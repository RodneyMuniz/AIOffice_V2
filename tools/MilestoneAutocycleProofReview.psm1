Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$proposalModulePath = Join-Path $PSScriptRoot "MilestoneAutocycleProposal.psm1"
$freezeModulePath = Join-Path $PSScriptRoot "MilestoneAutocycleFreeze.psm1"
$baselineModulePath = Join-Path $PSScriptRoot "MilestoneBaseline.psm1"
$dispatchModulePath = Join-Path $PSScriptRoot "MilestoneAutocycleDispatch.psm1"
$executionEvidenceModulePath = Join-Path $PSScriptRoot "MilestoneAutocycleExecutionEvidence.psm1"
$qaModulePath = Join-Path $PSScriptRoot "MilestoneAutocycleQA.psm1"
$summaryModulePath = Join-Path $PSScriptRoot "MilestoneAutocycleSummary.psm1"
$closeoutModulePath = Join-Path $PSScriptRoot "MilestoneAutocycleCloseout.psm1"
$script:commandCache = @{}

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

    $json = $Document | ConvertTo-Json -Depth 30
    Set-Content -LiteralPath $Path -Value $json -Encoding UTF8
}

function Write-Utf8File {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [AllowNull()]
        [string]$Value
    )

    $directory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($directory) -and -not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    if ($null -eq $Value) {
        $Value = ""
    }

    Set-Content -LiteralPath $Path -Value $Value -Encoding UTF8
}

function Append-Utf8File {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    $directory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($directory) -and -not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    Add-Content -LiteralPath $Path -Value $Value -Encoding UTF8
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

function Get-MilestoneAutocycleFoundationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_autocycle\foundation.contract.json") -Label "Milestone autocycle foundation contract"
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

    $cacheKey = "{0}|{1}" -f $ModulePath, $CommandName
    if ($script:commandCache.ContainsKey($cacheKey)) {
        return $script:commandCache[$cacheKey]
    }

    if (-not (Test-Path -LiteralPath $ModulePath)) {
        throw "Proof review requires dependency module '$DependencyLabel' at '$ModulePath'."
    }

    try {
        $module = Import-Module $ModulePath -Force -PassThru -ErrorAction Stop
    }
    catch {
        throw "Proof review requires dependency module '$DependencyLabel' to load successfully. $($_.Exception.Message)"
    }

    $command = $module.ExportedCommands[$CommandName]
    if ($null -eq $command) {
        throw "Proof review requires dependency command '$CommandName' from dependency module '$DependencyLabel'."
    }

    $script:commandCache[$cacheKey] = $command
    return $command
}

function Get-ProposalFlowCommand { return Get-RequiredDependencyCommand -ModulePath $proposalModulePath -DependencyLabel "MilestoneAutocycleProposal" -CommandName "Invoke-MilestoneAutocycleProposalFlow" }
function Get-ProposalIntakeValidatorCommand { return Get-RequiredDependencyCommand -ModulePath $proposalModulePath -DependencyLabel "MilestoneAutocycleProposal" -CommandName "Test-MilestoneAutocycleProposalIntakeContract" }
function Get-ProposalValidatorCommand { return Get-RequiredDependencyCommand -ModulePath $proposalModulePath -DependencyLabel "MilestoneAutocycleProposal" -CommandName "Test-MilestoneAutocycleProposalContract" }
function Get-ApprovalFlowCommand { return Get-RequiredDependencyCommand -ModulePath $freezeModulePath -DependencyLabel "MilestoneAutocycleFreeze" -CommandName "Invoke-MilestoneAutocycleApprovalFlow" }
function Get-ApprovalValidatorCommand { return Get-RequiredDependencyCommand -ModulePath $freezeModulePath -DependencyLabel "MilestoneAutocycleFreeze" -CommandName "Test-MilestoneAutocycleApprovalContract" }
function Get-FreezeValidatorCommand { return Get-RequiredDependencyCommand -ModulePath $freezeModulePath -DependencyLabel "MilestoneAutocycleFreeze" -CommandName "Test-MilestoneAutocycleFreezeContract" }
function Get-BaselineBindingFlowCommand { return Get-RequiredDependencyCommand -ModulePath $baselineModulePath -DependencyLabel "MilestoneBaseline" -CommandName "Invoke-MilestoneFreezeBaselineBindingFlow" }
function Get-BaselineBindingValidatorCommand { return Get-RequiredDependencyCommand -ModulePath $baselineModulePath -DependencyLabel "MilestoneBaseline" -CommandName "Test-MilestoneAutocycleBaselineBindingContract" }
function Get-DispatchFlowCommand { return Get-RequiredDependencyCommand -ModulePath $dispatchModulePath -DependencyLabel "MilestoneAutocycleDispatch" -CommandName "Invoke-MilestoneAutocycleDispatchFlow" }
function Get-DispatchValidatorCommand { return Get-RequiredDependencyCommand -ModulePath $dispatchModulePath -DependencyLabel "MilestoneAutocycleDispatch" -CommandName "Test-MilestoneAutocycleDispatchContract" }
function Get-RunLedgerValidatorCommand { return Get-RequiredDependencyCommand -ModulePath $dispatchModulePath -DependencyLabel "MilestoneAutocycleDispatch" -CommandName "Test-MilestoneAutocycleRunLedgerContract" }
function Get-RunLedgerStatusCommand { return Get-RequiredDependencyCommand -ModulePath $dispatchModulePath -DependencyLabel "MilestoneAutocycleDispatch" -CommandName "Set-MilestoneAutocycleRunLedgerStatus" }
function Get-ExecutionEvidenceFlowCommand { return Get-RequiredDependencyCommand -ModulePath $executionEvidenceModulePath -DependencyLabel "MilestoneAutocycleExecutionEvidence" -CommandName "Invoke-MilestoneAutocycleExecutionEvidenceFlow" }
function Get-ExecutionEvidenceValidatorCommand { return Get-RequiredDependencyCommand -ModulePath $executionEvidenceModulePath -DependencyLabel "MilestoneAutocycleExecutionEvidence" -CommandName "Test-MilestoneAutocycleExecutionEvidenceContract" }
function Get-QAObservationFlowCommand { return Get-RequiredDependencyCommand -ModulePath $qaModulePath -DependencyLabel "MilestoneAutocycleQA" -CommandName "Invoke-MilestoneAutocycleQAObservationFlow" }
function Get-QAObservationValidatorCommand { return Get-RequiredDependencyCommand -ModulePath $qaModulePath -DependencyLabel "MilestoneAutocycleQA" -CommandName "Test-MilestoneAutocycleQAObservationContract" }
function Get-QAAggregationValidatorCommand { return Get-RequiredDependencyCommand -ModulePath $qaModulePath -DependencyLabel "MilestoneAutocycleQA" -CommandName "Test-MilestoneAutocycleQAAggregationContract" }
function Get-SummaryFlowCommand { return Get-RequiredDependencyCommand -ModulePath $summaryModulePath -DependencyLabel "MilestoneAutocycleSummary" -CommandName "Invoke-MilestoneAutocycleSummaryFlow" }
function Get-SummaryValidatorCommand { return Get-RequiredDependencyCommand -ModulePath $summaryModulePath -DependencyLabel "MilestoneAutocycleSummary" -CommandName "Test-MilestoneAutocycleSummaryContract" }
function Get-DecisionPacketValidatorCommand { return Get-RequiredDependencyCommand -ModulePath $summaryModulePath -DependencyLabel "MilestoneAutocycleSummary" -CommandName "Test-MilestoneAutocycleDecisionPacketContract" }
function Get-CloseoutFlowCommand { return Get-RequiredDependencyCommand -ModulePath $closeoutModulePath -DependencyLabel "MilestoneAutocycleCloseout" -CommandName "Invoke-MilestoneAutocycleCloseoutFlow" }
function Get-ReplayProofValidatorCommand { return Get-RequiredDependencyCommand -ModulePath $closeoutModulePath -DependencyLabel "MilestoneAutocycleCloseout" -CommandName "Test-MilestoneAutocycleReplayProofContract" }
function Get-CloseoutPacketValidatorCommand { return Get-RequiredDependencyCommand -ModulePath $closeoutModulePath -DependencyLabel "MilestoneAutocycleCloseout" -CommandName "Test-MilestoneAutocycleCloseoutPacketContract" }

function Get-GitCommand {
    $command = Get-Command git -ErrorAction SilentlyContinue
    if ($null -eq $command) {
        throw "Proof review requires Git CLI to be installed and callable."
    }

    return $command
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
    Get-GitCommand | Out-Null
    $worktreeRoot = (& git -C $gitLocation rev-parse --show-toplevel 2>$null)
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($worktreeRoot)) {
        throw "$Label '$PathValue' must resolve inside a Git worktree."
    }

    return (Resolve-Path -LiteralPath $worktreeRoot.Trim()).Path
}

function Get-GitBranchName {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    Get-GitCommand | Out-Null
    $branch = (& git -C $RepositoryRoot branch --show-current 2>$null).Trim()
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($branch)) {
        throw "Unable to resolve the current Git branch for proof review."
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
        throw "Unable to resolve the current Git HEAD commit for proof review."
    }

    return $head
}

function Get-GitTreeId {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    Get-GitCommand | Out-Null
    $treeRevision = "HEAD^{tree}"
    $tree = (& git -C $RepositoryRoot rev-parse --verify $treeRevision 2>$null).Trim()
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($tree)) {
        throw "Unable to resolve the current Git HEAD tree for proof review."
    }

    return $tree
}

function Get-GitStatusLines {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    Get-GitCommand | Out-Null
    $statusLines = @(& git -C $RepositoryRoot status --short --untracked-files=all 2>$null)
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to resolve Git status for proof review."
    }

    return @($statusLines | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Assert-CleanGitWorktree {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $statusLines = @(Get-GitStatusLines -RepositoryRoot $RepositoryRoot)
    if ($statusLines.Count -gt 0) {
        throw "Proof review requires a clean Git worktree before replay."
    }
}

function Get-GitInfoExcludePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    return Join-Path $RepositoryRoot ".git\info\exclude"
}

