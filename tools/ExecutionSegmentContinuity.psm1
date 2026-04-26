Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot

function Get-RepositoryRoot {
    return $repoRoot
}

function Get-ModuleRepositoryRootPath {
    return (Resolve-Path -LiteralPath (Get-RepositoryRoot)).Path
}

function Resolve-PathValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [string]$AnchorPath = (Get-ModuleRepositoryRootPath)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    $resolvedAnchorPath = if (Test-Path -LiteralPath $AnchorPath) {
        (Resolve-Path -LiteralPath $AnchorPath).Path
    }
    else {
        [System.IO.Path]::GetFullPath($AnchorPath)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $resolvedAnchorPath $PathValue))
}

function Resolve-ExistingPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [string]$AnchorPath = (Get-ModuleRepositoryRootPath)
    )

    $resolvedPath = Resolve-PathValue -PathValue $PathValue -AnchorPath $AnchorPath
    if (-not (Test-Path -LiteralPath $resolvedPath)) {
        throw "$Label '$PathValue' does not exist."
    }

    return (Resolve-Path -LiteralPath $resolvedPath).Path
}

function Assert-DurableArtifactReference {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Reference,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Reference -match '(?i)(chat|transcript|conversation)') {
        throw "$Context must reference durable repo artifacts, not chat memory."
    }
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

    return [bool]$Value
}

function Assert-IntegerValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [int]$Minimum = 1,
        [int]$Maximum = [int]::MaxValue
    )

    if ($Value -isnot [int] -and $Value -isnot [long]) {
        throw "$Context must be an integer."
    }

    $integerValue = [int]$Value
    if ($integerValue -lt $Minimum -or $integerValue -gt $Maximum) {
        throw "$Context must be between $Minimum and $Maximum."
    }

    return $integerValue
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

function Assert-RequiredObjectFields {
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        [string[]]$FieldNames,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-ObjectValue -Value $Object -Context $Context | Out-Null
    foreach ($fieldName in $FieldNames) {
        Get-RequiredProperty -Object $Object -Name $fieldName -Context $Context | Out-Null
    }
}

function Assert-MatchesPattern {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Pattern,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -notmatch $Pattern) {
        throw "$Context does not match required pattern '$Pattern'."
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

function Get-ExecutionSegmentsFoundationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\execution_segments\foundation.contract.json") -Label "Execution segments foundation contract"
}

function Get-ExecutionSegmentArtifactContract {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArtifactType
    )

    $contractPath = switch ($ArtifactType) {
        "execution_segment_dispatch" { "contracts\execution_segments\execution_segment_dispatch.contract.json" }
        "execution_segment_checkpoint" { "contracts\execution_segments\execution_segment_checkpoint.contract.json" }
        "execution_segment_result" { "contracts\execution_segments\execution_segment_result.contract.json" }
        "execution_segment_resume_request" { "contracts\execution_segments\execution_segment_resume_request.contract.json" }
        "execution_segment_handoff" { "contracts\execution_segments\execution_segment_handoff.contract.json" }
        default { throw "Execution segment artifact_type '$ArtifactType' is not supported." }
    }

    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) $contractPath) -Label "$ArtifactType contract"
}

function Assert-RequiredNonClaims {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$NonClaims,
        [Parameter(Mandatory = $true)]
        [string[]]$RequiredNonClaims,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($requiredNonClaim in $RequiredNonClaims) {
        if ($NonClaims -notcontains $requiredNonClaim) {
            throw "$Context non_claims must include '$requiredNonClaim'."
        }
    }
}

function Get-StringValues {
    param(
        [AllowNull()]
        $Value
    )

    if ($null -eq $Value) {
        return @()
    }

    if ($Value -is [string]) {
        return @($Value)
    }

    if ($Value -is [System.Collections.IEnumerable]) {
        $items = @()
        foreach ($item in $Value) {
            $items += @(Get-StringValues -Value $item)
        }

        return $items
    }

    if ($null -ne $Value.PSObject -and @($Value.PSObject.Properties).Count -gt 0) {
        $items = @()
        foreach ($property in $Value.PSObject.Properties) {
            $items += @(Get-StringValues -Value $property.Value)
        }

        return $items
    }

    return @()
}

