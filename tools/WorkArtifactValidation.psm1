Set-StrictMode -Version Latest

$governedValidationModulePath = Join-Path $PSScriptRoot "GovernedWorkObjectValidation.psm1"
$planningRecordStorageModulePath = Join-Path $PSScriptRoot "PlanningRecordStorage.psm1"
Import-Module $governedValidationModulePath -Force
Import-Module $planningRecordStorageModulePath -Force

function Get-RepositoryRoot {
    return (Split-Path -Parent $PSScriptRoot)
}

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
        throw "Artifact path '$ArtifactPath' does not exist."
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
        Assert-ObjectValue -Value $item -Context "$Context item" | Out-Null
    }

    Write-Output -NoEnumerate $items
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

    return $Value
}

function Get-ArtifactFoundationContract {
    $path = Join-Path (Get-RepositoryRoot) "contracts\work_artifacts\foundation.contract.json"
    return (Get-JsonDocument -Path $path -Label "Work artifact foundation contract")
}

function Get-ArtifactSpecificContract {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArtifactType
    )

    $path = Join-Path (Get-RepositoryRoot) ("contracts\work_artifacts\{0}.contract.json" -f $ArtifactType)
    if (-not (Test-Path -LiteralPath $path)) {
        throw "No work artifact contract exists for artifact type '$ArtifactType'."
    }

    return (Get-JsonDocument -Path $path -Label "Work artifact contract")
}

function Resolve-ReferencePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory,
        [Parameter(Mandatory = $true)]
        [string]$Reference
    )

    if ([System.IO.Path]::IsPathRooted($Reference)) {
        $candidate = $Reference
    }
    else {
        $relativeRef = $Reference -replace "[/\\]", [System.IO.Path]::DirectorySeparatorChar
        $candidate = Join-Path $BaseDirectory $relativeRef
    }

    if (-not (Test-Path -LiteralPath $candidate)) {
        throw "Reference '$Reference' does not exist."
    }

    return (Resolve-Path -LiteralPath $candidate).Path
}

function Validate-CommonFields {
    param(
        [Parameter(Mandatory = $true)]
        $Artifact,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract
    )

    foreach ($fieldName in $Foundation.common_required_fields) {
        Get-RequiredProperty -Object $Artifact -Name $fieldName -Context "Artifact" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "contract_version" -Context "Artifact") -Context "Artifact.contract_version"
    if ($contractVersion -ne $Foundation.contract_version) {
        throw "Artifact.contract_version must equal '$($Foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "record_type" -Context "Artifact") -Context "Artifact.record_type"
    if ($recordType -ne $Foundation.record_type) {
        throw "Artifact.record_type must equal '$($Foundation.record_type)'."
    }

    $artifactType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "artifact_type" -Context "Artifact") -Context "Artifact.artifact_type"
    Assert-AllowedValue -Value $artifactType -AllowedValues @($Foundation.allowed_artifact_types) -Context "Artifact.artifact_type"
    if ($artifactType -ne $Contract.artifact_type) {
        throw "Artifact.artifact_type does not match its contract."
    }

    $artifactId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "artifact_id" -Context "Artifact") -Context "Artifact.artifact_id"
    Assert-RegexMatch -Value $artifactId -Pattern $Foundation.identifier_pattern -Context "Artifact.artifact_id"

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "title" -Context "Artifact") -Context "Artifact.title" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "summary" -Context "Artifact") -Context "Artifact.summary" | Out-Null

    $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "status" -Context "Artifact") -Context "Artifact.status"
    Assert-AllowedValue -Value $status -AllowedValues @($Contract.lifecycle.allowed_statuses) -Context "Artifact.status"

    $createdAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "created_at" -Context "Artifact") -Context "Artifact.created_at"
    Assert-RegexMatch -Value $createdAt -Pattern $Foundation.timestamp_pattern -Context "Artifact.created_at"

    $createdBy = Assert-ObjectValue -Value (Get-RequiredProperty -Object $Artifact -Name "created_by" -Context "Artifact") -Context "Artifact.created_by"
    foreach ($fieldName in $Foundation.created_by_required_fields) {
        Get-RequiredProperty -Object $createdBy -Name $fieldName -Context "Artifact.created_by" | Out-Null
    }
    $role = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $createdBy -Name "role" -Context "Artifact.created_by") -Context "Artifact.created_by.role"
    Assert-AllowedValue -Value $role -AllowedValues @($Foundation.allowed_actor_roles) -Context "Artifact.created_by.role"
    Assert-AllowedValue -Value $role -AllowedValues @($Contract.allowed_created_by_roles) -Context "Artifact.created_by.role"
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $createdBy -Name "id" -Context "Artifact.created_by") -Context "Artifact.created_by.id" | Out-Null
}

