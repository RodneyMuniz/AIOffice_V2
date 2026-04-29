Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

function Get-RepositoryRoot {
    return $repoRoot
}

function Get-ModuleRepositoryRootPath {
    return (Resolve-Path -LiteralPath (Get-RepositoryRoot)).Path
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

function Get-CycleControllerFoundationContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "cycle_controller", "foundation.contract.json")) -Label "Cycle controller foundation contract"
}

function Get-CycleLedgerContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "cycle_controller", "cycle_ledger.contract.json")) -Label "Cycle ledger contract"
}

function Test-HasProperty {
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    if ($null -eq $Object) {
        return $false
    }

    $propertyNames = @($Object.PSObject.Properties | ForEach-Object { $_.Name })
    return $propertyNames -contains $Name
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

    $property = $Object.PSObject.Properties[$Name]
    $PSCmdlet.WriteObject($property.Value, $false)
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
        [int]$MinimumCount = 1
    )

    if ($null -eq $Value -or $Value -is [string] -or -not ($Value -is [System.Collections.IEnumerable])) {
        throw "$Context must be an array."
    }

    $items = @($Value)
    if ($items.Count -lt $MinimumCount) {
        throw "$Context must contain at least $MinimumCount item(s)."
    }

    foreach ($item in $items) {
        Assert-ObjectValue -Value $item -Context "$Context item" | Out-Null
    }

    $PSCmdlet.WriteObject($items, $false)
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

function Assert-Timestamp {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Pattern,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-MatchesPattern -Value $Value -Pattern $Pattern -Context $Context
    try {
        $styles = [System.Globalization.DateTimeStyles]::AssumeUniversal -bor [System.Globalization.DateTimeStyles]::AdjustToUniversal
        return [System.DateTimeOffset]::ParseExact($Value, "yyyy-MM-dd'T'HH:mm:ss'Z'", [System.Globalization.CultureInfo]::InvariantCulture, $styles)
    }
    catch {
        throw "$Context must be a valid UTC timestamp."
    }
}

function Get-DynamicObjectProperty {
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $property = $Object.PSObject.Properties[$Name]
    if ($null -eq $property) {
        throw "$Context does not define '$Name'."
    }

    return $property.Value
}

function Get-AllowedTransitionsForState {
    param(
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        [string]$State
    )

    return @(Get-DynamicObjectProperty -Object $Foundation.allowed_transitions -Name $State -Context "Cycle ledger allowed transition model")
}

function Get-CurrentStepForState {
    param(
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        [string]$State
    )

    return [string](Get-DynamicObjectProperty -Object $Foundation.current_step_by_state -Name $State -Context "Cycle ledger current-step model")
}

function Get-StateRefRequirement {
    param(
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [string]$State
    )

    return Get-DynamicObjectProperty -Object $Contract.state_ref_requirements -Name $State -Context "Cycle ledger state ref requirements"
}

function Assert-OptionalRepoRef {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Pattern,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -isnot [string]) {
        throw "$Context must be a string."
    }

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return ""
    }

    Assert-MatchesPattern -Value $Value -Pattern $Pattern -Context $Context
    return $Value
}

