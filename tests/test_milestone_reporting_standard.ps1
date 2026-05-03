$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$validator = Join-Path $repoRoot "tools\validate_milestone_reporting_standard.ps1"

if (-not (Test-Path -LiteralPath $validator -PathType Leaf)) {
    throw "Validator not found: $validator"
}

$result = & $validator -RepositoryRoot $repoRoot -PassThru

if ($result.verdict -ne "passed") {
    throw "Expected validator verdict 'passed'."
}

if ($result.required_files.Count -ne 4) {
    throw "Expected four required files to be checked."
}

if ($result.required_section_texts.Count -ne 8) {
    throw "Expected eight required section texts to be checked."
}

if (-not $result.operator_artifact_boundary) {
    throw "Expected operator-artifact boundary enforcement."
}

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r14-reporting-standard-" + [guid]::NewGuid().ToString("N"))
try {
    foreach ($relativePath in @(
        "governance\MILESTONE_REPORTING_STANDARD.md",
        "governance\KPI_DOMAIN_MODEL.md",
        "governance\templates\AIOffice_Milestone_Report_Template_v2.md",
        "governance\DOCUMENT_AUTHORITY_INDEX.md"
    )) {
        $sourcePath = Join-Path $repoRoot $relativePath
        $targetPath = Join-Path $tempRoot $relativePath
        New-Item -ItemType Directory -Path (Split-Path -Parent $targetPath) -Force | Out-Null
        Copy-Item -LiteralPath $sourcePath -Destination $targetPath -Force
    }

    Remove-Item -LiteralPath (Join-Path $tempRoot "governance\DOCUMENT_AUTHORITY_INDEX.md") -Force

    $failedAsExpected = $false
    try {
        & $validator -RepositoryRoot $tempRoot -PassThru | Out-Null
    }
    catch {
        if ($_.Exception.Message -like "*Required file missing*DOCUMENT_AUTHORITY_INDEX.md*") {
            $failedAsExpected = $true
        }
        else {
            throw
        }
    }

    if (-not $failedAsExpected) {
        throw "Validator accepted a fixture missing DOCUMENT_AUTHORITY_INDEX.md."
    }
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

Write-Output "PASS milestone reporting standard validation"
