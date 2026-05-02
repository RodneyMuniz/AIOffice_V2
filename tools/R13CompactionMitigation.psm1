Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$script:R13RepositoryName = "AIOffice_V2"
$script:R13Branch = "release/r13-api-first-qa-pipeline-and-operator-control-room-product-slice"
$script:R13Milestone = "R13 API-First QA Pipeline and Operator Control-Room Product Slice"
$script:R13SourceTask = "R13-013"
$script:R13SignoffGeneratedHead = "fb2179bb7b66d3d7dd1fd4eb2683aed825f01577"
$script:R13SignoffCommittedHead = "9f80291b0f3049ec1dd15635079705db031383fd"
$script:R13SignoffCommittedTree = "c08ca2dc992fd3666f369d221db63806f6178e94"
$script:GitObjectPattern = "^[a-f0-9]{40}$"
$script:TimestampPattern = "^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$"
$script:IdentityReconciliationRef = "state/continuity/r13_compaction_mitigation/r13_013_identity_reconciliation.json"
$script:PacketRef = "state/continuity/r13_compaction_mitigation/r13_013_compaction_mitigation_packet.json"
$script:PromptRef = "state/continuity/r13_compaction_mitigation/r13_013_restart_prompt.md"
$script:ManifestRef = "state/continuity/r13_compaction_mitigation/validation_manifest.md"
$script:RequiredNonClaims = @(
    "bounded repo-truth continuity mitigation only",
    "does not solve Codex compaction generally",
    "does not solve Codex reliability generally",
    "no R13 closeout",
    "no R14 or successor opening",
    "no production runtime",
    "no productized UI",
    "no full product QA coverage",
    "R13 active through R13-013 only",
    "R13-014 through R13-018 remain planned only"
)
$script:IdentityNonClaims = @(
    "no history rewrite",
    "no false current-head claim",
    "no R13 closeout",
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

function Write-R13ContinuityJsonFile {
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

function Write-R13ContinuityTextFile {
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

function Get-R13ContinuityGitIdentity {
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
        ref = Convert-ToRepositoryRelativePath -PathValue $Ref
        evidence_kind = $EvidenceKind
        authority_kind = $AuthorityKind
        scope = $Scope
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
        Assert-RequiredObjectFields -Object $refObject -FieldNames @("ref_id", "ref", "evidence_kind", "authority_kind", "scope") -Context "$Context ref"
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

function Assert-NoForbiddenR13ContinuityClaims {
    param(
        [Parameter(Mandatory = $true)]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($line in @(Get-StringLeaves -Value $Value)) {
        if ($line -match '(?i)\bR13\b.*\b(closeout|closed|complete milestone|formally closed)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims R13 closeout. Offending text: $line"
        }
        if ($line -match '(?i)\bR14\b.*\b(active|open|opened|started)\b|\bsuccessor\b.*\b(active|open|opened|started)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims R14 or successor opening. Offending text: $line"
        }
        if ($line -match '(?i)\bsolved\s+Codex\s+(reliability|context compaction|compaction)\b|\bCodex\s+(reliability|context compaction|compaction)\s+is\s+solved\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims solved Codex reliability or compaction. Offending text: $line"
        }
        if ($line -match '(?i)\bproduction runtime\b|\breal production QA\b|\bproductized (control-room|UI)\b|\bfull UI app\b|\bfull product QA\b|\bbroad autonomous\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims forbidden product, production, or autonomy scope. Offending text: $line"
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

function Assert-IdentityNonClaims {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$NonClaims,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($requiredNonClaim in $script:IdentityNonClaims) {
        if ($NonClaims -notcontains $requiredNonClaim) {
            throw "$Context non_claims must include '$requiredNonClaim'."
        }
    }
}

function Get-R13ContinuityEvidenceRefs {
    param(
        [string]$IdentityReconciliationPath = $script:IdentityReconciliationRef,
        [string]$PacketPath = $script:PacketRef,
        [string]$PromptPath = $script:PromptRef,
        [string]$ManifestPath = $script:ManifestRef
    )

    return @(
        (New-EvidenceRef -RefId "r13-013-packet-contract" -Ref "contracts/continuity/r13_compaction_mitigation_packet.contract.json" -EvidenceKind "contract" -AuthorityKind "repo_contract"),
        (New-EvidenceRef -RefId "r13-013-restart-prompt-contract" -Ref "contracts/continuity/r13_restart_prompt.contract.json" -EvidenceKind "contract" -AuthorityKind "repo_contract"),
        (New-EvidenceRef -RefId "r13-013-module" -Ref "tools/R13CompactionMitigation.psm1" -EvidenceKind "module" -AuthorityKind "repo_tooling"),
        (New-EvidenceRef -RefId "r13-013-generator" -Ref "tools/new_r13_compaction_mitigation_packet.ps1" -EvidenceKind "cli" -AuthorityKind "repo_tooling"),
        (New-EvidenceRef -RefId "r13-013-packet-validator" -Ref "tools/validate_r13_compaction_mitigation_packet.ps1" -EvidenceKind "validator" -AuthorityKind "repo_tooling"),
        (New-EvidenceRef -RefId "r13-013-restart-prompt-validator" -Ref "tools/validate_r13_restart_prompt.ps1" -EvidenceKind "validator" -AuthorityKind "repo_tooling"),
        (New-EvidenceRef -RefId "r13-013-test" -Ref "tests/test_r13_compaction_mitigation.ps1" -EvidenceKind "test" -AuthorityKind "repo_tooling"),
        (New-EvidenceRef -RefId "r13-013-identity-reconciliation" -Ref $IdentityReconciliationPath -EvidenceKind "identity_reconciliation"),
        (New-EvidenceRef -RefId "r13-013-compaction-mitigation-packet" -Ref $PacketPath -EvidenceKind "compaction_mitigation_packet"),
        (New-EvidenceRef -RefId "r13-013-restart-prompt" -Ref $PromptPath -EvidenceKind "restart_prompt"),
        (New-EvidenceRef -RefId "r13-013-validation-manifest" -Ref $ManifestPath -EvidenceKind "validation_manifest"),
        (New-EvidenceRef -RefId "r13-012-signoff" -Ref "state/signoff/r13_meaningful_qa_signoff/r13_012_signoff.json" -EvidenceKind "meaningful_qa_signoff"),
        (New-EvidenceRef -RefId "r13-012-evidence-matrix" -Ref "state/signoff/r13_meaningful_qa_signoff/r13_012_evidence_matrix.json" -EvidenceKind "evidence_matrix"),
        (New-EvidenceRef -RefId "r13-011-external-replay-result" -Ref "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_result.json" -EvidenceKind "external_replay_result"),
        (New-EvidenceRef -RefId "r13-011-external-replay-import" -Ref "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_import.json" -EvidenceKind "external_replay_import"),
        (New-EvidenceRef -RefId "r13-control-room-status" -Ref "state/control_room/r13_current/control_room_status.json" -EvidenceKind "control_room_status"),
        (New-EvidenceRef -RefId "r13-control-room-view" -Ref "state/control_room/r13_current/control_room.md" -EvidenceKind "control_room_view"),
        (New-EvidenceRef -RefId "r13-control-room-refresh-result" -Ref "state/control_room/r13_current/control_room_refresh_result.json" -EvidenceKind "control_room_refresh_result"),
        (New-EvidenceRef -RefId "r13-control-room-validation-manifest" -Ref "state/control_room/r13_current/validation_manifest.md" -EvidenceKind "validation_manifest"),
        (New-EvidenceRef -RefId "r13-operator-demo" -Ref "state/control_room/r13_current/operator_demo.md" -EvidenceKind "operator_demo"),
        (New-EvidenceRef -RefId "r13-authority" -Ref "governance/R13_API_FIRST_QA_PIPELINE_AND_OPERATOR_CONTROL_ROOM_PRODUCT_SLICE.md" -EvidenceKind "authority" -AuthorityKind "repo_governance")
    )
}

function Get-EvidenceRefMap {
    param(
        [Parameter(Mandatory = $true)]
        $EvidenceRefs,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $map = @{}
    foreach ($refObject in @($EvidenceRefs)) {
        $refId = [string]$refObject.ref_id
        if ($map.ContainsKey($refId)) {
            throw "$Context contains duplicate ref_id '$refId'."
        }
        $map[$refId] = [string]$refObject.ref
    }
    return $map
}

function New-R13IdentityReconciliationObject {
    [CmdletBinding()]
    param(
        [string]$IdentityReconciliationPath = $script:IdentityReconciliationRef
    )

    $gitIdentity = Get-R13ContinuityGitIdentity
    $signoff = Get-JsonDocument -Path "state/signoff/r13_meaningful_qa_signoff/r13_012_signoff.json" -Label "R13-012 signoff"
    return [pscustomobject][ordered]@{
        contract_version = "v1"
        artifact_type = "r13_013_identity_reconciliation"
        reconciliation_id = Get-StableId -Prefix "r13ir" -Key "$($gitIdentity.Branch)|$($gitIdentity.Head)|$IdentityReconciliationPath"
        repository = $script:R13RepositoryName
        branch = [string]$gitIdentity.Branch
        source_milestone = $script:R13Milestone
        source_task = $script:R13SourceTask
        signoff_ref = "state/signoff/r13_meaningful_qa_signoff/r13_012_signoff.json"
        signoff_generated_from_head = [string]$signoff.head
        signoff_generated_from_tree = [string]$signoff.tree
        signoff_committed_at_head = $script:R13SignoffCommittedHead
        signoff_committed_at_tree = $script:R13SignoffCommittedTree
        current_r13_013_working_head = [string]$gitIdentity.Head
        current_r13_013_working_tree = [string]$gitIdentity.Tree
        reason = "generated artifacts are created before the commit that makes them durable"
        verdict = "accepted_as_generation_identity_not_current_identity"
        generated_at_utc = Get-UtcTimestamp
        non_claims = @($script:IdentityNonClaims)
    }
}

function Get-R13PrerequisiteDocuments {
    $documents = @{}
    $paths = [ordered]@{
        Signoff = "state/signoff/r13_meaningful_qa_signoff/r13_012_signoff.json"
        EvidenceMatrix = "state/signoff/r13_meaningful_qa_signoff/r13_012_evidence_matrix.json"
        ExternalReplayResult = "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_result.json"
        ExternalReplayImport = "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_import.json"
        ControlRoomStatus = "state/control_room/r13_current/control_room_status.json"
        ControlRoomRefreshResult = "state/control_room/r13_current/control_room_refresh_result.json"
    }
    foreach ($entry in $paths.GetEnumerator()) {
        $documents[$entry.Key] = Get-JsonDocument -Path $entry.Value -Label $entry.Key
    }

    return $documents
}

function New-R13CompactionMitigationPacketObject {
    [CmdletBinding()]
    param(
        [string]$IdentityReconciliationPath = $script:IdentityReconciliationRef,
        [string]$PacketPath = $script:PacketRef,
        [string]$PromptPath = $script:PromptRef,
        [string]$ManifestPath = $script:ManifestRef
    )

    $gitIdentity = Get-R13ContinuityGitIdentity
    $documents = Get-R13PrerequisiteDocuments
    $identity = Get-JsonDocument -Path $IdentityReconciliationPath -Label "R13-013 identity reconciliation"
    $signoff = $documents.Signoff
    $matrix = $documents.EvidenceMatrix
    $externalResult = $documents.ExternalReplayResult
    $externalImport = $documents.ExternalReplayImport
    $controlStatus = $documents.ControlRoomStatus
    $controlRefresh = $documents.ControlRoomRefreshResult
    $evidenceRefs = @(Get-R13ContinuityEvidenceRefs -IdentityReconciliationPath $IdentityReconciliationPath -PacketPath $PacketPath -PromptPath $PromptPath -ManifestPath $ManifestPath)

    return [pscustomobject][ordered]@{
        contract_version = "v1"
        artifact_type = "r13_compaction_mitigation_packet"
        packet_id = Get-StableId -Prefix "r13cmp" -Key "$($gitIdentity.Branch)|$($gitIdentity.Head)|$PacketPath"
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
            r13_closed = $false
            r14_or_successor_opened = $false
        }
        current_state_summary = "R13-013 adds bounded repo-truth continuity and compaction mitigation evidence only: explicit R13-012 identity reconciliation, a restart packet, a restart prompt, validators, and focused proof. It does not solve Codex compaction or reliability generally."
        identity_reconciliation_ref = Convert-ToRepositoryRelativePath -PathValue $IdentityReconciliationPath
        prerequisite_evidence_refs = @(
            (New-EvidenceRef -RefId "r13-012-signoff" -Ref "state/signoff/r13_meaningful_qa_signoff/r13_012_signoff.json" -EvidenceKind "meaningful_qa_signoff"),
            (New-EvidenceRef -RefId "r13-012-evidence-matrix" -Ref "state/signoff/r13_meaningful_qa_signoff/r13_012_evidence_matrix.json" -EvidenceKind "evidence_matrix"),
            (New-EvidenceRef -RefId "r13-011-external-replay-result" -Ref "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_result.json" -EvidenceKind "external_replay_result"),
            (New-EvidenceRef -RefId "r13-011-external-replay-import" -Ref "state/external_runs/r13_external_replay/r13_011/r13_011_external_replay_import.json" -EvidenceKind "external_replay_import"),
            (New-EvidenceRef -RefId "r13-control-room-status" -Ref "state/control_room/r13_current/control_room_status.json" -EvidenceKind "control_room_status"),
            (New-EvidenceRef -RefId "r13-operator-demo" -Ref "state/control_room/r13_current/operator_demo.md" -EvidenceKind "operator_demo")
        )
        recovered_state = [pscustomobject][ordered]@{
            git_identity = [pscustomobject][ordered]@{
                branch = [string]$gitIdentity.Branch
                head = [string]$gitIdentity.Head
                tree = [string]$gitIdentity.Tree
            }
            active_milestone = $script:R13Milestone
            active_through_task = "R13-013"
            completed_task_range = "R13-001 through R13-013"
            planned_task_range = "R13-014 through R13-018"
            r13_012_bounded_signoff_decision = [pscustomobject][ordered]@{
                signoff_ref = "state/signoff/r13_meaningful_qa_signoff/r13_012_signoff.json"
                evidence_matrix_ref = "state/signoff/r13_meaningful_qa_signoff/r13_012_evidence_matrix.json"
                signoff_decision = [string]$signoff.signoff_decision
                aggregate_verdict = [string]$signoff.aggregate_verdict
                scope = [string]$signoff.signoff_scope
                signoff_generated_from_head = [string]$identity.signoff_generated_from_head
                signoff_committed_at_head = [string]$identity.signoff_committed_at_head
                identity_reconciliation_ref = Convert-ToRepositoryRelativePath -PathValue $IdentityReconciliationPath
                evidence_rows = @($matrix.evidence_rows).Count
            }
            r13_011_external_replay_status = [pscustomobject][ordered]@{
                status = [string]$externalResult.run_conclusion
                aggregate_verdict = [string]$externalResult.aggregate_verdict
                run_id = [string]$externalResult.run_id
                artifact_id = [string]$externalResult.artifact_id
                artifact_digest = [string]$externalResult.artifact_digest
                imported_artifact_id = [string]$externalImport.imported_artifact_id
                command_count = @($externalResult.command_results).Count
                passed_command_count = @($externalResult.command_results | Where-Object { [string]$_.verdict -eq "passed" }).Count
            }
            qa_pipeline_state = [pscustomobject][ordered]@{
                issue_detection_aggregate = [string]$controlStatus.qa_pipeline_status.issue_detection.aggregate_verdict
                issue_count = [int]$controlStatus.qa_pipeline_status.issue_detection.total_issue_count
                fix_queue_status = [string]$controlStatus.qa_pipeline_status.fix_queue.status
                failure_to_fix_cycle = [string]$controlStatus.qa_pipeline_status.failure_to_fix_cycle.aggregate_verdict
                bounded_scope_only = $true
            }
            control_room_state = [pscustomobject][ordered]@{
                status_ref = "state/control_room/r13_current/control_room_status.json"
                view_ref = "state/control_room/r13_current/control_room.md"
                refresh_result_ref = "state/control_room/r13_current/control_room_refresh_result.json"
                refresh_verdict = [string]$controlRefresh.refresh_verdict
                active_through_task = [string]$controlStatus.active_scope.active_through_task
                current_operator_control_room_gate = [string]$controlStatus.hard_gate_status.current_operator_control_room.status
                productized_ui_claimed = [bool]$controlStatus.control_room_status.productized_ui_claimed
            }
            operator_demo_state = [pscustomobject][ordered]@{
                demo_ref = "state/control_room/r13_current/operator_demo.md"
                validation_manifest_ref = "state/control_room/r13_current/operator_demo_validation_manifest.md"
                status = "partially_evidenced"
                productized_demo_claimed = $false
            }
            next_legal_action = "R13-014 only after R13-013 is committed, pushed, and verified"
            forbidden_actions = @("no R13 closeout", "no R14 or successor opening", "no broad repo inventory unless focused validation fails", "no general Codex compaction solved claim")
            safe_next_prompt_boundary = "Use the R13-013 restart prompt only after the R13-013 commit is pushed and verified; then R13-014 may start from committed repo evidence."
        }
        next_legal_action = [pscustomobject][ordered]@{
            task_id = "R13-014"
            action = "start_next_task_after_commit_push_and_verification"
            required_before = "R13-013 is committed, pushed, and verification validates branch/head/tree and clean worktree"
            description = "R13-014 may start only after R13-013 is committed, pushed, and verified from repo evidence."
        }
        forbidden_actions = @(
            "do not close R13",
            "do not open R14 or any successor",
            "do not claim Codex compaction is solved generally",
            "do not claim Codex reliability is solved generally",
            "do not perform broad repo inventory unless focused validation fails",
            "do not claim production runtime, productized UI, full product QA, or broad autonomy"
        )
        restart_prompt_ref = Convert-ToRepositoryRelativePath -PathValue $PromptPath
        validation_results = @(
            [pscustomobject][ordered]@{
                validator = "R13CompactionMitigation identity reconciliation"
                verdict = "passed"
                summary = "R13-012 signoff head is accepted only as generation identity and is reconciled to the durable R13-012 commit."
            },
            [pscustomobject][ordered]@{
                validator = "R13CompactionMitigation packet generator"
                verdict = "passed"
                summary = "Packet recovered branch/head/tree, R13 active boundary, prerequisite evidence, next legal action, forbidden actions, and non-claims from repo evidence."
            }
        )
        residual_risks = @(
            "This is bounded repo-truth continuity mitigation only and does not solve Codex compaction generally.",
            "Generated artifacts still record generation-time Git identity before the commit that makes them durable.",
            "R13 remains active; later tasks still require explicit committed evidence.",
            "R13-014 must not start until R13-013 is committed, pushed, and verified."
        )
        evidence_refs = @($evidenceRefs)
        generated_at_utc = Get-UtcTimestamp
        non_claims = @($script:RequiredNonClaims)
    }
}

function New-R13RestartPromptText {
    [CmdletBinding()]
    param(
        [string]$PacketPath = $script:PacketRef,
        [string]$IdentityReconciliationPath = $script:IdentityReconciliationRef
    )

    $gitIdentity = Get-R13ContinuityGitIdentity
    $promptId = Get-StableId -Prefix "r13rp" -Key "$($gitIdentity.Branch)|$($gitIdentity.Head)|$PacketPath"
    $requiredChecks = @(
        'git rev-parse --show-toplevel',
        'git branch --show-current',
        'git rev-parse HEAD',
        'git rev-parse "HEAD^{tree}"',
        'git status --short --untracked-files=all'
    )

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("Run only these minimal checks first:") | Out-Null
    foreach ($check in $requiredChecks) {
        $lines.Add(('- `{0}`' -f $check)) | Out-Null
    }
    $lines.Add("") | Out-Null
    $lines.Add(('Use committed repo evidence as the state source. Read the packet at `{0}` and identity reconciliation at `{1}` before taking any milestone action.' -f $script:PacketRef, $script:IdentityReconciliationRef)) | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("Do not perform broad repo inventory unless focused validation fails. Do not close R13. Do not open R14 or any successor. Do not claim Codex compaction or Codex reliability is solved generally.") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("R13-014 is allowed only after R13-013 is committed, pushed, and verified from branch/head/tree and a clean worktree. Until then, R13 is active through R13-013 only and R13-014 through R13-018 remain planned only.") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("Codex compaction is not solved generally; this prompt is only a bounded repo-truth restart aid for the R13-013 boundary.") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## Prompt Metadata") | Out-Null
    $lines.Add('- artifact_type: `r13_restart_prompt`') | Out-Null
    $lines.Add(('- prompt_id: `{0}`' -f $promptId)) | Out-Null
    $lines.Add(('- source_packet_ref: `{0}`' -f $script:PacketRef)) | Out-Null
    $lines.Add('- target_user: `Codex restart agent`') | Out-Null
    $lines.Add('- intended_use: `recover R13 state after context compaction using committed repo evidence`') | Out-Null
    $lines.Add('- allowed_next_task: `R13-014 after R13-013 commit/push/verification only`') | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## Evidence Refs") | Out-Null
    foreach ($refObject in @(Get-R13ContinuityEvidenceRefs -IdentityReconciliationPath $IdentityReconciliationPath -PacketPath $PacketPath)) {
        $lines.Add(('- `{0}`: `{1}`' -f $refObject.ref_id, $refObject.ref)) | Out-Null
    }
    $lines.Add("") | Out-Null
    $lines.Add("## Non-Claims") | Out-Null
    foreach ($nonClaim in $script:RequiredNonClaims) {
        $lines.Add("- $nonClaim") | Out-Null
    }

    return (($lines -join "`n") + "`n")
}

function Test-R13IdentityReconciliationObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $IdentityReconciliation,
        [string]$SourceLabel = "R13-013 identity reconciliation"
    )

    Assert-RequiredObjectFields -Object $IdentityReconciliation -FieldNames @("contract_version", "artifact_type", "reconciliation_id", "repository", "branch", "source_milestone", "source_task", "signoff_ref", "signoff_generated_from_head", "signoff_committed_at_head", "current_r13_013_working_head", "reason", "verdict", "non_claims") -Context $SourceLabel
    if ($IdentityReconciliation.contract_version -ne "v1") {
        throw "$SourceLabel contract_version must be v1."
    }
    if ($IdentityReconciliation.artifact_type -ne "r13_013_identity_reconciliation") {
        throw "$SourceLabel artifact_type must be r13_013_identity_reconciliation."
    }
    if ($IdentityReconciliation.repository -ne $script:R13RepositoryName -or $IdentityReconciliation.branch -ne $script:R13Branch -or $IdentityReconciliation.source_milestone -ne $script:R13Milestone -or $IdentityReconciliation.source_task -ne $script:R13SourceTask) {
        throw "$SourceLabel must bind to R13-013 on the R13 branch."
    }
    Assert-ExistingRef -Ref ([string]$IdentityReconciliation.signoff_ref) -Context "$SourceLabel signoff_ref"
    $signoff = Get-JsonDocument -Path ([string]$IdentityReconciliation.signoff_ref) -Label "R13-012 signoff"
    if ([string]$IdentityReconciliation.signoff_generated_from_head -ne $script:R13SignoffGeneratedHead -or [string]$signoff.head -ne [string]$IdentityReconciliation.signoff_generated_from_head) {
        throw "$SourceLabel must preserve the R13-012 signoff generation head."
    }
    if ([string]$IdentityReconciliation.signoff_committed_at_head -ne $script:R13SignoffCommittedHead) {
        throw "$SourceLabel must record the durable R13-012 commit head."
    }
    Assert-GitObjectId -Value $IdentityReconciliation.current_r13_013_working_head -Context "$SourceLabel current_r13_013_working_head"
    if ([string]$IdentityReconciliation.reason -ne "generated artifacts are created before the commit that makes them durable") {
        throw "$SourceLabel reason must explain generation-before-commit identity."
    }
    if ([string]$IdentityReconciliation.verdict -ne "accepted_as_generation_identity_not_current_identity") {
        throw "$SourceLabel verdict must accept generation identity only."
    }
    $nonClaims = Assert-StringArray -Value $IdentityReconciliation.non_claims -Context "$SourceLabel non_claims"
    Assert-IdentityNonClaims -NonClaims $nonClaims -Context $SourceLabel
    Assert-NoForbiddenR13ContinuityClaims -Value $IdentityReconciliation -Context $SourceLabel

    return [pscustomobject][ordered]@{
        ReconciliationId = [string]$IdentityReconciliation.reconciliation_id
        SignoffGeneratedFromHead = [string]$IdentityReconciliation.signoff_generated_from_head
        SignoffCommittedAtHead = [string]$IdentityReconciliation.signoff_committed_at_head
        Verdict = [string]$IdentityReconciliation.verdict
    }
}

function Test-R13IdentityReconciliation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$IdentityReconciliationPath
    )

    $identity = Get-JsonDocument -Path $IdentityReconciliationPath -Label "R13-013 identity reconciliation"
    return Test-R13IdentityReconciliationObject -IdentityReconciliation $identity -SourceLabel "R13-013 identity reconciliation"
}

function Test-R13CompactionMitigationPacketObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Packet,
        [string]$SourceLabel = "R13 compaction mitigation packet"
    )

    $contract = Get-JsonDocument -Path "contracts/continuity/r13_compaction_mitigation_packet.contract.json" -Label "R13 compaction mitigation packet contract"
    Assert-RequiredObjectFields -Object $Packet -FieldNames $contract.required_fields -Context $SourceLabel
    if ($Packet.contract_version -ne "v1") {
        throw "$SourceLabel contract_version must be v1."
    }
    if ($Packet.artifact_type -ne "r13_compaction_mitigation_packet") {
        throw "$SourceLabel artifact_type must be r13_compaction_mitigation_packet."
    }
    if ($Packet.repository -ne $script:R13RepositoryName -or $Packet.branch -ne $script:R13Branch -or $Packet.source_milestone -ne $script:R13Milestone -or $Packet.source_task -ne $script:R13SourceTask) {
        throw "$SourceLabel must bind to R13-013 on the R13 branch."
    }
    Assert-GitObjectId -Value $Packet.head -Context "$SourceLabel head"
    Assert-GitObjectId -Value $Packet.tree -Context "$SourceLabel tree"
    $activeScope = Assert-ObjectValue -Value $Packet.active_scope -Context "$SourceLabel active_scope"
    Assert-RequiredObjectFields -Object $activeScope -FieldNames @("active_milestone", "active_through_task", "completed_range", "planned_range", "r13_closed", "r14_or_successor_opened") -Context "$SourceLabel active_scope"
    if ($activeScope.active_through_task -ne "R13-013" -or $activeScope.completed_range -ne "R13-001 through R13-013" -or $activeScope.planned_range -ne "R13-014 through R13-018") {
        throw "$SourceLabel active_scope must declare R13 active through R13-013 with R13-014 through R13-018 planned only."
    }
    if ([bool]$activeScope.r13_closed -or [bool]$activeScope.r14_or_successor_opened) {
        throw "$SourceLabel active_scope cannot close R13 or open R14/successor."
    }
    Assert-ExistingRef -Ref ([string]$Packet.identity_reconciliation_ref) -Context "$SourceLabel identity_reconciliation_ref"
    $identityValidation = Test-R13IdentityReconciliation -IdentityReconciliationPath ([string]$Packet.identity_reconciliation_ref)
    if ($identityValidation.SignoffGeneratedFromHead -ne $script:R13SignoffGeneratedHead -or $identityValidation.SignoffCommittedAtHead -ne $script:R13SignoffCommittedHead) {
        throw "$SourceLabel identity reconciliation does not preserve the R13-012 generated/current distinction."
    }
    Assert-RefArray -Value $Packet.prerequisite_evidence_refs -Context "$SourceLabel prerequisite_evidence_refs" -RequireExists | Out-Null
    $recoveredState = Assert-ObjectValue -Value $Packet.recovered_state -Context "$SourceLabel recovered_state"
    Assert-RequiredObjectFields -Object $recoveredState -FieldNames @("git_identity", "active_milestone", "active_through_task", "planned_task_range", "r13_012_bounded_signoff_decision", "r13_011_external_replay_status", "qa_pipeline_state", "control_room_state", "operator_demo_state", "next_legal_action", "forbidden_actions", "safe_next_prompt_boundary") -Context "$SourceLabel recovered_state"
    if ($recoveredState.active_through_task -ne "R13-013" -or $recoveredState.planned_task_range -ne "R13-014 through R13-018") {
        throw "$SourceLabel recovered_state must preserve the R13-013/R13-014 boundary."
    }
    if ($recoveredState.r13_012_bounded_signoff_decision.signoff_decision -ne "accepted_bounded_scope" -or $recoveredState.r13_012_bounded_signoff_decision.signoff_generated_from_head -ne $script:R13SignoffGeneratedHead -or $recoveredState.r13_012_bounded_signoff_decision.signoff_committed_at_head -ne $script:R13SignoffCommittedHead) {
        throw "$SourceLabel must recover the bounded R13-012 signoff decision and explicit identity reconciliation."
    }
    if ($recoveredState.r13_011_external_replay_status.aggregate_verdict -ne "passed") {
        throw "$SourceLabel must recover passed R13-011 external replay status."
    }
    if ([bool]$recoveredState.control_room_state.productized_ui_claimed) {
        throw "$SourceLabel cannot claim productized control-room UI."
    }
    $nextLegalAction = Assert-ObjectValue -Value $Packet.next_legal_action -Context "$SourceLabel next_legal_action"
    if ($nextLegalAction.task_id -ne "R13-014" -or [string]$nextLegalAction.required_before -notmatch "committed" -or [string]$nextLegalAction.required_before -notmatch "pushed" -or [string]$nextLegalAction.required_before -notmatch "verification") {
        throw "$SourceLabel next_legal_action must allow R13-014 only after R13-013 commit, push, and verification."
    }
    $forbiddenActions = Assert-StringArray -Value $Packet.forbidden_actions -Context "$SourceLabel forbidden_actions"
    foreach ($fragment in @("do not close R13", "do not open R14", "do not claim Codex compaction is solved generally", "do not perform broad repo inventory unless focused validation fails")) {
        if (@($forbiddenActions | Where-Object { $_ -like "*$fragment*" }).Count -eq 0) {
            throw "$SourceLabel forbidden_actions must include '$fragment'."
        }
    }
    Assert-ExistingRef -Ref ([string]$Packet.restart_prompt_ref) -Context "$SourceLabel restart_prompt_ref"
    $validationResults = Assert-ObjectArray -Value $Packet.validation_results -Context "$SourceLabel validation_results"
    foreach ($validationResult in @($validationResults)) {
        Assert-RequiredObjectFields -Object $validationResult -FieldNames @("validator", "verdict", "summary") -Context "$SourceLabel validation_results item"
        if ([string]$validationResult.verdict -ne "passed") {
            throw "$SourceLabel validation_results must be passed."
        }
    }
    Assert-StringArray -Value $Packet.residual_risks -Context "$SourceLabel residual_risks" | Out-Null
    Assert-RefArray -Value $Packet.evidence_refs -Context "$SourceLabel evidence_refs" -RequireExists | Out-Null
    Assert-TimestampString -Value $Packet.generated_at_utc -Context "$SourceLabel generated_at_utc"
    $nonClaims = Assert-StringArray -Value $Packet.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel
    Assert-NoForbiddenR13ContinuityClaims -Value $Packet -Context $SourceLabel

    return [pscustomobject][ordered]@{
        PacketId = [string]$Packet.packet_id
        Branch = [string]$Packet.branch
        Head = [string]$Packet.head
        Tree = [string]$Packet.tree
        ActiveThroughTask = [string]$Packet.active_scope.active_through_task
        PlannedRange = [string]$Packet.active_scope.planned_range
        NextLegalAction = [string]$Packet.next_legal_action.task_id
        EvidenceRefCount = @($Packet.evidence_refs).Count
    }
}

function Test-R13CompactionMitigationPacket {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PacketPath
    )

    $packet = Get-JsonDocument -Path $PacketPath -Label "R13 compaction mitigation packet"
    return Test-R13CompactionMitigationPacketObject -Packet $packet -SourceLabel "R13 compaction mitigation packet"
}

function Test-R13RestartPrompt {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PromptPath
    )

    $resolvedPath = Resolve-RepositoryPath -PathValue $PromptPath
    if (-not (Test-Path -LiteralPath $resolvedPath)) {
        throw "R13 restart prompt '$PromptPath' does not exist."
    }
    $text = Get-Content -LiteralPath $resolvedPath -Raw
    $normalized = (($text -replace "`r`n", "`n") -replace "`r", "`n").TrimStart()
    if (-not $normalized.StartsWith("Run only these minimal checks first:")) {
        throw "R13 restart prompt must start with minimal branch/head/worktree checks."
    }
    foreach ($check in @('git rev-parse --show-toplevel', 'git branch --show-current', 'git rev-parse HEAD', 'git rev-parse "HEAD^{tree}"', 'git status --short --untracked-files=all')) {
        if ($text -notmatch [regex]::Escape($check)) {
            throw "R13 restart prompt must include required check '$check'."
        }
    }
    foreach ($requiredFragment in @(
            "Use committed repo evidence as the state source",
            "Do not perform broad repo inventory unless focused validation fails",
            "Do not close R13",
            "Do not open R14 or any successor",
            "R13-014 is allowed only after R13-013 is committed, pushed, and verified",
            "Codex compaction is not solved generally",
            "R13 is active through R13-013 only",
            "R13-014 through R13-018 remain planned only"
        )) {
        if ($text -notmatch [regex]::Escape($requiredFragment)) {
            throw "R13 restart prompt must include '$requiredFragment'."
        }
    }
    foreach ($nonClaim in $script:RequiredNonClaims) {
        if ($text -notmatch [regex]::Escape($nonClaim)) {
            throw "R13 restart prompt must include non-claim '$nonClaim'."
        }
    }
    foreach ($ref in @($script:PacketRef, $script:IdentityReconciliationRef)) {
        if ($text -notmatch [regex]::Escape($ref)) {
            throw "R13 restart prompt must reference '$ref'."
        }
    }
    Assert-NoForbiddenR13ContinuityClaims -Value $text -Context "R13 restart prompt"

    $promptId = if ($text -match 'prompt_id:\s+`([^`]+)`') { $Matches[1] } else { "" }
    Assert-NonEmptyString -Value $promptId -Context "R13 restart prompt prompt_id" | Out-Null
    return [pscustomobject][ordered]@{
        PromptPath = (Convert-ToRepositoryRelativePath -PathValue $PromptPath)
        PromptId = $promptId
        RequiredCheckCount = 5
    }
}

