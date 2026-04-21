Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$workArtifactValidationModule = Import-Module (Join-Path $PSScriptRoot "WorkArtifactValidation.psm1") -Force -PassThru
$batonPersistenceModule = Import-Module (Join-Path $PSScriptRoot "BatonPersistence.psm1") -Force -PassThru
$restoreGateModule = Import-Module (Join-Path $PSScriptRoot "RestoreGate.psm1") -Force -PassThru
$milestoneBaselineModule = Import-Module (Join-Path $PSScriptRoot "MilestoneBaseline.psm1") -Force -PassThru

$testWorkArtifactContract = $workArtifactValidationModule.ExportedCommands["Test-WorkArtifactContract"]
$testBatonRecordContract = $batonPersistenceModule.ExportedCommands["Test-BatonRecordContract"]
$testRestoreGateResultContract = $restoreGateModule.ExportedCommands["Test-RestoreGateResultContract"]
$testMilestoneBaselineRecordContract = $milestoneBaselineModule.ExportedCommands["Test-MilestoneBaselineRecordContract"]

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

function Assert-NullableString {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($null -eq $Value) {
        return $null
    }

    return (Assert-NonEmptyString -Value $Value -Context $Context)
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

function Assert-IntegerValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -is [int]) {
        return $Value
    }

    if ($Value -is [long] -and $Value -ge [int]::MinValue -and $Value -le [int]::MaxValue) {
        return [int]$Value
    }

    throw "$Context must be an integer."
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
        [string]$BaseDirectory,
        [Parameter(Mandatory = $true)]
        [string]$Reference
    )

    if ([System.IO.Path]::IsPathRooted($Reference)) {
        return (Get-RelativeReference -BaseDirectory $BaseDirectory -TargetPath $Reference)
    }

    $candidate = Join-Path $BaseDirectory ($Reference -replace "[/\\]", [System.IO.Path]::DirectorySeparatorChar)
    if (Test-Path -LiteralPath $candidate) {
        return $Reference.Replace("\", "/")
    }

    return $Reference.Replace("\", "/")
}

function Get-NormalizedNullableReferenceForSave {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory,
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Reference
    )

    if ([string]::IsNullOrWhiteSpace($Reference)) {
        return $null
    }

    return (Get-NormalizedReferenceForSave -BaseDirectory $BaseDirectory -Reference $Reference)
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
        throw "Unable to resolve $Label for resume re-entry."
    }

    return $value
}

function Get-GitBranchName {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $branch = (Get-GitValue -RepositoryRoot $RepositoryRoot -Arguments @("branch", "--show-current") -Label "Git branch").Trim()
    if ([string]::IsNullOrWhiteSpace($branch)) {
        throw "Resume re-entry requires a non-empty Git branch."
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
        throw "Resume re-entry requires a non-empty Git HEAD commit."
    }

    return $head
}

function Get-GitStatusLines {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $statusOutput = & git -C $RepositoryRoot status --short --untracked-files=all 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to resolve Git status for resume re-entry."
    }

    return @($statusOutput | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function New-BlockReason {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Code,
        [Parameter(Mandatory = $true)]
        [string]$Summary
    )

    return [pscustomobject]@{
        code    = $Code
        summary = $Summary
    }
}

function Add-UniqueBlockReason {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.ArrayList]$Reasons,
        [Parameter(Mandatory = $true)]
        [string]$Code,
        [Parameter(Mandatory = $true)]
        [string]$Summary
    )

    $existing = @($Reasons | Where-Object { $_.code -eq $Code -and $_.summary -eq $Summary })
    if ($existing.Count -eq 0) {
        [void]$Reasons.Add((New-BlockReason -Code $Code -Summary $Summary))
    }
}

function Get-ResumeReentryFoundationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\resume_reentry\foundation.contract.json") -Label "Resume re-entry foundation contract"
}

function Get-ResumeReentryRequestContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\resume_reentry\request.contract.json") -Label "Resume re-entry request contract"
}

function Get-ResumeReentryResultContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\resume_reentry\result.contract.json") -Label "Resume re-entry result contract"
}

function Validate-RequestFields {
    param(
        [Parameter(Mandatory = $true)]
        $Request
    )

    $foundation = Get-ResumeReentryFoundationContract
    $requestContract = Get-ResumeReentryRequestContract

    foreach ($fieldName in $foundation.request_required_fields) {
        Get-RequiredProperty -Object $Request -Name $fieldName -Context "Resume re-entry request" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Request -Name "contract_version" -Context "Resume re-entry request") -Context "Resume re-entry request.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "Resume re-entry request.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Request -Name "record_type" -Context "Resume re-entry request") -Context "Resume re-entry request.record_type"
    if ($recordType -ne $foundation.request_record_type -or $recordType -ne $requestContract.record_type) {
        throw "Resume re-entry request.record_type must equal '$($foundation.request_record_type)'."
    }

    $resumeRequestId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Request -Name "resume_request_id" -Context "Resume re-entry request") -Context "Resume re-entry request.resume_request_id"
    Assert-RegexMatch -Value $resumeRequestId -Pattern $foundation.identifier_pattern -Context "Resume re-entry request.resume_request_id"
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Request -Name "baton_ref" -Context "Resume re-entry request") -Context "Resume re-entry request.baton_ref" | Out-Null
    $operatorId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Request -Name "operator_id" -Context "Resume re-entry request") -Context "Resume re-entry request.operator_id"
    Assert-RegexMatch -Value $operatorId -Pattern $foundation.operator_pattern -Context "Resume re-entry request.operator_id"
    $requestedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Request -Name "requested_at" -Context "Resume re-entry request") -Context "Resume re-entry request.requested_at"
    Assert-RegexMatch -Value $requestedAt -Pattern $foundation.timestamp_pattern -Context "Resume re-entry request.requested_at"
    $reentryKind = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Request -Name "reentry_kind" -Context "Resume re-entry request") -Context "Resume re-entry request.reentry_kind"
    Assert-AllowedValue -Value $reentryKind -AllowedValues @($foundation.allowed_reentry_kinds) -Context "Resume re-entry request.reentry_kind"
    Assert-NullableString -Value (Get-RequiredProperty -Object $Request -Name "baseline_ref" -Context "Resume re-entry request") -Context "Resume re-entry request.baseline_ref" | Out-Null
    Assert-NullableString -Value (Get-RequiredProperty -Object $Request -Name "restore_result_ref" -Context "Resume re-entry request") -Context "Resume re-entry request.restore_result_ref" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Request -Name "notes" -Context "Resume re-entry request") -Context "Resume re-entry request.notes" | Out-Null

    return [pscustomobject]@{
        ResumeRequestId = $resumeRequestId
    }
}

