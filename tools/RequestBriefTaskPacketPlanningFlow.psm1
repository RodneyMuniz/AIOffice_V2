Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$governedWorkObjectValidationModule = Import-Module (Join-Path $PSScriptRoot "GovernedWorkObjectValidation.psm1") -Force -PassThru
$planningRecordStorageModule = Import-Module (Join-Path $PSScriptRoot "PlanningRecordStorage.psm1") -Force -PassThru
$workArtifactValidationModule = Import-Module (Join-Path $PSScriptRoot "WorkArtifactValidation.psm1") -Force -PassThru
$testGovernedWorkObjectContract = $governedWorkObjectValidationModule.ExportedCommands["Test-GovernedWorkObjectContract"]
$testPlanningRecordContract = $planningRecordStorageModule.ExportedCommands["Test-PlanningRecordContract"]
$testWorkArtifactContract = $workArtifactValidationModule.ExportedCommands["Test-WorkArtifactContract"]

function Get-RepositoryRoot {
    return $repoRoot
}

function Resolve-PathValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return $PathValue
    }

    return Join-Path (Get-Location) $PathValue
}

function Resolve-ExistingPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $resolvedPath = Resolve-PathValue -PathValue $PathValue
    if (-not (Test-Path -LiteralPath $resolvedPath)) {
        throw "$Label '$PathValue' does not exist."
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

function Get-UtcTimestamp {
    param(
        [datetime]$DateTime = (Get-Date).ToUniversalTime()
    )

    return $DateTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
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

function Get-ComparisonPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue
    )

    $fullPath = [System.IO.Path]::GetFullPath($PathValue)
    if (Test-Path -LiteralPath $fullPath) {
        $fullPath = (Resolve-Path -LiteralPath $fullPath).Path
    }

    return ($fullPath.Replace("/", "\").TrimEnd("\")).ToLowerInvariant()
}

function New-UniqueStringList {
    Write-Output -NoEnumerate ([System.Collections.Generic.List[string]]::new())
}

function Add-UniqueString {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.Generic.List[string]]$List,
        [AllowNull()]
        [string]$Value
    )

    if (-not [string]::IsNullOrWhiteSpace($Value) -and -not $List.Contains($Value)) {
        $List.Add($Value) | Out-Null
    }
}

function Get-ArtifactContract {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArtifactType
    )

    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) ("contracts\work_artifacts\{0}.contract.json" -f $ArtifactType)) -Label "Work artifact contract"
}

function Get-WorkObjectContract {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ObjectType
    )

    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) ("contracts\governed_work_objects\{0}.contract.json" -f $ObjectType)) -Label "Governed work object contract"
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

function Get-PlanningRecordViewPath {
    param(
        [Parameter(Mandatory = $true)]
        $PlanningRecordDocument,
        [Parameter(Mandatory = $true)]
        [string]$PlanningRecordPath,
        [Parameter(Mandatory = $true)]
        [string]$View
    )

    $planningRecordDirectory = Split-Path -Parent $PlanningRecordPath
    switch ($View) {
        "accepted" {
            $recordRef = Assert-NonEmptyString -Value $PlanningRecordDocument.accepted_state.record_ref -Context "PlanningRecord.accepted_state.record_ref"
            return (Resolve-ReferenceAgainstBase -BaseDirectory $planningRecordDirectory -Reference $recordRef -Label "Accepted planning record")
        }
        "working" {
            $recordRef = Assert-NonEmptyString -Value $PlanningRecordDocument.working_state.record_ref -Context "PlanningRecord.working_state.record_ref"
            return (Resolve-ReferenceAgainstBase -BaseDirectory $planningRecordDirectory -Reference $recordRef -Label "Working planning record")
        }
        default {
            throw "Unsupported planning record view '$View'."
        }
    }
}

