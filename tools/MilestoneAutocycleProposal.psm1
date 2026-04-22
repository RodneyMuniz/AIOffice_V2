Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$workArtifactValidationModule = Import-Module (Join-Path $PSScriptRoot "WorkArtifactValidation.psm1") -Force -PassThru
$governedWorkObjectValidationModule = Import-Module (Join-Path $PSScriptRoot "GovernedWorkObjectValidation.psm1") -Force -PassThru
$testWorkArtifactContract = $workArtifactValidationModule.ExportedCommands["Test-WorkArtifactContract"]
$testGovernedWorkObjectContract = $governedWorkObjectValidationModule.ExportedCommands["Test-GovernedWorkObjectContract"]

function Get-RepositoryRoot {
    return $repoRoot
}

function Get-ModuleRepositoryRootPath {
    return (Resolve-Path -LiteralPath (Get-RepositoryRoot)).Path
}

function Resolve-PathValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [string]$AnchorPath = (Get-ModuleRepositoryRootPath)
    )

    Assert-NonEmptyString -Value $PathValue -Context "Path value" | Out-Null

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    $resolvedAnchorPath = if (Test-Path -LiteralPath $AnchorPath) {
        (Resolve-Path -LiteralPath $AnchorPath).Path
    }
    else {
        [System.IO.Path]::GetFullPath($AnchorPath)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $resolvedAnchorPath $PathValue))
}

function Resolve-ExistingPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [string]$AnchorPath = (Get-ModuleRepositoryRootPath)
    )

    $resolvedPath = Resolve-PathValue -PathValue $PathValue -AnchorPath $AnchorPath
    if (-not (Test-Path -LiteralPath $resolvedPath)) {
        throw "$Label '$PathValue' does not exist."
    }

    return (Resolve-Path -LiteralPath $resolvedPath).Path
}

function Resolve-ReferenceAgainstBase {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory,
        [Parameter(Mandatory = $true)]
        [string]$Reference,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    if ([System.IO.Path]::IsPathRooted($Reference)) {
        $candidate = $Reference
    }
    else {
        $candidate = Join-Path $BaseDirectory ($Reference -replace "[/\\]", [System.IO.Path]::DirectorySeparatorChar)
    }

    if (-not (Test-Path -LiteralPath $candidate)) {
        throw "$Label reference '$Reference' does not exist."
    }

    return (Resolve-Path -LiteralPath $candidate).Path
}

function Get-RelativeReference {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory,
        [Parameter(Mandatory = $true)]
        [string]$TargetPath
    )

    $resolvedBaseDirectory = Resolve-ExistingPath -PathValue $BaseDirectory -Label "Base directory"
    $resolvedTargetPath = Resolve-ExistingPath -PathValue $TargetPath -Label "Target path"
    $baseUri = [System.Uri]("{0}{1}" -f $resolvedBaseDirectory.TrimEnd("\/"), [System.IO.Path]::DirectorySeparatorChar)
    $targetUri = [System.Uri]$resolvedTargetPath
    return ($baseUri.MakeRelativeUri($targetUri).OriginalString).Replace("\", "/")
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
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Document
    )

    $json = $Document | ConvertTo-Json -Depth 20
    Set-Content -LiteralPath $Path -Value $json -Encoding UTF8
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

function Assert-IntegerValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -is [int]) {
        return $Value
    }

    if ($Value -is [long] -and $Value -ge [int]::MinValue -and $Value -le [int]::MaxValue) {
        return [int]$Value
    }

    throw "$Context must be an integer."
}

function Assert-StringArray {
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

    Write-Output -NoEnumerate $items
}

function Assert-ObjectArray {
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
        if ($null -eq $item -or $item -is [string] -or $item -is [System.Array]) {
            throw "$Context item must be an object."
        }
    }

    Write-Output -NoEnumerate $items
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

function Get-UtcTimestamp {
    param(
        [datetime]$DateTime = (Get-Date).ToUniversalTime()
    )

    return $DateTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
}

function Get-MilestoneAutocycleFoundationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_autocycle\foundation.contract.json") -Label "Milestone autocycle foundation contract"
}

function Get-MilestoneAutocycleCycleContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_autocycle\milestone_cycle.contract.json") -Label "Milestone autocycle cycle contract"
}

function Get-MilestoneAutocycleProposalIntakeContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_autocycle\proposal_intake.contract.json") -Label "Milestone autocycle proposal intake contract"
}

function Get-MilestoneAutocycleProposalContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_autocycle\proposal.contract.json") -Label "Milestone autocycle proposal contract"
}

function Get-GovernedTaskContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\governed_work_objects\task.contract.json") -Label "Governed task contract"
}

function Get-GovernedMilestoneContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\governed_work_objects\milestone.contract.json") -Label "Governed milestone contract"
}

function Resolve-IntakeTaskDrafts {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$TaskDrafts,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $taskContract = Get-GovernedTaskContract
    $taskIds = [System.Collections.Generic.HashSet[string]]::new()
    $validatedDrafts = [System.Collections.Generic.List[object]]::new()

    foreach ($index in 0..($TaskDrafts.Count - 1)) {
        $taskDraft = $TaskDrafts[$index]
        $taskContext = "{0}[{1}]" -f $Context, $index
        $taskId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $taskDraft -Name "task_id" -Context $taskContext) -Context "$taskContext.task_id"
        if (-not $taskIds.Add($taskId)) {
            throw "$taskContext.task_id '$taskId' must be unique within the proposed task set."
        }

        $validatedDrafts.Add([pscustomobject]@{
                task_id           = $taskId
                title             = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $taskDraft -Name "title" -Context $taskContext) -Context "$taskContext.title"
                task_kind         = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $taskDraft -Name "task_kind" -Context $taskContext) -Context "$taskContext.task_kind"
                scope_summary     = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $taskDraft -Name "scope_summary" -Context $taskContext) -Context "$taskContext.scope_summary"
                requested_outcome = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $taskDraft -Name "requested_outcome" -Context $taskContext) -Context "$taskContext.requested_outcome"
                acceptance_checks = [string[]](Assert-StringArray -Value (Get-RequiredProperty -Object $taskDraft -Name "acceptance_checks" -Context $taskContext) -Context "$taskContext.acceptance_checks")
                non_goals         = [string[]](Assert-StringArray -Value (Get-RequiredProperty -Object $taskDraft -Name "non_goals" -Context $taskContext) -Context "$taskContext.non_goals")
                depends_on_ids    = if (Test-HasProperty -Object $taskDraft -Name "depends_on_ids") {
                    [string[]](Assert-StringArray -Value $taskDraft.depends_on_ids -Context "$taskContext.depends_on_ids" -AllowEmpty)
                }
                else {
                    @()
                }
                notes             = if (Test-HasProperty -Object $taskDraft -Name "notes") {
                    Assert-NonEmptyString -Value $taskDraft.notes -Context "$taskContext.notes"
                }
                else {
                    "Proposed from structured milestone autocycle intake."
                }
            }) | Out-Null

        Assert-AllowedValue -Value $validatedDrafts[$index].task_kind -AllowedValues @($taskContract.allowed_task_kinds) -Context "$taskContext.task_kind"
    }

    foreach ($taskDraft in @($validatedDrafts)) {
        foreach ($dependsOnId in @($taskDraft.depends_on_ids)) {
            if ($dependsOnId -eq $taskDraft.task_id) {
                throw "Proposed task '$($taskDraft.task_id)' must not depend on itself."
            }
            if (-not $taskIds.Contains($dependsOnId)) {
                throw "Proposed task '$($taskDraft.task_id)' depends on unknown task id '$dependsOnId'."
            }
        }
    }

    return @($validatedDrafts)
}

function Get-ValidatedRequestBriefInput {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RequestBriefReference,
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory
    )

    $resolvedRequestBriefPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference $RequestBriefReference -Label "Milestone proposal request brief"
    $artifactCheck = & $testWorkArtifactContract -ArtifactPath $resolvedRequestBriefPath
    if ($artifactCheck.ArtifactType -ne "request_brief") {
        throw "Milestone proposal intake requires a request_brief artifact, but '$RequestBriefReference' resolved to artifact type '$($artifactCheck.ArtifactType)'."
    }

    $requestBrief = Get-JsonDocument -Path $artifactCheck.ArtifactPath -Label "Milestone proposal request brief"
    if ($requestBrief.status -ne "ready_for_planning") {
        throw "Milestone proposal intake requires request_brief '$($requestBrief.artifact_id)' to be in status 'ready_for_planning'."
    }

    return [pscustomobject]@{
        Validation = $artifactCheck
        Document   = $requestBrief
        Directory  = (Split-Path -Parent $artifactCheck.ArtifactPath)
    }
}

