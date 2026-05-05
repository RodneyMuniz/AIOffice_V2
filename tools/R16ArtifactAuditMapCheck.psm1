Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R16ArtifactMapGenerator.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R16AuditMapGenerator.psm1") -Force

$script:R16Milestone = "R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation"
$script:Repository = "RodneyMuniz/AIOffice_V2"
$script:Branch = "release/r16-operational-memory-artifact-map-role-workflow-foundation"
$script:InputHead = "e1a4ec6e4e0c7c12ac2d68f98b496323fe998ecf"
$script:InputTree = "2acbd19827083752803091bd2df4416c4786c486"
$script:ReportId = "aioffice-r16-013-artifact-audit-map-check-report-v1"

$script:CompleteTasks = @(
    "R16-001", "R16-002", "R16-003", "R16-004", "R16-005", "R16-006", "R16-007",
    "R16-008", "R16-009", "R16-010", "R16-011", "R16-012", "R16-013"
)

$script:PlannedTasks = @(
    "R16-014", "R16-015", "R16-016", "R16-017", "R16-018", "R16-019", "R16-020",
    "R16-021", "R16-022", "R16-023", "R16-024", "R16-025", "R16-026"
)

$script:KnownR15Caveats = @(
    [ordered]@{
        caveat_id = "r15_final_proof_review_package_stale_generated_from"
        path = "state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/r15_009_final_proof_review_package/r15_final_proof_review_package.json"
        applies_to_ref_id = "r15_final_proof_review_package"
        caveat_type = "stale_generated_from_ref_preserved"
        declared_boundary = [ordered]@{
            audited_head = "d9685030a0556a528684d28367db83f4c72f7fc9"
            audited_tree = "7529230df0c1f5bec3625ba654b035a2af824e9b"
            post_audit_support_commit = "3058bd6ed5067c97f744c92b9b9235004f0568b0"
        }
        observed_boundary = [ordered]@{
            generated_from_head = "5865422a1a1c0bf6f347346a95087ee33e055da3"
            generated_from_tree = "c2d8f3e8f59e3f7785a0f8261f82204bcbb4af22"
        }
        accepted_reason = "The R15 external audit acceptance boundary is recorded separately and the older generated_from values remain visible as provenance caveats."
        preserved_scope = "R15 remains accepted with caveats through R15-009 only; R13 remains failed/partial and R14/R15 caveats are not removed."
    },
    [ordered]@{
        caveat_id = "r15_evidence_index_stale_generated_from"
        path = "state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/r15_009_final_proof_review_package/evidence_index.json"
        applies_to_ref_id = "r15_final_evidence_index"
        caveat_type = "stale_generated_from_ref_preserved"
        declared_boundary = [ordered]@{
            audited_head = "d9685030a0556a528684d28367db83f4c72f7fc9"
            audited_tree = "7529230df0c1f5bec3625ba654b035a2af824e9b"
            post_audit_support_commit = "3058bd6ed5067c97f744c92b9b9235004f0568b0"
        }
        observed_boundary = [ordered]@{
            generated_from_head = "5865422a1a1c0bf6f347346a95087ee33e055da3"
            generated_from_tree = "c2d8f3e8f59e3f7785a0f8261f82204bcbb4af22"
        }
        accepted_reason = "The R15 evidence index keeps its original generated_from values and is accepted only with this explicit caveat."
        preserved_scope = "R15 remains accepted with caveats through R15-009 only; R13 remains failed/partial and R14/R15 caveats are not removed."
    }
)

$script:RequiredDependencyPaths = @(
    "contracts/artifacts/r16_artifact_map.contract.json",
    "state/artifacts/r16_artifact_map.json",
    "contracts/audit/r16_audit_map.contract.json",
    "state/audit/r16_r15_r16_audit_map.json",
    "tools/R16ArtifactMapGenerator.psm1",
    "tools/validate_r16_artifact_map.ps1",
    "tools/R16AuditMapGenerator.psm1",
    "tools/validate_r16_audit_map.ps1",
    "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_012_r15_r16_audit_map/proof_review.json",
    "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_012_r15_r16_audit_map/validation_manifest.md"
)

$script:CheckScopeIds = @(
    "artifact_map_path_exists",
    "audit_map_path_exists",
    "required_paths_exist",
    "artifact_records_exact_paths",
    "audit_entries_exact_evidence_paths",
    "no_wildcard_paths",
    "no_broad_repo_root_paths",
    "no_directory_only_proof_claims",
    "no_report_as_machine_proof_misuse",
    "stale_generated_from_requires_caveat",
    "r15_stale_generated_from_caveat_preserved",
    "current_posture_active_through_r16_013",
    "r16_014_through_r16_026_planned_only",
    "no_r16_014_or_later_implementation_claims",
    "r13_r14_r15_boundaries_preserved",
    "no_runtime_product_agent_integration_claims"
)

$script:FindingCategories = @(
    "required_path_presence",
    "exact_path_policy",
    "wildcard_path_policy",
    "broad_repo_root_policy",
    "directory_only_proof_policy",
    "stale_generated_from_policy",
    "report_proof_treatment_policy",
    "runtime_overclaim_policy",
    "context_planner_overclaim_policy",
    "role_workflow_overclaim_policy",
    "later_task_overclaim_policy",
    "historical_boundary_policy",
    "r15_caveat_preservation"
)

$script:FindingSeverities = @("pass", "info", "warning", "fail")

$script:RequiredFindingFields = @(
    "finding_id",
    "category",
    "severity",
    "subject_path",
    "subject_ref_id",
    "expected",
    "actual",
    "accepted_caveat_id",
    "message",
    "deterministic_order"
)

$script:RequiredNonClaims = @(
    "no context-load planner",
    "no context budget estimator",
    "no role-run envelope",
    "no RACI transition gate",
    "no handoff packet",
    "no workflow drill",
    "no product runtime",
    "no productized UI",
    "no actual autonomous agents",
    "no true multi-agent execution",
    "no persistent memory runtime",
    "no runtime memory loading",
    "no retrieval runtime",
    "no vector search runtime",
    "no external integrations",
    "no GitHub Projects integration",
    "no Linear integration",
    "no Symphony integration",
    "no custom board integration",
    "no external board sync",
    "no solved Codex compaction",
    "no solved Codex reliability",
    "no main merge",
    "no R13 closure",
    "no R14 caveat removal",
    "no R15 caveat removal",
    "no R13 partial-gate conversion"
)

$script:RejectedClaims = @(
    "context-load planner",
    "context budget estimator",
    "role-run envelope",
    "RACI transition gate",
    "handoff packet",
    "workflow drill",
    "product runtime",
    "productized UI",
    "actual autonomous agents",
    "true multi-agent execution",
    "persistent memory runtime",
    "runtime memory loading",
    "retrieval runtime",
    "vector search runtime",
    "external integrations",
    "GitHub Projects integration",
    "Linear integration",
    "Symphony integration",
    "custom board integration",
    "external board sync",
    "solved Codex compaction",
    "solved Codex reliability",
    "main merge",
    "R13 closure",
    "R14 caveat removal",
    "R15 caveat removal",
    "R13 partial-gate conversion",
    "R16-014 or later implementation",
    "R16-027 or later task"
)

function Test-HasProperty {
    param(
        [AllowNull()]$Object,
        [Parameter(Mandatory = $true)][string]$Name
    )

    if ($Object -is [System.Collections.IDictionary]) {
        return $Object.Contains($Name)
    }

    return $null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name
}

function Get-RequiredProperty {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if (-not (Test-HasProperty -Object $Object -Name $Name)) {
        throw "$Context is missing required field '$Name'."
    }

    if ($Object -is [System.Collections.IDictionary]) {
        $PSCmdlet.WriteObject($Object[$Name], $false)
        return
    }

    $PSCmdlet.WriteObject($Object.PSObject.Properties[$Name].Value, $false)
}

function Assert-NonEmptyString {
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($Value -isnot [string] -or [string]::IsNullOrWhiteSpace($Value)) {
        throw "$Context must be a non-empty string."
    }

    return $Value
}

function Assert-BooleanValue {
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($Value -isnot [bool]) {
        throw "$Context must be a boolean."
    }

    return [bool]$Value
}

function Assert-IntegerValue {
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($Value -isnot [int] -and $Value -isnot [long]) {
        throw "$Context must be an integer."
    }

    return [int]$Value
}

function Assert-ObjectValue {
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($null -eq $Value -or $Value -is [string] -or $Value -is [System.Array]) {
        throw "$Context must be an object."
    }

    return $Value
}

function Assert-ObjectArray {
    [CmdletBinding()]
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context,
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
        if ($null -eq $item -or $item -is [string] -or $item -is [System.Array]) {
            throw "$Context must contain only objects."
        }
    }

    $PSCmdlet.WriteObject($items, $false)
}

function Assert-StringArray {
    [CmdletBinding()]
    param(
        [AllowNull()]$Value,
        [Parameter(Mandatory = $true)][string]$Context,
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
        if ($item -isnot [string] -or [string]::IsNullOrWhiteSpace($item)) {
            throw "$Context must contain only non-empty strings."
        }
    }

    $PSCmdlet.WriteObject([string[]]$items, $false)
}

