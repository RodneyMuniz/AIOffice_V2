Set-StrictMode -Version Latest

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
        [string]$Context
    )

    if ($null -eq $Value -or $Value -is [string] -or -not ($Value -is [System.Collections.IEnumerable])) {
        throw "$Context must be an array."
    }

    $items = @($Value)
    if ($items.Count -eq 0) {
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
        [string]$Context
    )

    if ($null -eq $Value -or $Value -is [string] -or -not ($Value -is [System.Collections.IEnumerable])) {
        throw "$Context must be an array."
    }

    $items = @($Value)
    if ($items.Count -eq 0) {
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

function Validate-CommonArtifactFields {
    param(
        [Parameter(Mandatory = $true)]
        $Artifact,
        [Parameter(Mandatory = $true)]
        $Foundation
    )

    foreach ($fieldName in $Foundation.common_required_fields) {
        Get-RequiredProperty -Object $Artifact -Name $fieldName -Context "Artifact" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "contract_version" -Context "Artifact") -Context "Artifact.contract_version"
    if ($contractVersion -ne $Foundation.contract_version) {
        throw "Artifact.contract_version must equal '$($Foundation.contract_version)'."
    }

    $artifactType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "artifact_type" -Context "Artifact") -Context "Artifact.artifact_type"
    if ($artifactType -ne $Foundation.artifact_type) {
        throw "Artifact.artifact_type must equal '$($Foundation.artifact_type)'."
    }

    $artifactId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "artifact_id" -Context "Artifact") -Context "Artifact.artifact_id"
    Assert-RegexMatch -Value $artifactId -Pattern $Foundation.identifier_pattern -Context "Artifact.artifact_id"

    $packetId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "packet_id" -Context "Artifact") -Context "Artifact.packet_id"
    Assert-RegexMatch -Value $packetId -Pattern $Foundation.identifier_pattern -Context "Artifact.packet_id"

    $stage = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "stage" -Context "Artifact") -Context "Artifact.stage"
    Assert-AllowedValue -Value $stage -AllowedValues @($Foundation.allowed_stages) -Context "Artifact.stage"

    $createdAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "created_at" -Context "Artifact") -Context "Artifact.created_at"
    Assert-RegexMatch -Value $createdAt -Pattern $Foundation.timestamp_pattern -Context "Artifact.created_at"

    $createdBy = Assert-ObjectValue -Value (Get-RequiredProperty -Object $Artifact -Name "created_by" -Context "Artifact") -Context "Artifact.created_by"
    foreach ($fieldName in $Foundation.created_by_required_fields) {
        Get-RequiredProperty -Object $createdBy -Name $fieldName -Context "Artifact.created_by" | Out-Null
    }
    $actorRole = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $createdBy -Name "role" -Context "Artifact.created_by") -Context "Artifact.created_by.role"
    Assert-AllowedValue -Value $actorRole -AllowedValues @($Foundation.allowed_actor_roles) -Context "Artifact.created_by.role"
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $createdBy -Name "id" -Context "Artifact.created_by") -Context "Artifact.created_by.id" | Out-Null

    $scope = Assert-ObjectValue -Value (Get-RequiredProperty -Object $Artifact -Name "scope" -Context "Artifact") -Context "Artifact.scope"
    foreach ($fieldName in $Foundation.scope_required_fields) {
        Get-RequiredProperty -Object $scope -Name $fieldName -Context "Artifact.scope" | Out-Null
    }
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $scope -Name "summary" -Context "Artifact.scope") -Context "Artifact.scope.summary" | Out-Null
    Assert-StringArray -Value (Get-RequiredProperty -Object $scope -Name "in_scope" -Context "Artifact.scope") -Context "Artifact.scope.in_scope" | Out-Null
    Assert-StringArray -Value (Get-RequiredProperty -Object $scope -Name "out_of_scope" -Context "Artifact.scope") -Context "Artifact.scope.out_of_scope" | Out-Null

    Assert-StringArray -Value (Get-RequiredProperty -Object $Artifact -Name "assumptions" -Context "Artifact") -Context "Artifact.assumptions" | Out-Null

    $inputs = Assert-ObjectArray -Value (Get-RequiredProperty -Object $Artifact -Name "inputs" -Context "Artifact") -Context "Artifact.inputs"
    foreach ($inputItem in $inputs) {
        foreach ($fieldName in $Foundation.input_required_fields) {
            Get-RequiredProperty -Object $inputItem -Name $fieldName -Context "Artifact.inputs item" | Out-Null
        }
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $inputItem -Name "kind" -Context "Artifact.inputs item") -Context "Artifact.inputs item.kind" | Out-Null
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $inputItem -Name "ref" -Context "Artifact.inputs item") -Context "Artifact.inputs item.ref" | Out-Null
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $inputItem -Name "summary" -Context "Artifact.inputs item") -Context "Artifact.inputs item.summary" | Out-Null
    }

    Assert-ObjectValue -Value (Get-RequiredProperty -Object $Artifact -Name "output" -Context "Artifact") -Context "Artifact.output" | Out-Null

    $risks = Assert-ObjectArray -Value (Get-RequiredProperty -Object $Artifact -Name "risks" -Context "Artifact") -Context "Artifact.risks"
    foreach ($riskItem in $risks) {
        foreach ($fieldName in $Foundation.risk_required_fields) {
            Get-RequiredProperty -Object $riskItem -Name $fieldName -Context "Artifact.risks item" | Out-Null
        }
        $riskLevel = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $riskItem -Name "level" -Context "Artifact.risks item") -Context "Artifact.risks item.level"
        Assert-AllowedValue -Value $riskLevel -AllowedValues @($Foundation.allowed_risk_levels) -Context "Artifact.risks item.level"
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $riskItem -Name "summary" -Context "Artifact.risks item") -Context "Artifact.risks item.summary" | Out-Null
    }

    $handoff = Assert-ObjectValue -Value (Get-RequiredProperty -Object $Artifact -Name "handoff" -Context "Artifact") -Context "Artifact.handoff"
    foreach ($fieldName in $Foundation.handoff_required_fields) {
        Get-RequiredProperty -Object $handoff -Name $fieldName -Context "Artifact.handoff" | Out-Null
    }
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $handoff -Name "next_stage" -Context "Artifact.handoff") -Context "Artifact.handoff.next_stage" | Out-Null

    $packetOut = Assert-ObjectValue -Value (Get-RequiredProperty -Object $handoff -Name "packet_out" -Context "Artifact.handoff") -Context "Artifact.handoff.packet_out"
    foreach ($fieldName in $Foundation.packet_out_required_fields) {
        Get-RequiredProperty -Object $packetOut -Name $fieldName -Context "Artifact.handoff.packet_out" | Out-Null
    }
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $packetOut -Name "summary" -Context "Artifact.handoff.packet_out") -Context "Artifact.handoff.packet_out.summary" | Out-Null
    Assert-StringArray -Value (Get-RequiredProperty -Object $packetOut -Name "artifact_refs" -Context "Artifact.handoff.packet_out") -Context "Artifact.handoff.packet_out.artifact_refs" | Out-Null

    $approval = Assert-ObjectValue -Value (Get-RequiredProperty -Object $Artifact -Name "approval" -Context "Artifact") -Context "Artifact.approval"
    foreach ($fieldName in $Foundation.approval_required_fields) {
        Get-RequiredProperty -Object $approval -Name $fieldName -Context "Artifact.approval" | Out-Null
    }
    $approvalMode = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $approval -Name "mode" -Context "Artifact.approval") -Context "Artifact.approval.mode"
    Assert-AllowedValue -Value $approvalMode -AllowedValues @($Foundation.approval_allowed_modes) -Context "Artifact.approval.mode"
    $approvalStatus = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $approval -Name "status" -Context "Artifact.approval") -Context "Artifact.approval.status"
    Assert-AllowedValue -Value $approvalStatus -AllowedValues @($Foundation.approval_allowed_statuses) -Context "Artifact.approval.status"
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $approval -Name "notes" -Context "Artifact.approval") -Context "Artifact.approval.notes" | Out-Null

    $approvalBy = Get-RequiredProperty -Object $approval -Name "by" -Context "Artifact.approval"
    $approvalAt = Get-RequiredProperty -Object $approval -Name "at" -Context "Artifact.approval"

    if ($approvalMode -eq "not_required") {
        if ($approvalStatus -ne "not_required") {
            throw "Artifact.approval.status must be 'not_required' when Artifact.approval.mode is 'not_required'."
        }
        if ($null -ne $approvalBy -or $null -ne $approvalAt) {
            throw "Artifact.approval.by and Artifact.approval.at must be null when approval is not required."
        }
    }
    elseif ($approvalStatus -eq "pending") {
        if ($null -ne $approvalBy -or $null -ne $approvalAt) {
            throw "Artifact.approval.by and Artifact.approval.at must be null while approval status is pending."
        }
    }
    else {
        Assert-NonEmptyString -Value $approvalBy -Context "Artifact.approval.by" | Out-Null
        $approvalAtValue = Assert-NonEmptyString -Value $approvalAt -Context "Artifact.approval.at"
        Assert-RegexMatch -Value $approvalAtValue -Pattern $Foundation.timestamp_pattern -Context "Artifact.approval.at"
    }
}