function Get-ValidatedMilestoneInput {
    param(
        [Parameter(Mandatory = $true)]
        [string]$MilestoneReference,
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory
    )

    $resolvedMilestonePath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference $MilestoneReference -Label "Milestone proposal target milestone"
    $milestoneValidation = & $testGovernedWorkObjectContract -WorkObjectPath $resolvedMilestonePath
    if ($milestoneValidation.ObjectType -ne "milestone") {
        throw "Milestone proposal intake requires a milestone target, but '$MilestoneReference' resolved to object type '$($milestoneValidation.ObjectType)'."
    }

    $milestoneDocument = Get-JsonDocument -Path $milestoneValidation.WorkObjectPath -Label "Milestone proposal target milestone"
    $milestoneContract = Get-GovernedMilestoneContract
    if (@($milestoneContract.lifecycle.terminal_statuses) -contains $milestoneDocument.status) {
        throw "Milestone proposal intake requires a non-terminal milestone target."
    }

    return [pscustomobject]@{
        Validation = $milestoneValidation
        Document   = $milestoneDocument
        Directory  = (Split-Path -Parent $milestoneValidation.WorkObjectPath)
    }
}

function Assert-RequestBriefTargetsMilestone {
    param(
        [Parameter(Mandatory = $true)]
        $RequestBriefInput,
        [Parameter(Mandatory = $true)]
        $MilestoneInput
    )

    $rawWorkObjectRefs = Get-RequiredProperty -Object $RequestBriefInput.Document -Name "work_object_refs" -Context "Milestone proposal request brief"
    $workObjectRefs = @($rawWorkObjectRefs)
    if ($rawWorkObjectRefs -is [string] -or $null -eq $rawWorkObjectRefs -or $workObjectRefs.Count -eq 0) {
        throw "Milestone proposal request brief.work_object_refs must be a non-empty array."
    }
    foreach ($workObjectRef in @($workObjectRefs)) {
        Assert-ObjectValue -Value $workObjectRef -Context "Milestone proposal request brief.work_object_refs item" | Out-Null
    }

    if ($workObjectRefs.Count -ne 1) {
        throw "Milestone proposal request brief must target exactly one governed milestone work object."
    }

    $workObjectRef = $workObjectRefs[0]
    $relation = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $workObjectRef -Name "relation" -Context "Milestone proposal request brief.work_object_refs[0]") -Context "Milestone proposal request brief.work_object_refs[0].relation"
    if ($relation -ne "targets") {
        throw "Milestone proposal request brief work object relation must equal 'targets'."
    }

    $objectType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $workObjectRef -Name "object_type" -Context "Milestone proposal request brief.work_object_refs[0]") -Context "Milestone proposal request brief.work_object_refs[0].object_type"
    if ($objectType -ne "milestone") {
        throw "Milestone proposal request brief must target a milestone work object only."
    }

    $resolvedRequestMilestonePath = Resolve-ReferenceAgainstBase -BaseDirectory $RequestBriefInput.Directory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $workObjectRef -Name "ref" -Context "Milestone proposal request brief.work_object_refs[0]") -Context "Milestone proposal request brief.work_object_refs[0].ref") -Label "Milestone proposal request brief target"
    if ($resolvedRequestMilestonePath -ne $MilestoneInput.Validation.WorkObjectPath) {
        throw "Milestone proposal request brief target must match the intake milestone_ref exactly."
    }

    $objectId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $workObjectRef -Name "object_id" -Context "Milestone proposal request brief.work_object_refs[0]") -Context "Milestone proposal request brief.work_object_refs[0].object_id"
    if ($objectId -ne $MilestoneInput.Validation.ObjectId) {
        throw "Milestone proposal request brief target object_id must match the intake milestone target."
    }
}