function Test-ResumeReentryRequestContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResumeRequestPath
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $ResumeRequestPath -Label "Resume re-entry request"
    $request = Get-JsonDocument -Path $resolvedPath -Label "Resume re-entry request"
    $result = Validate-RequestFields -Request $request

    return [pscustomobject]@{
        IsValid           = $true
        ResumeRequestId   = $result.ResumeRequestId
        ResumeRequestPath = $resolvedPath
    }
}

function Validate-ResultFields {
    param(
        [Parameter(Mandatory = $true)]
        $Result,
        [string]$BaseDirectory
    )

    $foundation = Get-ResumeReentryFoundationContract
    $resultContract = Get-ResumeReentryResultContract

    foreach ($fieldName in $foundation.result_required_fields) {
        Get-RequiredProperty -Object $Result -Name $fieldName -Context "Resume re-entry result" | Out-Null
    }

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "contract_version" -Context "Resume re-entry result") -Context "Resume re-entry result.contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "Resume re-entry result.contract_version must equal '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "record_type" -Context "Resume re-entry result") -Context "Resume re-entry result.record_type"
    if ($recordType -ne $foundation.result_record_type -or $recordType -ne $resultContract.record_type) {
        throw "Resume re-entry result.record_type must equal '$($foundation.result_record_type)'."
    }

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "resume_result_id" -Context "Resume re-entry result") -Context "Resume re-entry result.resume_result_id" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "resume_request_id" -Context "Resume re-entry result") -Context "Resume re-entry result.resume_request_id" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "baton_ref" -Context "Resume re-entry result") -Context "Resume re-entry result.baton_ref" | Out-Null
    Assert-NullableString -Value (Get-RequiredProperty -Object $Result -Name "baseline_ref" -Context "Resume re-entry result") -Context "Resume re-entry result.baseline_ref" | Out-Null
    Assert-NullableString -Value (Get-RequiredProperty -Object $Result -Name "restore_result_ref" -Context "Resume re-entry result") -Context "Resume re-entry result.restore_result_ref" | Out-Null
    $requestedBy = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "requested_by" -Context "Resume re-entry result") -Context "Resume re-entry result.requested_by"
    Assert-RegexMatch -Value $requestedBy -Pattern $foundation.operator_pattern -Context "Resume re-entry result.requested_by"
    $decidedAt = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "decided_at" -Context "Resume re-entry result") -Context "Resume re-entry result.decided_at"
    Assert-RegexMatch -Value $decidedAt -Pattern $foundation.timestamp_pattern -Context "Resume re-entry result.decided_at"
    $reentryKind = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "reentry_kind" -Context "Resume re-entry result") -Context "Resume re-entry result.reentry_kind"
    Assert-AllowedValue -Value $reentryKind -AllowedValues @($foundation.allowed_reentry_kinds) -Context "Resume re-entry result.reentry_kind"
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "prior_execution_bundle_ref" -Context "Resume re-entry result") -Context "Resume re-entry result.prior_execution_bundle_ref" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "prior_qa_report_ref" -Context "Resume re-entry result") -Context "Resume re-entry result.prior_qa_report_ref" | Out-Null
    $generatedExecutionBundleRef = Assert-NullableString -Value (Get-RequiredProperty -Object $Result -Name "generated_execution_bundle_ref" -Context "Resume re-entry result") -Context "Resume re-entry result.generated_execution_bundle_ref"

    $decision = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "decision" -Context "Resume re-entry result") -Context "Resume re-entry result.decision"
    Assert-AllowedValue -Value $decision -AllowedValues @($foundation.allowed_decisions) -Context "Resume re-entry result.decision"

    $checkpoints = Assert-ObjectValue -Value (Get-RequiredProperty -Object $Result -Name "checkpoints" -Context "Resume re-entry result") -Context "Resume re-entry result.checkpoints"
    foreach ($fieldName in $foundation.checkpoint_required_fields) {
        Assert-BooleanValue -Value (Get-RequiredProperty -Object $checkpoints -Name $fieldName -Context "Resume re-entry result.checkpoints") -Context "Resume re-entry result.checkpoints.$fieldName" | Out-Null
    }

    $currentGitState = Assert-ObjectValue -Value (Get-RequiredProperty -Object $Result -Name "current_git_state" -Context "Resume re-entry result") -Context "Resume re-entry result.current_git_state"
    foreach ($fieldName in $foundation.current_git_state_required_fields) {
        Get-RequiredProperty -Object $currentGitState -Name $fieldName -Context "Resume re-entry result.current_git_state" | Out-Null
    }
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $currentGitState -Name "repository_root" -Context "Resume re-entry result.current_git_state") -Context "Resume re-entry result.current_git_state.repository_root" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $currentGitState -Name "branch" -Context "Resume re-entry result.current_git_state") -Context "Resume re-entry result.current_git_state.branch" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $currentGitState -Name "head_commit" -Context "Resume re-entry result.current_git_state") -Context "Resume re-entry result.current_git_state.head_commit" | Out-Null
    Assert-BooleanValue -Value (Get-RequiredProperty -Object $currentGitState -Name "working_tree_clean" -Context "Resume re-entry result.current_git_state") -Context "Resume re-entry result.current_git_state.working_tree_clean" | Out-Null
    Assert-StringArray -Value (Get-RequiredProperty -Object $currentGitState -Name "status_lines" -Context "Resume re-entry result.current_git_state") -Context "Resume re-entry result.current_git_state.status_lines" -AllowEmpty | Out-Null

    $blockReasons = [object[]](Assert-ObjectArray -Value (Get-RequiredProperty -Object $Result -Name "block_reasons" -Context "Resume re-entry result") -Context "Resume re-entry result.block_reasons" -AllowEmpty)
    foreach ($blockReason in $blockReasons) {
        foreach ($fieldName in $foundation.block_reason_required_fields) {
            Get-RequiredProperty -Object $blockReason -Name $fieldName -Context "Resume re-entry result.block_reasons item" | Out-Null
        }

        $reasonCode = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $blockReason -Name "code" -Context "Resume re-entry result.block_reasons item") -Context "Resume re-entry result.block_reasons item.code"
        Assert-AllowedValue -Value $reasonCode -AllowedValues @($foundation.allowed_reason_codes) -Context "Resume re-entry result.block_reasons item.code"
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $blockReason -Name "summary" -Context "Resume re-entry result.block_reasons item") -Context "Resume re-entry result.block_reasons item.summary" | Out-Null
    }

    if ($resultContract.decision_rules.allow_requires_generated_execution_bundle_ref -and $decision -eq "allow" -and $null -eq $generatedExecutionBundleRef) {
        throw "Resume re-entry allow decisions must include a generated_execution_bundle_ref."
    }
    if ($resultContract.decision_rules.allow_requires_no_block_reasons -and $decision -eq "allow" -and $blockReasons.Count -ne 0) {
        throw "Resume re-entry allow decisions must not include block reasons."
    }
    if ($resultContract.decision_rules.blocked_requires_block_reasons -and $decision -eq "blocked" -and $blockReasons.Count -eq 0) {
        throw "Resume re-entry blocked decisions must include at least one block reason."
    }
    if ($resultContract.decision_rules.blocked_forbids_generated_execution_bundle_ref -and $decision -eq "blocked" -and $null -ne $generatedExecutionBundleRef) {
        throw "Resume re-entry blocked decisions must not include a generated_execution_bundle_ref."
    }

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Result -Name "notes" -Context "Resume re-entry result") -Context "Resume re-entry result.notes" | Out-Null

    if (-not [string]::IsNullOrWhiteSpace($BaseDirectory)) {
        $resolvedBatonPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference $Result.baton_ref -Label "Resume re-entry baton"
        & $testBatonRecordContract -BatonPath $resolvedBatonPath | Out-Null

        $resolvedPriorExecutionBundlePath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference $Result.prior_execution_bundle_ref -Label "Resume re-entry prior Execution Bundle"
        $priorExecutionBundleValidation = & $testWorkArtifactContract -ArtifactPath $resolvedPriorExecutionBundlePath
        if ($priorExecutionBundleValidation.ArtifactType -ne "execution_bundle") {
            throw "Resume re-entry result.prior_execution_bundle_ref must resolve to an execution_bundle artifact."
        }

        $resolvedPriorQaReportPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference $Result.prior_qa_report_ref -Label "Resume re-entry prior QA Report"
        $priorQaReportValidation = & $testWorkArtifactContract -ArtifactPath $resolvedPriorQaReportPath
        if ($priorQaReportValidation.ArtifactType -ne "qa_report") {
            throw "Resume re-entry result.prior_qa_report_ref must resolve to a qa_report artifact."
        }

        if ($null -ne $Result.baseline_ref) {
            $resolvedBaselinePath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference $Result.baseline_ref -Label "Resume re-entry baseline"
            & $testMilestoneBaselineRecordContract -BaselinePath $resolvedBaselinePath | Out-Null
        }

        if ($null -ne $Result.restore_result_ref) {
            $resolvedRestoreResultPath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference $Result.restore_result_ref -Label "Resume re-entry restore result"
            & $testRestoreGateResultContract -RestoreResultPath $resolvedRestoreResultPath | Out-Null
        }

        if ($null -ne $generatedExecutionBundleRef) {
            $resolvedGeneratedExecutionBundlePath = Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference $generatedExecutionBundleRef -Label "Resume re-entry generated Execution Bundle"
            $generatedExecutionBundleValidation = & $testWorkArtifactContract -ArtifactPath $resolvedGeneratedExecutionBundlePath
            if ($generatedExecutionBundleValidation.ArtifactType -ne "execution_bundle") {
                throw "Resume re-entry result.generated_execution_bundle_ref must resolve to an execution_bundle artifact."
            }
        }
    }
}

