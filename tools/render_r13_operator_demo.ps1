[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$StatusPath,
    [Parameter(Mandatory = $true)]
    [string]$OutputPath
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$r13RepositoryName = "AIOffice_V2"
$r13Branch = "release/r13-api-first-qa-pipeline-and-operator-control-room-product-slice"
$r13Milestone = "R13 API-First QA Pipeline and Operator Control-Room Product Slice"
$r13SourceTask = "R13-010"
$requiredSections = @(
    "Executive operator summary",
    "What was proved locally",
    "QA failure-to-fix cycle walkthrough",
    "Before and after evidence",
    "Current control-room posture",
    "Custom runner posture",
    "Skill invocation posture",
    "What is still blocked",
    "Next legal action",
    "Evidence map",
    "Explicit non-claims"
)
$requiredNonClaims = @(
    "no external replay has occurred",
    "no final QA signoff has occurred",
    "no hard R13 value gate fully delivered",
    "no productized UI",
    "no production runtime",
    "no R14 or successor opening"
)

function Resolve-RepoPath {
    param([Parameter(Mandatory = $true)][string]$PathValue)
    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $repoRoot $PathValue))
}

function ConvertTo-RepoRef {
    param([Parameter(Mandatory = $true)][string]$PathValue)
    $fullPath = [System.IO.Path]::GetFullPath((Resolve-RepoPath -PathValue $PathValue))
    $rootPath = [System.IO.Path]::GetFullPath($repoRoot).TrimEnd([char[]]@([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar))
    if ($fullPath.StartsWith($rootPath + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $fullPath.Substring($rootPath.Length + 1).Replace("\", "/")
    }
    return $PathValue.Replace("\", "/")
}

function Assert-ExistingRef {
    param(
        [Parameter(Mandatory = $true)][string]$Ref,
        [Parameter(Mandatory = $true)][string]$Context
    )
    if ([string]::IsNullOrWhiteSpace($Ref) -or [System.IO.Path]::IsPathRooted($Ref) -or $Ref -match '(^|[\\/])\.\.([\\/]|$)') {
        throw "$Context must be a repository-relative path."
    }
    if (-not (Test-Path -LiteralPath (Resolve-RepoPath -PathValue $Ref))) {
        throw "$Context '$Ref' does not exist."
    }
}

function Read-JsonDocument {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Label
    )
    $resolved = Resolve-RepoPath -PathValue $Path
    if (-not (Test-Path -LiteralPath $resolved)) {
        throw "$Label '$Path' does not exist."
    }
    return (Read-SingleJsonObject -Path $resolved -Label $Label)
}

function Write-TextFile {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string]$Value
    )
    $resolved = Resolve-RepoPath -PathValue $Path
    $parent = Split-Path -Parent $resolved
    if (-not [string]::IsNullOrWhiteSpace($parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    $text = ($Value -replace "`r`n", "`n") -replace "`r", "`n"
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($resolved, $text, $utf8NoBom)
}

function Invoke-GitLine {
    param([Parameter(Mandatory = $true)][string[]]$Arguments)
    $output = & git -C $repoRoot @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Git command failed: git $($Arguments -join ' ')"
    }
    return ([string](@($output)[0])).Trim()
}

function Get-GitIdentity {
    return [pscustomobject][ordered]@{
        Branch = Invoke-GitLine -Arguments @("branch", "--show-current")
        Head = Invoke-GitLine -Arguments @("rev-parse", "HEAD")
        Tree = Invoke-GitLine -Arguments @("rev-parse", "HEAD^{tree}")
    }
}

function Get-StableId {
    param(
        [Parameter(Mandatory = $true)][string]$Prefix,
        [Parameter(Mandatory = $true)][string]$Key
    )
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Key.ToLowerInvariant())
        $hash = $sha.ComputeHash($bytes)
    }
    finally {
        $sha.Dispose()
    }
    $hex = -join ($hash[0..7] | ForEach-Object { $_.ToString("x2", [System.Globalization.CultureInfo]::InvariantCulture) })
    return "$Prefix-$hex"
}

