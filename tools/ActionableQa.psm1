Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$script:R12RepositoryName = "AIOffice_V2"
$script:R12Branch = "release/r12-external-api-runner-actionable-qa-control-room-pilot"
$script:GitObjectPattern = "^[a-f0-9]{40}$"
$script:TimestampPattern = "^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$"
$script:AllowedIssueSeverities = @("info", "warning", "error", "critical")
$script:AllowedBlockingStatuses = @("non_blocking", "blocking", "advisory")
$script:AllowedAggregateVerdicts = @("passed", "warning", "failed", "blocked")
$script:RequiredReportNonClaims = @(
    "no production QA",
    "no real production QA",
    "no security audit",
    "no full test coverage",
    "no external evidence gate pass",
    "no R12 closeout",
    "no R12 value-gate delivery by this task alone"
)

function Get-RepositoryRoot {
    return $repoRoot
}

function Get-ModuleRepositoryRootPath {
    return (Resolve-Path -LiteralPath (Get-RepositoryRoot)).Path
}

function Join-RepositoryPath {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Segments
    )

    $path = Get-RepositoryRoot
    foreach ($segment in $Segments) {
        $path = Join-Path $path $segment
    }

    return $path
}

function Resolve-RepositoryPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path (Get-RepositoryRoot) $PathValue))
}

function Convert-ToRepositoryRelativePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue
    )

    $fullPath = [System.IO.Path]::GetFullPath($PathValue)
    $rootPath = [System.IO.Path]::GetFullPath((Get-RepositoryRoot)).TrimEnd([char[]]@([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar))
    if ($fullPath.Equals($rootPath, [System.StringComparison]::OrdinalIgnoreCase)) {
        return "."
    }
    if ($fullPath.StartsWith($rootPath + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $fullPath.Substring($rootPath.Length + 1).Replace("\", "/")
    }

    return $PathValue.Replace("\", "/")
}

function Get-UtcTimestamp {
    return [System.DateTimeOffset]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture)
}

function Get-JsonDocument {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    return (Read-SingleJsonObject -Path $Path -Label $Label)
}

function Write-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Document,
        [switch]$Overwrite
    )

    if ((Test-Path -LiteralPath $Path -PathType Leaf) -and -not $Overwrite) {
        throw "Actionable QA output '$Path' already exists. Use -Overwrite to replace it explicitly."
    }

    $parentPath = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($parentPath)) {
        New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    }

    $Document | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Test-HasProperty {
    param(
        [AllowNull()]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    return $null -ne $Object -and @($Object.PSObject.Properties.Name) -contains $Name
}

function Get-RequiredProperty {
    [CmdletBinding()]
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

    $PSCmdlet.WriteObject($Object.PSObject.Properties[$Name].Value, $false)
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

function Assert-StringValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($null -eq $Value -or $Value -isnot [string]) {
        throw "$Context must be a string."
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

    return [bool]$Value
}

function Assert-IntegerValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [int]$Minimum = 0
    )

    if ($Value -isnot [int] -and $Value -isnot [long]) {
        throw "$Context must be an integer."
    }
    $integer = [int]$Value
    if ($integer -lt $Minimum) {
        throw "$Context must be at least $Minimum."
    }
    return $integer
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
    [CmdletBinding()]
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

    $PSCmdlet.WriteObject($items, $false)
}

function Assert-ObjectArray {
    [CmdletBinding()]
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

    $PSCmdlet.WriteObject($items, $false)
}

function Assert-GitSha {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-NonEmptyString -Value $Value -Context $Context | Out-Null
    if ($Value -notmatch $script:GitObjectPattern) {
        throw "$Context must be a 40-character Git SHA."
    }
}

function Assert-TimestampString {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $timestamp = Assert-NonEmptyString -Value $Value -Context $Context
    if ($timestamp -notmatch $script:TimestampPattern) {
        throw "$Context must be a UTC timestamp."
    }
    return $timestamp
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

function Assert-BoundedPathOrUrl {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -match '^https?://') {
        return
    }
    if ([System.IO.Path]::IsPathRooted($Value) -or $Value -match '(^|[\\/])\.\.([\\/]|$)') {
        throw "$Context must be a repository-relative path without traversal."
    }
}

function Assert-ExistingEvidenceRef {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Ref,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-BoundedPathOrUrl -Value $Ref -Context $Context
    if ($Ref -match '^https?://') {
        return
    }

    $resolvedRef = Resolve-RepositoryPath -PathValue $Ref
    if (-not (Test-Path -LiteralPath $resolvedRef)) {
        throw "$Context evidence ref '$Ref' does not exist."
    }
}

function Assert-RequiredNonClaims {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$NonClaims,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($requiredNonClaim in $script:RequiredReportNonClaims) {
        if ($NonClaims -notcontains $requiredNonClaim) {
            throw "$Context non_claims must include '$requiredNonClaim'."
        }
    }
}

function Test-LineHasNegation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Line
    )

    return ($Line -match '(?i)\b(no|not|without|cannot|must not|does not|do not|is not|are not|non-claim|non_claim|refuse|refuses|blocked|diagnostic only)\b')
}

function Assert-NoProductionQaClaim {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $strings = @()
    if ($null -eq $Value) {
        return
    }
    if ($Value -is [string]) {
        $strings += $Value
    }
    elseif ($Value -is [System.Collections.IEnumerable]) {
        foreach ($item in $Value) {
            if ($item -is [string]) {
                $strings += $item
            }
        }
    }

    foreach ($line in $strings) {
        if ($line -match '(?i)\b(production QA|real production QA)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context cannot claim production QA or real production QA: $line"
        }
    }
}

