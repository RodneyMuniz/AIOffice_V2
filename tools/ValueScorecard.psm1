Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$script:R12ValueScorecardDimensions = @(
    "product_visible_surface",
    "operator_workflow_clarity",
    "external_api_execution_independence",
    "qa_lint_actionability",
    "repo_truth_architecture",
    "governance_proof_discipline"
)

$script:R12ValueScorecardBaselines = @{
    product_visible_surface = 8
    operator_workflow_clarity = 34
    external_api_execution_independence = 30
    qa_lint_actionability = 30
    repo_truth_architecture = 73
    governance_proof_discipline = 95
}

$script:R12ValueScorecardWeights = @{
    product_visible_surface = 25
    operator_workflow_clarity = 20
    external_api_execution_independence = 20
    qa_lint_actionability = 15
    repo_truth_architecture = 10
    governance_proof_discipline = 10
}

$script:R12ValueScorecardTargets = @{
    product_visible_surface = @(18, 20)
    operator_workflow_clarity = @(50, 50)
    external_api_execution_independence = @(50, 50)
    qa_lint_actionability = @(50, 55)
    repo_truth_architecture = @(78, 78)
    governance_proof_discipline = @(95, 95)
}

$script:R12ValueGateIds = @(
    "external_api_runner",
    "actionable_qa",
    "operator_control_room",
    "real_build_change"
)

$script:R12RequiredNonClaims = @(
    "targets are not proof",
    "no R12 value gates delivered during Phase A",
    "no 10 percent or larger corrected progress uplift during Phase A",
    "no production runtime",
    "no real production QA",
    "no productized control-room behavior",
    "no broad CI/product coverage",
    "no broad autonomous milestone execution",
    "no solved Codex reliability",
    "no R13 or successor opened"
)

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
        [string]$Context
    )

    if ($null -eq $Value -or $Value -is [string] -or -not ($Value -is [System.Collections.IEnumerable])) {
        throw "$Context must be an array."
    }

    $items = @($Value)
    if ($items.Count -eq 0) {
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

function Assert-RequiredNonClaims {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$NonClaims,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($requiredNonClaim in $script:R12RequiredNonClaims) {
        if ($NonClaims -notcontains $requiredNonClaim) {
            throw "$Context non_claims must include '$requiredNonClaim'."
        }
    }
}

function Get-R12ValueScorecardContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "value_scorecard", "r12_value_scorecard.contract.json")) -Label "R12 value scorecard contract"
}

