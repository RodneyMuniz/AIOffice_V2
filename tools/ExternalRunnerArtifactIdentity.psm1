Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

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

function Assert-StringValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($null -eq $Value -or $Value -isnot [string]) {
        throw "$Context must be a string."
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

function Get-ExternalRunnerArtifactFoundationContract {
    $contract = Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "external_runner_artifact", "foundation.contract.json")) -Label "External runner artifact foundation contract"
    return $contract
}

function Get-ExternalRunnerArtifactIdentityContract {
    $contract = Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "external_runner_artifact", "external_runner_artifact_identity.contract.json")) -Label "External runner artifact identity contract"
    return $contract
}

function Get-ExternalRunnerCloseoutIdentityContract {
    $contract = Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "external_runner_artifact", "external_runner_closeout_identity.contract.json")) -Label "External runner closeout identity contract"
    return $contract
}

function Assert-OptionalReference {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Reference,
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [string]$AnchorPath
    )

    if (-not [string]::IsNullOrWhiteSpace($Reference)) {
        Resolve-ExistingPath -PathValue $Reference -Label $Label -AnchorPath $AnchorPath | Out-Null
    }
}

function Assert-RequiredReference {
    param(
        [AllowNull()]
        $Reference,
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [string]$AnchorPath
    )

    $referenceValue = Assert-NonEmptyString -Value $Reference -Context $Label
    Resolve-ExistingPath -PathValue $referenceValue -Label $Label -AnchorPath $AnchorPath | Out-Null
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

function Assert-NoForbiddenCloseoutClaimText {
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

        if ($value -match '(?i)(R9-004|external_runner_limitation|external-runner limitation).{0,120}(satisfies|proves|proof|closeout|external proof)') {
            throw "$Context must not claim that R9-004 limitation evidence satisfies R10 external proof."
        }

        if ($value -match '(?i)\b(unavailable|limitation|could not|cannot|no real)\b.{0,120}\b(proof|proves|satisfies|closeout|successful)\b' -and $value -notmatch '(?i)\b(no|not|without|insufficient|must not|does not)\b.{0,120}\b(proof|prove|satisfy|closeout|success)') {
            throw "$Context must not describe unavailable or limitation-only external-runner evidence as proof."
        }

        if ($value -match '(?i)\b(broad|production-grade|product(?:ion)?|product)\b.{0,80}\b(CI|coverage|product coverage)\b.{0,80}\b(claim|claimed|proves|proof|exists|available|complete)\b' -and $value -notmatch '(?i)\b(no|not|without|must not|does not)\b') {
            throw "$Context must not claim broad CI/product coverage."
        }
    }
}

function Assert-ConcreteCloseoutRunIdentity {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$RunId,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$RunUrl,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$ArtifactName,
        [Parameter(Mandatory = $true)]
        [string]$RetrievalInstruction,
        [Parameter(Mandatory = $true)]
        [string]$RunnerKind,
        [Parameter(Mandatory = $true)]
        [string]$GithubActionsRunUrlPattern,
        [Parameter(Mandatory = $true)]
        [string]$SyntheticRunIdPattern,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-NonEmptyString -Value $RunId -Context "$Context run_id" | Out-Null
    if ($RunId -match $SyntheticRunIdPattern) {
        throw "$Context run_id must not be synthetic, dummy, test, or placeholder."
    }

    Assert-NonEmptyString -Value $RunUrl -Context "$Context run_url" | Out-Null
    Assert-NonEmptyString -Value $ArtifactName -Context "$Context artifact_name" | Out-Null
    Assert-NonEmptyString -Value $RetrievalInstruction -Context "$Context artifact_url_or_retrieval_instruction" | Out-Null

    if ($RetrievalInstruction -match '(?i)^(n/a|none|unavailable|limitation)$') {
        throw "$Context artifact_url_or_retrieval_instruction must be actionable."
    }

    if ($RunnerKind -eq "github_actions") {
        Assert-MatchesPattern -Value $RunUrl -Pattern $GithubActionsRunUrlPattern -Context "$Context run_url"
    }
    elseif ($RunUrl -notmatch '^https?://') {
        throw "$Context run_url must be a concrete external runner URL."
    }
}

