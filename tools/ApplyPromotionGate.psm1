Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "StageArtifactValidation.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "PacketRecordStorage.psm1") -Force

function Get-RepositoryRoot {
    return $repoRoot
}

function Resolve-OptionalPath {
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

    $resolvedPath = Resolve-OptionalPath -PathValue $PathValue
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

function Get-UtcTimestamp {
    param(
        [datetime]$Value = (Get-Date).ToUniversalTime()
    )

    return $Value.ToString("yyyy-MM-ddTHH:mm:ssZ")
}

function Convert-BlankStringToNull {
    param(
        [AllowNull()]
        [string]$Value
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $null
    }

    return $Value
}

function Get-GateFoundationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\apply_promotion\foundation.contract.json") -Label "Apply/promotion gate foundation contract"
}

function Get-GateRequestContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\apply_promotion\gate_request.contract.json") -Label "Apply/promotion gate request contract"
}

function Get-GateResultContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\apply_promotion\gate_result.contract.json") -Label "Apply/promotion gate result contract"
}

function Get-GateResultStorePath {
    param(
        [string]$StorePath
    )

    if ([string]::IsNullOrWhiteSpace($StorePath)) {
        return Join-Path (Get-RepositoryRoot) "state\gate_results"
    }

    return (Resolve-OptionalPath -PathValue $StorePath)
}

function Validate-GateRequestApproval {
    param(
        [Parameter(Mandatory = $true)]
        $Approval,
        [Parameter(Mandatory = $true)]
        $Foundation
    )

    foreach ($fieldName in $Foundation.request_approval_required_fields) {
        Get-RequiredProperty -Object $Approval -Name $fieldName -Context "GateRequest.approval" | Out-Null
    }

    $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Approval -Name "status" -Context "GateRequest.approval") -Context "GateRequest.approval.status"
    Assert-AllowedValue -Value $status -AllowedValues @($Foundation.allowed_approval_statuses) -Context "GateRequest.approval.status"

    $by = Get-RequiredProperty -Object $Approval -Name "by" -Context "GateRequest.approval"
    $at = Get-RequiredProperty -Object $Approval -Name "at" -Context "GateRequest.approval"
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Approval -Name "notes" -Context "GateRequest.approval") -Context "GateRequest.approval.notes" | Out-Null

    if ($status -eq "pending") {
        if ($null -ne $by -or $null -ne $at) {
            throw "GateRequest.approval.by and GateRequest.approval.at must be null while approval is pending."
        }
    }
    else {
        Assert-NonEmptyString -Value $by -Context "GateRequest.approval.by" | Out-Null
        $atValue = Assert-NonEmptyString -Value $at -Context "GateRequest.approval.at"
        Assert-RegexMatch -Value $atValue -Pattern $Foundation.timestamp_pattern -Context "GateRequest.approval.at"
    }
}

function Validate-GateRequestScope {
    param(
        [Parameter(Mandatory = $true)]
        $Scope,
        [Parameter(Mandatory = $true)]
        $Foundation
    )

    foreach ($fieldName in $Foundation.request_scope_required_fields) {
        Get-RequiredProperty -Object $Scope -Name $fieldName -Context "GateRequest.scope" | Out-Null
    }

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Scope -Name "summary" -Context "GateRequest.scope") -Context "GateRequest.scope.summary" | Out-Null
    Assert-StringArray -Value (Get-RequiredProperty -Object $Scope -Name "allowed_paths" -Context "GateRequest.scope") -Context "GateRequest.scope.allowed_paths" -AllowEmpty | Out-Null
    Assert-StringArray -Value (Get-RequiredProperty -Object $Scope -Name "prohibited_paths" -Context "GateRequest.scope") -Context "GateRequest.scope.prohibited_paths" -AllowEmpty | Out-Null
}