function Validate-ProposalIntakeFields {
    param(
        [Parameter(Mandatory = $true)]
        $ProposalIntake,
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory
    )

    $foundation = Get-MilestoneAutocycleFoundationContract
    $proposalIntakeContract = Get-MilestoneAutocycleProposalIntakeContract
    $cycleContract = Get-MilestoneAutocycleCycleContract

    foreach ($fieldName in @($proposalIntakeContract.required_fields)) {
        Get-RequiredProperty -Object $ProposalIntake -Name $fieldName -Context "Milestone proposal intake" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ProposalIntake -Name "contract_version" -Context "Milestone proposal intake") -Context "Milestone proposal intake.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "Milestone proposal intake.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ProposalIntake -Name "record_type" -Context "Milestone proposal intake") -Context "Milestone proposal intake.record_type"
    if ($recordType -ne $foundation.proposal_intake_record_type -or $recordType -ne $proposalIntakeContract.record_type) {
        throw "Milestone proposal intake.record_type must equal '$($foundation.proposal_intake_record_type)'."
    }

    $intakeId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ProposalIntake -Name "intake_id" -Context "Milestone proposal intake") -Context "Milestone proposal intake.intake_id"
    Assert-RegexMatch -Value $intakeId -Pattern $foundation.identifier_pattern -Context "Milestone proposal intake.intake_id"

    $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ProposalIntake -Name "status" -Context "Milestone proposal intake") -Context "Milestone proposal intake.status"
    Assert-AllowedValue -Value $status -AllowedValues @($proposalIntakeContract.allowed_statuses) -Context "Milestone proposal intake.status"
    if ($status -ne "ready_for_proposal") {
        throw "Milestone proposal generation requires intake status 'ready_for_proposal'."
    }

    $scopeNotes = [string[]](Assert-StringArray -Value (Get-RequiredProperty -Object $ProposalIntake -Name "scope_notes" -Context "Milestone proposal intake") -Context "Milestone proposal intake.scope_notes" -AllowEmpty)
    $assumptions = [string[]](Assert-StringArray -Value (Get-RequiredProperty -Object $ProposalIntake -Name "assumptions" -Context "Milestone proposal intake") -Context "Milestone proposal intake.assumptions" -AllowEmpty)
    $notes = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ProposalIntake -Name "notes" -Context "Milestone proposal intake") -Context "Milestone proposal intake.notes"

    $requestBriefInput = Get-ValidatedRequestBriefInput -RequestBriefReference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ProposalIntake -Name "request_brief_ref" -Context "Milestone proposal intake") -Context "Milestone proposal intake.request_brief_ref") -BaseDirectory $BaseDirectory
    $milestoneInput = Get-ValidatedMilestoneInput -MilestoneReference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ProposalIntake -Name "milestone_ref" -Context "Milestone proposal intake") -Context "Milestone proposal intake.milestone_ref") -BaseDirectory $BaseDirectory
    Assert-RequestBriefTargetsMilestone -RequestBriefInput $requestBriefInput -MilestoneInput $milestoneInput

    $taskDrafts = [object[]](Assert-ObjectArray -Value (Get-RequiredProperty -Object $ProposalIntake -Name "proposed_tasks" -Context "Milestone proposal intake") -Context "Milestone proposal intake.proposed_tasks")
    $minTaskCount = [int](Get-MilestoneAutocycleCycleContract).boundary_rules.frozen_task_count_min
    $maxTaskCount = [int](Get-MilestoneAutocycleCycleContract).boundary_rules.frozen_task_count_max
    if ($taskDrafts.Count -lt $minTaskCount -or $taskDrafts.Count -gt $maxTaskCount) {
        throw "Milestone proposal intake.proposed_tasks count must stay within the bounded range of $minTaskCount to $maxTaskCount tasks."
    }

    $validatedDrafts = Resolve-IntakeTaskDrafts -TaskDrafts $taskDrafts -Context "Milestone proposal intake.proposed_tasks"

    return [pscustomobject]@{
        IntakeId          = $intakeId
        Status            = $status
        ScopeNotes        = $scopeNotes
        Assumptions       = $assumptions
        Notes             = $notes
        RequestBriefInput = $requestBriefInput
        MilestoneInput    = $milestoneInput
        TaskDrafts        = $validatedDrafts
    }
}

function Test-MilestoneAutocycleProposalIntakeContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProposalIntakePath
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $ProposalIntakePath -Label "Milestone proposal intake"
    $proposalIntake = Get-JsonDocument -Path $resolvedPath -Label "Milestone proposal intake"
    $result = Validate-ProposalIntakeFields -ProposalIntake $proposalIntake -BaseDirectory (Split-Path -Parent $resolvedPath)

    return [pscustomobject]@{
        IsValid           = $true
        IntakeId          = $result.IntakeId
        ProposalIntakePath = $resolvedPath
        RequestBriefPath  = $result.RequestBriefInput.Validation.ArtifactPath
        MilestonePath     = $result.MilestoneInput.Validation.WorkObjectPath
        TaskCount         = @($result.TaskDrafts).Count
    }
}

