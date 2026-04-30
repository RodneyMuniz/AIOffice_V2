Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force
Import-Module (Join-Path $PSScriptRoot "ExternalRunnerContract.psm1") -Force

$script:R12Branch = "release/r12-external-api-runner-actionable-qa-control-room-pilot"
$script:GitObjectPattern = "^[a-f0-9]{40}$"
$script:TimestampPattern = "^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$"
$script:RequiredGitHubActionsNonClaims = @(
    "no external final-state replay",
    "no broad CI/product coverage",
    "no production runner",
    "no R12 value-gate delivery yet",
    "no solved Codex reliability"
)

function Get-RepositoryRoot {
    return $repoRoot
}

function Get-UtcTimestamp {
    return (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture)
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

function ConvertTo-JsonString {
    param(
        [Parameter(Mandatory = $true)]
        $Value
    )

    return ($Value | ConvertTo-Json -Depth 60)
}

function Write-JsonFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Value
    )

    $directory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    Set-Content -LiteralPath $Path -Value (ConvertTo-JsonString -Value $Value) -Encoding UTF8
    return $Path
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

function Assert-RequiredFields {
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

function Assert-RequiredNonClaims {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$NonClaims,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($requiredNonClaim in $script:RequiredGitHubActionsNonClaims) {
        if ($NonClaims -notcontains $requiredNonClaim) {
            throw "$Context non_claims must include '$requiredNonClaim'."
        }
    }
}

function Assert-TimestampString {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $timestamp = Assert-NonEmptyString -Value $Value -Context $Context
    if ($timestamp -notmatch $script:TimestampPattern) {
        throw "$Context does not match required timestamp pattern."
    }

    return $timestamp
}

function Assert-R12BranchHeadTree {
    param(
        [Parameter(Mandatory = $true)]
        $Packet,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $branch = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet -Name "branch" -Context $Context) -Context "$Context branch"
    if ($branch -ne $script:R12Branch) {
        throw "$Context branch must be '$script:R12Branch'."
    }

    $head = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet -Name "requested_head" -Context $Context) -Context "$Context requested_head"
    $tree = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet -Name "requested_tree" -Context $Context) -Context "$Context requested_tree"
    if ($head -notmatch $script:GitObjectPattern) {
        throw "$Context requested_head does not match required git object pattern."
    }
    if ($tree -notmatch $script:GitObjectPattern) {
        throw "$Context requested_tree does not match required git object pattern."
    }
}

function Invoke-LoggedNativeCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,
        [Parameter(Mandatory = $true)]
        [string]$LogRoot,
        [Parameter(Mandatory = $true)]
        [string]$LogName
    )

    New-Item -ItemType Directory -Path $LogRoot -Force | Out-Null
    $stdoutPath = Join-Path $LogRoot ("{0}.stdout.log" -f $LogName)
    $stderrPath = Join-Path $LogRoot ("{0}.stderr.log" -f $LogName)
    $exitCodePath = Join-Path $LogRoot ("{0}.exit_code.txt" -f $LogName)

    $output = & $Command @Arguments 2>&1
    $exitCode = $LASTEXITCODE
    $stdoutLines = @()
    $stderrLines = @()
    foreach ($line in @($output)) {
        if ($line -is [System.Management.Automation.ErrorRecord]) {
            $stderrLines += $line.ToString()
        }
        else {
            $stdoutLines += [string]$line
        }
    }

    Set-Content -LiteralPath $stdoutPath -Value $stdoutLines -Encoding UTF8
    Set-Content -LiteralPath $stderrPath -Value $stderrLines -Encoding UTF8
    Set-Content -LiteralPath $exitCodePath -Value ([string]$exitCode) -Encoding UTF8

    return [pscustomobject]@{
        Command = $Command
        Arguments = $Arguments
        ExitCode = $exitCode
        StdoutPath = $stdoutPath
        StderrPath = $stderrPath
        ExitCodePath = $exitCodePath
        Stdout = ($stdoutLines -join [Environment]::NewLine)
        Stderr = ($stderrLines -join [Environment]::NewLine)
    }
}

