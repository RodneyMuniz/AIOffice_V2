Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$jsonRootModule = Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force -PassThru
$cycleLedgerModule = Import-Module (Join-Path $PSScriptRoot "CycleLedger.psm1") -Force -PassThru
$script:ReadSingleJsonObject = $jsonRootModule.ExportedCommands["Read-SingleJsonObject"]
$script:TestCycleLedgerContract = $cycleLedgerModule.ExportedCommands["Test-CycleLedgerContract"]
$script:GetCycleLedger = $cycleLedgerModule.ExportedCommands["Get-CycleLedger"]

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

function Get-JsonDocument {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $document = & $script:ReadSingleJsonObject -Path $Path -Label $Label
    $PSCmdlet.WriteObject($document, $false)
}

function Get-CycleControllerFoundationContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "cycle_controller", "foundation.contract.json")) -Label "Cycle controller foundation contract"
}

function Get-CycleLedgerContractDefinition {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "cycle_controller", "cycle_ledger.contract.json")) -Label "Cycle ledger contract"
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

function Assert-OptionalRepoRef {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Pattern,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($null -eq $Value) {
        return ""
    }

    if ($Value -isnot [string]) {
        throw "$Context must be a string."
    }

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return ""
    }

    Assert-MatchesPattern -Value $Value -Pattern $Pattern -Context $Context
    return $Value
}

function Assert-StringArrayValue {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [switch]$AllowEmpty
    )

    if ($null -eq $Value) {
        if ($AllowEmpty) {
            $PSCmdlet.WriteObject(@(), $false)
            return
        }

        throw "$Context must be an array."
    }

    if ($Value -is [string]) {
        $items = @($Value)
    }
    elseif ($Value -is [System.Collections.IEnumerable]) {
        $items = @($Value)
    }
    else {
        throw "$Context must be an array."
    }

    if (-not $AllowEmpty -and $items.Count -eq 0) {
        throw "$Context must not be empty."
    }

    foreach ($item in $items) {
        Assert-NonEmptyString -Value $item -Context "$Context item" | Out-Null
    }

    $PSCmdlet.WriteObject($items, $false)
}

function Get-UtcTimestamp {
    return [System.DateTimeOffset]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture)
}

function Get-AllowedTransitionsForState {
    param(
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        [string]$State
    )

    return @(Get-DynamicObjectProperty -Object $Foundation.allowed_transitions -Name $State -Context "Cycle controller transition model")
}

function Get-CurrentStepForState {
    param(
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        [string]$State
    )

    return [string](Get-DynamicObjectProperty -Object $Foundation.current_step_by_state -Name $State -Context "Cycle controller current-step model")
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

function Assert-NoForbiddenControllerText {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [Parameter(Mandatory = $true)]
        $Foundation
    )

    if ($null -eq $Value) {
        return
    }

    $items = if ($Value -is [System.Array]) { @($Value) } else { @($Value) }
    $forbiddenClaimPattern = '(?i)\b(open|opened|active|complete|accepted)\b.{0,80}\b(R12|successor milestone)\b|\b(R12|successor milestone)\b.{0,80}\b(active|open|opened|complete|accepted)\b|\b(broad autonomous milestone execution|broad autonomy|UI/control-room productization|control-room productization|Standard runtime|multi-repo orchestration|swarms|unattended automatic resume|solved Codex context compaction|hours-long unattended execution|production runtime|productized control-room behavior|general Codex reliability)\b'

    foreach ($item in $items) {
        if ($item -isnot [string]) {
            continue
        }

        if ($item -match $Foundation.forbidden_controller_authority_pattern) {
            throw "$Context must not inject chat transcript, chat memory, narration, manual assertion, or operator memory authority."
        }

        if ($item -match $forbiddenClaimPattern) {
            throw "$Context must not inject successor milestone, broad autonomy, productization, runtime, orchestration, unattended resume, compaction, production, or general reliability claims."
        }
    }
}