function Validate-Lineage {
    param(
        [Parameter(Mandatory = $true)]
        $Artifact,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract
    )

    $lineage = Assert-ObjectValue -Value (Get-RequiredProperty -Object $Artifact -Name "lineage" -Context "Artifact") -Context "Artifact.lineage"
    foreach ($fieldName in $Foundation.lineage_required_fields) {
        Get-RequiredProperty -Object $lineage -Name $fieldName -Context "Artifact.lineage" | Out-Null
    }

    $sourceKind = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $lineage -Name "source_kind" -Context "Artifact.lineage") -Context "Artifact.lineage.source_kind"
    Assert-AllowedValue -Value $sourceKind -AllowedValues @($Foundation.allowed_source_kinds) -Context "Artifact.lineage.source_kind"
    Assert-AllowedValue -Value $sourceKind -AllowedValues @($Contract.allowed_lineage_source_kinds) -Context "Artifact.lineage.source_kind"
    Assert-StringArray -Value (Get-RequiredProperty -Object $lineage -Name "source_refs" -Context "Artifact.lineage") -Context "Artifact.lineage.source_refs" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $lineage -Name "rationale" -Context "Artifact.lineage") -Context "Artifact.lineage.rationale" | Out-Null

    return $lineage
}

function Validate-Pipeline {
    param(
        [Parameter(Mandatory = $true)]
        $Artifact,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract
    )

    $pipeline = Assert-ObjectValue -Value (Get-RequiredProperty -Object $Artifact -Name "pipeline" -Context "Artifact") -Context "Artifact.pipeline"
    foreach ($fieldName in $Foundation.pipeline_required_fields) {
        Get-RequiredProperty -Object $pipeline -Name $fieldName -Context "Artifact.pipeline" | Out-Null
    }

    $mode = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $pipeline -Name "mode" -Context "Artifact.pipeline") -Context "Artifact.pipeline.mode"
    Assert-AllowedValue -Value $mode -AllowedValues @($Foundation.allowed_pipeline_modes) -Context "Artifact.pipeline.mode"

    $runtimeBoundary = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $pipeline -Name "runtime_boundary" -Context "Artifact.pipeline") -Context "Artifact.pipeline.runtime_boundary"
    Assert-AllowedValue -Value $runtimeBoundary -AllowedValues @($Foundation.allowed_runtime_boundaries) -Context "Artifact.pipeline.runtime_boundary"

    $standardRuntimeClaimed = Assert-BooleanValue -Value (Get-RequiredProperty -Object $pipeline -Name "standard_runtime_claimed" -Context "Artifact.pipeline") -Context "Artifact.pipeline.standard_runtime_claimed"
    if ($standardRuntimeClaimed) {
        throw "Artifact.pipeline.standard_runtime_claimed must remain false for the bounded admin-only repo surface."
    }

    $subprojectRuntimeClaimed = Assert-BooleanValue -Value (Get-RequiredProperty -Object $pipeline -Name "subproject_runtime_claimed" -Context "Artifact.pipeline") -Context "Artifact.pipeline.subproject_runtime_claimed"
    if ($subprojectRuntimeClaimed) {
        throw "Artifact.pipeline.subproject_runtime_claimed must remain false for the bounded admin-only repo surface."
    }

    $orchestrationScope = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $pipeline -Name "orchestration_scope" -Context "Artifact.pipeline") -Context "Artifact.pipeline.orchestration_scope"
    Assert-AllowedValue -Value $orchestrationScope -AllowedValues @($Foundation.allowed_orchestration_scopes) -Context "Artifact.pipeline.orchestration_scope"
    Assert-AllowedValue -Value $orchestrationScope -AllowedValues @($Contract.allowed_orchestration_scopes) -Context "Artifact.pipeline.orchestration_scope"
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $pipeline -Name "notes" -Context "Artifact.pipeline") -Context "Artifact.pipeline.notes" | Out-Null

    return [pscustomobject]@{
        Mode               = $mode
        RuntimeBoundary    = $runtimeBoundary
        OrchestrationScope = $orchestrationScope
    }
}

