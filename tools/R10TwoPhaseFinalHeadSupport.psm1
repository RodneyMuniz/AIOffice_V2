Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force
$externalRunnerModule = Import-Module (Join-Path $PSScriptRoot "ExternalRunnerArtifactIdentity.psm1") -Force -PassThru
$externalProofBundleModule = Import-Module (Join-Path $PSScriptRoot "ExternalProofArtifactBundle.psm1") -Force -PassThru
$externalRunnerQaModule = Import-Module (Join-Path $PSScriptRoot "ExternalRunnerConsumingQaSignoff.psm1") -Force -PassThru
$script:TestExternalRunnerCloseoutIdentityContract = $externalRunnerModule.ExportedCommands["Test-ExternalRunnerCloseoutIdentityContract"]
$script:TestExternalProofArtifactBundleContract = $externalProofBundleModule.ExportedCommands["Test-ExternalProofArtifactBundleContract"]
$script:TestExternalRunnerConsumingQaSignoffContract = $externalRunnerQaModule.ExportedCommands["Test-ExternalRunnerConsumingQaSignoffContract"]

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

function Get-R10TwoPhaseFinalHeadCloseoutProcedureContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "post_push_support", "r10_two_phase_final_head_closeout_procedure.contract.json")) -Label "R10 two-phase final-head closeout procedure contract"
}

function Get-PostPushSupportFoundationContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "post_push_support", "foundation.contract.json")) -Label "Post-push support foundation contract"
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

function Assert-RequiredListItems {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$ActualItems,
        [Parameter(Mandatory = $true)]
        [string[]]$RequiredItems,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($requiredItem in $RequiredItems) {
        if ($ActualItems -notcontains $requiredItem) {
            throw "$Context must include '$requiredItem'."
        }
    }
}

function Get-ProcedureTextValues {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value
    )

    if ($null -eq $Value) {
        return
    }

    if ($Value -is [string]) {
        $PSCmdlet.WriteObject($Value, $false)
        return
    }

    if ($Value -is [System.Collections.IDictionary]) {
        foreach ($key in $Value.Keys) {
            Get-ProcedureTextValues -Value $Value[$key]
        }
        return
    }

    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
        foreach ($item in $Value) {
            Get-ProcedureTextValues -Value $item
        }
        return
    }

    if ($Value -is [System.ValueType]) {
        return
    }

    if (@($Value.PSObject.Properties).Count -gt 0) {
        foreach ($property in $Value.PSObject.Properties) {
            Get-ProcedureTextValues -Value $property.Value
        }
    }
}

function Assert-NoForbiddenCompletedClaimText {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Values,
        [Parameter(Mandatory = $true)]
        [string]$ForbiddenCompletedClaimPattern,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($value in $Values) {
        if ([string]::IsNullOrWhiteSpace($value)) {
            continue
        }

        $hasNegation = $value -match '(?i)\b(no|not|without|must not|does not|has not|will not|future|later|before)\b'
        if ($value -match $ForbiddenCompletedClaimPattern -and -not $hasNegation) {
            throw "$Context must not claim final-head clean replay is already complete or that R10 is already closed."
        }

        if ($value -match '(?i)\bR10\b.{0,40}\b(already\s+)?closed\b' -and -not $hasNegation) {
            throw "$Context must not claim final-head clean replay is already complete or that R10 is already closed."
        }
    }
}

function Assert-PostPushSupportPolicy {
    param(
        [Parameter(Mandatory = $true)]
        $Policy,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-RequiredObjectFields -Object $Policy -FieldNames $Contract.post_push_support_commit_policy_required_fields -Context $Context

    $candidateCloseoutCommitMustBePushedFirst = Assert-BooleanValue -Value (Get-RequiredProperty -Object $Policy -Name "candidate_closeout_commit_must_be_pushed_first" -Context $Context) -Context "$Context.candidate_closeout_commit_must_be_pushed_first"
    if (-not $candidateCloseoutCommitMustBePushedFirst) {
        throw "$Context must require the candidate closeout commit to be pushed before final-head support is created."
    }

    $supportMustBeAfterPush = Assert-BooleanValue -Value (Get-RequiredProperty -Object $Policy -Name "support_must_be_after_push" -Context $Context) -Context "$Context.support_must_be_after_push"
    if (-not $supportMustBeAfterPush) {
        throw "$Context must require post-push final-head support."
    }

    $sameCommitSelfReferentialProofAllowed = Assert-BooleanValue -Value (Get-RequiredProperty -Object $Policy -Name "same_commit_self_referential_proof_allowed" -Context $Context) -Context "$Context.same_commit_self_referential_proof_allowed"
    if ($sameCommitSelfReferentialProofAllowed) {
        throw "$Context must not allow same-commit self-referential final-head proof."
    }

    $closeoutWithoutSupportAllowed = Assert-BooleanValue -Value (Get-RequiredProperty -Object $Policy -Name "closeout_without_support_allowed" -Context $Context) -Context "$Context.closeout_without_support_allowed"
    if ($closeoutWithoutSupportAllowed) {
        throw "$Context must not allow closeout without a follow-up support commit or external artifact identity."
    }

    $allowedPublicationModes = Assert-StringArray -Value (Get-RequiredProperty -Object $Policy -Name "allowed_publication_modes" -Context $Context) -Context "$Context.allowed_publication_modes" -AllowEmpty
    foreach ($allowedPublicationMode in $allowedPublicationModes) {
        Assert-AllowedValue -Value $allowedPublicationMode -AllowedValues $Contract.allowed_publication_modes -Context "$Context.allowed_publication_modes item"
    }

    if ($allowedPublicationModes -notcontains "follow_up_support_commit" -and $allowedPublicationModes -notcontains "external_artifact_identity") {
        throw "$Context must allow a follow-up support commit or external artifact identity."
    }

    $statement = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Policy -Name "statement" -Context $Context) -Context "$Context.statement"
    if ($statement -notmatch '(?i)after .{0,40}push') {
        throw "$Context.statement must require final-head support after the candidate closeout push."
    }

    if ($statement -notmatch '(?i)(follow-up support commit|external artifact identity)') {
        throw "$Context.statement must allow a follow-up support commit or external artifact identity."
    }

    if ($statement -match '(?i)(same closeout commit|same commit)' -and $statement -notmatch '(?i)\b(not|never|without)\b.{0,80}(same closeout commit|same commit)') {
        throw "$Context must not allow same-commit self-referential final-head proof."
    }
}

