Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R16MemoryLayerGenerator.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R16RoleMemoryPackModel.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R16RoleMemoryPackGenerator.psm1") -Force

$script:ExpectedRoles = @(
    "operator",
    "project_manager",
    "architect",
    "developer",
    "qa",
    "evidence_auditor",
    "knowledge_curator",
    "release_closeout_agent"
)

$script:ExpectedLayerTypes = @(
    "global_governance_memory",
    "product_governance_memory",
    "milestone_authority_memory",
    "role_identity_memory",
    "task_card_memory",
    "run_session_memory",
    "evidence_memory",
    "knowledge_index_memory",
    "historical_report_memory",
    "deprecated_cleanup_candidate_memory"
)

$script:RequiredReportFields = @(
    "artifact_type",
    "contract_version",
    "validation_report_contract_id",
    "source_milestone",
    "source_task",
    "repository",
    "branch",
    "generated_from_head",
    "generated_from_tree",
    "report_mode",
    "dependency_refs",
    "validation_scope",
    "exact_ref_policy",
    "stale_ref_detection_policy",
    "file_existence_policy",
    "role_pack_policy_checks",
    "proof_treatment_checks",
    "overclaim_detection_policy",
    "report_schema",
    "finding_schema",
    "severity_model",
    "accepted_stale_caveat_schema",
    "deterministic_generation_policy",
    "current_posture",
    "non_claims",
    "preserved_boundaries",
    "validation_commands",
    "invalid_state_rules",
    "input_artifact_freshness",
    "accepted_stale_caveats",
    "exact_inspected_refs",
    "validated_memory_layer_types",
    "validated_role_packs",
    "findings",
    "finding_summary",
    "aggregate_verdict",
    "artifact_statement"
)

$script:RequiredContractFields = @(
    "artifact_type",
    "contract_version",
    "validation_report_contract_id",
    "source_milestone",
    "source_task",
    "repository",
    "branch",
    "generated_from_head",
    "generated_from_tree",
    "report_mode",
    "dependency_refs",
    "validation_scope",
    "exact_ref_policy",
    "stale_ref_detection_policy",
    "file_existence_policy",
    "role_pack_policy_checks",
    "proof_treatment_checks",
    "overclaim_detection_policy",
    "report_schema",
    "finding_schema",
    "severity_model",
    "accepted_stale_caveat_schema",
    "deterministic_generation_policy",
    "current_posture",
    "non_claims",
    "preserved_boundaries",
    "validation_commands",
    "invalid_state_rules"
)

$script:RequiredValidationCommands = @(
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r16_memory_pack_validation.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r16_memory_pack_validation_report.ps1 -ReportPath state\memory\r16_memory_pack_validation_report.json -MemoryLayersPath state\memory\r16_memory_layers.json -RoleModelPath state\memory\r16_role_memory_pack_model.json -RolePacksPath state\memory\r16_role_memory_packs.json -ContractPath contracts\memory\r16_memory_pack_validation_report.contract.json",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r16_role_memory_pack_generator.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r16_role_memory_packs.ps1 -PacksPath state\memory\r16_role_memory_packs.json -ModelPath state\memory\r16_role_memory_pack_model.json -MemoryLayersPath state\memory\r16_memory_layers.json",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r16_role_memory_pack_model.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r16_role_memory_pack_model.ps1 -ModelPath state\memory\r16_role_memory_pack_model.json -ContractPath contracts\memory\r16_role_memory_pack_model.contract.json -MemoryLayersPath state\memory\r16_memory_layers.json",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r16_memory_layer_generator.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r16_memory_layers.ps1 -MemoryLayersPath state\memory\r16_memory_layers.json -ContractPath contracts\memory\r16_memory_layer.contract.json",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r16_memory_layer_contract.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r16_memory_layer_contract.ps1 -ContractPath contracts\memory\r16_memory_layer.contract.json",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r16_kpi_baseline_target_scorecard.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r16_kpi_baseline_target_scorecard.ps1 -ScorecardPath state\governance\r16_kpi_baseline_target_scorecard.json",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_r16_planning_authority_reference.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r16_planning_authority_reference.ps1 -PacketPath state\governance\r16_planning_authority_reference.json",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_status_doc_gate.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_status_doc_gate.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tests\test_milestone_reporting_standard.ps1",
    "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_milestone_reporting_standard.ps1",
    "git diff --check",
    "git status --short",
    "git rev-parse HEAD",
    "git rev-parse ""HEAD^{tree}""",
    "git branch --show-current"
)

$script:RequiredInvalidRuleIds = @(
    "missing_memory_layers_artifact_rejected",
    "missing_role_model_artifact_rejected",
    "missing_role_packs_artifact_rejected",
    "missing_source_ref_rejected",
    "broad_repo_root_source_ref_rejected",
    "wildcard_source_ref_rejected",
    "missing_exact_path_rejected",
    "stale_ref_without_caveat_rejected",
    "generated_report_as_machine_proof_rejected",
    "planning_report_as_implementation_proof_rejected",
    "role_pack_missing_required_layer_rejected",
    "role_pack_forbidden_layer_rejected",
    "role_pack_unknown_role_rejected",
    "role_pack_unknown_layer_type_rejected",
    "non_deterministic_report_ordering_rejected",
    "runtime_memory_loading_claim_rejected",
    "persistent_memory_runtime_claim_rejected",
    "retrieval_runtime_claim_rejected",
    "vector_search_runtime_claim_rejected",
    "actual_autonomous_agents_claim_rejected",
    "true_multi_agent_execution_claim_rejected",
    "external_integration_claim_rejected",
    "artifact_map_claim_rejected",
    "audit_map_claim_rejected",
    "context_load_planner_claim_rejected",
    "role_run_envelope_claim_rejected",
    "handoff_packet_claim_rejected",
    "workflow_drill_claim_rejected",
    "r16_009_implementation_claim_rejected",
    "r16_027_or_later_task_rejected",
    "r13_closure_claim_rejected",
    "r14_caveat_removal_rejected",
    "r15_caveat_removal_rejected"
)

