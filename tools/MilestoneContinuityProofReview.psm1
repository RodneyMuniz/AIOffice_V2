Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
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
    Write-Utf8File -Path $Path -Value $json
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

function Assert-RequiredObjectFields {
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        [string[]]$FieldNames,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-ObjectValue -Value $Object -Context $Context | Out-Null
    foreach ($fieldName in $FieldNames) {
        Get-RequiredProperty -Object $Object -Name $fieldName -Context $Context | Out-Null
    }
}

function Assert-MatchingValue {
    param(
        [Parameter(Mandatory = $true)]
        $Expected,
        [Parameter(Mandatory = $true)]
        $Actual,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Expected -ne $Actual) {
        throw "$Context must match. Expected '$Expected' but found '$Actual'."
    }
}

function Get-UtcTimestamp {
    param(
        [datetime]$DateTime = (Get-Date).ToUniversalTime()
    )

    return $DateTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
}

function Get-RelativeReference {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory,
        [Parameter(Mandatory = $true)]
        [string]$TargetPath
    )

    $resolvedBaseDirectory = if (Test-Path -LiteralPath $BaseDirectory) {
        (Resolve-Path -LiteralPath $BaseDirectory).Path
    }
    else {
        [System.IO.Path]::GetFullPath($BaseDirectory)
    }

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

function Get-GitTrimmedValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $output = & git -C $RepositoryRoot @Arguments 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "$Context failed."
    }

    return ([string]::Join([Environment]::NewLine, @($output))).Trim()
}

function Get-GitBranchName {
    param([Parameter(Mandatory = $true)][string]$RepositoryRoot)
    return Get-GitTrimmedValue -RepositoryRoot $RepositoryRoot -Arguments @("branch", "--show-current") -Context "Git branch lookup"
}

function Get-GitHeadCommit {
    param([Parameter(Mandatory = $true)][string]$RepositoryRoot)
    return Get-GitTrimmedValue -RepositoryRoot $RepositoryRoot -Arguments @("rev-parse", "HEAD") -Context "Git HEAD lookup"
}

function Get-GitTreeId {
    param([Parameter(Mandatory = $true)][string]$RepositoryRoot)
    return Get-GitTrimmedValue -RepositoryRoot $RepositoryRoot -Arguments @("rev-parse", "HEAD^{tree}") -Context "Git tree lookup"
}

function Get-MilestoneContinuityFoundationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_continuity\foundation.contract.json") -Label "Milestone continuity foundation contract"
}

function Get-ProofReviewPacketContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_continuity\proof_review_packet.contract.json") -Label "Milestone continuity proof-review packet contract"
}

function Get-CloseoutPacketContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\milestone_continuity\closeout_packet.contract.json") -Label "Milestone continuity closeout packet contract"
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

    $module = Import-Module $ModulePath -Force -PassThru -ErrorAction Stop
    $command = $module.ExportedCommands[$CommandName]
    if ($null -eq $command) {
        throw "Proof review requires dependency command '$CommandName' from module '$DependencyLabel'."
    }

    $script:commandCache[$cacheKey] = $command
    return $command
}

function Get-FaultEventValidatorCommand { return Get-RequiredDependencyCommand -ModulePath (Join-Path $PSScriptRoot "FaultManagement.psm1") -DependencyLabel "FaultManagement" -CommandName "Test-FaultManagementEventContract" }
function Get-CheckpointValidatorCommand { return Get-RequiredDependencyCommand -ModulePath (Join-Path $PSScriptRoot "MilestoneContinuity.psm1") -DependencyLabel "MilestoneContinuity" -CommandName "Test-MilestoneContinuityCheckpointContract" }
function Get-HandoffValidatorCommand { return Get-RequiredDependencyCommand -ModulePath (Join-Path $PSScriptRoot "MilestoneContinuity.psm1") -DependencyLabel "MilestoneContinuity" -CommandName "Test-MilestoneContinuityHandoffPacketContract" }
function Get-ResumeRequestValidatorCommand { return Get-RequiredDependencyCommand -ModulePath (Join-Path $PSScriptRoot "MilestoneContinuityResume.psm1") -DependencyLabel "MilestoneContinuityResume" -CommandName "Test-MilestoneContinuityResumeRequestContract" }
function Get-ResumeResultValidatorCommand { return Get-RequiredDependencyCommand -ModulePath (Join-Path $PSScriptRoot "MilestoneContinuityResume.psm1") -DependencyLabel "MilestoneContinuityResume" -CommandName "Test-MilestoneContinuityResumeResultContract" }
function Get-LedgerValidatorCommand { return Get-RequiredDependencyCommand -ModulePath (Join-Path $PSScriptRoot "MilestoneContinuityLedger.psm1") -DependencyLabel "MilestoneContinuityLedger" -CommandName "Test-MilestoneContinuityLedgerContract" }
function Get-RollbackPlanRequestValidatorCommand { return Get-RequiredDependencyCommand -ModulePath (Join-Path $PSScriptRoot "MilestoneRollbackPlan.psm1") -DependencyLabel "MilestoneRollbackPlan" -CommandName "Test-MilestoneRollbackPlanRequestContract" }
function Get-RollbackPlanValidatorCommand { return Get-RequiredDependencyCommand -ModulePath (Join-Path $PSScriptRoot "MilestoneRollbackPlan.psm1") -DependencyLabel "MilestoneRollbackPlan" -CommandName "Test-MilestoneRollbackPlanContract" }
function Get-RollbackAuthorizationValidatorCommand { return Get-RequiredDependencyCommand -ModulePath (Join-Path $PSScriptRoot "MilestoneRollbackDrill.psm1") -DependencyLabel "MilestoneRollbackDrill" -CommandName "Test-MilestoneRollbackDrillAuthorizationContract" }
function Get-RollbackDrillResultValidatorCommand { return Get-RequiredDependencyCommand -ModulePath (Join-Path $PSScriptRoot "MilestoneRollbackDrill.psm1") -DependencyLabel "MilestoneRollbackDrill" -CommandName "Test-MilestoneRollbackDrillResultContract" }
function Get-ReviewSummaryValidatorCommand { return Get-RequiredDependencyCommand -ModulePath (Join-Path $PSScriptRoot "MilestoneContinuityReview.psm1") -DependencyLabel "MilestoneContinuityReview" -CommandName "Test-MilestoneContinuityReviewSummaryContract" }
function Get-OperatorPacketValidatorCommand { return Get-RequiredDependencyCommand -ModulePath (Join-Path $PSScriptRoot "MilestoneContinuityReview.psm1") -DependencyLabel "MilestoneContinuityReview" -CommandName "Test-MilestoneContinuityOperatorPacketContract" }

function Get-R7InputPaths {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    return [pscustomobject]@{
        FaultEventPath = Join-Path $RepositoryRoot "state\fixtures\valid\fault_management\fault_event.valid.json"
        CheckpointPath = Join-Path $RepositoryRoot "state\fixtures\valid\milestone_continuity\continuity_checkpoint.valid.json"
        HandoffPath = Join-Path $RepositoryRoot "state\fixtures\valid\milestone_continuity\continuity_handoff_packet.valid.json"
        ResumeRequestPath = Join-Path $RepositoryRoot "state\fixtures\valid\milestone_continuity\resume_from_fault_request.valid.json"
        ResumeResultPath = Join-Path $RepositoryRoot "state\fixtures\valid\milestone_continuity\resume_from_fault_result.valid.json"
        LedgerPath = Join-Path $RepositoryRoot "state\fixtures\valid\milestone_continuity\continuity_ledger.valid.json"
        RollbackPlanRequestPath = Join-Path $RepositoryRoot "state\fixtures\valid\milestone_continuity\rollback_plan_request.valid.json"
        RollbackPlanPath = Join-Path $RepositoryRoot "state\fixtures\valid\milestone_continuity\rollback_plan.valid.json"
        RollbackDrillAuthorizationPath = Join-Path $RepositoryRoot "state\fixtures\valid\milestone_continuity\rollback_drill_authorization.valid.json"
        RollbackDrillResultPath = Join-Path $RepositoryRoot "state\fixtures\valid\milestone_continuity\rollback_drill_result.valid.json"
        ReviewSummaryPath = Join-Path $RepositoryRoot "state\fixtures\valid\milestone_continuity\review_summaries\review-summary-r7-008-001.json"
        OperatorPacketPath = Join-Path $RepositoryRoot "state\fixtures\valid\milestone_continuity\operator_packets\operator-packet-r7-008-001.json"
    }
}

function Get-R7ReplayCommandDefinitions {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    return @(
        [pscustomobject]@{ CommandId = "test-fault-event"; RelativeScript = "tests/test_fault_management_event.ps1"; LogName = "test_fault_management_event.log" },
        [pscustomobject]@{ CommandId = "test-continuity-artifacts"; RelativeScript = "tests/test_milestone_continuity_artifacts.ps1"; LogName = "test_milestone_continuity_artifacts.log" },
        [pscustomobject]@{ CommandId = "test-resume-from-fault"; RelativeScript = "tests/test_milestone_continuity_resume_from_fault.ps1"; LogName = "test_milestone_continuity_resume_from_fault.log" },
        [pscustomobject]@{ CommandId = "test-continuity-ledger"; RelativeScript = "tests/test_milestone_continuity_ledger.ps1"; LogName = "test_milestone_continuity_ledger.log" },
        [pscustomobject]@{ CommandId = "test-rollback-plan"; RelativeScript = "tests/test_milestone_rollback_plan.ps1"; LogName = "test_milestone_rollback_plan.log" },
        [pscustomobject]@{ CommandId = "test-rollback-drill"; RelativeScript = "tests/test_milestone_rollback_drill.ps1"; LogName = "test_milestone_rollback_drill.log" },
        [pscustomobject]@{ CommandId = "test-continuity-review"; RelativeScript = "tests/test_milestone_continuity_review.ps1"; LogName = "test_milestone_continuity_review.log" }
    )
}

