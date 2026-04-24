Set-StrictMode -Version Latest

$continuityLedgerModule = Import-Module (Join-Path $PSScriptRoot "MilestoneContinuityLedger.psm1") -Force -PassThru
$rollbackPlanModule = Import-Module (Join-Path $PSScriptRoot "MilestoneRollbackPlan.psm1") -Force -PassThru
$rollbackDrillModule = Import-Module (Join-Path $PSScriptRoot "MilestoneRollbackDrill.psm1") -Force -PassThru

$testMilestoneContinuityLedgerContract = $continuityLedgerModule.ExportedCommands["Test-MilestoneContinuityLedgerContract"]
$getMilestoneContinuityLedger = $continuityLedgerModule.ExportedCommands["Get-MilestoneContinuityLedger"]
$testMilestoneRollbackPlanContract = $rollbackPlanModule.ExportedCommands["Test-MilestoneRollbackPlanContract"]
$getMilestoneRollbackPlan = $rollbackPlanModule.ExportedCommands["Get-MilestoneRollbackPlan"]
$testMilestoneRollbackDrillResultContract = $rollbackDrillModule.ExportedCommands["Test-MilestoneRollbackDrillResultContract"]
$getMilestoneRollbackDrillResult = $rollbackDrillModule.ExportedCommands["Get-MilestoneRollbackDrillResult"]

$script:continuityLedgerReferenceCache = @{}
$script:rollbackPlanReferenceCache = @{}
$script:rollbackDrillReferenceCache = @{}
$script:reviewSummaryValidationCache = @{}
$script:reviewSummaryDocumentCache = @{}

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
        throw "Continuity review artifact path '$ArtifactPath' does not exist."
    }

    return (Resolve-Path -LiteralPath $resolvedPath).Path
}

function Resolve-OutputPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )

    if ([System.IO.Path]::IsPathRooted($OutputPath)) {
        return [System.IO.Path]::GetFullPath($OutputPath)
    }

    return [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $OutputPath))
}

function Resolve-ReferenceAgainstBase {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory,
        [Parameter(Mandatory = $true)]
        [string]$Reference,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    if ([System.IO.Path]::IsPathRooted($Reference)) {
        $candidatePath = $Reference
    }
    else {
        $candidatePath = Join-Path $BaseDirectory ($Reference -replace "[/\\]", [System.IO.Path]::DirectorySeparatorChar)
    }

    if (-not (Test-Path -LiteralPath $candidatePath)) {
        throw "$Label reference '$Reference' does not exist."
    }

    return (Resolve-Path -LiteralPath $candidatePath).Path
}

function Get-RelativeReference {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory,
        [Parameter(Mandatory = $true)]
        [string]$TargetPath
    )

    $resolvedBaseDirectory = [System.IO.Path]::GetFullPath($BaseDirectory)
    $resolvedTargetPath = Resolve-ArtifactPath -ArtifactPath $TargetPath
    $baseUri = [System.Uri]("{0}{1}" -f $resolvedBaseDirectory.TrimEnd("\/"), [System.IO.Path]::DirectorySeparatorChar)
    $targetUri = [System.Uri]$resolvedTargetPath
    return ($baseUri.MakeRelativeUri($targetUri).OriginalString).Replace("\", "/")
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

function Get-MilestoneContinuityFoundationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_continuity\foundation.contract.json") -Label "Milestone continuity foundation contract"
}

function Get-MilestoneContinuityReviewSummaryContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_continuity\review_summary.contract.json") -Label "Continuity review summary contract"
}

function Get-MilestoneContinuityOperatorPacketContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_continuity\operator_packet.contract.json") -Label "Continuity operator packet contract"
}

function Assert-SafeAdvisoryText {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [Parameter(Mandatory = $true)]
        [string[]]$ProhibitedFragments
    )

    $text = Assert-NonEmptyString -Value $Value -Context $Context
    foreach ($fragment in $ProhibitedFragments) {
        if ($text.IndexOf($fragment, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
            throw "$Context must not imply '$fragment'."
        }
    }

    return $text
}

function Validate-ExactStringSet {
    param(
        [AllowNull()]
        $Items,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [Parameter(Mandatory = $true)]
        [string[]]$ExpectedValues
    )

    $values = @(Assert-StringArray -Value $Items -Context $Context -MinimumCount $ExpectedValues.Count)
    $actual = @($values | Sort-Object -Unique)
    $expected = @($ExpectedValues | Sort-Object -Unique)

    if ($actual.Count -ne $expected.Count) {
        throw "$Context must contain exactly: $($expected -join ', ')."
    }

    foreach ($expectedValue in $expected) {
        if ($actual -notcontains $expectedValue) {
            throw "$Context must contain exactly: $($expected -join ', ')."
        }
    }

    return $ExpectedValues
}

function Validate-CycleContext {
    param(
        [Parameter(Mandatory = $true)]
        $CycleContext,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        $Foundation,
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
        $Contract,
        [Parameter(Mandatory = $true)]
        $Foundation,
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

function Validate-GitContext {
    param(
        [Parameter(Mandatory = $true)]
        $GitContext,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        [string]$ContextPrefix
    )

    foreach ($fieldName in @($Contract.git_context_required_fields)) {
        Get-RequiredProperty -Object $GitContext -Name $fieldName -Context $ContextPrefix | Out-Null
    }

    $branch = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $GitContext -Name "branch" -Context $ContextPrefix) -Context "$ContextPrefix.branch"
    Assert-RegexMatch -Value $branch -Pattern $Foundation.branch_pattern -Context "$ContextPrefix.branch"
    $headCommit = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $GitContext -Name "head_commit" -Context $ContextPrefix) -Context "$ContextPrefix.head_commit"
    Assert-RegexMatch -Value $headCommit -Pattern $Foundation.git_object_pattern -Context "$ContextPrefix.head_commit"
    $treeId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $GitContext -Name "tree_id" -Context $ContextPrefix) -Context "$ContextPrefix.tree_id"
    Assert-RegexMatch -Value $treeId -Pattern $Foundation.git_object_pattern -Context "$ContextPrefix.tree_id"

    return [pscustomobject]@{
        Branch = $branch
        HeadCommit = $headCommit
        TreeId = $treeId
    }
}

function Validate-Supervision {
    param(
        [Parameter(Mandatory = $true)]
        $Supervision,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        $Foundation,
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
        throw "$ContextPrefix.resume_authority_state must remain 'operator_review_required'."
    }

    return [pscustomobject]@{
        Mode = $mode
        OperatorAuthority = $operatorAuthority
        ResumeAuthorityState = $resumeAuthorityState
    }
}

function Validate-ContinuityLedgerReviewReference {
    param(
        [Parameter(Mandatory = $true)]
        $LedgerRef,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        [string]$ContextPrefix,
        [string]$AnchorPath = (Get-Location)
    )

    foreach ($fieldName in @($Contract.continuity_ledger_ref_required_fields)) {
        Get-RequiredProperty -Object $LedgerRef -Name $fieldName -Context $ContextPrefix | Out-Null
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $LedgerRef -Name "record_type" -Context $ContextPrefix) -Context "$ContextPrefix.record_type"
    if ($recordType -ne $Foundation.ledger_record_type) {
        throw "$ContextPrefix.record_type must equal '$($Foundation.ledger_record_type)'."
    }

    $ledgerId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $LedgerRef -Name "ledger_id" -Context $ContextPrefix) -Context "$ContextPrefix.ledger_id"
    Assert-RegexMatch -Value $ledgerId -Pattern $Foundation.identifier_pattern -Context "$ContextPrefix.ledger_id"
    $ledgerPathValue = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $LedgerRef -Name "ledger_path" -Context $ContextPrefix) -Context "$ContextPrefix.ledger_path"
    $resolvedLedgerPath = Resolve-ReferenceAgainstBase -BaseDirectory $AnchorPath -Reference $ledgerPathValue -Label "Continuity review ledger"
    if ($script:continuityLedgerReferenceCache.ContainsKey($resolvedLedgerPath)) {
        $cachedEntry = $script:continuityLedgerReferenceCache[$resolvedLedgerPath]
        $validation = $cachedEntry.Validation
        $document = $cachedEntry.Document
    }
    else {
        $validation = & $testMilestoneContinuityLedgerContract -LedgerPath $resolvedLedgerPath
        $document = & $getMilestoneContinuityLedger -LedgerPath $resolvedLedgerPath
        $script:continuityLedgerReferenceCache[$resolvedLedgerPath] = [pscustomobject]@{
            Validation = $validation
            Document = $document
        }
    }

    if ($validation.LedgerId -ne $ledgerId) {
        throw "$ContextPrefix.ledger_id must match the referenced continuity ledger."
    }

    return [pscustomobject]@{
        LedgerId = $validation.LedgerId
        LedgerPath = $resolvedLedgerPath
        Validation = $validation
        Document = $document
    }
}