function Assert-RequiredRepoRef {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Pattern,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $ref = Assert-OptionalRepoRef -Value $Value -Pattern $Pattern -Context $Context
    if ([string]::IsNullOrWhiteSpace($ref)) {
        throw "$Context is required for the current cycle state."
    }

    return $ref
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

function Assert-ControllerAuthority {
    param(
        [Parameter(Mandatory = $true)]
        $ControllerAuthority,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract
    )

    Assert-RequiredObjectFields -Object $ControllerAuthority -FieldNames @($Contract.controller_authority_required_fields) -Context "Cycle ledger.controller_authority"

    $authorityType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ControllerAuthority -Name "authority_type" -Context "Cycle ledger.controller_authority") -Context "Cycle ledger.controller_authority.authority_type"
    if ($authorityType -ne $Foundation.authority_type -or $authorityType -match $Foundation.forbidden_controller_authority_pattern) {
        throw "Cycle ledger.controller_authority.authority_type must make repo-truth cycle ledger authority explicit."
    }

    $stateAuthority = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ControllerAuthority -Name "state_authority" -Context "Cycle ledger.controller_authority") -Context "Cycle ledger.controller_authority.state_authority"
    if ($stateAuthority -ne $Foundation.state_authority -or $stateAuthority -match $Foundation.forbidden_controller_authority_pattern) {
        throw "Cycle ledger.controller_authority.state_authority must be '$($Foundation.state_authority)' and must not imply chat transcript, memory, narration, or manual assertion authority."
    }

    $committedStateRequired = Assert-BooleanValue -Value (Get-RequiredProperty -Object $ControllerAuthority -Name "committed_state_required" -Context "Cycle ledger.controller_authority") -Context "Cycle ledger.controller_authority.committed_state_required"
    if (-not $committedStateRequired) {
        throw "Cycle ledger.controller_authority.committed_state_required must be true."
    }

    $chatMemoryAuthorityAllowed = Assert-BooleanValue -Value (Get-RequiredProperty -Object $ControllerAuthority -Name "chat_memory_authority_allowed" -Context "Cycle ledger.controller_authority") -Context "Cycle ledger.controller_authority.chat_memory_authority_allowed"
    if ($chatMemoryAuthorityAllowed) {
        throw "Cycle ledger.controller_authority.chat_memory_authority_allowed must be false."
    }

    $statement = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ControllerAuthority -Name "statement" -Context "Cycle ledger.controller_authority") -Context "Cycle ledger.controller_authority.statement"
    $forbiddenAuthorityClaimPattern = '(?i)\b(chat transcript|chat memory|operator memory|memory|narration|manual assertion)\b.{0,80}\b(is|are|becomes|become|serves as)\b.{0,80}\b(state authority|authority)\b'
    if ($statement -match $forbiddenAuthorityClaimPattern -and $statement -notmatch '(?i)\b(no|not|never|not cycle state authority|not state authority|non-authoritative)\b') {
        throw "Cycle ledger.controller_authority.statement must not imply chat transcript, memory, narration, or manual assertion authority."
    }
}

function Assert-AllowedNextStates {
    param(
        [Parameter(Mandatory = $true)]
        [string]$State,
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [string[]]$AllowedNextStates,
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [string[]]$ExpectedNextStates,
        [Parameter(Mandatory = $true)]
        [string[]]$TerminalStates
    )

    $isTerminal = $TerminalStates -contains $State
    if ($isTerminal -and $AllowedNextStates.Count -ne 0) {
        throw "Cycle ledger terminal state '$State' must not have allowed_next_states."
    }

    if (-not $isTerminal -and $ExpectedNextStates.Count -gt 0 -and $AllowedNextStates.Count -eq 0) {
        throw "Cycle ledger non-terminal state '$State' must not have empty allowed_next_states."
    }

    if ($AllowedNextStates.Count -ne $ExpectedNextStates.Count) {
        throw "Cycle ledger.allowed_next_states for state '$State' must match the allowed transition model."
    }

    for ($index = 0; $index -lt $ExpectedNextStates.Count; $index += 1) {
        if ($AllowedNextStates[$index] -ne $ExpectedNextStates[$index]) {
            throw "Cycle ledger.allowed_next_states for state '$State' must match the allowed transition model."
        }
    }
}

