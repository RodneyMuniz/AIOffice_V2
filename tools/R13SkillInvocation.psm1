Set-StrictMode -Version Latest

$registryModule = Import-Module (Join-Path $PSScriptRoot "R13SkillRegistry.psm1") -Force -PassThru
$script:GetRepositoryRoot = $registryModule.ExportedCommands["Get-RepositoryRoot"]
$script:ResolveRepositoryPath = $registryModule.ExportedCommands["Resolve-RepositoryPath"]
$script:ConvertToRepositoryRelativePath = $registryModule.ExportedCommands["Convert-ToRepositoryRelativePath"]
$script:TestRepositoryRelativePath = $registryModule.ExportedCommands["Test-RepositoryRelativePath"]
$script:AssertRepositoryRelativePath = $registryModule.ExportedCommands["Assert-RepositoryRelativePath"]
$script:AssertExistingRef = $registryModule.ExportedCommands["Assert-ExistingRef"]
$script:GetUtcTimestamp = $registryModule.ExportedCommands["Get-UtcTimestamp"]
$script:GetJsonDocument = $registryModule.ExportedCommands["Get-JsonDocument"]
$script:WriteJsonFile = $registryModule.ExportedCommands["Write-R13SkillJsonFile"]
$script:WriteTextFile = $registryModule.ExportedCommands["Write-R13SkillTextFile"]
$script:TestHasProperty = $registryModule.ExportedCommands["Test-HasProperty"]
$script:GetRequiredProperty = $registryModule.ExportedCommands["Get-RequiredProperty"]
$script:AssertNonEmptyString = $registryModule.ExportedCommands["Assert-NonEmptyString"]
$script:AssertStringValue = $registryModule.ExportedCommands["Assert-StringValue"]
$script:AssertIntegerValue = $registryModule.ExportedCommands["Assert-IntegerValue"]
$script:AssertObjectValue = $registryModule.ExportedCommands["Assert-ObjectValue"]
$script:AssertStringArray = $registryModule.ExportedCommands["Assert-StringArray"]
$script:AssertObjectArray = $registryModule.ExportedCommands["Assert-ObjectArray"]
$script:AssertRequiredObjectFields = $registryModule.ExportedCommands["Assert-RequiredObjectFields"]
$script:AssertAllowedValue = $registryModule.ExportedCommands["Assert-AllowedValue"]
$script:AssertGitObjectId = $registryModule.ExportedCommands["Assert-GitObjectId"]
$script:AssertTimestampString = $registryModule.ExportedCommands["Assert-TimestampString"]
$script:GetGitIdentity = $registryModule.ExportedCommands["Get-R13SkillGitIdentity"]
$script:GetStableId = $registryModule.ExportedCommands["Get-StableId"]
$script:AssertNoForbiddenClaims = $registryModule.ExportedCommands["Assert-NoForbiddenR13SkillClaims"]
$script:AssertRequiredNonClaims = $registryModule.ExportedCommands["Assert-RequiredNonClaims"]
$script:AssertStandardIdentity = $registryModule.ExportedCommands["Assert-StandardIdentity"]
$script:AssertRefArray = $registryModule.ExportedCommands["Assert-RefArray"]
$script:AssertCommandHasNoForbiddenMutation = $registryModule.ExportedCommands["Assert-CommandHasNoForbiddenMutation"]
$script:AssertAllowedCommandShape = $registryModule.ExportedCommands["Assert-AllowedCommandShape"]
$script:TestCommandAllowedByRegistry = $registryModule.ExportedCommands["Test-R13SkillCommandAllowedByRegistry"]
$script:GetAllowedInvocationModes = $registryModule.ExportedCommands["Get-R13SkillAllowedInvocationModes"]
$script:GetSkillById = $registryModule.ExportedCommands["Get-R13SkillById"]
$script:TestRegistryObject = $registryModule.ExportedCommands["Test-R13SkillRegistryObject"]

$script:R13RepositoryName = "AIOffice_V2"
$script:R13Branch = "release/r13-api-first-qa-pipeline-and-operator-control-room-product-slice"
$script:R13Milestone = "R13 API-First QA Pipeline and Operator Control-Room Product Slice"
$script:R13SourceTask = "R13-008"
$script:AllowedExecutionStatuses = @("completed", "blocked", "failed")
$script:AllowedAggregateVerdicts = @("passed", "failed", "blocked")
$script:AllowedCommandVerdicts = @("passed", "failed", "blocked")

function Invoke-RegistryFunction {
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.CommandInfo]$Command,
        [Parameter(ValueFromRemainingArguments = $true)]
        [object[]]$Arguments
    )

    & $Command @Arguments
}

function Get-RepoRoot {
    return (& $script:GetRepositoryRoot)
}

function Get-R13SkillInvocationRequestContract {
    return (& $script:GetJsonDocument -Path (Join-Path (Get-RepoRoot) "contracts\skills\r13_skill_invocation_request.contract.json") -Label "R13 skill invocation request contract")
}