function Validate-Scope {
    param(
        [Parameter(Mandatory = $true)]
        $Artifact,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        $Pipeline
    )

    $scope = Assert-ObjectValue -Value (Get-RequiredProperty -Object $Artifact -Name "scope" -Context "Artifact") -Context "Artifact.scope"
    foreach ($fieldName in $Foundation.scope_required_fields) {
        Get-RequiredProperty -Object $scope -Name $fieldName -Context "Artifact.scope" | Out-Null
    }

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $scope -Name "summary" -Context "Artifact.scope") -Context "Artifact.scope.summary" | Out-Null
    $allowedSurfaces = [string[]](Assert-StringArray -Value (Get-RequiredProperty -Object $scope -Name "allowed_surfaces" -Context "Artifact.scope") -Context "Artifact.scope.allowed_surfaces")
    $protectedSurfaces = [string[]](Assert-StringArray -Value (Get-RequiredProperty -Object $scope -Name "protected_surfaces" -Context "Artifact.scope") -Context "Artifact.scope.protected_surfaces")
    $prohibitedSurfaces = [string[]](Assert-StringArray -Value (Get-RequiredProperty -Object $scope -Name "prohibited_surfaces" -Context "Artifact.scope") -Context "Artifact.scope.prohibited_surfaces" -AllowEmpty)
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $scope -Name "notes" -Context "Artifact.scope") -Context "Artifact.scope.notes" | Out-Null

    foreach ($surface in @($allowedSurfaces + $protectedSurfaces + $prohibitedSurfaces)) {
        Assert-AllowedValue -Value $surface -AllowedValues @($Foundation.allowed_scope_surfaces) -Context "Artifact.scope surface"
    }
    foreach ($surface in @($allowedSurfaces + $protectedSurfaces)) {
        Assert-AllowedValue -Value $surface -AllowedValues @($Contract.allowed_scope_surfaces) -Context "Artifact.scope surface"
    }

    foreach ($protectedSurface in @($protectedSurfaces)) {
        if ($allowedSurfaces -notcontains $protectedSurface) {
            throw "Artifact.scope.protected_surfaces must be a subset of Artifact.scope.allowed_surfaces."
        }
    }

    foreach ($requiredProtectedSurface in @($Contract.required_protected_surfaces)) {
        if ($protectedSurfaces -notcontains $requiredProtectedSurface) {
            throw "Artifact.scope.protected_surfaces must include '$requiredProtectedSurface' for artifact type '$($Contract.artifact_type)'."
        }
    }

    foreach ($requiredProhibitedSurface in @($Contract.required_prohibited_surfaces)) {
        if ($prohibitedSurfaces -notcontains $requiredProhibitedSurface) {
            throw "Artifact.scope.prohibited_surfaces must include '$requiredProhibitedSurface' for artifact type '$($Contract.artifact_type)'."
        }
    }

    foreach ($prohibitedSurface in @($prohibitedSurfaces)) {
        if ($allowedSurfaces -contains $prohibitedSurface) {
            throw "Artifact.scope.allowed_surfaces must not include prohibited surface '$prohibitedSurface'."
        }
        if ($protectedSurfaces -contains $prohibitedSurface) {
            throw "Artifact.scope.protected_surfaces must not include prohibited surface '$prohibitedSurface'."
        }
    }

    if ($Pipeline.RuntimeBoundary -eq "admin_only") {
        foreach ($forbiddenSurface in @("standard_runtime", "subproject_runtime")) {
            if ($allowedSurfaces -contains $forbiddenSurface -or $protectedSurfaces -contains $forbiddenSurface) {
                throw "Artifact.scope must not include '$forbiddenSurface' when Artifact.pipeline.runtime_boundary is 'admin_only'."
            }
        }
    }

    return $scope
}

