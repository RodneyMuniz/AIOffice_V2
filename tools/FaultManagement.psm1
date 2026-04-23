Set-StrictMode -Version Latest

function Resolve-EventPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$EventPath
    )

    if ([System.IO.Path]::IsPathRooted($EventPath)) {
        $resolvedPath = $EventPath
    }
    else {
        $resolvedPath = Join-Path (Get-Location) $EventPath
    }

    if (-not (Test-Path -LiteralPath $resolvedPath)) {
        throw "Fault event path '$EventPath' does not exist."
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

function Get-FaultManagementFoundationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\fault_management\foundation.contract.json") -Label "Fault management foundation contract"
}

function Get-FaultManagementEventContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\fault_management\fault_event.contract.json") -Label "Fault management event contract"
}

function Validate-CycleContext {
    param(
        [Parameter(Mandatory = $true)]
        $CycleContext,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $EventContract
    )

    foreach ($fieldName in @($EventContract.cycle_context_required_fields)) {
        Get-RequiredProperty -Object $CycleContext -Name $fieldName -Context "Fault event.cycle_context" | Out-Null
    }

    $cycleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $CycleContext -Name "cycle_id" -Context "Fault event.cycle_context") -Context "Fault event.cycle_context.cycle_id"
    Assert-RegexMatch -Value $cycleId -Pattern $Foundation.identifier_pattern -Context "Fault event.cycle_context.cycle_id"

    $milestoneId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $CycleContext -Name "milestone_id" -Context "Fault event.cycle_context") -Context "Fault event.cycle_context.milestone_id"
    Assert-RegexMatch -Value $milestoneId -Pattern $Foundation.identifier_pattern -Context "Fault event.cycle_context.milestone_id"

    $milestoneTitle = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $CycleContext -Name "milestone_title" -Context "Fault event.cycle_context") -Context "Fault event.cycle_context.milestone_title"

    return [pscustomobject]@{
        CycleId        = $cycleId
        MilestoneId    = $milestoneId
        MilestoneTitle = $milestoneTitle
    }
}

function Validate-AffectedScope {
    param(
        [Parameter(Mandatory = $true)]
        $AffectedScope,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $EventContract
    )

    foreach ($fieldName in @($EventContract.affected_scope_required_fields)) {
        Get-RequiredProperty -Object $AffectedScope -Name $fieldName -Context "Fault event.affected_scope" | Out-Null
    }

    $scopeLevel = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $AffectedScope -Name "scope_level" -Context "Fault event.affected_scope") -Context "Fault event.affected_scope.scope_level"
    Assert-AllowedValue -Value $scopeLevel -AllowedValues @($Foundation.allowed_scope_levels) -Context "Fault event.affected_scope.scope_level"

    $taskId = Assert-OptionalIdentifier -Object $AffectedScope -Name "task_id" -Pattern $Foundation.identifier_pattern -Context "Fault event.affected_scope"
    $segmentId = Assert-OptionalIdentifier -Object $AffectedScope -Name "segment_id" -Pattern $Foundation.identifier_pattern -Context "Fault event.affected_scope"

    if ($scopeLevel -eq "cycle") {
        if ($null -ne $taskId -or $null -ne $segmentId) {
            throw "Fault event.affected_scope must not include task_id or segment_id when scope_level is 'cycle'."
        }
    }

    if ($scopeLevel -eq "task" -and $null -eq $taskId) {
        throw "Fault event.affected_scope.task_id is required when scope_level is 'task'."
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
        $EventContract
    )

    foreach ($fieldName in @($EventContract.repository_required_fields)) {
        Get-RequiredProperty -Object $RepositoryContext -Name $fieldName -Context "Fault event.repository" | Out-Null
    }

    $repositoryName = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RepositoryContext -Name "repository_name" -Context "Fault event.repository") -Context "Fault event.repository.repository_name"
    if ($repositoryName -ne $Foundation.repository_name) {
        throw "Fault event.repository.repository_name must equal '$($Foundation.repository_name)'."
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
        $EventContract
    )

    foreach ($fieldName in @($EventContract.git_context_required_fields)) {
        Get-RequiredProperty -Object $GitContext -Name $fieldName -Context "Fault event.git_context" | Out-Null
    }

    $branch = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $GitContext -Name "branch" -Context "Fault event.git_context") -Context "Fault event.git_context.branch"
    Assert-RegexMatch -Value $branch -Pattern $Foundation.branch_pattern -Context "Fault event.git_context.branch"

    $headCommit = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $GitContext -Name "head_commit" -Context "Fault event.git_context") -Context "Fault event.git_context.head_commit"
    Assert-RegexMatch -Value $headCommit -Pattern $Foundation.git_object_pattern -Context "Fault event.git_context.head_commit"

    $treeId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $GitContext -Name "tree_id" -Context "Fault event.git_context") -Context "Fault event.git_context.tree_id"
    Assert-RegexMatch -Value $treeId -Pattern $Foundation.git_object_pattern -Context "Fault event.git_context.tree_id"

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
        $EventContract
    )

    foreach ($fieldName in @($EventContract.supervision_required_fields)) {
        Get-RequiredProperty -Object $Supervision -Name $fieldName -Context "Fault event.supervision" | Out-Null
    }

    $mode = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Supervision -Name "mode" -Context "Fault event.supervision") -Context "Fault event.supervision.mode"
    Assert-AllowedValue -Value $mode -AllowedValues @($Foundation.allowed_supervision_modes) -Context "Fault event.supervision.mode"

    $operatorAuthority = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Supervision -Name "operator_authority" -Context "Fault event.supervision") -Context "Fault event.supervision.operator_authority"
    Assert-RegexMatch -Value $operatorAuthority -Pattern $Foundation.operator_pattern -Context "Fault event.supervision.operator_authority"

    $resumeAuthorityState = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Supervision -Name "resume_authority_state" -Context "Fault event.supervision") -Context "Fault event.supervision.resume_authority_state"
    Assert-AllowedValue -Value $resumeAuthorityState -AllowedValues @($Foundation.allowed_resume_authority_states) -Context "Fault event.supervision.resume_authority_state"

    return [pscustomobject]@{
        Mode                 = $mode
        OperatorAuthority    = $operatorAuthority
        ResumeAuthorityState = $resumeAuthorityState
    }
}

