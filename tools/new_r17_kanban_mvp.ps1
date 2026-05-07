$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R17KanbanMvp.psm1") -Force -PassThru
$newR17KanbanMvp = $module.ExportedCommands["New-R17KanbanMvp"]

$result = & $newR17KanbanMvp -RepositoryRoot $repoRoot
$result | ConvertTo-Json -Depth 20