function Get-CommandCounts {
    param([AllowNull()]$CommandResults)
    $commands = @($CommandResults)
    return [pscustomobject][ordered]@{
        Total = $commands.Count
        Passed = @($commands | Where-Object { [string]$_.verdict -eq "passed" }).Count
        Failed = @($commands | Where-Object { [string]$_.verdict -eq "failed" }).Count
    }
}

function Test-LineHasNegation {
    param([Parameter(Mandatory = $true)][string]$Line)
    return ($Line -match '(?i)\b(no|not|without|cannot|must not|does not|do not|is not|are not|did not|non-claim|non_claim|blocked|planned|planned only|not yet|not fully|partial|partially|missing|required before|pending|false)\b')
}

function Assert-NoForbiddenDemoClaims {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][string]$Context
    )
    foreach ($line in @($Text -split "`n")) {
        if ($line -match '(?i)\bexternal[_ -]?replay\b' -and $line -match '(?i)\b(executed|complete|completed|passed|delivered|proved|run|ran|replayed|started|occurred)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims external replay. Offending text: $line"
        }
        if ($line -match '(?i)\bfinal\s+QA\s+signoff\b|\bfinal\s+signoff\b|\bsign-off\b' -and $line -match '(?i)\b(accepted|complete|completed|delivered|passed|signed|occurred)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims final QA signoff. Offending text: $line"
        }
        if ($line -match '(?i)\b(hard\s+)?R13\s+hard\s+value\s+gate\b|\bhard\s+value\s+gate\b|\bmeaningful\s+QA\s+loop\b|\bAPI/custom-runner bypass\b|\bcurrent\s+operator\s+control[- ]room\b|\bskill\s+invocation\s+evidence\b|\boperator\s+demo\s+gate\b' -and $line -match '(?i)\b(delivered|complete|completed|passed|proved|fully delivered)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims hard gate delivery. Offending text: $line"
        }
        if ($line -match '(?i)\bproductized UI\b|\bproductized control[- ]room behavior\b|\bfull UI app\b|\bproduction runtime\b|\breal production QA\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims forbidden product or production scope. Offending text: $line"
        }
        if ($line -match '(?i)\bR14\b.*\b(active|open|opened)\b|\bsuccessor\b.*\b(active|open|opened)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims R14 or successor opening. Offending text: $line"
        }
    }
}

function Assert-SourceStatusForDemo {
    param([Parameter(Mandatory = $true)]$Status)
    if ($Status.artifact_type -ne "r13_control_room_status") {
        throw "Source control-room status artifact_type must be r13_control_room_status."
    }
    if ($Status.repository -ne $r13RepositoryName -or $Status.branch -ne $r13Branch -or $Status.source_milestone -ne $r13Milestone) {
        throw "Source control-room status identity does not match R13."
    }
    if (-not [bool]$Status.stale_state_checks.stale_state_checks_passed) {
        throw "Source control-room status stale-state checks must have passed."
    }
    if ([string]$Status.active_scope.active_through_task -ne "R13-009") {
        throw "Source control-room status must show R13 active through R13-009 before operator demo generation."
    }
    $completed = @($Status.completed_tasks | ForEach-Object { [string]$_.task_id })
    $planned = @($Status.planned_tasks | ForEach-Object { [string]$_.task_id })
    $expectedCompleted = @(1..9 | ForEach-Object { "R13-{0}" -f $_.ToString("000") })
    $expectedPlanned = @(10..18 | ForEach-Object { "R13-{0}" -f $_.ToString("000") })
    if (($completed -join "|") -ne ($expectedCompleted -join "|") -or ($planned -join "|") -ne ($expectedPlanned -join "|")) {
        throw "Source control-room status must show R13-001 through R13-009 complete and R13-010 through R13-018 planned."
    }
    if ([string]$Status.next_actions[0].task_id -ne "R13-010") {
        throw "Source control-room status first next legal action must be R13-010."
    }
    if ([string]$Status.external_replay_status.status -ne "not_delivered" -or [bool]$Status.external_replay_status.executed) {
        throw "Source control-room status must not claim external replay."
    }
    if ([bool]$Status.hard_gate_status.overall.any_hard_gate_delivered) {
        throw "Source control-room status must not mark any hard gate delivered."
    }
}

