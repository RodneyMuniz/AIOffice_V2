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

function ConvertTo-RepoRef {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue
    )

    $resolvedPath = Resolve-PathValue -PathValue $PathValue
    $resolvedRoot = Get-ModuleRepositoryRootPath
    if (-not $resolvedRoot.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $resolvedRoot = $resolvedRoot + [System.IO.Path]::DirectorySeparatorChar
    }

    if (-not $resolvedPath.StartsWith($resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Path '$PathValue' cannot be represented as an in-repository evidence ref."
    }

    return $resolvedPath.Substring($resolvedRoot.Length).Replace("\", "/")
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

function Get-CycleBootstrapPacketContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "cycle_controller", "cycle_bootstrap_packet.contract.json")) -Label "Cycle bootstrap packet contract"
}

function Get-CycleNextActionPacketContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "cycle_controller", "cycle_next_action_packet.contract.json")) -Label "Cycle next-action packet contract"
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

function Assert-TimestampValue {
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
        [System.DateTimeOffset]::ParseExact($Value, "yyyy-MM-dd'T'HH:mm:ss'Z'", [System.Globalization.CultureInfo]::InvariantCulture, $styles) | Out-Null
    }
    catch {
        throw "$Context must be a valid UTC timestamp."
    }
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

function Assert-RepoRefValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-NonEmptyString -Value $Value -Context $Context | Out-Null
    Assert-MatchesPattern -Value $Value -Pattern $Foundation.repo_ref_pattern -Context $Context
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

    if ($null -eq $Object -or $Object -is [string] -or $Object -is [System.Array]) {
        throw "$Context must be an object."
    }

    foreach ($fieldName in $FieldNames) {
        Get-RequiredProperty -Object $Object -Name $fieldName -Context $Context | Out-Null
    }
}

function Assert-NoPositiveOverclaim {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($null -eq $Value) {
        return
    }

    $items = if ($Value -is [System.Array]) { @($Value) } else { @($Value) }
    $forbiddenPattern = '(?i)\b(open|opened|active|complete|accepted)\b.{0,80}\b(R12|successor milestone)\b|\b(R12|successor milestone)\b.{0,80}\b(active|open|opened|complete|accepted)\b|\b(broad autonomous milestone execution|broad autonomy|UI/control-room productization|control-room productization|Standard runtime|multi-repo orchestration|swarms|unattended automatic resume|solved Codex context compaction|hours-long unattended execution|production runtime|productized control-room behavior|general Codex reliability)\b'
    $negationPattern = '(?i)\b(no|not|without|does not|do not|has not|non-claim|nonclaims|non-scope|not implemented|must not|refuse|refuses|reject|rejects|planned only)\b'

    foreach ($item in $items) {
        if ($item -isnot [string]) {
            continue
        }

        if ($item -match $forbiddenPattern -and $item -notmatch $negationPattern) {
            throw "$Context must not imply unattended automatic resume, solved compaction, broad autonomy, productization, runtime, orchestration, production, general reliability, or successor opening."
        }
    }
}

function Assert-AuthorityTextAllowed {
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
    foreach ($item in $items) {
        if ($item -isnot [string]) {
            continue
        }

        $negationPattern = '(?i)\b(no|not|never|without|not cycle state authority|not state authority|non-authoritative)\b'
        if ($item -match $Foundation.forbidden_controller_authority_pattern -and $item -notmatch $negationPattern) {
            throw "$Context must not use chat transcript, chat memory, narration, manual assertion, or operator memory as cycle state authority."
        }
    }
}

function Get-UtcTimestamp {
    return [System.DateTimeOffset]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture)
}

function Get-CurrentGitRef {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Revision
    )

    $value = (& git -C (Get-RepositoryRoot) rev-parse $Revision 2>$null)
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($value)) {
        throw "Unable to resolve current Git ref '$Revision'."
    }

    return [string]($value.Trim())
}

function Get-AllowedTransitionsForState {
    param(
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        [string]$State
    )

    return @(Get-DynamicObjectProperty -Object $Foundation.allowed_transitions -Name $State -Context "Cycle bootstrap transition model")
}

