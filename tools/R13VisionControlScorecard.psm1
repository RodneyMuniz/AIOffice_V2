Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$script:R13VisionControlSubScoreWeights = [ordered]@{
    intent_defined = 10
    contract_or_design = 15
    implemented_tooling = 20
    execution_evidence = 25
    operator_usable = 20
    current_integrated = 10
}

$script:R13VisionControlSegmentWeights = [ordered]@{
    "Product" = 30
    "Workflow" = 30
    "Architecture" = 25
    "Governance / Proof" = 15
}

$script:R13VisionControlPenaltyValues = @{
    stale_at_final_closeout = -10
    manual_chat_bridge = -10
    no_defect_fix_retest_cycle = -10
    manual_external_dispatch_import = -10
    local_only_where_external_planned = -5
    inconsistent_score_math = -5
}

$script:R13AcceptedUpliftEvidenceKinds = @(
    "implemented_code",
    "committed_machine_evidence",
    "external_replay_evidence"
)

$script:R13RequiredNonClaims = @(
    "R13 is not closed",
    "R14 or successor is not opened",
    "no production runtime",
    "no production QA",
    "no full product QA coverage",
    "no productized UI",
    "no productized control-room behavior",
    "no broad autonomy",
    "no solved Codex reliability",
    "no solved Codex context compaction",
    "generated Markdown and reports are not proof by themselves",
    "planning reports are methodology only, not product proof",
    "score uplift requires committed evidence refs",
    "no 10 to 15 percent progress claim from R13-015 scorecard"
)

$script:R12ReportedSegmentAverages = @{
    "Product" = 8.0
    "Workflow" = 51.0
    "Architecture" = 56.0
    "Governance / Proof" = 94.3
}

$script:R12ReportedWeightedAggregate = 48.2

$script:R13VisionControlItems = @(
    [pscustomobject]@{ item_id = "product_unified_workspace"; segment = "Product"; vision_category = "Unified workspace"; r6 = 8; r7 = 8; r8 = 8; r9 = 8; r10 = 8; r11 = 8; r12 = 9 },
    [pscustomobject]@{ item_id = "product_chat_intake_view"; segment = "Product"; vision_category = "Chat/intake view"; r6 = 7; r7 = 7; r8 = 7; r9 = 7; r10 = 7; r11 = 7; r12 = 7 },
    [pscustomobject]@{ item_id = "product_kanban_product_board"; segment = "Product"; vision_category = "Kanban/product board"; r6 = 6; r7 = 6; r8 = 6; r9 = 6; r10 = 6; r11 = 6; r12 = 7 },
    [pscustomobject]@{ item_id = "product_approvals_decision_queue"; segment = "Product"; vision_category = "Approvals/decision queue"; r6 = 20; r7 = 22; r8 = 22; r9 = 23; r10 = 24; r11 = 27; r12 = 30 },
    [pscustomobject]@{ item_id = "product_cost_dashboard"; segment = "Product"; vision_category = "Cost dashboard"; r6 = 0; r7 = 0; r8 = 0; r9 = 0; r10 = 0; r11 = 0; r12 = 0 },
    [pscustomobject]@{ item_id = "product_agent_skill_use_surface"; segment = "Product"; vision_category = "Agent/skill use surface"; r6 = 0; r7 = 0; r8 = 0; r9 = 0; r10 = 0; r11 = 0; r12 = 2 },
    [pscustomobject]@{ item_id = "workflow_request_tasking_execution_qa_loop"; segment = "Workflow"; vision_category = "Request -> tasking -> execution -> QA loop"; r6 = 35; r7 = 38; r8 = 42; r9 = 45; r10 = 48; r11 = 52; r12 = 55 },
    [pscustomobject]@{ item_id = "workflow_operator_approval_discipline"; segment = "Workflow"; vision_category = "Operator approval discipline"; r6 = 45; r7 = 48; r8 = 52; r9 = 55; r10 = 57; r11 = 60; r12 = 62 },
    [pscustomobject]@{ item_id = "workflow_qa_audit_loop"; segment = "Workflow"; vision_category = "QA/audit loop"; r6 = 45; r7 = 50; r8 = 58; r9 = 60; r10 = 64; r11 = 65; r12 = 67 },
    [pscustomobject]@{ item_id = "workflow_copy_paste_reduction_low_touch_cycle"; segment = "Workflow"; vision_category = "Copy/paste reduction / low-touch cycle"; r6 = 5; r7 = 8; r8 = 10; r9 = 12; r10 = 15; r11 = 18; r12 = 20 },
    [pscustomobject]@{ item_id = "architecture_persisted_state_truth_substrates"; segment = "Architecture"; vision_category = "Persisted state/truth substrates"; r6 = 80; r7 = 84; r8 = 88; r9 = 90; r10 = 92; r11 = 93; r12 = 95 },
    [pscustomobject]@{ item_id = "architecture_git_backed_remote_truth_final_head_support"; segment = "Architecture"; vision_category = "Git-backed remote truth/final-head support"; r6 = 45; r7 = 52; r8 = 58; r9 = 60; r10 = 65; r11 = 67; r12 = 70 },
    [pscustomobject]@{ item_id = "architecture_baton_resume_continuity"; segment = "Architecture"; vision_category = "Baton/resume/continuity"; r6 = 45; r7 = 55; r8 = 57; r9 = 60; r10 = 62; r11 = 66; r12 = 68 },
    [pscustomobject]@{ item_id = "architecture_ci_cd_external_proof"; segment = "Architecture"; vision_category = "CI/CD/external proof"; r6 = 35; r7 = 40; r8 = 50; r9 = 52; r10 = 65; r11 = 66; r12 = 72 },
    [pscustomobject]@{ item_id = "architecture_api_custom_app_execution_plane"; segment = "Architecture"; vision_category = "API/custom-app execution plane"; r6 = 5; r7 = 5; r8 = 8; r9 = 10; r10 = 18; r11 = 20; r12 = 25 },
    [pscustomobject]@{ item_id = "architecture_agent_skill_execution_architecture"; segment = "Architecture"; vision_category = "Agent/skill execution architecture"; r6 = 0; r7 = 0; r8 = 0; r9 = 0; r10 = 2; r11 = 4; r12 = 6 },
    [pscustomobject]@{ item_id = "governance_fail_closed_control_model"; segment = "Governance / Proof"; vision_category = "Fail-closed control model"; r6 = 80; r7 = 84; r8 = 88; r9 = 90; r10 = 92; r11 = 94; r12 = 95 },
    [pscustomobject]@{ item_id = "governance_traceable_artifacts_evidence"; segment = "Governance / Proof"; vision_category = "Traceable artifacts/evidence"; r6 = 82; r7 = 86; r8 = 90; r9 = 92; r10 = 94; r11 = 95; r12 = 96 },
    [pscustomobject]@{ item_id = "governance_anti_narration_discipline"; segment = "Governance / Proof"; vision_category = "Anti-narration discipline"; r6 = 75; r7 = 80; r8 = 84; r9 = 86; r10 = 88; r11 = 90; r12 = 92 },
    [pscustomobject]@{ item_id = "governance_replayable_audit_records"; segment = "Governance / Proof"; vision_category = "Replayable audit records"; r6 = 78; r7 = 82; r8 = 86; r9 = 88; r10 = 91; r11 = 92; r12 = 94 }
)

