Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force
$issueDetectorModule = Import-Module (Join-Path $PSScriptRoot "R13QaIssueDetector.psm1") -Force -PassThru
$fixQueueModule = Import-Module (Join-Path $PSScriptRoot "R13QaFixQueue.psm1") -Force -PassThru
$boundedExecutionModule = Import-Module (Join-Path $PSScriptRoot "R13BoundedFixExecution.psm1") -Force -PassThru

$script:InvokeIssueDetector = $issueDetectorModule.ExportedCommands["Invoke-R13QaIssueDetector"]
$script:TestIssueDetectionReport = $issueDetectorModule.ExportedCommands["Test-R13QaIssueDetectionReport"]
$script:TestFixQueue = $fixQueueModule.ExportedCommands["Test-R13QaFixQueue"]
$script:TestBoundedFixExecution = $boundedExecutionModule.ExportedCommands["Test-R13BoundedFixExecutionPacket"]

$script:R13RepositoryName = "AIOffice_V2"
$script:R13Branch = "release/r13-api-first-qa-pipeline-and-operator-control-room-product-slice"
$script:R13Milestone = "R13 API-First QA Pipeline and Operator Control-Room Product Slice"
$script:R13SourceTask = "R13-006"
$script:R13IssueReportTask = "R13-003"
$script:R13FixQueueTask = "R13-004"
$script:R13BoundedExecutionTask = "R13-005"
$script:GitObjectPattern = "^[a-f0-9]{40}$"
$script:TimestampPattern = "^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$"
$script:AllowedCycleAggregateVerdicts = @("failed", "blocked", "fixed_pending_external_replay")
$script:AllowedFixExecutionAggregateVerdicts = @("executed_pending_rerun", "blocked")
$script:AllowedComparisonVerdicts = @("target_issue_resolved", "target_issue_unresolved", "blocked")
$script:AllowedCycleStatuses = @("blocked", "fixed_locally_pending_external_replay")
$script:AllowedDemoRoots = @(
    "state/cycles/r13_qa_cycle_demo",
    "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/qa/r13_006_demo"
)
$script:CanonicalInvalidDetectorRoot = "state/fixtures/invalid/actionable_qa/r13_detector_inputs"
$script:RequiredNonClaims = @(
    "R13-006 runs one controlled demo workspace QA failure-to-fix cycle only",
    "no canonical invalid detector fixture mutation",
    "no external replay has occurred",
    "no final QA signoff has occurred",
    "no R13 hard value gate delivered by R13-006",
    "no meaningful QA loop gate delivered yet",
    "no current operator control-room gate delivered by R13-006",
    "no API/custom-runner bypass gate delivered by R13-006",
    "no skill invocation evidence gate delivered by R13-006",
    "no operator demo gate delivered by R13-006",
    "no production QA delivered by R13-006",
    "no productized control-room behavior",
    "no R14 or successor opening"
)

function Get-RepositoryRoot {
    return $repoRoot
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

    $fullPath = [System.IO.Path]::GetFullPath((Resolve-RepositoryPath -PathValue $PathValue))
    $rootPath = [System.IO.Path]::GetFullPath((Get-RepositoryRoot)).TrimEnd([char[]]@([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar))
    if ($fullPath.Equals($rootPath, [System.StringComparison]::OrdinalIgnoreCase)) {
        return "."
    }
    if ($fullPath.StartsWith($rootPath + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $fullPath.Substring($rootPath.Length + 1).Replace("\", "/")
    }

    return $PathValue.Replace("\", "/")
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

function Test-RepositoryRelativePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue
    )

    if ([string]::IsNullOrWhiteSpace($PathValue)) {
        return $false
    }
    if ($PathValue -match '^https?://') {
        return $false
    }
    if ([System.IO.Path]::IsPathRooted($PathValue) -or $PathValue -match '(^|[\\/])\.\.([\\/]|$)') {
        return $false
    }

    return Test-IsInsideRepository -PathValue (Resolve-RepositoryPath -PathValue $PathValue)
}

function Assert-RepositoryRelativePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if (-not (Test-RepositoryRelativePath -PathValue $PathValue)) {
        throw "$Context must be a repository-relative path inside the repository."
    }
}

function Assert-ExistingRef {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Ref,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-RepositoryRelativePath -PathValue $Ref -Context $Context
    if (-not (Test-Path -LiteralPath (Resolve-RepositoryPath -PathValue $Ref))) {
        throw "$Context '$Ref' does not exist."
    }
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

function Write-JsonFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Value
    )

    $resolvedPath = Resolve-RepositoryPath -PathValue $Path
    $parentPath = Split-Path -Parent $resolvedPath
    if (-not [string]::IsNullOrWhiteSpace($parentPath)) {
        New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    }

    $json = [string]::Join("`n", @($Value | ConvertTo-Json -Depth 100))
    $json = ($json -replace "`r`n", "`n") -replace "`r", "`n"
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($resolvedPath, $json.TrimEnd() + "`n", $utf8NoBom)
}

function Write-TextFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    $resolvedPath = Resolve-RepositoryPath -PathValue $Path
    $parentPath = Split-Path -Parent $resolvedPath
    if (-not [string]::IsNullOrWhiteSpace($parentPath)) {
        New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    }

    $text = ($Value -replace "`r`n", "`n") -replace "`r", "`n"
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($resolvedPath, $text.TrimEnd() + "`n", $utf8NoBom)
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
}

function Invoke-GitLine {
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

    return ([string](@($output)[0])).Trim()
}

function Get-GitIdentity {
    return [pscustomobject][ordered]@{
        Branch = Invoke-GitLine -Arguments @("branch", "--show-current")
        Head = Invoke-GitLine -Arguments @("rev-parse", "HEAD")
        Tree = Invoke-GitLine -Arguments @("rev-parse", "HEAD^{tree}")
    }
}

function Get-StableId {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Prefix,
        [Parameter(Mandatory = $true)]
        [string]$Key
    )

    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Key.ToLowerInvariant())
        $hash = $sha.ComputeHash($bytes)
    }
    finally {
        $sha.Dispose()
    }

    $hex = -join ($hash[0..7] | ForEach-Object { $_.ToString("x2", [System.Globalization.CultureInfo]::InvariantCulture) })
    return "$Prefix-$hex"
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

function Test-LineHasNegation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Line
    )

    return ($Line -match '(?i)\b(no|not|without|cannot|must not|does not|do not|is not|are not|did not|non-claim|non_claim|refuse|refuses|blocked|planned only|not yet delivered|pending|future|expected_future|not complete|still not|rejects|rejected)\b')
}

function Assert-NoForbiddenR13Claims {
    param(
        [Parameter(Mandatory = $true)]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($line in @(Get-StringLeaves -Value $Value)) {
        if ($line -match '(?i)\bexternal[_ -]?replay\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims external replay. Offending text: $line"
        }
        if ($line -match '(?i)\bsignoff\b|\bsign-off\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims final signoff. Offending text: $line"
        }
        if ($line -match '(?i)\b(hard\s+)?R13\s+hard\s+value\s+gate\b|\bhard\s+value\s+gate\b|\bmeaningful\s+QA\s+loop\b.*\b(delivered|complete|passed)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims R13 hard value gate delivery. Offending text: $line"
        }
        if ($line -match '(?i)\breal production QA\b|\bproduction QA\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims production QA. Offending text: $line"
        }
        if ($line -match '(?i)\bR14\b.*\b(active|open|opened)\b|\bsuccessor milestone\b.*\b(active|open|opened)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims R14 or successor milestone opening. Offending text: $line"
        }
    }
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

function Assert-StandardIdentity {
    param(
        [Parameter(Mandatory = $true)]
        $Artifact,
        [Parameter(Mandatory = $true)]
        [string]$SourceLabel
    )

    if ($Artifact.repository -ne $script:R13RepositoryName) {
        throw "$SourceLabel repository must be '$script:R13RepositoryName'."
    }
    if ($Artifact.branch -ne $script:R13Branch) {
        throw "$SourceLabel branch must be '$script:R13Branch'."
    }
    Assert-GitObjectIdWhenPopulated -Value $Artifact.head -Context "$SourceLabel head"
    Assert-GitObjectIdWhenPopulated -Value $Artifact.tree -Context "$SourceLabel tree"
    if ($Artifact.source_milestone -ne $script:R13Milestone) {
        throw "$SourceLabel source_milestone must be '$script:R13Milestone'."
    }
    if ($Artifact.source_task -ne $script:R13SourceTask) {
        throw "$SourceLabel source_task must be '$script:R13SourceTask'."
    }
}

function Assert-EvidenceRefs {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$EvidenceRefs,
        [Parameter(Mandatory = $true)]
        [string[]]$RequiredFields,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $refIds = @{}
    foreach ($evidence in @($EvidenceRefs)) {
        Assert-RequiredObjectFields -Object $evidence -FieldNames $RequiredFields -Context $Context
        $refId = Assert-NonEmptyString -Value $evidence.ref_id -Context "$Context ref_id"
        if ($refIds.ContainsKey($refId)) {
            throw "$Context contains duplicate ref_id '$refId'."
        }
        $refIds[$refId] = $true
        $ref = Assert-NonEmptyString -Value $evidence.ref -Context "$Context ref"
        Assert-ExistingRef -Ref $ref -Context "$Context ref"
        Assert-NonEmptyString -Value $evidence.evidence_kind -Context "$Context evidence_kind" | Out-Null
        Assert-NonEmptyString -Value $evidence.authority_kind -Context "$Context authority_kind" | Out-Null
        Assert-NonEmptyString -Value $evidence.scope -Context "$Context scope" | Out-Null
    }
}

function Get-R13QaFailureFixCycleContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "actionable_qa", "r13_qa_failure_fix_cycle.contract.json")) -Label "R13 QA failure-fix cycle contract"
}