function Assert-RepositoryIdentity {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Repository,
        [Parameter(Mandatory = $true)]
        [string]$Branch,
        [Parameter(Mandatory = $true)]
        $Foundation
    )

    if ($Repository -ne $Foundation.repository) {
        throw "Controller repository must be '$($Foundation.repository)'."
    }

    if ($Branch -ne $Foundation.branch) {
        throw "Controller branch must be '$($Foundation.branch)'."
    }
}

function Assert-GitIdentity {
    param(
        [Parameter(Mandatory = $true)]
        [string]$HeadSha,
        [Parameter(Mandatory = $true)]
        [string]$TreeSha,
        [Parameter(Mandatory = $true)]
        $Foundation
    )

    Assert-MatchesPattern -Value $HeadSha -Pattern $Foundation.git_sha_pattern -Context "Controller head_sha"
    Assert-MatchesPattern -Value $TreeSha -Pattern $Foundation.git_sha_pattern -Context "Controller tree_sha"
}

function Test-PathUnderRoot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Root
    )

    $fullPath = [System.IO.Path]::GetFullPath($Path)
    $fullRoot = [System.IO.Path]::GetFullPath($Root)
    if (-not $fullRoot.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $fullRoot = $fullRoot + [System.IO.Path]::DirectorySeparatorChar
    }

    return $fullPath.StartsWith($fullRoot, [System.StringComparison]::OrdinalIgnoreCase)
}

function Resolve-GovernedOutputPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$OutputPath,
        [string]$GovernedRoot = "state/cycle_controller",
        [switch]$AllowOutsideGovernedRoot
    )

    Assert-NonEmptyString -Value $OutputPath -Context "Controller output path" | Out-Null
    Assert-NonEmptyString -Value $GovernedRoot -Context "Controller governed output root" | Out-Null

    $resolvedOutputPath = Resolve-PathValue -PathValue $OutputPath
    $resolvedGovernedRoot = Resolve-PathValue -PathValue $GovernedRoot

    if (-not $AllowOutsideGovernedRoot -and -not (Test-PathUnderRoot -Path $resolvedOutputPath -Root $resolvedGovernedRoot)) {
        throw "Controller output path '$OutputPath' is outside governed output root '$GovernedRoot'."
    }

    return $resolvedOutputPath
}

function Set-LedgerProperty {
    param(
        [Parameter(Mandatory = $true)]
        $Ledger,
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [AllowNull()]
        $Value
    )

    if ($Ledger.PSObject.Properties.Name -contains $Name) {
        $Ledger.PSObject.Properties[$Name].Value = $Value
        return
    }

    Add-Member -InputObject $Ledger -MemberType NoteProperty -Name $Name -Value $Value
}

function Get-StringArrayProperty {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    if (-not (Test-HasProperty -Object $Object -Name $Name)) {
        throw "Cycle ledger is missing required field '$Name'."
    }

    $value = $Object.PSObject.Properties[$Name].Value
    $items = Assert-StringArrayValue -Value $value -Context "Cycle ledger.$Name" -AllowEmpty
    $PSCmdlet.WriteObject($items, $false)
}

function Add-UniqueStringValues {
    [CmdletBinding()]
    param(
        [AllowEmptyCollection()]
        [string[]]$Existing,
        [AllowEmptyCollection()]
        [string[]]$Additional
    )

    $items = @()
    foreach ($item in @($Existing) + @($Additional)) {
        if ([string]::IsNullOrWhiteSpace($item)) {
            continue
        }

        if ($items -notcontains $item) {
            $items += $item
        }
    }

    $PSCmdlet.WriteObject($items, $false)
}

function New-TransitionEntry {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FromState,
        [Parameter(Mandatory = $true)]
        [string]$ToState,
        [Parameter(Mandatory = $true)]
        [string]$Timestamp,
        [Parameter(Mandatory = $true)]
        [string]$EvidenceRef,
        [Parameter(Mandatory = $true)]
        [string]$Actor,
        [Parameter(Mandatory = $true)]
        [string]$Reason
    )

    return [pscustomobject][ordered]@{
        from_state = $FromState
        to_state = $ToState
        transitioned_at_utc = $Timestamp
        evidence_ref = $EvidenceRef
        actor = $Actor
        reason = $Reason
    }
}

