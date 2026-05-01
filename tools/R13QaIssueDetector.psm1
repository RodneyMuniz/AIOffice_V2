Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$script:R13RepositoryName = "AIOffice_V2"
$script:R13Branch = "release/r13-api-first-qa-pipeline-and-operator-control-room-product-slice"
$script:R13Milestone = "R13 API-First QA Pipeline and Operator Control-Room Product Slice"
$script:R13SourceTask = "R13-003"
$script:R13DetectorVersion = "r13-qa-issue-detector-v2"
$script:GitObjectPattern = "^[a-f0-9]{40}$"
$script:TimestampPattern = "^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$"
$script:AllowedIssueSeverities = @("critical", "error", "warning", "info")
$script:AllowedBlockingStatuses = @("blocking", "non_blocking", "advisory")
$script:AllowedAggregateVerdicts = @("passed", "failed", "blocked")
$script:AllowedIssueStatuses = @("detected", "unresolved", "resolved", "fixed", "advisory")
$script:AllowedLifecycleStages = @("detected", "blocked")
$script:AllowedCheckVerdicts = @("passed", "failed", "blocked", "skipped")
$script:AllowedCommandVerdicts = @("passed", "failed", "blocked", "not_run")
$script:AllowedDependencyStatuses = @("available", "unavailable", "skipped")
$script:AllowedIssueTypes = @(
    "malformed_json",
    "missing_required_evidence_ref",
    "missing_reproduction_command",
    "narrative_only_qa_evidence",
    "executor_self_certification_qa_authority",
    "local_only_evidence_as_external_proof",
    "missing_recommended_fix",
    "aggregate_passed_with_unresolved_blocking_issue",
    "stale_or_wrong_branch_head_tree_identity",
    "powershell_parse_error",
    "psscriptanalyzer_finding"
)
$script:RequiredNonClaims = @(
    "no R13 hard value gate delivered by R13-003",
    "no meaningful QA loop gate delivered yet",
    "no fix queue delivered by R13-003",
    "no bounded fix execution delivered by R13-003",
    "no rerun delivered by R13-003",
    "no before/after comparison delivered by R13-003",
    "no external replay proof delivered by R13-003",
    "no current operator control-room delivered by R13-003",
    "no final QA signoff delivered by R13-003",
    "no real production QA",
    "no executor self-certification as QA",
    "no R14 or successor opening"
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

function Test-HasProperty {
    param(
        [AllowNull()]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    return $null -ne $Object -and @($Object.PSObject.Properties.Name) -contains $Name
}

function Get-PropertyValue {
    param(
        [AllowNull()]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [AllowNull()]
        $Default = $null
    )

    if (Test-HasProperty -Object $Object -Name $Name) {
        return $Object.PSObject.Properties[$Name].Value
    }

    return $Default
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

function Assert-GitObjectIdWhenPopulated {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $text = Assert-StringValue -Value $Value -Context $Context
    if (-not [string]::IsNullOrWhiteSpace($text) -and $text -notmatch $script:GitObjectPattern) {
        throw "$Context must be a 40-character Git object ID when populated."
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

function Assert-BoundedPathOrUrl {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -eq "not_applicable") {
        return
    }
    if ($Value -match '^https?://') {
        return
    }
    if ([System.IO.Path]::IsPathRooted($Value) -or $Value -match '(^|[\\/])\.\.([\\/]|$)') {
        throw "$Context must be a repository-relative path without traversal."
    }
}

function Assert-ExistingRef {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Ref,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-BoundedPathOrUrl -Value $Ref -Context $Context
    if ($Ref -match '^https?://' -or $Ref -eq "not_applicable") {
        return
    }
    if (-not (Test-Path -LiteralPath (Resolve-RepositoryPath -PathValue $Ref))) {
        throw "$Context '$Ref' does not exist."
    }
}

function Get-R13QaIssueDetectionReportContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "actionable_qa", "r13_qa_issue_detection_report.contract.json")) -Label "R13 QA issue detection report contract"
}

function Assert-RequiredNonClaims {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$NonClaims,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($requiredNonClaim in $script:RequiredNonClaims) {
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

    return ($Line -match '(?i)\b(no|not|without|cannot|must not|does not|do not|is not|are not|did not|non-claim|non_claim|refuse|refuses|blocked|planned only|not yet delivered|detected as invalid|rejects|rejected)\b')
}

function Get-StringLeaves {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value
    )

    if ($null -eq $Value) {
        return
    }
    if ($Value -is [string]) {
        $PSCmdlet.WriteObject($Value, $false)
        return
    }
    if ($Value -is [System.Collections.IDictionary]) {
        foreach ($entry in $Value.GetEnumerator()) {
            Get-StringLeaves -Value $entry.Value
        }
        return
    }
    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
        foreach ($item in $Value) {
            Get-StringLeaves -Value $item
        }
        return
    }
    if ($Value -is [pscustomobject]) {
        foreach ($property in @($Value.PSObject.Properties)) {
            Get-StringLeaves -Value $property.Value
        }
    }
}

function Assert-NoSuccessorOpeningClaim {
    param(
        [Parameter(Mandatory = $true)]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($line in @(Get-StringLeaves -Value $Value)) {
        if ($line -match '(?i)\bR14\b.*\b(active|open|opened)\b|\bsuccessor milestone\b.*\b(active|open|opened)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims R14 or successor milestone opening. Offending text: $line"
        }
    }
}

function Get-StableIssueId {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        [Parameter(Mandatory = $true)]
        [string]$IssueType,
        [Parameter(Mandatory = $true)]
        [string]$Key
    )

    $inputText = ("{0}|{1}|{2}" -f $FilePath.ToLowerInvariant(), $IssueType.ToLowerInvariant(), $Key.ToLowerInvariant())
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($inputText)
        $hash = $sha.ComputeHash($bytes)
    }
    finally {
        $sha.Dispose()
    }

    $hex = -join ($hash[0..7] | ForEach-Object { $_.ToString("x2", [System.Globalization.CultureInfo]::InvariantCulture) })
    return "r13qi-$hex"
}

function Get-LineNumberForPattern {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Pattern
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return 0
    }

    try {
        $lines = [System.IO.File]::ReadAllLines($Path)
    }
    catch {
        return 0
    }

    for ($index = 0; $index -lt $lines.Count; $index += 1) {
        if ($lines[$index] -match $Pattern) {
            return ($index + 1)
        }
    }

    return 0
}

function Get-LineNumberForText {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Text
    )

    $escaped = [regex]::Escape($Text)
    return Get-LineNumberForPattern -Path $Path -Pattern $escaped
}

function Get-LineFromJsonException {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    if ($Message -match '(?i)\bline\s*:?\s*(\d+)') {
        return [int]$Matches[1]
    }
    if ($Message -match '(?i)\bLine\s+(\d+)') {
        return [int]$Matches[1]
    }

    return 0
}

function New-EvidenceRef {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Ref,
        [Parameter(Mandatory = $true)]
        [string]$EvidenceKind,
        [string]$AuthorityKind = "repo_detector",
        [string]$Scope = "repo"
    )

    $refId = "evidence-" + (Get-StableIssueId -FilePath $Ref -IssueType "evidence_ref" -Key $EvidenceKind).Substring(6)
    return [pscustomobject][ordered]@{
        ref_id = $refId
        ref = $Ref
        evidence_kind = $EvidenceKind
        authority_kind = $AuthorityKind
        scope = $Scope
    }
}

function Add-EvidenceRef {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.Generic.List[object]]$EvidenceRefs,
        [Parameter(Mandatory = $true)]
        [hashtable]$EvidenceRefIndex,
        [Parameter(Mandatory = $true)]
        [string]$Ref,
        [Parameter(Mandatory = $true)]
        [string]$EvidenceKind,
        [string]$AuthorityKind = "repo_detector",
        [string]$Scope = "repo"
    )

    $entry = New-EvidenceRef -Ref $Ref -EvidenceKind $EvidenceKind -AuthorityKind $AuthorityKind -Scope $Scope
    if (-not $EvidenceRefIndex.ContainsKey($entry.ref_id)) {
        $EvidenceRefs.Add($entry) | Out-Null
        $EvidenceRefIndex[$entry.ref_id] = $entry
    }

    return [string]$entry.ref_id
}

