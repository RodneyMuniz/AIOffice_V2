Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force
$issueDetectorModule = Import-Module (Join-Path $PSScriptRoot "R13QaIssueDetector.psm1") -Force -PassThru
$script:TestIssueDetectionReport = $issueDetectorModule.ExportedCommands["Test-R13QaIssueDetectionReport"]

$script:R13RepositoryName = "AIOffice_V2"
$script:R13Branch = "release/r13-api-first-qa-pipeline-and-operator-control-room-product-slice"
$script:R13Milestone = "R13 API-First QA Pipeline and Operator Control-Room Product Slice"
$script:R13SourceTask = "R13-004"
$script:R13IssueReportTask = "R13-003"
$script:GitObjectPattern = "^[a-f0-9]{40}$"
$script:TimestampPattern = "^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$"
$script:AllowedIssueSeverities = @("critical", "error", "warning", "info")
$script:AllowedBlockingStatuses = @("blocking", "non_blocking", "advisory")
$script:AllowedAggregateVerdicts = @("ready_for_fix_execution", "blocked")
$script:AllowedQueueStatuses = @("ready_for_fix_execution", "blocked")
$script:AllowedFixStatuses = @("queued", "blocked", "no_fix")
$script:AllowedRiskLevels = @("low", "medium", "high")
$script:CycleQaRoot = "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/qa"
$script:RequiredNonClaims = @(
    "R13-004 is a fix queue and fix-plan generator only",
    "no R13 hard value gate delivered by R13-004",
    "no meaningful QA loop delivered yet",
    "no fix execution delivered by R13-004",
    "no rerun delivered by R13-004",
    "no before/after comparison delivered by R13-004",
    "no external replay proof delivered by R13-004",
    "no current operator control-room delivered by R13-004",
    "no final QA signoff delivered by R13-004",
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

function Test-RepositoryRelativePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue
    )

    if ([string]::IsNullOrWhiteSpace($PathValue)) {
        return $false
    }
    if ($PathValue -eq "not_applicable") {
        return $true
    }
    if ($PathValue -match '^https?://') {
        return $true
    }
    if ([System.IO.Path]::IsPathRooted($PathValue) -or $PathValue -match '(^|[\\/])\.\.([\\/]|$)') {
        return $false
    }

    $resolved = [System.IO.Path]::GetFullPath((Join-Path (Get-RepositoryRoot) $PathValue))
    $root = [System.IO.Path]::GetFullPath((Get-RepositoryRoot)).TrimEnd([char[]]@([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar))
    return $resolved.Equals($root, [System.StringComparison]::OrdinalIgnoreCase) -or $resolved.StartsWith($root + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)
}

function Assert-BoundedPathOrUrl {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if (-not (Test-RepositoryRelativePath -PathValue $Value)) {
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

function Get-R13QaFixQueueContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "actionable_qa", "r13_qa_fix_queue.contract.json")) -Label "R13 QA fix queue contract"
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

    return ($Line -match '(?i)\b(no|not|without|cannot|must not|does not|do not|is not|are not|did not|non-claim|non_claim|refuse|refuses|blocked|planned only|not yet delivered|expected future|rejects|rejected)\b')
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

function Assert-NoForbiddenAuthority {
    param(
        [Parameter(Mandatory = $true)]
        [string]$AuthorityKind,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($AuthorityKind -match '(?i)executor_self_certification|self_certification') {
        throw "executor self-certification as fix authority is rejected."
    }
}

function Assert-NoExternalProofClaim {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$EvidenceRefs,
        [Parameter(Mandatory = $true)]
        [object[]]$ExpectedEvidenceRefs,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($evidence in @($EvidenceRefs + $ExpectedEvidenceRefs)) {
        $kind = [string](Get-PropertyValue -Object $evidence -Name "evidence_kind" -Default "")
        $authority = [string](Get-PropertyValue -Object $evidence -Name "authority_kind" -Default "")
        $scope = [string](Get-PropertyValue -Object $evidence -Name "scope" -Default "")
        if ($authority -match '(?i)external_runner' -or $scope -match '(?i)^external$') {
            throw "$Context cannot claim external proof or external replay in R13-004."
        }
        if ($kind -match '(?i)external[_ -]?proof|external[_ -]?replay' -and $scope -notmatch '(?i)^external$') {
            throw "local-only evidence cannot be treated as external proof."
        }
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

function Get-SeveritySortRank {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Severity
    )

    switch ($Severity) {
        "critical" { return 0 }
        "error" { return 1 }
        "warning" { return 2 }
        default { return 3 }
    }
}

function Get-HighestSeverity {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Issues
    )

    return [string](@($Issues | Sort-Object @{ Expression = { Get-SeveritySortRank -Severity ([string]$_.severity) } } | Select-Object -First 1).severity)
}

function Convert-HashtableToObject {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Table
    )

    $object = [pscustomobject]@{}
    foreach ($key in @($Table.Keys | Sort-Object)) {
        Add-Member -InputObject $object -MemberType NoteProperty -Name ([string]$key) -Value $Table[$key]
    }
    return $object
}

function Get-DefaultValidationCommands {
    return @(
        "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r13_qa_fix_queue.ps1 -QueuePath <queue>",
        "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r13_qa_fix_queue.ps1"
    )
}

