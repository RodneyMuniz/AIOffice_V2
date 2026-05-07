$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R16FinalProofReviewPackage.psm1") -Force -PassThru
$newPackageObject = $module.ExportedCommands["New-R16FinalProofReviewPackageObject"]
$newPackageSet = $module.ExportedCommands["New-R16FinalProofReviewPackageSet"]
$testPackageObject = $module.ExportedCommands["Test-R16FinalProofReviewPackageObject"]
$testPackageSet = $module.ExportedCommands["Test-R16FinalProofReviewPackageSet"]
$testPackage = $module.ExportedCommands["Test-R16FinalProofReviewPackage"]
$testEvidenceIndex = $module.ExportedCommands["Test-R16FinalEvidenceIndex"]
$testFinalHeadPacket = $module.ExportedCommands["Test-R16FinalHeadSupportPacket"]
$testContract = $module.ExportedCommands["Test-R16FinalProofReviewPackageContract"]
$stableJson = $module.ExportedCommands["ConvertTo-StableJson"]
$newFixtures = $module.ExportedCommands["New-R16FinalProofReviewPackageFixtureFiles"]

$validPassed = 0
$invalidRejected = 0
$failures = @()
$fixtureRootRel = "tests\fixtures\r16_final_proof_review_package"
$fixtureRoot = Join-Path $repoRoot $fixtureRootRel
$validFixtureRel = Join-Path $fixtureRootRel "valid_final_proof_review_package.json"
$validFixturePath = Join-Path $repoRoot $validFixtureRel
$packageRel = "state\proof_reviews\r16_operational_memory_artifact_map_role_workflow_foundation\r16_026_final_proof_review_package\r16_final_proof_review_package.json"
$evidenceIndexRel = "state\proof_reviews\r16_operational_memory_artifact_map_role_workflow_foundation\r16_026_final_proof_review_package\evidence_index.json"
$finalHeadPacketRel = "state\proof_reviews\r16_operational_memory_artifact_map_role_workflow_foundation\r16_026_final_proof_review_package\final_head_support_packet.json"
$tempRootRel = Join-Path "state\proof_reviews\r16_operational_memory_artifact_map_role_workflow_foundation" ("r16finalproofreviewpackage" + [guid]::NewGuid().ToString("N"))
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
    if ([string]$FixtureSpec.base_fixture -ne "valid_final_proof_review_package.json") {
        throw "$FixtureName base_fixture must be valid_final_proof_review_package.json."
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
        "contracts\governance\r16_final_proof_review_package.contract.json",
        "tools\R16FinalProofReviewPackage.psm1",
        "tools\new_r16_final_proof_review_package.ps1",
        "tools\validate_r16_final_proof_review_package.ps1",
        "tests\test_r16_final_proof_review_package.ps1",
        $packageRel,
        $evidenceIndexRel,
        $finalHeadPacketRel,
        $validFixtureRel
    )) {
        if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $requiredPath) -PathType Leaf)) {
            $failures += "FAIL required deliverable missing: $requiredPath"
        }
    }

    foreach ($forbiddenPath in @(
        "state\audit\r16_final_audit_acceptance.json",
        "state\audit\r16_closeout_completion.json",
        "state\workflow\r16_runtime_execution.json",
        "state\memory\r16_runtime_memory.json",
        "state\retrieval\r16_vector_index.json",
        "state\integrations\r16_external_integrations.json",
        "state\proof_reviews\r16_operational_memory_artifact_map_role_workflow_foundation\r16_026_final_proof_review_package\proof_review.json"
    )) {
        if (Test-Path -LiteralPath (Join-Path $repoRoot $forbiddenPath)) {
            $failures += "FAIL forbidden R16-026 overclaim artifact exists: $forbiddenPath"
        }
    }

    $contractResult = & $testContract -RepositoryRoot $repoRoot
    if ($contractResult.SourceTask -ne "R16-026" -or $contractResult.RequiredEvidencePathCount -ne 25 -or $contractResult.RequiredValidationCommandCount -ne 7) {
        $failures += "FAIL contract: expected R16-026 contract with 25 exact evidence paths and 7 focused validation commands."
    }
    else {
        Write-Output ("PASS contract: {0}, exact_evidence_paths={1}, validation_commands={2}" -f $contractResult.ContractId, $contractResult.RequiredEvidencePathCount, $contractResult.RequiredValidationCommandCount)
        $validPassed += 1
    }

    $first = & $newPackageObject -RepositoryRoot $repoRoot
    $second = & $newPackageObject -RepositoryRoot $repoRoot
    if ((& $stableJson $first) -ne (& $stableJson $second)) {
        $failures += "FAIL determinism: two generated R16-026 final proof/review package objects differ after stable normalization."
    }
    else {
        Write-Output "PASS determinism: generated R16-026 final proof/review package object is stable across two generations."
        $validPassed += 1
    }

    $generated = & $newPackageSet -OutputRoot $tempRootRel -RepositoryRoot $repoRoot
    if ($generated.AggregateVerdict -ne "generated_r16_final_proof_review_package_candidate" -or $generated.ExactEvidenceRefCount -ne 25 -or $generated.IndexedEvidenceCount -ne 25 -or $generated.ProofReviewRefCount -ne 25 -or $generated.ValidationManifestRefCount -ne 25 -or $generated.GuardVerdict -ne "failed_closed_over_budget" -or $generated.LatestGuardUpperBound -ne 1364079 -or $generated.Threshold -ne 150000) {
        $failures += "FAIL generated package set: expected candidate verdict, 25 exact/indexed evidence refs, 25 proof-review refs, 25 validation manifests, and guard 1364079 over 150000."
    }
    else {
        Write-Output ("PASS generated package set: exact_evidence_refs={0}, indexed_evidence={1}, proof_review_refs={2}, verdict={3}, guard={4}/{5}" -f $generated.ExactEvidenceRefCount, $generated.IndexedEvidenceCount, $generated.ProofReviewRefCount, $generated.AggregateVerdict, $generated.LatestGuardUpperBound, $generated.Threshold)
        $validPassed += 1
    }

    $stateResult = & $testPackageSet -PackagePath $packageRel -EvidenceIndexPath $evidenceIndexRel -FinalHeadSupportPacketPath $finalHeadPacketRel -RepositoryRoot $repoRoot
    if ($stateResult.AggregateVerdict -ne "generated_r16_final_proof_review_package_candidate" -or $stateResult.ExactEvidenceRefCount -ne 25 -or $stateResult.IndexedEvidenceCount -ne 25 -or $stateResult.ProofReviewRefCount -ne 25 -or $stateResult.ValidationManifestRefCount -ne 25 -or $stateResult.GuardVerdict -ne "failed_closed_over_budget" -or $stateResult.LatestGuardUpperBound -ne 1364079 -or $stateResult.Threshold -ne 150000 -or $stateResult.PreviousAcceptedBaseline -ne "8f3453529c763476b597926f53a9dd1899dece0b") {
        $failures += "FAIL state R16-026 package set: expected candidate package, exact refs, final-head support packet, and failed-closed guard posture."
    }
    else {
        Write-Output ("PASS state package set: exact_evidence_refs={0}, indexed_evidence={1}, proof_review_refs={2}, observed_head={3}, verdict={4}" -f $stateResult.ExactEvidenceRefCount, $stateResult.IndexedEvidenceCount, $stateResult.ProofReviewRefCount, $stateResult.ObservedHead, $stateResult.AggregateVerdict)
        $validPassed += 1
    }

    $packageOnly = & $testPackage -Path $packageRel -RepositoryRoot $repoRoot
    $evidenceOnly = & $testEvidenceIndex -Path $evidenceIndexRel -RepositoryRoot $repoRoot
    $packetOnly = & $testFinalHeadPacket -Path $finalHeadPacketRel -RepositoryRoot $repoRoot
    if ($packageOnly.ExactEvidenceRefCount -ne 25 -or $evidenceOnly.IndexedEvidenceCount -ne 25 -or $packetOnly.ValidationCommandCount -ne 7) {
        $failures += "FAIL individual validators: expected package, evidence index, and final-head packet to validate independently."
    }
    else {
        Write-Output ("PASS individual validators: package_refs={0}, index_refs={1}, packet_commands={2}" -f $packageOnly.ExactEvidenceRefCount, $evidenceOnly.IndexedEvidenceCount, $packetOnly.ValidationCommandCount)
        $validPassed += 1
    }

    $validFixtureResult = & $testPackage -Path $validFixtureRel -RepositoryRoot $repoRoot
    if ($validFixtureResult.AggregateVerdict -ne "generated_r16_final_proof_review_package_candidate" -or $validFixtureResult.ExactEvidenceRefCount -ne 25 -or $validFixtureResult.ProofReviewRefCount -ne 25 -or $validFixtureResult.GuardVerdict -ne "failed_closed_over_budget") {
        $failures += "FAIL valid fixture: expected R16-026 candidate fixture with R16-001 through R16-025 indexed evidence and no overclaims."
    }
    else {
        Write-Output ("PASS valid fixture: {0}" -f (Join-Path $repoRoot $validFixtureRel))
        $validPassed += 1
    }

    $validFixtureObject = Read-TestJsonObject -Path $validFixturePath
    $expectedInvalidFragments = [ordered]@{
        "invalid_missing_required_top_level_field.json" = @("missing required field 'generation_boundary'")
        "invalid_missing_generated_from_head.json" = @("missing required field 'generated_from_head'")
        "invalid_missing_accepted_task_range.json" = @("missing required field 'accepted_task_range'")
        "invalid_missing_exact_evidence_refs.json" = @("missing required field 'exact_evidence_refs'")
        "invalid_missing_proof_review_refs.json" = @("missing required field 'proof_review_refs'")
        "invalid_missing_validation_manifest_refs.json" = @("missing required field 'validation_manifest_refs'")
        "invalid_missing_current_guard_posture.json" = @("missing required field 'current_guard_posture'")
        "invalid_missing_friction_metrics_summary.json" = @("missing required field 'friction_metrics_summary'")
        "invalid_missing_audit_readiness_summary.json" = @("missing required field 'audit_readiness_summary'")
        "invalid_missing_preserved_boundaries.json" = @("missing required field 'preserved_boundaries'")
        "invalid_missing_non_claims.json" = @("missing required field 'non_claims'")
        "invalid_guard_verdict_not_failed_closed.json" = @("guard verdict")
        "invalid_threshold_changed.json" = @("threshold must be 150000")
        "invalid_executable_handoff_claim.json" = @("executable handoff claim")
        "invalid_executable_transition_claim.json" = @("executable transition claim")
        "invalid_runtime_execution_claim.json" = @("runtime execution claim")
        "invalid_runtime_memory_claim.json" = @("runtime memory claim")
        "invalid_retrieval_runtime_claim.json" = @("retrieval runtime claim")
        "invalid_vector_search_runtime_claim.json" = @("vector search runtime claim")
        "invalid_product_runtime_claim.json" = @("product runtime claim")
        "invalid_autonomous_agent_claim.json" = @("autonomous-agent claim")
        "invalid_external_integration_claim.json" = @("external-integration claim")
        "invalid_solved_codex_compaction_claim.json" = @("solved Codex compaction claim")
        "invalid_solved_codex_reliability_claim.json" = @("solved Codex reliability claim")
        "invalid_final_external_audit_acceptance_claim.json" = @("final external audit acceptance claim")
        "invalid_main_merge_claim.json" = @("main merge claim")
        "invalid_r13_closure_claim.json" = @("R13 closure claim")
        "invalid_r13_partial_gate_conversion_claim.json" = @("R13 partial-gate conversion claim")
        "invalid_r14_caveat_removal.json" = @("R14 caveat removal")
        "invalid_r15_caveat_removal.json" = @("R15 caveat removal")
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
        "invalid_r16_027_or_later_task_claim.json" = @("R16-027 or later task claim")
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
            & $testPackageObject -Package $candidate -SourceLabel $fixtureName -RepositoryRoot $repoRoot | Out-Null
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
    $failures += ("FAIL R16 final proof/review package harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        $proofRoot = [System.IO.Path]::GetFullPath((Join-Path $repoRoot "state\proof_reviews\r16_operational_memory_artifact_map_role_workflow_foundation"))
        $resolvedTempRoot = [System.IO.Path]::GetFullPath($tempRoot)
        $proofRootWithSeparator = $proofRoot.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
        if ($resolvedTempRoot.StartsWith($proofRootWithSeparator, [System.StringComparison]::OrdinalIgnoreCase)) {
            Remove-Item -LiteralPath $resolvedTempRoot -Recurse -Force
        }
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R16 final proof/review package tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R16 final proof/review package tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