function Write-CycleLedgerDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$LedgerPath,
        [Parameter(Mandatory = $true)]
        $Ledger
    )

    $parentPath = Split-Path -Parent $LedgerPath
    if (-not [string]::IsNullOrWhiteSpace($parentPath)) {
        New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    }

    $json = $Ledger | ConvertTo-Json -Depth 80
    Set-Content -LiteralPath $LedgerPath -Value $json -Encoding UTF8
}

function Test-WrittenCycleLedger {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$LedgerPath
    )

    $validation = & $script:TestCycleLedgerContract -LedgerPath $LedgerPath
    $PSCmdlet.WriteObject($validation, $false)
}

function Get-RequiredRefStatus {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Ledger,
        [Parameter(Mandatory = $true)]
        [string]$State,
        [Parameter(Mandatory = $true)]
        $Contract
    )

    $requirements = Get-StateRefRequirement -Contract $Contract -State $State
    $missing = @()
    $satisfied = @()

    foreach ($fieldName in @($requirements.singular_refs)) {
        $value = [string](Get-RequiredProperty -Object $Ledger -Name $fieldName -Context "Cycle ledger")
        if ([string]::IsNullOrWhiteSpace($value)) {
            $missing += $fieldName
        }
        else {
            $satisfied += $fieldName
        }
    }

    foreach ($fieldName in @($requirements.array_refs)) {
        $value = Get-RequiredProperty -Object $Ledger -Name $fieldName -Context "Cycle ledger"
        $items = Assert-StringArrayValue -Value $value -Context "Cycle ledger.$fieldName" -AllowEmpty
        if ($items.Count -eq 0) {
            $missing += $fieldName
        }
        else {
            $satisfied += $fieldName
        }
    }

    if ([bool]$requirements.approval_evidence_required) {
        $evidenceRefs = Assert-StringArrayValue -Value (Get-RequiredProperty -Object $Ledger -Name "evidence_refs" -Context "Cycle ledger") -Context "Cycle ledger.evidence_refs" -AllowEmpty
        $approvalEvidence = @($evidenceRefs | Where-Object { $_ -match $Contract.approval_evidence_pattern })
        if ($approvalEvidence.Count -eq 0) {
            $missing += "approval_evidence_ref"
        }
        else {
            $satisfied += "approval_evidence_ref"
        }
    }

    if ([bool]$requirements.refusal_reasons_required) {
        $refusalReasons = Assert-StringArrayValue -Value (Get-RequiredProperty -Object $Ledger -Name "refusal_reasons" -Context "Cycle ledger") -Context "Cycle ledger.refusal_reasons" -AllowEmpty
        if ($refusalReasons.Count -eq 0) {
            $missing += "refusal_reasons"
        }
        else {
            $satisfied += "refusal_reasons"
        }
    }

    $PSCmdlet.WriteObject([pscustomobject]@{
        Missing = $missing
        Satisfied = $satisfied
    }, $false)
}

function Assert-TargetStateRequirementsSatisfied {
    param(
        [Parameter(Mandatory = $true)]
        $Ledger,
        [Parameter(Mandatory = $true)]
        [string]$TargetState,
        [Parameter(Mandatory = $true)]
        $Contract
    )

    $refStatus = Get-RequiredRefStatus -Ledger $Ledger -State $TargetState -Contract $Contract
    if ($refStatus.Missing.Count -gt 0) {
        throw "Transition target state '$TargetState' is missing required refs: $($refStatus.Missing -join ', ')."
    }
}

function Update-CycleLedgerState {
    param(
        [Parameter(Mandatory = $true)]
        $Ledger,
        [Parameter(Mandatory = $true)]
        [string]$TargetState,
        [Parameter(Mandatory = $true)]
        [string]$Timestamp,
        [Parameter(Mandatory = $true)]
        $Foundation
    )

    Set-LedgerProperty -Ledger $Ledger -Name "state" -Value $TargetState
    Set-LedgerProperty -Ledger $Ledger -Name "allowed_next_states" -Value @(Get-AllowedTransitionsForState -Foundation $Foundation -State $TargetState)
    Set-LedgerProperty -Ledger $Ledger -Name "current_step" -Value (Get-CurrentStepForState -Foundation $Foundation -State $TargetState)
    Set-LedgerProperty -Ledger $Ledger -Name "updated_at_utc" -Value $Timestamp
}

