$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $PSScriptRoot "R17EventEvidenceSummary.psm1"
Import-Module $modulePath -Force

$result = Test-R17EventEvidenceSummary -RepositoryRoot $repoRoot
$result | Format-List