function Get-ActionableQaIssueContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "actionable_qa", "actionable_qa_issue.contract.json")) -Label "Actionable QA issue contract"
}

function Get-ActionableQaReportContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "actionable_qa", "actionable_qa_report.contract.json")) -Label "Actionable QA report contract"
}

function Test-ActionableQaIssueObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Issue,
        [string]$SourceLabel = "Actionable QA issue"
    )

    $contract = Get-ActionableQaIssueContract
    Assert-RequiredObjectFields -Object $Issue -FieldNames $contract.required_fields -Context $SourceLabel

    $id = Assert-NonEmptyString -Value $Issue.id -Context "$SourceLabel id"
    $severity = Assert-NonEmptyString -Value $Issue.severity -Context "$SourceLabel severity"
    Assert-AllowedValue -Value $severity -AllowedValues $script:AllowedIssueSeverities -Context "$SourceLabel severity"
    Assert-NonEmptyString -Value $Issue.component -Context "$SourceLabel component" | Out-Null

    $filePath = Assert-StringValue -Value $Issue.file_path -Context "$SourceLabel file_path"
    $evidence = Assert-ObjectValue -Value $Issue.evidence -Context "$SourceLabel evidence"
    if ([string]::IsNullOrWhiteSpace($filePath)) {
        throw "$SourceLabel must include file path or explicit not_applicable reason."
    }
    if ($filePath -eq "not_applicable") {
        if (-not (Test-HasProperty -Object $evidence -Name "not_applicable_reason")) {
            throw "$SourceLabel file_path not_applicable requires evidence.not_applicable_reason."
        }
        Assert-NonEmptyString -Value $evidence.not_applicable_reason -Context "$SourceLabel evidence.not_applicable_reason" | Out-Null
    }
    else {
        Assert-BoundedPathOrUrl -Value $filePath -Context "$SourceLabel file_path"
    }

    Assert-IntegerValue -Value $Issue.line -Context "$SourceLabel line" -Minimum 0 | Out-Null
    Assert-NonEmptyString -Value $Issue.failed_rule -Context "$SourceLabel failed_rule" | Out-Null
    Assert-NonEmptyString -Value $Issue.recommended_fix -Context "$SourceLabel recommended_fix" | Out-Null
    $blockingStatus = Assert-NonEmptyString -Value $Issue.blocking_status -Context "$SourceLabel blocking_status"
    Assert-AllowedValue -Value $blockingStatus -AllowedValues $script:AllowedBlockingStatuses -Context "$SourceLabel blocking_status"
    Assert-NonEmptyString -Value $Issue.reproduction_command -Context "$SourceLabel reproduction_command" | Out-Null
    Assert-NonEmptyString -Value $Issue.source_check -Context "$SourceLabel source_check" | Out-Null

    $PSCmdlet.WriteObject([pscustomobject][ordered]@{
            IssueId = $id
            Severity = $severity
            Component = $Issue.component
            FilePath = $filePath
            BlockingStatus = $blockingStatus
            SourceCheck = $Issue.source_check
        }, $false)
}

function Test-ActionableQaIssue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$IssuePath
    )

    $issue = Get-JsonDocument -Path $IssuePath -Label "Actionable QA issue"
    return Test-ActionableQaIssueObject -Issue $issue -SourceLabel "Actionable QA issue"
}

