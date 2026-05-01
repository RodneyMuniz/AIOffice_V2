$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R13BoundedFixExecution.psm1") -Force -PassThru
$testPacket = $module.ExportedCommands["Test-R13BoundedFixExecutionPacket"]
$newPacket = $module.ExportedCommands["New-R13BoundedFixExecutionPacket"]

$validRoot = Join-Path $repoRoot "state\fixtures\valid\actionable_qa"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\actionable_qa\r13_bounded_fix_execution"
$cycleQueuePath = Join-Path $repoRoot "state\cycles\r13_api_first_qa_pipeline_and_operator_control_room_product_slice\qa\r13_004_fix_queue.json"
$cyclePacketPath = Join-Path $repoRoot "state\cycles\r13_api_first_qa_pipeline_and_operator_control_room_product_slice\qa\r13_005_bounded_fix_execution_packet.json"
$validatorPath = Join-Path $repoRoot "tools\validate_r13_bounded_fix_execution.ps1"
$cliPath = Join-Path $repoRoot "tools\new_r13_bounded_fix_execution_packet.ps1"
$invalidQueueRoot = Join-Path $repoRoot "state\fixtures\invalid\actionable_qa\r13_qa_fix_queue"
$validPassed = 0
$invalidRejected = 0
$failures = @()

function Invoke-ExpectedRefusal {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [string[]]$RequiredFragments,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Action
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

function Invoke-PowerShellFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        [string[]]$Arguments = @()
    )

    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $FilePath @Arguments 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }

    return [pscustomobject]@{
        ExitCode = $exitCode
        Output = @($output | ForEach-Object { [string]$_ })
    }
}

function Read-JsonObject {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json)
}

function Assert-ContainsAll {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [string[]]$Actual,
        [Parameter(Mandatory = $true)]
        [string[]]$Expected
    )

    $missing = @($Expected | Where-Object { $Actual -notcontains $_ })
    if ($missing.Count -gt 0) {
        $script:failures += ("FAIL preservation: {0} missed {1}." -f $Label, ($missing -join ", "))
    }
}

