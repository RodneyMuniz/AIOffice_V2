Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$milestoneBaselineModulePath = Join-Path $PSScriptRoot "MilestoneBaseline.psm1"
$script:testMilestoneAutocycleBaselineBindingContract = $null

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

function Assert-GitCliAvailable {
    $gitCommand = Get-Command git -ErrorAction SilentlyContinue
    if ($null -eq $gitCommand) {
        throw "Milestone autocycle dispatch requires Git CLI to be installed and callable."
    }

    return $gitCommand
}

function Get-GitWorktreeRoot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $PathValue -Label $Label
    $gitLocation = if (Test-Path -LiteralPath $resolvedPath -PathType Container) { $resolvedPath } else { Split-Path -Parent $resolvedPath }
    Assert-GitCliAvailable | Out-Null
    $worktreeRoot = (& git -C $gitLocation rev-parse --show-toplevel 2>$null)
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($worktreeRoot)) {
        throw "$Label '$PathValue' must resolve inside a Git worktree."
    }

    return (Resolve-Path -LiteralPath $worktreeRoot.Trim()).Path
}

function Assert-ResolvedPathInsideRepository {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResolvedPath,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryWorktreeRoot,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $resolvedRepositoryRoot = Resolve-ExistingPath -PathValue $RepositoryRoot -Label "Repository root"
    if (-not (Test-PathWithinRoot -Path $ResolvedPath -Root $resolvedRepositoryRoot)) {
        throw "$Label '$ResolvedPath' must resolve inside repository root '$resolvedRepositoryRoot'."
    }

    $pathWorktreeRoot = Get-GitWorktreeRoot -PathValue $ResolvedPath -Label $Label
    if ($pathWorktreeRoot -ne $RepositoryWorktreeRoot) {
        throw "$Label '$ResolvedPath' must resolve inside the same Git worktree as repository root '$resolvedRepositoryRoot'."
    }

    return $ResolvedPath
}