function Get-CurrentStepForState {
    param(
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        [string]$State
    )

    return [string](Get-DynamicObjectProperty -Object $Foundation.current_step_by_state -Name $State -Context "Cycle bootstrap current-step model")
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

function Add-UniqueStringValues {
    [CmdletBinding()]
    param(
        [AllowEmptyCollection()]
        [string[]]$Values
    )

    $items = @()
    foreach ($value in @($Values)) {
        if ([string]::IsNullOrWhiteSpace($value)) {
            continue
        }

        if ($items -notcontains $value) {
            $items += $value
        }
    }

    $PSCmdlet.WriteObject($items, $false)
}

function Get-RequiredInputsForTargetState {
    [CmdletBinding()]
    param(
        [AllowNull()]
        [string]$TargetState,
        [Parameter(Mandatory = $true)]
        $LedgerContract
    )

    if ([string]::IsNullOrWhiteSpace($TargetState)) {
        $PSCmdlet.WriteObject(@(), $false)
        return
    }

    $requirements = Get-StateRefRequirement -Contract $LedgerContract -State $TargetState
    $inputs = @($requirements.singular_refs) + @($requirements.array_refs)
    if ([bool]$requirements.approval_evidence_required) {
        $inputs += "operator_approval_evidence_ref"
    }
    if ([bool]$requirements.refusal_reasons_required) {
        $inputs += "refusal_reasons"
    }

    $inputs += @("evidence_ref", "actor", "reason")
    $PSCmdlet.WriteObject((Add-UniqueStringValues -Values $inputs), $false)
}

function Get-RecommendedTargetState {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [string[]]$AllowedNextStates,
        [string]$PreferredTargetState = ""
    )

    if (-not [string]::IsNullOrWhiteSpace($PreferredTargetState)) {
        if ($AllowedNextStates -notcontains $PreferredTargetState) {
            throw "Next-action target state '$PreferredTargetState' is outside allowed_next_states: $($AllowedNextStates -join ', ')."
        }

        return $PreferredTargetState
    }

    $nonRefusalTargets = @($AllowedNextStates | Where-Object { @("blocked", "stopped") -notcontains $_ })
    if ($nonRefusalTargets.Count -gt 0) {
        return $nonRefusalTargets[0]
    }

    if ($AllowedNextStates.Count -gt 0) {
        return $AllowedNextStates[0]
    }

    return ""
}

function Get-RecommendedAction {
    param(
        [AllowNull()]
        [string]$TargetState,
        [Parameter(Mandatory = $true)]
        $NextActionContract
    )

    if ([string]::IsNullOrWhiteSpace($TargetState)) {
        return $NextActionContract.terminal_recommended_action
    }

    if (@("blocked", "stopped") -contains $TargetState) {
        return "refuse_to_$TargetState"
    }

    return "advance_to_$TargetState"
}

function Resolve-GovernedOutputPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [string]$GovernedRoot = "state/cycle_controller",
        [switch]$AllowOutsideGovernedRoot
    )

    Assert-NonEmptyString -Value $PathValue -Context "Cycle bootstrap output path" | Out-Null
    $resolvedOutputPath = Resolve-PathValue -PathValue $PathValue
    $resolvedGovernedRoot = Resolve-PathValue -PathValue $GovernedRoot

    if (-not $resolvedGovernedRoot.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $resolvedGovernedRoot += [System.IO.Path]::DirectorySeparatorChar
    }

    if (-not $AllowOutsideGovernedRoot -and -not $resolvedOutputPath.StartsWith($resolvedGovernedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Cycle bootstrap output path '$PathValue' is outside governed output root '$GovernedRoot'."
    }

    return $resolvedOutputPath
}

function Write-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Document
    )

    $parentPath = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($parentPath)) {
        New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    }

    $json = $Document | ConvertTo-Json -Depth 80
    Set-Content -LiteralPath $Path -Value $json -Encoding UTF8
}

function Assert-CanWriteOutput {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [switch]$Overwrite
    )

    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        if (-not $Overwrite) {
            throw "Cycle bootstrap output '$Path' already exists. Use -Overwrite to replace it explicitly."
        }
    }
}

