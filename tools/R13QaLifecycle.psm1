Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$script:R13RepositoryName = "AIOffice_V2"
$script:R13Branch = "release/r13-api-first-qa-pipeline-and-operator-control-room-product-slice"
$script:R13Milestone = "R13 API-First QA Pipeline and Operator Control-Room Product Slice"
$script:R13SourceTask = "R13-002"
$script:GitObjectPattern = "^[a-f0-9]{40}$"
$script:TimestampPattern = "^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$"
$script:StageOrder = @{
    initialized = 0
    detected = 1
    classified = 2
    queued = 3
    fix_authorized = 4
    fix_executed = 5
    rerun = 6
    compared = 7
    signoff_ready = 8
    signed_off = 9
}

function Get-RepositoryRoot {
    return $repoRoot
}

function Join-RepositoryPath {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Segments
    )

    $path = Get-RepositoryRoot
    foreach ($segment in $Segments) {
        $path = Join-Path $path $segment
    }

    return $path
}

function Resolve-RepositoryPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path (Get-RepositoryRoot) $PathValue))
}

function Get-JsonDocument {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    return (Read-SingleJsonObject -Path $Path -Label $Label)
}

function Test-HasProperty {
    param(
        [AllowNull()]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    return $null -ne $Object -and @($Object.PSObject.Properties.Name) -contains $Name
}

function Get-RequiredProperty {
    [CmdletBinding()]
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

    $PSCmdlet.WriteObject($Object.PSObject.Properties[$Name].Value, $false)
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

function Assert-StringValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($null -eq $Value -or $Value -isnot [string]) {
        throw "$Context must be a string."
    }

    return $Value
}

function Assert-StringArray {
    [CmdletBinding()]
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

    $PSCmdlet.WriteObject($items, $false)
}

function Assert-ObjectArray {
    [CmdletBinding()]
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

    $PSCmdlet.WriteObject($items, $false)
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

function Assert-GitObjectIdWhenPopulated {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $text = Assert-StringValue -Value $Value -Context $Context
    if (-not [string]::IsNullOrWhiteSpace($text) -and $text -notmatch $script:GitObjectPattern) {
        throw "$Context must be a 40-character Git object ID when populated."
    }
}

function Assert-TimestampString {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $timestamp = Assert-NonEmptyString -Value $Value -Context $Context
    if ($timestamp -notmatch $script:TimestampPattern) {
        throw "$Context must be a UTC timestamp."
    }
}

function Assert-BoundedPathOrUrl {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -match '^https?://') {
        return
    }
    if ([System.IO.Path]::IsPathRooted($Value) -or $Value -match '(^|[\\/])\.\.([\\/]|$)') {
        throw "$Context must be a repository-relative path without traversal."
    }
}

function Assert-ExistingRef {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Ref,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-BoundedPathOrUrl -Value $Ref -Context $Context
    if ($Ref -match '^https?://') {
        return
    }
    if (-not (Test-Path -LiteralPath (Resolve-RepositoryPath -PathValue $Ref))) {
        throw "$Context '$Ref' does not exist."
    }
}

function Get-R13QaLifecycleContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "actionable_qa", "r13_qa_lifecycle.contract.json")) -Label "R13 QA lifecycle contract"
}

function Assert-RequiredNonClaims {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$NonClaims,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($requiredNonClaim in @($Contract.required_non_claims)) {
        if ($NonClaims -notcontains $requiredNonClaim) {
            throw "$Context non_claims must include '$requiredNonClaim'."
        }
    }
}

function Test-LineHasNegation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Line
    )

    return ($Line -match '(?i)\b(no|not|without|cannot|must not|does not|do not|is not|are not|non-claim|non_claim|refuse|refuses|blocked|planned only|not yet delivered)\b')
}

