Set-StrictMode -Version Latest

$faultManagementModule = Import-Module (Join-Path $PSScriptRoot "FaultManagement.psm1") -Force -PassThru
$milestoneContinuityModule = Import-Module (Join-Path $PSScriptRoot "MilestoneContinuity.psm1") -Force -PassThru
$milestoneContinuityResumeModule = Import-Module (Join-Path $PSScriptRoot "MilestoneContinuityResume.psm1") -Force -PassThru

$testFaultManagementEventContract = $faultManagementModule.ExportedCommands["Test-FaultManagementEventContract"]
$getFaultManagementEvent = $faultManagementModule.ExportedCommands["Get-FaultManagementEvent"]
$testMilestoneContinuityCheckpointContract = $milestoneContinuityModule.ExportedCommands["Test-MilestoneContinuityCheckpointContract"]
$testMilestoneContinuityHandoffPacketContract = $milestoneContinuityModule.ExportedCommands["Test-MilestoneContinuityHandoffPacketContract"]
$getMilestoneContinuityArtifact = $milestoneContinuityModule.ExportedCommands["Get-MilestoneContinuityArtifact"]
$testMilestoneContinuityResumeRequestContract = $milestoneContinuityResumeModule.ExportedCommands["Test-MilestoneContinuityResumeRequestContract"]
$testMilestoneContinuityResumeResultContract = $milestoneContinuityResumeModule.ExportedCommands["Test-MilestoneContinuityResumeResultContract"]
$getMilestoneContinuityResumeResult = $milestoneContinuityResumeModule.ExportedCommands["Get-MilestoneContinuityResumeResult"]

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
        throw "Continuity ledger artifact path '$ArtifactPath' does not exist."
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

function Assert-ArrayValue {
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

    return $items
}

function Assert-StringArray {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [int]$MinimumCount = 0
    )

    $items = Assert-ArrayValue -Value $Value -Context $Context -MinimumCount $MinimumCount
    foreach ($item in $items) {
        Assert-NonEmptyString -Value $item -Context "$Context item" | Out-Null
    }

    return $items
}

function Assert-PositiveInteger {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -isnot [int] -and $Value -isnot [long]) {
        throw "$Context must be an integer."
    }

    if ($Value -lt 1) {
        throw "$Context must be greater than zero."
    }

    return [int]$Value
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

function Get-RepoRelativePathFromResolvedPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResolvedPath
    )

    $repoRoot = (Resolve-Path -LiteralPath (Get-RepositoryRoot)).Path
    $normalizedRepoRoot = [System.IO.Path]::GetFullPath($repoRoot)
    $normalizedResolvedPath = [System.IO.Path]::GetFullPath($ResolvedPath)

    if (-not $normalizedResolvedPath.StartsWith($normalizedRepoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Path '$ResolvedPath' is outside the repository root."
    }

    $relativePath = $normalizedResolvedPath.Substring($normalizedRepoRoot.Length).TrimStart('\', '/')
    return ($relativePath -replace '\\', '/')
}

function Get-MilestoneContinuityFoundationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_continuity\foundation.contract.json") -Label "Milestone continuity foundation contract"
}

function Get-MilestoneContinuityLedgerContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_continuity\continuity_ledger.contract.json") -Label "Milestone continuity ledger contract"
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
        throw "$ContextPrefix.resume_authority_state must remain 'operator_review_required' for supervised continuity stitching."
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

function Validate-ResumeRequestReference {
    param(
        [Parameter(Mandatory = $true)]
        $ResumeRequestRef,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [string]$ContextPrefix
    )

    foreach ($fieldName in @($Contract.resume_request_ref_required_fields)) {
        Get-RequiredProperty -Object $ResumeRequestRef -Name $fieldName -Context $ContextPrefix | Out-Null
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ResumeRequestRef -Name "record_type" -Context $ContextPrefix) -Context "$ContextPrefix.record_type"
    if ($recordType -ne $Foundation.resume_request_record_type) {
        throw "$ContextPrefix.record_type must equal '$($Foundation.resume_request_record_type)'."
    }

    $resumeRequestId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ResumeRequestRef -Name "resume_request_id" -Context $ContextPrefix) -Context "$ContextPrefix.resume_request_id"
    Assert-RegexMatch -Value $resumeRequestId -Pattern $Foundation.identifier_pattern -Context "$ContextPrefix.resume_request_id"

    $resumeRequestPathInfo = Assert-RepoRelativeExistingPath -RelativePath (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ResumeRequestRef -Name "resume_request_path" -Context $ContextPrefix) -Context "$ContextPrefix.resume_request_path") -Context "$ContextPrefix.resume_request_path"
    $validation = & $testMilestoneContinuityResumeRequestContract -ResumeRequestPath $resumeRequestPathInfo.ResolvedPath
    $document = Get-JsonDocument -Path $resumeRequestPathInfo.ResolvedPath -Label "Resume-from-fault request"

    if ($validation.ResumeRequestId -ne $resumeRequestId) {
        throw "$ContextPrefix.resume_request_id does not match the referenced resume request artifact."
    }

    return [pscustomobject]@{
        ResumeRequestId = $validation.ResumeRequestId
        ResumeRequestPath = $resumeRequestPathInfo.RelativePath
        Validation = $validation
        Document = $document
    }
}