function Assert-PacketCommonFields {
    param(
        [Parameter(Mandatory = $true)]
        $Packet,
        [Parameter(Mandatory = $true)]
        [string]$ArtifactType,
        [Parameter(Mandatory = $true)]
        [string]$SourceTask,
        [Parameter(Mandatory = $true)]
        [string]$SourceLabel,
        [Parameter(Mandatory = $true)]
        $Foundation
    )

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet -Name "contract_version" -Context $SourceLabel) -Context "$SourceLabel.contract_version"
    if ($contractVersion -ne $Foundation.contract_version) {
        throw "$SourceLabel.contract_version must be '$($Foundation.contract_version)'."
    }

    $packetArtifactType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet -Name "artifact_type" -Context $SourceLabel) -Context "$SourceLabel.artifact_type"
    if ($packetArtifactType -ne $ArtifactType) {
        throw "$SourceLabel.artifact_type must be '$ArtifactType'."
    }

    $repository = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet -Name "repository" -Context $SourceLabel) -Context "$SourceLabel.repository"
    if ($repository -ne $Foundation.repository) {
        throw "$SourceLabel.repository must be '$($Foundation.repository)'."
    }

    $branch = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet -Name "branch" -Context $SourceLabel) -Context "$SourceLabel.branch"
    if ($branch -ne $Foundation.branch) {
        throw "$SourceLabel.branch must be '$($Foundation.branch)'."
    }

    $milestone = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet -Name "milestone" -Context $SourceLabel) -Context "$SourceLabel.milestone"
    if ($milestone -ne $Foundation.milestone) {
        throw "$SourceLabel.milestone must be '$($Foundation.milestone)'."
    }

    $packetSourceTask = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet -Name "source_task" -Context $SourceLabel) -Context "$SourceLabel.source_task"
    if ($packetSourceTask -ne $SourceTask) {
        throw "$SourceLabel.source_task must be '$SourceTask'."
    }

    $cycleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet -Name "cycle_id" -Context $SourceLabel) -Context "$SourceLabel.cycle_id"
    Assert-MatchesPattern -Value $cycleId -Pattern $Foundation.identifier_pattern -Context "$SourceLabel.cycle_id"

    Assert-RepoRefValue -Value (Get-RequiredProperty -Object $Packet -Name "cycle_ledger_ref" -Context $SourceLabel) -Foundation $Foundation -Context "$SourceLabel.cycle_ledger_ref"
    Assert-AllowedValue -Value (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet -Name "ledger_state" -Context $SourceLabel) -Context "$SourceLabel.ledger_state") -AllowedValues @($Foundation.allowed_states) -Context "$SourceLabel.ledger_state"
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet -Name "ledger_current_step" -Context $SourceLabel) -Context "$SourceLabel.ledger_current_step" | Out-Null

    $headSha = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet -Name "head_sha" -Context $SourceLabel) -Context "$SourceLabel.head_sha"
    $treeSha = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet -Name "tree_sha" -Context $SourceLabel) -Context "$SourceLabel.tree_sha"
    Assert-MatchesPattern -Value $headSha -Pattern $Foundation.git_sha_pattern -Context "$SourceLabel.head_sha"
    Assert-MatchesPattern -Value $treeSha -Pattern $Foundation.git_sha_pattern -Context "$SourceLabel.tree_sha"
    Assert-TimestampValue -Value (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet -Name "created_at_utc" -Context $SourceLabel) -Context "$SourceLabel.created_at_utc") -Pattern $Foundation.timestamp_pattern -Context "$SourceLabel.created_at_utc"

    $nonClaims = Assert-StringArrayValue -Value (Get-RequiredProperty -Object $Packet -Name "non_claims" -Context $SourceLabel) -Context "$SourceLabel.non_claims"
    foreach ($requiredNonClaim in @($Foundation.required_non_claims)) {
        if ($nonClaims -notcontains $requiredNonClaim) {
            throw "$SourceLabel.non_claims must include '$requiredNonClaim'."
        }
    }

    Assert-NoPositiveOverclaim -Value $nonClaims -Context "$SourceLabel.non_claims"
}

function Get-LedgerForPacketRef {
    param(
        [Parameter(Mandatory = $true)]
        [string]$CycleLedgerRef,
        [string]$AnchorPath = (Get-ModuleRepositoryRootPath)
    )

    $ledgerPath = Resolve-PathValue -PathValue $CycleLedgerRef -AnchorPath (Get-ModuleRepositoryRootPath)
    if (-not (Test-Path -LiteralPath $ledgerPath)) {
        throw "Cycle packet cycle_ledger_ref '$CycleLedgerRef' does not exist."
    }

    return (& $script:GetCycleLedger -LedgerPath $ledgerPath)
}

function Assert-PacketMatchesLedger {
    param(
        [Parameter(Mandatory = $true)]
        $Packet,
        [Parameter(Mandatory = $true)]
        $Ledger,
        [Parameter(Mandatory = $true)]
        [string]$SourceLabel
    )

    foreach ($entry in @(
            @{ Name = "cycle_id"; Expected = $Ledger.cycle_id },
            @{ Name = "repository"; Expected = $Ledger.repository },
            @{ Name = "branch"; Expected = $Ledger.branch },
            @{ Name = "milestone"; Expected = $Ledger.milestone },
            @{ Name = "ledger_state"; Expected = $Ledger.state },
            @{ Name = "ledger_current_step"; Expected = $Ledger.current_step },
            @{ Name = "head_sha"; Expected = $Ledger.head_sha },
            @{ Name = "tree_sha"; Expected = $Ledger.tree_sha }
        )) {
        $actual = [string](Get-RequiredProperty -Object $Packet -Name $entry.Name -Context $SourceLabel)
        if ($actual -ne $entry.Expected) {
            throw "$SourceLabel.$($entry.Name) must match the validated cycle ledger."
        }
    }
}

