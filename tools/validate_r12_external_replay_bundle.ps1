[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$BundlePath
)

$ErrorActionPreference = "Stop"
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$repoRoot = Split-Path -Parent $PSScriptRoot
$contractPath = Join-Path $repoRoot "contracts\external_replay\r12_external_replay_bundle.contract.json"
$contract = Read-SingleJsonObject -Path $contractPath -Label "R12 external replay bundle contract"
$bundle = Read-SingleJsonObject -Path $BundlePath -Label "R12 external replay bundle"
$bundlePathResolved = (Resolve-Path -LiteralPath $BundlePath).Path
$bundleRoot = [System.IO.Path]::GetFullPath((Split-Path -Parent $bundlePathResolved))
$gitObjectPattern = "^[a-f0-9]{40}$"
$timestampPattern = "^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$"

function Test-HasProperty {
    param($Object, [string]$Name)
    return $null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name
}

function Get-RequiredProperty {
    param($Object, [string]$Name, [string]$Context)
    if (-not (Test-HasProperty -Object $Object -Name $Name)) {
        throw "$Context is missing required field '$Name'."
    }
    return $Object.PSObject.Properties[$Name].Value
}

function Assert-NonEmptyString {
    param($Value, [string]$Context)
    if ($Value -isnot [string] -or [string]::IsNullOrWhiteSpace($Value)) {
        throw "$Context must be a non-empty string."
    }
    return $Value
}

function Assert-StringArray {
    param($Value, [string]$Context, [switch]$AllowEmpty)
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
    return $items
}

function Assert-ObjectArray {
    param($Value, [string]$Context)
    if ($null -eq $Value -or $Value -is [string] -or -not ($Value -is [System.Collections.IEnumerable])) {
        throw "$Context must be an array."
    }
    $items = @($Value)
    if ($items.Count -eq 0) {
        throw "$Context must not be empty."
    }
    foreach ($item in $items) {
        if ($null -eq $item -or $item -is [string] -or $item -is [System.Array]) {
            throw "$Context item must be an object."
        }
    }
    return $items
}

function Resolve-BundleRef {
    param([string]$Reference, [string]$Context)
    Assert-NonEmptyString -Value $Reference -Context $Context | Out-Null
    if ([System.IO.Path]::IsPathRooted($Reference)) {
        throw "$Context must be a relative path bounded inside the bundle root; absolute paths are not allowed."
    }
    if ($Reference -match '(^|[\\/])\.\.([\\/]|$)') {
        throw "$Context must be bounded inside the bundle root."
    }
    $resolved = [System.IO.Path]::GetFullPath((Join-Path $bundleRoot $Reference))
    $rootForPrefix = $bundleRoot.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
    $rootWithSeparator = $rootForPrefix + [System.IO.Path]::DirectorySeparatorChar
    $isBundleRoot = $resolved.Equals($rootForPrefix, [System.StringComparison]::OrdinalIgnoreCase)
    $isInsideBundleRoot = $resolved.StartsWith($rootWithSeparator, [System.StringComparison]::OrdinalIgnoreCase)
    if (-not ($isBundleRoot -or $isInsideBundleRoot)) {
        throw "$Context must stay inside the bundle root."
    }
    if (-not (Test-Path -LiteralPath $resolved)) {
        throw "$Context '$Reference' does not exist."
    }
    return $resolved
}

foreach ($field in $contract.required_fields) {
    Get-RequiredProperty -Object $bundle -Name $field -Context "R12 external replay bundle" | Out-Null
}

