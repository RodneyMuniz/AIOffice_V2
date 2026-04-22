Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$milestoneQAModulePath = Join-Path $PSScriptRoot "MilestoneAutocycleQA.psm1"
$milestoneExecutionEvidenceModulePath = Join-Path $PSScriptRoot "MilestoneAutocycleExecutionEvidence.psm1"
$script:testMilestoneAutocycleQAAggregationContract = $null
$script:testMilestoneAutocycleQAObservationContract = $null
$script:testMilestoneAutocycleExecutionEvidenceContract = $null

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

    $json = $Document | ConvertTo-Json -Depth 20
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

function Get-MilestoneAutocycleFoundationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_autocycle\foundation.contract.json") -Label "Milestone autocycle foundation contract"
}

function Get-MilestoneAutocycleSummaryContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_autocycle\summary.contract.json") -Label "Milestone autocycle summary contract"
}

function Get-MilestoneAutocycleDecisionPacketContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_autocycle\decision_packet.contract.json") -Label "Milestone autocycle decision packet contract"
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
        throw "Milestone summary requires dependency module '$DependencyLabel' at '$ModulePath'."
    }

    try {
        $module = Import-Module $ModulePath -Force -PassThru -ErrorAction Stop
    }
    catch {
        throw "Milestone summary requires dependency module '$DependencyLabel' to load successfully. $($_.Exception.Message)"
    }

    $command = $module.ExportedCommands[$CommandName]
    if ($null -eq $command) {
        throw "Milestone summary requires dependency command '$CommandName' from dependency module '$DependencyLabel'."
    }

    return $command
}

function Get-MilestoneAutocycleQAAggregationValidatorCommand {
    if ($null -eq $script:testMilestoneAutocycleQAAggregationContract) {
        $script:testMilestoneAutocycleQAAggregationContract = Get-RequiredDependencyCommand -ModulePath $milestoneQAModulePath -DependencyLabel "MilestoneAutocycleQA" -CommandName "Test-MilestoneAutocycleQAAggregationContract"
    }

    return $script:testMilestoneAutocycleQAAggregationContract
}

function Get-MilestoneAutocycleQAObservationValidatorCommand {
    if ($null -eq $script:testMilestoneAutocycleQAObservationContract) {
        $script:testMilestoneAutocycleQAObservationContract = Get-RequiredDependencyCommand -ModulePath $milestoneQAModulePath -DependencyLabel "MilestoneAutocycleQA" -CommandName "Test-MilestoneAutocycleQAObservationContract"
    }

    return $script:testMilestoneAutocycleQAObservationContract
}

function Get-MilestoneAutocycleExecutionEvidenceValidatorCommand {
    if ($null -eq $script:testMilestoneAutocycleExecutionEvidenceContract) {
        $script:testMilestoneAutocycleExecutionEvidenceContract = Get-RequiredDependencyCommand -ModulePath $milestoneExecutionEvidenceModulePath -DependencyLabel "MilestoneAutocycleExecutionEvidence" -CommandName "Test-MilestoneAutocycleExecutionEvidenceContract"
    }

    return $script:testMilestoneAutocycleExecutionEvidenceContract
}

function Resolve-QAAggregationInput {
    param(
        [Parameter(Mandatory = $true)]
        [string]$QAAggregationPath
    )

    $qaAggregationValidator = Get-MilestoneAutocycleQAAggregationValidatorCommand
    $qaAggregationValidation = & $qaAggregationValidator -QAAggregationPath $QAAggregationPath
    $qaAggregation = Get-JsonDocument -Path $qaAggregationValidation.QAAggregationPath -Label "Milestone summary QA aggregation"

    return [pscustomobject]@{
        Validation = $qaAggregationValidation
        Aggregation = $qaAggregation
    }
}

