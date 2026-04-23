Set-StrictMode -Version Latest

$continuityLedgerModule = Import-Module (Join-Path $PSScriptRoot "MilestoneContinuityLedger.psm1") -Force -PassThru
$milestoneBaselineModule = Import-Module (Join-Path $PSScriptRoot "MilestoneBaseline.psm1") -Force -PassThru

$testMilestoneContinuityLedgerContract = $continuityLedgerModule.ExportedCommands["Test-MilestoneContinuityLedgerContract"]
$getMilestoneContinuityLedger = $continuityLedgerModule.ExportedCommands["Get-MilestoneContinuityLedger"]
$testMilestoneAutocycleBaselineBindingContract = $milestoneBaselineModule.ExportedCommands["Test-MilestoneAutocycleBaselineBindingContract"]
$testMilestoneBaselineRecordContract = $milestoneBaselineModule.ExportedCommands["Test-MilestoneBaselineRecordContract"]

function Resolve-ArtifactPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArtifactPath,
        [string]$AnchorPath = (Get-Location)
    )

    if ([System.IO.Path]::IsPathRooted($ArtifactPath)) {
        $resolvedPath = $ArtifactPath
    }
    else {
        $resolvedPath = Join-Path $AnchorPath $ArtifactPath
    }

    if (-not (Test-Path -LiteralPath $resolvedPath)) {
        throw "Rollback-plan artifact path '$ArtifactPath' does not exist."
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

function Resolve-OutputPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )

    if ([System.IO.Path]::IsPathRooted($OutputPath)) {
        return $OutputPath
    }

    return (Join-Path (Get-Location) $OutputPath)
}

function Write-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        $Document,
        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )

    $resolvedOutputPath = Resolve-OutputPath -OutputPath $OutputPath
    $parentPath = Split-Path -Parent $resolvedOutputPath
    if (-not [string]::IsNullOrWhiteSpace($parentPath)) {
        New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    }

    $Document | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $resolvedOutputPath -Encoding ascii
    return (Resolve-Path -LiteralPath $resolvedOutputPath).Path
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
        [int]$MinimumCount = 0
    )

    if ($null -eq $Value -or $Value -is [string] -or $Value -isnot [System.Array]) {
        throw "$Context must be an array."
    }

    $items = @($Value)
    if ($items.Count -lt $MinimumCount) {
        throw "$Context must contain at least $MinimumCount item(s)."
    }

    foreach ($item in $items) {
        Assert-NonEmptyString -Value $item -Context "$Context item" | Out-Null
    }

    return $items
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

    return $Value
}

function Get-RepositoryRoot {
    return (Split-Path -Parent $PSScriptRoot)
}

function Assert-RepoRelativeExistingPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RelativePath,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ([System.IO.Path]::IsPathRooted($RelativePath)) {
        throw "$Context must be repo-relative, not absolute."
    }

    $repoRoot = (Resolve-Path -LiteralPath (Get-RepositoryRoot)).Path
    $candidatePath = Join-Path $repoRoot $RelativePath

    if (-not (Test-Path -LiteralPath $candidatePath)) {
        throw "$Context path '$RelativePath' does not exist."
    }

    $resolvedPath = (Resolve-Path -LiteralPath $candidatePath).Path
    if (-not $resolvedPath.StartsWith($repoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "$Context path '$RelativePath' resolves outside the repository root."
    }

    return [pscustomobject]@{
        RelativePath = $RelativePath
        ResolvedPath = $resolvedPath
    }
}

function Get-RepoRelativePathFromResolvedPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResolvedPath
    )

    $repoRoot = (Resolve-Path -LiteralPath (Get-RepositoryRoot)).Path
    $normalizedRepoRoot = [System.IO.Path]::GetFullPath($repoRoot)
    $normalizedResolvedPath = [System.IO.Path]::GetFullPath($ResolvedPath)
    if (-not $normalizedResolvedPath.StartsWith($normalizedRepoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Path '$ResolvedPath' is outside the repository root."
    }

    $relativePath = $normalizedResolvedPath.Substring($normalizedRepoRoot.Length).TrimStart('\', '/')
    return ($relativePath -replace '\\', '/')
}

function Get-MilestoneContinuityFoundationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_continuity\foundation.contract.json") -Label "Milestone continuity foundation contract"
}

function Get-MilestoneRollbackPlanRequestContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_continuity\rollback_plan_request.contract.json") -Label "Rollback plan request contract"
}

function Get-MilestoneRollbackPlanContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_continuity\rollback_plan.contract.json") -Label "Rollback plan contract"
}

function Validate-CycleContext {
    param(
        [Parameter(Mandatory = $true)]
        $CycleContext,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [string]$ContextPrefix
    )

    foreach ($fieldName in @($Contract.cycle_context_required_fields)) {
        Get-RequiredProperty -Object $CycleContext -Name $fieldName -Context $ContextPrefix | Out-Null
    }

    $cycleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $CycleContext -Name "cycle_id" -Context $ContextPrefix) -Context "$ContextPrefix.cycle_id"
    Assert-RegexMatch -Value $cycleId -Pattern $Foundation.identifier_pattern -Context "$ContextPrefix.cycle_id"

    $milestoneId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $CycleContext -Name "milestone_id" -Context $ContextPrefix) -Context "$ContextPrefix.milestone_id"
    Assert-RegexMatch -Value $milestoneId -Pattern $Foundation.identifier_pattern -Context "$ContextPrefix.milestone_id"

    $milestoneTitle = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $CycleContext -Name "milestone_title" -Context $ContextPrefix) -Context "$ContextPrefix.milestone_title"

    return [pscustomobject]@{
        CycleId = $cycleId
        MilestoneId = $milestoneId
        MilestoneTitle = $milestoneTitle
    }
}

