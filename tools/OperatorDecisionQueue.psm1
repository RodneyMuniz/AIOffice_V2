Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force
$statusModule = Import-Module (Join-Path $PSScriptRoot "ControlRoomStatus.psm1") -Force -PassThru
$script:TestControlRoomStatus = $statusModule.ExportedCommands["Test-ControlRoomStatus"]

$script:R12RepositoryName = "AIOffice_V2"
$script:R12Branch = "release/r12-external-api-runner-actionable-qa-control-room-pilot"
$script:GitObjectPattern = "^[a-f0-9]{40}$"
$script:TimestampPattern = "^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$"
$script:AllowedBlockingStatuses = @("blocking", "non_blocking", "advisory")
$script:RequiredQueueNonClaims = @(
    "no automatic operator replacement",
    "no R13 authorization",
    "no final acceptance",
    "no R12 closeout",
    "no productized workflow UI",
    "R12-018 not done"
)

function Get-RepositoryRoot {
    return $repoRoot
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

    if ($PathValue -match '^https?://') {
        return $PathValue
    }

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

function Write-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Document,
        [switch]$Overwrite
    )

    if ((Test-Path -LiteralPath $Path -PathType Leaf) -and -not $Overwrite) {
        throw "Operator decision queue output '$Path' already exists. Use -Overwrite to replace it explicitly."
    }

    $parentPath = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($parentPath)) {
        New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    }

    $json = ($Document | ConvertTo-Json -Depth 100)
    $content = ($json -replace "`r`n", "`n") + "`n"
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $content, $utf8NoBom)
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
    if (-not (Test-Path -LiteralPath (Resolve-RepositoryPath -PathValue $Ref))) {
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

    foreach ($requiredNonClaim in $script:RequiredQueueNonClaims) {
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

    return ($Line -match '(?i)\b(no|not|without|cannot|must not|does not|do not|is not|are not|unauthorized|blocked|refused|not authorized)\b')
}

function Assert-NoImplicitSuccessorAuthorization {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Lines,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($line in $Lines) {
        if ($line -match '(?i)\b(open|authorize|start|approve|approved|authorized)\b.{0,80}\b(R13|successor milestone)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context successor milestone authorization cannot be implicit: $line"
        }
    }
}

function Get-OperatorDecisionQueueContract {
    return Get-JsonDocument -Path (Resolve-RepositoryPath -PathValue "contracts/control_room/operator_decision_queue.contract.json") -Label "Operator decision queue contract"
}

function Test-OperatorDecisionQueueObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Queue,
        [string]$SourceLabel = "Operator decision queue"
    )

    $contract = Get-OperatorDecisionQueueContract
    Assert-RequiredObjectFields -Object $Queue -FieldNames $contract.required_fields -Context $SourceLabel

    if ($Queue.contract_version -ne $contract.contract_version) {
        throw "$SourceLabel contract_version must be '$($contract.contract_version)'."
    }
    if ($Queue.artifact_type -ne "operator_decision_queue") {
        throw "$SourceLabel artifact_type must be 'operator_decision_queue'."
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
    Assert-NonEmptyString -Value $Queue.active_milestone -Context "$SourceLabel active_milestone" | Out-Null
    $sourceStatusRef = Assert-NonEmptyString -Value $Queue.source_control_room_status_ref -Context "$SourceLabel source_control_room_status_ref"
    Assert-ExistingEvidenceRef -Ref $sourceStatusRef -Context "$SourceLabel source_control_room_status_ref"
    & $script:TestControlRoomStatus -StatusPath $sourceStatusRef | Out-Null
    $sourceStatus = Get-JsonDocument -Path (Resolve-RepositoryPath -PathValue $sourceStatusRef) -Label "Source control-room status"
    Assert-TimestampString -Value $Queue.generated_at_utc -Context "$SourceLabel generated_at_utc" | Out-Null

    if ($Queue.repository -ne $sourceStatus.repository -or $Queue.branch -ne $sourceStatus.branch -or $Queue.head -ne $sourceStatus.head -or $Queue.tree -ne $sourceStatus.tree) {
        throw "$SourceLabel must preserve branch/head/tree from source control-room status."
    }

    $decisions = Assert-ObjectArray -Value $Queue.decisions -Context "$SourceLabel decisions" -AllowEmpty
    $decisionCount = Assert-IntegerValue -Value $Queue.decision_count -Context "$SourceLabel decision_count" -Minimum 0
    $blockingDecisionCount = Assert-IntegerValue -Value $Queue.blocking_decision_count -Context "$SourceLabel blocking_decision_count" -Minimum 0
    if ($decisionCount -ne $decisions.Count) {
        throw "$SourceLabel decision_count must match decisions."
    }
    $actualBlockingCount = @($decisions | Where-Object { $_.blocking_status -eq "blocking" }).Count
    if ($blockingDecisionCount -ne $actualBlockingCount) {
        throw "$SourceLabel hidden blocking decisions fail validation; blocking_decision_count must match decisions."
    }

    $successorLines = New-Object System.Collections.Generic.List[string]
    Assert-StringArray -Value $Queue.recommended_sequence -Context "$SourceLabel recommended_sequence" | Out-Null
    foreach ($sequenceItem in @($Queue.recommended_sequence)) {
        $successorLines.Add([string]$sequenceItem) | Out-Null
    }
    Assert-NoImplicitSuccessorAuthorization -Lines @($Queue.recommended_sequence | ForEach-Object { [string]$_ }) -Context $SourceLabel

    $decisionIds = @{}
    foreach ($decision in $decisions) {
        Assert-RequiredObjectFields -Object $decision -FieldNames $contract.decision_required_fields -Context "$SourceLabel decision"
        $decisionId = Assert-NonEmptyString -Value $decision.decision_id -Context "$SourceLabel decision.decision_id"
        $decisionIds[$decisionId] = $true
        $decisionType = Assert-NonEmptyString -Value $decision.decision_type -Context "$SourceLabel decision.decision_type"
        Assert-AllowedValue -Value $decisionType -AllowedValues $contract.allowed_decision_types -Context "$SourceLabel decision.decision_type"
        Assert-NonEmptyString -Value $decision.title -Context "$SourceLabel decision.title" | Out-Null
        Assert-NonEmptyString -Value $decision.context -Context "$SourceLabel decision.context" | Out-Null
        Assert-StringArray -Value $decision.options -Context "$SourceLabel decision.options" | Out-Null
        Assert-NonEmptyString -Value $decision.recommended_option -Context "$SourceLabel decision.recommended_option" | Out-Null
        Assert-NonEmptyString -Value $decision.consequence -Context "$SourceLabel decision.consequence" | Out-Null
        Assert-NonEmptyString -Value $decision.required_before -Context "$SourceLabel decision.required_before" | Out-Null
        Assert-AllowedValue -Value ([string]$decision.blocking_status) -AllowedValues $script:AllowedBlockingStatuses -Context "$SourceLabel decision.blocking_status"
        $decisionEvidenceRefs = Assert-StringArray -Value $decision.evidence_refs -Context "$SourceLabel decision.evidence_refs"
        foreach ($evidenceRef in $decisionEvidenceRefs) {
            Assert-ExistingEvidenceRef -Ref $evidenceRef -Context "$SourceLabel decision.evidence_refs"
        }
        Assert-NonEmptyString -Value $decision.owner_role -Context "$SourceLabel decision.owner_role" | Out-Null

        foreach ($line in @($decision.title, $decision.context, $decision.recommended_option, $decision.consequence) + @($decision.options)) {
            $successorLines.Add([string]$line) | Out-Null
        }

        if ($decisionType -eq "final_acceptance") {
            if ($sourceStatus.active_scope.current_completed_through -ne "R12-021" -or $sourceStatus.qa_evidence_gate_status.status -ne "passed" -or @($sourceStatus.blockers).Count -gt 0) {
                throw "$SourceLabel final acceptance decision cannot appear before R12 closeout prerequisites exist."
            }
        }
    }

    foreach ($sourceDecision in @($sourceStatus.operator_decisions_required)) {
        if ($sourceDecision.blocking_status -eq "blocking" -and -not $decisionIds.ContainsKey([string]$sourceDecision.id)) {
            throw "$SourceLabel hidden blocking decisions fail validation; missing source decision '$($sourceDecision.id)'."
        }
    }

    Assert-NoImplicitSuccessorAuthorization -Lines @($successorLines | ForEach-Object { [string]$_ }) -Context $SourceLabel

    $evidenceRefs = Assert-StringArray -Value $Queue.evidence_refs -Context "$SourceLabel evidence_refs"
    foreach ($evidenceRef in $evidenceRefs) {
        Assert-ExistingEvidenceRef -Ref $evidenceRef -Context "$SourceLabel evidence_refs"
    }
    $nonClaims = Assert-StringArray -Value $Queue.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel

    return [pscustomobject][ordered]@{
        QueueId = $Queue.queue_id
        Repository = $Queue.repository
        Branch = $Queue.branch
        Head = $Queue.head
        Tree = $Queue.tree
        DecisionCount = $decisionCount
        BlockingDecisionCount = $blockingDecisionCount
        SourceControlRoomStatusRef = $sourceStatusRef
    }
}

