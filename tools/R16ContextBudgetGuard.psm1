Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$script:R16Milestone = "R16 Operational Memory, Artifact Map, and Role-Bound Workflow Foundation"
$script:Repository = "RodneyMuniz/AIOffice_V2"
$script:Branch = "release/r16-operational-memory-artifact-map-role-workflow-foundation"
$script:InputHead = "c2ffe362e2a98b7182c44fdd0f3b4e03f4594341"
$script:InputTree = "f5d37a08ee0933251661c02bf016295633fbd2c6"
$script:GuardContractId = "aioffice-r16-017-context-budget-guard-contract-v1"
$script:GuardId = "aioffice-r16-017-context-budget-guard-v1"
$script:DefaultMaxEstimatedTokensUpperBound = 150000
$script:CompleteTasks = [string[]](1..17 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })
$script:PlannedTasks = [string[]](18..26 | ForEach-Object { "R16-{0}" -f $_.ToString("000") })

$script:RequiredReportTopLevelFields = @(
    "artifact_type",
    "guard_version",
    "guard_id",
    "source_milestone",
    "source_task",
    "repository",
    "branch",
    "generation_boundary",
    "context_load_plan_ref",
    "context_budget_estimate_ref",
    "configured_budget_thresholds",
    "evaluated_budget",
    "guard_mode",
    "no_full_repo_scan_policy",
    "evaluated_load_items",
    "current_posture",
    "preserved_boundaries",
    "finding_summary",
    "aggregate_verdict",
    "validation_commands",
    "non_claims"
)

$script:RequiredNonClaims = @(
    "R16-017 adds bounded over-budget and no-full-repo-scan guard only",
    "no exact provider token count",
    "no exact provider tokenization",
    "no exact provider billing",
    "no exact provider pricing",
    "no runtime memory",
    "no retrieval runtime",
    "no vector search runtime",
    "no role-run envelope",
    "no RACI transition gate",
    "no handoff packet",
    "no workflow drill",
    "no product runtime",
    "no autonomous agents",
    "no external integrations",
    "no solved Codex compaction",
    "no solved Codex reliability",
    "R13 remains failed/partial and not closed",
    "R14 caveats remain preserved",
    "R15 caveats remain preserved",
    "R16-018 through R16-026 remain planned only"
)

$script:ForbiddenTrueBooleanClaims = @{
    "broad_repo_scan_allowed" = "broad/full repo scan claim"
    "broad_repo_scan_used" = "broad/full repo scan claim"
    "full_repo_scan_allowed" = "broad/full repo scan claim"
    "full_repo_scan_used" = "broad/full repo scan claim"
    "wildcard_allowed" = "wildcard path allowance claim"
    "wildcard_paths_allowed" = "wildcard path allowance claim"
    "directory_only_refs_allowed" = "directory-only path allowance claim"
    "directory_only_paths_allowed" = "directory-only path allowance claim"
    "local_scratch_refs_allowed" = "scratch/temp path allowance claim"
    "scratch_temp_paths_allowed" = "scratch/temp path allowance claim"
    "unverified_remote_refs_allowed" = "URL/remote ref allowance claim"
    "url_or_remote_refs_allowed" = "URL/remote ref allowance claim"
    "raw_chat_history_loading_allowed" = "raw chat history loading claim"
    "exact_provider_token_count_claimed" = "exact provider token count claim"
    "exact_provider_tokenizer_used" = "exact provider tokenization claim"
    "exact_provider_billing_claimed" = "exact provider billing claim"
    "exact_provider_pricing_used" = "exact provider billing claim"
    "runtime_memory_implemented" = "runtime memory claim"
    "runtime_memory_loading_implemented" = "runtime memory claim"
    "runtime_memory_loading_allowed" = "runtime memory claim"
    "retrieval_runtime_implemented" = "retrieval runtime claim"
    "retrieval_runtime_allowed" = "retrieval runtime claim"
    "vector_search_runtime_implemented" = "vector search runtime claim"
    "vector_search_runtime_allowed" = "vector search runtime claim"
    "product_runtime_implemented" = "product runtime claim"
    "productized_ui_implemented" = "product runtime claim"
    "actual_autonomous_agents_implemented" = "autonomous agent claim"
    "true_multi_agent_execution_implemented" = "autonomous agent claim"
    "external_integrations_implemented" = "external integration claim"
    "role_run_envelope_implemented" = "role-run envelope claim"
    "raci_transition_gate_implemented" = "RACI transition gate claim"
    "handoff_packet_implemented" = "handoff packet claim"
    "workflow_drill_run" = "workflow drill claim"
    "solved_codex_compaction" = "solved Codex compaction claim"
    "solved_codex_reliability" = "solved Codex reliability claim"
    "r16_018_or_later_implementation_claimed" = "R16-018 or later implementation claim"
    "r16_027_or_later_task_exists" = "R16-027 or later task claim"
    "r13_closure_claimed" = "R13 boundary change"
    "r14_caveat_removal_claimed" = "R14 caveat removal"
    "r15_caveat_removal_claimed" = "R15 caveat removal"
    "r13_partial_gate_conversion_claimed" = "R13 boundary change"
    "main_merge_completed" = "main merge claim"
}

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

function New-GuardFinding {
    param(
        [Parameter(Mandatory = $true)][string]$FindingId,
        [Parameter(Mandatory = $true)][string]$Severity,
        [Parameter(Mandatory = $true)][string]$Category,
        [Parameter(Mandatory = $true)][string]$Message,
        [AllowNull()]$Evidence,
        [Parameter(Mandatory = $true)][int]$Order
    )

    $finding = [ordered]@{
        finding_id = $FindingId
        severity = $Severity
        category = $Category
        message = $Message
        fail_closed = ($Severity -in @("fail", "blocker"))
        deterministic_order = $Order
    }

    if ($null -ne $Evidence) {
        $finding["evidence"] = $Evidence
    }

    return $finding
}

function Add-GuardFinding {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.Generic.List[object]]$Findings,
        [Parameter(Mandatory = $true)][hashtable]$Seen,
        [Parameter(Mandatory = $true)][string]$FindingId,
        [Parameter(Mandatory = $true)][string]$Severity,
        [Parameter(Mandatory = $true)][string]$Category,
        [Parameter(Mandatory = $true)][string]$Message,
        [AllowNull()]$Evidence
    )

    $dedupeKey = "$FindingId|$Message"
    if ($Seen.ContainsKey($dedupeKey)) {
        return
    }

    $Seen[$dedupeKey] = $true
    $finding = New-GuardFinding -FindingId $FindingId -Severity $Severity -Category $Category -Message $Message -Evidence $Evidence -Order ($Findings.Count + 1)
    $null = $Findings.Add($finding)
}

function Test-BroadRepoRootPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    $normalized = (ConvertTo-NormalizedRepoPath -Path $Path).ToLowerInvariant()
    return [string]::IsNullOrWhiteSpace($normalized) -or $normalized -in @(
        ".",
        "./",
        "/",
        "\",
        "repo",
        "repository",
        "full_repo",
        "entire_repo",
        "all",
        "all_files",
        "**",
        "**/*"
    )
}

function Test-WildcardPath {
    param([Parameter(Mandatory = $true)][string]$Path)
    return $Path -match '[\*\?\[\]]'
}

function Test-LocalScratchPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    $normalized = (ConvertTo-NormalizedRepoPath -Path $Path).ToLowerInvariant()
    return $normalized -match '^(\.tmp|\.temp|scratch|tmp|temp|state/temp|state/tmp|state/scratch)(/|$)'
}

function Test-RemoteOrUrlRef {
    param([Parameter(Mandatory = $true)][string]$Path)

    $normalized = ConvertTo-NormalizedRepoPath -Path $Path
    return $normalized -match '^[A-Za-z][A-Za-z0-9+.-]*://' -or
        $normalized -match '^git@' -or
        $normalized -match '^(origin|upstream|refs)/' -or
        $normalized -match '^[A-Za-z0-9_.-]+:'
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

    if ([System.IO.Path]::IsPathRooted($normalized) -or $normalized -match '(^|/)\.\.(/|$)' -or (Test-RemoteOrUrlRef -Path $normalized)) {
        return $false
    }

    $resolved = [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $normalized))
    return (Test-Path -LiteralPath $resolved -PathType Container)
}

function Test-GitTrackedPath {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    $normalized = ConvertTo-NormalizedRepoPath -Path $Path
    $null = & git -C $RepositoryRoot ls-files --error-unmatch -- $normalized 2>$null
    return $LASTEXITCODE -eq 0
}