function Add-CycleLedgerTransition {
    param(
        [Parameter(Mandatory = $true)]
        $Ledger,
        [Parameter(Mandatory = $true)]
        [string]$FromState,
        [Parameter(Mandatory = $true)]
        [string]$TargetState,
        [Parameter(Mandatory = $true)]
        [string]$Timestamp,
        [Parameter(Mandatory = $true)]
        [string]$EvidenceRef,
        [Parameter(Mandatory = $true)]
        [string]$Actor,
        [Parameter(Mandatory = $true)]
        [string]$Reason
    )

    if (-not (Test-HasProperty -Object $Ledger -Name "transition_history")) {
        throw "Cycle ledger is missing required field 'transition_history'."
    }

    $transitionHistory = @($Ledger.PSObject.Properties["transition_history"].Value)
    $transitionHistory += (New-TransitionEntry -FromState $FromState -ToState $TargetState -Timestamp $Timestamp -EvidenceRef $EvidenceRef -Actor $Actor -Reason $Reason)
    Set-LedgerProperty -Ledger $Ledger -Name "transition_history" -Value @($transitionHistory)
}

function Add-CycleLedgerEvidenceRefs {
    param(
        [Parameter(Mandatory = $true)]
        $Ledger,
        [AllowEmptyCollection()]
        [string[]]$Refs,
        [Parameter(Mandatory = $true)]
        $Foundation
    )

    foreach ($ref in @($Refs)) {
        Assert-OptionalRepoRef -Value $ref -Pattern $Foundation.repo_ref_pattern -Context "Controller evidence ref" | Out-Null
    }

    $existingRefs = Get-StringArrayProperty -Object $Ledger -Name "evidence_refs"
    $mergedRefs = Add-UniqueStringValues -Existing $existingRefs -Additional $Refs
    Set-LedgerProperty -Ledger $Ledger -Name "evidence_refs" -Value @($mergedRefs)
}

function Set-CycleLedgerRefs {
    param(
        [Parameter(Mandatory = $true)]
        $Ledger,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [string]$OperatorRequestRef,
        [string]$CyclePlanRef,
        [string]$BaselineRef,
        [string]$AuditPacketRef,
        [string]$DecisionPacketRef,
        [string[]]$DispatchRefs,
        [string[]]$ExecutionResultRefs,
        [string[]]$QaRefs
    )

    foreach ($entry in @(
            @{ Name = "operator_request_ref"; ParameterName = "OperatorRequestRef"; Value = $OperatorRequestRef },
            @{ Name = "cycle_plan_ref"; ParameterName = "CyclePlanRef"; Value = $CyclePlanRef },
            @{ Name = "baseline_ref"; ParameterName = "BaselineRef"; Value = $BaselineRef },
            @{ Name = "audit_packet_ref"; ParameterName = "AuditPacketRef"; Value = $AuditPacketRef },
            @{ Name = "decision_packet_ref"; ParameterName = "DecisionPacketRef"; Value = $DecisionPacketRef }
        )) {
        if ($PSBoundParameters.ContainsKey($entry.ParameterName)) {
            $ref = Assert-OptionalRepoRef -Value $entry.Value -Pattern $Foundation.repo_ref_pattern -Context "Controller $($entry.Name)"
            Set-LedgerProperty -Ledger $Ledger -Name $entry.Name -Value $ref
        }
    }

    foreach ($entry in @(
            @{ Name = "dispatch_refs"; Value = $DispatchRefs; ParameterName = "DispatchRefs" },
            @{ Name = "execution_result_refs"; Value = $ExecutionResultRefs; ParameterName = "ExecutionResultRefs" },
            @{ Name = "qa_refs"; Value = $QaRefs; ParameterName = "QaRefs" }
        )) {
        if ($PSBoundParameters.ContainsKey($entry.ParameterName)) {
            $refs = Assert-StringArrayValue -Value $entry.Value -Context "Controller $($entry.Name)" -AllowEmpty
            foreach ($ref in $refs) {
                Assert-OptionalRepoRef -Value $ref -Pattern $Foundation.repo_ref_pattern -Context "Controller $($entry.Name) item" | Out-Null
            }

            Set-LedgerProperty -Ledger $Ledger -Name $entry.Name -Value @($refs)
        }
    }
}

