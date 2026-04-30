Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$jsonRootModule = Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force -PassThru
$script:ReadSingleJsonObject = $jsonRootModule.ExportedCommands["Read-SingleJsonObject"]

$script:AllowedOutcomes = @(
    "phase_match",
    "advanced_remote_head",
    "stale_expected_head",
    "branch_mismatch",
    "dirty_worktree_blocked",
    "missing_remote_ref",
    "unknown_remote_head",
    "fail_closed"
)

$script:ContinueOutcomes = @("phase_match", "advanced_remote_head")

$script:RequiredNonClaims = @(
    "no broad release automation",
    "no external runner execution",
    "no R12 value-gate delivery",
    "no solved Codex reliability"
)

function Get-RepositoryRoot {
    return $repoRoot
}

function Join-RepositoryPath {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Segments
    )

    $path = Get-RepositoryRoot
    foreach ($segment in $Segments) {
        $path = Join-Path $path $segment
    }

    return $path
}

function Resolve-PathValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path (Get-RepositoryRoot) $PathValue))
}

function Read-JsonDocument {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $document = & $script:ReadSingleJsonObject -Path $Path -Label $Label
    $PSCmdlet.WriteObject($document, $false)
}

function Write-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Document,
        [switch]$Overwrite
    )

    if ((Test-Path -LiteralPath $Path -PathType Leaf) -and -not $Overwrite) {
        throw "Remote-head phase output '$Path' already exists. Use -Overwrite to replace it explicitly."
    }

    $parentPath = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($parentPath)) {
        New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    }

    $Document | ConvertTo-Json -Depth 80 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Test-HasProperty {
    param(
        [AllowNull()]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    return $null -ne $Object -and @($Object.PSObject.Properties.Name) -contains $Name
}

function Get-RequiredProperty {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if (-not (Test-HasProperty -Object $Object -Name $Name)) {
        throw "$Context is missing required field '$Name'."
    }

    $PSCmdlet.WriteObject($Object.PSObject.Properties[$Name].Value, $false)
}

function Assert-NonEmptyString {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -isnot [string] -or [string]::IsNullOrWhiteSpace($Value)) {
        throw "$Context must be a non-empty string."
    }

    return $Value
}

function Assert-BooleanValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -isnot [bool]) {
        throw "$Context must be a boolean."
    }

    return [bool]$Value
}

function Assert-StringArray {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [switch]$AllowEmpty
    )

    if ($null -eq $Value -or $Value -is [string] -or -not ($Value -is [System.Collections.IEnumerable])) {
        throw "$Context must be an array."
    }

    $items = @($Value)
    if (-not $AllowEmpty -and $items.Count -eq 0) {
        throw "$Context must not be empty."
    }

    foreach ($item in $items) {
        Assert-NonEmptyString -Value $item -Context "$Context item" | Out-Null
    }

    $PSCmdlet.WriteObject($items, $false)
}

function Assert-GitSha {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-NonEmptyString -Value $Value -Context $Context | Out-Null
    if ($Value -notmatch '^[0-9a-f]{40}$') {
        throw "$Context must be a 40-character Git SHA."
    }
}

function Get-UtcTimestamp {
    return [System.DateTimeOffset]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture)
}

function Invoke-GitLines {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & git -C (Get-RepositoryRoot) @Arguments 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }

    if ($exitCode -ne 0) {
        throw "Git command failed: git $($Arguments -join ' ')"
    }

    return @($output | ForEach-Object { [string]$_ })
}

function Get-RemoteHeadPhaseContract {
    return Read-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "remote_head_phase", "remote_head_phase_detection.contract.json")) -Label "Remote-head phase detection contract"
}

function Assert-RequiredNonClaims {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$NonClaims,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($requiredNonClaim in $script:RequiredNonClaims) {
        if ($NonClaims -notcontains $requiredNonClaim) {
            throw "$Context non_claims must include '$requiredNonClaim'."
        }
    }
}

function Assert-NoPositiveForbiddenClaim {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $items = if ($Value -is [System.Array]) { @($Value) } else { @($Value) }
    foreach ($item in $items) {
        if ($item -isnot [string]) {
            continue
        }

        if ($item -match '(?i)\b(broad release automation|external runner execution|R12 value-gate delivery|solved Codex reliability)\b' -and $item -notmatch '(?i)\b(no|not|without|does not|non-claim|refuse|refuses|planned only)\b') {
            throw "$Context contains a forbidden positive claim: $item"
        }
    }
}

