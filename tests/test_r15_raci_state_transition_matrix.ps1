$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R15RaciStateTransitionMatrix.psm1") -Force -PassThru
$testMatrix = $module.ExportedCommands["Test-R15RaciStateTransitionMatrix"]

$taxonomyPath = Join-Path $repoRoot "state\knowledge\r15_artifact_classification_taxonomy.json"
$knowledgeIndexPath = Join-Path $repoRoot "state\knowledge\r15_repo_knowledge_index.json"
$agentIdentityPacketPath = Join-Path $repoRoot "state\agents\r15_agent_identity_packet.json"
$agentMemoryScopePath = Join-Path $repoRoot "state\agents\r15_agent_memory_scope.json"
$contractPath = Join-Path $repoRoot "contracts\agents\raci_state_transition_matrix.contract.json"
$validFixture = Join-Path $repoRoot "state\fixtures\valid\agents\r15_raci_state_transition_matrix.valid.json"
$stateArtifact = Join-Path $repoRoot "state\agents\r15_raci_state_transition_matrix.json"

$validPassed = 0
$invalidRejected = 0
$failures = @()
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r15racimatrix" + [guid]::NewGuid().ToString("N").Substring(0, 8))

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

function Invoke-MatrixValidation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$RepositoryRoot = $repoRoot
    )

    & $testMatrix -MatrixPath $Path -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath -AgentIdentityPacketPath $agentIdentityPacketPath -AgentMemoryScopePath $agentMemoryScopePath -RepositoryRoot $RepositoryRoot | Out-Null
}