function Write-StepLog {
    param(
        [Parameter(Mandatory = $true)]
        [string]$StepLogPath,
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Append-Utf8File -Path $StepLogPath -Value ("[{0}] {1}" -f (Get-UtcTimestamp), $Message)
}

function Write-EventLog {
    param(
        [Parameter(Mandatory = $true)]
        [string]$EventLogPath,
        [Parameter(Mandatory = $true)]
        [string]$EventType,
        [Parameter(Mandatory = $true)]
        $Data
    )

    $eventDocument = [pscustomobject]@{
        recorded_at = Get-UtcTimestamp
        event_type = $EventType
        data = $Data
    }

    Append-Utf8File -Path $EventLogPath -Value ($eventDocument | ConvertTo-Json -Depth 20 -Compress)
}

function Invoke-LoggedPowerShellScript {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string]$RelativeScript,
        [Parameter(Mandatory = $true)]
        [string]$LogPath,
        [Parameter(Mandatory = $true)]
        [string]$CommandId,
        [Parameter(Mandatory = $true)]
        [string]$StepLogPath,
        [Parameter(Mandatory = $true)]
        [string]$EventLogPath
    )

    $scriptPath = Resolve-ExistingPath -PathValue (Join-Path $RepositoryRoot $RelativeScript) -Label "Replay script"
    $commandDisplay = "powershell -NoProfile -ExecutionPolicy Bypass -File {0}" -f $RelativeScript.Replace("/", "\")

    Write-StepLog -StepLogPath $StepLogPath -Message ("Running {0}" -f $commandDisplay)
    $outputLines = @(& powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath *>&1)
    $exitCode = $LASTEXITCODE
    Write-Utf8File -Path $LogPath -Value ([string]::Join([Environment]::NewLine, @($outputLines)))

    $resultSummary = if ($outputLines.Count -gt 0) { [string]$outputLines[-1] } else { "No output captured." }
    Write-EventLog -EventLogPath $EventLogPath -EventType "command_completed" -Data ([pscustomobject]@{
            command_id = $CommandId
            command = $commandDisplay
            exit_code = $exitCode
            log_ref = $LogPath
        })

    if ($exitCode -ne 0) {
        throw "Replay command '$commandDisplay' failed with exit code $exitCode."
    }

    return [pscustomobject]@{
        command_id = $CommandId
        command = $commandDisplay
        log_ref = $LogPath
        exit_code = 0
        status = "passed"
        result_summary = $resultSummary
    }
}

function Get-R7CloseoutNonClaims {
    $foundation = Get-MilestoneContinuityFoundationContract
    return @($foundation.allowed_closeout_non_claims)
}

function Test-RequiredNonClaims {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$NonClaims,
        [Parameter(Mandatory = $true)]
        [string[]]$Expected,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($expectedClaim in $Expected) {
        if ($NonClaims -notcontains $expectedClaim) {
            throw "$Context is missing required non-claim '$expectedClaim'."
        }
    }
}

function Assert-NoProhibitedClaimFragments {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$TextValues,
        [Parameter(Mandatory = $true)]
        [string[]]$Fragments,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($textValue in $TextValues) {
        if ([string]::IsNullOrWhiteSpace($textValue)) {
            continue
        }

        foreach ($fragment in $Fragments) {
            if ($textValue.ToLowerInvariant().Contains($fragment.ToLowerInvariant())) {
                throw "$Context must not contain prohibited claim fragment '$fragment'."
            }
        }
    }
}