function New-ExpectedEvidenceRefs {
    return @(
        [pscustomobject][ordered]@{
            ref_id = "r13-005-fix-execution-packet"
            ref = "$script:CycleQaRoot/r13_005_fix_execution_packet.json"
            evidence_kind = "fix_execution"
            authority_kind = "future_repo_evidence"
            scope = "repo"
            status = "expected_future_evidence"
        },
        [pscustomobject][ordered]@{
            ref_id = "r13-006-rerun-issue-detection-report"
            ref = "$script:CycleQaRoot/r13_006_rerun_issue_detection_report.json"
            evidence_kind = "rerun_issue_detection"
            authority_kind = "future_repo_evidence"
            scope = "repo"
            status = "expected_future_evidence"
        },
        [pscustomobject][ordered]@{
            ref_id = "r13-006-before-after-comparison"
            ref = "$script:CycleQaRoot/r13_006_before_after_comparison.json"
            evidence_kind = "before_after_comparison"
            authority_kind = "future_repo_evidence"
            scope = "repo"
            status = "expected_future_evidence"
        }
    )
}

function Get-ExpectedEvidenceRefIds {
    return @("r13-005-fix-execution-packet", "r13-006-rerun-issue-detection-report", "r13-006-before-after-comparison")
}

function Test-BroadTargetPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue
    )

    return $PathValue -in @(".", "./", "*", "**", "*/", "**/*")
}

function Get-SourceIssueReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$IssueReportPath
    )

    $resolvedIssueReportPath = Resolve-RepositoryPath -PathValue $IssueReportPath
    & $script:TestIssueDetectionReport -ReportPath $resolvedIssueReportPath | Out-Null
    $report = Get-JsonDocument -Path $resolvedIssueReportPath -Label "R13 QA issue detection report"
    if ($report.branch -ne $script:R13Branch) {
        throw "R13 QA issue detection report branch must be '$script:R13Branch'."
    }
    if ($report.source_milestone -ne $script:R13Milestone) {
        throw "R13 QA issue detection report source_milestone must be '$script:R13Milestone'."
    }
    if ($report.source_task -ne $script:R13IssueReportTask) {
        throw "R13 QA issue detection report source_task must be '$script:R13IssueReportTask'."
    }

    return $report
}

function New-FixItemFromIssue {
    param(
        [Parameter(Mandatory = $true)]
        $Issue,
        [Parameter(Mandatory = $true)]
        [string[]]$ValidationCommands,
        [switch]$AllowBroadScope
    )

    $targetFile = [string]$Issue.file_path
    $isBroad = Test-BroadTargetPath -PathValue $targetFile
    $scopeAllowsBroad = [bool]($AllowBroadScope -and $isBroad)
    $scopeKind = if ($scopeAllowsBroad) { "explicitly_authorized_broad_scope" } else { "single_source_file" }
    $broadJustification = if ($scopeAllowsBroad) { "Broad scope was explicitly allowed by the R13-004 generator switch; no fixes are executed by this queue." } else { "" }
    $riskLevel = if ([string]$Issue.severity -eq "critical") { "medium" } else { "low" }

    return [pscustomobject][ordered]@{
        fix_item_id = Get-StableId -Prefix "r13qf" -Key ([string]$Issue.issue_id)
        source_issue_ids = @([string]$Issue.issue_id)
        issue_types = @([string]$Issue.issue_type)
        severity = [string]$Issue.severity
        blocking_status = [string]$Issue.blocking_status
        component = [string]$Issue.component
        target_files = @($targetFile)
        bounded_scope = [pscustomobject][ordered]@{
            scope_kind = $scopeKind
            allow_broad_scope = $scopeAllowsBroad
            description = "Modify only the listed target file(s) and directly related evidence refs for the preserved source issue."
            explicitly_related_paths = @()
            broad_scope_justification = $broadJustification
        }
        proposed_change_summary = "Apply the source recommended fix for $($Issue.issue_type) in $targetFile."
        reproduction_commands = @([string]$Issue.reproduction_command)
        recommended_fix = [string]$Issue.recommended_fix
        allowed_commands = @(@([string]$Issue.reproduction_command) + @($ValidationCommands) | Sort-Object -Unique)
        validation_commands = @($ValidationCommands)
        risk_level = $riskLevel
        rollback_note = "Restore the listed target file(s) from git and rerun the validation commands before accepting any later fix execution evidence."
        expected_evidence_refs = @(Get-ExpectedEvidenceRefIds)
        status = "queued"
        owner_role = "repository_maintainer"
        authority_kind = "repo_fix_plan_generator"
        non_claims = @($script:RequiredNonClaims)
    }
}

function New-NoFixItemFromIssue {
    param(
        [Parameter(Mandatory = $true)]
        $Issue,
        [Parameter(Mandatory = $true)]
        [string]$Reason
    )

    return [pscustomobject][ordered]@{
        no_fix_item_id = Get-StableId -Prefix "r13qnf" -Key ([string]$Issue.issue_id)
        source_issue_ids = @([string]$Issue.issue_id)
        issue_types = @([string]$Issue.issue_type)
        severity = [string]$Issue.severity
        blocking_status = [string]$Issue.blocking_status
        component = [string]$Issue.component
        reason = $Reason
        reproduction_commands = @([string]$Issue.reproduction_command)
        recommended_fix = [string]$Issue.recommended_fix
        expected_evidence_refs = @(Get-ExpectedEvidenceRefIds)
        status = "no_fix"
        owner_role = "repository_maintainer"
        authority_kind = "repo_fix_plan_generator"
        non_claims = @($script:RequiredNonClaims)
    }
}