function New-MilestoneAutocycleProposal {
    param(
        [Parameter(Mandatory = $true)]
        $ProposalIntakeInput,
        [Parameter(Mandatory = $true)]
        [string]$ProposalId,
        [Parameter(Mandatory = $true)]
        [string]$ProposalDirectory
    )

    $milestoneRelativeRef = Get-RelativeReference -BaseDirectory $ProposalDirectory -TargetPath $ProposalIntakeInput.MilestoneInput.Validation.WorkObjectPath
    $proposalTasks = for ($index = 0; $index -lt @($ProposalIntakeInput.TaskDrafts).Count; $index += 1) {
        $taskDraft = $ProposalIntakeInput.TaskDrafts[$index]
        [pscustomobject]@{
            sequence          = $index + 1
            task_id           = $taskDraft.task_id
            title             = $taskDraft.title
            status            = "proposed"
            parent            = [pscustomobject]@{
                object_type = "milestone"
                object_id   = $ProposalIntakeInput.MilestoneInput.Validation.ObjectId
                ref         = $milestoneRelativeRef
            }
            task_kind         = $taskDraft.task_kind
            scope_summary     = $taskDraft.scope_summary
            requested_outcome = $taskDraft.requested_outcome
            acceptance_checks = @($taskDraft.acceptance_checks)
            non_goals         = @($taskDraft.non_goals)
            depends_on_ids    = @($taskDraft.depends_on_ids)
            notes             = $taskDraft.notes
        }
    }

    return [pscustomobject]@{
        contract_version = (Get-MilestoneAutocycleFoundationContract).contract_version
        record_type      = (Get-MilestoneAutocycleFoundationContract).proposal_record_type
        proposal_id      = $ProposalId
        intake_ref       = Get-RelativeReference -BaseDirectory $ProposalDirectory -TargetPath $ProposalIntakeInput.Validation.ProposalIntakePath
        request_brief_ref = Get-RelativeReference -BaseDirectory $ProposalDirectory -TargetPath $ProposalIntakeInput.RequestBriefInput.Validation.ArtifactPath
        milestone_ref    = $milestoneRelativeRef
        milestone_identity = [pscustomobject]@{
            object_type = "milestone"
            object_id   = $ProposalIntakeInput.MilestoneInput.Validation.ObjectId
            title       = $ProposalIntakeInput.MilestoneInput.Document.title
            status      = $ProposalIntakeInput.MilestoneInput.Document.status
        }
        proposed_task_set = @($proposalTasks)
        task_count       = @($proposalTasks).Count
        scope_notes      = @($ProposalIntakeInput.ScopeNotes)
        assumptions      = @($ProposalIntakeInput.Assumptions)
        status           = "proposal_ready"
        refusal_reasons  = @()
        notes            = "Structured milestone proposal generated from one ready-for-planning request brief and one milestone target only."
    }
}