function Get-ValidatedRequestBriefInput {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RequestBriefPath
    )

    $artifactCheck = & $testWorkArtifactContract -ArtifactPath $RequestBriefPath
    if ($artifactCheck.ArtifactType -ne "request_brief") {
        throw "Planning flow requires a Request Brief artifact, but '$RequestBriefPath' resolved to artifact type '$($artifactCheck.ArtifactType)'."
    }

    $requestBrief = Get-JsonDocument -Path $artifactCheck.ArtifactPath -Label "Request Brief"
    if ($requestBrief.status -ne "ready_for_planning") {
        throw "Request Brief '$($requestBrief.artifact_id)' must be in status 'ready_for_planning' before Task Packet generation."
    }

    return [pscustomobject]@{
        Validation = $artifactCheck
        Document   = $requestBrief
        Directory  = (Split-Path -Parent $artifactCheck.ArtifactPath)
    }
}

function Get-ValidatedTaskPacketTargets {
    param(
        [Parameter(Mandatory = $true)]
        $RequestBriefInput,
        [Parameter(Mandatory = $true)]
        $TaskPacketContract
    )

    $targets = [System.Collections.ArrayList]::new()

    foreach ($workObjectRef in @(Assert-ObjectArray -Value (Get-RequiredProperty -Object $RequestBriefInput.Document -Name "work_object_refs" -Context "Request Brief") -Context "Request Brief.work_object_refs")) {
        $resolvedWorkObjectPath = Resolve-ReferenceAgainstBase -BaseDirectory $RequestBriefInput.Directory -Reference $workObjectRef.ref -Label "Request Brief work object"
        $workObjectValidation = & $testGovernedWorkObjectContract -WorkObjectPath $resolvedWorkObjectPath
        $workObjectDocument = Get-JsonDocument -Path $workObjectValidation.WorkObjectPath -Label "Target governed work object"
        $objectContract = Get-WorkObjectContract -ObjectType $workObjectValidation.ObjectType

        if (@($TaskPacketContract.allowed_work_object_types) -notcontains $workObjectValidation.ObjectType) {
            throw "Request Brief work object '$($workObjectValidation.ObjectId)' uses object type '$($workObjectValidation.ObjectType)', which is not allowed for Task Packets."
        }

        if (@($objectContract.lifecycle.terminal_statuses) -contains $workObjectValidation.Status) {
            throw "Request Brief work object '$($workObjectValidation.ObjectId)' is already in terminal status '$($workObjectValidation.Status)'."
        }

        [void]$targets.Add([pscustomobject]@{
            ObjectType      = $workObjectValidation.ObjectType
            ObjectId        = $workObjectValidation.ObjectId
            ResolvedPath    = $resolvedWorkObjectPath
            ComparisonPath  = Get-ComparisonPath -PathValue $resolvedWorkObjectPath
            Document        = $workObjectDocument
            SourceRef       = $workObjectRef
        })
    }

    if ($targets.Count -eq 0) {
        throw "Request Brief must reference at least one governed work object target before Task Packet generation."
    }

    return $targets
}

