Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$milestoneProposalModulePath = Join-Path $PSScriptRoot "MilestoneAutocycleProposal.psm1"
$milestoneFreezeModulePath = Join-Path $PSScriptRoot "MilestoneAutocycleFreeze.psm1"
$milestoneBaselineModulePath = Join-Path $PSScriptRoot "MilestoneBaseline.psm1"
$milestoneDispatchModulePath = Join-Path $PSScriptRoot "MilestoneAutocycleDispatch.psm1"
$milestoneExecutionEvidenceModulePath = Join-Path $PSScriptRoot "MilestoneAutocycleExecutionEvidence.psm1"
$milestoneQAModulePath = Join-Path $PSScriptRoot "MilestoneAutocycleQA.psm1"
$milestoneSummaryModulePath = Join-Path $PSScriptRoot "MilestoneAutocycleSummary.psm1"
$script:testMilestoneAutocycleProposalContract = $null
$script:testMilestoneAutocycleApprovalContract = $null
$script:testMilestoneAutocycleFreezeContract = $null
$script:testMilestoneAutocycleBaselineBindingContract = $null
$script:testMilestoneAutocycleDispatchContract = $null
$script:testMilestoneAutocycleRunLedgerContract = $null
$script:testMilestoneAutocycleExecutionEvidenceContract = $null
$script:testMilestoneAutocycleQAObservationContract = $null
$script:testMilestoneAutocycleQAAggregationContract = $null
$script:testMilestoneAutocycleSummaryContract = $null
$script:testMilestoneAutocycleDecisionPacketContract = $null

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

    Assert-NonEmptyString -Value $PathValue -Context "Path value" | Out-Null

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

function Test-PathWithinRoot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Root
    )

    $normalizedPath = [System.IO.Path]::GetFullPath($Path).TrimEnd("\/")
    $normalizedRoot = [System.IO.Path]::GetFullPath($Root).TrimEnd("\/")
    if ($normalizedPath.Equals($normalizedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $true
    }

    $rootPrefix = "{0}{1}" -f $normalizedRoot, [System.IO.Path]::DirectorySeparatorChar
    return $normalizedPath.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)
}

function Resolve-PathForCreationInsideRepository {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $resolvedPath = Resolve-PathValue -PathValue $PathValue -AnchorPath $RepositoryRoot
    $resolvedRepositoryRoot = Resolve-ExistingPath -PathValue $RepositoryRoot -Label "Repository root"
    if (-not (Test-PathWithinRoot -Path $resolvedPath -Root $resolvedRepositoryRoot)) {
        throw "$Label '$resolvedPath' must resolve inside repository root '$resolvedRepositoryRoot'."
    }

    return $resolvedPath
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
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Document
    )

    $json = $Document | ConvertTo-Json -Depth 25
    Set-Content -LiteralPath $Path -Value $json -Encoding UTF8
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
        $candidate = $Reference
    }
    else {
        $candidate = Join-Path $BaseDirectory ($Reference -replace "[/\\]", [System.IO.Path]::DirectorySeparatorChar)
    }

    if (-not (Test-Path -LiteralPath $candidate)) {
        throw "$Label reference '$Reference' does not exist."
    }

    return (Resolve-Path -LiteralPath $candidate).Path
}

function Get-RelativeReference {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory,
        [Parameter(Mandatory = $true)]
        [string]$TargetPath
    )

    $resolvedBaseDirectory = Resolve-ExistingPath -PathValue $BaseDirectory -Label "Base directory"
    $resolvedTargetPath = Resolve-ExistingPath -PathValue $TargetPath -Label "Target path"
    $baseUri = [System.Uri]("{0}{1}" -f $resolvedBaseDirectory.TrimEnd("\/"), [System.IO.Path]::DirectorySeparatorChar)
    $targetUri = [System.Uri]$resolvedTargetPath
    return ($baseUri.MakeRelativeUri($targetUri).OriginalString).Replace("\", "/")
}

function Get-GitCommand {
    $command = Get-Command git -ErrorAction SilentlyContinue
    if ($null -eq $command) {
        throw "Milestone closeout requires Git CLI to be installed and callable."
    }

    return $command
}

function Get-GitBranchName {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    Get-GitCommand | Out-Null
    $branch = (& git -C $RepositoryRoot branch --show-current 2>$null).Trim()
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($branch)) {
        throw "Unable to resolve the current Git branch for milestone closeout."
    }

    return $branch
}

function Get-GitHeadCommit {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    Get-GitCommand | Out-Null
    $head = (& git -C $RepositoryRoot rev-parse HEAD 2>$null).Trim()
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($head)) {
        throw "Unable to resolve the current Git HEAD commit for milestone closeout."
    }

    return $head
}

function Get-MilestoneAutocycleFoundationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_autocycle\foundation.contract.json") -Label "Milestone autocycle foundation contract"
}

function Get-MilestoneAutocycleReplayProofContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_autocycle\replay_proof.contract.json") -Label "Milestone replay proof contract"
}

function Get-MilestoneAutocycleCloseoutPacketContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_autocycle\closeout_packet.contract.json") -Label "Milestone closeout packet contract"
}

function Get-RequiredDependencyCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ModulePath,
        [Parameter(Mandatory = $true)]
        [string]$DependencyLabel,
        [Parameter(Mandatory = $true)]
        [string]$CommandName
    )

    if (-not (Test-Path -LiteralPath $ModulePath)) {
        throw "Milestone closeout requires dependency module '$DependencyLabel' at '$ModulePath'."
    }

    try {
        $module = Import-Module $ModulePath -Force -PassThru -ErrorAction Stop
    }
    catch {
        throw "Milestone closeout requires dependency module '$DependencyLabel' to load successfully. $($_.Exception.Message)"
    }

    $command = $module.ExportedCommands[$CommandName]
    if ($null -eq $command) {
        throw "Milestone closeout requires dependency command '$CommandName' from dependency module '$DependencyLabel'."
    }

    return $command
}

function Get-MilestoneAutocycleProposalValidatorCommand {
    if ($null -eq $script:testMilestoneAutocycleProposalContract) {
        $script:testMilestoneAutocycleProposalContract = Get-RequiredDependencyCommand -ModulePath $milestoneProposalModulePath -DependencyLabel "MilestoneAutocycleProposal" -CommandName "Test-MilestoneAutocycleProposalContract"
    }

    return $script:testMilestoneAutocycleProposalContract
}

function Get-MilestoneAutocycleApprovalValidatorCommand {
    if ($null -eq $script:testMilestoneAutocycleApprovalContract) {
        $script:testMilestoneAutocycleApprovalContract = Get-RequiredDependencyCommand -ModulePath $milestoneFreezeModulePath -DependencyLabel "MilestoneAutocycleFreeze" -CommandName "Test-MilestoneAutocycleApprovalContract"
    }

    return $script:testMilestoneAutocycleApprovalContract
}

