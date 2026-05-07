$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R16FrictionMetricsReport.psm1") -Force -PassThru
$newReportObject = $module.ExportedCommands["New-R16FrictionMetricsReportObject"]
$newReport = $module.ExportedCommands["New-R16FrictionMetricsReport"]
$testReport = $module.ExportedCommands["Test-R16FrictionMetricsReport"]
$testReportObject = $module.ExportedCommands["Test-R16FrictionMetricsReportObject"]
$testContract = $module.ExportedCommands["Test-R16FrictionMetricsReportContract"]
$stableJson = $module.ExportedCommands["ConvertTo-StableJson"]
$newFixtures = $module.ExportedCommands["New-R16FrictionMetricsReportFixtureFiles"]

$validPassed = 0
$invalidRejected = 0
$failures = @()
$fixtureRootRel = "tests\fixtures\r16_friction_metrics_report"
$fixtureRoot = Join-Path $repoRoot $fixtureRootRel
$validFixtureRel = Join-Path $fixtureRootRel "valid_friction_metrics_report.json"
$validFixturePath = Join-Path $repoRoot $validFixtureRel
$stateReportRel = "state\governance\r16_friction_metrics_report.json"
$tempRootRel = Join-Path "state\governance" ("r16frictionmetricsreport" + [guid]::NewGuid().ToString("N"))
$tempRoot = Join-Path $repoRoot $tempRootRel

