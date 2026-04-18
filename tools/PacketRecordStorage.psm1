Set-StrictMode -Version Latest

function Get-RepositoryRoot {
    return (Split-Path -Parent $PSScriptRoot)
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

function Get-PacketStorePath {
    param(
        [string]$StorePath
    )

    if ([string]::IsNullOrWhiteSpace($StorePath)) {
        return Join-Path (Get-RepositoryRoot) "state\packets"
    }

    return (Resolve-OptionalPath -PathValue $StorePath)
}

function Get-FoundationContract {
    $path = Join-Path (Get-RepositoryRoot) "contracts\packet_records\foundation.contract.json"
    return Get-JsonDocument -Path $path -Label "Packet record foundation contract"
}

function Get-PacketRecordContract {
    $path = Join-Path (Get-RepositoryRoot) "contracts\packet_records\packet_record.contract.json"
    return Get-JsonDocument -Path $path -Label "Packet record contract"
}

function Validate-StageProgression {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$StageProgression,
        [Parameter(Mandatory = $true)]
        $Foundation
    )

    foreach ($entry in $StageProgression) {
        foreach ($fieldName in $Foundation.stage_progression_required_fields) {
            Get-RequiredProperty -Object $entry -Name $fieldName -Context "Packet.stage_progression item" | Out-Null
        }

        $stage = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $entry -Name "stage" -Context "Packet.stage_progression item") -Context "Packet.stage_progression item.stage"
        Assert-AllowedValue -Value $stage -AllowedValues @($Foundation.allowed_stages) -Context "Packet.stage_progression item.stage"

        $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $entry -Name "status" -Context "Packet.stage_progression item") -Context "Packet.stage_progression item.status"
        Assert-AllowedValue -Value $status -AllowedValues @($Foundation.allowed_stage_statuses) -Context "Packet.stage_progression item.status"

        $enteredAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $entry -Name "entered_at" -Context "Packet.stage_progression item") -Context "Packet.stage_progression item.entered_at"
        Assert-RegexMatch -Value $enteredAt -Pattern $Foundation.timestamp_pattern -Context "Packet.stage_progression item.entered_at"

        $artifactRef = Get-RequiredProperty -Object $entry -Name "artifact_ref" -Context "Packet.stage_progression item"
        Assert-NullableString -Value $artifactRef -Context "Packet.stage_progression item.artifact_ref" | Out-Null
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $entry -Name "notes" -Context "Packet.stage_progression item") -Context "Packet.stage_progression item.notes" | Out-Null
    }
}

function Validate-ApprovalState {
    param(
        [Parameter(Mandatory = $true)]
        $ApprovalState,
        [Parameter(Mandatory = $true)]
        $Foundation
    )

    foreach ($fieldName in $Foundation.approval_state_required_fields) {
        Get-RequiredProperty -Object $ApprovalState -Name $fieldName -Context "Packet.approval_state" | Out-Null
    }

    $mode = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ApprovalState -Name "mode" -Context "Packet.approval_state") -Context "Packet.approval_state.mode"
    Assert-AllowedValue -Value $mode -AllowedValues @($Foundation.allowed_approval_modes) -Context "Packet.approval_state.mode"

    $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ApprovalState -Name "status" -Context "Packet.approval_state") -Context "Packet.approval_state.status"
    Assert-AllowedValue -Value $status -AllowedValues @($Foundation.allowed_approval_statuses) -Context "Packet.approval_state.status"

    $by = Get-RequiredProperty -Object $ApprovalState -Name "by" -Context "Packet.approval_state"
    $at = Get-RequiredProperty -Object $ApprovalState -Name "at" -Context "Packet.approval_state"
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ApprovalState -Name "notes" -Context "Packet.approval_state") -Context "Packet.approval_state.notes" | Out-Null

    if ($mode -eq "not_required") {
        if ($status -ne "not_required") {
            throw "Packet.approval_state.status must be 'not_required' when Packet.approval_state.mode is 'not_required'."
        }
        if ($null -ne $by -or $null -ne $at) {
            throw "Packet.approval_state.by and Packet.approval_state.at must be null when approval is not required."
        }
    }
    elseif ($status -eq "pending") {
        if ($null -ne $by -or $null -ne $at) {
            throw "Packet.approval_state.by and Packet.approval_state.at must be null while approval is pending."
        }
    }
    else {
        Assert-NonEmptyString -Value $by -Context "Packet.approval_state.by" | Out-Null
        $atValue = Assert-NonEmptyString -Value $at -Context "Packet.approval_state.at"
        Assert-RegexMatch -Value $atValue -Pattern $Foundation.timestamp_pattern -Context "Packet.approval_state.at"
    }
}

