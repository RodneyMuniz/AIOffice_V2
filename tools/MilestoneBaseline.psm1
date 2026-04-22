Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$planningRecordStorageModulePath = Join-Path $PSScriptRoot "PlanningRecordStorage.psm1"
$governedWorkObjectValidationModulePath = Join-Path $PSScriptRoot "GovernedWorkObjectValidation.psm1"
$milestoneAutocycleFreezeModulePath = Join-Path $PSScriptRoot "MilestoneAutocycleFreeze.psm1"
$script:testPlanningRecordContract = $null
$script:testGovernedWorkObjectContract = $null
$script:testMilestoneAutocycleFreezeContract = $null
$script:newPlanningRecordCommand = $null
$script:setPlanningRecordWorkingStateCommand = $null
$script:setPlanningRecordAcceptedStateCommand = $null
$script:setPlanningRecordReconciliationStateCommand = $null
$script:savePlanningRecordCommand = $null

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

function Resolve-PathInsideRepository {
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

    $resolvedPath = Resolve-ExistingPath -PathValue $PathValue -Label $Label -AnchorPath $RepositoryRoot
    return Assert-ResolvedPathInsideRepository -ResolvedPath $resolvedPath -RepositoryRoot $RepositoryRoot -RepositoryWorktreeRoot $RepositoryWorktreeRoot -Label $Label
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

function Get-RelativeReferencePathValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory,
        [Parameter(Mandatory = $true)]
        [string]$TargetPath
    )

    $resolvedBaseDirectory = Resolve-ExistingPath -PathValue $BaseDirectory -Label "Base directory"
    $normalizedTargetPath = [System.IO.Path]::GetFullPath($TargetPath)
    $baseUri = [System.Uri]("{0}{1}" -f $resolvedBaseDirectory.TrimEnd("\/"), [System.IO.Path]::DirectorySeparatorChar)
    $targetUri = [System.Uri]$normalizedTargetPath
    return ($baseUri.MakeRelativeUri($targetUri).OriginalString).Replace("\", "/")
}

function Get-NormalizedReferenceForSave {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaselineDirectory,
        [Parameter(Mandatory = $true)]
        [string]$Reference
    )

    if ([System.IO.Path]::IsPathRooted($Reference)) {
        return (Get-RelativeReference -BaseDirectory $BaselineDirectory -TargetPath $Reference)
    }

    $candidate = Join-Path $BaselineDirectory ($Reference -replace "[/\\]", [System.IO.Path]::DirectorySeparatorChar)
    if (Test-Path -LiteralPath $candidate) {
        return $Reference.Replace("\", "/")
    }

    return $Reference.Replace("\", "/")
}

function Get-BaselineFoundationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_baselines\foundation.contract.json") -Label "Milestone baseline foundation contract"
}

function Get-BaselineContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_baselines\milestone_baseline.contract.json") -Label "Milestone baseline contract"
}

function Get-MilestoneAutocycleFoundationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_autocycle\foundation.contract.json") -Label "Milestone autocycle foundation contract"
}

function Get-MilestoneAutocycleBaselineBindingContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_autocycle\baseline_binding.contract.json") -Label "Milestone autocycle baseline binding contract"
}

function Assert-GitCliAvailable {
    $contract = Get-BaselineContract
    if (-not $contract.runtime_rules.git_cli_required) {
        return $null
    }

    $gitCommand = Get-Command git -ErrorAction SilentlyContinue
    if ($null -eq $gitCommand) {
        throw "Milestone baseline requires Git CLI to be installed and callable."
    }

    return $gitCommand
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
        throw "Milestone baseline requires dependency module '$DependencyLabel' at '$ModulePath'."
    }

    try {
        $module = Import-Module $ModulePath -Force -PassThru -ErrorAction Stop
    }
    catch {
        throw "Milestone baseline requires dependency module '$DependencyLabel' to load successfully. $($_.Exception.Message)"
    }

    $command = $module.ExportedCommands[$CommandName]
    if ($null -eq $command) {
        throw "Milestone baseline requires dependency command '$CommandName' from dependency module '$DependencyLabel'."
    }

    return $command
}

function Get-PlanningRecordValidatorCommand {
    $contract = Get-BaselineContract
    if (-not $contract.runtime_rules.planning_record_validator_required) {
        throw "Milestone baseline contract requires planning_record_validator_required to remain true."
    }

    if ($null -eq $script:testPlanningRecordContract) {
        $script:testPlanningRecordContract = Get-RequiredDependencyCommand -ModulePath $planningRecordStorageModulePath -DependencyLabel "PlanningRecordStorage" -CommandName "Test-PlanningRecordContract"
    }

    return $script:testPlanningRecordContract
}

function Get-GovernedWorkObjectValidatorCommand {
    $contract = Get-BaselineContract
    if (-not $contract.runtime_rules.governed_work_object_validator_required) {
        throw "Milestone baseline contract requires governed_work_object_validator_required to remain true."
    }

    if ($null -eq $script:testGovernedWorkObjectContract) {
        $script:testGovernedWorkObjectContract = Get-RequiredDependencyCommand -ModulePath $governedWorkObjectValidationModulePath -DependencyLabel "GovernedWorkObjectValidation" -CommandName "Test-GovernedWorkObjectContract"
    }

    return $script:testGovernedWorkObjectContract
}

function Get-MilestoneFreezeValidatorCommand {
    if ($null -eq $script:testMilestoneAutocycleFreezeContract) {
        $script:testMilestoneAutocycleFreezeContract = Get-RequiredDependencyCommand -ModulePath $milestoneAutocycleFreezeModulePath -DependencyLabel "MilestoneAutocycleFreeze" -CommandName "Test-MilestoneAutocycleFreezeContract"
    }

    return $script:testMilestoneAutocycleFreezeContract
}

function Get-NewPlanningRecordCommand {
    if ($null -eq $script:newPlanningRecordCommand) {
        $script:newPlanningRecordCommand = Get-RequiredDependencyCommand -ModulePath $planningRecordStorageModulePath -DependencyLabel "PlanningRecordStorage" -CommandName "New-PlanningRecord"
    }

    return $script:newPlanningRecordCommand
}

function Get-SetPlanningRecordWorkingStateCommand {
    if ($null -eq $script:setPlanningRecordWorkingStateCommand) {
        $script:setPlanningRecordWorkingStateCommand = Get-RequiredDependencyCommand -ModulePath $planningRecordStorageModulePath -DependencyLabel "PlanningRecordStorage" -CommandName "Set-PlanningRecordWorkingState"
    }

    return $script:setPlanningRecordWorkingStateCommand
}

function Get-SetPlanningRecordAcceptedStateCommand {
    if ($null -eq $script:setPlanningRecordAcceptedStateCommand) {
        $script:setPlanningRecordAcceptedStateCommand = Get-RequiredDependencyCommand -ModulePath $planningRecordStorageModulePath -DependencyLabel "PlanningRecordStorage" -CommandName "Set-PlanningRecordAcceptedState"
    }

    return $script:setPlanningRecordAcceptedStateCommand
}

function Get-SetPlanningRecordReconciliationStateCommand {
    if ($null -eq $script:setPlanningRecordReconciliationStateCommand) {
        $script:setPlanningRecordReconciliationStateCommand = Get-RequiredDependencyCommand -ModulePath $planningRecordStorageModulePath -DependencyLabel "PlanningRecordStorage" -CommandName "Set-PlanningRecordReconciliationState"
    }

    return $script:setPlanningRecordReconciliationStateCommand
}

function Get-SavePlanningRecordCommand {
    if ($null -eq $script:savePlanningRecordCommand) {
        $script:savePlanningRecordCommand = Get-RequiredDependencyCommand -ModulePath $planningRecordStorageModulePath -DependencyLabel "PlanningRecordStorage" -CommandName "Save-PlanningRecord"
    }

    return $script:savePlanningRecordCommand
}

function Assert-AbsolutePathValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $normalizedPath = Assert-NonEmptyString -Value $PathValue -Context $Context
    if (-not [System.IO.Path]::IsPathRooted($normalizedPath)) {
        throw "$Context must be stored as an absolute machine-local path."
    }

    return [System.IO.Path]::GetFullPath($normalizedPath)
}

function Get-GitValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    Assert-GitCliAvailable | Out-Null
    $value = (& git -C $RepositoryRoot @Arguments 2>$null)
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to resolve $Label for milestone baseline capture."
    }

    return $value
}

function Assert-GitBranchIdentity {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string]$Branch,
        [Parameter(Mandatory = $true)]
        $Foundation
    )

    Assert-GitCliAvailable | Out-Null
    $normalizedBranch = Assert-NonEmptyString -Value $Branch -Context "Milestone baseline.git.branch"
    if ($Foundation.git_branch_validation_mode -eq "git_check_ref_format_branch") {
        & git -C $RepositoryRoot check-ref-format --branch $normalizedBranch *> $null
        if ($LASTEXITCODE -ne 0) {
            throw "Milestone baseline.git.branch must be a structurally valid Git branch name."
        }
    }

    if ($Foundation.git_branch_must_exist_in_repository) {
        & git -C $RepositoryRoot show-ref --verify --quiet ("refs/heads/{0}" -f $normalizedBranch) *> $null
        if ($LASTEXITCODE -ne 0) {
            throw "Milestone baseline.git.branch must resolve to a local branch in the referenced repository."
        }
    }

    return $normalizedBranch
}

function Assert-GitObjectIdentity {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string]$ObjectId,
        [Parameter(Mandatory = $true)]
        [string]$Pattern,
        [Parameter(Mandatory = $true)]
        [string]$ObjectSpec,
        [Parameter(Mandatory = $true)]
        [bool]$MustExistInRepository,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-GitCliAvailable | Out-Null
    $normalizedObjectId = Assert-NonEmptyString -Value $ObjectId -Context $Context
    Assert-RegexMatch -Value $normalizedObjectId -Pattern $Pattern -Context $Context

    if ($MustExistInRepository) {
        & git -C $RepositoryRoot cat-file -e $ObjectSpec *> $null
        if ($LASTEXITCODE -ne 0) {
            throw "$Context must resolve to an existing Git object in the referenced repository."
        }
    }

    return $normalizedObjectId
}

function Get-GitBranchName {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $branchValue = Get-GitValue -RepositoryRoot $RepositoryRoot -Arguments @("branch", "--show-current") -Label "Git branch"
    $branch = if ($null -eq $branchValue) { "" } else { ([string]$branchValue).Trim() }
    if ([string]::IsNullOrWhiteSpace($branch)) {
        throw "Milestone baseline capture requires an attached Git branch; detached HEAD is not allowed."
    }

    return $branch
}

