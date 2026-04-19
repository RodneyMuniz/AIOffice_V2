Set-StrictMode -Version Latest

$governedValidationModulePath = Join-Path $PSScriptRoot "GovernedWorkObjectValidation.psm1"
Import-Module $governedValidationModulePath -Force

function Get-RepositoryRoot {
    return (Split-Path -Parent $PSScriptRoot)
}

function Resolve-PlanningRecordPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PlanningRecordPath
    )

    if ([System.IO.Path]::IsPathRooted($PlanningRecordPath)) {
        $resolvedPath = $PlanningRecordPath
    }
    else {
        $resolvedPath = Join-Path (Get-Location) $PlanningRecordPath
    }

    if (-not (Test-Path -LiteralPath $resolvedPath)) {
        throw "Planning record path '$PlanningRecordPath' does not exist."
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
    Set-Content -LiteralPath $Path -Value $json
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

function Assert-NullableString {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($null -eq $Value) {
        return $null
    }

    return (Assert-NonEmptyString -Value $Value -Context $Context)
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

function Assert-NullableBoolean {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($null -eq $Value) {
        return $null
    }

    if ($Value -isnot [bool]) {
        throw "$Context must be a boolean or null."
    }

    return $Value
}

function Get-UtcTimestamp {
    param(
        [Parameter(Mandatory = $true)]
        [datetime]$DateTime
    )

    return $DateTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
}

function Convert-BlankStringToNull {
    param(
        [AllowNull()]
        [string]$Value
    )

    if ($null -eq $Value -or [string]::IsNullOrWhiteSpace($Value)) {
        return $null
    }

    return $Value
}

function Get-PlanningRecordFoundationContract {
    $path = Join-Path (Get-RepositoryRoot) "contracts\planning_records\foundation.contract.json"
    return (Get-JsonDocument -Path $path -Label "Planning record foundation contract")
}

function Get-PlanningRecordContract {
    $path = Join-Path (Get-RepositoryRoot) "contracts\planning_records\planning_record.contract.json"
    return (Get-JsonDocument -Path $path -Label "Planning record contract")
}

function Resolve-RecordRefPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory,
        [AllowNull()]
        [string]$Ref
    )

    if ([string]::IsNullOrWhiteSpace($Ref)) {
        return $null
    }

    if ([System.IO.Path]::IsPathRooted($Ref)) {
        $candidate = $Ref
    }
    else {
        $relativeRef = $Ref -replace "[/\\]", [System.IO.Path]::DirectorySeparatorChar
        $candidate = Join-Path $BaseDirectory $relativeRef
    }

    if (-not (Test-Path -LiteralPath $candidate)) {
        throw "Record ref '$Ref' does not exist."
    }

    return (Resolve-Path -LiteralPath $candidate).Path
}

function Get-ValidatedWorkObjectFromPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorkObjectPath,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $validation = Test-GovernedWorkObjectContract -WorkObjectPath $WorkObjectPath
    $document = Get-JsonDocument -Path $validation.WorkObjectPath -Label $Context

    return [pscustomobject]@{
        Validation = $validation
        Document   = $document
    }
}

function Validate-TopLevelFields {
    param(
        [Parameter(Mandatory = $true)]
        $PlanningRecord,
        [Parameter(Mandatory = $true)]
        $Foundation
    )

    foreach ($fieldName in $Foundation.required_fields) {
        Get-RequiredProperty -Object $PlanningRecord -Name $fieldName -Context "PlanningRecord" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $PlanningRecord -Name "contract_version" -Context "PlanningRecord") -Context "PlanningRecord.contract_version"
    if ($contractVersion -ne $Foundation.contract_version) {
        throw "PlanningRecord.contract_version must equal '$($Foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $PlanningRecord -Name "record_type" -Context "PlanningRecord") -Context "PlanningRecord.record_type"
    if ($recordType -ne $Foundation.record_type) {
        throw "PlanningRecord.record_type must equal '$($Foundation.record_type)'."
    }

    $planningRecordId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $PlanningRecord -Name "planning_record_id" -Context "PlanningRecord") -Context "PlanningRecord.planning_record_id"
    Assert-RegexMatch -Value $planningRecordId -Pattern $Foundation.identifier_pattern -Context "PlanningRecord.planning_record_id"

    $objectType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $PlanningRecord -Name "object_type" -Context "PlanningRecord") -Context "PlanningRecord.object_type"
    Assert-AllowedValue -Value $objectType -AllowedValues @($Foundation.allowed_object_types) -Context "PlanningRecord.object_type"

    $objectId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $PlanningRecord -Name "object_id" -Context "PlanningRecord") -Context "PlanningRecord.object_id"
    Assert-RegexMatch -Value $objectId -Pattern $Foundation.identifier_pattern -Context "PlanningRecord.object_id"

    $createdAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $PlanningRecord -Name "created_at" -Context "PlanningRecord") -Context "PlanningRecord.created_at"
    Assert-RegexMatch -Value $createdAt -Pattern $Foundation.timestamp_pattern -Context "PlanningRecord.created_at"

    $updatedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $PlanningRecord -Name "updated_at" -Context "PlanningRecord") -Context "PlanningRecord.updated_at"
    Assert-RegexMatch -Value $updatedAt -Pattern $Foundation.timestamp_pattern -Context "PlanningRecord.updated_at"
}

