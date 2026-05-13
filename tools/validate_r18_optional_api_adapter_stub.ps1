$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18OptionalApiAdapterStub.psm1"
Import-Module $modulePath -Force

$result = Test-R18OptionalApiAdapterStub -RepositoryRoot $repoRoot

Write-Output "R18-023 optional API adapter stub validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Adapter default mode: {0}" -f $result.AdapterDefaultMode)
Write-Output ("Live mode enabled: {0}" -f $result.LiveModeEnabled)
Write-Output ("Requested live outcome: {0}" -f $result.RequestedLiveOutcome)
Write-Output ("Codex API invoked: {0}" -f $result.RuntimeFlags.codex_api_invoked)
Write-Output ("OpenAI API invoked: {0}" -f $result.RuntimeFlags.openai_api_invoked)
