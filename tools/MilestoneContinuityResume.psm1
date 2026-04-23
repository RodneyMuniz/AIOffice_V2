Set-StrictMode -Version Latest

$faultManagementModule = Import-Module (Join-Path $PSScriptRoot "FaultManagement.psm1") -Force -PassThru
$milestoneContinuityModule = Import-Module (Join-Path $PSScriptRoot "MilestoneContinuity.psm1") -Force -PassThru

$testFaultManagementEventContract = $faultManagementModule.ExportedCommands["Test-FaultManagementEventContract"]
$getFaultManagementEvent = $faultManagementModule.ExportedCommands["Get-FaultManagementEvent"]
$testMilestoneContinuityCheckpointContract = $milestoneContinuityModule.ExportedCommands["Test-MilestoneContinuityCheckpointContract"]
$testMilestoneContinuityHandoffPacketContract = $milestoneContinuityModule.ExportedCommands["Test-MilestoneContinuityHandoffPacketContract"]
$getMilestoneContinuityArtifact = $milestoneContinuityModule.ExportedCommands["Get-MilestoneContinuityArtifact"]

function Resolve-ArtifactPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArtifactPath
    )

    if ([System.IO.Path]::IsPathRooted($ArtifactPath)) {
        $resolvedPath = $ArtifactPath
    }
    else {
        $resolvedPath = Join-Path (Get-Location) $ArtifactPath
    }

    if (-not (Test-Path -LiteralPath $resolvedPath)) {
        throw "Resume-from-fault artifact path '$ArtifactPath' does not exist."
    }

    return (Resolve-Path -LiteralPath $resolvedPath).Path
}

function Get-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    try {
        return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    }
    catch {
        throw "$Label at '$Path' is not valid JSON. $($_.Exception.Message)"
    }
}

function Write-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        $Document,
        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )

    $resolvedOutputPath = if ([System.IO.Path]::IsPathRooted($OutputPath)) { $OutputPath } else { Join-Path (Get-Location) $OutputPath }
    $parentPath = Split-Path -Parent $resolvedOutputPath
    if (-not [string]::IsNullOrWhiteSpace($parentPath)) {
        New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    }

    $Document | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $resolvedOutputPath -Encoding ascii
    return (Resolve-Path -LiteralPath $resolvedOutputPath).Path
}

function Test-HasProperty {
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    return $null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name
}

function Get-RequiredProperty {
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

    Write-Output -NoEnumerate ($Object.$Name)
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

function Assert-RegexMatch {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Pattern,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -notmatch $Pattern) {
        throw "$Context does not match the required pattern."
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
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [int]$MinimumCount = 0
    )

    if ($null -eq $Value -or $Value -is [string] -or $Value -isnot [System.Array]) {
        throw "$Context must be an array."
    }

    $items = @($Value)
    if ($items.Count -lt $MinimumCount) {
        throw "$Context must contain at least $MinimumCount item(s)."
    }

    foreach ($item in $items) {
        Assert-NonEmptyString -Value $item -Context "$Context item" | Out-Null
    }

    return $items
}

function Assert-RepoRelativeExistingPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RelativePath,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ([System.IO.Path]::IsPathRooted($RelativePath)) {
        throw "$Context must be repo-relative, not absolute."
    }

    $repoRoot = (Resolve-Path -LiteralPath (Get-RepositoryRoot)).Path
    $candidatePath = Join-Path $repoRoot $RelativePath
    if (-not (Test-Path -LiteralPath $candidatePath)) {
        throw "$Context path '$RelativePath' does not exist."
    }

    $resolvedPath = (Resolve-Path -LiteralPath $candidatePath).Path
    if (-not $resolvedPath.StartsWith($repoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "$Context path '$RelativePath' resolves outside the repository root."
    }

    return [pscustomobject]@{
        RelativePath = $RelativePath
        ResolvedPath = $resolvedPath
    }
}

function Get-RepositoryRoot {
    return (Split-Path -Parent $PSScriptRoot)
}

function Get-MilestoneContinuityFoundationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_continuity\foundation.contract.json") -Label "Milestone continuity foundation contract"
}

function Get-MilestoneContinuityResumeRequestContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_continuity\resume_from_fault_request.contract.json") -Label "Milestone continuity resume request contract"
}

function Get-MilestoneContinuityResumeResultContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_continuity\resume_from_fault_result.contract.json") -Label "Milestone continuity resume result contract"
}

function Validate-CycleContext {
    param(
        [Parameter(Mandatory = $true)]
        $CycleContext,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [string]$ContextPrefix
    )

    foreach ($fieldName in @($Contract.cycle_context_required_fields)) {
        Get-RequiredProperty -Object $CycleContext -Name $fieldName -Context $ContextPrefix | Out-Null
    }

    $cycleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $CycleContext -Name "cycle_id" -Context $ContextPrefix) -Context "$ContextPrefix.cycle_id"
    Assert-RegexMatch -Value $cycleId -Pattern $Foundation.identifier_pattern -Context "$ContextPrefix.cycle_id"

    $milestoneId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $CycleContext -Name "milestone_id" -Context $ContextPrefix) -Context "$ContextPrefix.milestone_id"
    Assert-RegexMatch -Value $milestoneId -Pattern $Foundation.identifier_pattern -Context "$ContextPrefix.milestone_id"

    $milestoneTitle = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $CycleContext -Name "milestone_title" -Context $ContextPrefix) -Context "$ContextPrefix.milestone_title"

    return [pscustomobject]@{
        CycleId = $cycleId
        MilestoneId = $milestoneId
        MilestoneTitle = $milestoneTitle
    }
}