function Validate-ArtifactRefs {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [object[]]$ArtifactRefs,
        [Parameter(Mandatory = $true)]
        $Foundation
    )

    foreach ($item in $ArtifactRefs) {
        foreach ($fieldName in $Foundation.artifact_ref_required_fields) {
            Get-RequiredProperty -Object $item -Name $fieldName -Context "Packet.artifact_refs item" | Out-Null
        }

        $stage = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "stage" -Context "Packet.artifact_refs item") -Context "Packet.artifact_refs item.stage"
        Assert-AllowedValue -Value $stage -AllowedValues @($Foundation.allowed_stages) -Context "Packet.artifact_refs item.stage"

        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "ref" -Context "Packet.artifact_refs item") -Context "Packet.artifact_refs item.ref" | Out-Null

        $kind = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "kind" -Context "Packet.artifact_refs item") -Context "Packet.artifact_refs item.kind"
        Assert-AllowedValue -Value $kind -AllowedValues @($Foundation.allowed_artifact_ref_kinds) -Context "Packet.artifact_refs item.kind"

        $view = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "view" -Context "Packet.artifact_refs item") -Context "Packet.artifact_refs item.view"
        Assert-AllowedValue -Value $view -AllowedValues @($Foundation.allowed_artifact_ref_views) -Context "Packet.artifact_refs item.view"

        $addedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "added_at" -Context "Packet.artifact_refs item") -Context "Packet.artifact_refs item.added_at"
        Assert-RegexMatch -Value $addedAt -Pattern $Foundation.timestamp_pattern -Context "Packet.artifact_refs item.added_at"
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "notes" -Context "Packet.artifact_refs item") -Context "Packet.artifact_refs item.notes" | Out-Null
    }
}

function Validate-GitRefs {
    param(
        [Parameter(Mandatory = $true)]
        $GitRefs,
        [Parameter(Mandatory = $true)]
        $Foundation
    )

    foreach ($fieldName in $Foundation.git_ref_required_fields) {
        Get-RequiredProperty -Object $GitRefs -Name $fieldName -Context "Packet.git_refs" | Out-Null
    }

    Assert-NullableString -Value (Get-RequiredProperty -Object $GitRefs -Name "branch" -Context "Packet.git_refs") -Context "Packet.git_refs.branch" | Out-Null
    Assert-NullableString -Value (Get-RequiredProperty -Object $GitRefs -Name "head_commit" -Context "Packet.git_refs") -Context "Packet.git_refs.head_commit" | Out-Null
    Assert-NullableString -Value (Get-RequiredProperty -Object $GitRefs -Name "accepted_commit" -Context "Packet.git_refs") -Context "Packet.git_refs.accepted_commit" | Out-Null
    Assert-NullableString -Value (Get-RequiredProperty -Object $GitRefs -Name "accepted_tag" -Context "Packet.git_refs") -Context "Packet.git_refs.accepted_tag" | Out-Null
    $lastObservedAt = Get-RequiredProperty -Object $GitRefs -Name "last_observed_at" -Context "Packet.git_refs"
    $lastObservedAtValue = Assert-NullableString -Value $lastObservedAt -Context "Packet.git_refs.last_observed_at"
    if ($null -ne $lastObservedAtValue) {
        Assert-RegexMatch -Value $lastObservedAtValue -Pattern $Foundation.timestamp_pattern -Context "Packet.git_refs.last_observed_at"
    }
}

