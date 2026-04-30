Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$jsonRootModule = Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force -PassThru
$script:ReadSingleJsonObject = $jsonRootModule.ExportedCommands["Read-SingleJsonObject"]

$script:ProtectedTransitions = @(
    "plan_approved -> fresh_thread_bootstrap_ready",
    "fresh_thread_bootstrap_ready -> residue_preflight_passed",
    "residue_preflight_passed -> external_runner_requested",
    "external_runner_evidence_recorded -> dev_result_recorded",
    "dev_result_recorded -> actionable_qa_ready",
    "qa_gate_passed -> control_room_status_ready",
    "operator_decision_pending -> candidate_closeout_ready",
    "candidate_closeout_ready -> final_head_support_pending"
)

$script:RequiredNonClaims = @(
    "no destructive cleanup",
    "no destructive rollback",
    "no broad filesystem cleanup",
    "no R12 value-gate delivery"
)

$script:BroadRootPaths = @(
    ".",
    "/",
    ".git",
    "state",
    "tools",
    "tests",
    "contracts",
    "governance",
    "execution"
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

function Test-PathUnderRepositoryRoot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue
    )

    $fullPath = [System.IO.Path]::GetFullPath($PathValue)
    $fullRoot = [System.IO.Path]::GetFullPath((Get-RepositoryRoot)).TrimEnd([char[]]@([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar))
    if ($fullPath.Equals($fullRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $true
    }

    return $fullPath.StartsWith($fullRoot + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)
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
        throw "Transition residue preflight output '$Path' already exists. Use -Overwrite to replace it explicitly."
    }

    $parentPath = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($parentPath)) {
        New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    }

    $Document | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $Path -Encoding UTF8
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

function Assert-ObjectValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($null -eq $Value -or $Value -is [string] -or $Value -is [System.Array]) {
        throw "$Context must be an object."
    }

    return $Value
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

function Assert-ObjectArray {
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
        Assert-ObjectValue -Value $item -Context "$Context item" | Out-Null
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

function Get-UtcTimestamp {
    return [System.DateTimeOffset]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture)
}

function Get-TransitionResiduePreflightContract {
    return Read-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "residue_guard", "transition_residue_preflight.contract.json")) -Label "Transition residue preflight contract"
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

        if ($item -match '(?i)\b(destructive cleanup|destructive rollback|broad filesystem cleanup|R12 value-gate delivery)\b' -and $item -notmatch '(?i)\b(no|not|without|does not|non-claim|refuse|refuses|never)\b') {
            throw "$Context contains a forbidden positive claim: $item"
        }
    }
}

function Get-TransitionKey {
    param(
        [Parameter(Mandatory = $true)]
        [string]$From,
        [Parameter(Mandatory = $true)]
        [string]$To
    )

    return "$From -> $To"
}

function Assert-ProtectedTransition {
    param(
        [Parameter(Mandatory = $true)]
        [string]$From,
        [Parameter(Mandatory = $true)]
        [string]$To,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $key = Get-TransitionKey -From $From -To $To
    if ($script:ProtectedTransitions -notcontains $key) {
        throw "$Context transition '$key' is not protected by the R12 residue preflight contract."
    }
}

function Get-ParsedStatus {
    [CmdletBinding()]
    param(
        [AllowEmptyCollection()]
        [string[]]$RawGitStatus
    )

    $tracked = @()
    $untracked = @()
    foreach ($line in @($RawGitStatus)) {
        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }
        if ($line.Length -lt 4) {
            $tracked += $line
            continue
        }

        $xy = $line.Substring(0, 2)
        $path = $line.Substring(3).Trim()
        if ($xy -eq "??") {
            $untracked += $path
        }
        elseif (-not [string]::IsNullOrWhiteSpace($xy.Trim())) {
            $tracked += $path
        }
    }

    $PSCmdlet.WriteObject([pscustomobject][ordered]@{
        tracked_dirty_files = @($tracked)
        untracked_files = @($untracked)
    }, $false)
}

function Test-PathMatchesAnyPattern {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [AllowEmptyCollection()]
        [string[]]$Patterns
    )

    foreach ($pattern in @($Patterns)) {
        if ($Path -like $pattern) {
            return $true
        }
    }
    return $false
}

