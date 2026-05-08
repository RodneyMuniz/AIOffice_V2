$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17OrchestratorIdentityAuthority.psm1"
$module = Import-Module $modulePath -Force -PassThru
$newArtifacts = $module.ExportedCommands["New-R17OrchestratorIdentityAuthorityArtifacts"]

$result = & $newArtifacts -RepositoryRoot $repoRoot
$result | ConvertTo-Json -Depth 20