function Assert-ConcreteRunIdentity {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$RunId,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$RunUrl,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$ArtifactName,
        [Parameter(Mandatory = $true)]
        [string]$RetrievalInstruction,
        [Parameter(Mandatory = $true)]
        [string]$RunnerKind,
        [Parameter(Mandatory = $true)]
        [string]$GithubActionsRunUrlPattern,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-NonEmptyString -Value $RunId -Context "$Context run_id" | Out-Null
    Assert-NonEmptyString -Value $RunUrl -Context "$Context run_url" | Out-Null
    Assert-NonEmptyString -Value $ArtifactName -Context "$Context artifact_name" | Out-Null
    Assert-NonEmptyString -Value $RetrievalInstruction -Context "$Context artifact_url_or_retrieval_instruction" | Out-Null

    if ($RunnerKind -eq "github_actions") {
        Assert-MatchesPattern -Value $RunUrl -Pattern $GithubActionsRunUrlPattern -Context "$Context run_url"
    }
}

function Test-ExternalRunnerCloseoutIdentityObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $ArtifactIdentity,
        [string]$SourceLabel = "External runner closeout identity",
        [string]$AnchorPath = (Get-ModuleRepositoryRootPath)
    )

    $foundation = Get-ExternalRunnerArtifactFoundationContract
    $contract = Get-ExternalRunnerCloseoutIdentityContract

    Assert-RequiredObjectFields -Object $ArtifactIdentity -FieldNames $contract.required_fields -Context $SourceLabel

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "contract_version" -Context $SourceLabel) -Context "$SourceLabel contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "$SourceLabel contract_version must be '$($foundation.contract_version)'."
    }

    $artifactType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "artifact_type" -Context $SourceLabel) -Context "$SourceLabel artifact_type"
    if ($artifactType -ne $contract.artifact_type) {
        throw "$SourceLabel artifact_type must be '$($contract.artifact_type)'."
    }

    $artifactId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "artifact_id" -Context $SourceLabel) -Context "$SourceLabel artifact_id"
    Assert-MatchesPattern -Value $artifactId -Pattern $foundation.identifier_pattern -Context "$SourceLabel artifact_id"

    $repository = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "repository" -Context $SourceLabel) -Context "$SourceLabel repository"
    Assert-MatchesPattern -Value $repository -Pattern $foundation.repository_name_pattern -Context "$SourceLabel repository"
    if ($repository -ne $foundation.repository_name) {
        throw "$SourceLabel repository must be '$($foundation.repository_name)'."
    }

    $branch = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "branch" -Context $SourceLabel) -Context "$SourceLabel branch"
    if ($branch -ne $contract.required_branch) {
        throw "$SourceLabel branch must be '$($contract.required_branch)'."
    }

    $headSha = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "head_sha" -Context $SourceLabel) -Context "$SourceLabel head_sha"
    $treeSha = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "tree_sha" -Context $SourceLabel) -Context "$SourceLabel tree_sha"
    Assert-MatchesPattern -Value $headSha -Pattern $foundation.git_object_pattern -Context "$SourceLabel head_sha"
    Assert-MatchesPattern -Value $treeSha -Pattern $foundation.git_object_pattern -Context "$SourceLabel tree_sha"

    $runnerKind = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "runner_kind" -Context $SourceLabel) -Context "$SourceLabel runner_kind"
    Assert-AllowedValue -Value $runnerKind -AllowedValues $foundation.allowed_runner_kinds -Context "$SourceLabel runner_kind"

    $runnerIdentity = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "runner_identity" -Context $SourceLabel) -Context "$SourceLabel runner_identity"
    $workflowName = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "workflow_name" -Context $SourceLabel) -Context "$SourceLabel workflow_name"
    $workflowRef = Assert-RequiredReference -Reference (Get-RequiredProperty -Object $ArtifactIdentity -Name "workflow_ref" -Context $SourceLabel) -Label "$SourceLabel workflow_ref" -AnchorPath (Get-ModuleRepositoryRootPath)

    $runId = Assert-StringValue -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "run_id" -Context $SourceLabel) -Context "$SourceLabel run_id"
    $runUrl = Assert-StringValue -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "run_url" -Context $SourceLabel) -Context "$SourceLabel run_url"
    $artifactName = Assert-StringValue -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "artifact_name" -Context $SourceLabel) -Context "$SourceLabel artifact_name"
    $retrievalInstruction = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "artifact_url_or_retrieval_instruction" -Context $SourceLabel) -Context "$SourceLabel artifact_url_or_retrieval_instruction"

    Assert-ConcreteCloseoutRunIdentity -RunId $runId -RunUrl $runUrl -ArtifactName $artifactName -RetrievalInstruction $retrievalInstruction -RunnerKind $runnerKind -GithubActionsRunUrlPattern $foundation.github_actions_run_url_pattern -SyntheticRunIdPattern $contract.synthetic_run_id_pattern -Context $SourceLabel

    $triggeredAtUtc = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "triggered_at_utc" -Context $SourceLabel) -Context "$SourceLabel triggered_at_utc"
    $completedAtUtc = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "completed_at_utc" -Context $SourceLabel) -Context "$SourceLabel completed_at_utc"
    Assert-MatchesPattern -Value $triggeredAtUtc -Pattern $foundation.timestamp_pattern -Context "$SourceLabel triggered_at_utc"
    Assert-MatchesPattern -Value $completedAtUtc -Pattern $foundation.timestamp_pattern -Context "$SourceLabel completed_at_utc"

    $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "status" -Context $SourceLabel) -Context "$SourceLabel status"
    Assert-AllowedValue -Value $status -AllowedValues $contract.allowed_statuses -Context "$SourceLabel status"
    if ($status -eq "unavailable") {
        throw "$SourceLabel status must not be 'unavailable' for R10 closeout-use identity."
    }

    $conclusion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "conclusion" -Context $SourceLabel) -Context "$SourceLabel conclusion"
    Assert-AllowedValue -Value $conclusion -AllowedValues $contract.allowed_conclusions -Context "$SourceLabel conclusion"
    if ($conclusion -eq "unavailable") {
        throw "$SourceLabel conclusion must not be 'unavailable' for R10 closeout-use identity."
    }

    $commandManifestRef = Assert-RequiredReference -Reference (Get-RequiredProperty -Object $ArtifactIdentity -Name "command_manifest_ref" -Context $SourceLabel) -Label "$SourceLabel command_manifest_ref" -AnchorPath $AnchorPath
    $stdoutLogRefs = Assert-StringArray -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "stdout_log_refs" -Context $SourceLabel) -Context "$SourceLabel stdout_log_refs"
    $stderrLogRefs = Assert-StringArray -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "stderr_log_refs" -Context $SourceLabel) -Context "$SourceLabel stderr_log_refs"
    $exitCodeRefs = Assert-StringArray -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "exit_code_refs" -Context $SourceLabel) -Context "$SourceLabel exit_code_refs"

    foreach ($stdoutLogRef in $stdoutLogRefs) {
        Assert-RequiredReference -Reference $stdoutLogRef -Label "$SourceLabel stdout_log_refs item" -AnchorPath $AnchorPath | Out-Null
    }

    foreach ($stderrLogRef in $stderrLogRefs) {
        Assert-RequiredReference -Reference $stderrLogRef -Label "$SourceLabel stderr_log_refs item" -AnchorPath $AnchorPath | Out-Null
    }

    foreach ($exitCodeRef in $exitCodeRefs) {
        Assert-RequiredReference -Reference $exitCodeRef -Label "$SourceLabel exit_code_refs item" -AnchorPath $AnchorPath | Out-Null
    }

    $qaPacketRef = Assert-RequiredReference -Reference (Get-RequiredProperty -Object $ArtifactIdentity -Name "qa_packet_ref" -Context $SourceLabel) -Label "$SourceLabel qa_packet_ref" -AnchorPath $AnchorPath
    $remoteHeadEvidenceRef = Assert-RequiredReference -Reference (Get-RequiredProperty -Object $ArtifactIdentity -Name "remote_head_evidence_ref" -Context $SourceLabel) -Label "$SourceLabel remote_head_evidence_ref" -AnchorPath $AnchorPath
    $finalRemoteHeadSupportRef = Assert-RequiredReference -Reference (Get-RequiredProperty -Object $ArtifactIdentity -Name "final_remote_head_support_ref" -Context $SourceLabel) -Label "$SourceLabel final_remote_head_support_ref" -AnchorPath $AnchorPath

    $nonClaims = Assert-StringArray -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "non_claims" -Context $SourceLabel) -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -RequiredNonClaims $contract.required_non_claims -Context $SourceLabel

    $claimText = @(
        $artifactId,
        $branch,
        $runnerKind,
        $runnerIdentity,
        $workflowName,
        $workflowRef,
        $runId,
        $runUrl,
        $artifactName,
        $retrievalInstruction,
        $commandManifestRef,
        $qaPacketRef,
        $remoteHeadEvidenceRef,
        $finalRemoteHeadSupportRef
    )
    $claimText += $stdoutLogRefs
    $claimText += $stderrLogRefs
    $claimText += $exitCodeRefs
    $claimText += $nonClaims
    Assert-NoForbiddenCloseoutClaimText -Values $claimText -Context $SourceLabel

    $result = [pscustomobject]@{
        ArtifactId = $artifactId
        Repository = $repository
        Branch = $branch
        HeadSha = $headSha
        TreeSha = $treeSha
        RunnerKind = $runnerKind
        Status = $status
        Conclusion = $conclusion
        RunId = $runId
        RunUrl = $runUrl
        ArtifactName = $artifactName
        IsSuccessfulProofIdentity = ($status -eq "completed" -and $conclusion -eq "success")
    }

    Write-Output -NoEnumerate $result
}