function Assert-NoForbiddenPositiveClaims {
    param(
        [Parameter(Mandatory = $true)]
        $Artifact,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $forbiddenClaimPatterns = @(
        "unattended automatic resume",
        "solved Codex context compaction",
        "hours-long unattended milestone execution",
        "broad autonomous milestone execution",
        "UI or control-room productization",
        "Standard runtime",
        "multi-repo orchestration",
        "swarms or fleet execution"
    )

    foreach ($value in @(Get-StringValues -Value $Artifact)) {
        foreach ($pattern in $forbiddenClaimPatterns) {
            if ($value -match [regex]::Escape($pattern) -and $value -notmatch '(?i)\b(no|not|without|do not|does not|never)\b') {
                throw "$Context must not claim '$pattern'."
            }
        }
    }
}

function Assert-NoChatMemoryAuthorityText {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -match '(?i)(chat memory|chat transcript|conversation transcript)' -and $Value -notmatch '(?i)\b(no|not|without|do not|does not|never)\b') {
        throw "$Context must not depend on chat memory or chat transcripts as authority."
    }
}

function Resolve-RequiredRefs {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Refs,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [Parameter(Mandatory = $true)]
        [string]$AnchorPath
    )

    foreach ($ref in $Refs) {
        Assert-DurableArtifactReference -Reference $ref -Context "$Context item"
        Resolve-ExistingPath -PathValue $ref -Label "$Context item" -AnchorPath $AnchorPath | Out-Null
    }
}

function Assert-AllowedScope {
    param(
        [Parameter(Mandatory = $true)]
        $AllowedScope,
        [Parameter(Mandatory = $true)]
        [object[]]$RequiredFields,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-RequiredObjectFields -Object $AllowedScope -FieldNames $RequiredFields -Context $Context
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $AllowedScope -Name "scope_id" -Context $Context) -Context "$Context.scope_id" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $AllowedScope -Name "description" -Context $Context) -Context "$Context.description" | Out-Null
}

function Assert-ContextBudget {
    param(
        [Parameter(Mandatory = $true)]
        $ContextBudget,
        [Parameter(Mandatory = $true)]
        [object[]]$RequiredFields,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-RequiredObjectFields -Object $ContextBudget -FieldNames $RequiredFields -Context $Context
    Assert-IntegerValue -Value (Get-RequiredProperty -Object $ContextBudget -Name "max_prompt_tokens" -Context $Context) -Context "$Context.max_prompt_tokens" -Minimum 1 -Maximum $Foundation.max_context_prompt_tokens | Out-Null
    Assert-IntegerValue -Value (Get-RequiredProperty -Object $ContextBudget -Name "max_runtime_minutes" -Context $Context) -Context "$Context.max_runtime_minutes" -Minimum 1 -Maximum $Foundation.max_segment_runtime_minutes | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ContextBudget -Name "segment_boundary" -Context $Context) -Context "$Context.segment_boundary" | Out-Null
}