function Validate-ResumeResultReference {
    param(
        [Parameter(Mandatory = $true)]
        $ResumeResultRef,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [string]$ContextPrefix
    )

    foreach ($fieldName in @($Contract.resume_result_ref_required_fields)) {
        Get-RequiredProperty -Object $ResumeResultRef -Name $fieldName -Context $ContextPrefix | Out-Null
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ResumeResultRef -Name "record_type" -Context $ContextPrefix) -Context "$ContextPrefix.record_type"
    if ($recordType -ne $Foundation.resume_result_record_type) {
        throw "$ContextPrefix.record_type must equal '$($Foundation.resume_result_record_type)'."
    }

    $resumeResultId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ResumeResultRef -Name "resume_result_id" -Context $ContextPrefix) -Context "$ContextPrefix.resume_result_id"
    Assert-RegexMatch -Value $resumeResultId -Pattern $Foundation.identifier_pattern -Context "$ContextPrefix.resume_result_id"

    $resumeResultPathInfo = Assert-RepoRelativeExistingPath -RelativePath (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ResumeResultRef -Name "resume_result_path" -Context $ContextPrefix) -Context "$ContextPrefix.resume_result_path") -Context "$ContextPrefix.resume_result_path"
    $validation = & $testMilestoneContinuityResumeResultContract -ResumeResultPath $resumeResultPathInfo.ResolvedPath
    $document = & $getMilestoneContinuityResumeResult -ResumeResultPath $resumeResultPathInfo.ResolvedPath

    if ($validation.ResumeResultId -ne $resumeResultId) {
        throw "$ContextPrefix.resume_result_id does not match the referenced resume result artifact."
    }

    return [pscustomobject]@{
        ResumeResultId = $validation.ResumeResultId
        ResumeResultPath = $resumeResultPathInfo.RelativePath
        Validation = $validation
        Document = $document
    }
}