function Test-ExternalRunnerCloseoutIdentityContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PacketPath
    )

    $resolvedPacketPath = Resolve-ExistingPath -PathValue $PacketPath -Label "External runner closeout identity"
    $artifactIdentity = Get-JsonDocument -Path $resolvedPacketPath -Label "External runner closeout identity"
    $validation = Test-ExternalRunnerCloseoutIdentityObject -ArtifactIdentity $artifactIdentity -SourceLabel "External runner closeout identity" -AnchorPath (Split-Path -Parent $resolvedPacketPath)
    Write-Output -NoEnumerate $validation
}

function Test-ExternalRunnerArtifactIdentityObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $ArtifactIdentity,
        [string]$SourceLabel = "External runner artifact identity",
        [string]$AnchorPath = (Get-ModuleRepositoryRootPath)
    )

    $foundation = Get-ExternalRunnerArtifactFoundationContract
    $contract = Get-ExternalRunnerArtifactIdentityContract

    Assert-RequiredObjectFields -Object $ArtifactIdentity -FieldNames $contract.required_fields -Context $SourceLabel

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "contract_version" -Context $SourceLabel) -Context "$SourceLabel contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "$SourceLabel contract_version must be '$($foundation.contract_version)'."
    }

    $artifactType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "artifact_type" -Context $SourceLabel) -Context "$SourceLabel artifact_type"
    if ($artifactType -ne $contract.artifact_type -or $artifactType -ne $foundation.artifact_identity_type) {
        throw "$SourceLabel artifact_type must be '$($contract.artifact_type)'."
    }

    $artifactId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "artifact_id" -Context $SourceLabel) -Context "$SourceLabel artifact_id"
    Assert-MatchesPattern -Value $artifactId -Pattern $foundation.identifier_pattern -Context "$SourceLabel artifact_id"

    $repository = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "repository" -Context $SourceLabel) -Context "$SourceLabel repository"
    Assert-MatchesPattern -Value $repository -Pattern $foundation.repository_name_pattern -Context "$SourceLabel repository"
    if ($repository -ne $foundation.repository_name) {
        throw "$SourceLabel repository must be '$($foundation.repository_name)'."
    }

    $branch = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "branch" -Context $SourceLabel) -Context "$SourceLabel branch"
    Assert-MatchesPattern -Value $branch -Pattern $foundation.branch_pattern -Context "$SourceLabel branch"

    $headSha = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "head_sha" -Context $SourceLabel) -Context "$SourceLabel head_sha"
    $treeSha = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "tree_sha" -Context $SourceLabel) -Context "$SourceLabel tree_sha"
    Assert-MatchesPattern -Value $headSha -Pattern $foundation.git_object_pattern -Context "$SourceLabel head_sha"
    Assert-MatchesPattern -Value $treeSha -Pattern $foundation.git_object_pattern -Context "$SourceLabel tree_sha"

    $runnerKind = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "runner_kind" -Context $SourceLabel) -Context "$SourceLabel runner_kind"
    Assert-AllowedValue -Value $runnerKind -AllowedValues $foundation.allowed_runner_kinds -Context "$SourceLabel runner_kind"

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "runner_identity" -Context $SourceLabel) -Context "$SourceLabel runner_identity" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "workflow_name" -Context $SourceLabel) -Context "$SourceLabel workflow_name" | Out-Null
    $workflowRef = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "workflow_ref" -Context $SourceLabel) -Context "$SourceLabel workflow_ref"
    Assert-OptionalReference -Reference $workflowRef -Label "$SourceLabel workflow_ref" -AnchorPath (Get-ModuleRepositoryRootPath)

    $runId = Assert-StringValue -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "run_id" -Context $SourceLabel) -Context "$SourceLabel run_id"
    $runUrl = Assert-StringValue -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "run_url" -Context $SourceLabel) -Context "$SourceLabel run_url"
    $artifactName = Assert-StringValue -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "artifact_name" -Context $SourceLabel) -Context "$SourceLabel artifact_name"
    $retrievalInstruction = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "artifact_url_or_retrieval_instruction" -Context $SourceLabel) -Context "$SourceLabel artifact_url_or_retrieval_instruction"

    if ($runnerKind -eq "github_actions" -and -not [string]::IsNullOrWhiteSpace($runUrl)) {
        Assert-MatchesPattern -Value $runUrl -Pattern $foundation.github_actions_run_url_pattern -Context "$SourceLabel run_url"
    }

    $triggeredAtUtc = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "triggered_at_utc" -Context $SourceLabel) -Context "$SourceLabel triggered_at_utc"
    $completedAtUtc = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "completed_at_utc" -Context $SourceLabel) -Context "$SourceLabel completed_at_utc"
    Assert-MatchesPattern -Value $triggeredAtUtc -Pattern $foundation.timestamp_pattern -Context "$SourceLabel triggered_at_utc"
    Assert-MatchesPattern -Value $completedAtUtc -Pattern $foundation.timestamp_pattern -Context "$SourceLabel completed_at_utc"

    $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "status" -Context $SourceLabel) -Context "$SourceLabel status"
    Assert-AllowedValue -Value $status -AllowedValues $foundation.allowed_statuses -Context "$SourceLabel status"

    $conclusion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "conclusion" -Context $SourceLabel) -Context "$SourceLabel conclusion"
    Assert-AllowedValue -Value $conclusion -AllowedValues $foundation.allowed_conclusions -Context "$SourceLabel conclusion"

    $qaPacketRef = Assert-StringValue -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "qa_packet_ref" -Context $SourceLabel) -Context "$SourceLabel qa_packet_ref"
    $remoteHeadEvidenceRef = Assert-StringValue -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "remote_head_evidence_ref" -Context $SourceLabel) -Context "$SourceLabel remote_head_evidence_ref"
    $finalRemoteHeadSupportRef = Assert-StringValue -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "final_remote_head_support_ref" -Context $SourceLabel) -Context "$SourceLabel final_remote_head_support_ref"

    $nonClaims = Assert-StringArray -Value (Get-RequiredProperty -Object $ArtifactIdentity -Name "non_claims" -Context $SourceLabel) -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -RequiredNonClaims $foundation.required_non_claims -Context $SourceLabel

    if ($status -eq "unavailable") {
        if ($conclusion -ne "unavailable") {
            throw "$SourceLabel conclusion must be 'unavailable' when status is 'unavailable'."
        }

        if (-not [string]::IsNullOrWhiteSpace($runId) -or -not [string]::IsNullOrWhiteSpace($runUrl) -or -not [string]::IsNullOrWhiteSpace($artifactName)) {
            throw "$SourceLabel unavailable limitation must not claim concrete run_id, run_url, or artifact_name."
        }

        if ($retrievalInstruction -notmatch '(?i)(limitation|unavailable|could not|cannot|no real)') {
            throw "$SourceLabel unavailable limitation must record a clear limitation or unavailable retrieval instruction."
        }

        if ($retrievalInstruction -match '(?i)(proof|identity|artifact).{0,40}(captured|claimed|exists|available)' -and $retrievalInstruction -notmatch '(?i)\b(no|not|without)\b.{0,80}(proof|identity|artifact|run)') {
            throw "$SourceLabel unavailable limitation must not be described as proof."
        }

        Assert-RequiredNonClaims -NonClaims $nonClaims -RequiredNonClaims $foundation.limitation_required_non_claims -Context $SourceLabel
    }
    else {
        if ($conclusion -eq "unavailable") {
            throw "$SourceLabel conclusion must not be 'unavailable' unless status is 'unavailable'."
        }
    }

    if ($status -eq "completed") {
        Assert-ConcreteRunIdentity -RunId $runId -RunUrl $runUrl -ArtifactName $artifactName -RetrievalInstruction $retrievalInstruction -RunnerKind $runnerKind -GithubActionsRunUrlPattern $foundation.github_actions_run_url_pattern -Context $SourceLabel
    }

    if ($conclusion -eq "success") {
        if ($status -ne "completed") {
            throw "$SourceLabel conclusion 'success' requires status 'completed'."
        }

        Assert-ConcreteRunIdentity -RunId $runId -RunUrl $runUrl -ArtifactName $artifactName -RetrievalInstruction $retrievalInstruction -RunnerKind $runnerKind -GithubActionsRunUrlPattern $foundation.github_actions_run_url_pattern -Context $SourceLabel

        Assert-NonEmptyString -Value $qaPacketRef -Context "$SourceLabel qa_packet_ref" | Out-Null
        Assert-NonEmptyString -Value $remoteHeadEvidenceRef -Context "$SourceLabel remote_head_evidence_ref" | Out-Null
        Assert-NonEmptyString -Value $finalRemoteHeadSupportRef -Context "$SourceLabel final_remote_head_support_ref" | Out-Null
    }

    Assert-OptionalReference -Reference $qaPacketRef -Label "$SourceLabel qa_packet_ref" -AnchorPath $AnchorPath
    Assert-OptionalReference -Reference $remoteHeadEvidenceRef -Label "$SourceLabel remote_head_evidence_ref" -AnchorPath $AnchorPath
    Assert-OptionalReference -Reference $finalRemoteHeadSupportRef -Label "$SourceLabel final_remote_head_support_ref" -AnchorPath $AnchorPath

    $result = [pscustomobject]@{
        ArtifactId = $artifactId
        Repository = $repository
        Branch = $branch
        HeadSha = $headSha
        TreeSha = $treeSha
        RunnerKind = $runnerKind
        Status = $status
        Conclusion = $conclusion
        RunId = $runId
        RunUrl = $runUrl
        ArtifactName = $artifactName
    }

    Write-Output -NoEnumerate $result
}

function Test-ExternalRunnerArtifactIdentityContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PacketPath
    )

    $resolvedPacketPath = Resolve-ExistingPath -PathValue $PacketPath -Label "External runner artifact identity"
    $artifactIdentity = Get-JsonDocument -Path $resolvedPacketPath -Label "External runner artifact identity"
    $validation = Test-ExternalRunnerArtifactIdentityObject -ArtifactIdentity $artifactIdentity -SourceLabel "External runner artifact identity" -AnchorPath (Split-Path -Parent $resolvedPacketPath)
    Write-Output -NoEnumerate $validation
}

Export-ModuleMember -Function Test-ExternalRunnerArtifactIdentityContract, Test-ExternalRunnerArtifactIdentityObject, Test-ExternalRunnerCloseoutIdentityContract, Test-ExternalRunnerCloseoutIdentityObject
