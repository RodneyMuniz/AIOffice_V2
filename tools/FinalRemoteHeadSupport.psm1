Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot

function Get-RepositoryRoot {
    return $repoRoot
}

function Get-ModuleRepositoryRootPath {
    return (Resolve-Path -LiteralPath (Get-RepositoryRoot)).Path
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
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    try {
        return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    }
    catch {
        throw "$Label at '$Path' is not valid JSON. $($_.Exception.Message)"
    }
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

    Write-Output -NoEnumerate ($Object.$Name)
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

    Write-Output -NoEnumerate $items
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

function Get-PostPushSupportFoundationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\post_push_support\foundation.contract.json") -Label "Post-push support foundation contract"
}

function Get-FinalRemoteHeadSupportPacketContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\post_push_support\final_remote_head_support_packet.contract.json") -Label "Final remote-head support packet contract"
}

function Assert-SupportPacketPolicy {
    param(
        [Parameter(Mandatory = $true)]
        $Policy,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-RequiredObjectFields -Object $Policy -FieldNames $Contract.support_packet_commit_policy_required_fields -Context $Context

    $createdAfterCloseoutPush = Assert-BooleanValue -Value (Get-RequiredProperty -Object $Policy -Name "created_after_closeout_push" -Context $Context) -Context "$Context.created_after_closeout_push"
    if (-not $createdAfterCloseoutPush) {
        throw "$Context must explicitly state that the support packet is created after the closeout push."
    }

    $notInsideSameCloseoutCommit = Assert-BooleanValue -Value (Get-RequiredProperty -Object $Policy -Name "not_inside_same_closeout_commit" -Context $Context) -Context "$Context.not_inside_same_closeout_commit"
    if (-not $notInsideSameCloseoutCommit) {
        throw "$Context must explicitly state that the support packet is not inside the same closeout commit it verifies."
    }

    $allowedPublicationModes = Assert-StringArray -Value (Get-RequiredProperty -Object $Policy -Name "allowed_publication_modes" -Context $Context) -Context "$Context.allowed_publication_modes"
    foreach ($allowedPublicationMode in $allowedPublicationModes) {
        Assert-AllowedValue -Value $allowedPublicationMode -AllowedValues $Foundation.allowed_publication_modes -Context "$Context.allowed_publication_modes item"
    }

    if ($allowedPublicationModes -notcontains "follow_up_support_commit" -and $allowedPublicationModes -notcontains "external_artifact_identity") {
        throw "$Context must allow a follow-up support commit or an external artifact identity."
    }

    $statement = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Policy -Name "statement" -Context $Context) -Context "$Context.statement"
    if ($statement -notmatch '(?i)after (the )?closeout push') {
        throw "$Context.statement must explicitly state that the support packet is created after the closeout push."
    }

    if ($statement -notmatch '(?i)not .{0,40}(inside|committed in|included in).{0,80}same .{0,20}closeout commit') {
        throw "$Context.statement must explicitly state that the support packet is not inside the same closeout commit it verifies."
    }

    if ($statement -notmatch '(?i)(follow-up support commit|external artifact identity)') {
        throw "$Context.statement must explicitly allow a follow-up support commit or an external artifact identity."
    }

    if ($statement -match '(?i)(committed|included|inside).{0,40}same .{0,20}closeout commit' -and $statement -notmatch '(?i)not .{0,40}(committed|included|inside).{0,80}same .{0,20}closeout commit') {
        throw "$Context must not imply same-commit or self-referential proof."
    }
}

function Test-FinalRemoteHeadSupportObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $SupportPacket,
        [string]$SourceLabel = "Final remote-head support packet",
        [string]$AnchorPath = (Get-ModuleRepositoryRootPath)
    )

    $foundation = Get-PostPushSupportFoundationContract
    $contract = Get-FinalRemoteHeadSupportPacketContract

    Assert-RequiredObjectFields -Object $SupportPacket -FieldNames $contract.required_fields -Context $SourceLabel

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $SupportPacket -Name "contract_version" -Context $SourceLabel) -Context "$SourceLabel contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "$SourceLabel contract_version must be '$($foundation.contract_version)'."
    }

    $packetType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $SupportPacket -Name "packet_type" -Context $SourceLabel) -Context "$SourceLabel packet_type"
    if ($packetType -ne $contract.packet_type -or $packetType -ne $foundation.final_remote_head_support_packet_type) {
        throw "$SourceLabel packet_type must be '$($contract.packet_type)'."
    }

    $packetId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $SupportPacket -Name "packet_id" -Context $SourceLabel) -Context "$SourceLabel packet_id"
    Assert-MatchesPattern -Value $packetId -Pattern $foundation.identifier_pattern -Context "$SourceLabel packet_id"

    $repository = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $SupportPacket -Name "repository" -Context $SourceLabel) -Context "$SourceLabel repository"
    Assert-MatchesPattern -Value $repository -Pattern $foundation.repository_name_pattern -Context "$SourceLabel repository"
    if ($repository -ne $foundation.repository_name) {
        throw "$SourceLabel repository must be '$($foundation.repository_name)'."
    }

    $branch = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $SupportPacket -Name "branch" -Context $SourceLabel) -Context "$SourceLabel branch"
    Assert-MatchesPattern -Value $branch -Pattern $foundation.branch_pattern -Context "$SourceLabel branch"

    $verifiedRemoteHead = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $SupportPacket -Name "verified_remote_head" -Context $SourceLabel) -Context "$SourceLabel verified_remote_head"
    $verifiedTree = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $SupportPacket -Name "verified_tree" -Context $SourceLabel) -Context "$SourceLabel verified_tree"
    $closeoutCommit = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $SupportPacket -Name "closeout_commit" -Context $SourceLabel) -Context "$SourceLabel closeout_commit"

    foreach ($gitObject in @(
            @{ Value = $verifiedRemoteHead; Context = "$SourceLabel verified_remote_head" },
            @{ Value = $verifiedTree; Context = "$SourceLabel verified_tree" },
            @{ Value = $closeoutCommit; Context = "$SourceLabel closeout_commit" }
        )) {
        Assert-MatchesPattern -Value $gitObject.Value -Pattern $foundation.git_object_pattern -Context $gitObject.Context
    }

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $SupportPacket -Name "verified_commit_subject" -Context $SourceLabel) -Context "$SourceLabel verified_commit_subject" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $SupportPacket -Name "closeout_commit_subject" -Context $SourceLabel) -Context "$SourceLabel closeout_commit_subject" | Out-Null

    $verificationTiming = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $SupportPacket -Name "verification_timing" -Context $SourceLabel) -Context "$SourceLabel verification_timing"
    Assert-AllowedValue -Value $verificationTiming -AllowedValues $foundation.allowed_verification_timings -Context "$SourceLabel verification_timing"
    if ($verificationTiming -ne "after_closeout_push") {
        throw "$SourceLabel verification_timing must be 'after_closeout_push'."
    }

    $supportPacketCommitPolicy = Get-RequiredProperty -Object $SupportPacket -Name "support_packet_commit_policy" -Context $SourceLabel
    Assert-SupportPacketPolicy -Policy $supportPacketCommitPolicy -Foundation $foundation -Contract $contract -Context "$SourceLabel support_packet_commit_policy"

    $verificationMethod = Get-RequiredProperty -Object $SupportPacket -Name "verification_method" -Context $SourceLabel
    Assert-RequiredObjectFields -Object $verificationMethod -FieldNames $contract.verification_method_required_fields -Context "$SourceLabel verification_method"
    $methodType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $verificationMethod -Name "method_type" -Context "$SourceLabel verification_method") -Context "$SourceLabel verification_method.method_type"
    Assert-AllowedValue -Value $methodType -AllowedValues $foundation.allowed_verification_method_types -Context "$SourceLabel verification_method.method_type"
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $verificationMethod -Name "runner_identity" -Context "$SourceLabel verification_method") -Context "$SourceLabel verification_method.runner_identity" | Out-Null
    $externalRunIdentityRef = Assert-StringValue -Value (Get-RequiredProperty -Object $verificationMethod -Name "external_run_identity_ref" -Context "$SourceLabel verification_method") -Context "$SourceLabel verification_method.external_run_identity_ref"
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $verificationMethod -Name "notes" -Context "$SourceLabel verification_method") -Context "$SourceLabel verification_method.notes" | Out-Null

    $claimsExternalRunner = $methodType -eq "ci_runner" -or $methodType -eq "external_runner"
    if ($claimsExternalRunner -and ($externalRunIdentityRef -notmatch $foundation.concrete_run_identity_pattern)) {
        throw "$SourceLabel claims CI or external runner proof without a concrete run identity reference."
    }

    $verificationEvidenceRefs = Assert-StringArray -Value (Get-RequiredProperty -Object $SupportPacket -Name "verification_evidence_refs" -Context $SourceLabel) -Context "$SourceLabel verification_evidence_refs"
    foreach ($verificationEvidenceRef in $verificationEvidenceRefs) {
        Resolve-ExistingPath -PathValue $verificationEvidenceRef -Label "$SourceLabel verification_evidence_refs item" -AnchorPath $AnchorPath | Out-Null
    }

    $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $SupportPacket -Name "status" -Context $SourceLabel) -Context "$SourceLabel status"
    Assert-AllowedValue -Value $status -AllowedValues $foundation.allowed_statuses -Context "$SourceLabel status"

    $refusalReasons = Assert-StringArray -Value (Get-RequiredProperty -Object $SupportPacket -Name "refusal_reasons" -Context $SourceLabel) -Context "$SourceLabel refusal_reasons" -AllowEmpty
    if ($status -eq "passed") {
        if ($refusalReasons.Count -ne 0) {
            throw "$SourceLabel refusal_reasons must be empty when status is 'passed'."
        }

        if ($verifiedRemoteHead -ne $closeoutCommit) {
            throw "$SourceLabel verified_remote_head must match closeout_commit when status is 'passed'."
        }
    }
    else {
        if ($refusalReasons.Count -eq 0) {
            throw "$SourceLabel refusal_reasons must not be empty when status is '$status'."
        }
    }

    $createdAtUtc = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $SupportPacket -Name "created_at_utc" -Context $SourceLabel) -Context "$SourceLabel created_at_utc"
    Assert-MatchesPattern -Value $createdAtUtc -Pattern $foundation.timestamp_pattern -Context "$SourceLabel created_at_utc"

    $nonClaims = Assert-StringArray -Value (Get-RequiredProperty -Object $SupportPacket -Name "non_claims" -Context $SourceLabel) -Context "$SourceLabel non_claims"
    foreach ($requiredNonClaim in $foundation.required_non_claims) {
        if ($nonClaims -notcontains $requiredNonClaim) {
            throw "$SourceLabel non_claims must include '$requiredNonClaim'."
        }
    }

    return [pscustomobject]@{
        PacketId = $packetId
        Repository = $repository
        Branch = $branch
        VerifiedRemoteHead = $verifiedRemoteHead
        CloseoutCommit = $closeoutCommit
        Status = $status
        VerificationTiming = $verificationTiming
        VerificationMethodType = $methodType
    }
}

function Test-FinalRemoteHeadSupportContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PacketPath
    )

    $resolvedPacketPath = Resolve-ExistingPath -PathValue $PacketPath -Label "Final remote-head support packet"
    $supportPacket = Get-JsonDocument -Path $resolvedPacketPath -Label "Final remote-head support packet"
    return Test-FinalRemoteHeadSupportObject -SupportPacket $supportPacket -SourceLabel "Final remote-head support packet" -AnchorPath (Split-Path -Parent $resolvedPacketPath)
}

Export-ModuleMember -Function Test-FinalRemoteHeadSupportContract, Test-FinalRemoteHeadSupportObject