function Validate-EventClassification {
    param(
        [Parameter(Mandatory = $true)]
        [string]$EventType,
        [Parameter(Mandatory = $true)]
        [string]$EventCategory,
        [Parameter(Mandatory = $true)]
        [string]$TriggerClassification,
        [Parameter(Mandatory = $true)]
        [string]$RequiredNextAction,
        [Parameter(Mandatory = $true)]
        [string]$AutomaticRecoveryClaim,
        [Parameter(Mandatory = $true)]
        $Foundation
    )

    Assert-AllowedValue -Value $EventType -AllowedValues @($Foundation.allowed_event_types) -Context "Fault event.event_type"
    switch ($EventType) {
        "interruption" {
            Assert-AllowedValue -Value $EventCategory -AllowedValues @($Foundation.allowed_interruption_categories) -Context "Fault event.event_category"
        }
        "fault" {
            Assert-AllowedValue -Value $EventCategory -AllowedValues @($Foundation.allowed_fault_categories) -Context "Fault event.event_category"
        }
    }

    Assert-AllowedValue -Value $TriggerClassification -AllowedValues @($Foundation.allowed_trigger_classifications) -Context "Fault event.trigger_classification"
    Assert-AllowedValue -Value $RequiredNextAction -AllowedValues @($Foundation.allowed_required_next_actions) -Context "Fault event.required_next_action"
    Assert-AllowedValue -Value $AutomaticRecoveryClaim -AllowedValues @($Foundation.allowed_automatic_recovery_claims) -Context "Fault event.automatic_recovery_claim"
}

