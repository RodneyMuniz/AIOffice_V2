Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$planningRecordStorageModule = Import-Module (Join-Path $PSScriptRoot "PlanningRecordStorage.psm1") -Force -PassThru
$governedWorkObjectValidationModule = Import-Module (Join-Path $PSScriptRoot "GovernedWorkObjectValidation.psm1") -Force -PassThru

$testPlanningRecordContract = $planningRecordStorageModule.ExportedCommands["Test-PlanningRecordContract"]
$testGovernedWorkObjectContract = $governedWorkObjectValidationModule.ExportedCommands["Test-GovernedWorkObjectContract"]

function Get-RepositoryRoot {
    return $repoRoot
}

function Resolve-PathValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return $PathValue
    }

    return Join-Path (Get-Location) $PathValue
}

function Resolve-ExistingPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $resolvedPath = Resolve-PathValue -PathValue $PathValue
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

    $resolvedPath = Resolve-ExistingPath -PathValue $PathValue -Label $Label
    return Assert-ResolvedPathInsideRepository -ResolvedPath $resolvedPath -RepositoryRoot $RepositoryRoot -RepositoryWorktreeRoot $RepositoryWorktreeRoot -Label $Label
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

function Get-GitValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

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

    $normalizedBranch = Assert-NonEmptyString -Value $Branch -Context "Milestone baseline.git.branch"
    if ($Foundation.git_branch_validation_mode -eq "git_check_ref_format_branch") {
        $null = (& git -C $RepositoryRoot check-ref-format --branch $normalizedBranch 2>&1)
        if ($LASTEXITCODE -ne 0) {
            throw "Milestone baseline.git.branch must be a structurally valid Git branch name."
        }
    }

    if ($Foundation.git_branch_must_exist_in_repository) {
        & git -C $RepositoryRoot show-ref --verify --quiet ("refs/heads/{0}" -f $normalizedBranch) 2>$null
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

    $normalizedObjectId = Assert-NonEmptyString -Value $ObjectId -Context $Context
    Assert-RegexMatch -Value $normalizedObjectId -Pattern $Pattern -Context $Context

    if ($MustExistInRepository) {
        & git -C $RepositoryRoot cat-file -e $ObjectSpec 2>$null
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

    $branch = (Get-GitValue -RepositoryRoot $RepositoryRoot -Arguments @("branch", "--show-current") -Label "Git branch").Trim()
    if ([string]::IsNullOrWhiteSpace($branch)) {
        throw "Milestone baseline capture requires a non-empty Git branch."
    }

    return $branch
}

function Get-GitHeadCommit {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $head = (Get-GitValue -RepositoryRoot $RepositoryRoot -Arguments @("rev-parse", "HEAD") -Label "Git HEAD commit").Trim()
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

    $treeId = (Get-GitValue -RepositoryRoot $RepositoryRoot -Arguments @("rev-parse", "HEAD^{tree}") -Label "Git tree id").Trim()
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

    $statusOutput = & git -C $RepositoryRoot status --short --untracked-files=all 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to resolve Git status for milestone baseline capture."
    }

    return @($statusOutput | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Resolve-PlanningRecordBaselineInput {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PlanningRecordPath,
        [Parameter(Mandatory = $true)]
        $MilestoneDocument,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryWorktreeRoot
    )

    $resolvedPlanningRecordPath = Resolve-PathInsideRepository -PathValue $PlanningRecordPath -RepositoryRoot $RepositoryRoot -RepositoryWorktreeRoot $RepositoryWorktreeRoot -Label "Planning record"
    $validation = & $testPlanningRecordContract -PlanningRecordPath $resolvedPlanningRecordPath
    $planningRecord = Get-JsonDocument -Path $validation.PlanningRecordPath -Label "Planning record"
    if ($planningRecord.accepted_state.status -ne "accepted") {
        throw "Milestone baseline capture requires accepted planning records only."
    }

    $acceptedRecordRef = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $planningRecord.accepted_state -Name "record_ref" -Context "PlanningRecord.accepted_state") -Context "PlanningRecord.accepted_state.record_ref"
    $acceptedRecordPath = Resolve-ReferenceAgainstBase -BaseDirectory (Split-Path -Parent $validation.PlanningRecordPath) -Reference $acceptedRecordRef -Label "Planning record accepted surface"
    $acceptedRecordPath = Assert-ResolvedPathInsideRepository -ResolvedPath $acceptedRecordPath -RepositoryRoot $RepositoryRoot -RepositoryWorktreeRoot $RepositoryWorktreeRoot -Label "Planning record accepted surface"
    $acceptedRecordValidation = & $testGovernedWorkObjectContract -WorkObjectPath $acceptedRecordPath
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

    return [pscustomobject]@{
        Validation         = $validation
        PlanningRecord     = $planningRecord
        AcceptedRecordPath = $acceptedRecordPath
        AcceptedRecord     = $acceptedRecord
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
    $milestoneValidation = & $testGovernedWorkObjectContract -WorkObjectPath $milestonePath
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

    $baselineRepositoryRoot = Resolve-ExistingPath -PathValue (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $git -Name "repository_root" -Context "Milestone baseline.git") -Context "Milestone baseline.git.repository_root") -Label "Milestone baseline.git.repository_root"
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

    foreach ($planningRecordRef in $planningRecordRefs) {
        foreach ($fieldName in $foundation.planning_record_ref_required_fields) {
            Get-RequiredProperty -Object $planningRecordRef -Name $fieldName -Context "Milestone baseline.planning_record_refs item" | Out-Null
        }

        $planningView = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $planningRecordRef -Name "view" -Context "Milestone baseline.planning_record_refs item") -Context "Milestone baseline.planning_record_refs item.view"
        Assert-AllowedValue -Value $planningView -AllowedValues @($foundation.allowed_planning_record_views) -Context "Milestone baseline.planning_record_refs item.view"

        $planningRecordPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $planningRecordRef -Name "ref" -Context "Milestone baseline.planning_record_refs item") -Context "Milestone baseline.planning_record_refs item.ref") -Label "Milestone baseline planning record"
        $planningRecordInput = Resolve-PlanningRecordBaselineInput -PlanningRecordPath $planningRecordPath -MilestoneDocument $milestoneDocument -RepositoryRoot $baselineRepositoryRoot -RepositoryWorktreeRoot $baselineRepositoryWorktreeRoot

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

        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $planningRecordRef -Name "notes" -Context "Milestone baseline.planning_record_refs item") -Context "Milestone baseline.planning_record_refs item.notes" | Out-Null
    }

    $evidence = [object[]](Assert-ObjectArray -Value (Get-RequiredProperty -Object $Baseline -Name "evidence" -Context "Milestone baseline") -Context "Milestone baseline.evidence")
    $planningRecordEvidenceFound = $false
    foreach ($evidenceItem in $evidence) {
        foreach ($fieldName in $foundation.evidence_required_fields) {
            Get-RequiredProperty -Object $evidenceItem -Name $fieldName -Context "Milestone baseline.evidence item" | Out-Null
        }

        $evidenceKind = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $evidenceItem -Name "kind" -Context "Milestone baseline.evidence item") -Context "Milestone baseline.evidence item.kind"
        Assert-AllowedValue -Value $evidenceKind -AllowedValues @($foundation.allowed_evidence_kinds) -Context "Milestone baseline.evidence item.kind"
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $evidenceItem -Name "ref" -Context "Milestone baseline.evidence item") -Context "Milestone baseline.evidence item.ref" | Out-Null
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $evidenceItem -Name "summary" -Context "Milestone baseline.evidence item") -Context "Milestone baseline.evidence item.summary" | Out-Null
        if ($evidenceKind -eq "planning_record") {
            $planningRecordEvidenceFound = $true
        }
    }

    if ($contract.evidence_rules.planning_record_evidence_required -and -not $planningRecordEvidenceFound) {
        throw "Milestone baseline records must include planning_record evidence."
    }

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Baseline -Name "notes" -Context "Milestone baseline") -Context "Milestone baseline.notes" | Out-Null
}

function Test-MilestoneBaselineRecordContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaselinePath
    )

    $resolvedBaselinePath = Resolve-ExistingPath -PathValue $BaselinePath -Label "Milestone baseline"
    $baseline = Get-JsonDocument -Path $resolvedBaselinePath -Label "Milestone baseline"
    Validate-BaselineFields -Baseline $baseline -BaseDirectory (Split-Path -Parent $resolvedBaselinePath)

    return [pscustomobject]@{
        IsValid      = $true
        BaselineId   = $baseline.baseline_id
        BaselinePath = $resolvedBaselinePath
    }
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
    $resolvedMilestonePath = Resolve-PathInsideRepository -PathValue $MilestonePath -RepositoryRoot $resolvedRepositoryRoot -RepositoryWorktreeRoot $repositoryWorktreeRoot -Label "Milestone"
    $milestoneValidation = & $testGovernedWorkObjectContract -WorkObjectPath $resolvedMilestonePath
    if ($milestoneValidation.ObjectType -ne "milestone") {
        throw "Milestone baseline capture requires a milestone governed work object."
    }

    $milestoneDocument = Get-JsonDocument -Path $milestoneValidation.WorkObjectPath -Label "Milestone"
    if (@($foundation.allowed_milestone_statuses) -notcontains $milestoneDocument.status) {
        throw "Milestone baseline capture requires milestone status 'active' or 'completed'."
    }

    $statusLines = @(Get-GitStatusLines -RepositoryRoot $resolvedRepositoryRoot)
    if ($statusLines.Count -ne 0) {
        throw "Milestone baseline capture requires a clean Git worktree."
    }

    $createdAtText = Get-UtcTimestamp -DateTime $CapturedAt
    $branch = Get-GitBranchName -RepositoryRoot $resolvedRepositoryRoot
    $headCommit = Get-GitHeadCommit -RepositoryRoot $resolvedRepositoryRoot
    $treeId = Get-GitTreeId -RepositoryRoot $resolvedRepositoryRoot

    $planningRecordRefs = @()
    $evidence = @()
    foreach ($planningRecordPath in @($PlanningRecordPaths)) {
        $planningRecordInput = Resolve-PlanningRecordBaselineInput -PlanningRecordPath $planningRecordPath -MilestoneDocument $milestoneDocument -RepositoryRoot $resolvedRepositoryRoot -RepositoryWorktreeRoot $repositoryWorktreeRoot

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
    }

    $evidence += [pscustomobject]@{
        kind    = "artifact"
        ref     = $milestoneValidation.WorkObjectPath
        summary = "Milestone work object captured as the baseline scope anchor."
    }

    $baseline = [pscustomobject]@{
        contract_version = $foundation.contract_version
        record_type      = $foundation.record_type
        baseline_id      = $BaselineId
        baseline_kind    = $BaselineKind
        milestone        = [pscustomobject]@{
            object_id = $milestoneDocument.object_id
            ref       = $milestoneValidation.WorkObjectPath
            status    = $milestoneDocument.status
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
            repository_root             = $resolvedRepositoryRoot
            branch                      = $branch
            head_commit                 = $headCommit
            tree_id                     = $treeId
            status_lines                = @($statusLines)
            working_tree_clean          = $true
            captured_from_clean_worktree = $true
        }
        planning_record_refs = @($planningRecordRefs)
        evidence         = @($evidence)
        notes            = "Git-backed milestone baseline captured from a clean worktree. This is a restore target substrate only and does not claim rollback execution."
    }

    Validate-BaselineFields -Baseline $baseline -BaseDirectory (Get-Location).Path
    return $baseline
}

function Save-MilestoneBaselineRecord {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Baseline,
        [Parameter(Mandatory = $true)]
        [string]$StorePath
    )

    $resolvedStorePath = Resolve-PathValue -PathValue $StorePath
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

    $baselinePath = Join-Path $baselineDirectory ("{0}.json" -f $persistedBaseline.baseline_id)
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

    $resolvedStorePath = Resolve-PathValue -PathValue $StorePath
    $baselinePath = Join-Path (Join-Path $resolvedStorePath "milestone_baselines") ("{0}.json" -f $BaselineId)
    $validation = Test-MilestoneBaselineRecordContract -BaselinePath $baselinePath
    $baseline = Get-JsonDocument -Path $validation.BaselinePath -Label "Milestone baseline"

    return [pscustomobject]@{
        Validation = $validation
        Baseline   = $baseline
    }
}

Export-ModuleMember -Function Test-MilestoneBaselineRecordContract, New-MilestoneBaselineRecord, Save-MilestoneBaselineRecord, Get-MilestoneBaselineRecord