function Get-GitHeadCommit {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $headValue = Get-GitValue -RepositoryRoot $RepositoryRoot -Arguments @("rev-parse", "HEAD") -Label "Git HEAD commit"
    $head = if ($null -eq $headValue) { "" } else { ([string]$headValue).Trim() }
    if ([string]::IsNullOrWhiteSpace($head)) {
        throw "Milestone baseline capture requires a non-empty Git HEAD commit."
    }

    return $head
}

function Get-GitTreeId {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $treeValue = Get-GitValue -RepositoryRoot $RepositoryRoot -Arguments @("rev-parse", "HEAD^{tree}") -Label "Git tree id"
    $treeId = if ($null -eq $treeValue) { "" } else { ([string]$treeValue).Trim() }
    if ([string]::IsNullOrWhiteSpace($treeId)) {
        throw "Milestone baseline capture requires a non-empty Git tree id."
    }

    return $treeId
}

function Get-GitStatusLines {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    Assert-GitCliAvailable | Out-Null
    $statusOutput = & git -C $RepositoryRoot status --short --untracked-files=all 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to resolve Git status for milestone baseline capture."
    }

    return @($statusOutput | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Resolve-ValidatedMilestoneBaselineMilestoneInput {
    param(
        [Parameter(Mandatory = $true)]
        [string]$MilestonePath,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryWorktreeRoot
    )

    $foundation = Get-BaselineFoundationContract
    $resolvedMilestonePath = Resolve-PathInsideRepository -PathValue $MilestonePath -RepositoryRoot $RepositoryRoot -RepositoryWorktreeRoot $RepositoryWorktreeRoot -Label "Milestone"
    $milestoneValidation = & (Get-GovernedWorkObjectValidatorCommand) -WorkObjectPath $resolvedMilestonePath
    if ($milestoneValidation.ObjectType -ne "milestone") {
        throw "Milestone baseline capture requires a milestone governed work object."
    }

    $milestoneDocument = Get-JsonDocument -Path $milestoneValidation.WorkObjectPath -Label "Milestone"
    if (@($foundation.allowed_milestone_statuses) -notcontains $milestoneDocument.status) {
        throw "Milestone baseline capture requires milestone status 'active' or 'completed'."
    }

    return [pscustomobject]@{
        Validation = $milestoneValidation
        Document   = $milestoneDocument
    }
}

function Get-CleanGitBaselineCapture {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $resolvedRepositoryRoot = Resolve-ExistingPath -PathValue $RepositoryRoot -Label "Repository root"
    $statusLines = @(Get-GitStatusLines -RepositoryRoot $resolvedRepositoryRoot)
    if ($statusLines.Count -ne 0) {
        throw "Milestone baseline capture requires a clean Git worktree."
    }

    return [pscustomobject]@{
        repository_root              = $resolvedRepositoryRoot
        branch                       = Get-GitBranchName -RepositoryRoot $resolvedRepositoryRoot
        head_commit                  = Get-GitHeadCommit -RepositoryRoot $resolvedRepositoryRoot
        tree_id                      = Get-GitTreeId -RepositoryRoot $resolvedRepositoryRoot
        status_lines                 = @()
        working_tree_clean           = $true
        captured_from_clean_worktree = $true
    }
}

function Assert-UsableCapturedGitState {
    param(
        [Parameter(Mandatory = $true)]
        $GitCapture,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $foundation = Get-BaselineFoundationContract
    $contract = Get-BaselineContract
    $resolvedRepositoryRoot = Resolve-ExistingPath -PathValue $RepositoryRoot -Label "Repository root"
    $gitCaptureObject = Assert-ObjectValue -Value $GitCapture -Context "GitCapture"

    foreach ($fieldName in $foundation.git_required_fields) {
        Get-RequiredProperty -Object $gitCaptureObject -Name $fieldName -Context "GitCapture" | Out-Null
    }

    $capturedRepositoryRoot = Assert-AbsolutePathValue -PathValue (Get-RequiredProperty -Object $gitCaptureObject -Name "repository_root" -Context "GitCapture") -Context "GitCapture.repository_root"
    $resolvedCaptureRepositoryRoot = Resolve-ExistingPath -PathValue $capturedRepositoryRoot -Label "GitCapture.repository_root"
    if ($resolvedCaptureRepositoryRoot -ne $resolvedRepositoryRoot) {
        throw "GitCapture.repository_root must match RepositoryRoot."
    }

    $branch = Assert-GitBranchIdentity -RepositoryRoot $resolvedRepositoryRoot -Branch (Get-RequiredProperty -Object $gitCaptureObject -Name "branch" -Context "GitCapture") -Foundation $foundation
    $headCommit = Assert-GitObjectIdentity -RepositoryRoot $resolvedRepositoryRoot -ObjectId (Get-RequiredProperty -Object $gitCaptureObject -Name "head_commit" -Context "GitCapture") -Pattern $foundation.git_commit_hash_pattern -ObjectSpec ("{0}^{{commit}}" -f $gitCaptureObject.head_commit) -MustExistInRepository $foundation.git_head_commit_must_exist_in_repository -Context "GitCapture.head_commit"
    $treeId = Assert-GitObjectIdentity -RepositoryRoot $resolvedRepositoryRoot -ObjectId (Get-RequiredProperty -Object $gitCaptureObject -Name "tree_id" -Context "GitCapture") -Pattern $foundation.git_tree_hash_pattern -ObjectSpec ("{0}^{{tree}}" -f $gitCaptureObject.tree_id) -MustExistInRepository $foundation.git_tree_id_must_exist_in_repository -Context "GitCapture.tree_id"
    $statusLines = [string[]](Assert-StringArray -Value (Get-RequiredProperty -Object $gitCaptureObject -Name "status_lines" -Context "GitCapture") -Context "GitCapture.status_lines" -AllowEmpty)
    $workingTreeClean = Assert-BooleanValue -Value (Get-RequiredProperty -Object $gitCaptureObject -Name "working_tree_clean" -Context "GitCapture") -Context "GitCapture.working_tree_clean"
    $capturedFromCleanWorktree = Assert-BooleanValue -Value (Get-RequiredProperty -Object $gitCaptureObject -Name "captured_from_clean_worktree" -Context "GitCapture") -Context "GitCapture.captured_from_clean_worktree"
    if ($contract.git_rules.clean_worktree_required -and (-not $workingTreeClean -or -not $capturedFromCleanWorktree -or $statusLines.Count -ne 0)) {
        throw "GitCapture must preserve a clean-worktree capture with no status lines."
    }

    $currentBranch = Get-GitBranchName -RepositoryRoot $resolvedRepositoryRoot
    if ($currentBranch -ne $branch) {
        throw "GitCapture.branch no longer matches the repository branch."
    }

    $currentHeadCommit = Get-GitHeadCommit -RepositoryRoot $resolvedRepositoryRoot
    if ($currentHeadCommit -ne $headCommit) {
        throw "GitCapture.head_commit no longer matches the repository HEAD."
    }

    $currentTreeId = Get-GitTreeId -RepositoryRoot $resolvedRepositoryRoot
    if ($currentTreeId -ne $treeId) {
        throw "GitCapture.tree_id no longer matches the repository HEAD tree."
    }

    return [pscustomobject]@{
        repository_root              = $resolvedRepositoryRoot
        branch                       = $branch
        head_commit                  = $headCommit
        tree_id                      = $treeId
        status_lines                 = @($statusLines)
        working_tree_clean           = $workingTreeClean
        captured_from_clean_worktree = $capturedFromCleanWorktree
    }
}

function Resolve-PlanningRecordBaselineInput {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PlanningRecordPath,
        [Parameter(Mandatory = $true)]
        $MilestoneDocument,
        [Parameter(Mandatory = $true)]
        [string]$MilestonePath,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryWorktreeRoot
    )

    $resolvedPlanningRecordPath = Resolve-PathInsideRepository -PathValue $PlanningRecordPath -RepositoryRoot $RepositoryRoot -RepositoryWorktreeRoot $RepositoryWorktreeRoot -Label "Planning record"
    $validation = & (Get-PlanningRecordValidatorCommand) -PlanningRecordPath $resolvedPlanningRecordPath
    $planningRecord = Get-JsonDocument -Path $validation.PlanningRecordPath -Label "Planning record"
    if ($planningRecord.accepted_state.status -ne "accepted") {
        throw "Milestone baseline capture requires accepted planning records only."
    }

    $acceptedRecordRef = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $planningRecord.accepted_state -Name "record_ref" -Context "PlanningRecord.accepted_state") -Context "PlanningRecord.accepted_state.record_ref"
    $acceptedRecordPath = Resolve-ReferenceAgainstBase -BaseDirectory (Split-Path -Parent $validation.PlanningRecordPath) -Reference $acceptedRecordRef -Label "Planning record accepted surface"
    $acceptedRecordPath = Assert-ResolvedPathInsideRepository -ResolvedPath $acceptedRecordPath -RepositoryRoot $RepositoryRoot -RepositoryWorktreeRoot $RepositoryWorktreeRoot -Label "Planning record accepted surface"
    $acceptedRecordValidation = & (Get-GovernedWorkObjectValidatorCommand) -WorkObjectPath $acceptedRecordPath
    $acceptedRecord = Get-JsonDocument -Path $acceptedRecordValidation.WorkObjectPath -Label "Accepted planning record work object"

    $parent = Assert-ObjectValue -Value (Get-RequiredProperty -Object $acceptedRecord -Name "parent" -Context "Accepted planning record work object") -Context "Accepted planning record work object.parent"
    $parentType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $parent -Name "object_type" -Context "Accepted planning record work object.parent") -Context "Accepted planning record work object.parent.object_type"
    if ($parentType -ne "milestone") {
        throw "Accepted planning record work objects must have milestone parents for milestone baseline capture."
    }

    $parentObjectId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $parent -Name "object_id" -Context "Accepted planning record work object.parent") -Context "Accepted planning record work object.parent.object_id"
    if ($parentObjectId -ne $MilestoneDocument.object_id) {
        throw "Planning record '$($validation.PlanningRecordId)' does not belong to milestone '$($MilestoneDocument.object_id)'."
    }

    $parentRef = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $parent -Name "ref" -Context "Accepted planning record work object.parent") -Context "Accepted planning record work object.parent.ref"
    $acceptedParentPath = Resolve-PathInsideRepository -PathValue $parentRef -RepositoryRoot $RepositoryRoot -RepositoryWorktreeRoot $RepositoryWorktreeRoot -Label "Accepted planning record milestone parent"
    $acceptedParentValidation = & (Get-GovernedWorkObjectValidatorCommand) -WorkObjectPath $acceptedParentPath
    if ($acceptedParentValidation.ObjectType -ne "milestone") {
        throw "Accepted planning record milestone parent refs must resolve to governed milestone work objects."
    }

    $acceptedParentDocument = Get-JsonDocument -Path $acceptedParentValidation.WorkObjectPath -Label "Accepted planning record milestone parent"
    if ($acceptedParentDocument.object_id -ne $MilestoneDocument.object_id) {
        throw "Accepted planning record milestone parent refs must resolve to the anchored milestone identity."
    }
    if ($acceptedParentValidation.WorkObjectPath -ine $MilestonePath) {
        throw "Accepted planning record milestone parent ref must match the anchored milestone work object path."
    }

    return [pscustomobject]@{
        Validation          = $validation
        PlanningRecord      = $planningRecord
        AcceptedRecordPath  = $acceptedRecordPath
        AcceptedRecord      = $acceptedRecord
        AcceptedParentPath  = $acceptedParentValidation.WorkObjectPath
    }
}