if ($bundle.contract_version -ne $contract.contract_version) {
    throw "R12 external replay bundle contract_version must be '$($contract.contract_version)'."
}
if ($bundle.artifact_type -ne $contract.artifact_type) {
    throw "R12 external replay bundle artifact_type must be '$($contract.artifact_type)'."
}
if ($bundle.repository -ne "AIOffice_V2") {
    throw "R12 external replay bundle repository must be AIOffice_V2."
}
if ($bundle.branch -ne $contract.required_branch) {
    throw "R12 external replay bundle branch must be '$($contract.required_branch)'."
}
foreach ($shaField in @("expected_head", "expected_tree", "observed_head", "observed_tree")) {
    $sha = Assert-NonEmptyString -Value $bundle.$shaField -Context "R12 external replay bundle $shaField"
    if ($sha -notmatch $gitObjectPattern) {
        throw "R12 external replay bundle $shaField must be a git object SHA."
    }
}
Assert-NonEmptyString -Value $bundle.workflow_name -Context "R12 external replay bundle workflow_name" | Out-Null
$runId = [string](Get-RequiredProperty -Object $bundle -Name "run_id" -Context "R12 external replay bundle")
$runUrl = [string](Get-RequiredProperty -Object $bundle -Name "run_url" -Context "R12 external replay bundle")
Assert-NonEmptyString -Value $bundle.runner_os -Context "R12 external replay bundle runner_os" | Out-Null
Assert-NonEmptyString -Value $bundle.runner_name_or_kind -Context "R12 external replay bundle runner_name_or_kind" | Out-Null
Assert-NonEmptyString -Value $bundle.replay_scope -Context "R12 external replay bundle replay_scope" | Out-Null
$earlyAggregateVerdict = [string](Get-RequiredProperty -Object $bundle -Name "aggregate_verdict" -Context "R12 external replay bundle")
$earlyHeadTreeMatch = ($bundle.expected_head -eq $bundle.observed_head -and $bundle.expected_tree -eq $bundle.observed_tree)
if ($earlyAggregateVerdict -eq "passed") {
    if (-not $earlyHeadTreeMatch) {
        throw "R12 external replay bundle observed head/tree must match expected head/tree for pass."
    }
    if ([string]::IsNullOrWhiteSpace($runId) -or $runUrl -notmatch '^https://github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+/actions/runs/[0-9]+') {
        throw "R12 external replay bundle local-only bundle cannot be presented as external run proof without concrete run_id/run_url."
    }
}

foreach ($cleanField in @("clean_status_before", "clean_status_after")) {
    $cleanStatus = Get-RequiredProperty -Object $bundle -Name $cleanField -Context "R12 external replay bundle"
    foreach ($requiredCleanField in $contract.clean_status_required_fields) {
        Get-RequiredProperty -Object $cleanStatus -Name $requiredCleanField -Context "R12 external replay bundle $cleanField" | Out-Null
    }
    Assert-NonEmptyString -Value $cleanStatus.status -Context "R12 external replay bundle $cleanField.status" | Out-Null
    Resolve-BundleRef -Reference $cleanStatus.evidence_ref -Context "R12 external replay bundle $cleanField.evidence_ref" | Out-Null
}

$commandResults = Assert-ObjectArray -Value $bundle.command_results -Context "R12 external replay bundle command_results"
$seenCommandIds = @{}
$nonzeroCommands = @()
foreach ($commandResult in $commandResults) {
    foreach ($requiredCommandField in $contract.command_result_required_fields) {
        Get-RequiredProperty -Object $commandResult -Name $requiredCommandField -Context "R12 external replay bundle command_result" | Out-Null
    }
    $commandId = Assert-NonEmptyString -Value $commandResult.command_id -Context "R12 external replay bundle command_result.command_id"
    if ($seenCommandIds.ContainsKey($commandId)) {
        throw "R12 external replay bundle command_results contains duplicate command_id '$commandId'."
    }
    $seenCommandIds[$commandId] = $true
    Assert-NonEmptyString -Value $commandResult.command -Context "R12 external replay bundle command_result.command" | Out-Null
    if ($commandResult.exit_code -isnot [int] -and $commandResult.exit_code -isnot [long]) {
        throw "R12 external replay bundle command_result.exit_code must be an integer."
    }
    $verdict = Assert-NonEmptyString -Value $commandResult.verdict -Context "R12 external replay bundle command_result.verdict"
    if (@("passed", "failed", "blocked") -notcontains $verdict) {
        throw "R12 external replay bundle command_result.verdict must be passed, failed, or blocked."
    }
    if ($commandResult.exit_code -ne 0) {
        $nonzeroCommands += $commandId
    }
    if ($verdict -eq "passed" -and $commandResult.exit_code -ne 0) {
        throw "R12 external replay bundle failed command cannot be presented as pass."
    }
    Resolve-BundleRef -Reference $commandResult.stdout_ref -Context "R12 external replay bundle command_result.stdout_ref" | Out-Null
    Resolve-BundleRef -Reference $commandResult.stderr_ref -Context "R12 external replay bundle command_result.stderr_ref" | Out-Null
    Resolve-BundleRef -Reference $commandResult.exit_code_ref -Context "R12 external replay bundle command_result.exit_code_ref" | Out-Null
}

