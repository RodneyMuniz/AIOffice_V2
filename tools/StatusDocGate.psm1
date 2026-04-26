Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot

function Get-RepositoryRoot {
    return $repoRoot
}

function Get-ModuleRepositoryRootPath {
    return (Resolve-Path -LiteralPath (Get-RepositoryRoot)).Path
}

function Resolve-PathValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [string]$AnchorPath = (Get-ModuleRepositoryRootPath)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    $resolvedAnchorPath = if (Test-Path -LiteralPath $AnchorPath) {
        (Resolve-Path -LiteralPath $AnchorPath).Path
    }
    else {
        [System.IO.Path]::GetFullPath($AnchorPath)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $resolvedAnchorPath $PathValue))
}

function Resolve-ExistingPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [string]$AnchorPath = (Get-ModuleRepositoryRootPath)
    )

    $resolvedPath = Resolve-PathValue -PathValue $PathValue -AnchorPath $AnchorPath
    if (-not (Test-Path -LiteralPath $resolvedPath)) {
        throw "$Label '$PathValue' does not exist."
    }

    return (Resolve-Path -LiteralPath $resolvedPath).Path
}

function Get-TextDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    try {
        return Get-Content -LiteralPath $Path -Raw
    }
    catch {
        throw "$Label at '$Path' could not be read. $($_.Exception.Message)"
    }
}

function Assert-RegexMatch {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [Parameter(Mandatory = $true)]
        [string]$Pattern,
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    if ($Text -notmatch $Pattern) {
        throw $Message
    }
}

function Get-R8TaskStatusMap {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $matches = [regex]::Matches($Text, '(?ms)^###\s+`(R8-\d{3})`.*?^\-\s+Status:\s+(done|planned)\s*$')
    if ($matches.Count -eq 0) {
        throw "$Context does not define any R8 task status headings."
    }

    $statusMap = @{}
    foreach ($match in $matches) {
        $taskId = $match.Groups[1].Value
        $status = $match.Groups[2].Value
        if ($statusMap.ContainsKey($taskId)) {
            throw "$Context defines duplicate task status entries for '$taskId'."
        }

        $statusMap[$taskId] = $status
    }

    return $statusMap
}

function Get-R9TaskStatusMap {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $matches = [regex]::Matches($Text, '(?ms)^###\s+`(R9-\d{3})`.*?^\-\s+Status:\s+(done|planned)\s*$')
    if ($matches.Count -eq 0) {
        throw "$Context does not define any R9 task status headings."
    }

    $statusMap = @{}
    foreach ($match in $matches) {
        $taskId = $match.Groups[1].Value
        $status = $match.Groups[2].Value
        if ($statusMap.ContainsKey($taskId)) {
            throw "$Context defines duplicate task status entries for '$taskId'."
        }

        $statusMap[$taskId] = $status
    }

    return $statusMap
}

function Get-ContiguousDoneThroughFromStatusMap {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$StatusMap,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [string]$TaskPrefix = "R8",
        [int]$TaskCount = 9
    )

    $doneThrough = 0
    $plannedStart = $null
    $plannedThrough = $null

    foreach ($taskNumber in 1..$TaskCount) {
        $taskId = "{0}-{1}" -f $TaskPrefix, $taskNumber.ToString("000")
        if (-not $StatusMap.ContainsKey($taskId)) {
            throw "$Context is missing status for '$taskId'."
        }

        $status = $StatusMap[$taskId]
        if ($status -eq "done") {
            if ($null -ne $plannedStart) {
                throw "$Context marks '$taskId' done after planned tasks have already started."
            }

            $doneThrough = $taskNumber
            continue
        }

        if ($null -eq $plannedStart) {
            $plannedStart = $taskNumber
        }

        $plannedThrough = $taskNumber
    }

    if ($doneThrough -lt $TaskCount -and $null -eq $plannedStart) {
        throw "$Context must preserve at least one planned $TaskPrefix task while the milestone remains open."
    }

    return [pscustomobject]@{
        DoneThrough = $doneThrough
        PlannedStart = $plannedStart
        PlannedThrough = $plannedThrough
    }
}

