$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$gateModulePath = Join-Path $repoRoot "tools\ApplyPromotionGate.psm1"
$packetModulePath = Join-Path $repoRoot "tools\PacketRecordStorage.psm1"
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
$ambiguousScopeFixture = Join-Path $repoRoot "state\fixtures\invalid\apply_promotion_gate_request.ambiguous-scope.json"
$missingArtifactFixture = Join-Path $repoRoot "state\fixtures\invalid\apply_promotion_gate_request.missing-artifact-link.json"
$validPacketFixture = Join-Path $repoRoot "state\fixtures\valid\apply_promotion.packet.valid.json"

$failures = @()

try {
    $validRequestCheck = Test-ApplyPromotionGateRequestContract -GateRequestPath $validRequestFixture
    Write-Output ("PASS request contract: {0} -> {1}" -f $validRequestCheck.GateRequestId, $validRequestCheck.RequestedAction)
}
catch {
    $failures += ("FAIL request contract: {0}" -f $_.Exception.Message)
}

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("aioffice-rst011-" + [guid]::NewGuid().ToString("N"))
$packetStore = Join-Path $tempRoot "packets"
$resultStore = Join-Path $tempRoot "gate_results"
New-Item -ItemType Directory -Path $packetStore -Force | Out-Null
New-Item -ItemType Directory -Path $resultStore -Force | Out-Null