function Assert-StringSetEquals {
    param(
        [Parameter(Mandatory = $true)][string[]]$Actual,
        [Parameter(Mandatory = $true)][string[]]$Expected,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $sortedActual = @($Actual | Sort-Object)
    $sortedExpected = @($Expected | Sort-Object)
    if ($sortedActual.Count -ne $sortedExpected.Count) {
        throw "$Context must contain exactly: $($sortedExpected -join ', ')."
    }

    for ($index = 0; $index -lt $sortedExpected.Count; $index += 1) {
        if ($sortedActual[$index] -ne $sortedExpected[$index]) {
            throw "$Context must contain exactly: $($sortedExpected -join ', ')."
        }
    }
}

function Assert-RequiredStringsPresent {
    param(
        [Parameter(Mandatory = $true)][string[]]$Actual,
        [Parameter(Mandatory = $true)][string[]]$Required,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($item in $Required) {
        if ($Actual -notcontains $item) {
            throw "$Context must include '$item'."
        }
    }
}

function Assert-FalseFields {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string[]]$Fields,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $Fields) {
        $value = Get-RequiredProperty -Object $Object -Name $field -Context $Context
        if ((Assert-BooleanValue -Value $value -Context "$Context $field") -ne $false) {
            throw "$Context $field must be False."
        }
    }
}

function Assert-TrueFields {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string[]]$Fields,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $Fields) {
        $value = Get-RequiredProperty -Object $Object -Name $field -Context $Context
        if ((Assert-BooleanValue -Value $value -Context "$Context $field") -ne $true) {
            throw "$Context $field must be True."
        }
    }
}

function Get-RepositoryRoot {
    param([AllowNull()][string]$RepositoryRoot)

    if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
        $RepositoryRoot = $repoRoot
    }

    if (Test-Path -LiteralPath $RepositoryRoot) {
        return (Resolve-Path -LiteralPath $RepositoryRoot).Path
    }

    return [System.IO.Path]::GetFullPath($RepositoryRoot)
}

function ConvertTo-NormalizedRepoPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    return $Path.Trim().Replace("\", "/")
}

function Resolve-RepoRelativePathValue {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $Path))
}

function Test-WildcardPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    return $Path -match '[\*\?]'
}

function Test-BroadRepoRootPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    $normalized = ConvertTo-NormalizedRepoPath -Path $Path
    return [string]::IsNullOrWhiteSpace($normalized) -or $normalized -in @(".", "./", "/", "\") -or $normalized -match '^[A-Za-z]:/?$'
}

function Test-DirectoryOnlyPath {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    $normalized = ConvertTo-NormalizedRepoPath -Path $Path
    if ($normalized.EndsWith("/")) {
        return $true
    }

    if ([System.IO.Path]::IsPathRooted($Path) -or $normalized -match '(^|/)\.\.(/|$)') {
        return $false
    }

    $resolved = Resolve-RepoRelativePathValue -Path $normalized -RepositoryRoot $RepositoryRoot
    return (Test-Path -LiteralPath $resolved -PathType Container)
}

function Assert-SafeRepoRelativePath {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$Context,
        [switch]$RequireLeaf
    )

    $normalized = ConvertTo-NormalizedRepoPath -Path $Path
    if ([System.IO.Path]::IsPathRooted($normalized)) {
        throw "$Context path must be repo-relative, not absolute."
    }
    if (Test-BroadRepoRootPath -Path $normalized) {
        throw "$Context rejects broad repo root path '$Path'."
    }
    if (Test-WildcardPath -Path $normalized) {
        throw "$Context rejects wildcard path '$Path'."
    }
    if ($normalized -match '(^|/)\.\.(/|$)') {
        throw "$Context must not traverse outside the repository."
    }
    if (Test-DirectoryOnlyPath -Path $normalized -RepositoryRoot $RepositoryRoot) {
        throw "$Context rejects directory-only proof claim '$Path'."
    }

    $resolved = Resolve-RepoRelativePathValue -Path $normalized -RepositoryRoot $RepositoryRoot
    $root = [System.IO.Path]::GetFullPath($RepositoryRoot)
    if (-not $resolved.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "$Context must remain inside the repository."
    }
    if ($RequireLeaf -and -not (Test-Path -LiteralPath $resolved -PathType Leaf)) {
        throw "$Context required path '$Path' does not exist."
    }

    return $resolved
}

function ConvertTo-StableJson {
    param([Parameter(Mandatory = $true)]$Object)

    $json = $Object | ConvertTo-Json -Depth 100
    return $json.Replace("`r`n", "`n").Replace("`r", "`n")
}

function Write-StableJsonFile {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $directory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $encoding = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($Path, (ConvertTo-StableJson -Object $Object) + "`n", $encoding)
}

function Copy-JsonObject {
    param([Parameter(Mandatory = $true)]$Value)
    return ($Value | ConvertTo-Json -Depth 100 | ConvertFrom-Json)
}

function New-PathRef {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$RefId,
        [Parameter(Mandatory = $true)][string]$Source,
        [string]$ProofStatus = "",
        [string]$EvidenceKind = "",
        [bool]$MachineProof = $false,
        [bool]$ImplementationProof = $false
    )

    return [pscustomobject]@{
        Path = (ConvertTo-NormalizedRepoPath -Path $Path)
        RefId = $RefId
        Source = $Source
        ProofStatus = $ProofStatus
        EvidenceKind = $EvidenceKind
        MachineProof = $MachineProof
        ImplementationProof = $ImplementationProof
    }
}

function Add-PathRef {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.ArrayList]$Refs,
        [AllowNull()][string]$Path,
        [Parameter(Mandatory = $true)][string]$RefId,
        [Parameter(Mandatory = $true)][string]$Source,
        [string]$ProofStatus = "",
        [string]$EvidenceKind = "",
        [bool]$MachineProof = $false,
        [bool]$ImplementationProof = $false
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return
    }

    [void]$Refs.Add((New-PathRef -Path $Path -RefId $RefId -Source $Source -ProofStatus $ProofStatus -EvidenceKind $EvidenceKind -MachineProof:$MachineProof -ImplementationProof:$ImplementationProof))
}

function Add-StringPropertyPathRefs {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.ArrayList]$Refs,
        [AllowNull()]$Object,
        [Parameter(Mandatory = $true)][string]$Source
    )

    if ($null -eq $Object) {
        return
    }

    if ($Object -is [System.Collections.IEnumerable] -and $Object -isnot [string]) {
        $index = 0
        foreach ($item in @($Object)) {
            Add-StringPropertyPathRefs -Refs $Refs -Object $item -Source ("{0}[{1}]" -f $Source, $index)
            $index += 1
        }
        return
    }

    if ($Object -isnot [pscustomobject]) {
        return
    }

    foreach ($property in @($Object.PSObject.Properties)) {
        $name = $property.Name
        $value = $property.Value
        if ($value -is [string] -and $name -match '(?i)(^path$|_path$|path$|^generated_|^validator_|^test_|^proof_|^valid_fixture$|^validation_manifest$)') {
            if ($value -match '^[A-Za-z0-9_.\-/]+$' -and $value -match '/') {
                Add-PathRef -Refs $Refs -Path $value -RefId ("{0}.{1}" -f $Source, $name) -Source $Source
            }
        }
        elseif ($value -is [System.Collections.IEnumerable] -and $value -isnot [string]) {
            Add-StringPropertyPathRefs -Refs $Refs -Object $value -Source ("{0}.{1}" -f $Source, $name)
        }
        elseif ($value -is [pscustomobject]) {
            Add-StringPropertyPathRefs -Refs $Refs -Object $value -Source ("{0}.{1}" -f $Source, $name)
        }
    }
}

function New-Finding {
    param(
        [Parameter(Mandatory = $true)][string]$FindingId,
        [Parameter(Mandatory = $true)][string]$Category,
        [Parameter(Mandatory = $true)][string]$Severity,
        [string]$SubjectPath = "",
        [string]$SubjectRefId = "",
        [string]$Expected = "",
        [string]$Actual = "",
        [string]$AcceptedCaveatId = "",
        [Parameter(Mandatory = $true)][string]$Message,
        [Parameter(Mandatory = $true)][int]$Order
    )

    return [ordered]@{
        finding_id = $FindingId
        category = $Category
        severity = $Severity
        subject_path = $SubjectPath
        subject_ref_id = $SubjectRefId
        expected = $Expected
        actual = $Actual
        accepted_caveat_id = $AcceptedCaveatId
        message = $Message
        deterministic_order = $Order
    }
}

function Add-Finding {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.ArrayList]$Findings,
        [Parameter(Mandatory = $true)][string]$FindingId,
        [Parameter(Mandatory = $true)][string]$Category,
        [Parameter(Mandatory = $true)][string]$Severity,
        [string]$SubjectPath = "",
        [string]$SubjectRefId = "",
        [string]$Expected = "",
        [string]$Actual = "",
        [string]$AcceptedCaveatId = "",
        [Parameter(Mandatory = $true)][string]$Message
    )

    [void]$Findings.Add((New-Finding -FindingId $FindingId -Category $Category -Severity $Severity -SubjectPath $SubjectPath -SubjectRefId $SubjectRefId -Expected $Expected -Actual $Actual -AcceptedCaveatId $AcceptedCaveatId -Message $Message -Order ($Findings.Count + 1)))
}

function Get-FindingCounts {
    param([Parameter(Mandatory = $true)]$Findings)

    $items = @($Findings)
    return [ordered]@{
        pass_count = @($items | Where-Object { $_.severity -eq "pass" }).Count
        info_count = @($items | Where-Object { $_.severity -eq "info" }).Count
        warning_count = @($items | Where-Object { $_.severity -eq "warning" }).Count
        fail_count = @($items | Where-Object { $_.severity -eq "fail" }).Count
    }
}

function Test-ReportLikeMachineProofMisuse {
    param([Parameter(Mandatory = $true)]$PathRef)

    $path = [string]$PathRef.Path
    $proofStatus = [string]$PathRef.ProofStatus
    $evidenceKind = [string]$PathRef.EvidenceKind
    if ($path -match '\.md$' -and ($PathRef.MachineProof -or $PathRef.ImplementationProof -or $proofStatus -eq "machine_validated")) {
        return $true
    }
    if ($evidenceKind -in @("operator_report", "planning_artifact", "narrative_context", "validation_manifest", "proof_review_package") -and ($PathRef.MachineProof -or $PathRef.ImplementationProof)) {
        return $true
    }

    return $false
}