function New-ExternalRunnerGitHubActionsDependencyCheck {
    [CmdletBinding()]
    param(
        [string]$GhCommand = "gh",
        [string]$OutputRoot = (Join-Path (Get-RepositoryRoot) "state\external_runs\r12_external_runner")
    )

    $checkedAt = Get-UtcTimestamp
    $rawLogRoot = Join-Path $OutputRoot "raw_logs"
    $ghCommandInfo = Get-Command -Name $GhCommand -ErrorAction SilentlyContinue
    if ($null -eq $ghCommandInfo) {
        return [pscustomobject]@{
            contract_version = "v1"
            artifact_type = "external_runner_github_actions_dependency_check"
            mode = "check_dependencies"
            gh_available = $false
            auth_available = $false
            workflow_dispatch_permission = $false
            verdict = "fail_closed"
            dependency_reason = "gh CLI unavailable"
            checked_at_utc = $checkedAt
            raw_log_root = $rawLogRoot
            evidence_refs = @()
            non_claims = $script:RequiredGitHubActionsNonClaims
        }
    }

    $versionResult = Invoke-LoggedNativeCommand -Command $ghCommandInfo.Source -Arguments @("--version") -LogRoot $rawLogRoot -LogName "gh-version"
    if ($versionResult.ExitCode -ne 0) {
        return [pscustomobject]@{
            contract_version = "v1"
            artifact_type = "external_runner_github_actions_dependency_check"
            mode = "check_dependencies"
            gh_available = $false
            auth_available = $false
            workflow_dispatch_permission = $false
            verdict = "fail_closed"
            dependency_reason = "gh CLI unavailable or unusable"
            checked_at_utc = $checkedAt
            raw_log_root = $rawLogRoot
            evidence_refs = @($versionResult.StdoutPath, $versionResult.StderrPath, $versionResult.ExitCodePath)
            non_claims = $script:RequiredGitHubActionsNonClaims
        }
    }

    $authResult = Invoke-LoggedNativeCommand -Command $ghCommandInfo.Source -Arguments @("auth", "status", "--hostname", "github.com") -LogRoot $rawLogRoot -LogName "gh-auth-status"
    if ($authResult.ExitCode -ne 0) {
        return [pscustomobject]@{
            contract_version = "v1"
            artifact_type = "external_runner_github_actions_dependency_check"
            mode = "check_dependencies"
            gh_available = $true
            auth_available = $false
            workflow_dispatch_permission = $false
            verdict = "fail_closed"
            dependency_reason = "gh auth missing or invalid"
            checked_at_utc = $checkedAt
            raw_log_root = $rawLogRoot
            evidence_refs = @($versionResult.StdoutPath, $versionResult.StderrPath, $versionResult.ExitCodePath, $authResult.StdoutPath, $authResult.StderrPath, $authResult.ExitCodePath)
            non_claims = $script:RequiredGitHubActionsNonClaims
        }
    }

    return [pscustomobject]@{
        contract_version = "v1"
        artifact_type = "external_runner_github_actions_dependency_check"
        mode = "check_dependencies"
        gh_available = $true
        auth_available = $true
        workflow_dispatch_permission = $true
        verdict = "passed"
        dependency_reason = ""
        checked_at_utc = $checkedAt
        raw_log_root = $rawLogRoot
        evidence_refs = @($versionResult.StdoutPath, $versionResult.StderrPath, $versionResult.ExitCodePath, $authResult.StdoutPath, $authResult.StderrPath, $authResult.ExitCodePath)
        non_claims = $script:RequiredGitHubActionsNonClaims
    }
}