function Save-RequestFixture {
    param(
        [Parameter(Mandatory = $true)]
        $RequestObject,
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $RequestObject | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $Path -Encoding UTF8
}

try {
    $packet = Get-PacketRecord -Path $validPacketFixture
    $savedPacketPath = Save-PacketRecord -PacketRecord $packet -StorePath $packetStore

    $allowRequest = Get-JsonFixture -Path $validRequestFixture
    $allowRequest.packet_record_ref = $savedPacketPath
    $allowRequestPath = Join-Path $tempRoot "allow.request.json"
    Save-RequestFixture -RequestObject $allowRequest -Path $allowRequestPath

    $allowResult = Invoke-ApplyPromotionGate -GateRequestPath $allowRequestPath
    if ($allowResult.decision -ne "allow") {
        $failures += "FAIL allow path did not return allow."
    }
    if (-not $allowResult.preconditions.approval -or -not $allowResult.preconditions.scope -or -not $allowResult.preconditions.artifact_linkage -or -not $allowResult.preconditions.reconciliation) {
        $failures += "FAIL allow path did not satisfy all preconditions."
    }

    $savedAllowResult = Save-ApplyPromotionGateResult -GateResult $allowResult -StorePath $resultStore
    $validatedAllowResult = Test-ApplyPromotionGateResultContract -GateResultPath $savedAllowResult.GateResultPath
    Write-Output ("PASS allow path: {0} -> {1}" -f $validatedAllowResult.GateResultId, $validatedAllowResult.Decision)

    $missingApprovalRequest = Get-JsonFixture -Path $missingApprovalFixture
    $missingApprovalRequest.packet_record_ref = $savedPacketPath
    $missingApprovalPath = Join-Path $tempRoot "missing-approval.request.json"
    Save-RequestFixture -RequestObject $missingApprovalRequest -Path $missingApprovalPath

    $missingApprovalResult = Invoke-ApplyPromotionGate -GateRequestPath $missingApprovalPath
    if ($missingApprovalResult.decision -ne "blocked" -or (@($missingApprovalResult.block_reasons.code) -notcontains "approval_missing")) {
        $failures += "FAIL missing approval request did not block with approval_missing."
    }
    Write-Output ("PASS missing approval block: {0}" -f ($missingApprovalResult.block_reasons.code -join ", "))

    $ambiguousScopeRequest = Get-JsonFixture -Path $ambiguousScopeFixture
    $ambiguousScopeRequest.packet_record_ref = $savedPacketPath
    $ambiguousScopePath = Join-Path $tempRoot "ambiguous-scope.request.json"
    Save-RequestFixture -RequestObject $ambiguousScopeRequest -Path $ambiguousScopePath

    $ambiguousScopeResult = Invoke-ApplyPromotionGate -GateRequestPath $ambiguousScopePath
    if ($ambiguousScopeResult.decision -ne "blocked" -or (@($ambiguousScopeResult.block_reasons.code) -notcontains "scope_ambiguous")) {
        $failures += "FAIL ambiguous scope request did not block with scope_ambiguous."
    }
    Write-Output ("PASS ambiguous scope block: {0}" -f ($ambiguousScopeResult.block_reasons.code -join ", "))

    $missingScopeRequest = Get-JsonFixture -Path $validRequestFixture
    $missingScopeRequest.packet_record_ref = $savedPacketPath
    $missingScopeRequest.gate_request_id = "gate-rst011-block-scope-missing-001"
    $missingScopeRequest.scope.allowed_paths = @()
    $missingScopePath = Join-Path $tempRoot "missing-scope.request.json"
    Save-RequestFixture -RequestObject $missingScopeRequest -Path $missingScopePath

    $missingScopeResult = Invoke-ApplyPromotionGate -GateRequestPath $missingScopePath
    if ($missingScopeResult.decision -ne "blocked" -or (@($missingScopeResult.block_reasons.code) -notcontains "scope_missing")) {
        $failures += "FAIL missing scope request did not block with scope_missing."
    }
    Write-Output ("PASS missing scope block: {0}" -f ($missingScopeResult.block_reasons.code -join ", "))

    $missingArtifactRequest = Get-JsonFixture -Path $missingArtifactFixture
    $missingArtifactRequest.packet_record_ref = $savedPacketPath
    $missingArtifactPath = Join-Path $tempRoot "missing-artifact.request.json"
    Save-RequestFixture -RequestObject $missingArtifactRequest -Path $missingArtifactPath

    $missingArtifactResult = Invoke-ApplyPromotionGate -GateRequestPath $missingArtifactPath
    if ($missingArtifactResult.decision -ne "blocked" -or (@($missingArtifactResult.block_reasons.code) -notcontains "artifact_linkage_missing")) {
        $failures += "FAIL missing artifact link request did not block with artifact_linkage_missing."
    }
    Write-Output ("PASS artifact linkage block: {0}" -f ($missingArtifactResult.block_reasons.code -join ", "))

    $reconciliationPacket = Get-PacketRecord -Path $validPacketFixture
    $reconciliationPacket.packet_id = "packet-rst011-recon-001"
    $reconciliationPacket.reconciliation_state.status = "pending"
    $reconciliationPacket.reconciliation_state.working_matches_accepted = $null
    $reconciliationPacket.reconciliation_state.git_head_matches_accepted = $null
    $reconciliationPacket.reconciliation_state.notes = "Reconciliation still pending."
    $reconciliationPacket.updated_at = "2026-04-19T13:17:00Z"
    $reconciliationPacketPath = Save-PacketRecord -PacketRecord $reconciliationPacket -StorePath $packetStore

    $reconciliationRequest = Get-JsonFixture -Path $validRequestFixture
    $reconciliationRequest.gate_request_id = "gate-rst011-block-reconciliation-001"
    $reconciliationRequest.packet_id = "packet-rst011-recon-001"
    $reconciliationRequest.packet_record_ref = $reconciliationPacketPath
    $reconciliationRequestPath = Join-Path $tempRoot "reconciliation.request.json"
    Save-RequestFixture -RequestObject $reconciliationRequest -Path $reconciliationRequestPath

    $reconciliationResult = Invoke-ApplyPromotionGate -GateRequestPath $reconciliationRequestPath
    if ($reconciliationResult.decision -ne "blocked" -or (@($reconciliationResult.block_reasons.code) -notcontains "reconciliation_unresolved")) {
        $failures += "FAIL unresolved reconciliation request did not block with reconciliation_unresolved."
    }
    $savedBlockedResult = Save-ApplyPromotionGateResult -GateResult $reconciliationResult -StorePath $resultStore
    $reloadedBlockedResult = Get-ApplyPromotionGateResult -Path $savedBlockedResult.GateResultPath
    if (-not $reloadedBlockedResult.blocked_state_record.recorded) {
        $failures += "FAIL blocked gate result did not record blocked state."
    }

    $reloadedBlockedPacket = Get-PacketRecord -Path $reconciliationPacketPath
    if ($reloadedBlockedPacket.working_state.status -ne "blocked") {
        $failures += "FAIL blocked gate outcome did not update packet working_state.status to blocked."
    }
    if ($reloadedBlockedPacket.working_state.notes -notmatch "Gate blocked by") {
        $failures += "FAIL blocked gate outcome did not persist blocked-state notes."
    }
    Write-Output ("PASS reconciliation block and recording: {0}" -f $savedBlockedResult.GateResultPath)
}
catch {
    $failures += ("FAIL gate test execution: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Apply/promotion gate tests failed. Failure count: {0}" -f $failures.Count)
}

Write-Output "All apply/promotion gate tests passed."