function Validate-WorkingState {
    param(
        [Parameter(Mandatory = $true)]
        $WorkingState,
        [Parameter(Mandatory = $true)]
        $Foundation
    )

    foreach ($fieldName in $Foundation.working_state_required_fields) {
        Get-RequiredProperty -Object $WorkingState -Name $fieldName -Context "Packet.working_state" | Out-Null
    }

    $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $WorkingState -Name "status" -Context "Packet.working_state") -Context "Packet.working_state.status"
    Assert-AllowedValue -Value $status -AllowedValues @($Foundation.allowed_working_state_statuses) -Context "Packet.working_state.status"

    $currentStage = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $WorkingState -Name "current_stage" -Context "Packet.working_state") -Context "Packet.working_state.current_stage"
    Assert-AllowedValue -Value $currentStage -AllowedValues @($Foundation.allowed_stages) -Context "Packet.working_state.current_stage"

    Assert-StringArray -Value (Get-RequiredProperty -Object $WorkingState -Name "artifact_refs" -Context "Packet.working_state") -Context "Packet.working_state.artifact_refs" -AllowEmpty | Out-Null
    $updatedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $WorkingState -Name "last_local_update_at" -Context "Packet.working_state") -Context "Packet.working_state.last_local_update_at"
    Assert-RegexMatch -Value $updatedAt -Pattern $Foundation.timestamp_pattern -Context "Packet.working_state.last_local_update_at"
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $WorkingState -Name "notes" -Context "Packet.working_state") -Context "Packet.working_state.notes" | Out-Null
}

function Validate-AcceptedState {
    param(
        [Parameter(Mandatory = $true)]
        $AcceptedState,
        [Parameter(Mandatory = $true)]
        $Foundation
    )

    foreach ($fieldName in $Foundation.accepted_state_required_fields) {
        Get-RequiredProperty -Object $AcceptedState -Name $fieldName -Context "Packet.accepted_state" | Out-Null
    }

    $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $AcceptedState -Name "status" -Context "Packet.accepted_state") -Context "Packet.accepted_state.status"
    Assert-AllowedValue -Value $status -AllowedValues @($Foundation.allowed_accepted_state_statuses) -Context "Packet.accepted_state.status"

    $acceptedStage = Get-RequiredProperty -Object $AcceptedState -Name "accepted_stage" -Context "Packet.accepted_state"
    $acceptedStageValue = Assert-NullableString -Value $acceptedStage -Context "Packet.accepted_state.accepted_stage"
    if ($null -ne $acceptedStageValue) {
        Assert-AllowedValue -Value $acceptedStageValue -AllowedValues @($Foundation.allowed_stages) -Context "Packet.accepted_state.accepted_stage"
    }

    $artifactRefs = Assert-StringArray -Value (Get-RequiredProperty -Object $AcceptedState -Name "artifact_refs" -Context "Packet.accepted_state") -Context "Packet.accepted_state.artifact_refs" -AllowEmpty
    $acceptedAt = Get-RequiredProperty -Object $AcceptedState -Name "accepted_at" -Context "Packet.accepted_state"
    $acceptedAtValue = Assert-NullableString -Value $acceptedAt -Context "Packet.accepted_state.accepted_at"
    if ($null -ne $acceptedAtValue) {
        Assert-RegexMatch -Value $acceptedAtValue -Pattern $Foundation.timestamp_pattern -Context "Packet.accepted_state.accepted_at"
    }
    $acceptedBy = Get-RequiredProperty -Object $AcceptedState -Name "accepted_by" -Context "Packet.accepted_state"
    $acceptedByValue = Assert-NullableString -Value $acceptedBy -Context "Packet.accepted_state.accepted_by"
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $AcceptedState -Name "notes" -Context "Packet.accepted_state") -Context "Packet.accepted_state.notes" | Out-Null

    if ($status -eq "none") {
        if ($null -ne $acceptedStageValue -or $artifactRefs.Count -ne 0 -or $null -ne $acceptedAtValue -or $null -ne $acceptedByValue) {
            throw "Packet.accepted_state with status 'none' must have null stage and acceptance metadata, and an empty artifact_refs array."
        }
    }
    else {
        if ($null -eq $acceptedStageValue -or $artifactRefs.Count -eq 0 -or $null -eq $acceptedAtValue -or $null -eq $acceptedByValue) {
            throw "Packet.accepted_state with status '$status' requires accepted_stage, artifact_refs, accepted_at, and accepted_by."
        }
    }
}

