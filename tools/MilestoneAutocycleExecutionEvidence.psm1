Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$milestoneDispatchModulePath = Join-Path $PSScriptRoot "MilestoneAutocycleDispatch.psm1"
$script:testMilestoneAutocycleDispatchContract = $null

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

function Get-UtcTimestamp {
    param(
        [datetime]$DateTime = (Get-Date).ToUniversalTime()
    )

    return $DateTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
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

function Assert-NullableTimestampValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($null -eq $Value) {
        return $null
    }

    $foundation = Get-MilestoneAutocycleFoundationContract
    $timestamp = Assert-NonEmptyString -Value $Value -Context $Context
    Assert-RegexMatch -Value $timestamp -Pattern $foundation.timestamp_pattern -Context $Context
    return $timestamp
}

function Get-MilestoneAutocycleFoundationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_autocycle\foundation.contract.json") -Label "Milestone autocycle foundation contract"
}

function Get-MilestoneAutocycleRunLedgerContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_autocycle\run_ledger.contract.json") -Label "Milestone autocycle run ledger contract"
}

function Get-MilestoneAutocycleExecutionEvidenceContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_autocycle\execution_evidence.contract.json") -Label "Milestone autocycle execution evidence contract"
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
        throw "Milestone execution evidence requires dependency module '$DependencyLabel' at '$ModulePath'."
    }

    try {
        $module = Import-Module $ModulePath -Force -PassThru -ErrorAction Stop
    }
    catch {
        throw "Milestone execution evidence requires dependency module '$DependencyLabel' to load successfully. $($_.Exception.Message)"
    }

    $command = $module.ExportedCommands[$CommandName]
    if ($null -eq $command) {
        throw "Milestone execution evidence requires dependency command '$CommandName' from dependency module '$DependencyLabel'."
    }

    return $command
}

function Get-MilestoneAutocycleDispatchValidatorCommand {
    if ($null -eq $script:testMilestoneAutocycleDispatchContract) {
        $script:testMilestoneAutocycleDispatchContract = Get-RequiredDependencyCommand -ModulePath $milestoneDispatchModulePath -DependencyLabel "MilestoneAutocycleDispatch" -CommandName "Test-MilestoneAutocycleDispatchContract"
    }

    return $script:testMilestoneAutocycleDispatchContract
}

function Resolve-DispatchInput {
    param(
        [Parameter(Mandatory = $true)]
        [string]$DispatchPath
    )

    $dispatchValidator = Get-MilestoneAutocycleDispatchValidatorCommand
    $dispatchValidation = & $dispatchValidator -DispatchPath $DispatchPath
    $dispatch = Get-JsonDocument -Path $dispatchValidation.DispatchPath -Label "Milestone execution evidence dispatch"

    return [pscustomobject]@{
        Validation = $dispatchValidation
        Dispatch   = $dispatch
    }
}

