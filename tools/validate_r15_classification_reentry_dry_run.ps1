[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$DryRunPath,
    [string]$TaxonomyPath = "state\knowledge\r15_artifact_classification_taxonomy.json",
    [string]$KnowledgeIndexPath = "state\knowledge\r15_repo_knowledge_index.json",
    [string]$AgentIdentityPacketPath = "state\agents\r15_agent_identity_packet.json",
    [string]$AgentMemoryScopePath = "state\agents\r15_agent_memory_scope.json",
    [string]$RaciStateTransitionMatrixPath = "state\agents\r15_raci_state_transition_matrix.json",
    [string]$CardReentryPacketPath = "state\agents\r15_card_reentry_packet.json"
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R15ClassificationReentryDryRun.psm1") -Force -PassThru
$testDryRun = $module.ExportedCommands["Test-R15ClassificationReentryDryRun"]

try {
    $result = & $testDryRun -DryRunPath $DryRunPath -TaxonomyPath $TaxonomyPath -KnowledgeIndexPath $KnowledgeIndexPath -AgentIdentityPacketPath $AgentIdentityPacketPath -AgentMemoryScopePath $AgentMemoryScopePath -RaciStateTransitionMatrixPath $RaciStateTransitionMatrixPath -CardReentryPacketPath $CardReentryPacketPath
    Write-Output ("VALID: R15 classification/re-entry dry run '{0}' passed with {1} target paths, {2} classifications, {3} index lookups, target agent '{4}', transition '{5}', verdict '{6}', full_repo_scan_executed={7}, runtime_agents_implemented={8}, card_reentry_runtime_implemented={9}, final_r15_proof_package_complete={10}, r16_opened={11}." -f $result.DryRunId, $result.TargetSlicePathCount, $result.ClassificationCount, $result.LookupCount, $result.TargetAgentId, $result.TransitionId, $result.AggregateVerdict, $result.FullRepoScanExecuted, $result.RuntimeAgentsImplemented, $result.CardReentryRuntimeImplemented, $result.FinalR15ProofPackageComplete, $result.R16Opened)
    exit 0
}
catch {
    Write-Output ("INVALID: R15 classification/re-entry dry run failed validation. {0}" -f $_.Exception.Message)
    exit 1
}