function Get-ActiveStateR8StatusSnapshot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $openRangeMatches = [regex]::Matches($Text, 'R8-001`\s+through\s+`R8-(\d{3})`\s+complete\s+and\s+`R8-(\d{3})`\s+through\s+`R8-(\d{3})`\s+planned(?:\s+only)?')
    $openSingleMatches = [regex]::Matches($Text, 'R8-001`\s+through\s+`R8-(\d{3})`\s+complete\s+and\s+`R8-(\d{3})`\s+(?:remains\s+)?planned(?:\s+only)?')
    $closedMatches = [regex]::Matches($Text, 'R8-001`\s+through\s+`R8-(\d{3})`\s+complete(?!\s+and)')

    $snapshots = @()

    foreach ($match in $openRangeMatches) {
        $snapshots += [pscustomobject]@{
            DoneThrough = [int]$match.Groups[1].Value
            PlannedStart = [int]$match.Groups[2].Value
            PlannedThrough = [int]$match.Groups[3].Value
        }
    }

    foreach ($match in $openSingleMatches) {
        $snapshots += [pscustomobject]@{
            DoneThrough = [int]$match.Groups[1].Value
            PlannedStart = [int]$match.Groups[2].Value
            PlannedThrough = [int]$match.Groups[2].Value
        }
    }

    if ($snapshots.Count -eq 0 -and $closedMatches.Count -gt 0) {
        foreach ($match in $closedMatches) {
            $snapshots += [pscustomobject]@{
                DoneThrough = [int]$match.Groups[1].Value
                PlannedStart = $null
                PlannedThrough = $null
            }
        }
    }

    if ($snapshots.Count -eq 0) {
        throw "$Context does not expose an R8 summary status range."
    }

    $firstSnapshot = $snapshots[0]
    foreach ($snapshot in $snapshots) {
        if ($snapshot.DoneThrough -ne $firstSnapshot.DoneThrough -or $snapshot.PlannedStart -ne $firstSnapshot.PlannedStart -or $snapshot.PlannedThrough -ne $firstSnapshot.PlannedThrough) {
            throw "$Context contains contradictory R8 summary status ranges."
        }
    }

    return $firstSnapshot
}

function Get-ReadmeR8StatusSnapshot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $doneMatches = [regex]::Matches($Text, '`R8-(\d{3})`\s+is\s+complete')
    if ($doneMatches.Count -eq 0) {
        throw "$Context does not record any completed R8 task statements."
    }

    $doneTasks = @($doneMatches | ForEach-Object { [int]$_.Groups[1].Value } | Sort-Object -Unique)
    $doneThrough = $doneTasks[-1]
    foreach ($taskNumber in 1..$doneThrough) {
        if ($doneTasks -notcontains $taskNumber) {
            throw "$Context skips completed R8 task '$taskNumber' in its task summary."
        }
    }

    $plannedRangeMatch = [regex]::Match($Text, '`R8-(\d{3})`\s+through\s+`R8-(\d{3})`\s+remain\s+planned\s+only')
    $plannedSingleMatch = [regex]::Match($Text, '`R8-(\d{3})`\s+(?:remains|is)\s+planned\s+only')

    if ($doneThrough -ge 9) {
        return [pscustomobject]@{
            DoneThrough = $doneThrough
            PlannedStart = $null
            PlannedThrough = $null
        }
    }

    if ($plannedRangeMatch.Success) {
        return [pscustomobject]@{
            DoneThrough = $doneThrough
            PlannedStart = [int]$plannedRangeMatch.Groups[1].Value
            PlannedThrough = [int]$plannedRangeMatch.Groups[2].Value
        }
    }

    if ($plannedSingleMatch.Success) {
        return [pscustomobject]@{
            DoneThrough = $doneThrough
            PlannedStart = [int]$plannedSingleMatch.Groups[1].Value
            PlannedThrough = [int]$plannedSingleMatch.Groups[1].Value
        }
    }

    throw "$Context must preserve an explicit planned-only statement for the remaining R8 tasks while R8 stays open."
}