function Resolve-PathForCreationInsideRepository {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryWorktreeRoot,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $resolvedPath = Resolve-PathValue -PathValue $PathValue -AnchorPath $RepositoryRoot
    $resolvedRepositoryRoot = Resolve-ExistingPath -PathValue $RepositoryRoot -Label "Repository root"
    if (-not (Test-PathWithinRoot -Path $resolvedPath -Root $resolvedRepositoryRoot)) {
        throw "$Label '$resolvedPath' must resolve inside repository root '$resolvedRepositoryRoot'."
    }

    $existingAnchorPath = $resolvedPath
    while (-not (Test-Path -LiteralPath $existingAnchorPath)) {
        $parentPath = Split-Path -Parent $existingAnchorPath
        if ([string]::IsNullOrWhiteSpace($parentPath) -or $parentPath -eq $existingAnchorPath) {
            $existingAnchorPath = $resolvedRepositoryRoot
            break
        }

        $existingAnchorPath = $parentPath
    }

    $pathWorktreeRoot = Get-GitWorktreeRoot -PathValue $existingAnchorPath -Label "$Label parent"
    if ($pathWorktreeRoot -ne $RepositoryWorktreeRoot) {
        throw "$Label '$resolvedPath' must resolve inside the same Git worktree as repository root '$resolvedRepositoryRoot'."
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

function Assert-RelativeRepositoryReference {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $normalized = Assert-NonEmptyString -Value $Value -Context $Context
    if ([System.IO.Path]::IsPathRooted($normalized)) {
        throw "$Context must be stored as a repository-relative path or glob."
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

function Assert-RelativeRepositoryReferenceArray {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [switch]$AllowEmpty
    )

    $items = [string[]](Assert-StringArray -Value $Value -Context $Context -AllowEmpty:$AllowEmpty)
    $normalizedItems = @()
    foreach ($item in $items) {
        $normalizedItems += (Assert-RelativeRepositoryReference -Value $item -Context "$Context item")
    }

    Write-Output -NoEnumerate $normalizedItems
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

function Get-MilestoneAutocycleDispatchContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_autocycle\dispatch.contract.json") -Label "Milestone autocycle dispatch contract"
}

function Get-MilestoneAutocycleRunLedgerContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_autocycle\run_ledger.contract.json") -Label "Milestone autocycle run ledger contract"
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
        throw "Milestone autocycle dispatch requires dependency module '$DependencyLabel' at '$ModulePath'."
    }

    try {
        $module = Import-Module $ModulePath -Force -PassThru -ErrorAction Stop
    }
    catch {
        throw "Milestone autocycle dispatch requires dependency module '$DependencyLabel' to load successfully. $($_.Exception.Message)"
    }

    $command = $module.ExportedCommands[$CommandName]
    if ($null -eq $command) {
        throw "Milestone autocycle dispatch requires dependency command '$CommandName' from dependency module '$DependencyLabel'."
    }

    return $command
}

function Get-MilestoneBaselineBindingValidatorCommand {
    if ($null -eq $script:testMilestoneAutocycleBaselineBindingContract) {
        $script:testMilestoneAutocycleBaselineBindingContract = Get-RequiredDependencyCommand -ModulePath $milestoneBaselineModulePath -DependencyLabel "MilestoneBaseline" -CommandName "Test-MilestoneAutocycleBaselineBindingContract"
    }

    return $script:testMilestoneAutocycleBaselineBindingContract
}

function Resolve-BaselineBindingDispatchInput {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BindingPath
    )

    $bindingValidator = Get-MilestoneBaselineBindingValidatorCommand
    $bindingValidation = & $bindingValidator -BindingPath $BindingPath
    $binding = Get-JsonDocument -Path $bindingValidation.BindingPath -Label "Milestone baseline binding"
    $bindingDirectory = Split-Path -Parent $bindingValidation.BindingPath
    $baseline = Assert-ObjectValue -Value (Get-RequiredProperty -Object $binding -Name "baseline" -Context "Milestone dispatch baseline binding") -Context "Milestone dispatch baseline binding.baseline"
    $foundation = Get-MilestoneAutocycleFoundationContract

    $baselineId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $baseline -Name "baseline_id" -Context "Milestone dispatch baseline binding.baseline") -Context "Milestone dispatch baseline binding.baseline.baseline_id"
    Assert-RegexMatch -Value $baselineId -Pattern $foundation.identifier_pattern -Context "Milestone dispatch baseline binding.baseline.baseline_id"
    if ($baselineId -ne $bindingValidation.BaselineId) {
        throw "Milestone dispatch baseline binding.baseline.baseline_id must match the validated baseline id."
    }

    $repositoryRoot = Resolve-ExistingPath -PathValue (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $baseline -Name "repository_root" -Context "Milestone dispatch baseline binding.baseline") -Context "Milestone dispatch baseline binding.baseline.repository_root") -Label "Milestone dispatch repository root" -AnchorPath $bindingDirectory
    if (-not (Test-Path -LiteralPath $repositoryRoot -PathType Container)) {
        throw "Milestone dispatch repository root must resolve to a directory."
    }

    $repositoryWorktreeRoot = Get-GitWorktreeRoot -PathValue $repositoryRoot -Label "Milestone dispatch repository root"
    Assert-ResolvedPathInsideRepository -ResolvedPath $bindingValidation.BindingPath -RepositoryRoot $repositoryRoot -RepositoryWorktreeRoot $repositoryWorktreeRoot -Label "Milestone dispatch baseline binding" | Out-Null
    Assert-ResolvedPathInsideRepository -ResolvedPath $bindingValidation.FreezePath -RepositoryRoot $repositoryRoot -RepositoryWorktreeRoot $repositoryWorktreeRoot -Label "Milestone dispatch freeze" | Out-Null

    $branch = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $baseline -Name "branch" -Context "Milestone dispatch baseline binding.baseline") -Context "Milestone dispatch baseline binding.baseline.branch"
    $headCommit = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $baseline -Name "head_commit" -Context "Milestone dispatch baseline binding.baseline") -Context "Milestone dispatch baseline binding.baseline.head_commit"
    $treeId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $baseline -Name "tree_id" -Context "Milestone dispatch baseline binding.baseline") -Context "Milestone dispatch baseline binding.baseline.tree_id"
    $freeze = Get-JsonDocument -Path $bindingValidation.FreezePath -Label "Milestone dispatch freeze"
    $freezeTasksById = @{}
    foreach ($freezeTask in @($freeze.frozen_task_set)) {
        $freezeTasksById[$freezeTask.task_id] = $freezeTask
    }

    return [pscustomobject]@{
        BindingValidation      = $bindingValidation
        Binding                = $binding
        Freeze                 = $freeze
        FreezeTasksById        = $freezeTasksById
        RepositoryRoot         = $repositoryRoot
        RepositoryWorktreeRoot = $repositoryWorktreeRoot
        BaselineId             = $baselineId
        Branch                 = $branch
        HeadCommit             = $headCommit
        TreeId                 = $treeId
    }
}

function Validate-AllowedScope {
    param(
        [Parameter(Mandatory = $true)]
        $AllowedScope,
        [Parameter(Mandatory = $true)]
        $FreezeTask
    )

    $dispatchContract = Get-MilestoneAutocycleDispatchContract
    $scope = Assert-ObjectValue -Value $AllowedScope -Context "Milestone dispatch.allowed_scope"

    foreach ($fieldName in @($dispatchContract.allowed_scope_required_fields)) {
        Get-RequiredProperty -Object $scope -Name $fieldName -Context "Milestone dispatch.allowed_scope" | Out-Null
    }

    $scopeKind = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $scope -Name "scope_kind" -Context "Milestone dispatch.allowed_scope") -Context "Milestone dispatch.allowed_scope.scope_kind"
    if ($scopeKind -ne $dispatchContract.allowed_scope_kind) {
        throw "Milestone dispatch.allowed_scope.scope_kind must equal '$($dispatchContract.allowed_scope_kind)'."
    }

    $scopeSummary = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $scope -Name "scope_summary" -Context "Milestone dispatch.allowed_scope") -Context "Milestone dispatch.allowed_scope.scope_summary"
    if ($scopeSummary -ne $FreezeTask.scope_summary) {
        throw "Milestone dispatch.allowed_scope.scope_summary must match the frozen task scope_summary exactly."
    }

    $allowedPaths = [string[]](Assert-RelativeRepositoryReferenceArray -Value (Get-RequiredProperty -Object $scope -Name "allowed_paths" -Context "Milestone dispatch.allowed_scope") -Context "Milestone dispatch.allowed_scope.allowed_paths")
    $blockedPaths = [string[]](Assert-RelativeRepositoryReferenceArray -Value (Get-RequiredProperty -Object $scope -Name "blocked_paths" -Context "Milestone dispatch.allowed_scope") -Context "Milestone dispatch.allowed_scope.blocked_paths" -AllowEmpty)

    return [pscustomobject]@{
        scope_kind    = $scopeKind
        scope_summary = $scopeSummary
        allowed_paths = @($allowedPaths)
        blocked_paths = @($blockedPaths)
    }
}