function Add-TemporaryGitExcludePattern {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string]$RelativeDirectory
    )

    $excludePath = Get-GitInfoExcludePath -RepositoryRoot $RepositoryRoot
    $pattern = "/{0}/" -f ($RelativeDirectory.Trim("/\") -replace "\\", "/")
    $content = if (Test-Path -LiteralPath $excludePath) { Get-Content -LiteralPath $excludePath -Raw } else { "" }
    $startMarker = "# codex-r6-proof-review-start"
    $endMarker = "# codex-r6-proof-review-end"

    if ($content -like "*$startMarker*") {
        $content = Remove-TemporaryGitExcludePatternText -Content $content
    }

    $block = @(
        $startMarker
        $pattern
        $endMarker
        ""
    ) -join [Environment]::NewLine

    Write-Utf8File -Path $excludePath -Value ($content + $block)
}

function Remove-TemporaryGitExcludePatternText {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Content
    )

    $normalized = $Content -replace "`r`n", "`n"
    $pattern = "(?ms)^# codex-r6-proof-review-start`n.*?^# codex-r6-proof-review-end`n?"
    return ($normalized -replace $pattern, "") -replace "`n", [Environment]::NewLine
}

function Remove-TemporaryGitExcludePattern {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $excludePath = Get-GitInfoExcludePath -RepositoryRoot $RepositoryRoot
    if (-not (Test-Path -LiteralPath $excludePath)) {
        return
    }

    $content = Get-Content -LiteralPath $excludePath -Raw
    $updatedContent = Remove-TemporaryGitExcludePatternText -Content $content
    Write-Utf8File -Path $excludePath -Value $updatedContent.TrimEnd()
}

function Get-ProofReviewNonClaims {
    return @(
        "No operator decision was executed; the operator decision remains advisory only.",
        "This replay does not prove broader autonomy.",
        "This replay does not prove rollback execution.",
        "This replay does not prove unattended automatic resume.",
        "This replay does not prove UI or Standard runtime productization.",
        "This replay does not prove multi-repo behavior, swarms, or broader orchestration."
    )
}

function Get-ForbiddenExecutedDecisionFragments {
    return @(
        "operator accepted",
        "operator chose",
        "operator decision executed"
    )
}

function Get-ProofReviewPackageType {
    return "r6_supervised_milestone_autocycle_proof_review"
}

function New-PackagePaths {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string]$OutputRoot
    )

    $packageRoot = Resolve-PathForCreationInsideRepository -PathValue $OutputRoot -RepositoryRoot $RepositoryRoot -Label "Proof review output root"
    return [pscustomobject]@{
        PackageRoot = $packageRoot
        MetaRoot = Join-Path $packageRoot "meta"
        RawLogsRoot = Join-Path $packageRoot "raw_logs"
        ArtifactRoot = Join-Path $packageRoot "artifacts"
        ProposalRoot = Join-Path (Join-Path $packageRoot "artifacts") "proposal"
        CycleRoot = Join-Path (Join-Path $packageRoot "artifacts") "cycle"
        BaselineRoot = Join-Path (Join-Path $packageRoot "artifacts") "baseline_binding"
        DispatchRoot = Join-Path (Join-Path $packageRoot "artifacts") "dispatch"
        EvidenceRoot = Join-Path (Join-Path $packageRoot "artifacts") "evidence"
        QARoot = Join-Path (Join-Path $packageRoot "artifacts") "qa"
        SummaryRoot = Join-Path (Join-Path $packageRoot "artifacts") "summary"
        CloseoutRoot = Join-Path (Join-Path $packageRoot "artifacts") "closeout"
        ExecutorOutputRoot = Join-Path (Join-Path $packageRoot "artifacts") "executor_outputs"
        QAInputRoot = Join-Path (Join-Path $packageRoot "artifacts") "qa_inputs"
        ReplaySummaryPath = Join-Path $packageRoot "REPLAY_SUMMARY.md"
        CloseoutReviewPath = Join-Path $packageRoot "CLOSEOUT_REVIEW.md"
        ManifestPath = Join-Path $packageRoot "proof_review_manifest.json"
        CommandsPath = Join-Path (Join-Path $packageRoot "meta") "replayed_commands.txt"
        ReplaySourcePath = Join-Path (Join-Path $packageRoot "meta") "replay_source.json"
        SelectionScopePath = Join-Path (Join-Path $packageRoot "meta") "proof_selection_scope.json"
        ArtifactRefsPath = Join-Path (Join-Path $packageRoot "meta") "authoritative_artifact_refs.json"
        NonClaimsPath = Join-Path (Join-Path $packageRoot "meta") "non_claims.json"
        StepLogPath = Join-Path (Join-Path $packageRoot "raw_logs") "replay_steps.log"
        EventLogPath = Join-Path (Join-Path $packageRoot "raw_logs") "replay_events.jsonl"
    }
}

function Ensure-DirectoryLayout {
    param(
        [Parameter(Mandatory = $true)]
        $PackagePaths
    )

    foreach ($path in @(
            $PackagePaths.PackageRoot,
            $PackagePaths.MetaRoot,
            $PackagePaths.RawLogsRoot,
            $PackagePaths.ArtifactRoot,
            $PackagePaths.ProposalRoot,
            $PackagePaths.CycleRoot,
            $PackagePaths.BaselineRoot,
            $PackagePaths.DispatchRoot,
            $PackagePaths.EvidenceRoot,
            $PackagePaths.QARoot,
            $PackagePaths.SummaryRoot,
            $PackagePaths.CloseoutRoot,
            $PackagePaths.ExecutorOutputRoot,
            $PackagePaths.QAInputRoot
        )) {
        if (-not (Test-Path -LiteralPath $path)) {
            New-Item -ItemType Directory -Path $path -Force | Out-Null
        }
    }
}

function Write-StepLog {
    param(
        [Parameter(Mandatory = $true)]
        $PackagePaths,
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    $timestamp = Get-UtcTimestamp
    $line = "[{0}] {1}" -f $timestamp, $Message
    Append-Utf8File -Path $PackagePaths.StepLogPath -Value $line
    Write-Output $line
}

function Write-EventLog {
    param(
        [Parameter(Mandatory = $true)]
        $PackagePaths,
        [Parameter(Mandatory = $true)]
        [string]$EventType,
        [Parameter(Mandatory = $true)]
        $Data
    )

    $eventDocument = [pscustomobject]@{
        timestamp_utc = Get-UtcTimestamp
        event_type = $EventType
        data = $Data
    }
    Append-Utf8File -Path $PackagePaths.EventLogPath -Value ($eventDocument | ConvertTo-Json -Depth 15 -Compress)
}

function Get-ExactScopeStatements {
    param(
        [Parameter(Mandatory = $true)]
        [string]$CycleId,
        [Parameter(Mandatory = $true)]
        [string]$ProposalIntakeRelativeRef,
        [Parameter(Mandatory = $true)]
        [string[]]$FrozenTaskIds
    )

    $taskList = $FrozenTaskIds -join ", "
    return [pscustomobject]@{
        ReplayScope = "Exact replay scope: cycle $CycleId replays from structured intake $ProposalIntakeRelativeRef through advisory-only operator decision across frozen tasks $taskList."
        CloseoutScope = "Exact closeout scope: close out only cycle $CycleId from structured intake $ProposalIntakeRelativeRef through advisory-only operator decision across frozen tasks $taskList."
        BoundaryStatement = "This replay remains bounded to cycle $CycleId for AIOffice_V2 only and preserves advisory-only operator decision state."
        ProvedScope = "Proved scope: cycle $CycleId replays one exact supervised pilot path from intake, proposal, approval, freeze, one Git-backed baseline binding, $($FrozenTaskIds.Count) sequential governed dispatches with matching run ledgers, $($FrozenTaskIds.Count) execution evidence bundles, $($FrozenTaskIds.Count) QA observations rolled into one milestone QA aggregation, one bounded summary, one advisory-only operator decision packet, one replay proof, and one closeout packet."
        UnprovedScope = "Unproved scope: no explicit operator acceptance artifact is referenced for cycle $CycleId, so this replay does not prove an executed operator choice beyond advisory review surfaces."
        OutOfScope = "Out of scope: broader autonomy, unattended automatic resume, rollback execution, UI, Standard runtime, multi-repo behavior, swarms, and broader orchestration."
    }
}

function New-AllowedScope {
    param(
        [Parameter(Mandatory = $true)]
        $FrozenTask,
        [Parameter(Mandatory = $true)]
        [string]$PackageRootRelative
    )

    return [pscustomobject]@{
        scope_kind = "frozen_task_dispatch"
        scope_summary = $FrozenTask.scope_summary
        allowed_paths = @(
            "{0}/artifacts/**" -f $PackageRootRelative
        )
        blocked_paths = @(
            "governance/**",
            "execution/**",
            "README.md"
        )
    }
}

function New-ExpectedOutputs {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageRootRelative,
        [Parameter(Mandatory = $true)]
        [string]$TaskId
    )

    return @(
        [pscustomobject]@{
            kind = "executor_artifact"
            path = "{0}/artifacts/executor_outputs/{1}/*" -f $PackageRootRelative, $TaskId
            notes = "Durable executor output for the replayed task."
        },
        [pscustomobject]@{
            kind = "execution_evidence"
            path = "{0}/artifacts/evidence/execution_evidence/*.json" -f $PackageRootRelative
            notes = "Durable governed execution evidence for the replayed task."
        }
    )
}

function New-RefusalConditions {
    return @(
        [pscustomobject]@{
            code = "repo_state_drift"
            description = "Refuse when the live repository branch, head commit, tree, or worktree cleanliness drifts from the pinned baseline."
        },
        [pscustomobject]@{
            code = "executor_evidence_incomplete"
            description = "Refuse when required produced artifacts, test outputs, or evidence refs are missing."
        },
        [pscustomobject]@{
            code = "proof_integrity_inconsistent"
            description = "Refuse when authoritative replay lineage becomes inconsistent with the frozen pilot cycle."
        }
    )
}