function Get-MilestoneAutocycleFreezeValidatorCommand {
    if ($null -eq $script:testMilestoneAutocycleFreezeContract) {
        $script:testMilestoneAutocycleFreezeContract = Get-RequiredDependencyCommand -ModulePath $milestoneFreezeModulePath -DependencyLabel "MilestoneAutocycleFreeze" -CommandName "Test-MilestoneAutocycleFreezeContract"
    }

    return $script:testMilestoneAutocycleFreezeContract
}

function Get-MilestoneAutocycleBaselineBindingValidatorCommand {
    if ($null -eq $script:testMilestoneAutocycleBaselineBindingContract) {
        $script:testMilestoneAutocycleBaselineBindingContract = Get-RequiredDependencyCommand -ModulePath $milestoneBaselineModulePath -DependencyLabel "MilestoneBaseline" -CommandName "Test-MilestoneAutocycleBaselineBindingContract"
    }

    return $script:testMilestoneAutocycleBaselineBindingContract
}

function Get-MilestoneAutocycleDispatchValidatorCommand {
    if ($null -eq $script:testMilestoneAutocycleDispatchContract) {
        $script:testMilestoneAutocycleDispatchContract = Get-RequiredDependencyCommand -ModulePath $milestoneDispatchModulePath -DependencyLabel "MilestoneAutocycleDispatch" -CommandName "Test-MilestoneAutocycleDispatchContract"
    }

    return $script:testMilestoneAutocycleDispatchContract
}

function Get-MilestoneAutocycleRunLedgerValidatorCommand {
    if ($null -eq $script:testMilestoneAutocycleRunLedgerContract) {
        $script:testMilestoneAutocycleRunLedgerContract = Get-RequiredDependencyCommand -ModulePath $milestoneDispatchModulePath -DependencyLabel "MilestoneAutocycleDispatch" -CommandName "Test-MilestoneAutocycleRunLedgerContract"
    }

    return $script:testMilestoneAutocycleRunLedgerContract
}

function Get-MilestoneAutocycleExecutionEvidenceValidatorCommand {
    if ($null -eq $script:testMilestoneAutocycleExecutionEvidenceContract) {
        $script:testMilestoneAutocycleExecutionEvidenceContract = Get-RequiredDependencyCommand -ModulePath $milestoneExecutionEvidenceModulePath -DependencyLabel "MilestoneAutocycleExecutionEvidence" -CommandName "Test-MilestoneAutocycleExecutionEvidenceContract"
    }

    return $script:testMilestoneAutocycleExecutionEvidenceContract
}

function Get-MilestoneAutocycleQAObservationValidatorCommand {
    if ($null -eq $script:testMilestoneAutocycleQAObservationContract) {
        $script:testMilestoneAutocycleQAObservationContract = Get-RequiredDependencyCommand -ModulePath $milestoneQAModulePath -DependencyLabel "MilestoneAutocycleQA" -CommandName "Test-MilestoneAutocycleQAObservationContract"
    }

    return $script:testMilestoneAutocycleQAObservationContract
}

function Get-MilestoneAutocycleQAAggregationValidatorCommand {
    if ($null -eq $script:testMilestoneAutocycleQAAggregationContract) {
        $script:testMilestoneAutocycleQAAggregationContract = Get-RequiredDependencyCommand -ModulePath $milestoneQAModulePath -DependencyLabel "MilestoneAutocycleQA" -CommandName "Test-MilestoneAutocycleQAAggregationContract"
    }

    return $script:testMilestoneAutocycleQAAggregationContract
}

function Get-MilestoneAutocycleSummaryValidatorCommand {
    if ($null -eq $script:testMilestoneAutocycleSummaryContract) {
        $script:testMilestoneAutocycleSummaryContract = Get-RequiredDependencyCommand -ModulePath $milestoneSummaryModulePath -DependencyLabel "MilestoneAutocycleSummary" -CommandName "Test-MilestoneAutocycleSummaryContract"
    }

    return $script:testMilestoneAutocycleSummaryContract
}

function Get-MilestoneAutocycleDecisionPacketValidatorCommand {
    if ($null -eq $script:testMilestoneAutocycleDecisionPacketContract) {
        $script:testMilestoneAutocycleDecisionPacketContract = Get-RequiredDependencyCommand -ModulePath $milestoneSummaryModulePath -DependencyLabel "MilestoneAutocycleSummary" -CommandName "Test-MilestoneAutocycleDecisionPacketContract"
    }

    return $script:testMilestoneAutocycleDecisionPacketContract
}

function Get-UniqueValues {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Values
    )

    $items = @($Values | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) } | Sort-Object -Unique)
    Write-Output -NoEnumerate $items
}

function Assert-PathSetMatches {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$ActualPaths,
        [Parameter(Mandatory = $true)]
        [string[]]$ExpectedPaths,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $actualSet = @($ActualPaths | Sort-Object -Unique)
    $expectedSet = @($ExpectedPaths | Sort-Object -Unique)
    if ($actualSet.Count -ne $expectedSet.Count) {
        throw "$Context must match the authoritative replay path set."
    }

    foreach ($expectedPath in $expectedSet) {
        if ($actualSet -notcontains $expectedPath) {
            throw "$Context must match the authoritative replay path set."
        }
    }
}

function Get-DefaultCloseoutNonClaims {
    return @(
        "No operator decision was executed; the decision packet remains advisory only.",
        "This closeout path does not prove broader autonomy.",
        "This closeout path does not prove rollback execution.",
        "This closeout path does not prove unattended automatic resume.",
        "This closeout path does not prove UI or Standard runtime productization.",
        "This closeout path does not prove multi-repo behavior, swarms, or broader orchestration."
    )
}

function Validate-NonClaims {
    param(
        [AllowNull()]
        $NonClaims,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [Parameter(Mandatory = $true)]
        [string[]]$RequiredFragments
    )

    $items = [object[]](Assert-StringArray -Value $NonClaims -Context $Context)
    $normalizedItems = @()
    foreach ($item in $items) {
        $normalizedItems += (Assert-NonEmptyString -Value $item -Context "$Context item")
    }

    foreach ($requiredFragment in @($RequiredFragments)) {
        $matchingClaim = @($normalizedItems | Where-Object {
                $_.IndexOf($requiredFragment, [System.StringComparison]::OrdinalIgnoreCase) -ge 0
            })
        if ($matchingClaim.Count -eq 0) {
            throw "$Context must explicitly cover '$requiredFragment'."
        }
    }

    Write-Output -NoEnumerate $normalizedItems
}

function Assert-NoForbiddenClaims {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [Parameter(Mandatory = $true)]
        [string[]]$Fragments
    )

    $normalizedValue = Assert-NonEmptyString -Value $Value -Context $Context
    foreach ($fragment in @($Fragments)) {
        if ($normalizedValue.IndexOf($fragment, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
            throw "$Context must not claim '$fragment'."
        }
    }

    return $normalizedValue
}

