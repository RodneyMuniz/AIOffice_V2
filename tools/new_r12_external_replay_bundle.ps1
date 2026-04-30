[CmdletBinding()]
param(
    [string]$Repository = "AIOffice_V2",
    [Parameter(Mandatory = $true)]
    [string]$Branch,
    [Parameter(Mandatory = $true)]
    [string]$ExpectedHead,
    [Parameter(Mandatory = $true)]
    [string]$ExpectedTree,
    [Parameter(Mandatory = $true)]
    [string]$ObservedHead,
    [Parameter(Mandatory = $true)]
    [string]$ObservedTree,
    [Parameter(Mandatory = $true)]
    [string]$WorkflowName,
    [Parameter(Mandatory = $true)]
    [string]$RunId,
    [Parameter(Mandatory = $true)]
    [string]$RunUrl,
    [Parameter(Mandatory = $true)]
    [string]$RunnerOs,
    [Parameter(Mandatory = $true)]
    [string]$RunnerNameOrKind,
    [Parameter(Mandatory = $true)]
    [string]$ReplayScope,
    [Parameter(Mandatory = $true)]
    [string]$CleanStatusBefore,
    [Parameter(Mandatory = $true)]
    [string]$CleanStatusAfter,
    [Parameter(Mandatory = $true)]
    [string]$CommandResultsPath,
    [Parameter(Mandatory = $true)]
    [string]$ArtifactName,
    [Parameter(Mandatory = $true)]
    [string]$ArtifactFilesJson,
    [Parameter(Mandatory = $true)]
    [string]$OutputPath
)

$ErrorActionPreference = "Stop"
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$rawCommandResults = Get-Content -LiteralPath $CommandResultsPath -Raw
$trimmedCommandResults = $rawCommandResults.TrimStart([char]0xFEFF, [char]0x20, [char]0x09, [char]0x0A, [char]0x0D)
if ($trimmedCommandResults.StartsWith("{")) {
    $commandResults = Read-SingleJsonObject -Path $CommandResultsPath -Label "R12 external replay command result wrapper"
    if (-not ($commandResults.PSObject.Properties.Name -contains "command_results")) {
        throw "R12 external replay command result wrapper must include command_results when the root is an object."
    }
    $commandResultsArray = @($commandResults.command_results)
}
else {
    $parsed = ConvertFrom-Json -InputObject $rawCommandResults
    $commandResultsArray = @($parsed)
}

$artifactFiles = @((ConvertFrom-Json -InputObject $ArtifactFilesJson))
$nonzero = @($commandResultsArray | Where-Object { $_.exit_code -ne 0 })
$headTreeMatch = ($ExpectedHead -eq $ObservedHead -and $ExpectedTree -eq $ObservedTree)
$aggregateVerdict = if ($nonzero.Count -eq 0 -and $headTreeMatch) { "passed" } else { "failed" }
$refusalReasons = @()
if (-not $headTreeMatch) {
    $refusalReasons += "observed head/tree did not match expected head/tree"
}
foreach ($failedCommand in $nonzero) {
    $refusalReasons += ("command '{0}' exited {1}" -f $failedCommand.command_id, $failedCommand.exit_code)
}

$bundle = [pscustomobject]@{
    contract_version = "v1"
    artifact_type = "r12_external_replay_bundle"
    repository = $Repository
    branch = $Branch
    expected_head = $ExpectedHead
    expected_tree = $ExpectedTree
    observed_head = $ObservedHead
    observed_tree = $ObservedTree
    workflow_name = $WorkflowName
    run_id = $RunId
    run_url = $RunUrl
    runner_os = $RunnerOs
    runner_name_or_kind = $RunnerNameOrKind
    replay_scope = $ReplayScope
    clean_status_before = [pscustomobject]@{
        status = "clean"
        evidence_ref = $CleanStatusBefore
    }
    clean_status_after = [pscustomobject]@{
        status = "clean"
        evidence_ref = $CleanStatusAfter
    }
    command_results = $commandResultsArray
    artifact_name = $ArtifactName
    artifact_files = $artifactFiles
    aggregate_verdict = $aggregateVerdict
    refusal_reasons = $refusalReasons
    created_at_utc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture)
    non_claims = @(
        "no broad CI/product coverage",
        "no production CI",
        "no R12 final-state replay",
        "no R12 closeout",
        "no R12 value-gate delivery yet"
    )
}

$directory = Split-Path -Parent $OutputPath
if (-not [string]::IsNullOrWhiteSpace($directory)) {
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
}
$bundle | ConvertTo-Json -Depth 80 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
Write-Output ("WROTE: R12 external replay bundle '{0}' with aggregate verdict '{1}'." -f $OutputPath, $aggregateVerdict)