function Validate-RunLedgerFieldsForEvidence {
    param(
        [Parameter(Mandatory = $true)]
        $Ledger,
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory
    )

    $foundation = Get-MilestoneAutocycleFoundationContract
    $ledgerContract = Get-MilestoneAutocycleRunLedgerContract

    foreach ($fieldName in @($foundation.run_ledger_required_fields)) {
        Get-RequiredProperty -Object $Ledger -Name $fieldName -Context "Milestone run ledger" | Out-Null
    }
    foreach ($fieldName in @($ledgerContract.required_fields)) {
        Get-RequiredProperty -Object $Ledger -Name $fieldName -Context "Milestone run ledger" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "contract_version" -Context "Milestone run ledger") -Context "Milestone run ledger.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "Milestone run ledger.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "record_type" -Context "Milestone run ledger") -Context "Milestone run ledger.record_type"
    if ($recordType -ne $foundation.run_ledger_record_type -or $recordType -ne $ledgerContract.record_type) {
        throw "Milestone run ledger.record_type must equal '$($foundation.run_ledger_record_type)'."
    }

    $ledgerId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "ledger_id" -Context "Milestone run ledger") -Context "Milestone run ledger.ledger_id"
    $cycleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "cycle_id" -Context "Milestone run ledger") -Context "Milestone run ledger.cycle_id"
    $dispatchId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "dispatch_id" -Context "Milestone run ledger") -Context "Milestone run ledger.dispatch_id"
    $taskId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "task_id" -Context "Milestone run ledger") -Context "Milestone run ledger.task_id"
    $executorType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "executor_type" -Context "Milestone run ledger") -Context "Milestone run ledger.executor_type"
    $baselineId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "baseline_id" -Context "Milestone run ledger") -Context "Milestone run ledger.baseline_id"

    foreach ($pair in @(
            @{ Value = $ledgerId; Context = "Milestone run ledger.ledger_id" },
            @{ Value = $cycleId; Context = "Milestone run ledger.cycle_id" },
            @{ Value = $dispatchId; Context = "Milestone run ledger.dispatch_id" },
            @{ Value = $taskId; Context = "Milestone run ledger.task_id" },
            @{ Value = $baselineId; Context = "Milestone run ledger.baseline_id" }
        )) {
        Assert-RegexMatch -Value $pair.Value -Pattern $foundation.identifier_pattern -Context $pair.Context
    }

    Assert-AllowedValue -Value $executorType -AllowedValues @($foundation.allowed_executor_types) -Context "Milestone run ledger.executor_type"

    $dispatchPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "dispatch_ref" -Context "Milestone run ledger") -Context "Milestone run ledger.dispatch_ref") -Label "Milestone run ledger dispatch"
    $bindingPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "baseline_binding_ref" -Context "Milestone run ledger") -Context "Milestone run ledger.baseline_binding_ref") -Label "Milestone run ledger baseline binding"

    $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "status" -Context "Milestone run ledger") -Context "Milestone run ledger.status"
    Assert-AllowedValue -Value $status -AllowedValues @($foundation.allowed_dispatch_statuses) -Context "Milestone run ledger.status"

    $startedAt = Assert-NullableTimestampValue -Value (Get-RequiredProperty -Object $Ledger -Name "started_at" -Context "Milestone run ledger") -Context "Milestone run ledger.started_at"
    $completedAt = Assert-NullableTimestampValue -Value (Get-RequiredProperty -Object $Ledger -Name "completed_at" -Context "Milestone run ledger") -Context "Milestone run ledger.completed_at"

    switch ($status) {
        "not_started" {
            if ($null -ne $startedAt -or $null -ne $completedAt) {
                throw "Milestone run ledger in status 'not_started' must keep started_at and completed_at null."
            }
        }
        "in_progress" {
            if ($null -eq $startedAt -or $null -ne $completedAt) {
                throw "Milestone run ledger in status 'in_progress' must set started_at and keep completed_at null."
            }
        }
        "completed" {
            if ($null -eq $startedAt -or $null -eq $completedAt) {
                throw "Milestone run ledger in status 'completed' must set started_at and completed_at."
            }
        }
        "failed" {
            if ($null -eq $startedAt -or $null -eq $completedAt) {
                throw "Milestone run ledger in status 'failed' must set started_at and completed_at."
            }
        }
        "refused" {
            if ($null -ne $startedAt -or $null -eq $completedAt) {
                throw "Milestone run ledger in status 'refused' must keep started_at null and set completed_at."
            }
        }
    }

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "result_summary" -Context "Milestone run ledger") -Context "Milestone run ledger.result_summary" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "notes" -Context "Milestone run ledger") -Context "Milestone run ledger.notes" | Out-Null

    return [pscustomobject]@{
        LedgerId      = $ledgerId
        CycleId       = $cycleId
        DispatchId    = $dispatchId
        TaskId        = $taskId
        ExecutorType  = $executorType
        BaselineId    = $baselineId
        DispatchPath  = $dispatchPath
        BindingPath   = $bindingPath
        Status        = $status
        StartedAt     = $startedAt
        CompletedAt   = $completedAt
    }
}