function Resolve-SummaryTaskInputs {
    param(
        [Parameter(Mandatory = $true)]
        $QAAggregationInput
    )

    $qaObservationValidator = Get-MilestoneAutocycleQAObservationValidatorCommand
    $executionEvidenceValidator = Get-MilestoneAutocycleExecutionEvidenceValidatorCommand
    $aggregationDirectory = Split-Path -Parent $QAAggregationInput.Validation.QAAggregationPath
    $resolvedItems = @()

    foreach ($taskResult in @($QAAggregationInput.Aggregation.task_results)) {
        $qaObservationPath = Resolve-ReferenceAgainstBase -BaseDirectory $aggregationDirectory -Reference (Assert-NonEmptyString -Value $taskResult.qa_observation_ref -Context "Milestone summary QA aggregation.task_results item.qa_observation_ref") -Label "Milestone summary QA observation"
        $qaObservationValidation = & $qaObservationValidator -QAObservationPath $qaObservationPath
        $qaObservation = Get-JsonDocument -Path $qaObservationValidation.QAObservationPath -Label "Milestone summary QA observation"

        $qaObservationDirectory = Split-Path -Parent $qaObservationValidation.QAObservationPath
        $executionEvidencePath = Resolve-ReferenceAgainstBase -BaseDirectory $qaObservationDirectory -Reference (Assert-NonEmptyString -Value $qaObservation.execution_evidence_ref -Context "Milestone summary QA observation.execution_evidence_ref") -Label "Milestone summary execution evidence"
        $executionEvidenceValidation = & $executionEvidenceValidator -EvidenceBundlePath $executionEvidencePath
        $executionEvidence = Get-JsonDocument -Path $executionEvidenceValidation.EvidenceBundlePath -Label "Milestone summary execution evidence"

        $resolvedItems += [pscustomobject]@{
            TaskResult = $taskResult
            QAObservationValidation = $qaObservationValidation
            QAObservation = $qaObservation
            ExecutionEvidenceValidation = $executionEvidenceValidation
            ExecutionEvidence = $executionEvidence
        }
    }

    if ($resolvedItems.Count -eq 0) {
        throw "Milestone summary requires at least one task QA result in the authoritative QA aggregation."
    }

    Write-Output -NoEnumerate $resolvedItems
}

function Get-UniqueValues {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Values
    )

    $items = @($Values | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) } | Sort-Object -Unique)
    Write-Output -NoEnumerate $items
}

function Convert-TaskInputsToCoverage {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$TaskInputs
    )

    $coverage = @()
    foreach ($taskInput in $TaskInputs) {
        $coverage += [pscustomobject]@{
            task_id = $taskInput.QAObservationValidation.TaskId
            dispatch_id = $taskInput.QAObservationValidation.DispatchId
            qa_observation_id = $taskInput.QAObservationValidation.QAObservationId
            status = $taskInput.QAObservationValidation.Status
        }
    }

    Write-Output -NoEnumerate $coverage
}

function Get-DefaultSummaryRecommendation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$MilestoneStatus
    )

    switch ($MilestoneStatus) {
        "passed" { return "accept" }
        "blocked" { return "rework" }
        "failed" { return "stop" }
        default { throw "Unsupported milestone QA status '$MilestoneStatus' for summary recommendation." }
    }
}

function Get-DefaultNonClaims {
    return @(
        "This summary is not replay proof.",
        "This summary is not final closeout.",
        "This summary does not prove broader autonomy.",
        "This summary does not prove rollback execution, unattended automatic resume, UI, Standard runtime, multi-repo behavior, or swarms."
    )
}

function New-ScopeSummary {
    param(
        [Parameter(Mandatory = $true)]
        $QAAggregationInput,
        [Parameter(Mandatory = $true)]
        [object[]]$TaskInputs
    )

    $dispatchIds = Get-UniqueValues -Values @($TaskInputs | ForEach-Object { $_.QAObservationValidation.DispatchId })
    $taskIds = Get-UniqueValues -Values @($TaskInputs | ForEach-Object { $_.QAObservationValidation.TaskId })
    $baselineIds = Get-UniqueValues -Values @($TaskInputs | ForEach-Object { $_.QAObservationValidation.BaselineId })
    $executorTypes = Get-UniqueValues -Values @($TaskInputs | ForEach-Object { $_.QAObservationValidation.ExecutorType })

    return "The authoritative QA aggregation covers {0} governed task results for cycle {1} across dispatches {2}, frozen tasks {3}, executor types {4}, and pinned baselines {5}." -f $TaskInputs.Count, $QAAggregationInput.Validation.CycleId, ($dispatchIds -join ", "), ($taskIds -join ", "), ($executorTypes -join ", "), ($baselineIds -join ", ")
}

function New-DiffSummary {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$TaskInputs
    )

    $changedFileEntries = @()
    foreach ($taskInput in $TaskInputs) {
        foreach ($changedFile in @($taskInput.ExecutionEvidence.changed_files)) {
            $changedFileEntries += "{0} ({1})" -f $changedFile.path, $changedFile.change_kind
        }
    }

    $uniqueChangedFileEntries = Get-UniqueValues -Values $changedFileEntries
    return "Governed execution evidence records {0} changed-file entries across {1} execution bundles. Changed paths: {2}." -f $uniqueChangedFileEntries.Count, $TaskInputs.Count, ($uniqueChangedFileEntries -join ", ")
}