function Get-R13SkillInvocationResultContract {
    return (& $script:GetJsonDocument -Path (Join-Path (Get-RepoRoot) "contracts\skills\r13_skill_invocation_result.contract.json") -Label "R13 skill invocation result contract")
}

function Test-OutputRefInAllowedRoot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Ref,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    & $script:AssertRepositoryRelativePath -PathValue $Ref -Context $Context
    $normalized = $Ref.Replace("\", "/")
    if ($normalized -notmatch '^state/cycles/' -and $normalized -notmatch '^state/skills/') {
        throw "$Context must be inside state/cycles or state/skills."
    }
}

function Test-BroadAllowedPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue
    )

    $normalized = $PathValue.Replace("\", "/").TrimEnd("/")
    return $normalized -in @(".", "./", "*", "**", "state", "state/cycles", "state/skills", "tools", "tests")
}

function Assert-AllowedPaths {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $paths = & $script:AssertStringArray -Value $Value -Context $Context
    foreach ($path in @($paths)) {
        if (Test-BroadAllowedPath -PathValue $path) {
            throw "$Context contains overly broad path '$path'."
        }
        & $script:AssertRepositoryRelativePath -PathValue $path -Context "$Context item"
    }

    $PSCmdlet.WriteObject($paths, $false)
}

