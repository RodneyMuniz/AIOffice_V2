Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "R15ArtifactClassificationTaxonomy.psm1") -Force

$script:RequiredTopLevelFields = @(
    "artifact_type",
    "contract_version",
    "index_id",
    "source_milestone",
    "source_task",
    "generated_from_head",
    "generated_from_tree",
    "taxonomy_ref",
    "index_scope",
    "index_entries",
    "required_entry_fields",
    "allowed_artifact_classes",
    "allowed_evidence_kinds",
    "allowed_authority_kinds",
    "allowed_lifecycle_states",
    "allowed_proof_status_values",
    "relationship_types",
    "lookup_profiles",
    "invalid_state_rules",
    "non_claims"
)

$script:RequiredEntryFields = @(
    "entry_id",
    "path",
    "title",
    "summary",
    "classification_class",
    "evidence_kind",
    "authority_kind",
    "lifecycle_state",
    "proof_status",
    "owner_role",
    "source_milestone",
    "source_task",
    "last_verified_head",
    "depends_on",
    "supersedes",
    "superseded_by",
    "related_entries",
    "recommended_for_roles",
    "load_priority",
    "scan_scope",
    "reason",
    "non_claims"
)

$script:RequiredRelationshipTypes = @(
    "depends_on",
    "supersedes",
    "superseded_by",
    "references",
    "validates",
    "reports_on",
    "evidence_for",
    "template_for",
    "derived_from",
    "related_to"
)

$script:RequiredLookupProfiles = @(
    "operator_summary",
    "pm_planning",
    "architect_design",
    "developer_execution",
    "qa_validation",
    "auditor_review",
    "knowledge_curator",
    "release_closeout",
    "codex_reentry"
)

$script:AllowedScanScopes = @(
    "no_scan",
    "exact_file_only",
    "folder_limited",
    "evidence_refs_only",
    "bounded_glob",
    "full_repo_prohibited"
)

$script:AllowedLoadPriorities = @(
    "1_critical",
    "2_high",
    "3_normal",
    "4_context_only",
    "5_avoid_unless_needed"
)

$script:RequiredNonClaims = @(
    "no full repo index implemented by R15-003",
    "no full repo artifacts classified by R15-003",
    "no knowledge-base engine implemented by R15-003",
    "no artifact registry engine implemented by R15-003",
    "no retrieval engine implemented by R15-003",
    "no vector search implemented by R15-003",
    "no Obsidian integration by R15-003",
    "no GitHub Projects integration",
    "no Linear implementation",
    "no Symphony implementation",
    "no custom board implementation",
    "no agent identity packets implemented",
    "no memory scopes implemented",
    "no RACI matrix implemented",
    "no card re-entry packets implemented",
    "no classification or re-entry dry run executed",
    "no final R15 proof package complete",
    "no product runtime",
    "no board runtime",
    "no external board sync",
    "no true multi-agent execution",
    "no persistent memory engine",
    "no R16 opening",
    "no solved Codex compaction",
    "no solved Codex reliability"
)

$script:ProofByItselfEvidenceKinds = @(
    "committed_machine_evidence",
    "external_replay_evidence",
    "validation_manifest",
    "test_result"
)

$script:GeneratedOrNarrativeClasses = @(
    "generated_operator_artifact",
    "report",
    "template",
    "status_surface"
)

$script:GeneratedOrNarrativeEvidenceKinds = @(
    "generated_artifact",
    "operator_artifact",
    "status_doc",
    "governance_doc",
    "planning_doc",
    "unknown"
)

$script:OverclaimPatterns = @(
    "product runtime",
    "production runtime",
    "productized UI",
    "board runtime",
    "external board sync",
    "Linear implementation",
    "Linear integration",
    "Symphony implementation",
    "Symphony integration",
    "GitHub Projects implementation",
    "GitHub Projects integration",
    "custom board implementation",
    "custom board runtime",
    "true multi-agent execution",
    "multi-agent runtime",
    "persistent memory engine",
    "solved Codex reliability",
    "solved Codex compaction",
    "solved Codex context compaction",
    "R16 opening",
    "R16 opened",
    "full repo index",
    "full-repo index",
    "full repo scan",
    "full-repo scan",
    "full repo artifacts classified",
    "full-repo artifacts classified"
)