function Test-ActionableQaReportObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Report,
        [string]$SourceLabel = "Actionable QA report"
    )

    $contract = Get-ActionableQaReportContract
    Assert-RequiredObjectFields -Object $Report -FieldNames $contract.required_fields -Context $SourceLabel

    if ($Report.contract_version -ne $contract.contract_version) {
        throw "$SourceLabel contract_version must be '$($contract.contract_version)'."
    }
    if ($Report.artifact_type -ne "actionable_qa_report") {
        throw "$SourceLabel artifact_type must be 'actionable_qa_report'."
    }

    Assert-NonEmptyString -Value $Report.report_id -Context "$SourceLabel report_id" | Out-Null
    if ($Report.repository -ne $script:R12RepositoryName) {
        throw "$SourceLabel repository must be '$script:R12RepositoryName'."
    }
    if ($Report.branch -ne $script:R12Branch) {
        throw "$SourceLabel branch must be '$script:R12Branch'."
    }
    Assert-GitSha -Value ([string]$Report.head) -Context "$SourceLabel head"
    Assert-GitSha -Value ([string]$Report.tree) -Context "$SourceLabel tree"

    $qaScope = Assert-ObjectValue -Value $Report.qa_scope -Context "$SourceLabel qa_scope"
    Assert-RequiredObjectFields -Object $qaScope -FieldNames $contract.qa_scope_required_fields -Context "$SourceLabel qa_scope"
    Assert-StringArray -Value $qaScope.paths -Context "$SourceLabel qa_scope.paths" | Out-Null
    Assert-NonEmptyString -Value $qaScope.description -Context "$SourceLabel qa_scope.description" | Out-Null

    $qaMode = Assert-NonEmptyString -Value $Report.qa_mode -Context "$SourceLabel qa_mode"
    Assert-AllowedValue -Value $qaMode -AllowedValues $contract.allowed_qa_modes -Context "$SourceLabel qa_mode"

    $dependencyStatus = Assert-ObjectValue -Value $Report.dependency_status -Context "$SourceLabel dependency_status"
    Assert-RequiredObjectFields -Object $dependencyStatus -FieldNames $contract.dependency_status_required_fields -Context "$SourceLabel dependency_status"
    $psscriptanalyzer = Assert-ObjectValue -Value $dependencyStatus.psscriptanalyzer -Context "$SourceLabel dependency_status.psscriptanalyzer"
    Assert-RequiredObjectFields -Object $psscriptanalyzer -FieldNames $contract.psscriptanalyzer_required_fields -Context "$SourceLabel dependency_status.psscriptanalyzer"
    Assert-NonEmptyString -Value $psscriptanalyzer.name -Context "$SourceLabel dependency_status.psscriptanalyzer.name" | Out-Null
    $psaAvailable = Assert-BooleanValue -Value $psscriptanalyzer.available -Context "$SourceLabel dependency_status.psscriptanalyzer.available"
    $psaStatus = Assert-NonEmptyString -Value $psscriptanalyzer.status -Context "$SourceLabel dependency_status.psscriptanalyzer.status"
    Assert-AllowedValue -Value $psaStatus -AllowedValues $contract.allowed_dependency_statuses -Context "$SourceLabel dependency_status.psscriptanalyzer.status"
    $strictRequired = Assert-BooleanValue -Value $psscriptanalyzer.strict_required -Context "$SourceLabel dependency_status.psscriptanalyzer.strict_required"
    Assert-TimestampString -Value $psscriptanalyzer.checked_at_utc -Context "$SourceLabel dependency_status.psscriptanalyzer.checked_at_utc" | Out-Null
    Assert-StringValue -Value $psscriptanalyzer.details -Context "$SourceLabel dependency_status.psscriptanalyzer.details" | Out-Null
    if (-not $psaAvailable -and $psaStatus -ne "unavailable") {
        throw "$SourceLabel dependency_status.psscriptanalyzer unavailable dependency must be recorded explicitly."
    }

    $commands = Assert-ObjectArray -Value $Report.commands_run -Context "$SourceLabel commands_run"
    foreach ($command in $commands) {
        Assert-RequiredObjectFields -Object $command -FieldNames $contract.command_required_fields -Context "$SourceLabel command"
        Assert-NonEmptyString -Value $command.command_id -Context "$SourceLabel command.command_id" | Out-Null
        Assert-NonEmptyString -Value $command.command -Context "$SourceLabel command.command" | Out-Null
        Assert-IntegerValue -Value $command.exit_code -Context "$SourceLabel command.exit_code" -Minimum 0 | Out-Null
        $commandVerdict = Assert-NonEmptyString -Value $command.verdict -Context "$SourceLabel command.verdict"
        Assert-AllowedValue -Value $commandVerdict -AllowedValues $contract.allowed_command_verdicts -Context "$SourceLabel command.verdict"
        Assert-TimestampString -Value $command.started_at_utc -Context "$SourceLabel command.started_at_utc" | Out-Null
        Assert-TimestampString -Value $command.completed_at_utc -Context "$SourceLabel command.completed_at_utc" | Out-Null
    }

    $checks = Assert-ObjectArray -Value $Report.checks_run -Context "$SourceLabel checks_run"
    foreach ($check in $checks) {
        Assert-RequiredObjectFields -Object $check -FieldNames $contract.check_required_fields -Context "$SourceLabel check"
        Assert-NonEmptyString -Value $check.check_id -Context "$SourceLabel check.check_id" | Out-Null
        Assert-NonEmptyString -Value $check.check_type -Context "$SourceLabel check.check_type" | Out-Null
        Assert-StringValue -Value $check.scope -Context "$SourceLabel check.scope" | Out-Null
        $checkVerdict = Assert-NonEmptyString -Value $check.verdict -Context "$SourceLabel check.verdict"
        Assert-AllowedValue -Value $checkVerdict -AllowedValues $contract.allowed_check_verdicts -Context "$SourceLabel check.verdict"
        Assert-IntegerValue -Value $check.issue_count -Context "$SourceLabel check.issue_count" -Minimum 0 | Out-Null
        Assert-NonEmptyString -Value $check.reproduction_command -Context "$SourceLabel check.reproduction_command" | Out-Null
    }

    $issues = Assert-ObjectArray -Value $Report.issues -Context "$SourceLabel issues" -AllowEmpty
    $seenIssues = @{}
    $blockingIssueCount = 0
    $severityCounts = @{ critical = 0; error = 0; warning = 0; info = 0 }
    foreach ($issue in $issues) {
        $issueValidation = Test-ActionableQaIssueObject -Issue $issue -SourceLabel "$SourceLabel issue"
        if ($seenIssues.ContainsKey($issueValidation.IssueId)) {
            throw "$SourceLabel duplicate issue id '$($issueValidation.IssueId)' is rejected."
        }
        $seenIssues[$issueValidation.IssueId] = $true
        $severityCounts[$issueValidation.Severity] += 1
        if ($issueValidation.BlockingStatus -eq "blocking") {
            $blockingIssueCount += 1
        }
    }

    $summary = Assert-ObjectValue -Value $Report.summary -Context "$SourceLabel summary"
    Assert-RequiredObjectFields -Object $summary -FieldNames $contract.summary_required_fields -Context "$SourceLabel summary"
    $summaryTotal = Assert-IntegerValue -Value $summary.total_issue_count -Context "$SourceLabel summary.total_issue_count" -Minimum 0
    $summaryBlocking = Assert-IntegerValue -Value $summary.blocking_issue_count -Context "$SourceLabel summary.blocking_issue_count" -Minimum 0
    if ($summaryTotal -ne $issues.Count) {
        throw "$SourceLabel summary.total_issue_count must match issues count."
    }
    if ($summaryBlocking -ne $blockingIssueCount) {
        throw "$SourceLabel summary.blocking_issue_count must match blocking issues."
    }
    foreach ($severity in $script:AllowedIssueSeverities) {
        $fieldName = "{0}_count" -f $severity
        $declaredCount = Assert-IntegerValue -Value $summary.$fieldName -Context "$SourceLabel summary.$fieldName" -Minimum 0
        if ($declaredCount -ne $severityCounts[$severity]) {
            throw "$SourceLabel summary.$fieldName must match issue severity count."
        }
    }
    if ((Assert-IntegerValue -Value $summary.command_count -Context "$SourceLabel summary.command_count" -Minimum 0) -ne $commands.Count) {
        throw "$SourceLabel summary.command_count must match commands_run count."
    }
    if ((Assert-IntegerValue -Value $summary.check_count -Context "$SourceLabel summary.check_count" -Minimum 0) -ne $checks.Count) {
        throw "$SourceLabel summary.check_count must match checks_run count."
    }

    $aggregateVerdict = Assert-NonEmptyString -Value $Report.aggregate_verdict -Context "$SourceLabel aggregate_verdict"
    Assert-AllowedValue -Value $aggregateVerdict -AllowedValues $script:AllowedAggregateVerdicts -Context "$SourceLabel aggregate_verdict"
    if ($blockingIssueCount -gt 0 -and $aggregateVerdict -eq "passed") {
        throw "$SourceLabel blocking issues cannot produce aggregate passed."
    }
    if ($strictRequired -and -not $psaAvailable -and $aggregateVerdict -eq "passed") {
        throw "$SourceLabel strict mode cannot pass when PSScriptAnalyzer is unavailable."
    }

    $reproductionCommands = Assert-StringArray -Value $Report.reproduction_commands -Context "$SourceLabel reproduction_commands"
    $evidenceRefs = Assert-StringArray -Value $Report.evidence_refs -Context "$SourceLabel evidence_refs"
    foreach ($evidenceRef in $evidenceRefs) {
        Assert-ExistingEvidenceRef -Ref $evidenceRef -Context "$SourceLabel evidence_refs"
    }
    Assert-TimestampString -Value $Report.created_at_utc -Context "$SourceLabel created_at_utc" | Out-Null
    $nonClaims = Assert-StringArray -Value $Report.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel
    Assert-NoProductionQaClaim -Value @($Report.non_claims) -Context $SourceLabel

    $PSCmdlet.WriteObject([pscustomobject][ordered]@{
            ReportId = $Report.report_id
            Repository = $Report.repository
            Branch = $Report.branch
            Head = $Report.head
            Tree = $Report.tree
            QaMode = $qaMode
            PSScriptAnalyzerAvailable = $psaAvailable
            IssueCount = $issues.Count
            BlockingIssueCount = $blockingIssueCount
            AggregateVerdict = $aggregateVerdict
            EvidenceRefCount = $evidenceRefs.Count
        }, $false)
}