function Test-OperatorDecisionQueue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$QueuePath
    )

    $queue = Get-JsonDocument -Path $QueuePath -Label "Operator decision queue"
    return Test-OperatorDecisionQueueObject -Queue $queue -SourceLabel "Operator decision queue"
}

function Export-OperatorDecisionQueueMarkdown {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Queue,
        [Parameter(Mandatory = $true)]
        [string]$MarkdownOutputPath,
        [switch]$Overwrite
    )

    $resolvedOutputPath = Resolve-RepositoryPath -PathValue $MarkdownOutputPath
    if ((Test-Path -LiteralPath $resolvedOutputPath -PathType Leaf) -and -not $Overwrite) {
        throw "Operator decision queue Markdown output '$MarkdownOutputPath' already exists. Use -Overwrite to replace it explicitly."
    }

    $parentPath = Split-Path -Parent $resolvedOutputPath
    if (-not [string]::IsNullOrWhiteSpace($parentPath)) {
        New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    }

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# R12 Operator Decision Queue") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add(("- Generated at UTC: ``{0}``" -f $Queue.generated_at_utc)) | Out-Null
    $lines.Add(("- Source status: ``{0}``" -f $Queue.source_control_room_status_ref)) | Out-Null
    $lines.Add(("- Branch: ``{0}``" -f $Queue.branch)) | Out-Null
    $lines.Add(("- Head: ``{0}``" -f $Queue.head)) | Out-Null
    $lines.Add(("- Tree: ``{0}``" -f $Queue.tree)) | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## Queue Summary") | Out-Null
    $lines.Add(("- Decision count: {0}" -f $Queue.decision_count)) | Out-Null
    $lines.Add(("- Blocking decision count: {0}" -f $Queue.blocking_decision_count)) | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## Recommended Sequence") | Out-Null
    foreach ($sequenceItem in @($Queue.recommended_sequence)) {
        $lines.Add("- $sequenceItem") | Out-Null
    }
    $lines.Add("") | Out-Null
    $lines.Add("## Decisions") | Out-Null
    foreach ($decision in @($Queue.decisions)) {
        $lines.Add(("### ``{0}``" -f $decision.decision_id)) | Out-Null
        $lines.Add(("- Type: ``{0}``" -f $decision.decision_type)) | Out-Null
        $lines.Add(("- Blocking status: ``{0}``" -f $decision.blocking_status)) | Out-Null
        $lines.Add(("- Title: {0}" -f $decision.title)) | Out-Null
        $lines.Add(("- Context: {0}" -f $decision.context)) | Out-Null
        $lines.Add(("- Options: ``{0}``" -f (@($decision.options) -join '`, `'))) | Out-Null
        $lines.Add(("- Recommended option: {0}" -f $decision.recommended_option)) | Out-Null
        $lines.Add(("- Consequence: {0}" -f $decision.consequence)) | Out-Null
        $lines.Add(("- Required before: ``{0}``" -f $decision.required_before)) | Out-Null
        $lines.Add(("- Owner role: ``{0}``" -f $decision.owner_role)) | Out-Null
        $lines.Add(("- Evidence refs: ``{0}``" -f (@($decision.evidence_refs) -join '`, `'))) | Out-Null
        $lines.Add("") | Out-Null
    }
    $lines.Add("## Evidence Refs") | Out-Null
    foreach ($evidenceRef in @($Queue.evidence_refs)) {
        $lines.Add(("- ``{0}``" -f $evidenceRef)) | Out-Null
    }
    $lines.Add("") | Out-Null
    $lines.Add("## Non-Claims") | Out-Null
    foreach ($nonClaim in @($Queue.non_claims)) {
        $lines.Add("- $nonClaim") | Out-Null
    }

    $content = ($lines -join "`n") + "`n"
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($resolvedOutputPath, $content, $utf8NoBom)
    return $resolvedOutputPath
}

