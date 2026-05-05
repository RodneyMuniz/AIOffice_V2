[CmdletBinding()]
param(
    [string]$OutputPath = "state\context\r16_context_load_plan.json",
    [string]$RoleMemoryPacksPath = "state\memory\r16_role_memory_packs.json",
    [string]$ArtifactMapPath = "state\artifacts\r16_artifact_map.json",
    [string]$AuditMapPath = "state\audit\r16_r15_r16_audit_map.json",
    [string]$CheckReportPath = "state\artifacts\r16_artifact_audit_map_check_report.json",
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R16ContextLoadPlanner.psm1") -Force -PassThru
$newPlan = $module.ExportedCommands["New-R16ContextLoadPlan"]

try {
    $result = & $newPlan -OutputPath $OutputPath -RoleMemoryPacksPath $RoleMemoryPacksPath -ArtifactMapPath $ArtifactMapPath -AuditMapPath $AuditMapPath -CheckReportPath $CheckReportPath -RepositoryRoot $RepositoryRoot
    Write-Output ("GENERATED: R16 context-load plan '{0}' wrote '{1}' with {2} load groups and {3} exact load items; active_through={4}, planned_range={5}..{6}, verdict={7}. The generated plan is a committed state artifact only, not runtime memory, not retrieval/vector runtime, not a budget estimator, not an over-budget validator, not a role-run envelope, not a handoff packet, and not workflow execution." -f $result.PlanId, $result.OutputPath, $result.LoadGroupCount, $result.LoadItemCount, $result.ActiveThroughTask, $result.PlannedTaskStart, $result.PlannedTaskEnd, $result.AggregateVerdict)
    exit 0
}
catch {
    Write-Output ("FAILED: R16 context-load plan generation failed closed. {0}" -f $_.Exception.Message)
    exit 1
}