function Validate-BaselineFields {
    param(
        [Parameter(Mandatory = $true)]
        $Baseline,
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory
    )

    $foundation = Get-BaselineFoundationContract
    $contract = Get-BaselineContract

    foreach ($fieldName in $foundation.required_fields) {
        Get-RequiredProperty -Object $Baseline -Name $fieldName -Context "Milestone baseline" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Baseline -Name "contract_version" -Context "Milestone baseline") -Context "Milestone baseline.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "Milestone baseline.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Baseline -Name "record_type" -Context "Milestone baseline") -Context "Milestone baseline.record_type"
    if ($recordType -ne $foundation.record_type -or $recordType -ne $contract.record_type) {
        throw "Milestone baseline.record_type must equal '$($foundation.record_type)'."
    }

    $baselineId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Baseline -Name "baseline_id" -Context "Milestone baseline") -Context "Milestone baseline.baseline_id"
    Assert-RegexMatch -Value $baselineId -Pattern $foundation.identifier_pattern -Context "Milestone baseline.baseline_id"

    $baselineKind = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Baseline -Name "baseline_kind" -Context "Milestone baseline") -Context "Milestone baseline.baseline_kind"
    Assert-AllowedValue -Value $baselineKind -AllowedValues @($foundation.allowed_baseline_kinds) -Context "Milestone baseline.baseline_kind"

    $capturedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Baseline -Name "captured_at" -Context "Milestone baseline") -Context "Milestone baseline.captured_at"
    Assert-RegexMatch -Value $capturedAt -Pattern $foundation.timestamp_pattern -Context "Milestone baseline.captured_at"

    $capturedBy = Assert-ObjectValue -Value (Get-RequiredProperty -Object $Baseline -Name "captured_by" -Context "Milestone baseline") -Context "Milestone baseline.captured_by"
    foreach ($fieldName in $foundation.captured_by_required_fields) {
        Get-RequiredProperty -Object $capturedBy -Name $fieldName -Context "Milestone baseline.captured_by" | Out-Null
    }

    $capturedByRole = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $capturedBy -Name "role" -Context "Milestone baseline.captured_by") -Context "Milestone baseline.captured_by.role"
    Assert-AllowedValue -Value $capturedByRole -AllowedValues @($foundation.allowed_actor_roles) -Context "Milestone baseline.captured_by.role"
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $capturedBy -Name "id" -Context "Milestone baseline.captured_by") -Context "Milestone baseline.captured_by.id" | Out-Null

    $authority = Assert-ObjectValue -Value (Get-RequiredProperty -Object $Baseline -Name "authority" -Context "Milestone baseline") -Context "Milestone baseline.authority"
    foreach ($fieldName in $foundation.authority_required_fields) {
        Get-RequiredProperty -Object $authority -Name $fieldName -Context "Milestone baseline.authority" | Out-Null
    }

    $operatorId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $authority -Name "operator_id" -Context "Milestone baseline.authority") -Context "Milestone baseline.authority.operator_id"
    Assert-RegexMatch -Value $operatorId -Pattern $foundation.operator_pattern -Context "Milestone baseline.authority.operator_id"
    $approvedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $authority -Name "approved_at" -Context "Milestone baseline.authority") -Context "Milestone baseline.authority.approved_at"
    Assert-RegexMatch -Value $approvedAt -Pattern $foundation.timestamp_pattern -Context "Milestone baseline.authority.approved_at"
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $authority -Name "reason" -Context "Milestone baseline.authority") -Context "Milestone baseline.authority.reason" | Out-Null

    $milestone = Assert-ObjectValue -Value (Get-RequiredProperty -Object $Baseline -Name "milestone" -Context "Milestone baseline") -Context "Milestone baseline.milestone"
    foreach ($fieldName in $foundation.milestone_required_fields) {
        Get-RequiredProperty -Object $milestone -Name $fieldName -Context "Milestone baseline.milestone" | Out-Null
    }

    $milestoneObjectId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $milestone -Name "object_id" -Context "Milestone baseline.milestone") -Context "Milestone baseline.milestone.object_id"
    $milestonePath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $milestone -Name "ref" -Context "Milestone baseline.milestone") -Context "Milestone baseline.milestone.ref") -Label "Milestone baseline milestone"
    $milestoneValidation = & (Get-GovernedWorkObjectValidatorCommand) -WorkObjectPath $milestonePath
    if ($milestoneValidation.ObjectType -ne "milestone") {
        throw "Milestone baseline records must reference governed work object milestones."
    }

    $milestoneDocument = Get-JsonDocument -Path $milestoneValidation.WorkObjectPath -Label "Milestone baseline milestone"
    if ($milestoneDocument.object_id -ne $milestoneObjectId) {
        throw "Milestone baseline milestone.object_id must match the referenced milestone work object."
    }

    $milestoneStatus = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $milestone -Name "status" -Context "Milestone baseline.milestone") -Context "Milestone baseline.milestone.status"
    Assert-AllowedValue -Value $milestoneStatus -AllowedValues @($foundation.allowed_milestone_statuses) -Context "Milestone baseline.milestone.status"
    if ($milestoneDocument.status -ne $milestoneStatus) {
        throw "Milestone baseline milestone.status must match the referenced milestone work object status."
    }

    $git = Assert-ObjectValue -Value (Get-RequiredProperty -Object $Baseline -Name "git" -Context "Milestone baseline") -Context "Milestone baseline.git"
    foreach ($fieldName in $foundation.git_required_fields) {
        Get-RequiredProperty -Object $git -Name $fieldName -Context "Milestone baseline.git" | Out-Null
    }

    $storedRepositoryRoot = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $git -Name "repository_root" -Context "Milestone baseline.git") -Context "Milestone baseline.git.repository_root"
    if ($foundation.git_repository_root_must_be_absolute -or $contract.git_rules.repository_root_persistence -eq "absolute_machine_local") {
        $storedRepositoryRoot = Assert-AbsolutePathValue -PathValue $storedRepositoryRoot -Context "Milestone baseline.git.repository_root"
    }

    $baselineRepositoryRoot = Resolve-ExistingPath -PathValue $storedRepositoryRoot -Label "Milestone baseline.git.repository_root"
    if ($foundation.git_repository_root_must_be_worktree) {
        $baselineRepositoryWorktreeRoot = Get-GitWorktreeRoot -PathValue $baselineRepositoryRoot -Label "Milestone baseline.git.repository_root"
    }
    else {
        $baselineRepositoryWorktreeRoot = $baselineRepositoryRoot
    }
    $branch = Assert-GitBranchIdentity -RepositoryRoot $baselineRepositoryRoot -Branch (Get-RequiredProperty -Object $git -Name "branch" -Context "Milestone baseline.git") -Foundation $foundation
    $storedHeadCommit = Get-RequiredProperty -Object $git -Name "head_commit" -Context "Milestone baseline.git"
    $storedTreeId = Get-RequiredProperty -Object $git -Name "tree_id" -Context "Milestone baseline.git"
    $headCommit = Assert-GitObjectIdentity -RepositoryRoot $baselineRepositoryRoot -ObjectId $storedHeadCommit -Pattern $foundation.git_commit_hash_pattern -ObjectSpec ("{0}^{{commit}}" -f $storedHeadCommit) -MustExistInRepository $foundation.git_head_commit_must_exist_in_repository -Context "Milestone baseline.git.head_commit"
    $treeId = Assert-GitObjectIdentity -RepositoryRoot $baselineRepositoryRoot -ObjectId $storedTreeId -Pattern $foundation.git_tree_hash_pattern -ObjectSpec ("{0}^{{tree}}" -f $storedTreeId) -MustExistInRepository $foundation.git_tree_id_must_exist_in_repository -Context "Milestone baseline.git.tree_id"
    $statusLines = [string[]](Assert-StringArray -Value (Get-RequiredProperty -Object $git -Name "status_lines" -Context "Milestone baseline.git") -Context "Milestone baseline.git.status_lines" -AllowEmpty)
    $workingTreeClean = Assert-BooleanValue -Value (Get-RequiredProperty -Object $git -Name "working_tree_clean" -Context "Milestone baseline.git") -Context "Milestone baseline.git.working_tree_clean"
    $capturedFromCleanWorktree = Assert-BooleanValue -Value (Get-RequiredProperty -Object $git -Name "captured_from_clean_worktree" -Context "Milestone baseline.git") -Context "Milestone baseline.git.captured_from_clean_worktree"
    if ($contract.git_rules.clean_worktree_required -and (-not $workingTreeClean -or -not $capturedFromCleanWorktree -or $statusLines.Count -ne 0)) {
        throw "Milestone baseline records must capture a clean Git worktree with no status lines."
    }

    if ($foundation.git_tree_id_must_match_head_commit_tree) {
        $expectedTreeId = (Get-GitValue -RepositoryRoot $baselineRepositoryRoot -Arguments @("rev-parse", ("{0}^{{tree}}" -f $headCommit)) -Label "Git tree id for stored head commit").Trim()
        if ($expectedTreeId -ne $treeId) {
            throw "Milestone baseline.git.tree_id must match the stored head_commit tree in the referenced repository."
        }
    }

    Assert-ResolvedPathInsideRepository -ResolvedPath $milestoneValidation.WorkObjectPath -RepositoryRoot $baselineRepositoryRoot -RepositoryWorktreeRoot $baselineRepositoryWorktreeRoot -Label "Milestone baseline milestone" | Out-Null

    $planningRecordRefs = [object[]](Assert-ObjectArray -Value (Get-RequiredProperty -Object $Baseline -Name "planning_record_refs" -Context "Milestone baseline") -Context "Milestone baseline.planning_record_refs")
    if ($planningRecordRefs.Count -eq 0) {
        throw "Milestone baseline records must include at least one accepted planning record ref."
    }

    $expectedPlanningRecordEvidenceRefs = @()
    $expectedAcceptedArtifactEvidenceRefs = @()
    foreach ($planningRecordRef in $planningRecordRefs) {
        foreach ($fieldName in $foundation.planning_record_ref_required_fields) {
            Get-RequiredProperty -Object $planningRecordRef -Name $fieldName -Context "Milestone baseline.planning_record_refs item" | Out-Null
        }

        $planningView = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $planningRecordRef -Name "view" -Context "Milestone baseline.planning_record_refs item") -Context "Milestone baseline.planning_record_refs item.view"
        Assert-AllowedValue -Value $planningView -AllowedValues @($foundation.allowed_planning_record_views) -Context "Milestone baseline.planning_record_refs item.view"

        $planningRecordPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $planningRecordRef -Name "ref" -Context "Milestone baseline.planning_record_refs item") -Context "Milestone baseline.planning_record_refs item.ref") -Label "Milestone baseline planning record"
        $planningRecordInput = Resolve-PlanningRecordBaselineInput -PlanningRecordPath $planningRecordPath -MilestoneDocument $milestoneDocument -MilestonePath $milestoneValidation.WorkObjectPath -RepositoryRoot $baselineRepositoryRoot -RepositoryWorktreeRoot $baselineRepositoryWorktreeRoot

        if ($planningRecordInput.Validation.PlanningRecordId -ne $planningRecordRef.planning_record_id) {
            throw "Milestone baseline planning_record_refs item.planning_record_id must match the referenced planning record."
        }
        if ($planningRecordInput.Validation.ObjectType -ne $planningRecordRef.object_type -or $planningRecordInput.Validation.ObjectId -ne $planningRecordRef.object_id) {
            throw "Milestone baseline planning_record_refs item object identity must match the referenced planning record."
        }

        $acceptedRecordPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $planningRecordRef -Name "accepted_record_ref" -Context "Milestone baseline.planning_record_refs item") -Context "Milestone baseline.planning_record_refs item.accepted_record_ref") -Label "Milestone baseline accepted planning record"
        if ($acceptedRecordPath -ne $planningRecordInput.AcceptedRecordPath) {
            throw "Milestone baseline planning_record_refs item.accepted_record_ref must match the referenced planning record accepted surface."
        }

        $expectedPlanningRecordEvidenceRefs += $planningRecordInput.Validation.PlanningRecordPath
        $expectedAcceptedArtifactEvidenceRefs += $planningRecordInput.AcceptedRecordPath
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $planningRecordRef -Name "notes" -Context "Milestone baseline.planning_record_refs item") -Context "Milestone baseline.planning_record_refs item.notes" | Out-Null
    }

    $evidence = [object[]](Assert-ObjectArray -Value (Get-RequiredProperty -Object $Baseline -Name "evidence" -Context "Milestone baseline") -Context "Milestone baseline.evidence")
    $planningRecordEvidenceFound = $false
    $matchedPlanningRecordEvidenceRefs = @()
    $matchedAcceptedArtifactEvidenceRefs = @()
    $milestoneAnchorArtifactEvidenceFound = $false
    foreach ($evidenceItem in $evidence) {
        foreach ($fieldName in $foundation.evidence_required_fields) {
            Get-RequiredProperty -Object $evidenceItem -Name $fieldName -Context "Milestone baseline.evidence item" | Out-Null
        }

        $evidenceKind = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $evidenceItem -Name "kind" -Context "Milestone baseline.evidence item") -Context "Milestone baseline.evidence item.kind"
        Assert-AllowedValue -Value $evidenceKind -AllowedValues @($foundation.allowed_evidence_kinds) -Context "Milestone baseline.evidence item.kind"
        $evidenceRef = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $evidenceItem -Name "ref" -Context "Milestone baseline.evidence item") -Context "Milestone baseline.evidence item.ref"
        if ($contract.evidence_rules.evidence_refs_must_resolve) {
            $resolvedEvidenceRef = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference $evidenceRef -Label "Milestone baseline evidence"
        }
        else {
            $resolvedEvidenceRef = $evidenceRef
        }
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $evidenceItem -Name "summary" -Context "Milestone baseline.evidence item") -Context "Milestone baseline.evidence item.summary" | Out-Null
        if ($evidenceKind -eq "planning_record") {
            $planningRecordEvidenceFound = $true
            if ($contract.evidence_rules.planning_record_evidence_must_match_refs -and $expectedPlanningRecordEvidenceRefs -notcontains $resolvedEvidenceRef) {
                throw "Milestone baseline planning_record evidence refs must match planning_record_refs item.ref values."
            }
            if ($matchedPlanningRecordEvidenceRefs -notcontains $resolvedEvidenceRef) {
                $matchedPlanningRecordEvidenceRefs += $resolvedEvidenceRef
            }
        }
        elseif ($evidenceKind -eq "artifact") {
            if ($resolvedEvidenceRef -ieq $milestoneValidation.WorkObjectPath) {
                $milestoneAnchorArtifactEvidenceFound = $true
            }
            elseif ($expectedAcceptedArtifactEvidenceRefs -contains $resolvedEvidenceRef -and $matchedAcceptedArtifactEvidenceRefs -notcontains $resolvedEvidenceRef) {
                $matchedAcceptedArtifactEvidenceRefs += $resolvedEvidenceRef
            }
        }
    }

    if ($contract.evidence_rules.planning_record_evidence_required -and -not $planningRecordEvidenceFound) {
        throw "Milestone baseline records must include planning_record evidence."
    }
    if ($contract.evidence_rules.planning_record_evidence_must_match_refs -and $matchedPlanningRecordEvidenceRefs.Count -ne $expectedPlanningRecordEvidenceRefs.Count) {
        throw "Milestone baseline records must include planning_record evidence for each planning_record_refs item."
    }
    if ($contract.evidence_rules.accepted_planning_artifact_evidence_required -and $matchedAcceptedArtifactEvidenceRefs.Count -ne $expectedAcceptedArtifactEvidenceRefs.Count) {
        throw "Milestone baseline records must include accepted planning artifact evidence for each planning_record_refs item."
    }
    if ($contract.evidence_rules.milestone_anchor_artifact_evidence_required -and -not $milestoneAnchorArtifactEvidenceFound) {
        throw "Milestone baseline records must include milestone anchor artifact evidence."
    }

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Baseline -Name "notes" -Context "Milestone baseline") -Context "Milestone baseline.notes" | Out-Null
}

function Test-MilestoneBaselineRecordContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaselinePath
    )

    $resolvedBaselinePath = Resolve-ExistingPath -PathValue $BaselinePath -Label "Milestone baseline" -AnchorPath (Get-ModuleRepositoryRootPath)
    $baseline = Get-JsonDocument -Path $resolvedBaselinePath -Label "Milestone baseline"
    Validate-BaselineFields -Baseline $baseline -BaseDirectory (Split-Path -Parent $resolvedBaselinePath)

    return [pscustomobject]@{
        IsValid      = $true
        BaselineId   = $baseline.baseline_id
        BaselinePath = $resolvedBaselinePath
    }
}

function Build-MilestoneBaselineRecord {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaselineId,
        [Parameter(Mandatory = $true)]
        $MilestoneInput,
        [Parameter(Mandatory = $true)]
        [string[]]$PlanningRecordPaths,
        [Parameter(Mandatory = $true)]
        [string]$OperatorId,
        [Parameter(Mandatory = $true)]
        [string]$AuthorityReason,
        [Parameter(Mandatory = $true)]
        $GitCapture,
        [Parameter(Mandatory = $true)]
        [datetime]$CapturedAt,
        [Parameter(Mandatory = $true)]
        [string]$CapturedById,
        [Parameter(Mandatory = $true)]
        [string]$BaselineKind
    )

    $foundation = Get-BaselineFoundationContract
    $resolvedGitCapture = Assert-UsableCapturedGitState -GitCapture $GitCapture -RepositoryRoot $GitCapture.repository_root
    $createdAtText = Get-UtcTimestamp -DateTime $CapturedAt
    $planningRecordRefs = @()
    $evidence = @()
    foreach ($planningRecordPath in @($PlanningRecordPaths)) {
        $planningRecordInput = Resolve-PlanningRecordBaselineInput -PlanningRecordPath $planningRecordPath -MilestoneDocument $MilestoneInput.Document -MilestonePath $MilestoneInput.Validation.WorkObjectPath -RepositoryRoot $resolvedGitCapture.repository_root -RepositoryWorktreeRoot (Get-GitWorktreeRoot -PathValue $resolvedGitCapture.repository_root -Label "Repository root")

        $planningRecordRefs += [pscustomobject]@{
            planning_record_id  = $planningRecordInput.Validation.PlanningRecordId
            object_type         = $planningRecordInput.Validation.ObjectType
            object_id           = $planningRecordInput.Validation.ObjectId
            view                = "accepted"
            ref                 = $planningRecordInput.Validation.PlanningRecordPath
            accepted_record_ref = $planningRecordInput.AcceptedRecordPath
            notes               = "Accepted planning record captured into the milestone Git baseline."
        }

        $evidence += [pscustomobject]@{
            kind    = "planning_record"
            ref     = $planningRecordInput.Validation.PlanningRecordPath
            summary = "Accepted planning record '$($planningRecordInput.Validation.PlanningRecordId)' is included in the milestone baseline."
        }

        $evidence += [pscustomobject]@{
            kind    = "artifact"
            ref     = $planningRecordInput.AcceptedRecordPath
            summary = "Accepted planning surface '$($planningRecordInput.AcceptedRecord.object_id)' is captured as milestone-baseline evidence."
        }
    }

    $evidence += [pscustomobject]@{
        kind    = "artifact"
        ref     = $MilestoneInput.Validation.WorkObjectPath
        summary = "Milestone work object captured as the baseline scope anchor."
    }

    $baseline = [pscustomobject]@{
        contract_version = $foundation.contract_version
        record_type      = $foundation.record_type
        baseline_id      = $BaselineId
        baseline_kind    = $BaselineKind
        milestone        = [pscustomobject]@{
            object_id = $MilestoneInput.Document.object_id
            ref       = $MilestoneInput.Validation.WorkObjectPath
            status    = $MilestoneInput.Document.status
        }
        captured_at      = $createdAtText
        captured_by      = [pscustomobject]@{
            role = "control_kernel"
            id   = $CapturedById
        }
        authority        = [pscustomobject]@{
            operator_id = $OperatorId
            approved_at = $createdAtText
            reason      = $AuthorityReason
        }
        git              = [pscustomobject]@{
            repository_root              = $resolvedGitCapture.repository_root
            branch                       = $resolvedGitCapture.branch
            head_commit                  = $resolvedGitCapture.head_commit
            tree_id                      = $resolvedGitCapture.tree_id
            status_lines                 = @($resolvedGitCapture.status_lines)
            working_tree_clean           = $resolvedGitCapture.working_tree_clean
            captured_from_clean_worktree = $resolvedGitCapture.captured_from_clean_worktree
        }
        planning_record_refs = @($planningRecordRefs)
        evidence         = @($evidence)
        notes            = "Git-backed milestone baseline captured from a clean worktree. This is a restore target substrate only and does not claim rollback execution."
    }

    Validate-BaselineFields -Baseline $baseline -BaseDirectory (Get-ModuleRepositoryRootPath)
    return $baseline
}