function Get-Transition {
    param(
        [Parameter(Mandatory = $true)]
        $Model,
        [Parameter(Mandatory = $true)]
        [string]$TransitionId
    )

    return @($Model.transition_matrix | Where-Object { $_.transition_id -eq $TransitionId })[0]
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
        $result = & $testMatrix -MatrixPath $validPath -TaxonomyPath $taxonomyPath -KnowledgeIndexPath $knowledgeIndexPath -AgentIdentityPacketPath $agentIdentityPacketPath -AgentMemoryScopePath $agentMemoryScopePath -RepositoryRoot $repoRoot
        Write-Output ("PASS valid R15 RACI state-transition matrix: {0} ({1} states, {2} transitions)" -f $validPath, $result.StateCount, $result.TransitionCount)
        $validPassed += 1
    }

    Invoke-ExpectedRefusal -Label "missing-required-state" -RequiredFragments @("missing required state", "closed") -Action {
        $model = Read-BaseModel
        $model.state_model = @($model.state_model | Where-Object { $_.state_id -ne "closed" })
        Invoke-MatrixValidation -Path (Write-TempModel -Model $model -Name "missing-required-state")
    }

    Invoke-ExpectedRefusal -Label "duplicate-state" -RequiredFragments @("duplicate state_id", "intake") -Action {
        $model = Read-BaseModel
        $model.state_model = @($model.state_model) + @($model.state_model[0])
        Invoke-MatrixValidation -Path (Write-TempModel -Model $model -Name "duplicate-state")
    }

    Invoke-ExpectedRefusal -Label "missing-required-transition" -RequiredFragments @("missing required transition", "qa_review_to_qa_passed") -Action {
        $model = Read-BaseModel
        $model.transition_matrix = @($model.transition_matrix | Where-Object { $_.transition_id -ne "qa_review_to_qa_passed" })
        Invoke-MatrixValidation -Path (Write-TempModel -Model $model -Name "missing-required-transition")
    }

    Invoke-ExpectedRefusal -Label "duplicate-transition-id" -RequiredFragments @("duplicate transition_id", "intake_to_refinement") -Action {
        $model = Read-BaseModel
        $model.transition_matrix = @($model.transition_matrix) + @($model.transition_matrix[0])
        Invoke-MatrixValidation -Path (Write-TempModel -Model $model -Name "duplicate-transition-id")
    }

    Invoke-ExpectedRefusal -Label "transition-to-closed-without-user-approval" -RequiredFragments @("cannot transition to closed", "user approval") -Action {
        $model = Read-BaseModel
        $transition = Get-Transition -Model $model -TransitionId "approved_for_closeout_to_closed"
        $transition.requires_user_approval = $false
        Invoke-MatrixValidation -Path (Write-TempModel -Model $model -Name "closed-without-user-approval")
    }

    Invoke-ExpectedRefusal -Label "developer-accountable-for-qa-pass" -RequiredFragments @("developer", "accountable for QA pass") -Action {
        $model = Read-BaseModel
        $transition = Get-Transition -Model $model -TransitionId "qa_review_to_qa_passed"
        $transition.accountable_agent_id = "developer"
        Invoke-MatrixValidation -Path (Write-TempModel -Model $model -Name "developer-accountable-qa-pass")
    }

    Invoke-ExpectedRefusal -Label "qa-as-implementer-for-final-qa-scope" -RequiredFragments @("qa_test_agent", "implementation executor") -Action {
        $model = Read-BaseModel
        $transition = Get-Transition -Model $model -TransitionId "ready_to_in_progress"
        $transition.allowed_executors = @($transition.allowed_executors) + @("qa_test_agent")
        Invoke-MatrixValidation -Path (Write-TempModel -Model $model -Name "qa-as-implementer")
    }

    Invoke-ExpectedRefusal -Label "auditor-as-implementer" -RequiredFragments @("evidence_auditor", "implementation executor") -Action {
        $model = Read-BaseModel
        $transition = Get-Transition -Model $model -TransitionId "in_progress_to_implementation_complete"
        $transition.allowed_executors = @($transition.allowed_executors) + @("evidence_auditor")
        Invoke-MatrixValidation -Path (Write-TempModel -Model $model -Name "auditor-as-implementer")
    }

    Invoke-ExpectedRefusal -Label "pm-as-code-implementer" -RequiredFragments @("project_manager", "implementation executor") -Action {
        $model = Read-BaseModel
        $transition = Get-Transition -Model $model -TransitionId "ready_to_in_progress"
        $transition.allowed_executors = @($transition.allowed_executors) + @("project_manager")
        Invoke-MatrixValidation -Path (Write-TempModel -Model $model -Name "pm-as-implementer")
    }

    Invoke-ExpectedRefusal -Label "release-closeout-without-audit-accepted" -RequiredFragments @("audit accepted state") -Action {
        $model = Read-BaseModel
        $transition = Get-Transition -Model $model -TransitionId "approved_for_closeout_to_closed"
        $transition.required_evidence_refs = @($transition.required_evidence_refs | Where-Object { $_ -ne "audit_accepted_state_ref" })
        Invoke-MatrixValidation -Path (Write-TempModel -Model $model -Name "release-closeout-without-audit")
    }

    Invoke-ExpectedRefusal -Label "missing-accountable-agent" -RequiredFragments @("accountable_agent_id", "non-empty string") -Action {
        $model = Read-BaseModel
        $record = @($model.state_raci_records | Where-Object { $_.state_id -eq "ready" })[0]
        $record.accountable_agent_id = ""
        Invoke-MatrixValidation -Path (Write-TempModel -Model $model -Name "missing-accountable")
    }

    Invoke-ExpectedRefusal -Label "missing-responsible-agent" -RequiredFragments @("responsible_agent_ids", "must not be empty") -Action {
        $model = Read-BaseModel
        $record = @($model.state_raci_records | Where-Object { $_.state_id -eq "ready" })[0]
        $record.responsible_agent_ids = @()
        Invoke-MatrixValidation -Path (Write-TempModel -Model $model -Name "missing-responsible")
    }

    Invoke-ExpectedRefusal -Label "runtime-state-machine-overclaim" -RequiredFragments @("runtime_state_machine_implemented", "False") -Action {
        $model = Read-BaseModel
        $model.scope_boundary.runtime_state_machine_implemented = $true
        Invoke-MatrixValidation -Path (Write-TempModel -Model $model -Name "runtime-state-machine-overclaim")
    }

    Invoke-ExpectedRefusal -Label "board-routing-runtime-overclaim" -RequiredFragments @("board_routing_runtime_implemented", "False") -Action {
        $model = Read-BaseModel
        $model.scope_boundary.board_routing_runtime_implemented = $true
        Invoke-MatrixValidation -Path (Write-TempModel -Model $model -Name "board-routing-overclaim")
    }

    Invoke-ExpectedRefusal -Label "actual-agent-runtime-overclaim" -RequiredFragments @("actual_agents_implemented", "False") -Action {
        $model = Read-BaseModel
        $model.scope_boundary.actual_agents_implemented = $true
        Invoke-MatrixValidation -Path (Write-TempModel -Model $model -Name "actual-agents-overclaim")
    }

    Invoke-ExpectedRefusal -Label "card-reentry-implementation-overclaim" -RequiredFragments @("card_reentry_packet_implemented", "False") -Action {
        $model = Read-BaseModel
        $model.scope_boundary.card_reentry_packet_implemented = $true
        Invoke-MatrixValidation -Path (Write-TempModel -Model $model -Name "card-reentry-overclaim")
    }

    Invoke-ExpectedRefusal -Label "r16-opening-overclaim" -RequiredFragments @("r16_opened", "False") -Action {
        $model = Read-BaseModel
        $model.scope_boundary.r16_opened = $true
        Invoke-MatrixValidation -Path (Write-TempModel -Model $model -Name "r16-overclaim")
    }

    Invoke-ExpectedRefusal -Label "r15-010-successor-status" -RequiredFragments @("R15 implementation beyond R15-009") -Action {
        $scenario = New-StatusDocHarness -Root (Join-Path $tempRoot "invalid-r15-010-successor-status")
        Add-Content -LiteralPath $scenario.R15AuthorityPath -Value ("`r`nR15-010 successor task is planned.") -Encoding UTF8
        Invoke-MatrixValidation -Path $validFixture -RepositoryRoot $scenario.Root
    }
}
catch {
    $failures += ("FAIL R15 RACI state-transition matrix harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R15 RACI state-transition matrix tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R15 RACI state-transition matrix tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
