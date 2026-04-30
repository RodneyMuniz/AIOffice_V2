Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force
$statusModule = Import-Module (Join-Path $PSScriptRoot "ControlRoomStatus.psm1") -Force -PassThru
$script:TestControlRoomStatus = $statusModule.ExportedCommands["Test-ControlRoomStatus"]

function Get-RepositoryRoot {
    return $repoRoot
}

function Resolve-RepositoryPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path (Get-RepositoryRoot) $PathValue))
}

function Get-JsonDocument {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    return (Read-SingleJsonObject -Path $Path -Label $Label)
}

function Get-ControlRoomViewContract {
    return Get-JsonDocument -Path (Resolve-RepositoryPath -PathValue "contracts/control_room/control_room_view.contract.json") -Label "Control-room view contract"
}

function Test-LineHasNegation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Line
    )

    return ($Line -match '(?i)\b(no|not|without|cannot|must not|does not|do not|is not|are not|non-claim|blocked|required before|not_started)\b')
}

function Assert-NoForbiddenViewClaim {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($line in ($Text -split "\r?\n")) {
        if ($line -match '(?i)\b(productized control-room behavior|full UI app|production runtime|R12 closeout|final-state replay|real build/change gate)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context contains a forbidden positive view claim: $line"
        }
    }
}

function Add-BulletList {
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.Generic.List[string]]$Lines,
        [Parameter(Mandatory = $true)]
        [object[]]$Items
    )

    if ($Items.Count -eq 0) {
        $Lines.Add("- None recorded.") | Out-Null
        return
    }

    foreach ($item in $Items) {
        $Lines.Add("- ``$item``") | Out-Null
    }
}