function New-R13QaFixQueue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$IssueReportPath,
        [string]$QueueRef = "$script:CycleQaRoot/r13_004_fix_queue.json",
        [switch]$AllowBroadScope
    )

    $sourceReport = Get-SourceIssueReport -IssueReportPath $IssueReportPath
    $sourceIssueReportRef = Convert-ToRepositoryRelativePath -PathValue $IssueReportPath
    $branch = Invoke-GitLine -Arguments @("branch", "--show-current")
    $head = Invoke-GitLine -Arguments @("rev-parse", "HEAD")
    $tree = Invoke-GitLine -Arguments @("rev-parse", "HEAD^{tree}")

    if ($branch -ne $script:R13Branch) {
        throw "Current branch must be '$script:R13Branch' to generate an R13 QA fix queue."
    }

    $sourceIssues = @($sourceReport.issues)
    $blockingIssues = @($sourceIssues | Where-Object { [string]$_.blocking_status -eq "blocking" })
    $validationCommands = @(Get-DefaultValidationCommands)
    if (-not [string]::IsNullOrWhiteSpace($QueueRef)) {
        $validationCommands = @(
            "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r13_qa_fix_queue.ps1 -QueuePath $QueueRef",
            "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r13_qa_fix_queue.ps1"
        )
    }

    $fixItems = New-Object System.Collections.Generic.List[object]
    $noFixItems = New-Object System.Collections.Generic.List[object]
    $refusalReasons = New-Object System.Collections.Generic.List[string]
    foreach ($issue in @($blockingIssues | Sort-Object @{ Expression = { Get-SeveritySortRank -Severity ([string]$_.severity) } }, issue_id)) {
        $targetFile = [string]$issue.file_path
        if ((Test-BroadTargetPath -PathValue $targetFile) -and -not $AllowBroadScope) {
            $noFixItems.Add((New-NoFixItemFromIssue -Issue $issue -Reason "Source issue target '$targetFile' is broad repo scope and R13-004 generation was not run with AllowBroadScope.")) | Out-Null
            $refusalReasons.Add("Broad target '$targetFile' for source issue '$($issue.issue_id)' was mapped to no-fix because AllowBroadScope was not set.") | Out-Null
            continue
        }
        $fixItems.Add((New-FixItemFromIssue -Issue $issue -ValidationCommands $validationCommands -AllowBroadScope:$AllowBroadScope)) | Out-Null
    }

    $issueTypes = @($sourceIssues | ForEach-Object { [string]$_.issue_type } | Sort-Object -Unique)
    $commandsRequired = @(
        @($sourceReport.reproduction_commands) +
        @($blockingIssues | ForEach-Object { [string]$_.reproduction_command }) +
        $validationCommands
    ) | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) } | Sort-Object -Unique

    $mappedBlockingIds = @{}
    foreach ($item in @($fixItems.ToArray() + $noFixItems.ToArray())) {
        foreach ($sourceIssueId in @($item.source_issue_ids)) {
            $mappedBlockingIds[[string]$sourceIssueId] = $true
        }
    }

    $unmappedBlockingIssues = @($blockingIssues | Where-Object { -not $mappedBlockingIds.ContainsKey([string]$_.issue_id) } | ForEach-Object { [string]$_.issue_id })
    foreach ($unmappedId in $unmappedBlockingIssues) {
        $refusalReasons.Add("Blocking source issue '$unmappedId' was not mapped to a fix or no-fix item.") | Out-Null
    }

    $aggregateVerdict = if ($refusalReasons.Count -gt 0 -or $noFixItems.Count -gt 0 -or $unmappedBlockingIssues.Count -gt 0) { "blocked" } else { "ready_for_fix_execution" }

    $evidenceRefs = @(
        [pscustomobject][ordered]@{
            ref_id = "source-r13-003-issue-report"
            ref = $sourceIssueReportRef
            evidence_kind = "source_issue_report"
            authority_kind = "repo_detector"
            scope = "repo"
        },
        [pscustomobject][ordered]@{
            ref_id = "r13-qa-fix-queue-contract"
            ref = "contracts/actionable_qa/r13_qa_fix_queue.contract.json"
            evidence_kind = "contract"
            authority_kind = "repo_contract"
            scope = "repo"
        },
        [pscustomobject][ordered]@{
            ref_id = "r13-qa-fix-queue-module"
            ref = "tools/R13QaFixQueue.psm1"
            evidence_kind = "fix_queue_module"
            authority_kind = "repo_tooling"
            scope = "repo"
        },
        [pscustomobject][ordered]@{
            ref_id = "r13-qa-fix-queue-tests"
            ref = "tests/test_r13_qa_fix_queue.ps1"
            evidence_kind = "test_harness"
            authority_kind = "repo_tests"
            scope = "repo"
        }
    )

    $queue = [pscustomobject][ordered]@{
        contract_version = "v1"
        artifact_type = "r13_qa_fix_queue"
        queue_id = "r13-004-qa-fix-queue-" + [guid]::NewGuid().ToString("N")
        repository = $script:R13RepositoryName
        branch = $branch
        head = $head
        tree = $tree
        source_milestone = $script:R13Milestone
        source_task = $script:R13SourceTask
        source_issue_report_ref = $sourceIssueReportRef
        queue_status = $aggregateVerdict
        issue_summary = [pscustomobject][ordered]@{
            source_issue_count = $sourceIssues.Count
            blocking_issue_count = $blockingIssues.Count
            mapped_blocking_issue_count = $mappedBlockingIds.Count
            fix_item_count = $fixItems.Count
            no_fix_item_count = $noFixItems.Count
            unmapped_blocking_issue_count = $unmappedBlockingIssues.Count
            issue_types = @($issueTypes)
        }
        fix_items = @($fixItems.ToArray())
        unmapped_blocking_issues = @($unmappedBlockingIssues)
        no_fix_items = @($noFixItems.ToArray())
        allowed_scope = [pscustomobject][ordered]@{
            scope_kind = "bounded_source_issue_targets"
            allow_broad_scope = [bool]$AllowBroadScope
            allowed_roots = @("contracts", "tools", "tests", "state", "governance", "execution")
            disallowed_patterns = @("..", "absolute_paths", "external_proof_claims", "executor_self_certification")
            broad_scope_justification = if ($AllowBroadScope) { "AllowBroadScope was explicitly supplied; the queue still does not execute fixes." } else { "" }
        }
        commands_required = @($commandsRequired)
        validation_commands = @($validationCommands)
        expected_evidence_refs = @(New-ExpectedEvidenceRefs)
        aggregate_verdict = $aggregateVerdict
        evidence_refs = @($evidenceRefs)
        refusal_reasons = @($refusalReasons.ToArray())
        generated_at_utc = Get-UtcTimestamp
        non_claims = @($script:RequiredNonClaims)
    }

    Test-R13QaFixQueueObject -Queue $queue -SourceLabel "R13 QA fix queue draft" | Out-Null
    $PSCmdlet.WriteObject($queue, $false)
}

