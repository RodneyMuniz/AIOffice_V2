Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force
$statusModule = Import-Module (Join-Path $PSScriptRoot "ControlRoomStatus.psm1") -Force -PassThru
$viewModule = Import-Module (Join-Path $PSScriptRoot "render_control_room_view.psm1") -Force -PassThru
$queueModule = Import-Module (Join-Path $PSScriptRoot "OperatorDecisionQueue.psm1") -Force -PassThru

$script:NewControlRoomStatus = $statusModule.ExportedCommands["New-ControlRoomStatus"]
$script:TestControlRoomStatus = $statusModule.ExportedCommands["Test-ControlRoomStatus"]
$script:ExportControlRoomViewMarkdown = $viewModule.ExportedCommands["Export-ControlRoomViewMarkdown"]
$script:TestControlRoomViewMarkdown = $viewModule.ExportedCommands["Test-ControlRoomViewMarkdown"]
$script:NewOperatorDecisionQueue = $queueModule.ExportedCommands["New-OperatorDecisionQueue"]
$script:TestOperatorDecisionQueue = $queueModule.ExportedCommands["Test-OperatorDecisionQueue"]
$script:TestOperatorDecisionQueueMarkdown = $queueModule.ExportedCommands["Test-OperatorDecisionQueueMarkdown"]

$script:R12RepositoryName = "AIOffice_V2"
$script:R12Branch = "release/r12-external-api-runner-actionable-qa-control-room-pilot"
$script:GitObjectPattern = "^[a-f0-9]{40}$"
$script:TimestampPattern = "^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$"
$script:AllowedRefreshVerdicts = @("passed", "warning", "failed", "blocked", "refused")
$script:RequiredRefreshNonClaims = @(
    "no final QA pass for R12 closeout",
    "no R12 final-state replay",
    "no R12 closeout",
    "no R13 opened",
    "no productized control-room behavior",
    "no full UI app",
    "no production runtime",
    "no broad autonomy",
    "no solved Codex reliability",
    "no broad CI/product coverage"
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

    return (Read-SingleJsonObject -Path (Resolve-RepositoryPath -PathValue $Path) -Label $Label)
}

function Write-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Document,
        [switch]$Overwrite
    )

    $resolvedPath = Resolve-RepositoryPath -PathValue $Path
    if ((Test-Path -LiteralPath $resolvedPath -PathType Leaf) -and -not $Overwrite) {
        throw "Control-room refresh result output '$Path' already exists. Use -Overwrite to replace it explicitly."
    }

    $parentPath = Split-Path -Parent $resolvedPath
    if (-not [string]::IsNullOrWhiteSpace($parentPath)) {
        New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    }

    $json = ($Document | ConvertTo-Json -Depth 100)
    $content = ($json -replace "`r`n", "`n") + "`n"
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($resolvedPath, $content, $utf8NoBom)
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

function Assert-AllowedValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string[]]$AllowedValues,
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

    foreach ($fieldName in $FieldNames) {
        Get-RequiredProperty -Object $Object -Name $fieldName -Context $Context | Out-Null
    }
}

function Assert-ExistingRef {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Ref,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-NonEmptyString -Value $Ref -Context $Context | Out-Null
    if ($Ref -match '^https?://') {
        return
    }
    if ([System.IO.Path]::IsPathRooted($Ref) -or $Ref -match '(^|[\\/])\.\.([\\/]|$)') {
        throw "$Context must be a repository-relative path without traversal."
    }
    if (-not (Test-Path -LiteralPath (Resolve-RepositoryPath -PathValue $Ref) -PathType Leaf)) {
        throw "$Context ref '$Ref' does not exist."
    }
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

function Get-GitSingleLine {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $lines = @(Invoke-GitLines -Arguments $Arguments)
    if ($lines.Count -eq 0) {
        throw "$Context returned no output."
    }
    return ([string]$lines[0]).Trim()
}

function New-CommandResult {
    param(
        [Parameter(Mandatory = $true)]
        [string]$CommandName,
        [Parameter(Mandatory = $true)]
        [string]$Status,
        [Parameter(Mandatory = $true)]
        [string]$Details,
        [hashtable]$Extra = @{}
    )

    $result = [ordered]@{
        command_name = $CommandName
        status = $Status
        details = $Details
    }
    foreach ($key in @($Extra.Keys | Sort-Object)) {
        $result[$key] = $Extra[$key]
    }
    return [pscustomobject]$result
}

function New-ValidationResult {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Target,
        [Parameter(Mandatory = $true)]
        [string]$Status,
        [Parameter(Mandatory = $true)]
        [string]$Details
    )

    return [pscustomobject][ordered]@{
        target = $Target
        status = $Status
        details = $Details
    }
}