function Resolve-ExternalRunnerGitHubActionsRunSelection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$CandidateRuns,
        [Parameter(Mandatory = $true)]
        [string]$Branch,
        [Parameter(Mandatory = $true)]
        [string]$Head,
        [Parameter(Mandatory = $true)]
        [string]$WorkflowName
    )

    $matchingRuns = @($CandidateRuns | Where-Object {
            $_.head_branch -eq $Branch -and $_.head_sha -eq $Head -and $_.workflow_name -eq $WorkflowName
        })

    if ($matchingRuns.Count -eq 0) {
        throw "GitHub Actions run selection failed closed because no candidate run matched branch/head/workflow."
    }
    if ($matchingRuns.Count -gt 1) {
        throw "GitHub Actions run selection failed closed because multiple candidate runs are ambiguous for branch/head/workflow/time."
    }

    Write-Output -NoEnumerate $matchingRuns[0]
}

function New-ExternalRunnerGitHubActionsManualDispatchInstructions {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $RequestPacket,
        [string]$RequestRef = ""
    )

    $requestValidation = Test-ExternalRunnerRequestObject -Request $RequestPacket -SourceLabel "Manual dispatch request packet"
    return [pscustomobject]@{
        contract_version = "v1"
        artifact_type = "external_runner_github_actions_manual_dispatch_instructions"
        mode = "prepare_manual_dispatch_instructions"
        dispatch_mode = "manual_dispatch"
        api_controlled = $false
        manual = $true
        repository = "RodneyMuniz/AIOffice_V2"
        branch = $requestValidation.Branch
        requested_head = $requestValidation.RequestedHead
        requested_tree = $requestValidation.RequestedTree
        workflow_ref = $RequestPacket.workflow_ref
        workflow_name = $RequestPacket.workflow_name
        request_ref = $RequestRef
        request_packet = $RequestPacket
        instructions = @(
            "Open the GitHub Actions workflow manually.",
            "Use workflow_dispatch with the exact branch, expected_head, expected_tree, and replay_scope values from request_packet.",
            "Record the resulting run_id, run_url, and artifact identity before making any external-runner claim."
        )
        evidence_refs = @($RequestRef)
        non_claims = $script:RequiredGitHubActionsNonClaims + @("manual dispatch path is not API-controlled")
    }
}