function Get-RepoPathPolicyEvaluation {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot,
        [string]$PathContext = "path"
    )

    $normalized = ConvertTo-NormalizedRepoPath -Path $Path
    $reasons = New-Object System.Collections.Generic.List[string]

    if (Test-BroadRepoRootPath -Path $normalized) {
        $null = $reasons.Add("broad_or_full_repo_scan_ref")
    }
    if (Test-WildcardPath -Path $normalized) {
        $null = $reasons.Add("wildcard_path")
    }
    if ([System.IO.Path]::IsPathRooted($normalized)) {
        $null = $reasons.Add("absolute_path")
    }
    if ($normalized -match '(^|/)\.\.(/|$)') {
        $null = $reasons.Add("parent_traversal_path")
    }
    if (Test-RemoteOrUrlRef -Path $normalized) {
        $null = $reasons.Add("url_or_remote_ref")
    }
    if (Test-LocalScratchPath -Path $normalized) {
        $null = $reasons.Add("scratch_temp_path")
    }
    if ($reasons.Count -eq 0 -and (Test-DirectoryOnlyPath -Path $normalized -RepositoryRoot $RepositoryRoot)) {
        $null = $reasons.Add("directory_only_path")
    }

    $exists = $false
    $isLeaf = $false
    $tracked = $false
    if ($reasons.Count -eq 0) {
        $resolved = [System.IO.Path]::GetFullPath((Join-Path $RepositoryRoot $normalized))
        $root = [System.IO.Path]::GetFullPath($RepositoryRoot)
        if (-not $resolved.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
            $null = $reasons.Add("outside_repository")
        }
        else {
            $exists = Test-Path -LiteralPath $resolved
            $isLeaf = Test-Path -LiteralPath $resolved -PathType Leaf
            if (-not $isLeaf) {
                $null = $reasons.Add("not_exact_file_path")
            }
            $tracked = Test-GitTrackedPath -Path $normalized -RepositoryRoot $RepositoryRoot
            if (-not $tracked) {
                $null = $reasons.Add("untracked_path")
            }
        }
    }

    return [pscustomobject]@{
        path_context = $PathContext
        path = $Path
        normalized_path = $normalized
        exact_repo_relative_tracked_file = ($reasons.Count -eq 0)
        exists = $exists
        is_leaf = $isLeaf
        tracked = $tracked
        invalid_reasons = [string[]]$reasons
    }
}

function Get-ObjectPathFields {
    [CmdletBinding()]
    param(
        [AllowNull()]$Value,
        [string]$Context = "root"
    )

    if ($null -eq $Value -or $Value -is [string]) {
        return
    }

    if ($Value -is [System.Collections.IDictionary]) {
        foreach ($key in $Value.Keys) {
            $childContext = "$Context.$key"
            if ($key -eq "path" -and $Value[$key] -is [string]) {
                $PSCmdlet.WriteObject([pscustomobject]@{
                    Context = $childContext
                    Path = [string]$Value[$key]
                }, $false)
            }
            Get-ObjectPathFields -Value $Value[$key] -Context $childContext
        }
        return
    }

    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
        $arrayIndex = 0
        foreach ($item in $Value) {
            Get-ObjectPathFields -Value $item -Context "$Context[$arrayIndex]"
            $arrayIndex += 1
        }
        return
    }

    if ($Value.PSObject -and $Value.PSObject.Properties) {
        foreach ($property in $Value.PSObject.Properties) {
            $childContext = "$Context.$($property.Name)"
            if ($property.Name -eq "path" -and $property.Value -is [string]) {
                $PSCmdlet.WriteObject([pscustomobject]@{
                    Context = $childContext
                    Path = [string]$property.Value
                }, $false)
            }
            Get-ObjectPathFields -Value $property.Value -Context $childContext
        }
    }
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

    return $Text -match '(?i)\b(no|not|without|does not|do not|must not|never|non-claim|non_claim|false|planned only|not implemented|not claimed|approximate|approximation|not exact|not provider|non-provider|not currency|rejected|rejects|fail closed|fail-closed|blocked|guard only|only)\b'
}

function Add-ForbiddenStringClaimFindings {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.Generic.List[object]]$Findings,
        [Parameter(Mandatory = $true)][hashtable]$Seen,
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Context
    )

    $claimPatterns = @(
        @{ Id = "exact_provider_token_claim"; Label = "exact provider token count"; Pattern = '(?i)\b(exact provider token count|exact provider tokenization|exact provider tokenizer|provider tokenizer used|exact tokenizer)\b' },
        @{ Id = "exact_provider_billing_claim"; Label = "exact provider billing"; Pattern = '(?i)\b(exact provider billing|exact provider bill|provider bill|provider billing|provider pricing used|exact provider pricing)\b' },
        @{ Id = "broad_repo_scan_claim"; Label = "broad repo scan"; Pattern = '(?i)\b(broad repo scan|broad repository scan|scan the repo|scan whole repo|load whole repo)\b' },
        @{ Id = "full_repo_scan_claim"; Label = "full repo scan"; Pattern = '(?i)\b(full repo scan|full repository scan|entire repo|whole repository|load full repo|load entire repo)\b' },
        @{ Id = "raw_chat_history_claim"; Label = "raw chat history loading"; Pattern = '(?i)\b(raw chat history|entire chat history|full chat transcript)\b.{0,160}\b(load|loaded|loading|carry|carried|include|included)\b' },
        @{ Id = "runtime_memory_claim"; Label = "runtime memory"; Pattern = '(?i)\b(runtime memory|runtime memory loading|persistent memory runtime|persistent memory engine)\b.{0,160}\b(implemented|exists|created|claimed|complete|runtime|loads)\b' },
        @{ Id = "retrieval_runtime_claim"; Label = "retrieval runtime"; Pattern = '(?i)\b(retrieval runtime|retrieval engine|runtime retrieval)\b.{0,160}\b(implemented|exists|created|claimed|complete)\b' },
        @{ Id = "vector_search_claim"; Label = "vector search runtime"; Pattern = '(?i)\b(vector search runtime|runtime vector search|vector search)\b.{0,160}\b(implemented|exists|created|claimed|complete)\b' },
        @{ Id = "role_run_envelope_claim"; Label = "role-run envelope"; Pattern = '(?i)\b(role-run envelope|role run envelope)\b.{0,160}\b(implemented|exists|created|claimed|complete)\b' },
        @{ Id = "raci_transition_gate_claim"; Label = "RACI transition gate"; Pattern = '(?i)\b(RACI transition gate|RACI transition gates)\b.{0,160}\b(implemented|exists|created|claimed|complete)\b' },
        @{ Id = "handoff_packet_claim"; Label = "handoff packet"; Pattern = '(?i)\b(handoff packet|handoff packets)\b.{0,160}\b(implemented|exists|created|claimed|complete)\b' },
        @{ Id = "workflow_drill_claim"; Label = "workflow drill"; Pattern = '(?i)\b(workflow drill|workflow drills)\b.{0,160}\b(implemented|exists|created|claimed|complete|ran)\b' },
        @{ Id = "product_runtime_claim"; Label = "product runtime"; Pattern = '(?i)\b(product runtime|production runtime|productized UI|productized control-room behavior|full UI app)\b' },
        @{ Id = "autonomous_agent_claim"; Label = "autonomous agents"; Pattern = '(?i)\b(actual autonomous agents|actual agents implemented|true multi-agent execution|true multi-agent runtime|multi-agent runtime|agent runtime)\b' },
        @{ Id = "external_integration_claim"; Label = "external integrations"; Pattern = '(?i)\b(GitHub Projects integration|Linear integration|Symphony integration|custom board integration|external board sync|external integration)\b' },
        @{ Id = "r16_018_claim"; Label = "R16-018 or later implementation"; Pattern = '(?i)\bR16-(0(?:1[8-9]|2[0-6]))\b.{0,160}\b(done|complete|completed|implemented|executed|ran|claimed|created)\b' },
        @{ Id = "r16_027_claim"; Label = "R16-027 or later task"; Pattern = '(?i)\bR16-(0(?:2[7-9]|[3-9][0-9])|[1-9][0-9]{2,})\b.{0,160}\b(done|complete|completed|implemented|executed|ran|exists|created|planned|active)\b' },
        @{ Id = "solved_codex_claim"; Label = "solved Codex compaction or reliability"; Pattern = '(?i)\b(solved Codex compaction|solved Codex context compaction|solved Codex reliability|Codex reliability solved|Codex compaction solved)\b' },
        @{ Id = "r13_boundary_claim"; Label = "R13 closure"; Pattern = '(?i)\bR13\b.{0,120}\b(is now closed|is closed|formally closed|closed in repo truth|closeout package exists|final-head support exists|merged to main|main merge exists)\b' },
        @{ Id = "r14_caveat_removal_claim"; Label = "R14 caveat removal"; Pattern = '(?i)\bR14\b.{0,120}\b(accepted without caveats|uncaveated acceptance|caveats removed|cleanly accepted|accepted cleanly)\b' },
        @{ Id = "r15_caveat_removal_claim"; Label = "R15 caveat removal"; Pattern = '(?i)\bR15\b.{0,120}\b(accepted without caveats|uncaveated acceptance|caveats removed|cleanly accepted|accepted cleanly)\b' }
    )

    $values = @(Get-StringValuesFromObject -Value $Object)
    foreach ($value in $values) {
        foreach ($claimPattern in $claimPatterns) {
            if ($value -match $claimPattern.Pattern -and -not (Test-TextHasNegation -Text $value)) {
                Add-GuardFinding -Findings $Findings -Seen $Seen -FindingId $claimPattern.Id -Severity "fail" -Category "forbidden_claim" -Message ("{0} contains forbidden positive claim: {1}." -f $Context, $claimPattern.Label) -Evidence ([ordered]@{ text = $value }) | Out-Null
            }
        }
    }
}