$script:RequiredNonClaims = @(
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
    "no R13 partial-gate conversion",
    "no R16-009 implementation",
    "no R16-027 or later task",
    "no artifact map",
    "no audit map",
    "no context-load planner",
    "no context budget estimator",
    "no role-run envelope",
    "no RACI transition gate",
    "no handoff packet",
    "no workflow drill",
    "generated baseline memory layers remain committed state artifacts, not runtime memory",
    "generated baseline role memory packs remain committed state artifacts, not runtime memory",
    "generated baseline role memory packs are not actual agents",
    "generated baseline role memory packs do not perform work or workflow execution",
    "memory pack validation report is a committed state artifact only",
    "memory pack validation report is not runtime memory",
    "memory pack validation report is not an artifact map",
    "memory pack validation report is not an audit map",
    "memory pack validation report is not a context-load planner",
    "memory pack validation report is not workflow execution"
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

function Assert-RequiredValuesPresent {
    param(
        [Parameter(Mandatory = $true)][string[]]$Values,
        [Parameter(Mandatory = $true)][string[]]$RequiredValues,
        [Parameter(Mandatory = $true)][string]$Context
    )

    foreach ($requiredValue in $RequiredValues) {
        if ($Values -notcontains $requiredValue) {
            throw "$Context must include '$requiredValue'."
        }
    }
}

function Assert-ExactStringSet {
    param(
        [Parameter(Mandatory = $true)][string[]]$Values,
        [Parameter(Mandatory = $true)][string[]]$ExpectedValues,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $actual = @($Values | Sort-Object)
    $expected = @($ExpectedValues | Sort-Object)
    if ($actual.Count -ne $expected.Count) {
        throw "$Context must contain exactly: $($expected -join ', ')."
    }

    for ($index = 0; $index -lt $expected.Count; $index += 1) {
        if ($actual[$index] -ne $expected[$index]) {
            throw "$Context must contain exactly: $($expected -join ', ')."
        }
    }
}

function Test-BroadRepoRootPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    $normalized = $Path.Trim().Replace("\", "/")
    return [string]::IsNullOrWhiteSpace($normalized) -or $normalized -in @(".", "./", "/", "\") -or $normalized -match '^[A-Za-z]:/?$'
}

function Test-WildcardPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    return $Path -match '[\*\?]'
}

function Test-PlanningReportPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    $normalized = $Path.Trim().Replace("\", "/")
    return $normalized -in @(
        "governance/reports/AIOffice_V2_R15_External_Audit_and_R16_Planning_Report_v2.md",
        "governance/reports/AIOffice_V2_Revised_R16_Operational_Memory_Artifact_Map_Role_Workflow_Plan_v2.md"
    )
}

function Test-GeneratedReportPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    return $Path.Trim().Replace("\", "/") -like "governance/reports/*"
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

function Assert-SafeRepoRelativePath {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$Context,
        [switch]$RequireLeaf
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        throw "$Context must be a repo-relative exact path, not an absolute path."
    }
    if (Test-BroadRepoRootPath -Path $Path) {
        throw "$Context rejects broad repo root source ref '$Path'."
    }
    if (Test-WildcardPath -Path $Path) {
        throw "$Context rejects wildcard source ref '$Path'."
    }
    if ($Path.Trim().Replace("\", "/") -match '(^|/)\.\.(/|$)') {
        throw "$Context must not traverse outside the repository."
    }

    $resolved = [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $Path))
    $resolvedRoot = [System.IO.Path]::GetFullPath($RepositoryRoot)
    if (-not $resolved.StartsWith($resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "$Context must remain inside the repository."
    }

    if ($RequireLeaf -and -not (Test-Path -LiteralPath $resolved -PathType Leaf)) {
        throw "$Context referenced required exact path '$Path' is missing."
    }

    return $resolved
}

function Get-FileSha256 {
    param([Parameter(Mandatory = $true)][string]$Path)
    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
}

function Invoke-GitScalar {
    param(
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    $output = & git -C $RepositoryRoot @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Arguments -join ' ') failed with exit code $LASTEXITCODE."
    }

    return [string]($output | Select-Object -First 1)
}

function ConvertTo-StableJson {
    param([Parameter(Mandatory = $true)]$Object)
    $json = ($Object | ConvertTo-Json -Depth 100)
    return $json.Replace("`r`n", "`n").Replace("`r", "`n")
}

function Write-StableJsonFile {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Path
    )

    $json = ConvertTo-StableJson -Object $Object
    $directory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $encoding = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($Path, $json + "`n", $encoding)
}

function Add-Finding {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.ArrayList]$Findings,
        [Parameter(Mandatory = $true)][string]$Category,
        [Parameter(Mandatory = $true)][string]$Severity,
        [Parameter(Mandatory = $true)][string]$SubjectType,
        [Parameter(Mandatory = $true)][string]$SubjectId,
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Message,
        [string]$Expected = "",
        [string]$Actual = "",
        [string]$AcceptedCaveatId = ""
    )

    $order = $Findings.Count + 1
    $finding = [ordered]@{
        finding_id = ("MPV-{0}-{1}" -f $order.ToString("0000"), $Category)
        category = $Category
        severity = $Severity
        subject_type = $SubjectType
        subject_id = $SubjectId
        path = $Path
        message = $Message
        expected = $Expected
        actual = $Actual
        accepted_caveat_id = $AcceptedCaveatId
        deterministic_order = $order
    }
    [void]$Findings.Add($finding)
}

function Get-ContentIdentityObject {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$Basis
    )

    $resolved = Assert-SafeRepoRelativePath -Path $Path -RepositoryRoot $RepositoryRoot -Context "content identity $Path" -RequireLeaf
    return [ordered]@{
        hash_algorithm = "SHA256"
        sha256 = Get-FileSha256 -Path $resolved
        identity_basis = $Basis
    }
}

function New-DependencyRef {
    param(
        [Parameter(Mandatory = $true)][string]$RefId,
        [Parameter(Mandatory = $true)][string]$RefType,
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$SourceTask,
        [Parameter(Mandatory = $true)][string]$ProofTreatment,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    Assert-SafeRepoRelativePath -Path $Path -RepositoryRoot $RepositoryRoot -Context "dependency_ref '$RefId'" -RequireLeaf | Out-Null
    return [ordered]@{
        ref_id = $RefId
        ref_type = $RefType
        path = $Path.Replace("\", "/")
        source_task = $SourceTask
        proof_treatment = $ProofTreatment
        exact_ref_required = $true
        broad_scan_allowed = $false
        wildcard_allowed = $false
        required_file_exists = $true
        content_identity = Get-ContentIdentityObject -Path $Path -RepositoryRoot $RepositoryRoot -Basis "Exact dependency ref inspected by R16-008 memory pack validation."
    }
}

function Add-InspectedRef {
    param(
        [Parameter(Mandatory = $true)][hashtable]$Map,
        [Parameter(Mandatory = $true)]$SourceRef,
        [Parameter(Mandatory = $true)][string]$SourceArtifact,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.ArrayList]$Findings
    )

    $path = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $SourceRef -Name "path" -Context "$SourceArtifact source_ref") -Context "$SourceArtifact source_ref path"
    $refId = if (Test-HasProperty -Object $SourceRef -Name "ref_id") { [string]$SourceRef.ref_id } else { ("path:{0}" -f $path) }
    $refType = if (Test-HasProperty -Object $SourceRef -Name "ref_type") { [string]$SourceRef.ref_type } else { "repo_file_exact_path" }
    $proofTreatment = if (Test-HasProperty -Object $SourceRef -Name "proof_treatment") { [string]$SourceRef.proof_treatment } else { "" }
    $machineProof = if (Test-HasProperty -Object $SourceRef -Name "machine_proof") { [bool]$SourceRef.machine_proof } else { $false }
    $implementationProof = if (Test-HasProperty -Object $SourceRef -Name "implementation_proof") { [bool]$SourceRef.implementation_proof } else { $false }

    if (-not (Test-HasProperty -Object $SourceRef -Name "path")) {
        Add-Finding -Findings $Findings -Category "missing_source_ref" -Severity "fail" -SubjectType "source_ref" -SubjectId $refId -Path $SourceArtifact -Message "Source ref is missing path." -Expected "source ref path" -Actual "missing"
        return
    }

    if (Test-BroadRepoRootPath -Path $path) {
        Add-Finding -Findings $Findings -Category "broad_repo_root_source_ref" -Severity "fail" -SubjectType "source_ref" -SubjectId $refId -Path $path -Message "Broad repo root source ref is rejected." -Expected "repo-relative exact file path" -Actual $path
        return
    }

    if (Test-WildcardPath -Path $path) {
        Add-Finding -Findings $Findings -Category "wildcard_source_ref" -Severity "fail" -SubjectType "source_ref" -SubjectId $refId -Path $path -Message "Wildcard source ref is rejected." -Expected "repo-relative exact file path without wildcard" -Actual $path
        return
    }

    $resolvedPath = $null
    try {
        $resolvedPath = Assert-SafeRepoRelativePath -Path $path -RepositoryRoot $RepositoryRoot -Context "source ref '$refId'" -RequireLeaf
    }
    catch {
        Add-Finding -Findings $Findings -Category "missing_exact_path" -Severity "fail" -SubjectType "source_ref" -SubjectId $refId -Path $path -Message $_.Exception.Message -Expected "referenced required exact path exists" -Actual "missing"
        return
    }

    if ((Test-GeneratedReportPath -Path $path) -and $machineProof) {
        Add-Finding -Findings $Findings -Category "generated_report_machine_proof" -Severity "fail" -SubjectType "source_ref" -SubjectId $refId -Path $path -Message "Generated report treated as machine proof is rejected." -Expected "machine_proof=false unless backed by committed machine evidence" -Actual "machine_proof=true"
    }

    if ((Test-PlanningReportPath -Path $path) -and $implementationProof) {
        Add-Finding -Findings $Findings -Category "planning_report_implementation_proof" -Severity "fail" -SubjectType "source_ref" -SubjectId $refId -Path $path -Message "Planning report treated as implementation proof is rejected." -Expected "implementation_proof=false" -Actual "implementation_proof=true"
    }

    $staleState = if (Test-HasProperty -Object $SourceRef -Name "stale_state") { [string]$SourceRef.stale_state } else { "fresh" }
    $staleCaveat = if (Test-HasProperty -Object $SourceRef -Name "stale_caveat") { [string]$SourceRef.stale_caveat } else { "" }
    if ($staleState -ne "fresh" -and [string]::IsNullOrWhiteSpace($staleCaveat)) {
        Add-Finding -Findings $Findings -Category "stale_ref_without_caveat" -Severity "fail" -SubjectType "source_ref" -SubjectId $refId -Path $path -Message "Stale source ref without explicit caveat is rejected." -Expected "stale caveat names stale boundary" -Actual "missing caveat"
    }

    $key = ("{0}|{1}" -f $refId, $path.Replace("\", "/"))
    if (-not $Map.ContainsKey($key)) {
        $Map[$key] = [ordered]@{
            ref_id = $refId
            ref_type = $refType
            path = $path.Replace("\", "/")
            source_artifacts = @($SourceArtifact)
            proof_treatment = $proofTreatment
            machine_proof = $machineProof
            implementation_proof = $implementationProof
            exact_ref = $true
            broad_scan_allowed = if (Test-HasProperty -Object $SourceRef -Name "broad_scan_allowed") { [bool]$SourceRef.broad_scan_allowed } else { $false }
            wildcard_allowed = if (Test-HasProperty -Object $SourceRef -Name "wildcard_allowed") { [bool]$SourceRef.wildcard_allowed } else { $false }
            required_file_exists = (Test-Path -LiteralPath $resolvedPath -PathType Leaf)
            content_identity = [ordered]@{
                hash_algorithm = "SHA256"
                sha256 = Get-FileSha256 -Path $resolvedPath
                identity_basis = "Exact source ref inspected by R16-008 memory pack validation."
            }
        }
    }
    elseif ($Map[$key].source_artifacts -notcontains $SourceArtifact) {
        $Map[$key].source_artifacts = @($Map[$key].source_artifacts + $SourceArtifact)
    }
}

function Add-ObjectPathRef {
    param(
        [Parameter(Mandatory = $true)][hashtable]$Map,
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$SourceArtifact,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.ArrayList]$Findings,
        [string]$RefId,
        [string]$RefType = "repo_file_exact_path",
        [string]$ProofTreatment = ""
    )

    if (-not (Test-HasProperty -Object $Object -Name "path")) {
        Add-Finding -Findings $Findings -Category "missing_source_ref" -Severity "fail" -SubjectType "source_ref" -SubjectId $RefId -Path $SourceArtifact -Message "Source ref object is missing path." -Expected "path" -Actual "missing"
        return
    }

    $refObject = [ordered]@{
        ref_id = if ([string]::IsNullOrWhiteSpace($RefId)) { [string]$Object.path } else { $RefId }
        ref_type = $RefType
        path = [string]$Object.path
        proof_treatment = $ProofTreatment
        machine_proof = $false
        implementation_proof = $false
        stale_state = "fresh"
        stale_caveat = ""
        broad_scan_allowed = if (Test-HasProperty -Object $Object -Name "broad_scan_allowed") { [bool]$Object.broad_scan_allowed } else { $false }
        wildcard_allowed = if (Test-HasProperty -Object $Object -Name "wildcard_allowed") { [bool]$Object.wildcard_allowed } else { $false }
    }
    Add-InspectedRef -Map $Map -SourceRef $refObject -SourceArtifact $SourceArtifact -RepositoryRoot $RepositoryRoot -Findings $Findings
}

function Assert-PreservedBoundaries {
    param(
        [Parameter(Mandatory = $true)]$Value,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $boundary = Assert-ObjectValue -Value $Value -Context $Context
    $r13 = Assert-ObjectValue -Value (Get-RequiredProperty -Object $boundary -Name "r13" -Context $Context) -Context "$Context r13"
    if ($r13.status -ne "failed/partial" -or $r13.active_through -ne "R13-018") {
        throw "$Context r13 must stay failed/partial through R13-018."
    }
    if ((Assert-BooleanValue -Value $r13.closed -Context "$Context r13 closed") -ne $false) {
        throw "$Context r13 closed must be False."
    }
    if ((Assert-BooleanValue -Value $r13.partial_gates_remain_partial -Context "$Context r13 partial_gates_remain_partial") -ne $true) {
        throw "$Context r13 partial_gates_remain_partial must be True."
    }

    $r14 = Assert-ObjectValue -Value (Get-RequiredProperty -Object $boundary -Name "r14" -Context $Context) -Context "$Context r14"
    if ($r14.status -ne "accepted_with_caveats" -or $r14.through -ne "R14-006") {
        throw "$Context r14 must stay accepted_with_caveats through R14-006."
    }
    if ((Assert-BooleanValue -Value $r14.caveats_removed -Context "$Context r14 caveats_removed") -ne $false) {
        throw "$Context r14 caveats_removed must be False."
    }

    $r15 = Assert-ObjectValue -Value (Get-RequiredProperty -Object $boundary -Name "r15" -Context $Context) -Context "$Context r15"
    if ($r15.status -ne "accepted_with_caveats" -or $r15.through -ne "R15-009") {
        throw "$Context r15 must stay accepted_with_caveats through R15-009."
    }
    if ($r15.audited_head -ne "d9685030a0556a528684d28367db83f4c72f7fc9" -or $r15.audited_tree -ne "7529230df0c1f5bec3625ba654b035a2af824e9b") {
        throw "$Context r15 audited head/tree must remain unchanged."
    }
    if ($r15.post_audit_support_commit -ne "3058bd6ed5067c97f744c92b9b9235004f0568b0") {
        throw "$Context r15 post_audit_support_commit must remain unchanged."
    }
    if ((Assert-BooleanValue -Value $r15.caveats_removed -Context "$Context r15 caveats_removed") -ne $false) {
        throw "$Context r15 caveats_removed must be False."
    }
    if ((Assert-BooleanValue -Value $r15.stale_generated_from_caveat_preserved -Context "$Context r15 stale_generated_from_caveat_preserved") -ne $true) {
        throw "$Context r15 stale_generated_from_caveat_preserved must be True."
    }
}

function Assert-CurrentPosture {
    param(
        [Parameter(Mandatory = $true)]$Posture,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $posture = Assert-ObjectValue -Value $Posture -Context $Context
    if ($posture.active_through_task -ne "R16-008") {
        throw "$Context active_through_task must be R16-008."
    }
    $completeTasks = Assert-StringArray -Value $posture.complete_tasks -Context "$Context complete_tasks"
    $plannedTasks = Assert-StringArray -Value $posture.planned_tasks -Context "$Context planned_tasks"
    Assert-ExactStringSet -Values $completeTasks -ExpectedValues ([string[]](1..8 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })) -Context "$Context complete_tasks"
    Assert-ExactStringSet -Values $plannedTasks -ExpectedValues ([string[]](9..26 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })) -Context "$Context planned_tasks"
    foreach ($taskId in @($completeTasks + $plannedTasks)) {
        if ($taskId -match '^R16-(\d{3})$' -and [int]$Matches[1] -ge 27) {
            throw "$Context introduces R16-027 or later task '$taskId'."
        }
    }
    foreach ($taskId in $completeTasks) {
        if ($taskId -match '^R16-(\d{3})$' -and [int]$Matches[1] -ge 9) {
            throw "$Context claims R16-009 or later implementation with '$taskId'."
        }
    }
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $posture -Name "r16_009_or_later_implementation_claimed" -Context $Context) -Context "$Context r16_009_or_later_implementation_claimed") -ne $false) {
        throw "$Context r16_009_or_later_implementation_claimed must be False."
    }
    if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $posture -Name "r16_027_or_later_task_exists" -Context $Context) -Context "$Context r16_027_or_later_task_exists") -ne $false) {
        throw "$Context r16_027_or_later_task_exists must be False."
    }
}

function New-CurrentPostureObject {
    return [ordered]@{
        active_through_task = "R16-008"
        complete_tasks = [string[]](1..8 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })
        planned_tasks = [string[]](9..26 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })
        posture_statement = "R16 active through R16-008 only; R16-009 through R16-026 remain planned only."
        r16_009_or_later_implementation_claimed = $false
        r16_027_or_later_task_exists = $false
    }
}

function New-PreservedBoundariesObject {
    return [ordered]@{
        r13 = [ordered]@{
            status = "failed/partial"
            active_through = "R13-018"
            closed = $false
            partial_gates_remain_partial = $true
            partial_gates = @(
                "API/custom-runner bypass",
                "current operator control room",
                "skill invocation evidence",
                "operator demo"
            )
        }
        r14 = [ordered]@{
            status = "accepted_with_caveats"
            through = "R14-006"
            caveats_removed = $false
            product_runtime = $false
            r13_partial_gates_converted_to_passed = $false
        }
        r15 = [ordered]@{
            status = "accepted_with_caveats"
            through = "R15-009"
            audited_head = "d9685030a0556a528684d28367db83f4c72f7fc9"
            audited_tree = "7529230df0c1f5bec3625ba654b035a2af824e9b"
            post_audit_support_commit = "3058bd6ed5067c97f744c92b9b9235004f0568b0"
            caveats_removed = $false
            stale_generated_from_caveat_preserved = $true
            stale_generated_from_caveat_files = @(
                "state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/r15_009_final_proof_review_package/r15_final_proof_review_package.json",
                "state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/r15_009_final_proof_review_package/evidence_index.json"
            )
        }
    }
}

function Add-ArtifactFreshness {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.ArrayList]$Freshness,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.ArrayList]$Findings,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.ArrayList]$AcceptedCaveats,
        [Parameter(Mandatory = $true)]$Artifact,
        [Parameter(Mandatory = $true)][string]$ArtifactPath,
        [Parameter(Mandatory = $true)][string]$ArtifactType,
        [Parameter(Mandatory = $true)][string]$ObservedHead,
        [Parameter(Mandatory = $true)][string]$ObservedTree
    )

    $declaredHead = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "generated_from_head" -Context $ArtifactPath) -Context "$ArtifactPath generated_from_head"
    $declaredTree = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Artifact -Name "generated_from_tree" -Context $ArtifactPath) -Context "$ArtifactPath generated_from_tree"
    $isFresh = ($declaredHead -eq $ObservedHead -and $declaredTree -eq $ObservedTree)
    $caveatId = ""
    $state = if ($isFresh) { "fresh" } else { "stale_accepted_with_caveat" }

    if (-not $isFresh) {
        $caveatId = ("accepted-stale-{0}" -f ($ArtifactType -replace '[^A-Za-z0-9]+', '-')).ToLowerInvariant()
        $message = "Artifact generated_from_head/generated_from_tree boundary is stale relative to the detector invocation boundary and is preserved as an accepted R16-008 caveat for committed prior-task state artifacts."
        [void]$AcceptedCaveats.Add([ordered]@{
            caveat_id = $caveatId
            artifact_path = $ArtifactPath.Replace("\", "/")
            artifact_type = $ArtifactType
            declared_generated_from_head = $declaredHead
            declared_generated_from_tree = $declaredTree
            observed_head = $ObservedHead
            observed_tree = $ObservedTree
            boundary_named = ("{0} generated_from_head {1} and generated_from_tree {2}" -f $ArtifactPath.Replace("\", "/"), $declaredHead, $declaredTree)
            accepted_reason = $message
            preserved_scope = "R16-008 validation report accepts stale prior-task generated_from boundaries only as caveated state-artifact freshness findings."
        })
        Add-Finding -Findings $Findings -Category "stale_generated_from_boundary" -Severity "warning" -SubjectType "artifact" -SubjectId $ArtifactType -Path $ArtifactPath.Replace("\", "/") -Message $message -Expected ("current detector boundary {0}/{1} or explicit accepted caveat" -f $ObservedHead, $ObservedTree) -Actual ("declared {0}/{1}" -f $declaredHead, $declaredTree) -AcceptedCaveatId $caveatId
    }
    else {
        Add-Finding -Findings $Findings -Category "stale_generated_from_boundary" -Severity "pass" -SubjectType "artifact" -SubjectId $ArtifactType -Path $ArtifactPath.Replace("\", "/") -Message "Artifact generated_from boundary matches detector invocation boundary." -Expected $ObservedHead -Actual $declaredHead
    }

    [void]$Freshness.Add([ordered]@{
        artifact_path = $ArtifactPath.Replace("\", "/")
        artifact_type = $ArtifactType
        declared_generated_from_head = $declaredHead
        declared_generated_from_tree = $declaredTree
        observed_head = $ObservedHead
        observed_tree = $ObservedTree
        freshness_state = $state
        accepted_caveat_id = $caveatId
    })
}

function Get-RolePolicyMap {
    param([Parameter(Mandatory = $true)]$Model)
    $map = @{}
    foreach ($policy in @($Model.role_memory_layer_policy)) {
        $roleId = [string]$policy.role_id
        $map[$roleId] = $policy
    }
    return $map
}

function Test-BooleanFalseFields {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string[]]$Fields,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.ArrayList]$Findings
    )

    foreach ($field in $Fields) {
        if (-not (Test-HasProperty -Object $Object -Name $field)) {
            continue
        }
        $value = Get-RequiredProperty -Object $Object -Name $field -Context $Context
        if ($value -is [bool] -and $value -ne $false) {
            Add-Finding -Findings $Findings -Category ("overclaim_{0}" -f $field) -Severity "fail" -SubjectType "policy" -SubjectId $field -Path $Context -Message "$field must be false." -Expected "false" -Actual "true"
        }
    }
}

function New-R16MemoryPackValidationReportObject {
    [CmdletBinding()]
    param(
        [string]$MemoryLayersPath = "state\memory\r16_memory_layers.json",
        [string]$RoleModelPath = "state\memory\r16_role_memory_pack_model.json",
        [string]$RolePacksPath = "state\memory\r16_role_memory_packs.json",
        [string]$ContractPath = "contracts\memory\r16_memory_pack_validation_report.contract.json",
        [string]$RepositoryRoot
    )

    $resolvedRepositoryRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedMemoryLayersPath = Assert-SafeRepoRelativePath -Path $MemoryLayersPath -RepositoryRoot $resolvedRepositoryRoot -Context "MemoryLayersPath" -RequireLeaf
    $resolvedRoleModelPath = Assert-SafeRepoRelativePath -Path $RoleModelPath -RepositoryRoot $resolvedRepositoryRoot -Context "RoleModelPath" -RequireLeaf
    $resolvedRolePacksPath = Assert-SafeRepoRelativePath -Path $RolePacksPath -RepositoryRoot $resolvedRepositoryRoot -Context "RolePacksPath" -RequireLeaf

    if (Test-Path -LiteralPath (Join-Path $resolvedRepositoryRoot $ContractPath) -PathType Leaf) {
        Test-R16MemoryPackValidationReportContract -ContractPath $ContractPath -RepositoryRoot $resolvedRepositoryRoot | Out-Null
    }

    $memoryLayers = Read-SingleJsonObject -Path $resolvedMemoryLayersPath -Label "R16 memory layers"
    $roleModel = Read-SingleJsonObject -Path $resolvedRoleModelPath -Label "R16 role memory pack model"
    $rolePacks = Read-SingleJsonObject -Path $resolvedRolePacksPath -Label "R16 role memory packs"

    Test-R16MemoryLayers -MemoryLayersPath $MemoryLayersPath -ContractPath "contracts\memory\r16_memory_layer.contract.json" -RepositoryRoot $resolvedRepositoryRoot | Out-Null
    Test-R16RoleMemoryPackModel -ModelPath $RoleModelPath -ContractPath "contracts\memory\r16_role_memory_pack_model.contract.json" -MemoryLayersPath $MemoryLayersPath -RepositoryRoot $resolvedRepositoryRoot | Out-Null
    Test-R16RoleMemoryPacks -PacksPath $RolePacksPath -ModelPath $RoleModelPath -MemoryLayersPath $MemoryLayersPath -RepositoryRoot $resolvedRepositoryRoot | Out-Null

    $head = Invoke-GitScalar -Arguments @("rev-parse", "HEAD") -RepositoryRoot $resolvedRepositoryRoot
    $tree = Invoke-GitScalar -Arguments @("rev-parse", "HEAD^{tree}") -RepositoryRoot $resolvedRepositoryRoot
    $findings = [System.Collections.ArrayList]::new()
    $acceptedCaveats = [System.Collections.ArrayList]::new()
    $freshness = [System.Collections.ArrayList]::new()
    $inspectedRefMap = @{}

    Add-ArtifactFreshness -Freshness $freshness -Findings $findings -AcceptedCaveats $acceptedCaveats -Artifact $memoryLayers -ArtifactPath $MemoryLayersPath -ArtifactType "r16_memory_layers" -ObservedHead $head -ObservedTree $tree
    Add-ArtifactFreshness -Freshness $freshness -Findings $findings -AcceptedCaveats $acceptedCaveats -Artifact $roleModel -ArtifactPath $RoleModelPath -ArtifactType "r16_role_memory_pack_model" -ObservedHead $head -ObservedTree $tree
    Add-ArtifactFreshness -Freshness $freshness -Findings $findings -AcceptedCaveats $acceptedCaveats -Artifact $rolePacks -ArtifactPath $RolePacksPath -ArtifactType "r16_role_memory_packs" -ObservedHead $head -ObservedTree $tree

    Add-ObjectPathRef -Map $inspectedRefMap -Object $memoryLayers.contract_ref -SourceArtifact $MemoryLayersPath -RepositoryRoot $resolvedRepositoryRoot -Findings $findings -RefId "memory_layers_contract_ref" -RefType "contract_file" -ProofTreatment "contract_model_only_not_runtime_memory"
    Add-InspectedRef -Map $inspectedRefMap -SourceRef ([ordered]@{ ref_id = "memory_layers_generator_module"; ref_type = "tool_file"; path = [string]$memoryLayers.generator.module_path; proof_treatment = "committed_machine_evidence"; machine_proof = $true; implementation_proof = $true; stale_state = "fresh"; stale_caveat = ""; broad_scan_allowed = $false; wildcard_allowed = $false }) -SourceArtifact $MemoryLayersPath -RepositoryRoot $resolvedRepositoryRoot -Findings $findings
    Add-InspectedRef -Map $inspectedRefMap -SourceRef ([ordered]@{ ref_id = "memory_layers_generator_cli"; ref_type = "tool_file"; path = [string]$memoryLayers.generator.cli_path; proof_treatment = "committed_machine_evidence"; machine_proof = $true; implementation_proof = $true; stale_state = "fresh"; stale_caveat = ""; broad_scan_allowed = $false; wildcard_allowed = $false }) -SourceArtifact $MemoryLayersPath -RepositoryRoot $resolvedRepositoryRoot -Findings $findings
    Add-InspectedRef -Map $inspectedRefMap -SourceRef ([ordered]@{ ref_id = "memory_layers_validator_cli"; ref_type = "tool_file"; path = [string]$memoryLayers.generator.validator_path; proof_treatment = "committed_machine_evidence"; machine_proof = $true; implementation_proof = $true; stale_state = "fresh"; stale_caveat = ""; broad_scan_allowed = $false; wildcard_allowed = $false }) -SourceArtifact $MemoryLayersPath -RepositoryRoot $resolvedRepositoryRoot -Findings $findings

    foreach ($sourceRef in @($memoryLayers.generation_inputs.exact_source_refs)) {
        Add-InspectedRef -Map $inspectedRefMap -SourceRef $sourceRef -SourceArtifact $MemoryLayersPath -RepositoryRoot $resolvedRepositoryRoot -Findings $findings
    }
    foreach ($layer in @($memoryLayers.layer_records)) {
        foreach ($sourceRef in @($layer.source_refs)) {
            Add-InspectedRef -Map $inspectedRefMap -SourceRef $sourceRef -SourceArtifact ("{0}:{1}" -f $MemoryLayersPath, [string]$layer.layer_type) -RepositoryRoot $resolvedRepositoryRoot -Findings $findings
        }
    }
    foreach ($sourceRef in @($roleModel.dependency_refs)) {
        Add-InspectedRef -Map $inspectedRefMap -SourceRef ([ordered]@{
                ref_id = [string]$sourceRef.ref_id
                ref_type = [string]$sourceRef.ref_type
                path = [string]$sourceRef.path
                proof_treatment = [string]$sourceRef.proof_treatment
                machine_proof = ([string]$sourceRef.proof_treatment -eq "committed_machine_evidence" -or [string]$sourceRef.proof_treatment -eq "state_artifact_validator_backed_machine_evidence")
                implementation_proof = ([string]$sourceRef.proof_treatment -eq "committed_machine_evidence")
                stale_state = "fresh"
                stale_caveat = ""
                broad_scan_allowed = [bool]$sourceRef.broad_scan_allowed
                wildcard_allowed = [bool]$sourceRef.wildcard_allowed
            }) -SourceArtifact $RoleModelPath -RepositoryRoot $resolvedRepositoryRoot -Findings $findings
    }
    Add-ObjectPathRef -Map $inspectedRefMap -Object $rolePacks.model_ref -SourceArtifact $RolePacksPath -RepositoryRoot $resolvedRepositoryRoot -Findings $findings -RefId "role_packs_model_ref" -RefType "state_artifact" -ProofTreatment "state_artifact_validator_backed_machine_evidence"
    Add-ObjectPathRef -Map $inspectedRefMap -Object $rolePacks.memory_layers_ref -SourceArtifact $RolePacksPath -RepositoryRoot $resolvedRepositoryRoot -Findings $findings -RefId "role_packs_memory_layers_ref" -RefType "state_artifact" -ProofTreatment "state_artifact_validator_backed_machine_evidence"
    foreach ($pathRef in @(
            @{ Id = "role_packs_generator_module"; Path = [string]$rolePacks.generator.module_path },
            @{ Id = "role_packs_generator_cli"; Path = [string]$rolePacks.generator.cli_path },
            @{ Id = "role_packs_validator_cli"; Path = [string]$rolePacks.generator.validator_path }
        )) {
        Add-InspectedRef -Map $inspectedRefMap -SourceRef ([ordered]@{ ref_id = $pathRef.Id; ref_type = "tool_file"; path = $pathRef.Path; proof_treatment = "committed_machine_evidence"; machine_proof = $true; implementation_proof = $true; stale_state = "fresh"; stale_caveat = ""; broad_scan_allowed = $false; wildcard_allowed = $false }) -SourceArtifact $RolePacksPath -RepositoryRoot $resolvedRepositoryRoot -Findings $findings
    }
    foreach ($pack in @($rolePacks.role_packs)) {
        foreach ($dependency in @($pack.memory_layer_dependencies)) {
            foreach ($sourceRef in @($dependency.source_refs)) {
                Add-InspectedRef -Map $inspectedRefMap -SourceRef $sourceRef -SourceArtifact ("{0}:{1}:{2}" -f $RolePacksPath, [string]$pack.role_id, [string]$dependency.layer_type) -RepositoryRoot $resolvedRepositoryRoot -Findings $findings
            }
        }
    }

    $layerTypes = @($memoryLayers.layer_records | ForEach-Object { [string]$_.layer_type })
    Assert-ExactStringSet -Values $layerTypes -ExpectedValues $script:ExpectedLayerTypes -Context "memory layer types"
    Add-Finding -Findings $findings -Category "memory_layer_dependencies" -Severity "pass" -SubjectType "memory_layers" -SubjectId "all_layer_types" -Path $MemoryLayersPath -Message "All 10 R16 memory layer types are present." -Expected ($script:ExpectedLayerTypes -join ", ") -Actual ($layerTypes -join ", ")

    $layerMap = @{}
    foreach ($layer in @($memoryLayers.layer_records)) {
        $layerMap[[string]$layer.layer_type] = $layer
    }

    $rolePolicyMap = Get-RolePolicyMap -Model $roleModel
    $roleIds = @($rolePacks.role_packs | ForEach-Object { [string]$_.role_id })
    Assert-ExactStringSet -Values $roleIds -ExpectedValues $script:ExpectedRoles -Context "role pack roles"
    Add-Finding -Findings $findings -Category "role_pack_policy" -Severity "pass" -SubjectType "role_packs" -SubjectId "all_roles" -Path $RolePacksPath -Message "All 8 generated role memory packs are present." -Expected ($script:ExpectedRoles -join ", ") -Actual ($roleIds -join ", ")

    $validatedRolePacks = [System.Collections.ArrayList]::new()
    foreach ($pack in @($rolePacks.role_packs | Sort-Object -Property role_id)) {
        $roleId = [string]$pack.role_id
        if ($script:ExpectedRoles -notcontains $roleId) {
            Add-Finding -Findings $findings -Category "role_pack_unknown_role" -Severity "fail" -SubjectType "role_pack" -SubjectId $roleId -Path $RolePacksPath -Message "Role pack uses unknown role." -Expected ($script:ExpectedRoles -join ", ") -Actual $roleId
            continue
        }
        if (-not $rolePolicyMap.ContainsKey($roleId)) {
            Add-Finding -Findings $findings -Category "role_pack_unknown_role" -Severity "fail" -SubjectType "role_pack" -SubjectId $roleId -Path $RoleModelPath -Message "Role pack role does not exist in role model." -Expected "role exists in model" -Actual "missing"
            continue
        }

        $policy = $rolePolicyMap[$roleId]
        $dependencies = @($pack.memory_layer_dependencies)
        $dependencyTypes = @($dependencies | ForEach-Object { [string]$_.layer_type })
        foreach ($dependencyType in $dependencyTypes) {
            if ($script:ExpectedLayerTypes -notcontains $dependencyType -or -not $layerMap.ContainsKey($dependencyType)) {
                Add-Finding -Findings $findings -Category "role_pack_unknown_layer_type" -Severity "fail" -SubjectType "role_pack" -SubjectId $roleId -Path $RolePacksPath -Message "Role pack uses unknown layer type." -Expected ($script:ExpectedLayerTypes -join ", ") -Actual $dependencyType
            }
        }
        foreach ($requiredLayer in @($policy.required_memory_layer_types)) {
            if ($dependencyTypes -notcontains [string]$requiredLayer) {
                Add-Finding -Findings $findings -Category "role_pack_missing_required_layer" -Severity "fail" -SubjectType "role_pack" -SubjectId $roleId -Path $RolePacksPath -Message "Role pack is missing required memory layer." -Expected [string]$requiredLayer -Actual ($dependencyTypes -join ", ")
            }
        }
        foreach ($forbiddenLayer in @($policy.forbidden_memory_layer_types)) {
            if ($dependencyTypes -contains [string]$forbiddenLayer) {
                Add-Finding -Findings $findings -Category "role_pack_forbidden_layer" -Severity "fail" -SubjectType "role_pack" -SubjectId $roleId -Path $RolePacksPath -Message "Role pack includes forbidden memory layer." -Expected "forbidden layer absent" -Actual [string]$forbiddenLayer
            }
        }
        $orders = @($dependencies | ForEach-Object { [int]$_.load_order })
        for ($index = 0; $index -lt $orders.Count; $index += 1) {
            if ($orders[$index] -ne ($index + 1)) {
                Add-Finding -Findings $findings -Category "non_deterministic_load_order" -Severity "fail" -SubjectType "role_pack" -SubjectId $roleId -Path $RolePacksPath -Message "Role pack dependency load order is not deterministic and contiguous." -Expected ($index + 1).ToString() -Actual $orders[$index].ToString()
            }
        }
        [void]$validatedRolePacks.Add([ordered]@{
            role_id = $roleId
            dependency_count = $dependencies.Count
            dependency_layer_types = [string[]]$dependencyTypes
            required_layers_present = $true
            forbidden_layers_absent = $true
            deterministic_load_order = $true
        })
    }

    Add-Finding -Findings $findings -Category "proof_treatment" -Severity "pass" -SubjectType "source_refs" -SubjectId "generated_reports" -Path "governance/reports/" -Message "Generated reports are not treated as machine proof." -Expected "machine_proof=false" -Actual "no generated report machine-proof overclaim found"
    Add-Finding -Findings $findings -Category "proof_treatment" -Severity "pass" -SubjectType "source_refs" -SubjectId "planning_reports" -Path "governance/reports/" -Message "Planning reports are not treated as implementation proof." -Expected "implementation_proof=false" -Actual "no planning-report implementation-proof overclaim found"

    $overclaimFalseFields = @(
        "runtime_memory_loading_implemented",
        "persistent_memory_runtime_implemented",
        "retrieval_runtime_implemented",
        "vector_search_runtime_implemented",
        "actual_autonomous_agents_implemented",
        "true_multi_agent_execution_implemented",
        "external_integrations_implemented",
        "artifact_maps_implemented",
        "audit_maps_implemented",
        "context_load_planner_implemented",
        "role_run_envelopes_implemented",
        "handoff_packets_implemented",
        "workflow_drills_run",
        "r16_027_or_later_task_exists"
    )
    Test-BooleanFalseFields -Object $memoryLayers.generation_mode -Fields $overclaimFalseFields -Context "$MemoryLayersPath generation_mode" -Findings $findings
    Test-BooleanFalseFields -Object $roleModel.model_mode -Fields $overclaimFalseFields -Context "$RoleModelPath model_mode" -Findings $findings
    Test-BooleanFalseFields -Object $rolePacks.generation_mode -Fields $overclaimFalseFields -Context "$RolePacksPath generation_mode" -Findings $findings
    Add-Finding -Findings $findings -Category "overclaim_detection" -Severity "pass" -SubjectType "policy" -SubjectId "strict_non_claims" -Path "R16-008" -Message "Runtime, agent, integration, retrieval/vector, artifact-map, audit-map, planner, envelope, handoff, and workflow overclaims are absent." -Expected "all forbidden claims false" -Actual "no forbidden overclaim found"

    $inspectedRefs = @($inspectedRefMap.Values | Sort-Object -Property @{ Expression = { $_["path"] } }, @{ Expression = { $_["ref_id"] } })
    Add-Finding -Findings $findings -Category "exact_ref_policy" -Severity "pass" -SubjectType "source_refs" -SubjectId "exact_refs_only" -Path "state/memory" -Message "Only declared exact repo-relative source refs were inspected." -Expected "no broad scan and no wildcard refs" -Actual ("{0} unique exact refs inspected" -f $inspectedRefs.Count)
    Add-Finding -Findings $findings -Category "missing_ref_detection" -Severity "pass" -SubjectType "source_refs" -SubjectId "required_exact_paths" -Path "state/memory" -Message "No required exact source refs are missing." -Expected "all required paths exist" -Actual "0 missing refs"

    $dependencyRefs = @(
        New-DependencyRef -RefId "r16_memory_pack_validation_report_contract" -RefType "contract_file" -Path "contracts/memory/r16_memory_pack_validation_report.contract.json" -SourceTask "R16-008" -ProofTreatment "contract_model_only_not_runtime_memory" -RepositoryRoot $resolvedRepositoryRoot
        New-DependencyRef -RefId "r16_memory_pack_validation_module" -RefType "tool_file" -Path "tools/R16MemoryPackValidation.psm1" -SourceTask "R16-008" -ProofTreatment "committed_machine_evidence" -RepositoryRoot $resolvedRepositoryRoot
        New-DependencyRef -RefId "r16_memory_pack_ref_detector_cli" -RefType "tool_file" -Path "tools/test_r16_memory_pack_refs.ps1" -SourceTask "R16-008" -ProofTreatment "committed_machine_evidence" -RepositoryRoot $resolvedRepositoryRoot
        New-DependencyRef -RefId "r16_memory_pack_validation_report_validator_cli" -RefType "tool_file" -Path "tools/validate_r16_memory_pack_validation_report.ps1" -SourceTask "R16-008" -ProofTreatment "committed_machine_evidence" -RepositoryRoot $resolvedRepositoryRoot
        New-DependencyRef -RefId "r16_memory_pack_validation_test" -RefType "test_file" -Path "tests/test_r16_memory_pack_validation.ps1" -SourceTask "R16-008" -ProofTreatment "committed_machine_evidence" -RepositoryRoot $resolvedRepositoryRoot
        New-DependencyRef -RefId "r16_memory_layers" -RefType "state_artifact" -Path "state/memory/r16_memory_layers.json" -SourceTask "R16-005" -ProofTreatment "state_artifact_validator_backed_machine_evidence" -RepositoryRoot $resolvedRepositoryRoot
        New-DependencyRef -RefId "r16_role_memory_pack_model" -RefType "state_artifact" -Path "state/memory/r16_role_memory_pack_model.json" -SourceTask "R16-006" -ProofTreatment "state_artifact_validator_backed_machine_evidence" -RepositoryRoot $resolvedRepositoryRoot
        New-DependencyRef -RefId "r16_role_memory_packs" -RefType "state_artifact" -Path "state/memory/r16_role_memory_packs.json" -SourceTask "R16-007" -ProofTreatment "state_artifact_validator_backed_machine_evidence" -RepositoryRoot $resolvedRepositoryRoot
        New-DependencyRef -RefId "r16_007_validation_manifest" -RefType "validation_manifest" -Path "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_007_baseline_role_memory_packs/validation_manifest.md" -SourceTask "R16-007" -ProofTreatment "validation_manifest_commands_only" -RepositoryRoot $resolvedRepositoryRoot
        New-DependencyRef -RefId "r16_authority" -RefType "governance_document" -Path "governance/R16_OPERATIONAL_MEMORY_ARTIFACT_MAP_ROLE_WORKFLOW_FOUNDATION.md" -SourceTask "R16-001" -ProofTreatment "canonical_authority_constraint_not_proof_by_itself" -RepositoryRoot $resolvedRepositoryRoot
        New-DependencyRef -RefId "r16_planning_authority_reference" -RefType "state_artifact" -Path "state/governance/r16_planning_authority_reference.json" -SourceTask "R16-002" -ProofTreatment "state_artifact_validator_backed_machine_evidence" -RepositoryRoot $resolvedRepositoryRoot
        New-DependencyRef -RefId "r16_kpi_scorecard" -RefType "state_artifact" -Path "state/governance/r16_kpi_baseline_target_scorecard.json" -SourceTask "R16-003" -ProofTreatment "state_artifact_validator_backed_machine_evidence" -RepositoryRoot $resolvedRepositoryRoot
    )

    $failCount = @($findings | Where-Object { $_.severity -eq "fail" }).Count
    $warningCount = @($findings | Where-Object { $_.severity -eq "warning" }).Count
    $verdict = if ($failCount -gt 0) { "failed" } elseif ($warningCount -gt 0) { "passed_with_caveats" } else { "passed" }

    return [ordered]@{
        artifact_type = "r16_memory_pack_validation_report"
        contract_version = "v1"
        validation_report_contract_id = "aioffice-r16-008-memory-pack-validation-report-v1"
        source_milestone = "R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation"
        source_task = "R16-008"
        repository = "RodneyMuniz/AIOffice_V2"
        branch = "release/r16-operational-memory-artifact-map-role-workflow-foundation"
        generated_from_head = $head
        generated_from_tree = $tree
        report_mode = [ordered]@{
            mode = "deterministic_memory_pack_validation_and_stale_ref_detection_state_artifact_only"
            state_artifact_only = $true
            runtime_memory = $false
            artifact_map = $false
            audit_map = $false
            context_load_planner = $false
            workflow_execution = $false
        }
        dependency_refs = $dependencyRefs
        validation_scope = [ordered]@{
            consumed_memory_layers_path = $MemoryLayersPath.Replace("\", "/")
            consumed_role_model_path = $RoleModelPath.Replace("\", "/")
            consumed_role_packs_path = $RolePacksPath.Replace("\", "/")
            role_pack_count_expected = 8
            role_pack_count_observed = @($rolePacks.role_packs).Count
            memory_layer_type_count_expected = 10
            memory_layer_type_count_observed = @($memoryLayers.layer_records).Count
            exact_source_refs_only = $true
            source_refs_inspected_from_declared_artifacts_only = $true
            broad_repo_scan_performed = $false
            wildcard_scan_performed = $false
            artifact_maps_implemented = $false
            audit_maps_implemented = $false
            context_load_planner_implemented = $false
        }
        exact_ref_policy = [ordered]@{
            policy_id = "repo_relative_exact_refs_only"
            source_refs_must_be_repo_relative_exact_paths = $true
            broad_repo_root_refs_allowed = $false
            wildcard_refs_allowed = $false
            broad_repo_scan_allowed = $false
            broad_repo_scan_performed = $false
            wildcard_scan_performed = $false
        }
        stale_ref_detection_policy = [ordered]@{
            policy_id = "fail_closed_unless_explicit_caveat"
            generated_from_head_tree_mismatch_detected = $true
            stale_ref_requires_caveat = $true
            stale_ref_accepted_without_caveat = $false
            stale_caveat_must_name_ref_and_boundary = $true
            accepted_stale_caveat_count = $acceptedCaveats.Count
        }
        file_existence_policy = [ordered]@{
            required_exact_paths_must_exist = $true
            missing_required_exact_paths_fail = $true
            broad_repo_root_refs_fail = $true
            wildcard_refs_fail = $true
            required_file_existence_checked = $true
        }
        role_pack_policy_checks = [ordered]@{
            required_role_count = 8
            observed_role_count = @($rolePacks.role_packs).Count
            required_layer_types = $script:ExpectedLayerTypes
            required_layer_type_count = 10
            observed_layer_type_count = @($memoryLayers.layer_records).Count
            model_policy_source = $RoleModelPath.Replace("\", "/")
            missing_required_layers_fail = $true
            forbidden_layers_fail = $true
            unknown_roles_fail = $true
            unknown_layer_types_fail = $true
            deterministic_load_order_required = $true
        }
        proof_treatment_checks = [ordered]@{
            generated_reports_as_machine_proof_allowed = $false
            planning_reports_as_implementation_proof_allowed = $false
            validation_reports_are_runtime_memory = $false
            validation_reports_are_artifact_maps = $false
            validation_reports_are_audit_maps = $false
            validation_reports_are_context_load_planners = $false
        }
        overclaim_detection_policy = [ordered]@{
            runtime_memory_loading_claimed = $false
            persistent_memory_runtime_claimed = $false
            retrieval_runtime_claimed = $false
            vector_search_runtime_claimed = $false
            actual_autonomous_agents_claimed = $false
            true_multi_agent_execution_claimed = $false
            external_integration_claimed = $false
            artifact_map_claimed = $false
            audit_map_claimed = $false
            context_load_planner_claimed = $false
            role_run_envelope_claimed = $false
            handoff_packet_claimed = $false
            workflow_drill_claimed = $false
            r16_009_or_later_implementation_claimed = $false
            r16_027_or_later_task_exists = $false
            r13_closure_claimed = $false
            r14_caveat_removed = $false
            r15_caveat_removed = $false
        }
        report_schema = [ordered]@{
            required_top_level_fields = $script:RequiredReportFields
            aggregate_verdict_values = @("passed", "passed_with_caveats", "failed")
            single_json_object_required = $true
        }
        finding_schema = [ordered]@{
            required_fields = @("finding_id", "category", "severity", "subject_type", "subject_id", "path", "message", "expected", "actual", "accepted_caveat_id", "deterministic_order")
            deterministic_order_required = $true
            severity_values = @("pass", "info", "warning", "fail")
        }
        severity_model = [ordered]@{
            severity_values = @("pass", "info", "warning", "fail")
            fail_blocks_aggregate_pass = $true
            warning_requires_caveat_for_stale_ref = $true
        }
        accepted_stale_caveat_schema = [ordered]@{
            required_fields = @("caveat_id", "artifact_path", "artifact_type", "declared_generated_from_head", "declared_generated_from_tree", "observed_head", "observed_tree", "boundary_named", "accepted_reason", "preserved_scope")
            stale_boundary_must_name_head_and_tree = $true
            stale_boundary_must_name_artifact_path = $true
        }
        deterministic_generation_policy = [ordered]@{
            deterministic_output_required = $true
            deterministic_report_ordering_required = $true
            findings_sorted_by_deterministic_order = $true
            inspected_refs_sorted_by_path_then_ref_id = $true
            broad_repo_scan_allowed = $false
            wildcard_scan_allowed = $false
        }
        current_posture = New-CurrentPostureObject
        non_claims = $script:RequiredNonClaims
        preserved_boundaries = New-PreservedBoundariesObject
        validation_commands = @($script:RequiredValidationCommands | ForEach-Object { [ordered]@{ command = $_; required = $true } })
        invalid_state_rules = @($script:RequiredInvalidRuleIds | ForEach-Object { [ordered]@{ rule_id = $_; description = ("Fail closed for {0}." -f ($_ -replace "_", " ")) } })
        input_artifact_freshness = $freshness
        accepted_stale_caveats = $acceptedCaveats
        exact_inspected_refs = $inspectedRefs
        validated_memory_layer_types = @($script:ExpectedLayerTypes | ForEach-Object { [ordered]@{ layer_type = $_; present = ($layerTypes -contains $_) } })
        validated_role_packs = $validatedRolePacks
        findings = $findings
        finding_summary = [ordered]@{
            total_findings = $findings.Count
            pass_count = @($findings | Where-Object { $_.severity -eq "pass" }).Count
            info_count = @($findings | Where-Object { $_.severity -eq "info" }).Count
            warning_count = $warningCount
            fail_count = $failCount
            stale_ref_findings = @($findings | Where-Object { $_.category -eq "stale_generated_from_boundary" }).Count
            accepted_stale_ref_findings = $acceptedCaveats.Count
            missing_ref_findings = @($findings | Where-Object { $_.category -eq "missing_exact_path" -or $_.category -eq "missing_source_ref" }).Count
            proof_treatment_findings = @($findings | Where-Object { $_.category -eq "proof_treatment" -or $_.category -eq "generated_report_machine_proof" -or $_.category -eq "planning_report_implementation_proof" }).Count
            role_policy_findings = @($findings | Where-Object { $_.category -like "role_pack*" -or $_.category -eq "memory_layer_dependencies" }).Count
            overclaim_findings = @($findings | Where-Object { $_.category -like "overclaim*" }).Count
        }
        aggregate_verdict = $verdict
        artifact_statement = "R16-008 memory pack validation report is a committed validation report state artifact only. It is not runtime memory, not an artifact map, not an audit map, not a context-load planner, and not workflow execution."
    }
}

function Test-R16MemoryPackValidationReportContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$ContractPath,
        [string]$RepositoryRoot
    )

    $resolvedRepositoryRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedContractPath = Assert-SafeRepoRelativePath -Path $ContractPath -RepositoryRoot $resolvedRepositoryRoot -Context "ContractPath" -RequireLeaf
    $contract = Read-SingleJsonObject -Path $resolvedContractPath -Label "R16 memory pack validation report contract"

    foreach ($field in $script:RequiredContractFields) {
        Get-RequiredProperty -Object $contract -Name $field -Context $ContractPath | Out-Null
    }
    if ($contract.artifact_type -ne "r16_memory_pack_validation_report_contract") {
        throw "$ContractPath artifact_type must be r16_memory_pack_validation_report_contract."
    }
    if ($contract.source_task -ne "R16-008") {
        throw "$ContractPath source_task must be R16-008."
    }
    Assert-RequiredValuesPresent -Values (Assert-StringArray -Value $contract.severity_model.severity_values -Context "$ContractPath severity_model severity_values") -RequiredValues @("pass", "info", "warning", "fail") -Context "$ContractPath severity_model severity_values"
    Assert-RequiredValuesPresent -Values (Assert-StringArray -Value $contract.report_schema.required_top_level_fields -Context "$ContractPath report_schema required_top_level_fields") -RequiredValues $script:RequiredReportFields -Context "$ContractPath report_schema required_top_level_fields"
    $ruleIds = @((Assert-ObjectArray -Value $contract.invalid_state_rules -Context "$ContractPath invalid_state_rules") | ForEach-Object { [string]$_.rule_id })
    Assert-RequiredValuesPresent -Values $ruleIds -RequiredValues $script:RequiredInvalidRuleIds -Context "$ContractPath invalid_state_rules"
    Assert-PreservedBoundaries -Value $contract.preserved_boundaries -Context "$ContractPath preserved_boundaries"

    return [pscustomobject]@{
        ContractId = $contract.validation_report_contract_id
        SourceTask = $contract.source_task
        RequiredFieldCount = $script:RequiredReportFields.Count
        SeverityValues = [string[]]$contract.severity_model.severity_values
    }
}

function Test-ExactInspectedRefs {
    param(
        [Parameter(Mandatory = $true)]$Refs,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $items = Assert-ObjectArray -Value $Refs -Context $Context
    $keys = @()
    foreach ($item in $items) {
        $path = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "path" -Context $Context) -Context "$Context path"
        $refId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "ref_id" -Context $Context) -Context "$Context ref_id"
        Assert-SafeRepoRelativePath -Path $path -RepositoryRoot $RepositoryRoot -Context "$Context $refId" -RequireLeaf | Out-Null
        if ((Test-HasProperty -Object $item -Name "broad_scan_allowed") -and [bool]$item.broad_scan_allowed) {
            throw "$Context $refId broad_scan_allowed must be False."
        }
        if ((Test-HasProperty -Object $item -Name "wildcard_allowed") -and [bool]$item.wildcard_allowed) {
            throw "$Context $refId wildcard_allowed must be False."
        }
        if ((Test-GeneratedReportPath -Path $path) -and (Test-HasProperty -Object $item -Name "machine_proof") -and [bool]$item.machine_proof) {
            throw "$Context generated report treated as machine proof at '$path'."
        }
        if ((Test-PlanningReportPath -Path $path) -and (Test-HasProperty -Object $item -Name "implementation_proof") -and [bool]$item.implementation_proof) {
            throw "$Context planning report treated as implementation proof at '$path'."
        }
        $keys += ("{0}|{1}" -f $path, $refId)
    }

    $expectedKeys = @($keys | Sort-Object)
    for ($index = 0; $index -lt $keys.Count; $index += 1) {
        if ($keys[$index] -ne $expectedKeys[$index]) {
            throw "$Context exact_inspected_refs must be sorted by path then ref_id."
        }
    }
}

function Test-FindingOrdering {
    param(
        [Parameter(Mandatory = $true)]$Findings,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $items = Assert-ObjectArray -Value $Findings -Context $Context
    for ($index = 0; $index -lt $items.Count; $index += 1) {
        $finding = $items[$index]
        foreach ($field in @("finding_id", "category", "severity", "subject_type", "subject_id", "path", "message", "expected", "actual", "accepted_caveat_id", "deterministic_order")) {
            Get-RequiredProperty -Object $finding -Name $field -Context "$Context[$index]" | Out-Null
        }
        if ($finding.severity -notin @("pass", "info", "warning", "fail")) {
            throw "$Context[$index] severity '$($finding.severity)' is not allowed."
        }
        $order = Assert-IntegerValue -Value $finding.deterministic_order -Context "$Context[$index] deterministic_order"
        if ($order -ne ($index + 1)) {
            throw "$Context has non-deterministic report ordering at finding $($finding.finding_id)."
        }
        $expectedPrefix = "MPV-{0}-" -f $order.ToString("0000")
        if ([string]$finding.finding_id -notlike "$expectedPrefix*") {
            throw "$Context finding_id '$($finding.finding_id)' must match deterministic_order $order."
        }
    }
}

function Test-AcceptedStaleCaveats {
    param(
        [Parameter(Mandatory = $true)]$Report,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $caveats = Assert-ObjectArray -Value $Report.accepted_stale_caveats -Context "$Context accepted_stale_caveats" -AllowEmpty
    $caveatIds = @($caveats | ForEach-Object { [string]$_.caveat_id })
    foreach ($caveat in $caveats) {
        foreach ($field in @("caveat_id", "artifact_path", "artifact_type", "declared_generated_from_head", "declared_generated_from_tree", "observed_head", "observed_tree", "boundary_named", "accepted_reason", "preserved_scope")) {
            Assert-NonEmptyString -Value (Get-RequiredProperty -Object $caveat -Name $field -Context "$Context accepted_stale_caveat") -Context "$Context accepted_stale_caveat $field" | Out-Null
        }
        if ($caveat.boundary_named -notmatch [regex]::Escape($caveat.declared_generated_from_head) -or $caveat.boundary_named -notmatch [regex]::Escape($caveat.declared_generated_from_tree)) {
            throw "$Context accepted stale caveat '$($caveat.caveat_id)' must name the stale head/tree boundary."
        }
    }

    foreach ($finding in @($Report.findings | Where-Object { $_.category -eq "stale_generated_from_boundary" -and $_.severity -eq "warning" })) {
        if ([string]::IsNullOrWhiteSpace([string]$finding.accepted_caveat_id) -or $caveatIds -notcontains [string]$finding.accepted_caveat_id) {
            throw "$Context stale ref without caveat is rejected for finding '$($finding.finding_id)'."
        }
    }
}

function Test-R16MemoryPackValidationReportObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Report,
        [Parameter(Mandatory = $true)]$MemoryLayers,
        [Parameter(Mandatory = $true)]$RoleModel,
        [Parameter(Mandatory = $true)]$RolePacks,
        [Parameter(Mandatory = $true)]$Contract,
        [string]$RepositoryRoot = $repoRoot,
        [string]$SourceLabel = "R16 memory pack validation report"
    )

    $resolvedRepositoryRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    foreach ($field in $script:RequiredReportFields) {
        Get-RequiredProperty -Object $Report -Name $field -Context $SourceLabel | Out-Null
    }
    if ($Report.artifact_type -ne "r16_memory_pack_validation_report") {
        throw "$SourceLabel artifact_type must be r16_memory_pack_validation_report."
    }
    if ($Report.validation_report_contract_id -ne $Contract.validation_report_contract_id) {
        throw "$SourceLabel validation_report_contract_id must match contract."
    }
    if ($Report.source_task -ne "R16-008") {
        throw "$SourceLabel source_task must be R16-008."
    }
    if ($Report.repository -ne "RodneyMuniz/AIOffice_V2") {
        throw "$SourceLabel repository must be RodneyMuniz/AIOffice_V2."
    }
    if ($Report.branch -ne "release/r16-operational-memory-artifact-map-role-workflow-foundation") {
        throw "$SourceLabel branch must be the R16 release branch."
    }
    Assert-NonEmptyString -Value $Report.generated_from_head -Context "$SourceLabel generated_from_head" | Out-Null
    Assert-NonEmptyString -Value $Report.generated_from_tree -Context "$SourceLabel generated_from_tree" | Out-Null

    $scope = Assert-ObjectValue -Value $Report.validation_scope -Context "$SourceLabel validation_scope"
    if ($scope.consumed_memory_layers_path -ne "state/memory/r16_memory_layers.json") {
        throw "$SourceLabel missing memory layers artifact dependency."
    }
    if ($scope.consumed_role_model_path -ne "state/memory/r16_role_memory_pack_model.json") {
        throw "$SourceLabel missing role model artifact dependency."
    }
    if ($scope.consumed_role_packs_path -ne "state/memory/r16_role_memory_packs.json") {
        throw "$SourceLabel missing role packs artifact dependency."
    }
    if ([int]$scope.role_pack_count_observed -ne 8 -or [int]$scope.role_pack_count_expected -ne 8) {
        throw "$SourceLabel must validate all eight role packs."
    }
    if ([int]$scope.memory_layer_type_count_observed -ne 10 -or [int]$scope.memory_layer_type_count_expected -ne 10) {
        throw "$SourceLabel must validate all 10 memory layer types."
    }
    foreach ($falseField in @("broad_repo_scan_performed", "wildcard_scan_performed", "artifact_maps_implemented", "audit_maps_implemented", "context_load_planner_implemented")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $scope -Name $falseField -Context "$SourceLabel validation_scope") -Context "$SourceLabel validation_scope $falseField") -ne $false) {
            throw "$SourceLabel validation_scope $falseField must be False."
        }
    }

    $exactPolicy = Assert-ObjectValue -Value $Report.exact_ref_policy -Context "$SourceLabel exact_ref_policy"
    foreach ($falseField in @("broad_repo_root_refs_allowed", "wildcard_refs_allowed", "broad_repo_scan_allowed", "broad_repo_scan_performed", "wildcard_scan_performed")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $exactPolicy -Name $falseField -Context "$SourceLabel exact_ref_policy") -Context "$SourceLabel exact_ref_policy $falseField") -ne $false) {
            throw "$SourceLabel exact_ref_policy $falseField must be False."
        }
    }

    $filePolicy = Assert-ObjectValue -Value $Report.file_existence_policy -Context "$SourceLabel file_existence_policy"
    foreach ($trueField in @("required_exact_paths_must_exist", "missing_required_exact_paths_fail", "broad_repo_root_refs_fail", "wildcard_refs_fail", "required_file_existence_checked")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $filePolicy -Name $trueField -Context "$SourceLabel file_existence_policy") -Context "$SourceLabel file_existence_policy $trueField") -ne $true) {
            throw "$SourceLabel file_existence_policy $trueField must be True."
        }
    }

    $roleChecks = Assert-ObjectValue -Value $Report.role_pack_policy_checks -Context "$SourceLabel role_pack_policy_checks"
    if ([int]$roleChecks.observed_role_count -ne 8 -or [int]$roleChecks.observed_layer_type_count -ne 10) {
        throw "$SourceLabel role policy counts must cover 8 roles and 10 memory layer types."
    }
    foreach ($trueField in @("missing_required_layers_fail", "forbidden_layers_fail", "unknown_roles_fail", "unknown_layer_types_fail", "deterministic_load_order_required")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $roleChecks -Name $trueField -Context "$SourceLabel role_pack_policy_checks") -Context "$SourceLabel role_pack_policy_checks $trueField") -ne $true) {
            throw "$SourceLabel role_pack_policy_checks $trueField must be True."
        }
    }

    $proofChecks = Assert-ObjectValue -Value $Report.proof_treatment_checks -Context "$SourceLabel proof_treatment_checks"
    foreach ($falseField in @("generated_reports_as_machine_proof_allowed", "planning_reports_as_implementation_proof_allowed", "validation_reports_are_runtime_memory", "validation_reports_are_artifact_maps", "validation_reports_are_audit_maps", "validation_reports_are_context_load_planners")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $proofChecks -Name $falseField -Context "$SourceLabel proof_treatment_checks") -Context "$SourceLabel proof_treatment_checks $falseField") -ne $false) {
            throw "$SourceLabel proof_treatment_checks $falseField must be False."
        }
    }

    $overclaims = Assert-ObjectValue -Value $Report.overclaim_detection_policy -Context "$SourceLabel overclaim_detection_policy"
    foreach ($falseField in @(
            "runtime_memory_loading_claimed",
            "persistent_memory_runtime_claimed",
            "retrieval_runtime_claimed",
            "vector_search_runtime_claimed",
            "actual_autonomous_agents_claimed",
            "true_multi_agent_execution_claimed",
            "external_integration_claimed",
            "artifact_map_claimed",
            "audit_map_claimed",
            "context_load_planner_claimed",
            "role_run_envelope_claimed",
            "handoff_packet_claimed",
            "workflow_drill_claimed",
            "r16_009_or_later_implementation_claimed",
            "r16_027_or_later_task_exists",
            "r13_closure_claimed",
            "r14_caveat_removed",
            "r15_caveat_removed"
        )) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $overclaims -Name $falseField -Context "$SourceLabel overclaim_detection_policy") -Context "$SourceLabel overclaim_detection_policy $falseField") -ne $false) {
            throw "$SourceLabel overclaim_detection_policy $falseField must be False."
        }
    }

    Assert-RequiredValuesPresent -Values (Assert-StringArray -Value $Report.severity_model.severity_values -Context "$SourceLabel severity_model severity_values") -RequiredValues @("pass", "info", "warning", "fail") -Context "$SourceLabel severity_model severity_values"
    Assert-CurrentPosture -Posture $Report.current_posture -Context "$SourceLabel current_posture"
    Assert-PreservedBoundaries -Value $Report.preserved_boundaries -Context "$SourceLabel preserved_boundaries"
    Assert-RequiredValuesPresent -Values (Assert-StringArray -Value $Report.non_claims -Context "$SourceLabel non_claims") -RequiredValues $script:RequiredNonClaims -Context "$SourceLabel non_claims"

    $dependencyRefs = Assert-ObjectArray -Value $Report.dependency_refs -Context "$SourceLabel dependency_refs"
    foreach ($dependencyRef in $dependencyRefs) {
        $path = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $dependencyRef -Name "path" -Context "$SourceLabel dependency_refs") -Context "$SourceLabel dependency_refs path"
        Assert-SafeRepoRelativePath -Path $path -RepositoryRoot $resolvedRepositoryRoot -Context "$SourceLabel dependency_refs $path" -RequireLeaf | Out-Null
        if ((Assert-BooleanValue -Value $dependencyRef.exact_ref_required -Context "$SourceLabel dependency_refs exact_ref_required") -ne $true) {
            throw "$SourceLabel dependency ref '$path' must require exact refs."
        }
        if ((Assert-BooleanValue -Value $dependencyRef.broad_scan_allowed -Context "$SourceLabel dependency_refs broad_scan_allowed") -ne $false -or (Assert-BooleanValue -Value $dependencyRef.wildcard_allowed -Context "$SourceLabel dependency_refs wildcard_allowed") -ne $false) {
            throw "$SourceLabel dependency ref '$path' must reject broad scan and wildcard refs."
        }
    }

    Test-ExactInspectedRefs -Refs $Report.exact_inspected_refs -RepositoryRoot $resolvedRepositoryRoot -Context "$SourceLabel exact_inspected_refs"
    Test-FindingOrdering -Findings $Report.findings -Context "$SourceLabel findings"
    Test-AcceptedStaleCaveats -Report $Report -Context $SourceLabel

    $validatedLayerTypes = @($Report.validated_memory_layer_types | ForEach-Object { [string]$_.layer_type })
    Assert-ExactStringSet -Values $validatedLayerTypes -ExpectedValues $script:ExpectedLayerTypes -Context "$SourceLabel validated_memory_layer_types"
    $validatedRoleIds = @($Report.validated_role_packs | ForEach-Object { [string]$_.role_id })
    foreach ($validatedRoleId in $validatedRoleIds) {
        if ($script:ExpectedRoles -notcontains $validatedRoleId) {
            throw "$SourceLabel role pack uses unknown role '$validatedRoleId'."
        }
    }
    Assert-ExactStringSet -Values $validatedRoleIds -ExpectedValues $script:ExpectedRoles -Context "$SourceLabel validated_role_packs"
    $rolePolicyMap = Get-RolePolicyMap -Model $RoleModel
    foreach ($validatedPack in @($Report.validated_role_packs)) {
        $roleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $validatedPack -Name "role_id" -Context "$SourceLabel validated_role_packs") -Context "$SourceLabel validated_role_packs role_id"
        if ($script:ExpectedRoles -notcontains $roleId -or -not $rolePolicyMap.ContainsKey($roleId)) {
            throw "$SourceLabel role pack uses unknown role '$roleId'."
        }
        $dependencyLayerTypes = Assert-StringArray -Value (Get-RequiredProperty -Object $validatedPack -Name "dependency_layer_types" -Context "$SourceLabel validated_role_packs $roleId") -Context "$SourceLabel validated_role_packs $roleId dependency_layer_types"
        foreach ($dependencyLayerType in $dependencyLayerTypes) {
            if ($script:ExpectedLayerTypes -notcontains $dependencyLayerType) {
                throw "$SourceLabel role pack '$roleId' uses unknown layer type '$dependencyLayerType'."
            }
        }
        $policy = $rolePolicyMap[$roleId]
        foreach ($requiredLayer in @($policy.required_memory_layer_types)) {
            if ($dependencyLayerTypes -notcontains [string]$requiredLayer) {
                throw "$SourceLabel role pack '$roleId' is missing required layer '$requiredLayer'."
            }
        }
        foreach ($forbiddenLayer in @($policy.forbidden_memory_layer_types)) {
            if ($dependencyLayerTypes -contains [string]$forbiddenLayer) {
                throw "$SourceLabel role pack '$roleId' includes forbidden layer '$forbiddenLayer'."
            }
        }
    }

    $failFindings = @($Report.findings | Where-Object { $_.severity -eq "fail" })
    if ($failFindings.Count -gt 0) {
        throw "$SourceLabel contains failing findings: $($failFindings[0].finding_id) $($failFindings[0].message)"
    }
    if ($Report.aggregate_verdict -notin @("passed", "passed_with_caveats")) {
        throw "$SourceLabel aggregate_verdict must pass when no failing findings exist."
    }
    if (@($Report.accepted_stale_caveats).Count -gt 0 -and $Report.aggregate_verdict -ne "passed_with_caveats") {
        throw "$SourceLabel aggregate_verdict must be passed_with_caveats when stale refs are accepted by caveat."
    }

    $statement = Assert-NonEmptyString -Value $Report.artifact_statement -Context "$SourceLabel artifact_statement"
    foreach ($fragment in @("committed validation report state artifact only", "not runtime memory", "not an artifact map", "not an audit map", "not a context-load planner", "not workflow execution")) {
        if ($statement -notmatch [regex]::Escape($fragment)) {
            throw "$SourceLabel artifact_statement must include '$fragment'."
        }
    }

    return [pscustomobject]@{
        AggregateVerdict = $Report.aggregate_verdict
        RolePackCount = @($Report.validated_role_packs).Count
        MemoryLayerTypeCount = @($Report.validated_memory_layer_types).Count
        ExactInspectedRefCount = @($Report.exact_inspected_refs).Count
        AcceptedStaleCaveatCount = @($Report.accepted_stale_caveats).Count
        MissingRefFindingCount = [int]$Report.finding_summary.missing_ref_findings
        RolePolicyFindingCount = [int]$Report.finding_summary.role_policy_findings
        OverclaimFindingCount = [int]$Report.finding_summary.overclaim_findings
        ActiveThroughTask = $Report.current_posture.active_through_task
        PlannedTaskStart = $Report.current_posture.planned_tasks[0]
        PlannedTaskEnd = $Report.current_posture.planned_tasks[-1]
    }
}

function Test-R16MemoryPackValidationReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$ReportPath,
        [Parameter(Mandatory = $true)][string]$MemoryLayersPath,
        [Parameter(Mandatory = $true)][string]$RoleModelPath,
        [Parameter(Mandatory = $true)][string]$RolePacksPath,
        [Parameter(Mandatory = $true)][string]$ContractPath,
        [string]$RepositoryRoot
    )

    $resolvedRepositoryRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedReportPath = Assert-SafeRepoRelativePath -Path $ReportPath -RepositoryRoot $resolvedRepositoryRoot -Context "ReportPath" -RequireLeaf
    $resolvedMemoryLayersPath = Assert-SafeRepoRelativePath -Path $MemoryLayersPath -RepositoryRoot $resolvedRepositoryRoot -Context "MemoryLayersPath" -RequireLeaf
    $resolvedRoleModelPath = Assert-SafeRepoRelativePath -Path $RoleModelPath -RepositoryRoot $resolvedRepositoryRoot -Context "RoleModelPath" -RequireLeaf
    $resolvedRolePacksPath = Assert-SafeRepoRelativePath -Path $RolePacksPath -RepositoryRoot $resolvedRepositoryRoot -Context "RolePacksPath" -RequireLeaf
    $resolvedContractPath = Assert-SafeRepoRelativePath -Path $ContractPath -RepositoryRoot $resolvedRepositoryRoot -Context "ContractPath" -RequireLeaf

    $contract = Read-SingleJsonObject -Path $resolvedContractPath -Label "R16 memory pack validation report contract"
    Test-R16MemoryPackValidationReportContract -ContractPath $ContractPath -RepositoryRoot $resolvedRepositoryRoot | Out-Null
    $memoryLayers = Read-SingleJsonObject -Path $resolvedMemoryLayersPath -Label "R16 memory layers"
    $roleModel = Read-SingleJsonObject -Path $resolvedRoleModelPath -Label "R16 role memory pack model"
    $rolePacks = Read-SingleJsonObject -Path $resolvedRolePacksPath -Label "R16 role memory packs"
    $report = Read-SingleJsonObject -Path $resolvedReportPath -Label "R16 memory pack validation report"

    return Test-R16MemoryPackValidationReportObject -Report $report -MemoryLayers $memoryLayers -RoleModel $roleModel -RolePacks $rolePacks -Contract $contract -RepositoryRoot $resolvedRepositoryRoot -SourceLabel $ReportPath
}

function New-R16MemoryPackValidationReport {
    [CmdletBinding()]
    param(
        [string]$OutputPath = "state\memory\r16_memory_pack_validation_report.json",
        [string]$MemoryLayersPath = "state\memory\r16_memory_layers.json",
        [string]$RoleModelPath = "state\memory\r16_role_memory_pack_model.json",
        [string]$RolePacksPath = "state\memory\r16_role_memory_packs.json",
        [string]$ContractPath = "contracts\memory\r16_memory_pack_validation_report.contract.json",
        [string]$RepositoryRoot
    )

    $resolvedRepositoryRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedOutputPath = Assert-SafeRepoRelativePath -Path $OutputPath -RepositoryRoot $resolvedRepositoryRoot -Context "OutputPath"
    $report = New-R16MemoryPackValidationReportObject -MemoryLayersPath $MemoryLayersPath -RoleModelPath $RoleModelPath -RolePacksPath $RolePacksPath -ContractPath $ContractPath -RepositoryRoot $resolvedRepositoryRoot
    Write-StableJsonFile -Object $report -Path $resolvedOutputPath
    $validation = Test-R16MemoryPackValidationReport -ReportPath $OutputPath -MemoryLayersPath $MemoryLayersPath -RoleModelPath $RoleModelPath -RolePacksPath $RolePacksPath -ContractPath $ContractPath -RepositoryRoot $resolvedRepositoryRoot

    return [pscustomobject]@{
        OutputPath = $OutputPath
        AggregateVerdict = $validation.AggregateVerdict
        RolePackCount = $validation.RolePackCount
        MemoryLayerTypeCount = $validation.MemoryLayerTypeCount
        ExactInspectedRefCount = $validation.ExactInspectedRefCount
        AcceptedStaleCaveatCount = $validation.AcceptedStaleCaveatCount
        ActiveThroughTask = $validation.ActiveThroughTask
        PlannedTaskStart = $validation.PlannedTaskStart
        PlannedTaskEnd = $validation.PlannedTaskEnd
    }
}

Export-ModuleMember -Function New-R16MemoryPackValidationReportObject, New-R16MemoryPackValidationReport, Test-R16MemoryPackValidationReport, Test-R16MemoryPackValidationReportObject, Test-R16MemoryPackValidationReportContract
