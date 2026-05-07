param(
    [string]$SnapshotPath = "state/ui/r17_kanban_mvp/r17_kanban_snapshot.json"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R17KanbanMvp.psm1") -Force -PassThru
$testR17KanbanMvp = $module.ExportedCommands["Test-R17KanbanMvp"]

$result = & $testR17KanbanMvp -RepositoryRoot $repoRoot -SnapshotPath $SnapshotPath
$result | ConvertTo-Json -Depth 20
