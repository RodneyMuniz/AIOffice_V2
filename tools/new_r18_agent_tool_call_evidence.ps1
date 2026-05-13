$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18AgentToolCallEvidence.psm1"
Import-Module $modulePath -Force

$result = New-R18AgentToolCallEvidenceArtifacts -RepositoryRoot $repoRoot

Write-Output "R18-021 agent invocation and tool-call evidence model foundation artifacts generated."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Ledger record count: {0}" -f $result.RecordCount)
Write-Output ("Invalid fixture count: {0}" -f $result.InvalidFixtureCount)
Write-Output "Artifacts are deterministic evidence-shape artifacts only; no live agent invocation, tool-call execution, API invocation, recovery action, release gate execution, CI replay, product runtime, or no-manual-prompt-transfer success occurred."
