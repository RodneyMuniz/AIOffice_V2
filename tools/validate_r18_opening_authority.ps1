[CmdletBinding()]
param(
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}

function Resolve-RepoPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $Path))
}

function Read-JsonFile {
    param([Parameter(Mandatory = $true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required file is missing: $Path"
    }
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Assert-Condition {
    param([bool]$Condition, [Parameter(Mandatory = $true)][string]$Message)
    if (-not $Condition) {
        throw $Message
    }
}

function Assert-FalseField {
    param($Object, [string]$Name, [string]$Message)
    Assert-Condition -Condition ($Object.PSObject.Properties.Name -contains $Name) -Message "Missing required false field '$Name'."
    Assert-Condition -Condition ($Object.$Name -eq $false) -Message $Message
}

function Get-GitPathSet {
    param([string]$GitArgs)
    $isInsideWorkTree = & git -C $RepositoryRoot rev-parse --is-inside-work-tree 2>$null
    if ($LASTEXITCODE -ne 0 -or $isInsideWorkTree -ne "true") {
        return @()
    }

    $gitArgsArray = @($GitArgs -split ' ')
    $items = & git -C $RepositoryRoot @gitArgsArray 2>$null
    if ($LASTEXITCODE -ne 0) {
        return @()
    }

    return @($items | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | ForEach-Object { $_ -replace '\\', '/' })
}

$state = Read-JsonFile -Path (Resolve-RepoPath "state/governance/r18_opening_authority.json")
$contract = Read-JsonFile -Path (Resolve-RepoPath "contracts/governance/r18_opening_authority.contract.json")
$decision = Read-JsonFile -Path (Resolve-RepoPath "state/operator_decisions/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_operator_closeout_decision.json")
$authorityPath = Resolve-RepoPath "governance/R18_AUTOMATED_RECOVERY_RUNTIME_AND_API_ORCHESTRATION.md"
$manifestPath = Resolve-RepoPath "state/planning/r18_automated_recovery_runtime_and_api_orchestration/r18_001_opening_authority_manifest.md"

Assert-Condition -Condition (Test-Path -LiteralPath $authorityPath -PathType Leaf) -Message "R18 authority document is missing."
Assert-Condition -Condition (Test-Path -LiteralPath $manifestPath -PathType Leaf) -Message "R18 opening manifest is missing."
Assert-Condition -Condition ($contract.artifact_type -eq "r18_opening_authority_contract") -Message "R18 contract artifact_type is invalid."
Assert-Condition -Condition ($state.artifact_type -eq "r18_opening_authority") -Message "R18 state artifact_type is invalid."
Assert-Condition -Condition ($decision.operator_approval_recorded -eq $true -and $decision.r17_closed -eq $true) -Message "R18 opened without R17 operator closeout approval."
Assert-Condition -Condition ($state.r18_status -eq "active_through_r18_001_only") -Message "R18 is opened beyond R18-001."
Assert-Condition -Condition ($state.active_task -eq "R18-001") -Message "R18 active task must be R18-001 only."
Assert-Condition -Condition (@($state.done_tasks) -join "," -eq "R18-001") -Message "R18 is opened beyond R18-001."
Assert-Condition -Condition (@($state.planned_tasks).Count -eq 27) -Message "R18-002 through R18-028 must be planned only."
Assert-Condition -Condition (@($state.planned_tasks) -contains "R18-002" -and @($state.planned_tasks) -contains "R18-028") -Message "R18 planned range must be R18-002 through R18-028."

$falseChecks = [ordered]@{
        r18_runtime_implementation_claimed = "Any R18 runtime implementation is claimed."
        r18_api_invocation_claimed = "R18 API invocation is claimed."
        openai_api_invoked = "OpenAI API invocation is claimed."
        codex_api_invoked = "Codex API invocation is claimed."
        autonomous_codex_invocation_claimed = "Autonomous Codex invocation is claimed."
        live_recovery_runtime_claimed = "Live recovery runtime is claimed."
        live_a2a_runtime_claimed = "Live A2A runtime is claimed."
        main_merge_claimed = "Main merge is claimed."
        r18_closeout_claimed = "R18 closeout is claimed."
        solved_codex_compaction_claimed = "Solved Codex compaction is claimed."
        solved_codex_reliability_claimed = "Solved Codex reliability is claimed."
        no_manual_prompt_transfer_success_claimed = "No-manual-prompt-transfer success is claimed."
    }
foreach ($entry in $falseChecks.GetEnumerator()) {
    Assert-FalseField -Object $state -Name $entry.Key -Message $entry.Value
}

$authority = Get-Content -LiteralPath $authorityPath -Raw
Assert-Condition -Condition ($authority -like "*R18 is active only after R17 operator closeout approval*") -Message "R18 authority must state dependency on R17 operator closeout approval."
Assert-Condition -Condition ($authority -like "*Active through*R18-011*WIP classifier foundation only*") -Message "R18 authority must state active through R18-011 only."
Assert-Condition -Condition ($authority -like "*R18-012*R18-028*planned only*") -Message "R18 authority must state R18-012 through R18-028 planned only."
Assert-Condition -Condition ($authority -like "*API-backed Codex/OpenAI invocation is optional and must not be implemented before secrets, budget, timeout, retry, approval, and stop controls exist*") -Message "R18 authority must preserve API control boundary."
Assert-Condition -Condition ($authority -like "*small resumable work orders, not giant Codex prompts*") -Message "R18 authority must require small resumable work orders."
Assert-Condition -Condition ($authority -like "*fail-closed behavior*") -Message "R18 authority must preserve fail-closed behavior."

$matches = [regex]::Matches($authority, '(?ms)^###\s+`(R18-\d{3})`.*?^\-\s+Status:\s+(done|planned)\s*$')
Assert-Condition -Condition ($matches.Count -eq 28) -Message "R18 authority must define 28 R18 tasks."
foreach ($match in $matches) {
    $taskId = $match.Groups[1].Value
    $status = $match.Groups[2].Value
    if ($taskId -eq "R18-001" -or $taskId -eq "R18-002" -or $taskId -eq "R18-003" -or $taskId -eq "R18-004" -or $taskId -eq "R18-005" -or $taskId -eq "R18-006" -or $taskId -eq "R18-007" -or $taskId -eq "R18-008" -or $taskId -eq "R18-009" -or $taskId -eq "R18-010" -or $taskId -eq "R18-011") {
        Assert-Condition -Condition ($status -eq "done") -Message "$taskId must be done."
    }
    else {
        Assert-Condition -Condition ($status -eq "planned") -Message "$taskId must be planned only."
    }
}
Assert-Condition -Condition ($authority -notmatch '(?m)^###\s+`R18-(0(?:2[9]|[3-9][0-9])|[1-9][0-9]{2,})`') -Message "R18 is opened beyond R18-028."

$statusText = [string]::Join([Environment]::NewLine, @(
        (Get-Content -LiteralPath (Resolve-RepoPath "README.md") -Raw),
        (Get-Content -LiteralPath (Resolve-RepoPath "execution/KANBAN.md") -Raw),
        (Get-Content -LiteralPath (Resolve-RepoPath "governance/ACTIVE_STATE.md") -Raw),
        (Get-Content -LiteralPath (Resolve-RepoPath "governance/DECISION_LOG.md") -Raw)
    ))
foreach ($required in @(
        "R18 active through R18-011 only",
        "R18-012 through R18-028 planned only",
        "R18-002 created agent card schema and seed cards only",
        "Agent cards are not live agents",
        "R18-003 created skill contract schema and seed skill contracts only",
        "Skill contracts are not live skill execution",
        "R18-004 created A2A handoff packet schema and seed handoff packets only",
        "A2A handoff packets are not live A2A runtime",
        "R18-005 created role-to-skill permission matrix only",
        "Permission matrix is not runtime enforcement",
        "R18-006 created Orchestrator chat/control intake contract and seed intake packets only",
        "Intake packets are not a live chat UI",
        "Intake packets are not Orchestrator runtime",
        "R18-007 created local runner/CLI shell foundation only",
        "CLI shell is dry-run only",
        "CLI shell is not full work-order execution runtime",
        "R18-008 created work-order execution state machine foundation only",
        "Work-order state machine is not runtime execution",
        "R18-009 created runner state store and resumable execution log foundation only",
        "Runner state store is not live runner runtime",
        "Execution log is deterministic foundation evidence, not live execution evidence",
        "Resume checkpoint is not a continuation packet",
        "R18-010 created compact failure detector foundation only",
        "Failure detection is deterministic over seed signal artifacts only",
        "Failure events are not recovery completion",
        "R18-011 created WIP classifier foundation only",
        "WIP classification is deterministic over seed git inventory artifacts only",
        "No WIP cleanup was performed",
        "No WIP abandonment was performed",
        "No files were restored or deleted",
        "No staging, commit, or push was performed by the classifier",
        "Remote branch verifier runtime is not implemented",
        "Continuation packet generator is not implemented",
        "New-context prompt generator is not implemented",
        "No work orders were executed",
        "No board/card runtime mutation occurred",
        "No A2A messages were sent",
        "No live agents were invoked",
        "No live skills were executed",
        "No A2A runtime was implemented",
        "No live A2A runtime was implemented",
        "No local runner runtime was executed",
        "No recovery runtime was implemented",
        "No recovery action was performed",
        "No API invocation occurred",
        "No automatic new-thread creation occurred",
        "No stage/commit/push was performed by the runner or state store",
        "No stage/commit/push was performed by the detector",
        "No product runtime is claimed",
        "Codex compaction is detected as a failure type, not solved",
        "R18 runtime implementation is not yet delivered",
        "Main is not merged"
    )) {
    Assert-Condition -Condition ($statusText -like "*$required*") -Message "Status docs missing R18 wording: $required"
}
foreach ($forbidden in @(
        "R18 runtime implementation is delivered",
        "R18 API invocation completed",
        "R18 live recovery runtime delivered",
        "R18 solved Codex compaction",
        "R18 solved Codex reliability",
        "R18 proved no-manual-prompt-transfer success"
    )) {
    Assert-Condition -Condition ($statusText -notlike "*$forbidden*") -Message "Forbidden R18 positive claim found: $forbidden"
}

$changedPaths = @()
$changedPaths += Get-GitPathSet -GitArgs "diff --name-only"
$changedPaths += Get-GitPathSet -GitArgs "diff --cached --name-only"
$changedPaths = @($changedPaths | Sort-Object -Unique)
foreach ($path in $changedPaths) {
    Assert-Condition -Condition ($path -notmatch '^state/proof_reviews/r1[3-6]|^state/.*/r1[3-6]_|^governance/R1[3-6]_') -Message "Historical R13/R14/R15/R16 evidence is edited: $path"
    Assert-Condition -Condition ($path -notmatch '^\.local_backups/') -Message "Operator local backup paths are committed: $path"
}

Write-Output "R18 opening authority validation passed."
Write-Output "R18 opening authority state remains active through R18-001 only; current status is active through R18-011 only with R18-012 through R18-028 planned only."