function Validate-GateRequestFields {
    param(
        [Parameter(Mandatory = $true)]
        $GateRequest
    )

    $foundation = Get-GateFoundationContract
    $requestContract = Get-GateRequestContract

    foreach ($fieldName in $foundation.request_required_fields) {
        Get-RequiredProperty -Object $GateRequest -Name $fieldName -Context "GateRequest" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $GateRequest -Name "contract_version" -Context "GateRequest") -Context "GateRequest.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "GateRequest.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $GateRequest -Name "record_type" -Context "GateRequest") -Context "GateRequest.record_type"
    if ($recordType -ne $foundation.request_record_type -or $recordType -ne $requestContract.record_type) {
        throw "GateRequest.record_type must equal '$($foundation.request_record_type)'."
    }

    $gateRequestId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $GateRequest -Name "gate_request_id" -Context "GateRequest") -Context "GateRequest.gate_request_id"
    Assert-RegexMatch -Value $gateRequestId -Pattern $foundation.identifier_pattern -Context "GateRequest.gate_request_id"

    $packetId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $GateRequest -Name "packet_id" -Context "GateRequest") -Context "GateRequest.packet_id"
    Assert-RegexMatch -Value $packetId -Pattern $foundation.identifier_pattern -Context "GateRequest.packet_id"

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $GateRequest -Name "packet_record_ref" -Context "GateRequest") -Context "GateRequest.packet_record_ref" | Out-Null

    $requestedAction = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $GateRequest -Name "requested_action" -Context "GateRequest") -Context "GateRequest.requested_action"
    Assert-AllowedValue -Value $requestedAction -AllowedValues @($foundation.allowed_requested_actions) -Context "GateRequest.requested_action"

    $requestedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $GateRequest -Name "requested_at" -Context "GateRequest") -Context "GateRequest.requested_at"
    Assert-RegexMatch -Value $requestedAt -Pattern $foundation.timestamp_pattern -Context "GateRequest.requested_at"

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $GateRequest -Name "requested_by" -Context "GateRequest") -Context "GateRequest.requested_by" | Out-Null

    $approval = Assert-ObjectValue -Value (Get-RequiredProperty -Object $GateRequest -Name "approval" -Context "GateRequest") -Context "GateRequest.approval"
    Validate-GateRequestApproval -Approval $approval -Foundation $foundation

    $scope = Assert-ObjectValue -Value (Get-RequiredProperty -Object $GateRequest -Name "scope" -Context "GateRequest") -Context "GateRequest.scope"
    Validate-GateRequestScope -Scope $scope -Foundation $foundation

    Assert-StringArray -Value (Get-RequiredProperty -Object $GateRequest -Name "approved_artifact_refs" -Context "GateRequest") -Context "GateRequest.approved_artifact_refs" -AllowEmpty | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $GateRequest -Name "notes" -Context "GateRequest") -Context "GateRequest.notes" | Out-Null

    return [pscustomobject]@{
        IsValid       = $true
        GateRequestId = $gateRequestId
        PacketId      = $packetId
        RequestedAction = $requestedAction
    }
}

