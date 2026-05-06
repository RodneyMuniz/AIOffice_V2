$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R16RaciTransitionGate.psm1") -Force -PassThru
$newReportObject = $module.ExportedCommands["New-R16RaciTransitionGateReportObject"]
$newReport = $module.ExportedCommands["New-R16RaciTransitionGateReport"]
$testReport = $module.ExportedCommands["Test-R16RaciTransitionGateReport"]
$testReportObject = $module.ExportedCommands["Test-R16RaciTransitionGateReportObject"]
$testContract = $module.ExportedCommands["Test-R16RaciTransitionGateReportContract"]
$stableJson = $module.ExportedCommands["ConvertTo-StableJson"]
$newFixtures = $module.ExportedCommands["New-R16RaciTransitionGateFixtureFiles"]

$validPassed = 0
$invalidRejected = 0
$failures = @()
$fixtureRootRel = "tests\fixtures\r16_raci_transition_gate"
$fixtureRoot = Join-Path $repoRoot $fixtureRootRel
$validFixtureRel = Join-Path $fixtureRootRel "valid_raci_transition_gate_report.json"
$validFixturePath = Join-Path $repoRoot $validFixtureRel
$stateReportRel = "state\workflow\r16_raci_transition_gate_report.json"
$tempRootRel = Join-Path "state\workflow" ("r16racitransitiongate" + [guid]::NewGuid().ToString("N"))
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