function Initialize-CycleControllerLedger {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$CycleId,
        [Parameter(Mandatory = $true)]
        [string]$OutputPath,
        [Parameter(Mandatory = $true)]
        [string]$HeadSha,
        [Parameter(Mandatory = $true)]
        [string]$TreeSha,
        [string]$Repository = "",
        [string]$Branch = "",
        [string]$OperatorRequestRef = "",
        [string]$GovernedRoot = "state/cycle_controller",
        [switch]$Overwrite,
        [switch]$AllowOutsideGovernedRoot
    )

    $foundation = Get-CycleControllerFoundationContract
    $contract = Get-CycleLedgerContractDefinition
    $repositoryValue = if ([string]::IsNullOrWhiteSpace($Repository)) { $foundation.repository } else { $Repository }
    $branchValue = if ([string]::IsNullOrWhiteSpace($Branch)) { $foundation.branch } else { $Branch }

    Assert-NoForbiddenControllerText -Value @($CycleId, $RepositoryValue, $BranchValue, $OperatorRequestRef) -Context "Initialize controller input" -Foundation $foundation
    Assert-MatchesPattern -Value (Assert-NonEmptyString -Value $CycleId -Context "Controller cycle_id") -Pattern $foundation.identifier_pattern -Context "Controller cycle_id"
    Assert-RepositoryIdentity -Repository $repositoryValue -Branch $branchValue -Foundation $foundation
    Assert-GitIdentity -HeadSha $HeadSha -TreeSha $TreeSha -Foundation $foundation
    $operatorRequestRefValue = Assert-OptionalRepoRef -Value $OperatorRequestRef -Pattern $foundation.repo_ref_pattern -Context "Controller operator_request_ref"

    $resolvedOutputPath = Resolve-GovernedOutputPath -OutputPath $OutputPath -GovernedRoot $GovernedRoot -AllowOutsideGovernedRoot:$AllowOutsideGovernedRoot
    if (Test-Path -LiteralPath $resolvedOutputPath -PathType Leaf) {
        if (-not $Overwrite) {
            throw "Cycle ledger '$OutputPath' already exists. Use -Overwrite to replace it explicitly."
        }
    }

    $createdAt = Get-UtcTimestamp
    $state = if ([string]::IsNullOrWhiteSpace($operatorRequestRefValue)) { "initialized" } else { "request_recorded" }
    $initializeEvidenceRef = "state/cycle_controller/$CycleId/controller_initialize.evidence.json"
    $transitionHistory = @(
        (New-TransitionEntry -FromState $foundation.initial_transition_from -ToState "initialized" -Timestamp $createdAt -EvidenceRef $initializeEvidenceRef -Actor "R11-003-cycle-controller" -Reason "Initialize the cycle ledger from repo-truth controller input.")
    )

    $evidenceRefs = @()
    if ($state -eq "request_recorded") {
        $transitionHistory += (New-TransitionEntry -FromState "initialized" -ToState "request_recorded" -Timestamp $createdAt -EvidenceRef $operatorRequestRefValue -Actor "R11-003-cycle-controller" -Reason "Record the operator request ref during cycle initialization.")
        $evidenceRefs += $operatorRequestRefValue
    }

    $ledger = [pscustomobject][ordered]@{
        contract_version = $foundation.contract_version
        artifact_type = $foundation.cycle_ledger_artifact_type
        cycle_id = $CycleId
        repository = $foundation.repository
        branch = $foundation.branch
        milestone = $foundation.milestone
        source_task = $foundation.source_task
        controller_authority = [pscustomobject][ordered]@{
            authority_type = $foundation.authority_type
            state_authority = $foundation.state_authority
            committed_state_required = $true
            chat_memory_authority_allowed = $false
            statement = "The committed cycle ledger artifact is the authority for cycle state. Chat transcripts, Codex narration, operator memory, and manual assertions are not cycle state authority."
        }
        state = $state
        allowed_next_states = @(Get-AllowedTransitionsForState -Foundation $foundation -State $state)
        current_step = Get-CurrentStepForState -Foundation $foundation -State $state
        operator_request_ref = $operatorRequestRefValue
        cycle_plan_ref = ""
        baseline_ref = ""
        dispatch_refs = @()
        execution_result_refs = @()
        qa_refs = @()
        audit_packet_ref = ""
        decision_packet_ref = ""
        head_sha = $HeadSha
        tree_sha = $TreeSha
        created_at_utc = $createdAt
        updated_at_utc = $createdAt
        transition_history = @($transitionHistory)
        evidence_refs = @($evidenceRefs)
        refusal_reasons = @()
        non_claims = @($foundation.required_non_claims)
    }

    Assert-TargetStateRequirementsSatisfied -Ledger $ledger -TargetState $state -Contract $contract
    Write-CycleLedgerDocument -LedgerPath $resolvedOutputPath -Ledger $ledger
    $validation = Test-WrittenCycleLedger -LedgerPath $resolvedOutputPath

    $result = [pscustomobject][ordered]@{
        ArtifactType = "cycle_controller_result"
        Command = "initialize"
        Status = "succeeded"
        LedgerPath = $resolvedOutputPath
        CycleId = $validation.CycleId
        State = $validation.State
        CurrentStep = $validation.CurrentStep
        AllowedNextStates = @($validation.AllowedNextStates)
        HeadSha = $validation.HeadSha
        TreeSha = $validation.TreeSha
        NonClaims = @($validation.NonClaims)
    }

    $PSCmdlet.WriteObject($result, $false)
}