function New-MilestoneBaselineRecord {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaselineId,
        [Parameter(Mandatory = $true)]
        [string]$MilestonePath,
        [Parameter(Mandatory = $true)]
        [string[]]$PlanningRecordPaths,
        [Parameter(Mandatory = $true)]
        [string]$OperatorId,
        [Parameter(Mandatory = $true)]
        [string]$AuthorityReason,
        [string]$RepositoryRoot = (Get-RepositoryRoot),
        [datetime]$CapturedAt = (Get-Date).ToUniversalTime(),
        [string]$CapturedById = "control-kernel:milestone-baseline",
        [string]$BaselineKind = "milestone_checkpoint"
    )

    $foundation = Get-BaselineFoundationContract

    Assert-RegexMatch -Value $BaselineId -Pattern $foundation.identifier_pattern -Context "BaselineId"
    Assert-RegexMatch -Value $OperatorId -Pattern $foundation.operator_pattern -Context "OperatorId"
    Assert-NonEmptyString -Value $AuthorityReason -Context "AuthorityReason" | Out-Null
    Assert-AllowedValue -Value $BaselineKind -AllowedValues @($foundation.allowed_baseline_kinds) -Context "BaselineKind"

    $resolvedRepositoryRoot = Resolve-ExistingPath -PathValue $RepositoryRoot -Label "Repository root"
    $repositoryWorktreeRoot = Get-GitWorktreeRoot -PathValue $resolvedRepositoryRoot -Label "Repository root"
    $milestoneInput = Resolve-ValidatedMilestoneBaselineMilestoneInput -MilestonePath $MilestonePath -RepositoryRoot $resolvedRepositoryRoot -RepositoryWorktreeRoot $repositoryWorktreeRoot
    $gitCapture = Get-CleanGitBaselineCapture -RepositoryRoot $resolvedRepositoryRoot

    return (Build-MilestoneBaselineRecord -BaselineId $BaselineId -MilestoneInput $milestoneInput -PlanningRecordPaths $PlanningRecordPaths -OperatorId $OperatorId -AuthorityReason $AuthorityReason -GitCapture $gitCapture -CapturedAt $CapturedAt -CapturedById $CapturedById -BaselineKind $BaselineKind)
}

function Get-FreezeBaselineBindingInput {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FreezePath,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $resolvedRepositoryRoot = Resolve-ExistingPath -PathValue $RepositoryRoot -Label "Repository root"
    $repositoryWorktreeRoot = Get-GitWorktreeRoot -PathValue $resolvedRepositoryRoot -Label "Repository root"
    $resolvedFreezePath = Resolve-PathInsideRepository -PathValue $FreezePath -RepositoryRoot $resolvedRepositoryRoot -RepositoryWorktreeRoot $repositoryWorktreeRoot -Label "Milestone freeze"
    $freezeValidation = & (Get-MilestoneFreezeValidatorCommand) -FreezePath $resolvedFreezePath
    $freeze = Get-JsonDocument -Path $freezeValidation.FreezePath -Label "Milestone freeze"

    $resolvedProposalPath = Assert-ResolvedPathInsideRepository -ResolvedPath $freezeValidation.ProposalPath -RepositoryRoot $resolvedRepositoryRoot -RepositoryWorktreeRoot $repositoryWorktreeRoot -Label "Milestone freeze proposal"
    $proposal = Get-JsonDocument -Path $resolvedProposalPath -Label "Milestone proposal"
    $proposalDirectory = Split-Path -Parent $resolvedProposalPath
    $milestonePath = Resolve-ReferenceAgainstBase -BaseDirectory $proposalDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $proposal -Name "milestone_ref" -Context "Milestone proposal") -Context "Milestone proposal.milestone_ref") -Label "Milestone proposal milestone"
    $milestonePath = Assert-ResolvedPathInsideRepository -ResolvedPath $milestonePath -RepositoryRoot $resolvedRepositoryRoot -RepositoryWorktreeRoot $repositoryWorktreeRoot -Label "Milestone proposal milestone"
    $milestoneInput = Resolve-ValidatedMilestoneBaselineMilestoneInput -MilestonePath $milestonePath -RepositoryRoot $resolvedRepositoryRoot -RepositoryWorktreeRoot $repositoryWorktreeRoot
    $freezeDirectory = Split-Path -Parent $freezeValidation.FreezePath

    foreach ($task in @($freeze.frozen_task_set)) {
        $taskParent = Assert-ObjectValue -Value (Get-RequiredProperty -Object $task -Name "parent" -Context "Milestone freeze task") -Context "Milestone freeze task.parent"
        $resolvedTaskParentPath = Resolve-ReferenceAgainstBase -BaseDirectory $freezeDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $taskParent -Name "ref" -Context "Milestone freeze task.parent") -Context "Milestone freeze task.parent.ref") -Label "Milestone freeze task parent"
        $resolvedTaskParentPath = Assert-ResolvedPathInsideRepository -ResolvedPath $resolvedTaskParentPath -RepositoryRoot $resolvedRepositoryRoot -RepositoryWorktreeRoot $repositoryWorktreeRoot -Label "Milestone freeze task parent"
        if ($resolvedTaskParentPath -ine $milestoneInput.Validation.WorkObjectPath) {
            throw "Frozen task parent refs must resolve to the anchored milestone for baseline binding."
        }
    }

    return [pscustomobject]@{
        RepositoryRoot         = $resolvedRepositoryRoot
        RepositoryWorktreeRoot = $repositoryWorktreeRoot
        FreezeValidation       = $freezeValidation
        Freeze                 = $freeze
        ProposalPath           = $resolvedProposalPath
        Proposal               = $proposal
        MilestoneInput         = $milestoneInput
    }
}

function Get-FreezeTaskPlanningRecordId {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FreezeId,
        [Parameter(Mandatory = $true)]
        [string]$TaskId
    )

    return ("planning-{0}-{1}" -f $FreezeId, $TaskId)
}

function Get-FreezeTaskAcceptedRecordPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PlanningStorePath,
        [Parameter(Mandatory = $true)]
        [string]$PlanningRecordId
    )

    return (Join-Path (Join-Path $PlanningStorePath "accepted") ("{0}.task.json" -f $PlanningRecordId))
}

function New-FreezeTaskAcceptedWorkObject {
    param(
        [Parameter(Mandatory = $true)]
        $Task,
        [Parameter(Mandatory = $true)]
        $Freeze,
        [Parameter(Mandatory = $true)]
        [string]$FreezePath,
        [Parameter(Mandatory = $true)]
        [string]$ProposalPath,
        [Parameter(Mandatory = $true)]
        [string]$MilestonePath,
        [Parameter(Mandatory = $true)]
        [string]$PlanningStorePath,
        [Parameter(Mandatory = $true)]
        [hashtable]$PlanningRecordIdMap,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [datetime]$BoundAt
    )

    $boundAtText = Get-UtcTimestamp -DateTime $BoundAt
    $freezeRef = Get-RelativeReference -BaseDirectory $RepositoryRoot -TargetPath $FreezePath
    $proposalRef = Get-RelativeReference -BaseDirectory $RepositoryRoot -TargetPath $ProposalPath
    $milestoneRef = Get-RelativeReference -BaseDirectory $RepositoryRoot -TargetPath $MilestonePath

    $relationships = @()
    foreach ($dependencyTaskId in @($Task.depends_on_ids)) {
        if (-not $PlanningRecordIdMap.ContainsKey($dependencyTaskId)) {
            throw "Frozen task '$($Task.task_id)' depends on unknown task id '$dependencyTaskId'."
        }

        $dependencyPlanningRecordId = [string]$PlanningRecordIdMap[$dependencyTaskId]
        $dependencyAcceptedPath = Get-FreezeTaskAcceptedRecordPath -PlanningStorePath $PlanningStorePath -PlanningRecordId $dependencyPlanningRecordId
        $relationships += [pscustomobject]@{
            relation    = "depends_on"
            object_type = "task"
            object_id   = $dependencyTaskId
            ref         = Get-RelativeReferencePathValue -BaseDirectory $RepositoryRoot -TargetPath $dependencyAcceptedPath
            notes       = "Dependency preserved from the frozen milestone task set for baseline binding."
        }
    }

    return [pscustomobject]@{
        contract_version   = "v1"
        record_type        = "governed_work_object"
        object_type        = "task"
        object_id          = $Task.task_id
        title              = $Task.title
        summary            = $Task.scope_summary
        status             = "ready"
        created_at         = $boundAtText
        created_by         = [pscustomobject]@{
            role = "control_kernel"
            id   = "control-kernel:milestone-autocycle-baseline-binding"
        }
        parent             = [pscustomobject]@{
            object_type = $Task.parent.object_type
            object_id   = $Task.parent.object_id
            ref         = $milestoneRef
        }
        lineage            = [pscustomobject]@{
            source_kind = "milestone_plan"
            source_refs = @($freezeRef, $proposalRef)
            rationale   = "Accepted planning surface materialized from the approved frozen milestone task set for Git-backed baseline binding only."
        }
        relationships      = @($relationships)
        evidence           = @(
            [pscustomobject]@{
                kind    = "decision_record"
                ref     = $freezeRef
                summary = "The approved freeze authorizes this accepted planning surface for baseline binding."
            }
        )
        audit              = [pscustomobject]@{
            trail_refs       = @($freezeRef, $proposalRef)
            last_reviewed_at = $boundAtText
            notes            = "Accepted planning surface materialized from the committed freeze before dispatch."
        }
        scope_summary      = $Task.scope_summary
        task_kind          = $Task.task_kind
        requested_outcome  = $Task.requested_outcome
        acceptance_checks  = @($Task.acceptance_checks)
        non_goals          = @($Task.non_goals)
    }
}