function Test-RefWithinAllowedPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Ref,
        [Parameter(Mandatory = $true)]
        [string[]]$AllowedPaths
    )

    $refFullPath = [System.IO.Path]::GetFullPath((& $script:ResolveRepositoryPath -PathValue $Ref))
    foreach ($allowedPath in @($AllowedPaths)) {
        $allowedFullPath = [System.IO.Path]::GetFullPath((& $script:ResolveRepositoryPath -PathValue $allowedPath)).TrimEnd([char[]]@([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar))
        if ($refFullPath.Equals($allowedFullPath, [System.StringComparison]::OrdinalIgnoreCase) -or $refFullPath.StartsWith($allowedFullPath + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }

    return $false
}

function Assert-OperatorApproval {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $approval = & $script:AssertObjectValue -Value $Value -Context $Context
    & $script:AssertRequiredObjectFields -Object $approval -FieldNames @("approval_status", "approved_by", "approved_at_utc", "approval_scope") -Context $Context
    $status = & $script:AssertNonEmptyString -Value $approval.approval_status -Context "$Context approval_status"
    if ($status -ne "approved_for_local_non_mutating_skill_invocation") {
        throw "$Context approval_status must be approved_for_local_non_mutating_skill_invocation."
    }
    & $script:AssertNonEmptyString -Value $approval.approved_by -Context "$Context approved_by" | Out-Null
    & $script:AssertTimestampString -Value $approval.approved_at_utc -Context "$Context approved_at_utc"
    $scope = & $script:AssertNonEmptyString -Value $approval.approval_scope -Context "$Context approval_scope"
    if ($scope -notmatch '(?i)local|repo' -or $scope -notmatch '(?i)non[- ]?mutating|validation|dry[- ]?run') {
        throw "$Context approval_scope must explicitly scope local/repo non-mutating skill invocation."
    }
}

function Assert-RequestedOutputs {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [Parameter(Mandatory = $true)]
        [string[]]$AllowedPaths
    )

    $outputs = & $script:AssertObjectArray -Value $Value -Context $Context
    $outputIds = @{}
    foreach ($output in @($outputs)) {
        & $script:AssertRequiredObjectFields -Object $output -FieldNames @("output_id", "ref", "artifact_type", "contract_ref") -Context $Context
        $outputId = & $script:AssertNonEmptyString -Value $output.output_id -Context "$Context output_id"
        if ($outputIds.ContainsKey($outputId)) {
            throw "$Context contains duplicate output_id '$outputId'."
        }
        $outputIds[$outputId] = $true
        $ref = & $script:AssertNonEmptyString -Value $output.ref -Context "$Context ref"
        Test-OutputRefInAllowedRoot -Ref $ref -Context "$Context ref"
        if (-not (Test-RefWithinAllowedPath -Ref $ref -AllowedPaths $AllowedPaths)) {
            throw "$Context ref '$ref' must be covered by allowed_paths."
        }
        & $script:AssertNonEmptyString -Value $output.artifact_type -Context "$Context artifact_type" | Out-Null
        $contractRef = & $script:AssertNonEmptyString -Value $output.contract_ref -Context "$Context contract_ref"
        & $script:AssertExistingRef -Ref $contractRef -Context "$Context contract_ref"
    }

    $PSCmdlet.WriteObject($outputs, $false)
}

function Test-R13SkillInvocationRequestObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Request,
        [Parameter(Mandatory = $true)]
        $Registry,
        [string]$SourceLabel = "R13 skill invocation request"
    )

    & $script:TestRegistryObject -Registry $Registry -SourceLabel "R13 skill registry" | Out-Null
    $contract = Get-R13SkillInvocationRequestContract
    & $script:AssertRequiredObjectFields -Object $Request -FieldNames $contract.required_fields -Context $SourceLabel

    if ($Request.contract_version -ne "v1") {
        throw "$SourceLabel contract_version must be v1."
    }
    if ($Request.artifact_type -ne "r13_skill_invocation_request") {
        throw "$SourceLabel artifact_type must be r13_skill_invocation_request."
    }
    $invocationId = & $script:AssertNonEmptyString -Value $Request.invocation_id -Context "$SourceLabel invocation_id"
    & $script:AssertStandardIdentity -Artifact $Request -SourceLabel $SourceLabel
    $skillId = & $script:AssertNonEmptyString -Value $Request.skill_id -Context "$SourceLabel skill_id"
    $skill = & $script:GetSkillById -Registry $Registry -SkillId $skillId
    if ($null -eq $skill) {
        throw "$SourceLabel skill_id '$skillId' is not registered."
    }
    $skillVersion = & $script:AssertNonEmptyString -Value $Request.skill_version -Context "$SourceLabel skill_version"
    if ($skillVersion -ne [string]$skill.skill_version) {
        throw "$SourceLabel skill_version must match registry skill_version for '$skillId'."
    }
    $invocationMode = & $script:AssertNonEmptyString -Value $Request.invocation_mode -Context "$SourceLabel invocation_mode"
    & $script:AssertAllowedValue -Value $invocationMode -AllowedValues (& $script:GetAllowedInvocationModes) -Context "$SourceLabel invocation_mode"

    $allowedPaths = Assert-AllowedPaths -Value $Request.allowed_paths -Context "$SourceLabel allowed_paths"
    $inputRefs = & $script:AssertRefArray -Value $Request.input_refs -Context "$SourceLabel input_refs" -RequireExists
    foreach ($inputRef in @($inputRefs)) {
        if (-not (Test-RefWithinAllowedPath -Ref ([string]$inputRef.ref) -AllowedPaths $allowedPaths)) {
            throw "$SourceLabel input ref '$($inputRef.ref)' must be covered by allowed_paths."
        }
    }
    $requestedOutputs = Assert-RequestedOutputs -Value $Request.requested_outputs -Context "$SourceLabel requested_outputs" -AllowedPaths $allowedPaths
    $expectedResultRef = & $script:AssertNonEmptyString -Value $Request.expected_result_ref -Context "$SourceLabel expected_result_ref"
    Test-OutputRefInAllowedRoot -Ref $expectedResultRef -Context "$SourceLabel expected_result_ref"
    if (-not (Test-RefWithinAllowedPath -Ref $expectedResultRef -AllowedPaths $allowedPaths)) {
        throw "$SourceLabel expected_result_ref must be covered by allowed_paths."
    }
    if (@($requestedOutputs | Where-Object { [string]$_.ref -eq $expectedResultRef }).Count -eq 0) {
        throw "$SourceLabel requested_outputs must include expected_result_ref."
    }

    $allowedCommands = & $script:AssertAllowedCommandShape -Value $Request.allowed_commands -Context "$SourceLabel allowed_commands" -AllowEmpty:($invocationMode -eq "dry_run_only")
    foreach ($commandObject in @($allowedCommands)) {
        $command = [string]$commandObject.command
        if (-not (& $script:TestCommandAllowedByRegistry -Command $command -Skill $skill)) {
            throw "$SourceLabel allowed command '$($commandObject.command_id)' is outside the registered '$skillId' boundary."
        }
        if ($skillId -eq "runner.external_replay" -and $command -match '(?i)\b(workflow\s+run|invoke_external_runner|watch_external_runner|capture_external_runner|r12-external-replay)\b') {
            throw "$SourceLabel attempts external replay execution in R13-008."
        }
    }
    if ($skillId -eq "runner.external_replay" -and $invocationMode -eq "generate_artifact") {
        throw "$SourceLabel cannot generate external replay execution artifacts in R13-008."
    }
    if ($skillId -eq "control_room.refresh" -and $invocationMode -eq "generate_artifact") {
        throw "$SourceLabel cannot deliver current control-room refresh artifacts in R13-008."
    }

    Assert-OperatorApproval -Value $Request.operator_approval -Context "$SourceLabel operator_approval"
    & $script:AssertRefArray -Value $Request.evidence_refs -Context "$SourceLabel evidence_refs" -RequireExists | Out-Null
    & $script:AssertStringArray -Value $Request.refusal_reasons -Context "$SourceLabel refusal_reasons" -AllowEmpty | Out-Null
    & $script:AssertTimestampString -Value $Request.created_at_utc -Context "$SourceLabel created_at_utc"
    $nonClaims = & $script:AssertStringArray -Value $Request.non_claims -Context "$SourceLabel non_claims"
    & $script:AssertRequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel
    & $script:AssertNoForbiddenClaims -Value $Request -Context $SourceLabel

    $PSCmdlet.WriteObject([pscustomobject][ordered]@{
        InvocationId = $invocationId
        SkillId = $skillId
        SkillVersion = $skillVersion
        InvocationMode = $invocationMode
        CommandCount = @($allowedCommands).Count
        InputRefCount = @($inputRefs).Count
        ExpectedResultRef = $expectedResultRef
    }, $false)
}