function Inspect-CycleControllerLedger {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$LedgerPath
    )

    $foundation = Get-CycleControllerFoundationContract
    $contract = Get-CycleLedgerContractDefinition
    $resolvedLedgerPath = Resolve-ExistingPath -PathValue $LedgerPath -Label "Cycle ledger"
    $validation = Test-WrittenCycleLedger -LedgerPath $resolvedLedgerPath
    $ledger = & $script:GetCycleLedger -LedgerPath $resolvedLedgerPath
    $refStatus = Get-RequiredRefStatus -Ledger $ledger -State $ledger.state -Contract $contract

    $result = [pscustomobject][ordered]@{
        ArtifactType = "cycle_controller_status"
        LedgerPath = $resolvedLedgerPath
        CycleId = $validation.CycleId
        Repository = $validation.Repository
        Branch = $validation.Branch
        Milestone = $validation.Milestone
        SourceTask = $validation.SourceTask
        State = $validation.State
        CurrentStep = $validation.CurrentStep
        AllowedNextStates = @($validation.AllowedNextStates)
        RequiredRefs = [pscustomobject][ordered]@{
            Missing = @($refStatus.Missing)
            Satisfied = @($refStatus.Satisfied)
        }
        HeadSha = $validation.HeadSha
        TreeSha = $validation.TreeSha
        TransitionCount = $validation.TransitionCount
        NonClaims = @($validation.NonClaims)
        ControllerAuthority = [pscustomobject][ordered]@{
            AuthorityType = $foundation.authority_type
            StateAuthority = $foundation.state_authority
        }
    }

    $PSCmdlet.WriteObject($result, $false)
}