function Validate-ReconciliationState {
    param(
        [Parameter(Mandatory = $true)]
        $ReconciliationState,
        [Parameter(Mandatory = $true)]
        $Foundation
    )

    foreach ($fieldName in $Foundation.reconciliation_state_required_fields) {
        Get-RequiredProperty -Object $ReconciliationState -Name $fieldName -Context "Packet.reconciliation_state" | Out-Null
    }

    $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ReconciliationState -Name "status" -Context "Packet.reconciliation_state") -Context "Packet.reconciliation_state.status"
    Assert-AllowedValue -Value $status -AllowedValues @($Foundation.allowed_reconciliation_statuses) -Context "Packet.reconciliation_state.status"

    $comparedAt = Get-RequiredProperty -Object $ReconciliationState -Name "compared_at" -Context "Packet.reconciliation_state"
    $comparedAtValue = Assert-NullableString -Value $comparedAt -Context "Packet.reconciliation_state.compared_at"
    if ($null -ne $comparedAtValue) {
        Assert-RegexMatch -Value $comparedAtValue -Pattern $Foundation.timestamp_pattern -Context "Packet.reconciliation_state.compared_at"
    }

    $workingMatchesAccepted = Assert-NullableBoolean -Value (Get-RequiredProperty -Object $ReconciliationState -Name "working_matches_accepted" -Context "Packet.reconciliation_state") -Context "Packet.reconciliation_state.working_matches_accepted"
    $gitHeadMatchesAccepted = Assert-NullableBoolean -Value (Get-RequiredProperty -Object $ReconciliationState -Name "git_head_matches_accepted" -Context "Packet.reconciliation_state") -Context "Packet.reconciliation_state.git_head_matches_accepted"
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ReconciliationState -Name "notes" -Context "Packet.reconciliation_state") -Context "Packet.reconciliation_state.notes" | Out-Null

    if ($status -eq "not_started") {
        if ($null -ne $comparedAtValue -or $null -ne $workingMatchesAccepted -or $null -ne $gitHeadMatchesAccepted) {
            throw "Packet.reconciliation_state with status 'not_started' must keep compared_at and comparison flags null."
        }
    }
    elseif ($status -eq "pending") {
        if ($null -eq $comparedAtValue) {
            throw "Packet.reconciliation_state with status 'pending' requires compared_at."
        }
    }
    else {
        if ($null -eq $comparedAtValue -or $null -eq $workingMatchesAccepted -or $null -eq $gitHeadMatchesAccepted) {
            throw "Packet.reconciliation_state with status '$status' requires compared_at and both comparison flags."
        }
    }
}