function New-ExecutionEvidenceInputs {
    param(
        [Parameter(Mandatory = $true)]
        $PackagePaths,
        [Parameter(Mandatory = $true)]
        [string]$TaskId,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $taskOutputRoot = Join-Path $PackagePaths.ExecutorOutputRoot $TaskId
    if (-not (Test-Path -LiteralPath $taskOutputRoot)) {
        New-Item -ItemType Directory -Path $taskOutputRoot -Force | Out-Null
    }

    $artifactPath = Join-Path $taskOutputRoot "artifact.txt"
    $testOutputPath = Join-Path $taskOutputRoot "test-output.log"
    $evidenceRefPath = Join-Path $taskOutputRoot "evidence-ref.md"

    Write-Utf8File -Path $artifactPath -Value ("Replay artifact for {0}" -f $TaskId)
    Write-Utf8File -Path $testOutputPath -Value ("Replay test output for {0}" -f $TaskId)
    Write-Utf8File -Path $evidenceRefPath -Value ("Replay evidence reference for {0}" -f $TaskId)

    $artifactRelativePath = Get-RelativePathFromRoot -Root $repositoryRoot -Path $artifactPath
    $testOutputRelativePath = Get-RelativePathFromRoot -Root $repositoryRoot -Path $testOutputPath
    $evidenceRefRelativePath = Get-RelativePathFromRoot -Root $repositoryRoot -Path $evidenceRefPath

    return [pscustomobject]@{
        ChangedFiles = @(
            [pscustomobject]@{
                path = $artifactRelativePath
                change_kind = "added"
                notes = "Replay artifact generated for the task."
            },
            [pscustomobject]@{
                path = $testOutputRelativePath
                change_kind = "added"
                notes = "Replay test output generated for the task."
            },
            [pscustomobject]@{
                path = $evidenceRefRelativePath
                change_kind = "added"
                notes = "Replay evidence reference generated for the task."
            }
        )
        ProducedArtifacts = @(
            [pscustomobject]@{
                kind = "executor_artifact"
                path = $artifactRelativePath
                notes = "Durable replay artifact for the task."
            }
        )
        TestOutputs = @(
            [pscustomobject]@{
                kind = "powershell_log"
                ref = $testOutputRelativePath
                notes = "Durable replay test output for the task."
            }
        )
        EvidenceRefs = @(
            [pscustomobject]@{
                kind = "executor_note"
                ref = $evidenceRefRelativePath
                notes = "Durable replay evidence reference for the task."
            }
        )
    }
}

function New-QAEvidenceInput {
    param(
        [Parameter(Mandatory = $true)]
        $PackagePaths,
        [Parameter(Mandatory = $true)]
        [string]$TaskId,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $qaInputPath = Join-Path $PackagePaths.QAInputRoot ("{0}-qa.md" -f $TaskId)
    Write-Utf8File -Path $qaInputPath -Value ("Replay QA evidence ref for {0}" -f $TaskId)

    return [pscustomobject]@{
        Finding = [pscustomobject]@{
            finding_id = "finding-{0}" -f $TaskId
            summary = "QA passed for replayed task $TaskId."
            notes = "Replay QA finding for the exact pilot scope."
        }
        EvidenceRef = [pscustomobject]@{
            kind = "qa_note"
            ref = (Get-RelativePathFromRoot -Root $RepositoryRoot -Path $qaInputPath)
            notes = "Durable replay QA evidence reference for the task."
        }
    }
}

function Get-ManifestRequiredFields {
    return @(
        "package_version",
        "package_type",
        "scenario_id",
        "cycle_id",
        "operator_decision_state",
        "proposal_intake_ref",
        "summary_ref",
        "decision_packet_ref",
        "replay_proof_ref",
        "closeout_packet_ref",
        "selection_scope_ref",
        "replay_source_ref",
        "replay_commands_ref",
        "authoritative_artifact_refs_ref",
        "non_claims_ref",
        "replay_summary_ref",
        "closeout_review_ref",
        "raw_log_refs",
        "notes"
    )
}

function Get-SelectionScopeRequiredFields {
    return @(
        "scenario_id",
        "cycle_id",
        "scope_statement",
        "closeout_scope_statement",
        "input_refs",
        "frozen_task_ids",
        "dispatched_task_ids",
        "replay_chain",
        "notes"
    )
}

function Get-ReplaySourceRequiredFields {
    return @(
        "scenario_id",
        "cycle_id",
        "repository_root_relative",
        "branch",
        "source_head_commit",
        "source_tree_id",
        "generated_by_script",
        "generated_at_utc"
    )
}

function Get-AuthoritativeArtifactRefRequiredFields {
    return @(
        "proposal_intake_ref",
        "request_brief_ref",
        "milestone_ref",
        "proposal_ref",
        "approval_ref",
        "freeze_ref",
        "baseline_binding_ref",
        "dispatch_refs",
        "run_ledger_refs",
        "execution_evidence_refs",
        "qa_observation_refs",
        "qa_aggregation_ref",
        "summary_ref",
        "decision_packet_ref",
        "replay_proof_ref",
        "closeout_packet_ref"
    )
}

function Get-AllowedReplayChain {
    return @(
        "proposal_intake",
        "proposal",
        "approval",
        "freeze",
        "baseline_binding",
        "dispatch",
        "run_ledger",
        "execution_evidence",
        "qa_observation",
        "qa_aggregation",
        "summary",
        "decision_packet",
        "replay_proof",
        "closeout_packet"
    )
}

function Validate-NonClaimsArray {
    param(
        [AllowNull()]
        $NonClaims,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $items = [string[]](Assert-StringArray -Value $NonClaims -Context $Context)
    $requiredFragments = @("operator decision", "autonomy", "rollback", "unattended automatic resume", "ui", "standard runtime", "multi-repo", "swarms", "broader orchestration")
    foreach ($requiredFragment in $requiredFragments) {
        $match = @($items | Where-Object {
                $_.IndexOf($requiredFragment, [System.StringComparison]::OrdinalIgnoreCase) -ge 0
            })
        if ($match.Count -eq 0) {
            throw "$Context must explicitly cover '$requiredFragment'."
        }
    }

    return $items
}

function Assert-NoExecutedDecisionClaims {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($fragment in @(Get-ForbiddenExecutedDecisionFragments)) {
        if ($Value.IndexOf($fragment, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
            throw "$Context must not represent advisory operator choice as executed."
        }
    }

    return $Value
}

function Validate-SelectionScopeDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SelectionScopePath,
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory
    )

    $selectionScope = Get-JsonDocument -Path $SelectionScopePath -Label "Proof review selection scope"
    $foundation = Get-MilestoneAutocycleFoundationContract
    foreach ($fieldName in @(Get-SelectionScopeRequiredFields)) {
        Get-RequiredProperty -Object $selectionScope -Name $fieldName -Context "Proof review selection scope" | Out-Null
    }

    $scenarioId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $selectionScope -Name "scenario_id" -Context "Proof review selection scope") -Context "Proof review selection scope.scenario_id"
    $cycleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $selectionScope -Name "cycle_id" -Context "Proof review selection scope") -Context "Proof review selection scope.cycle_id"
    Assert-RegexMatch -Value $scenarioId -Pattern $foundation.identifier_pattern -Context "Proof review selection scope.scenario_id"
    Assert-RegexMatch -Value $cycleId -Pattern $foundation.identifier_pattern -Context "Proof review selection scope.cycle_id"

    $scopeStatement = Assert-NoExecutedDecisionClaims -Value (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $selectionScope -Name "scope_statement" -Context "Proof review selection scope") -Context "Proof review selection scope.scope_statement") -Context "Proof review selection scope.scope_statement"
    $closeoutScopeStatement = Assert-NoExecutedDecisionClaims -Value (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $selectionScope -Name "closeout_scope_statement" -Context "Proof review selection scope") -Context "Proof review selection scope.closeout_scope_statement") -Context "Proof review selection scope.closeout_scope_statement"
    $notes = Assert-NoExecutedDecisionClaims -Value (Assert-NonEmptyString -Value (Get-RequiredProperty -Object $selectionScope -Name "notes" -Context "Proof review selection scope") -Context "Proof review selection scope.notes") -Context "Proof review selection scope.notes"

    $inputRefs = Assert-ObjectValue -Value (Get-RequiredProperty -Object $selectionScope -Name "input_refs" -Context "Proof review selection scope") -Context "Proof review selection scope.input_refs"
    foreach ($fieldName in @("proposal_intake_ref", "request_brief_ref", "milestone_ref")) {
        Get-RequiredProperty -Object $inputRefs -Name $fieldName -Context "Proof review selection scope.input_refs" | Out-Null
    }

    $proposalIntakePath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value $inputRefs.proposal_intake_ref -Context "Proof review selection scope.input_refs.proposal_intake_ref") -Label "Proof review selection scope proposal intake"
    $requestBriefPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value $inputRefs.request_brief_ref -Context "Proof review selection scope.input_refs.request_brief_ref") -Label "Proof review selection scope request brief"
    $milestonePath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value $inputRefs.milestone_ref -Context "Proof review selection scope.input_refs.milestone_ref") -Label "Proof review selection scope milestone"

    $frozenTaskIds = [string[]](Assert-StringArray -Value (Get-RequiredProperty -Object $selectionScope -Name "frozen_task_ids" -Context "Proof review selection scope") -Context "Proof review selection scope.frozen_task_ids")
    $dispatchedTaskIds = [string[]](Assert-StringArray -Value (Get-RequiredProperty -Object $selectionScope -Name "dispatched_task_ids" -Context "Proof review selection scope") -Context "Proof review selection scope.dispatched_task_ids")
    $replayChain = [string[]](Assert-StringArray -Value (Get-RequiredProperty -Object $selectionScope -Name "replay_chain" -Context "Proof review selection scope") -Context "Proof review selection scope.replay_chain")

    $expectedReplayChain = @(Get-AllowedReplayChain)
    if (@($replayChain | Sort-Object -Unique).Count -ne $expectedReplayChain.Count) {
        throw "Proof review selection scope.replay_chain must contain the exact bounded replay chain."
    }
    foreach ($expectedStage in $expectedReplayChain) {
        if ($replayChain -notcontains $expectedStage) {
            throw "Proof review selection scope.replay_chain must contain stage '$expectedStage'."
        }
    }

    return [pscustomobject]@{
        ScenarioId = $scenarioId
        CycleId = $cycleId
        ScopeStatement = $scopeStatement
        CloseoutScopeStatement = $closeoutScopeStatement
        ProposalIntakePath = $proposalIntakePath
        RequestBriefPath = $requestBriefPath
        MilestonePath = $milestonePath
        FrozenTaskIds = @($frozenTaskIds)
        DispatchedTaskIds = @($dispatchedTaskIds)
        ReplayChain = @($replayChain)
        Notes = $notes
    }
}