function Get-StringLeaves {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value
    )

    if ($null -eq $Value) {
        return
    }
    if ($Value -is [string]) {
        $PSCmdlet.WriteObject($Value, $false)
        return
    }
    if ($Value -is [System.Collections.IDictionary]) {
        foreach ($entry in $Value.GetEnumerator()) {
            Get-StringLeaves -Value $entry.Value
        }
        return
    }
    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
        foreach ($item in $Value) {
            Get-StringLeaves -Value $item
        }
        return
    }
    if ($Value -is [pscustomobject]) {
        foreach ($property in @($Value.PSObject.Properties)) {
            Get-StringLeaves -Value $property.Value
        }
    }
}

function Assert-NoSuccessorOpeningClaim {
    param(
        [Parameter(Mandatory = $true)]
        $Lifecycle,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($line in @(Get-StringLeaves -Value $Lifecycle)) {
        if ($line -match '(?i)\bR14\b.*\b(active|open|opened)\b|\bsuccessor milestone\b.*\b(active|open|opened)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims R14 or successor milestone opening. Offending text: $line"
        }
    }
}

function Test-StageAtLeast {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Stage,
        [Parameter(Mandatory = $true)]
        [string]$MinimumStage
    )

    if ($Stage -eq "blocked") {
        return $false
    }

    return ([int]$script:StageOrder[$Stage]) -ge ([int]$script:StageOrder[$MinimumStage])
}

function Get-EvidenceForReference {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$EvidenceRefs,
        [Parameter(Mandatory = $true)]
        [string]$Ref
    )

    $matches = @($EvidenceRefs | Where-Object { [string]$_.ref_id -eq $Ref -or [string]$_.ref -eq $Ref })
    foreach ($match in $matches) {
        $PSCmdlet.WriteObject($match, $false)
    }
}

function Assert-ReferenceHasEvidence {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$EvidenceRefs,
        [Parameter(Mandatory = $true)]
        [string]$Ref,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [string]$RequiredKind = "",
        [switch]$RequireExternal
    )

    Assert-NonEmptyString -Value $Ref -Context $Context | Out-Null
    $matches = @(Get-EvidenceForReference -EvidenceRefs $EvidenceRefs -Ref $Ref)
    if ($matches.Count -eq 0) {
        throw "$Context must be backed by evidence_refs."
    }
    if (-not [string]::IsNullOrWhiteSpace($RequiredKind) -and @($matches | Where-Object { [string]$_.evidence_kind -eq $RequiredKind }).Count -eq 0) {
        throw "$Context must be backed by evidence_refs of kind '$RequiredKind'."
    }
    if ($RequireExternal) {
        $externalMatches = @($matches | Where-Object { [string]$_.scope -eq "external" -and [string]$_.authority_kind -eq "external_runner" })
        if ($externalMatches.Count -eq 0) {
            throw "local-only evidence cannot be used as external replay proof."
        }
    }
}

function Assert-NoForbiddenEvidenceAuthority {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$EvidenceRefs,
        [AllowEmptyCollection()]
        [object[]]$QaChecks
    )

    foreach ($evidence in $EvidenceRefs) {
        $kind = [string]$evidence.evidence_kind
        $authority = [string]$evidence.authority_kind
        if ($kind -match '(?i)narrative|chat_transcript|narrative_only_qa') {
            throw "narrative-only QA treated as evidence is rejected."
        }
        if ($authority -match '(?i)executor_self_certification|self_certification') {
            throw "executor self-certification treated as QA authority is rejected."
        }
    }

    foreach ($check in $QaChecks) {
        $checkType = [string]$check.check_type
        $authority = [string]$check.authority_kind
        if ($checkType -match '(?i)narrative|chat_transcript|narrative_only_qa') {
            throw "narrative-only QA treated as evidence is rejected."
        }
        if ($authority -match '(?i)executor_self_certification|self_certification') {
            throw "executor self-certification treated as QA authority is rejected."
        }
    }
}