function Validate-WorkingState {
    param(
        [Parameter(Mandatory = $true)]
        $PlanningRecord,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory
    )

    $workingState = Assert-ObjectValue -Value (Get-RequiredProperty -Object $PlanningRecord -Name "working_state" -Context "PlanningRecord") -Context "PlanningRecord.working_state"
    foreach ($fieldName in $Foundation.working_state_required_fields) {
        Get-RequiredProperty -Object $workingState -Name $fieldName -Context "PlanningRecord.working_state" | Out-Null
    }

    $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $workingState -Name "status" -Context "PlanningRecord.working_state") -Context "PlanningRecord.working_state.status"
    Assert-AllowedValue -Value $status -AllowedValues @($Foundation.allowed_working_state_statuses) -Context "PlanningRecord.working_state.status"

    $recordRef = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $workingState -Name "record_ref" -Context "PlanningRecord.working_state") -Context "PlanningRecord.working_state.record_ref"
    $recordPath = Resolve-RecordRefPath -BaseDirectory $BaseDirectory -Ref $recordRef
    $validatedWorkObject = Get-ValidatedWorkObjectFromPath -WorkObjectPath $recordPath -Context "Working surface work object"

    $workingObjectType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $workingState -Name "object_type" -Context "PlanningRecord.working_state") -Context "PlanningRecord.working_state.object_type"
    $workingObjectId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $workingState -Name "object_id" -Context "PlanningRecord.working_state") -Context "PlanningRecord.working_state.object_id"
    $workingObjectStatus = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $workingState -Name "object_status" -Context "PlanningRecord.working_state") -Context "PlanningRecord.working_state.object_status"
    $lastLocalUpdateAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $workingState -Name "last_local_update_at" -Context "PlanningRecord.working_state") -Context "PlanningRecord.working_state.last_local_update_at"
    Assert-RegexMatch -Value $lastLocalUpdateAt -Pattern $Foundation.timestamp_pattern -Context "PlanningRecord.working_state.last_local_update_at"
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $workingState -Name "notes" -Context "PlanningRecord.working_state") -Context "PlanningRecord.working_state.notes" | Out-Null

    if ($workingObjectType -ne $PlanningRecord.object_type) {
        throw "PlanningRecord.working_state.object_type must match PlanningRecord.object_type."
    }
    if ($workingObjectId -ne $PlanningRecord.object_id) {
        throw "PlanningRecord.working_state.object_id must match PlanningRecord.object_id."
    }
    if ($workingObjectType -ne $validatedWorkObject.Document.object_type) {
        throw "PlanningRecord.working_state.object_type must match the referenced work object."
    }
    if ($workingObjectId -ne $validatedWorkObject.Document.object_id) {
        throw "PlanningRecord.working_state.object_id must match the referenced work object."
    }
    if ($workingObjectStatus -ne $validatedWorkObject.Document.status) {
        throw "PlanningRecord.working_state.object_status must match the referenced work object status."
    }

    return [pscustomobject]@{
        RecordPath = $recordPath
        Document   = $validatedWorkObject.Document
        State      = $workingState
    }
}