function Validate-ExpectedOutputs {
    param(
        [Parameter(Mandatory = $true)]
        $ExpectedOutputs
    )

    $dispatchContract = Get-MilestoneAutocycleDispatchContract
    $foundation = Get-MilestoneAutocycleFoundationContract
    $items = [object[]](Assert-ObjectArray -Value $ExpectedOutputs -Context "Milestone dispatch.expected_outputs")
    $normalizedItems = @()

    foreach ($item in $items) {
        foreach ($fieldName in @($dispatchContract.expected_output_required_fields)) {
            Get-RequiredProperty -Object $item -Name $fieldName -Context "Milestone dispatch.expected_outputs item" | Out-Null
        }

        $kind = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "kind" -Context "Milestone dispatch.expected_outputs item") -Context "Milestone dispatch.expected_outputs item.kind"
        Assert-RegexMatch -Value $kind -Pattern $foundation.identifier_pattern -Context "Milestone dispatch.expected_outputs item.kind"
        $path = Assert-RelativeRepositoryReference -Value (Get-RequiredProperty -Object $item -Name "path" -Context "Milestone dispatch.expected_outputs item") -Context "Milestone dispatch.expected_outputs item.path"
        $notes = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "notes" -Context "Milestone dispatch.expected_outputs item") -Context "Milestone dispatch.expected_outputs item.notes"

        $normalizedItems += [pscustomobject]@{
            kind  = $kind
            path  = $path
            notes = $notes
        }
    }

    Write-Output -NoEnumerate $normalizedItems
}

function Validate-RefusalConditions {
    param(
        [Parameter(Mandatory = $true)]
        $RefusalConditions
    )

    $dispatchContract = Get-MilestoneAutocycleDispatchContract
    $foundation = Get-MilestoneAutocycleFoundationContract
    $items = [object[]](Assert-ObjectArray -Value $RefusalConditions -Context "Milestone dispatch.refusal_conditions")
    $normalizedItems = @()

    foreach ($item in $items) {
        foreach ($fieldName in @($dispatchContract.refusal_condition_required_fields)) {
            Get-RequiredProperty -Object $item -Name $fieldName -Context "Milestone dispatch.refusal_conditions item" | Out-Null
        }

        $code = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "code" -Context "Milestone dispatch.refusal_conditions item") -Context "Milestone dispatch.refusal_conditions item.code"
        Assert-RegexMatch -Value $code -Pattern $foundation.identifier_pattern -Context "Milestone dispatch.refusal_conditions item.code"
        $description = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "description" -Context "Milestone dispatch.refusal_conditions item") -Context "Milestone dispatch.refusal_conditions item.description"

        $normalizedItems += [pscustomobject]@{
            code        = $code
            description = $description
        }
    }

    Write-Output -NoEnumerate $normalizedItems
}

