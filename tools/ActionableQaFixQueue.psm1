Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force
$actionableQaModule = Import-Module (Join-Path $PSScriptRoot "ActionableQa.psm1") -Force -PassThru
$script:TestActionableQaReport = $actionableQaModule.ExportedCommands["Test-ActionableQaReport"]

$script:R12RepositoryName = "AIOffice_V2"
$script:R12Branch = "release/r12-external-api-runner-actionable-qa-control-room-pilot"
$script:GitObjectPattern = "^[a-f0-9]{40}$"
$script:TimestampPattern = "^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$"
$script:AllowedIssueSeverities = @("info", "warning", "error", "critical")
$script:AllowedBlockingStatuses = @("non_blocking", "blocking", "advisory")
$script:RequiredNonClaims = @(
    "recommendations are bounded/static",
    "no automatic repair claim",
    "no production QA",
    "no R12 closeout",
    "no full value-gate delivery by static recommendations"
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
        throw "Actionable QA fix queue output '$Path' already exists. Use -Overwrite to replace it explicitly."
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

    foreach ($requiredNonClaim in $script:RequiredNonClaims) {
        if ($NonClaims -notcontains $requiredNonClaim) {
            throw "$Context non_claims must include '$requiredNonClaim'."
        }
    }
}

function Assert-FilePathOrNotApplicable {
    param(
        [Parameter(Mandatory = $true)]
        $Item,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $filePath = Assert-StringValue -Value $Item.file_path -Context "$Context file_path"
    $evidence = Assert-ObjectValue -Value $Item.evidence -Context "$Context evidence"
    if ([string]::IsNullOrWhiteSpace($filePath)) {
        throw "$Context must include file path or explicit not_applicable reason."
    }
    if ($filePath -eq "not_applicable") {
        if (-not (Test-HasProperty -Object $evidence -Name "not_applicable_reason")) {
            throw "$Context file_path not_applicable requires evidence.not_applicable_reason."
        }
        Assert-NonEmptyString -Value $evidence.not_applicable_reason -Context "$Context evidence.not_applicable_reason" | Out-Null
    }
    else {
        Assert-BoundedPathOrUrl -Value $filePath -Context "$Context file_path"
    }
}

function Get-ActionableQaFixQueueContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "actionable_qa", "actionable_qa_fix_queue.contract.json")) -Label "Actionable QA fix queue contract"
}

function Get-SourceActionableQaReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ReportRef
    )

    Assert-ExistingEvidenceRef -Ref $ReportRef -Context "Actionable QA fix queue source_actionable_qa_report_ref"
    & $script:TestActionableQaReport -ReportPath $ReportRef | Out-Null
    return Get-JsonDocument -Path (Resolve-RepositoryPath -PathValue $ReportRef) -Label "Source actionable QA report"
}