function Advance-CycleControllerLedger {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$LedgerPath,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$TargetState,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$EvidenceRef,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Actor,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Reason,
        [string]$OperatorRequestRef,
        [string]$CyclePlanRef,
        [string]$BaselineRef,
        [string[]]$DispatchRefs,
        [string[]]$ExecutionResultRefs,
        [string[]]$QaRefs,
        [string]$AuditPacketRef,
        [string]$DecisionPacketRef,
        [string[]]$AdditionalEvidenceRefs
    )

    $foundation = Get-CycleControllerFoundationContract
    $contract = Get-CycleLedgerContractDefinition
    Assert-NoForbiddenControllerText -Value @($TargetState, $EvidenceRef, $Actor, $Reason, $OperatorRequestRef, $CyclePlanRef, $BaselineRef, $AuditPacketRef, $DecisionPacketRef, $AdditionalEvidenceRefs) -Context "Advance controller input" -Foundation $foundation
    Assert-AllowedValue -Value (Assert-NonEmptyString -Value $TargetState -Context "Controller target state") -AllowedValues @($foundation.allowed_states) -Context "Controller target state"
    $evidenceRefValue = Assert-OptionalRepoRef -Value (Assert-NonEmptyString -Value $EvidenceRef -Context "Controller evidence_ref") -Pattern $foundation.repo_ref_pattern -Context "Controller evidence_ref"
    $actorValue = Assert-NonEmptyString -Value $Actor -Context "Controller actor"
    $reasonValue = Assert-NonEmptyString -Value $Reason -Context "Controller reason"

    $resolvedLedgerPath = Resolve-ExistingPath -PathValue $LedgerPath -Label "Cycle ledger"
    $ledger = & $script:GetCycleLedger -LedgerPath $resolvedLedgerPath
    $fromState = [string]$ledger.state
    if (@($foundation.terminal_states) -contains $fromState) {
        throw "Cannot transition from terminal state '$fromState'."
    }

    $allowedTransitions = @(Get-AllowedTransitionsForState -Foundation $foundation -State $fromState)
    if ($allowedTransitions -notcontains $TargetState) {
        throw "Illegal transition from '$fromState' to '$TargetState'. Allowed next states: $($allowedTransitions -join ', ')."
    }

    if (@("blocked", "stopped") -contains $TargetState) {
        throw "Use Refuse-CycleControllerLedger for terminal refusal target '$TargetState'."
    }

    $setRefParameters = @{
        Ledger = $ledger
        Foundation = $foundation
    }
    foreach ($entry in @(
            @{ Name = "OperatorRequestRef"; Value = $OperatorRequestRef },
            @{ Name = "CyclePlanRef"; Value = $CyclePlanRef },
            @{ Name = "BaselineRef"; Value = $BaselineRef },
            @{ Name = "AuditPacketRef"; Value = $AuditPacketRef },
            @{ Name = "DecisionPacketRef"; Value = $DecisionPacketRef },
            @{ Name = "DispatchRefs"; Value = $DispatchRefs },
            @{ Name = "ExecutionResultRefs"; Value = $ExecutionResultRefs },
            @{ Name = "QaRefs"; Value = $QaRefs }
        )) {
        if ($PSBoundParameters.ContainsKey($entry.Name)) {
            $setRefParameters[$entry.Name] = $entry.Value
        }
    }
    Set-CycleLedgerRefs @setRefParameters

    $additionalRefs = Assert-StringArrayValue -Value $AdditionalEvidenceRefs -Context "Controller additional_evidence_refs" -AllowEmpty
    $allEvidenceRefs = @($evidenceRefValue) + @($additionalRefs)
    Add-CycleLedgerEvidenceRefs -Ledger $ledger -Refs $allEvidenceRefs -Foundation $foundation

    Assert-TargetStateRequirementsSatisfied -Ledger $ledger -TargetState $TargetState -Contract $contract
    $timestamp = Get-UtcTimestamp
    Add-CycleLedgerTransition -Ledger $ledger -FromState $fromState -TargetState $TargetState -Timestamp $timestamp -EvidenceRef $evidenceRefValue -Actor $actorValue -Reason $reasonValue
    Update-CycleLedgerState -Ledger $ledger -TargetState $TargetState -Timestamp $timestamp -Foundation $foundation

    Write-CycleLedgerDocument -LedgerPath $resolvedLedgerPath -Ledger $ledger
    $validation = Test-WrittenCycleLedger -LedgerPath $resolvedLedgerPath

    $result = [pscustomobject][ordered]@{
        ArtifactType = "cycle_controller_result"
        Command = "advance"
        Status = "succeeded"
        LedgerPath = $resolvedLedgerPath
        CycleId = $validation.CycleId
        FromState = $fromState
        State = $validation.State
        CurrentStep = $validation.CurrentStep
        AllowedNextStates = @($validation.AllowedNextStates)
        TransitionCount = $validation.TransitionCount
        NonClaims = @($validation.NonClaims)
    }

    $PSCmdlet.WriteObject($result, $false)
}