function Assert-R8NonClaimsPreserved {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $nonClaimsSectionMatch = [regex]::Match($Text, '(?ms)^##\s+Preserved non-claims\s*\r?\n(.*?)(?=^##\s+|\z)')
    if (-not $nonClaimsSectionMatch.Success) {
        throw "$Context must preserve a 'Preserved non-claims' section."
    }

    $nonClaimsSectionText = $nonClaimsSectionMatch.Groups[1].Value

    $requiredPhrases = @(
        "UI or control-room productization",
        "Standard runtime",
        "multi-repo orchestration",
        "swarms",
        "broad autonomous milestone execution",
        "unattended automatic resume",
        "destructive rollback"
    )

    foreach ($requiredPhrase in $requiredPhrases) {
        if ($nonClaimsSectionText -notmatch [regex]::Escape($requiredPhrase)) {
            throw "$Context must preserve the R8 non-claim '$requiredPhrase'."
        }
    }
}

function Assert-PositiveClaimHasReference {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [Parameter(Mandatory = $true)]
        [string]$ClaimLabel,
        [Parameter(Mandatory = $true)]
        [string]$PositivePattern,
        [Parameter(Mandatory = $true)]
        [string]$ReferencePattern
    )

    $lines = $Text -split "\r?\n"
    foreach ($line in $lines) {
        if ($line -match $PositivePattern) {
            if ($line -match '(?i)\b(no|not|without|cannot)\b') {
                continue
            }

            if ($Text -notmatch $ReferencePattern) {
                throw "$Context claims $ClaimLabel without a concrete reference."
            }
        }
    }
}

function Assert-MostRecentlyClosedMilestoneConsistency {
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$Texts,
        [Parameter(Mandatory = $true)]
        [bool]$R8Closed
    )

    $forbiddenMilestone = if ($R8Closed) {
        "R7 Fault-Managed Continuity and Rollback Drill"
    }
    else {
        "R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner"
    }

    $escapedForbiddenMilestone = [regex]::Escape('`' + $forbiddenMilestone + '`')
    $forbiddenPatterns = @(
        ($escapedForbiddenMilestone + '\s+(?:is\s+now|is|remains|was)?\s*the\s+most\s+recently\s+closed\s+milestone'),
        ('most\s+recently\s+closed\s+milestone\s*\r?\n\s*' + $escapedForbiddenMilestone)
    )

    foreach ($entry in $Texts.GetEnumerator()) {
        foreach ($forbiddenPattern in $forbiddenPatterns) {
            if ($entry.Value -match $forbiddenPattern) {
                throw "$($entry.Key) contains a stale most recently closed milestone claim for '$forbiddenMilestone'."
            }
        }
    }
}

function Assert-R9NonClaimsPreserved {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $nonClaimsSectionMatch = [regex]::Match($Text, '(?ms)^##\s+Required non-claims\s*\r?\n(.*?)(?=^##\s+|\z)')
    if (-not $nonClaimsSectionMatch.Success) {
        throw "$Context must preserve a 'Required non-claims' section."
    }

    $nonClaimsSectionText = $nonClaimsSectionMatch.Groups[1].Value

    $requiredPhrases = @(
        "no UI or control-room productization",
        "no Standard runtime",
        "no multi-repo orchestration",
        "no swarms",
        "no broad autonomous milestone execution",
        "no unattended automatic resume",
        "no destructive rollback",
        "no production-grade CI for every workflow",
        "no general Codex reliability claim",
        "no claim that Codex context compaction is solved",
        "no claim that hours-long milestones can now run unattended"
    )

    foreach ($requiredPhrase in $requiredPhrases) {
        if ($nonClaimsSectionText -notmatch [regex]::Escape($requiredPhrase)) {
            throw "$Context must preserve the R9 non-claim '$requiredPhrase'."
        }
    }
}