function Validate-ScopeContext {
    param(
        [Parameter(Mandatory = $true)]
        $ScopeContext,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [string]$ContextPrefix
    )

    foreach ($fieldName in @($Contract.scope_context_required_fields)) {
        Get-RequiredProperty -Object $ScopeContext -Name $fieldName -Context $ContextPrefix | Out-Null
    }

    $scopeLevel = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ScopeContext -Name "scope_level" -Context $ContextPrefix) -Context "$ContextPrefix.scope_level"
    Assert-AllowedValue -Value $scopeLevel -AllowedValues @($Foundation.allowed_scope_levels) -Context "$ContextPrefix.scope_level"

    $taskId = $null
    $segmentId = $null

    if (Test-HasProperty -Object $ScopeContext -Name "task_id") {
        $taskId = Assert-NonEmptyString -Value $ScopeContext.task_id -Context "$ContextPrefix.task_id"
        Assert-RegexMatch -Value $taskId -Pattern $Foundation.identifier_pattern -Context "$ContextPrefix.task_id"
    }

    if (Test-HasProperty -Object $ScopeContext -Name "segment_id") {
        $segmentId = Assert-NonEmptyString -Value $ScopeContext.segment_id -Context "$ContextPrefix.segment_id"
        Assert-RegexMatch -Value $segmentId -Pattern $Foundation.identifier_pattern -Context "$ContextPrefix.segment_id"
    }

    if ($scopeLevel -eq "cycle") {
        if ($null -ne $taskId -or $null -ne $segmentId) {
            throw "$ContextPrefix must not include task_id or segment_id when scope_level is 'cycle'."
        }
    }

    if ($scopeLevel -eq "task" -and $null -eq $taskId) {
        throw "$ContextPrefix.task_id is required when scope_level is 'task'."
    }

    return [pscustomobject]@{
        ScopeLevel = $scopeLevel
        TaskId = $taskId
        SegmentId = $segmentId
    }
}

function Validate-RepositoryContext {
    param(
        [Parameter(Mandatory = $true)]
        $RepositoryContext,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [string]$ContextPrefix
    )

    foreach ($fieldName in @($Contract.repository_required_fields)) {
        Get-RequiredProperty -Object $RepositoryContext -Name $fieldName -Context $ContextPrefix | Out-Null
    }

    $repositoryName = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RepositoryContext -Name "repository_name" -Context $ContextPrefix) -Context "$ContextPrefix.repository_name"
    if ($repositoryName -ne $Foundation.repository_name) {
        throw "$ContextPrefix.repository_name must equal '$($Foundation.repository_name)'."
    }

    return $repositoryName
}

function Validate-GitContext {
    param(
        [Parameter(Mandatory = $true)]
        $GitContext,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [string]$ContextPrefix
    )

    foreach ($fieldName in @($Contract.git_context_required_fields)) {
        Get-RequiredProperty -Object $GitContext -Name $fieldName -Context $ContextPrefix | Out-Null
    }

    $branch = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $GitContext -Name "branch" -Context $ContextPrefix) -Context "$ContextPrefix.branch"
    Assert-RegexMatch -Value $branch -Pattern $Foundation.branch_pattern -Context "$ContextPrefix.branch"

    $headCommit = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $GitContext -Name "head_commit" -Context $ContextPrefix) -Context "$ContextPrefix.head_commit"
    Assert-RegexMatch -Value $headCommit -Pattern $Foundation.git_object_pattern -Context "$ContextPrefix.head_commit"

    $treeId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $GitContext -Name "tree_id" -Context $ContextPrefix) -Context "$ContextPrefix.tree_id"
    Assert-RegexMatch -Value $treeId -Pattern $Foundation.git_object_pattern -Context "$ContextPrefix.tree_id"

    return [pscustomobject]@{
        Branch = $branch
        HeadCommit = $headCommit
        TreeId = $treeId
    }
}

function Validate-Supervision {
    param(
        [Parameter(Mandatory = $true)]
        $Supervision,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [string]$ContextPrefix
    )

    foreach ($fieldName in @($Contract.supervision_required_fields)) {
        Get-RequiredProperty -Object $Supervision -Name $fieldName -Context $ContextPrefix | Out-Null
    }

    $mode = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Supervision -Name "mode" -Context $ContextPrefix) -Context "$ContextPrefix.mode"
    Assert-AllowedValue -Value $mode -AllowedValues @($Foundation.allowed_supervision_modes) -Context "$ContextPrefix.mode"

    $operatorAuthority = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Supervision -Name "operator_authority" -Context $ContextPrefix) -Context "$ContextPrefix.operator_authority"
    Assert-RegexMatch -Value $operatorAuthority -Pattern $Foundation.operator_pattern -Context "$ContextPrefix.operator_authority"

    $resumeAuthorityState = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Supervision -Name "resume_authority_state" -Context $ContextPrefix) -Context "$ContextPrefix.resume_authority_state"
    Assert-AllowedValue -Value $resumeAuthorityState -AllowedValues @($Foundation.allowed_resume_authority_states) -Context "$ContextPrefix.resume_authority_state"

    if ($resumeAuthorityState -ne "operator_review_required") {
        throw "$ContextPrefix.resume_authority_state must remain 'operator_review_required' for supervised resume-from-fault."
    }

    return [pscustomobject]@{
        Mode = $mode
        OperatorAuthority = $operatorAuthority
        ResumeAuthorityState = $resumeAuthorityState
    }
}

function Validate-AuthoritativeRefs {
    param(
        [Parameter(Mandatory = $true)]
        $AuthoritativeRefs,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        [string]$ContextPrefix
    )

    $resolvedRefs = [ordered]@{}
    foreach ($fieldName in @($Foundation.required_authoritative_ref_fields)) {
        $relativePath = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $AuthoritativeRefs -Name $fieldName -Context $ContextPrefix) -Context "$ContextPrefix.$fieldName"
        $resolvedRefs[$fieldName] = Assert-RepoRelativeExistingPath -RelativePath $relativePath -Context "$ContextPrefix.$fieldName"
    }

    return [pscustomobject]$resolvedRefs
}

