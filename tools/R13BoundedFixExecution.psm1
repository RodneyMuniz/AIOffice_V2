Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force
$fixQueueModule = Import-Module (Join-Path $PSScriptRoot "R13QaFixQueue.psm1") -Force -PassThru
$script:TestFixQueue = $fixQueueModule.ExportedCommands["Test-R13QaFixQueue"]

$script:R13RepositoryName = "AIOffice_V2"
$script:R13Branch = "release/r13-api-first-qa-pipeline-and-operator-control-room-product-slice"
$script:R13Milestone = "R13 API-First QA Pipeline and Operator Control-Room Product Slice"
$script:R13SourceTask = "R13-005"
$script:R13FixQueueTask = "R13-004"
$script:CycleQaRoot = "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/qa"
$script:DefaultPacketRef = "$script:CycleQaRoot/r13_005_bounded_fix_execution_packet.json"
$script:GitObjectPattern = "^[a-f0-9]{40}$"
$script:TimestampPattern = "^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$"
$script:AllowedExecutionModes = @("authorization_only", "dry_run", "executed")
$script:AllowedExecutionStatuses = @("authorized", "blocked", "dry_run_complete", "executed_pending_validation", "validation_passed", "validation_failed")
$script:AllowedAggregateVerdicts = @("authorized_for_future_execution", "blocked", "dry_run_complete", "execution_recorded", "validation_failed", "validation_passed")
$script:RequiredNonClaims = @(
    "R13-005 implements the bounded fix execution packet model only",
    "no actual fix execution has occurred",
    "no target file mutation has occurred",
    "no QA rerun has occurred",
    "no before/after comparison has occurred",
    "no external replay has occurred",
    "no final QA signoff has occurred",
    "no R13 hard value gate delivered by R13-005",
    "no meaningful QA loop delivered yet",
    "no production QA delivered by R13-005",
    "no executor self-certification as QA or execution authority",
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

    foreach ($item in $items) {
        $PSCmdlet.WriteObject($item)
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

function Get-UniqueStrings {
    [CmdletBinding()]
    param(
        [AllowNull()]
        [object[]]$Values
    )

    $seen = @{}
    $items = @()
    foreach ($value in @($Values)) {
        if ($null -eq $value) {
            continue
        }
        $text = [string]$value
        if ([string]::IsNullOrWhiteSpace($text)) {
            continue
        }
        if (-not $seen.ContainsKey($text)) {
            $seen[$text] = $true
            $items += $text
        }
    }

    foreach ($item in $items) {
        $PSCmdlet.WriteObject($item)
    }
}

function Test-RepositoryRelativePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [switch]$AllowUrl
    )

    if ([string]::IsNullOrWhiteSpace($PathValue)) {
        return $false
    }
    if ($AllowUrl -and $PathValue -match '^https?://') {
        return $true
    }
    if ($PathValue -match '^https?://') {
        return $false
    }
    if ([System.IO.Path]::IsPathRooted($PathValue) -or $PathValue -match '(^|[\\/])\.\.([\\/]|$)') {
        return $false
    }

    $resolved = [System.IO.Path]::GetFullPath((Join-Path (Get-RepositoryRoot) $PathValue))
    $root = [System.IO.Path]::GetFullPath((Get-RepositoryRoot)).TrimEnd([char[]]@([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar))
    return $resolved.Equals($root, [System.StringComparison]::OrdinalIgnoreCase) -or $resolved.StartsWith($root + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)
}

function Test-BroadTargetPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue
    )

    return $PathValue -in @(".", "./", "*", "**", "*/", "**/*")
}

function Assert-TargetFilePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [Parameter(Mandatory = $true)]
        [bool]$AllowBroadScope,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$BroadScopeJustification,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if (-not (Test-RepositoryRelativePath -PathValue $PathValue)) {
        throw "$Context target_files must be repository-relative paths inside the repository."
    }
    if (Test-BroadTargetPath -PathValue $PathValue) {
        if (-not $AllowBroadScope -or [string]::IsNullOrWhiteSpace($BroadScopeJustification)) {
            throw "$Context broad scope target '$PathValue' requires explicit broad-scope authorization and justification."
        }
    }
}