function Materialize-FreezePlanningRecordBridge {
    param(
        [Parameter(Mandatory = $true)]
        $BindingInput,
        [Parameter(Mandatory = $true)]
        [string]$OutputRoot,
        [Parameter(Mandatory = $true)]
        [datetime]$BoundAt
    )

    $planningStorePath = Join-Path (Join-Path $OutputRoot "planning_records") $BindingInput.Freeze.freeze_id
    New-Item -ItemType Directory -Path $planningStorePath -Force | Out-Null

    $planningRecordIdMap = @{}
    foreach ($task in @($BindingInput.Freeze.frozen_task_set)) {
        $planningRecordIdMap[$task.task_id] = Get-FreezeTaskPlanningRecordId -FreezeId $BindingInput.Freeze.freeze_id -TaskId $task.task_id
    }

    $materializedPlanningRecords = @()
    foreach ($task in @($BindingInput.Freeze.frozen_task_set)) {
        $planningRecordId = [string]$planningRecordIdMap[$task.task_id]
        $acceptedWorkObject = New-FreezeTaskAcceptedWorkObject -Task $task -Freeze $BindingInput.Freeze -FreezePath $BindingInput.FreezeValidation.FreezePath -ProposalPath $BindingInput.ProposalPath -MilestonePath $BindingInput.MilestoneInput.Validation.WorkObjectPath -PlanningStorePath $planningStorePath -PlanningRecordIdMap $planningRecordIdMap -RepositoryRoot $BindingInput.RepositoryRoot -BoundAt $BoundAt
        $workingWorkObject = ConvertFrom-Json ($acceptedWorkObject | ConvertTo-Json -Depth 20)

        $planningRecord = & (Get-NewPlanningRecordCommand) -PlanningRecordId $planningRecordId -WorkingRecord $workingWorkObject -CreatedAt $BoundAt -InitialWorkingStatus "ready_for_review"
        $planningRecord = & (Get-SetPlanningRecordWorkingStateCommand) -PlanningRecord $planningRecord -Status "ready_for_review" -WorkObjectRecord $workingWorkObject -UpdatedAt $BoundAt -Notes "Working planning surface mirrors the frozen approved task set at baseline-binding time."
        $planningRecord = & (Get-SetPlanningRecordAcceptedStateCommand) -PlanningRecord $planningRecord -Status "accepted" -WorkObjectRecord $acceptedWorkObject -AcceptedAt $BoundAt -AcceptedBy $BindingInput.Freeze.approved_by -Notes "Accepted planning surface materialized from the approved freeze for baseline binding."
        $planningRecord = & (Get-SetPlanningRecordReconciliationStateCommand) -PlanningRecord $planningRecord -Status "matched" -ComparedAt $BoundAt -WorkingMatchesAccepted $true -Notes "Working and accepted planning surfaces intentionally match when a frozen milestone is baseline-bound."
        $planningRecordPath = & (Get-SavePlanningRecordCommand) -PlanningRecord $planningRecord -StorePath $planningStorePath
        $planningRecordValidation = & (Get-PlanningRecordValidatorCommand) -PlanningRecordPath $planningRecordPath

        $materializedPlanningRecords += [pscustomobject]@{
            TaskId                = $task.task_id
            PlanningRecordId      = $planningRecordValidation.PlanningRecordId
            PlanningRecordPath    = $planningRecordValidation.PlanningRecordPath
            AcceptedRecordPath    = $planningRecordValidation.AcceptedRecordPath
            PlanningRecordValidation = $planningRecordValidation
        }
    }

    return [pscustomobject]@{
        PlanningStorePath          = $planningStorePath
        MaterializedPlanningRecords = @($materializedPlanningRecords)
    }
}

