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
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Failure
    )
    Assert-Condition -Condition ($Object.PSObject.Properties.Name -contains $Name) -Message "Missing required false field '$Name'."
    Assert-Condition -Condition ($Object.$Name -eq $false) -Message $Failure
}

function Assert-TrueField {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Failure
    )
    Assert-Condition -Condition ($Object.PSObject.Properties.Name -contains $Name) -Message "Missing required true field '$Name'."
    Assert-Condition -Condition ($Object.$Name -eq $true) -Message $Failure
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

$decisionPath = Resolve-RepoPath "state/operator_decisions/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_operator_closeout_decision.json"
$contractPath = Resolve-RepoPath "contracts/governance/r17_operator_closeout_decision.contract.json"
$evidenceIndexPath = Resolve-RepoPath "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_operator_closeout_decision/evidence_index.json"
$proofReviewPath = Resolve-RepoPath "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_operator_closeout_decision/proof_review.md"
$validationManifestPath = Resolve-RepoPath "state/proof_reviews/r17_agentic_operating_surface_a2a_runtime_kanban_release_cycle/r17_operator_closeout_decision/validation_manifest.md"

$decision = Read-JsonFile -Path $decisionPath
$contract = Read-JsonFile -Path $contractPath
$evidenceIndex = Read-JsonFile -Path $evidenceIndexPath

foreach ($path in @(
        $proofReviewPath,
        $validationManifestPath,
        (Resolve-RepoPath "governance/reports/AIOffice_V2_R17_External_Audit_and_R18_Planning_Report_v1.md"),
        (Resolve-RepoPath "governance/plans/AIOffice_V2_Revised_R17_Plan.md")
    )) {
    Assert-Condition -Condition (Test-Path -LiteralPath $path -PathType Leaf) -Message "Required closeout artifact is missing: $path"
}

Assert-Condition -Condition ($contract.artifact_type -eq "r17_operator_closeout_decision_contract") -Message "R17 closeout contract artifact_type is invalid."
Assert-Condition -Condition ($decision.artifact_type -eq "r17_operator_closeout_decision") -Message "R17 closeout decision artifact_type is invalid."
Assert-Condition -Condition ($decision.decision_status -eq "operator_approved") -Message "R17 is closed without operator approval recorded."
Assert-Condition -Condition ($decision.decision_type -eq "accept_r17_bounded_foundation_with_caveats_and_open_r18") -Message "R17 closeout decision type is invalid."
Assert-Condition -Condition ($decision.accepted_scope -eq "R17-001 through R17-028 only") -Message "R17 accepted scope must be R17-001 through R17-028 only."
Assert-Condition -Condition ($decision.accepted_as -eq "bounded_foundation_pivot_only") -Message "R17 must be accepted only as bounded foundation/pivot."
Assert-Condition -Condition ($decision.rejected_as -eq "live_product_runtime") -Message "R17 accepted as live runtime is rejected."
Assert-TrueField -Object $decision -Name "operator_approval_recorded" -Failure "R17 is closed without operator approval recorded."
Assert-TrueField -Object $decision -Name "r17_closed" -Failure "R17 closeout decision must explicitly close R17."
Assert-TrueField -Object $decision -Name "r18_opening_authorized" -Failure "R18 opening authorization must be explicit."

$falseChecks = [ordered]@{
    main_merge_claimed = "Main merge is claimed."
    product_runtime_claimed = "R17 is accepted as live runtime."
    four_exercised_a2a_cycles_claimed = "R17 claims four exercised A2A cycles."
    live_a2a_runtime_claimed = "R17 claims live A2A runtime."
    live_recovery_runtime_claimed = "R17 claims live recovery runtime."
    automatic_new_thread_creation_claimed = "R17 claims automatic new-thread creation."
    openai_api_invoked = "R17 claims OpenAI API invocation."
    codex_api_invoked = "R17 claims Codex API invocation."
    autonomous_codex_invocation_claimed = "R17 claims autonomous Codex invocation."
    no_manual_prompt_transfer_success_claimed = "R17 claims no-manual-prompt-transfer success."
    solved_codex_compaction_claimed = "R17 claims solved compaction."
    solved_codex_reliability_claimed = "R17 claims solved reliability."
}

foreach ($entry in $falseChecks.GetEnumerator()) {
    Assert-FalseField -Object $decision -Name $entry.Key -Failure $entry.Value
}

