[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$PacketPath,
    [string]$TaxonomyPath = "state\knowledge\r15_artifact_classification_taxonomy.json",
    [string]$KnowledgeIndexPath = "state\knowledge\r15_repo_knowledge_index.json",
    [string]$AgentIdentityPacketPath = "state\agents\r15_agent_identity_packet.json",
    [string]$AgentMemoryScopePath = "state\agents\r15_agent_memory_scope.json",
    [string]$RaciStateTransitionMatrixPath = "state\agents\r15_raci_state_transition_matrix.json",
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R15CardReentryPacket.psm1") -Force -PassThru
$testPacket = $module.ExportedCommands["Test-R15CardReentryPacket"]

try {
    $result = & $testPacket -PacketPath $PacketPath -TaxonomyPath $TaxonomyPath -KnowledgeIndexPath $KnowledgeIndexPath -AgentIdentityPacketPath $AgentIdentityPacketPath -AgentMemoryScopePath $AgentMemoryScopePath -RaciStateTransitionMatrixPath $RaciStateTransitionMatrixPath -RepositoryRoot $RepositoryRoot
    Write-Output ("VALID: R15 card re-entry packet model '{0}' passed with {1} packet records, model_only={2}, card_reentry_runtime_implemented={3}, board_routing_runtime_implemented={4}, actual_agents_implemented={5}, classification_reentry_dry_run_executed={6}, product_runtime_implemented={7}, integration_runtime_implemented={8}." -f $result.PacketModelId, $result.PacketCount, $result.ModelOnly, $result.CardReentryRuntimeImplemented, $result.BoardRoutingRuntimeImplemented, $result.ActualAgentsImplemented, $result.ClassificationReentryDryRunExecuted, $result.ProductRuntimeImplemented, $result.IntegrationRuntimeImplemented)
    exit 0
}
catch {
    Write-Output ("INVALID: R15 card re-entry packet model failed validation. {0}" -f $_.Exception.Message)
    exit 1
}