function Validate-BaselineBindingFields {
    param(
        [Parameter(Mandatory = $true)]
        $Binding,
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory
    )

    $foundation = Get-MilestoneAutocycleFoundationContract
    $contract = Get-MilestoneAutocycleBaselineBindingContract

    foreach ($fieldName in @($contract.required_fields)) {
        Get-RequiredProperty -Object $Binding -Name $fieldName -Context "Milestone baseline binding" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Binding -Name "contract_version" -Context "Milestone baseline binding") -Context "Milestone baseline binding.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "Milestone baseline binding.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Binding -Name "record_type" -Context "Milestone baseline binding") -Context "Milestone baseline binding.record_type"
    if ($recordType -ne $foundation.baseline_binding_record_type -or $recordType -ne $contract.record_type) {
        throw "Milestone baseline binding.record_type must equal '$($foundation.baseline_binding_record_type)'."
    }

    $bindingId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Binding -Name "binding_id" -Context "Milestone baseline binding") -Context "Milestone baseline binding.binding_id"
    Assert-RegexMatch -Value $bindingId -Pattern $foundation.identifier_pattern -Context "Milestone baseline binding.binding_id"
    $cycleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Binding -Name "cycle_id" -Context "Milestone baseline binding") -Context "Milestone baseline binding.cycle_id"
    Assert-RegexMatch -Value $cycleId -Pattern $foundation.identifier_pattern -Context "Milestone baseline binding.cycle_id"
    $freezeId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Binding -Name "freeze_id" -Context "Milestone baseline binding") -Context "Milestone baseline binding.freeze_id"
    Assert-RegexMatch -Value $freezeId -Pattern $foundation.identifier_pattern -Context "Milestone baseline binding.freeze_id"
    $boundAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Binding -Name "bound_at" -Context "Milestone baseline binding") -Context "Milestone baseline binding.bound_at"
    Assert-RegexMatch -Value $boundAt -Pattern $foundation.timestamp_pattern -Context "Milestone baseline binding.bound_at"

    $baselineBinding = Assert-ObjectValue -Value (Get-RequiredProperty -Object $Binding -Name "baseline" -Context "Milestone baseline binding") -Context "Milestone baseline binding.baseline"
    foreach ($fieldName in @($contract.baseline_required_fields)) {
        Get-RequiredProperty -Object $baselineBinding -Name $fieldName -Context "Milestone baseline binding.baseline" | Out-Null
    }

    $baselineRepositoryRoot = Assert-AbsolutePathValue -PathValue (Get-RequiredProperty -Object $baselineBinding -Name "repository_root" -Context "Milestone baseline binding.baseline") -Context "Milestone baseline binding.baseline.repository_root"
    $resolvedBaselineRepositoryRoot = Resolve-ExistingPath -PathValue $baselineRepositoryRoot -Label "Milestone baseline binding.baseline.repository_root"
    $baselineRepositoryWorktreeRoot = Get-GitWorktreeRoot -PathValue $resolvedBaselineRepositoryRoot -Label "Milestone baseline binding.baseline.repository_root"

    $baselineFoundation = Get-BaselineFoundationContract
    $baselineSummaryId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $baselineBinding -Name "baseline_id" -Context "Milestone baseline binding.baseline") -Context "Milestone baseline binding.baseline.baseline_id"
    Assert-RegexMatch -Value $baselineSummaryId -Pattern $foundation.identifier_pattern -Context "Milestone baseline binding.baseline.baseline_id"
    $baselineBranch = Assert-GitBranchIdentity -RepositoryRoot $resolvedBaselineRepositoryRoot -Branch (Get-RequiredProperty -Object $baselineBinding -Name "branch" -Context "Milestone baseline binding.baseline") -Foundation $baselineFoundation
    $baselineHeadCommit = Assert-GitObjectIdentity -RepositoryRoot $resolvedBaselineRepositoryRoot -ObjectId (Get-RequiredProperty -Object $baselineBinding -Name "head_commit" -Context "Milestone baseline binding.baseline") -Pattern $baselineFoundation.git_commit_hash_pattern -ObjectSpec ("{0}^{{commit}}" -f $baselineBinding.head_commit) -MustExistInRepository $baselineFoundation.git_head_commit_must_exist_in_repository -Context "Milestone baseline binding.baseline.head_commit"
    $baselineTreeId = Assert-GitObjectIdentity -RepositoryRoot $resolvedBaselineRepositoryRoot -ObjectId (Get-RequiredProperty -Object $baselineBinding -Name "tree_id" -Context "Milestone baseline binding.baseline") -Pattern $baselineFoundation.git_tree_hash_pattern -ObjectSpec ("{0}^{{tree}}" -f $baselineBinding.tree_id) -MustExistInRepository $baselineFoundation.git_tree_id_must_exist_in_repository -Context "Milestone baseline binding.baseline.tree_id"

    $baselinePath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $baselineBinding -Name "baseline_ref" -Context "Milestone baseline binding.baseline") -Context "Milestone baseline binding.baseline.baseline_ref") -Label "Milestone baseline binding baseline"
    $baselinePath = Assert-ResolvedPathInsideRepository -ResolvedPath $baselinePath -RepositoryRoot $resolvedBaselineRepositoryRoot -RepositoryWorktreeRoot $baselineRepositoryWorktreeRoot -Label "Milestone baseline binding baseline"
    $baselineValidation = Test-MilestoneBaselineRecordContract -BaselinePath $baselinePath
    $baselineDocument = Get-JsonDocument -Path $baselineValidation.BaselinePath -Label "Milestone baseline binding baseline"
    if ($baselineDocument.baseline_id -ne $baselineSummaryId) {
        throw "Milestone baseline binding.baseline.baseline_id must match the referenced milestone baseline."
    }
    if ($baselineDocument.git.repository_root -ne $resolvedBaselineRepositoryRoot -or $baselineDocument.git.branch -ne $baselineBranch -or $baselineDocument.git.head_commit -ne $baselineHeadCommit -or $baselineDocument.git.tree_id -ne $baselineTreeId) {
        throw "Milestone baseline binding.baseline must match the referenced baseline Git identity exactly."
    }

    $freezePath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Binding -Name "freeze_ref" -Context "Milestone baseline binding") -Context "Milestone baseline binding.freeze_ref") -Label "Milestone baseline binding freeze"
    $freezePath = Assert-ResolvedPathInsideRepository -ResolvedPath $freezePath -RepositoryRoot $resolvedBaselineRepositoryRoot -RepositoryWorktreeRoot $baselineRepositoryWorktreeRoot -Label "Milestone baseline binding freeze"
    $freezeValidation = & (Get-MilestoneFreezeValidatorCommand) -FreezePath $freezePath
    $freeze = Get-JsonDocument -Path $freezeValidation.FreezePath -Label "Milestone freeze"
    if ($freezeValidation.FreezeId -ne $freezeId) {
        throw "Milestone baseline binding.freeze_id must match the referenced freeze."
    }
    if ($freezeValidation.CycleId -ne $cycleId) {
        throw "Milestone baseline binding.cycle_id must match the referenced freeze."
    }

    $resolvedProposalPath = Assert-ResolvedPathInsideRepository -ResolvedPath $freezeValidation.ProposalPath -RepositoryRoot $resolvedBaselineRepositoryRoot -RepositoryWorktreeRoot $baselineRepositoryWorktreeRoot -Label "Milestone freeze proposal"
    $proposal = Get-JsonDocument -Path $resolvedProposalPath -Label "Milestone proposal"
    $proposalDirectory = Split-Path -Parent $resolvedProposalPath
    $milestonePath = Resolve-ReferenceAgainstBase -BaseDirectory $proposalDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $proposal -Name "milestone_ref" -Context "Milestone proposal") -Context "Milestone proposal.milestone_ref") -Label "Milestone proposal milestone"
    $milestonePath = Assert-ResolvedPathInsideRepository -ResolvedPath $milestonePath -RepositoryRoot $resolvedBaselineRepositoryRoot -RepositoryWorktreeRoot $baselineRepositoryWorktreeRoot -Label "Milestone proposal milestone"
    $milestoneInput = Resolve-ValidatedMilestoneBaselineMilestoneInput -MilestonePath $milestonePath -RepositoryRoot $resolvedBaselineRepositoryRoot -RepositoryWorktreeRoot $baselineRepositoryWorktreeRoot

    $milestone = Assert-ObjectValue -Value (Get-RequiredProperty -Object $Binding -Name "milestone" -Context "Milestone baseline binding") -Context "Milestone baseline binding.milestone"
    foreach ($fieldName in @($contract.milestone_required_fields)) {
        Get-RequiredProperty -Object $milestone -Name $fieldName -Context "Milestone baseline binding.milestone" | Out-Null
    }

    if ((Assert-NonEmptyString -Value (Get-RequiredProperty -Object $milestone -Name "object_type" -Context "Milestone baseline binding.milestone") -Context "Milestone baseline binding.milestone.object_type") -ne "milestone") {
        throw "Milestone baseline binding.milestone.object_type must equal 'milestone'."
    }

    $resolvedBindingMilestonePath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $milestone -Name "ref" -Context "Milestone baseline binding.milestone") -Context "Milestone baseline binding.milestone.ref") -Label "Milestone baseline binding milestone"
    $resolvedBindingMilestonePath = Assert-ResolvedPathInsideRepository -ResolvedPath $resolvedBindingMilestonePath -RepositoryRoot $resolvedBaselineRepositoryRoot -RepositoryWorktreeRoot $baselineRepositoryWorktreeRoot -Label "Milestone baseline binding milestone"
    if ($resolvedBindingMilestonePath -ine $milestoneInput.Validation.WorkObjectPath) {
        throw "Milestone baseline binding.milestone.ref must resolve to the freeze milestone."
    }
    if ($milestone.object_id -ne $milestoneInput.Document.object_id -or $milestone.status -ne $milestoneInput.Document.status) {
        throw "Milestone baseline binding.milestone must match the freeze milestone identity and status."
    }
    if ($baselineDocument.milestone.object_id -ne $milestone.object_id -or (Resolve-ReferenceAgainstBase -BaseDirectory (Split-Path -Parent $baselineValidation.BaselinePath) -Reference $baselineDocument.milestone.ref -Label "Milestone baseline binding baseline milestone") -ine $resolvedBindingMilestonePath) {
        throw "Milestone baseline binding baseline milestone must match the bound milestone."
    }

    $planningRecordRefs = [object[]](Assert-ObjectArray -Value (Get-RequiredProperty -Object $Binding -Name "planning_record_refs" -Context "Milestone baseline binding") -Context "Milestone baseline binding.planning_record_refs")
    if ($planningRecordRefs.Count -ne @($freeze.frozen_task_set).Count) {
        throw "Milestone baseline binding.planning_record_refs must match the frozen task count exactly."
    }

    $freezeTasksById = @{}
    foreach ($freezeTask in @($freeze.frozen_task_set)) {
        $freezeTasksById[$freezeTask.task_id] = $freezeTask
    }

    $resolvedBindingPlanningRefs = @()
    $resolvedBindingAcceptedRefs = @()
    foreach ($planningRecordRef in $planningRecordRefs) {
        foreach ($fieldName in @($contract.planning_record_ref_required_fields)) {
            Get-RequiredProperty -Object $planningRecordRef -Name $fieldName -Context "Milestone baseline binding.planning_record_refs item" | Out-Null
        }

        $planningView = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $planningRecordRef -Name "view" -Context "Milestone baseline binding.planning_record_refs item") -Context "Milestone baseline binding.planning_record_refs item.view"
        if ($planningView -ne "accepted") {
            throw "Milestone baseline binding.planning_record_refs item.view must equal 'accepted'."
        }

        $taskId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $planningRecordRef -Name "object_id" -Context "Milestone baseline binding.planning_record_refs item") -Context "Milestone baseline binding.planning_record_refs item.object_id"
        if (-not $freezeTasksById.ContainsKey($taskId)) {
            throw "Milestone baseline binding.planning_record_refs item.object_id must resolve to a frozen task id."
        }

        $resolvedPlanningRecordPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $planningRecordRef -Name "ref" -Context "Milestone baseline binding.planning_record_refs item") -Context "Milestone baseline binding.planning_record_refs item.ref") -Label "Milestone baseline binding planning record"
        $resolvedPlanningRecordPath = Assert-ResolvedPathInsideRepository -ResolvedPath $resolvedPlanningRecordPath -RepositoryRoot $resolvedBaselineRepositoryRoot -RepositoryWorktreeRoot $baselineRepositoryWorktreeRoot -Label "Milestone baseline binding planning record"
        $planningRecordInput = Resolve-PlanningRecordBaselineInput -PlanningRecordPath $resolvedPlanningRecordPath -MilestoneDocument $milestoneInput.Document -MilestonePath $milestoneInput.Validation.WorkObjectPath -RepositoryRoot $resolvedBaselineRepositoryRoot -RepositoryWorktreeRoot $baselineRepositoryWorktreeRoot
        $resolvedAcceptedRecordPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $planningRecordRef -Name "accepted_record_ref" -Context "Milestone baseline binding.planning_record_refs item") -Context "Milestone baseline binding.planning_record_refs item.accepted_record_ref") -Label "Milestone baseline binding accepted planning record"
        if ($resolvedAcceptedRecordPath -ne $planningRecordInput.AcceptedRecordPath) {
            throw "Milestone baseline binding.planning_record_refs item.accepted_record_ref must match the referenced planning record accepted surface."
        }

        if ($planningRecordInput.Validation.PlanningRecordId -ne $planningRecordRef.planning_record_id -or $planningRecordInput.Validation.ObjectType -ne $planningRecordRef.object_type -or $planningRecordInput.Validation.ObjectId -ne $planningRecordRef.object_id) {
            throw "Milestone baseline binding.planning_record_refs item identity must match the referenced planning record."
        }

        $freezeTask = $freezeTasksById[$taskId]
        if ($planningRecordInput.AcceptedRecord.title -ne $freezeTask.title -or $planningRecordInput.AcceptedRecord.task_kind -ne $freezeTask.task_kind -or $planningRecordInput.AcceptedRecord.scope_summary -ne $freezeTask.scope_summary -or $planningRecordInput.AcceptedRecord.requested_outcome -ne $freezeTask.requested_outcome) {
            throw "Materialized accepted planning records must preserve the frozen task content exactly."
        }
        if (($planningRecordInput.AcceptedRecord.acceptance_checks -join "|") -ne (@($freezeTask.acceptance_checks) -join "|") -or ($planningRecordInput.AcceptedRecord.non_goals -join "|") -ne (@($freezeTask.non_goals) -join "|")) {
            throw "Materialized accepted planning records must preserve the frozen task acceptance and non-goal lists exactly."
        }
        if ($planningRecordInput.AcceptedRecord.status -ne "ready") {
            throw "Materialized accepted planning records must normalize frozen tasks into ready task surfaces."
        }

        $relationshipTaskIds = @($planningRecordInput.AcceptedRecord.relationships | Where-Object { $_.relation -eq "depends_on" } | ForEach-Object { $_.object_id })
        if (($relationshipTaskIds -join "|") -ne (@($freezeTask.depends_on_ids) -join "|")) {
            throw "Materialized accepted planning records must preserve frozen task dependency ids exactly."
        }

        $resolvedBindingPlanningRefs += $planningRecordInput.Validation.PlanningRecordPath
        $resolvedBindingAcceptedRefs += $planningRecordInput.AcceptedRecordPath
    }

    $baselinePlanningRefs = @()
    $baselineAcceptedRefs = @()
    foreach ($baselinePlanningRecordRef in @($baselineDocument.planning_record_refs)) {
        $baselinePlanningRefs += Resolve-ReferenceAgainstBase -BaseDirectory (Split-Path -Parent $baselineValidation.BaselinePath) -Reference $baselinePlanningRecordRef.ref -Label "Milestone baseline binding baseline planning record"
        $baselineAcceptedRefs += Resolve-ReferenceAgainstBase -BaseDirectory (Split-Path -Parent $baselineValidation.BaselinePath) -Reference $baselinePlanningRecordRef.accepted_record_ref -Label "Milestone baseline binding baseline accepted planning record"
    }

    if (($baselinePlanningRefs -join "|") -ne ($resolvedBindingPlanningRefs -join "|") -or ($baselineAcceptedRefs -join "|") -ne ($resolvedBindingAcceptedRefs -join "|")) {
        throw "Milestone baseline binding planning_record_refs must match the referenced baseline planning refs exactly."
    }

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Binding -Name "notes" -Context "Milestone baseline binding") -Context "Milestone baseline binding.notes" | Out-Null

    return [pscustomobject]@{
        BindingId   = $bindingId
        CycleId     = $cycleId
        FreezePath  = $freezeValidation.FreezePath
        BaselineId  = $baselineSummaryId
        BaselinePath = $baselineValidation.BaselinePath
    }
}

