$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18OptionalApiAdapterStub.psm1"
Import-Module $modulePath -Force

$result = New-R18OptionalApiAdapterStubArtifacts -RepositoryRoot $repoRoot

Write-Output "R18-023 optional API adapter stub foundation artifacts generated."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Invalid fixture count: {0}" -f $result.InvalidFixtureCount)
Write-Output "Artifacts are deterministic disabled/dry-run stub evidence only; no Codex/OpenAI API invocation, live adapter runtime, live agent invocation, skill execution, tool-call execution, recovery action, release gate execution, CI replay, product runtime, or no-manual-prompt-transfer success occurred."