function Validate-RollbackPlanReviewReference {
    param(
        [Parameter(Mandatory = $true)]
        $RollbackPlanRef,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        [string]$ContextPrefix,
        [string]$AnchorPath = (Get-Location)
    )

    foreach ($fieldName in @($Contract.rollback_plan_ref_required_fields)) {
        Get-RequiredProperty -Object $RollbackPlanRef -Name $fieldName -Context $ContextPrefix | Out-Null
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackPlanRef -Name "record_type" -Context $ContextPrefix) -Context "$ContextPrefix.record_type"
    if ($recordType -ne $Foundation.rollback_plan_record_type) {
        throw "$ContextPrefix.record_type must equal '$($Foundation.rollback_plan_record_type)'."
    }

    $rollbackPlanId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackPlanRef -Name "rollback_plan_id" -Context $ContextPrefix) -Context "$ContextPrefix.rollback_plan_id"
    Assert-RegexMatch -Value $rollbackPlanId -Pattern $Foundation.identifier_pattern -Context "$ContextPrefix.rollback_plan_id"
    $rollbackPlanPathValue = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackPlanRef -Name "rollback_plan_path" -Context $ContextPrefix) -Context "$ContextPrefix.rollback_plan_path"
    $resolvedRollbackPlanPath = Resolve-ReferenceAgainstBase -BaseDirectory $AnchorPath -Reference $rollbackPlanPathValue -Label "Continuity review rollback plan"
    if ($script:rollbackPlanReferenceCache.ContainsKey($resolvedRollbackPlanPath)) {
        $cachedEntry = $script:rollbackPlanReferenceCache[$resolvedRollbackPlanPath]
        $validation = $cachedEntry.Validation
        $document = $cachedEntry.Document
    }
    else {
        $validation = & $testMilestoneRollbackPlanContract -RollbackPlanPath $resolvedRollbackPlanPath
        $document = & $getMilestoneRollbackPlan -RollbackPlanPath $resolvedRollbackPlanPath
        $script:rollbackPlanReferenceCache[$resolvedRollbackPlanPath] = [pscustomobject]@{
            Validation = $validation
            Document = $document
        }
    }

    if ($validation.RollbackPlanId -ne $rollbackPlanId) {
        throw "$ContextPrefix.rollback_plan_id must match the referenced rollback plan."
    }

    return [pscustomobject]@{
        RollbackPlanId = $validation.RollbackPlanId
        RollbackPlanPath = $resolvedRollbackPlanPath
        Validation = $validation
        Document = $document
    }
}

function Validate-RollbackDrillReviewReference {
    param(
        [Parameter(Mandatory = $true)]
        $RollbackDrillRef,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        [string]$ContextPrefix,
        [string]$AnchorPath = (Get-Location)
    )

    foreach ($fieldName in @($Contract.rollback_drill_result_ref_required_fields)) {
        Get-RequiredProperty -Object $RollbackDrillRef -Name $fieldName -Context $ContextPrefix | Out-Null
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackDrillRef -Name "record_type" -Context $ContextPrefix) -Context "$ContextPrefix.record_type"
    if ($recordType -ne $Foundation.rollback_drill_result_record_type) {
        throw "$ContextPrefix.record_type must equal '$($Foundation.rollback_drill_result_record_type)'."
    }

    $rollbackDrillId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackDrillRef -Name "rollback_drill_id" -Context $ContextPrefix) -Context "$ContextPrefix.rollback_drill_id"
    Assert-RegexMatch -Value $rollbackDrillId -Pattern $Foundation.identifier_pattern -Context "$ContextPrefix.rollback_drill_id"
    $drillResultPathValue = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackDrillRef -Name "drill_result_path" -Context $ContextPrefix) -Context "$ContextPrefix.drill_result_path"
    $resolvedDrillResultPath = Resolve-ReferenceAgainstBase -BaseDirectory $AnchorPath -Reference $drillResultPathValue -Label "Continuity review rollback drill result"
    if ($script:rollbackDrillReferenceCache.ContainsKey($resolvedDrillResultPath)) {
        $cachedEntry = $script:rollbackDrillReferenceCache[$resolvedDrillResultPath]
        $validation = $cachedEntry.Validation
        $document = $cachedEntry.Document
    }
    else {
        $validation = & $testMilestoneRollbackDrillResultContract -DrillResultPath $resolvedDrillResultPath
        $document = & $getMilestoneRollbackDrillResult -DrillResultPath $resolvedDrillResultPath
        $script:rollbackDrillReferenceCache[$resolvedDrillResultPath] = [pscustomobject]@{
            Validation = $validation
            Document = $document
        }
    }

    if ($validation.RollbackDrillId -ne $rollbackDrillId) {
        throw "$ContextPrefix.rollback_drill_id must match the referenced rollback drill result."
    }

    return [pscustomobject]@{
        RollbackDrillId = $validation.RollbackDrillId
        DrillResultPath = $resolvedDrillResultPath
        Validation = $validation
        Document = $document
    }
}

function Validate-ContinuityIdentity {
    param(
        [Parameter(Mandatory = $true)]
        $ContinuityIdentity,
        [Parameter(Mandatory = $true)]
        [string[]]$RequiredFields,
        [Parameter(Mandatory = $true)]
        $LedgerReference,
        [Parameter(Mandatory = $true)]
        $RollbackPlanReference,
        [Parameter(Mandatory = $true)]
        $RollbackDrillReference,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        [string]$ContextPrefix
    )

    foreach ($fieldName in $RequiredFields) {
        Get-RequiredProperty -Object $ContinuityIdentity -Name $fieldName -Context $ContextPrefix | Out-Null
    }

    $taskId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ContinuityIdentity -Name "task_id" -Context $ContextPrefix) -Context "$ContextPrefix.task_id"
    $interruptedSegmentId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ContinuityIdentity -Name "interrupted_segment_id" -Context $ContextPrefix) -Context "$ContextPrefix.interrupted_segment_id"
    $successorSegmentId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ContinuityIdentity -Name "successor_segment_id" -Context $ContextPrefix) -Context "$ContextPrefix.successor_segment_id"

    foreach ($pair in @(
            @{ Value = $taskId; Context = "$ContextPrefix.task_id" },
            @{ Value = $interruptedSegmentId; Context = "$ContextPrefix.interrupted_segment_id" },
            @{ Value = $successorSegmentId; Context = "$ContextPrefix.successor_segment_id" }
        )) {
        Assert-RegexMatch -Value $pair.Value -Pattern $Foundation.identifier_pattern -Context $pair.Context
    }

    if ($taskId -ne $LedgerReference.Validation.TaskId -or $taskId -ne $RollbackPlanReference.Validation.TaskId -or $taskId -ne $RollbackDrillReference.Validation.TaskId) {
        throw "$ContextPrefix.task_id must match the referenced continuity ledger, rollback plan, and rollback drill result."
    }
    if ($interruptedSegmentId -ne $LedgerReference.Validation.InterruptedSegmentId -or $interruptedSegmentId -ne $RollbackPlanReference.Validation.InterruptedSegmentId -or $interruptedSegmentId -ne $RollbackDrillReference.Validation.InterruptedSegmentId) {
        throw "$ContextPrefix.interrupted_segment_id must match the referenced continuity lineage exactly."
    }
    if ($successorSegmentId -ne $LedgerReference.Validation.SuccessorSegmentId -or $successorSegmentId -ne $RollbackPlanReference.Validation.SuccessorSegmentId -or $successorSegmentId -ne $RollbackDrillReference.Validation.SuccessorSegmentId) {
        throw "$ContextPrefix.successor_segment_id must match the referenced continuity lineage exactly."
    }

    $rollbackPlanId = $null
    if ($RequiredFields -contains "rollback_plan_id") {
        $rollbackPlanId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ContinuityIdentity -Name "rollback_plan_id" -Context $ContextPrefix) -Context "$ContextPrefix.rollback_plan_id"
        Assert-RegexMatch -Value $rollbackPlanId -Pattern $Foundation.identifier_pattern -Context "$ContextPrefix.rollback_plan_id"
        if ($rollbackPlanId -ne $RollbackPlanReference.Validation.RollbackPlanId) {
            throw "$ContextPrefix.rollback_plan_id must match the referenced rollback plan."
        }
    }

    $rollbackDrillId = $null
    if ($RequiredFields -contains "rollback_drill_id") {
        $rollbackDrillId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ContinuityIdentity -Name "rollback_drill_id" -Context $ContextPrefix) -Context "$ContextPrefix.rollback_drill_id"
        Assert-RegexMatch -Value $rollbackDrillId -Pattern $Foundation.identifier_pattern -Context "$ContextPrefix.rollback_drill_id"
        if ($rollbackDrillId -ne $RollbackDrillReference.Validation.RollbackDrillId) {
            throw "$ContextPrefix.rollback_drill_id must match the referenced rollback drill result."
        }
    }

    return [pscustomobject]@{
        TaskId = $taskId
        InterruptedSegmentId = $interruptedSegmentId
        SuccessorSegmentId = $successorSegmentId
        RollbackPlanId = $rollbackPlanId
        RollbackDrillId = $rollbackDrillId
    }
}

