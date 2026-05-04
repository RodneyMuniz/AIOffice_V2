$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R15CardReentryPacket.psm1") -Force -PassThru
$testPacket = $module.ExportedCommands["Test-R15CardReentryPacket"]

$taxonomyPath = Join-Path $repoRoot "state\knowledge\r15_artifact_classification_taxonomy.json"
$knowledgeIndexPath = Join-Path $repoRoot "state\knowledge\r15_repo_knowledge_index.json"
$agentIdentityPacketPath = Join-Path $repoRoot "state\agents\r15_agent_identity_packet.json"
$agentMemoryScopePath = Join-Path $repoRoot "state\agents\r15_agent_memory_scope.json"
$raciStateTransitionMatrixPath = Join-Path $repoRoot "state\agents\r15_raci_state_transition_matrix.json"
$contractPath = Join-Path $repoRoot "contracts\agents\card_reentry_packet.contract.json"
$validFixture = Join-Path $repoRoot "state\fixtures\valid\agents\r15_card_reentry_packet.valid.json"
$stateArtifact = Join-Path $repoRoot "state\agents\r15_card_reentry_packet.json"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\agents\r15_card_reentry_packet"

$validPassed = 0
$invalidRejected = 0
$failures = @()
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r15cardreentry" + [guid]::NewGuid().ToString("N").Substring(0, 8))

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

function Read-BaseModel {
    return Get-Content -LiteralPath $validFixture -Raw | ConvertFrom-Json
}

function Read-StateModel {
    return Get-Content -LiteralPath $stateArtifact -Raw | ConvertFrom-Json
}

function Write-TempModel {
    param(
        [Parameter(Mandatory = $true)]
        $Model,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $path = Join-Path $tempRoot ("{0}.json" -f $Name)
    $Model | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $path -Encoding UTF8
    return $path
}

function Invoke-PacketValidation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$RepositoryRoot = $repoRoot
    )

    & $testPacket -PacketPath $Path -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath -AgentIdentityPacketPath $agentIdentityPacketPath -AgentMemoryScopePath $agentMemoryScopePath -RaciStateTransitionMatrixPath $raciStateTransitionMatrixPath -RepositoryRoot $RepositoryRoot | Out-Null
}

function Get-PacketByAgent {
    param(
        [Parameter(Mandatory = $true)]
        $Model,
        [Parameter(Mandatory = $true)]
        [string]$AgentId
    )

    return @($Model.packet_records | Where-Object { $_.target_agent_id -eq $AgentId })[0]
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
        KanbanPath = Join-Path $Root "execution\KANBAN.md"
        R15AuthorityPath = Join-Path $Root "governance\R15_KNOWLEDGE_BASE_AGENT_IDENTITY_MEMORY_AND_RACI_FOUNDATIONS.md"
    }
}