function Test-ResumeReentryResultContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResumeResultPath
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $ResumeResultPath -Label "Resume re-entry result"
    $result = Get-JsonDocument -Path $resolvedPath -Label "Resume re-entry result"
    Validate-ResultFields -Result $result -BaseDirectory (Split-Path -Parent $resolvedPath)

    return [pscustomobject]@{
        IsValid          = $true
        ResumeResultPath = $resolvedPath
    }
}

function Get-ValidatedBatonInput {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BatonPath
    )

    $batonValidation = & $testBatonRecordContract -BatonPath $BatonPath
    $baton = Get-JsonDocument -Path $batonValidation.ArtifactPath -Label "Baton"
    $batonDirectory = Split-Path -Parent $batonValidation.ArtifactPath

    $priorExecutionBundlePath = Resolve-ReferenceAgainstBase -BaseDirectory $batonDirectory -Reference $baton.resume_context.prior_execution_bundle_ref -Label "Baton prior Execution Bundle"
    $priorExecutionBundleValidation = & $testWorkArtifactContract -ArtifactPath $priorExecutionBundlePath
    if ($priorExecutionBundleValidation.ArtifactType -ne "execution_bundle") {
        throw "Resume re-entry requires baton.resume_context.prior_execution_bundle_ref to resolve to an execution_bundle artifact."
    }

    $priorQaReportPath = Resolve-ReferenceAgainstBase -BaseDirectory $batonDirectory -Reference $baton.resume_context.prior_qa_report_ref -Label "Baton prior QA Report"
    $priorQaReportValidation = & $testWorkArtifactContract -ArtifactPath $priorQaReportPath
    if ($priorQaReportValidation.ArtifactType -ne "qa_report") {
        throw "Resume re-entry requires baton.resume_context.prior_qa_report_ref to resolve to a qa_report artifact."
    }

    $priorQaReport = Get-JsonDocument -Path $priorQaReportValidation.ArtifactPath -Label "Prior QA Report"
    $priorExecutionBundle = Get-JsonDocument -Path $priorExecutionBundleValidation.ArtifactPath -Label "Prior Execution Bundle"

    return [pscustomobject]@{
        Validation                   = $batonValidation
        Baton                        = $baton
        BatonDirectory               = $batonDirectory
        PriorExecutionBundlePath     = $priorExecutionBundleValidation.ArtifactPath
        PriorExecutionBundle         = $priorExecutionBundle
        PriorQaReportPath            = $priorQaReportValidation.ArtifactPath
        PriorQaReport                = $priorQaReport
    }
}

