$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$proofModulePath = Join-Path $repoRoot "tools\BoundedProofSuite.psm1"
$repoEnforcementModulePath = Join-Path $repoRoot "tools\RepoEnforcement.psm1"
Import-Module $proofModulePath -Force
Import-Module $repoEnforcementModulePath -Force

$failures = @()

function Write-Utf8File {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [AllowNull()]
        [string]$Value
    )

    $directory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($directory) -and -not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    if ($null -eq $Value) {
        $Value = ""
    }

    Set-Content -LiteralPath $Path -Value $Value -Encoding UTF8
}

function New-ValidProofHarness {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root
    )

    $selectedIds = @(
        "r5-restore-gate",
        "r5-resume-reentry"
    )

    $proofResult = Invoke-BoundedProofSuite -OutputRoot $Root -TestIds $selectedIds
    $summary = Get-Content -LiteralPath $proofResult.SummaryPath -Raw | ConvertFrom-Json
    $replaySummaryPath = Join-Path $Root "REPLAY_SUMMARY.md"
    $replayedCommandPath = Join-Path $Root "meta\replayed_command.txt"

    Write-Utf8File -Path $replaySummaryPath -Value "# Replay Summary`n`n- bounded R5 subset"
    Write-Utf8File -Path $replayedCommandPath -Value "powershell -ExecutionPolicy Bypass -File tools\new_r5_recovery_resume_proof_review.ps1"

    return [pscustomobject]@{
        Root        = $Root
        SummaryPath = $proofResult.SummaryPath
        Summary     = $summary
        SelectedIds = $selectedIds
    }
}

function Invoke-RepoEnforcementCase {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Arrange,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Assert
    )

    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-repo-enforcement-" + [guid]::NewGuid().ToString("N"))
    try {
        $harness = New-ValidProofHarness -Root $tempRoot
        & $Arrange $harness
        $result = Invoke-RepoEnforcementCheck -ProofOutputRoot $harness.Root -RequiredProofIds $harness.SelectedIds -PreReplayStatusLines @()
        & $Assert $result $harness
    }
    catch {
        $failures += ("FAIL {0}: {1}" -f $Label, $_.Exception.Message)
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}

Invoke-RepoEnforcementCase -Label "valid repo enforcement allow path" -Arrange {
    param($harness)
} -Assert {
    param($result, $harness)

    if ($result.decision -ne "allow") {
        throw "Repo enforcement did not allow a valid bounded proof review."
    }

    $savedPath = Save-RepoEnforcementResult -EnforcementResult $result -OutputRoot $harness.Root
    $validation = Test-RepoEnforcementResultContract -EnforcementResultPath $savedPath
    if (-not $validation.IsValid -or $validation.Decision -ne "allow") {
        throw "Saved repo enforcement result did not validate as an allow decision."
    }

    Write-Output ("PASS valid repo enforcement allow path: {0}" -f $savedPath)
}

Invoke-RepoEnforcementCase -Label "dirty-worktree refusal" -Arrange {
    param($harness)
} -Assert {
    param($result, $harness)

    $blocked = Invoke-RepoEnforcementCheck -ProofOutputRoot $harness.Root -RequiredProofIds $harness.SelectedIds -PreReplayStatusLines @(" M README.md")
    if ($blocked.decision -ne "blocked") {
        throw "Repo enforcement did not block a dirty pre-replay worktree."
    }

    if (@($blocked.block_reasons | Where-Object { $_.code -eq "workspace_dirty" }).Count -eq 0) {
        throw "Repo enforcement dirty-worktree block reason was not recorded."
    }

    Write-Output "PASS dirty-worktree refusal: repo enforcement requires a clean Git worktree before replay."
}

Invoke-RepoEnforcementCase -Label "missing replay summary refusal" -Arrange {
    param($harness)
    Remove-Item -LiteralPath (Join-Path $harness.Root "REPLAY_SUMMARY.md") -Force
} -Assert {
    param($result, $harness)

    if ($result.decision -ne "blocked") {
        throw "Repo enforcement did not block a missing replay summary."
    }

    if (@($result.block_reasons | Where-Object { $_.code -eq "replay_summary_missing" }).Count -eq 0) {
        throw "Repo enforcement missing replay-summary reason was not recorded."
    }

    Write-Output "PASS missing replay summary refusal: replay summary Markdown is required."
}

try {
    $repoScopedRoot = Join-Path $repoRoot ("scratch\r5-repo-enforcement-" + [guid]::NewGuid().ToString("N"))
    $repoScopedHarness = New-ValidProofHarness -Root $repoScopedRoot
    $result = Invoke-RepoEnforcementCheck -ProofOutputRoot $repoScopedHarness.Root -RequiredProofIds $repoScopedHarness.SelectedIds -PreReplayStatusLines @()
    $governedOutputReasons = @($result.block_reasons | Where-Object { $_.code -eq "governed_output_root_required" })

    if ($result.decision -ne "blocked") {
        throw "Repo enforcement did not block an output root outside the governed proof review subtree."
    }

    if ($governedOutputReasons.Count -eq 0) {
        throw "Repo enforcement did not record the governed-output-root block reason."
    }

    Write-Output "PASS governed output root refusal: proof output inside the repository must stay under state/proof_reviews/."
}
catch {
    $failures += ("FAIL governed output root refusal: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $repoScopedRoot) {
        Remove-Item -LiteralPath $repoScopedRoot -Recurse -Force
    }
}

Invoke-RepoEnforcementCase -Label "selection mismatch refusal" -Arrange {
    param($harness)
    $summary = Get-Content -LiteralPath $harness.SummaryPath -Raw | ConvertFrom-Json
    $summary.selection_ids = @("r5-restore-gate")
    $summary | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $harness.SummaryPath -Encoding UTF8
} -Assert {
    param($result, $harness)

    if ($result.decision -ne "blocked") {
        throw "Repo enforcement did not block mismatched proof selection ids."
    }

    if (@($result.block_reasons | Where-Object { $_.code -eq "required_selection_missing" -or $_.code -eq "selection_scope_mismatch" }).Count -eq 0) {
        throw "Repo enforcement did not record a selection-scope block reason."
    }

    Write-Output "PASS selection mismatch refusal: proof review selection must match the required id set exactly."
}

Invoke-RepoEnforcementCase -Label "replay source head mismatch refusal" -Arrange {
    param($harness)
    $summary = Get-Content -LiteralPath $harness.SummaryPath -Raw | ConvertFrom-Json
    $summary.repo_head = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    $summary | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $harness.SummaryPath -Encoding UTF8
} -Assert {
    param($result, $harness)

    if ($result.decision -ne "blocked") {
        throw "Repo enforcement did not block a stale replay-source head."
    }

    if (@($result.block_reasons | Where-Object { $_.code -eq "replay_source_head_mismatch" }).Count -eq 0) {
        throw "Repo enforcement did not record a replay-source-head mismatch reason."
    }

    Write-Output "PASS replay source head mismatch refusal: stale proof reviews fail closeout discipline."
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Repo enforcement tests failed. Failure count: {0}" -f $failures.Count)
}

Write-Output "All repo enforcement tests passed."