Assert-Condition -Condition (@($decision.external_audit_artifact_refs).Count -ge 2) -Message "External audit artifact refs are missing."
Assert-Condition -Condition (@($decision.final_r17_package_refs).Count -ge 3) -Message "Final R17 package refs are missing."
Assert-Condition -Condition (@($decision.evidence_refs).Count -ge 3) -Message "Closeout evidence refs are missing."
Assert-Condition -Condition (@($decision.hard_non_claims).Count -ge 10) -Message "Hard non-claims are incomplete."
Assert-Condition -Condition (@($decision.caveats).Count -ge 4) -Message "R17 caveats are incomplete."

foreach ($flag in $falseChecks.Keys) {
    Assert-Condition -Condition ($evidenceIndex.runtime_flags.$flag -eq $false) -Message "Evidence index runtime flag '$flag' must be false."
}

$statusText = [string]::Join([Environment]::NewLine, @(
        (Get-Content -LiteralPath (Resolve-RepoPath "README.md") -Raw),
        (Get-Content -LiteralPath (Resolve-RepoPath "execution/KANBAN.md") -Raw),
        (Get-Content -LiteralPath (Resolve-RepoPath "governance/ACTIVE_STATE.md") -Raw),
        (Get-Content -LiteralPath (Resolve-RepoPath "governance/R17_AGENTIC_OPERATING_SURFACE_A2A_RUNTIME_KANBAN_RELEASE_CYCLE.md") -Raw),
        (Get-Content -LiteralPath (Resolve-RepoPath "governance/DECISION_LOG.md") -Raw)
    ))

foreach ($required in @(
        "R17 accepted and closed with caveats through R17-028 only",
        "R17 accepted only as a bounded foundation/pivot milestone",
        "R17 did not deliver live product runtime",
        "R17 did not deliver four exercised A2A cycles",
        "R17 did not deliver live A2A runtime",
        "R17 did not deliver live automated recovery",
        "R17 did not solve Codex compaction or reliability",
        "R17 did not prove no-manual-prompt-transfer success",
        "R18 active through R18-001 only",
        "R18-002 through R18-028 planned only",
        "Main is not merged"
    )) {
    Assert-Condition -Condition ($statusText -like "*$required*") -Message "Status docs missing required wording: $required"
}

foreach ($forbidden in @(
        "R17 delivered four exercised A2A cycles",
        "R17 delivered live product runtime",
        "R17 delivered live A2A runtime",
        "R17 delivered live automated recovery",
        "R17 solved Codex compaction",
        "R17 solved Codex reliability",
        "R17 proved no-manual-prompt-transfer success",
        "R17 invoked OpenAI API",
        "R17 invoked Codex API",
        "main merge completed"
    )) {
    Assert-Condition -Condition ($statusText -notlike "*$forbidden*") -Message "Forbidden positive claim found: $forbidden"
}

$changedPaths = @()
$changedPaths += Get-GitPathSet -GitArgs "diff --name-only"
$changedPaths += Get-GitPathSet -GitArgs "diff --cached --name-only"
$changedPaths = @($changedPaths | Sort-Object -Unique)

foreach ($path in $changedPaths) {
    Assert-Condition -Condition ($path -notmatch '^state/proof_reviews/r1[3-6]|^state/.*/r1[3-6]_|^governance/R1[3-6]_') -Message "Historical R13/R14/R15/R16 evidence is edited: $path"
    Assert-Condition -Condition ($path -notmatch '^\.local_backups/') -Message "Operator local backup paths are committed: $path"
}

$trackedPaths = Get-GitPathSet -GitArgs "ls-files"
foreach ($path in $trackedPaths) {
    Assert-Condition -Condition ($path -notmatch '^\.local_backups/') -Message "Operator local backup paths are committed: $path"
}

$combinedJson = @($decision, $evidenceIndex) | ConvertTo-Json -Depth 100
Assert-Condition -Condition ($combinedJson -notmatch '"broad_repo_scan_output[^"]*"\s*:\s*true') -Message "Broad repo scan output is committed."
Assert-Condition -Condition ($combinedJson -notmatch '\.local_backups') -Message "Operator local backup paths are committed in closeout artifacts."

Write-Output "R17 operator closeout decision validation passed."
Write-Output "R17 status: accepted and closed with caveats through R17-028 only."
Write-Output "R18 status: opening authorized; active through R18-001 only."