function Add-DetectorIssue {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.Generic.List[object]]$Issues,
        [Parameter(Mandatory = $true)]
        [hashtable]$IssueIndex,
        [Parameter(Mandatory = $true)]
        [string]$IssueType,
        [Parameter(Mandatory = $true)]
        [string]$Severity,
        [Parameter(Mandatory = $true)]
        [string]$BlockingStatus,
        [Parameter(Mandatory = $true)]
        [string]$Component,
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        [int]$Line = 0,
        [Parameter(Mandatory = $true)]
        [string]$Key,
        [Parameter(Mandatory = $true)]
        [string]$Title,
        [Parameter(Mandatory = $true)]
        [string]$ObservedBehavior,
        [Parameter(Mandatory = $true)]
        [string]$ExpectedBehavior,
        [Parameter(Mandatory = $true)]
        [string]$ReproductionCommand,
        [Parameter(Mandatory = $true)]
        [string]$RecommendedFix,
        [Parameter(Mandatory = $true)]
        [string[]]$EvidenceRefs,
        [string]$LifecycleStage = "detected",
        [string]$AuthorityKind = "repo_detector"
    )

    $issueId = Get-StableIssueId -FilePath $FilePath -IssueType $IssueType -Key $Key
    if ($IssueIndex.ContainsKey($issueId)) {
        return
    }

    $issue = [pscustomobject][ordered]@{
        issue_id = $issueId
        severity = $Severity
        blocking_status = $BlockingStatus
        status = "unresolved"
        component = $Component
        file_path = $FilePath
        line = [int]$Line
        issue_type = $IssueType
        title = $Title
        observed_behavior = $ObservedBehavior
        expected_behavior = $ExpectedBehavior
        reproduction_command = $ReproductionCommand
        recommended_fix = $RecommendedFix
        evidence_refs = @($EvidenceRefs)
        lifecycle_stage = $LifecycleStage
        detected_by = $script:R13DetectorVersion
        authority_kind = $AuthorityKind
    }

    $Issues.Add($issue) | Out-Null
    $IssueIndex[$issueId] = $true
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

function New-CommandRecord {
    param(
        [Parameter(Mandatory = $true)]
        [string]$CommandId,
        [Parameter(Mandatory = $true)]
        [string]$Command,
        [Parameter(Mandatory = $true)]
        [int]$ExitCode,
        [Parameter(Mandatory = $true)]
        [string]$Verdict,
        [string]$StartedAtUtc = (Get-UtcTimestamp),
        [string]$CompletedAtUtc = (Get-UtcTimestamp)
    )

    return [pscustomobject][ordered]@{
        command_id = $CommandId
        command = $Command
        exit_code = $ExitCode
        verdict = $Verdict
        started_at_utc = $StartedAtUtc
        completed_at_utc = $CompletedAtUtc
    }
}

function New-CheckRecord {
    param(
        [Parameter(Mandatory = $true)]
        [string]$CheckId,
        [Parameter(Mandatory = $true)]
        [string]$CheckType,
        [Parameter(Mandatory = $true)]
        [string]$Scope,
        [Parameter(Mandatory = $true)]
        [string]$Verdict,
        [Parameter(Mandatory = $true)]
        [int]$IssueCount,
        [Parameter(Mandatory = $true)]
        [string]$ReproductionCommand
    )

    return [pscustomobject][ordered]@{
        check_id = $CheckId
        check_type = $CheckType
        scope = $Scope
        verdict = $Verdict
        issue_count = $IssueCount
        reproduction_command = $ReproductionCommand
    }
}

function Test-IsInsideRepository {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue
    )

    $fullPath = [System.IO.Path]::GetFullPath($PathValue)
    $rootPath = [System.IO.Path]::GetFullPath((Get-RepositoryRoot)).TrimEnd([char[]]@([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar))
    return $fullPath.Equals($rootPath, [System.StringComparison]::OrdinalIgnoreCase) -or $fullPath.StartsWith($rootPath + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)
}

function Resolve-DetectionScope {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$ScopePath,
        [switch]$AllowRepoRootScan,
        [switch]$FixtureMode
    )

    $resolvedPaths = New-Object System.Collections.Generic.List[string]
    $refusalReasons = New-Object System.Collections.Generic.List[string]
    $files = New-Object System.Collections.Generic.List[string]
    $rootPath = [System.IO.Path]::GetFullPath((Get-RepositoryRoot)).TrimEnd([char[]]@([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar))
    $allowedExtensions = @(".json", ".ps1", ".psm1")
    if ($FixtureMode) {
        $allowedExtensions += ".md"
    }

    foreach ($scope in @($ScopePath)) {
        if ([string]::IsNullOrWhiteSpace($scope)) {
            $refusalReasons.Add("scope path cannot be empty.") | Out-Null
            continue
        }

        $resolved = Resolve-RepositoryPath -PathValue $scope
        $resolvedPaths.Add($resolved) | Out-Null

        if (-not (Test-IsInsideRepository -PathValue $resolved)) {
            $refusalReasons.Add("scope path '$scope' resolves outside the repository.") | Out-Null
            continue
        }
        if (-not (Test-Path -LiteralPath $resolved)) {
            $refusalReasons.Add("scope path '$scope' does not exist.") | Out-Null
            continue
        }
        if (([System.IO.Path]::GetFullPath($resolved).TrimEnd([char[]]@([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar))).Equals($rootPath, [System.StringComparison]::OrdinalIgnoreCase) -and -not $AllowRepoRootScan) {
            $refusalReasons.Add("broad repo-root scan is unsafe without -AllowRepoRootScan.") | Out-Null
            continue
        }

        $item = Get-Item -LiteralPath $resolved
        if ($item.PSIsContainer) {
            foreach ($file in @(Get-ChildItem -LiteralPath $resolved -File -Recurse | Where-Object {
                        $_.FullName -notmatch '[\\/]\.git[\\/]' -and $allowedExtensions -contains $_.Extension.ToLowerInvariant()
                    })) {
                $files.Add($file.FullName) | Out-Null
            }
        }
        elseif ($allowedExtensions -contains $item.Extension.ToLowerInvariant()) {
            $files.Add($item.FullName) | Out-Null
        }
    }

    $uniqueFiles = @($files.ToArray() | Sort-Object -Unique)
    return [pscustomobject][ordered]@{
        paths = @($ScopePath)
        resolved_paths = @($resolvedPaths.ToArray())
        files = @($uniqueFiles)
        refusal_reasons = @($refusalReasons.ToArray())
    }
}

function Test-IsIssueLikeObject {
    param(
        [Parameter(Mandatory = $true)]
        $Object
    )

    foreach ($name in @("issue_id", "issue_type", "observed_behavior", "expected_behavior", "severity", "blocking_status", "title")) {
        if (Test-HasProperty -Object $Object -Name $name) {
            return $true
        }
    }

    return $false
}

function Get-EvidenceRefKeys {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $EvidenceRefs
    )

    if ($null -eq $EvidenceRefs -or $EvidenceRefs -is [string]) {
        return
    }

    foreach ($evidence in @($EvidenceRefs)) {
        if ($evidence -is [string]) {
            $PSCmdlet.WriteObject($evidence, $false)
            continue
        }
        foreach ($name in @("ref_id", "ref", "evidence_ref")) {
            if (Test-HasProperty -Object $evidence -Name $name) {
                $value = [string](Get-PropertyValue -Object $evidence -Name $name -Default "")
                if (-not [string]::IsNullOrWhiteSpace($value)) {
                    $PSCmdlet.WriteObject($value, $false)
                }
            }
        }
    }
}