function Assert-CurrentPosture {
    param(
        [Parameter(Mandatory = $true)]$Posture,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $postureObject = Assert-ObjectValue -Value $Posture -Context $Context
    if ($postureObject.active_through_task -ne "R16-013") {
        throw "$Context active_through_task must be R16-013."
    }

    $completeTasks = Assert-StringArray -Value $postureObject.complete_tasks -Context "$Context complete_tasks"
    Assert-StringSetEquals -Actual $completeTasks -Expected $script:CompleteTasks -Context "$Context complete_tasks"

    $plannedTasks = Assert-StringArray -Value $postureObject.planned_tasks -Context "$Context planned_tasks"
    Assert-StringSetEquals -Actual $plannedTasks -Expected $script:PlannedTasks -Context "$Context planned_tasks"

    if ((Assert-BooleanValue -Value $postureObject.r16_014_or_later_implementation_claimed -Context "$Context r16_014_or_later_implementation_claimed") -ne $false) {
        throw "$Context rejects R16-014 or later implementation claims."
    }
    if ((Assert-BooleanValue -Value $postureObject.r16_027_or_later_task_exists -Context "$Context r16_027_or_later_task_exists") -ne $false) {
        throw "$Context rejects R16-027 or later task claims."
    }
}

function Assert-PreservedBoundaries {
    param(
        [Parameter(Mandatory = $true)]$Boundaries,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $boundaryObject = Assert-ObjectValue -Value $Boundaries -Context $Context
    if ($boundaryObject.r13.status -ne "failed_partial_through_r13_018_only") {
        throw "$Context r13 status must remain failed_partial_through_r13_018_only."
    }
    if ((Assert-BooleanValue -Value $boundaryObject.r13.closed -Context "$Context r13 closed") -ne $false) {
        throw "$Context r13 closed must be False."
    }
    if ((Assert-BooleanValue -Value $boundaryObject.r13.partial_gates_remain_partial -Context "$Context r13 partial_gates_remain_partial") -ne $true) {
        throw "$Context r13 partial gates must remain partial."
    }
    if ((Assert-BooleanValue -Value $boundaryObject.r13.partial_gates_converted_to_passed -Context "$Context r13 partial_gates_converted_to_passed") -ne $false) {
        throw "$Context rejects R13 partial-gate conversion."
    }

    if ($boundaryObject.r14.status -ne "accepted_with_caveats_through_r14_006_only") {
        throw "$Context r14 status must remain accepted_with_caveats_through_r14_006_only."
    }
    if ((Assert-BooleanValue -Value $boundaryObject.r14.caveats_removed -Context "$Context r14 caveats_removed") -ne $false) {
        throw "$Context r14 caveats_removed must be False."
    }

    if ($boundaryObject.r15.status -ne "accepted_with_caveats_through_r15_009_only") {
        throw "$Context r15 status must remain accepted_with_caveats_through_r15_009_only."
    }
    if ((Assert-BooleanValue -Value $boundaryObject.r15.caveats_removed -Context "$Context r15 caveats_removed") -ne $false) {
        throw "$Context r15 caveats_removed must be False."
    }
    if ((Assert-BooleanValue -Value $boundaryObject.r15.stale_generated_from_caveat_preserved -Context "$Context r15 stale_generated_from_caveat_preserved") -ne $true) {
        throw "$Context r15 stale generated_from caveat must remain preserved."
    }
}

function Assert-ReportMode {
    param(
        [Parameter(Mandatory = $true)]$Mode,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $modeObject = Assert-ObjectValue -Value $Mode -Context $Context
    Assert-TrueFields -Object $modeObject -Fields @(
        "artifact_audit_map_check_tooling_implemented"
    ) -Context $Context
    Assert-FalseFields -Object $modeObject -Fields @(
        "context_load_planner_implemented",
        "context_budget_estimator_implemented",
        "role_run_envelope_implemented",
        "raci_transition_gate_implemented",
        "handoff_packet_implemented",
        "workflow_drill_run",
        "runtime_memory_implemented",
        "product_runtime_implemented",
        "actual_autonomous_agents_implemented",
        "external_integrations_implemented"
    ) -Context $Context
}

function Assert-AcceptedCaveats {
    param(
        [Parameter(Mandatory = $true)]$Caveats,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $items = Assert-ObjectArray -Value $Caveats -Context $Context
    $ids = @($items | ForEach-Object { [string]$_.caveat_id })
    $paths = @($items | ForEach-Object { [string]$_.path })
    foreach ($known in $script:KnownR15Caveats) {
        if ($ids -notcontains $known.caveat_id -or $paths -notcontains $known.path) {
            throw "$Context must preserve accepted stale generated_from caveat '$($known.caveat_id)' for '$($known.path)'."
        }
    }
}

function Test-R16ArtifactAuditMapCheckReportContractObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Contract,
        [string]$SourceLabel = "R16 artifact audit map check report contract",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    foreach ($field in @(
        "artifact_type",
        "contract_version",
        "report_contract_id",
        "source_milestone",
        "source_task",
        "repository",
        "branch",
        "generated_from_head",
        "generated_from_tree",
        "dependency_refs",
        "report_mode",
        "check_scope",
        "finding_schema",
        "aggregate_verdict_values",
        "exact_ref_policy",
        "stale_ref_policy",
        "proof_treatment_policy",
        "overclaim_detection_policy",
        "current_posture",
        "preserved_boundaries"
    )) {
        Get-RequiredProperty -Object $Contract -Name $field -Context $SourceLabel | Out-Null
    }

    if ($Contract.artifact_type -ne "r16_artifact_audit_map_check_report_contract") {
        throw "$SourceLabel artifact_type must be r16_artifact_audit_map_check_report_contract."
    }
    if ($Contract.contract_version -ne "v1") {
        throw "$SourceLabel contract_version must be v1."
    }
    if ($Contract.report_contract_id -ne $script:ReportId) {
        throw "$SourceLabel report_contract_id must be $script:ReportId."
    }
    if ($Contract.source_task -ne "R16-013") {
        throw "$SourceLabel source_task must be R16-013."
    }
    if ($Contract.source_milestone -ne $script:R16Milestone -or $Contract.repository -ne $script:Repository -or $Contract.branch -ne $script:Branch) {
        throw "$SourceLabel repository, branch, or milestone metadata is incorrect."
    }
    if ($Contract.generated_from_head -ne $script:InputHead -or $Contract.generated_from_tree -ne $script:InputTree) {
        throw "$SourceLabel generated_from_head/tree must preserve the R16-013 input boundary."
    }

    $dependencyRefs = Assert-ObjectArray -Value $Contract.dependency_refs -Context "$SourceLabel dependency_refs"
    $dependencyPaths = @($dependencyRefs | ForEach-Object { [string]$_.path })
    Assert-RequiredStringsPresent -Actual $dependencyPaths -Required $script:RequiredDependencyPaths -Context "$SourceLabel dependency_refs"
    foreach ($path in $dependencyPaths) {
        Assert-SafeRepoRelativePath -Path $path -RepositoryRoot $resolvedRoot -Context "$SourceLabel dependency_refs" -RequireLeaf | Out-Null
    }

    $mode = Assert-ObjectValue -Value $Contract.report_mode -Context "$SourceLabel report_mode"
    if ((Assert-BooleanValue -Value $mode.check_report_only -Context "$SourceLabel report_mode check_report_only") -ne $true) {
        throw "$SourceLabel report_mode check_report_only must be True."
    }
    if ((Assert-BooleanValue -Value $mode.artifact_audit_map_check_tooling_implemented -Context "$SourceLabel report_mode artifact_audit_map_check_tooling_implemented") -ne $true) {
        throw "$SourceLabel report_mode artifact_audit_map_check_tooling_implemented must be True."
    }
    Assert-FalseFields -Object $mode -Fields @(
        "context_load_planner",
        "context_budget_estimator",
        "role_run_envelope",
        "raci_transition_gate",
        "handoff_packet",
        "workflow_drill",
        "runtime_memory",
        "product_runtime",
        "autonomous_agents",
        "external_integrations"
    ) -Context "$SourceLabel report_mode"

    $checkScope = Assert-ObjectValue -Value $Contract.check_scope -Context "$SourceLabel check_scope"
    foreach ($checkScopeId in $script:CheckScopeIds) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $checkScope -Name $checkScopeId -Context "$SourceLabel check_scope") -Context "$SourceLabel check_scope $checkScopeId") -ne $true) {
            throw "$SourceLabel check_scope $checkScopeId must be True."
        }
    }

    $findingSchema = Assert-ObjectValue -Value $Contract.finding_schema -Context "$SourceLabel finding_schema"
    Assert-StringSetEquals -Actual (Assert-StringArray -Value $findingSchema.required_fields -Context "$SourceLabel finding_schema required_fields") -Expected $script:RequiredFindingFields -Context "$SourceLabel finding_schema required_fields"
    Assert-StringSetEquals -Actual (Assert-StringArray -Value $findingSchema.severity_values -Context "$SourceLabel finding_schema severity_values") -Expected $script:FindingSeverities -Context "$SourceLabel finding_schema severity_values"
    Assert-StringSetEquals -Actual (Assert-StringArray -Value $findingSchema.categories -Context "$SourceLabel finding_schema categories") -Expected $script:FindingCategories -Context "$SourceLabel finding_schema categories"
    Assert-StringSetEquals -Actual (Assert-StringArray -Value $Contract.aggregate_verdict_values -Context "$SourceLabel aggregate_verdict_values") -Expected @("passed", "passed_with_caveats", "failed") -Context "$SourceLabel aggregate_verdict_values"

    $policy = Assert-ObjectValue -Value $Contract.exact_ref_policy -Context "$SourceLabel exact_ref_policy"
    Assert-TrueFields -Object $policy -Fields @(
        "repo_relative_exact_paths_only",
        "no_wildcard_path_claims",
        "no_broad_repo_root_claims",
        "no_full_repo_scan_claims",
        "no_directory_only_proof_claims_unless_exact_files_listed",
        "stale_generated_from_refs_detected_and_caveated"
    ) -Context "$SourceLabel exact_ref_policy"

    $stalePolicy = Assert-ObjectValue -Value $Contract.stale_ref_policy -Context "$SourceLabel stale_ref_policy"
    Assert-RequiredStringsPresent -Actual (Assert-StringArray -Value $stalePolicy.preserved_stale_generated_from_paths -Context "$SourceLabel stale_ref_policy preserved paths") -Required @($script:KnownR15Caveats | ForEach-Object { [string]$_.path }) -Context "$SourceLabel stale_ref_policy preserved paths"

    $proofPolicy = Assert-ObjectValue -Value $Contract.proof_treatment_policy -Context "$SourceLabel proof_treatment_policy"
    Assert-RequiredStringsPresent -Actual (Assert-StringArray -Value $proofPolicy.treatment_categories -Context "$SourceLabel proof_treatment_policy treatment_categories") -Required @(
        "machine-validated evidence",
        "validator-backed committed state artifacts",
        "generated state artifacts only",
        "contract-only artifacts",
        "proof-review packages",
        "validation manifests",
        "operator reports",
        "planning artifacts",
        "narrative context",
        "external replay evidence",
        "local-only rejected evidence",
        "runtime/product claims rejected unless later implemented and evidenced"
    ) -Context "$SourceLabel proof_treatment_policy treatment_categories"

    $overclaim = Assert-ObjectValue -Value $Contract.overclaim_detection_policy -Context "$SourceLabel overclaim_detection_policy"
    Assert-RequiredStringsPresent -Actual (Assert-StringArray -Value $overclaim.rejected_claims -Context "$SourceLabel overclaim_detection_policy rejected_claims") -Required $script:RejectedClaims -Context "$SourceLabel overclaim_detection_policy rejected_claims"
    Assert-CurrentPosture -Posture $Contract.current_posture -Context "$SourceLabel current_posture"
    Assert-PreservedBoundaries -Boundaries $Contract.preserved_boundaries -Context "$SourceLabel preserved_boundaries"

    return [pscustomobject]@{
        ReportContractId = $Contract.report_contract_id
        SourceTask = $Contract.source_task
        DependencyRefCount = $dependencyRefs.Count
        CheckScopeCount = $script:CheckScopeIds.Count
    }
}