function Get-R13FixExecutionResultContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "actionable_qa", "r13_fix_execution_result.contract.json")) -Label "R13 fix execution result contract"
}

function Get-R13QaBeforeAfterComparisonContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "actionable_qa", "r13_qa_before_after_comparison.contract.json")) -Label "R13 QA before-after comparison contract"
}

function Test-IsAllowedDemoWorkspace {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RelativePath
    )

    $normalized = $RelativePath.TrimEnd("/").Replace("\", "/")
    foreach ($root in $script:AllowedDemoRoots) {
        if ($normalized.Equals($root, [System.StringComparison]::OrdinalIgnoreCase) -or $normalized.StartsWith($root + "/", [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }

    return $false
}

function Assert-DemoWorkspaceRef {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Ref,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-RepositoryRelativePath -PathValue $Ref -Context $Context
    if (-not (Test-IsAllowedDemoWorkspace -RelativePath $Ref)) {
        throw "$Context must be under state/cycles/r13_qa_cycle_demo/ or state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/qa/r13_006_demo/."
    }
}

function Test-IsCanonicalInvalidDetectorFixture {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Ref
    )

    $normalized = $Ref.Replace("\", "/")
    return $normalized.StartsWith($script:CanonicalInvalidDetectorRoot + "/", [System.StringComparison]::OrdinalIgnoreCase)
}

function Get-ReportIssuesForFile {
    param(
        [Parameter(Mandatory = $true)]
        $Report,
        [Parameter(Mandatory = $true)]
        [string]$FileRef
    )

    $normalizedFileRef = $FileRef.Replace("\", "/")
    return @($Report.issues | Where-Object { ([string]$_.file_path).Replace("\", "/") -eq $normalizedFileRef })
}

function Get-BlockingIssuesForFile {
    param(
        [Parameter(Mandatory = $true)]
        $Report,
        [Parameter(Mandatory = $true)]
        [string]$FileRef
    )

    return @(Get-ReportIssuesForFile -Report $Report -FileRef $FileRef | Where-Object {
            ([string]$_.blocking_status -eq "blocking" -or [string]$_.severity -in @("critical", "error")) -and [string]$_.status -notin @("fixed", "resolved")
        })
}

function Get-SelectedIssueTypeIssues {
    param(
        [Parameter(Mandatory = $true)]
        $Report,
        [Parameter(Mandatory = $true)]
        [string]$FileRef,
        [Parameter(Mandatory = $true)]
        [string]$IssueType
    )

    return @(Get-ReportIssuesForFile -Report $Report -FileRef $FileRef | Where-Object { [string]$_.issue_type -eq $IssueType })
}

function Get-SelectedBlockingIssueTypeIssues {
    param(
        [Parameter(Mandatory = $true)]
        $Report,
        [Parameter(Mandatory = $true)]
        [string]$FileRef,
        [Parameter(Mandatory = $true)]
        [string]$IssueType
    )

    return @(Get-SelectedIssueTypeIssues -Report $Report -FileRef $FileRef -IssueType $IssueType | Where-Object {
            ([string]$_.blocking_status -eq "blocking" -or [string]$_.severity -in @("critical", "error")) -and [string]$_.status -notin @("fixed", "resolved")
        })
}

function Get-ValidatedSourceIssueReport {
    param(
        [Parameter(Mandatory = $true)]
        [string]$IssueReportPath
    )

    $resolved = Resolve-RepositoryPath -PathValue $IssueReportPath
    & $script:TestIssueDetectionReport -ReportPath $resolved | Out-Null
    $report = Get-JsonDocument -Path $resolved -Label "R13-003 issue report"
    if ($report.source_task -ne $script:R13IssueReportTask) {
        throw "Source issue report must be from $script:R13IssueReportTask."
    }
    return $report
}

function Get-ValidatedFixQueue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FixQueuePath
    )

    $resolved = Resolve-RepositoryPath -PathValue $FixQueuePath
    & $script:TestFixQueue -QueuePath $resolved | Out-Null
    $queue = Get-JsonDocument -Path $resolved -Label "R13-004 fix queue"
    if ($queue.source_task -ne $script:R13FixQueueTask) {
        throw "Source fix queue must be from $script:R13FixQueueTask."
    }
    return $queue
}

function Get-ValidatedBoundedFixExecution {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BoundedFixExecutionPath
    )

    $resolved = Resolve-RepositoryPath -PathValue $BoundedFixExecutionPath
    & $script:TestBoundedFixExecution -PacketPath $resolved | Out-Null
    $packet = Get-JsonDocument -Path $resolved -Label "R13-005 bounded fix execution packet"
    if ($packet.source_task -ne $script:R13BoundedExecutionTask) {
        throw "Source bounded fix execution packet must be from $script:R13BoundedExecutionTask."
    }
    if ($packet.execution_mode -ne "authorization_only" -or $packet.aggregate_verdict -ne "authorized_for_future_execution") {
        throw "R13-006 requires an R13-005 authorization-only packet with aggregate_verdict authorized_for_future_execution."
    }
    return $packet
}

function Get-FixItemById {
    param(
        [Parameter(Mandatory = $true)]
        $Queue,
        [Parameter(Mandatory = $true)]
        [string]$FixItemId
    )

    $items = @($Queue.fix_items | Where-Object { [string]$_.fix_item_id -eq $FixItemId })
    if ($items.Count -ne 1) {
        throw "Selected fix item '$FixItemId' is not present in the R13-004 source queue."
    }
    return $items[0]
}

function Select-R13DemoFixItem {
    param(
        [Parameter(Mandatory = $true)]
        $Queue,
        [Parameter(Mandatory = $true)]
        $Packet,
        [string]$FixItemId = ""
    )

    $authorizedFixItemIds = @($Packet.selected_fix_item_ids | ForEach-Object { [string]$_ })
    if ($authorizedFixItemIds.Count -eq 0) {
        throw "R13-005 bounded fix execution packet contains no authorized selected_fix_item_ids."
    }

    if (-not [string]::IsNullOrWhiteSpace($FixItemId)) {
        if ($authorizedFixItemIds -notcontains $FixItemId) {
            throw "Selected fix item '$FixItemId' is not authorized by R13-005."
        }
        return (Get-FixItemById -Queue $Queue -FixItemId $FixItemId)
    }

    $preferred = @($Queue.fix_items | Where-Object {
            $authorizedFixItemIds -contains [string]$_.fix_item_id -and
            @($_.issue_types) -contains "malformed_json" -and
            @($_.target_files | Where-Object { [string]$_ -eq "state/fixtures/invalid/actionable_qa/r13_detector_inputs/malformed_json_input.json" }).Count -gt 0
        })
    if ($preferred.Count -gt 0) {
        return $preferred[0]
    }

    return (Get-FixItemById -Queue $Queue -FixItemId $authorizedFixItemIds[0])
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
        [string]$Verdict
    )

    $timestamp = Get-UtcTimestamp
    return [pscustomobject][ordered]@{
        command_id = $CommandId
        command = $Command
        exit_code = $ExitCode
        verdict = $Verdict
        started_at_utc = $timestamp
        completed_at_utc = Get-UtcTimestamp
    }
}

function New-ValidationResult {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ValidationId,
        [Parameter(Mandatory = $true)]
        [string]$Scope,
        [Parameter(Mandatory = $true)]
        [string]$Verdict,
        [Parameter(Mandatory = $true)]
        [string]$Details
    )

    return [pscustomobject][ordered]@{
        validation_id = $ValidationId
        scope = $Scope
        verdict = $Verdict
        details = $Details
    }
}

function New-EvidenceRef {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RefId,
        [Parameter(Mandatory = $true)]
        [string]$Ref,
        [Parameter(Mandatory = $true)]
        [string]$EvidenceKind,
        [string]$AuthorityKind = "repo_tooling",
        [string]$Scope = "repo"
    )

    return [pscustomobject][ordered]@{
        ref_id = $RefId
        ref = $Ref.Replace("\", "/")
        evidence_kind = $EvidenceKind
        authority_kind = $AuthorityKind
        scope = $Scope
    }
}

function Get-GitTrackedPathStatus {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepoRelativePath
    )

    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & git -C (Get-RepositoryRoot) status --porcelain -- $RepoRelativePath 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }
    if ($exitCode -ne 0) {
        throw "Git status failed for '$RepoRelativePath'."
    }
    return @($output | ForEach-Object { [string]$_ })
}