function Validate-GateResultFields {
    param(
        [Parameter(Mandatory = $true)]
        $GateResult
    )

    $foundation = Get-GateFoundationContract
    $resultContract = Get-GateResultContract

    foreach ($fieldName in $foundation.result_required_fields) {
        Get-RequiredProperty -Object $GateResult -Name $fieldName -Context "GateResult" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $GateResult -Name "contract_version" -Context "GateResult") -Context "GateResult.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "GateResult.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $GateResult -Name "record_type" -Context "GateResult") -Context "GateResult.record_type"
    if ($recordType -ne $foundation.result_record_type -or $recordType -ne $resultContract.record_type) {
        throw "GateResult.record_type must equal '$($foundation.result_record_type)'."
    }

    $gateResultId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $GateResult -Name "gate_result_id" -Context "GateResult") -Context "GateResult.gate_result_id"
    Assert-RegexMatch -Value $gateResultId -Pattern $foundation.identifier_pattern -Context "GateResult.gate_result_id"

    $gateRequestId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $GateResult -Name "gate_request_id" -Context "GateResult") -Context "GateResult.gate_request_id"
    Assert-RegexMatch -Value $gateRequestId -Pattern $foundation.identifier_pattern -Context "GateResult.gate_request_id"

    $packetId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $GateResult -Name "packet_id" -Context "GateResult") -Context "GateResult.packet_id"
    Assert-RegexMatch -Value $packetId -Pattern $foundation.identifier_pattern -Context "GateResult.packet_id"

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $GateResult -Name "packet_record_ref" -Context "GateResult") -Context "GateResult.packet_record_ref" | Out-Null

    $requestedAction = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $GateResult -Name "requested_action" -Context "GateResult") -Context "GateResult.requested_action"
    Assert-AllowedValue -Value $requestedAction -AllowedValues @($foundation.allowed_requested_actions) -Context "GateResult.requested_action"

    $decidedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $GateResult -Name "decided_at" -Context "GateResult") -Context "GateResult.decided_at"
    Assert-RegexMatch -Value $decidedAt -Pattern $foundation.timestamp_pattern -Context "GateResult.decided_at"

    $decision = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $GateResult -Name "decision" -Context "GateResult") -Context "GateResult.decision"
    Assert-AllowedValue -Value $decision -AllowedValues @($foundation.allowed_decisions) -Context "GateResult.decision"

    $preconditions = Assert-ObjectValue -Value (Get-RequiredProperty -Object $GateResult -Name "preconditions" -Context "GateResult") -Context "GateResult.preconditions"
    foreach ($fieldName in $foundation.result_precondition_required_fields) {
        $fieldValue = Get-RequiredProperty -Object $preconditions -Name $fieldName -Context "GateResult.preconditions"
        if ($fieldValue -isnot [bool]) {
            throw "GateResult.preconditions.$fieldName must be a boolean."
        }
    }

    $scope = Assert-ObjectValue -Value (Get-RequiredProperty -Object $GateResult -Name "scope" -Context "GateResult") -Context "GateResult.scope"
    Validate-GateRequestScope -Scope $scope -Foundation $foundation

    Assert-StringArray -Value (Get-RequiredProperty -Object $GateResult -Name "approved_artifact_refs" -Context "GateResult") -Context "GateResult.approved_artifact_refs" -AllowEmpty | Out-Null

    $blockReasons = Assert-ObjectArray -Value (Get-RequiredProperty -Object $GateResult -Name "block_reasons" -Context "GateResult") -Context "GateResult.block_reasons" -AllowEmpty
    foreach ($reason in $blockReasons) {
        foreach ($fieldName in $foundation.block_reason_required_fields) {
            Get-RequiredProperty -Object $reason -Name $fieldName -Context "GateResult.block_reasons item" | Out-Null
        }

        $code = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $reason -Name "code" -Context "GateResult.block_reasons item") -Context "GateResult.block_reasons item.code"
        Assert-AllowedValue -Value $code -AllowedValues @($foundation.allowed_reason_codes) -Context "GateResult.block_reasons item.code"
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $reason -Name "summary" -Context "GateResult.block_reasons item") -Context "GateResult.block_reasons item.summary" | Out-Null
    }

    $blockedStateRecord = Assert-ObjectValue -Value (Get-RequiredProperty -Object $GateResult -Name "blocked_state_record" -Context "GateResult") -Context "GateResult.blocked_state_record"
    foreach ($fieldName in $foundation.blocked_state_record_required_fields) {
        Get-RequiredProperty -Object $blockedStateRecord -Name $fieldName -Context "GateResult.blocked_state_record" | Out-Null
    }

    $recorded = Get-RequiredProperty -Object $blockedStateRecord -Name "recorded" -Context "GateResult.blocked_state_record"
    if ($recorded -isnot [bool]) {
        throw "GateResult.blocked_state_record.recorded must be a boolean."
    }

    $recordedPacketRef = Get-RequiredProperty -Object $blockedStateRecord -Name "packet_record_ref" -Context "GateResult.blocked_state_record"
    $recordedPacketRefValue = Assert-NullableString -Value $recordedPacketRef -Context "GateResult.blocked_state_record.packet_record_ref"
    $recordedAt = Get-RequiredProperty -Object $blockedStateRecord -Name "recorded_at" -Context "GateResult.blocked_state_record"
    $recordedAtValue = Assert-NullableString -Value $recordedAt -Context "GateResult.blocked_state_record.recorded_at"
    if ($null -ne $recordedAtValue) {
        Assert-RegexMatch -Value $recordedAtValue -Pattern $foundation.timestamp_pattern -Context "GateResult.blocked_state_record.recorded_at"
    }
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $blockedStateRecord -Name "notes" -Context "GateResult.blocked_state_record") -Context "GateResult.blocked_state_record.notes" | Out-Null

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $GateResult -Name "notes" -Context "GateResult") -Context "GateResult.notes" | Out-Null

    if ($decision -eq "allow") {
        if ($blockReasons.Count -ne 0) {
            throw "GateResult with decision 'allow' must not contain block reasons."
        }
        if ($recorded) {
            throw "GateResult with decision 'allow' must not record blocked state."
        }
    }
    else {
        if ($blockReasons.Count -eq 0) {
            throw "GateResult with decision 'blocked' must contain at least one block reason."
        }
    }

    if ($recorded -and ($null -eq $recordedPacketRefValue -or $null -eq $recordedAtValue)) {
        throw "GateResult.blocked_state_record requires packet_record_ref and recorded_at when recorded is true."
    }

    return [pscustomobject]@{
        IsValid      = $true
        GateResultId = $gateResultId
        Decision     = $decision
    }
}