function Validate-WorkObjectRefs {
    param(
        [Parameter(Mandatory = $true)]
        $Artifact,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory
    )

    $refs = Assert-ObjectArray -Value (Get-RequiredProperty -Object $Artifact -Name "work_object_refs" -Context "Artifact") -Context "Artifact.work_object_refs" -AllowEmpty
    if ($refs.Count -lt [int]$Contract.minimum_work_object_refs) {
        throw "Artifact.work_object_refs must include at least $($Contract.minimum_work_object_refs) item(s) for artifact type '$($Contract.artifact_type)'."
    }

    foreach ($refItem in $refs) {
        foreach ($fieldName in $Foundation.work_object_ref_required_fields) {
            Get-RequiredProperty -Object $refItem -Name $fieldName -Context "Artifact.work_object_refs item" | Out-Null
        }

        $relation = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $refItem -Name "relation" -Context "Artifact.work_object_refs item") -Context "Artifact.work_object_refs item.relation"
        Assert-AllowedValue -Value $relation -AllowedValues @($Foundation.allowed_reference_relations) -Context "Artifact.work_object_refs item.relation"
        Assert-AllowedValue -Value $relation -AllowedValues @($Contract.allowed_work_object_relations) -Context "Artifact.work_object_refs item.relation"

        $objectType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $refItem -Name "object_type" -Context "Artifact.work_object_refs item") -Context "Artifact.work_object_refs item.object_type"
        Assert-AllowedValue -Value $objectType -AllowedValues @($Foundation.allowed_work_object_types) -Context "Artifact.work_object_refs item.object_type"
        Assert-AllowedValue -Value $objectType -AllowedValues @($Contract.allowed_work_object_types) -Context "Artifact.work_object_refs item.object_type"

        $objectId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $refItem -Name "object_id" -Context "Artifact.work_object_refs item") -Context "Artifact.work_object_refs item.object_id"
        Assert-RegexMatch -Value $objectId -Pattern $Foundation.identifier_pattern -Context "Artifact.work_object_refs item.object_id"

        $reference = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $refItem -Name "ref" -Context "Artifact.work_object_refs item") -Context "Artifact.work_object_refs item.ref"
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $refItem -Name "notes" -Context "Artifact.work_object_refs item") -Context "Artifact.work_object_refs item.notes" | Out-Null

        $resolvedPath = Resolve-ReferencePath -BaseDirectory $BaseDirectory -Reference $reference
        $validation = Test-GovernedWorkObjectContract -WorkObjectPath $resolvedPath
        if ($validation.ObjectType -ne $objectType) {
            throw "Artifact.work_object_refs item.object_type must match the referenced governed work object."
        }
        if ($validation.ObjectId -ne $objectId) {
            throw "Artifact.work_object_refs item.object_id must match the referenced governed work object."
        }
    }
}

