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

function Get-R10TaskStatusMap {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $matches = [regex]::Matches($Text, '(?ms)^###\s+`(R10-\d{3})`.*?^\-\s+Status:\s+(done|planned)\s*$')
    if ($matches.Count -eq 0) {
        throw "$Context does not define any R10 task status headings."
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

function Get-R11TaskStatusMap {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $matches = [regex]::Matches($Text, '(?ms)^###\s+`(R11-\d{3})`.*?^\-\s+Status:\s+(done|planned)\s*$')
    if ($matches.Count -eq 0) {
        throw "$Context does not define any R11 task status headings."
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

function Get-R12TaskStatusMap {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $matches = [regex]::Matches($Text, '(?ms)^###\s+`(R12-\d{3})`.*?^\-\s+Status:\s+(done|planned)\s*$')
    if ($matches.Count -eq 0) {
        throw "$Context does not define any R12 task status headings."
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
            if ($line -match '(?i)\b(no|not|without|cannot|unless)\b') {
                continue
            }

            if ($ClaimLabel -eq "a concrete CI or external proof artifact") {
                if ($line -notmatch $ReferencePattern) {
                    throw "$Context claims $ClaimLabel without a concrete reference."
                }

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
        [bool]$R8Closed,
        [bool]$R9Closed = $false,
        [bool]$R10Closed = $false,
        [bool]$R11Closed = $false
    )

    $forbiddenMilestones = if ($R11Closed) {
        @(
            "R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation",
            "R9 Isolated QA and Continuity-Managed Milestone Execution Pilot",
            "R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner",
            "R7 Fault-Managed Continuity and Rollback Drill"
        )
    }
    elseif ($R10Closed) {
        @(
            "R9 Isolated QA and Continuity-Managed Milestone Execution Pilot",
            "R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner",
            "R7 Fault-Managed Continuity and Rollback Drill"
        )
    }
    elseif ($R9Closed) {
        @(
            "R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner",
            "R7 Fault-Managed Continuity and Rollback Drill"
        )
    }
    elseif ($R8Closed) {
        @("R7 Fault-Managed Continuity and Rollback Drill")
    }
    else {
        @("R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner")
    }

    foreach ($forbiddenMilestone in $forbiddenMilestones) {
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

function Assert-R10NonClaimsPreserved {
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
        "no swarms or fleet execution",
        "no broad autonomous milestone execution",
        "no unattended automatic resume",
        "no solved Codex context compaction",
        "no hours-long unattended milestone execution",
        "no destructive rollback",
        "no production-grade CI for every workflow",
        "no general Codex reliability",
        "no broad segmented milestone execution beyond the external-runner proof loop"
    )

    foreach ($requiredPhrase in $requiredPhrases) {
        if ($nonClaimsSectionText -notmatch [regex]::Escape($requiredPhrase)) {
            throw "$Context must preserve the R10 non-claim '$requiredPhrase'."
        }
    }
}

function Assert-R11NonClaimsPreserved {
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
        "no solved Codex context compaction",
        "no hours-long unattended execution",
        "no hours-long unattended milestone execution",
        "no executor self-certification as QA",
        "no Dev result accepted as QA authority",
        "no real production QA",
        "no destructive rollback",
        "no broad CI/product coverage",
        "no general Codex reliability",
        "no productized control-room behavior",
        "no production runtime",
        "no successor milestone without explicit approval",
        "no claim beyond one bounded R11 controlled-cycle pilot"
    )

    foreach ($requiredPhrase in $requiredPhrases) {
        if ($nonClaimsSectionText -notmatch [regex]::Escape($requiredPhrase)) {
            throw "$Context must preserve the R11 non-claim '$requiredPhrase'."
        }
    }
}

function Assert-R12NonClaimsPreserved {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $nonClaimsSectionMatch = [regex]::Match($Text, '(?ms)^##\s+Required Non-Claims\s*\r?\n(.*?)(?=^##\s+|\z)')
    if (-not $nonClaimsSectionMatch.Success) {
        throw "$Context must preserve a 'Required Non-Claims' section."
    }

    $nonClaimsSectionText = $nonClaimsSectionMatch.Groups[1].Value

    $requiredPhrases = @(
        "delivered R12 value gates",
        "10 percent or larger corrected progress uplift",
        "broad autonomous milestone execution",
        "unattended automatic resume",
        "solved Codex context compaction",
        "production runtime",
        "real production QA",
        "full UI/control-room productization",
        "productized control-room behavior",
        "Standard runtime",
        "multi-repo orchestration",
        "swarms",
        "broad CI/product coverage",
        "general Codex reliability",
        "R13 or successor opening"
    )

    foreach ($requiredPhrase in $requiredPhrases) {
        if ($nonClaimsSectionText -notmatch [regex]::Escape($requiredPhrase)) {
            throw "$Context must preserve the R12 non-claim '$requiredPhrase'."
        }
    }
}

function Test-LineHasNegation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Line
    )

    if ($Line -match '^\s*-\s+(any\s+)?(broad UI or control-room productization|UI or control-room productization|Standard runtime|Standard or subproject runtime|multi-repo orchestration|multi-repo or fleet orchestration|swarms|swarms or fleet execution|broad autonomous milestone execution|unattended automatic resume|solved Codex context compaction|hours-long unattended milestone execution|destructive rollback|destructive primary-tree rollback)') {
        return $true
    }

    return ($Line -match '(?i)\b(no|not|without|cannot|must not|does not|do not|is not|are not|did not|does not widen|does not open|non-claim|nonclaims|non-scope|claim of|any claim|any implemented|claiming|scope widens|widens|excludes|refuse|reject|rejects|rejected|rejecting|stop|fail closed|fails closed|fail-closed|explicitly excluded|implies|must not claim|does not claim|does not prove|docs claim)\b')
}

function Assert-NoForbiddenPositiveClaim {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [Parameter(Mandatory = $true)]
        [string]$ClaimLabel,
        [Parameter(Mandatory = $true)]
        [string]$Pattern
    )

    $lines = $Text -split "\r?\n"
    foreach ($line in $lines) {
        if ($line -match $Pattern -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims $ClaimLabel. Offending line: $line"
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

    if ($kanbanSnapshot.DoneThrough -ne 6 -or $kanbanSnapshot.PlannedStart -ne 7 -or $kanbanSnapshot.PlannedThrough -ne 7) {
        throw "R9 status must keep only R9-001 through R9-006 done and R9-007 planned."
    }

    Assert-RegexMatch -Text $Texts.Readme -Pattern 'R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`\s+is now the active milestone in repo truth through `R9-006` only' -Message "README must declare R9 as the active milestone through R9-006 only."
    Assert-RegexMatch -Text $Texts.ActiveState -Pattern '## Active Milestone\s+`R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`\s+is now active in repo truth through `R9-006` only\.' -Message "ACTIVE_STATE must declare R9 as the active milestone through R9-006 only."
    Assert-RegexMatch -Text $Texts.Kanban -Pattern '## Active Milestone\s+`R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`' -Message "KANBAN must declare R9 as the active milestone."
    Assert-RegexMatch -Text $Texts.DecisionLog -Pattern 'R9 Opened As Isolated QA And Continuity-Managed Pilot' -Message "DECISION_LOG must record the R9 opening decision."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`\s+is now active in repo truth through `R9-006` only' -Message "R9 authority must declare R9 active through R9-006 only."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'R9-007`\s+remains planned only' -Message "R9 authority must keep R9-007 planned only."
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
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'contracts/execution_segments/execution_segment_dispatch\.contract\.json' -Message "R9 authority must cite the R9-005 execution segment dispatch contract."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'tools/ExecutionSegmentContinuity\.psm1' -Message "R9 authority must cite the R9-005 execution segment validator module."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'tests/test_execution_segment_continuity\.ps1' -Message "R9 authority must cite the R9-005 focused test."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'state/fixtures/valid/execution_segments/execution_segment_handoff\.valid\.json' -Message "R9 authority must cite the R9-005 valid handoff fixture."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'state/pilots/r9_tiny_segmented_milestone_pilot/pilot_request\.json' -Message "R9 authority must cite the R9-006 pilot request artifact."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'state/pilots/r9_tiny_segmented_milestone_pilot/segments/segment_001_result\.json' -Message "R9 authority must cite the R9-006 segment result artifact."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'state/pilots/r9_tiny_segmented_milestone_pilot/qa/isolated_qa_signoff\.json' -Message "R9 authority must cite the R9-006 isolated QA signoff artifact."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'tests/test_r9_tiny_segmented_pilot\.ps1' -Message "R9 authority must cite the R9-006 focused pilot test."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'R9 still does not close' -Message "R9 authority must preserve that R9 is not closed by R9-006."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'The pilot proves only one tiny bounded segmented control path' -Message "R9 authority must bound the R9-006 pilot claim."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'R9 still does not solve Codex context compaction' -Message "R9 authority must preserve the Codex compaction non-claim."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'R9 still does not prove hours-long unattended milestone execution' -Message "R9 authority must preserve the hours-long unattended milestone non-claim."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'R9 still does not prove unattended automatic resume' -Message "R9 authority must preserve the unattended automatic resume non-claim."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'R9 still does not prove broad autonomous milestone execution' -Message "R9 authority must preserve the broad-autonomy non-claim."
    Assert-R9NonClaimsPreserved -Text $Texts.R9Authority -Context "R9 authority"

    return $kanbanSnapshot
}

function Test-R9ClosedStatus {
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$Texts,
        [bool]$AllowR10Active = $false,
        [bool]$AllowR10Closed = $false,
        [bool]$AllowR11Active = $false,
        [bool]$AllowR11Closed = $false,
        [bool]$AllowR12Active = $false
    )

    if (-not $Texts.Contains("R9Authority")) {
        throw "R9 authority document must exist when R9 is closed."
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

    if ($kanbanSnapshot.DoneThrough -ne 7 -or $kanbanSnapshot.PlannedStart -ne $null -or $kanbanSnapshot.PlannedThrough -ne $null) {
        throw "R9 closed status must keep R9-001 through R9-007 done with no planned R9 tasks."
    }

    if ($AllowR10Closed) {
        Assert-RegexMatch -Text $Texts.Readme -Pattern 'R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`\s+remains the prior closed milestone' -Message "README must preserve R9 as the prior closed milestone after R10 closeout."
    }
    else {
        Assert-RegexMatch -Text $Texts.Readme -Pattern 'R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`\s+is now the most recently closed milestone' -Message "README must mark R9 as the most recently closed milestone."
    }

    if ($AllowR10Closed -and $AllowR11Closed -and $AllowR12Active) {
        Assert-RegexMatch -Text $Texts.ActiveState -Pattern '## Active Milestone\s+`R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`\s+is now active in repo truth through `R12-016` only\.' -Message "ACTIVE_STATE must declare R12 as active through R12-016 only."
        Assert-RegexMatch -Text $Texts.Kanban -Pattern '## Active Milestone\s+`R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`' -Message "KANBAN must declare R12 as the active milestone."
    }
    elseif ($AllowR10Closed -and $AllowR11Closed) {
        Assert-RegexMatch -Text $Texts.ActiveState -Pattern '## Active Milestone\s+No active implementation milestone is open after R11 closeout\.' -Message "ACTIVE_STATE must not open a successor milestone after R11 closeout."
        Assert-RegexMatch -Text $Texts.Kanban -Pattern '## Active Milestone\s+No active implementation milestone is open after R11 closeout\.' -Message "KANBAN must not open a successor milestone after R11 closeout."
    }
    elseif ($AllowR10Closed -and -not $AllowR11Active) {
        Assert-RegexMatch -Text $Texts.ActiveState -Pattern '## Active Milestone\s+No active implementation milestone is open after R10 closeout\.' -Message "ACTIVE_STATE must not open a successor milestone after R10 closeout."
        Assert-RegexMatch -Text $Texts.Kanban -Pattern '## Active Milestone\s+No active implementation milestone is open after R10 closeout\.' -Message "KANBAN must not open a successor milestone after R10 closeout."
    }
    elseif ($AllowR10Closed -and $AllowR11Active) {
        Assert-RegexMatch -Text $Texts.ActiveState -Pattern '## Active Milestone\s+`R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot`\s+is now active in repo truth through `R11-008` only\.' -Message "ACTIVE_STATE must declare R11 as active through R11-008 only."
        Assert-RegexMatch -Text $Texts.Kanban -Pattern '## Active Milestone\s+`R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot`' -Message "KANBAN must declare R11 as the active milestone."
    }
    elseif ($AllowR10Active) {
        Assert-RegexMatch -Text $Texts.ActiveState -Pattern '## Active Milestone\s+`R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`\s+is now active in repo truth through `R10-007` only\.' -Message "ACTIVE_STATE must declare R10 as active through R10-007 only when R10 is open."
        Assert-RegexMatch -Text $Texts.Kanban -Pattern '## Active Milestone\s+`R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`' -Message "KANBAN must declare R10 as the active milestone when R10 is open."
    }
    else {
        Assert-RegexMatch -Text $Texts.ActiveState -Pattern '## Active Milestone\s+No active implementation milestone is open after R9 closeout\.' -Message "ACTIVE_STATE must not open a successor milestone after R9 closeout."
        Assert-RegexMatch -Text $Texts.Kanban -Pattern '## Active Milestone\s+No active implementation milestone is open after R9 closeout\.' -Message "KANBAN must not open a successor milestone after R9 closeout."
    }
    if (-not $AllowR10Closed) {
        Assert-RegexMatch -Text $Texts.Kanban -Pattern '## Most Recently Closed Milestone\s+`R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`' -Message "KANBAN must mark R9 as the most recently closed milestone."
    }
    Assert-RegexMatch -Text $Texts.DecisionLog -Pattern 'R9-007 Closed R9 Narrowly' -Message "DECISION_LOG must record the R9 closeout decision."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`\s+is now closed in repo truth' -Message "R9 authority must declare R9 closed in repo truth."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'state/proof_reviews/r9_isolated_qa_and_continuity_managed_milestone_execution_pilot/' -Message "R9 authority must cite the R9 proof-review package path."
    Assert-RegexMatch -Text $Texts.Readme -Pattern 'state/proof_reviews/r9_isolated_qa_and_continuity_managed_milestone_execution_pilot/' -Message "README must cite the R9 proof-review package path."
    Assert-RegexMatch -Text $Texts.ActiveState -Pattern 'state/proof_reviews/r9_isolated_qa_and_continuity_managed_milestone_execution_pilot/' -Message "ACTIVE_STATE must cite the R9 proof-review package path."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`\s+remains the prior closed milestone' -Message "R9 authority must preserve R8 as the prior closed milestone."

    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'contracts/isolated_qa/qa_signoff_packet\.contract\.json' -Message "R9 authority must cite the R9-002 QA signoff contract."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'tools/IsolatedQaSignoff\.psm1' -Message "R9 authority must cite the R9-002 isolated QA signoff validator module."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'tests/test_isolated_qa_signoff\.ps1' -Message "R9 authority must cite the R9-002 focused test."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'contracts/post_push_support/final_remote_head_support_packet\.contract\.json' -Message "R9 authority must cite the R9-003 final remote-head support contract."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'tools/FinalRemoteHeadSupport\.psm1' -Message "R9 authority must cite the R9-003 final remote-head support validator module."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'tests/test_final_remote_head_support\.ps1' -Message "R9 authority must cite the R9-003 focused test."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'contracts/external_runner_artifact/external_runner_artifact_identity\.contract\.json' -Message "R9 authority must cite the R9-004 external runner artifact identity contract."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'tools/ExternalRunnerArtifactIdentity\.psm1' -Message "R9 authority must cite the R9-004 external runner artifact identity validator module."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'state/fixtures/valid/external_runner_artifact/external_runner_limitation\.valid\.json' -Message "R9 authority must cite the R9-004 explicit limitation fixture."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'tests/test_external_runner_artifact_identity\.ps1' -Message "R9 authority must cite the R9-004 focused test."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'no concrete CI or external runner artifact identity is claimed' -Message "R9 authority must preserve the R9-004 no-concrete-run-identity limitation."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'R9 remains blocked from claiming external proof until a real run identity is captured' -Message "R9 authority must keep external proof blocked until a real run identity is captured."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'contracts/execution_segments/execution_segment_dispatch\.contract\.json' -Message "R9 authority must cite the R9-005 execution segment dispatch contract."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'tools/ExecutionSegmentContinuity\.psm1' -Message "R9 authority must cite the R9-005 execution segment validator module."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'tests/test_execution_segment_continuity\.ps1' -Message "R9 authority must cite the R9-005 focused test."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'state/pilots/r9_tiny_segmented_milestone_pilot/' -Message "R9 authority must cite the R9-006 tiny pilot package."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'state/pilots/r9_tiny_segmented_milestone_pilot/pilot_request\.json' -Message "R9 authority must cite the R9-006 pilot request artifact."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'tests/test_r9_tiny_segmented_pilot\.ps1' -Message "R9 authority must cite the R9-006 focused pilot test."

    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'R9 did not prove real external/CI runner artifact identity' -Message "R9 authority must preserve the real external/CI runner identity non-claim."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'R9 did not prove external QA proof' -Message "R9 authority must preserve the external QA proof non-claim."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'R9 did not solve Codex context compaction' -Message "R9 authority must preserve the Codex compaction non-claim."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'R9 did not prove hours-long unattended milestone execution' -Message "R9 authority must preserve the hours-long unattended milestone non-claim."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'R9 did not prove unattended automatic resume' -Message "R9 authority must preserve the unattended automatic resume non-claim."
    Assert-RegexMatch -Text $Texts.R9Authority -Pattern 'R9 did not prove broad autonomous milestone execution' -Message "R9 authority must preserve the broad-autonomy non-claim."
    Assert-R9NonClaimsPreserved -Text $Texts.R9Authority -Context "R9 authority"

    return $kanbanSnapshot
}

function Test-R10OpeningStatus {
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$Texts
    )

    if (-not $Texts.Contains("R10Authority")) {
        throw "R10 authority document must exist when R10 is open."
    }

    $kanbanTaskStatuses = Get-R10TaskStatusMap -Text $Texts.Kanban -Context "KANBAN"
    $authorityTaskStatuses = Get-R10TaskStatusMap -Text $Texts.R10Authority -Context "R10 authority"

    foreach ($taskId in $kanbanTaskStatuses.Keys) {
        if ($authorityTaskStatuses[$taskId] -ne $kanbanTaskStatuses[$taskId]) {
            throw "R10 authority does not match KANBAN for status '$taskId'."
        }
    }

    $kanbanSnapshot = Get-ContiguousDoneThroughFromStatusMap -StatusMap $kanbanTaskStatuses -Context "KANBAN" -TaskPrefix "R10" -TaskCount 8
    $authoritySnapshot = Get-ContiguousDoneThroughFromStatusMap -StatusMap $authorityTaskStatuses -Context "R10 authority" -TaskPrefix "R10" -TaskCount 8

    if ($authoritySnapshot.DoneThrough -ne $kanbanSnapshot.DoneThrough -or $authoritySnapshot.PlannedStart -ne $kanbanSnapshot.PlannedStart -or $authoritySnapshot.PlannedThrough -ne $kanbanSnapshot.PlannedThrough) {
        throw "R10 authority does not match KANBAN for the live R10 task status boundary."
    }

    if ($kanbanSnapshot.DoneThrough -ne 7 -or $kanbanSnapshot.PlannedStart -ne 8 -or $kanbanSnapshot.PlannedThrough -ne 8) {
        throw "R10 status must keep only R10-001 through R10-007 done and R10-008 planned."
    }

    $combinedText = [string]::Join([Environment]::NewLine, @($Texts.Values))

    Assert-RegexMatch -Text $Texts.Readme -Pattern 'R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`\s+is now the active milestone in repo truth through `R10-007` only' -Message "README must declare R10 as the active milestone through R10-007 only."
    Assert-RegexMatch -Text $Texts.ActiveState -Pattern '## Active Milestone\s+`R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`\s+is now active in repo truth through `R10-007` only\.' -Message "ACTIVE_STATE must declare R10 as active through R10-007 only."
    Assert-RegexMatch -Text $Texts.Kanban -Pattern '## Active Milestone\s+`R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`' -Message "KANBAN must declare R10 as the active milestone."
    Assert-RegexMatch -Text $Texts.Kanban -Pattern '## Most Recently Closed Milestone\s+`R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`' -Message "KANBAN must keep R9 as the most recently closed milestone while R10 is open."
    Assert-RegexMatch -Text $Texts.DecisionLog -Pattern 'R10-001 Opened R10 Narrowly' -Message "DECISION_LOG must record the R10 opening decision."
    Assert-RegexMatch -Text $Texts.DecisionLog -Pattern 'R10-006 Added External-Runner-Consuming QA Signoff' -Message "DECISION_LOG must record the R10-006 QA signoff decision."
    Assert-RegexMatch -Text $Texts.DecisionLog -Pattern 'R10-007 Defined Two-Phase Final-Head Support' -Message "DECISION_LOG must record the R10-007 two-phase support decision."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`\s+is now active in repo truth through `R10-007` only' -Message "R10 authority must declare R10 active through R10-007 only."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'R10-008`\s+remains planned only' -Message "R10 authority must keep R10-008 planned only."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`\s+remains the most recently closed milestone' -Message "R10 authority must keep R9 as the most recently closed milestone."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'governance/reports/AIOffice_V2_R9_Audit_and_R10_Planning_Report_v2\.md' -Message "R10 authority must reference the R9-to-R10 operator report as narrative only."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'It is not milestone proof by itself' -Message "R10 authority must state that the operator report is not milestone proof by itself."
    Assert-RegexMatch -Text $Texts.Readme -Pattern 'R10 branch is `release/r10-real-external-runner-proof-foundation`' -Message "README must record the active R10 release branch."
    Assert-RegexMatch -Text $Texts.ActiveState -Pattern 'active R10 branch is `release/r10-real-external-runner-proof-foundation`' -Message "ACTIVE_STATE must record the active R10 release branch."
    Assert-RegexMatch -Text $Texts.Kanban -Pattern 'Active branch:\s+`release/r10-real-external-runner-proof-foundation`' -Message "KANBAN must record the active R10 release branch."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'one active branch: `release/r10-real-external-runner-proof-foundation`' -Message "R10 authority must record the active R10 release branch."

    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'R10-002 hardens the closeout-use validator' -Message "R10 authority must record the R10-002 validator hardening."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'R10-003 defines the external proof artifact bundle format' -Message "R10 authority must record the R10-003 bundle format."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'R10-004 wires one external runner path' -Message "R10 authority must record the R10-004 runner path wiring."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'Workflow existence is not proof of a successful run' -Message "R10 authority must keep workflow existence from being treated as successful external proof."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'R10-005 captured real run ID `25033063285`' -Message "R10 authority must record the R10-005 real run id."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'https://github\.com/RodneyMuniz/AIOffice_V2/actions/runs/25033063285' -Message "R10 authority must record the R10-005 real run URL."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'r10-external-proof-bundle-25033063285-1' -Message "R10 authority must record the R10-005 artifact name."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'https://api\.github\.com/repos/RodneyMuniz/AIOffice_V2/actions/artifacts/6675983991/zip' -Message "R10 authority must record the R10-005 artifact retrieval instruction."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'Run `25033063285` completed with conclusion `failure`; it is a real external runner identity capture, but successful external proof was not established by that run' -Message "R10 authority must distinguish the failed identity capture from successful external proof."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'R10-005G captured successful external proof run ID `25040949422`' -Message "R10 authority must record the R10-005G successful run id."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'https://github\.com/RodneyMuniz/AIOffice_V2/actions/runs/25040949422' -Message "R10 authority must record the R10-005G real run URL."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'r10-external-proof-bundle-25040949422-1' -Message "R10 authority must record the R10-005G artifact name."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'https://api\.github\.com/repos/RodneyMuniz/AIOffice_V2/actions/artifacts/6679018430/zip' -Message "R10 authority must record the R10-005G artifact retrieval instruction."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'Run `25040949422` completed with status `completed` and conclusion `success`; this is one bounded external runner proof run only' -Message "R10 authority must distinguish the successful external proof run from broader R10 proof."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'R10-005G has produced one successful external proof artifact bundle for the tested R10 release branch head' -Message "R10 authority must record the bounded successful external proof bundle."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'R10-006 adds external-runner-consuming QA signoff based on successful R10-005G evidence' -Message "R10 authority must record the R10-006 external-runner-consuming QA signoff."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'state/external_runs/r10_external_proof_bundle/25040949422/qa/external_runner_consuming_qa_signoff\.json' -Message "R10 authority must cite the R10-006 QA signoff packet."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'R10-007 adds the two-phase final-head closeout support procedure' -Message "R10 authority must record the R10-007 two-phase support procedure."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'R10 still has not executed final-head clean replay' -Message "R10 authority must preserve the final-head clean replay non-claim."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'R10 does not prove solved Codex context compaction' -Message "R10 authority must preserve the Codex compaction non-claim."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'R10 does not prove unattended automatic resume' -Message "R10 authority must preserve the unattended automatic resume non-claim."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'R10 does not prove hours-long unattended milestone execution' -Message "R10 authority must preserve the hours-long unattended milestone non-claim."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'R10 does not prove broad autonomous milestone execution' -Message "R10 authority must preserve the broad-autonomy non-claim."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'Limitation-only external-runner evidence is insufficient for R10 closeout' -Message "R10 authority must reject limitation-only external-runner closeout."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'contracts/external_runner_artifact/external_runner_closeout_identity\.contract\.json' -Message "R10 authority must cite the R10-002 closeout identity contract."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'tools/validate_external_runner_closeout_identity\.ps1' -Message "R10 authority must cite the R10-002 closeout identity CLI validator."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'state/fixtures/valid/external_runner_artifact/r10_closeout_identity\.valid\.json' -Message "R10 authority must cite the R10-002 validator-only fixture."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'tests/test_external_runner_closeout_identity\.ps1' -Message "R10 authority must cite the R10-002 focused test."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'R10-002`\s+includes a validator-only fixture for contract shape testing\.\s+That fixture is not a real external runner capture and is not R10 proof' -Message "R10 authority must keep the R10-002 fixture from being treated as real external proof."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'contracts/external_proof_bundle/foundation\.contract\.json' -Message "R10 authority must cite the R10-003 external proof bundle foundation contract."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'contracts/external_proof_bundle/external_proof_artifact_bundle\.contract\.json' -Message "R10 authority must cite the R10-003 external proof artifact bundle contract."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'tools/ExternalProofArtifactBundle\.psm1' -Message "R10 authority must cite the R10-003 external proof artifact bundle validator module."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'tools/validate_external_proof_artifact_bundle\.ps1' -Message "R10 authority must cite the R10-003 external proof artifact bundle CLI validator."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'state/fixtures/valid/external_proof_bundle/external_proof_artifact_bundle\.valid\.json' -Message "R10 authority must cite the R10-003 validator-only fixture."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'tests/test_external_proof_artifact_bundle\.ps1' -Message "R10 authority must cite the R10-003 focused test."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'validator-only fixture is not a real external runner capture, not CI proof, not external QA proof, and not R10 closeout proof' -Message "R10 authority must keep the R10-003 fixture from being treated as real external proof."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern '\.github/workflows/r10-external-proof-bundle\.yml' -Message "R10 authority must cite the R10-004 workflow."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'tools/invoke_r10_external_proof_bundle\.ps1' -Message "R10 authority must cite the R10-004 runner script."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'tests/test_r10_external_proof_workflow\.ps1' -Message "R10 authority must cite the R10-004 focused workflow test."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'contracts/isolated_qa/external_runner_consuming_qa_signoff\.contract\.json' -Message "R10 authority must cite the R10-006 QA signoff contract."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'tools/ExternalRunnerConsumingQaSignoff\.psm1' -Message "R10 authority must cite the R10-006 QA signoff validator module."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'tools/validate_external_runner_consuming_qa_signoff\.ps1' -Message "R10 authority must cite the R10-006 QA signoff CLI validator."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'tests/test_external_runner_consuming_qa_signoff\.ps1' -Message "R10 authority must cite the R10-006 focused test."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'governance/R10_TWO_PHASE_FINAL_HEAD_CLOSEOUT_SUPPORT_PROCEDURE\.md' -Message "R10 authority must cite the R10-007 procedure document."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'contracts/post_push_support/r10_two_phase_final_head_closeout_procedure\.contract\.json' -Message "R10 authority must cite the R10-007 procedure contract."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'tools/R10TwoPhaseFinalHeadSupport\.psm1' -Message "R10 authority must cite the R10-007 validator module."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'tools/validate_r10_two_phase_final_head_support\.ps1' -Message "R10 authority must cite the R10-007 CLI validator."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'state/fixtures/valid/post_push_support/r10_two_phase_final_head_closeout_procedure\.valid\.json' -Message "R10 authority must cite the R10-007 valid fixture."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'tests/test_r10_two_phase_final_head_support\.ps1' -Message "R10 authority must cite the R10-007 focused test."
    Assert-R10NonClaimsPreserved -Text $Texts.R10Authority -Context "R10 authority"

    if (-not $Texts.Contains("BranchingConvention")) {
        throw "Branching convention document must exist when R10 is open."
    }

    Assert-RegexMatch -Text $Texts.BranchingConvention -Pattern 'From R10 onward, each release or milestone gets a dedicated release branch' -Message "Branching convention must record the R10+ release branch rule."
    Assert-RegexMatch -Text $Texts.BranchingConvention -Pattern 'Pattern: `release/r<release-number>-<short-kebab-milestone-name>`' -Message "Branching convention must record the release branch pattern."
    Assert-RegexMatch -Text $Texts.BranchingConvention -Pattern 'R10 branch: `release/r10-real-external-runner-proof-foundation`' -Message "Branching convention must record the R10 branch."
    Assert-RegexMatch -Text $Texts.BranchingConvention -Pattern 'feature/r5-closeout-remaining-foundations`\s+remains the historical R9 closed/support line' -Message "Branching convention must preserve the old feature branch as historical R9 support only."
    Assert-RegexMatch -Text $Texts.BranchingConvention -Pattern 'Reports remain narrative operator artifacts, not proof' -Message "Branching convention must preserve report non-proof status."
    Assert-RegexMatch -Text $Texts.BranchingConvention -Pattern 'Branch truth must be verified before each milestone slice' -Message "Branching convention must require branch truth checks before each slice."

    if ($combinedText -match 'R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`\s+(?:is now closed in repo truth|is formally closed|is now the most recently closed milestone)') {
        throw "Status docs must not claim R10 closeout while only R10-007 is complete."
    }

    if ($combinedText -match '`R10-008`\s+is\s+complete') {
        throw "Status docs must not claim R10-008 complete while only R10-007 is complete."
    }

    return $kanbanSnapshot
}

function Test-R10ClosedStatus {
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$Texts,
        [bool]$AllowR11Active = $false,
        [bool]$AllowR11Closed = $false,
        [bool]$AllowR12Active = $false
    )

    if (-not $Texts.Contains("R10Authority")) {
        throw "R10 authority document must exist when R10 is closed."
    }

    $kanbanTaskStatuses = Get-R10TaskStatusMap -Text $Texts.Kanban -Context "KANBAN"
    $authorityTaskStatuses = Get-R10TaskStatusMap -Text $Texts.R10Authority -Context "R10 authority"

    foreach ($taskId in $kanbanTaskStatuses.Keys) {
        if ($authorityTaskStatuses[$taskId] -ne $kanbanTaskStatuses[$taskId]) {
            throw "R10 authority does not match KANBAN for status '$taskId'."
        }
    }

    $kanbanSnapshot = Get-ContiguousDoneThroughFromStatusMap -StatusMap $kanbanTaskStatuses -Context "KANBAN" -TaskPrefix "R10" -TaskCount 8
    $authoritySnapshot = Get-ContiguousDoneThroughFromStatusMap -StatusMap $authorityTaskStatuses -Context "R10 authority" -TaskPrefix "R10" -TaskCount 8

    if ($authoritySnapshot.DoneThrough -ne $kanbanSnapshot.DoneThrough -or $authoritySnapshot.PlannedStart -ne $kanbanSnapshot.PlannedStart -or $authoritySnapshot.PlannedThrough -ne $kanbanSnapshot.PlannedThrough) {
        throw "R10 authority does not match KANBAN for the live R10 task status boundary."
    }

    if ($kanbanSnapshot.DoneThrough -ne 8 -or $kanbanSnapshot.PlannedStart -ne $null -or $kanbanSnapshot.PlannedThrough -ne $null) {
        throw "R10 closed status must keep R10-001 through R10-008 done with no planned R10 tasks."
    }

    $combinedText = [string]::Join([Environment]::NewLine, @($Texts.Values))
    $supportPacketPath = "state/proof_reviews/r10_real_external_runner_artifact_identity_and_final_head_clean_replay_foundation/final_head_support/final_remote_head_support_packet.json"
    $phase1PackagePath = "state/proof_reviews/r10_real_external_runner_artifact_identity_and_final_head_clean_replay_foundation/"
    $candidateCommit = "cfebd351922b192585ed5f9d3ca56bee30ea16ae"

    Assert-RegexMatch -Text $Texts.Readme -Pattern 'R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`\s+is now closed in repo truth' -Message "README must declare R10 closed in repo truth after Phase 2 support."
    if ($AllowR12Active) {
        Assert-RegexMatch -Text $Texts.ActiveState -Pattern '## Active Milestone\s+`R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`\s+is now active in repo truth through `R12-016` only\.' -Message "ACTIVE_STATE must declare R12 as active through R12-016 only."
        Assert-RegexMatch -Text $Texts.Kanban -Pattern '## Active Milestone\s+`R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`' -Message "KANBAN must declare R12 as the active milestone after R12 opening."
    }
    elseif ($AllowR11Active) {
        Assert-RegexMatch -Text $Texts.ActiveState -Pattern '## Active Milestone\s+`R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot`\s+is now active in repo truth through `R11-008` only\.' -Message "ACTIVE_STATE must declare R11 as active through R11-008 only."
        Assert-RegexMatch -Text $Texts.Kanban -Pattern '## Active Milestone\s+`R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot`' -Message "KANBAN must declare R11 as the active milestone after R11 opening."
    }
    elseif ($AllowR11Closed) {
        Assert-RegexMatch -Text $Texts.ActiveState -Pattern '## Active Milestone\s+No active implementation milestone is open after R11 closeout\.' -Message "ACTIVE_STATE must not open a successor milestone after R11 closeout."
        Assert-RegexMatch -Text $Texts.Kanban -Pattern '## Active Milestone\s+No active implementation milestone is open after R11 closeout\.' -Message "KANBAN must not open a successor milestone after R11 closeout."
    }
    else {
        Assert-RegexMatch -Text $Texts.ActiveState -Pattern '## Active Milestone\s+No active implementation milestone is open after R10 closeout\.' -Message "ACTIVE_STATE must not open a successor milestone after R10 closeout."
        Assert-RegexMatch -Text $Texts.Kanban -Pattern '## Active Milestone\s+No active implementation milestone is open after R10 closeout\.' -Message "KANBAN must not open a successor milestone after R10 closeout."
    }
    if (-not $AllowR11Closed) {
        Assert-RegexMatch -Text $Texts.Kanban -Pattern '## Most Recently Closed Milestone\s+`R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`' -Message "KANBAN must mark R10 as the most recently closed milestone."
    }
    Assert-RegexMatch -Text $Texts.DecisionLog -Pattern 'R10-008 Added Final-Head Support And Closed R10 Narrowly' -Message "DECISION_LOG must record the R10-008 Phase 2 closeout decision."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`\s+is now closed in repo truth' -Message "R10 authority must declare R10 closed in repo truth."

    foreach ($entry in @(
            @{ Text = $Texts.Readme; Context = "README" },
            @{ Text = $Texts.ActiveState; Context = "ACTIVE_STATE" },
            @{ Text = $Texts.Kanban; Context = "KANBAN" },
            @{ Text = $Texts.R10Authority; Context = "R10 authority" }
        )) {
        Assert-RegexMatch -Text $entry.Text -Pattern ([regex]::Escape($supportPacketPath)) -Message "$($entry.Context) must cite the R10 Phase 2 final-head support packet."
        Assert-RegexMatch -Text $entry.Text -Pattern ([regex]::Escape($candidateCommit)) -Message "$($entry.Context) must cite the R10 candidate closeout commit SHA."
    }

    Assert-RegexMatch -Text $combinedText -Pattern ([regex]::Escape($phase1PackagePath)) -Message "Status docs must cite the R10 Phase 1 candidate closeout package."
    Assert-RegexMatch -Text $combinedText -Pattern 'one successful bounded external runner proof run exists from R10-005G' -Message "Status docs must keep the narrow R10 external runner proof claim."
    Assert-RegexMatch -Text $combinedText -Pattern 'one external-runner-consuming QA signoff exists from R10-006' -Message "Status docs must keep the narrow R10 QA signoff claim."
    Assert-RegexMatch -Text $combinedText -Pattern 'one two-phase final-head support procedure exists from R10-007' -Message "Status docs must keep the narrow R10 two-phase procedure claim."
    Assert-RegexMatch -Text $combinedText -Pattern 'one Phase 1 candidate closeout package exists from R10-008' -Message "Status docs must keep the R10 Phase 1 candidate package claim."
    Assert-RegexMatch -Text $combinedText -Pattern 'one Phase 2 post-push final-head support packet exists after the candidate push' -Message "Status docs must keep the R10 Phase 2 support packet claim."
    if (-not $AllowR11Active -and -not $AllowR11Closed) {
        Assert-RegexMatch -Text $combinedText -Pattern 'no successor milestone (?:is )?opened' -Message "Status docs must preserve that no successor milestone opened."
    }

    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'one active branch: `release/r10-real-external-runner-proof-foundation`' -Message "R10 authority must record the active R10 release branch."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'R10-002 hardens the closeout-use validator' -Message "R10 authority must record the R10-002 validator hardening."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'R10-003 defines the external proof artifact bundle format' -Message "R10 authority must record the R10-003 bundle format."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'R10-004 wires one external runner path' -Message "R10 authority must record the R10-004 runner path wiring."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'Workflow existence is not proof of a successful run' -Message "R10 authority must keep Workflow existence from being treated as successful external proof."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'Run `25033063285` completed with conclusion `failure`; it is a real external runner identity capture, but successful external proof was not established by that run' -Message "R10 authority must distinguish the failed identity capture from successful external proof."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'Limitation-only external-runner evidence is insufficient for R10 closeout' -Message "R10 authority must reject limitation-only external-runner closeout."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'contracts/external_runner_artifact/external_runner_closeout_identity\.contract\.json' -Message "R10 authority must cite the R10-002 closeout identity contract."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'tools/validate_external_runner_closeout_identity\.ps1' -Message "R10 authority must cite the R10-002 closeout identity CLI validator."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'state/fixtures/valid/external_runner_artifact/r10_closeout_identity\.valid\.json' -Message "R10 authority must cite the R10-002 validator-only fixture."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'tests/test_external_runner_closeout_identity\.ps1' -Message "R10 authority must cite the R10-002 focused test."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'R10-002`\s+includes a validator-only fixture for contract shape testing\.\s+That fixture is not a real external runner capture and is not R10 proof' -Message "R10 authority must keep the R10-002 fixture from being treated as real external proof."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'contracts/external_proof_bundle/foundation\.contract\.json' -Message "R10 authority must cite the R10-003 external proof bundle foundation contract."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'contracts/external_proof_bundle/external_proof_artifact_bundle\.contract\.json' -Message "R10 authority must cite the R10-003 external proof artifact bundle contract."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'tools/ExternalProofArtifactBundle\.psm1' -Message "R10 authority must cite the R10-003 external proof artifact bundle validator module."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'tools/validate_external_proof_artifact_bundle\.ps1' -Message "R10 authority must cite the R10-003 external proof artifact bundle CLI validator."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'state/fixtures/valid/external_proof_bundle/external_proof_artifact_bundle\.valid\.json' -Message "R10 authority must cite the R10-003 validator-only fixture."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'tests/test_external_proof_artifact_bundle\.ps1' -Message "R10 authority must cite the R10-003 focused test."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'validator-only fixture is not a real external runner capture, not CI proof, not external QA proof, and not R10 closeout proof' -Message "R10 authority must keep the R10-003 fixture from being treated as real external proof."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern '\.github/workflows/r10-external-proof-bundle\.yml' -Message "R10 authority must cite the R10-004 workflow."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'tools/invoke_r10_external_proof_bundle\.ps1' -Message "R10 authority must cite the R10-004 runner script."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'tests/test_r10_external_proof_workflow\.ps1' -Message "R10 authority must cite the R10-004 focused workflow test."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'contracts/isolated_qa/external_runner_consuming_qa_signoff\.contract\.json' -Message "R10 authority must cite the R10-006 QA signoff contract."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'tools/ExternalRunnerConsumingQaSignoff\.psm1' -Message "R10 authority must cite the R10-006 QA signoff validator module."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'tools/validate_external_runner_consuming_qa_signoff\.ps1' -Message "R10 authority must cite the R10-006 QA signoff CLI validator."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'tests/test_external_runner_consuming_qa_signoff\.ps1' -Message "R10 authority must cite the R10-006 focused test."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'state/external_runs/r10_external_proof_bundle/25040949422/qa/external_runner_consuming_qa_signoff\.json' -Message "R10 authority must cite the R10-006 QA signoff packet."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'governance/R10_TWO_PHASE_FINAL_HEAD_CLOSEOUT_SUPPORT_PROCEDURE\.md' -Message "R10 authority must cite the R10-007 procedure document."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'contracts/post_push_support/r10_two_phase_final_head_closeout_procedure\.contract\.json' -Message "R10 authority must cite the R10-007 procedure contract."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'tools/R10TwoPhaseFinalHeadSupport\.psm1' -Message "R10 authority must cite the R10-007 validator module."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'tools/validate_r10_two_phase_final_head_support\.ps1' -Message "R10 authority must cite the R10-007 CLI validator."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'state/fixtures/valid/post_push_support/r10_two_phase_final_head_closeout_procedure\.valid\.json' -Message "R10 authority must cite the R10-007 valid fixture."
    Assert-RegexMatch -Text $Texts.R10Authority -Pattern 'tests/test_r10_two_phase_final_head_support\.ps1' -Message "R10 authority must cite the R10-007 focused test."

    if (-not $Texts.Contains("BranchingConvention")) {
        throw "Branching convention document must exist when R10 is closed."
    }

    Assert-RegexMatch -Text $Texts.BranchingConvention -Pattern 'R10 branch: `release/r10-real-external-runner-proof-foundation`' -Message "Branching convention must record the R10 branch."

    Assert-R10NonClaimsPreserved -Text $Texts.R10Authority -Context "R10 authority"

    if (-not $AllowR11Active -and -not $AllowR11Closed -and $combinedText -match '(?i)R11.*is now active') {
        throw "Status docs must not open a successor milestone after R10 closeout."
    }

    return $kanbanSnapshot
}

function Test-R11OpeningStatus {
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$Texts,
        [bool]$Closed = $false,
        [bool]$AllowR12Active = $false
    )

    if (-not $Texts.Contains("R11Authority")) {
        throw "R11 authority document must exist when R11 is open or closed."
    }

    $kanbanTaskStatuses = Get-R11TaskStatusMap -Text $Texts.Kanban -Context "KANBAN"
    $authorityTaskStatuses = Get-R11TaskStatusMap -Text $Texts.R11Authority -Context "R11 authority"

    foreach ($taskId in $kanbanTaskStatuses.Keys) {
        if ($authorityTaskStatuses[$taskId] -ne $kanbanTaskStatuses[$taskId]) {
            throw "R11 authority does not match KANBAN for status '$taskId'."
        }
    }

    $kanbanSnapshot = Get-ContiguousDoneThroughFromStatusMap -StatusMap $kanbanTaskStatuses -Context "KANBAN" -TaskPrefix "R11" -TaskCount 9
    $authoritySnapshot = Get-ContiguousDoneThroughFromStatusMap -StatusMap $authorityTaskStatuses -Context "R11 authority" -TaskPrefix "R11" -TaskCount 9

    if ($authoritySnapshot.DoneThrough -ne $kanbanSnapshot.DoneThrough -or $authoritySnapshot.PlannedStart -ne $kanbanSnapshot.PlannedStart -or $authoritySnapshot.PlannedThrough -ne $kanbanSnapshot.PlannedThrough) {
        throw "R11 authority does not match KANBAN for the live R11 task status boundary."
    }

    if ($Closed -and $AllowR12Active) {
        Assert-RegexMatch -Text $Texts.Readme -Pattern 'R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`\s+is now the active milestone in repo truth through `R12-016` only' -Message "README must declare R12 active through R12-016 only."
        Assert-RegexMatch -Text $Texts.ActiveState -Pattern '## Active Milestone\s+`R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`\s+is now active in repo truth through `R12-016` only\.' -Message "ACTIVE_STATE must declare R12 active through R12-016 only."
        Assert-RegexMatch -Text $Texts.Kanban -Pattern '## Active Milestone\s+`R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`' -Message "KANBAN must declare R12 as the active milestone."
        Assert-RegexMatch -Text $Texts.Kanban -Pattern '## Most Recently Closed Milestone\s+`R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot`' -Message "KANBAN must keep R11 as the most recently closed milestone while R12 is open."
    }
    elseif ($Closed) {
        if ($kanbanSnapshot.DoneThrough -ne 9 -or $kanbanSnapshot.PlannedStart -ne $null -or $kanbanSnapshot.PlannedThrough -ne $null) {
            throw "R11 closed status must keep R11-001 through R11-009 done with no planned R11 tasks."
        }
    }
    elseif ($kanbanSnapshot.DoneThrough -ne 8 -or $kanbanSnapshot.PlannedStart -ne 9 -or $kanbanSnapshot.PlannedThrough -ne 9) {
        throw "R11 open status must keep only R11-001 through R11-008 done and R11-009 planned."
    }

    $combinedText = [string]::Join([Environment]::NewLine, @($Texts.Values))
    $currentStatusText = [string]::Join([Environment]::NewLine, @(
            $Texts.Readme,
            $Texts.ActiveState,
            $Texts.Kanban
        ))
    $r10SupportPacketPath = "state/proof_reviews/r10_real_external_runner_artifact_identity_and_final_head_clean_replay_foundation/final_head_support/final_remote_head_support_packet.json"
    $r10FinalSupportHead = "91035cfbb34f531684943d0bfd8c3ba660f48f08"
    $r10CandidateCommit = "cfebd351922b192585ed5f9d3ca56bee30ea16ae"
    $r11AuthorityPath = "governance/R11_CONTROLLED_EXTERNAL_CYCLE_CONTROLLER_AND_REPO_TRUTH_RESUME_PILOT.md"
    $r10R11ReportPath = "governance/reports/AIOffice_V2_R10_Audit_and_R11_Planning_Report_v1.md"
    $r11Phase1PackagePath = "state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/"
    $r11FinalSupportPacketPath = "state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot/final_head_support/final_remote_head_support_packet.json"
    $r11CandidateCommit = "545232bfd06df86018917bc677e6ba3374b3b9c4"
    $r11FoundationContractPath = "contracts/cycle_controller/foundation.contract.json"
    $r11CycleLedgerContractPath = "contracts/cycle_controller/cycle_ledger.contract.json"
    $r11ValidLedgerFixturePath = "state/fixtures/valid/cycle_controller/cycle_ledger.valid.json"
    $r11InvalidLedgerFixturePath = "state/fixtures/invalid/cycle_controller/"
    $r11CycleLedgerModulePath = "tools/CycleLedger.psm1"
    $r11CycleLedgerValidatorPath = "tools/validate_cycle_ledger.ps1"
    $r11CycleLedgerTestPath = "tests/test_cycle_ledger.ps1"
    $r11ControllerCommandContractPath = "contracts/cycle_controller/controller_command.contract.json"
    $r11ControllerResultContractPath = "contracts/cycle_controller/controller_result.contract.json"
    $r11ControllerInitializeFixturePath = "state/fixtures/valid/cycle_controller/controller_initialize_command.valid.json"
    $r11ControllerAdvanceFixturePath = "state/fixtures/valid/cycle_controller/controller_advance_command.valid.json"
    $r11ControllerRefuseFixturePath = "state/fixtures/valid/cycle_controller/controller_refuse_command.valid.json"
    $r11ControllerInvalidFixturePath = "state/fixtures/invalid/cycle_controller/"
    $r11ControllerModulePath = "tools/CycleController.psm1"
    $r11ControllerCliPath = "tools/invoke_cycle_controller.ps1"
    $r11ControllerTestPath = "tests/test_cycle_controller.ps1"
    $r11BootstrapPacketContractPath = "contracts/cycle_controller/cycle_bootstrap_packet.contract.json"
    $r11NextActionPacketContractPath = "contracts/cycle_controller/cycle_next_action_packet.contract.json"
    $r11BootstrapPacketFixturePath = "state/fixtures/valid/cycle_controller/cycle_bootstrap_packet.valid.json"
    $r11NextActionPacketFixturePath = "state/fixtures/valid/cycle_controller/cycle_next_action_packet.valid.json"
    $r11BootstrapInvalidFixturePath = "state/fixtures/invalid/cycle_controller/"
    $r11BootstrapModulePath = "tools/CycleBootstrap.psm1"
    $r11BootstrapCliPath = "tools/prepare_cycle_bootstrap.ps1"
    $r11BootstrapTestPath = "tests/test_cycle_bootstrap_resume.ps1"
    $r11ResiduePolicyContractPath = "contracts/cycle_controller/local_residue_policy.contract.json"
    $r11ResidueScanContractPath = "contracts/cycle_controller/local_residue_scan_result.contract.json"
    $r11ResidueQuarantineContractPath = "contracts/cycle_controller/local_residue_quarantine_result.contract.json"
    $r11ResidueCleanFixturePath = "state/fixtures/valid/cycle_controller/local_residue_scan_result.clean.valid.json"
    $r11ResidueDirtyFixturePath = "state/fixtures/valid/cycle_controller/local_residue_scan_result.dirty.valid.json"
    $r11ResidueQuarantineFixturePath = "state/fixtures/valid/cycle_controller/local_residue_quarantine_result.valid.json"
    $r11ResidueInvalidFixturePath = "state/fixtures/invalid/cycle_controller/"
    $r11ResidueModulePath = "tools/LocalResidueGuard.psm1"
    $r11ResidueCliPath = "tools/invoke_local_residue_guard.ps1"
    $r11ResidueTestPath = "tests/test_local_residue_guard.ps1"
    $r11DevDispatchContractPath = "contracts/cycle_controller/dev_dispatch_packet.contract.json"
    $r11DevResultContractPath = "contracts/cycle_controller/dev_execution_result_packet.contract.json"
    $r11DevDispatchFixturePath = "state/fixtures/valid/cycle_controller/dev_dispatch_packet.valid.json"
    $r11DevResultFixturePath = "state/fixtures/valid/cycle_controller/dev_execution_result_packet.valid.json"
    $r11DevInvalidFixturePath = "state/fixtures/invalid/cycle_controller/"
    $r11DevModulePath = "tools/DevExecutionAdapter.psm1"
    $r11DevCliPath = "tools/invoke_dev_execution_adapter.ps1"
    $r11DevTestPath = "tests/test_dev_execution_adapter.ps1"
    $r11QaGateContractPath = "contracts/cycle_controller/cycle_qa_gate.contract.json"
    $r11QaSignoffContractPath = "contracts/cycle_controller/cycle_qa_signoff_packet.contract.json"
    $r11QaSignoffFixturePath = "state/fixtures/valid/cycle_controller/cycle_qa_signoff_packet.valid.json"
    $r11QaInvalidFixturePath = "state/fixtures/invalid/cycle_controller/"
    $r11QaModulePath = "tools/CycleQaGate.psm1"
    $r11QaCliPath = "tools/invoke_cycle_qa_gate.ps1"
    $r11QaTestPath = "tests/test_cycle_qa_gate.ps1"
    $r11AuditContractPath = "contracts/cycle_controller/cycle_audit_packet.contract.json"
    $r11DecisionContractPath = "contracts/cycle_controller/operator_decision_packet.contract.json"
    $r11PilotRootPath = "state/cycles/r11_008_controlled_cycle_pilot/"
    $r11PilotTestPath = "tests/test_r11_controlled_cycle_pilot.ps1"

    if ($Closed -and $AllowR12Active) {
        Assert-RegexMatch -Text $Texts.Readme -Pattern 'R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`\s+is now the active milestone in repo truth through `R12-016` only' -Message "README must declare R12 active through R12-016 only."
        Assert-RegexMatch -Text $Texts.ActiveState -Pattern '## Active Milestone\s+`R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`\s+is now active in repo truth through `R12-016` only\.' -Message "ACTIVE_STATE must declare R12 active through R12-016 only."
        Assert-RegexMatch -Text $Texts.Kanban -Pattern '## Active Milestone\s+`R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`' -Message "KANBAN must declare R12 as the active milestone."
        Assert-RegexMatch -Text $Texts.Kanban -Pattern '## Most Recently Closed Milestone\s+`R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot`' -Message "KANBAN must mark R11 as the most recently closed milestone."
    }
    elseif ($Closed) {
        Assert-RegexMatch -Text $Texts.Readme -Pattern 'R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot`\s+is now closed narrowly in repo truth' -Message "README must declare R11 closed narrowly after Phase 2 support."
        Assert-RegexMatch -Text $Texts.ActiveState -Pattern '## Active Milestone\s+No active implementation milestone is open after R11 closeout\.' -Message "ACTIVE_STATE must not open a successor milestone after R11 closeout."
        Assert-RegexMatch -Text $Texts.Kanban -Pattern '## Active Milestone\s+No active implementation milestone is open after R11 closeout\.' -Message "KANBAN must not open a successor milestone after R11 closeout."
        Assert-RegexMatch -Text $Texts.Kanban -Pattern '## Most Recently Closed Milestone\s+`R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot`' -Message "KANBAN must mark R11 as the most recently closed milestone."
    }
    else {
        Assert-RegexMatch -Text $Texts.Readme -Pattern 'R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot`\s+is now the active milestone in repo truth through `R11-008` only' -Message "README must declare R11 as the active milestone through R11-008 only."
        Assert-RegexMatch -Text $Texts.ActiveState -Pattern '## Active Milestone\s+`R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot`\s+is now active in repo truth through `R11-008` only\.' -Message "ACTIVE_STATE must declare R11 as active through R11-008 only."
        Assert-RegexMatch -Text $Texts.Kanban -Pattern '## Active Milestone\s+`R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot`' -Message "KANBAN must declare R11 as the active milestone."
        Assert-RegexMatch -Text $Texts.Kanban -Pattern '## Most Recently Closed Milestone\s+`R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`' -Message "KANBAN must keep R10 as the most recently closed milestone while R11 is open."
    }
    Assert-RegexMatch -Text $Texts.DecisionLog -Pattern 'R11-001 Opened R11 Controlled Cycle Controller Pilot' -Message "DECISION_LOG must record the R11 opening decision."
    Assert-RegexMatch -Text $Texts.DecisionLog -Pattern 'R11-002 Defined Cycle Ledger State Machine' -Message "DECISION_LOG must record the R11-002 cycle ledger decision."
    Assert-RegexMatch -Text $Texts.DecisionLog -Pattern 'R11-003 Built Thin Cycle Controller CLI' -Message "DECISION_LOG must record the R11-003 cycle controller CLI decision."
    Assert-RegexMatch -Text $Texts.DecisionLog -Pattern 'R11-004 Added Bounded Repo-Truth Bootstrap Resume' -Message "DECISION_LOG must record the R11-004 bootstrap/resume decision."
    Assert-RegexMatch -Text $Texts.DecisionLog -Pattern 'R11-005 Added Local Residue Guard' -Message "DECISION_LOG must record the R11-005 local residue guard decision."
    Assert-RegexMatch -Text $Texts.DecisionLog -Pattern 'R11-006 Added Bounded Dev Execution Adapter' -Message "DECISION_LOG must record the R11-006 bounded Dev adapter decision."
    Assert-RegexMatch -Text $Texts.DecisionLog -Pattern 'R11-007 Added Separate QA Gate' -Message "DECISION_LOG must record the R11-007 separate QA gate decision."
    Assert-RegexMatch -Text $Texts.DecisionLog -Pattern 'R11-008 Ran Bounded Controlled-Cycle Pilot' -Message "DECISION_LOG must record the R11-008 controlled-cycle pilot decision."
    Assert-RegexMatch -Text $Texts.DecisionLog -Pattern 'R11-009 Added Final-Head Support And Closed R11 Narrowly|R11-009 Prepared Candidate Closeout Package' -Message "DECISION_LOG must record R11-009 candidate or final support decisions."
    if ($Closed) {
        Assert-RegexMatch -Text $Texts.R11Authority -Pattern 'R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot`\s+is now closed narrowly in repo truth' -Message "R11 authority must declare R11 closed narrowly."
        Assert-RegexMatch -Text $Texts.R11Authority -Pattern 'R11-001`\s+through\s+`R11-009`\s+are complete' -Message "R11 authority must declare R11-001 through R11-009 complete."
        Assert-RegexMatch -Text $Texts.R11Authority -Pattern 'R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`\s+remains the prior closed milestone' -Message "R11 authority must preserve R10 as the prior closed milestone."
        Assert-RegexMatch -Text $combinedText -Pattern ([regex]::Escape($r11FinalSupportPacketPath)) -Message "Status docs must cite the R11 Phase 2 final-head support packet."
        Assert-RegexMatch -Text $combinedText -Pattern ([regex]::Escape($r11CandidateCommit)) -Message "Status docs must cite the R11 candidate closeout commit SHA."
    }
    else {
        Assert-RegexMatch -Text $Texts.R11Authority -Pattern 'R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot`\s+is now active in repo truth through `R11-008` only' -Message "R11 authority must declare R11 active through R11-008 only."
        Assert-RegexMatch -Text $Texts.R11Authority -Pattern 'R11-009`\s+remains planned only' -Message "R11 authority must keep R11-009 planned only."
        Assert-RegexMatch -Text $Texts.R11Authority -Pattern 'R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`\s+remains the most recently closed prior milestone' -Message "R11 authority must preserve R10 as the most recently closed prior milestone."
    }

    foreach ($entry in @(
            @{ Text = $Texts.Readme; Context = "README" },
            @{ Text = $Texts.ActiveState; Context = "ACTIVE_STATE" },
            @{ Text = $Texts.Kanban; Context = "KANBAN" },
            @{ Text = $Texts.R11Authority; Context = "R11 authority" }
        )) {
        Assert-RegexMatch -Text $entry.Text -Pattern ([regex]::Escape($r10FinalSupportHead)) -Message "$($entry.Context) must cite the R10 closeout head required before R11 opens."
    }

    Assert-RegexMatch -Text $combinedText -Pattern ([regex]::Escape($r10SupportPacketPath)) -Message "Status docs must cite the R10 Phase 2 final-head support packet before R11 opens."
    Assert-RegexMatch -Text $combinedText -Pattern ([regex]::Escape($r10CandidateCommit)) -Message "Status docs must cite the R10 candidate closeout commit before R11 opens."
    Assert-RegexMatch -Text $combinedText -Pattern ([regex]::Escape($r11AuthorityPath)) -Message "Status docs must cite the R11 authority document."
    Assert-RegexMatch -Text $combinedText -Pattern ([regex]::Escape($r10R11ReportPath)) -Message "Status docs must cite the R10-to-R11 operator report artifact."
    Assert-RegexMatch -Text $combinedText -Pattern ([regex]::Escape($r11Phase1PackagePath)) -Message "Status docs must cite the R11-009 Phase 1 candidate closeout package."
    foreach ($requiredR11Ref in @(
            $r11FoundationContractPath,
            $r11CycleLedgerContractPath,
            $r11ValidLedgerFixturePath,
            $r11InvalidLedgerFixturePath,
            $r11CycleLedgerModulePath,
            $r11CycleLedgerValidatorPath,
            $r11CycleLedgerTestPath
        )) {
        Assert-RegexMatch -Text $combinedText -Pattern ([regex]::Escape($requiredR11Ref)) -Message "Status docs must cite the R11-002 ledger artifact '$requiredR11Ref'."
        Assert-RegexMatch -Text $Texts.R11Authority -Pattern ([regex]::Escape($requiredR11Ref)) -Message "R11 authority must cite the R11-002 ledger artifact '$requiredR11Ref'."
    }
    Assert-RegexMatch -Text $Texts.R11Authority -Pattern 'narrative operator artifact only' -Message "R11 authority must state that the R10-to-R11 report is narrative only."
    Assert-RegexMatch -Text $Texts.R11Authority -Pattern 'not milestone proof by itself' -Message "R11 authority must state that the R10-to-R11 report is not proof by itself."
    Assert-RegexMatch -Text $combinedText -Pattern 'R11-002.{0,160}cycle ledger/state machine' -Message "Status docs must describe R11-002 as the cycle ledger/state machine definition slice."
    Assert-RegexMatch -Text $combinedText -Pattern 'R11-003.{0,180}(thin cycle controller CLI|cycle controller CLI)' -Message "Status docs must describe R11-003 as the thin cycle controller CLI slice."
    Assert-RegexMatch -Text $combinedText -Pattern 'R11-004.{0,220}(bounded bootstrap/resume-from-repo-truth|bootstrap/resume-from-repo-truth|repo-truth packet)' -Message "Status docs must describe R11-004 as the bounded bootstrap/resume-from-repo-truth slice."
    Assert-RegexMatch -Text $combinedText -Pattern 'R11-005.{0,240}(local-only residue|local residue).{0,160}(detection|dry-run|quarantine|refusal|guard)' -Message "Status docs must describe R11-005 as the local-only residue detection/quarantine/refusal guard slice."
    foreach ($requiredR11ControllerRef in @(
            $r11ControllerCommandContractPath,
            $r11ControllerResultContractPath,
            $r11ControllerInitializeFixturePath,
            $r11ControllerAdvanceFixturePath,
            $r11ControllerRefuseFixturePath,
            $r11ControllerInvalidFixturePath,
            $r11ControllerModulePath,
            $r11ControllerCliPath,
            $r11ControllerTestPath
        )) {
        Assert-RegexMatch -Text $combinedText -Pattern ([regex]::Escape($requiredR11ControllerRef)) -Message "Status docs must cite the R11-003 controller artifact '$requiredR11ControllerRef'."
        Assert-RegexMatch -Text $Texts.R11Authority -Pattern ([regex]::Escape($requiredR11ControllerRef)) -Message "R11 authority must cite the R11-003 controller artifact '$requiredR11ControllerRef'."
    }
    foreach ($requiredR11BootstrapRef in @(
            $r11BootstrapPacketContractPath,
            $r11NextActionPacketContractPath,
            $r11BootstrapPacketFixturePath,
            $r11NextActionPacketFixturePath,
            $r11BootstrapInvalidFixturePath,
            $r11BootstrapModulePath,
            $r11BootstrapCliPath,
            $r11BootstrapTestPath
        )) {
        Assert-RegexMatch -Text $combinedText -Pattern ([regex]::Escape($requiredR11BootstrapRef)) -Message "Status docs must cite the R11-004 bootstrap artifact '$requiredR11BootstrapRef'."
        Assert-RegexMatch -Text $Texts.R11Authority -Pattern ([regex]::Escape($requiredR11BootstrapRef)) -Message "R11 authority must cite the R11-004 bootstrap artifact '$requiredR11BootstrapRef'."
    }
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)R11-004.{0,240}(committed|valid).{0,120}cycle ledger' -Message "Status docs must tie R11-004 bootstrap to committed ledger truth."
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)R11-004.{0,260}(allowed_next_states|allowed next states|ledger allowed next states)' -Message "Status docs must tie R11-004 next action to ledger allowed next states."
    foreach ($requiredR11ResidueRef in @(
            $r11ResiduePolicyContractPath,
            $r11ResidueScanContractPath,
            $r11ResidueQuarantineContractPath,
            $r11ResidueCleanFixturePath,
            $r11ResidueDirtyFixturePath,
            $r11ResidueQuarantineFixturePath,
            $r11ResidueInvalidFixturePath,
            $r11ResidueModulePath,
            $r11ResidueCliPath,
            $r11ResidueTestPath
        )) {
        Assert-RegexMatch -Text $combinedText -Pattern ([regex]::Escape($requiredR11ResidueRef)) -Message "Status docs must cite the R11-005 local residue artifact '$requiredR11ResidueRef'."
        Assert-RegexMatch -Text $Texts.R11Authority -Pattern ([regex]::Escape($requiredR11ResidueRef)) -Message "R11 authority must cite the R11-005 local residue artifact '$requiredR11ResidueRef'."
    }
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)R11-005.{0,900}(git status --short --untracked-files=all|dry-run evidence|dry-run quarantine)' -Message "Status docs must tie R11-005 residue handling to git-status scan and dry-run evidence."
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)R11-005.{0,900}(no local-only residue used as evidence|not evidence|not repo truth)' -Message "Status docs must preserve that R11-005 does not use local-only residue as evidence."
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)R11-005.{0,900}(no deletion without dry-run and explicit authorization|must not delete)' -Message "Status docs must preserve R11-005 no-deletion without dry-run and authorization."
    foreach ($requiredR11DevRef in @(
            $r11DevDispatchContractPath,
            $r11DevResultContractPath,
            $r11DevDispatchFixturePath,
            $r11DevResultFixturePath,
            $r11DevInvalidFixturePath,
            $r11DevModulePath,
            $r11DevCliPath,
            $r11DevTestPath
        )) {
        Assert-RegexMatch -Text $combinedText -Pattern ([regex]::Escape($requiredR11DevRef)) -Message "Status docs must cite the R11-006 bounded Dev adapter artifact '$requiredR11DevRef'."
        Assert-RegexMatch -Text $Texts.R11Authority -Pattern ([regex]::Escape($requiredR11DevRef)) -Message "R11 authority must cite the R11-006 bounded Dev adapter artifact '$requiredR11DevRef'."
    }
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)R11-006.{0,260}(bounded Dev execution adapter|bounded Dev dispatch/result|bounded implementation dispatch/result).{0,220}(dispatch/result packets|task packets|result packets)' -Message "Status docs must describe R11-006 as bounded Dev dispatch/result packet adapter tooling."
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)R11-006.{0,260}(at least two bounded task packet|two bounded task)' -Message "Status docs must preserve that R11-006 represents at least two bounded task packets."
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)R11-006.{0,260}(source evidence|not QA authority|no QA authority|not a QA verdict|no QA verdict)' -Message "Status docs must preserve that R11-006 result packets are source evidence only, not QA authority."
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)R11-006.{0,260}(does not run a real implementation task|does not execute a real implementation task|no real implementation task|fixture-only)' -Message "Status docs must preserve that R11-006 does not run a real implementation task."
    foreach ($requiredR11QaRef in @(
            $r11QaGateContractPath,
            $r11QaSignoffContractPath,
            $r11QaSignoffFixturePath,
            $r11QaInvalidFixturePath,
            $r11QaModulePath,
            $r11QaCliPath,
            $r11QaTestPath,
            $r11AuditContractPath,
            $r11DecisionContractPath,
            $r11PilotRootPath,
            $r11PilotTestPath
        )) {
        Assert-RegexMatch -Text $combinedText -Pattern ([regex]::Escape($requiredR11QaRef)) -Message "Status docs must cite the R11 artifact '$requiredR11QaRef'."
        Assert-RegexMatch -Text $Texts.R11Authority -Pattern ([regex]::Escape($requiredR11QaRef)) -Message "R11 authority must cite the R11 artifact '$requiredR11QaRef'."
    }
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)R11-007.{0,320}(separate QA gate|QA gate contracts|QA signoff packet).{0,260}(bounded Dev evidence|Dev evidence|Dev dispatch/result)' -Message "Status docs must describe R11-007 as separate QA gate contracts/tooling over bounded Dev evidence."
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)R11-007.{0,360}(consume|consumes).{0,160}(Dev evidence refs|source evidence refs)' -Message "Status docs must state that R11-007 consumes Dev evidence refs."
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)R11-007.{0,420}(executor self-certification|Dev-result QA authority|QA verdict)' -Message "Status docs must state that R11-007 rejects executor self-certification and Dev-result QA authority/verdict claims."
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)R11-007.{0,420}(separate QA actor|distinct QA actor|explicit non-self-certification|independence boundary)' -Message "Status docs must state that R11-007 requires separate QA actor or explicit independence boundary."
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)R11-008.{0,420}(bounded controlled-cycle pilot|controlled-cycle pilot).{0,420}(state/cycles/r11_008_controlled_cycle_pilot|cycle_audit_packet|operator_decision_packet)' -Message "Status docs must describe R11-008 as one bounded controlled-cycle pilot with audit and decision evidence."
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)R11-008.{0,420}(operator_intervention_count|operator intervention count).{0,160}(2|<= 2)' -Message "Status docs must record the R11-008 operator intervention count."
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)R11-008.{0,420}(manual_bootstrap_count|manual bootstrap count).{0,160}0' -Message "Status docs must record the R11-008 manual bootstrap count."
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)(no|does not|does not yet have|does not build|does not claim|not implemented).{0,160}QA gate execution' -Message "Status docs must preserve that no QA gate execution exists by R11-006."
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)(no|does not|does not yet have|does not build|does not claim|does not execute|has not run).{0,160}complete controlled cycle' -Message "Status docs must preserve that no complete controlled cycle has run by R11-006."
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)(no|does not|does not claim|not implemented).{0,220}unattended automatic resume' -Message "Status docs must preserve that R11-006 does not claim unattended automatic resume."
    if ($Closed) {
        Assert-RegexMatch -Text $combinedText -Pattern '(?i)R11 closeout.{0,260}(bounded controlled-cycle pilot|R11-008 cycle evidence).{0,260}(R11-009 candidate closeout package|R11-009 post-push final-head support packet)' -Message "Status docs must limit R11 closeout to the bounded pilot, candidate package, and final-head support packet."
    }
    else {
        Assert-RegexMatch -Text $combinedText -Pattern '(?i)(no|does not|does not yet have|does not build|does not claim|does not close).{0,160}R11 closeout' -Message "Status docs must preserve that R11 has not closed."
    }
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)(no|does not|does not claim|not implemented).{0,220}(real production QA|QA over a complete controlled cycle|QA has run over a complete controlled cycle|QA has run a full controlled cycle)' -Message "Status docs must preserve that R11-007 does not claim production QA or QA over a complete controlled cycle."

    Assert-RegexMatch -Text $Texts.R11Authority -Pattern 'not another proof-documentation milestone' -Message "R11 authority must reject another proof-documentation milestone."
    Assert-RegexMatch -Text $Texts.R11Authority -Pattern 'not another proof-paperwork milestone' -Message "R11 authority must reject another proof-paperwork milestone."
    Assert-RegexMatch -Text $Texts.R11Authority -Pattern 'operator intervention count per cycle decreases' -Message "R11 authority must include operator intervention reduction as a success metric."
    Assert-RegexMatch -Text $Texts.R11Authority -Pattern 'manual bootstrap count decreases to zero' -Message "R11 authority must include manual bootstrap reduction as a success metric."
    Assert-RegexMatch -Text $Texts.R11Authority -Pattern 'at least two bounded tasks run inside one controlled cycle' -Message "R11 authority must require at least two bounded tasks in one cycle."
    Assert-RegexMatch -Text $Texts.R11Authority -Pattern 'state authority is repo-truth ledger/controller, not chat memory' -Message "R11 authority must make repo-truth ledger/controller the state authority."
    Assert-RegexMatch -Text $Texts.R11Authority -Pattern 'failed or interrupted executor session can be resumed from repo state' -Message "R11 authority must require bounded resume from repo state."
    Assert-RegexMatch -Text $Texts.R11Authority -Pattern 'local-only residue is detected, quarantined, or refused automatically' -Message "R11 authority must require local-only residue handling."
    Assert-RegexMatch -Text $Texts.R11Authority -Pattern 'QA is separate from executor evidence' -Message "R11 authority must require separate QA from executor evidence."
    Assert-RegexMatch -Text $Texts.R11Authority -Pattern 'final audit packet is generated from ledger/evidence refs' -Message "R11 authority must require final audit packet generation from ledger/evidence refs."
    Assert-RegexMatch -Text $Texts.R11Authority -Pattern 'user intervention is limited to planned approval and final decision points' -Message "R11 authority must limit user intervention to planned approval/final decision points."

    Assert-R11NonClaimsPreserved -Text $Texts.R11Authority -Context "R11 authority"

    Assert-NoForbiddenPositiveClaim -Text $combinedText -Context "Status docs" -ClaimLabel "broad autonomous milestone execution" -Pattern '(?i)\bbroad autonomous milestone execution\b|\bbroad autonomy\b'
    Assert-NoForbiddenPositiveClaim -Text $combinedText -Context "Status docs" -ClaimLabel "solved Codex context compaction" -Pattern '(?i)\bsolved Codex context compaction\b|\bCodex context compaction is solved\b'
    Assert-NoForbiddenPositiveClaim -Text $combinedText -Context "Status docs" -ClaimLabel "unattended automatic resume" -Pattern '(?i)\bunattended automatic resume\b'
    Assert-NoForbiddenPositiveClaim -Text $combinedText -Context "Status docs" -ClaimLabel "UI/control-room productization" -Pattern '(?i)\bUI/control-room productization\b|\bcontrol-room productization\b|\bproduct UI\b'
    Assert-NoForbiddenPositiveClaim -Text $combinedText -Context "Status docs" -ClaimLabel "Standard runtime" -Pattern '(?i)\bStandard runtime\b'
    Assert-NoForbiddenPositiveClaim -Text $combinedText -Context "Status docs" -ClaimLabel "multi-repo orchestration" -Pattern '(?i)\bmulti-repo orchestration\b'
    Assert-NoForbiddenPositiveClaim -Text $combinedText -Context "Status docs" -ClaimLabel "swarms" -Pattern '(?i)\bswarms\b|\bfleet execution\b'
    Assert-NoForbiddenPositiveClaim -Text $combinedText -Context "Status docs" -ClaimLabel "R11-002 controller CLI implementation" -Pattern '(?i)\bR11-002\b.{0,100}\b(built|implemented|exists|includes|complete|available|ships)\b.{0,100}\bcontroller CLI\b|\bR11-002\b.{0,100}\bcontroller CLI\b.{0,100}\b(built|implemented|exists|includes|complete|available|ships)\b'
    Assert-NoForbiddenPositiveClaim -Text $combinedText -Context "Status docs" -ClaimLabel "R11 bootstrap/resume execution" -Pattern '(?i)\bbootstrap/resume execution\b.{0,120}\b(built|implemented|exists|includes|complete|available|ships)\b|\bR11-002\b.{0,160}\bbootstrap/resume execution\b'
    Assert-NoForbiddenPositiveClaim -Text $combinedText -Context "Status docs" -ClaimLabel "R11 complete controlled cycle beyond the bounded pilot" -Pattern '(?i)\bcomplete controlled cycle\b.{0,120}\b(ran|run|executed|complete|exists|available)\b|\bR11-002\b.{0,160}\bcomplete controlled cycle\b|\bcontrolled-cycle pilot\b.{0,120}\b(closes R11|opens R12|production runtime|real production QA|broad autonomous)\b'
    Assert-NoForbiddenPositiveClaim -Text $combinedText -Context "Status docs" -ClaimLabel "real Dev execution" -Pattern '(?i)\breal Dev execution\b.{0,120}\b(ran|run|executed|complete|proven|proof)\b|\bDev execution\b.{0,120}\b(ran|run|executed)\b'
    if (-not $AllowR12Active) {
        Assert-NoForbiddenPositiveClaim -Text $combinedText -Context "Status docs" -ClaimLabel "unapproved successor milestone" -Pattern '(?i)\bR12\b.*\b(active|open|opened)\b|\bsuccessor milestone\b.*\b(active|open|opened)\b'
    }

    if ($currentStatusText -match '(?i)(`R10`|R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation).{0,120}(currently open|is now active|active in repo truth through `R10-|## Active Milestone)') {
        throw "Current status docs contain a stale R10 active contradiction after R11 opening."
    }

    return $kanbanSnapshot
}

