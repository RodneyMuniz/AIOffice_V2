Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$script:R12RepositoryName = "AIOffice_V2"
$script:R12Branch = "release/r12-external-api-runner-actionable-qa-control-room-pilot"
$script:R12Milestone = "R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot"
$script:GitObjectPattern = "^[a-f0-9]{40}$"
$script:TimestampPattern = "^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$"
$script:AllowedGateStatuses = @("not_started", "foundation_present", "diagnostic_only", "blocked", "partially_evidenced", "evidenced", "refused")
$script:AllowedBlockingStatuses = @("blocking", "non_blocking", "advisory")
$script:RequiredStatusNonClaims = @(
    "no productized control-room behavior",
    "no full UI app",
    "no production runtime",
    "no R12 closeout",
    "no final-state replay",
    "no full R12 value-gate delivery",
    "no final QA pass for R12 closeout",
    "no R13 authorization",
    "no broad autonomy",
    "no solved Codex reliability",
    "no broad CI/product coverage"
)

function Get-RepositoryRoot {
    return $repoRoot
}

function Join-RepositoryPath {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Segments
    )

    $path = Get-RepositoryRoot
    foreach ($segment in $Segments) {
        $path = Join-Path $path $segment
    }

    return $path
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

function Get-UtcTimestamp {
    return [System.DateTimeOffset]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture)
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

function Write-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Document,
        [switch]$Overwrite
    )

    if ((Test-Path -LiteralPath $Path -PathType Leaf) -and -not $Overwrite) {
        throw "Control-room status output '$Path' already exists. Use -Overwrite to replace it explicitly."
    }

    $parentPath = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($parentPath)) {
        New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    }

    $json = ($Document | ConvertTo-Json -Depth 100)
    $content = ($json -replace "`r`n", "`n") + "`n"
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $content, $utf8NoBom)
}

function Test-HasProperty {
    param(
        [AllowNull()]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    return $null -ne $Object -and @($Object.PSObject.Properties.Name) -contains $Name
}

function Get-RequiredProperty {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if (-not (Test-HasProperty -Object $Object -Name $Name)) {
        throw "$Context is missing required field '$Name'."
    }

    $PSCmdlet.WriteObject($Object.PSObject.Properties[$Name].Value, $false)
}

function Assert-NonEmptyString {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -isnot [string] -or [string]::IsNullOrWhiteSpace($Value)) {
        throw "$Context must be a non-empty string."
    }

    return $Value
}

function Assert-StringValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($null -eq $Value -or $Value -isnot [string]) {
        throw "$Context must be a string."
    }

    return $Value
}

function Assert-BooleanValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -isnot [bool]) {
        throw "$Context must be a boolean."
    }

    return [bool]$Value
}

function Assert-ObjectValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($null -eq $Value -or $Value -is [string] -or $Value -is [System.Array]) {
        throw "$Context must be an object."
    }

    return $Value
}

function Assert-StringArray {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [switch]$AllowEmpty
    )

    if ($null -eq $Value -or $Value -is [string] -or -not ($Value -is [System.Collections.IEnumerable])) {
        throw "$Context must be an array."
    }

    $items = @($Value)
    if (-not $AllowEmpty -and $items.Count -eq 0) {
        throw "$Context must not be empty."
    }

    foreach ($item in $items) {
        Assert-NonEmptyString -Value $item -Context "$Context item" | Out-Null
    }

    $PSCmdlet.WriteObject($items, $false)
}

function Assert-ObjectArray {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [switch]$AllowEmpty
    )

    if ($null -eq $Value -or $Value -is [string] -or -not ($Value -is [System.Collections.IEnumerable])) {
        throw "$Context must be an array."
    }

    $items = @($Value)
    if (-not $AllowEmpty -and $items.Count -eq 0) {
        throw "$Context must not be empty."
    }

    foreach ($item in $items) {
        Assert-ObjectValue -Value $item -Context "$Context item" | Out-Null
    }

    $PSCmdlet.WriteObject($items, $false)
}

function Assert-GitSha {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-NonEmptyString -Value $Value -Context $Context | Out-Null
    if ($Value -notmatch $script:GitObjectPattern) {
        throw "$Context must be a 40-character Git SHA."
    }
}

function Assert-TimestampString {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $timestamp = Assert-NonEmptyString -Value $Value -Context $Context
    if ($timestamp -notmatch $script:TimestampPattern) {
        throw "$Context must be a UTC timestamp."
    }
    return $timestamp
}

function Assert-RequiredObjectFields {
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        [string[]]$FieldNames,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-ObjectValue -Value $Object -Context $Context | Out-Null
    foreach ($fieldName in $FieldNames) {
        Get-RequiredProperty -Object $Object -Name $fieldName -Context $Context | Out-Null
    }
}

