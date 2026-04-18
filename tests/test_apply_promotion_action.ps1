$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$actionModulePath = Join-Path $repoRoot "tools\ApplyPromotionAction.psm1"
$gateModulePath = Join-Path $repoRoot "tools\ApplyPromotionGate.psm1"
$packetModulePath = Join-Path $repoRoot "tools\PacketRecordStorage.psm1"
Import-Module $actionModulePath -Force
Import-Module $gateModulePath -Force
Import-Module $packetModulePath -Force

function Get-JsonFixture {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

$validRequestFixture = Join-Path $repoRoot "state\fixtures\valid\apply_promotion_gate_request.valid.json"
$missingApprovalFixture = Join-Path $repoRoot "state\fixtures\invalid\apply_promotion_gate_request.missing-approval.json"
$validPacketFixture = Join-Path $repoRoot "state\fixtures\valid\apply_promotion.packet.valid.json"

$failures = @()
$allowOutcomePath = $null
$blockedOutcomePath = $null

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("aioffice-r2-action-" + [guid]::NewGuid().ToString("N"))
$packetStore = Join-Path $tempRoot "packets"
$gateResultStore = Join-Path $tempRoot "gate_results"
$actionRequestStore = Join-Path $tempRoot "action_requests"
$actionResultStore = Join-Path $tempRoot "action_results"
New-Item -ItemType Directory -Path $packetStore -Force | Out-Null
New-Item -ItemType Directory -Path $gateResultStore -Force | Out-Null
New-Item -ItemType Directory -Path $actionRequestStore -Force | Out-Null
New-Item -ItemType Directory -Path $actionResultStore -Force | Out-Null

function Save-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        $Document,
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $Document | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $Path -Encoding UTF8
}

