Set-StrictMode -Version Latest

$rollbackPlanModule = Import-Module (Join-Path $PSScriptRoot "MilestoneRollbackPlan.psm1") -Force -PassThru
$testMilestoneRollbackPlanContract = $rollbackPlanModule.ExportedCommands["Test-MilestoneRollbackPlanContract"]
$getMilestoneRollbackPlan = $rollbackPlanModule.ExportedCommands["Get-MilestoneRollbackPlan"]

function Resolve-ArtifactPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArtifactPath,
        [string]$AnchorPath = (Get-Location)
    )

    $resolvedPath = if ([System.IO.Path]::IsPathRooted($ArtifactPath)) {
        $ArtifactPath
    }
    else {
        Join-Path $AnchorPath $ArtifactPath
    }

    if (-not (Test-Path -LiteralPath $resolvedPath)) {
        throw "Rollback-drill artifact path '$ArtifactPath' does not exist."
    }

    return (Resolve-Path -LiteralPath $resolvedPath).Path
}

function Resolve-AbsolutePathValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [string]$AnchorPath = (Get-Location)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $AnchorPath $PathValue))
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

function Assert-AbsolutePathString {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $pathValue = Assert-NonEmptyString -Value $Value -Context $Context
    if (-not [System.IO.Path]::IsPathRooted($pathValue)) {
        throw "$Context must be an absolute path."
    }

    return ([System.IO.Path]::GetFullPath($pathValue))
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

function Get-MilestoneContinuityFoundationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_continuity\foundation.contract.json") -Label "Milestone continuity foundation contract"
}

function Get-MilestoneRollbackDrillAuthorizationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_continuity\rollback_drill_authorization.contract.json") -Label "Rollback drill authorization contract"
}

function Get-MilestoneRollbackDrillResultContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_continuity\rollback_drill_result.contract.json") -Label "Rollback drill result contract"
}

function Assert-GitCliAvailable {
    $gitCommand = Get-Command git -ErrorAction SilentlyContinue
    if ($null -eq $gitCommand) {
        throw "Rollback drill requires Git CLI to be installed and callable."
    }

    return $gitCommand
}

function Invoke-GitCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-GitCliAvailable | Out-Null
    $processStartInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processStartInfo.FileName = "git"
    $processStartInfo.UseShellExecute = $false
    $processStartInfo.RedirectStandardOutput = $true
    $processStartInfo.RedirectStandardError = $true
    $processStartInfo.WorkingDirectory = $RepositoryRoot

    $escapedArguments = @("-C", $RepositoryRoot) + $Arguments | ForEach-Object {
        if ($_ -match '[\s"]') {
            '"' + ($_ -replace '"', '\"') + '"'
        }
        else {
            $_
        }
    }
    $processStartInfo.Arguments = [string]::Join(" ", $escapedArguments)

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $processStartInfo
    [void]$process.Start()
    $standardOutput = $process.StandardOutput.ReadToEnd()
    $standardError = $process.StandardError.ReadToEnd()
    $process.WaitForExit()

    if ($process.ExitCode -ne 0) {
        $detail = @($standardError.Trim(), $standardOutput.Trim()) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
        $detail = [string]::Join([Environment]::NewLine, $detail)
        if ([string]::IsNullOrWhiteSpace($detail)) {
            throw "$Context failed."
        }

        throw "$Context failed. $detail"
    }

    if ([string]::IsNullOrWhiteSpace($standardOutput)) {
        return @()
    }

    return @($standardOutput -split "(`r`n|`n|`r)" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Get-GitTrimmedValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $output = Invoke-GitCommand -RepositoryRoot $RepositoryRoot -Arguments $Arguments -Context $Context
    return ([string]::Join([Environment]::NewLine, $output)).Trim()
}

function Get-GitObservedState {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    return [pscustomobject]@{
        Branch = Get-GitTrimmedValue -RepositoryRoot $RepositoryRoot -Arguments @("branch", "--show-current") -Context "Git branch resolution"
        HeadCommit = Get-GitTrimmedValue -RepositoryRoot $RepositoryRoot -Arguments @("rev-parse", "HEAD") -Context "Git HEAD resolution"
        TreeId = Get-GitTrimmedValue -RepositoryRoot $RepositoryRoot -Arguments @("rev-parse", "HEAD^{tree}") -Context "Git tree resolution"
    }
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
        throw "$ContextPrefix.resume_authority_state must remain 'operator_review_required' for rollback-drill supervision."
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

function Validate-ObservedState {
    param(
        [Parameter(Mandatory = $true)]
        $ObservedState,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [string]$ContextPrefix
    )

    foreach ($fieldName in @($Contract.observed_state_required_fields)) {
        Get-RequiredProperty -Object $ObservedState -Name $fieldName -Context $ContextPrefix | Out-Null
    }

    $branch = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ObservedState -Name "branch" -Context $ContextPrefix) -Context "$ContextPrefix.branch"
    Assert-RegexMatch -Value $branch -Pattern $Foundation.branch_pattern -Context "$ContextPrefix.branch"
    $headCommit = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ObservedState -Name "head_commit" -Context $ContextPrefix) -Context "$ContextPrefix.head_commit"
    Assert-RegexMatch -Value $headCommit -Pattern $Foundation.git_object_pattern -Context "$ContextPrefix.head_commit"
    $treeId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ObservedState -Name "tree_id" -Context $ContextPrefix) -Context "$ContextPrefix.tree_id"
    Assert-RegexMatch -Value $treeId -Pattern $Foundation.git_object_pattern -Context "$ContextPrefix.tree_id"

    return [pscustomobject]@{
        Branch = $branch
        HeadCommit = $headCommit
        TreeId = $treeId
    }
}