function Validate-StageSpecificFields {
    param(
        [Parameter(Mandatory = $true)]
        $Artifact,
        [Parameter(Mandatory = $true)]
        $StageContract
    )

    $stage = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "stage" -Context "Artifact") -Context "Artifact.stage"
    if ($stage -ne $StageContract.stage) {
        throw "Artifact.stage '$stage' does not match stage contract '$($StageContract.stage)'."
    }

    $handoff = Get-RequiredProperty -Object $Artifact -Name "handoff" -Context "Artifact"
    $nextStage = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $handoff -Name "next_stage" -Context "Artifact.handoff") -Context "Artifact.handoff.next_stage"
    Assert-AllowedValue -Value $nextStage -AllowedValues @($StageContract.allowed_next_stages) -Context "Artifact.handoff.next_stage"

    $approval = Get-RequiredProperty -Object $Artifact -Name "approval" -Context "Artifact"
    $approvalMode = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $approval -Name "mode" -Context "Artifact.approval") -Context "Artifact.approval.mode"
    $approvalStatus = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $approval -Name "status" -Context "Artifact.approval") -Context "Artifact.approval.status"

    if ($approvalMode -ne $StageContract.approval.required_mode) {
        throw "Artifact.approval.mode must equal '$($StageContract.approval.required_mode)' for stage '$stage'."
    }
    Assert-AllowedValue -Value $approvalStatus -AllowedValues @($StageContract.approval.allowed_statuses) -Context "Artifact.approval.status"

    $output = Assert-ObjectValue -Value (Get-RequiredProperty -Object $Artifact -Name "output" -Context "Artifact") -Context "Artifact.output"
    foreach ($fieldName in $StageContract.required_output_fields) {
        Get-RequiredProperty -Object $output -Name $fieldName -Context "Artifact.output" | Out-Null
        $fieldType = $StageContract.output_field_types.$fieldName
        $fieldValue = Get-RequiredProperty -Object $output -Name $fieldName -Context "Artifact.output"

        switch ($fieldType) {
            "string" {
                Assert-NonEmptyString -Value $fieldValue -Context "Artifact.output.$fieldName" | Out-Null
            }
            "string_array" {
                Assert-StringArray -Value $fieldValue -Context "Artifact.output.$fieldName" | Out-Null
            }
            default {
                throw "Unsupported output field type '$fieldType' in stage contract '$stage'."
            }
        }
    }
}

