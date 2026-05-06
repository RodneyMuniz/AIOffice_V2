[CmdletBinding()]
param(
    [string]$Path = "state\workflow\r16_role_run_envelopes.json",
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16RoleRunEnvelopeGenerator.psm1") -Force -PassThru
$testEnvelopes = $module.ExportedCommands["Test-R16RoleRunEnvelopes"]

try {
    $result = & $testEnvelopes -Path $Path -RepositoryRoot $RepositoryRoot
    Write-Output ("PASS: R16 role-run envelopes '{0}' are valid; active_through={1}, planned_range={2}..{3}, envelopes={4}, blocked={5}, executable={6}, aggregate_verdict={7}, guard_verdict={8}, estimated_tokens_upper_bound={9}, max_estimated_tokens_upper_bound={10}. This is bounded state-artifact generation only; all envelopes are non-executable under failed_closed_over_budget and no runtime memory, retrieval/vector runtime, product runtime, autonomous agents, external integrations, RACI transition gate, handoff packet, workflow drill, solved Codex compaction, or solved Codex reliability is claimed." -f $result.ArtifactId, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd, $result.EnvelopeCount, $result.BlockedEnvelopeCount, $result.ExecutableEnvelopeCount, $result.AggregateVerdict, $result.BudgetGuardVerdict, $result.EstimatedTokensUpperBound, $result.MaxEstimatedTokensUpperBound)
    exit 0
}
catch {
    Write-Output ("FAIL: R16 role-run envelopes are invalid. {0}" -f $_.Exception.Message)
    exit 1
}