function Get-ValidatedBaselineInput {
    param(
        [AllowNull()]
        [string]$BaselineReference,
        [AllowNull()]
        [string]$BaseDirectory,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    if ([string]::IsNullOrWhiteSpace($BaselineReference)) {
        return $null
    }

    $baselinePath = if ([System.IO.Path]::IsPathRooted($BaselineReference) -or [string]::IsNullOrWhiteSpace($BaseDirectory)) {
        Resolve-ExistingPath -PathValue $BaselineReference -Label $Label
    }
    else {
        Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference $BaselineReference -Label $Label
    }

    $baselineValidation = & $testMilestoneBaselineRecordContract -BaselinePath $baselinePath
    $baseline = Get-JsonDocument -Path $baselineValidation.BaselinePath -Label $Label

    return [pscustomobject]@{
        Validation = $baselineValidation
        Baseline   = $baseline
        Path       = $baselineValidation.BaselinePath
    }
}

function Get-ValidatedRestoreGateInput {
    param(
        [AllowNull()]
        [string]$RestoreResultReference,
        [AllowNull()]
        [string]$BaseDirectory,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    if ([string]::IsNullOrWhiteSpace($RestoreResultReference)) {
        return $null
    }

    $restoreResultPath = if ([System.IO.Path]::IsPathRooted($RestoreResultReference) -or [string]::IsNullOrWhiteSpace($BaseDirectory)) {
        Resolve-ExistingPath -PathValue $RestoreResultReference -Label $Label
    }
    else {
        Resolve-ReferenceAgainstBase -BaseDirectory $BaseDirectory -Reference $RestoreResultReference -Label $Label
    }

    & $testRestoreGateResultContract -RestoreResultPath $restoreResultPath | Out-Null
    $restoreResult = Get-JsonDocument -Path $restoreResultPath -Label $Label

    return [pscustomobject]@{
        Result = $restoreResult
        Path   = $restoreResultPath
    }
}

function Save-GeneratedExecutionBundle {
    param(
        [Parameter(Mandatory = $true)]
        $ExecutionBundle,
        [Parameter(Mandatory = $true)]
        [string]$OutputRoot
    )

    $resolvedOutputRoot = Resolve-PathValue -PathValue $OutputRoot
    if (-not (Test-Path -LiteralPath $resolvedOutputRoot)) {
        New-Item -ItemType Directory -Path $resolvedOutputRoot -Force | Out-Null
    }

    $executionBundleDirectory = Join-Path $resolvedOutputRoot "execution_bundles"
    if (-not (Test-Path -LiteralPath $executionBundleDirectory)) {
        New-Item -ItemType Directory -Path $executionBundleDirectory -Force | Out-Null
    }

    $persistedExecutionBundle = [pscustomobject]@{
        contract_version    = $ExecutionBundle.contract_version
        record_type         = $ExecutionBundle.record_type
        artifact_type       = $ExecutionBundle.artifact_type
        artifact_id         = $ExecutionBundle.artifact_id
        title               = $ExecutionBundle.title
        summary             = $ExecutionBundle.summary
        status              = $ExecutionBundle.status
        created_at          = $ExecutionBundle.created_at
        created_by          = $ExecutionBundle.created_by
        lineage             = [pscustomobject]@{
            source_kind = $ExecutionBundle.lineage.source_kind
            source_refs = @($ExecutionBundle.lineage.source_refs | ForEach-Object { Get-NormalizedReferenceForSave -BaseDirectory $executionBundleDirectory -Reference $_ })
            rationale   = $ExecutionBundle.lineage.rationale
        }
        work_object_refs    = @($ExecutionBundle.work_object_refs | ForEach-Object {
                [pscustomobject]@{
                    relation    = $_.relation
                    object_type = $_.object_type
                    object_id   = $_.object_id
                    ref         = (Get-NormalizedReferenceForSave -BaseDirectory $executionBundleDirectory -Reference $_.ref)
                    notes       = $_.notes
                }
            })
        planning_record_refs = @($ExecutionBundle.planning_record_refs | ForEach-Object {
                [pscustomobject]@{
                    relation           = $_.relation
                    planning_record_id = $_.planning_record_id
                    object_type        = $_.object_type
                    object_id          = $_.object_id
                    view               = $_.view
                    ref                = (Get-NormalizedReferenceForSave -BaseDirectory $executionBundleDirectory -Reference $_.ref)
                    notes              = $_.notes
                }
            })
        evidence            = @($ExecutionBundle.evidence | ForEach-Object {
                [pscustomobject]@{
                    kind    = $_.kind
                    ref     = (Get-NormalizedReferenceForSave -BaseDirectory $executionBundleDirectory -Reference $_.ref)
                    summary = $_.summary
                }
            })
        audit               = $ExecutionBundle.audit
        execution_summary   = $ExecutionBundle.execution_summary
        executor_profile    = $ExecutionBundle.executor_profile
        bounded_targets     = @($ExecutionBundle.bounded_targets)
        expected_outputs    = @($ExecutionBundle.expected_outputs)
        prohibited_operations = @($ExecutionBundle.prohibited_operations)
        replay_command      = $ExecutionBundle.replay_command
        qa_attempt_count    = $ExecutionBundle.qa_attempt_count
        qa_retry_ceiling    = $ExecutionBundle.qa_retry_ceiling
        qa_entry_state      = $ExecutionBundle.qa_entry_state
        prior_qa_report_ref = (Get-NormalizedReferenceForSave -BaseDirectory $executionBundleDirectory -Reference $ExecutionBundle.prior_qa_report_ref)
        prior_baton_ref     = (Get-NormalizedReferenceForSave -BaseDirectory $executionBundleDirectory -Reference $ExecutionBundle.prior_baton_ref)
        pipeline            = $ExecutionBundle.pipeline
        scope               = $ExecutionBundle.scope
    }

    $executionBundlePath = Join-Path $executionBundleDirectory ("{0}.json" -f $persistedExecutionBundle.artifact_id)
    Write-JsonDocument -Path $executionBundlePath -Document $persistedExecutionBundle
    $validation = & $testWorkArtifactContract -ArtifactPath $executionBundlePath
    if ($validation.ArtifactType -ne "execution_bundle") {
        throw "Generated resume re-entry bundle did not validate as an execution_bundle artifact."
    }

    return $executionBundlePath
}

function Save-ResumeReentryResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $ResumeReentryResult,
        [Parameter(Mandatory = $true)]
        [string]$OutputRoot
    )

    $resolvedOutputRoot = Resolve-PathValue -PathValue $OutputRoot
    if (-not (Test-Path -LiteralPath $resolvedOutputRoot)) {
        New-Item -ItemType Directory -Path $resolvedOutputRoot -Force | Out-Null
    }

    $resultDirectory = Join-Path $resolvedOutputRoot "results"
    if (-not (Test-Path -LiteralPath $resultDirectory)) {
        New-Item -ItemType Directory -Path $resultDirectory -Force | Out-Null
    }

    $persistedResult = [pscustomobject]@{
        contract_version            = $ResumeReentryResult.contract_version
        record_type                 = $ResumeReentryResult.record_type
        resume_result_id            = $ResumeReentryResult.resume_result_id
        resume_request_id           = $ResumeReentryResult.resume_request_id
        baton_ref                   = (Get-NormalizedReferenceForSave -BaseDirectory $resultDirectory -Reference $ResumeReentryResult.baton_ref)
        baseline_ref                = (Get-NormalizedNullableReferenceForSave -BaseDirectory $resultDirectory -Reference $ResumeReentryResult.baseline_ref)
        restore_result_ref          = (Get-NormalizedNullableReferenceForSave -BaseDirectory $resultDirectory -Reference $ResumeReentryResult.restore_result_ref)
        requested_by                = $ResumeReentryResult.requested_by
        decided_at                  = $ResumeReentryResult.decided_at
        reentry_kind                = $ResumeReentryResult.reentry_kind
        prior_execution_bundle_ref  = (Get-NormalizedReferenceForSave -BaseDirectory $resultDirectory -Reference $ResumeReentryResult.prior_execution_bundle_ref)
        prior_qa_report_ref         = (Get-NormalizedReferenceForSave -BaseDirectory $resultDirectory -Reference $ResumeReentryResult.prior_qa_report_ref)
        generated_execution_bundle_ref = (Get-NormalizedNullableReferenceForSave -BaseDirectory $resultDirectory -Reference $ResumeReentryResult.generated_execution_bundle_ref)
        decision                    = $ResumeReentryResult.decision
        checkpoints                 = $ResumeReentryResult.checkpoints
        current_git_state           = $ResumeReentryResult.current_git_state
        block_reasons               = @($ResumeReentryResult.block_reasons)
        notes                       = $ResumeReentryResult.notes
    }

    $resultPath = Join-Path $resultDirectory ("{0}.json" -f $persistedResult.resume_result_id)
    Write-JsonDocument -Path $resultPath -Document $persistedResult
    Test-ResumeReentryResultContract -ResumeResultPath $resultPath | Out-Null

    return $resultPath
}

