Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$script:RequiredClassificationClasses = @(
    "constitutional_truth",
    "operating_model",
    "domain_model",
    "contract",
    "tool",
    "test",
    "status_surface",
    "evidence_package",
    "machine_evidence",
    "generated_operator_artifact",
    "report",
    "template",
    "historical_archive",
    "deprecated",
    "candidate",
    "cleanup_candidate",
    "external_mirror",
    "external_evidence",
    "unknown"
)

$script:RequiredEvidenceKinds = @(
    "implemented_code",
    "generated_artifact",
    "operator_artifact",
    "external_replay_evidence",
    "status_doc",
    "governance_doc",
    "planning_doc",
    "validation_manifest",
    "test_result",
    "unknown"
)

$script:RequiredAuthorityKinds = @(
    "constitutional_authority",
    "governance_authority",
    "operating_authority",
    "contract_authority",
    "status_authority",
    "proof_authority",
    "planning_context",
    "report_context",
    "non_authoritative_reference",
    "unknown"
)

$script:RequiredLifecycleStates = @(
    "current",
    "active",
    "planned",
    "historical",
    "superseded",
    "deprecated",
    "candidate",
    "cleanup_candidate",
    "unknown"
)

$script:RequiredProofStatuses = @(
    "proof_by_itself_false",
    "proof_by_itself_true",
    "requires_machine_evidence",
    "external_evidence_required",
    "operator_artifact_only",
    "historical_context_only"
)

$script:RequiredClassificationRecordFields = @(
    "artifact_id",
    "path",
    "classification_class",
    "evidence_kind",
    "authority_kind",
    "lifecycle_state",
    "proof_status",
    "reason",
    "source_task",
    "last_verified_head",
    "non_claims"
)

$script:RequiredNonClaims = @(
    "no full repo artifacts classified by R15-002",
    "no repo knowledge index implemented by R15-002",
    "no artifact registry engine implemented by R15-002",
    "no knowledge base implemented by R15-002",
    "no deprecated files cleaned by R15-002",
    "no cleanup decisions approved by R15-002",
    "no agent identity packets implemented by R15-002",
    "no memory scopes implemented by R15-002",
    "no RACI matrix implemented by R15-002",
    "no card re-entry packets implemented by R15-002",
    "no classification or re-entry dry run executed by R15-002",
    "no final R15 proof package complete by R15-002",
    "no product runtime",
    "no board runtime",
    "no external board sync",
    "no Linear implementation",
    "no Symphony implementation",
    "no GitHub Projects implementation",
    "no custom board implementation",
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
    "productized control-room",
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
    "R16 opening"
)

function Get-RepositoryRoot {
    return $repoRoot
}