function Validate-PacketRecordFields {
    param(
        [Parameter(Mandatory = $true)]
        $PacketRecord
    )

    $foundation = Get-FoundationContract
    $packetContract = Get-PacketRecordContract

    foreach ($fieldName in $foundation.required_fields) {
        Get-RequiredProperty -Object $PacketRecord -Name $fieldName -Context "Packet" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $PacketRecord -Name "contract_version" -Context "Packet") -Context "Packet.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "Packet.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $PacketRecord -Name "record_type" -Context "Packet") -Context "Packet.record_type"
    if ($recordType -ne $foundation.record_type -or $recordType -ne $packetContract.record_type) {
        throw "Packet.record_type must equal '$($foundation.record_type)'."
    }

    $packetId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $PacketRecord -Name "packet_id" -Context "Packet") -Context "Packet.packet_id"
    Assert-RegexMatch -Value $packetId -Pattern $foundation.identifier_pattern -Context "Packet.packet_id"

    $createdAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $PacketRecord -Name "created_at" -Context "Packet") -Context "Packet.created_at"
    Assert-RegexMatch -Value $createdAt -Pattern $foundation.timestamp_pattern -Context "Packet.created_at"
    $updatedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $PacketRecord -Name "updated_at" -Context "Packet") -Context "Packet.updated_at"
    Assert-RegexMatch -Value $updatedAt -Pattern $foundation.timestamp_pattern -Context "Packet.updated_at"

    $currentStage = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $PacketRecord -Name "current_stage" -Context "Packet") -Context "Packet.current_stage"
    Assert-AllowedValue -Value $currentStage -AllowedValues @($foundation.allowed_stages) -Context "Packet.current_stage"

    $stageProgression = Assert-ObjectArray -Value (Get-RequiredProperty -Object $PacketRecord -Name "stage_progression" -Context "Packet") -Context "Packet.stage_progression"
    Validate-StageProgression -StageProgression $stageProgression -Foundation $foundation
    $lastProgressionStage = $stageProgression[-1].stage
    if ($currentStage -ne $lastProgressionStage) {
        throw "Packet.current_stage must match the stage of the last Packet.stage_progression entry."
    }

    $approvalState = Assert-ObjectValue -Value (Get-RequiredProperty -Object $PacketRecord -Name "approval_state" -Context "Packet") -Context "Packet.approval_state"
    Validate-ApprovalState -ApprovalState $approvalState -Foundation $foundation

    $artifactRefs = Assert-ObjectArray -Value (Get-RequiredProperty -Object $PacketRecord -Name "artifact_refs" -Context "Packet") -Context "Packet.artifact_refs" -AllowEmpty
    Validate-ArtifactRefs -ArtifactRefs $artifactRefs -Foundation $foundation

    $gitRefs = Assert-ObjectValue -Value (Get-RequiredProperty -Object $PacketRecord -Name "git_refs" -Context "Packet") -Context "Packet.git_refs"
    Validate-GitRefs -GitRefs $gitRefs -Foundation $foundation

    $workingState = Assert-ObjectValue -Value (Get-RequiredProperty -Object $PacketRecord -Name "working_state" -Context "Packet") -Context "Packet.working_state"
    Validate-WorkingState -WorkingState $workingState -Foundation $foundation

    $acceptedState = Assert-ObjectValue -Value (Get-RequiredProperty -Object $PacketRecord -Name "accepted_state" -Context "Packet") -Context "Packet.accepted_state"
    Validate-AcceptedState -AcceptedState $acceptedState -Foundation $foundation

    $reconciliationState = Assert-ObjectValue -Value (Get-RequiredProperty -Object $PacketRecord -Name "reconciliation_state" -Context "Packet") -Context "Packet.reconciliation_state"
    Validate-ReconciliationState -ReconciliationState $reconciliationState -Foundation $foundation

    $workingCurrentStage = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $workingState -Name "current_stage" -Context "Packet.working_state") -Context "Packet.working_state.current_stage"
    if ($workingCurrentStage -ne $currentStage) {
        throw "Packet.working_state.current_stage must match Packet.current_stage."
    }

    foreach ($artifactRef in (Get-RequiredProperty -Object $workingState -Name "artifact_refs" -Context "Packet.working_state")) {
        if (@($PacketRecord.artifact_refs.ref) -notcontains $artifactRef) {
            throw "Packet.working_state.artifact_refs contains '$artifactRef' which is not present in Packet.artifact_refs."
        }
    }

    foreach ($artifactRef in (Get-RequiredProperty -Object $acceptedState -Name "artifact_refs" -Context "Packet.accepted_state")) {
        if (@($PacketRecord.artifact_refs.ref) -notcontains $artifactRef) {
            throw "Packet.accepted_state.artifact_refs contains '$artifactRef' which is not present in Packet.artifact_refs."
        }
    }

    return [pscustomobject]@{
        IsValid   = $true
        PacketId  = $packetId
        Stage     = $currentStage
    }
}

function Test-PacketRecordContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PacketRecordPath
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $PacketRecordPath -Label "Packet record path"
    $packetRecord = Get-JsonDocument -Path $resolvedPath -Label "Packet record"
    $result = Validate-PacketRecordFields -PacketRecord $packetRecord

    return [pscustomobject]@{
        IsValid         = $result.IsValid
        PacketId        = $result.PacketId
        Stage           = $result.Stage
        PacketRecordPath = $resolvedPath
    }
}