$script:R13VisionControlItemById = @{}
foreach ($item in $script:R13VisionControlItems) {
    $script:R13VisionControlItemById[$item.item_id] = $item
}

function Get-RepositoryRoot {
    return $repoRoot
}

function Join-RepositoryPath {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Segments
    )

    $path = Get-RepositoryRoot
    foreach ($segment in $Segments) {
        $path = Join-Path $path $segment
    }

    return $path
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
        [Parameter(Mandatory = $true)]
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

function Assert-NumberValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [double]$Minimum = 0,
        [double]$Maximum = 100
    )

    if (-not ($Value -is [byte] -or $Value -is [int] -or $Value -is [long] -or $Value -is [single] -or $Value -is [double] -or $Value -is [decimal])) {
        throw "$Context must be numeric."
    }

    $number = [double]$Value
    if ($number -lt $Minimum -or $number -gt $Maximum) {
        throw "$Context must be between $Minimum and $Maximum."
    }

    return $number
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

function Assert-RoundedNumber {
    param(
        [Parameter(Mandatory = $true)]
        [double]$Actual,
        [Parameter(Mandatory = $true)]
        [double]$Expected,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [double]$Tolerance = 0.01
    )

    if ([math]::Abs($Actual - $Expected) -gt $Tolerance) {
        throw "$Context must equal $Expected; actual $Actual."
    }
}

function Round-Score {
    param(
        [Parameter(Mandatory = $true)]
        [double]$Value
    )

    return [math]::Round($Value, 1, [System.MidpointRounding]::AwayFromZero)
}

function Convert-RepoRefToPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Ref
    )

    $relative = $Ref -replace '/', [System.IO.Path]::DirectorySeparatorChar
    return Join-Path (Get-RepositoryRoot) $relative
}