function Test-R16ArtifactAuditMapCheckReportContract {
    [CmdletBinding()]
    param(
        [string]$Path = "contracts/artifacts/r16_artifact_audit_map_check_report.contract.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedPath = Assert-SafeRepoRelativePath -Path $Path -RepositoryRoot $resolvedRoot -Context "R16-013 report contract path" -RequireLeaf
    $contract = Read-SingleJsonObject -Path $resolvedPath -Label "R16-013 report contract"
    return Test-R16ArtifactAuditMapCheckReportContractObject -Contract $contract -SourceLabel $Path -RepositoryRoot $resolvedRoot
}

function Get-R16ArtifactAuditMapPathRefs {
    param(
        [Parameter(Mandatory = $true)]$ArtifactMap,
        [Parameter(Mandatory = $true)]$AuditMap,
        [Parameter(Mandatory = $true)][string]$ArtifactMapPath,
        [Parameter(Mandatory = $true)][string]$AuditMapPath,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    $refs = [System.Collections.ArrayList]::new()
    Add-PathRef -Refs $refs -Path $ArtifactMapPath -RefId "artifact_map_ref" -Source "check_input"
    Add-PathRef -Refs $refs -Path $AuditMapPath -RefId "audit_map_ref" -Source "check_input"

    $order = 0
    foreach ($path in @($ArtifactMap.required_paths)) {
        $order += 1
        Add-PathRef -Refs $refs -Path ([string]$path) -RefId ("artifact_map_required_path_{0}" -f $order) -Source "artifact_map.required_paths"
    }

    foreach ($record in @($ArtifactMap.artifact_records)) {
        Add-PathRef -Refs $refs -Path ([string]$record.path) -RefId ([string]$record.artifact_id) -Source "artifact_map.artifact_records" -ProofStatus ([string]$record.proof_status) -EvidenceKind ([string]$record.evidence_kind)
        if (Test-HasProperty -Object $record -Name "inspection_route") {
            Add-PathRef -Refs $refs -Path ([string]$record.inspection_route.path) -RefId ([string]$record.inspection_route.route_id) -Source "artifact_map.inspection_route"
        }
        foreach ($ref in @($record.source_refs)) {
            Add-PathRef -Refs $refs -Path ([string]$ref.path) -RefId ([string]$ref.ref_id) -Source "artifact_map.source_refs" -ProofStatus ([string]$ref.proof_status) -EvidenceKind ([string]$ref.evidence_kind) -MachineProof:([bool]$ref.machine_proof) -ImplementationProof:([bool]$ref.implementation_proof)
        }
        foreach ($ref in @($record.dependency_refs)) {
            Add-PathRef -Refs $refs -Path ([string]$ref.path) -RefId ([string]$ref.ref_id) -Source "artifact_map.dependency_refs" -ProofStatus ([string]$ref.proof_status) -EvidenceKind ([string]$ref.evidence_kind) -MachineProof:([bool]$ref.machine_proof) -ImplementationProof:([bool]$ref.implementation_proof)
        }
    }

    $order = 0
    foreach ($path in @($AuditMap.required_paths)) {
        $order += 1
        Add-PathRef -Refs $refs -Path ([string]$path) -RefId ("audit_map_required_path_{0}" -f $order) -Source "audit_map.required_paths"
    }

    foreach ($entry in @($AuditMap.audit_entries)) {
        Add-PathRef -Refs $refs -Path ([string]$entry.evidence_path) -RefId ([string]$entry.audit_entry_id) -Source "audit_map.audit_entries" -ProofStatus ([string]$entry.proof_status) -EvidenceKind ([string]$entry.evidence_kind)
        if (Test-HasProperty -Object $entry -Name "inspection_route") {
            Add-PathRef -Refs $refs -Path ([string]$entry.inspection_route.evidence_path) -RefId ([string]$entry.inspection_route.route_id) -Source "audit_map.inspection_route"
        }
        foreach ($command in @($entry.validation_commands)) {
            Add-PathRef -Refs $refs -Path ([string]$command.validates_path) -RefId ([string]$command.command_id) -Source "audit_map.validation_commands" -EvidenceKind ([string]$command.evidence_kind)
        }
    }

    foreach ($caveat in @($AuditMap.caveats)) {
        Add-PathRef -Refs $refs -Path ([string]$caveat.applies_to_path) -RefId ([string]$caveat.caveat_id) -Source "audit_map.caveats"
    }

    foreach ($proofPath in @(
            "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_012_r15_r16_audit_map/proof_review.json",
            "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_012_r15_r16_audit_map/evidence_index.json"
        )) {
        $resolvedProofPath = Resolve-RepoRelativePathValue -Path $proofPath -RepositoryRoot $RepositoryRoot
        if (Test-Path -LiteralPath $resolvedProofPath -PathType Leaf) {
            $proofObject = Read-SingleJsonObject -Path $resolvedProofPath -Label $proofPath
            Add-StringPropertyPathRefs -Refs $refs -Object $proofObject -Source $proofPath
        }
    }

    return @($refs)
}

function Add-PathPolicyFindings {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.ArrayList]$Findings,
        [Parameter(Mandatory = $true)]$PathRefs,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    foreach ($pathRef in @($PathRefs)) {
        $path = [string]$pathRef.Path
        if (Test-WildcardPath -Path $path) {
            Add-Finding -Findings $Findings -FindingId "wildcard_path_rejected" -Category "wildcard_path_policy" -Severity "fail" -SubjectPath $path -SubjectRefId ([string]$pathRef.RefId) -Expected "no wildcard paths" -Actual $path -Message "Wildcard path '$path' is rejected."
            continue
        }
        if (Test-BroadRepoRootPath -Path $path) {
            Add-Finding -Findings $Findings -FindingId "broad_repo_root_path_rejected" -Category "broad_repo_root_policy" -Severity "fail" -SubjectPath $path -SubjectRefId ([string]$pathRef.RefId) -Expected "exact repo-relative file path" -Actual $path -Message "Broad repo root path '$path' is rejected."
            continue
        }
        if ([System.IO.Path]::IsPathRooted($path) -or $path -match '(^|/)\.\.(/|$)') {
            Add-Finding -Findings $Findings -FindingId "exact_path_policy_rejected" -Category "exact_path_policy" -Severity "fail" -SubjectPath $path -SubjectRefId ([string]$pathRef.RefId) -Expected "safe repo-relative path" -Actual $path -Message "Path '$path' is not a safe repo-relative exact path."
            continue
        }
        if (Test-DirectoryOnlyPath -Path $path -RepositoryRoot $RepositoryRoot) {
            Add-Finding -Findings $Findings -FindingId "directory_only_proof_claim_rejected" -Category "directory_only_proof_policy" -Severity "fail" -SubjectPath $path -SubjectRefId ([string]$pathRef.RefId) -Expected "exact evidence file path" -Actual $path -Message "Directory-only proof claim '$path' is rejected unless exact files are listed."
            continue
        }

        $resolved = Resolve-RepoRelativePathValue -Path $path -RepositoryRoot $RepositoryRoot
        if (-not (Test-Path -LiteralPath $resolved -PathType Leaf)) {
            Add-Finding -Findings $Findings -FindingId "missing_required_path_rejected" -Category "required_path_presence" -Severity "fail" -SubjectPath $path -SubjectRefId ([string]$pathRef.RefId) -Expected "path exists" -Actual "missing" -Message "Required evidence path '$path' does not exist."
            continue
        }

        if (Test-ReportLikeMachineProofMisuse -PathRef $pathRef) {
            Add-Finding -Findings $Findings -FindingId "report_as_machine_proof_rejected" -Category "report_proof_treatment_policy" -Severity "fail" -SubjectPath $path -SubjectRefId ([string]$pathRef.RefId) -Expected "report or planning artifact is context/proof-review only" -Actual "machine proof or implementation proof" -Message "Report/Markdown planning artifact '$path' cannot be treated as machine implementation proof."
        }
    }
}

function Add-StaleCaveatFindings {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.ArrayList]$Findings,
        [Parameter(Mandatory = $true)]$ArtifactMap,
        [Parameter(Mandatory = $true)]$AuditMap
    )

    foreach ($record in @($ArtifactMap.artifact_records)) {
        foreach ($ref in @($record.source_refs)) {
            if ([string]$ref.stale_state -ne "fresh" -and [string]::IsNullOrWhiteSpace([string]$ref.caveat_id)) {
                Add-Finding -Findings $Findings -FindingId "artifact_source_ref_stale_without_caveat" -Category "stale_generated_from_policy" -Severity "fail" -SubjectPath ([string]$ref.path) -SubjectRefId ([string]$ref.ref_id) -Expected "stale refs carry explicit caveat_id" -Actual "missing caveat_id" -Message "Stale artifact source ref '$($ref.ref_id)' is missing an explicit caveat."
            }
        }
    }

    $auditCaveatIds = @($AuditMap.caveats | ForEach-Object { [string]$_.caveat_id })
    foreach ($entry in @($AuditMap.audit_entries)) {
        if ([string]$entry.stale_ref_status -ne "fresh") {
            if ([string]::IsNullOrWhiteSpace([string]$entry.caveat_id) -or $auditCaveatIds -notcontains [string]$entry.caveat_id) {
                Add-Finding -Findings $Findings -FindingId "audit_entry_stale_without_caveat" -Category "stale_generated_from_policy" -Severity "fail" -SubjectPath ([string]$entry.evidence_path) -SubjectRefId ([string]$entry.audit_entry_id) -Expected "stale generated_from ref has explicit caveat" -Actual "missing or undeclared caveat" -Message "Stale audit entry '$($entry.audit_entry_id)' is missing an explicit caveat."
            }
        }
    }

    foreach ($known in $script:KnownR15Caveats) {
        $matching = @($AuditMap.caveats | Where-Object { $_.caveat_id -eq $known.caveat_id -and $_.applies_to_path -eq $known.path })
        if ($matching.Count -eq 0) {
            Add-Finding -Findings $Findings -FindingId "r15_stale_caveat_missing" -Category "r15_caveat_preservation" -Severity "fail" -SubjectPath $known.path -SubjectRefId $known.applies_to_ref_id -Expected "explicit preserved R15 stale generated_from caveat" -Actual "missing" -Message "Known R15 stale generated_from caveat '$($known.caveat_id)' is not preserved."
        }
        else {
            Add-Finding -Findings $Findings -FindingId ("accepted_{0}" -f $known.caveat_id) -Category "stale_generated_from_policy" -Severity "warning" -SubjectPath $known.path -SubjectRefId $known.applies_to_ref_id -Expected "stale generated_from is visible and caveated" -Actual "accepted with explicit caveat" -AcceptedCaveatId $known.caveat_id -Message "Known R15 stale generated_from ref is accepted only because the audit map preserves explicit caveat '$($known.caveat_id)'."
        }
    }
}