function New-BlockReason {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Code,
        [Parameter(Mandatory = $true)]
        [string]$Summary
    )

    return [pscustomobject]@{
        code    = $Code
        summary = $Summary
    }
}

function Test-ScopePathBounded {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [pscustomobject]@{ IsBounded = $false; Code = "scope_unbounded"; Summary = "Scope path '$PathValue' must be relative." }
    }

    if ($PathValue -match "[\*\?\[\]]") {
        return [pscustomobject]@{ IsBounded = $false; Code = "scope_ambiguous"; Summary = "Scope path '$PathValue' contains wildcard characters." }
    }

    $normalized = $PathValue.Replace("/", "\")
    if ($normalized -eq "." -or $normalized -eq ".\" -or $normalized -eq "\" -or $normalized -eq "") {
        return [pscustomobject]@{ IsBounded = $false; Code = "scope_unbounded"; Summary = "Scope path '$PathValue' is not specific enough." }
    }

    foreach ($segment in ($normalized -split "\\")) {
        if ($segment -eq "..") {
            return [pscustomobject]@{ IsBounded = $false; Code = "scope_unbounded"; Summary = "Scope path '$PathValue' contains parent traversal." }
        }
    }

    return [pscustomobject]@{ IsBounded = $true; Code = $null; Summary = $null }
}

function Add-UniqueBlockReason {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.ArrayList]$Reasons,
        [Parameter(Mandatory = $true)]
        [string]$Code,
        [Parameter(Mandatory = $true)]
        [string]$Summary
    )

    $existing = @($Reasons | Where-Object { $_.code -eq $Code -and $_.summary -eq $Summary })
    if ($existing.Count -eq 0) {
        [void]$Reasons.Add((New-BlockReason -Code $Code -Summary $Summary))
    }
}

function Evaluate-ApprovalPreconditions {
    param(
        [Parameter(Mandatory = $true)]
        $GateRequest,
        [Parameter(Mandatory = $true)]
        $PacketRecord,
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.ArrayList]$Reasons
    )

    $satisfied = $true
    if ($GateRequest.approval.status -eq "rejected") {
        Add-UniqueBlockReason -Reasons $Reasons -Code "approval_rejected" -Summary "Gate request approval is rejected."
        $satisfied = $false
    }
    elseif ($GateRequest.approval.status -ne "approved") {
        Add-UniqueBlockReason -Reasons $Reasons -Code "approval_missing" -Summary "Gate request approval is not explicitly approved."
        $satisfied = $false
    }

    if ($PacketRecord.approval_state.status -eq "rejected") {
        Add-UniqueBlockReason -Reasons $Reasons -Code "approval_rejected" -Summary "Packet approval state is rejected."
        $satisfied = $false
    }
    elseif ($PacketRecord.approval_state.status -ne "approved") {
        Add-UniqueBlockReason -Reasons $Reasons -Code "approval_missing" -Summary "Packet approval state is not explicitly approved."
        $satisfied = $false
    }

    return $satisfied
}

function Evaluate-ScopePreconditions {
    param(
        [Parameter(Mandatory = $true)]
        $GateRequest,
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.ArrayList]$Reasons
    )

    $satisfied = $true
    $allowedPaths = @($GateRequest.scope.allowed_paths)
    if ($allowedPaths.Count -eq 0) {
        Add-UniqueBlockReason -Reasons $Reasons -Code "scope_missing" -Summary "Gate request does not define any allowed_paths."
        $satisfied = $false
    }

    foreach ($pathValue in @($GateRequest.scope.allowed_paths) + @($GateRequest.scope.prohibited_paths)) {
        $pathCheck = Test-ScopePathBounded -PathValue $pathValue
        if (-not $pathCheck.IsBounded) {
            Add-UniqueBlockReason -Reasons $Reasons -Code $pathCheck.Code -Summary $pathCheck.Summary
            $satisfied = $false
        }
    }

    foreach ($pathValue in @($GateRequest.scope.allowed_paths)) {
        if (@($GateRequest.scope.prohibited_paths) -contains $pathValue) {
            Add-UniqueBlockReason -Reasons $Reasons -Code "scope_ambiguous" -Summary "Scope path '$pathValue' appears in both allowed_paths and prohibited_paths."
            $satisfied = $false
        }
    }

    return $satisfied
}