function Add-BooleanClaimFindings {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.Generic.List[object]]$Findings,
        [Parameter(Mandatory = $true)][hashtable]$Seen,
        [AllowNull()]$Object,
        [string]$Context = "root"
    )

    if ($null -eq $Object -or $Object -is [string]) {
        return
    }

    if ($Object -is [System.Collections.IDictionary]) {
        foreach ($key in $Object.Keys) {
            $childContext = "$Context.$key"
            $value = $Object[$key]
            if ($value -is [bool]) {
                if ($script:ForbiddenTrueBooleanClaims.ContainsKey($key) -and $value) {
                    Add-GuardFinding -Findings $Findings -Seen $Seen -FindingId ("forbidden_true_flag_{0}" -f $key) -Severity "fail" -Category "forbidden_claim" -Message ("{0} must be False; found forbidden claim '{1}'." -f $childContext, $script:ForbiddenTrueBooleanClaims[$key]) -Evidence ([ordered]@{ field = $childContext; value = $value }) | Out-Null
                }
                if ($key -in @("exact_path_only", "repo_relative_exact_paths_only", "load_items_require_paths") -and -not $value) {
                    Add-GuardFinding -Findings $Findings -Seen $Seen -FindingId ("required_true_flag_{0}" -f $key) -Severity "fail" -Category "path_policy" -Message ("{0} must be True for exact repo-relative load enforcement." -f $childContext) -Evidence ([ordered]@{ field = $childContext; value = $value }) | Out-Null
                }
                if ($key -eq "remote_verified" -and -not $value) {
                    Add-GuardFinding -Findings $Findings -Seen $Seen -FindingId "remote_unverified_ref" -Severity "fail" -Category "path_policy" -Message ("{0} must be True; unverified remote refs are rejected." -f $childContext) -Evidence ([ordered]@{ field = $childContext; value = $value }) | Out-Null
                }
            }
            Add-BooleanClaimFindings -Findings $Findings -Seen $Seen -Object $value -Context $childContext
        }
        return
    }

    if ($Object -is [System.Collections.IEnumerable] -and $Object -isnot [string]) {
        $arrayIndex = 0
        foreach ($item in $Object) {
            Add-BooleanClaimFindings -Findings $Findings -Seen $Seen -Object $item -Context "$Context[$arrayIndex]"
            $arrayIndex += 1
        }
        return
    }

    if ($Object.PSObject -and $Object.PSObject.Properties) {
        foreach ($property in $Object.PSObject.Properties) {
            $childContext = "$Context.$($property.Name)"
            if ($property.Value -is [bool]) {
                if ($script:ForbiddenTrueBooleanClaims.ContainsKey($property.Name) -and $property.Value) {
                    Add-GuardFinding -Findings $Findings -Seen $Seen -FindingId ("forbidden_true_flag_{0}" -f $property.Name) -Severity "fail" -Category "forbidden_claim" -Message ("{0} must be False; found forbidden claim '{1}'." -f $childContext, $script:ForbiddenTrueBooleanClaims[$property.Name]) -Evidence ([ordered]@{ field = $childContext; value = $property.Value }) | Out-Null
                }
                if ($property.Name -in @("exact_path_only", "repo_relative_exact_paths_only", "load_items_require_paths") -and -not $property.Value) {
                    Add-GuardFinding -Findings $Findings -Seen $Seen -FindingId ("required_true_flag_{0}" -f $property.Name) -Severity "fail" -Category "path_policy" -Message ("{0} must be True for exact repo-relative load enforcement." -f $childContext) -Evidence ([ordered]@{ field = $childContext; value = $property.Value }) | Out-Null
                }
                if ($property.Name -eq "remote_verified" -and -not $property.Value) {
                    Add-GuardFinding -Findings $Findings -Seen $Seen -FindingId "remote_unverified_ref" -Severity "fail" -Category "path_policy" -Message ("{0} must be True; unverified remote refs are rejected." -f $childContext) -Evidence ([ordered]@{ field = $childContext; value = $property.Value }) | Out-Null
                }
            }
            Add-BooleanClaimFindings -Findings $Findings -Seen $Seen -Object $property.Value -Context $childContext
        }
    }
}

function Add-BoundaryFindings {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.Generic.List[object]]$Findings,
        [Parameter(Mandatory = $true)][hashtable]$Seen,
        [AllowNull()]$Boundaries,
        [Parameter(Mandatory = $true)][string]$Context
    )

    if ($null -eq $Boundaries) {
        Add-GuardFinding -Findings $Findings -Seen $Seen -FindingId "missing_preserved_boundaries" -Severity "fail" -Category "historical_boundary" -Message "$Context preserved_boundaries is missing." -Evidence $null | Out-Null
        return
    }

    $boundaryObject = Assert-ObjectValue -Value $Boundaries -Context "$Context preserved_boundaries"
    $r13 = Get-RequiredProperty -Object $boundaryObject -Name "r13" -Context "$Context preserved_boundaries"
    $r14 = Get-RequiredProperty -Object $boundaryObject -Name "r14" -Context "$Context preserved_boundaries"
    $r15 = Get-RequiredProperty -Object $boundaryObject -Name "r15" -Context "$Context preserved_boundaries"

    if ($r13.status -ne "failed_partial_through_r13_018_only" -or $r13.closed -ne $false -or $r13.partial_gates_converted_to_passed -ne $false) {
        Add-GuardFinding -Findings $Findings -Seen $Seen -FindingId "r13_boundary_weakened" -Severity "fail" -Category "historical_boundary" -Message "$Context weakens the R13 failed/partial boundary." -Evidence $r13 | Out-Null
    }
    if ($r14.status -ne "accepted_with_caveats_through_r14_006_only" -or $r14.caveats_removed -ne $false) {
        Add-GuardFinding -Findings $Findings -Seen $Seen -FindingId "r14_caveat_removed" -Severity "fail" -Category "historical_boundary" -Message "$Context removes or weakens the R14 caveat boundary." -Evidence $r14 | Out-Null
    }
    if ($r15.status -ne "accepted_with_caveats_through_r15_009_only" -or $r15.caveats_removed -ne $false) {
        Add-GuardFinding -Findings $Findings -Seen $Seen -FindingId "r15_caveat_removed" -Severity "fail" -Category "historical_boundary" -Message "$Context removes or weakens the R15 caveat boundary." -Evidence $r15 | Out-Null
    }
}

function Get-ContextLoadPlanItems {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)]$Plan)

    $groups = @(Get-RequiredProperty -Object $Plan -Name "load_groups" -Context "context load plan")
    foreach ($group in $groups) {
        foreach ($item in @($group.load_items)) {
            $PSCmdlet.WriteObject($item, $false)
        }
    }
}

function Get-PathFindingId {
    param([Parameter(Mandatory = $true)][string]$Reason)

    switch ($Reason) {
        "wildcard_path" { return "invalid_wildcard_path" }
        "directory_only_path" { return "invalid_directory_only_path" }
        "scratch_temp_path" { return "invalid_scratch_temp_path" }
        "absolute_path" { return "invalid_absolute_path" }
        "parent_traversal_path" { return "invalid_parent_traversal_path" }
        "url_or_remote_ref" { return "invalid_url_or_remote_ref" }
        "broad_or_full_repo_scan_ref" { return "invalid_broad_or_full_repo_scan_ref" }
        "untracked_path" { return "invalid_untracked_path" }
        "not_exact_file_path" { return "invalid_not_exact_file_path" }
        default { return "invalid_path_policy" }
    }
}

function Add-PathPolicyFindings {
    param(
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][System.Collections.Generic.List[object]]$Findings,
        [Parameter(Mandatory = $true)][hashtable]$Seen,
        [Parameter(Mandatory = $true)]$PolicyEvaluation
    )

    foreach ($reason in @($PolicyEvaluation.invalid_reasons)) {
        Add-GuardFinding -Findings $Findings -Seen $Seen -FindingId (Get-PathFindingId -Reason $reason) -Severity "fail" -Category "path_policy" -Message ("{0} rejects '{1}' because it is {2}." -f $PolicyEvaluation.path_context, $PolicyEvaluation.path, $reason) -Evidence ([ordered]@{ path = $PolicyEvaluation.path; reason = $reason }) | Out-Null
    }
}

function New-CurrentPostureObject {
    return [ordered]@{
        active_through_task = "R16-017"
        complete_tasks = @($script:CompleteTasks)
        planned_tasks = @($script:PlannedTasks)
        r16_018_or_later_implementation_claimed = $false
        r16_027_or_later_task_exists = $false
    }
}