function Validate-RollbackPlanReference {
    param(
        [Parameter(Mandatory = $true)]
        $RollbackPlanRef,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract,
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
    $resolvedRollbackPlanPath = Resolve-ArtifactPath -ArtifactPath $rollbackPlanPathValue -AnchorPath $AnchorPath
    $validation = & $testMilestoneRollbackPlanContract -RollbackPlanPath $resolvedRollbackPlanPath
    $document = & $getMilestoneRollbackPlan -RollbackPlanPath $resolvedRollbackPlanPath

    if ($validation.RollbackPlanId -ne $rollbackPlanId) {
        throw "$ContextPrefix.rollback_plan_id does not match the referenced rollback plan artifact."
    }

    return [pscustomobject]@{
        RollbackPlanId = $validation.RollbackPlanId
        RollbackPlanPath = $resolvedRollbackPlanPath
        Validation = $validation
        Document = $document
    }
}

function Validate-RollbackDrillAuthorizationDocument {
    param(
        [Parameter(Mandatory = $true)]
        $RollbackDrillAuthorization,
        [Parameter(Mandatory = $true)]
        [string]$SourceLabel,
        [AllowNull()]
        [string]$AuthorizationPath
    )

    $foundation = Get-MilestoneContinuityFoundationContract
    $contract = Get-MilestoneRollbackDrillAuthorizationContract

    foreach ($fieldName in @($contract.required_fields)) {
        Get-RequiredProperty -Object $RollbackDrillAuthorization -Name $fieldName -Context "Rollback drill authorization" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackDrillAuthorization -Name "contract_version" -Context "Rollback drill authorization") -Context "Rollback drill authorization.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "Rollback drill authorization.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackDrillAuthorization -Name "record_type" -Context "Rollback drill authorization") -Context "Rollback drill authorization.record_type"
    if ($recordType -ne $foundation.rollback_drill_authorization_record_type -or $recordType -ne $contract.record_type) {
        throw "Rollback drill authorization.record_type must equal '$($foundation.rollback_drill_authorization_record_type)'."
    }

    $authorizationId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackDrillAuthorization -Name "rollback_drill_authorization_id" -Context "Rollback drill authorization") -Context "Rollback drill authorization.rollback_drill_authorization_id"
    Assert-RegexMatch -Value $authorizationId -Pattern $foundation.identifier_pattern -Context "Rollback drill authorization.rollback_drill_authorization_id"

    $rollbackPlanId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackDrillAuthorization -Name "rollback_plan_id" -Context "Rollback drill authorization") -Context "Rollback drill authorization.rollback_plan_id"
    Assert-RegexMatch -Value $rollbackPlanId -Pattern $foundation.identifier_pattern -Context "Rollback drill authorization.rollback_plan_id"

    $approvedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackDrillAuthorization -Name "approved_at" -Context "Rollback drill authorization") -Context "Rollback drill authorization.approved_at"
    Assert-RegexMatch -Value $approvedAt -Pattern $foundation.timestamp_pattern -Context "Rollback drill authorization.approved_at"

    $operatorAuthority = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackDrillAuthorization -Name "operator_authority" -Context "Rollback drill authorization") -Context "Rollback drill authorization.operator_authority"
    Assert-RegexMatch -Value $operatorAuthority -Pattern $foundation.operator_pattern -Context "Rollback drill authorization.operator_authority"

    $requiredAuthorityState = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackDrillAuthorization -Name "required_authority_state" -Context "Rollback drill authorization") -Context "Rollback drill authorization.required_authority_state"
    Assert-AllowedValue -Value $requiredAuthorityState -AllowedValues @($foundation.allowed_resume_authority_states) -Context "Rollback drill authorization.required_authority_state"
    if ($requiredAuthorityState -ne "operator_review_required") {
        throw "Rollback drill authorization.required_authority_state must equal 'operator_review_required'."
    }

    $approvedEnvironmentScope = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackDrillAuthorization -Name "approved_environment_scope" -Context "Rollback drill authorization") -Context "Rollback drill authorization.approved_environment_scope"
    Assert-AllowedValue -Value $approvedEnvironmentScope -AllowedValues @($foundation.allowed_rollback_drill_environment_scopes) -Context "Rollback drill authorization.approved_environment_scope"

    $gitMutationApproved = Assert-BooleanValue -Value (Get-RequiredProperty -Object $RollbackDrillAuthorization -Name "git_mutation_approved" -Context "Rollback drill authorization") -Context "Rollback drill authorization.git_mutation_approved"
    if (-not $gitMutationApproved) {
        throw "Rollback drill authorization.git_mutation_approved must remain true."
    }

    $primaryWorktreeExecution = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackDrillAuthorization -Name "primary_worktree_execution" -Context "Rollback drill authorization") -Context "Rollback drill authorization.primary_worktree_execution"
    Assert-AllowedValue -Value $primaryWorktreeExecution -AllowedValues @($foundation.allowed_rollback_primary_worktree_execution_states) -Context "Rollback drill authorization.primary_worktree_execution"

    $notes = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackDrillAuthorization -Name "notes" -Context "Rollback drill authorization") -Context "Rollback drill authorization.notes"

    return [pscustomobject]@{
        IsValid = $true
        RollbackDrillAuthorizationId = $authorizationId
        RollbackPlanId = $rollbackPlanId
        ApprovedAt = $approvedAt
        OperatorAuthority = $operatorAuthority
        RequiredAuthorityState = $requiredAuthorityState
        ApprovedEnvironmentScope = $approvedEnvironmentScope
        GitMutationApproved = $gitMutationApproved
        PrimaryWorktreeExecution = $primaryWorktreeExecution
        AuthorizationPath = $AuthorizationPath
        SourceLabel = $SourceLabel
        Notes = $notes
    }
}