function Export-ControlRoomViewMarkdown {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$StatusPath,
        [string]$MarkdownOutputPath = "state/control_room/r12_current/control_room.md",
        [switch]$Overwrite
    )

    & $script:TestControlRoomStatus -StatusPath $StatusPath | Out-Null
    $status = Get-JsonDocument -Path (Resolve-RepositoryPath -PathValue $StatusPath) -Label "Control-room status"

    $resolvedOutputPath = Resolve-RepositoryPath -PathValue $MarkdownOutputPath
    if ((Test-Path -LiteralPath $resolvedOutputPath -PathType Leaf) -and -not $Overwrite) {
        throw "Control-room Markdown output '$MarkdownOutputPath' already exists. Use -Overwrite to replace it explicitly."
    }

    $parentPath = Split-Path -Parent $resolvedOutputPath
    if (-not [string]::IsNullOrWhiteSpace($parentPath)) {
        New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    }

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# R12 Operator Control Room") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add(("- Generated at UTC: ``{0}``" -f $status.generated_at_utc)) | Out-Null
    $lines.Add(("- Source status: ``{0}``" -f $StatusPath.Replace("\", "/"))) | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## Current Branch/Head/Tree") | Out-Null
    $lines.Add(("- Branch: ``{0}``" -f $status.branch)) | Out-Null
    $lines.Add(("- Head: ``{0}``" -f $status.head)) | Out-Null
    $lines.Add(("- Tree: ``{0}``" -f $status.tree)) | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## Active Milestone and Scope") | Out-Null
    $lines.Add(("- Active milestone: ``{0}``" -f $status.active_milestone)) | Out-Null
    $lines.Add(("- Input completed through: ``{0}``" -f $status.active_scope.input_completed_through)) | Out-Null
    $lines.Add(("- Current completed through: ``{0}``" -f $status.active_scope.current_completed_through)) | Out-Null
    $lines.Add(("- Scope: {0}" -f $status.active_scope.scope_summary)) | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## R12 Task Status Summary") | Out-Null
    $lines.Add(("- Completed tasks: ``{0}``" -f (@($status.completed_tasks) -join '`, `'))) | Out-Null
    $lines.Add(("- Planned tasks: ``{0}``" -f (@($status.planned_tasks) -join '`, `'))) | Out-Null
    $lines.Add(("- Current phase: ``{0}``" -f $status.current_phase)) | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## Value Gate Status") | Out-Null
    $lines.Add("| Gate | Status |") | Out-Null
    $lines.Add("| --- | --- |") | Out-Null
    foreach ($gateName in @("external_api_runner", "actionable_qa", "operator_control_room", "real_build_change")) {
        $lines.Add(("| ``{0}`` | ``{1}`` |" -f $gateName, $status.value_gate_status.$gateName)) | Out-Null
    }
    $lines.Add("") | Out-Null
    $lines.Add("## Blockers and Attention Items") | Out-Null
    $lines.Add("### Blockers") | Out-Null
    foreach ($blocker in @($status.blockers)) {
        $lines.Add(("- ``{0}`` [{1}/{2}] {3}: {4} Recommended next action: {5}" -f $blocker.id, $blocker.severity, $blocker.blocking_status, $blocker.title, $blocker.explanation, $blocker.recommended_next_action)) | Out-Null
        $lines.Add(("  Evidence refs: ``{0}``" -f (@($blocker.evidence_refs) -join '`, `'))) | Out-Null
    }
    $lines.Add("### Attention Items") | Out-Null
    foreach ($attentionItem in @($status.attention_items)) {
        $lines.Add(("- ``{0}`` [{1}/{2}] {3}: {4} Recommended next action: {5}" -f $attentionItem.id, $attentionItem.severity, $attentionItem.blocking_status, $attentionItem.title, $attentionItem.explanation, $attentionItem.recommended_next_action)) | Out-Null
        $lines.Add(("  Evidence refs: ``{0}``" -f (@($attentionItem.evidence_refs) -join '`, `'))) | Out-Null
    }
    $lines.Add("") | Out-Null
    $lines.Add("## QA/Actionability Posture") | Out-Null
    $lines.Add(("- Actionable QA status: ``{0}`` - {1}" -f $status.actionable_qa_status.status, $status.actionable_qa_status.summary)) | Out-Null
    $lines.Add(("- QA evidence gate status: ``{0}`` - {1}" -f $status.qa_evidence_gate_status.status, $status.qa_evidence_gate_status.summary)) | Out-Null
    $lines.Add(("- QA evidence gate passable_current_state: ``{0}``" -f $status.qa_evidence_gate_status.passable_current_state)) | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## External Runner Posture") | Out-Null
    $lines.Add(("- External runner status: ``{0}`` - {1}" -f $status.external_runner_status.status, $status.external_runner_status.summary)) | Out-Null
    $lines.Add(("- has_live_r12_external_run: ``{0}``" -f $status.external_runner_status.has_live_r12_external_run)) | Out-Null
    $lines.Add(("- has_external_artifact_evidence: ``{0}``" -f $status.external_runner_status.has_external_artifact_evidence)) | Out-Null
    $lines.Add(("- Blocking reason: {0}" -f $status.external_runner_status.blocking_reason)) | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## Current Evidence Refs") | Out-Null
    foreach ($evidenceRef in @($status.evidence_refs)) {
        $lines.Add(("- ``{0}``" -f $evidenceRef)) | Out-Null
    }
    $lines.Add("") | Out-Null
    $lines.Add("## Next Recommended Actions") | Out-Null
    foreach ($nextAction in @($status.next_actions)) {
        $lines.Add(("- ``{0}`` / ``{1}`` [{2}] {3}: {4} Required before: ``{5}``" -f $nextAction.id, $nextAction.task_id, $nextAction.action_type, $nextAction.title, $nextAction.description, $nextAction.required_before)) | Out-Null
        $lines.Add(("  Evidence refs: ``{0}``" -f (@($nextAction.evidence_refs) -join '`, `'))) | Out-Null
    }
    $lines.Add("") | Out-Null
    $lines.Add("## Operator Decisions Required") | Out-Null
    foreach ($decision in @($status.operator_decisions_required)) {
        $lines.Add(("- ``{0}`` [{1}/{2}] {3}. Required before: ``{4}``" -f $decision.id, $decision.decision_type, $decision.blocking_status, $decision.title, $decision.required_before)) | Out-Null
        $lines.Add(("  Evidence refs: ``{0}``" -f (@($decision.evidence_refs) -join '`, `'))) | Out-Null
    }
    $lines.Add("") | Out-Null
    $lines.Add("## Explicit Non-Claims") | Out-Null
    foreach ($nonClaim in @($status.non_claims)) {
        $lines.Add("- $nonClaim") | Out-Null
    }

    Set-Content -LiteralPath $resolvedOutputPath -Value $lines -Encoding UTF8
    return $resolvedOutputPath
}

function Test-ControlRoomViewMarkdown {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$StatusPath,
        [Parameter(Mandatory = $true)]
        [string]$MarkdownPath
    )

    & $script:TestControlRoomStatus -StatusPath $StatusPath | Out-Null
    $status = Get-JsonDocument -Path (Resolve-RepositoryPath -PathValue $StatusPath) -Label "Control-room status"
    $contract = Get-ControlRoomViewContract
    $resolvedMarkdownPath = Resolve-RepositoryPath -PathValue $MarkdownPath
    $text = Get-Content -LiteralPath $resolvedMarkdownPath -Raw

    if ($text -notmatch '^# R12 Operator Control Room') {
        throw "Control-room view must include the title."
    }
    if ($text -notmatch 'Generated at UTC:\s+`\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z`') {
        throw "Control-room view must include the generated timestamp."
    }

    foreach ($section in @($contract.required_sections | Where-Object { $_ -ne "Title and Generated Timestamp" })) {
        $heading = "## " + $section
        if ($text -notmatch [regex]::Escape($heading)) {
            throw "Control-room view missing required section '$section'."
        }
    }

    foreach ($identityValue in @($status.branch, $status.head, $status.tree)) {
        if ($text -notmatch [regex]::Escape([string]$identityValue)) {
            throw "Control-room view must preserve branch/head/tree value '$identityValue'."
        }
    }

    foreach ($blocker in @($status.blockers)) {
        if ($text -notmatch [regex]::Escape([string]$blocker.id) -or $text -notmatch [regex]::Escape([string]$blocker.title)) {
            throw "Control-room view must include blocker '$($blocker.id)'."
        }
    }

    foreach ($nonClaim in @($status.non_claims)) {
        if ($text -notmatch [regex]::Escape([string]$nonClaim)) {
            throw "Control-room view must include non-claim '$nonClaim'."
        }
    }

    foreach ($evidenceRef in @($status.evidence_refs)) {
        if ($text -notmatch [regex]::Escape([string]$evidenceRef)) {
            throw "Control-room view must include evidence ref '$evidenceRef'."
        }
    }

    if (-not [bool]$status.external_runner_status.has_live_r12_external_run -and $text -notmatch '(?i)No live R12 external run|has_live_r12_external_run:\s+``False``|external runner status:\s+``blocked``') {
        throw "Control-room view hides blocked external evidence posture."
    }
    if (-not [bool]$status.qa_evidence_gate_status.passable_current_state -and $text -notmatch '(?i)cannot pass|passable_current_state:\s+``False``|QA evidence gate status:\s+``blocked``') {
        throw "Control-room view hides blocked QA evidence gate status."
    }

    Assert-NoForbiddenViewClaim -Text $text -Context "Control-room view"

    return [pscustomobject][ordered]@{
        MarkdownPath = $resolvedMarkdownPath
        SourceStatusPath = $StatusPath
        Branch = $status.branch
        Head = $status.head
        Tree = $status.tree
        BlockerCount = @($status.blockers).Count
        EvidenceRefCount = @($status.evidence_refs).Count
    }
}

Export-ModuleMember -Function Get-ControlRoomViewContract, Export-ControlRoomViewMarkdown, Test-ControlRoomViewMarkdown