function Test-OperatorDecisionQueueMarkdown {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$QueuePath,
        [Parameter(Mandatory = $true)]
        [string]$MarkdownPath
    )

    $queue = Get-JsonDocument -Path (Resolve-RepositoryPath -PathValue $QueuePath) -Label "Operator decision queue"
    Test-OperatorDecisionQueueObject -Queue $queue -SourceLabel "Operator decision queue" | Out-Null
    $text = Get-Content -LiteralPath (Resolve-RepositoryPath -PathValue $MarkdownPath) -Raw
    foreach ($expected in @(
            "# R12 Operator Decision Queue",
            ("Decision count: {0}" -f $queue.decision_count),
            ("Blocking decision count: {0}" -f $queue.blocking_decision_count),
            "## Recommended Sequence",
            "## Decisions",
            "## Evidence Refs",
            "## Non-Claims"
        )) {
        if ($text -notmatch [regex]::Escape($expected)) {
            throw "Operator decision queue Markdown must include '$expected'."
        }
    }
    foreach ($decision in @($queue.decisions)) {
        if ($text -notmatch [regex]::Escape([string]$decision.decision_id)) {
            throw "Operator decision queue Markdown must include decision '$($decision.decision_id)'."
        }
    }
    foreach ($nonClaim in @($queue.non_claims)) {
        if ($text -notmatch [regex]::Escape([string]$nonClaim)) {
            throw "Operator decision queue Markdown must include non-claim '$nonClaim'."
        }
    }

    return [pscustomobject][ordered]@{
        MarkdownPath = (Resolve-RepositoryPath -PathValue $MarkdownPath)
        QueuePath = $QueuePath
        DecisionCount = $queue.decision_count
        BlockingDecisionCount = $queue.blocking_decision_count
    }
}