function Validate-RollbackDrillAuthorizationReference {
    param(
        [Parameter(Mandatory = $true)]
        $AuthorizationRef,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [string]$ContextPrefix,
        [string]$AnchorPath = (Get-Location)
    )

    foreach ($fieldName in @($Contract.rollback_drill_authorization_ref_required_fields)) {
        Get-RequiredProperty -Object $AuthorizationRef -Name $fieldName -Context $ContextPrefix | Out-Null
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $AuthorizationRef -Name "record_type" -Context $ContextPrefix) -Context "$ContextPrefix.record_type"
    if ($recordType -ne $Foundation.rollback_drill_authorization_record_type) {
        throw "$ContextPrefix.record_type must equal '$($Foundation.rollback_drill_authorization_record_type)'."
    }

    $authorizationId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $AuthorizationRef -Name "rollback_drill_authorization_id" -Context $ContextPrefix) -Context "$ContextPrefix.rollback_drill_authorization_id"
    Assert-RegexMatch -Value $authorizationId -Pattern $Foundation.identifier_pattern -Context "$ContextPrefix.rollback_drill_authorization_id"

    $authorizationPathValue = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $AuthorizationRef -Name "authorization_path" -Context $ContextPrefix) -Context "$ContextPrefix.authorization_path"
    $resolvedAuthorizationPath = Resolve-ArtifactPath -ArtifactPath $authorizationPathValue -AnchorPath $AnchorPath
    $validation = Test-MilestoneRollbackDrillAuthorizationContract -RollbackDrillAuthorizationPath $resolvedAuthorizationPath

    if ($validation.RollbackDrillAuthorizationId -ne $authorizationId) {
        throw "$ContextPrefix.rollback_drill_authorization_id does not match the referenced rollback-drill authorization artifact."
    }

    return [pscustomobject]@{
        RollbackDrillAuthorizationId = $validation.RollbackDrillAuthorizationId
        AuthorizationPath = $resolvedAuthorizationPath
        Validation = $validation
        Document = Get-JsonDocument -Path $resolvedAuthorizationPath -Label "Rollback drill authorization"
    }
}