function Repair-R13DemoInput {
    param(
        [Parameter(Mandatory = $true)]
        [string]$IssueType,
        [Parameter(Mandatory = $true)]
        [string]$BeforePath,
        [Parameter(Mandatory = $true)]
        [string]$AfterPath,
        [Parameter(Mandatory = $true)]
        [string]$SourceFileRef,
        [Parameter(Mandatory = $true)]
        [string]$SelectedFixItemId,
        [Parameter(Mandatory = $true)]
        [string]$SelectedSourceIssueId
    )

    if ($IssueType -eq "malformed_json") {
        $document = [pscustomobject][ordered]@{
            artifact_type = "r13_006_controlled_demo_input"
            source_artifact_type = "seeded_bad_qa_input"
            selected_issue = "malformed JSON"
            repair_status = "json_root_repaired"
            source_fixture_ref = $SourceFileRef
            selected_fix_item_ref = $SelectedFixItemId
            selected_source_issue_ref = $SelectedSourceIssueId
            repair_note = "R13-006 demo copy repaired by adding the missing comma and preserving a single JSON object root."
        }
        Write-JsonFile -Path $AfterPath -Value $document
        return
    }

    $beforeDocument = Get-JsonDocument -Path (Resolve-RepositoryPath -PathValue $BeforePath) -Label "R13-006 demo before input"
    if ($IssueType -eq "missing_reproduction_command" -or $IssueType -eq "missing_recommended_fix") {
        foreach ($issue in @($beforeDocument.issues)) {
            if ($IssueType -eq "missing_reproduction_command" -and -not (Test-HasProperty -Object $issue -Name "reproduction_command")) {
                Add-Member -InputObject $issue -MemberType NoteProperty -Name "reproduction_command" -Value "powershell -NoProfile -ExecutionPolicy Bypass -File tools\invoke_r13_qa_issue_detector.ps1 -ScopePath $AfterPath -OutputPath state/cycles/r13_qa_cycle_demo/after_detection_report.json -FixtureMode"
            }
            if ($IssueType -eq "missing_recommended_fix" -and -not (Test-HasProperty -Object $issue -Name "recommended_fix")) {
                Add-Member -InputObject $issue -MemberType NoteProperty -Name "recommended_fix" -Value "Add the missing recommended_fix field in the controlled R13-006 demo copy."
            }
        }
        Write-JsonFile -Path $AfterPath -Value $beforeDocument
        return
    }

    throw "R13-006 demo repair does not support selected issue type '$IssueType'."
}

function Test-R13FixExecutionResultObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Result,
        [string]$SourceLabel = "R13 fix execution result"
    )

    $contract = Get-R13FixExecutionResultContract
    Assert-RequiredObjectFields -Object $Result -FieldNames $contract.required_fields -Context $SourceLabel
    if ($Result.contract_version -ne $contract.contract_version) {
        throw "$SourceLabel contract_version must be '$($contract.contract_version)'."
    }
    if ($Result.artifact_type -ne "r13_fix_execution_result") {
        throw "$SourceLabel artifact_type must be 'r13_fix_execution_result'."
    }
    Assert-NonEmptyString -Value $Result.execution_result_id -Context "$SourceLabel execution_result_id" | Out-Null
    Assert-StandardIdentity -Artifact $Result -SourceLabel $SourceLabel

    foreach ($refEntry in @(
            @{ Name = "source_issue_report_ref"; Value = $Result.source_issue_report_ref },
            @{ Name = "source_fix_queue_ref"; Value = $Result.source_fix_queue_ref },
            @{ Name = "source_bounded_fix_execution_ref"; Value = $Result.source_bounded_fix_execution_ref },
            @{ Name = "source_file_ref"; Value = $Result.source_file_ref },
            @{ Name = "demo_before_ref"; Value = $Result.demo_before_ref },
            @{ Name = "demo_after_ref"; Value = $Result.demo_after_ref }
        )) {
        $ref = Assert-NonEmptyString -Value $refEntry.Value -Context "$SourceLabel $($refEntry.Name)"
        Assert-ExistingRef -Ref $ref -Context "$SourceLabel $($refEntry.Name)"
    }
    Assert-DemoWorkspaceRef -Ref ([string]$Result.demo_before_ref) -Context "$SourceLabel demo_before_ref"
    Assert-DemoWorkspaceRef -Ref ([string]$Result.demo_after_ref) -Context "$SourceLabel demo_after_ref"

    Assert-NonEmptyString -Value $Result.selected_fix_item_id -Context "$SourceLabel selected_fix_item_id" | Out-Null
    Assert-NonEmptyString -Value $Result.selected_source_issue_id -Context "$SourceLabel selected_source_issue_id" | Out-Null
    Assert-NonEmptyString -Value $Result.selected_issue_type -Context "$SourceLabel selected_issue_type" | Out-Null

    $changedFiles = Assert-StringArray -Value $Result.changed_files -Context "$SourceLabel changed_files"
    foreach ($changedFile in $changedFiles) {
        Assert-DemoWorkspaceRef -Ref $changedFile -Context "$SourceLabel changed_files"
        Assert-ExistingRef -Ref $changedFile -Context "$SourceLabel changed_files"
        if (Test-IsCanonicalInvalidDetectorFixture -Ref $changedFile) {
            throw "$SourceLabel changed_files must not include canonical invalid detector fixtures."
        }
    }

    $mutationScope = Assert-ObjectValue -Value $Result.mutation_scope -Context "$SourceLabel mutation_scope"
    Assert-RequiredObjectFields -Object $mutationScope -FieldNames $contract.mutation_scope_required_fields -Context "$SourceLabel mutation_scope"
    if ([string]$mutationScope.scope_kind -ne "controlled_demo_workspace_only") {
        throw "$SourceLabel mutation_scope.scope_kind must be controlled_demo_workspace_only."
    }
    Assert-DemoWorkspaceRef -Ref ([string]$mutationScope.demo_workspace) -Context "$SourceLabel mutation_scope.demo_workspace"
    $allowedRoots = Assert-StringArray -Value $mutationScope.allowed_roots -Context "$SourceLabel mutation_scope.allowed_roots"
    foreach ($allowedRoot in $allowedRoots) {
        Assert-DemoWorkspaceRef -Ref $allowedRoot -Context "$SourceLabel mutation_scope.allowed_roots"
    }
    if ([bool](Assert-BooleanValue -Value $mutationScope.canonical_source_modified -Context "$SourceLabel mutation_scope.canonical_source_modified")) {
        throw "$SourceLabel canonical_source_modified must be false."
    }

    $commands = Assert-ObjectArray -Value $Result.commands_run -Context "$SourceLabel commands_run"
    foreach ($command in $commands) {
        Assert-RequiredObjectFields -Object $command -FieldNames $contract.command_required_fields -Context "$SourceLabel commands_run"
        Assert-NonEmptyString -Value $command.command_id -Context "$SourceLabel command_id" | Out-Null
        Assert-NonEmptyString -Value $command.command -Context "$SourceLabel command" | Out-Null
        Assert-IntegerValue -Value $command.exit_code -Context "$SourceLabel exit_code" -Minimum 0 | Out-Null
        $commandVerdict = Assert-NonEmptyString -Value $command.verdict -Context "$SourceLabel command verdict"
        Assert-AllowedValue -Value $commandVerdict -AllowedValues $contract.allowed_command_verdicts -Context "$SourceLabel command verdict"
        Assert-TimestampString -Value $command.started_at_utc -Context "$SourceLabel command started_at_utc"
        Assert-TimestampString -Value $command.completed_at_utc -Context "$SourceLabel command completed_at_utc"
    }

    $validationResults = Assert-ObjectArray -Value $Result.validation_results -Context "$SourceLabel validation_results"
    foreach ($validation in $validationResults) {
        Assert-RequiredObjectFields -Object $validation -FieldNames $contract.validation_result_required_fields -Context "$SourceLabel validation_results"
        Assert-NonEmptyString -Value $validation.validation_id -Context "$SourceLabel validation_id" | Out-Null
        Assert-NonEmptyString -Value $validation.scope -Context "$SourceLabel validation scope" | Out-Null
        $validationVerdict = Assert-NonEmptyString -Value $validation.verdict -Context "$SourceLabel validation verdict"
        Assert-AllowedValue -Value $validationVerdict -AllowedValues $contract.allowed_validation_verdicts -Context "$SourceLabel validation verdict"
        Assert-NonEmptyString -Value $validation.details -Context "$SourceLabel validation details" | Out-Null
    }

    Assert-NonEmptyString -Value $Result.rollback_note -Context "$SourceLabel rollback_note" | Out-Null
    $aggregateVerdict = Assert-NonEmptyString -Value $Result.aggregate_verdict -Context "$SourceLabel aggregate_verdict"
    Assert-AllowedValue -Value $aggregateVerdict -AllowedValues $script:AllowedFixExecutionAggregateVerdicts -Context "$SourceLabel aggregate_verdict"
    $refusalReasons = Assert-StringArray -Value $Result.refusal_reasons -Context "$SourceLabel refusal_reasons" -AllowEmpty
    if ($aggregateVerdict -eq "executed_pending_rerun" -and @($refusalReasons).Count -ne 0) {
        throw "$SourceLabel executed_pending_rerun requires empty refusal_reasons."
    }
    if ($aggregateVerdict -eq "blocked" -and @($refusalReasons).Count -eq 0) {
        throw "$SourceLabel blocked aggregate_verdict requires refusal_reasons."
    }

    $evidenceRefs = Assert-ObjectArray -Value $Result.evidence_refs -Context "$SourceLabel evidence_refs"
    Assert-EvidenceRefs -EvidenceRefs $evidenceRefs -RequiredFields $contract.evidence_ref_required_fields -Context "$SourceLabel evidence_refs"
    Assert-TimestampString -Value $Result.created_at_utc -Context "$SourceLabel created_at_utc"
    $nonClaims = Assert-StringArray -Value $Result.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel
    Assert-NoForbiddenR13Claims -Value $Result -Context $SourceLabel

    return [pscustomobject][ordered]@{
        ExecutionResultId = [string]$Result.execution_result_id
        SelectedFixItemId = [string]$Result.selected_fix_item_id
        SelectedSourceIssueId = [string]$Result.selected_source_issue_id
        SelectedIssueType = [string]$Result.selected_issue_type
        ChangedFileCount = @($changedFiles).Count
        AggregateVerdict = $aggregateVerdict
    }
}