function Get-RemoteHeadPhaseOutcome {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Detection
    )

    $refusalReasons = @()
    $outcome = "fail_closed"
    $exactNextAction = "refuse_and_record_ambiguous_remote_head_phase_state"
    $failClosed = $true

    $worktreeStatus = @($Detection.worktree_status)
    $evidenceRefs = @($Detection.evidence_refs)
    $allowedPriorHeads = @($Detection.allowed_prior_heads)
    $allowedNextHeads = @($Detection.allowed_next_heads)

    if ($evidenceRefs.Count -eq 0) {
        $outcome = "fail_closed"
        $refusalReasons += "evidence refs are missing; remote-head phase state cannot be accepted."
        $exactNextAction = "record required evidence refs before continuing"
    }
    elseif ($Detection.active_branch -ne $Detection.expected_branch) {
        $outcome = "branch_mismatch"
        $refusalReasons += "active branch '$($Detection.active_branch)' does not match expected branch '$($Detection.expected_branch)'."
        $exactNextAction = "stop_and_switch_to_expected_branch_or_request_operator_direction"
    }
    elseif ($worktreeStatus.Count -gt 0) {
        $outcome = "dirty_worktree_blocked"
        $refusalReasons += "worktree status is not clean; dirty tracked or unclassified local residue blocks transition."
        $exactNextAction = "stop_and_run_residue_preflight_before_remote_phase_detection"
    }
    elseif ([string]::IsNullOrWhiteSpace([string]$Detection.remote_ref) -or [string]::IsNullOrWhiteSpace([string]$Detection.remote_head)) {
        $outcome = "missing_remote_ref"
        $refusalReasons += "remote ref or remote head is missing."
        $exactNextAction = "query_remote_ref_and_record_exact_remote_head"
    }
    elseif ($Detection.local_head -eq $Detection.expected_current_head -and $Detection.remote_head -eq $Detection.expected_current_head) {
        $outcome = "phase_match"
        $failClosed = $false
        $exactNextAction = "continue_current_phase_with_matching_local_and_remote_head"
    }
    elseif ($allowedNextHeads -contains $Detection.remote_head -and ($allowedPriorHeads -contains $Detection.expected_current_head -or $Detection.local_head -ne $Detection.remote_head)) {
        $outcome = "advanced_remote_head"
        $failClosed = $false
        $exactNextAction = "refresh_bootstrap_from_remote_head_and_continue_at_allowed_next_phase"
    }
    elseif ($allowedPriorHeads -contains $Detection.expected_current_head) {
        $outcome = "stale_expected_head"
        $refusalReasons += "expected_current_head '$($Detection.expected_current_head)' is a prior head but remote head '$($Detection.remote_head)' is not an allowed next head."
        $exactNextAction = "stop_and_refresh_expected_current_head_from_repo_truth"
    }
    elseif ($Detection.remote_head -ne $Detection.expected_current_head -and $allowedPriorHeads -notcontains $Detection.remote_head -and $allowedNextHeads -notcontains $Detection.remote_head) {
        $outcome = "unknown_remote_head"
        $refusalReasons += "remote head '$($Detection.remote_head)' is not expected current, allowed prior, or allowed next."
        $exactNextAction = "fail_closed_and_request_operator_remote_head_reconciliation"
    }
    else {
        $outcome = "fail_closed"
        $refusalReasons += "remote-head phase state is ambiguous and cannot silently continue."
        $exactNextAction = "stop_and_record_exact_branch_head_tree_remote_ref_and_phase_name"
    }

    $PSCmdlet.WriteObject([pscustomobject][ordered]@{
        outcome = $outcome
        fail_closed = [bool]$failClosed
        exact_next_action = $exactNextAction
        refusal_reasons = @($refusalReasons)
    }, $false)
}

function Test-RemoteHeadPhaseDetectionObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Detection,
        [string]$SourceLabel = "Remote-head phase detection"
    )

    $contract = Get-RemoteHeadPhaseContract
    foreach ($field in @($contract.required_input_fields)) {
        Get-RequiredProperty -Object $Detection -Name $field -Context $SourceLabel | Out-Null
    }

    if ([string](Get-RequiredProperty -Object $Detection -Name "repository" -Context $SourceLabel) -ne "AIOffice_V2") {
        throw "$SourceLabel repository must be AIOffice_V2."
    }

    foreach ($field in @("active_branch", "expected_branch", "remote_ref", "phase_name")) {
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Detection -Name $field -Context $SourceLabel) -Context "$SourceLabel $field" | Out-Null
    }

    foreach ($field in @("local_head", "local_tree", "expected_current_head")) {
        Assert-GitSha -Value ([string](Get-RequiredProperty -Object $Detection -Name $field -Context $SourceLabel)) -Context "$SourceLabel $field"
    }

    if (-not [string]::IsNullOrWhiteSpace([string]$Detection.remote_head)) {
        Assert-GitSha -Value ([string]$Detection.remote_head) -Context "$SourceLabel remote_head"
    }

    Assert-StringArray -Value $Detection.allowed_prior_heads -Context "$SourceLabel allowed_prior_heads" -AllowEmpty | Out-Null
    Assert-StringArray -Value $Detection.allowed_next_heads -Context "$SourceLabel allowed_next_heads" -AllowEmpty | Out-Null
    Assert-StringArray -Value $Detection.worktree_status -Context "$SourceLabel worktree_status" -AllowEmpty | Out-Null
    $evidenceRefs = Assert-StringArray -Value $Detection.evidence_refs -Context "$SourceLabel evidence_refs"
    $nonClaims = Assert-StringArray -Value $Detection.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel
    Assert-NoPositiveForbiddenClaim -Value @($Detection.phase_name, $evidenceRefs, $nonClaims) -Context $SourceLabel

    $resolution = Get-RemoteHeadPhaseOutcome -Detection $Detection

    if (Test-HasProperty -Object $Detection -Name "outcome") {
        $declaredOutcome = Assert-NonEmptyString -Value $Detection.outcome -Context "$SourceLabel outcome"
        if ($script:AllowedOutcomes -notcontains $declaredOutcome) {
            throw "$SourceLabel outcome must be one of: $($script:AllowedOutcomes -join ', ')."
        }
        if ($declaredOutcome -ne $resolution.outcome) {
            throw "$SourceLabel outcome '$declaredOutcome' does not match computed outcome '$($resolution.outcome)'."
        }
    }

    if (Test-HasProperty -Object $Detection -Name "fail_closed") {
        $declaredFailClosed = Assert-BooleanValue -Value $Detection.fail_closed -Context "$SourceLabel fail_closed"
        if ($declaredFailClosed -ne [bool]$resolution.fail_closed) {
            throw "$SourceLabel fail_closed does not match computed outcome."
        }
    }

    $PSCmdlet.WriteObject([pscustomobject][ordered]@{
        IsValid = $true
        Outcome = $resolution.outcome
        FailClosed = [bool]$resolution.fail_closed
        ExactNextAction = $resolution.exact_next_action
        RefusalReasons = @($resolution.refusal_reasons)
        EvidenceRefCount = $evidenceRefs.Count
    }, $false)
}

function Test-RemoteHeadPhaseDetectionContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$DetectionPath
    )

    $resolvedPath = Resolve-PathValue -PathValue $DetectionPath
    $detection = Read-JsonDocument -Path $resolvedPath -Label "Remote-head phase detection"
    return Test-RemoteHeadPhaseDetectionObject -Detection $detection -SourceLabel $DetectionPath
}

function Assert-RemoteHeadPhaseReady {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $DetectionResult,
        [string]$SourceLabel = "Remote-head phase detection"
    )

    $outcome = [string]$DetectionResult.Outcome
    if ($script:ContinueOutcomes -notcontains $outcome) {
        throw "$SourceLabel failed closed with outcome '$outcome'."
    }

    return $true
}

