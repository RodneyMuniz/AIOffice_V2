Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$script:R12OperatingLoopStates = @(
    "initialized",
    "request_recorded",
    "plan_prepared",
    "plan_approved",
    "fresh_thread_bootstrap_ready",
    "residue_preflight_passed",
    "external_runner_requested",
    "external_runner_evidence_recorded",
    "dev_result_recorded",
    "actionable_qa_ready",
    "qa_gate_passed",
    "control_room_status_ready",
    "operator_decision_pending",
    "candidate_closeout_ready",
    "final_head_support_pending",
    "closed"
)

$script:R12OperatingLoopEvidenceRefs = @(
    "operator_request_ref",
    "cycle_plan_ref",
    "operator_approval_ref",
    "fresh_thread_bootstrap_ref",
    "residue_preflight_ref",
    "external_runner_request_ref",
    "external_runner_result_ref",
    "external_artifact_manifest_ref",
    "dev_result_ref",
    "actionable_qa_report_ref",
    "qa_gate_ref",
    "control_room_status_ref",
    "operator_decision_ref",
    "audit_packet_ref",
    "candidate_closeout_ref",
    "final_head_support_ref"
)

$script:R12RequiredNonClaims = @(
    "chat transcript is not authority",
    "narrative is not proof",
    "no R12 value gates delivered during Phase A",
    "no broad autonomous milestone execution",
    "no unattended automatic resume",
    "no solved Codex context compaction",
    "no production runtime",
    "no real production QA",
    "no productized control-room behavior",
    "no R13 or successor opened"
)

$script:R12ForbiddenClaimPatterns = @(
    "broad autonomous milestone execution",
    "unattended automatic resume",
    "solved Codex context compaction",
    "hours-long unattended execution",
    "production runtime",
    "real production QA",
    "full UI/control-room productization",
    "productized control-room behavior",
    "Standard runtime",
    "multi-repo orchestration",
    "swarms",
    "broad CI/product coverage",
    "R13",
    "successor milestone opened"
)

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
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    return $null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name
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
    [CmdletBinding()]
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

    $PSCmdlet.WriteObject($items, $false)
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

function Get-StateIndex {
    param(
        [Parameter(Mandatory = $true)]
        [string]$State
    )

    for ($index = 0; $index -lt $script:R12OperatingLoopStates.Count; $index += 1) {
        if ($script:R12OperatingLoopStates[$index] -eq $State) {
            return $index
        }
    }

    throw "state '$State' must be one of: $($script:R12OperatingLoopStates -join ', ')."
}

function Get-RequiredEvidenceRefsForState {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$State
    )

    $stateIndex = Get-StateIndex -State $State
    $refs = New-Object System.Collections.Generic.List[string]

    $stateRefMap = [ordered]@{
        request_recorded = @("operator_request_ref")
        plan_prepared = @("cycle_plan_ref")
        plan_approved = @("operator_approval_ref")
        fresh_thread_bootstrap_ready = @("fresh_thread_bootstrap_ref")
        residue_preflight_passed = @("residue_preflight_ref")
        external_runner_requested = @("external_runner_request_ref")
        external_runner_evidence_recorded = @("external_runner_result_ref", "external_artifact_manifest_ref")
        dev_result_recorded = @("dev_result_ref")
        actionable_qa_ready = @("actionable_qa_report_ref")
        qa_gate_passed = @("qa_gate_ref")
        control_room_status_ready = @("control_room_status_ref")
        operator_decision_pending = @("operator_decision_ref")
        candidate_closeout_ready = @("audit_packet_ref", "candidate_closeout_ref")
        final_head_support_pending = @("final_head_support_ref")
        closed = @()
    }

    foreach ($entry in $stateRefMap.GetEnumerator()) {
        $requiredStateIndex = Get-StateIndex -State $entry.Key
        if ($requiredStateIndex -le $stateIndex) {
            foreach ($refName in $entry.Value) {
                if (-not $refs.Contains($refName)) {
                    $refs.Add($refName) | Out-Null
                }
            }
        }
    }

    $PSCmdlet.WriteObject(@($refs), $false)
}

function Assert-RequiredNonClaims {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$NonClaims,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($requiredNonClaim in $script:R12RequiredNonClaims) {
        if ($NonClaims -notcontains $requiredNonClaim) {
            throw "$Context non_claims must include '$requiredNonClaim'."
        }
    }
}

function Get-R12OperatingLoopContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "operating_loop", "r12_operating_loop.contract.json")) -Label "R12 operating loop contract"
}