function Test-CycleNextActionPacketObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Packet,
        [string]$SourceLabel = "Cycle next-action packet",
        [string]$AnchorPath = (Get-ModuleRepositoryRootPath)
    )

    $foundation = Get-CycleControllerFoundationContract
    $contract = Get-CycleNextActionPacketContract
    Assert-RequiredObjectFields -Object $Packet -FieldNames @($contract.required_fields) -Context $SourceLabel
    Assert-PacketCommonFields -Packet $Packet -ArtifactType $contract.next_action_packet_artifact_type -SourceTask $contract.source_task -SourceLabel $SourceLabel -Foundation $foundation

    $nextActionId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet -Name "next_action_id" -Context $SourceLabel) -Context "$SourceLabel.next_action_id"
    Assert-MatchesPattern -Value $nextActionId -Pattern $foundation.identifier_pattern -Context "$SourceLabel.next_action_id"

    $ledgerState = [string](Get-RequiredProperty -Object $Packet -Name "ledger_state" -Context $SourceLabel)
    $expectedCurrentStep = Get-CurrentStepForState -Foundation $foundation -State $ledgerState
    $ledgerCurrentStep = [string](Get-RequiredProperty -Object $Packet -Name "ledger_current_step" -Context $SourceLabel)
    if ($ledgerCurrentStep -ne $expectedCurrentStep) {
        throw "$SourceLabel.ledger_current_step must match ledger_state '$ledgerState'."
    }

    $allowedTargetStates = Assert-StringArrayValue -Value (Get-RequiredProperty -Object $Packet -Name "allowed_target_states" -Context $SourceLabel) -Context "$SourceLabel.allowed_target_states" -AllowEmpty
    foreach ($targetState in $allowedTargetStates) {
        Assert-AllowedValue -Value $targetState -AllowedValues @($foundation.allowed_states) -Context "$SourceLabel.allowed_target_states item"
    }

    $recommendedAction = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet -Name "recommended_action" -Context $SourceLabel) -Context "$SourceLabel.recommended_action"
    $recommendedTarget = ""
    if ($recommendedAction -match '^(advance|refuse)_to_(.+)$') {
        $recommendedTarget = $Matches[2]
        if ($allowedTargetStates -notcontains $recommendedTarget) {
            throw "$SourceLabel.recommended_action target '$recommendedTarget' is outside allowed_target_states."
        }
    }
    elseif ($recommendedAction -ne $contract.terminal_recommended_action) {
        throw "$SourceLabel.recommended_action must be an advance/refuse action or '$($contract.terminal_recommended_action)'."
    }

    Assert-StringArrayValue -Value (Get-RequiredProperty -Object $Packet -Name "required_inputs" -Context $SourceLabel) -Context "$SourceLabel.required_inputs" -AllowEmpty | Out-Null
    Assert-StringArrayValue -Value (Get-RequiredProperty -Object $Packet -Name "blocked_reasons" -Context $SourceLabel) -Context "$SourceLabel.blocked_reasons" -AllowEmpty | Out-Null
    Assert-BooleanValue -Value (Get-RequiredProperty -Object $Packet -Name "operator_decision_required" -Context $SourceLabel) -Context "$SourceLabel.operator_decision_required" | Out-Null
    Assert-NoPositiveOverclaim -Value @($recommendedAction, (Get-RequiredProperty -Object $Packet -Name "required_inputs" -Context $SourceLabel), (Get-RequiredProperty -Object $Packet -Name "blocked_reasons" -Context $SourceLabel)) -Context $SourceLabel

    $ledgerRef = [string](Get-RequiredProperty -Object $Packet -Name "cycle_ledger_ref" -Context $SourceLabel)
    $ledger = Get-LedgerForPacketRef -CycleLedgerRef $ledgerRef -AnchorPath $AnchorPath
    if ($null -ne $ledger) {
        Assert-PacketMatchesLedger -Packet $Packet -Ledger $ledger -SourceLabel $SourceLabel
        $expectedTargets = @($ledger.allowed_next_states)
        if ($allowedTargetStates.Count -ne $expectedTargets.Count) {
            throw "$SourceLabel.allowed_target_states must match ledger.allowed_next_states."
        }
        for ($index = 0; $index -lt $expectedTargets.Count; $index += 1) {
            if ($allowedTargetStates[$index] -ne $expectedTargets[$index]) {
                throw "$SourceLabel.allowed_target_states must match ledger.allowed_next_states."
            }
        }
    }

    $PSCmdlet.WriteObject([pscustomobject]@{
        IsValid = $true
        PacketId = $nextActionId
        CycleId = [string](Get-RequiredProperty -Object $Packet -Name "cycle_id" -Context $SourceLabel)
        LedgerState = $ledgerState
        RecommendedAction = $recommendedAction
        AllowedTargetStates = @($allowedTargetStates)
        SourceLabel = $SourceLabel
    }, $false)
}