function Invoke-RemoteHeadPhaseDetection {
    [CmdletBinding()]
    param(
        [string]$DetectionPath = "",
        [string]$OutputPath = "",
        [switch]$Overwrite,
        [string]$Repository = "AIOffice_V2",
        [string]$ExpectedBranch = "release/r12-external-api-runner-actionable-qa-control-room-pilot",
        [string]$RemoteRef = "refs/heads/release/r12-external-api-runner-actionable-qa-control-room-pilot",
        [string]$ExpectedCurrentHead = "",
        [string[]]$AllowedPriorHeads = @(),
        [string[]]$AllowedNextHeads = @(),
        [string]$PhaseName = "r12_remote_head_phase_detection",
        [string[]]$EvidenceRefs = @("contracts/remote_head_phase/remote_head_phase_detection.contract.json"),
        [string[]]$NonClaims = $script:RequiredNonClaims
    )

    if (-not [string]::IsNullOrWhiteSpace($DetectionPath)) {
        $inputObject = Read-JsonDocument -Path (Resolve-PathValue -PathValue $DetectionPath) -Label "Remote-head phase detection input"
    }
    else {
    $activeBranch = (@(Invoke-GitLines -Arguments @("branch", "--show-current")))[0].Trim()
    $localHead = (@(Invoke-GitLines -Arguments @("rev-parse", "HEAD")))[0].Trim()
    $localTree = (@(Invoke-GitLines -Arguments @("rev-parse", "HEAD^{tree}")))[0].Trim()
        $remoteLine = @(Invoke-GitLines -Arguments @("ls-remote", "origin", $RemoteRef))
        $remoteHead = ""
        if ($remoteLine.Count -gt 0 -and $remoteLine[0] -match '^([0-9a-f]{40})\s+') {
            $remoteHead = $Matches[1]
        }
        $statusLines = @(Invoke-GitLines -Arguments @("status", "--short", "--untracked-files=all") | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
        $expectedHeadValue = if ([string]::IsNullOrWhiteSpace($ExpectedCurrentHead)) { $localHead } else { $ExpectedCurrentHead }
        $inputObject = [pscustomobject][ordered]@{
            repository = $Repository
            active_branch = $activeBranch
            expected_branch = $ExpectedBranch
            local_head = $localHead
            local_tree = $localTree
            remote_head = $remoteHead
            remote_ref = $RemoteRef
            expected_current_head = $expectedHeadValue
            allowed_prior_heads = @($AllowedPriorHeads)
            allowed_next_heads = @($AllowedNextHeads)
            phase_name = $PhaseName
            worktree_status = @($statusLines)
            evidence_refs = @($EvidenceRefs)
            non_claims = @($NonClaims)
        }
    }

    $validation = Test-RemoteHeadPhaseDetectionObject -Detection $inputObject -SourceLabel "Remote-head phase detection input"
    $result = [pscustomobject][ordered]@{
        contract_version = "v1"
        artifact_type = "remote_head_phase_detection_result"
        repository = $inputObject.repository
        active_branch = $inputObject.active_branch
        expected_branch = $inputObject.expected_branch
        local_head = $inputObject.local_head
        local_tree = $inputObject.local_tree
        remote_head = $inputObject.remote_head
        remote_ref = $inputObject.remote_ref
        expected_current_head = $inputObject.expected_current_head
        allowed_prior_heads = @($inputObject.allowed_prior_heads)
        allowed_next_heads = @($inputObject.allowed_next_heads)
        phase_name = $inputObject.phase_name
        worktree_status = @($inputObject.worktree_status)
        evidence_refs = @($inputObject.evidence_refs)
        outcome = $validation.Outcome
        fail_closed = [bool]$validation.FailClosed
        exact_next_action = $validation.ExactNextAction
        refusal_reasons = @($validation.RefusalReasons)
        created_at_utc = Get-UtcTimestamp
        non_claims = @($inputObject.non_claims)
    }

    Test-RemoteHeadPhaseDetectionObject -Detection $result -SourceLabel "Remote-head phase detection result" | Out-Null

    if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
        Write-JsonDocument -Path (Resolve-PathValue -PathValue $OutputPath) -Document $result -Overwrite:$Overwrite
    }

    $PSCmdlet.WriteObject($result, $false)
}

Export-ModuleMember -Function Get-RemoteHeadPhaseContract, Test-RemoteHeadPhaseDetectionObject, Test-RemoteHeadPhaseDetectionContract, Assert-RemoteHeadPhaseReady, Invoke-RemoteHeadPhaseDetection