function Assert-QuarantineCandidate {
    param(
        [Parameter(Mandatory = $true)]
        $Candidate,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $path = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Candidate -Name "path" -Context $Context) -Context "$Context.path"
    $dryRunRef = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Candidate -Name "dry_run_evidence_ref" -Context $Context) -Context "$Context.dry_run_evidence_ref"
    $authorizationStatus = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Candidate -Name "authorization_status" -Context $Context) -Context "$Context.authorization_status"
    if (@("candidate", "authorized", "refused") -notcontains $authorizationStatus) {
        throw "$Context.authorization_status must be candidate, authorized, or refused."
    }

    $action = if (Test-HasProperty -Object $Candidate -Name "action") { [string]$Candidate.action } else { "quarantine_dry_run_only" }
    if ($action -match '(?i)delete|remove') {
        throw "$Context no deletion is allowed for quarantine candidates."
    }

    $normalized = $path.Replace("\", "/").TrimEnd("/")
    if ($script:BroadRootPaths -contains $normalized) {
        throw "$Context broad quarantine candidate '$path' is refused."
    }
    if ($normalized.StartsWith(".git/", [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "$Context .git quarantine candidate '$path' is refused."
    }
    if ([System.IO.Path]::IsPathRooted($path) -and -not (Test-PathUnderRepositoryRoot -PathValue $path)) {
        throw "$Context outside-repo quarantine candidate '$path' is refused."
    }

    if ([string]::IsNullOrWhiteSpace($dryRunRef)) {
        throw "$Context quarantine candidates require dry-run evidence before authorization."
    }
}

function Test-TransitionResiduePreflightObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Preflight,
        [string]$SourceLabel = "Transition residue preflight"
    )

    $contract = Get-TransitionResiduePreflightContract
    foreach ($field in @($contract.required_result_fields)) {
        Get-RequiredProperty -Object $Preflight -Name $field -Context $SourceLabel | Out-Null
    }

    if ($Preflight.repository -ne "AIOffice_V2") {
        throw "$SourceLabel repository must be AIOffice_V2."
    }
    if ($Preflight.branch -ne "release/r12-external-api-runner-actionable-qa-control-room-pilot") {
        throw "$SourceLabel branch must be release/r12-external-api-runner-actionable-qa-control-room-pilot."
    }
    Assert-GitSha -Value ([string]$Preflight.head) -Context "$SourceLabel head"
    Assert-GitSha -Value ([string]$Preflight.tree) -Context "$SourceLabel tree"
    Assert-ProtectedTransition -From ([string]$Preflight.transition_from) -To ([string]$Preflight.transition_to) -Context $SourceLabel

    $rawGitStatus = Assert-StringArray -Value $Preflight.raw_git_status -Context "$SourceLabel raw_git_status" -AllowEmpty
    $trackedDirtyFiles = Assert-StringArray -Value $Preflight.tracked_dirty_files -Context "$SourceLabel tracked_dirty_files" -AllowEmpty
    $untrackedFiles = Assert-StringArray -Value $Preflight.untracked_files -Context "$SourceLabel untracked_files" -AllowEmpty
    $expectedUntrackedFiles = Assert-StringArray -Value $Preflight.expected_untracked_files -Context "$SourceLabel expected_untracked_files" -AllowEmpty
    $unexpectedUntrackedFiles = Assert-StringArray -Value $Preflight.unexpected_untracked_files -Context "$SourceLabel unexpected_untracked_files" -AllowEmpty
    $evidenceRefs = Assert-StringArray -Value $Preflight.evidence_refs -Context "$SourceLabel evidence_refs"
    $nonClaims = Assert-StringArray -Value $Preflight.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel
    Assert-NoPositiveForbiddenClaim -Value @($nonClaims, $Preflight.refusal_reasons) -Context $SourceLabel

    $verdict = Assert-NonEmptyString -Value $Preflight.preflight_verdict -Context "$SourceLabel preflight_verdict"
    if (@("pass", "fail_closed") -notcontains $verdict) {
        throw "$SourceLabel preflight_verdict must be pass or fail_closed."
    }

    if (Test-HasProperty -Object $Preflight -Name "deletion_allowed") {
        if (Assert-BooleanValue -Value $Preflight.deletion_allowed -Context "$SourceLabel deletion_allowed") {
            throw "$SourceLabel no deletion is allowed."
        }
    }

    $parsed = Get-ParsedStatus -RawGitStatus $rawGitStatus
    foreach ($path in @($parsed.tracked_dirty_files)) {
        if ($trackedDirtyFiles -notcontains $path) {
            throw "$SourceLabel tracked_dirty_files must include '$path' from raw_git_status."
        }
    }
    foreach ($path in @($parsed.untracked_files)) {
        if ($untrackedFiles -notcontains $path) {
            throw "$SourceLabel untracked_files must include '$path' from raw_git_status."
        }
    }

    $expectedPatterns = if (Test-HasProperty -Object $Preflight -Name "expected_untracked_path_patterns") {
        Assert-StringArray -Value $Preflight.expected_untracked_path_patterns -Context "$SourceLabel expected_untracked_path_patterns" -AllowEmpty
    }
    else {
        @()
    }
    foreach ($path in $expectedUntrackedFiles) {
        if ($untrackedFiles -notcontains $path) {
            throw "$SourceLabel expected_untracked_files includes '$path' that is not untracked."
        }
        if ($expectedPatterns.Count -eq 0 -or -not (Test-PathMatchesAnyPattern -Path $path -Patterns $expectedPatterns)) {
            throw "$SourceLabel expected generated artifacts must be declared with exact path patterns."
        }
    }

    $quarantineCandidates = Assert-ObjectArray -Value $Preflight.quarantine_candidates -Context "$SourceLabel quarantine_candidates" -AllowEmpty
    for ($index = 0; $index -lt $quarantineCandidates.Count; $index += 1) {
        Assert-QuarantineCandidate -Candidate $quarantineCandidates[$index] -Context "$SourceLabel quarantine_candidates[$index]"
    }

    if ($trackedDirtyFiles.Count -gt 0 -and $verdict -ne "fail_closed") {
        throw "$SourceLabel dirty tracked files block transition."
    }
    if ($unexpectedUntrackedFiles.Count -gt 0 -and $verdict -ne "fail_closed") {
        throw "$SourceLabel unexpected untracked files block transition."
    }
    if ($trackedDirtyFiles.Count -eq 0 -and $unexpectedUntrackedFiles.Count -eq 0 -and $verdict -ne "pass") {
        throw "$SourceLabel clean or expected-only status should pass unless a refusal reason is recorded."
    }

    $PSCmdlet.WriteObject([pscustomobject][ordered]@{
        IsValid = $true
        Transition = (Get-TransitionKey -From $Preflight.transition_from -To $Preflight.transition_to)
        Verdict = $verdict
        TrackedDirtyCount = $trackedDirtyFiles.Count
        UnexpectedUntrackedCount = $unexpectedUntrackedFiles.Count
        EvidenceRefCount = $evidenceRefs.Count
        Head = $Preflight.head
        Tree = $Preflight.tree
        Branch = $Preflight.branch
    }, $false)
}

