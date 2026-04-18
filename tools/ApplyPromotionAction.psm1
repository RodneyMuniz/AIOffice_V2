Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "StageArtifactValidation.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "PacketRecordStorage.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "ApplyPromotionGate.psm1") -Force

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

function Get-UtcTimestamp {
    param(
        [datetime]$Value = (Get-Date).ToUniversalTime()
    )

    return $Value.ToString("yyyy-MM-ddTHH:mm:ssZ")
}

function Ensure-Directory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Get-ActionFoundationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\apply_promotion\foundation.contract.json") -Label "Apply/promotion action foundation contract"
}

function Get-ActionRequestContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\apply_promotion\action_request.contract.json") -Label "Apply/promotion action request contract"
}

function Get-ActionResultContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\apply_promotion\action_result.contract.json") -Label "Apply/promotion action result contract"
}

function Get-PacketFoundationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\packet_records\foundation.contract.json") -Label "Packet foundation contract"
}

function Get-ActionResultStorePath {
    param(
        [string]$StorePath
    )

    if ([string]::IsNullOrWhiteSpace($StorePath)) {
        return Join-Path (Get-RepositoryRoot) "state\apply_promotion_action_results"
    }

    return (Resolve-OptionalPath -PathValue $StorePath)
}

function Normalize-RelativePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue
    )

    return $PathValue.Replace("/", "\").TrimStart("\")
}