function Validate-AcceptedState {
    param(
        [Parameter(Mandatory = $true)]
        $PlanningRecord,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory,
        [Parameter(Mandatory = $true)]
        $WorkingStateResult
    )

    $acceptedState = Assert-ObjectValue -Value (Get-RequiredProperty -Object $PlanningRecord -Name "accepted_state" -Context "PlanningRecord") -Context "PlanningRecord.accepted_state"
    foreach ($fieldName in $Foundation.accepted_state_required_fields) {
        Get-RequiredProperty -Object $acceptedState -Name $fieldName -Context "PlanningRecord.accepted_state" | Out-Null
    }

    $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $acceptedState -Name "status" -Context "PlanningRecord.accepted_state") -Context "PlanningRecord.accepted_state.status"
    Assert-AllowedValue -Value $status -AllowedValues @($Foundation.allowed_accepted_state_statuses) -Context "PlanningRecord.accepted_state.status"

    $recordRef = Convert-BlankStringToNull -Value (Get-RequiredProperty -Object $acceptedState -Name "record_ref" -Context "PlanningRecord.accepted_state")
    $acceptedObjectType = Convert-BlankStringToNull -Value (Get-RequiredProperty -Object $acceptedState -Name "object_type" -Context "PlanningRecord.accepted_state")
    $acceptedObjectId = Convert-BlankStringToNull -Value (Get-RequiredProperty -Object $acceptedState -Name "object_id" -Context "PlanningRecord.accepted_state")
    $acceptedObjectStatus = Convert-BlankStringToNull -Value (Get-RequiredProperty -Object $acceptedState -Name "object_status" -Context "PlanningRecord.accepted_state")
    $acceptedAt = Convert-BlankStringToNull -Value (Get-RequiredProperty -Object $acceptedState -Name "accepted_at" -Context "PlanningRecord.accepted_state")
    $acceptedBy = Convert-BlankStringToNull -Value (Get-RequiredProperty -Object $acceptedState -Name "accepted_by" -Context "PlanningRecord.accepted_state")
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $acceptedState -Name "notes" -Context "PlanningRecord.accepted_state") -Context "PlanningRecord.accepted_state.notes" | Out-Null

    if ($status -eq "none") {
        if ($null -ne $recordRef -or $null -ne $acceptedObjectType -or $null -ne $acceptedObjectId -or $null -ne $acceptedObjectStatus -or $null -ne $acceptedAt -or $null -ne $acceptedBy) {
            throw "PlanningRecord.accepted_state status 'none' requires null record and acceptance metadata."
        }

        return [pscustomobject]@{
            RecordPath = $null
            Document   = $null
            State      = $acceptedState
        }
    }

    Assert-NonEmptyString -Value $recordRef -Context "PlanningRecord.accepted_state.record_ref" | Out-Null
    Assert-NonEmptyString -Value $acceptedObjectType -Context "PlanningRecord.accepted_state.object_type" | Out-Null
    Assert-NonEmptyString -Value $acceptedObjectId -Context "PlanningRecord.accepted_state.object_id" | Out-Null
    Assert-NonEmptyString -Value $acceptedObjectStatus -Context "PlanningRecord.accepted_state.object_status" | Out-Null
    Assert-NonEmptyString -Value $acceptedAt -Context "PlanningRecord.accepted_state.accepted_at" | Out-Null
    Assert-RegexMatch -Value $acceptedAt -Pattern $Foundation.timestamp_pattern -Context "PlanningRecord.accepted_state.accepted_at"
    Assert-NonEmptyString -Value $acceptedBy -Context "PlanningRecord.accepted_state.accepted_by" | Out-Null

    $recordPath = Resolve-RecordRefPath -BaseDirectory $BaseDirectory -Ref $recordRef
    if ($recordPath -eq $WorkingStateResult.RecordPath) {
        throw "PlanningRecord.accepted_state.record_ref must differ from PlanningRecord.working_state.record_ref."
    }

    $validatedWorkObject = Get-ValidatedWorkObjectFromPath -WorkObjectPath $recordPath -Context "Accepted surface work object"

    if ($acceptedObjectType -ne $PlanningRecord.object_type) {
        throw "PlanningRecord.accepted_state.object_type must match PlanningRecord.object_type."
    }
    if ($acceptedObjectId -ne $PlanningRecord.object_id) {
        throw "PlanningRecord.accepted_state.object_id must match PlanningRecord.object_id."
    }
    if ($acceptedObjectType -ne $validatedWorkObject.Document.object_type) {
        throw "PlanningRecord.accepted_state.object_type must match the referenced work object."
    }
    if ($acceptedObjectId -ne $validatedWorkObject.Document.object_id) {
        throw "PlanningRecord.accepted_state.object_id must match the referenced work object."
    }
    if ($acceptedObjectStatus -ne $validatedWorkObject.Document.status) {
        throw "PlanningRecord.accepted_state.object_status must match the referenced work object status."
    }

    return [pscustomobject]@{
        RecordPath = $recordPath
        Document   = $validatedWorkObject.Document
        State      = $acceptedState
    }
}