function Test-ActionableQaReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ReportPath
    )

    $report = Get-JsonDocument -Path $ReportPath -Label "Actionable QA report"
    return Test-ActionableQaReportObject -Report $report -SourceLabel "Actionable QA report"
}

function Invoke-GitLines {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & git -C (Get-RepositoryRoot) @Arguments 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }

    if ($exitCode -ne 0) {
        throw "Git command failed: git $($Arguments -join ' ')"
    }

    return @($output | ForEach-Object { [string]$_ })
}

function New-ActionableQaIssue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Id,
        [Parameter(Mandatory = $true)]
        [ValidateSet("info", "warning", "error", "critical")]
        [string]$Severity,
        [Parameter(Mandatory = $true)]
        [string]$Component,
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        [int]$Line = 0,
        [Parameter(Mandatory = $true)]
        [string]$FailedRule,
        [Parameter(Mandatory = $true)]
        $Evidence,
        [Parameter(Mandatory = $true)]
        [string]$RecommendedFix,
        [Parameter(Mandatory = $true)]
        [ValidateSet("non_blocking", "blocking", "advisory")]
        [string]$BlockingStatus,
        [Parameter(Mandatory = $true)]
        [string]$ReproductionCommand,
        [Parameter(Mandatory = $true)]
        [string]$SourceCheck
    )

    return [pscustomobject][ordered]@{
        id = $Id
        severity = $Severity
        component = $Component
        file_path = $FilePath
        line = $Line
        failed_rule = $FailedRule
        evidence = $Evidence
        recommended_fix = $RecommendedFix
        blocking_status = $BlockingStatus
        reproduction_command = $ReproductionCommand
        source_check = $SourceCheck
    }
}

function Get-ScopedFiles {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Paths,
        [Parameter(Mandatory = $true)]
        [string[]]$Extensions
    )

    $files = New-Object System.Collections.Generic.List[string]
    foreach ($path in @($Paths)) {
        $resolvedPath = Resolve-RepositoryPath -PathValue $path
        if (-not (Test-Path -LiteralPath $resolvedPath)) {
            continue
        }

        $item = Get-Item -LiteralPath $resolvedPath
        if ($item.PSIsContainer) {
            foreach ($file in Get-ChildItem -LiteralPath $resolvedPath -File -Recurse) {
                if ($Extensions -contains $file.Extension.ToLowerInvariant()) {
                    $files.Add($file.FullName) | Out-Null
                }
            }
        }
        else {
            if ($Extensions -contains $item.Extension.ToLowerInvariant()) {
                $files.Add($item.FullName) | Out-Null
            }
        }
    }

    return @($files | Sort-Object -Unique)
}