function Assert-AllowedValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [object[]]$AllowedValues,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($AllowedValues -notcontains $Value) {
        throw "$Context must be one of: $($AllowedValues -join ', ')."
    }
}

function Assert-BoundedPathOrUrl {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -match '^https?://') {
        return
    }
    if ([System.IO.Path]::IsPathRooted($Value) -or $Value -match '(^|[\\/])\.\.([\\/]|$)') {
        throw "$Context must be a repository-relative path without traversal."
    }
}

function Assert-ExistingEvidenceRef {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Ref,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-BoundedPathOrUrl -Value $Ref -Context $Context
    if ($Ref -match '^https?://') {
        return
    }
    if (-not (Test-Path -LiteralPath (Resolve-RepositoryPath -PathValue $Ref))) {
        throw "$Context evidence ref '$Ref' does not exist."
    }
}

function Assert-RequiredNonClaims {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$NonClaims,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($requiredNonClaim in $script:RequiredStatusNonClaims) {
        if ($NonClaims -notcontains $requiredNonClaim) {
            throw "$Context non_claims must include '$requiredNonClaim'."
        }
    }
}

function Test-LineHasNegation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Line
    )

    return ($Line -match '(?i)\b(no|not|without|cannot|must not|does not|do not|is not|are not|non-claim|refuse|refused|blocked|not_started)\b')
}

function Assert-NoForbiddenStatusClaim {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Lines,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($line in $Lines) {
        if ($line -match '(?i)\b(productized control-room behavior|full UI app|production runtime|R12 closeout|final-state replay|real build/change gate|full R12 value-gate delivery)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context contains a forbidden positive claim: $line"
        }
    }
}

function Get-R12TaskNumber {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TaskId,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($TaskId -notmatch '^R12-(\d{3})$') {
        throw "$Context must be an R12 task id."
    }

    return [int]$Matches[1]
}

function Get-R12TaskId {
    param(
        [Parameter(Mandatory = $true)]
        [int]$TaskNumber
    )

    return "R12-{0}" -f $TaskNumber.ToString("000")
}

function Assert-R12TaskLists {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$CompletedTasks,
        [Parameter(Mandatory = $true)]
        [string[]]$PlannedTasks,
        [Parameter(Mandatory = $true)]
        $ActiveScope,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($CompletedTasks.Count -eq 0) {
        throw "$Context completed_tasks must not be empty."
    }

    $currentNumber = Get-R12TaskNumber -TaskId ([string]$ActiveScope.current_completed_through) -Context "$Context active_scope.current_completed_through"
    if ($currentNumber -lt 14 -or $currentNumber -gt 17) {
        throw "$Context must show R12 active at least through R12-014 and no later than R12-017 in this slice."
    }

    $expectedInputCompletedThrough = if ($currentNumber -ge 17) { "R12-016" } else { "R12-013" }
    if ($ActiveScope.input_completed_through -ne $expectedInputCompletedThrough) {
        throw "$Context active_scope.input_completed_through must be $expectedInputCompletedThrough."
    }

    for ($taskNumber = 1; $taskNumber -le $currentNumber; $taskNumber += 1) {
        $expectedTask = Get-R12TaskId -TaskNumber $taskNumber
        if ($CompletedTasks -notcontains $expectedTask) {
            throw "$Context completed_tasks must include '$expectedTask'."
        }
    }

    foreach ($completedTask in $CompletedTasks) {
        $completedNumber = Get-R12TaskNumber -TaskId $completedTask -Context "$Context completed_tasks item"
        if ($completedNumber -gt $currentNumber) {
            throw "$Context completed_tasks cannot include tasks after active_scope.current_completed_through."
        }
    }

    if ($currentNumber -lt 21) {
        for ($taskNumber = $currentNumber + 1; $taskNumber -le 21; $taskNumber += 1) {
            $expectedTask = Get-R12TaskId -TaskNumber $taskNumber
            if ($PlannedTasks -notcontains $expectedTask) {
                throw "$Context planned_tasks must include '$expectedTask'."
            }
        }
    }

    foreach ($plannedTask in $PlannedTasks) {
        $plannedNumber = Get-R12TaskNumber -TaskId $plannedTask -Context "$Context planned_tasks item"
        if ($plannedNumber -le $currentNumber -or $plannedNumber -gt 21) {
            throw "$Context planned_tasks must contain only tasks after current completion through R12-021."
        }
    }
}

function Get-ControlRoomStatusContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "control_room", "control_room_status.contract.json")) -Label "Control-room status contract"
}