function New-PacketRecord {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PacketId,
        [string]$InitialStage = "intake",
        [datetime]$CreatedAt = (Get-Date).ToUniversalTime()
    )

    $foundation = Get-FoundationContract
    Assert-RegexMatch -Value $PacketId -Pattern $foundation.identifier_pattern -Context "PacketId"
    Assert-AllowedValue -Value $InitialStage -AllowedValues @($foundation.allowed_stages) -Context "InitialStage"

    $createdAtValue = Get-UtcTimestamp -Value $CreatedAt.ToUniversalTime()

    $packetRecord = [pscustomobject]@{
        contract_version    = $foundation.contract_version
        record_type         = $foundation.record_type
        packet_id           = $PacketId
        created_at          = $createdAtValue
        updated_at          = $createdAtValue
        current_stage       = $InitialStage
        stage_progression   = @(
            [pscustomobject]@{
                stage        = $InitialStage
                status       = "active"
                entered_at   = $createdAtValue
                artifact_ref = $null
                notes        = "Packet record created."
            }
        )
        approval_state      = [pscustomobject]@{
            mode  = "required"
            status = "pending"
            by    = $null
            at    = $null
            notes = "Approval not yet recorded."
        }
        artifact_refs       = @()
        git_refs            = [pscustomobject]@{
            branch           = $null
            head_commit      = $null
            accepted_commit  = $null
            accepted_tag     = $null
            last_observed_at = $null
        }
        working_state       = [pscustomobject]@{
            status               = "in_progress"
            current_stage        = $InitialStage
            artifact_refs        = @()
            last_local_update_at = $createdAtValue
            notes                = "Working state initialized."
        }
        accepted_state      = [pscustomobject]@{
            status         = "none"
            accepted_stage = $null
            artifact_refs  = @()
            accepted_at    = $null
            accepted_by    = $null
            notes          = "No accepted state recorded."
        }
        reconciliation_state = [pscustomobject]@{
            status                    = "not_started"
            compared_at               = $null
            working_matches_accepted  = $null
            git_head_matches_accepted = $null
            notes                     = "Reconciliation not started."
        }
    }

    Validate-PacketRecordFields -PacketRecord $packetRecord | Out-Null
    return $packetRecord
}

function Add-PacketRecordArtifactRef {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $PacketRecord,
        [Parameter(Mandatory = $true)]
        [string]$Stage,
        [Parameter(Mandatory = $true)]
        [string]$Ref,
        [string]$Kind = "stage_artifact",
        [string]$View = "working",
        [datetime]$AddedAt = (Get-Date).ToUniversalTime(),
        [string]$Notes = "Artifact reference recorded."
    )

    $foundation = Get-FoundationContract
    Assert-AllowedValue -Value $Stage -AllowedValues @($foundation.allowed_stages) -Context "Stage"
    Assert-AllowedValue -Value $Kind -AllowedValues @($foundation.allowed_artifact_ref_kinds) -Context "Kind"
    Assert-AllowedValue -Value $View -AllowedValues @($foundation.allowed_artifact_ref_views) -Context "View"

    $existingRefs = @($PacketRecord.artifact_refs)
    $existingRefs += [pscustomobject]@{
        stage    = $Stage
        ref      = $Ref
        kind     = $Kind
        view     = $View
        added_at = (Get-UtcTimestamp -Value $AddedAt.ToUniversalTime())
        notes    = $Notes
    }

    $PacketRecord.artifact_refs = $existingRefs
    $PacketRecord.updated_at = Get-UtcTimestamp
    Validate-PacketRecordFields -PacketRecord $PacketRecord | Out-Null
    return $PacketRecord
}

function Set-PacketRecordCurrentStage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $PacketRecord,
        [Parameter(Mandatory = $true)]
        [string]$Stage,
        [string]$Status = "active",
        [AllowNull()]
        [string]$ArtifactRef = $null,
        [datetime]$ChangedAt = (Get-Date).ToUniversalTime(),
        [string]$Notes = "Stage progression updated."
    )

    $foundation = Get-FoundationContract
    Assert-AllowedValue -Value $Stage -AllowedValues @($foundation.allowed_stages) -Context "Stage"
    Assert-AllowedValue -Value $Status -AllowedValues @($foundation.allowed_stage_statuses) -Context "Status"

    $changedAtValue = Get-UtcTimestamp -Value $ChangedAt.ToUniversalTime()
    $stageHistory = @($PacketRecord.stage_progression)
    $stageHistory += [pscustomobject]@{
        stage        = $Stage
        status       = $Status
        entered_at   = $changedAtValue
        artifact_ref = $ArtifactRef
        notes        = $Notes
    }

    $PacketRecord.stage_progression = $stageHistory
    $PacketRecord.current_stage = $Stage
    $PacketRecord.updated_at = $changedAtValue
    $PacketRecord.working_state.current_stage = $Stage
    $PacketRecord.working_state.last_local_update_at = $changedAtValue
    Validate-PacketRecordFields -PacketRecord $PacketRecord | Out-Null
    return $PacketRecord
}

