Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R16ContextLoadPlanner.psm1") -Force

$script:R16Milestone = "R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation"
$script:Repository = "RodneyMuniz/AIOffice_V2"
$script:Branch = "release/r16-operational-memory-artifact-map-role-workflow-foundation"
$script:InputHead = "f5e8d228bc9993e59ca7907b1fc427381b365daa"
$script:InputTree = "ca0ff6c829cfdd029a1b97ad931243df6c598500"
$script:EstimateContractId = "aioffice-r16-016-context-budget-estimate-contract-v1"
$script:EstimateId = "aioffice-r16-016-context-budget-estimate-v1"
$script:CompleteTasks = [string[]](1..16 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })
$script:PlannedTasks = [string[]](17..26 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })

$script:RequiredEstimateTopLevelFields = @(
    "artifact_type",
    "estimate_version",
    "estimate_id",
    "source_milestone",
    "source_task",
    "repository",
    "branch",
    "generation_boundary",
    "context_load_plan_ref",
    "estimate_mode",
    "estimation_method",
    "summary_estimates",
    "load_item_estimates",
    "current_posture",
    "preserved_boundaries",
    "finding_summary",
    "aggregate_verdict",
    "non_claims"
)

$script:RequiredLoadItemEstimateFields = @(
    "estimate_item_id",
    "load_item_id",
    "path",
    "exists",
    "byte_count",
    "line_count",
    "estimated_tokens_lower_bound",
    "estimated_tokens_upper_bound",
    "estimate_basis",
    "exact_provider_token_count_claimed",
    "exact_provider_billing_claimed",
    "deterministic_order"
)

$script:RequiredFalseEstimateModeFields = @(
    "exact_provider_token_count_claimed",
    "exact_provider_billing_claimed",
    "over_budget_fail_closed_validator_implemented",
    "runtime_memory_implemented",
    "runtime_memory_loading_implemented",
    "retrieval_runtime_implemented",
    "vector_search_runtime_implemented",
    "product_runtime_implemented",
    "actual_autonomous_agents_implemented",
    "true_multi_agent_execution_implemented",
    "external_integrations_implemented",
    "role_run_envelope_implemented",
    "raci_transition_gate_implemented",
    "handoff_packet_implemented",
    "workflow_drill_run",
    "solved_codex_compaction",
    "solved_codex_reliability"
)

$script:RequiredNonClaims = @(
    "no exact provider token count",
    "no exact provider billing",
    "no over-budget fail-closed validator",
    "no role-run envelope",
    "no RACI transition gate",
    "no handoff packet",
    "no workflow drill",
    "no product runtime",
    "no runtime memory",
    "no retrieval runtime",
    "no vector search runtime",
    "no autonomous agents",
    "no external integrations",
    "no solved Codex compaction",
    "no solved Codex reliability"
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

    return [int64]$Value
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
        Assert-NonEmptyString -Value $item -Context "$Context item" | Out-Null
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
        Assert-ObjectValue -Value $item -Context "$Context item" | Out-Null
    }

    $PSCmdlet.WriteObject($items, $false)
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

function Assert-ExactStringSet {
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

function Assert-TrueField {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Field,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $value = Get-RequiredProperty -Object $Object -Name $Field -Context $Context
    if ((Assert-BooleanValue -Value $value -Context "$Context $Field") -ne $true) {
        throw "$Context $Field must be True."
    }
}

function ConvertTo-NormalizedRepoPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    return $Path.Trim().Replace("\", "/")
}

function Test-WildcardPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    return $Path -match '[\*\?]'
}

function Test-BroadRepoRootPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    $normalized = ConvertTo-NormalizedRepoPath -Path $Path
    return [string]::IsNullOrWhiteSpace($normalized) -or $normalized -in @(".", "./", "/", "\", "repo", "repository", "full_repo", "entire_repo")
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

    if ([System.IO.Path]::IsPathRooted($normalized) -or $normalized -match '(^|/)\.\.(/|$)' -or $normalized -match '^[A-Za-z][A-Za-z0-9+.-]*:') {
        return $false
    }

    $resolved = [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $normalized))
    return (Test-Path -LiteralPath $resolved -PathType Container)
}

function Test-LocalScratchPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    $normalized = ConvertTo-NormalizedRepoPath -Path $Path
    return $normalized -match '^(scratch|tmp|temp|state/temp|state/tmp|state/scratch)(/|$)'
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

function Assert-GitTrackedPath {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $normalized = ConvertTo-NormalizedRepoPath -Path $Path
    $null = & git -C $RepositoryRoot ls-files --error-unmatch -- $normalized 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "$Context rejects untracked ref '$Path'."
    }
}

function Assert-SafeRepoRelativePath {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [Parameter(Mandatory = $true)][string]$Context,
        [switch]$RequireLeaf,
        [switch]$RequireTracked
    )

    $normalized = ConvertTo-NormalizedRepoPath -Path $Path
    if ($normalized -match '^[A-Za-z][A-Za-z0-9+.-]*:') {
        throw "$Context rejects remote or non-repo path '$Path'."
    }
    if ([System.IO.Path]::IsPathRooted($normalized)) {
        throw "$Context path must be repo-relative, not absolute."
    }
    if (Test-BroadRepoRootPath -Path $normalized) {
        throw "$Context rejects broad repo scan or broad repo root path '$Path'."
    }
    if (Test-WildcardPath -Path $normalized) {
        throw "$Context rejects wildcard path '$Path'."
    }
    if ($normalized -match '(^|/)\.\.(/|$)') {
        throw "$Context must not traverse outside the repository."
    }
    if (Test-DirectoryOnlyPath -Path $normalized -RepositoryRoot $RepositoryRoot) {
        throw "$Context rejects directory-only ref '$Path'."
    }
    if (Test-LocalScratchPath -Path $normalized) {
        throw "$Context rejects local scratch ref '$Path'."
    }

    $resolved = [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $normalized))
    $root = [System.IO.Path]::GetFullPath($RepositoryRoot)
    if (-not $resolved.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "$Context must remain inside the repository."
    }
    if ($RequireLeaf -and -not (Test-Path -LiteralPath $resolved -PathType Leaf)) {
        throw "$Context required path '$Path' does not exist."
    }
    if ($RequireTracked) {
        Assert-GitTrackedPath -Path $normalized -RepositoryRoot $RepositoryRoot -Context $Context
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

function Get-StringValuesFromObject {
    [CmdletBinding()]
    param([AllowNull()]$Value)

    if ($null -eq $Value) {
        return
    }

    if ($Value -is [string]) {
        $PSCmdlet.WriteObject($Value, $false)
        return
    }

    if ($Value -is [System.Collections.IDictionary]) {
        foreach ($key in $Value.Keys) {
            Get-StringValuesFromObject -Value $Value[$key]
        }
        return
    }

    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
        foreach ($item in $Value) {
            Get-StringValuesFromObject -Value $item
        }
        return
    }

    if ($Value.PSObject -and $Value.PSObject.Properties) {
        foreach ($property in $Value.PSObject.Properties) {
            Get-StringValuesFromObject -Value $property.Value
        }
    }
}