function Test-R13SkillInvocationRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RequestPath,
        [Parameter(Mandatory = $true)]
        [string]$RegistryPath
    )

    $registry = & $script:GetJsonDocument -Path $RegistryPath -Label "R13 skill registry"
    $request = & $script:GetJsonDocument -Path $RequestPath -Label "R13 skill invocation request"
    return Test-R13SkillInvocationRequestObject -Request $request -Registry $registry -SourceLabel "R13 skill invocation request"
}

function Assert-OutputArtifacts {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [switch]$AllowEmpty
    )

    $artifacts = & $script:AssertObjectArray -Value $Value -Context $Context -AllowEmpty:$AllowEmpty
    $artifactIds = @{}
    foreach ($artifact in @($artifacts)) {
        & $script:AssertRequiredObjectFields -Object $artifact -FieldNames @("artifact_id", "ref", "artifact_type", "evidence_kind", "validation_status") -Context $Context
        $artifactId = & $script:AssertNonEmptyString -Value $artifact.artifact_id -Context "$Context artifact_id"
        if ($artifactIds.ContainsKey($artifactId)) {
            throw "$Context contains duplicate artifact_id '$artifactId'."
        }
        $artifactIds[$artifactId] = $true
        $ref = & $script:AssertNonEmptyString -Value $artifact.ref -Context "$Context ref"
        & $script:AssertRepositoryRelativePath -PathValue $ref -Context "$Context ref"
        & $script:AssertNonEmptyString -Value $artifact.artifact_type -Context "$Context artifact_type" | Out-Null
        & $script:AssertNonEmptyString -Value $artifact.evidence_kind -Context "$Context evidence_kind" | Out-Null
        $validationStatus = & $script:AssertNonEmptyString -Value $artifact.validation_status -Context "$Context validation_status"
        if ($validationStatus -notin @("created", "available", "validated", "not_created", "blocked")) {
            throw "$Context validation_status must be created, available, validated, not_created, or blocked."
        }
        if ($validationStatus -notin @("not_created", "blocked") -and -not (Test-Path -LiteralPath (& $script:ResolveRepositoryPath -PathValue $ref))) {
            throw "$Context ref '$ref' does not exist."
        }
    }

    $PSCmdlet.WriteObject($artifacts, $false)
}