function Assert-ExistingOrExpectedEvidenceRef {
    param(
        [Parameter(Mandatory = $true)]
        $Evidence,
        [Parameter(Mandatory = $true)]
        [string[]]$RequiredFields,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-RequiredObjectFields -Object $Evidence -FieldNames $RequiredFields -Context $Context
    Assert-NonEmptyString -Value $Evidence.ref_id -Context "$Context ref_id" | Out-Null
    $ref = Assert-NonEmptyString -Value $Evidence.ref -Context "$Context ref"
    Assert-NonEmptyString -Value $Evidence.evidence_kind -Context "$Context evidence_kind" | Out-Null
    Assert-NoForbiddenAuthority -AuthorityKind ([string]$Evidence.authority_kind) -Context "$Context authority_kind"
    Assert-NonEmptyString -Value $Evidence.scope -Context "$Context scope" | Out-Null

    $status = [string](Get-PropertyValue -Object $Evidence -Name "status" -Default "")
    if (-not (Test-RepositoryRelativePath -PathValue $ref -AllowUrl)) {
        throw "$Context ref '$ref' must be repository-relative, inside the repository, or an http(s) URL."
    }
    if ($ref -notmatch '^https?://' -and $status -ne "expected_future_evidence" -and -not (Test-Path -LiteralPath (Resolve-RepositoryPath -PathValue $ref))) {
        throw "$Context ref '$ref' must exist unless it is explicitly marked expected_future_evidence."
    }
}

function Get-R13BoundedFixExecutionContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "actionable_qa", "r13_bounded_fix_execution.contract.json")) -Label "R13 bounded fix execution contract"
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

    $hex = -join ($hash[0..15] | ForEach-Object { $_.ToString("x2", [System.Globalization.CultureInfo]::InvariantCulture) })
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

    return ($Line -match '(?i)\b(no|not|without|cannot|must not|does not|do not|is not|are not|did not|non-claim|non_claim|refuse|refuses|blocked|planned only|not yet delivered|expected future|expected_future|future evidence|future_repo_evidence|rejects|rejected)\b')
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
        throw "$Context rejects executor self-certification as execution or QA authority."
    }
}

function Assert-NoLocalOnlyExternalProof {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$EvidenceRefs,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($evidence in @($EvidenceRefs)) {
        $kind = [string](Get-PropertyValue -Object $evidence -Name "evidence_kind" -Default "")
        $authority = [string](Get-PropertyValue -Object $evidence -Name "authority_kind" -Default "")
        $scope = [string](Get-PropertyValue -Object $evidence -Name "scope" -Default "")
        if ($kind -match '(?i)external[_ -]?(proof|replay)' -and ($authority -notmatch '(?i)external_runner' -or $scope -notmatch '(?i)^external$')) {
            throw "$Context local-only evidence cannot be treated as external proof."
        }
    }
}