function Test-R10TwoPhaseFinalHeadSupportObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Procedure,
        [string]$SourceLabel = "R10 two-phase final-head closeout procedure"
    )

    $foundation = Get-PostPushSupportFoundationContract
    $contract = Get-R10TwoPhaseFinalHeadCloseoutProcedureContract

    Assert-RequiredObjectFields -Object $Procedure -FieldNames $contract.required_fields -Context $SourceLabel

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Procedure -Name "contract_version" -Context $SourceLabel) -Context "$SourceLabel contract_version"
    if ($contractVersion -ne $foundation.contract_version -or $contractVersion -ne $contract.contract_version) {
        throw "$SourceLabel contract_version must be '$($contract.contract_version)'."
    }

    $procedureType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Procedure -Name "procedure_type" -Context $SourceLabel) -Context "$SourceLabel procedure_type"
    if ($procedureType -ne $contract.procedure_type) {
        throw "$SourceLabel procedure_type must be '$($contract.procedure_type)'."
    }

    $procedureId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Procedure -Name "procedure_id" -Context $SourceLabel) -Context "$SourceLabel procedure_id"
    Assert-MatchesPattern -Value $procedureId -Pattern $foundation.identifier_pattern -Context "$SourceLabel procedure_id"

    $repository = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Procedure -Name "repository" -Context $SourceLabel) -Context "$SourceLabel repository"
    if ($repository -ne $foundation.repository_name) {
        throw "$SourceLabel repository must be '$($foundation.repository_name)'."
    }

    $branch = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Procedure -Name "branch" -Context $SourceLabel) -Context "$SourceLabel branch"
    if ($branch -ne $contract.required_branch) {
        throw "$SourceLabel branch must be '$($contract.required_branch)'."
    }

    $sourceMilestone = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Procedure -Name "source_milestone" -Context $SourceLabel) -Context "$SourceLabel source_milestone"
    if ($sourceMilestone -ne $contract.required_source_milestone) {
        throw "$SourceLabel source_milestone must be '$($contract.required_source_milestone)'."
    }

    $sourceTask = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Procedure -Name "source_task" -Context $SourceLabel) -Context "$SourceLabel source_task"
    if ($sourceTask -ne $contract.required_source_task) {
        throw "$SourceLabel source_task must be '$($contract.required_source_task)'."
    }

    Assert-RequiredReference -Reference (Get-RequiredProperty -Object $Procedure -Name "candidate_closeout_commit_ref" -Context $SourceLabel) -Label "$SourceLabel candidate_closeout_commit_ref" | Out-Null
    Assert-RequiredReference -Reference (Get-RequiredProperty -Object $Procedure -Name "candidate_closeout_tree_ref" -Context $SourceLabel) -Label "$SourceLabel candidate_closeout_tree_ref" | Out-Null
    $externalRunnerIdentityRef = Assert-RequiredReference -Reference (Get-RequiredProperty -Object $Procedure -Name "external_runner_identity_ref" -Context $SourceLabel) -Label "$SourceLabel external_runner_identity_ref"
    $externalProofBundleRef = Assert-RequiredReference -Reference (Get-RequiredProperty -Object $Procedure -Name "external_proof_bundle_ref" -Context $SourceLabel) -Label "$SourceLabel external_proof_bundle_ref"
    $externalRunnerConsumingQaSignoffRef = Assert-RequiredReference -Reference (Get-RequiredProperty -Object $Procedure -Name "external_runner_consuming_qa_signoff_ref" -Context $SourceLabel) -Label "$SourceLabel external_runner_consuming_qa_signoff_ref"

    $identityValidation = & $script:TestExternalRunnerCloseoutIdentityContract -PacketPath $externalRunnerIdentityRef
    if ($identityValidation.RunId -ne $contract.required_external_run_id -or $identityValidation.Status -ne "completed" -or $identityValidation.Conclusion -ne "success" -or -not $identityValidation.IsSuccessfulProofIdentity) {
        throw "$SourceLabel external runner identity must reference successful run '$($contract.required_external_run_id)'."
    }

    $bundleValidation = & $script:TestExternalProofArtifactBundleContract -BundlePath $externalProofBundleRef
    if ($bundleValidation.AggregateVerdict -ne "passed" -or -not $bundleValidation.IsPassingBundleShape) {
        throw "$SourceLabel external proof bundle aggregate verdict must be 'passed'."
    }

    if (-not $bundleValidation.HeadMatch) {
        throw "$SourceLabel external proof bundle head_match must be true."
    }

    if ($bundleValidation.RunId -ne $identityValidation.RunId) {
        throw "$SourceLabel external proof bundle run ID must match the external runner identity run ID."
    }

    $qaValidation = & $script:TestExternalRunnerConsumingQaSignoffContract -PacketPath $externalRunnerConsumingQaSignoffRef
    if ($qaValidation.Verdict -ne "passed") {
        throw "$SourceLabel external-runner-consuming QA signoff verdict must be 'passed'."
    }

    if ($qaValidation.ExternalRunId -ne $identityValidation.RunId) {
        throw "$SourceLabel external-runner-consuming QA signoff run ID must match the external runner identity run ID."
    }

    $postPushFinalHeadSupportRequired = Assert-BooleanValue -Value (Get-RequiredProperty -Object $Procedure -Name "post_push_final_head_support_required" -Context $SourceLabel) -Context "$SourceLabel post_push_final_head_support_required"
    if (-not $postPushFinalHeadSupportRequired) {
        throw "$SourceLabel post-push final-head support is required."
    }

    $postPushSupportCommitPolicy = Get-RequiredProperty -Object $Procedure -Name "post_push_support_commit_policy" -Context $SourceLabel
    Assert-PostPushSupportPolicy -Policy $postPushSupportCommitPolicy -Contract $contract -Context "$SourceLabel post_push_support_commit_policy"

    $finalAcceptanceConditions = Assert-StringArray -Value (Get-RequiredProperty -Object $Procedure -Name "final_acceptance_conditions" -Context $SourceLabel) -Context "$SourceLabel final_acceptance_conditions"
    Assert-RequiredListItems -ActualItems $finalAcceptanceConditions -RequiredItems $contract.required_final_acceptance_conditions -Context "$SourceLabel final_acceptance_conditions"

    $refusalConditions = Assert-StringArray -Value (Get-RequiredProperty -Object $Procedure -Name "refusal_conditions" -Context $SourceLabel) -Context "$SourceLabel refusal_conditions"
    Assert-RequiredListItems -ActualItems $refusalConditions -RequiredItems $contract.required_refusal_conditions -Context "$SourceLabel refusal_conditions"

    $nonClaims = Assert-StringArray -Value (Get-RequiredProperty -Object $Procedure -Name "non_claims" -Context $SourceLabel) -Context "$SourceLabel non_claims"
    Assert-RequiredListItems -ActualItems $nonClaims -RequiredItems $contract.required_non_claims -Context "$SourceLabel non_claims"

    $createdAtUtc = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Procedure -Name "created_at_utc" -Context $SourceLabel) -Context "$SourceLabel created_at_utc"
    Assert-MatchesPattern -Value $createdAtUtc -Pattern $foundation.timestamp_pattern -Context "$SourceLabel created_at_utc"

    $claimText = @(Get-ProcedureTextValues -Value $Procedure)
    Assert-NoForbiddenCompletedClaimText -Values $claimText -ForbiddenCompletedClaimPattern $contract.forbidden_completed_claim_pattern -Context $SourceLabel

    return [pscustomobject]@{
        ProcedureId = $procedureId
        Repository = $repository
        Branch = $branch
        SourceTask = $sourceTask
        ExternalRunId = $identityValidation.RunId
        BundleVerdict = $bundleValidation.AggregateVerdict
        QaVerdict = $qaValidation.Verdict
        PostPushFinalHeadSupportRequired = $postPushFinalHeadSupportRequired
    }
}

function Test-R10TwoPhaseFinalHeadSupportContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProcedurePath
    )

    $resolvedProcedurePath = Resolve-ExistingPath -PathValue $ProcedurePath -Label "R10 two-phase final-head closeout procedure"
    $procedure = Get-JsonDocument -Path $resolvedProcedurePath -Label "R10 two-phase final-head closeout procedure"
    $validation = Test-R10TwoPhaseFinalHeadSupportObject -Procedure $procedure -SourceLabel "R10 two-phase final-head closeout procedure"
    $PSCmdlet.WriteObject($validation, $false)
}

Export-ModuleMember -Function Test-R10TwoPhaseFinalHeadSupportContract, Test-R10TwoPhaseFinalHeadSupportObject