function Test-MilestoneRollbackDrillResultDocument {
    param(
        [Parameter(Mandatory = $true)]
        $RollbackDrillResult,
        [Parameter(Mandatory = $true)]
        [string]$SourceLabel,
        [AllowNull()]
        [string]$DrillResultPath
    )

    $foundation = Get-MilestoneContinuityFoundationContract
    $contract = Get-MilestoneRollbackDrillResultContract
    $anchorPath = if ([string]::IsNullOrWhiteSpace($DrillResultPath)) { (Get-Location) } else { Split-Path -Parent $DrillResultPath }

    foreach ($fieldName in @($contract.required_fields)) {
        Get-RequiredProperty -Object $RollbackDrillResult -Name $fieldName -Context "Rollback drill result" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackDrillResult -Name "contract_version" -Context "Rollback drill result") -Context "Rollback drill result.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "Rollback drill result.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackDrillResult -Name "record_type" -Context "Rollback drill result") -Context "Rollback drill result.record_type"
    if ($recordType -ne $foundation.rollback_drill_result_record_type -or $recordType -ne $contract.record_type) {
        throw "Rollback drill result.record_type must equal '$($foundation.rollback_drill_result_record_type)'."
    }

    $rollbackDrillId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackDrillResult -Name "rollback_drill_id" -Context "Rollback drill result") -Context "Rollback drill result.rollback_drill_id"
    Assert-RegexMatch -Value $rollbackDrillId -Pattern $foundation.identifier_pattern -Context "Rollback drill result.rollback_drill_id"

    $executedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackDrillResult -Name "executed_at" -Context "Rollback drill result") -Context "Rollback drill result.executed_at"
    Assert-RegexMatch -Value $executedAt -Pattern $foundation.timestamp_pattern -Context "Rollback drill result.executed_at"

    $rollbackPlanReference = Validate-RollbackPlanReference -RollbackPlanRef (Assert-ObjectValue -Value (Get-RequiredProperty -Object $RollbackDrillResult -Name "rollback_plan_ref" -Context "Rollback drill result") -Context "Rollback drill result.rollback_plan_ref") -Foundation $foundation -Contract $contract -ContextPrefix "Rollback drill result.rollback_plan_ref" -AnchorPath $anchorPath
    $authorizationReference = Validate-RollbackDrillAuthorizationReference -AuthorizationRef (Assert-ObjectValue -Value (Get-RequiredProperty -Object $RollbackDrillResult -Name "rollback_drill_authorization_ref" -Context "Rollback drill result") -Context "Rollback drill result.rollback_drill_authorization_ref") -Foundation $foundation -Contract $contract -ContextPrefix "Rollback drill result.rollback_drill_authorization_ref" -AnchorPath $anchorPath

    $plan = $rollbackPlanReference.Document
    $authorization = $authorizationReference.Document

    if ($authorizationReference.Validation.RollbackPlanId -ne $rollbackPlanReference.Validation.RollbackPlanId) {
        throw "Rollback drill authorization must target the same rollback plan referenced by the drill result."
    }
    if ($plan.execution_state -ne "not_executed") {
        throw "Rollback drill result can only reference rollback plans that remain explicitly pre-execution."
    }
    if ($plan.operator_approval.approved_for_execution) {
        throw "Rollback drill result cannot reference rollback plans that already claim execution approval."
    }

    $cycleContext = Validate-CycleContext -CycleContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $RollbackDrillResult -Name "cycle_context" -Context "Rollback drill result") -Context "Rollback drill result.cycle_context") -Foundation $foundation -Contract $contract -ContextPrefix "Rollback drill result.cycle_context"
    if ($cycleContext.CycleId -ne $plan.cycle_context.cycle_id -or $cycleContext.MilestoneId -ne $plan.cycle_context.milestone_id -or $cycleContext.MilestoneTitle -ne $plan.cycle_context.milestone_title) {
        throw "Rollback drill result.cycle_context must match the referenced rollback plan."
    }

    $repositoryName = Validate-RepositoryContext -RepositoryContext (Assert-ObjectValue -Value (Get-RequiredProperty -Object $RollbackDrillResult -Name "repository" -Context "Rollback drill result") -Context "Rollback drill result.repository") -Foundation $foundation -Contract $contract -ContextPrefix "Rollback drill result.repository"
    if ($repositoryName -ne $plan.repository.repository_name) {
        throw "Rollback drill result.repository.repository_name must match the referenced rollback plan."
    }

    $sourceContinuity = Assert-ObjectValue -Value (Get-RequiredProperty -Object $RollbackDrillResult -Name "source_continuity" -Context "Rollback drill result") -Context "Rollback drill result.source_continuity"
    foreach ($fieldName in @($contract.source_continuity_required_fields)) {
        Get-RequiredProperty -Object $sourceContinuity -Name $fieldName -Context "Rollback drill result.source_continuity" | Out-Null
    }

    $ledgerId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $sourceContinuity -Name "ledger_id" -Context "Rollback drill result.source_continuity") -Context "Rollback drill result.source_continuity.ledger_id"
    Assert-RegexMatch -Value $ledgerId -Pattern $foundation.identifier_pattern -Context "Rollback drill result.source_continuity.ledger_id"
    $taskId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $sourceContinuity -Name "task_id" -Context "Rollback drill result.source_continuity") -Context "Rollback drill result.source_continuity.task_id"
    Assert-RegexMatch -Value $taskId -Pattern $foundation.identifier_pattern -Context "Rollback drill result.source_continuity.task_id"
    $interruptedSegmentId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $sourceContinuity -Name "interrupted_segment_id" -Context "Rollback drill result.source_continuity") -Context "Rollback drill result.source_continuity.interrupted_segment_id"
    Assert-RegexMatch -Value $interruptedSegmentId -Pattern $foundation.identifier_pattern -Context "Rollback drill result.source_continuity.interrupted_segment_id"
    $successorSegmentId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $sourceContinuity -Name "successor_segment_id" -Context "Rollback drill result.source_continuity") -Context "Rollback drill result.source_continuity.successor_segment_id"
    Assert-RegexMatch -Value $successorSegmentId -Pattern $foundation.identifier_pattern -Context "Rollback drill result.source_continuity.successor_segment_id"
    $ledgerContinuityState = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $sourceContinuity -Name "ledger_continuity_state" -Context "Rollback drill result.source_continuity") -Context "Rollback drill result.source_continuity.ledger_continuity_state"
    Assert-AllowedValue -Value $ledgerContinuityState -AllowedValues @($foundation.allowed_ledger_continuity_states) -Context "Rollback drill result.source_continuity.ledger_continuity_state"

    if ($ledgerId -ne $plan.source_continuity.ledger_ref.ledger_id -or $taskId -ne $plan.source_continuity.task_id -or $interruptedSegmentId -ne $plan.source_continuity.interrupted_segment_id -or $successorSegmentId -ne $plan.source_continuity.successor_segment_id -or $ledgerContinuityState -ne $plan.source_continuity.ledger_continuity_state) {
        throw "Rollback drill result.source_continuity must match the referenced rollback plan exactly."
    }

    $targetGitContext = Assert-ObjectValue -Value (Get-RequiredProperty -Object $RollbackDrillResult -Name "target_git_context" -Context "Rollback drill result") -Context "Rollback drill result.target_git_context"
    foreach ($fieldName in @($contract.target_git_context_required_fields)) {
        Get-RequiredProperty -Object $targetGitContext -Name $fieldName -Context "Rollback drill result.target_git_context" | Out-Null
    }

    $targetScope = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $targetGitContext -Name "target_scope" -Context "Rollback drill result.target_git_context") -Context "Rollback drill result.target_git_context.target_scope"
    Assert-AllowedValue -Value $targetScope -AllowedValues @($foundation.allowed_rollback_target_scopes) -Context "Rollback drill result.target_git_context.target_scope"
    $targetRepositoryRoot = Assert-AbsolutePathString -Value (Get-RequiredProperty -Object $targetGitContext -Name "repository_root" -Context "Rollback drill result.target_git_context") -Context "Rollback drill result.target_git_context.repository_root"
    $targetBranch = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $targetGitContext -Name "branch" -Context "Rollback drill result.target_git_context") -Context "Rollback drill result.target_git_context.branch"
    Assert-RegexMatch -Value $targetBranch -Pattern $foundation.branch_pattern -Context "Rollback drill result.target_git_context.branch"
    $targetHeadCommit = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $targetGitContext -Name "head_commit" -Context "Rollback drill result.target_git_context") -Context "Rollback drill result.target_git_context.head_commit"
    Assert-RegexMatch -Value $targetHeadCommit -Pattern $foundation.git_object_pattern -Context "Rollback drill result.target_git_context.head_commit"
    $targetTreeId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $targetGitContext -Name "tree_id" -Context "Rollback drill result.target_git_context") -Context "Rollback drill result.target_git_context.tree_id"
    Assert-RegexMatch -Value $targetTreeId -Pattern $foundation.git_object_pattern -Context "Rollback drill result.target_git_context.tree_id"

    if ($targetScope -ne $plan.rollback_target.target_scope -or $targetRepositoryRoot -ne [System.IO.Path]::GetFullPath($plan.rollback_target.repository_root) -or $targetBranch -ne $plan.rollback_target.branch -or $targetHeadCommit -ne $plan.rollback_target.head_commit -or $targetTreeId -ne $plan.rollback_target.tree_id) {
        throw "Rollback drill result.target_git_context must match the referenced rollback plan target exactly."
    }

    $drillEnvironment = Assert-ObjectValue -Value (Get-RequiredProperty -Object $RollbackDrillResult -Name "drill_environment" -Context "Rollback drill result") -Context "Rollback drill result.drill_environment"
    foreach ($fieldName in @($contract.drill_environment_required_fields)) {
        Get-RequiredProperty -Object $drillEnvironment -Name $fieldName -Context "Rollback drill result.drill_environment" | Out-Null
    }

    $environmentScope = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $drillEnvironment -Name "environment_scope" -Context "Rollback drill result.drill_environment") -Context "Rollback drill result.drill_environment.environment_scope"
    Assert-AllowedValue -Value $environmentScope -AllowedValues @($foundation.allowed_rollback_drill_environment_scopes) -Context "Rollback drill result.drill_environment.environment_scope"
    $environmentRoot = Assert-AbsolutePathString -Value (Get-RequiredProperty -Object $drillEnvironment -Name "environment_root" -Context "Rollback drill result.drill_environment") -Context "Rollback drill result.drill_environment.environment_root"
    $sourceRepositoryRoot = Assert-AbsolutePathString -Value (Get-RequiredProperty -Object $drillEnvironment -Name "source_repository_root" -Context "Rollback drill result.drill_environment") -Context "Rollback drill result.drill_environment.source_repository_root"
    $disposableBranch = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $drillEnvironment -Name "disposable_branch" -Context "Rollback drill result.drill_environment") -Context "Rollback drill result.drill_environment.disposable_branch"
    Assert-RegexMatch -Value $disposableBranch -Pattern $foundation.branch_pattern -Context "Rollback drill result.drill_environment.disposable_branch"
    $primaryWorktreeExecution = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $drillEnvironment -Name "primary_worktree_execution" -Context "Rollback drill result.drill_environment") -Context "Rollback drill result.drill_environment.primary_worktree_execution"
    Assert-AllowedValue -Value $primaryWorktreeExecution -AllowedValues @($foundation.allowed_rollback_primary_worktree_execution_states) -Context "Rollback drill result.drill_environment.primary_worktree_execution"

    if ($environmentScope -ne $authorizationReference.Validation.ApprovedEnvironmentScope -or $environmentScope -ne $plan.environment_constraints.allowed_environment_scope) {
        throw "Rollback drill result.drill_environment.environment_scope must match the rollback plan and explicit drill authorization."
    }
    if ($sourceRepositoryRoot -ne $targetRepositoryRoot) {
        throw "Rollback drill result.drill_environment.source_repository_root must match the rollback plan target repository root."
    }
    if ($environmentRoot.Equals($sourceRepositoryRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Rollback drill result.drill_environment.environment_root must not equal the primary worktree root."
    }
    if (Test-PathWithinRoot -Path $environmentRoot -Root $sourceRepositoryRoot) {
        throw "Rollback drill result.drill_environment.environment_root must not resolve inside the primary repository root."
    }

    $supervision = Validate-Supervision -Supervision (Assert-ObjectValue -Value (Get-RequiredProperty -Object $RollbackDrillResult -Name "supervision" -Context "Rollback drill result") -Context "Rollback drill result.supervision") -Foundation $foundation -Contract $contract -ContextPrefix "Rollback drill result.supervision"
    if ($supervision.Mode -ne $plan.supervision.mode -or $supervision.OperatorAuthority -ne $plan.supervision.operator_authority -or $supervision.ResumeAuthorityState -ne $plan.supervision.resume_authority_state) {
        throw "Rollback drill result.supervision must match the referenced rollback plan."
    }

    $operatorApproval = Assert-ObjectValue -Value (Get-RequiredProperty -Object $RollbackDrillResult -Name "operator_approval" -Context "Rollback drill result") -Context "Rollback drill result.operator_approval"
    foreach ($fieldName in @($contract.operator_approval_required_fields)) {
        Get-RequiredProperty -Object $operatorApproval -Name $fieldName -Context "Rollback drill result.operator_approval" | Out-Null
    }

    $approvedOperatorAuthority = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $operatorApproval -Name "operator_authority" -Context "Rollback drill result.operator_approval") -Context "Rollback drill result.operator_approval.operator_authority"
    Assert-RegexMatch -Value $approvedOperatorAuthority -Pattern $foundation.operator_pattern -Context "Rollback drill result.operator_approval.operator_authority"
    $approvedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $operatorApproval -Name "approved_at" -Context "Rollback drill result.operator_approval") -Context "Rollback drill result.operator_approval.approved_at"
    Assert-RegexMatch -Value $approvedAt -Pattern $foundation.timestamp_pattern -Context "Rollback drill result.operator_approval.approved_at"
    $requiredAuthorityState = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $operatorApproval -Name "required_authority_state" -Context "Rollback drill result.operator_approval") -Context "Rollback drill result.operator_approval.required_authority_state"
    Assert-AllowedValue -Value $requiredAuthorityState -AllowedValues @($foundation.allowed_resume_authority_states) -Context "Rollback drill result.operator_approval.required_authority_state"
    $gitMutationApproved = Assert-BooleanValue -Value (Get-RequiredProperty -Object $operatorApproval -Name "git_mutation_approved" -Context "Rollback drill result.operator_approval") -Context "Rollback drill result.operator_approval.git_mutation_approved"
    if (-not $gitMutationApproved) {
        throw "Rollback drill result.operator_approval.git_mutation_approved must remain true."
    }

    if ($approvedOperatorAuthority -ne $authorizationReference.Validation.OperatorAuthority -or $approvedOperatorAuthority -ne $supervision.OperatorAuthority) {
        throw "Rollback drill result.operator_approval.operator_authority must match the rollback plan and drill authorization."
    }
    if ($approvedAt -ne $authorizationReference.Validation.ApprovedAt) {
        throw "Rollback drill result.operator_approval.approved_at must match the rollback-drill authorization."
    }
    if ($requiredAuthorityState -ne $authorizationReference.Validation.RequiredAuthorityState -or $requiredAuthorityState -ne $supervision.ResumeAuthorityState -or $requiredAuthorityState -ne $plan.operator_approval.required_authority_state) {
        throw "Rollback drill result.operator_approval.required_authority_state must stay aligned with the rollback plan and drill authorization."
    }

    $drillAction = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackDrillResult -Name "drill_action" -Context "Rollback drill result") -Context "Rollback drill result.drill_action"
    Assert-AllowedValue -Value $drillAction -AllowedValues @($foundation.allowed_rollback_drill_actions) -Context "Rollback drill result.drill_action"

    $observedBefore = Validate-ObservedState -ObservedState (Assert-ObjectValue -Value (Get-RequiredProperty -Object $RollbackDrillResult -Name "observed_before" -Context "Rollback drill result") -Context "Rollback drill result.observed_before") -Foundation $foundation -Contract $contract -ContextPrefix "Rollback drill result.observed_before"
    $observedAfter = Validate-ObservedState -ObservedState (Assert-ObjectValue -Value (Get-RequiredProperty -Object $RollbackDrillResult -Name "observed_after" -Context "Rollback drill result") -Context "Rollback drill result.observed_after") -Foundation $foundation -Contract $contract -ContextPrefix "Rollback drill result.observed_after"

    if ($observedBefore.Branch -ne $disposableBranch -or $observedAfter.Branch -ne $disposableBranch) {
        throw "Rollback drill result observed Git state must remain on the disposable drill branch."
    }
    if ($observedAfter.HeadCommit -ne $targetHeadCommit -or $observedAfter.TreeId -ne $targetTreeId) {
        throw "Rollback drill result.observed_after must match the rollback plan target Git context."
    }
    if ($observedBefore.HeadCommit -eq $observedAfter.HeadCommit -and $observedBefore.TreeId -eq $observedAfter.TreeId) {
        throw "Rollback drill result must demonstrate a bounded Git-context transition inside the disposable environment."
    }

    $executionState = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackDrillResult -Name "execution_state" -Context "Rollback drill result") -Context "Rollback drill result.execution_state"
    Assert-AllowedValue -Value $executionState -AllowedValues @($foundation.allowed_rollback_drill_execution_states) -Context "Rollback drill result.execution_state"

    $authoritativeRefs = Validate-AuthoritativeRefs -AuthoritativeRefs (Assert-ObjectValue -Value (Get-RequiredProperty -Object $RollbackDrillResult -Name "authoritative_refs" -Context "Rollback drill result") -Context "Rollback drill result.authoritative_refs") -Foundation $foundation -ContextPrefix "Rollback drill result.authoritative_refs"
    foreach ($fieldName in @($foundation.required_authoritative_ref_fields)) {
        if ($RollbackDrillResult.authoritative_refs.$fieldName -ne $plan.authoritative_refs.$fieldName) {
            throw "Rollback drill result.authoritative_refs.$fieldName must match the referenced rollback plan."
        }
    }

    $nonClaims = Assert-StringArray -Value (Get-RequiredProperty -Object $RollbackDrillResult -Name "non_claims" -Context "Rollback drill result") -Context "Rollback drill result.non_claims" -MinimumCount 1
    foreach ($nonClaim in $nonClaims) {
        Assert-AllowedValue -Value $nonClaim -AllowedValues @($foundation.allowed_rollback_drill_non_claims) -Context "Rollback drill result.non_claims item"
    }
    if ($nonClaims -notcontains "drill_only_no_primary_worktree_rollback_no_broader_recovery") {
        throw "Rollback drill result.non_claims must preserve the bounded disposable-drill non-claim."
    }

    $notes = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $RollbackDrillResult -Name "notes" -Context "Rollback drill result") -Context "Rollback drill result.notes"

    return [pscustomobject]@{
        IsValid = $true
        RollbackDrillId = $rollbackDrillId
        DrillResultPath = $DrillResultPath
        RollbackPlanId = $rollbackPlanReference.RollbackPlanId
        RollbackDrillAuthorizationId = $authorizationReference.RollbackDrillAuthorizationId
        CycleId = $cycleContext.CycleId
        MilestoneId = $cycleContext.MilestoneId
        TaskId = $taskId
        InterruptedSegmentId = $interruptedSegmentId
        SuccessorSegmentId = $successorSegmentId
        EnvironmentScope = $environmentScope
        EnvironmentRoot = $environmentRoot
        DisposableBranch = $disposableBranch
        TargetRepositoryRoot = $targetRepositoryRoot
        TargetHeadCommit = $targetHeadCommit
        TargetTreeId = $targetTreeId
        ExecutionState = $executionState
        OperatorAuthority = $approvedOperatorAuthority
        AuthoritativeRefs = $authoritativeRefs
        NonClaims = $nonClaims
        SourceLabel = $SourceLabel
        Notes = $notes
    }
}