function Validate-ReconciliationState {
    param(
        [Parameter(Mandatory = $true)]
        $PlanningRecord,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $AcceptedStateResult
    )

    $reconciliationState = Assert-ObjectValue -Value (Get-RequiredProperty -Object $PlanningRecord -Name "reconciliation_state" -Context "PlanningRecord") -Context "PlanningRecord.reconciliation_state"
    foreach ($fieldName in $Foundation.reconciliation_state_required_fields) {
        Get-RequiredProperty -Object $reconciliationState -Name $fieldName -Context "PlanningRecord.reconciliation_state" | Out-Null
    }

    $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $reconciliationState -Name "status" -Context "PlanningRecord.reconciliation_state") -Context "PlanningRecord.reconciliation_state.status"
    Assert-AllowedValue -Value $status -AllowedValues @($Foundation.allowed_reconciliation_statuses) -Context "PlanningRecord.reconciliation_state.status"

    $comparedAt = Convert-BlankStringToNull -Value (Get-RequiredProperty -Object $reconciliationState -Name "compared_at" -Context "PlanningRecord.reconciliation_state")
    $workingMatchesAccepted = Assert-NullableBoolean -Value (Get-RequiredProperty -Object $reconciliationState -Name "working_matches_accepted" -Context "PlanningRecord.reconciliation_state") -Context "PlanningRecord.reconciliation_state.working_matches_accepted"
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $reconciliationState -Name "notes" -Context "PlanningRecord.reconciliation_state") -Context "PlanningRecord.reconciliation_state.notes" | Out-Null

    switch ($status) {
        "not_started" {
            if ($null -ne $comparedAt -or $null -ne $workingMatchesAccepted) {
                throw "PlanningRecord.reconciliation_state status 'not_started' requires null comparison fields."
            }
        }
        "pending" {
            Assert-NonEmptyString -Value $comparedAt -Context "PlanningRecord.reconciliation_state.compared_at" | Out-Null
            Assert-RegexMatch -Value $comparedAt -Pattern $Foundation.timestamp_pattern -Context "PlanningRecord.reconciliation_state.compared_at"
            if ($null -ne $workingMatchesAccepted) {
                throw "PlanningRecord.reconciliation_state status 'pending' requires working_matches_accepted to be null."
            }
        }
        "blocked" {
            Assert-NonEmptyString -Value $comparedAt -Context "PlanningRecord.reconciliation_state.compared_at" | Out-Null
            Assert-RegexMatch -Value $comparedAt -Pattern $Foundation.timestamp_pattern -Context "PlanningRecord.reconciliation_state.compared_at"
            if ($null -ne $workingMatchesAccepted) {
                throw "PlanningRecord.reconciliation_state status 'blocked' requires working_matches_accepted to be null."
            }
        }
        "matched" {
            if ($AcceptedStateResult.State.status -eq "none") {
                throw "PlanningRecord.reconciliation_state status 'matched' requires an accepted surface."
            }
            Assert-NonEmptyString -Value $comparedAt -Context "PlanningRecord.reconciliation_state.compared_at" | Out-Null
            Assert-RegexMatch -Value $comparedAt -Pattern $Foundation.timestamp_pattern -Context "PlanningRecord.reconciliation_state.compared_at"
            if ($workingMatchesAccepted -ne $true) {
                throw "PlanningRecord.reconciliation_state status 'matched' requires working_matches_accepted to be true."
            }
        }
        "drift" {
            if ($AcceptedStateResult.State.status -eq "none") {
                throw "PlanningRecord.reconciliation_state status 'drift' requires an accepted surface."
            }
            Assert-NonEmptyString -Value $comparedAt -Context "PlanningRecord.reconciliation_state.compared_at" | Out-Null
            Assert-RegexMatch -Value $comparedAt -Pattern $Foundation.timestamp_pattern -Context "PlanningRecord.reconciliation_state.compared_at"
            if ($workingMatchesAccepted -ne $false) {
                throw "PlanningRecord.reconciliation_state status 'drift' requires working_matches_accepted to be false."
            }
        }
    }
}

