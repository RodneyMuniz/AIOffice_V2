$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R15ClassificationReentryDryRun.psm1") -Force -PassThru
$testDryRun = $module.ExportedCommands["Test-R15ClassificationReentryDryRun"]

$taxonomyPath = Join-Path $repoRoot "state\knowledge\r15_artifact_classification_taxonomy.json"
$knowledgeIndexPath = Join-Path $repoRoot "state\knowledge\r15_repo_knowledge_index.json"
$agentIdentityPacketPath = Join-Path $repoRoot "state\agents\r15_agent_identity_packet.json"
$agentMemoryScopePath = Join-Path $repoRoot "state\agents\r15_agent_memory_scope.json"
$raciStateTransitionMatrixPath = Join-Path $repoRoot "state\agents\r15_raci_state_transition_matrix.json"
$cardReentryPacketPath = Join-Path $repoRoot "state\agents\r15_card_reentry_packet.json"
$contractPath = Join-Path $repoRoot "contracts\agents\classification_reentry_dry_run.contract.json"
$validFixture = Join-Path $repoRoot "state\fixtures\valid\agents\r15_classification_reentry_dry_run.valid.json"
$stateArtifact = Join-Path $repoRoot "state\agents\r15_classification_reentry_dry_run.json"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\agents\r15_classification_reentry_dry_run"

$validPassed = 0
$invalidRejected = 0
$failures = @()
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r15classreentry" + [guid]::NewGuid().ToString("N").Substring(0, 8))

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

function Invoke-DryRunValidation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$RepositoryRoot = $repoRoot
    )

    & $testDryRun -DryRunPath $Path -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath -AgentIdentityPacketPath $agentIdentityPacketPath -AgentMemoryScopePath $agentMemoryScopePath -RaciStateTransitionMatrixPath $raciStateTransitionMatrixPath -CardReentryPacketPath $cardReentryPacketPath -RepositoryRoot $RepositoryRoot | Out-Null
}

function New-StatusDocHarness {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root
    )

    $paths = @(
        "README.md",
        "governance\ACTIVE_STATE.md",
        "execution\KANBAN.md",
        "governance\DECISION_LOG.md",
        "governance\DOCUMENT_AUTHORITY_INDEX.md",
        "governance\R15_KNOWLEDGE_BASE_AGENT_IDENTITY_MEMORY_AND_RACI_FOUNDATIONS.md"
    )

    foreach ($relativePath in $paths) {
        $sourcePath = Join-Path $repoRoot $relativePath
        $targetPath = Join-Path $Root $relativePath
        $targetDirectory = Split-Path -Parent $targetPath
        New-Item -ItemType Directory -Path $targetDirectory -Force | Out-Null
        Copy-Item -LiteralPath $sourcePath -Destination $targetPath -Force
    }

    return [pscustomobject]@{
        Root = $Root
        ReadmePath = Join-Path $Root "README.md"
        ActiveStatePath = Join-Path $Root "governance\ACTIVE_STATE.md"
        KanbanPath = Join-Path $Root "execution\KANBAN.md"
        DecisionLogPath = Join-Path $Root "governance\DECISION_LOG.md"
        R15AuthorityPath = Join-Path $Root "governance\R15_KNOWLEDGE_BASE_AGENT_IDENTITY_MEMORY_AND_RACI_FOUNDATIONS.md"
    }
}