function Resolve-SummaryPilotInputs {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SummaryPath,
        [Parameter(Mandatory = $true)]
        [string]$DecisionPacketPath
    )

    $summaryValidator = Get-MilestoneAutocycleSummaryValidatorCommand
    $decisionPacketValidator = Get-MilestoneAutocycleDecisionPacketValidatorCommand
    $qaAggregationValidator = Get-MilestoneAutocycleQAAggregationValidatorCommand
    $qaObservationValidator = Get-MilestoneAutocycleQAObservationValidatorCommand
    $executionEvidenceValidator = Get-MilestoneAutocycleExecutionEvidenceValidatorCommand
    $dispatchValidator = Get-MilestoneAutocycleDispatchValidatorCommand
    $runLedgerValidator = Get-MilestoneAutocycleRunLedgerValidatorCommand
    $bindingValidator = Get-MilestoneAutocycleBaselineBindingValidatorCommand
    $freezeValidator = Get-MilestoneAutocycleFreezeValidatorCommand

    $summaryValidation = & $summaryValidator -SummaryPath $SummaryPath
    $decisionPacketValidation = & $decisionPacketValidator -DecisionPacketPath $DecisionPacketPath
    if ($summaryValidation.CycleId -ne $decisionPacketValidation.CycleId) {
        throw "Milestone closeout requires summary and decision packet cycle_id values to match."
    }
    if (-not $decisionPacketValidation.RecommendationIsAdvisory) {
        throw "Milestone closeout requires the referenced decision packet recommendation to remain advisory only."
    }

    $summary = Get-JsonDocument -Path $summaryValidation.SummaryPath -Label "Milestone closeout summary"
    $qaAggregationValidation = & $qaAggregationValidator -QAAggregationPath $summaryValidation.QAAggregationPath
    $qaAggregation = Get-JsonDocument -Path $qaAggregationValidation.QAAggregationPath -Label "Milestone closeout QA aggregation"
    $qaAggregationDirectory = Split-Path -Parent $qaAggregationValidation.QAAggregationPath

    $taskInputs = @()
    foreach ($taskResult in @($qaAggregation.task_results)) {
        $qaObservationPath = Resolve-ReferenceAgainstBase -BaseDirectory $qaAggregationDirectory -Reference (Assert-NonEmptyString -Value $taskResult.qa_observation_ref -Context "Milestone closeout QA aggregation.task_results item.qa_observation_ref") -Label "Milestone closeout QA observation"
        $qaObservationValidation = & $qaObservationValidator -QAObservationPath $qaObservationPath
        $qaObservation = Get-JsonDocument -Path $qaObservationValidation.QAObservationPath -Label "Milestone closeout QA observation"
        $qaObservationDirectory = Split-Path -Parent $qaObservationValidation.QAObservationPath

        $executionEvidencePath = Resolve-ReferenceAgainstBase -BaseDirectory $qaObservationDirectory -Reference (Assert-NonEmptyString -Value $qaObservation.execution_evidence_ref -Context "Milestone closeout QA observation.execution_evidence_ref") -Label "Milestone closeout execution evidence"
        $executionEvidenceValidation = & $executionEvidenceValidator -EvidenceBundlePath $executionEvidencePath
        $dispatchValidation = & $dispatchValidator -DispatchPath $executionEvidenceValidation.DispatchPath
        $runLedgerValidation = & $runLedgerValidator -LedgerPath $executionEvidenceValidation.LedgerPath
        $bindingValidation = & $bindingValidator -BindingPath $executionEvidenceValidation.BindingPath
        $freezeValidation = & $freezeValidator -FreezePath $bindingValidation.FreezePath

        $taskInputs += [pscustomobject]@{
            TaskId = $qaObservationValidation.TaskId
            DispatchId = $qaObservationValidation.DispatchId
            QAObservationValidation = $qaObservationValidation
            ExecutionEvidenceValidation = $executionEvidenceValidation
            DispatchValidation = $dispatchValidation
            RunLedgerValidation = $runLedgerValidation
            BindingValidation = $bindingValidation
            FreezeValidation = $freezeValidation
        }
    }

    if ($taskInputs.Count -eq 0) {
        throw "Milestone closeout requires at least one authoritative QA task result."
    }

    $bindingPaths = Get-UniqueValues -Values @($taskInputs | ForEach-Object { $_.BindingValidation.BindingPath })
    $freezePaths = Get-UniqueValues -Values @($taskInputs | ForEach-Object { $_.FreezeValidation.FreezePath })
    $proposalPaths = Get-UniqueValues -Values @($taskInputs | ForEach-Object { $_.FreezeValidation.ProposalPath })
    if ($bindingPaths.Count -ne 1 -or $freezePaths.Count -ne 1 -or $proposalPaths.Count -ne 1) {
        throw "Milestone closeout requires one authoritative proposal, freeze, and baseline binding for the bounded pilot cycle."
    }

    return [pscustomobject]@{
        SummaryValidation = $summaryValidation
        Summary = $summary
        DecisionPacketValidation = $decisionPacketValidation
        QAAggregationValidation = $qaAggregationValidation
        QAAggregation = $qaAggregation
        TaskInputs = $taskInputs
        ProposalPath = $proposalPaths[0]
        FreezePath = $freezePaths[0]
        BindingPath = $bindingPaths[0]
        RepositoryRoot = $taskInputs[0].ExecutionEvidenceValidation.RepositoryRoot
    }
}