function Test-TextHasNegation {
    param([AllowNull()][string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return $false
    }

    return $Text -match '(?i)\b(no|not|without|does not|do not|must not|never|non-claim|non_claim|false|planned only|not implemented|not claimed|approximate|approximation|not exact|not provider|non-provider|not currency|rejected|rejects|fail closed|fail-closed|only)\b'
}

function Assert-NoForbiddenPositiveClaim {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]]$Values,
        [Parameter(Mandatory = $true)][string]$Context,
        [Parameter(Mandatory = $true)][string]$ClaimLabel,
        [Parameter(Mandatory = $true)][string]$Pattern
    )

    foreach ($value in $Values) {
        if ($value -match $Pattern -and -not (Test-TextHasNegation -Text $value)) {
            throw "$Context contains forbidden positive claim: $ClaimLabel. Text: $value"
        }
    }
}

function Assert-NoOverclaimsInStrings {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $values = @(Get-StringValuesFromObject -Value $Object)
    Assert-NoForbiddenPositiveClaim -Values $values -Context $Context -ClaimLabel "exact provider token count" -Pattern '(?i)\b(exact provider token count|exact provider tokenization|exact provider tokenizer|provider tokenizer used|exact tokenizer)\b'
    Assert-NoForbiddenPositiveClaim -Values $values -Context $Context -ClaimLabel "exact provider billing" -Pattern '(?i)\b(exact provider billing|exact provider bill|provider bill|provider billing|provider pricing used|exact provider pricing)\b'
    Assert-NoForbiddenPositiveClaim -Values $values -Context $Context -ClaimLabel "over-budget fail-closed validator" -Pattern '(?i)\b(over-budget fail-closed validator|over budget fail closed validator)\b.{0,160}\b(implemented|exists|created|claimed|complete)\b'
    Assert-NoForbiddenPositiveClaim -Values $values -Context $Context -ClaimLabel "runtime memory" -Pattern '(?i)\b(runtime memory|runtime memory loading|persistent memory runtime|persistent memory engine)\b.{0,160}\b(implemented|exists|created|claimed|complete|runtime)\b'
    Assert-NoForbiddenPositiveClaim -Values $values -Context $Context -ClaimLabel "retrieval runtime" -Pattern '(?i)\b(retrieval runtime|retrieval engine|runtime retrieval)\b.{0,160}\b(implemented|exists|created|claimed|complete)\b'
    Assert-NoForbiddenPositiveClaim -Values $values -Context $Context -ClaimLabel "vector search runtime" -Pattern '(?i)\b(vector search runtime|runtime vector search|vector search)\b.{0,160}\b(implemented|exists|created|claimed|complete)\b'
    Assert-NoForbiddenPositiveClaim -Values $values -Context $Context -ClaimLabel "role-run envelope" -Pattern '(?i)\b(role-run envelope|role run envelope)\b.{0,160}\b(implemented|exists|created|claimed|complete)\b'
    Assert-NoForbiddenPositiveClaim -Values $values -Context $Context -ClaimLabel "RACI transition gate" -Pattern '(?i)\b(RACI transition gate|RACI transition gates)\b.{0,160}\b(implemented|exists|created|claimed|complete)\b'
    Assert-NoForbiddenPositiveClaim -Values $values -Context $Context -ClaimLabel "handoff packet" -Pattern '(?i)\b(handoff packet|handoff packets)\b.{0,160}\b(implemented|exists|created|claimed|complete)\b'
    Assert-NoForbiddenPositiveClaim -Values $values -Context $Context -ClaimLabel "workflow drill" -Pattern '(?i)\b(workflow drill|workflow drills)\b.{0,160}\b(implemented|exists|created|claimed|complete|ran)\b'
    Assert-NoForbiddenPositiveClaim -Values $values -Context $Context -ClaimLabel "product runtime" -Pattern '(?i)\b(product runtime|production runtime|productized UI|productized control-room behavior|full UI app)\b'
    Assert-NoForbiddenPositiveClaim -Values $values -Context $Context -ClaimLabel "autonomous agents" -Pattern '(?i)\b(actual autonomous agents|actual agents implemented|true multi-agent execution|true multi-agent runtime|agent runtime)\b'
    Assert-NoForbiddenPositiveClaim -Values $values -Context $Context -ClaimLabel "external integrations" -Pattern '(?i)\b(GitHub Projects integration|Linear integration|Symphony integration|custom board integration|external board sync|external integration)\b'
    Assert-NoForbiddenPositiveClaim -Values $values -Context $Context -ClaimLabel "solved Codex compaction or reliability" -Pattern '(?i)\b(solved Codex compaction|solved Codex context compaction|solved Codex reliability|Codex reliability solved|Codex compaction solved)\b'
    Assert-NoForbiddenPositiveClaim -Values $values -Context $Context -ClaimLabel "R16-017 or later implementation" -Pattern '(?i)\bR16-(0(?:1[7-9]|2[0-6]))\b.{0,160}\b(done|complete|completed|implemented|executed|ran|claimed|created)\b'
    Assert-NoForbiddenPositiveClaim -Values $values -Context $Context -ClaimLabel "R16-027 or later task" -Pattern '(?i)\bR16-(0(?:2[7-9]|[3-9][0-9])|[1-9][0-9]{2,})\b.{0,160}\b(done|complete|completed|implemented|executed|ran|exists|created|planned|active)\b'
    Assert-NoForbiddenPositiveClaim -Values $values -Context $Context -ClaimLabel "R13 closure" -Pattern '(?i)\bR13\b.{0,120}\b(is now closed|is closed|formally closed|closed in repo truth|closeout package exists|final-head support exists|merged to main|main merge exists)\b'
    Assert-NoForbiddenPositiveClaim -Values $values -Context $Context -ClaimLabel "R14 caveat removal" -Pattern '(?i)\bR14\b.{0,120}\b(accepted without caveats|uncaveated acceptance|caveats removed|cleanly accepted|accepted cleanly)\b'
    Assert-NoForbiddenPositiveClaim -Values $values -Context $Context -ClaimLabel "R15 caveat removal" -Pattern '(?i)\bR15\b.{0,120}\b(accepted without caveats|uncaveated acceptance|caveats removed|cleanly accepted|accepted cleanly)\b'
}