$statusRef = ConvertTo-RepoRef -PathValue $StatusPath
$demoRef = ConvertTo-RepoRef -PathValue $OutputPath
$status = Read-JsonDocument -Path $StatusPath -Label "R13 control-room status"
Assert-SourceStatusForDemo -Status $status

$viewRef = [string]$status.control_room_status.markdown_view_ref
$failureFixCycleRef = "state/cycles/r13_qa_cycle_demo/qa_failure_fix_cycle.json"
$comparisonRef = "state/cycles/r13_qa_cycle_demo/before_after_comparison.json"
$runnerResultRef = "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/runner/r13_007_custom_runner_result.json"
$skillRegistryRef = "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_skill_registry.json"
$qaDetectRef = "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_qa_detect_invocation_result.json"
$qaFixPlanRef = "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_qa_fix_plan_invocation_result.json"

foreach ($ref in @($viewRef, $failureFixCycleRef, $comparisonRef, $runnerResultRef, $skillRegistryRef, $qaDetectRef, $qaFixPlanRef)) {
    Assert-ExistingRef -Ref $ref -Context "operator demo source ref"
}

$failureFixCycle = Read-JsonDocument -Path $failureFixCycleRef -Label "R13 failure-to-fix cycle"
$comparison = Read-JsonDocument -Path $comparisonRef -Label "R13 before/after comparison"
$runnerResult = Read-JsonDocument -Path $runnerResultRef -Label "R13 custom runner result"
$skillRegistry = Read-JsonDocument -Path $skillRegistryRef -Label "R13 skill registry"
$qaDetectResult = Read-JsonDocument -Path $qaDetectRef -Label "R13 qa.detect skill invocation result"
$qaFixPlanResult = Read-JsonDocument -Path $qaFixPlanRef -Label "R13 qa.fix_plan skill invocation result"

if ($failureFixCycle.artifact_type -ne "r13_qa_failure_fix_cycle" -or $comparison.artifact_type -ne "r13_qa_before_after_comparison") {
    throw "R13 QA demo sources have unexpected artifact types."
}
if ($runnerResult.artifact_type -ne "r13_custom_runner_result" -or $skillRegistry.artifact_type -ne "r13_skill_registry") {
    throw "R13 runner or skill registry sources have unexpected artifact types."
}
if ($qaDetectResult.skill_id -ne "qa.detect" -or $qaFixPlanResult.skill_id -ne "qa.fix_plan") {
    throw "R13 skill invocation source results do not match qa.detect and qa.fix_plan."
}

$gitIdentity = Get-GitIdentity
if ($gitIdentity.Branch -ne $r13Branch) {
    throw "Current branch must be '$r13Branch'."
}