function Assert-Actors {
    param(
        [Parameter(Mandatory = $true)]
        $Actors,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-RequiredObjectFields -Object $Actors -FieldNames $Contract.actor_required_fields -Context "$Context actors"
    foreach ($actorName in @($Contract.actor_required_fields)) {
        $actor = Assert-ObjectValue -Value $Actors.$actorName -Context "$Context actors.$actorName"
        Assert-RequiredObjectFields -Object $actor -FieldNames $Contract.actor_value_required_fields -Context "$Context actors.$actorName"
        Assert-NonEmptyString -Value $actor.actor_id -Context "$Context actors.$actorName.actor_id" | Out-Null
        Assert-NonEmptyString -Value $actor.actor_kind -Context "$Context actors.$actorName.actor_kind" | Out-Null
        $authorityKind = Assert-NonEmptyString -Value $actor.authority_kind -Context "$Context actors.$actorName.authority_kind"
        if ($authorityKind -match '(?i)executor_self_certification|self_certification') {
            throw "executor self-certification treated as QA authority is rejected."
        }
    }

    if ([string]$Actors.fix_executor.actor_id -eq [string]$Actors.signoff_authority.actor_id) {
        throw "executor self-certification treated as QA authority is rejected."
    }
}

function Assert-LifecycleTransitions {
    param(
        [AllowEmptyCollection()]
        [object[]]$Transitions,
        [Parameter(Mandatory = $true)]
        [string]$LifecycleStage,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $allowedPairs = @{}
    foreach ($transitionRule in @($Contract.lifecycle_transitions)) {
        $allowedPairs["$($transitionRule.from_stage)->$($transitionRule.to_stage)"] = $true
    }

    if ($LifecycleStage -eq "initialized" -and $Transitions.Count -eq 0) {
        return
    }
    if ($LifecycleStage -ne "initialized" -and $Transitions.Count -eq 0) {
        throw "$Context lifecycle_transitions must not be empty outside initialized stage."
    }

    $previousToStage = $null
    foreach ($transition in $Transitions) {
        Assert-RequiredObjectFields -Object $transition -FieldNames $Contract.transition_required_fields -Context "$Context lifecycle_transitions"
        $fromStage = Assert-NonEmptyString -Value $transition.from_stage -Context "$Context transition.from_stage"
        $toStage = Assert-NonEmptyString -Value $transition.to_stage -Context "$Context transition.to_stage"
        Assert-AllowedValue -Value $fromStage -AllowedValues $Contract.lifecycle_stage -Context "$Context transition.from_stage"
        Assert-AllowedValue -Value $toStage -AllowedValues $Contract.lifecycle_stage -Context "$Context transition.to_stage"
        Assert-StringValue -Value $transition.evidence_ref -Context "$Context transition.evidence_ref" | Out-Null

        if (-not $allowedPairs.ContainsKey("$fromStage->$toStage") -and -not $allowedPairs.ContainsKey("*->$toStage")) {
            throw "$Context transition '$fromStage->$toStage' is not allowed."
        }
        if ($null -ne $previousToStage -and $fromStage -ne $previousToStage) {
            throw "$Context lifecycle_transitions must be contiguous."
        }
        $previousToStage = $toStage
    }

    if ($previousToStage -ne $LifecycleStage) {
        throw "$Context lifecycle_transitions final stage must match lifecycle_stage."
    }
}

function Test-R13QaLifecycleObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Lifecycle,
        [string]$SourceLabel = "R13 QA lifecycle"
    )

    $contract = Get-R13QaLifecycleContract
    Assert-RequiredObjectFields -Object $Lifecycle -FieldNames $contract.required_fields -Context $SourceLabel

    if ($Lifecycle.contract_version -ne $contract.contract_version) {
        throw "$SourceLabel contract_version must be '$($contract.contract_version)'."
    }
    if ($Lifecycle.artifact_type -ne $contract.artifact_type) {
        throw "$SourceLabel artifact_type must be '$($contract.artifact_type)'."
    }
    Assert-NonEmptyString -Value $Lifecycle.lifecycle_id -Context "$SourceLabel lifecycle_id" | Out-Null
    if ($Lifecycle.repository -ne $script:R13RepositoryName) {
        throw "$SourceLabel repository must be '$script:R13RepositoryName'."
    }
    if ($Lifecycle.branch -ne $script:R13Branch) {
        throw "$SourceLabel branch must be '$script:R13Branch'."
    }
    if ($Lifecycle.source_milestone -ne $script:R13Milestone) {
        throw "$SourceLabel source_milestone must be '$script:R13Milestone'."
    }
    if ($Lifecycle.source_task -ne $script:R13SourceTask) {
        throw "$SourceLabel source_task must be '$script:R13SourceTask'."
    }
    Assert-GitObjectIdWhenPopulated -Value $Lifecycle.head -Context "$SourceLabel head"
    Assert-GitObjectIdWhenPopulated -Value $Lifecycle.tree -Context "$SourceLabel tree"

    $qaScope = Assert-ObjectValue -Value $Lifecycle.qa_scope -Context "$SourceLabel qa_scope"
    Assert-RequiredObjectFields -Object $qaScope -FieldNames $contract.qa_scope_required_fields -Context "$SourceLabel qa_scope"
    Assert-StringArray -Value $qaScope.paths -Context "$SourceLabel qa_scope.paths" | Out-Null
    Assert-NonEmptyString -Value $qaScope.description -Context "$SourceLabel qa_scope.description" | Out-Null
    Assert-NonEmptyString -Value $qaScope.cycle_goal -Context "$SourceLabel qa_scope.cycle_goal" | Out-Null

    $stage = Assert-NonEmptyString -Value $Lifecycle.lifecycle_stage -Context "$SourceLabel lifecycle_stage"
    Assert-AllowedValue -Value $stage -AllowedValues $contract.lifecycle_stage -Context "$SourceLabel lifecycle_stage"
    $aggregateVerdict = Assert-NonEmptyString -Value $Lifecycle.aggregate_verdict -Context "$SourceLabel aggregate_verdict"
    Assert-AllowedValue -Value $aggregateVerdict -AllowedValues $contract.allowed_aggregate_verdicts -Context "$SourceLabel aggregate_verdict"

    Assert-Actors -Actors $Lifecycle.actors -Contract $contract -Context $SourceLabel

    $transitions = Assert-ObjectArray -Value $Lifecycle.lifecycle_transitions -Context "$SourceLabel lifecycle_transitions" -AllowEmpty
    Assert-LifecycleTransitions -Transitions $transitions -LifecycleStage $stage -Contract $contract -Context $SourceLabel

    $qaChecks = Assert-ObjectArray -Value $Lifecycle.qa_checks -Context "$SourceLabel qa_checks" -AllowEmpty
    foreach ($check in $qaChecks) {
        Assert-RequiredObjectFields -Object $check -FieldNames $contract.qa_check_required_fields -Context "$SourceLabel qa_check"
        Assert-NonEmptyString -Value $check.check_id -Context "$SourceLabel qa_check.check_id" | Out-Null
        Assert-NonEmptyString -Value $check.check_type -Context "$SourceLabel qa_check.check_type" | Out-Null
        Assert-NonEmptyString -Value $check.authority_kind -Context "$SourceLabel qa_check.authority_kind" | Out-Null
        $checkVerdict = Assert-NonEmptyString -Value $check.verdict -Context "$SourceLabel qa_check.verdict"
        Assert-AllowedValue -Value $checkVerdict -AllowedValues $contract.allowed_check_verdicts -Context "$SourceLabel qa_check.verdict"
        Assert-StringValue -Value $check.evidence_ref -Context "$SourceLabel qa_check.evidence_ref" | Out-Null
        Assert-StringArray -Value $check.issue_refs -Context "$SourceLabel qa_check.issue_refs" -AllowEmpty | Out-Null
    }

    $detectedIssues = Assert-ObjectArray -Value $Lifecycle.detected_issues -Context "$SourceLabel detected_issues" -AllowEmpty
    foreach ($issue in $detectedIssues) {
        Assert-RequiredObjectFields -Object $issue -FieldNames $contract.issue_required_fields -Context "$SourceLabel detected_issue"
        Assert-NonEmptyString -Value $issue.issue_id -Context "$SourceLabel detected_issue.issue_id" | Out-Null
        Assert-NonEmptyString -Value $issue.severity -Context "$SourceLabel detected_issue.severity" | Out-Null
        $blockingStatus = Assert-NonEmptyString -Value $issue.blocking_status -Context "$SourceLabel detected_issue.blocking_status"
        Assert-AllowedValue -Value $blockingStatus -AllowedValues $contract.allowed_issue_blocking_statuses -Context "$SourceLabel detected_issue.blocking_status"
        $issueStatus = Assert-NonEmptyString -Value $issue.status -Context "$SourceLabel detected_issue.status"
        Assert-AllowedValue -Value $issueStatus -AllowedValues $contract.allowed_issue_statuses -Context "$SourceLabel detected_issue.status"
        Assert-NonEmptyString -Value $issue.evidence_ref -Context "$SourceLabel detected_issue.evidence_ref" | Out-Null
    }

    $classifiedIssues = Assert-ObjectArray -Value $Lifecycle.classified_issues -Context "$SourceLabel classified_issues" -AllowEmpty
    foreach ($issue in $classifiedIssues) {
        Assert-RequiredObjectFields -Object $issue -FieldNames $contract.classified_issue_required_fields -Context "$SourceLabel classified_issue"
        Assert-NonEmptyString -Value $issue.issue_id -Context "$SourceLabel classified_issue.issue_id" | Out-Null
        Assert-NonEmptyString -Value $issue.classification -Context "$SourceLabel classified_issue.classification" | Out-Null
        $blockingStatus = Assert-NonEmptyString -Value $issue.blocking_status -Context "$SourceLabel classified_issue.blocking_status"
        Assert-AllowedValue -Value $blockingStatus -AllowedValues $contract.allowed_issue_blocking_statuses -Context "$SourceLabel classified_issue.blocking_status"
        $issueStatus = Assert-NonEmptyString -Value $issue.status -Context "$SourceLabel classified_issue.status"
        Assert-AllowedValue -Value $issueStatus -AllowedValues $contract.allowed_issue_statuses -Context "$SourceLabel classified_issue.status"
        Assert-NonEmptyString -Value $issue.detection_ref -Context "$SourceLabel classified_issue.detection_ref" | Out-Null
        Assert-NonEmptyString -Value $issue.classification_evidence_ref -Context "$SourceLabel classified_issue.classification_evidence_ref" | Out-Null
    }

    foreach ($refField in @("fix_queue_ref", "fix_execution_ref", "rerun_ref", "before_after_comparison_ref", "external_replay_ref", "signoff_ref", "operator_summary_ref")) {
        Assert-StringValue -Value $Lifecycle.$refField -Context "$SourceLabel $refField" | Out-Null
    }

    $evidenceRefs = Assert-ObjectArray -Value $Lifecycle.evidence_refs -Context "$SourceLabel evidence_refs"
    foreach ($evidence in $evidenceRefs) {
        Assert-RequiredObjectFields -Object $evidence -FieldNames $contract.evidence_ref_required_fields -Context "$SourceLabel evidence_refs"
        Assert-NonEmptyString -Value $evidence.ref_id -Context "$SourceLabel evidence_refs.ref_id" | Out-Null
        $ref = Assert-NonEmptyString -Value $evidence.ref -Context "$SourceLabel evidence_refs.ref"
        Assert-ExistingRef -Ref $ref -Context "$SourceLabel evidence_refs"
        Assert-NonEmptyString -Value $evidence.evidence_kind -Context "$SourceLabel evidence_refs.evidence_kind" | Out-Null
        Assert-NonEmptyString -Value $evidence.authority_kind -Context "$SourceLabel evidence_refs.authority_kind" | Out-Null
        Assert-NonEmptyString -Value $evidence.scope -Context "$SourceLabel evidence_refs.scope" | Out-Null
    }

    $refusalReasons = Assert-StringArray -Value $Lifecycle.refusal_reasons -Context "$SourceLabel refusal_reasons" -AllowEmpty
    Assert-TimestampString -Value $Lifecycle.created_at_utc -Context "$SourceLabel created_at_utc"
    $nonClaims = Assert-StringArray -Value $Lifecycle.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Contract $contract -Context $SourceLabel
    Assert-NoSuccessorOpeningClaim -Lifecycle $Lifecycle -Context $SourceLabel
    Assert-NoForbiddenEvidenceAuthority -EvidenceRefs $evidenceRefs -QaChecks $qaChecks

    if ($stage -eq "blocked" -or $aggregateVerdict -ne "passed") {
        if ($refusalReasons.Count -eq 0) {
            throw "$SourceLabel non-passed or blocked lifecycle requires refusal_reasons."
        }
    }
    if ($aggregateVerdict -eq "passed" -and $refusalReasons.Count -ne 0) {
        throw "$SourceLabel passed aggregate verdict requires empty refusal_reasons."
    }

    if (Test-StageAtLeast -Stage $stage -MinimumStage "classified") {
        if ($detectedIssues.Count -eq 0 -or $classifiedIssues.Count -eq 0) {
            throw "classified without detected/classified issues evidence is rejected."
        }
        foreach ($issue in $detectedIssues) {
            Assert-ReferenceHasEvidence -EvidenceRefs $evidenceRefs -Ref ([string]$issue.evidence_ref) -Context "$SourceLabel detected issue evidence" | Out-Null
        }
        foreach ($issue in $classifiedIssues) {
            Assert-ReferenceHasEvidence -EvidenceRefs $evidenceRefs -Ref ([string]$issue.detection_ref) -Context "$SourceLabel classified issue detection evidence" | Out-Null
            Assert-ReferenceHasEvidence -EvidenceRefs $evidenceRefs -Ref ([string]$issue.classification_evidence_ref) -Context "$SourceLabel classified issue classification evidence" | Out-Null
        }
    }
    if (Test-StageAtLeast -Stage $stage -MinimumStage "queued") {
        if ([string]::IsNullOrWhiteSpace([string]$Lifecycle.fix_queue_ref)) {
            throw "queued without fix_queue_ref is rejected."
        }
        Assert-ReferenceHasEvidence -EvidenceRefs $evidenceRefs -Ref ([string]$Lifecycle.fix_queue_ref) -Context "$SourceLabel fix_queue_ref" -RequiredKind "fix_queue" | Out-Null
    }
    if (Test-StageAtLeast -Stage $stage -MinimumStage "fix_executed") {
        if ([string]::IsNullOrWhiteSpace([string]$Lifecycle.fix_execution_ref)) {
            throw "fix_executed without fix_execution_ref is rejected."
        }
        Assert-ReferenceHasEvidence -EvidenceRefs $evidenceRefs -Ref ([string]$Lifecycle.fix_execution_ref) -Context "$SourceLabel fix_execution_ref" -RequiredKind "fix_execution" | Out-Null
    }
    if (Test-StageAtLeast -Stage $stage -MinimumStage "rerun") {
        if ([string]::IsNullOrWhiteSpace([string]$Lifecycle.rerun_ref)) {
            throw "rerun without rerun_ref is rejected."
        }
        Assert-ReferenceHasEvidence -EvidenceRefs $evidenceRefs -Ref ([string]$Lifecycle.rerun_ref) -Context "$SourceLabel rerun_ref" -RequiredKind "rerun" | Out-Null
    }
    if (Test-StageAtLeast -Stage $stage -MinimumStage "compared") {
        if ([string]::IsNullOrWhiteSpace([string]$Lifecycle.rerun_ref)) {
            throw "compared without rerun_ref is rejected."
        }
        if ([string]::IsNullOrWhiteSpace([string]$Lifecycle.before_after_comparison_ref)) {
            throw "compared without before_after_comparison_ref is rejected."
        }
        Assert-ReferenceHasEvidence -EvidenceRefs $evidenceRefs -Ref ([string]$Lifecycle.before_after_comparison_ref) -Context "$SourceLabel before_after_comparison_ref" -RequiredKind "before_after_comparison" | Out-Null
    }
    if ($stage -eq "signed_off" -or $stage -eq "signoff_ready") {
        foreach ($requiredFinalRef in @("rerun_ref", "before_after_comparison_ref", "external_replay_ref", "operator_summary_ref")) {
            if ([string]::IsNullOrWhiteSpace([string]$Lifecycle.$requiredFinalRef)) {
                if ($requiredFinalRef -eq "operator_summary_ref") {
                    throw "signed_off without operator_summary_ref is rejected."
                }
                throw "signed_off without $requiredFinalRef is rejected."
            }
        }
        Assert-ReferenceHasEvidence -EvidenceRefs $evidenceRefs -Ref ([string]$Lifecycle.external_replay_ref) -Context "$SourceLabel external_replay_ref" -RequiredKind "external_replay" -RequireExternal | Out-Null
        Assert-ReferenceHasEvidence -EvidenceRefs $evidenceRefs -Ref ([string]$Lifecycle.operator_summary_ref) -Context "$SourceLabel operator_summary_ref" -RequiredKind "operator_summary" | Out-Null
    }
    if ($stage -eq "signed_off") {
        if ([string]::IsNullOrWhiteSpace([string]$Lifecycle.signoff_ref)) {
            throw "signed_off without signoff_ref is rejected."
        }
        Assert-ReferenceHasEvidence -EvidenceRefs $evidenceRefs -Ref ([string]$Lifecycle.signoff_ref) -Context "$SourceLabel signoff_ref" -RequiredKind "signoff" | Out-Null
    }

    $unresolvedBlocking = @($detectedIssues + $classifiedIssues | Where-Object {
            [string]$_.blocking_status -eq "blocking" -and [string]$_.status -notin @("fixed", "resolved")
        })
    if ($aggregateVerdict -eq "passed" -and $unresolvedBlocking.Count -gt 0) {
        throw "passed aggregate verdict with unresolved blocking issues is rejected."
    }

    if ($aggregateVerdict -eq "passed") {
        if ($stage -ne "signed_off") {
            throw "$SourceLabel passed aggregate verdict requires lifecycle_stage signed_off."
        }
        if ($qaChecks.Count -eq 0) {
            throw "pass without evidence is rejected because qa_checks is empty."
        }
        $nonSchemaChecks = @($qaChecks | Where-Object { [string]$_.check_type -notmatch '(?i)schema|contract' })
        if ($nonSchemaChecks.Count -eq 0) {
            throw "schema-only QA cannot be treated as a meaningful QA cycle."
        }
    }

    $PSCmdlet.WriteObject([pscustomobject][ordered]@{
            LifecycleId = $Lifecycle.lifecycle_id
            Repository = $Lifecycle.repository
            Branch = $Lifecycle.branch
            Head = $Lifecycle.head
            Tree = $Lifecycle.tree
            Stage = $stage
            AggregateVerdict = $aggregateVerdict
            DetectedIssueCount = $detectedIssues.Count
            ClassifiedIssueCount = $classifiedIssues.Count
            EvidenceRefCount = $evidenceRefs.Count
        }, $false)
}

function Test-R13QaLifecycle {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$LifecyclePath
    )

    $lifecycle = Get-JsonDocument -Path $LifecyclePath -Label "R13 QA lifecycle"
    return Test-R13QaLifecycleObject -Lifecycle $lifecycle -SourceLabel "R13 QA lifecycle"
}

Export-ModuleMember -Function Get-R13QaLifecycleContract, Test-R13QaLifecycleObject, Test-R13QaLifecycle