function Assert-ExistingRepoRef {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Ref,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ([System.IO.Path]::IsPathRooted($Ref) -or $Ref -match '^[a-zA-Z][a-zA-Z0-9+.-]*:') {
        throw "$Context ref '$Ref' must be repository-relative."
    }

    $resolved = Convert-RepoRefToPath -Ref $Ref
    if (-not (Test-Path -LiteralPath $resolved)) {
        throw "$Context ref '$Ref' does not exist."
    }
}

function Get-R13VisionControlContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "vision_control", "r13_vision_control_scorecard.contract.json")) -Label "R13 vision control scorecard contract"
}

function Assert-RequiredNonClaims {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$NonClaims,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($requiredNonClaim in $script:R13RequiredNonClaims) {
        if ($NonClaims -notcontains $requiredNonClaim) {
            throw "$Context non_claims must include '$requiredNonClaim'."
        }
    }
}

function Assert-RefIdsResolve {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$RefIds,
        [Parameter(Mandatory = $true)]
        [hashtable]$EvidenceById,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($refId in $RefIds) {
        if (-not $EvidenceById.ContainsKey($refId)) {
            throw "$Context evidence ref id '$refId' must resolve to top-level evidence_refs."
        }
    }
}

function Test-HasAcceptedUpliftEvidence {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$RefIds,
        [Parameter(Mandatory = $true)]
        [hashtable]$EvidenceById
    )

    foreach ($refId in $RefIds) {
        $evidence = $EvidenceById[$refId]
        if ($script:R13AcceptedUpliftEvidenceKinds -contains [string]$evidence.evidence_kind) {
            return $true
        }
    }

    return $false
}

