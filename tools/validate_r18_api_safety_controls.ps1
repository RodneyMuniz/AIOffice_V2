$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18ApiSafetyControls.psm1"
Import-Module $modulePath -Force

$result = Test-R18ApiSafetyControls -RepositoryRoot $repoRoot

Write-Output "R18-022 safety, secrets, budget, and token controls validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("API enabled: {0}" -f $result.ApiEnabled)
Write-Output ("Operator approval required: {0}" -f $result.OperatorApprovalRequired)
Write-Output ("Codex API invoked: {0}" -f $result.RuntimeFlags.codex_api_invoked)
Write-Output ("OpenAI API invoked: {0}" -f $result.RuntimeFlags.openai_api_invoked)