try {
    $packet = Get-PacketRecord -Path $validPacketFixture
    $savedPacketPath = Save-PacketRecord -PacketRecord $packet -StorePath $packetStore

    $allowGateRequest = Get-JsonFixture -Path $validRequestFixture
    $allowGateRequest.packet_record_ref = $savedPacketPath
    $allowGateRequest.approved_artifact_refs = @((Join-Path $repoRoot "artifacts\fixtures\valid\architect.valid.json"))
    $allowGateRequest.scope.allowed_paths = @("state/apply_promotion_actions")
    $allowGateRequestPath = Join-Path $tempRoot "allow.gate.request.json"
    Save-JsonDocument -Document $allowGateRequest -Path $allowGateRequestPath

    $allowGateResult = Invoke-ApplyPromotionGate -GateRequestPath $allowGateRequestPath
    if ($allowGateResult.decision -ne "allow") {
        $failures += "FAIL allow gate setup did not return allow."
    }

    $savedAllowGateResult = Save-ApplyPromotionGateResult -GateResult $allowGateResult -StorePath $gateResultStore
    $allowActionRelativePath = ("state/apply_promotion_actions/test-action-{0}.apply.outcome.json" -f [guid]::NewGuid().ToString("N"))
    $allowActionRequest = [pscustomobject]@{
        contract_version      = "v1"
        record_type           = "apply_promotion_action_request"
        action_request_id     = "action-r2-allow-001"
        gate_result_ref       = $savedAllowGateResult.GateResultPath
        gate_result_id        = $savedAllowGateResult.GateResult.gate_result_id
        packet_id             = $allowGateRequest.packet_id
        packet_record_ref     = $savedPacketPath
        requested_action      = "apply"
        architect_artifact_ref = (Join-Path $repoRoot "artifacts\fixtures\valid\architect.valid.json")
        approved_artifact_refs = @((Join-Path $repoRoot "artifacts\fixtures\valid\architect.valid.json"))
        target_relative_path  = $allowActionRelativePath
        requested_at          = "2026-04-19T16:00:00Z"
        requested_by          = "operator:admin"
        notes                 = "Execute one bounded allow-path apply action."
    }
    $allowActionRequestPath = Join-Path $actionRequestStore "allow.action.request.json"
    Save-JsonDocument -Document $allowActionRequest -Path $allowActionRequestPath

    $allowActionContract = Test-ApplyPromotionActionRequestContract -ActionRequestPath $allowActionRequestPath
    Write-Output ("PASS action request contract: {0} -> {1}" -f $allowActionContract.ActionRequestId, $allowActionContract.RequestedAction)

    $savedActionResult = Invoke-ApplyPromotionAction -ActionRequestPath $allowActionRequestPath -ResultStorePath $actionResultStore
    $allowOutcomePath = $savedActionResult.ActionOutcomePath
    if (-not (Test-Path -LiteralPath $savedActionResult.ActionResultPath)) {
        $failures += "FAIL allow action result path was not created."
    }
    if (-not (Test-Path -LiteralPath $savedActionResult.ActionOutcomePath)) {
        $failures += "FAIL allow action outcome path was not created."
    }

    $validatedActionResult = Test-ApplyPromotionActionResultContract -ActionResultPath $savedActionResult.ActionResultPath
    Write-Output ("PASS action result contract: {0} -> {1}" -f $validatedActionResult.ActionResultId, $validatedActionResult.RequestedAction)

    $updatedPacket = Get-PacketRecord -Path $savedActionResult.PacketPath
    if ($updatedPacket.working_state.status -ne "in_progress") {
        $failures += "FAIL allow action did not update working_state.status to in_progress."
    }
    if ($updatedPacket.working_state.artifact_refs -notcontains $allowActionRelativePath) {
        $failures += "FAIL allow action did not record the bounded outcome artifact in working_state.artifact_refs."
    }
    if ($updatedPacket.reconciliation_state.status -ne "drift") {
        $failures += "FAIL allow action did not update reconciliation_state.status to drift."
    }
    if ($updatedPacket.reconciliation_state.working_matches_accepted -ne $false) {
        $failures += "FAIL allow action did not record working_matches_accepted as false."
    }
    if ($updatedPacket.reconciliation_state.git_head_matches_accepted -ne $true) {
        $failures += "FAIL allow action did not keep git_head_matches_accepted true."
    }
    Write-Output ("PASS allow action execution: {0}" -f $savedActionResult.ActionResultPath)

    $blockedPacket = Get-PacketRecord -Path $validPacketFixture
    $blockedPacket.packet_id = "packet-r2-action-block-001"
    $blockedPacketPath = Save-PacketRecord -PacketRecord $blockedPacket -StorePath $packetStore

    $blockedGateRequest = Get-JsonFixture -Path $missingApprovalFixture
    $blockedGateRequest.packet_id = "packet-r2-action-block-001"
    $blockedGateRequest.packet_record_ref = $blockedPacketPath
    $blockedGateRequest.scope.allowed_paths = @("state/apply_promotion_actions")
    $blockedGateRequestPath = Join-Path $tempRoot "blocked.gate.request.json"
    Save-JsonDocument -Document $blockedGateRequest -Path $blockedGateRequestPath

    $blockedGateResult = Invoke-ApplyPromotionGate -GateRequestPath $blockedGateRequestPath
    if ($blockedGateResult.decision -ne "blocked") {
        $failures += "FAIL blocked gate setup did not return blocked."
    }

    $savedBlockedGateResult = Save-ApplyPromotionGateResult -GateResult $blockedGateResult -StorePath $gateResultStore
    $blockedActionRelativePath = ("state/apply_promotion_actions/test-action-{0}.blocked.outcome.json" -f [guid]::NewGuid().ToString("N"))
    $blockedActionRequest = [pscustomobject]@{
        contract_version      = "v1"
        record_type           = "apply_promotion_action_request"
        action_request_id     = "action-r2-block-001"
        gate_result_ref       = $savedBlockedGateResult.GateResultPath
        gate_result_id        = $savedBlockedGateResult.GateResult.gate_result_id
        packet_id             = "packet-r2-action-block-001"
        packet_record_ref     = $blockedPacketPath
        requested_action      = "promotion"
        architect_artifact_ref = (Join-Path $repoRoot "artifacts\fixtures\valid\architect.valid.json")
        approved_artifact_refs = @((Join-Path $repoRoot "artifacts\fixtures\valid\architect.valid.json"))
        target_relative_path  = $blockedActionRelativePath
        requested_at          = "2026-04-19T16:05:00Z"
        requested_by          = "operator:admin"
        notes                 = "This blocked action request should never execute."
    }
    $blockedActionRequestPath = Join-Path $actionRequestStore "blocked.action.request.json"
    Save-JsonDocument -Document $blockedActionRequest -Path $blockedActionRequestPath

    Test-ApplyPromotionActionRequestContract -ActionRequestPath $blockedActionRequestPath | Out-Null

    $blockedExecutionFailed = $false
    try {
        Invoke-ApplyPromotionAction -ActionRequestPath $blockedActionRequestPath -ResultStorePath $actionResultStore | Out-Null
    }
    catch {
        $blockedExecutionFailed = $true
        Write-Output ("PASS blocked action refusal: {0}" -f $_.Exception.Message)
    }

    if (-not $blockedExecutionFailed) {
        $failures += "FAIL blocked gate result still allowed the bounded action executor to run."
    }

    $blockedOutcomePath = Join-Path $repoRoot $blockedActionRelativePath.Replace("/", "\")
    if (Test-Path -LiteralPath $blockedOutcomePath) {
        $failures += "FAIL blocked action created an outcome artifact."
    }
}
catch {
    $failures += ("FAIL action test execution: {0}" -f $_.Exception.Message)
}
finally {
    foreach ($outcomePath in @($allowOutcomePath, $blockedOutcomePath)) {
        if ($null -ne $outcomePath -and (Test-Path -LiteralPath $outcomePath)) {
            Remove-Item -LiteralPath $outcomePath -Force
        }
    }

    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Apply/promotion action tests failed. Failure count: {0}" -f $failures.Count)
}

Write-Output "All apply/promotion action tests passed."