function Validate-FaultEventReference {
    param(
        [Parameter(Mandatory = $true)]
        $FaultEventRef,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [string]$ContextPrefix
    )

    foreach ($fieldName in @($Contract.fault_event_ref_required_fields)) {
        Get-RequiredProperty -Object $FaultEventRef -Name $fieldName -Context $ContextPrefix | Out-Null
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $FaultEventRef -Name "record_type" -Context $ContextPrefix) -Context "$ContextPrefix.record_type"
    if ($recordType -ne $Foundation.fault_event_record_type) {
        throw "$ContextPrefix.record_type must equal '$($Foundation.fault_event_record_type)'."
    }

    $eventId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $FaultEventRef -Name "event_id" -Context $ContextPrefix) -Context "$ContextPrefix.event_id"
    Assert-RegexMatch -Value $eventId -Pattern $Foundation.identifier_pattern -Context "$ContextPrefix.event_id"

    $eventPathInfo = Assert-RepoRelativeExistingPath -RelativePath (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $FaultEventRef -Name "event_path" -Context $ContextPrefix) -Context "$ContextPrefix.event_path") -Context "$ContextPrefix.event_path"
    $validation = & $testFaultManagementEventContract -EventPath $eventPathInfo.ResolvedPath
    $document = & $getFaultManagementEvent -EventPath $eventPathInfo.ResolvedPath
    if ($validation.EventId -ne $eventId) {
        throw "$ContextPrefix.event_id does not match the referenced fault event artifact."
    }

    return [pscustomobject]@{
        EventId = $validation.EventId
        EventPath = $eventPathInfo.RelativePath
        Validation = $validation
        Document = $document
    }
}

function Validate-CheckpointReference {
    param(
        [Parameter(Mandatory = $true)]
        $CheckpointRef,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [string]$ContextPrefix
    )

    foreach ($fieldName in @($Contract.checkpoint_ref_required_fields)) {
        Get-RequiredProperty -Object $CheckpointRef -Name $fieldName -Context $ContextPrefix | Out-Null
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $CheckpointRef -Name "record_type" -Context $ContextPrefix) -Context "$ContextPrefix.record_type"
    if ($recordType -ne $Foundation.checkpoint_record_type) {
        throw "$ContextPrefix.record_type must equal '$($Foundation.checkpoint_record_type)'."
    }

    $checkpointId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $CheckpointRef -Name "checkpoint_id" -Context $ContextPrefix) -Context "$ContextPrefix.checkpoint_id"
    Assert-RegexMatch -Value $checkpointId -Pattern $Foundation.identifier_pattern -Context "$ContextPrefix.checkpoint_id"

    $checkpointPathInfo = Assert-RepoRelativeExistingPath -RelativePath (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $CheckpointRef -Name "checkpoint_path" -Context $ContextPrefix) -Context "$ContextPrefix.checkpoint_path") -Context "$ContextPrefix.checkpoint_path"
    $validation = & $testMilestoneContinuityCheckpointContract -ArtifactPath $checkpointPathInfo.ResolvedPath
    $document = & $getMilestoneContinuityArtifact -ArtifactPath $checkpointPathInfo.ResolvedPath
    if ($validation.ArtifactId -ne $checkpointId) {
        throw "$ContextPrefix.checkpoint_id does not match the referenced checkpoint artifact."
    }

    return [pscustomobject]@{
        CheckpointId = $validation.ArtifactId
        CheckpointPath = $checkpointPathInfo.RelativePath
        Validation = $validation
        Document = $document
    }
}

function Validate-HandoffReference {
    param(
        [Parameter(Mandatory = $true)]
        $HandoffRef,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [string]$ContextPrefix
    )

    foreach ($fieldName in @($Contract.handoff_packet_ref_required_fields)) {
        Get-RequiredProperty -Object $HandoffRef -Name $fieldName -Context $ContextPrefix | Out-Null
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $HandoffRef -Name "record_type" -Context $ContextPrefix) -Context "$ContextPrefix.record_type"
    if ($recordType -ne $Foundation.handoff_packet_record_type) {
        throw "$ContextPrefix.record_type must equal '$($Foundation.handoff_packet_record_type)'."
    }

    $handoffId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $HandoffRef -Name "handoff_id" -Context $ContextPrefix) -Context "$ContextPrefix.handoff_id"
    Assert-RegexMatch -Value $handoffId -Pattern $Foundation.identifier_pattern -Context "$ContextPrefix.handoff_id"

    $handoffPathInfo = Assert-RepoRelativeExistingPath -RelativePath (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $HandoffRef -Name "handoff_path" -Context $ContextPrefix) -Context "$ContextPrefix.handoff_path") -Context "$ContextPrefix.handoff_path"
    $validation = & $testMilestoneContinuityHandoffPacketContract -ArtifactPath $handoffPathInfo.ResolvedPath
    $document = & $getMilestoneContinuityArtifact -ArtifactPath $handoffPathInfo.ResolvedPath
    if ($validation.ArtifactId -ne $handoffId) {
        throw "$ContextPrefix.handoff_id does not match the referenced handoff artifact."
    }

    return [pscustomobject]@{
        HandoffId = $validation.ArtifactId
        HandoffPath = $handoffPathInfo.RelativePath
        Validation = $validation
        Document = $document
    }
}

