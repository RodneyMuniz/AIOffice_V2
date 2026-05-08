$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17AgentRegistry.psm1"
Import-Module $modulePath -Force

$result = New-R17AgentRegistryArtifacts -RepositoryRoot $repoRoot

Write-Output "Generated R17-012 agent registry and identity packet artifacts."
Write-Output ("Registry contract: {0}" -f $result.RegistryContract)
Write-Output ("Identity packet contract: {0}" -f $result.IdentityContract)
Write-Output ("Registry state: {0}" -f $result.Registry)
Write-Output ("Identity root: {0}" -f $result.IdentityRoot)
Write-Output ("Check report: {0}" -f $result.CheckReport)
Write-Output ("UI snapshot: {0}" -f $result.UiSnapshot)
Write-Output ("Fixture root: {0}" -f $result.FixtureRoot)
Write-Output ("Proof-review root: {0}" -f $result.ProofRoot)
Write-Output ("Required agents: {0}" -f $result.RequiredAgentCount)
Write-Output ("Identity packets: {0}" -f $result.IdentityPacketCount)
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