try {
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

    foreach ($validPath in @($contractPath, $validFixture, $stateArtifact)) {
        $result = & $testPacket -PacketPath $validPath -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath -AgentIdentityPacketPath $agentIdentityPacketPath -AgentMemoryScopePath $agentMemoryScopePath -RaciStateTransitionMatrixPath $raciStateTransitionMatrixPath -RepositoryRoot $repoRoot
        Write-Output ("PASS valid R15 card re-entry packet model: {0} ({1} packet records)" -f $validPath, $result.PacketCount)
        $validPassed += 1
    }

    $invalidFixtures = @(
        @{ Label = "fixture-missing-required-packet-field"; Path = "missing-required-packet-field.invalid.json"; RequiredFragments = @("missing required field", "target_agent_id") },
        @{ Label = "fixture-duplicate-packet-id"; Path = "duplicate-packet-id.invalid.json"; RequiredFragments = @("duplicate packet_id") },
        @{ Label = "fixture-unknown-target-agent-id"; Path = "unknown-target-agent-id.invalid.json"; RequiredFragments = @("unknown target_agent_id") },
        @{ Label = "fixture-unknown-memory-scope-ref"; Path = "unknown-memory-scope-ref.invalid.json"; RequiredFragments = @("unknown memory_scope_ref") },
        @{ Label = "fixture-unknown-raci-transition-ref"; Path = "unknown-raci-transition-ref.invalid.json"; RequiredFragments = @("unknown raci_transition_ref") },
        @{ Label = "fixture-unbounded-full-repo-scan"; Path = "unbounded-full-repo-scan.invalid.json"; RequiredFragments = @("full repo scan") },
        @{ Label = "fixture-wildcard-allowed-path"; Path = "wildcard-allowed-path.invalid.json"; RequiredFragments = @("wildcard path") },
        @{ Label = "fixture-implicit-memory-loading"; Path = "implicit-memory-loading.invalid.json"; RequiredFragments = @("no_implicit_historical_memory", "true") },
        @{ Label = "fixture-persistent-memory-runtime-claim"; Path = "persistent-memory-runtime-claim.invalid.json"; RequiredFragments = @("persistent_memory_engine_implemented", "False") },
        @{ Label = "fixture-retrieval-engine-claim"; Path = "retrieval-engine-claim.invalid.json"; RequiredFragments = @("retrieval_engine_implemented", "False") },
        @{ Label = "fixture-vector-search-claim"; Path = "vector-search-claim.invalid.json"; RequiredFragments = @("vector_search_implemented", "False") },
        @{ Label = "fixture-external-board-sync-claim"; Path = "external-board-sync-claim.invalid.json"; RequiredFragments = @("external_board_sync_implemented", "False") },
        @{ Label = "fixture-board-routing-runtime-claim"; Path = "board-routing-runtime-claim.invalid.json"; RequiredFragments = @("board_routing_runtime_implemented", "False") },
        @{ Label = "fixture-card-reentry-runtime-claim"; Path = "card-reentry-runtime-claim.invalid.json"; RequiredFragments = @("card_reentry_runtime_implemented", "False") },
        @{ Label = "fixture-dry-run-executed-claim"; Path = "dry-run-executed-claim.invalid.json"; RequiredFragments = @("classification_reentry_dry_run_executed", "False") },
        @{ Label = "fixture-product-runtime-claim"; Path = "product-runtime-claim.invalid.json"; RequiredFragments = @("product_runtime_implemented", "False") },
        @{ Label = "fixture-r16-opening-claim"; Path = "r16-opening-claim.invalid.json"; RequiredFragments = @("r16_opened", "False") },
        @{ Label = "fixture-identity-forbidden-action-allowed"; Path = "identity-forbidden-action-allowed.invalid.json"; RequiredFragments = @("not allowed by R15-004 identity") },
        @{ Label = "fixture-memory-scope-prohibited-access"; Path = "memory-scope-prohibited-access.invalid.json"; RequiredFragments = @("not allowed memory scope", "historical_report_memory") },
        @{ Label = "fixture-raci-transition-state-violation"; Path = "raci-transition-state-violation.invalid.json"; RequiredFragments = @("violates R15-006 transition") },
        @{ Label = "fixture-developer-approves-qa"; Path = "developer-approves-qa.invalid.json"; RequiredFragments = @("developer packet cannot approve QA") },
        @{ Label = "fixture-qa-implements-code"; Path = "qa-implements-code.invalid.json"; RequiredFragments = @("QA packet cannot implement code") },
        @{ Label = "fixture-auditor-implements"; Path = "auditor-implements.invalid.json"; RequiredFragments = @("auditor packet cannot implement") },
        @{ Label = "fixture-pm-implements-code"; Path = "pm-implements-code.invalid.json"; RequiredFragments = @("PM packet cannot implement code") },
        @{ Label = "fixture-release-closeout-missing-user-approval"; Path = "release-closeout-missing-user-approval.invalid.json"; RequiredFragments = @("release_closeout_agent packet cannot close") }
    )

    foreach ($fixture in $invalidFixtures) {
        Invoke-ExpectedRefusal -Label $fixture.Label -RequiredFragments $fixture.RequiredFragments -Action {
            Invoke-PacketValidation -Path (Join-Path $invalidRoot $fixture.Path)
        }
    }

    Invoke-ExpectedRefusal -Label "missing-required-packet-field" -RequiredFragments @("missing required field", "target_agent_id") -Action {
        $model = Read-BaseModel
        $model.packet_records[0].PSObject.Properties.Remove("target_agent_id")
        Invoke-PacketValidation -Path (Write-TempModel -Model $model -Name "missing-required-packet-field")
    }

    Invoke-ExpectedRefusal -Label "duplicate-packet-id" -RequiredFragments @("duplicate packet_id") -Action {
        $model = Read-BaseModel
        $model.packet_records = @($model.packet_records) + @($model.packet_records[0])
        Invoke-PacketValidation -Path (Write-TempModel -Model $model -Name "duplicate-packet-id")
    }

    Invoke-ExpectedRefusal -Label "unknown-target-agent-id" -RequiredFragments @("unknown target_agent_id") -Action {
        $model = Read-BaseModel
        $model.packet_records[0].target_agent_id = "unknown_agent"
        Invoke-PacketValidation -Path (Write-TempModel -Model $model -Name "unknown-target-agent")
    }

    Invoke-ExpectedRefusal -Label "unknown-memory-scope-ref" -RequiredFragments @("unknown memory_scope_ref") -Action {
        $model = Read-BaseModel
        $model.packet_records[0].memory_scope_refs = @($model.packet_records[0].memory_scope_refs) + @("unknown_memory_scope")
        Invoke-PacketValidation -Path (Write-TempModel -Model $model -Name "unknown-memory-scope")
    }

    Invoke-ExpectedRefusal -Label "unknown-raci-transition-ref" -RequiredFragments @("unknown raci_transition_ref") -Action {
        $model = Read-BaseModel
        $model.packet_records[0].raci_transition_refs = @("unknown_transition")
        Invoke-PacketValidation -Path (Write-TempModel -Model $model -Name "unknown-raci-transition")
    }

    Invoke-ExpectedRefusal -Label "full-repo-scan-allowed-path" -RequiredFragments @("full repo scan") -Action {
        $model = Read-BaseModel
        $model.packet_records[0].allowed_canonical_paths = @($model.packet_records[0].allowed_canonical_paths) + @(".")
        Invoke-PacketValidation -Path (Write-TempModel -Model $model -Name "full-repo-path")
    }

    Invoke-ExpectedRefusal -Label "wildcard-allowed-path" -RequiredFragments @("wildcard path") -Action {
        $model = Read-BaseModel
        $model.packet_records[0].allowed_canonical_paths = @($model.packet_records[0].allowed_canonical_paths) + @("governance/*.md")
        Invoke-PacketValidation -Path (Write-TempModel -Model $model -Name "wildcard-path")
    }

    Invoke-ExpectedRefusal -Label "implicit-memory-loading" -RequiredFragments @("no_implicit_historical_memory", "true") -Action {
        $model = Read-BaseModel
        $model.packet_records[0].load_plan.no_implicit_historical_memory = $false
        Invoke-PacketValidation -Path (Write-TempModel -Model $model -Name "implicit-memory-loading")
    }

    Invoke-ExpectedRefusal -Label "persistent-memory-runtime-claim" -RequiredFragments @("persistent_memory_engine_implemented", "False") -Action {
        $model = Read-BaseModel
        $model.scope_boundary.persistent_memory_engine_implemented = $true
        Invoke-PacketValidation -Path (Write-TempModel -Model $model -Name "persistent-memory-claim")
    }

    Invoke-ExpectedRefusal -Label "retrieval-engine-claim" -RequiredFragments @("retrieval_engine_implemented", "False") -Action {
        $model = Read-BaseModel
        $model.scope_boundary.retrieval_engine_implemented = $true
        Invoke-PacketValidation -Path (Write-TempModel -Model $model -Name "retrieval-claim")
    }

    Invoke-ExpectedRefusal -Label "vector-search-claim" -RequiredFragments @("vector_search_implemented", "False") -Action {
        $model = Read-BaseModel
        $model.scope_boundary.vector_search_implemented = $true
        Invoke-PacketValidation -Path (Write-TempModel -Model $model -Name "vector-claim")
    }

    Invoke-ExpectedRefusal -Label "external-board-sync-claim" -RequiredFragments @("external_board_sync_implemented", "False") -Action {
        $model = Read-BaseModel
        $model.scope_boundary.external_board_sync_implemented = $true
        Invoke-PacketValidation -Path (Write-TempModel -Model $model -Name "external-board-sync")
    }

    Invoke-ExpectedRefusal -Label "board-routing-runtime-claim" -RequiredFragments @("board_routing_runtime_implemented", "False") -Action {
        $model = Read-BaseModel
        $model.scope_boundary.board_routing_runtime_implemented = $true
        Invoke-PacketValidation -Path (Write-TempModel -Model $model -Name "board-routing-runtime")
    }

    Invoke-ExpectedRefusal -Label "card-reentry-runtime-claim" -RequiredFragments @("card_reentry_runtime_implemented", "False") -Action {
        $model = Read-BaseModel
        $model.scope_boundary.card_reentry_runtime_implemented = $true
        Invoke-PacketValidation -Path (Write-TempModel -Model $model -Name "card-reentry-runtime")
    }

    Invoke-ExpectedRefusal -Label "dry-run-executed-claim" -RequiredFragments @("classification_reentry_dry_run_executed", "False") -Action {
        $model = Read-BaseModel
        $model.scope_boundary.classification_reentry_dry_run_executed = $true
        Invoke-PacketValidation -Path (Write-TempModel -Model $model -Name "dry-run-executed")
    }

    Invoke-ExpectedRefusal -Label "product-runtime-claim" -RequiredFragments @("product_runtime_implemented", "False") -Action {
        $model = Read-BaseModel
        $model.scope_boundary.product_runtime_implemented = $true
        Invoke-PacketValidation -Path (Write-TempModel -Model $model -Name "product-runtime")
    }

    Invoke-ExpectedRefusal -Label "r16-opening-claim" -RequiredFragments @("r16_opened", "False") -Action {
        $model = Read-BaseModel
        $model.scope_boundary.r16_opened = $true
        Invoke-PacketValidation -Path (Write-TempModel -Model $model -Name "r16-opening")
    }

    Invoke-ExpectedRefusal -Label "identity-forbidden-action-allowed" -RequiredFragments @("not allowed by R15-004 identity") -Action {
        $model = Read-BaseModel
        $model.packet_records[0].allowed_actions = @($model.packet_records[0].allowed_actions) + @("must not close cards or self-approve")
        Invoke-PacketValidation -Path (Write-TempModel -Model $model -Name "identity-forbidden-action")
    }

    Invoke-ExpectedRefusal -Label "memory-scope-prohibited-access" -RequiredFragments @("not allowed memory scope", "historical_report_memory") -Action {
        $model = Read-BaseModel
        $model.packet_records[0].memory_scope_refs = @($model.packet_records[0].memory_scope_refs) + @("historical_report_memory")
        Invoke-PacketValidation -Path (Write-TempModel -Model $model -Name "memory-scope-prohibited")
    }

    Invoke-ExpectedRefusal -Label "raci-transition-state-violation" -RequiredFragments @("violates R15-006 transition") -Action {
        $model = Read-BaseModel
        $model.packet_records[0].current_card_state = "qa_review"
        Invoke-PacketValidation -Path (Write-TempModel -Model $model -Name "raci-transition-state")
    }

    Invoke-ExpectedRefusal -Label "developer-approves-qa" -RequiredFragments @("developer packet cannot approve QA") -Action {
        $model = Read-BaseModel
        $model.packet_records[0].intended_next_state = "qa_passed"
        Invoke-PacketValidation -Path (Write-TempModel -Model $model -Name "developer-approves-qa")
    }

    Invoke-ExpectedRefusal -Label "qa-implements-code" -RequiredFragments @("QA packet cannot implement code") -Action {
        $model = Read-StateModel
        $packet = Get-PacketByAgent -Model $model -AgentId "qa_test_agent"
        $packet.allowed_actions = @($packet.allowed_actions) + @("implement scoped task packet")
        Invoke-PacketValidation -Path (Write-TempModel -Model $model -Name "qa-implements-code")
    }

    Invoke-ExpectedRefusal -Label "auditor-implements" -RequiredFragments @("auditor packet cannot implement") -Action {
        $model = Read-StateModel
        $packet = Get-PacketByAgent -Model $model -AgentId "evidence_auditor"
        $packet.allowed_actions = @($packet.allowed_actions) + @("implement scoped task packet")
        Invoke-PacketValidation -Path (Write-TempModel -Model $model -Name "auditor-implements")
    }

    Invoke-ExpectedRefusal -Label "pm-implements-code" -RequiredFragments @("PM packet cannot implement code") -Action {
        $model = Read-StateModel
        $packet = Get-PacketByAgent -Model $model -AgentId "project_manager"
        $packet.allowed_actions = @($packet.allowed_actions) + @("implement code")
        Invoke-PacketValidation -Path (Write-TempModel -Model $model -Name "pm-implements-code")
    }

    Invoke-ExpectedRefusal -Label "release-closeout-missing-user-approval" -RequiredFragments @("release_closeout_agent packet cannot close") -Action {
        $model = Read-StateModel
        $packet = Get-PacketByAgent -Model $model -AgentId "release_closeout_agent"
        $packet.approval_requirements.user_approval_required = $false
        Invoke-PacketValidation -Path (Write-TempModel -Model $model -Name "release-closeout-missing-user")
    }

    Invoke-ExpectedRefusal -Label "r15-008-complete-status" -RequiredFragments @("R15-008", "planned only") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r15-008-complete-status")
        foreach ($path in @($scenario.KanbanPath, $scenario.R15AuthorityPath)) {
            $text = Get-Content -LiteralPath $path -Raw
            $updatedText = [regex]::Replace($text, '(?m)(^### `R15-008` Run one classification and re-entry dry run\r?\n- Status: )planned', '${1}done', 1)
            if ($updatedText -eq $text) {
                throw "Expected R15-008 planned status was not found in '$path'."
            }
            Set-Content -LiteralPath $path -Value $updatedText -Encoding UTF8
        }
        Invoke-PacketValidation -Path $validFixture -RepositoryRoot $scenario.Root
    }
}
catch {
    $failures += ("FAIL R15 card re-entry packet harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R15 card re-entry packet tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R15 card re-entry packet tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
