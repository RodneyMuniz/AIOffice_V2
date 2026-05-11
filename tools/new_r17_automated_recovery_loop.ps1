$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17AutomatedRecoveryLoop.psm1"
Import-Module $modulePath -Force

$result = New-R17AutomatedRecoveryLoopArtifacts -RepositoryRoot $repoRoot

Write-Output "Generated R17-027 automated recovery loop foundation artifacts."
Write-Output ("Contract: {0}" -f $result.Contract)
Write-Output ("Plan: {0}" -f $result.Plan)
Write-Output ("State machine: {0}" -f $result.StateMachine)
Write-Output ("Failure events: {0}" -f $result.FailureEvents)
Write-Output ("Continuation packets: {0}" -f $result.ContinuationPackets)
Write-Output ("New-context packets: {0}" -f $result.NewContextPackets)
Write-Output ("Check report: {0}" -f $result.CheckReport)
Write-Output ("Prompt packet root: {0}" -f $result.PromptPacketRoot)
Write-Output ("UI snapshot: {0}" -f $result.UiSnapshot)
Write-Output ("Fixture root: {0}" -f $result.FixtureRoot)
Write-Output ("Proof root: {0}" -f $result.ProofRoot)
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
