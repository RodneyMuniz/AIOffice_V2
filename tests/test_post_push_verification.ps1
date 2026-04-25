$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\PostPushVerification.psm1") -Force -PassThru
$invokePostPushVerification = $module.ExportedCommands["Invoke-PostPushVerification"]
$assertPostPushVerificationSatisfied = $module.ExportedCommands["Assert-PostPushVerificationSatisfied"]
$testPostPushVerification = $module.ExportedCommands["Test-PostPushVerificationContract"]

function New-PostPushHarness {
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

    Set-Content -LiteralPath (Join-Path $workingRoot "README.md") -Value "# Post-push verification harness" -Encoding UTF8
    & git -C $workingRoot add README.md | Out-Null
    & git -C $workingRoot commit -m "seed post-push verification harness" | Out-Null
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

$tempRoot = Join-Path $shortBase ("r8ppv" + [guid]::NewGuid().ToString("N").Substring(0, 8))
try {
    $harness = New-PostPushHarness -Root $tempRoot
    $pushedCommit = (& git -C $harness.WorkingRoot rev-parse HEAD).Trim()

    $matchArtifactPath = Join-Path $harness.WorkingRoot "artifacts\post_push_verification.match.json"
    $matchResult = & $invokePostPushVerification -RepositoryRoot $harness.WorkingRoot -RepositoryName "AIOffice_V2" -Branch $harness.Branch -ExpectedPushedCommit $pushedCommit -OutputPath $matchArtifactPath
    if ($matchResult.Result -ne "passed" -or $matchResult.Status -ne "matched") {
        $failures += "FAIL valid: post-push verification did not pass when the pushed commit matched the remote head."
    }
    else {
        $validatedMatch = & $testPostPushVerification -ArtifactPath $matchArtifactPath
        $satisfiedMatch = & $assertPostPushVerificationSatisfied -ArtifactPath $matchArtifactPath -ExpectedPushedCommit $pushedCommit
        Write-Output ("PASS valid match: {0} -> {1}" -f $validatedMatch.VerificationId, $satisfiedMatch.ActualRemoteHead)
        $validPassed += 1
    }

    $scriptArtifactPath = Join-Path $harness.WorkingRoot "artifacts\post_push_verification.script.json"
    & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $repoRoot "tools\verify_post_push_remote_head.ps1") -RepositoryRoot $harness.WorkingRoot -RepositoryName "AIOffice_V2" -Branch $harness.Branch -ExpectedPushedCommit $pushedCommit -OutputPath $scriptArtifactPath | Out-Null
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $scriptArtifactPath)) {
        $failures += "FAIL valid: verify_post_push_remote_head.ps1 did not emit a durable artifact on the happy path."
    }
    else {
        Write-Output "PASS valid script smoke: verify_post_push_remote_head.ps1 emitted a durable artifact."
        $validPassed += 1
    }

    Add-Content -LiteralPath (Join-Path $harness.WorkingRoot "README.md") -Value "local-only drift after push"
    & git -C $harness.WorkingRoot add README.md | Out-Null
    & git -C $harness.WorkingRoot commit -m "local-only post-push mismatch" | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create local-only post-push mismatch commit."
    }

    $unpushedCommit = (& git -C $harness.WorkingRoot rev-parse HEAD).Trim()
    $mismatchArtifactPath = Join-Path $harness.WorkingRoot "artifacts\post_push_verification.mismatch.json"
    $mismatchResult = & $invokePostPushVerification -RepositoryRoot $harness.WorkingRoot -RepositoryName "AIOffice_V2" -Branch $harness.Branch -ExpectedPushedCommit $unpushedCommit -OutputPath $mismatchArtifactPath
    if ($mismatchResult.Result -ne "failed" -or $mismatchResult.Status -ne "mismatch") {
        $failures += "FAIL invalid: post-push mismatch was not recorded as a failed verification."
    }
    else {
        $validatedMismatch = & $testPostPushVerification -ArtifactPath $mismatchArtifactPath
        Write-Output ("PASS invalid mismatch artifact: {0} -> {1}" -f $validatedMismatch.VerificationId, $validatedMismatch.Status)
        $invalidRejected += 1
    }

    Invoke-ExpectedRefusal -Label "missing-verification-artifact" -RequiredFragments @("does not exist", "Post-push verification artifact") -Action {
        & $assertPostPushVerificationSatisfied -ArtifactPath (Join-Path $harness.WorkingRoot "artifacts\missing.json") -ExpectedPushedCommit $pushedCommit | Out-Null
    }
}
catch {
    $failures += ("FAIL post-push verification harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Post-push verification tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All post-push verification tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