function Test-R9OpeningStatus {
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$Texts
    )

    if (-not $Texts.Contains("R9Authority")) {
        throw "R9 authority document must exist when R9 is open."
    }

    $kanbanTaskStatuses = Get-R9TaskStatusMap -Text $Texts.Kanban -Context "KANBAN"
    $authorityTaskStatuses = Get-R9TaskStatusMap -Text $Texts.R9Authority -Context "R9 authority"

    foreach ($taskId in $kanbanTaskStatuses.Keys) {
        if ($authorityTaskStatuses[$taskId] -ne $kanbanTaskStatuses[$taskId]) {
            throw "R9 authority does not match KANBAN for status '$taskId'."
        }
    }

    $kanbanSnapshot = Get-ContiguousDoneThroughFromStatusMap -StatusMap $kanbanTaskStatuses -Context "KANBAN" -TaskPrefix "R9" -TaskCount 7
    $authoritySnapshot = Get-ContiguousDoneThroughFromStatusMap -StatusMap $authorityTaskStatuses -Context "R9 authority" -TaskPrefix "R9" -TaskCount 7

    if ($authoritySnapshot.DoneThrough -ne $kanbanSnapshot.DoneThrough -or $authoritySnapshot.PlannedStart -ne $kanbanSnapshot.PlannedStart -or $authoritySnapshot.PlannedThrough -ne $kanbanSnapshot.PlannedThrough) {
        throw "R9 authority does not match KANBAN for the live R9 task status boundary."
    }

    if ($kanbanSnapshot.DoneThrough -ne 4 -or $kanbanSnapshot.PlannedStart -ne 5 -or $kanbanSnapshot.PlannedThrough -ne 7) {
        throw "R9 status must keep only R9-001 through R9-004 done and R9-005 through R9-007 planned."
    }

    Assert-RegexMatch -Text $Texts.Readme -Pattern 'R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`\s+is now the active milestone in repo truth through `R9-004` only' -Message "README must declare R9 as the active milestone through R9-004 only."
    Assert-RegexMatch -Text $Texts.ActiveState -Pattern '## Active Milestone\s+`R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`\s+is now active in repo truth through `R9-004` only\.' -Message "ACTIVE_STATE must declare R9 as the active milestone through R9-004 only."
    Assert-RegexMatch -Text $Texts.Kanban -Pattern '## Active Milestone\s+`R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`' -Message "KANBAN must declare R9 as the active milestone."
    Assert-RegexMatch -Text $Texts.DecisionLog -Pattern 'R9 Opened As Isolated QA And Continuity-Managed Pilot' -Message "DECISION_LOG must record the R9 opening decision."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`\s+is now active in repo truth through `R9-004` only' -Message "R9 authority must declare R9 active through R9-004 only."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'R9-005`\s+through\s+`R9-007`\s+remain planned only' -Message "R9 authority must keep R9-005 through R9-007 planned only."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'contracts/isolated_qa/qa_signoff_packet\.contract\.json' -Message "R9 authority must cite the R9-002 QA signoff contract."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'tools/IsolatedQaSignoff\.psm1' -Message "R9 authority must cite the R9-002 isolated QA signoff validator module."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'tests/test_isolated_qa_signoff\.ps1' -Message "R9 authority must cite the R9-002 focused test."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'contracts/post_push_support/final_remote_head_support_packet\.contract\.json' -Message "R9 authority must cite the R9-003 final remote-head support contract."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'tools/FinalRemoteHeadSupport\.psm1' -Message "R9 authority must cite the R9-003 final remote-head support validator module."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'tests/test_final_remote_head_support\.ps1' -Message "R9 authority must cite the R9-003 focused test."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'contracts/external_runner_artifact/external_runner_artifact_identity\.contract\.json' -Message "R9 authority must cite the R9-004 external runner artifact identity contract."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'tools/ExternalRunnerArtifactIdentity\.psm1' -Message "R9 authority must cite the R9-004 external runner artifact identity validator module."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'tests/test_external_runner_artifact_identity\.ps1' -Message "R9 authority must cite the R9-004 focused test."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'state/fixtures/valid/external_runner_artifact/external_runner_limitation\.valid\.json' -Message "R9 authority must cite the R9-004 explicit limitation fixture when no real run identity is captured."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'no concrete CI or external runner artifact identity is claimed' -Message "R9 authority must preserve the R9-004 no-concrete-run-identity limitation."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'R9 remains blocked from claiming external proof until a real run identity is captured' -Message "R9 authority must keep external proof blocked until a real run identity is captured."
    Assert-R9NonClaimsPreserved -Text $Texts.R9Authority -Context "R9 authority"

    return $kanbanSnapshot
}

