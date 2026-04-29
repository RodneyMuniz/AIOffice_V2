$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\DevExecutionAdapter.psm1") -Force -PassThru -DisableNameChecking -WarningAction SilentlyContinue
$controllerModule = Import-Module (Join-Path $repoRoot "tools\CycleController.psm1") -Force -PassThru -DisableNameChecking -WarningAction SilentlyContinue
$jsonRootModule = Import-Module (Join-Path $repoRoot "tools\JsonRoot.psm1") -Force -PassThru

$newDispatch = $module.ExportedCommands["New-DevDispatchPacket"]
$testDispatch = $module.ExportedCommands["Test-DevDispatchPacketContract"]
$inspectDispatch = $module.ExportedCommands["Inspect-DevDispatchPacket"]
$newResult = $module.ExportedCommands["New-DevExecutionResultPacket"]
$testResult = $module.ExportedCommands["Test-DevExecutionResultPacketContract"]
$testResultObject = $module.ExportedCommands["Test-DevExecutionResultPacketObject"]
$inspectResult = $module.ExportedCommands["Inspect-DevExecutionResultPacket"]
$initializeLedger = $controllerModule.ExportedCommands["Initialize-CycleControllerLedger"]
$advanceLedger = $controllerModule.ExportedCommands["Advance-CycleControllerLedger"]
$readSingleJsonObject = $jsonRootModule.ExportedCommands["Read-SingleJsonObject"]

$cliPath = Join-Path $repoRoot "tools\invoke_dev_execution_adapter.ps1"
$testRunId = "test-dev-adapter-" + [guid]::NewGuid().ToString("N").Substring(0, 8)
$stateRootRelative = "state/cycle_controller/$testRunId"
$stateRoot = Join-Path $repoRoot ($stateRootRelative -replace "/", "\")
$validPassed = 0
$invalidRejected = 0
$failures = @()

function Invoke-Git {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & git -C $repoRoot @Arguments 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }

    if ($exitCode -ne 0) {
        throw ("git {0} failed: {1}" -f ($Arguments -join " "), ($output -join "`n"))
    }

    return @($output | ForEach-Object { [string]$_ })
}

function Get-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return (& $readSingleJsonObject -Path $Path -Label "Test JSON document")
}

function Write-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Document
    )

    $parentPath = Split-Path -Parent $Path
    New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    $Document | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Copy-JsonObject {
    param(
        [Parameter(Mandatory = $true)]
        $Object
    )

    $copyPath = Join-Path $stateRoot ("copy-" + [guid]::NewGuid().ToString("N") + ".json")
    Write-JsonDocument -Path $copyPath -Document $Object
    return Get-JsonDocument -Path $copyPath
}

function New-StatePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    return (Join-Path $stateRoot $Name)
}

function New-StateRef {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    return "$stateRootRelative/$Name"
}

