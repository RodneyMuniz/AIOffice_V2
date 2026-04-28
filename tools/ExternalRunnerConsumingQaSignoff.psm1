Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force
$externalRunnerModule = Import-Module (Join-Path $PSScriptRoot "ExternalRunnerArtifactIdentity.psm1") -Force -PassThru
$externalProofBundleModule = Import-Module (Join-Path $PSScriptRoot "ExternalProofArtifactBundle.psm1") -Force -PassThru
$script:TestExternalRunnerCloseoutIdentityContract = $externalRunnerModule.ExportedCommands["Test-ExternalRunnerCloseoutIdentityContract"]
$script:TestExternalProofArtifactBundleContract = $externalProofBundleModule.ExportedCommands["Test-ExternalProofArtifactBundleContract"]

function Get-RepositoryRoot {
    return $repoRoot
}

function Get-ModuleRepositoryRootPath {
    return (Resolve-Path -LiteralPath (Get-RepositoryRoot)).Path
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

function Resolve-PathValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [string]$AnchorPath = (Get-ModuleRepositoryRootPath)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    $resolvedAnchorPath = if (Test-Path -LiteralPath $AnchorPath) {
        (Resolve-Path -LiteralPath $AnchorPath).Path
    }
    else {
        [System.IO.Path]::GetFullPath($AnchorPath)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $resolvedAnchorPath $PathValue))
}

function Resolve-ExistingPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [string]$AnchorPath = (Get-ModuleRepositoryRootPath)
    )

    $resolvedPath = Resolve-PathValue -PathValue $PathValue -AnchorPath $AnchorPath
    if (-not (Test-Path -LiteralPath $resolvedPath)) {
        throw "$Label '$PathValue' does not exist."
    }

    return (Resolve-Path -LiteralPath $resolvedPath).Path
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

    $property = $Object.PSObject.Properties[$Name]
    $PSCmdlet.WriteObject($property.Value, $false)
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

function Assert-MatchesPattern {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Pattern,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -notmatch $Pattern) {
        throw "$Context does not match required pattern '$Pattern'."
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

function Get-ExternalRunnerConsumingQaContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "isolated_qa", "external_runner_consuming_qa_signoff.contract.json")) -Label "External-runner-consuming QA signoff contract"
}

function Get-IsolatedQaFoundationContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "isolated_qa", "foundation.contract.json")) -Label "Isolated QA foundation contract"
}