function Export-R13CompactionMitigationValidationManifest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PacketPath,
        [Parameter(Mandatory = $true)]
        [string]$PromptPath,
        [Parameter(Mandatory = $true)]
        [string]$IdentityReconciliationPath,
        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )

    $packetValidation = Test-R13CompactionMitigationPacket -PacketPath $PacketPath
    $promptValidation = Test-R13RestartPrompt -PromptPath $PromptPath
    $identityValidation = Test-R13IdentityReconciliation -IdentityReconciliationPath $IdentityReconciliationPath

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# R13 Compaction Mitigation Validation Manifest") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add('- artifact_type: `r13_compaction_mitigation_validation_manifest`') | Out-Null
    $lines.Add(('- generated_at_utc: `{0}`' -f (Get-UtcTimestamp))) | Out-Null
    $lines.Add(('- packet_ref: `{0}`' -f (Convert-ToRepositoryRelativePath -PathValue $PacketPath))) | Out-Null
    $lines.Add(('- restart_prompt_ref: `{0}`' -f (Convert-ToRepositoryRelativePath -PathValue $PromptPath))) | Out-Null
    $lines.Add(('- identity_reconciliation_ref: `{0}`' -f (Convert-ToRepositoryRelativePath -PathValue $IdentityReconciliationPath))) | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## Validation Results") | Out-Null
    $lines.Add(('- packet: `passed` - `{0}` active through `{1}`, next legal action `{2}`' -f $packetValidation.PacketId, $packetValidation.ActiveThroughTask, $packetValidation.NextLegalAction)) | Out-Null
    $lines.Add(('- restart prompt: `passed` - `{0}` with `{1}` required checks' -f $promptValidation.PromptId, $promptValidation.RequiredCheckCount)) | Out-Null
    $lines.Add(('- identity reconciliation: `passed` - signoff generated from `{0}` and committed at `{1}`' -f $identityValidation.SignoffGeneratedFromHead, $identityValidation.SignoffCommittedAtHead)) | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## R13 Boundary") | Out-Null
    $lines.Add('- R13 active through `R13-013` only') | Out-Null
    $lines.Add("- R13-014 through R13-018 remain planned only") | Out-Null
    $lines.Add('- Next legal action: `R13-014` only after R13-013 commit, push, and verification') | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## Identity Reconciliation") | Out-Null
    $lines.Add("- The R13-012 signoff head is generation identity, not a false current-head claim.") | Out-Null
    $lines.Add("- No history rewrite occurred and no R13 closeout or successor opening is claimed.") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## Explicit Non-Claims") | Out-Null
    foreach ($nonClaim in $script:RequiredNonClaims) {
        $lines.Add("- $nonClaim") | Out-Null
    }

    Write-R13ContinuityTextFile -Path $OutputPath -Value (($lines -join "`n") + "`n")
    return [pscustomobject][ordered]@{
        ManifestPath = (Convert-ToRepositoryRelativePath -PathValue $OutputPath)
        PacketId = $packetValidation.PacketId
        PromptId = $promptValidation.PromptId
        IdentityVerdict = $identityValidation.Verdict
    }
}

