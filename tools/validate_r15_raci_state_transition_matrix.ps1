[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$MatrixPath,
    [string]$TaxonomyPath = "state\knowledge\r15_artifact_classification_taxonomy.json",
    [string]$KnowledgeIndexPath = "state\knowledge\r15_repo_knowledge_index.json",
    [string]$AgentIdentityPacketPath = "state\agents\r15_agent_identity_packet.json",
    [string]$AgentMemoryScopePath = "state\agents\r15_agent_memory_scope.json",
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R15RaciStateTransitionMatrix.psm1") -Force -PassThru
$testMatrix = $module.ExportedCommands["Test-R15RaciStateTransitionMatrix"]

try {
    $result = & $testMatrix -MatrixPath $MatrixPath -TaxonomyPath $TaxonomyPath -KnowledgeIndexPath $KnowledgeIndexPath -AgentIdentityPacketPath $AgentIdentityPacketPath -AgentMemoryScopePath $AgentMemoryScopePath -RepositoryRoot $RepositoryRoot
    Write-Output ("VALID: R15 RACI state-transition matrix '{0}' passed with {1} states, {2} transitions, {3} prohibited transitions, model_only={4}, runtime_state_machine_implemented={5}, board_routing_runtime_implemented={6}, actual_agents_implemented={7}, card_reentry_packet_implemented={8}, product_runtime_implemented={9}, integration_runtime_implemented={10}." -f $result.MatrixId, $result.StateCount, $result.TransitionCount, $result.ProhibitedTransitionCount, $result.ModelOnly, $result.RuntimeStateMachineImplemented, $result.BoardRoutingRuntimeImplemented, $result.ActualAgentsImplemented, $result.CardReentryPacketImplemented, $result.ProductRuntimeImplemented, $result.IntegrationRuntimeImplemented)
    exit 0
}
catch {
    Write-Output ("INVALID: R15 RACI state-transition matrix failed validation. {0}" -f $_.Exception.Message)
    exit 1
}