function Get-JsonDocument {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    return (Read-SingleJsonObject -Path $Path -Label $Label)
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

function Get-UniqueIdMap {
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

function Assert-RequiredIdsPresent {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Map,
        [Parameter(Mandatory = $true)]
        [string[]]$RequiredIds,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    foreach ($requiredId in $RequiredIds) {
        if (-not $Map.ContainsKey($requiredId)) {
            throw "Taxonomy is missing required $Label '$requiredId'."
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

    return $Text -match '(?i)\b(no|not|without|does not|do not|must not|never|non-claim|non_claim|not implemented|not claimed|planned only)\b'
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
        [string]$Context = "classification"
    )

    if ($ProofStatus -ne "proof_by_itself_true") {
        return
    }

    if ($script:GeneratedOrNarrativeClasses -contains $ClassId) {
        throw "$Context class '$ClassId' cannot be proof by itself; reports and generated operator artifacts require supporting evidence."
    }

    if ($script:GeneratedOrNarrativeEvidenceKinds -contains $EvidenceKind) {
        throw "$Context evidence kind '$EvidenceKind' cannot be proof by itself for reports or generated Markdown."
    }

    if (-not $ClassAllowsProofByItself -or -not $EvidenceAllowsProofByItself -or $script:ProofByItselfEvidenceKinds -notcontains $EvidenceKind) {
        throw "$Context proof_by_itself_true requires an explicitly allowed proof status and evidence type."
    }

    if ($Path -match '(?i)\.md$' -and $EvidenceKind -notin $script:ProofByItselfEvidenceKinds) {
        throw "$Context generated Markdown cannot be proof by itself without explicit machine evidence."
    }
}

function Test-R15ArtifactClassificationTaxonomyObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Taxonomy,
        [string]$SourceLabel = "R15 artifact classification taxonomy"
    )

    foreach ($field in @(
            "artifact_type",
            "contract_version",
            "taxonomy_id",
            "source_milestone",
            "source_task",
            "classification_classes",
            "evidence_kinds",
            "authority_kinds",
            "lifecycle_states",
            "proof_status_values",
            "required_fields_for_classification_records",
            "invalid_state_rules",
            "non_claims"
        )) {
        Get-RequiredProperty -Object $Taxonomy -Name $field -Context $SourceLabel | Out-Null
    }

    if ($Taxonomy.artifact_type -ne "r15_artifact_classification_taxonomy") {
        throw "$SourceLabel artifact_type must be 'r15_artifact_classification_taxonomy'."
    }
    Assert-NonEmptyString -Value $Taxonomy.contract_version -Context "$SourceLabel contract_version" | Out-Null
    Assert-NonEmptyString -Value $Taxonomy.taxonomy_id -Context "$SourceLabel taxonomy_id" | Out-Null
    if ($Taxonomy.source_milestone -ne "R15 Knowledge Base, Agent Identity, Memory, and RACI Foundations") {
        throw "$SourceLabel source_milestone must be the R15 milestone title."
    }
    if ($Taxonomy.source_task -ne "R15-002") {
        throw "$SourceLabel source_task must be R15-002."
    }

    $classificationClasses = Assert-ObjectArray -Value $Taxonomy.classification_classes -Context "$SourceLabel classification_classes"
    $evidenceKinds = Assert-ObjectArray -Value $Taxonomy.evidence_kinds -Context "$SourceLabel evidence_kinds"
    $authorityKinds = Assert-ObjectArray -Value $Taxonomy.authority_kinds -Context "$SourceLabel authority_kinds"
    $lifecycleStates = Assert-ObjectArray -Value $Taxonomy.lifecycle_states -Context "$SourceLabel lifecycle_states"
    $proofStatuses = Assert-ObjectArray -Value $Taxonomy.proof_status_values -Context "$SourceLabel proof_status_values"

    $classificationClassMap = Get-UniqueIdMap -Items $classificationClasses -FieldName "class_id" -Context "$SourceLabel classification_classes"
    $evidenceKindMap = Get-UniqueIdMap -Items $evidenceKinds -FieldName "evidence_kind" -Context "$SourceLabel evidence_kinds"
    $authorityKindMap = Get-UniqueIdMap -Items $authorityKinds -FieldName "authority_kind" -Context "$SourceLabel authority_kinds"
    $lifecycleStateMap = Get-UniqueIdMap -Items $lifecycleStates -FieldName "lifecycle_state" -Context "$SourceLabel lifecycle_states"
    $proofStatusMap = Get-UniqueIdMap -Items $proofStatuses -FieldName "proof_status" -Context "$SourceLabel proof_status_values"

    Assert-RequiredIdsPresent -Map $classificationClassMap -RequiredIds $script:RequiredClassificationClasses -Label "classification class"
    Assert-RequiredIdsPresent -Map $evidenceKindMap -RequiredIds $script:RequiredEvidenceKinds -Label "evidence kind"
    Assert-RequiredIdsPresent -Map $authorityKindMap -RequiredIds $script:RequiredAuthorityKinds -Label "authority kind"
    Assert-RequiredIdsPresent -Map $lifecycleStateMap -RequiredIds $script:RequiredLifecycleStates -Label "lifecycle state"
    Assert-RequiredIdsPresent -Map $proofStatusMap -RequiredIds $script:RequiredProofStatuses -Label "proof status"

    foreach ($class in $classificationClasses) {
        $classId = Assert-NonEmptyString -Value $class.class_id -Context "$SourceLabel class_id"
        foreach ($field in @("description", "default_evidence_kind", "default_authority_kind", "default_lifecycle_state", "default_proof_status", "proof_by_itself_allowed", "requires_explicit_reason")) {
            Get-RequiredProperty -Object $class -Name $field -Context "$SourceLabel classification class '$classId'" | Out-Null
        }

        Assert-NonEmptyString -Value $class.description -Context "$SourceLabel $classId description" | Out-Null
        $defaultEvidenceKind = Assert-NonEmptyString -Value $class.default_evidence_kind -Context "$SourceLabel $classId default_evidence_kind"
        $defaultAuthorityKind = Assert-NonEmptyString -Value $class.default_authority_kind -Context "$SourceLabel $classId default_authority_kind"
        $defaultLifecycleState = Assert-NonEmptyString -Value $class.default_lifecycle_state -Context "$SourceLabel $classId default_lifecycle_state"
        $defaultProofStatus = Assert-NonEmptyString -Value $class.default_proof_status -Context "$SourceLabel $classId default_proof_status"
        $classAllowsProofByItself = Assert-BooleanValue -Value $class.proof_by_itself_allowed -Context "$SourceLabel $classId proof_by_itself_allowed"
        $requiresReason = Assert-BooleanValue -Value $class.requires_explicit_reason -Context "$SourceLabel $classId requires_explicit_reason"

        if (-not $evidenceKindMap.ContainsKey($defaultEvidenceKind)) {
            throw "$SourceLabel classification class '$classId' uses unknown evidence kind '$defaultEvidenceKind'."
        }
        if (-not $authorityKindMap.ContainsKey($defaultAuthorityKind)) {
            throw "$SourceLabel classification class '$classId' uses unknown authority kind '$defaultAuthorityKind'."
        }
        if (-not $lifecycleStateMap.ContainsKey($defaultLifecycleState)) {
            throw "$SourceLabel classification class '$classId' uses unknown lifecycle state '$defaultLifecycleState'."
        }
        if (-not $proofStatusMap.ContainsKey($defaultProofStatus)) {
            throw "$SourceLabel classification class '$classId' uses unknown proof status '$defaultProofStatus'."
        }
        if ($classId -eq "unknown" -and -not $requiresReason) {
            throw "$SourceLabel unknown classification class must require an explicit reason."
        }

        $evidenceAllowsProofByItself = [bool]$evidenceKindMap[$defaultEvidenceKind].proof_by_itself_allowed
        Assert-ProofByItselfAllowed -ClassId $classId -EvidenceKind $defaultEvidenceKind -ProofStatus $defaultProofStatus -ClassAllowsProofByItself $classAllowsProofByItself -EvidenceAllowsProofByItself $evidenceAllowsProofByItself -Context "$SourceLabel classification class '$classId'"
    }

    foreach ($evidenceKind in $evidenceKinds) {
        $id = Assert-NonEmptyString -Value $evidenceKind.evidence_kind -Context "$SourceLabel evidence_kind"
        foreach ($field in @("description", "proof_by_itself_allowed")) {
            Get-RequiredProperty -Object $evidenceKind -Name $field -Context "$SourceLabel evidence kind '$id'" | Out-Null
        }
        Assert-NonEmptyString -Value $evidenceKind.description -Context "$SourceLabel $id description" | Out-Null
        $allowsProof = Assert-BooleanValue -Value $evidenceKind.proof_by_itself_allowed -Context "$SourceLabel $id proof_by_itself_allowed"
        if ($allowsProof -and $script:ProofByItselfEvidenceKinds -notcontains $id) {
            throw "$SourceLabel evidence kind '$id' cannot allow proof by itself."
        }
    }

    foreach ($authorityKind in $authorityKinds) {
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $authorityKind -Name "description" -Context "$SourceLabel authority kind") -Context "$SourceLabel authority kind description" | Out-Null
    }
    foreach ($lifecycleState in $lifecycleStates) {
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $lifecycleState -Name "description" -Context "$SourceLabel lifecycle state") -Context "$SourceLabel lifecycle state description" | Out-Null
    }
    foreach ($proofStatus in $proofStatuses) {
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $proofStatus -Name "description" -Context "$SourceLabel proof status") -Context "$SourceLabel proof status description" | Out-Null
    }

    $requiredRecordFields = Assert-StringArray -Value $Taxonomy.required_fields_for_classification_records -Context "$SourceLabel required_fields_for_classification_records"
    foreach ($requiredField in $script:RequiredClassificationRecordFields) {
        if ($requiredRecordFields -notcontains $requiredField) {
            throw "$SourceLabel required_fields_for_classification_records must include '$requiredField'."
        }
    }

    $invalidStateRules = Assert-ObjectArray -Value $Taxonomy.invalid_state_rules -Context "$SourceLabel invalid_state_rules"
    Get-UniqueIdMap -Items $invalidStateRules -FieldName "rule_id" -Context "$SourceLabel invalid_state_rules" | Out-Null
    foreach ($rule in $invalidStateRules) {
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $rule -Name "description" -Context "$SourceLabel invalid state rule") -Context "$SourceLabel invalid state rule description" | Out-Null
    }

    $nonClaims = Assert-StringArray -Value $Taxonomy.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel
    Assert-NoOverclaimText -Values $nonClaims -Context "$SourceLabel non_claims"

    if (Test-HasProperty -Object $Taxonomy -Name "claims") {
        $claims = Assert-StringArray -Value $Taxonomy.claims -Context "$SourceLabel claims" -AllowEmpty
        Assert-NoOverclaimText -Values $claims -Context "$SourceLabel claims"
    }

    $classificationRecordCount = 0
    if (Test-HasProperty -Object $Taxonomy -Name "classification_records") {
        $records = Assert-ObjectArray -Value $Taxonomy.classification_records -Context "$SourceLabel classification_records" -AllowEmpty
        $classificationRecordCount = $records.Count
        foreach ($record in $records) {
            foreach ($requiredField in $requiredRecordFields) {
                Get-RequiredProperty -Object $record -Name $requiredField -Context "$SourceLabel classification record" | Out-Null
            }

            $artifactId = Assert-NonEmptyString -Value $record.artifact_id -Context "$SourceLabel classification record artifact_id"
            $path = Assert-NonEmptyString -Value $record.path -Context "$SourceLabel classification record '$artifactId' path"
            $classId = Assert-NonEmptyString -Value $record.classification_class -Context "$SourceLabel classification record '$artifactId' classification_class"
            $evidenceKind = Assert-NonEmptyString -Value $record.evidence_kind -Context "$SourceLabel classification record '$artifactId' evidence_kind"
            $authorityKind = Assert-NonEmptyString -Value $record.authority_kind -Context "$SourceLabel classification record '$artifactId' authority_kind"
            $lifecycleState = Assert-NonEmptyString -Value $record.lifecycle_state -Context "$SourceLabel classification record '$artifactId' lifecycle_state"
            $proofStatus = Assert-NonEmptyString -Value $record.proof_status -Context "$SourceLabel classification record '$artifactId' proof_status"
            $reason = Assert-NonEmptyString -Value $record.reason -Context "$SourceLabel classification record '$artifactId' reason"
            Assert-NonEmptyString -Value $record.source_task -Context "$SourceLabel classification record '$artifactId' source_task" | Out-Null
            Assert-NonEmptyString -Value $record.last_verified_head -Context "$SourceLabel classification record '$artifactId' last_verified_head" | Out-Null
            Assert-StringArray -Value $record.non_claims -Context "$SourceLabel classification record '$artifactId' non_claims" | Out-Null

            if (-not $classificationClassMap.ContainsKey($classId)) {
                throw "$SourceLabel classification record '$artifactId' uses unknown classification class '$classId'."
            }
            if (-not $evidenceKindMap.ContainsKey($evidenceKind)) {
                throw "$SourceLabel classification record '$artifactId' uses unknown evidence kind '$evidenceKind'."
            }
            if (-not $authorityKindMap.ContainsKey($authorityKind)) {
                throw "$SourceLabel classification record '$artifactId' uses unknown authority kind '$authorityKind'."
            }
            if (-not $lifecycleStateMap.ContainsKey($lifecycleState)) {
                throw "$SourceLabel classification record '$artifactId' uses unknown lifecycle state '$lifecycleState'."
            }
            if (-not $proofStatusMap.ContainsKey($proofStatus)) {
                throw "$SourceLabel classification record '$artifactId' uses unknown proof status '$proofStatus'."
            }
            if (($classId -eq "unknown" -or $evidenceKind -eq "unknown" -or $authorityKind -eq "unknown" -or $lifecycleState -eq "unknown") -and [string]::IsNullOrWhiteSpace($reason)) {
                throw "$SourceLabel classification record '$artifactId' unknown classification requires explicit reason."
            }

            $classAllowsProofByItself = [bool]$classificationClassMap[$classId].proof_by_itself_allowed
            $evidenceAllowsProofByItself = [bool]$evidenceKindMap[$evidenceKind].proof_by_itself_allowed
            Assert-ProofByItselfAllowed -ClassId $classId -EvidenceKind $evidenceKind -ProofStatus $proofStatus -ClassAllowsProofByItself $classAllowsProofByItself -EvidenceAllowsProofByItself $evidenceAllowsProofByItself -Path $path -Context "$SourceLabel classification record '$artifactId'"
        }
    }

    return [pscustomobject]@{
        ArtifactType = $Taxonomy.artifact_type
        TaxonomyId = $Taxonomy.taxonomy_id
        SourceTask = $Taxonomy.source_task
        ClassificationClassCount = $classificationClasses.Count
        EvidenceKindCount = $evidenceKinds.Count
        AuthorityKindCount = $authorityKinds.Count
        LifecycleStateCount = $lifecycleStates.Count
        ProofStatusCount = $proofStatuses.Count
        ClassificationRecordCount = $classificationRecordCount
    }
}

function Get-R15ArtifactClassificationTaxonomy {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TaxonomyPath
    )

    return Get-JsonDocument -Path $TaxonomyPath -Label "R15 artifact classification taxonomy"
}

function Test-R15ArtifactClassificationTaxonomy {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TaxonomyPath
    )

    $taxonomy = Get-R15ArtifactClassificationTaxonomy -TaxonomyPath $TaxonomyPath
    return Test-R15ArtifactClassificationTaxonomyObject -Taxonomy $taxonomy -SourceLabel $TaxonomyPath
}

Export-ModuleMember -Function Get-R15ArtifactClassificationTaxonomy, Test-R15ArtifactClassificationTaxonomyObject, Test-R15ArtifactClassificationTaxonomy