function Test-ControlRoomStatusObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Status,
        [string]$SourceLabel = "Control-room status"
    )

    $contract = Get-ControlRoomStatusContract
    Assert-RequiredObjectFields -Object $Status -FieldNames $contract.required_fields -Context $SourceLabel

    if ($Status.contract_version -ne $contract.contract_version) {
        throw "$SourceLabel contract_version must be '$($contract.contract_version)'."
    }
    if ($Status.artifact_type -ne "control_room_status") {
        throw "$SourceLabel artifact_type must be 'control_room_status'."
    }
    Assert-NonEmptyString -Value $Status.status_id -Context "$SourceLabel status_id" | Out-Null
    if ($Status.repository -ne $script:R12RepositoryName) {
        throw "$SourceLabel repository must be '$script:R12RepositoryName'."
    }
    if ($Status.branch -ne $script:R12Branch) {
        throw "$SourceLabel branch must be '$script:R12Branch'."
    }
    Assert-GitSha -Value ([string]$Status.head) -Context "$SourceLabel head"
    Assert-GitSha -Value ([string]$Status.tree) -Context "$SourceLabel tree"
    if ($Status.active_milestone -ne $script:R12Milestone) {
        throw "$SourceLabel active_milestone must be '$script:R12Milestone'."
    }

    $activeScope = Assert-ObjectValue -Value $Status.active_scope -Context "$SourceLabel active_scope"
    Assert-RequiredObjectFields -Object $activeScope -FieldNames $contract.active_scope_required_fields -Context "$SourceLabel active_scope"
    Assert-StringArray -Value $activeScope.planned_remaining -Context "$SourceLabel active_scope.planned_remaining" -AllowEmpty | Out-Null
    Assert-NonEmptyString -Value $activeScope.scope_summary -Context "$SourceLabel active_scope.scope_summary" | Out-Null

    $completedTasks = Assert-StringArray -Value $Status.completed_tasks -Context "$SourceLabel completed_tasks"
    $plannedTasks = Assert-StringArray -Value $Status.planned_tasks -Context "$SourceLabel planned_tasks"
    Assert-R12TaskLists -CompletedTasks $completedTasks -PlannedTasks $plannedTasks -ActiveScope $activeScope -Context $SourceLabel

    Assert-NonEmptyString -Value $Status.current_phase -Context "$SourceLabel current_phase" | Out-Null

    $valueGateStatus = Assert-ObjectValue -Value $Status.value_gate_status -Context "$SourceLabel value_gate_status"
    foreach ($gateName in @($contract.value_gate_names)) {
        $gateValue = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $valueGateStatus -Name $gateName -Context "$SourceLabel value_gate_status") -Context "$SourceLabel value_gate_status.$gateName"
        Assert-AllowedValue -Value $gateValue -AllowedValues $script:AllowedGateStatuses -Context "$SourceLabel value_gate_status.$gateName"
    }

    $externalRunnerStatus = Assert-ObjectValue -Value $Status.external_runner_status -Context "$SourceLabel external_runner_status"
    foreach ($fieldName in @("status", "summary", "has_live_r12_external_run", "has_external_artifact_evidence", "evidence_refs", "blocking_reason")) {
        Get-RequiredProperty -Object $externalRunnerStatus -Name $fieldName -Context "$SourceLabel external_runner_status" | Out-Null
    }
    Assert-AllowedValue -Value ([string]$externalRunnerStatus.status) -AllowedValues $script:AllowedGateStatuses -Context "$SourceLabel external_runner_status.status"
    Assert-BooleanValue -Value $externalRunnerStatus.has_live_r12_external_run -Context "$SourceLabel external_runner_status.has_live_r12_external_run" | Out-Null
    Assert-BooleanValue -Value $externalRunnerStatus.has_external_artifact_evidence -Context "$SourceLabel external_runner_status.has_external_artifact_evidence" | Out-Null
    Assert-StringArray -Value $externalRunnerStatus.evidence_refs -Context "$SourceLabel external_runner_status.evidence_refs" -AllowEmpty | Out-Null

    foreach ($statusField in @("actionable_qa_status", "control_room_status", "real_build_change_status", "qa_evidence_gate_status")) {
        Assert-ObjectValue -Value $Status.$statusField -Context "$SourceLabel $statusField" | Out-Null
        Get-RequiredProperty -Object $Status.$statusField -Name "status" -Context "$SourceLabel $statusField" | Out-Null
        Get-RequiredProperty -Object $Status.$statusField -Name "summary" -Context "$SourceLabel $statusField" | Out-Null
    }
    $statusCurrentNumber = Get-R12TaskNumber -TaskId ([string]$activeScope.current_completed_through) -Context "$SourceLabel active_scope.current_completed_through"
    if ($statusCurrentNumber -le 16) {
        if ($Status.real_build_change_status.status -ne "not_started") {
            throw "$SourceLabel cannot claim real build/change started in R12-014 through R12-016."
        }
        if ((Test-HasProperty -Object $Status.real_build_change_status -Name "started") -and [bool]$Status.real_build_change_status.started) {
            throw "$SourceLabel cannot claim real build/change started."
        }
    }
    else {
        if ($Status.real_build_change_status.status -ne "partially_evidenced") {
            throw "$SourceLabel R12-017 must record bounded real build/change evidence as partially_evidenced."
        }
        if (-not (Test-HasProperty -Object $Status.real_build_change_status -Name "started") -or -not [bool]$Status.real_build_change_status.started) {
            throw "$SourceLabel R12-017 real_build_change_status.started must be true."
        }
        $realBuildEvidenceRefs = Assert-StringArray -Value $Status.real_build_change_status.evidence_refs -Context "$SourceLabel real_build_change_status.evidence_refs"
        foreach ($evidenceRef in $realBuildEvidenceRefs) {
            Assert-ExistingEvidenceRef -Ref $evidenceRef -Context "$SourceLabel real_build_change_status.evidence_refs"
        }
        if ($valueGateStatus.real_build_change -ne "partially_evidenced") {
            throw "$SourceLabel R12-017 value_gate_status.real_build_change must be partially_evidenced."
        }
    }

    if (-not (Test-HasProperty -Object $Status.qa_evidence_gate_status -Name "passable_current_state")) {
        throw "$SourceLabel qa_evidence_gate_status is missing required field 'passable_current_state'."
    }
    $qaPassable = Assert-BooleanValue -Value $Status.qa_evidence_gate_status.passable_current_state -Context "$SourceLabel qa_evidence_gate_status.passable_current_state"

    $blockers = Assert-ObjectArray -Value $Status.blockers -Context "$SourceLabel blockers" -AllowEmpty
    foreach ($blocker in $blockers) {
        Assert-RequiredObjectFields -Object $blocker -FieldNames $contract.blocker_required_fields -Context "$SourceLabel blocker"
        Assert-AllowedValue -Value ([string]$blocker.blocking_status) -AllowedValues $script:AllowedBlockingStatuses -Context "$SourceLabel blocker.blocking_status"
        $blockerEvidenceRefs = Assert-StringArray -Value $blocker.evidence_refs -Context "$SourceLabel blocker.evidence_refs"
        foreach ($evidenceRef in $blockerEvidenceRefs) {
            Assert-ExistingEvidenceRef -Ref $evidenceRef -Context "$SourceLabel blocker.evidence_refs"
        }
    }

    $attentionItems = Assert-ObjectArray -Value $Status.attention_items -Context "$SourceLabel attention_items" -AllowEmpty
    foreach ($attentionItem in $attentionItems) {
        Assert-RequiredObjectFields -Object $attentionItem -FieldNames $contract.blocker_required_fields -Context "$SourceLabel attention_item"
        Assert-AllowedValue -Value ([string]$attentionItem.blocking_status) -AllowedValues $script:AllowedBlockingStatuses -Context "$SourceLabel attention_item.blocking_status"
        $attentionEvidenceRefs = Assert-StringArray -Value $attentionItem.evidence_refs -Context "$SourceLabel attention_item.evidence_refs"
        foreach ($evidenceRef in $attentionEvidenceRefs) {
            Assert-ExistingEvidenceRef -Ref $evidenceRef -Context "$SourceLabel attention_item.evidence_refs"
        }
    }

    $nextActions = Assert-ObjectArray -Value $Status.next_actions -Context "$SourceLabel next_actions"
    foreach ($nextAction in $nextActions) {
        Assert-RequiredObjectFields -Object $nextAction -FieldNames $contract.next_action_required_fields -Context "$SourceLabel next_action"
        $nextActionEvidenceRefs = Assert-StringArray -Value $nextAction.evidence_refs -Context "$SourceLabel next_action.evidence_refs"
        foreach ($evidenceRef in $nextActionEvidenceRefs) {
            Assert-ExistingEvidenceRef -Ref $evidenceRef -Context "$SourceLabel next_action.evidence_refs"
        }
    }

    $operatorDecisions = Assert-ObjectArray -Value $Status.operator_decisions_required -Context "$SourceLabel operator_decisions_required" -AllowEmpty
    foreach ($operatorDecision in $operatorDecisions) {
        foreach ($fieldName in @("id", "title", "decision_type", "required_before", "blocking_status", "evidence_refs")) {
            Get-RequiredProperty -Object $operatorDecision -Name $fieldName -Context "$SourceLabel operator_decision" | Out-Null
        }
        $decisionEvidenceRefs = Assert-StringArray -Value $operatorDecision.evidence_refs -Context "$SourceLabel operator_decision.evidence_refs"
        foreach ($evidenceRef in $decisionEvidenceRefs) {
            Assert-ExistingEvidenceRef -Ref $evidenceRef -Context "$SourceLabel operator_decision.evidence_refs"
        }
    }

    $evidenceRefs = Assert-StringArray -Value $Status.evidence_refs -Context "$SourceLabel evidence_refs"
    foreach ($evidenceRef in $evidenceRefs) {
        Assert-ExistingEvidenceRef -Ref $evidenceRef -Context "$SourceLabel evidence_refs"
    }
    Assert-TimestampString -Value $Status.generated_at_utc -Context "$SourceLabel generated_at_utc" | Out-Null
    $nonClaims = Assert-StringArray -Value $Status.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel

    $hasRealExternalEvidence = [bool]$externalRunnerStatus.has_live_r12_external_run -and [bool]$externalRunnerStatus.has_external_artifact_evidence
    if ($valueGateStatus.external_api_runner -in @("partially_evidenced", "evidenced") -and -not $hasRealExternalEvidence) {
        throw "$SourceLabel cannot claim external runner evidence without real external run/result/artifact refs."
    }
    if (([string]$Status.qa_evidence_gate_status.status) -in @("passed", "evidenced") -or $qaPassable) {
        if (-not $hasRealExternalEvidence) {
            throw "$SourceLabel cannot claim current QA gate pass without real external evidence."
        }
    }
    if ($valueGateStatus.operator_control_room -eq "evidenced") {
        throw "$SourceLabel cannot claim productized or fully evidenced operator control-room behavior in this slice."
    }

    $blockedOrRefused = @($contract.value_gate_names | Where-Object { $valueGateStatus.$_ -in @("blocked", "refused") })
    if (([string]$Status.qa_evidence_gate_status.status) -in @("blocked", "refused", "not_passable_current_state")) {
        $blockedOrRefused += "qa_evidence_gate_status"
    }
    if ($blockedOrRefused.Count -gt 0 -and @($blockers | Where-Object { $_.blocking_status -eq "blocking" }).Count -eq 0) {
        throw "$SourceLabel missing blockers or attention items for blocked/refused gate status."
    }

    $claimLines = New-Object System.Collections.Generic.List[string]
    $claimLines.Add([string]$Status.current_phase) | Out-Null
    $claimLines.Add([string]$activeScope.scope_summary) | Out-Null
    foreach ($nonClaim in $nonClaims) { $claimLines.Add($nonClaim) | Out-Null }
    foreach ($blocker in $blockers) {
        $claimLines.Add([string]$blocker.title) | Out-Null
        $claimLines.Add([string]$blocker.explanation) | Out-Null
    }
    foreach ($nextAction in $nextActions) {
        $claimLines.Add([string]$nextAction.title) | Out-Null
        $claimLines.Add([string]$nextAction.description) | Out-Null
    }
    Assert-NoForbiddenStatusClaim -Lines @($claimLines) -Context $SourceLabel

    $PSCmdlet.WriteObject([pscustomobject][ordered]@{
            StatusId = $Status.status_id
            Repository = $Status.repository
            Branch = $Status.branch
            Head = $Status.head
            Tree = $Status.tree
            CurrentCompletedThrough = $activeScope.current_completed_through
            PlannedTaskCount = $plannedTasks.Count
            ExternalApiRunnerGate = $valueGateStatus.external_api_runner
            ActionableQaGate = $valueGateStatus.actionable_qa
            OperatorControlRoomGate = $valueGateStatus.operator_control_room
            RealBuildChangeGate = $valueGateStatus.real_build_change
            QaEvidenceGateStatus = $Status.qa_evidence_gate_status.status
            BlockerCount = $blockers.Count
            NextActionCount = $nextActions.Count
        }, $false)
}

