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

function Get-HarnessFoundationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\supervised_harness\foundation.contract.json") -Label "Supervised harness foundation contract"
}

function Get-HarnessRequestContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\supervised_harness\request.contract.json") -Label "Supervised harness request contract"
}

function Get-SupervisedRunRoot {
    param(
        [Parameter(Mandatory = $true)]
        $FlowRequest,
        [string]$OutputRoot
    )

    if ([string]::IsNullOrWhiteSpace($OutputRoot)) {
        return Join-Path (Get-RepositoryRoot) ("state\supervised_runs\{0}" -f $FlowRequest.flow_request_id)
    }

    return Resolve-OptionalPath -PathValue $OutputRoot
}

function Get-SupervisedRunPaths {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RunRoot
    )

    return [pscustomobject]@{
        RunRoot         = $RunRoot
        PacketStore     = Join-Path $RunRoot "packets"
        GateRequestStore = Join-Path $RunRoot "gate_requests"
        GateResultStore = Join-Path $RunRoot "gate_results"
    }
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

function Validate-HarnessGateApproval {
    param(
        [Parameter(Mandatory = $true)]
        $Approval,
        [Parameter(Mandatory = $true)]
        $Foundation
    )

    foreach ($fieldName in $Foundation.gate_request_approval_required_fields) {
        Get-RequiredProperty -Object $Approval -Name $fieldName -Context "HarnessRequest.gate_request.approval" | Out-Null
    }

    $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Approval -Name "status" -Context "HarnessRequest.gate_request.approval") -Context "HarnessRequest.gate_request.approval.status"
    Assert-AllowedValue -Value $status -AllowedValues @($Foundation.allowed_approval_statuses) -Context "HarnessRequest.gate_request.approval.status"

    $by = Get-RequiredProperty -Object $Approval -Name "by" -Context "HarnessRequest.gate_request.approval"
    $at = Get-RequiredProperty -Object $Approval -Name "at" -Context "HarnessRequest.gate_request.approval"
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Approval -Name "notes" -Context "HarnessRequest.gate_request.approval") -Context "HarnessRequest.gate_request.approval.notes" | Out-Null

    if ($status -eq "pending") {
        if ($null -ne $by -or $null -ne $at) {
            throw "HarnessRequest.gate_request.approval.by and .at must be null while approval is pending."
        }
    }
    else {
        Assert-NonEmptyString -Value $by -Context "HarnessRequest.gate_request.approval.by" | Out-Null
        $atValue = Assert-NonEmptyString -Value $at -Context "HarnessRequest.gate_request.approval.at"
        Assert-RegexMatch -Value $atValue -Pattern $Foundation.timestamp_pattern -Context "HarnessRequest.gate_request.approval.at"
    }
}

function Validate-HarnessGateScope {
    param(
        [Parameter(Mandatory = $true)]
        $Scope,
        [Parameter(Mandatory = $true)]
        $Foundation
    )

    foreach ($fieldName in $Foundation.gate_request_scope_required_fields) {
        Get-RequiredProperty -Object $Scope -Name $fieldName -Context "HarnessRequest.gate_request.scope" | Out-Null
    }

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Scope -Name "summary" -Context "HarnessRequest.gate_request.scope") -Context "HarnessRequest.gate_request.scope.summary" | Out-Null
    Assert-StringArray -Value (Get-RequiredProperty -Object $Scope -Name "allowed_paths" -Context "HarnessRequest.gate_request.scope") -Context "HarnessRequest.gate_request.scope.allowed_paths" -AllowEmpty | Out-Null
    Assert-StringArray -Value (Get-RequiredProperty -Object $Scope -Name "prohibited_paths" -Context "HarnessRequest.gate_request.scope") -Context "HarnessRequest.gate_request.scope.prohibited_paths" -AllowEmpty | Out-Null
}