function Assert-TransitionHistory {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Transitions,
        [Parameter(Mandatory = $true)]
        [string]$CurrentState,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [datetimeoffset]$CreatedAtUtc,
        [Parameter(Mandatory = $true)]
        [datetimeoffset]$UpdatedAtUtc
    )

    $previousToState = $null
    $previousTimestamp = $null
    $allowedStates = @($Foundation.allowed_states)

    for ($index = 0; $index -lt $Transitions.Count; $index += 1) {
        $transition = $Transitions[$index]
        Assert-RequiredObjectFields -Object $transition -FieldNames @($Contract.transition_required_fields) -Context "Cycle ledger.transition_history[$index]"

        $fromState = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $transition -Name "from_state" -Context "Cycle ledger.transition_history[$index]") -Context "Cycle ledger.transition_history[$index].from_state"
        $toState = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $transition -Name "to_state" -Context "Cycle ledger.transition_history[$index]") -Context "Cycle ledger.transition_history[$index].to_state"
        if ($allowedStates -notcontains $toState) {
            throw "Cycle ledger.transition_history[$index].to_state '$toState' is not a known cycle state."
        }

        $transitionedAt = Assert-Timestamp -Value (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $transition -Name "transitioned_at_utc" -Context "Cycle ledger.transition_history[$index]") -Context "Cycle ledger.transition_history[$index].transitioned_at_utc") -Pattern $Foundation.timestamp_pattern -Context "Cycle ledger.transition_history[$index].transitioned_at_utc"
        if ($transitionedAt -lt $CreatedAtUtc -or $transitionedAt -gt $UpdatedAtUtc) {
            throw "Cycle ledger.transition_history[$index].transitioned_at_utc must fall between created_at_utc and updated_at_utc."
        }

        if ($null -ne $previousTimestamp -and $transitionedAt -lt $previousTimestamp) {
            throw "Cycle ledger.transition_history timestamps must not regress."
        }

        $evidenceRef = Assert-RequiredRepoRef -Value (Get-RequiredProperty -Object $transition -Name "evidence_ref" -Context "Cycle ledger.transition_history[$index]") -Pattern $Foundation.repo_ref_pattern -Context "Cycle ledger.transition_history[$index].evidence_ref"
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $transition -Name "actor" -Context "Cycle ledger.transition_history[$index]") -Context "Cycle ledger.transition_history[$index].actor" | Out-Null
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $transition -Name "reason" -Context "Cycle ledger.transition_history[$index]") -Context "Cycle ledger.transition_history[$index].reason" | Out-Null

        if ($index -eq 0) {
            if ($fromState -ne $Foundation.initial_transition_from -or $toState -ne "initialized") {
                throw "Cycle ledger.transition_history must begin with '$($Foundation.initial_transition_from)' to 'initialized'."
            }
        }
        else {
            if ($fromState -ne $previousToState) {
                throw "Cycle ledger.transition_history[$index].from_state does not match prior to_state '$previousToState'."
            }

            $expectedNextStates = @(Get-AllowedTransitionsForState -Foundation $Foundation -State $fromState)
            if ($expectedNextStates -notcontains $toState) {
                throw "Cycle ledger.transition_history contains impossible jump from '$fromState' to '$toState'."
            }
        }

        $previousToState = $toState
        $previousTimestamp = $transitionedAt
        $null = $evidenceRef
    }

    if ($previousToState -ne $CurrentState) {
        throw "Cycle ledger.transition_history must end at current state '$CurrentState'."
    }
}

function Assert-StateRefRequirements {
    param(
        [Parameter(Mandatory = $true)]
        [string]$State,
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$SingularRefs,
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$ArrayRefs,
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [string[]]$EvidenceRefs,
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [string[]]$RefusalReasons,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract
    )

    $requirements = Get-StateRefRequirement -Contract $Contract -State $State

    foreach ($fieldName in @($requirements.singular_refs)) {
        Assert-RequiredRepoRef -Value $SingularRefs[$fieldName] -Pattern $Foundation.repo_ref_pattern -Context "Cycle ledger.$fieldName" | Out-Null
    }

    foreach ($fieldName in @($requirements.array_refs)) {
        $items = @($ArrayRefs[$fieldName])
        if ($items.Count -eq 0) {
            throw "Cycle ledger.$fieldName is required for state '$State'."
        }
    }

    if ([bool]$requirements.approval_evidence_required) {
        if ($EvidenceRefs.Count -eq 0) {
            throw "Cycle ledger.evidence_refs are required for state '$State'."
        }

        $approvalEvidence = @($EvidenceRefs | Where-Object { $_ -match $Contract.approval_evidence_pattern })
        if ($approvalEvidence.Count -eq 0) {
            throw "Cycle ledger.evidence_refs must include operator approval evidence for state '$State'."
        }
    }

    if ([bool]$requirements.refusal_reasons_required -and $RefusalReasons.Count -eq 0) {
        throw "Cycle ledger.refusal_reasons are required for terminal state '$State'."
    }

    if ($State -eq "accepted" -and $RefusalReasons.Count -ne 0) {
        throw "Cycle ledger.refusal_reasons must be empty when terminal state is 'accepted'."
    }
}