function Get-JsonObjects {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value,
        [string]$Path = "$"
    )

    if ($null -eq $Value) {
        return
    }
    if ($Value -is [pscustomobject]) {
        $PSCmdlet.WriteObject([pscustomobject][ordered]@{ Object = $Value; Path = $Path }, $false)
        foreach ($property in @($Value.PSObject.Properties)) {
            Get-JsonObjects -Value $property.Value -Path "$Path.$($property.Name)"
        }
        return
    }
    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
        $index = 0
        foreach ($item in $Value) {
            Get-JsonObjects -Value $item -Path "$Path[$index]"
            $index += 1
        }
    }
}

function Find-UnresolvedBlockingJsonObject {
    param(
        [Parameter(Mandatory = $true)]
        $Document
    )

    foreach ($entry in @(Get-JsonObjects -Value $Document)) {
        $object = $entry.Object
        if ((Test-HasProperty -Object $object -Name "blocking_status") -and [string](Get-PropertyValue -Object $object -Name "blocking_status" -Default "") -eq "blocking") {
            $status = [string](Get-PropertyValue -Object $object -Name "status" -Default "unresolved")
            if ($status -notin @("fixed", "resolved")) {
                return $entry
            }
        }
    }

    return $null
}

function Test-ContainsNarrativeOnlyQa {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text
    )

    if (Test-LineHasNegation -Line $Text) {
        return $false
    }

    return ($Text -match '(?i)\bnarrative[- ]only QA\b|\bchat transcript\b|\bQA passed based on narrative\b|\blooks good to me\b|\bmanual narrative says passed\b')
}

function Test-ExternalKindText {
    param(
        [AllowNull()]
        $Value
    )

    if ($null -eq $Value) {
        return $false
    }

    return ([string]$Value -match '(?i)external[_ -]?(proof|replay|runner|artifact)')
}

function Test-LocalScopeText {
    param(
        [AllowNull()]
        $Value
    )

    if ($null -eq $Value) {
        return $false
    }

    return ([string]$Value -match '(?i)^(local|local_only|repo_local|workspace)$')
}