function Resolve-RunLedgerInput {
    param(
        [Parameter(Mandatory = $true)]
        [string]$LedgerPath
    )

    $resolvedLedgerPath = Resolve-ExistingPath -PathValue $LedgerPath -Label "Milestone execution evidence run ledger"
    $ledger = Get-JsonDocument -Path $resolvedLedgerPath -Label "Milestone execution evidence run ledger"
    $validation = Validate-RunLedgerFieldsForEvidence -Ledger $ledger -BaseDirectory (Split-Path -Parent $resolvedLedgerPath)

    return [pscustomobject]@{
        Validation = $validation
        Ledger     = $ledger
        LedgerPath = $resolvedLedgerPath
    }
}

function Resolve-DispatchAndLedgerEvidenceInput {
    param(
        [Parameter(Mandatory = $true)]
        [string]$DispatchPath,
        [Parameter(Mandatory = $true)]
        [string]$LedgerPath
    )

    $dispatchInput = Resolve-DispatchInput -DispatchPath $DispatchPath
    $ledgerInput = Resolve-RunLedgerInput -LedgerPath $LedgerPath

    if (-not (Test-PathWithinRoot -Path $ledgerInput.LedgerPath -Root $dispatchInput.Validation.RepositoryRoot)) {
        throw "Milestone execution evidence run ledger must resolve inside the referenced dispatch repository root."
    }
    if ($ledgerInput.Validation.DispatchPath -ne $dispatchInput.Validation.DispatchPath) {
        throw "Milestone execution evidence requires dispatch and run ledger identity to match exactly."
    }
    if ($ledgerInput.Validation.CycleId -ne $dispatchInput.Validation.CycleId) {
        throw "Milestone execution evidence requires dispatch and run ledger cycle_id to match exactly."
    }
    if ($ledgerInput.Validation.DispatchId -ne $dispatchInput.Validation.DispatchId) {
        throw "Milestone execution evidence requires dispatch and run ledger dispatch_id to match exactly."
    }
    if ($ledgerInput.Validation.TaskId -ne $dispatchInput.Validation.TaskId) {
        throw "Milestone execution evidence requires dispatch and run ledger task_id to match exactly."
    }
    if ($ledgerInput.Validation.ExecutorType -ne $dispatchInput.Validation.ExecutorType) {
        throw "Milestone execution evidence requires dispatch and run ledger executor_type to match exactly."
    }
    if ($ledgerInput.Validation.BaselineId -ne $dispatchInput.Validation.BaselineId) {
        throw "Milestone execution evidence requires dispatch and run ledger baseline_id to match exactly."
    }
    if ($ledgerInput.Validation.BindingPath -ne $dispatchInput.Validation.BindingPath) {
        throw "Milestone execution evidence requires dispatch and run ledger baseline_binding_ref to match exactly."
    }

    return [pscustomobject]@{
        DispatchInput   = $dispatchInput
        RunLedgerInput  = $ledgerInput
        RepositoryRoot  = $dispatchInput.Validation.RepositoryRoot
        DispatchPath    = $dispatchInput.Validation.DispatchPath
        LedgerPath      = $ledgerInput.LedgerPath
        BindingPath     = $dispatchInput.Validation.BindingPath
        CycleId         = $dispatchInput.Validation.CycleId
        DispatchId      = $dispatchInput.Validation.DispatchId
        LedgerId        = $ledgerInput.Validation.LedgerId
        TaskId          = $dispatchInput.Validation.TaskId
        ExecutorType    = $dispatchInput.Validation.ExecutorType
        BaselineId      = $dispatchInput.Validation.BaselineId
        DispatchStatus  = $dispatchInput.Validation.Status
        LedgerStatus    = $ledgerInput.Validation.Status
    }
}

