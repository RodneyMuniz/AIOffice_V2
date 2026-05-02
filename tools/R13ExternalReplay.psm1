Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$script:R13RepositoryName = "AIOffice_V2"
$script:R13RepositoryFullName = "RodneyMuniz/AIOffice_V2"
$script:R13Branch = "release/r13-api-first-qa-pipeline-and-operator-control-room-product-slice"
$script:R13Milestone = "R13 API-First QA Pipeline and Operator Control-Room Product Slice"
$script:R13SourceTask = "R13-011"
$script:GitObjectPattern = "^[a-f0-9]{40}$"
$script:TimestampPattern = "^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$"
$script:DigestPattern = "^sha256:[a-f0-9]{64}$"
$script:AllowedAggregateVerdicts = @("passed", "failed", "blocked")
$script:AllowedCommandVerdicts = @("passed", "failed", "blocked")
$script:RequestRequiredNonClaims = @(
    "R13-011 may record passed external replay only with actual external-runner evidence",
    "no external replay proof is claimed without run ID, artifact ID, artifact digest, and external-runner evidence",
    "no final QA signoff has occurred",
    "no R13 hard value gate fully delivered by R13-011",
    "no R14 or successor opening"
)
$script:ResultRequiredNonClaims = @(
    "R13-011 records external replay status only",
    "no final QA signoff has occurred",
    "no R13 hard value gate fully delivered by R13-011",
    "no R14 or successor opening"
)
$script:ImportRequiredNonClaims = @(
    "R13-011 imported artifact validation is external replay evidence only",
    "no final QA signoff has occurred",
    "no R13 hard value gate fully delivered by R13-011",
    "no R14 or successor opening"
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

function Write-R13ExternalReplayJsonFile {
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

function Write-R13ExternalReplayTextFile {
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

function Get-R13ExternalReplayGitIdentity {
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

    return ($Line -match '(?i)\b(no|not|without|cannot|must not|does not|do not|is not|are not|did not|non-claim|non_claim|refuse|refuses|blocked|planned|planned only|not yet delivered|not fully delivered|partial|partially|missing|required before|not executed|not delivered|future|pending|rejects|rejected|unavailable|fail closed|failed closed)\b')
}

function Assert-NoForbiddenR13ExternalReplayClaims {
    param(
        [Parameter(Mandatory = $true)]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($line in @(Get-StringLeaves -Value $Value)) {
        if ($line -match '(?i)\bfinal\s+QA\s+signoff\b|\bfinal\s+signoff\b|\bsign-off\b' -and $line -match '(?i)\b(accepted|complete|completed|delivered|passed|signed|occurred)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims final QA signoff. Offending text: $line"
        }
        if ($line -match '(?i)\b(hard\s+)?R13\s+hard\s+value\s+gate\b|\bhard\s+value\s+gate\b|\bmeaningful\s+QA\s+loop\b.*\b(delivered|complete|passed|proved)\b|\bAPI/custom-runner bypass\b.*\b(delivered|complete|passed|proved)\b|\bskill\s+invocation\s+evidence\b.*\b(delivered|complete|passed|proved)\b|\bcurrent\s+operator\s+control[- ]room\b.*\b(delivered|complete|passed|proved|fully delivered)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims R13 hard gate delivery. Offending text: $line"
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
        [string[]]$RequiredNonClaims,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($requiredNonClaim in $RequiredNonClaims) {
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

function Get-RequestInputRefs {
    return @(
        (New-EvidenceRef -RefId "r13-006-failure-fix-cycle" -Ref "state/cycles/r13_qa_cycle_demo/qa_failure_fix_cycle.json" -EvidenceKind "failure_fix_cycle" -AuthorityKind "repo_evidence"),
        (New-EvidenceRef -RefId "r13-006-before-after-comparison" -Ref "state/cycles/r13_qa_cycle_demo/before_after_comparison.json" -EvidenceKind "before_after_comparison" -AuthorityKind "repo_evidence"),
        (New-EvidenceRef -RefId "r13-010-control-room-status" -Ref "state/control_room/r13_current/control_room_status.json" -EvidenceKind "control_room_status" -AuthorityKind "repo_evidence"),
        (New-EvidenceRef -RefId "r13-010-control-room-view" -Ref "state/control_room/r13_current/control_room.md" -EvidenceKind "control_room_view" -AuthorityKind "repo_evidence"),
        (New-EvidenceRef -RefId "r13-010-control-room-refresh-result" -Ref "state/control_room/r13_current/control_room_refresh_result.json" -EvidenceKind "control_room_refresh_result" -AuthorityKind "repo_evidence"),
        (New-EvidenceRef -RefId "r13-010-operator-demo" -Ref "state/control_room/r13_current/operator_demo.md" -EvidenceKind "operator_demo" -AuthorityKind "repo_evidence"),
        (New-EvidenceRef -RefId "r13-010-operator-demo-validation-manifest" -Ref "state/control_room/r13_current/operator_demo_validation_manifest.md" -EvidenceKind "validation_manifest" -AuthorityKind "repo_evidence"),
        (New-EvidenceRef -RefId "r13-007-custom-runner-result" -Ref "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/runner/r13_007_custom_runner_result.json" -EvidenceKind "custom_runner_result" -AuthorityKind "repo_evidence"),
        (New-EvidenceRef -RefId "r13-008-skill-registry" -Ref "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_skill_registry.json" -EvidenceKind "skill_registry" -AuthorityKind "repo_evidence")
    )
}

function Get-RequestAllowedCommands {
    return @(
        [pscustomobject][ordered]@{
            command_id = "validate-r13-006-cycle"
            command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools\\validate_r13_qa_failure_fix_cycle.ps1 -CyclePath state\\cycles\\r13_qa_cycle_demo\\qa_failure_fix_cycle.json"
        },
        [pscustomobject][ordered]@{
            command_id = "validate-r13-006-comparison"
            command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools\\validate_r13_qa_before_after_comparison.ps1 -ComparisonPath state\\cycles\\r13_qa_cycle_demo\\before_after_comparison.json"
        },
        [pscustomobject][ordered]@{
            command_id = "validate-r13-control-room-status"
            command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools\\validate_r13_control_room_status.ps1 -StatusPath state\\control_room\\r13_current\\control_room_status.json"
        },
        [pscustomobject][ordered]@{
            command_id = "validate-r13-control-room-view"
            command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools\\validate_r13_control_room_view.ps1 -ViewPath state\\control_room\\r13_current\\control_room.md"
        },
        [pscustomobject][ordered]@{
            command_id = "validate-r13-control-room-refresh-result"
            command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools\\validate_r13_control_room_refresh_result.ps1 -RefreshResultPath state\\control_room\\r13_current\\control_room_refresh_result.json"
        },
        [pscustomobject][ordered]@{
            command_id = "validate-r13-operator-demo"
            command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools\\validate_r13_operator_demo.ps1 -DemoPath state\\control_room\\r13_current\\operator_demo.md"
        },
        [pscustomobject][ordered]@{
            command_id = "validate-r13-custom-runner-result"
            command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools\\validate_r13_custom_runner_result.ps1 -ResultPath state\\cycles\\r13_api_first_qa_pipeline_and_operator_control_room_product_slice\\runner\\r13_007_custom_runner_result.json"
        },
        [pscustomobject][ordered]@{
            command_id = "validate-r13-skill-registry"
            command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools\\validate_r13_skill_registry.ps1 -RegistryPath state\\cycles\\r13_api_first_qa_pipeline_and_operator_control_room_product_slice\\skills\\r13_008_skill_registry.json"
        }
    )
}

function New-R13ExternalReplayRequestObject {
    [CmdletBinding()]
    param(
        [string]$ExpectedResultRef = "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_result.json"
    )

    $gitIdentity = Get-R13ExternalReplayGitIdentity
    if ($gitIdentity.Branch -ne $script:R13Branch) {
        throw "Current branch must be '$script:R13Branch'."
    }

    $requestId = Get-StableId -Prefix "r13errq" -Key "$($gitIdentity.Branch)|$($gitIdentity.Head)|$($gitIdentity.Tree)|r13-011"
    return [pscustomobject][ordered]@{
        contract_version = "v1"
        artifact_type = "r13_external_replay_request"
        request_id = $requestId
        repository = $script:R13RepositoryName
        branch = [string]$gitIdentity.Branch
        head = [string]$gitIdentity.Head
        tree = [string]$gitIdentity.Tree
        source_milestone = $script:R13Milestone
        source_task = $script:R13SourceTask
        replay_scope = "r13_011_external_replay_after_operator_demo"
        input_refs = @(Get-RequestInputRefs)
        workflow_ref = "github_actions_manual_dispatch_or_equivalent_external_runner_required"
        allowed_commands = @(Get-RequestAllowedCommands)
        expected_artifact_name = "r13-external-replay-<run_id>-<run_attempt>"
        expected_result_ref = $ExpectedResultRef.Replace("\", "/")
        operator_approval = [pscustomobject][ordered]@{
            approval_status = "authorized_by_operator_task"
            approved_by = "operator_task_request"
            approved_at_utc = Get-UtcTimestamp
            approval_scope = "R13-011 external replay after operator demo, or fail closed with manual dispatch packet if authenticated dispatch is unavailable."
        }
        evidence_refs = @(
            (New-EvidenceRef -RefId "r13-external-replay-request-contract" -Ref "contracts/external_replay/r13_external_replay_request.contract.json" -EvidenceKind "contract" -AuthorityKind "repo_contract"),
            (New-EvidenceRef -RefId "r13-external-replay-result-contract" -Ref "contracts/external_replay/r13_external_replay_result.contract.json" -EvidenceKind "contract" -AuthorityKind "repo_contract"),
            (New-EvidenceRef -RefId "r13-external-replay-module" -Ref "tools/R13ExternalReplay.psm1" -EvidenceKind "module" -AuthorityKind "repo_tooling"),
            (New-EvidenceRef -RefId "r13-external-replay-request-generator" -Ref "tools/new_r13_external_replay_request.ps1" -EvidenceKind "cli" -AuthorityKind "repo_tooling"),
            (New-EvidenceRef -RefId "r13-authority" -Ref "governance/R13_API_FIRST_QA_PIPELINE_AND_OPERATOR_CONTROL_ROOM_PRODUCT_SLICE.md" -EvidenceKind "authority" -AuthorityKind "repo_governance")
        )
        refusal_reasons = @()
        created_at_utc = Get-UtcTimestamp
        non_claims = @($script:RequestRequiredNonClaims)
    }
}

function Test-R13ExternalReplayRequestObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Request,
        [string]$SourceLabel = "R13 external replay request"
    )

    $contract = Get-JsonDocument -Path "contracts/external_replay/r13_external_replay_request.contract.json" -Label "R13 external replay request contract"
    Assert-RequiredObjectFields -Object $Request -FieldNames $contract.required_fields -Context $SourceLabel
    if ($Request.contract_version -ne "v1") {
        throw "$SourceLabel contract_version must be v1."
    }
    if ($Request.artifact_type -ne "r13_external_replay_request") {
        throw "$SourceLabel artifact_type must be r13_external_replay_request."
    }
    $requestId = Assert-NonEmptyString -Value $Request.request_id -Context "$SourceLabel request_id"
    if ($Request.repository -ne $script:R13RepositoryName -or $Request.branch -ne $script:R13Branch -or $Request.source_milestone -ne $script:R13Milestone -or $Request.source_task -ne $script:R13SourceTask) {
        throw "$SourceLabel identity must bind to R13-011 on the R13 release branch."
    }
    Assert-GitObjectId -Value $Request.head -Context "$SourceLabel head"
    Assert-GitObjectId -Value $Request.tree -Context "$SourceLabel tree"
    $replayScope = Assert-NonEmptyString -Value $Request.replay_scope -Context "$SourceLabel replay_scope"
    Assert-AllowedValue -Value $replayScope -AllowedValues $contract.allowed_replay_scopes -Context "$SourceLabel replay_scope"
    $inputRefs = Assert-RefArray -Value $Request.input_refs -Context "$SourceLabel input_refs" -RequireExists
    Assert-NonEmptyString -Value $Request.workflow_ref -Context "$SourceLabel workflow_ref" | Out-Null
    $allowedCommands = Assert-ObjectArray -Value $Request.allowed_commands -Context "$SourceLabel allowed_commands"
    foreach ($command in @($allowedCommands)) {
        Assert-RequiredObjectFields -Object $command -FieldNames @("command_id", "command") -Context "$SourceLabel allowed_commands"
        Assert-NonEmptyString -Value $command.command_id -Context "$SourceLabel allowed_commands command_id" | Out-Null
        Assert-NonEmptyString -Value $command.command -Context "$SourceLabel allowed_commands command" | Out-Null
    }
    Assert-NonEmptyString -Value $Request.expected_artifact_name -Context "$SourceLabel expected_artifact_name" | Out-Null
    Assert-RepositoryRelativePath -PathValue (Assert-NonEmptyString -Value $Request.expected_result_ref -Context "$SourceLabel expected_result_ref") -Context "$SourceLabel expected_result_ref"
    Assert-RequiredObjectFields -Object $Request.operator_approval -FieldNames @("approval_status", "approved_by", "approved_at_utc", "approval_scope") -Context "$SourceLabel operator_approval"
    Assert-TimestampString -Value $Request.operator_approval.approved_at_utc -Context "$SourceLabel operator_approval.approved_at_utc"
    Assert-RefArray -Value $Request.evidence_refs -Context "$SourceLabel evidence_refs" -RequireExists | Out-Null
    Assert-StringArray -Value $Request.refusal_reasons -Context "$SourceLabel refusal_reasons" -AllowEmpty | Out-Null
    Assert-TimestampString -Value $Request.created_at_utc -Context "$SourceLabel created_at_utc"
    $nonClaims = Assert-StringArray -Value $Request.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -RequiredNonClaims $script:RequestRequiredNonClaims -Context $SourceLabel
    Assert-NoForbiddenR13ExternalReplayClaims -Value $Request -Context $SourceLabel

    return [pscustomobject][ordered]@{
        RequestId = $requestId
        Branch = [string]$Request.branch
        Head = [string]$Request.head
        Tree = [string]$Request.tree
        InputRefCount = @($inputRefs).Count
        CommandCount = @($allowedCommands).Count
        ReplayScope = $replayScope
    }
}

function Test-R13ExternalReplayRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RequestPath
    )

    $request = Get-JsonDocument -Path $RequestPath -Label "R13 external replay request"
    return Test-R13ExternalReplayRequestObject -Request $request -SourceLabel "R13 external replay request"
}

function Test-R13ExternalReplayResultObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Result,
        [string]$SourceLabel = "R13 external replay result"
    )

    $contract = Get-JsonDocument -Path "contracts/external_replay/r13_external_replay_result.contract.json" -Label "R13 external replay result contract"
    Assert-RequiredObjectFields -Object $Result -FieldNames $contract.required_fields -Context $SourceLabel
    if ($Result.contract_version -ne "v1") {
        throw "$SourceLabel contract_version must be v1."
    }
    if ($Result.artifact_type -ne "r13_external_replay_result") {
        throw "$SourceLabel artifact_type must be r13_external_replay_result."
    }
    $resultId = Assert-NonEmptyString -Value $Result.result_id -Context "$SourceLabel result_id"
    $requestId = Assert-NonEmptyString -Value $Result.request_id -Context "$SourceLabel request_id"
    if ($Result.repository -ne $script:R13RepositoryName -or $Result.branch -ne $script:R13Branch) {
        throw "$SourceLabel identity must bind to the R13 release branch."
    }
    Assert-GitObjectId -Value $Result.requested_head -Context "$SourceLabel requested_head"
    Assert-GitObjectId -Value $Result.requested_tree -Context "$SourceLabel requested_tree"
    Assert-GitObjectId -Value $Result.observed_head -Context "$SourceLabel observed_head"
    Assert-GitObjectId -Value $Result.observed_tree -Context "$SourceLabel observed_tree"
    Assert-NonEmptyString -Value $Result.workflow_name -Context "$SourceLabel workflow_name" | Out-Null
    $runId = Assert-StringValue -Value $Result.run_id -Context "$SourceLabel run_id"
    $runUrl = Assert-StringValue -Value $Result.run_url -Context "$SourceLabel run_url"
    Assert-IntegerValue -Value $Result.run_attempt -Context "$SourceLabel run_attempt" | Out-Null
    Assert-NonEmptyString -Value $Result.run_status -Context "$SourceLabel run_status" | Out-Null
    Assert-NonEmptyString -Value $Result.run_conclusion -Context "$SourceLabel run_conclusion" | Out-Null
    $artifactId = Assert-StringValue -Value $Result.artifact_id -Context "$SourceLabel artifact_id"
    Assert-StringValue -Value $Result.artifact_name -Context "$SourceLabel artifact_name" | Out-Null
    $artifactDigest = Assert-StringValue -Value $Result.artifact_digest -Context "$SourceLabel artifact_digest"
    $commandResults = Assert-ObjectArray -Value $Result.command_results -Context "$SourceLabel command_results" -AllowEmpty
    $passedCount = 0
    $failedCount = 0
    $blockedCount = 0
    foreach ($commandResult in @($commandResults)) {
        Assert-RequiredObjectFields -Object $commandResult -FieldNames @("command_id", "command", "exit_code", "verdict", "stdout_ref", "stderr_ref", "started_at_utc", "completed_at_utc") -Context "$SourceLabel command_results"
        Assert-NonEmptyString -Value $commandResult.command_id -Context "$SourceLabel command_results command_id" | Out-Null
        Assert-NonEmptyString -Value $commandResult.command -Context "$SourceLabel command_results command" | Out-Null
        Assert-IntegerValue -Value $commandResult.exit_code -Context "$SourceLabel command_results exit_code" | Out-Null
        $verdict = Assert-NonEmptyString -Value $commandResult.verdict -Context "$SourceLabel command_results verdict"
        Assert-AllowedValue -Value $verdict -AllowedValues $script:AllowedCommandVerdicts -Context "$SourceLabel command_results verdict"
        if ($verdict -eq "passed") { $passedCount += 1 }
        if ($verdict -eq "failed") { $failedCount += 1 }
        if ($verdict -eq "blocked") { $blockedCount += 1 }
        Assert-ExistingRef -Ref (Assert-NonEmptyString -Value $commandResult.stdout_ref -Context "$SourceLabel command_results stdout_ref") -Context "$SourceLabel command_results stdout_ref"
        Assert-ExistingRef -Ref (Assert-NonEmptyString -Value $commandResult.stderr_ref -Context "$SourceLabel command_results stderr_ref") -Context "$SourceLabel command_results stderr_ref"
        Assert-TimestampString -Value $commandResult.started_at_utc -Context "$SourceLabel command_results started_at_utc"
        Assert-TimestampString -Value $commandResult.completed_at_utc -Context "$SourceLabel command_results completed_at_utc"
    }
    $aggregateVerdict = Assert-NonEmptyString -Value $Result.aggregate_verdict -Context "$SourceLabel aggregate_verdict"
    Assert-AllowedValue -Value $aggregateVerdict -AllowedValues $script:AllowedAggregateVerdicts -Context "$SourceLabel aggregate_verdict"
    $importedArtifactRef = Assert-StringValue -Value $Result.imported_artifact_ref -Context "$SourceLabel imported_artifact_ref"
    Assert-RefArray -Value $Result.evidence_refs -Context "$SourceLabel evidence_refs" -RequireExists | Out-Null
    $refusalReasons = Assert-StringArray -Value $Result.refusal_reasons -Context "$SourceLabel refusal_reasons" -AllowEmpty
    Assert-TimestampString -Value $Result.started_at_utc -Context "$SourceLabel started_at_utc"
    Assert-TimestampString -Value $Result.completed_at_utc -Context "$SourceLabel completed_at_utc"
    $nonClaims = Assert-StringArray -Value $Result.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -RequiredNonClaims $script:ResultRequiredNonClaims -Context $SourceLabel
    Assert-NoForbiddenR13ExternalReplayClaims -Value $Result -Context $SourceLabel

    $hasExternalRun = -not [string]::IsNullOrWhiteSpace($runId) -and $runUrl -match '^https://github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+/actions/runs/[0-9]+'
    if ($aggregateVerdict -eq "passed") {
        if (-not $hasExternalRun) {
            throw "$SourceLabel passed aggregate verdict requires GitHub Actions or equivalent external-runner run_id/run_url evidence."
        }
        if ([string]::IsNullOrWhiteSpace($artifactId) -or $artifactDigest -notmatch $script:DigestPattern) {
            throw "$SourceLabel passed aggregate verdict requires artifact_id and sha256 artifact_digest."
        }
        if ([string]::IsNullOrWhiteSpace($importedArtifactRef)) {
            throw "$SourceLabel passed aggregate verdict requires imported_artifact_ref."
        }
        Assert-ExistingRef -Ref $importedArtifactRef -Context "$SourceLabel imported_artifact_ref"
        if ($Result.run_status -ne "completed" -or $Result.run_conclusion -ne "success") {
            throw "$SourceLabel passed aggregate verdict requires completed/success external run status."
        }
        if ($Result.requested_head -ne $Result.observed_head -or $Result.requested_tree -ne $Result.observed_tree) {
            throw "$SourceLabel passed aggregate verdict requires observed head/tree to match requested head/tree."
        }
        if (@($commandResults).Count -eq 0 -or $failedCount -ne 0 -or $blockedCount -ne 0) {
            throw "$SourceLabel passed aggregate verdict requires at least one command and all commands passing."
        }
        if (@($refusalReasons).Count -ne 0) {
            throw "$SourceLabel passed aggregate verdict requires empty refusal_reasons."
        }
    }
    elseif ($aggregateVerdict -eq "failed") {
        if (-not $hasExternalRun) {
            throw "$SourceLabel failed aggregate verdict must still cite an external run identity; use blocked for missing dispatch."
        }
        if ($failedCount -eq 0 -and $Result.run_conclusion -eq "success") {
            throw "$SourceLabel failed aggregate verdict requires failed command evidence or a non-success run conclusion."
        }
    }
    else {
        if (@($refusalReasons).Count -eq 0) {
            throw "$SourceLabel blocked aggregate verdict requires refusal_reasons."
        }
        if ($hasExternalRun -and [string]::IsNullOrWhiteSpace($artifactId)) {
            throw "$SourceLabel cites an external run but is missing artifact_id; record the artifact or do not claim external replay evidence."
        }
    }

    return [pscustomobject][ordered]@{
        ResultId = $resultId
        RequestId = $requestId
        RunId = $runId
        ArtifactId = $artifactId
        CommandCount = @($commandResults).Count
        PassedCommandCount = $passedCount
        FailedCommandCount = $failedCount
        BlockedCommandCount = $blockedCount
        AggregateVerdict = $aggregateVerdict
    }
}

function Test-R13ExternalReplayResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResultPath
    )

    $result = Get-JsonDocument -Path $ResultPath -Label "R13 external replay result"
    return Test-R13ExternalReplayResultObject -Result $result -SourceLabel "R13 external replay result"
}

function Test-R13ExternalReplayImportObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Import,
        [string]$SourceLabel = "R13 external replay import"
    )

    $contract = Get-JsonDocument -Path "contracts/external_replay/r13_external_replay_import.contract.json" -Label "R13 external replay import contract"
    Assert-RequiredObjectFields -Object $Import -FieldNames $contract.required_fields -Context $SourceLabel
    if ($Import.artifact_type -ne "r13_external_replay_import") {
        throw "$SourceLabel artifact_type must be r13_external_replay_import."
    }
    Assert-NonEmptyString -Value $Import.imported_artifact_id -Context "$SourceLabel imported_artifact_id" | Out-Null
    Assert-NonEmptyString -Value $Import.source_run_id -Context "$SourceLabel source_run_id" | Out-Null
    Assert-NonEmptyString -Value $Import.source_artifact_id -Context "$SourceLabel source_artifact_id" | Out-Null
    Assert-NonEmptyString -Value $Import.source_artifact_name -Context "$SourceLabel source_artifact_name" | Out-Null
    $digest = Assert-NonEmptyString -Value $Import.source_artifact_digest -Context "$SourceLabel source_artifact_digest"
    if ($digest -notmatch $script:DigestPattern) {
        throw "$SourceLabel source_artifact_digest must be a sha256 digest."
    }
    $importedPaths = Assert-StringArray -Value $Import.imported_paths -Context "$SourceLabel imported_paths"
    foreach ($path in @($importedPaths)) {
        Assert-ExistingRef -Ref $path -Context "$SourceLabel imported_paths"
    }
    $validationResults = Assert-ObjectArray -Value $Import.validation_results -Context "$SourceLabel validation_results"
    foreach ($validationResult in @($validationResults)) {
        Assert-RequiredObjectFields -Object $validationResult -FieldNames @("artifact_id", "ref", "validator", "verdict", "summary") -Context "$SourceLabel validation_results"
        Assert-ExistingRef -Ref (Assert-NonEmptyString -Value $validationResult.ref -Context "$SourceLabel validation_results ref") -Context "$SourceLabel validation_results ref"
        Assert-NonEmptyString -Value $validationResult.validator -Context "$SourceLabel validation_results validator" | Out-Null
        Assert-AllowedValue -Value (Assert-NonEmptyString -Value $validationResult.verdict -Context "$SourceLabel validation_results verdict") -AllowedValues $script:AllowedCommandVerdicts -Context "$SourceLabel validation_results verdict"
    }
    Assert-RefArray -Value $Import.evidence_refs -Context "$SourceLabel evidence_refs" -RequireExists | Out-Null
    $aggregateVerdict = Assert-NonEmptyString -Value $Import.aggregate_verdict -Context "$SourceLabel aggregate_verdict"
    Assert-AllowedValue -Value $aggregateVerdict -AllowedValues $script:AllowedAggregateVerdicts -Context "$SourceLabel aggregate_verdict"
    $nonClaims = Assert-StringArray -Value $Import.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -RequiredNonClaims $script:ImportRequiredNonClaims -Context $SourceLabel
    Assert-NoForbiddenR13ExternalReplayClaims -Value $Import -Context $SourceLabel

    if ($aggregateVerdict -eq "passed" -and @($validationResults | Where-Object { [string]$_.verdict -ne "passed" }).Count -ne 0) {
        throw "$SourceLabel passed aggregate verdict requires all validation_results to pass."
    }

    return [pscustomobject][ordered]@{
        ImportedArtifactId = [string]$Import.imported_artifact_id
        SourceRunId = [string]$Import.source_run_id
        SourceArtifactId = [string]$Import.source_artifact_id
        ImportedPathCount = @($importedPaths).Count
        ValidationResultCount = @($validationResults).Count
        AggregateVerdict = $aggregateVerdict
    }
}