function Test-OperatingLoopObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Loop,
        [string]$SourceLabel = "R12 operating loop"
    )

    Get-R12OperatingLoopContract | Out-Null

    foreach ($field in @(
            "contract_version",
            "artifact_type",
            "loop_id",
            "repository",
            "branch",
            "milestone",
            "source_task",
            "loop_authority",
            "state",
            "allowed_next_states",
            "evidence_refs",
            "transition_history",
            "successor_milestone_opened",
            "successor_milestone_ref",
            "claims",
            "non_claims"
        )) {
        Get-RequiredProperty -Object $Loop -Name $field -Context $SourceLabel | Out-Null
    }

    if ($Loop.artifact_type -ne "r12_operating_loop") {
        throw "$SourceLabel artifact_type must be 'r12_operating_loop'."
    }
    if ($Loop.repository -ne "AIOffice_V2") {
        throw "$SourceLabel repository must be AIOffice_V2."
    }
    if ($Loop.branch -ne "release/r12-external-api-runner-actionable-qa-control-room-pilot") {
        throw "$SourceLabel branch must be release/r12-external-api-runner-actionable-qa-control-room-pilot."
    }
    if ($Loop.milestone -ne "R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot") {
        throw "$SourceLabel milestone must be the R12 milestone title."
    }
    if ($Loop.source_task -ne "R12-003") {
        throw "$SourceLabel source_task must be R12-003."
    }
    Assert-NonEmptyString -Value $Loop.loop_id -Context "$SourceLabel loop_id" | Out-Null

    $authority = Assert-ObjectValue -Value $Loop.loop_authority -Context "$SourceLabel loop_authority"
    foreach ($field in @("state_authority", "committed_state_required", "chat_transcript_authority_allowed", "narrative_authority_allowed", "statement")) {
        Get-RequiredProperty -Object $authority -Name $field -Context "$SourceLabel loop_authority" | Out-Null
    }
    $stateAuthority = Assert-NonEmptyString -Value $authority.state_authority -Context "$SourceLabel loop_authority.state_authority"
    if ($stateAuthority -match "(?i)chat") {
        throw "$SourceLabel chat transcript cannot be state authority."
    }
    if (-not (Assert-BooleanValue -Value $authority.committed_state_required -Context "$SourceLabel loop_authority.committed_state_required")) {
        throw "$SourceLabel committed operating-loop artifact must be required."
    }
    if (Assert-BooleanValue -Value $authority.chat_transcript_authority_allowed -Context "$SourceLabel loop_authority.chat_transcript_authority_allowed") {
        throw "$SourceLabel chat transcript authority is rejected."
    }
    if (Assert-BooleanValue -Value $authority.narrative_authority_allowed -Context "$SourceLabel loop_authority.narrative_authority_allowed") {
        throw "$SourceLabel narrative authority is rejected."
    }
    Assert-NonEmptyString -Value $authority.statement -Context "$SourceLabel loop_authority.statement" | Out-Null

    $state = Assert-NonEmptyString -Value $Loop.state -Context "$SourceLabel state"
    $stateIndex = Get-StateIndex -State $state
    $allowedNextStates = Assert-StringArray -Value $Loop.allowed_next_states -Context "$SourceLabel allowed_next_states" -AllowEmpty
    if ($state -eq "closed") {
        if ($allowedNextStates.Count -ne 0) {
            throw "$SourceLabel closed state must not have allowed_next_states."
        }
    }
    else {
        $expectedNextState = $script:R12OperatingLoopStates[$stateIndex + 1]
        if ($allowedNextStates -notcontains $expectedNextState) {
            throw "$SourceLabel allowed_next_states must include next legal state '$expectedNextState'."
        }
    }

    $evidenceRefs = Assert-ObjectValue -Value $Loop.evidence_refs -Context "$SourceLabel evidence_refs"
    foreach ($refName in $script:R12OperatingLoopEvidenceRefs) {
        Get-RequiredProperty -Object $evidenceRefs -Name $refName -Context "$SourceLabel evidence_refs" | Out-Null
    }

    $requiredRefs = Get-RequiredEvidenceRefsForState -State $state
    if ($stateIndex -ge (Get-StateIndex -State "final_head_support_pending")) {
        if ([string]::IsNullOrWhiteSpace([string]$evidenceRefs.candidate_closeout_ref)) {
            throw "$SourceLabel final support before candidate closeout is rejected."
        }
    }
    foreach ($requiredRef in $requiredRefs) {
        Assert-NonEmptyString -Value $evidenceRefs.PSObject.Properties[$requiredRef].Value -Context "$SourceLabel evidence_refs.$requiredRef" | Out-Null
    }

    if ($stateIndex -ge (Get-StateIndex -State "external_runner_evidence_recorded")) {
        if ([string]::IsNullOrWhiteSpace([string]$evidenceRefs.external_runner_result_ref) -or [string]::IsNullOrWhiteSpace([string]$evidenceRefs.external_artifact_manifest_ref)) {
            throw "$SourceLabel final closeout without external runner evidence is rejected."
        }
    }
    if ($stateIndex -ge (Get-StateIndex -State "qa_gate_passed")) {
        if ([string]::IsNullOrWhiteSpace([string]$evidenceRefs.actionable_qa_report_ref)) {
            throw "$SourceLabel QA gate pass requires actionable QA report evidence."
        }
    }
    if ($stateIndex -ge (Get-StateIndex -State "operator_decision_pending")) {
        if ([string]::IsNullOrWhiteSpace([string]$evidenceRefs.control_room_status_ref)) {
            throw "$SourceLabel operator decision requires control-room status evidence."
        }
    }
    if ($state -eq "closed") {
        foreach ($refName in $script:R12OperatingLoopEvidenceRefs) {
            Assert-NonEmptyString -Value $evidenceRefs.PSObject.Properties[$refName].Value -Context "$SourceLabel evidence_refs.$refName" | Out-Null
        }
    }

    $transitions = Assert-ObjectArray -Value $Loop.transition_history -Context "$SourceLabel transition_history"
    $previousToState = "none"
    foreach ($transition in $transitions) {
        foreach ($field in @("from_state", "to_state", "transitioned_at_utc", "evidence_ref", "actor", "reason")) {
            Get-RequiredProperty -Object $transition -Name $field -Context "$SourceLabel transition" | Out-Null
        }
        $fromState = Assert-NonEmptyString -Value $transition.from_state -Context "$SourceLabel transition.from_state"
        $toState = Assert-NonEmptyString -Value $transition.to_state -Context "$SourceLabel transition.to_state"
        Assert-NonEmptyString -Value $transition.transitioned_at_utc -Context "$SourceLabel transition.transitioned_at_utc" | Out-Null
        Assert-NonEmptyString -Value $transition.evidence_ref -Context "$SourceLabel transition.evidence_ref" | Out-Null
        Assert-NonEmptyString -Value $transition.actor -Context "$SourceLabel transition.actor" | Out-Null
        Assert-NonEmptyString -Value $transition.reason -Context "$SourceLabel transition.reason" | Out-Null

        if ($fromState -ne $previousToState) {
            throw "$SourceLabel transition_history has a from_state gap before '$toState'."
        }
        if ($fromState -eq "none") {
            if ($toState -ne "initialized") {
                throw "$SourceLabel illegal state transition from none to '$toState'."
            }
        }
        else {
            $fromIndex = Get-StateIndex -State $fromState
            $toIndex = Get-StateIndex -State $toState
            if ($toIndex -ne ($fromIndex + 1)) {
                throw "$SourceLabel illegal state transition from '$fromState' to '$toState'."
            }
        }
        $previousToState = $toState
    }

    if ($previousToState -ne $state) {
        throw "$SourceLabel transition_history must end at current state '$state'."
    }

    $successorOpened = Assert-BooleanValue -Value $Loop.successor_milestone_opened -Context "$SourceLabel successor_milestone_opened"
    if ($successorOpened) {
        throw "$SourceLabel successor milestone opening is rejected."
    }
    if (-not [string]::IsNullOrWhiteSpace([string]$Loop.successor_milestone_ref)) {
        throw "$SourceLabel successor milestone ref must be empty during R12 Phase A."
    }

    $claims = Assert-StringArray -Value $Loop.claims -Context "$SourceLabel claims" -AllowEmpty
    foreach ($claim in $claims) {
        foreach ($forbidden in $script:R12ForbiddenClaimPatterns) {
            if ($claim -match [regex]::Escape($forbidden)) {
                throw "$SourceLabel broad autonomy/product/runtime claim is rejected: $claim"
            }
        }
    }

    $nonClaims = Assert-StringArray -Value $Loop.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel

    return [pscustomobject]@{
        LoopId = $Loop.loop_id
        State = $state
        TransitionCount = $transitions.Count
        RequiredEvidenceRefCount = $requiredRefs.Count
        Closed = ($state -eq "closed")
    }
}

function Test-OperatingLoopContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$LoopPath
    )

    $loop = Get-JsonDocument -Path $LoopPath -Label "R12 operating loop"
    return Test-OperatingLoopObject -Loop $loop -SourceLabel $LoopPath
}

Export-ModuleMember -Function Get-R12OperatingLoopContract, Test-OperatingLoopObject, Test-OperatingLoopContract