function Test-ActionableQaFixQueueObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Queue,
        [string]$SourceLabel = "Actionable QA fix queue"
    )

    $contract = Get-ActionableQaFixQueueContract
    Assert-RequiredObjectFields -Object $Queue -FieldNames $contract.required_fields -Context $SourceLabel

    if ($Queue.contract_version -ne $contract.contract_version) {
        throw "$SourceLabel contract_version must be '$($contract.contract_version)'."
    }
    if ($Queue.artifact_type -ne "actionable_qa_fix_queue") {
        throw "$SourceLabel artifact_type must be 'actionable_qa_fix_queue'."
    }
    Assert-NonEmptyString -Value $Queue.queue_id -Context "$SourceLabel queue_id" | Out-Null
    if ($Queue.repository -ne $script:R12RepositoryName) {
        throw "$SourceLabel repository must be '$script:R12RepositoryName'."
    }
    if ($Queue.branch -ne $script:R12Branch) {
        throw "$SourceLabel branch must be '$script:R12Branch'."
    }
    Assert-GitSha -Value ([string]$Queue.head) -Context "$SourceLabel head"
    Assert-GitSha -Value ([string]$Queue.tree) -Context "$SourceLabel tree"
    $sourceReportRef = Assert-NonEmptyString -Value $Queue.source_actionable_qa_report_ref -Context "$SourceLabel source_actionable_qa_report_ref"
    $sourceReport = Get-SourceActionableQaReport -ReportRef $sourceReportRef
    Assert-TimestampString -Value $Queue.generated_at_utc -Context "$SourceLabel generated_at_utc" | Out-Null

    if ($Queue.repository -ne $sourceReport.repository -or $Queue.branch -ne $sourceReport.branch -or $Queue.head -ne $sourceReport.head -or $Queue.tree -ne $sourceReport.tree) {
        throw "$SourceLabel branch/head/tree must match source actionable QA report."
    }

    $sourceIssues = @($sourceReport.issues)
    $sourceIssueIds = @{}
    $sourceBlockingIssueIds = New-Object System.Collections.Generic.List[string]
    $expectedSeverityCounts = @{ critical = 0; error = 0; warning = 0; info = 0 }
    $expectedComponentCounts = @{}
    foreach ($issue in $sourceIssues) {
        $sourceIssueIds[$issue.id] = $issue
        $expectedSeverityCounts[$issue.severity] += 1
        if (-not $expectedComponentCounts.ContainsKey($issue.component)) {
            $expectedComponentCounts[$issue.component] = 0
        }
        $expectedComponentCounts[$issue.component] += 1
        if ($issue.blocking_status -eq "blocking") {
            $sourceBlockingIssueIds.Add([string]$issue.id) | Out-Null
        }
    }

    $issueCount = Assert-IntegerValue -Value $Queue.issue_count -Context "$SourceLabel issue_count" -Minimum 0
    $blockingIssueCount = Assert-IntegerValue -Value $Queue.blocking_issue_count -Context "$SourceLabel blocking_issue_count" -Minimum 0
    if ($issueCount -ne $sourceIssues.Count) {
        throw "$SourceLabel issue_count must match source report issues."
    }
    if ($blockingIssueCount -ne $sourceBlockingIssueIds.Count) {
        throw "$SourceLabel queue cannot hide blocking issues; blocking_issue_count must match source report."
    }

    $issuesBySeverity = Assert-ObjectValue -Value $Queue.issues_by_severity -Context "$SourceLabel issues_by_severity"
    foreach ($severity in $script:AllowedIssueSeverities) {
        $declared = Assert-IntegerValue -Value (Get-RequiredProperty -Object $issuesBySeverity -Name $severity -Context "$SourceLabel issues_by_severity") -Context "$SourceLabel issues_by_severity.$severity" -Minimum 0
        if ($declared -ne $expectedSeverityCounts[$severity]) {
            throw "$SourceLabel issues_by_severity.$severity must match source report."
        }
    }

    $issuesByComponent = Assert-ObjectValue -Value $Queue.issues_by_component -Context "$SourceLabel issues_by_component"
    foreach ($componentName in $expectedComponentCounts.Keys) {
        $declared = Assert-IntegerValue -Value (Get-RequiredProperty -Object $issuesByComponent -Name $componentName -Context "$SourceLabel issues_by_component") -Context "$SourceLabel issues_by_component.$componentName" -Minimum 0
        if ($declared -ne $expectedComponentCounts[$componentName]) {
            throw "$SourceLabel issues_by_component.$componentName must match source report."
        }
    }

    $fixItems = Assert-ObjectArray -Value $Queue.fix_items -Context "$SourceLabel fix_items" -AllowEmpty
    $fixItemsBySourceIssue = @{}
    foreach ($fixItem in $fixItems) {
        Assert-RequiredObjectFields -Object $fixItem -FieldNames $contract.fix_item_required_fields -Context "$SourceLabel fix_item"
        Assert-NonEmptyString -Value $fixItem.fix_id -Context "$SourceLabel fix_item.fix_id" | Out-Null
        $sourceIssueId = Assert-NonEmptyString -Value $fixItem.source_issue_id -Context "$SourceLabel fix_item.source_issue_id"
        if (-not $sourceIssueIds.ContainsKey($sourceIssueId)) {
            throw "$SourceLabel fix_item source_issue_id '$sourceIssueId' does not map to a source issue."
        }
        $sourceIssue = $sourceIssueIds[$sourceIssueId]
        $severity = Assert-NonEmptyString -Value $fixItem.severity -Context "$SourceLabel fix_item.severity"
        Assert-AllowedValue -Value $severity -AllowedValues $script:AllowedIssueSeverities -Context "$SourceLabel fix_item.severity"
        if ($severity -ne $sourceIssue.severity) {
            throw "$SourceLabel fix_item severity must match source issue '$sourceIssueId'."
        }
        Assert-NonEmptyString -Value $fixItem.component -Context "$SourceLabel fix_item.component" | Out-Null
        Assert-FilePathOrNotApplicable -Item $fixItem -Context "$SourceLabel fix_item"
        Assert-IntegerValue -Value $fixItem.line -Context "$SourceLabel fix_item.line" -Minimum 0 | Out-Null
        Assert-NonEmptyString -Value $fixItem.failed_rule -Context "$SourceLabel fix_item.failed_rule" | Out-Null
        Assert-NonEmptyString -Value $fixItem.recommended_fix -Context "$SourceLabel fix_item.recommended_fix" | Out-Null
        Assert-NonEmptyString -Value $fixItem.reproduction_command -Context "$SourceLabel fix_item.reproduction_command" | Out-Null
        $blockingStatus = Assert-NonEmptyString -Value $fixItem.blocking_status -Context "$SourceLabel fix_item.blocking_status"
        Assert-AllowedValue -Value $blockingStatus -AllowedValues $script:AllowedBlockingStatuses -Context "$SourceLabel fix_item.blocking_status"
        Assert-NonEmptyString -Value $fixItem.owner_role -Context "$SourceLabel fix_item.owner_role" | Out-Null
        Assert-IntegerValue -Value $fixItem.suggested_order -Context "$SourceLabel fix_item.suggested_order" -Minimum 1 | Out-Null
        if ($fixItem.recommended_fix -ne $sourceIssue.recommended_fix) {
            throw "$SourceLabel fix_item recommended_fix must match source issue '$sourceIssueId'."
        }
        if ($fixItem.reproduction_command -ne $sourceIssue.reproduction_command) {
            throw "$SourceLabel fix_item reproduction_command must match source issue '$sourceIssueId'."
        }
        $fixItemsBySourceIssue[$sourceIssueId] = $fixItem
    }

    foreach ($blockingIssueId in @($sourceBlockingIssueIds)) {
        if (-not $fixItemsBySourceIssue.ContainsKey($blockingIssueId)) {
            throw "$SourceLabel every blocking issue must have a fix item; missing '$blockingIssueId'."
        }
    }

    $reproductionCommands = Assert-StringArray -Value $Queue.reproduction_commands -Context "$SourceLabel reproduction_commands"
    Assert-NonEmptyString -Value $Queue.recommended_next_action -Context "$SourceLabel recommended_next_action" | Out-Null
    $evidenceRefs = Assert-StringArray -Value $Queue.evidence_refs -Context "$SourceLabel evidence_refs"
    foreach ($evidenceRef in $evidenceRefs) {
        Assert-ExistingEvidenceRef -Ref $evidenceRef -Context "$SourceLabel evidence_refs"
    }
    $nonClaims = Assert-StringArray -Value $Queue.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel

    $PSCmdlet.WriteObject([pscustomobject][ordered]@{
            QueueId = $Queue.queue_id
            Repository = $Queue.repository
            Branch = $Queue.branch
            Head = $Queue.head
            Tree = $Queue.tree
            IssueCount = $issueCount
            BlockingIssueCount = $blockingIssueCount
            FixItemCount = $fixItems.Count
            RecommendedNextAction = $Queue.recommended_next_action
            ReproductionCommandCount = $reproductionCommands.Count
        }, $false)
}