function Assert-ExpectedEvidenceRefs {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$ExpectedEvidenceRefs,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [Parameter(Mandatory = $true)]
        $Contract
    )

    $ids = @{}
    foreach ($expectedRef in $ExpectedEvidenceRefs) {
        Assert-RequiredObjectFields -Object $expectedRef -FieldNames $Contract.expected_evidence_ref_required_fields -Context "$Context expected_evidence_refs"
        $refId = Assert-NonEmptyString -Value $expectedRef.ref_id -Context "$Context expected_evidence_refs.ref_id"
        $ref = Assert-NonEmptyString -Value $expectedRef.ref -Context "$Context expected_evidence_refs.ref"
        Assert-BoundedPathOrUrl -Value $ref -Context "$Context expected_evidence_refs.ref"
        Assert-NonEmptyString -Value $expectedRef.evidence_kind -Context "$Context expected_evidence_refs.evidence_kind" | Out-Null
        Assert-NoForbiddenAuthority -AuthorityKind ([string]$expectedRef.authority_kind) -Context "$Context expected_evidence_refs.authority_kind"
        Assert-NonEmptyString -Value $expectedRef.scope -Context "$Context expected_evidence_refs.scope" | Out-Null
        $status = Assert-NonEmptyString -Value $expectedRef.status -Context "$Context expected_evidence_refs.status"
        if ($status -ne "expected_future_evidence") {
            Assert-ExistingRef -Ref $ref -Context "$Context expected_evidence_refs"
        }
        $ids[$refId] = $expectedRef
    }

    return $ids
}

function Assert-ItemExpectedRefs {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$ItemRefs,
        [Parameter(Mandatory = $true)]
        [hashtable]$ExpectedRefIds,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($itemRef in $ItemRefs) {
        if (-not $ExpectedRefIds.ContainsKey($itemRef)) {
            throw "$Context expected_evidence_refs item '$itemRef' must reference queue expected_evidence_refs."
        }
    }
}

function Assert-TargetFiles {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$TargetFiles,
        [Parameter(Mandatory = $true)]
        $BoundedScope,
        [Parameter(Mandatory = $true)]
        $AllowedScope,
        [Parameter(Mandatory = $true)]
        [string[]]$QueueNonClaims,
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [string[]]$RefusalReasons,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $boundedAllowsBroad = Assert-BooleanValue -Value $BoundedScope.allow_broad_scope -Context "$Context bounded_scope.allow_broad_scope"
    $queueAllowsBroad = Assert-BooleanValue -Value $AllowedScope.allow_broad_scope -Context "$Context allowed_scope.allow_broad_scope"

    foreach ($targetFile in $TargetFiles) {
        Assert-BoundedPathOrUrl -Value $targetFile -Context "$Context target_files"
        if ($targetFile -eq "not_applicable") {
            throw "$Context target_files must identify bounded repository targets, not not_applicable."
        }
        if (Test-BroadTargetPath -PathValue $targetFile) {
            if (-not ($boundedAllowsBroad -and $queueAllowsBroad)) {
                throw "$Context broad repo-wide fix scope requires explicit AllowBroadScope authorization."
            }
            $justification = Assert-NonEmptyString -Value $BoundedScope.broad_scope_justification -Context "$Context bounded_scope.broad_scope_justification"
            if ($justification -notmatch '(?i)broad|AllowBroadScope') {
                throw "$Context broad scope justification must record explicit broad-scope authorization."
            }
            if ($RefusalReasons.Count -eq 0 -and @($QueueNonClaims | Where-Object { $_ -match '(?i)broad scope.*no fixes executed|no fix execution' }).Count -eq 0) {
                throw "$Context broad scope authorization must be recorded in non_claims or refusal_reasons."
            }
        }
    }
}