function Test-MilestoneRollbackDrillAuthorizationContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RollbackDrillAuthorizationPath
    )

    $resolvedAuthorizationPath = Resolve-ArtifactPath -ArtifactPath $RollbackDrillAuthorizationPath
    $authorization = Get-JsonDocument -Path $resolvedAuthorizationPath -Label "Rollback drill authorization"
    return (Validate-RollbackDrillAuthorizationDocument -RollbackDrillAuthorization $authorization -SourceLabel $resolvedAuthorizationPath -AuthorizationPath $resolvedAuthorizationPath)
}

function Test-MilestoneRollbackDrillAuthorizationObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $RollbackDrillAuthorization,
        [string]$SourceLabel = "in-memory rollback drill authorization"
    )

    return (Validate-RollbackDrillAuthorizationDocument -RollbackDrillAuthorization $RollbackDrillAuthorization -SourceLabel $SourceLabel -AuthorizationPath $null)
}

function Test-MilestoneRollbackDrillResultContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$DrillResultPath
    )

    $resolvedDrillResultPath = Resolve-ArtifactPath -ArtifactPath $DrillResultPath
    $result = Get-JsonDocument -Path $resolvedDrillResultPath -Label "Rollback drill result"
    return (Test-MilestoneRollbackDrillResultDocument -RollbackDrillResult $result -SourceLabel $resolvedDrillResultPath -DrillResultPath $resolvedDrillResultPath)
}

function Test-MilestoneRollbackDrillResultObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $RollbackDrillResult,
        [string]$SourceLabel = "in-memory rollback drill result"
    )

    return (Test-MilestoneRollbackDrillResultDocument -RollbackDrillResult $RollbackDrillResult -SourceLabel $SourceLabel -DrillResultPath $null)
}

function Get-MilestoneRollbackDrillResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$DrillResultPath
    )

    $validation = Test-MilestoneRollbackDrillResultContract -DrillResultPath $DrillResultPath
    return (Get-JsonDocument -Path $validation.DrillResultPath -Label "Rollback drill result")
}

function Invoke-MilestoneRollbackDrill {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RollbackPlanPath,
        [Parameter(Mandatory = $true)]
        [string]$RollbackDrillAuthorizationPath,
        [Parameter(Mandatory = $true)]
        [string]$DrillResultPath,
        [string]$DisposableEnvironmentRoot,
        [string]$DisposableBranchName,
        [string]$RollbackDrillId = "rollback-drill-r7-007-001",
        [datetime]$ExecutedAt = (Get-Date).ToUniversalTime()
    )

    $foundation = Get-MilestoneContinuityFoundationContract
    Assert-NonEmptyString -Value $RollbackDrillId -Context "RollbackDrillId" | Out-Null
    Assert-RegexMatch -Value $RollbackDrillId -Pattern $foundation.identifier_pattern -Context "RollbackDrillId"

    $planValidation = & $testMilestoneRollbackPlanContract -RollbackPlanPath $RollbackPlanPath
    $plan = & $getMilestoneRollbackPlan -RollbackPlanPath $RollbackPlanPath
    $authorizationValidation = Test-MilestoneRollbackDrillAuthorizationContract -RollbackDrillAuthorizationPath $RollbackDrillAuthorizationPath
    $authorization = Get-JsonDocument -Path $authorizationValidation.AuthorizationPath -Label "Rollback drill authorization"

    if ($authorizationValidation.RollbackPlanId -ne $planValidation.RollbackPlanId) {
        throw "Rollback drill authorization must target the same rollback plan that the drill harness consumes."
    }
    if ($plan.execution_state -ne "not_executed") {
        throw "Rollback drill can only run from a rollback plan that remains explicitly pre-execution."
    }
    if ($plan.operator_approval.approved_for_execution) {
        throw "Rollback drill can only run from a rollback plan that does not already claim execution approval."
    }
    if (-not $plan.operator_approval.approval_required) {
        throw "Rollback drill requires a rollback plan that still records explicit operator approval requirements."
    }
    if ($plan.operator_approval.required_authority_state -ne $authorizationValidation.RequiredAuthorityState) {
        throw "Rollback drill authorization state must match the rollback plan authority requirement."
    }
    if ($plan.supervision.operator_authority -ne $authorizationValidation.OperatorAuthority) {
        throw "Rollback drill authorization operator must match the rollback plan supervision identity."
    }
    if ($plan.environment_constraints.primary_worktree_execution -ne "refused") {
        throw "Rollback drill refuses rollback plans that do not explicitly refuse primary-worktree execution."
    }
    if ($plan.environment_constraints.allowed_environment_scope -ne $authorizationValidation.ApprovedEnvironmentScope) {
        throw "Rollback drill authorization environment scope must match the rollback plan environment constraint."
    }
    if ($plan.environment_constraints.allowed_environment_scope -notin @($foundation.allowed_rollback_drill_environment_scopes)) {
        throw "Rollback drill only proves disposable-worktree execution in this bounded slice."
    }

    $sourceRepositoryRoot = Resolve-ArtifactPath -ArtifactPath $plan.rollback_target.repository_root
    $sourceRepositoryRoot = (Resolve-Path -LiteralPath $sourceRepositoryRoot).Path
    $sourceWorktreeRoot = Get-GitTrimmedValue -RepositoryRoot $sourceRepositoryRoot -Arguments @("rev-parse", "--show-toplevel") -Context "Source repository worktree resolution"
    $sourceWorktreeRoot = (Resolve-Path -LiteralPath $sourceWorktreeRoot).Path
    if ($sourceWorktreeRoot -ne $sourceRepositoryRoot) {
        throw "Rollback drill target repository root must resolve to the Git worktree root exactly."
    }

    $sourceRepositoryLeaf = Split-Path -Leaf $sourceRepositoryRoot
    if ($sourceRepositoryLeaf -ne $foundation.repository_name) {
        throw "Rollback drill target repository root leaf name must equal '$($foundation.repository_name)'."
    }

    $sourceStateBefore = Get-GitObservedState -RepositoryRoot $sourceRepositoryRoot

    if ([string]::IsNullOrWhiteSpace($DisposableBranchName)) {
        $DisposableBranchName = "rollback-drill-$RollbackDrillId"
    }
    Assert-RegexMatch -Value $DisposableBranchName -Pattern $foundation.branch_pattern -Context "DisposableBranchName"

    if ([string]::IsNullOrWhiteSpace($DisposableEnvironmentRoot)) {
        $DisposableEnvironmentRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("aioffice-r7-007-" + [System.Guid]::NewGuid().ToString("N"))
    }

    $resolvedDisposableEnvironmentRoot = Resolve-AbsolutePathValue -PathValue $DisposableEnvironmentRoot
    if ($resolvedDisposableEnvironmentRoot.Equals($sourceRepositoryRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "DisposableEnvironmentRoot must not equal the primary worktree root."
    }
    if (Test-PathWithinRoot -Path $resolvedDisposableEnvironmentRoot -Root $sourceRepositoryRoot) {
        throw "DisposableEnvironmentRoot must not resolve inside the primary repository root."
    }
    if (Test-Path -LiteralPath $resolvedDisposableEnvironmentRoot) {
        throw "DisposableEnvironmentRoot '$resolvedDisposableEnvironmentRoot' already exists."
    }

    $environmentParent = Split-Path -Parent $resolvedDisposableEnvironmentRoot
    if (-not [string]::IsNullOrWhiteSpace($environmentParent)) {
        New-Item -ItemType Directory -Path $environmentParent -Force | Out-Null
    }

    $worktreeAdded = $false
    try {
        Invoke-GitCommand -RepositoryRoot $sourceRepositoryRoot -Arguments @("worktree", "add", "--detach", $resolvedDisposableEnvironmentRoot, $sourceStateBefore.HeadCommit) -Context "Disposable rollback drill worktree creation" | Out-Null
        $worktreeAdded = $true

        $disposableWorktreeRoot = Get-GitTrimmedValue -RepositoryRoot $resolvedDisposableEnvironmentRoot -Arguments @("rev-parse", "--show-toplevel") -Context "Disposable rollback drill worktree verification"
        $disposableWorktreeRoot = (Resolve-Path -LiteralPath $disposableWorktreeRoot).Path
        if ($disposableWorktreeRoot -ne $resolvedDisposableEnvironmentRoot) {
            throw "Rollback drill disposable environment must resolve to its own Git worktree root."
        }

        Invoke-GitCommand -RepositoryRoot $resolvedDisposableEnvironmentRoot -Arguments @("checkout", "-b", $DisposableBranchName) -Context "Disposable rollback drill branch creation" | Out-Null
        $observedBefore = Get-GitObservedState -RepositoryRoot $resolvedDisposableEnvironmentRoot

        Invoke-GitCommand -RepositoryRoot $resolvedDisposableEnvironmentRoot -Arguments @("reset", "--hard", $plan.rollback_target.head_commit) -Context "Disposable rollback drill reset" | Out-Null
        $observedAfter = Get-GitObservedState -RepositoryRoot $resolvedDisposableEnvironmentRoot

        if ($observedAfter.HeadCommit -ne $plan.rollback_target.head_commit -or $observedAfter.TreeId -ne $plan.rollback_target.tree_id) {
            throw "Rollback drill disposable environment did not land on the rollback plan target Git context."
        }
        if ($observedBefore.HeadCommit -eq $observedAfter.HeadCommit -and $observedBefore.TreeId -eq $observedAfter.TreeId) {
            throw "Rollback drill must demonstrate a bounded Git-context transition inside the disposable environment."
        }

        $sourceStateAfter = Get-GitObservedState -RepositoryRoot $sourceRepositoryRoot
        if ($sourceStateAfter.Branch -ne $sourceStateBefore.Branch -or $sourceStateAfter.HeadCommit -ne $sourceStateBefore.HeadCommit -or $sourceStateAfter.TreeId -ne $sourceStateBefore.TreeId) {
            throw "Rollback drill must not change the primary worktree Git context."
        }

        $result = [pscustomobject]@{
            contract_version = $foundation.contract_version
            record_type = $foundation.rollback_drill_result_record_type
            rollback_drill_id = $RollbackDrillId
            executed_at = $ExecutedAt.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
            rollback_plan_ref = [pscustomobject]@{
                record_type = $foundation.rollback_plan_record_type
                rollback_plan_id = $planValidation.RollbackPlanId
                rollback_plan_path = $planValidation.RollbackPlanPath
            }
            rollback_drill_authorization_ref = [pscustomobject]@{
                record_type = $foundation.rollback_drill_authorization_record_type
                rollback_drill_authorization_id = $authorizationValidation.RollbackDrillAuthorizationId
                authorization_path = $authorizationValidation.AuthorizationPath
            }
            cycle_context = $plan.cycle_context
            repository = $plan.repository
            source_continuity = [pscustomobject]@{
                ledger_id = $plan.source_continuity.ledger_ref.ledger_id
                task_id = $plan.source_continuity.task_id
                interrupted_segment_id = $plan.source_continuity.interrupted_segment_id
                successor_segment_id = $plan.source_continuity.successor_segment_id
                ledger_continuity_state = $plan.source_continuity.ledger_continuity_state
            }
            target_git_context = [pscustomobject]@{
                target_scope = $plan.rollback_target.target_scope
                repository_root = $sourceRepositoryRoot
                branch = $plan.rollback_target.branch
                head_commit = $plan.rollback_target.head_commit
                tree_id = $plan.rollback_target.tree_id
            }
            drill_environment = [pscustomobject]@{
                environment_scope = $authorizationValidation.ApprovedEnvironmentScope
                environment_root = $resolvedDisposableEnvironmentRoot
                source_repository_root = $sourceRepositoryRoot
                disposable_branch = $DisposableBranchName
                primary_worktree_execution = "refused"
            }
            supervision = $plan.supervision
            operator_approval = [pscustomobject]@{
                operator_authority = $authorizationValidation.OperatorAuthority
                approved_at = $authorizationValidation.ApprovedAt
                required_authority_state = $authorizationValidation.RequiredAuthorityState
                git_mutation_approved = $authorizationValidation.GitMutationApproved
            }
            drill_action = "hard_reset_to_target_baseline_in_disposable_worktree"
            observed_before = [pscustomobject]@{
                branch = $observedBefore.Branch
                head_commit = $observedBefore.HeadCommit
                tree_id = $observedBefore.TreeId
            }
            observed_after = [pscustomobject]@{
                branch = $observedAfter.Branch
                head_commit = $observedAfter.HeadCommit
                tree_id = $observedAfter.TreeId
            }
            execution_state = "completed_disposable_worktree_drill"
            authoritative_refs = $plan.authoritative_refs
            non_claims = @(
                "drill_only_no_primary_worktree_rollback_no_broader_recovery"
            )
            notes = "This rollback drill runs one hard-reset rehearsal only inside a disposable worktree with explicit operator approval before Git mutation. It does not execute rollback in the primary worktree and does not widen into broader recovery behavior."
        }

        $savedResultPath = Write-JsonDocument -Document $result -OutputPath $DrillResultPath
        $validation = Test-MilestoneRollbackDrillResultContract -DrillResultPath $savedResultPath

        return [pscustomobject]@{
            DrillResult = $result
            DrillResultPath = $savedResultPath
            Validation = $validation
            SourceArtifacts = [pscustomobject]@{
                RollbackPlanId = $planValidation.RollbackPlanId
                RollbackDrillAuthorizationId = $authorizationValidation.RollbackDrillAuthorizationId
                SourceHeadBefore = $sourceStateBefore.HeadCommit
                SourceHeadAfter = $sourceStateAfter.HeadCommit
            }
        }
    }
    catch {
        if ($worktreeAdded) {
            try {
                Invoke-GitCommand -RepositoryRoot $sourceRepositoryRoot -Arguments @("worktree", "remove", "--force", $resolvedDisposableEnvironmentRoot) -Context "Rollback drill cleanup" | Out-Null
            }
            catch {
            }
        }

        throw
    }
}

Export-ModuleMember -Function Test-MilestoneRollbackDrillAuthorizationContract, Test-MilestoneRollbackDrillAuthorizationObject, Test-MilestoneRollbackDrillResultContract, Test-MilestoneRollbackDrillResultObject, Get-MilestoneRollbackDrillResult, Invoke-MilestoneRollbackDrill
