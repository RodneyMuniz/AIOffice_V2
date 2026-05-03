$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R15ArtifactClassificationTaxonomy.psm1") -Force -PassThru
$testTaxonomy = $module.ExportedCommands["Test-R15ArtifactClassificationTaxonomy"]

$contractPath = Join-Path $repoRoot "contracts\knowledge\artifact_classification_taxonomy.contract.json"
$validFixture = Join-Path $repoRoot "state\fixtures\valid\knowledge\r15_artifact_classification_taxonomy.valid.json"
$stateArtifact = Join-Path $repoRoot "state\knowledge\r15_artifact_classification_taxonomy.json"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\knowledge\r15_artifact_classification_taxonomy"

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

try {
    foreach ($validPath in @($contractPath, $validFixture, $stateArtifact)) {
        $result = & $testTaxonomy -TaxonomyPath $validPath
        Write-Output ("PASS valid taxonomy: {0} ({1} classes, {2} evidence kinds)" -f $validPath, $result.ClassificationClassCount, $result.EvidenceKindCount)
        $validPassed += 1
    }

    Invoke-ExpectedRefusal -Label "missing-required-classification-class" -RequiredFragments @("missing required classification class", "external_evidence") -Action {
        & $testTaxonomy -TaxonomyPath (Join-Path $invalidRoot "missing-required-classification-class.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "duplicate-classification-class" -RequiredFragments @("duplicates", "contract") -Action {
        & $testTaxonomy -TaxonomyPath (Join-Path $invalidRoot "duplicate-classification-class.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-required-evidence-kind" -RequiredFragments @("missing required evidence kind", "test_result") -Action {
        & $testTaxonomy -TaxonomyPath (Join-Path $invalidRoot "missing-required-evidence-kind.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-required-authority-kind" -RequiredFragments @("missing required authority kind", "proof_authority") -Action {
        & $testTaxonomy -TaxonomyPath (Join-Path $invalidRoot "missing-required-authority-kind.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-required-lifecycle-state" -RequiredFragments @("missing required lifecycle state", "superseded") -Action {
        & $testTaxonomy -TaxonomyPath (Join-Path $invalidRoot "missing-required-lifecycle-state.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-required-proof-status" -RequiredFragments @("missing required proof status", "operator_artifact_only") -Action {
        & $testTaxonomy -TaxonomyPath (Join-Path $invalidRoot "missing-required-proof-status.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "generated-operator-artifact-proof-by-itself" -RequiredFragments @("generated_operator_artifact", "proof by itself") -Action {
        & $testTaxonomy -TaxonomyPath (Join-Path $invalidRoot "generated-operator-artifact-proof-by-itself.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "unknown-classification-without-reason" -RequiredFragments @("reason", "must be a non-empty string") -Action {
        & $testTaxonomy -TaxonomyPath (Join-Path $invalidRoot "unknown-classification-without-reason.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "runtime-and-integration-overclaim" -RequiredFragments @("overclaim", "product runtime") -Action {
        & $testTaxonomy -TaxonomyPath (Join-Path $invalidRoot "runtime-and-integration-overclaim.invalid.json") | Out-Null
    }
}
catch {
    $failures += ("FAIL R15 artifact classification taxonomy harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R15 artifact classification taxonomy tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R15 artifact classification taxonomy tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