function Assert-RequiredReference {
    param(
        [AllowNull()]
        $Reference,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $referenceValue = Assert-NonEmptyString -Value $Reference -Context $Label
    Resolve-ExistingPath -PathValue $referenceValue -Label $Label -AnchorPath (Get-ModuleRepositoryRootPath) | Out-Null
    return $referenceValue
}

function Assert-RequiredNonClaims {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$NonClaims,
        [Parameter(Mandatory = $true)]
        [string[]]$RequiredNonClaims,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($requiredNonClaim in $RequiredNonClaims) {
        if ($NonClaims -notcontains $requiredNonClaim) {
            throw "$Context non_claims must include '$requiredNonClaim'."
        }
    }
}

function Assert-NoForbiddenQaClaimText {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Values,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($value in $Values) {
        if ([string]::IsNullOrWhiteSpace($value)) {
            continue
        }

        $hasNegation = $value -match '(?i)\b(no|not|without|must not|does not|cannot|insufficient)\b'

        if ($value -match '(?i)\b(final[- ]head clean replay|R10 closeout|broad CI|product coverage|production-grade CI|UI|control-room|control room|Standard runtime|multi-repo|swarms?|fleet execution|broad autonomous|unattended automatic resume|solved Codex context compaction|context compaction solved|hours-long unattended|destructive rollback|general Codex reliability)\b.{0,120}\b(claim|claimed|proves|proof|exists|available|complete|supported|solved|accepted)\b' -and -not $hasNegation) {
            throw "$Context must not claim final-head replay, R10 closeout, broad CI/product coverage, UI, Standard runtime, multi-repo, swarms, broad autonomy, unattended resume, solved compaction, hours-long execution, destructive rollback, or general Codex reliability."
        }
    }
}

function Assert-ReferenceIsPresent {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Reference,
        [Parameter(Mandatory = $true)]
        [object[]]$SourceArtifacts,
        [Parameter(Mandatory = $true)]
        [string[]]$AllowedKinds,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $matches = @($SourceArtifacts | Where-Object { $_.artifact_ref -eq $Reference })
    if ($matches.Count -eq 0) {
        throw "$Context must be represented in source_artifacts."
    }

    $kindMatches = @($matches | Where-Object { $AllowedKinds -contains $_.artifact_kind })
    if ($kindMatches.Count -eq 0) {
        throw "$Context source_artifacts entry must use artifact_kind '$($AllowedKinds -join "' or '")'."
    }
}

function Assert-NotR9LimitationInput {
    param(
        [Parameter(Mandatory = $true)]
        $Document,
        [Parameter(Mandatory = $true)]
        [string]$Reference,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $artifactType = if (Test-HasProperty -Object $Document -Name "artifact_type") { [string]$Document.artifact_type } else { "" }
    $artifactId = if (Test-HasProperty -Object $Document -Name "artifact_id") { [string]$Document.artifact_id } else { "" }
    $status = if (Test-HasProperty -Object $Document -Name "status") { [string]$Document.status } else { "" }
    $text = @($Reference, $artifactType, $artifactId, $status) -join " "

    if ($text -match '(?i)(R9-004|external_runner_limitation|limitation)' -or $status -eq "unavailable") {
        throw "$Context must not use R9-004 limitation evidence as QA proof."
    }
}

function Assert-NotFailedRunEvidence {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RunId,
        [Parameter(Mandatory = $true)]
        [object[]]$FailedRunIds,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($FailedRunIds -contains $RunId) {
        throw "$Context must not use failed run evidence from '$RunId' as QA proof."
    }
}

function Assert-NotExecutorOnlyQaAuthority {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProducedBy,
        [Parameter(Mandatory = $true)]
        [string]$AuthorityRole,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($AuthorityRole -eq "consumed_external_runner_evidence" -and $ProducedBy -match '(?i)\b(executor|local[-_ ]?runner|local[-_ ]?qa|codex[-_ ]?executor)\b') {
        throw "$Context executor-only evidence must not be presented as QA authority."
    }
}

function Assert-SourceArtifactIsNotForbiddenEvidence {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArtifactRef,
        [Parameter(Mandatory = $true)]
        [string]$ResolvedArtifactRef,
        [Parameter(Mandatory = $true)]
        [string]$ArtifactKind,
        [Parameter(Mandatory = $true)]
        [object[]]$FailedRunIds,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($ArtifactRef -match '(?i)(R9-004|external_runner_limitation|external-runner limitation|limitation\.valid\.json)') {
        throw "$Context must not use R9-004 limitation evidence as QA proof."
    }

    foreach ($failedRunId in $FailedRunIds) {
        if ($ArtifactRef -match [regex]::Escape([string]$failedRunId)) {
            throw "$Context must not use failed run evidence from '$failedRunId' as QA proof."
        }
    }

    if ($ArtifactKind -ne "external_runner_identity" -and $ArtifactKind -ne "external_proof_bundle") {
        return
    }

    $artifactDocument = Get-JsonDocument -Path $ResolvedArtifactRef -Label "$Context source_artifacts item.artifact_ref"
    Assert-NotR9LimitationInput -Document $artifactDocument -Reference $ArtifactRef -Context $Context

    $runId = if (Test-HasProperty -Object $artifactDocument -Name "run_id") { [string]$artifactDocument.run_id } else { "" }
    if (-not [string]::IsNullOrWhiteSpace($runId)) {
        Assert-NotFailedRunEvidence -RunId $runId -FailedRunIds $FailedRunIds -Context $Context
    }

    if ($ArtifactKind -eq "external_runner_identity") {
        $conclusion = if (Test-HasProperty -Object $artifactDocument -Name "conclusion") { [string]$artifactDocument.conclusion } else { "" }
        if (-not [string]::IsNullOrWhiteSpace($conclusion) -and $conclusion -ne "success") {
            throw "$Context must not use failed run evidence from '$runId' as QA proof."
        }
    }

    if ($ArtifactKind -eq "external_proof_bundle") {
        $aggregateVerdict = if (Test-HasProperty -Object $artifactDocument -Name "aggregate_verdict") { [string]$artifactDocument.aggregate_verdict } else { "" }
        if (-not [string]::IsNullOrWhiteSpace($aggregateVerdict) -and $aggregateVerdict -ne "passed") {
            throw "$Context must not use failed run evidence from '$runId' as QA proof."
        }
    }
}

function Test-ExternalRunnerConsumingQaSignoffObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $QaSignoffPacket,
        [string]$SourceLabel = "External-runner-consuming QA signoff"
    )

    $foundation = Get-IsolatedQaFoundationContract
    $contract = Get-ExternalRunnerConsumingQaContract

    Assert-RequiredObjectFields -Object $QaSignoffPacket -FieldNames $contract.required_fields -Context $SourceLabel

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaSignoffPacket -Name "contract_version" -Context $SourceLabel) -Context "$SourceLabel contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "$SourceLabel contract_version must be '$($foundation.contract_version)'."
    }

    $packetType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaSignoffPacket -Name "packet_type" -Context $SourceLabel) -Context "$SourceLabel packet_type"
    if ($packetType -ne $contract.packet_type) {
        throw "$SourceLabel packet_type must be '$($contract.packet_type)'."
    }

    $packetId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaSignoffPacket -Name "packet_id" -Context $SourceLabel) -Context "$SourceLabel packet_id"
    Assert-MatchesPattern -Value $packetId -Pattern $foundation.identifier_pattern -Context "$SourceLabel packet_id"

    $repository = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaSignoffPacket -Name "repository" -Context $SourceLabel) -Context "$SourceLabel repository"
    if ($repository -ne $foundation.repository_name) {
        throw "$SourceLabel repository must be '$($foundation.repository_name)'."
    }

    $branch = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaSignoffPacket -Name "branch" -Context $SourceLabel) -Context "$SourceLabel branch"
    if ($branch -ne $contract.required_branch) {
        throw "$SourceLabel branch must be '$($contract.required_branch)'."
    }

    $sourceMilestone = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaSignoffPacket -Name "source_milestone" -Context $SourceLabel) -Context "$SourceLabel source_milestone"
    if ($sourceMilestone -ne $contract.required_source_milestone) {
        throw "$SourceLabel source_milestone must be '$($contract.required_source_milestone)'."
    }

    $sourceTask = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaSignoffPacket -Name "source_task" -Context $SourceLabel) -Context "$SourceLabel source_task"
    if ($sourceTask -ne $contract.required_source_task) {
        throw "$SourceLabel source_task must be '$($contract.required_source_task)'."
    }

    $qaRoleIdentity = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaSignoffPacket -Name "qa_role_identity" -Context $SourceLabel) -Context "$SourceLabel qa_role_identity"
    $qaRunnerKind = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaSignoffPacket -Name "qa_runner_kind" -Context $SourceLabel) -Context "$SourceLabel qa_runner_kind"
    Assert-AllowedValue -Value $qaRunnerKind -AllowedValues $contract.allowed_qa_runner_kinds -Context "$SourceLabel qa_runner_kind"

    $qaAuthorityType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaSignoffPacket -Name "qa_authority_type" -Context $SourceLabel) -Context "$SourceLabel qa_authority_type"
    if ($qaAuthorityType -match $contract.forbidden_self_certification_pattern) {
        throw "$SourceLabel qa_authority_type must not imply executor self-certification."
    }

    Assert-AllowedValue -Value $qaAuthorityType -AllowedValues $contract.allowed_qa_authority_types -Context "$SourceLabel qa_authority_type"

    $externalRunnerIdentityRef = Assert-RequiredReference -Reference (Get-RequiredProperty -Object $QaSignoffPacket -Name "external_runner_identity_ref" -Context $SourceLabel) -Label "$SourceLabel external_runner_identity_ref"
    $externalProofBundleRef = Assert-RequiredReference -Reference (Get-RequiredProperty -Object $QaSignoffPacket -Name "external_proof_bundle_ref" -Context $SourceLabel) -Label "$SourceLabel external_proof_bundle_ref"
    $artifactRetrievalRef = Assert-RequiredReference -Reference (Get-RequiredProperty -Object $QaSignoffPacket -Name "artifact_retrieval_ref" -Context $SourceLabel) -Label "$SourceLabel artifact_retrieval_ref"
    $finalRemoteHeadSupportRef = Assert-RequiredReference -Reference (Get-RequiredProperty -Object $QaSignoffPacket -Name "final_remote_head_support_ref" -Context $SourceLabel) -Label "$SourceLabel final_remote_head_support_ref"

    $identityDocument = Get-JsonDocument -Path $externalRunnerIdentityRef -Label "$SourceLabel external_runner_identity_ref"
    Assert-NotR9LimitationInput -Document $identityDocument -Reference $externalRunnerIdentityRef -Context $SourceLabel
    $identityRunId = if (Test-HasProperty -Object $identityDocument -Name "run_id") { [string]$identityDocument.run_id } else { "" }
    Assert-NotFailedRunEvidence -RunId $identityRunId -FailedRunIds $contract.failed_or_limitation_run_ids -Context $SourceLabel

    $identityValidation = & $script:TestExternalRunnerCloseoutIdentityContract -PacketPath $externalRunnerIdentityRef
    if ($identityValidation.RunId -ne $contract.required_external_run_id) {
        throw "$SourceLabel external_runner_identity_ref must reference run '$($contract.required_external_run_id)'."
    }

    if ($identityValidation.Status -ne "completed" -or $identityValidation.Conclusion -ne "success" -or -not $identityValidation.IsSuccessfulProofIdentity) {
        throw "$SourceLabel external runner identity must be completed with conclusion 'success'."
    }

    $bundleDocument = Get-JsonDocument -Path $externalProofBundleRef -Label "$SourceLabel external_proof_bundle_ref"
    $bundleRunId = if (Test-HasProperty -Object $bundleDocument -Name "run_id") { [string]$bundleDocument.run_id } else { "" }
    Assert-NotFailedRunEvidence -RunId $bundleRunId -FailedRunIds $contract.failed_or_limitation_run_ids -Context $SourceLabel

    $bundleValidation = & $script:TestExternalProofArtifactBundleContract -BundlePath $externalProofBundleRef
    if ($bundleValidation.AggregateVerdict -ne "passed" -or -not $bundleValidation.IsPassingBundleShape) {
        throw "$SourceLabel external proof bundle aggregate verdict must be 'passed'."
    }

    if (-not $bundleValidation.HeadMatch) {
        throw "$SourceLabel external proof bundle head_match must be true."
    }

    if ($bundleValidation.RunId -ne $identityValidation.RunId) {
        throw "$SourceLabel external proof bundle run ID must match identity packet run ID."
    }

    if ($bundleValidation.Branch -ne $identityValidation.Branch -or $bundleValidation.Branch -ne $contract.required_branch) {
        throw "$SourceLabel external proof bundle branch must match the R10 release branch and identity packet."
    }

    if ($bundleValidation.ArtifactName -ne $identityValidation.ArtifactName) {
        throw "$SourceLabel external proof bundle artifact name must match identity packet artifact name."
    }

    $retrievalText = Get-Content -LiteralPath $artifactRetrievalRef -Raw
    if ($retrievalText -notmatch [regex]::Escape($identityValidation.ArtifactName) -or $retrievalText -notmatch [regex]::Escape($identityValidation.RunUrl)) {
        throw "$SourceLabel artifact retrieval ref must identify the successful run URL and artifact name."
    }

    $sourceArtifacts = Assert-ObjectArray -Value (Get-RequiredProperty -Object $QaSignoffPacket -Name "source_artifacts" -Context $SourceLabel) -Context "$SourceLabel source_artifacts"
    foreach ($sourceArtifact in $sourceArtifacts) {
        Assert-RequiredObjectFields -Object $sourceArtifact -FieldNames $contract.source_artifact_required_fields -Context "$SourceLabel source_artifacts item"

        $artifactRef = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $sourceArtifact -Name "artifact_ref" -Context "$SourceLabel source_artifacts item") -Context "$SourceLabel source_artifacts item.artifact_ref"
        $resolvedArtifactRef = Resolve-ExistingPath -PathValue $artifactRef -Label "$SourceLabel source_artifacts item.artifact_ref" -AnchorPath (Get-ModuleRepositoryRootPath)

        $artifactKind = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $sourceArtifact -Name "artifact_kind" -Context "$SourceLabel source_artifacts item") -Context "$SourceLabel source_artifacts item.artifact_kind"
        if ($contract.forbidden_source_artifact_kinds -contains $artifactKind) {
            if ($artifactKind -eq "local_qa_evidence") {
                throw "$SourceLabel local-only QA evidence must not be presented as R10 closeout QA."
            }

            if ($artifactKind -eq "executor_evidence") {
                throw "$SourceLabel executor-only evidence must not be presented as QA authority."
            }

            throw "$SourceLabel source_artifacts must not include forbidden artifact_kind '$artifactKind'."
        }

        Assert-AllowedValue -Value $artifactKind -AllowedValues $contract.allowed_source_artifact_kinds -Context "$SourceLabel source_artifacts item.artifact_kind"

        $authorityRole = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $sourceArtifact -Name "authority_role" -Context "$SourceLabel source_artifacts item") -Context "$SourceLabel source_artifacts item.authority_role"
        Assert-AllowedValue -Value $authorityRole -AllowedValues $contract.allowed_artifact_authority_roles -Context "$SourceLabel source_artifacts item.authority_role"

        $producedBy = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $sourceArtifact -Name "produced_by" -Context "$SourceLabel source_artifacts item") -Context "$SourceLabel source_artifacts item.produced_by"
        Assert-NotExecutorOnlyQaAuthority -ProducedBy $producedBy -AuthorityRole $authorityRole -Context $SourceLabel
        Assert-SourceArtifactIsNotForbiddenEvidence -ArtifactRef $artifactRef -ResolvedArtifactRef $resolvedArtifactRef -ArtifactKind $artifactKind -FailedRunIds $contract.failed_or_limitation_run_ids -Context $SourceLabel
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $sourceArtifact -Name "notes" -Context "$SourceLabel source_artifacts item") -Context "$SourceLabel source_artifacts item.notes" | Out-Null
    }

    Assert-ReferenceIsPresent -Reference $externalRunnerIdentityRef -SourceArtifacts $sourceArtifacts -AllowedKinds @("external_runner_identity") -Context "$SourceLabel external_runner_identity_ref" | Out-Null
    Assert-ReferenceIsPresent -Reference $externalProofBundleRef -SourceArtifacts $sourceArtifacts -AllowedKinds @("external_proof_bundle") -Context "$SourceLabel external_proof_bundle_ref" | Out-Null
    Assert-ReferenceIsPresent -Reference $artifactRetrievalRef -SourceArtifacts $sourceArtifacts -AllowedKinds @("artifact_retrieval_instruction") -Context "$SourceLabel artifact_retrieval_ref" | Out-Null
    Assert-ReferenceIsPresent -Reference $finalRemoteHeadSupportRef -SourceArtifacts $sourceArtifacts -AllowedKinds @("final_remote_head_support_ref") -Context "$SourceLabel final_remote_head_support_ref" | Out-Null

    $verdict = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaSignoffPacket -Name "verdict" -Context $SourceLabel) -Context "$SourceLabel verdict"
    Assert-AllowedValue -Value $verdict -AllowedValues $contract.allowed_verdicts -Context "$SourceLabel verdict"

    $refusalReasons = Assert-StringArray -Value (Get-RequiredProperty -Object $QaSignoffPacket -Name "refusal_reasons" -Context $SourceLabel) -Context "$SourceLabel refusal_reasons" -AllowEmpty
    if ($verdict -eq "passed" -and $refusalReasons.Count -ne 0) {
        throw "$SourceLabel refusal_reasons must be empty when verdict is 'passed'."
    }

    if ($verdict -ne "passed" -and $refusalReasons.Count -eq 0) {
        throw "$SourceLabel refusal_reasons must not be empty when verdict is '$verdict'."
    }

    if ($verdict -eq "passed" -and -not $identityValidation.IsSuccessfulProofIdentity) {
        throw "$SourceLabel verdict 'passed' requires successful external runner identity evidence."
    }

    if ($verdict -eq "passed" -and -not $bundleValidation.IsPassingBundleShape) {
        throw "$SourceLabel verdict 'passed' requires a passing external proof bundle."
    }

    $independenceBoundary = Get-RequiredProperty -Object $QaSignoffPacket -Name "independence_boundary" -Context $SourceLabel
    Assert-RequiredObjectFields -Object $independenceBoundary -FieldNames $contract.independence_boundary_required_fields -Context "$SourceLabel independence_boundary"

    $boundaryType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $independenceBoundary -Name "boundary_type" -Context "$SourceLabel independence_boundary") -Context "$SourceLabel independence_boundary.boundary_type"
    Assert-AllowedValue -Value $boundaryType -AllowedValues $contract.allowed_independence_boundary_types -Context "$SourceLabel independence_boundary.boundary_type"

    $executorIdentity = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $independenceBoundary -Name "executor_identity" -Context "$SourceLabel independence_boundary") -Context "$SourceLabel independence_boundary.executor_identity"
    $qaIdentity = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $independenceBoundary -Name "qa_identity" -Context "$SourceLabel independence_boundary") -Context "$SourceLabel independence_boundary.qa_identity"
    if ($qaIdentity -ne $qaRoleIdentity) {
        throw "$SourceLabel independence_boundary.qa_identity must match qa_role_identity."
    }

    if ($executorIdentity -eq $qaIdentity) {
        throw "$SourceLabel independence_boundary must not say the same executor produced and approved the signoff."
    }

    $executorArtifactsRole = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $independenceBoundary -Name "executor_artifacts_role" -Context "$SourceLabel independence_boundary") -Context "$SourceLabel independence_boundary.executor_artifacts_role"
    if ($executorArtifactsRole -ne $contract.required_executor_artifacts_role) {
        throw "$SourceLabel independence_boundary must preserve executor artifacts as source evidence only."
    }

    $statement = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $independenceBoundary -Name "statement" -Context "$SourceLabel independence_boundary") -Context "$SourceLabel independence_boundary.statement"
    if ($statement -match '(?i)same executor.*(approved|signoff)|produced and approved') {
        throw "$SourceLabel independence_boundary must not say the same executor produced and approved the signoff."
    }

    $createdAtUtc = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaSignoffPacket -Name "created_at_utc" -Context $SourceLabel) -Context "$SourceLabel created_at_utc"
    Assert-MatchesPattern -Value $createdAtUtc -Pattern $foundation.timestamp_pattern -Context "$SourceLabel created_at_utc"

    $nonClaims = Assert-StringArray -Value (Get-RequiredProperty -Object $QaSignoffPacket -Name "non_claims" -Context $SourceLabel) -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -RequiredNonClaims $contract.required_non_claims -Context $SourceLabel

    $claimText = @(
        $packetId,
        $repository,
        $branch,
        $sourceMilestone,
        $sourceTask,
        $qaRoleIdentity,
        $qaRunnerKind,
        $qaAuthorityType,
        $externalRunnerIdentityRef,
        $externalProofBundleRef,
        $artifactRetrievalRef,
        $finalRemoteHeadSupportRef,
        $verdict,
        $statement
    )
    $claimText += $refusalReasons
    $claimText += $nonClaims
    foreach ($sourceArtifact in $sourceArtifacts) {
        $claimText += @($sourceArtifact.artifact_ref, $sourceArtifact.artifact_kind, $sourceArtifact.authority_role, $sourceArtifact.produced_by, $sourceArtifact.notes)
    }
    Assert-NoForbiddenQaClaimText -Values $claimText -Context $SourceLabel

    $result = [pscustomobject]@{
        PacketId = $packetId
        Repository = $repository
        Branch = $branch
        SourceTask = $sourceTask
        QaRoleIdentity = $qaRoleIdentity
        QaRunnerKind = $qaRunnerKind
        QaAuthorityType = $qaAuthorityType
        Verdict = $verdict
        ExternalRunId = $identityValidation.RunId
        ExternalRunUrl = $identityValidation.RunUrl
        ArtifactName = $identityValidation.ArtifactName
        BundleVerdict = $bundleValidation.AggregateVerdict
    }

    $PSCmdlet.WriteObject($result, $false)
}

function Test-ExternalRunnerConsumingQaSignoffContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PacketPath
    )

    $resolvedPacketPath = Resolve-ExistingPath -PathValue $PacketPath -Label "External-runner-consuming QA signoff"
    $qaSignoffPacket = Get-JsonDocument -Path $resolvedPacketPath -Label "External-runner-consuming QA signoff"
    $validation = Test-ExternalRunnerConsumingQaSignoffObject -QaSignoffPacket $qaSignoffPacket -SourceLabel "External-runner-consuming QA signoff"
    $PSCmdlet.WriteObject($validation, $false)
}

Export-ModuleMember -Function Test-ExternalRunnerConsumingQaSignoffContract, Test-ExternalRunnerConsumingQaSignoffObject