function Assert-SharedSegmentFields {
    param(
        [Parameter(Mandatory = $true)]
        $Artifact,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [string]$ExpectedArtifactType,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-RequiredObjectFields -Object $Artifact -FieldNames $Contract.required_fields -Context $Context

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "contract_version" -Context $Context) -Context "$Context contract_version"
    if ($contractVersion -ne $Foundation.contract_version) {
        throw "$Context contract_version must be '$($Foundation.contract_version)'."
    }

    $artifactType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "artifact_type" -Context $Context) -Context "$Context artifact_type"
    if ($artifactType -ne $ExpectedArtifactType) {
        throw "$Context artifact_type must be '$ExpectedArtifactType'."
    }

    $artifactId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "artifact_id" -Context $Context) -Context "$Context artifact_id"
    Assert-MatchesPattern -Value $artifactId -Pattern $Foundation.identifier_pattern -Context "$Context artifact_id"

    $repository = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "repository" -Context $Context) -Context "$Context repository"
    Assert-MatchesPattern -Value $repository -Pattern $Foundation.repository_name_pattern -Context "$Context repository"
    if ($repository -ne $Foundation.repository_name) {
        throw "$Context repository must be '$($Foundation.repository_name)'."
    }

    $branch = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "branch" -Context $Context) -Context "$Context branch"
    Assert-MatchesPattern -Value $branch -Pattern $Foundation.branch_pattern -Context "$Context branch"

    $milestone = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "milestone" -Context $Context) -Context "$Context milestone"
    if ($milestone -ne $Foundation.milestone_title) {
        throw "$Context milestone must be '$($Foundation.milestone_title)'."
    }

    $taskId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "task_id" -Context $Context) -Context "$Context task_id"
    Assert-MatchesPattern -Value $taskId -Pattern $Foundation.task_id_pattern -Context "$Context task_id"

    $segmentId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "segment_id" -Context $Context) -Context "$Context segment_id"
    Assert-MatchesPattern -Value $segmentId -Pattern $Foundation.identifier_pattern -Context "$Context segment_id"

    $segmentSequence = Assert-IntegerValue -Value (Get-RequiredProperty -Object $Artifact -Name "segment_sequence" -Context $Context) -Context "$Context segment_sequence"

    $baselineHead = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "baseline_head" -Context $Context) -Context "$Context baseline_head"
    $baselineTree = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "baseline_tree" -Context $Context) -Context "$Context baseline_tree"
    $currentHead = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "current_head" -Context $Context) -Context "$Context current_head"
    $currentTree = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "current_tree" -Context $Context) -Context "$Context current_tree"

    foreach ($gitObject in @(
            @{ Value = $baselineHead; Context = "$Context baseline_head" },
            @{ Value = $baselineTree; Context = "$Context baseline_tree" },
            @{ Value = $currentHead; Context = "$Context current_head" },
            @{ Value = $currentTree; Context = "$Context current_tree" }
        )) {
        Assert-MatchesPattern -Value $gitObject.Value -Pattern $Foundation.git_object_pattern -Context $gitObject.Context
    }

    $createdAtUtc = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "created_at_utc" -Context $Context) -Context "$Context created_at_utc"
    Assert-MatchesPattern -Value $createdAtUtc -Pattern $Foundation.timestamp_pattern -Context "$Context created_at_utc"

    $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "status" -Context $Context) -Context "$Context status"
    Assert-AllowedValue -Value $status -AllowedValues $Foundation.allowed_statuses -Context "$Context status"

    $nonClaims = Assert-StringArray -Value (Get-RequiredProperty -Object $Artifact -Name "non_claims" -Context $Context) -Context "$Context non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -RequiredNonClaims $Foundation.required_non_claims -Context $Context
    Assert-NoForbiddenPositiveClaims -Artifact $Artifact -Context $Context

    return [pscustomobject]@{
        ArtifactId = $artifactId
        ArtifactType = $artifactType
        Repository = $repository
        Branch = $branch
        Milestone = $milestone
        TaskId = $taskId
        SegmentId = $segmentId
        SegmentSequence = $segmentSequence
        BaselineHead = $baselineHead
        BaselineTree = $baselineTree
        CurrentHead = $currentHead
        CurrentTree = $currentTree
        Status = $status
    }
}

function Assert-SegmentIdentityMatches {
    param(
        [Parameter(Mandatory = $true)]
        $Actual,
        [Parameter(Mandatory = $true)]
        $Expected,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($propertyName in @("Repository", "Branch", "Milestone", "TaskId", "SegmentId", "SegmentSequence", "BaselineHead", "BaselineTree", "CurrentHead", "CurrentTree")) {
        if ($Actual.$propertyName -ne $Expected.$propertyName) {
            throw "$Context has contradictory repository/branch/milestone/task/segment or git identity for '$propertyName'."
        }
    }
}

function Resolve-ReferencedSegmentArtifact {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Ref,
        [Parameter(Mandatory = $true)]
        [string]$ExpectedArtifactType,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [Parameter(Mandatory = $true)]
    [string]$AnchorPath
    )

    Assert-DurableArtifactReference -Reference $Ref -Context $Context
    $resolvedPath = Resolve-ExistingPath -PathValue $Ref -Label $Context -AnchorPath $AnchorPath
    $document = Get-JsonDocument -Path $resolvedPath -Label $Context
    $artifactType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $document -Name "artifact_type" -Context $Context) -Context "$Context artifact_type"
    if ($artifactType -ne $ExpectedArtifactType) {
        throw "$Context must reference artifact_type '$ExpectedArtifactType'."
    }

    $validation = Test-ExecutionSegmentArtifactDocument -Artifact $document -SourceLabel $Context -AnchorPath (Split-Path -Parent $resolvedPath)
    return [pscustomobject]@{
        Path = $resolvedPath
        Document = $document
        Validation = $validation
    }
}