function Get-RepositoryRoot {
    return $repoRoot
}

function Test-HasProperty {
    param(
        [AllowNull()]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    return $null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name
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

function Resolve-IndexRelativePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $repoRoot $Path))
}

function Assert-PathExists {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $resolvedPath = Resolve-IndexRelativePath -Path $Path
    if (-not (Test-Path -LiteralPath $resolvedPath)) {
        throw "$Context path '$Path' does not exist."
    }

    return (Resolve-Path -LiteralPath $resolvedPath).Path
}

function New-ValueSet {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Items,
        [Parameter(Mandatory = $true)]
        [string]$FieldName,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $map = @{}
    foreach ($item in $Items) {
        $id = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name $FieldName -Context $Context) -Context "$Context $FieldName"
        if ($map.ContainsKey($id)) {
            throw "$Context duplicates '$id'."
        }

        $map[$id] = $item
    }

    return $map
}

function Assert-RequiredValuesPresent {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Values,
        [Parameter(Mandatory = $true)]
        [string[]]$RequiredValues,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($requiredValue in $RequiredValues) {
        if ($Values -notcontains $requiredValue) {
            throw "$Context must include '$requiredValue'."
        }
    }
}

function Test-TextHasNegation {
    param(
        [AllowNull()]
        [string]$Text
    )

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return $false
    }

    return $Text -match '(?i)\b(no|not|without|does not|do not|must not|never|non-claim|non_claim|not implemented|not claimed|planned only|prohibited|forbidden|disallowed)\b'
}

