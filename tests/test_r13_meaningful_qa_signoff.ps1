$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R13MeaningfulQaSignoff.psm1") -Force -PassThru
$generate = $module.ExportedCommands["New-R13MeaningfulQaSignoffArtifacts"]
$testSignoff = $module.ExportedCommands["Test-R13MeaningfulQaSignoff"]
$testMatrix = $module.ExportedCommands["Test-R13MeaningfulQaSignoffEvidenceMatrix"]
$writeJson = $module.ExportedCommands["Write-R13SignoffJsonFile"]

$tempRoot = Join-Path $repoRoot ("state\signoff\_test_runs\" + [guid]::NewGuid().ToString("N"))
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

function Invoke-MutatedSignoffRefusal {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [string]$SourceSignoffPath,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Mutator
    )

    $signoff = Read-JsonObject -Path $SourceSignoffPath
    & $Mutator $signoff
    $invalidPath = Join-Path $tempRoot ("invalid\" + $Label + ".json")
    Write-JsonObject -Path $invalidPath -Value $signoff
    Invoke-ExpectedRefusal -Label $Label -Action {
        & $testSignoff -SignoffPath $invalidPath | Out-Null
    }
}

try {
    $validRoot = Join-Path $tempRoot "valid"
    $validSignoffPath = Join-Path $validRoot "r13_012_signoff.json"
    $validMatrixPath = Join-Path $validRoot "r13_012_evidence_matrix.json"
    $validManifestPath = Join-Path $validRoot "validation_manifest.md"
    $generated = & $generate -SignoffPath $validSignoffPath -MatrixPath $validMatrixPath -ManifestPath $validManifestPath
    if ($generated.SignoffDecision -ne "accepted_bounded_scope" -or $generated.AggregateVerdict -ne "passed") {
        $failures += "FAIL valid: generated signoff did not pass for bounded scope."
    }
    else {
        Write-Output "PASS valid: bounded signoff generated."
        $validPassed += 1
    }

    & $testSignoff -SignoffPath $validSignoffPath | Out-Null
    Write-Output "PASS valid: bounded signoff validates."
    $validPassed += 1

    & $testMatrix -MatrixPath $validMatrixPath | Out-Null
    Write-Output "PASS valid: evidence matrix validates."
    $validPassed += 1

    Assert-CliValid -Label "signoff CLI validates" -FilePath (Join-Path $repoRoot "tools\validate_r13_meaningful_qa_signoff.ps1") -Arguments @("-SignoffPath", $validSignoffPath)
    Assert-CliValid -Label "matrix CLI validates" -FilePath (Join-Path $repoRoot "tools\validate_r13_meaningful_qa_signoff_evidence_matrix.ps1") -Arguments @("-MatrixPath", $validMatrixPath)

    Invoke-MutatedSignoffRefusal -Label "missing_external_replay.invalid" -SourceSignoffPath $validSignoffPath -Mutator {
        param($signoff)
        $signoff.evidence_refs = @($signoff.evidence_refs | Where-Object { [string]$_.ref_id -ne "r13-011-external-replay-result" })
    }
    Invoke-MutatedSignoffRefusal -Label "missing_operator_demo.invalid" -SourceSignoffPath $validSignoffPath -Mutator {
        param($signoff)
        $signoff.evidence_refs = @($signoff.evidence_refs | Where-Object { [string]$_.ref_id -ne "r13-operator-demo" })
    }
    Invoke-MutatedSignoffRefusal -Label "missing_evidence_matrix.invalid" -SourceSignoffPath $validSignoffPath -Mutator {
        param($signoff)
        $signoff.evidence_refs = @($signoff.evidence_refs | Where-Object { [string]$_.ref_id -ne "r13-012-evidence-matrix" })
    }
    Invoke-MutatedSignoffRefusal -Label "product_wide_qa_claim.invalid" -SourceSignoffPath $validSignoffPath -Mutator {
        param($signoff)
        $signoff.signoff_scope = "full product QA coverage for the whole product"
    }
    Invoke-MutatedSignoffRefusal -Label "production_runtime_claim.invalid" -SourceSignoffPath $validSignoffPath -Mutator {
        param($signoff)
        $signoff.gate_assessment.production_runtime = "production runtime delivered"
    }
    Invoke-MutatedSignoffRefusal -Label "r13_closeout_claim.invalid" -SourceSignoffPath $validSignoffPath -Mutator {
        param($signoff)
        $signoff.gate_assessment.r13_closeout = "R13 closeout completed"
    }
    Invoke-MutatedSignoffRefusal -Label "r14_successor_claim.invalid" -SourceSignoffPath $validSignoffPath -Mutator {
        param($signoff)
        $signoff.gate_assessment.r14_or_successor = "R14 successor opened"
    }

    $statusPath = Join-Path $repoRoot "state\control_room\r13_current\control_room_status.json"
    $originalStatusText = Get-Content -LiteralPath $statusPath -Raw
    try {
        $staleStatus = $originalStatusText | ConvertFrom-Json
        $staleStatus.stale_state_checks.head_matches_expected = $false
        $staleStatus.stale_state_checks.stale_state_checks_passed = $false
        Write-JsonObject -Path $statusPath -Value $staleStatus
        Invoke-ExpectedRefusal -Label "stale_control_room_status.invalid" -Action {
            & $testSignoff -SignoffPath $validSignoffPath | Out-Null
        }
    }
    finally {
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($statusPath, $originalStatusText, $utf8NoBom)
    }
}
catch {
    $failures += ("FAIL R13 meaningful QA signoff harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        $resolvedTemp = [System.IO.Path]::GetFullPath($tempRoot)
        $allowedPrefix = [System.IO.Path]::GetFullPath((Join-Path $repoRoot "state\signoff\_test_runs")).TrimEnd([System.IO.Path]::DirectorySeparatorChar)
        if ($resolvedTemp.StartsWith($allowedPrefix + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R13 meaningful QA signoff tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R13 meaningful QA signoff tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