function Validate-RepositoryContext {
    param(
        [Parameter(Mandatory = $true)]
        $RepositoryContext,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [string]$ContextPrefix
    )

    foreach ($fieldName in @($Contract.repository_required_fields)) {
        Get-RequiredProperty -Object $RepositoryContext -Name $fieldName -Context $ContextPrefix | Out-Null
    }

    $repositoryName = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RepositoryContext -Name "repository_name" -Context $ContextPrefix) -Context "$ContextPrefix.repository_name"
    if ($repositoryName -ne $Foundation.repository_name) {
        throw "$ContextPrefix.repository_name must equal '$($Foundation.repository_name)'."
    }

    return $repositoryName
}

function Validate-Supervision {
    param(
        [Parameter(Mandatory = $true)]
        $Supervision,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [string]$ContextPrefix
    )

    foreach ($fieldName in @($Contract.supervision_required_fields)) {
        Get-RequiredProperty -Object $Supervision -Name $fieldName -Context $ContextPrefix | Out-Null
    }

    $mode = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Supervision -Name "mode" -Context $ContextPrefix) -Context "$ContextPrefix.mode"
    Assert-AllowedValue -Value $mode -AllowedValues @($Foundation.allowed_supervision_modes) -Context "$ContextPrefix.mode"

    $operatorAuthority = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Supervision -Name "operator_authority" -Context $ContextPrefix) -Context "$ContextPrefix.operator_authority"
    Assert-RegexMatch -Value $operatorAuthority -Pattern $Foundation.operator_pattern -Context "$ContextPrefix.operator_authority"

    $resumeAuthorityState = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Supervision -Name "resume_authority_state" -Context $ContextPrefix) -Context "$ContextPrefix.resume_authority_state"
    Assert-AllowedValue -Value $resumeAuthorityState -AllowedValues @($Foundation.allowed_resume_authority_states) -Context "$ContextPrefix.resume_authority_state"
    if ($resumeAuthorityState -ne "operator_review_required") {
        throw "$ContextPrefix.resume_authority_state must remain 'operator_review_required' for rollback-plan preparation."
    }

    return [pscustomobject]@{
        Mode = $mode
        OperatorAuthority = $operatorAuthority
        ResumeAuthorityState = $resumeAuthorityState
    }
}

function Validate-AuthoritativeRefs {
    param(
        [Parameter(Mandatory = $true)]
        $AuthoritativeRefs,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        [string]$ContextPrefix
    )

    $resolvedRefs = [ordered]@{}
    foreach ($fieldName in @($Foundation.required_authoritative_ref_fields)) {
        $relativePath = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $AuthoritativeRefs -Name $fieldName -Context $ContextPrefix) -Context "$ContextPrefix.$fieldName"
        $resolvedRefs[$fieldName] = Assert-RepoRelativeExistingPath -RelativePath $relativePath -Context "$ContextPrefix.$fieldName"
    }

    return [pscustomobject]$resolvedRefs
}

function Validate-LedgerReference {
    param(
        [Parameter(Mandatory = $true)]
        $LedgerRef,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [string]$ContextPrefix
    )

    $requiredFieldSet = if (Test-HasProperty -Object $Contract -Name "ledger_ref_required_fields") {
        @($Contract.ledger_ref_required_fields)
    }
    elseif (Test-HasProperty -Object $Contract -Name "continuity_ledger_ref_required_fields") {
        @($Contract.continuity_ledger_ref_required_fields)
    }
    else {
        throw "$ContextPrefix contract is missing ledger reference required-field rules."
    }

    foreach ($fieldName in $requiredFieldSet) {
        Get-RequiredProperty -Object $LedgerRef -Name $fieldName -Context $ContextPrefix | Out-Null
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $LedgerRef -Name "record_type" -Context $ContextPrefix) -Context "$ContextPrefix.record_type"
    if ($recordType -ne $Foundation.ledger_record_type) {
        throw "$ContextPrefix.record_type must equal '$($Foundation.ledger_record_type)'."
    }

    $ledgerId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $LedgerRef -Name "ledger_id" -Context $ContextPrefix) -Context "$ContextPrefix.ledger_id"
    Assert-RegexMatch -Value $ledgerId -Pattern $Foundation.identifier_pattern -Context "$ContextPrefix.ledger_id"

    $ledgerPathInfo = Assert-RepoRelativeExistingPath -RelativePath (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $LedgerRef -Name "ledger_path" -Context $ContextPrefix) -Context "$ContextPrefix.ledger_path") -Context "$ContextPrefix.ledger_path"
    $validation = & $testMilestoneContinuityLedgerContract -LedgerPath $ledgerPathInfo.ResolvedPath
    $document = & $getMilestoneContinuityLedger -LedgerPath $ledgerPathInfo.ResolvedPath

    if ($validation.LedgerId -ne $ledgerId) {
        throw "$ContextPrefix.ledger_id does not match the referenced continuity ledger artifact."
    }

    return [pscustomobject]@{
        LedgerId = $validation.LedgerId
        LedgerPath = $ledgerPathInfo.RelativePath
        Validation = $validation
        Document = $document
    }
}