function Get-LineCount {
    param([Parameter(Mandatory = $true)][string]$Path)

    $lineCount = 0
    foreach ($line in [System.IO.File]::ReadLines($Path)) {
        $lineCount += 1
    }

    return $lineCount
}

function Get-TokenEstimateBounds {
    param([Parameter(Mandatory = $true)][int64]$ByteCount)

    return [pscustomobject]@{
        Lower = [int64][math]::Ceiling($ByteCount / 5)
        Upper = [int64][math]::Ceiling($ByteCount / 3)
    }
}

function Get-BudgetCategory {
    param([Parameter(Mandatory = $true)][int64]$UpperBound)

    if ($UpperBound -le 25000) {
        return "small"
    }
    if ($UpperBound -le 75000) {
        return "medium"
    }
    if ($UpperBound -le 150000) {
        return "large"
    }

    return "very_large"
}

function Get-ContextLoadPlanItems {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Plan,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    $groups = @($Plan.load_groups | Sort-Object -Property deterministic_order)
    $items = @()
    foreach ($group in $groups) {
        $loadItems = @($group.load_items | Sort-Object -Property deterministic_order)
        foreach ($item in $loadItems) {
            $path = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "path" -Context "context-load plan load item") -Context "context-load plan load item path"
            if ((Assert-BooleanValue -Value $item.exact_path_only -Context "context-load plan load item exact_path_only") -ne $true) {
                throw "context-load plan load item '$path' exact_path_only must be True."
            }
            if ((Assert-BooleanValue -Value $item.broad_scan_allowed -Context "context-load plan load item broad_scan_allowed") -ne $false) {
                throw "context-load plan load item '$path' broad_scan_allowed must be False."
            }
            if ((Assert-BooleanValue -Value $item.wildcard_allowed -Context "context-load plan load item wildcard_allowed") -ne $false) {
                throw "context-load plan load item '$path' wildcard_allowed must be False."
            }
            if ((Assert-BooleanValue -Value $item.remote_verified -Context "context-load plan load item remote_verified") -ne $true) {
                throw "context-load plan load item '$path' remote_verified must be True."
            }

            Assert-SafeRepoRelativePath -Path $path -RepositoryRoot $RepositoryRoot -Context "context-load plan load item '$($item.item_id)'" -RequireLeaf -RequireTracked | Out-Null
            $items += $item
        }
    }

    return $items
}