function Assert-ExecutionEvidenceReadyState {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$DispatchAndLedgerInput
    )

    $contract = Get-MilestoneAutocycleExecutionEvidenceContract
    if ($contract.terminal_dispatch_statuses -notcontains $DispatchAndLedgerInput.DispatchStatus) {
        throw "Milestone execution evidence requires the referenced dispatch status to be 'completed' before evidence assembly."
    }
    if ($contract.terminal_ledger_statuses -notcontains $DispatchAndLedgerInput.LedgerStatus) {
        throw "Milestone execution evidence requires the referenced run ledger status to be 'completed' before evidence assembly."
    }
}

function Validate-ChangedFiles {
    param(
        [AllowNull()]
        $ChangedFiles,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $contract = Get-MilestoneAutocycleExecutionEvidenceContract
    $items = [object[]](Assert-ObjectArray -Value $ChangedFiles -Context "Milestone execution evidence.changed_files")
    $normalizedItems = @()
    foreach ($item in $items) {
        foreach ($fieldName in @($contract.changed_file_required_fields)) {
            Get-RequiredProperty -Object $item -Name $fieldName -Context "Milestone execution evidence.changed_files item" | Out-Null
        }

        $resolvedPath = Resolve-RepositoryReferenceInput -Value (Get-RequiredProperty -Object $item -Name "path" -Context "Milestone execution evidence.changed_files item") -RepositoryRoot $RepositoryRoot -Context "Milestone execution evidence.changed_files item.path"
        $changeKind = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "change_kind" -Context "Milestone execution evidence.changed_files item") -Context "Milestone execution evidence.changed_files item.change_kind"
        $notes = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "notes" -Context "Milestone execution evidence.changed_files item") -Context "Milestone execution evidence.changed_files item.notes"

        $normalizedItems += [pscustomobject]@{
            path        = $resolvedPath.RelativePath
            change_kind = $changeKind
            notes       = $notes
        }
    }

    Write-Output -NoEnumerate $normalizedItems
}

function Validate-ProducedArtifacts {
    param(
        [AllowNull()]
        $ProducedArtifacts,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $contract = Get-MilestoneAutocycleExecutionEvidenceContract
    $items = [object[]](Assert-ObjectArray -Value $ProducedArtifacts -Context "Milestone execution evidence.produced_artifacts")
    $normalizedItems = @()
    foreach ($item in $items) {
        foreach ($fieldName in @($contract.produced_artifact_required_fields)) {
            Get-RequiredProperty -Object $item -Name $fieldName -Context "Milestone execution evidence.produced_artifacts item" | Out-Null
        }

        $kind = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "kind" -Context "Milestone execution evidence.produced_artifacts item") -Context "Milestone execution evidence.produced_artifacts item.kind"
        $pathValue = Resolve-RepositoryReferenceInput -Value (Get-RequiredProperty -Object $item -Name "path" -Context "Milestone execution evidence.produced_artifacts item") -RepositoryRoot $RepositoryRoot -Context "Milestone execution evidence.produced_artifacts item.path" -RequireExisting
        $notes = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "notes" -Context "Milestone execution evidence.produced_artifacts item") -Context "Milestone execution evidence.produced_artifacts item.notes"

        $normalizedItems += [pscustomobject]@{
            kind  = $kind
            path  = $pathValue.RelativePath
            notes = $notes
        }
    }

    Write-Output -NoEnumerate $normalizedItems
}

function Validate-TestOutputs {
    param(
        [AllowNull()]
        $TestOutputs,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $contract = Get-MilestoneAutocycleExecutionEvidenceContract
    $items = [object[]](Assert-ObjectArray -Value $TestOutputs -Context "Milestone execution evidence.test_outputs")
    $normalizedItems = @()
    foreach ($item in $items) {
        foreach ($fieldName in @($contract.test_output_required_fields)) {
            Get-RequiredProperty -Object $item -Name $fieldName -Context "Milestone execution evidence.test_outputs item" | Out-Null
        }

        $kind = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "kind" -Context "Milestone execution evidence.test_outputs item") -Context "Milestone execution evidence.test_outputs item.kind"
        $reference = Resolve-RepositoryReferenceInput -Value (Get-RequiredProperty -Object $item -Name "ref" -Context "Milestone execution evidence.test_outputs item") -RepositoryRoot $RepositoryRoot -Context "Milestone execution evidence.test_outputs item.ref" -RequireExisting
        $notes = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "notes" -Context "Milestone execution evidence.test_outputs item") -Context "Milestone execution evidence.test_outputs item.notes"

        $normalizedItems += [pscustomobject]@{
            kind  = $kind
            ref   = $reference.RelativePath
            notes = $notes
        }
    }

    Write-Output -NoEnumerate $normalizedItems
}