function Assert-Alignment {
    param(
        [Parameter(Mandatory = $true)]
        $FaultEventReference,
        [Parameter(Mandatory = $true)]
        $CheckpointReference,
        [Parameter(Mandatory = $true)]
        $HandoffReference,
        [Parameter(Mandatory = $true)]
        $CycleContext,
        [Parameter(Mandatory = $true)]
        $ScopeContext,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryName,
        [Parameter(Mandatory = $true)]
        $GitContext,
        [Parameter(Mandatory = $true)]
        $Supervision,
        [Parameter(Mandatory = $true)]
        [string]$ContextLabel
    )

    $faultEventDocument = $FaultEventReference.Document
    $checkpointDocument = $CheckpointReference.Document
    $handoffDocument = $HandoffReference.Document

    if ($faultEventReference.EventId -ne $CheckpointReference.Document.fault_event_ref.event_id -or $faultEventReference.EventId -ne $HandoffReference.Document.fault_event_ref.event_id) {
        throw "$ContextLabel fault-event lineage must match across the referenced checkpoint and handoff packet."
    }

    if ($CheckpointReference.CheckpointId -ne $handoffDocument.checkpoint_ref.checkpoint_id) {
        throw "$ContextLabel checkpoint lineage must match the referenced handoff packet."
    }

    if ($CycleContext.CycleId -ne $faultEventDocument.cycle_context.cycle_id -or $CycleContext.CycleId -ne $checkpointDocument.cycle_context.cycle_id -or $CycleContext.CycleId -ne $handoffDocument.cycle_context.cycle_id) {
        throw "$ContextLabel.cycle_context.cycle_id must match the referenced fault, checkpoint, and handoff artifacts."
    }

    if ($CycleContext.MilestoneId -ne $faultEventDocument.cycle_context.milestone_id -or $CycleContext.MilestoneId -ne $checkpointDocument.cycle_context.milestone_id -or $CycleContext.MilestoneId -ne $handoffDocument.cycle_context.milestone_id) {
        throw "$ContextLabel.cycle_context.milestone_id must match the referenced fault, checkpoint, and handoff artifacts."
    }

    if ($CycleContext.MilestoneTitle -ne $faultEventDocument.cycle_context.milestone_title -or $CycleContext.MilestoneTitle -ne $checkpointDocument.cycle_context.milestone_title -or $CycleContext.MilestoneTitle -ne $handoffDocument.cycle_context.milestone_title) {
        throw "$ContextLabel.cycle_context.milestone_title must match the referenced fault, checkpoint, and handoff artifacts."
    }

    if ($ScopeContext.ScopeLevel -ne $faultEventDocument.affected_scope.scope_level -or $ScopeContext.ScopeLevel -ne $checkpointDocument.scope_context.scope_level -or $ScopeContext.ScopeLevel -ne $handoffDocument.scope_context.scope_level) {
        throw "$ContextLabel.scope_context.scope_level must match the referenced fault, checkpoint, and handoff artifacts."
    }

    if ($ScopeContext.TaskId -ne $faultEventDocument.affected_scope.task_id -or $ScopeContext.TaskId -ne $checkpointDocument.scope_context.task_id -or $ScopeContext.TaskId -ne $handoffDocument.scope_context.task_id) {
        throw "$ContextLabel.scope_context.task_id must match the referenced fault, checkpoint, and handoff artifacts."
    }

    if ($ScopeContext.SegmentId -ne $faultEventDocument.affected_scope.segment_id -or $ScopeContext.SegmentId -ne $checkpointDocument.scope_context.segment_id -or $ScopeContext.SegmentId -ne $handoffDocument.scope_context.segment_id) {
        throw "$ContextLabel.scope_context.segment_id must match the referenced fault, checkpoint, and handoff artifacts."
    }

    if ($RepositoryName -ne $faultEventDocument.repository.repository_name -or $RepositoryName -ne $checkpointDocument.repository.repository_name -or $RepositoryName -ne $handoffDocument.repository.repository_name) {
        throw "$ContextLabel.repository.repository_name must match the referenced fault, checkpoint, and handoff artifacts."
    }

    if ($GitContext.Branch -ne $faultEventDocument.git_context.branch -or $GitContext.Branch -ne $checkpointDocument.git_context.branch -or $GitContext.Branch -ne $handoffDocument.git_context.branch) {
        throw "$ContextLabel.git_context.branch must match the referenced fault, checkpoint, and handoff artifacts."
    }

    if ($GitContext.HeadCommit -ne $faultEventDocument.git_context.head_commit -or $GitContext.HeadCommit -ne $checkpointDocument.git_context.head_commit -or $GitContext.HeadCommit -ne $handoffDocument.git_context.head_commit) {
        throw "$ContextLabel.git_context.head_commit must match the referenced fault, checkpoint, and handoff artifacts."
    }

    if ($GitContext.TreeId -ne $faultEventDocument.git_context.tree_id -or $GitContext.TreeId -ne $checkpointDocument.git_context.tree_id -or $GitContext.TreeId -ne $handoffDocument.git_context.tree_id) {
        throw "$ContextLabel.git_context.tree_id must match the referenced fault, checkpoint, and handoff artifacts."
    }

    if ($Supervision.Mode -ne $faultEventDocument.supervision.mode -or $Supervision.Mode -ne $checkpointDocument.supervision.mode -or $Supervision.Mode -ne $handoffDocument.supervision.mode) {
        throw "$ContextLabel.supervision.mode must match the referenced fault, checkpoint, and handoff artifacts."
    }

    if ($Supervision.OperatorAuthority -ne $faultEventDocument.supervision.operator_authority -or $Supervision.OperatorAuthority -ne $checkpointDocument.supervision.operator_authority -or $Supervision.OperatorAuthority -ne $handoffDocument.supervision.operator_authority) {
        throw "$ContextLabel.supervision.operator_authority must match the referenced fault, checkpoint, and handoff artifacts."
    }

    if ($Supervision.ResumeAuthorityState -ne $faultEventDocument.supervision.resume_authority_state -or $Supervision.ResumeAuthorityState -ne $checkpointDocument.supervision.resume_authority_state -or $Supervision.ResumeAuthorityState -ne $handoffDocument.supervision.resume_authority_state) {
        throw "$ContextLabel.supervision.resume_authority_state must match the referenced fault, checkpoint, and handoff artifacts."
    }

    if ($faultEventDocument.automatic_recovery_claim -ne "not_implied" -or $checkpointDocument.resume_execution_claim -ne "not_implied" -or $handoffDocument.resume_execution_claim -ne "not_implied") {
        throw "$ContextLabel linked artifacts must preserve the explicit non-claim that no unattended recovery or resume is implied."
    }

    if ($handoffDocument.required_next_action -ne "operator_review_required") {
        throw "$ContextLabel requires a handoff packet whose required_next_action remains 'operator_review_required'."
    }
}