function Validate-ReplayProofRefs {
    param(
        [AllowNull()]
        $ProofRefs,
        [Parameter(Mandatory = $true)]
        $SummaryPilotInputs,
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory
    )

    $contract = Get-MilestoneAutocycleReplayProofContract
    $approvalValidator = Get-MilestoneAutocycleApprovalValidatorCommand
    $proposalValidator = Get-MilestoneAutocycleProposalValidatorCommand
    $freezeValidator = Get-MilestoneAutocycleFreezeValidatorCommand
    $bindingValidator = Get-MilestoneAutocycleBaselineBindingValidatorCommand
    $dispatchValidator = Get-MilestoneAutocycleDispatchValidatorCommand
    $runLedgerValidator = Get-MilestoneAutocycleRunLedgerValidatorCommand
    $executionEvidenceValidator = Get-MilestoneAutocycleExecutionEvidenceValidatorCommand
    $qaObservationValidator = Get-MilestoneAutocycleQAObservationValidatorCommand
    $qaAggregationValidator = Get-MilestoneAutocycleQAAggregationValidatorCommand

    $proofRefsObject = Assert-ObjectValue -Value $ProofRefs -Context "Milestone replay proof.proof_refs"
    foreach ($fieldName in @($contract.proof_refs_required_fields)) {
        Get-RequiredProperty -Object $proofRefsObject -Name $fieldName -Context "Milestone replay proof.proof_refs" | Out-Null
    }

    $proposalPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $proofRefsObject -Name "proposal_ref" -Context "Milestone replay proof.proof_refs") -Context "Milestone replay proof.proof_refs.proposal_ref") -Label "Milestone replay proof proposal"
    $proposalValidation = & $proposalValidator -ProposalPath $proposalPath
    if ($proposalValidation.ProposalPath -ne $SummaryPilotInputs.ProposalPath) {
        throw "Milestone replay proof.proof_refs.proposal_ref must match the authoritative proposal from the summary path."
    }

    $approvalPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $proofRefsObject -Name "approval_ref" -Context "Milestone replay proof.proof_refs") -Context "Milestone replay proof.proof_refs.approval_ref") -Label "Milestone replay proof approval"
    $approvalValidation = & $approvalValidator -ApprovalPath $approvalPath
    if ($approvalValidation.CycleId -ne $SummaryPilotInputs.SummaryValidation.CycleId) {
        throw "Milestone replay proof.proof_refs.approval_ref must match the authoritative cycle_id."
    }
    if ($approvalValidation.Status -ne "approved") {
        throw "Milestone replay proof.proof_refs.approval_ref must reference an approved milestone approval."
    }
    if ($approvalValidation.ProposalPath -ne $SummaryPilotInputs.ProposalPath) {
        throw "Milestone replay proof.proof_refs.approval_ref must match the authoritative proposal from the summary path."
    }

    $freezePath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $proofRefsObject -Name "freeze_ref" -Context "Milestone replay proof.proof_refs") -Context "Milestone replay proof.proof_refs.freeze_ref") -Label "Milestone replay proof freeze"
    $freezeValidation = & $freezeValidator -FreezePath $freezePath
    if ($freezeValidation.FreezePath -ne $SummaryPilotInputs.FreezePath) {
        throw "Milestone replay proof.proof_refs.freeze_ref must match the authoritative freeze from the summary path."
    }

    $bindingPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $proofRefsObject -Name "baseline_binding_ref" -Context "Milestone replay proof.proof_refs") -Context "Milestone replay proof.proof_refs.baseline_binding_ref") -Label "Milestone replay proof baseline binding"
    $bindingValidation = & $bindingValidator -BindingPath $bindingPath
    if ($bindingValidation.BindingPath -ne $SummaryPilotInputs.BindingPath) {
        throw "Milestone replay proof.proof_refs.baseline_binding_ref must match the authoritative baseline binding from the summary path."
    }

    $dispatchRefs = [object[]](Assert-StringArray -Value (Get-RequiredProperty -Object $proofRefsObject -Name "dispatch_refs" -Context "Milestone replay proof.proof_refs") -Context "Milestone replay proof.proof_refs.dispatch_refs")
    $resolvedDispatchPaths = @()
    foreach ($dispatchRef in $dispatchRefs) {
        $dispatchPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference $dispatchRef -Label "Milestone replay proof dispatch"
        (& $dispatchValidator -DispatchPath $dispatchPath) | Out-Null
        $resolvedDispatchPaths += $dispatchPath
    }
    Assert-PathSetMatches -ActualPaths $resolvedDispatchPaths -ExpectedPaths @($SummaryPilotInputs.TaskInputs | ForEach-Object { $_.DispatchValidation.DispatchPath }) -Context "Milestone replay proof.proof_refs.dispatch_refs"

    $runLedgerRefs = [object[]](Assert-StringArray -Value (Get-RequiredProperty -Object $proofRefsObject -Name "run_ledger_refs" -Context "Milestone replay proof.proof_refs") -Context "Milestone replay proof.proof_refs.run_ledger_refs")
    $resolvedRunLedgerPaths = @()
    foreach ($runLedgerRef in $runLedgerRefs) {
        $runLedgerPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference $runLedgerRef -Label "Milestone replay proof run ledger"
        (& $runLedgerValidator -LedgerPath $runLedgerPath) | Out-Null
        $resolvedRunLedgerPaths += $runLedgerPath
    }
    Assert-PathSetMatches -ActualPaths $resolvedRunLedgerPaths -ExpectedPaths @($SummaryPilotInputs.TaskInputs | ForEach-Object { $_.RunLedgerValidation.LedgerPath }) -Context "Milestone replay proof.proof_refs.run_ledger_refs"

    $executionEvidenceRefs = [object[]](Assert-StringArray -Value (Get-RequiredProperty -Object $proofRefsObject -Name "execution_evidence_refs" -Context "Milestone replay proof.proof_refs") -Context "Milestone replay proof.proof_refs.execution_evidence_refs")
    $resolvedExecutionEvidencePaths = @()
    foreach ($executionEvidenceRef in $executionEvidenceRefs) {
        $executionEvidencePath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference $executionEvidenceRef -Label "Milestone replay proof execution evidence"
        (& $executionEvidenceValidator -EvidenceBundlePath $executionEvidencePath) | Out-Null
        $resolvedExecutionEvidencePaths += $executionEvidencePath
    }
    Assert-PathSetMatches -ActualPaths $resolvedExecutionEvidencePaths -ExpectedPaths @($SummaryPilotInputs.TaskInputs | ForEach-Object { $_.ExecutionEvidenceValidation.EvidenceBundlePath }) -Context "Milestone replay proof.proof_refs.execution_evidence_refs"

    $qaObservationRefs = [object[]](Assert-StringArray -Value (Get-RequiredProperty -Object $proofRefsObject -Name "qa_observation_refs" -Context "Milestone replay proof.proof_refs") -Context "Milestone replay proof.proof_refs.qa_observation_refs")
    $resolvedQAObservationPaths = @()
    foreach ($qaObservationRef in $qaObservationRefs) {
        $qaObservationPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference $qaObservationRef -Label "Milestone replay proof QA observation"
        (& $qaObservationValidator -QAObservationPath $qaObservationPath) | Out-Null
        $resolvedQAObservationPaths += $qaObservationPath
    }
    Assert-PathSetMatches -ActualPaths $resolvedQAObservationPaths -ExpectedPaths @($SummaryPilotInputs.TaskInputs | ForEach-Object { $_.QAObservationValidation.QAObservationPath }) -Context "Milestone replay proof.proof_refs.qa_observation_refs"

    $qaAggregationPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $proofRefsObject -Name "qa_aggregation_ref" -Context "Milestone replay proof.proof_refs") -Context "Milestone replay proof.proof_refs.qa_aggregation_ref") -Label "Milestone replay proof QA aggregation"
    (& $qaAggregationValidator -QAAggregationPath $qaAggregationPath) | Out-Null
    if ($qaAggregationPath -ne $SummaryPilotInputs.QAAggregationValidation.QAAggregationPath) {
        throw "Milestone replay proof.proof_refs.qa_aggregation_ref must match the authoritative QA aggregation from the summary path."
    }

    return [pscustomobject]@{
        ProposalPath = $proposalValidation.ProposalPath
        ApprovalPath = $approvalValidation.ApprovalPath
        FreezePath = $freezeValidation.FreezePath
        BindingPath = $bindingValidation.BindingPath
        DispatchPaths = @($resolvedDispatchPaths | Sort-Object -Unique)
        RunLedgerPaths = @($resolvedRunLedgerPaths | Sort-Object -Unique)
        ExecutionEvidencePaths = @($resolvedExecutionEvidencePaths | Sort-Object -Unique)
        QAObservationPaths = @($resolvedQAObservationPaths | Sort-Object -Unique)
        QAAggregationPath = $qaAggregationPath
    }
}

