param(
    [string]$SnapshotPath = "state/ui/r17_kanban_mvp/r17_card_detail_snapshot.json"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R17CardDetailDrawer.psm1") -Force -PassThru
$testR17CardDetailDrawer = $module.ExportedCommands["Test-R17CardDetailDrawer"]

$result = & $testR17CardDetailDrawer -RepositoryRoot $repoRoot -SnapshotPath $SnapshotPath
$result | ConvertTo-Json -Depth 20