function Validate-PreparedReentry {
    param(
        [AllowNull()]
        $PreparedReentry,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract
    )

    $preparedReentryObject = Assert-ObjectValue -Value $PreparedReentry -Context "Resume-from-fault result.prepared_reentry"
    foreach ($fieldName in @($Contract.prepared_reentry_required_fields)) {
        Get-RequiredProperty -Object $preparedReentryObject -Name $fieldName -Context "Resume-from-fault result.prepared_reentry" | Out-Null
    }

    $preparedAction = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $preparedReentryObject -Name "prepared_action" -Context "Resume-from-fault result.prepared_reentry") -Context "Resume-from-fault result.prepared_reentry.prepared_action"
    Assert-AllowedValue -Value $preparedAction -AllowedValues @($Foundation.allowed_resume_prepared_next_steps) -Context "Resume-from-fault result.prepared_reentry.prepared_action"

    $nextOperatorVisibleStep = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $preparedReentryObject -Name "next_operator_visible_step" -Context "Resume-from-fault result.prepared_reentry") -Context "Resume-from-fault result.prepared_reentry.next_operator_visible_step"
    $preparedScopeSummary = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $preparedReentryObject -Name "prepared_scope_summary" -Context "Resume-from-fault result.prepared_reentry") -Context "Resume-from-fault result.prepared_reentry.prepared_scope_summary"

    return [pscustomobject]@{
        PreparedAction = $preparedAction
        NextOperatorVisibleStep = $nextOperatorVisibleStep
        PreparedScopeSummary = $preparedScopeSummary
    }
}