function Test-PlanningRecordContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PlanningRecordPath
    )

    $resolvedPlanningRecordPath = Resolve-PlanningRecordPath -PlanningRecordPath $PlanningRecordPath
    $planningRecord = Get-JsonDocument -Path $resolvedPlanningRecordPath -Label "Planning record"
    $foundation = Get-PlanningRecordFoundationContract
    $contract = Get-PlanningRecordContract

    if ($contract.record_type -ne $foundation.record_type) {
        throw "Planning record contract record_type must equal '$($foundation.record_type)'."
    }

    Validate-TopLevelFields -PlanningRecord $planningRecord -Foundation $foundation
    $baseDirectory = Split-Path -Parent $resolvedPlanningRecordPath
    $workingStateResult = Validate-WorkingState -PlanningRecord $planningRecord -Foundation $foundation -BaseDirectory $baseDirectory
    $acceptedStateResult = Validate-AcceptedState -PlanningRecord $planningRecord -Foundation $foundation -BaseDirectory $baseDirectory -WorkingStateResult $workingStateResult
    Validate-ReconciliationState -PlanningRecord $planningRecord -Foundation $foundation -AcceptedStateResult $acceptedStateResult

    return [pscustomobject]@{
        IsValid                  = $true
        PlanningRecordId         = $planningRecord.planning_record_id
        ObjectType               = $planningRecord.object_type
        ObjectId                 = $planningRecord.object_id
        PlanningRecordPath       = $resolvedPlanningRecordPath
        WorkingRecordPath        = $workingStateResult.RecordPath
        AcceptedRecordPath       = $acceptedStateResult.RecordPath
        ReconciliationStatus     = $planningRecord.reconciliation_state.status
        FoundationContractPath   = Join-Path (Get-RepositoryRoot) "contracts\planning_records\foundation.contract.json"
        PlanningContractPath     = Join-Path (Get-RepositoryRoot) "contracts\planning_records\planning_record.contract.json"
    }
}

function New-PlanningRecord {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PlanningRecordId,
        [Parameter(Mandatory = $true)]
        $WorkingRecord,
        [Parameter(Mandatory = $true)]
        [datetime]$CreatedAt,
        [string]$InitialWorkingStatus = "draft"
    )

    $foundation = Get-PlanningRecordFoundationContract
    Assert-RegexMatch -Value $PlanningRecordId -Pattern $foundation.identifier_pattern -Context "PlanningRecordId"
    Assert-AllowedValue -Value $InitialWorkingStatus -AllowedValues @($foundation.allowed_working_state_statuses) -Context "InitialWorkingStatus"

    $validatedWorkingRecord = Test-GovernedWorkObjectObject -WorkObject $WorkingRecord -SourceLabel "New-PlanningRecord working record"
    $createdAtText = Get-UtcTimestamp -DateTime $CreatedAt

    return [pscustomobject]@{
        contract_version = $foundation.contract_version
        record_type = $foundation.record_type
        planning_record_id = $PlanningRecordId
        object_type = $validatedWorkingRecord.ObjectType
        object_id = $validatedWorkingRecord.ObjectId
        created_at = $createdAtText
        updated_at = $createdAtText
        working_state = [pscustomobject]@{
            status = $InitialWorkingStatus
            record_ref = $null
            object_type = $validatedWorkingRecord.ObjectType
            object_id = $validatedWorkingRecord.ObjectId
            object_status = $validatedWorkingRecord.Status
            last_local_update_at = $createdAtText
            notes = "Initial working record created."
            record = $WorkingRecord
        }
        accepted_state = [pscustomobject]@{
            status = "none"
            record_ref = $null
            object_type = $null
            object_id = $null
            object_status = $null
            accepted_at = $null
            accepted_by = $null
            notes = "No accepted record yet."
            record = $null
        }
        reconciliation_state = [pscustomobject]@{
            status = "not_started"
            compared_at = $null
            working_matches_accepted = $null
            notes = "No reconciliation recorded yet."
        }
    }
}