function Test-R16ContextBudgetEstimateContract {
    [CmdletBinding()]
    param(
        [string]$Path = "contracts/context/r16_context_budget_estimate.contract.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedPath = Assert-SafeRepoRelativePath -Path $Path -RepositoryRoot $resolvedRoot -Context "R16 context budget estimate contract path" -RequireLeaf
    $contract = Read-SingleJsonObject -Path $resolvedPath -Label "R16 context budget estimate contract"

    foreach ($field in @("artifact_type", "contract_version", "estimate_contract_id", "source_milestone", "source_task", "repository", "branch", "generated_from_head", "generated_from_tree", "dependency_refs", "estimate_schema", "load_item_estimate_schema", "approximation_policy", "no_exact_provider_claim_policy", "budget_category_policy", "validation_policy", "overclaim_detection_policy", "current_posture", "preserved_boundaries", "non_claims")) {
        Get-RequiredProperty -Object $contract -Name $field -Context "R16 context budget estimate contract" | Out-Null
    }

    if ($contract.artifact_type -ne "r16_context_budget_estimate_contract" -or $contract.contract_version -ne "v1" -or $contract.estimate_contract_id -ne $script:EstimateContractId) {
        throw "R16 context budget estimate contract identity is incorrect."
    }
    if ($contract.source_milestone -ne $script:R16Milestone -or $contract.source_task -ne "R16-016" -or $contract.repository -ne $script:Repository -or $contract.branch -ne $script:Branch) {
        throw "R16 context budget estimate contract source metadata is incorrect."
    }
    if ($contract.generated_from_head -ne $script:InputHead -or $contract.generated_from_tree -ne $script:InputTree) {
        throw "R16 context budget estimate contract generated_from head/tree must preserve the R16-016 baseline."
    }

    $dependencyRefs = Assert-ObjectArray -Value $contract.dependency_refs -Context "R16 context budget estimate contract dependency_refs"
    $dependencyPaths = @($dependencyRefs | Sort-Object -Property deterministic_order | ForEach-Object { [string]$_.path })
    Assert-ExactStringSet -Actual $dependencyPaths -Expected @(
        "contracts/context/r16_context_load_plan.contract.json",
        "state/context/r16_context_load_plan.json",
        "tools/R16ContextLoadPlanner.psm1",
        "tools/validate_r16_context_load_plan.ps1",
        "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_015_context_load_planner/proof_review.json",
        "state/proof_reviews/r16_operational_memory_artifact_map_role_workflow_foundation/r16_015_context_load_planner/validation_manifest.md"
    ) -Context "R16 context budget estimate contract dependency_refs"
    foreach ($ref in $dependencyRefs) {
        Assert-SafeRepoRelativePath -Path $ref.path -RepositoryRoot $resolvedRoot -Context "R16 context budget estimate contract dependency '$($ref.ref_id)'" -RequireLeaf | Out-Null
    }

    $estimateRequired = Assert-StringArray -Value $contract.estimate_schema.required_fields -Context "R16 context budget estimate contract estimate_schema.required_fields"
    Assert-RequiredStringsPresent -Actual $estimateRequired -Required $script:RequiredEstimateTopLevelFields -Context "R16 context budget estimate contract estimate_schema.required_fields"
    $itemRequired = Assert-StringArray -Value $contract.load_item_estimate_schema.required_fields -Context "R16 context budget estimate contract load_item_estimate_schema.required_fields"
    Assert-RequiredStringsPresent -Actual $itemRequired -Required $script:RequiredLoadItemEstimateFields -Context "R16 context budget estimate contract load_item_estimate_schema.required_fields"

    Assert-TrueField -Object $contract.approximation_policy -Field "deterministic_local_file_metrics_required" -Context "R16 context budget estimate contract approximation_policy"
    Assert-TrueField -Object $contract.approximation_policy -Field "rough_token_ranges_allowed" -Context "R16 context budget estimate contract approximation_policy"
    Assert-FalseFields -Object $contract.approximation_policy -Fields @("network_access_allowed", "provider_tokenizer_allowed", "provider_pricing_allowed") -Context "R16 context budget estimate contract approximation_policy"
    Assert-FalseFields -Object $contract.no_exact_provider_claim_policy -Fields @("exact_provider_token_counts_allowed", "exact_provider_tokenization_claims_allowed", "exact_provider_billing_claims_allowed", "exact_provider_pricing_claims_allowed") -Context "R16 context budget estimate contract no_exact_provider_claim_policy"
    Assert-FalseFields -Object $contract.validation_policy -Fields @("over_budget_fail_closed_validation_implemented") -Context "R16 context budget estimate contract validation_policy"

    $posture = Assert-ObjectValue -Value $contract.current_posture -Context "R16 context budget estimate contract current_posture"
    if ($posture.active_through_task -ne "R16-016") {
        throw "R16 context budget estimate contract current_posture active_through_task must be R16-016."
    }
    Assert-ExactStringSet -Actual (Assert-StringArray -Value $posture.complete_tasks -Context "R16 context budget estimate contract current_posture complete_tasks") -Expected $script:CompleteTasks -Context "R16 context budget estimate contract current_posture complete_tasks"
    Assert-ExactStringSet -Actual (Assert-StringArray -Value $posture.planned_tasks -Context "R16 context budget estimate contract current_posture planned_tasks") -Expected $script:PlannedTasks -Context "R16 context budget estimate contract current_posture planned_tasks"
    Assert-FalseFields -Object $posture -Fields @("r16_017_or_later_implementation_claimed", "r16_027_or_later_task_exists") -Context "R16 context budget estimate contract current_posture"

    Assert-PreservedBoundaries -Boundaries $contract.preserved_boundaries -Context "R16 context budget estimate contract preserved_boundaries"
    $nonClaims = Assert-StringArray -Value $contract.non_claims -Context "R16 context budget estimate contract non_claims"
    Assert-RequiredStringsPresent -Actual $nonClaims -Required $script:RequiredNonClaims -Context "R16 context budget estimate contract non_claims"
    Assert-NoOverclaimsInStrings -Object $contract -Context "R16 context budget estimate contract"

    return [pscustomobject]@{
        ContractId = $contract.estimate_contract_id
        ActiveThroughTask = $posture.active_through_task
        PlannedTaskStart = $posture.planned_tasks[0]
        PlannedTaskEnd = $posture.planned_tasks[-1]
        DependencyRefCount = $dependencyRefs.Count
    }
}

function Assert-PreservedBoundaries {
    param(
        [Parameter(Mandatory = $true)]$Boundaries,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $boundaryObject = Assert-ObjectValue -Value $Boundaries -Context $Context
    $r13 = Assert-ObjectValue -Value (Get-RequiredProperty -Object $boundaryObject -Name "r13" -Context $Context) -Context "$Context r13"
    $r14 = Assert-ObjectValue -Value (Get-RequiredProperty -Object $boundaryObject -Name "r14" -Context $Context) -Context "$Context r14"
    $r15 = Assert-ObjectValue -Value (Get-RequiredProperty -Object $boundaryObject -Name "r15" -Context $Context) -Context "$Context r15"

    if ($r13.status -ne "failed_partial_through_r13_018_only") {
        throw "$Context r13 status must preserve failed_partial_through_r13_018_only."
    }
    Assert-FalseFields -Object $r13 -Fields @("closed", "partial_gates_converted_to_passed") -Context "$Context r13"
    if ((Assert-BooleanValue -Value $r13.partial_gates_remain_partial -Context "$Context r13 partial_gates_remain_partial") -ne $true) {
        throw "$Context r13 partial_gates_remain_partial must be True."
    }
    if ($r14.status -ne "accepted_with_caveats_through_r14_006_only") {
        throw "$Context r14 status must preserve accepted_with_caveats_through_r14_006_only."
    }
    Assert-FalseFields -Object $r14 -Fields @("caveats_removed") -Context "$Context r14"
    if ($r15.status -ne "accepted_with_caveats_through_r15_009_only") {
        throw "$Context r15 status must preserve accepted_with_caveats_through_r15_009_only."
    }
    Assert-FalseFields -Object $r15 -Fields @("caveats_removed") -Context "$Context r15"
    Assert-TrueField -Object $r15 -Field "stale_generated_from_caveat_preserved" -Context "$Context r15"
}

function New-R16ContextBudgetEstimateObject {
    [CmdletBinding()]
    param(
        [string]$ContextLoadPlanPath = "state/context/r16_context_load_plan.json",
        [string]$ContractPath = "contracts/context/r16_context_budget_estimate.contract.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    Test-R16ContextBudgetEstimateContract -Path $ContractPath -RepositoryRoot $resolvedRoot | Out-Null
    Test-R16ContextLoadPlan -Path $ContextLoadPlanPath -RepositoryRoot $resolvedRoot | Out-Null

    $resolvedPlanPath = Assert-SafeRepoRelativePath -Path $ContextLoadPlanPath -RepositoryRoot $resolvedRoot -Context "context_load_plan_ref path" -RequireLeaf -RequireTracked
    $plan = Read-SingleJsonObject -Path $resolvedPlanPath -Label "R16 context-load plan"
    $loadItems = @(Get-ContextLoadPlanItems -Plan $plan -RepositoryRoot $resolvedRoot)

    $loadItemEstimates = @()
    $totalBytes = [int64]0
    $totalLines = [int64]0
    $tokenLower = [int64]0
    $tokenUpper = [int64]0
    $order = 0

    foreach ($item in $loadItems) {
        $order += 1
        $path = ConvertTo-NormalizedRepoPath -Path ([string]$item.path)
        $resolvedItemPath = Assert-SafeRepoRelativePath -Path $path -RepositoryRoot $resolvedRoot -Context "load item estimate '$($item.item_id)'" -RequireLeaf -RequireTracked
        $byteCount = [int64]([System.IO.FileInfo]::new($resolvedItemPath).Length)
        $lineCount = [int64](Get-LineCount -Path $resolvedItemPath)
        $bounds = Get-TokenEstimateBounds -ByteCount $byteCount

        $totalBytes += $byteCount
        $totalLines += $lineCount
        $tokenLower += [int64]$bounds.Lower
        $tokenUpper += [int64]$bounds.Upper

        $loadItemEstimates += [ordered]@{
            estimate_item_id = "estimate_item_{0}" -f $order.ToString("000")
            load_item_id = [string]$item.item_id
            path = $path
            exists = $true
            byte_count = $byteCount
            line_count = $lineCount
            estimated_tokens_lower_bound = [int64]$bounds.Lower
            estimated_tokens_upper_bound = [int64]$bounds.Upper
            approximate_cost_proxy_lower_units = [int64][math]::Ceiling([int64]$bounds.Lower / 1000)
            approximate_cost_proxy_upper_units = [int64][math]::Ceiling([int64]$bounds.Upper / 1000)
            cost_proxy_basis = "ceil(estimated_tokens / 1000) relative units; not currency and not provider billing"
            estimate_basis = "deterministic local file byte_count and line_count; token range is approximate, not exact provider tokenization"
            exact_provider_token_count_claimed = $false
            exact_provider_billing_claimed = $false
            deterministic_order = $order
        }
    }

    $uniqueFileCount = @($loadItemEstimates | ForEach-Object { [string]$_.path } | Sort-Object -Unique).Count
    $budgetCategory = Get-BudgetCategory -UpperBound $tokenUpper

    return [ordered]@{
        artifact_type = "r16_context_budget_estimate"
        estimate_version = "v1"
        estimate_id = $script:EstimateId
        source_milestone = $script:R16Milestone
        source_task = "R16-016"
        repository = $script:Repository
        branch = $script:Branch
        generation_boundary = [ordered]@{
            input_head = $script:InputHead
            input_tree = $script:InputTree
        }
        context_load_plan_ref = [ordered]@{
            path = (ConvertTo-NormalizedRepoPath -Path $ContextLoadPlanPath)
            source_task = "R16-015"
            loaded_and_validated = $true
        }
        estimate_mode = [ordered]@{
            context_budget_estimator_implemented = $true
            estimate_is_approximate = $true
            exact_provider_token_count_claimed = $false
            exact_provider_billing_claimed = $false
            over_budget_fail_closed_validator_implemented = $false
            runtime_memory_implemented = $false
            runtime_memory_loading_implemented = $false
            retrieval_runtime_implemented = $false
            vector_search_runtime_implemented = $false
            product_runtime_implemented = $false
            actual_autonomous_agents_implemented = $false
            true_multi_agent_execution_implemented = $false
            external_integrations_implemented = $false
            role_run_envelope_implemented = $false
            raci_transition_gate_implemented = $false
            handoff_packet_implemented = $false
            workflow_drill_run = $false
            solved_codex_compaction = $false
            solved_codex_reliability = $false
        }
        estimation_method = [ordered]@{
            deterministic_local_file_metrics = $true
            exact_paths_only = $true
            broad_repo_scan_used = $false
            full_repo_scan_used = $false
            approximate_token_formula_documented = $true
            approximate_token_formula = "lower_bound = ceil(byte_count / 5); upper_bound = ceil(byte_count / 3)"
            exact_provider_tokenizer_used = $false
            exact_provider_pricing_used = $false
            billing_estimate_is_not_provider_bill = $true
            cost_proxy_is_not_currency = $true
        }
        summary_estimates = [ordered]@{
            load_item_count = [int64]$loadItemEstimates.Count
            exact_file_count = [int64]$uniqueFileCount
            total_bytes = $totalBytes
            total_lines = $totalLines
            estimated_tokens_lower_bound = $tokenLower
            estimated_tokens_upper_bound = $tokenUpper
            estimated_ref_count = [int64]($loadItemEstimates.Count + 1)
            approximate_cost_proxy_lower_units = [int64][math]::Ceiling($tokenLower / 1000)
            approximate_cost_proxy_upper_units = [int64][math]::Ceiling($tokenUpper / 1000)
            cost_proxy_basis = "ceil(estimated_tokens / 1000) relative units; not currency and not provider billing"
            budget_category = $budgetCategory
            budget_rationale = "Category is based on approximate estimated_tokens_upper_bound from deterministic local byte counts; it is not exact provider tokenization or provider billing."
        }
        load_item_estimates = @($loadItemEstimates)
        current_posture = [ordered]@{
            active_through_task = "R16-016"
            complete_tasks = $script:CompleteTasks
            planned_tasks = $script:PlannedTasks
            r16_017_or_later_implementation_claimed = $false
            r16_027_or_later_task_exists = $false
        }
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
        accepted_caveats = @(
            [ordered]@{
                caveat_id = "r15_final_proof_review_package_stale_generated_from"
                caveat_type = "stale_generated_from_ref_preserved"
                path = "state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/r15_009_final_proof_review_package/r15_final_proof_review_package.json"
                deterministic_order = 1
            },
            [ordered]@{
                caveat_id = "r15_evidence_index_stale_generated_from"
                caveat_type = "stale_generated_from_ref_preserved"
                path = "state/proof_reviews/r15_knowledge_base_agent_identity_memory_and_raci_foundations/r15_009_final_proof_review_package/evidence_index.json"
                deterministic_order = 2
            }
        )
        validation_findings = @(
            [ordered]@{
                finding_id = "deterministic_local_file_metrics_estimated"
                severity = "pass"
                message = "All context-load plan load items were measured by deterministic local byte and line counts."
                deterministic_order = 1
            },
            [ordered]@{
                finding_id = "accepted_r15_stale_generated_from_caveats_preserved"
                severity = "warning"
                message = "Accepted R15 stale generated_from caveats are preserved as caveats, not removed."
                deterministic_order = 2
            }
        )
        finding_summary = [ordered]@{
            pass_count = 1
            warning_count = 2
            fail_count = 0
            open_violation_count = 0
        }
        aggregate_verdict = "passed_with_caveats"
        validation_commands = @(
            [ordered]@{
                command_id = "new_r16_context_budget_estimate"
                command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools/new_r16_context_budget_estimate.ps1"
                expected_result = "PASS"
                validates_path = "state/context/r16_context_budget_estimate.json"
                deterministic_order = 1
            },
            [ordered]@{
                command_id = "validate_r16_context_budget_estimate"
                command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_context_budget_estimate.ps1"
                expected_result = "PASS"
                validates_path = "state/context/r16_context_budget_estimate.json"
                deterministic_order = 2
            },
            [ordered]@{
                command_id = "test_r16_context_budget_estimator"
                command = "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_context_budget_estimator.ps1"
                expected_result = "PASS"
                validates_path = "tests/test_r16_context_budget_estimator.ps1"
                deterministic_order = 3
            }
        )
        non_claims = @(
            "no exact provider token count",
            "no exact provider billing",
            "no over-budget fail-closed validator",
            "no role-run envelope",
            "no RACI transition gate",
            "no handoff packet",
            "no workflow drill",
            "no product runtime",
            "no runtime memory",
            "no retrieval runtime",
            "no vector search runtime",
            "no autonomous agents",
            "no external integrations",
            "no solved Codex compaction",
            "no solved Codex reliability",
            "state/context/r16_context_budget_estimate.json is a committed generated context budget estimate state artifact only",
            "the estimate is approximate only",
            "the estimate is not exact provider tokenization",
            "the estimate is not exact provider billing",
            "the estimate is not an over-budget fail-closed validator",
            "R16-017 through R16-026 remain planned only"
        )
    }
}

function Test-R16ContextBudgetEstimateObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Estimate,
        [string]$SourceLabel = "R16 context budget estimate",
        [string]$RepositoryRoot = $repoRoot,
        [string]$ContractPath = "contracts/context/r16_context_budget_estimate.contract.json"
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    Test-R16ContextBudgetEstimateContract -Path $ContractPath -RepositoryRoot $resolvedRoot | Out-Null

    foreach ($field in $script:RequiredEstimateTopLevelFields) {
        Get-RequiredProperty -Object $Estimate -Name $field -Context $SourceLabel | Out-Null
    }

    if ($Estimate.artifact_type -ne "r16_context_budget_estimate" -or $Estimate.estimate_version -ne "v1" -or $Estimate.estimate_id -ne $script:EstimateId) {
        throw "$SourceLabel estimate identity is incorrect."
    }
    if ($Estimate.source_milestone -ne $script:R16Milestone -or $Estimate.source_task -ne "R16-016" -or $Estimate.repository -ne $script:Repository -or $Estimate.branch -ne $script:Branch) {
        throw "$SourceLabel source metadata is incorrect."
    }

    $boundary = Assert-ObjectValue -Value $Estimate.generation_boundary -Context "$SourceLabel generation_boundary"
    if ($boundary.input_head -ne $script:InputHead -or $boundary.input_tree -ne $script:InputTree) {
        throw "$SourceLabel generation_boundary must preserve the R16-016 input head and tree."
    }

    $planRef = Assert-ObjectValue -Value $Estimate.context_load_plan_ref -Context "$SourceLabel context_load_plan_ref"
    if ($planRef.path -ne "state/context/r16_context_load_plan.json" -or $planRef.source_task -ne "R16-015") {
        throw "$SourceLabel context_load_plan_ref must point to state/context/r16_context_load_plan.json from R16-015."
    }
    Assert-TrueField -Object $planRef -Field "loaded_and_validated" -Context "$SourceLabel context_load_plan_ref"
    $resolvedPlanPath = Assert-SafeRepoRelativePath -Path $planRef.path -RepositoryRoot $resolvedRoot -Context "$SourceLabel context_load_plan_ref" -RequireLeaf -RequireTracked
    Test-R16ContextLoadPlan -Path $planRef.path -RepositoryRoot $resolvedRoot | Out-Null
    $plan = Read-SingleJsonObject -Path $resolvedPlanPath -Label "R16 context-load plan"
    $planItems = @(Get-ContextLoadPlanItems -Plan $plan -RepositoryRoot $resolvedRoot)

    $mode = Assert-ObjectValue -Value $Estimate.estimate_mode -Context "$SourceLabel estimate_mode"
    Assert-TrueField -Object $mode -Field "context_budget_estimator_implemented" -Context "$SourceLabel estimate_mode"
    Assert-TrueField -Object $mode -Field "estimate_is_approximate" -Context "$SourceLabel estimate_mode"
    Assert-FalseFields -Object $mode -Fields $script:RequiredFalseEstimateModeFields -Context "$SourceLabel estimate_mode"

    $method = Assert-ObjectValue -Value $Estimate.estimation_method -Context "$SourceLabel estimation_method"
    foreach ($trueField in @("deterministic_local_file_metrics", "exact_paths_only", "approximate_token_formula_documented", "billing_estimate_is_not_provider_bill", "cost_proxy_is_not_currency")) {
        Assert-TrueField -Object $method -Field $trueField -Context "$SourceLabel estimation_method"
    }
    Assert-FalseFields -Object $method -Fields @("broad_repo_scan_used", "full_repo_scan_used", "exact_provider_tokenizer_used", "exact_provider_pricing_used") -Context "$SourceLabel estimation_method"
    if ($method.approximate_token_formula -ne "lower_bound = ceil(byte_count / 5); upper_bound = ceil(byte_count / 3)") {
        throw "$SourceLabel approximate_token_formula must document the deterministic approximation formula."
    }

    $estimates = Assert-ObjectArray -Value $Estimate.load_item_estimates -Context "$SourceLabel load_item_estimates"
    if ($estimates.Count -ne $planItems.Count) {
        throw "$SourceLabel load_item_estimates count must match the context-load plan load item count."
    }

    $totalBytes = [int64]0
    $totalLines = [int64]0
    $tokenLower = [int64]0
    $tokenUpper = [int64]0
    $uniquePaths = @{}

    for ($index = 0; $index -lt $estimates.Count; $index += 1) {
        $itemEstimate = Assert-ObjectValue -Value $estimates[$index] -Context "$SourceLabel load_item_estimates[$index]"
        foreach ($field in $script:RequiredLoadItemEstimateFields) {
            Get-RequiredProperty -Object $itemEstimate -Name $field -Context "$SourceLabel load_item_estimates[$index]" | Out-Null
        }

        $expectedOrder = $index + 1
        if ((Assert-IntegerValue -Value $itemEstimate.deterministic_order -Context "$SourceLabel load_item_estimates[$index] deterministic_order") -ne $expectedOrder) {
            throw "$SourceLabel load_item_estimates[$index] deterministic_order must be $expectedOrder."
        }
        if ($itemEstimate.estimate_item_id -ne ("estimate_item_{0}" -f $expectedOrder.ToString("000"))) {
            throw "$SourceLabel load_item_estimates[$index] estimate_item_id is not deterministic."
        }

        $planItem = $planItems[$index]
        if ($itemEstimate.load_item_id -ne $planItem.item_id) {
            throw "$SourceLabel load_item_estimates[$index] load_item_id must match the context-load plan item."
        }
        Assert-TrueField -Object $itemEstimate -Field "exists" -Context "$SourceLabel load_item_estimates[$index]"
        Assert-FalseFields -Object $itemEstimate -Fields @("exact_provider_token_count_claimed", "exact_provider_billing_claimed") -Context "$SourceLabel load_item_estimates[$index]"

        $resolvedItemPath = Assert-SafeRepoRelativePath -Path $itemEstimate.path -RepositoryRoot $resolvedRoot -Context "$SourceLabel load_item_estimates[$index]" -RequireLeaf -RequireTracked
        if ($itemEstimate.path -ne (ConvertTo-NormalizedRepoPath -Path ([string]$planItem.path))) {
            throw "$SourceLabel load_item_estimates[$index] path must match the context-load plan item path."
        }
        $actualBytes = [int64]([System.IO.FileInfo]::new($resolvedItemPath).Length)
        $actualLines = [int64](Get-LineCount -Path $resolvedItemPath)
        $bounds = Get-TokenEstimateBounds -ByteCount $actualBytes

        if ((Assert-IntegerValue -Value $itemEstimate.byte_count -Context "$SourceLabel load_item_estimates[$index] byte_count") -ne $actualBytes) {
            throw "$SourceLabel load_item_estimates[$index] byte_count must match deterministic local file metrics."
        }
        if ((Assert-IntegerValue -Value $itemEstimate.line_count -Context "$SourceLabel load_item_estimates[$index] line_count") -ne $actualLines) {
            throw "$SourceLabel load_item_estimates[$index] line_count must match deterministic local file metrics."
        }
        if ((Assert-IntegerValue -Value $itemEstimate.estimated_tokens_lower_bound -Context "$SourceLabel load_item_estimates[$index] estimated_tokens_lower_bound") -ne $bounds.Lower) {
            throw "$SourceLabel load_item_estimates[$index] estimated_tokens_lower_bound must match the approximate formula."
        }
        if ((Assert-IntegerValue -Value $itemEstimate.estimated_tokens_upper_bound -Context "$SourceLabel load_item_estimates[$index] estimated_tokens_upper_bound") -ne $bounds.Upper) {
            throw "$SourceLabel load_item_estimates[$index] estimated_tokens_upper_bound must match the approximate formula."
        }
        if ($itemEstimate.estimate_basis -notmatch "approximate" -or $itemEstimate.estimate_basis -notmatch "not exact provider tokenization") {
            throw "$SourceLabel load_item_estimates[$index] estimate_basis must label token values as approximate and not exact provider tokenization."
        }

        $totalBytes += $actualBytes
        $totalLines += $actualLines
        $tokenLower += [int64]$bounds.Lower
        $tokenUpper += [int64]$bounds.Upper
        $uniquePaths[(ConvertTo-NormalizedRepoPath -Path ([string]$itemEstimate.path))] = $true
    }

    $summary = Assert-ObjectValue -Value $Estimate.summary_estimates -Context "$SourceLabel summary_estimates"
    if ((Assert-IntegerValue -Value $summary.load_item_count -Context "$SourceLabel summary_estimates load_item_count") -ne $estimates.Count) {
        throw "$SourceLabel summary_estimates load_item_count must match load_item_estimates."
    }
    if ((Assert-IntegerValue -Value $summary.exact_file_count -Context "$SourceLabel summary_estimates exact_file_count") -ne $uniquePaths.Keys.Count) {
        throw "$SourceLabel summary_estimates exact_file_count must match unique exact files."
    }
    if ((Assert-IntegerValue -Value $summary.total_bytes -Context "$SourceLabel summary_estimates total_bytes") -ne $totalBytes) {
        throw "$SourceLabel summary_estimates total_bytes must match deterministic local file metrics."
    }
    if ((Assert-IntegerValue -Value $summary.total_lines -Context "$SourceLabel summary_estimates total_lines") -ne $totalLines) {
        throw "$SourceLabel summary_estimates total_lines must match deterministic local file metrics."
    }
    if ((Assert-IntegerValue -Value $summary.estimated_tokens_lower_bound -Context "$SourceLabel summary_estimates estimated_tokens_lower_bound") -ne $tokenLower) {
        throw "$SourceLabel summary_estimates estimated_tokens_lower_bound must match item totals."
    }
    if ((Assert-IntegerValue -Value $summary.estimated_tokens_upper_bound -Context "$SourceLabel summary_estimates estimated_tokens_upper_bound") -ne $tokenUpper) {
        throw "$SourceLabel summary_estimates estimated_tokens_upper_bound must match item totals."
    }
    if ((Assert-IntegerValue -Value $summary.estimated_ref_count -Context "$SourceLabel summary_estimates estimated_ref_count") -ne ($estimates.Count + 1)) {
        throw "$SourceLabel summary_estimates estimated_ref_count must include load items plus the context-load plan ref."
    }
    if ($summary.budget_category -ne (Get-BudgetCategory -UpperBound $tokenUpper)) {
        throw "$SourceLabel summary_estimates budget_category must match deterministic category policy."
    }
    if ($summary.budget_rationale -notmatch "approximate" -or $summary.budget_rationale -notmatch "not exact provider tokenization" -or $summary.budget_rationale -notmatch "provider billing") {
        throw "$SourceLabel summary_estimates budget_rationale must label token/cost values as approximate and not provider billing."
    }

    $posture = Assert-ObjectValue -Value $Estimate.current_posture -Context "$SourceLabel current_posture"
    if ($posture.active_through_task -ne "R16-016") {
        throw "$SourceLabel current_posture active_through_task must be R16-016."
    }
    Assert-ExactStringSet -Actual (Assert-StringArray -Value $posture.complete_tasks -Context "$SourceLabel current_posture complete_tasks") -Expected $script:CompleteTasks -Context "$SourceLabel current_posture complete_tasks"
    Assert-ExactStringSet -Actual (Assert-StringArray -Value $posture.planned_tasks -Context "$SourceLabel current_posture planned_tasks") -Expected $script:PlannedTasks -Context "$SourceLabel current_posture planned_tasks"
    Assert-FalseFields -Object $posture -Fields @("r16_017_or_later_implementation_claimed", "r16_027_or_later_task_exists") -Context "$SourceLabel current_posture"

    Assert-PreservedBoundaries -Boundaries $Estimate.preserved_boundaries -Context "$SourceLabel preserved_boundaries"

    $findingSummary = Assert-ObjectValue -Value $Estimate.finding_summary -Context "$SourceLabel finding_summary"
    foreach ($field in @("fail_count", "open_violation_count")) {
        if ((Assert-IntegerValue -Value (Get-RequiredProperty -Object $findingSummary -Name $field -Context "$SourceLabel finding_summary") -Context "$SourceLabel finding_summary $field") -ne 0) {
            throw "$SourceLabel finding_summary $field must be 0."
        }
    }
    if ($Estimate.aggregate_verdict -notin @("passed", "passed_with_caveats")) {
        throw "$SourceLabel aggregate_verdict must be passed or passed_with_caveats."
    }

    $nonClaims = Assert-StringArray -Value $Estimate.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredStringsPresent -Actual $nonClaims -Required $script:RequiredNonClaims -Context "$SourceLabel non_claims"
    Assert-NoOverclaimsInStrings -Object $Estimate -Context $SourceLabel

    return [pscustomobject]@{
        EstimateId = $Estimate.estimate_id
        ActiveThroughTask = $Estimate.current_posture.active_through_task
        PlannedTaskStart = $Estimate.current_posture.planned_tasks[0]
        PlannedTaskEnd = $Estimate.current_posture.planned_tasks[-1]
        LoadItemCount = [int64]$summary.load_item_count
        ExactFileCount = [int64]$summary.exact_file_count
        TotalBytes = [int64]$summary.total_bytes
        TotalLines = [int64]$summary.total_lines
        EstimatedTokensLowerBound = [int64]$summary.estimated_tokens_lower_bound
        EstimatedTokensUpperBound = [int64]$summary.estimated_tokens_upper_bound
        BudgetCategory = [string]$summary.budget_category
        AggregateVerdict = [string]$Estimate.aggregate_verdict
    }
}

function Test-R16ContextBudgetEstimate {
    [CmdletBinding()]
    param(
        [string]$Path = "state/context/r16_context_budget_estimate.json",
        [string]$ContractPath = "contracts/context/r16_context_budget_estimate.contract.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedPath = Assert-SafeRepoRelativePath -Path $Path -RepositoryRoot $resolvedRoot -Context "R16 context budget estimate path" -RequireLeaf
    $estimate = Read-SingleJsonObject -Path $resolvedPath -Label "R16 context budget estimate"
    return Test-R16ContextBudgetEstimateObject -Estimate $estimate -SourceLabel $Path -RepositoryRoot $resolvedRoot -ContractPath $ContractPath
}

function New-R16ContextBudgetEstimate {
    [CmdletBinding()]
    param(
        [string]$OutputPath = "state/context/r16_context_budget_estimate.json",
        [string]$ContextLoadPlanPath = "state/context/r16_context_load_plan.json",
        [string]$ContractPath = "contracts/context/r16_context_budget_estimate.contract.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedOutput = Assert-SafeRepoRelativePath -Path $OutputPath -RepositoryRoot $resolvedRoot -Context "OutputPath"
    $estimate = New-R16ContextBudgetEstimateObject -ContextLoadPlanPath $ContextLoadPlanPath -ContractPath $ContractPath -RepositoryRoot $resolvedRoot
    Write-StableJsonFile -Object $estimate -Path $resolvedOutput
    $validation = Test-R16ContextBudgetEstimate -Path $OutputPath -ContractPath $ContractPath -RepositoryRoot $resolvedRoot

    return [pscustomobject]@{
        OutputPath = $OutputPath
        EstimateId = $validation.EstimateId
        ActiveThroughTask = $validation.ActiveThroughTask
        PlannedTaskStart = $validation.PlannedTaskStart
        PlannedTaskEnd = $validation.PlannedTaskEnd
        LoadItemCount = $validation.LoadItemCount
        ExactFileCount = $validation.ExactFileCount
        EstimatedTokensLowerBound = $validation.EstimatedTokensLowerBound
        EstimatedTokensUpperBound = $validation.EstimatedTokensUpperBound
        BudgetCategory = $validation.BudgetCategory
        AggregateVerdict = $validation.AggregateVerdict
    }
}

function New-R16ContextBudgetEstimatorFixtureFiles {
    [CmdletBinding()]
    param(
        [string]$FixtureRoot = "tests/fixtures/r16_context_budget_estimator",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedFixtureRoot = [System.IO.Path]::GetFullPath((Join-Path $resolvedRoot $FixtureRoot))
    New-Item -ItemType Directory -Path $resolvedFixtureRoot -Force | Out-Null

    $valid = New-R16ContextBudgetEstimateObject -RepositoryRoot $resolvedRoot
    Write-StableJsonFile -Object $valid -Path (Join-Path $resolvedFixtureRoot "valid_context_budget_estimate.json")

    $fixtureSpecs = [ordered]@{
        "invalid_missing_context_load_plan_ref.json" = {
            param($p)
            $p.PSObject.Properties.Remove("context_load_plan_ref")
        }
        "invalid_missing_load_item_path.json" = {
            param($p)
            $p.load_item_estimates[0].PSObject.Properties.Remove("path")
        }
        "invalid_wildcard_path.json" = {
            param($p)
            $p.load_item_estimates[0].path = "state/memory/*.json"
        }
        "invalid_broad_scan_claim.json" = {
            param($p)
            $p.estimation_method.broad_repo_scan_used = $true
        }
        "invalid_directory_only_ref.json" = {
            param($p)
            $p.load_item_estimates[0].path = "state/memory/"
        }
        "invalid_local_scratch_ref.json" = {
            param($p)
            $p.load_item_estimates[0].path = "scratch/r16_context_budget_estimate.tmp.json"
        }
        "invalid_remote_unverified_ref.json" = {
            param($p)
            $p.load_item_estimates[0].path = "https://example.invalid/context.json"
        }
        "invalid_exact_provider_token_claim.json" = {
            param($p)
            $p.estimate_mode.exact_provider_token_count_claimed = $true
        }
        "invalid_exact_provider_billing_claim.json" = {
            param($p)
            $p.estimate_mode.exact_provider_billing_claimed = $true
        }
        "invalid_over_budget_fail_closed_claim.json" = {
            param($p)
            $p.estimate_mode.over_budget_fail_closed_validator_implemented = $true
        }
        "invalid_runtime_memory_claim.json" = {
            param($p)
            $p.estimate_mode.runtime_memory_implemented = $true
        }
        "invalid_retrieval_runtime_claim.json" = {
            param($p)
            $p.estimate_mode.retrieval_runtime_implemented = $true
        }
        "invalid_vector_search_claim.json" = {
            param($p)
            $p.estimate_mode.vector_search_runtime_implemented = $true
        }
        "invalid_role_run_envelope_claim.json" = {
            param($p)
            $p.estimate_mode.role_run_envelope_implemented = $true
        }
        "invalid_raci_transition_gate_claim.json" = {
            param($p)
            $p.estimate_mode.raci_transition_gate_implemented = $true
        }
        "invalid_handoff_packet_claim.json" = {
            param($p)
            $p.estimate_mode.handoff_packet_implemented = $true
        }
        "invalid_workflow_drill_claim.json" = {
            param($p)
            $p.estimate_mode.workflow_drill_run = $true
        }
        "invalid_r16_017_claim.json" = {
            param($p)
            $p.current_posture.r16_017_or_later_implementation_claimed = $true
        }
        "invalid_r13_boundary_change.json" = {
            param($p)
            $p.preserved_boundaries.r13.closed = $true
        }
        "invalid_r14_caveat_removed.json" = {
            param($p)
            $p.preserved_boundaries.r14.caveats_removed = $true
        }
        "invalid_r15_caveat_removed.json" = {
            param($p)
            $p.preserved_boundaries.r15.caveats_removed = $true
        }
    }

    foreach ($name in $fixtureSpecs.Keys) {
        $fixture = Copy-JsonObject -Value $valid
        & $fixtureSpecs[$name] $fixture
        Write-StableJsonFile -Object $fixture -Path (Join-Path $resolvedFixtureRoot $name)
    }

    return [pscustomobject]@{
        FixtureRoot = $FixtureRoot
        ValidFixture = (Join-Path $FixtureRoot "valid_context_budget_estimate.json")
        InvalidFixtureCount = $fixtureSpecs.Count
    }
}

Export-ModuleMember -Function New-R16ContextBudgetEstimateObject, New-R16ContextBudgetEstimate, Test-R16ContextBudgetEstimateObject, Test-R16ContextBudgetEstimate, Test-R16ContextBudgetEstimateContract, New-R16ContextBudgetEstimatorFixtureFiles, ConvertTo-StableJson
