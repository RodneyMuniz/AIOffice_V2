[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ScopePath,
    [string]$TaxonomyPath = "state\knowledge\r15_artifact_classification_taxonomy.json",
    [string]$KnowledgeIndexPath = "state\knowledge\r15_repo_knowledge_index.json",
    [string]$AgentIdentityPacketPath = "state\agents\r15_agent_identity_packet.json",
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "R15AgentMemoryScope.psm1") -Force -PassThru
$testScope = $module.ExportedCommands["Test-R15AgentMemoryScope"]

try {
    $result = & $testScope -ScopePath $ScopePath -TaxonomyPath $TaxonomyPath -KnowledgeIndexPath $KnowledgeIndexPath -AgentIdentityPacketPath $AgentIdentityPacketPath -RepositoryRoot $RepositoryRoot
    Write-Output ("VALID: R15 agent memory scope model '{0}' passed with {1} memory scopes, {2} role mappings, model_only={3}, persistent_memory_engine_implemented={4}, runtime_memory_loading_implemented={5}, retrieval_engine_implemented={6}, vector_search_implemented={7}, direct_agent_access_runtime={8}, true_multi_agent_execution={9}." -f $result.MemoryScopeModelId, $result.ScopeCount, $result.RoleAccessCount, $result.ModelOnly, $result.PersistentMemoryEngineImplemented, $result.RuntimeMemoryLoadingImplemented, $result.RetrievalEngineImplemented, $result.VectorSearchImplemented, $result.DirectAgentAccessRuntime, $result.TrueMultiAgentExecution)
    exit 0
}
catch {
    Write-Output ("INVALID: R15 agent memory scope model failed validation. {0}" -f $_.Exception.Message)
    exit 1
}