function Validate-PlanningRecordRefs {
    param(
        [Parameter(Mandatory = $true)]
        $Artifact,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory
    )

    $refs = Assert-ObjectArray -Value (Get-RequiredProperty -Object $Artifact -Name "planning_record_refs" -Context "Artifact") -Context "Artifact.planning_record_refs" -AllowEmpty
    if ($refs.Count -lt [int]$Contract.minimum_planning_record_refs) {
        throw "Artifact.planning_record_refs must include at least $($Contract.minimum_planning_record_refs) item(s) for artifact type '$($Contract.artifact_type)'."
    }

    foreach ($refItem in $refs) {
        foreach ($fieldName in $Foundation.planning_record_ref_required_fields) {
            Get-RequiredProperty -Object $refItem -Name $fieldName -Context "Artifact.planning_record_refs item" | Out-Null
        }

        $relation = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $refItem -Name "relation" -Context "Artifact.planning_record_refs item") -Context "Artifact.planning_record_refs item.relation"
        Assert-AllowedValue -Value $relation -AllowedValues @($Foundation.allowed_reference_relations) -Context "Artifact.planning_record_refs item.relation"
        Assert-AllowedValue -Value $relation -AllowedValues @($Contract.allowed_planning_record_relations) -Context "Artifact.planning_record_refs item.relation"

        $planningRecordId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $refItem -Name "planning_record_id" -Context "Artifact.planning_record_refs item") -Context "Artifact.planning_record_refs item.planning_record_id"
        Assert-RegexMatch -Value $planningRecordId -Pattern $Foundation.identifier_pattern -Context "Artifact.planning_record_refs item.planning_record_id"

        $objectType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $refItem -Name "object_type" -Context "Artifact.planning_record_refs item") -Context "Artifact.planning_record_refs item.object_type"
        Assert-AllowedValue -Value $objectType -AllowedValues @($Foundation.allowed_work_object_types) -Context "Artifact.planning_record_refs item.object_type"

        $objectId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $refItem -Name "object_id" -Context "Artifact.planning_record_refs item") -Context "Artifact.planning_record_refs item.object_id"
        Assert-RegexMatch -Value $objectId -Pattern $Foundation.identifier_pattern -Context "Artifact.planning_record_refs item.object_id"

        $view = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $refItem -Name "view" -Context "Artifact.planning_record_refs item") -Context "Artifact.planning_record_refs item.view"
        Assert-AllowedValue -Value $view -AllowedValues @($Foundation.allowed_planning_record_views) -Context "Artifact.planning_record_refs item.view"
        Assert-AllowedValue -Value $view -AllowedValues @($Contract.allowed_planning_record_views) -Context "Artifact.planning_record_refs item.view"

        $reference = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $refItem -Name "ref" -Context "Artifact.planning_record_refs item") -Context "Artifact.planning_record_refs item.ref"
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $refItem -Name "notes" -Context "Artifact.planning_record_refs item") -Context "Artifact.planning_record_refs item.notes" | Out-Null

        $resolvedPath = Resolve-ReferencePath -BaseDirectory $BaseDirectory -Reference $reference
        $validation = Test-PlanningRecordContract -PlanningRecordPath $resolvedPath
        if ($validation.PlanningRecordId -ne $planningRecordId) {
            throw "Artifact.planning_record_refs item.planning_record_id must match the referenced planning record."
        }
        if ($validation.ObjectType -ne $objectType) {
            throw "Artifact.planning_record_refs item.object_type must match the referenced planning record."
        }
        if ($validation.ObjectId -ne $objectId) {
            throw "Artifact.planning_record_refs item.object_id must match the referenced planning record."
        }
    }
}

function Validate-Evidence {
    param(
        [Parameter(Mandatory = $true)]
        $Artifact,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract
    )

    $evidence = Assert-ObjectArray -Value (Get-RequiredProperty -Object $Artifact -Name "evidence" -Context "Artifact") -Context "Artifact.evidence"
    $evidenceKinds = @()

    foreach ($evidenceItem in $evidence) {
        foreach ($fieldName in $Foundation.evidence_required_fields) {
            Get-RequiredProperty -Object $evidenceItem -Name $fieldName -Context "Artifact.evidence item" | Out-Null
        }

        $kind = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $evidenceItem -Name "kind" -Context "Artifact.evidence item") -Context "Artifact.evidence item.kind"
        Assert-AllowedValue -Value $kind -AllowedValues @($Foundation.allowed_evidence_kinds) -Context "Artifact.evidence item.kind"
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $evidenceItem -Name "ref" -Context "Artifact.evidence item") -Context "Artifact.evidence item.ref" | Out-Null
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $evidenceItem -Name "summary" -Context "Artifact.evidence item") -Context "Artifact.evidence item.summary" | Out-Null
        $evidenceKinds += $kind
    }

    foreach ($requiredKind in @($Contract.required_evidence_kinds)) {
        if ($evidenceKinds -notcontains $requiredKind) {
            throw "Artifact.evidence must include kind '$requiredKind' for artifact type '$($Contract.artifact_type)'."
        }
    }

    return $evidenceKinds
}