function Validate-EvidenceSnapshot {
    param(
        [Parameter(Mandatory = $true)]
        $EvidenceSnapshot,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $LedgerReference,
        [Parameter(Mandatory = $true)]
        $RollbackPlanReference,
        [Parameter(Mandatory = $true)]
        $RollbackDrillReference,
        [Parameter(Mandatory = $true)]
        [string]$ContextPrefix
    )

    foreach ($fieldName in @($Contract.evidence_snapshot_required_fields)) {
        Get-RequiredProperty -Object $EvidenceSnapshot -Name $fieldName -Context $ContextPrefix | Out-Null
    }

    $ledgerContinuityState = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $EvidenceSnapshot -Name "ledger_continuity_state" -Context $ContextPrefix) -Context "$ContextPrefix.ledger_continuity_state"
    Assert-AllowedValue -Value $ledgerContinuityState -AllowedValues @($Foundation.allowed_ledger_continuity_states) -Context "$ContextPrefix.ledger_continuity_state"
    if ($ledgerContinuityState -ne $LedgerReference.Validation.LedgerContinuityState) {
        throw "$ContextPrefix.ledger_continuity_state must match the referenced continuity ledger."
    }

    $rollbackPlanExecutionState = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $EvidenceSnapshot -Name "rollback_plan_execution_state" -Context $ContextPrefix) -Context "$ContextPrefix.rollback_plan_execution_state"
    Assert-AllowedValue -Value $rollbackPlanExecutionState -AllowedValues @($Foundation.allowed_rollback_execution_states) -Context "$ContextPrefix.rollback_plan_execution_state"
    if ($rollbackPlanExecutionState -ne $RollbackPlanReference.Validation.ExecutionState) {
        throw "$ContextPrefix.rollback_plan_execution_state must match the referenced rollback plan."
    }

    $rollbackTargetScope = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $EvidenceSnapshot -Name "rollback_target_scope" -Context $ContextPrefix) -Context "$ContextPrefix.rollback_target_scope"
    Assert-AllowedValue -Value $rollbackTargetScope -AllowedValues @($Foundation.allowed_rollback_target_scopes) -Context "$ContextPrefix.rollback_target_scope"
    if ($rollbackTargetScope -ne $RollbackPlanReference.Document.rollback_target.target_scope) {
        throw "$ContextPrefix.rollback_target_scope must match the referenced rollback plan."
    }

    $rollbackEnvironmentScope = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $EvidenceSnapshot -Name "rollback_environment_scope" -Context $ContextPrefix) -Context "$ContextPrefix.rollback_environment_scope"
    Assert-AllowedValue -Value $rollbackEnvironmentScope -AllowedValues @($Foundation.allowed_rollback_environment_scopes) -Context "$ContextPrefix.rollback_environment_scope"
    if ($rollbackEnvironmentScope -ne $RollbackPlanReference.Validation.AllowedEnvironmentScope) {
        throw "$ContextPrefix.rollback_environment_scope must match the referenced rollback plan."
    }

    $rollbackDrillExecutionState = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $EvidenceSnapshot -Name "rollback_drill_execution_state" -Context $ContextPrefix) -Context "$ContextPrefix.rollback_drill_execution_state"
    Assert-AllowedValue -Value $rollbackDrillExecutionState -AllowedValues @($Foundation.allowed_rollback_drill_execution_states) -Context "$ContextPrefix.rollback_drill_execution_state"
    if ($rollbackDrillExecutionState -ne $RollbackDrillReference.Validation.ExecutionState) {
        throw "$ContextPrefix.rollback_drill_execution_state must match the referenced rollback drill result."
    }

    $rollbackDrillEnvironmentScope = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $EvidenceSnapshot -Name "rollback_drill_environment_scope" -Context $ContextPrefix) -Context "$ContextPrefix.rollback_drill_environment_scope"
    Assert-AllowedValue -Value $rollbackDrillEnvironmentScope -AllowedValues @($Foundation.allowed_rollback_drill_environment_scopes) -Context "$ContextPrefix.rollback_drill_environment_scope"
    if ($rollbackDrillEnvironmentScope -ne $RollbackDrillReference.Validation.EnvironmentScope) {
        throw "$ContextPrefix.rollback_drill_environment_scope must match the referenced rollback drill result."
    }

    $rollbackDrillAction = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $EvidenceSnapshot -Name "rollback_drill_action" -Context $ContextPrefix) -Context "$ContextPrefix.rollback_drill_action"
    Assert-AllowedValue -Value $rollbackDrillAction -AllowedValues @($Foundation.allowed_rollback_drill_actions) -Context "$ContextPrefix.rollback_drill_action"
    if ($rollbackDrillAction -ne $RollbackDrillReference.Document.drill_action) {
        throw "$ContextPrefix.rollback_drill_action must match the referenced rollback drill result."
    }

    return [pscustomobject]@{
        LedgerContinuityState = $ledgerContinuityState
        RollbackPlanExecutionState = $rollbackPlanExecutionState
        RollbackTargetScope = $rollbackTargetScope
        RollbackEnvironmentScope = $rollbackEnvironmentScope
        RollbackDrillExecutionState = $rollbackDrillExecutionState
        RollbackDrillEnvironmentScope = $rollbackDrillEnvironmentScope
        RollbackDrillAction = $rollbackDrillAction
    }
}

function Get-DefaultEvidenceQualitySummary {
    return "This advisory review is bounded to one committed continuity ledger, one committed governed rollback plan, and one committed disposable-worktree rollback drill result artifact only. Evidence quality is exact for one repository, one active cycle, and one bounded rehearsal path; it does not claim broader continuity, rollback, or closeout proof."
}

function Get-DefaultSummaryNotes {
    return "This advisory continuity and rollback review summarizes accepted continuity-ledger, rollback-plan, and rollback-drill evidence only. It preserves explicit non-claims, requires manual operator judgment, and does not imply automatic or destructive execution."
}

function Get-DefaultOperatorPacketNotes {
    return "This operator packet is advisory only. It presents one bounded recommendation plus bounded operator options without executing rollback, without authorizing unattended action, and without widening the proved R7 scope."
}