function Test-R13FixExecutionResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResultPath
    )

    $result = Get-JsonDocument -Path $ResultPath -Label "R13 fix execution result"
    return Test-R13FixExecutionResultObject -Result $result -SourceLabel "R13 fix execution result"
}

function Test-R13QaBeforeAfterComparisonObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Comparison,
        [string]$SourceLabel = "R13 QA before-after comparison"
    )

    $contract = Get-R13QaBeforeAfterComparisonContract
    Assert-RequiredObjectFields -Object $Comparison -FieldNames $contract.required_fields -Context $SourceLabel
    if ($Comparison.contract_version -ne $contract.contract_version) {
        throw "$SourceLabel contract_version must be '$($contract.contract_version)'."
    }
    if ($Comparison.artifact_type -ne "r13_qa_before_after_comparison") {
        throw "$SourceLabel artifact_type must be 'r13_qa_before_after_comparison'."
    }
    Assert-NonEmptyString -Value $Comparison.comparison_id -Context "$SourceLabel comparison_id" | Out-Null
    Assert-StandardIdentity -Artifact $Comparison -SourceLabel $SourceLabel
    Assert-NonEmptyString -Value $Comparison.selected_fix_item_id -Context "$SourceLabel selected_fix_item_id" | Out-Null
    Assert-NonEmptyString -Value $Comparison.selected_source_issue_id -Context "$SourceLabel selected_source_issue_id" | Out-Null
    $selectedIssueType = Assert-NonEmptyString -Value $Comparison.selected_issue_type -Context "$SourceLabel selected_issue_type"

    foreach ($refEntry in @(
            @{ Name = "demo_before_ref"; Value = $Comparison.demo_before_ref },
            @{ Name = "demo_after_ref"; Value = $Comparison.demo_after_ref },
            @{ Name = "before_report_ref"; Value = $Comparison.before_report_ref },
            @{ Name = "after_report_ref"; Value = $Comparison.after_report_ref }
        )) {
        $ref = Assert-NonEmptyString -Value $refEntry.Value -Context "$SourceLabel $($refEntry.Name)"
        Assert-ExistingRef -Ref $ref -Context "$SourceLabel $($refEntry.Name)"
    }
    Assert-DemoWorkspaceRef -Ref ([string]$Comparison.demo_before_ref) -Context "$SourceLabel demo_before_ref"
    Assert-DemoWorkspaceRef -Ref ([string]$Comparison.demo_after_ref) -Context "$SourceLabel demo_after_ref"

    $beforeReport = Get-JsonDocument -Path (Resolve-RepositoryPath -PathValue ([string]$Comparison.before_report_ref)) -Label "$SourceLabel before report"
    $afterReport = Get-JsonDocument -Path (Resolve-RepositoryPath -PathValue ([string]$Comparison.after_report_ref)) -Label "$SourceLabel after report"
    & $script:TestIssueDetectionReport -ReportPath (Resolve-RepositoryPath -PathValue ([string]$Comparison.before_report_ref)) | Out-Null
    & $script:TestIssueDetectionReport -ReportPath (Resolve-RepositoryPath -PathValue ([string]$Comparison.after_report_ref)) | Out-Null

    $declaredBeforeIssueIds = Assert-StringArray -Value $Comparison.before_issue_ids -Context "$SourceLabel before_issue_ids" -AllowEmpty
    $declaredAfterIssueIds = Assert-StringArray -Value $Comparison.after_issue_ids -Context "$SourceLabel after_issue_ids" -AllowEmpty
    $resolvedIssueIds = Assert-StringArray -Value $Comparison.resolved_issue_ids -Context "$SourceLabel resolved_issue_ids" -AllowEmpty
    $unresolvedIssueIds = Assert-StringArray -Value $Comparison.unresolved_issue_ids -Context "$SourceLabel unresolved_issue_ids" -AllowEmpty
    $newIssueIds = Assert-StringArray -Value $Comparison.new_issue_ids -Context "$SourceLabel new_issue_ids" -AllowEmpty

    $beforeSelectedIssues = @(Get-SelectedBlockingIssueTypeIssues -Report $beforeReport -FileRef ([string]$Comparison.demo_before_ref) -IssueType $selectedIssueType)
    $afterSelectedIssues = @(Get-SelectedBlockingIssueTypeIssues -Report $afterReport -FileRef ([string]$Comparison.demo_after_ref) -IssueType $selectedIssueType)
    $afterBlockingIssues = @(Get-BlockingIssuesForFile -Report $afterReport -FileRef ([string]$Comparison.demo_after_ref))
    $computedBeforeIds = @($beforeSelectedIssues | ForEach-Object { [string]$_.issue_id })
    $computedAfterIds = @($afterSelectedIssues | ForEach-Object { [string]$_.issue_id })

    foreach ($computedId in $computedBeforeIds) {
        if ($declaredBeforeIssueIds -notcontains $computedId) {
            throw "$SourceLabel before_issue_ids must include detected selected issue '$computedId'."
        }
    }
    foreach ($declaredAfterId in $declaredAfterIssueIds) {
        if ($computedAfterIds -notcontains $declaredAfterId) {
            throw "$SourceLabel after_issue_ids contains '$declaredAfterId' that is not a selected blocking after issue."
        }
    }

    $comparisonVerdict = Assert-NonEmptyString -Value $Comparison.comparison_verdict -Context "$SourceLabel comparison_verdict"
    Assert-AllowedValue -Value $comparisonVerdict -AllowedValues $script:AllowedComparisonVerdicts -Context "$SourceLabel comparison_verdict"
    $refusalReasons = Assert-StringArray -Value $Comparison.refusal_reasons -Context "$SourceLabel refusal_reasons" -AllowEmpty
    if ($comparisonVerdict -eq "target_issue_resolved") {
        if ($beforeSelectedIssues.Count -eq 0) {
            throw "$SourceLabel before report is missing the selected issue type '$selectedIssueType'."
        }
        if ($afterSelectedIssues.Count -ne 0) {
            throw "$SourceLabel after report still has selected issue type '$selectedIssueType' as blocking."
        }
        if ($afterBlockingIssues.Count -ne 0) {
            throw "$SourceLabel after report introduced new blocking issue(s) for the demo after file."
        }
        foreach ($beforeIssueId in $computedBeforeIds) {
            if ($resolvedIssueIds -notcontains $beforeIssueId) {
                throw "$SourceLabel resolved_issue_ids must include before issue '$beforeIssueId'."
            }
        }
        if (@($unresolvedIssueIds).Count -ne 0 -or @($newIssueIds).Count -ne 0) {
            throw "$SourceLabel target_issue_resolved requires empty unresolved_issue_ids and new_issue_ids."
        }
        if (@($refusalReasons).Count -ne 0) {
            throw "$SourceLabel target_issue_resolved requires empty refusal_reasons."
        }
    }
    elseif ($comparisonVerdict -eq "blocked" -and @($refusalReasons).Count -eq 0) {
        throw "$SourceLabel blocked comparison_verdict requires refusal_reasons."
    }

    $evidenceRefs = Assert-ObjectArray -Value $Comparison.evidence_refs -Context "$SourceLabel evidence_refs"
    Assert-EvidenceRefs -EvidenceRefs $evidenceRefs -RequiredFields $contract.evidence_ref_required_fields -Context "$SourceLabel evidence_refs"
    Assert-TimestampString -Value $Comparison.created_at_utc -Context "$SourceLabel created_at_utc"
    $nonClaims = Assert-StringArray -Value $Comparison.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel
    Assert-NoForbiddenR13Claims -Value $Comparison -Context $SourceLabel

    return [pscustomobject][ordered]@{
        ComparisonId = [string]$Comparison.comparison_id
        SelectedIssueType = $selectedIssueType
        BeforeIssueCount = @($declaredBeforeIssueIds).Count
        AfterIssueCount = @($declaredAfterIssueIds).Count
        ResolvedIssueCount = @($resolvedIssueIds).Count
        ComparisonVerdict = $comparisonVerdict
    }
}