function Read-TestJsonObject {
    param([Parameter(Mandatory = $true)][string]$Path)

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Copy-TestJsonObject {
    param([Parameter(Mandatory = $true)]$Value)

    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Get-FixturePathSegments {
    param([Parameter(Mandatory = $true)][string]$Path)

    if ($Path -notmatch '^\$\.') {
        throw "mutation_path '$Path' must start with '$.'."
    }

    $segments = @()
    foreach ($part in @($Path.Substring(2) -split '\.')) {
        $match = [regex]::Match($part, '^([A-Za-z_][A-Za-z0-9_]*)(?:\[(\d+)\])?$')
        if (-not $match.Success) {
            throw "mutation_path '$Path' has unsupported segment '$part'."
        }

        $indexValue = $null
        if ($match.Groups[2].Success) {
            $indexValue = [int]$match.Groups[2].Value
        }

        $segments += [pscustomobject]@{
            Name = $match.Groups[1].Value
            Index = $indexValue
        }
    }

    return $segments
}

function Get-ObjectPropertyValue {
    param(
        [Parameter(Mandatory = $true)]$InputObject,
        [Parameter(Mandatory = $true)][string]$Name
    )

    $property = $InputObject.PSObject.Properties[$Name]
    if ($null -eq $property) {
        throw "mutation path property '$Name' does not exist."
    }

    return $property.Value
}

function Set-ObjectPropertyValue {
    param(
        [Parameter(Mandatory = $true)]$InputObject,
        [Parameter(Mandatory = $true)][string]$Name,
        [AllowNull()]$Value
    )

    $property = $InputObject.PSObject.Properties[$Name]
    if ($null -eq $property) {
        $InputObject | Add-Member -NotePropertyName $Name -NotePropertyValue $Value -Force
        return
    }

    $property.Value = $Value
}

function Get-MutationParent {
    param(
        [Parameter(Mandatory = $true)]$Artifact,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $segments = @(Get-FixturePathSegments -Path $Path)
    if ($segments.Count -eq 0) {
        throw "mutation_path '$Path' must identify a property."
    }

    $current = $Artifact
    for ($index = 0; $index -lt ($segments.Count - 1); $index += 1) {
        $segment = $segments[$index]
        $current = Get-ObjectPropertyValue -InputObject $current -Name $segment.Name
        if ($null -ne $segment.Index) {
            $items = @($current)
            if ($segment.Index -ge $items.Count) {
                throw "mutation_path '$Path' index $($segment.Index) is out of range."
            }

            $current = $items[$segment.Index]
        }
    }

    return [pscustomobject]@{
        Parent = $current
        Segment = $segments[-1]
    }
}

function Set-MutationPathValue {
    param(
        [Parameter(Mandatory = $true)]$Artifact,
        [Parameter(Mandatory = $true)][string]$Path,
        [AllowNull()]$Value
    )

    $target = Get-MutationParent -Artifact $Artifact -Path $Path
    if ($null -eq $target.Segment.Index) {
        Set-ObjectPropertyValue -InputObject $target.Parent -Name $target.Segment.Name -Value $Value
        return
    }

    $items = @(Get-ObjectPropertyValue -InputObject $target.Parent -Name $target.Segment.Name)
    if ($target.Segment.Index -ge $items.Count) {
        throw "mutation_path '$Path' index $($target.Segment.Index) is out of range."
    }

    $items[$target.Segment.Index] = $Value
    Set-ObjectPropertyValue -InputObject $target.Parent -Name $target.Segment.Name -Value $items
}

function Remove-MutationPathProperty {
    param(
        [Parameter(Mandatory = $true)]$Artifact,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $target = Get-MutationParent -Artifact $Artifact -Path $Path
    if ($null -ne $target.Segment.Index) {
        throw "mutation_path '$Path' cannot remove an array element."
    }

    $target.Parent.PSObject.Properties.Remove($target.Segment.Name)
}

function Apply-FixtureMutation {
    param(
        [Parameter(Mandatory = $true)]$Artifact,
        [Parameter(Mandatory = $true)]$FixtureSpec
    )

    $mutationPath = [string]$FixtureSpec.mutation_path
    $mutationValue = $FixtureSpec.mutation_value

    if ($mutationValue -is [string] -and $mutationValue -eq "__REMOVE_PROPERTY__") {
        Remove-MutationPathProperty -Artifact $Artifact -Path $mutationPath
        return
    }

    Set-MutationPathValue -Artifact $Artifact -Path $mutationPath -Value $mutationValue
}

function Assert-CompactMutationFixture {
    param(
        [Parameter(Mandatory = $true)][string]$FixtureName,
        [Parameter(Mandatory = $true)]$FixtureSpec,
        [Parameter(Mandatory = $true)][string[]]$RequiredFragments,
        [Parameter(Mandatory = $true)][string]$FixturePath
    )

    $expectedFixtureId = [System.IO.Path]::GetFileNameWithoutExtension($FixtureName)
    foreach ($fieldName in @("fixture_id", "base_fixture", "mutation_path", "mutation_value", "expected_failure")) {
        if ($FixtureSpec.PSObject.Properties.Name -notcontains $fieldName) {
            throw "$FixtureName compact mutation fixture is missing '$fieldName'."
        }
    }

    if ([string]$FixtureSpec.fixture_id -ne $expectedFixtureId) {
        throw "$FixtureName fixture_id must be '$expectedFixtureId'."
    }
    if ([string]$FixtureSpec.base_fixture -ne "valid_friction_metrics_report.json") {
        throw "$FixtureName base_fixture must be valid_friction_metrics_report.json."
    }
    if ([string]$FixtureSpec.mutation_path -notmatch '^\$\.') {
        throw "$FixtureName mutation_path must identify a JSON object path."
    }

    $expectedFailures = [string[]]@($FixtureSpec.expected_failure)
    foreach ($fragment in $RequiredFragments) {
        if ($expectedFailures -notcontains $fragment) {
            throw "$FixtureName expected_failure must include '$fragment'."
        }
    }

    $lineCount = @(Get-Content -LiteralPath $FixturePath).Count
    if ($lineCount -gt 50) {
        throw "$FixtureName compact mutation fixture must stay under 50 lines; found $lineCount."
    }
}

function Invoke-ExpectedRefusal {
    param(
        [Parameter(Mandatory = $true)][string]$Label,
        [Parameter(Mandatory = $true)][string[]]$RequiredFragments,
        [Parameter(Mandatory = $true)][scriptblock]$Action
    )

    try {
        & $Action
        $script:failures += ("FAIL invalid: {0} was accepted unexpectedly." -f $Label)
    }
    catch {
        $message = $_.Exception.Message
        $missingFragments = @($RequiredFragments | Where-Object { $message -notlike ("*{0}*" -f $_) })
        if ($missingFragments.Count -gt 0) {
            $script:failures += ("FAIL invalid: {0} refusal message missed fragments {1}. Actual: {2}" -f $Label, ($missingFragments -join ", "), $message)
            return
        }

        Write-Output ("PASS invalid: {0} -> {1}" -f $Label, $message)
        $script:invalidRejected += 1
    }
}

try {
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
    & $newFixtures -RepositoryRoot $repoRoot | Out-Null

    foreach ($requiredPath in @(
        "contracts\governance\r16_friction_metrics_report.contract.json",
        "tools\R16FrictionMetricsReport.psm1",
        "tools\new_r16_friction_metrics_report.ps1",
        "tools\validate_r16_friction_metrics_report.ps1",
        "tests\test_r16_friction_metrics_report.ps1",
        $stateReportRel,
        $validFixtureRel
    )) {
        if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $requiredPath) -PathType Leaf)) {
            $failures += "FAIL required deliverable missing: $requiredPath"
        }
    }

    foreach ($forbiddenPath in @(
        "state\audit\r16_final_audit_acceptance.json",
        "state\audit\r16_final_proof_package.json",
        "state\audit\r16_closeout_completion.json",
        "state\workflow\r16_runtime_execution.json",
        "state\memory\r16_runtime_memory.json",
        "state\retrieval\r16_vector_index.json",
        "state\integrations\r16_external_integrations.json",
        "state\proof_reviews\r16_operational_memory_artifact_map_role_workflow_foundation\r16_026_final_proof_review_package\proof_review.json"
    )) {
        if (Test-Path -LiteralPath (Join-Path $repoRoot $forbiddenPath)) {
            $failures += "FAIL forbidden R16-025 overbuild artifact exists: $forbiddenPath"
        }
    }

    $contractResult = & $testContract -RepositoryRoot $repoRoot
    if ($contractResult.SourceTask -ne "R16-025" -or $contractResult.DependencyRefCount -ne 22) {
        $failures += "FAIL contract: expected R16-025 friction metrics report contract with 22 exact dependency refs."
    }
    else {
        Write-Output ("PASS contract: {0}, dependency_refs={1}, required_fields={2}" -f $contractResult.ContractId, $contractResult.DependencyRefCount, $contractResult.RequiredReportFieldCount)
        $validPassed += 1
    }

    $first = & $newReportObject -RepositoryRoot $repoRoot
    $second = & $newReportObject -RepositoryRoot $repoRoot
    if ((& $stableJson $first) -ne (& $stableJson $second)) {
        $failures += "FAIL determinism: two generated R16-025 friction metrics report objects differ after stable normalization."
    }
    else {
        Write-Output "PASS determinism: generated R16-025 friction metrics report object is stable across two generations."
        $validPassed += 1
    }

    $tempReportRel = Join-Path $tempRootRel "r16_friction_metrics_report.json"
    $generated = & $newReport -OutputPath $tempReportRel -RepositoryRoot $repoRoot
    if ($generated.ActiveThroughTask -ne "R16-025" -or $generated.PlannedTaskStart -ne "R16-026" -or $generated.PlannedTaskEnd -ne "R16-026" -or $generated.AggregateVerdict -ne "passed_bounded_friction_metrics_report_with_guard_failed_closed" -or $generated.ExactMetricInputCount -ne 14 -or $generated.ProofReviewRefCount -ne 8 -or $generated.GuardVerdict -ne "failed_closed_over_budget" -or $generated.LatestGuardUpperBound -ne 1364079 -or $generated.Threshold -ne 150000) {
        $failures += "FAIL generated report: expected R16 active through R16-025 in report only, R16-026 planned only, 14 exact metric inputs, 8 proof review refs, failed_closed_over_budget guard values 1364079 over 150000, and passed_bounded_friction_metrics_report_with_guard_failed_closed."
    }
    else {
        Write-Output ("PASS generated report: exact_metric_inputs={0}, proof_review_refs={1}, verdict={2}, guard={3}/{4}" -f $generated.ExactMetricInputCount, $generated.ProofReviewRefCount, $generated.AggregateVerdict, $generated.LatestGuardUpperBound, $generated.Threshold)
        $validPassed += 1
    }

    $stateResult = & $testReport -Path $stateReportRel -RepositoryRoot $repoRoot
    if ($stateResult.ActiveThroughTask -ne "R16-025" -or $stateResult.PlannedTaskStart -ne "R16-026" -or $stateResult.PlannedTaskEnd -ne "R16-026" -or $stateResult.ExactMetricInputCount -ne 14 -or $stateResult.ProofReviewRefCount -ne 8 -or $stateResult.GuardVerdict -ne "failed_closed_over_budget" -or $stateResult.LatestGuardUpperBound -ne 1364079 -or $stateResult.Threshold -ne 150000 -or $stateResult.FrictionFindingCount -lt 10 -or $stateResult.NextMilestoneImplicationCount -lt 5) {
        $failures += "FAIL state R16-025 report: expected bounded friction metrics posture with guard 1364079 over 150000 and explicit next milestone implications."
    }
    else {
        Write-Output ("PASS state report: exact_metric_inputs={0}, proof_review_refs={1}, friction_findings={2}, next_implications={3}, verdict={4}" -f $stateResult.ExactMetricInputCount, $stateResult.ProofReviewRefCount, $stateResult.FrictionFindingCount, $stateResult.NextMilestoneImplicationCount, $stateResult.AggregateVerdict)
        $validPassed += 1
    }

    $validFixtureResult = & $testReport -Path $validFixtureRel -RepositoryRoot $repoRoot
    if ($validFixtureResult.ExactMetricInputCount -ne 14 -or $validFixtureResult.ProofReviewRefCount -ne 8 -or $validFixtureResult.AggregateVerdict -ne "passed_bounded_friction_metrics_report_with_guard_failed_closed") {
        $failures += "FAIL valid fixture: expected bounded friction metrics report with exact repo-backed inputs and operator-observed process evidence separated from machine proof."
    }
    else {
        Write-Output ("PASS valid fixture: {0}" -f (Join-Path $repoRoot $validFixtureRel))
        $validPassed += 1
    }

    $validFixtureObject = Read-TestJsonObject -Path $validFixturePath
    $expectedInvalidFragments = [ordered]@{
        "invalid_missing_required_top_level_field.json" = @("missing required field 'generation_boundary'")
        "invalid_missing_context_budget_history.json" = @("missing required field 'context_budget_history'")
        "invalid_missing_context_guard_posture.json" = @("missing required field 'context_guard_posture'")
        "invalid_missing_manual_step_metrics.json" = @("missing required field 'manual_step_metrics'")
        "invalid_missing_restart_recovery_metrics.json" = @("missing required field 'restart_recovery_metrics'")
        "invalid_missing_compaction_failure_metrics.json" = @("missing required field 'compaction_failure_metrics'")
        "invalid_missing_deterministic_drift_metrics.json" = @("missing required field 'deterministic_drift_metrics'")
        "invalid_missing_regeneration_cascade_metrics.json" = @("missing required field 'regeneration_cascade_metrics'")
        "invalid_missing_fixture_bloat_metrics.json" = @("missing required field 'fixture_bloat_metrics'")
        "invalid_missing_next_milestone_planning_implications.json" = @("missing required field 'next_milestone_planning_implications'")
        "invalid_raw_chat_history_as_canonical_evidence.json" = @("raw chat history as canonical evidence")
        "invalid_full_repo_scan_claim.json" = @("full repo scan claim")
        "invalid_broad_repo_scan_claim.json" = @("broad repo scan claim")
        "invalid_wildcard_path.json" = @("wildcard path")
        "invalid_directory_only_ref.json" = @("directory-only ref")
        "invalid_scratch_temp_ref.json" = @("scratch/temp path")
        "invalid_absolute_path.json" = @("absolute path")
        "invalid_parent_traversal_path.json" = @("parent traversal path")
        "invalid_url_or_remote_ref.json" = @("URL or remote ref")
        "invalid_report_as_machine_proof_misuse.json" = @("report-as-machine-proof misuse")
        "invalid_exact_provider_tokenization_claim.json" = @("exact provider tokenization claim")
        "invalid_exact_provider_billing_claim.json" = @("exact provider billing claim")
        "invalid_solved_codex_compaction_claim.json" = @("solved Codex compaction claim")
        "invalid_solved_codex_reliability_claim.json" = @("solved Codex reliability claim")
        "invalid_runtime_memory_claim.json" = @("runtime memory claim")
        "invalid_retrieval_runtime_claim.json" = @("retrieval runtime claim")
        "invalid_vector_search_runtime_claim.json" = @("vector search runtime claim")
        "invalid_product_runtime_claim.json" = @("product runtime claim")
        "invalid_autonomous_agent_claim.json" = @("autonomous-agent claim")
        "invalid_external_integration_claim.json" = @("external-integration claim")
        "invalid_executable_handoff_claim.json" = @("executable handoff claim")
        "invalid_executable_transition_claim.json" = @("executable transition claim")
        "invalid_final_r16_audit_acceptance_claim.json" = @("final R16 audit acceptance claim")
        "invalid_closeout_completion_claim.json" = @("closeout completion claim")
        "invalid_final_proof_package_completion_claim.json" = @("final proof package completion claim")
        "invalid_r16_026_implementation_claim.json" = @("R16-026 implementation claim")
        "invalid_r16_027_or_later_task_claim.json" = @("R16-027 or later task claim")
        "invalid_r13_closure_or_partial_gate_conversion_claim.json" = @("R13 closure or partial-gate conversion claim")
        "invalid_r14_caveat_removal.json" = @("caveat removal")
        "invalid_r15_caveat_removal.json" = @("caveat removal")
    }

    foreach ($fixtureName in $expectedInvalidFragments.Keys) {
        $fixturePath = Join-Path $fixtureRoot $fixtureName
        if (-not (Test-Path -LiteralPath $fixturePath -PathType Leaf)) {
            $failures += "FAIL invalid: expected fixture missing: $fixtureName"
            continue
        }

        $fixtureSpec = Read-TestJsonObject -Path $fixturePath
        try {
            Assert-CompactMutationFixture -FixtureName $fixtureName -FixtureSpec $fixtureSpec -RequiredFragments $expectedInvalidFragments[$fixtureName] -FixturePath $fixturePath
        }
        catch {
            $failures += ("FAIL invalid: {0} compact fixture shape failed. {1}" -f $fixtureName, $_.Exception.Message)
            continue
        }

        Invoke-ExpectedRefusal -Label $fixtureName -RequiredFragments $expectedInvalidFragments[$fixtureName] -Action {
            $candidate = Copy-TestJsonObject -Value $validFixtureObject
            Apply-FixtureMutation -Artifact $candidate -FixtureSpec $fixtureSpec
            & $testReportObject -Report $candidate -SourceLabel $fixtureName -RepositoryRoot $repoRoot | Out-Null
        }
    }

    $actualInvalidNames = @((Get-ChildItem -LiteralPath $fixtureRoot -Filter "invalid_*.json" | ForEach-Object { $_.Name }) | Sort-Object)
    $expectedInvalidNames = @($expectedInvalidFragments.Keys | Sort-Object)
    $unexpectedInvalidNames = @($actualInvalidNames | Where-Object { $expectedInvalidNames -notcontains $_ })
    if ($unexpectedInvalidNames.Count -gt 0) {
        $failures += ("FAIL invalid: unexpected invalid fixture files exist: {0}" -f ($unexpectedInvalidNames -join ", "))
    }
}
catch {
    $failures += ("FAIL R16 friction metrics report harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        $governanceRoot = [System.IO.Path]::GetFullPath((Join-Path $repoRoot "state\governance"))
        $resolvedTempRoot = [System.IO.Path]::GetFullPath($tempRoot)
        $governanceRootWithSeparator = $governanceRoot.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
        if ($resolvedTempRoot.StartsWith($governanceRootWithSeparator, [System.StringComparison]::OrdinalIgnoreCase)) {
            Remove-Item -LiteralPath $resolvedTempRoot -Recurse -Force
        }
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R16 friction metrics report tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R16 friction metrics report tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