function Validate-ReplaySource {
    param(
        [AllowNull()]
        $ReplaySource,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $contract = Get-MilestoneAutocycleReplayProofContract
    $foundation = Get-MilestoneAutocycleFoundationContract
    $sourceObject = Assert-ObjectValue -Value $ReplaySource -Context $Context
    foreach ($fieldName in @($contract.replay_source_required_fields)) {
        Get-RequiredProperty -Object $sourceObject -Name $fieldName -Context $Context | Out-Null
    }

    $repositoryRoot = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $sourceObject -Name "repository_root" -Context $Context) -Context "$Context.repository_root"
    $branch = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $sourceObject -Name "branch" -Context $Context) -Context "$Context.branch"
    $headCommit = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $sourceObject -Name "head_commit" -Context $Context) -Context "$Context.head_commit"
    Assert-RegexMatch -Value $headCommit -Pattern "^[0-9a-f]{40}$" -Context "$Context.head_commit"
    Assert-RegexMatch -Value $branch -Pattern $foundation.identifier_pattern -Context "$Context.branch"

    return [pscustomobject]@{
        repository_root = $repositoryRoot
        branch = $branch
        head_commit = $headCommit
    }
}

function Get-DefaultReplayScope {
    return "One exact supervised pilot scenario from milestone proposal through advisory operator decision packet only."
}

function Get-DefaultReplayBoundaryStatement {
    return "This replay proof is bounded to the supervised milestone autocycle pilot for AIOffice_V2 only and does not execute operator choice."
}

function Get-DefaultCloseoutScope {
    return "This closeout packet covers the bounded supervised milestone autocycle pilot for AIOffice_V2 from governed proposal through advisory operator decision packet only."
}

function Get-DefaultProvedScope {
    return "Repo truth now proves the bounded supervised pilot path from proposal, approval and freeze, baseline binding, governed dispatch and run ledger, execution evidence, QA observation and aggregation, bounded summary, advisory operator decision packet, replay proof, and closeout packet assembly."
}

function Get-DefaultUnprovedScope {
    return "No explicit operator acceptance artifact is referenced here, so the pilot does not prove an executed operator choice beyond the advisory review surfaces."
}

function Get-DefaultOutOfScope {
    return "Broad autonomy, unattended automatic resume, rollback execution, UI, Standard runtime, multi-repo behavior, swarms, and broader orchestration remain out of scope."
}

function Validate-MilestoneReplayProofFields {
    param(
        [Parameter(Mandatory = $true)]
        $ReplayProof,
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory
    )

    $foundation = Get-MilestoneAutocycleFoundationContract
    $contract = Get-MilestoneAutocycleReplayProofContract

    foreach ($fieldName in @($foundation.replay_proof_required_fields)) {
        Get-RequiredProperty -Object $ReplayProof -Name $fieldName -Context "Milestone replay proof" | Out-Null
    }
    foreach ($fieldName in @($contract.required_fields)) {
        Get-RequiredProperty -Object $ReplayProof -Name $fieldName -Context "Milestone replay proof" | Out-Null
    }

    $replayProofId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ReplayProof -Name "replay_proof_id" -Context "Milestone replay proof") -Context "Milestone replay proof.replay_proof_id"
    $cycleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ReplayProof -Name "cycle_id" -Context "Milestone replay proof") -Context "Milestone replay proof.cycle_id"
    $summaryId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ReplayProof -Name "summary_id" -Context "Milestone replay proof") -Context "Milestone replay proof.summary_id"
    $decisionPacketId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ReplayProof -Name "decision_packet_id" -Context "Milestone replay proof") -Context "Milestone replay proof.decision_packet_id"

    foreach ($pair in @(
            @{ Value = $replayProofId; Context = "Milestone replay proof.replay_proof_id" },
            @{ Value = $cycleId; Context = "Milestone replay proof.cycle_id" },
            @{ Value = $summaryId; Context = "Milestone replay proof.summary_id" },
            @{ Value = $decisionPacketId; Context = "Milestone replay proof.decision_packet_id" }
        )) {
        Assert-RegexMatch -Value $pair.Value -Pattern $foundation.identifier_pattern -Context $pair.Context
    }

    $summaryPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ReplayProof -Name "summary_ref" -Context "Milestone replay proof") -Context "Milestone replay proof.summary_ref") -Label "Milestone replay proof summary"
    $decisionPacketPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ReplayProof -Name "decision_packet_ref" -Context "Milestone replay proof") -Context "Milestone replay proof.decision_packet_ref") -Label "Milestone replay proof decision packet"
    $summaryPilotInputs = Resolve-SummaryPilotInputs -SummaryPath $summaryPath -DecisionPacketPath $decisionPacketPath

    if ($cycleId -ne $summaryPilotInputs.SummaryValidation.CycleId) {
        throw "Milestone replay proof.cycle_id must match the referenced summary cycle_id."
    }
    if ($summaryId -ne $summaryPilotInputs.SummaryValidation.SummaryId) {
        throw "Milestone replay proof.summary_id must match the referenced summary id."
    }
    if ($decisionPacketId -ne $summaryPilotInputs.DecisionPacketValidation.DecisionPacketId) {
        throw "Milestone replay proof.decision_packet_id must match the referenced decision packet id."
    }

    $recommendation = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ReplayProof -Name "recommendation" -Context "Milestone replay proof") -Context "Milestone replay proof.recommendation"
    Assert-AllowedValue -Value $recommendation -AllowedValues @($foundation.allowed_summary_recommendations) -Context "Milestone replay proof.recommendation"
    if ($recommendation -ne $summaryPilotInputs.DecisionPacketValidation.Recommendation) {
        throw "Milestone replay proof.recommendation must match the referenced decision packet recommendation."
    }

    $operatorDecisionState = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ReplayProof -Name "operator_decision_state" -Context "Milestone replay proof") -Context "Milestone replay proof.operator_decision_state"
    Assert-AllowedValue -Value $operatorDecisionState -AllowedValues @($foundation.allowed_operator_decision_states) -Context "Milestone replay proof.operator_decision_state"
    if (-not $summaryPilotInputs.DecisionPacketValidation.RecommendationIsAdvisory) {
        throw "Milestone replay proof requires the referenced decision packet recommendation to remain advisory only."
    }

    $proofRefs = Validate-ReplayProofRefs -ProofRefs (Get-RequiredProperty -Object $ReplayProof -Name "proof_refs" -Context "Milestone replay proof") -SummaryPilotInputs $summaryPilotInputs -BaseDirectory $BaseDirectory
    $replayScope = Assert-NoForbiddenClaims -Value (Get-RequiredProperty -Object $ReplayProof -Name "replay_scope" -Context "Milestone replay proof") -Context "Milestone replay proof.replay_scope" -Fragments @($contract.prohibited_claim_fragments)
    $replaySource = Validate-ReplaySource -ReplaySource (Get-RequiredProperty -Object $ReplayProof -Name "replay_source" -Context "Milestone replay proof") -Context "Milestone replay proof.replay_source"
    $boundaryStatement = Assert-NoForbiddenClaims -Value (Get-RequiredProperty -Object $ReplayProof -Name "boundary_statement" -Context "Milestone replay proof") -Context "Milestone replay proof.boundary_statement" -Fragments @($contract.prohibited_claim_fragments)
    $nonClaims = [object[]](Validate-NonClaims -NonClaims (Get-RequiredProperty -Object $ReplayProof -Name "non_claims" -Context "Milestone replay proof") -Context "Milestone replay proof.non_claims" -RequiredFragments @($contract.required_non_claim_fragments))
    $notes = Assert-NoForbiddenClaims -Value (Get-RequiredProperty -Object $ReplayProof -Name "notes" -Context "Milestone replay proof") -Context "Milestone replay proof.notes" -Fragments @($contract.prohibited_claim_fragments)

    return [pscustomobject]@{
        ReplayProofId = $replayProofId
        CycleId = $cycleId
        SummaryId = $summaryId
        DecisionPacketId = $decisionPacketId
        SummaryPath = $summaryPilotInputs.SummaryValidation.SummaryPath
        DecisionPacketPath = $summaryPilotInputs.DecisionPacketValidation.DecisionPacketPath
        Recommendation = $recommendation
        OperatorDecisionState = $operatorDecisionState
        ProofRefs = $proofRefs
        ReplaySource = $replaySource
        ReplayScope = $replayScope
        BoundaryStatement = $boundaryStatement
        NonClaims = $nonClaims
        Notes = $notes
    }
}

function Test-MilestoneAutocycleReplayProofContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ReplayProofPath
    )

    $resolvedReplayProofPath = Resolve-ExistingPath -PathValue $ReplayProofPath -Label "Milestone replay proof"
    $replayProof = Get-JsonDocument -Path $resolvedReplayProofPath -Label "Milestone replay proof"
    $result = Validate-MilestoneReplayProofFields -ReplayProof $replayProof -BaseDirectory (Split-Path -Parent $resolvedReplayProofPath)

    return [pscustomobject]@{
        IsValid = $true
        ReplayProofId = $result.ReplayProofId
        CycleId = $result.CycleId
        SummaryId = $result.SummaryId
        DecisionPacketId = $result.DecisionPacketId
        Recommendation = $result.Recommendation
        OperatorDecisionState = $result.OperatorDecisionState
        ReplayProofPath = $resolvedReplayProofPath
        SummaryPath = $result.SummaryPath
        DecisionPacketPath = $result.DecisionPacketPath
    }
}

function Validate-MilestoneCloseoutPacketFields {
    param(
        [Parameter(Mandatory = $true)]
        $CloseoutPacket,
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory
    )

    $foundation = Get-MilestoneAutocycleFoundationContract
    $contract = Get-MilestoneAutocycleCloseoutPacketContract

    foreach ($fieldName in @($foundation.closeout_packet_required_fields)) {
        Get-RequiredProperty -Object $CloseoutPacket -Name $fieldName -Context "Milestone closeout packet" | Out-Null
    }
    foreach ($fieldName in @($contract.required_fields)) {
        Get-RequiredProperty -Object $CloseoutPacket -Name $fieldName -Context "Milestone closeout packet" | Out-Null
    }

    $closeoutPacketId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $CloseoutPacket -Name "closeout_packet_id" -Context "Milestone closeout packet") -Context "Milestone closeout packet.closeout_packet_id"
    $cycleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $CloseoutPacket -Name "cycle_id" -Context "Milestone closeout packet") -Context "Milestone closeout packet.cycle_id"
    $replayProofId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $CloseoutPacket -Name "replay_proof_id" -Context "Milestone closeout packet") -Context "Milestone closeout packet.replay_proof_id"
    $summaryId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $CloseoutPacket -Name "summary_id" -Context "Milestone closeout packet") -Context "Milestone closeout packet.summary_id"
    $decisionPacketId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $CloseoutPacket -Name "decision_packet_id" -Context "Milestone closeout packet") -Context "Milestone closeout packet.decision_packet_id"

    foreach ($pair in @(
            @{ Value = $closeoutPacketId; Context = "Milestone closeout packet.closeout_packet_id" },
            @{ Value = $cycleId; Context = "Milestone closeout packet.cycle_id" },
            @{ Value = $replayProofId; Context = "Milestone closeout packet.replay_proof_id" },
            @{ Value = $summaryId; Context = "Milestone closeout packet.summary_id" },
            @{ Value = $decisionPacketId; Context = "Milestone closeout packet.decision_packet_id" }
        )) {
        Assert-RegexMatch -Value $pair.Value -Pattern $foundation.identifier_pattern -Context $pair.Context
    }

    $replayProofPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $CloseoutPacket -Name "replay_proof_ref" -Context "Milestone closeout packet") -Context "Milestone closeout packet.replay_proof_ref") -Label "Milestone closeout replay proof"
    $replayProofValidation = Test-MilestoneAutocycleReplayProofContract -ReplayProofPath $replayProofPath

    if ($cycleId -ne $replayProofValidation.CycleId) {
        throw "Milestone closeout packet.cycle_id must match the referenced replay proof cycle_id."
    }
    if ($replayProofId -ne $replayProofValidation.ReplayProofId) {
        throw "Milestone closeout packet.replay_proof_id must match the referenced replay proof id."
    }
    if ($summaryId -ne $replayProofValidation.SummaryId) {
        throw "Milestone closeout packet.summary_id must match the referenced replay proof summary id."
    }
    if ($decisionPacketId -ne $replayProofValidation.DecisionPacketId) {
        throw "Milestone closeout packet.decision_packet_id must match the referenced replay proof decision packet id."
    }

    $summaryPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $CloseoutPacket -Name "summary_ref" -Context "Milestone closeout packet") -Context "Milestone closeout packet.summary_ref") -Label "Milestone closeout summary"
    $decisionPacketPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $CloseoutPacket -Name "decision_packet_ref" -Context "Milestone closeout packet") -Context "Milestone closeout packet.decision_packet_ref") -Label "Milestone closeout decision packet"
    if ($summaryPath -ne $replayProofValidation.SummaryPath) {
        throw "Milestone closeout packet.summary_ref must match the referenced replay proof summary."
    }
    if ($decisionPacketPath -ne $replayProofValidation.DecisionPacketPath) {
        throw "Milestone closeout packet.decision_packet_ref must match the referenced replay proof decision packet."
    }

    $operatorDecisionState = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $CloseoutPacket -Name "operator_decision_state" -Context "Milestone closeout packet") -Context "Milestone closeout packet.operator_decision_state"
    Assert-AllowedValue -Value $operatorDecisionState -AllowedValues @($foundation.allowed_operator_decision_states) -Context "Milestone closeout packet.operator_decision_state"
    if ($operatorDecisionState -ne $replayProofValidation.OperatorDecisionState) {
        throw "Milestone closeout packet.operator_decision_state must match the referenced replay proof operator decision state."
    }

    $closeoutScope = Assert-NoForbiddenClaims -Value (Get-RequiredProperty -Object $CloseoutPacket -Name "closeout_scope" -Context "Milestone closeout packet") -Context "Milestone closeout packet.closeout_scope" -Fragments @($contract.prohibited_claim_fragments)
    $provedScope = Assert-NoForbiddenClaims -Value (Get-RequiredProperty -Object $CloseoutPacket -Name "proved_scope" -Context "Milestone closeout packet") -Context "Milestone closeout packet.proved_scope" -Fragments @($contract.prohibited_claim_fragments)
    $unprovedScope = Assert-NoForbiddenClaims -Value (Get-RequiredProperty -Object $CloseoutPacket -Name "unproved_scope" -Context "Milestone closeout packet") -Context "Milestone closeout packet.unproved_scope" -Fragments @($contract.prohibited_claim_fragments)
    $outOfScope = Assert-NoForbiddenClaims -Value (Get-RequiredProperty -Object $CloseoutPacket -Name "out_of_scope" -Context "Milestone closeout packet") -Context "Milestone closeout packet.out_of_scope" -Fragments @($contract.prohibited_claim_fragments)
    $nonClaims = [object[]](Validate-NonClaims -NonClaims (Get-RequiredProperty -Object $CloseoutPacket -Name "non_claims" -Context "Milestone closeout packet") -Context "Milestone closeout packet.non_claims" -RequiredFragments @($contract.required_non_claim_fragments))
    $notes = Assert-NoForbiddenClaims -Value (Get-RequiredProperty -Object $CloseoutPacket -Name "notes" -Context "Milestone closeout packet") -Context "Milestone closeout packet.notes" -Fragments @($contract.prohibited_claim_fragments)

    return [pscustomobject]@{
        CloseoutPacketId = $closeoutPacketId
        CycleId = $cycleId
        ReplayProofId = $replayProofId
        SummaryId = $summaryId
        DecisionPacketId = $decisionPacketId
        OperatorDecisionState = $operatorDecisionState
        ReplayProofPath = $replayProofValidation.ReplayProofPath
        SummaryPath = $replayProofValidation.SummaryPath
        DecisionPacketPath = $replayProofValidation.DecisionPacketPath
        CloseoutScope = $closeoutScope
        ProvedScope = $provedScope
        UnprovedScope = $unprovedScope
        OutOfScope = $outOfScope
        NonClaims = $nonClaims
        Notes = $notes
    }
}