function Test-TransitionResiduePreflightContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PreflightPath
    )

    $preflight = Read-JsonDocument -Path (Resolve-PathValue -PathValue $PreflightPath) -Label "Transition residue preflight"
    return Test-TransitionResiduePreflightObject -Preflight $preflight -SourceLabel $PreflightPath
}

function Assert-TransitionResiduePreflightReady {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PreflightPath,
        [Parameter(Mandatory = $true)]
        [string]$ExpectedBranch,
        [Parameter(Mandatory = $true)]
        [string]$ExpectedHead,
        [Parameter(Mandatory = $true)]
        [string]$ExpectedTree,
        [Parameter(Mandatory = $true)]
        [string]$TransitionFrom,
        [Parameter(Mandatory = $true)]
        [string]$TransitionTo
    )

    $resolvedPath = Resolve-PathValue -PathValue $PreflightPath
    if (-not (Test-Path -LiteralPath $resolvedPath -PathType Leaf)) {
        throw "missing preflight result for transition '$TransitionFrom -> $TransitionTo'."
    }

    $preflight = Read-JsonDocument -Path $resolvedPath -Label "Transition residue preflight"
    $validation = Test-TransitionResiduePreflightObject -Preflight $preflight -SourceLabel $PreflightPath

    if ($preflight.branch -ne $ExpectedBranch) {
        throw "wrong branch preflight result: expected '$ExpectedBranch', got '$($preflight.branch)'."
    }
    if ($preflight.head -ne $ExpectedHead -or $preflight.tree -ne $ExpectedTree) {
        throw "stale head/tree preflight result: expected $ExpectedHead/$ExpectedTree, got $($preflight.head)/$($preflight.tree)."
    }
    if ($preflight.transition_from -ne $TransitionFrom -or $preflight.transition_to -ne $TransitionTo) {
        throw "wrong transition preflight result: expected '$TransitionFrom -> $TransitionTo'."
    }
    if ($validation.Verdict -ne "pass") {
        throw "transition residue preflight verdict is '$($validation.Verdict)' and blocks transition."
    }

    return $true
}

