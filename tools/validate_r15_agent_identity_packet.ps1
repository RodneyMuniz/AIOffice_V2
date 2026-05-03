[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$PacketPath,
    [string]$TaxonomyPath = "state\knowledge\r15_artifact_classification_taxonomy.json",
    [string]$KnowledgeIndexPath = "state\knowledge\r15_repo_knowledge_index.json"
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R15AgentIdentityPacket.psm1") -Force -PassThru
$testPacket = $module.ExportedCommands["Test-R15AgentIdentityPacket"]

try {
    $result = & $testPacket -PacketPath $PacketPath -TaxonomyPath $TaxonomyPath -KnowledgeIndexPath $KnowledgeIndexPath
    Write-Output ("VALID: R15 agent identity packet set '{0}' passed with {1} roles, model_only={2}, runtime_agents_implemented={3}, true_multi_agent_execution={4}, direct_agent_access_runtime={5}." -f $result.PacketSetId, $result.RoleCount, $result.ModelOnly, $result.RuntimeAgentsImplemented, $result.TrueMultiAgentExecution, $result.DirectAgentAccessRuntime)
    exit 0
}
catch {
    Write-Output ("INVALID: R15 agent identity packet set failed validation. {0}" -f $_.Exception.Message)
    exit 1
}
