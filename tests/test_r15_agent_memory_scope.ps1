$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R15AgentMemoryScope.psm1") -Force -PassThru
$testScope = $module.ExportedCommands["Test-R15AgentMemoryScope"]

$taxonomyPath = Join-Path $repoRoot "state\knowledge\r15_artifact_classification_taxonomy.json"
$knowledgeIndexPath = Join-Path $repoRoot "state\knowledge\r15_repo_knowledge_index.json"
$agentIdentityPacketPath = Join-Path $repoRoot "state\agents\r15_agent_identity_packet.json"
$contractPath = Join-Path $repoRoot "contracts\agents\agent_memory_scope.contract.json"
$validFixture = Join-Path $repoRoot "state\fixtures\valid\agents\r15_agent_memory_scope.valid.json"
$stateArtifact = Join-Path $repoRoot "state\agents\r15_agent_memory_scope.json"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\agents\r15_agent_memory_scope"

$validPassed = 0
$invalidRejected = 0
$failures = @()
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r15memoryscope" + [guid]::NewGuid().ToString("N").Substring(0, 8))

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
        KanbanPath = Join-Path $Root "execution\KANBAN.md"
        R15AuthorityPath = Join-Path $Root "governance\R15_KNOWLEDGE_BASE_AGENT_IDENTITY_MEMORY_AND_RACI_FOUNDATIONS.md"
    }
}

function Replace-FileText {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$OldValue,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$NewValue
    )

    $text = Get-Content -LiteralPath $Path -Raw
    if ($text.IndexOf($OldValue, [System.StringComparison]::Ordinal) -lt 0) {
        throw "Expected text was not found in '$Path'."
    }

    Set-Content -LiteralPath $Path -Value ($text.Replace($OldValue, $NewValue)) -Encoding UTF8
}