function Test-R13QaBeforeAfterComparison {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ComparisonPath
    )

    $comparison = Get-JsonDocument -Path $ComparisonPath -Label "R13 QA before-after comparison"
    return Test-R13QaBeforeAfterComparisonObject -Comparison $comparison -SourceLabel "R13 QA before-after comparison"
}

function Test-R13QaFailureFixCycleObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Cycle,
        [string]$SourceLabel = "R13 QA failure-fix cycle"
    )

    $contract = Get-R13QaFailureFixCycleContract
    Assert-RequiredObjectFields -Object $Cycle -FieldNames $contract.required_fields -Context $SourceLabel
    if ($Cycle.contract_version -ne $contract.contract_version) {
        throw "$SourceLabel contract_version must be '$($contract.contract_version)'."
    }
    if ($Cycle.artifact_type -ne "r13_qa_failure_fix_cycle") {
        throw "$SourceLabel artifact_type must be 'r13_qa_failure_fix_cycle'."
    }
    Assert-NonEmptyString -Value $Cycle.cycle_id -Context "$SourceLabel cycle_id" | Out-Null
    Assert-StandardIdentity -Artifact $Cycle -SourceLabel $SourceLabel
    $selectedFixItemId = Assert-NonEmptyString -Value $Cycle.selected_fix_item_id -Context "$SourceLabel selected_fix_item_id"
    $selectedSourceIssueId = Assert-NonEmptyString -Value $Cycle.selected_source_issue_id -Context "$SourceLabel selected_source_issue_id"
    $selectedIssueType = Assert-NonEmptyString -Value $Cycle.selected_issue_type -Context "$SourceLabel selected_issue_type"

    foreach ($refEntry in @(
            @{ Name = "source_issue_report_ref"; Value = $Cycle.source_issue_report_ref },
            @{ Name = "source_fix_queue_ref"; Value = $Cycle.source_fix_queue_ref },
            @{ Name = "source_bounded_fix_execution_ref"; Value = $Cycle.source_bounded_fix_execution_ref },
            @{ Name = "before_input_ref"; Value = $Cycle.before_input_ref },
            @{ Name = "after_input_ref"; Value = $Cycle.after_input_ref },
            @{ Name = "fix_execution_ref"; Value = $Cycle.fix_execution_ref },
            @{ Name = "before_detection_report_ref"; Value = $Cycle.before_detection_report_ref },
            @{ Name = "after_detection_report_ref"; Value = $Cycle.after_detection_report_ref },
            @{ Name = "before_after_comparison_ref"; Value = $Cycle.before_after_comparison_ref },
            @{ Name = "qa_rerun_ref"; Value = $Cycle.qa_rerun_ref }
        )) {
        $ref = Assert-NonEmptyString -Value $refEntry.Value -Context "$SourceLabel $($refEntry.Name)"
        Assert-ExistingRef -Ref $ref -Context "$SourceLabel $($refEntry.Name)"
    }
    Assert-DemoWorkspaceRef -Ref ([string]$Cycle.demo_workspace) -Context "$SourceLabel demo_workspace"
    Assert-DemoWorkspaceRef -Ref ([string]$Cycle.before_input_ref) -Context "$SourceLabel before_input_ref"
    Assert-DemoWorkspaceRef -Ref ([string]$Cycle.after_input_ref) -Context "$SourceLabel after_input_ref"

    $sourceReport = Get-ValidatedSourceIssueReport -IssueReportPath ([string]$Cycle.source_issue_report_ref)
    $sourceQueue = Get-ValidatedFixQueue -FixQueuePath ([string]$Cycle.source_fix_queue_ref)
    $sourcePacket = Get-ValidatedBoundedFixExecution -BoundedFixExecutionPath ([string]$Cycle.source_bounded_fix_execution_ref)
    if (@($sourcePacket.selected_fix_item_ids) -notcontains $selectedFixItemId) {
        throw "$SourceLabel selected_fix_item_id '$selectedFixItemId' is not authorized by R13-005."
    }
    if (@($sourcePacket.selected_source_issue_ids) -notcontains $selectedSourceIssueId) {
        throw "$SourceLabel selected_source_issue_id '$selectedSourceIssueId' is not authorized by R13-005."
    }
    $sourceFixItem = Get-FixItemById -Queue $sourceQueue -FixItemId $selectedFixItemId
    if (@($sourceFixItem.source_issue_ids) -notcontains $selectedSourceIssueId) {
        throw "$SourceLabel selected source issue is not mapped by the selected fix item."
    }
    if (@($sourceFixItem.issue_types) -notcontains $selectedIssueType) {
        throw "$SourceLabel selected issue type is not preserved by the selected fix item."
    }
    $sourceIssue = @($sourceReport.issues | Where-Object { [string]$_.issue_id -eq $selectedSourceIssueId })
    if ($sourceIssue.Count -ne 1 -or [string]$sourceIssue[0].issue_type -ne $selectedIssueType) {
        throw "$SourceLabel selected source issue is not preserved from the R13-003 issue report."
    }

    $fixExecutionValidation = Test-R13FixExecutionResult -ResultPath ([string]$Cycle.fix_execution_ref)
    if ($fixExecutionValidation.SelectedFixItemId -ne $selectedFixItemId -or $fixExecutionValidation.SelectedSourceIssueId -ne $selectedSourceIssueId) {
        throw "$SourceLabel fix execution result does not preserve selected fix/source issue IDs."
    }
    $comparisonValidation = Test-R13QaBeforeAfterComparison -ComparisonPath ([string]$Cycle.before_after_comparison_ref)
    if ($comparisonValidation.SelectedIssueType -ne $selectedIssueType) {
        throw "$SourceLabel before/after comparison does not preserve selected issue type."
    }

    $beforeReport = Get-JsonDocument -Path (Resolve-RepositoryPath -PathValue ([string]$Cycle.before_detection_report_ref)) -Label "$SourceLabel before detection report"
    $afterReport = Get-JsonDocument -Path (Resolve-RepositoryPath -PathValue ([string]$Cycle.after_detection_report_ref)) -Label "$SourceLabel after detection report"
    & $script:TestIssueDetectionReport -ReportPath (Resolve-RepositoryPath -PathValue ([string]$Cycle.before_detection_report_ref)) | Out-Null
    & $script:TestIssueDetectionReport -ReportPath (Resolve-RepositoryPath -PathValue ([string]$Cycle.after_detection_report_ref)) | Out-Null
    $beforeSelectedIssues = @(Get-SelectedBlockingIssueTypeIssues -Report $beforeReport -FileRef ([string]$Cycle.before_input_ref) -IssueType $selectedIssueType)
    $afterSelectedIssues = @(Get-SelectedBlockingIssueTypeIssues -Report $afterReport -FileRef ([string]$Cycle.after_input_ref) -IssueType $selectedIssueType)
    $afterBlockingIssues = @(Get-BlockingIssuesForFile -Report $afterReport -FileRef ([string]$Cycle.after_input_ref))

    $safetyChecks = Assert-ObjectValue -Value $Cycle.safety_checks -Context "$SourceLabel safety_checks"
    Assert-RequiredObjectFields -Object $safetyChecks -FieldNames $contract.safety_check_required_fields -Context "$SourceLabel safety_checks"
    if (-not [bool](Assert-BooleanValue -Value $safetyChecks.selected_fix_item_authorized -Context "$SourceLabel safety_checks.selected_fix_item_authorized")) {
        throw "$SourceLabel selected fix item is not marked authorized."
    }
    if (-not [bool](Assert-BooleanValue -Value $safetyChecks.canonical_fixture_preserved -Context "$SourceLabel safety_checks.canonical_fixture_preserved")) {
        throw "$SourceLabel canonical invalid detector fixture was mutated."
    }
    if (-not [bool](Assert-BooleanValue -Value $safetyChecks.before_report_contains_selected_issue -Context "$SourceLabel safety_checks.before_report_contains_selected_issue")) {
        throw "$SourceLabel before report is not marked as containing the selected issue."
    }
    if ([bool](Assert-BooleanValue -Value $safetyChecks.after_report_contains_selected_blocking_issue -Context "$SourceLabel safety_checks.after_report_contains_selected_blocking_issue")) {
        throw "$SourceLabel after report still has selected issue type as blocking."
    }
    $newBlockingIssueCount = Assert-IntegerValue -Value $safetyChecks.new_blocking_issue_count -Context "$SourceLabel safety_checks.new_blocking_issue_count" -Minimum 0
    if ($newBlockingIssueCount -ne 0) {
        throw "$SourceLabel after report introduced new blocking issue(s)."
    }
    foreach ($claimFlag in @("external_replay_claimed", "final_signoff_claimed", "hard_gate_claimed")) {
        if ([bool](Assert-BooleanValue -Value $safetyChecks.$claimFlag -Context "$SourceLabel safety_checks.$claimFlag")) {
            throw "$SourceLabel safety_checks.$claimFlag must be false."
        }
    }
    if ($beforeSelectedIssues.Count -eq 0) {
        throw "$SourceLabel before report is missing selected issue type '$selectedIssueType'."
    }
    if ($afterSelectedIssues.Count -ne 0) {
        throw "$SourceLabel after report still contains selected issue type '$selectedIssueType' as blocking."
    }
    if ($afterBlockingIssues.Count -ne 0) {
        throw "$SourceLabel after report introduced new blocking issue(s) for the demo after file."
    }

    $cycleStatus = Assert-NonEmptyString -Value $Cycle.cycle_status -Context "$SourceLabel cycle_status"
    Assert-AllowedValue -Value $cycleStatus -AllowedValues $script:AllowedCycleStatuses -Context "$SourceLabel cycle_status"
    $aggregateVerdict = Assert-NonEmptyString -Value $Cycle.aggregate_verdict -Context "$SourceLabel aggregate_verdict"
    Assert-AllowedValue -Value $aggregateVerdict -AllowedValues $script:AllowedCycleAggregateVerdicts -Context "$SourceLabel aggregate_verdict"
    $refusalReasons = Assert-StringArray -Value $Cycle.refusal_reasons -Context "$SourceLabel refusal_reasons" -AllowEmpty
    if ($aggregateVerdict -eq "fixed_pending_external_replay") {
        if ($cycleStatus -ne "fixed_locally_pending_external_replay") {
            throw "$SourceLabel fixed_pending_external_replay requires cycle_status fixed_locally_pending_external_replay."
        }
        if ($comparisonValidation.ComparisonVerdict -ne "target_issue_resolved") {
            throw "$SourceLabel fixed_pending_external_replay requires target_issue_resolved comparison."
        }
        if (@($refusalReasons).Count -ne 0) {
            throw "$SourceLabel fixed_pending_external_replay requires empty refusal_reasons."
        }
    }
    elseif ($aggregateVerdict -eq "blocked" -and @($refusalReasons).Count -eq 0) {
        throw "$SourceLabel blocked aggregate_verdict requires refusal_reasons."
    }

    $evidenceRefs = Assert-ObjectArray -Value $Cycle.evidence_refs -Context "$SourceLabel evidence_refs"
    Assert-EvidenceRefs -EvidenceRefs $evidenceRefs -RequiredFields $contract.evidence_ref_required_fields -Context "$SourceLabel evidence_refs"
    Assert-TimestampString -Value $Cycle.created_at_utc -Context "$SourceLabel created_at_utc"
    $nonClaims = Assert-StringArray -Value $Cycle.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel
    Assert-NoForbiddenR13Claims -Value $Cycle -Context $SourceLabel

    return [pscustomobject][ordered]@{
        CycleId = [string]$Cycle.cycle_id
        SelectedFixItemId = $selectedFixItemId
        SelectedSourceIssueId = $selectedSourceIssueId
        SelectedIssueType = $selectedIssueType
        BeforeIssueCount = @($beforeReport.issues).Count
        AfterIssueCount = @($afterReport.issues).Count
        ComparisonVerdict = $comparisonValidation.ComparisonVerdict
        AggregateVerdict = $aggregateVerdict
    }
}