function Test-ExecutionSegmentDispatchDocument {
    param(
        [Parameter(Mandatory = $true)]
        $Dispatch,
        [Parameter(Mandatory = $true)]
        [string]$SourceLabel,
        [Parameter(Mandatory = $true)]
        [string]$AnchorPath
    )

    $foundation = Get-ExecutionSegmentsFoundationContract
    $contract = Get-ExecutionSegmentArtifactContract -ArtifactType "execution_segment_dispatch"
    $base = Assert-SharedSegmentFields -Artifact $Dispatch -Foundation $foundation -Contract $contract -ExpectedArtifactType "execution_segment_dispatch" -Context $SourceLabel

    if ($base.Status -ne "prepared") {
        throw "$SourceLabel status must be 'prepared'."
    }

    if ($base.BaselineHead -ne $base.CurrentHead -or $base.BaselineTree -ne $base.CurrentTree) {
        throw "$SourceLabel current_head/current_tree must match baseline_head/baseline_tree at dispatch."
    }

    $dispatchId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Dispatch -Name "dispatch_id" -Context $SourceLabel) -Context "$SourceLabel dispatch_id"
    Assert-MatchesPattern -Value $dispatchId -Pattern $foundation.identifier_pattern -Context "$SourceLabel dispatch_id"

    Resolve-ExistingPath -PathValue (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Dispatch -Name "source_request_ref" -Context $SourceLabel) -Context "$SourceLabel source_request_ref") -Label "$SourceLabel source_request_ref" -AnchorPath $AnchorPath | Out-Null
    Assert-AllowedScope -AllowedScope (Get-RequiredProperty -Object $Dispatch -Name "allowed_scope" -Context $SourceLabel) -RequiredFields $contract.allowed_scope_required_fields -Context "$SourceLabel allowed_scope"
    Assert-StringArray -Value (Get-RequiredProperty -Object $Dispatch -Name "allowed_files" -Context $SourceLabel) -Context "$SourceLabel allowed_files" | Out-Null
    Assert-StringArray -Value (Get-RequiredProperty -Object $Dispatch -Name "forbidden_paths" -Context $SourceLabel) -Context "$SourceLabel forbidden_paths" | Out-Null
    Assert-StringArray -Value (Get-RequiredProperty -Object $Dispatch -Name "expected_outputs" -Context $SourceLabel) -Context "$SourceLabel expected_outputs" | Out-Null
    Assert-ContextBudget -ContextBudget (Get-RequiredProperty -Object $Dispatch -Name "context_budget" -Context $SourceLabel) -RequiredFields $contract.context_budget_required_fields -Foundation $foundation -Context "$SourceLabel context_budget"
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Dispatch -Name "runner_kind" -Context $SourceLabel) -Context "$SourceLabel runner_kind" | Out-Null
    Resolve-ExistingPath -PathValue (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Dispatch -Name "operator_authority_ref" -Context $SourceLabel) -Context "$SourceLabel operator_authority_ref") -Label "$SourceLabel operator_authority_ref" -AnchorPath $AnchorPath | Out-Null
    Assert-StringArray -Value (Get-RequiredProperty -Object $Dispatch -Name "refusal_conditions" -Context $SourceLabel) -Context "$SourceLabel refusal_conditions" | Out-Null

    return $base
}

function Test-ExecutionSegmentCheckpointDocument {
    param(
        [Parameter(Mandatory = $true)]
        $Checkpoint,
        [Parameter(Mandatory = $true)]
        [string]$SourceLabel,
        [Parameter(Mandatory = $true)]
        [string]$AnchorPath
    )

    $foundation = Get-ExecutionSegmentsFoundationContract
    $contract = Get-ExecutionSegmentArtifactContract -ArtifactType "execution_segment_checkpoint"
    $base = Assert-SharedSegmentFields -Artifact $Checkpoint -Foundation $foundation -Contract $contract -ExpectedArtifactType "execution_segment_checkpoint" -Context $SourceLabel

    if ($base.Status -ne "checkpointed") {
        throw "$SourceLabel status must be 'checkpointed'."
    }

    $checkpointId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Checkpoint -Name "checkpoint_id" -Context $SourceLabel) -Context "$SourceLabel checkpoint_id"
    Assert-MatchesPattern -Value $checkpointId -Pattern $foundation.identifier_pattern -Context "$SourceLabel checkpoint_id"

    $dispatchRef = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Checkpoint -Name "dispatch_ref" -Context $SourceLabel) -Context "$SourceLabel dispatch_ref"
    $dispatch = Resolve-ReferencedSegmentArtifact -Ref $dispatchRef -ExpectedArtifactType "execution_segment_dispatch" -Context "$SourceLabel dispatch_ref" -AnchorPath $AnchorPath
    Assert-SegmentIdentityMatches -Actual $base -Expected $dispatch.Validation -Context "$SourceLabel dispatch_ref"

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Checkpoint -Name "checkpoint_reason" -Context $SourceLabel) -Context "$SourceLabel checkpoint_reason" | Out-Null
    Assert-StringArray -Value (Get-RequiredProperty -Object $Checkpoint -Name "completed_steps" -Context $SourceLabel) -Context "$SourceLabel completed_steps" | Out-Null
    Assert-StringArray -Value (Get-RequiredProperty -Object $Checkpoint -Name "remaining_steps" -Context $SourceLabel) -Context "$SourceLabel remaining_steps" | Out-Null
    Resolve-RequiredRefs -Refs (Assert-StringArray -Value (Get-RequiredProperty -Object $Checkpoint -Name "produced_artifact_refs" -Context $SourceLabel) -Context "$SourceLabel produced_artifact_refs") -Context "$SourceLabel produced_artifact_refs" -AnchorPath $AnchorPath
    Resolve-RequiredRefs -Refs (Assert-StringArray -Value (Get-RequiredProperty -Object $Checkpoint -Name "evidence_refs" -Context $SourceLabel) -Context "$SourceLabel evidence_refs") -Context "$SourceLabel evidence_refs" -AnchorPath $AnchorPath

    $workspaceState = Get-RequiredProperty -Object $Checkpoint -Name "workspace_state" -Context $SourceLabel
    Assert-RequiredObjectFields -Object $workspaceState -FieldNames $contract.workspace_state_required_fields -Context "$SourceLabel workspace_state"
    $state = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $workspaceState -Name "state" -Context "$SourceLabel workspace_state") -Context "$SourceLabel workspace_state.state"
    Assert-AllowedValue -Value $state -AllowedValues $foundation.allowed_workspace_states -Context "$SourceLabel workspace_state.state"
    $durableStateWritten = Assert-BooleanValue -Value (Get-RequiredProperty -Object $workspaceState -Name "durable_state_written" -Context "$SourceLabel workspace_state") -Context "$SourceLabel workspace_state.durable_state_written"
    if (-not $durableStateWritten) {
        throw "$SourceLabel workspace_state.durable_state_written must be true."
    }
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $workspaceState -Name "notes" -Context "$SourceLabel workspace_state") -Context "$SourceLabel workspace_state.notes" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Checkpoint -Name "next_action" -Context $SourceLabel) -Context "$SourceLabel next_action" | Out-Null

    return $base
}