function Add-OverclaimFindings {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.ArrayList]$Findings,
        [Parameter(Mandatory = $true)]$ArtifactMap,
        [Parameter(Mandatory = $true)]$AuditMap
    )

    $artifactMode = Assert-ObjectValue -Value $ArtifactMap.generation_mode -Context "artifact map generation_mode"
    foreach ($field in @(
        "generated_artifact_map_is_runtime_memory",
        "audit_map_implemented",
        "context_load_planner_implemented",
        "context_budget_estimator_implemented",
        "role_run_envelope_implemented",
        "raci_transition_gate_implemented",
        "handoff_packet_implemented",
        "workflow_drill_run",
        "product_runtime_implemented",
        "actual_autonomous_agents_implemented",
        "external_integrations_implemented"
    )) {
        if ((Test-HasProperty -Object $artifactMode -Name $field) -and [bool](Get-RequiredProperty -Object $artifactMode -Name $field -Context "artifact map generation_mode")) {
            Add-Finding -Findings $Findings -FindingId ("artifact_mode_{0}_overclaim" -f $field) -Category "runtime_overclaim_policy" -Severity "fail" -SubjectPath "state/artifacts/r16_artifact_map.json" -SubjectRefId $field -Expected "False" -Actual "True" -Message "Artifact map generation mode overclaim '$field' is rejected."
        }
    }

    $auditMode = Assert-ObjectValue -Value $AuditMap.generation_mode -Context "audit map generation_mode"
    foreach ($field in @(
        "generated_audit_map_is_runtime_memory",
        "artifact_map_diff_tooling_implemented",
        "context_load_planner_implemented",
        "context_budget_estimator_implemented",
        "role_run_envelope_implemented",
        "raci_transition_gate_implemented",
        "handoff_packet_implemented",
        "workflow_drill_run",
        "product_runtime_implemented",
        "actual_autonomous_agents_implemented",
        "external_integrations_implemented"
    )) {
        if ((Test-HasProperty -Object $auditMode -Name $field) -and [bool](Get-RequiredProperty -Object $auditMode -Name $field -Context "audit map generation_mode")) {
            $category = if ($field -match 'context') { "context_planner_overclaim_policy" } elseif ($field -match 'role|handoff|workflow|raci') { "role_workflow_overclaim_policy" } else { "runtime_overclaim_policy" }
            Add-Finding -Findings $Findings -FindingId ("audit_mode_{0}_overclaim" -f $field) -Category $category -Severity "fail" -SubjectPath "state/audit/r16_r15_r16_audit_map.json" -SubjectRefId $field -Expected "False" -Actual "True" -Message "Audit map generation mode overclaim '$field' is rejected."
        }
    }
}

function New-AcceptedCaveatObjects {
    $items = @()
    $order = 0
    foreach ($known in $script:KnownR15Caveats) {
        $order += 1
        $items += [ordered]@{
            caveat_id = $known.caveat_id
            caveat_type = $known.caveat_type
            path = $known.path
            applies_to_ref_id = $known.applies_to_ref_id
            declared_boundary = $known.declared_boundary
            observed_boundary = $known.observed_boundary
            accepted_reason = $known.accepted_reason
            preserved_scope = $known.preserved_scope
            deterministic_order = $order
        }
    }

    return $items
}

function Get-ZeroSummaryCounters {
    return [ordered]@{
        missing_required_paths = 0
        wildcard_paths = 0
        broad_repo_root_paths = 0
        directory_only_proof_claims = 0
        stale_generated_from_without_caveat = 0
        report_as_machine_proof_errors = 0
        runtime_overclaims = 0
        context_planner_overclaims = 0
        role_workflow_overclaims = 0
        later_task_overclaims = 0
        r13_boundary_violations = 0
        r14_caveat_removals = 0
        r15_caveat_removals = 0
    }
}

function Get-CheckCounterSummary {
    param([Parameter(Mandatory = $true)]$Findings)

    $items = @($Findings)
    return [ordered]@{
        missing_required_paths = @($items | Where-Object { $_.category -eq "required_path_presence" -and $_.severity -eq "fail" }).Count
        wildcard_paths = @($items | Where-Object { $_.category -eq "wildcard_path_policy" -and $_.severity -eq "fail" }).Count
        broad_repo_root_paths = @($items | Where-Object { $_.category -eq "broad_repo_root_policy" -and $_.severity -eq "fail" }).Count
        directory_only_proof_claims = @($items | Where-Object { $_.category -eq "directory_only_proof_policy" -and $_.severity -eq "fail" }).Count
        stale_generated_from_without_caveat = @($items | Where-Object { $_.category -in @("stale_generated_from_policy", "r15_caveat_preservation") -and $_.severity -eq "fail" }).Count
        report_as_machine_proof_errors = @($items | Where-Object { $_.category -eq "report_proof_treatment_policy" -and $_.severity -eq "fail" }).Count
        runtime_overclaims = @($items | Where-Object { $_.category -eq "runtime_overclaim_policy" -and $_.severity -eq "fail" }).Count
        context_planner_overclaims = @($items | Where-Object { $_.category -eq "context_planner_overclaim_policy" -and $_.severity -eq "fail" }).Count
        role_workflow_overclaims = @($items | Where-Object { $_.category -eq "role_workflow_overclaim_policy" -and $_.severity -eq "fail" }).Count
        later_task_overclaims = @($items | Where-Object { $_.category -eq "later_task_overclaim_policy" -and $_.severity -eq "fail" }).Count
        r13_boundary_violations = @($items | Where-Object { $_.category -eq "historical_boundary_policy" -and $_.subject_ref_id -eq "r13" -and $_.severity -eq "fail" }).Count
        r14_caveat_removals = @($items | Where-Object { $_.category -eq "historical_boundary_policy" -and $_.subject_ref_id -eq "r14" -and $_.severity -eq "fail" }).Count
        r15_caveat_removals = @($items | Where-Object { $_.category -eq "historical_boundary_policy" -and $_.subject_ref_id -eq "r15" -and $_.severity -eq "fail" }).Count
    }
}