function Test-MilestoneContinuityResumeRequestDocument {
    param(
        [Parameter(Mandatory = $true)]
        $ResumeRequest,
        [Parameter(Mandatory = $true)]
        [string]$SourceLabel,
        [AllowNull()]
        [string]$ResumeRequestPath
    )

    $foundation = Get-MilestoneContinuityFoundationContract
    $contract = Get-MilestoneContinuityResumeRequestContract

    foreach ($fieldName in @($contract.required_fields)) {
        Get-RequiredProperty -Object $ResumeRequest -Name $fieldName -Context "Resume-from-fault request" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ResumeRequest -Name "contract_version" -Context "Resume-from-fault request") -Context "Resume-from-fault request.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "Resume-from-fault request.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ResumeRequest -Name "record_type" -Context "Resume-from-fault request") -Context "Resume-from-fault request.record_type"
    if ($recordType -ne $foundation.resume_request_record_type -or $recordType -ne $contract.record_type) {
        throw "Resume-from-fault request.record_type must equal '$($foundation.resume_request_record_type)'."
    }

    $resumeRequestId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ResumeRequest -Name "resume_request_id" -Context "Resume-from-fault request") -Context "Resume-from-fault request.resume_request_id"
    Assert-RegexMatch -Value $resumeRequestId -Pattern $foundation.identifier_pattern -Context "Resume-from-fault request.resume_request_id"

    $requestedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ResumeRequest -Name "requested_at" -Context "Resume-from-fault request") -Context "Resume-from-fault request.requested_at"
    Assert-RegexMatch -Value $requestedAt -Pattern $foundation.timestamp_pattern -Context "Resume-from-fault request.requested_at"

    $faultEventReference = Validate-FaultEventReference -FaultEventRef (Assert-ObjectValue -Value (Get-RequiredProperty -Object $ResumeRequest -Name "fault_event_ref" -Context "Resume-from-fault request") -Context "Resume-from-fault request.fault_event_ref") -Foundation $foundation -Contract $contract -ContextPrefix "Resume-from-fault request.fault_event_ref"
    $checkpointReference = Validate-CheckpointReference -CheckpointRef (Assert-ObjectValue -Value (Get-RequiredProperty -Object $ResumeRequest -Name "checkpoint_ref" -Context "Resume-from-fault request") -Context "Resume-from-fault request.checkpoint_ref") -Foundation $foundation -Contract $contract -ContextPrefix "Resume-from-fault request.checkpoint_ref"
    $handoffReference = Validate-HandoffReference -HandoffRef (Assert-ObjectValue -Value (Get-RequiredProperty -Object $ResumeRequest -Name "handoff_packet_ref" -Context "Resume-from-fault request") -Context "Resume-from-fault request.handoff_packet_ref") -Foundation $foundation -Contract $contract -ContextPrefix "Resume-from-fault request.handoff_packet_ref"
    $cycleContext = Validate-CycleContext -CycleContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $ResumeRequest -Name "cycle_context" -Context "Resume-from-fault request") -Context "Resume-from-fault request.cycle_context") -Foundation $foundation -Contract $contract -ContextPrefix "Resume-from-fault request.cycle_context"
    $scopeContext = Validate-ScopeContext -ScopeContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $ResumeRequest -Name "scope_context" -Context "Resume-from-fault request") -Context "Resume-from-fault request.scope_context") -Foundation $foundation -Contract $contract -ContextPrefix "Resume-from-fault request.scope_context"
    $repositoryName = Validate-RepositoryContext -RepositoryContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $ResumeRequest -Name "repository" -Context "Resume-from-fault request") -Context "Resume-from-fault request.repository") -Foundation $foundation -Contract $contract -ContextPrefix "Resume-from-fault request.repository"
    $gitContext = Validate-GitContext -GitContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $ResumeRequest -Name "git_context" -Context "Resume-from-fault request") -Context "Resume-from-fault request.git_context") -Foundation $foundation -Contract $contract -ContextPrefix "Resume-from-fault request.git_context"
    $supervision = Validate-Supervision -Supervision (Assert-ObjectValue -Value (Get-RequiredProperty -Object $ResumeRequest -Name "supervision" -Context "Resume-from-fault request") -Context "Resume-from-fault request.supervision") -Foundation $foundation -Contract $contract -ContextPrefix "Resume-from-fault request.supervision"

    $resumeKind = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ResumeRequest -Name "resume_kind" -Context "Resume-from-fault request") -Context "Resume-from-fault request.resume_kind"
    Assert-AllowedValue -Value $resumeKind -AllowedValues @($foundation.allowed_resume_request_kinds) -Context "Resume-from-fault request.resume_kind"

    $requestedNextStep = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ResumeRequest -Name "requested_next_step" -Context "Resume-from-fault request") -Context "Resume-from-fault request.requested_next_step"
    Assert-AllowedValue -Value $requestedNextStep -AllowedValues @($foundation.allowed_resume_prepared_next_steps) -Context "Resume-from-fault request.requested_next_step"

    $authoritativeRefs = Validate-AuthoritativeRefs -AuthoritativeRefs (Assert-ObjectValue -Value (Get-RequiredProperty -Object $ResumeRequest -Name "authoritative_refs" -Context "Resume-from-fault request") -Context "Resume-from-fault request.authoritative_refs") -Foundation $foundation -ContextPrefix "Resume-from-fault request.authoritative_refs"
    $refusalConditions = Assert-StringArray -Value (Get-RequiredProperty -Object $ResumeRequest -Name "refusal_conditions" -Context "Resume-from-fault request") -Context "Resume-from-fault request.refusal_conditions" -MinimumCount 1
    $resumeExecutionClaim = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ResumeRequest -Name "resume_execution_claim" -Context "Resume-from-fault request") -Context "Resume-from-fault request.resume_execution_claim"
    Assert-AllowedValue -Value $resumeExecutionClaim -AllowedValues @($foundation.allowed_resume_execution_claims) -Context "Resume-from-fault request.resume_execution_claim"
    $notes = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ResumeRequest -Name "notes" -Context "Resume-from-fault request") -Context "Resume-from-fault request.notes"

    Assert-Alignment -FaultEventReference $faultEventReference -CheckpointReference $checkpointReference -HandoffReference $handoffReference -CycleContext $cycleContext -ScopeContext $scopeContext -RepositoryName $repositoryName -GitContext $gitContext -Supervision $supervision -ContextLabel "Resume-from-fault request"

    return [pscustomobject]@{
        IsValid = $true
        ResumeRequestId = $resumeRequestId
        ResumeRequestPath = $ResumeRequestPath
        ResumeKind = $resumeKind
        RequestedNextStep = $requestedNextStep
        FaultEventId = $faultEventReference.EventId
        CheckpointId = $checkpointReference.CheckpointId
        HandoffId = $handoffReference.HandoffId
        CycleId = $cycleContext.CycleId
        MilestoneId = $cycleContext.MilestoneId
        ScopeLevel = $scopeContext.ScopeLevel
        TaskId = $scopeContext.TaskId
        SegmentId = $scopeContext.SegmentId
        RepositoryName = $repositoryName
        Branch = $gitContext.Branch
        HeadCommit = $gitContext.HeadCommit
        TreeId = $gitContext.TreeId
        OperatorAuthority = $supervision.OperatorAuthority
        ResumeAuthorityState = $supervision.ResumeAuthorityState
        RefusalConditions = $refusalConditions
        AuthoritativeRefs = $authoritativeRefs
        ResumeExecutionClaim = $resumeExecutionClaim
        SourceLabel = $SourceLabel
        Notes = $notes
    }
}