function Evaluate-ArtifactLinkagePreconditions {
    param(
        [Parameter(Mandatory = $true)]
        $GateRequest,
        [Parameter(Mandatory = $true)]
        $PacketRecord,
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.ArrayList]$Reasons
    )

    $satisfied = $true
    $acceptedRefs = @($PacketRecord.accepted_state.artifact_refs)
    $acceptedViewRefs = @($PacketRecord.artifact_refs | Where-Object { $_.view -eq "accepted" } | Select-Object -ExpandProperty ref)
    $architectApprovedFound = $false

    if ($PacketRecord.accepted_state.status -ne "accepted") {
        Add-UniqueBlockReason -Reasons $Reasons -Code "artifact_linkage_missing" -Summary "Packet accepted state is not in accepted status."
        $satisfied = $false
    }

    $approvedArtifactRefs = @($GateRequest.approved_artifact_refs)
    if ($approvedArtifactRefs.Count -eq 0) {
        Add-UniqueBlockReason -Reasons $Reasons -Code "artifact_linkage_missing" -Summary "Gate request does not identify any approved artifacts."
        $satisfied = $false
    }

    foreach ($artifactRef in $approvedArtifactRefs) {
        $artifactLinked = $true
        if ($acceptedRefs -notcontains $artifactRef) {
            Add-UniqueBlockReason -Reasons $Reasons -Code "artifact_linkage_missing" -Summary "Approved artifact '$artifactRef' is not present in packet accepted_state.artifact_refs."
            $artifactLinked = $false
            $satisfied = $false
        }

        if ($acceptedViewRefs -notcontains $artifactRef) {
            Add-UniqueBlockReason -Reasons $Reasons -Code "artifact_linkage_missing" -Summary "Approved artifact '$artifactRef' is not present in packet accepted-view artifact_refs."
            $artifactLinked = $false
            $satisfied = $false
        }

        try {
            $validatedArtifact = Test-StageArtifactContract -ArtifactPath $artifactRef
            $artifactDocument = Get-JsonDocument -Path $validatedArtifact.ArtifactPath -Label "Approved artifact"
            if ($artifactDocument.approval.status -ne "approved") {
                Add-UniqueBlockReason -Reasons $Reasons -Code "artifact_not_approved" -Summary "Approved artifact '$artifactRef' is not in approved status."
                $artifactLinked = $false
                $satisfied = $false
            }

            if ($artifactDocument.stage -eq "architect" -and $artifactDocument.approval.status -eq "approved") {
                $architectApprovedFound = $true
            }
        }
        catch {
            Add-UniqueBlockReason -Reasons $Reasons -Code "artifact_linkage_missing" -Summary "Approved artifact '$artifactRef' failed validation. $($_.Exception.Message)"
            $artifactLinked = $false
            $satisfied = $false
        }

        if (-not $artifactLinked) {
            $satisfied = $false
        }
    }

    if (-not $architectApprovedFound) {
        Add-UniqueBlockReason -Reasons $Reasons -Code "architect_artifact_missing" -Summary "No approved architect artifact is linked into the gate request."
        $satisfied = $false
    }

    return $satisfied
}