function New-R16ArtifactAuditMapCheckReportObject {
    [CmdletBinding()]
    param(
        [string]$ArtifactMapPath = "state/artifacts/r16_artifact_map.json",
        [string]$AuditMapPath = "state/audit/r16_r15_r16_audit_map.json",
        [string]$ContractPath = "contracts/artifacts/r16_artifact_audit_map_check_report.contract.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    Test-R16ArtifactAuditMapCheckReportContract -Path $ContractPath -RepositoryRoot $resolvedRoot | Out-Null

    $artifactMapValidation = Test-R16ArtifactMap -Path $ArtifactMapPath -RepositoryRoot $resolvedRoot
    $auditMapValidation = Test-R16AuditMap -Path $AuditMapPath -RepositoryRoot $resolvedRoot -ArtifactMapPath $ArtifactMapPath

    $artifactMapResolved = Assert-SafeRepoRelativePath -Path $ArtifactMapPath -RepositoryRoot $resolvedRoot -Context "artifact map input" -RequireLeaf
    $auditMapResolved = Assert-SafeRepoRelativePath -Path $AuditMapPath -RepositoryRoot $resolvedRoot -Context "audit map input" -RequireLeaf
    $artifactMap = Read-SingleJsonObject -Path $artifactMapResolved -Label "R16 artifact map"
    $auditMap = Read-SingleJsonObject -Path $auditMapResolved -Label "R16 audit map"

    $findings = [System.Collections.ArrayList]::new()
    $pathRefs = Get-R16ArtifactAuditMapPathRefs -ArtifactMap $artifactMap -AuditMap $auditMap -ArtifactMapPath $ArtifactMapPath -AuditMapPath $AuditMapPath -RepositoryRoot $resolvedRoot
    Add-PathPolicyFindings -Findings $findings -PathRefs $pathRefs -RepositoryRoot $resolvedRoot
    Add-StaleCaveatFindings -Findings $findings -ArtifactMap $artifactMap -AuditMap $auditMap
    Add-OverclaimFindings -Findings $findings -ArtifactMap $artifactMap -AuditMap $auditMap

    $counterSummary = Get-CheckCounterSummary -Findings $findings
    if (@($findings | Where-Object { $_.severity -eq "fail" }).Count -eq 0) {
        Add-Finding -Findings $findings -FindingId "contract_validated" -Category "exact_path_policy" -Severity "pass" -SubjectPath $ContractPath -SubjectRefId "report_contract" -Expected "contract validates" -Actual "passed" -Message "R16-013 report contract validates and preserves check-only semantics."
        Add-Finding -Findings $findings -FindingId "artifact_map_loaded" -Category "required_path_presence" -Severity "pass" -SubjectPath $ArtifactMapPath -SubjectRefId "artifact_map_ref" -Expected "artifact map loaded and validated" -Actual ("records={0}" -f $artifactMapValidation.RecordCount) -Message "R16 artifact map loaded and validated from exact path."
        Add-Finding -Findings $findings -FindingId "audit_map_loaded" -Category "required_path_presence" -Severity "pass" -SubjectPath $AuditMapPath -SubjectRefId "audit_map_ref" -Expected "audit map loaded and validated" -Actual ("entries={0}" -f $auditMapValidation.EntryCount) -Message "R16 R15/R16 audit map loaded and validated from exact path."
        Add-Finding -Findings $findings -FindingId "required_paths_exist" -Category "required_path_presence" -Severity "pass" -SubjectPath "" -SubjectRefId "required_paths" -Expected "all required paths exist" -Actual "missing=0" -Message "Artifact-map and audit-map required paths exist."
        Add-Finding -Findings $findings -FindingId "exact_paths_only" -Category "exact_path_policy" -Severity "pass" -SubjectPath "" -SubjectRefId "exact_ref_policy" -Expected "repo-relative exact file paths" -Actual ("checked={0}" -f @($pathRefs).Count) -Message "Artifact records, audit entries, source refs, inspection routes, and practical proof-review refs use exact file paths."
        Add-Finding -Findings $findings -FindingId "no_wildcards" -Category "wildcard_path_policy" -Severity "pass" -SubjectPath "" -SubjectRefId "wildcard_policy" -Expected "no wildcard paths" -Actual "wildcard_paths=0" -Message "No wildcard path claims were found."
        Add-Finding -Findings $findings -FindingId "no_broad_repo_root_paths" -Category "broad_repo_root_policy" -Severity "pass" -SubjectPath "" -SubjectRefId "broad_repo_root_policy" -Expected "no broad repo root paths" -Actual "broad_repo_root_paths=0" -Message "No broad repo-root path claims were found."
        Add-Finding -Findings $findings -FindingId "no_directory_only_proof_claims" -Category "directory_only_proof_policy" -Severity "pass" -SubjectPath "" -SubjectRefId "directory_only_policy" -Expected "no directory-only proof claims" -Actual "directory_only_proof_claims=0" -Message "No directory-only proof claims were found."
        Add-Finding -Findings $findings -FindingId "no_report_as_machine_proof" -Category "report_proof_treatment_policy" -Severity "pass" -SubjectPath "" -SubjectRefId "proof_treatment_policy" -Expected "reports and manifests are not machine implementation proof by themselves" -Actual "report_as_machine_proof_errors=0" -Message "Reports, manifests, and planning artifacts are not treated as machine implementation proof."
        Add-Finding -Findings $findings -FindingId "current_posture_preserved" -Category "later_task_overclaim_policy" -Severity "pass" -SubjectPath "" -SubjectRefId "current_posture" -Expected "active through R16-013 only" -Actual "R16-014 through R16-026 planned only" -Message "Current posture is active through R16-013 only; R16-014 through R16-026 remain planned only."
        Add-Finding -Findings $findings -FindingId "historical_boundaries_preserved" -Category "historical_boundary_policy" -Severity "pass" -SubjectPath "" -SubjectRefId "r13_r14_r15" -Expected "R13 failed/partial, R14/R15 caveats preserved" -Actual "preserved" -Message "R13 remains failed/partial and not closed; R14/R15 caveats remain preserved."
        Add-Finding -Findings $findings -FindingId "no_runtime_or_integration_overclaims" -Category "runtime_overclaim_policy" -Severity "pass" -SubjectPath "" -SubjectRefId "non_claims" -Expected "no runtime/product/agent/integration claims" -Actual "overclaims=0" -Message "No product runtime, runtime memory, autonomous agent, or external integration overclaims were found."
        Add-Finding -Findings $findings -FindingId "no_context_or_role_workflow_overclaims" -Category "context_planner_overclaim_policy" -Severity "pass" -SubjectPath "" -SubjectRefId "non_claims" -Expected "no context planner or role workflow implementation" -Actual "overclaims=0" -Message "No context-load planner, budget estimator, role-run envelope, handoff packet, RACI transition gate, or workflow drill claims were found."
    }

    $findingCounts = Get-FindingCounts -Findings $findings
    $counterSummary = Get-CheckCounterSummary -Findings $findings
    $aggregateVerdict = if ($findingCounts.fail_count -gt 0) { "failed" } elseif ($findingCounts.warning_count -gt 0) { "passed_with_caveats" } else { "passed" }

    $findingSummary = [ordered]@{}
    foreach ($property in $findingCounts.GetEnumerator()) {
        $findingSummary[$property.Key] = $property.Value
    }
    foreach ($property in $counterSummary.GetEnumerator()) {
        $findingSummary[$property.Key] = $property.Value
    }

    return [ordered]@{
        artifact_type = "r16_artifact_audit_map_check_report"
        report_version = "v1"
        report_id = $script:ReportId
        source_milestone = $script:R16Milestone
        source_task = "R16-013"
        repository = $script:Repository
        branch = $script:Branch
        generation_boundary = [ordered]@{
            input_head = $script:InputHead
            input_tree = $script:InputTree
            boundary_note = "input boundary for generation, not a claim to equal final R16-013 commit"
        }
        artifact_map_ref = [ordered]@{
            path = (ConvertTo-NormalizedRepoPath -Path $ArtifactMapPath)
            source_task = "R16-010"
            loaded_and_validated = $true
        }
        audit_map_ref = [ordered]@{
            path = (ConvertTo-NormalizedRepoPath -Path $AuditMapPath)
            source_task = "R16-012"
            loaded_and_validated = $true
        }
        current_posture = [ordered]@{
            active_through_task = "R16-013"
            complete_tasks = $script:CompleteTasks
            planned_tasks = $script:PlannedTasks
            r16_014_or_later_implementation_claimed = $false
            r16_027_or_later_task_exists = $false
        }
        check_mode = [ordered]@{
            artifact_audit_map_check_tooling_implemented = $true
            check_report_state_artifact = $true
            context_load_planner_implemented = $false
            context_budget_estimator_implemented = $false
            role_run_envelope_implemented = $false
            raci_transition_gate_implemented = $false
            handoff_packet_implemented = $false
            workflow_drill_run = $false
            runtime_memory_implemented = $false
            product_runtime_implemented = $false
            actual_autonomous_agents_implemented = $false
            external_integrations_implemented = $false
        }
        exact_ref_summary = [ordered]@{
            artifact_map_required_paths_checked = @($artifactMap.required_paths).Count
            audit_map_required_paths_checked = @($auditMap.required_paths).Count
            artifact_records_checked = @($artifactMap.artifact_records).Count
            audit_entries_checked = @($auditMap.audit_entries).Count
            missing_required_paths = $counterSummary.missing_required_paths
            wildcard_paths = $counterSummary.wildcard_paths
            broad_repo_root_paths = $counterSummary.broad_repo_root_paths
            directory_only_proof_claims = $counterSummary.directory_only_proof_claims
            stale_generated_from_without_caveat = $counterSummary.stale_generated_from_without_caveat
            report_as_machine_proof_errors = $counterSummary.report_as_machine_proof_errors
        }
        accepted_caveats = (New-AcceptedCaveatObjects)
        findings = @($findings)
        finding_summary = $findingSummary
        aggregate_verdict = $aggregateVerdict
        preserved_boundaries = [ordered]@{
            r13 = [ordered]@{
                status = "failed_partial_through_r13_018_only"
                closed = $false
                partial_gates_remain_partial = $true
                partial_gates_converted_to_passed = $false
            }
            r14 = [ordered]@{
                status = "accepted_with_caveats_through_r14_006_only"
                caveats_removed = $false
            }
            r15 = [ordered]@{
                status = "accepted_with_caveats_through_r15_009_only"
                caveats_removed = $false
                stale_generated_from_caveat_preserved = $true
            }
        }
        non_claims = $script:RequiredNonClaims
    }
}

function Assert-ZeroReportCounters {
    param(
        [Parameter(Mandatory = $true)]$Summary,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in @(
        "missing_required_paths",
        "wildcard_paths",
        "broad_repo_root_paths",
        "directory_only_proof_claims",
        "stale_generated_from_without_caveat",
        "report_as_machine_proof_errors",
        "runtime_overclaims",
        "context_planner_overclaims",
        "role_workflow_overclaims",
        "later_task_overclaims",
        "r13_boundary_violations",
        "r14_caveat_removals",
        "r15_caveat_removals"
    )) {
        $value = Assert-IntegerValue -Value (Get-RequiredProperty -Object $Summary -Name $field -Context $Context) -Context "$Context $field"
        if ($value -ne 0) {
            throw "$Context $field must be 0."
        }
    }
}

function Assert-FindingObject {
    param(
        [Parameter(Mandatory = $true)]$Finding,
        [Parameter(Mandatory = $true)][int]$ExpectedOrder,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($field in $script:RequiredFindingFields) {
        Get-RequiredProperty -Object $Finding -Name $field -Context $Context | Out-Null
    }
    if ([string]$Finding.category -notin $script:FindingCategories) {
        throw "$Context category '$($Finding.category)' is not allowed."
    }
    if ([string]$Finding.severity -notin $script:FindingSeverities) {
        throw "$Context severity '$($Finding.severity)' is not allowed."
    }
    if ((Assert-IntegerValue -Value $Finding.deterministic_order -Context "$Context deterministic_order") -ne $ExpectedOrder) {
        throw "$Context deterministic_order must be $ExpectedOrder."
    }
}

function Test-R16ArtifactAuditMapCheckReportObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Report,
        [string]$SourceLabel = "R16 artifact audit map check report",
        [string]$RepositoryRoot,
        [string]$ContractPath = "contracts/artifacts/r16_artifact_audit_map_check_report.contract.json"
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    Test-R16ArtifactAuditMapCheckReportContract -Path $ContractPath -RepositoryRoot $resolvedRoot | Out-Null

    foreach ($field in @(
        "artifact_type",
        "report_version",
        "report_id",
        "source_milestone",
        "source_task",
        "repository",
        "branch",
        "generation_boundary",
        "artifact_map_ref",
        "audit_map_ref",
        "current_posture",
        "check_mode",
        "exact_ref_summary",
        "accepted_caveats",
        "findings",
        "finding_summary",
        "aggregate_verdict",
        "preserved_boundaries",
        "non_claims"
    )) {
        Get-RequiredProperty -Object $Report -Name $field -Context $SourceLabel | Out-Null
    }

    if ($Report.artifact_type -ne "r16_artifact_audit_map_check_report") {
        throw "$SourceLabel artifact_type must be r16_artifact_audit_map_check_report."
    }
    if ($Report.report_version -ne "v1" -or $Report.report_id -ne $script:ReportId -or $Report.source_task -ne "R16-013") {
        throw "$SourceLabel report id, version, or source task is incorrect."
    }
    if ($Report.source_milestone -ne $script:R16Milestone -or $Report.repository -ne $script:Repository -or $Report.branch -ne $script:Branch) {
        throw "$SourceLabel repository, branch, or milestone metadata is incorrect."
    }

    $boundary = Assert-ObjectValue -Value $Report.generation_boundary -Context "$SourceLabel generation_boundary"
    if ($boundary.input_head -ne $script:InputHead -or $boundary.input_tree -ne $script:InputTree) {
        throw "$SourceLabel generation_boundary must preserve the R16-013 input head and tree."
    }

    $artifactRef = Assert-ObjectValue -Value $Report.artifact_map_ref -Context "$SourceLabel artifact_map_ref"
    if ($artifactRef.path -ne "state/artifacts/r16_artifact_map.json" -or $artifactRef.source_task -ne "R16-010" -or $artifactRef.loaded_and_validated -ne $true) {
        throw "$SourceLabel artifact_map_ref must load and validate state/artifacts/r16_artifact_map.json."
    }
    Assert-SafeRepoRelativePath -Path ([string]$artifactRef.path) -RepositoryRoot $resolvedRoot -Context "$SourceLabel artifact_map_ref" -RequireLeaf | Out-Null

    $auditRef = Assert-ObjectValue -Value $Report.audit_map_ref -Context "$SourceLabel audit_map_ref"
    if ($auditRef.path -ne "state/audit/r16_r15_r16_audit_map.json" -or $auditRef.source_task -ne "R16-012" -or $auditRef.loaded_and_validated -ne $true) {
        throw "$SourceLabel audit_map_ref must load and validate state/audit/r16_r15_r16_audit_map.json."
    }
    Assert-SafeRepoRelativePath -Path ([string]$auditRef.path) -RepositoryRoot $resolvedRoot -Context "$SourceLabel audit_map_ref" -RequireLeaf | Out-Null

    Assert-CurrentPosture -Posture $Report.current_posture -Context "$SourceLabel current_posture"
    Assert-ReportMode -Mode $Report.check_mode -Context "$SourceLabel check_mode"
    Assert-PreservedBoundaries -Boundaries $Report.preserved_boundaries -Context "$SourceLabel preserved_boundaries"

    $exactRefSummary = Assert-ObjectValue -Value $Report.exact_ref_summary -Context "$SourceLabel exact_ref_summary"
    foreach ($field in @(
        "artifact_map_required_paths_checked",
        "audit_map_required_paths_checked",
        "artifact_records_checked",
        "audit_entries_checked",
        "missing_required_paths",
        "wildcard_paths",
        "broad_repo_root_paths",
        "directory_only_proof_claims",
        "stale_generated_from_without_caveat",
        "report_as_machine_proof_errors"
    )) {
        Assert-IntegerValue -Value (Get-RequiredProperty -Object $exactRefSummary -Name $field -Context "$SourceLabel exact_ref_summary") -Context "$SourceLabel exact_ref_summary $field" | Out-Null
    }
    foreach ($zeroField in @(
        "missing_required_paths",
        "wildcard_paths",
        "broad_repo_root_paths",
        "directory_only_proof_claims",
        "stale_generated_from_without_caveat",
        "report_as_machine_proof_errors"
    )) {
        if ([int](Get-RequiredProperty -Object $exactRefSummary -Name $zeroField -Context "$SourceLabel exact_ref_summary") -ne 0) {
            throw "$SourceLabel exact_ref_summary $zeroField must be 0."
        }
    }

    Assert-AcceptedCaveats -Caveats $Report.accepted_caveats -Context "$SourceLabel accepted_caveats"

    $findings = Assert-ObjectArray -Value $Report.findings -Context "$SourceLabel findings"
    for ($index = 0; $index -lt $findings.Count; $index += 1) {
        Assert-FindingObject -Finding $findings[$index] -ExpectedOrder ($index + 1) -Context "$SourceLabel findings[$index]"
    }

    $summary = Assert-ObjectValue -Value $Report.finding_summary -Context "$SourceLabel finding_summary"
    foreach ($field in @("pass_count", "info_count", "warning_count", "fail_count")) {
        Assert-IntegerValue -Value (Get-RequiredProperty -Object $summary -Name $field -Context "$SourceLabel finding_summary") -Context "$SourceLabel finding_summary $field" | Out-Null
    }
    if ([int]$summary.fail_count -ne 0) {
        throw "$SourceLabel finding_summary fail_count must be 0."
    }
    Assert-ZeroReportCounters -Summary $summary -Context "$SourceLabel finding_summary"

    $computedCounts = Get-FindingCounts -Findings $findings
    foreach ($field in @("pass_count", "info_count", "warning_count", "fail_count")) {
        if ([int]$summary.$field -ne [int]$computedCounts[$field]) {
            throw "$SourceLabel finding_summary $field does not match findings."
        }
    }

    if ($Report.aggregate_verdict -notin @("passed", "passed_with_caveats")) {
        throw "$SourceLabel aggregate_verdict must be passed or passed_with_caveats."
    }
    if ([int]$summary.warning_count -gt 0 -and $Report.aggregate_verdict -ne "passed_with_caveats") {
        throw "$SourceLabel aggregate_verdict must be passed_with_caveats when accepted caveat warnings exist."
    }
    if ([int]$summary.warning_count -eq 0 -and $Report.aggregate_verdict -ne "passed") {
        throw "$SourceLabel aggregate_verdict must be passed when no warnings exist."
    }

    $nonClaims = Assert-StringArray -Value $Report.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredStringsPresent -Actual $nonClaims -Required $script:RequiredNonClaims -Context "$SourceLabel non_claims"

    return [pscustomobject]@{
        ReportId = $Report.report_id
        SourceTask = $Report.source_task
        ActiveThroughTask = $Report.current_posture.active_through_task
        PlannedTaskStart = $Report.current_posture.planned_tasks[0]
        PlannedTaskEnd = $Report.current_posture.planned_tasks[-1]
        FindingCount = $findings.Count
        WarningCount = [int]$summary.warning_count
        AggregateVerdict = $Report.aggregate_verdict
    }
}

function Test-R16ArtifactAuditMapCheckReport {
    [CmdletBinding()]
    param(
        [string]$Path = "state/artifacts/r16_artifact_audit_map_check_report.json",
        [string]$RepositoryRoot,
        [string]$ContractPath = "contracts/artifacts/r16_artifact_audit_map_check_report.contract.json"
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedPath = Assert-SafeRepoRelativePath -Path $Path -RepositoryRoot $resolvedRoot -Context "R16-013 check report path" -RequireLeaf
    $report = Read-SingleJsonObject -Path $resolvedPath -Label "R16-013 check report"
    return Test-R16ArtifactAuditMapCheckReportObject -Report $report -SourceLabel $Path -RepositoryRoot $resolvedRoot -ContractPath $ContractPath
}

function New-R16ArtifactAuditMapCheckReport {
    [CmdletBinding()]
    param(
        [string]$ArtifactMapPath = "state/artifacts/r16_artifact_map.json",
        [string]$AuditMapPath = "state/audit/r16_r15_r16_audit_map.json",
        [string]$ContractPath = "contracts/artifacts/r16_artifact_audit_map_check_report.contract.json",
        [string]$OutputPath = "state/artifacts/r16_artifact_audit_map_check_report.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedOutput = Assert-SafeRepoRelativePath -Path $OutputPath -RepositoryRoot $resolvedRoot -Context "OutputPath"
    $report = New-R16ArtifactAuditMapCheckReportObject -ArtifactMapPath $ArtifactMapPath -AuditMapPath $AuditMapPath -ContractPath $ContractPath -RepositoryRoot $resolvedRoot
    Write-StableJsonFile -Object $report -Path $resolvedOutput
    $validation = Test-R16ArtifactAuditMapCheckReport -Path $OutputPath -RepositoryRoot $resolvedRoot -ContractPath $ContractPath

    return [pscustomobject]@{
        OutputPath = $OutputPath
        ReportId = $validation.ReportId
        FindingCount = $validation.FindingCount
        WarningCount = $validation.WarningCount
        AggregateVerdict = $validation.AggregateVerdict
        ActiveThroughTask = $validation.ActiveThroughTask
        PlannedTaskStart = $validation.PlannedTaskStart
        PlannedTaskEnd = $validation.PlannedTaskEnd
    }
}

function Add-FailFindingToFixture {
    param(
        [Parameter(Mandatory = $true)]$Report,
        [Parameter(Mandatory = $true)][string]$FindingId,
        [Parameter(Mandatory = $true)][string]$Category,
        [Parameter(Mandatory = $true)][string]$SubjectPath,
        [Parameter(Mandatory = $true)][string]$SubjectRefId,
        [Parameter(Mandatory = $true)][string]$Expected,
        [Parameter(Mandatory = $true)][string]$Actual,
        [Parameter(Mandatory = $true)][string]$Message
    )

    $findings = [System.Collections.ArrayList]::new()
    foreach ($finding in @($Report.findings)) {
        [void]$findings.Add($finding)
    }
    [void]$findings.Add((New-Finding -FindingId $FindingId -Category $Category -Severity "fail" -SubjectPath $SubjectPath -SubjectRefId $SubjectRefId -Expected $Expected -Actual $Actual -Message $Message -Order ($findings.Count + 1)))
    $Report.findings = @($findings)
    $Report.finding_summary.fail_count = [int]$Report.finding_summary.fail_count + 1
    $Report.aggregate_verdict = "failed"
}

function New-R16ArtifactAuditMapCheckFixtureFiles {
    [CmdletBinding()]
    param(
        [string]$FixtureRoot = "tests/fixtures/r16_artifact_audit_map_check",
        [string]$RepositoryRoot,
        [string]$ContractPath = "contracts/artifacts/r16_artifact_audit_map_check_report.contract.json"
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedFixtureRoot = Resolve-RepoRelativePathValue -Path $FixtureRoot -RepositoryRoot $resolvedRoot
    New-Item -ItemType Directory -Path $resolvedFixtureRoot -Force | Out-Null

    $valid = New-R16ArtifactAuditMapCheckReportObject -ContractPath $ContractPath -RepositoryRoot $resolvedRoot
    Write-StableJsonFile -Object $valid -Path (Join-Path $resolvedFixtureRoot "valid_check_report.json")

    $fixtureSpecs = [ordered]@{
        "invalid_missing_artifact_map_ref.json" = {
            param($r)
            $r.artifact_map_ref.loaded_and_validated = $false
        }
        "invalid_missing_audit_map_ref.json" = {
            param($r)
            $r.audit_map_ref.loaded_and_validated = $false
        }
        "invalid_missing_evidence_path.json" = {
            param($r)
            $r.exact_ref_summary.missing_required_paths = 1
            $r.finding_summary.missing_required_paths = 1
            Add-FailFindingToFixture -Report $r -FindingId "missing_required_path_rejected" -Category "required_path_presence" -SubjectPath "state/missing/evidence.json" -SubjectRefId "missing_evidence" -Expected "path exists" -Actual "missing" -Message "missing_required_paths must be 0."
        }
        "invalid_wildcard_path.json" = {
            param($r)
            $r.exact_ref_summary.wildcard_paths = 1
            $r.finding_summary.wildcard_paths = 1
            Add-FailFindingToFixture -Report $r -FindingId "wildcard_path_rejected" -Category "wildcard_path_policy" -SubjectPath "tools/*.ps1" -SubjectRefId "wildcard" -Expected "no wildcard paths" -Actual "tools/*.ps1" -Message "wildcard_paths must be 0."
        }
        "invalid_broad_repo_root_path.json" = {
            param($r)
            $r.exact_ref_summary.broad_repo_root_paths = 1
            $r.finding_summary.broad_repo_root_paths = 1
            Add-FailFindingToFixture -Report $r -FindingId "broad_repo_root_path_rejected" -Category "broad_repo_root_policy" -SubjectPath "." -SubjectRefId "repo_root" -Expected "exact file path" -Actual "." -Message "broad_repo_root_paths must be 0."
        }
        "invalid_directory_only_proof_claim.json" = {
            param($r)
            $r.exact_ref_summary.directory_only_proof_claims = 1
            $r.finding_summary.directory_only_proof_claims = 1
            Add-FailFindingToFixture -Report $r -FindingId "directory_only_proof_claim_rejected" -Category "directory_only_proof_policy" -SubjectPath "state/proof_reviews/" -SubjectRefId "directory_only" -Expected "exact file path" -Actual "directory" -Message "directory_only_proof_claims must be 0."
        }
        "invalid_stale_generated_from_without_caveat.json" = {
            param($r)
            $r.accepted_caveats = @($r.accepted_caveats | Where-Object { $_.caveat_id -ne "r15_evidence_index_stale_generated_from" })
        }
        "invalid_report_as_machine_proof.json" = {
            param($r)
            $r.exact_ref_summary.report_as_machine_proof_errors = 1
            $r.finding_summary.report_as_machine_proof_errors = 1
            Add-FailFindingToFixture -Report $r -FindingId "report_as_machine_proof_rejected" -Category "report_proof_treatment_policy" -SubjectPath "governance/reports/AIOffice_V2_R15_External_Audit_and_R16_Planning_Report_v2.md" -SubjectRefId "operator_report" -Expected "context only" -Actual "machine proof" -Message "report_as_machine_proof_errors must be 0."
        }
        "invalid_runtime_memory_claim.json" = {
            param($r)
            $r.check_mode.runtime_memory_implemented = $true
        }
        "invalid_context_planner_claim.json" = {
            param($r)
            $r.check_mode.context_load_planner_implemented = $true
        }
        "invalid_role_run_envelope_claim.json" = {
            param($r)
            $r.check_mode.role_run_envelope_implemented = $true
        }
        "invalid_handoff_packet_claim.json" = {
            param($r)
            $r.check_mode.handoff_packet_implemented = $true
        }
        "invalid_workflow_drill_claim.json" = {
            param($r)
            $r.check_mode.workflow_drill_run = $true
        }
        "invalid_r16_014_claim.json" = {
            param($r)
            $r.current_posture.r16_014_or_later_implementation_claimed = $true
        }
        "invalid_r13_boundary_change.json" = {
            param($r)
            $r.preserved_boundaries.r13.closed = $true
        }
        "invalid_r14_caveat_removed.json" = {
            param($r)
            $r.preserved_boundaries.r14.caveats_removed = $true
        }
        "invalid_r15_caveat_removed.json" = {
            param($r)
            $r.preserved_boundaries.r15.caveats_removed = $true
        }
    }

    foreach ($name in $fixtureSpecs.Keys) {
        $fixture = Copy-JsonObject -Value $valid
        & $fixtureSpecs[$name] $fixture
        Write-StableJsonFile -Object $fixture -Path (Join-Path $resolvedFixtureRoot $name)
    }

    return [pscustomobject]@{
        FixtureRoot = $FixtureRoot
        ValidFixture = (Join-Path $FixtureRoot "valid_check_report.json")
        InvalidFixtureCount = $fixtureSpecs.Count
    }
}

Export-ModuleMember -Function New-R16ArtifactAuditMapCheckReportObject, New-R16ArtifactAuditMapCheckReport, Test-R16ArtifactAuditMapCheckReport, Test-R16ArtifactAuditMapCheckReportObject, Test-R16ArtifactAuditMapCheckReportContract, Test-R16ArtifactAuditMapCheckReportContractObject, New-R16ArtifactAuditMapCheckFixtureFiles, ConvertTo-StableJson