function Set-PacketRecordApprovalState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $PacketRecord,
        [Parameter(Mandatory = $true)]
        [string]$Mode,
        [Parameter(Mandatory = $true)]
        [string]$Status,
        [AllowNull()]
        [string]$By = $null,
        [AllowNull()]
        [datetime]$At = $null,
        [string]$Notes = "Approval state updated."
    )

    $PacketRecord.approval_state.mode = $Mode
    $PacketRecord.approval_state.status = $Status
    $PacketRecord.approval_state.by = $By
    if ($null -eq $At) {
        $PacketRecord.approval_state.at = $null
    }
    else {
        $PacketRecord.approval_state.at = Get-UtcTimestamp -Value $At.ToUniversalTime()
    }
    $PacketRecord.approval_state.notes = $Notes
    $PacketRecord.updated_at = Get-UtcTimestamp
    Validate-PacketRecordFields -PacketRecord $PacketRecord | Out-Null
    return $PacketRecord
}

function Set-PacketRecordGitRefs {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $PacketRecord,
        [AllowNull()]
        [string]$Branch = $null,
        [AllowNull()]
        [string]$HeadCommit = $null,
        [AllowNull()]
        [string]$AcceptedCommit = $null,
        [AllowNull()]
        [string]$AcceptedTag = $null,
        [AllowNull()]
        [datetime]$ObservedAt = $null
    )

    $PacketRecord.git_refs.branch = Convert-BlankStringToNull -Value $Branch
    $PacketRecord.git_refs.head_commit = Convert-BlankStringToNull -Value $HeadCommit
    $PacketRecord.git_refs.accepted_commit = Convert-BlankStringToNull -Value $AcceptedCommit
    $PacketRecord.git_refs.accepted_tag = Convert-BlankStringToNull -Value $AcceptedTag
    if ($null -eq $ObservedAt) {
        $PacketRecord.git_refs.last_observed_at = $null
    }
    else {
        $PacketRecord.git_refs.last_observed_at = Get-UtcTimestamp -Value $ObservedAt.ToUniversalTime()
    }
    $PacketRecord.updated_at = Get-UtcTimestamp
    Validate-PacketRecordFields -PacketRecord $PacketRecord | Out-Null
    return $PacketRecord
}

function Set-PacketRecordWorkingState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $PacketRecord,
        [Parameter(Mandatory = $true)]
        [string]$Status,
        [Parameter(Mandatory = $true)]
        [string[]]$ArtifactRefs,
        [datetime]$UpdatedAt = (Get-Date).ToUniversalTime(),
        [string]$Notes = "Working state updated."
    )

    $PacketRecord.working_state.status = $Status
    $PacketRecord.working_state.current_stage = $PacketRecord.current_stage
    $PacketRecord.working_state.artifact_refs = @($ArtifactRefs)
    $PacketRecord.working_state.last_local_update_at = Get-UtcTimestamp -Value $UpdatedAt.ToUniversalTime()
    $PacketRecord.working_state.notes = $Notes
    $PacketRecord.updated_at = Get-UtcTimestamp -Value $UpdatedAt.ToUniversalTime()
    Validate-PacketRecordFields -PacketRecord $PacketRecord | Out-Null
    return $PacketRecord
}

