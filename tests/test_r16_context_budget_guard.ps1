$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
& (Join-Path $repoRoot "tools\test_r16_context_budget_guard.ps1")