function Get-ControlRoomRefreshContract {
    return Get-JsonDocument -Path "contracts/control_room/control_room_refresh_result.contract.json" -Label "Control-room refresh result contract"
}

function Assert-RequiredNonClaims {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$NonClaims,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($requiredNonClaim in $script:RequiredRefreshNonClaims) {
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

    return ($Line -match '(?i)\b(no|not|without|cannot|must not|does not|do not|is not|are not|non-claim|blocked|refused|pending only|not done|unauthorized|not authorized|required before)\b')
}

function Assert-NoForbiddenRefreshClaim {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($line in ($Text -split "\r?\n")) {
        if ($line -match '(?i)\b(productized control-room behavior|full UI app|production runtime|R12 closeout|final-state replay|broad autonomy|solved Codex reliability|broad CI/product coverage|final QA pass for R12 closeout)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context contains a forbidden positive claim: $line"
        }
    }
}

function Assert-GeneratedArtifactClaims {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Refs,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($ref in @($Refs)) {
        Assert-ExistingRef -Ref $ref -Context "$Context generated artifact"
        $text = Get-Content -LiteralPath (Resolve-RepositoryPath -PathValue $ref) -Raw
        Assert-NoForbiddenRefreshClaim -Text $text -Context "$Context generated artifact '$ref'"
    }
}

function Assert-RefreshIdentityResult {
    param(
        [Parameter(Mandatory = $true)]
        $Result,
        [Parameter(Mandatory = $true)]
        [object[]]$CommandResults,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $identity = @($CommandResults | Where-Object { $_.command_name -eq "repo_identity_check" } | Select-Object -First 1)
    if ($identity.Count -eq 0) {
        throw "$Context command_results must include repo_identity_check."
    }
    $identityResult = $identity[0]
    if ([string]$identityResult.status -ne "passed") {
        throw "$Context stale branch/head/tree fails validation; repo_identity_check status is '$($identityResult.status)'."
    }
    foreach ($fieldName in @("expected_repository", "actual_repository", "expected_branch", "actual_branch", "expected_head", "actual_head", "expected_tree", "actual_tree")) {
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $identityResult -Name $fieldName -Context "$Context repo_identity_check") -Context "$Context repo_identity_check.$fieldName" | Out-Null
    }
    if ($identityResult.expected_repository -ne $Result.repository -or $identityResult.actual_repository -ne $Result.repository) {
        throw "$Context stale branch/head/tree fails validation; repository identity is inconsistent."
    }
    if ($identityResult.expected_branch -ne $Result.branch -or $identityResult.actual_branch -ne $Result.branch) {
        throw "$Context stale branch/head/tree fails validation; branch identity is inconsistent."
    }
    if ($identityResult.expected_head -ne $Result.head -or $identityResult.actual_head -ne $Result.head) {
        throw "$Context stale branch/head/tree fails validation; head identity is inconsistent."
    }
    if ($identityResult.expected_tree -ne $Result.tree -or $identityResult.actual_tree -ne $Result.tree) {
        throw "$Context stale branch/head/tree fails validation; tree identity is inconsistent."
    }
}

function Assert-ExternalEvidenceBlocker {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Blockers,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $blockerText = ($Blockers | ConvertTo-Json -Depth 50)
    if ($blockerText -notmatch '(?i)external (runner )?evidence' -or $blockerText -notmatch '(?i)\b(missing|no live|cannot pass|blocked)\b') {
        throw "$Context missing blocker for missing real external evidence."
    }
}

function Test-ControlRoomRefreshResultObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Result,
        [string]$SourceLabel = "Control-room refresh result"
    )

    $contract = Get-ControlRoomRefreshContract
    Assert-RequiredObjectFields -Object $Result -FieldNames $contract.required_fields -Context $SourceLabel

    if ($Result.contract_version -ne $contract.contract_version) {
        throw "$SourceLabel contract_version must be '$($contract.contract_version)'."
    }
    if ($Result.artifact_type -ne "control_room_refresh_result") {
        throw "$SourceLabel artifact_type must be 'control_room_refresh_result'."
    }
    Assert-NonEmptyString -Value $Result.refresh_id -Context "$SourceLabel refresh_id" | Out-Null
    if ($Result.repository -ne $script:R12RepositoryName) {
        throw "$SourceLabel repository must be '$script:R12RepositoryName'."
    }
    if ($Result.branch -ne $script:R12Branch) {
        throw "$SourceLabel branch must be '$script:R12Branch'."
    }
    Assert-GitSha -Value ([string]$Result.head) -Context "$SourceLabel head"
    Assert-GitSha -Value ([string]$Result.tree) -Context "$SourceLabel tree"
    Assert-StringValue -Value $Result.source_status_ref -Context "$SourceLabel source_status_ref" | Out-Null
    $generatedStatusRef = Assert-NonEmptyString -Value $Result.generated_status_ref -Context "$SourceLabel generated_status_ref"
    $generatedViewRef = Assert-NonEmptyString -Value $Result.generated_view_ref -Context "$SourceLabel generated_view_ref"
    $generatedQueueRef = Assert-NonEmptyString -Value $Result.generated_decision_queue_ref -Context "$SourceLabel generated_decision_queue_ref"
    $generatedQueueViewRef = Assert-NonEmptyString -Value $Result.generated_decision_queue_view_ref -Context "$SourceLabel generated_decision_queue_view_ref"

    $commandResults = Assert-ObjectArray -Value $Result.command_results -Context "$SourceLabel command_results"
    foreach ($commandResult in $commandResults) {
        Assert-RequiredObjectFields -Object $commandResult -FieldNames $contract.command_result_required_fields -Context "$SourceLabel command_result"
        Assert-NonEmptyString -Value $commandResult.command_name -Context "$SourceLabel command_result.command_name" | Out-Null
        Assert-NonEmptyString -Value $commandResult.status -Context "$SourceLabel command_result.status" | Out-Null
        Assert-StringValue -Value $commandResult.details -Context "$SourceLabel command_result.details" | Out-Null
    }
    Assert-RefreshIdentityResult -Result $Result -CommandResults $commandResults -Context $SourceLabel

    $validationResults = Assert-ObjectArray -Value $Result.validation_results -Context "$SourceLabel validation_results"
    foreach ($validationResult in $validationResults) {
        Assert-RequiredObjectFields -Object $validationResult -FieldNames $contract.validation_result_required_fields -Context "$SourceLabel validation_result"
        Assert-NonEmptyString -Value $validationResult.target -Context "$SourceLabel validation_result.target" | Out-Null
        Assert-NonEmptyString -Value $validationResult.status -Context "$SourceLabel validation_result.status" | Out-Null
        Assert-StringValue -Value $validationResult.details -Context "$SourceLabel validation_result.details" | Out-Null
    }

    & $script:TestControlRoomStatus -StatusPath $generatedStatusRef | Out-Null
    & $script:TestControlRoomViewMarkdown -StatusPath $generatedStatusRef -MarkdownPath $generatedViewRef | Out-Null
    & $script:TestOperatorDecisionQueue -QueuePath $generatedQueueRef | Out-Null
    & $script:TestOperatorDecisionQueueMarkdown -QueuePath $generatedQueueRef -MarkdownPath $generatedQueueViewRef | Out-Null
    Assert-GeneratedArtifactClaims -Refs @($generatedStatusRef, $generatedViewRef, $generatedQueueRef, $generatedQueueViewRef) -Context $SourceLabel

    $valueGateStatus = Assert-ObjectValue -Value $Result.value_gate_status -Context "$SourceLabel value_gate_status"
    foreach ($gateName in @("external_api_runner", "actionable_qa", "operator_control_room", "real_build_change")) {
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $valueGateStatus -Name $gateName -Context "$SourceLabel value_gate_status") -Context "$SourceLabel value_gate_status.$gateName" | Out-Null
    }

    $blockers = Assert-ObjectArray -Value $Result.blockers -Context "$SourceLabel blockers"
    Assert-ExternalEvidenceBlocker -Blockers $blockers -Context $SourceLabel
    Assert-ObjectArray -Value $Result.next_actions -Context "$SourceLabel next_actions" | Out-Null
    Assert-ObjectArray -Value $Result.operator_decisions_required -Context "$SourceLabel operator_decisions_required" -AllowEmpty | Out-Null

    $refreshVerdict = Assert-NonEmptyString -Value $Result.refresh_verdict -Context "$SourceLabel refresh_verdict"
    Assert-AllowedValue -Value $refreshVerdict -AllowedValues $script:AllowedRefreshVerdicts -Context "$SourceLabel refresh_verdict"
    $refusalReasons = Assert-StringArray -Value $Result.refusal_reasons -Context "$SourceLabel refusal_reasons" -AllowEmpty
    if ($refreshVerdict -in @("failed", "blocked", "refused") -and $refusalReasons.Count -eq 0) {
        throw "$SourceLabel blocked/failed/refused refresh requires refusal_reasons."
    }

    $evidenceRefs = Assert-StringArray -Value $Result.evidence_refs -Context "$SourceLabel evidence_refs"
    foreach ($evidenceRef in $evidenceRefs) {
        Assert-ExistingRef -Ref $evidenceRef -Context "$SourceLabel evidence_refs"
    }
    Assert-TimestampString -Value $Result.generated_at_utc -Context "$SourceLabel generated_at_utc" | Out-Null
    $nonClaims = Assert-StringArray -Value $Result.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel

    $resultText = $Result | ConvertTo-Json -Depth 100
    Assert-NoForbiddenRefreshClaim -Text $resultText -Context $SourceLabel

    return [pscustomobject][ordered]@{
        RefreshId = $Result.refresh_id
        Repository = $Result.repository
        Branch = $Result.branch
        Head = $Result.head
        Tree = $Result.tree
        RefreshVerdict = $refreshVerdict
        GeneratedStatusRef = $generatedStatusRef
        GeneratedViewRef = $generatedViewRef
        GeneratedDecisionQueueRef = $generatedQueueRef
        RefusalReasonCount = $refusalReasons.Count
        EvidenceRefCount = $evidenceRefs.Count
    }
}

