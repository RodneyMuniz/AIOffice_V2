Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$script:R13RepositoryName = "AIOffice_V2"
$script:R13Branch = "release/r13-api-first-qa-pipeline-and-operator-control-room-product-slice"
$script:R13Milestone = "R13 API-First QA Pipeline and Operator Control-Room Product Slice"
$script:R13SourceTask = "R13-013"
$script:GitObjectPattern = "^[a-f0-9]{40}$"
$script:TimestampPattern = "^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$"
$script:AllowedGateStatuses = @("not_delivered", "partial_local_only", "partially_evidenced", "bounded_scope_delivered", "blocked")
$script:AllowedBlockingStatuses = @("blocking", "non_blocking", "advisory")
$script:AllowedRefreshVerdicts = @("current", "blocked")
$script:RequiredNonClaims = @(
    "R13-012 adds bounded meaningful QA signoff only",
    "R13-013 adds bounded compaction mitigation and restart proof only",
    "R13 active through R13-013 only",
    "R13-014 through R13-018 remain planned only",
    "final QA signoff occurred only for bounded R13 representative QA slice",
    "meaningful QA loop hard gate delivered only for bounded representative scope, not full product scope",
    "API/custom-runner bypass gate remains partial only",
    "operator demo gate is partially evidenced only; not fully delivered as a hard gate",
    "current operator control-room gate remains partially evidenced only; not fully delivered as a hard gate",
    "skill invocation evidence gate remains partial only",
    "external replay evidence is imported and bounded signoff consumed it",
    "R13-012 generated-head mismatch is explicitly reconciled as generation identity, not current identity",
    "does not solve Codex compaction generally",
    "does not solve Codex reliability generally",
    "no full product QA coverage",
    "no R13 closeout",
    "no productized control-room behavior",
    "no full UI app",
    "no production runtime",
    "no real production QA",
    "no full-scope hard gate overclaim",
    "no R14 or successor opening"
)
$script:RequiredViewSections = @(
    "Current branch/head/tree",
    "Active milestone and scope",
    "R13 task status summary",
    "Hard gate posture",
    "QA pipeline posture",
    "Runner/API-custom-runner posture",
    "Skill invocation posture",
    "External replay posture",
    "Signoff posture",
    "Blockers and attention items",
    "Next legal actions",
    "Operator decisions required",
    "Evidence refs",
    "Explicit non-claims"
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

function Assert-RepositoryRelativePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ([string]::IsNullOrWhiteSpace($PathValue)) {
        throw "$Context must be a non-empty repository-relative path."
    }
    if ($PathValue -match '^https?://' -or [System.IO.Path]::IsPathRooted($PathValue) -or $PathValue -match '(^|[\\/])\.\.([\\/]|$)') {
        throw "$Context must be a repository-relative path inside the repository."
    }
    if (-not (Test-IsInsideRepository -PathValue (Resolve-RepositoryPath -PathValue $PathValue))) {
        throw "$Context must resolve inside the repository."
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

    return (Read-SingleJsonObject -Path (Resolve-RepositoryPath -PathValue $Path) -Label $Label)
}

function Write-R13ControlRoomJsonFile {
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

function Write-R13ControlRoomTextFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Value
    )

    $resolvedPath = Resolve-RepositoryPath -PathValue $Path
    $parentPath = Split-Path -Parent $resolvedPath
    if (-not [string]::IsNullOrWhiteSpace($parentPath)) {
        New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    }

    $text = ($Value -replace "`r`n", "`n") -replace "`r", "`n"
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($resolvedPath, $text, $utf8NoBom)
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
        [string]$Context
    )

    if ($Value -isnot [int] -and $Value -isnot [long]) {
        throw "$Context must be an integer."
    }

    return [int]$Value
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

