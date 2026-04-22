Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$milestoneExecutionEvidenceModulePath = Join-Path $PSScriptRoot "MilestoneAutocycleExecutionEvidence.psm1"
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

function Get-RelativePathFromRoot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root,
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $basePath = [System.IO.Path]::GetFullPath($Root).TrimEnd("\/")
    $targetPath = [System.IO.Path]::GetFullPath($Path)
    $baseUri = [System.Uri]("{0}{1}" -f $basePath, [System.IO.Path]::DirectorySeparatorChar)
    $targetUri = [System.Uri]$targetPath
    return ($baseUri.MakeRelativeUri($targetUri).OriginalString).Replace("\", "/")
}

function Assert-RelativeRepositoryReference {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $normalized = Assert-NonEmptyString -Value $Value -Context $Context
    if ([System.IO.Path]::IsPathRooted($normalized)) {
        throw "$Context must be stored as a repository-relative path."
    }
    if ($normalized.Contains(":")) {
        throw "$Context must not contain drive-qualified or colon-qualified segments."
    }

    $segments = $normalized -split "[/\\]"
    if ($segments.Count -eq 0) {
        throw "$Context must include at least one path segment."
    }

    foreach ($segment in $segments) {
        if ([string]::IsNullOrWhiteSpace($segment)) {
            throw "$Context must not contain empty path segments."
        }
        if ($segment -eq "." -or $segment -eq "..") {
            throw "$Context must not traverse '.' or '..' path segments."
        }
    }

    return $normalized.Replace("\", "/")
}

function Resolve-RepositoryReferenceInput {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [switch]$RequireExisting
    )

    $resolvedRepositoryRoot = Resolve-ExistingPath -PathValue $RepositoryRoot -Label "Repository root"
    $reference = Assert-NonEmptyString -Value $Value -Context $Context
    if ([System.IO.Path]::IsPathRooted($reference)) {
        $candidate = [System.IO.Path]::GetFullPath($reference)
    }
    else {
        $normalizedReference = Assert-RelativeRepositoryReference -Value $reference -Context $Context
        $candidate = [System.IO.Path]::GetFullPath((Join-Path $resolvedRepositoryRoot ($normalizedReference -replace "[/\\]", [System.IO.Path]::DirectorySeparatorChar)))
    }

    if (-not (Test-PathWithinRoot -Path $candidate -Root $resolvedRepositoryRoot)) {
        throw "$Context must resolve inside repository root '$resolvedRepositoryRoot'."
    }

    if ($RequireExisting -and -not (Test-Path -LiteralPath $candidate)) {
        throw "$Context reference '$reference' does not exist."
    }

    return [pscustomobject]@{
        RelativePath = Get-RelativePathFromRoot -Root $resolvedRepositoryRoot -Path $candidate
        ResolvedPath = $candidate
    }
}

function Get-MilestoneAutocycleFoundationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_autocycle\foundation.contract.json") -Label "Milestone autocycle foundation contract"
}

function Get-MilestoneAutocycleQAObservationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_autocycle\qa_observation.contract.json") -Label "Milestone autocycle QA observation contract"
}

function Get-MilestoneAutocycleQAAggregationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_autocycle\qa_aggregation.contract.json") -Label "Milestone autocycle QA aggregation contract"
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
        throw "Milestone QA requires dependency module '$DependencyLabel' at '$ModulePath'."
    }

    try {
        $module = Import-Module $ModulePath -Force -PassThru -ErrorAction Stop
    }
    catch {
        throw "Milestone QA requires dependency module '$DependencyLabel' to load successfully. $($_.Exception.Message)"
    }

    $command = $module.ExportedCommands[$CommandName]
    if ($null -eq $command) {
        throw "Milestone QA requires dependency command '$CommandName' from dependency module '$DependencyLabel'."
    }

    return $command
}

