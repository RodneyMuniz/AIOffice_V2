[CmdletBinding()]
param(
    [string]$OutputPath = "state/cycles/r12_real_build_cycle/bootstrap/fresh_thread_restart_proof.json",
    [switch]$Overwrite
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "FreshThreadRestartProof.psm1") -Force -PassThru
$newProof = $module.ExportedCommands["New-FreshThreadRestartProof"]

$proof = & $newProof -OutputPath $OutputPath -Overwrite:$Overwrite
Write-Output ("PASS fresh-thread restart proof: {0} verdict {1} at {2}" -f $proof.proof_id, $proof.proof_verdict, $OutputPath)