function Refuse-CycleControllerLedger {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$LedgerPath,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$TargetState,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$EvidenceRef,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Actor,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Reason,
        [Parameter(Mandatory = $true)]
        [string[]]$RefusalReasons
    )

    $foundation = Get-CycleControllerFoundationContract
    $contract = Get-CycleLedgerContractDefinition
    Assert-NoForbiddenControllerText -Value @($TargetState, $EvidenceRef, $Actor, $Reason, $RefusalReasons) -Context "Refuse controller input" -Foundation $foundation

    if (@("blocked", "stopped") -notcontains $TargetState) {
        throw "Refusal target state must be 'blocked' or 'stopped'."
    }

    $evidenceRefValue = Assert-OptionalRepoRef -Value (Assert-NonEmptyString -Value $EvidenceRef -Context "Controller evidence_ref") -Pattern $foundation.repo_ref_pattern -Context "Controller evidence_ref"
    $actorValue = Assert-NonEmptyString -Value $Actor -Context "Controller actor"
    $reasonValue = Assert-NonEmptyString -Value $Reason -Context "Controller reason"
    $refusalReasonValues = Assert-StringArrayValue -Value $RefusalReasons -Context "Controller refusal_reasons"

    $resolvedLedgerPath = Resolve-ExistingPath -PathValue $LedgerPath -Label "Cycle ledger"
    $ledger = & $script:GetCycleLedger -LedgerPath $resolvedLedgerPath
    $fromState = [string]$ledger.state
    if (@($foundation.terminal_states) -contains $fromState) {
        throw "Cannot transition from terminal state '$fromState'."
    }

    $allowedTransitions = @(Get-AllowedTransitionsForState -Foundation $foundation -State $fromState)
    if ($allowedTransitions -notcontains $TargetState) {
        throw "Illegal transition from '$fromState' to '$TargetState'. Allowed next states: $($allowedTransitions -join ', ')."
    }

    Add-CycleLedgerEvidenceRefs -Ledger $ledger -Refs @($evidenceRefValue) -Foundation $foundation
    Set-LedgerProperty -Ledger $ledger -Name "refusal_reasons" -Value @($refusalReasonValues)
    Assert-TargetStateRequirementsSatisfied -Ledger $ledger -TargetState $TargetState -Contract $contract

    $timestamp = Get-UtcTimestamp
    Add-CycleLedgerTransition -Ledger $ledger -FromState $fromState -TargetState $TargetState -Timestamp $timestamp -EvidenceRef $evidenceRefValue -Actor $actorValue -Reason $reasonValue
    Update-CycleLedgerState -Ledger $ledger -TargetState $TargetState -Timestamp $timestamp -Foundation $foundation

    Write-CycleLedgerDocument -LedgerPath $resolvedLedgerPath -Ledger $ledger
    $validation = Test-WrittenCycleLedger -LedgerPath $resolvedLedgerPath

    $result = [pscustomobject][ordered]@{
        ArtifactType = "cycle_controller_result"
        Command = "refuse"
        Status = "succeeded"
        LedgerPath = $resolvedLedgerPath
        CycleId = $validation.CycleId
        FromState = $fromState
        State = $validation.State
        CurrentStep = $validation.CurrentStep
        AllowedNextStates = @($validation.AllowedNextStates)
        TransitionCount = $validation.TransitionCount
        RefusalReasons = @($refusalReasonValues)
        NonClaims = @($validation.NonClaims)
    }

    $PSCmdlet.WriteObject($result, $false)
}

Export-ModuleMember -Function Initialize-CycleControllerLedger, Inspect-CycleControllerLedger, Advance-CycleControllerLedger, Refuse-CycleControllerLedger