function Get-MilestoneAutocycleExecutionEvidenceValidatorCommand {
    if ($null -eq $script:testMilestoneAutocycleExecutionEvidenceContract) {
        $script:testMilestoneAutocycleExecutionEvidenceContract = Get-RequiredDependencyCommand -ModulePath $milestoneExecutionEvidenceModulePath -DependencyLabel "MilestoneAutocycleExecutionEvidence" -CommandName "Test-MilestoneAutocycleExecutionEvidenceContract"
    }

    return $script:testMilestoneAutocycleExecutionEvidenceContract
}

function Resolve-ExecutionEvidenceInput {
    param(
        [Parameter(Mandatory = $true)]
        [string]$EvidenceBundlePath
    )

    $executionEvidenceValidator = Get-MilestoneAutocycleExecutionEvidenceValidatorCommand
    $executionEvidenceValidation = & $executionEvidenceValidator -EvidenceBundlePath $EvidenceBundlePath
    $executionEvidence = Get-JsonDocument -Path $executionEvidenceValidation.EvidenceBundlePath -Label "Milestone QA execution evidence"

    return [pscustomobject]@{
        Validation = $executionEvidenceValidation
        Evidence   = $executionEvidence
    }
}

function Validate-QAFindings {
    param(
        [AllowNull()]
        $Findings
    )

    $foundation = Get-MilestoneAutocycleFoundationContract
    $contract = Get-MilestoneAutocycleQAObservationContract
    $items = [object[]](Assert-ObjectArray -Value $Findings -Context "Milestone QA observation.findings")
    $normalizedItems = @()
    foreach ($item in $items) {
        foreach ($fieldName in @($contract.finding_required_fields)) {
            Get-RequiredProperty -Object $item -Name $fieldName -Context "Milestone QA observation.findings item" | Out-Null
        }

        $findingId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "finding_id" -Context "Milestone QA observation.findings item") -Context "Milestone QA observation.findings item.finding_id"
        Assert-RegexMatch -Value $findingId -Pattern $foundation.identifier_pattern -Context "Milestone QA observation.findings item.finding_id"
        $summary = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "summary" -Context "Milestone QA observation.findings item") -Context "Milestone QA observation.findings item.summary"
        $notes = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "notes" -Context "Milestone QA observation.findings item") -Context "Milestone QA observation.findings item.notes"

        $normalizedItems += [pscustomobject]@{
            finding_id = $findingId
            summary    = $summary
            notes      = $notes
        }
    }

    Write-Output -NoEnumerate $normalizedItems
}

function Validate-QAEvidenceRefs {
    param(
        [AllowNull()]
        $EvidenceRefs,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $contract = Get-MilestoneAutocycleQAObservationContract
    $items = [object[]](Assert-ObjectArray -Value $EvidenceRefs -Context $Context)
    $normalizedItems = @()
    foreach ($item in $items) {
        foreach ($fieldName in @($contract.evidence_ref_required_fields)) {
            Get-RequiredProperty -Object $item -Name $fieldName -Context "$Context item" | Out-Null
        }

        $kind = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "kind" -Context "$Context item") -Context "$Context item.kind"
        $reference = Resolve-RepositoryReferenceInput -Value (Get-RequiredProperty -Object $item -Name "ref" -Context "$Context item") -RepositoryRoot $RepositoryRoot -Context "$Context item.ref" -RequireExisting
        $notes = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "notes" -Context "$Context item") -Context "$Context item.notes"

        $normalizedItems += [pscustomobject]@{
            kind  = $kind
            ref   = $reference.RelativePath
            notes = $notes
        }
    }

    Write-Output -NoEnumerate $normalizedItems
}

function Get-QAAggregationRollupState {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$TaskResults
    )

    $statuses = @($TaskResults | ForEach-Object { $_.status })
    if ($statuses -contains "failed") {
        return [pscustomobject]@{
            MilestoneStatus = "failed"
            ProgressionState = "stop"
            StopReasonCode = "qa_failed"
        }
    }

    if ($statuses -contains "blocked") {
        return [pscustomobject]@{
            MilestoneStatus = "blocked"
            ProgressionState = "stop"
            StopReasonCode = "qa_evidence_incomplete"
        }
    }

    return [pscustomobject]@{
        MilestoneStatus = "passed"
        ProgressionState = "continue"
        StopReasonCode = $null
    }
}