function Test-MilestoneContinuityResumeResultDocument {
    param(
        [Parameter(Mandatory = $true)]
        $ResumeResult,
        [Parameter(Mandatory = $true)]
        [string]$SourceLabel,
        [AllowNull()]
        [string]$ResumeResultPath
    )

    $foundation = Get-MilestoneContinuityFoundationContract
    $contract = Get-MilestoneContinuityResumeResultContract

    foreach ($fieldName in @($contract.required_fields)) {
        Get-RequiredProperty -Object $ResumeResult -Name $fieldName -Context "Resume-from-fault result" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ResumeResult -Name "contract_version" -Context "Resume-from-fault result") -Context "Resume-from-fault result.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "Resume-from-fault result.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ResumeResult -Name "record_type" -Context "Resume-from-fault result") -Context "Resume-from-fault result.record_type"
    if ($recordType -ne $foundation.resume_result_record_type -or $recordType -ne $contract.record_type) {
        throw "Resume-from-fault result.record_type must equal '$($foundation.resume_result_record_type)'."
    }

    $resumeResultId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ResumeResult -Name "resume_result_id" -Context "Resume-from-fault result") -Context "Resume-from-fault result.resume_result_id"
    Assert-RegexMatch -Value $resumeResultId -Pattern $foundation.identifier_pattern -Context "Resume-from-fault result.resume_result_id"

    $resumeRequestId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ResumeResult -Name "resume_request_id" -Context "Resume-from-fault result") -Context "Resume-from-fault result.resume_request_id"
    Assert-RegexMatch -Value $resumeRequestId -Pattern $foundation.identifier_pattern -Context "Resume-from-fault result.resume_request_id"

    $preparedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ResumeResult -Name "prepared_at" -Context "Resume-from-fault result") -Context "Resume-from-fault result.prepared_at"
    Assert-RegexMatch -Value $preparedAt -Pattern $foundation.timestamp_pattern -Context "Resume-from-fault result.prepared_at"

    $faultEventReference = Validate-FaultEventReference -FaultEventRef (Assert-ObjectValue -Value (Get-RequiredProperty -Object $ResumeResult -Name "fault_event_ref" -Context "Resume-from-fault result") -Context "Resume-from-fault result.fault_event_ref") -Foundation $foundation -Contract $contract -ContextPrefix "Resume-from-fault result.fault_event_ref"
    $checkpointReference = Validate-CheckpointReference -CheckpointRef (Assert-ObjectValue -Value (Get-RequiredProperty -Object $ResumeResult -Name "checkpoint_ref" -Context "Resume-from-fault result") -Context "Resume-from-fault result.checkpoint_ref") -Foundation $foundation -Contract $contract -ContextPrefix "Resume-from-fault result.checkpoint_ref"
    $handoffReference = Validate-HandoffReference -HandoffRef (Assert-ObjectValue -Value (Get-RequiredProperty -Object $ResumeResult -Name "handoff_packet_ref" -Context "Resume-from-fault result") -Context "Resume-from-fault result.handoff_packet_ref") -Foundation $foundation -Contract $contract -ContextPrefix "Resume-from-fault result.handoff_packet_ref"
    $cycleContext = Validate-CycleContext -CycleContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $ResumeResult -Name "cycle_context" -Context "Resume-from-fault result") -Context "Resume-from-fault result.cycle_context") -Foundation $foundation -Contract $contract -ContextPrefix "Resume-from-fault result.cycle_context"
    $scopeContext = Validate-ScopeContext -ScopeContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $ResumeResult -Name "scope_context" -Context "Resume-from-fault result") -Context "Resume-from-fault result.scope_context") -Foundation $foundation -Contract $contract -ContextPrefix "Resume-from-fault result.scope_context"
    $repositoryName = Validate-RepositoryContext -RepositoryContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $ResumeResult -Name "repository" -Context "Resume-from-fault result") -Context "Resume-from-fault result.repository") -Foundation $foundation -Contract $contract -ContextPrefix "Resume-from-fault result.repository"
    $gitContext = Validate-GitContext -GitContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $ResumeResult -Name "git_context" -Context "Resume-from-fault result") -Context "Resume-from-fault result.git_context") -Foundation $foundation -Contract $contract -ContextPrefix "Resume-from-fault result.git_context"
    $supervision = Validate-Supervision -Supervision (Assert-ObjectValue -Value (Get-RequiredProperty -Object $ResumeResult -Name "supervision" -Context "Resume-from-fault result") -Context "Resume-from-fault result.supervision") -Foundation $foundation -Contract $contract -ContextPrefix "Resume-from-fault result.supervision"

    $resumeKind = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ResumeResult -Name "resume_kind" -Context "Resume-from-fault result") -Context "Resume-from-fault result.resume_kind"
    Assert-AllowedValue -Value $resumeKind -AllowedValues @($foundation.allowed_resume_request_kinds) -Context "Resume-from-fault result.resume_kind"

    $preparedReentry = Validate-PreparedReentry -PreparedReentry (Get-RequiredProperty -Object $ResumeResult -Name "prepared_reentry" -Context "Resume-from-fault result") -Foundation $foundation -Contract $contract
    $authoritativeRefs = Validate-AuthoritativeRefs -AuthoritativeRefs (Assert-ObjectValue -Value (Get-RequiredProperty -Object $ResumeResult -Name "authoritative_refs" -Context "Resume-from-fault result") -Context "Resume-from-fault result.authoritative_refs") -Foundation $foundation -ContextPrefix "Resume-from-fault result.authoritative_refs"
    $refusalConditions = Assert-StringArray -Value (Get-RequiredProperty -Object $ResumeResult -Name "refusal_conditions" -Context "Resume-from-fault result") -Context "Resume-from-fault result.refusal_conditions" -MinimumCount 1
    $resumeExecutionClaim = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ResumeResult -Name "resume_execution_claim" -Context "Resume-from-fault result") -Context "Resume-from-fault result.resume_execution_claim"
    Assert-AllowedValue -Value $resumeExecutionClaim -AllowedValues @($foundation.allowed_resume_execution_claims) -Context "Resume-from-fault result.resume_execution_claim"
    $notes = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ResumeResult -Name "notes" -Context "Resume-from-fault result") -Context "Resume-from-fault result.notes"

    Assert-Alignment -FaultEventReference $faultEventReference -CheckpointReference $checkpointReference -HandoffReference $handoffReference -CycleContext $cycleContext -ScopeContext $scopeContext -RepositoryName $repositoryName -GitContext $gitContext -Supervision $supervision -ContextLabel "Resume-from-fault result"

    return [pscustomobject]@{
        IsValid = $true
        ResumeResultId = $resumeResultId
        ResumeRequestId = $resumeRequestId
        ResumeResultPath = $ResumeResultPath
        ResumeKind = $resumeKind
        PreparedAction = $preparedReentry.PreparedAction
        FaultEventId = $faultEventReference.EventId
        CheckpointId = $checkpointReference.CheckpointId
        HandoffId = $handoffReference.HandoffId
        CycleId = $cycleContext.CycleId
        MilestoneId = $cycleContext.MilestoneId
        ScopeLevel = $scopeContext.ScopeLevel
        TaskId = $scopeContext.TaskId
        SegmentId = $scopeContext.SegmentId
        RepositoryName = $repositoryName
        Branch = $gitContext.Branch
        HeadCommit = $gitContext.HeadCommit
        TreeId = $gitContext.TreeId
        OperatorAuthority = $supervision.OperatorAuthority
        ResumeAuthorityState = $supervision.ResumeAuthorityState
        RefusalConditions = $refusalConditions
        AuthoritativeRefs = $authoritativeRefs
        ResumeExecutionClaim = $resumeExecutionClaim
        SourceLabel = $SourceLabel
        Notes = $notes
    }
}

function Test-MilestoneContinuityResumeRequestContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResumeRequestPath
    )

    $resolvedRequestPath = Resolve-ArtifactPath -ArtifactPath $ResumeRequestPath
    $resumeRequest = Get-JsonDocument -Path $resolvedRequestPath -Label "Resume-from-fault request"
    return (Test-MilestoneContinuityResumeRequestDocument -ResumeRequest $resumeRequest -SourceLabel $resolvedRequestPath -ResumeRequestPath $resolvedRequestPath)
}

function Test-MilestoneContinuityResumeRequestObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $ResumeRequest,
        [string]$SourceLabel = "in-memory resume-from-fault request"
    )

    return (Test-MilestoneContinuityResumeRequestDocument -ResumeRequest $ResumeRequest -SourceLabel $SourceLabel -ResumeRequestPath $null)
}

function Test-MilestoneContinuityResumeResultContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResumeResultPath
    )

    $resolvedResultPath = Resolve-ArtifactPath -ArtifactPath $ResumeResultPath
    $resumeResult = Get-JsonDocument -Path $resolvedResultPath -Label "Resume-from-fault result"
    return (Test-MilestoneContinuityResumeResultDocument -ResumeResult $resumeResult -SourceLabel $resolvedResultPath -ResumeResultPath $resolvedResultPath)
}

function Test-MilestoneContinuityResumeResultObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $ResumeResult,
        [string]$SourceLabel = "in-memory resume-from-fault result"
    )

    return (Test-MilestoneContinuityResumeResultDocument -ResumeResult $ResumeResult -SourceLabel $SourceLabel -ResumeResultPath $null)
}

function Get-MilestoneContinuityResumeResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResumeResultPath
    )

    $validation = Test-MilestoneContinuityResumeResultContract -ResumeResultPath $ResumeResultPath
    return (Get-JsonDocument -Path $validation.ResumeResultPath -Label "Resume-from-fault result")
}

function Invoke-MilestoneContinuityResumeFromFault {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResumeRequestPath,
        [Parameter(Mandatory = $true)]
        [string]$ResumeResultPath,
        [datetime]$PreparedAt = (Get-Date).ToUniversalTime()
    )

    $requestValidation = Test-MilestoneContinuityResumeRequestContract -ResumeRequestPath $ResumeRequestPath
    $request = Get-JsonDocument -Path $requestValidation.ResumeRequestPath -Label "Resume-from-fault request"
    $foundation = Get-MilestoneContinuityFoundationContract

    $scopeSummary = if ($request.scope_context.scope_level -eq "task") {
        "Resume cycle '$($request.cycle_context.cycle_id)' task '$($request.scope_context.task_id)' segment '$($request.scope_context.segment_id)' under explicit operator control only."
    }
    else {
        "Resume cycle '$($request.cycle_context.cycle_id)' under explicit operator control only."
    }

    $resumeResult = [pscustomobject]@{
        contract_version = $foundation.contract_version
        record_type = $foundation.resume_result_record_type
        resume_result_id = ("{0}.result" -f $request.resume_request_id)
        resume_request_id = $request.resume_request_id
        prepared_at = $PreparedAt.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        fault_event_ref = $request.fault_event_ref
        checkpoint_ref = $request.checkpoint_ref
        handoff_packet_ref = $request.handoff_packet_ref
        cycle_context = $request.cycle_context
        scope_context = $request.scope_context
        repository = $request.repository
        git_context = $request.git_context
        supervision = $request.supervision
        resume_kind = $request.resume_kind
        prepared_reentry = [pscustomobject]@{
            prepared_action = $request.requested_next_step
            next_operator_visible_step = "Use the prepared supervised resume-from-fault result to resume one governed segment only after explicit operator confirmation."
            prepared_scope_summary = $scopeSummary
        }
        authoritative_refs = $request.authoritative_refs
        refusal_conditions = @($request.refusal_conditions)
        resume_execution_claim = "not_implied"
        notes = "This result prepares one supervised re-entry path from accepted R7 fault and continuity artifacts only. It does not execute resume and does not imply unattended automatic resume."
    }

    $savedResultPath = Write-JsonDocument -Document $resumeResult -OutputPath $ResumeResultPath
    $resultValidation = Test-MilestoneContinuityResumeResultContract -ResumeResultPath $savedResultPath

    return [pscustomobject]@{
        ResumeResult = $resumeResult
        ResumeResultPath = $savedResultPath
        Validation = $resultValidation
    }
}

Export-ModuleMember -Function Test-MilestoneContinuityResumeRequestContract, Test-MilestoneContinuityResumeRequestObject, Test-MilestoneContinuityResumeResultContract, Test-MilestoneContinuityResumeResultObject, Get-MilestoneContinuityResumeResult, Invoke-MilestoneContinuityResumeFromFault
