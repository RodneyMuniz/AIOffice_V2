[CmdletBinding()]
param(
    [string]$OutputPath = "state\workflow\r16_role_run_envelopes.json",
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16RoleRunEnvelopeGenerator.psm1") -Force -PassThru
$newEnvelopes = $module.ExportedCommands["New-R16RoleRunEnvelopes"]

try {
    $result = & $newEnvelopes -OutputPath $OutputPath -RepositoryRoot $RepositoryRoot
    Write-Output ("GENERATED: R16 role-run envelopes '{0}' wrote '{1}' with envelopes={2}, blocked={3}, executable={4}, active_through={5}, planned_range={6}..{7}, aggregate_verdict={8}, guard_verdict={9}, estimated_tokens_upper_bound={10}, max_estimated_tokens_upper_bound={11}. Envelopes are committed state artifacts only and remain non-executable under failed_closed_over_budget; no RACI transition gate, handoff packet, workflow drill, runtime memory, product runtime, autonomous agents, or external integrations are claimed." -f $result.ArtifactId, $result.OutputPath, $result.EnvelopeCount, $result.BlockedEnvelopeCount, $result.ExecutableEnvelopeCount, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd, $result.AggregateVerdict, $result.BudgetGuardVerdict, $result.EstimatedTokensUpperBound, $result.MaxEstimatedTokensUpperBound)
    exit 0
}
catch {
    Write-Output ("FAILED: R16 role-run envelope generation failed closed. {0}" -f $_.Exception.Message)
    exit 1
}