function Test-ActionableQaFixQueue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$QueuePath
    )

    $queue = Get-JsonDocument -Path $QueuePath -Label "Actionable QA fix queue"
    return Test-ActionableQaFixQueueObject -Queue $queue -SourceLabel "Actionable QA fix queue"
}

function Export-ActionableQaFixQueueMarkdown {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Queue,
        [Parameter(Mandatory = $true)]
        [string]$MarkdownOutputPath,
        [switch]$Overwrite
    )

    if ((Test-Path -LiteralPath $MarkdownOutputPath -PathType Leaf) -and -not $Overwrite) {
        throw "Actionable QA fix queue Markdown output '$MarkdownOutputPath' already exists. Use -Overwrite to replace it explicitly."
    }

    $parentPath = Split-Path -Parent $MarkdownOutputPath
    if (-not [string]::IsNullOrWhiteSpace($parentPath)) {
        New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    }

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# R12 Actionable QA Fix Queue") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add(("- Queue ID: ``{0}``" -f $Queue.queue_id)) | Out-Null
    $lines.Add(("- Source report: ``{0}``" -f $Queue.source_actionable_qa_report_ref)) | Out-Null
    $lines.Add(("- Issue count: {0}" -f $Queue.issue_count)) | Out-Null
    $lines.Add(("- Blocking count: {0}" -f $Queue.blocking_issue_count)) | Out-Null
    $lines.Add(("- Recommended next action: {0}" -f $Queue.recommended_next_action)) | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## Commands") | Out-Null
    foreach ($command in @($Queue.reproduction_commands)) {
        $lines.Add(("- ``{0}``" -f $command)) | Out-Null
    }
    $lines.Add("") | Out-Null
    $lines.Add("## Fix Items") | Out-Null
    if (@($Queue.fix_items).Count -eq 0) {
        $lines.Add("- No fix items were generated because no source issues were present.") | Out-Null
    }
    else {
        foreach ($fixItem in @($Queue.fix_items | Sort-Object suggested_order)) {
            $lines.Add(("- {0}. ``{1}`` [{2}/{3}] ``{4}:{5}`` - {6}" -f $fixItem.suggested_order, $fixItem.source_issue_id, $fixItem.severity, $fixItem.blocking_status, $fixItem.file_path, $fixItem.line, $fixItem.recommended_fix)) | Out-Null
        }
    }
    $lines.Add("") | Out-Null
    $lines.Add("## Non-Claims") | Out-Null
    foreach ($nonClaim in @($Queue.non_claims)) {
        $lines.Add("- $nonClaim") | Out-Null
    }

    Set-Content -LiteralPath $MarkdownOutputPath -Value $lines -Encoding UTF8
    return $MarkdownOutputPath
}