function Normalize-CommandText {
    param(
        [Parameter(Mandatory = $true)]
        [string]$CommandText
    )

    $normalized = Assert-NonEmptyString -Value $CommandText -Context "Command text"
    $normalized = $normalized -replace "\s+-NoProfile(?=\s|$)", ""
    $normalized = $normalized.Replace("/", "\")
    $normalized = $normalized -replace "\s+", " "
    return $normalized.Trim().ToLowerInvariant()
}

function Get-NonEmptyFileLines {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return @(
        Get-Content -LiteralPath $Path | ForEach-Object { [string]$_ } | Where-Object {
            -not [string]::IsNullOrWhiteSpace($_)
        }
    )
}

function Test-ProofReviewSupportManifest {
    param(
        [Parameter(Mandatory = $true)]
        $ProofReviewManifest,
        [Parameter(Mandatory = $true)]
        [string]$PackageRoot,
        [Parameter(Mandatory = $true)]
        $ReplaySource
    )

    $contract = Get-ProofReviewPacketContract
    if (-not (Test-HasProperty -Object $ProofReviewManifest -Name "support_manifest_ref")) {
        return $null
    }

    $supportManifestPath = Resolve-ExistingPath -PathValue (Assert-NonEmptyString -Value $ProofReviewManifest.support_manifest_ref -Context "Proof-review manifest.support_manifest_ref") -Label "Proof-review support manifest" -AnchorPath $PackageRoot
    $supportManifest = Get-JsonDocument -Path $supportManifestPath -Label "Proof-review support manifest"

    Assert-RequiredObjectFields -Object $supportManifest -FieldNames @($contract.support_manifest_required_fields) -Context "Proof-review support manifest"
    Assert-RequiredObjectFields -Object $supportManifest.original_replay_source -FieldNames @($contract.support_manifest_original_replay_source_required_fields) -Context "Proof-review support manifest.original_replay_source"
    Assert-MatchingValue -Expected $ReplaySource.source_head_commit -Actual (Assert-NonEmptyString -Value $supportManifest.original_replay_source.head_commit -Context "Proof-review support manifest.original_replay_source.head_commit") -Context "Proof-review support manifest original replay source head"
    Assert-MatchingValue -Expected $ReplaySource.source_tree_id -Actual (Assert-NonEmptyString -Value $supportManifest.original_replay_source.tree_id -Context "Proof-review support manifest.original_replay_source.tree_id") -Context "Proof-review support manifest original replay source tree"
    Assert-NonEmptyString -Value $supportManifest.support_kind -Context "Proof-review support manifest.support_kind" | Out-Null
    Assert-NonEmptyString -Value $supportManifest.correction_purpose -Context "Proof-review support manifest.correction_purpose" | Out-Null
    Assert-NonEmptyString -Value $supportManifest.accepted_r7_closeout_head_before_correction -Context "Proof-review support manifest.accepted_r7_closeout_head_before_correction" | Out-Null
    if ($null -ne $supportManifest.correction_commit_head) {
        Assert-NonEmptyString -Value $supportManifest.correction_commit_head -Context "Proof-review support manifest.correction_commit_head" | Out-Null
    }
    Assert-NonEmptyString -Value $supportManifest.branch -Context "Proof-review support manifest.branch" | Out-Null
    Assert-NonEmptyString -Value $supportManifest.local_head -Context "Proof-review support manifest.local_head" | Out-Null
    Assert-NonEmptyString -Value $supportManifest.remote_head -Context "Proof-review support manifest.remote_head" | Out-Null
    Assert-NonEmptyString -Value $supportManifest.tree_hash -Context "Proof-review support manifest.tree_hash" | Out-Null
    $supportTimestamp = Assert-NonEmptyString -Value $supportManifest.timestamp_utc -Context "Proof-review support manifest.timestamp_utc"
    if ($supportTimestamp -notmatch "^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$") {
        throw "Proof-review support manifest.timestamp_utc must match the expected UTC timestamp pattern."
    }
    Assert-AllowedValue -Value (Assert-NonEmptyString -Value $supportManifest.result -Context "Proof-review support manifest.result") -AllowedValues @($contract.allowed_support_manifest_results) -Context "Proof-review support manifest.result"
    if ([string]$supportManifest.result -ne "passed") {
        throw "Proof-review support manifest.result must be 'passed' for a valid proof-review package."
    }

    $supportNote = Assert-NonEmptyString -Value $supportManifest.note -Context "Proof-review support manifest.note"
    if ($supportNote.ToLowerInvariant() -notlike "*not replacement original replay logs*") {
        throw "Proof-review support manifest.note must explicitly state that support-hardening logs are not replacement original replay logs."
    }

    $commandList = Assert-StringArray -Value $supportManifest.command_list -Context "Proof-review support manifest.command_list"
    $commandRecords = Assert-ObjectArray -Value $supportManifest.command_records -Context "Proof-review support manifest.command_records"
    $rawLogRefs = Assert-StringArray -Value $supportManifest.raw_log_refs -Context "Proof-review support manifest.raw_log_refs"
    $exitCodes = Assert-ObjectValue -Value $supportManifest.exit_codes -Context "Proof-review support manifest.exit_codes"
    $claimedCommandCoverage = Assert-ObjectArray -Value $supportManifest.claimed_command_log_coverage -Context "Proof-review support manifest.claimed_command_log_coverage"
    $normalizedSupportCommandList = @{}

    foreach ($commandListItem in $commandList) {
        $normalizedSupportCommandList[(Normalize-CommandText -CommandText $commandListItem)] = $true
    }

    foreach ($rawLogRef in $rawLogRefs) {
        Resolve-ExistingPath -PathValue $rawLogRef -Label "Proof-review support raw log" -AnchorPath $PackageRoot | Out-Null
    }

    foreach ($commandRecord in $commandRecords) {
        Assert-RequiredObjectFields -Object $commandRecord -FieldNames @($contract.support_manifest_command_record_required_fields) -Context "Proof-review support manifest.command_records item"
        $commandId = Assert-NonEmptyString -Value $commandRecord.command_id -Context "Proof-review support manifest.command_records item.command_id"
        $command = Assert-NonEmptyString -Value $commandRecord.command -Context "Proof-review support manifest.command_records item.command"
        $stdoutLogRef = Assert-NonEmptyString -Value $commandRecord.stdout_log_ref -Context "Proof-review support manifest.command_records item.stdout_log_ref"
        $stderrLogRef = Assert-NonEmptyString -Value $commandRecord.stderr_log_ref -Context "Proof-review support manifest.command_records item.stderr_log_ref"
        $classification = Assert-NonEmptyString -Value $commandRecord.classification -Context "Proof-review support manifest.command_records item.classification"

        Assert-AllowedValue -Value $classification -AllowedValues @("support_hardening_logs") -Context "Proof-review support manifest.command_records item.classification"
        Resolve-ExistingPath -PathValue $stdoutLogRef -Label "Proof-review support command stdout log" -AnchorPath $PackageRoot | Out-Null
        Resolve-ExistingPath -PathValue $stderrLogRef -Label "Proof-review support command stderr log" -AnchorPath $PackageRoot | Out-Null

        if ($commandList -notcontains $command) {
            throw "Proof-review support manifest.command_list must include '$command'."
        }
        if (-not (Test-HasProperty -Object $exitCodes -Name $commandId)) {
            throw "Proof-review support manifest.exit_codes is missing command id '$commandId'."
        }
        if ([int]$exitCodes.$commandId -ne [int]$commandRecord.exit_code) {
            throw "Proof-review support manifest.exit_codes.$commandId must match command record exit_code."
        }
    }

    foreach ($coverageEntry in $claimedCommandCoverage) {
        Assert-RequiredObjectFields -Object $coverageEntry -FieldNames @($contract.support_manifest_claimed_command_coverage_required_fields) -Context "Proof-review support manifest.claimed_command_log_coverage item"
        $coverageCommand = Assert-NonEmptyString -Value $coverageEntry.command -Context "Proof-review support manifest.claimed_command_log_coverage item.command"
        $coverageLogRefs = Assert-StringArray -Value $coverageEntry.log_refs -Context "Proof-review support manifest.claimed_command_log_coverage item.log_refs"
        $coverageClassification = Assert-NonEmptyString -Value $coverageEntry.classification -Context "Proof-review support manifest.claimed_command_log_coverage item.classification"
        Assert-AllowedValue -Value $coverageClassification -AllowedValues @($contract.allowed_support_log_classifications) -Context "Proof-review support manifest.claimed_command_log_coverage item.classification"
        Assert-NonEmptyString -Value $coverageEntry.note -Context "Proof-review support manifest.claimed_command_log_coverage item.note" | Out-Null

        foreach ($coverageLogRef in $coverageLogRefs) {
            Resolve-ExistingPath -PathValue $coverageLogRef -Label "Proof-review claimed-command coverage log" -AnchorPath $PackageRoot | Out-Null
        }

        if (-not $normalizedSupportCommandList.ContainsKey((Normalize-CommandText -CommandText $coverageCommand)) -and $coverageClassification -eq "support_hardening_logs") {
            throw "Proof-review support manifest.command_list must include support-covered command '$coverageCommand'."
        }
    }

    return [pscustomobject]@{
        SupportManifestPath = $supportManifestPath
        SupportManifest = $supportManifest
        ClaimedCommandCoverage = $claimedCommandCoverage
    }
}

function Test-R7CommittedEvidence {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $inputPaths = Get-R7InputPaths -RepositoryRoot $RepositoryRoot
    & (Get-FaultEventValidatorCommand) -EventPath $inputPaths.FaultEventPath | Out-Null
    & (Get-CheckpointValidatorCommand) -ArtifactPath $inputPaths.CheckpointPath | Out-Null
    & (Get-HandoffValidatorCommand) -ArtifactPath $inputPaths.HandoffPath | Out-Null
    & (Get-ResumeRequestValidatorCommand) -ResumeRequestPath $inputPaths.ResumeRequestPath | Out-Null
    & (Get-ResumeResultValidatorCommand) -ResumeResultPath $inputPaths.ResumeResultPath | Out-Null
    & (Get-LedgerValidatorCommand) -LedgerPath $inputPaths.LedgerPath | Out-Null
    & (Get-RollbackPlanRequestValidatorCommand) -RollbackPlanRequestPath $inputPaths.RollbackPlanRequestPath | Out-Null
    & (Get-RollbackPlanValidatorCommand) -RollbackPlanPath $inputPaths.RollbackPlanPath | Out-Null
    & (Get-RollbackAuthorizationValidatorCommand) -RollbackDrillAuthorizationPath $inputPaths.RollbackDrillAuthorizationPath | Out-Null
    & (Get-RollbackDrillResultValidatorCommand) -DrillResultPath $inputPaths.RollbackDrillResultPath | Out-Null
    & (Get-ReviewSummaryValidatorCommand) -ReviewSummaryPath $inputPaths.ReviewSummaryPath | Out-Null
    & (Get-OperatorPacketValidatorCommand) -OperatorPacketPath $inputPaths.OperatorPacketPath | Out-Null

    $faultEvent = Get-JsonDocument -Path $inputPaths.FaultEventPath -Label "Fault event"
    $checkpoint = Get-JsonDocument -Path $inputPaths.CheckpointPath -Label "Continuity checkpoint"
    $handoff = Get-JsonDocument -Path $inputPaths.HandoffPath -Label "Continuity handoff packet"
    $resumeRequest = Get-JsonDocument -Path $inputPaths.ResumeRequestPath -Label "Resume request"
    $resumeResult = Get-JsonDocument -Path $inputPaths.ResumeResultPath -Label "Resume result"
    $ledger = Get-JsonDocument -Path $inputPaths.LedgerPath -Label "Continuity ledger"
    $rollbackPlanRequest = Get-JsonDocument -Path $inputPaths.RollbackPlanRequestPath -Label "Rollback plan request"
    $rollbackPlan = Get-JsonDocument -Path $inputPaths.RollbackPlanPath -Label "Rollback plan"
    $rollbackAuthorization = Get-JsonDocument -Path $inputPaths.RollbackDrillAuthorizationPath -Label "Rollback drill authorization"
    $rollbackDrillResult = Get-JsonDocument -Path $inputPaths.RollbackDrillResultPath -Label "Rollback drill result"
    $reviewSummary = Get-JsonDocument -Path $inputPaths.ReviewSummaryPath -Label "Review summary"
    $operatorPacket = Get-JsonDocument -Path $inputPaths.OperatorPacketPath -Label "Operator packet"

    $cycleId = Assert-NonEmptyString -Value $faultEvent.cycle_context.cycle_id -Context "Fault event.cycle_context.cycle_id"
    $milestoneId = Assert-NonEmptyString -Value $faultEvent.cycle_context.milestone_id -Context "Fault event.cycle_context.milestone_id"
    $repositoryName = Assert-NonEmptyString -Value $faultEvent.repository.repository_name -Context "Fault event.repository.repository_name"
    $taskId = Assert-NonEmptyString -Value $faultEvent.affected_scope.task_id -Context "Fault event.affected_scope.task_id"
    $interruptedSegmentId = Assert-NonEmptyString -Value $faultEvent.affected_scope.segment_id -Context "Fault event.affected_scope.segment_id"

    foreach ($cycleDocument in @(
            @{ Value = $checkpoint.cycle_context.cycle_id; Context = "Checkpoint cycle id" },
            @{ Value = $handoff.cycle_context.cycle_id; Context = "Handoff cycle id" },
            @{ Value = $resumeRequest.cycle_context.cycle_id; Context = "Resume request cycle id" },
            @{ Value = $resumeResult.cycle_context.cycle_id; Context = "Resume result cycle id" },
            @{ Value = $ledger.cycle_context.cycle_id; Context = "Ledger cycle id" },
            @{ Value = $rollbackPlan.cycle_context.cycle_id; Context = "Rollback plan cycle id" },
            @{ Value = $rollbackDrillResult.cycle_context.cycle_id; Context = "Rollback drill result cycle id" },
            @{ Value = $reviewSummary.cycle_context.cycle_id; Context = "Review summary cycle id" },
            @{ Value = $operatorPacket.cycle_context.cycle_id; Context = "Operator packet cycle id" }
        )) {
        Assert-MatchingValue -Expected $cycleId -Actual $cycleDocument.Value -Context $cycleDocument.Context
    }

    foreach ($milestoneDocument in @(
            @{ Value = $checkpoint.cycle_context.milestone_id; Context = "Checkpoint milestone id" },
            @{ Value = $handoff.cycle_context.milestone_id; Context = "Handoff milestone id" },
            @{ Value = $resumeRequest.cycle_context.milestone_id; Context = "Resume request milestone id" },
            @{ Value = $resumeResult.cycle_context.milestone_id; Context = "Resume result milestone id" },
            @{ Value = $ledger.cycle_context.milestone_id; Context = "Ledger milestone id" },
            @{ Value = $rollbackPlan.cycle_context.milestone_id; Context = "Rollback plan milestone id" },
            @{ Value = $rollbackDrillResult.cycle_context.milestone_id; Context = "Rollback drill result milestone id" },
            @{ Value = $reviewSummary.cycle_context.milestone_id; Context = "Review summary milestone id" },
            @{ Value = $operatorPacket.cycle_context.milestone_id; Context = "Operator packet milestone id" }
        )) {
        Assert-MatchingValue -Expected $milestoneId -Actual $milestoneDocument.Value -Context $milestoneDocument.Context
    }

    foreach ($repositoryDocument in @(
            @{ Value = $checkpoint.repository.repository_name; Context = "Checkpoint repository name" },
            @{ Value = $handoff.repository.repository_name; Context = "Handoff repository name" },
            @{ Value = $resumeRequest.repository.repository_name; Context = "Resume request repository name" },
            @{ Value = $resumeResult.repository.repository_name; Context = "Resume result repository name" },
            @{ Value = $ledger.repository.repository_name; Context = "Ledger repository name" },
            @{ Value = $rollbackPlan.repository.repository_name; Context = "Rollback plan repository name" },
            @{ Value = $rollbackDrillResult.repository.repository_name; Context = "Rollback drill result repository name" },
            @{ Value = $reviewSummary.repository.repository_name; Context = "Review summary repository name" },
            @{ Value = $operatorPacket.repository.repository_name; Context = "Operator packet repository name" }
        )) {
        Assert-MatchingValue -Expected $repositoryName -Actual $repositoryDocument.Value -Context $repositoryDocument.Context
    }

    $continuityBranch = Assert-NonEmptyString -Value $faultEvent.git_context.branch -Context "Fault event.git_context.branch"
    $continuityHeadCommit = Assert-NonEmptyString -Value $faultEvent.git_context.head_commit -Context "Fault event.git_context.head_commit"
    $continuityTreeId = Assert-NonEmptyString -Value $faultEvent.git_context.tree_id -Context "Fault event.git_context.tree_id"

    foreach ($gitContext in @(
            @{ Branch = $checkpoint.git_context.branch; Head = $checkpoint.git_context.head_commit; Tree = $checkpoint.git_context.tree_id; Context = "Checkpoint git context" },
            @{ Branch = $handoff.git_context.branch; Head = $handoff.git_context.head_commit; Tree = $handoff.git_context.tree_id; Context = "Handoff git context" },
            @{ Branch = $resumeRequest.git_context.branch; Head = $resumeRequest.git_context.head_commit; Tree = $resumeRequest.git_context.tree_id; Context = "Resume request git context" },
            @{ Branch = $resumeResult.git_context.branch; Head = $resumeResult.git_context.head_commit; Tree = $resumeResult.git_context.tree_id; Context = "Resume result git context" },
            @{ Branch = $ledger.git_context.branch; Head = $ledger.git_context.head_commit; Tree = $ledger.git_context.tree_id; Context = "Ledger git context" },
            @{ Branch = $reviewSummary.continuity_git_context.branch; Head = $reviewSummary.continuity_git_context.head_commit; Tree = $reviewSummary.continuity_git_context.tree_id; Context = "Review summary continuity git context" }
        )) {
        Assert-MatchingValue -Expected $continuityBranch -Actual $gitContext.Branch -Context "$($gitContext.Context) branch"
        Assert-MatchingValue -Expected $continuityHeadCommit -Actual $gitContext.Head -Context "$($gitContext.Context) head commit"
        Assert-MatchingValue -Expected $continuityTreeId -Actual $gitContext.Tree -Context "$($gitContext.Context) tree id"
    }

    Assert-MatchingValue -Expected $taskId -Actual $checkpoint.scope_context.task_id -Context "Checkpoint task id"
    Assert-MatchingValue -Expected $taskId -Actual $handoff.scope_context.task_id -Context "Handoff task id"
    Assert-MatchingValue -Expected $taskId -Actual $resumeRequest.scope_context.task_id -Context "Resume request task id"
    Assert-MatchingValue -Expected $taskId -Actual $resumeResult.scope_context.task_id -Context "Resume result task id"
    Assert-MatchingValue -Expected $taskId -Actual $reviewSummary.continuity_identity.task_id -Context "Review summary task id"
    Assert-MatchingValue -Expected $taskId -Actual $operatorPacket.continuity_identity.task_id -Context "Operator packet task id"
    Assert-MatchingValue -Expected $taskId -Actual $rollbackPlan.source_continuity.task_id -Context "Rollback plan task id"
    Assert-MatchingValue -Expected $taskId -Actual $rollbackDrillResult.source_continuity.task_id -Context "Rollback drill result task id"

    Assert-MatchingValue -Expected $interruptedSegmentId -Actual $checkpoint.scope_context.segment_id -Context "Checkpoint interrupted segment id"
    Assert-MatchingValue -Expected $interruptedSegmentId -Actual $handoff.scope_context.segment_id -Context "Handoff interrupted segment id"
    Assert-MatchingValue -Expected $interruptedSegmentId -Actual $resumeRequest.scope_context.segment_id -Context "Resume request interrupted segment id"
    Assert-MatchingValue -Expected $interruptedSegmentId -Actual $resumeResult.scope_context.segment_id -Context "Resume result interrupted segment id"
    Assert-MatchingValue -Expected $interruptedSegmentId -Actual $reviewSummary.continuity_identity.interrupted_segment_id -Context "Review summary interrupted segment id"
    Assert-MatchingValue -Expected $interruptedSegmentId -Actual $operatorPacket.continuity_identity.interrupted_segment_id -Context "Operator packet interrupted segment id"
    Assert-MatchingValue -Expected $interruptedSegmentId -Actual $rollbackPlan.source_continuity.interrupted_segment_id -Context "Rollback plan interrupted segment id"
    Assert-MatchingValue -Expected $interruptedSegmentId -Actual $rollbackDrillResult.source_continuity.interrupted_segment_id -Context "Rollback drill result interrupted segment id"

    $successorSegmentId = Assert-NonEmptyString -Value $rollbackPlan.source_continuity.successor_segment_id -Context "Rollback plan.source_continuity.successor_segment_id"
    Assert-MatchingValue -Expected $successorSegmentId -Actual $reviewSummary.continuity_identity.successor_segment_id -Context "Review summary successor segment id"
    Assert-MatchingValue -Expected $successorSegmentId -Actual $operatorPacket.continuity_identity.successor_segment_id -Context "Operator packet successor segment id"
    Assert-MatchingValue -Expected $successorSegmentId -Actual $rollbackDrillResult.source_continuity.successor_segment_id -Context "Rollback drill result successor segment id"
    Assert-MatchingValue -Expected $successorSegmentId -Actual $ledger.ordered_segments[1].segment_id -Context "Ledger successor segment id"

    $ledgerId = Assert-NonEmptyString -Value $ledger.ledger_id -Context "Ledger.ledger_id"
    Assert-MatchingValue -Expected $ledgerId -Actual $rollbackPlanRequest.continuity_ledger_ref.ledger_id -Context "Rollback plan request ledger id"
    Assert-MatchingValue -Expected $ledgerId -Actual $rollbackPlan.source_continuity.ledger_ref.ledger_id -Context "Rollback plan ledger id"
    Assert-MatchingValue -Expected $ledgerId -Actual $rollbackDrillResult.source_continuity.ledger_id -Context "Rollback drill result ledger id"
    Assert-MatchingValue -Expected $ledgerId -Actual $reviewSummary.evidence_refs.continuity_ledger_ref.ledger_id -Context "Review summary ledger id"

    $rollbackPlanRequestId = Assert-NonEmptyString -Value $rollbackPlanRequest.rollback_plan_request_id -Context "Rollback plan request id"
    $rollbackPlanId = Assert-NonEmptyString -Value $rollbackPlan.rollback_plan_id -Context "Rollback plan id"
    $rollbackAuthorizationId = Assert-NonEmptyString -Value $rollbackAuthorization.rollback_drill_authorization_id -Context "Rollback authorization id"
    $rollbackDrillId = Assert-NonEmptyString -Value $rollbackDrillResult.rollback_drill_id -Context "Rollback drill id"
    $reviewSummaryId = Assert-NonEmptyString -Value $reviewSummary.review_summary_id -Context "Review summary id"
    $operatorPacketId = Assert-NonEmptyString -Value $operatorPacket.operator_packet_id -Context "Operator packet id"

    Assert-MatchingValue -Expected $rollbackPlanId -Actual $rollbackAuthorization.rollback_plan_id -Context "Rollback authorization rollback plan id"
    Assert-MatchingValue -Expected $rollbackPlanId -Actual $rollbackDrillResult.rollback_plan_ref.rollback_plan_id -Context "Rollback drill result rollback plan id"
    Assert-MatchingValue -Expected $rollbackPlanId -Actual $reviewSummary.evidence_refs.rollback_plan_ref.rollback_plan_id -Context "Review summary rollback plan id"
    Assert-MatchingValue -Expected $rollbackPlanId -Actual $operatorPacket.continuity_identity.rollback_plan_id -Context "Operator packet rollback plan id"
    Assert-MatchingValue -Expected $rollbackAuthorizationId -Actual $rollbackDrillResult.rollback_drill_authorization_ref.rollback_drill_authorization_id -Context "Rollback drill result authorization id"
    Assert-MatchingValue -Expected $rollbackDrillId -Actual $reviewSummary.evidence_refs.rollback_drill_result_ref.rollback_drill_id -Context "Review summary rollback drill id"
    Assert-MatchingValue -Expected $rollbackDrillId -Actual $operatorPacket.continuity_identity.rollback_drill_id -Context "Operator packet rollback drill id"
    Assert-MatchingValue -Expected $reviewSummaryId -Actual $operatorPacket.review_summary_id -Context "Operator packet review summary id"

    Assert-MatchingValue -Expected $rollbackPlan.rollback_target.branch -Actual $rollbackDrillResult.target_git_context.branch -Context "Rollback target branch"
    Assert-MatchingValue -Expected $rollbackPlan.rollback_target.head_commit -Actual $rollbackDrillResult.target_git_context.head_commit -Context "Rollback target head commit"
    Assert-MatchingValue -Expected $rollbackPlan.rollback_target.tree_id -Actual $rollbackDrillResult.target_git_context.tree_id -Context "Rollback target tree id"
    Assert-MatchingValue -Expected $rollbackPlan.rollback_target.branch -Actual $reviewSummary.rollback_target_git_context.branch -Context "Review summary rollback target branch"
    Assert-MatchingValue -Expected $rollbackPlan.rollback_target.head_commit -Actual $reviewSummary.rollback_target_git_context.head_commit -Context "Review summary rollback target head commit"
    Assert-MatchingValue -Expected $rollbackPlan.rollback_target.tree_id -Actual $reviewSummary.rollback_target_git_context.tree_id -Context "Review summary rollback target tree id"

    $expectedReviewNonClaims = Get-MilestoneContinuityFoundationContract | Select-Object -ExpandProperty allowed_review_non_claims
    Test-RequiredNonClaims -NonClaims @($reviewSummary.non_claims) -Expected @($expectedReviewNonClaims) -Context "Review summary non-claims"
    Test-RequiredNonClaims -NonClaims @($operatorPacket.non_claims) -Expected @($expectedReviewNonClaims) -Context "Operator packet non-claims"
    Assert-AllowedValue -Value $reviewSummary.recommendation -AllowedValues @((Get-MilestoneContinuityFoundationContract).allowed_review_recommendations) -Context "Review summary recommendation"
    Assert-AllowedValue -Value $operatorPacket.recommendation -AllowedValues @((Get-MilestoneContinuityFoundationContract).allowed_operator_packet_options) -Context "Operator packet recommendation"
    if (-not (Assert-BooleanValue -Value $reviewSummary.recommendation_is_advisory -Context "Review summary recommendation_is_advisory")) {
        throw "Review summary recommendation_is_advisory must remain true."
    }
    if (-not (Assert-BooleanValue -Value $operatorPacket.recommendation_is_advisory -Context "Operator packet recommendation_is_advisory")) {
        throw "Operator packet recommendation_is_advisory must remain true."
    }

    return [pscustomobject]@{
        InputPaths = $inputPaths
        FaultEvent = $faultEvent
        Checkpoint = $checkpoint
        Handoff = $handoff
        ResumeRequest = $resumeRequest
        ResumeResult = $resumeResult
        Ledger = $ledger
        RollbackPlanRequest = $rollbackPlanRequest
        RollbackPlan = $rollbackPlan
        RollbackAuthorization = $rollbackAuthorization
        RollbackDrillResult = $rollbackDrillResult
        ReviewSummary = $reviewSummary
        OperatorPacket = $operatorPacket
        CycleId = $cycleId
        MilestoneId = $milestoneId
        RepositoryName = $repositoryName
        TaskId = $taskId
        InterruptedSegmentId = $interruptedSegmentId
        SuccessorSegmentId = $successorSegmentId
        LedgerId = $ledgerId
        RollbackPlanRequestId = $rollbackPlanRequestId
        RollbackPlanId = $rollbackPlanId
        RollbackAuthorizationId = $rollbackAuthorizationId
        RollbackDrillId = $rollbackDrillId
        ReviewSummaryId = $reviewSummaryId
        OperatorPacketId = $operatorPacketId
        ContinuityBranch = $continuityBranch
        ContinuityHeadCommit = $continuityHeadCommit
        ContinuityTreeId = $continuityTreeId
    }
}

function Get-R7ScopeStatements {
    param(
        [Parameter(Mandatory = $true)]
        $Evidence,
        [Parameter(Mandatory = $true)]
        [string]$RelativeFaultEventPath,
        [Parameter(Mandatory = $true)]
        [string]$RelativeOperatorPacketPath
    )

    return [pscustomobject]@{
        ReplayScope = "Exact replay scope: cycle $($Evidence.CycleId) replays one interrupted-and-resumed supervised continuity path from committed fault event $RelativeFaultEventPath through committed operator packet $RelativeOperatorPacketPath, plus one committed disposable-worktree rollback drill result, without implying unattended or destructive execution."
        CloseoutScope = "Exact closeout scope: close out only cycle $($Evidence.CycleId) for one repository-local interrupted-and-resumed supervised continuity chain plus one safe disposable-worktree rollback drill packet from committed R7-002 through R7-008 evidence."
        ProvedScope = "Proved scope: cycle $($Evidence.CycleId) replays one exact chain across committed fault event, checkpoint, handoff packet, supervised resume request/result, continuity ledger, governed rollback plan request/plan, rollback drill authorization/result, advisory review summary, operator packet, raw replay logs, one bounded replay summary artifact, and one bounded closeout packet."
        UnprovedScope = "Unproved scope: unattended automatic resume, destructive primary-tree rollback, broader rollback productization, UI or control-room productization, Standard runtime, multi-repo behavior, swarms, and broader orchestration."
        OutOfScope = "Out of scope: any later milestone work, any R8 implementation, any broader autonomy claim, and any destructive rollback execution outside the bounded disposable-worktree drill already committed."
    }
}

function Test-MilestoneContinuityCloseoutPacketObject {
    param(
        [Parameter(Mandatory = $true)]
        $CloseoutPacket,
        [Parameter(Mandatory = $true)]
        [string]$SourceLabel,
        [string]$AnchorDirectory
    )

    $foundation = Get-MilestoneContinuityFoundationContract
    $contract = Get-CloseoutPacketContract

    Assert-RequiredObjectFields -Object $CloseoutPacket -FieldNames @($contract.required_fields) -Context $SourceLabel
    Assert-MatchingValue -Expected $foundation.contract_version -Actual $CloseoutPacket.contract_version -Context "$SourceLabel.contract_version"
    Assert-MatchingValue -Expected $contract.record_type -Actual $CloseoutPacket.record_type -Context "$SourceLabel.record_type"
    Assert-RequiredObjectFields -Object $CloseoutPacket.cycle_context -FieldNames @($contract.cycle_context_required_fields) -Context "$SourceLabel.cycle_context"
    Assert-RequiredObjectFields -Object $CloseoutPacket.repository -FieldNames @($contract.repository_required_fields) -Context "$SourceLabel.repository"
    Assert-RequiredObjectFields -Object $CloseoutPacket.replay_source -FieldNames @($contract.replay_source_required_fields) -Context "$SourceLabel.replay_source"
    Assert-RequiredObjectFields -Object $CloseoutPacket.continuity_identity -FieldNames @($contract.continuity_identity_required_fields) -Context "$SourceLabel.continuity_identity"
    Assert-RequiredObjectFields -Object $CloseoutPacket.rollback_identity -FieldNames @($contract.rollback_identity_required_fields) -Context "$SourceLabel.rollback_identity"
    Assert-RequiredObjectFields -Object $CloseoutPacket.authoritative_refs -FieldNames @($contract.authoritative_refs_required_fields) -Context "$SourceLabel.authoritative_refs"
    Assert-RequiredObjectFields -Object $CloseoutPacket.authoritative_refs.continuity_proof_refs -FieldNames @($contract.continuity_proof_refs_required_fields) -Context "$SourceLabel.authoritative_refs.continuity_proof_refs"
    Assert-RequiredObjectFields -Object $CloseoutPacket.authoritative_refs.rollback_proof_refs -FieldNames @($contract.rollback_proof_refs_required_fields) -Context "$SourceLabel.authoritative_refs.rollback_proof_refs"
    Assert-RequiredObjectFields -Object $CloseoutPacket.authoritative_refs.repo_truth_refs -FieldNames @($contract.repo_truth_refs_required_fields) -Context "$SourceLabel.authoritative_refs.repo_truth_refs"

    $nonClaims = Assert-StringArray -Value $CloseoutPacket.non_claims -Context "$SourceLabel.non_claims"
    Test-RequiredNonClaims -NonClaims @($nonClaims) -Expected @(Get-R7CloseoutNonClaims) -Context "$SourceLabel.non_claims"
    if (Assert-BooleanValue -Value $CloseoutPacket.automatic_execution_implied -Context "$SourceLabel.automatic_execution_implied") {
        throw "$SourceLabel must not imply automatic execution."
    }
    if (Assert-BooleanValue -Value $CloseoutPacket.destructive_primary_worktree_rollback_implied -Context "$SourceLabel.destructive_primary_worktree_rollback_implied") {
        throw "$SourceLabel must not imply destructive primary-worktree rollback."
    }

    Assert-NoProhibitedClaimFragments -TextValues @(
        [string]$CloseoutPacket.exact_replay_scope,
        [string]$CloseoutPacket.closeout_scope,
        [string]$CloseoutPacket.proved_scope,
        [string]$CloseoutPacket.unproved_scope,
        [string]$CloseoutPacket.out_of_scope,
        [string]$CloseoutPacket.notes
    ) -Fragments @($contract.prohibited_claim_fragments) -Context $SourceLabel

    if (-not [string]::IsNullOrWhiteSpace($AnchorDirectory)) {
        Resolve-ExistingPath -PathValue (Join-Path $AnchorDirectory $CloseoutPacket.summary_ref) -Label "$SourceLabel.summary_ref" | Out-Null
        Resolve-ExistingPath -PathValue (Join-Path $AnchorDirectory $CloseoutPacket.proof_selection_scope_ref) -Label "$SourceLabel.proof_selection_scope_ref" | Out-Null

        foreach ($proofRef in @(
                $CloseoutPacket.authoritative_refs.continuity_proof_refs.fault_event_ref,
                $CloseoutPacket.authoritative_refs.continuity_proof_refs.checkpoint_ref,
                $CloseoutPacket.authoritative_refs.continuity_proof_refs.handoff_packet_ref,
                $CloseoutPacket.authoritative_refs.continuity_proof_refs.resume_request_ref,
                $CloseoutPacket.authoritative_refs.continuity_proof_refs.resume_result_ref,
                $CloseoutPacket.authoritative_refs.continuity_proof_refs.continuity_ledger_ref,
                $CloseoutPacket.authoritative_refs.rollback_proof_refs.rollback_plan_request_ref,
                $CloseoutPacket.authoritative_refs.rollback_proof_refs.rollback_plan_ref,
                $CloseoutPacket.authoritative_refs.rollback_proof_refs.rollback_drill_authorization_ref,
                $CloseoutPacket.authoritative_refs.rollback_proof_refs.rollback_drill_result_ref,
                $CloseoutPacket.authoritative_refs.rollback_proof_refs.review_summary_ref,
                $CloseoutPacket.authoritative_refs.rollback_proof_refs.operator_packet_ref,
                $CloseoutPacket.authoritative_refs.repo_truth_refs.readme_path,
                $CloseoutPacket.authoritative_refs.repo_truth_refs.active_state_path,
                $CloseoutPacket.authoritative_refs.repo_truth_refs.kanban_path,
                $CloseoutPacket.authoritative_refs.repo_truth_refs.decision_log_path,
                $CloseoutPacket.authoritative_refs.repo_truth_refs.milestone_authority_path
            )) {
            Resolve-ExistingPath -PathValue (Join-Path $AnchorDirectory $proofRef) -Label "$SourceLabel authoritative ref" | Out-Null
        }
    }

    return $CloseoutPacket
}

function Test-MilestoneContinuityCloseoutPacketContract {
    param(
        [Parameter(Mandatory = $true)]
        [string]$CloseoutPacketPath
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $CloseoutPacketPath -Label "Closeout packet path"
    $closeoutPacket = Get-JsonDocument -Path $resolvedPath -Label "Closeout packet"
    return Test-MilestoneContinuityCloseoutPacketObject -CloseoutPacket $closeoutPacket -SourceLabel $resolvedPath -AnchorDirectory (Split-Path -Parent $resolvedPath)
}

function Test-MilestoneContinuityProofReviewPackage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageRoot
    )

    $packageRootPath = Resolve-ExistingPath -PathValue $PackageRoot -Label "Proof-review package root"
    $foundation = Get-MilestoneContinuityFoundationContract
    $contract = Get-ProofReviewPacketContract

    $manifestPath = Resolve-ExistingPath -PathValue (Join-Path $packageRootPath "proof_review_manifest.json") -Label "Proof-review manifest"
    $manifest = Get-JsonDocument -Path $manifestPath -Label "Proof-review manifest"
    Assert-RequiredObjectFields -Object $manifest -FieldNames @($contract.required_fields) -Context "Proof-review manifest"
    Assert-MatchingValue -Expected $foundation.contract_version -Actual $manifest.package_version -Context "Proof-review manifest.package_version"
    Assert-MatchingValue -Expected $contract.package_type -Actual $manifest.package_type -Context "Proof-review manifest.package_type"

    $selectionScopePath = Resolve-ExistingPath -PathValue (Join-Path $packageRootPath $manifest.selection_scope_ref) -Label "Proof selection scope"
    $replaySourcePath = Resolve-ExistingPath -PathValue (Join-Path $packageRootPath $manifest.replay_source_ref) -Label "Replay source metadata"
    $replayedCommandsPath = Resolve-ExistingPath -PathValue (Join-Path $packageRootPath $manifest.replay_commands_ref) -Label "Replayed commands"
    $artifactRefsPath = Resolve-ExistingPath -PathValue (Join-Path $packageRootPath $manifest.authoritative_artifact_refs_ref) -Label "Authoritative artifact refs"
    $nonClaimsPath = Resolve-ExistingPath -PathValue (Join-Path $packageRootPath $manifest.non_claims_ref) -Label "Explicit non-claims"
    $replaySummaryMarkdownPath = Resolve-ExistingPath -PathValue (Join-Path $packageRootPath $manifest.replay_summary_ref) -Label "Replay summary Markdown"
    $closeoutReviewPath = Resolve-ExistingPath -PathValue (Join-Path $packageRootPath $manifest.closeout_review_ref) -Label "Closeout review Markdown"
    $summaryPath = Resolve-ExistingPath -PathValue (Join-Path $packageRootPath $manifest.summary_ref) -Label "Proof-review summary artifact"
    $closeoutPacketPath = Resolve-ExistingPath -PathValue (Join-Path $packageRootPath $manifest.closeout_packet_ref) -Label "Closeout packet"

    $selectionScope = Get-JsonDocument -Path $selectionScopePath -Label "Proof selection scope"
    $replaySource = Get-JsonDocument -Path $replaySourcePath -Label "Replay source metadata"
    $artifactRefs = Get-JsonDocument -Path $artifactRefsPath -Label "Authoritative artifact refs"
    $summary = Get-JsonDocument -Path $summaryPath -Label "Proof-review summary artifact"
    $closeoutPacket = Test-MilestoneContinuityCloseoutPacketContract -CloseoutPacketPath $closeoutPacketPath
    $supportManifestValidation = Test-ProofReviewSupportManifest -ProofReviewManifest $manifest -PackageRoot $packageRootPath -ReplaySource $replaySource
    $nonClaims = Assert-StringArray -Value (Get-JsonDocument -Path $nonClaimsPath -Label "Explicit non-claims") -Context "Proof-review package non-claims"
    Test-RequiredNonClaims -NonClaims @($nonClaims) -Expected @(Get-R7CloseoutNonClaims) -Context "Proof-review package non-claims"

    $rawLogRefs = Assert-StringArray -Value $manifest.raw_log_refs -Context "Proof-review manifest.raw_log_refs"
    foreach ($rawLogRef in $rawLogRefs) {
        Resolve-ExistingPath -PathValue (Join-Path $packageRootPath $rawLogRef) -Label "Raw log" | Out-Null
    }

    Assert-RequiredObjectFields -Object $summary -FieldNames @($contract.summary_required_fields) -Context "Proof-review summary artifact"
    $commandResults = Assert-ObjectArray -Value $summary.command_results -Context "Proof-review summary artifact.command_results"
    $normalizedClaimedCommandCoverage = @{}
    foreach ($commandResult in $commandResults) {
        Assert-RequiredObjectFields -Object $commandResult -FieldNames @($contract.summary_command_result_required_fields) -Context "Proof-review summary artifact.command_results item"
        Assert-AllowedValue -Value ([string]$commandResult.status) -AllowedValues @($contract.allowed_summary_statuses) -Context "Proof-review summary artifact.command_results item.status"
        if ([int]$commandResult.exit_code -ne 0) {
            throw "Proof-review summary artifact.command_results item.exit_code must be 0."
        }

        Resolve-ExistingPath -PathValue (Join-Path $packageRootPath $commandResult.log_ref) -Label "Command result raw log" | Out-Null
        $normalizedClaimedCommandCoverage[(Normalize-CommandText -CommandText ([string]$commandResult.command))] = @([string]$commandResult.log_ref)
    }

    if ($null -ne $supportManifestValidation) {
        foreach ($coverageEntry in @($supportManifestValidation.ClaimedCommandCoverage)) {
            $normalizedClaimedCommandCoverage[(Normalize-CommandText -CommandText ([string]$coverageEntry.command))] = @($coverageEntry.log_refs)
        }
    }

    Assert-NoProhibitedClaimFragments -TextValues @(
        [string]$summary.exact_replay_scope,
        [string]$summary.proved_scope,
        [string]$summary.unproved_scope,
        [string]$summary.notes,
        (Get-Content -LiteralPath $replaySummaryMarkdownPath -Raw),
        (Get-Content -LiteralPath $closeoutReviewPath -Raw)
    ) -Fragments @($contract.prohibited_claim_fragments) -Context "Proof-review summary package"

    if (-not ([string](Get-RequiredProperty -Object $selectionScope -Name "scope_statement" -Context "Proof selection scope")).StartsWith("Exact replay scope:")) {
        throw "Proof selection scope must preserve the exact replay scope wording."
    }
    if (-not ([string](Get-RequiredProperty -Object $selectionScope -Name "closeout_scope_statement" -Context "Proof selection scope")).StartsWith("Exact closeout scope:")) {
        throw "Proof selection scope must preserve the exact closeout scope wording."
    }

    Assert-RequiredObjectFields -Object $artifactRefs -FieldNames @("continuity_proof_refs", "rollback_proof_refs", "repo_truth_refs") -Context "Authoritative artifact refs"
    Assert-RequiredObjectFields -Object $artifactRefs.continuity_proof_refs -FieldNames @("fault_event_ref", "checkpoint_ref", "handoff_packet_ref", "resume_request_ref", "resume_result_ref", "continuity_ledger_ref") -Context "Authoritative artifact continuity refs"
    Assert-RequiredObjectFields -Object $artifactRefs.rollback_proof_refs -FieldNames @("rollback_plan_request_ref", "rollback_plan_ref", "rollback_drill_authorization_ref", "rollback_drill_result_ref", "review_summary_ref", "operator_packet_ref") -Context "Authoritative artifact rollback refs"
    Assert-RequiredObjectFields -Object $artifactRefs.repo_truth_refs -FieldNames @($foundation.required_authoritative_ref_fields) -Context "Authoritative artifact repo truth refs"

    foreach ($proofRef in @(
            $artifactRefs.continuity_proof_refs.fault_event_ref,
            $artifactRefs.continuity_proof_refs.checkpoint_ref,
            $artifactRefs.continuity_proof_refs.handoff_packet_ref,
            $artifactRefs.continuity_proof_refs.resume_request_ref,
            $artifactRefs.continuity_proof_refs.resume_result_ref,
            $artifactRefs.continuity_proof_refs.continuity_ledger_ref,
            $artifactRefs.rollback_proof_refs.rollback_plan_request_ref,
            $artifactRefs.rollback_proof_refs.rollback_plan_ref,
            $artifactRefs.rollback_proof_refs.rollback_drill_authorization_ref,
            $artifactRefs.rollback_proof_refs.rollback_drill_result_ref,
            $artifactRefs.rollback_proof_refs.review_summary_ref,
            $artifactRefs.rollback_proof_refs.operator_packet_ref
        )) {
        Resolve-ExistingPath -PathValue (Join-Path $packageRootPath $proofRef) -Label "Authoritative proof ref" | Out-Null
    }

    foreach ($repoTruthPath in @(
            $artifactRefs.repo_truth_refs.readme_path,
            $artifactRefs.repo_truth_refs.active_state_path,
            $artifactRefs.repo_truth_refs.kanban_path,
            $artifactRefs.repo_truth_refs.decision_log_path,
            $artifactRefs.repo_truth_refs.milestone_authority_path
        )) {
        Resolve-ExistingPath -PathValue (Join-Path $packageRootPath $repoTruthPath) -Label "Repo-truth authority path" | Out-Null
    }

    $replayedCommandsText = Get-Content -LiteralPath $replayedCommandsPath -Raw
    $replayedCommandLines = @(Get-NonEmptyFileLines -Path $replayedCommandsPath)
    foreach ($requiredCommand in @(
            "powershell -ExecutionPolicy Bypass -File tools\new_r7_fault_managed_continuity_proof_review.ps1",
            "powershell -ExecutionPolicy Bypass -File tests\test_fault_management_event.ps1",
            "powershell -ExecutionPolicy Bypass -File tests\test_milestone_continuity_artifacts.ps1",
            "powershell -ExecutionPolicy Bypass -File tests\test_milestone_continuity_resume_from_fault.ps1",
            "powershell -ExecutionPolicy Bypass -File tests\test_milestone_continuity_ledger.ps1",
            "powershell -ExecutionPolicy Bypass -File tests\test_milestone_rollback_plan.ps1",
            "powershell -ExecutionPolicy Bypass -File tests\test_milestone_rollback_drill.ps1",
            "powershell -ExecutionPolicy Bypass -File tests\test_milestone_continuity_review.ps1",
            "powershell -ExecutionPolicy Bypass -File tools\validate_milestone_continuity_proof_review.ps1",
            "powershell -ExecutionPolicy Bypass -File tests\test_r7_fault_managed_continuity_proof_review.ps1"
        )) {
        if ($replayedCommandsText -notlike ("*{0}*" -f $requiredCommand)) {
            throw "Replayed commands must include '$requiredCommand'."
        }
    }

    foreach ($replayedCommandLine in $replayedCommandLines) {
        $normalizedCommand = Normalize-CommandText -CommandText $replayedCommandLine
        if (-not $normalizedClaimedCommandCoverage.ContainsKey($normalizedCommand)) {
            throw "Claimed replay command '$replayedCommandLine' has no raw log or explicit support-log reference."
        }
    }

    return [pscustomobject]@{
        PackageRoot = $packageRootPath
        ManifestPath = $manifestPath
        SummaryPath = $summaryPath
        CloseoutPacketPath = $closeoutPacketPath
        ReplaySourcePath = $replaySourcePath
        ReplaySourceHeadCommit = $replaySource.source_head_commit
        ReplaySourceTreeId = $replaySource.source_tree_id
        SupportManifestPath = $(if ($null -ne $supportManifestValidation) { $supportManifestValidation.SupportManifestPath } else { $null })
    }
}