function Set-PacketRecordAcceptedState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $PacketRecord,
        [Parameter(Mandatory = $true)]
        [string]$Status,
        [AllowNull()]
        [string]$AcceptedStage = $null,
        [string[]]$ArtifactRefs = @(),
        [AllowNull()]
        [datetime]$AcceptedAt = $null,
        [AllowNull()]
        [string]$AcceptedBy = $null,
        [string]$Notes = "Accepted state updated."
    )

    $PacketRecord.accepted_state.status = $Status
    $PacketRecord.accepted_state.accepted_stage = $AcceptedStage
    $PacketRecord.accepted_state.artifact_refs = @($ArtifactRefs)
    if ($null -eq $AcceptedAt) {
        $PacketRecord.accepted_state.accepted_at = $null
    }
    else {
        $PacketRecord.accepted_state.accepted_at = Get-UtcTimestamp -Value $AcceptedAt.ToUniversalTime()
    }
    $PacketRecord.accepted_state.accepted_by = $AcceptedBy
    $PacketRecord.accepted_state.notes = $Notes
    $PacketRecord.updated_at = Get-UtcTimestamp
    Validate-PacketRecordFields -PacketRecord $PacketRecord | Out-Null
    return $PacketRecord
}

function Set-PacketRecordReconciliationState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $PacketRecord,
        [Parameter(Mandatory = $true)]
        [string]$Status,
        [AllowNull()]
        [datetime]$ComparedAt = $null,
        [AllowNull()]
        [bool]$WorkingMatchesAccepted = $null,
        [AllowNull()]
        [bool]$GitHeadMatchesAccepted = $null,
        [string]$Notes = "Reconciliation state updated."
    )

    $PacketRecord.reconciliation_state.status = $Status
    if ($null -eq $ComparedAt) {
        $PacketRecord.reconciliation_state.compared_at = $null
    }
    else {
        $PacketRecord.reconciliation_state.compared_at = Get-UtcTimestamp -Value $ComparedAt.ToUniversalTime()
    }
    $PacketRecord.reconciliation_state.working_matches_accepted = $WorkingMatchesAccepted
    $PacketRecord.reconciliation_state.git_head_matches_accepted = $GitHeadMatchesAccepted
    $PacketRecord.reconciliation_state.notes = $Notes
    $PacketRecord.updated_at = Get-UtcTimestamp
    Validate-PacketRecordFields -PacketRecord $PacketRecord | Out-Null
    return $PacketRecord
}

function Save-PacketRecord {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $PacketRecord,
        [string]$StorePath
    )

    Validate-PacketRecordFields -PacketRecord $PacketRecord | Out-Null
    $finalStorePath = Get-PacketStorePath -StorePath $StorePath
    if (-not (Test-Path -LiteralPath $finalStorePath)) {
        New-Item -ItemType Directory -Path $finalStorePath -Force | Out-Null
    }

    $packetId = Get-RequiredProperty -Object $PacketRecord -Name "packet_id" -Context "Packet"
    $filePath = Join-Path $finalStorePath ("{0}.json" -f $packetId)
    $PacketRecord | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $filePath -Encoding UTF8

    return $filePath
}

function Get-PacketRecord {
    [CmdletBinding(DefaultParameterSetName = "ByPacketId")]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = "ByPacketId")]
        [string]$PacketId,
        [Parameter(ParameterSetName = "ByPacketId")]
        [string]$StorePath,
        [Parameter(Mandatory = $true, ParameterSetName = "ByPath")]
        [string]$Path
    )

    if ($PSCmdlet.ParameterSetName -eq "ByPath") {
        $resolvedPath = Resolve-ExistingPath -PathValue $Path -Label "Packet record path"
    }
    else {
        $finalStorePath = Get-PacketStorePath -StorePath $StorePath
        $resolvedPath = Resolve-ExistingPath -PathValue (Join-Path $finalStorePath ("{0}.json" -f $PacketId)) -Label "Packet record path"
    }

    $packetRecord = Get-JsonDocument -Path $resolvedPath -Label "Packet record"
    Validate-PacketRecordFields -PacketRecord $packetRecord | Out-Null
    return $packetRecord
}

Export-ModuleMember -Function Test-PacketRecordContract, New-PacketRecord, Save-PacketRecord, Get-PacketRecord, Add-PacketRecordArtifactRef, Set-PacketRecordCurrentStage, Set-PacketRecordApprovalState, Set-PacketRecordGitRefs, Set-PacketRecordWorkingState, Set-PacketRecordAcceptedState, Set-PacketRecordReconciliationState