function Validate-ProposalFields {
    param(
        [Parameter(Mandatory = $true)]
        $Proposal,
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory
    )

    $foundation = Get-MilestoneAutocycleFoundationContract
    $proposalContract = Get-MilestoneAutocycleProposalContract
    $proposalIntakeContract = Get-MilestoneAutocycleProposalIntakeContract
    $cycleContract = Get-MilestoneAutocycleCycleContract

    foreach ($fieldName in @($proposalContract.required_fields)) {
        Get-RequiredProperty -Object $Proposal -Name $fieldName -Context "Milestone proposal" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Proposal -Name "contract_version" -Context "Milestone proposal") -Context "Milestone proposal.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "Milestone proposal.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Proposal -Name "record_type" -Context "Milestone proposal") -Context "Milestone proposal.record_type"
    if ($recordType -ne $foundation.proposal_record_type -or $recordType -ne $proposalContract.record_type) {
        throw "Milestone proposal.record_type must equal '$($foundation.proposal_record_type)'."
    }

    $proposalId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Proposal -Name "proposal_id" -Context "Milestone proposal") -Context "Milestone proposal.proposal_id"
    Assert-RegexMatch -Value $proposalId -Pattern $foundation.identifier_pattern -Context "Milestone proposal.proposal_id"

    $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Proposal -Name "status" -Context "Milestone proposal") -Context "Milestone proposal.status"
    Assert-AllowedValue -Value $status -AllowedValues @($proposalContract.allowed_statuses) -Context "Milestone proposal.status"

    $scopeNotes = [string[]](Assert-StringArray -Value (Get-RequiredProperty -Object $Proposal -Name "scope_notes" -Context "Milestone proposal") -Context "Milestone proposal.scope_notes" -AllowEmpty)
    $assumptions = [string[]](Assert-StringArray -Value (Get-RequiredProperty -Object $Proposal -Name "assumptions" -Context "Milestone proposal") -Context "Milestone proposal.assumptions" -AllowEmpty)
    $refusalReasons = [string[]](Assert-StringArray -Value (Get-RequiredProperty -Object $Proposal -Name "refusal_reasons" -Context "Milestone proposal") -Context "Milestone proposal.refusal_reasons" -AllowEmpty)
    if ($status -eq "proposal_ready" -and $refusalReasons.Count -ne 0) {
        throw "Milestone proposal.refusal_reasons must be empty when status is 'proposal_ready'."
    }

    $intakePath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Proposal -Name "intake_ref" -Context "Milestone proposal") -Context "Milestone proposal.intake_ref") -Label "Milestone proposal intake"
    $proposalIntakeValidation = Test-MilestoneAutocycleProposalIntakeContract -ProposalIntakePath $intakePath
    $proposalIntake = Get-JsonDocument -Path $proposalIntakeValidation.ProposalIntakePath -Label "Milestone proposal intake"
    if ($proposalIntake.record_type -ne $proposalIntakeContract.record_type) {
        throw "Milestone proposal intake_ref must resolve to a milestone_autocycle proposal intake."
    }

    $requestBriefInput = Get-ValidatedRequestBriefInput -RequestBriefReference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Proposal -Name "request_brief_ref" -Context "Milestone proposal") -Context "Milestone proposal.request_brief_ref") -BaseDirectory $BaseDirectory
    if ($requestBriefInput.Validation.ArtifactPath -ne $proposalIntakeValidation.RequestBriefPath) {
        throw "Milestone proposal.request_brief_ref must match the intake request_brief_ref."
    }

    $milestoneInput = Get-ValidatedMilestoneInput -MilestoneReference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Proposal -Name "milestone_ref" -Context "Milestone proposal") -Context "Milestone proposal.milestone_ref") -BaseDirectory $BaseDirectory
    if ($milestoneInput.Validation.WorkObjectPath -ne $proposalIntakeValidation.MilestonePath) {
        throw "Milestone proposal.milestone_ref must match the intake milestone_ref."
    }

    $milestoneIdentity = Assert-ObjectValue -Value (Get-RequiredProperty -Object $Proposal -Name "milestone_identity" -Context "Milestone proposal") -Context "Milestone proposal.milestone_identity"
    if ((Assert-NonEmptyString -Value (Get-RequiredProperty -Object $milestoneIdentity -Name "object_type" -Context "Milestone proposal.milestone_identity") -Context "Milestone proposal.milestone_identity.object_type") -ne "milestone") {
        throw "Milestone proposal.milestone_identity.object_type must equal 'milestone'."
    }
    if ((Assert-NonEmptyString -Value (Get-RequiredProperty -Object $milestoneIdentity -Name "object_id" -Context "Milestone proposal.milestone_identity") -Context "Milestone proposal.milestone_identity.object_id") -ne $milestoneInput.Validation.ObjectId) {
        throw "Milestone proposal.milestone_identity.object_id must match the referenced milestone."
    }
    if ((Assert-NonEmptyString -Value (Get-RequiredProperty -Object $milestoneIdentity -Name "title" -Context "Milestone proposal.milestone_identity") -Context "Milestone proposal.milestone_identity.title") -ne $milestoneInput.Document.title) {
        throw "Milestone proposal.milestone_identity.title must match the referenced milestone."
    }

    $taskCount = Assert-IntegerValue -Value (Get-RequiredProperty -Object $Proposal -Name "task_count" -Context "Milestone proposal") -Context "Milestone proposal.task_count"
    $proposedTasks = [object[]](Assert-ObjectArray -Value (Get-RequiredProperty -Object $Proposal -Name "proposed_task_set" -Context "Milestone proposal") -Context "Milestone proposal.proposed_task_set")
    if ($taskCount -ne $proposedTasks.Count) {
        throw "Milestone proposal.task_count must equal the proposed_task_set count."
    }

    $minTaskCount = [int]$cycleContract.boundary_rules.frozen_task_count_min
    $maxTaskCount = [int]$cycleContract.boundary_rules.frozen_task_count_max
    if ($taskCount -lt $minTaskCount -or $taskCount -gt $maxTaskCount) {
        throw "Milestone proposal.task_count must stay within the bounded range of $minTaskCount to $maxTaskCount tasks."
    }

    $proposalTaskIds = [System.Collections.Generic.HashSet[string]]::new()
    for ($index = 0; $index -lt $proposedTasks.Count; $index += 1) {
        $task = $proposedTasks[$index]
        $taskContext = "Milestone proposal.proposed_task_set[$index]"
        foreach ($fieldName in @($proposalContract.required_task_fields)) {
            Get-RequiredProperty -Object $task -Name $fieldName -Context $taskContext | Out-Null
        }

        $sequence = Assert-IntegerValue -Value (Get-RequiredProperty -Object $task -Name "sequence" -Context $taskContext) -Context "$taskContext.sequence"
        if ($sequence -ne ($index + 1)) {
            throw "$taskContext.sequence must be contiguous and start at 1."
        }

        $taskId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $task -Name "task_id" -Context $taskContext) -Context "$taskContext.task_id"
        if (-not $proposalTaskIds.Add($taskId)) {
            throw "$taskContext.task_id '$taskId' must be unique within the proposal."
        }

        Assert-AllowedValue -Value (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $task -Name "status" -Context $taskContext) -Context "$taskContext.status") -AllowedValues @($proposalContract.allowed_task_statuses) -Context "$taskContext.status"
        Assert-AllowedValue -Value (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $task -Name "task_kind" -Context $taskContext) -Context "$taskContext.task_kind") -AllowedValues @((Get-GovernedTaskContract).allowed_task_kinds) -Context "$taskContext.task_kind"
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $task -Name "title" -Context $taskContext) -Context "$taskContext.title" | Out-Null
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $task -Name "scope_summary" -Context $taskContext) -Context "$taskContext.scope_summary" | Out-Null
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $task -Name "requested_outcome" -Context $taskContext) -Context "$taskContext.requested_outcome" | Out-Null
        Assert-StringArray -Value (Get-RequiredProperty -Object $task -Name "acceptance_checks" -Context $taskContext) -Context "$taskContext.acceptance_checks" | Out-Null
        Assert-StringArray -Value (Get-RequiredProperty -Object $task -Name "non_goals" -Context $taskContext) -Context "$taskContext.non_goals" | Out-Null
        $dependsOnIds = [string[]](Assert-StringArray -Value (Get-RequiredProperty -Object $task -Name "depends_on_ids" -Context $taskContext) -Context "$taskContext.depends_on_ids" -AllowEmpty)
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $task -Name "notes" -Context $taskContext) -Context "$taskContext.notes" | Out-Null

        $parent = Assert-ObjectValue -Value (Get-RequiredProperty -Object $task -Name "parent" -Context $taskContext) -Context "$taskContext.parent"
        if ((Assert-NonEmptyString -Value (Get-RequiredProperty -Object $parent -Name "object_type" -Context "$taskContext.parent") -Context "$taskContext.parent.object_type") -ne "milestone") {
            throw "$taskContext.parent.object_type must equal 'milestone'."
        }
        if ((Assert-NonEmptyString -Value (Get-RequiredProperty -Object $parent -Name "object_id" -Context "$taskContext.parent") -Context "$taskContext.parent.object_id") -ne $milestoneInput.Validation.ObjectId) {
            throw "$taskContext.parent.object_id must match the proposal milestone."
        }
        $resolvedParentPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $parent -Name "ref" -Context "$taskContext.parent") -Context "$taskContext.parent.ref") -Label "$taskContext parent"
        if ($resolvedParentPath -ne $milestoneInput.Validation.WorkObjectPath) {
            throw "$taskContext.parent.ref must resolve to the proposal milestone."
        }

        foreach ($dependsOnId in @($dependsOnIds)) {
            if ($dependsOnId -eq $taskId) {
                throw "$taskContext.depends_on_ids must not include the task's own id."
            }
        }
    }

    foreach ($task in @($proposedTasks)) {
        foreach ($dependsOnId in @($task.depends_on_ids)) {
            if (-not $proposalTaskIds.Contains($dependsOnId)) {
                throw "Milestone proposal task '$($task.task_id)' depends on unknown task id '$dependsOnId'."
            }
        }
    }

    return [pscustomobject]@{
        ProposalId     = $proposalId
        ProposalStatus = $status
        IntakePath     = $proposalIntakeValidation.ProposalIntakePath
        RequestBriefPath = $requestBriefInput.Validation.ArtifactPath
        MilestonePath  = $milestoneInput.Validation.WorkObjectPath
        TaskCount      = $taskCount
        ScopeNotes     = $scopeNotes
        Assumptions    = $assumptions
        RefusalReasons = $refusalReasons
    }
}

function Test-MilestoneAutocycleProposalContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProposalPath
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $ProposalPath -Label "Milestone proposal"
    $proposal = Get-JsonDocument -Path $resolvedPath -Label "Milestone proposal"
    $result = Validate-ProposalFields -Proposal $proposal -BaseDirectory (Split-Path -Parent $resolvedPath)

    return [pscustomobject]@{
        IsValid       = $true
        ProposalId    = $result.ProposalId
        ProposalPath  = $resolvedPath
        IntakePath    = $result.IntakePath
        RequestBriefPath = $result.RequestBriefPath
        MilestonePath = $result.MilestonePath
        TaskCount     = $result.TaskCount
    }
}

function Get-MilestoneAutocycleProposal {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProposalPath
    )

    $validation = Test-MilestoneAutocycleProposalContract -ProposalPath $ProposalPath
    return (Get-JsonDocument -Path $validation.ProposalPath -Label "Milestone proposal")
}

function Invoke-MilestoneAutocycleProposalFlow {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProposalIntakePath,
        [Parameter(Mandatory = $true)]
        [string]$OutputRoot,
        [string]$ProposalId,
        [datetime]$CreatedAt = (Get-Date).ToUniversalTime()
    )

    $intakeValidation = Test-MilestoneAutocycleProposalIntakeContract -ProposalIntakePath $ProposalIntakePath
    $proposalIntake = Get-JsonDocument -Path $intakeValidation.ProposalIntakePath -Label "Milestone proposal intake"
    $proposalInput = Validate-ProposalIntakeFields -ProposalIntake $proposalIntake -BaseDirectory (Split-Path -Parent $intakeValidation.ProposalIntakePath)
    $proposalInput | Add-Member -NotePropertyName Validation -NotePropertyValue $intakeValidation

    if ([string]::IsNullOrWhiteSpace($ProposalId)) {
        $ProposalId = "proposal-{0}" -f $proposalInput.IntakeId
    }

    Assert-RegexMatch -Value $ProposalId -Pattern (Get-MilestoneAutocycleFoundationContract).identifier_pattern -Context "ProposalId"

    $resolvedOutputRoot = Resolve-PathValue -PathValue $OutputRoot -AnchorPath (Get-ModuleRepositoryRootPath)
    if (-not (Test-Path -LiteralPath $resolvedOutputRoot)) {
        New-Item -ItemType Directory -Path $resolvedOutputRoot -Force | Out-Null
    }

    $proposalDirectory = Join-Path $resolvedOutputRoot "proposals"
    if (-not (Test-Path -LiteralPath $proposalDirectory)) {
        New-Item -ItemType Directory -Path $proposalDirectory -Force | Out-Null
    }

    $proposalPath = Join-Path $proposalDirectory ("{0}.json" -f $ProposalId)
    $proposal = New-MilestoneAutocycleProposal -ProposalIntakeInput $proposalInput -ProposalId $ProposalId -ProposalDirectory $proposalDirectory
    Write-JsonDocument -Path $proposalPath -Document $proposal
    $proposalValidation = Test-MilestoneAutocycleProposalContract -ProposalPath $proposalPath

    return [pscustomobject]@{
        ProposalIntakeValidation = $intakeValidation
        ProposalValidation       = $proposalValidation
        ProposalIntakePath       = $intakeValidation.ProposalIntakePath
        ProposalPath             = $proposalValidation.ProposalPath
        Proposal                 = $proposal
        CreatedAt                = Get-UtcTimestamp -DateTime $CreatedAt
    }
}

Export-ModuleMember -Function Test-MilestoneAutocycleProposalIntakeContract, Test-MilestoneAutocycleProposalContract, Get-MilestoneAutocycleProposal, Invoke-MilestoneAutocycleProposalFlow