function Validate-BaselineBindingReference {
    param(
        [Parameter(Mandatory = $true)]
        $BindingRef,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [string]$ContextPrefix,
        [string]$AnchorPath = (Get-Location)
    )

    foreach ($fieldName in @($Contract.baseline_binding_ref_required_fields)) {
        Get-RequiredProperty -Object $BindingRef -Name $fieldName -Context $ContextPrefix | Out-Null
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $BindingRef -Name "record_type" -Context $ContextPrefix) -Context "$ContextPrefix.record_type"
    if ($recordType -ne "milestone_autocycle_baseline_binding") {
        throw "$ContextPrefix.record_type must equal 'milestone_autocycle_baseline_binding'."
    }

    $bindingId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $BindingRef -Name "binding_id" -Context $ContextPrefix) -Context "$ContextPrefix.binding_id"
    Assert-RegexMatch -Value $bindingId -Pattern $Foundation.identifier_pattern -Context "$ContextPrefix.binding_id"

    $bindingPathValue = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $BindingRef -Name "binding_path" -Context $ContextPrefix) -Context "$ContextPrefix.binding_path"
    $resolvedBindingPath = Resolve-ArtifactPath -ArtifactPath $bindingPathValue -AnchorPath $AnchorPath
    $validation = & $testMilestoneAutocycleBaselineBindingContract -BindingPath $resolvedBindingPath

    if ($validation.BindingId -ne $bindingId) {
        throw "$ContextPrefix.binding_id does not match the referenced baseline binding artifact."
    }

    return [pscustomobject]@{
        BindingId = $validation.BindingId
        BindingPath = $resolvedBindingPath
        Validation = $validation
    }
}

function Validate-BaselineReference {
    param(
        [Parameter(Mandatory = $true)]
        $BaselineRef,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [string]$ContextPrefix,
        [string]$AnchorPath = (Get-Location)
    )

    foreach ($fieldName in @($Contract.baseline_ref_required_fields)) {
        Get-RequiredProperty -Object $BaselineRef -Name $fieldName -Context $ContextPrefix | Out-Null
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $BaselineRef -Name "record_type" -Context $ContextPrefix) -Context "$ContextPrefix.record_type"
    if ($recordType -ne "milestone_baseline") {
        throw "$ContextPrefix.record_type must equal 'milestone_baseline'."
    }

    $baselineId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $BaselineRef -Name "baseline_id" -Context $ContextPrefix) -Context "$ContextPrefix.baseline_id"
    Assert-RegexMatch -Value $baselineId -Pattern $Foundation.identifier_pattern -Context "$ContextPrefix.baseline_id"

    $baselinePathValue = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $BaselineRef -Name "baseline_path" -Context $ContextPrefix) -Context "$ContextPrefix.baseline_path"
    $resolvedBaselinePath = Resolve-ArtifactPath -ArtifactPath $baselinePathValue -AnchorPath $AnchorPath
    $validation = & $testMilestoneBaselineRecordContract -BaselinePath $resolvedBaselinePath
    $document = Get-JsonDocument -Path $resolvedBaselinePath -Label "Milestone baseline"

    if ($validation.BaselineId -ne $baselineId) {
        throw "$ContextPrefix.baseline_id does not match the referenced milestone baseline artifact."
    }

    return [pscustomobject]@{
        BaselineId = $validation.BaselineId
        BaselinePath = $resolvedBaselinePath
        Validation = $validation
        Document = $document
    }
}

function Assert-RepositoryRootMatchesRepositoryName {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryName,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $rootName = Split-Path -Leaf ([System.IO.Path]::GetFullPath($RepositoryRoot))
    if ($rootName -ne $RepositoryName) {
        throw "$Context repository root leaf name must equal '$RepositoryName'."
    }
}

