[CmdletBinding()]
param(
    [string]$ContractPath = "contracts\artifacts\r16_artifact_map.contract.json",
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16ArtifactMapContract.psm1") -Force -PassThru
$testContract = $module.ExportedCommands["Test-R16ArtifactMapContract"]

try {
    $result = & $testContract -ContractPath $ContractPath -RepositoryRoot $RepositoryRoot

    Write-Output ("VALID: R16 artifact map contract '{0}' passed with classes={1}, roles={2}, authority_classes={3}, evidence_kinds={4}, lifecycle_states={5}, proof_statuses={6}, active_through={7}, planned_range={8}..{9}; contract is model-only and no generated artifact map or generator is claimed." -f $result.ContractId, $result.ArtifactClassCount, $result.ArtifactRoleCount, $result.AuthorityClassCount, $result.EvidenceKindCount, $result.LifecycleStateCount, $result.ProofStatusCount, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd)
    exit 0
}
catch {
    Write-Output ("INVALID: R16 artifact map contract failed validation. {0}" -f $_.Exception.Message)
    exit 1
}
