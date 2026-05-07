$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R17CardDetailDrawer.psm1") -Force -PassThru
$newR17CardDetailDrawer = $module.ExportedCommands["New-R17CardDetailDrawer"]

$result = & $newR17CardDetailDrawer -RepositoryRoot $repoRoot
$result | ConvertTo-Json -Depth 20
