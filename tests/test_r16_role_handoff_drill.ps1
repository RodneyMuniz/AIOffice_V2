$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R16RoleHandoffDrill.psm1") -Force -PassThru
$newReportObject = $module.ExportedCommands["New-R16RoleHandoffDrillObject"]
$newReport = $module.ExportedCommands["New-R16RoleHandoffDrill"]
$testReport = $module.ExportedCommands["Test-R16RoleHandoffDrill"]
$testReportObject = $module.ExportedCommands["Test-R16RoleHandoffDrillObject"]
$testContract = $module.ExportedCommands["Test-R16RoleHandoffDrillContract"]
$stableJson = $module.ExportedCommands["ConvertTo-StableJson"]
$newFixtures = $module.ExportedCommands["New-R16RoleHandoffDrillFixtureFiles"]

$validPassed = 0
$invalidRejected = 0
$failures = @()
$fixtureRootRel = "tests\fixtures\r16_role_handoff_drill"
$fixtureRoot = Join-Path $repoRoot $fixtureRootRel
$validFixtureRel = Join-Path $fixtureRootRel "valid_role_handoff_drill.json"
$validFixturePath = Join-Path $repoRoot $validFixtureRel
$stateReportRel = "state\workflow\r16_role_handoff_drill.json"
$tempRootRel = Join-Path "state\workflow" ("r16rolehandoffdrill" + [guid]::NewGuid().ToString("N"))
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
    if ([string]$FixtureSpec.base_fixture -ne "valid_role_handoff_drill.json") {
        throw "$FixtureName base_fixture must be valid_role_handoff_drill.json."
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
        "contracts\workflow\r16_role_handoff_drill.contract.json",
        "tools\R16RoleHandoffDrill.psm1",
        "tools\new_r16_role_handoff_drill.ps1",
        "tools\validate_r16_role_handoff_drill.ps1",
        "tests\test_r16_role_handoff_drill.ps1",
        $stateReportRel,
        $validFixtureRel
    )) {
        if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $requiredPath) -PathType Leaf)) {
            $failures += "FAIL required deliverable missing: $requiredPath"
        }
    }

    foreach ($forbiddenPath in @(
        "state\workflow\r16_audit_readiness_drill.json",
        "state\workflow\r16_runtime_handoff_execution.json",
        "state\memory\r16_runtime_memory.json",
        "state\retrieval\r16_vector_index.json",
        "state\workflow\r16_runtime_execution.json"
    )) {
        if (Test-Path -LiteralPath (Join-Path $repoRoot $forbiddenPath)) {
            $failures += "FAIL forbidden R16-023A overbuild artifact exists: $forbiddenPath"
        }
    }

    $contractResult = & $testContract -RepositoryRoot $repoRoot
    if ($contractResult.SourceTask -ne "R16-023" -or $contractResult.DependencyRefCount -ne 9) {
        $failures += "FAIL contract: expected R16-023 role-handoff drill contract with nine exact dependency refs."
    }
    else {
        Write-Output ("PASS contract: {0}, dependency_refs={1}, required_fields={2}" -f $contractResult.ContractId, $contractResult.DependencyRefCount, $contractResult.RequiredReportFieldCount)
        $validPassed += 1
    }

    $first = & $newReportObject -RepositoryRoot $repoRoot
    $second = & $newReportObject -RepositoryRoot $repoRoot
    if ((& $stableJson $first) -ne (& $stableJson $second)) {
        $failures += "FAIL determinism: two generated R16-023 role-handoff drill objects differ after stable normalization."
    }
    else {
        Write-Output "PASS determinism: generated R16-023 role-handoff drill object is stable across two generations."
        $validPassed += 1
    }

    $tempReportRel = Join-Path $tempRootRel "r16_role_handoff_drill.json"
    $generated = & $newReport -OutputPath $tempReportRel -RepositoryRoot $repoRoot
    if ($generated.ActiveThroughTask -ne "R16-023" -or $generated.PlannedTaskStart -ne "R16-024" -or $generated.PlannedTaskEnd -ne "R16-026" -or $generated.AggregateVerdict -ne "passed_bounded_role_handoff_drill_with_all_handoffs_blocked" -or $generated.CoreHandoffCount -ne 3 -or $generated.BlockedHandoffCount -ne 3 -or $generated.ExecutableHandoffCount -ne 0 -or $generated.ExecutableTransitionCount -ne 0 -or $generated.SourceHandoffPacketBlockedCount -ne 4) {
        $failures += "FAIL generated report: expected active through R16-023, R16-024 through R16-026 planned only, three blocked core handoffs, zero executable handoffs/transitions, four blocked source handoff packets, and passed_bounded_role_handoff_drill_with_all_handoffs_blocked."
    }
    else {
        Write-Output ("PASS generated report: core_handoffs={0}, blocked={1}, executable_handoffs={2}, executable_transitions={3}, verdict={4}" -f $generated.CoreHandoffCount, $generated.BlockedHandoffCount, $generated.ExecutableHandoffCount, $generated.ExecutableTransitionCount, $generated.AggregateVerdict)
        $validPassed += 1
    }

    $guardReport = Get-Content -LiteralPath (Join-Path $repoRoot "state\context\r16_context_budget_guard_report.json") -Raw | ConvertFrom-Json
    $expectedUpperBound = [int64]$guardReport.evaluated_budget.estimated_tokens_upper_bound
    $expectedThreshold = [int64]$guardReport.evaluated_budget.max_estimated_tokens_upper_bound

    $stateResult = & $testReport -Path $stateReportRel -RepositoryRoot $repoRoot
    if ($stateResult.ActiveThroughTask -ne "R16-023" -or $stateResult.PlannedTaskStart -ne "R16-024" -or $stateResult.PlannedTaskEnd -ne "R16-026" -or $stateResult.CoreHandoffCount -ne 3 -or $stateResult.BlockedHandoffCount -ne 3 -or $stateResult.ExecutableHandoffCount -ne 0 -or $stateResult.ExecutableTransitionCount -ne 0 -or $stateResult.SourceHandoffPacketBlockedCount -ne 4 -or $stateResult.GuardVerdict -ne "failed_closed_over_budget" -or $stateResult.EstimatedTokensUpperBound -ne $expectedUpperBound -or $stateResult.Threshold -ne $expectedThreshold) {
        $failures += ("FAIL state R16-023 report: expected failed_closed_over_budget guard values {0} over {1}, three blocked core handoffs, source blocked handoff count 4, and zero executable handoffs/transitions." -f $expectedUpperBound, $expectedThreshold)
    }
    else {
        Write-Output ("PASS state report: blocked={0}, executable_handoffs={1}, executable_transitions={2}, verdict={3}" -f $stateResult.BlockedHandoffCount, $stateResult.ExecutableHandoffCount, $stateResult.ExecutableTransitionCount, $stateResult.AggregateVerdict)
        $validPassed += 1
    }

    $validFixtureResult = & $testReport -Path $validFixtureRel -RepositoryRoot $repoRoot
    if ($validFixtureResult.CoreHandoffCount -ne 3 -or $validFixtureResult.BlockedHandoffCount -ne 3 -or $validFixtureResult.ExecutableHandoffCount -ne 0 -or $validFixtureResult.ExecutableTransitionCount -ne 0 -or $validFixtureResult.AggregateVerdict -ne "passed_bounded_role_handoff_drill_with_all_handoffs_blocked") {
        $failures += "FAIL valid fixture: expected bounded role-handoff drill with all core handoffs blocked."
    }
    else {
        Write-Output ("PASS valid fixture: {0}" -f (Join-Path $repoRoot $validFixtureRel))
        $validPassed += 1
    }

    $validFixtureObject = Read-TestJsonObject -Path $validFixturePath
    $expectedInvalidFragments = [ordered]@{
        "invalid_missing_required_top_level_field.json" = @("missing required field 'generation_boundary'")
        "invalid_missing_handoff_packet_report_ref.json" = @("missing required field 'handoff_packet_report_ref'")
        "invalid_missing_restart_compaction_recovery_drill_ref.json" = @("missing required field 'restart_compaction_recovery_drill_ref'")
        "invalid_missing_raci_transition_gate_report_ref.json" = @("missing required field 'raci_transition_gate_report_ref'")
        "invalid_missing_role_run_envelopes_ref.json" = @("missing required field 'role_run_envelopes_ref'")
        "invalid_missing_context_budget_guard_ref.json" = @("missing required field 'context_budget_guard_ref'")
        "invalid_missing_role_handoff_chain.json" = @("missing required field 'role_handoff_chain'")
        "invalid_missing_evaluated_handoffs.json" = @("missing required field 'evaluated_handoffs'")
        "invalid_missing_project_manager_to_developer_handoff.json" = @("missing project_manager -> developer handoff")
        "invalid_missing_developer_to_qa_handoff.json" = @("missing developer -> qa handoff")
        "invalid_missing_qa_to_evidence_auditor_handoff.json" = @("missing qa -> evidence_auditor handoff")
        "invalid_handoff_marked_executable.json" = @("handoff marked executable")
        "invalid_transition_marked_executable.json" = @("transition marked executable")
        "invalid_guard_verdict_not_failed_closed_over_budget.json" = @("guard verdict must be failed_closed_over_budget")
        "invalid_blocked_reason_missing_failed_closed_over_budget.json" = @("blocked_reason", "failed_closed_over_budget")
        "invalid_blocked_reason_missing_r16_020_transition_gate.json" = @("blocked_reason", "R16-020")
        "invalid_raw_chat_history_as_canonical_state.json" = @("raw chat history as canonical state")
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
        "invalid_runtime_handoff_execution_claim.json" = @("runtime handoff execution claim")
        "invalid_workflow_drill_execution_beyond_report_claim.json" = @("workflow drill execution claim beyond this report artifact")
        "invalid_runtime_memory_claim.json" = @("runtime memory claim")
        "invalid_retrieval_runtime_claim.json" = @("retrieval runtime claim")
        "invalid_vector_search_runtime_claim.json" = @("vector search runtime claim")
        "invalid_product_runtime_claim.json" = @("product runtime claim")
        "invalid_autonomous_agent_claim.json" = @("autonomous-agent claim")
        "invalid_autonomous_recovery_claim.json" = @("autonomous recovery claim")
        "invalid_external_integration_claim.json" = @("external-integration claim")
        "invalid_solved_codex_compaction_claim.json" = @("solved Codex compaction claim")
        "invalid_solved_codex_reliability_claim.json" = @("solved Codex reliability claim")
        "invalid_r16_024_implementation_claim.json" = @("R16-024 implementation claim")
        "invalid_r16_027_or_later_task_claim.json" = @("R16-027 or later task claim")
        "invalid_r13_closure_or_partial_gate_conversion_claim.json" = @("R13 closure or partial-gate conversion claim")
        "invalid_r14_caveat_removal.json" = @("R14 caveat removal")
        "invalid_r15_caveat_removal.json" = @("R15 caveat removal")
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
    $failures += ("FAIL R16 role-handoff drill harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        $workflowRoot = [System.IO.Path]::GetFullPath((Join-Path $repoRoot "state\workflow"))
        $resolvedTempRoot = [System.IO.Path]::GetFullPath($tempRoot)
        $workflowRootWithSeparator = $workflowRoot.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
        if ($resolvedTempRoot.StartsWith($workflowRootWithSeparator, [System.StringComparison]::OrdinalIgnoreCase)) {
            Remove-Item -LiteralPath $resolvedTempRoot -Recurse -Force
        }
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R16 role-handoff drill tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R16 role-handoff drill tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