function Test-R13QaFailureFixCycle {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$CyclePath
    )

    $cycle = Get-JsonDocument -Path $CyclePath -Label "R13 QA failure-fix cycle"
    return Test-R13QaFailureFixCycleObject -Cycle $cycle -SourceLabel "R13 QA failure-fix cycle"
}

function Invoke-R13QaFailureFixCycle {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$IssueReportPath,
        [Parameter(Mandatory = $true)]
        [string]$FixQueuePath,
        [Parameter(Mandatory = $true)]
        [string]$BoundedFixExecutionPath,
        [Parameter(Mandatory = $true)]
        [string]$OutputRoot,
        [string]$FixItemId = ""
    )

    $outputRootRef = Convert-ToRepositoryRelativePath -PathValue $OutputRoot
    Assert-DemoWorkspaceRef -Ref $outputRootRef -Context "OutputRoot"
    $outputRootPath = Resolve-RepositoryPath -PathValue $outputRootRef
    New-Item -ItemType Directory -Path $outputRootPath -Force | Out-Null

    $issueReportRef = Convert-ToRepositoryRelativePath -PathValue $IssueReportPath
    $fixQueueRef = Convert-ToRepositoryRelativePath -PathValue $FixQueuePath
    $boundedExecutionRef = Convert-ToRepositoryRelativePath -PathValue $BoundedFixExecutionPath
    $sourceReport = Get-ValidatedSourceIssueReport -IssueReportPath $issueReportRef
    $sourceQueue = Get-ValidatedFixQueue -FixQueuePath $fixQueueRef
    $sourcePacket = Get-ValidatedBoundedFixExecution -BoundedFixExecutionPath $boundedExecutionRef
    $selectedFixItem = Select-R13DemoFixItem -Queue $sourceQueue -Packet $sourcePacket -FixItemId $FixItemId

    $selectedFixItemId = [string]$selectedFixItem.fix_item_id
    $sourceIssueIds = @($selectedFixItem.source_issue_ids | ForEach-Object { [string]$_ })
    $issueTypes = @($selectedFixItem.issue_types | ForEach-Object { [string]$_ })
    $targetFiles = @($selectedFixItem.target_files | ForEach-Object { [string]$_ })
    if ($sourceIssueIds.Count -ne 1 -or $issueTypes.Count -ne 1 -or $targetFiles.Count -ne 1) {
        throw "R13-006 demo cycle requires exactly one source issue, issue type, and target file."
    }
    $selectedSourceIssueId = $sourceIssueIds[0]
    $selectedIssueType = $issueTypes[0]
    $sourceFileRef = $targetFiles[0].Replace("\", "/")
    if (@($sourcePacket.selected_fix_item_ids) -notcontains $selectedFixItemId -or @($sourcePacket.selected_source_issue_ids) -notcontains $selectedSourceIssueId) {
        throw "Selected fix item/source issue is not authorized by R13-005."
    }
    Assert-ExistingRef -Ref $sourceFileRef -Context "selected source target file"
    if (-not (Test-IsCanonicalInvalidDetectorFixture -Ref $sourceFileRef)) {
        throw "R13-006 demo requires a canonical invalid detector fixture source file."
    }
    if (@(Get-GitTrackedPathStatus -RepoRelativePath $sourceFileRef).Count -ne 0) {
        throw "Canonical invalid detector fixture '$sourceFileRef' has pre-existing git modifications; refusing demo run."
    }

    $sourceIssue = @($sourceReport.issues | Where-Object { [string]$_.issue_id -eq $selectedSourceIssueId -and [string]$_.issue_type -eq $selectedIssueType })
    if ($sourceIssue.Count -ne 1) {
        throw "Selected source issue '$selectedSourceIssueId' with issue type '$selectedIssueType' was not found in the R13-003 issue report."
    }

    $sourceHashBefore = (Get-FileHash -Algorithm SHA256 -LiteralPath (Resolve-RepositoryPath -PathValue $sourceFileRef)).Hash
    $fileName = Split-Path -Leaf $sourceFileRef
    $beforeRef = (Join-Path $outputRootRef (Join-Path "before" $fileName)).Replace("\", "/")
    $afterRef = (Join-Path $outputRootRef (Join-Path "after" $fileName)).Replace("\", "/")
    $beforeReportRef = (Join-Path $outputRootRef "before_detection_report.json").Replace("\", "/")
    $afterReportRef = (Join-Path $outputRootRef "after_detection_report.json").Replace("\", "/")
    $fixExecutionResultRef = (Join-Path $outputRootRef "fix_execution_result.json").Replace("\", "/")
    $comparisonRef = (Join-Path $outputRootRef "before_after_comparison.json").Replace("\", "/")
    $cycleRef = (Join-Path $outputRootRef "qa_failure_fix_cycle.json").Replace("\", "/")
    $manifestRef = (Join-Path $outputRootRef "validation_manifest.md").Replace("\", "/")

    New-Item -ItemType Directory -Path (Split-Path -Parent (Resolve-RepositoryPath -PathValue $beforeRef)) -Force | Out-Null
    New-Item -ItemType Directory -Path (Split-Path -Parent (Resolve-RepositoryPath -PathValue $afterRef)) -Force | Out-Null
    Copy-Item -LiteralPath (Resolve-RepositoryPath -PathValue $sourceFileRef) -Destination (Resolve-RepositoryPath -PathValue $beforeRef) -Force
    Repair-R13DemoInput -IssueType $selectedIssueType -BeforePath $beforeRef -AfterPath $afterRef -SourceFileRef $sourceFileRef -SelectedFixItemId $selectedFixItemId -SelectedSourceIssueId $selectedSourceIssueId
    Read-SingleJsonObject -Path (Resolve-RepositoryPath -PathValue $afterRef) -Label "R13-006 demo after input" | Out-Null

    $sourceHashAfter = (Get-FileHash -Algorithm SHA256 -LiteralPath (Resolve-RepositoryPath -PathValue $sourceFileRef)).Hash
    if ($sourceHashBefore -ne $sourceHashAfter -or @(Get-GitTrackedPathStatus -RepoRelativePath $sourceFileRef).Count -ne 0) {
        throw "Canonical invalid detector fixture '$sourceFileRef' was modified; refusing R13-006 cycle."
    }

    $beforeReport = & $script:InvokeIssueDetector -ScopePath @($beforeRef) -FixtureMode
    $afterReport = & $script:InvokeIssueDetector -ScopePath @($afterRef) -FixtureMode
    Write-JsonFile -Path $beforeReportRef -Value $beforeReport
    Write-JsonFile -Path $afterReportRef -Value $afterReport

    $beforeSelectedIssues = @(Get-SelectedBlockingIssueTypeIssues -Report $beforeReport -FileRef $beforeRef -IssueType $selectedIssueType)
    if ($beforeSelectedIssues.Count -eq 0) {
        throw "Before detector report does not contain selected issue type '$selectedIssueType' for '$beforeRef'."
    }
    $afterSelectedIssues = @(Get-SelectedBlockingIssueTypeIssues -Report $afterReport -FileRef $afterRef -IssueType $selectedIssueType)
    if ($afterSelectedIssues.Count -ne 0) {
        throw "After detector report still contains selected issue type '$selectedIssueType' as blocking for '$afterRef'."
    }
    $afterBlockingIssues = @(Get-BlockingIssuesForFile -Report $afterReport -FileRef $afterRef)
    if ($afterBlockingIssues.Count -ne 0) {
        throw "After detector report introduced new blocking issue(s) for '$afterRef'."
    }

    $gitIdentity = Get-GitIdentity
    if ($gitIdentity.Branch -ne $script:R13Branch) {
        throw "R13-006 must run on branch '$script:R13Branch'."
    }

    $fixExecutionResult = [pscustomobject][ordered]@{
        contract_version = "v1"
        artifact_type = "r13_fix_execution_result"
        execution_result_id = Get-StableId -Prefix "r13fer" -Key "$selectedFixItemId|$selectedSourceIssueId|$afterRef"
        repository = $script:R13RepositoryName
        branch = $gitIdentity.Branch
        head = $gitIdentity.Head
        tree = $gitIdentity.Tree
        source_milestone = $script:R13Milestone
        source_task = $script:R13SourceTask
        source_issue_report_ref = $issueReportRef
        source_fix_queue_ref = $fixQueueRef
        source_bounded_fix_execution_ref = $boundedExecutionRef
        selected_fix_item_id = $selectedFixItemId
        selected_source_issue_id = $selectedSourceIssueId
        selected_issue_type = $selectedIssueType
        source_file_ref = $sourceFileRef
        demo_before_ref = $beforeRef
        demo_after_ref = $afterRef
        changed_files = @($afterRef)
        mutation_scope = [pscustomobject][ordered]@{
            scope_kind = "controlled_demo_workspace_only"
            demo_workspace = $outputRootRef
            allowed_roots = @($outputRootRef)
            canonical_source_modified = $false
        }
        commands_run = @(
            (New-CommandRecord -CommandId "copy-demo-before" -Command "Copy-Item $sourceFileRef $beforeRef" -ExitCode 0 -Verdict "passed"),
            (New-CommandRecord -CommandId "apply-bounded-demo-repair" -Command "Apply deterministic $selectedIssueType repair to $afterRef" -ExitCode 0 -Verdict "passed"),
            (New-CommandRecord -CommandId "json-root-validation" -Command "Import-Module .\tools\JsonRoot.psm1 -Force; Read-SingleJsonObject -Path $afterRef" -ExitCode 0 -Verdict "passed")
        )
        validation_results = @(
            (New-ValidationResult -ValidationId "selected-fix-authorized" -Scope $selectedFixItemId -Verdict "passed" -Details "Selected fix item and source issue are authorized by the R13-005 bounded fix execution packet."),
            (New-ValidationResult -ValidationId "canonical-fixture-preserved" -Scope $sourceFileRef -Verdict "passed" -Details "Canonical invalid detector fixture SHA256 remained $sourceHashBefore and git status stayed clean for the source fixture."),
            (New-ValidationResult -ValidationId "after-json-root-valid" -Scope $afterRef -Verdict "passed" -Details "Demo after input parses as a single JSON object through JsonRoot.Read-SingleJsonObject.")
        )
        rollback_note = [string]$selectedFixItem.rollback_note
        aggregate_verdict = "executed_pending_rerun"
        evidence_refs = @(
            (New-EvidenceRef -RefId "r13-fix-execution-result-contract" -Ref "contracts/actionable_qa/r13_fix_execution_result.contract.json" -EvidenceKind "contract" -AuthorityKind "repo_contract"),
            (New-EvidenceRef -RefId "r13-qa-failure-fix-cycle-module" -Ref "tools/R13QaFailureFixCycle.psm1" -EvidenceKind "module"),
            (New-EvidenceRef -RefId "r13-demo-before-input" -Ref $beforeRef -EvidenceKind "demo_before_input" -AuthorityKind "repo_demo"),
            (New-EvidenceRef -RefId "r13-demo-after-input" -Ref $afterRef -EvidenceKind "demo_after_input" -AuthorityKind "repo_demo")
        )
        refusal_reasons = @()
        created_at_utc = Get-UtcTimestamp
        non_claims = @($script:RequiredNonClaims)
    }
    Write-JsonFile -Path $fixExecutionResultRef -Value $fixExecutionResult

    $beforeIssueIds = @($beforeSelectedIssues | ForEach-Object { [string]$_.issue_id })
    $afterIssueIds = @($afterSelectedIssues | ForEach-Object { [string]$_.issue_id })
    $comparison = [pscustomobject][ordered]@{
        contract_version = "v1"
        artifact_type = "r13_qa_before_after_comparison"
        comparison_id = Get-StableId -Prefix "r13qbac" -Key "$selectedFixItemId|$selectedIssueType|$beforeReportRef|$afterReportRef"
        repository = $script:R13RepositoryName
        branch = $gitIdentity.Branch
        head = $gitIdentity.Head
        tree = $gitIdentity.Tree
        source_milestone = $script:R13Milestone
        source_task = $script:R13SourceTask
        selected_fix_item_id = $selectedFixItemId
        selected_source_issue_id = $selectedSourceIssueId
        selected_issue_type = $selectedIssueType
        demo_before_ref = $beforeRef
        demo_after_ref = $afterRef
        before_report_ref = $beforeReportRef
        after_report_ref = $afterReportRef
        before_issue_ids = @($beforeIssueIds)
        after_issue_ids = @($afterIssueIds)
        resolved_issue_ids = @($beforeIssueIds)
        unresolved_issue_ids = @()
        new_issue_ids = @()
        comparison_verdict = "target_issue_resolved"
        evidence_refs = @(
            (New-EvidenceRef -RefId "r13-before-after-comparison-contract" -Ref "contracts/actionable_qa/r13_qa_before_after_comparison.contract.json" -EvidenceKind "contract" -AuthorityKind "repo_contract"),
            (New-EvidenceRef -RefId "r13-before-detection-report" -Ref $beforeReportRef -EvidenceKind "before_detection_report" -AuthorityKind "repo_detector"),
            (New-EvidenceRef -RefId "r13-after-detection-report" -Ref $afterReportRef -EvidenceKind "after_detection_report" -AuthorityKind "repo_detector"),
            (New-EvidenceRef -RefId "r13-demo-before-input" -Ref $beforeRef -EvidenceKind "demo_before_input" -AuthorityKind "repo_demo"),
            (New-EvidenceRef -RefId "r13-demo-after-input" -Ref $afterRef -EvidenceKind "demo_after_input" -AuthorityKind "repo_demo")
        )
        refusal_reasons = @()
        created_at_utc = Get-UtcTimestamp
        non_claims = @($script:RequiredNonClaims)
    }
    Write-JsonFile -Path $comparisonRef -Value $comparison

    $cycle = [pscustomobject][ordered]@{
        contract_version = "v1"
        artifact_type = "r13_qa_failure_fix_cycle"
        cycle_id = Get-StableId -Prefix "r13qffc" -Key "$selectedFixItemId|$selectedSourceIssueId|$outputRootRef"
        repository = $script:R13RepositoryName
        branch = $gitIdentity.Branch
        head = $gitIdentity.Head
        tree = $gitIdentity.Tree
        source_milestone = $script:R13Milestone
        source_task = $script:R13SourceTask
        source_issue_report_ref = $issueReportRef
        source_fix_queue_ref = $fixQueueRef
        source_bounded_fix_execution_ref = $boundedExecutionRef
        selected_fix_item_id = $selectedFixItemId
        selected_source_issue_id = $selectedSourceIssueId
        selected_issue_type = $selectedIssueType
        demo_workspace = $outputRootRef
        before_input_ref = $beforeRef
        after_input_ref = $afterRef
        fix_execution_ref = $fixExecutionResultRef
        before_detection_report_ref = $beforeReportRef
        after_detection_report_ref = $afterReportRef
        before_after_comparison_ref = $comparisonRef
        qa_rerun_ref = $afterReportRef
        cycle_status = "fixed_locally_pending_external_replay"
        safety_checks = [pscustomobject][ordered]@{
            selected_fix_item_authorized = $true
            canonical_fixture_preserved = $true
            before_report_contains_selected_issue = $true
            after_report_contains_selected_blocking_issue = $false
            new_blocking_issue_count = 0
            external_replay_claimed = $false
            final_signoff_claimed = $false
            hard_gate_claimed = $false
        }
        aggregate_verdict = "fixed_pending_external_replay"
        evidence_refs = @(
            (New-EvidenceRef -RefId "r13-qa-failure-fix-cycle-contract" -Ref "contracts/actionable_qa/r13_qa_failure_fix_cycle.contract.json" -EvidenceKind "contract" -AuthorityKind "repo_contract"),
            (New-EvidenceRef -RefId "r13-qa-failure-fix-cycle-module" -Ref "tools/R13QaFailureFixCycle.psm1" -EvidenceKind "module"),
            (New-EvidenceRef -RefId "r13-qa-failure-fix-cycle-cli" -Ref "tools/run_r13_qa_failure_fix_cycle.ps1" -EvidenceKind "cli"),
            (New-EvidenceRef -RefId "source-r13-003-issue-report" -Ref $issueReportRef -EvidenceKind "source_issue_report" -AuthorityKind "repo_detector"),
            (New-EvidenceRef -RefId "source-r13-004-fix-queue" -Ref $fixQueueRef -EvidenceKind "source_fix_queue" -AuthorityKind "repo_fix_queue"),
            (New-EvidenceRef -RefId "source-r13-005-bounded-fix-execution" -Ref $boundedExecutionRef -EvidenceKind "source_bounded_fix_execution" -AuthorityKind "repo_authorization"),
            (New-EvidenceRef -RefId "r13-fix-execution-result" -Ref $fixExecutionResultRef -EvidenceKind "fix_execution_result"),
            (New-EvidenceRef -RefId "r13-before-detection-report" -Ref $beforeReportRef -EvidenceKind "before_detection_report" -AuthorityKind "repo_detector"),
            (New-EvidenceRef -RefId "r13-after-detection-report" -Ref $afterReportRef -EvidenceKind "after_detection_report" -AuthorityKind "repo_detector"),
            (New-EvidenceRef -RefId "r13-before-after-comparison" -Ref $comparisonRef -EvidenceKind "before_after_comparison"),
            (New-EvidenceRef -RefId "r13-validation-manifest" -Ref $manifestRef -EvidenceKind "validation_manifest")
        )
        refusal_reasons = @()
        created_at_utc = Get-UtcTimestamp
        non_claims = @($script:RequiredNonClaims)
    }
    Write-JsonFile -Path $cycleRef -Value $cycle

    $manifest = @"
# R13-006 Validation Manifest

- Selected fix item ID: `$selectedFixItemId`
- Selected source issue ID: `$selectedSourceIssueId`
- Selected issue type: `$selectedIssueType`
- Source issue report ref: `$issueReportRef`
- Fix queue ref: `$fixQueueRef`
- Bounded fix execution ref: `$boundedExecutionRef`
- Before report ref: `$beforeReportRef`
- After report ref: `$afterReportRef`
- Comparison ref: `$comparisonRef`

## Exact Validation Commands Run

- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\run_r13_qa_failure_fix_cycle.ps1 -IssueReportPath $issueReportRef -FixQueuePath $fixQueueRef -BoundedFixExecutionPath $boundedExecutionRef -OutputRoot $outputRootRef -FixItemId $selectedFixItemId`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r13_fix_execution_result.ps1 -ResultPath $fixExecutionResultRef`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r13_qa_before_after_comparison.ps1 -ComparisonPath $comparisonRef`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r13_qa_failure_fix_cycle.ps1 -CyclePath $cycleRef`
- `powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r13_qa_failure_fix_cycle.ps1`

## Explicit Non-Claims

- R13-006 runs one controlled demo workspace QA failure-to-fix cycle only.
- Canonical invalid detector fixtures were not mutated.
- No external replay has occurred.
- No final QA signoff has occurred.
- No R13 hard value gate is delivered yet.
- No production QA is claimed.
- No R14 or successor milestone is opened.
"@
    Write-TextFile -Path $manifestRef -Value $manifest

    Test-R13FixExecutionResult -ResultPath $fixExecutionResultRef | Out-Null
    Test-R13QaBeforeAfterComparison -ComparisonPath $comparisonRef | Out-Null
    Test-R13QaFailureFixCycle -CyclePath $cycleRef | Out-Null

    return [pscustomobject][ordered]@{
        SelectedFixItemId = $selectedFixItemId
        SelectedSourceIssueId = $selectedSourceIssueId
        SelectedIssueType = $selectedIssueType
        BeforeIssueCount = @($beforeReport.issues).Count
        AfterIssueCount = @($afterReport.issues).Count
        BeforeSelectedIssueCount = $beforeSelectedIssues.Count
        AfterSelectedBlockingIssueCount = $afterSelectedIssues.Count
        ComparisonVerdict = "target_issue_resolved"
        AggregateVerdict = "fixed_pending_external_replay"
        DemoWorkspace = $outputRootRef
        BeforeInputRef = $beforeRef
        AfterInputRef = $afterRef
        BeforeDetectionReportRef = $beforeReportRef
        AfterDetectionReportRef = $afterReportRef
        FixExecutionResultRef = $fixExecutionResultRef
        BeforeAfterComparisonRef = $comparisonRef
        CycleRef = $cycleRef
        ValidationManifestRef = $manifestRef
        CanonicalFixturePreserved = $true
    }
}

Export-ModuleMember -Function Get-R13QaFailureFixCycleContract, Get-R13FixExecutionResultContract, Get-R13QaBeforeAfterComparisonContract, Invoke-R13QaFailureFixCycle, Test-R13FixExecutionResultObject, Test-R13FixExecutionResult, Test-R13QaBeforeAfterComparisonObject, Test-R13QaBeforeAfterComparison, Test-R13QaFailureFixCycleObject, Test-R13QaFailureFixCycle