function Assert-LineageAlignment {
    param(
        [Parameter(Mandatory = $true)]
        $FaultEventReference,
        [Parameter(Mandatory = $true)]
        $CheckpointReference,
        [Parameter(Mandatory = $true)]
        $HandoffReference,
        [Parameter(Mandatory = $true)]
        $ResumeRequestReference,
        [Parameter(Mandatory = $true)]
        $ResumeResultReference,
        [Parameter(Mandatory = $true)]
        $CycleContext,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryName,
        [Parameter(Mandatory = $true)]
        $GitContext,
        [Parameter(Mandatory = $true)]
        $Supervision,
        [Parameter(Mandatory = $true)]
        [string]$ContextLabel
    )

    $expectedCycleId = $ResumeRequestReference.Validation.CycleId
    $expectedMilestoneId = $ResumeRequestReference.Validation.MilestoneId
    $expectedTaskId = $ResumeRequestReference.Validation.TaskId
    $expectedSegmentId = $ResumeRequestReference.Validation.SegmentId

    if ($ResumeResultReference.Validation.ResumeRequestId -ne $ResumeRequestReference.Validation.ResumeRequestId) {
        throw "$ContextLabel.authoritative_lineage.resume_result_ref must point to a result for the referenced resume request."
    }

    foreach ($validation in @(
        $FaultEventReference.Validation,
        $CheckpointReference.Validation,
        $HandoffReference.Validation,
        $ResumeRequestReference.Validation,
        $ResumeResultReference.Validation
    )) {
        if ($validation.CycleId -ne $expectedCycleId -or $validation.MilestoneId -ne $expectedMilestoneId) {
            throw "$ContextLabel.authoritative_lineage contains contradictory cycle or milestone identity."
        }

        if ($validation.RepositoryName -ne $RepositoryName) {
            throw "$ContextLabel.repository.repository_name must match all referenced continuity artifacts."
        }

        if ($validation.Branch -ne $GitContext.Branch -or $validation.HeadCommit -ne $GitContext.HeadCommit -or $validation.TreeId -ne $GitContext.TreeId) {
            throw "$ContextLabel.git_context must match all referenced continuity artifacts."
        }

        if ($validation.OperatorAuthority -ne $Supervision.OperatorAuthority) {
            throw "$ContextLabel.supervision.operator_authority must match all referenced continuity artifacts."
        }
    }

    foreach ($validation in @(
        $CheckpointReference.Validation,
        $HandoffReference.Validation,
        $ResumeRequestReference.Validation,
        $ResumeResultReference.Validation
    )) {
        if ($validation.TaskId -ne $expectedTaskId -or $validation.SegmentId -ne $expectedSegmentId) {
            throw "$ContextLabel.authoritative_lineage contains contradictory task or segment identity."
        }
    }

    if ($CycleContext.CycleId -ne $expectedCycleId -or $CycleContext.MilestoneId -ne $expectedMilestoneId) {
        throw "$ContextLabel.cycle_context must match the referenced continuity artifacts."
    }

    if ($ResumeRequestReference.Document.resume_execution_claim -ne "not_implied" -or
        $ResumeResultReference.Document.resume_execution_claim -ne "not_implied" -or
        $CheckpointReference.Document.resume_execution_claim -ne "not_implied" -or
        $HandoffReference.Document.resume_execution_claim -ne "not_implied" -or
        $FaultEventReference.Document.automatic_recovery_claim -ne "not_implied") {
        throw "$ContextLabel must remain explicitly non-executing across the referenced interruption and continuity artifacts."
    }

    return [pscustomobject]@{
        CycleId = $expectedCycleId
        MilestoneId = $expectedMilestoneId
        TaskId = $expectedTaskId
        InterruptedSegmentId = $expectedSegmentId
        FaultEventId = $FaultEventReference.Validation.EventId
        CheckpointId = $CheckpointReference.Validation.ArtifactId
        HandoffId = $HandoffReference.Validation.ArtifactId
        ResumeRequestId = $ResumeRequestReference.Validation.ResumeRequestId
        ResumeResultId = $ResumeResultReference.Validation.ResumeResultId
    }
}

