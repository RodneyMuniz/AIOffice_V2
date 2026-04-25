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

function Write-Utf8File {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [AllowNull()]
        [string]$Value
    )

    $directory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($directory) -and -not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    if ($null -eq $Value) {
        $Value = ""
    }

    Set-Content -LiteralPath $Path -Value $Value -Encoding UTF8
}

function Write-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Document
    )

    $json = $Document | ConvertTo-Json -Depth 20
    Write-Utf8File -Path $Path -Value $json
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

function Get-QaProofFoundationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\qa_proof\foundation.contract.json") -Label "QA proof foundation contract"
}

function Get-PostPushVerificationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\qa_proof\post_push_verification.contract.json") -Label "Post-push verification contract"
}

function Get-UtcTimestamp {
    param(
        [datetime]$DateTime = (Get-Date).ToUniversalTime()
    )

    return $DateTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
}

function Get-GitTrimmedValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $output = & git -C $RepositoryRoot @Arguments 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "$Context failed."
    }

    return ([string]::Join([Environment]::NewLine, @($output))).Trim()
}

function Get-GitBranchName {
    param([Parameter(Mandatory = $true)][string]$RepositoryRoot)
    return Get-GitTrimmedValue -RepositoryRoot $RepositoryRoot -Arguments @("branch", "--show-current") -Context "Git branch lookup"
}

function Get-GitRemoteHeadCommit {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string]$RemoteName,
        [Parameter(Mandatory = $true)]
        [string]$Branch
    )

    try {
        $output = @(& git -C $RepositoryRoot ls-remote $RemoteName ("refs/heads/{0}" -f $Branch) 2>&1)
    }
    catch {
        throw "Post-push remote head lookup failed for remote '$RemoteName' branch '$Branch'."
    }

    if ($LASTEXITCODE -ne 0) {
        throw "Post-push remote head lookup failed for remote '$RemoteName' branch '$Branch'."
    }

    $line = ([string]::Join([Environment]::NewLine, @($output))).Trim()
    if ([string]::IsNullOrWhiteSpace($line)) {
        throw "Post-push remote branch head was not found for remote '$RemoteName' branch '$Branch'."
    }

    $parts = $line -split "\s+"
    if ($parts.Count -lt 1 -or [string]::IsNullOrWhiteSpace($parts[0])) {
        throw "Post-push remote head lookup returned malformed output for remote '$RemoteName' branch '$Branch'."
    }

    return $parts[0].Trim()
}

function Get-GitCommitSubject {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string]$Commit
    )

    return Get-GitTrimmedValue -RepositoryRoot $RepositoryRoot -Arguments @("log", "-1", "--pretty=%s", $Commit) -Context "Git commit subject lookup"
}

function Get-GitTreeIdForCommit {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string]$Commit
    )

    return Get-GitTrimmedValue -RepositoryRoot $RepositoryRoot -Arguments @("rev-parse", ("{0}^{{tree}}" -f $Commit)) -Context "Git tree lookup"
}

