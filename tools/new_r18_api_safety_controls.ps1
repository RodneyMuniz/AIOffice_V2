$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18ApiSafetyControls.psm1"
Import-Module $modulePath -Force

$result = New-R18ApiSafetyControlsArtifacts -RepositoryRoot $repoRoot

Write-Output "R18-022 safety, secrets, budget, and token controls foundation artifacts generated."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Invalid fixture count: {0}" -f $result.InvalidFixtureCount)
Write-Output "Artifacts are deterministic control/policy/validation artifacts only; no Codex/OpenAI API invocation, live adapter runtime, live agent invocation, skill execution, tool-call execution, recovery action, release gate execution, CI replay, product runtime, or no-manual-prompt-transfer success occurred."