function Validate-DispatchFields {
    param(
        [Parameter(Mandatory = $true)]
        $Dispatch,
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory
    )

    $foundation = Get-MilestoneAutocycleFoundationContract
    $dispatchContract = Get-MilestoneAutocycleDispatchContract

    foreach ($fieldName in @($dispatchContract.required_fields)) {
        Get-RequiredProperty -Object $Dispatch -Name $fieldName -Context "Milestone dispatch" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Dispatch -Name "contract_version" -Context "Milestone dispatch") -Context "Milestone dispatch.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "Milestone dispatch.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Dispatch -Name "record_type" -Context "Milestone dispatch") -Context "Milestone dispatch.record_type"
    if ($recordType -ne $foundation.dispatch_record_type -or $recordType -ne $dispatchContract.record_type) {
        throw "Milestone dispatch.record_type must equal '$($foundation.dispatch_record_type)'."
    }

    $dispatchId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Dispatch -Name "dispatch_id" -Context "Milestone dispatch") -Context "Milestone dispatch.dispatch_id"
    Assert-RegexMatch -Value $dispatchId -Pattern $foundation.identifier_pattern -Context "Milestone dispatch.dispatch_id"
    $cycleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Dispatch -Name "cycle_id" -Context "Milestone dispatch") -Context "Milestone dispatch.cycle_id"
    Assert-RegexMatch -Value $cycleId -Pattern $foundation.identifier_pattern -Context "Milestone dispatch.cycle_id"
    $taskId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Dispatch -Name "task_id" -Context "Milestone dispatch") -Context "Milestone dispatch.task_id"
    Assert-RegexMatch -Value $taskId -Pattern $foundation.identifier_pattern -Context "Milestone dispatch.task_id"

    $executorType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Dispatch -Name "executor_type" -Context "Milestone dispatch") -Context "Milestone dispatch.executor_type"
    Assert-AllowedValue -Value $executorType -AllowedValues @($foundation.allowed_executor_types) -Context "Milestone dispatch.executor_type"

    $bindingPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Dispatch -Name "baseline_binding_ref" -Context "Milestone dispatch") -Context "Milestone dispatch.baseline_binding_ref") -Label "Milestone dispatch baseline binding"
    $bindingInput = Resolve-BaselineBindingDispatchInput -BindingPath $bindingPath
    if ($cycleId -ne $bindingInput.BindingValidation.CycleId) {
        throw "Milestone dispatch.cycle_id must match the referenced baseline binding cycle."
    }

    $baselineId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Dispatch -Name "baseline_id" -Context "Milestone dispatch") -Context "Milestone dispatch.baseline_id"
    Assert-RegexMatch -Value $baselineId -Pattern $foundation.identifier_pattern -Context "Milestone dispatch.baseline_id"
    if ($baselineId -ne $bindingInput.BaselineId) {
        throw "Milestone dispatch.baseline_id must match the pinned baseline id from the baseline binding."
    }

    if (-not $bindingInput.FreezeTasksById.ContainsKey($taskId)) {
        throw "Milestone dispatch.task_id must resolve to one frozen task from the referenced baseline binding."
    }

    $freezeTask = $bindingInput.FreezeTasksById[$taskId]
    $normalizedAllowedScope = Validate-AllowedScope -AllowedScope (Get-RequiredProperty -Object $Dispatch -Name "allowed_scope" -Context "Milestone dispatch") -FreezeTask $freezeTask
    $targetBranch = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Dispatch -Name "target_branch" -Context "Milestone dispatch") -Context "Milestone dispatch.target_branch"
    Assert-RegexMatch -Value $targetBranch -Pattern $dispatchContract.target_branch_pattern -Context "Milestone dispatch.target_branch"
    if ($targetBranch -ne $bindingInput.Branch) {
        throw "Milestone dispatch.target_branch must match the bound baseline branch exactly."
    }

    $normalizedExpectedOutputs = [object[]](Validate-ExpectedOutputs -ExpectedOutputs (Get-RequiredProperty -Object $Dispatch -Name "expected_outputs" -Context "Milestone dispatch"))
    $normalizedRefusalConditions = [object[]](Validate-RefusalConditions -RefusalConditions (Get-RequiredProperty -Object $Dispatch -Name "refusal_conditions" -Context "Milestone dispatch"))

    $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Dispatch -Name "status" -Context "Milestone dispatch") -Context "Milestone dispatch.status"
    Assert-AllowedValue -Value $status -AllowedValues @($foundation.allowed_dispatch_statuses) -Context "Milestone dispatch.status"

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Dispatch -Name "notes" -Context "Milestone dispatch") -Context "Milestone dispatch.notes" | Out-Null

    return [pscustomobject]@{
        DispatchId       = $dispatchId
        CycleId          = $cycleId
        TaskId           = $taskId
        ExecutorType     = $executorType
        Status           = $status
        BindingPath      = $bindingInput.BindingValidation.BindingPath
        FreezePath       = $bindingInput.BindingValidation.FreezePath
        BaselineId       = $bindingInput.BaselineId
        RepositoryRoot   = $bindingInput.RepositoryRoot
        TargetBranch     = $targetBranch
        AllowedScope     = $normalizedAllowedScope
        ExpectedOutputs  = $normalizedExpectedOutputs
        RefusalConditions = $normalizedRefusalConditions
    }
}

function Test-MilestoneAutocycleDispatchContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$DispatchPath
    )

    $resolvedDispatchPath = Resolve-ExistingPath -PathValue $DispatchPath -Label "Milestone dispatch"
    $dispatch = Get-JsonDocument -Path $resolvedDispatchPath -Label "Milestone dispatch"
    $result = Validate-DispatchFields -Dispatch $dispatch -BaseDirectory (Split-Path -Parent $resolvedDispatchPath)

    return [pscustomobject]@{
        IsValid       = $true
        DispatchId    = $result.DispatchId
        CycleId       = $result.CycleId
        TaskId        = $result.TaskId
        ExecutorType  = $result.ExecutorType
        Status        = $result.Status
        BindingPath   = $result.BindingPath
        FreezePath    = $result.FreezePath
        BaselineId    = $result.BaselineId
        RepositoryRoot = $result.RepositoryRoot
        TargetBranch  = $result.TargetBranch
        DispatchPath  = $resolvedDispatchPath
    }
}