function New-OperatorDecisionQueue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ControlRoomStatusPath,
        [string]$OutputPath = "",
        [string]$MarkdownOutputPath = "",
        [switch]$Overwrite
    )

    & $script:TestControlRoomStatus -StatusPath $ControlRoomStatusPath | Out-Null
    $sourceStatus = Get-JsonDocument -Path (Resolve-RepositoryPath -PathValue $ControlRoomStatusPath) -Label "Control-room status"
    $sourceStatusRef = Convert-ToRepositoryRelativePath -PathValue $ControlRoomStatusPath
    $nextSliceDecision = if ($sourceStatus.active_scope.current_completed_through -eq "R12-017") {
        [pscustomobject][ordered]@{
            decision_id = "decision-r12-018-fresh-thread"
            decision_type = "next_slice_authorization"
            title = "Execute R12-018 only from a separate fresh Codex thread"
            context = "R12-017 prepared a bootstrap packet and next prompt, but R12-018 is not done in this thread."
            options = @("Use the generated R12-018 prompt in a new Codex thread", "Keep R12-018 pending")
            recommended_option = "Use the generated R12-018 prompt in a new Codex thread"
            consequence = "R12-018 remains pending until a separate fresh thread verifies repo truth from the committed packet."
            required_before = "starting_R12_018"
            blocking_status = "blocking"
            evidence_refs = @($sourceStatusRef, "contracts/bootstrap/fresh_thread_bootstrap_packet.contract.json", "tools/FreshThreadBootstrap.psm1")
            owner_role = "operator"
        }
    }
    else {
        [pscustomobject][ordered]@{
            decision_id = "decision-r12-017-018-authorization"
            decision_type = "next_slice_authorization"
            title = "Explicit authorization is required for R12-017 through R12-018 only"
            context = "R12-017 and R12-018 remain planned until the operator authorizes one real useful build/change cycle and fresh-thread restart proof."
            options = @("Authorize R12-017 through R12-018 only in the next prompt", "Keep R12-017 through R12-018 planned")
            recommended_option = "Authorize R12-017 through R12-018 only in the next prompt"
            consequence = "No real build/change cycle starts unless the next prompt explicitly targets R12-017 through R12-018."
            required_before = "starting_R12_017"
            blocking_status = "blocking"
            evidence_refs = @($sourceStatusRef, "governance/R12_EXTERNAL_API_RUNNER_ACTIONABLE_QA_AND_CONTROL_ROOM_WORKFLOW_PILOT.md")
            owner_role = "operator"
        }
    }

    $decisions = @(
        [pscustomobject][ordered]@{
            decision_id = "decision-external-evidence-required"
            decision_type = "external_evidence_required"
            title = "Real external evidence is required before final QA/evidence gate pass"
            context = "The control-room status records no live R12 external runner result and no external artifact evidence for the current branch/head/tree."
            options = @("Defer final QA/evidence pass until real external evidence exists", "Authorize a later bounded external evidence capture slice")
            recommended_option = "Defer final QA/evidence pass until real external evidence exists"
            consequence = "Final QA/evidence gate and R12 closeout remain blocked until real external runner result and artifact evidence are committed."
            required_before = "final_qa_evidence_gate_pass"
            blocking_status = "blocking"
            evidence_refs = @($sourceStatusRef, "contracts/actionable_qa/cycle_qa_evidence_gate.contract.json")
            owner_role = "operator"
        },
        [pscustomobject][ordered]@{
            decision_id = "decision-control-room-review"
            decision_type = "approval_required"
            title = "Review generated control-room refresh artifacts"
            context = "The status model, Markdown view, decision queue, and refresh result are generated for operator review as a bounded static workflow."
            options = @("Accept the bounded control-room refresh evidence", "Request corrections to generated refresh wording")
            recommended_option = "Accept the bounded control-room refresh evidence"
            consequence = "Acceptance records operator-readable refresh evidence only; it does not create productized control-room behavior."
            required_before = "next_slice_authorization"
            blocking_status = "non_blocking"
            evidence_refs = @($sourceStatusRef, "contracts/control_room/control_room_status.contract.json", "contracts/control_room/control_room_view.contract.json", "contracts/control_room/control_room_refresh_result.contract.json")
            owner_role = "operator"
        },
        $nextSliceDecision,
        [pscustomobject][ordered]@{
            decision_id = "decision-no-r13-successor"
            decision_type = "blocked_refusal"
            title = "No R13 or successor milestone is authorized"
            context = "R12 remains active and cannot close until all R12 closeout prerequisites exist."
            options = @("Keep R13 unauthorized", "Require a separate future repo-truth opening prompt before any successor")
            recommended_option = "Keep R13 unauthorized"
            consequence = "Any R13 or successor work remains blocked until explicit future authorization and repo-truth opening evidence exist."
            required_before = "any_successor_milestone_opening"
            blocking_status = "blocking"
            evidence_refs = @($sourceStatusRef, "governance/R12_EXTERNAL_API_RUNNER_ACTIONABLE_QA_AND_CONTROL_ROOM_WORKFLOW_PILOT.md")
            owner_role = "operator"
        }
    )

    $queue = [pscustomobject][ordered]@{
        contract_version = "v1"
        artifact_type = "operator_decision_queue"
        queue_id = "r12-operator-decision-queue-" + [guid]::NewGuid().ToString("N")
        repository = $sourceStatus.repository
        branch = $sourceStatus.branch
        head = $sourceStatus.head
        tree = $sourceStatus.tree
        active_milestone = $sourceStatus.active_milestone
        source_control_room_status_ref = $sourceStatusRef
        generated_at_utc = Get-UtcTimestamp
        decisions = @($decisions)
        decision_count = @($decisions).Count
        blocking_decision_count = @($decisions | Where-Object { $_.blocking_status -eq "blocking" }).Count
        recommended_sequence = @(
            "Review the generated control-room status, Markdown view, decision queue, and refresh result.",
            "Keep final QA/evidence gate blocked until real external runner result and artifact evidence exist.",
            "Use the generated R12-018 prompt only in a separate fresh Codex thread.",
            "Keep R13 or any successor milestone unauthorized."
        )
        evidence_refs = @(
            $sourceStatusRef,
            "contracts/control_room/operator_decision_queue.contract.json",
            "tools/OperatorDecisionQueue.psm1",
            "tools/export_operator_decision_queue.ps1",
            "contracts/control_room/control_room_refresh_result.contract.json"
        )
        non_claims = @($script:RequiredQueueNonClaims)
    }

    Test-OperatorDecisionQueueObject -Queue $queue -SourceLabel "Operator decision queue draft" | Out-Null

    if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
        Write-JsonDocument -Path (Resolve-RepositoryPath -PathValue $OutputPath) -Document $queue -Overwrite:$Overwrite
    }
    if (-not [string]::IsNullOrWhiteSpace($MarkdownOutputPath)) {
        Export-OperatorDecisionQueueMarkdown -Queue $queue -MarkdownOutputPath $MarkdownOutputPath -Overwrite:$Overwrite | Out-Null
    }

    $PSCmdlet.WriteObject($queue, $false)
}

Export-ModuleMember -Function Get-OperatorDecisionQueueContract, Test-OperatorDecisionQueueObject, Test-OperatorDecisionQueue, New-OperatorDecisionQueue, Export-OperatorDecisionQueueMarkdown, Test-OperatorDecisionQueueMarkdown