function Get-MutationPathValue {
    param(
        [Parameter(Mandatory = $true)]$Artifact,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $current = $Artifact
    foreach ($segment in @(Get-FixturePathSegments -Path $Path)) {
        $current = Get-ObjectPropertyValue -InputObject $current -Name $segment.Name
        if ($null -ne $segment.Index) {
            $items = @($current)
            if ($segment.Index -ge $items.Count) {
                throw "mutation_path '$Path' index $($segment.Index) is out of range."
            }

            $current = $items[$segment.Index]
        }
    }

    return $current
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

    $removeEvidencePrefix = "__REMOVE_REQUIRED_EVIDENCE:"
    if ($mutationValue -is [string] -and $mutationValue.StartsWith($removeEvidencePrefix) -and $mutationValue.EndsWith("__")) {
        $requiredPath = $mutationValue.Substring($removeEvidencePrefix.Length, $mutationValue.Length - $removeEvidencePrefix.Length - 2)
        $refs = @(Get-MutationPathValue -Artifact $Artifact -Path $mutationPath)
        Set-MutationPathValue -Artifact $Artifact -Path $mutationPath -Value @($refs | Where-Object { [string]$_.path -ne $requiredPath })
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
    if ([string]$FixtureSpec.base_fixture -ne "valid_raci_transition_gate_report.json") {
        throw "$FixtureName base_fixture must be valid_raci_transition_gate_report.json."
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
        "contracts\workflow\r16_raci_transition_gate_report.contract.json",
        "tools\R16RaciTransitionGate.psm1",
        "tools\test_r16_raci_transition_gate.ps1",
        "tools\validate_r16_raci_transition_gate_report.ps1",
        "tests\test_r16_raci_transition_gate.ps1",
        $stateReportRel,
        $validFixtureRel
    )) {
        if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $requiredPath) -PathType Leaf)) {
            $failures += "FAIL required deliverable missing: $requiredPath"
        }
    }

    foreach ($forbiddenPath in @(
        "contracts\workflow\r16_handoff_packet.contract.json",
        "state\workflow\r16_handoff_packets.json",
        "state\workflow\r16_workflow_drill.json",
        "state\memory\r16_runtime_memory.json",
        "state\retrieval\r16_vector_index.json"
    )) {
        if (Test-Path -LiteralPath (Join-Path $repoRoot $forbiddenPath)) {
            $failures += "FAIL forbidden R16-020 overbuild artifact exists: $forbiddenPath"
        }
    }

    $contractResult = & $testContract -RepositoryRoot $repoRoot
    if ($contractResult.SourceTask -ne "R16-020" -or $contractResult.DependencyRefCount -ne 7) {
        $failures += "FAIL contract: expected R16-020 contract with seven exact dependency refs."
    }
    else {
        Write-Output ("PASS contract: {0}, dependency_refs={1}, required_fields={2}" -f $contractResult.ContractId, $contractResult.DependencyRefCount, $contractResult.RequiredReportFieldCount)
        $validPassed += 1
    }

    $first = & $newReportObject -RepositoryRoot $repoRoot
    $second = & $newReportObject -RepositoryRoot $repoRoot
    if ((& $stableJson $first) -ne (& $stableJson $second)) {
        $failures += "FAIL determinism: two generated R16-020 RACI transition gate report objects differ after stable normalization."
    }
    else {
        Write-Output "PASS determinism: generated R16-020 RACI transition gate report object is stable across two generations."
        $validPassed += 1
    }

    $tempReportRel = Join-Path $tempRootRel "r16_raci_transition_gate_report.json"
    $generated = & $newReport -OutputPath $tempReportRel -RepositoryRoot $repoRoot
    if ($generated.ActiveThroughTask -ne "R16-020" -or $generated.PlannedTaskStart -ne "R16-021" -or $generated.PlannedTaskEnd -ne "R16-026" -or $generated.AggregateVerdict -ne "failed_closed_all_transitions_blocked_by_budget_guard" -or $generated.BlockedTransitionCount -ne 4 -or $generated.AllowedTransitionCount -ne 0) {
        $failures += "FAIL generated report: expected active through R16-020, R16-021 through R16-026 planned only, four blocked transitions, zero allowed transitions, and failed_closed_all_transitions_blocked_by_budget_guard."
    }
    else {
        Write-Output ("PASS generated report: transitions={0}, blocked={1}, allowed={2}, verdict={3}" -f $generated.TransitionCount, $generated.BlockedTransitionCount, $generated.AllowedTransitionCount, $generated.AggregateVerdict)
        $validPassed += 1
    }

    $guardReport = Get-Content -LiteralPath (Join-Path $repoRoot "state\context\r16_context_budget_guard_report.json") -Raw | ConvertFrom-Json
    $expectedEstimatedUpperBound = [int64]$guardReport.evaluated_budget.estimated_tokens_upper_bound
    $expectedMaxUpperBound = [int64]$guardReport.evaluated_budget.max_estimated_tokens_upper_bound

    $stateResult = & $testReport -Path $stateReportRel -RepositoryRoot $repoRoot
    if ($stateResult.ActiveThroughTask -ne "R16-020" -or $stateResult.PlannedTaskStart -ne "R16-021" -or $stateResult.PlannedTaskEnd -ne "R16-026" -or $stateResult.BlockedTransitionCount -ne 4 -or $stateResult.AllowedTransitionCount -ne 0 -or $stateResult.BudgetGuardVerdict -ne "failed_closed_over_budget" -or $stateResult.EstimatedTokensUpperBound -ne $expectedEstimatedUpperBound -or $stateResult.MaxEstimatedTokensUpperBound -ne $expectedMaxUpperBound) {
        $failures += ("FAIL committed R16-020 report: expected failed_closed_over_budget guard values {0} over {1} and all transitions blocked." -f $expectedEstimatedUpperBound, $expectedMaxUpperBound)
    }
    else {
        Write-Output ("PASS committed R16-020 report: blocked={0}, allowed={1}, verdict={2}" -f $stateResult.BlockedTransitionCount, $stateResult.AllowedTransitionCount, $stateResult.AggregateVerdict)
        $validPassed += 1
    }

    $validFixtureResult = & $testReport -Path $validFixtureRel -RepositoryRoot $repoRoot
    if ($validFixtureResult.BlockedTransitionCount -ne 4 -or $validFixtureResult.AllowedTransitionCount -ne 0 -or $validFixtureResult.AggregateVerdict -ne "failed_closed_all_transitions_blocked_by_budget_guard") {
        $failures += "FAIL valid fixture: expected all evaluated execution transitions blocked with zero allowed transitions."
    }
    else {
        Write-Output ("PASS valid fixture: {0}" -f (Join-Path $repoRoot $validFixtureRel))
        $validPassed += 1
    }

    $validFixtureObject = Read-TestJsonObject -Path $validFixturePath
    $expectedInvalidFragments = [ordered]@{
        "invalid_missing_required_top_level_field.json" = @("missing required field 'gate_mode'")
        "invalid_missing_role_run_envelopes_ref.json" = @("missing required field 'role_run_envelopes_ref'")
        "invalid_missing_context_budget_guard_ref.json" = @("missing required field 'context_budget_guard_ref'")
        "invalid_missing_evaluated_transitions.json" = @("missing required field 'evaluated_transitions'")
        "invalid_transition_allowed_failed_guard.json" = @("allowed while", "failed_closed_over_budget")
        "invalid_transition_allowed_source_not_executable.json" = @("source envelope executable=false")
        "invalid_transition_allowed_target_not_executable.json" = @("target envelope executable=false")
        "invalid_unknown_source_role.json" = @("unknown source role")
        "invalid_unknown_target_role.json" = @("unknown target role")
        "invalid_action_not_in_allowed_actions.json" = @("action not in allowed_actions")
        "invalid_missing_required_evidence_ref.json" = @("missing required evidence ref")
        "invalid_evidence_ref_path_wildcard.json" = @("wildcard path")
        "invalid_evidence_ref_directory_only.json" = @("directory-only ref")
        "invalid_evidence_ref_scratch_temp.json" = @("scratch/temp path")
        "invalid_evidence_ref_absolute_path.json" = @("absolute path")
        "invalid_evidence_ref_parent_traversal.json" = @("parent traversal path")
        "invalid_evidence_ref_url_remote.json" = @("URL or remote ref")
        "invalid_broad_repo_scan_claim.json" = @("broad repo scan claim")
        "invalid_full_repo_scan_claim.json" = @("full repo scan claim")
        "invalid_raw_chat_history_evidence_claim.json" = @("raw chat history evidence claim")
        "invalid_report_as_machine_proof_misuse.json" = @("report-as-machine-proof misuse")
        "invalid_exact_provider_tokenization_claim.json" = @("exact provider tokenization claim")
        "invalid_exact_provider_billing_claim.json" = @("exact provider billing claim")
        "invalid_runtime_memory_claim.json" = @("runtime memory claim")
        "invalid_retrieval_runtime_claim.json" = @("retrieval runtime claim")
        "invalid_vector_search_runtime_claim.json" = @("vector search runtime claim")
        "invalid_product_runtime_claim.json" = @("product runtime claim")
        "invalid_autonomous_agent_claim.json" = @("autonomous-agent claim")
        "invalid_external_integration_claim.json" = @("external-integration claim")
        "invalid_handoff_packet_implementation_claim.json" = @("handoff packet implementation claim")
        "invalid_workflow_drill_claim.json" = @("workflow drill claim")
        "invalid_r16_021_implementation_claim.json" = @("R16-021 implementation claim")
        "invalid_r16_027_or_later_task_claim.json" = @("R16-027 or later task claim")
        "invalid_r13_closure_or_partial_gate_conversion_claim.json" = @("r13", "closed must be False")
        "invalid_r14_caveat_removal.json" = @("r14", "caveat removal")
        "invalid_r15_caveat_removal.json" = @("r15", "caveat removal")
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
    $failures += ("FAIL R16 RACI transition gate harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R16 RACI transition gate tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R16 RACI transition gate tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