function Validate-RunLedgerFields {
    param(
        [Parameter(Mandatory = $true)]
        $Ledger,
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory
    )

    $foundation = Get-MilestoneAutocycleFoundationContract
    $ledgerContract = Get-MilestoneAutocycleRunLedgerContract

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
    Assert-RegexMatch -Value $ledgerId -Pattern $foundation.identifier_pattern -Context "Milestone run ledger.ledger_id"
    $cycleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "cycle_id" -Context "Milestone run ledger") -Context "Milestone run ledger.cycle_id"
    Assert-RegexMatch -Value $cycleId -Pattern $foundation.identifier_pattern -Context "Milestone run ledger.cycle_id"
    $dispatchId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "dispatch_id" -Context "Milestone run ledger") -Context "Milestone run ledger.dispatch_id"
    Assert-RegexMatch -Value $dispatchId -Pattern $foundation.identifier_pattern -Context "Milestone run ledger.dispatch_id"
    $taskId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "task_id" -Context "Milestone run ledger") -Context "Milestone run ledger.task_id"
    Assert-RegexMatch -Value $taskId -Pattern $foundation.identifier_pattern -Context "Milestone run ledger.task_id"

    $dispatchPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "dispatch_ref" -Context "Milestone run ledger") -Context "Milestone run ledger.dispatch_ref") -Label "Milestone run ledger dispatch"
    $dispatchValidation = Test-MilestoneAutocycleDispatchContract -DispatchPath $dispatchPath
    $dispatch = Get-JsonDocument -Path $dispatchValidation.DispatchPath -Label "Milestone dispatch"

    if ($dispatchId -ne $dispatchValidation.DispatchId) {
        throw "Milestone run ledger.dispatch_id must match the referenced dispatch."
    }
    if ($cycleId -ne $dispatchValidation.CycleId) {
        throw "Milestone run ledger.cycle_id must match the referenced dispatch cycle."
    }
    if ($taskId -ne $dispatchValidation.TaskId) {
        throw "Milestone run ledger.task_id must match the referenced dispatch task."
    }

    $executorType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "executor_type" -Context "Milestone run ledger") -Context "Milestone run ledger.executor_type"
    Assert-AllowedValue -Value $executorType -AllowedValues @($foundation.allowed_executor_types) -Context "Milestone run ledger.executor_type"
    if ($executorType -ne $dispatchValidation.ExecutorType) {
        throw "Milestone run ledger.executor_type must match the referenced dispatch executor_type."
    }

    $bindingPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "baseline_binding_ref" -Context "Milestone run ledger") -Context "Milestone run ledger.baseline_binding_ref") -Label "Milestone run ledger baseline binding"
    if ($bindingPath -ne $dispatchValidation.BindingPath) {
        throw "Milestone run ledger.baseline_binding_ref must match the referenced dispatch baseline binding."
    }

    $baselineId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "baseline_id" -Context "Milestone run ledger") -Context "Milestone run ledger.baseline_id"
    Assert-RegexMatch -Value $baselineId -Pattern $foundation.identifier_pattern -Context "Milestone run ledger.baseline_id"
    if ($baselineId -ne $dispatchValidation.BaselineId) {
        throw "Milestone run ledger.baseline_id must match the pinned baseline id from the referenced dispatch."
    }

    $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Ledger -Name "status" -Context "Milestone run ledger") -Context "Milestone run ledger.status"
    Assert-AllowedValue -Value $status -AllowedValues @($foundation.allowed_dispatch_statuses) -Context "Milestone run ledger.status"
    if ($status -ne $dispatch.status) {
        throw "Milestone run ledger.status must match the referenced dispatch status exactly."
    }

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
        Status        = $status
        BaselineId    = $baselineId
        BindingPath   = $dispatchValidation.BindingPath
        DispatchPath  = $dispatchValidation.DispatchPath
        RepositoryRoot = $dispatchValidation.RepositoryRoot
        StartedAt     = $startedAt
        CompletedAt   = $completedAt
    }
}

function Test-MilestoneAutocycleRunLedgerContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$LedgerPath
    )

    $resolvedLedgerPath = Resolve-ExistingPath -PathValue $LedgerPath -Label "Milestone run ledger"
    $ledger = Get-JsonDocument -Path $resolvedLedgerPath -Label "Milestone run ledger"
    $result = Validate-RunLedgerFields -Ledger $ledger -BaseDirectory (Split-Path -Parent $resolvedLedgerPath)

    return [pscustomobject]@{
        IsValid       = $true
        LedgerId      = $result.LedgerId
        CycleId       = $result.CycleId
        DispatchId    = $result.DispatchId
        TaskId        = $result.TaskId
        ExecutorType  = $result.ExecutorType
        Status        = $result.Status
        BaselineId    = $result.BaselineId
        BindingPath   = $result.BindingPath
        DispatchPath  = $result.DispatchPath
        RepositoryRoot = $result.RepositoryRoot
        LedgerPath    = $resolvedLedgerPath
    }
}