function Validate-SupervisedAdminFlowRequestFields {
    param(
        [Parameter(Mandatory = $true)]
        $FlowRequest
    )

    $foundation = Get-HarnessFoundationContract
    $requestContract = Get-HarnessRequestContract

    foreach ($fieldName in $foundation.required_fields) {
        Get-RequiredProperty -Object $FlowRequest -Name $fieldName -Context "HarnessRequest" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $FlowRequest -Name "contract_version" -Context "HarnessRequest") -Context "HarnessRequest.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "HarnessRequest.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $FlowRequest -Name "record_type" -Context "HarnessRequest") -Context "HarnessRequest.record_type"
    if ($recordType -ne $foundation.request_record_type -or $recordType -ne $requestContract.record_type) {
        throw "HarnessRequest.record_type must equal '$($foundation.request_record_type)'."
    }

    $flowRequestId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $FlowRequest -Name "flow_request_id" -Context "HarnessRequest") -Context "HarnessRequest.flow_request_id"
    Assert-RegexMatch -Value $flowRequestId -Pattern $foundation.identifier_pattern -Context "HarnessRequest.flow_request_id"

    $operatorId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $FlowRequest -Name "operator_id" -Context "HarnessRequest") -Context "HarnessRequest.operator_id"
    Assert-RegexMatch -Value $operatorId -Pattern $foundation.operator_pattern -Context "HarnessRequest.operator_id"

    $requestedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $FlowRequest -Name "requested_at" -Context "HarnessRequest") -Context "HarnessRequest.requested_at"
    Assert-RegexMatch -Value $requestedAt -Pattern $foundation.timestamp_pattern -Context "HarnessRequest.requested_at"

    $packet = Assert-ObjectValue -Value (Get-RequiredProperty -Object $FlowRequest -Name "packet" -Context "HarnessRequest") -Context "HarnessRequest.packet"
    foreach ($fieldName in $foundation.packet_required_fields) {
        Get-RequiredProperty -Object $packet -Name $fieldName -Context "HarnessRequest.packet" | Out-Null
    }

    $packetMode = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $packet -Name "mode" -Context "HarnessRequest.packet") -Context "HarnessRequest.packet.mode"
    Assert-AllowedValue -Value $packetMode -AllowedValues @($foundation.allowed_packet_modes) -Context "HarnessRequest.packet.mode"

    $packetId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $packet -Name "packet_id" -Context "HarnessRequest.packet") -Context "HarnessRequest.packet.packet_id"
    Assert-RegexMatch -Value $packetId -Pattern $foundation.identifier_pattern -Context "HarnessRequest.packet.packet_id"

    $packetRecordRef = Get-RequiredProperty -Object $packet -Name "packet_record_ref" -Context "HarnessRequest.packet"
    $packetRecordRefValue = Assert-NullableString -Value $packetRecordRef -Context "HarnessRequest.packet.packet_record_ref"
    if ($packetMode -eq "create" -and $null -ne $packetRecordRefValue) {
        throw "HarnessRequest.packet.packet_record_ref must be null when packet.mode is 'create'."
    }
    if ($packetMode -eq "load" -and $null -eq $packetRecordRefValue) {
        throw "HarnessRequest.packet.packet_record_ref is required when packet.mode is 'load'."
    }

    $artifactRefs = Assert-ObjectValue -Value (Get-RequiredProperty -Object $packet -Name "stage_artifact_refs" -Context "HarnessRequest.packet") -Context "HarnessRequest.packet.stage_artifact_refs"
    foreach ($fieldName in $foundation.stage_artifact_refs_required_fields) {
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $artifactRefs -Name $fieldName -Context "HarnessRequest.packet.stage_artifact_refs") -Context "HarnessRequest.packet.stage_artifact_refs.$fieldName" | Out-Null
    }

    $packetApprovalStatus = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $packet -Name "approval_status" -Context "HarnessRequest.packet") -Context "HarnessRequest.packet.approval_status"
    Assert-AllowedValue -Value $packetApprovalStatus -AllowedValues @($foundation.allowed_packet_approval_statuses) -Context "HarnessRequest.packet.approval_status"

    $reconciliationStatus = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $packet -Name "reconciliation_status" -Context "HarnessRequest.packet") -Context "HarnessRequest.packet.reconciliation_status"
    Assert-AllowedValue -Value $reconciliationStatus -AllowedValues @($foundation.allowed_reconciliation_statuses) -Context "HarnessRequest.packet.reconciliation_status"

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $packet -Name "notes" -Context "HarnessRequest.packet") -Context "HarnessRequest.packet.notes" | Out-Null

    $gateRequest = Assert-ObjectValue -Value (Get-RequiredProperty -Object $FlowRequest -Name "gate_request" -Context "HarnessRequest") -Context "HarnessRequest.gate_request"
    foreach ($fieldName in $foundation.gate_request_required_fields) {
        Get-RequiredProperty -Object $gateRequest -Name $fieldName -Context "HarnessRequest.gate_request" | Out-Null
    }

    $requestedAction = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $gateRequest -Name "requested_action" -Context "HarnessRequest.gate_request") -Context "HarnessRequest.gate_request.requested_action"
    Assert-AllowedValue -Value $requestedAction -AllowedValues @($foundation.allowed_requested_actions) -Context "HarnessRequest.gate_request.requested_action"

    $gateApproval = Assert-ObjectValue -Value (Get-RequiredProperty -Object $gateRequest -Name "approval" -Context "HarnessRequest.gate_request") -Context "HarnessRequest.gate_request.approval"
    Validate-HarnessGateApproval -Approval $gateApproval -Foundation $foundation

    $gateScope = Assert-ObjectValue -Value (Get-RequiredProperty -Object $gateRequest -Name "scope" -Context "HarnessRequest.gate_request") -Context "HarnessRequest.gate_request.scope"
    Validate-HarnessGateScope -Scope $gateScope -Foundation $foundation

    Assert-StringArray -Value (Get-RequiredProperty -Object $gateRequest -Name "approved_artifact_refs" -Context "HarnessRequest.gate_request") -Context "HarnessRequest.gate_request.approved_artifact_refs" -AllowEmpty | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $gateRequest -Name "notes" -Context "HarnessRequest.gate_request") -Context "HarnessRequest.gate_request.notes" | Out-Null

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $FlowRequest -Name "notes" -Context "HarnessRequest") -Context "HarnessRequest.notes" | Out-Null

    return [pscustomobject]@{
        IsValid       = $true
        FlowRequestId = $flowRequestId
        OperatorId    = $operatorId
        PacketMode    = $packetMode
        PacketId      = $packetId
        RequestedAction = $requestedAction
    }
}

function Test-SupervisedAdminFlowRequestContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$FlowRequestPath
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $FlowRequestPath -Label "Supervised flow request path"
    $flowRequest = Get-JsonDocument -Path $resolvedPath -Label "Supervised flow request"
    $result = Validate-SupervisedAdminFlowRequestFields -FlowRequest $flowRequest

    return [pscustomobject]@{
        IsValid        = $result.IsValid
        FlowRequestId  = $result.FlowRequestId
        OperatorId     = $result.OperatorId
        PacketMode     = $result.PacketMode
        PacketId       = $result.PacketId
        RequestedAction = $result.RequestedAction
        FlowRequestPath = $resolvedPath
    }
}

function Get-GitContext {
    $branch = (& git -C (Get-RepositoryRoot) rev-parse --abbrev-ref HEAD 2>$null).Trim()
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($branch)) {
        throw "Unable to resolve the current Git branch for the supervised harness."
    }

    $headCommit = (& git -C (Get-RepositoryRoot) rev-parse HEAD 2>$null).Trim()
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($headCommit)) {
        throw "Unable to resolve the current Git HEAD commit for the supervised harness."
    }

    return [pscustomobject]@{
        branch = $branch
        head_commit = $headCommit
    }
}

function Validate-StageArtifactsForFlow {
    param(
        [Parameter(Mandatory = $true)]
        $StageArtifactRefs
    )

    $expectedStages = @("intake", "pm", "context_audit", "architect")
    $validated = [ordered]@{}
    foreach ($stage in $expectedStages) {
        $artifactPath = Get-RequiredProperty -Object $StageArtifactRefs -Name $stage -Context "HarnessRequest.packet.stage_artifact_refs"
        $artifactCheck = Test-StageArtifactContract -ArtifactPath $artifactPath
        if ($artifactCheck.Stage -ne $stage) {
            throw "Harness stage artifact '$artifactPath' did not validate as stage '$stage'."
        }
        $validated[$stage] = $artifactCheck.ArtifactPath
    }

    return [pscustomobject]$validated
}

