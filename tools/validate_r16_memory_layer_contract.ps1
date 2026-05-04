[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ContractPath,
    [string]$SamplePath,
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16MemoryLayerContract.psm1") -Force -PassThru
$testContract = $module.ExportedCommands["Test-R16MemoryLayerContract"]
$testSample = $module.ExportedCommands["Test-R16MemoryLayerContractSample"]

try {
    $result = & $testContract -ContractPath $ContractPath -RepositoryRoot $RepositoryRoot
    $sampleSuffix = ""
    if (-not [string]::IsNullOrWhiteSpace($SamplePath)) {
        $sampleResult = & $testSample -SamplePath $SamplePath -ContractPath $ContractPath -RepositoryRoot $RepositoryRoot
        $sampleSuffix = (" Sample '{0}' passed with {1} model-only records." -f $sampleResult.SamplePath, $sampleResult.RecordCount)
    }

    Write-Output ("VALID: R16 memory layer contract '{0}' passed with {1} layer types, {2} authority classes, active_through={3}, planned_range={4}..{5}; contract is model-only and not runtime memory.{6}" -f $result.ContractId, $result.LayerTypeCount, $result.AuthorityClassCount, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd, $sampleSuffix)
    exit 0
}
catch {
    Write-Output ("INVALID: R16 memory layer contract failed validation. {0}" -f $_.Exception.Message)
    exit 1
}
