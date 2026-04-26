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

function Get-ContiguousDoneThroughFromStatusMap {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$StatusMap,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $doneThrough = 0
    $plannedStart = $null
    $plannedThrough = $null

    foreach ($taskNumber in 1..9) {
        $taskId = "R8-{0}" -f $taskNumber.ToString("000")
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

    if ($doneThrough -lt 9 -and $null -eq $plannedStart) {
        throw "$Context must preserve at least one planned R8 task while the milestone remains open."
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

    $texts = [ordered]@{}
    foreach ($entry in $paths.GetEnumerator()) {
        $texts[$entry.Key] = Get-TextDocument -Path $entry.Value -Label $entry.Key
    }

    Assert-RegexMatch -Text $texts.Readme -Pattern 'R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`\s+is now the active milestone' -Message "README must declare R8 as the active milestone."
    Assert-RegexMatch -Text $texts.ActiveState -Pattern '## Active Milestone\s+`R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`' -Message "ACTIVE_STATE must declare R8 as the active milestone."
    Assert-RegexMatch -Text $texts.Kanban -Pattern '## Active Milestone\s+`R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`' -Message "KANBAN must declare R8 as the active milestone."
    Assert-RegexMatch -Text $texts.R8Authority -Pattern 'R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner`\s+is now active in repo truth' -Message "R8 authority must declare R8 as active in repo truth."

    Assert-RegexMatch -Text $texts.Readme -Pattern 'R7 Fault-Managed Continuity and Rollback Drill`\s+is now the most recently closed milestone' -Message "README must preserve R7 as the most recently closed milestone."
    Assert-RegexMatch -Text $texts.Kanban -Pattern '## Most Recently Closed Milestone\s+`R7 Fault-Managed Continuity and Rollback Drill`' -Message "KANBAN must preserve R7 as the most recently closed milestone."
    Assert-RegexMatch -Text $texts.R8Authority -Pattern 'R7 Fault-Managed Continuity and Rollback Drill`\s+remains the most recently closed milestone' -Message "R8 authority must preserve R7 as the most recently closed milestone."

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

    if ($kanbanSnapshot.DoneThrough -ge 9 -or $r8ClosedClaimed) {
        if ($kanbanSnapshot.DoneThrough -lt 9) {
            throw "Status docs claim R8 is closed before R8-009 is complete."
        }

        if ($kanbanSnapshot.PlannedStart -ne $null -or $kanbanSnapshot.PlannedThrough -ne $null) {
            throw "Status docs cannot keep planned R8 tasks once R8-009 is marked done."
        }

        if ($combinedText -notmatch 'qa_proof_packet\.json') {
            throw "R8 closeout claims require a referenced QA packet."
        }

        if ($combinedText -notmatch '(?i)(state[\\/](proof_reviews|qa)|artifacts|support)[\\/].*post[_-]push.*verification.*\.json') {
            throw "R8 closeout claims require a referenced post-push verification artifact."
        }

        if ($combinedText -notmatch '(?i)actions/runs/\d+') {
            throw "R8 closeout claims require a concrete CI or external workflow run identity."
        }

        if ($combinedText -notmatch '(?i)state/proof_reviews/.*/r8') {
            throw "R8 closeout claims require a referenced R8 proof package path."
        }
    }

    Assert-PositiveClaimHasReference -Text $combinedText -Context "Status docs" -ClaimLabel "a concrete CI or external proof artifact" -PositivePattern '(?i)\bconcrete\b.*\b(ci|external)\b.*\bproof\b.*\b(artifact|run)\b.*\b(exists|recorded|available|present)\b' -ReferencePattern '(?i)actions/runs/\d+'
    Assert-PositiveClaimHasReference -Text $combinedText -Context "Status docs" -ClaimLabel "a clean-checkout QA packet" -PositivePattern '(?i)\b(clean-checkout qa|qa proof packet|qa packet)\b.*\b(exists|recorded|available|present)\b' -ReferencePattern 'qa_proof_packet\.json'
    Assert-PositiveClaimHasReference -Text $combinedText -Context "Status docs" -ClaimLabel "a post-push verification artifact" -PositivePattern '(?i)\bpost-push verification artifact\b.*\b(exists|recorded|available|present)\b' -ReferencePattern '(?i)(state[\\/](proof_reviews|qa)|artifacts|support)[\\/].*post[_-]push.*verification.*\.json'

    if ($texts.DecisionLog -match 'R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner.*no later implementation milestone is open yet in repo truth') {
        throw "DECISION_LOG still implies no later implementation milestone is open after R8 was opened."
    }

    return [pscustomobject]@{
        ActiveMilestone = "R8 Remote-Gated QA Subagent and Clean-Checkout Proof Runner"
        MostRecentlyClosedMilestone = "R7 Fault-Managed Continuity and Rollback Drill"
        DoneThrough = $kanbanSnapshot.DoneThrough
        PlannedStart = $kanbanSnapshot.PlannedStart
        PlannedThrough = $kanbanSnapshot.PlannedThrough
        R8RemainsOpen = ($kanbanSnapshot.DoneThrough -lt 9)
    }
}

Export-ModuleMember -Function Test-StatusDocGate