function Initialize-SupervisedPacket {
    param(
        [Parameter(Mandatory = $true)]
        $FlowRequest,
        [Parameter(Mandatory = $true)]
        $RunPaths
    )

    $validatedArtifacts = Validate-StageArtifactsForFlow -StageArtifactRefs $FlowRequest.packet.stage_artifact_refs
    $gitContext = Get-GitContext
    $timestamp = Get-UtcTimestamp

    $packet = New-PacketRecord -PacketId $FlowRequest.packet.packet_id -InitialStage "intake"
    $packet = Add-PacketRecordArtifactRef -PacketRecord $packet -Stage "intake" -Ref $validatedArtifacts.intake -Kind "stage_artifact" -View "working" -Notes "Supervised harness intake artifact."
    $packet = Set-PacketRecordCurrentStage -PacketRecord $packet -Stage "intake" -Status "complete" -ArtifactRef $validatedArtifacts.intake -Notes "Supervised harness recorded intake completion."

    $packet = Add-PacketRecordArtifactRef -PacketRecord $packet -Stage "pm" -Ref $validatedArtifacts.pm -Kind "stage_artifact" -View "working" -Notes "Supervised harness planning artifact."
    $packet = Set-PacketRecordCurrentStage -PacketRecord $packet -Stage "pm" -Status "complete" -ArtifactRef $validatedArtifacts.pm -Notes "Supervised harness recorded planning completion."

    $packet = Add-PacketRecordArtifactRef -PacketRecord $packet -Stage "context_audit" -Ref $validatedArtifacts.context_audit -Kind "stage_artifact" -View "working" -Notes "Supervised harness context audit artifact."
    $packet = Set-PacketRecordCurrentStage -PacketRecord $packet -Stage "context_audit" -Status "complete" -ArtifactRef $validatedArtifacts.context_audit -Notes "Supervised harness recorded context audit completion."

    $packet = Add-PacketRecordArtifactRef -PacketRecord $packet -Stage "architect" -Ref $validatedArtifacts.architect -Kind "stage_artifact" -View "working" -Notes "Supervised harness architect artifact."
    $packet = Add-PacketRecordArtifactRef -PacketRecord $packet -Stage "architect" -Ref $validatedArtifacts.architect -Kind "stage_artifact" -View "accepted" -Notes "Supervised harness accepted architect artifact."
    $packet = Set-PacketRecordCurrentStage -PacketRecord $packet -Stage "architect" -Status "complete" -ArtifactRef $validatedArtifacts.architect -Notes "Supervised harness recorded architect completion."

    if ($FlowRequest.packet.approval_status -eq "approved") {
        $packet = Set-PacketRecordApprovalState -PacketRecord $packet -Mode "required" -Status "approved" -By $FlowRequest.operator_id -At (Get-Date).ToUniversalTime() -Notes "Supervised harness recorded explicit admin approval."
    }
    else {
        $packet = Set-PacketRecordApprovalState -PacketRecord $packet -Mode "required" -Status "pending" -Notes "Supervised harness left packet approval pending."
    }

    $packet = Set-PacketRecordAcceptedState -PacketRecord $packet -Status "accepted" -AcceptedStage "architect" -ArtifactRefs @($validatedArtifacts.architect) -AcceptedAt (Get-Date).ToUniversalTime() -AcceptedBy $FlowRequest.operator_id -Notes "Supervised harness accepted architect artifact as packet truth."
    $packet = Set-PacketRecordWorkingState -PacketRecord $packet -Status "ready_for_review" -ArtifactRefs @($validatedArtifacts.architect) -Notes "Supervised harness aligned working state with architect artifact."
    $packet = Set-PacketRecordGitRefs -PacketRecord $packet -Branch $gitContext.branch -HeadCommit $gitContext.head_commit -AcceptedCommit $gitContext.head_commit -ObservedAt (Get-Date).ToUniversalTime()

    if ($FlowRequest.packet.reconciliation_status -eq "matched") {
        $packet = Set-PacketRecordReconciliationState -PacketRecord $packet -Status "matched" -ComparedAt (Get-Date).ToUniversalTime() -WorkingMatchesAccepted:$true -GitHeadMatchesAccepted:$true -Notes "Supervised harness confirmed matched reconciliation."
    }
    else {
        $packet = Set-PacketRecordReconciliationState -PacketRecord $packet -Status "pending" -ComparedAt (Get-Date).ToUniversalTime() -Notes "Supervised harness left reconciliation pending."
    }

    $savedPacketPath = Save-PacketRecord -PacketRecord $packet -StorePath $RunPaths.PacketStore
    return [pscustomobject]@{
        PacketPath      = $savedPacketPath
        PacketRecord    = Get-PacketRecord -Path $savedPacketPath
        ArchitectArtifact = $validatedArtifacts.architect
    }
}

function Load-SupervisedPacketCopy {
    param(
        [Parameter(Mandatory = $true)]
        $FlowRequest,
        [Parameter(Mandatory = $true)]
        $RunPaths
    )

    $validatedArtifacts = Validate-StageArtifactsForFlow -StageArtifactRefs $FlowRequest.packet.stage_artifact_refs
    $sourcePacketPath = Resolve-ExistingPath -PathValue $FlowRequest.packet.packet_record_ref -Label "Harness source packet path"
    $packetRecord = Get-PacketRecord -Path $sourcePacketPath

    if ($packetRecord.packet_id -ne $FlowRequest.packet.packet_id) {
        throw "Loaded packet '$($packetRecord.packet_id)' does not match harness request packet_id '$($FlowRequest.packet.packet_id)'."
    }

    if ($packetRecord.current_stage -ne "architect" -and $packetRecord.accepted_state.accepted_stage -ne "architect") {
        throw "Loaded packet must already be at or accepted through 'architect' for the minimal supervised load path."
    }

    $savedPacketPath = Save-PacketRecord -PacketRecord $packetRecord -StorePath $RunPaths.PacketStore
    return [pscustomobject]@{
        PacketPath      = $savedPacketPath
        PacketRecord    = Get-PacketRecord -Path $savedPacketPath
        ArchitectArtifact = $validatedArtifacts.architect
    }
}

