$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17A2aDispatcher.psm1"
Import-Module $modulePath -Force

$result = New-R17A2aDispatcherArtifacts -RepositoryRoot $repoRoot

Write-Output "Generated R17-021 bounded A2A dispatcher foundation artifacts."
Write-Output ("Dispatcher contract: {0}" -f $result.Contract)
Write-Output ("Route set: {0}" -f $result.Routes)
Write-Output ("Dispatch log: {0}" -f $result.DispatchLog)
Write-Output ("Check report: {0}" -f $result.CheckReport)
Write-Output ("UI snapshot: {0}" -f $result.UiSnapshot)
Write-Output ("Fixture root: {0}" -f $result.FixtureRoot)
Write-Output ("Proof root: {0}" -f $result.ProofRoot)
Write-Output ("Dispatch candidates: {0}" -f $result.RouteCount)
Write-Output ("Valid seed routes not dispatched: {0}" -f $result.ValidSeedRouteCount)
Write-Output ("Invalid fixtures: {0}" -f $result.InvalidFixtureCount)
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
