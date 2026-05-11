[CmdletBinding()]
param(
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
    $RepositoryRoot = Split-Path -Parent $RepositoryRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "StatusDocGate.psm1") -Force -PassThru
$testStatusDocGate = $module.ExportedCommands["Test-StatusDocGate"]

$validation = & $testStatusDocGate -RepositoryRoot $RepositoryRoot
$plannedSummary = if ($null -eq $validation.PlannedStart) {
    "no remaining planned R8 tasks"
}
elseif ($validation.PlannedStart -eq $validation.PlannedThrough) {
    ("{0} planned" -f ("R8-{0}" -f $validation.PlannedStart.ToString("000")))
}
else {
    ("R8-{0} through R8-{1} planned" -f $validation.PlannedStart.ToString("000"), $validation.PlannedThrough.ToString("000"))
}

if ($validation.R18Opened) {
    Write-Output ("VALID: status-doc gate records R17 accepted and closed with caveats through R17-{0} only, active milestone '{1}' through R18-{2}, R18-{3} through R18-{4} planned only, R18-002 agent cards as schema/seed governance artifacts only, R18-003 skill contracts as schema/seed governance artifacts only, R18-004 A2A handoff packets as schema/seed governance artifacts only, R18-005 role-to-skill permission matrix as governance/control artifact only, permission matrix not runtime enforcement, handoff packets not live A2A runtime, no A2A messages sent, no live agents invoked, no live skills executed, R18 runtime implementation not yet delivered, no API invocation, no live recovery runtime, no live A2A runtime, no local runner runtime, no automatic new-thread creation, no product runtime, no solved Codex compaction/reliability, no no-manual-prompt-transfer success, and no main merge." -f $validation.R17DoneThrough.ToString("000"), $validation.ActiveMilestone, $validation.R18DoneThrough.ToString("000"), $validation.R18PlannedStart.ToString("000"), $validation.R18PlannedThrough.ToString("000"))
}
elseif ($validation.R17Opened) {
    $r17PlannedSummary = if ($null -eq $validation.R17PlannedStart) {
        "no planned R17 successor task"
    }
    elseif ($validation.R17PlannedStart -eq $validation.R17PlannedThrough) {
        ("R17-{0} planned" -f $validation.R17PlannedStart.ToString("000"))
    }
    else {
        ("R17-{0} through R17-{1} planned" -f $validation.R17PlannedStart.ToString("000"), $validation.R17PlannedThrough.ToString("000"))
    }
    Write-Output ("VALID: status-doc gate records R8 closed with tasks through R8-{0} complete, most recently closed milestone '{1}', R10 through R10-{2} closed, R11 through R11-{3} closed, R12 through R12-{4} closed, R13 failed/partial through R13-{5} only, R14 accepted with caveats through R14-{6}, R15 accepted with caveats through R15-{7}, R16 complete through R16-{8}, and active milestone '{9}' through R17-{10} with {11}; R17-029 or later completion claims, R17 closeout without operator approval, R18 opening, live recovery-loop runtime, automatic new-thread creation, live execution harness runtime, harness pilot runtime execution, OpenAI API invocation, Codex API invocation, autonomous Codex invocation, live board mutation, runtime card creation, Orchestrator runtime, A2A runtime, autonomous-agent runtime, adapter-runtime, false Dev/QA/Audit output claims, executable handoff/transition, external integration, Kanban product runtime, product/production runtime, external audit acceptance, main merge, R13 closure, R14/R15 caveat removal, and solved-Codex claims are rejected." -f $validation.DoneThrough.ToString("000"), $validation.MostRecentlyClosedMilestone, $validation.R10DoneThrough.ToString("000"), $validation.R11DoneThrough.ToString("000"), $validation.R12DoneThrough.ToString("000"), $validation.R13DoneThrough.ToString("000"), $validation.R14DoneThrough.ToString("000"), $validation.R15DoneThrough.ToString("000"), $validation.R16DoneThrough.ToString("000"), $validation.ActiveMilestone, $validation.R17DoneThrough.ToString("000"), $r17PlannedSummary)
}
elseif ($validation.R16Opened) {
    $r16PlannedSummary = if ($null -eq $validation.R16PlannedStart) {
        "no planned R16 successor task"
    }
    elseif ($validation.R16PlannedStart -eq $validation.R16PlannedThrough) {
        ("R16-{0} planned" -f $validation.R16PlannedStart.ToString("000"))
    }
    else {
        ("R16-{0} through R16-{1} planned" -f $validation.R16PlannedStart.ToString("000"), $validation.R16PlannedThrough.ToString("000"))
    }
    Write-Output ("VALID: status-doc gate records R8 closed with tasks through R8-{0} complete, most recently closed milestone '{1}', R10 through R10-{2} closed, R11 through R11-{3} closed, R12 through R12-{4} closed, R13 failed/partial through R13-{5} only, R14 accepted with caveats through R14-{6}, R15 accepted with caveats through R15-{7}, and active milestone '{8}' through R16-{9} with {10}; R16-026 overclaims beyond candidate-only package support, executable/runtime role-run envelopes while the guard is failed_closed_over_budget, exact-provider token/billing claims, generated-baseline-memory-as-runtime, generated role memory packs treated as runtime memory or actual agents, role memory pack generator runtime overclaims, role memory pack model as actual agents, target-as-achieved KPI scoring, R16-027 or later tasks, R16 closure, R13 closure, R14/R15 caveat-removal, R13 partial-gate conversion, runtime, product UI, agent, artifact-map-runtime, artifact map contract-as-generated-map, audit map runtime/product/diff/context overclaims, context-load-plan runtime/budget overclaims, executable/runtime handoff, friction-metrics machine-proof/runtime overclaims, workflow-drill execution overclaims beyond bounded report artifacts, integration, retrieval/vector, persistent-memory runtime, main-merge, and solved-Codex claims are rejected while the R16-017 guard can fail closed on over-budget context plans." -f $validation.DoneThrough.ToString("000"), $validation.MostRecentlyClosedMilestone, $validation.R10DoneThrough.ToString("000"), $validation.R11DoneThrough.ToString("000"), $validation.R12DoneThrough.ToString("000"), $validation.R13DoneThrough.ToString("000"), $validation.R14DoneThrough.ToString("000"), $validation.R15DoneThrough.ToString("000"), $validation.ActiveMilestone, $validation.R16DoneThrough.ToString("000"), $r16PlannedSummary)
}
elseif ($validation.R15Opened) {
    $r15PlannedSummary = if ($null -eq $validation.R15PlannedStart) {
        "no planned R15 successor task"
    }
    elseif ($validation.R15PlannedStart -eq $validation.R15PlannedThrough) {
        ("R15-{0} planned" -f $validation.R15PlannedStart.ToString("000"))
    }
    else {
        ("R15-{0} through R15-{1} planned" -f $validation.R15PlannedStart.ToString("000"), $validation.R15PlannedThrough.ToString("000"))
    }
    Write-Output ("VALID: status-doc gate records R8 closed with tasks through R8-{0} complete, most recently closed milestone '{1}', R10 through R10-{2} closed, R11 through R11-{3} closed, R12 through R12-{4} closed, R13 failed/partial through R13-{5} only, R14 accepted/narrowly complete through R14-{6}, and active milestone '{7}' through R15-{8} with {9}, accepted with caveats by external audit at audited head d9685030a0556a528684d28367db83f4c72f7fc9 and audited tree 7529230df0c1f5bec3625ba654b035a2af824e9b as a bounded foundation milestone only, and no R16 opening." -f $validation.DoneThrough.ToString("000"), $validation.MostRecentlyClosedMilestone, $validation.R10DoneThrough.ToString("000"), $validation.R11DoneThrough.ToString("000"), $validation.R12DoneThrough.ToString("000"), $validation.R13DoneThrough.ToString("000"), $validation.R14DoneThrough.ToString("000"), $validation.ActiveMilestone, $validation.R15DoneThrough.ToString("000"), $r15PlannedSummary)
}
elseif ($validation.R14Opened) {
    Write-Output ("VALID: status-doc gate records R8 closed with tasks through R8-{0} complete, most recently closed milestone '{1}', R10 through R10-{2} closed, R11 through R11-{3} closed, R12 through R12-{4} closed, R13 failed/partial through R13-{5} only, and active milestone '{6}' through R14-{7} with no R15 opening." -f $validation.DoneThrough.ToString("000"), $validation.MostRecentlyClosedMilestone, $validation.R10DoneThrough.ToString("000"), $validation.R11DoneThrough.ToString("000"), $validation.R12DoneThrough.ToString("000"), $validation.R13DoneThrough.ToString("000"), $validation.ActiveMilestone, $validation.R14DoneThrough.ToString("000"))
}
elseif ($validation.R13Opened) {
    $r13PlannedSummary = if ($null -eq $validation.R13PlannedStart) {
        "no planned R13 successor task"
    }
    elseif ($validation.R13PlannedStart -eq $validation.R13PlannedThrough) {
        ("R13-{0} planned" -f $validation.R13PlannedStart.ToString("000"))
    }
    else {
        ("R13-{0} through R13-{1} planned" -f $validation.R13PlannedStart.ToString("000"), $validation.R13PlannedThrough.ToString("000"))
    }

    Write-Output ("VALID: status-doc gate records R8 closed with tasks through R8-{0} complete, most recently closed milestone '{1}', R10 through R10-{2} closed, R11 through R11-{3} closed, R12 through R12-{4} closed, and active milestone '{5}' through R13-{6} with {7}." -f $validation.DoneThrough.ToString("000"), $validation.MostRecentlyClosedMilestone, $validation.R10DoneThrough.ToString("000"), $validation.R11DoneThrough.ToString("000"), $validation.R12DoneThrough.ToString("000"), $validation.ActiveMilestone, $validation.R13DoneThrough.ToString("000"), $r13PlannedSummary)
}
elseif ($validation.R12Closed) {
    Write-Output ("VALID: status-doc gate records R8 closed with tasks through R8-{0} complete, most recently closed milestone '{1}', no active successor milestone, R10 through R10-{2} closed, R11 through R11-{3} closed, and R12 through R12-{4} closed." -f $validation.DoneThrough.ToString("000"), $validation.MostRecentlyClosedMilestone, $validation.R10DoneThrough.ToString("000"), $validation.R11DoneThrough.ToString("000"), $validation.R12DoneThrough.ToString("000"))
}
elseif ($validation.R12Opened) {
    Write-Output ("VALID: status-doc gate records R8 closed with tasks through R8-{0} complete, most recently closed milestone '{1}', R10 through R10-{2} closed, R11 through R11-{3} closed, and active milestone '{4}' through R12-{5} with R12-{6} through R12-{7} planned." -f $validation.DoneThrough.ToString("000"), $validation.MostRecentlyClosedMilestone, $validation.R10DoneThrough.ToString("000"), $validation.R11DoneThrough.ToString("000"), $validation.ActiveMilestone, $validation.R12DoneThrough.ToString("000"), $validation.R12PlannedStart.ToString("000"), $validation.R12PlannedThrough.ToString("000"))
}
elseif ($validation.R11Closed) {
    Write-Output ("VALID: status-doc gate records R8 closed with tasks through R8-{0} complete, most recently closed milestone '{1}', no active successor milestone, R10 through R10-{2} closed, and R11 through R11-{3} closed." -f $validation.DoneThrough.ToString("000"), $validation.MostRecentlyClosedMilestone, $validation.R10DoneThrough.ToString("000"), $validation.R11DoneThrough.ToString("000"))
}
elseif ($validation.R11Opened) {
    Write-Output ("VALID: status-doc gate records R8 closed with tasks through R8-{0} complete, most recently closed milestone '{1}', R10 through R10-{2} closed, and active milestone '{3}' through R11-{4} with R11-{5} through R11-{6} planned." -f $validation.DoneThrough.ToString("000"), $validation.MostRecentlyClosedMilestone, $validation.R10DoneThrough.ToString("000"), $validation.ActiveMilestone, $validation.R11DoneThrough.ToString("000"), $validation.R11PlannedStart.ToString("000"), $validation.R11PlannedThrough.ToString("000"))
}
elseif ($validation.R10Closed) {
    Write-Output ("VALID: status-doc gate records R8 closed with tasks through R8-{0} complete, most recently closed milestone '{1}', no active successor milestone, and R10 through R10-{2} closed." -f $validation.DoneThrough.ToString("000"), $validation.MostRecentlyClosedMilestone, $validation.R10DoneThrough.ToString("000"))
}
elseif ($validation.R10Opened) {
    Write-Output ("VALID: status-doc gate records R8 closed with tasks through R8-{0} complete, most recently closed milestone '{1}', and active milestone '{2}' through R10-{3} with R10-{4} through R10-{5} planned." -f $validation.DoneThrough.ToString("000"), $validation.MostRecentlyClosedMilestone, $validation.ActiveMilestone, $validation.R10DoneThrough.ToString("000"), $validation.R10PlannedStart.ToString("000"), $validation.R10PlannedThrough.ToString("000"))
}
elseif ($validation.R9Closed) {
    Write-Output ("VALID: status-doc gate records R8 closed with tasks through R8-{0} complete, most recently closed milestone '{1}', no active successor milestone, and R9 through R9-{2} closed." -f $validation.DoneThrough.ToString("000"), $validation.MostRecentlyClosedMilestone, $validation.R9DoneThrough.ToString("000"))
}
elseif ($validation.R9Opened) {
    Write-Output ("VALID: status-doc gate records R8 closed with tasks through R8-{0} complete, most recently closed milestone '{1}', and active milestone '{2}' through R9-{3} with R9-{4} through R9-{5} planned." -f $validation.DoneThrough.ToString("000"), $validation.MostRecentlyClosedMilestone, $validation.ActiveMilestone, $validation.R9DoneThrough.ToString("000"), $validation.R9PlannedStart.ToString("000"), $validation.R9PlannedThrough.ToString("000"))
}
elseif ($validation.R8Closed) {
    Write-Output ("VALID: status-doc gate records R8 closed with tasks through R8-{0} complete, most recently closed milestone '{1}', and {2}." -f $validation.DoneThrough.ToString("000"), $validation.MostRecentlyClosedMilestone, $plannedSummary)
}
else {
    Write-Output ("VALID: status-doc gate keeps '{0}' active with tasks through R8-{1} complete and {2}." -f $validation.ActiveMilestone, $validation.DoneThrough.ToString("000"), $plannedSummary)
}