function Validate-ReplaySourceDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ReplaySourcePath
    )

    $replaySource = Get-JsonDocument -Path $ReplaySourcePath -Label "Proof review replay source metadata"
    $foundation = Get-MilestoneAutocycleFoundationContract
    foreach ($fieldName in @(Get-ReplaySourceRequiredFields)) {
        Get-RequiredProperty -Object $replaySource -Name $fieldName -Context "Proof review replay source metadata" | Out-Null
    }

    $scenarioId = Assert-NonEmptyString -Value $replaySource.scenario_id -Context "Proof review replay source metadata.scenario_id"
    $cycleId = Assert-NonEmptyString -Value $replaySource.cycle_id -Context "Proof review replay source metadata.cycle_id"
    $repositoryRootRelative = Assert-NonEmptyString -Value $replaySource.repository_root_relative -Context "Proof review replay source metadata.repository_root_relative"
    $branch = Assert-NonEmptyString -Value $replaySource.branch -Context "Proof review replay source metadata.branch"
    $sourceHeadCommit = Assert-NonEmptyString -Value $replaySource.source_head_commit -Context "Proof review replay source metadata.source_head_commit"
    $sourceTreeId = Assert-NonEmptyString -Value $replaySource.source_tree_id -Context "Proof review replay source metadata.source_tree_id"
    $generatedByScript = Assert-NonEmptyString -Value $replaySource.generated_by_script -Context "Proof review replay source metadata.generated_by_script"
    $generatedAtUtc = Assert-NonEmptyString -Value $replaySource.generated_at_utc -Context "Proof review replay source metadata.generated_at_utc"

    Assert-RegexMatch -Value $scenarioId -Pattern $foundation.identifier_pattern -Context "Proof review replay source metadata.scenario_id"
    Assert-RegexMatch -Value $cycleId -Pattern $foundation.identifier_pattern -Context "Proof review replay source metadata.cycle_id"
    Assert-RegexMatch -Value $branch -Pattern $foundation.identifier_pattern -Context "Proof review replay source metadata.branch"
    Assert-RegexMatch -Value $sourceHeadCommit -Pattern "^[0-9a-f]{40}$" -Context "Proof review replay source metadata.source_head_commit"
    Assert-RegexMatch -Value $sourceTreeId -Pattern "^[0-9a-f]{40}$" -Context "Proof review replay source metadata.source_tree_id"
    Assert-RegexMatch -Value $generatedAtUtc -Pattern $foundation.timestamp_pattern -Context "Proof review replay source metadata.generated_at_utc"

    return [pscustomobject]@{
        ScenarioId = $scenarioId
        CycleId = $cycleId
        RepositoryRootRelative = $repositoryRootRelative
        Branch = $branch
        SourceHeadCommit = $sourceHeadCommit
        SourceTreeId = $sourceTreeId
        GeneratedByScript = $generatedByScript
        GeneratedAtUtc = $generatedAtUtc
    }
}

function Validate-AuthoritativeArtifactRefs {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArtifactRefsPath,
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory
    )

    $artifactRefs = Get-JsonDocument -Path $ArtifactRefsPath -Label "Proof review authoritative artifact refs"
    foreach ($fieldName in @(Get-AuthoritativeArtifactRefRequiredFields)) {
        Get-RequiredProperty -Object $artifactRefs -Name $fieldName -Context "Proof review authoritative artifact refs" | Out-Null
    }

    $proposalIntakePath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value $artifactRefs.proposal_intake_ref -Context "Proof review authoritative artifact refs.proposal_intake_ref") -Label "Proof review authoritative proposal intake"
    $requestBriefPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value $artifactRefs.request_brief_ref -Context "Proof review authoritative artifact refs.request_brief_ref") -Label "Proof review authoritative request brief"
    $milestonePath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value $artifactRefs.milestone_ref -Context "Proof review authoritative artifact refs.milestone_ref") -Label "Proof review authoritative milestone"
    $proposalPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value $artifactRefs.proposal_ref -Context "Proof review authoritative artifact refs.proposal_ref") -Label "Proof review authoritative proposal"
    $approvalPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value $artifactRefs.approval_ref -Context "Proof review authoritative artifact refs.approval_ref") -Label "Proof review authoritative approval"
    $freezePath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value $artifactRefs.freeze_ref -Context "Proof review authoritative artifact refs.freeze_ref") -Label "Proof review authoritative freeze"
    $bindingPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value $artifactRefs.baseline_binding_ref -Context "Proof review authoritative artifact refs.baseline_binding_ref") -Label "Proof review authoritative baseline binding"
    $qaAggregationPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value $artifactRefs.qa_aggregation_ref -Context "Proof review authoritative artifact refs.qa_aggregation_ref") -Label "Proof review authoritative QA aggregation"
    $summaryPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value $artifactRefs.summary_ref -Context "Proof review authoritative artifact refs.summary_ref") -Label "Proof review authoritative summary"
    $decisionPacketPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value $artifactRefs.decision_packet_ref -Context "Proof review authoritative artifact refs.decision_packet_ref") -Label "Proof review authoritative decision packet"
    $replayProofPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value $artifactRefs.replay_proof_ref -Context "Proof review authoritative artifact refs.replay_proof_ref") -Label "Proof review authoritative replay proof"
    $closeoutPacketPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference (Assert-NonEmptyString -Value $artifactRefs.closeout_packet_ref -Context "Proof review authoritative artifact refs.closeout_packet_ref") -Label "Proof review authoritative closeout packet"

    $dispatchRefs = [string[]](Assert-StringArray -Value $artifactRefs.dispatch_refs -Context "Proof review authoritative artifact refs.dispatch_refs")
    $runLedgerRefs = [string[]](Assert-StringArray -Value $artifactRefs.run_ledger_refs -Context "Proof review authoritative artifact refs.run_ledger_refs")
    $executionEvidenceRefs = [string[]](Assert-StringArray -Value $artifactRefs.execution_evidence_refs -Context "Proof review authoritative artifact refs.execution_evidence_refs")
    $qaObservationRefs = [string[]](Assert-StringArray -Value $artifactRefs.qa_observation_refs -Context "Proof review authoritative artifact refs.qa_observation_refs")

    $proposalIntakeValidation = & (Get-ProposalIntakeValidatorCommand) -ProposalIntakePath $proposalIntakePath
    $proposalValidation = & (Get-ProposalValidatorCommand) -ProposalPath $proposalPath
    $approvalValidation = & (Get-ApprovalValidatorCommand) -ApprovalPath $approvalPath
    $freezeValidation = & (Get-FreezeValidatorCommand) -FreezePath $freezePath
    $bindingValidation = & (Get-BaselineBindingValidatorCommand) -BindingPath $bindingPath
    $qaAggregationValidation = & (Get-QAAggregationValidatorCommand) -QAAggregationPath $qaAggregationPath

    $dispatchValidations = @()
    foreach ($dispatchRef in $dispatchRefs) {
        $dispatchPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference $dispatchRef -Label "Proof review dispatch"
        $dispatchValidations += (& (Get-DispatchValidatorCommand) -DispatchPath $dispatchPath)
    }

    $runLedgerValidations = @()
    foreach ($runLedgerRef in $runLedgerRefs) {
        $runLedgerPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference $runLedgerRef -Label "Proof review run ledger"
        $runLedgerValidations += (& (Get-RunLedgerValidatorCommand) -LedgerPath $runLedgerPath)
    }

    $executionEvidenceValidations = @()
    foreach ($executionEvidenceRef in $executionEvidenceRefs) {
        $executionEvidencePath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference $executionEvidenceRef -Label "Proof review execution evidence"
        $executionEvidenceValidations += (& (Get-ExecutionEvidenceValidatorCommand) -EvidenceBundlePath $executionEvidencePath)
    }

    $qaObservationValidations = @()
    foreach ($qaObservationRef in $qaObservationRefs) {
        $qaObservationPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference $qaObservationRef -Label "Proof review QA observation"
        $qaObservationValidations += (& (Get-QAObservationValidatorCommand) -QAObservationPath $qaObservationPath)
    }

    return [pscustomobject]@{
        ProposalIntakeValidation = $proposalIntakeValidation
        ProposalValidation = $proposalValidation
        ApprovalValidation = $approvalValidation
        FreezeValidation = $freezeValidation
        BindingValidation = $bindingValidation
        DispatchValidations = @($dispatchValidations)
        RunLedgerValidations = @($runLedgerValidations)
        ExecutionEvidenceValidations = @($executionEvidenceValidations)
        QAObservationValidations = @($qaObservationValidations)
        QAAggregationValidation = $qaAggregationValidation
        ProposalIntakePath = $proposalIntakePath
        RequestBriefPath = $requestBriefPath
        MilestonePath = $milestonePath
        ProposalPath = $proposalPath
        ApprovalPath = $approvalPath
        FreezePath = $freezePath
        BindingPath = $bindingPath
        QAAggregationPath = $qaAggregationPath
        SummaryPath = $summaryPath
        DecisionPacketPath = $decisionPacketPath
        ReplayProofPath = $replayProofPath
        CloseoutPacketPath = $closeoutPacketPath
    }
}

function Test-MilestoneAutocycleProofReviewPackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageRoot
    )

    $resolvedPackageRoot = Resolve-ExistingPath -PathValue $PackageRoot -Label "Proof review package root"
    $repositoryRoot = Get-GitWorktreeRoot -PathValue $resolvedPackageRoot -Label "Proof review package root"
    $manifestPath = Join-Path $resolvedPackageRoot "proof_review_manifest.json"
    if (-not (Test-Path -LiteralPath $manifestPath)) {
        throw "Proof review package manifest is missing."
    }

    $manifest = Get-JsonDocument -Path $manifestPath -Label "Proof review package manifest"
    $foundation = Get-MilestoneAutocycleFoundationContract
    foreach ($fieldName in @(Get-ManifestRequiredFields)) {
        Get-RequiredProperty -Object $manifest -Name $fieldName -Context "Proof review package manifest" | Out-Null
    }

    $packageVersion = Assert-NonEmptyString -Value $manifest.package_version -Context "Proof review package manifest.package_version"
    if ($packageVersion -ne $foundation.contract_version) {
        throw "Proof review package manifest.package_version must equal '$($foundation.contract_version)'."
    }

    $packageType = Assert-NonEmptyString -Value $manifest.package_type -Context "Proof review package manifest.package_type"
    if ($packageType -ne (Get-ProofReviewPackageType)) {
        throw "Proof review package manifest.package_type must equal '$(Get-ProofReviewPackageType)'."
    }

    $scenarioId = Assert-NonEmptyString -Value $manifest.scenario_id -Context "Proof review package manifest.scenario_id"
    $cycleId = Assert-NonEmptyString -Value $manifest.cycle_id -Context "Proof review package manifest.cycle_id"
    $operatorDecisionState = Assert-NonEmptyString -Value $manifest.operator_decision_state -Context "Proof review package manifest.operator_decision_state"
    $notes = Assert-NoExecutedDecisionClaims -Value (Assert-NonEmptyString -Value $manifest.notes -Context "Proof review package manifest.notes") -Context "Proof review package manifest.notes"

    Assert-RegexMatch -Value $scenarioId -Pattern $foundation.identifier_pattern -Context "Proof review package manifest.scenario_id"
    Assert-RegexMatch -Value $cycleId -Pattern $foundation.identifier_pattern -Context "Proof review package manifest.cycle_id"
    Assert-AllowedValue -Value $operatorDecisionState -AllowedValues @($foundation.allowed_operator_decision_states) -Context "Proof review package manifest.operator_decision_state"

    $selectionScopePath = Resolve-ReferenceAgainstBase -BaseDirectory $resolvedPackageRoot -Reference (Assert-NonEmptyString -Value $manifest.selection_scope_ref -Context "Proof review package manifest.selection_scope_ref") -Label "Proof review selection scope"
    $replaySourcePath = Resolve-ReferenceAgainstBase -BaseDirectory $resolvedPackageRoot -Reference (Assert-NonEmptyString -Value $manifest.replay_source_ref -Context "Proof review package manifest.replay_source_ref") -Label "Proof review replay source metadata"
    $commandsPath = Resolve-ReferenceAgainstBase -BaseDirectory $resolvedPackageRoot -Reference (Assert-NonEmptyString -Value $manifest.replay_commands_ref -Context "Proof review package manifest.replay_commands_ref") -Label "Proof review replay commands"
    $artifactRefsPath = Resolve-ReferenceAgainstBase -BaseDirectory $resolvedPackageRoot -Reference (Assert-NonEmptyString -Value $manifest.authoritative_artifact_refs_ref -Context "Proof review package manifest.authoritative_artifact_refs_ref") -Label "Proof review authoritative artifact refs"
    $nonClaimsPath = Resolve-ReferenceAgainstBase -BaseDirectory $resolvedPackageRoot -Reference (Assert-NonEmptyString -Value $manifest.non_claims_ref -Context "Proof review package manifest.non_claims_ref") -Label "Proof review non-claims"
    $replaySummaryPath = Resolve-ReferenceAgainstBase -BaseDirectory $resolvedPackageRoot -Reference (Assert-NonEmptyString -Value $manifest.replay_summary_ref -Context "Proof review package manifest.replay_summary_ref") -Label "Proof review replay summary"
    $closeoutReviewPath = Resolve-ReferenceAgainstBase -BaseDirectory $resolvedPackageRoot -Reference (Assert-NonEmptyString -Value $manifest.closeout_review_ref -Context "Proof review package manifest.closeout_review_ref") -Label "Proof review closeout review"
    $proposalIntakePath = Resolve-ReferenceAgainstBase -BaseDirectory $resolvedPackageRoot -Reference (Assert-NonEmptyString -Value $manifest.proposal_intake_ref -Context "Proof review package manifest.proposal_intake_ref") -Label "Proof review proposal intake"
    $summaryPath = Resolve-ReferenceAgainstBase -BaseDirectory $resolvedPackageRoot -Reference (Assert-NonEmptyString -Value $manifest.summary_ref -Context "Proof review package manifest.summary_ref") -Label "Proof review summary"
    $decisionPacketPath = Resolve-ReferenceAgainstBase -BaseDirectory $resolvedPackageRoot -Reference (Assert-NonEmptyString -Value $manifest.decision_packet_ref -Context "Proof review package manifest.decision_packet_ref") -Label "Proof review decision packet"
    $replayProofPath = Resolve-ReferenceAgainstBase -BaseDirectory $resolvedPackageRoot -Reference (Assert-NonEmptyString -Value $manifest.replay_proof_ref -Context "Proof review package manifest.replay_proof_ref") -Label "Proof review replay proof"
    $closeoutPacketPath = Resolve-ReferenceAgainstBase -BaseDirectory $resolvedPackageRoot -Reference (Assert-NonEmptyString -Value $manifest.closeout_packet_ref -Context "Proof review package manifest.closeout_packet_ref") -Label "Proof review closeout packet"

    $rawLogRefs = [string[]](Assert-StringArray -Value $manifest.raw_log_refs -Context "Proof review package manifest.raw_log_refs")
    $resolvedRawLogPaths = @()
    foreach ($rawLogRef in $rawLogRefs) {
        $rawLogPath = Resolve-ReferenceAgainstBase -BaseDirectory $resolvedPackageRoot -Reference $rawLogRef -Label "Proof review raw log"
        if ([string]::IsNullOrWhiteSpace((Get-Content -LiteralPath $rawLogPath -Raw))) {
            throw "Proof review package raw log '$rawLogRef' must not be empty."
        }
        $resolvedRawLogPaths += $rawLogPath
    }

    $selectionScope = Validate-SelectionScopeDocument -SelectionScopePath $selectionScopePath -BaseDirectory $resolvedPackageRoot
    $replaySource = Validate-ReplaySourceDocument -ReplaySourcePath $replaySourcePath
    $authoritativeArtifacts = Validate-AuthoritativeArtifactRefs -ArtifactRefsPath $artifactRefsPath -BaseDirectory $resolvedPackageRoot
    $nonClaims = Validate-NonClaimsArray -NonClaims (Get-JsonDocument -Path $nonClaimsPath -Label "Proof review non-claims") -Context "Proof review non-claims"

    $replayProofValidation = & (Get-ReplayProofValidatorCommand) -ReplayProofPath $replayProofPath
    $closeoutPacketValidation = & (Get-CloseoutPacketValidatorCommand) -CloseoutPacketPath $closeoutPacketPath

    if ($selectionScope.ScenarioId -ne $scenarioId -or $replaySource.ScenarioId -ne $scenarioId) {
        throw "Proof review package scenario_id must match selection scope and replay-source metadata."
    }
    foreach ($item in @(
            $selectionScope.CycleId,
            $replaySource.CycleId,
            $replayProofValidation.CycleId,
            $closeoutPacketValidation.CycleId,
            $authoritativeArtifacts.QAAggregationValidation.CycleId,
            $authoritativeArtifacts.ApprovalValidation.CycleId,
            $authoritativeArtifacts.FreezeValidation.CycleId,
            $authoritativeArtifacts.BindingValidation.CycleId
        )) {
        if ($item -ne $cycleId) {
            throw "Proof review package cycle_id must match every authoritative replay artifact."
        }
    }

    if ($operatorDecisionState -ne $replayProofValidation.OperatorDecisionState -or $operatorDecisionState -ne $closeoutPacketValidation.OperatorDecisionState) {
        throw "Proof review package operator_decision_state must match the replay proof and closeout packet."
    }

    if ($authoritativeArtifacts.SummaryPath -ne $summaryPath -or $authoritativeArtifacts.DecisionPacketPath -ne $decisionPacketPath) {
        throw "Proof review package requires summary and decision lineage to remain explicit."
    }
    if ($authoritativeArtifacts.ReplayProofPath -ne $replayProofPath -or $authoritativeArtifacts.CloseoutPacketPath -ne $closeoutPacketPath) {
        throw "Proof review package must preserve replay-proof and closeout-packet lineage explicitly."
    }
    if ($replayProofValidation.SummaryPath -ne $summaryPath -or $replayProofValidation.DecisionPacketPath -ne $decisionPacketPath) {
        throw "Proof review package replay proof must preserve summary and decision lineage explicitly."
    }
    if ($closeoutPacketValidation.SummaryPath -ne $summaryPath -or $closeoutPacketValidation.DecisionPacketPath -ne $decisionPacketPath) {
        throw "Proof review package closeout packet must preserve summary and decision lineage explicitly."
    }
    if ($authoritativeArtifacts.ProposalIntakePath -ne $proposalIntakePath) {
        throw "Proof review package proposal_intake_ref must match the authoritative selection scope intake."
    }

    $freeze = Get-JsonDocument -Path $authoritativeArtifacts.FreezePath -Label "Proof review authoritative freeze"
    $frozenTaskIds = @($freeze.frozen_task_set | ForEach-Object { $_.task_id } | Sort-Object -Unique)
    $dispatchTaskIds = @($authoritativeArtifacts.DispatchValidations | ForEach-Object { $_.TaskId } | Sort-Object -Unique)
    $qaTaskIds = @($authoritativeArtifacts.QAObservationValidations | ForEach-Object { $_.TaskId } | Sort-Object -Unique)
    $aggregationTaskIds = @($authoritativeArtifacts.QAAggregationValidation.TaskResults | ForEach-Object { $_.task_id } | Sort-Object -Unique)

    if (($frozenTaskIds -join "|") -ne (@($selectionScope.FrozenTaskIds | Sort-Object -Unique) -join "|")) {
        throw "Proof review package selection scope must match the exact frozen task set."
    }
    if (($dispatchTaskIds -join "|") -ne (@($selectionScope.DispatchedTaskIds | Sort-Object -Unique) -join "|")) {
        throw "Proof review package selection scope must match the exact dispatched task set."
    }
    if (($dispatchTaskIds -join "|") -ne ($qaTaskIds -join "|") -or ($dispatchTaskIds -join "|") -ne ($aggregationTaskIds -join "|")) {
        throw "Proof review package task lineage across dispatch, QA observation, and QA aggregation must remain exact."
    }

    $replaySummaryText = Get-Content -LiteralPath $replaySummaryPath -Raw
    $closeoutReviewText = Get-Content -LiteralPath $closeoutReviewPath -Raw
    $commandsText = Get-Content -LiteralPath $commandsPath -Raw
    if ([string]::IsNullOrWhiteSpace($commandsText)) {
        throw "Proof review package replay command list must not be empty."
    }
    foreach ($textCheck in @(
            @{ Text = $replaySummaryText; Context = "Proof review replay summary" },
            @{ Text = $closeoutReviewText; Context = "Proof review closeout review" }
        )) {
        if ($textCheck.Text.IndexOf($selectionScope.ScopeStatement, [System.StringComparison]::Ordinal) -lt 0 -and $textCheck.Context -eq "Proof review replay summary") {
            throw "Proof review replay summary must carry the exact replay scope statement."
        }
        if ($textCheck.Text.IndexOf($selectionScope.CloseoutScopeStatement, [System.StringComparison]::Ordinal) -lt 0 -and $textCheck.Context -eq "Proof review closeout review") {
            throw "Proof review closeout review must carry the exact closeout scope statement."
        }
        if ($textCheck.Text.IndexOf((Get-RelativePathFromRoot -Root $repositoryRoot -Path $summaryPath), [System.StringComparison]::OrdinalIgnoreCase) -lt 0 -and $textCheck.Context -eq "Proof review replay summary") {
            throw "Proof review replay summary must preserve summary lineage explicitly."
        }
        if ($textCheck.Text.IndexOf((Get-RelativePathFromRoot -Root $repositoryRoot -Path $decisionPacketPath), [System.StringComparison]::OrdinalIgnoreCase) -lt 0 -and $textCheck.Context -eq "Proof review replay summary") {
            throw "Proof review replay summary must preserve decision-packet lineage explicitly."
        }
        Assert-NoExecutedDecisionClaims -Value $textCheck.Text -Context $textCheck.Context | Out-Null
    }

    $replayProof = Get-JsonDocument -Path $replayProofPath -Label "Proof review replay proof"
    $closeoutPacket = Get-JsonDocument -Path $closeoutPacketPath -Label "Proof review closeout packet"
    if ($replayProof.replay_scope -ne $selectionScope.ScopeStatement) {
        throw "Proof review package exact replay scope must match the replay proof wording."
    }
    if ($closeoutPacket.closeout_scope -ne $selectionScope.CloseoutScopeStatement) {
        throw "Proof review package exact replay scope must match the closeout wording."
    }

    if ($replaySource.GeneratedByScript -notlike "*tools/new_r6_supervised_milestone_autocycle_proof_review.ps1*") {
        throw "Proof review replay-source metadata must record the replay entrypoint."
    }

    return [pscustomobject]@{
        IsValid = $true
        PackageRoot = $resolvedPackageRoot
        ManifestPath = $manifestPath
        ScenarioId = $scenarioId
        CycleId = $cycleId
        ProposalIntakePath = $proposalIntakePath
        SummaryPath = $summaryPath
        DecisionPacketPath = $decisionPacketPath
        ReplayProofPath = $replayProofPath
        CloseoutPacketPath = $closeoutPacketPath
        ReplaySummaryPath = $replaySummaryPath
        CloseoutReviewPath = $closeoutReviewPath
        RawLogPaths = @($resolvedRawLogPaths)
        OperatorDecisionState = $operatorDecisionState
        Notes = $notes
    }
}

