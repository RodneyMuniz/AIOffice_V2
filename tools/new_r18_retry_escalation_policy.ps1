$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18RetryEscalationPolicy.psm1"
Import-Module $modulePath -Force

$result = New-R18RetryEscalationPolicyArtifacts -RepositoryRoot $repoRoot

Write-Output "R18-015 retry escalation policy foundation artifacts generated."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Scenario count: {0}" -f $result.ScenarioCount)
Write-Output ("Decision count: {0}" -f $result.DecisionCount)
Write-Output "Retry/escalation decisions are deterministic policy artifacts only and were not executed."