function Test-ExecutionSegmentResultDocument {
    param(
        [Parameter(Mandatory = $true)]
        $Result,
        [Parameter(Mandatory = $true)]
        [string]$SourceLabel,
        [Parameter(Mandatory = $true)]
        [string]$AnchorPath
    )

    $foundation = Get-ExecutionSegmentsFoundationContract
    $contract = Get-ExecutionSegmentArtifactContract -ArtifactType "execution_segment_result"
    $base = Assert-SharedSegmentFields -Artifact $Result -Foundation $foundation -Contract $contract -ExpectedArtifactType "execution_segment_result" -Context $SourceLabel

    $resultId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "result_id" -Context $SourceLabel) -Context "$SourceLabel result_id"
    Assert-MatchesPattern -Value $resultId -Pattern $foundation.identifier_pattern -Context "$SourceLabel result_id"

    $dispatch = Resolve-ReferencedSegmentArtifact -Ref (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "dispatch_ref" -Context $SourceLabel) -Context "$SourceLabel dispatch_ref") -ExpectedArtifactType "execution_segment_dispatch" -Context "$SourceLabel dispatch_ref" -AnchorPath $AnchorPath
    $checkpoint = Resolve-ReferencedSegmentArtifact -Ref (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "checkpoint_ref" -Context $SourceLabel) -Context "$SourceLabel checkpoint_ref") -ExpectedArtifactType "execution_segment_checkpoint" -Context "$SourceLabel checkpoint_ref" -AnchorPath $AnchorPath
    Assert-SegmentIdentityMatches -Actual $base -Expected $dispatch.Validation -Context "$SourceLabel dispatch_ref"
    Assert-SegmentIdentityMatches -Actual $base -Expected $checkpoint.Validation -Context "$SourceLabel checkpoint_ref"

    $outcome = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "outcome" -Context $SourceLabel) -Context "$SourceLabel outcome"
    Assert-AllowedValue -Value $outcome -AllowedValues $foundation.allowed_outcomes -Context "$SourceLabel outcome"

    if ($outcome -ne $base.Status) {
        throw "$SourceLabel status must match outcome '$outcome'."
    }

    Assert-StringArray -Value (Get-RequiredProperty -Object $Result -Name "changed_files" -Context $SourceLabel) -Context "$SourceLabel changed_files" -AllowEmpty | Out-Null
    Resolve-RequiredRefs -Refs (Assert-StringArray -Value (Get-RequiredProperty -Object $Result -Name "produced_artifact_refs" -Context $SourceLabel) -Context "$SourceLabel produced_artifact_refs") -Context "$SourceLabel produced_artifact_refs" -AnchorPath $AnchorPath
    Resolve-RequiredRefs -Refs (Assert-StringArray -Value (Get-RequiredProperty -Object $Result -Name "test_refs" -Context $SourceLabel) -Context "$SourceLabel test_refs" -AllowEmpty) -Context "$SourceLabel test_refs" -AnchorPath $AnchorPath
    $evidenceRefs = Assert-StringArray -Value (Get-RequiredProperty -Object $Result -Name "evidence_refs" -Context $SourceLabel) -Context "$SourceLabel evidence_refs" -AllowEmpty
    if ($outcome -eq "completed" -and $evidenceRefs.Count -eq 0) {
        throw "$SourceLabel evidence_refs must not be empty when outcome is 'completed'."
    }
    Resolve-RequiredRefs -Refs $evidenceRefs -Context "$SourceLabel evidence_refs" -AnchorPath $AnchorPath

    Assert-BooleanValue -Value (Get-RequiredProperty -Object $Result -Name "next_segment_required" -Context $SourceLabel) -Context "$SourceLabel next_segment_required" | Out-Null
    $refusalReasons = Assert-StringArray -Value (Get-RequiredProperty -Object $Result -Name "refusal_reasons" -Context $SourceLabel) -Context "$SourceLabel refusal_reasons" -AllowEmpty
    if ($outcome -eq "completed" -or $outcome -eq "checkpointed") {
        if ($refusalReasons.Count -ne 0) {
            throw "$SourceLabel refusal_reasons must be empty when outcome is '$outcome'."
        }
    }
    elseif ($refusalReasons.Count -eq 0) {
        throw "$SourceLabel refusal_reasons must not be empty when outcome is '$outcome'."
    }

    return $base
}