function New-PreservedBoundariesObject {
    return [ordered]@{
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
}

function New-R16ContextBudgetGuardReportObject {
    [CmdletBinding()]
    param(
        [string]$ContextLoadPlanPath = "state/context/r16_context_load_plan.json",
        [string]$ContextBudgetEstimatePath = "state/context/r16_context_budget_estimate.json",
        [string]$ContractPath = "contracts/context/r16_context_budget_guard.contract.json",
        [int64]$MaxEstimatedTokensUpperBound = $script:DefaultMaxEstimatedTokensUpperBound,
        [AllowNull()]$ContextLoadPlanObject,
        [AllowNull()]$ContextBudgetEstimateObject,
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    if ($MaxEstimatedTokensUpperBound -le 0) {
        throw "MaxEstimatedTokensUpperBound must be greater than zero."
    }

    Test-R16ContextBudgetGuardContract -Path $ContractPath -RepositoryRoot $resolvedRoot | Out-Null

    $loadPlanObject = $ContextLoadPlanObject
    if ($null -eq $loadPlanObject) {
        $planPathEvaluation = Get-RepoPathPolicyEvaluation -Path $ContextLoadPlanPath -RepositoryRoot $resolvedRoot -PathContext "context_load_plan_ref.path"
        if (-not $planPathEvaluation.exact_repo_relative_tracked_file) {
            throw "ContextLoadPlanPath must be an exact repo-relative tracked file path. Reasons: $($planPathEvaluation.invalid_reasons -join ', ')"
        }
        $loadPlanObject = Read-SingleJsonObject -Path (Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -Path $ContextLoadPlanPath)) -Label "R16 context-load plan"
    }

    $budgetEstimateObject = $ContextBudgetEstimateObject
    if ($null -eq $budgetEstimateObject) {
        $estimatePathEvaluation = Get-RepoPathPolicyEvaluation -Path $ContextBudgetEstimatePath -RepositoryRoot $resolvedRoot -PathContext "context_budget_estimate_ref.path"
        if (-not $estimatePathEvaluation.exact_repo_relative_tracked_file) {
            throw "ContextBudgetEstimatePath must be an exact repo-relative tracked file path. Reasons: $($estimatePathEvaluation.invalid_reasons -join ', ')"
        }
        $budgetEstimateObject = Read-SingleJsonObject -Path (Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -Path $ContextBudgetEstimatePath)) -Label "R16 context budget estimate"
    }

    $findings = New-Object System.Collections.Generic.List[object]
    $seenFindings = @{}

    if ($loadPlanObject.artifact_type -ne "r16_context_load_plan" -or $loadPlanObject.source_task -ne "R16-015") {
        Add-GuardFinding -Findings $findings -Seen $seenFindings -FindingId "invalid_context_load_plan_identity" -Severity "fail" -Category "input_identity" -Message "Context load plan must be the R16-015 r16_context_load_plan artifact." -Evidence ([ordered]@{ artifact_type = $loadPlanObject.artifact_type; source_task = $loadPlanObject.source_task }) | Out-Null
    }
    if ($budgetEstimateObject.artifact_type -ne "r16_context_budget_estimate" -or $budgetEstimateObject.source_task -ne "R16-016") {
        Add-GuardFinding -Findings $findings -Seen $seenFindings -FindingId "invalid_context_budget_estimate_identity" -Severity "fail" -Category "input_identity" -Message "Context budget estimate must be the R16-016 r16_context_budget_estimate artifact." -Evidence ([ordered]@{ artifact_type = $budgetEstimateObject.artifact_type; source_task = $budgetEstimateObject.source_task }) | Out-Null
    }

    Add-BooleanClaimFindings -Findings $findings -Seen $seenFindings -Object $loadPlanObject -Context "context_load_plan"
    Add-BooleanClaimFindings -Findings $findings -Seen $seenFindings -Object $budgetEstimateObject -Context "context_budget_estimate"
    Add-ForbiddenStringClaimFindings -Findings $findings -Seen $seenFindings -Object $loadPlanObject -Context "context_load_plan"
    Add-ForbiddenStringClaimFindings -Findings $findings -Seen $seenFindings -Object $budgetEstimateObject -Context "context_budget_estimate"
    Add-BoundaryFindings -Findings $findings -Seen $seenFindings -Boundaries $loadPlanObject.preserved_boundaries -Context "context_load_plan"
    Add-BoundaryFindings -Findings $findings -Seen $seenFindings -Boundaries $budgetEstimateObject.preserved_boundaries -Context "context_budget_estimate"

    $allPathEvaluations = New-Object System.Collections.Generic.List[object]
    foreach ($pathField in @(Get-ObjectPathFields -Value $loadPlanObject -Context "context_load_plan")) {
        $pathEvaluation = Get-RepoPathPolicyEvaluation -Path $pathField.Path -RepositoryRoot $resolvedRoot -PathContext $pathField.Context
        $null = $allPathEvaluations.Add($pathEvaluation)
        Add-PathPolicyFindings -Findings $findings -Seen $seenFindings -PolicyEvaluation $pathEvaluation
    }
    foreach ($pathField in @(Get-ObjectPathFields -Value $budgetEstimateObject -Context "context_budget_estimate")) {
        $pathEvaluation = Get-RepoPathPolicyEvaluation -Path $pathField.Path -RepositoryRoot $resolvedRoot -PathContext $pathField.Context
        $null = $allPathEvaluations.Add($pathEvaluation)
        Add-PathPolicyFindings -Findings $findings -Seen $seenFindings -PolicyEvaluation $pathEvaluation
    }

    $planItems = @(Get-ContextLoadPlanItems -Plan $loadPlanObject)
    $estimateItemsValue = Get-RequiredProperty -Object $budgetEstimateObject -Name "load_item_estimates" -Context "context budget estimate"
    $estimateItems = @($estimateItemsValue)
    if ($planItems.Count -ne $estimateItems.Count) {
        Add-GuardFinding -Findings $findings -Seen $seenFindings -FindingId "load_item_count_mismatch" -Severity "fail" -Category "input_consistency" -Message "Context load plan load item count must match budget estimate load item count." -Evidence ([ordered]@{ plan_count = $planItems.Count; estimate_count = $estimateItems.Count }) | Out-Null
    }

    $evaluatedLoadItems = New-Object System.Collections.Generic.List[object]
    $maxItemCount = [Math]::Max($planItems.Count, $estimateItems.Count)
    for ($index = 0; $index -lt $maxItemCount; $index += 1) {
        $planItem = if ($index -lt $planItems.Count) { $planItems[$index] } else { $null }
        $estimateItem = if ($index -lt $estimateItems.Count) { $estimateItems[$index] } else { $null }
        $candidatePath = if ($null -ne $planItem -and (Test-HasProperty -Object $planItem -Name "path")) { [string]$planItem.path } elseif ($null -ne $estimateItem -and (Test-HasProperty -Object $estimateItem -Name "path")) { [string]$estimateItem.path } else { "" }
        $itemPathEvaluation = Get-RepoPathPolicyEvaluation -Path $candidatePath -RepositoryRoot $resolvedRoot -PathContext ("evaluated_load_items[{0}].path" -f $index)

        if ($null -ne $planItem -and $null -ne $estimateItem) {
            if ($planItem.item_id -ne $estimateItem.load_item_id) {
                Add-GuardFinding -Findings $findings -Seen $seenFindings -FindingId "load_item_id_mismatch" -Severity "fail" -Category "input_consistency" -Message "Context load plan item_id must match budget estimate load_item_id." -Evidence ([ordered]@{ order = $index + 1; plan_item_id = $planItem.item_id; estimate_load_item_id = $estimateItem.load_item_id }) | Out-Null
            }
            if ((ConvertTo-NormalizedRepoPath -Path ([string]$planItem.path)) -ne (ConvertTo-NormalizedRepoPath -Path ([string]$estimateItem.path))) {
                Add-GuardFinding -Findings $findings -Seen $seenFindings -FindingId "load_item_path_mismatch" -Severity "fail" -Category "input_consistency" -Message "Context load plan path must match budget estimate path." -Evidence ([ordered]@{ order = $index + 1; plan_path = $planItem.path; estimate_path = $estimateItem.path }) | Out-Null
            }
        }

        $null = $evaluatedLoadItems.Add([ordered]@{
            load_item_id = if ($null -eq $planItem) { $null } else { $planItem.item_id }
            estimate_item_id = if ($null -eq $estimateItem) { $null } else { $estimateItem.estimate_item_id }
            path = $candidatePath
            exact_repo_relative_tracked_file = $itemPathEvaluation.exact_repo_relative_tracked_file
            exists = $itemPathEvaluation.exists
            tracked = $itemPathEvaluation.tracked
            invalid_reasons = @($itemPathEvaluation.invalid_reasons)
            estimated_tokens_upper_bound = if ($null -eq $estimateItem -or -not (Test-HasProperty -Object $estimateItem -Name "estimated_tokens_upper_bound")) { $null } else { [int64]$estimateItem.estimated_tokens_upper_bound }
            deterministic_order = $index + 1
        })
    }

    $summary = Assert-ObjectValue -Value $budgetEstimateObject.summary_estimates -Context "context budget estimate summary_estimates"
    $estimatedUpperBound = Assert-IntegerValue -Value $summary.estimated_tokens_upper_bound -Context "context budget estimate summary_estimates estimated_tokens_upper_bound"
    $estimatedLowerBound = Assert-IntegerValue -Value $summary.estimated_tokens_lower_bound -Context "context budget estimate summary_estimates estimated_tokens_lower_bound"
    $thresholdExceeded = $estimatedUpperBound -gt $MaxEstimatedTokensUpperBound
    if ($thresholdExceeded) {
        Add-GuardFinding -Findings $findings -Seen $seenFindings -FindingId "estimated_tokens_upper_bound_exceeds_threshold" -Severity "blocker" -Category "budget" -Message ("estimated_tokens_upper_bound {0} exceeds configured threshold {1}; guard fails closed." -f $estimatedUpperBound, $MaxEstimatedTokensUpperBound) -Evidence ([ordered]@{ estimated_tokens_upper_bound = $estimatedUpperBound; max_estimated_tokens_upper_bound = $MaxEstimatedTokensUpperBound }) | Out-Null
    }

    $findingArray = @($findings.ToArray())
    $failCount = @($findingArray | Where-Object { $_.severity -eq "fail" }).Count
    $blockerCount = @($findingArray | Where-Object { $_.severity -eq "blocker" }).Count
    $warningCount = @($findingArray | Where-Object { $_.severity -eq "warning" }).Count
    $passCount = if (($failCount + $blockerCount) -eq 0) { 1 } else { 0 }
    $overBudgetCount = @($findingArray | Where-Object { $_.finding_id -eq "estimated_tokens_upper_bound_exceeds_threshold" }).Count
    $policyViolationCount = @($findingArray | Where-Object { $_.category -in @("path_policy", "forbidden_claim", "historical_boundary", "input_identity", "input_consistency") }).Count

    $aggregateVerdict = if ($overBudgetCount -gt 0 -and $policyViolationCount -gt 0) {
        "failed_closed_multiple_policy_violations"
    }
    elseif ($overBudgetCount -gt 0) {
        "failed_closed_over_budget"
    }
    elseif ($policyViolationCount -gt 0) {
        "failed_closed_policy_violation"
    }
    else {
        "passed_guard"
    }

    $validationFindings = @($findingArray)
    if ($validationFindings.Count -eq 0) {
        $validationFindings = @(
            [ordered]@{
                finding_id = "guard_inputs_within_policy"
                severity = "pass"
                category = "guard"
                message = "Context load plan and budget estimate stayed within the configured guard policy."
                fail_closed = $false
                deterministic_order = 1
            }
        )
    }

    return [ordered]@{
        artifact_type = "r16_context_budget_guard_report"
        guard_version = "v1"
        guard_id = $script:GuardId
        source_milestone = $script:R16Milestone
        source_task = "R16-017"
        repository = $script:Repository
        branch = $script:Branch
        generation_boundary = [ordered]@{
            input_head = $script:InputHead
            input_tree = $script:InputTree
        }
        context_load_plan_ref = [ordered]@{
            path = (ConvertTo-NormalizedRepoPath -Path $ContextLoadPlanPath)
            source_task = "R16-015"
            loaded_and_validated = ($loadPlanObject.artifact_type -eq "r16_context_load_plan")
            exact_path_only = $true
            broad_scan_allowed = $false
        }
        context_budget_estimate_ref = [ordered]@{
            path = (ConvertTo-NormalizedRepoPath -Path $ContextBudgetEstimatePath)
            source_task = "R16-016"
            loaded_and_validated = ($budgetEstimateObject.artifact_type -eq "r16_context_budget_estimate")
            exact_path_only = $true
            broad_scan_allowed = $false
        }
        configured_budget_thresholds = [ordered]@{
            max_estimated_tokens_upper_bound = $MaxEstimatedTokensUpperBound
            threshold_source = "explicit configured threshold"
            threshold_exceeded_verdict = "failed_closed_over_budget"
        }
        evaluated_budget = [ordered]@{
            estimated_tokens_lower_bound = $estimatedLowerBound
            estimated_tokens_upper_bound = $estimatedUpperBound
            max_estimated_tokens_upper_bound = $MaxEstimatedTokensUpperBound
            threshold_exceeded = $thresholdExceeded
            budget_category = $summary.budget_category
            exact_provider_token_count_claimed = $false
            exact_provider_billing_claimed = $false
            provider_tokenizer_used = $false
            provider_pricing_used = $false
        }
        guard_mode = [ordered]@{
            deterministic_local_only = $true
            reads_committed_context_load_plan = $true
            reads_committed_context_budget_estimate = $true
            fail_closed_on_over_budget = $true
            fail_closed_on_no_full_repo_scan_policy_violation = $true
            provider_tokenizer_used = $false
            provider_pricing_used = $false
            exact_provider_token_count_claimed = $false
            exact_provider_billing_claimed = $false
            runtime_memory_implemented = $false
            retrieval_runtime_implemented = $false
            vector_search_runtime_implemented = $false
            role_run_envelope_implemented = $false
            raci_transition_gate_implemented = $false
            handoff_packet_implemented = $false
            workflow_drill_run = $false
            product_runtime_implemented = $false
            actual_autonomous_agents_implemented = $false
            external_integrations_implemented = $false
            solved_codex_compaction = $false
            solved_codex_reliability = $false
        }
        no_full_repo_scan_policy = [ordered]@{
            repo_relative_exact_paths_only = $true
            tracked_files_only = $true
            wildcard_paths_allowed = $false
            directory_only_paths_allowed = $false
            scratch_temp_paths_allowed = $false
            absolute_paths_allowed = $false
            parent_traversal_allowed = $false
            url_or_remote_refs_allowed = $false
            broad_repo_scan_allowed = $false
            full_repo_scan_allowed = $false
            raw_chat_history_loading_allowed = $false
            broad_or_full_repo_scan_claims_rejected = $true
        }
        evaluated_load_items = @($evaluatedLoadItems.ToArray())
        path_policy_evaluations = @($allPathEvaluations.ToArray())
        current_posture = (New-CurrentPostureObject)
        preserved_boundaries = (New-PreservedBoundariesObject)
        validation_findings = @($validationFindings)
        finding_summary = [ordered]@{
            pass_count = $passCount
            warning_count = $warningCount
            fail_count = $failCount
            blocker_count = $blockerCount
            over_budget_count = $overBudgetCount
            policy_violation_count = $policyViolationCount
            open_violation_count = ($failCount + $blockerCount)
        }
        aggregate_verdict = $aggregateVerdict
        validation_commands = @(
            [ordered]@{
                command_id = "tools_test_r16_context_budget_guard"
                command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools/test_r16_context_budget_guard.ps1"
                expected_result = "PASS"
                validates_path = "tools/R16ContextBudgetGuard.psm1"
                deterministic_order = 1
            },
            [ordered]@{
                command_id = "validate_r16_context_budget_guard_report"
                command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_context_budget_guard_report.ps1"
                expected_result = "PASS"
                validates_path = "state/context/r16_context_budget_guard_report.json"
                deterministic_order = 2
            },
            [ordered]@{
                command_id = "test_r16_context_budget_guard"
                command = "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_context_budget_guard.ps1"
                expected_result = "PASS"
                validates_path = "tests/test_r16_context_budget_guard.ps1"
                deterministic_order = 3
            },
            [ordered]@{
                command_id = "validate_r16_context_budget_estimate"
                command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_context_budget_estimate.ps1"
                expected_result = "PASS"
                validates_path = "state/context/r16_context_budget_estimate.json"
                deterministic_order = 4
            },
            [ordered]@{
                command_id = "test_r16_context_budget_estimator"
                command = "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_context_budget_estimator.ps1"
                expected_result = "PASS"
                validates_path = "tests/test_r16_context_budget_estimator.ps1"
                deterministic_order = 5
            },
            [ordered]@{
                command_id = "validate_r16_context_load_plan"
                command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_r16_context_load_plan.ps1"
                expected_result = "PASS"
                validates_path = "state/context/r16_context_load_plan.json"
                deterministic_order = 6
            },
            [ordered]@{
                command_id = "test_r16_context_load_planner"
                command = "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_r16_context_load_planner.ps1"
                expected_result = "PASS"
                validates_path = "tests/test_r16_context_load_planner.ps1"
                deterministic_order = 7
            },
            [ordered]@{
                command_id = "validate_status_doc_gate"
                command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools/validate_status_doc_gate.ps1"
                expected_result = "PASS"
                validates_path = "governance/ACTIVE_STATE.md"
                deterministic_order = 8
            },
            [ordered]@{
                command_id = "test_status_doc_gate"
                command = "powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_status_doc_gate.ps1"
                expected_result = "PASS"
                validates_path = "tests/test_status_doc_gate.ps1"
                deterministic_order = 9
            }
        )
        non_claims = @($script:RequiredNonClaims)
    }
}

