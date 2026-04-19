Set-StrictMode -Version Latest

function Resolve-WorkObjectPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorkObjectPath
    )

    if ([System.IO.Path]::IsPathRooted($WorkObjectPath)) {
        $resolvedPath = $WorkObjectPath
    }
    else {
        $resolvedPath = Join-Path (Get-Location) $WorkObjectPath
    }

    if (-not (Test-Path -LiteralPath $resolvedPath)) {
        throw "Work object path '$WorkObjectPath' does not exist."
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
        $joined = ($AllowedValues -join ", ")
        throw "$Context must be one of: $joined."
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

    return $items
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
        Assert-ObjectValue -Value $item -Context "$Context item" | Out-Null
    }

    return $items
}

function Get-RepositoryRoot {
    return (Split-Path -Parent $PSScriptRoot)
}

function Test-ContainsAny {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Values,
        [Parameter(Mandatory = $true)]
        [string[]]$AllowedValues
    )

    foreach ($value in $Values) {
        if ($AllowedValues -contains $value) {
            return $true
        }
    }

    return $false
}

function Validate-CommonFields {
    param(
        [Parameter(Mandatory = $true)]
        $WorkObject,
        [Parameter(Mandatory = $true)]
        $Foundation
    )

    foreach ($fieldName in $Foundation.common_required_fields) {
        Get-RequiredProperty -Object $WorkObject -Name $fieldName -Context "WorkObject" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $WorkObject -Name "contract_version" -Context "WorkObject") -Context "WorkObject.contract_version"
    if ($contractVersion -ne $Foundation.contract_version) {
        throw "WorkObject.contract_version must equal '$($Foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $WorkObject -Name "record_type" -Context "WorkObject") -Context "WorkObject.record_type"
    if ($recordType -ne $Foundation.record_type) {
        throw "WorkObject.record_type must equal '$($Foundation.record_type)'."
    }

    $objectType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $WorkObject -Name "object_type" -Context "WorkObject") -Context "WorkObject.object_type"
    Assert-AllowedValue -Value $objectType -AllowedValues @($Foundation.allowed_object_types) -Context "WorkObject.object_type"

    $objectId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $WorkObject -Name "object_id" -Context "WorkObject") -Context "WorkObject.object_id"
    Assert-RegexMatch -Value $objectId -Pattern $Foundation.identifier_pattern -Context "WorkObject.object_id"

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $WorkObject -Name "title" -Context "WorkObject") -Context "WorkObject.title" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $WorkObject -Name "summary" -Context "WorkObject") -Context "WorkObject.summary" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $WorkObject -Name "status" -Context "WorkObject") -Context "WorkObject.status" | Out-Null

    $createdAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $WorkObject -Name "created_at" -Context "WorkObject") -Context "WorkObject.created_at"
    Assert-RegexMatch -Value $createdAt -Pattern $Foundation.timestamp_pattern -Context "WorkObject.created_at"

    $createdBy = Assert-ObjectValue -Value (Get-RequiredProperty -Object $WorkObject -Name "created_by" -Context "WorkObject") -Context "WorkObject.created_by"
    foreach ($fieldName in $Foundation.created_by_required_fields) {
        Get-RequiredProperty -Object $createdBy -Name $fieldName -Context "WorkObject.created_by" | Out-Null
    }
    $createdByRole = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $createdBy -Name "role" -Context "WorkObject.created_by") -Context "WorkObject.created_by.role"
    Assert-AllowedValue -Value $createdByRole -AllowedValues @($Foundation.allowed_actor_roles) -Context "WorkObject.created_by.role"
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $createdBy -Name "id" -Context "WorkObject.created_by") -Context "WorkObject.created_by.id" | Out-Null

    $lineage = Assert-ObjectValue -Value (Get-RequiredProperty -Object $WorkObject -Name "lineage" -Context "WorkObject") -Context "WorkObject.lineage"
    foreach ($fieldName in $Foundation.lineage_required_fields) {
        Get-RequiredProperty -Object $lineage -Name $fieldName -Context "WorkObject.lineage" | Out-Null
    }
    $sourceKind = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $lineage -Name "source_kind" -Context "WorkObject.lineage") -Context "WorkObject.lineage.source_kind"
    Assert-AllowedValue -Value $sourceKind -AllowedValues @($Foundation.allowed_source_kinds) -Context "WorkObject.lineage.source_kind"
    Assert-StringArray -Value (Get-RequiredProperty -Object $lineage -Name "source_refs" -Context "WorkObject.lineage") -Context "WorkObject.lineage.source_refs" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $lineage -Name "rationale" -Context "WorkObject.lineage") -Context "WorkObject.lineage.rationale" | Out-Null

    $relationships = Assert-ObjectArray -Value (Get-RequiredProperty -Object $WorkObject -Name "relationships" -Context "WorkObject") -Context "WorkObject.relationships" -AllowEmpty
    foreach ($relationship in $relationships) {
        foreach ($fieldName in $Foundation.relationship_required_fields) {
            Get-RequiredProperty -Object $relationship -Name $fieldName -Context "WorkObject.relationships item" | Out-Null
        }
        $relation = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $relationship -Name "relation" -Context "WorkObject.relationships item") -Context "WorkObject.relationships item.relation"
        Assert-AllowedValue -Value $relation -AllowedValues @($Foundation.allowed_relationship_relations) -Context "WorkObject.relationships item.relation"
        $relationshipObjectType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $relationship -Name "object_type" -Context "WorkObject.relationships item") -Context "WorkObject.relationships item.object_type"
        Assert-AllowedValue -Value $relationshipObjectType -AllowedValues @($Foundation.allowed_object_types) -Context "WorkObject.relationships item.object_type"
        $relationshipObjectId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $relationship -Name "object_id" -Context "WorkObject.relationships item") -Context "WorkObject.relationships item.object_id"
        Assert-RegexMatch -Value $relationshipObjectId -Pattern $Foundation.identifier_pattern -Context "WorkObject.relationships item.object_id"
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $relationship -Name "ref" -Context "WorkObject.relationships item") -Context "WorkObject.relationships item.ref" | Out-Null
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $relationship -Name "notes" -Context "WorkObject.relationships item") -Context "WorkObject.relationships item.notes" | Out-Null
    }

    $evidence = Assert-ObjectArray -Value (Get-RequiredProperty -Object $WorkObject -Name "evidence" -Context "WorkObject") -Context "WorkObject.evidence"
    foreach ($evidenceItem in $evidence) {
        foreach ($fieldName in $Foundation.evidence_required_fields) {
            Get-RequiredProperty -Object $evidenceItem -Name $fieldName -Context "WorkObject.evidence item" | Out-Null
        }
        $evidenceKind = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $evidenceItem -Name "kind" -Context "WorkObject.evidence item") -Context "WorkObject.evidence item.kind"
        Assert-AllowedValue -Value $evidenceKind -AllowedValues @($Foundation.allowed_evidence_kinds) -Context "WorkObject.evidence item.kind"
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $evidenceItem -Name "ref" -Context "WorkObject.evidence item") -Context "WorkObject.evidence item.ref" | Out-Null
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $evidenceItem -Name "summary" -Context "WorkObject.evidence item") -Context "WorkObject.evidence item.summary" | Out-Null
    }

    $audit = Assert-ObjectValue -Value (Get-RequiredProperty -Object $WorkObject -Name "audit" -Context "WorkObject") -Context "WorkObject.audit"
    foreach ($fieldName in $Foundation.audit_required_fields) {
        Get-RequiredProperty -Object $audit -Name $fieldName -Context "WorkObject.audit" | Out-Null
    }
    Assert-StringArray -Value (Get-RequiredProperty -Object $audit -Name "trail_refs" -Context "WorkObject.audit") -Context "WorkObject.audit.trail_refs" | Out-Null
    $lastReviewedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $audit -Name "last_reviewed_at" -Context "WorkObject.audit") -Context "WorkObject.audit.last_reviewed_at"
    Assert-RegexMatch -Value $lastReviewedAt -Pattern $Foundation.timestamp_pattern -Context "WorkObject.audit.last_reviewed_at"
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $audit -Name "notes" -Context "WorkObject.audit") -Context "WorkObject.audit.notes" | Out-Null
}

