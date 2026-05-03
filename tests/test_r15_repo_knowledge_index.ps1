$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R15RepoKnowledgeIndex.psm1") -Force -PassThru
$testIndex = $module.ExportedCommands["Test-R15RepoKnowledgeIndex"]

$taxonomyPath = Join-Path $repoRoot "state\knowledge\r15_artifact_classification_taxonomy.json"
$contractPath = Join-Path $repoRoot "contracts\knowledge\repo_knowledge_index.contract.json"
$validFixture = Join-Path $repoRoot "state\fixtures\valid\knowledge\r15_repo_knowledge_index.valid.json"
$stateArtifact = Join-Path $repoRoot "state\knowledge\r15_repo_knowledge_index.json"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\knowledge\r15_repo_knowledge_index"

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
        $result = & $testIndex -IndexPath $validPath -TaxonomyPath $taxonomyPath
        Write-Output ("PASS valid repo knowledge index: {0} ({1} entries)" -f $validPath, $result.EntryCount)
        $validPassed += 1
    }

    Invoke-ExpectedRefusal -Label "missing-taxonomy-ref" -RequiredFragments @("missing required field", "taxonomy_ref") -Action {
        & $testIndex -IndexPath (Join-Path $invalidRoot "missing-taxonomy-ref.invalid.json") -TaxonomyPath $taxonomyPath | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-required-entry-field" -RequiredFragments @("missing required field", "summary") -Action {
        & $testIndex -IndexPath (Join-Path $invalidRoot "missing-required-entry-field.invalid.json") -TaxonomyPath $taxonomyPath | Out-Null
    }

    Invoke-ExpectedRefusal -Label "unknown-classification-without-reason" -RequiredFragments @("reason", "non-empty") -Action {
        & $testIndex -IndexPath (Join-Path $invalidRoot "unknown-classification-without-reason.invalid.json") -TaxonomyPath $taxonomyPath | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-evidence-kind" -RequiredFragments @("unknown evidence kind", "invalid_evidence_kind") -Action {
        & $testIndex -IndexPath (Join-Path $invalidRoot "invalid-evidence-kind.invalid.json") -TaxonomyPath $taxonomyPath | Out-Null
    }

    Invoke-ExpectedRefusal -Label "duplicate-entry-id" -RequiredFragments @("duplicate entry_id", "governance_vision") -Action {
        & $testIndex -IndexPath (Join-Path $invalidRoot "duplicate-entry-id.invalid.json") -TaxonomyPath $taxonomyPath | Out-Null
    }

    Invoke-ExpectedRefusal -Label "duplicate-path-without-duplicate-reason" -RequiredFragments @("duplicate path", "duplicate_reason") -Action {
        & $testIndex -IndexPath (Join-Path $invalidRoot "duplicate-path-without-duplicate-reason.invalid.json") -TaxonomyPath $taxonomyPath | Out-Null
    }

    Invoke-ExpectedRefusal -Label "unknown-internal-relationship" -RequiredFragments @("relationship reference", "missing_internal_entry") -Action {
        & $testIndex -IndexPath (Join-Path $invalidRoot "unknown-internal-relationship.invalid.json") -TaxonomyPath $taxonomyPath | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-load-priority" -RequiredFragments @("invalid load_priority", "0_immediate") -Action {
        & $testIndex -IndexPath (Join-Path $invalidRoot "invalid-load-priority.invalid.json") -TaxonomyPath $taxonomyPath | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-scan-scope" -RequiredFragments @("invalid scan_scope", "full_repo") -Action {
        & $testIndex -IndexPath (Join-Path $invalidRoot "invalid-scan-scope.invalid.json") -TaxonomyPath $taxonomyPath | Out-Null
    }

    Invoke-ExpectedRefusal -Label "full-repo-scan-claim" -RequiredFragments @("full repo index", "prohibited") -Action {
        & $testIndex -IndexPath (Join-Path $invalidRoot "full-repo-scan-claim.invalid.json") -TaxonomyPath $taxonomyPath | Out-Null
    }

    Invoke-ExpectedRefusal -Label "generated-report-proof-by-itself" -RequiredFragments @("report", "proof by itself") -Action {
        & $testIndex -IndexPath (Join-Path $invalidRoot "generated-report-proof-by-itself.invalid.json") -TaxonomyPath $taxonomyPath | Out-Null
    }

    $overclaimFixtures = @(
        @{ Label = "product-runtime-overclaim"; File = "product-runtime-overclaim.invalid.json"; Pattern = "product runtime" },
        @{ Label = "board-runtime-overclaim"; File = "board-runtime-overclaim.invalid.json"; Pattern = "board runtime" },
        @{ Label = "external-board-sync-overclaim"; File = "external-board-sync-overclaim.invalid.json"; Pattern = "external board sync" },
        @{ Label = "linear-implementation-overclaim"; File = "linear-implementation-overclaim.invalid.json"; Pattern = "Linear implementation" },
        @{ Label = "symphony-implementation-overclaim"; File = "symphony-implementation-overclaim.invalid.json"; Pattern = "Symphony implementation" },
        @{ Label = "github-projects-implementation-overclaim"; File = "github-projects-implementation-overclaim.invalid.json"; Pattern = "GitHub Projects implementation" },
        @{ Label = "custom-board-implementation-overclaim"; File = "custom-board-implementation-overclaim.invalid.json"; Pattern = "custom board implementation" },
        @{ Label = "true-multi-agent-execution-overclaim"; File = "true-multi-agent-execution-overclaim.invalid.json"; Pattern = "true multi-agent execution" },
        @{ Label = "persistent-memory-engine-overclaim"; File = "persistent-memory-engine-overclaim.invalid.json"; Pattern = "persistent memory engine" },
        @{ Label = "solved-codex-compaction-overclaim"; File = "solved-codex-compaction-overclaim.invalid.json"; Pattern = "solved Codex compaction" },
        @{ Label = "solved-codex-reliability-overclaim"; File = "solved-codex-reliability-overclaim.invalid.json"; Pattern = "solved Codex reliability" },
        @{ Label = "r16-opening-overclaim"; File = "r16-opening-overclaim.invalid.json"; Pattern = "R16 opening" }
    )

    foreach ($fixture in $overclaimFixtures) {
        Invoke-ExpectedRefusal -Label $fixture.Label -RequiredFragments @("overclaim", $fixture.Pattern) -Action {
            & $testIndex -IndexPath (Join-Path $invalidRoot $fixture.File) -TaxonomyPath $taxonomyPath | Out-Null
        }
    }
}
catch {
    $failures += ("FAIL R15 repo knowledge index harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R15 repo knowledge index tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R15 repo knowledge index tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