function Test-MilestoneRollbackPlanRequestDocument {
    param(
        [Parameter(Mandatory = $true)]
        $RollbackPlanRequest,
        [Parameter(Mandatory = $true)]
        [string]$SourceLabel,
        [AllowNull()]
        [string]$RollbackPlanRequestPath
    )

    $foundation = Get-MilestoneContinuityFoundationContract
    $contract = Get-MilestoneRollbackPlanRequestContract

    foreach ($fieldName in @($contract.required_fields)) {
        Get-RequiredProperty -Object $RollbackPlanRequest -Name $fieldName -Context "Rollback plan request" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackPlanRequest -Name "contract_version" -Context "Rollback plan request") -Context "Rollback plan request.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "Rollback plan request.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackPlanRequest -Name "record_type" -Context "Rollback plan request") -Context "Rollback plan request.record_type"
    if ($recordType -ne $foundation.rollback_plan_request_record_type -or $recordType -ne $contract.record_type) {
        throw "Rollback plan request.record_type must equal '$($foundation.rollback_plan_request_record_type)'."
    }

    $rollbackPlanRequestId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackPlanRequest -Name "rollback_plan_request_id" -Context "Rollback plan request") -Context "Rollback plan request.rollback_plan_request_id"
    Assert-RegexMatch -Value $rollbackPlanRequestId -Pattern $foundation.identifier_pattern -Context "Rollback plan request.rollback_plan_request_id"

    $requestedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackPlanRequest -Name "requested_at" -Context "Rollback plan request") -Context "Rollback plan request.requested_at"
    Assert-RegexMatch -Value $requestedAt -Pattern $foundation.timestamp_pattern -Context "Rollback plan request.requested_at"

    $ledgerReference = Validate-LedgerReference -LedgerRef (Assert-ObjectValue -Value (Get-RequiredProperty -Object $RollbackPlanRequest -Name "continuity_ledger_ref" -Context "Rollback plan request") -Context "Rollback plan request.continuity_ledger_ref") -Foundation $foundation -Contract $contract -ContextPrefix "Rollback plan request.continuity_ledger_ref"

    $targetScope = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackPlanRequest -Name "target_scope" -Context "Rollback plan request") -Context "Rollback plan request.target_scope"
    Assert-AllowedValue -Value $targetScope -AllowedValues @($foundation.allowed_rollback_target_scopes) -Context "Rollback plan request.target_scope"

    $allowedEnvironmentScope = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackPlanRequest -Name "allowed_environment_scope" -Context "Rollback plan request") -Context "Rollback plan request.allowed_environment_scope"
    Assert-AllowedValue -Value $allowedEnvironmentScope -AllowedValues @($foundation.allowed_rollback_environment_scopes) -Context "Rollback plan request.allowed_environment_scope"

    $operatorApprovalRequired = Assert-BooleanValue -Value (Get-RequiredProperty -Object $RollbackPlanRequest -Name "operator_approval_required" -Context "Rollback plan request") -Context "Rollback plan request.operator_approval_required"
    if (-not $operatorApprovalRequired) {
        throw "Rollback plan request.operator_approval_required must remain true."
    }

    $requiredApprovalState = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackPlanRequest -Name "required_approval_state" -Context "Rollback plan request") -Context "Rollback plan request.required_approval_state"
    Assert-AllowedValue -Value $requiredApprovalState -AllowedValues @($foundation.allowed_resume_authority_states) -Context "Rollback plan request.required_approval_state"
    if ($requiredApprovalState -ne "operator_review_required") {
        throw "Rollback plan request.required_approval_state must equal 'operator_review_required'."
    }

    $refusalConditions = Assert-StringArray -Value (Get-RequiredProperty -Object $RollbackPlanRequest -Name "refusal_conditions" -Context "Rollback plan request") -Context "Rollback plan request.refusal_conditions" -MinimumCount 1
    $notes = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackPlanRequest -Name "notes" -Context "Rollback plan request") -Context "Rollback plan request.notes"

    return [pscustomobject]@{
        IsValid = $true
        RollbackPlanRequestId = $rollbackPlanRequestId
        LedgerId = $ledgerReference.LedgerId
        LedgerPath = $ledgerReference.LedgerPath
        CycleId = $ledgerReference.Validation.CycleId
        MilestoneId = $ledgerReference.Validation.MilestoneId
        TaskId = $ledgerReference.Validation.TaskId
        InterruptedSegmentId = $ledgerReference.Validation.InterruptedSegmentId
        SuccessorSegmentId = $ledgerReference.Validation.SuccessorSegmentId
        RepositoryName = $ledgerReference.Validation.RepositoryName
        OperatorAuthority = $ledgerReference.Validation.OperatorAuthority
        TargetScope = $targetScope
        AllowedEnvironmentScope = $allowedEnvironmentScope
        RequiredApprovalState = $requiredApprovalState
        RefusalConditions = $refusalConditions
        SourceLabel = $SourceLabel
        RequestPath = $RollbackPlanRequestPath
        Notes = $notes
    }
}