try {
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

    foreach ($validPath in @($contractPath, $validFixture, $stateArtifact)) {
        $result = & $testDryRun -DryRunPath $validPath -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath -AgentIdentityPacketPath $agentIdentityPacketPath -AgentMemoryScopePath $agentMemoryScopePath -RaciStateTransitionMatrixPath $raciStateTransitionMatrixPath -CardReentryPacketPath $cardReentryPacketPath -RepositoryRoot $repoRoot
        Write-Output ("PASS valid R15 classification/re-entry dry run: {0} ({1} target paths, {2} lookups, verdict {3})" -f $validPath, $result.TargetSlicePathCount, $result.LookupCount, $result.AggregateVerdict)
        $validPassed += 1
    }

    $invalidFixtures = @(
        @{ Label = "missing-target-slice-path"; Path = "missing-target-slice-path.invalid.json"; RequiredFragments = @("missing required target slice path") },
        @{ Label = "full-repo-scan-claim"; Path = "full-repo-scan-claim.invalid.json"; RequiredFragments = @("full_repo_scan_executed", "False") },
        @{ Label = "wildcard-path"; Path = "wildcard-path.invalid.json"; RequiredFragments = @("broad repo-root or wildcard path") },
        @{ Label = "unknown-artifact-class"; Path = "unknown-artifact-class.invalid.json"; RequiredFragments = @("unknown artifact classification") },
        @{ Label = "unknown-index-entry"; Path = "unknown-index-entry.invalid.json"; RequiredFragments = @("unknown knowledge index entry") },
        @{ Label = "unknown-target-agent"; Path = "unknown-target-agent.invalid.json"; RequiredFragments = @("target_agent_id", "evidence_auditor") },
        @{ Label = "unknown-memory-scope"; Path = "unknown-memory-scope.invalid.json"; RequiredFragments = @("unknown memory scope") },
        @{ Label = "unknown-raci-transition"; Path = "unknown-raci-transition.invalid.json"; RequiredFragments = @("unknown RACI transition") },
        @{ Label = "missing-reentry-packet"; Path = "missing-reentry-packet.invalid.json"; RequiredFragments = @("missing required field", "packet_output") },
        @{ Label = "runtime-agent-claim"; Path = "runtime-agent-claim.invalid.json"; RequiredFragments = @("runtime_agents_implemented", "False") },
        @{ Label = "card-reentry-runtime-claim"; Path = "card-reentry-runtime-claim.invalid.json"; RequiredFragments = @("card_reentry_runtime_implemented", "False") },
        @{ Label = "board-routing-runtime-claim"; Path = "board-routing-runtime-claim.invalid.json"; RequiredFragments = @("board_routing_runtime_implemented", "False") },
        @{ Label = "workflow-execution-claim"; Path = "workflow-execution-claim.invalid.json"; RequiredFragments = @("workflow_execution_implemented", "False") },
        @{ Label = "product-runtime-claim"; Path = "product-runtime-claim.invalid.json"; RequiredFragments = @("product_runtime_implemented", "False") },
        @{ Label = "final-proof-package-claim"; Path = "final-proof-package-claim.invalid.json"; RequiredFragments = @("final_r15_proof_package_complete", "False") },
        @{ Label = "r16-opened-claim"; Path = "r16-opened-claim.invalid.json"; RequiredFragments = @("r16_opened", "False") },
        @{ Label = "runtime-distinction-missing"; Path = "runtime-distinction-missing.invalid.json"; RequiredFragments = @("must not claim runtime execution") }
    )

    foreach ($fixture in $invalidFixtures) {
        Invoke-ExpectedRefusal -Label $fixture.Label -RequiredFragments $fixture.RequiredFragments -Action {
            Invoke-DryRunValidation -Path (Join-Path $invalidRoot $fixture.Path)
        }
    }

    Invoke-ExpectedRefusal -Label "r15-010-successor-status" -RequiredFragments @("R15 implementation beyond R15-009") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r15-010-successor-status")
        Add-Content -LiteralPath $scenario.R15AuthorityPath -Value ("`r`nR15-010 successor task is planned.") -Encoding UTF8
        Invoke-DryRunValidation -Path $validFixture -RepositoryRoot $scenario.Root
    }

    Invoke-ExpectedRefusal -Label "status-runtime-overclaim" -RequiredFragments @("runtime or integration overclaim") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-runtime-overclaim")
        Add-Content -LiteralPath $scenario.ReadmePath -Value ("`r`nR15-008 implemented card re-entry runtime and board routing runtime.") -Encoding UTF8
        Invoke-DryRunValidation -Path $validFixture -RepositoryRoot $scenario.Root
    }
}
catch {
    $failures += ("FAIL R15 classification/re-entry dry-run harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R15 classification/re-entry dry-run tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R15 classification/re-entry dry-run tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