function Validate-LedgerSegment {
    param(
        [Parameter(Mandatory = $true)]
        $Segment,
        [Parameter(Mandatory = $true)]
        [int]$ExpectedOrdinal,
        [Parameter(Mandatory = $true)]
        [string]$ExpectedTaskId,
        [Parameter(Mandatory = $true)]
        [string]$ExpectedRole,
        [Parameter(Mandatory = $true)]
        [string]$ExpectedState,
        [AllowNull()]
        $ExpectedSegmentId,
        [AllowNull()]
        $ExpectedPriorSegmentId,
        [Parameter(Mandatory = $true)]
        $LedgerGitContext,
        [Parameter(Mandatory = $true)]
        $LedgerSupervision,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [string]$ContextPrefix
    )

    foreach ($fieldName in @($Contract.segment_required_fields)) {
        Get-RequiredProperty -Object $Segment -Name $fieldName -Context $ContextPrefix | Out-Null
    }

    $ordinal = Assert-PositiveInteger -Value (Get-RequiredProperty -Object $Segment -Name "ordinal" -Context $ContextPrefix) -Context "$ContextPrefix.ordinal"
    if ($ordinal -ne $ExpectedOrdinal) {
        throw "$ContextPrefix.ordinal must equal $ExpectedOrdinal."
    }

    $taskId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Segment -Name "task_id" -Context $ContextPrefix) -Context "$ContextPrefix.task_id"
    Assert-RegexMatch -Value $taskId -Pattern $Foundation.identifier_pattern -Context "$ContextPrefix.task_id"
    if ($taskId -ne $ExpectedTaskId) {
        throw "$ContextPrefix.task_id must equal '$ExpectedTaskId'."
    }

    $segmentId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Segment -Name "segment_id" -Context $ContextPrefix) -Context "$ContextPrefix.segment_id"
    Assert-RegexMatch -Value $segmentId -Pattern $Foundation.identifier_pattern -Context "$ContextPrefix.segment_id"

    if (-not [string]::IsNullOrWhiteSpace([string]$ExpectedSegmentId) -and $segmentId -ne $ExpectedSegmentId) {
        throw "$ContextPrefix.segment_id must equal '$ExpectedSegmentId'."
    }

    $segmentRole = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Segment -Name "segment_role" -Context $ContextPrefix) -Context "$ContextPrefix.segment_role"
    Assert-AllowedValue -Value $segmentRole -AllowedValues @($Foundation.allowed_segment_roles) -Context "$ContextPrefix.segment_role"
    if ($segmentRole -ne $ExpectedRole) {
        throw "$ContextPrefix.segment_role must equal '$ExpectedRole'."
    }

    $continuityState = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Segment -Name "continuity_state" -Context $ContextPrefix) -Context "$ContextPrefix.continuity_state"
    Assert-AllowedValue -Value $continuityState -AllowedValues @($Foundation.allowed_segment_continuity_states) -Context "$ContextPrefix.continuity_state"
    if ($continuityState -ne $ExpectedState) {
        throw "$ContextPrefix.continuity_state must equal '$ExpectedState'."
    }

    $gitContext = Validate-GitContext -GitContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $Segment -Name "git_context" -Context $ContextPrefix) -Context "$ContextPrefix.git_context") -Foundation $Foundation -Contract $Contract -ContextPrefix "$ContextPrefix.git_context"
    if ($gitContext.Branch -ne $LedgerGitContext.Branch -or $gitContext.HeadCommit -ne $LedgerGitContext.HeadCommit -or $gitContext.TreeId -ne $LedgerGitContext.TreeId) {
        throw "$ContextPrefix.git_context must match the ledger git context."
    }

    $supervision = Validate-Supervision -Supervision (Assert-ObjectValue -Value (Get-RequiredProperty -Object $Segment -Name "supervision" -Context $ContextPrefix) -Context "$ContextPrefix.supervision") -Foundation $Foundation -Contract $Contract -ContextPrefix "$ContextPrefix.supervision"
    if ($supervision.Mode -ne $LedgerSupervision.Mode -or $supervision.OperatorAuthority -ne $LedgerSupervision.OperatorAuthority -or $supervision.ResumeAuthorityState -ne $LedgerSupervision.ResumeAuthorityState) {
        throw "$ContextPrefix.supervision must match the ledger supervision identity."
    }

    $priorSegmentId = $null
    if (Test-HasProperty -Object $Segment -Name "prior_segment_id") {
        $priorSegmentId = Assert-NonEmptyString -Value $Segment.prior_segment_id -Context "$ContextPrefix.prior_segment_id"
        Assert-RegexMatch -Value $priorSegmentId -Pattern $Foundation.identifier_pattern -Context "$ContextPrefix.prior_segment_id"
    }

    if ([string]::IsNullOrWhiteSpace([string]$ExpectedPriorSegmentId) -and $null -ne $priorSegmentId) {
        throw "$ContextPrefix.prior_segment_id must be absent for the first stitched segment."
    }

    if (-not [string]::IsNullOrWhiteSpace([string]$ExpectedPriorSegmentId) -and $priorSegmentId -ne $ExpectedPriorSegmentId) {
        throw "$ContextPrefix.prior_segment_id must equal '$ExpectedPriorSegmentId'."
    }

    return [pscustomobject]@{
        Ordinal = $ordinal
        TaskId = $taskId
        SegmentId = $segmentId
        PriorSegmentId = $priorSegmentId
        SegmentRole = $segmentRole
        ContinuityState = $continuityState
    }
}