function Test-DependencyPacket {
    param(
        [Parameter(Mandatory = $true)]
        $Packet,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-RequiredFields -Object $Packet -FieldNames @("contract_version", "artifact_type", "mode", "gh_available", "auth_available", "workflow_dispatch_permission", "verdict", "dependency_reason", "checked_at_utc", "evidence_refs", "non_claims") -Context $Context
    if ($Packet.artifact_type -ne "external_runner_github_actions_dependency_check") {
        throw "$Context artifact_type must be external_runner_github_actions_dependency_check."
    }
    if ($Packet.mode -ne "check_dependencies") {
        throw "$Context mode must be check_dependencies."
    }
    $ghAvailable = Assert-BooleanValue -Value $Packet.gh_available -Context "$Context gh_available"
    $authAvailable = Assert-BooleanValue -Value $Packet.auth_available -Context "$Context auth_available"
    $workflowDispatchPermission = Assert-BooleanValue -Value $Packet.workflow_dispatch_permission -Context "$Context workflow_dispatch_permission"
    $verdict = Assert-NonEmptyString -Value $Packet.verdict -Context "$Context verdict"
    if (@("passed", "fail_closed") -notcontains $verdict) {
        throw "$Context verdict must be passed or fail_closed."
    }
    $dependencyReason = Assert-StringValue -Value $Packet.dependency_reason -Context "$Context dependency_reason"
    if ($verdict -eq "passed") {
        if (-not $ghAvailable -or -not $authAvailable -or -not $workflowDispatchPermission) {
            throw "$Context passed dependency check requires gh, auth, and workflow dispatch permission."
        }
    }
    else {
        Assert-NonEmptyString -Value $dependencyReason -Context "$Context dependency_reason" | Out-Null
        if (-not $ghAvailable -and $dependencyReason -notmatch "(?i)gh CLI") {
            throw "$Context missing gh CLI must fail closed with exact dependency reason."
        }
        if ($ghAvailable -and -not $authAvailable -and $dependencyReason -notmatch "(?i)auth") {
            throw "$Context missing auth must fail closed with exact dependency reason."
        }
        if ($ghAvailable -and $authAvailable -and -not $workflowDispatchPermission -and $dependencyReason -notmatch "(?i)workflow dispatch|permission") {
            throw "$Context missing workflow dispatch permission must fail closed with exact dependency reason."
        }
    }
    Assert-TimestampString -Value $Packet.checked_at_utc -Context "$Context checked_at_utc"
    $nonClaims = Assert-StringArray -Value $Packet.non_claims -Context "$Context non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $Context

    return [pscustomobject]@{
        Mode = $Packet.mode
        Verdict = $verdict
        GhAvailable = $ghAvailable
        AuthAvailable = $authAvailable
        WorkflowDispatchPermission = $workflowDispatchPermission
        DependencyReason = $dependencyReason
    }
}

function Test-DispatchPacket {
    param(
        [Parameter(Mandatory = $true)]
        $Packet,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-RequiredFields -Object $Packet -FieldNames @("contract_version", "artifact_type", "mode", "request_ref", "request_packet", "api_controlled", "dispatch_mode", "workflow_ref", "workflow_name", "branch", "requested_head", "requested_tree", "run_id", "run_url", "candidate_runs", "status", "evidence_refs", "non_claims") -Context $Context
    if ($Packet.artifact_type -ne "external_runner_github_actions_dispatch_result") {
        throw "$Context artifact_type must be external_runner_github_actions_dispatch_result."
    }
    if ($Packet.mode -ne "dispatch") {
        throw "$Context mode must be dispatch."
    }
    Assert-R12BranchHeadTree -Packet $Packet -Context $Context
    $apiControlled = Assert-BooleanValue -Value $Packet.api_controlled -Context "$Context api_controlled"
    $dispatchMode = Assert-NonEmptyString -Value $Packet.dispatch_mode -Context "$Context dispatch_mode"
    if ($apiControlled -and $dispatchMode -ne "api_dispatch") {
        throw "$Context API-controlled dispatch result must use dispatch_mode api_dispatch."
    }
    $candidateRuns = Assert-ObjectArray -Value $Packet.candidate_runs -Context "$Context candidate_runs" -AllowEmpty
    $runId = Assert-StringValue -Value $Packet.run_id -Context "$Context run_id"
    $runUrl = Assert-StringValue -Value $Packet.run_url -Context "$Context run_url"
    if ($candidateRuns.Count -gt 1 -and [string]::IsNullOrWhiteSpace($runId)) {
        throw "$Context ambiguous run selection failed closed because multiple candidate runs exist and no unique run id was selected."
    }
    if ($apiControlled) {
        Assert-NonEmptyString -Value $runId -Context "$Context run_id" | Out-Null
        Assert-NonEmptyString -Value $runUrl -Context "$Context run_url" | Out-Null
    }
    $nonClaims = Assert-StringArray -Value $Packet.non_claims -Context "$Context non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $Context
    Test-ExternalRunnerRequestObject -Request $Packet.request_packet -SourceLabel "$Context request_packet" | Out-Null

    return [pscustomobject]@{
        Mode = $Packet.mode
        DispatchMode = $dispatchMode
        ApiControlled = $apiControlled
        RunId = $runId
        CandidateRunCount = $candidateRuns.Count
    }
}

function Test-ManualDispatchPacket {
    param(
        [Parameter(Mandatory = $true)]
        $Packet,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-RequiredFields -Object $Packet -FieldNames @("contract_version", "artifact_type", "mode", "dispatch_mode", "api_controlled", "manual", "repository", "branch", "requested_head", "requested_tree", "workflow_ref", "workflow_name", "request_packet", "instructions", "evidence_refs", "non_claims") -Context $Context
    if ($Packet.artifact_type -ne "external_runner_github_actions_manual_dispatch_instructions") {
        throw "$Context artifact_type must be external_runner_github_actions_manual_dispatch_instructions."
    }
    if ($Packet.mode -ne "prepare_manual_dispatch_instructions") {
        throw "$Context mode must be prepare_manual_dispatch_instructions."
    }
    Assert-R12BranchHeadTree -Packet $Packet -Context $Context
    if ($Packet.dispatch_mode -ne "manual_dispatch") {
        throw "$Context manual dispatch path must be labeled manual_dispatch."
    }
    if (Assert-BooleanValue -Value $Packet.api_controlled -Context "$Context api_controlled") {
        throw "$Context manual dispatch path must not be described as API-controlled."
    }
    if (-not (Assert-BooleanValue -Value $Packet.manual -Context "$Context manual")) {
        throw "$Context manual dispatch path must be marked manual."
    }
    Assert-StringArray -Value $Packet.instructions -Context "$Context instructions" | Out-Null
    $nonClaims = Assert-StringArray -Value $Packet.non_claims -Context "$Context non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $Context
    if ($nonClaims -notcontains "manual dispatch path is not API-controlled") {
        throw "$Context non_claims must include 'manual dispatch path is not API-controlled'."
    }
    Test-ExternalRunnerRequestObject -Request $Packet.request_packet -SourceLabel "$Context request_packet" | Out-Null

    return [pscustomobject]@{
        Mode = $Packet.mode
        DispatchMode = $Packet.dispatch_mode
        ApiControlled = $false
        Manual = $true
        InstructionCount = @($Packet.instructions).Count
    }
}

function Test-CapturePacket {
    param(
        [Parameter(Mandatory = $true)]
        $Packet,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-RequiredFields -Object $Packet -FieldNames @("contract_version", "artifact_type", "mode", "request_ref", "result_packet", "raw_command_log_root", "capture_status", "evidence_refs", "non_claims") -Context $Context
    if ($Packet.artifact_type -ne "external_runner_github_actions_capture_result") {
        throw "$Context artifact_type must be external_runner_github_actions_capture_result."
    }
    if ($Packet.mode -ne "capture") {
        throw "$Context mode must be capture."
    }
    $captureStatus = Assert-NonEmptyString -Value $Packet.capture_status -Context "$Context capture_status"
    if (@("captured", "failed_closed") -notcontains $captureStatus) {
        throw "$Context capture_status must be captured or failed_closed."
    }
    Assert-NonEmptyString -Value $Packet.raw_command_log_root -Context "$Context raw_command_log_root" | Out-Null
    $resultValidation = Test-ExternalRunnerResultObject -Result $Packet.result_packet -SourceLabel "$Context result_packet"
    $nonClaims = Assert-StringArray -Value $Packet.non_claims -Context "$Context non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $Context

    return [pscustomobject]@{
        Mode = $Packet.mode
        CaptureStatus = $captureStatus
        ResultId = $resultValidation.ResultId
        RunId = $resultValidation.RunId
        SuccessfulExternalEvidenceShape = $resultValidation.SuccessfulExternalEvidenceShape
    }
}

function Test-SummaryPacket {
    param(
        [Parameter(Mandatory = $true)]
        $Packet,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-RequiredFields -Object $Packet -FieldNames @("contract_version", "artifact_type", "mode", "run_id", "run_url", "status", "conclusion", "evidence_refs", "non_claims") -Context $Context
    if ($Packet.artifact_type -ne "external_runner_github_actions_run_summary") {
        throw "$Context artifact_type must be external_runner_github_actions_run_summary."
    }
    if ($Packet.mode -ne "summarize") {
        throw "$Context mode must be summarize."
    }
    $nonClaims = Assert-StringArray -Value $Packet.non_claims -Context "$Context non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $Context
    return [pscustomobject]@{
        Mode = $Packet.mode
        RunId = $Packet.run_id
        Status = $Packet.status
        Conclusion = $Packet.conclusion
    }
}

function Test-ExternalRunnerGitHubActionsPacket {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PacketPath
    )

    $packet = Get-JsonDocument -Path $PacketPath -Label "External runner GitHub Actions packet"
    $artifactType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $packet -Name "artifact_type" -Context "External runner GitHub Actions packet") -Context "External runner GitHub Actions packet artifact_type"

    switch ($artifactType) {
        "external_runner_github_actions_dependency_check" {
            return Test-DependencyPacket -Packet $packet -Context "External runner GitHub Actions dependency check"
        }
        "external_runner_github_actions_dispatch_result" {
            return Test-DispatchPacket -Packet $packet -Context "External runner GitHub Actions dispatch result"
        }
        "external_runner_github_actions_manual_dispatch_instructions" {
            return Test-ManualDispatchPacket -Packet $packet -Context "External runner GitHub Actions manual dispatch instructions"
        }
        "external_runner_github_actions_capture_result" {
            return Test-CapturePacket -Packet $packet -Context "External runner GitHub Actions capture result"
        }
        "external_runner_github_actions_run_summary" {
            return Test-SummaryPacket -Packet $packet -Context "External runner GitHub Actions run summary"
        }
        default {
            throw "External runner GitHub Actions packet artifact_type '$artifactType' is not supported."
        }
    }
}

function Invoke-ExternalRunnerGitHubActions {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("check_dependencies", "dispatch", "watch", "capture", "summarize", "prepare_manual_dispatch_instructions")]
        [string]$Mode,
        [string]$RequestPath,
        [string]$OutputRoot = (Join-Path (Get-RepositoryRoot) "state\external_runs\r12_external_runner"),
        [string]$MockInputPath,
        [string]$OutputPath,
        [string]$GhCommand = "gh"
    )

    if (-not [string]::IsNullOrWhiteSpace($MockInputPath)) {
        $validation = Test-ExternalRunnerGitHubActionsPacket -PacketPath $MockInputPath
        if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
            $packet = Get-JsonDocument -Path $MockInputPath -Label "Mock GitHub Actions packet"
            Write-JsonFile -Path $OutputPath -Value $packet | Out-Null
        }
        return $validation
    }

    if ($Mode -eq "check_dependencies") {
        $packet = New-ExternalRunnerGitHubActionsDependencyCheck -GhCommand $GhCommand -OutputRoot $OutputRoot
        if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
            Write-JsonFile -Path $OutputPath -Value $packet | Out-Null
        }
        return Test-DependencyPacket -Packet $packet -Context "External runner GitHub Actions dependency check"
    }

    if ($Mode -eq "prepare_manual_dispatch_instructions") {
        if ([string]::IsNullOrWhiteSpace($RequestPath)) {
            throw "RequestPath is required to prepare manual dispatch instructions."
        }
        $request = Get-JsonDocument -Path $RequestPath -Label "External runner request"
        $packet = New-ExternalRunnerGitHubActionsManualDispatchInstructions -RequestPacket $request -RequestRef $RequestPath
        if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
            Write-JsonFile -Path $OutputPath -Value $packet | Out-Null
        }
        return Test-ManualDispatchPacket -Packet $packet -Context "External runner GitHub Actions manual dispatch instructions"
    }

    $dependency = New-ExternalRunnerGitHubActionsDependencyCheck -GhCommand $GhCommand -OutputRoot $OutputRoot
    $dependencyValidation = Test-DependencyPacket -Packet $dependency -Context "External runner GitHub Actions dependency check"
    if ($dependencyValidation.Verdict -ne "passed") {
        throw "GitHub Actions external runner $Mode failed closed: $($dependencyValidation.DependencyReason)"
    }

    if ($Mode -eq "dispatch") {
        if ([string]::IsNullOrWhiteSpace($RequestPath)) {
            throw "RequestPath is required for dispatch."
        }
        $request = Get-JsonDocument -Path $RequestPath -Label "External runner request"
        $requestValidation = Test-ExternalRunnerRequestObject -Request $request -SourceLabel "Dispatch request packet"
        $rawLogRoot = Join-Path $OutputRoot "raw_logs"
        $gh = (Get-Command -Name $GhCommand -ErrorAction Stop).Source
        $dispatchResult = Invoke-LoggedNativeCommand -Command $gh -Arguments @("workflow", "run", $request.workflow_ref, "--ref", $request.branch, "-f", ("branch={0}" -f $request.branch), "-f", ("expected_head={0}" -f $request.requested_head), "-f", ("expected_tree={0}" -f $request.requested_tree), "-f", "replay_scope=foundation") -LogRoot $rawLogRoot -LogName "gh-workflow-run"
        if ($dispatchResult.ExitCode -ne 0) {
            throw "GitHub Actions workflow dispatch failed closed; see raw command logs under '$rawLogRoot'."
        }

        $listResult = Invoke-LoggedNativeCommand -Command $gh -Arguments @("run", "list", "--workflow", $request.workflow_ref, "--branch", $request.branch, "--commit", $request.requested_head, "--json", "databaseId,url,headSha,headBranch,status,conclusion,workflowName,createdAt", "--limit", "20") -LogRoot $rawLogRoot -LogName "gh-run-list"
        if ($listResult.ExitCode -ne 0) {
            throw "GitHub Actions run id discovery failed closed; see raw command logs under '$rawLogRoot'."
        }
        $candidateRuns = @($listResult.Stdout | ConvertFrom-Json)
        $normalizedRuns = @($candidateRuns | ForEach-Object {
                [pscustomobject]@{
                    run_id = [string]$_.databaseId
                    run_url = [string]$_.url
                    head_sha = [string]$_.headSha
                    head_branch = [string]$_.headBranch
                    workflow_name = [string]$_.workflowName
                    status = [string]$_.status
                    conclusion = [string]$_.conclusion
                    created_at_utc = [string]$_.createdAt
                }
            })
        $selectedRun = Resolve-ExternalRunnerGitHubActionsRunSelection -CandidateRuns $normalizedRuns -Branch $request.branch -Head $request.requested_head -WorkflowName $request.workflow_name
        $packet = [pscustomobject]@{
            contract_version = "v1"
            artifact_type = "external_runner_github_actions_dispatch_result"
            mode = "dispatch"
            request_ref = $RequestPath
            request_packet = $request
            api_controlled = $true
            dispatch_mode = "api_dispatch"
            workflow_ref = $request.workflow_ref
            workflow_name = $request.workflow_name
            branch = $request.branch
            requested_head = $requestValidation.RequestedHead
            requested_tree = $requestValidation.RequestedTree
            run_id = $selectedRun.run_id
            run_url = $selectedRun.run_url
            candidate_runs = $normalizedRuns
            status = "dispatched"
            evidence_refs = @($dispatchResult.StdoutPath, $dispatchResult.StderrPath, $dispatchResult.ExitCodePath, $listResult.StdoutPath, $listResult.StderrPath, $listResult.ExitCodePath)
            non_claims = $script:RequiredGitHubActionsNonClaims
        }
        if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
            Write-JsonFile -Path $OutputPath -Value $packet | Out-Null
        }
        return Test-DispatchPacket -Packet $packet -Context "External runner GitHub Actions dispatch result"
    }

    throw "Mode '$Mode' requires MockInputPath or a later live capture/watch implementation path with a concrete run id."
}

Export-ModuleMember -Function New-ExternalRunnerGitHubActionsDependencyCheck, New-ExternalRunnerGitHubActionsManualDispatchInstructions, Resolve-ExternalRunnerGitHubActionsRunSelection, Test-ExternalRunnerGitHubActionsPacket, Invoke-ExternalRunnerGitHubActions