function Test-CycleLedgerObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Ledger,
        [string]$SourceLabel = "Cycle ledger"
    )

    $foundation = Get-CycleControllerFoundationContract
    $contract = Get-CycleLedgerContract

    Assert-RequiredObjectFields -Object $Ledger -FieldNames @($contract.required_fields) -Context $SourceLabel

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "contract_version" -Context $SourceLabel) -Context "$SourceLabel.contract_version"
    if ($contractVersion -ne $foundation.contract_version -or $contractVersion -ne $contract.contract_version) {
        throw "$SourceLabel.contract_version must equal '$($foundation.contract_version)'."
    }

    $artifactType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "artifact_type" -Context $SourceLabel) -Context "$SourceLabel.artifact_type"
    if ($artifactType -ne $foundation.cycle_ledger_artifact_type -or $artifactType -ne $contract.ledger_artifact_type) {
        throw "$SourceLabel.artifact_type must equal '$($foundation.cycle_ledger_artifact_type)'."
    }

    $cycleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "cycle_id" -Context $SourceLabel) -Context "$SourceLabel.cycle_id"
    Assert-MatchesPattern -Value $cycleId -Pattern $foundation.identifier_pattern -Context "$SourceLabel.cycle_id"

    $repository = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "repository" -Context $SourceLabel) -Context "$SourceLabel.repository"
    if ($repository -ne $foundation.repository) {
        throw "$SourceLabel.repository must be '$($foundation.repository)'."
    }

    $branch = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "branch" -Context $SourceLabel) -Context "$SourceLabel.branch"
    if ($branch -ne $foundation.branch) {
        throw "$SourceLabel.branch must be '$($foundation.branch)'."
    }

    $milestone = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "milestone" -Context $SourceLabel) -Context "$SourceLabel.milestone"
    if ($milestone -ne $foundation.milestone) {
        throw "$SourceLabel.milestone must be '$($foundation.milestone)'."
    }

    $sourceTask = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "source_task" -Context $SourceLabel) -Context "$SourceLabel.source_task"
    if ($sourceTask -ne $foundation.source_task) {
        throw "$SourceLabel.source_task must be '$($foundation.source_task)'."
    }

    Assert-ControllerAuthority -ControllerAuthority (Assert-ObjectValue -Value (Get-RequiredProperty -Object $Ledger -Name "controller_authority" -Context $SourceLabel) -Context "$SourceLabel.controller_authority") -Foundation $foundation -Contract $contract

    $state = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "state" -Context $SourceLabel) -Context "$SourceLabel.state"
    Assert-AllowedValue -Value $state -AllowedValues @($foundation.allowed_states) -Context "$SourceLabel.state"

    $allowedNextStates = Assert-StringArray -Value (Get-RequiredProperty -Object $Ledger -Name "allowed_next_states" -Context $SourceLabel) -Context "$SourceLabel.allowed_next_states" -AllowEmpty
    foreach ($allowedNextState in $allowedNextStates) {
        Assert-AllowedValue -Value $allowedNextState -AllowedValues @($foundation.allowed_states) -Context "$SourceLabel.allowed_next_states item"
    }

    $expectedNextStates = @(Get-AllowedTransitionsForState -Foundation $foundation -State $state)
    Assert-AllowedNextStates -State $state -AllowedNextStates $allowedNextStates -ExpectedNextStates $expectedNextStates -TerminalStates @($foundation.terminal_states)

    $currentStep = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "current_step" -Context $SourceLabel) -Context "$SourceLabel.current_step"
    $expectedCurrentStep = Get-CurrentStepForState -Foundation $foundation -State $state
    if ($currentStep -ne $expectedCurrentStep) {
        throw "$SourceLabel.current_step '$currentStep' contradicts current state '$state'. Expected '$expectedCurrentStep'."
    }

    $singularRefs = @{}
    foreach ($fieldName in @($contract.singular_ref_fields)) {
        $singularRefs[$fieldName] = Assert-OptionalRepoRef -Value (Get-RequiredProperty -Object $Ledger -Name $fieldName -Context $SourceLabel) -Pattern $foundation.repo_ref_pattern -Context "$SourceLabel.$fieldName"
    }

    $arrayRefs = @{}
    foreach ($fieldName in @($contract.array_ref_fields)) {
        $items = Assert-StringArray -Value (Get-RequiredProperty -Object $Ledger -Name $fieldName -Context $SourceLabel) -Context "$SourceLabel.$fieldName" -AllowEmpty
        foreach ($item in $items) {
            Assert-MatchesPattern -Value $item -Pattern $foundation.repo_ref_pattern -Context "$SourceLabel.$fieldName item"
        }
        $arrayRefs[$fieldName] = $items
    }

    $headSha = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "head_sha" -Context $SourceLabel) -Context "$SourceLabel.head_sha"
    Assert-MatchesPattern -Value $headSha -Pattern $foundation.git_sha_pattern -Context "$SourceLabel.head_sha"

    $treeSha = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "tree_sha" -Context $SourceLabel) -Context "$SourceLabel.tree_sha"
    Assert-MatchesPattern -Value $treeSha -Pattern $foundation.git_sha_pattern -Context "$SourceLabel.tree_sha"

    $createdAtUtc = Assert-Timestamp -Value (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "created_at_utc" -Context $SourceLabel) -Context "$SourceLabel.created_at_utc") -Pattern $foundation.timestamp_pattern -Context "$SourceLabel.created_at_utc"
    $updatedAtUtc = Assert-Timestamp -Value (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "updated_at_utc" -Context $SourceLabel) -Context "$SourceLabel.updated_at_utc") -Pattern $foundation.timestamp_pattern -Context "$SourceLabel.updated_at_utc"
    if ($updatedAtUtc -lt $createdAtUtc) {
        throw "$SourceLabel.updated_at_utc must not be earlier than created_at_utc."
    }

    $transitionHistory = Assert-ObjectArray -Value (Get-RequiredProperty -Object $Ledger -Name "transition_history" -Context $SourceLabel) -Context "$SourceLabel.transition_history" -MinimumCount 1
    Assert-TransitionHistory -Transitions $transitionHistory -CurrentState $state -Foundation $foundation -Contract $contract -CreatedAtUtc $createdAtUtc -UpdatedAtUtc $updatedAtUtc

    $evidenceRefs = @($arrayRefs["evidence_refs"])
    $refusalReasons = Assert-StringArray -Value (Get-RequiredProperty -Object $Ledger -Name "refusal_reasons" -Context $SourceLabel) -Context "$SourceLabel.refusal_reasons" -AllowEmpty
    $nonClaims = Assert-StringArray -Value (Get-RequiredProperty -Object $Ledger -Name "non_claims" -Context $SourceLabel) -Context "$SourceLabel.non_claims"

    foreach ($requiredNonClaim in @($foundation.required_non_claims)) {
        if ($nonClaims -notcontains $requiredNonClaim) {
            throw "$SourceLabel.non_claims must include '$requiredNonClaim'."
        }
    }

    Assert-StateRefRequirements -State $state -SingularRefs $singularRefs -ArrayRefs $arrayRefs -EvidenceRefs $evidenceRefs -RefusalReasons $refusalReasons -Foundation $foundation -Contract $contract

    $result = [pscustomobject]@{
        IsValid = $true
        CycleId = $cycleId
        Repository = $repository
        Branch = $branch
        Milestone = $milestone
        SourceTask = $sourceTask
        State = $state
        CurrentStep = $currentStep
        AllowedNextStates = $allowedNextStates
        HeadSha = $headSha
        TreeSha = $treeSha
        CreatedAtUtc = $createdAtUtc.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        UpdatedAtUtc = $updatedAtUtc.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        TransitionCount = $transitionHistory.Count
        NonClaims = $nonClaims
        SourceLabel = $SourceLabel
    }

    $PSCmdlet.WriteObject($result, $false)
}

function Test-CycleLedgerContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$LedgerPath
    )

    $resolvedLedgerPath = Resolve-ExistingPath -PathValue $LedgerPath -Label "Cycle ledger"
    $ledger = Get-JsonDocument -Path $resolvedLedgerPath -Label "Cycle ledger"
    $validation = Test-CycleLedgerObject -Ledger $ledger -SourceLabel "Cycle ledger"
    $PSCmdlet.WriteObject($validation, $false)
}

function Get-CycleLedger {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$LedgerPath
    )

    $resolvedLedgerPath = Resolve-ExistingPath -PathValue $LedgerPath -Label "Cycle ledger"
    Test-CycleLedgerContract -LedgerPath $resolvedLedgerPath | Out-Null
    return Get-JsonDocument -Path $resolvedLedgerPath -Label "Cycle ledger"
}

Export-ModuleMember -Function Test-CycleLedgerContract, Test-CycleLedgerObject, Get-CycleLedger