function Get-ValidatedTaskPacketPlanningRefs {
    param(
        [Parameter(Mandatory = $true)]
        $RequestBriefInput,
        [Parameter(Mandatory = $true)]
        $TargetRefs
    )

    $planningRefs = [System.Collections.ArrayList]::new()
    $targetMap = @{}

    foreach ($target in @($TargetRefs)) {
        $targetKey = "{0}|{1}" -f $target.ObjectType, $target.ObjectId
        if (-not $targetMap.ContainsKey($targetKey)) {
            $targetMap[$targetKey] = @()
        }

        $targetMap[$targetKey] += $target
    }

    if (-not (Test-HasProperty -Object $RequestBriefInput.Document -Name "planning_record_refs")) {
        throw "Request Brief '$($RequestBriefInput.Document.artifact_id)' is missing planning_record_refs."
    }

    $rawPlanningRefs = $RequestBriefInput.Document.planning_record_refs
    if ($null -eq $rawPlanningRefs -or @($rawPlanningRefs).Count -eq 0) {
        throw "Request Brief '$($RequestBriefInput.Document.artifact_id)' must include at least one accepted planning_record_ref before Task Packet generation."
    }

    $requestPlanningRefs = @(Assert-ObjectArray -Value $rawPlanningRefs -Context "Request Brief.planning_record_refs" -AllowEmpty)

    foreach ($planningRecordRef in $requestPlanningRefs) {
        if ($planningRecordRef.view -ne "accepted") {
            throw "Request Brief planning_record_ref '$($planningRecordRef.planning_record_id)' must use view 'accepted' for approved Task Packet generation."
        }

        $resolvedPlanningRecordPath = Resolve-ReferenceAgainstBase -BaseDirectory $RequestBriefInput.Directory -Reference $planningRecordRef.ref -Label "Request Brief planning record"
        $planningRecordValidation = & $testPlanningRecordContract -PlanningRecordPath $resolvedPlanningRecordPath
        $planningRecordDocument = Get-JsonDocument -Path $planningRecordValidation.PlanningRecordPath -Label "Planning record"

        if ($planningRecordDocument.accepted_state.status -ne "accepted") {
            throw "Planning record '$($planningRecordValidation.PlanningRecordId)' does not currently expose an accepted state."
        }

        $planningKey = "{0}|{1}" -f $planningRecordValidation.ObjectType, $planningRecordValidation.ObjectId
        if (-not $targetMap.ContainsKey($planningKey)) {
            throw "Planning record '$($planningRecordValidation.PlanningRecordId)' is not aligned to any targeted governed work object in the Request Brief."
        }

        $acceptedViewPath = Get-PlanningRecordViewPath -PlanningRecordDocument $planningRecordDocument -PlanningRecordPath $planningRecordValidation.PlanningRecordPath -View "accepted"
        $matchingTarget = @($targetMap[$planningKey] | Where-Object { $_.ComparisonPath -eq (Get-ComparisonPath -PathValue $acceptedViewPath) })
        if ($matchingTarget.Count -eq 0) {
            throw "Planning record '$($planningRecordValidation.PlanningRecordId)' must align to the accepted governed work object ref in the Request Brief."
        }

        [void]$planningRefs.Add([pscustomobject]@{
            PlanningRecordId     = $planningRecordValidation.PlanningRecordId
            ObjectType           = $planningRecordValidation.ObjectType
            ObjectId             = $planningRecordValidation.ObjectId
            ResolvedPath         = $planningRecordValidation.PlanningRecordPath
            ComparisonPath       = Get-ComparisonPath -PathValue $planningRecordValidation.PlanningRecordPath
            AcceptedViewPath     = $acceptedViewPath
            AcceptedViewCompare  = Get-ComparisonPath -PathValue $acceptedViewPath
            Document             = $planningRecordDocument
            MatchingTarget       = $matchingTarget[0]
            SourceRef            = $planningRecordRef
        })
    }

    foreach ($target in @($TargetRefs)) {
        $targetMatched = @($planningRefs | Where-Object { $_.MatchingTarget.ComparisonPath -eq $target.ComparisonPath })
        if ($targetMatched.Count -eq 0) {
            throw "Request Brief work object '$($target.ObjectId)' is not grounded in an accepted planning record."
        }
    }

    return $planningRefs
}