try {
    $authorizationFixturePath = Join-Path $validRoot "r13_bounded_fix_execution.authorization.valid.json"
    $authorizationValidation = & $testPacket -PacketPath $authorizationFixturePath
    if ($authorizationValidation.ExecutionMode -ne "authorization_only" -or $authorizationValidation.AggregateVerdict -ne "authorized_for_future_execution") {
        $failures += "FAIL valid: authorization fixture did not validate as future-execution authorization only."
    }
    else {
        Write-Output ("PASS valid authorization fixture: {0}" -f $authorizationValidation.ExecutionId)
        $validPassed += 1
    }

    $dryRunFixturePath = Join-Path $validRoot "r13_bounded_fix_execution.dry_run.valid.json"
    $dryRunValidation = & $testPacket -PacketPath $dryRunFixturePath
    if ($dryRunValidation.ExecutionMode -ne "dry_run" -or $dryRunValidation.AggregateVerdict -ne "dry_run_complete") {
        $failures += "FAIL valid: dry-run fixture did not validate as dry-run/no-mutation."
    }
    else {
        Write-Output ("PASS valid dry-run fixture: {0}" -f $dryRunValidation.ExecutionId)
        $validPassed += 1
    }

    $expectedInvalidFragments = @{
        "selected_fix_item_not_in_queue.invalid.json" = @("not present", "source queue")
        "selected_source_issue_not_mapped.invalid.json" = @("not mapped", "selected fix items")
        "outside_repo_target_file.invalid.json" = @("repository-relative", "inside the repository")
        "broad_scope_without_authorization.invalid.json" = @("broad scope", "authorization")
        "missing_rollback_plan.invalid.json" = @("rollback_plan")
        "missing_validation_commands.invalid.json" = @("validation_commands")
        "missing_expected_evidence_refs.invalid.json" = @("expected_evidence_refs")
        "executor_self_certification_as_execution_authority.invalid.json" = @("executor self-certification", "authority")
        "local_only_as_external_proof.invalid.json" = @("local-only", "external proof")
        "claims_rerun_before_rerun_task.invalid.json" = @("claims rerun", "rerun task")
        "claims_comparison_before_comparison_task.invalid.json" = @("comparison", "before")
        "claims_external_replay_before_external_task.invalid.json" = @("external replay", "external task")
        "claims_signoff_before_signoff_task.invalid.json" = @("signoff", "signoff task")
        "aggregate_passed_before_execution.invalid.json" = @("authorization_only", "authorized")
        "missing_non_claims.invalid.json" = @("non_claims")
        "r14_successor_opened.invalid.json" = @("R14", "successor")
    }

    $invalidFiles = @(Get-ChildItem -LiteralPath $invalidRoot -Filter "*.invalid.json" -File | Sort-Object Name)
    foreach ($expectedName in $expectedInvalidFragments.Keys) {
        if (@($invalidFiles | Where-Object { $_.Name -eq $expectedName }).Count -ne 1) {
            $failures += "FAIL fixture: missing invalid fixture '$expectedName'."
        }
    }

    foreach ($invalidFile in $invalidFiles) {
        if (-not $expectedInvalidFragments.ContainsKey($invalidFile.Name)) {
            $failures += "FAIL fixture: unexpected invalid fixture '$($invalidFile.Name)' lacks expected refusal fragments."
            continue
        }
        Invoke-ExpectedRefusal -Label $invalidFile.Name -RequiredFragments $expectedInvalidFragments[$invalidFile.Name] -Action {
            & $testPacket -PacketPath $invalidFile.FullName | Out-Null
        }
    }

    $sourceQueue = Read-JsonObject -Path $cycleQueuePath
    $generatedAll = & $newPacket -FixQueuePath $cycleQueuePath -PacketRef "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/qa/r13_005_bounded_fix_execution_packet.json"
    $allFixItemIds = @($sourceQueue.fix_items | ForEach-Object { [string]$_.fix_item_id })
    $allSourceIssueIds = @($sourceQueue.fix_items | ForEach-Object { @($_.source_issue_ids) })
    $allTargetFiles = @($sourceQueue.fix_items | ForEach-Object { @($_.target_files) } | Select-Object -Unique)

    if (@($generatedAll.selected_fix_item_ids).Count -ne 14 -or @($generatedAll.selected_source_issue_ids).Count -ne 14 -or $generatedAll.aggregate_verdict -ne "authorized_for_future_execution") {
        $failures += "FAIL generator: R13-004 fix queue artifact was not consumed into the expected all-item authorization packet."
    }
    else {
        Write-Output "PASS generator consumes R13-004 fix queue artifact and selects all fix items."
        $validPassed += 1
    }

    Assert-ContainsAll -Label "selected fix item IDs" -Actual @($generatedAll.selected_fix_item_ids) -Expected $allFixItemIds
    Assert-ContainsAll -Label "selected source issue IDs" -Actual @($generatedAll.selected_source_issue_ids) -Expected $allSourceIssueIds
    Assert-ContainsAll -Label "target files" -Actual @($generatedAll.planned_changes | ForEach-Object { @($_.target_files) } | Select-Object -Unique) -Expected $allTargetFiles

    $firstFixItem = $sourceQueue.fix_items[0]
    $generatedSingle = & $newPacket -FixQueuePath $cycleQueuePath -FixItemId ([string]$firstFixItem.fix_item_id) -PacketRef "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/qa/r13_005_bounded_fix_execution_packet.json"
    if (@($generatedSingle.selected_fix_item_ids).Count -ne 1 -or @($generatedSingle.selected_source_issue_ids).Count -ne @($firstFixItem.source_issue_ids).Count) {
        $failures += "FAIL generator: single fix item selection did not preserve selected fix/source issue IDs."
    }
    else {
        Write-Output "PASS generator can select a single fix item."
        $validPassed += 1
    }

    Assert-ContainsAll -Label "single selected source issue IDs" -Actual @($generatedSingle.selected_source_issue_ids) -Expected @($firstFixItem.source_issue_ids)
    Assert-ContainsAll -Label "single target files" -Actual @($generatedSingle.planned_changes[0].target_files) -Expected @($firstFixItem.target_files)
    Assert-ContainsAll -Label "single allowed commands" -Actual @($generatedSingle.allowed_commands) -Expected @($firstFixItem.allowed_commands)
    Assert-ContainsAll -Label "single validation commands" -Actual @($generatedSingle.validation_commands) -Expected @($firstFixItem.validation_commands)

    $rollbackEntry = @($generatedSingle.rollback_plan | Where-Object { [string]$_.fix_item_id -eq [string]$firstFixItem.fix_item_id } | Select-Object -First 1)
    if ($rollbackEntry.Count -ne 1 -or [string]$rollbackEntry[0].rollback_note -ne [string]$firstFixItem.rollback_note) {
        $failures += "FAIL generator: rollback plan did not preserve selected fix item rollback_note."
    }
    else {
        Write-Output "PASS generator preserves rollback plan."
        $validPassed += 1
    }

    $expectedFutureRefs = @($generatedSingle.expected_evidence_refs | Where-Object { $_.status -eq "expected_future_evidence" } | ForEach-Object { [string]$_.ref_id })
    Assert-ContainsAll -Label "expected future evidence refs" -Actual $expectedFutureRefs -Expected @($firstFixItem.expected_evidence_refs)
    if ($expectedFutureRefs.Count -lt 1) {
        $failures += "FAIL generator: expected future evidence refs were not preserved."
    }
    else {
        Write-Output "PASS generator preserves expected future evidence refs."
        $validPassed += 1
    }

    Invoke-ExpectedRefusal -Label "dynamic-unknown-fix-item" -RequiredFragments @("not present", "source queue") -Action {
        & $newPacket -FixQueuePath $cycleQueuePath -FixItemId "r13qf-unknown" | Out-Null
    }
    Invoke-ExpectedRefusal -Label "dynamic-outside-repo-target" -RequiredFragments @("repository-relative") -Action {
        & $newPacket -FixQueuePath (Join-Path $invalidQueueRoot "outside_repo_target_file.invalid.json") | Out-Null
    }
    Invoke-ExpectedRefusal -Label "dynamic-broad-scope" -RequiredFragments @("broad", "AllowBroadScope") -Action {
        & $newPacket -FixQueuePath (Join-Path $invalidQueueRoot "broad_scope_without_authorization.invalid.json") | Out-Null
    }

    foreach ($claimFixture in @(
        "claims_rerun_before_rerun_task.invalid.json",
        "claims_comparison_before_comparison_task.invalid.json",
        "claims_external_replay_before_external_task.invalid.json",
        "claims_signoff_before_signoff_task.invalid.json"
    )) {
        Invoke-ExpectedRefusal -Label "validator-claim-$claimFixture" -RequiredFragments @("claims") -Action {
            & $testPacket -PacketPath (Join-Path $invalidRoot $claimFixture) | Out-Null
        }
    }

    $tempOutputPath = Join-Path $repoRoot ("state\tmp_r13_005_cli_test_" + [guid]::NewGuid().ToString("N") + ".json")
    $cliResult = Invoke-PowerShellFile -FilePath $cliPath -Arguments @("-FixQueuePath", $cycleQueuePath, "-OutputPath", $tempOutputPath)
    if ($cliResult.ExitCode -ne 0) {
        $failures += "FAIL CLI: packet generator returned non-zero. Output: $([string]::Join(' ', @($cliResult.Output)))"
    }
    else {
        $tempValidation = & $testPacket -PacketPath $tempOutputPath
        if ($tempValidation.SelectedFixItemCount -ne 14 -or $tempValidation.AggregateVerdict -ne "authorized_for_future_execution") {
            $failures += "FAIL CLI: generated authorization packet did not validate with expected selected item count."
        }
        else {
            Write-Output "PASS CLI exits 0 for valid authorization packet generation."
            $validPassed += 1
        }
    }
    if (Test-Path -LiteralPath $tempOutputPath) {
        Remove-Item -LiteralPath $tempOutputPath -Force
    }

    $validatorValid = Invoke-PowerShellFile -FilePath $validatorPath -Arguments @("-PacketPath", $authorizationFixturePath)
    if ($validatorValid.ExitCode -ne 0 -or ([string]::Join("`n", @($validatorValid.Output)) -notmatch "VALID")) {
        $failures += "FAIL validator: validator CLI did not print VALID for authorization fixture. Output: $([string]::Join(' ', @($validatorValid.Output)))"
    }
    else {
        Write-Output "PASS validator CLI prints VALID for valid fixture."
        $validPassed += 1
    }

    $cyclePacketValidation = Invoke-PowerShellFile -FilePath $validatorPath -Arguments @("-PacketPath", $cyclePacketPath)
    if ($cyclePacketValidation.ExitCode -ne 0 -or ([string]::Join("`n", @($cyclePacketValidation.Output)) -notmatch "VALID")) {
        $failures += "FAIL validator: generated R13-005 packet artifact did not validate. Output: $([string]::Join(' ', @($cyclePacketValidation.Output)))"
    }
    else {
        Write-Output "PASS validator CLI validates generated R13-005 packet."
        $validPassed += 1
    }
}
catch {
    $failures += ("FAIL R13 bounded fix execution harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R13 bounded fix execution tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R13 bounded fix execution tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
