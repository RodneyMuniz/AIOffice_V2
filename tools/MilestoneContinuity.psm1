Set-StrictMode -Version Latest

Import-Module (Join-Path $PSScriptRoot "FaultManagement.psm1") -Force

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
        throw "Continuity artifact path '$ArtifactPath' does not exist."
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

function Assert-OptionalIdentifier {
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string]$Pattern,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if (-not (Test-HasProperty -Object $Object -Name $Name)) {
        return $null
    }

    $value = Assert-NonEmptyString -Value $Object.$Name -Context "$Context.$Name"
    Assert-RegexMatch -Value $value -Pattern $Pattern -Context "$Context.$Name"
    return $value
}

function Get-RepositoryRoot {
    return (Split-Path -Parent $PSScriptRoot)
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

function Resolve-OutputPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )

    if ([System.IO.Path]::IsPathRooted($OutputPath)) {
        return $OutputPath
    }

    return (Join-Path (Get-Location) $OutputPath)
}

function Write-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        $Document,
        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )

    $resolvedOutputPath = Resolve-OutputPath -OutputPath $OutputPath
    $parentPath = Split-Path -Parent $resolvedOutputPath
    if (-not [string]::IsNullOrWhiteSpace($parentPath)) {
        New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    }

    $Document | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $resolvedOutputPath -Encoding ascii
    return (Resolve-Path -LiteralPath $resolvedOutputPath).Path
}

function Get-MilestoneContinuityFoundationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_continuity\foundation.contract.json") -Label "Milestone continuity foundation contract"
}

function Get-MilestoneContinuityCheckpointContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_continuity\continuity_checkpoint.contract.json") -Label "Milestone continuity checkpoint contract"
}

function Get-MilestoneContinuityHandoffPacketContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_continuity\continuity_handoff_packet.contract.json") -Label "Milestone continuity handoff packet contract"
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
        CycleId        = $cycleId
        MilestoneId    = $milestoneId
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

    $taskId = Assert-OptionalIdentifier -Object $ScopeContext -Name "task_id" -Pattern $Foundation.identifier_pattern -Context $ContextPrefix
    $segmentId = Assert-OptionalIdentifier -Object $ScopeContext -Name "segment_id" -Pattern $Foundation.identifier_pattern -Context $ContextPrefix

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
        TaskId     = $taskId
        SegmentId  = $segmentId
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
        Branch     = $branch
        HeadCommit = $headCommit
        TreeId     = $treeId
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

    return [pscustomobject]@{
        Mode                 = $mode
        OperatorAuthority    = $operatorAuthority
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
    $eventValidation = Test-FaultManagementEventContract -EventPath $eventPathInfo.ResolvedPath
    $eventDocument = Get-FaultManagementEvent -EventPath $eventPathInfo.ResolvedPath

    if ($eventValidation.EventId -ne $eventId) {
        throw "$ContextPrefix.event_id does not match the referenced fault event artifact."
    }

    return [pscustomobject]@{
        EventId        = $eventValidation.EventId
        EventPath      = $eventPathInfo.RelativePath
        EventResolved  = $eventPathInfo.ResolvedPath
        Validation     = $eventValidation
        Document       = $eventDocument
    }
}