function Validate-ParentInvariant {
    param(
        [Parameter(Mandatory = $true)]
        $WorkObject,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        $Foundation
    )

    $parent = Get-RequiredProperty -Object $WorkObject -Name "parent" -Context "WorkObject"
    if ($Contract.parent_requirement -eq "forbidden") {
        if ($null -ne $parent) {
            throw "WorkObject.parent must be null for object type '$($Contract.object_type)'."
        }

        return
    }

    $parentObject = Assert-ObjectValue -Value $parent -Context "WorkObject.parent"
    foreach ($fieldName in $Foundation.parent_required_fields) {
        Get-RequiredProperty -Object $parentObject -Name $fieldName -Context "WorkObject.parent" | Out-Null
    }

    $parentObjectType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $parentObject -Name "object_type" -Context "WorkObject.parent") -Context "WorkObject.parent.object_type"
    Assert-AllowedValue -Value $parentObjectType -AllowedValues @($Contract.allowed_parent_object_types) -Context "WorkObject.parent.object_type"

    $parentObjectId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $parentObject -Name "object_id" -Context "WorkObject.parent") -Context "WorkObject.parent.object_id"
    Assert-RegexMatch -Value $parentObjectId -Pattern $Foundation.identifier_pattern -Context "WorkObject.parent.object_id"
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $parentObject -Name "ref" -Context "WorkObject.parent") -Context "WorkObject.parent.ref" | Out-Null
}