$runnerCounts = Get-CommandCounts -CommandResults $runnerResult.command_results
$detectCounts = Get-CommandCounts -CommandResults $qaDetectResult.command_results
$fixPlanCounts = Get-CommandCounts -CommandResults $qaFixPlanResult.command_results
$beforeCount = @($comparison.before_issue_ids).Count
$afterCount = @($comparison.after_issue_ids).Count
$demoId = Get-StableId -Prefix "r13od" -Key "$($gitIdentity.Branch)|$($gitIdentity.Head)|$demoRef|$($failureFixCycle.cycle_id)"
$generatedAt = [System.DateTimeOffset]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture)
$sourceSkillRefs = @($qaDetectRef, $qaFixPlanRef)
$evidenceRefs = @(
    "contracts/control_room/r13_operator_demo.contract.json",
    "tools/render_r13_operator_demo.ps1",
    "tools/validate_r13_operator_demo.ps1",
    $statusRef,
    $viewRef,
    $failureFixCycleRef,
    $comparisonRef,
    $runnerResultRef,
    $skillRegistryRef,
    $qaDetectRef,
    $qaFixPlanRef
)

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# R13 Operator Demo") | Out-Null
$lines.Add("") | Out-Null
$lines.Add('- contract_version: `v1`') | Out-Null
$lines.Add('- artifact_type: `r13_operator_demo`') | Out-Null
$lines.Add(('- demo_id: `{0}`' -f $demoId)) | Out-Null
$lines.Add(('- repository: `{0}`' -f $r13RepositoryName)) | Out-Null
$lines.Add(('- branch: `{0}`' -f $gitIdentity.Branch)) | Out-Null
$lines.Add(('- head: `{0}`' -f $gitIdentity.Head)) | Out-Null
$lines.Add(('- tree: `{0}`' -f $gitIdentity.Tree)) | Out-Null
$lines.Add(('- source_milestone: `{0}`' -f $r13Milestone)) | Out-Null
$lines.Add(('- source_task: `{0}`' -f $r13SourceTask)) | Out-Null
$lines.Add(('- source_control_room_status_ref: `{0}`' -f $statusRef)) | Out-Null
$lines.Add(('- source_control_room_view_ref: `{0}`' -f $viewRef)) | Out-Null
$lines.Add(('- source_failure_fix_cycle_ref: `{0}`' -f $failureFixCycleRef)) | Out-Null
$lines.Add(('- source_before_after_comparison_ref: `{0}`' -f $comparisonRef)) | Out-Null
$lines.Add(('- source_runner_result_ref: `{0}`' -f $runnerResultRef)) | Out-Null
$lines.Add(('- source_skill_registry_ref: `{0}`' -f $skillRegistryRef)) | Out-Null
$lines.Add(('- source_skill_invocation_refs: `{0}`' -f ($sourceSkillRefs -join '`, `'))) | Out-Null
$lines.Add(('- demo_sections: `{0}`' -f ($requiredSections -join '`, `'))) | Out-Null
$lines.Add('- evidence_refs: see `Evidence map`') | Out-Null
$lines.Add('- blocker_summary: `external replay missing; final QA signoff missing; hard gates not fully delivered`') | Out-Null
$lines.Add('- hard_gate_summary: `operator demo gate partially evidenced only; no hard R13 value gate fully delivered`') | Out-Null
$lines.Add('- next_legal_action: `R13-011 external replay after demo`') | Out-Null
$lines.Add(('- generated_at_utc: `{0}`' -f $generatedAt)) | Out-Null
$lines.Add('- non_claims: see `Explicit non-claims`') | Out-Null
$lines.Add("") | Out-Null
$lines.Add("## Executive operator summary") | Out-Null
$lines.Add("R13 now has a human-readable operator demo artifact that explains the local QA failure-to-fix proof, current control-room surface, bounded custom-runner evidence, and partial skill invocation evidence without requiring raw JSON first.") | Out-Null
$lines.Add("R13 is active through R13-010 only; R13-011 through R13-018 remain planned only.") | Out-Null
$lines.Add("External replay and final QA signoff are still missing, and no hard R13 value gate is fully delivered.") | Out-Null
$lines.Add("") | Out-Null
$lines.Add("## What was proved locally") | Out-Null
$lines.Add(('- Local QA proof: selected issue type `{0}` was repaired in the controlled demo workspace.' -f $failureFixCycle.selected_issue_type)) | Out-Null
$lines.Add(('- Cycle aggregate verdict: `{0}`.' -f $failureFixCycle.aggregate_verdict)) | Out-Null
$lines.Add(('- Current control-room surface: `{0}` and `{1}`.' -f $statusRef, $viewRef)) | Out-Null
$lines.Add(('- Bounded custom-runner evidence: `{0}` commands, `{1}` passed, aggregate `{2}`.' -f $runnerCounts.Total, $runnerCounts.Passed, $runnerResult.aggregate_verdict)) | Out-Null
$lines.Add(('- Partial skill invocation evidence: `qa.detect` `{0}` command / `{1}` passed; `qa.fix_plan` `{2}` command / `{3}` passed.' -f $detectCounts.Total, $detectCounts.Passed, $fixPlanCounts.Total, $fixPlanCounts.Passed)) | Out-Null
$lines.Add("") | Out-Null
$lines.Add("## QA failure-to-fix cycle walkthrough") | Out-Null
$lines.Add(('- Source cycle: `{0}`.' -f $failureFixCycleRef)) | Out-Null
$lines.Add(('- Selected fix item: `{0}`.' -f $failureFixCycle.selected_fix_item_id)) | Out-Null
$lines.Add(('- Selected source issue: `{0}`.' -f $failureFixCycle.selected_source_issue_id)) | Out-Null
$lines.Add(('- Selected issue type: `{0}`.' -f $failureFixCycle.selected_issue_type)) | Out-Null
$lines.Add(('- Cycle status: `{0}`.' -f $failureFixCycle.cycle_status)) | Out-Null
$lines.Add(('- Aggregate verdict: `{0}`.' -f $failureFixCycle.aggregate_verdict)) | Out-Null
$lines.Add("") | Out-Null
$lines.Add("## Before and after evidence") | Out-Null
$lines.Add(('- Before input: `{0}`.' -f $comparison.demo_before_ref)) | Out-Null
$lines.Add(('- After input: `{0}`.' -f $comparison.demo_after_ref)) | Out-Null
$lines.Add(('- Before detection report: `{0}`.' -f $comparison.before_report_ref)) | Out-Null
$lines.Add(('- After detection report: `{0}`.' -f $comparison.after_report_ref)) | Out-Null
$lines.Add(('- Before issue count: `{0}`.' -f $beforeCount)) | Out-Null
$lines.Add(('- After issue count: `{0}`.' -f $afterCount)) | Out-Null
$lines.Add(('- Comparison verdict: `{0}`.' -f $comparison.comparison_verdict)) | Out-Null
$lines.Add("") | Out-Null
$lines.Add("## Current control-room posture") | Out-Null
$lines.Add(('- Source status: `{0}`.' -f $statusRef)) | Out-Null
$lines.Add(('- Source Markdown view: `{0}`.' -f $viewRef)) | Out-Null
$lines.Add(('- Source status stale-state checks passed: `{0}`.' -f $status.stale_state_checks.stale_state_checks_passed)) | Out-Null
$lines.Add("- R13 active through R13-010 only after this demo; R13-011 through R13-018 remain planned only.") | Out-Null
$lines.Add("- Current operator control-room gate remains partially evidenced only, not fully delivered as a hard gate.") | Out-Null
$lines.Add("") | Out-Null
$lines.Add("## Custom runner posture") | Out-Null
$lines.Add(('- Runner result: `{0}`.' -f $runnerResultRef)) | Out-Null
$lines.Add(('- Execution status: `{0}`.' -f $runnerResult.execution_status)) | Out-Null
$lines.Add(('- Aggregate verdict: `{0}`.' -f $runnerResult.aggregate_verdict)) | Out-Null
$lines.Add(('- Commands: `{0}` total, `{1}` passed, `{2}` failed.' -f $runnerCounts.Total, $runnerCounts.Passed, $runnerCounts.Failed)) | Out-Null
$lines.Add("- API/custom-runner bypass gate remains partial only, not fully delivered as a hard gate.") | Out-Null
$lines.Add("") | Out-Null
$lines.Add("## Skill invocation posture") | Out-Null
$lines.Add(('- Skill registry: `{0}`.' -f $skillRegistryRef)) | Out-Null
$lines.Add(('- Registered skills: `{0}`.' -f (@($skillRegistry.skills | ForEach-Object { [string]$_.skill_id }) -join '`, `'))) | Out-Null
$lines.Add(('- `qa.detect`: `{0}` command, `{1}` passed, aggregate `{2}`, ref `{3}`.' -f $detectCounts.Total, $detectCounts.Passed, $qaDetectResult.aggregate_verdict, $qaDetectRef)) | Out-Null
$lines.Add(('- `qa.fix_plan`: `{0}` command, `{1}` passed, aggregate `{2}`, ref `{3}`.' -f $fixPlanCounts.Total, $fixPlanCounts.Passed, $qaFixPlanResult.aggregate_verdict, $qaFixPlanRef)) | Out-Null
$lines.Add("- Skill invocation evidence gate is partially evidenced only, not fully delivered as a hard gate.") | Out-Null
$lines.Add("") | Out-Null
$lines.Add("## What is still blocked") | Out-Null
$lines.Add("- External replay missing.") | Out-Null
$lines.Add("- Final QA signoff missing.") | Out-Null
$lines.Add("- Hard gates not fully delivered.") | Out-Null
$lines.Add("") | Out-Null
$lines.Add("## Next legal action") | Out-Null
$lines.Add('- `R13-011`: external replay after demo, unless the R13 authority/status changes by explicit repo-truth approval.') | Out-Null
$lines.Add("") | Out-Null
$lines.Add("## Evidence map") | Out-Null
foreach ($ref in $evidenceRefs) {
    $lines.Add(('- `{0}`' -f $ref)) | Out-Null
}
$lines.Add("") | Out-Null
$lines.Add("## Explicit non-claims") | Out-Null
foreach ($nonClaim in $requiredNonClaims) {
    $lines.Add("- $nonClaim") | Out-Null
}