function Test-MilestoneAutocycleBaselineBindingContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$BindingPath
    )

    $resolvedBindingPath = Resolve-ExistingPath -PathValue $BindingPath -Label "Milestone baseline binding" -AnchorPath (Get-ModuleRepositoryRootPath)
    $binding = Get-JsonDocument -Path $resolvedBindingPath -Label "Milestone baseline binding"
    $result = Validate-BaselineBindingFields -Binding $binding -BaseDirectory (Split-Path -Parent $resolvedBindingPath)

    return [pscustomobject]@{
        IsValid      = $true
        BindingId    = $result.BindingId
        CycleId      = $result.CycleId
        FreezePath   = $result.FreezePath
        BaselineId   = $result.BaselineId
        BaselinePath = $result.BaselinePath
        BindingPath  = $resolvedBindingPath
    }
}

function Invoke-MilestoneFreezeBaselineBindingFlow {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$FreezePath,
        [Parameter(Mandatory = $true)]
        [string]$OutputRoot,
        [string]$RepositoryRoot = (Get-RepositoryRoot),
        [string]$BindingId,
        [string]$BaselineId,
        [datetime]$BoundAt = (Get-Date).ToUniversalTime()
    )

    $foundation = Get-MilestoneAutocycleFoundationContract
    $bindingInput = Get-FreezeBaselineBindingInput -FreezePath $FreezePath -RepositoryRoot $RepositoryRoot
    $resolvedOutputRoot = Resolve-PathForCreationInsideRepository -PathValue $OutputRoot -RepositoryRoot $bindingInput.RepositoryRoot -RepositoryWorktreeRoot $bindingInput.RepositoryWorktreeRoot -Label "Milestone baseline binding output root"
    New-Item -ItemType Directory -Path $resolvedOutputRoot -Force | Out-Null

    if ([string]::IsNullOrWhiteSpace($BindingId)) {
        $BindingId = "baseline-binding-{0}" -f $bindingInput.Freeze.freeze_id
    }
    if ([string]::IsNullOrWhiteSpace($BaselineId)) {
        $BaselineId = "baseline-{0}" -f $bindingInput.Freeze.freeze_id
    }

    Assert-RegexMatch -Value $BindingId -Pattern $foundation.identifier_pattern -Context "BindingId"
    Assert-RegexMatch -Value $BaselineId -Pattern $foundation.identifier_pattern -Context "BaselineId"

    $gitCapture = Get-CleanGitBaselineCapture -RepositoryRoot $bindingInput.RepositoryRoot
    $materializedPlanning = Materialize-FreezePlanningRecordBridge -BindingInput $bindingInput -OutputRoot $resolvedOutputRoot -BoundAt $BoundAt
    $baseline = Build-MilestoneBaselineRecord -BaselineId $BaselineId -MilestoneInput $bindingInput.MilestoneInput -PlanningRecordPaths @($materializedPlanning.MaterializedPlanningRecords.PlanningRecordPath) -OperatorId $bindingInput.Freeze.approved_by -AuthorityReason ("Bind frozen milestone '{0}' to one Git-backed baseline anchor before dispatch." -f $bindingInput.Freeze.freeze_id) -GitCapture $gitCapture -CapturedAt $BoundAt -CapturedById "control-kernel:milestone-autocycle-baseline-binding" -BaselineKind "milestone_checkpoint"

    $baselineStorePath = Join-Path $resolvedOutputRoot "baseline_store"
    $baselinePath = Save-MilestoneBaselineRecord -Baseline $baseline -StorePath $baselineStorePath
    $loadedBaseline = Get-MilestoneBaselineRecord -BaselineId $baseline.baseline_id -StorePath $baselineStorePath

    $bindingDirectory = Join-Path $resolvedOutputRoot "baseline_bindings"
    New-Item -ItemType Directory -Path $bindingDirectory -Force | Out-Null
    $binding = [pscustomobject]@{
        contract_version = $foundation.contract_version
        record_type      = $foundation.baseline_binding_record_type
        binding_id       = $BindingId
        cycle_id         = $bindingInput.Freeze.cycle_id
        freeze_id        = $bindingInput.Freeze.freeze_id
        freeze_ref       = Get-RelativeReference -BaseDirectory $bindingDirectory -TargetPath $bindingInput.FreezeValidation.FreezePath
        milestone        = [pscustomobject]@{
            object_type = "milestone"
            object_id   = $bindingInput.MilestoneInput.Document.object_id
            ref         = Get-RelativeReference -BaseDirectory $bindingDirectory -TargetPath $bindingInput.MilestoneInput.Validation.WorkObjectPath
            status      = $bindingInput.MilestoneInput.Document.status
        }
        bound_at         = Get-UtcTimestamp -DateTime $BoundAt
        planning_record_refs = @($materializedPlanning.MaterializedPlanningRecords | ForEach-Object {
                [pscustomobject]@{
                    planning_record_id  = $_.PlanningRecordValidation.PlanningRecordId
                    object_type         = $_.PlanningRecordValidation.ObjectType
                    object_id           = $_.PlanningRecordValidation.ObjectId
                    view                = "accepted"
                    ref                 = Get-RelativeReference -BaseDirectory $bindingDirectory -TargetPath $_.PlanningRecordValidation.PlanningRecordPath
                    accepted_record_ref = Get-RelativeReference -BaseDirectory $bindingDirectory -TargetPath $_.PlanningRecordValidation.AcceptedRecordPath
                    notes               = "Accepted planning record materialized from the approved frozen task set for baseline capture."
                }
            })
        baseline         = [pscustomobject]@{
            baseline_id     = $loadedBaseline.Baseline.baseline_id
            baseline_ref    = Get-RelativeReference -BaseDirectory $bindingDirectory -TargetPath $baselinePath
            repository_root = $loadedBaseline.Baseline.git.repository_root
            branch          = $loadedBaseline.Baseline.git.branch
            head_commit     = $loadedBaseline.Baseline.git.head_commit
            tree_id         = $loadedBaseline.Baseline.git.tree_id
        }
        notes            = "Frozen milestone bound to one Git-backed baseline by materializing accepted planning-record bridge surfaces and reusing the existing milestone baseline substrate only."
    }

    $bindingPath = Join-Path $bindingDirectory ("{0}.json" -f $BindingId)
    Write-JsonDocument -Path $bindingPath -Document $binding
    $bindingValidation = Test-MilestoneAutocycleBaselineBindingContract -BindingPath $bindingPath

    return [pscustomobject]@{
        BindingValidation  = $bindingValidation
        BindingPath        = $bindingValidation.BindingPath
        BaselinePath       = $baselinePath
        BaselineId         = $loadedBaseline.Baseline.baseline_id
        FreezePath         = $bindingInput.FreezeValidation.FreezePath
        PlanningRecordPaths = @($materializedPlanning.MaterializedPlanningRecords.PlanningRecordPath)
    }
}

function Save-MilestoneBaselineRecord {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Baseline,
        [Parameter(Mandatory = $true)]
        [string]$StorePath
    )

    Validate-BaselineFields -Baseline $Baseline -BaseDirectory (Get-ModuleRepositoryRootPath)

    $resolvedStorePath = Resolve-PathValue -PathValue $StorePath -AnchorPath (Get-ModuleRepositoryRootPath)
    if (-not (Test-Path -LiteralPath $resolvedStorePath)) {
        New-Item -ItemType Directory -Path $resolvedStorePath -Force | Out-Null
    }

    $baselineDirectory = Join-Path $resolvedStorePath "milestone_baselines"
    if (-not (Test-Path -LiteralPath $baselineDirectory)) {
        New-Item -ItemType Directory -Path $baselineDirectory -Force | Out-Null
    }

    $persistedBaseline = [pscustomobject]@{
        contract_version = $Baseline.contract_version
        record_type      = $Baseline.record_type
        baseline_id      = $Baseline.baseline_id
        baseline_kind    = $Baseline.baseline_kind
        milestone        = [pscustomobject]@{
            object_id = $Baseline.milestone.object_id
            ref       = (Get-NormalizedReferenceForSave -BaselineDirectory $baselineDirectory -Reference $Baseline.milestone.ref)
            status    = $Baseline.milestone.status
        }
        captured_at      = $Baseline.captured_at
        captured_by      = $Baseline.captured_by
        authority        = $Baseline.authority
        git              = $Baseline.git
        planning_record_refs = @($Baseline.planning_record_refs | ForEach-Object {
                [pscustomobject]@{
                    planning_record_id  = $_.planning_record_id
                    object_type         = $_.object_type
                    object_id           = $_.object_id
                    view                = $_.view
                    ref                 = (Get-NormalizedReferenceForSave -BaselineDirectory $baselineDirectory -Reference $_.ref)
                    accepted_record_ref = (Get-NormalizedReferenceForSave -BaselineDirectory $baselineDirectory -Reference $_.accepted_record_ref)
                    notes               = $_.notes
                }
            })
        evidence         = @($Baseline.evidence | ForEach-Object {
                [pscustomobject]@{
                    kind    = $_.kind
                    ref     = (Get-NormalizedReferenceForSave -BaselineDirectory $baselineDirectory -Reference $_.ref)
                    summary = $_.summary
                }
            })
        notes            = $Baseline.notes
    }

    $contract = Get-BaselineContract
    $baselinePath = Join-Path $baselineDirectory ("{0}.json" -f $persistedBaseline.baseline_id)
    if (Test-Path -LiteralPath $baselinePath) {
        if ($contract.save_rules.baseline_id_collision_policy -ne "overwrite_existing") {
            throw "Milestone baseline save does not permit reusing baseline_id '$($persistedBaseline.baseline_id)'."
        }
    }

    Write-JsonDocument -Path $baselinePath -Document $persistedBaseline
    Test-MilestoneBaselineRecordContract -BaselinePath $baselinePath | Out-Null

    return $baselinePath
}

function Get-MilestoneBaselineRecord {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaselineId,
        [Parameter(Mandatory = $true)]
        [string]$StorePath
    )

    $resolvedStorePath = Resolve-PathValue -PathValue $StorePath -AnchorPath (Get-ModuleRepositoryRootPath)
    $baselinePath = Join-Path (Join-Path $resolvedStorePath "milestone_baselines") ("{0}.json" -f $BaselineId)
    $validation = Test-MilestoneBaselineRecordContract -BaselinePath $baselinePath
    $baseline = Get-JsonDocument -Path $validation.BaselinePath -Label "Milestone baseline"

    return [pscustomobject]@{
        Validation = $validation
        Baseline   = $baseline
    }
}

Export-ModuleMember -Function Test-MilestoneBaselineRecordContract, New-MilestoneBaselineRecord, Save-MilestoneBaselineRecord, Get-MilestoneBaselineRecord, Test-MilestoneAutocycleBaselineBindingContract, Invoke-MilestoneFreezeBaselineBindingFlow