function Test-PostPushVerificationObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $PostPushVerification,
        [string]$SourceLabel = "Post-push verification"
    )

    $foundation = Get-QaProofFoundationContract
    $contract = Get-PostPushVerificationContract

    Assert-RequiredObjectFields -Object $PostPushVerification -FieldNames $contract.required_fields -Context $SourceLabel

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $PostPushVerification -Name "contract_version" -Context $SourceLabel) -Context "$SourceLabel contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "$SourceLabel contract_version must be '$($foundation.contract_version)'."
    }

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $PostPushVerification -Name "record_type" -Context $SourceLabel) -Context "$SourceLabel record_type"
    if ($recordType -ne $contract.record_type -or $recordType -ne $foundation.post_push_verification_record_type) {
        throw "$SourceLabel record_type must be '$($contract.record_type)'."
    }

    $verificationId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $PostPushVerification -Name "verification_id" -Context $SourceLabel) -Context "$SourceLabel verification_id"
    Assert-MatchesPattern -Value $verificationId -Pattern $foundation.identifier_pattern -Context "$SourceLabel verification_id"

    $repositoryName = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $PostPushVerification -Name "repository_name" -Context $SourceLabel) -Context "$SourceLabel repository_name"
    Assert-MatchesPattern -Value $repositoryName -Pattern $foundation.repository_name_pattern -Context "$SourceLabel repository_name"
    if ($repositoryName -ne $foundation.repository_name) {
        throw "$SourceLabel repository_name must be '$($foundation.repository_name)'."
    }

    $branch = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $PostPushVerification -Name "branch" -Context $SourceLabel) -Context "$SourceLabel branch"
    Assert-MatchesPattern -Value $branch -Pattern $foundation.branch_pattern -Context "$SourceLabel branch"

    $expectedPushedCommit = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $PostPushVerification -Name "expected_pushed_commit" -Context $SourceLabel) -Context "$SourceLabel expected_pushed_commit"
    $actualRemoteHead = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $PostPushVerification -Name "actual_remote_head" -Context $SourceLabel) -Context "$SourceLabel actual_remote_head"
    $treeHash = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $PostPushVerification -Name "tree_hash" -Context $SourceLabel) -Context "$SourceLabel tree_hash"
    foreach ($gitObject in @(
            @{ Value = $expectedPushedCommit; Context = "$SourceLabel expected_pushed_commit" },
            @{ Value = $actualRemoteHead; Context = "$SourceLabel actual_remote_head" },
            @{ Value = $treeHash; Context = "$SourceLabel tree_hash" }
        )) {
        Assert-MatchesPattern -Value $gitObject.Value -Pattern $foundation.git_object_pattern -Context $gitObject.Context
    }

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $PostPushVerification -Name "commit_subject" -Context $SourceLabel) -Context "$SourceLabel commit_subject" | Out-Null
    $verifiedAtUtc = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $PostPushVerification -Name "verified_at_utc" -Context $SourceLabel) -Context "$SourceLabel verified_at_utc"
    Assert-MatchesPattern -Value $verifiedAtUtc -Pattern $foundation.timestamp_pattern -Context "$SourceLabel verified_at_utc"

    $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $PostPushVerification -Name "status" -Context $SourceLabel) -Context "$SourceLabel status"
    Assert-AllowedValue -Value $status -AllowedValues $foundation.allowed_remote_head_verification_statuses -Context "$SourceLabel status"

    $result = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $PostPushVerification -Name "result" -Context $SourceLabel) -Context "$SourceLabel result"
    Assert-AllowedValue -Value $result -AllowedValues $foundation.allowed_remote_head_verification_results -Context "$SourceLabel result"

    $refusalReason = Get-RequiredProperty -Object $PostPushVerification -Name "refusal_reason" -Context $SourceLabel
    if ($null -eq $refusalReason -or $refusalReason -isnot [string]) {
        throw "$SourceLabel refusal_reason must be a string."
    }

    if ($status -eq "matched") {
        if ($result -ne "passed") {
            throw "$SourceLabel result must be 'passed' when status is 'matched'."
        }

        if ($expectedPushedCommit -ne $actualRemoteHead) {
            throw "$SourceLabel expected_pushed_commit and actual_remote_head must match when status is 'matched'."
        }

        if (-not [string]::IsNullOrWhiteSpace($refusalReason)) {
            throw "$SourceLabel refusal_reason must be empty when status is 'matched'."
        }
    }
    else {
        if ($result -ne "failed") {
            throw "$SourceLabel result must be 'failed' when status is 'mismatch'."
        }

        if ($expectedPushedCommit -eq $actualRemoteHead) {
            throw "$SourceLabel expected_pushed_commit and actual_remote_head must differ when status is 'mismatch'."
        }

        if ([string]::IsNullOrWhiteSpace($refusalReason)) {
            throw "$SourceLabel refusal_reason must be populated when status is 'mismatch'."
        }
    }

    return [pscustomobject]@{
        VerificationId = $verificationId
        RepositoryName = $repositoryName
        Branch = $branch
        ExpectedPushedCommit = $expectedPushedCommit
        ActualRemoteHead = $actualRemoteHead
        Status = $status
        Result = $result
    }
}

function Test-PostPushVerificationContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArtifactPath
    )

    $resolvedArtifactPath = Resolve-ExistingPath -PathValue $ArtifactPath -Label "Post-push verification artifact"
    $document = Get-JsonDocument -Path $resolvedArtifactPath -Label "Post-push verification artifact"
    return Test-PostPushVerificationObject -PostPushVerification $document -SourceLabel "Post-push verification artifact"
}

