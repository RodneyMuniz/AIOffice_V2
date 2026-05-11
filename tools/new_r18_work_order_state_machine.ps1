$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R18WorkOrderStateMachine.psm1"
Import-Module $modulePath -Force

$result = New-R18WorkOrderStateMachineArtifacts -RepositoryRoot $repoRoot

Write-Output "Generated R18-008 work-order state machine foundation artifacts."
Write-Output ("Contract: {0}" -f $result.Contract)
Write-Output ("State machine: {0}" -f $result.StateMachine)
Write-Output ("Transition catalog: {0}" -f $result.TransitionCatalog)
Write-Output ("Seed root: {0}" -f $result.SeedRoot)
Write-Output ("Transition root: {0}" -f $result.TransitionRoot)
Write-Output ("Check report: {0}" -f $result.CheckReport)
Write-Output ("UI snapshot: {0}" -f $result.UiSnapshot)
Write-Output ("Fixture root: {0}" -f $result.FixtureRoot)
Write-Output ("Proof root: {0}" -f $result.ProofRoot)
Write-Output ("Required state count: {0}" -f $result.RequiredStateCount)
Write-Output ("Required transition count: {0}" -f $result.RequiredTransitionCount)
Write-Output ("Generated seed count: {0}" -f $result.GeneratedSeedCount)
Write-Output ("Generated transition evaluation count: {0}" -f $result.GeneratedTransitionEvaluationCount)
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