function Test-ControlRoomRefreshResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RefreshResultPath
    )

    $result = Get-JsonDocument -Path $RefreshResultPath -Label "Control-room refresh result"
    return Test-ControlRoomRefreshResultObject -Result $result -SourceLabel "Control-room refresh result"
}

function Assert-RequestedRepoIdentity {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Repository,
        [Parameter(Mandatory = $true)]
        [string]$Branch,
        [Parameter(Mandatory = $true)]
        [string]$Head,
        [Parameter(Mandatory = $true)]
        [string]$Tree
    )

    Assert-NonEmptyString -Value $Repository -Context "Repository" | Out-Null
    Assert-NonEmptyString -Value $Branch -Context "Branch" | Out-Null
    Assert-GitSha -Value $Head -Context "Head"
    Assert-GitSha -Value $Tree -Context "Tree"

    $actualRepository = Split-Path -Leaf (Get-RepositoryRoot)
    $actualBranch = Get-GitSingleLine -Arguments @("branch", "--show-current") -Context "git branch --show-current"
    $actualHead = Get-GitSingleLine -Arguments @("rev-parse", "HEAD") -Context "git rev-parse HEAD"
    $actualTree = Get-GitSingleLine -Arguments @("rev-parse", "HEAD^{tree}") -Context "git rev-parse HEAD^{tree}"

    $matches = (
        $Repository -eq $script:R12RepositoryName -and
        $Repository -eq $actualRepository -and
        $Branch -eq $script:R12Branch -and
        $Branch -eq $actualBranch -and
        $Head -eq $actualHead -and
        $Tree -eq $actualTree
    )

    $commandResult = New-CommandResult -CommandName "repo_identity_check" -Status $(if ($matches) { "passed" } else { "failed" }) -Details $(if ($matches) { "Explicit repository/branch/head/tree matched current repo truth." } else { "Explicit repository/branch/head/tree did not match current repo truth." }) -Extra @{
        expected_repository = $Repository
        actual_repository = $actualRepository
        expected_branch = $Branch
        actual_branch = $actualBranch
        expected_head = $Head
        actual_head = $actualHead
        expected_tree = $Tree
        actual_tree = $actualTree
    }

    if (-not $matches) {
        throw "Control-room refresh refused stale branch/head/tree. Expected $Repository/$Branch/$Head/$Tree, actual $actualRepository/$actualBranch/$actualHead/$actualTree."
    }

    return $commandResult
}