function Assert-FaultEventAlignment {
    param(
        [Parameter(Mandatory = $true)]
        $FaultEventReference,
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
        [string]$ArtifactLabel
    )

    $faultEvent = $FaultEventReference.Document
    $validation = $FaultEventReference.Validation

    if ($CycleContext.CycleId -ne $validation.CycleId) {
        throw "$ArtifactLabel.cycle_context.cycle_id must match the referenced fault event."
    }

    if ($CycleContext.MilestoneId -ne $validation.MilestoneId) {
        throw "$ArtifactLabel.cycle_context.milestone_id must match the referenced fault event."
    }

    if ($CycleContext.MilestoneTitle -ne $faultEvent.cycle_context.milestone_title) {
        throw "$ArtifactLabel.cycle_context.milestone_title must match the referenced fault event."
    }

    if ($ScopeContext.ScopeLevel -ne $validation.ScopeLevel) {
        throw "$ArtifactLabel.scope_context.scope_level must match the referenced fault event."
    }

    if ($ScopeContext.TaskId -ne $validation.TaskId) {
        throw "$ArtifactLabel.scope_context.task_id must match the referenced fault event."
    }

    if ($ScopeContext.SegmentId -ne $validation.SegmentId) {
        throw "$ArtifactLabel.scope_context.segment_id must match the referenced fault event."
    }

    if ($RepositoryName -ne $validation.RepositoryName) {
        throw "$ArtifactLabel.repository.repository_name must match the referenced fault event."
    }

    if ($GitContext.Branch -ne $validation.Branch -or $GitContext.HeadCommit -ne $validation.HeadCommit -or $GitContext.TreeId -ne $validation.TreeId) {
        throw "$ArtifactLabel.git_context must match the referenced fault event git context."
    }

    if ($Supervision.Mode -ne $faultEvent.supervision.mode -or $Supervision.OperatorAuthority -ne $validation.OperatorAuthority -or $Supervision.ResumeAuthorityState -ne $faultEvent.supervision.resume_authority_state) {
        throw "$ArtifactLabel.supervision must match the referenced fault event supervision state."
    }
}

function Validate-CheckpointSnapshot {
    param(
        [Parameter(Mandatory = $true)]
        $CheckpointSnapshot,
        [Parameter(Mandatory = $true)]
        $Contract
    )

    foreach ($fieldName in @($Contract.checkpoint_snapshot_required_fields)) {
        Get-RequiredProperty -Object $CheckpointSnapshot -Name $fieldName -Context "Continuity checkpoint.checkpoint_snapshot" | Out-Null
    }

    return [pscustomobject]@{
        SegmentGoal      = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $CheckpointSnapshot -Name "segment_goal" -Context "Continuity checkpoint.checkpoint_snapshot") -Context "Continuity checkpoint.checkpoint_snapshot.segment_goal"
        LastCompletedStep = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $CheckpointSnapshot -Name "last_completed_step" -Context "Continuity checkpoint.checkpoint_snapshot") -Context "Continuity checkpoint.checkpoint_snapshot.last_completed_step"
        NextRequiredStep = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $CheckpointSnapshot -Name "next_required_step" -Context "Continuity checkpoint.checkpoint_snapshot") -Context "Continuity checkpoint.checkpoint_snapshot.next_required_step"
    }
}

function Validate-HandoffSummary {
    param(
        [Parameter(Mandatory = $true)]
        $HandoffSummary,
        [Parameter(Mandatory = $true)]
        $Contract
    )

    foreach ($fieldName in @($Contract.handoff_summary_required_fields)) {
        Get-RequiredProperty -Object $HandoffSummary -Name $fieldName -Context "Continuity handoff.handoff_summary" | Out-Null
    }

    return [pscustomobject]@{
        SegmentGoal             = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $HandoffSummary -Name "segment_goal" -Context "Continuity handoff.handoff_summary") -Context "Continuity handoff.handoff_summary.segment_goal"
        CompletedWorkSummary    = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $HandoffSummary -Name "completed_work_summary" -Context "Continuity handoff.handoff_summary") -Context "Continuity handoff.handoff_summary.completed_work_summary"
        HandoffObjective        = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $HandoffSummary -Name "handoff_objective" -Context "Continuity handoff.handoff_summary") -Context "Continuity handoff.handoff_summary.handoff_objective"
        NextOperatorVisibleStep = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $HandoffSummary -Name "next_operator_visible_step" -Context "Continuity handoff.handoff_summary") -Context "Continuity handoff.handoff_summary.next_operator_visible_step"
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
    $checkpointValidation = Test-MilestoneContinuityCheckpointContract -ArtifactPath $checkpointPathInfo.ResolvedPath
    $checkpointDocument = Get-MilestoneContinuityArtifact -ArtifactPath $checkpointPathInfo.ResolvedPath

    if ($checkpointValidation.ArtifactId -ne $checkpointId) {
        throw "$ContextPrefix.checkpoint_id does not match the referenced checkpoint artifact."
    }

    return [pscustomobject]@{
        CheckpointId       = $checkpointValidation.ArtifactId
        CheckpointPath     = $checkpointPathInfo.RelativePath
        CheckpointResolved = $checkpointPathInfo.ResolvedPath
        Validation         = $checkpointValidation
        Document           = $checkpointDocument
    }
}

