Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$script:R13RepositoryName = "AIOffice_V2"
$script:R13RepositoryFullName = "RodneyMuniz/AIOffice_V2"
$script:R13Branch = "release/r13-api-first-qa-pipeline-and-operator-control-room-product-slice"
$script:R13Milestone = "R13 API-First QA Pipeline and Operator Control-Room Product Slice"
$script:R13SourceTask = "R13-012"
$script:GitObjectPattern = "^[a-f0-9]{40}$"
$script:DigestPattern = "^sha256:[a-f0-9]{64}$"
$script:TimestampPattern = "^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$"
$script:ExpectedExternalRunId = "25241730946"
$script:ExpectedExternalArtifactId = "6759970924"
$script:ExpectedExternalDigest = "sha256:50bc3e28d47c5aca5c4ff6a5e595a967c3aa4153c6611dd20e09f47864ee3769"
$script:AllowedSignoffDecisions = @("accepted_bounded_scope", "rejected", "blocked")
$script:AllowedAggregateVerdicts = @("passed", "failed", "blocked")
$script:AllowedEvidenceVerdicts = @("passed", "failed", "blocked")
$script:RequiredNonClaims = @(
    "bounded representative QA slice only",
    "no production QA",
    "no full product QA coverage",
    "no full autonomous execution",
    "no solved Codex reliability",
    "no productized UI",
    "no R13 closeout",
    "no R14 or successor opening",
    "meaningful QA loop hard gate delivered only for bounded representative scope, not full product scope"
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

function Write-R13SignoffJsonFile {
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

function Write-R13SignoffTextFile {
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

function Get-R13SignoffGitIdentity {
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

    return ($Line -match '(?i)\b(no|not|without|cannot|must not|does not|do not|is not|are not|did not|non-claim|non_claim|blocked|planned only|not yet|not fully|partial|partially|missing|bounded|only|rejects|rejected|scope-limited)\b')
}

function Assert-NoForbiddenR13SignoffClaims {
    param(
        [Parameter(Mandatory = $true)]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($line in @(Get-StringLeaves -Value $Value)) {
        if ($line -match '(?i)\b(full|whole|entire|product[- ]wide|broad)\s+(product\s+)?QA\b|\bfull\s+product\s+QA\s+coverage\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims product-wide QA scope. Offending text: $line"
        }
        if ($line -match '(?i)\bproduction\s+(QA|runtime|coverage|signoff)\b|\breal\s+production\s+QA\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims production runtime or production QA. Offending text: $line"
        }
        if ($line -match '(?i)\b(full|broad)\s+autonomous\s+execution\b|\bbroad\s+autonomy\b|\bfully\s+autonomous\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims broad autonomous execution. Offending text: $line"
        }
        if ($line -match '(?i)\bsolved\s+Codex\s+(reliability|context\s+compaction)\b|\bCodex\s+reliability\s+solved\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims solved Codex reliability. Offending text: $line"
        }
        if ($line -match '(?i)\bproductized\s+UI\b|\bproductized\s+control[- ]room\b|\bfull\s+UI\s+app\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims productized UI. Offending text: $line"
        }
        if ($line -match '(?i)\bR13\b.*\b(closed|closeout\s+complete|closeout\s+completed)\b|\bclose\s+R13\b|\bR13\s+closeout\s+passed\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims R13 closeout. Offending text: $line"
        }
        if ($line -match '(?i)\bR14\b.*\b(active|open|opened|started)\b|\bsuccessor\b.*\b(active|open|opened|started)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims R14 or successor opening. Offending text: $line"
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

function Get-R13SignoffContract {
    return Get-JsonDocument -Path "contracts/actionable_qa/r13_meaningful_qa_signoff.contract.json" -Label "R13 meaningful QA signoff contract"
}

function Get-R13SignoffEvidenceMatrixContract {
    return Get-JsonDocument -Path "contracts/actionable_qa/r13_meaningful_qa_signoff_evidence_matrix.contract.json" -Label "R13 meaningful QA signoff evidence matrix contract"
}

function New-RequiredEvidenceSpec {
    param(
        [Parameter(Mandatory = $true)]
        [string]$EvidenceId,
        [Parameter(Mandatory = $true)]
        [string]$RequiredFor,
        [Parameter(Mandatory = $true)]
        [string]$ExpectedRef,
        [Parameter(Mandatory = $true)]
        [string]$Validator,
        [Parameter(Mandatory = $true)]
        [string]$EvidenceKind,
        [string]$AuthorityKind = "repo_evidence",
        [string]$Scope = "repo"
    )

    return [pscustomobject][ordered]@{
        evidence_id = $EvidenceId
        required_for = $RequiredFor
        expected_ref = $ExpectedRef.Replace("\", "/")
        validator = $Validator
        evidence_kind = $EvidenceKind
        authority_kind = $AuthorityKind
        scope = $Scope
    }
}

function Get-R13RequiredEvidenceSpecs {
    return @(
        (New-RequiredEvidenceSpec -EvidenceId "r13-012-signoff-contract" -RequiredFor "signoff_contract" -ExpectedRef "contracts/actionable_qa/r13_meaningful_qa_signoff.contract.json" -Validator "R13MeaningfulQaSignoff contract reader" -EvidenceKind "contract" -AuthorityKind "repo_contract"),
        (New-RequiredEvidenceSpec -EvidenceId "r13-012-evidence-matrix-contract" -RequiredFor "signoff_contract" -ExpectedRef "contracts/actionable_qa/r13_meaningful_qa_signoff_evidence_matrix.contract.json" -Validator "R13MeaningfulQaSignoff contract reader" -EvidenceKind "contract" -AuthorityKind "repo_contract"),
        (New-RequiredEvidenceSpec -EvidenceId "r13-012-signoff-module" -RequiredFor "signoff_tooling" -ExpectedRef "tools/R13MeaningfulQaSignoff.psm1" -Validator "PowerShell module import" -EvidenceKind "module" -AuthorityKind "repo_tooling"),
        (New-RequiredEvidenceSpec -EvidenceId "r13-012-signoff-generator" -RequiredFor "signoff_tooling" -ExpectedRef "tools/new_r13_meaningful_qa_signoff.ps1" -Validator "PowerShell CLI presence" -EvidenceKind "cli" -AuthorityKind "repo_tooling"),
        (New-RequiredEvidenceSpec -EvidenceId "r13-012-signoff-validator" -RequiredFor "signoff_tooling" -ExpectedRef "tools/validate_r13_meaningful_qa_signoff.ps1" -Validator "PowerShell CLI presence" -EvidenceKind "validator" -AuthorityKind "repo_tooling"),
        (New-RequiredEvidenceSpec -EvidenceId "r13-012-evidence-matrix-validator" -RequiredFor "signoff_tooling" -ExpectedRef "tools/validate_r13_meaningful_qa_signoff_evidence_matrix.ps1" -Validator "PowerShell CLI presence" -EvidenceKind "validator" -AuthorityKind "repo_tooling"),
        (New-RequiredEvidenceSpec -EvidenceId "r13-012-signoff-test" -RequiredFor "signoff_tooling" -ExpectedRef "tests/test_r13_meaningful_qa_signoff.ps1" -Validator "PowerShell test presence" -EvidenceKind "test" -AuthorityKind "repo_tooling"),
        (New-RequiredEvidenceSpec -EvidenceId "r13-authority" -RequiredFor "milestone_boundary" -ExpectedRef "governance/R13_API_FIRST_QA_PIPELINE_AND_OPERATOR_CONTROL_ROOM_PRODUCT_SLICE.md" -Validator "bounded status text and no successor claim" -EvidenceKind "authority" -AuthorityKind "repo_governance"),
        (New-RequiredEvidenceSpec -EvidenceId "r13-control-room-status" -RequiredFor "current_control_room_evidence" -ExpectedRef "state/control_room/r13_current/control_room_status.json" -Validator "tools/validate_r13_control_room_status.ps1 plus current identity check" -EvidenceKind "control_room_status"),
        (New-RequiredEvidenceSpec -EvidenceId "r13-control-room-view" -RequiredFor "current_control_room_evidence" -ExpectedRef "state/control_room/r13_current/control_room.md" -Validator "tools/validate_r13_control_room_view.ps1" -EvidenceKind "control_room_view"),
        (New-RequiredEvidenceSpec -EvidenceId "r13-control-room-refresh-result" -RequiredFor "current_control_room_evidence" -ExpectedRef "state/control_room/r13_current/control_room_refresh_result.json" -Validator "tools/validate_r13_control_room_refresh_result.ps1 plus current identity check" -EvidenceKind "control_room_refresh_result"),
        (New-RequiredEvidenceSpec -EvidenceId "r13-control-room-validation-manifest" -RequiredFor "current_control_room_evidence" -ExpectedRef "state/control_room/r13_current/validation_manifest.md" -Validator "manifest presence" -EvidenceKind "validation_manifest"),
        (New-RequiredEvidenceSpec -EvidenceId "r13-operator-demo" -RequiredFor "operator_demo_evidence" -ExpectedRef "state/control_room/r13_current/operator_demo.md" -Validator "tools/validate_r13_operator_demo.ps1" -EvidenceKind "operator_demo"),
        (New-RequiredEvidenceSpec -EvidenceId "r13-operator-demo-validation-manifest" -RequiredFor "operator_demo_evidence" -ExpectedRef "state/control_room/r13_current/operator_demo_validation_manifest.md" -Validator "operator demo validation manifest presence" -EvidenceKind "validation_manifest"),
        (New-RequiredEvidenceSpec -EvidenceId "r13-006-failure-fix-cycle" -RequiredFor "local_qa_failure_to_fix_proof" -ExpectedRef "state/cycles/r13_qa_cycle_demo/qa_failure_fix_cycle.json" -Validator "fixed_pending_external_replay and safety checks" -EvidenceKind "failure_fix_cycle"),
        (New-RequiredEvidenceSpec -EvidenceId "r13-006-before-after-comparison" -RequiredFor "local_qa_failure_to_fix_proof" -ExpectedRef "state/cycles/r13_qa_cycle_demo/before_after_comparison.json" -Validator "target_issue_resolved comparison" -EvidenceKind "before_after_comparison"),
        (New-RequiredEvidenceSpec -EvidenceId "r13-003-issue-detection-report" -RequiredFor "local_qa_failure_to_fix_proof" -ExpectedRef "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/qa/r13_003_issue_detection_report.json" -Validator "issue detection report shape" -EvidenceKind "issue_detection_report"),
        (New-RequiredEvidenceSpec -EvidenceId "r13-004-fix-queue" -RequiredFor "local_qa_failure_to_fix_proof" -ExpectedRef "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/qa/r13_004_fix_queue.json" -Validator "ready_for_fix_execution queue" -EvidenceKind "fix_queue"),
        (New-RequiredEvidenceSpec -EvidenceId "r13-005-bounded-fix-execution" -RequiredFor "local_qa_failure_to_fix_proof" -ExpectedRef "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/qa/r13_005_bounded_fix_execution_packet.json" -Validator "bounded execution packet authorization" -EvidenceKind "bounded_fix_execution_packet"),
        (New-RequiredEvidenceSpec -EvidenceId "r13-007-custom-runner-result" -RequiredFor "runner_evidence" -ExpectedRef "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/runner/r13_007_custom_runner_result.json" -Validator "custom runner aggregate passed" -EvidenceKind "custom_runner_result"),
        (New-RequiredEvidenceSpec -EvidenceId "r13-008-skill-registry" -RequiredFor "skill_invocation_evidence" -ExpectedRef "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_skill_registry.json" -Validator "skill registry presence" -EvidenceKind "skill_registry"),
        (New-RequiredEvidenceSpec -EvidenceId "r13-008-qa-detect-invocation" -RequiredFor "skill_invocation_evidence" -ExpectedRef "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_qa_detect_invocation_result.json" -Validator "qa.detect invocation passed" -EvidenceKind "skill_invocation_result"),
        (New-RequiredEvidenceSpec -EvidenceId "r13-008-qa-fix-plan-invocation" -RequiredFor "skill_invocation_evidence" -ExpectedRef "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_qa_fix_plan_invocation_result.json" -Validator "qa.fix_plan invocation passed" -EvidenceKind "skill_invocation_result"),
        (New-RequiredEvidenceSpec -EvidenceId "r13-011-external-replay-request" -RequiredFor "external_replay_proof" -ExpectedRef "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_request.json" -Validator "external replay request identity" -EvidenceKind "external_replay_request"),
        (New-RequiredEvidenceSpec -EvidenceId "r13-011-external-replay-result" -RequiredFor "external_replay_proof" -ExpectedRef "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_result.json" -Validator "tools/validate_r13_external_replay_result.ps1 plus strict run/artifact identity" -EvidenceKind "external_replay_result"),
        (New-RequiredEvidenceSpec -EvidenceId "r13-011-external-replay-import" -RequiredFor "external_replay_proof" -ExpectedRef "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_import.json" -Validator "tools/validate_r13_external_replay_import.ps1 plus strict run/artifact identity" -EvidenceKind "external_replay_import"),
        (New-RequiredEvidenceSpec -EvidenceId "r13-011-external-replay-imported-manifest" -RequiredFor "external_replay_proof" -ExpectedRef "state/external_runs/r13_external_replay/r13_011/imported_artifact_25241730946_6759970924/validation_manifest.md" -Validator "imported artifact manifest records 10 passed commands" -EvidenceKind "imported_artifact_manifest" -AuthorityKind "github_actions_external_runner"),
        (New-RequiredEvidenceSpec -EvidenceId "r13-012-evidence-matrix" -RequiredFor "signoff_evidence_matrix" -ExpectedRef "state/signoff/r13_meaningful_qa_signoff/r13_012_evidence_matrix.json" -Validator "tools/validate_r13_meaningful_qa_signoff_evidence_matrix.ps1" -EvidenceKind "evidence_matrix")
    )
}

function Get-EvidenceRefMap {
    param(
        [Parameter(Mandatory = $true)]
        $EvidenceRefs,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [switch]$AllowMissing
    )

    $refs = Assert-RefArray -Value $EvidenceRefs -Context $Context -RequireExists:(!$AllowMissing)
    $map = @{}
    foreach ($ref in @($refs)) {
        $map[[string]$ref.ref_id] = [string]$ref.ref
    }
    return $map
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

function Invoke-ValidationCli {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $resolved = Resolve-RepositoryPath -PathValue $FilePath
    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $resolved @Arguments 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }

    if ($exitCode -ne 0) {
        throw "$Context failed. Output: $([string]::Join(' ', @($output)))"
    }
}

function New-EvidenceRow {
    param(
        [Parameter(Mandatory = $true)]
        $Spec,
        [string]$ActualRef,
        [string]$Status = "present_current_validated",
        [string]$Verdict = "passed",
        [string]$Notes = "Required evidence exists and validates."
    )

    if ([string]::IsNullOrWhiteSpace($ActualRef)) {
        $ActualRef = [string]$Spec.expected_ref
    }

    return [pscustomobject][ordered]@{
        evidence_id = [string]$Spec.evidence_id
        required_for = [string]$Spec.required_for
        expected_ref = [string]$Spec.expected_ref
        actual_ref = $ActualRef.Replace("\", "/")
        status = $Status
        validator = [string]$Spec.validator
        verdict = $Verdict
        notes = $Notes
    }
}

function Get-ActualRefFromMap {
    param(
        [Parameter(Mandatory = $true)]
        $Spec,
        [AllowNull()]
        $EvidenceRefMap
    )

    if ($null -ne $EvidenceRefMap -and $EvidenceRefMap.ContainsKey([string]$Spec.evidence_id)) {
        return [string]$EvidenceRefMap[[string]$Spec.evidence_id]
    }
    return [string]$Spec.expected_ref
}

function Assert-JsonArtifact {
    param(
        [Parameter(Mandatory = $true)]
        $Document,
        [Parameter(Mandatory = $true)]
        [string]$ArtifactType,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [switch]$RequireR13Identity
    )

    if ($Document.artifact_type -ne $ArtifactType) {
        throw "$Context artifact_type must be '$ArtifactType'."
    }
    if ($RequireR13Identity) {
        if ($Document.repository -ne $script:R13RepositoryName) {
            throw "$Context repository must be '$script:R13RepositoryName'."
        }
        if ($Document.branch -ne $script:R13Branch) {
            throw "$Context branch must be '$script:R13Branch'."
        }
        if ($Document.source_milestone -ne $script:R13Milestone) {
            throw "$Context source_milestone must be '$script:R13Milestone'."
        }
    }
}

function Test-R13PrerequisiteEvidence {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $GitIdentity,
        [AllowNull()]
        $EvidenceRefMap,
        [switch]$AllowPendingMatrix
    )

    if ([string]$GitIdentity.Branch -ne $script:R13Branch) {
        throw "R13-012 signoff must run on branch '$script:R13Branch'."
    }

    $rows = @()
    $specs = @(Get-R13RequiredEvidenceSpecs)
    foreach ($spec in $specs) {
        $actualRef = Get-ActualRefFromMap -Spec $spec -EvidenceRefMap $EvidenceRefMap
        if ([string]$spec.evidence_id -eq "r13-012-evidence-matrix" -and $AllowPendingMatrix -and -not (Test-Path -LiteralPath (Resolve-RepositoryPath -PathValue $actualRef))) {
            $rows += New-EvidenceRow -Spec $spec -ActualRef $actualRef -Notes "Evidence matrix is generated together with the signoff and validated after both files are written."
        }
        else {
            Assert-ExistingRef -Ref $actualRef -Context "required evidence '$($spec.evidence_id)'"
            $rows += New-EvidenceRow -Spec $spec -ActualRef $actualRef
        }
    }

    $rowById = @{}
    foreach ($row in @($rows)) {
        $rowById[[string]$row.evidence_id] = $row
    }

    $authorityText = Get-Content -LiteralPath (Resolve-RepositoryPath -PathValue $rowById["r13-authority"].actual_ref) -Raw
    Assert-NoForbiddenR13SignoffClaims -Value $authorityText -Context "R13 authority"

    $issueReport = Get-JsonDocument -Path $rowById["r13-003-issue-detection-report"].actual_ref -Label "R13 issue detection report"
    Assert-JsonArtifact -Document $issueReport -ArtifactType "r13_qa_issue_detection_report" -Context "R13 issue detection report" -RequireR13Identity
    if ([string]$issueReport.aggregate_verdict -ne "failed") {
        throw "R13 issue detection report must preserve the initial failed detector evidence."
    }

    $fixQueue = Get-JsonDocument -Path $rowById["r13-004-fix-queue"].actual_ref -Label "R13 fix queue"
    Assert-JsonArtifact -Document $fixQueue -ArtifactType "r13_qa_fix_queue" -Context "R13 fix queue" -RequireR13Identity
    if ([string]$fixQueue.aggregate_verdict -ne "ready_for_fix_execution") {
        throw "R13 fix queue must be ready_for_fix_execution."
    }

    $boundedPacket = Get-JsonDocument -Path $rowById["r13-005-bounded-fix-execution"].actual_ref -Label "R13 bounded fix execution packet"
    Assert-JsonArtifact -Document $boundedPacket -ArtifactType "r13_bounded_fix_execution_packet" -Context "R13 bounded fix execution packet" -RequireR13Identity
    if ([string]$boundedPacket.aggregate_verdict -ne "authorized_for_future_execution") {
        throw "R13 bounded fix execution packet must preserve authorized_for_future_execution."
    }

    $failureFixCycle = Get-JsonDocument -Path $rowById["r13-006-failure-fix-cycle"].actual_ref -Label "R13 failure-to-fix cycle"
    Assert-JsonArtifact -Document $failureFixCycle -ArtifactType "r13_qa_failure_fix_cycle" -Context "R13 failure-to-fix cycle" -RequireR13Identity
    if ([string]$failureFixCycle.cycle_status -ne "fixed_locally_pending_external_replay" -or [string]$failureFixCycle.aggregate_verdict -ne "fixed_pending_external_replay") {
        throw "R13 failure-to-fix cycle must preserve the bounded local fixed-pending-external-replay posture."
    }
    if (-not [bool]$failureFixCycle.safety_checks.selected_fix_item_authorized -or -not [bool]$failureFixCycle.safety_checks.before_report_contains_selected_issue -or [bool]$failureFixCycle.safety_checks.after_report_contains_selected_blocking_issue -or [bool]$failureFixCycle.safety_checks.external_replay_claimed -or [bool]$failureFixCycle.safety_checks.final_signoff_claimed -or [bool]$failureFixCycle.safety_checks.hard_gate_claimed) {
        throw "R13 failure-to-fix cycle safety checks do not support bounded signoff."
    }

    $comparison = Get-JsonDocument -Path $rowById["r13-006-before-after-comparison"].actual_ref -Label "R13 before/after comparison"
    Assert-JsonArtifact -Document $comparison -ArtifactType "r13_qa_before_after_comparison" -Context "R13 before/after comparison" -RequireR13Identity
    if ([string]$comparison.comparison_verdict -ne "target_issue_resolved" -or @($comparison.unresolved_issue_ids).Count -ne 0 -or @($comparison.new_issue_ids).Count -ne 0) {
        throw "R13 before/after comparison must show the target issue resolved without unresolved or new issue IDs."
    }

    $runnerResult = Get-JsonDocument -Path $rowById["r13-007-custom-runner-result"].actual_ref -Label "R13 custom runner result"
    Assert-JsonArtifact -Document $runnerResult -ArtifactType "r13_custom_runner_result" -Context "R13 custom runner result" -RequireR13Identity
    $runnerCounts = Get-CommandCounts -CommandResults $runnerResult.command_results
    if ([string]$runnerResult.aggregate_verdict -ne "passed" -or $runnerCounts.failed -ne 0 -or $runnerCounts.blocked -ne 0) {
        throw "R13 custom runner result must have passed without failed or blocked commands."
    }

    $skillRegistry = Get-JsonDocument -Path $rowById["r13-008-skill-registry"].actual_ref -Label "R13 skill registry"
    Assert-JsonArtifact -Document $skillRegistry -ArtifactType "r13_skill_registry" -Context "R13 skill registry" -RequireR13Identity
    foreach ($requiredSkill in @("qa.detect", "qa.fix_plan", "runner.external_replay", "control_room.refresh")) {
        if (@($skillRegistry.skills | ForEach-Object { [string]$_.skill_id }) -notcontains $requiredSkill) {
            throw "R13 skill registry must include '$requiredSkill'."
        }
    }

    foreach ($skillRowId in @("r13-008-qa-detect-invocation", "r13-008-qa-fix-plan-invocation")) {
        $skillResult = Get-JsonDocument -Path $rowById[$skillRowId].actual_ref -Label "$skillRowId result"
        Assert-JsonArtifact -Document $skillResult -ArtifactType "r13_skill_invocation_result" -Context "$skillRowId result" -RequireR13Identity
        $skillCounts = Get-CommandCounts -CommandResults $skillResult.command_results
        if ([string]$skillResult.aggregate_verdict -ne "passed" -or $skillCounts.passed -lt 1 -or $skillCounts.failed -ne 0 -or $skillCounts.blocked -ne 0) {
            throw "$skillRowId must have passed skill invocation evidence."
        }
    }

    $request = Get-JsonDocument -Path $rowById["r13-011-external-replay-request"].actual_ref -Label "R13 external replay request"
    Assert-JsonArtifact -Document $request -ArtifactType "r13_external_replay_request" -Context "R13 external replay request" -RequireR13Identity

    $externalReplayModule = Import-Module (Join-Path $PSScriptRoot "R13ExternalReplay.psm1") -Force -PassThru
    $testReplayResult = $externalReplayModule.ExportedCommands["Test-R13ExternalReplayResult"]
    $testReplayImport = $externalReplayModule.ExportedCommands["Test-R13ExternalReplayImport"]
    & $testReplayResult -ResultPath $rowById["r13-011-external-replay-result"].actual_ref | Out-Null
    & $testReplayImport -ImportPath $rowById["r13-011-external-replay-import"].actual_ref | Out-Null

    $externalResult = Get-JsonDocument -Path $rowById["r13-011-external-replay-result"].actual_ref -Label "R13 external replay result"
    $externalImport = Get-JsonDocument -Path $rowById["r13-011-external-replay-import"].actual_ref -Label "R13 external replay import"
    $externalCounts = Get-CommandCounts -CommandResults $externalResult.command_results
    if ([string]$externalResult.aggregate_verdict -ne "passed" -or [string]$externalResult.run_id -ne $script:ExpectedExternalRunId -or [string]$externalResult.artifact_id -ne $script:ExpectedExternalArtifactId -or [string]$externalResult.artifact_digest -ne $script:ExpectedExternalDigest) {
        throw "R13 external replay result must preserve the expected passed run/artifact/digest identity."
    }
    if ([string]$externalResult.requested_head -ne [string]$externalResult.observed_head -or [string]$externalResult.requested_tree -ne [string]$externalResult.observed_tree) {
        throw "R13 external replay result observed head/tree must match requested head/tree."
    }
    if ($externalCounts.total -ne 10 -or $externalCounts.passed -ne 10 -or $externalCounts.failed -ne 0 -or $externalCounts.blocked -ne 0) {
        throw "R13 external replay result must show 10/10 commands passed."
    }
    if ([string]$externalImport.aggregate_verdict -ne "passed" -or [string]$externalImport.source_run_id -ne $script:ExpectedExternalRunId -or [string]$externalImport.source_artifact_id -ne $script:ExpectedExternalArtifactId -or [string]$externalImport.source_artifact_digest -ne $script:ExpectedExternalDigest) {
        throw "R13 external replay import must preserve passed run/artifact/digest identity."
    }
    $manifestText = Get-Content -LiteralPath (Resolve-RepositoryPath -PathValue $rowById["r13-011-external-replay-imported-manifest"].actual_ref) -Raw
    foreach ($manifestFragment in @("Run ID: $script:ExpectedExternalRunId", "Aggregate verdict: passed", "assert_requested_identity: passed", "validate_status_doc_gate: passed")) {
        if ($manifestText -notmatch [regex]::Escape($manifestFragment)) {
            throw "R13 imported artifact validation manifest must include '$manifestFragment'."
        }
    }

    $controlRoomModule = Import-Module (Join-Path $PSScriptRoot "R13ControlRoomStatus.psm1") -Force -PassThru
    $testControlStatus = $controlRoomModule.ExportedCommands["Test-R13ControlRoomStatus"]
    $testControlView = $controlRoomModule.ExportedCommands["Test-R13ControlRoomView"]
    $testControlRefresh = $controlRoomModule.ExportedCommands["Test-R13ControlRoomRefreshResult"]
    & $testControlStatus -StatusPath $rowById["r13-control-room-status"].actual_ref | Out-Null
    & $testControlView -ViewPath $rowById["r13-control-room-view"].actual_ref | Out-Null
    & $testControlRefresh -RefreshResultPath $rowById["r13-control-room-refresh-result"].actual_ref | Out-Null
    $status = Get-JsonDocument -Path $rowById["r13-control-room-status"].actual_ref -Label "R13 current control-room status"
    $refresh = Get-JsonDocument -Path $rowById["r13-control-room-refresh-result"].actual_ref -Label "R13 current control-room refresh result"
    foreach ($artifact in @($status, $refresh)) {
        if ([string]$artifact.branch -ne [string]$GitIdentity.Branch -or [string]$artifact.head -ne [string]$GitIdentity.Head -or [string]$artifact.tree -ne [string]$GitIdentity.Tree) {
            throw "R13 current control-room evidence must match current branch/head/tree."
        }
        if (-not [bool]$artifact.stale_state_checks.stale_state_checks_passed) {
            throw "R13 current control-room evidence stale-state checks must pass."
        }
    }
    if ([string]$refresh.refresh_verdict -ne "current") {
        throw "R13 control-room refresh result must be current."
    }

    Invoke-ValidationCli -FilePath "tools/validate_r13_operator_demo.ps1" -Arguments @("-DemoPath", $rowById["r13-operator-demo"].actual_ref) -Context "R13 operator demo validation"

    return [pscustomobject][ordered]@{
        Rows = @($rows)
        LocalQa = [pscustomobject][ordered]@{
            issue_detection_aggregate_verdict = [string]$issueReport.aggregate_verdict
            fix_queue_aggregate_verdict = [string]$fixQueue.aggregate_verdict
            bounded_execution_aggregate_verdict = [string]$boundedPacket.aggregate_verdict
            failure_fix_cycle_status = [string]$failureFixCycle.cycle_status
            failure_fix_cycle_aggregate_verdict = [string]$failureFixCycle.aggregate_verdict
            before_after_comparison_verdict = [string]$comparison.comparison_verdict
            selected_issue_type = [string]$failureFixCycle.selected_issue_type
            bounded_slice_validated = $true
        }
        ExternalReplay = [pscustomobject][ordered]@{
            run_id = [string]$externalResult.run_id
            artifact_id = [string]$externalResult.artifact_id
            artifact_digest = [string]$externalResult.artifact_digest
            requested_head = [string]$externalResult.requested_head
            requested_tree = [string]$externalResult.requested_tree
            observed_head = [string]$externalResult.observed_head
            observed_tree = [string]$externalResult.observed_tree
            command_count = [int]$externalCounts.total
            passed_command_count = [int]$externalCounts.passed
            aggregate_verdict = [string]$externalResult.aggregate_verdict
            import_aggregate_verdict = [string]$externalImport.aggregate_verdict
            passed_external_replay_proven = $true
        }
        ControlRoom = [pscustomobject][ordered]@{
            status_ref = [string]$rowById["r13-control-room-status"].actual_ref
            view_ref = [string]$rowById["r13-control-room-view"].actual_ref
            refresh_result_ref = [string]$rowById["r13-control-room-refresh-result"].actual_ref
            active_through_task = [string]$status.active_scope.active_through_task
            stale_state_checks_passed = [bool]$status.stale_state_checks.stale_state_checks_passed
            matches_current_branch_head_tree = $true
        }
        OperatorDemo = [pscustomobject][ordered]@{
            demo_ref = [string]$rowById["r13-operator-demo"].actual_ref
            validation_manifest_ref = [string]$rowById["r13-operator-demo-validation-manifest"].actual_ref
            validates = $true
        }
        Runner = [pscustomobject][ordered]@{
            aggregate_verdict = [string]$runnerResult.aggregate_verdict
            command_count = [int]$runnerCounts.total
            passed_command_count = [int]$runnerCounts.passed
            partial_local_only = $true
        }
        Skills = [pscustomobject][ordered]@{
            registered_skill_count = @($skillRegistry.skills).Count
            invoked_skill_ids = @("qa.detect", "qa.fix_plan")
            partial_invocation_evidence_only = $true
        }
    }
}

function New-R13SignoffEvidenceRefs {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SignoffPath,
        [Parameter(Mandatory = $true)]
        [string]$MatrixPath,
        [Parameter(Mandatory = $true)]
        [string]$ManifestPath
    )

    $refs = @()
    foreach ($spec in @(Get-R13RequiredEvidenceSpecs)) {
        $ref = if ([string]$spec.evidence_id -eq "r13-012-evidence-matrix") { $MatrixPath } else { [string]$spec.expected_ref }
        $refs += New-EvidenceRef -RefId ([string]$spec.evidence_id) -Ref $ref -EvidenceKind ([string]$spec.evidence_kind) -AuthorityKind ([string]$spec.authority_kind) -Scope ([string]$spec.scope)
    }
    $refs += New-EvidenceRef -RefId "r13-012-signoff" -Ref $SignoffPath -EvidenceKind "meaningful_qa_signoff"
    $refs += New-EvidenceRef -RefId "r13-012-signoff-validation-manifest" -Ref $ManifestPath -EvidenceKind "validation_manifest"
    return @($refs)
}

function New-R13MeaningfulQaSignoffObjects {
    [CmdletBinding()]
    param(
        [string]$SignoffPath = "state/signoff/r13_meaningful_qa_signoff/r13_012_signoff.json",
        [string]$MatrixPath = "state/signoff/r13_meaningful_qa_signoff/r13_012_evidence_matrix.json",
        [string]$ManifestPath = "state/signoff/r13_meaningful_qa_signoff/validation_manifest.md"
    )

    $signoffRef = (Convert-ToRepositoryRelativePath -PathValue $SignoffPath)
    $matrixRef = (Convert-ToRepositoryRelativePath -PathValue $MatrixPath)
    $manifestRef = (Convert-ToRepositoryRelativePath -PathValue $ManifestPath)
    $gitIdentity = Get-R13SignoffGitIdentity
    $evidenceRefs = New-R13SignoffEvidenceRefs -SignoffPath $signoffRef -MatrixPath $matrixRef -ManifestPath $manifestRef
    $evidenceRefMap = Get-EvidenceRefMap -EvidenceRefs $evidenceRefs -Context "generated R13 signoff evidence_refs" -AllowMissing
    $assessment = Test-R13PrerequisiteEvidence -GitIdentity $gitIdentity -EvidenceRefMap $evidenceRefMap -AllowPendingMatrix
    $rows = @($assessment.Rows)
    $missingRows = @($rows | Where-Object { [string]$_.verdict -ne "passed" })
    $passed = $missingRows.Count -eq 0
    $decision = if ($passed) { "accepted_bounded_scope" } else { "blocked" }
    $verdict = if ($passed) { "passed" } else { "blocked" }
    $residualRisks = @(
        "Representative demo workspace only; not production QA and not full product QA coverage.",
        "The API/custom-runner bypass remains partial local evidence only.",
        "Skill invocation evidence is limited to qa.detect and qa.fix_plan; runner.external_replay and control_room.refresh were not invoked as R13-008 skills.",
        "The current control room and operator demo are repo-generated Markdown/JSON evidence, not productized UI or product runtime.",
        "The signoff does not solve Codex reliability, context compaction, or broad autonomous execution.",
        "R13 remains active after R13-012; R13-013 through R13-018 remain planned only."
    )
    $blockers = if ($passed) { @() } else { @($missingRows | ForEach-Object { "Required evidence '$($_.evidence_id)' did not pass validation." }) }

    $signoff = [pscustomobject][ordered]@{
        contract_version = "v1"
        artifact_type = "r13_meaningful_qa_signoff"
        signoff_id = Get-StableId -Prefix "r13mqs" -Key "$($gitIdentity.Branch)|$($gitIdentity.Head)|$($gitIdentity.Tree)|$signoffRef"
        repository = $script:R13RepositoryName
        branch = [string]$gitIdentity.Branch
        head = [string]$gitIdentity.Head
        tree = [string]$gitIdentity.Tree
        source_milestone = $script:R13Milestone
        source_task = $script:R13SourceTask
        signoff_scope = "bounded R13 representative QA failure-to-fix loop and evidence-backed operator workflow slice"
        required_evidence = @($rows)
        evidence_assessment = [pscustomobject][ordered]@{
            local_qa_failure_to_fix_proof = $assessment.LocalQa
            passed_external_replay_proof = $assessment.ExternalReplay
            current_control_room_evidence = $assessment.ControlRoom
            operator_demo_evidence = $assessment.OperatorDemo
            runner_evidence = $assessment.Runner
            skill_invocation_evidence = $assessment.Skills
            all_required_evidence_present_current_validated = $passed
        }
        gate_assessment = [pscustomobject][ordered]@{
            meaningful_qa_loop_hard_gate = "delivered_for_bounded_representative_scope_only"
            meaningful_qa_loop_full_product_scope = "not_delivered"
            api_custom_runner_bypass = "partial_local_only"
            current_operator_control_room = "partial_repo_generated_evidence_only"
            skill_invocation_evidence = "partial_local_invocation_evidence_only"
            operator_demo = "partial_markdown_demo_evidence_only"
            production_qa = "not_delivered"
            production_runtime = "not_delivered"
            productized_ui = "not_delivered"
            r13_closeout = "not_closed"
            r14_or_successor = "not_opened"
        }
        residual_risks = @($residualRisks)
        blockers = @($blockers)
        signoff_decision = $decision
        aggregate_verdict = $verdict
        evidence_refs = @($evidenceRefs)
        generated_at_utc = Get-UtcTimestamp
        non_claims = @($script:RequiredNonClaims)
    }

    $matrix = [pscustomobject][ordered]@{
        artifact_type = "r13_meaningful_qa_signoff_evidence_matrix"
        matrix_id = Get-StableId -Prefix "r13mqsem" -Key "$($gitIdentity.Branch)|$($gitIdentity.Head)|$($gitIdentity.Tree)|$matrixRef"
        repository = $script:R13RepositoryName
        branch = [string]$gitIdentity.Branch
        head = [string]$gitIdentity.Head
        tree = [string]$gitIdentity.Tree
        source_milestone = $script:R13Milestone
        source_task = $script:R13SourceTask
        source_signoff_ref = $signoffRef
        evidence_rows = @($rows)
        coverage_summary = [pscustomobject][ordered]@{
            required_evidence_count = @($rows).Count
            passed_evidence_count = @($rows | Where-Object { [string]$_.verdict -eq "passed" }).Count
            failed_evidence_count = @($rows | Where-Object { [string]$_.verdict -eq "failed" }).Count
            blocked_evidence_count = @($rows | Where-Object { [string]$_.verdict -eq "blocked" }).Count
            bounded_scope_covered = $passed
            full_product_scope_covered = $false
            production_scope_covered = $false
        }
        missing_evidence = @($missingRows | ForEach-Object { [string]$_.evidence_id })
        residual_risks = @($residualRisks)
        aggregate_verdict = $verdict
        evidence_refs = @(
            (New-EvidenceRef -RefId "r13-012-signoff" -Ref $signoffRef -EvidenceKind "meaningful_qa_signoff"),
            (New-EvidenceRef -RefId "r13-012-evidence-matrix-contract" -Ref "contracts/actionable_qa/r13_meaningful_qa_signoff_evidence_matrix.contract.json" -EvidenceKind "contract" -AuthorityKind "repo_contract"),
            (New-EvidenceRef -RefId "r13-012-evidence-matrix-validator" -Ref "tools/validate_r13_meaningful_qa_signoff_evidence_matrix.ps1" -EvidenceKind "validator" -AuthorityKind "repo_tooling")
        )
        non_claims = @($script:RequiredNonClaims)
    }

    return [pscustomobject][ordered]@{
        Signoff = $signoff
        Matrix = $matrix
        ManifestPath = $manifestRef
    }
}

function Export-R13MeaningfulQaSignoffValidationManifest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SignoffPath,
        [Parameter(Mandatory = $true)]
        [string]$MatrixPath,
        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )

    if (-not (Test-Path -LiteralPath (Resolve-RepositoryPath -PathValue $OutputPath))) {
        Write-R13SignoffTextFile -Path $OutputPath -Value "# R13 Meaningful QA Signoff Validation Manifest`n`nPending regeneration by R13-012 signoff tooling.`n"
    }

    $signoffValidation = Test-R13MeaningfulQaSignoff -SignoffPath $SignoffPath
    $matrixValidation = Test-R13MeaningfulQaSignoffEvidenceMatrix -MatrixPath $MatrixPath
    $signoff = Get-JsonDocument -Path $SignoffPath -Label "R13 meaningful QA signoff"
    $matrix = Get-JsonDocument -Path $MatrixPath -Label "R13 meaningful QA signoff evidence matrix"
    $outputRef = Convert-ToRepositoryRelativePath -PathValue $OutputPath

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# R13 Meaningful QA Signoff Validation Manifest") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add('- artifact_type: `r13_meaningful_qa_signoff_validation_manifest`') | Out-Null
    $lines.Add(('- source_signoff_ref: `{0}`' -f (Convert-ToRepositoryRelativePath -PathValue $SignoffPath))) | Out-Null
    $lines.Add(('- source_evidence_matrix_ref: `{0}`' -f (Convert-ToRepositoryRelativePath -PathValue $MatrixPath))) | Out-Null
    $lines.Add(('- generated_at_utc: `{0}`' -f (Get-UtcTimestamp))) | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## Decision") | Out-Null
    $lines.Add(('- Signoff decision: `{0}`' -f $signoff.signoff_decision)) | Out-Null
    $lines.Add(('- Aggregate verdict: `{0}`' -f $signoff.aggregate_verdict)) | Out-Null
    $lines.Add(('- Scope: `{0}`' -f $signoff.signoff_scope)) | Out-Null
    $lines.Add(('- Matrix verdict: `{0}`' -f $matrix.aggregate_verdict)) | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## Evidence Coverage") | Out-Null
    $lines.Add(('- Required evidence rows: `{0}`' -f $matrix.coverage_summary.required_evidence_count)) | Out-Null
    $lines.Add(('- Passed evidence rows: `{0}`' -f $matrix.coverage_summary.passed_evidence_count)) | Out-Null
    $lines.Add(('- Missing evidence: `{0}`' -f (@($matrix.missing_evidence).Count))) | Out-Null
    $lines.Add(('- Signoff validator result: `{0}`' -f $signoffValidation.AggregateVerdict)) | Out-Null
    $lines.Add(('- Matrix validator result: `{0}`' -f $matrixValidation.AggregateVerdict)) | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## External Replay") | Out-Null
    $lines.Add(('- Run ID: `{0}`' -f $signoff.evidence_assessment.passed_external_replay_proof.run_id)) | Out-Null
    $lines.Add(('- Artifact ID: `{0}`' -f $signoff.evidence_assessment.passed_external_replay_proof.artifact_id)) | Out-Null
    $lines.Add(('- Artifact digest: `{0}`' -f $signoff.evidence_assessment.passed_external_replay_proof.artifact_digest)) | Out-Null
    $lines.Add(('- Commands: `{0}` total, `{1}` passed' -f $signoff.evidence_assessment.passed_external_replay_proof.command_count, $signoff.evidence_assessment.passed_external_replay_proof.passed_command_count)) | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## Residual Risks") | Out-Null
    foreach ($risk in @($signoff.residual_risks)) {
        $lines.Add("- $risk") | Out-Null
    }
    $lines.Add("") | Out-Null
    $lines.Add("## Explicit Non-Claims") | Out-Null
    foreach ($nonClaim in @($signoff.non_claims)) {
        $lines.Add("- $nonClaim") | Out-Null
    }
    $lines.Add("") | Out-Null
    $lines.Add(('- Validation manifest ref: `{0}`' -f $outputRef)) | Out-Null

    Write-R13SignoffTextFile -Path $OutputPath -Value (($lines -join "`n") + "`n")
    return [pscustomobject][ordered]@{
        ManifestPath = $outputRef
        SignoffDecision = [string]$signoff.signoff_decision
        AggregateVerdict = [string]$signoff.aggregate_verdict
        EvidenceRows = @($matrix.evidence_rows).Count
    }
}

function New-R13MeaningfulQaSignoffArtifacts {
    [CmdletBinding()]
    param(
        [string]$SignoffPath = "state/signoff/r13_meaningful_qa_signoff/r13_012_signoff.json",
        [string]$MatrixPath = "state/signoff/r13_meaningful_qa_signoff/r13_012_evidence_matrix.json",
        [string]$ManifestPath = "state/signoff/r13_meaningful_qa_signoff/validation_manifest.md"
    )

    $objects = New-R13MeaningfulQaSignoffObjects -SignoffPath $SignoffPath -MatrixPath $MatrixPath -ManifestPath $ManifestPath
    Write-R13SignoffJsonFile -Path $SignoffPath -Value $objects.Signoff
    Write-R13SignoffJsonFile -Path $MatrixPath -Value $objects.Matrix
    $manifest = Export-R13MeaningfulQaSignoffValidationManifest -SignoffPath $SignoffPath -MatrixPath $MatrixPath -OutputPath $ManifestPath
    return [pscustomobject][ordered]@{
        SignoffPath = (Convert-ToRepositoryRelativePath -PathValue $SignoffPath)
        MatrixPath = (Convert-ToRepositoryRelativePath -PathValue $MatrixPath)
        ManifestPath = $manifest.ManifestPath
        SignoffDecision = [string]$objects.Signoff.signoff_decision
        AggregateVerdict = [string]$objects.Signoff.aggregate_verdict
        SignoffScope = [string]$objects.Signoff.signoff_scope
    }
}

function Assert-SignoffIdentity {
    param(
        [Parameter(Mandatory = $true)]
        $Signoff,
        [Parameter(Mandatory = $true)]
        [string]$SourceLabel
    )

    if ($Signoff.repository -ne $script:R13RepositoryName) {
        throw "$SourceLabel repository must be '$script:R13RepositoryName'."
    }
    if ($Signoff.branch -ne $script:R13Branch) {
        throw "$SourceLabel branch must be '$script:R13Branch'."
    }
    Assert-GitObjectId -Value $Signoff.head -Context "$SourceLabel head"
    Assert-GitObjectId -Value $Signoff.tree -Context "$SourceLabel tree"
    if ($Signoff.source_milestone -ne $script:R13Milestone) {
        throw "$SourceLabel source_milestone must be '$script:R13Milestone'."
    }
    if ($Signoff.source_task -ne $script:R13SourceTask) {
        throw "$SourceLabel source_task must be '$script:R13SourceTask'."
    }
}

function Assert-EvidenceRows {
    param(
        [Parameter(Mandatory = $true)]
        $Rows,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $rowItems = Assert-ObjectArray -Value $Rows -Context $Context
    $requiredIds = @(Get-R13RequiredEvidenceSpecs | ForEach-Object { [string]$_.evidence_id })
    $actualIds = @($rowItems | ForEach-Object { [string]$_.evidence_id })
    foreach ($requiredId in $requiredIds) {
        if ($actualIds -notcontains $requiredId) {
            throw "$Context is missing required evidence row '$requiredId'."
        }
    }
    foreach ($row in @($rowItems)) {
        Assert-RequiredObjectFields -Object $row -FieldNames @("evidence_id", "required_for", "expected_ref", "actual_ref", "status", "validator", "verdict", "notes") -Context "$Context row"
        Assert-ExistingRef -Ref ([string]$row.actual_ref) -Context "$Context actual_ref"
        Assert-RepositoryRelativePath -PathValue ([string]$row.expected_ref) -Context "$Context expected_ref"
        Assert-AllowedValue -Value ([string]$row.verdict) -AllowedValues $script:AllowedEvidenceVerdicts -Context "$Context verdict"
        Assert-NonEmptyString -Value $row.status -Context "$Context status" | Out-Null
        Assert-NonEmptyString -Value $row.validator -Context "$Context validator" | Out-Null
        Assert-NonEmptyString -Value $row.notes -Context "$Context notes" | Out-Null
    }

    return @($rowItems)
}

function Test-R13MeaningfulQaSignoffEvidenceMatrixObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Matrix,
        [string]$SourceLabel = "R13 meaningful QA signoff evidence matrix"
    )

    $contract = Get-R13SignoffEvidenceMatrixContract
    Assert-RequiredObjectFields -Object $Matrix -FieldNames $contract.required_fields -Context $SourceLabel
    if ($Matrix.artifact_type -ne "r13_meaningful_qa_signoff_evidence_matrix") {
        throw "$SourceLabel artifact_type must be r13_meaningful_qa_signoff_evidence_matrix."
    }
    Assert-NonEmptyString -Value $Matrix.matrix_id -Context "$SourceLabel matrix_id" | Out-Null
    Assert-ExistingRef -Ref ([string]$Matrix.source_signoff_ref) -Context "$SourceLabel source_signoff_ref"
    $rows = Assert-EvidenceRows -Rows $Matrix.evidence_rows -Context "$SourceLabel evidence_rows"
    $coverage = Assert-ObjectValue -Value $Matrix.coverage_summary -Context "$SourceLabel coverage_summary"
    Assert-RequiredObjectFields -Object $coverage -FieldNames @("required_evidence_count", "passed_evidence_count", "failed_evidence_count", "blocked_evidence_count", "bounded_scope_covered", "full_product_scope_covered", "production_scope_covered") -Context "$SourceLabel coverage_summary"
    $missingEvidence = Assert-StringArray -Value $Matrix.missing_evidence -Context "$SourceLabel missing_evidence" -AllowEmpty
    Assert-StringArray -Value $Matrix.residual_risks -Context "$SourceLabel residual_risks" | Out-Null
    $aggregateVerdict = Assert-NonEmptyString -Value $Matrix.aggregate_verdict -Context "$SourceLabel aggregate_verdict"
    Assert-AllowedValue -Value $aggregateVerdict -AllowedValues $script:AllowedAggregateVerdicts -Context "$SourceLabel aggregate_verdict"
    Assert-RefArray -Value $Matrix.evidence_refs -Context "$SourceLabel evidence_refs" -RequireExists | Out-Null
    $nonClaims = Assert-StringArray -Value $Matrix.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel
    Assert-NoForbiddenR13SignoffClaims -Value $Matrix -Context $SourceLabel

    if ($aggregateVerdict -eq "passed") {
        if (@($rows | Where-Object { [string]$_.verdict -ne "passed" }).Count -ne 0) {
            throw "$SourceLabel passed aggregate verdict requires all rows to pass."
        }
        if (@($missingEvidence).Count -ne 0) {
            throw "$SourceLabel passed aggregate verdict requires empty missing_evidence."
        }
        if (-not [bool]$coverage.bounded_scope_covered -or [bool]$coverage.full_product_scope_covered -or [bool]$coverage.production_scope_covered) {
            throw "$SourceLabel passed verdict must cover bounded scope only."
        }
    }

    return [pscustomobject][ordered]@{
        MatrixId = [string]$Matrix.matrix_id
        SourceSignoffRef = [string]$Matrix.source_signoff_ref
        EvidenceRowCount = @($rows).Count
        AggregateVerdict = $aggregateVerdict
    }
}

function Test-R13MeaningfulQaSignoffEvidenceMatrix {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$MatrixPath
    )

    $matrix = Get-JsonDocument -Path $MatrixPath -Label "R13 meaningful QA signoff evidence matrix"
    return Test-R13MeaningfulQaSignoffEvidenceMatrixObject -Matrix $matrix -SourceLabel "R13 meaningful QA signoff evidence matrix"
}

function Test-R13MeaningfulQaSignoffObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Signoff,
        [string]$SourceLabel = "R13 meaningful QA signoff"
    )

    $contract = Get-R13SignoffContract
    Assert-RequiredObjectFields -Object $Signoff -FieldNames $contract.required_fields -Context $SourceLabel
    if ($Signoff.contract_version -ne "v1") {
        throw "$SourceLabel contract_version must be v1."
    }
    if ($Signoff.artifact_type -ne "r13_meaningful_qa_signoff") {
        throw "$SourceLabel artifact_type must be r13_meaningful_qa_signoff."
    }
    Assert-NonEmptyString -Value $Signoff.signoff_id -Context "$SourceLabel signoff_id" | Out-Null
    Assert-SignoffIdentity -Signoff $Signoff -SourceLabel $SourceLabel
    $scope = Assert-NonEmptyString -Value $Signoff.signoff_scope -Context "$SourceLabel signoff_scope"
    if ($scope -notmatch '(?i)\bbounded\b' -or $scope -notmatch '(?i)\brepresentative\b') {
        throw "$SourceLabel signoff_scope must be bounded and representative."
    }
    $decision = Assert-NonEmptyString -Value $Signoff.signoff_decision -Context "$SourceLabel signoff_decision"
    Assert-AllowedValue -Value $decision -AllowedValues $script:AllowedSignoffDecisions -Context "$SourceLabel signoff_decision"
    $aggregateVerdict = Assert-NonEmptyString -Value $Signoff.aggregate_verdict -Context "$SourceLabel aggregate_verdict"
    Assert-AllowedValue -Value $aggregateVerdict -AllowedValues $script:AllowedAggregateVerdicts -Context "$SourceLabel aggregate_verdict"
    $rows = Assert-EvidenceRows -Rows $Signoff.required_evidence -Context "$SourceLabel required_evidence"
    $evidenceRefs = Assert-RefArray -Value $Signoff.evidence_refs -Context "$SourceLabel evidence_refs" -RequireExists
    $refIds = @($evidenceRefs | ForEach-Object { [string]$_.ref_id })
    foreach ($spec in @(Get-R13RequiredEvidenceSpecs)) {
        if ($refIds -notcontains [string]$spec.evidence_id) {
            throw "$SourceLabel evidence_refs must include '$($spec.evidence_id)'."
        }
    }
    if ($refIds -notcontains "r13-012-evidence-matrix") {
        throw "$SourceLabel evidence_refs must include r13-012-evidence-matrix."
    }
    $refMap = Get-EvidenceRefMap -EvidenceRefs $Signoff.evidence_refs -Context "$SourceLabel evidence_refs"
    $gitIdentity = Get-R13SignoffGitIdentity
    if ([string]$Signoff.branch -ne [string]$gitIdentity.Branch -or [string]$Signoff.head -ne [string]$gitIdentity.Head -or [string]$Signoff.tree -ne [string]$gitIdentity.Tree) {
        throw "$SourceLabel must match current branch/head/tree."
    }
    Test-R13PrerequisiteEvidence -GitIdentity $gitIdentity -EvidenceRefMap $refMap | Out-Null
    $matrixRef = [string]$refMap["r13-012-evidence-matrix"]
    Test-R13MeaningfulQaSignoffEvidenceMatrix -MatrixPath $matrixRef | Out-Null

    $evidenceAssessment = Assert-ObjectValue -Value $Signoff.evidence_assessment -Context "$SourceLabel evidence_assessment"
    Assert-RequiredObjectFields -Object $evidenceAssessment -FieldNames @("local_qa_failure_to_fix_proof", "passed_external_replay_proof", "current_control_room_evidence", "operator_demo_evidence", "runner_evidence", "skill_invocation_evidence", "all_required_evidence_present_current_validated") -Context "$SourceLabel evidence_assessment"
    if (-not [bool]$evidenceAssessment.all_required_evidence_present_current_validated) {
        throw "$SourceLabel evidence_assessment must mark all required evidence present/current/validated for accepted signoff."
    }
    $gateAssessment = Assert-ObjectValue -Value $Signoff.gate_assessment -Context "$SourceLabel gate_assessment"
    Assert-RequiredObjectFields -Object $gateAssessment -FieldNames @("meaningful_qa_loop_hard_gate", "meaningful_qa_loop_full_product_scope", "api_custom_runner_bypass", "current_operator_control_room", "skill_invocation_evidence", "operator_demo", "production_qa", "production_runtime", "productized_ui", "r13_closeout", "r14_or_successor") -Context "$SourceLabel gate_assessment"
    if ([string]$gateAssessment.meaningful_qa_loop_hard_gate -ne "delivered_for_bounded_representative_scope_only") {
        throw "$SourceLabel must mark meaningful QA loop delivered only for bounded representative scope."
    }
    if ([string]$gateAssessment.meaningful_qa_loop_full_product_scope -ne "not_delivered") {
        throw "$SourceLabel must not mark the full product meaningful QA loop delivered."
    }
    foreach ($fieldName in @("production_qa", "production_runtime", "productized_ui")) {
        if ([string]$gateAssessment.$fieldName -ne "not_delivered") {
            throw "$SourceLabel gate_assessment.$fieldName must be not_delivered."
        }
    }
    if ([string]$gateAssessment.r13_closeout -ne "not_closed" -or [string]$gateAssessment.r14_or_successor -ne "not_opened") {
        throw "$SourceLabel must not close R13 or open R14/successor."
    }

    $residualRisks = Assert-StringArray -Value $Signoff.residual_risks -Context "$SourceLabel residual_risks"
    $blockers = Assert-StringArray -Value $Signoff.blockers -Context "$SourceLabel blockers" -AllowEmpty
    $nonClaims = Assert-StringArray -Value $Signoff.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel
    Assert-TimestampString -Value $Signoff.generated_at_utc -Context "$SourceLabel generated_at_utc"
    Assert-NoForbiddenR13SignoffClaims -Value $Signoff -Context $SourceLabel

    if ($decision -eq "accepted_bounded_scope") {
        if ($aggregateVerdict -ne "passed") {
            throw "$SourceLabel accepted_bounded_scope requires aggregate_verdict passed."
        }
        if (@($blockers).Count -ne 0) {
            throw "$SourceLabel accepted_bounded_scope requires no blockers."
        }
        if (@($rows | Where-Object { [string]$_.verdict -ne "passed" }).Count -ne 0) {
            throw "$SourceLabel accepted_bounded_scope requires all required evidence rows to pass."
        }
    }
    elseif ($aggregateVerdict -eq "passed") {
        throw "$SourceLabel passed aggregate verdict is allowed only with accepted_bounded_scope."
    }

    return [pscustomobject][ordered]@{
        SignoffId = [string]$Signoff.signoff_id
        Branch = [string]$Signoff.branch
        Head = [string]$Signoff.head
        Tree = [string]$Signoff.tree
        SignoffDecision = $decision
        AggregateVerdict = $aggregateVerdict
        SignoffScope = $scope
        ResidualRiskCount = @($residualRisks).Count
        EvidenceRowCount = @($rows).Count
    }
}

function Test-R13MeaningfulQaSignoff {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SignoffPath
    )

    $signoff = Get-JsonDocument -Path $SignoffPath -Label "R13 meaningful QA signoff"
    return Test-R13MeaningfulQaSignoffObject -Signoff $signoff -SourceLabel "R13 meaningful QA signoff"
}

Export-ModuleMember -Function Get-RepositoryRoot, Resolve-RepositoryPath, Convert-ToRepositoryRelativePath, Get-UtcTimestamp, Get-JsonDocument, Write-R13SignoffJsonFile, Write-R13SignoffTextFile, Get-R13SignoffGitIdentity, Get-R13RequiredEvidenceSpecs, New-R13MeaningfulQaSignoffObjects, New-R13MeaningfulQaSignoffArtifacts, Export-R13MeaningfulQaSignoffValidationManifest, Test-R13MeaningfulQaSignoffObject, Test-R13MeaningfulQaSignoff, Test-R13MeaningfulQaSignoffEvidenceMatrixObject, Test-R13MeaningfulQaSignoffEvidenceMatrix