function Test-FaultManagementEventDocument {
    param(
        [Parameter(Mandatory = $true)]
        $FaultEvent,
        [Parameter(Mandatory = $true)]
        [string]$SourceLabel,
        [AllowNull()]
        [string]$EventPath
    )

    $foundation = Get-FaultManagementFoundationContract
    $eventContract = Get-FaultManagementEventContract

    foreach ($fieldName in @($eventContract.required_fields)) {
        Get-RequiredProperty -Object $FaultEvent -Name $fieldName -Context "Fault event" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $FaultEvent -Name "contract_version" -Context "Fault event") -Context "Fault event.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "Fault event.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $FaultEvent -Name "record_type" -Context "Fault event") -Context "Fault event.record_type"
    if ($recordType -ne $foundation.fault_event_record_type -or $recordType -ne $eventContract.record_type) {
        throw "Fault event.record_type must equal '$($foundation.fault_event_record_type)'."
    }

    $eventId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $FaultEvent -Name "event_id" -Context "Fault event") -Context "Fault event.event_id"
    Assert-RegexMatch -Value $eventId -Pattern $foundation.identifier_pattern -Context "Fault event.event_id"

    $eventType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $FaultEvent -Name "event_type" -Context "Fault event") -Context "Fault event.event_type"
    $eventCategory = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $FaultEvent -Name "event_category" -Context "Fault event") -Context "Fault event.event_category"
    $reasonSummary = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $FaultEvent -Name "reason_summary" -Context "Fault event") -Context "Fault event.reason_summary"
    $triggerClassification = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $FaultEvent -Name "trigger_classification" -Context "Fault event") -Context "Fault event.trigger_classification"
    $requiredNextAction = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $FaultEvent -Name "required_next_action" -Context "Fault event") -Context "Fault event.required_next_action"
    $automaticRecoveryClaim = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $FaultEvent -Name "automatic_recovery_claim" -Context "Fault event") -Context "Fault event.automatic_recovery_claim"
    Validate-EventClassification -EventType $eventType -EventCategory $eventCategory -TriggerClassification $triggerClassification -RequiredNextAction $requiredNextAction -AutomaticRecoveryClaim $automaticRecoveryClaim -Foundation $foundation

    $occurredAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $FaultEvent -Name "occurred_at" -Context "Fault event") -Context "Fault event.occurred_at"
    Assert-RegexMatch -Value $occurredAt -Pattern $foundation.timestamp_pattern -Context "Fault event.occurred_at"

    $cycleContext = Validate-CycleContext -CycleContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $FaultEvent -Name "cycle_context" -Context "Fault event") -Context "Fault event.cycle_context") -Foundation $foundation -EventContract $eventContract
    $affectedScope = Validate-AffectedScope -AffectedScope (Assert-ObjectValue -Value (Get-RequiredProperty -Object $FaultEvent -Name "affected_scope" -Context "Fault event") -Context "Fault event.affected_scope") -Foundation $foundation -EventContract $eventContract
    $repositoryName = Validate-RepositoryContext -RepositoryContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $FaultEvent -Name "repository" -Context "Fault event") -Context "Fault event.repository") -Foundation $foundation -EventContract $eventContract
    $gitContext = Validate-GitContext -GitContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $FaultEvent -Name "git_context" -Context "Fault event") -Context "Fault event.git_context") -Foundation $foundation -EventContract $eventContract
    $supervision = Validate-Supervision -Supervision (Assert-ObjectValue -Value (Get-RequiredProperty -Object $FaultEvent -Name "supervision" -Context "Fault event") -Context "Fault event.supervision") -Foundation $foundation -EventContract $eventContract

    $notes = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $FaultEvent -Name "notes" -Context "Fault event") -Context "Fault event.notes"

    return [pscustomobject]@{
        IsValid                = $true
        EventId                = $eventId
        EventType              = $eventType
        EventCategory          = $eventCategory
        ReasonSummary          = $reasonSummary
        TriggerClassification  = $triggerClassification
        CycleId                = $cycleContext.CycleId
        MilestoneId            = $cycleContext.MilestoneId
        ScopeLevel             = $affectedScope.ScopeLevel
        TaskId                 = $affectedScope.TaskId
        SegmentId              = $affectedScope.SegmentId
        RepositoryName         = $repositoryName
        Branch                 = $gitContext.Branch
        HeadCommit             = $gitContext.HeadCommit
        TreeId                 = $gitContext.TreeId
        RequiredNextAction     = $requiredNextAction
        AutomaticRecoveryClaim = $automaticRecoveryClaim
        OperatorAuthority      = $supervision.OperatorAuthority
        SourceLabel            = $SourceLabel
        EventPath              = $EventPath
        Notes                  = $notes
    }
}

function Test-FaultManagementEventContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$EventPath
    )

    $resolvedEventPath = Resolve-EventPath -EventPath $EventPath
    $faultEvent = Get-JsonDocument -Path $resolvedEventPath -Label "Fault event"
    return (Test-FaultManagementEventDocument -FaultEvent $faultEvent -SourceLabel $resolvedEventPath -EventPath $resolvedEventPath)
}

function Test-FaultManagementEventObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $FaultEvent,
        [string]$SourceLabel = "in-memory fault event"
    )

    return (Test-FaultManagementEventDocument -FaultEvent $FaultEvent -SourceLabel $SourceLabel -EventPath $null)
}

function Get-FaultManagementEvent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$EventPath
    )

    $validation = Test-FaultManagementEventContract -EventPath $EventPath
    return (Get-JsonDocument -Path $validation.EventPath -Label "Fault event")
}

Export-ModuleMember -Function Test-FaultManagementEventContract, Test-FaultManagementEventObject, Get-FaultManagementEvent