function Test-MilestoneContinuityCheckpointDocument {
    param(
        [Parameter(Mandatory = $true)]
        $Checkpoint,
        [Parameter(Mandatory = $true)]
        [string]$SourceLabel,
        [AllowNull()]
        [string]$ArtifactPath
    )

    $foundation = Get-MilestoneContinuityFoundationContract
    $contract = Get-MilestoneContinuityCheckpointContract

    foreach ($fieldName in @($contract.required_fields)) {
        Get-RequiredProperty -Object $Checkpoint -Name $fieldName -Context "Continuity checkpoint" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Checkpoint -Name "contract_version" -Context "Continuity checkpoint") -Context "Continuity checkpoint.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "Continuity checkpoint.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Checkpoint -Name "record_type" -Context "Continuity checkpoint") -Context "Continuity checkpoint.record_type"
    if ($recordType -ne $foundation.checkpoint_record_type -or $recordType -ne $contract.record_type) {
        throw "Continuity checkpoint.record_type must equal '$($foundation.checkpoint_record_type)'."
    }

    $checkpointId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Checkpoint -Name "checkpoint_id" -Context "Continuity checkpoint") -Context "Continuity checkpoint.checkpoint_id"
    Assert-RegexMatch -Value $checkpointId -Pattern $foundation.identifier_pattern -Context "Continuity checkpoint.checkpoint_id"

    $emittedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Checkpoint -Name "emitted_at" -Context "Continuity checkpoint") -Context "Continuity checkpoint.emitted_at"
    Assert-RegexMatch -Value $emittedAt -Pattern $foundation.timestamp_pattern -Context "Continuity checkpoint.emitted_at"

    $faultEventReference = Validate-FaultEventReference -FaultEventRef (Assert-ObjectValue -Value (Get-RequiredProperty -Object $Checkpoint -Name "fault_event_ref" -Context "Continuity checkpoint") -Context "Continuity checkpoint.fault_event_ref") -Foundation $foundation -Contract $contract -ContextPrefix "Continuity checkpoint.fault_event_ref"
    $cycleContext = Validate-CycleContext -CycleContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $Checkpoint -Name "cycle_context" -Context "Continuity checkpoint") -Context "Continuity checkpoint.cycle_context") -Foundation $foundation -Contract $contract -ContextPrefix "Continuity checkpoint.cycle_context"
    $scopeContext = Validate-ScopeContext -ScopeContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $Checkpoint -Name "scope_context" -Context "Continuity checkpoint") -Context "Continuity checkpoint.scope_context") -Foundation $foundation -Contract $contract -ContextPrefix "Continuity checkpoint.scope_context"
    $repositoryName = Validate-RepositoryContext -RepositoryContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $Checkpoint -Name "repository" -Context "Continuity checkpoint") -Context "Continuity checkpoint.repository") -Foundation $foundation -Contract $contract -ContextPrefix "Continuity checkpoint.repository"
    $gitContext = Validate-GitContext -GitContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $Checkpoint -Name "git_context" -Context "Continuity checkpoint") -Context "Continuity checkpoint.git_context") -Foundation $foundation -Contract $contract -ContextPrefix "Continuity checkpoint.git_context"
    $supervision = Validate-Supervision -Supervision (Assert-ObjectValue -Value (Get-RequiredProperty -Object $Checkpoint -Name "supervision" -Context "Continuity checkpoint") -Context "Continuity checkpoint.supervision") -Foundation $foundation -Contract $contract -ContextPrefix "Continuity checkpoint.supervision"
    $requiredNextAction = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Checkpoint -Name "required_next_action" -Context "Continuity checkpoint") -Context "Continuity checkpoint.required_next_action"
    Assert-AllowedValue -Value $requiredNextAction -AllowedValues @($foundation.allowed_checkpoint_next_actions) -Context "Continuity checkpoint.required_next_action"
    $authoritativeRefs = Validate-AuthoritativeRefs -AuthoritativeRefs (Assert-ObjectValue -Value (Get-RequiredProperty -Object $Checkpoint -Name "authoritative_refs" -Context "Continuity checkpoint") -Context "Continuity checkpoint.authoritative_refs") -Foundation $foundation -ContextPrefix "Continuity checkpoint.authoritative_refs"
    $checkpointSnapshot = Validate-CheckpointSnapshot -CheckpointSnapshot (Assert-ObjectValue -Value (Get-RequiredProperty -Object $Checkpoint -Name "checkpoint_snapshot" -Context "Continuity checkpoint") -Context "Continuity checkpoint.checkpoint_snapshot") -Contract $contract
    $unresolvedBlockers = Assert-StringArray -Value (Get-RequiredProperty -Object $Checkpoint -Name "unresolved_blockers" -Context "Continuity checkpoint") -Context "Continuity checkpoint.unresolved_blockers"
    $interruptionNotes = Assert-StringArray -Value (Get-RequiredProperty -Object $Checkpoint -Name "interruption_notes" -Context "Continuity checkpoint") -Context "Continuity checkpoint.interruption_notes" -MinimumCount 1
    $resumeExecutionClaim = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Checkpoint -Name "resume_execution_claim" -Context "Continuity checkpoint") -Context "Continuity checkpoint.resume_execution_claim"
    Assert-AllowedValue -Value $resumeExecutionClaim -AllowedValues @($foundation.allowed_resume_execution_claims) -Context "Continuity checkpoint.resume_execution_claim"
    $notes = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Checkpoint -Name "notes" -Context "Continuity checkpoint") -Context "Continuity checkpoint.notes"

    Assert-FaultEventAlignment -FaultEventReference $faultEventReference -CycleContext $cycleContext -ScopeContext $scopeContext -RepositoryName $repositoryName -GitContext $gitContext -Supervision $supervision -ArtifactLabel "Continuity checkpoint"

    return [pscustomobject]@{
        IsValid                = $true
        RecordType             = $recordType
        ArtifactId             = $checkpointId
        FaultEventId           = $faultEventReference.EventId
        CycleId                = $cycleContext.CycleId
        MilestoneId            = $cycleContext.MilestoneId
        ScopeLevel             = $scopeContext.ScopeLevel
        TaskId                 = $scopeContext.TaskId
        SegmentId              = $scopeContext.SegmentId
        RepositoryName         = $repositoryName
        Branch                 = $gitContext.Branch
        HeadCommit             = $gitContext.HeadCommit
        TreeId                 = $gitContext.TreeId
        RequiredNextAction     = $requiredNextAction
        ResumeExecutionClaim   = $resumeExecutionClaim
        OperatorAuthority      = $supervision.OperatorAuthority
        SourceLabel            = $SourceLabel
        ArtifactPath           = $ArtifactPath
        CheckpointSnapshot     = $checkpointSnapshot
        UnresolvedBlockers     = $unresolvedBlockers
        InterruptionNotes      = $interruptionNotes
        AuthoritativeRefs      = $authoritativeRefs
        Notes                  = $notes
    }
}