function Test-MilestoneContinuityReviewSummaryDocument {
    param(
        [Parameter(Mandatory = $true)]
        $ReviewSummary,
        [Parameter(Mandatory = $true)]
        [string]$SourceLabel,
        [AllowNull()]
        [string]$ReviewSummaryPath
    )

    $foundation = Get-MilestoneContinuityFoundationContract
    $contract = Get-MilestoneContinuityReviewSummaryContract

    foreach ($fieldName in @($contract.required_fields)) {
        Get-RequiredProperty -Object $ReviewSummary -Name $fieldName -Context "Continuity review summary" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ReviewSummary -Name "contract_version" -Context "Continuity review summary") -Context "Continuity review summary.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "Continuity review summary.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ReviewSummary -Name "record_type" -Context "Continuity review summary") -Context "Continuity review summary.record_type"
    if ($recordType -ne $foundation.review_summary_record_type -or $recordType -ne $contract.record_type) {
        throw "Continuity review summary.record_type must equal '$($foundation.review_summary_record_type)'."
    }

    $reviewSummaryId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ReviewSummary -Name "review_summary_id" -Context "Continuity review summary") -Context "Continuity review summary.review_summary_id"
    Assert-RegexMatch -Value $reviewSummaryId -Pattern $foundation.identifier_pattern -Context "Continuity review summary.review_summary_id"
    $reviewedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ReviewSummary -Name "reviewed_at" -Context "Continuity review summary") -Context "Continuity review summary.reviewed_at"
    Assert-RegexMatch -Value $reviewedAt -Pattern $foundation.timestamp_pattern -Context "Continuity review summary.reviewed_at"

    $cycleContext = Validate-CycleContext -CycleContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $ReviewSummary -Name "cycle_context" -Context "Continuity review summary") -Context "Continuity review summary.cycle_context") -Contract $contract -Foundation $foundation -ContextPrefix "Continuity review summary.cycle_context"
    $repositoryName = Validate-RepositoryContext -RepositoryContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $ReviewSummary -Name "repository" -Context "Continuity review summary") -Context "Continuity review summary.repository") -Contract $contract -Foundation $foundation -ContextPrefix "Continuity review summary.repository"

    $anchorPath = if ([string]::IsNullOrWhiteSpace([string]$ReviewSummaryPath)) { Get-Location } else { Split-Path -Parent $ReviewSummaryPath }
    $evidenceRefs = Assert-ObjectValue -Value (Get-RequiredProperty -Object $ReviewSummary -Name "evidence_refs" -Context "Continuity review summary") -Context "Continuity review summary.evidence_refs"
    foreach ($fieldName in @($contract.evidence_refs_required_fields)) {
        Get-RequiredProperty -Object $evidenceRefs -Name $fieldName -Context "Continuity review summary.evidence_refs" | Out-Null
    }

    $ledgerReference = Validate-ContinuityLedgerReviewReference -LedgerRef (Assert-ObjectValue -Value (Get-RequiredProperty -Object $evidenceRefs -Name "continuity_ledger_ref" -Context "Continuity review summary.evidence_refs") -Context "Continuity review summary.evidence_refs.continuity_ledger_ref") -Contract $contract -Foundation $foundation -ContextPrefix "Continuity review summary.evidence_refs.continuity_ledger_ref" -AnchorPath $anchorPath
    $rollbackPlanReference = Validate-RollbackPlanReviewReference -RollbackPlanRef (Assert-ObjectValue -Value (Get-RequiredProperty -Object $evidenceRefs -Name "rollback_plan_ref" -Context "Continuity review summary.evidence_refs") -Context "Continuity review summary.evidence_refs.rollback_plan_ref") -Contract $contract -Foundation $foundation -ContextPrefix "Continuity review summary.evidence_refs.rollback_plan_ref" -AnchorPath $anchorPath
    $rollbackDrillReference = Validate-RollbackDrillReviewReference -RollbackDrillRef (Assert-ObjectValue -Value (Get-RequiredProperty -Object $evidenceRefs -Name "rollback_drill_result_ref" -Context "Continuity review summary.evidence_refs") -Context "Continuity review summary.evidence_refs.rollback_drill_result_ref") -Contract $contract -Foundation $foundation -ContextPrefix "Continuity review summary.evidence_refs.rollback_drill_result_ref" -AnchorPath $anchorPath

    if ($cycleContext.CycleId -ne $ledgerReference.Validation.CycleId -or $cycleContext.CycleId -ne $rollbackPlanReference.Validation.CycleId -or $cycleContext.CycleId -ne $rollbackDrillReference.Validation.CycleId) {
        throw "Continuity review summary.cycle_context.cycle_id must match the referenced continuity, rollback plan, and rollback drill evidence."
    }
    if ($cycleContext.MilestoneId -ne $ledgerReference.Validation.MilestoneId -or $cycleContext.MilestoneId -ne $rollbackPlanReference.Validation.MilestoneId -or $cycleContext.MilestoneId -ne $rollbackDrillReference.Validation.MilestoneId) {
        throw "Continuity review summary.cycle_context.milestone_id must match the referenced continuity, rollback plan, and rollback drill evidence."
    }
    if ($repositoryName -ne $ledgerReference.Validation.RepositoryName -or $repositoryName -ne $rollbackPlanReference.Validation.RepositoryName -or $repositoryName -ne $rollbackDrillReference.Document.repository.repository_name) {
        throw "Continuity review summary.repository.repository_name must match the referenced continuity, rollback plan, and rollback drill evidence."
    }

    $continuityIdentity = Validate-ContinuityIdentity -ContinuityIdentity (Assert-ObjectValue -Value (Get-RequiredProperty -Object $ReviewSummary -Name "continuity_identity" -Context "Continuity review summary") -Context "Continuity review summary.continuity_identity") -RequiredFields @($contract.continuity_identity_required_fields) -LedgerReference $ledgerReference -RollbackPlanReference $rollbackPlanReference -RollbackDrillReference $rollbackDrillReference -Foundation $foundation -ContextPrefix "Continuity review summary.continuity_identity"

    $continuityGitContext = Validate-GitContext -GitContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $ReviewSummary -Name "continuity_git_context" -Context "Continuity review summary") -Context "Continuity review summary.continuity_git_context") -Contract $contract -Foundation $foundation -ContextPrefix "Continuity review summary.continuity_git_context"
    if ($continuityGitContext.Branch -ne $ledgerReference.Validation.Branch -or $continuityGitContext.HeadCommit -ne $ledgerReference.Validation.HeadCommit -or $continuityGitContext.TreeId -ne $ledgerReference.Validation.TreeId) {
        throw "Continuity review summary.continuity_git_context must match the referenced continuity ledger."
    }

    $rollbackTargetGitContext = Validate-GitContext -GitContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $ReviewSummary -Name "rollback_target_git_context" -Context "Continuity review summary") -Context "Continuity review summary.rollback_target_git_context") -Contract $contract -Foundation $foundation -ContextPrefix "Continuity review summary.rollback_target_git_context"
    if ($rollbackTargetGitContext.Branch -ne $rollbackPlanReference.Validation.TargetBranch -or $rollbackTargetGitContext.HeadCommit -ne $rollbackPlanReference.Validation.TargetHeadCommit -or $rollbackTargetGitContext.TreeId -ne $rollbackPlanReference.Validation.TargetTreeId) {
        throw "Continuity review summary.rollback_target_git_context must match the referenced rollback plan target."
    }
    if ($rollbackTargetGitContext.Branch -ne $rollbackDrillReference.Document.target_git_context.branch -or $rollbackTargetGitContext.HeadCommit -ne $rollbackDrillReference.Validation.TargetHeadCommit -or $rollbackTargetGitContext.TreeId -ne $rollbackDrillReference.Validation.TargetTreeId) {
        throw "Continuity review summary.rollback_target_git_context must match the referenced rollback drill result target."
    }

    $supervision = Validate-Supervision -Supervision (Assert-ObjectValue -Value (Get-RequiredProperty -Object $ReviewSummary -Name "supervision" -Context "Continuity review summary") -Context "Continuity review summary.supervision") -Contract $contract -Foundation $foundation -ContextPrefix "Continuity review summary.supervision"
    if ($supervision.OperatorAuthority -ne $ledgerReference.Validation.OperatorAuthority -or $supervision.OperatorAuthority -ne $rollbackPlanReference.Validation.OperatorAuthority -or $supervision.OperatorAuthority -ne $rollbackDrillReference.Validation.OperatorAuthority) {
        throw "Continuity review summary.supervision.operator_authority must stay aligned across the referenced evidence chain."
    }
    if ($supervision.Mode -ne $rollbackPlanReference.Document.supervision.mode -or $supervision.Mode -ne $rollbackDrillReference.Document.supervision.mode) {
        throw "Continuity review summary.supervision.mode must match the referenced rollback evidence."
    }
    if ($supervision.ResumeAuthorityState -ne $rollbackPlanReference.Document.supervision.resume_authority_state -or $supervision.ResumeAuthorityState -ne $rollbackDrillReference.Document.supervision.resume_authority_state) {
        throw "Continuity review summary.supervision.resume_authority_state must match the referenced rollback evidence."
    }

    $evidenceSnapshot = Validate-EvidenceSnapshot -EvidenceSnapshot (Assert-ObjectValue -Value (Get-RequiredProperty -Object $ReviewSummary -Name "evidence_snapshot" -Context "Continuity review summary") -Context "Continuity review summary.evidence_snapshot") -Contract $contract -Foundation $foundation -LedgerReference $ledgerReference -RollbackPlanReference $rollbackPlanReference -RollbackDrillReference $rollbackDrillReference -ContextPrefix "Continuity review summary.evidence_snapshot"

    $evidenceQualitySummary = Assert-SafeAdvisoryText -Value (Get-RequiredProperty -Object $ReviewSummary -Name "evidence_quality_summary" -Context "Continuity review summary") -Context "Continuity review summary.evidence_quality_summary" -ProhibitedFragments @($contract.prohibited_claim_fragments)
    $scopeLimitations = Validate-ExactStringSet -Items (Get-RequiredProperty -Object $ReviewSummary -Name "scope_limitations" -Context "Continuity review summary") -Context "Continuity review summary.scope_limitations" -ExpectedValues @($foundation.allowed_review_scope_limitations)
    $nonClaims = Validate-ExactStringSet -Items (Get-RequiredProperty -Object $ReviewSummary -Name "non_claims" -Context "Continuity review summary") -Context "Continuity review summary.non_claims" -ExpectedValues @($foundation.allowed_review_non_claims)

    $recommendation = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ReviewSummary -Name "recommendation" -Context "Continuity review summary") -Context "Continuity review summary.recommendation"
    Assert-AllowedValue -Value $recommendation -AllowedValues @($foundation.allowed_review_recommendations) -Context "Continuity review summary.recommendation"
    $recommendationIsAdvisory = Assert-BooleanValue -Value (Get-RequiredProperty -Object $ReviewSummary -Name "recommendation_is_advisory" -Context "Continuity review summary") -Context "Continuity review summary.recommendation_is_advisory"
    if (-not $recommendationIsAdvisory) {
        throw "Continuity review summary.recommendation_is_advisory must remain true."
    }

    $automaticExecutionImplied = Assert-BooleanValue -Value (Get-RequiredProperty -Object $ReviewSummary -Name "automatic_execution_implied" -Context "Continuity review summary") -Context "Continuity review summary.automatic_execution_implied"
    if ($automaticExecutionImplied) {
        throw "Continuity review summary.automatic_execution_implied must remain false."
    }

    $destructivePrimaryWorktreeRollbackImplied = Assert-BooleanValue -Value (Get-RequiredProperty -Object $ReviewSummary -Name "destructive_primary_worktree_rollback_implied" -Context "Continuity review summary") -Context "Continuity review summary.destructive_primary_worktree_rollback_implied"
    if ($destructivePrimaryWorktreeRollbackImplied) {
        throw "Continuity review summary.destructive_primary_worktree_rollback_implied must remain false."
    }

    $notes = Assert-SafeAdvisoryText -Value (Get-RequiredProperty -Object $ReviewSummary -Name "notes" -Context "Continuity review summary") -Context "Continuity review summary.notes" -ProhibitedFragments @($contract.prohibited_claim_fragments)

    return [pscustomobject]@{
        IsValid = $true
        ReviewSummaryId = $reviewSummaryId
        ReviewSummaryPath = $ReviewSummaryPath
        CycleId = $cycleContext.CycleId
        MilestoneId = $cycleContext.MilestoneId
        RepositoryName = $repositoryName
        TaskId = $continuityIdentity.TaskId
        InterruptedSegmentId = $continuityIdentity.InterruptedSegmentId
        SuccessorSegmentId = $continuityIdentity.SuccessorSegmentId
        LedgerId = $ledgerReference.Validation.LedgerId
        RollbackPlanId = $rollbackPlanReference.Validation.RollbackPlanId
        RollbackDrillId = $rollbackDrillReference.Validation.RollbackDrillId
        Recommendation = $recommendation
        RecommendationIsAdvisory = $recommendationIsAdvisory
        EvidenceQualitySummary = $evidenceQualitySummary
        ScopeLimitations = $scopeLimitations
        NonClaims = $nonClaims
        OperatorAuthority = $supervision.OperatorAuthority
        SourceLabel = $SourceLabel
        Notes = $notes
    }
}

function Test-MilestoneContinuityReviewSummaryContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ReviewSummaryPath
    )

    $resolvedReviewSummaryPath = Resolve-ArtifactPath -ArtifactPath $ReviewSummaryPath
    if ($script:reviewSummaryValidationCache.ContainsKey($resolvedReviewSummaryPath)) {
        return $script:reviewSummaryValidationCache[$resolvedReviewSummaryPath]
    }

    $reviewSummary = Get-JsonDocument -Path $resolvedReviewSummaryPath -Label "Continuity review summary"
    $validation = Test-MilestoneContinuityReviewSummaryDocument -ReviewSummary $reviewSummary -SourceLabel $resolvedReviewSummaryPath -ReviewSummaryPath $resolvedReviewSummaryPath
    $script:reviewSummaryValidationCache[$resolvedReviewSummaryPath] = $validation
    return $validation
}

function Test-MilestoneContinuityReviewSummaryObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $ReviewSummary,
        [string]$SourceLabel = "in-memory continuity review summary"
    )

    return (Test-MilestoneContinuityReviewSummaryDocument -ReviewSummary $ReviewSummary -SourceLabel $SourceLabel -ReviewSummaryPath $null)
}

function Get-MilestoneContinuityReviewSummary {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ReviewSummaryPath
    )

    $validation = Test-MilestoneContinuityReviewSummaryContract -ReviewSummaryPath $ReviewSummaryPath
    if ($script:reviewSummaryDocumentCache.ContainsKey($validation.ReviewSummaryPath)) {
        return $script:reviewSummaryDocumentCache[$validation.ReviewSummaryPath]
    }

    $document = Get-JsonDocument -Path $validation.ReviewSummaryPath -Label "Continuity review summary"
    $script:reviewSummaryDocumentCache[$validation.ReviewSummaryPath] = $document
    return $document
}