function Assert-CleanGitWorktree {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    Assert-GitCliAvailable | Out-Null
    $statusOutput = (& git -C $RepositoryRoot status --short --untracked-files=all 2>$null)
    if ($LASTEXITCODE -ne 0) {
        throw "Milestone dispatch requires Git status to succeed before dispatch."
    }

    if (@($statusOutput).Count -gt 0) {
        throw "Milestone dispatch requires a clean Git worktree before dispatch."
    }
}

function Get-CurrentGitBranch {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    Assert-GitCliAvailable | Out-Null
    $branch = (& git -C $RepositoryRoot branch --show-current 2>$null)
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($branch)) {
        throw "Milestone dispatch requires an attached Git branch before dispatch."
    }

    return $branch.Trim()
}

function Get-GitRevisionValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string]$Revision,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-GitCliAvailable | Out-Null
    $value = (& git -C $RepositoryRoot rev-parse $Revision 2>$null)
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($value)) {
        throw "Milestone dispatch requires $Context to resolve before dispatch."
    }

    return $value.Trim()
}

function Get-CurrentGitRepositoryState {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    return [pscustomobject]@{
        Branch     = Get-CurrentGitBranch -RepositoryRoot $RepositoryRoot
        HeadCommit = Get-GitRevisionValue -RepositoryRoot $RepositoryRoot -Revision "HEAD" -Context "live HEAD commit"
        TreeId     = Get-GitRevisionValue -RepositoryRoot $RepositoryRoot -Revision "HEAD^{tree}" -Context "live HEAD tree"
    }
}

function Assert-LiveRepositoryMatchesPinnedBaseline {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [pscustomobject]$PinnedBaseline
    )

    $currentState = Get-CurrentGitRepositoryState -RepositoryRoot $RepositoryRoot
    $driftReasons = @()

    if ($currentState.Branch -ne $PinnedBaseline.Branch) {
        $driftReasons += ("branch expected '{0}' but found '{1}'" -f $PinnedBaseline.Branch, $currentState.Branch)
    }
    if ($currentState.HeadCommit -ne $PinnedBaseline.HeadCommit) {
        $driftReasons += ("head_commit expected '{0}' but found '{1}'" -f $PinnedBaseline.HeadCommit, $currentState.HeadCommit)
    }
    if ($currentState.TreeId -ne $PinnedBaseline.TreeId) {
        $driftReasons += ("tree_id expected '{0}' but found '{1}'" -f $PinnedBaseline.TreeId, $currentState.TreeId)
    }

    if ($driftReasons.Count -gt 0) {
        throw "Milestone dispatch live repository state drifted from pinned baseline: $($driftReasons -join '; ')."
    }

    Assert-CleanGitWorktree -RepositoryRoot $RepositoryRoot
    return $currentState
}

function Assert-NoActiveDispatchForCycle {
    param(
        [Parameter(Mandatory = $true)]
        [string]$DispatchDirectory,
        [Parameter(Mandatory = $true)]
        [string]$CycleId
    )

    if (-not (Test-Path -LiteralPath $DispatchDirectory)) {
        return
    }

    $dispatchContract = Get-MilestoneAutocycleDispatchContract
    $activeStatuses = @($dispatchContract.active_statuses)
    $dispatchFiles = Get-ChildItem -LiteralPath $DispatchDirectory -Filter *.json -File -ErrorAction SilentlyContinue
    foreach ($dispatchFile in @($dispatchFiles)) {
        $validation = Test-MilestoneAutocycleDispatchContract -DispatchPath $dispatchFile.FullName
        if ($validation.CycleId -eq $CycleId -and $activeStatuses -contains $validation.Status) {
            throw "Milestone dispatch refuses cycle '$CycleId' because dispatch '$($validation.DispatchId)' is already active."
        }
    }
}

function Get-AllowedLedgerTransitions {
    param(
        [Parameter(Mandatory = $true)]
        [string]$CurrentStatus
    )

    $ledgerContract = Get-MilestoneAutocycleRunLedgerContract
    $property = $ledgerContract.valid_transitions.PSObject.Properties | Where-Object { $_.Name -eq $CurrentStatus } | Select-Object -First 1
    if ($null -eq $property) {
        throw "Milestone run ledger does not define transitions for status '$CurrentStatus'."
    }

    return @($property.Value)
}