function Validate-EvidenceRefs {
    param(
        [AllowNull()]
        $EvidenceRefs,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $contract = Get-MilestoneAutocycleExecutionEvidenceContract
    $items = [object[]](Assert-ObjectArray -Value $EvidenceRefs -Context "Milestone execution evidence.evidence_refs")
    $normalizedItems = @()
    foreach ($item in $items) {
        foreach ($fieldName in @($contract.evidence_ref_required_fields)) {
            Get-RequiredProperty -Object $item -Name $fieldName -Context "Milestone execution evidence.evidence_refs item" | Out-Null
        }

        $kind = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "kind" -Context "Milestone execution evidence.evidence_refs item") -Context "Milestone execution evidence.evidence_refs item.kind"
        $reference = Resolve-RepositoryReferenceInput -Value (Get-RequiredProperty -Object $item -Name "ref" -Context "Milestone execution evidence.evidence_refs item") -RepositoryRoot $RepositoryRoot -Context "Milestone execution evidence.evidence_refs item.ref" -RequireExisting
        $notes = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "notes" -Context "Milestone execution evidence.evidence_refs item") -Context "Milestone execution evidence.evidence_refs item.notes"

        $normalizedItems += [pscustomobject]@{
            kind  = $kind
            ref   = $reference.RelativePath
            notes = $notes
        }
    }

    Write-Output -NoEnumerate $normalizedItems
}

