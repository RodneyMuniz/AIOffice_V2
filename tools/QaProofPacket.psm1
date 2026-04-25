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

function Assert-ObjectArray {
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

    Write-Output -NoEnumerate $items
}

function Assert-IntegerValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -isnot [int] -and $Value -isnot [long]) {
        throw "$Context must be an integer."
    }

    return [int]$Value
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

function Get-QaProofFoundationContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\qa_proof\foundation.contract.json") -Label "QA proof foundation contract"
}

function Get-QaProofPacketContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\qa_proof\qa_proof_packet.contract.json") -Label "QA proof packet contract"
}

function Test-QaProofPacketObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $QaProofPacket,
        [string]$SourceLabel = "QA proof packet",
        [string]$AnchorPath = (Get-ModuleRepositoryRootPath)
    )

    $foundation = Get-QaProofFoundationContract
    $contract = Get-QaProofPacketContract

    Assert-RequiredObjectFields -Object $QaProofPacket -FieldNames $contract.required_fields -Context $SourceLabel

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaProofPacket -Name "contract_version" -Context $SourceLabel) -Context "$SourceLabel contract_version"
    if ($contractVersion -ne $foundation.contract_version) {
        throw "$SourceLabel contract_version must be '$($foundation.contract_version)'."
    }

    $packetType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaProofPacket -Name "packet_type" -Context $SourceLabel) -Context "$SourceLabel packet_type"
    if ($packetType -ne $contract.package_type -or $packetType -ne $foundation.qa_proof_packet_type) {
        throw "$SourceLabel packet_type must be '$($contract.package_type)'."
    }

    $packetId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaProofPacket -Name "packet_id" -Context $SourceLabel) -Context "$SourceLabel packet_id"
    Assert-MatchesPattern -Value $packetId -Pattern $foundation.identifier_pattern -Context "$SourceLabel packet_id"

    $repository = Get-RequiredProperty -Object $QaProofPacket -Name "repository" -Context $SourceLabel
    Assert-RequiredObjectFields -Object $repository -FieldNames $contract.repository_required_fields -Context "$SourceLabel repository"
    $repositoryName = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $repository -Name "repository_name" -Context "$SourceLabel repository") -Context "$SourceLabel repository.repository_name"
    if ($repositoryName -ne $foundation.repository_name) {
        throw "$SourceLabel repository.repository_name must be '$($foundation.repository_name)'."
    }
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $repository -Name "repository_root_relative" -Context "$SourceLabel repository") -Context "$SourceLabel repository.repository_root_relative" | Out-Null

    $branch = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaProofPacket -Name "branch" -Context $SourceLabel) -Context "$SourceLabel branch"
    Assert-MatchesPattern -Value $branch -Pattern $foundation.branch_pattern -Context "$SourceLabel branch"

    $localHead = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaProofPacket -Name "local_head" -Context $SourceLabel) -Context "$SourceLabel local_head"
    $remoteHead = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaProofPacket -Name "remote_head" -Context $SourceLabel) -Context "$SourceLabel remote_head"
    $checkedOutHead = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaProofPacket -Name "checked_out_head" -Context $SourceLabel) -Context "$SourceLabel checked_out_head"
    $treeHash = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaProofPacket -Name "tree_hash" -Context $SourceLabel) -Context "$SourceLabel tree_hash"

    foreach ($gitObject in @(
            @{ Value = $localHead; Context = "$SourceLabel local_head" },
            @{ Value = $remoteHead; Context = "$SourceLabel remote_head" },
            @{ Value = $checkedOutHead; Context = "$SourceLabel checked_out_head" },
            @{ Value = $treeHash; Context = "$SourceLabel tree_hash" }
        )) {
        Assert-MatchesPattern -Value $gitObject.Value -Pattern $foundation.git_object_pattern -Context $gitObject.Context
    }

    if ($localHead -ne $remoteHead -or $checkedOutHead -ne $remoteHead) {
        throw "$SourceLabel must preserve exact remote truth. local_head, remote_head, and checked_out_head must match."
    }

    $capturedAtUtc = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaProofPacket -Name "captured_at_utc" -Context $SourceLabel) -Context "$SourceLabel captured_at_utc"
    Assert-MatchesPattern -Value $capturedAtUtc -Pattern $foundation.timestamp_pattern -Context "$SourceLabel captured_at_utc"

    $commandList = Assert-StringArray -Value (Get-RequiredProperty -Object $QaProofPacket -Name "command_list" -Context $SourceLabel) -Context "$SourceLabel command_list"
    $commandResults = Assert-ObjectArray -Value (Get-RequiredProperty -Object $QaProofPacket -Name "command_results" -Context $SourceLabel) -Context "$SourceLabel command_results"
    if ($commandList.Count -ne $commandResults.Count) {
        throw "$SourceLabel command_list and command_results must have the same item count."
    }

    $environment = Get-RequiredProperty -Object $QaProofPacket -Name "environment" -Context $SourceLabel
    Assert-RequiredObjectFields -Object $environment -FieldNames $contract.environment_required_fields -Context "$SourceLabel environment"
    $runnerKind = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $environment -Name "runner_kind" -Context "$SourceLabel environment") -Context "$SourceLabel environment.runner_kind"
    Assert-AllowedValue -Value $runnerKind -AllowedValues $foundation.allowed_runner_kinds -Context "$SourceLabel environment.runner_kind"
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $environment -Name "runner_identity" -Context "$SourceLabel environment") -Context "$SourceLabel environment.runner_identity" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $environment -Name "platform" -Context "$SourceLabel environment") -Context "$SourceLabel environment.platform" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $environment -Name "shell" -Context "$SourceLabel environment") -Context "$SourceLabel environment.shell" | Out-Null
    $checkoutMode = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $environment -Name "checkout_mode" -Context "$SourceLabel environment") -Context "$SourceLabel environment.checkout_mode"
    Assert-AllowedValue -Value $checkoutMode -AllowedValues $foundation.allowed_checkout_modes -Context "$SourceLabel environment.checkout_mode"

    $workspaceState = Get-RequiredProperty -Object $QaProofPacket -Name "workspace_state" -Context $SourceLabel
    Assert-RequiredObjectFields -Object $workspaceState -FieldNames $contract.workspace_state_required_fields -Context "$SourceLabel workspace_state"
    $statusBefore = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $workspaceState -Name "status_before" -Context "$SourceLabel workspace_state") -Context "$SourceLabel workspace_state.status_before"
    $statusAfter = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $workspaceState -Name "status_after" -Context "$SourceLabel workspace_state") -Context "$SourceLabel workspace_state.status_after"
    Assert-AllowedValue -Value $statusBefore -AllowedValues $foundation.allowed_workspace_statuses -Context "$SourceLabel workspace_state.status_before"
    Assert-AllowedValue -Value $statusAfter -AllowedValues $foundation.allowed_workspace_statuses -Context "$SourceLabel workspace_state.status_after"
    Resolve-ExistingPath -PathValue (Get-RequiredProperty -Object $workspaceState -Name "git_status_porcelain_before_ref" -Context "$SourceLabel workspace_state") -Label "$SourceLabel workspace_state.git_status_porcelain_before_ref" -AnchorPath $AnchorPath | Out-Null
    Resolve-ExistingPath -PathValue (Get-RequiredProperty -Object $workspaceState -Name "git_status_porcelain_after_ref" -Context "$SourceLabel workspace_state") -Label "$SourceLabel workspace_state.git_status_porcelain_after_ref" -AnchorPath $AnchorPath | Out-Null
    Resolve-ExistingPath -PathValue (Get-RequiredProperty -Object $workspaceState -Name "git_diff_check_ref" -Context "$SourceLabel workspace_state") -Label "$SourceLabel workspace_state.git_diff_check_ref" -AnchorPath $AnchorPath | Out-Null

    $hasFailedCommand = $false
    for ($i = 0; $i -lt $commandResults.Count; $i++) {
        $commandResult = $commandResults[$i]
        $commandContext = "{0} command_results[{1}]" -f $SourceLabel, $i
        Assert-RequiredObjectFields -Object $commandResult -FieldNames $contract.command_result_required_fields -Context $commandContext

        $commandId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $commandResult -Name "command_id" -Context $commandContext) -Context "$commandContext.command_id"
        Assert-MatchesPattern -Value $commandId -Pattern $foundation.identifier_pattern -Context "$commandContext.command_id"
        $command = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $commandResult -Name "command" -Context $commandContext) -Context "$commandContext.command"
        if ($commandList[$i] -ne $command) {
            throw "$commandContext.command must match command_list[$i]."
        }

        Resolve-ExistingPath -PathValue (Get-RequiredProperty -Object $commandResult -Name "stdout_log_ref" -Context $commandContext) -Label "$commandContext.stdout_log_ref" -AnchorPath $AnchorPath | Out-Null
        Resolve-ExistingPath -PathValue (Get-RequiredProperty -Object $commandResult -Name "stderr_log_ref" -Context $commandContext) -Label "$commandContext.stderr_log_ref" -AnchorPath $AnchorPath | Out-Null

        $exitCode = Assert-IntegerValue -Value (Get-RequiredProperty -Object $commandResult -Name "exit_code" -Context $commandContext) -Context "$commandContext.exit_code"
        if ($exitCode -lt 0) {
            throw "$commandContext.exit_code must be zero or greater."
        }

        $commandStatus = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $commandResult -Name "status" -Context $commandContext) -Context "$commandContext.status"
        Assert-AllowedValue -Value $commandStatus -AllowedValues $foundation.allowed_command_statuses -Context "$commandContext.status"

        if (($exitCode -eq 0 -and $commandStatus -ne "passed") -or ($exitCode -ne 0 -and $commandStatus -ne "failed")) {
            throw "$commandContext exit_code and status must agree."
        }

        if ($commandStatus -eq "failed") {
            $hasFailedCommand = $true
        }
    }

    $artifactHashes = Assert-ObjectArray -Value (Get-RequiredProperty -Object $QaProofPacket -Name "artifact_hashes" -Context $SourceLabel) -Context "$SourceLabel artifact_hashes"
    foreach ($artifactHash in $artifactHashes) {
        $artifactContext = "$SourceLabel artifact_hashes item"
        Assert-RequiredObjectFields -Object $artifactHash -FieldNames $contract.artifact_hash_required_fields -Context $artifactContext
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $artifactHash -Name "artifact_label" -Context $artifactContext) -Context "$artifactContext.artifact_label" | Out-Null
        Resolve-ExistingPath -PathValue (Get-RequiredProperty -Object $artifactHash -Name "artifact_ref" -Context $artifactContext) -Label "$artifactContext.artifact_ref" -AnchorPath $AnchorPath | Out-Null
        $hashSha256 = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $artifactHash -Name "hash_sha256" -Context $artifactContext) -Context "$artifactContext.hash_sha256"
        Assert-MatchesPattern -Value $hashSha256 -Pattern $foundation.sha256_pattern -Context "$artifactContext.hash_sha256"
    }

    $qaVerdict = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaProofPacket -Name "qa_verdict" -Context $SourceLabel) -Context "$SourceLabel qa_verdict"
    Assert-AllowedValue -Value $qaVerdict -AllowedValues $foundation.allowed_qa_verdicts -Context "$SourceLabel qa_verdict"

    $refusalReasons = Assert-StringArray -Value (Get-RequiredProperty -Object $QaProofPacket -Name "refusal_reasons" -Context $SourceLabel) -Context "$SourceLabel refusal_reasons" -AllowEmpty

    $executorSelfCertificationState = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaProofPacket -Name "executor_self_certification_state" -Context $SourceLabel) -Context "$SourceLabel executor_self_certification_state"
    Assert-AllowedValue -Value $executorSelfCertificationState -AllowedValues $foundation.allowed_executor_self_certification_states -Context "$SourceLabel executor_self_certification_state"

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QaProofPacket -Name "notes" -Context $SourceLabel) -Context "$SourceLabel notes" | Out-Null

    $hasDirtyWorkspace = $statusBefore -eq "dirty" -or $statusAfter -eq "dirty"

    if ($qaVerdict -eq "passed") {
        if ($refusalReasons.Count -gt 0) {
            throw "$SourceLabel refusal_reasons must be empty when qa_verdict is 'passed'."
        }

        if ($hasFailedCommand) {
            throw "$SourceLabel cannot report qa_verdict 'passed' when any command failed."
        }

        if ($hasDirtyWorkspace) {
            throw "$SourceLabel cannot report qa_verdict 'passed' when workspace_state is dirty before or after execution."
        }
    }
    else {
        if ($refusalReasons.Count -eq 0) {
            throw "$SourceLabel refusal_reasons must not be empty when qa_verdict is '$qaVerdict'."
        }

        if (-not ($hasFailedCommand -or $hasDirtyWorkspace)) {
            throw "$SourceLabel must capture at least one failed command or dirty workspace state when qa_verdict is '$qaVerdict'."
        }
    }

    return [pscustomobject]@{
        PacketId = $packetId
        RepositoryName = $repositoryName
        Branch = $branch
        RemoteHead = $remoteHead
        CheckedOutHead = $checkedOutHead
        Verdict = $qaVerdict
        CommandCount = $commandResults.Count
    }
}

function Test-QaProofPacketContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PacketPath
    )

    $resolvedPacketPath = Resolve-ExistingPath -PathValue $PacketPath -Label "QA proof packet"
    $qaProofPacket = Get-JsonDocument -Path $resolvedPacketPath -Label "QA proof packet"
    return Test-QaProofPacketObject -QaProofPacket $qaProofPacket -SourceLabel "QA proof packet" -AnchorPath (Split-Path -Parent $resolvedPacketPath)
}

Export-ModuleMember -Function Test-QaProofPacketContract, Test-QaProofPacketObject
