$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\SupervisedAdminHarness.psm1"
Import-Module $modulePath -Force

$allowFixture = Join-Path $repoRoot "state\fixtures\valid\supervised_admin_flow.allow.json"
$blockFixture = Join-Path $repoRoot "state\fixtures\valid\supervised_admin_flow.block.json"

$failures = @()
$allowActionOutcomePath = $null

try {
    $allowContract = Test-SupervisedAdminFlowRequestContract -FlowRequestPath $allowFixture
    Write-Output ("PASS harness request contract: {0} -> {1}" -f $allowContract.FlowRequestId, $allowContract.PacketMode)
}
catch {
    $failures += ("FAIL harness allow request contract: {0}" -f $_.Exception.Message)
}

try {
    $blockContract = Test-SupervisedAdminFlowRequestContract -FlowRequestPath $blockFixture
    Write-Output ("PASS harness request contract: {0} -> {1}" -f $blockContract.FlowRequestId, $blockContract.PacketMode)
}
catch {
    $failures += ("FAIL harness block request contract: {0}" -f $_.Exception.Message)
}

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("aioffice-rst012-" + [guid]::NewGuid().ToString("N"))
$allowRoot = Join-Path $tempRoot "allow"
$blockRoot = Join-Path $tempRoot "block"

try {
    $allowResult = Invoke-SupervisedAdminFlow -FlowRequestPath $allowFixture -OutputRoot $allowRoot
    if ($allowResult.Decision -ne "allow") {
        $failures += "FAIL allow harness flow did not return allow."
    }

    if (-not (Test-Path -LiteralPath $allowResult.PacketPath)) {
        $failures += "FAIL allow harness packet path was not created."
    }
    if (-not (Test-Path -LiteralPath $allowResult.GateRequestPath)) {
        $failures += "FAIL allow harness gate request path was not created."
    }
    if (-not (Test-Path -LiteralPath $allowResult.GateResultPath)) {
        $failures += "FAIL allow harness gate result path was not created."
    }
    if (-not (Test-Path -LiteralPath $allowResult.ActionRequestPath)) {
        $failures += "FAIL allow harness action request path was not created."
    }
    if (-not (Test-Path -LiteralPath $allowResult.ActionResultPath)) {
        $failures += "FAIL allow harness action result path was not created."
    }
    if (-not (Test-Path -LiteralPath $allowResult.ActionOutcomePath)) {
        $failures += "FAIL allow harness action outcome path was not created."
    }

    $allowPacket = Get-Content -LiteralPath $allowResult.PacketPath -Raw | ConvertFrom-Json
    $allowGateResult = Get-Content -LiteralPath $allowResult.GateResultPath -Raw | ConvertFrom-Json
    $allowActionResult = Get-Content -LiteralPath $allowResult.ActionResultPath -Raw | ConvertFrom-Json
    if ($allowPacket.current_stage -ne "architect") {
        $failures += "FAIL allow harness packet did not advance through architect."
    }
    if ($allowPacket.accepted_state.accepted_stage -ne "architect") {
        $failures += "FAIL allow harness packet did not accept the architect artifact."
    }
    if ($allowGateResult.decision -ne "allow") {
        $failures += "FAIL allow harness gate result did not persist allow."
    }
    if ($allowActionResult.status -ne "completed") {
        $failures += "FAIL allow harness action result did not persist completed status."
    }
    if ($allowPacket.working_state.artifact_refs -notcontains $allowResult.ActionOutcomePath.Replace($repoRoot + "\", "").Replace("\", "/")) {
        $failures += "FAIL allow harness packet working_state.artifact_refs did not include the bounded action outcome artifact."
    }
    if ($allowPacket.reconciliation_state.status -ne "drift") {
        $failures += "FAIL allow harness packet reconciliation_state.status did not become drift after the bounded action."
    }
    if ($allowPacket.reconciliation_state.working_matches_accepted -ne $false) {
        $failures += "FAIL allow harness packet did not record working_matches_accepted as false after the bounded action."
    }
    if ($allowPacket.reconciliation_state.git_head_matches_accepted -ne $true) {
        $failures += "FAIL allow harness packet did not keep git_head_matches_accepted true after the bounded action."
    }
    $allowActionOutcomePath = $allowResult.ActionOutcomePath
    Write-Output ("PASS allow supervised flow: {0}" -f $allowResult.GateResultPath)

    $blockResult = Invoke-SupervisedAdminFlow -FlowRequestPath $blockFixture -OutputRoot $blockRoot
    if ($blockResult.Decision -ne "blocked") {
        $failures += "FAIL block harness flow did not return blocked."
    }

    if (-not (Test-Path -LiteralPath $blockResult.PacketPath)) {
        $failures += "FAIL block harness packet path was not created."
    }
    if (-not (Test-Path -LiteralPath $blockResult.GateResultPath)) {
        $failures += "FAIL block harness gate result path was not created."
    }
    if ($null -ne $blockResult.ActionRequestPath -or $null -ne $blockResult.ActionResultPath -or $null -ne $blockResult.ActionOutcomePath) {
        $failures += "FAIL block harness flow should not return action artifact paths."
    }

    $blockPacket = Get-Content -LiteralPath $blockResult.PacketPath -Raw | ConvertFrom-Json
    $blockGateResult = Get-Content -LiteralPath $blockResult.GateResultPath -Raw | ConvertFrom-Json
    if ($blockGateResult.decision -ne "blocked") {
        $failures += "FAIL block harness gate result did not persist blocked."
    }
    if (-not $blockGateResult.blocked_state_record.recorded) {
        $failures += "FAIL block harness gate result did not record blocked state."
    }
    if ($blockPacket.working_state.status -ne "blocked") {
        $failures += "FAIL block harness packet working_state.status did not become blocked."
    }
    if ($blockPacket.working_state.notes -notmatch "Gate blocked by") {
        $failures += "FAIL block harness packet did not persist blocked-state notes."
    }
    if (@($blockGateResult.block_reasons.code) -contains "artifact_linkage_missing") {
        $failures += "FAIL block harness gate result still reported artifact_linkage_missing for the replayed load path."
    }
    Write-Output ("PASS block supervised flow: {0}" -f $blockResult.GateResultPath)
}
catch {
    $failures += ("FAIL supervised flow execution: {0}" -f $_.Exception.Message)
}
finally {
    if ($null -ne $allowActionOutcomePath -and (Test-Path -LiteralPath $allowActionOutcomePath)) {
        Remove-Item -LiteralPath $allowActionOutcomePath -Force
    }
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Supervised admin flow tests failed. Failure count: {0}" -f $failures.Count)
}

Write-Output "All supervised admin flow tests passed."