function New-TransitionResiduePreflight {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TransitionFrom,
        [Parameter(Mandatory = $true)]
        [string]$TransitionTo,
        [string[]]$RawGitStatus = $null,
        [string[]]$ExpectedUntrackedPathPatterns = @(),
        [object[]]$QuarantineCandidates = @(),
        [string[]]$EvidenceRefs = @("contracts/residue_guard/transition_residue_preflight.contract.json", "tools/TransitionResiduePreflight.psm1"),
        [string]$OutputPath = "",
        [switch]$Overwrite
    )

    Assert-ProtectedTransition -From $TransitionFrom -To $TransitionTo -Context "Transition residue preflight"

    $branch = (Invoke-GitLines -Arguments @("branch", "--show-current"))[0].Trim()
    $head = (Invoke-GitLines -Arguments @("rev-parse", "HEAD"))[0].Trim()
    $tree = (Invoke-GitLines -Arguments @("rev-parse", "HEAD^{tree}"))[0].Trim()
    $statusLines = if ($null -eq $RawGitStatus) {
        @(Invoke-GitLines -Arguments @("status", "--short", "--untracked-files=all") | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    }
    else {
        @($RawGitStatus)
    }

    $parsed = Get-ParsedStatus -RawGitStatus $statusLines
    $expectedUntracked = @($parsed.untracked_files | Where-Object { Test-PathMatchesAnyPattern -Path $_ -Patterns $ExpectedUntrackedPathPatterns })
    $unexpectedUntracked = @($parsed.untracked_files | Where-Object { -not (Test-PathMatchesAnyPattern -Path $_ -Patterns $ExpectedUntrackedPathPatterns) })
    $refusalReasons = @()
    if (@($parsed.tracked_dirty_files).Count -gt 0) {
        $refusalReasons += "dirty tracked files block transition."
    }
    if ($unexpectedUntracked.Count -gt 0) {
        $refusalReasons += "unexpected untracked files block transition."
    }
    $verdict = if ($refusalReasons.Count -eq 0) { "pass" } else { "fail_closed" }

    $preflight = [pscustomobject][ordered]@{
        contract_version = "v1"
        artifact_type = "transition_residue_preflight"
        repository = "AIOffice_V2"
        branch = $branch
        head = $head
        tree = $tree
        transition_from = $TransitionFrom
        transition_to = $TransitionTo
        raw_git_status = @($statusLines)
        tracked_dirty_files = @($parsed.tracked_dirty_files)
        untracked_files = @($parsed.untracked_files)
        expected_untracked_path_patterns = @($ExpectedUntrackedPathPatterns)
        expected_untracked_files = @($expectedUntracked)
        unexpected_untracked_files = @($unexpectedUntracked)
        quarantine_candidates = @($QuarantineCandidates)
        deletion_allowed = $false
        preflight_verdict = $verdict
        refusal_reasons = @($refusalReasons)
        evidence_refs = @($EvidenceRefs)
        created_at_utc = Get-UtcTimestamp
        non_claims = @($script:RequiredNonClaims)
    }

    Test-TransitionResiduePreflightObject -Preflight $preflight -SourceLabel "Transition residue preflight draft" | Out-Null

    if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
        Write-JsonDocument -Path (Resolve-PathValue -PathValue $OutputPath) -Document $preflight -Overwrite:$Overwrite
    }

    $PSCmdlet.WriteObject($preflight, $false)
}

Export-ModuleMember -Function Get-TransitionResiduePreflightContract, Test-TransitionResiduePreflightObject, Test-TransitionResiduePreflightContract, Assert-TransitionResiduePreflightReady, New-TransitionResiduePreflight