function Test-MilestoneContinuityOperatorPacketDocument {
    param(
        [Parameter(Mandatory = $true)]
        $OperatorPacket,
        [Parameter(Mandatory = $true)]
        [string]$SourceLabel,
        [AllowNull()]
        [string]$OperatorPacketPath
    )

    $foundation = Get-MilestoneContinuityFoundationContract
    $contract = Get-MilestoneContinuityOperatorPacketContract

    foreach ($fieldName in @($contract.required_fields)) {
        Get-RequiredProperty -Object $OperatorPacket -Name $fieldName -Context "Continuity operator packet" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $OperatorPacket -Name "contract_version" -Context "Continuity operator packet") -Context "Continuity operator packet.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "Continuity operator packet.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $OperatorPacket -Name "record_type" -Context "Continuity operator packet") -Context "Continuity operator packet.record_type"
    if ($recordType -ne $foundation.operator_packet_record_type -or $recordType -ne $contract.record_type) {
        throw "Continuity operator packet.record_type must equal '$($foundation.operator_packet_record_type)'."
    }

    $operatorPacketId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $OperatorPacket -Name "operator_packet_id" -Context "Continuity operator packet") -Context "Continuity operator packet.operator_packet_id"
    Assert-RegexMatch -Value $operatorPacketId -Pattern $foundation.identifier_pattern -Context "Continuity operator packet.operator_packet_id"
    $preparedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $OperatorPacket -Name "prepared_at" -Context "Continuity operator packet") -Context "Continuity operator packet.prepared_at"
    Assert-RegexMatch -Value $preparedAt -Pattern $foundation.timestamp_pattern -Context "Continuity operator packet.prepared_at"

    $cycleContext = Validate-CycleContext -CycleContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $OperatorPacket -Name "cycle_context" -Context "Continuity operator packet") -Context "Continuity operator packet.cycle_context") -Contract $contract -Foundation $foundation -ContextPrefix "Continuity operator packet.cycle_context"
    $repositoryName = Validate-RepositoryContext -RepositoryContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $OperatorPacket -Name "repository" -Context "Continuity operator packet") -Context "Continuity operator packet.repository") -Contract $contract -Foundation $foundation -ContextPrefix "Continuity operator packet.repository"

    $anchorPath = if ([string]::IsNullOrWhiteSpace([string]$OperatorPacketPath)) { Get-Location } else { Split-Path -Parent $OperatorPacketPath }
    $reviewSummaryRef = Assert-ObjectValue -Value (Get-RequiredProperty -Object $OperatorPacket -Name "review_summary_ref" -Context "Continuity operator packet") -Context "Continuity operator packet.review_summary_ref"
    foreach ($fieldName in @($contract.review_summary_ref_required_fields)) {
        Get-RequiredProperty -Object $reviewSummaryRef -Name $fieldName -Context "Continuity operator packet.review_summary_ref" | Out-Null
    }

    $summaryRecordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $reviewSummaryRef -Name "record_type" -Context "Continuity operator packet.review_summary_ref") -Context "Continuity operator packet.review_summary_ref.record_type"
    if ($summaryRecordType -ne $foundation.review_summary_record_type) {
        throw "Continuity operator packet.review_summary_ref.record_type must equal '$($foundation.review_summary_record_type)'."
    }

    $reviewSummaryId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $reviewSummaryRef -Name "review_summary_id" -Context "Continuity operator packet.review_summary_ref") -Context "Continuity operator packet.review_summary_ref.review_summary_id"
    Assert-RegexMatch -Value $reviewSummaryId -Pattern $foundation.identifier_pattern -Context "Continuity operator packet.review_summary_ref.review_summary_id"
    $reviewSummaryPathValue = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $reviewSummaryRef -Name "review_summary_path" -Context "Continuity operator packet.review_summary_ref") -Context "Continuity operator packet.review_summary_ref.review_summary_path"
    $resolvedReviewSummaryPath = Resolve-ReferenceAgainstBase -BaseDirectory $anchorPath -Reference $reviewSummaryPathValue -Label "Continuity operator packet review summary"
    $reviewSummaryValidation = Test-MilestoneContinuityReviewSummaryContract -ReviewSummaryPath $resolvedReviewSummaryPath
    $reviewSummaryDocument = Get-MilestoneContinuityReviewSummary -ReviewSummaryPath $resolvedReviewSummaryPath

    if ($reviewSummaryValidation.ReviewSummaryId -ne $reviewSummaryId) {
        throw "Continuity operator packet.review_summary_ref.review_summary_id must match the referenced review summary."
    }

    $packetReviewSummaryId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $OperatorPacket -Name "review_summary_id" -Context "Continuity operator packet") -Context "Continuity operator packet.review_summary_id"
    Assert-RegexMatch -Value $packetReviewSummaryId -Pattern $foundation.identifier_pattern -Context "Continuity operator packet.review_summary_id"
    if ($packetReviewSummaryId -ne $reviewSummaryValidation.ReviewSummaryId) {
        throw "Continuity operator packet.review_summary_id must match the referenced review summary."
    }

    if ($cycleContext.CycleId -ne $reviewSummaryValidation.CycleId -or $cycleContext.MilestoneId -ne $reviewSummaryValidation.MilestoneId) {
        throw "Continuity operator packet.cycle_context must match the referenced review summary."
    }
    if ($repositoryName -ne $reviewSummaryValidation.RepositoryName) {
        throw "Continuity operator packet.repository.repository_name must match the referenced review summary."
    }

    $continuityIdentityObject = Assert-ObjectValue -Value (Get-RequiredProperty -Object $OperatorPacket -Name "continuity_identity" -Context "Continuity operator packet") -Context "Continuity operator packet.continuity_identity"
    foreach ($fieldName in @($contract.continuity_identity_required_fields)) {
        Get-RequiredProperty -Object $continuityIdentityObject -Name $fieldName -Context "Continuity operator packet.continuity_identity" | Out-Null
    }

    $taskId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $continuityIdentityObject -Name "task_id" -Context "Continuity operator packet.continuity_identity") -Context "Continuity operator packet.continuity_identity.task_id"
    $interruptedSegmentId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $continuityIdentityObject -Name "interrupted_segment_id" -Context "Continuity operator packet.continuity_identity") -Context "Continuity operator packet.continuity_identity.interrupted_segment_id"
    $successorSegmentId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $continuityIdentityObject -Name "successor_segment_id" -Context "Continuity operator packet.continuity_identity") -Context "Continuity operator packet.continuity_identity.successor_segment_id"
    $rollbackPlanId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $continuityIdentityObject -Name "rollback_plan_id" -Context "Continuity operator packet.continuity_identity") -Context "Continuity operator packet.continuity_identity.rollback_plan_id"
    $rollbackDrillId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $continuityIdentityObject -Name "rollback_drill_id" -Context "Continuity operator packet.continuity_identity") -Context "Continuity operator packet.continuity_identity.rollback_drill_id"

    foreach ($pair in @(
            @{ Value = $taskId; Context = "Continuity operator packet.continuity_identity.task_id" },
            @{ Value = $interruptedSegmentId; Context = "Continuity operator packet.continuity_identity.interrupted_segment_id" },
            @{ Value = $successorSegmentId; Context = "Continuity operator packet.continuity_identity.successor_segment_id" },
            @{ Value = $rollbackPlanId; Context = "Continuity operator packet.continuity_identity.rollback_plan_id" },
            @{ Value = $rollbackDrillId; Context = "Continuity operator packet.continuity_identity.rollback_drill_id" }
        )) {
        Assert-RegexMatch -Value $pair.Value -Pattern $foundation.identifier_pattern -Context $pair.Context
    }

    if ($taskId -ne $reviewSummaryValidation.TaskId -or $interruptedSegmentId -ne $reviewSummaryValidation.InterruptedSegmentId -or $successorSegmentId -ne $reviewSummaryValidation.SuccessorSegmentId -or $rollbackPlanId -ne $reviewSummaryValidation.RollbackPlanId -or $rollbackDrillId -ne $reviewSummaryValidation.RollbackDrillId) {
        throw "Continuity operator packet.continuity_identity must match the referenced review summary."
    }

    $supervision = Validate-Supervision -Supervision (Assert-ObjectValue -Value (Get-RequiredProperty -Object $OperatorPacket -Name "supervision" -Context "Continuity operator packet") -Context "Continuity operator packet.supervision") -Contract $contract -Foundation $foundation -ContextPrefix "Continuity operator packet.supervision"
    if ($supervision.Mode -ne $reviewSummaryDocument.supervision.mode -or $supervision.OperatorAuthority -ne $reviewSummaryDocument.supervision.operator_authority -or $supervision.ResumeAuthorityState -ne $reviewSummaryDocument.supervision.resume_authority_state) {
        throw "Continuity operator packet.supervision must match the referenced review summary."
    }

    $evidenceSnapshotObject = Assert-ObjectValue -Value (Get-RequiredProperty -Object $OperatorPacket -Name "evidence_snapshot" -Context "Continuity operator packet") -Context "Continuity operator packet.evidence_snapshot"
    foreach ($fieldName in @($contract.evidence_snapshot_required_fields)) {
        Get-RequiredProperty -Object $evidenceSnapshotObject -Name $fieldName -Context "Continuity operator packet.evidence_snapshot" | Out-Null
        if ($evidenceSnapshotObject.$fieldName -ne $reviewSummaryDocument.evidence_snapshot.$fieldName) {
            throw "Continuity operator packet.evidence_snapshot.$fieldName must match the referenced review summary."
        }
    }

    Assert-AllowedValue -Value $evidenceSnapshotObject.ledger_continuity_state -AllowedValues @($foundation.allowed_ledger_continuity_states) -Context "Continuity operator packet.evidence_snapshot.ledger_continuity_state"
    Assert-AllowedValue -Value $evidenceSnapshotObject.rollback_plan_execution_state -AllowedValues @($foundation.allowed_rollback_execution_states) -Context "Continuity operator packet.evidence_snapshot.rollback_plan_execution_state"
    Assert-AllowedValue -Value $evidenceSnapshotObject.rollback_target_scope -AllowedValues @($foundation.allowed_rollback_target_scopes) -Context "Continuity operator packet.evidence_snapshot.rollback_target_scope"
    Assert-AllowedValue -Value $evidenceSnapshotObject.rollback_environment_scope -AllowedValues @($foundation.allowed_rollback_environment_scopes) -Context "Continuity operator packet.evidence_snapshot.rollback_environment_scope"
    Assert-AllowedValue -Value $evidenceSnapshotObject.rollback_drill_execution_state -AllowedValues @($foundation.allowed_rollback_drill_execution_states) -Context "Continuity operator packet.evidence_snapshot.rollback_drill_execution_state"
    Assert-AllowedValue -Value $evidenceSnapshotObject.rollback_drill_environment_scope -AllowedValues @($foundation.allowed_rollback_drill_environment_scopes) -Context "Continuity operator packet.evidence_snapshot.rollback_drill_environment_scope"
    Assert-AllowedValue -Value $evidenceSnapshotObject.rollback_drill_action -AllowedValues @($foundation.allowed_rollback_drill_actions) -Context "Continuity operator packet.evidence_snapshot.rollback_drill_action"

    $evidenceQualitySummary = Assert-SafeAdvisoryText -Value (Get-RequiredProperty -Object $OperatorPacket -Name "evidence_quality_summary" -Context "Continuity operator packet") -Context "Continuity operator packet.evidence_quality_summary" -ProhibitedFragments @($contract.prohibited_claim_fragments)
    if ($evidenceQualitySummary -ne $reviewSummaryDocument.evidence_quality_summary) {
        throw "Continuity operator packet.evidence_quality_summary must match the referenced review summary."
    }

    $scopeLimitations = Validate-ExactStringSet -Items (Get-RequiredProperty -Object $OperatorPacket -Name "scope_limitations" -Context "Continuity operator packet") -Context "Continuity operator packet.scope_limitations" -ExpectedValues @($foundation.allowed_review_scope_limitations)
    if ((@($scopeLimitations | Sort-Object -Unique) -join "|") -ne (@($reviewSummaryDocument.scope_limitations | Sort-Object -Unique) -join "|")) {
        throw "Continuity operator packet.scope_limitations must match the referenced review summary."
    }

    $recommendation = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $OperatorPacket -Name "recommendation" -Context "Continuity operator packet") -Context "Continuity operator packet.recommendation"
    Assert-AllowedValue -Value $recommendation -AllowedValues @($foundation.allowed_review_recommendations) -Context "Continuity operator packet.recommendation"
    if ($recommendation -ne $reviewSummaryValidation.Recommendation) {
        throw "Continuity operator packet.recommendation must match the referenced review summary."
    }

    $recommendationIsAdvisory = Assert-BooleanValue -Value (Get-RequiredProperty -Object $OperatorPacket -Name "recommendation_is_advisory" -Context "Continuity operator packet") -Context "Continuity operator packet.recommendation_is_advisory"
    if (-not $recommendationIsAdvisory -or -not $reviewSummaryValidation.RecommendationIsAdvisory) {
        throw "Continuity operator packet.recommendation_is_advisory must remain true."
    }

    $manualOperatorDecisionRequired = Assert-BooleanValue -Value (Get-RequiredProperty -Object $OperatorPacket -Name "manual_operator_decision_required" -Context "Continuity operator packet") -Context "Continuity operator packet.manual_operator_decision_required"
    if (-not $manualOperatorDecisionRequired) {
        throw "Continuity operator packet.manual_operator_decision_required must remain true."
    }

    $operatorOptions = Validate-ExactStringSet -Items (Get-RequiredProperty -Object $OperatorPacket -Name "operator_options" -Context "Continuity operator packet") -Context "Continuity operator packet.operator_options" -ExpectedValues @($foundation.allowed_operator_packet_options)
    $automaticExecutionImplied = Assert-BooleanValue -Value (Get-RequiredProperty -Object $OperatorPacket -Name "automatic_execution_implied" -Context "Continuity operator packet") -Context "Continuity operator packet.automatic_execution_implied"
    if ($automaticExecutionImplied) {
        throw "Continuity operator packet.automatic_execution_implied must remain false."
    }

    $destructivePrimaryWorktreeRollbackImplied = Assert-BooleanValue -Value (Get-RequiredProperty -Object $OperatorPacket -Name "destructive_primary_worktree_rollback_implied" -Context "Continuity operator packet") -Context "Continuity operator packet.destructive_primary_worktree_rollback_implied"
    if ($destructivePrimaryWorktreeRollbackImplied) {
        throw "Continuity operator packet.destructive_primary_worktree_rollback_implied must remain false."
    }

    $nonClaims = Validate-ExactStringSet -Items (Get-RequiredProperty -Object $OperatorPacket -Name "non_claims" -Context "Continuity operator packet") -Context "Continuity operator packet.non_claims" -ExpectedValues @($foundation.allowed_review_non_claims)
    if ((@($nonClaims | Sort-Object -Unique) -join "|") -ne (@($reviewSummaryDocument.non_claims | Sort-Object -Unique) -join "|")) {
        throw "Continuity operator packet.non_claims must match the referenced review summary."
    }

    $notes = Assert-SafeAdvisoryText -Value (Get-RequiredProperty -Object $OperatorPacket -Name "notes" -Context "Continuity operator packet") -Context "Continuity operator packet.notes" -ProhibitedFragments @($contract.prohibited_claim_fragments)

    return [pscustomobject]@{
        IsValid = $true
        OperatorPacketId = $operatorPacketId
        OperatorPacketPath = $OperatorPacketPath
        ReviewSummaryId = $reviewSummaryValidation.ReviewSummaryId
        CycleId = $cycleContext.CycleId
        MilestoneId = $cycleContext.MilestoneId
        RepositoryName = $repositoryName
        Recommendation = $recommendation
        RecommendationIsAdvisory = $recommendationIsAdvisory
        ManualOperatorDecisionRequired = $manualOperatorDecisionRequired
        OperatorOptions = $operatorOptions
        NonClaims = $nonClaims
        SourceLabel = $SourceLabel
        Notes = $notes
    }
}

function Test-MilestoneContinuityOperatorPacketContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$OperatorPacketPath
    )

    $resolvedOperatorPacketPath = Resolve-ArtifactPath -ArtifactPath $OperatorPacketPath
    $operatorPacket = Get-JsonDocument -Path $resolvedOperatorPacketPath -Label "Continuity operator packet"
    return (Test-MilestoneContinuityOperatorPacketDocument -OperatorPacket $operatorPacket -SourceLabel $resolvedOperatorPacketPath -OperatorPacketPath $resolvedOperatorPacketPath)
}

function Test-MilestoneContinuityOperatorPacketObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $OperatorPacket,
        [string]$SourceLabel = "in-memory continuity operator packet"
    )

    return (Test-MilestoneContinuityOperatorPacketDocument -OperatorPacket $OperatorPacket -SourceLabel $SourceLabel -OperatorPacketPath $null)
}

function Invoke-MilestoneContinuityAdvisoryReviewFlow {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ContinuityLedgerPath,
        [Parameter(Mandatory = $true)]
        [string]$RollbackPlanPath,
        [Parameter(Mandatory = $true)]
        [string]$RollbackDrillResultPath,
        [Parameter(Mandatory = $true)]
        [string]$OutputRoot,
        [string]$ReviewSummaryId = "review-summary-r7-008-001",
        [string]$OperatorPacketId = "operator-packet-r7-008-001",
        [datetime]$ReviewedAt = (Get-Date).ToUniversalTime(),
        [string[]]$ScopeLimitations,
        [string[]]$NonClaims,
        [string]$EvidenceQualitySummary = (Get-DefaultEvidenceQualitySummary),
        [string]$ReviewNotes = (Get-DefaultSummaryNotes),
        [string]$OperatorPacketNotes = (Get-DefaultOperatorPacketNotes)
    )

    $foundation = Get-MilestoneContinuityFoundationContract
    $reviewSummaryContract = Get-MilestoneContinuityReviewSummaryContract

    Assert-RegexMatch -Value (Assert-NonEmptyString -Value $ReviewSummaryId -Context "ReviewSummaryId") -Pattern $foundation.identifier_pattern -Context "ReviewSummaryId"
    Assert-RegexMatch -Value (Assert-NonEmptyString -Value $OperatorPacketId -Context "OperatorPacketId") -Pattern $foundation.identifier_pattern -Context "OperatorPacketId"
    Assert-NonEmptyString -Value $EvidenceQualitySummary -Context "EvidenceQualitySummary" | Out-Null
    Assert-NonEmptyString -Value $ReviewNotes -Context "ReviewNotes" | Out-Null
    Assert-NonEmptyString -Value $OperatorPacketNotes -Context "OperatorPacketNotes" | Out-Null

    $resolvedOutputRoot = Resolve-OutputPath -OutputPath $OutputRoot
    $summaryDirectory = Join-Path $resolvedOutputRoot "review_summaries"
    $packetDirectory = Join-Path $resolvedOutputRoot "operator_packets"
    New-Item -ItemType Directory -Path $summaryDirectory -Force | Out-Null
    New-Item -ItemType Directory -Path $packetDirectory -Force | Out-Null

    $reviewSummaryPath = Join-Path $summaryDirectory ("{0}.json" -f $ReviewSummaryId)
    $operatorPacketPath = Join-Path $packetDirectory ("{0}.json" -f $OperatorPacketId)
    if (Test-Path -LiteralPath $reviewSummaryPath) {
        throw "Review summary id '$ReviewSummaryId' already exists."
    }
    if (Test-Path -LiteralPath $operatorPacketPath) {
        throw "Operator packet id '$OperatorPacketId' already exists."
    }

    $ledgerValidation = & $testMilestoneContinuityLedgerContract -LedgerPath $ContinuityLedgerPath
    $ledger = & $getMilestoneContinuityLedger -LedgerPath $ContinuityLedgerPath
    $rollbackPlanValidation = & $testMilestoneRollbackPlanContract -RollbackPlanPath $RollbackPlanPath
    $rollbackPlan = & $getMilestoneRollbackPlan -RollbackPlanPath $RollbackPlanPath
    $rollbackDrillValidation = & $testMilestoneRollbackDrillResultContract -DrillResultPath $RollbackDrillResultPath
    $rollbackDrill = & $getMilestoneRollbackDrillResult -DrillResultPath $RollbackDrillResultPath

    if ($ledgerValidation.CycleId -ne $rollbackPlanValidation.CycleId -or $ledgerValidation.CycleId -ne $rollbackDrillValidation.CycleId) {
        throw "Advisory continuity review requires cycle alignment across continuity ledger, rollback plan, and rollback drill result."
    }
    if ($ledgerValidation.MilestoneId -ne $rollbackPlanValidation.MilestoneId -or $ledgerValidation.MilestoneId -ne $rollbackDrillValidation.MilestoneId) {
        throw "Advisory continuity review requires milestone alignment across continuity ledger, rollback plan, and rollback drill result."
    }
    if ($ledgerValidation.TaskId -ne $rollbackPlanValidation.TaskId -or $ledgerValidation.TaskId -ne $rollbackDrillValidation.TaskId) {
        throw "Advisory continuity review requires task lineage alignment across continuity ledger, rollback plan, and rollback drill result."
    }
    if ($ledgerValidation.InterruptedSegmentId -ne $rollbackPlanValidation.InterruptedSegmentId -or $ledgerValidation.InterruptedSegmentId -ne $rollbackDrillValidation.InterruptedSegmentId) {
        throw "Advisory continuity review requires interrupted-segment lineage alignment across continuity ledger, rollback plan, and rollback drill result."
    }
    if ($ledgerValidation.SuccessorSegmentId -ne $rollbackPlanValidation.SuccessorSegmentId -or $ledgerValidation.SuccessorSegmentId -ne $rollbackDrillValidation.SuccessorSegmentId) {
        throw "Advisory continuity review requires successor-segment lineage alignment across continuity ledger, rollback plan, and rollback drill result."
    }
    if ($ledgerValidation.RepositoryName -ne $rollbackPlanValidation.RepositoryName -or $ledger.repository.repository_name -ne $rollbackDrill.repository.repository_name) {
        throw "Advisory continuity review requires repository alignment across continuity ledger, rollback plan, and rollback drill result."
    }
    if ($ledgerValidation.OperatorAuthority -ne $rollbackPlanValidation.OperatorAuthority -or $ledgerValidation.OperatorAuthority -ne $rollbackDrillValidation.OperatorAuthority) {
        throw "Advisory continuity review requires supervision alignment across continuity ledger, rollback plan, and rollback drill result."
    }

    $resolvedScopeLimitations = if ($PSBoundParameters.ContainsKey("ScopeLimitations")) {
        @(Validate-ExactStringSet -Items $ScopeLimitations -Context "ScopeLimitations" -ExpectedValues @($foundation.allowed_review_scope_limitations))
    }
    else {
        @($foundation.allowed_review_scope_limitations)
    }

    $resolvedNonClaims = if ($PSBoundParameters.ContainsKey("NonClaims")) {
        @(Validate-ExactStringSet -Items $NonClaims -Context "NonClaims" -ExpectedValues @($foundation.allowed_review_non_claims))
    }
    else {
        @($foundation.allowed_review_non_claims)
    }

    $summary = [pscustomobject]@{
        contract_version = $foundation.contract_version
        record_type = $foundation.review_summary_record_type
        review_summary_id = $ReviewSummaryId
        reviewed_at = $ReviewedAt.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        cycle_context = $ledger.cycle_context
        repository = $ledger.repository
        evidence_refs = [pscustomobject]@{
            continuity_ledger_ref = [pscustomobject]@{
                record_type = $foundation.ledger_record_type
                ledger_id = $ledgerValidation.LedgerId
                ledger_path = Get-RelativeReference -BaseDirectory $summaryDirectory -TargetPath $ledgerValidation.LedgerPath
            }
            rollback_plan_ref = [pscustomobject]@{
                record_type = $foundation.rollback_plan_record_type
                rollback_plan_id = $rollbackPlanValidation.RollbackPlanId
                rollback_plan_path = Get-RelativeReference -BaseDirectory $summaryDirectory -TargetPath $rollbackPlanValidation.RollbackPlanPath
            }
            rollback_drill_result_ref = [pscustomobject]@{
                record_type = $foundation.rollback_drill_result_record_type
                rollback_drill_id = $rollbackDrillValidation.RollbackDrillId
                drill_result_path = Get-RelativeReference -BaseDirectory $summaryDirectory -TargetPath $rollbackDrillValidation.DrillResultPath
            }
        }
        continuity_identity = [pscustomobject]@{
            task_id = $ledgerValidation.TaskId
            interrupted_segment_id = $ledgerValidation.InterruptedSegmentId
            successor_segment_id = $ledgerValidation.SuccessorSegmentId
        }
        continuity_git_context = $ledger.git_context
        rollback_target_git_context = [pscustomobject]@{
            branch = $rollbackPlan.rollback_target.branch
            head_commit = $rollbackPlan.rollback_target.head_commit
            tree_id = $rollbackPlan.rollback_target.tree_id
        }
        supervision = $ledger.supervision
        evidence_snapshot = [pscustomobject]@{
            ledger_continuity_state = $ledgerValidation.LedgerContinuityState
            rollback_plan_execution_state = $rollbackPlanValidation.ExecutionState
            rollback_target_scope = $rollbackPlan.rollback_target.target_scope
            rollback_environment_scope = $rollbackPlanValidation.AllowedEnvironmentScope
            rollback_drill_execution_state = $rollbackDrillValidation.ExecutionState
            rollback_drill_environment_scope = $rollbackDrillValidation.EnvironmentScope
            rollback_drill_action = $rollbackDrill.drill_action
        }
        evidence_quality_summary = $EvidenceQualitySummary
        scope_limitations = @($resolvedScopeLimitations)
        non_claims = @($resolvedNonClaims)
        recommendation = "advance_to_r7_009"
        recommendation_is_advisory = $true
        automatic_execution_implied = $false
        destructive_primary_worktree_rollback_implied = $false
        notes = $ReviewNotes
    }

    $savedReviewSummaryPath = Write-JsonDocument -Document $summary -OutputPath $reviewSummaryPath
    $reviewSummaryValidation = Test-MilestoneContinuityReviewSummaryContract -ReviewSummaryPath $savedReviewSummaryPath

    $operatorPacket = [pscustomobject]@{
        contract_version = $foundation.contract_version
        record_type = $foundation.operator_packet_record_type
        operator_packet_id = $OperatorPacketId
        prepared_at = $ReviewedAt.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        cycle_context = $summary.cycle_context
        repository = $summary.repository
        review_summary_ref = [pscustomobject]@{
            record_type = $foundation.review_summary_record_type
            review_summary_id = $reviewSummaryValidation.ReviewSummaryId
            review_summary_path = Get-RelativeReference -BaseDirectory $packetDirectory -TargetPath $reviewSummaryValidation.ReviewSummaryPath
        }
        review_summary_id = $reviewSummaryValidation.ReviewSummaryId
        continuity_identity = [pscustomobject]@{
            task_id = $ledgerValidation.TaskId
            interrupted_segment_id = $ledgerValidation.InterruptedSegmentId
            successor_segment_id = $ledgerValidation.SuccessorSegmentId
            rollback_plan_id = $rollbackPlanValidation.RollbackPlanId
            rollback_drill_id = $rollbackDrillValidation.RollbackDrillId
        }
        supervision = $summary.supervision
        evidence_snapshot = $summary.evidence_snapshot
        evidence_quality_summary = $summary.evidence_quality_summary
        scope_limitations = $summary.scope_limitations
        recommendation = $summary.recommendation
        recommendation_is_advisory = $true
        manual_operator_decision_required = $true
        operator_options = @($foundation.allowed_operator_packet_options)
        automatic_execution_implied = $false
        destructive_primary_worktree_rollback_implied = $false
        non_claims = $summary.non_claims
        notes = $OperatorPacketNotes
    }

    $savedOperatorPacketPath = Write-JsonDocument -Document $operatorPacket -OutputPath $operatorPacketPath
    $operatorPacketValidation = Test-MilestoneContinuityOperatorPacketContract -OperatorPacketPath $savedOperatorPacketPath

    return [pscustomobject]@{
        ReviewSummaryValidation = $reviewSummaryValidation
        OperatorPacketValidation = $operatorPacketValidation
        ReviewSummaryPath = $reviewSummaryValidation.ReviewSummaryPath
        OperatorPacketPath = $operatorPacketValidation.OperatorPacketPath
        ReviewSummaryId = $reviewSummaryValidation.ReviewSummaryId
        OperatorPacketId = $operatorPacketValidation.OperatorPacketId
        CycleId = $reviewSummaryValidation.CycleId
        Recommendation = $reviewSummaryValidation.Recommendation
        SourceArtifacts = [pscustomobject]@{
            LedgerId = $ledgerValidation.LedgerId
            RollbackPlanId = $rollbackPlanValidation.RollbackPlanId
            RollbackDrillId = $rollbackDrillValidation.RollbackDrillId
        }
    }
}

Export-ModuleMember -Function Test-MilestoneContinuityReviewSummaryContract, Test-MilestoneContinuityReviewSummaryObject, Get-MilestoneContinuityReviewSummary, Test-MilestoneContinuityOperatorPacketContract, Test-MilestoneContinuityOperatorPacketObject, Invoke-MilestoneContinuityAdvisoryReviewFlow