function Validate-SpecificField {
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$FieldName,
        [Parameter(Mandatory = $true)]
        [string]$FieldType,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $fieldValue = Get-RequiredProperty -Object $Object -Name $FieldName -Context $Context
    switch ($FieldType) {
        "string" {
            Assert-NonEmptyString -Value $fieldValue -Context "$Context.$FieldName" | Out-Null
        }
        "nullable_string" {
            Assert-NullableString -Value $fieldValue -Context "$Context.$FieldName" | Out-Null
        }
        "string_array" {
            Assert-StringArray -Value $fieldValue -Context "$Context.$FieldName" | Out-Null
        }
        "object" {
            Assert-ObjectValue -Value $fieldValue -Context "$Context.$FieldName" | Out-Null
        }
        default {
            throw "Unsupported field type '$FieldType' in contract '$Context'."
        }
    }
}

function Validate-SpecificFields {
    param(
        [Parameter(Mandatory = $true)]
        $WorkObject,
        [Parameter(Mandatory = $true)]
        $Contract
    )

    foreach ($fieldName in $Contract.required_fields) {
        Get-RequiredProperty -Object $WorkObject -Name $fieldName -Context "WorkObject" | Out-Null
        Validate-SpecificField -Object $WorkObject -FieldName $fieldName -FieldType $Contract.field_types.$fieldName -Context "WorkObject"
    }

    foreach ($fieldName in @($Contract.optional_fields)) {
        if (Test-HasProperty -Object $WorkObject -Name $fieldName) {
            Validate-SpecificField -Object $WorkObject -FieldName $fieldName -FieldType $Contract.field_types.$fieldName -Context "WorkObject"
        }
    }
}