function New-TestSummary {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$TaskInputs
    )

    $testKinds = @()
    $testRefs = @()
    foreach ($taskInput in $TaskInputs) {
        foreach ($testOutput in @($taskInput.ExecutionEvidence.test_outputs)) {
            $testKinds += $testOutput.kind
            $testRefs += $testOutput.ref
        }
    }

    $uniqueTestKinds = Get-UniqueValues -Values $testKinds
    $uniqueTestRefs = Get-UniqueValues -Values $testRefs
    return "Governed execution evidence records {0} durable test-output refs across test kinds {1}. Test refs: {2}." -f $uniqueTestRefs.Count, ($uniqueTestKinds -join ", "), ($uniqueTestRefs -join ", ")
}

function New-BlockerSummary {
    param(
        [Parameter(Mandatory = $true)]
        $QAAggregationInput,
        [Parameter(Mandatory = $true)]
        [object[]]$TaskInputs
    )

    $milestoneStatus = $QAAggregationInput.Validation.MilestoneStatus
    $progressionState = $QAAggregationInput.Validation.ProgressionState
    $stopReasonCode = $QAAggregationInput.Validation.StopReasonCode

    if ($milestoneStatus -eq "passed") {
        return "The authoritative milestone QA state is passed with progression {0}. No blocked or failed QA task results are present in the governed aggregation." -f $progressionState
    }

    $blockedFindings = @()
    foreach ($taskInput in $TaskInputs | Where-Object { $_.QAObservationValidation.Status -in @("blocked", "failed") }) {
        foreach ($finding in @($taskInput.QAObservation.findings)) {
            $blockedFindings += $finding.summary
        }
    }

    $uniqueBlockedFindings = Get-UniqueValues -Values $blockedFindings
    return "The authoritative milestone QA state is {0} with progression {1} and stop reason {2}. Governed blocking findings: {3}." -f $milestoneStatus, $progressionState, $stopReasonCode, ($uniqueBlockedFindings -join " | ")
}

function New-EvidenceQualitySummary {
    param(
        [Parameter(Mandatory = $true)]
        $QAAggregationInput,
        [Parameter(Mandatory = $true)]
        [object[]]$TaskInputs
    )

    $producedArtifactCount = 0
    $executionEvidenceRefCount = 0
    $qaEvidenceRefCount = 0
    $findingCount = 0
    foreach ($taskInput in $TaskInputs) {
        $producedArtifactCount += @($taskInput.ExecutionEvidence.produced_artifacts).Count
        $executionEvidenceRefCount += @($taskInput.ExecutionEvidence.evidence_refs).Count
        $qaEvidenceRefCount += @($taskInput.QAObservation.evidence_refs).Count
        $findingCount += @($taskInput.QAObservation.findings).Count
    }

    if ($QAAggregationInput.Validation.MilestoneStatus -eq "passed") {
        return "Evidence quality is bounded and traceable through {0} governed execution bundles, {1} QA observations, {2} produced artifacts, {3} execution evidence refs, {4} QA evidence refs, and {5} QA findings. It supports bounded operator review only and remains thinner than replay-grade or closeout-grade evidence." -f $TaskInputs.Count, $TaskInputs.Count, $producedArtifactCount, $executionEvidenceRefCount, $qaEvidenceRefCount, $findingCount
    }

    return "Evidence quality is bounded and traceable through {0} governed execution bundles, {1} QA observations, {2} produced artifacts, {3} execution evidence refs, {4} QA evidence refs, and {5} QA findings, but the authoritative milestone QA state remains {6}. The summary therefore stays advisory and does not claim acceptance readiness." -f $TaskInputs.Count, $TaskInputs.Count, $producedArtifactCount, $executionEvidenceRefCount, $qaEvidenceRefCount, $findingCount, $QAAggregationInput.Validation.MilestoneStatus
}