function Invoke-MilestoneAutocycleDispatchFlow {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$BindingPath,
        [Parameter(Mandatory = $true)]
        [string]$TaskId,
        [Parameter(Mandatory = $true)]
        $AllowedScope,
        [Parameter(Mandatory = $true)]
        [string]$TargetBranch,
        [Parameter(Mandatory = $true)]
        $ExpectedOutputs,
        [Parameter(Mandatory = $true)]
        $RefusalConditions,
        [Parameter(Mandatory = $true)]
        [string]$OutputRoot,
        [string]$ExecutorType = "codex",
        [string]$DispatchId,
        [string]$LedgerId,
        [string]$Notes = "Governed Codex dispatch prepared from one frozen task and one pinned baseline binding only.",
        [string]$LedgerNotes = "Run ledger initialized for one governed Codex dispatch before any execution evidence is recorded."
    )

    $foundation = Get-MilestoneAutocycleFoundationContract
    $bindingInput = Resolve-BaselineBindingDispatchInput -BindingPath $BindingPath

    $taskId = Assert-NonEmptyString -Value $TaskId -Context "TaskId"
    Assert-RegexMatch -Value $taskId -Pattern $foundation.identifier_pattern -Context "TaskId"
    if (-not $bindingInput.FreezeTasksById.ContainsKey($taskId)) {
        throw "Milestone dispatch task_id must resolve to one frozen task from the referenced baseline binding."
    }

    $executorType = Assert-NonEmptyString -Value $ExecutorType -Context "ExecutorType"
    Assert-AllowedValue -Value $executorType -AllowedValues @($foundation.allowed_executor_types) -Context "ExecutorType"
    $normalizedAllowedScope = Validate-AllowedScope -AllowedScope $AllowedScope -FreezeTask $bindingInput.FreezeTasksById[$taskId]
    $normalizedExpectedOutputs = [object[]](Validate-ExpectedOutputs -ExpectedOutputs $ExpectedOutputs)
    $normalizedRefusalConditions = [object[]](Validate-RefusalConditions -RefusalConditions $RefusalConditions)

    $targetBranch = Assert-NonEmptyString -Value $TargetBranch -Context "TargetBranch"
    Assert-RegexMatch -Value $targetBranch -Pattern (Get-MilestoneAutocycleDispatchContract).target_branch_pattern -Context "TargetBranch"
    if ($targetBranch -ne $bindingInput.Branch) {
        throw "Milestone dispatch target branch must match the bound baseline branch exactly."
    }

    Assert-NonEmptyString -Value $Notes -Context "Notes" | Out-Null
    Assert-NonEmptyString -Value $LedgerNotes -Context "LedgerNotes" | Out-Null

    $resolvedOutputRoot = Resolve-PathForCreationInsideRepository -PathValue $OutputRoot -RepositoryRoot $bindingInput.RepositoryRoot -RepositoryWorktreeRoot $bindingInput.RepositoryWorktreeRoot -Label "Milestone dispatch output root"
    New-Item -ItemType Directory -Path $resolvedOutputRoot -Force | Out-Null

    $dispatchDirectory = Join-Path $resolvedOutputRoot "dispatches"
    $ledgerDirectory = Join-Path $resolvedOutputRoot "run_ledgers"
    Assert-NoActiveDispatchForCycle -DispatchDirectory $dispatchDirectory -CycleId $bindingInput.BindingValidation.CycleId
    $currentState = Assert-LiveRepositoryMatchesPinnedBaseline -RepositoryRoot $bindingInput.RepositoryRoot -PinnedBaseline ([pscustomobject]@{
            Branch     = $bindingInput.Branch
            HeadCommit = $bindingInput.HeadCommit
            TreeId     = $bindingInput.TreeId
        })
    New-Item -ItemType Directory -Path $dispatchDirectory -Force | Out-Null
    New-Item -ItemType Directory -Path $ledgerDirectory -Force | Out-Null

    if ([string]::IsNullOrWhiteSpace($DispatchId)) {
        $DispatchId = "dispatch-{0}-{1}" -f $bindingInput.BindingValidation.CycleId, $taskId
    }
    if ([string]::IsNullOrWhiteSpace($LedgerId)) {
        $LedgerId = "run-ledger-{0}" -f $DispatchId
    }

    Assert-RegexMatch -Value $DispatchId -Pattern $foundation.identifier_pattern -Context "DispatchId"
    Assert-RegexMatch -Value $LedgerId -Pattern $foundation.identifier_pattern -Context "LedgerId"

    $dispatchPath = Join-Path $dispatchDirectory ("{0}.json" -f $DispatchId)
    if (Test-Path -LiteralPath $dispatchPath) {
        throw "Milestone dispatch id '$DispatchId' already exists."
    }

    $dispatch = [pscustomobject]@{
        contract_version    = $foundation.contract_version
        record_type         = $foundation.dispatch_record_type
        dispatch_id         = $DispatchId
        cycle_id            = $bindingInput.BindingValidation.CycleId
        task_id             = $taskId
        executor_type       = $executorType
        baseline_binding_ref = Get-RelativeReference -BaseDirectory $dispatchDirectory -TargetPath $bindingInput.BindingValidation.BindingPath
        baseline_id         = $bindingInput.BaselineId
        allowed_scope       = $normalizedAllowedScope
        target_branch       = $targetBranch
        expected_outputs    = @($normalizedExpectedOutputs)
        refusal_conditions  = @($normalizedRefusalConditions)
        status              = "not_started"
        notes               = $Notes
    }

    Write-JsonDocument -Path $dispatchPath -Document $dispatch
    $dispatchValidation = Test-MilestoneAutocycleDispatchContract -DispatchPath $dispatchPath

    $ledgerPath = Join-Path $ledgerDirectory ("{0}.json" -f $LedgerId)
    if (Test-Path -LiteralPath $ledgerPath) {
        throw "Milestone run ledger id '$LedgerId' already exists."
    }

    $ledger = [pscustomobject]@{
        contract_version     = $foundation.contract_version
        record_type          = $foundation.run_ledger_record_type
        ledger_id            = $LedgerId
        cycle_id             = $dispatchValidation.CycleId
        dispatch_id          = $dispatchValidation.DispatchId
        dispatch_ref         = Get-RelativeReference -BaseDirectory $ledgerDirectory -TargetPath $dispatchValidation.DispatchPath
        task_id              = $dispatchValidation.TaskId
        executor_type        = $dispatchValidation.ExecutorType
        baseline_binding_ref = Get-RelativeReference -BaseDirectory $ledgerDirectory -TargetPath $dispatchValidation.BindingPath
        baseline_id          = $dispatchValidation.BaselineId
        status               = "not_started"
        started_at           = $null
        completed_at         = $null
        result_summary       = "Dispatch created; executor not started."
        notes                = $LedgerNotes
    }

    Write-JsonDocument -Path $ledgerPath -Document $ledger
    $ledgerValidation = Test-MilestoneAutocycleRunLedgerContract -LedgerPath $ledgerPath

    return [pscustomobject]@{
        DispatchValidation = $dispatchValidation
        RunLedgerValidation = $ledgerValidation
        DispatchPath       = $dispatchValidation.DispatchPath
        RunLedgerPath      = $ledgerValidation.LedgerPath
        DispatchId         = $dispatchValidation.DispatchId
        LedgerId           = $ledgerValidation.LedgerId
        BaselineId         = $dispatchValidation.BaselineId
    }
}