function Test-CycleNextActionPacketContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PacketPath
    )

    $resolvedPacketPath = Resolve-ExistingPath -PathValue $PacketPath -Label "Cycle next-action packet"
    $packet = Get-JsonDocument -Path $resolvedPacketPath -Label "Cycle next-action packet"
    $validation = Test-CycleNextActionPacketObject -Packet $packet -SourceLabel "Cycle next-action packet" -AnchorPath (Get-ModuleRepositoryRootPath)
    $PSCmdlet.WriteObject($validation, $false)
}

function Test-CycleBootstrapPacketObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Packet,
        [string]$SourceLabel = "Cycle bootstrap packet",
        [string]$AnchorPath = (Get-ModuleRepositoryRootPath)
    )

    $foundation = Get-CycleControllerFoundationContract
    $contract = Get-CycleBootstrapPacketContract
    Assert-RequiredObjectFields -Object $Packet -FieldNames @($contract.required_fields) -Context $SourceLabel
    Assert-PacketCommonFields -Packet $Packet -ArtifactType $contract.bootstrap_packet_artifact_type -SourceTask $contract.source_task -SourceLabel $SourceLabel -Foundation $foundation

    $bootstrapId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet -Name "bootstrap_id" -Context $SourceLabel) -Context "$SourceLabel.bootstrap_id"
    Assert-MatchesPattern -Value $bootstrapId -Pattern $foundation.identifier_pattern -Context "$SourceLabel.bootstrap_id"

    $allowedNextStates = Assert-StringArrayValue -Value (Get-RequiredProperty -Object $Packet -Name "allowed_next_states" -Context $SourceLabel) -Context "$SourceLabel.allowed_next_states" -AllowEmpty
    foreach ($allowedNextState in $allowedNextStates) {
        Assert-AllowedValue -Value $allowedNextState -AllowedValues @($foundation.allowed_states) -Context "$SourceLabel.allowed_next_states item"
    }

    $nextActionPacketRef = [string](Get-RequiredProperty -Object $Packet -Name "next_action_packet_ref" -Context $SourceLabel)
    Assert-RepoRefValue -Value $nextActionPacketRef -Foundation $foundation -Context "$SourceLabel.next_action_packet_ref"
    $bootstrapSource = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet -Name "bootstrap_source" -Context $SourceLabel) -Context "$SourceLabel.bootstrap_source"
    if ($bootstrapSource -ne $contract.bootstrap_source) {
        throw "$SourceLabel.bootstrap_source must be '$($contract.bootstrap_source)'."
    }

    $stateAuthority = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet -Name "state_authority" -Context $SourceLabel) -Context "$SourceLabel.state_authority"
    if ($stateAuthority -ne $contract.state_authority) {
        throw "$SourceLabel.state_authority must be '$($contract.state_authority)'."
    }

    $chatMemoryAuthorityAllowed = Assert-BooleanValue -Value (Get-RequiredProperty -Object $Packet -Name "chat_memory_authority_allowed" -Context $SourceLabel) -Context "$SourceLabel.chat_memory_authority_allowed"
    if ($chatMemoryAuthorityAllowed) {
        throw "$SourceLabel.chat_memory_authority_allowed must be false."
    }

    Assert-AuthorityTextAllowed -Value @($bootstrapSource, $stateAuthority) -Context $SourceLabel -Foundation $foundation
    $evidenceRefs = Assert-StringArrayValue -Value (Get-RequiredProperty -Object $Packet -Name "evidence_refs" -Context $SourceLabel) -Context "$SourceLabel.evidence_refs"
    foreach ($evidenceRef in $evidenceRefs) {
        Assert-RepoRefValue -Value $evidenceRef -Foundation $foundation -Context "$SourceLabel.evidence_refs item"
    }
    Assert-StringArrayValue -Value (Get-RequiredProperty -Object $Packet -Name "refusal_reasons" -Context $SourceLabel) -Context "$SourceLabel.refusal_reasons" -AllowEmpty | Out-Null
    Assert-NoPositiveOverclaim -Value @($bootstrapSource, $stateAuthority, $evidenceRefs, (Get-RequiredProperty -Object $Packet -Name "refusal_reasons" -Context $SourceLabel)) -Context $SourceLabel

    $ledgerRef = [string](Get-RequiredProperty -Object $Packet -Name "cycle_ledger_ref" -Context $SourceLabel)
    $ledger = Get-LedgerForPacketRef -CycleLedgerRef $ledgerRef -AnchorPath $AnchorPath
    if ($null -ne $ledger) {
        Assert-PacketMatchesLedger -Packet $Packet -Ledger $ledger -SourceLabel $SourceLabel
        $expectedNextStates = @($ledger.allowed_next_states)
        if ($allowedNextStates.Count -ne $expectedNextStates.Count) {
            throw "$SourceLabel.allowed_next_states must match ledger.allowed_next_states."
        }
        for ($index = 0; $index -lt $expectedNextStates.Count; $index += 1) {
            if ($allowedNextStates[$index] -ne $expectedNextStates[$index]) {
                throw "$SourceLabel.allowed_next_states must match ledger.allowed_next_states."
            }
        }
    }

    $nextActionPath = Resolve-PathValue -PathValue $nextActionPacketRef -AnchorPath (Get-ModuleRepositoryRootPath)
    if (-not (Test-Path -LiteralPath $nextActionPath)) {
        throw "$SourceLabel.next_action_packet_ref '$nextActionPacketRef' does not exist."
    }

    $nextActionValidation = Test-CycleNextActionPacketContract -PacketPath $nextActionPath
    if ($nextActionValidation.CycleId -ne [string](Get-RequiredProperty -Object $Packet -Name "cycle_id" -Context $SourceLabel)) {
        throw "$SourceLabel.next_action_packet_ref must reference the same cycle_id."
    }

    $PSCmdlet.WriteObject([pscustomobject]@{
        IsValid = $true
        PacketId = $bootstrapId
        CycleId = [string](Get-RequiredProperty -Object $Packet -Name "cycle_id" -Context $SourceLabel)
        LedgerState = [string](Get-RequiredProperty -Object $Packet -Name "ledger_state" -Context $SourceLabel)
        NextActionPacketRef = $nextActionPacketRef
        SourceLabel = $SourceLabel
    }, $false)
}