function Evaluate-ReconciliationPreconditions {
    param(
        [Parameter(Mandatory = $true)]
        $PacketRecord,
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.ArrayList]$Reasons
    )

    $satisfied = $true
    $reconciliation = $PacketRecord.reconciliation_state

    if ([string]::IsNullOrWhiteSpace($PacketRecord.git_refs.head_commit) -or [string]::IsNullOrWhiteSpace($PacketRecord.git_refs.accepted_commit)) {
        Add-UniqueBlockReason -Reasons $Reasons -Code "reconciliation_unresolved" -Summary "Packet Git references are incomplete for reconciliation."
        $satisfied = $false
    }

    if ($reconciliation.status -eq "not_started" -or $reconciliation.status -eq "pending" -or $null -eq $reconciliation.compared_at -or $null -eq $reconciliation.working_matches_accepted -or $null -eq $reconciliation.git_head_matches_accepted) {
        Add-UniqueBlockReason -Reasons $Reasons -Code "reconciliation_unresolved" -Summary "Packet reconciliation state is not fully resolved."
        $satisfied = $false
    }
    elseif ($reconciliation.status -ne "matched" -or -not $reconciliation.working_matches_accepted -or -not $reconciliation.git_head_matches_accepted) {
        Add-UniqueBlockReason -Reasons $Reasons -Code "reconciliation_failed" -Summary "Packet reconciliation state does not show a matched working and Git-visible truth surface."
        $satisfied = $false
    }

    return $satisfied
}

function Test-ApplyPromotionGateRequestContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$GateRequestPath
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $GateRequestPath -Label "Gate request path"
    $gateRequest = Get-JsonDocument -Path $resolvedPath -Label "Gate request"
    $result = Validate-GateRequestFields -GateRequest $gateRequest

    return [pscustomobject]@{
        IsValid        = $result.IsValid
        GateRequestId  = $result.GateRequestId
        PacketId       = $result.PacketId
        RequestedAction = $result.RequestedAction
        GateRequestPath = $resolvedPath
    }
}

function Test-ApplyPromotionGateResultContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$GateResultPath
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $GateResultPath -Label "Gate result path"
    $gateResult = Get-JsonDocument -Path $resolvedPath -Label "Gate result"
    $result = Validate-GateResultFields -GateResult $gateResult

    return [pscustomobject]@{
        IsValid       = $result.IsValid
        GateResultId  = $result.GateResultId
        Decision      = $result.Decision
        GateResultPath = $resolvedPath
    }
}

function Invoke-ApplyPromotionGate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$GateRequestPath
    )

    $gateRequestCheck = Test-ApplyPromotionGateRequestContract -GateRequestPath $GateRequestPath
    $gateRequest = Get-JsonDocument -Path $gateRequestCheck.GateRequestPath -Label "Gate request"
    $packetRecordPath = Resolve-ExistingPath -PathValue $gateRequest.packet_record_ref -Label "Packet record path"
    $packetRecord = Get-PacketRecord -Path $packetRecordPath

    if ($packetRecord.packet_id -ne $gateRequest.packet_id) {
        throw "Gate request packet_id '$($gateRequest.packet_id)' does not match packet record '$($packetRecord.packet_id)'."
    }

    $reasons = [System.Collections.ArrayList]::new()
    $approvalSatisfied = Evaluate-ApprovalPreconditions -GateRequest $gateRequest -PacketRecord $packetRecord -Reasons $reasons
    $scopeSatisfied = Evaluate-ScopePreconditions -GateRequest $gateRequest -Reasons $reasons
    $artifactSatisfied = Evaluate-ArtifactLinkagePreconditions -GateRequest $gateRequest -PacketRecord $packetRecord -Reasons $reasons
    $reconciliationSatisfied = Evaluate-ReconciliationPreconditions -PacketRecord $packetRecord -Reasons $reasons

    $decision = if ($reasons.Count -eq 0) { "allow" } else { "blocked" }
    $timestamp = Get-UtcTimestamp
    $gateResultId = "{0}.result" -f $gateRequest.gate_request_id

    $gateResult = [pscustomobject]@{
        contract_version    = (Get-GateFoundationContract).contract_version
        record_type         = (Get-GateFoundationContract).result_record_type
        gate_result_id      = $gateResultId
        gate_request_id     = $gateRequest.gate_request_id
        packet_id           = $gateRequest.packet_id
        packet_record_ref   = $packetRecordPath
        requested_action    = $gateRequest.requested_action
        decided_at          = $timestamp
        decision            = $decision
        preconditions       = [pscustomobject]@{
            approval         = $approvalSatisfied
            scope            = $scopeSatisfied
            artifact_linkage = $artifactSatisfied
            reconciliation   = $reconciliationSatisfied
        }
        scope               = [pscustomobject]@{
            summary         = $gateRequest.scope.summary
            allowed_paths   = @($gateRequest.scope.allowed_paths)
            prohibited_paths = @($gateRequest.scope.prohibited_paths)
        }
        approved_artifact_refs = @($gateRequest.approved_artifact_refs)
        block_reasons       = @($reasons)
        blocked_state_record = [pscustomobject]@{
            recorded        = $false
            packet_record_ref = $null
            recorded_at     = $null
            notes           = "Blocked state has not been recorded yet."
        }
        notes               = if ($decision -eq "allow") { "All apply/promotion gate preconditions are satisfied." } else { "Apply/promotion gate blocked fail-closed." }
    }

    Validate-GateResultFields -GateResult $gateResult | Out-Null
    return $gateResult
}