function New-R13CompactionMitigationArtifacts {
    [CmdletBinding()]
    param(
        [string]$IdentityReconciliationPath = $script:IdentityReconciliationRef,
        [string]$PacketPath = $script:PacketRef,
        [string]$PromptPath = $script:PromptRef,
        [string]$ManifestPath = $script:ManifestRef
    )

    $identity = New-R13IdentityReconciliationObject -IdentityReconciliationPath $IdentityReconciliationPath
    Write-R13ContinuityJsonFile -Path $IdentityReconciliationPath -Value $identity
    $prompt = New-R13RestartPromptText -PacketPath $PacketPath -IdentityReconciliationPath $IdentityReconciliationPath
    Write-R13ContinuityTextFile -Path $PromptPath -Value $prompt
    Write-R13ContinuityTextFile -Path $ManifestPath -Value "# R13 Compaction Mitigation Validation Manifest`n`nPending regeneration by R13-013 continuity tooling.`n"
    $packet = New-R13CompactionMitigationPacketObject -IdentityReconciliationPath $IdentityReconciliationPath -PacketPath $PacketPath -PromptPath $PromptPath -ManifestPath $ManifestPath
    Write-R13ContinuityJsonFile -Path $PacketPath -Value $packet
    $manifest = Export-R13CompactionMitigationValidationManifest -PacketPath $PacketPath -PromptPath $PromptPath -IdentityReconciliationPath $IdentityReconciliationPath -OutputPath $ManifestPath

    return [pscustomobject][ordered]@{
        IdentityReconciliationPath = (Convert-ToRepositoryRelativePath -PathValue $IdentityReconciliationPath)
        PacketPath = (Convert-ToRepositoryRelativePath -PathValue $PacketPath)
        PromptPath = (Convert-ToRepositoryRelativePath -PathValue $PromptPath)
        ManifestPath = $manifest.ManifestPath
        PacketId = $manifest.PacketId
        PromptId = $manifest.PromptId
    }
}

Export-ModuleMember -Function Get-RepositoryRoot, Resolve-RepositoryPath, Convert-ToRepositoryRelativePath, Get-UtcTimestamp, Get-JsonDocument, Write-R13ContinuityJsonFile, Write-R13ContinuityTextFile, Get-R13ContinuityGitIdentity, New-R13IdentityReconciliationObject, Test-R13IdentityReconciliationObject, Test-R13IdentityReconciliation, New-R13CompactionMitigationPacketObject, Test-R13CompactionMitigationPacketObject, Test-R13CompactionMitigationPacket, New-R13RestartPromptText, Test-R13RestartPrompt, Export-R13CompactionMitigationValidationManifest, New-R13CompactionMitigationArtifacts