function Validate-Audit {
    param(
        [Parameter(Mandatory = $true)]
        $Artifact,
        [Parameter(Mandatory = $true)]
        $Foundation
    )

    $audit = Assert-ObjectValue -Value (Get-RequiredProperty -Object $Artifact -Name "audit" -Context "Artifact") -Context "Artifact.audit"
    foreach ($fieldName in $Foundation.audit_required_fields) {
        Get-RequiredProperty -Object $audit -Name $fieldName -Context "Artifact.audit" | Out-Null
    }

    Assert-StringArray -Value (Get-RequiredProperty -Object $audit -Name "trail_refs" -Context "Artifact.audit") -Context "Artifact.audit.trail_refs" | Out-Null
    $lastReviewedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $audit -Name "last_reviewed_at" -Context "Artifact.audit") -Context "Artifact.audit.last_reviewed_at"
    Assert-RegexMatch -Value $lastReviewedAt -Pattern $Foundation.timestamp_pattern -Context "Artifact.audit.last_reviewed_at"
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $audit -Name "notes" -Context "Artifact.audit") -Context "Artifact.audit.notes" | Out-Null
}

function Validate-SpecificField {
    param(
        [Parameter(Mandatory = $true)]
        $Artifact,
        [Parameter(Mandatory = $true)]
        [string]$FieldName,
        [Parameter(Mandatory = $true)]
        [string]$FieldType,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $fieldValue = Get-RequiredProperty -Object $Artifact -Name $FieldName -Context $Context
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
        "boolean" {
            Assert-BooleanValue -Value $fieldValue -Context "$Context.$FieldName" | Out-Null
        }
        default {
            throw "Unsupported field type '$FieldType' in contract '$Context'."
        }
    }
}

function Validate-SpecificFields {
    param(
        [Parameter(Mandatory = $true)]
        $Artifact,
        [Parameter(Mandatory = $true)]
        $Contract
    )

    foreach ($fieldName in $Contract.required_fields) {
        Get-RequiredProperty -Object $Artifact -Name $fieldName -Context "Artifact" | Out-Null
        Validate-SpecificField -Artifact $Artifact -FieldName $fieldName -FieldType $Contract.field_types.$fieldName -Context "Artifact"
    }

    foreach ($fieldName in @($Contract.optional_fields)) {
        if (Test-HasProperty -Object $Artifact -Name $fieldName) {
            Validate-SpecificField -Artifact $Artifact -FieldName $fieldName -FieldType $Contract.field_types.$fieldName -Context "Artifact"
        }
    }
}

function Test-HasAcceptedPlanningRecordRef {
    param(
        [Parameter(Mandatory = $true)]
        $Artifact
    )

    foreach ($planningRecordRef in @($Artifact.planning_record_refs)) {
        if ($planningRecordRef.view -eq "accepted") {
            return $true
        }
    }

    return $false
}

