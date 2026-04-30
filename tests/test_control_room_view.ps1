$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\render_control_room_view.psm1") -Force -PassThru
$testView = $module.ExportedCommands["Test-ControlRoomViewMarkdown"]
$exportView = $module.ExportedCommands["Export-ControlRoomViewMarkdown"]

$validStatusPath = Join-Path $repoRoot "state\fixtures\valid\control_room\control_room_status.foundation.valid.json"
$validRoot = Join-Path $repoRoot "state\fixtures\valid\control_room_view"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\control_room_view"
$currentStatusPath = Join-Path $repoRoot "state\control_room\r12_current\control_room_status.json"
$currentViewPath = Join-Path $repoRoot "state\control_room\r12_current\control_room.md"
$validPassed = 0
$invalidRejected = 0
$failures = @()
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r12_control_room_view_" + [guid]::NewGuid().ToString("N").Substring(0, 8))

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

try {
    $fixtureView = & $testView -StatusPath $validStatusPath -MarkdownPath (Join-Path $validRoot "control_room.valid.md")
    if ($fixtureView.BlockerCount -lt 1 -or $fixtureView.EvidenceRefCount -lt 1) {
        $failures += "FAIL valid: control-room view fixture did not expose blockers and evidence refs."
    }
    else {
        Write-Output ("PASS valid control-room Markdown fixture: {0}" -f $fixtureView.MarkdownPath)
        $validPassed += 1
    }

    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
    $generatedViewPath = Join-Path $tempRoot "generated_control_room.md"
    & $exportView -StatusPath $validStatusPath -MarkdownOutputPath $generatedViewPath -Overwrite | Out-Null
    $generatedView = & $testView -StatusPath $validStatusPath -MarkdownPath $generatedViewPath
    if ($generatedView.Branch -ne "release/r12-external-api-runner-actionable-qa-control-room-pilot") {
        $failures += "FAIL valid: generated control-room Markdown did not preserve branch."
    }
    else {
        Write-Output ("PASS valid generated control-room Markdown: {0}" -f $generatedView.MarkdownPath)
        $validPassed += 1
    }

    $currentView = & $testView -StatusPath $currentStatusPath -MarkdownPath $currentViewPath
    if ($currentView.BlockerCount -lt 1) {
        $failures += "FAIL valid: current generated control-room Markdown did not preserve blockers."
    }
    else {
        Write-Output ("PASS valid current generated control-room Markdown: {0}" -f $currentView.MarkdownPath)
        $validPassed += 1
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-section" -RequiredFragments @("missing required section", "External Runner Posture") -Action {
        & $testView -StatusPath $validStatusPath -MarkdownPath (Join-Path $invalidRoot "control_room.missing-section.invalid.md") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-non-claims" -RequiredFragments @("non-claim") -Action {
        & $testView -StatusPath $validStatusPath -MarkdownPath (Join-Path $invalidRoot "control_room.missing-non-claims.invalid.md") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-productized-ui-overclaim" -RequiredFragments @("forbidden positive view claim", "productized control-room behavior") -Action {
        & $testView -StatusPath $validStatusPath -MarkdownPath (Join-Path $invalidRoot "control_room.productized-ui-overclaim.invalid.md") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-hidden-blocker" -RequiredFragments @("must include blocker") -Action {
        & $testView -StatusPath $validStatusPath -MarkdownPath (Join-Path $invalidRoot "control_room.hidden-blocker.invalid.md") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-evidence-refs" -RequiredFragments @("evidence ref") -Action {
        & $testView -StatusPath $validStatusPath -MarkdownPath (Join-Path $invalidRoot "control_room.missing-evidence-refs.invalid.md") | Out-Null
    }
}
catch {
    $failures += ("FAIL control-room view harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Control-room view tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All control-room view tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
