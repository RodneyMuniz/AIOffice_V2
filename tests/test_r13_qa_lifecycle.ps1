$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R13QaLifecycle.psm1") -Force -PassThru
$testLifecycle = $module.ExportedCommands["Test-R13QaLifecycle"]
$testLifecycleObject = $module.ExportedCommands["Test-R13QaLifecycleObject"]

$validPath = Join-Path $repoRoot "state\fixtures\valid\actionable_qa\r13_qa_lifecycle.valid.json"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\actionable_qa\r13_qa_lifecycle"
$cliPath = Join-Path $repoRoot "tools\validate_r13_qa_lifecycle.ps1"
$validPassed = 0
$invalidRejected = 0
$failures = @()

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

function Read-FixtureObject {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json)
}

function Copy-JsonObject {
    param(
        [Parameter(Mandatory = $true)]
        $Object
    )

    return ($Object | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function Invoke-PowerShellFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        [Parameter(Mandatory = $true)]
        [string]$LifecyclePath
    )

    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $FilePath -LifecyclePath $LifecyclePath 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }

    return [pscustomobject]@{
        ExitCode = $exitCode
        Output = @($output)
    }
}

try {
    $validLifecycle = & $testLifecycle -LifecyclePath $validPath
    if ($validLifecycle.Stage -ne "initialized" -or $validLifecycle.AggregateVerdict -ne "not_ready" -or $validLifecycle.EvidenceRefCount -lt 2) {
        $failures += "FAIL valid: initialized lifecycle fixture did not validate with the expected honest incomplete posture."
    }
    else {
        Write-Output ("PASS valid R13 QA lifecycle fixture: {0}" -f $validLifecycle.LifecycleId)
        $validPassed += 1
    }

    $expectedInvalidFragments = @{
        "pass_without_rerun.invalid.json" = @("rerun_ref")
        "pass_without_fix.invalid.json" = @("fix_execution_ref")
        "pass_without_evidence.invalid.json" = @("evidence_refs", "empty")
        "narrative_only_qa.invalid.json" = @("narrative-only QA")
        "executor_self_certification.invalid.json" = @("executor self-certification")
        "local_only_as_external.invalid.json" = @("local-only", "external replay proof")
        "signoff_without_operator_summary.invalid.json" = @("operator_summary_ref")
        "unresolved_blocking_issues_as_pass.invalid.json" = @("unresolved blocking issues")
        "missing_non_claims.invalid.json" = @("non_claims")
        "r14_successor_opened.invalid.json" = @("R14", "successor")
    }

    $invalidFiles = @(Get-ChildItem -LiteralPath $invalidRoot -Filter "*.invalid.json" -File | Sort-Object Name)
    foreach ($expectedName in $expectedInvalidFragments.Keys) {
        if (@($invalidFiles | Where-Object { $_.Name -eq $expectedName }).Count -ne 1) {
            $failures += "FAIL fixture: missing invalid fixture '$expectedName'."
        }
    }

    foreach ($invalidFile in $invalidFiles) {
        if (-not $expectedInvalidFragments.ContainsKey($invalidFile.Name)) {
            $failures += "FAIL fixture: unexpected invalid fixture '$($invalidFile.Name)' lacks expected refusal fragments."
            continue
        }

        Invoke-ExpectedRefusal -Label $invalidFile.Name -RequiredFragments $expectedInvalidFragments[$invalidFile.Name] -Action {
            & $testLifecycle -LifecyclePath $invalidFile.FullName | Out-Null
        }
    }

    $cliValid = Invoke-PowerShellFile -FilePath $cliPath -LifecyclePath $validPath
    if ($cliValid.ExitCode -ne 0 -or ([string]::Join("`n", @($cliValid.Output)) -notmatch "VALID")) {
        $failures += "FAIL cli-valid: CLI validator did not return success for the valid fixture. Output: $([string]::Join(' ', @($cliValid.Output)))"
    }
    else {
        Write-Output "PASS CLI valid fixture returned success."
        $validPassed += 1
    }

    $cliInvalidPath = Join-Path $invalidRoot "pass_without_rerun.invalid.json"
    $cliInvalid = Invoke-PowerShellFile -FilePath $cliPath -LifecyclePath $cliInvalidPath
    if ($cliInvalid.ExitCode -eq 0) {
        $failures += "FAIL cli-invalid: CLI validator returned success for an invalid lifecycle. Output: $([string]::Join(' ', @($cliInvalid.Output)))"
    }
    else {
        Write-Output "PASS CLI invalid fixture returned non-zero."
        $invalidRejected += 1
    }

    $finalBase = Read-FixtureObject -Path (Join-Path $invalidRoot "pass_without_rerun.invalid.json")
    $finalBase.rerun_ref = "tests/test_r13_qa_lifecycle.ps1"
    $withoutRerun = Copy-JsonObject -Object $finalBase
    $withoutRerun.rerun_ref = ""
    Invoke-ExpectedRefusal -Label "final-signoff-without-rerun" -RequiredFragments @("rerun_ref") -Action {
        & $testLifecycleObject -Lifecycle $withoutRerun -SourceLabel "dynamic final lifecycle" | Out-Null
    }

    $withoutComparison = Copy-JsonObject -Object $finalBase
    $withoutComparison.before_after_comparison_ref = ""
    Invoke-ExpectedRefusal -Label "final-signoff-without-comparison" -RequiredFragments @("before_after_comparison_ref") -Action {
        & $testLifecycleObject -Lifecycle $withoutComparison -SourceLabel "dynamic final lifecycle" | Out-Null
    }

    $withoutExternalReplay = Copy-JsonObject -Object $finalBase
    $withoutExternalReplay.external_replay_ref = ""
    Invoke-ExpectedRefusal -Label "final-signoff-without-external-replay" -RequiredFragments @("external_replay_ref") -Action {
        & $testLifecycleObject -Lifecycle $withoutExternalReplay -SourceLabel "dynamic final lifecycle" | Out-Null
    }

    $withoutOperatorSummary = Copy-JsonObject -Object $finalBase
    $withoutOperatorSummary.operator_summary_ref = ""
    Invoke-ExpectedRefusal -Label "final-signoff-without-operator-summary" -RequiredFragments @("operator_summary_ref") -Action {
        & $testLifecycleObject -Lifecycle $withoutOperatorSummary -SourceLabel "dynamic final lifecycle" | Out-Null
    }

    Invoke-ExpectedRefusal -Label "dynamic-narrative-only-qa" -RequiredFragments @("narrative-only QA") -Action {
        & $testLifecycle -LifecyclePath (Join-Path $invalidRoot "narrative_only_qa.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "dynamic-executor-self-certification" -RequiredFragments @("executor self-certification") -Action {
        & $testLifecycle -LifecyclePath (Join-Path $invalidRoot "executor_self_certification.invalid.json") | Out-Null
    }
}
catch {
    $failures += ("FAIL R13 QA lifecycle harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R13 QA lifecycle tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R13 QA lifecycle tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