function Invoke-ControlRoomRefresh {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Repository,
        [Parameter(Mandatory = $true)]
        [string]$Branch,
        [Parameter(Mandatory = $true)]
        [string]$Head,
        [Parameter(Mandatory = $true)]
        [string]$Tree,
        [string]$StatusOutputPath = "state/control_room/r12_current/control_room_status.json",
        [string]$ViewOutputPath = "state/control_room/r12_current/control_room.md",
        [string]$DecisionQueueOutputPath = "state/control_room/r12_current/operator_decision_queue.json",
        [string]$DecisionQueueViewOutputPath = "state/control_room/r12_current/operator_decision_queue.md",
        [string]$RefreshResultOutputPath = "state/control_room/r12_current/control_room_refresh_result.json",
        [switch]$Overwrite
    )

    $commandResults = New-Object System.Collections.Generic.List[object]
    $validationResults = New-Object System.Collections.Generic.List[object]
    $identityResult = Assert-RequestedRepoIdentity -Repository $Repository -Branch $Branch -Head $Head -Tree $Tree
    $commandResults.Add($identityResult) | Out-Null

    & $script:NewControlRoomStatus -OutputPath $StatusOutputPath -CompletedThroughTask "R12-017" -Overwrite:$Overwrite | Out-Null
    $commandResults.Add((New-CommandResult -CommandName "export_control_room_status" -Status "passed" -Details "Generated control-room status for R12-017." -Extra @{ output_ref = (Convert-ToRepositoryRelativePath -PathValue $StatusOutputPath) })) | Out-Null

    & $script:ExportControlRoomViewMarkdown -StatusPath $StatusOutputPath -MarkdownOutputPath $ViewOutputPath -Overwrite:$Overwrite | Out-Null
    $commandResults.Add((New-CommandResult -CommandName "export_control_room_view" -Status "passed" -Details "Generated Markdown control-room view." -Extra @{ output_ref = (Convert-ToRepositoryRelativePath -PathValue $ViewOutputPath) })) | Out-Null

    & $script:NewOperatorDecisionQueue -ControlRoomStatusPath $StatusOutputPath -OutputPath $DecisionQueueOutputPath -MarkdownOutputPath $DecisionQueueViewOutputPath -Overwrite:$Overwrite | Out-Null
    $commandResults.Add((New-CommandResult -CommandName "export_operator_decision_queue" -Status "passed" -Details "Generated operator decision queue JSON and Markdown." -Extra @{ output_ref = (Convert-ToRepositoryRelativePath -PathValue $DecisionQueueOutputPath); markdown_ref = (Convert-ToRepositoryRelativePath -PathValue $DecisionQueueViewOutputPath) })) | Out-Null

    & $script:TestControlRoomStatus -StatusPath $StatusOutputPath | Out-Null
    $validationResults.Add((New-ValidationResult -Target (Convert-ToRepositoryRelativePath -PathValue $StatusOutputPath) -Status "passed" -Details "Control-room status contract validation passed.")) | Out-Null
    & $script:TestControlRoomViewMarkdown -StatusPath $StatusOutputPath -MarkdownPath $ViewOutputPath | Out-Null
    $validationResults.Add((New-ValidationResult -Target (Convert-ToRepositoryRelativePath -PathValue $ViewOutputPath) -Status "passed" -Details "Control-room Markdown view validation passed.")) | Out-Null
    & $script:TestOperatorDecisionQueue -QueuePath $DecisionQueueOutputPath | Out-Null
    $validationResults.Add((New-ValidationResult -Target (Convert-ToRepositoryRelativePath -PathValue $DecisionQueueOutputPath) -Status "passed" -Details "Operator decision queue validation passed.")) | Out-Null
    & $script:TestOperatorDecisionQueueMarkdown -QueuePath $DecisionQueueOutputPath -MarkdownPath $DecisionQueueViewOutputPath | Out-Null
    $validationResults.Add((New-ValidationResult -Target (Convert-ToRepositoryRelativePath -PathValue $DecisionQueueViewOutputPath) -Status "passed" -Details "Operator decision queue Markdown validation passed.")) | Out-Null

    $status = Get-JsonDocument -Path $StatusOutputPath -Label "Generated control-room status"
    $queue = Get-JsonDocument -Path $DecisionQueueOutputPath -Label "Generated operator decision queue"
    $statusRef = Convert-ToRepositoryRelativePath -PathValue $StatusOutputPath
    $viewRef = Convert-ToRepositoryRelativePath -PathValue $ViewOutputPath
    $queueRef = Convert-ToRepositoryRelativePath -PathValue $DecisionQueueOutputPath
    $queueViewRef = Convert-ToRepositoryRelativePath -PathValue $DecisionQueueViewOutputPath
    $refreshResultRef = Convert-ToRepositoryRelativePath -PathValue $RefreshResultOutputPath

    $evidenceRefs = @(
        "contracts/control_room/control_room_refresh_result.contract.json",
        "tools/ControlRoomRefresh.psm1",
        "tools/refresh_control_room.ps1",
        "tests/test_control_room_refresh.ps1",
        $statusRef,
        $viewRef,
        $queueRef,
        $queueViewRef
    ) | Sort-Object -Unique

    $result = [pscustomobject][ordered]@{
        contract_version = "v1"
        artifact_type = "control_room_refresh_result"
        refresh_id = "r12-control-room-refresh-" + [guid]::NewGuid().ToString("N")
        repository = $Repository
        branch = $Branch
        head = $Head
        tree = $Tree
        source_status_ref = "repo_truth:explicit_repository_branch_head_tree_inputs"
        generated_status_ref = $statusRef
        generated_view_ref = $viewRef
        generated_decision_queue_ref = $queueRef
        generated_decision_queue_view_ref = $queueViewRef
        command_results = @($commandResults.ToArray())
        validation_results = @($validationResults.ToArray())
        value_gate_status = $status.value_gate_status
        blockers = @($status.blockers)
        next_actions = @($status.next_actions)
        operator_decisions_required = @($queue.decisions)
        refresh_verdict = "blocked"
        refusal_reasons = @(
            "Current real QA/evidence gate cannot pass without real external runner result and external artifact evidence.",
            "R12 closeout remains blocked; this refresh only updates bounded operator control-room posture."
        )
        evidence_refs = @($evidenceRefs)
        generated_at_utc = Get-UtcTimestamp
        non_claims = @($script:RequiredRefreshNonClaims)
    }

    Test-ControlRoomRefreshResultObject -Result $result -SourceLabel "Control-room refresh result draft" | Out-Null
    Write-JsonDocument -Path $RefreshResultOutputPath -Document $result -Overwrite:$Overwrite
    & $script:TestControlRoomStatus -StatusPath $StatusOutputPath | Out-Null
    Test-ControlRoomRefreshResult -RefreshResultPath $RefreshResultOutputPath | Out-Null

    $commandResults.Add((New-CommandResult -CommandName "write_refresh_result" -Status "passed" -Details "Generated and validated control-room refresh result." -Extra @{ output_ref = $refreshResultRef })) | Out-Null

    return $result
}

Export-ModuleMember -Function Get-ControlRoomRefreshContract, Test-ControlRoomRefreshResultObject, Test-ControlRoomRefreshResult, Invoke-ControlRoomRefresh