function Test-R13SkillInvocationResultObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Result,
        [Parameter(Mandatory = $true)]
        $Registry,
        [string]$SourceLabel = "R13 skill invocation result"
    )

    & $script:TestRegistryObject -Registry $Registry -SourceLabel "R13 skill registry" | Out-Null
    $contract = Get-R13SkillInvocationResultContract
    & $script:AssertRequiredObjectFields -Object $Result -FieldNames $contract.required_fields -Context $SourceLabel

    if ($Result.contract_version -ne "v1") {
        throw "$SourceLabel contract_version must be v1."
    }
    if ($Result.artifact_type -ne "r13_skill_invocation_result") {
        throw "$SourceLabel artifact_type must be r13_skill_invocation_result."
    }
    $resultId = & $script:AssertNonEmptyString -Value $Result.result_id -Context "$SourceLabel result_id"
    $invocationId = & $script:AssertNonEmptyString -Value $Result.invocation_id -Context "$SourceLabel invocation_id"
    & $script:AssertStandardIdentity -Artifact $Result -SourceLabel $SourceLabel
    $skillId = & $script:AssertNonEmptyString -Value $Result.skill_id -Context "$SourceLabel skill_id"
    $skill = & $script:GetSkillById -Registry $Registry -SkillId $skillId
    if ($null -eq $skill) {
        throw "$SourceLabel skill_id '$skillId' is not registered."
    }
    $skillVersion = & $script:AssertNonEmptyString -Value $Result.skill_version -Context "$SourceLabel skill_version"
    if ($skillVersion -ne [string]$skill.skill_version) {
        throw "$SourceLabel skill_version must match registry skill_version for '$skillId'."
    }
    $invocationMode = & $script:AssertNonEmptyString -Value $Result.invocation_mode -Context "$SourceLabel invocation_mode"
    & $script:AssertAllowedValue -Value $invocationMode -AllowedValues (& $script:GetAllowedInvocationModes) -Context "$SourceLabel invocation_mode"
    $executionStatus = & $script:AssertNonEmptyString -Value $Result.execution_status -Context "$SourceLabel execution_status"
    & $script:AssertAllowedValue -Value $executionStatus -AllowedValues $script:AllowedExecutionStatuses -Context "$SourceLabel execution_status"
    $aggregateVerdict = & $script:AssertNonEmptyString -Value $Result.aggregate_verdict -Context "$SourceLabel aggregate_verdict"
    & $script:AssertAllowedValue -Value $aggregateVerdict -AllowedValues $script:AllowedAggregateVerdicts -Context "$SourceLabel aggregate_verdict"

    $commandResults = & $script:AssertObjectArray -Value $Result.command_results -Context "$SourceLabel command_results" -AllowEmpty
    $passedCount = 0
    $failedCount = 0
    $blockedCount = 0
    foreach ($commandResult in @($commandResults)) {
        & $script:AssertRequiredObjectFields -Object $commandResult -FieldNames @("command_id", "command", "exit_code", "verdict", "stdout_ref", "stderr_ref", "started_at_utc", "completed_at_utc") -Context "$SourceLabel command_results"
        & $script:AssertNonEmptyString -Value $commandResult.command_id -Context "$SourceLabel command_results command_id" | Out-Null
        $command = & $script:AssertNonEmptyString -Value $commandResult.command -Context "$SourceLabel command_results command"
        if (-not (& $script:TestCommandAllowedByRegistry -Command $command -Skill $skill)) {
            throw "$SourceLabel command_results command is outside registered '$skillId' boundary."
        }
        & $script:AssertCommandHasNoForbiddenMutation -Command $command -Context "$SourceLabel command_results command"
        & $script:AssertIntegerValue -Value $commandResult.exit_code -Context "$SourceLabel command_results exit_code" | Out-Null
        $verdict = & $script:AssertNonEmptyString -Value $commandResult.verdict -Context "$SourceLabel command_results verdict"
        & $script:AssertAllowedValue -Value $verdict -AllowedValues $script:AllowedCommandVerdicts -Context "$SourceLabel command_results verdict"
        if ($verdict -eq "passed") { $passedCount += 1 }
        if ($verdict -eq "failed") { $failedCount += 1 }
        if ($verdict -eq "blocked") { $blockedCount += 1 }
        & $script:AssertExistingRef -Ref (& $script:AssertNonEmptyString -Value $commandResult.stdout_ref -Context "$SourceLabel command_results stdout_ref") -Context "$SourceLabel command_results stdout_ref"
        & $script:AssertExistingRef -Ref (& $script:AssertNonEmptyString -Value $commandResult.stderr_ref -Context "$SourceLabel command_results stderr_ref") -Context "$SourceLabel command_results stderr_ref"
        & $script:AssertTimestampString -Value $commandResult.started_at_utc -Context "$SourceLabel command_results started_at_utc"
        & $script:AssertTimestampString -Value $commandResult.completed_at_utc -Context "$SourceLabel command_results completed_at_utc"
    }

    Assert-OutputArtifacts -Value $Result.output_artifacts -Context "$SourceLabel output_artifacts" -AllowEmpty:($aggregateVerdict -eq "blocked") | Out-Null
    & $script:AssertRefArray -Value $Result.evidence_refs -Context "$SourceLabel evidence_refs" -RequireExists | Out-Null
    $refusalReasons = & $script:AssertStringArray -Value $Result.refusal_reasons -Context "$SourceLabel refusal_reasons" -AllowEmpty
    & $script:AssertTimestampString -Value $Result.started_at_utc -Context "$SourceLabel started_at_utc"
    & $script:AssertTimestampString -Value $Result.completed_at_utc -Context "$SourceLabel completed_at_utc"
    $nonClaims = & $script:AssertStringArray -Value $Result.non_claims -Context "$SourceLabel non_claims"
    & $script:AssertRequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel
    & $script:AssertNoForbiddenClaims -Value $Result -Context $SourceLabel

    if ($aggregateVerdict -eq "passed" -and ($commandResults.Count -eq 0 -or $failedCount -ne 0 -or $blockedCount -ne 0)) {
        throw "$SourceLabel aggregate_verdict passed requires at least one command and all commands passing."
    }
    if ($aggregateVerdict -eq "failed" -and $failedCount -eq 0) {
        throw "$SourceLabel aggregate_verdict failed requires at least one failed command."
    }
    if ($aggregateVerdict -eq "blocked" -and @($refusalReasons).Count -eq 0) {
        throw "$SourceLabel aggregate_verdict blocked requires refusal_reasons."
    }
    if ($executionStatus -eq "completed" -and $aggregateVerdict -eq "blocked") {
        throw "$SourceLabel completed execution cannot have aggregate_verdict blocked."
    }
    if ($executionStatus -eq "blocked" -and $aggregateVerdict -ne "blocked") {
        throw "$SourceLabel blocked execution_status must have aggregate_verdict blocked."
    }

    $PSCmdlet.WriteObject([pscustomobject][ordered]@{
        ResultId = $resultId
        InvocationId = $invocationId
        SkillId = $skillId
        SkillVersion = $skillVersion
        InvocationMode = $invocationMode
        ExecutionStatus = $executionStatus
        CommandCount = @($commandResults).Count
        PassedCommandCount = $passedCount
        FailedCommandCount = $failedCount
        BlockedCommandCount = $blockedCount
        AggregateVerdict = $aggregateVerdict
    }, $false)
}

function Test-R13SkillInvocationResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResultPath,
        [Parameter(Mandatory = $true)]
        [string]$RegistryPath
    )

    $registry = & $script:GetJsonDocument -Path $RegistryPath -Label "R13 skill registry"
    $result = & $script:GetJsonDocument -Path $ResultPath -Label "R13 skill invocation result"
    return Test-R13SkillInvocationResultObject -Result $result -Registry $registry -SourceLabel "R13 skill invocation result"
}