function Test-MilestoneContinuityHandoffPacketDocument {
    param(
        [Parameter(Mandatory = $true)]
        $HandoffPacket,
        [Parameter(Mandatory = $true)]
        [string]$SourceLabel,
        [AllowNull()]
        [string]$ArtifactPath
    )

    $foundation = Get-MilestoneContinuityFoundationContract
    $contract = Get-MilestoneContinuityHandoffPacketContract

    foreach ($fieldName in @($contract.required_fields)) {
        Get-RequiredProperty -Object $HandoffPacket -Name $fieldName -Context "Continuity handoff" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $HandoffPacket -Name "contract_version" -Context "Continuity handoff") -Context "Continuity handoff.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "Continuity handoff.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $HandoffPacket -Name "record_type" -Context "Continuity handoff") -Context "Continuity handoff.record_type"
    if ($recordType -ne $foundation.handoff_packet_record_type -or $recordType -ne $contract.record_type) {
        throw "Continuity handoff.record_type must equal '$($foundation.handoff_packet_record_type)'."
    }

    $handoffId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $HandoffPacket -Name "handoff_id" -Context "Continuity handoff") -Context "Continuity handoff.handoff_id"
    Assert-RegexMatch -Value $handoffId -Pattern $foundation.identifier_pattern -Context "Continuity handoff.handoff_id"

    $emittedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $HandoffPacket -Name "emitted_at" -Context "Continuity handoff") -Context "Continuity handoff.emitted_at"
    Assert-RegexMatch -Value $emittedAt -Pattern $foundation.timestamp_pattern -Context "Continuity handoff.emitted_at"

    $faultEventReference = Validate-FaultEventReference -FaultEventRef (Assert-ObjectValue -Value (Get-RequiredProperty -Object $HandoffPacket -Name "fault_event_ref" -Context "Continuity handoff") -Context "Continuity handoff.fault_event_ref") -Foundation $foundation -Contract $contract -ContextPrefix "Continuity handoff.fault_event_ref"
    $checkpointReference = Validate-CheckpointReference -CheckpointRef (Assert-ObjectValue -Value (Get-RequiredProperty -Object $HandoffPacket -Name "checkpoint_ref" -Context "Continuity handoff") -Context "Continuity handoff.checkpoint_ref") -Foundation $foundation -Contract $contract -ContextPrefix "Continuity handoff.checkpoint_ref"
    $cycleContext = Validate-CycleContext -CycleContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $HandoffPacket -Name "cycle_context" -Context "Continuity handoff") -Context "Continuity handoff.cycle_context") -Foundation $foundation -Contract $contract -ContextPrefix "Continuity handoff.cycle_context"
    $scopeContext = Validate-ScopeContext -ScopeContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $HandoffPacket -Name "scope_context" -Context "Continuity handoff") -Context "Continuity handoff.scope_context") -Foundation $foundation -Contract $contract -ContextPrefix "Continuity handoff.scope_context"
    $repositoryName = Validate-RepositoryContext -RepositoryContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $HandoffPacket -Name "repository" -Context "Continuity handoff") -Context "Continuity handoff.repository") -Foundation $foundation -Contract $contract -ContextPrefix "Continuity handoff.repository"
    $gitContext = Validate-GitContext -GitContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $HandoffPacket -Name "git_context" -Context "Continuity handoff") -Context "Continuity handoff.git_context") -Foundation $foundation -Contract $contract -ContextPrefix "Continuity handoff.git_context"
    $supervision = Validate-Supervision -Supervision (Assert-ObjectValue -Value (Get-RequiredProperty -Object $HandoffPacket -Name "supervision" -Context "Continuity handoff") -Context "Continuity handoff.supervision") -Foundation $foundation -Contract $contract -ContextPrefix "Continuity handoff.supervision"
    $requiredNextAction = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $HandoffPacket -Name "required_next_action" -Context "Continuity handoff") -Context "Continuity handoff.required_next_action"
    Assert-AllowedValue -Value $requiredNextAction -AllowedValues @($foundation.allowed_handoff_next_actions) -Context "Continuity handoff.required_next_action"
    $authoritativeRefs = Validate-AuthoritativeRefs -AuthoritativeRefs (Assert-ObjectValue -Value (Get-RequiredProperty -Object $HandoffPacket -Name "authoritative_refs" -Context "Continuity handoff") -Context "Continuity handoff.authoritative_refs") -Foundation $foundation -ContextPrefix "Continuity handoff.authoritative_refs"
    $handoffSummary = Validate-HandoffSummary -HandoffSummary (Assert-ObjectValue -Value (Get-RequiredProperty -Object $HandoffPacket -Name "handoff_summary" -Context "Continuity handoff") -Context "Continuity handoff.handoff_summary") -Contract $contract
    $unresolvedBlockers = Assert-StringArray -Value (Get-RequiredProperty -Object $HandoffPacket -Name "unresolved_blockers" -Context "Continuity handoff") -Context "Continuity handoff.unresolved_blockers"
    $interruptionNotes = Assert-StringArray -Value (Get-RequiredProperty -Object $HandoffPacket -Name "interruption_notes" -Context "Continuity handoff") -Context "Continuity handoff.interruption_notes" -MinimumCount 1
    $resumeExecutionClaim = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $HandoffPacket -Name "resume_execution_claim" -Context "Continuity handoff") -Context "Continuity handoff.resume_execution_claim"
    Assert-AllowedValue -Value $resumeExecutionClaim -AllowedValues @($foundation.allowed_resume_execution_claims) -Context "Continuity handoff.resume_execution_claim"
    $notes = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $HandoffPacket -Name "notes" -Context "Continuity handoff") -Context "Continuity handoff.notes"

    Assert-FaultEventAlignment -FaultEventReference $faultEventReference -CycleContext $cycleContext -ScopeContext $scopeContext -RepositoryName $repositoryName -GitContext $gitContext -Supervision $supervision -ArtifactLabel "Continuity handoff"

    $checkpointDocument = $checkpointReference.Document
    if ($checkpointDocument.fault_event_ref.event_id -ne $faultEventReference.EventId) {
        throw "Continuity handoff.checkpoint_ref must point to a checkpoint that references the same fault event."
    }

    if ($cycleContext.CycleId -ne $checkpointDocument.cycle_context.cycle_id -or $cycleContext.MilestoneId -ne $checkpointDocument.cycle_context.milestone_id) {
        throw "Continuity handoff.cycle_context must match the referenced checkpoint."
    }

    if ($scopeContext.ScopeLevel -ne $checkpointDocument.scope_context.scope_level -or $scopeContext.TaskId -ne $checkpointDocument.scope_context.task_id -or $scopeContext.SegmentId -ne $checkpointDocument.scope_context.segment_id) {
        throw "Continuity handoff.scope_context must match the referenced checkpoint."
    }

    if ($gitContext.Branch -ne $checkpointDocument.git_context.branch -or $gitContext.HeadCommit -ne $checkpointDocument.git_context.head_commit -or $gitContext.TreeId -ne $checkpointDocument.git_context.tree_id) {
        throw "Continuity handoff.git_context must match the referenced checkpoint."
    }

    return [pscustomobject]@{
        IsValid                = $true
        RecordType             = $recordType
        ArtifactId             = $handoffId
        FaultEventId           = $faultEventReference.EventId
        CheckpointId           = $checkpointReference.CheckpointId
        CycleId                = $cycleContext.CycleId
        MilestoneId            = $cycleContext.MilestoneId
        ScopeLevel             = $scopeContext.ScopeLevel
        TaskId                 = $scopeContext.TaskId
        SegmentId              = $scopeContext.SegmentId
        RepositoryName         = $repositoryName
        Branch                 = $gitContext.Branch
        HeadCommit             = $gitContext.HeadCommit
        TreeId                 = $gitContext.TreeId
        RequiredNextAction     = $requiredNextAction
        ResumeExecutionClaim   = $resumeExecutionClaim
        OperatorAuthority      = $supervision.OperatorAuthority
        SourceLabel            = $SourceLabel
        ArtifactPath           = $ArtifactPath
        HandoffSummary         = $handoffSummary
        UnresolvedBlockers     = $unresolvedBlockers
        InterruptionNotes      = $interruptionNotes
        AuthoritativeRefs      = $authoritativeRefs
        Notes                  = $notes
    }
}

function Test-MilestoneContinuityCheckpointContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArtifactPath
    )

    $resolvedArtifactPath = Resolve-ArtifactPath -ArtifactPath $ArtifactPath
    $checkpoint = Get-JsonDocument -Path $resolvedArtifactPath -Label "Continuity checkpoint"
    return (Test-MilestoneContinuityCheckpointDocument -Checkpoint $checkpoint -SourceLabel $resolvedArtifactPath -ArtifactPath $resolvedArtifactPath)
}

function Test-MilestoneContinuityCheckpointObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Checkpoint,
        [string]$SourceLabel = "in-memory continuity checkpoint"
    )

    return (Test-MilestoneContinuityCheckpointDocument -Checkpoint $Checkpoint -SourceLabel $SourceLabel -ArtifactPath $null)
}

function Test-MilestoneContinuityHandoffPacketContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArtifactPath
    )

    $resolvedArtifactPath = Resolve-ArtifactPath -ArtifactPath $ArtifactPath
    $handoffPacket = Get-JsonDocument -Path $resolvedArtifactPath -Label "Continuity handoff packet"
    return (Test-MilestoneContinuityHandoffPacketDocument -HandoffPacket $handoffPacket -SourceLabel $resolvedArtifactPath -ArtifactPath $resolvedArtifactPath)
}

function Test-MilestoneContinuityHandoffPacketObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $HandoffPacket,
        [string]$SourceLabel = "in-memory continuity handoff packet"
    )

    return (Test-MilestoneContinuityHandoffPacketDocument -HandoffPacket $HandoffPacket -SourceLabel $SourceLabel -ArtifactPath $null)
}

function Test-MilestoneContinuityArtifactContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArtifactPath
    )

    $resolvedArtifactPath = Resolve-ArtifactPath -ArtifactPath $ArtifactPath
    $artifact = Get-JsonDocument -Path $resolvedArtifactPath -Label "Milestone continuity artifact"
    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $artifact -Name "record_type" -Context "Milestone continuity artifact") -Context "Milestone continuity artifact.record_type"
    $foundation = Get-MilestoneContinuityFoundationContract

    switch ($recordType) {
        $foundation.checkpoint_record_type {
            return (Test-MilestoneContinuityCheckpointContract -ArtifactPath $resolvedArtifactPath)
        }
        $foundation.handoff_packet_record_type {
            return (Test-MilestoneContinuityHandoffPacketContract -ArtifactPath $resolvedArtifactPath)
        }
        default {
            throw "Milestone continuity artifact.record_type '$recordType' is not supported."
        }
    }
}

function Get-MilestoneContinuityArtifact {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArtifactPath
    )

    $validation = Test-MilestoneContinuityArtifactContract -ArtifactPath $ArtifactPath
    return (Get-JsonDocument -Path $validation.ArtifactPath -Label "Milestone continuity artifact")
}