function Test-ControlRoomStatus {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$StatusPath
    )

    $status = Get-JsonDocument -Path $StatusPath -Label "Control-room status"
    return Test-ControlRoomStatusObject -Status $status -SourceLabel "Control-room status"
}

function Invoke-GitLines {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & git -C (Get-RepositoryRoot) @Arguments 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }

    if ($exitCode -ne 0) {
        throw "Git command failed: git $($Arguments -join ' ')"
    }

    return @($output | ForEach-Object { [string]$_ })
}

function New-R12TaskArray {
    param(
        [Parameter(Mandatory = $true)]
        [int]$Start,
        [Parameter(Mandatory = $true)]
        [int]$End
    )

    if ($Start -gt $End) {
        return @()
    }

    $items = New-Object System.Collections.Generic.List[string]
    for ($taskNumber = $Start; $taskNumber -le $End; $taskNumber += 1) {
        $items.Add((Get-R12TaskId -TaskNumber $taskNumber)) | Out-Null
    }

    return @($items)
}

function New-ControlRoomStatus {
    [CmdletBinding()]
    param(
        [string]$OutputPath = "",
        [string]$CompletedThroughTask = "R12-017",
        [switch]$Overwrite
    )

    $branch = (@(Invoke-GitLines -Arguments @("branch", "--show-current")))[0].Trim()
    $head = (@(Invoke-GitLines -Arguments @("rev-parse", "HEAD")))[0].Trim()
    $tree = (@(Invoke-GitLines -Arguments @("rev-parse", "HEAD^{tree}")))[0].Trim()
    $completedThroughNumber = Get-R12TaskNumber -TaskId $CompletedThroughTask -Context "CompletedThroughTask"
    if ($completedThroughNumber -lt 14 -or $completedThroughNumber -gt 17) {
        throw "CompletedThroughTask must be R12-014, R12-015, R12-016, or R12-017 for this slice."
    }

    $completedTasks = New-R12TaskArray -Start 1 -End $completedThroughNumber
    $plannedTasks = if ($completedThroughNumber -lt 21) { New-R12TaskArray -Start ($completedThroughNumber + 1) -End 21 } else { @() }

    $coreEvidenceRefs = @(
        "contracts/control_room/control_room_status.contract.json",
        "tools/ControlRoomStatus.psm1",
        "tools/export_control_room_status.ps1",
        "contracts/control_room/control_room_view.contract.json",
        "tools/render_control_room_view.psm1",
        "contracts/control_room/operator_decision_queue.contract.json",
        "tools/OperatorDecisionQueue.psm1",
        "tools/export_operator_decision_queue.ps1",
        "contracts/control_room/control_room_refresh_result.contract.json",
        "tools/ControlRoomRefresh.psm1",
        "tools/refresh_control_room.ps1",
        "tests/test_control_room_refresh.ps1",
        "contracts/actionable_qa/cycle_qa_evidence_gate.contract.json",
        "tools/ActionableQaEvidenceGate.psm1",
        "governance/R12_EXTERNAL_API_RUNNER_ACTIONABLE_QA_AND_CONTROL_ROOM_WORKFLOW_PILOT.md"
    )

    $inputCompletedThrough = if ($completedThroughNumber -ge 17) { "R12-016" } else { "R12-013" }
    $plannedSummary = if ($CompletedThroughTask -eq "R12-017") {
        "R12-018 through R12-021 remain planned only."
    }
    else {
        "R12-017 through R12-021 remain planned only when $CompletedThroughTask is R12-016."
    }
    $currentPhase = if ($CompletedThroughTask -eq "R12-017") { "bounded_control_room_refresh_cycle" } else { "operator_control_room_foundation_slice" }
    $realBuildGateStatus = if ($CompletedThroughTask -eq "R12-017") { "partially_evidenced" } else { "not_started" }
    $realBuildStatus = if ($CompletedThroughTask -eq "R12-017") { "partially_evidenced" } else { "not_started" }
    $realBuildStarted = $CompletedThroughTask -eq "R12-017"
    $realBuildSummary = if ($CompletedThroughTask -eq "R12-017") {
        "R12-017 added and ran one bounded one-command operator control-room refresh workflow that regenerates status, Markdown view, and decision queue artifacts from explicit repo identity."
    }
    else {
        "R12-017 real useful build/change cycle has not started in this prompt."
    }
    $realBuildEvidenceRefs = if ($CompletedThroughTask -eq "R12-017") {
        @(
            "contracts/control_room/control_room_refresh_result.contract.json",
            "tools/ControlRoomRefresh.psm1",
            "tools/refresh_control_room.ps1",
            "tests/test_control_room_refresh.ps1"
        )
    }
    else {
        @()
    }

    $status = [pscustomobject][ordered]@{
        contract_version = "v1"
        artifact_type = "control_room_status"
        status_id = "r12-control-room-status-" + [guid]::NewGuid().ToString("N")
        repository = $script:R12RepositoryName
        branch = $branch
        head = $head
        tree = $tree
        active_milestone = $script:R12Milestone
        active_scope = [pscustomobject][ordered]@{
            input_completed_through = $inputCompletedThrough
            current_completed_through = $CompletedThroughTask
            planned_remaining = @($plannedTasks)
            scope_summary = "R12 is active through $CompletedThroughTask only; $plannedSummary"
        }
        completed_tasks = @($completedTasks)
        planned_tasks = @($plannedTasks)
        current_phase = $currentPhase
        value_gate_status = [pscustomobject][ordered]@{
            external_api_runner = "foundation_present"
            actionable_qa = "foundation_present"
            operator_control_room = "foundation_present"
            real_build_change = $realBuildGateStatus
        }
        external_runner_status = [pscustomobject][ordered]@{
            status = "blocked"
            summary = "External runner foundations exist, but no live R12 external run/result and no external artifact evidence are captured for the current R12 state."
            has_live_r12_external_run = $false
            has_external_artifact_evidence = $false
            evidence_refs = @(
                "contracts/external_runner/external_runner_result.contract.json",
                "contracts/external_runner/external_artifact_evidence_packet.contract.json",
                "tools/ExternalRunnerGitHubActions.psm1",
                "tools/ExternalArtifactEvidence.psm1"
            )
            blocking_reason = "A real external runner result and external artifact evidence are required before final QA/evidence gate pass or R12 closeout."
        }
        actionable_qa_status = [pscustomobject][ordered]@{
            status = "foundation_present"
            summary = "Actionable QA report, fix queue, and cycle QA evidence gate foundations exist; current final gate remains blocked on real external evidence."
            evidence_refs = @(
                "contracts/actionable_qa/actionable_qa_report.contract.json",
                "contracts/actionable_qa/actionable_qa_fix_queue.contract.json",
                "contracts/actionable_qa/cycle_qa_evidence_gate.contract.json",
                "tools/ActionableQa.psm1",
                "tools/ActionableQaFixQueue.psm1",
                "tools/ActionableQaEvidenceGate.psm1"
            )
        }
        control_room_status = [pscustomobject][ordered]@{
            status = "foundation_present"
            summary = "Bounded JSON status, Markdown view, operator decision queue, and one-command refresh workflow are generated for operator review; this is not productized control-room behavior."
            status_model_ref = "state/control_room/r12_current/control_room_status.json"
            markdown_view_ref = "state/control_room/r12_current/control_room.md"
            decision_queue_ref = "state/control_room/r12_current/operator_decision_queue.json"
            refresh_result_ref = "state/control_room/r12_current/control_room_refresh_result.json"
        }
        real_build_change_status = [pscustomobject][ordered]@{
            status = $realBuildStatus
            summary = $realBuildSummary
            started = $realBuildStarted
            evidence_refs = @($realBuildEvidenceRefs)
        }
        qa_evidence_gate_status = [pscustomobject][ordered]@{
            status = "blocked"
            summary = "Current real QA evidence gate cannot pass without real external runner result and external artifact evidence."
            passable_current_state = $false
            missing_required_evidence = @("external_runner_result_ref", "external_artifact_evidence_ref")
            evidence_refs = @(
                "contracts/actionable_qa/cycle_qa_evidence_gate.contract.json",
                "tools/ActionableQaEvidenceGate.psm1"
            )
        }
        blockers = @(
            [pscustomobject][ordered]@{
                id = "blocker-r12-external-evidence"
                severity = "high"
                title = "Real R12 external runner evidence is missing"
                explanation = "No live R12 external runner result and no external artifact evidence are captured for the current branch/head/tree, so the final QA/evidence gate remains blocked."
                evidence_refs = @(
                    "contracts/external_runner/external_runner_result.contract.json",
                    "contracts/external_runner/external_artifact_evidence_packet.contract.json",
                    "contracts/actionable_qa/cycle_qa_evidence_gate.contract.json"
                )
                recommended_next_action = "Run the authorized external runner/replay slice later and import real artifact evidence before attempting final QA/evidence pass."
                blocking_status = "blocking"
            }
        )
        attention_items = @(
            [pscustomobject][ordered]@{
                id = "attention-control-room-boundary"
                severity = "medium"
                title = "Control-room surface is bounded foundation only"
                explanation = "The generated JSON and Markdown make the current posture operator-readable, but they do not constitute a full UI app or productized workflow UI."
                evidence_refs = @("contracts/control_room/control_room_status.contract.json")
                recommended_next_action = "Review the generated status/view/queue as static evidence only."
                blocking_status = "advisory"
            },
            [pscustomobject][ordered]@{
                id = "attention-r12-018-pending"
                severity = "high"
                title = "R12-018 remains pending for a separate fresh Codex thread"
                explanation = "R12-018 is not done and must be executed separately from committed repo truth using the generated handoff packet when it exists."
                evidence_refs = @("contracts/bootstrap/fresh_thread_bootstrap_packet.contract.json", "tools/FreshThreadBootstrap.psm1")
                recommended_next_action = "Use the generated R12-018 prompt in a new Codex thread only."
                blocking_status = "advisory"
            },
            [pscustomobject][ordered]@{
                id = "attention-no-successor"
                severity = "high"
                title = "No R13 or successor milestone is authorized"
                explanation = "R12 remains active, R12 closeout is not claimed, and no successor milestone is opened."
                evidence_refs = @("governance/R12_EXTERNAL_API_RUNNER_ACTIONABLE_QA_AND_CONTROL_ROOM_WORKFLOW_PILOT.md")
                recommended_next_action = "Keep successor work blocked until explicit future authorization exists."
                blocking_status = "advisory"
            }
        )
        next_actions = @(
            [pscustomobject][ordered]@{
                id = "next-r12-018-fresh-thread"
                task_id = "R12-018"
                title = "Run R12-018 fresh-thread restart proof from committed handoff packet"
                action_type = "fresh_thread_handoff"
                description = "Use the generated bootstrap packet and next prompt in a separate fresh Codex thread; do not start R12-019 or later in that thread."
                required_before = "starting_R12_018"
                evidence_refs = @("contracts/bootstrap/fresh_thread_bootstrap_packet.contract.json", "tools/FreshThreadBootstrap.psm1")
            },
            [pscustomobject][ordered]@{
                id = "next-real-external-evidence"
                task_id = "R12-019"
                title = "Capture real external evidence before final QA pass"
                action_type = "external_evidence_required"
                description = "A later authorized slice must capture real external runner result and artifact evidence tied to exact branch/head/tree before final gate pass or closeout."
                required_before = "final_qa_evidence_gate_pass"
                evidence_refs = @(
                    "contracts/external_runner/external_runner_result.contract.json",
                    "contracts/external_runner/external_artifact_evidence_packet.contract.json"
                )
            }
        )
        operator_decisions_required = @(
            [pscustomobject][ordered]@{
                id = "decision-external-evidence-required"
                title = "Real external evidence is required before final QA/evidence pass"
                decision_type = "external_evidence_required"
                required_before = "final_qa_evidence_gate_pass"
                blocking_status = "blocking"
                evidence_refs = @("contracts/actionable_qa/cycle_qa_evidence_gate.contract.json")
            },
            [pscustomobject][ordered]@{
                id = "decision-control-room-review"
                title = "Review generated control-room status and Markdown view"
                decision_type = "approval_required"
                required_before = "next_slice_authorization"
                blocking_status = "non_blocking"
                evidence_refs = @("contracts/control_room/control_room_status.contract.json")
            },
            [pscustomobject][ordered]@{
                id = "decision-r12-018-fresh-thread"
                title = "Execute R12-018 only from a separate fresh Codex thread"
                decision_type = "next_slice_authorization"
                required_before = "starting_R12_018"
                blocking_status = "blocking"
                evidence_refs = @("contracts/bootstrap/fresh_thread_bootstrap_packet.contract.json", "tools/FreshThreadBootstrap.psm1")
            },
            [pscustomobject][ordered]@{
                id = "decision-no-r13-successor"
                title = "Keep R13 or successor milestone unauthorized"
                decision_type = "blocked_refusal"
                required_before = "any_successor_milestone_opening"
                blocking_status = "blocking"
                evidence_refs = @("governance/R12_EXTERNAL_API_RUNNER_ACTIONABLE_QA_AND_CONTROL_ROOM_WORKFLOW_PILOT.md")
            }
        )
        evidence_refs = @($coreEvidenceRefs | Sort-Object -Unique)
        generated_at_utc = Get-UtcTimestamp
        non_claims = @(
            "no productized control-room behavior",
            "no full UI app",
            "no production runtime",
            "no R12 closeout",
            "no final-state replay",
            "no full R12 value-gate delivery",
            "no final QA pass for R12 closeout",
            "no R13 authorization",
            "no broad autonomy",
            "no solved Codex reliability",
            "no broad CI/product coverage"
        )
    }

    Test-ControlRoomStatusObject -Status $status -SourceLabel "Control-room status draft" | Out-Null

    if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
        Write-JsonDocument -Path (Resolve-RepositoryPath -PathValue $OutputPath) -Document $status -Overwrite:$Overwrite
    }

    $PSCmdlet.WriteObject($status, $false)
}

Export-ModuleMember -Function Get-ControlRoomStatusContract, Test-ControlRoomStatusObject, Test-ControlRoomStatus, New-ControlRoomStatus