$content = ($lines -join "`n") + "`n"
Assert-NoForbiddenDemoClaims -Text $content -Context "R13 operator demo"
Write-TextFile -Path $OutputPath -Value $content

$manifestPath = Join-Path (Split-Path -Parent (Resolve-RepoPath -PathValue $OutputPath)) "operator_demo_validation_manifest.md"
$manifestRef = ConvertTo-RepoRef -PathValue $manifestPath
$manifestLines = New-Object System.Collections.Generic.List[string]
$manifestLines.Add("# R13 Operator Demo Validation Manifest") | Out-Null
$manifestLines.Add("") | Out-Null
$manifestLines.Add('- artifact_type: `r13_operator_demo_validation_manifest`') | Out-Null
$manifestLines.Add(('- source_operator_demo_ref: `{0}`' -f $demoRef)) | Out-Null
$manifestLines.Add(('- generated_at_utc: `{0}`' -f $generatedAt)) | Out-Null
$manifestLines.Add(('- branch: `{0}`' -f $gitIdentity.Branch)) | Out-Null
$manifestLines.Add(('- head: `{0}`' -f $gitIdentity.Head)) | Out-Null
$manifestLines.Add(('- tree: `{0}`' -f $gitIdentity.Tree)) | Out-Null
$manifestLines.Add("") | Out-Null
$manifestLines.Add("## Demo Boundary") | Out-Null
$manifestLines.Add('- Completed: `R13-001 through R13-010`') | Out-Null
$manifestLines.Add('- Planned: `R13-011 through R13-018`') | Out-Null
$manifestLines.Add('- Next legal action: `R13-011`') | Out-Null
$manifestLines.Add("") | Out-Null
$manifestLines.Add("## Required Sections") | Out-Null
foreach ($section in $requiredSections) {
    $manifestLines.Add(('- `{0}`' -f $section)) | Out-Null
}
$manifestLines.Add("") | Out-Null
$manifestLines.Add("## Required Non-Claims") | Out-Null
foreach ($nonClaim in $requiredNonClaims) {
    $manifestLines.Add("- $nonClaim") | Out-Null
}
Write-TextFile -Path $manifestPath -Value (($manifestLines -join "`n") + "`n")

Write-Output ("Rendered R13 operator demo: {0}" -f $demoRef)
Write-Output ("Validation manifest: {0}" -f $manifestRef)