function Test-MilestoneRollbackPlanDocument {
    param(
        [Parameter(Mandatory = $true)]
        $RollbackPlan,
        [Parameter(Mandatory = $true)]
        [string]$SourceLabel,
        [AllowNull()]
        [string]$RollbackPlanPath
    )

    $foundation = Get-MilestoneContinuityFoundationContract
    $contract = Get-MilestoneRollbackPlanContract
    $anchorPath = if ([string]::IsNullOrWhiteSpace($RollbackPlanPath)) { (Get-Location) } else { Split-Path -Parent $RollbackPlanPath }

    foreach ($fieldName in @($contract.required_fields)) {
        Get-RequiredProperty -Object $RollbackPlan -Name $fieldName -Context "Rollback plan" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackPlan -Name "contract_version" -Context "Rollback plan") -Context "Rollback plan.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "Rollback plan.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackPlan -Name "record_type" -Context "Rollback plan") -Context "Rollback plan.record_type"
    if ($recordType -ne $foundation.rollback_plan_record_type -or $recordType -ne $contract.record_type) {
        throw "Rollback plan.record_type must equal '$($foundation.rollback_plan_record_type)'."
    }

    $rollbackPlanId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackPlan -Name "rollback_plan_id" -Context "Rollback plan") -Context "Rollback plan.rollback_plan_id"
    Assert-RegexMatch -Value $rollbackPlanId -Pattern $foundation.identifier_pattern -Context "Rollback plan.rollback_plan_id"

    $rollbackPlanRequestId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackPlan -Name "rollback_plan_request_id" -Context "Rollback plan") -Context "Rollback plan.rollback_plan_request_id"
    Assert-RegexMatch -Value $rollbackPlanRequestId -Pattern $foundation.identifier_pattern -Context "Rollback plan.rollback_plan_request_id"

    $plannedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackPlan -Name "planned_at" -Context "Rollback plan") -Context "Rollback plan.planned_at"
    Assert-RegexMatch -Value $plannedAt -Pattern $foundation.timestamp_pattern -Context "Rollback plan.planned_at"

    $cycleContext = Validate-CycleContext -CycleContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $RollbackPlan -Name "cycle_context" -Context "Rollback plan") -Context "Rollback plan.cycle_context") -Foundation $foundation -Contract $contract -ContextPrefix "Rollback plan.cycle_context"
    $repositoryName = Validate-RepositoryContext -RepositoryContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $RollbackPlan -Name "repository" -Context "Rollback plan") -Context "Rollback plan.repository") -Foundation $foundation -Contract $contract -ContextPrefix "Rollback plan.repository"

    $sourceContinuity = Assert-ObjectValue -Value (Get-RequiredProperty -Object $RollbackPlan -Name "source_continuity" -Context "Rollback plan") -Context "Rollback plan.source_continuity"
    foreach ($fieldName in @($contract.source_continuity_required_fields)) {
        Get-RequiredProperty -Object $sourceContinuity -Name $fieldName -Context "Rollback plan.source_continuity" | Out-Null
    }

    $ledgerReference = Validate-LedgerReference -LedgerRef (Assert-ObjectValue -Value (Get-RequiredProperty -Object $sourceContinuity -Name "ledger_ref" -Context "Rollback plan.source_continuity") -Context "Rollback plan.source_continuity.ledger_ref") -Foundation $foundation -Contract $contract -ContextPrefix "Rollback plan.source_continuity.ledger_ref"

    $taskId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $sourceContinuity -Name "task_id" -Context "Rollback plan.source_continuity") -Context "Rollback plan.source_continuity.task_id"
    Assert-RegexMatch -Value $taskId -Pattern $foundation.identifier_pattern -Context "Rollback plan.source_continuity.task_id"
    $interruptedSegmentId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $sourceContinuity -Name "interrupted_segment_id" -Context "Rollback plan.source_continuity") -Context "Rollback plan.source_continuity.interrupted_segment_id"
    Assert-RegexMatch -Value $interruptedSegmentId -Pattern $foundation.identifier_pattern -Context "Rollback plan.source_continuity.interrupted_segment_id"
    $successorSegmentId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $sourceContinuity -Name "successor_segment_id" -Context "Rollback plan.source_continuity") -Context "Rollback plan.source_continuity.successor_segment_id"
    Assert-RegexMatch -Value $successorSegmentId -Pattern $foundation.identifier_pattern -Context "Rollback plan.source_continuity.successor_segment_id"
    $ledgerContinuityState = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $sourceContinuity -Name "ledger_continuity_state" -Context "Rollback plan.source_continuity") -Context "Rollback plan.source_continuity.ledger_continuity_state"
    Assert-AllowedValue -Value $ledgerContinuityState -AllowedValues @($foundation.allowed_ledger_continuity_states) -Context "Rollback plan.source_continuity.ledger_continuity_state"

    if ($cycleContext.CycleId -ne $ledgerReference.Validation.CycleId -or $cycleContext.MilestoneId -ne $ledgerReference.Validation.MilestoneId) {
        throw "Rollback plan.cycle_context must match the referenced continuity ledger."
    }
    if ($taskId -ne $ledgerReference.Validation.TaskId -or $interruptedSegmentId -ne $ledgerReference.Validation.InterruptedSegmentId -or $successorSegmentId -ne $ledgerReference.Validation.SuccessorSegmentId) {
        throw "Rollback plan.source_continuity must match the referenced continuity ledger segment lineage exactly."
    }
    if ($ledgerContinuityState -ne $ledgerReference.Validation.LedgerContinuityState) {
        throw "Rollback plan.source_continuity.ledger_continuity_state must match the referenced continuity ledger."
    }
    if ($repositoryName -ne $ledgerReference.Validation.RepositoryName) {
        throw "Rollback plan.repository.repository_name must match the referenced continuity ledger repository."
    }

    $rollbackTarget = Assert-ObjectValue -Value (Get-RequiredProperty -Object $RollbackPlan -Name "rollback_target" -Context "Rollback plan") -Context "Rollback plan.rollback_target"
    foreach ($fieldName in @($contract.rollback_target_required_fields)) {
        Get-RequiredProperty -Object $rollbackTarget -Name $fieldName -Context "Rollback plan.rollback_target" | Out-Null
    }

    $targetScope = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $rollbackTarget -Name "target_scope" -Context "Rollback plan.rollback_target") -Context "Rollback plan.rollback_target.target_scope"
    Assert-AllowedValue -Value $targetScope -AllowedValues @($foundation.allowed_rollback_target_scopes) -Context "Rollback plan.rollback_target.target_scope"

    $bindingReference = Validate-BaselineBindingReference -BindingRef (Assert-ObjectValue -Value (Get-RequiredProperty -Object $rollbackTarget -Name "baseline_binding_ref" -Context "Rollback plan.rollback_target") -Context "Rollback plan.rollback_target.baseline_binding_ref") -Foundation $foundation -Contract $contract -ContextPrefix "Rollback plan.rollback_target.baseline_binding_ref" -AnchorPath $anchorPath
    $baselineReference = Validate-BaselineReference -BaselineRef (Assert-ObjectValue -Value (Get-RequiredProperty -Object $rollbackTarget -Name "baseline_ref" -Context "Rollback plan.rollback_target") -Context "Rollback plan.rollback_target.baseline_ref") -Foundation $foundation -Contract $contract -ContextPrefix "Rollback plan.rollback_target.baseline_ref" -AnchorPath $anchorPath

    if ($bindingReference.Validation.BaselineId -ne $baselineReference.BaselineId -or $bindingReference.Validation.BaselinePath -ne $baselineReference.BaselinePath) {
        throw "Rollback plan.rollback_target baseline refs must match the referenced baseline binding exactly."
    }

    $targetRepositoryRoot = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $rollbackTarget -Name "repository_root" -Context "Rollback plan.rollback_target") -Context "Rollback plan.rollback_target.repository_root"
    $targetRepositoryRootResolved = Resolve-ArtifactPath -ArtifactPath $targetRepositoryRoot -AnchorPath $anchorPath
    $targetBranch = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $rollbackTarget -Name "branch" -Context "Rollback plan.rollback_target") -Context "Rollback plan.rollback_target.branch"
    Assert-RegexMatch -Value $targetBranch -Pattern $foundation.branch_pattern -Context "Rollback plan.rollback_target.branch"
    $targetHeadCommit = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $rollbackTarget -Name "head_commit" -Context "Rollback plan.rollback_target") -Context "Rollback plan.rollback_target.head_commit"
    Assert-RegexMatch -Value $targetHeadCommit -Pattern $foundation.git_object_pattern -Context "Rollback plan.rollback_target.head_commit"
    $targetTreeId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $rollbackTarget -Name "tree_id" -Context "Rollback plan.rollback_target") -Context "Rollback plan.rollback_target.tree_id"
    Assert-RegexMatch -Value $targetTreeId -Pattern $foundation.git_object_pattern -Context "Rollback plan.rollback_target.tree_id"

    $baselineDocument = $baselineReference.Document
    if ($baselineDocument.git.repository_root -ne $targetRepositoryRootResolved -or $baselineDocument.git.branch -ne $targetBranch -or $baselineDocument.git.head_commit -ne $targetHeadCommit -or $baselineDocument.git.tree_id -ne $targetTreeId) {
        throw "Rollback plan.rollback_target git context must match the referenced baseline exactly."
    }

    Assert-RepositoryRootMatchesRepositoryName -RepositoryRoot $targetRepositoryRootResolved -RepositoryName $repositoryName -Context "Rollback plan.rollback_target"

    $environmentConstraints = Assert-ObjectValue -Value (Get-RequiredProperty -Object $RollbackPlan -Name "environment_constraints" -Context "Rollback plan") -Context "Rollback plan.environment_constraints"
    foreach ($fieldName in @($contract.environment_constraints_required_fields)) {
        Get-RequiredProperty -Object $environmentConstraints -Name $fieldName -Context "Rollback plan.environment_constraints" | Out-Null
    }

    $allowedEnvironmentScope = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $environmentConstraints -Name "allowed_environment_scope" -Context "Rollback plan.environment_constraints") -Context "Rollback plan.environment_constraints.allowed_environment_scope"
    Assert-AllowedValue -Value $allowedEnvironmentScope -AllowedValues @($foundation.allowed_rollback_environment_scopes) -Context "Rollback plan.environment_constraints.allowed_environment_scope"
    $primaryWorktreeExecution = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $environmentConstraints -Name "primary_worktree_execution" -Context "Rollback plan.environment_constraints") -Context "Rollback plan.environment_constraints.primary_worktree_execution"
    Assert-AllowedValue -Value $primaryWorktreeExecution -AllowedValues @($foundation.allowed_rollback_primary_worktree_execution_states) -Context "Rollback plan.environment_constraints.primary_worktree_execution"

    $supervision = Validate-Supervision -Supervision (Assert-ObjectValue -Value (Get-RequiredProperty -Object $RollbackPlan -Name "supervision" -Context "Rollback plan") -Context "Rollback plan.supervision") -Foundation $foundation -Contract $contract -ContextPrefix "Rollback plan.supervision"
    if ($supervision.OperatorAuthority -ne $ledgerReference.Validation.OperatorAuthority) {
        throw "Rollback plan.supervision.operator_authority must match the referenced continuity ledger."
    }

    $operatorApproval = Assert-ObjectValue -Value (Get-RequiredProperty -Object $RollbackPlan -Name "operator_approval" -Context "Rollback plan") -Context "Rollback plan.operator_approval"
    foreach ($fieldName in @($contract.operator_approval_required_fields)) {
        Get-RequiredProperty -Object $operatorApproval -Name $fieldName -Context "Rollback plan.operator_approval" | Out-Null
    }

    $approvalRequired = Assert-BooleanValue -Value (Get-RequiredProperty -Object $operatorApproval -Name "approval_required" -Context "Rollback plan.operator_approval") -Context "Rollback plan.operator_approval.approval_required"
    if (-not $approvalRequired) {
        throw "Rollback plan.operator_approval.approval_required must remain true."
    }

    $requiredAuthorityState = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $operatorApproval -Name "required_authority_state" -Context "Rollback plan.operator_approval") -Context "Rollback plan.operator_approval.required_authority_state"
    Assert-AllowedValue -Value $requiredAuthorityState -AllowedValues @($foundation.allowed_resume_authority_states) -Context "Rollback plan.operator_approval.required_authority_state"
    if ($requiredAuthorityState -ne "operator_review_required") {
        throw "Rollback plan.operator_approval.required_authority_state must equal 'operator_review_required'."
    }
    if ($requiredAuthorityState -ne $supervision.ResumeAuthorityState) {
        throw "Rollback plan.operator_approval.required_authority_state must match the rollback plan supervision state."
    }

    $approvedForExecution = Assert-BooleanValue -Value (Get-RequiredProperty -Object $operatorApproval -Name "approved_for_execution" -Context "Rollback plan.operator_approval") -Context "Rollback plan.operator_approval.approved_for_execution"
    if ($approvedForExecution) {
        throw "Rollback plan.operator_approval.approved_for_execution must remain false in this pre-execution slice."
    }

    $refusalConditions = Assert-StringArray -Value (Get-RequiredProperty -Object $RollbackPlan -Name "refusal_conditions" -Context "Rollback plan") -Context "Rollback plan.refusal_conditions" -MinimumCount 1

    $executionState = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackPlan -Name "execution_state" -Context "Rollback plan") -Context "Rollback plan.execution_state"
    Assert-AllowedValue -Value $executionState -AllowedValues @($foundation.allowed_rollback_execution_states) -Context "Rollback plan.execution_state"

    $authoritativeRefs = Validate-AuthoritativeRefs -AuthoritativeRefs (Assert-ObjectValue -Value (Get-RequiredProperty -Object $RollbackPlan -Name "authoritative_refs" -Context "Rollback plan") -Context "Rollback plan.authoritative_refs") -Foundation $foundation -ContextPrefix "Rollback plan.authoritative_refs"
    $nonClaims = Assert-StringArray -Value (Get-RequiredProperty -Object $RollbackPlan -Name "non_claims" -Context "Rollback plan") -Context "Rollback plan.non_claims" -MinimumCount 1
    foreach ($nonClaim in $nonClaims) {
        Assert-AllowedValue -Value $nonClaim -AllowedValues @($foundation.allowed_rollback_non_claims) -Context "Rollback plan.non_claims item"
    }
    if ($nonClaims -notcontains "plan_only_no_execution_no_drill_no_primary_worktree_rollback") {
        throw "Rollback plan.non_claims must preserve the bounded pre-execution non-claim."
    }

    $notes = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackPlan -Name "notes" -Context "Rollback plan") -Context "Rollback plan.notes"

    return [pscustomobject]@{
        IsValid = $true
        RollbackPlanId = $rollbackPlanId
        RollbackPlanRequestId = $rollbackPlanRequestId
        RollbackPlanPath = $RollbackPlanPath
        CycleId = $cycleContext.CycleId
        MilestoneId = $cycleContext.MilestoneId
        TaskId = $taskId
        InterruptedSegmentId = $interruptedSegmentId
        SuccessorSegmentId = $successorSegmentId
        LedgerId = $ledgerReference.LedgerId
        BindingId = $bindingReference.BindingId
        BaselineId = $baselineReference.BaselineId
        RepositoryName = $repositoryName
        TargetRepositoryRoot = $targetRepositoryRootResolved
        TargetBranch = $targetBranch
        TargetHeadCommit = $targetHeadCommit
        TargetTreeId = $targetTreeId
        AllowedEnvironmentScope = $allowedEnvironmentScope
        ExecutionState = $executionState
        OperatorAuthority = $supervision.OperatorAuthority
        AuthoritativeRefs = $authoritativeRefs
        NonClaims = $nonClaims
        SourceLabel = $SourceLabel
        Notes = $notes
    }
}

function Test-MilestoneRollbackPlanRequestContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RollbackPlanRequestPath
    )

    $resolvedRequestPath = Resolve-ArtifactPath -ArtifactPath $RollbackPlanRequestPath
    $request = Get-JsonDocument -Path $resolvedRequestPath -Label "Rollback plan request"
    return (Test-MilestoneRollbackPlanRequestDocument -RollbackPlanRequest $request -SourceLabel $resolvedRequestPath -RollbackPlanRequestPath $resolvedRequestPath)
}

function Test-MilestoneRollbackPlanRequestObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $RollbackPlanRequest,
        [string]$SourceLabel = "in-memory rollback plan request"
    )

    return (Test-MilestoneRollbackPlanRequestDocument -RollbackPlanRequest $RollbackPlanRequest -SourceLabel $SourceLabel -RollbackPlanRequestPath $null)
}

function Test-MilestoneRollbackPlanContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RollbackPlanPath
    )

    $resolvedPlanPath = Resolve-ArtifactPath -ArtifactPath $RollbackPlanPath
    $plan = Get-JsonDocument -Path $resolvedPlanPath -Label "Rollback plan"
    return (Test-MilestoneRollbackPlanDocument -RollbackPlan $plan -SourceLabel $resolvedPlanPath -RollbackPlanPath $resolvedPlanPath)
}

function Test-MilestoneRollbackPlanObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $RollbackPlan,
        [string]$SourceLabel = "in-memory rollback plan"
    )

    return (Test-MilestoneRollbackPlanDocument -RollbackPlan $RollbackPlan -SourceLabel $SourceLabel -RollbackPlanPath $null)
}

function Get-MilestoneRollbackPlan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RollbackPlanPath
    )

    $validation = Test-MilestoneRollbackPlanContract -RollbackPlanPath $RollbackPlanPath
    return (Get-JsonDocument -Path $validation.RollbackPlanPath -Label "Rollback plan")
}

function Invoke-MilestoneRollbackPlan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RollbackPlanRequestPath,
        [Parameter(Mandatory = $true)]
        [string]$BaselineBindingPath,
        [Parameter(Mandatory = $true)]
        [string]$RollbackPlanPath,
        [string]$RollbackPlanId = "rollback-plan-r7-006-001",
        [datetime]$PlannedAt = (Get-Date).ToUniversalTime()
    )

    $foundation = Get-MilestoneContinuityFoundationContract
    Assert-NonEmptyString -Value $RollbackPlanId -Context "RollbackPlanId" | Out-Null
    Assert-RegexMatch -Value $RollbackPlanId -Pattern $foundation.identifier_pattern -Context "RollbackPlanId"

    $requestValidation = Test-MilestoneRollbackPlanRequestContract -RollbackPlanRequestPath $RollbackPlanRequestPath
    $request = Get-JsonDocument -Path $requestValidation.RequestPath -Label "Rollback plan request"
    $ledger = & $getMilestoneContinuityLedger -LedgerPath $requestValidation.LedgerPath

    $resolvedBindingPath = Resolve-ArtifactPath -ArtifactPath $BaselineBindingPath
    $bindingValidation = & $testMilestoneAutocycleBaselineBindingContract -BindingPath $resolvedBindingPath
    $baselineValidation = & $testMilestoneBaselineRecordContract -BaselinePath $bindingValidation.BaselinePath
    $baselineDocument = Get-JsonDocument -Path $bindingValidation.BaselinePath -Label "Milestone baseline"

    Assert-RepositoryRootMatchesRepositoryName -RepositoryRoot $baselineDocument.git.repository_root -RepositoryName $foundation.repository_name -Context "Rollback plan target"

    $rollbackPlan = [pscustomobject]@{
        contract_version = $foundation.contract_version
        record_type = $foundation.rollback_plan_record_type
        rollback_plan_id = $RollbackPlanId
        rollback_plan_request_id = $request.rollback_plan_request_id
        planned_at = $PlannedAt.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        cycle_context = $ledger.cycle_context
        repository = $ledger.repository
        source_continuity = [pscustomobject]@{
            ledger_ref = [pscustomobject]@{
                record_type = $foundation.ledger_record_type
                ledger_id = $ledger.ledger_id
                ledger_path = (Get-RepoRelativePathFromResolvedPath -ResolvedPath $requestValidation.LedgerPath)
            }
            task_id = $ledger.ordered_segments[0].task_id
            interrupted_segment_id = $ledger.ordered_segments[0].segment_id
            successor_segment_id = $ledger.ordered_segments[1].segment_id
            ledger_continuity_state = $ledger.ledger_continuity_state
        }
        rollback_target = [pscustomobject]@{
            target_scope = $request.target_scope
            baseline_binding_ref = [pscustomobject]@{
                record_type = "milestone_autocycle_baseline_binding"
                binding_id = $bindingValidation.BindingId
                binding_path = $bindingValidation.BindingPath
            }
            baseline_ref = [pscustomobject]@{
                record_type = "milestone_baseline"
                baseline_id = $baselineValidation.BaselineId
                baseline_path = $bindingValidation.BaselinePath
            }
            repository_root = $baselineDocument.git.repository_root
            branch = $baselineDocument.git.branch
            head_commit = $baselineDocument.git.head_commit
            tree_id = $baselineDocument.git.tree_id
        }
        environment_constraints = [pscustomobject]@{
            allowed_environment_scope = $request.allowed_environment_scope
            primary_worktree_execution = "refused"
        }
        supervision = $ledger.supervision
        operator_approval = [pscustomobject]@{
            approval_required = $request.operator_approval_required
            required_authority_state = $request.required_approval_state
            approved_for_execution = $false
        }
        refusal_conditions = @($request.refusal_conditions)
        execution_state = "not_executed"
        authoritative_refs = $ledger.authoritative_refs
        non_claims = @(
            "plan_only_no_execution_no_drill_no_primary_worktree_rollback"
        )
        notes = "This governed rollback plan records one bounded rollback target and future approval guard from accepted continuity-ledger truth plus accepted baseline-binding truth only. It does not execute rollback, does not run a rollback drill, and does not permit primary-worktree rollback."
    }

    $savedPlanPath = Write-JsonDocument -Document $rollbackPlan -OutputPath $RollbackPlanPath
    $validation = Test-MilestoneRollbackPlanContract -RollbackPlanPath $savedPlanPath

    return [pscustomobject]@{
        RollbackPlan = $rollbackPlan
        RollbackPlanPath = $savedPlanPath
        Validation = $validation
        SourceArtifacts = [pscustomobject]@{
            RollbackPlanRequestId = $requestValidation.RollbackPlanRequestId
            LedgerId = $requestValidation.LedgerId
            BindingId = $bindingValidation.BindingId
            BaselineId = $baselineValidation.BaselineId
        }
    }
}

Export-ModuleMember -Function Test-MilestoneRollbackPlanRequestContract, Test-MilestoneRollbackPlanRequestObject, Test-MilestoneRollbackPlanContract, Test-MilestoneRollbackPlanObject, Get-MilestoneRollbackPlan, Invoke-MilestoneRollbackPlan