function New-MilestoneContinuityCheckpointArtifact {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Checkpoint,
        [string]$OutputPath
    )

    $validation = Test-MilestoneContinuityCheckpointObject -Checkpoint $Checkpoint
    $resolvedOutputPath = $null
    if ($PSBoundParameters.ContainsKey("OutputPath")) {
        $resolvedOutputPath = Write-JsonDocument -Document $Checkpoint -OutputPath $OutputPath
    }

    return [pscustomobject]@{
        ArtifactType = $validation.RecordType
        ArtifactId   = $validation.ArtifactId
        OutputPath   = $resolvedOutputPath
        Validation   = $validation
    }
}

function New-MilestoneContinuityHandoffPacketArtifact {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $HandoffPacket,
        [string]$OutputPath
    )

    $validation = Test-MilestoneContinuityHandoffPacketObject -HandoffPacket $HandoffPacket
    $resolvedOutputPath = $null
    if ($PSBoundParameters.ContainsKey("OutputPath")) {
        $resolvedOutputPath = Write-JsonDocument -Document $HandoffPacket -OutputPath $OutputPath
    }

    return [pscustomobject]@{
        ArtifactType = $validation.RecordType
        ArtifactId   = $validation.ArtifactId
        OutputPath   = $resolvedOutputPath
        Validation   = $validation
    }
}

Export-ModuleMember -Function Test-MilestoneContinuityArtifactContract, Test-MilestoneContinuityCheckpointContract, Test-MilestoneContinuityCheckpointObject, Test-MilestoneContinuityHandoffPacketContract, Test-MilestoneContinuityHandoffPacketObject, Get-MilestoneContinuityArtifact, New-MilestoneContinuityCheckpointArtifact, New-MilestoneContinuityHandoffPacketArtifact