function Validate-ExecutionEvidenceBundleFields {
    param(
        [Parameter(Mandatory = $true)]
        $ExecutionEvidence,
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory
    )

    $foundation = Get-MilestoneAutocycleFoundationContract
    $contract = Get-MilestoneAutocycleExecutionEvidenceContract

    foreach ($fieldName in @($foundation.execution_evidence_required_fields)) {
        Get-RequiredProperty -Object $ExecutionEvidence -Name $fieldName -Context "Milestone execution evidence" | Out-Null
    }
    foreach ($fieldName in @($contract.required_fields)) {
        Get-RequiredProperty -Object $ExecutionEvidence -Name $fieldName -Context "Milestone execution evidence" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ExecutionEvidence -Name "contract_version" -Context "Milestone execution evidence") -Context "Milestone execution evidence.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "Milestone execution evidence.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ExecutionEvidence -Name "record_type" -Context "Milestone execution evidence") -Context "Milestone execution evidence.record_type"
    if ($recordType -ne $foundation.execution_evidence_record_type -or $recordType -ne $contract.record_type) {
        throw "Milestone execution evidence.record_type must equal '$($foundation.execution_evidence_record_type)'."
    }

    $evidenceBundleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ExecutionEvidence -Name "evidence_bundle_id" -Context "Milestone execution evidence") -Context "Milestone execution evidence.evidence_bundle_id"
    $cycleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ExecutionEvidence -Name "cycle_id" -Context "Milestone execution evidence") -Context "Milestone execution evidence.cycle_id"
    $dispatchId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ExecutionEvidence -Name "dispatch_id" -Context "Milestone execution evidence") -Context "Milestone execution evidence.dispatch_id"
    $runLedgerId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ExecutionEvidence -Name "run_ledger_id" -Context "Milestone execution evidence") -Context "Milestone execution evidence.run_ledger_id"
    $taskId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ExecutionEvidence -Name "task_id" -Context "Milestone execution evidence") -Context "Milestone execution evidence.task_id"
    $executorType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ExecutionEvidence -Name "executor_type" -Context "Milestone execution evidence") -Context "Milestone execution evidence.executor_type"
    $baselineId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ExecutionEvidence -Name "baseline_id" -Context "Milestone execution evidence") -Context "Milestone execution evidence.baseline_id"

    foreach ($pair in @(
            @{ Value = $evidenceBundleId; Context = "Milestone execution evidence.evidence_bundle_id" },
            @{ Value = $cycleId; Context = "Milestone execution evidence.cycle_id" },
            @{ Value = $dispatchId; Context = "Milestone execution evidence.dispatch_id" },
            @{ Value = $runLedgerId; Context = "Milestone execution evidence.run_ledger_id" },
            @{ Value = $taskId; Context = "Milestone execution evidence.task_id" },
            @{ Value = $baselineId; Context = "Milestone execution evidence.baseline_id" }
        )) {
        Assert-RegexMatch -Value $pair.Value -Pattern $foundation.identifier_pattern -Context $pair.Context
    }

    Assert-AllowedValue -Value $executorType -AllowedValues @($foundation.allowed_executor_types) -Context "Milestone execution evidence.executor_type"

    $dispatchPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ExecutionEvidence -Name "dispatch_ref" -Context "Milestone execution evidence") -Context "Milestone execution evidence.dispatch_ref") -Label "Milestone execution evidence dispatch"
    $ledgerPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ExecutionEvidence -Name "run_ledger_ref" -Context "Milestone execution evidence") -Context "Milestone execution evidence.run_ledger_ref") -Label "Milestone execution evidence run ledger"
    $bindingPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ExecutionEvidence -Name "baseline_binding_ref" -Context "Milestone execution evidence") -Context "Milestone execution evidence.baseline_binding_ref") -Label "Milestone execution evidence baseline binding"

    $dispatchAndLedgerInput = Resolve-DispatchAndLedgerEvidenceInput -DispatchPath $dispatchPath -LedgerPath $ledgerPath
    Assert-ExecutionEvidenceReadyState -DispatchAndLedgerInput $dispatchAndLedgerInput

    if ($cycleId -ne $dispatchAndLedgerInput.CycleId) {
        throw "Milestone execution evidence.cycle_id must match the referenced dispatch cycle_id."
    }
    if ($dispatchId -ne $dispatchAndLedgerInput.DispatchId) {
        throw "Milestone execution evidence.dispatch_id must match the referenced dispatch."
    }
    if ($runLedgerId -ne $dispatchAndLedgerInput.LedgerId) {
        throw "Milestone execution evidence.run_ledger_id must match the referenced run ledger."
    }
    if ($taskId -ne $dispatchAndLedgerInput.TaskId) {
        throw "Milestone execution evidence.task_id must match the pinned task id from the referenced dispatch."
    }
    if ($executorType -ne $dispatchAndLedgerInput.ExecutorType) {
        throw "Milestone execution evidence.executor_type must match the referenced dispatch executor_type."
    }
    if ($baselineId -ne $dispatchAndLedgerInput.BaselineId) {
        throw "Milestone execution evidence.baseline_id must match the pinned baseline id from the referenced dispatch."
    }
    if ($bindingPath -ne $dispatchAndLedgerInput.BindingPath) {
        throw "Milestone execution evidence.baseline_binding_ref must match the referenced dispatch baseline binding."
    }

    $changedFiles = [object[]](Validate-ChangedFiles -ChangedFiles (Get-RequiredProperty -Object $ExecutionEvidence -Name "changed_files" -Context "Milestone execution evidence") -RepositoryRoot $dispatchAndLedgerInput.RepositoryRoot)
    $producedArtifacts = [object[]](Validate-ProducedArtifacts -ProducedArtifacts (Get-RequiredProperty -Object $ExecutionEvidence -Name "produced_artifacts" -Context "Milestone execution evidence") -RepositoryRoot $dispatchAndLedgerInput.RepositoryRoot)
    $testOutputs = [object[]](Validate-TestOutputs -TestOutputs (Get-RequiredProperty -Object $ExecutionEvidence -Name "test_outputs" -Context "Milestone execution evidence") -RepositoryRoot $dispatchAndLedgerInput.RepositoryRoot)
    $evidenceRefs = [object[]](Validate-EvidenceRefs -EvidenceRefs (Get-RequiredProperty -Object $ExecutionEvidence -Name "evidence_refs" -Context "Milestone execution evidence") -RepositoryRoot $dispatchAndLedgerInput.RepositoryRoot)
    $notes = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ExecutionEvidence -Name "notes" -Context "Milestone execution evidence") -Context "Milestone execution evidence.notes"

    return [pscustomobject]@{
        EvidenceBundleId = $evidenceBundleId
        CycleId          = $cycleId
        DispatchId       = $dispatchId
        LedgerId         = $runLedgerId
        TaskId           = $taskId
        ExecutorType     = $executorType
        BaselineId       = $baselineId
        DispatchPath     = $dispatchAndLedgerInput.DispatchPath
        LedgerPath       = $dispatchAndLedgerInput.LedgerPath
        BindingPath      = $dispatchAndLedgerInput.BindingPath
        RepositoryRoot   = $dispatchAndLedgerInput.RepositoryRoot
        ChangedFiles     = $changedFiles
        ProducedArtifacts = $producedArtifacts
        TestOutputs      = $testOutputs
        EvidenceRefs     = $evidenceRefs
        Notes            = $notes
    }
}