function Assert-PostPushVerificationSatisfied {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArtifactPath,
        [Parameter(Mandatory = $true)]
        [string]$ExpectedPushedCommit
    )

    $foundation = Get-QaProofFoundationContract
    $expectedCommit = Assert-NonEmptyString -Value $ExpectedPushedCommit -Context "ExpectedPushedCommit"
    Assert-MatchesPattern -Value $expectedCommit -Pattern $foundation.git_object_pattern -Context "ExpectedPushedCommit"

    $validation = Test-PostPushVerificationContract -ArtifactPath $ArtifactPath
    if ($validation.ExpectedPushedCommit -ne $expectedCommit) {
        throw "Post-push verification artifact expected_pushed_commit '$($validation.ExpectedPushedCommit)' does not match required commit '$expectedCommit'."
    }

    if ($validation.Result -ne "passed" -or $validation.Status -ne "matched") {
        throw "Post-push verification artifact does not prove that commit '$expectedCommit' landed remotely."
    }

    return $validation
}

function Invoke-PostPushVerification {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryName,
        [Parameter(Mandatory = $true)]
        [string]$Branch,
        [Parameter(Mandatory = $true)]
        [string]$ExpectedPushedCommit,
        [Parameter(Mandatory = $true)]
        [string]$OutputPath,
        [string]$RemoteName = "origin"
    )

    $foundation = Get-QaProofFoundationContract

    $resolvedRepositoryRoot = Resolve-ExistingPath -PathValue $RepositoryRoot -Label "Repository root"
    $repositoryNameValue = Assert-NonEmptyString -Value $RepositoryName -Context "RepositoryName"
    Assert-MatchesPattern -Value $repositoryNameValue -Pattern $foundation.repository_name_pattern -Context "RepositoryName"
    if ($repositoryNameValue -ne $foundation.repository_name) {
        throw "RepositoryName must be '$($foundation.repository_name)'."
    }

    $branchValue = Assert-NonEmptyString -Value $Branch -Context "Branch"
    Assert-MatchesPattern -Value $branchValue -Pattern $foundation.branch_pattern -Context "Branch"

    $currentBranch = Get-GitBranchName -RepositoryRoot $resolvedRepositoryRoot
    if ($currentBranch -ne $branchValue) {
        throw "Repository current branch '$currentBranch' does not match requested branch '$branchValue'."
    }

    $expectedCommit = Assert-NonEmptyString -Value $ExpectedPushedCommit -Context "ExpectedPushedCommit"
    Assert-MatchesPattern -Value $expectedCommit -Pattern $foundation.git_object_pattern -Context "ExpectedPushedCommit"

    $actualRemoteHead = Get-GitRemoteHeadCommit -RepositoryRoot $resolvedRepositoryRoot -RemoteName $RemoteName -Branch $branchValue
    $commitSubject = Get-GitCommitSubject -RepositoryRoot $resolvedRepositoryRoot -Commit $expectedCommit
    $treeHash = Get-GitTreeIdForCommit -RepositoryRoot $resolvedRepositoryRoot -Commit $expectedCommit

    $status = if ($expectedCommit -eq $actualRemoteHead) { "matched" } else { "mismatch" }
    $result = if ($status -eq "matched") { "passed" } else { "failed" }
    $refusalReason = if ($status -eq "matched") {
        ""
    }
    else {
        "Expected pushed commit '$expectedCommit' does not match actual remote head '$actualRemoteHead' for branch '$branchValue'."
    }

    $artifact = [pscustomobject]@{
        contract_version = $foundation.contract_version
        record_type = $foundation.post_push_verification_record_type
        verification_id = ("post-push-verification-{0}" -f ([guid]::NewGuid().ToString("N").Substring(0, 12)))
        repository_name = $repositoryNameValue
        branch = $branchValue
        expected_pushed_commit = $expectedCommit
        actual_remote_head = $actualRemoteHead
        commit_subject = $commitSubject
        tree_hash = $treeHash
        verified_at_utc = Get-UtcTimestamp
        status = $status
        result = $result
        refusal_reason = $refusalReason
    }

    $resolvedOutputPath = Resolve-PathValue -PathValue $OutputPath -AnchorPath $resolvedRepositoryRoot
    Write-JsonDocument -Path $resolvedOutputPath -Document $artifact
    $validation = Test-PostPushVerificationObject -PostPushVerification $artifact -SourceLabel "Post-push verification artifact"

    return [pscustomobject]@{
        ArtifactPath = $resolvedOutputPath
        VerificationId = $validation.VerificationId
        Branch = $validation.Branch
        ExpectedPushedCommit = $validation.ExpectedPushedCommit
        ActualRemoteHead = $validation.ActualRemoteHead
        Status = $validation.Status
        Result = $validation.Result
    }
}

Export-ModuleMember -Function Assert-PostPushVerificationSatisfied, Invoke-PostPushVerification, Test-PostPushVerificationContract, Test-PostPushVerificationObject