function Test-ActionableQaFixQueueMarkdown {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$QueuePath,
        [Parameter(Mandatory = $true)]
        [string]$MarkdownPath
    )

    $queue = Get-JsonDocument -Path $QueuePath -Label "Actionable QA fix queue"
    $text = Get-Content -LiteralPath $MarkdownPath -Raw
    foreach ($expected in @(
            ("Issue count: {0}" -f $queue.issue_count),
            ("Blocking count: {0}" -f $queue.blocking_issue_count),
            "## Commands",
            $queue.recommended_next_action
        )) {
        if ($text -notmatch [regex]::Escape($expected)) {
            throw "Actionable QA fix queue Markdown export must include '$expected'."
        }
    }

    return [pscustomobject][ordered]@{
        MarkdownPath = $MarkdownPath
        IssueCount = $queue.issue_count
        BlockingIssueCount = $queue.blocking_issue_count
        RecommendedNextAction = $queue.recommended_next_action
    }
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

function New-ActionableQaFixQueue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ActionableQaReportPath,
        [string]$OutputPath = "",
        [string]$MarkdownOutputPath = "",
        [string]$RecommendedNextAction = "",
        [switch]$Overwrite
    )

    $sourceReportRef = $ActionableQaReportPath.Replace("\", "/")
    $sourceReport = Get-SourceActionableQaReport -ReportRef $sourceReportRef
    $sourceIssues = @($sourceReport.issues)
    $blockingIssueCount = @($sourceIssues | Where-Object { $_.blocking_status -eq "blocking" }).Count

    $issuesBySeverity = @{ critical = 0; error = 0; warning = 0; info = 0 }
    $issuesByComponent = @{}
    foreach ($issue in $sourceIssues) {
        $issuesBySeverity[$issue.severity] += 1
        if (-not $issuesByComponent.ContainsKey($issue.component)) {
            $issuesByComponent[$issue.component] = 0
        }
        $issuesByComponent[$issue.component] += 1
    }

    $orderedIssues = @($sourceIssues | Sort-Object @{ Expression = { if ($_.blocking_status -eq "blocking") { 0 } else { 1 } } }, @{ Expression = { Get-SeveritySortRank -Severity $_.severity } }, id)
    $fixItems = New-Object System.Collections.Generic.List[object]
    $order = 0
    foreach ($issue in $orderedIssues) {
        $order += 1
        $fixItems.Add([pscustomobject][ordered]@{
                fix_id = "fix-" + ([regex]::Replace([string]$issue.id, '[^A-Za-z0-9_.-]', '-'))
                source_issue_id = $issue.id
                severity = $issue.severity
                component = $issue.component
                file_path = $issue.file_path
                line = $issue.line
                failed_rule = $issue.failed_rule
                recommended_fix = $issue.recommended_fix
                reproduction_command = $issue.reproduction_command
                blocking_status = $issue.blocking_status
                owner_role = "repository_maintainer"
                suggested_order = $order
                evidence = $issue.evidence
            }) | Out-Null
    }

    $nextAction = $RecommendedNextAction
    if ([string]::IsNullOrWhiteSpace($nextAction)) {
        if ($blockingIssueCount -gt 0) {
            $nextAction = "resolve_blocking_issues_before_rerunning_gate"
        }
        elseif ($sourceIssues.Count -gt 0) {
            $nextAction = "review_non_blocking_issues_and_rerun_actionable_qa"
        }
        else {
            $nextAction = "no_actionable_issues_recorded_rerun_gate_with_external_evidence"
        }
    }

    $evidenceRefs = @($sourceReportRef) + @($sourceReport.evidence_refs) + @(
        "contracts/actionable_qa/actionable_qa_fix_queue.contract.json",
        "tools/ActionableQaFixQueue.psm1"
    )
    $evidenceRefs = @($evidenceRefs | Sort-Object -Unique)

    $queueData = [ordered]@{}
    $queueData["contract_version"] = "v1"
    $queueData["artifact_type"] = "actionable_qa_fix_queue"
    $queueData["queue_id"] = ("r12-actionable-qa-fix-queue-" + [guid]::NewGuid().ToString("N"))
    $queueData["repository"] = $sourceReport.repository
    $queueData["branch"] = $sourceReport.branch
    $queueData["head"] = $sourceReport.head
    $queueData["tree"] = $sourceReport.tree
    $queueData["source_actionable_qa_report_ref"] = $sourceReportRef
    $queueData["generated_at_utc"] = Get-UtcTimestamp
    $queueData["issue_count"] = $sourceIssues.Count
    $queueData["blocking_issue_count"] = $blockingIssueCount
    $queueData["issues_by_severity"] = Convert-HashtableToObject -Table $issuesBySeverity
    $queueData["issues_by_component"] = Convert-HashtableToObject -Table $issuesByComponent
    $queueData["fix_items"] = @($fixItems | ForEach-Object { $_ })
    $queueData["reproduction_commands"] = @($sourceReport.reproduction_commands)
    $queueData["recommended_next_action"] = $nextAction
    $queueData["evidence_refs"] = @($evidenceRefs)
    $queueData["non_claims"] = @($script:RequiredNonClaims)
    $queue = [pscustomobject]$queueData

    Test-ActionableQaFixQueueObject -Queue $queue -SourceLabel "Actionable QA fix queue draft" | Out-Null

    if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
        Write-JsonDocument -Path (Resolve-RepositoryPath -PathValue $OutputPath) -Document $queue -Overwrite:$Overwrite
    }
    if (-not [string]::IsNullOrWhiteSpace($MarkdownOutputPath)) {
        Export-ActionableQaFixQueueMarkdown -Queue $queue -MarkdownOutputPath (Resolve-RepositoryPath -PathValue $MarkdownOutputPath) -Overwrite:$Overwrite | Out-Null
    }

    $PSCmdlet.WriteObject($queue, $false)
}

Export-ModuleMember -Function Get-ActionableQaFixQueueContract, Test-ActionableQaFixQueueObject, Test-ActionableQaFixQueue, New-ActionableQaFixQueue, Export-ActionableQaFixQueueMarkdown, Test-ActionableQaFixQueueMarkdown