function Split-SimpleCommandLine {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command
    )

    $matches = [regex]::Matches($Command, '(?:"([^"]*)"|(\S+))')
    foreach ($match in $matches) {
        if ($match.Groups[1].Success) {
            $PSCmdlet.WriteObject($match.Groups[1].Value, $false)
        }
        else {
            $PSCmdlet.WriteObject($match.Groups[2].Value, $false)
        }
    }
}

function New-EvidenceRef {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RefId,
        [Parameter(Mandatory = $true)]
        [string]$Ref,
        [Parameter(Mandatory = $true)]
        [string]$EvidenceKind,
        [string]$AuthorityKind = "repo_tooling",
        [string]$Scope = "repo"
    )

    return [pscustomobject][ordered]@{
        ref_id = $RefId
        ref = $Ref.Replace("\", "/")
        evidence_kind = $EvidenceKind
        authority_kind = $AuthorityKind
        scope = $Scope
    }
}

function Invoke-SkillCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $CommandObject,
        [Parameter(Mandatory = $true)]
        [int]$Index,
        [Parameter(Mandatory = $true)]
        [string]$OutputRoot
    )

    $commandId = [string]$CommandObject.command_id
    $command = [string]$CommandObject.command
    $number = $Index.ToString("000", [System.Globalization.CultureInfo]::InvariantCulture)
    $stdoutRef = (Join-Path $OutputRoot ("command_{0}_{1}_stdout.log" -f $number, $commandId)).Replace("\", "/")
    $stderrRef = (Join-Path $OutputRoot ("command_{0}_{1}_stderr.log" -f $number, $commandId)).Replace("\", "/")
    $stdoutPath = & $script:ResolveRepositoryPath -PathValue $stdoutRef
    $stderrPath = & $script:ResolveRepositoryPath -PathValue $stderrRef
    New-Item -ItemType Directory -Path (Split-Path -Parent $stdoutPath) -Force | Out-Null

    $startedAt = & $script:GetUtcTimestamp
    $tokens = @(Split-SimpleCommandLine -Command $command)
    if ($tokens.Count -eq 0) {
        & $script:WriteTextFile -Path $stdoutRef -Value ""
        & $script:WriteTextFile -Path $stderrRef -Value "Command could not be tokenized."
        return [pscustomobject][ordered]@{
            CommandResult = [pscustomobject][ordered]@{
                command_id = $commandId
                command = $command
                exit_code = -1
                verdict = "blocked"
                stdout_ref = $stdoutRef
                stderr_ref = $stderrRef
                started_at_utc = $startedAt
                completed_at_utc = (& $script:GetUtcTimestamp)
            }
            RefusalReason = "Command '$commandId' could not be tokenized."
        }
    }

    $filePath = $tokens[0]
    $arguments = @()
    if ($tokens.Count -gt 1) {
        $arguments = @($tokens[1..($tokens.Count - 1)])
    }

    try {
        $process = Start-Process -FilePath $filePath -ArgumentList $arguments -WorkingDirectory (Get-RepoRoot) -NoNewWindow -Wait -PassThru -RedirectStandardOutput $stdoutPath -RedirectStandardError $stderrPath
        $exitCode = [int]$process.ExitCode
        $verdict = if ($exitCode -eq 0) { "passed" } else { "failed" }
        $refusalReason = $null
    }
    catch {
        & $script:WriteTextFile -Path $stdoutRef -Value ""
        & $script:WriteTextFile -Path $stderrRef -Value $_.Exception.Message
        $exitCode = -1
        $verdict = "blocked"
        $refusalReason = "Dependency failure while running command '$commandId': $($_.Exception.Message)"
    }

    return [pscustomobject][ordered]@{
        CommandResult = [pscustomobject][ordered]@{
            command_id = $commandId
            command = $command
            exit_code = $exitCode
            verdict = $verdict
            stdout_ref = $stdoutRef
            stderr_ref = $stderrRef
            started_at_utc = $startedAt
            completed_at_utc = (& $script:GetUtcTimestamp)
        }
        RefusalReason = $refusalReason
    }
}

function Get-InvocationOutputRoot {
    param(
        [Parameter(Mandatory = $true)]
        $Request
    )

    $rawLogOutput = @($Request.requested_outputs | Where-Object { [string]$_.artifact_type -eq "raw_log_root" } | Select-Object -First 1)
    if ($rawLogOutput.Count -gt 0) {
        return ([string]$rawLogOutput[0].ref).Replace("\", "/").TrimEnd("/")
    }

    $resultDirectory = Split-Path -Parent ([string]$Request.expected_result_ref)
    return (Join-Path $resultDirectory ("r13_008_raw_logs/" + [string]$Request.invocation_id)).Replace("\", "/")
}

function New-BlockedSkillResult {
    param(
        [Parameter(Mandatory = $true)]
        $Request,
        [Parameter(Mandatory = $true)]
        [string[]]$RefusalReasons,
        [Parameter(Mandatory = $true)]
        [string]$StartedAtUtc,
        [Parameter(Mandatory = $true)]
        [string]$RegistryPath
    )

    return [pscustomobject][ordered]@{
        contract_version = "v1"
        artifact_type = "r13_skill_invocation_result"
        result_id = (& $script:GetStableId -Prefix "r13sir" -Key "$($Request.invocation_id)|blocked|$([string]::Join('|', $RefusalReasons))")
        invocation_id = [string]$Request.invocation_id
        repository = $script:R13RepositoryName
        branch = [string]$Request.branch
        head = [string]$Request.head
        tree = [string]$Request.tree
        source_milestone = $script:R13Milestone
        source_task = $script:R13SourceTask
        skill_id = [string]$Request.skill_id
        skill_version = [string]$Request.skill_version
        invocation_mode = [string]$Request.invocation_mode
        execution_status = "blocked"
        command_results = @()
        output_artifacts = @()
        aggregate_verdict = "blocked"
        evidence_refs = @(
            (New-EvidenceRef -RefId "r13-skill-registry-contract" -Ref "contracts/skills/r13_skill_registry.contract.json" -EvidenceKind "contract" -AuthorityKind "repo_contract"),
            (New-EvidenceRef -RefId "r13-skill-invocation-result-contract" -Ref "contracts/skills/r13_skill_invocation_result.contract.json" -EvidenceKind "contract" -AuthorityKind "repo_contract"),
            (New-EvidenceRef -RefId "r13-skill-registry-module" -Ref "tools/R13SkillRegistry.psm1" -EvidenceKind "module"),
            (New-EvidenceRef -RefId "r13-skill-invocation-module" -Ref "tools/R13SkillInvocation.psm1" -EvidenceKind "module"),
            (New-EvidenceRef -RefId "r13-skill-registry" -Ref (& $script:ConvertToRepositoryRelativePath -PathValue $RegistryPath) -EvidenceKind "skill_registry")
        )
        refusal_reasons = @($RefusalReasons)
        started_at_utc = $StartedAtUtc
        completed_at_utc = (& $script:GetUtcTimestamp)
        non_claims = @(& $registryModule.ExportedCommands["Get-R13SkillRequiredNonClaims"])
    }
}

function Invoke-R13Skill {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RegistryPath,
        [Parameter(Mandatory = $true)]
        [string]$RequestPath,
        [bool]$StrictRepoIdentity = $true
    )

    $startedAt = & $script:GetUtcTimestamp
    $registry = & $script:GetJsonDocument -Path $RegistryPath -Label "R13 skill registry"
    & $script:TestRegistryObject -Registry $registry -SourceLabel "R13 skill registry" | Out-Null
    $request = & $script:GetJsonDocument -Path $RequestPath -Label "R13 skill invocation request"
    $requestValidation = Test-R13SkillInvocationRequestObject -Request $request -Registry $registry -SourceLabel "R13 skill invocation request"

    $refusalReasons = @()
    if ($StrictRepoIdentity) {
        try {
            $gitIdentity = & $script:GetGitIdentity
            if ($gitIdentity.Branch -ne $request.branch) {
                $refusalReasons += "Strict repo identity mismatch: current branch '$($gitIdentity.Branch)' does not match request branch '$($request.branch)'."
            }
            if ($gitIdentity.Head -ne $request.head) {
                $refusalReasons += "Strict repo identity mismatch: current head '$($gitIdentity.Head)' does not match request head '$($request.head)'."
            }
            if ($gitIdentity.Tree -ne $request.tree) {
                $refusalReasons += "Strict repo identity mismatch: current tree '$($gitIdentity.Tree)' does not match request tree '$($request.tree)'."
            }
        }
        catch {
            $refusalReasons += "Strict repo identity check failed: $($_.Exception.Message)"
        }
    }

    if ($refusalReasons.Count -gt 0) {
        return New-BlockedSkillResult -Request $request -RefusalReasons $refusalReasons -StartedAtUtc $startedAt -RegistryPath $RegistryPath
    }

    $outputRoot = Get-InvocationOutputRoot -Request $request
    New-Item -ItemType Directory -Path (& $script:ResolveRepositoryPath -PathValue $outputRoot) -Force | Out-Null

    $commandResults = @()
    $outputArtifacts = @()
    $outputRefs = @()
    $commandRefusals = @()
    $index = 1
    if ([string]$request.invocation_mode -ne "dry_run_only") {
        foreach ($commandObject in @($request.allowed_commands)) {
            $execution = Invoke-SkillCommand -CommandObject $commandObject -Index $index -OutputRoot $outputRoot
            $commandResults += $execution.CommandResult
            $outputArtifacts += [pscustomobject][ordered]@{
                artifact_id = "stdout-$($execution.CommandResult.command_id)"
                ref = [string]$execution.CommandResult.stdout_ref
                artifact_type = "raw_log"
                evidence_kind = "stdout_log"
                validation_status = "created"
            }
            $outputArtifacts += [pscustomobject][ordered]@{
                artifact_id = "stderr-$($execution.CommandResult.command_id)"
                ref = [string]$execution.CommandResult.stderr_ref
                artifact_type = "raw_log"
                evidence_kind = "stderr_log"
                validation_status = "created"
            }
            if (-not [string]::IsNullOrWhiteSpace($execution.RefusalReason)) {
                $commandRefusals += [string]$execution.RefusalReason
            }
            $index += 1
        }
    }

    $failedCommands = @($commandResults | Where-Object { [string]$_.verdict -eq "failed" })
    $blockedCommands = @($commandResults | Where-Object { [string]$_.verdict -eq "blocked" })
    if ($commandRefusals.Count -gt 0 -or $blockedCommands.Count -gt 0) {
        $executionStatus = "blocked"
        $aggregateVerdict = "blocked"
        $refusalReasons = @($commandRefusals)
        if ($refusalReasons.Count -eq 0) {
            $refusalReasons = @("One or more skill invocation commands were blocked before completion.")
        }
    }
    elseif ($failedCommands.Count -gt 0) {
        $executionStatus = "completed"
        $aggregateVerdict = "failed"
        $refusalReasons = @()
    }
    else {
        $executionStatus = "completed"
        $aggregateVerdict = "passed"
        $refusalReasons = @()
    }

    if ([string]$request.invocation_mode -eq "dry_run_only") {
        $executionStatus = "completed"
        $aggregateVerdict = "passed"
        $refusalReasons = @()
    }

    foreach ($inputRef in @($request.input_refs)) {
        $outputArtifacts += [pscustomobject][ordered]@{
            artifact_id = "input-$($inputRef.ref_id)"
            ref = ([string]$inputRef.ref).Replace("\", "/")
            artifact_type = "input_evidence"
            evidence_kind = [string]$inputRef.evidence_kind
            validation_status = "available"
        }
    }

    $resultRef = ([string]$request.expected_result_ref).Replace("\", "/")
    $outputArtifacts += [pscustomobject][ordered]@{
        artifact_id = "skill-invocation-result"
        ref = $resultRef
        artifact_type = "r13_skill_invocation_result"
        evidence_kind = "skill_invocation_result"
        validation_status = "created"
    }

    $evidenceRefs = @(
        (New-EvidenceRef -RefId "r13-skill-registry-contract" -Ref "contracts/skills/r13_skill_registry.contract.json" -EvidenceKind "contract" -AuthorityKind "repo_contract"),
        (New-EvidenceRef -RefId "r13-skill-invocation-request-contract" -Ref "contracts/skills/r13_skill_invocation_request.contract.json" -EvidenceKind "contract" -AuthorityKind "repo_contract"),
        (New-EvidenceRef -RefId "r13-skill-invocation-result-contract" -Ref "contracts/skills/r13_skill_invocation_result.contract.json" -EvidenceKind "contract" -AuthorityKind "repo_contract"),
        (New-EvidenceRef -RefId "r13-skill-registry-module" -Ref "tools/R13SkillRegistry.psm1" -EvidenceKind "module"),
        (New-EvidenceRef -RefId "r13-skill-invocation-module" -Ref "tools/R13SkillInvocation.psm1" -EvidenceKind "module"),
        (New-EvidenceRef -RefId "r13-skill-registry" -Ref (& $script:ConvertToRepositoryRelativePath -PathValue $RegistryPath) -EvidenceKind "skill_registry"),
        (New-EvidenceRef -RefId "r13-skill-invocation-request" -Ref (& $script:ConvertToRepositoryRelativePath -PathValue $RequestPath) -EvidenceKind "skill_invocation_request")
    )
    foreach ($inputRef in @($request.input_refs)) {
        $evidenceRefs += (New-EvidenceRef -RefId ("input-{0}" -f $inputRef.ref_id) -Ref ([string]$inputRef.ref) -EvidenceKind ([string]$inputRef.evidence_kind) -AuthorityKind ([string]$inputRef.authority_kind))
    }

    $result = [pscustomobject][ordered]@{
        contract_version = "v1"
        artifact_type = "r13_skill_invocation_result"
        result_id = (& $script:GetStableId -Prefix "r13sir" -Key "$($request.invocation_id)|$($request.skill_id)|$outputRoot")
        invocation_id = [string]$request.invocation_id
        repository = $script:R13RepositoryName
        branch = [string]$request.branch
        head = [string]$request.head
        tree = [string]$request.tree
        source_milestone = $script:R13Milestone
        source_task = $script:R13SourceTask
        skill_id = [string]$request.skill_id
        skill_version = [string]$request.skill_version
        invocation_mode = [string]$request.invocation_mode
        execution_status = $executionStatus
        command_results = @($commandResults)
        output_artifacts = @($outputArtifacts)
        aggregate_verdict = $aggregateVerdict
        evidence_refs = @($evidenceRefs)
        refusal_reasons = @($refusalReasons)
        started_at_utc = $startedAt
        completed_at_utc = (& $script:GetUtcTimestamp)
        non_claims = @(& $registryModule.ExportedCommands["Get-R13SkillRequiredNonClaims"])
    }

    return $result
}

Export-ModuleMember -Function Get-R13SkillInvocationRequestContract, Get-R13SkillInvocationResultContract, Test-R13SkillInvocationRequestObject, Test-R13SkillInvocationRequest, Test-R13SkillInvocationResultObject, Test-R13SkillInvocationResult, Invoke-R13Skill