function Get-ComparisonPathValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [switch]$RequireExisting
    )

    $candidatePath = if ([System.IO.Path]::IsPathRooted($PathValue)) {
        $PathValue
    }
    else {
        Join-Path (Get-RepositoryRoot) (Normalize-RelativePath -PathValue $PathValue)
    }

    $fullPath = [System.IO.Path]::GetFullPath($candidatePath)
    if ($RequireExisting -and -not (Test-Path -LiteralPath $fullPath)) {
        throw "Path '$PathValue' does not exist."
    }

    if (Test-Path -LiteralPath $fullPath) {
        return ((Resolve-Path -LiteralPath $fullPath).Path.Replace("/", "\").TrimEnd("\")).ToLowerInvariant()
    }

    return ($fullPath.Replace("/", "\").TrimEnd("\")).ToLowerInvariant()
}

function Test-ScopePathBounded {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [pscustomobject]@{ IsBounded = $false; Summary = "Scope path '$PathValue' must be relative." }
    }

    if ($PathValue -match "[\*\?\[\]]") {
        return [pscustomobject]@{ IsBounded = $false; Summary = "Scope path '$PathValue' contains wildcard characters." }
    }

    $normalized = Normalize-RelativePath -PathValue $PathValue
    if ($normalized -eq "." -or $normalized -eq "" -or $normalized -eq "\") {
        return [pscustomobject]@{ IsBounded = $false; Summary = "Scope path '$PathValue' is not specific enough." }
    }

    foreach ($segment in ($normalized -split "\\")) {
        if ($segment -eq "..") {
            return [pscustomobject]@{ IsBounded = $false; Summary = "Scope path '$PathValue' contains parent traversal." }
        }
    }

    return [pscustomobject]@{ IsBounded = $true; Summary = $null }
}

function Test-RelativePathWithinScope {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TargetRelativePath,
        [Parameter(Mandatory = $true)]
        $Scope
    )

    $normalizedTarget = Normalize-RelativePath -PathValue $TargetRelativePath
    $allowedPaths = @($Scope.allowed_paths | ForEach-Object { Normalize-RelativePath -PathValue $_ })
    $prohibitedPaths = @($Scope.prohibited_paths | ForEach-Object { Normalize-RelativePath -PathValue $_ })

    $isAllowed = $false
    foreach ($allowedPath in $allowedPaths) {
        if ($normalizedTarget -eq $allowedPath -or $normalizedTarget.StartsWith("$allowedPath\")) {
            $isAllowed = $true
            break
        }
    }

    if (-not $isAllowed) {
        return [pscustomobject]@{
            IsAllowed = $false
            Summary   = "Target path '$TargetRelativePath' is outside the approved allowed_paths."
        }
    }

    foreach ($prohibitedPath in $prohibitedPaths) {
        if ($normalizedTarget -eq $prohibitedPath -or $normalizedTarget.StartsWith("$prohibitedPath\")) {
            return [pscustomobject]@{
                IsAllowed = $false
                Summary   = "Target path '$TargetRelativePath' is inside prohibited scope '$prohibitedPath'."
            }
        }
    }

    return [pscustomobject]@{
        IsAllowed = $true
        Summary   = $null
    }
}

function Add-UniqueString {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Values,
        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    if ($Values -notcontains $Value) {
        return @($Values) + @($Value)
    }

    return @($Values)
}

function Validate-ActionRequestFields {
    param(
        [Parameter(Mandatory = $true)]
        $ActionRequest
    )

    $foundation = Get-ActionFoundationContract
    $requestContract = Get-ActionRequestContract

    foreach ($fieldName in $foundation.action_request_required_fields) {
        Get-RequiredProperty -Object $ActionRequest -Name $fieldName -Context "ActionRequest" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ActionRequest -Name "contract_version" -Context "ActionRequest") -Context "ActionRequest.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "ActionRequest.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ActionRequest -Name "record_type" -Context "ActionRequest") -Context "ActionRequest.record_type"
    if ($recordType -ne $foundation.action_request_record_type -or $recordType -ne $requestContract.record_type) {
        throw "ActionRequest.record_type must equal '$($foundation.action_request_record_type)'."
    }

    $actionRequestId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ActionRequest -Name "action_request_id" -Context "ActionRequest") -Context "ActionRequest.action_request_id"
    Assert-RegexMatch -Value $actionRequestId -Pattern $foundation.identifier_pattern -Context "ActionRequest.action_request_id"

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ActionRequest -Name "gate_result_ref" -Context "ActionRequest") -Context "ActionRequest.gate_result_ref" | Out-Null

    $gateResultId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ActionRequest -Name "gate_result_id" -Context "ActionRequest") -Context "ActionRequest.gate_result_id"
    Assert-RegexMatch -Value $gateResultId -Pattern $foundation.identifier_pattern -Context "ActionRequest.gate_result_id"

    $packetId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ActionRequest -Name "packet_id" -Context "ActionRequest") -Context "ActionRequest.packet_id"
    Assert-RegexMatch -Value $packetId -Pattern $foundation.identifier_pattern -Context "ActionRequest.packet_id"

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ActionRequest -Name "packet_record_ref" -Context "ActionRequest") -Context "ActionRequest.packet_record_ref" | Out-Null

    $requestedAction = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ActionRequest -Name "requested_action" -Context "ActionRequest") -Context "ActionRequest.requested_action"
    Assert-AllowedValue -Value $requestedAction -AllowedValues @($foundation.allowed_requested_actions) -Context "ActionRequest.requested_action"

    $architectArtifactRef = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ActionRequest -Name "architect_artifact_ref" -Context "ActionRequest") -Context "ActionRequest.architect_artifact_ref"
    $architectArtifactCheck = Test-StageArtifactContract -ArtifactPath $architectArtifactRef
    if ($architectArtifactCheck.Stage -ne "architect") {
        throw "ActionRequest.architect_artifact_ref must reference an architect artifact."
    }

    Assert-StringArray -Value (Get-RequiredProperty -Object $ActionRequest -Name "approved_artifact_refs" -Context "ActionRequest") -Context "ActionRequest.approved_artifact_refs" | Out-Null

    $targetRelativePath = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ActionRequest -Name "target_relative_path" -Context "ActionRequest") -Context "ActionRequest.target_relative_path"
    $pathCheck = Test-ScopePathBounded -PathValue $targetRelativePath
    if (-not $pathCheck.IsBounded) {
        throw $pathCheck.Summary
    }

    $requestedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ActionRequest -Name "requested_at" -Context "ActionRequest") -Context "ActionRequest.requested_at"
    Assert-RegexMatch -Value $requestedAt -Pattern $foundation.timestamp_pattern -Context "ActionRequest.requested_at"

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ActionRequest -Name "requested_by" -Context "ActionRequest") -Context "ActionRequest.requested_by" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ActionRequest -Name "notes" -Context "ActionRequest") -Context "ActionRequest.notes" | Out-Null

    return [pscustomobject]@{
        IsValid         = $true
        ActionRequestId = $actionRequestId
        PacketId        = $packetId
        RequestedAction = $requestedAction
        TargetRelativePath = $targetRelativePath
    }
}

function Test-ApplyPromotionActionRequestContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ActionRequestPath
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $ActionRequestPath -Label "Action request path"
    $actionRequest = Get-JsonDocument -Path $resolvedPath -Label "Action request"
    $result = Validate-ActionRequestFields -ActionRequest $actionRequest

    return [pscustomobject]@{
        IsValid         = $result.IsValid
        ActionRequestId = $result.ActionRequestId
        PacketId        = $result.PacketId
        RequestedAction = $result.RequestedAction
        TargetRelativePath = $result.TargetRelativePath
        ActionRequestPath = $resolvedPath
    }
}

function Validate-ActionResultFields {
    param(
        [Parameter(Mandatory = $true)]
        $ActionResult
    )

    $foundation = Get-ActionFoundationContract
    $resultContract = Get-ActionResultContract
    $packetFoundation = Get-PacketFoundationContract

    foreach ($fieldName in $foundation.action_result_required_fields) {
        Get-RequiredProperty -Object $ActionResult -Name $fieldName -Context "ActionResult" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ActionResult -Name "contract_version" -Context "ActionResult") -Context "ActionResult.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "ActionResult.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ActionResult -Name "record_type" -Context "ActionResult") -Context "ActionResult.record_type"
    if ($recordType -ne $foundation.action_result_record_type -or $recordType -ne $resultContract.record_type) {
        throw "ActionResult.record_type must equal '$($foundation.action_result_record_type)'."
    }

    $actionResultId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ActionResult -Name "action_result_id" -Context "ActionResult") -Context "ActionResult.action_result_id"
    Assert-RegexMatch -Value $actionResultId -Pattern $foundation.identifier_pattern -Context "ActionResult.action_result_id"

    $actionRequestId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ActionResult -Name "action_request_id" -Context "ActionResult") -Context "ActionResult.action_request_id"
    Assert-RegexMatch -Value $actionRequestId -Pattern $foundation.identifier_pattern -Context "ActionResult.action_request_id"

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ActionResult -Name "gate_result_ref" -Context "ActionResult") -Context "ActionResult.gate_result_ref" | Out-Null

    $gateResultId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ActionResult -Name "gate_result_id" -Context "ActionResult") -Context "ActionResult.gate_result_id"
    Assert-RegexMatch -Value $gateResultId -Pattern $foundation.identifier_pattern -Context "ActionResult.gate_result_id"

    $packetId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ActionResult -Name "packet_id" -Context "ActionResult") -Context "ActionResult.packet_id"
    Assert-RegexMatch -Value $packetId -Pattern $foundation.identifier_pattern -Context "ActionResult.packet_id"

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ActionResult -Name "packet_record_ref" -Context "ActionResult") -Context "ActionResult.packet_record_ref" | Out-Null

    $requestedAction = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ActionResult -Name "requested_action" -Context "ActionResult") -Context "ActionResult.requested_action"
    Assert-AllowedValue -Value $requestedAction -AllowedValues @($foundation.allowed_requested_actions) -Context "ActionResult.requested_action"

    $executedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ActionResult -Name "executed_at" -Context "ActionResult") -Context "ActionResult.executed_at"
    Assert-RegexMatch -Value $executedAt -Pattern $foundation.timestamp_pattern -Context "ActionResult.executed_at"

    $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ActionResult -Name "status" -Context "ActionResult") -Context "ActionResult.status"
    Assert-AllowedValue -Value $status -AllowedValues @($foundation.allowed_action_statuses) -Context "ActionResult.status"

    $targetRelativePath = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ActionResult -Name "target_relative_path" -Context "ActionResult") -Context "ActionResult.target_relative_path"
    $pathCheck = Test-ScopePathBounded -PathValue $targetRelativePath
    if (-not $pathCheck.IsBounded) {
        throw $pathCheck.Summary
    }

    $outcomePath = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ActionResult -Name "outcome_path" -Context "ActionResult") -Context "ActionResult.outcome_path"
    if (-not (Test-Path -LiteralPath $outcomePath)) {
        throw "ActionResult.outcome_path '$outcomePath' does not exist."
    }

    $packetStateRecorded = Get-RequiredProperty -Object $ActionResult -Name "packet_state_recorded" -Context "ActionResult"
    if ($packetStateRecorded -isnot [bool]) {
        throw "ActionResult.packet_state_recorded must be a boolean."
    }

    $postActionState = Assert-ObjectValue -Value (Get-RequiredProperty -Object $ActionResult -Name "post_action_packet_state" -Context "ActionResult") -Context "ActionResult.post_action_packet_state"
    foreach ($fieldName in $foundation.action_result_post_state_required_fields) {
        Get-RequiredProperty -Object $postActionState -Name $fieldName -Context "ActionResult.post_action_packet_state" | Out-Null
    }

    $workingStateStatus = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $postActionState -Name "working_state_status" -Context "ActionResult.post_action_packet_state") -Context "ActionResult.post_action_packet_state.working_state_status"
    Assert-AllowedValue -Value $workingStateStatus -AllowedValues @($packetFoundation.allowed_working_state_statuses) -Context "ActionResult.post_action_packet_state.working_state_status"
    Assert-StringArray -Value (Get-RequiredProperty -Object $postActionState -Name "working_artifact_refs" -Context "ActionResult.post_action_packet_state") -Context "ActionResult.post_action_packet_state.working_artifact_refs" | Out-Null

    $reconciliationStatus = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $postActionState -Name "reconciliation_status" -Context "ActionResult.post_action_packet_state") -Context "ActionResult.post_action_packet_state.reconciliation_status"
    Assert-AllowedValue -Value $reconciliationStatus -AllowedValues @($packetFoundation.allowed_reconciliation_statuses) -Context "ActionResult.post_action_packet_state.reconciliation_status"

    $workingMatchesAccepted = Get-RequiredProperty -Object $postActionState -Name "working_matches_accepted" -Context "ActionResult.post_action_packet_state"
    if ($workingMatchesAccepted -isnot [bool]) {
        throw "ActionResult.post_action_packet_state.working_matches_accepted must be a boolean."
    }

    $gitHeadMatchesAccepted = Get-RequiredProperty -Object $postActionState -Name "git_head_matches_accepted" -Context "ActionResult.post_action_packet_state"
    if ($gitHeadMatchesAccepted -isnot [bool]) {
        throw "ActionResult.post_action_packet_state.git_head_matches_accepted must be a boolean."
    }

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ActionResult -Name "notes" -Context "ActionResult") -Context "ActionResult.notes" | Out-Null

    return [pscustomobject]@{
        IsValid        = $true
        ActionResultId = $actionResultId
        PacketId       = $packetId
        RequestedAction = $requestedAction
    }
}

function Test-ApplyPromotionActionResultContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ActionResultPath
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $ActionResultPath -Label "Action result path"
    $actionResult = Get-JsonDocument -Path $resolvedPath -Label "Action result"
    $result = Validate-ActionResultFields -ActionResult $actionResult

    return [pscustomobject]@{
        IsValid        = $result.IsValid
        ActionResultId = $result.ActionResultId
        PacketId       = $result.PacketId
        RequestedAction = $result.RequestedAction
        ActionResultPath = $resolvedPath
    }
}

function Invoke-ApplyPromotionAction {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ActionRequestPath,
        [string]$ResultStorePath
    )

    $actionRequestCheck = Test-ApplyPromotionActionRequestContract -ActionRequestPath $ActionRequestPath
    $actionRequest = Get-JsonDocument -Path $actionRequestCheck.ActionRequestPath -Label "Action request"
    $gateResult = Get-ApplyPromotionGateResult -Path $actionRequest.gate_result_ref

    if ($gateResult.gate_result_id -ne $actionRequest.gate_result_id) {
        throw "Action request gate_result_id '$($actionRequest.gate_result_id)' does not match gate result '$($gateResult.gate_result_id)'."
    }
    if ($gateResult.decision -ne "allow") {
        throw "Apply/promotion action can run only after an allow gate decision."
    }
    if ($gateResult.packet_id -ne $actionRequest.packet_id) {
        throw "Action request packet_id '$($actionRequest.packet_id)' does not match gate result packet '$($gateResult.packet_id)'."
    }
    if ($gateResult.requested_action -ne $actionRequest.requested_action) {
        throw "Action request requested_action '$($actionRequest.requested_action)' does not match gate result requested_action '$($gateResult.requested_action)'."
    }

    $scopeCheck = Test-RelativePathWithinScope -TargetRelativePath $actionRequest.target_relative_path -Scope $gateResult.scope
    if (-not $scopeCheck.IsAllowed) {
        throw $scopeCheck.Summary
    }

    $normalizedGateApprovedRefs = @($gateResult.approved_artifact_refs | ForEach-Object { Get-ComparisonPathValue -PathValue $_ -RequireExisting })
    $normalizedArchitectRef = Get-ComparisonPathValue -PathValue $actionRequest.architect_artifact_ref -RequireExisting
    if ($normalizedGateApprovedRefs -notcontains $normalizedArchitectRef) {
        throw "Action request architect_artifact_ref is not linked into the allow gate result approved_artifact_refs."
    }

    foreach ($approvedArtifactRef in @($actionRequest.approved_artifact_refs)) {
        $normalizedApprovedRef = Get-ComparisonPathValue -PathValue $approvedArtifactRef -RequireExisting
        if ($normalizedGateApprovedRefs -notcontains $normalizedApprovedRef) {
            throw "Action request approved artifact '$approvedArtifactRef' is not linked into the allow gate result approved_artifact_refs."
        }
    }

    $packetRecordPath = Resolve-ExistingPath -PathValue $actionRequest.packet_record_ref -Label "Action packet record path"
    $packetStorePath = Split-Path -Parent $packetRecordPath
    $packetRecord = Get-PacketRecord -Path $packetRecordPath
    if ($packetRecord.packet_id -ne $actionRequest.packet_id) {
        throw "Action request packet_id '$($actionRequest.packet_id)' does not match packet record '$($packetRecord.packet_id)'."
    }

    $architectArtifactCheck = Test-StageArtifactContract -ArtifactPath $actionRequest.architect_artifact_ref
    $architectArtifact = Get-JsonDocument -Path $architectArtifactCheck.ArtifactPath -Label "Architect artifact"
    if ($architectArtifact.stage -ne "architect" -or $architectArtifact.approval.status -ne "approved") {
        throw "Action request must reference an approved architect artifact."
    }

    $targetRelativePath = $actionRequest.target_relative_path
    $targetFullPath = Join-Path (Get-RepositoryRoot) (Normalize-RelativePath -PathValue $targetRelativePath)
    Ensure-Directory -Path (Split-Path -Parent $targetFullPath)

    $executedAt = (Get-Date).ToUniversalTime()
    $executedAtValue = Get-UtcTimestamp -Value $executedAt

    $outcomeDocument = [pscustomobject]@{
        contract_version       = (Get-ActionFoundationContract).contract_version
        record_type            = "apply_promotion_action_outcome"
        action_request_id      = $actionRequest.action_request_id
        gate_result_id         = $actionRequest.gate_result_id
        packet_id              = $actionRequest.packet_id
        requested_action       = $actionRequest.requested_action
        created_at             = $executedAtValue
        created_by             = $actionRequest.requested_by
        architect_artifact_ref = $architectArtifactCheck.ArtifactPath
        approved_artifact_refs = @($gateResult.approved_artifact_refs)
        change_intent          = $architectArtifact.output.change_intent
        affected_artifacts     = @($architectArtifact.output.affected_artifacts)
        acceptance_checks      = @($architectArtifact.output.acceptance_checks)
        notes                  = "Bounded allow-path action outcome artifact written inside approved scope."
    }
    $outcomeDocument | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $targetFullPath -Encoding UTF8

    $resultStore = Get-ActionResultStorePath -StorePath $ResultStorePath
    Ensure-Directory -Path $resultStore
    $actionResultId = "{0}.result" -f $actionRequest.action_request_id
    $actionResultPath = Join-Path $resultStore ("{0}.json" -f $actionResultId)

    $packetRecord = Add-PacketRecordArtifactRef -PacketRecord $packetRecord -Stage "architect" -Ref $actionRequestCheck.ActionRequestPath -Kind "supporting" -View "working" -AddedAt $executedAt -Notes "Bounded apply/promotion action request."
    $packetRecord = Add-PacketRecordArtifactRef -PacketRecord $packetRecord -Stage "architect" -Ref $targetRelativePath -Kind "supporting" -View "working" -AddedAt $executedAt -Notes "Bounded apply/promotion action outcome artifact."
    $packetRecord = Add-PacketRecordArtifactRef -PacketRecord $packetRecord -Stage "architect" -Ref $actionResultPath -Kind "supporting" -View "working" -AddedAt $executedAt -Notes "Bounded apply/promotion action result."

    $workingArtifactRefs = @($packetRecord.working_state.artifact_refs)
    $workingArtifactRefs = Add-UniqueString -Values $workingArtifactRefs -Value $actionRequestCheck.ActionRequestPath
    $workingArtifactRefs = Add-UniqueString -Values $workingArtifactRefs -Value $targetRelativePath
    $workingArtifactRefs = Add-UniqueString -Values $workingArtifactRefs -Value $actionResultPath

    $packetRecord = Set-PacketRecordWorkingState -PacketRecord $packetRecord -Status "in_progress" -ArtifactRefs $workingArtifactRefs -UpdatedAt $executedAt -Notes ("Bounded {0} action executed after allow gate decision. Outcome artifact: {1}. Action result: {2}" -f $actionRequest.requested_action, $targetRelativePath, $actionResultPath)
    $packetRecord = Set-PacketRecordReconciliationState -PacketRecord $packetRecord -Status "drift" -ComparedAt $executedAt -WorkingMatchesAccepted:$false -GitHeadMatchesAccepted:$true -Notes ("Bounded {0} action created working output inside approved scope while accepted commit remains unchanged." -f $actionRequest.requested_action)
    $savedPacketPath = Save-PacketRecord -PacketRecord $packetRecord -StorePath $packetStorePath
    $savedPacket = Get-PacketRecord -Path $savedPacketPath

    $actionResult = [pscustomobject]@{
        contract_version      = (Get-ActionFoundationContract).contract_version
        record_type           = (Get-ActionFoundationContract).action_result_record_type
        action_result_id      = $actionResultId
        action_request_id     = $actionRequest.action_request_id
        gate_result_ref       = $actionRequest.gate_result_ref
        gate_result_id        = $actionRequest.gate_result_id
        packet_id             = $actionRequest.packet_id
        packet_record_ref     = $savedPacketPath
        requested_action      = $actionRequest.requested_action
        executed_at           = $executedAtValue
        status                = "completed"
        target_relative_path  = $targetRelativePath
        outcome_path          = $targetFullPath
        packet_state_recorded = $true
        post_action_packet_state = [pscustomobject]@{
            working_state_status       = $savedPacket.working_state.status
            working_artifact_refs      = @($savedPacket.working_state.artifact_refs)
            reconciliation_status      = $savedPacket.reconciliation_state.status
            working_matches_accepted   = $savedPacket.reconciliation_state.working_matches_accepted
            git_head_matches_accepted  = $savedPacket.reconciliation_state.git_head_matches_accepted
        }
        notes                = ("Bounded {0} action completed and packet state was updated durably." -f $actionRequest.requested_action)
    }

    Validate-ActionResultFields -ActionResult $actionResult | Out-Null
    $actionResult | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $actionResultPath -Encoding UTF8

    return [pscustomobject]@{
        ActionResult     = $actionResult
        ActionResultPath = $actionResultPath
        ActionOutcomePath = $targetFullPath
        PacketPath       = $savedPacketPath
    }
}

Export-ModuleMember -Function Test-ApplyPromotionActionRequestContract, Test-ApplyPromotionActionResultContract, Invoke-ApplyPromotionAction