function Set-MilestoneAutocycleRunLedgerStatus {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$LedgerPath,
        [Parameter(Mandatory = $true)]
        [string]$Status,
        [Parameter(Mandatory = $true)]
        [string]$ResultSummary,
        [Parameter(Mandatory = $true)]
        [string]$Notes,
        [datetime]$OccurredAt = (Get-Date).ToUniversalTime()
    )

    $foundation = Get-MilestoneAutocycleFoundationContract
    $status = Assert-NonEmptyString -Value $Status -Context "Status"
    Assert-AllowedValue -Value $status -AllowedValues @($foundation.allowed_dispatch_statuses) -Context "Status"
    Assert-NonEmptyString -Value $ResultSummary -Context "ResultSummary" | Out-Null
    Assert-NonEmptyString -Value $Notes -Context "Notes" | Out-Null

    $ledgerValidation = Test-MilestoneAutocycleRunLedgerContract -LedgerPath $LedgerPath
    $ledger = Get-JsonDocument -Path $ledgerValidation.LedgerPath -Label "Milestone run ledger"
    $ledgerDirectory = Split-Path -Parent $ledgerValidation.LedgerPath
    $dispatchPath = Resolve-ReferenceAgainstBase -BaseDirectory $ledgerDirectory -Reference $ledger.dispatch_ref -Label "Milestone run ledger dispatch"
    $dispatchValidation = Test-MilestoneAutocycleDispatchContract -DispatchPath $dispatchPath
    $dispatch = Get-JsonDocument -Path $dispatchValidation.DispatchPath -Label "Milestone dispatch"

    $allowedTransitions = @(Get-AllowedLedgerTransitions -CurrentStatus $ledger.status)
    if ($allowedTransitions -notcontains $status) {
        throw "Milestone run ledger status '$($ledger.status)' cannot transition to '$status'."
    }

    $timestamp = Get-UtcTimestamp -DateTime $OccurredAt
    switch ($status) {
        "in_progress" {
            $ledger.started_at = $timestamp
            $ledger.completed_at = $null
        }
        "completed" {
            $ledger.completed_at = $timestamp
        }
        "failed" {
            $ledger.completed_at = $timestamp
        }
        "refused" {
            $ledger.started_at = $null
            $ledger.completed_at = $timestamp
        }
    }

    $dispatch.status = $status
    $ledger.status = $status
    $ledger.result_summary = $ResultSummary
    $ledger.notes = $Notes

    Write-JsonDocument -Path $dispatchValidation.DispatchPath -Document $dispatch
    Test-MilestoneAutocycleDispatchContract -DispatchPath $dispatchValidation.DispatchPath | Out-Null

    Write-JsonDocument -Path $ledgerValidation.LedgerPath -Document $ledger
    $updatedLedgerValidation = Test-MilestoneAutocycleRunLedgerContract -LedgerPath $ledgerValidation.LedgerPath

    return [pscustomobject]@{
        LedgerValidation  = $updatedLedgerValidation
        DispatchValidation = (Test-MilestoneAutocycleDispatchContract -DispatchPath $dispatchValidation.DispatchPath)
        LedgerPath        = $updatedLedgerValidation.LedgerPath
        DispatchPath      = $dispatchValidation.DispatchPath
        Status            = $updatedLedgerValidation.Status
    }
}

Export-ModuleMember -Function Test-MilestoneAutocycleDispatchContract, Test-MilestoneAutocycleRunLedgerContract, Invoke-MilestoneAutocycleDispatchFlow, Set-MilestoneAutocycleRunLedgerStatus