function Assert-SourceIssuePreservation {
    param(
        [Parameter(Mandatory = $true)]
        $Item,
        [Parameter(Mandatory = $true)]
        [object[]]$SourceIssues,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $issueTypes = Assert-StringArray -Value $Item.issue_types -Context "$Context issue_types"
    $reproductionCommands = Assert-StringArray -Value $Item.reproduction_commands -Context "$Context reproduction_commands"
    $recommendedFix = Assert-NonEmptyString -Value $Item.recommended_fix -Context "$Context recommended_fix"
    foreach ($sourceIssue in $SourceIssues) {
        if ($issueTypes -notcontains [string]$sourceIssue.issue_type) {
            throw "$Context issue_types must preserve issue type '$($sourceIssue.issue_type)'."
        }
        if ($reproductionCommands -notcontains [string]$sourceIssue.reproduction_command) {
            throw "$Context reproduction_commands must preserve source issue '$($sourceIssue.issue_id)' reproduction command."
        }
        if ($recommendedFix -notlike ("*{0}*" -f [string]$sourceIssue.recommended_fix)) {
            throw "$Context recommended_fix must preserve source issue '$($sourceIssue.issue_id)' recommended fix."
        }
    }
}

function Test-R13QaFixQueueObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Queue,
        [string]$SourceLabel = "R13 QA fix queue"
    )

    $contract = Get-R13QaFixQueueContract
    Assert-RequiredObjectFields -Object $Queue -FieldNames $contract.required_fields -Context $SourceLabel

    if ($Queue.contract_version -ne $contract.contract_version) {
        throw "$SourceLabel contract_version must be '$($contract.contract_version)'."
    }
    if ($Queue.artifact_type -ne "r13_qa_fix_queue") {
        throw "$SourceLabel artifact_type must be 'r13_qa_fix_queue'."
    }
    Assert-NonEmptyString -Value $Queue.queue_id -Context "$SourceLabel queue_id" | Out-Null
    if ($Queue.repository -ne $script:R13RepositoryName) {
        throw "$SourceLabel repository must be '$script:R13RepositoryName'."
    }
    if ($Queue.branch -ne $script:R13Branch) {
        throw "$SourceLabel branch must be '$script:R13Branch'."
    }
    Assert-GitObjectIdWhenPopulated -Value $Queue.head -Context "$SourceLabel head"
    Assert-GitObjectIdWhenPopulated -Value $Queue.tree -Context "$SourceLabel tree"
    if ($Queue.source_milestone -ne $script:R13Milestone) {
        throw "$SourceLabel source_milestone must be '$script:R13Milestone'."
    }
    if ($Queue.source_task -ne $script:R13SourceTask) {
        throw "$SourceLabel source_task must be '$script:R13SourceTask'."
    }

    $sourceIssueReportRef = Assert-NonEmptyString -Value $Queue.source_issue_report_ref -Context "$SourceLabel source_issue_report_ref"
    Assert-ExistingRef -Ref $sourceIssueReportRef -Context "$SourceLabel source_issue_report_ref"
    $sourceReport = Get-SourceIssueReport -IssueReportPath $sourceIssueReportRef

    $queueStatus = Assert-NonEmptyString -Value $Queue.queue_status -Context "$SourceLabel queue_status"
    Assert-AllowedValue -Value $queueStatus -AllowedValues $script:AllowedQueueStatuses -Context "$SourceLabel queue_status"

    $issueSummary = Assert-ObjectValue -Value $Queue.issue_summary -Context "$SourceLabel issue_summary"
    Assert-RequiredObjectFields -Object $issueSummary -FieldNames $contract.issue_summary_required_fields -Context "$SourceLabel issue_summary"
    $sourceIssueCount = Assert-IntegerValue -Value $issueSummary.source_issue_count -Context "$SourceLabel issue_summary.source_issue_count" -Minimum 0
    $blockingIssueCount = Assert-IntegerValue -Value $issueSummary.blocking_issue_count -Context "$SourceLabel issue_summary.blocking_issue_count" -Minimum 0
    $mappedBlockingIssueCount = Assert-IntegerValue -Value $issueSummary.mapped_blocking_issue_count -Context "$SourceLabel issue_summary.mapped_blocking_issue_count" -Minimum 0
    $declaredFixItemCount = Assert-IntegerValue -Value $issueSummary.fix_item_count -Context "$SourceLabel issue_summary.fix_item_count" -Minimum 0
    $declaredNoFixItemCount = Assert-IntegerValue -Value $issueSummary.no_fix_item_count -Context "$SourceLabel issue_summary.no_fix_item_count" -Minimum 0
    $unmappedBlockingIssueCount = Assert-IntegerValue -Value $issueSummary.unmapped_blocking_issue_count -Context "$SourceLabel issue_summary.unmapped_blocking_issue_count" -Minimum 0
    Assert-StringArray -Value $issueSummary.issue_types -Context "$SourceLabel issue_summary.issue_types" -AllowEmpty | Out-Null

    $sourceIssues = @($sourceReport.issues)
    $blockingIssues = @($sourceIssues | Where-Object { [string]$_.blocking_status -eq "blocking" })
    if ($sourceIssueCount -ne $sourceIssues.Count) {
        throw "$SourceLabel issue_summary.source_issue_count must match source issue report."
    }
    if ($blockingIssueCount -ne $blockingIssues.Count) {
        throw "$SourceLabel issue_summary.blocking_issue_count must match source issue report."
    }

    $sourceIssuesById = @{}
    foreach ($sourceIssue in $sourceIssues) {
        $sourceIssuesById[[string]$sourceIssue.issue_id] = $sourceIssue
    }

    $allowedScope = Assert-ObjectValue -Value $Queue.allowed_scope -Context "$SourceLabel allowed_scope"
    Assert-RequiredObjectFields -Object $allowedScope -FieldNames $contract.allowed_scope_required_fields -Context "$SourceLabel allowed_scope"
    Assert-NonEmptyString -Value $allowedScope.scope_kind -Context "$SourceLabel allowed_scope.scope_kind" | Out-Null
    Assert-BooleanValue -Value $allowedScope.allow_broad_scope -Context "$SourceLabel allowed_scope.allow_broad_scope" | Out-Null
    Assert-StringArray -Value $allowedScope.allowed_roots -Context "$SourceLabel allowed_scope.allowed_roots" | Out-Null
    Assert-StringArray -Value $allowedScope.disallowed_patterns -Context "$SourceLabel allowed_scope.disallowed_patterns" -AllowEmpty | Out-Null
    Assert-StringValue -Value $allowedScope.broad_scope_justification -Context "$SourceLabel allowed_scope.broad_scope_justification" | Out-Null

    $commandsRequired = Assert-StringArray -Value $Queue.commands_required -Context "$SourceLabel commands_required"
    $queueValidationCommands = Assert-StringArray -Value $Queue.validation_commands -Context "$SourceLabel validation_commands"
    if ($commandsRequired.Count -eq 0 -or $queueValidationCommands.Count -eq 0) {
        throw "$SourceLabel commands_required and validation_commands must not be empty."
    }

    $expectedEvidenceRefs = Assert-ObjectArray -Value $Queue.expected_evidence_refs -Context "$SourceLabel expected_evidence_refs"
    $expectedEvidenceRefIds = Assert-ExpectedEvidenceRefs -ExpectedEvidenceRefs $expectedEvidenceRefs -Context $SourceLabel -Contract $contract

    $evidenceRefs = Assert-ObjectArray -Value $Queue.evidence_refs -Context "$SourceLabel evidence_refs"
    foreach ($evidence in $evidenceRefs) {
        Assert-RequiredObjectFields -Object $evidence -FieldNames $contract.evidence_ref_required_fields -Context "$SourceLabel evidence_refs"
        Assert-NonEmptyString -Value $evidence.ref_id -Context "$SourceLabel evidence_refs.ref_id" | Out-Null
        $ref = Assert-NonEmptyString -Value $evidence.ref -Context "$SourceLabel evidence_refs.ref"
        Assert-ExistingRef -Ref $ref -Context "$SourceLabel evidence_refs"
        Assert-NonEmptyString -Value $evidence.evidence_kind -Context "$SourceLabel evidence_refs.evidence_kind" | Out-Null
        Assert-NoForbiddenAuthority -AuthorityKind ([string]$evidence.authority_kind) -Context "$SourceLabel evidence_refs.authority_kind"
        Assert-NonEmptyString -Value $evidence.scope -Context "$SourceLabel evidence_refs.scope" | Out-Null
    }
    Assert-NoExternalProofClaim -EvidenceRefs $evidenceRefs -ExpectedEvidenceRefs $expectedEvidenceRefs -Context $SourceLabel

    $refusalReasons = Assert-StringArray -Value $Queue.refusal_reasons -Context "$SourceLabel refusal_reasons" -AllowEmpty
    Assert-TimestampString -Value $Queue.generated_at_utc -Context "$SourceLabel generated_at_utc" | Out-Null
    $nonClaims = Assert-StringArray -Value $Queue.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel
    Assert-NoSuccessorOpeningClaim -Value $Queue -Context $SourceLabel

    $fixItems = Assert-ObjectArray -Value $Queue.fix_items -Context "$SourceLabel fix_items" -AllowEmpty
    $noFixItems = Assert-ObjectArray -Value $Queue.no_fix_items -Context "$SourceLabel no_fix_items" -AllowEmpty
    $unmappedBlockingIssues = Assert-StringArray -Value $Queue.unmapped_blocking_issues -Context "$SourceLabel unmapped_blocking_issues" -AllowEmpty

    if ($declaredFixItemCount -ne $fixItems.Count) {
        throw "$SourceLabel issue_summary.fix_item_count must match fix_items."
    }
    if ($declaredNoFixItemCount -ne $noFixItems.Count) {
        throw "$SourceLabel issue_summary.no_fix_item_count must match no_fix_items."
    }
    if ($unmappedBlockingIssueCount -ne $unmappedBlockingIssues.Count) {
        throw "$SourceLabel issue_summary.unmapped_blocking_issue_count must match unmapped_blocking_issues."
    }
    if ($unmappedBlockingIssues.Count -gt 0) {
        throw "$SourceLabel contains unmapped blocking issues; blocking issues must be mapped to fix or no-fix items."
    }

    $mappedBlocking = @{}
    foreach ($fixItem in $fixItems) {
        Assert-RequiredObjectFields -Object $fixItem -FieldNames $contract.fix_item_required_fields -Context "$SourceLabel fix_item"
        Assert-NonEmptyString -Value $fixItem.fix_item_id -Context "$SourceLabel fix_item.fix_item_id" | Out-Null
        $sourceIssueIds = Assert-StringArray -Value $fixItem.source_issue_ids -Context "$SourceLabel fix_item.source_issue_ids"
        $sourceItemIssues = @()
        foreach ($sourceIssueId in $sourceIssueIds) {
            if (-not $sourceIssuesById.ContainsKey($sourceIssueId)) {
                throw "$SourceLabel fix_item source_issue_id '$sourceIssueId' does not map to a source issue."
            }
            $sourceIssue = $sourceIssuesById[$sourceIssueId]
            $sourceItemIssues += $sourceIssue
            if ([string]$sourceIssue.blocking_status -eq "blocking") {
                $mappedBlocking[$sourceIssueId] = $true
            }
        }
        $severity = Assert-NonEmptyString -Value $fixItem.severity -Context "$SourceLabel fix_item.severity"
        Assert-AllowedValue -Value $severity -AllowedValues $script:AllowedIssueSeverities -Context "$SourceLabel fix_item.severity"
        $blockingStatus = Assert-NonEmptyString -Value $fixItem.blocking_status -Context "$SourceLabel fix_item.blocking_status"
        Assert-AllowedValue -Value $blockingStatus -AllowedValues $script:AllowedBlockingStatuses -Context "$SourceLabel fix_item.blocking_status"
        Assert-NonEmptyString -Value $fixItem.component -Context "$SourceLabel fix_item.component" | Out-Null
        $targetFiles = Assert-StringArray -Value $fixItem.target_files -Context "$SourceLabel fix_item.target_files"
        $boundedScope = Assert-ObjectValue -Value $fixItem.bounded_scope -Context "$SourceLabel fix_item.bounded_scope"
        Assert-RequiredObjectFields -Object $boundedScope -FieldNames $contract.bounded_scope_required_fields -Context "$SourceLabel fix_item.bounded_scope"
        Assert-NonEmptyString -Value $boundedScope.scope_kind -Context "$SourceLabel fix_item.bounded_scope.scope_kind" | Out-Null
        Assert-NonEmptyString -Value $boundedScope.description -Context "$SourceLabel fix_item.bounded_scope.description" | Out-Null
        Assert-StringArray -Value $boundedScope.explicitly_related_paths -Context "$SourceLabel fix_item.bounded_scope.explicitly_related_paths" -AllowEmpty | Out-Null
        Assert-StringValue -Value $boundedScope.broad_scope_justification -Context "$SourceLabel fix_item.bounded_scope.broad_scope_justification" | Out-Null
        Assert-TargetFiles -TargetFiles $targetFiles -BoundedScope $boundedScope -AllowedScope $allowedScope -QueueNonClaims $nonClaims -RefusalReasons $refusalReasons -Context "$SourceLabel fix_item"
        Assert-NonEmptyString -Value $fixItem.proposed_change_summary -Context "$SourceLabel fix_item.proposed_change_summary" | Out-Null
        Assert-SourceIssuePreservation -Item $fixItem -SourceIssues $sourceItemIssues -Context "$SourceLabel fix_item"
        Assert-StringArray -Value $fixItem.allowed_commands -Context "$SourceLabel fix_item.allowed_commands" | Out-Null
        Assert-StringArray -Value $fixItem.validation_commands -Context "$SourceLabel fix_item.validation_commands" | Out-Null
        $riskLevel = Assert-NonEmptyString -Value $fixItem.risk_level -Context "$SourceLabel fix_item.risk_level"
        Assert-AllowedValue -Value $riskLevel -AllowedValues $script:AllowedRiskLevels -Context "$SourceLabel fix_item.risk_level"
        Assert-NonEmptyString -Value $fixItem.rollback_note -Context "$SourceLabel fix_item.rollback_note" | Out-Null
        $itemExpectedRefs = Assert-StringArray -Value $fixItem.expected_evidence_refs -Context "$SourceLabel fix_item.expected_evidence_refs"
        Assert-ItemExpectedRefs -ItemRefs $itemExpectedRefs -ExpectedRefIds $expectedEvidenceRefIds -Context "$SourceLabel fix_item"
        $status = Assert-NonEmptyString -Value $fixItem.status -Context "$SourceLabel fix_item.status"
        Assert-AllowedValue -Value $status -AllowedValues $script:AllowedFixStatuses -Context "$SourceLabel fix_item.status"
        Assert-NonEmptyString -Value $fixItem.owner_role -Context "$SourceLabel fix_item.owner_role" | Out-Null
        Assert-NoForbiddenAuthority -AuthorityKind ([string]$fixItem.authority_kind) -Context "$SourceLabel fix_item.authority_kind"
        $itemNonClaims = Assert-StringArray -Value $fixItem.non_claims -Context "$SourceLabel fix_item.non_claims"
        Assert-RequiredNonClaims -NonClaims $itemNonClaims -Context "$SourceLabel fix_item"
    }

    foreach ($noFixItem in $noFixItems) {
        Assert-RequiredObjectFields -Object $noFixItem -FieldNames $contract.no_fix_item_required_fields -Context "$SourceLabel no_fix_item"
        Assert-NonEmptyString -Value $noFixItem.no_fix_item_id -Context "$SourceLabel no_fix_item.no_fix_item_id" | Out-Null
        $sourceIssueIds = Assert-StringArray -Value $noFixItem.source_issue_ids -Context "$SourceLabel no_fix_item.source_issue_ids"
        $sourceItemIssues = @()
        foreach ($sourceIssueId in $sourceIssueIds) {
            if (-not $sourceIssuesById.ContainsKey($sourceIssueId)) {
                throw "$SourceLabel no_fix_item source_issue_id '$sourceIssueId' does not map to a source issue."
            }
            $sourceIssue = $sourceIssuesById[$sourceIssueId]
            $sourceItemIssues += $sourceIssue
            if ([string]$sourceIssue.blocking_status -eq "blocking") {
                $mappedBlocking[$sourceIssueId] = $true
            }
        }
        $severity = Assert-NonEmptyString -Value $noFixItem.severity -Context "$SourceLabel no_fix_item.severity"
        Assert-AllowedValue -Value $severity -AllowedValues $script:AllowedIssueSeverities -Context "$SourceLabel no_fix_item.severity"
        $blockingStatus = Assert-NonEmptyString -Value $noFixItem.blocking_status -Context "$SourceLabel no_fix_item.blocking_status"
        Assert-AllowedValue -Value $blockingStatus -AllowedValues $script:AllowedBlockingStatuses -Context "$SourceLabel no_fix_item.blocking_status"
        Assert-NonEmptyString -Value $noFixItem.component -Context "$SourceLabel no_fix_item.component" | Out-Null
        Assert-NonEmptyString -Value $noFixItem.reason -Context "$SourceLabel no_fix_item.reason" | Out-Null
        Assert-SourceIssuePreservation -Item $noFixItem -SourceIssues $sourceItemIssues -Context "$SourceLabel no_fix_item"
        $itemExpectedRefs = Assert-StringArray -Value $noFixItem.expected_evidence_refs -Context "$SourceLabel no_fix_item.expected_evidence_refs"
        Assert-ItemExpectedRefs -ItemRefs $itemExpectedRefs -ExpectedRefIds $expectedEvidenceRefIds -Context "$SourceLabel no_fix_item"
        $status = Assert-NonEmptyString -Value $noFixItem.status -Context "$SourceLabel no_fix_item.status"
        Assert-AllowedValue -Value $status -AllowedValues $script:AllowedFixStatuses -Context "$SourceLabel no_fix_item.status"
        Assert-NonEmptyString -Value $noFixItem.owner_role -Context "$SourceLabel no_fix_item.owner_role" | Out-Null
        Assert-NoForbiddenAuthority -AuthorityKind ([string]$noFixItem.authority_kind) -Context "$SourceLabel no_fix_item.authority_kind"
        $itemNonClaims = Assert-StringArray -Value $noFixItem.non_claims -Context "$SourceLabel no_fix_item.non_claims"
        Assert-RequiredNonClaims -NonClaims $itemNonClaims -Context "$SourceLabel no_fix_item"
    }

    foreach ($blockingIssue in $blockingIssues) {
        if (-not $mappedBlocking.ContainsKey([string]$blockingIssue.issue_id)) {
            throw "$SourceLabel every blocking issue must be mapped to a fix item or no-fix item; missing '$($blockingIssue.issue_id)'."
        }
    }
    if ($mappedBlockingIssueCount -ne $mappedBlocking.Count) {
        throw "$SourceLabel issue_summary.mapped_blocking_issue_count must match mapped blocking issue count."
    }

    $aggregateVerdict = Assert-NonEmptyString -Value $Queue.aggregate_verdict -Context "$SourceLabel aggregate_verdict"
    if ($aggregateVerdict -eq "passed") {
        throw "$SourceLabel aggregate_verdict 'passed' is not allowed before fix execution."
    }
    Assert-AllowedValue -Value $aggregateVerdict -AllowedValues $script:AllowedAggregateVerdicts -Context "$SourceLabel aggregate_verdict"
    if ($aggregateVerdict -ne $queueStatus) {
        throw "$SourceLabel queue_status must match aggregate_verdict."
    }
    if ($aggregateVerdict -eq "ready_for_fix_execution" -and ($refusalReasons.Count -gt 0 -or $noFixItems.Count -gt 0 -or $unmappedBlockingIssues.Count -gt 0)) {
        throw "$SourceLabel ready_for_fix_execution requires no refusal_reasons, no no_fix_items, and no unmapped blocking issues."
    }
    if ($aggregateVerdict -eq "blocked" -and $refusalReasons.Count -eq 0) {
        throw "$SourceLabel blocked aggregate_verdict requires refusal_reasons."
    }

    $PSCmdlet.WriteObject([pscustomobject][ordered]@{
        QueueId = $Queue.queue_id
        Repository = $Queue.repository
        Branch = $Queue.branch
        Head = $Queue.head
        Tree = $Queue.tree
        SourceIssueCount = $sourceIssueCount
        BlockingIssueCount = $blockingIssueCount
        FixItemCount = $fixItems.Count
        NoFixItemCount = $noFixItems.Count
        UnmappedBlockingIssueCount = $unmappedBlockingIssues.Count
        AggregateVerdict = $aggregateVerdict
    }, $false)
}

function Test-R13QaFixQueue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$QueuePath
    )

    $queue = Get-JsonDocument -Path $QueuePath -Label "R13 QA fix queue"
    return Test-R13QaFixQueueObject -Queue $queue -SourceLabel "R13 QA fix queue"
}

Export-ModuleMember -Function Get-R13QaFixQueueContract, New-R13QaFixQueue, Test-R13QaFixQueueObject, Test-R13QaFixQueue
