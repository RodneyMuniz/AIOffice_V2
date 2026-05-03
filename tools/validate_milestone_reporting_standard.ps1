[CmdletBinding()]
param(
    [string]$RepositoryRoot,
    [switch]$PassThru
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

$resolvedRoot = (Resolve-Path -LiteralPath $RepositoryRoot).Path

$requiredFiles = @(
    "governance\MILESTONE_REPORTING_STANDARD.md",
    "governance\KPI_DOMAIN_MODEL.md",
    "governance\templates\AIOffice_Milestone_Report_Template_v2.md",
    "governance\DOCUMENT_AUTHORITY_INDEX.md"
)

$resolvedFiles = @()
foreach ($relativePath in $requiredFiles) {
    $path = Join-Path $resolvedRoot $relativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required file missing: $relativePath"
    }

    $resolvedFiles += [pscustomobject]@{
        path = $relativePath
        exists = $true
    }
}

$standardPath = Join-Path $resolvedRoot "governance\MILESTONE_REPORTING_STANDARD.md"
$templatePath = Join-Path $resolvedRoot "governance\templates\AIOffice_Milestone_Report_Template_v2.md"
$authorityIndexPath = Join-Path $resolvedRoot "governance\DOCUMENT_AUTHORITY_INDEX.md"

$standardText = Get-Content -LiteralPath $standardPath -Raw
$templateText = Get-Content -LiteralPath $templatePath -Raw
$authorityIndexText = Get-Content -LiteralPath $authorityIndexPath -Raw
$combinedText = [string]::Join([Environment]::NewLine, @($standardText, $templateText, $authorityIndexText))

$requiredSectionTexts = @(
    "TL;DR",
    "What changed since last report",
    "Executive KPI scorecard",
    "Domain drill-down",
    "RACI / role enforcement",
    "Evidence appendix",
    "Non-claims",
    "Rejected claims"
)

foreach ($sectionText in $requiredSectionTexts) {
    if ($combinedText.IndexOf($sectionText, [System.StringComparison]::OrdinalIgnoreCase) -lt 0) {
        throw "Required milestone reporting section text missing: $sectionText"
    }
}

$operatorArtifactBoundaries = @(
    "Reports are operator artifacts",
    "not proof by themselves",
    "Generated Markdown/reports",
    "operator artifacts unless backed by committed machine evidence"
)

foreach ($boundaryText in $operatorArtifactBoundaries) {
    if ($combinedText.IndexOf($boundaryText, [System.StringComparison]::OrdinalIgnoreCase) -lt 0) {
        throw "Milestone reporting standard cannot distinguish operator artifacts from machine evidence; missing: $boundaryText"
    }
}

$result = [pscustomobject]@{
    verdict = "passed"
    required_files = $resolvedFiles
    required_section_texts = $requiredSectionTexts
    operator_artifact_boundary = $true
}

if ($PassThru) {
    return $result
}

Write-Output ("VALID: milestone reporting standard exists with {0} required files, {1} required section texts, and explicit operator-artifact versus machine-evidence boundaries." -f $requiredFiles.Count, $requiredSectionTexts.Count)