function Get-ResumeReentryResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $Path -Label "Resume re-entry result"
    Test-ResumeReentryResultContract -ResumeResultPath $resolvedPath | Out-Null
    return (Get-JsonDocument -Path $resolvedPath -Label "Resume re-entry result")
}

function Invoke-ResumeReentry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResumeRequestPath,
        [Parameter(Mandatory = $true)]
        [string]$OutputRoot,
        [string]$RepositoryRoot = (Get-RepositoryRoot),
        [datetime]$CreatedAt = (Get-Date).ToUniversalTime(),
        [string]$CreatedById = "control-kernel:resume-reentry"
    )

    $requestValidation = Test-ResumeReentryRequestContract -ResumeRequestPath $ResumeRequestPath
    $request = Get-JsonDocument -Path $requestValidation.ResumeRequestPath -Label "Resume re-entry request"
    $resolvedOutputRoot = Resolve-PathValue -PathValue $OutputRoot
    if (-not (Test-Path -LiteralPath $resolvedOutputRoot)) {
        New-Item -ItemType Directory -Path $resolvedOutputRoot -Force | Out-Null
    }

    $resolvedRepositoryRoot = Resolve-ExistingPath -PathValue $RepositoryRoot -Label "Resume re-entry repository root"
    $batonInput = Get-ValidatedBatonInput -BatonPath $request.baton_ref
    $currentBranch = Get-GitBranchName -RepositoryRoot $resolvedRepositoryRoot
    $currentHeadCommit = Get-GitHeadCommit -RepositoryRoot $resolvedRepositoryRoot
    $statusLines = @(Get-GitStatusLines -RepositoryRoot $resolvedRepositoryRoot)
    $workingTreeClean = ($statusLines.Count -eq 0)

    $reasons = [System.Collections.ArrayList]::new()
    $baselineInput = $null
    $restoreGateInput = $null
    $restoreGateSatisfied = $true

    $batonReady = ($batonInput.Baton.status -eq "ready_for_handoff")
    if (-not $batonReady) {
        Add-UniqueBlockReason -Reasons $reasons -Code "baton_not_ready" -Summary "Baton status must be 'ready_for_handoff' before resume re-entry can be considered."
    }

    $resumeAuthoritySatisfied = $true
    if (-not [bool]$batonInput.Baton.resume_authority.resume_allowed) {
        Add-UniqueBlockReason -Reasons $reasons -Code "resume_not_allowed" -Summary "Baton resume authority does not permit bounded resume from the current handoff state."
        $resumeAuthoritySatisfied = $false
    }
    if ($batonInput.Baton.resume_authority.checkpoint -ne "qa_follow_up_ready" -or $batonInput.Baton.handoff_state -ne "follow_up") {
        Add-UniqueBlockReason -Reasons $reasons -Code "checkpoint_mismatch" -Summary "Resume re-entry requires a follow_up baton checkpoint of 'qa_follow_up_ready'."
        $resumeAuthoritySatisfied = $false
    }
    if ($request.reentry_kind -ne $batonInput.Baton.resume_context.reentry_kind) {
        Add-UniqueBlockReason -Reasons $reasons -Code "reentry_kind_mismatch" -Summary "Resume request reentry_kind must match the baton resume_context reentry_kind."
        $resumeAuthoritySatisfied = $false
    }

    $lineageSatisfied = $true
    $priorQaSourceRefs = [string[]](Assert-StringArray -Value (Get-RequiredProperty -Object $batonInput.PriorQaReport.lineage -Name "source_refs" -Context "Prior QA Report.lineage") -Context "Prior QA Report.lineage.source_refs")
    $matchingPriorExecutionBundle = $false
    foreach ($sourceRef in @($priorQaSourceRefs)) {
        $resolvedSourceRefPath = Resolve-ReferenceAgainstBase -BaseDirectory (Split-Path -Parent $batonInput.PriorQaReportPath) -Reference $sourceRef -Label "Prior QA Report lineage"
        if ($resolvedSourceRefPath -eq $batonInput.PriorExecutionBundlePath) {
            $matchingPriorExecutionBundle = $true
            break
        }
    }
    if (-not $matchingPriorExecutionBundle) {
        Add-UniqueBlockReason -Reasons $reasons -Code "lineage_mismatch" -Summary "Baton prior QA lineage does not resolve back to the baton prior execution bundle."
        $lineageSatisfied = $false
    }

    $executionBundleSatisfied = ($batonInput.PriorExecutionBundle.status -eq "prepared")
    if (-not $executionBundleSatisfied) {
        Add-UniqueBlockReason -Reasons $reasons -Code "execution_bundle_invalid" -Summary "Resume re-entry requires the prior execution bundle to remain in status 'prepared'."
    }

    $nextAttemptCount = [int]$batonInput.PriorExecutionBundle.qa_attempt_count + 1
    $retryCapacitySatisfied = ($nextAttemptCount -le [int]$batonInput.PriorExecutionBundle.qa_retry_ceiling)
    if (-not $retryCapacitySatisfied) {
        Add-UniqueBlockReason -Reasons $reasons -Code "retry_ceiling_reached" -Summary "Resume re-entry cannot prepare a new retry-entry execution bundle once the bounded retry ceiling is exhausted."
    }

    $cleanWorktreeSatisfied = $workingTreeClean
    if (-not $cleanWorktreeSatisfied) {
        Add-UniqueBlockReason -Reasons $reasons -Code "worktree_dirty" -Summary "Resume re-entry requires a clean Git worktree."
    }

    if (-not [string]::IsNullOrWhiteSpace($request.baseline_ref)) {
        $baselineInput = Get-ValidatedBaselineInput -BaselineReference $request.baseline_ref -BaseDirectory (Split-Path -Parent $requestValidation.ResumeRequestPath) -Label "Resume request baseline"
    }
    elseif ($null -ne $batonInput.Baton.resume_context.baseline_ref) {
        $baselineInput = Get-ValidatedBaselineInput -BaselineReference $batonInput.Baton.resume_context.baseline_ref -BaseDirectory $batonInput.BatonDirectory -Label "Baton baseline"
    }

    if (-not [string]::IsNullOrWhiteSpace($request.restore_result_ref)) {
        $restoreGateInput = Get-ValidatedRestoreGateInput -RestoreResultReference $request.restore_result_ref -BaseDirectory (Split-Path -Parent $requestValidation.ResumeRequestPath) -Label "Resume request restore result"
        if ($restoreGateInput.Result.decision -ne "allow") {
            Add-UniqueBlockReason -Reasons $reasons -Code "restore_gate_blocked" -Summary "Resume re-entry received a restore gate result that is not in decision 'allow'."
            $restoreGateSatisfied = $false
        }

        $restoreBaselineInput = Get-ValidatedBaselineInput -BaselineReference $restoreGateInput.Result.baseline_ref -BaseDirectory (Split-Path -Parent $restoreGateInput.Path) -Label "Restore result baseline"
        if ($null -eq $baselineInput) {
            $baselineInput = $restoreBaselineInput
        }
        elseif ($baselineInput.Path -ne $restoreBaselineInput.Path) {
            Add-UniqueBlockReason -Reasons $reasons -Code "baseline_mismatch" -Summary "Resume request baseline_ref does not match the restore gate result baseline_ref."
            $restoreGateSatisfied = $false
        }
    }

    if ([bool]$batonInput.Baton.resume_authority.restore_gate_required -and $null -eq $restoreGateInput) {
        Add-UniqueBlockReason -Reasons $reasons -Code "restore_gate_missing" -Summary "Baton resume authority requires an allow restore gate result before bounded resume re-entry."
        $restoreGateSatisfied = $false
    }

    if ($null -ne $baselineInput) {
        if ($currentBranch -ne $baselineInput.Baseline.git.branch -or $currentHeadCommit -ne $baselineInput.Baseline.git.head_commit) {
            Add-UniqueBlockReason -Reasons $reasons -Code "baseline_state_missing" -Summary "Current Git state does not match the requested milestone baseline state for resume re-entry."
            $restoreGateSatisfied = $false
        }
    }

    $generatedExecutionBundlePath = $null
    if ($reasons.Count -eq 0) {
        $priorExecutionBundleDirectory = Split-Path -Parent $batonInput.PriorExecutionBundlePath
        $createdAtText = Get-UtcTimestamp -DateTime $CreatedAt
        $generatedEvidence = @($batonInput.PriorExecutionBundle.evidence | ForEach-Object {
                [pscustomobject]@{
                    kind    = $_.kind
                    ref     = (Resolve-ReferenceAgainstBase -BaseDirectory $priorExecutionBundleDirectory -Reference $_.ref -Label "Prior Execution Bundle evidence")
                    summary = $_.summary
                }
            })
        $generatedEvidence += [pscustomobject]@{
            kind    = "artifact"
            ref     = $batonInput.Validation.ArtifactPath
            summary = "The baton provides the operator-controlled resume authority and bounded follow-up lineage."
        }
        $generatedEvidence += [pscustomobject]@{
            kind    = "artifact"
            ref     = $batonInput.PriorQaReportPath
            summary = "The prior QA report preserves the bounded retry-entry source context."
        }
        if ($null -ne $restoreGateInput) {
            $generatedEvidence += [pscustomobject]@{
                kind    = "artifact"
                ref     = $restoreGateInput.Path
                summary = "The allow restore gate result documents the bounded restore authorization checked before resume re-entry."
            }
        }
        if ($null -ne $baselineInput) {
            $generatedEvidence += [pscustomobject]@{
                kind    = "artifact"
                ref     = $baselineInput.Path
                summary = "The milestone baseline records the Git-backed state used by this bounded resume re-entry."
            }
        }

        $generatedExecutionBundle = [pscustomobject]@{
            contract_version    = $batonInput.PriorExecutionBundle.contract_version
            record_type         = $batonInput.PriorExecutionBundle.record_type
            artifact_type       = $batonInput.PriorExecutionBundle.artifact_type
            artifact_id         = ("execution-bundle-{0}" -f $request.resume_request_id)
            title               = "Retry entry for $($batonInput.PriorExecutionBundle.title)"
            summary             = "Operator-controlled bounded resume re-entry prepared from baton '$($batonInput.Baton.artifact_id)' without automatic resume or restore execution."
            status              = "prepared"
            created_at          = $createdAtText
            created_by          = [pscustomobject]@{
                role = "control_kernel"
                id   = $CreatedById
            }
            lineage             = [pscustomobject]@{
                source_kind = $batonInput.PriorExecutionBundle.lineage.source_kind
                source_refs = @($batonInput.PriorExecutionBundle.lineage.source_refs | ForEach-Object {
                        Resolve-ReferenceAgainstBase -BaseDirectory $priorExecutionBundleDirectory -Reference $_ -Label "Prior Execution Bundle lineage"
                    })
                rationale   = "The retry-entry execution bundle preserves the prior bounded execution lineage while reopening only the next allowed QA attempt."
            }
            work_object_refs    = @($batonInput.PriorExecutionBundle.work_object_refs | ForEach-Object {
                    [pscustomobject]@{
                        relation    = $_.relation
                        object_type = $_.object_type
                        object_id   = $_.object_id
                        ref         = (Resolve-ReferenceAgainstBase -BaseDirectory $priorExecutionBundleDirectory -Reference $_.ref -Label "Prior Execution Bundle work object")
                        notes       = $_.notes
                    }
                })
            planning_record_refs = @($batonInput.PriorExecutionBundle.planning_record_refs | ForEach-Object {
                    [pscustomobject]@{
                        relation           = $_.relation
                        planning_record_id = $_.planning_record_id
                        object_type        = $_.object_type
                        object_id          = $_.object_id
                        view               = $_.view
                        ref                = (Resolve-ReferenceAgainstBase -BaseDirectory $priorExecutionBundleDirectory -Reference $_.ref -Label "Prior Execution Bundle planning record")
                        notes              = $_.notes
                    }
                })
            evidence            = @($generatedEvidence)
            audit               = [pscustomobject]@{
                trail_refs       = @("tests/test_resume_reentry.ps1")
                last_reviewed_at = $createdAtText
                notes            = "Resume re-entry output reviewed against the focused resume re-entry test."
            }
            execution_summary   = "Prepare one bounded retry-entry execution bundle from persisted baton state under explicit operator control only."
            executor_profile    = $batonInput.PriorExecutionBundle.executor_profile
            bounded_targets     = @($batonInput.PriorExecutionBundle.bounded_targets)
            expected_outputs    = @($batonInput.PriorExecutionBundle.expected_outputs)
            prohibited_operations = @($batonInput.PriorExecutionBundle.prohibited_operations + @("automatic resume", "restore execution", "broad orchestration") | Select-Object -Unique)
            replay_command      = $null
            qa_attempt_count    = $nextAttemptCount
            qa_retry_ceiling    = [int]$batonInput.PriorExecutionBundle.qa_retry_ceiling
            qa_entry_state      = "retry_entry"
            prior_qa_report_ref = $batonInput.PriorQaReportPath
            prior_baton_ref     = $batonInput.Validation.ArtifactPath
            pipeline            = $batonInput.PriorExecutionBundle.pipeline
            scope               = $batonInput.PriorExecutionBundle.scope
        }

        $generatedExecutionBundlePath = Save-GeneratedExecutionBundle -ExecutionBundle $generatedExecutionBundle -OutputRoot $resolvedOutputRoot
    }

    $result = [pscustomobject]@{
        contract_version            = (Get-ResumeReentryFoundationContract).contract_version
        record_type                 = (Get-ResumeReentryFoundationContract).result_record_type
        resume_result_id            = ("{0}.result" -f $request.resume_request_id)
        resume_request_id           = $request.resume_request_id
        baton_ref                   = $batonInput.Validation.ArtifactPath
        baseline_ref                = if ($null -ne $baselineInput) { $baselineInput.Path } else { $null }
        restore_result_ref          = if ($null -ne $restoreGateInput) { $restoreGateInput.Path } else { $null }
        requested_by                = $request.operator_id
        decided_at                  = Get-UtcTimestamp -DateTime $CreatedAt
        reentry_kind                = $request.reentry_kind
        prior_execution_bundle_ref  = $batonInput.PriorExecutionBundlePath
        prior_qa_report_ref         = $batonInput.PriorQaReportPath
        generated_execution_bundle_ref = $generatedExecutionBundlePath
        decision                    = if ($reasons.Count -eq 0) { "allow" } else { "blocked" }
        checkpoints                 = [pscustomobject]@{
            baton_ready      = $batonReady
            resume_authority = $resumeAuthoritySatisfied
            lineage          = $lineageSatisfied
            clean_worktree   = $cleanWorktreeSatisfied
            retry_capacity   = $retryCapacitySatisfied
            restore_gate     = $restoreGateSatisfied
        }
        current_git_state           = [pscustomobject]@{
            repository_root   = $resolvedRepositoryRoot
            branch            = $currentBranch
            head_commit       = $currentHeadCommit
            working_tree_clean = $workingTreeClean
            status_lines      = @($statusLines)
        }
        block_reasons               = @($reasons)
        notes                       = if ($reasons.Count -eq 0) { "Resume re-entry prepared one bounded retry-entry execution bundle only. No automatic resume or restore action was executed." } else { "Resume re-entry blocked fail-closed. No new execution bundle was prepared." }
    }

    $resultPath = Save-ResumeReentryResult -ResumeReentryResult $result -OutputRoot $resolvedOutputRoot

    return [pscustomobject]@{
        ResumeReentryResult = $result
        ResumeResultPath    = $resultPath
        ExecutionBundlePath = $generatedExecutionBundlePath
    }
}

Export-ModuleMember -Function Test-ResumeReentryRequestContract, Test-ResumeReentryResultContract, Invoke-ResumeReentry, Save-ResumeReentryResult, Get-ResumeReentryResult