function Validate-LineageAndEvidenceInvariants {
    param(
        [Parameter(Mandatory = $true)]
        $WorkObject,
        [Parameter(Mandatory = $true)]
        $Contract
    )

    $lineage = Get-RequiredProperty -Object $WorkObject -Name "lineage" -Context "WorkObject"
    $sourceKind = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $lineage -Name "source_kind" -Context "WorkObject.lineage") -Context "WorkObject.lineage.source_kind"
    Assert-AllowedValue -Value $sourceKind -AllowedValues @($Contract.allowed_lineage_source_kinds) -Context "WorkObject.lineage.source_kind"

    $evidenceKinds = @((Get-RequiredProperty -Object $WorkObject -Name "evidence" -Context "WorkObject").kind)
    foreach ($requiredEvidenceKind in @($Contract.required_evidence_kinds)) {
        if ($evidenceKinds -notcontains $requiredEvidenceKind) {
            throw "WorkObject.evidence must include kind '$requiredEvidenceKind' for object type '$($Contract.object_type)'."
        }
    }
}

function Validate-RelationshipInvariants {
    param(
        [Parameter(Mandatory = $true)]
        $WorkObject,
        [Parameter(Mandatory = $true)]
        $Contract
    )

    foreach ($relationship in @((Get-RequiredProperty -Object $WorkObject -Name "relationships" -Context "WorkObject"))) {
        $relation = $relationship.relation
        if (-not (Test-HasProperty -Object $Contract.allowed_relationships -Name $relation)) {
            throw "Relationship '$relation' is not allowed for object type '$($Contract.object_type)'."
        }

        $allowedTargets = @($Contract.allowed_relationships.$relation)
        if ($allowedTargets -notcontains $relationship.object_type) {
            throw "Relationship '$relation' cannot target object type '$($relationship.object_type)' for object type '$($Contract.object_type)'."
        }
    }
}

function Validate-StatusInvariants {
    param(
        [Parameter(Mandatory = $true)]
        $WorkObject,
        [Parameter(Mandatory = $true)]
        $Contract
    )

    $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $WorkObject -Name "status" -Context "WorkObject") -Context "WorkObject.status"
    Assert-AllowedValue -Value $status -AllowedValues @($Contract.lifecycle.allowed_statuses) -Context "WorkObject.status"

    switch ($Contract.object_type) {
        "milestone" {
            if ($status -eq "completed") {
                if (-not (Test-HasProperty -Object $WorkObject -Name "completion_summary")) {
                    throw "Completed milestones must include WorkObject.completion_summary."
                }
                Assert-NonEmptyString -Value $WorkObject.completion_summary -Context "WorkObject.completion_summary" | Out-Null
                $evidenceKinds = @($WorkObject.evidence.kind)
                foreach ($requiredKind in @($Contract.completed_requires_evidence_kinds)) {
                    if ($evidenceKinds -notcontains $requiredKind) {
                        throw "Completed milestones must include evidence kind '$requiredKind'."
                    }
                }
            }
        }
        "task" {
            $taskKind = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $WorkObject -Name "task_kind" -Context "WorkObject") -Context "WorkObject.task_kind"
            Assert-AllowedValue -Value $taskKind -AllowedValues @($Contract.allowed_task_kinds) -Context "WorkObject.task_kind"
            if ($status -eq "done") {
                if (-not (Test-HasProperty -Object $WorkObject -Name "completion_summary")) {
                    throw "Done tasks must include WorkObject.completion_summary."
                }
                Assert-NonEmptyString -Value $WorkObject.completion_summary -Context "WorkObject.completion_summary" | Out-Null
                $evidenceKinds = @($WorkObject.evidence.kind)
                if (-not (Test-ContainsAny -Values $evidenceKinds -AllowedValues @($Contract.done_requires_one_of_evidence_kinds))) {
                    $requiredKinds = ($Contract.done_requires_one_of_evidence_kinds -join ", ")
                    throw "Done tasks must include at least one of these evidence kinds: $requiredKinds."
                }
            }
        }
        "bug" {
            $severity = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $WorkObject -Name "severity" -Context "WorkObject") -Context "WorkObject.severity"
            Assert-AllowedValue -Value $severity -AllowedValues @($Contract.allowed_severities) -Context "WorkObject.severity"

            $resolution = Assert-ObjectValue -Value (Get-RequiredProperty -Object $WorkObject -Name "resolution" -Context "WorkObject") -Context "WorkObject.resolution"
            foreach ($fieldName in $Contract.resolution_required_fields) {
                Get-RequiredProperty -Object $resolution -Name $fieldName -Context "WorkObject.resolution" | Out-Null
            }
            $resolutionKind = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $resolution -Name "kind" -Context "WorkObject.resolution") -Context "WorkObject.resolution.kind"
            Assert-AllowedValue -Value $resolutionKind -AllowedValues @($Contract.allowed_resolution_kinds) -Context "WorkObject.resolution.kind"
            Assert-NonEmptyString -Value (Get-RequiredProperty -Object $resolution -Name "summary" -Context "WorkObject.resolution") -Context "WorkObject.resolution.summary" | Out-Null
            Assert-StringArray -Value (Get-RequiredProperty -Object $resolution -Name "evidence_refs" -Context "WorkObject.resolution") -Context "WorkObject.resolution.evidence_refs" | Out-Null

            if (@($Contract.statuses_requiring_open_resolution) -contains $status -and $resolutionKind -ne "open") {
                throw "Bug status '$status' requires resolution.kind 'open'."
            }
            if (@($Contract.statuses_requiring_resolved_resolution) -contains $status -and @("fix", "workaround") -notcontains $resolutionKind) {
                throw "Bug status '$status' requires resolution.kind 'fix' or 'workaround'."
            }
            if (@($Contract.statuses_requiring_rejected_resolution) -contains $status -and $resolutionKind -ne "rejected") {
                throw "Bug status '$status' requires resolution.kind 'rejected'."
            }
        }
    }
}