function Save-HarnessGateRequest {
    param(
        [Parameter(Mandatory = $true)]
        $FlowRequest,
        [Parameter(Mandatory = $true)]
        [string]$PacketPath,
        [Parameter(Mandatory = $true)]
        $RunPaths
    )

    Ensure-Directory -Path $RunPaths.GateRequestStore

    $approvedArtifactRefs = @()
    foreach ($artifactRef in @($FlowRequest.gate_request.approved_artifact_refs)) {
        $validatedArtifact = Test-StageArtifactContract -ArtifactPath $artifactRef
        $approvedArtifactRefs += $validatedArtifact.ArtifactPath
    }

    $gateRequest = [pscustomobject]@{
        contract_version    = "v1"
        record_type         = "apply_promotion_gate_request"
        gate_request_id     = $FlowRequest.flow_request_id
        packet_id           = $FlowRequest.packet.packet_id
        packet_record_ref   = $PacketPath
        requested_action    = $FlowRequest.gate_request.requested_action
        requested_at        = Get-UtcTimestamp
        requested_by        = $FlowRequest.operator_id
        approval            = [pscustomobject]@{
            status = $FlowRequest.gate_request.approval.status
            by     = Convert-BlankStringToNull -Value $FlowRequest.gate_request.approval.by
            at     = Convert-BlankStringToNull -Value $FlowRequest.gate_request.approval.at
            notes  = $FlowRequest.gate_request.approval.notes
        }
        scope               = [pscustomobject]@{
            summary         = $FlowRequest.gate_request.scope.summary
            allowed_paths   = @($FlowRequest.gate_request.scope.allowed_paths)
            prohibited_paths = @($FlowRequest.gate_request.scope.prohibited_paths)
        }
        approved_artifact_refs = $approvedArtifactRefs
        notes               = $FlowRequest.gate_request.notes
    }

    $gateRequestPath = Join-Path $RunPaths.GateRequestStore ("{0}.request.json" -f $FlowRequest.flow_request_id)
    $gateRequest | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $gateRequestPath -Encoding UTF8
    Test-ApplyPromotionGateRequestContract -GateRequestPath $gateRequestPath | Out-Null

    return $gateRequestPath
}

function Invoke-SupervisedAdminFlow {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$FlowRequestPath,
        [string]$OutputRoot
    )

    $flowRequestCheck = Test-SupervisedAdminFlowRequestContract -FlowRequestPath $FlowRequestPath
    $flowRequest = Get-JsonDocument -Path $flowRequestCheck.FlowRequestPath -Label "Supervised flow request"

    $runRoot = Get-SupervisedRunRoot -FlowRequest $flowRequest -OutputRoot $OutputRoot
    $runPaths = Get-SupervisedRunPaths -RunRoot $runRoot
    Ensure-Directory -Path $runPaths.RunRoot
    Ensure-Directory -Path $runPaths.PacketStore
    Ensure-Directory -Path $runPaths.GateResultStore

    if ($flowRequest.packet.mode -eq "create") {
        $packetResult = Initialize-SupervisedPacket -FlowRequest $flowRequest -RunPaths $runPaths
    }
    else {
        $packetResult = Load-SupervisedPacketCopy -FlowRequest $flowRequest -RunPaths $runPaths
    }

    $gateRequestPath = Save-HarnessGateRequest -FlowRequest $flowRequest -PacketPath $packetResult.PacketPath -RunPaths $runPaths
    $gateResult = Invoke-ApplyPromotionGate -GateRequestPath $gateRequestPath
    $savedGateResult = Save-ApplyPromotionGateResult -GateResult $gateResult -StorePath $runPaths.GateResultStore

    return [pscustomobject]@{
        FlowRequestId  = $flowRequest.flow_request_id
        OperatorId     = $flowRequest.operator_id
        PacketMode     = $flowRequest.packet.mode
        PacketPath     = $packetResult.PacketPath
        GateRequestPath = $gateRequestPath
        GateResultPath = $savedGateResult.GateResultPath
        Decision       = $savedGateResult.GateResult.decision
        RunRoot        = $runPaths.RunRoot
    }
}

Export-ModuleMember -Function Test-SupervisedAdminFlowRequestContract, Invoke-SupervisedAdminFlow