function Validate-QAObservationFields {
    param(
        [Parameter(Mandatory = $true)]
        $QAObservation,
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory
    )

    $foundation = Get-MilestoneAutocycleFoundationContract
    $contract = Get-MilestoneAutocycleQAObservationContract

    foreach ($fieldName in @($foundation.qa_observation_required_fields)) {
        Get-RequiredProperty -Object $QAObservation -Name $fieldName -Context "Milestone QA observation" | Out-Null
    }
    foreach ($fieldName in @($contract.required_fields)) {
        Get-RequiredProperty -Object $QAObservation -Name $fieldName -Context "Milestone QA observation" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QAObservation -Name "contract_version" -Context "Milestone QA observation") -Context "Milestone QA observation.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "Milestone QA observation.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QAObservation -Name "record_type" -Context "Milestone QA observation") -Context "Milestone QA observation.record_type"
    if ($recordType -ne $foundation.qa_observation_record_type -or $recordType -ne $contract.record_type) {
        throw "Milestone QA observation.record_type must equal '$($foundation.qa_observation_record_type)'."
    }

    $qaObservationId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QAObservation -Name "qa_observation_id" -Context "Milestone QA observation") -Context "Milestone QA observation.qa_observation_id"
    $cycleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QAObservation -Name "cycle_id" -Context "Milestone QA observation") -Context "Milestone QA observation.cycle_id"
    $dispatchId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QAObservation -Name "dispatch_id" -Context "Milestone QA observation") -Context "Milestone QA observation.dispatch_id"
    $evidenceBundleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QAObservation -Name "evidence_bundle_id" -Context "Milestone QA observation") -Context "Milestone QA observation.evidence_bundle_id"
    $taskId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QAObservation -Name "task_id" -Context "Milestone QA observation") -Context "Milestone QA observation.task_id"
    $executorType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QAObservation -Name "executor_type" -Context "Milestone QA observation") -Context "Milestone QA observation.executor_type"
    $baselineId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QAObservation -Name "baseline_id" -Context "Milestone QA observation") -Context "Milestone QA observation.baseline_id"

    foreach ($pair in @(
            @{ Value = $qaObservationId; Context = "Milestone QA observation.qa_observation_id" },
            @{ Value = $cycleId; Context = "Milestone QA observation.cycle_id" },
            @{ Value = $dispatchId; Context = "Milestone QA observation.dispatch_id" },
            @{ Value = $evidenceBundleId; Context = "Milestone QA observation.evidence_bundle_id" },
            @{ Value = $taskId; Context = "Milestone QA observation.task_id" },
            @{ Value = $baselineId; Context = "Milestone QA observation.baseline_id" }
        )) {
        Assert-RegexMatch -Value $pair.Value -Pattern $foundation.identifier_pattern -Context $pair.Context
    }

    Assert-AllowedValue -Value $executorType -AllowedValues @($foundation.allowed_executor_types) -Context "Milestone QA observation.executor_type"

    $executionEvidencePath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QAObservation -Name "execution_evidence_ref" -Context "Milestone QA observation") -Context "Milestone QA observation.execution_evidence_ref") -Label "Milestone QA observation execution evidence"
    $executionEvidenceInput = Resolve-ExecutionEvidenceInput -EvidenceBundlePath $executionEvidencePath

    if ($evidenceBundleId -ne $executionEvidenceInput.Validation.EvidenceBundleId) {
        throw "Milestone QA observation.evidence_bundle_id must match the referenced execution evidence bundle."
    }
    if ($cycleId -ne $executionEvidenceInput.Validation.CycleId) {
        throw "Milestone QA observation.cycle_id must match the referenced execution evidence cycle_id."
    }
    if ($dispatchId -ne $executionEvidenceInput.Validation.DispatchId) {
        throw "Milestone QA observation.dispatch_id must match the referenced execution evidence dispatch_id."
    }
    if ($taskId -ne $executionEvidenceInput.Validation.TaskId) {
        throw "Milestone QA observation.task_id must match the referenced execution evidence task_id."
    }
    if ($executorType -ne $executionEvidenceInput.Validation.ExecutorType) {
        throw "Milestone QA observation.executor_type must match the referenced execution evidence executor_type."
    }
    if ($baselineId -ne $executionEvidenceInput.Validation.BaselineId) {
        throw "Milestone QA observation.baseline_id must match the pinned baseline id from the referenced execution evidence."
    }

    $baselineBindingPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QAObservation -Name "baseline_binding_ref" -Context "Milestone QA observation") -Context "Milestone QA observation.baseline_binding_ref") -Label "Milestone QA observation baseline binding"
    if ($baselineBindingPath -ne $executionEvidenceInput.Validation.BindingPath) {
        throw "Milestone QA observation.baseline_binding_ref must match the referenced execution evidence baseline binding."
    }

    $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QAObservation -Name "status" -Context "Milestone QA observation") -Context "Milestone QA observation.status"
    Assert-AllowedValue -Value $status -AllowedValues @($foundation.allowed_qa_statuses) -Context "Milestone QA observation.status"
    Assert-AllowedValue -Value $status -AllowedValues @($contract.allowed_statuses) -Context "Milestone QA observation.status"

    $findings = [object[]](Validate-QAFindings -Findings (Get-RequiredProperty -Object $QAObservation -Name "findings" -Context "Milestone QA observation"))
    $evidenceRefs = [object[]](Validate-QAEvidenceRefs -EvidenceRefs (Get-RequiredProperty -Object $QAObservation -Name "evidence_refs" -Context "Milestone QA observation") -RepositoryRoot $executionEvidenceInput.Validation.RepositoryRoot -Context "Milestone QA observation.evidence_refs")
    $notes = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QAObservation -Name "notes" -Context "Milestone QA observation") -Context "Milestone QA observation.notes"

    return [pscustomobject]@{
        QAObservationId      = $qaObservationId
        CycleId              = $cycleId
        DispatchId           = $dispatchId
        EvidenceBundleId     = $evidenceBundleId
        TaskId               = $taskId
        ExecutorType         = $executorType
        BaselineId           = $baselineId
        BaselineBindingPath  = $executionEvidenceInput.Validation.BindingPath
        ExecutionEvidencePath = $executionEvidenceInput.Validation.EvidenceBundlePath
        RepositoryRoot       = $executionEvidenceInput.Validation.RepositoryRoot
        Status               = $status
        Findings             = $findings
        EvidenceRefs         = $evidenceRefs
        Notes                = $notes
    }
}

function Test-MilestoneAutocycleQAObservationContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$QAObservationPath
    )

    $resolvedQAObservationPath = Resolve-ExistingPath -PathValue $QAObservationPath -Label "Milestone QA observation"
    $qaObservation = Get-JsonDocument -Path $resolvedQAObservationPath -Label "Milestone QA observation"
    $result = Validate-QAObservationFields -QAObservation $qaObservation -BaseDirectory (Split-Path -Parent $resolvedQAObservationPath)

    return [pscustomobject]@{
        IsValid              = $true
        QAObservationId      = $result.QAObservationId
        CycleId              = $result.CycleId
        DispatchId           = $result.DispatchId
        EvidenceBundleId     = $result.EvidenceBundleId
        TaskId               = $result.TaskId
        ExecutorType         = $result.ExecutorType
        BaselineId           = $result.BaselineId
        BaselineBindingPath  = $result.BaselineBindingPath
        ExecutionEvidencePath = $result.ExecutionEvidencePath
        RepositoryRoot       = $result.RepositoryRoot
        Status               = $result.Status
        QAObservationPath    = $resolvedQAObservationPath
    }
}

function Validate-QAAggregationTaskResults {
    param(
        [AllowNull()]
        $TaskResults,
        [Parameter(Mandatory = $true)]
        [string]$CycleId,
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory
    )

    $foundation = Get-MilestoneAutocycleFoundationContract
    $contract = Get-MilestoneAutocycleQAAggregationContract
    $items = [object[]](Assert-ObjectArray -Value $TaskResults -Context "Milestone QA aggregation.task_results")
    $normalizedItems = @()
    foreach ($item in $items) {
        foreach ($fieldName in @($contract.task_result_required_fields)) {
            Get-RequiredProperty -Object $item -Name $fieldName -Context "Milestone QA aggregation.task_results item" | Out-Null
        }

        $taskId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "task_id" -Context "Milestone QA aggregation.task_results item") -Context "Milestone QA aggregation.task_results item.task_id"
        $dispatchId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "dispatch_id" -Context "Milestone QA aggregation.task_results item") -Context "Milestone QA aggregation.task_results item.dispatch_id"
        $qaObservationId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "qa_observation_id" -Context "Milestone QA aggregation.task_results item") -Context "Milestone QA aggregation.task_results item.qa_observation_id"
        $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "status" -Context "Milestone QA aggregation.task_results item") -Context "Milestone QA aggregation.task_results item.status"

        foreach ($pair in @(
                @{ Value = $taskId; Context = "Milestone QA aggregation.task_results item.task_id" },
                @{ Value = $dispatchId; Context = "Milestone QA aggregation.task_results item.dispatch_id" },
                @{ Value = $qaObservationId; Context = "Milestone QA aggregation.task_results item.qa_observation_id" }
            )) {
            Assert-RegexMatch -Value $pair.Value -Pattern $foundation.identifier_pattern -Context $pair.Context
        }

        Assert-AllowedValue -Value $status -AllowedValues @((Get-MilestoneAutocycleQAObservationContract).allowed_statuses) -Context "Milestone QA aggregation.task_results item.status"
        $qaObservationPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "qa_observation_ref" -Context "Milestone QA aggregation.task_results item") -Context "Milestone QA aggregation.task_results item.qa_observation_ref") -Label "Milestone QA aggregation QA observation"
        $qaObservationValidation = Test-MilestoneAutocycleQAObservationContract -QAObservationPath $qaObservationPath

        if ($qaObservationValidation.CycleId -ne $CycleId) {
            throw "Milestone QA aggregation.task_results item must reference QA observations from the same cycle_id."
        }
        if ($qaObservationValidation.TaskId -ne $taskId) {
            throw "Milestone QA aggregation.task_results item.task_id must match the referenced QA observation task_id."
        }
        if ($qaObservationValidation.DispatchId -ne $dispatchId) {
            throw "Milestone QA aggregation.task_results item.dispatch_id must match the referenced QA observation dispatch_id."
        }
        if ($qaObservationValidation.QAObservationId -ne $qaObservationId) {
            throw "Milestone QA aggregation.task_results item.qa_observation_id must match the referenced QA observation id."
        }
        if ($qaObservationValidation.Status -ne $status) {
            throw "Milestone QA aggregation.task_results item.status must match the referenced QA observation status."
        }

        $normalizedItems += [pscustomobject]@{
            task_id           = $taskId
            dispatch_id       = $dispatchId
            qa_observation_id = $qaObservationId
            qa_observation_ref = Get-RelativeReference -BaseDirectory $BaseDirectory -TargetPath $qaObservationValidation.QAObservationPath
            status            = $status
        }
    }

    Write-Output -NoEnumerate $normalizedItems
}