try {
    foreach ($validPath in @($contractPath, $validFixture, $stateArtifact)) {
        $result = & $testScope -ScopePath $validPath -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath -AgentIdentityPacketPath $agentIdentityPacketPath -RepositoryRoot $repoRoot
        Write-Output ("PASS valid agent memory scope model: {0} ({1} scopes, {2} role mappings)" -f $validPath, $result.ScopeCount, $result.RoleAccessCount)
        $validPassed += 1
    }

    Invoke-ExpectedRefusal -Label "missing-required-scope" -RequiredFragments @("missing required memory scope", "deprecated_cleanup_candidate_memory") -Action {
        & $testScope -ScopePath (Join-Path $invalidRoot "missing-required-scope.invalid.json") -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath -AgentIdentityPacketPath $agentIdentityPacketPath -RepositoryRoot $repoRoot | Out-Null
    }

    Invoke-ExpectedRefusal -Label "duplicate-scope-id" -RequiredFragments @("duplicate scope_id", "evidence_memory") -Action {
        & $testScope -ScopePath (Join-Path $invalidRoot "duplicate-scope-id.invalid.json") -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath -AgentIdentityPacketPath $agentIdentityPacketPath -RepositoryRoot $repoRoot | Out-Null
    }

    Invoke-ExpectedRefusal -Label "scope-full-repo-scan" -RequiredFragments @("full repo scan", "load_mode") -Action {
        & $testScope -ScopePath (Join-Path $invalidRoot "scope-full-repo-scan.invalid.json") -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath -AgentIdentityPacketPath $agentIdentityPacketPath -RepositoryRoot $repoRoot | Out-Null
    }

    Invoke-ExpectedRefusal -Label "scope-broad-canonical-path" -RequiredFragments @("full repo scan", "canonical_paths") -Action {
        & $testScope -ScopePath (Join-Path $invalidRoot "scope-broad-canonical-path.invalid.json") -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath -AgentIdentityPacketPath $agentIdentityPacketPath -RepositoryRoot $repoRoot | Out-Null
    }

    Invoke-ExpectedRefusal -Label "role-load-all-memory-without-bounded-refs" -RequiredFragments @("load all memory", "bounded refs") -Action {
        & $testScope -ScopePath (Join-Path $invalidRoot "role-load-all-memory-without-bounded-refs.invalid.json") -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath -AgentIdentityPacketPath $agentIdentityPacketPath -RepositoryRoot $repoRoot | Out-Null
    }

    Invoke-ExpectedRefusal -Label "runtime-memory-loading-overclaim" -RequiredFragments @("runtime_memory_loading_implemented", "False") -Action {
        & $testScope -ScopePath (Join-Path $invalidRoot "runtime-memory-loading-overclaim.invalid.json") -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath -AgentIdentityPacketPath $agentIdentityPacketPath -RepositoryRoot $repoRoot | Out-Null
    }

    Invoke-ExpectedRefusal -Label "persistent-memory-engine-overclaim" -RequiredFragments @("persistent_memory_engine_implemented", "False") -Action {
        & $testScope -ScopePath (Join-Path $invalidRoot "persistent-memory-engine-overclaim.invalid.json") -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath -AgentIdentityPacketPath $agentIdentityPacketPath -RepositoryRoot $repoRoot | Out-Null
    }

    Invoke-ExpectedRefusal -Label "retrieval-engine-overclaim" -RequiredFragments @("retrieval_engine_implemented", "False") -Action {
        & $testScope -ScopePath (Join-Path $invalidRoot "retrieval-engine-overclaim.invalid.json") -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath -AgentIdentityPacketPath $agentIdentityPacketPath -RepositoryRoot $repoRoot | Out-Null
    }

    Invoke-ExpectedRefusal -Label "vector-search-overclaim" -RequiredFragments @("vector_search_implemented", "False") -Action {
        & $testScope -ScopePath (Join-Path $invalidRoot "vector-search-overclaim.invalid.json") -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath -AgentIdentityPacketPath $agentIdentityPacketPath -RepositoryRoot $repoRoot | Out-Null
    }

    Invoke-ExpectedRefusal -Label "direct-agent-runtime-overclaim" -RequiredFragments @("direct_agent_access_runtime", "False") -Action {
        & $testScope -ScopePath (Join-Path $invalidRoot "direct-agent-runtime-overclaim.invalid.json") -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath -AgentIdentityPacketPath $agentIdentityPacketPath -RepositoryRoot $repoRoot | Out-Null
    }

    Invoke-ExpectedRefusal -Label "raci-matrix-overclaim" -RequiredFragments @("raci_matrix_implemented", "False") -Action {
        & $testScope -ScopePath (Join-Path $invalidRoot "raci-matrix-overclaim.invalid.json") -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath -AgentIdentityPacketPath $agentIdentityPacketPath -RepositoryRoot $repoRoot | Out-Null
    }

    Invoke-ExpectedRefusal -Label "card-reentry-overclaim" -RequiredFragments @("card_reentry_packet_implemented", "False") -Action {
        & $testScope -ScopePath (Join-Path $invalidRoot "card-reentry-overclaim.invalid.json") -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath -AgentIdentityPacketPath $agentIdentityPacketPath -RepositoryRoot $repoRoot | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r16-opening-overclaim" -RequiredFragments @("r16_opened", "False") -Action {
        & $testScope -ScopePath (Join-Path $invalidRoot "r16-opening-overclaim.invalid.json") -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath -AgentIdentityPacketPath $agentIdentityPacketPath -RepositoryRoot $repoRoot | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r15-009-complete-status" -RequiredFragments @("R15-009", "planned only") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r15-009-complete-status")
        foreach ($path in @($scenario.KanbanPath, $scenario.R15AuthorityPath)) {
            $text = Get-Content -LiteralPath $path -Raw
            $updatedText = [regex]::Replace($text, '(?m)(^### `R15-009` Produce R15 proof/review package\r?\n- Status: )planned', '${1}done', 1)
            if ($updatedText -eq $text) {
                throw "Expected R15-009 planned status was not found in '$path'."
            }
            Set-Content -LiteralPath $path -Value $updatedText -Encoding UTF8
        }
        & $testScope -ScopePath $validFixture -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath -AgentIdentityPacketPath $agentIdentityPacketPath -RepositoryRoot $scenario.Root | Out-Null
    }
}
catch {
    $failures += ("FAIL R15 agent memory scope harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R15 agent memory scope tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R15 agent memory scope tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