function Set-PlanningRecordWorkingState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $PlanningRecord,
        [Parameter(Mandatory = $true)]
        [string]$Status,
        [Parameter(Mandatory = $true)]
        $WorkObjectRecord,
        [Parameter(Mandatory = $true)]
        [datetime]$UpdatedAt,
        [Parameter(Mandatory = $true)]
        [string]$Notes
    )

    $foundation = Get-PlanningRecordFoundationContract
    Assert-AllowedValue -Value $Status -AllowedValues @($foundation.allowed_working_state_statuses) -Context "WorkingState.status"
    Assert-NonEmptyString -Value $Notes -Context "WorkingState.notes" | Out-Null

    $validatedWorkObject = Test-GovernedWorkObjectObject -WorkObject $WorkObjectRecord -SourceLabel "Set-PlanningRecordWorkingState work object"
    if ($validatedWorkObject.ObjectType -ne $PlanningRecord.object_type -or $validatedWorkObject.ObjectId -ne $PlanningRecord.object_id) {
        throw "Working surface work object must match the planning record identity."
    }

    $PlanningRecord.working_state.status = $Status
    $PlanningRecord.working_state.record_ref = $null
    $PlanningRecord.working_state.object_type = $validatedWorkObject.ObjectType
    $PlanningRecord.working_state.object_id = $validatedWorkObject.ObjectId
    $PlanningRecord.working_state.object_status = $validatedWorkObject.Status
    $PlanningRecord.working_state.last_local_update_at = Get-UtcTimestamp -DateTime $UpdatedAt
    $PlanningRecord.working_state.notes = $Notes
    $PlanningRecord.working_state.record = $WorkObjectRecord
    $PlanningRecord.updated_at = Get-UtcTimestamp -DateTime $UpdatedAt

    return $PlanningRecord
}

function Set-PlanningRecordAcceptedState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $PlanningRecord,
        [Parameter(Mandatory = $true)]
        [string]$Status,
        [AllowNull()]
        $WorkObjectRecord,
        [AllowNull()]
        [datetime]$AcceptedAt,
        [AllowNull()]
        [string]$AcceptedBy,
        [Parameter(Mandatory = $true)]
        [string]$Notes
    )

    $foundation = Get-PlanningRecordFoundationContract
    Assert-AllowedValue -Value $Status -AllowedValues @($foundation.allowed_accepted_state_statuses) -Context "AcceptedState.status"
    Assert-NonEmptyString -Value $Notes -Context "AcceptedState.notes" | Out-Null

    if ($Status -eq "none") {
        if ($null -ne $WorkObjectRecord -or $null -ne $AcceptedAt -or -not [string]::IsNullOrWhiteSpace($AcceptedBy)) {
            throw "AcceptedState status 'none' does not allow work object or acceptance metadata."
        }

        $PlanningRecord.accepted_state.status = "none"
        $PlanningRecord.accepted_state.record_ref = $null
        $PlanningRecord.accepted_state.object_type = $null
        $PlanningRecord.accepted_state.object_id = $null
        $PlanningRecord.accepted_state.object_status = $null
        $PlanningRecord.accepted_state.accepted_at = $null
        $PlanningRecord.accepted_state.accepted_by = $null
        $PlanningRecord.accepted_state.notes = $Notes
        $PlanningRecord.accepted_state.record = $null
        return $PlanningRecord
    }

    if ($null -eq $WorkObjectRecord) {
        throw "AcceptedState status '$Status' requires a work object record."
    }
    if ($null -eq $AcceptedAt) {
        throw "AcceptedState status '$Status' requires AcceptedAt."
    }
    Assert-NonEmptyString -Value $AcceptedBy -Context "AcceptedState.accepted_by" | Out-Null

    $validatedWorkObject = Test-GovernedWorkObjectObject -WorkObject $WorkObjectRecord -SourceLabel "Set-PlanningRecordAcceptedState work object"
    if ($validatedWorkObject.ObjectType -ne $PlanningRecord.object_type -or $validatedWorkObject.ObjectId -ne $PlanningRecord.object_id) {
        throw "Accepted surface work object must match the planning record identity."
    }

    $PlanningRecord.accepted_state.status = $Status
    $PlanningRecord.accepted_state.record_ref = $null
    $PlanningRecord.accepted_state.object_type = $validatedWorkObject.ObjectType
    $PlanningRecord.accepted_state.object_id = $validatedWorkObject.ObjectId
    $PlanningRecord.accepted_state.object_status = $validatedWorkObject.Status
    $PlanningRecord.accepted_state.accepted_at = Get-UtcTimestamp -DateTime $AcceptedAt
    $PlanningRecord.accepted_state.accepted_by = $AcceptedBy
    $PlanningRecord.accepted_state.notes = $Notes
    $PlanningRecord.accepted_state.record = $WorkObjectRecord
    $PlanningRecord.updated_at = Get-UtcTimestamp -DateTime $AcceptedAt

    return $PlanningRecord
}