function Validate-ArtifactSpecificInvariants {
    param(
        [Parameter(Mandatory = $true)]
        $Artifact,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [string[]]$EvidenceKinds,
        [Parameter(Mandatory = $true)]
        $Lineage
    )

    $status = $Artifact.status

    switch ($Contract.artifact_type) {
        "task_packet" {
            if ($status -eq "approved" -and -not (Test-HasAcceptedPlanningRecordRef -Artifact $Artifact)) {
                throw "Approved Task Packets must include at least one accepted planning record ref."
            }
        }
        "execution_bundle" {
            if ($status -eq "prepared" -and $Lineage.source_kind -ne "task_packet") {
                throw "Prepared Execution Bundles must derive from a task_packet lineage source."
            }
        }
        "qa_report" {
            $verdict = Assert-NonEmptyString -Value $Artifact.verdict -Context "Artifact.verdict"
            Assert-AllowedValue -Value $verdict -AllowedValues @($Contract.allowed_verdicts) -Context "Artifact.verdict"
            $remediationRequired = Assert-BooleanValue -Value $Artifact.remediation_required -Context "Artifact.remediation_required"
            $remediationNotes = if (Test-HasProperty -Object $Artifact -Name "remediation_notes") { $Artifact.remediation_notes } else { $null }

            if ($status -eq "passed") {
                if ($verdict -ne "pass") {
                    throw "Passed QA Reports must use verdict 'pass'."
                }
                if ($remediationRequired) {
                    throw "Passed QA Reports must not require remediation."
                }
            }
            if ($status -eq "failed") {
                if ($verdict -ne "fail") {
                    throw "Failed QA Reports must use verdict 'fail'."
                }
                if (-not $remediationRequired) {
                    throw "Failed QA Reports must require remediation."
                }
                Assert-NonEmptyString -Value $remediationNotes -Context "Artifact.remediation_notes" | Out-Null
            }
            if ($status -eq "blocked" -and $verdict -ne "blocked") {
                throw "Blocked QA Reports must use verdict 'blocked'."
            }
        }
        "external_audit_pack" {
            if ($status -eq "ready_for_audit") {
                if ($EvidenceKinds -notcontains "qa_report") {
                    throw "Ready-for-audit packs must include qa_report evidence."
                }
                if (@($Artifact.included_artifacts).Count -eq 0) {
                    throw "Ready-for-audit packs must include at least one included artifact."
                }
            }
        }
        "baton" {
            if ($status -eq "ready_for_handoff" -and @($Artifact.next_required_artifacts).Count -eq 0) {
                throw "Ready-for-handoff batons must include at least one next_required_artifact."
            }
            if ($status -eq "closed" -and @($Artifact.next_required_artifacts).Count -gt 0) {
                throw "Closed batons must not retain next_required_artifacts."
            }
        }
    }
}

function Test-WorkArtifactContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArtifactPath
    )

    $resolvedArtifactPath = Resolve-ArtifactPath -ArtifactPath $ArtifactPath
    $artifact = Get-JsonDocument -Path $resolvedArtifactPath -Label "Work artifact"
    $foundation = Get-ArtifactFoundationContract
    $artifactType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $artifact -Name "artifact_type" -Context "Artifact") -Context "Artifact.artifact_type"
    $contract = Get-ArtifactSpecificContract -ArtifactType $artifactType
    $baseDirectory = Split-Path -Parent $resolvedArtifactPath

    Validate-CommonFields -Artifact $artifact -Foundation $foundation -Contract $contract
    $lineage = Validate-Lineage -Artifact $artifact -Foundation $foundation -Contract $contract
    $pipeline = Validate-Pipeline -Artifact $artifact -Foundation $foundation -Contract $contract
    Validate-Scope -Artifact $artifact -Foundation $foundation -Contract $contract -Pipeline $pipeline | Out-Null
    Validate-SpecificFields -Artifact $artifact -Contract $contract
    Validate-WorkObjectRefs -Artifact $artifact -Foundation $foundation -Contract $contract -BaseDirectory $baseDirectory
    Validate-PlanningRecordRefs -Artifact $artifact -Foundation $foundation -Contract $contract -BaseDirectory $baseDirectory
    $evidenceKinds = Validate-Evidence -Artifact $artifact -Foundation $foundation -Contract $contract
    Validate-Audit -Artifact $artifact -Foundation $foundation
    Validate-ArtifactSpecificInvariants -Artifact $artifact -Contract $contract -EvidenceKinds $evidenceKinds -Lineage $lineage

    return [pscustomobject]@{
        IsValid         = $true
        ArtifactType    = $artifactType
        ArtifactId      = $artifact.artifact_id
        ArtifactPath    = $resolvedArtifactPath
        ContractPath    = Join-Path (Get-RepositoryRoot) ("contracts\work_artifacts\{0}.contract.json" -f $artifactType)
        FoundationPath  = Join-Path (Get-RepositoryRoot) "contracts\work_artifacts\foundation.contract.json"
    }
}

Export-ModuleMember -Function Test-WorkArtifactContract