function New-TaskPacketFromRequestBrief {
    param(
        [Parameter(Mandatory = $true)]
        $RequestBriefInput,
        [Parameter(Mandatory = $true)]
        $TargetRefs,
        [Parameter(Mandatory = $true)]
        $PlanningRefs,
        [Parameter(Mandatory = $true)]
        [string]$TaskPacketId,
        [Parameter(Mandatory = $true)]
        [datetime]$CreatedAt,
        [Parameter(Mandatory = $true)]
        [string]$CreatedById,
        [Parameter(Mandatory = $true)]
        [string]$TaskPacketDirectory
    )

    $createdAtText = Get-UtcTimestamp -DateTime $CreatedAt
    $requestedActions = New-UniqueStringList
    Add-UniqueString -List $requestedActions -Value $RequestBriefInput.Document.requested_outcome
    Add-UniqueString -List $requestedActions -Value $RequestBriefInput.Document.request_intent

    $acceptanceChecks = New-UniqueStringList
    Add-UniqueString -List $acceptanceChecks -Value "Task Packet preserves lineage back to the Request Brief."
    Add-UniqueString -List $acceptanceChecks -Value "Task Packet remains grounded in accepted planning records only."
    foreach ($planningRef in @($PlanningRefs)) {
        if (Test-HasProperty -Object $planningRef.MatchingTarget.Document -Name "acceptance_checks") {
            foreach ($acceptanceCheck in @($planningRef.MatchingTarget.Document.acceptance_checks)) {
                Add-UniqueString -List $acceptanceChecks -Value $acceptanceCheck
            }
        }
    }

    $handoffNotes = New-UniqueStringList
    foreach ($operatorQuestion in @($RequestBriefInput.Document.operator_questions)) {
        Add-UniqueString -List $handoffNotes -Value $operatorQuestion
    }
    if (Test-HasProperty -Object $RequestBriefInput.Document -Name "escalation_notes") {
        Add-UniqueString -List $handoffNotes -Value $RequestBriefInput.Document.escalation_notes
    }

    $requestBriefRelativeRef = Get-RelativeReference -BaseDirectory $TaskPacketDirectory -TargetPath $RequestBriefInput.Validation.ArtifactPath

    $taskPacketWorkObjectRefs = foreach ($targetRef in @($TargetRefs)) {
        [pscustomobject]@{
            relation    = "implements"
            object_type = $targetRef.ObjectType
            object_id   = $targetRef.ObjectId
            ref         = (Get-RelativeReference -BaseDirectory $TaskPacketDirectory -TargetPath $targetRef.ResolvedPath)
            notes       = "Implements the targeted governed work object grounded by the accepted planning baseline."
        }
    }

    $taskPacketPlanningRefs = foreach ($planningRef in @($PlanningRefs)) {
        [pscustomobject]@{
            relation           = "derives_from"
            planning_record_id = $planningRef.PlanningRecordId
            object_type        = $planningRef.ObjectType
            object_id          = $planningRef.ObjectId
            view               = "accepted"
            ref                = (Get-RelativeReference -BaseDirectory $TaskPacketDirectory -TargetPath $planningRef.ResolvedPath)
            notes              = "Derived from the accepted planning record referenced by the Request Brief."
        }
    }

    $evidence = [System.Collections.ArrayList]::new()
    foreach ($planningRef in @($PlanningRefs)) {
        [void]$evidence.Add([pscustomobject]@{
            kind    = "planning_record"
            ref     = (Get-RelativeReference -BaseDirectory $TaskPacketDirectory -TargetPath $planningRef.ResolvedPath)
            summary = "The accepted planning record provides the approved baseline for this Task Packet."
        })
    }
    [void]$evidence.Add([pscustomobject]@{
        kind    = "artifact"
        ref     = $requestBriefRelativeRef
        summary = "The source Request Brief defines the bounded planning intent for this Task Packet."
    })

    $taskPacket = [pscustomobject]@{
        contract_version  = "v1"
        record_type       = "governed_work_artifact"
        artifact_type     = "task_packet"
        artifact_id       = $TaskPacketId
        title             = "Task Packet for $($RequestBriefInput.Document.title)"
        summary           = "Approved bounded Task Packet generated from Request Brief '$($RequestBriefInput.Document.artifact_id)'."
        status            = "approved"
        created_at        = $createdAtText
        created_by        = [pscustomobject]@{
            role = "control_kernel"
            id   = $CreatedById
        }
        lineage           = [pscustomobject]@{
            source_kind = "request_brief"
            source_refs = @($requestBriefRelativeRef)
            rationale   = "Task Packet generated from a planning-ready Request Brief grounded in accepted planning records."
        }
        work_object_refs  = @($taskPacketWorkObjectRefs)
        planning_record_refs = @($taskPacketPlanningRefs)
        evidence          = @($evidence)
        audit             = [pscustomobject]@{
            trail_refs       = @("tests/test_request_brief_task_packet_flow.ps1")
            last_reviewed_at = $createdAtText
            notes            = "Bounded Request Brief to Task Packet flow output reviewed against the focused flow test."
        }
        packet_summary    = "Convert the planning-ready Request Brief into one bounded approved Task Packet."
        requested_actions = @($requestedActions)
        acceptance_checks = @($acceptanceChecks)
        bounded_scope     = @($RequestBriefInput.Document.scope_constraints)
        non_goals         = @($RequestBriefInput.Document.non_goals)
        execution_profile = if ([string]::IsNullOrWhiteSpace($RequestBriefInput.Document.requested_execution_profile)) { "bounded-supervised-planning" } else { $RequestBriefInput.Document.requested_execution_profile }
        handoff_notes     = @($handoffNotes)
    }

    return $taskPacket
}