function Test-R13VisionControlScorecardObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Scorecard,
        [string]$SourceLabel = "R13 vision control scorecard"
    )

    $contract = Get-R13VisionControlContract
    $contractWeights = Assert-ObjectValue -Value (Get-RequiredProperty -Object $contract -Name "sub_score_weights" -Context "R13 vision control contract") -Context "R13 vision control contract sub_score_weights"
    $contractWeightTotal = 0
    foreach ($subScoreName in $script:R13VisionControlSubScoreWeights.Keys) {
        $contractWeight = Assert-NumberValue -Value (Get-RequiredProperty -Object $contractWeights -Name $subScoreName -Context "R13 vision control contract sub_score_weights") -Context "R13 vision control contract $subScoreName weight"
        $expectedWeight = [double]$script:R13VisionControlSubScoreWeights[$subScoreName]
        Assert-RoundedNumber -Actual $contractWeight -Expected $expectedWeight -Context "R13 vision control contract $subScoreName weight"
        $contractWeightTotal += $contractWeight
    }
    Assert-RoundedNumber -Actual $contractWeightTotal -Expected 100 -Context "R13 vision control contract sub_score_weights total"

    foreach ($field in @(
            "contract_version",
            "artifact_type",
            "repository",
            "branch",
            "milestone",
            "source_task",
            "generated_from_head",
            "generated_from_tree",
            "source_methodology_artifact",
            "evidence_source_package",
            "measurement_posture",
            "scoring_formula",
            "evidence_refs",
            "items",
            "segment_kpis",
            "weighted_aggregate",
            "gate_assessment",
            "non_claims"
        )) {
        Get-RequiredProperty -Object $Scorecard -Name $field -Context $SourceLabel | Out-Null
    }

    if ($Scorecard.artifact_type -ne "r13_vision_control_scorecard") {
        throw "$SourceLabel artifact_type must be 'r13_vision_control_scorecard'."
    }
    if ($Scorecard.repository -ne "AIOffice_V2") {
        throw "$SourceLabel repository must be AIOffice_V2."
    }
    if ($Scorecard.branch -ne "release/r13-api-first-qa-pipeline-and-operator-control-room-product-slice") {
        throw "$SourceLabel branch must be release/r13-api-first-qa-pipeline-and-operator-control-room-product-slice."
    }
    if ($Scorecard.milestone -ne "R13 API-First QA Pipeline and Operator Control-Room Product Slice") {
        throw "$SourceLabel milestone must be the R13 milestone title."
    }
    if ($Scorecard.source_task -ne "R13-015") {
        throw "$SourceLabel source_task must be R13-015."
    }
    Assert-NonEmptyString -Value $Scorecard.generated_from_head -Context "$SourceLabel generated_from_head" | Out-Null
    Assert-NonEmptyString -Value $Scorecard.generated_from_tree -Context "$SourceLabel generated_from_tree" | Out-Null

    $methodology = Assert-ObjectValue -Value $Scorecard.source_methodology_artifact -Context "$SourceLabel source_methodology_artifact"
    $methodologyPath = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $methodology -Name "path" -Context "$SourceLabel source_methodology_artifact") -Context "$SourceLabel source_methodology_artifact.path"
    if ($methodologyPath -ne "governance/reports/AIOffice_V2_R12_Audit_and_R13_Planning_Report_v1.md") {
        throw "$SourceLabel source_methodology_artifact.path must cite the R12/R13 planning report."
    }
    Assert-ExistingRepoRef -Ref $methodologyPath -Context "$SourceLabel source_methodology_artifact"
    $methodologyProofAuthority = Assert-BooleanValue -Value (Get-RequiredProperty -Object $methodology -Name "proof_authority" -Context "$SourceLabel source_methodology_artifact") -Context "$SourceLabel source_methodology_artifact.proof_authority"
    if ($methodologyProofAuthority) {
        throw "$SourceLabel source_methodology_artifact cannot be product proof authority."
    }

    $sourcePackage = Assert-ObjectValue -Value $Scorecard.evidence_source_package -Context "$SourceLabel evidence_source_package"
    $sourcePackageRef = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $sourcePackage -Name "ref" -Context "$SourceLabel evidence_source_package") -Context "$SourceLabel evidence_source_package.ref"
    if ($sourcePackageRef -ne "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/evidence/r13_014_cycle_evidence_package.json") {
        throw "$SourceLabel evidence_source_package.ref must cite the R13-014 cycle evidence package."
    }
    Assert-ExistingRepoRef -Ref $sourcePackageRef -Context "$SourceLabel evidence_source_package"

    $posture = Assert-ObjectValue -Value $Scorecard.measurement_posture -Context "$SourceLabel measurement_posture"
    foreach ($field in @("targets_are_not_proof", "planning_reports_methodology_only", "generated_markdown_not_proof_by_itself", "committed_evidence_required_for_uplift", "current_scorecard_is_machine_calculated")) {
        $value = Assert-BooleanValue -Value (Get-RequiredProperty -Object $posture -Name $field -Context "$SourceLabel measurement_posture") -Context "$SourceLabel measurement_posture.$field"
        if (-not $value) {
            throw "$SourceLabel measurement_posture.$field must be true."
        }
    }
    foreach ($field in @("r13_closed", "r14_or_successor_opened")) {
        $value = Assert-BooleanValue -Value (Get-RequiredProperty -Object $posture -Name $field -Context "$SourceLabel measurement_posture") -Context "$SourceLabel measurement_posture.$field"
        if ($value) {
            throw "$SourceLabel measurement_posture.$field must be false for R13-015."
        }
    }

    $formula = Assert-ObjectValue -Value $Scorecard.scoring_formula -Context "$SourceLabel scoring_formula"
    $formulaWeights = Assert-ObjectValue -Value (Get-RequiredProperty -Object $formula -Name "sub_score_weights" -Context "$SourceLabel scoring_formula") -Context "$SourceLabel scoring_formula.sub_score_weights"
    $formulaWeightTotal = 0
    foreach ($subScoreName in $script:R13VisionControlSubScoreWeights.Keys) {
        $weight = Assert-NumberValue -Value (Get-RequiredProperty -Object $formulaWeights -Name $subScoreName -Context "$SourceLabel scoring_formula.sub_score_weights") -Context "$SourceLabel scoring_formula.$subScoreName weight"
        $expectedWeight = [double]$script:R13VisionControlSubScoreWeights[$subScoreName]
        Assert-RoundedNumber -Actual $weight -Expected $expectedWeight -Context "$SourceLabel scoring_formula.$subScoreName weight"
        $formulaWeightTotal += $weight
    }
    Assert-RoundedNumber -Actual $formulaWeightTotal -Expected 100 -Context "$SourceLabel scoring_formula sub_score_weights total"

    $evidenceRefs = Assert-ObjectArray -Value $Scorecard.evidence_refs -Context "$SourceLabel evidence_refs"
    $evidenceById = @{}
    foreach ($evidence in $evidenceRefs) {
        foreach ($field in @("ref_id", "ref", "evidence_kind", "authority_kind", "scope")) {
            Get-RequiredProperty -Object $evidence -Name $field -Context "$SourceLabel evidence_ref" | Out-Null
        }
        $refId = Assert-NonEmptyString -Value $evidence.ref_id -Context "$SourceLabel evidence_refs.ref_id"
        if ($evidenceById.ContainsKey($refId)) {
            throw "$SourceLabel evidence_refs contains duplicate ref_id '$refId'."
        }
        $ref = Assert-NonEmptyString -Value $evidence.ref -Context "$SourceLabel evidence_refs.$refId.ref"
        Assert-ExistingRepoRef -Ref $ref -Context "$SourceLabel evidence_refs.$refId"
        Assert-NonEmptyString -Value $evidence.evidence_kind -Context "$SourceLabel evidence_refs.$refId.evidence_kind" | Out-Null
        Assert-NonEmptyString -Value $evidence.authority_kind -Context "$SourceLabel evidence_refs.$refId.authority_kind" | Out-Null
        Assert-NonEmptyString -Value $evidence.scope -Context "$SourceLabel evidence_refs.$refId.scope" | Out-Null
        $evidenceById[$refId] = $evidence
    }

    $items = Assert-ObjectArray -Value $Scorecard.items -Context "$SourceLabel items"
    if ($items.Count -ne $script:R13VisionControlItems.Count) {
        throw "$SourceLabel items must contain $($script:R13VisionControlItems.Count) vision items."
    }

    $seenItems = @{}
    $segmentItemScores = @{}
    foreach ($segmentName in $script:R13VisionControlSegmentWeights.Keys) {
        $segmentItemScores[$segmentName] = New-Object System.Collections.Generic.List[object]
    }

    foreach ($item in $items) {
        foreach ($field in @(
                "item_id",
                "segment",
                "vision_category",
                "r6_score",
                "r7_score",
                "r8_score",
                "r9_score",
                "r10_score",
                "r11_score",
                "r12_score",
                "sub_scores",
                "penalties",
                "raw_score",
                "penalty_total",
                "r13_score",
                "uplift_from_r12",
                "evidence_ref_ids",
                "scoring_basis",
                "rejected_claims",
                "non_claims"
            )) {
            Get-RequiredProperty -Object $item -Name $field -Context "$SourceLabel item" | Out-Null
        }

        $itemId = Assert-NonEmptyString -Value $item.item_id -Context "$SourceLabel item.item_id"
        if (-not $script:R13VisionControlItemById.ContainsKey($itemId)) {
            throw "$SourceLabel item '$itemId' is not an allowed Vision Control item."
        }
        if ($seenItems.ContainsKey($itemId)) {
            throw "$SourceLabel item '$itemId' is duplicated."
        }
        $seenItems[$itemId] = $true
        $expectedItem = $script:R13VisionControlItemById[$itemId]

        if ($item.segment -ne $expectedItem.segment) {
            throw "$SourceLabel item '$itemId' segment must be '$($expectedItem.segment)'."
        }
        if ($item.vision_category -ne $expectedItem.vision_category) {
            throw "$SourceLabel item '$itemId' vision_category must be '$($expectedItem.vision_category)'."
        }

        foreach ($history in @(
                @{ Field = "r6_score"; Expected = $expectedItem.r6 },
                @{ Field = "r7_score"; Expected = $expectedItem.r7 },
                @{ Field = "r8_score"; Expected = $expectedItem.r8 },
                @{ Field = "r9_score"; Expected = $expectedItem.r9 },
                @{ Field = "r10_score"; Expected = $expectedItem.r10 },
                @{ Field = "r11_score"; Expected = $expectedItem.r11 },
                @{ Field = "r12_score"; Expected = $expectedItem.r12 }
            )) {
            $score = Assert-NumberValue -Value $item.($history.Field) -Context "$SourceLabel $itemId $($history.Field)"
            Assert-RoundedNumber -Actual $score -Expected ([double]$history.Expected) -Context "$SourceLabel $itemId $($history.Field)"
        }

        $itemRefIds = Assert-StringArray -Value $item.evidence_ref_ids -Context "$SourceLabel $itemId evidence_ref_ids"
        Assert-RefIdsResolve -RefIds $itemRefIds -EvidenceById $evidenceById -Context "$SourceLabel $itemId"
        Assert-NonEmptyString -Value $item.scoring_basis -Context "$SourceLabel $itemId scoring_basis" | Out-Null
        Assert-StringArray -Value $item.rejected_claims -Context "$SourceLabel $itemId rejected_claims" | Out-Null
        Assert-StringArray -Value $item.non_claims -Context "$SourceLabel $itemId non_claims" | Out-Null

        $subScores = Assert-ObjectValue -Value $item.sub_scores -Context "$SourceLabel $itemId sub_scores"
        $rawScore = 0.0
        foreach ($subScoreName in $script:R13VisionControlSubScoreWeights.Keys) {
            $subScore = Assert-NumberValue -Value (Get-RequiredProperty -Object $subScores -Name $subScoreName -Context "$SourceLabel $itemId sub_scores") -Context "$SourceLabel $itemId $subScoreName"
            $rawScore += $subScore * ([double]$script:R13VisionControlSubScoreWeights[$subScoreName] / 100.0)
        }
        $rawScore = Round-Score -Value $rawScore

        $penalties = Assert-ObjectArray -Value $item.penalties -Context "$SourceLabel $itemId penalties" -AllowEmpty
        $penaltyTotal = 0.0
        foreach ($penalty in $penalties) {
            foreach ($field in @("penalty_id", "value", "reason", "evidence_ref_ids")) {
                Get-RequiredProperty -Object $penalty -Name $field -Context "$SourceLabel $itemId penalty" | Out-Null
            }
            $penaltyId = Assert-NonEmptyString -Value $penalty.penalty_id -Context "$SourceLabel $itemId penalty.penalty_id"
            if (-not $script:R13VisionControlPenaltyValues.ContainsKey($penaltyId)) {
                throw "$SourceLabel $itemId penalty '$penaltyId' is not allowed."
            }
            $penaltyValue = Assert-NumberValue -Value $penalty.value -Context "$SourceLabel $itemId $penaltyId value" -Minimum -100 -Maximum 0
            $expectedPenaltyValue = [double]$script:R13VisionControlPenaltyValues[$penaltyId]
            Assert-RoundedNumber -Actual $penaltyValue -Expected $expectedPenaltyValue -Context "$SourceLabel $itemId $penaltyId penalty value"
            Assert-NonEmptyString -Value $penalty.reason -Context "$SourceLabel $itemId $penaltyId reason" | Out-Null
            $penaltyRefIds = Assert-StringArray -Value $penalty.evidence_ref_ids -Context "$SourceLabel $itemId $penaltyId evidence_ref_ids"
            Assert-RefIdsResolve -RefIds $penaltyRefIds -EvidenceById $evidenceById -Context "$SourceLabel $itemId $penaltyId"
            $penaltyTotal += $penaltyValue
        }
        $penaltyTotal = Round-Score -Value $penaltyTotal
        $calculatedR13 = Round-Score -Value ([math]::Min(100.0, [math]::Max(0.0, $rawScore + $penaltyTotal)))

        $providedRaw = Assert-NumberValue -Value $item.raw_score -Context "$SourceLabel $itemId raw_score"
        $providedPenaltyTotal = Assert-NumberValue -Value $item.penalty_total -Context "$SourceLabel $itemId penalty_total" -Minimum -100 -Maximum 100
        $providedR13 = Assert-NumberValue -Value $item.r13_score -Context "$SourceLabel $itemId r13_score"
        $providedUplift = Assert-NumberValue -Value $item.uplift_from_r12 -Context "$SourceLabel $itemId uplift_from_r12" -Minimum -100 -Maximum 100
        Assert-RoundedNumber -Actual $providedRaw -Expected $rawScore -Context "$SourceLabel $itemId raw_score"
        Assert-RoundedNumber -Actual $providedPenaltyTotal -Expected $penaltyTotal -Context "$SourceLabel $itemId penalty_total"
        Assert-RoundedNumber -Actual $providedR13 -Expected $calculatedR13 -Context "$SourceLabel $itemId r13_score"

        $expectedUplift = Round-Score -Value ($calculatedR13 - [double]$expectedItem.r12)
        Assert-RoundedNumber -Actual $providedUplift -Expected $expectedUplift -Context "$SourceLabel $itemId uplift_from_r12"
        if ($expectedUplift -gt 0 -and -not (Test-HasAcceptedUpliftEvidence -RefIds $itemRefIds -EvidenceById $evidenceById)) {
            throw "$SourceLabel $itemId uplift must include at least one committed implemented, machine, or external evidence ref."
        }

        $segmentItemScores[$expectedItem.segment].Add([pscustomobject]@{
                R12 = [double]$expectedItem.r12
                R13 = $calculatedR13
            }) | Out-Null
    }

    foreach ($requiredItem in $script:R13VisionControlItems) {
        if (-not $seenItems.ContainsKey($requiredItem.item_id)) {
            throw "$SourceLabel is missing required Vision Control item '$($requiredItem.item_id)'."
        }
    }

    $segmentKpis = Assert-ObjectArray -Value $Scorecard.segment_kpis -Context "$SourceLabel segment_kpis"
    $seenSegments = @{}
    $computedR12RecalculatedAggregate = 0.0
    $computedR13Aggregate = 0.0
    foreach ($segmentKpi in $segmentKpis) {
        foreach ($field in @("segment", "weight", "item_count", "r12_reported_average", "r12_recomputed_average", "r13_average", "uplift_from_recomputed_r12")) {
            Get-RequiredProperty -Object $segmentKpi -Name $field -Context "$SourceLabel segment_kpi" | Out-Null
        }
        $segmentName = Assert-NonEmptyString -Value $segmentKpi.segment -Context "$SourceLabel segment_kpi.segment"
        if (-not $script:R13VisionControlSegmentWeights.Contains($segmentName)) {
            throw "$SourceLabel segment '$segmentName' is not allowed."
        }
        if ($seenSegments.ContainsKey($segmentName)) {
            throw "$SourceLabel segment '$segmentName' is duplicated."
        }
        $seenSegments[$segmentName] = $true

        $expectedWeight = [double]$script:R13VisionControlSegmentWeights[$segmentName]
        $providedWeight = Assert-NumberValue -Value $segmentKpi.weight -Context "$SourceLabel $segmentName segment weight"
        Assert-RoundedNumber -Actual $providedWeight -Expected $expectedWeight -Context "$SourceLabel $segmentName segment weight"

        $segmentScores = @($segmentItemScores[$segmentName].ToArray())
        $expectedCount = $segmentScores.Count
        $providedCount = Assert-NumberValue -Value $segmentKpi.item_count -Context "$SourceLabel $segmentName item_count"
        Assert-RoundedNumber -Actual $providedCount -Expected ([double]$expectedCount) -Context "$SourceLabel $segmentName item_count"

        $reportedAverage = Assert-NumberValue -Value $segmentKpi.r12_reported_average -Context "$SourceLabel $segmentName r12_reported_average"
        Assert-RoundedNumber -Actual $reportedAverage -Expected ([double]$script:R12ReportedSegmentAverages[$segmentName]) -Context "$SourceLabel $segmentName r12_reported_average"

        $r12RecomputedAverage = Round-Score -Value (($segmentScores | ForEach-Object { $_.R12 } | Measure-Object -Average).Average)
        $r13Average = Round-Score -Value (($segmentScores | ForEach-Object { $_.R13 } | Measure-Object -Average).Average)
        $uplift = Round-Score -Value ($r13Average - $r12RecomputedAverage)

        $providedR12Recomputed = Assert-NumberValue -Value $segmentKpi.r12_recomputed_average -Context "$SourceLabel $segmentName r12_recomputed_average"
        $providedR13Average = Assert-NumberValue -Value $segmentKpi.r13_average -Context "$SourceLabel $segmentName r13_average"
        $providedSegmentUplift = Assert-NumberValue -Value $segmentKpi.uplift_from_recomputed_r12 -Context "$SourceLabel $segmentName uplift_from_recomputed_r12" -Minimum -100 -Maximum 100
        Assert-RoundedNumber -Actual $providedR12Recomputed -Expected $r12RecomputedAverage -Context "$SourceLabel $segmentName r12_recomputed_average"
        Assert-RoundedNumber -Actual $providedR13Average -Expected $r13Average -Context "$SourceLabel $segmentName r13_average"
        Assert-RoundedNumber -Actual $providedSegmentUplift -Expected $uplift -Context "$SourceLabel $segmentName uplift_from_recomputed_r12"

        $computedR12RecalculatedAggregate += $r12RecomputedAverage * ($expectedWeight / 100.0)
        $computedR13Aggregate += $r13Average * ($expectedWeight / 100.0)
    }

    foreach ($segmentName in $script:R13VisionControlSegmentWeights.Keys) {
        if (-not $seenSegments.ContainsKey($segmentName)) {
            throw "$SourceLabel is missing segment KPI '$segmentName'."
        }
    }

    $computedR12RecalculatedAggregate = Round-Score -Value $computedR12RecalculatedAggregate
    $computedR13Aggregate = Round-Score -Value $computedR13Aggregate
    $computedUpliftFromReported = Round-Score -Value ($computedR13Aggregate - $script:R12ReportedWeightedAggregate)
    $computedUpliftFromRecomputed = Round-Score -Value ($computedR13Aggregate - $computedR12RecalculatedAggregate)

    $aggregate = Assert-ObjectValue -Value $Scorecard.weighted_aggregate -Context "$SourceLabel weighted_aggregate"
    foreach ($field in @("r12_reported_weighted_aggregate", "r12_recomputed_weighted_aggregate", "r13_weighted_aggregate", "uplift_from_reported_r12", "uplift_from_recomputed_r12", "ten_to_fifteen_percent_progress_claimed", "calculation_basis")) {
        Get-RequiredProperty -Object $aggregate -Name $field -Context "$SourceLabel weighted_aggregate" | Out-Null
    }
    Assert-RoundedNumber -Actual (Assert-NumberValue -Value $aggregate.r12_reported_weighted_aggregate -Context "$SourceLabel r12_reported_weighted_aggregate") -Expected $script:R12ReportedWeightedAggregate -Context "$SourceLabel r12_reported_weighted_aggregate"
    Assert-RoundedNumber -Actual (Assert-NumberValue -Value $aggregate.r12_recomputed_weighted_aggregate -Context "$SourceLabel r12_recomputed_weighted_aggregate") -Expected $computedR12RecalculatedAggregate -Context "$SourceLabel r12_recomputed_weighted_aggregate"
    Assert-RoundedNumber -Actual (Assert-NumberValue -Value $aggregate.r13_weighted_aggregate -Context "$SourceLabel r13_weighted_aggregate") -Expected $computedR13Aggregate -Context "$SourceLabel r13_weighted_aggregate"
    Assert-RoundedNumber -Actual (Assert-NumberValue -Value $aggregate.uplift_from_reported_r12 -Context "$SourceLabel uplift_from_reported_r12" -Minimum -100 -Maximum 100) -Expected $computedUpliftFromReported -Context "$SourceLabel uplift_from_reported_r12"
    Assert-RoundedNumber -Actual (Assert-NumberValue -Value $aggregate.uplift_from_recomputed_r12 -Context "$SourceLabel uplift_from_recomputed_r12" -Minimum -100 -Maximum 100) -Expected $computedUpliftFromRecomputed -Context "$SourceLabel uplift_from_recomputed_r12"
    $tenToFifteenClaimed = Assert-BooleanValue -Value $aggregate.ten_to_fifteen_percent_progress_claimed -Context "$SourceLabel ten_to_fifteen_percent_progress_claimed"
    if ($tenToFifteenClaimed -and ($computedUpliftFromReported -lt 10 -or $computedUpliftFromReported -gt 15 -or $computedUpliftFromRecomputed -lt 10 -or $computedUpliftFromRecomputed -gt 15)) {
        throw "$SourceLabel cannot claim 10 to 15 percent progress unless both reported-baseline and recomputed-baseline uplift are within that range."
    }
    Assert-NonEmptyString -Value $aggregate.calculation_basis -Context "$SourceLabel weighted_aggregate.calculation_basis" | Out-Null

    $gates = Assert-ObjectArray -Value $Scorecard.gate_assessment -Context "$SourceLabel gate_assessment"
    foreach ($gate in $gates) {
        foreach ($field in @("gate_id", "status", "evidence_ref_ids", "non_claims")) {
            Get-RequiredProperty -Object $gate -Name $field -Context "$SourceLabel gate_assessment item" | Out-Null
        }
        Assert-NonEmptyString -Value $gate.gate_id -Context "$SourceLabel gate_id" | Out-Null
        $gateStatus = Assert-NonEmptyString -Value $gate.status -Context "$SourceLabel gate status"
        if (@("bounded_delivered", "partial", "not_delivered") -notcontains $gateStatus) {
            throw "$SourceLabel gate status must be bounded_delivered, partial, or not_delivered."
        }
        $gateRefIds = Assert-StringArray -Value $gate.evidence_ref_ids -Context "$SourceLabel gate evidence_ref_ids" -AllowEmpty
        if ($gateStatus -ne "not_delivered" -and $gateRefIds.Count -eq 0) {
            throw "$SourceLabel gate '$($gate.gate_id)' has status '$gateStatus' without evidence_ref_ids."
        }
        Assert-RefIdsResolve -RefIds $gateRefIds -EvidenceById $evidenceById -Context "$SourceLabel gate '$($gate.gate_id)'"
        Assert-StringArray -Value $gate.non_claims -Context "$SourceLabel gate '$($gate.gate_id)' non_claims" | Out-Null
    }

    $topLevelNonClaims = Assert-StringArray -Value $Scorecard.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $topLevelNonClaims -Context $SourceLabel

    return [pscustomobject]@{
        ArtifactType = $Scorecard.artifact_type
        ItemCount = $items.Count
        SegmentCount = $segmentKpis.Count
        EvidenceRefCount = $evidenceRefs.Count
        R12ReportedAggregate = $script:R12ReportedWeightedAggregate
        R12RecomputedAggregate = $computedR12RecalculatedAggregate
        R13Aggregate = $computedR13Aggregate
        UpliftFromReportedR12 = $computedUpliftFromReported
        UpliftFromRecomputedR12 = $computedUpliftFromRecomputed
        TenToFifteenPercentProgressClaimed = $tenToFifteenClaimed
        R13Closed = [bool]$posture.r13_closed
        R14OrSuccessorOpened = [bool]$posture.r14_or_successor_opened
    }
}

function Test-R13VisionControlScorecardContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScorecardPath
    )

    $scorecard = Get-JsonDocument -Path $ScorecardPath -Label "R13 vision control scorecard"
    return Test-R13VisionControlScorecardObject -Scorecard $scorecard -SourceLabel $ScorecardPath
}

Export-ModuleMember -Function Get-R13VisionControlContract, Test-R13VisionControlScorecardObject, Test-R13VisionControlScorecardContract
