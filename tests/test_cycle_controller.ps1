$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\CycleController.psm1") -Force -PassThru -DisableNameChecking -WarningAction SilentlyContinue
$jsonRootModule = Import-Module (Join-Path $repoRoot "tools\JsonRoot.psm1") -Force -PassThru
$initialize = $module.ExportedCommands["Initialize-CycleControllerLedger"]
$inspect = $module.ExportedCommands["Inspect-CycleControllerLedger"]
$advance = $module.ExportedCommands["Advance-CycleControllerLedger"]
$refuse = $module.ExportedCommands["Refuse-CycleControllerLedger"]
$readSingleJsonObject = $jsonRootModule.ExportedCommands["Read-SingleJsonObject"]

$cliPath = Join-Path $repoRoot "tools\invoke_cycle_controller.ps1"
$validateCycleLedgerPath = Join-Path $repoRoot "tools\validate_cycle_ledger.ps1"
$tempRoot = Join-Path $repoRoot ("state\cycle_controller\test-r11-003-" + [guid]::NewGuid().ToString("N").Substring(0, 8))
$headSha = (& git -C $repoRoot rev-parse HEAD).Trim()
$treeSha = (& git -C $repoRoot rev-parse "HEAD^{tree}").Trim()

$validPassed = 0
$invalidRejected = 0
$failures = @()

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

    $json = $Document | ConvertTo-Json -Depth 80
    Set-Content -LiteralPath $Path -Value $json -Encoding UTF8
}

function New-LedgerPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
    return (Join-Path $tempRoot ("{0}.ledger.json" -f $Name))
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

function Invoke-ValidateCycleLedgerScript {
    param(
        [Parameter(Mandatory = $true)]
        [string]$LedgerPath
    )

    $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $validateCycleLedgerPath -LedgerPath $LedgerPath 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw ("validate_cycle_ledger.ps1 failed for '{0}': {1}" -f $LedgerPath, ($output -join "`n"))
    }

    return ($output -join "`n")
}

function Invoke-CliJson {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Parameters
    )

    $output = & $cliPath @Parameters
    return (($output -join "`n") | ConvertFrom-Json)
}

function New-InitializedLedger {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $path = New-LedgerPath -Name $Name
    & $initialize -CycleId ("cycle-{0}" -f $Name) -OutputPath $path -Repository "AIOffice_V2" -Branch "release/r10-real-external-runner-proof-foundation" -HeadSha $headSha -TreeSha $treeSha | Out-Null
    return $path
}