function Assert-NoOverclaimText {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Values,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($value in $Values) {
        foreach ($pattern in $script:OverclaimPatterns) {
            if ($value -match [regex]::Escape($pattern) -and -not (Test-TextHasNegation -Text $value)) {
                throw "$Context contains overclaim text '$pattern'."
            }
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

function Assert-ProofByItselfAllowed {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ClassId,
        [Parameter(Mandatory = $true)]
        [string]$EvidenceKind,
        [Parameter(Mandatory = $true)]
        [string]$ProofStatus,
        [Parameter(Mandatory = $true)]
        [bool]$ClassAllowsProofByItself,
        [Parameter(Mandatory = $true)]
        [bool]$EvidenceAllowsProofByItself,
        [string]$Path = "",
        [string]$Context = "repo knowledge index entry"
    )

    if ($ProofStatus -ne "proof_by_itself_true") {
        return
    }

    if ($script:GeneratedOrNarrativeClasses -contains $ClassId) {
        throw "$Context class '$ClassId' cannot be proof by itself."
    }

    if ($script:GeneratedOrNarrativeEvidenceKinds -contains $EvidenceKind) {
        throw "$Context evidence kind '$EvidenceKind' cannot be proof by itself."
    }

    if (-not $ClassAllowsProofByItself -or -not $EvidenceAllowsProofByItself -or $script:ProofByItselfEvidenceKinds -notcontains $EvidenceKind) {
        throw "$Context proof_by_itself_true is disallowed by the R15-002 taxonomy."
    }

    if ($Path -match '(?i)\.md$' -and $EvidenceKind -notin $script:ProofByItselfEvidenceKinds) {
        throw "$Context generated Markdown cannot be proof by itself."
    }
}

function Test-ExplicitExternalRef {
    param(
        [AllowNull()]
        [string]$Reference
    )

    if ([string]::IsNullOrWhiteSpace($Reference)) {
        return $false
    }

    return $Reference -match '^(external|url|github|artifact|manual|future):\S+'
}

function Assert-RelationshipReference {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Reference,
        [Parameter(Mandatory = $true)]
        [hashtable]$EntryIds,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($EntryIds.ContainsKey($Reference) -or (Test-ExplicitExternalRef -Reference $Reference)) {
        return
    }

    throw "$Context relationship reference '$Reference' does not point to a known entry_id or explicit external ref."
}

function Assert-RelatedEntries {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [object[]]$RelatedEntries,
        [Parameter(Mandatory = $true)]
        [hashtable]$EntryIds,
        [Parameter(Mandatory = $true)]
        [string[]]$RelationshipTypes,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($relatedEntry in $RelatedEntries) {
        $relationshipType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $relatedEntry -Name "relationship_type" -Context $Context) -Context "$Context relationship_type"
        if ($RelationshipTypes -notcontains $relationshipType) {
            throw "$Context uses invalid relationship_type '$relationshipType'."
        }

        $targetCount = 0
        if (Test-HasProperty -Object $relatedEntry -Name "target_entry_id") {
            $target = Assert-NonEmptyString -Value $relatedEntry.target_entry_id -Context "$Context target_entry_id"
            Assert-RelationshipReference -Reference $target -EntryIds $EntryIds -Context $Context
            $targetCount += 1
        }

        if (Test-HasProperty -Object $relatedEntry -Name "external_ref") {
            $externalRef = Assert-NonEmptyString -Value $relatedEntry.external_ref -Context "$Context external_ref"
            if (-not (Test-ExplicitExternalRef -Reference $externalRef)) {
                throw "$Context external_ref '$externalRef' must use an explicit external ref prefix."
            }
            $targetCount += 1
        }

        if ($targetCount -ne 1) {
            throw "$Context related_entries items must declare exactly one target_entry_id or external_ref."
        }

        if (Test-HasProperty -Object $relatedEntry -Name "reason") {
            Assert-NonEmptyString -Value $relatedEntry.reason -Context "$Context related_entries reason" | Out-Null
        }
    }
}

function Get-R15RepoKnowledgeIndex {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$IndexPath
    )

    return Read-SingleJsonObject -Path $IndexPath -Label "R15 repo knowledge index"
}

function Test-R15RepoKnowledgeIndexObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Index,
        [Parameter(Mandatory = $true)]
        $Taxonomy,
        [string]$SourceLabel = "R15 repo knowledge index"
    )

    foreach ($field in $script:RequiredTopLevelFields) {
        Get-RequiredProperty -Object $Index -Name $field -Context $SourceLabel | Out-Null
    }

    if ($Index.artifact_type -ne "r15_repo_knowledge_index") {
        throw "$SourceLabel artifact_type must be 'r15_repo_knowledge_index'."
    }

    Assert-NonEmptyString -Value $Index.contract_version -Context "$SourceLabel contract_version" | Out-Null
    Assert-NonEmptyString -Value $Index.index_id -Context "$SourceLabel index_id" | Out-Null
    if ($Index.source_milestone -ne "R15 Knowledge Base, Agent Identity, Memory, and RACI Foundations") {
        throw "$SourceLabel source_milestone must be the R15 milestone title."
    }
    if ($Index.source_task -ne "R15-003") {
        throw "$SourceLabel source_task must be R15-003."
    }
    Assert-NonEmptyString -Value $Index.generated_from_head -Context "$SourceLabel generated_from_head" | Out-Null
    Assert-NonEmptyString -Value $Index.generated_from_tree -Context "$SourceLabel generated_from_tree" | Out-Null

    Assert-ObjectValue -Value $Index.taxonomy_ref -Context "$SourceLabel taxonomy_ref" | Out-Null
    foreach ($field in @("taxonomy_id", "path", "contract_path", "source_task")) {
        Get-RequiredProperty -Object $Index.taxonomy_ref -Name $field -Context "$SourceLabel taxonomy_ref" | Out-Null
    }
    Assert-NonEmptyString -Value $Index.taxonomy_ref.taxonomy_id -Context "$SourceLabel taxonomy_ref taxonomy_id" | Out-Null
    Assert-PathExists -Path (Assert-NonEmptyString -Value $Index.taxonomy_ref.path -Context "$SourceLabel taxonomy_ref path") -Context "$SourceLabel taxonomy_ref" | Out-Null
    Assert-PathExists -Path (Assert-NonEmptyString -Value $Index.taxonomy_ref.contract_path -Context "$SourceLabel taxonomy_ref contract_path") -Context "$SourceLabel taxonomy_ref" | Out-Null
    if ($Index.taxonomy_ref.taxonomy_id -ne $Taxonomy.taxonomy_id) {
        throw "$SourceLabel taxonomy_ref taxonomy_id must match the loaded R15-002 taxonomy."
    }
    if ($Index.taxonomy_ref.source_task -ne "R15-002") {
        throw "$SourceLabel taxonomy_ref source_task must be R15-002."
    }

    Assert-ObjectValue -Value $Index.index_scope -Context "$SourceLabel index_scope" | Out-Null
    foreach ($field in @("bounded_seed_only", "full_repo_index", "future_fuller_index_requires_later_task")) {
        Get-RequiredProperty -Object $Index.index_scope -Name $field -Context "$SourceLabel index_scope" | Out-Null
    }
    if (-not (Assert-BooleanValue -Value $Index.index_scope.bounded_seed_only -Context "$SourceLabel index_scope bounded_seed_only")) {
        throw "$SourceLabel index_scope bounded_seed_only must be true."
    }
    if (Assert-BooleanValue -Value $Index.index_scope.full_repo_index -Context "$SourceLabel index_scope full_repo_index") {
        throw "$SourceLabel full repo index is prohibited for R15-003."
    }
    if (-not (Assert-BooleanValue -Value $Index.index_scope.future_fuller_index_requires_later_task -Context "$SourceLabel index_scope future_fuller_index_requires_later_task")) {
        throw "$SourceLabel future_fuller_index_requires_later_task must be true."
    }

    $taxonomySummary = Test-R15ArtifactClassificationTaxonomyObject -Taxonomy $Taxonomy -SourceLabel "$SourceLabel taxonomy dependency"
    if ($taxonomySummary.SourceTask -ne "R15-002") {
        throw "$SourceLabel taxonomy dependency must come from R15-002."
    }

    $classificationClassMap = New-ValueSet -Items @($Taxonomy.classification_classes) -FieldName "class_id" -Context "$SourceLabel taxonomy classification_classes"
    $evidenceKindMap = New-ValueSet -Items @($Taxonomy.evidence_kinds) -FieldName "evidence_kind" -Context "$SourceLabel taxonomy evidence_kinds"
    $authorityKindMap = New-ValueSet -Items @($Taxonomy.authority_kinds) -FieldName "authority_kind" -Context "$SourceLabel taxonomy authority_kinds"
    $lifecycleStateMap = New-ValueSet -Items @($Taxonomy.lifecycle_states) -FieldName "lifecycle_state" -Context "$SourceLabel taxonomy lifecycle_states"
    $proofStatusMap = New-ValueSet -Items @($Taxonomy.proof_status_values) -FieldName "proof_status" -Context "$SourceLabel taxonomy proof_status_values"

    $requiredEntryFields = Assert-StringArray -Value $Index.required_entry_fields -Context "$SourceLabel required_entry_fields"
    Assert-RequiredValuesPresent -Values $requiredEntryFields -RequiredValues $script:RequiredEntryFields -Context "$SourceLabel required_entry_fields"

    $allowedArtifactClasses = Assert-StringArray -Value $Index.allowed_artifact_classes -Context "$SourceLabel allowed_artifact_classes"
    $allowedEvidenceKinds = Assert-StringArray -Value $Index.allowed_evidence_kinds -Context "$SourceLabel allowed_evidence_kinds"
    $allowedAuthorityKinds = Assert-StringArray -Value $Index.allowed_authority_kinds -Context "$SourceLabel allowed_authority_kinds"
    $allowedLifecycleStates = Assert-StringArray -Value $Index.allowed_lifecycle_states -Context "$SourceLabel allowed_lifecycle_states"
    $allowedProofStatuses = Assert-StringArray -Value $Index.allowed_proof_status_values -Context "$SourceLabel allowed_proof_status_values"
    $relationshipTypes = Assert-StringArray -Value $Index.relationship_types -Context "$SourceLabel relationship_types"
    $lookupProfiles = Assert-StringArray -Value $Index.lookup_profiles -Context "$SourceLabel lookup_profiles"

    Assert-RequiredValuesPresent -Values $relationshipTypes -RequiredValues $script:RequiredRelationshipTypes -Context "$SourceLabel relationship_types"
    Assert-RequiredValuesPresent -Values $lookupProfiles -RequiredValues $script:RequiredLookupProfiles -Context "$SourceLabel lookup_profiles"

    foreach ($value in $allowedArtifactClasses) {
        if (-not $classificationClassMap.ContainsKey($value)) {
            throw "$SourceLabel allowed_artifact_classes contains unknown classification class '$value'."
        }
    }
    foreach ($value in $allowedEvidenceKinds) {
        if (-not $evidenceKindMap.ContainsKey($value)) {
            throw "$SourceLabel allowed_evidence_kinds contains unknown evidence kind '$value'."
        }
    }
    foreach ($value in $allowedAuthorityKinds) {
        if (-not $authorityKindMap.ContainsKey($value)) {
            throw "$SourceLabel allowed_authority_kinds contains unknown authority kind '$value'."
        }
    }
    foreach ($value in $allowedLifecycleStates) {
        if (-not $lifecycleStateMap.ContainsKey($value)) {
            throw "$SourceLabel allowed_lifecycle_states contains unknown lifecycle state '$value'."
        }
    }
    foreach ($value in $allowedProofStatuses) {
        if (-not $proofStatusMap.ContainsKey($value)) {
            throw "$SourceLabel allowed_proof_status_values contains unknown proof status '$value'."
        }
    }

    $invalidStateRules = Assert-ObjectArray -Value $Index.invalid_state_rules -Context "$SourceLabel invalid_state_rules"
    New-ValueSet -Items $invalidStateRules -FieldName "rule_id" -Context "$SourceLabel invalid_state_rules" | Out-Null
    foreach ($rule in $invalidStateRules) {
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $rule -Name "description" -Context "$SourceLabel invalid_state_rule") -Context "$SourceLabel invalid_state_rule description" | Out-Null
    }

    $nonClaims = Assert-StringArray -Value $Index.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel
    Assert-NoOverclaimText -Values $nonClaims -Context "$SourceLabel non_claims"

    if (Test-HasProperty -Object $Index -Name "claims") {
        Assert-NoOverclaimText -Values (Assert-StringArray -Value $Index.claims -Context "$SourceLabel claims" -AllowEmpty) -Context "$SourceLabel claims"
    }

    $entries = Assert-ObjectArray -Value $Index.index_entries -Context "$SourceLabel index_entries"
    $entryIdMap = @{}
    $pathMap = @{}

    foreach ($entry in $entries) {
        foreach ($requiredField in $requiredEntryFields) {
            Get-RequiredProperty -Object $entry -Name $requiredField -Context "$SourceLabel index entry" | Out-Null
        }

        $entryId = Assert-NonEmptyString -Value $entry.entry_id -Context "$SourceLabel index entry entry_id"
        if ($entryIdMap.ContainsKey($entryId)) {
            throw "$SourceLabel index_entries duplicate entry_id '$entryId'."
        }
        $entryIdMap[$entryId] = $entry

        $path = Assert-NonEmptyString -Value $entry.path -Context "$SourceLabel index entry '$entryId' path"
        Assert-PathExists -Path $path -Context "$SourceLabel index entry '$entryId'" | Out-Null
        if ($pathMap.ContainsKey($path)) {
            if (-not (Test-HasProperty -Object $entry -Name "duplicate_reason") -or [string]::IsNullOrWhiteSpace([string]$entry.duplicate_reason)) {
                throw "$SourceLabel index_entries duplicate path '$path' requires duplicate_reason."
            }
        }
        else {
            $pathMap[$path] = $entryId
        }
    }

    foreach ($entry in $entries) {
        $entryId = [string]$entry.entry_id
        $path = [string]$entry.path
        $title = Assert-NonEmptyString -Value $entry.title -Context "$SourceLabel index entry '$entryId' title"
        $summary = Assert-NonEmptyString -Value $entry.summary -Context "$SourceLabel index entry '$entryId' summary"
        $classId = Assert-NonEmptyString -Value $entry.classification_class -Context "$SourceLabel index entry '$entryId' classification_class"
        $evidenceKind = Assert-NonEmptyString -Value $entry.evidence_kind -Context "$SourceLabel index entry '$entryId' evidence_kind"
        $authorityKind = Assert-NonEmptyString -Value $entry.authority_kind -Context "$SourceLabel index entry '$entryId' authority_kind"
        $lifecycleState = Assert-NonEmptyString -Value $entry.lifecycle_state -Context "$SourceLabel index entry '$entryId' lifecycle_state"
        $proofStatus = Assert-NonEmptyString -Value $entry.proof_status -Context "$SourceLabel index entry '$entryId' proof_status"
        Assert-NonEmptyString -Value $entry.owner_role -Context "$SourceLabel index entry '$entryId' owner_role" | Out-Null
        Assert-NonEmptyString -Value $entry.source_milestone -Context "$SourceLabel index entry '$entryId' source_milestone" | Out-Null
        Assert-NonEmptyString -Value $entry.source_task -Context "$SourceLabel index entry '$entryId' source_task" | Out-Null
        Assert-NonEmptyString -Value $entry.last_verified_head -Context "$SourceLabel index entry '$entryId' last_verified_head" | Out-Null
        $reason = Assert-NonEmptyString -Value $entry.reason -Context "$SourceLabel index entry '$entryId' reason"
        $entryNonClaims = Assert-StringArray -Value $entry.non_claims -Context "$SourceLabel index entry '$entryId' non_claims" -AllowEmpty

        if (-not $classificationClassMap.ContainsKey($classId) -or $allowedArtifactClasses -notcontains $classId) {
            throw "$SourceLabel index entry '$entryId' uses unknown classification class '$classId'."
        }
        if (-not $evidenceKindMap.ContainsKey($evidenceKind) -or $allowedEvidenceKinds -notcontains $evidenceKind) {
            throw "$SourceLabel index entry '$entryId' uses unknown evidence kind '$evidenceKind'."
        }
        if (-not $authorityKindMap.ContainsKey($authorityKind) -or $allowedAuthorityKinds -notcontains $authorityKind) {
            throw "$SourceLabel index entry '$entryId' uses unknown authority kind '$authorityKind'."
        }
        if (-not $lifecycleStateMap.ContainsKey($lifecycleState) -or $allowedLifecycleStates -notcontains $lifecycleState) {
            throw "$SourceLabel index entry '$entryId' uses unknown lifecycle state '$lifecycleState'."
        }
        if (-not $proofStatusMap.ContainsKey($proofStatus) -or $allowedProofStatuses -notcontains $proofStatus) {
            throw "$SourceLabel index entry '$entryId' uses unknown proof status '$proofStatus'."
        }

        if (($classId -eq "unknown" -or $evidenceKind -eq "unknown" -or $authorityKind -eq "unknown" -or $lifecycleState -eq "unknown") -and [string]::IsNullOrWhiteSpace($reason)) {
            throw "$SourceLabel index entry '$entryId' unknown classification requires explicit reason."
        }

        $loadPriority = Assert-NonEmptyString -Value $entry.load_priority -Context "$SourceLabel index entry '$entryId' load_priority"
        if ($script:AllowedLoadPriorities -notcontains $loadPriority) {
            throw "$SourceLabel index entry '$entryId' has invalid load_priority '$loadPriority'."
        }
        $scanScope = Assert-NonEmptyString -Value $entry.scan_scope -Context "$SourceLabel index entry '$entryId' scan_scope"
        if ($script:AllowedScanScopes -notcontains $scanScope) {
            throw "$SourceLabel index entry '$entryId' has invalid scan_scope '$scanScope'."
        }

        $dependsOn = Assert-StringArray -Value $entry.depends_on -Context "$SourceLabel index entry '$entryId' depends_on" -AllowEmpty
        $supersedes = Assert-StringArray -Value $entry.supersedes -Context "$SourceLabel index entry '$entryId' supersedes" -AllowEmpty
        $supersededBy = Assert-StringArray -Value $entry.superseded_by -Context "$SourceLabel index entry '$entryId' superseded_by" -AllowEmpty
        $relatedEntries = Assert-ObjectArray -Value $entry.related_entries -Context "$SourceLabel index entry '$entryId' related_entries" -AllowEmpty
        Assert-StringArray -Value $entry.recommended_for_roles -Context "$SourceLabel index entry '$entryId' recommended_for_roles" -AllowEmpty | Out-Null

        foreach ($reference in @($dependsOn + $supersedes + $supersededBy)) {
            Assert-RelationshipReference -Reference $reference -EntryIds $entryIdMap -Context "$SourceLabel index entry '$entryId'"
        }
        Assert-RelatedEntries -RelatedEntries $relatedEntries -EntryIds $entryIdMap -RelationshipTypes $relationshipTypes -Context "$SourceLabel index entry '$entryId'"

        $classAllowsProofByItself = [bool]$classificationClassMap[$classId].proof_by_itself_allowed
        $evidenceAllowsProofByItself = [bool]$evidenceKindMap[$evidenceKind].proof_by_itself_allowed
        Assert-ProofByItselfAllowed -ClassId $classId -EvidenceKind $evidenceKind -ProofStatus $proofStatus -ClassAllowsProofByItself $classAllowsProofByItself -EvidenceAllowsProofByItself $evidenceAllowsProofByItself -Path $path -Context "$SourceLabel index entry '$entryId'"

        Assert-NoOverclaimText -Values @($title, $summary, $reason) -Context "$SourceLabel index entry '$entryId'"
        Assert-NoOverclaimText -Values $entryNonClaims -Context "$SourceLabel index entry '$entryId' non_claims"
    }

    return [pscustomobject]@{
        ArtifactType = $Index.artifact_type
        IndexId = $Index.index_id
        SourceTask = $Index.source_task
        EntryCount = $entries.Count
        BoundedSeedOnly = [bool]$Index.index_scope.bounded_seed_only
        FullRepoIndex = [bool]$Index.index_scope.full_repo_index
        TaxonomyId = $Index.taxonomy_ref.taxonomy_id
    }
}

function Test-R15RepoKnowledgeIndex {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$IndexPath,
        [Parameter(Mandatory = $true)]
        [string]$TaxonomyPath
    )

    $index = Get-R15RepoKnowledgeIndex -IndexPath $IndexPath
    $taxonomy = Get-R15ArtifactClassificationTaxonomy -TaxonomyPath $TaxonomyPath
    return Test-R15RepoKnowledgeIndexObject -Index $index -Taxonomy $taxonomy -SourceLabel $IndexPath
}

Export-ModuleMember -Function Get-R15RepoKnowledgeIndex, Test-R15RepoKnowledgeIndexObject, Test-R15RepoKnowledgeIndex
