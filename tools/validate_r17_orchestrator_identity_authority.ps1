$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17OrchestratorIdentityAuthority.psm1"
$module = Import-Module $modulePath -Force -PassThru
$testArtifacts = $module.ExportedCommands["Test-R17OrchestratorIdentityAuthorityArtifacts"]

$result = & $testArtifacts -RepositoryRoot $repoRoot
$result | ConvertTo-Json -Depth 20