foreach ($requiredCommandId in $contract.required_command_ids) {
    if (-not $seenCommandIds.ContainsKey($requiredCommandId)) {
        throw "R12 external replay bundle is missing required command result '$requiredCommandId'."
    }
}

Assert-NonEmptyString -Value $bundle.artifact_name -Context "R12 external replay bundle artifact_name" | Out-Null
$artifactFiles = Assert-StringArray -Value $bundle.artifact_files -Context "R12 external replay bundle artifact_files"
foreach ($artifactFile in $artifactFiles) {
    if ($artifactFile -match '(^|[\\/])\.\.([\\/]|$)') {
        throw "R12 external replay bundle artifact_files must be bounded paths."
    }
}

$aggregateVerdict = Assert-NonEmptyString -Value $bundle.aggregate_verdict -Context "R12 external replay bundle aggregate_verdict"
if ($contract.allowed_aggregate_verdicts -notcontains $aggregateVerdict) {
    throw "R12 external replay bundle aggregate_verdict must be one of $($contract.allowed_aggregate_verdicts -join ', ')."
}
$refusalReasons = Assert-StringArray -Value $bundle.refusal_reasons -Context "R12 external replay bundle refusal_reasons" -AllowEmpty
$createdAtUtc = Assert-NonEmptyString -Value $bundle.created_at_utc -Context "R12 external replay bundle created_at_utc"
if ($createdAtUtc -notmatch $timestampPattern) {
    throw "R12 external replay bundle created_at_utc must be a UTC timestamp."
}
$nonClaims = Assert-StringArray -Value $bundle.non_claims -Context "R12 external replay bundle non_claims"
foreach ($requiredNonClaim in $contract.required_non_claims) {
    if ($nonClaims -notcontains $requiredNonClaim) {
        throw "R12 external replay bundle non_claims must include '$requiredNonClaim'."
    }
}

$headTreeMatch = ($bundle.expected_head -eq $bundle.observed_head -and $bundle.expected_tree -eq $bundle.observed_tree)
if ($aggregateVerdict -eq "passed") {
    if (-not $headTreeMatch) {
        throw "R12 external replay bundle observed head/tree must match expected head/tree for pass."
    }
    if ($nonzeroCommands.Count -gt 0) {
        throw "R12 external replay bundle nonzero command exit code makes aggregate verdict fail."
    }
    if ($refusalReasons.Count -ne 0) {
        throw "R12 external replay bundle passed aggregate verdict requires empty refusal_reasons."
    }
    Assert-NonEmptyString -Value $runId -Context "R12 external replay bundle run_id" | Out-Null
    Assert-NonEmptyString -Value $runUrl -Context "R12 external replay bundle run_url" | Out-Null
    if ($runUrl -notmatch '^https://github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+/actions/runs/[0-9]+') {
        throw "R12 external replay bundle local-only bundle cannot be presented as external run proof without concrete run_url."
    }
}
else {
    if ($refusalReasons.Count -eq 0) {
        throw "R12 external replay bundle failed or blocked aggregate verdict requires refusal_reasons."
    }
}

Write-Output ("VALID: R12 external replay bundle for branch '{0}' observed head '{1}' tree '{2}' with {3} command result(s), aggregate verdict '{4}', and artifact '{5}'." -f $bundle.branch, $bundle.observed_head, $bundle.observed_tree, $commandResults.Count, $aggregateVerdict, $bundle.artifact_name)