function Assert-NoForbiddenSummaryClaims {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $contract = Get-MilestoneAutocycleSummaryContract
    $normalizedValue = Assert-NonEmptyString -Value $Value -Context $Context
    foreach ($fragment in @($contract.prohibited_claim_fragments)) {
        if ($normalizedValue.IndexOf($fragment, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
            throw "$Context must not claim '$fragment'."
        }
    }

    return $normalizedValue
}

function Validate-NonClaims {
    param(
        [AllowNull()]
        $NonClaims
    )

    $contract = Get-MilestoneAutocycleSummaryContract
    $items = [object[]](Assert-StringArray -Value $NonClaims -Context "Milestone summary.non_claims")
    $normalizedItems = @()
    foreach ($item in $items) {
        $normalizedItems += (Assert-NonEmptyString -Value $item -Context "Milestone summary.non_claims item")
    }

    foreach ($requiredFragment in @($contract.required_non_claim_fragments)) {
        $matchingClaim = @($normalizedItems | Where-Object {
                $_.IndexOf($requiredFragment, [System.StringComparison]::OrdinalIgnoreCase) -ge 0
            })
        if ($matchingClaim.Count -eq 0) {
            throw "Milestone summary.non_claims must explicitly cover '$requiredFragment'."
        }
    }

    Write-Output -NoEnumerate $normalizedItems
}

function Validate-TaskCoverage {
    param(
        [AllowNull()]
        $TaskCoverage,
        [Parameter(Mandatory = $true)]
        $QAAggregationInput
    )

    $foundation = Get-MilestoneAutocycleFoundationContract
    $contract = Get-MilestoneAutocycleSummaryContract
    $items = [object[]](Assert-ObjectArray -Value $TaskCoverage -Context "Milestone summary.task_coverage")
    $normalizedItems = @()

    foreach ($item in $items) {
        foreach ($fieldName in @($contract.task_coverage_required_fields)) {
            Get-RequiredProperty -Object $item -Name $fieldName -Context "Milestone summary.task_coverage item" | Out-Null
        }

        $taskId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "task_id" -Context "Milestone summary.task_coverage item") -Context "Milestone summary.task_coverage item.task_id"
        $dispatchId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "dispatch_id" -Context "Milestone summary.task_coverage item") -Context "Milestone summary.task_coverage item.dispatch_id"
        $qaObservationId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "qa_observation_id" -Context "Milestone summary.task_coverage item") -Context "Milestone summary.task_coverage item.qa_observation_id"
        $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "status" -Context "Milestone summary.task_coverage item") -Context "Milestone summary.task_coverage item.status"

        foreach ($pair in @(
                @{ Value = $taskId; Context = "Milestone summary.task_coverage item.task_id" },
                @{ Value = $dispatchId; Context = "Milestone summary.task_coverage item.dispatch_id" },
                @{ Value = $qaObservationId; Context = "Milestone summary.task_coverage item.qa_observation_id" }
            )) {
            Assert-RegexMatch -Value $pair.Value -Pattern $foundation.identifier_pattern -Context $pair.Context
        }

        Assert-AllowedValue -Value $status -AllowedValues @((Get-MilestoneAutocycleFoundationContract).allowed_qa_statuses) -Context "Milestone summary.task_coverage item.status"
        $normalizedItems += [pscustomobject]@{
            task_id = $taskId
            dispatch_id = $dispatchId
            qa_observation_id = $qaObservationId
            status = $status
        }
    }

    $expectedCoverage = @($QAAggregationInput.Aggregation.task_results | ForEach-Object {
            [pscustomobject]@{
                task_id = $_.task_id
                dispatch_id = $_.dispatch_id
                qa_observation_id = $_.qa_observation_id
                status = $_.status
            }
        })

    if ($normalizedItems.Count -ne $expectedCoverage.Count) {
        throw "Milestone summary.task_coverage must cover every authoritative task QA result from the referenced aggregation."
    }

    foreach ($expectedItem in $expectedCoverage) {
        $match = @($normalizedItems | Where-Object {
                $_.task_id -eq $expectedItem.task_id -and
                $_.dispatch_id -eq $expectedItem.dispatch_id -and
                $_.qa_observation_id -eq $expectedItem.qa_observation_id -and
                $_.status -eq $expectedItem.status
            })
        if ($match.Count -eq 0) {
            throw "Milestone summary.task_coverage must match the authoritative task QA results from the referenced aggregation."
        }
    }

    Write-Output -NoEnumerate $normalizedItems
}