function Invoke-RequestBriefToTaskPacketFlow {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RequestBriefPath,
        [Parameter(Mandatory = $true)]
        [string]$OutputRoot,
        [string]$TaskPacketId,
        [datetime]$CreatedAt = (Get-Date).ToUniversalTime(),
        [string]$CreatedById = "control-kernel:planner"
    )

    $requestBriefInput = Get-ValidatedRequestBriefInput -RequestBriefPath $RequestBriefPath
    $taskPacketContract = Get-ArtifactContract -ArtifactType "task_packet"
    $targetRefs = Get-ValidatedTaskPacketTargets -RequestBriefInput $requestBriefInput -TaskPacketContract $taskPacketContract
    $planningRefs = Get-ValidatedTaskPacketPlanningRefs -RequestBriefInput $requestBriefInput -TargetRefs $targetRefs

    if ([string]::IsNullOrWhiteSpace($TaskPacketId)) {
        $TaskPacketId = "task-packet-{0}" -f $requestBriefInput.Document.artifact_id
    }

    $resolvedOutputRoot = Resolve-PathValue -PathValue $OutputRoot
    if (-not (Test-Path -LiteralPath $resolvedOutputRoot)) {
        New-Item -ItemType Directory -Path $resolvedOutputRoot -Force | Out-Null
    }

    $taskPacketDirectory = Join-Path $resolvedOutputRoot "task_packets"
    if (-not (Test-Path -LiteralPath $taskPacketDirectory)) {
        New-Item -ItemType Directory -Path $taskPacketDirectory -Force | Out-Null
    }

    $taskPacketPath = Join-Path $taskPacketDirectory ("{0}.json" -f $TaskPacketId)
    $taskPacket = New-TaskPacketFromRequestBrief -RequestBriefInput $requestBriefInput -TargetRefs $targetRefs -PlanningRefs $planningRefs -TaskPacketId $TaskPacketId -CreatedAt $CreatedAt -CreatedById $CreatedById -TaskPacketDirectory $taskPacketDirectory

    Write-JsonDocument -Path $taskPacketPath -Document $taskPacket
    $taskPacketValidation = & $testWorkArtifactContract -ArtifactPath $taskPacketPath

    return [pscustomobject]@{
        RequestBriefValidation = $requestBriefInput.Validation
        TaskPacketValidation   = $taskPacketValidation
        RequestBriefPath       = $requestBriefInput.Validation.ArtifactPath
        TaskPacketPath         = $taskPacketValidation.ArtifactPath
        TaskPacket             = $taskPacket
    }
}

Export-ModuleMember -Function Invoke-RequestBriefToTaskPacketFlow
