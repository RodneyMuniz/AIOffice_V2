Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$proposalModule = Import-Module (Join-Path $PSScriptRoot "MilestoneAutocycleProposal.psm1") -Force -PassThru
$testMilestoneAutocycleProposalContract = $proposalModule.ExportedCommands["Test-MilestoneAutocycleProposalContract"]
$getMilestoneAutocycleProposal = $proposalModule.ExportedCommands["Get-MilestoneAutocycleProposal"]

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

function Get-UtcTimestamp {
    param(
        [datetime]$DateTime = (Get-Date).ToUniversalTime()
    )

    return $DateTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
}

function Get-MilestoneAutocycleFoundationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_autocycle\foundation.contract.json") -Label "Milestone autocycle foundation contract"
}

function Get-MilestoneAutocycleApprovalContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_autocycle\approval.contract.json") -Label "Milestone autocycle approval contract"
}

function Get-MilestoneAutocycleFreezeContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_autocycle\freeze.contract.json") -Label "Milestone autocycle freeze contract"
}

function Get-ValidatedProposalInput {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProposalPath
    )

    $proposalValidation = & $testMilestoneAutocycleProposalContract -ProposalPath $ProposalPath
    $proposal = & $getMilestoneAutocycleProposal -ProposalPath $proposalValidation.ProposalPath
    if ($proposal.status -ne "proposal_ready") {
        throw "Milestone freeze requires proposal '$($proposal.proposal_id)' to be in status 'proposal_ready'."
    }

    return [pscustomobject]@{
        Validation = $proposalValidation
        Proposal   = $proposal
        Directory  = (Split-Path -Parent $proposalValidation.ProposalPath)
    }
}

function New-OperatorAuthority {
    param(
        [Parameter(Mandatory = $true)]
        [string]$OperatorId,
        [Parameter(Mandatory = $true)]
        [string]$Status
    )

    return [pscustomobject]@{
        authority_kind = "operator_controlled"
        operator_id    = $OperatorId
        approval_basis = "explicit_operator_decision"
        status         = $Status
        notes          = if ($Status -eq "approved") { "Operator explicitly approved the milestone proposal freeze." } else { "Operator explicitly rejected the milestone proposal freeze." }
    }
}

function Assert-FrozenTaskSetMatchesProposal {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$FrozenTaskSet,
        [Parameter(Mandatory = $true)]
        [object[]]$ProposalTaskSet,
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory,
        [Parameter(Mandatory = $true)]
        [string]$ProposalPath
    )

    $freezeContract = Get-MilestoneAutocycleFreezeContract

    if ($FrozenTaskSet.Count -ne $ProposalTaskSet.Count) {
        throw "Milestone freeze.frozen_task_set must match the proposal task count exactly."
    }

    for ($index = 0; $index -lt $FrozenTaskSet.Count; $index += 1) {
        $frozenTask = $FrozenTaskSet[$index]
        $proposalTask = $ProposalTaskSet[$index]
        $taskContext = "Milestone freeze.frozen_task_set[$index]"

        foreach ($fieldName in @($freezeContract.required_task_fields)) {
            Get-RequiredProperty -Object $frozenTask -Name $fieldName -Context $taskContext | Out-Null
        }

        foreach ($fieldName in @("sequence", "task_id", "title", "status", "task_kind", "scope_summary", "requested_outcome", "notes")) {
            if ($frozenTask.$fieldName -ne $proposalTask.$fieldName) {
                throw "$taskContext.$fieldName must match the referenced proposal task set exactly."
            }
        }

        foreach ($fieldName in @("acceptance_checks", "non_goals", "depends_on_ids")) {
            if ((@($frozenTask.$fieldName) -join "|") -ne (@($proposalTask.$fieldName) -join "|")) {
                throw "$taskContext.$fieldName must match the referenced proposal task set exactly."
            }
        }

        foreach ($fieldName in @("object_type", "object_id")) {
            if ($frozenTask.parent.$fieldName -ne $proposalTask.parent.$fieldName) {
                throw "$taskContext.parent.$fieldName must match the referenced proposal task set exactly."
            }
        }

        $resolvedFrozenParentPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $frozenTask.parent -Name "ref" -Context "$taskContext.parent") -Context "$taskContext.parent.ref") -Label "$taskContext parent"
        $resolvedProposalParentPath = Resolve-ReferenceAgainstBase -BaseDirectory (Split-Path -Parent $ProposalPath) -Reference $proposalTask.parent.ref -Label "Referenced proposal task parent"
        if ($resolvedFrozenParentPath -ne $resolvedProposalParentPath) {
            throw "$taskContext.parent.ref must resolve to the same milestone as the proposal task set."
        }
    }
}

