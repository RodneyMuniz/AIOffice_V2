$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18NewContextPromptGenerator.psm1"
Import-Module $modulePath -Force

$result = New-R18NewContextPromptArtifacts -RepositoryRoot $repoRoot

Write-Output "R18-014 new-context prompt generator foundation artifacts generated."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Prompt input count: {0}" -f $result.PromptInputCount)
Write-Output ("Prompt packet count: {0}" -f $result.PromptPacketCount)
Write-Output "Prompt packets are deterministic text artifacts only and were not executed."