function Test-CycleBootstrapPacketContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PacketPath
    )

    $resolvedPacketPath = Resolve-ExistingPath -PathValue $PacketPath -Label "Cycle bootstrap packet"
    $packet = Get-JsonDocument -Path $resolvedPacketPath -Label "Cycle bootstrap packet"
    $validation = Test-CycleBootstrapPacketObject -Packet $packet -SourceLabel "Cycle bootstrap packet" -AnchorPath (Get-ModuleRepositoryRootPath)
    $PSCmdlet.WriteObject($validation, $false)
}

function New-CycleBootstrapResume {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$LedgerPath,
        [string]$OutputRoot = "state/cycle_controller/bootstrap",
        [string]$BootstrapPacketPath = "",
        [string]$NextActionPacketPath = "",
        [string]$BootstrapId = "",
        [string]$NextActionId = "",
        [string]$PreferredTargetState = "",
        [string]$ExpectedRepository = "",
        [string]$ExpectedBranch = "",
        [string]$ExpectedHeadSha = "",
        [string]$ExpectedTreeSha = "",
        [switch]$Overwrite,
        [switch]$AllowOutsideGovernedRoot
    )

    $foundation = Get-CycleControllerFoundationContract
    $ledgerContract = Get-CycleLedgerContractDefinition
    $bootstrapContract = Get-CycleBootstrapPacketContract
    $nextActionContract = Get-CycleNextActionPacketContract

    $resolvedLedgerPath = Resolve-ExistingPath -PathValue $LedgerPath -Label "Cycle ledger"
    $ledgerValidation = & $script:TestCycleLedgerContract -LedgerPath $resolvedLedgerPath
    $ledger = & $script:GetCycleLedger -LedgerPath $resolvedLedgerPath

    $expectedRepositoryValue = if ([string]::IsNullOrWhiteSpace($ExpectedRepository)) { $foundation.repository } else { $ExpectedRepository }
    $expectedBranchValue = if ([string]::IsNullOrWhiteSpace($ExpectedBranch)) { $foundation.branch } else { $ExpectedBranch }
    $expectedHeadValue = if ([string]::IsNullOrWhiteSpace($ExpectedHeadSha)) { Get-CurrentGitRef -Revision "HEAD" } else { $ExpectedHeadSha }
    $expectedTreeValue = if ([string]::IsNullOrWhiteSpace($ExpectedTreeSha)) { Get-CurrentGitRef -Revision "HEAD^{tree}" } else { $ExpectedTreeSha }

    Assert-MatchesPattern -Value $expectedHeadValue -Pattern $foundation.git_sha_pattern -Context "Cycle bootstrap expected head_sha"
    Assert-MatchesPattern -Value $expectedTreeValue -Pattern $foundation.git_sha_pattern -Context "Cycle bootstrap expected tree_sha"

    if ($ledger.repository -ne $expectedRepositoryValue) {
        throw "Cycle bootstrap ledger repository '$($ledger.repository)' contradicts expected repository '$expectedRepositoryValue'."
    }
    if ($ledger.branch -ne $expectedBranchValue) {
        throw "Cycle bootstrap ledger branch '$($ledger.branch)' contradicts expected branch '$expectedBranchValue'."
    }
    if ($ledger.head_sha -ne $expectedHeadValue) {
        throw "Cycle bootstrap ledger head '$($ledger.head_sha)' contradicts expected head '$expectedHeadValue'."
    }
    if ($ledger.tree_sha -ne $expectedTreeValue) {
        throw "Cycle bootstrap ledger tree '$($ledger.tree_sha)' contradicts expected tree '$expectedTreeValue'."
    }

    Assert-AuthorityTextAllowed -Value @($ledger.controller_authority.authority_type, $ledger.controller_authority.state_authority, $ledger.controller_authority.statement) -Context "Cycle ledger authority" -Foundation $foundation
    Assert-NoPositiveOverclaim -Value @($PreferredTargetState, $ledger.non_claims) -Context "Cycle bootstrap input"

    $allowedNextStates = @($ledger.allowed_next_states)
    $recommendedTargetState = Get-RecommendedTargetState -AllowedNextStates $allowedNextStates -PreferredTargetState $PreferredTargetState
    $recommendedAction = Get-RecommendedAction -TargetState $recommendedTargetState -NextActionContract $nextActionContract
    $requiredInputs = Get-RequiredInputsForTargetState -TargetState $recommendedTargetState -LedgerContract $ledgerContract
    $blockedReasons = @()
    if ($allowedNextStates.Count -eq 0) {
        $blockedReasons = @("Ledger is in terminal state '$($ledger.state)' and has no allowed next state.")
    }
    $operatorDecisionRequired = @("plan_approved", "accepted", "blocked", "stopped") -contains $recommendedTargetState

    $idSuffix = [guid]::NewGuid().ToString("N").Substring(0, 12)
    $bootstrapIdValue = if ([string]::IsNullOrWhiteSpace($BootstrapId)) { "bootstrap-$($ledger.cycle_id)-$idSuffix" } else { $BootstrapId }
    $nextActionIdValue = if ([string]::IsNullOrWhiteSpace($NextActionId)) { "next-action-$($ledger.cycle_id)-$idSuffix" } else { $NextActionId }
    Assert-MatchesPattern -Value $bootstrapIdValue -Pattern $foundation.identifier_pattern -Context "Cycle bootstrap bootstrap_id"
    Assert-MatchesPattern -Value $nextActionIdValue -Pattern $foundation.identifier_pattern -Context "Cycle bootstrap next_action_id"

    $resolvedOutputRoot = Resolve-GovernedOutputPath -PathValue $OutputRoot -AllowOutsideGovernedRoot:$AllowOutsideGovernedRoot
    $resolvedNextActionPath = if ([string]::IsNullOrWhiteSpace($NextActionPacketPath)) {
        Resolve-GovernedOutputPath -PathValue (Join-Path $resolvedOutputRoot "$nextActionIdValue.json") -AllowOutsideGovernedRoot:$AllowOutsideGovernedRoot
    }
    else {
        Resolve-GovernedOutputPath -PathValue $NextActionPacketPath -AllowOutsideGovernedRoot:$AllowOutsideGovernedRoot
    }
    $resolvedBootstrapPath = if ([string]::IsNullOrWhiteSpace($BootstrapPacketPath)) {
        Resolve-GovernedOutputPath -PathValue (Join-Path $resolvedOutputRoot "$bootstrapIdValue.json") -AllowOutsideGovernedRoot:$AllowOutsideGovernedRoot
    }
    else {
        Resolve-GovernedOutputPath -PathValue $BootstrapPacketPath -AllowOutsideGovernedRoot:$AllowOutsideGovernedRoot
    }

    Assert-CanWriteOutput -Path $resolvedNextActionPath -Overwrite:$Overwrite
    Assert-CanWriteOutput -Path $resolvedBootstrapPath -Overwrite:$Overwrite

    $ledgerRef = ConvertTo-RepoRef -PathValue $resolvedLedgerPath
    $nextActionRef = ConvertTo-RepoRef -PathValue $resolvedNextActionPath
    $createdAt = Get-UtcTimestamp

    $nextActionPacket = [pscustomobject][ordered]@{
        contract_version = $foundation.contract_version
        artifact_type = $nextActionContract.next_action_packet_artifact_type
        next_action_id = $nextActionIdValue
        repository = $ledger.repository
        branch = $ledger.branch
        milestone = $ledger.milestone
        source_task = $nextActionContract.source_task
        cycle_id = $ledger.cycle_id
        cycle_ledger_ref = $ledgerRef
        ledger_state = $ledger.state
        ledger_current_step = $ledger.current_step
        recommended_action = $recommendedAction
        allowed_target_states = @($allowedNextStates)
        required_inputs = @($requiredInputs)
        blocked_reasons = @($blockedReasons)
        operator_decision_required = [bool]$operatorDecisionRequired
        head_sha = $ledger.head_sha
        tree_sha = $ledger.tree_sha
        created_at_utc = $createdAt
        non_claims = @($foundation.required_non_claims)
    }

    Test-CycleNextActionPacketObject -Packet $nextActionPacket -SourceLabel "Cycle next-action packet draft" -AnchorPath (Get-ModuleRepositoryRootPath) | Out-Null
    Write-JsonDocument -Path $resolvedNextActionPath -Document $nextActionPacket
    Test-CycleNextActionPacketContract -PacketPath $resolvedNextActionPath | Out-Null

    $bootstrapPacket = [pscustomobject][ordered]@{
        contract_version = $foundation.contract_version
        artifact_type = $bootstrapContract.bootstrap_packet_artifact_type
        bootstrap_id = $bootstrapIdValue
        repository = $ledger.repository
        branch = $ledger.branch
        milestone = $ledger.milestone
        source_task = $bootstrapContract.source_task
        cycle_id = $ledger.cycle_id
        cycle_ledger_ref = $ledgerRef
        ledger_state = $ledger.state
        ledger_current_step = $ledger.current_step
        allowed_next_states = @($allowedNextStates)
        next_action_packet_ref = $nextActionRef
        head_sha = $ledger.head_sha
        tree_sha = $ledger.tree_sha
        created_at_utc = $createdAt
        bootstrap_source = $bootstrapContract.bootstrap_source
        state_authority = $bootstrapContract.state_authority
        chat_memory_authority_allowed = $false
        evidence_refs = @($ledgerRef, $nextActionRef)
        refusal_reasons = @()
        non_claims = @($foundation.required_non_claims)
    }

    Test-CycleBootstrapPacketObject -Packet $bootstrapPacket -SourceLabel "Cycle bootstrap packet draft" -AnchorPath (Get-ModuleRepositoryRootPath) | Out-Null
    Write-JsonDocument -Path $resolvedBootstrapPath -Document $bootstrapPacket
    Test-CycleBootstrapPacketContract -PacketPath $resolvedBootstrapPath | Out-Null

    $PSCmdlet.WriteObject([pscustomobject][ordered]@{
        ArtifactType = "cycle_bootstrap_result"
        Status = "succeeded"
        CycleId = $ledgerValidation.CycleId
        LedgerPath = $resolvedLedgerPath
        BootstrapPacketPath = $resolvedBootstrapPath
        NextActionPacketPath = $resolvedNextActionPath
        LedgerState = $ledger.state
        LedgerCurrentStep = $ledger.current_step
        RecommendedAction = $recommendedAction
        AllowedTargetStates = @($allowedNextStates)
        RequiredInputs = @($requiredInputs)
        NonClaims = @($foundation.required_non_claims)
    }, $false)
}

Export-ModuleMember -Function New-CycleBootstrapResume, Test-CycleBootstrapPacketContract, Test-CycleBootstrapPacketObject, Test-CycleNextActionPacketContract, Test-CycleNextActionPacketObject