function Test-R16ContextBudgetGuardContract {
    [CmdletBinding()]
    param(
        [string]$Path = "contracts/context/r16_context_budget_guard.contract.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedPath = Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -Path $Path)
    $contract = Read-SingleJsonObject -Path $resolvedPath -Label "R16 context budget guard contract"

    if ($contract.artifact_type -ne "r16_context_budget_guard_contract" -or $contract.contract_version -ne "v1" -or $contract.guard_contract_id -ne $script:GuardContractId) {
        throw "R16 context budget guard contract identity is incorrect."
    }
    if ($contract.source_milestone -ne $script:R16Milestone -or $contract.source_task -ne "R16-017" -or $contract.repository -ne $script:Repository -or $contract.branch -ne $script:Branch) {
        throw "R16 context budget guard contract source metadata is incorrect."
    }
    if ($contract.generated_from_head -ne $script:InputHead -or $contract.generated_from_tree -ne $script:InputTree) {
        throw "R16 context budget guard contract generation boundary is incorrect."
    }

    $thresholdPolicy = Assert-ObjectValue -Value $contract.budget_threshold_policy -Context "R16 context budget guard contract budget_threshold_policy"
    if ((Assert-IntegerValue -Value $thresholdPolicy.max_estimated_tokens_upper_bound -Context "R16 context budget guard contract threshold") -ne $script:DefaultMaxEstimatedTokensUpperBound) {
        throw "R16 context budget guard contract threshold must be $script:DefaultMaxEstimatedTokensUpperBound."
    }
    if ($thresholdPolicy.threshold_exceeded_verdict -ne "failed_closed_over_budget") {
        throw "R16 context budget guard contract must use failed_closed_over_budget for threshold exceedance."
    }

    $scanPolicy = Assert-ObjectValue -Value $contract.no_full_repo_scan_policy -Context "R16 context budget guard contract no_full_repo_scan_policy"
    foreach ($field in @("repo_relative_exact_paths_only", "tracked_files_only")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $scanPolicy -Name $field -Context "R16 context budget guard contract no_full_repo_scan_policy") -Context "R16 context budget guard contract $field") -ne $true) {
            throw "R16 context budget guard contract no_full_repo_scan_policy $field must be True."
        }
    }
    foreach ($field in @("wildcard_paths_allowed", "directory_only_paths_allowed", "scratch_temp_paths_allowed", "absolute_paths_allowed", "parent_traversal_allowed", "url_or_remote_refs_allowed", "broad_repo_scan_allowed", "full_repo_scan_allowed", "raw_chat_history_loading_allowed")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $scanPolicy -Name $field -Context "R16 context budget guard contract no_full_repo_scan_policy") -Context "R16 context budget guard contract $field") -ne $false) {
            throw "R16 context budget guard contract no_full_repo_scan_policy $field must be False."
        }
    }

    $posture = Assert-ObjectValue -Value $contract.current_posture -Context "R16 context budget guard contract current_posture"
    if ($posture.active_through_task -ne "R16-017") {
        throw "R16 context budget guard contract current_posture active_through_task must be R16-017."
    }
    Assert-ExactStringSet -Actual (Assert-StringArray -Value $posture.complete_tasks -Context "R16 context budget guard contract current_posture complete_tasks") -Expected $script:CompleteTasks -Context "R16 context budget guard contract current_posture complete_tasks"
    Assert-ExactStringSet -Actual (Assert-StringArray -Value $posture.planned_tasks -Context "R16 context budget guard contract current_posture planned_tasks") -Expected $script:PlannedTasks -Context "R16 context budget guard contract current_posture planned_tasks"

    Add-BoundaryFindings -Findings ([System.Collections.Generic.List[object]]::new()) -Seen @{} -Boundaries $contract.preserved_boundaries -Context "R16 context budget guard contract"

    $nonClaims = Assert-StringArray -Value $contract.non_claims -Context "R16 context budget guard contract non_claims"
    Assert-RequiredStringsPresent -Actual $nonClaims -Required $script:RequiredNonClaims -Context "R16 context budget guard contract non_claims"

    return [pscustomobject]@{
        GuardContractId = $contract.guard_contract_id
        ActiveThroughTask = $posture.active_through_task
        PlannedTaskStart = $posture.planned_tasks[0]
        PlannedTaskEnd = $posture.planned_tasks[-1]
        DependencyRefCount = @($contract.dependency_refs).Count
        MaxEstimatedTokensUpperBound = [int64]$thresholdPolicy.max_estimated_tokens_upper_bound
    }
}

function Test-R16ContextBudgetGuardReportObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]$Report,
        [string]$SourceLabel = "R16 context budget guard report",
        [string]$RepositoryRoot,
        [string]$ContractPath = "contracts/context/r16_context_budget_guard.contract.json"
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    Test-R16ContextBudgetGuardContract -Path $ContractPath -RepositoryRoot $resolvedRoot | Out-Null

    foreach ($field in $script:RequiredReportTopLevelFields) {
        Get-RequiredProperty -Object $Report -Name $field -Context $SourceLabel | Out-Null
    }

    if ($Report.artifact_type -ne "r16_context_budget_guard_report" -or $Report.guard_version -ne "v1" -or $Report.guard_id -ne $script:GuardId) {
        throw "$SourceLabel identity is incorrect."
    }
    if ($Report.source_milestone -ne $script:R16Milestone -or $Report.source_task -ne "R16-017" -or $Report.repository -ne $script:Repository -or $Report.branch -ne $script:Branch) {
        throw "$SourceLabel source metadata is incorrect."
    }

    $boundary = Assert-ObjectValue -Value $Report.generation_boundary -Context "$SourceLabel generation_boundary"
    if ($boundary.input_head -ne $script:InputHead -or $boundary.input_tree -ne $script:InputTree) {
        throw "$SourceLabel generation boundary must preserve the R16-017 input head and tree."
    }

    $thresholds = Assert-ObjectValue -Value $Report.configured_budget_thresholds -Context "$SourceLabel configured_budget_thresholds"
    $threshold = Assert-IntegerValue -Value $thresholds.max_estimated_tokens_upper_bound -Context "$SourceLabel max_estimated_tokens_upper_bound"
    if ($threshold -le 0) {
        throw "$SourceLabel max_estimated_tokens_upper_bound must be greater than zero."
    }

    $budget = Assert-ObjectValue -Value $Report.evaluated_budget -Context "$SourceLabel evaluated_budget"
    $upperBound = Assert-IntegerValue -Value $budget.estimated_tokens_upper_bound -Context "$SourceLabel evaluated_budget estimated_tokens_upper_bound"
    $thresholdExceeded = Assert-BooleanValue -Value $budget.threshold_exceeded -Context "$SourceLabel evaluated_budget threshold_exceeded"
    if ($thresholdExceeded -ne ($upperBound -gt $threshold)) {
        throw "$SourceLabel evaluated_budget threshold_exceeded must match estimated_tokens_upper_bound > threshold."
    }
    foreach ($field in @("exact_provider_token_count_claimed", "exact_provider_billing_claimed", "provider_tokenizer_used", "provider_pricing_used")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $budget -Name $field -Context "$SourceLabel evaluated_budget") -Context "$SourceLabel evaluated_budget $field") -ne $false) {
            throw "$SourceLabel evaluated_budget $field must be False."
        }
    }

    $mode = Assert-ObjectValue -Value $Report.guard_mode -Context "$SourceLabel guard_mode"
    foreach ($field in @("deterministic_local_only", "reads_committed_context_load_plan", "reads_committed_context_budget_estimate", "fail_closed_on_over_budget", "fail_closed_on_no_full_repo_scan_policy_violation")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $mode -Name $field -Context "$SourceLabel guard_mode") -Context "$SourceLabel guard_mode $field") -ne $true) {
            throw "$SourceLabel guard_mode $field must be True."
        }
    }
    foreach ($field in @("provider_tokenizer_used", "provider_pricing_used", "exact_provider_token_count_claimed", "exact_provider_billing_claimed", "runtime_memory_implemented", "retrieval_runtime_implemented", "vector_search_runtime_implemented", "role_run_envelope_implemented", "raci_transition_gate_implemented", "handoff_packet_implemented", "workflow_drill_run", "product_runtime_implemented", "actual_autonomous_agents_implemented", "external_integrations_implemented", "solved_codex_compaction", "solved_codex_reliability")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $mode -Name $field -Context "$SourceLabel guard_mode") -Context "$SourceLabel guard_mode $field") -ne $false) {
            throw "$SourceLabel guard_mode $field must be False."
        }
    }

    $scanPolicy = Assert-ObjectValue -Value $Report.no_full_repo_scan_policy -Context "$SourceLabel no_full_repo_scan_policy"
    foreach ($field in @("repo_relative_exact_paths_only", "tracked_files_only", "broad_or_full_repo_scan_claims_rejected")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $scanPolicy -Name $field -Context "$SourceLabel no_full_repo_scan_policy") -Context "$SourceLabel no_full_repo_scan_policy $field") -ne $true) {
            throw "$SourceLabel no_full_repo_scan_policy $field must be True."
        }
    }
    foreach ($field in @("wildcard_paths_allowed", "directory_only_paths_allowed", "scratch_temp_paths_allowed", "absolute_paths_allowed", "parent_traversal_allowed", "url_or_remote_refs_allowed", "broad_repo_scan_allowed", "full_repo_scan_allowed", "raw_chat_history_loading_allowed")) {
        if ((Assert-BooleanValue -Value (Get-RequiredProperty -Object $scanPolicy -Name $field -Context "$SourceLabel no_full_repo_scan_policy") -Context "$SourceLabel no_full_repo_scan_policy $field") -ne $false) {
            throw "$SourceLabel no_full_repo_scan_policy $field must be False."
        }
    }

    $items = Assert-ObjectArray -Value $Report.evaluated_load_items -Context "$SourceLabel evaluated_load_items" -AllowEmpty
    for ($index = 0; $index -lt $items.Count; $index += 1) {
        $item = Assert-ObjectValue -Value $items[$index] -Context "$SourceLabel evaluated_load_items[$index]"
        if ((Assert-IntegerValue -Value $item.deterministic_order -Context "$SourceLabel evaluated_load_items[$index] deterministic_order") -ne ($index + 1)) {
            throw "$SourceLabel evaluated_load_items[$index] deterministic_order must be $($index + 1)."
        }
    }

    $posture = Assert-ObjectValue -Value $Report.current_posture -Context "$SourceLabel current_posture"
    if ($posture.active_through_task -ne "R16-017") {
        throw "$SourceLabel current_posture active_through_task must be R16-017."
    }
    Assert-ExactStringSet -Actual (Assert-StringArray -Value $posture.complete_tasks -Context "$SourceLabel current_posture complete_tasks") -Expected $script:CompleteTasks -Context "$SourceLabel current_posture complete_tasks"
    Assert-ExactStringSet -Actual (Assert-StringArray -Value $posture.planned_tasks -Context "$SourceLabel current_posture planned_tasks") -Expected $script:PlannedTasks -Context "$SourceLabel current_posture planned_tasks"
    if ($posture.r16_018_or_later_implementation_claimed -ne $false -or $posture.r16_027_or_later_task_exists -ne $false) {
        throw "$SourceLabel current_posture must not claim R16-018 or later implementation or R16-027 or later tasks."
    }

    Add-BoundaryFindings -Findings ([System.Collections.Generic.List[object]]::new()) -Seen @{} -Boundaries $Report.preserved_boundaries -Context $SourceLabel

    $summary = Assert-ObjectValue -Value $Report.finding_summary -Context "$SourceLabel finding_summary"
    $openViolations = Assert-IntegerValue -Value $summary.open_violation_count -Context "$SourceLabel finding_summary open_violation_count"
    $overBudgetCount = Assert-IntegerValue -Value $summary.over_budget_count -Context "$SourceLabel finding_summary over_budget_count"
    $policyViolationCount = Assert-IntegerValue -Value $summary.policy_violation_count -Context "$SourceLabel finding_summary policy_violation_count"
    if ($Report.aggregate_verdict -notin @("passed_guard", "failed_closed_over_budget", "failed_closed_policy_violation", "failed_closed_multiple_policy_violations")) {
        throw "$SourceLabel aggregate_verdict is not a recognized guard verdict."
    }
    if ($thresholdExceeded -and $overBudgetCount -lt 1) {
        throw "$SourceLabel must record an over-budget finding when the threshold is exceeded."
    }
    if ($thresholdExceeded -and $Report.aggregate_verdict -notin @("failed_closed_over_budget", "failed_closed_multiple_policy_violations")) {
        throw "$SourceLabel must fail closed over budget when the threshold is exceeded."
    }
    if (-not $thresholdExceeded -and $openViolations -eq 0 -and $Report.aggregate_verdict -ne "passed_guard") {
        throw "$SourceLabel must pass when no threshold or policy violation is open."
    }
    if ($policyViolationCount -gt 0 -and $Report.aggregate_verdict -notin @("failed_closed_policy_violation", "failed_closed_multiple_policy_violations")) {
        throw "$SourceLabel must fail closed on policy violations."
    }

    $commands = Assert-ObjectArray -Value $Report.validation_commands -Context "$SourceLabel validation_commands"
    for ($index = 0; $index -lt $commands.Count; $index += 1) {
        $command = Assert-ObjectValue -Value $commands[$index] -Context "$SourceLabel validation_commands[$index]"
        if ((Assert-IntegerValue -Value $command.deterministic_order -Context "$SourceLabel validation_commands[$index] deterministic_order") -ne ($index + 1)) {
            throw "$SourceLabel validation_commands[$index] deterministic_order must be $($index + 1)."
        }
    }

    $nonClaims = Assert-StringArray -Value $Report.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredStringsPresent -Actual $nonClaims -Required $script:RequiredNonClaims -Context "$SourceLabel non_claims"

    return [pscustomobject]@{
        GuardId = $Report.guard_id
        ActiveThroughTask = $Report.current_posture.active_through_task
        PlannedTaskStart = $Report.current_posture.planned_tasks[0]
        PlannedTaskEnd = $Report.current_posture.planned_tasks[-1]
        EstimatedTokensUpperBound = [int64]$upperBound
        MaxEstimatedTokensUpperBound = [int64]$threshold
        ThresholdExceeded = [bool]$thresholdExceeded
        EvaluatedLoadItemCount = @($Report.evaluated_load_items).Count
        OverBudgetCount = [int64]$overBudgetCount
        PolicyViolationCount = [int64]$policyViolationCount
        OpenViolationCount = [int64]$openViolations
        AggregateVerdict = [string]$Report.aggregate_verdict
    }
}