function Test-ExecutionSegmentResumeRequestDocument {
    param(
        [Parameter(Mandatory = $true)]
        $ResumeRequest,
        [Parameter(Mandatory = $true)]
        [string]$SourceLabel,
        [Parameter(Mandatory = $true)]
        [string]$AnchorPath
    )

    $foundation = Get-ExecutionSegmentsFoundationContract
    $contract = Get-ExecutionSegmentArtifactContract -ArtifactType "execution_segment_resume_request"
    $base = Assert-SharedSegmentFields -Artifact $ResumeRequest -Foundation $foundation -Contract $contract -ExpectedArtifactType "execution_segment_resume_request" -Context $SourceLabel

    if ($base.Status -ne "prepared") {
        throw "$SourceLabel status must be 'prepared'."
    }

    $resumeRequestId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ResumeRequest -Name "resume_request_id" -Context $SourceLabel) -Context "$SourceLabel resume_request_id"
    Assert-MatchesPattern -Value $resumeRequestId -Pattern $foundation.identifier_pattern -Context "$SourceLabel resume_request_id"

    $priorResult = Resolve-ReferencedSegmentArtifact -Ref (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ResumeRequest -Name "prior_segment_result_ref" -Context $SourceLabel) -Context "$SourceLabel prior_segment_result_ref") -ExpectedArtifactType "execution_segment_result" -Context "$SourceLabel prior_segment_result_ref" -AnchorPath $AnchorPath
    $priorCheckpoint = Resolve-ReferencedSegmentArtifact -Ref (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ResumeRequest -Name "prior_checkpoint_ref" -Context $SourceLabel) -Context "$SourceLabel prior_checkpoint_ref") -ExpectedArtifactType "execution_segment_checkpoint" -Context "$SourceLabel prior_checkpoint_ref" -AnchorPath $AnchorPath

    if ($base.SegmentSequence -le $priorResult.Validation.SegmentSequence -or $base.SegmentSequence -le $priorCheckpoint.Validation.SegmentSequence) {
        throw "$SourceLabel segment_sequence must move forward from the prior segment."
    }

    $requestedNextSegmentId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ResumeRequest -Name "requested_next_segment_id" -Context $SourceLabel) -Context "$SourceLabel requested_next_segment_id"
    if ($requestedNextSegmentId -ne $base.SegmentId) {
        throw "$SourceLabel requested_next_segment_id must match segment_id."
    }

    if ($base.BaselineHead -ne $priorResult.Validation.BaselineHead -or $base.BaselineTree -ne $priorResult.Validation.BaselineTree) {
        throw "$SourceLabel baseline_head/baseline_tree must match prior segment result baseline."
    }

    $expectedCurrentHead = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ResumeRequest -Name "expected_current_head" -Context $SourceLabel) -Context "$SourceLabel expected_current_head"
    $expectedCurrentTree = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ResumeRequest -Name "expected_current_tree" -Context $SourceLabel) -Context "$SourceLabel expected_current_tree"
    Assert-MatchesPattern -Value $expectedCurrentHead -Pattern $foundation.git_object_pattern -Context "$SourceLabel expected_current_head"
    Assert-MatchesPattern -Value $expectedCurrentTree -Pattern $foundation.git_object_pattern -Context "$SourceLabel expected_current_tree"
    if ($expectedCurrentHead -ne $priorResult.Validation.CurrentHead -or $expectedCurrentTree -ne $priorResult.Validation.CurrentTree) {
        throw "$SourceLabel expected_current_head/expected_current_tree must match prior segment result current truth."
    }

    if ($base.CurrentHead -ne $expectedCurrentHead -or $base.CurrentTree -ne $expectedCurrentTree) {
        throw "$SourceLabel current_head/current_tree must match expected_current_head/expected_current_tree."
    }

    $resumeReason = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ResumeRequest -Name "resume_reason" -Context $SourceLabel) -Context "$SourceLabel resume_reason"
    Assert-NoChatMemoryAuthorityText -Value $resumeReason -Context "$SourceLabel resume_reason"
    Resolve-RequiredRefs -Refs (Assert-StringArray -Value (Get-RequiredProperty -Object $ResumeRequest -Name "required_artifact_refs" -Context $SourceLabel) -Context "$SourceLabel required_artifact_refs") -Context "$SourceLabel required_artifact_refs" -AnchorPath $AnchorPath
    Resolve-ExistingPath -PathValue (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ResumeRequest -Name "operator_authority_ref" -Context $SourceLabel) -Context "$SourceLabel operator_authority_ref") -Label "$SourceLabel operator_authority_ref" -AnchorPath $AnchorPath | Out-Null
    Assert-AllowedScope -AllowedScope (Get-RequiredProperty -Object $ResumeRequest -Name "allowed_scope" -Context $SourceLabel) -RequiredFields $contract.allowed_scope_required_fields -Context "$SourceLabel allowed_scope"
    Assert-StringArray -Value (Get-RequiredProperty -Object $ResumeRequest -Name "refusal_conditions" -Context $SourceLabel) -Context "$SourceLabel refusal_conditions" | Out-Null

    return $base
}

