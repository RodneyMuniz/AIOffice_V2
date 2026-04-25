$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$runnerModule = Import-Module (Join-Path $repoRoot "tools\CleanCheckoutQaRunner.psm1") -Force -PassThru
$invokeCleanCheckoutQaRun = $runnerModule.ExportedCommands["Invoke-CleanCheckoutQaRun"]
$qaPacketModule = Import-Module (Join-Path $repoRoot "tools\QaProofPacket.psm1") -Force -PassThru
$testQaProofPacket = $qaPacketModule.ExportedCommands["Test-QaProofPacketContract"]

function New-CleanCheckoutHarness {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root
    )

    $originRoot = Join-Path $Root "origin.git"
    $workingRoot = Join-Path $Root "working"
    $branch = "feature/r5-closeout-remaining-foundations"

    New-Item -ItemType Directory -Path $Root -Force | Out-Null
    & git init --bare $originRoot | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to initialize bare origin repository."
    }

    & git clone $originRoot $workingRoot | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to clone working repository."
    }

    & git -C $workingRoot config user.email "codex@example.com" | Out-Null
    & git -C $workingRoot config user.name "Codex" | Out-Null
    & git -C $workingRoot checkout -b $branch | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create working branch '$branch'."
    }

    New-Item -ItemType Directory -Path (Join-Path $workingRoot "tests") -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $workingRoot "README.md") -Value "# Clean checkout harness" -Encoding UTF8
    Set-Content -LiteralPath (Join-Path $workingRoot "tests\pass.ps1") -Value "Write-Output 'PASS: clean checkout command'" -Encoding UTF8
    Set-Content -LiteralPath (Join-Path $workingRoot "tests\fail.ps1") -Value "Write-Output 'FAIL: intentional'; exit 1" -Encoding UTF8
    Set-Content -LiteralPath (Join-Path $workingRoot "tests\dirty.ps1") -Value "Add-Content -LiteralPath README.md -Value 'dirty from clean-checkout qa'; Write-Output 'DIRTY: mutated checkout'" -Encoding UTF8

    & git -C $workingRoot add README.md tests | Out-Null
    & git -C $workingRoot commit -m "seed clean checkout qa harness" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create initial working commit."
    }

    & git -C $workingRoot push -u origin $branch | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to push initial working branch."
    }

    return [pscustomobject]@{
        Root = $Root
        OriginRoot = $originRoot
        WorkingRoot = $workingRoot
        Branch = $branch
        RemoteHead = (& git -C $workingRoot rev-parse HEAD).Trim()
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

$validPassed = 0
$invalidRejected = 0
$failures = @()

$shortBase = "C:\t"
if (-not (Test-Path -LiteralPath $shortBase)) {
    New-Item -ItemType Directory -Path $shortBase -Force | Out-Null
}

$tempRoot = Join-Path $shortBase ("r8cqa" + [guid]::NewGuid().ToString("N").Substring(0, 8))
try {
    $harness = New-CleanCheckoutHarness -Root $tempRoot

    $happyOutputRoot = Join-Path $tempRoot "qa\happy"
    $happyRun = & $invokeCleanCheckoutQaRun -RepositoryRoot $harness.WorkingRoot -RepositoryName "AIOffice_V2" -Branch $harness.Branch -RemoteSha $harness.RemoteHead -Commands @("powershell -NoProfile -ExecutionPolicy Bypass -File tests\pass.ps1") -OutputRoot $happyOutputRoot
    $happyPacket = & $testQaProofPacket -PacketPath $happyRun.PacketPath
    if ($happyPacket.Verdict -ne "passed") {
        $failures += "FAIL valid: clean-checkout happy path did not produce a passed QA packet."
    }
    elseif ($happyRun.CheckoutStrategy -ne "git_worktree") {
        $failures += "FAIL valid: clean-checkout happy path did not report git_worktree strategy."
    }
    elseif (Test-Path -LiteralPath $happyRun.CheckoutRoot) {
        $failures += "FAIL valid: clean-checkout happy path left the disposable checkout root behind."
    }
    else {
        Write-Output ("PASS valid clean-checkout happy path: {0} -> {1}" -f $happyPacket.PacketId, $happyPacket.Verdict)
        $validPassed += 1
    }

    $failureOutputRoot = Join-Path $tempRoot "qa\failure"
    $failureRun = & $invokeCleanCheckoutQaRun -RepositoryRoot $harness.WorkingRoot -RepositoryName "AIOffice_V2" -Branch $harness.Branch -RemoteSha $harness.RemoteHead -Commands @("powershell -NoProfile -ExecutionPolicy Bypass -File tests\fail.ps1") -OutputRoot $failureOutputRoot
    $failurePacket = & $testQaProofPacket -PacketPath $failureRun.PacketPath
    if ($failurePacket.Verdict -ne "failed") {
        $failures += "FAIL valid: command failure did not produce a failed QA packet."
    }
    elseif (Test-Path -LiteralPath $failureRun.CheckoutRoot) {
        $failures += "FAIL valid: failed-command run left the disposable checkout root behind."
    }
    else {
        Write-Output ("PASS valid failed-command packet: {0} -> {1}" -f $failurePacket.PacketId, $failurePacket.Verdict)
        $validPassed += 1
    }

    $dirtyOutputRoot = Join-Path $tempRoot "qa\dirty"
    $dirtyRun = & $invokeCleanCheckoutQaRun -RepositoryRoot $harness.WorkingRoot -RepositoryName "AIOffice_V2" -Branch $harness.Branch -RemoteSha $harness.RemoteHead -Commands @("powershell -NoProfile -ExecutionPolicy Bypass -File tests\dirty.ps1") -OutputRoot $dirtyOutputRoot
    $dirtyPacket = & $testQaProofPacket -PacketPath $dirtyRun.PacketPath
    if ($dirtyPacket.Verdict -ne "failed") {
        $failures += "FAIL valid: dirty final checkout did not produce a failed QA packet."
    }
    elseif (Test-Path -LiteralPath $dirtyRun.CheckoutRoot) {
        $failures += "FAIL valid: dirty-final run left the disposable checkout root behind."
    }
    else {
        Write-Output ("PASS valid dirty-final packet: {0} -> {1}" -f $dirtyPacket.PacketId, $dirtyPacket.Verdict)
        $validPassed += 1
    }

    Invoke-ExpectedRefusal -Label "missing-command-log" -RequiredFragments @("stdout_log_ref", "does not exist") -Action {
        Remove-Item -LiteralPath (Join-Path $happyOutputRoot "logs\command-001.stdout.log") -Force
        & $testQaProofPacket -PacketPath (Join-Path $happyOutputRoot "qa_proof_packet.json") | Out-Null
    }

    Add-Content -LiteralPath (Join-Path $harness.WorkingRoot "README.md") -Value "local-only unpushed commit"
    & git -C $harness.WorkingRoot add README.md | Out-Null
    & git -C $harness.WorkingRoot commit -m "local-only checkout mismatch" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create local-only mismatch commit."
    }
    $localOnlyHead = (& git -C $harness.WorkingRoot rev-parse HEAD).Trim()
    Invoke-ExpectedRefusal -Label "checkout-sha-mismatch" -RequiredFragments @("does not match actual remote head", $localOnlyHead) -Action {
        & $invokeCleanCheckoutQaRun -RepositoryRoot $harness.WorkingRoot -RepositoryName "AIOffice_V2" -Branch $harness.Branch -RemoteSha $localOnlyHead -Commands @("powershell -NoProfile -ExecutionPolicy Bypass -File tests\pass.ps1") -OutputRoot (Join-Path $tempRoot "qa\mismatch") | Out-Null
    }
}
catch {
    $failures += ("FAIL clean-checkout QA harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Clean-checkout QA runner tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All clean-checkout QA runner tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