function Test-MilestoneAutocycleExecutionEvidenceContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$EvidenceBundlePath
    )

    $resolvedEvidenceBundlePath = Resolve-ExistingPath -PathValue $EvidenceBundlePath -Label "Milestone execution evidence bundle"
    $executionEvidence = Get-JsonDocument -Path $resolvedEvidenceBundlePath -Label "Milestone execution evidence bundle"
    $result = Validate-ExecutionEvidenceBundleFields -ExecutionEvidence $executionEvidence -BaseDirectory (Split-Path -Parent $resolvedEvidenceBundlePath)

    return [pscustomobject]@{
        IsValid            = $true
        EvidenceBundleId   = $result.EvidenceBundleId
        CycleId            = $result.CycleId
        DispatchId         = $result.DispatchId
        LedgerId           = $result.LedgerId
        TaskId             = $result.TaskId
        ExecutorType       = $result.ExecutorType
        BaselineId         = $result.BaselineId
        DispatchPath       = $result.DispatchPath
        LedgerPath         = $result.LedgerPath
        BindingPath        = $result.BindingPath
        RepositoryRoot     = $result.RepositoryRoot
        EvidenceBundlePath = $resolvedEvidenceBundlePath
    }
}

function Invoke-MilestoneAutocycleExecutionEvidenceFlow {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$DispatchPath,
        [Parameter(Mandatory = $true)]
        [string]$LedgerPath,
        [Parameter(Mandatory = $true)]
        $ChangedFiles,
        [Parameter(Mandatory = $true)]
        $ProducedArtifacts,
        [Parameter(Mandatory = $true)]
        $TestOutputs,
        [Parameter(Mandatory = $true)]
        $EvidenceRefs,
        [Parameter(Mandatory = $true)]
        [string]$OutputRoot,
        [string]$EvidenceBundleId,
        [string]$Notes = "Governed execution evidence assembled from one completed dispatch and one completed run ledger only."
    )

    $foundation = Get-MilestoneAutocycleFoundationContract
    $dispatchAndLedgerInput = Resolve-DispatchAndLedgerEvidenceInput -DispatchPath $DispatchPath -LedgerPath $LedgerPath
    Assert-ExecutionEvidenceReadyState -DispatchAndLedgerInput $dispatchAndLedgerInput

    $normalizedChangedFiles = [object[]](Validate-ChangedFiles -ChangedFiles $ChangedFiles -RepositoryRoot $dispatchAndLedgerInput.RepositoryRoot)
    $normalizedProducedArtifacts = [object[]](Validate-ProducedArtifacts -ProducedArtifacts $ProducedArtifacts -RepositoryRoot $dispatchAndLedgerInput.RepositoryRoot)
    $normalizedTestOutputs = [object[]](Validate-TestOutputs -TestOutputs $TestOutputs -RepositoryRoot $dispatchAndLedgerInput.RepositoryRoot)
    $normalizedEvidenceRefs = [object[]](Validate-EvidenceRefs -EvidenceRefs $EvidenceRefs -RepositoryRoot $dispatchAndLedgerInput.RepositoryRoot)
    Assert-NonEmptyString -Value $Notes -Context "Notes" | Out-Null

    $resolvedOutputRoot = Resolve-PathForCreationInsideRepository -PathValue $OutputRoot -RepositoryRoot $dispatchAndLedgerInput.RepositoryRoot -Label "Milestone execution evidence output root"
    $bundleDirectory = Join-Path $resolvedOutputRoot "execution_evidence"
    New-Item -ItemType Directory -Path $bundleDirectory -Force | Out-Null

    if ([string]::IsNullOrWhiteSpace($EvidenceBundleId)) {
        $EvidenceBundleId = "execution-evidence-{0}" -f $dispatchAndLedgerInput.DispatchId
    }
    Assert-RegexMatch -Value $EvidenceBundleId -Pattern $foundation.identifier_pattern -Context "EvidenceBundleId"

    $bundlePath = Join-Path $bundleDirectory ("{0}.json" -f $EvidenceBundleId)
    if (Test-Path -LiteralPath $bundlePath) {
        throw "Milestone execution evidence bundle id '$EvidenceBundleId' already exists."
    }

    $bundle = [pscustomobject]@{
        contract_version     = $foundation.contract_version
        record_type          = $foundation.execution_evidence_record_type
        evidence_bundle_id   = $EvidenceBundleId
        cycle_id             = $dispatchAndLedgerInput.CycleId
        dispatch_id          = $dispatchAndLedgerInput.DispatchId
        dispatch_ref         = Get-RelativeReference -BaseDirectory $bundleDirectory -TargetPath $dispatchAndLedgerInput.DispatchPath
        run_ledger_id        = $dispatchAndLedgerInput.LedgerId
        run_ledger_ref       = Get-RelativeReference -BaseDirectory $bundleDirectory -TargetPath $dispatchAndLedgerInput.LedgerPath
        task_id              = $dispatchAndLedgerInput.TaskId
        executor_type        = $dispatchAndLedgerInput.ExecutorType
        baseline_binding_ref = Get-RelativeReference -BaseDirectory $bundleDirectory -TargetPath $dispatchAndLedgerInput.BindingPath
        baseline_id          = $dispatchAndLedgerInput.BaselineId
        changed_files        = @($normalizedChangedFiles)
        produced_artifacts   = @($normalizedProducedArtifacts)
        test_outputs         = @($normalizedTestOutputs)
        evidence_refs        = @($normalizedEvidenceRefs)
        notes                = $Notes
    }

    Write-JsonDocument -Path $bundlePath -Document $bundle
    $validation = Test-MilestoneAutocycleExecutionEvidenceContract -EvidenceBundlePath $bundlePath

    return [pscustomobject]@{
        EvidenceBundleValidation = $validation
        EvidenceBundlePath       = $validation.EvidenceBundlePath
        EvidenceBundleId         = $validation.EvidenceBundleId
        DispatchId               = $validation.DispatchId
        LedgerId                 = $validation.LedgerId
        TaskId                   = $validation.TaskId
        BaselineId               = $validation.BaselineId
    }
}

Export-ModuleMember -Function Test-MilestoneAutocycleExecutionEvidenceContract, Invoke-MilestoneAutocycleExecutionEvidenceFlow