function Inspect-JsonDetectorInput {
    param(
        [Parameter(Mandatory = $true)]
        [string]$File,
        [Parameter(Mandatory = $true)]
        $Document,
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.Generic.List[object]]$Issues,
        [Parameter(Mandatory = $true)]
        [hashtable]$IssueIndex,
        [Parameter(Mandatory = $true)]
        [string]$EvidenceRefId,
        [string]$ExpectedBranch = "",
        [string]$ExpectedHead = "",
        [string]$ExpectedTree = "",
        [switch]$FixtureMode
    )

    $relativePath = Convert-ToRepositoryRelativePath -PathValue $File
    $reproduction = "powershell -NoProfile -Command `"Import-Module .\tools\JsonRoot.psm1 -Force; Read-SingleJsonObject -Path '$relativePath'`""

    foreach ($identityField in @(
            @{ Name = "branch"; Expected = $ExpectedBranch },
            @{ Name = "head"; Expected = $ExpectedHead },
            @{ Name = "tree"; Expected = $ExpectedTree }
        )) {
        if (-not [string]::IsNullOrWhiteSpace($identityField.Expected) -and (Test-HasProperty -Object $Document -Name $identityField.Name)) {
            $actual = [string](Get-PropertyValue -Object $Document -Name $identityField.Name -Default "")
            if ($actual -ne $identityField.Expected) {
                Add-DetectorIssue -Issues $Issues -IssueIndex $IssueIndex -IssueType "stale_or_wrong_branch_head_tree_identity" -Severity "error" -BlockingStatus "blocking" -Component "repo_identity" -FilePath $relativePath -Line (Get-LineNumberForPattern -Path $File -Pattern ('"{0}"\s*:' -f [regex]::Escape($identityField.Name))) -Key $identityField.Name -Title "Stale or wrong repo identity was supplied" -ObservedBehavior ("{0} was '{1}'." -f $identityField.Name, $actual) -ExpectedBehavior ("{0} should match expected value '{1}' when provided." -f $identityField.Name, $identityField.Expected) -ReproductionCommand $reproduction -RecommendedFix "Regenerate the QA evidence from the current branch/head/tree or remove the stale identity claim." -EvidenceRefs @($EvidenceRefId)
            }
        }
    }

    foreach ($entry in @(Get-JsonObjects -Value $Document)) {
        $object = $entry.Object
        $pathKey = $entry.Path

        if (Test-HasProperty -Object $object -Name "required_evidence_refs") {
            $requiredRefs = Assert-StringArray -Value (Get-PropertyValue -Object $object -Name "required_evidence_refs") -Context "$relativePath required_evidence_refs" -AllowEmpty
            $availableRefs = @(Get-EvidenceRefKeys -EvidenceRefs (Get-PropertyValue -Object $object -Name "evidence_refs" -Default @()))
            foreach ($requiredRef in @($requiredRefs)) {
                if ($availableRefs -notcontains $requiredRef) {
                    Add-DetectorIssue -Issues $Issues -IssueIndex $IssueIndex -IssueType "missing_required_evidence_ref" -Severity "error" -BlockingStatus "blocking" -Component "qa_evidence" -FilePath $relativePath -Line (Get-LineNumberForPattern -Path $File -Pattern '"required_evidence_refs"\s*:') -Key ("{0}:{1}" -f $pathKey, $requiredRef) -Title "Required QA evidence ref is missing" -ObservedBehavior "A required evidence ref was declared but not present in evidence_refs." -ExpectedBehavior "Every required evidence ref should be backed by a concrete evidence_refs entry." -ReproductionCommand $reproduction -RecommendedFix "Add the missing evidence_refs entry or remove the unsupported required ref claim." -EvidenceRefs @($EvidenceRefId)
                }
            }
        }

        if (Test-IsIssueLikeObject -Object $object) {
            $issueKey = [string](Get-PropertyValue -Object $object -Name "issue_id" -Default (Get-PropertyValue -Object $object -Name "title" -Default $pathKey))
            $reproductionCommand = [string](Get-PropertyValue -Object $object -Name "reproduction_command" -Default "")
            if ([string]::IsNullOrWhiteSpace($reproductionCommand)) {
                Add-DetectorIssue -Issues $Issues -IssueIndex $IssueIndex -IssueType "missing_reproduction_command" -Severity "error" -BlockingStatus "blocking" -Component "qa_issue_evidence" -FilePath $relativePath -Line (Get-LineNumberForPattern -Path $File -Pattern '"reproduction_command"\s*:|\"issue_id\"\s*:|\"title\"\s*:') -Key $issueKey -Title "QA issue is missing a reproduction command" -ObservedBehavior "An issue-like object does not provide a runnable reproduction_command." -ExpectedBehavior "Every actionable QA issue should include a concrete reproduction command." -ReproductionCommand $reproduction -RecommendedFix "Add the exact command that reproduces or validates the issue." -EvidenceRefs @($EvidenceRefId)
            }

            $recommendedFix = [string](Get-PropertyValue -Object $object -Name "recommended_fix" -Default "")
            if ([string]::IsNullOrWhiteSpace($recommendedFix)) {
                Add-DetectorIssue -Issues $Issues -IssueIndex $IssueIndex -IssueType "missing_recommended_fix" -Severity "error" -BlockingStatus "blocking" -Component "qa_issue_evidence" -FilePath $relativePath -Line (Get-LineNumberForPattern -Path $File -Pattern '"recommended_fix"\s*:|\"issue_id\"\s*:|\"title\"\s*:') -Key $issueKey -Title "QA issue is missing a recommended fix" -ObservedBehavior "An issue-like object does not provide recommended_fix." -ExpectedBehavior "Every actionable QA issue should tell the fix executor what to repair." -ReproductionCommand $reproduction -RecommendedFix "Add a bounded recommended_fix that identifies the expected repair." -EvidenceRefs @($EvidenceRefId)
            }

            $issueEvidenceRefs = @(Get-EvidenceRefKeys -EvidenceRefs (Get-PropertyValue -Object $object -Name "evidence_refs" -Default @()))
            if ($issueEvidenceRefs.Count -eq 0) {
                Add-DetectorIssue -Issues $Issues -IssueIndex $IssueIndex -IssueType "missing_required_evidence_ref" -Severity "error" -BlockingStatus "blocking" -Component "qa_issue_evidence" -FilePath $relativePath -Line (Get-LineNumberForPattern -Path $File -Pattern '"evidence_refs"\s*:|\"issue_id\"\s*:|\"title\"\s*:') -Key ("{0}:evidence_refs" -f $issueKey) -Title "QA issue is missing required evidence refs" -ObservedBehavior "An issue-like object has no evidence_refs." -ExpectedBehavior "Each actionable issue should preserve at least one evidence ref." -ReproductionCommand $reproduction -RecommendedFix "Attach the source evidence ref for the issue." -EvidenceRefs @($EvidenceRefId)
            }
        }

        foreach ($authorityField in @("authority_kind", "qa_authority_kind", "actor_kind", "qa_runner_kind")) {
            if ((Test-HasProperty -Object $object -Name $authorityField) -and [string](Get-PropertyValue -Object $object -Name $authorityField -Default "") -match '(?i)executor_self_certification|self_certification') {
                Add-DetectorIssue -Issues $Issues -IssueIndex $IssueIndex -IssueType "executor_self_certification_qa_authority" -Severity "critical" -BlockingStatus "blocking" -Component "qa_authority" -FilePath $relativePath -Line (Get-LineNumberForPattern -Path $File -Pattern ('"{0}"\s*:' -f [regex]::Escape($authorityField))) -Key ("{0}:{1}" -f $pathKey, $authorityField) -Title "Executor self-certification was used as QA authority" -ObservedBehavior "$authorityField indicates executor self-certification." -ExpectedBehavior "QA authority must be separate from executor self-certification." -ReproductionCommand $reproduction -RecommendedFix "Replace the self-certifying authority with separate QA evidence or mark the artifact blocked." -EvidenceRefs @($EvidenceRefId)
            }
        }

        $evidenceKind = Get-PropertyValue -Object $object -Name "evidence_kind" -Default (Get-PropertyValue -Object $object -Name "claim_kind" -Default (Get-PropertyValue -Object $object -Name "proof_kind" -Default ""))
        $scope = Get-PropertyValue -Object $object -Name "scope" -Default (Get-PropertyValue -Object $object -Name "evidence_scope" -Default (Get-PropertyValue -Object $object -Name "artifact_scope" -Default ""))
        if ((Test-ExternalKindText -Value $evidenceKind) -and (Test-LocalScopeText -Value $scope)) {
            Add-DetectorIssue -Issues $Issues -IssueIndex $IssueIndex -IssueType "local_only_evidence_as_external_proof" -Severity "error" -BlockingStatus "blocking" -Component "external_proof" -FilePath $relativePath -Line (Get-LineNumberForPattern -Path $File -Pattern '"(evidence_kind|claim_kind|proof_kind|scope|evidence_scope|artifact_scope)"\s*:') -Key $pathKey -Title "Local-only evidence was claimed as external proof" -ObservedBehavior "The artifact describes external proof but its evidence scope is local." -ExpectedBehavior "External proof must come from external runner/artifact evidence, or the artifact must remain blocked." -ReproductionCommand $reproduction -RecommendedFix "Replace the local-only proof claim with actual external evidence or change the verdict/refusal posture." -EvidenceRefs @($EvidenceRefId)
        }
    }

    if ($FixtureMode) {
        foreach ($text in @(Get-StringLeaves -Value $Document)) {
            if (Test-ContainsNarrativeOnlyQa -Text $text) {
                Add-DetectorIssue -Issues $Issues -IssueIndex $IssueIndex -IssueType "narrative_only_qa_evidence" -Severity "error" -BlockingStatus "blocking" -Component "qa_evidence" -FilePath $relativePath -Line (Get-LineNumberForText -Path $File -Text $text) -Key "narrative-json" -Title "Narrative-only QA was presented as evidence" -ObservedBehavior "The artifact contains narrative-only QA pass language." -ExpectedBehavior "QA evidence should be backed by machine-readable checks, commands, and refs." -ReproductionCommand $reproduction -RecommendedFix "Replace narrative-only QA with structured detector, command, or external evidence." -EvidenceRefs @($EvidenceRefId)
                break
            }
        }
    }

    $aggregateVerdict = [string](Get-PropertyValue -Object $Document -Name "aggregate_verdict" -Default (Get-PropertyValue -Object $Document -Name "verdict" -Default ""))
    if ($aggregateVerdict -eq "passed") {
        $blockingEntry = Find-UnresolvedBlockingJsonObject -Document $Document
        if ($null -ne $blockingEntry) {
            Add-DetectorIssue -Issues $Issues -IssueIndex $IssueIndex -IssueType "aggregate_passed_with_unresolved_blocking_issue" -Severity "critical" -BlockingStatus "blocking" -Component "aggregate_verdict" -FilePath $relativePath -Line (Get-LineNumberForPattern -Path $File -Pattern '"aggregate_verdict"\s*:|\"blocking_status\"\s*:') -Key $blockingEntry.Path -Title "Aggregate passed hides an unresolved blocking issue" -ObservedBehavior "aggregate_verdict is passed while a nested blocking issue remains unresolved." -ExpectedBehavior "Passed aggregate verdicts must not hide unresolved blocking issues." -ReproductionCommand $reproduction -RecommendedFix "Change aggregate_verdict to failed or resolve the blocking issue with evidence before passing." -EvidenceRefs @($EvidenceRefId)
        }
    }
}

function Inspect-MarkdownDetectorInput {
    param(
        [Parameter(Mandatory = $true)]
        [string]$File,
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.Generic.List[object]]$Issues,
        [Parameter(Mandatory = $true)]
        [hashtable]$IssueIndex,
        [Parameter(Mandatory = $true)]
        [string]$EvidenceRefId,
        [switch]$FixtureMode
    )

    if (-not $FixtureMode) {
        return
    }

    $relativePath = Convert-ToRepositoryRelativePath -PathValue $File
    $lines = [System.IO.File]::ReadAllLines($File)
    for ($index = 0; $index -lt $lines.Count; $index += 1) {
        if (Test-ContainsNarrativeOnlyQa -Text $lines[$index]) {
            Add-DetectorIssue -Issues $Issues -IssueIndex $IssueIndex -IssueType "narrative_only_qa_evidence" -Severity "error" -BlockingStatus "blocking" -Component "qa_evidence" -FilePath $relativePath -Line ($index + 1) -Key "markdown:$($index + 1)" -Title "Narrative-only QA was presented as evidence" -ObservedBehavior "The Markdown input contains narrative-only QA pass language." -ExpectedBehavior "QA evidence should be backed by machine-readable checks, commands, and refs." -ReproductionCommand ("Get-Content -Raw -LiteralPath '{0}'" -f $relativePath) -RecommendedFix "Replace narrative-only QA prose with structured evidence or mark the detector input as blocked." -EvidenceRefs @($EvidenceRefId)
            return
        }
    }
}

function Test-R13QaIssueDetectionReportObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Report,
        [string]$SourceLabel = "R13 QA issue detection report"
    )

    $contract = Get-R13QaIssueDetectionReportContract
    Assert-RequiredObjectFields -Object $Report -FieldNames $contract.required_fields -Context $SourceLabel

    if ($Report.contract_version -ne $contract.contract_version) {
        throw "$SourceLabel contract_version must be '$($contract.contract_version)'."
    }
    if ($Report.artifact_type -ne "r13_qa_issue_detection_report") {
        throw "$SourceLabel artifact_type must be 'r13_qa_issue_detection_report'."
    }
    Assert-NonEmptyString -Value $Report.report_id -Context "$SourceLabel report_id" | Out-Null
    if ($Report.repository -ne $script:R13RepositoryName) {
        throw "$SourceLabel repository must be '$script:R13RepositoryName'."
    }
    if ($Report.branch -ne $script:R13Branch) {
        throw "$SourceLabel branch must be '$script:R13Branch'."
    }
    Assert-GitObjectIdWhenPopulated -Value $Report.head -Context "$SourceLabel head"
    Assert-GitObjectIdWhenPopulated -Value $Report.tree -Context "$SourceLabel tree"
    if ($Report.source_milestone -ne $script:R13Milestone) {
        throw "$SourceLabel source_milestone must be '$script:R13Milestone'."
    }
    if ($Report.source_task -ne $script:R13SourceTask) {
        throw "$SourceLabel source_task must be '$script:R13SourceTask'."
    }
    Assert-NonEmptyString -Value $Report.detector_version -Context "$SourceLabel detector_version" | Out-Null

    $scope = Assert-ObjectValue -Value $Report.detection_scope -Context "$SourceLabel detection_scope"
    Assert-RequiredObjectFields -Object $scope -FieldNames $contract.detection_scope_required_fields -Context "$SourceLabel detection_scope"
    Assert-StringArray -Value $scope.paths -Context "$SourceLabel detection_scope.paths" | Out-Null
    Assert-StringArray -Value $scope.resolved_paths -Context "$SourceLabel detection_scope.resolved_paths" -AllowEmpty | Out-Null
    Assert-BooleanValue -Value $scope.allow_repo_root_scan -Context "$SourceLabel detection_scope.allow_repo_root_scan" | Out-Null
    Assert-BooleanValue -Value $scope.fixture_mode -Context "$SourceLabel detection_scope.fixture_mode" | Out-Null
    Assert-NonEmptyString -Value $scope.description -Context "$SourceLabel detection_scope.description" | Out-Null

    $dependencyStatus = Assert-ObjectValue -Value $Report.dependency_status -Context "$SourceLabel dependency_status"
    Assert-RequiredObjectFields -Object $dependencyStatus -FieldNames $contract.dependency_status_required_fields -Context "$SourceLabel dependency_status"
    foreach ($dependencyName in @("json_root_reader", "powershell_parser", "psscriptanalyzer")) {
        $dependency = Assert-ObjectValue -Value $dependencyStatus.$dependencyName -Context "$SourceLabel dependency_status.$dependencyName"
        Assert-RequiredObjectFields -Object $dependency -FieldNames $contract.dependency_value_required_fields -Context "$SourceLabel dependency_status.$dependencyName"
        Assert-NonEmptyString -Value $dependency.name -Context "$SourceLabel dependency_status.$dependencyName.name" | Out-Null
        $available = Assert-BooleanValue -Value $dependency.available -Context "$SourceLabel dependency_status.$dependencyName.available"
        $status = Assert-NonEmptyString -Value $dependency.status -Context "$SourceLabel dependency_status.$dependencyName.status"
        Assert-AllowedValue -Value $status -AllowedValues $script:AllowedDependencyStatuses -Context "$SourceLabel dependency_status.$dependencyName.status"
        Assert-TimestampString -Value $dependency.checked_at_utc -Context "$SourceLabel dependency_status.$dependencyName.checked_at_utc" | Out-Null
        $details = Assert-StringValue -Value $dependency.details -Context "$SourceLabel dependency_status.$dependencyName.details"
        if (-not $available -and $status -ne "unavailable") {
            throw "$SourceLabel dependency_status.$dependencyName unavailable dependency must be recorded explicitly."
        }
        if ($dependencyName -eq "psscriptanalyzer" -and -not $available -and $details -notmatch '(?i)unavailable|not installed|full lint') {
            throw "$SourceLabel dependency_status.psscriptanalyzer must explicitly state that full lint was not run when unavailable."
        }
    }

    $commands = Assert-ObjectArray -Value $Report.commands_run -Context "$SourceLabel commands_run"
    foreach ($command in $commands) {
        Assert-RequiredObjectFields -Object $command -FieldNames $contract.command_required_fields -Context "$SourceLabel command"
        Assert-NonEmptyString -Value $command.command_id -Context "$SourceLabel command.command_id" | Out-Null
        Assert-NonEmptyString -Value $command.command -Context "$SourceLabel command.command" | Out-Null
        Assert-IntegerValue -Value $command.exit_code -Context "$SourceLabel command.exit_code" -Minimum 0 | Out-Null
        $commandVerdict = Assert-NonEmptyString -Value $command.verdict -Context "$SourceLabel command.verdict"
        Assert-AllowedValue -Value $commandVerdict -AllowedValues $script:AllowedCommandVerdicts -Context "$SourceLabel command.verdict"
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
        Assert-AllowedValue -Value $checkVerdict -AllowedValues $script:AllowedCheckVerdicts -Context "$SourceLabel check.verdict"
        Assert-IntegerValue -Value $check.issue_count -Context "$SourceLabel check.issue_count" -Minimum 0 | Out-Null
        Assert-NonEmptyString -Value $check.reproduction_command -Context "$SourceLabel check.reproduction_command" | Out-Null
    }

    $evidenceRefs = Assert-ObjectArray -Value $Report.evidence_refs -Context "$SourceLabel evidence_refs"
    $evidenceRefIds = @{}
    foreach ($evidence in $evidenceRefs) {
        Assert-RequiredObjectFields -Object $evidence -FieldNames $contract.evidence_ref_required_fields -Context "$SourceLabel evidence_refs"
        $refId = Assert-NonEmptyString -Value $evidence.ref_id -Context "$SourceLabel evidence_refs.ref_id"
        if ($evidenceRefIds.ContainsKey($refId)) {
            throw "$SourceLabel evidence_refs contains duplicate ref_id '$refId'."
        }
        $evidenceRefIds[$refId] = $true
        $ref = Assert-NonEmptyString -Value $evidence.ref -Context "$SourceLabel evidence_refs.ref"
        Assert-ExistingRef -Ref $ref -Context "$SourceLabel evidence_refs"
        $evidenceKind = Assert-NonEmptyString -Value $evidence.evidence_kind -Context "$SourceLabel evidence_refs.evidence_kind"
        $authorityKind = Assert-NonEmptyString -Value $evidence.authority_kind -Context "$SourceLabel evidence_refs.authority_kind"
        $evidenceScope = Assert-NonEmptyString -Value $evidence.scope -Context "$SourceLabel evidence_refs.scope"
        if ($evidenceKind -match '(?i)narrative|chat_transcript|narrative_only_qa') {
            throw "narrative-only QA treated as evidence is rejected."
        }
        if ($authorityKind -match '(?i)executor_self_certification|self_certification') {
            throw "executor self-certification treated as QA authority is rejected."
        }
        if (($evidenceKind -match '(?i)external[_ -]?(proof|replay|runner|artifact)') -and $evidenceScope -match '(?i)^(local|local_only|repo_local|workspace)$') {
            throw "local-only evidence cannot be used as external proof."
        }
    }

    $issues = Assert-ObjectArray -Value $Report.issues -Context "$SourceLabel issues" -AllowEmpty
    $seenIssueIds = @{}
    foreach ($issue in $issues) {
        Assert-RequiredObjectFields -Object $issue -FieldNames $contract.issue_required_fields -Context "$SourceLabel issue"
        $issueId = Assert-NonEmptyString -Value $issue.issue_id -Context "$SourceLabel issue.issue_id"
        if ($seenIssueIds.ContainsKey($issueId)) {
            throw "$SourceLabel issues contains duplicate issue_id '$issueId'."
        }
        $seenIssueIds[$issueId] = $true
        $severity = Assert-NonEmptyString -Value $issue.severity -Context "$SourceLabel issue.severity"
        Assert-AllowedValue -Value $severity -AllowedValues $script:AllowedIssueSeverities -Context "$SourceLabel issue.severity"
        $blockingStatus = Assert-NonEmptyString -Value $issue.blocking_status -Context "$SourceLabel issue.blocking_status"
        Assert-AllowedValue -Value $blockingStatus -AllowedValues $script:AllowedBlockingStatuses -Context "$SourceLabel issue.blocking_status"
        $status = Assert-NonEmptyString -Value $issue.status -Context "$SourceLabel issue.status"
        Assert-AllowedValue -Value $status -AllowedValues $script:AllowedIssueStatuses -Context "$SourceLabel issue.status"
        Assert-NonEmptyString -Value $issue.component -Context "$SourceLabel issue.component" | Out-Null
        $filePath = Assert-StringValue -Value $issue.file_path -Context "$SourceLabel issue.file_path"
        Assert-BoundedPathOrUrl -Value $filePath -Context "$SourceLabel issue.file_path"
        Assert-IntegerValue -Value $issue.line -Context "$SourceLabel issue.line" -Minimum 0 | Out-Null
        $issueType = Assert-NonEmptyString -Value $issue.issue_type -Context "$SourceLabel issue.issue_type"
        Assert-AllowedValue -Value $issueType -AllowedValues $script:AllowedIssueTypes -Context "$SourceLabel issue.issue_type"
        Assert-NonEmptyString -Value $issue.title -Context "$SourceLabel issue.title" | Out-Null
        Assert-NonEmptyString -Value $issue.observed_behavior -Context "$SourceLabel issue.observed_behavior" | Out-Null
        Assert-NonEmptyString -Value $issue.expected_behavior -Context "$SourceLabel issue.expected_behavior" | Out-Null
        Assert-NonEmptyString -Value $issue.reproduction_command -Context "$SourceLabel issue.reproduction_command" | Out-Null
        Assert-NonEmptyString -Value $issue.recommended_fix -Context "$SourceLabel issue.recommended_fix" | Out-Null
        $issueEvidenceRefs = Assert-StringArray -Value $issue.evidence_refs -Context "$SourceLabel issue.evidence_refs"
        foreach ($issueEvidenceRef in @($issueEvidenceRefs)) {
            if (-not $evidenceRefIds.ContainsKey($issueEvidenceRef)) {
                throw "$SourceLabel issue.evidence_refs '$issueEvidenceRef' must resolve to report evidence_refs."
            }
        }
        $lifecycleStage = Assert-NonEmptyString -Value $issue.lifecycle_stage -Context "$SourceLabel issue.lifecycle_stage"
        Assert-AllowedValue -Value $lifecycleStage -AllowedValues $script:AllowedLifecycleStages -Context "$SourceLabel issue.lifecycle_stage"
        Assert-NonEmptyString -Value $issue.detected_by -Context "$SourceLabel issue.detected_by" | Out-Null
        $authorityKind = Assert-NonEmptyString -Value $issue.authority_kind -Context "$SourceLabel issue.authority_kind"
        if ($authorityKind -match '(?i)executor_self_certification|self_certification') {
            throw "executor self-certification treated as QA authority is rejected."
        }
    }

    $summary = Assert-ObjectValue -Value $Report.summary -Context "$SourceLabel summary"
    Assert-RequiredObjectFields -Object $summary -FieldNames $contract.summary_required_fields -Context "$SourceLabel summary"
    $totalIssueCount = Assert-IntegerValue -Value $summary.total_issue_count -Context "$SourceLabel summary.total_issue_count" -Minimum 0
    $blockingIssueCount = Assert-IntegerValue -Value $summary.blocking_issue_count -Context "$SourceLabel summary.blocking_issue_count" -Minimum 0
    $criticalCount = Assert-IntegerValue -Value $summary.critical_count -Context "$SourceLabel summary.critical_count" -Minimum 0
    $errorCount = Assert-IntegerValue -Value $summary.error_count -Context "$SourceLabel summary.error_count" -Minimum 0
    $warningCount = Assert-IntegerValue -Value $summary.warning_count -Context "$SourceLabel summary.warning_count" -Minimum 0
    $infoCount = Assert-IntegerValue -Value $summary.info_count -Context "$SourceLabel summary.info_count" -Minimum 0
    Assert-IntegerValue -Value $summary.command_count -Context "$SourceLabel summary.command_count" -Minimum 0 | Out-Null
    Assert-IntegerValue -Value $summary.check_count -Context "$SourceLabel summary.check_count" -Minimum 0 | Out-Null

    if ($totalIssueCount -ne $issues.Count) {
        throw "$SourceLabel summary.total_issue_count must match issues."
    }
    if ($blockingIssueCount -ne @($issues | Where-Object { $_.blocking_status -eq "blocking" }).Count) {
        throw "$SourceLabel summary.blocking_issue_count must match issues."
    }
    if ($criticalCount -ne @($issues | Where-Object { $_.severity -eq "critical" }).Count -or $errorCount -ne @($issues | Where-Object { $_.severity -eq "error" }).Count -or $warningCount -ne @($issues | Where-Object { $_.severity -eq "warning" }).Count -or $infoCount -ne @($issues | Where-Object { $_.severity -eq "info" }).Count) {
        throw "$SourceLabel summary severity counts must match issues."
    }

    $aggregateVerdict = Assert-NonEmptyString -Value $Report.aggregate_verdict -Context "$SourceLabel aggregate_verdict"
    Assert-AllowedValue -Value $aggregateVerdict -AllowedValues $script:AllowedAggregateVerdicts -Context "$SourceLabel aggregate_verdict"
    $reproductionCommands = Assert-StringArray -Value $Report.reproduction_commands -Context "$SourceLabel reproduction_commands"
    $refusalReasons = Assert-StringArray -Value $Report.refusal_reasons -Context "$SourceLabel refusal_reasons" -AllowEmpty
    Assert-TimestampString -Value $Report.created_at_utc -Context "$SourceLabel created_at_utc" | Out-Null
    $nonClaims = Assert-StringArray -Value $Report.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel
    Assert-NoSuccessorOpeningClaim -Value $Report -Context $SourceLabel

    $unresolvedBlocking = @($issues | Where-Object {
            ($_.blocking_status -eq "blocking" -or $_.severity -in @("critical", "error")) -and $_.status -notin @("fixed", "resolved")
        })
    if ($aggregateVerdict -eq "passed" -and $unresolvedBlocking.Count -gt 0) {
        throw "passed aggregate verdict with unresolved blocking issues is rejected."
    }
    if ($aggregateVerdict -eq "passed" -and $refusalReasons.Count -gt 0) {
        throw "$SourceLabel passed aggregate verdict requires empty refusal_reasons."
    }
    if ($aggregateVerdict -eq "failed" -and $unresolvedBlocking.Count -eq 0) {
        throw "$SourceLabel failed aggregate verdict requires blocking, critical, or error issues."
    }
    if ($aggregateVerdict -eq "blocked" -and $refusalReasons.Count -eq 0) {
        throw "$SourceLabel blocked aggregate verdict requires refusal_reasons."
    }

    if ($reproductionCommands.Count -eq 0) {
        throw "$SourceLabel must include reproduction_commands."
    }

    $PSCmdlet.WriteObject([pscustomobject][ordered]@{
        ReportId = $Report.report_id
        Repository = $Report.repository
        Branch = $Report.branch
        Head = $Report.head
        Tree = $Report.tree
        AggregateVerdict = $aggregateVerdict
        IssueCount = $issues.Count
        BlockingIssueCount = $blockingIssueCount
        EvidenceRefCount = $evidenceRefs.Count
        RefusalReasonCount = $refusalReasons.Count
    }, $false)
}

function Test-R13QaIssueDetectionReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ReportPath
    )

    $report = Get-JsonDocument -Path $ReportPath -Label "R13 QA issue detection report"
    return Test-R13QaIssueDetectionReportObject -Report $report -SourceLabel "R13 QA issue detection report"
}

function Invoke-R13QaIssueDetector {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$ScopePath,
        [switch]$AllowRepoRootScan,
        [switch]$FixtureMode,
        [string]$ExpectedBranch = "",
        [string]$ExpectedHead = "",
        [string]$ExpectedTree = ""
    )

    $commands = New-Object System.Collections.Generic.List[object]
    $checks = New-Object System.Collections.Generic.List[object]
    $issues = New-Object System.Collections.Generic.List[object]
    $evidenceRefs = New-Object System.Collections.Generic.List[object]
    $issueIndex = @{}
    $evidenceRefIndex = @{}

    $branchStarted = Get-UtcTimestamp
    $branch = (@(Invoke-GitLines -Arguments @("branch", "--show-current")))[0].Trim()
    $head = (@(Invoke-GitLines -Arguments @("rev-parse", "HEAD")))[0].Trim()
    $tree = (@(Invoke-GitLines -Arguments @("rev-parse", "HEAD^{tree}")))[0].Trim()
    $commands.Add((New-CommandRecord -CommandId "git-identity" -Command "git branch --show-current; git rev-parse HEAD; git rev-parse HEAD^{tree}" -ExitCode 0 -Verdict "passed" -StartedAtUtc $branchStarted -CompletedAtUtc (Get-UtcTimestamp))) | Out-Null

    Add-EvidenceRef -EvidenceRefs $evidenceRefs -EvidenceRefIndex $evidenceRefIndex -Ref "contracts/actionable_qa/r13_qa_issue_detection_report.contract.json" -EvidenceKind "contract" -AuthorityKind "repo_contract" | Out-Null
    Add-EvidenceRef -EvidenceRefs $evidenceRefs -EvidenceRefIndex $evidenceRefIndex -Ref "tools/R13QaIssueDetector.psm1" -EvidenceKind "detector_module" -AuthorityKind "repo_detector" | Out-Null

    $psaCheckedAt = Get-UtcTimestamp
    $psaModule = Get-Module -ListAvailable -Name PSScriptAnalyzer | Select-Object -First 1
    $psaAvailable = $null -ne $psaModule
    $psaStatus = if ($psaAvailable) { "available" } else { "unavailable" }
    $psaDetails = if ($psaAvailable) { "PSScriptAnalyzer module found at $($psaModule.Path)." } else { "PSScriptAnalyzer unavailable/not installed; detector did not run full lint and only PowerShell parser checks are claimed." }

    $dependencyStatus = [pscustomobject][ordered]@{
        json_root_reader = [pscustomobject][ordered]@{
            name = "JsonRoot.Read-SingleJsonObject"
            available = $true
            status = "available"
            checked_at_utc = Get-UtcTimestamp
            details = "JSON inputs are read through the repository JsonRoot.Read-SingleJsonObject helper."
        }
        powershell_parser = [pscustomobject][ordered]@{
            name = "System.Management.Automation.Language.Parser.ParseFile"
            available = $true
            status = "available"
            checked_at_utc = Get-UtcTimestamp
            details = "PowerShell files are parsed with Parser.ParseFile before any optional linting."
        }
        psscriptanalyzer = [pscustomobject][ordered]@{
            name = "PSScriptAnalyzer"
            available = [bool]$psaAvailable
            status = $psaStatus
            checked_at_utc = $psaCheckedAt
            details = $psaDetails
        }
    }

    $scopeStarted = Get-UtcTimestamp
    $scope = Resolve-DetectionScope -ScopePath $ScopePath -AllowRepoRootScan:$AllowRepoRootScan -FixtureMode:$FixtureMode
    $refusalReasons = New-Object System.Collections.Generic.List[string]
    foreach ($reason in @($scope.refusal_reasons)) {
        $refusalReasons.Add([string]$reason) | Out-Null
    }
    $commands.Add((New-CommandRecord -CommandId "scope-resolution" -Command ("Resolve detector scope: {0}" -f ($ScopePath -join ", ")) -ExitCode $(if ($refusalReasons.Count -eq 0) { 0 } else { 1 }) -Verdict $(if ($refusalReasons.Count -eq 0) { "passed" } else { "blocked" }) -StartedAtUtc $scopeStarted -CompletedAtUtc (Get-UtcTimestamp))) | Out-Null
    $checks.Add((New-CheckRecord -CheckId "scope-validation" -CheckType "scope_validation" -Scope ($ScopePath -join ", ") -Verdict $(if ($refusalReasons.Count -eq 0) { "passed" } else { "blocked" }) -IssueCount 0 -ReproductionCommand "powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_r13_qa_issue_detector.ps1 -ScopePath <path> -OutputPath <report>")) | Out-Null

    if ($refusalReasons.Count -eq 0) {
        $jsonIssueStart = $issues.Count
        foreach ($file in @($scope.files | Where-Object { [System.IO.Path]::GetExtension($_).ToLowerInvariant() -eq ".json" })) {
            $relativePath = Convert-ToRepositoryRelativePath -PathValue $file
            $evidenceRefId = Add-EvidenceRef -EvidenceRefs $evidenceRefs -EvidenceRefIndex $evidenceRefIndex -Ref $relativePath -EvidenceKind "scoped_input" -AuthorityKind "repo_fixture" -Scope "repo"
            try {
                $document = Read-SingleJsonObject -Path $file -Label $relativePath
                Inspect-JsonDetectorInput -File $file -Document $document -Issues $issues -IssueIndex $issueIndex -EvidenceRefId $evidenceRefId -ExpectedBranch $ExpectedBranch -ExpectedHead $ExpectedHead -ExpectedTree $ExpectedTree -FixtureMode:$FixtureMode
            }
            catch {
                $message = $_.Exception.Message
                Add-DetectorIssue -Issues $issues -IssueIndex $issueIndex -IssueType "malformed_json" -Severity "error" -BlockingStatus "blocking" -Component "json_parse" -FilePath $relativePath -Line (Get-LineFromJsonException -Message $message) -Key "parse" -Title "Malformed JSON input cannot be inspected" -ObservedBehavior $message -ExpectedBehavior "Detector JSON inputs should parse as a single JSON object through JsonRoot.Read-SingleJsonObject." -ReproductionCommand ("powershell -NoProfile -Command `"Import-Module .\tools\JsonRoot.psm1 -Force; Read-SingleJsonObject -Path '$relativePath'`"") -RecommendedFix "Repair the JSON syntax and ensure the root is one JSON object." -EvidenceRefs @($evidenceRefId)
            }
        }
        $jsonIssues = $issues.Count - $jsonIssueStart
        $checks.Add((New-CheckRecord -CheckId "json-input-inspection" -CheckType "json_input_inspection" -Scope ($ScopePath -join ", ") -Verdict $(if ($jsonIssues -eq 0) { "passed" } else { "failed" }) -IssueCount $jsonIssues -ReproductionCommand "powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_r13_qa_issue_detector.ps1 -ScopePath <path> -OutputPath <report> -FixtureMode")) | Out-Null
        $commands.Add((New-CommandRecord -CommandId "json-root-reader" -Command "JsonRoot.Read-SingleJsonObject over scoped .json files" -ExitCode $(if ($jsonIssues -eq 0) { 0 } else { 1 }) -Verdict $(if ($jsonIssues -eq 0) { "passed" } else { "failed" }))) | Out-Null

        $markdownIssueStart = $issues.Count
        foreach ($file in @($scope.files | Where-Object { [System.IO.Path]::GetExtension($_).ToLowerInvariant() -eq ".md" })) {
            $relativePath = Convert-ToRepositoryRelativePath -PathValue $file
            $evidenceRefId = Add-EvidenceRef -EvidenceRefs $evidenceRefs -EvidenceRefIndex $evidenceRefIndex -Ref $relativePath -EvidenceKind "scoped_input" -AuthorityKind "repo_fixture" -Scope "repo"
            Inspect-MarkdownDetectorInput -File $file -Issues $issues -IssueIndex $issueIndex -EvidenceRefId $evidenceRefId -FixtureMode:$FixtureMode
        }
        $markdownIssues = $issues.Count - $markdownIssueStart
        $checks.Add((New-CheckRecord -CheckId "markdown-fixture-inspection" -CheckType "markdown_fixture_inspection" -Scope ($ScopePath -join ", ") -Verdict $(if ($markdownIssues -eq 0) { "passed" } else { "failed" }) -IssueCount $markdownIssues -ReproductionCommand "powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_r13_qa_issue_detector.ps1 -ScopePath <path> -OutputPath <report> -FixtureMode")) | Out-Null

        $psIssueStart = $issues.Count
        foreach ($file in @($scope.files | Where-Object { [System.IO.Path]::GetExtension($_).ToLowerInvariant() -in @(".ps1", ".psm1") })) {
            $relativePath = Convert-ToRepositoryRelativePath -PathValue $file
            $evidenceRefId = Add-EvidenceRef -EvidenceRefs $evidenceRefs -EvidenceRefIndex $evidenceRefIndex -Ref $relativePath -EvidenceKind "scoped_input" -AuthorityKind "repo_source" -Scope "repo"
            $tokens = $null
            $parseErrors = $null
            [System.Management.Automation.Language.Parser]::ParseFile($file, [ref]$tokens, [ref]$parseErrors) | Out-Null
            foreach ($parseError in @($parseErrors)) {
                Add-DetectorIssue -Issues $issues -IssueIndex $issueIndex -IssueType "powershell_parse_error" -Severity "error" -BlockingStatus "blocking" -Component "powershell_parse" -FilePath $relativePath -Line $parseError.Extent.StartLineNumber -Key $parseError.Extent.StartLineNumber -Title "PowerShell parser error detected" -ObservedBehavior $parseError.Message -ExpectedBehavior "Scoped PowerShell files should parse without parser errors." -ReproductionCommand ("powershell -NoProfile -Command `"[System.Management.Automation.Language.Parser]::ParseFile('$relativePath', [ref]`$null, [ref]`$null)`"") -RecommendedFix "Fix the PowerShell syntax error before using this script or module." -EvidenceRefs @($evidenceRefId)
            }
        }
        $psIssues = $issues.Count - $psIssueStart
        $checks.Add((New-CheckRecord -CheckId "powershell-parse" -CheckType "powershell_parse" -Scope ($ScopePath -join ", ") -Verdict $(if ($psIssues -eq 0) { "passed" } else { "failed" }) -IssueCount $psIssues -ReproductionCommand "PowerShell Parser.ParseFile over scoped .ps1/.psm1 files")) | Out-Null
        $commands.Add((New-CommandRecord -CommandId "powershell-parse" -Command "Parser.ParseFile over scoped .ps1/.psm1 files" -ExitCode $(if ($psIssues -eq 0) { 0 } else { 1 }) -Verdict $(if ($psIssues -eq 0) { "passed" } else { "failed" }))) | Out-Null

        if ($psaAvailable) {
            $psaIssueStart = $issues.Count
            Import-Module PSScriptAnalyzer -Force
            foreach ($file in @($scope.files | Where-Object { [System.IO.Path]::GetExtension($_).ToLowerInvariant() -in @(".ps1", ".psm1") })) {
                $relativePath = Convert-ToRepositoryRelativePath -PathValue $file
                $evidenceRefId = Add-EvidenceRef -EvidenceRefs $evidenceRefs -EvidenceRefIndex $evidenceRefIndex -Ref $relativePath -EvidenceKind "scoped_input" -AuthorityKind "repo_source" -Scope "repo"
                foreach ($finding in @(Invoke-ScriptAnalyzer -Path $file)) {
                    $severity = switch ([string]$finding.Severity) {
                        "Error" { "error" }
                        "Warning" { "warning" }
                        default { "info" }
                    }
                    $blockingStatus = if ($severity -eq "error") { "blocking" } elseif ($severity -eq "warning") { "non_blocking" } else { "advisory" }
                    Add-DetectorIssue -Issues $issues -IssueIndex $issueIndex -IssueType "psscriptanalyzer_finding" -Severity $severity -BlockingStatus $blockingStatus -Component "psscriptanalyzer" -FilePath $relativePath -Line ([int]$finding.Line) -Key ([string]$finding.RuleName + ":" + [string]$finding.Line) -Title "PSScriptAnalyzer finding detected" -ObservedBehavior ([string]$finding.Message) -ExpectedBehavior "Scoped PowerShell files should satisfy the available PSScriptAnalyzer rules or record an intentional exception." -ReproductionCommand ("Invoke-ScriptAnalyzer -Path '{0}'" -f $relativePath) -RecommendedFix "Review the analyzer finding and adjust the script if it is actionable." -EvidenceRefs @($evidenceRefId)
                }
            }
            $psaIssues = $issues.Count - $psaIssueStart
            $checks.Add((New-CheckRecord -CheckId "psscriptanalyzer" -CheckType "psscriptanalyzer" -Scope ($ScopePath -join ", ") -Verdict $(if ($psaIssues -eq 0) { "passed" } else { "failed" }) -IssueCount $psaIssues -ReproductionCommand "Invoke-ScriptAnalyzer -Path <scoped-file>")) | Out-Null
            $commands.Add((New-CommandRecord -CommandId "psscriptanalyzer" -Command "Invoke-ScriptAnalyzer over scoped PowerShell files" -ExitCode $(if ($psaIssues -eq 0) { 0 } else { 1 }) -Verdict $(if ($psaIssues -eq 0) { "passed" } else { "failed" }))) | Out-Null
        }
        else {
            $checks.Add((New-CheckRecord -CheckId "psscriptanalyzer" -CheckType "psscriptanalyzer" -Scope ($ScopePath -join ", ") -Verdict "skipped" -IssueCount 0 -ReproductionCommand "Get-Module -ListAvailable -Name PSScriptAnalyzer")) | Out-Null
            $commands.Add((New-CommandRecord -CommandId "psscriptanalyzer" -Command "Get-Module -ListAvailable -Name PSScriptAnalyzer" -ExitCode 0 -Verdict "not_run" -StartedAtUtc $psaCheckedAt -CompletedAtUtc (Get-UtcTimestamp))) | Out-Null
        }
    }

    $blockingIssueCount = @($issues | Where-Object { $_.blocking_status -eq "blocking" }).Count
    $criticalCount = @($issues | Where-Object { $_.severity -eq "critical" }).Count
    $errorCount = @($issues | Where-Object { $_.severity -eq "error" }).Count
    $warningCount = @($issues | Where-Object { $_.severity -eq "warning" }).Count
    $infoCount = @($issues | Where-Object { $_.severity -eq "info" }).Count

    $aggregateVerdict = "passed"
    if ($refusalReasons.Count -gt 0) {
        $aggregateVerdict = "blocked"
    }
    elseif ($blockingIssueCount -gt 0 -or $criticalCount -gt 0 -or $errorCount -gt 0) {
        $aggregateVerdict = "failed"
    }

    $report = [pscustomobject][ordered]@{
        contract_version = "v1"
        artifact_type = "r13_qa_issue_detection_report"
        report_id = "r13-003-qa-issue-detection-" + [guid]::NewGuid().ToString("N")
        repository = $script:R13RepositoryName
        branch = $branch
        head = $head
        tree = $tree
        source_milestone = $script:R13Milestone
        source_task = $script:R13SourceTask
        detector_version = $script:R13DetectorVersion
        detection_scope = [pscustomobject][ordered]@{
            paths = @($ScopePath)
            resolved_paths = @($scope.resolved_paths)
            allow_repo_root_scan = [bool]$AllowRepoRootScan
            fixture_mode = [bool]$FixtureMode
            description = "R13-003 source-mapped detector over explicitly scoped repository paths."
        }
        dependency_status = $dependencyStatus
        commands_run = @($commands.ToArray())
        checks_run = @($checks.ToArray())
        issues = @($issues.ToArray())
        summary = [pscustomobject][ordered]@{
            total_issue_count = $issues.Count
            blocking_issue_count = $blockingIssueCount
            critical_count = $criticalCount
            error_count = $errorCount
            warning_count = $warningCount
            info_count = $infoCount
            command_count = $commands.Count
            check_count = $checks.Count
        }
        aggregate_verdict = $aggregateVerdict
        reproduction_commands = @(
            "powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_r13_qa_issue_detector.ps1 -ScopePath <path> -OutputPath <report>",
            "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r13_qa_issue_detector.ps1"
        )
        evidence_refs = @($evidenceRefs.ToArray())
        refusal_reasons = @($refusalReasons.ToArray())
        created_at_utc = Get-UtcTimestamp
        non_claims = @($script:RequiredNonClaims)
    }

    Test-R13QaIssueDetectionReportObject -Report $report -SourceLabel "R13 QA issue detection report draft" | Out-Null
    $PSCmdlet.WriteObject($report, $false)
}

Export-ModuleMember -Function Get-R13QaIssueDetectionReportContract, Test-R13QaIssueDetectionReportObject, Test-R13QaIssueDetectionReport, Invoke-R13QaIssueDetector