function Validate-QAAggregationFields {
    param(
        [Parameter(Mandatory = $true)]
        $QAAggregation,
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory
    )

    $foundation = Get-MilestoneAutocycleFoundationContract
    $contract = Get-MilestoneAutocycleQAAggregationContract

    foreach ($fieldName in @($foundation.qa_aggregation_required_fields)) {
        Get-RequiredProperty -Object $QAAggregation -Name $fieldName -Context "Milestone QA aggregation" | Out-Null
    }
    foreach ($fieldName in @($contract.required_fields)) {
        Get-RequiredProperty -Object $QAAggregation -Name $fieldName -Context "Milestone QA aggregation" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QAAggregation -Name "contract_version" -Context "Milestone QA aggregation") -Context "Milestone QA aggregation.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "Milestone QA aggregation.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QAAggregation -Name "record_type" -Context "Milestone QA aggregation") -Context "Milestone QA aggregation.record_type"
    if ($recordType -ne $foundation.qa_aggregation_record_type -or $recordType -ne $contract.record_type) {
        throw "Milestone QA aggregation.record_type must equal '$($foundation.qa_aggregation_record_type)'."
    }

    $aggregationId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QAAggregation -Name "aggregation_id" -Context "Milestone QA aggregation") -Context "Milestone QA aggregation.aggregation_id"
    $cycleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QAAggregation -Name "cycle_id" -Context "Milestone QA aggregation") -Context "Milestone QA aggregation.cycle_id"
    Assert-RegexMatch -Value $aggregationId -Pattern $foundation.identifier_pattern -Context "Milestone QA aggregation.aggregation_id"
    Assert-RegexMatch -Value $cycleId -Pattern $foundation.identifier_pattern -Context "Milestone QA aggregation.cycle_id"

    $milestoneStatus = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QAAggregation -Name "milestone_status" -Context "Milestone QA aggregation") -Context "Milestone QA aggregation.milestone_status"
    Assert-AllowedValue -Value $milestoneStatus -AllowedValues @($contract.allowed_milestone_statuses) -Context "Milestone QA aggregation.milestone_status"

    $progressionState = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QAAggregation -Name "progression_state" -Context "Milestone QA aggregation") -Context "Milestone QA aggregation.progression_state"
    Assert-AllowedValue -Value $progressionState -AllowedValues @($contract.allowed_progression_states) -Context "Milestone QA aggregation.progression_state"

    $stopReasonCode = Get-RequiredProperty -Object $QAAggregation -Name "stop_reason_code" -Context "Milestone QA aggregation"
    if ($null -ne $stopReasonCode) {
        $stopReasonCode = Assert-NonEmptyString -Value $stopReasonCode -Context "Milestone QA aggregation.stop_reason_code"
        Assert-AllowedValue -Value $stopReasonCode -AllowedValues @($foundation.allowed_stop_reason_codes) -Context "Milestone QA aggregation.stop_reason_code"
    }

    $taskResults = [object[]](Validate-QAAggregationTaskResults -TaskResults (Get-RequiredProperty -Object $QAAggregation -Name "task_results" -Context "Milestone QA aggregation") -CycleId $cycleId -BaseDirectory $BaseDirectory)
    $expectedRollupState = Get-QAAggregationRollupState -TaskResults $taskResults
    if ($milestoneStatus -ne $expectedRollupState.MilestoneStatus) {
        throw "Milestone QA aggregation.milestone_status must reflect the rolled-up task QA state."
    }
    if ($progressionState -ne $expectedRollupState.ProgressionState) {
        throw "Milestone QA aggregation.progression_state must reflect the rolled-up task QA state."
    }
    if ($expectedRollupState.StopReasonCode) {
        if ($stopReasonCode -ne $expectedRollupState.StopReasonCode) {
            throw "Milestone QA aggregation.stop_reason_code must reflect the rolled-up task QA state."
        }
    }
    elseif ($null -ne $stopReasonCode) {
        throw "Milestone QA aggregation.stop_reason_code must be null when milestone_status is 'passed'."
    }

    $notes = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QAAggregation -Name "notes" -Context "Milestone QA aggregation") -Context "Milestone QA aggregation.notes"

    return [pscustomobject]@{
        AggregationId     = $aggregationId
        CycleId           = $cycleId
        MilestoneStatus   = $milestoneStatus
        ProgressionState  = $progressionState
        StopReasonCode    = $stopReasonCode
        TaskResults       = $taskResults
        Notes             = $notes
    }
}

function Test-MilestoneAutocycleQAAggregationContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$QAAggregationPath
    )

    $resolvedQAAggregationPath = Resolve-ExistingPath -PathValue $QAAggregationPath -Label "Milestone QA aggregation"
    $qaAggregation = Get-JsonDocument -Path $resolvedQAAggregationPath -Label "Milestone QA aggregation"
    $result = Validate-QAAggregationFields -QAAggregation $qaAggregation -BaseDirectory (Split-Path -Parent $resolvedQAAggregationPath)

    return [pscustomobject]@{
        IsValid           = $true
        AggregationId     = $result.AggregationId
        CycleId           = $result.CycleId
        MilestoneStatus   = $result.MilestoneStatus
        ProgressionState  = $result.ProgressionState
        StopReasonCode    = $result.StopReasonCode
        TaskResults       = $result.TaskResults
        QAAggregationPath = $resolvedQAAggregationPath
    }
}

function Invoke-MilestoneAutocycleQAObservationFlow {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$EvidenceBundlePath,
        [Parameter(Mandatory = $true)]
        [string]$Status,
        [Parameter(Mandatory = $true)]
        $Findings,
        [Parameter(Mandatory = $true)]
        $EvidenceRefs,
        [Parameter(Mandatory = $true)]
        [string]$OutputRoot,
        [string]$QAObservationId,
        [string]$AggregationId,
        [string]$Notes = "Bounded QA observation created from one governed execution-evidence bundle only.",
        [string]$AggregationNotes = "Milestone-visible QA aggregation updated from one bounded QA observation only."
    )

    $foundation = Get-MilestoneAutocycleFoundationContract
    $qaObservationContract = Get-MilestoneAutocycleQAObservationContract
    $executionEvidenceInput = Resolve-ExecutionEvidenceInput -EvidenceBundlePath $EvidenceBundlePath

    $status = Assert-NonEmptyString -Value $Status -Context "Status"
    Assert-AllowedValue -Value $status -AllowedValues @($foundation.allowed_qa_statuses) -Context "Status"
    Assert-AllowedValue -Value $status -AllowedValues @($qaObservationContract.allowed_statuses) -Context "Status"

    $normalizedFindings = [object[]](Validate-QAFindings -Findings $Findings)
    $normalizedEvidenceRefs = [object[]](Validate-QAEvidenceRefs -EvidenceRefs $EvidenceRefs -RepositoryRoot $executionEvidenceInput.Validation.RepositoryRoot -Context "Milestone QA observation.evidence_refs")
    Assert-NonEmptyString -Value $Notes -Context "Notes" | Out-Null
    Assert-NonEmptyString -Value $AggregationNotes -Context "AggregationNotes" | Out-Null

    $resolvedOutputRoot = Resolve-PathForCreationInsideRepository -PathValue $OutputRoot -RepositoryRoot $executionEvidenceInput.Validation.RepositoryRoot -Label "Milestone QA output root"
    $qaObservationDirectory = Join-Path $resolvedOutputRoot "qa_observations"
    $qaAggregationDirectory = Join-Path $resolvedOutputRoot "qa_aggregations"
    New-Item -ItemType Directory -Path $qaObservationDirectory -Force | Out-Null
    New-Item -ItemType Directory -Path $qaAggregationDirectory -Force | Out-Null

    if ([string]::IsNullOrWhiteSpace($QAObservationId)) {
        $QAObservationId = "qa-observation-{0}" -f $executionEvidenceInput.Validation.DispatchId
    }
    if ([string]::IsNullOrWhiteSpace($AggregationId)) {
        $AggregationId = "qa-aggregation-{0}" -f $executionEvidenceInput.Validation.CycleId
    }

    Assert-RegexMatch -Value $QAObservationId -Pattern $foundation.identifier_pattern -Context "QAObservationId"
    Assert-RegexMatch -Value $AggregationId -Pattern $foundation.identifier_pattern -Context "AggregationId"

    $qaObservationPath = Join-Path $qaObservationDirectory ("{0}.json" -f $QAObservationId)
    if (Test-Path -LiteralPath $qaObservationPath) {
        throw "Milestone QA observation id '$QAObservationId' already exists."
    }

    $qaObservation = [pscustomobject]@{
        contract_version     = $foundation.contract_version
        record_type          = $foundation.qa_observation_record_type
        qa_observation_id    = $QAObservationId
        cycle_id             = $executionEvidenceInput.Validation.CycleId
        dispatch_id          = $executionEvidenceInput.Validation.DispatchId
        execution_evidence_ref = Get-RelativeReference -BaseDirectory $qaObservationDirectory -TargetPath $executionEvidenceInput.Validation.EvidenceBundlePath
        evidence_bundle_id   = $executionEvidenceInput.Validation.EvidenceBundleId
        task_id              = $executionEvidenceInput.Validation.TaskId
        executor_type        = $executionEvidenceInput.Validation.ExecutorType
        baseline_binding_ref = Get-RelativeReference -BaseDirectory $qaObservationDirectory -TargetPath $executionEvidenceInput.Validation.BindingPath
        baseline_id          = $executionEvidenceInput.Validation.BaselineId
        status               = $status
        findings             = @($normalizedFindings)
        evidence_refs        = @($normalizedEvidenceRefs)
        notes                = $Notes
    }

    Write-JsonDocument -Path $qaObservationPath -Document $qaObservation
    $qaObservationValidation = Test-MilestoneAutocycleQAObservationContract -QAObservationPath $qaObservationPath

    $qaAggregationPath = Join-Path $qaAggregationDirectory ("{0}.json" -f $AggregationId)
    $taskResults = @()
    if (Test-Path -LiteralPath $qaAggregationPath) {
        $existingAggregationValidation = Test-MilestoneAutocycleQAAggregationContract -QAAggregationPath $qaAggregationPath
        $existingAggregation = Get-JsonDocument -Path $existingAggregationValidation.QAAggregationPath -Label "Milestone QA aggregation"
        $taskResults = @($existingAggregation.task_results | Where-Object { $_.task_id -ne $qaObservationValidation.TaskId })
    }

    $taskResults += [pscustomobject]@{
        task_id           = $qaObservationValidation.TaskId
        dispatch_id       = $qaObservationValidation.DispatchId
        qa_observation_id = $qaObservationValidation.QAObservationId
        qa_observation_ref = Get-RelativeReference -BaseDirectory $qaAggregationDirectory -TargetPath $qaObservationValidation.QAObservationPath
        status            = $qaObservationValidation.Status
    }

    $rollupState = Get-QAAggregationRollupState -TaskResults @($taskResults)
    $qaAggregation = [pscustomobject]@{
        contract_version = $foundation.contract_version
        record_type      = $foundation.qa_aggregation_record_type
        aggregation_id   = $AggregationId
        cycle_id         = $qaObservationValidation.CycleId
        milestone_status = $rollupState.MilestoneStatus
        progression_state = $rollupState.ProgressionState
        stop_reason_code = $rollupState.StopReasonCode
        task_results     = @($taskResults)
        notes            = $AggregationNotes
    }

    Write-JsonDocument -Path $qaAggregationPath -Document $qaAggregation
    $qaAggregationValidation = Test-MilestoneAutocycleQAAggregationContract -QAAggregationPath $qaAggregationPath

    return [pscustomobject]@{
        QAObservationValidation = $qaObservationValidation
        QAAggregationValidation = $qaAggregationValidation
        QAObservationPath       = $qaObservationValidation.QAObservationPath
        QAAggregationPath       = $qaAggregationValidation.QAAggregationPath
        QAObservationId         = $qaObservationValidation.QAObservationId
        AggregationId           = $qaAggregationValidation.AggregationId
        CycleId                 = $qaObservationValidation.CycleId
        DispatchId              = $qaObservationValidation.DispatchId
        TaskId                  = $qaObservationValidation.TaskId
        BaselineId              = $qaObservationValidation.BaselineId
    }
}

Export-ModuleMember -Function Test-MilestoneAutocycleQAObservationContract, Test-MilestoneAutocycleQAAggregationContract, Invoke-MilestoneAutocycleQAObservationFlow