function Set-PlanningRecordReconciliationState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $PlanningRecord,
        [Parameter(Mandatory = $true)]
        [string]$Status,
        [AllowNull()]
        [datetime]$ComparedAt,
        [AllowNull()]
        [Nullable[bool]]$WorkingMatchesAccepted,
        [Parameter(Mandatory = $true)]
        [string]$Notes
    )

    $foundation = Get-PlanningRecordFoundationContract
    Assert-AllowedValue -Value $Status -AllowedValues @($foundation.allowed_reconciliation_statuses) -Context "ReconciliationState.status"
    Assert-NonEmptyString -Value $Notes -Context "ReconciliationState.notes" | Out-Null

    $PlanningRecord.reconciliation_state.status = $Status
    $PlanningRecord.reconciliation_state.compared_at = if ($null -eq $ComparedAt) { $null } else { Get-UtcTimestamp -DateTime $ComparedAt }
    $PlanningRecord.reconciliation_state.working_matches_accepted = if ($null -eq $WorkingMatchesAccepted) { $null } else { [bool]$WorkingMatchesAccepted }
    $PlanningRecord.reconciliation_state.notes = $Notes
    if ($null -ne $ComparedAt) {
        $PlanningRecord.updated_at = Get-UtcTimestamp -DateTime $ComparedAt
    }

    return $PlanningRecord
}

function Convert-ToPersistedPlanningRecord {
    param(
        [Parameter(Mandatory = $true)]
        $PlanningRecord,
        [Parameter(Mandatory = $true)]
        [string]$WorkingRecordRef,
        [AllowNull()]
        [string]$AcceptedRecordRef
    )

    return [pscustomobject]@{
        contract_version = $PlanningRecord.contract_version
        record_type = $PlanningRecord.record_type
        planning_record_id = $PlanningRecord.planning_record_id
        object_type = $PlanningRecord.object_type
        object_id = $PlanningRecord.object_id
        created_at = $PlanningRecord.created_at
        updated_at = $PlanningRecord.updated_at
        working_state = [pscustomobject]@{
            status = $PlanningRecord.working_state.status
            record_ref = $WorkingRecordRef
            object_type = $PlanningRecord.working_state.object_type
            object_id = $PlanningRecord.working_state.object_id
            object_status = $PlanningRecord.working_state.object_status
            last_local_update_at = $PlanningRecord.working_state.last_local_update_at
            notes = $PlanningRecord.working_state.notes
        }
        accepted_state = [pscustomobject]@{
            status = $PlanningRecord.accepted_state.status
            record_ref = $AcceptedRecordRef
            object_type = $PlanningRecord.accepted_state.object_type
            object_id = $PlanningRecord.accepted_state.object_id
            object_status = $PlanningRecord.accepted_state.object_status
            accepted_at = $PlanningRecord.accepted_state.accepted_at
            accepted_by = $PlanningRecord.accepted_state.accepted_by
            notes = $PlanningRecord.accepted_state.notes
        }
        reconciliation_state = [pscustomobject]@{
            status = $PlanningRecord.reconciliation_state.status
            compared_at = $PlanningRecord.reconciliation_state.compared_at
            working_matches_accepted = $PlanningRecord.reconciliation_state.working_matches_accepted
            notes = $PlanningRecord.reconciliation_state.notes
        }
    }
}