function Validate-DecisionOptions {
    param(
        [AllowNull()]
        $Options
    )

    $contract = Get-MilestoneAutocycleDecisionPacketContract
    $items = [object[]](Assert-StringArray -Value $Options -Context "Milestone decision packet.options")
    $normalizedItems = @()
    foreach ($item in $items) {
        $normalizedItems += (Assert-NonEmptyString -Value $item -Context "Milestone decision packet.options item")
    }

    $uniqueItems = @($normalizedItems | Sort-Object -Unique)
    $expectedOptions = @($contract.allowed_options | Sort-Object -Unique)
    if ($uniqueItems.Count -ne $expectedOptions.Count) {
        throw "Milestone decision packet.options must contain exactly the bounded operator options."
    }

    foreach ($expectedOption in $expectedOptions) {
        if ($uniqueItems -notcontains $expectedOption) {
            throw "Milestone decision packet.options must contain only: $($expectedOptions -join ', ')."
        }
    }

    return @($contract.allowed_options)
}

function Validate-MilestoneSummaryFields {
    param(
        [Parameter(Mandatory = $true)]
        $Summary,
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory
    )

    $foundation = Get-MilestoneAutocycleFoundationContract
    $contract = Get-MilestoneAutocycleSummaryContract

    foreach ($fieldName in @($foundation.summary_required_fields)) {
        Get-RequiredProperty -Object $Summary -Name $fieldName -Context "Milestone summary" | Out-Null
    }
    foreach ($fieldName in @($contract.required_fields)) {
        Get-RequiredProperty -Object $Summary -Name $fieldName -Context "Milestone summary" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Summary -Name "contract_version" -Context "Milestone summary") -Context "Milestone summary.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "Milestone summary.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Summary -Name "record_type" -Context "Milestone summary") -Context "Milestone summary.record_type"
    if ($recordType -ne $foundation.summary_record_type -or $recordType -ne $contract.record_type) {
        throw "Milestone summary.record_type must equal '$($foundation.summary_record_type)'."
    }

    $summaryId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Summary -Name "summary_id" -Context "Milestone summary") -Context "Milestone summary.summary_id"
    $cycleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Summary -Name "cycle_id" -Context "Milestone summary") -Context "Milestone summary.cycle_id"
    $aggregationId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Summary -Name "aggregation_id" -Context "Milestone summary") -Context "Milestone summary.aggregation_id"

    foreach ($pair in @(
            @{ Value = $summaryId; Context = "Milestone summary.summary_id" },
            @{ Value = $cycleId; Context = "Milestone summary.cycle_id" },
            @{ Value = $aggregationId; Context = "Milestone summary.aggregation_id" }
        )) {
        Assert-RegexMatch -Value $pair.Value -Pattern $foundation.identifier_pattern -Context $pair.Context
    }

    $aggregationPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Summary -Name "qa_aggregation_ref" -Context "Milestone summary") -Context "Milestone summary.qa_aggregation_ref") -Label "Milestone summary QA aggregation"
    $qaAggregationInput = Resolve-QAAggregationInput -QAAggregationPath $aggregationPath

    if ($cycleId -ne $qaAggregationInput.Validation.CycleId) {
        throw "Milestone summary.cycle_id must match the referenced QA aggregation cycle_id."
    }
    if ($aggregationId -ne $qaAggregationInput.Validation.AggregationId) {
        throw "Milestone summary.aggregation_id must match the referenced QA aggregation id."
    }

    $taskCoverage = [object[]](Validate-TaskCoverage -TaskCoverage (Get-RequiredProperty -Object $Summary -Name "task_coverage" -Context "Milestone summary") -QAAggregationInput $qaAggregationInput)
    $scopeSummary = Assert-NoForbiddenSummaryClaims -Value (Get-RequiredProperty -Object $Summary -Name "scope_summary" -Context "Milestone summary") -Context "Milestone summary.scope_summary"
    $diffSummary = Assert-NoForbiddenSummaryClaims -Value (Get-RequiredProperty -Object $Summary -Name "diff_summary" -Context "Milestone summary") -Context "Milestone summary.diff_summary"
    $testSummary = Assert-NoForbiddenSummaryClaims -Value (Get-RequiredProperty -Object $Summary -Name "test_summary" -Context "Milestone summary") -Context "Milestone summary.test_summary"
    $blockerSummary = Assert-NoForbiddenSummaryClaims -Value (Get-RequiredProperty -Object $Summary -Name "blocker_summary" -Context "Milestone summary") -Context "Milestone summary.blocker_summary"
    $evidenceQualitySummary = Assert-NoForbiddenSummaryClaims -Value (Get-RequiredProperty -Object $Summary -Name "evidence_quality_summary" -Context "Milestone summary") -Context "Milestone summary.evidence_quality_summary"
    $nonClaims = [object[]](Validate-NonClaims -NonClaims (Get-RequiredProperty -Object $Summary -Name "non_claims" -Context "Milestone summary"))
    $recommendation = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Summary -Name "recommendation" -Context "Milestone summary") -Context "Milestone summary.recommendation"
    Assert-AllowedValue -Value $recommendation -AllowedValues @($foundation.allowed_summary_recommendations) -Context "Milestone summary.recommendation"

    $recommendationIsAdvisory = Assert-BooleanValue -Value (Get-RequiredProperty -Object $Summary -Name "recommendation_is_advisory" -Context "Milestone summary") -Context "Milestone summary.recommendation_is_advisory"
    if (-not $recommendationIsAdvisory) {
        throw "Milestone summary.recommendation_is_advisory must remain true."
    }

    $notes = Assert-NoForbiddenSummaryClaims -Value (Get-RequiredProperty -Object $Summary -Name "notes" -Context "Milestone summary") -Context "Milestone summary.notes"

    return [pscustomobject]@{
        SummaryId = $summaryId
        CycleId = $cycleId
        AggregationId = $aggregationId
        QAAggregationPath = $qaAggregationInput.Validation.QAAggregationPath
        TaskCoverage = $taskCoverage
        Recommendation = $recommendation
        RecommendationIsAdvisory = $recommendationIsAdvisory
        SummaryPath = $null
        Notes = $notes
    }
}

function Test-MilestoneAutocycleSummaryContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SummaryPath
    )

    $resolvedSummaryPath = Resolve-ExistingPath -PathValue $SummaryPath -Label "Milestone summary"
    $summary = Get-JsonDocument -Path $resolvedSummaryPath -Label "Milestone summary"
    $result = Validate-MilestoneSummaryFields -Summary $summary -BaseDirectory (Split-Path -Parent $resolvedSummaryPath)

    return [pscustomobject]@{
        IsValid = $true
        SummaryId = $result.SummaryId
        CycleId = $result.CycleId
        AggregationId = $result.AggregationId
        QAAggregationPath = $result.QAAggregationPath
        Recommendation = $result.Recommendation
        RecommendationIsAdvisory = $result.RecommendationIsAdvisory
        SummaryPath = $resolvedSummaryPath
    }
}

function Validate-MilestoneDecisionPacketFields {
    param(
        [Parameter(Mandatory = $true)]
        $DecisionPacket,
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory
    )

    $foundation = Get-MilestoneAutocycleFoundationContract
    $contract = Get-MilestoneAutocycleDecisionPacketContract

    foreach ($fieldName in @($foundation.decision_packet_required_fields)) {
        Get-RequiredProperty -Object $DecisionPacket -Name $fieldName -Context "Milestone decision packet" | Out-Null
    }
    foreach ($fieldName in @($contract.required_fields)) {
        Get-RequiredProperty -Object $DecisionPacket -Name $fieldName -Context "Milestone decision packet" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $DecisionPacket -Name "contract_version" -Context "Milestone decision packet") -Context "Milestone decision packet.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "Milestone decision packet.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $DecisionPacket -Name "record_type" -Context "Milestone decision packet") -Context "Milestone decision packet.record_type"
    if ($recordType -ne $foundation.decision_packet_record_type -or $recordType -ne $contract.record_type) {
        throw "Milestone decision packet.record_type must equal '$($foundation.decision_packet_record_type)'."
    }

    $decisionPacketId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $DecisionPacket -Name "decision_packet_id" -Context "Milestone decision packet") -Context "Milestone decision packet.decision_packet_id"
    $cycleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $DecisionPacket -Name "cycle_id" -Context "Milestone decision packet") -Context "Milestone decision packet.cycle_id"
    $summaryId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $DecisionPacket -Name "summary_id" -Context "Milestone decision packet") -Context "Milestone decision packet.summary_id"

    foreach ($pair in @(
            @{ Value = $decisionPacketId; Context = "Milestone decision packet.decision_packet_id" },
            @{ Value = $cycleId; Context = "Milestone decision packet.cycle_id" },
            @{ Value = $summaryId; Context = "Milestone decision packet.summary_id" }
        )) {
        Assert-RegexMatch -Value $pair.Value -Pattern $foundation.identifier_pattern -Context $pair.Context
    }

    $summaryPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $DecisionPacket -Name "summary_ref" -Context "Milestone decision packet") -Context "Milestone decision packet.summary_ref") -Label "Milestone decision packet summary"
    $summaryValidation = Test-MilestoneAutocycleSummaryContract -SummaryPath $summaryPath

    if ($cycleId -ne $summaryValidation.CycleId) {
        throw "Milestone decision packet.cycle_id must match the referenced summary cycle_id."
    }
    if ($summaryId -ne $summaryValidation.SummaryId) {
        throw "Milestone decision packet.summary_id must match the referenced summary id."
    }

    $recommendation = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $DecisionPacket -Name "recommendation" -Context "Milestone decision packet") -Context "Milestone decision packet.recommendation"
    Assert-AllowedValue -Value $recommendation -AllowedValues @($foundation.allowed_summary_recommendations) -Context "Milestone decision packet.recommendation"
    if ($recommendation -ne $summaryValidation.Recommendation) {
        throw "Milestone decision packet.recommendation must match the referenced summary recommendation."
    }

    $recommendationIsAdvisory = Assert-BooleanValue -Value (Get-RequiredProperty -Object $DecisionPacket -Name "recommendation_is_advisory" -Context "Milestone decision packet") -Context "Milestone decision packet.recommendation_is_advisory"
    if (-not $recommendationIsAdvisory -or -not $summaryValidation.RecommendationIsAdvisory) {
        throw "Milestone decision packet.recommendation_is_advisory must remain true."
    }

    $options = [object[]](Validate-DecisionOptions -Options (Get-RequiredProperty -Object $DecisionPacket -Name "options" -Context "Milestone decision packet"))
    $notes = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $DecisionPacket -Name "notes" -Context "Milestone decision packet") -Context "Milestone decision packet.notes"

    return [pscustomobject]@{
        DecisionPacketId = $decisionPacketId
        CycleId = $cycleId
        SummaryId = $summaryId
        SummaryPath = $summaryValidation.SummaryPath
        Recommendation = $recommendation
        RecommendationIsAdvisory = $recommendationIsAdvisory
        Options = $options
        Notes = $notes
    }
}