function Test-R13ExternalReplayImport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ImportPath
    )

    $import = Get-JsonDocument -Path $ImportPath -Label "R13 external replay import"
    return Test-R13ExternalReplayImportObject -Import $import -SourceLabel "R13 external replay import"
}

function New-CommandLogResult {
    param(
        [Parameter(Mandatory = $true)]
        [string]$CommandId,
        [Parameter(Mandatory = $true)]
        [string]$Command,
        [Parameter(Mandatory = $true)]
        [int]$ExitCode,
        [Parameter(Mandatory = $true)]
        [string]$Verdict,
        [Parameter(Mandatory = $true)]
        [string]$StdoutRef,
        [Parameter(Mandatory = $true)]
        [string]$StderrRef,
        [Parameter(Mandatory = $true)]
        [string]$StartedAtUtc,
        [Parameter(Mandatory = $true)]
        [string]$CompletedAtUtc
    )

    return [pscustomobject][ordered]@{
        command_id = $CommandId
        command = $Command
        exit_code = $ExitCode
        verdict = $Verdict
        stdout_ref = $StdoutRef.Replace("\", "/")
        stderr_ref = $StderrRef.Replace("\", "/")
        started_at_utc = $StartedAtUtc
        completed_at_utc = $CompletedAtUtc
    }
}

function Invoke-R13ExternalReplayDispatch {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RequestPath,
        [Parameter(Mandatory = $true)]
        [string]$OutputRoot
    )

    $startedAt = Get-UtcTimestamp
    $request = Get-JsonDocument -Path $RequestPath -Label "R13 external replay request"
    Test-R13ExternalReplayRequestObject -Request $request -SourceLabel "R13 external replay request" | Out-Null
    $outputRootRef = (Convert-ToRepositoryRelativePath -PathValue $OutputRoot).TrimEnd("/")
    $rawLogRoot = (Join-Path $outputRootRef "raw_logs").Replace("\", "/")
    New-Item -ItemType Directory -Path (Resolve-RepositoryPath -PathValue $rawLogRoot) -Force | Out-Null

    $commandResults = @()
    $refusalReasons = @()

    $checkStarted = Get-UtcTimestamp
    $checkStdoutRef = "$rawLogRoot/check_github_cli_stdout.log"
    $checkStderrRef = "$rawLogRoot/check_github_cli_stderr.log"
    $ghCommand = Get-Command -Name "gh" -ErrorAction SilentlyContinue
    if ($null -eq $ghCommand) {
        Write-R13ExternalReplayTextFile -Path $checkStdoutRef -Value ""
        Write-R13ExternalReplayTextFile -Path $checkStderrRef -Value "gh CLI was not found on PATH; authenticated GitHub Actions dispatch could not be attempted from this environment.`n"
        $checkExitCode = 1
        $checkVerdict = "blocked"
        $refusalReasons += "Authenticated external dispatch unavailable: gh CLI is not installed or not on PATH."
    }
    else {
        Write-R13ExternalReplayTextFile -Path $checkStdoutRef -Value ("{0}`n" -f $ghCommand.Source)
        Write-R13ExternalReplayTextFile -Path $checkStderrRef -Value ""
        $checkExitCode = 0
        $checkVerdict = "passed"
    }
    $checkCompleted = Get-UtcTimestamp
    $commandResults += New-CommandLogResult -CommandId "check-github-cli" -Command "Get-Command gh -ErrorAction SilentlyContinue" -ExitCode $checkExitCode -Verdict $checkVerdict -StdoutRef $checkStdoutRef -StderrRef $checkStderrRef -StartedAtUtc $checkStarted -CompletedAtUtc $checkCompleted

    $tokenStarted = Get-UtcTimestamp
    $tokenStdoutRef = "$rawLogRoot/check_github_tokens_stdout.log"
    $tokenStderrRef = "$rawLogRoot/check_github_tokens_stderr.log"
    $ghTokenPresent = -not [string]::IsNullOrWhiteSpace($env:GH_TOKEN)
    $githubTokenPresent = -not [string]::IsNullOrWhiteSpace($env:GITHUB_TOKEN)
    Write-R13ExternalReplayTextFile -Path $tokenStdoutRef -Value ("GH_TOKEN present: {0}`nGITHUB_TOKEN present: {1}`n" -f $ghTokenPresent, $githubTokenPresent)
    Write-R13ExternalReplayTextFile -Path $tokenStderrRef -Value ""
    if (-not $ghTokenPresent -and -not $githubTokenPresent) {
        $refusalReasons += "Authenticated external dispatch unavailable: no GH_TOKEN or GITHUB_TOKEN environment variable is present."
        $tokenExitCode = 1
        $tokenVerdict = "blocked"
    }
    else {
        $tokenExitCode = 0
        $tokenVerdict = "passed"
    }
    $tokenCompleted = Get-UtcTimestamp
    $commandResults += New-CommandLogResult -CommandId "check-github-token-presence" -Command "Test GH_TOKEN and GITHUB_TOKEN environment variable presence without reading secret values" -ExitCode $tokenExitCode -Verdict $tokenVerdict -StdoutRef $tokenStdoutRef -StderrRef $tokenStderrRef -StartedAtUtc $tokenStarted -CompletedAtUtc $tokenCompleted

    $dispatchCommand = "gh workflow run r13-external-replay.yml --repo $script:R13RepositoryFullName --ref $($request.branch) -f branch=$($request.branch) -f expected_head=$($request.head) -f expected_tree=$($request.tree) -f replay_scope=$($request.replay_scope)"
    $dispatchStarted = Get-UtcTimestamp
    $dispatchStdoutRef = "$rawLogRoot/dispatch_r13_external_replay_stdout.log"
    $dispatchStderrRef = "$rawLogRoot/dispatch_r13_external_replay_stderr.log"
    if ($checkExitCode -ne 0 -or $tokenExitCode -ne 0) {
        Write-R13ExternalReplayTextFile -Path $dispatchStdoutRef -Value ""
        Write-R13ExternalReplayTextFile -Path $dispatchStderrRef -Value ("Dispatch command not executed because authenticated dispatch prerequisites were unavailable.`nAttempted command: {0}`n" -f $dispatchCommand)
        $dispatchExitCode = 1
        $dispatchVerdict = "blocked"
    }
    else {
        $previousErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = "Continue"
        try {
            $dispatchOutput = Invoke-Expression "$dispatchCommand 2>&1"
            $dispatchExitCode = if ($null -eq $LASTEXITCODE) { 0 } else { [int]$LASTEXITCODE }
        }
        finally {
            $ErrorActionPreference = $previousErrorActionPreference
        }
        $dispatchOutputText = [string]::Join("`n", @($dispatchOutput))
        Write-R13ExternalReplayTextFile -Path $dispatchStdoutRef -Value ($dispatchOutputText.TrimEnd() + "`n")
        Write-R13ExternalReplayTextFile -Path $dispatchStderrRef -Value ""
        $dispatchVerdict = if ($dispatchExitCode -eq 0) { "passed" } else { "blocked" }
        if ($dispatchExitCode -ne 0) {
            $refusalReasons += "Authenticated external dispatch command failed with exit code $dispatchExitCode."
        }
    }
    $dispatchCompleted = Get-UtcTimestamp
    $commandResults += New-CommandLogResult -CommandId "dispatch-r13-external-replay" -Command $dispatchCommand -ExitCode $dispatchExitCode -Verdict $dispatchVerdict -StdoutRef $dispatchStdoutRef -StderrRef $dispatchStderrRef -StartedAtUtc $dispatchStarted -CompletedAtUtc $dispatchCompleted

    if ($dispatchExitCode -ne 0 -and $refusalReasons.Count -eq 0) {
        $refusalReasons += "Authenticated external dispatch was unavailable or failed before a run ID could be captured."
    }

    $observed = Get-R13ExternalReplayGitIdentity
    $result = [pscustomobject][ordered]@{
        contract_version = "v1"
        artifact_type = "r13_external_replay_result"
        result_id = Get-StableId -Prefix "r13err" -Key "$($request.request_id)|blocked|$([string]::Join('|', $refusalReasons))"
        request_id = [string]$request.request_id
        repository = $script:R13RepositoryName
        branch = [string]$request.branch
        requested_head = [string]$request.head
        requested_tree = [string]$request.tree
        observed_head = [string]$observed.Head
        observed_tree = [string]$observed.Tree
        workflow_name = "R13 External Replay"
        run_id = ""
        run_url = ""
        run_attempt = 0
        run_status = "not_dispatched"
        run_conclusion = "blocked"
        artifact_id = ""
        artifact_name = [string]$request.expected_artifact_name
        artifact_digest = ""
        command_results = @($commandResults)
        aggregate_verdict = "blocked"
        imported_artifact_ref = ""
        evidence_refs = @(
            (New-EvidenceRef -RefId "r13-external-replay-request" -Ref (Convert-ToRepositoryRelativePath -PathValue $RequestPath) -EvidenceKind "external_replay_request"),
            (New-EvidenceRef -RefId "r13-external-replay-result-contract" -Ref "contracts/external_replay/r13_external_replay_result.contract.json" -EvidenceKind "contract" -AuthorityKind "repo_contract"),
            (New-EvidenceRef -RefId "r13-external-replay-module" -Ref "tools/R13ExternalReplay.psm1" -EvidenceKind "module" -AuthorityKind "repo_tooling"),
            (New-EvidenceRef -RefId "r13-external-replay-invoker" -Ref "tools/invoke_r13_external_replay.ps1" -EvidenceKind "cli" -AuthorityKind "repo_tooling")
        )
        refusal_reasons = @($refusalReasons)
        started_at_utc = $startedAt
        completed_at_utc = Get-UtcTimestamp
        non_claims = @($script:ResultRequiredNonClaims)
    }

    $blockedRef = (Join-Path $outputRootRef "r13_011_external_replay_blocked.json").Replace("\", "/")
    Write-R13ExternalReplayJsonFile -Path $blockedRef -Value $result
    Test-R13ExternalReplayResultObject -Result $result -SourceLabel "generated R13 external replay blocked result" | Out-Null

    $manualPacket = [pscustomobject][ordered]@{
        artifact_type = "r13_external_replay_manual_dispatch_packet"
        packet_id = Get-StableId -Prefix "r13ermdp" -Key "$($request.request_id)|manual-dispatch|blocked"
        request_ref = (Convert-ToRepositoryRelativePath -PathValue $RequestPath)
        blocked_result_ref = $blockedRef
        repository = $script:R13RepositoryFullName
        branch = [string]$request.branch
        head = [string]$request.head
        tree = [string]$request.tree
        workflow_name = "R13 External Replay"
        workflow_ref = [string]$request.workflow_ref
        dispatch_status = "blocked_authenticated_dispatch_unavailable"
        attempted_command = $dispatchCommand
        attempted_command_results = @($commandResults)
        missing_dependencies_or_credentials = @($refusalReasons)
        manual_operator_action_required = @(
            "Provide an authenticated GitHub Actions dispatch path for an R13 External Replay workflow or equivalent external runner.",
            "Run against branch '$($request.branch)' and expected head '$($request.head)' / tree '$($request.tree)'.",
            "Capture run ID, run URL, run attempt, run status/conclusion, artifact ID, artifact name, artifact digest, observed head/tree, and command results.",
            "Import the artifact evidence into state/external_runs/r13_external_replay/r13_011/ and validate it with the R13 external replay validators before R13-012."
        )
        aggregate_verdict = "blocked"
        evidence_refs = @(
            (New-EvidenceRef -RefId "r13-external-replay-request" -Ref (Convert-ToRepositoryRelativePath -PathValue $RequestPath) -EvidenceKind "external_replay_request"),
            (New-EvidenceRef -RefId "r13-external-replay-blocked-result" -Ref $blockedRef -EvidenceKind "blocked_result"),
            (New-EvidenceRef -RefId "r13-external-replay-invoker" -Ref "tools/invoke_r13_external_replay.ps1" -EvidenceKind "cli" -AuthorityKind "repo_tooling")
        )
        created_at_utc = Get-UtcTimestamp
        non_claims = @(
            "no external replay has occurred",
            "no external replay proof is claimed",
            "no final QA signoff has occurred",
            "no R13 hard value gate fully delivered by R13-011",
            "no R14 or successor opening"
        )
    }
    $manualPacketRef = (Join-Path $outputRootRef "manual_dispatch_packet.json").Replace("\", "/")
    Write-R13ExternalReplayJsonFile -Path $manualPacketRef -Value $manualPacket

    return [pscustomobject][ordered]@{
        BlockedResultPath = $blockedRef
        ManualDispatchPacketPath = $manualPacketRef
        RawLogsPath = $rawLogRoot
        AggregateVerdict = "blocked"
        RefusalReasons = @($refusalReasons)
    }
}

Export-ModuleMember -Function Get-RepositoryRoot, Resolve-RepositoryPath, Convert-ToRepositoryRelativePath, Get-UtcTimestamp, Get-JsonDocument, Write-R13ExternalReplayJsonFile, Write-R13ExternalReplayTextFile, Get-R13ExternalReplayGitIdentity, New-R13ExternalReplayRequestObject, Test-R13ExternalReplayRequestObject, Test-R13ExternalReplayRequest, Test-R13ExternalReplayResultObject, Test-R13ExternalReplayResult, Test-R13ExternalReplayImportObject, Test-R13ExternalReplayImport, Invoke-R13ExternalReplayDispatch