function Invoke-ExternalCommandCapture {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command
    )

    $startedAt = Get-UtcTimestamp
    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & powershell -NoProfile -ExecutionPolicy Bypass -Command $Command 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }
    $completedAt = Get-UtcTimestamp

    $verdict = if ($exitCode -eq 0) { "passed" } else { "failed" }
    return [pscustomobject][ordered]@{
        exit_code = [int]$exitCode
        verdict = $verdict
        started_at_utc = $startedAt
        completed_at_utc = $completedAt
        output = @($output | ForEach-Object { [string]$_ })
    }
}

function Export-ActionableQaReportMarkdown {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Report,
        [Parameter(Mandatory = $true)]
        [string]$MarkdownOutputPath,
        [switch]$Overwrite
    )

    if ((Test-Path -LiteralPath $MarkdownOutputPath -PathType Leaf) -and -not $Overwrite) {
        throw "Actionable QA Markdown output '$MarkdownOutputPath' already exists. Use -Overwrite to replace it explicitly."
    }

    $parentPath = Split-Path -Parent $MarkdownOutputPath
    if (-not [string]::IsNullOrWhiteSpace($parentPath)) {
        New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    }

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# R12 Actionable QA Diagnostic Report") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add(("- Report ID: ``{0}``" -f $Report.report_id)) | Out-Null
    $lines.Add(("- Branch: ``{0}``" -f $Report.branch)) | Out-Null
    $lines.Add(("- Head: ``{0}``" -f $Report.head)) | Out-Null
    $lines.Add(("- Tree: ``{0}``" -f $Report.tree)) | Out-Null
    $lines.Add(("- QA mode: ``{0}``" -f $Report.qa_mode)) | Out-Null
    $lines.Add(("- Aggregate verdict: ``{0}``" -f $Report.aggregate_verdict)) | Out-Null
    $lines.Add("- Issue count: $($Report.summary.total_issue_count)") | Out-Null
    $lines.Add("- Blocking count: $($Report.summary.blocking_issue_count)") | Out-Null
    $lines.Add(("- PSScriptAnalyzer: ``{0}``" -f $Report.dependency_status.psscriptanalyzer.status)) | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## Commands") | Out-Null
    foreach ($command in @($Report.commands_run)) {
        $lines.Add(("- ``{0}`` -> ``{1}``" -f $command.command, $command.verdict)) | Out-Null
    }
    $lines.Add("") | Out-Null
    $lines.Add("## Issues") | Out-Null
    if (@($Report.issues).Count -eq 0) {
        $lines.Add("- No issues were recorded by this bounded diagnostic run.") | Out-Null
    }
    else {
        foreach ($issue in @($Report.issues)) {
            $lines.Add(("- ``{0}`` [{1}/{2}] ``{3}:{4}`` {5} - {6}" -f $issue.id, $issue.severity, $issue.blocking_status, $issue.file_path, $issue.line, $issue.failed_rule, $issue.recommended_fix)) | Out-Null
        }
    }
    $lines.Add("") | Out-Null
    $lines.Add("## Non-Claims") | Out-Null
    foreach ($nonClaim in @($Report.non_claims)) {
        $lines.Add("- $nonClaim") | Out-Null
    }

    Set-Content -LiteralPath $MarkdownOutputPath -Value $lines -Encoding UTF8
    return $MarkdownOutputPath
}