function Test-MilestoneContinuityLedgerDocument {
    param(
        [Parameter(Mandatory = $true)]
        $Ledger,
        [Parameter(Mandatory = $true)]
        [string]$SourceLabel,
        [AllowNull()]
        [string]$LedgerPath
    )

    $foundation = Get-MilestoneContinuityFoundationContract
    $contract = Get-MilestoneContinuityLedgerContract

    foreach ($fieldName in @($contract.required_fields)) {
        Get-RequiredProperty -Object $Ledger -Name $fieldName -Context "Continuity ledger" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "contract_version" -Context "Continuity ledger") -Context "Continuity ledger.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "Continuity ledger.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "record_type" -Context "Continuity ledger") -Context "Continuity ledger.record_type"
    if ($recordType -ne $foundation.ledger_record_type -or $recordType -ne $contract.record_type) {
        throw "Continuity ledger.record_type must equal '$($foundation.ledger_record_type)'."
    }

    $ledgerId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "ledger_id" -Context "Continuity ledger") -Context "Continuity ledger.ledger_id"
    Assert-RegexMatch -Value $ledgerId -Pattern $foundation.identifier_pattern -Context "Continuity ledger.ledger_id"

    $stitchedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "stitched_at" -Context "Continuity ledger") -Context "Continuity ledger.stitched_at"
    Assert-RegexMatch -Value $stitchedAt -Pattern $foundation.timestamp_pattern -Context "Continuity ledger.stitched_at"

    $cycleContext = Validate-CycleContext -CycleContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $Ledger -Name "cycle_context" -Context "Continuity ledger") -Context "Continuity ledger.cycle_context") -Foundation $foundation -Contract $contract -ContextPrefix "Continuity ledger.cycle_context"
    $repositoryName = Validate-RepositoryContext -RepositoryContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $Ledger -Name "repository" -Context "Continuity ledger") -Context "Continuity ledger.repository") -Foundation $foundation -Contract $contract -ContextPrefix "Continuity ledger.repository"
    $gitContext = Validate-GitContext -GitContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $Ledger -Name "git_context" -Context "Continuity ledger") -Context "Continuity ledger.git_context") -Foundation $foundation -Contract $contract -ContextPrefix "Continuity ledger.git_context"
    $supervision = Validate-Supervision -Supervision (Assert-ObjectValue -Value (Get-RequiredProperty -Object $Ledger -Name "supervision" -Context "Continuity ledger") -Context "Continuity ledger.supervision") -Foundation $foundation -Contract $contract -ContextPrefix "Continuity ledger.supervision"

    $ledgerContinuityState = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "ledger_continuity_state" -Context "Continuity ledger") -Context "Continuity ledger.ledger_continuity_state"
    Assert-AllowedValue -Value $ledgerContinuityState -AllowedValues @($foundation.allowed_ledger_continuity_states) -Context "Continuity ledger.ledger_continuity_state"

    $lineage = Assert-ObjectValue -Value (Get-RequiredProperty -Object $Ledger -Name "authoritative_lineage" -Context "Continuity ledger") -Context "Continuity ledger.authoritative_lineage"
    foreach ($fieldName in @($contract.authoritative_lineage_required_fields)) {
        Get-RequiredProperty -Object $lineage -Name $fieldName -Context "Continuity ledger.authoritative_lineage" | Out-Null
    }

    $faultEventReference = Validate-FaultEventReference -FaultEventRef (Assert-ObjectValue -Value (Get-RequiredProperty -Object $lineage -Name "fault_event_ref" -Context "Continuity ledger.authoritative_lineage") -Context "Continuity ledger.authoritative_lineage.fault_event_ref") -Foundation $foundation -Contract $contract -ContextPrefix "Continuity ledger.authoritative_lineage.fault_event_ref"
    $checkpointReference = Validate-CheckpointReference -CheckpointRef (Assert-ObjectValue -Value (Get-RequiredProperty -Object $lineage -Name "checkpoint_ref" -Context "Continuity ledger.authoritative_lineage") -Context "Continuity ledger.authoritative_lineage.checkpoint_ref") -Foundation $foundation -Contract $contract -ContextPrefix "Continuity ledger.authoritative_lineage.checkpoint_ref"
    $handoffReference = Validate-HandoffReference -HandoffRef (Assert-ObjectValue -Value (Get-RequiredProperty -Object $lineage -Name "handoff_packet_ref" -Context "Continuity ledger.authoritative_lineage") -Context "Continuity ledger.authoritative_lineage.handoff_packet_ref") -Foundation $foundation -Contract $contract -ContextPrefix "Continuity ledger.authoritative_lineage.handoff_packet_ref"
    $resumeRequestReference = Validate-ResumeRequestReference -ResumeRequestRef (Assert-ObjectValue -Value (Get-RequiredProperty -Object $lineage -Name "resume_request_ref" -Context "Continuity ledger.authoritative_lineage") -Context "Continuity ledger.authoritative_lineage.resume_request_ref") -Foundation $foundation -Contract $contract -ContextPrefix "Continuity ledger.authoritative_lineage.resume_request_ref"
    $resumeResultReference = Validate-ResumeResultReference -ResumeResultRef (Assert-ObjectValue -Value (Get-RequiredProperty -Object $lineage -Name "resume_result_ref" -Context "Continuity ledger.authoritative_lineage") -Context "Continuity ledger.authoritative_lineage.resume_result_ref") -Foundation $foundation -Contract $contract -ContextPrefix "Continuity ledger.authoritative_lineage.resume_result_ref"

    $lineageSummary = Assert-LineageAlignment -FaultEventReference $faultEventReference -CheckpointReference $checkpointReference -HandoffReference $handoffReference -ResumeRequestReference $resumeRequestReference -ResumeResultReference $resumeResultReference -CycleContext $cycleContext -RepositoryName $repositoryName -GitContext $gitContext -Supervision $supervision -ContextLabel "Continuity ledger"

    $orderedSegments = Assert-ArrayValue -Value (Get-RequiredProperty -Object $Ledger -Name "ordered_segments" -Context "Continuity ledger") -Context "Continuity ledger.ordered_segments" -MinimumCount 2
    if ($orderedSegments.Count -ne 2) {
        throw "Continuity ledger.ordered_segments must contain exactly 2 segments for this bounded stitched continuity slice."
    }

    $firstSegment = Validate-LedgerSegment -Segment $orderedSegments[0] -ExpectedOrdinal 1 -ExpectedTaskId $lineageSummary.TaskId -ExpectedRole "interrupted_boundary" -ExpectedState "interrupted_checkpointed" -ExpectedSegmentId $lineageSummary.InterruptedSegmentId -ExpectedPriorSegmentId $null -LedgerGitContext $gitContext -LedgerSupervision $supervision -Foundation $foundation -Contract $contract -ContextPrefix "Continuity ledger.ordered_segments[0]"
    $secondSegment = Validate-LedgerSegment -Segment $orderedSegments[1] -ExpectedOrdinal 2 -ExpectedTaskId $lineageSummary.TaskId -ExpectedRole "resumed_successor_prepared" -ExpectedState "supervised_resume_prepared" -ExpectedSegmentId $null -ExpectedPriorSegmentId $firstSegment.SegmentId -LedgerGitContext $gitContext -LedgerSupervision $supervision -Foundation $foundation -Contract $contract -ContextPrefix "Continuity ledger.ordered_segments[1]"

    if ($secondSegment.SegmentId -eq $firstSegment.SegmentId) {
        throw "Continuity ledger.ordered_segments[1].segment_id must introduce a distinct resumed successor segment."
    }

    $authoritativeRefs = Validate-AuthoritativeRefs -AuthoritativeRefs (Assert-ObjectValue -Value (Get-RequiredProperty -Object $Ledger -Name "authoritative_refs" -Context "Continuity ledger") -Context "Continuity ledger.authoritative_refs") -Foundation $foundation -ContextPrefix "Continuity ledger.authoritative_refs"
    $nonClaims = Assert-StringArray -Value (Get-RequiredProperty -Object $Ledger -Name "non_claims" -Context "Continuity ledger") -Context "Continuity ledger.non_claims" -MinimumCount 1
    foreach ($nonClaim in $nonClaims) {
        Assert-AllowedValue -Value $nonClaim -AllowedValues @($foundation.allowed_ledger_non_claims) -Context "Continuity ledger.non_claims item"
    }
    if ($nonClaims -notcontains "stitching_only_no_rollback_plan_no_rollback_drill_no_unattended_recovery") {
        throw "Continuity ledger.non_claims must explicitly preserve the bounded non-claim for rollback planning, rollback drill, and unattended recovery."
    }

    $notes = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "notes" -Context "Continuity ledger") -Context "Continuity ledger.notes"

    return [pscustomobject]@{
        IsValid = $true
        LedgerId = $ledgerId
        LedgerPath = $LedgerPath
        CycleId = $lineageSummary.CycleId
        MilestoneId = $lineageSummary.MilestoneId
        TaskId = $lineageSummary.TaskId
        InterruptedSegmentId = $firstSegment.SegmentId
        SuccessorSegmentId = $secondSegment.SegmentId
        FaultEventId = $lineageSummary.FaultEventId
        CheckpointId = $lineageSummary.CheckpointId
        HandoffId = $lineageSummary.HandoffId
        ResumeRequestId = $lineageSummary.ResumeRequestId
        ResumeResultId = $lineageSummary.ResumeResultId
        RepositoryName = $repositoryName
        Branch = $gitContext.Branch
        HeadCommit = $gitContext.HeadCommit
        TreeId = $gitContext.TreeId
        OperatorAuthority = $supervision.OperatorAuthority
        LedgerContinuityState = $ledgerContinuityState
        SegmentCount = $orderedSegments.Count
        AuthoritativeRefs = $authoritativeRefs
        NonClaims = $nonClaims
        SourceLabel = $SourceLabel
        Notes = $notes
    }
}

function Test-MilestoneContinuityLedgerContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$LedgerPath
    )

    $resolvedLedgerPath = Resolve-ArtifactPath -ArtifactPath $LedgerPath
    $ledger = Get-JsonDocument -Path $resolvedLedgerPath -Label "Continuity ledger"
    return (Test-MilestoneContinuityLedgerDocument -Ledger $ledger -SourceLabel $resolvedLedgerPath -LedgerPath $resolvedLedgerPath)
}

function Test-MilestoneContinuityLedgerObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Ledger,
        [string]$SourceLabel = "in-memory continuity ledger"
    )

    return (Test-MilestoneContinuityLedgerDocument -Ledger $Ledger -SourceLabel $SourceLabel -LedgerPath $null)
}

function Get-MilestoneContinuityLedger {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$LedgerPath
    )

    $validation = Test-MilestoneContinuityLedgerContract -LedgerPath $LedgerPath
    return (Get-JsonDocument -Path $validation.LedgerPath -Label "Continuity ledger")
}

function Invoke-MilestoneContinuityLedgerStitch {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$FaultEventPath,
        [Parameter(Mandatory = $true)]
        [string]$CheckpointPath,
        [Parameter(Mandatory = $true)]
        [string]$HandoffPacketPath,
        [Parameter(Mandatory = $true)]
        [string]$ResumeRequestPath,
        [Parameter(Mandatory = $true)]
        [string]$ResumeResultPath,
        [Parameter(Mandatory = $true)]
        [string]$SuccessorSegmentId,
        [Parameter(Mandatory = $true)]
        [string]$LedgerPath,
        [string]$LedgerId = "continuity-ledger-r7-005-001",
        [datetime]$StitchedAt = (Get-Date).ToUniversalTime()
    )

    $foundation = Get-MilestoneContinuityFoundationContract
    Assert-NonEmptyString -Value $LedgerId -Context "LedgerId" | Out-Null
    Assert-RegexMatch -Value $LedgerId -Pattern $foundation.identifier_pattern -Context "LedgerId"
    Assert-NonEmptyString -Value $SuccessorSegmentId -Context "SuccessorSegmentId" | Out-Null
    Assert-RegexMatch -Value $SuccessorSegmentId -Pattern $foundation.identifier_pattern -Context "SuccessorSegmentId"

    $faultEventValidation = & $testFaultManagementEventContract -EventPath $FaultEventPath
    $faultEventDocument = & $getFaultManagementEvent -EventPath $FaultEventPath
    $checkpointValidation = & $testMilestoneContinuityCheckpointContract -ArtifactPath $CheckpointPath
    $checkpointDocument = & $getMilestoneContinuityArtifact -ArtifactPath $CheckpointPath
    $handoffValidation = & $testMilestoneContinuityHandoffPacketContract -ArtifactPath $HandoffPacketPath
    $handoffDocument = & $getMilestoneContinuityArtifact -ArtifactPath $HandoffPacketPath
    $resumeRequestValidation = & $testMilestoneContinuityResumeRequestContract -ResumeRequestPath $ResumeRequestPath
    $resolvedResumeRequestPath = Resolve-ArtifactPath -ArtifactPath $ResumeRequestPath
    $resumeRequestDocument = Get-JsonDocument -Path $resolvedResumeRequestPath -Label "Resume-from-fault request"
    $resumeResultValidation = & $testMilestoneContinuityResumeResultContract -ResumeResultPath $ResumeResultPath
    $resolvedResumeResultPath = Resolve-ArtifactPath -ArtifactPath $ResumeResultPath
    $resumeResultDocument = & $getMilestoneContinuityResumeResult -ResumeResultPath $ResumeResultPath

    if ($faultEventValidation.EventId -ne $resumeRequestValidation.FaultEventId -or $faultEventValidation.EventId -ne $resumeResultValidation.FaultEventId) {
        throw "FaultEventPath must match the accepted fault-event lineage referenced by the resume artifacts."
    }

    if ($checkpointValidation.ArtifactId -ne $resumeRequestValidation.CheckpointId -or $checkpointValidation.ArtifactId -ne $resumeResultValidation.CheckpointId) {
        throw "CheckpointPath must match the accepted checkpoint lineage referenced by the resume artifacts."
    }

    if ($handoffValidation.ArtifactId -ne $resumeRequestValidation.HandoffId -or $handoffValidation.ArtifactId -ne $resumeResultValidation.HandoffId) {
        throw "HandoffPacketPath must match the accepted handoff lineage referenced by the resume artifacts."
    }

    if ($resumeResultValidation.ResumeRequestId -ne $resumeRequestValidation.ResumeRequestId) {
        throw "ResumeResultPath must point to a resume result prepared from the referenced resume request."
    }

    if ($SuccessorSegmentId -eq $resumeRequestValidation.SegmentId) {
        throw "SuccessorSegmentId must introduce a distinct resumed successor segment id."
    }

    $ledger = [pscustomobject]@{
        contract_version = $foundation.contract_version
        record_type = $foundation.ledger_record_type
        ledger_id = $LedgerId
        stitched_at = $StitchedAt.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        cycle_context = $resumeResultDocument.cycle_context
        repository = $resumeResultDocument.repository
        git_context = $resumeResultDocument.git_context
        supervision = $resumeResultDocument.supervision
        ledger_continuity_state = "stitched_interrupted_to_supervised_resume"
        authoritative_lineage = [pscustomobject]@{
            fault_event_ref = $resumeResultDocument.fault_event_ref.PSObject.Copy()
            checkpoint_ref = $resumeResultDocument.checkpoint_ref.PSObject.Copy()
            handoff_packet_ref = $resumeResultDocument.handoff_packet_ref.PSObject.Copy()
            resume_request_ref = [pscustomobject]@{
                record_type = $foundation.resume_request_record_type
                resume_request_id = $resumeRequestDocument.resume_request_id
                resume_request_path = (Get-RepoRelativePathFromResolvedPath -ResolvedPath $resolvedResumeRequestPath)
            }
            resume_result_ref = [pscustomobject]@{
                record_type = $foundation.resume_result_record_type
                resume_result_id = $resumeResultDocument.resume_result_id
                resume_result_path = (Get-RepoRelativePathFromResolvedPath -ResolvedPath $resolvedResumeResultPath)
            }
        }
        ordered_segments = @(
            [pscustomobject]@{
                ordinal = 1
                task_id = $resumeRequestDocument.scope_context.task_id
                segment_id = $resumeRequestDocument.scope_context.segment_id
                segment_role = "interrupted_boundary"
                continuity_state = "interrupted_checkpointed"
                git_context = $resumeResultDocument.git_context
                supervision = $resumeResultDocument.supervision
            },
            [pscustomobject]@{
                ordinal = 2
                task_id = $resumeRequestDocument.scope_context.task_id
                segment_id = $SuccessorSegmentId
                prior_segment_id = $resumeRequestDocument.scope_context.segment_id
                segment_role = "resumed_successor_prepared"
                continuity_state = "supervised_resume_prepared"
                git_context = $resumeResultDocument.git_context
                supervision = $resumeResultDocument.supervision
            }
        )
        authoritative_refs = $resumeResultDocument.authoritative_refs
        non_claims = @(
            "stitching_only_no_rollback_plan_no_rollback_drill_no_unattended_recovery"
        )
        notes = "This continuity ledger stitches one interrupted segment to one supervised prepared successor segment from accepted R7 fault, checkpoint, handoff, and resume artifacts only. It does not generate rollback plans, execute rollback drills, or imply unattended recovery."
    }

    $savedLedgerPath = Write-JsonDocument -Document $ledger -OutputPath $LedgerPath
    $validation = Test-MilestoneContinuityLedgerContract -LedgerPath $savedLedgerPath

    return [pscustomobject]@{
        Ledger = $ledger
        LedgerPath = $savedLedgerPath
        Validation = $validation
        SourceArtifacts = [pscustomobject]@{
            FaultEventId = $faultEventValidation.EventId
            CheckpointId = $checkpointValidation.ArtifactId
            HandoffId = $handoffValidation.ArtifactId
            ResumeRequestId = $resumeRequestValidation.ResumeRequestId
            ResumeResultId = $resumeResultValidation.ResumeResultId
        }
    }
}

Export-ModuleMember -Function Test-MilestoneContinuityLedgerContract, Test-MilestoneContinuityLedgerObject, Get-MilestoneContinuityLedger, Invoke-MilestoneContinuityLedgerStitch