function Assert-NoForbiddenR13Claims {
    param(
        [Parameter(Mandatory = $true)]
        $Packet,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $claimSurfaces = @(
        (Get-PropertyValue -Object $Packet -Name "actual_changes" -Default @()),
        (Get-PropertyValue -Object $Packet -Name "produced_evidence_refs" -Default @()),
        (Get-PropertyValue -Object $Packet -Name "validation_results" -Default @()),
        (Get-PropertyValue -Object $Packet -Name "execution_summary" -Default @()),
        (Get-PropertyValue -Object $Packet -Name "refusal_reasons" -Default @())
    )

    foreach ($line in @(Get-StringLeaves -Value $claimSurfaces)) {
        if ($line -match '(?i)\brerun\b|\bQA rerun\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims rerun before the R13 rerun task. Offending text: $line"
        }
        if ($line -match '(?i)\bbefore[/ -]?after\b|\bcomparison\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims before/after comparison before the comparison task. Offending text: $line"
        }
        if ($line -match '(?i)\bexternal replay\b|\bexternal[_ -]?replay\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims external replay before the external task. Offending text: $line"
        }
        if ($line -match '(?i)\bsignoff\b|\bsign-off\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims signoff before the signoff task. Offending text: $line"
        }
        if ($line -match '(?i)\bhard R13 value gate\b|\bproduction QA\b|\breal production QA\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims hard gate delivery or production QA before the required R13 tasks. Offending text: $line"
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

function Assert-SourceFixQueueIdentity {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Queue,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Queue.repository -ne $script:R13RepositoryName) {
        throw "$Context source fix queue repository must be '$script:R13RepositoryName'."
    }
    if ($Queue.branch -ne $script:R13Branch) {
        throw "$Context source fix queue branch must be '$script:R13Branch'."
    }
    if ($Queue.source_milestone -ne $script:R13Milestone) {
        throw "$Context source fix queue source_milestone must be '$script:R13Milestone'."
    }
    if ($Queue.source_task -ne $script:R13FixQueueTask) {
        throw "$Context source fix queue source_task must be '$script:R13FixQueueTask'."
    }
    if ($Queue.aggregate_verdict -ne "ready_for_fix_execution") {
        throw "$Context source fix queue aggregate_verdict must be 'ready_for_fix_execution'."
    }
}

function Get-ValidatedSourceFixQueue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$FixQueuePath,
        [string]$Context = "R13 bounded fix execution packet"
    )

    $resolvedQueuePath = Resolve-RepositoryPath -PathValue $FixQueuePath
    & $script:TestFixQueue -QueuePath $resolvedQueuePath | Out-Null
    $queue = Get-JsonDocument -Path $resolvedQueuePath -Label "R13 QA fix queue"
    Assert-SourceFixQueueIdentity -Queue $queue -Context $Context
    return $queue
}

function Get-SelectedFixItems {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Queue,
        [AllowNull()]
        [string[]]$FixItemId,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $fixItems = @($Queue.fix_items)
    $itemsById = @{}
    foreach ($item in $fixItems) {
        $itemsById[[string]$item.fix_item_id] = $item
    }

    if ($null -eq $FixItemId -or @($FixItemId).Count -eq 0) {
        if ($fixItems.Count -eq 0) {
            throw "$Context source fix queue has no queued fix items to select."
        }
        foreach ($item in $fixItems) {
            $PSCmdlet.WriteObject($item)
        }
        return
    }

    $selected = @()
    foreach ($id in @(Get-UniqueStrings -Values $FixItemId)) {
        if (-not $itemsById.ContainsKey($id)) {
            throw "$Context selected fix item '$id' is not present in the source queue."
        }
        $selected += $itemsById[$id]
    }

    foreach ($item in $selected) {
        $PSCmdlet.WriteObject($item)
    }
}

function Assert-SelectedSourceIssueIds {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$SelectedSourceIssueIds,
        [Parameter(Mandatory = $true)]
        [object[]]$SelectedFixItems,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $mappedSourceIds = @(Get-UniqueStrings -Values @($SelectedFixItems | ForEach-Object { @($_.source_issue_ids) }))
    foreach ($sourceIssueId in $SelectedSourceIssueIds) {
        if ($mappedSourceIds -notcontains $sourceIssueId) {
            throw "$Context selected_source_issue_ids contains '$sourceIssueId' that is not mapped by selected fix items."
        }
    }
    foreach ($mappedSourceId in $mappedSourceIds) {
        if ($SelectedSourceIssueIds -notcontains $mappedSourceId) {
            throw "$Context selected_source_issue_ids must preserve mapped source issue '$mappedSourceId'."
        }
    }
}

function Assert-SelectedFixItemIds {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$SelectedFixItemIds,
        [Parameter(Mandatory = $true)]
        $Queue,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $queueIds = @($Queue.fix_items | ForEach-Object { [string]$_.fix_item_id })
    foreach ($id in $SelectedFixItemIds) {
        if ($queueIds -notcontains $id) {
            throw "$Context selected fix item '$id' is not present in the source queue."
        }
    }
}

function Assert-FixItemScope {
    param(
        [Parameter(Mandatory = $true)]
        $FixItem,
        [Parameter(Mandatory = $true)]
        [bool]$AllowBroadScope,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$BroadScopeJustification,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $targetFiles = Assert-StringArray -Value $FixItem.target_files -Context "$Context target_files"
    $boundedScope = Assert-ObjectValue -Value $FixItem.bounded_scope -Context "$Context bounded_scope"
    $itemAllowsBroadScope = [bool](Get-PropertyValue -Object $boundedScope -Name "allow_broad_scope" -Default $false)
    $itemBroadJustification = [string](Get-PropertyValue -Object $boundedScope -Name "broad_scope_justification" -Default "")
    foreach ($targetFile in $targetFiles) {
        $effectiveAllowBroadScope = $AllowBroadScope -or $itemAllowsBroadScope
        $effectiveBroadJustification = if (-not [string]::IsNullOrWhiteSpace($BroadScopeJustification)) { $BroadScopeJustification } else { $itemBroadJustification }
        Assert-TargetFilePath -PathValue $targetFile -AllowBroadScope $effectiveAllowBroadScope -BroadScopeJustification $effectiveBroadJustification -Context $Context
    }
}

function New-PlannedChange {
    param(
        [Parameter(Mandatory = $true)]
        $FixItem
    )

    return [pscustomobject][ordered]@{
        fix_item_id = [string]$FixItem.fix_item_id
        source_issue_ids = @($FixItem.source_issue_ids)
        target_files = @($FixItem.target_files)
        bounded_scope = $FixItem.bounded_scope
        proposed_change_summary = [string]$FixItem.proposed_change_summary
        allowed_commands = @($FixItem.allowed_commands)
        validation_commands = @($FixItem.validation_commands)
        rollback_plan = [string]$FixItem.rollback_note
        expected_evidence_refs = @($FixItem.expected_evidence_refs)
    }
}

function New-RollbackPlanEntry {
    param(
        [Parameter(Mandatory = $true)]
        $FixItem
    )

    return [pscustomobject][ordered]@{
        fix_item_id = [string]$FixItem.fix_item_id
        source_issue_ids = @($FixItem.source_issue_ids)
        target_files = @($FixItem.target_files)
        rollback_note = [string]$FixItem.rollback_note
    }
}

function New-R13BoundedFixExecutionPacket {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$FixQueuePath,
        [string[]]$FixItemId = @(),
        [ValidateSet("authorization_only", "dry_run", "executed")]
        [string]$Mode = "authorization_only",
        [switch]$AllowBroadScope,
        [string]$PacketRef = $script:DefaultPacketRef
    )

    if ($Mode -eq "executed") {
        throw "executed mode is reserved for future R13 tasks and is not generated by R13-005."
    }

    $queue = Get-ValidatedSourceFixQueue -FixQueuePath $FixQueuePath -Context "R13 bounded fix execution packet generator"
    $selectedFixItems = @(Get-SelectedFixItems -Queue $queue -FixItemId $FixItemId -Context "R13 bounded fix execution packet generator")

    $broadScopeJustification = if ($AllowBroadScope) {
        "AllowBroadScope was explicitly supplied for this bounded packet and must be justified by each broad target scope."
    }
    else {
        ""
    }

    foreach ($item in $selectedFixItems) {
        Assert-FixItemScope -FixItem $item -AllowBroadScope ([bool]$AllowBroadScope) -BroadScopeJustification $broadScopeJustification -Context "R13 bounded fix execution packet generator fix item '$($item.fix_item_id)'"
        $validationCommands = Assert-StringArray -Value $item.validation_commands -Context "R13 bounded fix execution packet generator fix item '$($item.fix_item_id)' validation_commands"
        if (@($validationCommands).Count -eq 0) {
            throw "R13 bounded fix execution packet generator fix item '$($item.fix_item_id)' missing validation commands."
        }
        Assert-NonEmptyString -Value $item.rollback_note -Context "R13 bounded fix execution packet generator fix item '$($item.fix_item_id)' rollback_note" | Out-Null
        Assert-StringArray -Value $item.expected_evidence_refs -Context "R13 bounded fix execution packet generator fix item '$($item.fix_item_id)' expected_evidence_refs" | Out-Null
    }

    $selectedFixItemIds = @(Get-UniqueStrings -Values @($selectedFixItems | ForEach-Object { [string]$_.fix_item_id }))
    $selectedSourceIssueIds = @(Get-UniqueStrings -Values @($selectedFixItems | ForEach-Object { @($_.source_issue_ids) }))
    Assert-SelectedSourceIssueIds -SelectedSourceIssueIds $selectedSourceIssueIds -SelectedFixItems $selectedFixItems -Context "R13 bounded fix execution packet generator"

    $targetFiles = @(Get-UniqueStrings -Values @($selectedFixItems | ForEach-Object { @($_.target_files) }))
    $allowedCommands = @(Get-UniqueStrings -Values @(@($queue.commands_required) + @($selectedFixItems | ForEach-Object { @($_.allowed_commands) }) + @($queue.validation_commands)))
    $validationCommandsForPacket = @(Get-UniqueStrings -Values @(@($queue.validation_commands) + @($selectedFixItems | ForEach-Object { @($_.validation_commands) })))
    if (@($validationCommandsForPacket).Count -eq 0) {
        throw "R13 bounded fix execution packet generator missing validation commands."
    }

    $plannedChanges = @($selectedFixItems | ForEach-Object { New-PlannedChange -FixItem $_ })
    $rollbackPlan = @($selectedFixItems | ForEach-Object { New-RollbackPlanEntry -FixItem $_ })
    $executionStatus = if ($Mode -eq "dry_run") { "dry_run_complete" } else { "authorized" }
    $aggregateVerdict = if ($Mode -eq "dry_run") { "dry_run_complete" } else { "authorized_for_future_execution" }
    $actualChanges = @()
    if ($Mode -eq "dry_run") {
        $actualChanges = @(
            [pscustomobject][ordered]@{
                change_kind = "dry_run_no_mutation"
                fix_item_ids = @($selectedFixItemIds)
                changed_files = @()
                target_files_reviewed = @($targetFiles)
                mutation_performed = $false
                summary = "Dry-run/no-mutation packet only; no target files were changed and no fixes were executed."
            }
        )
    }

    $head = Invoke-GitLine -Arguments @("rev-parse", "HEAD")
    $tree = Invoke-GitLine -Arguments @("rev-parse", "HEAD^{tree}")
    $sourceFixQueueRef = Convert-ToRepositoryRelativePath -PathValue $FixQueuePath
    $executionId = Get-StableId -Prefix "r13bfe" -Key ("{0}|{1}|{2}|{3}" -f $queue.queue_id, $Mode, ($selectedFixItemIds -join ","), $sourceFixQueueRef)

    return [pscustomobject][ordered]@{
        contract_version = "v1"
        artifact_type = "r13_bounded_fix_execution_packet"
        execution_id = $executionId
        repository = $script:R13RepositoryName
        branch = $script:R13Branch
        head = $head
        tree = $tree
        source_milestone = $script:R13Milestone
        source_task = $script:R13SourceTask
        source_issue_report_ref = [string]$queue.source_issue_report_ref
        source_fix_queue_ref = $sourceFixQueueRef
        selected_fix_item_ids = @($selectedFixItemIds)
        selected_source_issue_ids = @($selectedSourceIssueIds)
        execution_mode = $Mode
        execution_status = $executionStatus
        authorization = [pscustomobject][ordered]@{
            authorized_by = "repository_maintainer"
            authority_kind = "repo_bounded_authorization_model"
            authorization_scope = "selected_fix_items_only"
            allow_broad_scope = [bool]$AllowBroadScope
            broad_scope_justification = $broadScopeJustification
            executor_self_certification_disallowed = $true
            qa_authority_kind = "future_independent_validation_required"
        }
        planned_changes = @($plannedChanges)
        actual_changes = @($actualChanges)
        allowed_commands = @($allowedCommands)
        commands_run = @()
        validation_commands = @($validationCommandsForPacket)
        validation_results = @()
        rollback_plan = @($rollbackPlan)
        expected_evidence_refs = @($queue.expected_evidence_refs)
        produced_evidence_refs = @(
            [pscustomobject][ordered]@{
                ref_id = "r13-005-bounded-fix-execution-packet"
                ref = $PacketRef.Replace("\", "/")
                evidence_kind = "bounded_fix_execution_packet"
                authority_kind = "repo_tooling"
                scope = "repo"
            }
        )
        execution_summary = [pscustomobject][ordered]@{
            selected_fix_item_count = @($selectedFixItemIds).Count
            selected_source_issue_count = @($selectedSourceIssueIds).Count
            target_file_count = @($targetFiles).Count
            mode = $Mode
            no_actual_file_mutation = $true
            no_fix_execution = $true
            no_rerun = $true
            no_before_after_comparison = $true
            no_external_replay = $true
            no_signoff = $true
            no_hard_r13_value_gate = $true
            r13_active_through = "R13-005 only"
            r13_006_through_r13_018 = "planned only"
        }
        aggregate_verdict = $aggregateVerdict
        evidence_refs = @(
            [pscustomobject][ordered]@{
                ref_id = "source-r13-004-fix-queue"
                ref = $sourceFixQueueRef
                evidence_kind = "source_fix_queue"
                authority_kind = "repo_fix_queue"
                scope = "repo"
            },
            [pscustomobject][ordered]@{
                ref_id = "r13-bounded-fix-execution-contract"
                ref = "contracts/actionable_qa/r13_bounded_fix_execution.contract.json"
                evidence_kind = "contract"
                authority_kind = "repo_contract"
                scope = "repo"
            },
            [pscustomobject][ordered]@{
                ref_id = "r13-bounded-fix-execution-module"
                ref = "tools/R13BoundedFixExecution.psm1"
                evidence_kind = "packet_module"
                authority_kind = "repo_tooling"
                scope = "repo"
            },
            [pscustomobject][ordered]@{
                ref_id = "r13-bounded-fix-execution-validator"
                ref = "tools/validate_r13_bounded_fix_execution.ps1"
                evidence_kind = "validator"
                authority_kind = "repo_tooling"
                scope = "repo"
            }
        )
        refusal_reasons = @()
        created_at_utc = Get-UtcTimestamp
        non_claims = @($script:RequiredNonClaims)
    }
}

function Assert-PacketMatchesSourceQueue {
    param(
        [Parameter(Mandatory = $true)]
        $Packet,
        [Parameter(Mandatory = $true)]
        $Queue,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $selectedFixItemIds = Assert-StringArray -Value $Packet.selected_fix_item_ids -Context "$Context selected_fix_item_ids"
    Assert-SelectedFixItemIds -SelectedFixItemIds $selectedFixItemIds -Queue $Queue -Context $Context
    $selectedItems = @(Get-SelectedFixItems -Queue $Queue -FixItemId $selectedFixItemIds -Context $Context)
    $selectedSourceIssueIds = Assert-StringArray -Value $Packet.selected_source_issue_ids -Context "$Context selected_source_issue_ids"
    Assert-SelectedSourceIssueIds -SelectedSourceIssueIds $selectedSourceIssueIds -SelectedFixItems $selectedItems -Context $Context

    $queueAllowedCommands = @(Get-UniqueStrings -Values @(@($Queue.commands_required) + @($selectedItems | ForEach-Object { @($_.allowed_commands) }) + @($Queue.validation_commands)))
    $packetAllowedCommands = Assert-StringArray -Value $Packet.allowed_commands -Context "$Context allowed_commands"
    foreach ($command in $packetAllowedCommands) {
        if ($queueAllowedCommands -notcontains $command) {
            throw "$Context allowed command '$command' is not authorized by the selected source fix queue items."
        }
    }

    $queueValidationCommands = @(Get-UniqueStrings -Values @(@($Queue.validation_commands) + @($selectedItems | ForEach-Object { @($_.validation_commands) })))
    $packetValidationCommands = Assert-StringArray -Value $Packet.validation_commands -Context "$Context validation_commands"
    foreach ($command in $packetValidationCommands) {
        if ($queueValidationCommands -notcontains $command) {
            throw "$Context validation command '$command' is not authorized by the selected source fix queue items."
        }
    }
    if (@($packetValidationCommands).Count -eq 0) {
        throw "$Context missing validation commands."
    }

    $authorization = Assert-ObjectValue -Value $Packet.authorization -Context "$Context authorization"
    $allowBroadScope = Assert-BooleanValue -Value $authorization.allow_broad_scope -Context "$Context authorization.allow_broad_scope"
    $broadScopeJustification = Assert-StringValue -Value $authorization.broad_scope_justification -Context "$Context authorization.broad_scope_justification"

    $plannedChanges = Assert-ObjectArray -Value $Packet.planned_changes -Context "$Context planned_changes"
    foreach ($change in $plannedChanges) {
        Assert-RequiredObjectFields -Object $change -FieldNames @("fix_item_id", "source_issue_ids", "target_files", "bounded_scope", "proposed_change_summary", "allowed_commands", "validation_commands", "rollback_plan", "expected_evidence_refs") -Context "$Context planned_change"
        $fixItemId = [string]$change.fix_item_id
        $sourceItem = @($selectedItems | Where-Object { [string]$_.fix_item_id -eq $fixItemId })
        if ($sourceItem.Count -ne 1) {
            throw "$Context planned_change fix_item_id '$fixItemId' must be one of the selected fix items."
        }
        foreach ($targetFile in (Assert-StringArray -Value $change.target_files -Context "$Context planned_change.target_files")) {
            Assert-TargetFilePath -PathValue $targetFile -AllowBroadScope $allowBroadScope -BroadScopeJustification $broadScopeJustification -Context "$Context planned_change"
            if (@($sourceItem[0].target_files) -notcontains $targetFile) {
                throw "$Context planned_change target file '$targetFile' must be preserved from the source fix item."
            }
        }
    }

    $rollbackPlan = Assert-ObjectArray -Value $Packet.rollback_plan -Context "$Context rollback_plan"
    foreach ($entry in $rollbackPlan) {
        Assert-RequiredObjectFields -Object $entry -FieldNames @("fix_item_id", "source_issue_ids", "target_files", "rollback_note") -Context "$Context rollback_plan"
        Assert-NonEmptyString -Value $entry.rollback_note -Context "$Context rollback_plan.rollback_note" | Out-Null
        $fixItemId = [string]$entry.fix_item_id
        $sourceItem = @($selectedItems | Where-Object { [string]$_.fix_item_id -eq $fixItemId })
        if ($sourceItem.Count -ne 1) {
            throw "$Context rollback_plan fix_item_id '$fixItemId' must be one of the selected fix items."
        }
        if ([string]$entry.rollback_note -ne [string]$sourceItem[0].rollback_note) {
            throw "$Context rollback_plan must preserve rollback_note from selected fix item '$fixItemId'."
        }
    }
}

function Assert-ModeSemantics {
    param(
        [Parameter(Mandatory = $true)]
        $Packet,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $mode = [string]$Packet.execution_mode
    $status = [string]$Packet.execution_status
    $aggregateVerdict = [string]$Packet.aggregate_verdict
    $actualChanges = Assert-ObjectArray -Value $Packet.actual_changes -Context "$Context actual_changes" -AllowEmpty
    $commandsRun = Assert-StringArray -Value $Packet.commands_run -Context "$Context commands_run" -AllowEmpty
    $validationResults = Assert-ObjectArray -Value $Packet.validation_results -Context "$Context validation_results" -AllowEmpty
    $producedEvidenceRefs = Assert-ObjectArray -Value $Packet.produced_evidence_refs -Context "$Context produced_evidence_refs" -AllowEmpty

    if (($mode -eq "authorization_only" -or $mode -eq "dry_run") -and @($commandsRun).Count -gt 0) {
        foreach ($command in $commandsRun) {
            if (@($Packet.allowed_commands) -notcontains $command) {
                throw "$Context commands_run includes command '$command' that is not listed in allowed_commands."
            }
            if ($command -notmatch '(?i)^\s*(Get-Content|git\s+(status|rev-parse|branch|diff\s+--check)|powershell\b.*(Read-SingleJsonObject|validate_|test_))') {
                throw "$Context authorization-only/dry-run commands_run must contain only non-mutating inspection commands."
            }
        }
    }

    if ($mode -eq "authorization_only") {
        if ($status -ne "authorized") {
            throw "$Context authorization_only execution_status must be 'authorized'."
        }
        if ($aggregateVerdict -ne "authorized_for_future_execution") {
            throw "$Context authorization_only aggregate_verdict must be 'authorized_for_future_execution'."
        }
        if (@($actualChanges).Count -ne 0) {
            throw "$Context authorization_only actual_changes must be empty."
        }
    }
    elseif ($mode -eq "dry_run") {
        if ($status -ne "dry_run_complete") {
            throw "$Context dry_run execution_status must be 'dry_run_complete'."
        }
        if ($aggregateVerdict -ne "dry_run_complete" -and $aggregateVerdict -ne "blocked") {
            throw "$Context dry_run aggregate_verdict must be 'dry_run_complete' or 'blocked'."
        }
        if (@($actualChanges).Count -eq 0) {
            throw "$Context dry_run actual_changes must state dry-run/no-mutation."
        }
        foreach ($change in $actualChanges) {
            Assert-RequiredObjectFields -Object $change -FieldNames @("change_kind", "fix_item_ids", "changed_files", "mutation_performed", "summary") -Context "$Context actual_changes"
            if ([bool]$change.mutation_performed) {
                throw "$Context dry_run cannot record target file mutation."
            }
            if (@($change.changed_files).Count -ne 0) {
                throw "$Context dry_run changed_files must be empty."
            }
            $summary = [string]$change.summary
            if ($summary -notmatch '(?i)dry[- ]?run' -or $summary -notmatch '(?i)no[- ]?mutation|no target files were changed|no file mutation') {
                throw "$Context dry_run actual_changes must explicitly state dry-run/no-mutation."
            }
        }
    }
    elseif ($mode -eq "executed") {
        if ([string]$Packet.source_task -eq $script:R13SourceTask) {
            throw "$Context R13-005 evidence cannot use executed mode."
        }
        if ($aggregateVerdict -eq "validation_passed" -and $status -ne "validation_passed") {
            throw "$Context validation_passed aggregate_verdict requires validation_passed execution_status."
        }
        if (@($actualChanges).Count -eq 0 -or @($actualChanges | Where-Object { @($_.changed_files).Count -gt 0 }).Count -eq 0) {
            throw "$Context claimed fix execution requires changed-file evidence."
        }
        if (@($producedEvidenceRefs).Count -eq 0) {
            throw "$Context claimed fix execution requires produced evidence refs."
        }
        if (@($validationResults).Count -eq 0) {
            throw "$Context claimed fix execution requires validation results."
        }
    }

    if ($mode -ne "executed" -and ($aggregateVerdict -in @("execution_recorded", "validation_failed", "validation_passed") -or $status -in @("executed_pending_validation", "validation_passed", "validation_failed"))) {
        throw "$Context claims fix execution or validation without executed mode."
    }
}

function Test-R13BoundedFixExecutionPacketObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Packet,
        [string]$SourceLabel = "R13 bounded fix execution packet"
    )

    $contract = Get-R13BoundedFixExecutionContract
    Assert-RequiredObjectFields -Object $Packet -FieldNames $contract.required_fields -Context $SourceLabel

    if ($Packet.contract_version -ne $contract.contract_version) {
        throw "$SourceLabel contract_version must be '$($contract.contract_version)'."
    }
    if ($Packet.artifact_type -ne "r13_bounded_fix_execution_packet") {
        throw "$SourceLabel artifact_type must be 'r13_bounded_fix_execution_packet'."
    }
    Assert-NonEmptyString -Value $Packet.execution_id -Context "$SourceLabel execution_id" | Out-Null
    if ($Packet.repository -ne $script:R13RepositoryName) {
        throw "$SourceLabel repository must be '$script:R13RepositoryName'."
    }
    if ($Packet.branch -ne $script:R13Branch) {
        throw "$SourceLabel branch must be '$script:R13Branch'."
    }
    Assert-GitObjectIdWhenPopulated -Value $Packet.head -Context "$SourceLabel head"
    Assert-GitObjectIdWhenPopulated -Value $Packet.tree -Context "$SourceLabel tree"
    if ($Packet.source_milestone -ne $script:R13Milestone) {
        throw "$SourceLabel source_milestone must be '$script:R13Milestone'."
    }
    if ($Packet.source_task -ne $script:R13SourceTask) {
        throw "$SourceLabel source_task must be '$script:R13SourceTask'."
    }

    $sourceIssueReportRef = Assert-NonEmptyString -Value $Packet.source_issue_report_ref -Context "$SourceLabel source_issue_report_ref"
    if (-not (Test-RepositoryRelativePath -PathValue $sourceIssueReportRef)) {
        throw "$SourceLabel source_issue_report_ref must be repository-relative and inside the repository."
    }
    if (-not (Test-Path -LiteralPath (Resolve-RepositoryPath -PathValue $sourceIssueReportRef))) {
        throw "$SourceLabel source_issue_report_ref '$sourceIssueReportRef' does not exist."
    }

    $sourceFixQueueRef = Assert-NonEmptyString -Value $Packet.source_fix_queue_ref -Context "$SourceLabel source_fix_queue_ref"
    if (-not (Test-RepositoryRelativePath -PathValue $sourceFixQueueRef)) {
        throw "$SourceLabel source_fix_queue_ref must be repository-relative and inside the repository."
    }
    if (-not (Test-Path -LiteralPath (Resolve-RepositoryPath -PathValue $sourceFixQueueRef))) {
        throw "$SourceLabel source_fix_queue_ref '$sourceFixQueueRef' does not exist."
    }
    $queue = Get-ValidatedSourceFixQueue -FixQueuePath $sourceFixQueueRef -Context $SourceLabel

    $mode = Assert-NonEmptyString -Value $Packet.execution_mode -Context "$SourceLabel execution_mode"
    Assert-AllowedValue -Value $mode -AllowedValues $script:AllowedExecutionModes -Context "$SourceLabel execution_mode"
    $status = Assert-NonEmptyString -Value $Packet.execution_status -Context "$SourceLabel execution_status"
    Assert-AllowedValue -Value $status -AllowedValues $script:AllowedExecutionStatuses -Context "$SourceLabel execution_status"
    $aggregateVerdict = Assert-NonEmptyString -Value $Packet.aggregate_verdict -Context "$SourceLabel aggregate_verdict"
    Assert-AllowedValue -Value $aggregateVerdict -AllowedValues $script:AllowedAggregateVerdicts -Context "$SourceLabel aggregate_verdict"

    $authorization = Assert-ObjectValue -Value $Packet.authorization -Context "$SourceLabel authorization"
    Assert-RequiredObjectFields -Object $authorization -FieldNames $contract.authorization_required_fields -Context "$SourceLabel authorization"
    Assert-NoForbiddenAuthority -AuthorityKind ([string]$authorization.authority_kind) -Context "$SourceLabel authorization.authority_kind"
    Assert-NoForbiddenAuthority -AuthorityKind ([string]$authorization.qa_authority_kind) -Context "$SourceLabel authorization.qa_authority_kind"
    if (-not [bool]$authorization.executor_self_certification_disallowed) {
        throw "$SourceLabel authorization must disallow executor self-certification."
    }
    if ([bool]$authorization.allow_broad_scope -and [string]::IsNullOrWhiteSpace([string]$authorization.broad_scope_justification)) {
        throw "$SourceLabel broad scope authorization requires broad_scope_justification."
    }

    Assert-PacketMatchesSourceQueue -Packet $Packet -Queue $queue -Context $SourceLabel

    $expectedEvidenceRefs = Assert-ObjectArray -Value $Packet.expected_evidence_refs -Context "$SourceLabel expected_evidence_refs"
    foreach ($evidence in $expectedEvidenceRefs) {
        Assert-ExistingOrExpectedEvidenceRef -Evidence $evidence -RequiredFields $contract.expected_evidence_ref_required_fields -Context "$SourceLabel expected_evidence_refs"
    }

    $producedEvidenceRefs = Assert-ObjectArray -Value $Packet.produced_evidence_refs -Context "$SourceLabel produced_evidence_refs" -AllowEmpty
    foreach ($evidence in $producedEvidenceRefs) {
        Assert-ExistingOrExpectedEvidenceRef -Evidence $evidence -RequiredFields $contract.produced_evidence_ref_required_fields -Context "$SourceLabel produced_evidence_refs"
    }
    Assert-NoLocalOnlyExternalProof -EvidenceRefs $producedEvidenceRefs -Context "$SourceLabel produced_evidence_refs"

    $evidenceRefs = Assert-ObjectArray -Value $Packet.evidence_refs -Context "$SourceLabel evidence_refs"
    foreach ($evidence in $evidenceRefs) {
        Assert-ExistingOrExpectedEvidenceRef -Evidence $evidence -RequiredFields $contract.evidence_ref_required_fields -Context "$SourceLabel evidence_refs"
    }
    Assert-NoLocalOnlyExternalProof -EvidenceRefs $evidenceRefs -Context "$SourceLabel evidence_refs"

    $refusalReasons = Assert-StringArray -Value $Packet.refusal_reasons -Context "$SourceLabel refusal_reasons" -AllowEmpty
    if ($aggregateVerdict -eq "blocked" -and @($refusalReasons).Count -eq 0) {
        throw "$SourceLabel blocked aggregate_verdict requires refusal_reasons."
    }

    Assert-TimestampString -Value $Packet.created_at_utc -Context "$SourceLabel created_at_utc" | Out-Null
    $nonClaims = Assert-StringArray -Value $Packet.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel
    Assert-NoForbiddenR13Claims -Packet $Packet -Context $SourceLabel
    Assert-NoSuccessorOpeningClaim -Value $Packet -Context $SourceLabel
    Assert-ModeSemantics -Packet $Packet -Context $SourceLabel

    $selectedFixItemIds = @($Packet.selected_fix_item_ids)
    $selectedSourceIssueIds = @($Packet.selected_source_issue_ids)
    $targetFiles = @(Get-UniqueStrings -Values @($Packet.planned_changes | ForEach-Object { @($_.target_files) }))

    $PSCmdlet.WriteObject([pscustomobject][ordered]@{
        ExecutionId = [string]$Packet.execution_id
        ExecutionMode = $mode
        ExecutionStatus = $status
        AggregateVerdict = $aggregateVerdict
        SelectedFixItemCount = @($selectedFixItemIds).Count
        SelectedSourceIssueCount = @($selectedSourceIssueIds).Count
        TargetFileCount = @($targetFiles).Count
    }, $false)
}

function Test-R13BoundedFixExecutionPacket {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PacketPath
    )

    $packet = Get-JsonDocument -Path $PacketPath -Label "R13 bounded fix execution packet"
    return Test-R13BoundedFixExecutionPacketObject -Packet $packet -SourceLabel "R13 bounded fix execution packet"
}

Export-ModuleMember -Function Get-R13BoundedFixExecutionContract, New-R13BoundedFixExecutionPacket, Test-R13BoundedFixExecutionPacketObject, Test-R13BoundedFixExecutionPacket
