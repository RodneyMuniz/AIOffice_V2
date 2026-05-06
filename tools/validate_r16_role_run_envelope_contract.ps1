[CmdletBinding()]
param(
    [string]$Path = "contracts\workflow\r16_role_run_envelope.contract.json",
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16RoleRunEnvelopeContract.psm1") -Force -PassThru
$testContract = $module.ExportedCommands["Test-R16RoleRunEnvelopeContract"]

try {
    $result = & $testContract -Path $Path -RepositoryRoot $RepositoryRoot
    Write-Output ("PASS: R16 role-run envelope contract '{0}' is valid; source_task={1}, active_through={2}, planned_range={3}..{4}, roles={5}, dependency_refs={6}, guard_verdict={7}, guard_blocks_execution={8}. This is contract/model proof only: no generated role-run envelopes, no role-run envelope generator, no RACI transition gate, no handoff packet, no workflow drill, no runtime memory, no retrieval/vector runtime, no product runtime, no autonomous agents, no external integrations, and no solved Codex compaction or reliability." -f $result.ContractId, $result.SourceTask, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd, $result.RoleCount, $result.DependencyRefCount, $result.GuardVerdict, $result.GuardBlocksExecution)
    exit 0
}
catch {
    Write-Output ("FAIL: R16 role-run envelope contract is invalid. {0}" -f $_.Exception.Message)
    exit 1
}