function Test-ValueScorecardObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Scorecard,
        [string]$SourceLabel = "R12 value scorecard"
    )

    $contract = Get-R12ValueScorecardContract
    $contractWeights = Assert-ObjectValue -Value (Get-RequiredProperty -Object $contract -Name "dimension_weights" -Context "R12 value scorecard contract") -Context "R12 value scorecard contract dimension_weights"
    $weightTotal = 0
    foreach ($requiredDimension in $script:R12ValueScorecardDimensions) {
        $contractWeightValue = Get-RequiredProperty -Object $contractWeights -Name $requiredDimension -Context "R12 value scorecard contract dimension_weights"
        $contractWeight = Assert-NumberValue -Value $contractWeightValue -Context "R12 value scorecard contract $requiredDimension weight"
        $expectedWeight = [double]$script:R12ValueScorecardWeights[$requiredDimension]
        if ([math]::Abs($contractWeight - $expectedWeight) -gt 0.001) {
            throw "R12 value scorecard contract $requiredDimension weight must be $expectedWeight."
        }
        $weightTotal += $contractWeight
    }
    if ([math]::Abs($weightTotal - 100) -gt 0.001) {
        throw "R12 value scorecard contract dimension_weights must total 100."
    }

    foreach ($field in @(
            "contract_version",
            "artifact_type",
            "repository",
            "branch",
            "milestone",
            "source_task",
            "source_planning_artifact",
            "measurement_posture",
            "dimensions",
            "corrected_total",
            "value_gates",
            "non_claims"
        )) {
        Get-RequiredProperty -Object $Scorecard -Name $field -Context $SourceLabel | Out-Null
    }

    Assert-NonEmptyString -Value $Scorecard.contract_version -Context "$SourceLabel contract_version" | Out-Null
    if ($Scorecard.artifact_type -ne "r12_value_scorecard") {
        throw "$SourceLabel artifact_type must be 'r12_value_scorecard'."
    }
    if ($Scorecard.repository -ne "AIOffice_V2") {
        throw "$SourceLabel repository must be AIOffice_V2."
    }
    if ($Scorecard.branch -ne "release/r12-external-api-runner-actionable-qa-control-room-pilot") {
        throw "$SourceLabel branch must be release/r12-external-api-runner-actionable-qa-control-room-pilot."
    }
    if ($Scorecard.milestone -ne "R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot") {
        throw "$SourceLabel milestone must be the R12 milestone title."
    }
    if ($Scorecard.source_task -ne "R12-002") {
        throw "$SourceLabel source_task must be R12-002."
    }

    $planningArtifact = Assert-ObjectValue -Value $Scorecard.source_planning_artifact -Context "$SourceLabel source_planning_artifact"
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $planningArtifact -Name "path" -Context "$SourceLabel source_planning_artifact") -Context "$SourceLabel source_planning_artifact.path" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $planningArtifact -Name "commit" -Context "$SourceLabel source_planning_artifact") -Context "$SourceLabel source_planning_artifact.commit" | Out-Null
    $planningProofAuthority = Assert-BooleanValue -Value (Get-RequiredProperty -Object $planningArtifact -Name "proof_authority" -Context "$SourceLabel source_planning_artifact") -Context "$SourceLabel source_planning_artifact.proof_authority"
    if ($planningProofAuthority) {
        throw "$SourceLabel source_planning_artifact cannot be proof authority."
    }

    $posture = Assert-ObjectValue -Value $Scorecard.measurement_posture -Context "$SourceLabel measurement_posture"
    $targetsAreNotProof = Assert-BooleanValue -Value (Get-RequiredProperty -Object $posture -Name "targets_are_not_proof" -Context "$SourceLabel measurement_posture") -Context "$SourceLabel measurement_posture.targets_are_not_proof"
    if (-not $targetsAreNotProof) {
        throw "$SourceLabel target-as-proved posture is invalid because targets are not proof."
    }
    $phaseAOnly = Assert-BooleanValue -Value (Get-RequiredProperty -Object $posture -Name "phase_a_foundation_only" -Context "$SourceLabel measurement_posture") -Context "$SourceLabel measurement_posture.phase_a_foundation_only"
    if (-not $phaseAOnly) {
        throw "$SourceLabel must mark Phase A as foundation only."
    }

    $topLevelNonClaims = Assert-StringArray -Value $Scorecard.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $topLevelNonClaims -Context $SourceLabel

    $dimensions = Assert-ObjectArray -Value $Scorecard.dimensions -Context "$SourceLabel dimensions"
    $seenDimensions = @{}
    $changedDimensions = @()

    foreach ($dimension in $dimensions) {
        foreach ($field in @("dimension", "weight", "baseline_score", "target_score", "proved_score", "proof_refs", "value_gate_refs", "scoring_basis", "non_claims")) {
            Get-RequiredProperty -Object $dimension -Name $field -Context "$SourceLabel dimension" | Out-Null
        }

        $dimensionId = Assert-NonEmptyString -Value $dimension.dimension -Context "$SourceLabel dimension.dimension"
        if ($script:R12ValueScorecardDimensions -notcontains $dimensionId) {
            throw "$SourceLabel dimension '$dimensionId' is not allowed."
        }
        if ($seenDimensions.ContainsKey($dimensionId)) {
            throw "$SourceLabel dimension '$dimensionId' is duplicated."
        }
        $seenDimensions[$dimensionId] = $true

        $weight = Assert-NumberValue -Value $dimension.weight -Context "$SourceLabel $dimensionId weight"
        if ($weight -le 0) {
            throw "$SourceLabel $dimensionId weight must be greater than zero."
        }
        $expectedWeight = [double]$script:R12ValueScorecardWeights[$dimensionId]
        if ([math]::Abs($weight - $expectedWeight) -gt 0.001) {
            throw "$SourceLabel $dimensionId weight drift is rejected; expected $expectedWeight."
        }

        $baselineScore = Assert-NumberValue -Value $dimension.baseline_score -Context "$SourceLabel $dimensionId baseline_score"
        if ([math]::Abs($baselineScore - [double]$script:R12ValueScorecardBaselines[$dimensionId]) -gt 0.001) {
            throw "$SourceLabel $dimensionId baseline_score must be $($script:R12ValueScorecardBaselines[$dimensionId])."
        }

        $targetRange = $script:R12ValueScorecardTargets[$dimensionId]
        $targetScore = Assert-NumberValue -Value $dimension.target_score -Context "$SourceLabel $dimensionId target_score"
        if ($targetScore -lt [double]$targetRange[0] -or $targetScore -gt [double]$targetRange[1]) {
            throw "$SourceLabel $dimensionId target_score must be between $($targetRange[0]) and $($targetRange[1])."
        }

        $provedScore = Assert-NumberValue -Value $dimension.proved_score -Context "$SourceLabel $dimensionId proved_score"
        $proofRefs = Assert-StringArray -Value $dimension.proof_refs -Context "$SourceLabel $dimensionId proof_refs" -AllowEmpty
        $valueGateRefs = Assert-StringArray -Value $dimension.value_gate_refs -Context "$SourceLabel $dimensionId value_gate_refs"
        $dimensionNonClaims = Assert-StringArray -Value $dimension.non_claims -Context "$SourceLabel $dimensionId non_claims"
        Assert-NonEmptyString -Value $dimension.scoring_basis -Context "$SourceLabel $dimensionId scoring_basis" | Out-Null

        foreach ($gateRef in $valueGateRefs) {
            if ($script:R12ValueGateIds -notcontains $gateRef) {
                throw "$SourceLabel $dimensionId value_gate_refs includes unknown gate '$gateRef'."
            }
        }
        if ($dimensionNonClaims -notcontains "targets are not proof") {
            throw "$SourceLabel $dimensionId non_claims must state that targets are not proof."
        }
        if ($dimension.scoring_basis -match "(?i)target.*achieved|achieved.*target") {
            throw "$SourceLabel target-as-proved scoring_basis is invalid for $dimensionId."
        }

        if ($provedScore -gt $baselineScore) {
            $changedDimensions += $dimensionId
            if ($proofRefs.Count -eq 0) {
                throw "$SourceLabel $dimensionId proved_score increased without proof_refs."
            }
            $nonPlanningProofRefs = @($proofRefs | Where-Object { $_ -notmatch "governance/reports/AIOffice_V2_R11_Audit_and_R12_Planning_Report_v1\.md" })
            if ($nonPlanningProofRefs.Count -eq 0) {
                throw "$SourceLabel $dimensionId proved uplift cannot rely on the planning report as proof."
            }
        }

        if ($provedScore -gt $targetScore -and $proofRefs.Count -eq 0) {
            throw "$SourceLabel $dimensionId proved_score exceeds target without proof_refs."
        }
    }

    foreach ($requiredDimension in $script:R12ValueScorecardDimensions) {
        if (-not $seenDimensions.ContainsKey($requiredDimension)) {
            throw "$SourceLabel is missing required dimension '$requiredDimension'."
        }
    }

    $correctedTotal = Assert-ObjectValue -Value $Scorecard.corrected_total -Context "$SourceLabel corrected_total"
    foreach ($field in @("baseline_score", "target_score", "proved_score", "uplift_from_baseline", "major_uplift_claimed", "target_recorded_as_achieved", "calculation_basis")) {
        Get-RequiredProperty -Object $correctedTotal -Name $field -Context "$SourceLabel corrected_total" | Out-Null
    }
    $totalBaseline = Assert-NumberValue -Value $correctedTotal.baseline_score -Context "$SourceLabel corrected_total.baseline_score"
    if ([math]::Abs($totalBaseline - 39) -gt 1) {
        throw "$SourceLabel corrected_total baseline_score must be about 39."
    }
    $totalTarget = Assert-NumberValue -Value $correctedTotal.target_score -Context "$SourceLabel corrected_total.target_score"
    if ($totalTarget -lt 50 -or $totalTarget -gt 54) {
        throw "$SourceLabel corrected_total target_score must be between 50 and 54."
    }
    $totalProved = Assert-NumberValue -Value $correctedTotal.proved_score -Context "$SourceLabel corrected_total.proved_score"
    $totalUplift = Assert-NumberValue -Value $correctedTotal.uplift_from_baseline -Context "$SourceLabel corrected_total.uplift_from_baseline" -Minimum -100 -Maximum 100
    $majorUpliftClaimed = Assert-BooleanValue -Value $correctedTotal.major_uplift_claimed -Context "$SourceLabel corrected_total.major_uplift_claimed"
    $targetRecordedAsAchieved = Assert-BooleanValue -Value $correctedTotal.target_recorded_as_achieved -Context "$SourceLabel corrected_total.target_recorded_as_achieved"
    Assert-NonEmptyString -Value $correctedTotal.calculation_basis -Context "$SourceLabel corrected_total.calculation_basis" | Out-Null
    if ($targetRecordedAsAchieved) {
        throw "$SourceLabel target-as-proved corrected_total is invalid."
    }

    $valueGates = Assert-ObjectArray -Value $Scorecard.value_gates -Context "$SourceLabel value_gates"
    $seenGates = @{}
    $allGatesProved = $true
    foreach ($gate in $valueGates) {
        foreach ($field in @("gate_id", "status", "proof_refs")) {
            Get-RequiredProperty -Object $gate -Name $field -Context "$SourceLabel value_gate" | Out-Null
        }
        $gateId = Assert-NonEmptyString -Value $gate.gate_id -Context "$SourceLabel value_gate.gate_id"
        if ($script:R12ValueGateIds -notcontains $gateId) {
            throw "$SourceLabel value gate '$gateId' is not allowed."
        }
        if ($seenGates.ContainsKey($gateId)) {
            throw "$SourceLabel value gate '$gateId' is duplicated."
        }
        $seenGates[$gateId] = $true
        $status = Assert-NonEmptyString -Value $gate.status -Context "$SourceLabel $gateId status"
        if (@("not_proved", "proved") -notcontains $status) {
            throw "$SourceLabel $gateId status must be not_proved or proved."
        }
        $gateProofRefs = Assert-StringArray -Value $gate.proof_refs -Context "$SourceLabel $gateId proof_refs" -AllowEmpty
        if ($status -eq "proved" -and $gateProofRefs.Count -eq 0) {
            throw "$SourceLabel $gateId is marked proved without proof_refs."
        }
        if ($status -ne "proved") {
            $allGatesProved = $false
        }
    }
    foreach ($requiredGate in $script:R12ValueGateIds) {
        if (-not $seenGates.ContainsKey($requiredGate)) {
            throw "$SourceLabel is missing required value gate '$requiredGate'."
        }
    }

    $actualUplift = $totalProved - $totalBaseline
    if ([math]::Abs($totalUplift - $actualUplift) -gt 0.01) {
        throw "$SourceLabel corrected_total uplift_from_baseline must match proved_score minus baseline_score."
    }

    if ($majorUpliftClaimed -or $totalUplift -ge 10) {
        if (-not $allGatesProved) {
            throw "$SourceLabel corrected_total claims 10 percent or larger uplift without all four value gates proved."
        }
    }

    $onlyGovernanceOrRepoChanged = $changedDimensions.Count -gt 0 -and @($changedDimensions | Where-Object { $_ -notin @("repo_truth_architecture", "governance_proof_discipline") }).Count -eq 0
    if ($totalUplift -ge 10 -and $onlyGovernanceOrRepoChanged) {
        throw "$SourceLabel governance/proof increase alone cannot drive a major corrected total increase."
    }

    return [pscustomobject]@{
        ArtifactType = $Scorecard.artifact_type
        Milestone = $Scorecard.milestone
        DimensionCount = $dimensions.Count
        CorrectedBaseline = $totalBaseline
        CorrectedTarget = $totalTarget
        CorrectedProved = $totalProved
        CorrectedUplift = $totalUplift
        AllValueGatesProved = $allGatesProved
        PhaseAFoundationOnly = $phaseAOnly
    }
}

function Test-ValueScorecardContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScorecardPath
    )

    $scorecard = Get-JsonDocument -Path $ScorecardPath -Label "R12 value scorecard"
    return Test-ValueScorecardObject -Scorecard $scorecard -SourceLabel $ScorecardPath
}

Export-ModuleMember -Function Get-R12ValueScorecardContract, Test-ValueScorecardObject, Test-ValueScorecardContract