function Test-R16ContextBudgetGuardReport {
    [CmdletBinding()]
    param(
        [string]$Path = "state/context/r16_context_budget_guard_report.json",
        [string]$ContractPath = "contracts/context/r16_context_budget_guard.contract.json",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedPath = Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -Path $Path)
    $report = Read-SingleJsonObject -Path $resolvedPath -Label "R16 context budget guard report"
    return Test-R16ContextBudgetGuardReportObject -Report $report -SourceLabel $Path -RepositoryRoot $resolvedRoot -ContractPath $ContractPath
}

function New-R16ContextBudgetGuardReport {
    [CmdletBinding()]
    param(
        [string]$OutputPath = "state/context/r16_context_budget_guard_report.json",
        [string]$ContextLoadPlanPath = "state/context/r16_context_load_plan.json",
        [string]$ContextBudgetEstimatePath = "state/context/r16_context_budget_estimate.json",
        [string]$ContractPath = "contracts/context/r16_context_budget_guard.contract.json",
        [int64]$MaxEstimatedTokensUpperBound = $script:DefaultMaxEstimatedTokensUpperBound,
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $report = New-R16ContextBudgetGuardReportObject -ContextLoadPlanPath $ContextLoadPlanPath -ContextBudgetEstimatePath $ContextBudgetEstimatePath -ContractPath $ContractPath -MaxEstimatedTokensUpperBound $MaxEstimatedTokensUpperBound -RepositoryRoot $resolvedRoot
    $resolvedOutput = Join-Path $resolvedRoot (ConvertTo-NormalizedRepoPath -Path $OutputPath)
    Write-StableJsonFile -Object $report -Path $resolvedOutput
    $validation = Test-R16ContextBudgetGuardReport -Path $OutputPath -ContractPath $ContractPath -RepositoryRoot $resolvedRoot

    return [pscustomobject]@{
        OutputPath = $OutputPath
        GuardId = $validation.GuardId
        ActiveThroughTask = $validation.ActiveThroughTask
        PlannedTaskStart = $validation.PlannedTaskStart
        PlannedTaskEnd = $validation.PlannedTaskEnd
        EstimatedTokensUpperBound = $validation.EstimatedTokensUpperBound
        MaxEstimatedTokensUpperBound = $validation.MaxEstimatedTokensUpperBound
        ThresholdExceeded = $validation.ThresholdExceeded
        EvaluatedLoadItemCount = $validation.EvaluatedLoadItemCount
        AggregateVerdict = $validation.AggregateVerdict
    }
}

function New-MinimalFixturePlanAndEstimate {
    param(
        [Parameter(Mandatory = $true)]$BasePlan,
        [Parameter(Mandatory = $true)]$BaseEstimate,
        [Parameter(Mandatory = $true)][string]$RepositoryRoot
    )

    $smallPath = "contracts/context/r16_context_load_plan.contract.json"
    $resolvedSmallPath = Join-Path $RepositoryRoot $smallPath
    $byteCount = [int64]([System.IO.FileInfo]::new($resolvedSmallPath).Length)
    $lineCount = [int64](@(Get-Content -LiteralPath $resolvedSmallPath).Count)
    $lower = [int64][Math]::Ceiling($byteCount / 5.0)
    $upper = [int64][Math]::Ceiling($byteCount / 3.0)

    $planFixture = Copy-JsonObject -Value $BasePlan
    $estimateFixture = Copy-JsonObject -Value $BaseEstimate

    $fixtureLoadItem = [pscustomobject][ordered]@{
        item_id = "fixture_small_context_contract"
        path = $smallPath
        ref_kind = "fixture_exact_tracked_file"
        source_ref = "fixture"
        source_task = "R16-014"
        authority_level = "test_fixture"
        proof_status = "fixture_only"
        proof_treatment = "guard test fixture only"
        load_required = $true
        machine_proof = $false
        implementation_proof = $false
        exact_path_only = $true
        broad_scan_allowed = $false
        wildcard_allowed = $false
        remote_verified = $true
        deterministic_order = 1
    }
    $planFixture.load_groups = @(
        [pscustomobject][ordered]@{
            group_id = "fixture_small_under_budget"
            purpose = "Fixture group for a valid bounded under-budget exact tracked file."
            load_items = @($fixtureLoadItem)
            required_refs = @("fixture_small_context_contract")
            optional_refs = @()
            forbidden_refs = @("wildcard paths", "broad repo scans", "directory-only refs", "local scratch refs", "unverified remote refs")
            deterministic_order = 1
        }
    )

    $fixtureEstimateItem = [pscustomobject][ordered]@{
        estimate_item_id = "estimate_item_001"
        load_item_id = "fixture_small_context_contract"
        path = $smallPath
        exists = $true
        byte_count = $byteCount
        line_count = $lineCount
        estimated_tokens_lower_bound = $lower
        estimated_tokens_upper_bound = $upper
        approximate_cost_proxy_lower_units = [int64][Math]::Ceiling($lower / 1000.0)
        approximate_cost_proxy_upper_units = [int64][Math]::Ceiling($upper / 1000.0)
        cost_proxy_basis = "ceil(estimated_tokens / 1000) relative units; not currency and not provider billing"
        estimate_basis = "deterministic local file byte_count and line_count; token range is approximate, not exact provider tokenization"
        exact_provider_token_count_claimed = $false
        exact_provider_billing_claimed = $false
        deterministic_order = 1
    }
    $estimateFixture.load_item_estimates = @($fixtureEstimateItem)
    $estimateFixture.summary_estimates.load_item_count = 1
    $estimateFixture.summary_estimates.exact_file_count = 1
    $estimateFixture.summary_estimates.total_bytes = $byteCount
    $estimateFixture.summary_estimates.total_lines = $lineCount
    $estimateFixture.summary_estimates.estimated_tokens_lower_bound = $lower
    $estimateFixture.summary_estimates.estimated_tokens_upper_bound = $upper
    $estimateFixture.summary_estimates.estimated_ref_count = 2
    $estimateFixture.summary_estimates.approximate_cost_proxy_lower_units = [int64][Math]::Ceiling($lower / 1000.0)
    $estimateFixture.summary_estimates.approximate_cost_proxy_upper_units = [int64][Math]::Ceiling($upper / 1000.0)
    $estimateFixture.summary_estimates.budget_category = "small"

    return [pscustomobject]@{
        Plan = $planFixture
        Estimate = $estimateFixture
    }
}

function New-GuardFixtureScenario {
    param(
        [Parameter(Mandatory = $true)][string]$FixtureId,
        [Parameter(Mandatory = $true)]$Plan,
        [Parameter(Mandatory = $true)]$Estimate,
        [Parameter(Mandatory = $true)][string]$ExpectedVerdict,
        [Parameter(Mandatory = $true)][string]$ExpectedFindingFragment,
        [int64]$Threshold = $script:DefaultMaxEstimatedTokensUpperBound
    )

    return [ordered]@{
        fixture_id = $FixtureId
        configured_budget_thresholds = [ordered]@{
            max_estimated_tokens_upper_bound = $Threshold
        }
        plan = $Plan
        estimate = $Estimate
        expected_aggregate_verdict = $ExpectedVerdict
        expected_finding_fragment = $ExpectedFindingFragment
    }
}

function New-R16ContextBudgetGuardFixtureFiles {
    [CmdletBinding()]
    param(
        [string]$FixtureRoot = "tests/fixtures/r16_context_budget_guard",
        [string]$RepositoryRoot
    )

    $resolvedRoot = Get-RepositoryRoot -RepositoryRoot $RepositoryRoot
    $resolvedFixtureRoot = [System.IO.Path]::GetFullPath((Join-Path $resolvedRoot $FixtureRoot))
    New-Item -ItemType Directory -Path $resolvedFixtureRoot -Force | Out-Null

    $basePlan = Read-SingleJsonObject -Path (Join-Path $resolvedRoot "state/context/r16_context_load_plan.json") -Label "R16 context-load plan"
    $baseEstimate = Read-SingleJsonObject -Path (Join-Path $resolvedRoot "state/context/r16_context_budget_estimate.json") -Label "R16 context budget estimate"
    $minimal = New-MinimalFixturePlanAndEstimate -BasePlan $basePlan -BaseEstimate $baseEstimate -RepositoryRoot $resolvedRoot

    $validScenario = New-GuardFixtureScenario -FixtureId "valid_bounded_under_budget" -Plan $minimal.Plan -Estimate $minimal.Estimate -ExpectedVerdict "passed_guard" -ExpectedFindingFragment "guard_inputs_within_policy"
    Write-StableJsonFile -Object $validScenario -Path (Join-Path $resolvedFixtureRoot "valid_bounded_under_budget.fixture.json")

    $currentOverBudgetScenario = New-GuardFixtureScenario -FixtureId "current_over_budget_estimate" -Plan (Copy-JsonObject -Value $basePlan) -Estimate (Copy-JsonObject -Value $baseEstimate) -ExpectedVerdict "failed_closed_over_budget" -ExpectedFindingFragment "exceeds configured threshold"
    Write-StableJsonFile -Object $currentOverBudgetScenario -Path (Join-Path $resolvedFixtureRoot "current_over_budget_estimate.fixture.json")

    $fixtureSpecs = [ordered]@{
        "invalid_wildcard_path.fixture.json" = @{
            Fragment = "wildcard_path"
            Mutate = {
                param($scenario)
                $scenario.plan.load_groups[0].load_items[0].path = "state/memory/*.json"
                $scenario.estimate.load_item_estimates[0].path = "state/memory/*.json"
            }
        }
        "invalid_directory_only_path.fixture.json" = @{
            Fragment = "directory_only_path"
            Mutate = {
                param($scenario)
                $scenario.plan.load_groups[0].load_items[0].path = "state/memory/"
                $scenario.estimate.load_item_estimates[0].path = "state/memory/"
            }
        }
        "invalid_broad_repo_scan_claim.fixture.json" = @{
            Fragment = "broad/full repo scan claim"
            Mutate = {
                param($scenario)
                $scenario.plan.load_policy.broad_repo_scan_allowed = $true
            }
        }
        "invalid_full_repo_scan_claim.fixture.json" = @{
            Fragment = "broad/full repo scan claim"
            Mutate = {
                param($scenario)
                $scenario.plan.load_policy.full_repo_scan_allowed = $true
            }
        }
        "invalid_scratch_temp_path.fixture.json" = @{
            Fragment = "scratch_temp_path"
            Mutate = {
                param($scenario)
                $scenario.plan.load_groups[0].load_items[0].path = "scratch/r16_context.tmp.json"
                $scenario.estimate.load_item_estimates[0].path = "scratch/r16_context.tmp.json"
            }
        }
        "invalid_absolute_path.fixture.json" = @{
            Fragment = "absolute_path"
            Mutate = {
                param($scenario)
                $scenario.plan.load_groups[0].load_items[0].path = "C:/Users/rodne/OneDrive/Documentos/AIOffice_V2/README.md"
                $scenario.estimate.load_item_estimates[0].path = "C:/Users/rodne/OneDrive/Documentos/AIOffice_V2/README.md"
            }
        }
        "invalid_parent_traversal_path.fixture.json" = @{
            Fragment = "parent_traversal_path"
            Mutate = {
                param($scenario)
                $scenario.plan.load_groups[0].load_items[0].path = "../README.md"
                $scenario.estimate.load_item_estimates[0].path = "../README.md"
            }
        }
        "invalid_url_remote_ref.fixture.json" = @{
            Fragment = "url_or_remote_ref"
            Mutate = {
                param($scenario)
                $scenario.plan.load_groups[0].load_items[0].path = "https://example.invalid/repo/context.json"
                $scenario.estimate.load_item_estimates[0].path = "https://example.invalid/repo/context.json"
            }
        }
        "invalid_exact_provider_token_claim.fixture.json" = @{
            Fragment = "exact provider token count"
            Mutate = {
                param($scenario)
                $scenario.estimate.estimate_mode.exact_provider_token_count_claimed = $true
            }
        }
        "invalid_exact_provider_billing_claim.fixture.json" = @{
            Fragment = "exact provider billing"
            Mutate = {
                param($scenario)
                $scenario.estimate.estimate_mode.exact_provider_billing_claimed = $true
            }
        }
        "invalid_runtime_memory_claim.fixture.json" = @{
            Fragment = "runtime memory claim"
            Mutate = {
                param($scenario)
                $scenario.estimate.estimate_mode.runtime_memory_implemented = $true
            }
        }
        "invalid_retrieval_runtime_claim.fixture.json" = @{
            Fragment = "retrieval runtime claim"
            Mutate = {
                param($scenario)
                $scenario.estimate.estimate_mode.retrieval_runtime_implemented = $true
            }
        }
        "invalid_vector_search_claim.fixture.json" = @{
            Fragment = "vector search runtime claim"
            Mutate = {
                param($scenario)
                $scenario.estimate.estimate_mode.vector_search_runtime_implemented = $true
            }
        }
        "invalid_role_run_envelope_claim.fixture.json" = @{
            Fragment = "role-run envelope claim"
            Mutate = {
                param($scenario)
                $scenario.estimate.estimate_mode.role_run_envelope_implemented = $true
            }
        }
        "invalid_raci_transition_gate_claim.fixture.json" = @{
            Fragment = "RACI transition gate claim"
            Mutate = {
                param($scenario)
                $scenario.estimate.estimate_mode.raci_transition_gate_implemented = $true
            }
        }
        "invalid_handoff_packet_claim.fixture.json" = @{
            Fragment = "handoff packet claim"
            Mutate = {
                param($scenario)
                $scenario.estimate.estimate_mode.handoff_packet_implemented = $true
            }
        }
        "invalid_workflow_drill_claim.fixture.json" = @{
            Fragment = "workflow drill claim"
            Mutate = {
                param($scenario)
                $scenario.estimate.estimate_mode.workflow_drill_run = $true
            }
        }
        "invalid_r16_018_implementation_claim.fixture.json" = @{
            Fragment = "R16-018 or later implementation"
            Mutate = {
                param($scenario)
                $scenario.estimate.validation_findings += [pscustomobject][ordered]@{
                    finding_id = "fixture_r16_018_claim"
                    severity = "fail"
                    message = "R16-018 implementation is complete."
                    deterministic_order = 99
                }
            }
        }
        "invalid_r13_boundary_change.fixture.json" = @{
            Fragment = "R13 failed/partial boundary"
            Mutate = {
                param($scenario)
                $scenario.estimate.preserved_boundaries.r13.closed = $true
            }
        }
        "invalid_r14_caveat_removal.fixture.json" = @{
            Fragment = "R14 caveat boundary"
            Mutate = {
                param($scenario)
                $scenario.estimate.preserved_boundaries.r14.caveats_removed = $true
            }
        }
        "invalid_r15_caveat_removal.fixture.json" = @{
            Fragment = "R15 caveat boundary"
            Mutate = {
                param($scenario)
                $scenario.estimate.preserved_boundaries.r15.caveats_removed = $true
            }
        }
    }

    foreach ($fixtureName in $fixtureSpecs.Keys) {
        $scenario = New-GuardFixtureScenario -FixtureId ($fixtureName -replace '\.fixture\.json$', '') -Plan (Copy-JsonObject -Value $minimal.Plan) -Estimate (Copy-JsonObject -Value $minimal.Estimate) -ExpectedVerdict "failed_closed_policy_violation" -ExpectedFindingFragment $fixtureSpecs[$fixtureName].Fragment
        & $fixtureSpecs[$fixtureName].Mutate $scenario
        Write-StableJsonFile -Object $scenario -Path (Join-Path $resolvedFixtureRoot $fixtureName)
    }

    return [pscustomobject]@{
        FixtureRoot = $FixtureRoot
        ValidFixture = (Join-Path $FixtureRoot "valid_bounded_under_budget.fixture.json")
        CurrentOverBudgetFixture = (Join-Path $FixtureRoot "current_over_budget_estimate.fixture.json")
        InvalidFixtureCount = $fixtureSpecs.Count
    }
}

Export-ModuleMember -Function New-R16ContextBudgetGuardReportObject, New-R16ContextBudgetGuardReport, Test-R16ContextBudgetGuardReportObject, Test-R16ContextBudgetGuardReport, Test-R16ContextBudgetGuardContract, New-R16ContextBudgetGuardFixtureFiles, ConvertTo-StableJson