function Test-StageArtifactContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArtifactPath
    )

    $repoRoot = Get-RepositoryRoot
    $resolvedArtifactPath = Resolve-ArtifactPath -ArtifactPath $ArtifactPath
    $foundationPath = Join-Path $repoRoot "contracts\stage_artifacts\foundation.contract.json"
    $foundation = Get-JsonDocument -Path $foundationPath -Label "Foundation contract"
    $artifact = Get-JsonDocument -Path $resolvedArtifactPath -Label "Artifact"

    $stage = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $artifact -Name "stage" -Context "Artifact") -Context "Artifact.stage"
    $stageContractPath = Join-Path $repoRoot ("contracts\stage_artifacts\{0}.contract.json" -f $stage)
    if (-not (Test-Path -LiteralPath $stageContractPath)) {
        throw "No stage contract exists for stage '$stage'."
    }
    $stageContract = Get-JsonDocument -Path $stageContractPath -Label "Stage contract"

    Validate-CommonArtifactFields -Artifact $artifact -Foundation $foundation
    Validate-StageSpecificFields -Artifact $artifact -StageContract $stageContract

    return [pscustomobject]@{
        IsValid               = $true
        Stage                 = $stage
        ArtifactPath          = $resolvedArtifactPath
        StageContractPath     = $stageContractPath
        FoundationContractPath = $foundationPath
    }
}

Export-ModuleMember -Function Test-StageArtifactContract