function Save-PlanningRecord {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $PlanningRecord,
        [Parameter(Mandatory = $true)]
        [string]$StorePath
    )

    if ($null -eq $PlanningRecord.working_state.record) {
        throw "PlanningRecord working_state.record must exist before save."
    }

    $workingRecordValidation = Test-GovernedWorkObjectObject -WorkObject $PlanningRecord.working_state.record -SourceLabel "Save-PlanningRecord working record"
    if ($workingRecordValidation.ObjectType -ne $PlanningRecord.object_type -or $workingRecordValidation.ObjectId -ne $PlanningRecord.object_id) {
        throw "PlanningRecord working_state.record must match the planning record identity before save."
    }

    $resolvedStorePath = if ([System.IO.Path]::IsPathRooted($StorePath)) { $StorePath } else { Join-Path (Get-Location) $StorePath }
    if (-not (Test-Path -LiteralPath $resolvedStorePath)) {
        New-Item -ItemType Directory -Path $resolvedStorePath -Force | Out-Null
    }

    $workingDirectory = Join-Path $resolvedStorePath "working"
    $acceptedDirectory = Join-Path $resolvedStorePath "accepted"
    New-Item -ItemType Directory -Path $workingDirectory -Force | Out-Null
    New-Item -ItemType Directory -Path $acceptedDirectory -Force | Out-Null

    $workingRecordRef = "working/{0}.{1}.json" -f $PlanningRecord.planning_record_id, $PlanningRecord.object_type
    $workingRecordPath = Join-Path $resolvedStorePath ($workingRecordRef -replace "/", "\")
    Write-JsonDocument -Path $workingRecordPath -Document $PlanningRecord.working_state.record

    $acceptedRecordRef = $null
    if ($PlanningRecord.accepted_state.status -ne "none") {
        if ($null -eq $PlanningRecord.accepted_state.record) {
            throw "PlanningRecord accepted_state.record must exist when accepted_state.status is '$($PlanningRecord.accepted_state.status)'."
        }

        $acceptedRecordValidation = Test-GovernedWorkObjectObject -WorkObject $PlanningRecord.accepted_state.record -SourceLabel "Save-PlanningRecord accepted record"
        if ($acceptedRecordValidation.ObjectType -ne $PlanningRecord.object_type -or $acceptedRecordValidation.ObjectId -ne $PlanningRecord.object_id) {
            throw "PlanningRecord accepted_state.record must match the planning record identity before save."
        }

        $acceptedRecordRef = "accepted/{0}.{1}.json" -f $PlanningRecord.planning_record_id, $PlanningRecord.object_type
        $acceptedRecordPath = Join-Path $resolvedStorePath ($acceptedRecordRef -replace "/", "\")
        Write-JsonDocument -Path $acceptedRecordPath -Document $PlanningRecord.accepted_state.record
    }

    $persistedRecord = Convert-ToPersistedPlanningRecord -PlanningRecord $PlanningRecord -WorkingRecordRef $workingRecordRef -AcceptedRecordRef $acceptedRecordRef
    $planningRecordPath = Join-Path $resolvedStorePath ("{0}.json" -f $PlanningRecord.planning_record_id)
    Write-JsonDocument -Path $planningRecordPath -Document $persistedRecord
    Test-PlanningRecordContract -PlanningRecordPath $planningRecordPath | Out-Null

    return $planningRecordPath
}

function Get-PlanningRecord {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PlanningRecordId,
        [Parameter(Mandatory = $true)]
        [string]$StorePath
    )

    $resolvedStorePath = if ([System.IO.Path]::IsPathRooted($StorePath)) { $StorePath } else { Join-Path (Get-Location) $StorePath }
    $planningRecordPath = Join-Path $resolvedStorePath ("{0}.json" -f $PlanningRecordId)
    $validation = Test-PlanningRecordContract -PlanningRecordPath $planningRecordPath
    $planningRecord = Get-JsonDocument -Path $validation.PlanningRecordPath -Label "Planning record"

    $workingRecord = Get-JsonDocument -Path $validation.WorkingRecordPath -Label "Working surface work object"
    Add-Member -InputObject $planningRecord.working_state -NotePropertyName "record" -NotePropertyValue $workingRecord -Force

    if ($null -ne $validation.AcceptedRecordPath) {
        $acceptedRecord = Get-JsonDocument -Path $validation.AcceptedRecordPath -Label "Accepted surface work object"
    }
    else {
        $acceptedRecord = $null
    }
    Add-Member -InputObject $planningRecord.accepted_state -NotePropertyName "record" -NotePropertyValue $acceptedRecord -Force

    return $planningRecord
}

Export-ModuleMember -Function Test-PlanningRecordContract, New-PlanningRecord, Set-PlanningRecordWorkingState, Set-PlanningRecordAcceptedState, Set-PlanningRecordReconciliationState, Save-PlanningRecord, Get-PlanningRecord