try {
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

    $initializedPath = New-LedgerPath -Name "initialized"
    $initialized = & $initialize -CycleId "cycle-r11-003-initialized" -OutputPath $initializedPath -Repository "AIOffice_V2" -Branch "release/r10-real-external-runner-proof-foundation" -HeadSha $headSha -TreeSha $treeSha
    if ($initialized.State -ne "initialized" -or $initialized.CurrentStep -ne "initialize_cycle_ledger") {
        $failures += "FAIL valid: initialize did not create an initialized cycle ledger."
    }
    else {
        Invoke-ValidateCycleLedgerScript -LedgerPath $initializedPath | Out-Null
        Write-Output ("PASS valid: initialize creates valid initialized ledger -> {0}" -f $initialized.State)
        $validPassed += 1
    }

    $requestRecordedPath = New-LedgerPath -Name "request-recorded"
    $requestRecorded = & $initialize -CycleId "cycle-r11-003-request-recorded" -OutputPath $requestRecordedPath -Repository "AIOffice_V2" -Branch "release/r10-real-external-runner-proof-foundation" -HeadSha $headSha -TreeSha $treeSha -OperatorRequestRef "state/cycle_controller/r11-003/operator_request.evidence.json"
    if ($requestRecorded.State -ne "request_recorded" -or $requestRecorded.CurrentStep -ne "record_operator_request") {
        $failures += "FAIL valid: initialize with operator request ref did not create a request_recorded ledger."
    }
    else {
        Invoke-ValidateCycleLedgerScript -LedgerPath $requestRecordedPath | Out-Null
        Write-Output ("PASS valid: initialize with operator request ref creates valid request_recorded ledger -> {0}" -f $requestRecorded.State)
        $validPassed += 1
    }

    $status = & $inspect -LedgerPath $initializedPath
    if ($status.State -ne "initialized" -or $status.CurrentStep -ne "initialize_cycle_ledger" -or $status.AllowedNextStates -notcontains "request_recorded" -or $status.RequiredRefs.Missing.Count -ne 0 -or $status.NonClaims -notcontains "no Standard runtime") {
        $failures += "FAIL valid: inspect did not report current state, current step, allowed next states, refs, and non-claims."
    }
    else {
        Write-Output ("PASS valid: inspect reports initialized ledger status -> {0}" -f $status.CurrentStep)
        $validPassed += 1
    }

    $advanceRequestPath = New-InitializedLedger -Name "advance-request"
    $advanceRequest = & $advance -LedgerPath $advanceRequestPath -TargetState "request_recorded" -EvidenceRef "state/cycle_controller/r11-003/request_recorded.evidence.json" -Actor "R11-003-test" -Reason "Record operator request ref." -OperatorRequestRef "state/cycle_controller/r11-003/operator_request.evidence.json"
    if ($advanceRequest.State -ne "request_recorded") {
        $failures += "FAIL valid: advance from initialized to request_recorded did not succeed."
    }
    else {
        Invoke-ValidateCycleLedgerScript -LedgerPath $advanceRequestPath | Out-Null
        Write-Output ("PASS valid: advance initialized -> request_recorded -> {0}" -f $advanceRequest.State)
        $validPassed += 1
    }

    $sequencePath = New-InitializedLedger -Name "sequence-plan-approved"
    & $advance -LedgerPath $sequencePath -TargetState "request_recorded" -EvidenceRef "state/cycle_controller/r11-003/sequence_request.evidence.json" -Actor "R11-003-test" -Reason "Record operator request ref." -OperatorRequestRef "state/cycle_controller/r11-003/operator_request.evidence.json" | Out-Null
    & $advance -LedgerPath $sequencePath -TargetState "plan_prepared" -EvidenceRef "state/cycle_controller/r11-003/plan_prepared.evidence.json" -Actor "R11-003-test" -Reason "Prepare the cycle plan ref." -CyclePlanRef "state/cycle_controller/r11-003/cycle_plan.evidence.json" | Out-Null
    $planApproved = & $advance -LedgerPath $sequencePath -TargetState "plan_approved" -EvidenceRef "state/cycle_controller/r11-003/operator_approval.evidence.json" -Actor "R11-003-test" -Reason "Record operator approval evidence."
    if ($planApproved.State -ne "plan_approved" -or $planApproved.CurrentStep -ne "record_operator_approval") {
        $failures += "FAIL valid: valid sequence did not advance to plan_approved."
    }
    else {
        Invoke-ValidateCycleLedgerScript -LedgerPath $sequencePath | Out-Null
        Write-Output ("PASS valid: sequence advances to plan_approved -> {0}" -f $planApproved.State)
        $validPassed += 1
    }

    $blockedPath = New-LedgerPath -Name "blocked"
    & $initialize -CycleId "cycle-r11-003-blocked" -OutputPath $blockedPath -HeadSha $headSha -TreeSha $treeSha -OperatorRequestRef "state/cycle_controller/r11-003/operator_request.evidence.json" | Out-Null
    $blocked = & $refuse -LedgerPath $blockedPath -TargetState "blocked" -EvidenceRef "state/cycle_controller/r11-003/block.evidence.json" -Actor "R11-003-test" -Reason "Block before execution." -RefusalReasons @("Required evidence is unavailable.")
    if ($blocked.State -ne "blocked" -or $blocked.AllowedNextStates.Count -ne 0) {
        $failures += "FAIL valid: refuse to blocked did not create a terminal blocked ledger."
    }
    else {
        Invoke-ValidateCycleLedgerScript -LedgerPath $blockedPath | Out-Null
        Write-Output ("PASS valid: refuse to blocked succeeds with no allowed next states -> {0}" -f $blocked.State)
        $validPassed += 1
    }

    $stoppedPath = New-InitializedLedger -Name "stopped"
    $stopped = & $refuse -LedgerPath $stoppedPath -TargetState "stopped" -EvidenceRef "state/cycle_controller/r11-003/stop.evidence.json" -Actor "R11-003-test" -Reason "Stop before request recording." -RefusalReasons @("Operator stopped the cycle before request recording.")
    if ($stopped.State -ne "stopped" -or $stopped.AllowedNextStates.Count -ne 0) {
        $failures += "FAIL valid: refuse to stopped did not create a terminal stopped ledger."
    }
    else {
        Invoke-ValidateCycleLedgerScript -LedgerPath $stoppedPath | Out-Null
        Write-Output ("PASS valid: refuse to stopped succeeds with no allowed next states -> {0}" -f $stopped.State)
        $validPassed += 1
    }

    $cliPathLedger = New-LedgerPath -Name "cli-initialize"
    $cliInitialized = Invoke-CliJson -Parameters @{
        Command = "initialize"
        CycleId = "cycle-r11-003-cli"
        OutputPath = $cliPathLedger
        HeadSha = $headSha
        TreeSha = $treeSha
    }
    $cliStatus = Invoke-CliJson -Parameters @{
        Command = "inspect"
        LedgerPath = $cliPathLedger
    }
    if ($cliInitialized.State -ne "initialized" -or $cliStatus.State -ne "initialized") {
        $failures += "FAIL valid: CLI initialize/inspect did not return initialized status."
    }
    else {
        Write-Output ("PASS valid: CLI initialize and inspect return JSON status -> {0}" -f $cliStatus.State)
        $validPassed += 1
    }

    Invoke-ExpectedRefusal -Label "illegal-transition" -RequiredFragments @("Illegal transition", "initialized", "plan_prepared") -Action {
        $path = New-InitializedLedger -Name "illegal-transition"
        & $advance -LedgerPath $path -TargetState "plan_prepared" -EvidenceRef "state/cycle_controller/r11-003/illegal.evidence.json" -Actor "R11-003-test" -Reason "Attempt illegal jump." | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-evidence-ref" -RequiredFragments @("evidence_ref", "non-empty string") -Action {
        $path = New-InitializedLedger -Name "missing-evidence"
        & $advance -LedgerPath $path -TargetState "request_recorded" -EvidenceRef "" -Actor "R11-003-test" -Reason "Missing evidence." -OperatorRequestRef "state/cycle_controller/r11-003/operator_request.evidence.json" | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-actor" -RequiredFragments @("actor", "non-empty string") -Action {
        $path = New-InitializedLedger -Name "missing-actor"
        & $advance -LedgerPath $path -TargetState "request_recorded" -EvidenceRef "state/cycle_controller/r11-003/request.evidence.json" -Actor "" -Reason "Missing actor." -OperatorRequestRef "state/cycle_controller/r11-003/operator_request.evidence.json" | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-reason" -RequiredFragments @("reason", "non-empty string") -Action {
        $path = New-InitializedLedger -Name "missing-reason"
        & $advance -LedgerPath $path -TargetState "request_recorded" -EvidenceRef "state/cycle_controller/r11-003/request.evidence.json" -Actor "R11-003-test" -Reason "" -OperatorRequestRef "state/cycle_controller/r11-003/operator_request.evidence.json" | Out-Null
    }

    Invoke-ExpectedRefusal -Label "required-refs-missing" -RequiredFragments @("missing required refs", "operator_request_ref") -Action {
        $path = New-InitializedLedger -Name "missing-required-ref"
        & $advance -LedgerPath $path -TargetState "request_recorded" -EvidenceRef "state/cycle_controller/r11-003/request.evidence.json" -Actor "R11-003-test" -Reason "Missing operator request ref." | Out-Null
    }

    Invoke-ExpectedRefusal -Label "unknown-target-state" -RequiredFragments @("target state", "must be one of") -Action {
        $path = New-InitializedLedger -Name "unknown-target"
        & $advance -LedgerPath $path -TargetState "teleported" -EvidenceRef "state/cycle_controller/r11-003/request.evidence.json" -Actor "R11-003-test" -Reason "Unknown target." -OperatorRequestRef "state/cycle_controller/r11-003/operator_request.evidence.json" | Out-Null
    }

    Invoke-ExpectedRefusal -Label "transition-from-terminal-state" -RequiredFragments @("terminal state", "stopped") -Action {
        $path = New-InitializedLedger -Name "terminal-transition"
        & $refuse -LedgerPath $path -TargetState "stopped" -EvidenceRef "state/cycle_controller/r11-003/stop.evidence.json" -Actor "R11-003-test" -Reason "Stop first." -RefusalReasons @("Stopped before request recording.") | Out-Null
        & $advance -LedgerPath $path -TargetState "request_recorded" -EvidenceRef "state/cycle_controller/r11-003/request.evidence.json" -Actor "R11-003-test" -Reason "Attempt after terminal." -OperatorRequestRef "state/cycle_controller/r11-003/operator_request.evidence.json" | Out-Null
    }

    Invoke-ExpectedRefusal -Label "overwrite-existing-without-flag" -RequiredFragments @("already exists", "Overwrite") -Action {
        $path = New-InitializedLedger -Name "overwrite"
        & $initialize -CycleId "cycle-r11-003-overwrite" -OutputPath $path -HeadSha $headSha -TreeSha $treeSha | Out-Null
    }

    Invoke-ExpectedRefusal -Label "chat-authority-ledger-refused" -RequiredFragments @("state_authority", "chat transcript") -Action {
        $path = New-InitializedLedger -Name "chat-authority"
        $ledger = Get-JsonDocument -Path $path
        $ledger.controller_authority.state_authority = "chat transcript"
        Write-JsonDocument -Path $path -Document $ledger
        & $inspect -LedgerPath $path | Out-Null
    }

    Invoke-ExpectedRefusal -Label "outside-governed-root" -RequiredFragments @("outside governed output root") -Action {
        $outsidePath = Join-Path ([System.IO.Path]::GetTempPath()) ("r11-controller-outside-" + [guid]::NewGuid().ToString("N") + ".json")
        & $initialize -CycleId "cycle-r11-003-outside" -OutputPath $outsidePath -HeadSha $headSha -TreeSha $treeSha | Out-Null
    }

    Invoke-ExpectedRefusal -Label "wrong-repository" -RequiredFragments @("repository", "AIOffice_V2") -Action {
        $path = New-LedgerPath -Name "wrong-repository"
        & $initialize -CycleId "cycle-r11-003-wrong-repo" -OutputPath $path -Repository "OtherRepo" -Branch "release/r10-real-external-runner-proof-foundation" -HeadSha $headSha -TreeSha $treeSha | Out-Null
    }

    Invoke-ExpectedRefusal -Label "wrong-branch" -RequiredFragments @("branch", "release/r10-real-external-runner-proof-foundation") -Action {
        $path = New-LedgerPath -Name "wrong-branch"
        & $initialize -CycleId "cycle-r11-003-wrong-branch" -OutputPath $path -Repository "AIOffice_V2" -Branch "feature/r5-closeout-remaining-foundations" -HeadSha $headSha -TreeSha $treeSha | Out-Null
    }

    Invoke-ExpectedRefusal -Label "malformed-git-head" -RequiredFragments @("head_sha", "required pattern") -Action {
        $path = New-LedgerPath -Name "malformed-head"
        & $initialize -CycleId "cycle-r11-003-malformed-head" -OutputPath $path -HeadSha "not-a-sha" -TreeSha $treeSha | Out-Null
    }

    Invoke-ExpectedRefusal -Label "malformed-ledger" -RequiredFragments @("missing required field", "contract_version") -Action {
        $path = New-LedgerPath -Name "malformed-ledger"
        Set-Content -LiteralPath $path -Value "{}" -Encoding UTF8
        & $inspect -LedgerPath $path | Out-Null
    }

    Invoke-ExpectedRefusal -Label "successor-claim-input" -RequiredFragments @("successor milestone", "broad autonomy") -Action {
        $path = New-InitializedLedger -Name "successor-claim"
        & $advance -LedgerPath $path -TargetState "request_recorded" -EvidenceRef "state/cycle_controller/r11-003/request.evidence.json" -Actor "R11-003-test" -Reason "Open R12 successor milestone after this transition." -OperatorRequestRef "state/cycle_controller/r11-003/operator_request.evidence.json" | Out-Null
    }

    Invoke-ExpectedRefusal -Label "unknown-cli-command" -RequiredFragments @("Unknown cycle controller command") -Action {
        & $cliPath -Command "dance" | Out-Null
    }

    Invoke-ExpectedRefusal -Label "cli-missing-ledger-path" -RequiredFragments @("LedgerPath", "required") -Action {
        & $cliPath -Command "inspect" | Out-Null
    }
}
catch {
    $failures += ("FAIL cycle controller harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Cycle controller tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All cycle controller tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