function Test-R12OpeningStatus {
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$Texts
    )

    if (-not $Texts.Contains("R12Authority")) {
        throw "R12 authority document must exist when R12 is open."
    }

    $kanbanTaskStatuses = Get-R12TaskStatusMap -Text $Texts.Kanban -Context "KANBAN"
    $authorityTaskStatuses = Get-R12TaskStatusMap -Text $Texts.R12Authority -Context "R12 authority"

    foreach ($taskId in $kanbanTaskStatuses.Keys) {
        if ($authorityTaskStatuses[$taskId] -ne $kanbanTaskStatuses[$taskId]) {
            throw "R12 authority does not match KANBAN for status '$taskId'."
        }
    }

    $kanbanSnapshot = Get-ContiguousDoneThroughFromStatusMap -StatusMap $kanbanTaskStatuses -Context "KANBAN" -TaskPrefix "R12" -TaskCount 21
    $authoritySnapshot = Get-ContiguousDoneThroughFromStatusMap -StatusMap $authorityTaskStatuses -Context "R12 authority" -TaskPrefix "R12" -TaskCount 21

    if ($authoritySnapshot.DoneThrough -ne $kanbanSnapshot.DoneThrough -or $authoritySnapshot.PlannedStart -ne $kanbanSnapshot.PlannedStart -or $authoritySnapshot.PlannedThrough -ne $kanbanSnapshot.PlannedThrough) {
        throw "R12 authority does not match KANBAN for the live R12 task status boundary."
    }

    if ($kanbanSnapshot.DoneThrough -ne 16 -or $kanbanSnapshot.PlannedStart -ne 17 -or $kanbanSnapshot.PlannedThrough -ne 21) {
        throw "R12 open status must keep only R12-001 through R12-016 done and R12-017 through R12-021 planned."
    }

    $combinedText = [string]::Join([Environment]::NewLine, @($Texts.Values))
    $r12CurrentText = [string]::Join([Environment]::NewLine, @(
            $Texts.Readme,
            $Texts.ActiveState,
            $Texts.Kanban,
            $Texts.DecisionLog,
            $Texts.BranchingConvention,
            $Texts.R12Authority
        ))
    $r12Branch = "release/r12-external-api-runner-actionable-qa-control-room-pilot"
    $r11FinalHead = "c3bcdf803c0370db66eaa0a9227b3c2301b28fa2"
    $planningCommit = "5aa08904b02663a5549d2c8a21971544476ae805"
    $startingTree = "ac324d20d4538e50bfdcb92fe192185a824a2f48"
    $r9Head = "3c225f863add07f64a9026661d9465d02024a83d"

    Assert-RegexMatch -Text $Texts.Readme -Pattern 'R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`\s+is now the active milestone in repo truth through `R12-016` only' -Message "README must declare R12 active through R12-016 only."
    Assert-RegexMatch -Text $Texts.ActiveState -Pattern '## Active Milestone\s+`R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`\s+is now active in repo truth through `R12-016` only\.' -Message "ACTIVE_STATE must declare R12 active through R12-016 only."
    Assert-RegexMatch -Text $Texts.Kanban -Pattern '## Active Milestone\s+`R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`' -Message "KANBAN must declare R12 as active."
    Assert-RegexMatch -Text $Texts.Kanban -Pattern '## Most Recently Closed Milestone\s+`R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot`' -Message "KANBAN must keep R11 as most recently closed while R12 is active."
    Assert-RegexMatch -Text $Texts.DecisionLog -Pattern 'R12-007 Through R12-010 Added External Runner Replay Evidence Foundations' -Message "DECISION_LOG must record the R12-007 through R12-010 foundation decision."
    Assert-RegexMatch -Text $Texts.DecisionLog -Pattern 'R12-011 Through R12-013 Added Actionable QA Evidence Gate Foundations' -Message "DECISION_LOG must record the R12-011 through R12-013 foundation decision."
    Assert-RegexMatch -Text $Texts.DecisionLog -Pattern 'R12-014 Through R12-016 Added Operator Control-Room Foundation' -Message "DECISION_LOG must record the R12-014 through R12-016 foundation decision."

    foreach ($entry in @(
            @{ Text = $Texts.Readme; Context = "README" },
            @{ Text = $Texts.ActiveState; Context = "ACTIVE_STATE" },
            @{ Text = $Texts.Kanban; Context = "KANBAN" },
            @{ Text = $Texts.R12Authority; Context = "R12 authority" }
        )) {
        Assert-RegexMatch -Text $entry.Text -Pattern ([regex]::Escape($r12Branch)) -Message "$($entry.Context) must cite the R12 branch."
        Assert-RegexMatch -Text $entry.Text -Pattern ([regex]::Escape($r11FinalHead)) -Message "$($entry.Context) must cite the R11 final accepted closeout head."
        Assert-RegexMatch -Text $entry.Text -Pattern ([regex]::Escape($planningCommit)) -Message "$($entry.Context) must cite the R11 audit/R12 planning report commit."
    }

    Assert-RegexMatch -Text $combinedText -Pattern ([regex]::Escape($startingTree)) -Message "Status docs must cite the R12 starting tree."
    Assert-RegexMatch -Text $combinedText -Pattern ([regex]::Escape($r9Head)) -Message "Status docs must preserve the historical R9 support head."
    Assert-RegexMatch -Text $combinedText -Pattern 'governance/reports/AIOffice_V2_R11_Audit_and_R12_Planning_Report_v1\.md' -Message "Status docs must cite the R11 audit/R12 planning report."
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)narrative planning artifact|narrative operator planning artifact' -Message "Status docs must say the R11 audit/R12 planning report is narrative planning only."
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)not milestone proof' -Message "Status docs must say the planning report is not milestone proof."
    Assert-RegexMatch -Text $combinedText -Pattern 'contracts/value_scorecard/r12_value_scorecard\.contract\.json' -Message "Status docs must cite the R12 value scorecard contract."
    Assert-RegexMatch -Text $combinedText -Pattern 'tools/ValueScorecard\.psm1' -Message "Status docs must cite the R12 value scorecard module."
    Assert-RegexMatch -Text $combinedText -Pattern 'tests/test_value_scorecard\.ps1' -Message "Status docs must cite the R12 value scorecard tests."
    Assert-RegexMatch -Text $combinedText -Pattern 'contracts/operating_loop/r12_operating_loop\.contract\.json' -Message "Status docs must cite the R12 operating-loop contract."
    Assert-RegexMatch -Text $combinedText -Pattern 'tools/OperatingLoop\.psm1' -Message "Status docs must cite the R12 operating-loop module."
    Assert-RegexMatch -Text $combinedText -Pattern 'tests/test_operating_loop\.ps1' -Message "Status docs must cite the R12 operating-loop tests."
    Assert-RegexMatch -Text $combinedText -Pattern 'contracts/remote_head_phase/remote_head_phase_detection\.contract\.json' -Message "Status docs must cite the R12 remote-head phase contract."
    Assert-RegexMatch -Text $combinedText -Pattern 'tools/RemoteHeadPhaseDetector\.psm1' -Message "Status docs must cite the R12 remote-head phase module."
    Assert-RegexMatch -Text $combinedText -Pattern 'tests/test_remote_head_phase_detector\.ps1' -Message "Status docs must cite the R12 remote-head phase tests."
    Assert-RegexMatch -Text $combinedText -Pattern 'contracts/bootstrap/fresh_thread_bootstrap_packet\.contract\.json' -Message "Status docs must cite the R12 fresh-thread bootstrap contract."
    Assert-RegexMatch -Text $combinedText -Pattern 'tools/FreshThreadBootstrap\.psm1' -Message "Status docs must cite the R12 fresh-thread bootstrap module."
    Assert-RegexMatch -Text $combinedText -Pattern 'tests/test_fresh_thread_bootstrap\.ps1' -Message "Status docs must cite the R12 fresh-thread bootstrap tests."
    Assert-RegexMatch -Text $combinedText -Pattern 'contracts/residue_guard/transition_residue_preflight\.contract\.json' -Message "Status docs must cite the R12 transition residue preflight contract."
    Assert-RegexMatch -Text $combinedText -Pattern 'tools/TransitionResiduePreflight\.psm1' -Message "Status docs must cite the R12 transition residue preflight module."
    Assert-RegexMatch -Text $combinedText -Pattern 'tests/test_transition_residue_preflight\.ps1' -Message "Status docs must cite the R12 transition residue preflight tests."
    Assert-RegexMatch -Text $combinedText -Pattern 'contracts/external_runner/external_runner_request\.contract\.json' -Message "Status docs must cite the R12 external runner request contract."
    Assert-RegexMatch -Text $combinedText -Pattern 'contracts/external_runner/external_runner_result\.contract\.json' -Message "Status docs must cite the R12 external runner result contract."
    Assert-RegexMatch -Text $combinedText -Pattern 'contracts/external_runner/external_runner_artifact_manifest\.contract\.json' -Message "Status docs must cite the R12 external runner artifact manifest contract."
    Assert-RegexMatch -Text $combinedText -Pattern 'tools/ExternalRunnerContract\.psm1' -Message "Status docs must cite the R12 external runner contract module."
    Assert-RegexMatch -Text $combinedText -Pattern 'tests/test_external_runner_contracts\.ps1' -Message "Status docs must cite the R12 external runner contract tests."
    Assert-RegexMatch -Text $combinedText -Pattern 'tools/ExternalRunnerGitHubActions\.psm1' -Message "Status docs must cite the R12 GitHub Actions external runner module."
    Assert-RegexMatch -Text $combinedText -Pattern 'tests/test_external_runner_github_actions\.ps1' -Message "Status docs must cite the R12 GitHub Actions external runner tests."
    Assert-RegexMatch -Text $combinedText -Pattern '\.github/workflows/r12-external-replay\.yml' -Message "Status docs must cite the R12 external replay workflow."
    Assert-RegexMatch -Text $combinedText -Pattern 'contracts/external_replay/r12_external_replay_bundle\.contract\.json' -Message "Status docs must cite the R12 external replay bundle contract."
    Assert-RegexMatch -Text $combinedText -Pattern 'tools/validate_r12_external_replay_bundle\.ps1' -Message "Status docs must cite the R12 external replay bundle validator."
    Assert-RegexMatch -Text $combinedText -Pattern 'tests/test_r12_external_replay_bundle\.ps1' -Message "Status docs must cite the R12 external replay bundle tests."
    Assert-RegexMatch -Text $combinedText -Pattern 'contracts/external_runner/external_artifact_evidence_packet\.contract\.json' -Message "Status docs must cite the R12 external artifact evidence packet contract."
    Assert-RegexMatch -Text $combinedText -Pattern 'tools/ExternalArtifactEvidence\.psm1' -Message "Status docs must cite the R12 external artifact evidence module."
    Assert-RegexMatch -Text $combinedText -Pattern 'tests/test_external_artifact_evidence\.ps1' -Message "Status docs must cite the R12 external artifact evidence tests."
    Assert-RegexMatch -Text $combinedText -Pattern 'contracts/actionable_qa/actionable_qa_report\.contract\.json' -Message "Status docs must cite the R12 actionable QA report contract."
    Assert-RegexMatch -Text $combinedText -Pattern 'contracts/actionable_qa/actionable_qa_issue\.contract\.json' -Message "Status docs must cite the R12 actionable QA issue contract."
    Assert-RegexMatch -Text $combinedText -Pattern 'tools/ActionableQa\.psm1' -Message "Status docs must cite the R12 actionable QA module."
    Assert-RegexMatch -Text $combinedText -Pattern 'tools/invoke_actionable_qa\.ps1' -Message "Status docs must cite the R12 actionable QA runner."
    Assert-RegexMatch -Text $combinedText -Pattern 'tests/test_actionable_qa\.ps1' -Message "Status docs must cite the R12 actionable QA tests."
    Assert-RegexMatch -Text $combinedText -Pattern 'contracts/actionable_qa/actionable_qa_fix_queue\.contract\.json' -Message "Status docs must cite the R12 actionable QA fix queue contract."
    Assert-RegexMatch -Text $combinedText -Pattern 'tools/ActionableQaFixQueue\.psm1' -Message "Status docs must cite the R12 actionable QA fix queue module."
    Assert-RegexMatch -Text $combinedText -Pattern 'tools/export_actionable_qa_fix_queue\.ps1' -Message "Status docs must cite the R12 actionable QA fix queue exporter."
    Assert-RegexMatch -Text $combinedText -Pattern 'tests/test_actionable_qa_fix_queue\.ps1' -Message "Status docs must cite the R12 actionable QA fix queue tests."
    Assert-RegexMatch -Text $combinedText -Pattern 'contracts/actionable_qa/cycle_qa_evidence_gate\.contract\.json' -Message "Status docs must cite the R12 cycle QA evidence gate contract."
    Assert-RegexMatch -Text $combinedText -Pattern 'tools/ActionableQaEvidenceGate\.psm1' -Message "Status docs must cite the R12 actionable QA evidence gate module."
    Assert-RegexMatch -Text $combinedText -Pattern 'tools/invoke_actionable_qa_evidence_gate\.ps1' -Message "Status docs must cite the R12 actionable QA evidence gate runner."
    Assert-RegexMatch -Text $combinedText -Pattern 'tests/test_actionable_qa_evidence_gate\.ps1' -Message "Status docs must cite the R12 actionable QA evidence gate tests."
    Assert-RegexMatch -Text $combinedText -Pattern 'contracts/control_room/control_room_status\.contract\.json' -Message "Status docs must cite the R12 control-room status contract."
    Assert-RegexMatch -Text $combinedText -Pattern 'tools/ControlRoomStatus\.psm1' -Message "Status docs must cite the R12 control-room status module."
    Assert-RegexMatch -Text $combinedText -Pattern 'tools/export_control_room_status\.ps1' -Message "Status docs must cite the R12 control-room status exporter."
    Assert-RegexMatch -Text $combinedText -Pattern 'tests/test_control_room_status\.ps1' -Message "Status docs must cite the R12 control-room status tests."
    Assert-RegexMatch -Text $combinedText -Pattern 'contracts/control_room/control_room_view\.contract\.json' -Message "Status docs must cite the R12 control-room view contract."
    Assert-RegexMatch -Text $combinedText -Pattern 'tools/render_control_room_view\.psm1' -Message "Status docs must cite the R12 control-room view renderer."
    Assert-RegexMatch -Text $combinedText -Pattern 'tests/test_control_room_view\.ps1' -Message "Status docs must cite the R12 control-room view tests."
    Assert-RegexMatch -Text $combinedText -Pattern 'contracts/control_room/operator_decision_queue\.contract\.json' -Message "Status docs must cite the R12 operator decision queue contract."
    Assert-RegexMatch -Text $combinedText -Pattern 'tools/OperatorDecisionQueue\.psm1' -Message "Status docs must cite the R12 operator decision queue module."
    Assert-RegexMatch -Text $combinedText -Pattern 'tools/export_operator_decision_queue\.ps1' -Message "Status docs must cite the R12 operator decision queue exporter."
    Assert-RegexMatch -Text $combinedText -Pattern 'tests/test_operator_decision_queue\.ps1' -Message "Status docs must cite the R12 operator decision queue tests."
    Assert-RegexMatch -Text $combinedText -Pattern 'state/control_room/r12_current/control_room_status\.json' -Message "Status docs must cite the current R12 control-room status artifact."
    Assert-RegexMatch -Text $combinedText -Pattern 'state/control_room/r12_current/control_room\.md' -Message "Status docs must cite the current R12 control-room Markdown view."
    Assert-RegexMatch -Text $combinedText -Pattern 'state/control_room/r12_current/operator_decision_queue\.json' -Message "Status docs must cite the current R12 operator decision queue JSON."
    Assert-RegexMatch -Text $combinedText -Pattern 'state/control_room/r12_current/operator_decision_queue\.md' -Message "Status docs must cite the current R12 operator decision queue Markdown."
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)current real QA evidence gate cannot pass without real external runner result and external artifact evidence' -Message "Status docs must state that the current real QA evidence gate cannot pass without real external evidence."
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)R12 cannot close unless all four value gates|R12 cannot close without all four value gates' -Message "Status docs must state that R12 cannot close without all four value gates."
    Assert-RegexMatch -Text $combinedText -Pattern '(?i)R12-017` through `R12-021` remain planned only|R12-017` through `R12-021` remain planned only' -Message "Status docs must preserve that R12-017 through R12-021 are planned only."
    Assert-RegexMatch -Text $Texts.BranchingConvention -Pattern 'R12 branch: `release/r12-external-api-runner-actionable-qa-control-room-pilot`' -Message "Branching convention must record the R12 branch."
    Assert-R12NonClaimsPreserved -Text $Texts.R12Authority -Context "R12 authority"

    Assert-NoForbiddenPositiveClaim -Text $r12CurrentText -Context "Status docs" -ClaimLabel "delivered R12 value gates" -Pattern '(?i)\bR12\b.{0,120}\b(value gates?|external/API runner gate|actionable QA gate|operator control-room gate|real build/change gate)\b.{0,120}\b(delivered|proved|implemented and exercised|complete)\b'
    Assert-NoForbiddenPositiveClaim -Text $r12CurrentText -Context "Status docs" -ClaimLabel "10 percent corrected progress uplift" -Pattern '(?i)\b10 percent\b.{0,120}\b(corrected progress uplift|improvement|progress)\b.{0,120}\b(claimed|proved|delivered|achieved)\b'
    Assert-NoForbiddenPositiveClaim -Text $r12CurrentText -Context "Status docs" -ClaimLabel "R13 successor opening" -Pattern '(?i)\bR13\b.*\b(active|open|opened)\b|\bsuccessor milestone\b.*\b(active|open|opened)\b'
    Assert-NoForbiddenPositiveClaim -Text $r12CurrentText -Context "Status docs" -ClaimLabel "production runtime" -Pattern '(?i)\bproduction runtime\b'
    Assert-NoForbiddenPositiveClaim -Text $r12CurrentText -Context "Status docs" -ClaimLabel "real production QA" -Pattern '(?i)\breal production QA\b'
    Assert-NoForbiddenPositiveClaim -Text $r12CurrentText -Context "Status docs" -ClaimLabel "productized control-room behavior" -Pattern '(?i)\bproductized control-room behavior\b|\bfull UI/control-room productization\b'
    Assert-NoForbiddenPositiveClaim -Text $r12CurrentText -Context "Status docs" -ClaimLabel "broad autonomy" -Pattern '(?i)\bbroad autonomous milestone execution\b|\bbroad autonomy\b'
    Assert-NoForbiddenPositiveClaim -Text $r12CurrentText -Context "Status docs" -ClaimLabel "solved Codex reliability" -Pattern '(?i)\bsolved Codex reliability\b|\bsolved Codex context compaction\b'

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
        BranchingConvention = Resolve-ExistingPath -PathValue "governance\BRANCHING_CONVENTION.md" -Label "Branching convention" -AnchorPath $resolvedRepositoryRoot
        R8Authority = Resolve-ExistingPath -PathValue "governance\R8_REMOTE_GATED_QA_SUBAGENT_AND_CLEAN_CHECKOUT_PROOF_RUNNER.md" -Label "R8 authority" -AnchorPath $resolvedRepositoryRoot
    }

    $r9AuthorityPath = Resolve-PathValue -PathValue "governance\R9_ISOLATED_QA_AND_CONTINUITY_MANAGED_MILESTONE_EXECUTION_PILOT.md" -AnchorPath $resolvedRepositoryRoot
    if (Test-Path -LiteralPath $r9AuthorityPath) {
        $paths["R9Authority"] = (Resolve-Path -LiteralPath $r9AuthorityPath).Path
    }

    $r10AuthorityPath = Resolve-PathValue -PathValue "governance\R10_REAL_EXTERNAL_RUNNER_ARTIFACT_IDENTITY_AND_FINAL_HEAD_CLEAN_REPLAY_FOUNDATION.md" -AnchorPath $resolvedRepositoryRoot
    if (Test-Path -LiteralPath $r10AuthorityPath) {
        $paths["R10Authority"] = (Resolve-Path -LiteralPath $r10AuthorityPath).Path
    }

    $r11AuthorityPath = Resolve-PathValue -PathValue "governance\R11_CONTROLLED_EXTERNAL_CYCLE_CONTROLLER_AND_REPO_TRUTH_RESUME_PILOT.md" -AnchorPath $resolvedRepositoryRoot
    if (Test-Path -LiteralPath $r11AuthorityPath) {
        $paths["R11Authority"] = (Resolve-Path -LiteralPath $r11AuthorityPath).Path
    }

    $r12AuthorityPath = Resolve-PathValue -PathValue "governance\R12_EXTERNAL_API_RUNNER_ACTIONABLE_QA_AND_CONTROL_ROOM_WORKFLOW_PILOT.md" -AnchorPath $resolvedRepositoryRoot
    if (Test-Path -LiteralPath $r12AuthorityPath) {
        $paths["R12Authority"] = (Resolve-Path -LiteralPath $r12AuthorityPath).Path
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
    $r9Opened = $combinedText -match 'R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`\s+is now (?:the )?active'
    $r9Closed = $combinedText -match 'R9 Isolated QA and Continuity-Managed Milestone Execution Pilot`\s+(?:is now closed in repo truth|is formally closed|is now the most recently closed milestone)'
    $r10Opened = $combinedText -match 'R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`\s+is now (?:the )?active'
    $r10Closed = $combinedText -match 'R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation`\s+(?:is now closed in repo truth|is formally closed|is now the most recently closed milestone)'
    $r11Opened = $combinedText -match 'R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot`\s+is now (?:the )?active'
    $r11Closed = $combinedText -match 'R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot`\s+(?:is now closed narrowly in repo truth|is closed narrowly in repo truth|is formally closed)'
    $r12Opened = $combinedText -match 'R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot`\s+is now (?:the )?active'
    Assert-MostRecentlyClosedMilestoneConsistency -Texts $texts -R8Closed $r8Closed -R9Closed $r9Closed -R10Closed $r10Closed -R11Closed $r11Closed
    $r9Snapshot = $null
    $r10Snapshot = $null
    $r11Snapshot = $null
    $r12Snapshot = $null

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
        if ($r9Closed) {
            $r9Snapshot = Test-R9ClosedStatus -Texts $texts -AllowR10Active:$r10Opened -AllowR10Closed:$r10Closed -AllowR11Active:$r11Opened -AllowR11Closed:$r11Closed -AllowR12Active:$r12Opened
            if ($r10Closed) {
                $r10Snapshot = Test-R10ClosedStatus -Texts $texts -AllowR11Active:$r11Opened -AllowR11Closed:$r11Closed -AllowR12Active:$r12Opened
                if ($r11Opened -or $r11Closed) {
                    $r11Snapshot = Test-R11OpeningStatus -Texts $texts -Closed:$r11Closed -AllowR12Active:$r12Opened
                    if ($r12Opened) {
                        $r12Snapshot = Test-R12OpeningStatus -Texts $texts
                    }
                }
            }
            elseif ($r10Opened) {
                $r10Snapshot = Test-R10OpeningStatus -Texts $texts
            }
        }
        elseif ($r9Opened) {
            Assert-RegexMatch -Text $texts.Readme -Pattern 'R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`\s+is now the most recently closed milestone' -Message "README must mark R8 as the most recently closed milestone after R8-009."
            $r9Snapshot = Test-R9OpeningStatus -Texts $texts
            Assert-RegexMatch -Text $texts.Kanban -Pattern '## Most Recently Closed Milestone\s+`R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`' -Message "KANBAN must mark R8 as the most recently closed milestone."
        }
        else {
            Assert-RegexMatch -Text $texts.Readme -Pattern 'R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`\s+is now the most recently closed milestone' -Message "README must mark R8 as the most recently closed milestone after R8-009."
            Assert-RegexMatch -Text $texts.ActiveState -Pattern 'No active implementation milestone is open after R8 closeout' -Message "ACTIVE_STATE must not open a successor milestone after R8 closeout."
            Assert-RegexMatch -Text $texts.Kanban -Pattern '## Active Milestone\s+No active implementation milestone is open after R8 closeout\.' -Message "KANBAN must not open a successor milestone after R8 closeout."
            Assert-RegexMatch -Text $texts.Kanban -Pattern '## Most Recently Closed Milestone\s+`R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`' -Message "KANBAN must mark R8 as the most recently closed milestone."
        }
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

    if ($r10Opened -and $combinedText -match '(?i)R11.*is now active') {
        throw "Status docs must not open a successor milestone after R10 opening."
    }

    $activeMilestone = if ($r12Opened) { "R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot" } elseif ($r11Opened) { "R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot" } elseif ($r10Closed) { "none" } elseif ($r10Opened) { "R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation" } elseif ($r9Opened) { "R9 Isolated QA and Continuity-Managed Milestone Execution Pilot" } elseif ($r8Closed) { "none" } else { "R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner" }
    $mostRecentlyClosedMilestone = if ($r11Closed) { "R11 Controlled External Cycle Controller and Repo-Truth Resume Pilot" } elseif ($r10Closed) { "R10 Real External Runner Artifact Identity and Final-Head Clean Replay Foundation" } elseif ($r9Closed) { "R9 Isolated QA and Continuity-Managed Milestone Execution Pilot" } elseif ($r8Closed) { "R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner" } else { "R7 Fault-Managed Continuity and Rollback Drill" }

    return [pscustomobject]@{
        ActiveMilestone = $activeMilestone
        MostRecentlyClosedMilestone = $mostRecentlyClosedMilestone
        DoneThrough = $kanbanSnapshot.DoneThrough
        PlannedStart = $kanbanSnapshot.PlannedStart
        PlannedThrough = $kanbanSnapshot.PlannedThrough
        R9DoneThrough = if ($null -eq $r9Snapshot) { $null } else { $r9Snapshot.DoneThrough }
        R9PlannedStart = if ($null -eq $r9Snapshot) { $null } else { $r9Snapshot.PlannedStart }
        R9PlannedThrough = if ($null -eq $r9Snapshot) { $null } else { $r9Snapshot.PlannedThrough }
        R10DoneThrough = if ($null -eq $r10Snapshot) { $null } else { $r10Snapshot.DoneThrough }
        R10PlannedStart = if ($null -eq $r10Snapshot) { $null } else { $r10Snapshot.PlannedStart }
        R10PlannedThrough = if ($null -eq $r10Snapshot) { $null } else { $r10Snapshot.PlannedThrough }
        R11DoneThrough = if ($null -eq $r11Snapshot) { $null } else { $r11Snapshot.DoneThrough }
        R11PlannedStart = if ($null -eq $r11Snapshot) { $null } else { $r11Snapshot.PlannedStart }
        R11PlannedThrough = if ($null -eq $r11Snapshot) { $null } else { $r11Snapshot.PlannedThrough }
        R12DoneThrough = if ($null -eq $r12Snapshot) { $null } else { $r12Snapshot.DoneThrough }
        R12PlannedStart = if ($null -eq $r12Snapshot) { $null } else { $r12Snapshot.PlannedStart }
        R12PlannedThrough = if ($null -eq $r12Snapshot) { $null } else { $r12Snapshot.PlannedThrough }
        R8RemainsOpen = (-not $r8Closed)
        R8Closed = $r8Closed
        R9Opened = $r9Opened
        R9Closed = $r9Closed
        R10Opened = $r10Opened
        R10Closed = $r10Closed
        R11Opened = $r11Opened
        R11Closed = $r11Closed
        R12Opened = $r12Opened
    }
}

Export-ModuleMember -Function Test-StatusDocGate