function Test-ExecutionSegmentHandoffDocument {
    param(
        [Parameter(Mandatory = $true)]
        $Handoff,
        [Parameter(Mandatory = $true)]
        [string]$SourceLabel,
        [Parameter(Mandatory = $true)]
        [string]$AnchorPath
    )

    $foundation = Get-ExecutionSegmentsFoundationContract
    $contract = Get-ExecutionSegmentArtifactContract -ArtifactType "execution_segment_handoff"
    $base = Assert-SharedSegmentFields -Artifact $Handoff -Foundation $foundation -Contract $contract -ExpectedArtifactType "execution_segment_handoff" -Context $SourceLabel

    if ($base.Status -ne "prepared") {
        throw "$SourceLabel status must be 'prepared'."
    }

    $handoffId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Handoff -Name "handoff_id" -Context $SourceLabel) -Context "$SourceLabel handoff_id"
    Assert-MatchesPattern -Value $handoffId -Pattern $foundation.identifier_pattern -Context "$SourceLabel handoff_id"

    $resumeRequest = Resolve-ReferencedSegmentArtifact -Ref (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Handoff -Name "resume_request_ref" -Context $SourceLabel) -Context "$SourceLabel resume_request_ref") -ExpectedArtifactType "execution_segment_resume_request" -Context "$SourceLabel resume_request_ref" -AnchorPath $AnchorPath

    $nextSegmentId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Handoff -Name "next_segment_id" -Context $SourceLabel) -Context "$SourceLabel next_segment_id"
    if ($nextSegmentId -ne $base.SegmentId -or $nextSegmentId -ne $resumeRequest.Document.requested_next_segment_id) {
        throw "$SourceLabel next_segment_id must match segment_id and the resume request."
    }

    if ($base.SegmentSequence -ne $resumeRequest.Validation.SegmentSequence) {
        throw "$SourceLabel segment_sequence must match the resume request for the next segment."
    }

    foreach ($propertyName in @("Repository", "Branch", "Milestone", "TaskId", "BaselineHead", "BaselineTree", "CurrentHead", "CurrentTree")) {
        if ($base.$propertyName -ne $resumeRequest.Validation.$propertyName) {
            throw "$SourceLabel has contradictory repository/branch/milestone/task or git identity for '$propertyName'."
        }
    }

    $handoffPacket = Get-RequiredProperty -Object $Handoff -Name "handoff_packet" -Context $SourceLabel
    Assert-RequiredObjectFields -Object $handoffPacket -FieldNames $contract.handoff_packet_required_fields -Context "$SourceLabel handoff_packet"
    $authorityBasis = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $handoffPacket -Name "authority_basis" -Context "$SourceLabel handoff_packet") -Context "$SourceLabel handoff_packet.authority_basis"
    if ($authorityBasis -ne $foundation.required_durable_authority_basis) {
        throw "$SourceLabel handoff_packet authority_basis must be '$($foundation.required_durable_authority_basis)'."
    }

    $chatMemoryAuthority = Assert-BooleanValue -Value (Get-RequiredProperty -Object $handoffPacket -Name "chat_memory_authority" -Context "$SourceLabel handoff_packet") -Context "$SourceLabel handoff_packet.chat_memory_authority"
    if ($chatMemoryAuthority) {
        throw "$SourceLabel handoff_packet must not use chat transcript as authority."
    }

    $handoffSummary = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $handoffPacket -Name "summary" -Context "$SourceLabel handoff_packet") -Context "$SourceLabel handoff_packet.summary"
    Assert-NoChatMemoryAuthorityText -Value $handoffSummary -Context "$SourceLabel handoff_packet.summary"

    Resolve-RequiredRefs -Refs (Assert-StringArray -Value (Get-RequiredProperty -Object $Handoff -Name "reconstructed_context_refs" -Context $SourceLabel) -Context "$SourceLabel reconstructed_context_refs") -Context "$SourceLabel reconstructed_context_refs" -AnchorPath $AnchorPath
    Assert-AllowedScope -AllowedScope (Get-RequiredProperty -Object $Handoff -Name "allowed_scope" -Context $SourceLabel) -RequiredFields $contract.allowed_scope_required_fields -Context "$SourceLabel allowed_scope"
    Resolve-RequiredRefs -Refs (Assert-StringArray -Value (Get-RequiredProperty -Object $Handoff -Name "required_inputs" -Context $SourceLabel) -Context "$SourceLabel required_inputs") -Context "$SourceLabel required_inputs" -AnchorPath $AnchorPath
    Assert-StringArray -Value (Get-RequiredProperty -Object $Handoff -Name "expected_outputs" -Context $SourceLabel) -Context "$SourceLabel expected_outputs" | Out-Null
    Assert-ContextBudget -ContextBudget (Get-RequiredProperty -Object $Handoff -Name "context_budget" -Context $SourceLabel) -RequiredFields $contract.context_budget_required_fields -Foundation $foundation -Context "$SourceLabel context_budget"

    return $base
}