function Test-GovernedWorkObjectContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorkObjectPath
    )

    $repoRoot = Get-RepositoryRoot
    $resolvedWorkObjectPath = Resolve-WorkObjectPath -WorkObjectPath $WorkObjectPath
    $foundationPath = Join-Path $repoRoot "contracts\governed_work_objects\foundation.contract.json"
    $foundation = Get-JsonDocument -Path $foundationPath -Label "Foundation contract"
    $workObject = Get-JsonDocument -Path $resolvedWorkObjectPath -Label "Work object"

    $objectType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $workObject -Name "object_type" -Context "WorkObject") -Context "WorkObject.object_type"
    $contractPath = Join-Path $repoRoot ("contracts\governed_work_objects\{0}.contract.json" -f $objectType)
    if (-not (Test-Path -LiteralPath $contractPath)) {
        throw "No governed work object contract exists for object type '$objectType'."
    }

    $contract = Get-JsonDocument -Path $contractPath -Label "Work object contract"
    if ($contract.object_type -ne $objectType) {
        throw "Work object contract '$contractPath' does not match object type '$objectType'."
    }

    Validate-CommonFields -WorkObject $workObject -Foundation $foundation
    Validate-ParentInvariant -WorkObject $workObject -Contract $contract -Foundation $foundation
    Validate-SpecificFields -WorkObject $workObject -Contract $contract
    Validate-LineageAndEvidenceInvariants -WorkObject $workObject -Contract $contract
    Validate-RelationshipInvariants -WorkObject $workObject -Contract $contract
    Validate-StatusInvariants -WorkObject $workObject -Contract $contract

    return [pscustomobject]@{
        IsValid              = $true
        ObjectType           = $objectType
        ObjectId             = $workObject.object_id
        WorkObjectPath       = $resolvedWorkObjectPath
        ContractPath         = $contractPath
        FoundationContractPath = $foundationPath
    }
}

Export-ModuleMember -Function Test-GovernedWorkObjectContract