function Assert-Condition {
    param(
        [Parameter(Mandatory = $true)]
        [bool]$Condition,
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

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

function Invoke-CliJson {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Parameters
    )

    $output = & $cliPath @Parameters
    return (($output -join "`n") | ConvertFrom-Json)
}

$dispatchContract = Get-JsonDocument -Path (Join-Path $repoRoot "contracts\cycle_controller\dev_dispatch_packet.contract.json")
$resultContract = Get-JsonDocument -Path (Join-Path $repoRoot "contracts\cycle_controller\dev_execution_result_packet.contract.json")

function New-TaskPacketDocument {
    param(
        [switch]$SingleTask
    )

    $tasks = @(
        [pscustomobject][ordered]@{
            task_id = "r11-006-test-contracts"
            task_title = "Define bounded Dev packet contracts"
            task_objective = "Represent bounded Dev dispatch/result contracts without running a real implementation task."
            bounded_scope = @(
                "Create packet contracts.",
                "Create adapter fixtures."
            )
            allowed_paths = @(
                "contracts/cycle_controller/dev_dispatch_packet.contract.json",
                "contracts/cycle_controller/dev_execution_result_packet.contract.json",
                "state/fixtures/valid/cycle_controller"
            )
            forbidden_paths = @(
                "state/external_runs/r11",
                "state/proof_reviews/r11_controlled_external_cycle_controller_and_repo_truth_resume_pilot"
            )
            expected_outputs = @(
                "Dispatch contract.",
                "Result contract."
            )
            acceptance_checks = @(
                "Contracts validate dispatch and result packets."
            )
            evidence_required = @(
                "Validated contract fixtures."
            )
            max_attempts = 2
            context_budget = [pscustomobject][ordered]@{
                max_files = 8
                max_lines = 1200
                max_prompt_tokens = 12000
            }
            non_claims = @($dispatchContract.required_non_claims)
        },
        [pscustomobject][ordered]@{
            task_id = "r11-006-test-tooling"
            task_title = "Add bounded Dev adapter tooling"
            task_objective = "Create and inspect bounded dispatch/result packets without QA or complete-cycle execution."
            bounded_scope = @(
                "Create adapter module.",
                "Create focused adapter tests."
            )
            allowed_paths = @(
                "tools/DevExecutionAdapter.psm1",
                "tools/invoke_dev_execution_adapter.ps1",
                "tests/test_dev_execution_adapter.ps1"
            )
            forbidden_paths = @(
                "tools/CleanCheckoutQaRunner.psm1",
                "tools/IsolatedQaSignoff.psm1"
            )
            expected_outputs = @(
                "Adapter module.",
                "CLI wrapper.",
                "Focused tests."
            )
            acceptance_checks = @(
                "Dispatch refuses unbounded paths.",
                "Result refuses QA authority claims."
            )
            evidence_required = @(
                "Focused test output."
            )
            max_attempts = 2
            context_budget = [pscustomobject][ordered]@{
                max_files = 10
                max_lines = 1800
                max_prompt_tokens = 16000
            }
            non_claims = @($dispatchContract.required_non_claims)
        }
    )

    if ($SingleTask) {
        $tasks = @($tasks[0])
    }

    return [pscustomobject][ordered]@{
        task_packets = @($tasks)
    }
}

function New-TaskResultDocument {
    param(
        [string]$FirstSummary = "Bounded contract packet work recorded with evidence refs only.",
        [string]$Status = "completed",
        [switch]$WithoutEvidence,
        [string[]]$RefusalReasons = @()
    )

    $firstEvidence = if ($WithoutEvidence) { @() } else { @("state/fixtures/valid/cycle_controller/dev_dispatch_packet.valid.json") }
    $secondEvidence = if ($WithoutEvidence) { @() } else { @("tests/test_dev_execution_adapter.ps1") }

    return [pscustomobject][ordered]@{
        task_results = @(
            [pscustomobject][ordered]@{
                task_id = "r11-006-test-contracts"
                status = $Status
                summary = $FirstSummary
                changed_files = @(
                    "contracts/cycle_controller/dev_dispatch_packet.contract.json",
                    "contracts/cycle_controller/dev_execution_result_packet.contract.json",
                    "state/fixtures/valid/cycle_controller/dev_dispatch_packet.valid.json"
                )
                produced_artifacts = @(
                    "contracts/cycle_controller/dev_dispatch_packet.contract.json",
                    "contracts/cycle_controller/dev_execution_result_packet.contract.json",
                    "state/fixtures/valid/cycle_controller/dev_dispatch_packet.valid.json"
                )
                command_logs = @(
                    "tests/test_dev_execution_adapter.ps1"
                )
                evidence_refs = @($firstEvidence)
                refusal_reasons = @($RefusalReasons)
                non_claims = @($resultContract.required_non_claims)
            },
            [pscustomobject][ordered]@{
                task_id = "r11-006-test-tooling"
                status = $Status
                summary = "Bounded adapter tooling work recorded with evidence refs only."
                changed_files = @(
                    "tools/DevExecutionAdapter.psm1",
                    "tools/invoke_dev_execution_adapter.ps1",
                    "tests/test_dev_execution_adapter.ps1"
                )
                produced_artifacts = @(
                    "tools/DevExecutionAdapter.psm1",
                    "tools/invoke_dev_execution_adapter.ps1",
                    "tests/test_dev_execution_adapter.ps1"
                )
                command_logs = @(
                    "tests/test_dev_execution_adapter.ps1"
                )
                evidence_refs = @($secondEvidence)
                refusal_reasons = @($RefusalReasons)
                non_claims = @($resultContract.required_non_claims)
            }
        )
        evidence_refs = @($firstEvidence + $secondEvidence)
        command_logs = @("tests/test_dev_execution_adapter.ps1")
        refusal_reasons = @($RefusalReasons)
    }
}

function New-DevDispatchReadyLedger {
    $head = @(Invoke-Git -Arguments @("rev-parse", "HEAD"))[0].Trim()
    $tree = @(Invoke-Git -Arguments @("rev-parse", "HEAD^{tree}"))[0].Trim()
    $cycleId = "cycle-r11-006-$testRunId"
    $ledgerPath = New-StatePath -Name "cycle_ledger.json"
    $operatorRequestRef = New-StateRef -Name "operator_request.json"
    $cyclePlanRef = New-StateRef -Name "cycle_plan.json"
    $baselineRef = New-StateRef -Name "baseline.json"
    $approvalRef = New-StateRef -Name "operator_approval.evidence.json"
    $dispatchRef = New-StateRef -Name "dev_dispatch.json"

    & $initializeLedger -CycleId $cycleId -OutputPath $ledgerPath -HeadSha $head -TreeSha $tree -OperatorRequestRef $operatorRequestRef -Overwrite | Out-Null
    & $advanceLedger -LedgerPath $ledgerPath -TargetState "plan_prepared" -EvidenceRef $cyclePlanRef -Actor "R11-006-test" -Reason "Prepare bounded test plan." -CyclePlanRef $cyclePlanRef | Out-Null
    & $advanceLedger -LedgerPath $ledgerPath -TargetState "plan_approved" -EvidenceRef $approvalRef -Actor "R11-006-test" -Reason "Record bounded operator approval." -AdditionalEvidenceRefs @($approvalRef) | Out-Null
    & $advanceLedger -LedgerPath $ledgerPath -TargetState "dev_dispatch_ready" -EvidenceRef (New-StateRef -Name "dev_dispatch_ready.evidence.json") -Actor "R11-006-test" -Reason "Prepare bounded Dev dispatch." -BaselineRef $baselineRef -DispatchRefs @($dispatchRef) | Out-Null

    return [pscustomobject]@{
        LedgerPath = $ledgerPath
        CycleId = $cycleId
        BaselineRef = $baselineRef
        ApprovalRef = $approvalRef
        DispatchRef = $dispatchRef
        Head = $head
        Tree = $tree
    }
}

try {
    New-Item -ItemType Directory -Path $stateRoot -Force | Out-Null
    $ledgerInfo = New-DevDispatchReadyLedger
    $taskPacketPath = New-StatePath -Name "task_packets.json"
    Write-JsonDocument -Path $taskPacketPath -Document (New-TaskPacketDocument)
    $dispatchPath = New-StatePath -Name "dev_dispatch.json"

    $dispatch = Invoke-CliJson -Parameters @{
        Command = "create-dispatch"
        LedgerPath = $ledgerInfo.LedgerPath
        CycleId = $ledgerInfo.CycleId
        OutputPath = $dispatchPath
        BaselineRef = $ledgerInfo.BaselineRef
        OperatorApprovalRef = $ledgerInfo.ApprovalRef
        TaskPacketPath = $taskPacketPath
        Overwrite = $true
    }
    $dispatchValidation = & $testDispatch -DispatchPath $dispatchPath
    Assert-Condition -Condition (@($dispatch.task_packets).Count -eq 2 -and $dispatchValidation.TaskCount -eq 2) -Message "valid dispatch did not preserve two bounded task packets."
    Assert-Condition -Condition ($dispatch.cycle_id -eq $ledgerInfo.CycleId -and $dispatch.cycle_ledger_ref -like "$stateRootRelative/*" -and $dispatch.baseline_ref -eq $ledgerInfo.BaselineRef -and $dispatch.operator_approval_ref -eq $ledgerInfo.ApprovalRef) -Message "valid dispatch did not preserve cycle id, ledger ref, baseline ref, and operator approval ref."
    $dispatchInspect = & $inspectDispatch -DispatchPath $dispatchPath
    Assert-Condition -Condition ($dispatchInspect.TaskCount -eq 2 -and $dispatchInspect.DispatchId -eq $dispatch.dispatch_id) -Message "dispatch inspect did not validate and summarize the packet."
    Write-Output "PASS valid: dispatch with at least two bounded task packets validates and preserves cycle identity."
    $validPassed += 1

    $singleTaskPath = New-StatePath -Name "task_packets.single.json"
    Write-JsonDocument -Path $singleTaskPath -Document (New-TaskPacketDocument -SingleTask)
    Invoke-ExpectedRefusal -Label "dispatch-fewer-than-two-tasks" -RequiredFragments @("at least 2") -Action {
        Invoke-CliJson -Parameters @{
            Command = "create-dispatch"
            LedgerPath = $ledgerInfo.LedgerPath
            CycleId = $ledgerInfo.CycleId
            OutputPath = (New-StatePath -Name "dispatch.single.invalid.json")
            BaselineRef = $ledgerInfo.BaselineRef
            OperatorApprovalRef = $ledgerInfo.ApprovalRef
            TaskPacketPath = $singleTaskPath
            Overwrite = $true
        } | Out-Null
    }

    $mutations = @(
        @{ Label = "dispatch-empty-scope"; Fragments = @("bounded_scope", "must not be empty"); Mutate = { param($doc) $doc.task_packets[0].bounded_scope = @() } },
        @{ Label = "dispatch-missing-expected-outputs"; Fragments = @("expected_outputs"); Mutate = { param($doc) $doc.task_packets[0].PSObject.Properties.Remove("expected_outputs") } },
        @{ Label = "dispatch-missing-evidence"; Fragments = @("evidence_required"); Mutate = { param($doc) $doc.task_packets[0].evidence_required = @() } },
        @{ Label = "dispatch-root-path"; Fragments = @("unbounded", "unsafe"); Mutate = { param($doc) $doc.task_packets[0].allowed_paths = @(".") } },
        @{ Label = "dispatch-dotgit-path"; Fragments = @("unbounded", "unsafe"); Mutate = { param($doc) $doc.task_packets[0].allowed_paths = @(".git/config") } },
        @{ Label = "dispatch-wildcard-path"; Fragments = @("unbounded", "unsafe"); Mutate = { param($doc) $doc.task_packets[0].allowed_paths = @("tools/*") } },
        @{ Label = "dispatch-broad-path"; Fragments = @("broad root-level path"); Mutate = { param($doc) $doc.task_packets[0].allowed_paths = @("tools") } }
    )

    foreach ($mutation in $mutations) {
        $doc = Copy-JsonObject -Object (New-TaskPacketDocument)
        & $mutation.Mutate $doc
        $path = New-StatePath -Name ("{0}.json" -f $mutation.Label)
        Write-JsonDocument -Path $path -Document $doc
        Invoke-ExpectedRefusal -Label $mutation.Label -RequiredFragments $mutation.Fragments -Action {
            & $newDispatch -LedgerPath $ledgerInfo.LedgerPath -CycleId $ledgerInfo.CycleId -BaselineRef $ledgerInfo.BaselineRef -OperatorApprovalRef $ledgerInfo.ApprovalRef -TaskPackets @($doc.task_packets) | Out-Null
        }
    }

    Invoke-ExpectedRefusal -Label "dispatch-unsupported-ledger-state" -RequiredFragments @("not compatible", "dev_dispatch_ready") -Action {
        & $newDispatch -LedgerPath (Join-Path $repoRoot "state\fixtures\valid\cycle_controller\cycle_ledger.valid.json") -CycleId "cycle-r11-002-validator-fixture" -BaselineRef $ledgerInfo.BaselineRef -OperatorApprovalRef $ledgerInfo.ApprovalRef -TaskPackets @((New-TaskPacketDocument).task_packets) | Out-Null
    }

    $taskResultPath = New-StatePath -Name "task_results.json"
    Write-JsonDocument -Path $taskResultPath -Document (New-TaskResultDocument)
    $resultPath = New-StatePath -Name "dev_result.json"
    $result = Invoke-CliJson -Parameters @{
        Command = "create-result"
        DispatchPath = $dispatchPath
        OutputPath = $resultPath
        ExecutorIdentity = "codex-test-executor"
        ExecutorKind = "codex"
        Status = "completed"
        TaskResultPath = $taskResultPath
        HeadBefore = $dispatch.head_sha
        TreeBefore = $dispatch.tree_sha
        HeadAfter = $dispatch.head_sha
        TreeAfter = $dispatch.tree_sha
        Overwrite = $true
    }
    $resultValidation = & $testResult -ResultPath $resultPath -DispatchPath $dispatchPath
    Assert-Condition -Condition ($result.status -eq "completed" -and @($result.evidence_refs).Count -gt 0 -and $result.dispatch_id -eq $dispatch.dispatch_id -and $result.cycle_id -eq $dispatch.cycle_id -and $resultValidation.TaskResultCount -eq 2) -Message "valid completed result did not validate or preserve dispatch/cycle identity."
    $resultInspect = & $inspectResult -ResultPath $resultPath -DispatchPath $dispatchPath
    Assert-Condition -Condition ($resultInspect.Status -eq "completed" -and $resultInspect.DispatchId -eq $dispatch.dispatch_id) -Message "result inspect did not validate and summarize the result packet."
    Write-Output "PASS valid: completed result validates with evidence refs and preserves dispatch/cycle identity."
    $validPassed += 1

    $noEvidenceDoc = New-TaskResultDocument -WithoutEvidence
    Invoke-ExpectedRefusal -Label "completed-result-without-evidence" -RequiredFragments @("evidence_refs", "completed") -Action {
        & $newResult -DispatchPath $dispatchPath -ExecutorIdentity "codex-test-executor" -ExecutorKind "codex" -Status "completed" -TaskResults @($noEvidenceDoc.task_results) -HeadBefore $dispatch.head_sha -TreeBefore $dispatch.tree_sha -HeadAfter $dispatch.head_sha -TreeAfter $dispatch.tree_sha | Out-Null
    }

    foreach ($blockedStatus in @("blocked", "failed")) {
        $blockedDoc = New-TaskResultDocument -Status $blockedStatus -WithoutEvidence
        Invoke-ExpectedRefusal -Label ("{0}-result-without-refusal" -f $blockedStatus) -RequiredFragments @("refusal_reasons", $blockedStatus) -Action {
            & $newResult -DispatchPath $dispatchPath -ExecutorIdentity "codex-test-executor" -ExecutorKind "codex" -Status $blockedStatus -TaskResults @($blockedDoc.task_results) -HeadBefore $dispatch.head_sha -TreeBefore $dispatch.tree_sha -HeadAfter $dispatch.head_sha -TreeAfter $dispatch.tree_sha | Out-Null
        }
    }

    $qaClaimDoc = New-TaskResultDocument -FirstSummary "Executor certifies QA passed for this task."
    Invoke-ExpectedRefusal -Label "result-claiming-qa-authority" -RequiredFragments @("QA authority") -Action {
        & $newResult -DispatchPath $dispatchPath -ExecutorIdentity "codex-test-executor" -ExecutorKind "codex" -Status "completed" -TaskResults @($qaClaimDoc.task_results) -HeadBefore $dispatch.head_sha -TreeBefore $dispatch.tree_sha -HeadAfter $dispatch.head_sha -TreeAfter $dispatch.tree_sha | Out-Null
    }

    $cycleClaimDoc = New-TaskResultDocument -FirstSummary "The complete controlled cycle ran and is accepted."
    Invoke-ExpectedRefusal -Label "result-claiming-complete-cycle" -RequiredFragments @("complete controlled cycle") -Action {
        & $newResult -DispatchPath $dispatchPath -ExecutorIdentity "codex-test-executor" -ExecutorKind "codex" -Status "completed" -TaskResults @($cycleClaimDoc.task_results) -HeadBefore $dispatch.head_sha -TreeBefore $dispatch.tree_sha -HeadAfter $dispatch.head_sha -TreeAfter $dispatch.tree_sha | Out-Null
    }

    Invoke-ExpectedRefusal -Label "result-executor-kind-qa" -RequiredFragments @("executor_kind", "must be one of") -Action {
        & $newResult -DispatchPath $dispatchPath -ExecutorIdentity "codex-qa-self-certifier" -ExecutorKind "qa" -Status "completed" -TaskResults @((New-TaskResultDocument).task_results) -HeadBefore $dispatch.head_sha -TreeBefore $dispatch.tree_sha -HeadAfter $dispatch.head_sha -TreeAfter $dispatch.tree_sha | Out-Null
    }

    $mismatchResult = Copy-JsonObject -Object (Get-JsonDocument -Path $resultPath)
    $mismatchResult.dispatch_id = "dev-dispatch-r11-006-mismatch"
    Invoke-ExpectedRefusal -Label "result-mismatched-dispatch-id" -RequiredFragments @("dispatch_id", "does not match") -Action {
        & $testResultObject -ExecutionResult $mismatchResult -DispatchPacket (Get-JsonDocument -Path $dispatchPath) | Out-Null
    }
    $mismatchResult = Copy-JsonObject -Object (Get-JsonDocument -Path $resultPath)
    $mismatchResult.cycle_id = "cycle-r11-006-mismatch"
    Invoke-ExpectedRefusal -Label "result-mismatched-cycle-id" -RequiredFragments @("cycle_id", "does not match") -Action {
        & $testResultObject -ExecutionResult $mismatchResult -DispatchPacket (Get-JsonDocument -Path $dispatchPath) | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-dispatch-fixture" -RequiredFragments @("unbounded") -Action {
        & $testDispatch -DispatchPath (Join-Path $repoRoot "state\fixtures\invalid\cycle_controller\dev_dispatch_packet.unbounded_path.invalid.json") | Out-Null
    }
    Invoke-ExpectedRefusal -Label "invalid-result-fixture" -RequiredFragments @("QA authority") -Action {
        & $testResult -ResultPath (Join-Path $repoRoot "state\fixtures\invalid\cycle_controller\dev_execution_result_packet.qa_claim.invalid.json") -DispatchPath (Join-Path $repoRoot "state\fixtures\valid\cycle_controller\dev_dispatch_packet.valid.json") | Out-Null
    }

    foreach ($requiredNonClaim in @($dispatchContract.required_non_claims)) {
        Assert-Condition -Condition (@($dispatch.non_claims) -contains $requiredNonClaim) -Message "dispatch is missing non-claim '$requiredNonClaim'."
    }
    foreach ($requiredNonClaim in @($resultContract.required_non_claims)) {
        Assert-Condition -Condition (@($result.non_claims) -contains $requiredNonClaim) -Message "result is missing non-claim '$requiredNonClaim'."
    }
    Write-Output "PASS valid: dispatch and result non-claims are preserved."
    $validPassed += 1
}
catch {
    $failures += ("FAIL dev execution adapter harness: {0}" -f $_.Exception.Message)
}
finally {
    $resolvedStateRoot = [System.IO.Path]::GetFullPath($stateRoot)
    $allowedStateRoot = [System.IO.Path]::GetFullPath((Join-Path $repoRoot "state\cycle_controller"))
    if (-not $allowedStateRoot.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $allowedStateRoot = $allowedStateRoot + [System.IO.Path]::DirectorySeparatorChar
    }
    if ($resolvedStateRoot.StartsWith($allowedStateRoot, [System.StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $resolvedStateRoot)) {
        Remove-Item -LiteralPath $resolvedStateRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Dev execution adapter tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All dev execution adapter tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