function Test-MilestoneAutocycleDecisionPacketContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$DecisionPacketPath
    )

    $resolvedDecisionPacketPath = Resolve-ExistingPath -PathValue $DecisionPacketPath -Label "Milestone decision packet"
    $decisionPacket = Get-JsonDocument -Path $resolvedDecisionPacketPath -Label "Milestone decision packet"
    $result = Validate-MilestoneDecisionPacketFields -DecisionPacket $decisionPacket -BaseDirectory (Split-Path -Parent $resolvedDecisionPacketPath)

    return [pscustomobject]@{
        IsValid = $true
        DecisionPacketId = $result.DecisionPacketId
        CycleId = $result.CycleId
        SummaryId = $result.SummaryId
        SummaryPath = $result.SummaryPath
        Recommendation = $result.Recommendation
        RecommendationIsAdvisory = $result.RecommendationIsAdvisory
        Options = $result.Options
        DecisionPacketPath = $resolvedDecisionPacketPath
    }
}

function Invoke-MilestoneAutocycleSummaryFlow {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$QAAggregationPath,
        [Parameter(Mandatory = $true)]
        [string]$OutputRoot,
        [string]$SummaryId,
        [string]$DecisionPacketId,
        [string[]]$NonClaims,
        [string]$Notes = "Bounded PRO-style milestone summary assembled from one authoritative QA aggregation and linked governed artifacts only.",
        [string]$DecisionPacketNotes = "Operator decision packet exposes bounded advisory options only and does not mutate milestone state."
    )

    $foundation = Get-MilestoneAutocycleFoundationContract
    $qaAggregationInput = Resolve-QAAggregationInput -QAAggregationPath $QAAggregationPath
    $taskInputs = [object[]](Resolve-SummaryTaskInputs -QAAggregationInput $qaAggregationInput)

    if ([string]::IsNullOrWhiteSpace($SummaryId)) {
        $SummaryId = "summary-{0}" -f $qaAggregationInput.Validation.CycleId
    }
    if ([string]::IsNullOrWhiteSpace($DecisionPacketId)) {
        $DecisionPacketId = "decision-packet-{0}" -f $qaAggregationInput.Validation.CycleId
    }
    Assert-RegexMatch -Value $SummaryId -Pattern $foundation.identifier_pattern -Context "SummaryId"
    Assert-RegexMatch -Value $DecisionPacketId -Pattern $foundation.identifier_pattern -Context "DecisionPacketId"
    Assert-NonEmptyString -Value $Notes -Context "Notes" | Out-Null
    Assert-NonEmptyString -Value $DecisionPacketNotes -Context "DecisionPacketNotes" | Out-Null

    $repositoryRoot = $taskInputs[0].QAObservationValidation.RepositoryRoot
    $resolvedOutputRoot = Resolve-PathForCreationInsideRepository -PathValue $OutputRoot -RepositoryRoot $repositoryRoot -Label "Milestone summary output root"
    $summaryDirectory = Join-Path $resolvedOutputRoot "summaries"
    $decisionPacketDirectory = Join-Path $resolvedOutputRoot "decision_packets"
    New-Item -ItemType Directory -Path $summaryDirectory -Force | Out-Null
    New-Item -ItemType Directory -Path $decisionPacketDirectory -Force | Out-Null

    $summaryPath = Join-Path $summaryDirectory ("{0}.json" -f $SummaryId)
    $decisionPacketPath = Join-Path $decisionPacketDirectory ("{0}.json" -f $DecisionPacketId)
    if (Test-Path -LiteralPath $summaryPath) {
        throw "Milestone summary id '$SummaryId' already exists."
    }
    if (Test-Path -LiteralPath $decisionPacketPath) {
        throw "Milestone decision packet id '$DecisionPacketId' already exists."
    }

    if ($PSBoundParameters.ContainsKey("NonClaims")) {
        $normalizedNonClaims = [object[]](Validate-NonClaims -NonClaims $NonClaims)
    }
    else {
        $normalizedNonClaims = [object[]](Get-DefaultNonClaims)
    }

    $taskCoverage = [object[]](Convert-TaskInputsToCoverage -TaskInputs $taskInputs)
    $recommendation = Get-DefaultSummaryRecommendation -MilestoneStatus $qaAggregationInput.Validation.MilestoneStatus
    $summary = [pscustomobject]@{
        contract_version = $foundation.contract_version
        record_type = $foundation.summary_record_type
        summary_id = $SummaryId
        cycle_id = $qaAggregationInput.Validation.CycleId
        qa_aggregation_ref = Get-RelativeReference -BaseDirectory $summaryDirectory -TargetPath $qaAggregationInput.Validation.QAAggregationPath
        aggregation_id = $qaAggregationInput.Validation.AggregationId
        task_coverage = @($taskCoverage)
        scope_summary = New-ScopeSummary -QAAggregationInput $qaAggregationInput -TaskInputs $taskInputs
        diff_summary = New-DiffSummary -TaskInputs $taskInputs
        test_summary = New-TestSummary -TaskInputs $taskInputs
        blocker_summary = New-BlockerSummary -QAAggregationInput $qaAggregationInput -TaskInputs $taskInputs
        evidence_quality_summary = New-EvidenceQualitySummary -QAAggregationInput $qaAggregationInput -TaskInputs $taskInputs
        non_claims = @($normalizedNonClaims)
        recommendation = $recommendation
        recommendation_is_advisory = $true
        notes = $Notes
    }

    Write-JsonDocument -Path $summaryPath -Document $summary
    $summaryValidation = Test-MilestoneAutocycleSummaryContract -SummaryPath $summaryPath

    $decisionPacket = [pscustomobject]@{
        contract_version = $foundation.contract_version
        record_type = $foundation.decision_packet_record_type
        decision_packet_id = $DecisionPacketId
        cycle_id = $summaryValidation.CycleId
        summary_ref = Get-RelativeReference -BaseDirectory $decisionPacketDirectory -TargetPath $summaryValidation.SummaryPath
        summary_id = $summaryValidation.SummaryId
        recommendation = $summaryValidation.Recommendation
        recommendation_is_advisory = $true
        options = @("accept", "rework", "stop")
        notes = $DecisionPacketNotes
    }

    Write-JsonDocument -Path $decisionPacketPath -Document $decisionPacket
    $decisionPacketValidation = Test-MilestoneAutocycleDecisionPacketContract -DecisionPacketPath $decisionPacketPath

    return [pscustomobject]@{
        SummaryValidation = $summaryValidation
        DecisionPacketValidation = $decisionPacketValidation
        SummaryPath = $summaryValidation.SummaryPath
        DecisionPacketPath = $decisionPacketValidation.DecisionPacketPath
        SummaryId = $summaryValidation.SummaryId
        DecisionPacketId = $decisionPacketValidation.DecisionPacketId
        CycleId = $summaryValidation.CycleId
        AggregationId = $summaryValidation.AggregationId
        Recommendation = $summaryValidation.Recommendation
    }
}

Export-ModuleMember -Function Test-MilestoneAutocycleSummaryContract, Test-MilestoneAutocycleDecisionPacketContract, Invoke-MilestoneAutocycleSummaryFlow