function Test-MilestoneAutocycleCloseoutPacketContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$CloseoutPacketPath
    )

    $resolvedCloseoutPacketPath = Resolve-ExistingPath -PathValue $CloseoutPacketPath -Label "Milestone closeout packet"
    $closeoutPacket = Get-JsonDocument -Path $resolvedCloseoutPacketPath -Label "Milestone closeout packet"
    $result = Validate-MilestoneCloseoutPacketFields -CloseoutPacket $closeoutPacket -BaseDirectory (Split-Path -Parent $resolvedCloseoutPacketPath)

    return [pscustomobject]@{
        IsValid = $true
        CloseoutPacketId = $result.CloseoutPacketId
        CycleId = $result.CycleId
        ReplayProofId = $result.ReplayProofId
        SummaryId = $result.SummaryId
        DecisionPacketId = $result.DecisionPacketId
        OperatorDecisionState = $result.OperatorDecisionState
        ReplayProofPath = $result.ReplayProofPath
        SummaryPath = $result.SummaryPath
        DecisionPacketPath = $result.DecisionPacketPath
        CloseoutPacketPath = $resolvedCloseoutPacketPath
    }
}

function Invoke-MilestoneAutocycleCloseoutFlow {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SummaryPath,
        [Parameter(Mandatory = $true)]
        [string]$DecisionPacketPath,
        [Parameter(Mandatory = $true)]
        $ProofRefs,
        [Parameter(Mandatory = $true)]
        [string]$OutputRoot,
        [string]$ReplayProofId,
        [string]$CloseoutPacketId,
        [string[]]$NonClaims,
        [string]$Notes = "Bounded replay proof assembled from authoritative summary, decision packet, and governed proof refs only.",
        [string]$CloseoutNotes = "Bounded closeout packet assembled from authoritative replay proof, summary, and decision packet only."
    )

    $foundation = Get-MilestoneAutocycleFoundationContract
    $replayProofContract = Get-MilestoneAutocycleReplayProofContract
    $summaryPilotInputs = Resolve-SummaryPilotInputs -SummaryPath $SummaryPath -DecisionPacketPath $DecisionPacketPath

    if ([string]::IsNullOrWhiteSpace($ReplayProofId)) {
        $ReplayProofId = "replay-proof-{0}" -f $summaryPilotInputs.SummaryValidation.CycleId
    }
    if ([string]::IsNullOrWhiteSpace($CloseoutPacketId)) {
        $CloseoutPacketId = "closeout-packet-{0}" -f $summaryPilotInputs.SummaryValidation.CycleId
    }
    Assert-RegexMatch -Value $ReplayProofId -Pattern $foundation.identifier_pattern -Context "ReplayProofId"
    Assert-RegexMatch -Value $CloseoutPacketId -Pattern $foundation.identifier_pattern -Context "CloseoutPacketId"
    Assert-NonEmptyString -Value $Notes -Context "Notes" | Out-Null
    Assert-NonEmptyString -Value $CloseoutNotes -Context "CloseoutNotes" | Out-Null

    $repositoryRoot = $summaryPilotInputs.RepositoryRoot
    $resolvedOutputRoot = Resolve-PathForCreationInsideRepository -PathValue $OutputRoot -RepositoryRoot $repositoryRoot -Label "Milestone closeout output root"
    $replayProofDirectory = Join-Path $resolvedOutputRoot "replay_proofs"
    $closeoutPacketDirectory = Join-Path $resolvedOutputRoot "closeout_packets"
    New-Item -ItemType Directory -Path $replayProofDirectory -Force | Out-Null
    New-Item -ItemType Directory -Path $closeoutPacketDirectory -Force | Out-Null

    $replayProofPath = Join-Path $replayProofDirectory ("{0}.json" -f $ReplayProofId)
    $closeoutPacketPath = Join-Path $closeoutPacketDirectory ("{0}.json" -f $CloseoutPacketId)
    if (Test-Path -LiteralPath $replayProofPath) {
        throw "Milestone replay proof id '$ReplayProofId' already exists."
    }
    if (Test-Path -LiteralPath $closeoutPacketPath) {
        throw "Milestone closeout packet id '$CloseoutPacketId' already exists."
    }

    if ($PSBoundParameters.ContainsKey("NonClaims")) {
        $normalizedNonClaims = [object[]](Validate-NonClaims -NonClaims $NonClaims -Context "NonClaims" -RequiredFragments @($replayProofContract.required_non_claim_fragments))
    }
    else {
        $normalizedNonClaims = [object[]](Get-DefaultCloseoutNonClaims)
    }

    $validatedProofRefs = Validate-ReplayProofRefs -ProofRefs $ProofRefs -SummaryPilotInputs $summaryPilotInputs -BaseDirectory $replayProofDirectory
    $replayProof = [pscustomobject]@{
        contract_version = $foundation.contract_version
        record_type = $foundation.replay_proof_record_type
        replay_proof_id = $ReplayProofId
        cycle_id = $summaryPilotInputs.SummaryValidation.CycleId
        summary_ref = Get-RelativeReference -BaseDirectory $replayProofDirectory -TargetPath $summaryPilotInputs.SummaryValidation.SummaryPath
        summary_id = $summaryPilotInputs.SummaryValidation.SummaryId
        decision_packet_ref = Get-RelativeReference -BaseDirectory $replayProofDirectory -TargetPath $summaryPilotInputs.DecisionPacketValidation.DecisionPacketPath
        decision_packet_id = $summaryPilotInputs.DecisionPacketValidation.DecisionPacketId
        recommendation = $summaryPilotInputs.DecisionPacketValidation.Recommendation
        operator_decision_state = "advisory_only_not_executed"
        proof_refs = [pscustomobject]@{
            proposal_ref = Get-RelativeReference -BaseDirectory $replayProofDirectory -TargetPath $validatedProofRefs.ProposalPath
            approval_ref = Get-RelativeReference -BaseDirectory $replayProofDirectory -TargetPath $validatedProofRefs.ApprovalPath
            freeze_ref = Get-RelativeReference -BaseDirectory $replayProofDirectory -TargetPath $validatedProofRefs.FreezePath
            baseline_binding_ref = Get-RelativeReference -BaseDirectory $replayProofDirectory -TargetPath $validatedProofRefs.BindingPath
            dispatch_refs = @($validatedProofRefs.DispatchPaths | ForEach-Object { Get-RelativeReference -BaseDirectory $replayProofDirectory -TargetPath $_ })
            run_ledger_refs = @($validatedProofRefs.RunLedgerPaths | ForEach-Object { Get-RelativeReference -BaseDirectory $replayProofDirectory -TargetPath $_ })
            execution_evidence_refs = @($validatedProofRefs.ExecutionEvidencePaths | ForEach-Object { Get-RelativeReference -BaseDirectory $replayProofDirectory -TargetPath $_ })
            qa_observation_refs = @($validatedProofRefs.QAObservationPaths | ForEach-Object { Get-RelativeReference -BaseDirectory $replayProofDirectory -TargetPath $_ })
            qa_aggregation_ref = Get-RelativeReference -BaseDirectory $replayProofDirectory -TargetPath $validatedProofRefs.QAAggregationPath
        }
        replay_scope = Get-DefaultReplayScope
        replay_source = [pscustomobject]@{
            repository_root = $repositoryRoot
            branch = Get-GitBranchName -RepositoryRoot $repositoryRoot
            head_commit = Get-GitHeadCommit -RepositoryRoot $repositoryRoot
        }
        boundary_statement = Get-DefaultReplayBoundaryStatement
        non_claims = @($normalizedNonClaims)
        notes = $Notes
    }

    Write-JsonDocument -Path $replayProofPath -Document $replayProof
    $replayProofValidation = Test-MilestoneAutocycleReplayProofContract -ReplayProofPath $replayProofPath

    $closeoutPacket = [pscustomobject]@{
        contract_version = $foundation.contract_version
        record_type = $foundation.closeout_packet_record_type
        closeout_packet_id = $CloseoutPacketId
        cycle_id = $replayProofValidation.CycleId
        replay_proof_ref = Get-RelativeReference -BaseDirectory $closeoutPacketDirectory -TargetPath $replayProofValidation.ReplayProofPath
        replay_proof_id = $replayProofValidation.ReplayProofId
        summary_ref = Get-RelativeReference -BaseDirectory $closeoutPacketDirectory -TargetPath $replayProofValidation.SummaryPath
        summary_id = $replayProofValidation.SummaryId
        decision_packet_ref = Get-RelativeReference -BaseDirectory $closeoutPacketDirectory -TargetPath $replayProofValidation.DecisionPacketPath
        decision_packet_id = $replayProofValidation.DecisionPacketId
        operator_decision_state = $replayProofValidation.OperatorDecisionState
        closeout_scope = Get-DefaultCloseoutScope
        proved_scope = Get-DefaultProvedScope
        unproved_scope = Get-DefaultUnprovedScope
        out_of_scope = Get-DefaultOutOfScope
        non_claims = @($normalizedNonClaims)
        notes = $CloseoutNotes
    }

    Write-JsonDocument -Path $closeoutPacketPath -Document $closeoutPacket
    $closeoutPacketValidation = Test-MilestoneAutocycleCloseoutPacketContract -CloseoutPacketPath $closeoutPacketPath

    return [pscustomobject]@{
        ReplayProofValidation = $replayProofValidation
        CloseoutPacketValidation = $closeoutPacketValidation
        ReplayProofPath = $replayProofValidation.ReplayProofPath
        CloseoutPacketPath = $closeoutPacketValidation.CloseoutPacketPath
        ReplayProofId = $replayProofValidation.ReplayProofId
        CloseoutPacketId = $closeoutPacketValidation.CloseoutPacketId
        CycleId = $replayProofValidation.CycleId
    }
}

Export-ModuleMember -Function Test-MilestoneAutocycleReplayProofContract, Test-MilestoneAutocycleCloseoutPacketContract, Invoke-MilestoneAutocycleCloseoutFlow