function Invoke-MilestoneAutocycleProofReviewFlow {
    [CmdletBinding()]
    param(
        [string]$OutputRoot = "state/proof_reviews/r6_supervised_milestone_autocycle_pilot",
        [string]$ProposalIntakePath = "state/fixtures/valid/milestone_autocycle/proposal_intake.valid.json",
        [string]$ScenarioId = "r6-supervised-milestone-autocycle-pilot-proof-001",
        [string]$CycleId = "cycle-r6-supervised-milestone-autocycle-pilot-proof-001",
        [string]$OperatorId = "operator:rodney",
        [string]$RepositoryRoot = (Get-ModuleRepositoryRootPath)
    )

    $foundation = Get-MilestoneAutocycleFoundationContract
    Assert-RegexMatch -Value $ScenarioId -Pattern $foundation.identifier_pattern -Context "ScenarioId"
    Assert-RegexMatch -Value $CycleId -Pattern $foundation.identifier_pattern -Context "CycleId"
    Assert-RegexMatch -Value $OperatorId -Pattern $foundation.operator_pattern -Context "OperatorId"

    $repositoryRoot = Resolve-ExistingPath -PathValue $RepositoryRoot -Label "Proof review repository root"
    Assert-CleanGitWorktree -RepositoryRoot $repositoryRoot

    $proposalIntakeFullPath = Resolve-ExistingPath -PathValue $ProposalIntakePath -Label "Proposal intake" -AnchorPath $repositoryRoot
    $packagePaths = New-PackagePaths -RepositoryRoot $repositoryRoot -OutputRoot $OutputRoot
    if (Test-Path -LiteralPath $packagePaths.PackageRoot) {
        throw "Proof review output root '$($packagePaths.PackageRoot)' already exists."
    }

    $packageRootRelative = Get-RelativePathFromRoot -Root $repositoryRoot -Path $packagePaths.PackageRoot
    $replaySourceHead = Get-GitHeadCommit -RepositoryRoot $repositoryRoot
    $replaySourceTree = Get-GitTreeId -RepositoryRoot $repositoryRoot
    $replaySourceBranch = Get-GitBranchName -RepositoryRoot $repositoryRoot
    $generatedAtUtc = Get-UtcTimestamp
    $success = $false

    Add-TemporaryGitExcludePattern -RepositoryRoot $repositoryRoot -RelativeDirectory $packageRootRelative
    try {
        Ensure-DirectoryLayout -PackagePaths $packagePaths
        Write-StepLog -PackagePaths $packagePaths -Message "Starting exact R6 supervised milestone autocycle proof review replay."
        Write-EventLog -PackagePaths $packagePaths -EventType "replay_started" -Data ([pscustomobject]@{
                scenario_id = $ScenarioId
                cycle_id = $CycleId
                replay_source_head = $replaySourceHead
                replay_source_tree = $replaySourceTree
                branch = $replaySourceBranch
            })

        $proposalFlow = & (Get-ProposalFlowCommand) -ProposalIntakePath $proposalIntakeFullPath -OutputRoot $packagePaths.ProposalRoot -ProposalId "proposal-r6-supervised-milestone-autocycle-pilot-proof-001"
        Write-StepLog -PackagePaths $packagePaths -Message ("Proposal generated at {0}" -f (Get-RelativePathFromRoot -Root $repositoryRoot -Path $proposalFlow.ProposalPath))
        Write-EventLog -PackagePaths $packagePaths -EventType "proposal_generated" -Data ([pscustomobject]@{
                proposal_path = (Get-RelativePathFromRoot -Root $repositoryRoot -Path $proposalFlow.ProposalPath)
                proposal_intake_path = (Get-RelativePathFromRoot -Root $repositoryRoot -Path $proposalFlow.ProposalIntakePath)
            })

        $approvalFlow = & (Get-ApprovalFlowCommand) -ProposalPath $proposalFlow.ProposalPath -DecisionStatus approved -OperatorId $OperatorId -CycleId $CycleId -OutputRoot $packagePaths.CycleRoot -DecisionId "approval-r6-supervised-milestone-autocycle-pilot-proof-001" -FreezeId "freeze-r6-supervised-milestone-autocycle-pilot-proof-001" -DecidedAt (Get-Date).ToUniversalTime() -Notes "Approve the exact R6 supervised pilot scenario under explicit operator control only."
        Write-StepLog -PackagePaths $packagePaths -Message ("Approval and freeze recorded at {0} and {1}" -f (Get-RelativePathFromRoot -Root $repositoryRoot -Path $approvalFlow.ApprovalPath), (Get-RelativePathFromRoot -Root $repositoryRoot -Path $approvalFlow.FreezePath))
        Write-EventLog -PackagePaths $packagePaths -EventType "approval_and_freeze_recorded" -Data ([pscustomobject]@{
                approval_path = (Get-RelativePathFromRoot -Root $repositoryRoot -Path $approvalFlow.ApprovalPath)
                freeze_path = (Get-RelativePathFromRoot -Root $repositoryRoot -Path $approvalFlow.FreezePath)
            })

        $bindingFlow = & (Get-BaselineBindingFlowCommand) -FreezePath $approvalFlow.FreezePath -RepositoryRoot $repositoryRoot -OutputRoot $packagePaths.BaselineRoot -BindingId "baseline-binding-r6-supervised-milestone-autocycle-pilot-proof-001" -BaselineId "baseline-r6-supervised-milestone-autocycle-pilot-proof-001" -BoundAt (Get-Date).ToUniversalTime()
        Write-StepLog -PackagePaths $packagePaths -Message ("Baseline binding recorded at {0}" -f (Get-RelativePathFromRoot -Root $repositoryRoot -Path $bindingFlow.BindingPath))
        Write-EventLog -PackagePaths $packagePaths -EventType "baseline_bound" -Data ([pscustomobject]@{
                binding_path = (Get-RelativePathFromRoot -Root $repositoryRoot -Path $bindingFlow.BindingPath)
                baseline_id = $bindingFlow.BaselineId
            })

        $freezeDocument = Get-JsonDocument -Path $approvalFlow.FreezePath -Label "Replay freeze"
        $frozenTasks = @($freezeDocument.frozen_task_set)
        if ($frozenTasks.Count -eq 0) {
            throw "Proof review replay requires at least one frozen task."
        }

        $scopeStatements = Get-ExactScopeStatements -CycleId $CycleId -ProposalIntakeRelativeRef (Get-RelativePathFromRoot -Root $repositoryRoot -Path $proposalIntakeFullPath) -FrozenTaskIds @($frozenTasks | ForEach-Object { $_.task_id })

        $dispatchPaths = @()
        $runLedgerPaths = @()
        $executionEvidencePaths = @()
        $qaObservationPaths = @()

        foreach ($frozenTask in $frozenTasks) {
            $taskId = $frozenTask.task_id
            Write-StepLog -PackagePaths $packagePaths -Message ("Preparing governed dispatch for frozen task {0}" -f $taskId)

            $dispatchFlow = & (Get-DispatchFlowCommand) -BindingPath $bindingFlow.BindingPath -TaskId $taskId -AllowedScope (New-AllowedScope -FrozenTask $frozenTask -PackageRootRelative $packageRootRelative) -TargetBranch $replaySourceBranch -ExpectedOutputs (New-ExpectedOutputs -PackageRootRelative $packageRootRelative -TaskId $taskId) -RefusalConditions (New-RefusalConditions) -OutputRoot $packagePaths.DispatchRoot -DispatchId ("dispatch-{0}" -f $taskId) -LedgerId ("run-ledger-{0}" -f $taskId) -Notes ("Governed replay dispatch for frozen task {0}." -f $taskId) -LedgerNotes ("Replay run ledger initialized for frozen task {0}." -f $taskId)
            & (Get-RunLedgerStatusCommand) -LedgerPath $dispatchFlow.RunLedgerPath -Status "in_progress" -ResultSummary ("Replay dispatch for task {0} entered in_progress." -f $taskId) -Notes ("Replay executor started for frozen task {0}." -f $taskId) -OccurredAt (Get-Date).ToUniversalTime() | Out-Null
            & (Get-RunLedgerStatusCommand) -LedgerPath $dispatchFlow.RunLedgerPath -Status "completed" -ResultSummary ("Replay dispatch for task {0} completed with governed outputs." -f $taskId) -Notes ("Replay executor completed for frozen task {0}." -f $taskId) -OccurredAt (Get-Date).ToUniversalTime() | Out-Null

            $executionEvidenceInputs = New-ExecutionEvidenceInputs -PackagePaths $packagePaths -TaskId $taskId -RepositoryRoot $repositoryRoot
            $evidenceFlow = & (Get-ExecutionEvidenceFlowCommand) -DispatchPath $dispatchFlow.DispatchPath -LedgerPath $dispatchFlow.RunLedgerPath -ChangedFiles $executionEvidenceInputs.ChangedFiles -ProducedArtifacts $executionEvidenceInputs.ProducedArtifacts -TestOutputs $executionEvidenceInputs.TestOutputs -EvidenceRefs $executionEvidenceInputs.EvidenceRefs -OutputRoot $packagePaths.EvidenceRoot -EvidenceBundleId ("execution-evidence-{0}" -f $taskId) -Notes ("Replay execution evidence bundle for frozen task {0}." -f $taskId)

            $qaInput = New-QAEvidenceInput -PackagePaths $packagePaths -TaskId $taskId -RepositoryRoot $repositoryRoot
            $qaFlow = & (Get-QAObservationFlowCommand) -EvidenceBundlePath $evidenceFlow.EvidenceBundlePath -Status "passed" -Findings @($qaInput.Finding) -EvidenceRefs @($qaInput.EvidenceRef) -OutputRoot $packagePaths.QARoot -QAObservationId ("qa-observation-{0}" -f $taskId) -AggregationId "qa-aggregation-r6-supervised-milestone-autocycle-pilot-proof-001" -Notes ("Replay QA observation for frozen task {0}." -f $taskId) -AggregationNotes "Replay milestone QA aggregation across the exact frozen task set."

            $dispatchPaths += $dispatchFlow.DispatchPath
            $runLedgerPaths += $dispatchFlow.RunLedgerPath
            $executionEvidencePaths += $evidenceFlow.EvidenceBundlePath
            $qaObservationPaths += $qaFlow.QAObservationPath

            Write-EventLog -PackagePaths $packagePaths -EventType "task_replayed" -Data ([pscustomobject]@{
                    task_id = $taskId
                    dispatch_path = (Get-RelativePathFromRoot -Root $repositoryRoot -Path $dispatchFlow.DispatchPath)
                    run_ledger_path = (Get-RelativePathFromRoot -Root $repositoryRoot -Path $dispatchFlow.RunLedgerPath)
                    execution_evidence_path = (Get-RelativePathFromRoot -Root $repositoryRoot -Path $evidenceFlow.EvidenceBundlePath)
                    qa_observation_path = (Get-RelativePathFromRoot -Root $repositoryRoot -Path $qaFlow.QAObservationPath)
                })
        }

        $qaAggregationPath = Resolve-ExistingPath -PathValue (Join-Path $packagePaths.QARoot "qa_aggregations\qa-aggregation-r6-supervised-milestone-autocycle-pilot-proof-001.json") -Label "Replay QA aggregation"
        $summaryFlow = & (Get-SummaryFlowCommand) -QAAggregationPath $qaAggregationPath -OutputRoot $packagePaths.SummaryRoot -SummaryId "summary-r6-supervised-milestone-autocycle-pilot-proof-001" -DecisionPacketId "decision-packet-r6-supervised-milestone-autocycle-pilot-proof-001" -Notes "Replay milestone summary from the exact governed QA aggregation only." -DecisionPacketNotes "Replay operator decision packet remains advisory only."
        Write-StepLog -PackagePaths $packagePaths -Message ("Summary and decision packet recorded at {0} and {1}" -f (Get-RelativePathFromRoot -Root $repositoryRoot -Path $summaryFlow.SummaryPath), (Get-RelativePathFromRoot -Root $repositoryRoot -Path $summaryFlow.DecisionPacketPath))

        $proofRefs = [pscustomobject]@{
            proposal_ref = $proposalFlow.ProposalPath
            approval_ref = $approvalFlow.ApprovalPath
            freeze_ref = $approvalFlow.FreezePath
            baseline_binding_ref = $bindingFlow.BindingPath
            dispatch_refs = @($dispatchPaths)
            run_ledger_refs = @($runLedgerPaths)
            execution_evidence_refs = @($executionEvidencePaths)
            qa_observation_refs = @($qaObservationPaths)
            qa_aggregation_ref = $qaAggregationPath
        }

        $nonClaims = Get-ProofReviewNonClaims
        Write-JsonDocument -Path $packagePaths.NonClaimsPath -Document @($nonClaims)

        $summaryDocument = Get-JsonDocument -Path $summaryFlow.SummaryPath -Label "Replay summary"
        $decisionPacketDocument = Get-JsonDocument -Path $summaryFlow.DecisionPacketPath -Label "Replay decision packet"
        $recommendation = Assert-NonEmptyString -Value $decisionPacketDocument.recommendation -Context "Replay decision packet.recommendation"
        Assert-AllowedValue -Value $recommendation -AllowedValues @($foundation.allowed_summary_recommendations) -Context "Replay decision packet.recommendation"
        if (-not (Assert-BooleanValue -Value $decisionPacketDocument.recommendation_is_advisory -Context "Replay decision packet.recommendation_is_advisory")) {
            throw "Replay decision packet.recommendation_is_advisory must remain true."
        }

        $replayProofId = "replay-proof-r6-supervised-milestone-autocycle-pilot-proof-001"
        $closeoutPacketId = "closeout-packet-r6-supervised-milestone-autocycle-pilot-proof-001"
        $replayProofDirectory = Join-Path $packagePaths.CloseoutRoot "replay_proofs"
        $closeoutPacketDirectory = Join-Path $packagePaths.CloseoutRoot "closeout_packets"
        if (-not (Test-Path -LiteralPath $replayProofDirectory)) {
            New-Item -ItemType Directory -Path $replayProofDirectory -Force | Out-Null
        }
        if (-not (Test-Path -LiteralPath $closeoutPacketDirectory)) {
            New-Item -ItemType Directory -Path $closeoutPacketDirectory -Force | Out-Null
        }

        $replayProofPath = Join-Path $replayProofDirectory ("{0}.json" -f $replayProofId)
        $closeoutPacketPath = Join-Path $closeoutPacketDirectory ("{0}.json" -f $closeoutPacketId)
        if (Test-Path -LiteralPath $replayProofPath) {
            throw "Replay proof path '$replayProofPath' already exists."
        }
        if (Test-Path -LiteralPath $closeoutPacketPath) {
            throw "Closeout packet path '$closeoutPacketPath' already exists."
        }

        $replayProof = [pscustomobject]@{
            contract_version = $foundation.contract_version
            record_type = $foundation.replay_proof_record_type
            replay_proof_id = $replayProofId
            cycle_id = $CycleId
            summary_ref = Get-RelativeReference -BaseDirectory (Split-Path -Parent $replayProofPath) -TargetPath $summaryFlow.SummaryPath
            summary_id = (Assert-NonEmptyString -Value $summaryDocument.summary_id -Context "Replay summary.summary_id")
            decision_packet_ref = Get-RelativeReference -BaseDirectory (Split-Path -Parent $replayProofPath) -TargetPath $summaryFlow.DecisionPacketPath
            decision_packet_id = (Assert-NonEmptyString -Value $decisionPacketDocument.decision_packet_id -Context "Replay decision packet.decision_packet_id")
            recommendation = $recommendation
            operator_decision_state = "advisory_only_not_executed"
            proof_refs = [pscustomobject]@{
                proposal_ref = Get-RelativeReference -BaseDirectory (Split-Path -Parent $replayProofPath) -TargetPath $proposalFlow.ProposalPath
                approval_ref = Get-RelativeReference -BaseDirectory (Split-Path -Parent $replayProofPath) -TargetPath $approvalFlow.ApprovalPath
                freeze_ref = Get-RelativeReference -BaseDirectory (Split-Path -Parent $replayProofPath) -TargetPath $approvalFlow.FreezePath
                baseline_binding_ref = Get-RelativeReference -BaseDirectory (Split-Path -Parent $replayProofPath) -TargetPath $bindingFlow.BindingPath
                dispatch_refs = @($dispatchPaths | ForEach-Object { Get-RelativeReference -BaseDirectory (Split-Path -Parent $replayProofPath) -TargetPath $_ })
                run_ledger_refs = @($runLedgerPaths | ForEach-Object { Get-RelativeReference -BaseDirectory (Split-Path -Parent $replayProofPath) -TargetPath $_ })
                execution_evidence_refs = @($executionEvidencePaths | ForEach-Object { Get-RelativeReference -BaseDirectory (Split-Path -Parent $replayProofPath) -TargetPath $_ })
                qa_observation_refs = @($qaObservationPaths | ForEach-Object { Get-RelativeReference -BaseDirectory (Split-Path -Parent $replayProofPath) -TargetPath $_ })
                qa_aggregation_ref = Get-RelativeReference -BaseDirectory (Split-Path -Parent $replayProofPath) -TargetPath $qaAggregationPath
            }
            replay_scope = $scopeStatements.ReplayScope
            replay_source = [pscustomobject]@{
                repository_root = $repositoryRoot
                branch = $replaySourceBranch
                head_commit = $replaySourceHead
            }
            boundary_statement = $scopeStatements.BoundaryStatement
            non_claims = @($nonClaims)
            notes = "Replay proof assembled from the exact R6 supervised pilot scenario only."
        }
        Write-JsonDocument -Path $replayProofPath -Document $replayProof

        $closeoutPacket = [pscustomobject]@{
            contract_version = $foundation.contract_version
            record_type = $foundation.closeout_packet_record_type
            closeout_packet_id = $closeoutPacketId
            cycle_id = $CycleId
            replay_proof_ref = Get-RelativeReference -BaseDirectory (Split-Path -Parent $closeoutPacketPath) -TargetPath $replayProofPath
            replay_proof_id = $replayProofId
            summary_ref = Get-RelativeReference -BaseDirectory (Split-Path -Parent $closeoutPacketPath) -TargetPath $summaryFlow.SummaryPath
            summary_id = (Assert-NonEmptyString -Value $summaryDocument.summary_id -Context "Replay summary.summary_id")
            decision_packet_ref = Get-RelativeReference -BaseDirectory (Split-Path -Parent $closeoutPacketPath) -TargetPath $summaryFlow.DecisionPacketPath
            decision_packet_id = (Assert-NonEmptyString -Value $decisionPacketDocument.decision_packet_id -Context "Replay decision packet.decision_packet_id")
            operator_decision_state = "advisory_only_not_executed"
            closeout_scope = $scopeStatements.CloseoutScope
            proved_scope = $scopeStatements.ProvedScope
            unproved_scope = $scopeStatements.UnprovedScope
            out_of_scope = $scopeStatements.OutOfScope
            non_claims = @($nonClaims)
            notes = "Closeout packet assembled from the exact R6 supervised pilot replay only."
        }
        Write-JsonDocument -Path $closeoutPacketPath -Document $closeoutPacket
        $closeoutFlow = [pscustomobject]@{
            ReplayProofPath = $replayProofPath
            CloseoutPacketPath = $closeoutPacketPath
            ReplayProofId = $replayProofId
            CloseoutPacketId = $closeoutPacketId
            CycleId = $CycleId
        }
        Write-StepLog -PackagePaths $packagePaths -Message ("Replay proof and closeout packet recorded at {0} and {1}" -f (Get-RelativePathFromRoot -Root $repositoryRoot -Path $closeoutFlow.ReplayProofPath), (Get-RelativePathFromRoot -Root $repositoryRoot -Path $closeoutFlow.CloseoutPacketPath))

        $selectionScope = [pscustomobject]@{
            scenario_id = $ScenarioId
            cycle_id = $CycleId
            scope_statement = $scopeStatements.ReplayScope
            closeout_scope_statement = $scopeStatements.CloseoutScope
            input_refs = [pscustomobject]@{
                proposal_intake_ref = Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath $proposalIntakeFullPath
                request_brief_ref = Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath (Join-Path (Split-Path -Parent $proposalIntakeFullPath) "request_brief.valid.json")
                milestone_ref = Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath (Join-Path (Split-Path -Parent $proposalIntakeFullPath) "governed_work_object.milestone.valid.json")
            }
            frozen_task_ids = @($frozenTasks | ForEach-Object { $_.task_id })
            dispatched_task_ids = @($frozenTasks | ForEach-Object { $_.task_id })
            replay_chain = @(Get-AllowedReplayChain)
            notes = "Selection scope records the exact replayed R6 pilot cycle and preserves advisory-only operator decision state."
        }
        Write-JsonDocument -Path $packagePaths.SelectionScopePath -Document $selectionScope

        $replaySource = [pscustomobject]@{
            scenario_id = $ScenarioId
            cycle_id = $CycleId
            repository_root_relative = "."
            branch = $replaySourceBranch
            source_head_commit = $replaySourceHead
            source_tree_id = $replaySourceTree
            generated_by_script = "tools/new_r6_supervised_milestone_autocycle_proof_review.ps1"
            generated_at_utc = $generatedAtUtc
        }
        Write-JsonDocument -Path $packagePaths.ReplaySourcePath -Document $replaySource

        $artifactRefs = [pscustomobject]@{
            proposal_intake_ref = Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath $proposalIntakeFullPath
            request_brief_ref = Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath (Join-Path (Split-Path -Parent $proposalIntakeFullPath) "request_brief.valid.json")
            milestone_ref = Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath (Join-Path (Split-Path -Parent $proposalIntakeFullPath) "governed_work_object.milestone.valid.json")
            proposal_ref = Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath $proposalFlow.ProposalPath
            approval_ref = Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath $approvalFlow.ApprovalPath
            freeze_ref = Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath $approvalFlow.FreezePath
            baseline_binding_ref = Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath $bindingFlow.BindingPath
            dispatch_refs = @($dispatchPaths | ForEach-Object { Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath $_ })
            run_ledger_refs = @($runLedgerPaths | ForEach-Object { Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath $_ })
            execution_evidence_refs = @($executionEvidencePaths | ForEach-Object { Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath $_ })
            qa_observation_refs = @($qaObservationPaths | ForEach-Object { Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath $_ })
            qa_aggregation_ref = Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath $qaAggregationPath
            summary_ref = Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath $summaryFlow.SummaryPath
            decision_packet_ref = Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath $summaryFlow.DecisionPacketPath
            replay_proof_ref = Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath $closeoutFlow.ReplayProofPath
            closeout_packet_ref = Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath $closeoutFlow.CloseoutPacketPath
        }
        Write-JsonDocument -Path $packagePaths.ArtifactRefsPath -Document $artifactRefs

        $replayCommand = "powershell -ExecutionPolicy Bypass -File tools\new_r6_supervised_milestone_autocycle_proof_review.ps1 -OutputRoot {0}" -f $packageRootRelative
        $validateCommand = "powershell -ExecutionPolicy Bypass -File tests\test_r6_supervised_milestone_autocycle_proof_review.ps1"
        Write-Utf8File -Path $packagePaths.CommandsPath -Value (@(
                $replayCommand,
                $validateCommand
            ) -join [Environment]::NewLine)

        $summaryRelativePath = Get-RelativePathFromRoot -Root $repositoryRoot -Path $summaryFlow.SummaryPath
        $decisionPacketRelativePath = Get-RelativePathFromRoot -Root $repositoryRoot -Path $summaryFlow.DecisionPacketPath
        $replayProofRelativePath = Get-RelativePathFromRoot -Root $repositoryRoot -Path $closeoutFlow.ReplayProofPath
        $closeoutPacketRelativePath = Get-RelativePathFromRoot -Root $repositoryRoot -Path $closeoutFlow.CloseoutPacketPath
        $rawLogRelativePaths = @(
            (Get-RelativePathFromRoot -Root $repositoryRoot -Path $packagePaths.StepLogPath)
            (Get-RelativePathFromRoot -Root $repositoryRoot -Path $packagePaths.EventLogPath)
        )

        $replaySummaryLines = @(
            "# R6 Supervised Milestone Autocycle Pilot Replay Summary",
            "",
            "## Exact Replay Scope",
            $scopeStatements.ReplayScope,
            "",
            "## Replay Source Metadata",
            ("- Branch: {0}" -f $replaySourceBranch),
            ("- Replay source head: {0}" -f $replaySourceHead),
            ("- Replay source tree: {0}" -f $replaySourceTree),
            ("- Replay command: {0}" -f $replayCommand),
            "",
            "## Authoritative Artifact Lineage",
            ("- Proposal intake: {0}" -f (Get-RelativePathFromRoot -Root $repositoryRoot -Path $proposalIntakeFullPath)),
            ("- Proposal: {0}" -f (Get-RelativePathFromRoot -Root $repositoryRoot -Path $proposalFlow.ProposalPath)),
            ("- Approval: {0}" -f (Get-RelativePathFromRoot -Root $repositoryRoot -Path $approvalFlow.ApprovalPath)),
            ("- Freeze: {0}" -f (Get-RelativePathFromRoot -Root $repositoryRoot -Path $approvalFlow.FreezePath)),
            ("- Baseline binding: {0}" -f (Get-RelativePathFromRoot -Root $repositoryRoot -Path $bindingFlow.BindingPath)),
            ("- Summary: {0}" -f $summaryRelativePath),
            ("- Decision packet: {0}" -f $decisionPacketRelativePath),
            ("- Replay proof: {0}" -f $replayProofRelativePath),
            ("- Closeout packet: {0}" -f $closeoutPacketRelativePath),
            "",
            "## Raw Logs",
            ("- {0}" -f $rawLogRelativePaths[0]),
            ("- {0}" -f $rawLogRelativePaths[1]),
            "",
            "## Explicit Non-Claims",
            @($nonClaims | ForEach-Object { "- $_" }),
            "",
            "## Advisory Operator Decision State",
            "- The operator can choose `accept`, `rework`, or `stop`, but no operator choice was executed in this replay."
        )
        Write-Utf8File -Path $packagePaths.ReplaySummaryPath -Value ($replaySummaryLines -join [Environment]::NewLine)

        $closeoutReviewLines = @(
            "# R6 Supervised Milestone Autocycle Pilot Closeout Review",
            "",
            "## Exact Closeout Scope",
            $scopeStatements.CloseoutScope,
            "",
            "## Proved Scope",
            $scopeStatements.ProvedScope,
            "",
            "## Unproved Scope",
            $scopeStatements.UnprovedScope,
            "",
            "## Out Of Scope",
            $scopeStatements.OutOfScope,
            "",
            "## Advisory Operator Decision State",
            "- The advisory-only operator decision packet remains unexecuted in this replay.",
            "",
            "## Explicit Non-Claims",
            @($nonClaims | ForEach-Object { "- $_" })
        )
        Write-Utf8File -Path $packagePaths.CloseoutReviewPath -Value ($closeoutReviewLines -join [Environment]::NewLine)

        $manifest = [pscustomobject]@{
            package_version = $foundation.contract_version
            package_type = Get-ProofReviewPackageType
            scenario_id = $ScenarioId
            cycle_id = $CycleId
            operator_decision_state = "advisory_only_not_executed"
            proposal_intake_ref = Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath $proposalIntakeFullPath
            summary_ref = Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath $summaryFlow.SummaryPath
            decision_packet_ref = Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath $summaryFlow.DecisionPacketPath
            replay_proof_ref = Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath $closeoutFlow.ReplayProofPath
            closeout_packet_ref = Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath $closeoutFlow.CloseoutPacketPath
            selection_scope_ref = Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath $packagePaths.SelectionScopePath
            replay_source_ref = Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath $packagePaths.ReplaySourcePath
            replay_commands_ref = Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath $packagePaths.CommandsPath
            authoritative_artifact_refs_ref = Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath $packagePaths.ArtifactRefsPath
            non_claims_ref = Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath $packagePaths.NonClaimsPath
            replay_summary_ref = Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath $packagePaths.ReplaySummaryPath
            closeout_review_ref = Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath $packagePaths.CloseoutReviewPath
            raw_log_refs = @(
                (Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath $packagePaths.StepLogPath)
                (Get-RelativeReference -BaseDirectory $packagePaths.PackageRoot -TargetPath $packagePaths.EventLogPath)
            )
            notes = "Committed proof-review package for the exact R6 supervised milestone autocycle replay from intake to advisory-only operator decision."
        }
        Write-JsonDocument -Path $packagePaths.ManifestPath -Document $manifest

        $validation = Test-MilestoneAutocycleProofReviewPackage -PackageRoot $packagePaths.PackageRoot
        Write-StepLog -PackagePaths $packagePaths -Message "Proof review package validated successfully."
        Write-EventLog -PackagePaths $packagePaths -EventType "replay_completed" -Data ([pscustomobject]@{
                package_root = $packageRootRelative
                replay_summary_ref = (Get-RelativePathFromRoot -Root $repositoryRoot -Path $packagePaths.ReplaySummaryPath)
                closeout_review_ref = (Get-RelativePathFromRoot -Root $repositoryRoot -Path $packagePaths.CloseoutReviewPath)
            })

        $success = $true
        return [pscustomobject]@{
            PackageRoot = $validation.PackageRoot
            ReplaySummaryPath = $validation.ReplaySummaryPath
            CloseoutReviewPath = $validation.CloseoutReviewPath
            ManifestPath = $validation.ManifestPath
            SummaryPath = $validation.SummaryPath
            DecisionPacketPath = $validation.DecisionPacketPath
            ReplayProofPath = $validation.ReplayProofPath
            CloseoutPacketPath = $validation.CloseoutPacketPath
            RawLogPaths = $validation.RawLogPaths
            ScenarioId = $validation.ScenarioId
            CycleId = $validation.CycleId
            ReplayCommand = $replayCommand
            TestCommand = $validateCommand
        }
    }
    finally {
        Remove-TemporaryGitExcludePattern -RepositoryRoot $repositoryRoot
        if (-not $success -and (Test-Path -LiteralPath $packagePaths.PackageRoot)) {
            Remove-Item -LiteralPath $packagePaths.PackageRoot -Recurse -Force
        }
    }
}

Export-ModuleMember -Function Test-MilestoneAutocycleProofReviewPackage, Invoke-MilestoneAutocycleProofReviewFlow