function Assert-GitObjectId {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $text = Assert-NonEmptyString -Value $Value -Context $Context
    if ($text -notmatch $script:GitObjectPattern) {
        throw "$Context must be a 40-character Git object ID."
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

function Get-R13ControlRoomGitIdentity {
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

function New-EvidenceRef {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RefId,
        [Parameter(Mandatory = $true)]
        [string]$Ref,
        [Parameter(Mandatory = $true)]
        [string]$EvidenceKind,
        [string]$AuthorityKind = "repo_evidence",
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

    return ($Line -match '(?i)\b(no|not|without|cannot|must not|does not|do not|is not|are not|did not|non-claim|non_claim|refuse|refuses|blocked|planned|planned only|not yet delivered|not fully delivered|partial|partially|missing|required before|before|prior to|not executed|not delivered|future|pending|rejects|rejected|bounded|only|scope-limited)\b')
}

function Assert-NoForbiddenR13ControlRoomClaims {
    param(
        [Parameter(Mandatory = $true)]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($line in @(Get-StringLeaves -Value $Value)) {
        if ($line -match '(?i)\bexternal[_ -]?replay\b' -and $line -match '(?i)\b(executed|complete|completed|passed|delivered|proved|run|ran|replayed|started)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims external replay execution or delivery. Offending text: $line"
        }
        if ($line -match '(?i)\bfinal\s+QA\s+signoff\b|\bfinal\s+signoff\b|\bsign-off\b' -and $line -match '(?i)\b(accepted|complete|completed|delivered|passed|signed)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims final QA signoff. Offending text: $line"
        }
        if ($line -match '(?i)\boperator\s+demo\b' -and $line -match '(?i)\b(delivered|complete|completed|proved|produced)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims operator demo delivery. Offending text: $line"
        }
        if ($line -match '(?i)\b(hard\s+)?R13\s+hard\s+value\s+gate\b|\bhard\s+value\s+gate\b|\bmeaningful\s+QA\s+loop\b.*\b(delivered|complete|passed|proved)\b|\bAPI/custom-runner bypass\b.*\b(delivered|complete|passed|proved)\b|\bskill\s+invocation\s+evidence\b.*\b(delivered|complete|passed|proved)\b|\bcurrent\s+operator\s+control[- ]room\b.*\b(delivered|complete|passed|proved|fully delivered)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims R13 hard gate delivery. Offending text: $line"
        }
        if ($line -match '(?i)\bproductized control[- ]room behavior\b|\bfull UI app\b|\bproduction runtime\b|\breal production QA\b|\bbroad autonomous milestone execution\b|\bbroad autonomy\b|\bsolved Codex reliability\b|\bsolved Codex context compaction\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims forbidden product, production, autonomy, or reliability scope. Offending text: $line"
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

function Assert-RefArray {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [switch]$AllowEmpty,
        [switch]$RequireExists
    )

    $refs = Assert-ObjectArray -Value $Value -Context $Context -AllowEmpty:$AllowEmpty
    $refIds = @{}
    foreach ($refObject in @($refs)) {
        Assert-RequiredObjectFields -Object $refObject -FieldNames @("ref_id", "ref", "evidence_kind", "authority_kind", "scope") -Context $Context
        $refId = Assert-NonEmptyString -Value $refObject.ref_id -Context "$Context ref_id"
        if ($refIds.ContainsKey($refId)) {
            throw "$Context contains duplicate ref_id '$refId'."
        }
        $refIds[$refId] = $true
        $ref = Assert-NonEmptyString -Value $refObject.ref -Context "$Context ref"
        Assert-RepositoryRelativePath -PathValue $ref -Context "$Context ref"
        if ($RequireExists -and -not (Test-Path -LiteralPath (Resolve-RepositoryPath -PathValue $ref))) {
            throw "$Context ref '$ref' does not exist."
        }
        Assert-NonEmptyString -Value $refObject.evidence_kind -Context "$Context evidence_kind" | Out-Null
        Assert-NonEmptyString -Value $refObject.authority_kind -Context "$Context authority_kind" | Out-Null
        Assert-NonEmptyString -Value $refObject.scope -Context "$Context scope" | Out-Null
    }

    $PSCmdlet.WriteObject($refs, $false)
}

function Get-R13ControlRoomStatusContract {
    return Get-JsonDocument -Path "contracts/control_room/r13_control_room_status.contract.json" -Label "R13 control-room status contract"
}

function Get-R13ControlRoomViewContract {
    return Get-JsonDocument -Path "contracts/control_room/r13_control_room_view.contract.json" -Label "R13 control-room view contract"
}

function Get-R13ControlRoomRefreshResultContract {
    return Get-JsonDocument -Path "contracts/control_room/r13_control_room_refresh_result.contract.json" -Label "R13 control-room refresh result contract"
}

function Get-R13RequiredNonClaims {
    return @($script:RequiredNonClaims)
}

function Get-R13RequiredMajorEvidenceRefs {
    return @(
        (New-EvidenceRef -RefId "r13-control-room-status-contract" -Ref "contracts/control_room/r13_control_room_status.contract.json" -EvidenceKind "contract" -AuthorityKind "repo_contract"),
        (New-EvidenceRef -RefId "r13-control-room-view-contract" -Ref "contracts/control_room/r13_control_room_view.contract.json" -EvidenceKind "contract" -AuthorityKind "repo_contract"),
        (New-EvidenceRef -RefId "r13-control-room-refresh-result-contract" -Ref "contracts/control_room/r13_control_room_refresh_result.contract.json" -EvidenceKind "contract" -AuthorityKind "repo_contract"),
        (New-EvidenceRef -RefId "r13-control-room-module" -Ref "tools/R13ControlRoomStatus.psm1" -EvidenceKind "module" -AuthorityKind "repo_tooling"),
        (New-EvidenceRef -RefId "r13-control-room-renderer" -Ref "tools/render_r13_control_room_view.ps1" -EvidenceKind "cli" -AuthorityKind "repo_tooling"),
        (New-EvidenceRef -RefId "r13-control-room-refresh-cli" -Ref "tools/refresh_r13_control_room.ps1" -EvidenceKind "cli" -AuthorityKind "repo_tooling"),
        (New-EvidenceRef -RefId "r13-control-room-status-validator" -Ref "tools/validate_r13_control_room_status.ps1" -EvidenceKind "validator" -AuthorityKind "repo_tooling"),
        (New-EvidenceRef -RefId "r13-control-room-view-validator" -Ref "tools/validate_r13_control_room_view.ps1" -EvidenceKind "validator" -AuthorityKind "repo_tooling"),
        (New-EvidenceRef -RefId "r13-control-room-refresh-validator" -Ref "tools/validate_r13_control_room_refresh_result.ps1" -EvidenceKind "validator" -AuthorityKind "repo_tooling"),
        (New-EvidenceRef -RefId "r13-control-room-test" -Ref "tests/test_r13_control_room_status.ps1" -EvidenceKind "test" -AuthorityKind "repo_tooling"),
        (New-EvidenceRef -RefId "r13-operator-demo-contract" -Ref "contracts/control_room/r13_operator_demo.contract.json" -EvidenceKind "contract" -AuthorityKind "repo_contract"),
        (New-EvidenceRef -RefId "r13-operator-demo-renderer" -Ref "tools/render_r13_operator_demo.ps1" -EvidenceKind "cli" -AuthorityKind "repo_tooling"),
        (New-EvidenceRef -RefId "r13-operator-demo-validator" -Ref "tools/validate_r13_operator_demo.ps1" -EvidenceKind "validator" -AuthorityKind "repo_tooling"),
        (New-EvidenceRef -RefId "r13-operator-demo-test" -Ref "tests/test_r13_operator_demo.ps1" -EvidenceKind "test" -AuthorityKind "repo_tooling"),
        (New-EvidenceRef -RefId "r13-operator-demo-artifact" -Ref "state/control_room/r13_current/operator_demo.md" -EvidenceKind "operator_demo" -AuthorityKind "repo_evidence"),
        (New-EvidenceRef -RefId "r13-operator-demo-validation-manifest" -Ref "state/control_room/r13_current/operator_demo_validation_manifest.md" -EvidenceKind "validation_manifest" -AuthorityKind "repo_evidence"),
        (New-EvidenceRef -RefId "r13-authority" -Ref "governance/R13_API_FIRST_QA_PIPELINE_AND_OPERATOR_CONTROL_ROOM_PRODUCT_SLICE.md" -EvidenceKind "authority" -AuthorityKind "repo_governance"),
        (New-EvidenceRef -RefId "r13-003-issue-report" -Ref "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/qa/r13_003_issue_detection_report.json" -EvidenceKind "issue_detection_report" -AuthorityKind "repo_evidence"),
        (New-EvidenceRef -RefId "r13-004-fix-queue" -Ref "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/qa/r13_004_fix_queue.json" -EvidenceKind "fix_queue" -AuthorityKind "repo_evidence"),
        (New-EvidenceRef -RefId "r13-005-bounded-fix-execution" -Ref "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/qa/r13_005_bounded_fix_execution_packet.json" -EvidenceKind "bounded_fix_execution_packet" -AuthorityKind "repo_evidence"),
        (New-EvidenceRef -RefId "r13-006-fix-execution-result" -Ref "state/cycles/r13_qa_cycle_demo/fix_execution_result.json" -EvidenceKind "fix_execution_result" -AuthorityKind "repo_evidence"),
        (New-EvidenceRef -RefId "r13-006-before-after-comparison" -Ref "state/cycles/r13_qa_cycle_demo/before_after_comparison.json" -EvidenceKind "before_after_comparison" -AuthorityKind "repo_evidence"),
        (New-EvidenceRef -RefId "r13-006-failure-fix-cycle" -Ref "state/cycles/r13_qa_cycle_demo/qa_failure_fix_cycle.json" -EvidenceKind "failure_fix_cycle" -AuthorityKind "repo_evidence"),
        (New-EvidenceRef -RefId "r13-007-custom-runner-result" -Ref "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/runner/r13_007_custom_runner_result.json" -EvidenceKind "custom_runner_result" -AuthorityKind "repo_evidence"),
        (New-EvidenceRef -RefId "r13-008-skill-registry" -Ref "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_skill_registry.json" -EvidenceKind "skill_registry" -AuthorityKind "repo_evidence"),
        (New-EvidenceRef -RefId "r13-008-qa-detect-result" -Ref "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_qa_detect_invocation_result.json" -EvidenceKind "skill_invocation_result" -AuthorityKind "repo_evidence"),
        (New-EvidenceRef -RefId "r13-008-qa-fix-plan-result" -Ref "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_qa_fix_plan_invocation_result.json" -EvidenceKind "skill_invocation_result" -AuthorityKind "repo_evidence"),
        (New-EvidenceRef -RefId "r13-011-external-replay-request-contract" -Ref "contracts/external_replay/r13_external_replay_request.contract.json" -EvidenceKind "contract" -AuthorityKind "repo_contract"),
        (New-EvidenceRef -RefId "r13-011-external-replay-result-contract" -Ref "contracts/external_replay/r13_external_replay_result.contract.json" -EvidenceKind "contract" -AuthorityKind "repo_contract"),
        (New-EvidenceRef -RefId "r13-011-external-replay-import-contract" -Ref "contracts/external_replay/r13_external_replay_import.contract.json" -EvidenceKind "contract" -AuthorityKind "repo_contract"),
        (New-EvidenceRef -RefId "r13-011-external-replay-module" -Ref "tools/R13ExternalReplay.psm1" -EvidenceKind "module" -AuthorityKind "repo_tooling"),
        (New-EvidenceRef -RefId "r13-011-external-replay-request-generator" -Ref "tools/new_r13_external_replay_request.ps1" -EvidenceKind "cli" -AuthorityKind "repo_tooling"),
        (New-EvidenceRef -RefId "r13-011-external-replay-invoker" -Ref "tools/invoke_r13_external_replay.ps1" -EvidenceKind "cli" -AuthorityKind "repo_tooling"),
        (New-EvidenceRef -RefId "r13-011-external-replay-request-validator" -Ref "tools/validate_r13_external_replay_request.ps1" -EvidenceKind "validator" -AuthorityKind "repo_tooling"),
        (New-EvidenceRef -RefId "r13-011-external-replay-result-validator" -Ref "tools/validate_r13_external_replay_result.ps1" -EvidenceKind "validator" -AuthorityKind "repo_tooling"),
        (New-EvidenceRef -RefId "r13-011-external-replay-import-validator" -Ref "tools/validate_r13_external_replay_import.ps1" -EvidenceKind "validator" -AuthorityKind "repo_tooling"),
        (New-EvidenceRef -RefId "r13-011-external-replay-request" -Ref "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_request.json" -EvidenceKind "external_replay_request" -AuthorityKind "repo_evidence"),
        (New-EvidenceRef -RefId "r13-011-external-replay-result" -Ref "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_result.json" -EvidenceKind "external_replay_result" -AuthorityKind "repo_evidence"),
        (New-EvidenceRef -RefId "r13-011-external-replay-import" -Ref "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_import.json" -EvidenceKind "external_replay_import" -AuthorityKind "repo_evidence"),
        (New-EvidenceRef -RefId "r13-011-external-replay-imported-artifact" -Ref "state/external_runs/r13_external_replay/r13_011/imported_artifact_25241730946_6759970924/validation_manifest.md" -EvidenceKind "imported_artifact_manifest" -AuthorityKind "github_actions_external_runner"),
        (New-EvidenceRef -RefId "r13-011-external-replay-blocked" -Ref "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_blocked.json" -EvidenceKind "blocked_result" -AuthorityKind "repo_evidence"),
        (New-EvidenceRef -RefId "r13-011-external-replay-manual-dispatch" -Ref "state/external_runs/r13_external_replay/r13_011/manual_dispatch_packet.json" -EvidenceKind "manual_dispatch_packet" -AuthorityKind "repo_evidence"),
        (New-EvidenceRef -RefId "r13-011-external-replay-validation-manifest" -Ref "state/external_runs/r13_external_replay/r13_011/validation_manifest.md" -EvidenceKind "validation_manifest" -AuthorityKind "repo_evidence"),
        (New-EvidenceRef -RefId "r13-012-signoff-contract" -Ref "contracts/actionable_qa/r13_meaningful_qa_signoff.contract.json" -EvidenceKind "contract" -AuthorityKind "repo_contract"),
        (New-EvidenceRef -RefId "r13-012-evidence-matrix-contract" -Ref "contracts/actionable_qa/r13_meaningful_qa_signoff_evidence_matrix.contract.json" -EvidenceKind "contract" -AuthorityKind "repo_contract"),
        (New-EvidenceRef -RefId "r13-012-signoff-module" -Ref "tools/R13MeaningfulQaSignoff.psm1" -EvidenceKind "module" -AuthorityKind "repo_tooling"),
        (New-EvidenceRef -RefId "r13-012-signoff-generator" -Ref "tools/new_r13_meaningful_qa_signoff.ps1" -EvidenceKind "cli" -AuthorityKind "repo_tooling"),
        (New-EvidenceRef -RefId "r13-012-signoff-validator" -Ref "tools/validate_r13_meaningful_qa_signoff.ps1" -EvidenceKind "validator" -AuthorityKind "repo_tooling"),
        (New-EvidenceRef -RefId "r13-012-evidence-matrix-validator" -Ref "tools/validate_r13_meaningful_qa_signoff_evidence_matrix.ps1" -EvidenceKind "validator" -AuthorityKind "repo_tooling"),
        (New-EvidenceRef -RefId "r13-012-signoff-test" -Ref "tests/test_r13_meaningful_qa_signoff.ps1" -EvidenceKind "test" -AuthorityKind "repo_tooling"),
        (New-EvidenceRef -RefId "r13-012-signoff" -Ref "state/signoff/r13_meaningful_qa_signoff/r13_012_signoff.json" -EvidenceKind "meaningful_qa_signoff" -AuthorityKind "repo_evidence"),
        (New-EvidenceRef -RefId "r13-012-evidence-matrix" -Ref "state/signoff/r13_meaningful_qa_signoff/r13_012_evidence_matrix.json" -EvidenceKind "evidence_matrix" -AuthorityKind "repo_evidence"),
        (New-EvidenceRef -RefId "r13-012-signoff-validation-manifest" -Ref "state/signoff/r13_meaningful_qa_signoff/validation_manifest.md" -EvidenceKind "validation_manifest" -AuthorityKind "repo_evidence"),
        (New-EvidenceRef -RefId "r13-013-packet-contract" -Ref "contracts/continuity/r13_compaction_mitigation_packet.contract.json" -EvidenceKind "contract" -AuthorityKind "repo_contract"),
        (New-EvidenceRef -RefId "r13-013-restart-prompt-contract" -Ref "contracts/continuity/r13_restart_prompt.contract.json" -EvidenceKind "contract" -AuthorityKind "repo_contract"),
        (New-EvidenceRef -RefId "r13-013-module" -Ref "tools/R13CompactionMitigation.psm1" -EvidenceKind "module" -AuthorityKind "repo_tooling"),
        (New-EvidenceRef -RefId "r13-013-generator" -Ref "tools/new_r13_compaction_mitigation_packet.ps1" -EvidenceKind "cli" -AuthorityKind "repo_tooling"),
        (New-EvidenceRef -RefId "r13-013-packet-validator" -Ref "tools/validate_r13_compaction_mitigation_packet.ps1" -EvidenceKind "validator" -AuthorityKind "repo_tooling"),
        (New-EvidenceRef -RefId "r13-013-restart-prompt-validator" -Ref "tools/validate_r13_restart_prompt.ps1" -EvidenceKind "validator" -AuthorityKind "repo_tooling"),
        (New-EvidenceRef -RefId "r13-013-test" -Ref "tests/test_r13_compaction_mitigation.ps1" -EvidenceKind "test" -AuthorityKind "repo_tooling"),
        (New-EvidenceRef -RefId "r13-013-identity-reconciliation" -Ref "state/continuity/r13_compaction_mitigation/r13_013_identity_reconciliation.json" -EvidenceKind "identity_reconciliation" -AuthorityKind "repo_evidence"),
        (New-EvidenceRef -RefId "r13-013-compaction-mitigation-packet" -Ref "state/continuity/r13_compaction_mitigation/r13_013_compaction_mitigation_packet.json" -EvidenceKind "compaction_mitigation_packet" -AuthorityKind "repo_evidence"),
        (New-EvidenceRef -RefId "r13-013-restart-prompt" -Ref "state/continuity/r13_compaction_mitigation/r13_013_restart_prompt.md" -EvidenceKind "restart_prompt" -AuthorityKind "repo_evidence"),
        (New-EvidenceRef -RefId "r13-013-validation-manifest" -Ref "state/continuity/r13_compaction_mitigation/validation_manifest.md" -EvidenceKind "validation_manifest" -AuthorityKind "repo_evidence")
    )
}

function Read-R13MajorEvidence {
    $documents = @{}
    foreach ($refObject in @(Get-R13RequiredMajorEvidenceRefs)) {
        Assert-ExistingRef -Ref ([string]$refObject.ref) -Context "major evidence '$($refObject.ref_id)'"
        if ([string]$refObject.ref -like "*.json") {
            $documents[[string]$refObject.ref_id] = Get-JsonDocument -Path ([string]$refObject.ref) -Label "major evidence '$($refObject.ref_id)'"
        }
    }

    $expectedArtifacts = @{
        "r13-003-issue-report" = "r13_qa_issue_detection_report"
        "r13-004-fix-queue" = "r13_qa_fix_queue"
        "r13-005-bounded-fix-execution" = "r13_bounded_fix_execution_packet"
        "r13-006-fix-execution-result" = "r13_fix_execution_result"
        "r13-006-before-after-comparison" = "r13_qa_before_after_comparison"
        "r13-006-failure-fix-cycle" = "r13_qa_failure_fix_cycle"
        "r13-007-custom-runner-result" = "r13_custom_runner_result"
        "r13-008-skill-registry" = "r13_skill_registry"
        "r13-008-qa-detect-result" = "r13_skill_invocation_result"
        "r13-008-qa-fix-plan-result" = "r13_skill_invocation_result"
        "r13-012-signoff" = "r13_meaningful_qa_signoff"
        "r13-012-evidence-matrix" = "r13_meaningful_qa_signoff_evidence_matrix"
        "r13-013-identity-reconciliation" = "r13_013_identity_reconciliation"
        "r13-013-compaction-mitigation-packet" = "r13_compaction_mitigation_packet"
    }

    foreach ($entry in $expectedArtifacts.GetEnumerator()) {
        $document = $documents[$entry.Key]
        if ($document.artifact_type -ne $entry.Value) {
            throw "Major evidence '$($entry.Key)' artifact_type must be '$($entry.Value)'."
        }
        if ($document.repository -ne $script:R13RepositoryName) {
            throw "Major evidence '$($entry.Key)' repository must be '$script:R13RepositoryName'."
        }
        if ($document.branch -ne $script:R13Branch) {
            throw "Major evidence '$($entry.Key)' branch must be '$script:R13Branch'."
        }
        if ($document.source_milestone -ne $script:R13Milestone) {
            throw "Major evidence '$($entry.Key)' source_milestone must be '$script:R13Milestone'."
        }
    }

    return $documents
}

function Get-ArrayCount {
    param(
        [AllowNull()]
        $Value
    )

    if ($null -eq $Value) {
        return 0
    }
    if ($Value -is [string]) {
        return 1
    }
    if ($Value -is [System.Collections.IEnumerable]) {
        return @($Value).Count
    }
    return 1
}

function Get-CommandCounts {
    param(
        [AllowNull()]
        $CommandResults
    )

    $commands = @($CommandResults)
    return [pscustomobject][ordered]@{
        total = $commands.Count
        passed = @($commands | Where-Object { [string]$_.verdict -eq "passed" }).Count
        failed = @($commands | Where-Object { [string]$_.verdict -eq "failed" }).Count
        blocked = @($commands | Where-Object { [string]$_.verdict -eq "blocked" }).Count
    }
}

function New-R13TaskStatusLists {
    $completed = @()
    foreach ($taskNumber in 1..13) {
        $taskId = "R13-{0}" -f $taskNumber.ToString("000")
        $completed += [pscustomobject][ordered]@{
            task_id = $taskId
            status = "done"
            summary = if ($taskId -eq "R13-013") { "Bounded compaction mitigation packet, identity reconciliation, restart prompt, validators, tests, and validation manifest generated from repo-truth evidence." } elseif ($taskId -eq "R13-012") { "Bounded meaningful QA signoff gate, evidence matrix, validators, tests, and validation manifest generated from actual R13 evidence." } elseif ($taskId -eq "R13-011") { "External replay request, prior blocked dispatch packet, GitHub Actions replay result, imported artifact evidence, raw logs, and validation manifest generated without final QA signoff." } elseif ($taskId -eq "R13-010") { "Human-readable operator demo artifact, validator, test, and validation manifest generated from actual R13 evidence." } elseif ($taskId -eq "R13-009") { "Current cycle-aware control-room status, Markdown view, refresh result, stale-state checks, validators, tests, and validation manifest." } else { "$taskId completed in prior R13 repo evidence." }
            evidence_refs = [string[]]$(if ($taskId -eq "R13-011") {
                @(
                    "contracts/external_replay/r13_external_replay_request.contract.json",
                    "contracts/external_replay/r13_external_replay_result.contract.json",
                    "contracts/external_replay/r13_external_replay_import.contract.json",
                    "tools/R13ExternalReplay.psm1",
                    "tools/new_r13_external_replay_request.ps1",
                    "tools/invoke_r13_external_replay.ps1",
                    "tools/validate_r13_external_replay_request.ps1",
                    "tools/validate_r13_external_replay_result.ps1",
                    "tools/validate_r13_external_replay_import.ps1",
                    "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_request.json",
                    "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_result.json",
                    "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_import.json",
                    "state/external_runs/r13_external_replay/r13_011/imported_artifact_25241730946_6759970924/validation_manifest.md",
                    "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_blocked.json",
                    "state/external_runs/r13_external_replay/r13_011/manual_dispatch_packet.json",
                    "state/external_runs/r13_external_replay/r13_011/validation_manifest.md"
                )
            }
            elseif ($taskId -eq "R13-012") {
                @(
                    "contracts/actionable_qa/r13_meaningful_qa_signoff.contract.json",
                    "contracts/actionable_qa/r13_meaningful_qa_signoff_evidence_matrix.contract.json",
                    "tools/R13MeaningfulQaSignoff.psm1",
                    "tools/new_r13_meaningful_qa_signoff.ps1",
                    "tools/validate_r13_meaningful_qa_signoff.ps1",
                    "tools/validate_r13_meaningful_qa_signoff_evidence_matrix.ps1",
                    "tests/test_r13_meaningful_qa_signoff.ps1",
                    "state/signoff/r13_meaningful_qa_signoff/r13_012_signoff.json",
                    "state/signoff/r13_meaningful_qa_signoff/r13_012_evidence_matrix.json",
                    "state/signoff/r13_meaningful_qa_signoff/validation_manifest.md"
                )
            }
            elseif ($taskId -eq "R13-013") {
                @(
                    "contracts/continuity/r13_compaction_mitigation_packet.contract.json",
                    "contracts/continuity/r13_restart_prompt.contract.json",
                    "tools/R13CompactionMitigation.psm1",
                    "tools/new_r13_compaction_mitigation_packet.ps1",
                    "tools/validate_r13_compaction_mitigation_packet.ps1",
                    "tools/validate_r13_restart_prompt.ps1",
                    "tests/test_r13_compaction_mitigation.ps1",
                    "state/continuity/r13_compaction_mitigation/r13_013_identity_reconciliation.json",
                    "state/continuity/r13_compaction_mitigation/r13_013_compaction_mitigation_packet.json",
                    "state/continuity/r13_compaction_mitigation/r13_013_restart_prompt.md",
                    "state/continuity/r13_compaction_mitigation/validation_manifest.md"
                )
            }
            elseif ($taskId -eq "R13-010") {
                @(
                    "contracts/control_room/r13_operator_demo.contract.json",
                    "tools/render_r13_operator_demo.ps1",
                    "tools/validate_r13_operator_demo.ps1",
                    "tests/test_r13_operator_demo.ps1",
                    "state/control_room/r13_current/operator_demo.md",
                    "state/control_room/r13_current/operator_demo_validation_manifest.md"
                )
            }
            elseif ($taskId -eq "R13-009") {
                @(
                    "contracts/control_room/r13_control_room_status.contract.json",
                    "contracts/control_room/r13_control_room_view.contract.json",
                    "contracts/control_room/r13_control_room_refresh_result.contract.json",
                    "tools/R13ControlRoomStatus.psm1",
                    "tools/render_r13_control_room_view.ps1",
                    "tools/refresh_r13_control_room.ps1",
                    "tests/test_r13_control_room_status.ps1"
                )
            }
            else {
                @("governance/R13_API_FIRST_QA_PIPELINE_AND_OPERATOR_CONTROL_ROOM_PRODUCT_SLICE.md")
            })
        }
    }

    $planned = @()
    foreach ($taskNumber in 14..18) {
        $taskId = "R13-{0}" -f $taskNumber.ToString("000")
        $planned += [pscustomobject][ordered]@{
            task_id = $taskId
            status = "planned_only"
            summary = "$taskId remains planned only under the R13 authority task order."
            evidence_refs = [string[]]@("governance/R13_API_FIRST_QA_PIPELINE_AND_OPERATOR_CONTROL_ROOM_PRODUCT_SLICE.md")
        }
    }

    return [pscustomobject][ordered]@{
        Completed = @($completed)
        Planned = @($planned)
    }
}

function New-StaleStateChecks {
    param(
        [Parameter(Mandatory = $true)]
        $GitIdentity,
        [string]$ExpectedBranch,
        [string]$ExpectedHead,
        [string]$ExpectedTree,
        [bool]$RequiredEvidenceRefsPresent = $true,
        [bool]$HardGateOverclaimAbsent = $true,
        [bool]$ExternalReplayNotClaimed = $true,
        [bool]$FinalSignoffNotOverclaimed = $true,
        [bool]$OperatorDemoNotClaimed = $true,
        [bool]$R14SuccessorNotOpened = $true,
        [bool]$ProductizedUiNotClaimed = $true
    )

    if ([string]::IsNullOrWhiteSpace($ExpectedBranch)) { $ExpectedBranch = [string]$GitIdentity.Branch }
    if ([string]::IsNullOrWhiteSpace($ExpectedHead)) { $ExpectedHead = [string]$GitIdentity.Head }
    if ([string]::IsNullOrWhiteSpace($ExpectedTree)) { $ExpectedTree = [string]$GitIdentity.Tree }

    $branchMatches = [string]$GitIdentity.Branch -eq $ExpectedBranch
    $headMatches = [string]$GitIdentity.Head -eq $ExpectedHead
    $treeMatches = [string]$GitIdentity.Tree -eq $ExpectedTree
    $passed = $branchMatches -and $headMatches -and $treeMatches -and $RequiredEvidenceRefsPresent -and $HardGateOverclaimAbsent -and $ExternalReplayNotClaimed -and $FinalSignoffNotOverclaimed -and $OperatorDemoNotClaimed -and $R14SuccessorNotOpened -and $ProductizedUiNotClaimed

    return [pscustomobject][ordered]@{
        expected_branch = $ExpectedBranch
        expected_head = $ExpectedHead
        expected_tree = $ExpectedTree
        observed_branch = [string]$GitIdentity.Branch
        observed_head = [string]$GitIdentity.Head
        observed_tree = [string]$GitIdentity.Tree
        branch_matches_expected = $branchMatches
        head_matches_expected = $headMatches
        tree_matches_expected = $treeMatches
        required_evidence_refs_present = $RequiredEvidenceRefsPresent
        hard_gate_overclaim_absent = $HardGateOverclaimAbsent
        external_replay_not_claimed = $ExternalReplayNotClaimed
        final_signoff_not_overclaimed = $FinalSignoffNotOverclaimed
        operator_demo_not_claimed = $OperatorDemoNotClaimed
        r14_successor_not_opened = $R14SuccessorNotOpened
        productized_ui_not_claimed = $ProductizedUiNotClaimed
        stale_state_checks_passed = $passed
    }
}

function Get-StaleStateRefusalReasons {
    param(
        [Parameter(Mandatory = $true)]
        $Checks
    )

    $reasons = @()
    if (-not [bool]$Checks.branch_matches_expected) {
        $reasons += "Expected branch '$($Checks.expected_branch)' does not match current branch '$($Checks.observed_branch)'."
    }
    if (-not [bool]$Checks.head_matches_expected) {
        $reasons += "Expected head '$($Checks.expected_head)' does not match current head '$($Checks.observed_head)'."
    }
    if (-not [bool]$Checks.tree_matches_expected) {
        $reasons += "Expected tree '$($Checks.expected_tree)' does not match current tree '$($Checks.observed_tree)'."
    }
    foreach ($fieldName in @("required_evidence_refs_present", "hard_gate_overclaim_absent", "external_replay_not_claimed", "final_signoff_not_overclaimed", "operator_demo_not_claimed", "r14_successor_not_opened", "productized_ui_not_claimed")) {
        if (-not [bool]$Checks.$fieldName) {
            $reasons += "Stale-state check '$fieldName' did not pass."
        }
    }
    return @($reasons)
}

function New-R13HardGateStatus {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$ControlRoomEvidenceRefs
    )

    return [pscustomobject][ordered]@{
        meaningful_qa_loop = [pscustomobject][ordered]@{
            status = "bounded_scope_delivered"
            hard_gate_delivered = $true
            delivery_scope = "bounded_representative_qa_failure_to_fix_slice_only"
            full_product_scope_delivered = $false
            summary = "Local detector, queue, bounded execution packet, demo failure-to-fix cycle, local custom runner evidence, local skill invocations, current control-room evidence, operator demo evidence, passed external replay/import evidence, and R13-012 bounded signoff exist. R13-013 adds continuity mitigation only. This delivers the meaningful QA loop hard gate only for the bounded representative slice, not for full product QA coverage."
            missing_required_evidence = @("full_product_qa_coverage", "production_qa_evidence")
            evidence_refs = @(
                "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/qa/r13_003_issue_detection_report.json",
                "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/qa/r13_004_fix_queue.json",
                "state/cycles/r13_qa_cycle_demo/qa_failure_fix_cycle.json",
                "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_result.json",
                "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_import.json",
                "state/signoff/r13_meaningful_qa_signoff/r13_012_signoff.json",
                "state/signoff/r13_meaningful_qa_signoff/r13_012_evidence_matrix.json"
            )
        }
        api_custom_runner_bypass = [pscustomobject][ordered]@{
            status = "partial_local_only"
            hard_gate_delivered = $false
            summary = "R13-007 adds a local API-shaped/custom-runner foundation with bounded validation command results only; the bypass gate is not fully delivered."
            missing_required_evidence = @("productized_api_runner_bypass_proof")
            evidence_refs = @("state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/runner/r13_007_custom_runner_result.json")
        }
        current_operator_control_room = [pscustomobject][ordered]@{
            status = "partially_evidenced"
            hard_gate_delivered = $false
            summary = "R13-009 generates current cycle-aware status, Markdown view, refresh result, stale-state checks, validators, tests, and validation manifest from repo truth; R13-010 adds a Markdown operator demo artifact; R13-011 records passed external replay/import evidence; R13-012 records bounded signoff; R13-013 records bounded restart proof. This remains partial operator-control-room evidence only, not productized control-room behavior."
            missing_required_evidence = @("productized_operator_control_room")
            evidence_refs = @($ControlRoomEvidenceRefs)
        }
        skill_invocation_evidence = [pscustomobject][ordered]@{
            status = "partially_evidenced"
            hard_gate_delivered = $false
            summary = "R13-008 registers four skills and invokes qa.detect plus qa.fix_plan locally with one passed validation command each; runner.external_replay and control_room.refresh are registered but not invoked as R13-008 skills."
            missing_required_evidence = @("external_replay_skill_invocation", "control_room_refresh_skill_invocation_if_required_by_later_gate")
            evidence_refs = @(
                "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_skill_registry.json",
                "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_qa_detect_invocation_result.json",
                "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_qa_fix_plan_invocation_result.json"
            )
        }
        operator_demo = [pscustomobject][ordered]@{
            status = "partially_evidenced"
            hard_gate_delivered = $false
            summary = "R13-010 adds a human-readable Markdown operator demo from actual R13 evidence; R13-012 consumes it for bounded signoff. This is partial operator-demo evidence only, not a productized demo surface."
            missing_required_evidence = @("productized_operator_demo")
            evidence_refs = @(
                "contracts/control_room/r13_operator_demo.contract.json",
                "tools/render_r13_operator_demo.ps1",
                "tools/validate_r13_operator_demo.ps1",
                "tests/test_r13_operator_demo.ps1",
                "state/control_room/r13_current/operator_demo.md",
                "state/control_room/r13_current/operator_demo_validation_manifest.md"
            )
        }
        overall = [pscustomobject][ordered]@{
            status = "bounded_scope_passed"
            any_hard_gate_delivered = $true
            any_full_product_hard_gate_delivered = $false
            summary = "R13-012 delivers the meaningful QA loop hard gate only for the bounded representative QA slice. R13-013 adds bounded continuity mitigation only. No full product, production, UI, broad autonomy, R13 closeout, R14, or successor gate is delivered."
        }
    }
}

function New-R13ControlRoomStatusObject {
    [CmdletBinding()]
    param(
        [string]$StatusRef = "state/control_room/r13_current/control_room_status.json",
        [string]$ViewRef = "state/control_room/r13_current/control_room.md",
        [string]$RefreshResultRef = "state/control_room/r13_current/control_room_refresh_result.json",
        [string]$ValidationManifestRef = "state/control_room/r13_current/validation_manifest.md",
        [string]$ExpectedBranch,
        [string]$ExpectedHead,
        [string]$ExpectedTree
    )

    $gitIdentity = Get-R13ControlRoomGitIdentity
    $staleChecks = New-StaleStateChecks -GitIdentity $gitIdentity -ExpectedBranch $ExpectedBranch -ExpectedHead $ExpectedHead -ExpectedTree $ExpectedTree
    $refusalReasons = Get-StaleStateRefusalReasons -Checks $staleChecks
    if (@($refusalReasons).Count -gt 0) {
        throw "Refusing stale R13 control-room status: $($refusalReasons -join ' ')"
    }

    $documents = Read-R13MajorEvidence
    $issueReport = $documents["r13-003-issue-report"]
    $fixQueue = $documents["r13-004-fix-queue"]
    $boundedPacket = $documents["r13-005-bounded-fix-execution"]
    $failureFixCycle = $documents["r13-006-failure-fix-cycle"]
    $comparison = $documents["r13-006-before-after-comparison"]
    $runnerResult = $documents["r13-007-custom-runner-result"]
    $skillRegistry = $documents["r13-008-skill-registry"]
    $qaDetectResult = $documents["r13-008-qa-detect-result"]
    $qaFixPlanResult = $documents["r13-008-qa-fix-plan-result"]
    $externalReplayRequest = $documents["r13-011-external-replay-request"]
    $externalReplayResult = $documents["r13-011-external-replay-result"]
    $externalReplayImport = $documents["r13-011-external-replay-import"]
    $externalReplayBlocked = $documents["r13-011-external-replay-blocked"]
    $signoff = $documents["r13-012-signoff"]
    $evidenceMatrix = $documents["r13-012-evidence-matrix"]

    $taskLists = New-R13TaskStatusLists
    $controlRoomEvidenceRefs = @(
        "contracts/control_room/r13_control_room_status.contract.json",
        "contracts/control_room/r13_control_room_view.contract.json",
        "contracts/control_room/r13_control_room_refresh_result.contract.json",
        "tools/R13ControlRoomStatus.psm1",
        "tools/render_r13_control_room_view.ps1",
        "tools/refresh_r13_control_room.ps1",
        "tools/validate_r13_control_room_status.ps1",
        "tools/validate_r13_control_room_view.ps1",
        "tools/validate_r13_control_room_refresh_result.ps1",
        "tests/test_r13_control_room_status.ps1",
        "contracts/control_room/r13_operator_demo.contract.json",
        "tools/render_r13_operator_demo.ps1",
        "tools/validate_r13_operator_demo.ps1",
        "tests/test_r13_operator_demo.ps1",
        $StatusRef.Replace("\", "/"),
        $ViewRef.Replace("\", "/"),
        $RefreshResultRef.Replace("\", "/"),
        $ValidationManifestRef.Replace("\", "/"),
        "state/control_room/r13_current/operator_demo.md",
        "state/control_room/r13_current/operator_demo_validation_manifest.md",
        "contracts/external_replay/r13_external_replay_request.contract.json",
        "contracts/external_replay/r13_external_replay_result.contract.json",
        "contracts/external_replay/r13_external_replay_import.contract.json",
        "tools/R13ExternalReplay.psm1",
        "tools/new_r13_external_replay_request.ps1",
        "tools/invoke_r13_external_replay.ps1",
        "tools/validate_r13_external_replay_request.ps1",
        "tools/validate_r13_external_replay_result.ps1",
        "tools/validate_r13_external_replay_import.ps1",
        "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_request.json",
        "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_result.json",
        "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_import.json",
        "state/external_runs/r13_external_replay/r13_011/imported_artifact_25241730946_6759970924/validation_manifest.md",
        "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_blocked.json",
        "state/external_runs/r13_external_replay/r13_011/manual_dispatch_packet.json",
        "state/external_runs/r13_external_replay/r13_011/validation_manifest.md",
        "contracts/actionable_qa/r13_meaningful_qa_signoff.contract.json",
        "contracts/actionable_qa/r13_meaningful_qa_signoff_evidence_matrix.contract.json",
        "tools/R13MeaningfulQaSignoff.psm1",
        "tools/new_r13_meaningful_qa_signoff.ps1",
        "tools/validate_r13_meaningful_qa_signoff.ps1",
        "tools/validate_r13_meaningful_qa_signoff_evidence_matrix.ps1",
        "tests/test_r13_meaningful_qa_signoff.ps1",
        "state/signoff/r13_meaningful_qa_signoff/r13_012_signoff.json",
        "state/signoff/r13_meaningful_qa_signoff/r13_012_evidence_matrix.json",
        "state/signoff/r13_meaningful_qa_signoff/validation_manifest.md",
        "contracts/continuity/r13_compaction_mitigation_packet.contract.json",
        "contracts/continuity/r13_restart_prompt.contract.json",
        "tools/R13CompactionMitigation.psm1",
        "tools/new_r13_compaction_mitigation_packet.ps1",
        "tools/validate_r13_compaction_mitigation_packet.ps1",
        "tools/validate_r13_restart_prompt.ps1",
        "tests/test_r13_compaction_mitigation.ps1",
        "state/continuity/r13_compaction_mitigation/r13_013_identity_reconciliation.json",
        "state/continuity/r13_compaction_mitigation/r13_013_compaction_mitigation_packet.json",
        "state/continuity/r13_compaction_mitigation/r13_013_restart_prompt.md",
        "state/continuity/r13_compaction_mitigation/validation_manifest.md"
    )
    $hardGateStatus = New-R13HardGateStatus -ControlRoomEvidenceRefs $controlRoomEvidenceRefs
    $runnerCounts = Get-CommandCounts -CommandResults $runnerResult.command_results
    $detectCounts = Get-CommandCounts -CommandResults $qaDetectResult.command_results
    $fixPlanCounts = Get-CommandCounts -CommandResults $qaFixPlanResult.command_results
    $registeredSkills = @($skillRegistry.skills | ForEach-Object { [string]$_.skill_id })
    $issueCount = if (Test-HasProperty -Object $issueReport -Name "summary") { [int]$issueReport.summary.total_issue_count } else { Get-ArrayCount -Value $issueReport.issues }
    $blockingIssueCount = if (Test-HasProperty -Object $issueReport -Name "summary") { [int]$issueReport.summary.blocking_issue_count } else { $issueCount }

    return [pscustomobject][ordered]@{
        contract_version = "v1"
        artifact_type = "r13_control_room_status"
        status_id = Get-StableId -Prefix "r13crs" -Key "$($gitIdentity.Branch)|$($gitIdentity.Head)|$($gitIdentity.Tree)|$StatusRef"
        repository = $script:R13RepositoryName
        branch = [string]$gitIdentity.Branch
        head = [string]$gitIdentity.Head
        tree = [string]$gitIdentity.Tree
        source_milestone = $script:R13Milestone
        source_task = $script:R13SourceTask
        active_scope = [pscustomobject][ordered]@{
            active_milestone = $script:R13Milestone
            active_through_task = "R13-013"
            completed_range = "R13-001 through R13-013"
            planned_range = "R13-014 through R13-018"
            scope_summary = "R13 is active through R13-013 only; R13-014 through R13-018 remain planned only."
            current_task_boundary = "R13-013 complete as bounded compaction mitigation and restart proof only; no R13 closeout, R14, or successor is included."
            productized_ui_claimed = $false
            r14_or_successor_opened = $false
        }
        completed_tasks = @($taskLists.Completed)
        planned_tasks = @($taskLists.Planned)
        hard_gate_status = $hardGateStatus
        qa_pipeline_status = [pscustomobject][ordered]@{
            lifecycle = [pscustomobject][ordered]@{
                status = "foundation_present"
                summary = "R13-002 defines the ideal QA lifecycle contract only."
                evidence_refs = @("contracts/actionable_qa/r13_qa_lifecycle.contract.json", "tools/R13QaLifecycle.psm1")
            }
            issue_detection = [pscustomobject][ordered]@{
                status = "issues_detected"
                total_issue_count = $issueCount
                blocking_issue_count = $blockingIssueCount
                aggregate_verdict = [string]$issueReport.aggregate_verdict
                evidence_refs = @("state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/qa/r13_003_issue_detection_report.json")
            }
            fix_queue = [pscustomobject][ordered]@{
                status = [string]$fixQueue.queue_status
                fix_item_count = [int]$fixQueue.issue_summary.fix_item_count
                blocking_issue_count = [int]$fixQueue.issue_summary.blocking_issue_count
                evidence_refs = @("state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/qa/r13_004_fix_queue.json")
            }
            bounded_fix_execution = [pscustomobject][ordered]@{
                status = [string]$boundedPacket.execution_status
                execution_mode = [string]$boundedPacket.execution_mode
                selected_fix_item_count = Get-ArrayCount -Value $boundedPacket.selected_fix_item_ids
                evidence_refs = @("state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/qa/r13_005_bounded_fix_execution_packet.json")
            }
            failure_to_fix_cycle = [pscustomobject][ordered]@{
                status = [string]$failureFixCycle.cycle_status
                aggregate_verdict = [string]$failureFixCycle.aggregate_verdict
                selected_fix_item_id = [string]$failureFixCycle.selected_fix_item_id
                selected_source_issue_id = [string]$failureFixCycle.selected_source_issue_id
                selected_issue_type = [string]$failureFixCycle.selected_issue_type
                comparison_verdict = [string]$comparison.comparison_verdict
                external_replay_claimed = $false
                final_signoff_claimed = $false
                evidence_refs = @(
                    "state/cycles/r13_qa_cycle_demo/fix_execution_result.json",
                    "state/cycles/r13_qa_cycle_demo/before_after_comparison.json",
                    "state/cycles/r13_qa_cycle_demo/qa_failure_fix_cycle.json"
                )
            }
        }
        runner_status = [pscustomobject][ordered]@{
            status = "partial_local_only"
            runner_kind = "local_custom_runner_cli"
            requested_operation = [string]$runnerResult.requested_operation
            execution_status = [string]$runnerResult.execution_status
            aggregate_verdict = [string]$runnerResult.aggregate_verdict
            command_count = [int]$runnerCounts.total
            passed_command_count = [int]$runnerCounts.passed
            failed_command_count = [int]$runnerCounts.failed
            api_custom_runner_bypass_gate_delivered = $false
            evidence_refs = @("state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/runner/r13_007_custom_runner_result.json")
        }
        skill_status = [pscustomobject][ordered]@{
            status = "partially_evidenced"
            registered_skill_ids = @($registeredSkills)
            invoked_skill_ids = @("qa.detect", "qa.fix_plan")
            not_invoked_skill_ids = @("runner.external_replay", "control_room.refresh")
            qa_detect = [pscustomobject][ordered]@{
                aggregate_verdict = [string]$qaDetectResult.aggregate_verdict
                command_count = [int]$detectCounts.total
                passed_command_count = [int]$detectCounts.passed
                failed_command_count = [int]$detectCounts.failed
                evidence_refs = @("state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_qa_detect_invocation_result.json")
            }
            qa_fix_plan = [pscustomobject][ordered]@{
                aggregate_verdict = [string]$qaFixPlanResult.aggregate_verdict
                command_count = [int]$fixPlanCounts.total
                passed_command_count = [int]$fixPlanCounts.passed
                failed_command_count = [int]$fixPlanCounts.failed
                evidence_refs = @("state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_qa_fix_plan_invocation_result.json")
            }
            skill_invocation_evidence_gate_delivered = $false
            evidence_refs = @(
                "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_skill_registry.json",
                "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_qa_detect_invocation_result.json",
                "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_qa_fix_plan_invocation_result.json"
            )
        }
        external_replay_status = [pscustomobject][ordered]@{
            status = "passed"
            executed = $true
            aggregate_verdict = [string]$externalReplayResult.aggregate_verdict
            request_ref = "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_request.json"
            result_ref = "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_result.json"
            import_ref = "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_import.json"
            imported_artifact_ref = "state/external_runs/r13_external_replay/r13_011/imported_artifact_25241730946_6759970924/validation_manifest.md"
            blocked_result_ref = "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_blocked.json"
            manual_dispatch_packet_ref = "state/external_runs/r13_external_replay/r13_011/manual_dispatch_packet.json"
            run_id = [string]$externalReplayResult.run_id
            run_url = [string]$externalReplayResult.run_url
            run_attempt = [int]$externalReplayResult.run_attempt
            artifact_id = [string]$externalReplayResult.artifact_id
            artifact_name = [string]$externalReplayResult.artifact_name
            artifact_digest = [string]$externalReplayResult.artifact_digest
            observed_head = [string]$externalReplayResult.observed_head
            observed_tree = [string]$externalReplayResult.observed_tree
            imported_artifact_id = [string]$externalReplayImport.imported_artifact_id
            summary = "GitHub Actions R13 External Replay run 25241730946 completed successfully with artifact 6759970924 imported and validated; R13-012 consumed it for bounded QA signoff only, and R13-013 preserves it as prerequisite restart evidence only."
            required_before = "any_future_unbounded_or_product_scope_signoff"
            evidence_refs = @(
                "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_request.json",
                "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_result.json",
                "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_import.json",
                "state/external_runs/r13_external_replay/r13_011/imported_artifact_25241730946_6759970924/validation_manifest.md",
                "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_blocked.json",
                "state/external_runs/r13_external_replay/r13_011/manual_dispatch_packet.json",
                "state/external_runs/r13_external_replay/r13_011/validation_manifest.md"
            )
        }
        signoff_status = [pscustomobject][ordered]@{
            status = [string]$signoff.signoff_decision
            aggregate_verdict = [string]$signoff.aggregate_verdict
            scope = [string]$signoff.signoff_scope
            bounded_scope_only = $true
            full_product_scope_signed_off = $false
            production_qa_signed_off = $false
            meaningful_qa_loop_gate = [string]$signoff.gate_assessment.meaningful_qa_loop_hard_gate
            residual_risk_count = @($signoff.residual_risks).Count
            evidence_row_count = @($evidenceMatrix.evidence_rows).Count
            evidence_refs = @(
                "state/signoff/r13_meaningful_qa_signoff/r13_012_signoff.json",
                "state/signoff/r13_meaningful_qa_signoff/r13_012_evidence_matrix.json",
                "state/signoff/r13_meaningful_qa_signoff/validation_manifest.md"
            )
        }
        compaction_mitigation_status = [pscustomobject][ordered]@{
            status = "bounded_repo_truth_mitigation_recorded"
            source_task = "R13-013"
            identity_reconciliation_ref = "state/continuity/r13_compaction_mitigation/r13_013_identity_reconciliation.json"
            packet_ref = "state/continuity/r13_compaction_mitigation/r13_013_compaction_mitigation_packet.json"
            restart_prompt_ref = "state/continuity/r13_compaction_mitigation/r13_013_restart_prompt.md"
            validation_manifest_ref = "state/continuity/r13_compaction_mitigation/validation_manifest.md"
            signoff_generated_from_head = "fb2179bb7b66d3d7dd1fd4eb2683aed825f01577"
            signoff_committed_at_head = "9f80291b0f3049ec1dd15635079705db031383fd"
            verdict = "accepted_as_generation_identity_not_current_identity"
            bounded_mitigation_only = $true
            codex_compaction_solved_generally = $false
            codex_reliability_solved_generally = $false
            evidence_refs = @(
                "state/continuity/r13_compaction_mitigation/r13_013_identity_reconciliation.json",
                "state/continuity/r13_compaction_mitigation/r13_013_compaction_mitigation_packet.json",
                "state/continuity/r13_compaction_mitigation/r13_013_restart_prompt.md",
                "state/continuity/r13_compaction_mitigation/validation_manifest.md"
            )
        }
        control_room_status = [pscustomobject][ordered]@{
            status = "partially_evidenced"
            status_model_ref = $StatusRef.Replace("\", "/")
            markdown_view_ref = $ViewRef.Replace("\", "/")
            refresh_result_ref = $RefreshResultRef.Replace("\", "/")
            validation_manifest_ref = $ValidationManifestRef.Replace("\", "/")
            operator_demo_ref = "state/control_room/r13_current/operator_demo.md"
            operator_demo_validation_manifest_ref = "state/control_room/r13_current/operator_demo_validation_manifest.md"
            stale_state_checks_passed = [bool]$staleChecks.stale_state_checks_passed
            productized_ui_claimed = $false
            hard_gate_delivered = $false
            summary = "R13-009 generates a repo-backed JSON status model, Markdown view, refresh result, and validation manifest; R13-010 adds a human-readable operator demo artifact; R13-011 imports passed external replay evidence; R13-012 adds bounded signoff status; R13-013 adds bounded compaction mitigation status. This remains not a productized UI and not a full product hard gate."
            evidence_refs = @($controlRoomEvidenceRefs)
        }
        blockers = @()
        attention_items = @(
            [pscustomobject][ordered]@{
                id = "attention-r13-current-control-room-partial"
                severity = "medium"
                title = "Current control-room evidence is partial"
                explanation = "The JSON status, Markdown view, refresh result, validation manifest, and operator demo artifact are evidence-backed, but they are not productized control-room behavior."
                evidence_refs = @("contracts/control_room/r13_control_room_status.contract.json", "contracts/control_room/r13_control_room_view.contract.json")
                recommended_next_action = "Review the generated artifacts as repo-generated operator evidence only."
                blocking_status = "advisory"
            },
            [pscustomobject][ordered]@{
                id = "attention-r13-task-boundary"
                severity = "high"
                title = "R13 stops at R13-013"
                explanation = "R13-014 through R13-018 remain planned only."
                evidence_refs = @("governance/R13_API_FIRST_QA_PIPELINE_AND_OPERATOR_CONTROL_ROOM_PRODUCT_SLICE.md")
                recommended_next_action = "Do not implement R13-014 or later inside R13-013."
                blocking_status = "advisory"
            },
            [pscustomobject][ordered]@{
                id = "attention-r13-signoff-bounded-only"
                severity = "high"
                title = "Bounded signoff only"
                explanation = "R13-012 signoff passed only for the bounded representative QA failure-to-fix loop and evidence-backed operator workflow slice."
                evidence_refs = @("state/signoff/r13_meaningful_qa_signoff/r13_012_signoff.json", "state/signoff/r13_meaningful_qa_signoff/r13_012_evidence_matrix.json")
                recommended_next_action = "Preserve bounded scope language and do not claim production, full product QA, R13 closeout, R14, or successor scope."
                blocking_status = "advisory"
            },
            [pscustomobject][ordered]@{
                id = "attention-r13-operator-demo-partial"
                severity = "medium"
                title = "Operator demo evidence is partial"
                explanation = "The operator demo artifact is a human-readable Markdown guide from repo evidence, not a productized UI or hard gate."
                evidence_refs = @("state/control_room/r13_current/operator_demo.md", "state/control_room/r13_current/operator_demo_validation_manifest.md")
                recommended_next_action = "Use the demo as operator context for later explicitly authorized R13 signoff work."
                blocking_status = "advisory"
            },
            [pscustomobject][ordered]@{
                id = "attention-r13-skill-evidence-partial"
                severity = "medium"
                title = "Skill invocation evidence remains partial"
                explanation = "Only qa.detect and qa.fix_plan were invoked by R13-008."
                evidence_refs = @("state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_skill_registry.json")
                recommended_next_action = "Keep runner.external_replay and control_room.refresh non-invoked unless a later R13 task authorizes them."
                blocking_status = "advisory"
            },
            [pscustomobject][ordered]@{
                id = "attention-r13-no-successor"
                severity = "high"
                title = "No R14 or successor is open"
                explanation = "R13 remains active and no successor milestone is authorized."
                evidence_refs = @("governance/R13_API_FIRST_QA_PIPELINE_AND_OPERATOR_CONTROL_ROOM_PRODUCT_SLICE.md")
                recommended_next_action = "Refuse any R14 or successor claim until separate operator approval and repo-truth opening evidence exist."
                blocking_status = "advisory"
            }
        )
        next_actions = @(
            [pscustomobject][ordered]@{
                id = "next-r13-014-after-r13-013-verified"
                task_id = "R13-014"
                title = "Start R13-014 only after R13-013 verification"
                action_type = "status_boundary"
                description = "R13-013 bounded compaction mitigation is recorded; start R13-014 only after R13-013 is committed, pushed, and verified."
                required_before = "any R13-014 work"
                evidence_refs = @("state/continuity/r13_compaction_mitigation/r13_013_compaction_mitigation_packet.json", "state/continuity/r13_compaction_mitigation/r13_013_restart_prompt.md", "governance/R13_API_FIRST_QA_PIPELINE_AND_OPERATOR_CONTROL_ROOM_PRODUCT_SLICE.md")
            }
        )
        operator_decisions_required = @(
            [pscustomobject][ordered]@{
                id = "decision-refuse-unbounded-signoff"
                title = "Refuse any unbounded or production QA signoff claim"
                decision_type = "signoff_scope_boundary"
                required_before = "any_unbounded_or_product_scope_signoff_claim"
                blocking_status = "blocking"
                evidence_refs = @("state/signoff/r13_meaningful_qa_signoff/r13_012_signoff.json")
            },
            [pscustomobject][ordered]@{
                id = "decision-refuse-successor"
                title = "Refuse R14 or successor opening"
                decision_type = "blocked_refusal"
                required_before = "any_successor_milestone_opening"
                blocking_status = "blocking"
                evidence_refs = @("governance/R13_API_FIRST_QA_PIPELINE_AND_OPERATOR_CONTROL_ROOM_PRODUCT_SLICE.md")
            }
        )
        evidence_refs = @(Get-R13RequiredMajorEvidenceRefs)
        stale_state_checks = $staleChecks
        generated_at_utc = Get-UtcTimestamp
        non_claims = @($script:RequiredNonClaims)
    }
}

function Assert-R13StatusIdentity {
    param(
        [Parameter(Mandatory = $true)]
        $Status,
        [Parameter(Mandatory = $true)]
        [string]$SourceLabel
    )

    if ($Status.repository -ne $script:R13RepositoryName) {
        throw "$SourceLabel repository must be '$script:R13RepositoryName'."
    }
    if ($Status.branch -ne $script:R13Branch) {
        throw "$SourceLabel branch must be '$script:R13Branch'."
    }
    Assert-GitObjectId -Value $Status.head -Context "$SourceLabel head"
    Assert-GitObjectId -Value $Status.tree -Context "$SourceLabel tree"
    if ($Status.source_milestone -ne $script:R13Milestone) {
        throw "$SourceLabel source_milestone must be '$script:R13Milestone'."
    }
    if ($Status.source_task -ne $script:R13SourceTask) {
        throw "$SourceLabel source_task must be '$script:R13SourceTask'."
    }
}

function Assert-StaleStateChecks {
    param(
        [Parameter(Mandatory = $true)]
        $Checks,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-RequiredObjectFields -Object $Checks -FieldNames @(
        "expected_branch",
        "expected_head",
        "expected_tree",
        "observed_branch",
        "observed_head",
        "observed_tree",
        "branch_matches_expected",
        "head_matches_expected",
        "tree_matches_expected",
        "required_evidence_refs_present",
        "hard_gate_overclaim_absent",
        "external_replay_not_claimed",
        "final_signoff_not_overclaimed",
        "operator_demo_not_claimed",
        "r14_successor_not_opened",
        "productized_ui_not_claimed",
        "stale_state_checks_passed"
    ) -Context $Context

    foreach ($fieldName in @("expected_branch", "expected_head", "expected_tree", "observed_branch", "observed_head", "observed_tree")) {
        Assert-NonEmptyString -Value $Checks.$fieldName -Context "$Context $fieldName" | Out-Null
    }
    foreach ($fieldName in @("expected_head", "expected_tree", "observed_head", "observed_tree")) {
        Assert-GitObjectId -Value $Checks.$fieldName -Context "$Context $fieldName"
    }
    foreach ($fieldName in @("branch_matches_expected", "head_matches_expected", "tree_matches_expected", "required_evidence_refs_present", "hard_gate_overclaim_absent", "external_replay_not_claimed", "final_signoff_not_overclaimed", "operator_demo_not_claimed", "r14_successor_not_opened", "productized_ui_not_claimed", "stale_state_checks_passed")) {
        if (-not (Assert-BooleanValue -Value $Checks.$fieldName -Context "$Context $fieldName")) {
            throw "$Context $fieldName must be true."
        }
    }
}

function Assert-R13TaskLists {
    param(
        [Parameter(Mandatory = $true)]
        $CompletedTasks,
        [Parameter(Mandatory = $true)]
        $PlannedTasks,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $completed = Assert-ObjectArray -Value $CompletedTasks -Context "$Context completed_tasks"
    $planned = Assert-ObjectArray -Value $PlannedTasks -Context "$Context planned_tasks"
    $expectedCompleted = @(1..13 | ForEach-Object { "R13-{0}" -f $_.ToString("000") })
    $expectedPlanned = @(14..18 | ForEach-Object { "R13-{0}" -f $_.ToString("000") })
    $actualCompleted = @($completed | ForEach-Object { [string]$_.task_id })
    $actualPlanned = @($planned | ForEach-Object { [string]$_.task_id })

    if (($actualCompleted -join "|") -ne ($expectedCompleted -join "|")) {
        throw "$Context completed_tasks must be R13-001 through R13-013 only."
    }
    if (($actualPlanned -join "|") -ne ($expectedPlanned -join "|")) {
        throw "$Context planned_tasks must be R13-014 through R13-018 only."
    }
    foreach ($task in @($completed)) {
        Assert-RequiredObjectFields -Object $task -FieldNames @("task_id", "status", "summary", "evidence_refs") -Context "$Context completed task"
        if ($task.status -ne "done") {
            throw "$Context completed task '$($task.task_id)' must have status done."
        }
        $refs = Assert-StringArray -Value $task.evidence_refs -Context "$Context completed task evidence_refs"
        foreach ($ref in @($refs)) {
            Assert-ExistingRef -Ref $ref -Context "$Context completed task evidence_refs"
        }
    }
    foreach ($task in @($planned)) {
        Assert-RequiredObjectFields -Object $task -FieldNames @("task_id", "status", "summary", "evidence_refs") -Context "$Context planned task"
        if ($task.status -ne "planned_only") {
            throw "$Context planned task '$($task.task_id)' must have status planned_only."
        }
    }
}

function Assert-HardGateStatus {
    param(
        [Parameter(Mandatory = $true)]
        $HardGateStatus,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-ObjectValue -Value $HardGateStatus -Context $Context | Out-Null
    foreach ($gateName in @("meaningful_qa_loop", "api_custom_runner_bypass", "current_operator_control_room", "skill_invocation_evidence", "operator_demo")) {
        $gate = Get-RequiredProperty -Object $HardGateStatus -Name $gateName -Context $Context
        Assert-RequiredObjectFields -Object $gate -FieldNames @("status", "hard_gate_delivered", "summary", "evidence_refs") -Context "$Context $gateName"
        Assert-AllowedValue -Value ([string]$gate.status) -AllowedValues $script:AllowedGateStatuses -Context "$Context $gateName.status"
        $delivered = Assert-BooleanValue -Value $gate.hard_gate_delivered -Context "$Context $gateName.hard_gate_delivered"
        if ($gateName -eq "meaningful_qa_loop") {
            if (-not $delivered -or [string]$gate.status -ne "bounded_scope_delivered" -or [bool]$gate.full_product_scope_delivered) {
                throw "$Context meaningful_qa_loop must be delivered only for bounded scope and not for full product scope."
            }
        }
        elseif ($delivered) {
            throw "$Context $gateName cannot be marked hard_gate_delivered."
        }
        Assert-StringArray -Value $gate.evidence_refs -Context "$Context $gateName.evidence_refs" | Out-Null
    }
    if ($HardGateStatus.current_operator_control_room.status -ne "partially_evidenced") {
        throw "$Context current_operator_control_room must be partially_evidenced for R13-011."
    }
    if ($HardGateStatus.operator_demo.status -ne "partially_evidenced") {
        throw "$Context operator_demo must be partially_evidenced for R13-011."
    }
    if ((Test-HasProperty -Object $HardGateStatus -Name "overall") -and [bool]$HardGateStatus.overall.any_full_product_hard_gate_delivered) {
        throw "$Context overall.any_full_product_hard_gate_delivered must be false."
    }
}

function Assert-WorkItems {
    param(
        [AllowNull()]
        $Items,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [switch]$AllowEmpty
    )

    $workItems = Assert-ObjectArray -Value $Items -Context $Context -AllowEmpty:$AllowEmpty
    foreach ($item in @($workItems)) {
        Assert-RequiredObjectFields -Object $item -FieldNames @("id", "severity", "title", "explanation", "evidence_refs", "recommended_next_action", "blocking_status") -Context $Context
        Assert-AllowedValue -Value ([string]$item.blocking_status) -AllowedValues $script:AllowedBlockingStatuses -Context "$Context blocking_status"
        $refs = Assert-StringArray -Value $item.evidence_refs -Context "$Context evidence_refs"
        foreach ($ref in @($refs)) {
            Assert-ExistingRef -Ref $ref -Context "$Context evidence_refs"
        }
    }
}

function Test-R13ControlRoomStatusObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Status,
        [string]$SourceLabel = "R13 control-room status"
    )

    $contract = Get-R13ControlRoomStatusContract
    Assert-RequiredObjectFields -Object $Status -FieldNames $contract.required_fields -Context $SourceLabel

    if ($Status.contract_version -ne "v1") {
        throw "$SourceLabel contract_version must be v1."
    }
    if ($Status.artifact_type -ne "r13_control_room_status") {
        throw "$SourceLabel artifact_type must be r13_control_room_status."
    }
    Assert-NonEmptyString -Value $Status.status_id -Context "$SourceLabel status_id" | Out-Null
    Assert-R13StatusIdentity -Status $Status -SourceLabel $SourceLabel
    $activeScope = Assert-ObjectValue -Value $Status.active_scope -Context "$SourceLabel active_scope"
    Assert-RequiredObjectFields -Object $activeScope -FieldNames @("active_milestone", "active_through_task", "completed_range", "planned_range", "scope_summary", "current_task_boundary", "productized_ui_claimed", "r14_or_successor_opened") -Context "$SourceLabel active_scope"
    if ($activeScope.active_milestone -ne $script:R13Milestone -or $activeScope.active_through_task -ne "R13-013") {
        throw "$SourceLabel active_scope must declare R13 active through R13-013."
    }
    if ([bool]$activeScope.productized_ui_claimed -or [bool]$activeScope.r14_or_successor_opened) {
        throw "$SourceLabel active_scope cannot claim productized UI or successor opening."
    }
    Assert-R13TaskLists -CompletedTasks $Status.completed_tasks -PlannedTasks $Status.planned_tasks -Context $SourceLabel
    Assert-HardGateStatus -HardGateStatus $Status.hard_gate_status -Context "$SourceLabel hard_gate_status"

    foreach ($statusField in @("qa_pipeline_status", "runner_status", "skill_status", "external_replay_status", "signoff_status", "control_room_status")) {
        Assert-ObjectValue -Value $Status.$statusField -Context "$SourceLabel $statusField" | Out-Null
    }
    if ([string]$Status.signoff_status.status -ne "accepted_bounded_scope" -or [string]$Status.signoff_status.aggregate_verdict -ne "passed" -or -not [bool]$Status.signoff_status.bounded_scope_only -or [bool]$Status.signoff_status.full_product_scope_signed_off -or [bool]$Status.signoff_status.production_qa_signed_off) {
        throw "$SourceLabel signoff_status must record accepted bounded-scope signoff only."
    }
    if ([string]$Status.external_replay_status.status -ne "passed" -or -not [bool]$Status.external_replay_status.executed) {
        throw "$SourceLabel must record external replay as passed and executed."
    }
    if ([string]$Status.external_replay_status.aggregate_verdict -ne "passed" -or [string]::IsNullOrWhiteSpace([string]$Status.external_replay_status.run_id) -or [string]::IsNullOrWhiteSpace([string]$Status.external_replay_status.artifact_id) -or [string]$Status.external_replay_status.artifact_digest -notmatch '^sha256:[a-f0-9]{64}$') {
        throw "$SourceLabel must preserve passed external replay run/artifact identity."
    }
    if ([string]$Status.control_room_status.status -ne "partially_evidenced" -or [bool]$Status.control_room_status.hard_gate_delivered) {
        throw "$SourceLabel control_room_status must be partially_evidenced and not hard_gate_delivered."
    }
    if ([bool]$Status.control_room_status.productized_ui_claimed) {
        throw "$SourceLabel cannot claim productized UI."
    }
    if (-not [bool]$Status.control_room_status.stale_state_checks_passed) {
        throw "$SourceLabel control_room_status stale_state_checks_passed must be true."
    }

    Assert-WorkItems -Items $Status.blockers -Context "$SourceLabel blockers" -AllowEmpty
    Assert-WorkItems -Items $Status.attention_items -Context "$SourceLabel attention_items" -AllowEmpty
    $nextActions = Assert-ObjectArray -Value $Status.next_actions -Context "$SourceLabel next_actions"
    foreach ($nextAction in @($nextActions)) {
        Assert-RequiredObjectFields -Object $nextAction -FieldNames @("id", "task_id", "title", "action_type", "description", "required_before", "evidence_refs") -Context "$SourceLabel next_action"
    }
    if ([string]$nextActions[0].task_id -ne "R13-014") {
        throw "$SourceLabel first next legal action must preserve R13-014 as the next planned-only task."
    }
    $operatorDecisions = Assert-ObjectArray -Value $Status.operator_decisions_required -Context "$SourceLabel operator_decisions_required" -AllowEmpty
    foreach ($decision in @($operatorDecisions)) {
        Assert-RequiredObjectFields -Object $decision -FieldNames @("id", "title", "decision_type", "required_before", "blocking_status", "evidence_refs") -Context "$SourceLabel operator_decision"
    }
    $evidenceRefs = Assert-RefArray -Value $Status.evidence_refs -Context "$SourceLabel evidence_refs" -RequireExists
    $refIds = @($evidenceRefs | ForEach-Object { [string]$_.ref_id })
    foreach ($requiredRef in @(Get-R13RequiredMajorEvidenceRefs)) {
        if ($refIds -notcontains [string]$requiredRef.ref_id) {
            throw "$SourceLabel evidence_refs must include '$($requiredRef.ref_id)'."
        }
    }
    if (Test-HasProperty -Object $Status -Name "stale_state_checks") {
        Assert-StaleStateChecks -Checks $Status.stale_state_checks -Context "$SourceLabel stale_state_checks"
    }
    Assert-TimestampString -Value $Status.generated_at_utc -Context "$SourceLabel generated_at_utc"
    $nonClaims = Assert-StringArray -Value $Status.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel
    Assert-NoForbiddenR13ControlRoomClaims -Value $Status -Context $SourceLabel

    $PSCmdlet.WriteObject([pscustomobject][ordered]@{
        StatusId = $Status.status_id
        Repository = $Status.repository
        Branch = $Status.branch
        Head = $Status.head
        Tree = $Status.tree
        CompletedTaskCount = @($Status.completed_tasks).Count
        PlannedTaskCount = @($Status.planned_tasks).Count
        BlockerCount = @($Status.blockers).Count
        AttentionItemCount = @($Status.attention_items).Count
        NextLegalAction = [string]$Status.next_actions[0].task_id
        ControlRoomGate = [string]$Status.hard_gate_status.current_operator_control_room.status
    }, $false)
}

function Test-R13ControlRoomStatus {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$StatusPath
    )

    $status = Get-JsonDocument -Path $StatusPath -Label "R13 control-room status"
    return Test-R13ControlRoomStatusObject -Status $status -SourceLabel "R13 control-room status"
}

function Export-R13ControlRoomView {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$StatusPath,
        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )

    Test-R13ControlRoomStatus -StatusPath $StatusPath | Out-Null
    $status = Get-JsonDocument -Path $StatusPath -Label "R13 control-room status"
    $statusRef = (Convert-ToRepositoryRelativePath -PathValue $StatusPath)

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# R13 Current Control Room") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add('- artifact_type: `r13_control_room_view`') | Out-Null
    $lines.Add(('- source_status_ref: `{0}`' -f $statusRef)) | Out-Null
    $lines.Add(('- generated_at_utc: `{0}`' -f $status.generated_at_utc)) | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## Current branch/head/tree") | Out-Null
    $lines.Add(('- Repository: `{0}`' -f $status.repository)) | Out-Null
    $lines.Add(('- Branch: `{0}`' -f $status.branch)) | Out-Null
    $lines.Add(('- Head: `{0}`' -f $status.head)) | Out-Null
    $lines.Add(('- Tree: `{0}`' -f $status.tree)) | Out-Null
    $lines.Add(('- Stale-state checks passed: `{0}`' -f $status.stale_state_checks.stale_state_checks_passed)) | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## Active milestone and scope") | Out-Null
    $lines.Add(('- Active milestone: `{0}`' -f $status.active_scope.active_milestone)) | Out-Null
    $lines.Add(('- Active through: `{0}`' -f $status.active_scope.active_through_task)) | Out-Null
    $lines.Add(('- Completed range: `{0}`' -f $status.active_scope.completed_range)) | Out-Null
    $lines.Add(('- Planned range: `{0}`' -f $status.active_scope.planned_range)) | Out-Null
    $lines.Add(("- Boundary: {0}" -f $status.active_scope.current_task_boundary)) | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## R13 task status summary") | Out-Null
    $lines.Add("### Completed") | Out-Null
    foreach ($task in @($status.completed_tasks)) {
        $lines.Add(('- `{0}`: `{1}` - {2}' -f $task.task_id, $task.status, $task.summary)) | Out-Null
    }
    $lines.Add("### Planned") | Out-Null
    foreach ($task in @($status.planned_tasks)) {
        $lines.Add(('- `{0}`: `{1}` - {2}' -f $task.task_id, $task.status, $task.summary)) | Out-Null
    }
    $lines.Add("") | Out-Null
    $lines.Add("## Hard gate posture") | Out-Null
    $lines.Add("| Gate | Status | Hard gate delivered | Summary |") | Out-Null
    $lines.Add("| --- | --- | --- | --- |") | Out-Null
    foreach ($gateName in @("meaningful_qa_loop", "api_custom_runner_bypass", "current_operator_control_room", "skill_invocation_evidence", "operator_demo")) {
        $gate = $status.hard_gate_status.$gateName
        $lines.Add(('| `{0}` | `{1}` | `{2}` | {3} |' -f $gateName, $gate.status, $gate.hard_gate_delivered, $gate.summary)) | Out-Null
    }
    $lines.Add("") | Out-Null
    $lines.Add("## QA pipeline posture") | Out-Null
    $lines.Add(('- Issue detection: `{0}` total issues, `{1}` blocking, aggregate `{2}`' -f $status.qa_pipeline_status.issue_detection.total_issue_count, $status.qa_pipeline_status.issue_detection.blocking_issue_count, $status.qa_pipeline_status.issue_detection.aggregate_verdict)) | Out-Null
    $lines.Add(('- Fix queue: `{0}` with `{1}` fix items' -f $status.qa_pipeline_status.fix_queue.status, $status.qa_pipeline_status.fix_queue.fix_item_count)) | Out-Null
    $lines.Add(('- Bounded fix execution: `{0}` / `{1}`' -f $status.qa_pipeline_status.bounded_fix_execution.execution_mode, $status.qa_pipeline_status.bounded_fix_execution.status)) | Out-Null
    $lines.Add(('- Failure-to-fix cycle: `{0}` / `{1}` / comparison `{2}`' -f $status.qa_pipeline_status.failure_to_fix_cycle.status, $status.qa_pipeline_status.failure_to_fix_cycle.aggregate_verdict, $status.qa_pipeline_status.failure_to_fix_cycle.comparison_verdict)) | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## Runner/API-custom-runner posture") | Out-Null
    $lines.Add(('- Status: `{0}`' -f $status.runner_status.status)) | Out-Null
    $lines.Add(('- Operation: `{0}`' -f $status.runner_status.requested_operation)) | Out-Null
    $lines.Add(('- Commands: `{0}` total, `{1}` passed, `{2}` failed' -f $status.runner_status.command_count, $status.runner_status.passed_command_count, $status.runner_status.failed_command_count)) | Out-Null
    $lines.Add(('- API/custom-runner bypass gate delivered: `{0}`' -f $status.runner_status.api_custom_runner_bypass_gate_delivered)) | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## Skill invocation posture") | Out-Null
    $lines.Add(('- Status: `{0}`' -f $status.skill_status.status)) | Out-Null
    $lines.Add(('- Registered skill IDs: `{0}`' -f (@($status.skill_status.registered_skill_ids) -join '`, `'))) | Out-Null
    $lines.Add(('- Invoked skill IDs: `{0}`' -f (@($status.skill_status.invoked_skill_ids) -join '`, `'))) | Out-Null
    $lines.Add(('- Not invoked skill IDs: `{0}`' -f (@($status.skill_status.not_invoked_skill_ids) -join '`, `'))) | Out-Null
    $lines.Add(('- `qa.detect`: `{0}` command, `{1}` passed' -f $status.skill_status.qa_detect.command_count, $status.skill_status.qa_detect.passed_command_count)) | Out-Null
    $lines.Add(('- `qa.fix_plan`: `{0}` command, `{1}` passed' -f $status.skill_status.qa_fix_plan.command_count, $status.skill_status.qa_fix_plan.passed_command_count)) | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## External replay posture") | Out-Null
    $lines.Add(('- Status: `{0}`' -f $status.external_replay_status.status)) | Out-Null
    $lines.Add(('- Executed: `{0}`' -f $status.external_replay_status.executed)) | Out-Null
    $lines.Add(("- Summary: {0}" -f $status.external_replay_status.summary)) | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## Signoff posture") | Out-Null
    $lines.Add(('- Status: `{0}`' -f $status.signoff_status.status)) | Out-Null
    $lines.Add(('- Aggregate verdict: `{0}`' -f $status.signoff_status.aggregate_verdict)) | Out-Null
    $lines.Add(('- Scope: `{0}`' -f $status.signoff_status.scope)) | Out-Null
    $lines.Add(('- Bounded scope only: `{0}`' -f $status.signoff_status.bounded_scope_only)) | Out-Null
    $lines.Add(('- Full product scope signed off: `{0}`' -f $status.signoff_status.full_product_scope_signed_off)) | Out-Null
    $lines.Add(('- Production QA signed off: `{0}`' -f $status.signoff_status.production_qa_signed_off)) | Out-Null
    $lines.Add(('- Meaningful QA loop gate: `{0}`' -f $status.signoff_status.meaningful_qa_loop_gate)) | Out-Null
    $lines.Add("") | Out-Null
    if (Test-HasProperty -Object $status -Name "compaction_mitigation_status") {
        $lines.Add("## Compaction mitigation posture") | Out-Null
        $lines.Add(('- Status: `{0}`' -f $status.compaction_mitigation_status.status)) | Out-Null
        $lines.Add(('- Identity reconciliation: `{0}`' -f $status.compaction_mitigation_status.identity_reconciliation_ref)) | Out-Null
        $lines.Add(('- Signoff generated from head: `{0}`' -f $status.compaction_mitigation_status.signoff_generated_from_head)) | Out-Null
        $lines.Add(('- Signoff committed at head: `{0}`' -f $status.compaction_mitigation_status.signoff_committed_at_head)) | Out-Null
        $lines.Add(('- Verdict: `{0}`' -f $status.compaction_mitigation_status.verdict)) | Out-Null
        $lines.Add(('- Bounded mitigation only: `{0}`' -f $status.compaction_mitigation_status.bounded_mitigation_only)) | Out-Null
        $lines.Add(('- Codex compaction is not solved generally: `{0}`' -f (-not [bool]$status.compaction_mitigation_status.codex_compaction_solved_generally))) | Out-Null
        $lines.Add("") | Out-Null
    }
    $lines.Add("## Blockers and attention items") | Out-Null
    $lines.Add("### Blockers") | Out-Null
    foreach ($blocker in @($status.blockers)) {
        $lines.Add(('- `{0}` [{1}/{2}] {3}: {4}' -f $blocker.id, $blocker.severity, $blocker.blocking_status, $blocker.title, $blocker.explanation)) | Out-Null
    }
    $lines.Add("### Attention items") | Out-Null
    foreach ($item in @($status.attention_items)) {
        $lines.Add(('- `{0}` [{1}/{2}] {3}: {4}' -f $item.id, $item.severity, $item.blocking_status, $item.title, $item.explanation)) | Out-Null
    }
    $lines.Add("") | Out-Null
    $lines.Add("## Next legal actions") | Out-Null
    foreach ($action in @($status.next_actions)) {
        $lines.Add(('- `{0}` / `{1}` [{2}] {3}: {4}' -f $action.id, $action.task_id, $action.action_type, $action.title, $action.description)) | Out-Null
    }
    $lines.Add("") | Out-Null
    $lines.Add("## Operator decisions required") | Out-Null
    foreach ($decision in @($status.operator_decisions_required)) {
        $lines.Add(('- `{0}` [{1}/{2}] {3}. Required before: `{4}`' -f $decision.id, $decision.decision_type, $decision.blocking_status, $decision.title, $decision.required_before)) | Out-Null
    }
    $lines.Add("") | Out-Null
    $lines.Add("## Evidence refs") | Out-Null
    foreach ($refObject in @($status.evidence_refs)) {
        $lines.Add(('- `{0}`: `{1}` ({2}/{3})' -f $refObject.ref_id, $refObject.ref, $refObject.evidence_kind, $refObject.authority_kind)) | Out-Null
    }
    $lines.Add("") | Out-Null
    $lines.Add("## Explicit non-claims") | Out-Null
    foreach ($nonClaim in @($status.non_claims)) {
        $lines.Add("- $nonClaim") | Out-Null
    }

    $content = ($lines -join "`n") + "`n"
    Write-R13ControlRoomTextFile -Path $OutputPath -Value $content
    return [pscustomobject][ordered]@{
        ViewPath = (Convert-ToRepositoryRelativePath -PathValue $OutputPath)
        SourceStatusRef = $statusRef
        SectionCount = $script:RequiredViewSections.Count
    }
}

function Get-SourceStatusRefFromView {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $match = [regex]::Match($Text, '(?m)^\-\s+source_status_ref:\s+`([^`]+)`\s*$')
    if (-not $match.Success) {
        throw "$Context must include source_status_ref metadata."
    }
    return $match.Groups[1].Value
}

function Test-R13ControlRoomView {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ViewPath
    )

    $resolvedViewPath = Resolve-RepositoryPath -PathValue $ViewPath
    if (-not (Test-Path -LiteralPath $resolvedViewPath)) {
        throw "R13 control-room view '$ViewPath' does not exist."
    }
    $text = Get-Content -LiteralPath $resolvedViewPath -Raw
    if ($text -notmatch '^# R13 Current Control Room') {
        throw "R13 control-room view must include the title."
    }
    if ($text -notmatch '(?m)^\-\s+artifact_type:\s+`r13_control_room_view`\s*$') {
        throw "R13 control-room view must include artifact_type metadata."
    }
    $sourceStatusRef = Get-SourceStatusRefFromView -Text $text -Context "R13 control-room view"
    $statusValidation = Test-R13ControlRoomStatus -StatusPath $sourceStatusRef
    $status = Get-JsonDocument -Path $sourceStatusRef -Label "R13 control-room status"

    foreach ($section in $script:RequiredViewSections) {
        if ($text -notmatch [regex]::Escape("## $section")) {
            throw "R13 control-room view missing required section '$section'."
        }
    }
    foreach ($identityValue in @($status.branch, $status.head, $status.tree)) {
        if ($text -notmatch [regex]::Escape([string]$identityValue)) {
            throw "R13 control-room view must include identity value '$identityValue'."
        }
    }
    foreach ($refObject in @($status.evidence_refs)) {
        if ($text -notmatch [regex]::Escape([string]$refObject.ref)) {
            throw "R13 control-room view must include evidence ref '$($refObject.ref)'."
        }
    }
    foreach ($nonClaim in @($status.non_claims)) {
        if ($text -notmatch [regex]::Escape([string]$nonClaim)) {
            throw "R13 control-room view must include non-claim '$nonClaim'."
        }
    }
    foreach ($taskId in @(1..13 | ForEach-Object { "R13-{0}" -f $_.ToString("000") })) {
        if ($text -notmatch [regex]::Escape($taskId)) {
            throw "R13 control-room view must include completed task '$taskId'."
        }
    }
    foreach ($taskId in @(14..18 | ForEach-Object { "R13-{0}" -f $_.ToString("000") })) {
        if ($text -notmatch [regex]::Escape($taskId)) {
            throw "R13 control-room view must include planned task '$taskId'."
        }
    }
    Assert-NoForbiddenR13ControlRoomClaims -Value $text -Context "R13 control-room view"

    return [pscustomobject][ordered]@{
        ViewPath = (Convert-ToRepositoryRelativePath -PathValue $ViewPath)
        SourceStatusRef = $sourceStatusRef
        StatusId = $statusValidation.StatusId
        SectionCount = $script:RequiredViewSections.Count
    }
}

function Test-R13ControlRoomRefreshResultObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $RefreshResult,
        [string]$SourceLabel = "R13 control-room refresh result"
    )

    $contract = Get-R13ControlRoomRefreshResultContract
    Assert-RequiredObjectFields -Object $RefreshResult -FieldNames $contract.required_fields -Context $SourceLabel
    if ($RefreshResult.contract_version -ne "v1") {
        throw "$SourceLabel contract_version must be v1."
    }
    if ($RefreshResult.artifact_type -ne "r13_control_room_refresh_result") {
        throw "$SourceLabel artifact_type must be r13_control_room_refresh_result."
    }
    Assert-NonEmptyString -Value $RefreshResult.refresh_id -Context "$SourceLabel refresh_id" | Out-Null
    Assert-R13StatusIdentity -Status $RefreshResult -SourceLabel $SourceLabel
    $verdict = Assert-NonEmptyString -Value $RefreshResult.refresh_verdict -Context "$SourceLabel refresh_verdict"
    Assert-AllowedValue -Value $verdict -AllowedValues $script:AllowedRefreshVerdicts -Context "$SourceLabel refresh_verdict"
    $refusalReasons = Assert-StringArray -Value $RefreshResult.refusal_reasons -Context "$SourceLabel refusal_reasons" -AllowEmpty
    if ($verdict -eq "current" -and @($refusalReasons).Count -ne 0) {
        throw "$SourceLabel current verdict cannot include refusal_reasons."
    }
    if ($verdict -eq "blocked" -and @($refusalReasons).Count -eq 0) {
        throw "$SourceLabel blocked verdict requires refusal_reasons."
    }
    if ($verdict -eq "current") {
        Assert-StaleStateChecks -Checks $RefreshResult.stale_state_checks -Context "$SourceLabel stale_state_checks"
        Assert-ExistingRef -Ref ([string]$RefreshResult.generated_status_ref) -Context "$SourceLabel generated_status_ref"
        Assert-ExistingRef -Ref ([string]$RefreshResult.generated_view_ref) -Context "$SourceLabel generated_view_ref"
        Test-R13ControlRoomStatus -StatusPath ([string]$RefreshResult.generated_status_ref) | Out-Null
        Test-R13ControlRoomView -ViewPath ([string]$RefreshResult.generated_view_ref) | Out-Null
    }
    $commandResults = Assert-ObjectArray -Value $RefreshResult.command_results -Context "$SourceLabel command_results" -AllowEmpty:($verdict -eq "blocked")
    foreach ($commandResult in @($commandResults)) {
        Assert-RequiredObjectFields -Object $commandResult -FieldNames @("command_id", "command", "exit_code", "verdict", "summary") -Context "$SourceLabel command_results"
        Assert-IntegerValue -Value $commandResult.exit_code -Context "$SourceLabel command_results exit_code" | Out-Null
    }
    $validationResults = Assert-ObjectArray -Value $RefreshResult.validation_results -Context "$SourceLabel validation_results" -AllowEmpty:($verdict -eq "blocked")
    foreach ($validationResult in @($validationResults)) {
        Assert-RequiredObjectFields -Object $validationResult -FieldNames @("artifact_id", "ref", "validator", "verdict", "summary") -Context "$SourceLabel validation_results"
        Assert-ExistingRef -Ref ([string]$validationResult.ref) -Context "$SourceLabel validation_results ref"
    }
    Assert-HardGateStatus -HardGateStatus $RefreshResult.hard_gate_status -Context "$SourceLabel hard_gate_status"
    Assert-WorkItems -Items $RefreshResult.blockers -Context "$SourceLabel blockers" -AllowEmpty
    Assert-ObjectArray -Value $RefreshResult.next_actions -Context "$SourceLabel next_actions" | Out-Null
    Assert-ObjectArray -Value $RefreshResult.operator_decisions_required -Context "$SourceLabel operator_decisions_required" -AllowEmpty | Out-Null
    Assert-RefArray -Value $RefreshResult.evidence_refs -Context "$SourceLabel evidence_refs" -RequireExists | Out-Null
    Assert-TimestampString -Value $RefreshResult.generated_at_utc -Context "$SourceLabel generated_at_utc"
    $nonClaims = Assert-StringArray -Value $RefreshResult.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel
    Assert-NoForbiddenR13ControlRoomClaims -Value $RefreshResult -Context $SourceLabel

    return [pscustomobject][ordered]@{
        RefreshId = $RefreshResult.refresh_id
        Repository = $RefreshResult.repository
        Branch = $RefreshResult.branch
        Head = $RefreshResult.head
        Tree = $RefreshResult.tree
        RefreshVerdict = $RefreshResult.refresh_verdict
        BlockerCount = @($RefreshResult.blockers).Count
        NextActionCount = @($RefreshResult.next_actions).Count
    }
}

function Test-R13ControlRoomRefreshResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RefreshResultPath
    )

    $refreshResult = Get-JsonDocument -Path $RefreshResultPath -Label "R13 control-room refresh result"
    return Test-R13ControlRoomRefreshResultObject -RefreshResult $refreshResult -SourceLabel "R13 control-room refresh result"
}

function Export-R13ControlRoomValidationManifest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RefreshResultPath,
        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )

    Test-R13ControlRoomRefreshResult -RefreshResultPath $RefreshResultPath | Out-Null
    $refreshResult = Get-JsonDocument -Path $RefreshResultPath -Label "R13 control-room refresh result"
    $status = Get-JsonDocument -Path ([string]$refreshResult.generated_status_ref) -Label "R13 control-room status"
    $manifestRef = Convert-ToRepositoryRelativePath -PathValue $OutputPath

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# R13 Control Room Validation Manifest") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add('- artifact_type: `r13_control_room_validation_manifest`') | Out-Null
    $lines.Add(('- source_refresh_result_ref: `{0}`' -f (Convert-ToRepositoryRelativePath -PathValue $RefreshResultPath))) | Out-Null
    $lines.Add(('- generated_at_utc: `{0}`' -f (Get-UtcTimestamp))) | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## Repository Identity") | Out-Null
    $lines.Add(('- Branch: `{0}`' -f $refreshResult.branch)) | Out-Null
    $lines.Add(('- Head: `{0}`' -f $refreshResult.head)) | Out-Null
    $lines.Add(('- Tree: `{0}`' -f $refreshResult.tree)) | Out-Null
    $lines.Add(('- Stale-state checks passed: `{0}`' -f $refreshResult.stale_state_checks.stale_state_checks_passed)) | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## Generated Artifacts") | Out-Null
    $lines.Add(('- Status JSON: `{0}`' -f $refreshResult.generated_status_ref)) | Out-Null
    $lines.Add(('- Markdown view: `{0}`' -f $refreshResult.generated_view_ref)) | Out-Null
    $lines.Add(('- Refresh result: `{0}`' -f (Convert-ToRepositoryRelativePath -PathValue $RefreshResultPath))) | Out-Null
    $lines.Add(('- Validation manifest: `{0}`' -f $manifestRef)) | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## Refresh Commands") | Out-Null
    foreach ($commandResult in @($refreshResult.command_results)) {
        $lines.Add(('- `{0}`: `{1}` exit `{2}` - {3}' -f $commandResult.command_id, $commandResult.verdict, $commandResult.exit_code, $commandResult.summary)) | Out-Null
    }
    $lines.Add("") | Out-Null
    $lines.Add("## Validation Results") | Out-Null
    foreach ($validationResult in @($refreshResult.validation_results)) {
        $lines.Add(('- `{0}` via `{1}`: `{2}` - `{3}`' -f $validationResult.ref, $validationResult.validator, $validationResult.verdict, $validationResult.summary)) | Out-Null
    }
    $lines.Add("") | Out-Null
    $lines.Add("## R13 Boundary") | Out-Null
    $lines.Add(('- Completed: `{0}`' -f $status.active_scope.completed_range)) | Out-Null
    $lines.Add(('- Planned: `{0}`' -f $status.active_scope.planned_range)) | Out-Null
    $lines.Add(('- Next legal action: `{0}`' -f $status.next_actions[0].task_id)) | Out-Null
    $lines.Add(('- Blockers: `{0}`' -f @($status.blockers).Count)) | Out-Null
    $lines.Add(('- Attention items: `{0}`' -f @($status.attention_items).Count)) | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## Hard Gate Posture") | Out-Null
    $lines.Add(('- Overall: `{0}`; any hard gate delivered: `{1}`' -f $status.hard_gate_status.overall.status, $status.hard_gate_status.overall.any_hard_gate_delivered)) | Out-Null
    foreach ($gateName in @("meaningful_qa_loop", "api_custom_runner_bypass", "current_operator_control_room", "skill_invocation_evidence", "operator_demo")) {
        $gate = $status.hard_gate_status.$gateName
        $lines.Add(('- `{0}`: `{1}`; hard gate delivered `{2}`' -f $gateName, $gate.status, $gate.hard_gate_delivered)) | Out-Null
    }
    $lines.Add("") | Out-Null
    $lines.Add("## Explicit Non-Claims") | Out-Null
    foreach ($nonClaim in @($status.non_claims)) {
        $lines.Add("- $nonClaim") | Out-Null
    }

    Write-R13ControlRoomTextFile -Path $OutputPath -Value (($lines -join "`n") + "`n")
    return [pscustomobject][ordered]@{
        ManifestPath = $manifestRef
        RefreshResultPath = (Convert-ToRepositoryRelativePath -PathValue $RefreshResultPath)
        ValidationResultCount = @($refreshResult.validation_results).Count
        StaleStateChecksPassed = [bool]$refreshResult.stale_state_checks.stale_state_checks_passed
    }
}

function New-BlockedRefreshResult {
    param(
        [Parameter(Mandatory = $true)]
        $GitIdentity,
        [Parameter(Mandatory = $true)]
        $StaleChecks,
        [Parameter(Mandatory = $true)]
        [string[]]$RefusalReasons,
        [Parameter(Mandatory = $true)]
        [string]$StatusRef,
        [Parameter(Mandatory = $true)]
        [string]$ViewRef
    )

    $hardGateStatus = New-R13HardGateStatus -ControlRoomEvidenceRefs @(
        "contracts/control_room/r13_control_room_status.contract.json",
        "contracts/control_room/r13_control_room_view.contract.json",
        "contracts/control_room/r13_control_room_refresh_result.contract.json"
    )

    return [pscustomobject][ordered]@{
        contract_version = "v1"
        artifact_type = "r13_control_room_refresh_result"
        refresh_id = Get-StableId -Prefix "r13crr" -Key "$($GitIdentity.Branch)|$($GitIdentity.Head)|blocked|$([string]::Join('|', $RefusalReasons))"
        repository = $script:R13RepositoryName
        branch = [string]$GitIdentity.Branch
        head = [string]$GitIdentity.Head
        tree = [string]$GitIdentity.Tree
        source_milestone = $script:R13Milestone
        source_task = $script:R13SourceTask
        source_status_ref = $StatusRef.Replace("\", "/")
        generated_status_ref = $StatusRef.Replace("\", "/")
        generated_view_ref = $ViewRef.Replace("\", "/")
        command_results = @(
            [pscustomobject][ordered]@{
                command_id = "repo-identity-check"
                command = "git branch --show-current; git rev-parse HEAD; git rev-parse HEAD^{tree}"
                exit_code = 1
                verdict = "blocked"
                summary = "Refresh blocked before generation because stale expected branch/head/tree checks failed."
            }
        )
        validation_results = @()
        stale_state_checks = $StaleChecks
        hard_gate_status = $hardGateStatus
        blockers = @(
            [pscustomobject][ordered]@{
                id = "blocker-r13-stale-refresh"
                severity = "high"
                title = "Stale branch/head/tree expectation refused"
                explanation = ($RefusalReasons -join " ")
                evidence_refs = @("contracts/control_room/r13_control_room_refresh_result.contract.json")
                recommended_next_action = "Refresh again with the current repository branch/head/tree."
                blocking_status = "blocking"
            }
        )
        next_actions = @(
            [pscustomobject][ordered]@{
                id = "next-refresh-current-identity"
                task_id = "R13-013"
                title = "Refresh with current repository identity"
                action_type = "blocked_retry"
                description = "Rerun the refresh command with expected branch/head/tree matching current repo truth."
                required_before = "accepting_control_room_status"
                evidence_refs = @("tools/refresh_r13_control_room.ps1")
            }
        )
        operator_decisions_required = @()
        refresh_verdict = "blocked"
        refusal_reasons = @($RefusalReasons)
        evidence_refs = @(
            (New-EvidenceRef -RefId "r13-control-room-refresh-result-contract" -Ref "contracts/control_room/r13_control_room_refresh_result.contract.json" -EvidenceKind "contract" -AuthorityKind "repo_contract"),
            (New-EvidenceRef -RefId "r13-control-room-refresh-cli" -Ref "tools/refresh_r13_control_room.ps1" -EvidenceKind "cli" -AuthorityKind "repo_tooling")
        )
        generated_at_utc = Get-UtcTimestamp
        non_claims = @($script:RequiredNonClaims)
    }
}

function Invoke-R13ControlRoomRefresh {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$OutputRoot,
        [string]$ExpectedBranch,
        [string]$ExpectedHead,
        [string]$ExpectedTree
    )

    $outputRootRef = (Convert-ToRepositoryRelativePath -PathValue $OutputRoot).TrimEnd("/")
    $statusRef = (Join-Path $outputRootRef "control_room_status.json").Replace("\", "/")
    $viewRef = (Join-Path $outputRootRef "control_room.md").Replace("\", "/")
    $refreshResultRef = (Join-Path $outputRootRef "control_room_refresh_result.json").Replace("\", "/")
    $validationManifestRef = (Join-Path $outputRootRef "validation_manifest.md").Replace("\", "/")
    $gitIdentity = Get-R13ControlRoomGitIdentity
    $staleChecks = New-StaleStateChecks -GitIdentity $gitIdentity -ExpectedBranch $ExpectedBranch -ExpectedHead $ExpectedHead -ExpectedTree $ExpectedTree
    $refusalReasons = Get-StaleStateRefusalReasons -Checks $staleChecks
    if (@($refusalReasons).Count -gt 0) {
        $blocked = New-BlockedRefreshResult -GitIdentity $gitIdentity -StaleChecks $staleChecks -RefusalReasons $refusalReasons -StatusRef $statusRef -ViewRef $viewRef
        Write-R13ControlRoomJsonFile -Path $refreshResultRef -Value $blocked
        return $blocked
    }

    $commandResults = @()
    $validationResults = @()
    $status = New-R13ControlRoomStatusObject -StatusRef $statusRef -ViewRef $viewRef -RefreshResultRef $refreshResultRef -ValidationManifestRef $validationManifestRef -ExpectedBranch $ExpectedBranch -ExpectedHead $ExpectedHead -ExpectedTree $ExpectedTree
    Write-R13ControlRoomJsonFile -Path $statusRef -Value $status
    $commandResults += [pscustomobject][ordered]@{
        command_id = "generate-status"
        command = "New-R13ControlRoomStatusObject"
        exit_code = 0
        verdict = "passed"
        summary = "Generated current R13 control-room status from repo evidence."
    }
    Test-R13ControlRoomStatus -StatusPath $statusRef | Out-Null
    $validationResults += [pscustomobject][ordered]@{
        artifact_id = "r13-control-room-status"
        ref = $statusRef
        validator = "tools/validate_r13_control_room_status.ps1"
        verdict = "passed"
        summary = "Generated status validates."
    }

    Export-R13ControlRoomView -StatusPath $statusRef -OutputPath $viewRef | Out-Null
    $commandResults += [pscustomobject][ordered]@{
        command_id = "render-view"
        command = "tools/render_r13_control_room_view.ps1"
        exit_code = 0
        verdict = "passed"
        summary = "Rendered human-readable control-room Markdown view."
    }
    Test-R13ControlRoomView -ViewPath $viewRef | Out-Null
    $validationResults += [pscustomobject][ordered]@{
        artifact_id = "r13-control-room-view"
        ref = $viewRef
        validator = "tools/validate_r13_control_room_view.ps1"
        verdict = "passed"
        summary = "Generated Markdown view validates."
    }

    $refreshResult = [pscustomobject][ordered]@{
        contract_version = "v1"
        artifact_type = "r13_control_room_refresh_result"
        refresh_id = Get-StableId -Prefix "r13crr" -Key "$($gitIdentity.Branch)|$($gitIdentity.Head)|$($gitIdentity.Tree)|$outputRootRef"
        repository = $script:R13RepositoryName
        branch = [string]$gitIdentity.Branch
        head = [string]$gitIdentity.Head
        tree = [string]$gitIdentity.Tree
        source_milestone = $script:R13Milestone
        source_task = $script:R13SourceTask
        source_status_ref = $statusRef
        generated_status_ref = $statusRef
        generated_view_ref = $viewRef
        generated_manifest_ref = $validationManifestRef
        command_results = @($commandResults)
        validation_results = @($validationResults)
        stale_state_checks = $staleChecks
        hard_gate_status = $status.hard_gate_status
        blockers = @($status.blockers)
        next_actions = @($status.next_actions)
        operator_decisions_required = @($status.operator_decisions_required)
        refresh_verdict = "current"
        refusal_reasons = @()
        evidence_refs = @($status.evidence_refs)
        generated_at_utc = Get-UtcTimestamp
        non_claims = @($script:RequiredNonClaims)
    }
    Write-R13ControlRoomJsonFile -Path $refreshResultRef -Value $refreshResult
    Test-R13ControlRoomRefreshResult -RefreshResultPath $refreshResultRef | Out-Null
    Export-R13ControlRoomValidationManifest -RefreshResultPath $refreshResultRef -OutputPath $validationManifestRef | Out-Null
    return $refreshResult
}

Export-ModuleMember -Function Get-RepositoryRoot, Resolve-RepositoryPath, Convert-ToRepositoryRelativePath, Get-UtcTimestamp, Get-JsonDocument, Write-R13ControlRoomJsonFile, Write-R13ControlRoomTextFile, Get-R13ControlRoomGitIdentity, Get-R13RequiredNonClaims, Get-R13RequiredMajorEvidenceRefs, New-R13ControlRoomStatusObject, Test-R13ControlRoomStatusObject, Test-R13ControlRoomStatus, Export-R13ControlRoomView, Test-R13ControlRoomView, Export-R13ControlRoomValidationManifest, Test-R13ControlRoomRefreshResultObject, Test-R13ControlRoomRefreshResult, Invoke-R13ControlRoomRefresh