function Test-ExecutionSegmentArtifactDocument {
    param(
        [Parameter(Mandatory = $true)]
        $Artifact,
        [Parameter(Mandatory = $true)]
        [string]$SourceLabel,
        [Parameter(Mandatory = $true)]
        [string]$AnchorPath
    )

    $artifactType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "artifact_type" -Context $SourceLabel) -Context "$SourceLabel artifact_type"

    switch ($artifactType) {
        "execution_segment_dispatch" {
            return Test-ExecutionSegmentDispatchDocument -Dispatch $Artifact -SourceLabel $SourceLabel -AnchorPath $AnchorPath
        }
        "execution_segment_checkpoint" {
            return Test-ExecutionSegmentCheckpointDocument -Checkpoint $Artifact -SourceLabel $SourceLabel -AnchorPath $AnchorPath
        }
        "execution_segment_result" {
            return Test-ExecutionSegmentResultDocument -Result $Artifact -SourceLabel $SourceLabel -AnchorPath $AnchorPath
        }
        "execution_segment_resume_request" {
            return Test-ExecutionSegmentResumeRequestDocument -ResumeRequest $Artifact -SourceLabel $SourceLabel -AnchorPath $AnchorPath
        }
        "execution_segment_handoff" {
            return Test-ExecutionSegmentHandoffDocument -Handoff $Artifact -SourceLabel $SourceLabel -AnchorPath $AnchorPath
        }
        default {
            throw "Execution segment artifact_type '$artifactType' is not supported."
        }
    }
}

function Test-ExecutionSegmentArtifactContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArtifactPath
    )

    $resolvedArtifactPath = Resolve-ExistingPath -PathValue $ArtifactPath -Label "Execution segment artifact"
    $artifact = Get-JsonDocument -Path $resolvedArtifactPath -Label "Execution segment artifact"
    return Test-ExecutionSegmentArtifactDocument -Artifact $artifact -SourceLabel "Execution segment artifact" -AnchorPath (Split-Path -Parent $resolvedArtifactPath)
}

Export-ModuleMember -Function Test-ExecutionSegmentArtifactContract