function Invoke-ActionableQa {
    [CmdletBinding()]
    param(
        [ValidateSet("diagnostic_non_strict", "strict", "fixture")]
        [string]$QaMode = "diagnostic_non_strict",
        [string[]]$PowerShellPaths = @("tools", "tests"),
        [string[]]$JsonPaths = @("contracts", "state/fixtures"),
        [string[]]$MarkdownPaths = @(
            "README.md",
            "governance/ACTIVE_STATE.md",
            "execution/KANBAN.md",
            "governance/DECISION_LOG.md",
            "governance/R12_EXTERNAL_API_RUNNER_ACTIONABLE_QA_AND_CONTROL_ROOM_WORKFLOW_PILOT.md"
        ),
        [string[]]$EvidenceRefs = @(
            "contracts/actionable_qa/actionable_qa_report.contract.json",
            "contracts/actionable_qa/actionable_qa_issue.contract.json",
            "tools/ActionableQa.psm1"
        ),
        [string[]]$TestCommands = @(),
        [string]$OutputPath = "",
        [string]$MarkdownOutputPath = "",
        [switch]$Overwrite
    )

    $branch = (Invoke-GitLines -Arguments @("branch", "--show-current"))[0].Trim()
    $head = (Invoke-GitLines -Arguments @("rev-parse", "HEAD"))[0].Trim()
    $tree = (Invoke-GitLines -Arguments @("rev-parse", "HEAD^{tree}"))[0].Trim()
    $issues = New-Object System.Collections.Generic.List[object]
    $checks = New-Object System.Collections.Generic.List[object]
    $commands = New-Object System.Collections.Generic.List[object]

    $psaCheckedAt = Get-UtcTimestamp
    $psaModule = Get-Module -ListAvailable -Name PSScriptAnalyzer | Select-Object -First 1
    $psaAvailable = $null -ne $psaModule
    $psaStatus = if ($psaAvailable) { "available" } else { "unavailable" }
    $psaDetails = if ($psaAvailable) { "PSScriptAnalyzer module found at $($psaModule.Path)." } else { "PSScriptAnalyzer module was not installed in this environment." }
    $strictRequired = $QaMode -eq "strict"

    $psFiles = Get-ScopedFiles -Paths $PowerShellPaths -Extensions @(".ps1", ".psm1")
    $parseIssueStart = $issues.Count
    foreach ($file in $psFiles) {
        $tokens = $null
        $parseErrors = $null
        [System.Management.Automation.Language.Parser]::ParseFile($file, [ref]$tokens, [ref]$parseErrors) | Out-Null
        foreach ($parseError in @($parseErrors)) {
            $relativePath = Convert-ToRepositoryRelativePath -PathValue $file
            $issues.Add((New-ActionableQaIssue -Id ("ps-parse-" + [guid]::NewGuid().ToString("N").Substring(0, 12)) -Severity "error" -Component "powershell_syntax" -FilePath $relativePath -Line $parseError.Extent.StartLineNumber -FailedRule "powershell_parse" -Evidence ([pscustomobject][ordered]@{ message = $parseError.Message; extent = $parseError.Extent.Text }) -RecommendedFix "Fix the PowerShell parser error before using this script or module." -BlockingStatus "blocking" -ReproductionCommand ("powershell -NoProfile -Command ""[System.Management.Automation.Language.Parser]::ParseFile('{0}', [ref]`$null, [ref]`$null)""" -f $relativePath) -SourceCheck "powershell_parse")) | Out-Null
        }
    }
    $psParseIssues = $issues.Count - $parseIssueStart
    $checks.Add([pscustomobject][ordered]@{
            check_id = "powershell-parse"
            check_type = "powershell_syntax_parse"
            scope = ($PowerShellPaths -join ", ")
            verdict = if ($psParseIssues -eq 0) { "passed" } else { "failed" }
            issue_count = $psParseIssues
            reproduction_command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_actionable_qa.ps1"
        }) | Out-Null
    $commands.Add([pscustomobject][ordered]@{
            command_id = "powershell-parse"
            command = "PowerShell Parser.ParseFile over scoped .ps1/.psm1 files"
            exit_code = if ($psParseIssues -eq 0) { 0 } else { 1 }
            verdict = if ($psParseIssues -eq 0) { "passed" } else { "failed" }
            started_at_utc = Get-UtcTimestamp
            completed_at_utc = Get-UtcTimestamp
        }) | Out-Null

    $jsonFiles = Get-ScopedFiles -Paths $JsonPaths -Extensions @(".json")
    $jsonIssueStart = $issues.Count
    foreach ($file in $jsonFiles) {
        try {
            Read-SingleJsonObject -Path $file -Label (Convert-ToRepositoryRelativePath -PathValue $file) | Out-Null
        }
        catch {
            $relativePath = Convert-ToRepositoryRelativePath -PathValue $file
            $issues.Add((New-ActionableQaIssue -Id ("json-parse-" + [guid]::NewGuid().ToString("N").Substring(0, 12)) -Severity "error" -Component "json_parse" -FilePath $relativePath -Line 0 -FailedRule "json_parse" -Evidence ([pscustomobject][ordered]@{ message = $_.Exception.Message }) -RecommendedFix "Repair the JSON so it parses as a single root object." -BlockingStatus "blocking" -ReproductionCommand ("powershell -NoProfile -Command ""Import-Module .\tools\JsonRoot.psm1 -Force; Read-SingleJsonObject -Path '{0}'""" -f $relativePath) -SourceCheck "json_parse")) | Out-Null
        }
    }
    $jsonIssues = $issues.Count - $jsonIssueStart
    $checks.Add([pscustomobject][ordered]@{
            check_id = "json-parse"
            check_type = "json_parse"
            scope = ($JsonPaths -join ", ")
            verdict = if ($jsonIssues -eq 0) { "passed" } else { "failed" }
            issue_count = $jsonIssues
            reproduction_command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_actionable_qa.ps1"
        }) | Out-Null
    $commands.Add([pscustomobject][ordered]@{
            command_id = "json-parse"
            command = "JsonRoot.Read-SingleJsonObject over scoped .json files"
            exit_code = if ($jsonIssues -eq 0) { 0 } else { 1 }
            verdict = if ($jsonIssues -eq 0) { "passed" } else { "failed" }
            started_at_utc = Get-UtcTimestamp
            completed_at_utc = Get-UtcTimestamp
        }) | Out-Null

    $evidenceIssueStart = $issues.Count
    foreach ($evidenceRef in @($EvidenceRefs)) {
        try {
            Assert-ExistingEvidenceRef -Ref $evidenceRef -Context "Actionable QA report input" | Out-Null
        }
        catch {
            $issues.Add((New-ActionableQaIssue -Id ("evidence-ref-" + [guid]::NewGuid().ToString("N").Substring(0, 12)) -Severity "error" -Component "evidence_refs" -FilePath $evidenceRef -Line 0 -FailedRule "evidence_ref_exists" -Evidence ([pscustomobject][ordered]@{ message = $_.Exception.Message }) -RecommendedFix "Create the referenced evidence artifact or remove the stale evidence reference." -BlockingStatus "blocking" -ReproductionCommand "powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_actionable_qa.ps1" -SourceCheck "evidence_ref_exists")) | Out-Null
        }
    }
    $evidenceIssues = $issues.Count - $evidenceIssueStart
    $checks.Add([pscustomobject][ordered]@{
            check_id = "evidence-ref-exists"
            check_type = "evidence_ref_existence"
            scope = ($EvidenceRefs -join ", ")
            verdict = if ($evidenceIssues -eq 0) { "passed" } else { "failed" }
            issue_count = $evidenceIssues
            reproduction_command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_actionable_qa.ps1"
        }) | Out-Null

    $markdownIssueStart = $issues.Count
    $markdownFiles = Get-ScopedFiles -Paths $MarkdownPaths -Extensions @(".md")
    $pathPattern = '`([^`]+?\.(?:json|ps1|psm1|md|yml|yaml))`'
    foreach ($file in $markdownFiles) {
        $relativeMarkdownPath = Convert-ToRepositoryRelativePath -PathValue $file
        $text = Get-Content -LiteralPath $file -Raw
        foreach ($match in [regex]::Matches($text, $pathPattern)) {
            $candidate = $match.Groups[1].Value
            if ($candidate -match '^https?://' -or $candidate -match '\*' -or $candidate -match '^\$') {
                continue
            }
            if ($candidate -match '^governance/reports/' -or $candidate -match '^contracts/' -or $candidate -match '^tools/' -or $candidate -match '^tests/' -or $candidate -match '^state/' -or $candidate -match '^\.github/' -or $candidate -match '^README\.md$' -or $candidate -match '^execution/') {
                $candidatePath = Resolve-RepositoryPath -PathValue $candidate
                if (-not (Test-Path -LiteralPath $candidatePath)) {
                    $issues.Add((New-ActionableQaIssue -Id ("md-ref-" + [guid]::NewGuid().ToString("N").Substring(0, 12)) -Severity "warning" -Component "governance_markdown_refs" -FilePath $relativeMarkdownPath -Line 0 -FailedRule "markdown_reference_path_exists" -Evidence ([pscustomobject][ordered]@{ missing_ref = $candidate }) -RecommendedFix "Update the markdown reference or add the referenced artifact." -BlockingStatus "advisory" -ReproductionCommand "powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_actionable_qa.ps1" -SourceCheck "markdown_reference_path_exists")) | Out-Null
                }
            }
        }
    }
    $markdownIssues = $issues.Count - $markdownIssueStart
    $checks.Add([pscustomobject][ordered]@{
            check_id = "markdown-reference-paths"
            check_type = "markdown_reference_path_check"
            scope = ($MarkdownPaths -join ", ")
            verdict = if ($markdownIssues -eq 0) { "passed" } else { "warning" }
            issue_count = $markdownIssues
            reproduction_command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_actionable_qa.ps1"
        }) | Out-Null

    if ($psaAvailable) {
        $psaIssueStart = $issues.Count
        $psaStarted = Get-UtcTimestamp
        Import-Module PSScriptAnalyzer -Force
        foreach ($path in @($PowerShellPaths)) {
            $resolvedPath = Resolve-RepositoryPath -PathValue $path
            if (Test-Path -LiteralPath $resolvedPath) {
                foreach ($finding in @(Invoke-ScriptAnalyzer -Path $resolvedPath -Recurse)) {
                    $severity = switch ([string]$finding.Severity) {
                        "Error" { "error" }
                        "Warning" { "warning" }
                        default { "info" }
                    }
                    $blockingStatus = if ($severity -eq "error") { "blocking" } elseif ($severity -eq "warning") { "non_blocking" } else { "advisory" }
                    $relativePath = Convert-ToRepositoryRelativePath -PathValue $finding.ScriptPath
                    $issues.Add((New-ActionableQaIssue -Id ("psa-" + [guid]::NewGuid().ToString("N").Substring(0, 12)) -Severity $severity -Component "psscriptanalyzer" -FilePath $relativePath -Line $finding.Line -FailedRule ([string]$finding.RuleName) -Evidence ([pscustomobject][ordered]@{ message = [string]$finding.Message }) -RecommendedFix "Review the PSScriptAnalyzer finding and adjust the script if the finding is actionable." -BlockingStatus $blockingStatus -ReproductionCommand ("Invoke-ScriptAnalyzer -Path '{0}'" -f $relativePath) -SourceCheck "psscriptanalyzer")) | Out-Null
                }
            }
        }
        $psaIssues = $issues.Count - $psaIssueStart
        $psaCompleted = Get-UtcTimestamp
        $checks.Add([pscustomobject][ordered]@{
                check_id = "psscriptanalyzer"
                check_type = "psscriptanalyzer"
                scope = ($PowerShellPaths -join ", ")
                verdict = if ($psaIssues -eq 0) { "passed" } elseif ($strictRequired) { "failed" } else { "warning" }
                issue_count = $psaIssues
                reproduction_command = "Invoke-ScriptAnalyzer -Path tools -Recurse"
            }) | Out-Null
        $commands.Add([pscustomobject][ordered]@{
                command_id = "psscriptanalyzer"
                command = "Invoke-ScriptAnalyzer over scoped PowerShell files"
                exit_code = if ($psaIssues -eq 0 -or -not $strictRequired) { 0 } else { 1 }
                verdict = if ($psaIssues -eq 0 -or -not $strictRequired) { "passed" } else { "failed" }
                started_at_utc = $psaStarted
                completed_at_utc = $psaCompleted
            }) | Out-Null
    }
    else {
        $checks.Add([pscustomobject][ordered]@{
                check_id = "psscriptanalyzer"
                check_type = "psscriptanalyzer"
                scope = ($PowerShellPaths -join ", ")
                verdict = if ($strictRequired) { "blocked" } else { "skipped" }
                issue_count = 0
                reproduction_command = "Get-Module -ListAvailable -Name PSScriptAnalyzer"
            }) | Out-Null
        $commands.Add([pscustomobject][ordered]@{
                command_id = "psscriptanalyzer"
                command = "Get-Module -ListAvailable -Name PSScriptAnalyzer"
                exit_code = if ($strictRequired) { 1 } else { 0 }
                verdict = if ($strictRequired) { "blocked" } else { "not_run" }
                started_at_utc = $psaCheckedAt
                completed_at_utc = Get-UtcTimestamp
            }) | Out-Null
    }

    $testIndex = 0
    foreach ($testCommand in @($TestCommands)) {
        if ([string]::IsNullOrWhiteSpace($testCommand)) {
            continue
        }
        $testIndex += 1
        $capture = Invoke-ExternalCommandCapture -Command $testCommand
        $commandId = "selected-test-{0}" -f $testIndex.ToString("000")
        $commands.Add([pscustomobject][ordered]@{
                command_id = $commandId
                command = $testCommand
                exit_code = $capture.exit_code
                verdict = $capture.verdict
                started_at_utc = $capture.started_at_utc
                completed_at_utc = $capture.completed_at_utc
            }) | Out-Null
        $checks.Add([pscustomobject][ordered]@{
                check_id = $commandId
                check_type = "selected_test_command"
                scope = $testCommand
                verdict = if ($capture.exit_code -eq 0) { "passed" } else { "failed" }
                issue_count = if ($capture.exit_code -eq 0) { 0 } else { 1 }
                reproduction_command = $testCommand
            }) | Out-Null
        if ($capture.exit_code -ne 0) {
            $issues.Add((New-ActionableQaIssue -Id ("test-command-" + [guid]::NewGuid().ToString("N").Substring(0, 12)) -Severity "error" -Component "selected_test_command" -FilePath "not_applicable" -Line 0 -FailedRule "selected_test_command_exit_code" -Evidence ([pscustomobject][ordered]@{ command = $testCommand; exit_code = $capture.exit_code; output = @($capture.output); not_applicable_reason = "The failed artifact is a selected command result, not a source file." }) -RecommendedFix "Run the reproduction command locally, inspect stdout/stderr, and repair the failing test or contract." -BlockingStatus "blocking" -ReproductionCommand $testCommand -SourceCheck "selected_test_command")) | Out-Null
        }
    }

    $blockingIssueCount = @($issues | Where-Object { $_.blocking_status -eq "blocking" }).Count
    $criticalCount = @($issues | Where-Object { $_.severity -eq "critical" }).Count
    $errorCount = @($issues | Where-Object { $_.severity -eq "error" }).Count
    $warningCount = @($issues | Where-Object { $_.severity -eq "warning" }).Count
    $infoCount = @($issues | Where-Object { $_.severity -eq "info" }).Count

    $aggregateVerdict = "passed"
    if ($strictRequired -and -not $psaAvailable) {
        $aggregateVerdict = "blocked"
    }
    elseif ($blockingIssueCount -gt 0 -or $errorCount -gt 0 -or $criticalCount -gt 0) {
        $aggregateVerdict = "failed"
    }
    elseif ($warningCount -gt 0) {
        $aggregateVerdict = "warning"
    }

    $report = [pscustomobject][ordered]@{
        contract_version = "v1"
        artifact_type = "actionable_qa_report"
        report_id = "r12-actionable-qa-" + [guid]::NewGuid().ToString("N")
        repository = $script:R12RepositoryName
        branch = $branch
        head = $head
        tree = $tree
        qa_scope = [pscustomobject][ordered]@{
            paths = @($PowerShellPaths + $JsonPaths + $MarkdownPaths)
            description = "Bounded R12 actionable QA foundation checks: PowerShell parse, JSON parse, evidence refs, feasible markdown refs, optional PSScriptAnalyzer, and selected test commands."
        }
        qa_mode = $QaMode
        dependency_status = [pscustomobject][ordered]@{
            psscriptanalyzer = [pscustomobject][ordered]@{
                name = "PSScriptAnalyzer"
                available = [bool]$psaAvailable
                status = $psaStatus
                strict_required = [bool]$strictRequired
                checked_at_utc = $psaCheckedAt
                details = $psaDetails
            }
        }
        commands_run = @($commands)
        checks_run = @($checks)
        issues = @($issues)
        summary = [pscustomobject][ordered]@{
            total_issue_count = @($issues).Count
            blocking_issue_count = $blockingIssueCount
            critical_count = $criticalCount
            error_count = $errorCount
            warning_count = $warningCount
            info_count = $infoCount
            command_count = @($commands).Count
            check_count = @($checks).Count
        }
        aggregate_verdict = $aggregateVerdict
        reproduction_commands = @(
            "powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_actionable_qa.ps1",
            "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_actionable_qa.ps1"
        )
        evidence_refs = @($EvidenceRefs)
        created_at_utc = Get-UtcTimestamp
        non_claims = @($script:RequiredReportNonClaims)
    }

    Test-ActionableQaReportObject -Report $report -SourceLabel "Actionable QA report draft" | Out-Null

    if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
        Write-JsonDocument -Path (Resolve-RepositoryPath -PathValue $OutputPath) -Document $report -Overwrite:$Overwrite
    }
    if (-not [string]::IsNullOrWhiteSpace($MarkdownOutputPath)) {
        Export-ActionableQaReportMarkdown -Report $report -MarkdownOutputPath (Resolve-RepositoryPath -PathValue $MarkdownOutputPath) -Overwrite:$Overwrite | Out-Null
    }

    $PSCmdlet.WriteObject($report, $false)
}

Export-ModuleMember -Function Get-ActionableQaIssueContract, Get-ActionableQaReportContract, Test-ActionableQaIssueObject, Test-ActionableQaIssue, Test-ActionableQaReportObject, Test-ActionableQaReport, Invoke-ActionableQa, Export-ActionableQaReportMarkdown
