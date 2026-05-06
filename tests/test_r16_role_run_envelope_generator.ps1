$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R16RoleRunEnvelopeGenerator.psm1") -Force -PassThru
$testEnvelopes = $module.ExportedCommands["Test-R16RoleRunEnvelopes"]
$testEnvelopesObject = $module.ExportedCommands["Test-R16RoleRunEnvelopesObject"]

$stateArtifactRel = "state\workflow\r16_role_run_envelopes.json"
$fixtureRootRel = "tests\fixtures\r16_role_run_envelope_generator"
$validFixtureRel = Join-Path $fixtureRootRel "valid_role_run_envelopes.json"
$fixtureRoot = Join-Path $repoRoot $fixtureRootRel
$validFixturePath = Join-Path $repoRoot $validFixtureRel

$validPassed = 0
$invalidRejected = 0
$failures = @()

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
        if ($part -notmatch '^([A-Za-z_][A-Za-z0-9_]*)(?:\[(\d+)\])?$') {
            throw "mutation_path '$Path' has unsupported segment '$part'."
        }

        $indexValue = $null
        if ($Matches.ContainsKey(2) -and $Matches[2] -ne "") {
            $indexValue = [int]$Matches[2]
        }

        $segments += [pscustomobject]@{
            Name = $Matches[1]
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

    if ($mutationValue -is [string] -and $mutationValue -like "__REMOVE_ROLE:*__") {
        $roleId = $mutationValue.Substring("__REMOVE_ROLE:".Length)
        $roleId = $roleId.Substring(0, $roleId.Length - 2)
        $envelopes = @(Get-MutationPathValue -Artifact $Artifact -Path $mutationPath)
        Set-MutationPathValue -Artifact $Artifact -Path $mutationPath -Value @($envelopes | Where-Object { [string]$_.role_id -ne $roleId })
        return
    }

    if ($mutationValue -is [string] -and $mutationValue -eq "__DUPLICATE_FIRST_ITEM__") {
        $items = @(Get-MutationPathValue -Artifact $Artifact -Path $mutationPath)
        if ($items.Count -eq 0) {
            throw "mutation_path '$mutationPath' cannot duplicate from an empty array."
        }

        Set-MutationPathValue -Artifact $Artifact -Path $mutationPath -Value @($items + (Copy-TestJsonObject -Value $items[0]))
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
    if ([string]$FixtureSpec.base_fixture -ne "valid_role_run_envelopes.json") {
        throw "$FixtureName base_fixture must be valid_role_run_envelopes.json."
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
    foreach ($requiredPath in @(
        "tools\R16RoleRunEnvelopeGenerator.psm1",
        "tools\new_r16_role_run_envelopes.ps1",
        "tools\validate_r16_role_run_envelopes.ps1",
        "tests\test_r16_role_run_envelope_generator.ps1",
        $stateArtifactRel,
        $validFixtureRel,
        "state\proof_reviews\r16_operational_memory_artifact_map_role_workflow_foundation\r16_019_role_run_envelope_generator\proof_review.json",
        "state\proof_reviews\r16_operational_memory_artifact_map_role_workflow_foundation\r16_019_role_run_envelope_generator\evidence_index.json",
        "state\proof_reviews\r16_operational_memory_artifact_map_role_workflow_foundation\r16_019_role_run_envelope_generator\validation_manifest.md"
    )) {
        if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $requiredPath) -PathType Leaf)) {
            $failures += "FAIL required deliverable missing: $requiredPath"
        }
    }

    foreach ($forbiddenPath in @(
        "contracts\workflow\r16_handoff_packet.contract.json",
        "contracts\workflow\r16_raci_transition_gate.contract.json",
        "tools\R16HandoffPacketGenerator.psm1",
        "state\workflow\r16_handoff_packets.json",
        "state\workflow\r16_workflow_drill.json"
    )) {
        if (Test-Path -LiteralPath (Join-Path $repoRoot $forbiddenPath)) {
            $failures += "FAIL forbidden R16-019 overbuild artifact exists: $forbiddenPath"
        }
    }

    $guardReport = Get-Content -LiteralPath (Join-Path $repoRoot "state\context\r16_context_budget_guard_report.json") -Raw | ConvertFrom-Json
    $expectedEstimatedUpperBound = [int64]$guardReport.evaluated_budget.estimated_tokens_upper_bound
    $expectedMaxUpperBound = [int64]$guardReport.evaluated_budget.max_estimated_tokens_upper_bound

    $stateResult = & $testEnvelopes -Path $stateArtifactRel -RepositoryRoot $repoRoot
    if ($stateResult.SourceTask -ne "R16-019" -or $stateResult.ActiveThroughTask -ne "R16-019" -or $stateResult.PlannedTaskStart -ne "R16-020" -or $stateResult.PlannedTaskEnd -ne "R16-026") {
        $failures += "FAIL committed artifact: expected R16-019 identity and R16 active through R16-019 only with R16-020 through R16-026 planned only."
    }
    elseif ($stateResult.EnvelopeCount -ne 8 -or $stateResult.BlockedEnvelopeCount -ne 8 -or $stateResult.ExecutableEnvelopeCount -ne 0 -or $stateResult.AggregateVerdict -ne "passed_with_all_envelopes_blocked_by_guard") {
        $failures += "FAIL committed artifact: expected eight deterministic envelopes, all blocked, none executable, and aggregate verdict passed_with_all_envelopes_blocked_by_guard."
    }
    elseif ($stateResult.BudgetGuardVerdict -ne "failed_closed_over_budget" -or $stateResult.EstimatedTokensUpperBound -ne $expectedEstimatedUpperBound -or $stateResult.MaxEstimatedTokensUpperBound -ne $expectedMaxUpperBound) {
        $failures += ("FAIL committed artifact: expected failed_closed_over_budget guard values {0} over {1} to be preserved." -f $expectedEstimatedUpperBound, $expectedMaxUpperBound)
    }
    else {
        Write-Output ("PASS committed R16-019 role-run envelopes: {0}" -f (Join-Path $repoRoot $stateArtifactRel))
        $validPassed += 1
    }

    $validFixtureResult = & $testEnvelopes -Path $validFixtureRel -RepositoryRoot $repoRoot
    if ($validFixtureResult.EnvelopeCount -ne 8 -or $validFixtureResult.BlockedEnvelopeCount -ne 8 -or $validFixtureResult.ExecutableEnvelopeCount -ne 0 -or $validFixtureResult.AggregateVerdict -ne "passed_with_all_envelopes_blocked_by_guard") {
        $failures += "FAIL valid fixture: expected complete eight-role envelope set, all blocked or non-executable due to failed_closed_over_budget."
    }
    else {
        Write-Output ("PASS valid fixture: {0}" -f (Join-Path $repoRoot $validFixtureRel))
        $validPassed += 1
    }

    $validFixtureObject = Read-TestJsonObject -Path $validFixturePath
    $expectedInvalidFragments = [ordered]@{
        "invalid_missing_required_top_level_field.json" = @("missing required field 'envelopes'")
        "invalid_missing_role_envelope.json" = @("envelopes role_id", "qa")
        "invalid_duplicate_role_envelope.json" = @("envelopes role_id", "must contain exactly")
        "invalid_role_id.json" = @("envelopes role_id", "must contain exactly")
        "invalid_role_display_name_mismatch.json" = @("role display name mismatch")
        "invalid_missing_memory_pack_ref.json" = @("memory_pack_ref")
        "invalid_missing_context_load_plan_ref.json" = @("context_load_plan_ref")
        "invalid_missing_context_budget_estimate_ref.json" = @("context_budget_estimate_ref")
        "invalid_missing_context_budget_guard_ref.json" = @("context_budget_guard_ref")
        "invalid_missing_budget_guard_status.json" = @("budget_guard_status")
        "invalid_executable_failed_closed_guard.json" = @("executable envelope", "failed_closed_over_budget")
        "invalid_blocked_reason_missing_failed_closed_over_budget.json" = @("blocked_reason", "failed_closed_over_budget")
        "invalid_wildcard_path.json" = @("wildcard path")
        "invalid_directory_only_ref.json" = @("directory-only ref")
        "invalid_broad_repo_scan_claim.json" = @("broad repo scan claim")
        "invalid_full_repo_scan_claim.json" = @("full repo scan claim")
        "invalid_scratch_temp_ref.json" = @("scratch/temp path")
        "invalid_absolute_path.json" = @("absolute path")
        "invalid_parent_traversal_path.json" = @("parent traversal path")
        "invalid_url_or_remote_ref.json" = @("URL or remote ref")
        "invalid_raw_chat_history_loading_claim.json" = @("raw chat history loading claim")
        "invalid_report_as_machine_proof_misuse.json" = @("report-as-machine-proof misuse")
        "invalid_exact_provider_tokenization_claim.json" = @("exact provider tokenization claim")
        "invalid_exact_provider_billing_claim.json" = @("exact provider billing claim")
        "invalid_runtime_memory_claim.json" = @("runtime memory claim")
        "invalid_retrieval_runtime_claim.json" = @("retrieval runtime claim")
        "invalid_vector_search_runtime_claim.json" = @("vector search runtime claim")
        "invalid_product_runtime_claim.json" = @("product runtime claim")
        "invalid_autonomous_agent_claim.json" = @("autonomous-agent claim")
        "invalid_external_integration_claim.json" = @("external-integration claim")
        "invalid_raci_transition_gate_implementation_claim.json" = @("RACI transition gate implementation claim")
        "invalid_handoff_packet_implementation_claim.json" = @("handoff packet implementation claim")
        "invalid_workflow_drill_claim.json" = @("workflow drill claim")
        "invalid_r16_020_implementation_claim.json" = @("R16-020 implementation claim")
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
            & $testEnvelopesObject -Artifact $candidate -SourceLabel $fixtureName -RepositoryRoot $repoRoot | Out-Null
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
    $failures += ("FAIL R16 role-run envelope generator harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R16 role-run envelope generator tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R16 role-run envelope generator tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