function Invoke-MilestoneContinuityProofReviewFlow {
    [CmdletBinding()]
    param(
        [string]$RepositoryRoot = (Get-RepositoryRoot),
        [string]$OutputRoot = "state/proof_reviews/r7_fault_managed_continuity_and_rollback_drill",
        [string]$ScenarioId = "r7-fault-managed-continuity-and-rollback-drill-proof-001"
    )

    $repositoryRootPath = Resolve-ExistingPath -PathValue $RepositoryRoot -Label "Repository root"
    $foundation = Get-MilestoneContinuityFoundationContract
    $evidence = Test-R7CommittedEvidence -RepositoryRoot $repositoryRootPath
    $outputRootPath = Resolve-PathValue -PathValue $OutputRoot -AnchorPath $repositoryRootPath
    if (Test-Path -LiteralPath $outputRootPath) {
        throw "Proof-review output root '$outputRootPath' already exists."
    }

    $summaryId = "summary-r7-fault-managed-continuity-and-rollback-drill-proof-001"
    $closeoutPacketId = "closeout-packet-r7-fault-managed-continuity-and-rollback-drill-proof-001"
    $generatedAtUtc = Get-UtcTimestamp
    $sourceBranch = Get-GitBranchName -RepositoryRoot $repositoryRootPath
    $sourceHeadCommit = Get-GitHeadCommit -RepositoryRoot $repositoryRootPath
    $sourceTreeId = Get-GitTreeId -RepositoryRoot $repositoryRootPath

    $stepLogPath = Join-Path $outputRootPath "raw_logs\replay_steps.log"
    $eventLogPath = Join-Path $outputRootPath "raw_logs\replay_events.jsonl"
    $success = $false

    try {
        foreach ($directoryPath in @(
                $outputRootPath,
                (Join-Path $outputRootPath "artifacts\summary\summaries"),
                (Join-Path $outputRootPath "artifacts\closeout\closeout_packets"),
                (Join-Path $outputRootPath "meta"),
                (Join-Path $outputRootPath "raw_logs\tests")
            )) {
            New-Item -ItemType Directory -Path $directoryPath -Force | Out-Null
        }

        Write-StepLog -StepLogPath $stepLogPath -Message "Validated committed R7-002 through R7-008 evidence."
        Write-EventLog -EventLogPath $eventLogPath -EventType "evidence_validated" -Data ([pscustomobject]@{
                cycle_id = $evidence.CycleId
                milestone_id = $evidence.MilestoneId
                repository_name = $evidence.RepositoryName
            })

        $commandResults = @()
        $rawLogRefs = @(
            "raw_logs/replay_steps.log",
            "raw_logs/replay_events.jsonl"
        )

        foreach ($commandDefinition in @(Get-R7ReplayCommandDefinitions -RepositoryRoot $repositoryRootPath)) {
            $logPath = Join-Path $outputRootPath ("raw_logs\tests\{0}" -f $commandDefinition.LogName)
            $commandResult = Invoke-LoggedPowerShellScript -RepositoryRoot $repositoryRootPath -RelativeScript $commandDefinition.RelativeScript -LogPath $logPath -CommandId $commandDefinition.CommandId -StepLogPath $stepLogPath -EventLogPath $eventLogPath
            $commandResult.log_ref = Get-RelativeReference -BaseDirectory $outputRootPath -TargetPath $logPath
            $commandResults += $commandResult
            $rawLogRefs += $commandResult.log_ref
        }

        $relativeFaultEventPath = Get-RelativePathFromRoot -Root $repositoryRootPath -Path $evidence.InputPaths.FaultEventPath
        $relativeOperatorPacketPath = Get-RelativePathFromRoot -Root $repositoryRootPath -Path $evidence.InputPaths.OperatorPacketPath
        $scopeStatements = Get-R7ScopeStatements -Evidence $evidence -RelativeFaultEventPath $relativeFaultEventPath -RelativeOperatorPacketPath $relativeOperatorPacketPath
        $nonClaims = @(Get-R7CloseoutNonClaims)

        $artifactRefs = [pscustomobject]@{
            continuity_proof_refs = [pscustomobject]@{
                fault_event_ref = Get-RelativeReference -BaseDirectory $outputRootPath -TargetPath $evidence.InputPaths.FaultEventPath
                checkpoint_ref = Get-RelativeReference -BaseDirectory $outputRootPath -TargetPath $evidence.InputPaths.CheckpointPath
                handoff_packet_ref = Get-RelativeReference -BaseDirectory $outputRootPath -TargetPath $evidence.InputPaths.HandoffPath
                resume_request_ref = Get-RelativeReference -BaseDirectory $outputRootPath -TargetPath $evidence.InputPaths.ResumeRequestPath
                resume_result_ref = Get-RelativeReference -BaseDirectory $outputRootPath -TargetPath $evidence.InputPaths.ResumeResultPath
                continuity_ledger_ref = Get-RelativeReference -BaseDirectory $outputRootPath -TargetPath $evidence.InputPaths.LedgerPath
            }
            rollback_proof_refs = [pscustomobject]@{
                rollback_plan_request_ref = Get-RelativeReference -BaseDirectory $outputRootPath -TargetPath $evidence.InputPaths.RollbackPlanRequestPath
                rollback_plan_ref = Get-RelativeReference -BaseDirectory $outputRootPath -TargetPath $evidence.InputPaths.RollbackPlanPath
                rollback_drill_authorization_ref = Get-RelativeReference -BaseDirectory $outputRootPath -TargetPath $evidence.InputPaths.RollbackDrillAuthorizationPath
                rollback_drill_result_ref = Get-RelativeReference -BaseDirectory $outputRootPath -TargetPath $evidence.InputPaths.RollbackDrillResultPath
                review_summary_ref = Get-RelativeReference -BaseDirectory $outputRootPath -TargetPath $evidence.InputPaths.ReviewSummaryPath
                operator_packet_ref = Get-RelativeReference -BaseDirectory $outputRootPath -TargetPath $evidence.InputPaths.OperatorPacketPath
            }
            repo_truth_refs = [pscustomobject]@{
                readme_path = Get-RelativeReference -BaseDirectory $outputRootPath -TargetPath (Join-Path $repositoryRootPath "README.md")
                active_state_path = Get-RelativeReference -BaseDirectory $outputRootPath -TargetPath (Join-Path $repositoryRootPath "governance\ACTIVE_STATE.md")
                kanban_path = Get-RelativeReference -BaseDirectory $outputRootPath -TargetPath (Join-Path $repositoryRootPath "execution\KANBAN.md")
                decision_log_path = Get-RelativeReference -BaseDirectory $outputRootPath -TargetPath (Join-Path $repositoryRootPath "governance\DECISION_LOG.md")
                milestone_authority_path = Get-RelativeReference -BaseDirectory $outputRootPath -TargetPath (Join-Path $repositoryRootPath "governance\R7_FAULT_MANAGED_CONTINUITY_AND_ROLLBACK_DRILL.md")
            }
        }
        $artifactRefsPath = Join-Path $outputRootPath "meta\authoritative_artifact_refs.json"
        Write-JsonDocument -Path $artifactRefsPath -Document $artifactRefs

        $nonClaimsPath = Join-Path $outputRootPath "meta\non_claims.json"
        Write-JsonDocument -Path $nonClaimsPath -Document @($nonClaims)

        $selectionScope = [pscustomobject]@{
            scenario_id = $ScenarioId
            cycle_id = $evidence.CycleId
            scope_statement = $scopeStatements.ReplayScope
            closeout_scope_statement = $scopeStatements.CloseoutScope
            replay_chain = @(
                "fault_event",
                "continuity_checkpoint",
                "continuity_handoff_packet",
                "resume_from_fault_request",
                "resume_from_fault_result",
                "continuity_ledger",
                "rollback_plan_request",
                "rollback_plan",
                "rollback_drill_authorization",
                "rollback_drill_result",
                "review_summary",
                "operator_packet",
                "proof_review_summary",
                "closeout_packet"
            )
            selected_command_ids = @($commandResults | ForEach-Object { $_.command_id })
            notes = "Selection scope records the exact committed R7-002 through R7-008 evidence chain replayed for one interrupted-and-resumed supervised cycle plus one safe rollback drill packet only."
        }
        $selectionScopePath = Join-Path $outputRootPath "meta\proof_selection_scope.json"
        Write-JsonDocument -Path $selectionScopePath -Document $selectionScope

        $replaySource = [pscustomobject]@{
            scenario_id = $ScenarioId
            cycle_id = $evidence.CycleId
            repository_root_relative = "."
            branch = $sourceBranch
            source_head_commit = $sourceHeadCommit
            source_tree_id = $sourceTreeId
            generated_by_script = "tools/new_r7_fault_managed_continuity_proof_review.ps1"
            generated_at_utc = $generatedAtUtc
        }
        $replaySourcePath = Join-Path $outputRootPath "meta\replay_source.json"
        Write-JsonDocument -Path $replaySourcePath -Document $replaySource

        $summary = [pscustomobject]@{
            summary_id = $summaryId
            scenario_id = $ScenarioId
            cycle_id = $evidence.CycleId
            repository = [pscustomobject]@{
                repository_name = $evidence.RepositoryName
            }
            continuity_identity = [pscustomobject]@{
                task_id = $evidence.TaskId
                interrupted_segment_id = $evidence.InterruptedSegmentId
                successor_segment_id = $evidence.SuccessorSegmentId
                fault_event_id = $evidence.FaultEvent.event_id
                checkpoint_id = $evidence.Checkpoint.checkpoint_id
                handoff_id = $evidence.Handoff.handoff_id
                resume_request_id = $evidence.ResumeRequest.resume_request_id
                resume_result_id = $evidence.ResumeResult.resume_result_id
                ledger_id = $evidence.LedgerId
            }
            rollback_identity = [pscustomobject]@{
                rollback_plan_request_id = $evidence.RollbackPlanRequestId
                rollback_plan_id = $evidence.RollbackPlanId
                rollback_drill_authorization_id = $evidence.RollbackAuthorizationId
                rollback_drill_id = $evidence.RollbackDrillId
                review_summary_id = $evidence.ReviewSummaryId
                operator_packet_id = $evidence.OperatorPacketId
            }
            replay_source = [pscustomobject]@{
                branch = $sourceBranch
                head_commit = $sourceHeadCommit
                tree_id = $sourceTreeId
            }
            command_results = @($commandResults)
            exact_replay_scope = $scopeStatements.ReplayScope
            proved_scope = $scopeStatements.ProvedScope
            unproved_scope = $scopeStatements.UnprovedScope
            notes = "Proof-review summary records exact command-level replay results for the committed R7 evidence chain only."
        }
        $summaryPath = Join-Path $outputRootPath "artifacts\summary\summaries\summary-r7-fault-managed-continuity-and-rollback-drill-proof-001.json"
        Write-JsonDocument -Path $summaryPath -Document $summary

        $closeoutPacketDirectory = Join-Path $outputRootPath "artifacts\closeout\closeout_packets"
        $closeoutPacket = [pscustomobject]@{
            contract_version = $foundation.contract_version
            record_type = $foundation.closeout_packet_record_type
            closeout_packet_id = $closeoutPacketId
            scenario_id = $ScenarioId
            cycle_context = [pscustomobject]@{
                cycle_id = $evidence.CycleId
                milestone_id = $evidence.MilestoneId
                milestone_title = $evidence.FaultEvent.cycle_context.milestone_title
            }
            repository = [pscustomobject]@{
                repository_name = $evidence.RepositoryName
            }
            replay_source = [pscustomobject]@{
                branch = $sourceBranch
                head_commit = $sourceHeadCommit
                tree_id = $sourceTreeId
            }
            continuity_identity = [pscustomobject]@{
                task_id = $evidence.TaskId
                interrupted_segment_id = $evidence.InterruptedSegmentId
                successor_segment_id = $evidence.SuccessorSegmentId
                fault_event_id = $evidence.FaultEvent.event_id
                checkpoint_id = $evidence.Checkpoint.checkpoint_id
                handoff_id = $evidence.Handoff.handoff_id
                resume_request_id = $evidence.ResumeRequest.resume_request_id
                resume_result_id = $evidence.ResumeResult.resume_result_id
                ledger_id = $evidence.LedgerId
            }
            rollback_identity = [pscustomobject]@{
                rollback_plan_request_id = $evidence.RollbackPlanRequestId
                rollback_plan_id = $evidence.RollbackPlanId
                rollback_drill_authorization_id = $evidence.RollbackAuthorizationId
                rollback_drill_id = $evidence.RollbackDrillId
                review_summary_id = $evidence.ReviewSummaryId
                operator_packet_id = $evidence.OperatorPacketId
            }
            summary_ref = Get-RelativeReference -BaseDirectory $closeoutPacketDirectory -TargetPath $summaryPath
            summary_id = $summaryId
            proof_selection_scope_ref = Get-RelativeReference -BaseDirectory $closeoutPacketDirectory -TargetPath $selectionScopePath
            authoritative_refs = [pscustomobject]@{
                continuity_proof_refs = [pscustomobject]@{
                    fault_event_ref = Get-RelativeReference -BaseDirectory $closeoutPacketDirectory -TargetPath $evidence.InputPaths.FaultEventPath
                    checkpoint_ref = Get-RelativeReference -BaseDirectory $closeoutPacketDirectory -TargetPath $evidence.InputPaths.CheckpointPath
                    handoff_packet_ref = Get-RelativeReference -BaseDirectory $closeoutPacketDirectory -TargetPath $evidence.InputPaths.HandoffPath
                    resume_request_ref = Get-RelativeReference -BaseDirectory $closeoutPacketDirectory -TargetPath $evidence.InputPaths.ResumeRequestPath
                    resume_result_ref = Get-RelativeReference -BaseDirectory $closeoutPacketDirectory -TargetPath $evidence.InputPaths.ResumeResultPath
                    continuity_ledger_ref = Get-RelativeReference -BaseDirectory $closeoutPacketDirectory -TargetPath $evidence.InputPaths.LedgerPath
                }
                rollback_proof_refs = [pscustomobject]@{
                    rollback_plan_request_ref = Get-RelativeReference -BaseDirectory $closeoutPacketDirectory -TargetPath $evidence.InputPaths.RollbackPlanRequestPath
                    rollback_plan_ref = Get-RelativeReference -BaseDirectory $closeoutPacketDirectory -TargetPath $evidence.InputPaths.RollbackPlanPath
                    rollback_drill_authorization_ref = Get-RelativeReference -BaseDirectory $closeoutPacketDirectory -TargetPath $evidence.InputPaths.RollbackDrillAuthorizationPath
                    rollback_drill_result_ref = Get-RelativeReference -BaseDirectory $closeoutPacketDirectory -TargetPath $evidence.InputPaths.RollbackDrillResultPath
                    review_summary_ref = Get-RelativeReference -BaseDirectory $closeoutPacketDirectory -TargetPath $evidence.InputPaths.ReviewSummaryPath
                    operator_packet_ref = Get-RelativeReference -BaseDirectory $closeoutPacketDirectory -TargetPath $evidence.InputPaths.OperatorPacketPath
                }
                repo_truth_refs = [pscustomobject]@{
                    readme_path = Get-RelativeReference -BaseDirectory $closeoutPacketDirectory -TargetPath (Join-Path $repositoryRootPath "README.md")
                    active_state_path = Get-RelativeReference -BaseDirectory $closeoutPacketDirectory -TargetPath (Join-Path $repositoryRootPath "governance\ACTIVE_STATE.md")
                    kanban_path = Get-RelativeReference -BaseDirectory $closeoutPacketDirectory -TargetPath (Join-Path $repositoryRootPath "execution\KANBAN.md")
                    decision_log_path = Get-RelativeReference -BaseDirectory $closeoutPacketDirectory -TargetPath (Join-Path $repositoryRootPath "governance\DECISION_LOG.md")
                    milestone_authority_path = Get-RelativeReference -BaseDirectory $closeoutPacketDirectory -TargetPath (Join-Path $repositoryRootPath "governance\R7_FAULT_MANAGED_CONTINUITY_AND_ROLLBACK_DRILL.md")
                }
            }
            operator_decision_state = "advisory_only_not_executed"
            exact_replay_scope = $scopeStatements.ReplayScope
            closeout_scope = $scopeStatements.CloseoutScope
            proved_scope = $scopeStatements.ProvedScope
            unproved_scope = $scopeStatements.UnprovedScope
            out_of_scope = $scopeStatements.OutOfScope
            automatic_execution_implied = $false
            destructive_primary_worktree_rollback_implied = $false
            non_claims = @($nonClaims)
            notes = "Closeout packet remains bounded to one replayable interrupted-and-resumed supervised continuity path plus one safe rollback drill packet only."
        }
        $closeoutPacketPath = Join-Path $outputRootPath "artifacts\closeout\closeout_packets\closeout-packet-r7-fault-managed-continuity-and-rollback-drill-proof-001.json"
        Write-JsonDocument -Path $closeoutPacketPath -Document $closeoutPacket

        $replayedCommandsPath = Join-Path $outputRootPath "meta\replayed_commands.txt"
        $replayedCommands = @(
            ("powershell -ExecutionPolicy Bypass -File tools\new_r7_fault_managed_continuity_proof_review.ps1 -OutputRoot {0}" -f (Get-RelativePathFromRoot -Root $repositoryRootPath -Path $outputRootPath))
        ) + @($commandResults | ForEach-Object { $_.command -replace " -NoProfile", "" }) + @(
            ("powershell -ExecutionPolicy Bypass -File tools\validate_milestone_continuity_proof_review.ps1 -PackageRoot {0}" -f (Get-RelativePathFromRoot -Root $repositoryRootPath -Path $outputRootPath)),
            "powershell -ExecutionPolicy Bypass -File tests\test_r7_fault_managed_continuity_proof_review.ps1"
        )
        Write-Utf8File -Path $replayedCommandsPath -Value ($replayedCommands -join [Environment]::NewLine)

        $replaySummaryPath = Join-Path $outputRootPath "REPLAY_SUMMARY.md"
        $replaySummaryLines = @(
            "# R7 Fault-Managed Continuity And Rollback Drill Replay Summary",
            "",
            "## Exact Replay Scope",
            $scopeStatements.ReplayScope,
            "",
            "## Replay Source Metadata",
            ("- Branch: {0}" -f $sourceBranch),
            ("- Replay source head: {0}" -f $sourceHeadCommit),
            ("- Replay source tree: {0}" -f $sourceTreeId),
            ("- Replay command: powershell -ExecutionPolicy Bypass -File tools\new_r7_fault_managed_continuity_proof_review.ps1 -OutputRoot {0}" -f (Get-RelativePathFromRoot -Root $repositoryRootPath -Path $outputRootPath)),
            "",
            "## Authoritative Artifact Lineage",
            ("- Fault event: {0}" -f (Get-RelativePathFromRoot -Root $repositoryRootPath -Path $evidence.InputPaths.FaultEventPath)),
            ("- Checkpoint: {0}" -f (Get-RelativePathFromRoot -Root $repositoryRootPath -Path $evidence.InputPaths.CheckpointPath)),
            ("- Handoff packet: {0}" -f (Get-RelativePathFromRoot -Root $repositoryRootPath -Path $evidence.InputPaths.HandoffPath)),
            ("- Resume request: {0}" -f (Get-RelativePathFromRoot -Root $repositoryRootPath -Path $evidence.InputPaths.ResumeRequestPath)),
            ("- Resume result: {0}" -f (Get-RelativePathFromRoot -Root $repositoryRootPath -Path $evidence.InputPaths.ResumeResultPath)),
            ("- Continuity ledger: {0}" -f (Get-RelativePathFromRoot -Root $repositoryRootPath -Path $evidence.InputPaths.LedgerPath)),
            ("- Rollback plan request: {0}" -f (Get-RelativePathFromRoot -Root $repositoryRootPath -Path $evidence.InputPaths.RollbackPlanRequestPath)),
            ("- Rollback plan: {0}" -f (Get-RelativePathFromRoot -Root $repositoryRootPath -Path $evidence.InputPaths.RollbackPlanPath)),
            ("- Rollback drill authorization: {0}" -f (Get-RelativePathFromRoot -Root $repositoryRootPath -Path $evidence.InputPaths.RollbackDrillAuthorizationPath)),
            ("- Rollback drill result: {0}" -f (Get-RelativePathFromRoot -Root $repositoryRootPath -Path $evidence.InputPaths.RollbackDrillResultPath)),
            ("- Review summary: {0}" -f (Get-RelativePathFromRoot -Root $repositoryRootPath -Path $evidence.InputPaths.ReviewSummaryPath)),
            ("- Operator packet: {0}" -f (Get-RelativePathFromRoot -Root $repositoryRootPath -Path $evidence.InputPaths.OperatorPacketPath)),
            ("- Proof-review summary: {0}" -f (Get-RelativePathFromRoot -Root $repositoryRootPath -Path $summaryPath)),
            ("- Closeout packet: {0}" -f (Get-RelativePathFromRoot -Root $repositoryRootPath -Path $closeoutPacketPath)),
            "",
            "## Raw Logs"
        ) + @($rawLogRefs | ForEach-Object { "- $($_)" }) + @(
            "",
            "## Explicit Non-Claims"
        ) + @($nonClaims | ForEach-Object { "- $($_ -replace '_', ' ')" }) + @(
            "",
            "## Advisory Operator Decision State",
            "- The advisory operator packet remains unexecuted in this closeout packet."
        )
        Write-Utf8File -Path $replaySummaryPath -Value ($replaySummaryLines -join [Environment]::NewLine)

        $closeoutReviewPath = Join-Path $outputRootPath "CLOSEOUT_REVIEW.md"
        $closeoutReviewLines = @(
            "# R7 Fault-Managed Continuity And Rollback Drill Closeout Review",
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
            "- The advisory-only operator packet remains manual and unexecuted in this closeout.",
            "",
            "## Explicit Non-Claims"
        ) + @($nonClaims | ForEach-Object { "- $($_ -replace '_', ' ')" })
        Write-Utf8File -Path $closeoutReviewPath -Value ($closeoutReviewLines -join [Environment]::NewLine)

        $manifest = [pscustomobject]@{
            package_version = $foundation.contract_version
            package_type = $foundation.proof_review_package_type
            scenario_id = $ScenarioId
            cycle_id = $evidence.CycleId
            summary_ref = Get-RelativeReference -BaseDirectory $outputRootPath -TargetPath $summaryPath
            closeout_packet_ref = Get-RelativeReference -BaseDirectory $outputRootPath -TargetPath $closeoutPacketPath
            selection_scope_ref = Get-RelativeReference -BaseDirectory $outputRootPath -TargetPath $selectionScopePath
            replay_source_ref = Get-RelativeReference -BaseDirectory $outputRootPath -TargetPath $replaySourcePath
            replay_commands_ref = Get-RelativeReference -BaseDirectory $outputRootPath -TargetPath $replayedCommandsPath
            authoritative_artifact_refs_ref = Get-RelativeReference -BaseDirectory $outputRootPath -TargetPath $artifactRefsPath
            non_claims_ref = Get-RelativeReference -BaseDirectory $outputRootPath -TargetPath $nonClaimsPath
            replay_summary_ref = Get-RelativeReference -BaseDirectory $outputRootPath -TargetPath $replaySummaryPath
            closeout_review_ref = Get-RelativeReference -BaseDirectory $outputRootPath -TargetPath $closeoutReviewPath
            raw_log_refs = @($rawLogRefs)
            notes = "Committed proof-review package for the exact R7 interrupted-and-resumed supervised continuity replay plus one safe rollback drill packet from committed R7-002 through R7-008 evidence only."
        }
        $manifestPath = Join-Path $outputRootPath "proof_review_manifest.json"
        Write-JsonDocument -Path $manifestPath -Document $manifest

        $validation = Test-MilestoneContinuityProofReviewPackage -PackageRoot $outputRootPath
        Write-StepLog -StepLogPath $stepLogPath -Message "Proof-review package validated successfully."
        Write-EventLog -EventLogPath $eventLogPath -EventType "proof_review_completed" -Data ([pscustomobject]@{
                package_root = (Get-RelativePathFromRoot -Root $repositoryRootPath -Path $outputRootPath)
                replay_source_head = $sourceHeadCommit
                replay_source_tree = $sourceTreeId
            })

        $success = $true
        return [pscustomobject]@{
            PackageRoot = $validation.PackageRoot
            ManifestPath = $validation.ManifestPath
            SummaryPath = $validation.SummaryPath
            CloseoutPacketPath = $validation.CloseoutPacketPath
            ReplaySourceHeadCommit = $validation.ReplaySourceHeadCommit
            ReplaySourceTreeId = $validation.ReplaySourceTreeId
        }
    }
    finally {
        if (-not $success -and (Test-Path -LiteralPath $outputRootPath)) {
            Remove-Item -LiteralPath $outputRootPath -Recurse -Force
        }
    }
}

Export-ModuleMember -Function Invoke-MilestoneContinuityProofReviewFlow, Test-MilestoneContinuityProofReviewPackage, Test-MilestoneContinuityCloseoutPacketContract, Test-MilestoneContinuityCloseoutPacketObject
