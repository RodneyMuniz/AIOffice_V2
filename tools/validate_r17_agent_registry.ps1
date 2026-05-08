$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17AgentRegistry.psm1"
Import-Module $modulePath -Force

$result = Test-R17AgentRegistry -RepositoryRoot $repoRoot

Write-Output "R17-012 agent registry validation passed."
Write-Output ("Aggregate verdict: {0}" -f $result.AggregateVerdict)
Write-Output ("Required agent count: {0}" -f $result.RequiredAgentCount)
Write-Output ("Identity packet count: {0}" -f $result.IdentityPacketCount)
Write-Output ("Agent IDs: {0}" -f (@($result.AgentIds) -join ", "))
Write-Output ("Runtime agent invocation implemented: {0}" -f $result.RuntimeAgentInvocationImplemented)
Write-Output ("A2A runtime implemented: {0}" -f $result.A2aRuntimeImplemented)
Write-Output ("Autonomous agent implemented: {0}" -f $result.AutonomousAgentImplemented)
Write-Output ("External API calls implemented: {0}" -f $result.ExternalApiCallsImplemented)
Write-Output ("Dev output claimed: {0}" -f $result.DevOutputClaimed)
Write-Output ("QA result claimed: {0}" -f $result.QaResultClaimed)
Write-Output ("Audit verdict claimed: {0}" -f $result.AuditVerdictClaimed)
