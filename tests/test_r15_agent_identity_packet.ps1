$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R15AgentIdentityPacket.psm1") -Force -PassThru
$testPacket = $module.ExportedCommands["Test-R15AgentIdentityPacket"]

$taxonomyPath = Join-Path $repoRoot "state\knowledge\r15_artifact_classification_taxonomy.json"
$knowledgeIndexPath = Join-Path $repoRoot "state\knowledge\r15_repo_knowledge_index.json"
$contractPath = Join-Path $repoRoot "contracts\agents\agent_identity_packet.contract.json"
$validFixture = Join-Path $repoRoot "state\fixtures\valid\agents\r15_agent_identity_packet.valid.json"
$stateArtifact = Join-Path $repoRoot "state\agents\r15_agent_identity_packet.json"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\agents\r15_agent_identity_packet"

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
        $result = & $testPacket -PacketPath $validPath -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath
        Write-Output ("PASS valid agent identity packet set: {0} ({1} roles)" -f $validPath, $result.RoleCount)
        $validPassed += 1
    }

    Invoke-ExpectedRefusal -Label "missing-required-role" -RequiredFragments @("missing required role", "release_closeout_agent") -Action {
        & $testPacket -PacketPath (Join-Path $invalidRoot "missing-required-role.invalid.json") -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath | Out-Null
    }

    Invoke-ExpectedRefusal -Label "duplicate-agent-id" -RequiredFragments @("duplicate agent_id", "developer") -Action {
        & $testPacket -PacketPath (Join-Path $invalidRoot "duplicate-agent-id.invalid.json") -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-required-role-field" -RequiredFragments @("missing required field", "purpose") -Action {
        & $testPacket -PacketPath (Join-Path $invalidRoot "missing-required-role-field.invalid.json") -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath | Out-Null
    }

    Invoke-ExpectedRefusal -Label "unknown-handoff-target" -RequiredFragments @("handoff_targets target", "missing_agent") -Action {
        & $testPacket -PacketPath (Join-Path $invalidRoot "unknown-handoff-target.invalid.json") -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath | Out-Null
    }

    Invoke-ExpectedRefusal -Label "unknown-escalation-target" -RequiredFragments @("escalation_targets target", "missing_agent") -Action {
        & $testPacket -PacketPath (Join-Path $invalidRoot "unknown-escalation-target.invalid.json") -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath | Out-Null
    }

    Invoke-ExpectedRefusal -Label "pm-implementation-authority" -RequiredFragments @("Project Manager", "implementation or test execution") -Action {
        & $testPacket -PacketPath (Join-Path $invalidRoot "pm-implementation-authority.invalid.json") -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath | Out-Null
    }

    Invoke-ExpectedRefusal -Label "architect-final-architecture-decision" -RequiredFragments @("Architect", "final architecture decision") -Action {
        & $testPacket -PacketPath (Join-Path $invalidRoot "architect-final-architecture-decision.invalid.json") -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath | Out-Null
    }

    Invoke-ExpectedRefusal -Label "developer-qa-signoff-card-closure" -RequiredFragments @("Developer", "QA signoff or card closure") -Action {
        & $testPacket -PacketPath (Join-Path $invalidRoot "developer-qa-signoff-card-closure.invalid.json") -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath | Out-Null
    }

    Invoke-ExpectedRefusal -Label "qa-own-implementation-final-qa" -RequiredFragments @("QA", "own implementation") -Action {
        & $testPacket -PacketPath (Join-Path $invalidRoot "qa-own-implementation-final-qa.invalid.json") -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath | Out-Null
    }

    Invoke-ExpectedRefusal -Label "auditor-implementation-authority" -RequiredFragments @("Evidence Auditor", "implementation authority") -Action {
        & $testPacket -PacketPath (Join-Path $invalidRoot "auditor-implementation-authority.invalid.json") -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath | Out-Null
    }

    Invoke-ExpectedRefusal -Label "knowledge-curator-delete-without-approval" -RequiredFragments @("Knowledge Curator", "delete or deprecate") -Action {
        & $testPacket -PacketPath (Join-Path $invalidRoot "knowledge-curator-delete-without-approval.invalid.json") -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath | Out-Null
    }

    Invoke-ExpectedRefusal -Label "release-merge-without-approval" -RequiredFragments @("Release Agent", "merge or promote") -Action {
        & $testPacket -PacketPath (Join-Path $invalidRoot "release-merge-without-approval.invalid.json") -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath | Out-Null
    }

    Invoke-ExpectedRefusal -Label "impersonation-narration-allowed" -RequiredFragments @("fake multi-agent narration", "impersonation") -Action {
        & $testPacket -PacketPath (Join-Path $invalidRoot "impersonation-narration-allowed.invalid.json") -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath | Out-Null
    }

    Invoke-ExpectedRefusal -Label "runtime-true-multi-agent-overclaim" -RequiredFragments @("true_multi_agent_execution", "False") -Action {
        & $testPacket -PacketPath (Join-Path $invalidRoot "runtime-true-multi-agent-overclaim.invalid.json") -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath | Out-Null
    }

    Invoke-ExpectedRefusal -Label "persistent-memory-engine-overclaim" -RequiredFragments @("persistent_memory_engine", "False") -Action {
        & $testPacket -PacketPath (Join-Path $invalidRoot "persistent-memory-engine-overclaim.invalid.json") -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath | Out-Null
    }

    Invoke-ExpectedRefusal -Label "raci-matrix-implementation-overclaim" -RequiredFragments @("raci_matrix_implemented", "False") -Action {
        & $testPacket -PacketPath (Join-Path $invalidRoot "raci-matrix-implementation-overclaim.invalid.json") -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath | Out-Null
    }

    Invoke-ExpectedRefusal -Label "card-reentry-implementation-overclaim" -RequiredFragments @("card_reentry_packet_implemented", "False") -Action {
        & $testPacket -PacketPath (Join-Path $invalidRoot "card-reentry-implementation-overclaim.invalid.json") -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath | Out-Null
    }

    Invoke-ExpectedRefusal -Label "r16-opening-overclaim" -RequiredFragments @("overclaim", "R16 opening") -Action {
        & $testPacket -PacketPath (Join-Path $invalidRoot "r16-opening-overclaim.invalid.json") -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath | Out-Null
    }
}
catch {
    $failures += ("FAIL R15 agent identity packet harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R15 agent identity packet tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R15 agent identity packet tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
