$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R13CompactionMitigation.psm1") -Force -PassThru
$generate = $module.ExportedCommands["New-R13CompactionMitigationArtifacts"]
$testPacket = $module.ExportedCommands["Test-R13CompactionMitigationPacket"]
$testPrompt = $module.ExportedCommands["Test-R13RestartPrompt"]
$testIdentity = $module.ExportedCommands["Test-R13IdentityReconciliation"]
$writeJson = $module.ExportedCommands["Write-R13ContinuityJsonFile"]

$validatePacketCli = Join-Path $repoRoot "tools\validate_r13_compaction_mitigation_packet.ps1"
$validatePromptCli = Join-Path $repoRoot "tools\validate_r13_restart_prompt.ps1"
$tempRoot = Join-Path $repoRoot ("state\continuity\_test_runs\" + [guid]::NewGuid().ToString("N"))

$validPassed = 0
$invalidRejected = 0
$failures = @()

function Read-JsonObject {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json)
}

function Write-JsonObject {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Value
    )

    & $script:writeJson -Path $Path -Value $Value
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

function Invoke-ExpectedRefusal {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Action
    )

    try {
        & $Action
        $script:failures += ("FAIL invalid: {0} was accepted unexpectedly." -f $Label)
    }
    catch {
        Write-Output ("PASS invalid: {0} -> {1}" -f $Label, $_.Exception.Message)
        $script:invalidRejected += 1
    }
}

function Assert-CliValid {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        [string[]]$Arguments = @()
    )

    $result = Invoke-PowerShellFile -FilePath $FilePath -Arguments $Arguments
    if ($result.ExitCode -ne 0 -or ([string]::Join("`n", @($result.Output)) -notmatch "VALID")) {
        $script:failures += ("FAIL valid: {0} did not print VALID. Output: {1}" -f $Label, ([string]::Join(" ", @($result.Output))))
        return
    }

    Write-Output ("PASS valid: {0}" -f $Label)
    $script:validPassed += 1
}

try {
    $identityPath = Join-Path $tempRoot "r13_013_identity_reconciliation.json"
    $packetPath = Join-Path $tempRoot "r13_013_compaction_mitigation_packet.json"
    $promptPath = Join-Path $tempRoot "r13_013_restart_prompt.md"
    $manifestPath = Join-Path $tempRoot "validation_manifest.md"

    $generated = & $generate -IdentityReconciliationPath $identityPath -PacketPath $packetPath -PromptPath $promptPath -ManifestPath $manifestPath
    if (-not (Test-Path -LiteralPath $identityPath) -or -not (Test-Path -LiteralPath $packetPath) -or -not (Test-Path -LiteralPath $promptPath) -or -not (Test-Path -LiteralPath $manifestPath)) {
        $failures += "FAIL generated artifacts: one or more expected artifacts were missing."
    }
    else {
        Write-Output "PASS generated R13-013 continuity artifacts."
        $validPassed += 1
    }

    $packetValidation = & $testPacket -PacketPath $packetPath
    if ($packetValidation.ActiveThroughTask -ne "R13-013" -or $packetValidation.PlannedRange -ne "R13-014 through R13-018" -or $packetValidation.NextLegalAction -ne "R13-014") {
        $failures += "FAIL generated packet: R13 boundary was not R13-013/R13-014."
    }
    else {
        Write-Output "PASS generated packet: R13 active through R13-013 only."
        $validPassed += 1
    }

    & $testPrompt -PromptPath $promptPath | Out-Null
    Write-Output "PASS generated restart prompt."
    $validPassed += 1

    $identityValidation = & $testIdentity -IdentityReconciliationPath $identityPath
    if ($identityValidation.SignoffGeneratedFromHead -ne "fb2179bb7b66d3d7dd1fd4eb2683aed825f01577" -or $identityValidation.SignoffCommittedAtHead -ne "9f80291b0f3049ec1dd15635079705db031383fd" -or $identityValidation.Verdict -ne "accepted_as_generation_identity_not_current_identity") {
        $failures += "FAIL identity reconciliation: expected generated and committed heads were not preserved."
    }
    else {
        Write-Output "PASS identity reconciliation: generated head and durable commit are explicit."
        $validPassed += 1
    }

    Assert-CliValid -Label "packet validator CLI" -FilePath $validatePacketCli -Arguments @("-PacketPath", $packetPath)
    Assert-CliValid -Label "restart prompt validator CLI" -FilePath $validatePromptCli -Arguments @("-PromptPath", $promptPath)

    $packet = Read-JsonObject -Path $packetPath
    $invalidPacketPath = Join-Path $tempRoot "invalid_packet_boundary.json"
    $packet.active_scope.active_through_task = "R13-012"
    Write-JsonObject -Path $invalidPacketPath -Value $packet
    Invoke-ExpectedRefusal -Label "packet-active-through-r13-012.invalid" -Action {
        & $testPacket -PacketPath $invalidPacketPath | Out-Null
    }

    $packet = Read-JsonObject -Path $packetPath
    $invalidPacketPath = Join-Path $tempRoot "invalid_packet_no_identity.json"
    $packet.identity_reconciliation_ref = "state/continuity/r13_compaction_mitigation/missing_identity_reconciliation.json"
    Write-JsonObject -Path $invalidPacketPath -Value $packet
    Invoke-ExpectedRefusal -Label "packet-missing-identity-reconciliation.invalid" -Action {
        & $testPacket -PacketPath $invalidPacketPath | Out-Null
    }

    $packet = Read-JsonObject -Path $packetPath
    $invalidPacketPath = Join-Path $tempRoot "invalid_packet_missing_non_claim.json"
    $packet.non_claims = @($packet.non_claims | Where-Object { [string]$_ -ne "does not solve Codex compaction generally" })
    Write-JsonObject -Path $invalidPacketPath -Value $packet
    Invoke-ExpectedRefusal -Label "packet-missing-compaction-nonclaim.invalid" -Action {
        & $testPacket -PacketPath $invalidPacketPath | Out-Null
    }

    $invalidPromptPath = Join-Path $tempRoot "invalid_restart_prompt.md"
    $promptText = Get-Content -LiteralPath $promptPath -Raw
    $promptText = $promptText.Replace("R13-014 is allowed only after R13-013 is committed, pushed, and verified", "R13-014 is allowed immediately")
    Set-Content -LiteralPath $invalidPromptPath -Value $promptText -Encoding UTF8
    Invoke-ExpectedRefusal -Label "prompt-allows-r13-014-too-early.invalid" -Action {
        & $testPrompt -PromptPath $invalidPromptPath | Out-Null
    }

    $manifestText = Get-Content -LiteralPath $manifestPath -Raw
    if ($manifestText -notmatch "R13 active through ``R13-013`` only" -or $manifestText -notmatch "signoff generated from ``fb2179bb7b66d3d7dd1fd4eb2683aed825f01577`` and committed at ``9f80291b0f3049ec1dd15635079705db031383fd``") {
        $failures += "FAIL validation manifest: R13 boundary or identity reconciliation summary was missing."
    }
    else {
        Write-Output "PASS validation manifest records boundary and identity reconciliation."
        $validPassed += 1
    }
}
catch {
    $failures += ("FAIL R13 compaction mitigation harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        $resolvedTemp = [System.IO.Path]::GetFullPath($tempRoot)
        $allowedPrefix = [System.IO.Path]::GetFullPath((Join-Path $repoRoot "state\continuity\_test_runs")).TrimEnd([System.IO.Path]::DirectorySeparatorChar)
        if ($resolvedTemp.StartsWith($allowedPrefix + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R13 compaction mitigation tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R13 compaction mitigation tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
