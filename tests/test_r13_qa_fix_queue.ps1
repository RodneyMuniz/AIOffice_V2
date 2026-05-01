$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R13QaFixQueue.psm1") -Force -PassThru
$testQueue = $module.ExportedCommands["Test-R13QaFixQueue"]
$newQueue = $module.ExportedCommands["New-R13QaFixQueue"]

$validRoot = Join-Path $repoRoot "state\fixtures\valid\actionable_qa"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\actionable_qa\r13_qa_fix_queue"
$cycleQueuePath = Join-Path $repoRoot "state\cycles\r13_api_first_qa_pipeline_and_operator_control_room_product_slice\qa\r13_004_fix_queue.json"
$sourceIssueReportPath = Join-Path $repoRoot "state\cycles\r13_api_first_qa_pipeline_and_operator_control_room_product_slice\qa\r13_003_issue_detection_report.json"
$validatorPath = Join-Path $repoRoot "tools\validate_r13_qa_fix_queue.ps1"
$cliPath = Join-Path $repoRoot "tools\export_r13_qa_fix_queue.ps1"
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

try {
    $readyFixturePath = Join-Path $validRoot "r13_qa_fix_queue.ready.valid.json"
    $readyQueue = & $testQueue -QueuePath $readyFixturePath
    if ($readyQueue.AggregateVerdict -ne "ready_for_fix_execution" -or $readyQueue.BlockingIssueCount -ne 1 -or $readyQueue.FixItemCount -ne 1 -or $readyQueue.UnmappedBlockingIssueCount -ne 0) {
        $failures += "FAIL valid: ready fixture did not validate as one mapped blocking fix item."
    }
    else {
        Write-Output ("PASS valid ready fixture: {0}" -f $readyQueue.QueueId)
        $validPassed += 1
    }

    $blockedFixturePath = Join-Path $validRoot "r13_qa_fix_queue.blocked.valid.json"
    $blockedQueue = & $testQueue -QueuePath $blockedFixturePath
    if ($blockedQueue.AggregateVerdict -ne "blocked" -or $blockedQueue.BlockingIssueCount -ne 1 -or $blockedQueue.NoFixItemCount -ne 1 -or $blockedQueue.UnmappedBlockingIssueCount -ne 0) {
        $failures += "FAIL valid: blocked fixture did not validate as an explicit no-fix blocked queue."
    }
    else {
        Write-Output ("PASS valid blocked fixture: {0}" -f $blockedQueue.QueueId)
        $validPassed += 1
    }

    $expectedInvalidFragments = @{
        "orphan_fix_item.invalid.json" = @("does not map")
        "hidden_unmapped_blocking_issue.invalid.json" = @("every blocking issue", "missing")
        "missing_source_issue_id.invalid.json" = @("source_issue_ids", "empty")
        "missing_reproduction_command.invalid.json" = @("reproduction_commands")
        "missing_recommended_fix.invalid.json" = @("recommended_fix")
        "missing_validation_commands.invalid.json" = @("validation_commands")
        "missing_expected_evidence_refs.invalid.json" = @("expected_evidence_refs")
        "broad_scope_without_authorization.invalid.json" = @("broad", "AllowBroadScope")
        "outside_repo_target_file.invalid.json" = @("repository-relative")
        "executor_self_certification_as_fix_authority.invalid.json" = @("executor self-certification")
        "local_only_as_external_proof.invalid.json" = @("local-only", "external proof")
        "aggregate_passed_before_fix_execution.invalid.json" = @("passed", "not allowed")
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
            & $testQueue -QueuePath $invalidFile.FullName | Out-Null
        }
    }

    $generatedQueue = & $newQueue -IssueReportPath $sourceIssueReportPath -QueueRef "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/qa/r13_004_fix_queue.json"
    $sourceIssueReport = Read-JsonObject -Path $sourceIssueReportPath
    $sourceBlockingIssues = @($sourceIssueReport.issues | Where-Object { $_.blocking_status -eq "blocking" })
    $generatedFixItems = @($generatedQueue.fix_items)
    $generatedNoFixItems = @($generatedQueue.no_fix_items)
    $mappedIds = @{}
    foreach ($item in @($generatedFixItems + $generatedNoFixItems)) {
        foreach ($sourceIssueId in @($item.source_issue_ids)) {
            $mappedIds[[string]$sourceIssueId] = $true
        }
    }
    $sourceIds = @($sourceIssueReport.issues | ForEach-Object { [string]$_.issue_id })
    $orphanIds = @($mappedIds.Keys | Where-Object { $sourceIds -notcontains $_ })
    $missingIds = @($sourceBlockingIssues | Where-Object { -not $mappedIds.ContainsKey([string]$_.issue_id) } | ForEach-Object { [string]$_.issue_id })

    if ($generatedQueue.issue_summary.source_issue_count -ne @($sourceIssueReport.issues).Count -or $sourceBlockingIssues.Count -ne 14) {
        $failures += "FAIL generator: source issue report was not consumed with the expected issue counts."
    }
    elseif ($missingIds.Count -ne 0) {
        $failures += "FAIL generator: not every R13-003 blocking issue was mapped. Missing: $($missingIds -join ', ')"
    }
    elseif ($orphanIds.Count -ne 0) {
        $failures += "FAIL generator: orphan fix/no-fix source issue IDs were produced: $($orphanIds -join ', ')"
    }
    else {
        Write-Output ("PASS generator consumed R13-003 and mapped {0} blocking issue(s)." -f $sourceBlockingIssues.Count)
        $validPassed += 1
    }

    foreach ($sourceIssue in $sourceIssueReport.issues) {
        $mappedItem = @($generatedFixItems + $generatedNoFixItems | Where-Object { @($_.source_issue_ids) -contains [string]$sourceIssue.issue_id } | Select-Object -First 1)
        if ($mappedItem.Count -ne 1) {
            $failures += "FAIL generator: source issue '$($sourceIssue.issue_id)' was not preserved in exactly one item."
            continue
        }
        if (@($mappedItem[0].reproduction_commands) -notcontains [string]$sourceIssue.reproduction_command) {
            $failures += "FAIL generator: source issue '$($sourceIssue.issue_id)' reproduction command was not preserved."
        }
        if ([string]$mappedItem[0].recommended_fix -notlike ("*{0}*" -f [string]$sourceIssue.recommended_fix)) {
            $failures += "FAIL generator: source issue '$($sourceIssue.issue_id)' recommended fix was not preserved."
        }
    }

    if (@($generatedQueue.validation_commands).Count -lt 1 -or @($generatedFixItems | Where-Object { @($_.validation_commands).Count -lt 1 }).Count -ne 0) {
        $failures += "FAIL generator: validation commands were not produced at queue and item level."
    }
    elseif (@($generatedQueue.expected_evidence_refs | Where-Object { $_.status -eq "expected_future_evidence" }).Count -lt 1 -or @($generatedFixItems | Where-Object { @($_.expected_evidence_refs).Count -lt 1 }).Count -ne 0) {
        $failures += "FAIL generator: expected future evidence refs were not produced."
    }
    else {
        Write-Output "PASS generator produced validation commands and expected future evidence refs."
        $validPassed += 1
    }

    if (@($generatedQueue.non_claims | Where-Object { $_ -match "no fix execution|no rerun|no meaningful QA loop|no external replay proof|no final QA signoff" }).Count -lt 5) {
        $failures += "FAIL generator: queue non_claims do not preserve no-execution/no-loop posture."
    }
    else {
        Write-Output "PASS generator preserves R13-004 non-claims."
        $validPassed += 1
    }

    Invoke-ExpectedRefusal -Label "dynamic-broad-scope-rejection" -RequiredFragments @("broad", "AllowBroadScope") -Action {
        & $testQueue -QueuePath (Join-Path $invalidRoot "broad_scope_without_authorization.invalid.json") | Out-Null
    }
    Invoke-ExpectedRefusal -Label "dynamic-outside-repo-rejection" -RequiredFragments @("repository-relative") -Action {
        & $testQueue -QueuePath (Join-Path $invalidRoot "outside_repo_target_file.invalid.json") | Out-Null
    }

    $tempQueuePath = Join-Path ([System.IO.Path]::GetTempPath()) ("r13-004-cli-queue-" + [guid]::NewGuid().ToString("N") + ".json")
    $cliResult = Invoke-PowerShellFile -FilePath $cliPath -Arguments @("-IssueReportPath", $sourceIssueReportPath, "-OutputPath", $tempQueuePath)
    if ($cliResult.ExitCode -ne 0) {
        $failures += "FAIL CLI: export CLI returned non-zero. Output: $([string]::Join(' ', @($cliResult.Output)))"
    }
    else {
        $cliQueueValidation = & $testQueue -QueuePath $tempQueuePath
        if ($cliQueueValidation.BlockingIssueCount -ne 14 -or $cliQueueValidation.FixItemCount -ne 14 -or $cliQueueValidation.AggregateVerdict -ne "ready_for_fix_execution") {
            $failures += "FAIL CLI: exported queue did not validate with expected R13-003 mappings."
        }
        else {
            Write-Output "PASS CLI exits 0 for successful queue generation."
            $validPassed += 1
        }
    }

    $validatorValid = Invoke-PowerShellFile -FilePath $validatorPath -Arguments @("-QueuePath", $readyFixturePath)
    if ($validatorValid.ExitCode -ne 0 -or ([string]::Join("`n", @($validatorValid.Output)) -notmatch "VALID")) {
        $failures += "FAIL validator: validator CLI did not print VALID for ready fixture. Output: $([string]::Join(' ', @($validatorValid.Output)))"
    }
    else {
        Write-Output "PASS validator CLI prints VALID for valid fixture."
        $validPassed += 1
    }

    $cycleQueueValidation = Invoke-PowerShellFile -FilePath $validatorPath -Arguments @("-QueuePath", $cycleQueuePath)
    if ($cycleQueueValidation.ExitCode -ne 0 -or ([string]::Join("`n", @($cycleQueueValidation.Output)) -notmatch "VALID")) {
        $failures += "FAIL validator: generated R13-004 queue artifact did not validate. Output: $([string]::Join(' ', @($cycleQueueValidation.Output)))"
    }
    else {
        Write-Output "PASS validator validates generated R13-004 queue artifact."
        $validPassed += 1
    }
}
catch {
    $failures += ("FAIL R13 QA fix queue harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R13 QA fix queue tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R13 QA fix queue tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