function Validate-ApprovalFields {
    param(
        [Parameter(Mandatory = $true)]
        $Approval,
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory
    )

    $foundation = Get-MilestoneAutocycleFoundationContract
    $approvalContract = Get-MilestoneAutocycleApprovalContract

    foreach ($fieldName in @($approvalContract.required_fields)) {
        Get-RequiredProperty -Object $Approval -Name $fieldName -Context "Milestone approval" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Approval -Name "contract_version" -Context "Milestone approval") -Context "Milestone approval.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "Milestone approval.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Approval -Name "record_type" -Context "Milestone approval") -Context "Milestone approval.record_type"
    if ($recordType -ne $foundation.approval_record_type -or $recordType -ne $approvalContract.record_type) {
        throw "Milestone approval.record_type must equal '$($foundation.approval_record_type)'."
    }

    $decisionId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Approval -Name "decision_id" -Context "Milestone approval") -Context "Milestone approval.decision_id"
    Assert-RegexMatch -Value $decisionId -Pattern $foundation.identifier_pattern -Context "Milestone approval.decision_id"
    $cycleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Approval -Name "cycle_id" -Context "Milestone approval") -Context "Milestone approval.cycle_id"
    Assert-RegexMatch -Value $cycleId -Pattern $foundation.identifier_pattern -Context "Milestone approval.cycle_id"

    $proposalPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Approval -Name "proposal_ref" -Context "Milestone approval") -Context "Milestone approval.proposal_ref") -Label "Milestone approval proposal"
    $proposalInput = Get-ValidatedProposalInput -ProposalPath $proposalPath
    $proposalId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Approval -Name "proposal_id" -Context "Milestone approval") -Context "Milestone approval.proposal_id"
    if ($proposalId -ne $proposalInput.Proposal.proposal_id) {
        throw "Milestone approval.proposal_id must match the referenced proposal."
    }

    $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Approval -Name "status" -Context "Milestone approval") -Context "Milestone approval.status"
    Assert-AllowedValue -Value $status -AllowedValues @($foundation.allowed_approval_statuses) -Context "Milestone approval.status"

    $decidedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Approval -Name "decided_at" -Context "Milestone approval") -Context "Milestone approval.decided_at"
    Assert-RegexMatch -Value $decidedAt -Pattern $foundation.timestamp_pattern -Context "Milestone approval.decided_at"
    $decidedBy = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Approval -Name "decided_by" -Context "Milestone approval") -Context "Milestone approval.decided_by"
    Assert-RegexMatch -Value $decidedBy -Pattern $foundation.operator_pattern -Context "Milestone approval.decided_by"

    $operatorAuthority = Assert-ObjectValue -Value (Get-RequiredProperty -Object $Approval -Name "operator_authority" -Context "Milestone approval") -Context "Milestone approval.operator_authority"
    if ((Assert-NonEmptyString -Value (Get-RequiredProperty -Object $operatorAuthority -Name "authority_kind" -Context "Milestone approval.operator_authority") -Context "Milestone approval.operator_authority.authority_kind") -ne "operator_controlled") {
        throw "Milestone approval.operator_authority.authority_kind must equal 'operator_controlled'."
    }
    if ((Assert-NonEmptyString -Value (Get-RequiredProperty -Object $operatorAuthority -Name "operator_id" -Context "Milestone approval.operator_authority") -Context "Milestone approval.operator_authority.operator_id") -ne $decidedBy) {
        throw "Milestone approval.operator_authority.operator_id must match decided_by."
    }
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $operatorAuthority -Name "approval_basis" -Context "Milestone approval.operator_authority") -Context "Milestone approval.operator_authority.approval_basis" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $operatorAuthority -Name "notes" -Context "Milestone approval.operator_authority") -Context "Milestone approval.operator_authority.notes" | Out-Null

    $rejectionReasons = [string[]](Assert-StringArray -Value (Get-RequiredProperty -Object $Approval -Name "rejection_reasons" -Context "Milestone approval") -Context "Milestone approval.rejection_reasons" -AllowEmpty)
    if ($status -eq "approved" -and $rejectionReasons.Count -ne 0) {
        throw "Approved milestone approvals must keep rejection_reasons empty."
    }
    if ($status -eq "rejected" -and $rejectionReasons.Count -eq 0) {
        throw "Rejected milestone approvals must include at least one rejection reason."
    }

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Approval -Name "notes" -Context "Milestone approval") -Context "Milestone approval.notes" | Out-Null

    return [pscustomobject]@{
        DecisionId    = $decisionId
        CycleId       = $cycleId
        ProposalPath  = $proposalInput.Validation.ProposalPath
        ProposalId    = $proposalInput.Proposal.proposal_id
        Status        = $status
        RejectionReasons = $rejectionReasons
    }
}

function Test-MilestoneAutocycleApprovalContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ApprovalPath
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $ApprovalPath -Label "Milestone approval"
    $approval = Get-JsonDocument -Path $resolvedPath -Label "Milestone approval"
    $result = Validate-ApprovalFields -Approval $approval -BaseDirectory (Split-Path -Parent $resolvedPath)

    return [pscustomobject]@{
        IsValid      = $true
        DecisionId   = $result.DecisionId
        ApprovalPath = $resolvedPath
        ProposalPath = $result.ProposalPath
        ProposalId   = $result.ProposalId
        Status       = $result.Status
        CycleId      = $result.CycleId
    }
}

function Validate-FreezeFields {
    param(
        [Parameter(Mandatory = $true)]
        $Freeze,
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory
    )

    $foundation = Get-MilestoneAutocycleFoundationContract
    $freezeContract = Get-MilestoneAutocycleFreezeContract

    foreach ($fieldName in @($freezeContract.required_fields)) {
        Get-RequiredProperty -Object $Freeze -Name $fieldName -Context "Milestone freeze" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Freeze -Name "contract_version" -Context "Milestone freeze") -Context "Milestone freeze.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "Milestone freeze.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Freeze -Name "record_type" -Context "Milestone freeze") -Context "Milestone freeze.record_type"
    if ($recordType -ne $foundation.freeze_record_type -or $recordType -ne $freezeContract.record_type) {
        throw "Milestone freeze.record_type must equal '$($foundation.freeze_record_type)'."
    }

    $freezeId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Freeze -Name "freeze_id" -Context "Milestone freeze") -Context "Milestone freeze.freeze_id"
    Assert-RegexMatch -Value $freezeId -Pattern $foundation.identifier_pattern -Context "Milestone freeze.freeze_id"
    $cycleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Freeze -Name "cycle_id" -Context "Milestone freeze") -Context "Milestone freeze.cycle_id"
    Assert-RegexMatch -Value $cycleId -Pattern $foundation.identifier_pattern -Context "Milestone freeze.cycle_id"

    $proposalPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Freeze -Name "proposal_ref" -Context "Milestone freeze") -Context "Milestone freeze.proposal_ref") -Label "Milestone freeze proposal"
    $proposalInput = Get-ValidatedProposalInput -ProposalPath $proposalPath
    $proposalId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Freeze -Name "proposal_id" -Context "Milestone freeze") -Context "Milestone freeze.proposal_id"
    if ($proposalId -ne $proposalInput.Proposal.proposal_id) {
        throw "Milestone freeze.proposal_id must match the referenced proposal."
    }

    $approvalStatus = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Freeze -Name "approval_status" -Context "Milestone freeze") -Context "Milestone freeze.approval_status"
    Assert-AllowedValue -Value $approvalStatus -AllowedValues @($freezeContract.allowed_approval_statuses) -Context "Milestone freeze.approval_status"
    $approvedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Freeze -Name "approved_at" -Context "Milestone freeze") -Context "Milestone freeze.approved_at"
    Assert-RegexMatch -Value $approvedAt -Pattern $foundation.timestamp_pattern -Context "Milestone freeze.approved_at"
    $approvedBy = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Freeze -Name "approved_by" -Context "Milestone freeze") -Context "Milestone freeze.approved_by"
    Assert-RegexMatch -Value $approvedBy -Pattern $foundation.operator_pattern -Context "Milestone freeze.approved_by"

    $operatorAuthority = Assert-ObjectValue -Value (Get-RequiredProperty -Object $Freeze -Name "operator_authority" -Context "Milestone freeze") -Context "Milestone freeze.operator_authority"
    if ((Assert-NonEmptyString -Value (Get-RequiredProperty -Object $operatorAuthority -Name "authority_kind" -Context "Milestone freeze.operator_authority") -Context "Milestone freeze.operator_authority.authority_kind") -ne "operator_controlled") {
        throw "Milestone freeze.operator_authority.authority_kind must equal 'operator_controlled'."
    }
    if ((Assert-NonEmptyString -Value (Get-RequiredProperty -Object $operatorAuthority -Name "operator_id" -Context "Milestone freeze.operator_authority") -Context "Milestone freeze.operator_authority.operator_id") -ne $approvedBy) {
        throw "Milestone freeze.operator_authority.operator_id must match approved_by."
    }
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $operatorAuthority -Name "approval_basis" -Context "Milestone freeze.operator_authority") -Context "Milestone freeze.operator_authority.approval_basis" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $operatorAuthority -Name "notes" -Context "Milestone freeze.operator_authority") -Context "Milestone freeze.operator_authority.notes" | Out-Null

    $frozenTaskSet = [object[]](Assert-ObjectArray -Value (Get-RequiredProperty -Object $Freeze -Name "frozen_task_set" -Context "Milestone freeze") -Context "Milestone freeze.frozen_task_set")
    Assert-FrozenTaskSetMatchesProposal -FrozenTaskSet $frozenTaskSet -ProposalTaskSet ([object[]]@($proposalInput.Proposal.proposed_task_set)) -BaseDirectory $BaseDirectory -ProposalPath $proposalInput.Validation.ProposalPath
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Freeze -Name "notes" -Context "Milestone freeze") -Context "Milestone freeze.notes" | Out-Null

    return [pscustomobject]@{
        FreezeId     = $freezeId
        CycleId      = $cycleId
        ProposalPath = $proposalInput.Validation.ProposalPath
        ProposalId   = $proposalInput.Proposal.proposal_id
        TaskCount    = $frozenTaskSet.Count
    }
}

function Test-MilestoneAutocycleFreezeContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$FreezePath
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $FreezePath -Label "Milestone freeze"
    $freeze = Get-JsonDocument -Path $resolvedPath -Label "Milestone freeze"
    $result = Validate-FreezeFields -Freeze $freeze -BaseDirectory (Split-Path -Parent $resolvedPath)

    return [pscustomobject]@{
        IsValid     = $true
        FreezeId    = $result.FreezeId
        FreezePath  = $resolvedPath
        CycleId     = $result.CycleId
        ProposalId  = $result.ProposalId
        ProposalPath = $result.ProposalPath
        TaskCount   = $result.TaskCount
    }
}

function Invoke-MilestoneAutocycleApprovalFlow {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProposalPath,
        [Parameter(Mandatory = $true)]
        [ValidateSet("approved", "rejected")]
        [string]$DecisionStatus,
        [Parameter(Mandatory = $true)]
        [string]$OperatorId,
        [Parameter(Mandatory = $true)]
        [string]$CycleId,
        [Parameter(Mandatory = $true)]
        [string]$OutputRoot,
        [string]$DecisionId,
        [string]$FreezeId,
        [string[]]$RejectionReasons = @(),
        [datetime]$DecidedAt = (Get-Date).ToUniversalTime(),
        [string]$Notes = "Milestone proposal decision recorded under explicit operator control only."
    )

    $foundation = Get-MilestoneAutocycleFoundationContract
    $proposalInput = Get-ValidatedProposalInput -ProposalPath $ProposalPath
    Assert-RegexMatch -Value $OperatorId -Pattern $foundation.operator_pattern -Context "OperatorId"
    Assert-RegexMatch -Value $CycleId -Pattern $foundation.identifier_pattern -Context "CycleId"
    Assert-NonEmptyString -Value $Notes -Context "Notes" | Out-Null

    if ([string]::IsNullOrWhiteSpace($DecisionId)) {
        $DecisionId = "decision-{0}" -f $proposalInput.Proposal.proposal_id
    }
    Assert-RegexMatch -Value $DecisionId -Pattern $foundation.identifier_pattern -Context "DecisionId"

    $rejectionReasons = [string[]]@($RejectionReasons | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    if ($DecisionStatus -eq "approved" -and $rejectionReasons.Count -ne 0) {
        throw "Approved milestone proposal decisions must not include rejection reasons."
    }
    if ($DecisionStatus -eq "rejected" -and $rejectionReasons.Count -eq 0) {
        throw "Rejected milestone proposal decisions must include at least one rejection reason."
    }

    if ($DecisionStatus -eq "approved" -and [string]::IsNullOrWhiteSpace($FreezeId)) {
        $FreezeId = "freeze-{0}" -f $proposalInput.Proposal.proposal_id
    }
    if ($DecisionStatus -eq "approved") {
        Assert-RegexMatch -Value $FreezeId -Pattern $foundation.identifier_pattern -Context "FreezeId"
    }

    $resolvedOutputRoot = Resolve-PathValue -PathValue $OutputRoot -AnchorPath (Get-ModuleRepositoryRootPath)
    if (-not (Test-Path -LiteralPath $resolvedOutputRoot)) {
        New-Item -ItemType Directory -Path $resolvedOutputRoot -Force | Out-Null
    }

    $approvalDirectory = Join-Path $resolvedOutputRoot "approvals"
    if (-not (Test-Path -LiteralPath $approvalDirectory)) {
        New-Item -ItemType Directory -Path $approvalDirectory -Force | Out-Null
    }

    $approval = [pscustomobject]@{
        contract_version  = $foundation.contract_version
        record_type       = $foundation.approval_record_type
        decision_id       = $DecisionId
        cycle_id          = $CycleId
        proposal_id       = $proposalInput.Proposal.proposal_id
        proposal_ref      = Get-RelativeReference -BaseDirectory $approvalDirectory -TargetPath $proposalInput.Validation.ProposalPath
        status            = $DecisionStatus
        decided_at        = Get-UtcTimestamp -DateTime $DecidedAt
        decided_by        = $OperatorId
        operator_authority = New-OperatorAuthority -OperatorId $OperatorId -Status $DecisionStatus
        rejection_reasons = @($rejectionReasons)
        notes             = $Notes
    }

    $approvalPath = Join-Path $approvalDirectory ("{0}.json" -f $DecisionId)
    Write-JsonDocument -Path $approvalPath -Document $approval
    $approvalValidation = Test-MilestoneAutocycleApprovalContract -ApprovalPath $approvalPath

    $freezePath = $null
    $freezeValidation = $null
    if ($DecisionStatus -eq "approved") {
        $freezeDirectory = Join-Path $resolvedOutputRoot "freezes"
        if (-not (Test-Path -LiteralPath $freezeDirectory)) {
            New-Item -ItemType Directory -Path $freezeDirectory -Force | Out-Null
        }

        $frozenTaskSet = @($proposalInput.Proposal.proposed_task_set | ForEach-Object {
                $resolvedParentPath = Resolve-ReferenceAgainstBase -BaseDirectory $proposalInput.Directory -Reference $_.parent.ref -Label "Proposal task parent"
                [pscustomobject]@{
                    sequence          = $_.sequence
                    task_id           = $_.task_id
                    title             = $_.title
                    status            = $_.status
                    parent            = [pscustomobject]@{
                        object_type = $_.parent.object_type
                        object_id   = $_.parent.object_id
                        ref         = Get-RelativeReference -BaseDirectory $freezeDirectory -TargetPath $resolvedParentPath
                    }
                    task_kind         = $_.task_kind
                    scope_summary     = $_.scope_summary
                    requested_outcome = $_.requested_outcome
                    acceptance_checks = @($_.acceptance_checks)
                    non_goals         = @($_.non_goals)
                    depends_on_ids    = @($_.depends_on_ids)
                    notes             = $_.notes
                }
            })

        $freeze = [pscustomobject]@{
            contract_version  = $foundation.contract_version
            record_type       = $foundation.freeze_record_type
            freeze_id         = $FreezeId
            cycle_id          = $CycleId
            proposal_id       = $proposalInput.Proposal.proposal_id
            proposal_ref      = Get-RelativeReference -BaseDirectory $freezeDirectory -TargetPath $proposalInput.Validation.ProposalPath
            approved_at       = Get-UtcTimestamp -DateTime $DecidedAt
            approved_by       = $OperatorId
            approval_status   = "approved"
            frozen_task_set   = @($frozenTaskSet)
            operator_authority = New-OperatorAuthority -OperatorId $OperatorId -Status "approved"
            notes             = "Milestone proposal frozen under explicit operator approval only."
        }

        $freezePath = Join-Path $freezeDirectory ("{0}.json" -f $FreezeId)
        Write-JsonDocument -Path $freezePath -Document $freeze
        $freezeValidation = Test-MilestoneAutocycleFreezeContract -FreezePath $freezePath
    }

    return [pscustomobject]@{
        ApprovalValidation = $approvalValidation
        FreezeValidation   = $freezeValidation
        ApprovalPath       = $approvalValidation.ApprovalPath
        FreezePath         = $freezePath
        DecisionStatus     = $DecisionStatus
    }
}

Export-ModuleMember -Function Test-MilestoneAutocycleApprovalContract, Test-MilestoneAutocycleFreezeContract, Invoke-MilestoneAutocycleApprovalFlow