function Save-ApplyPromotionGateResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $GateResult,
        [string]$StorePath
    )

    Validate-GateResultFields -GateResult $GateResult | Out-Null

    $resultStorePath = Get-GateResultStorePath -StorePath $StorePath
    if (-not (Test-Path -LiteralPath $resultStorePath)) {
        New-Item -ItemType Directory -Path $resultStorePath -Force | Out-Null
    }

    $resultFilePath = Join-Path $resultStorePath ("{0}.json" -f $GateResult.gate_result_id)

    if ($GateResult.decision -eq "blocked") {
        $packetRecordPath = Resolve-ExistingPath -PathValue $GateResult.packet_record_ref -Label "Packet record path"
        $packetStorePath = Split-Path -Parent $packetRecordPath
        $packetRecord = Get-PacketRecord -Path $packetRecordPath
        $reasonCodes = @($GateResult.block_reasons | Select-Object -ExpandProperty code) -join ", "
        $existingNotes = $packetRecord.working_state.notes
        $packetRecord.working_state.status = "blocked"
        $packetRecord.working_state.last_local_update_at = $GateResult.decided_at
        $packetRecord.working_state.notes = "{0} | Gate blocked by {1}; reasons: {2}; result: {3}" -f $existingNotes, $GateResult.gate_result_id, $reasonCodes, $resultFilePath
        $packetRecord.updated_at = $GateResult.decided_at
        $savedPacketPath = Save-PacketRecord -PacketRecord $packetRecord -StorePath $packetStorePath

        $GateResult.blocked_state_record.recorded = $true
        $GateResult.blocked_state_record.packet_record_ref = $savedPacketPath
        $GateResult.blocked_state_record.recorded_at = $GateResult.decided_at
        $GateResult.blocked_state_record.notes = "Blocked gate outcome recorded back into persisted packet state."
    }
    else {
        $GateResult.blocked_state_record.recorded = $false
        $GateResult.blocked_state_record.packet_record_ref = $null
        $GateResult.blocked_state_record.recorded_at = $null
        $GateResult.blocked_state_record.notes = "No blocked state recording was required for an allow decision."
    }

    Validate-GateResultFields -GateResult $GateResult | Out-Null
    $GateResult | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $resultFilePath -Encoding UTF8

    return [pscustomobject]@{
        GateResult     = $GateResult
        GateResultPath = $resultFilePath
    }
}

function Get-ApplyPromotionGateResult {
    [CmdletBinding(DefaultParameterSetName = "ByGateResultId")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "ByGateResultId")]
        [string]$GateResultId,
        [Parameter(ParameterSetName = "ByGateResultId")]
        [string]$StorePath,
        [Parameter(Mandatory = $true, ParameterSetName = "ByPath")]
        [string]$Path
    )

    if ($PSCmdlet.ParameterSetName -eq "ByPath") {
        $resolvedPath = Resolve-ExistingPath -PathValue $Path -Label "Gate result path"
    }
    else {
        $resolvedPath = Resolve-ExistingPath -PathValue (Join-Path (Get-GateResultStorePath -StorePath $StorePath) ("{0}.json" -f $GateResultId)) -Label "Gate result path"
    }

    $gateResult = Get-JsonDocument -Path $resolvedPath -Label "Gate result"
    Validate-GateResultFields -GateResult $gateResult | Out-Null
    return $gateResult
}

Export-ModuleMember -Function Test-ApplyPromotionGateRequestContract, Test-ApplyPromotionGateResultContract, Invoke-ApplyPromotionGate, Save-ApplyPromotionGateResult, Get-ApplyPromotionGateResult