function Test-StatusDocGate {
    [CmdletBinding()]
    param(
        [string]$RepositoryRoot = (Get-ModuleRepositoryRootPath)
    )

    $resolvedRepositoryRoot = Resolve-ExistingPath -PathValue $RepositoryRoot -Label "Repository root"

    $paths = [ordered]@{
        README = Resolve-ExistingPath -PathValue "README.md" -Label "README" -AnchorPath $resolvedRepositoryRoot
        ActiveState = Resolve-ExistingPath -PathValue "governance\ACTIVE_STATE.md" -Label "Active state" -AnchorPath $resolvedRepositoryRoot
        Kanban = Resolve-ExistingPath -PathValue "execution\KANBAN.md" -Label "Kanban" -AnchorPath $resolvedRepositoryRoot
        DecisionLog = Resolve-ExistingPath -PathValue "governance\DECISION_LOG.md" -Label "Decision log" -AnchorPath $resolvedRepositoryRoot
        R8Authority = Resolve-ExistingPath -PathValue "governance\R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md" -Label "R8 authority" -AnchorPath $resolvedRepositoryRoot
    }

    $r9AuthorityPath = Resolve-PathValue -PathValue "governance\R9_ISOLATED_QA_AND_CONTINUITY_MANAGED_MILESTONE_EXECUTION_PILOT.md" -AnchorPath $resolvedRepositoryRoot
    if (Test-Path -LiteralPath $r9AuthorityPath) {
        $paths["R9Authority"] = (Resolve-Path -LiteralPath $r9AuthorityPath).Path
    }

    $texts = [ordered]@{}
    foreach ($entry in $paths.GetEnumerator()) {
        $texts[$entry.Key] = Get-TextDocument -Path $entry.Value -Label $entry.Key
    }

    $kanbanTaskStatuses = Get-R8TaskStatusMap -Text $texts.Kanban -Context "KANBAN"
    $authorityTaskStatuses = Get-R8TaskStatusMap -Text $texts.R8Authority -Context "R8 authority"

    foreach ($taskId in $kanbanTaskStatuses.Keys) {
        if ($authorityTaskStatuses[$taskId] -ne $kanbanTaskStatuses[$taskId]) {
            throw "R8 authority does not match KANBAN for status '$taskId'."
        }
    }

    $kanbanSnapshot = Get-ContiguousDoneThroughFromStatusMap -StatusMap $kanbanTaskStatuses -Context "KANBAN"
    $authoritySnapshot = Get-ContiguousDoneThroughFromStatusMap -StatusMap $authorityTaskStatuses -Context "R8 authority"
    $activeStateSnapshot = Get-ActiveStateR8StatusSnapshot -Text $texts.ActiveState -Context "ACTIVE_STATE"
    $readmeSnapshot = Get-ReadmeR8StatusSnapshot -Text $texts.Readme -Context "README"

    foreach ($snapshot in @(
            @{ Name = "R8 authority"; Value = $authoritySnapshot },
            @{ Name = "ACTIVE_STATE"; Value = $activeStateSnapshot },
            @{ Name = "README"; Value = $readmeSnapshot }
        )) {
        if ($snapshot.Value.DoneThrough -ne $kanbanSnapshot.DoneThrough -or $snapshot.Value.PlannedStart -ne $kanbanSnapshot.PlannedStart -or $snapshot.Value.PlannedThrough -ne $kanbanSnapshot.PlannedThrough) {
            throw "$($snapshot.Name) does not match KANBAN for the live R8 task status boundary."
        }
    }

    Assert-R8NonClaimsPreserved -Text $texts.R8Authority -Context "R8 authority"

    $combinedText = [string]::Join([Environment]::NewLine, @($texts.Values))
    $r8CloseoutText = [string]::Join([Environment]::NewLine, @(
            $texts.Readme,
            $texts.ActiveState,
            $texts.Kanban,
            $texts.DecisionLog,
            $texts.R8Authority
        ))
    $r8ClosedClaimed = $false

    $closeoutClaimPatterns = @(
        'R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`\s+is now closed in repo truth',
        'R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`\s+is formally closed',
        'R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`\s+is the most recently closed milestone'
    )
    foreach ($closeoutClaimPattern in $closeoutClaimPatterns) {
        if ($combinedText -match $closeoutClaimPattern) {
            $r8ClosedClaimed = $true
            break
        }
    }

    $r8Closed = $kanbanSnapshot.DoneThrough -ge 9 -or $r8ClosedClaimed
    Assert-MostRecentlyClosedMilestoneConsistency -Texts $texts -R8Closed $r8Closed
    $r9Opened = $combinedText -match 'R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`\s+is now (?:the )?active'
    $r9Snapshot = $null

    if (-not $r8Closed) {
        Assert-RegexMatch -Text $texts.Readme -Pattern 'R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`\s+is now the active milestone' -Message "README must declare R8 as the active milestone."
        Assert-RegexMatch -Text $texts.ActiveState -Pattern '## Active Milestone\s+`R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`' -Message "ACTIVE_STATE must declare R8 as the active milestone."
        Assert-RegexMatch -Text $texts.Kanban -Pattern '## Active Milestone\s+`R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`' -Message "KANBAN must declare R8 as the active milestone."
        Assert-RegexMatch -Text $texts.R8Authority -Pattern 'R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`\s+is now active in repo truth' -Message "R8 authority must declare R8 as active in repo truth."

        Assert-RegexMatch -Text $texts.Readme -Pattern 'R7 Fault-Managed Continuity and Rollback Drill`\s+is now the most recently closed milestone' -Message "README must preserve R7 as the most recently closed milestone."
        Assert-RegexMatch -Text $texts.Kanban -Pattern '## Most Recently Closed Milestone\s+`R7 Fault-Managed Continuity and Rollback Drill`' -Message "KANBAN must preserve R7 as the most recently closed milestone."
        Assert-RegexMatch -Text $texts.R8Authority -Pattern 'R7 Fault-Managed Continuity and Rollback Drill`\s+remains the most recently closed milestone' -Message "R8 authority must preserve R7 as the most recently closed milestone."
    }
    else {
        Assert-RegexMatch -Text $texts.Readme -Pattern 'R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`\s+is now the most recently closed milestone' -Message "README must mark R8 as the most recently closed milestone after R8-009."
        if ($r9Opened) {
            $r9Snapshot = Test-R9OpeningStatus -Texts $texts
        }
        else {
            Assert-RegexMatch -Text $texts.ActiveState -Pattern 'No active implementation milestone is open after R8 closeout' -Message "ACTIVE_STATE must not open a successor milestone after R8 closeout."
            Assert-RegexMatch -Text $texts.Kanban -Pattern '## Active Milestone\s+No active implementation milestone is open after R8 closeout\.' -Message "KANBAN must not open a successor milestone after R8 closeout."
        }
        Assert-RegexMatch -Text $texts.Kanban -Pattern '## Most Recently Closed Milestone\s+`R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`' -Message "KANBAN must mark R8 as the most recently closed milestone."
        Assert-RegexMatch -Text $texts.R8Authority -Pattern 'R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`\s+is now closed in repo truth' -Message "R8 authority must declare R8 closed in repo truth."
    }

    if ($r8Closed) {
        if ($kanbanSnapshot.DoneThrough -lt 9) {
            throw "Status docs claim R8 is closed before R8-009 is complete."
        }

        if ($kanbanSnapshot.PlannedStart -ne $null -or $kanbanSnapshot.PlannedThrough -ne $null) {
            throw "Status docs cannot keep planned R8 tasks once R8-009 is marked done."
        }

        if ($r8CloseoutText -notmatch 'qa_proof_packet\.json') {
            throw "R8 closeout claims require a referenced QA packet."
        }

        if ($r8CloseoutText -notmatch '(?i)(state[\\/](proof_reviews|qa)|artifacts|support)[\\/][^\s`]*remote[_-]head[_-]verification[^\s`]*\.json') {
            throw "R8 closeout claims require a referenced remote-head verification artifact."
        }

        if ($r8CloseoutText -notmatch '(?i)(state[\\/](proof_reviews|qa)|artifacts|support)[\\/].*post[_-]push.*verification.*\.json' -and $r8CloseoutText -notmatch '(?i)post-push verification.{0,120}(limitation|not committed)|no committed exact-final post-push verification artifact is claimed') {
            throw "R8 closeout claims require either a post-push verification artifact reference or an explicit exact-final post-push verification limitation."
        }

        if ($r8CloseoutText -notmatch '(?i)actions/runs/\d+' -and $r8CloseoutText -notmatch '(?i)no concrete (CI|external|CI/external).*proof.*artifact.*claimed|external proof runner foundation exists') {
            throw "R8 closeout claims require either a concrete external workflow run identity or an explicit external-proof non-claim."
        }

        if ($r8CloseoutText -notmatch '(?i)state/proof_reviews/.*/r8') {
            throw "R8 closeout claims require a referenced R8 proof package path."
        }
    }

    Assert-PositiveClaimHasReference -Text $combinedText -Context "Status docs" -ClaimLabel "a concrete CI or external proof artifact" -PositivePattern '(?i)\bconcrete\b.*\b(ci|external)\b.*\bproof\b.*\b(artifact|run)\b.*\b(exists|recorded|available|present)\b' -ReferencePattern '(?i)actions/runs/\d+'
    Assert-PositiveClaimHasReference -Text $combinedText -Context "Status docs" -ClaimLabel "a clean-checkout QA packet" -PositivePattern '(?i)\b(clean-checkout qa|qa proof packet|qa packet)\b.*\b(exists|recorded|available|present)\b' -ReferencePattern 'qa_proof_packet\.json'
    Assert-PositiveClaimHasReference -Text $combinedText -Context "Status docs" -ClaimLabel "a post-push verification artifact" -PositivePattern '(?i)\bpost-push verification artifact\b.*\b(exists|recorded|available|present)\b' -ReferencePattern '(?i)(state[\\/](proof_reviews|qa)|artifacts|support)[\\/].*post[_-]push.*verification.*\.json'

    if (-not $r8Closed -and $texts.DecisionLog -match 'R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner.*no later implementation milestone is open yet in repo truth') {
        throw "DECISION_LOG still implies no later implementation milestone is open after R8 was opened."
    }

    $activeMilestone = if ($r9Opened) { "R9 Isolated QA and Continuity-Managed Milestone Execution Pilot" } elseif ($r8Closed) { "none" } else { "R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner" }
    $mostRecentlyClosedMilestone = if ($r8Closed) { "R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner" } else { "R7 Fault-Managed Continuity and Rollback Drill" }

    return [pscustomobject]@{
        ActiveMilestone = $activeMilestone
        MostRecentlyClosedMilestone = $mostRecentlyClosedMilestone
        DoneThrough = $kanbanSnapshot.DoneThrough
        PlannedStart = $kanbanSnapshot.PlannedStart
        PlannedThrough = $kanbanSnapshot.PlannedThrough
        R9DoneThrough = if ($null -eq $r9Snapshot) { $null } else { $r9Snapshot.DoneThrough }
        R9PlannedStart = if ($null -eq $r9Snapshot) { $null } else { $r9Snapshot.PlannedStart }
        R9PlannedThrough = if ($null -eq $r9Snapshot) { $null } else { $r9Snapshot.PlannedThrough }
        R8RemainsOpen = (-not $r8Closed)
        R8Closed = $r8Closed
        R9Opened = $r9Opened
    }
}

Export-ModuleMember -Function Test-StatusDocGate
