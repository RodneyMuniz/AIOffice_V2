$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R13CustomRunner.psm1") -Force -PassThru
$testRequest = $module.ExportedCommands["Test-R13CustomRunnerRequest"]
$testResult = $module.ExportedCommands["Test-R13CustomRunnerResult"]

$validRoot = Join-Path $repoRoot "state\fixtures\valid\runner"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\runner\r13_custom_runner"
$cliPath = Join-Path $repoRoot "tools\invoke_r13_custom_runner.ps1"
$validateRequestPath = Join-Path $repoRoot "tools\validate_r13_custom_runner_request.ps1"
$validateResultPath = Join-Path $repoRoot "tools\validate_r13_custom_runner_result.ps1"
$canonicalInvalidRoot = Join-Path $repoRoot "state\fixtures\invalid\actionable_qa\r13_detector_inputs"
$tempRoot = Join-Path $repoRoot ("state\runner\_test_runs\" + [guid]::NewGuid().ToString("N"))

$validPassed = 0
$invalidRejected = 0
$failures = @()

function Read-JsonObject {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json)
}

function Write-JsonFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Value
    )

    $parentPath = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($parentPath)) {
        New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    }
    $json = [string]::Join("`n", @($Value | ConvertTo-Json -Depth 100))
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $json.TrimEnd() + "`n", $utf8NoBom)
}

function ConvertTo-RepoRef {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $full = [System.IO.Path]::GetFullPath($Path)
    return $full.Substring($repoRoot.Length + 1).Replace("\", "/")
}

function Invoke-PowerShellFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        [string[]]$Arguments = @()
    )

    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $FilePath @Arguments 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }

    return [pscustomobject]@{
        ExitCode = $exitCode
        Output = @($output | ForEach-Object { [string]$_ })
    }
}

function Invoke-ExpectedRefusal {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Action
    )

    try {
        & $Action
        $script:failures += ("FAIL invalid: {0} was accepted unexpectedly." -f $Label)
    }
    catch {
        Write-Output ("PASS invalid: {0} -> {1}" -f $Label, $_.Exception.Message)
        $script:invalidRejected += 1
    }
}

function Get-GitLine {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $output = & git -C $repoRoot @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Arguments -join ' ') failed."
    }
    return ([string]@($output)[0]).Trim()
}

function Get-CanonicalFixtureHashes {
    $hashes = @{}
    foreach ($file in @(Get-ChildItem -LiteralPath $canonicalInvalidRoot -File | Sort-Object FullName)) {
        $relative = $file.FullName.Substring($repoRoot.Length + 1).Replace("\", "/")
        $hashes[$relative] = (Get-FileHash -Algorithm SHA256 -LiteralPath $file.FullName).Hash
    }

    return $hashes
}

function Assert-CanonicalHashesUnchanged {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Before,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $after = Get-CanonicalFixtureHashes
    foreach ($key in $Before.Keys) {
        if (-not $after.ContainsKey($key) -or $after[$key] -ne $Before[$key]) {
            $script:failures += ("FAIL canonical preservation: {0} changed during {1}." -f $key, $Context)
        }
    }
}

function New-TestRunnerRequest {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RequestPath,
        [Parameter(Mandatory = $true)]
        [string]$ResultPath,
        [Parameter(Mandatory = $true)]
        [string]$OutputRoot,
        [string]$Head = (Get-GitLine -Arguments @("rev-parse", "HEAD")),
        [string]$Tree = (Get-GitLine -Arguments @("rev-parse", "HEAD^{tree}")),
        [object[]]$AllowedCommands = $null
    )

    $requestRef = ConvertTo-RepoRef -Path $RequestPath
    $resultRef = ConvertTo-RepoRef -Path $ResultPath
    $outputRootRef = ConvertTo-RepoRef -Path $OutputRoot
    if ($null -eq $AllowedCommands) {
        $AllowedCommands = @(
            [pscustomobject][ordered]@{
                command_id = "validate-r13-006-fix-execution"
                command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r13_fix_execution_result.ps1 -ResultPath state\cycles\r13_qa_cycle_demo\fix_execution_result.json"
            },
            [pscustomobject][ordered]@{
                command_id = "validate-r13-006-comparison"
                command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r13_qa_before_after_comparison.ps1 -ComparisonPath state\cycles\r13_qa_cycle_demo\before_after_comparison.json"
            },
            [pscustomobject][ordered]@{
                command_id = "validate-r13-006-cycle"
                command = "powershell -NoProfile -ExecutionPolicy Bypass -File tools\validate_r13_qa_failure_fix_cycle.ps1 -CyclePath state\cycles\r13_qa_cycle_demo\qa_failure_fix_cycle.json"
            }
        )
    }

    $request = [pscustomobject][ordered]@{
        contract_version = "v1"
        artifact_type = "r13_custom_runner_request"
        request_id = "r13crq-test-" + [guid]::NewGuid().ToString("N").Substring(0, 12)
        repository = "AIOffice_V2"
        branch = "release/r13-api-first-qa-pipeline-and-operator-control-room-product-slice"
        head = $Head
        tree = $Tree
        source_milestone = "R13 API-First QA Pipeline and Operator Control-Room Product Slice"
        source_task = "R13-007"
        requested_operation = "run_bounded_validation_commands"
        execution_profile = [pscustomobject][ordered]@{
            profile_id = "r13-007-local-bounded-validation"
            runner_kind = "local_custom_runner_cli"
            mutation_allowed = $false
            destructive_commands_allowed = $false
            strict_repo_identity = $true
        }
        input_refs = @(
            [pscustomobject][ordered]@{
                ref_id = "r13-006-fix-execution"
                ref = "state/cycles/r13_qa_cycle_demo/fix_execution_result.json"
                evidence_kind = "r13_006_fix_execution_result"
                authority_kind = "repo_evidence"
                scope = "repo"
            },
            [pscustomobject][ordered]@{
                ref_id = "r13-006-comparison"
                ref = "state/cycles/r13_qa_cycle_demo/before_after_comparison.json"
                evidence_kind = "r13_006_before_after_comparison"
                authority_kind = "repo_evidence"
                scope = "repo"
            },
            [pscustomobject][ordered]@{
                ref_id = "r13-006-cycle"
                ref = "state/cycles/r13_qa_cycle_demo/qa_failure_fix_cycle.json"
                evidence_kind = "r13_006_cycle_artifact"
                authority_kind = "repo_evidence"
                scope = "repo"
            }
        )
        allowed_paths = @(
            "state/cycles/r13_qa_cycle_demo/fix_execution_result.json",
            "state/cycles/r13_qa_cycle_demo/before_after_comparison.json",
            "state/cycles/r13_qa_cycle_demo/qa_failure_fix_cycle.json",
            "tools/validate_r13_fix_execution_result.ps1",
            "tools/validate_r13_qa_before_after_comparison.ps1",
            "tools/validate_r13_qa_failure_fix_cycle.ps1",
            $outputRootRef,
            $resultRef
        )
        allowed_commands = @($AllowedCommands)
        output_root = $outputRootRef
        expected_result_ref = $resultRef
        operator_approval = [pscustomobject][ordered]@{
            approval_status = "approved_for_local_non_mutating_validation"
            approved_by = "operator"
            approved_at_utc = "2026-05-01T13:00:00Z"
            approval_scope = "R13-007 local non-mutating validation of existing R13-006 evidence only"
        }
        evidence_refs = @(
            [pscustomobject][ordered]@{
                ref_id = "request-contract"
                ref = "contracts/runner/r13_custom_runner_request.contract.json"
                evidence_kind = "contract"
                authority_kind = "repo_contract"
                scope = "repo"
            },
            [pscustomobject][ordered]@{
                ref_id = "runner-module"
                ref = "tools/R13CustomRunner.psm1"
                evidence_kind = "module"
                authority_kind = "repo_tooling"
                scope = "repo"
            },
            [pscustomobject][ordered]@{
                ref_id = "runner-cli"
                ref = "tools/invoke_r13_custom_runner.ps1"
                evidence_kind = "cli"
                authority_kind = "repo_tooling"
                scope = "repo"
            },
            [pscustomobject][ordered]@{
                ref_id = "r13-006-cycle"
                ref = "state/cycles/r13_qa_cycle_demo/qa_failure_fix_cycle.json"
                evidence_kind = "r13_006_cycle_artifact"
                authority_kind = "repo_evidence"
                scope = "repo"
            }
        )
        refusal_reasons = @()
        created_at_utc = "2026-05-01T13:00:00Z"
        non_claims = @(
            "R13-007 adds a local API-shaped/custom-runner foundation only",
            "no production API server delivered by R13-007",
            "no mutation commands are authorized or executed by R13-007 evidence",
            "no external replay has occurred",
            "no skill invocation has occurred",
            "no final QA signoff has occurred",
            "no R13 hard value gate delivered by R13-007",
            "no API/custom-runner bypass gate fully delivered by R13-007",
            "no current operator control-room gate delivered by R13-007",
            "no operator demo gate delivered by R13-007",
            "no R14 or successor opening"
        )
    }

    Write-JsonFile -Path $RequestPath -Value $request
    return [pscustomobject]@{
        Request = $request
        RequestPath = $RequestPath
        RequestRef = $requestRef
        ResultPath = $ResultPath
        ResultRef = $resultRef
        OutputRoot = $OutputRoot
        OutputRootRef = $outputRootRef
    }
}

try {
    $requestFixturePath = Join-Path $validRoot "r13_custom_runner_request.valid.json"
    $requestValidation = & $testRequest -RequestPath $requestFixturePath
    if ($requestValidation.CommandCount -lt 1) {
        $failures += "FAIL valid: runner request fixture did not expose commands."
    }
    else {
        Write-Output ("PASS valid runner request fixture: {0}" -f $requestValidation.RequestId)
        $validPassed += 1
    }

    $passedResultFixturePath = Join-Path $validRoot "r13_custom_runner_result.passed.valid.json"
    $passedResultValidation = & $testResult -ResultPath $passedResultFixturePath
    if ($passedResultValidation.AggregateVerdict -ne "passed") {
        $failures += "FAIL valid: passed runner result fixture did not validate as passed."
    }
    else {
        Write-Output ("PASS valid passed runner result fixture: {0}" -f $passedResultValidation.ResultId)
        $validPassed += 1
    }

    $blockedResultFixturePath = Join-Path $validRoot "r13_custom_runner_result.blocked.valid.json"
    $blockedResultValidation = & $testResult -ResultPath $blockedResultFixturePath
    if ($blockedResultValidation.AggregateVerdict -ne "blocked") {
        $failures += "FAIL valid: blocked runner result fixture did not validate as blocked."
    }
    else {
        Write-Output ("PASS valid blocked runner result fixture: {0}" -f $blockedResultValidation.ResultId)
        $validPassed += 1
    }

    $expectedInvalidFixtures = @(
        "mutation_command_requested.invalid.json",
        "git_push_command_requested.invalid.json",
        "git_clean_command_requested.invalid.json",
        "outside_repo_path.invalid.json",
        "repo_root_output_without_authorization.invalid.json",
        "wrong_branch.invalid.json",
        "missing_input_ref.invalid.json",
        "missing_allowed_commands.invalid.json",
        "missing_operator_approval.invalid.json",
        "external_replay_claimed.invalid.json",
        "skill_invocation_claimed.invalid.json",
        "final_signoff_claimed.invalid.json",
        "hard_gate_claimed.invalid.json",
        "missing_non_claims.invalid.json",
        "r14_successor_opened.invalid.json"
    )
    foreach ($fixtureName in $expectedInvalidFixtures) {
        $path = Join-Path $invalidRoot $fixtureName
        if (-not (Test-Path -LiteralPath $path)) {
            $failures += "FAIL fixture: missing invalid fixture '$fixtureName'."
            continue
        }
        Invoke-ExpectedRefusal -Label $fixtureName -Action {
            & $testRequest -RequestPath $path | Out-Null
        }
    }

    foreach ($unsafeCommand in @(
            @{ Label = "git reset"; Command = "git reset --hard HEAD" },
            @{ Label = "git rm"; Command = "git rm README.md" },
            @{ Label = "Remove-Item"; Command = "powershell -NoProfile -ExecutionPolicy Bypass -Command Remove-Item README.md" }
        )) {
        $unsafeRequestPath = Join-Path $tempRoot ("unsafe_{0}.json" -f ($unsafeCommand.Label -replace '\s+', '_'))
        $unsafeResultPath = Join-Path $tempRoot ("unsafe_{0}_result.json" -f ($unsafeCommand.Label -replace '\s+', '_'))
        $unsafeOutputRoot = Join-Path $tempRoot ("unsafe_{0}_logs" -f ($unsafeCommand.Label -replace '\s+', '_'))
        New-TestRunnerRequest -RequestPath $unsafeRequestPath -ResultPath $unsafeResultPath -OutputRoot $unsafeOutputRoot -AllowedCommands @([pscustomobject][ordered]@{ command_id = "unsafe"; command = $unsafeCommand.Command }) | Out-Null
        Invoke-ExpectedRefusal -Label ("unsafe command " + $unsafeCommand.Label) -Action {
            & $testRequest -RequestPath $unsafeRequestPath | Out-Null
        }
    }

    $outsideRequestPath = Join-Path $tempRoot "outside_path_request.json"
    $outsideResultPath = Join-Path $tempRoot "outside_path_result.json"
    $outsideOutputRoot = Join-Path $tempRoot "outside_path_logs"
    $outsideRequest = New-TestRunnerRequest -RequestPath $outsideRequestPath -ResultPath $outsideResultPath -OutputRoot $outsideOutputRoot
    $outsideObject = Read-JsonObject -Path $outsideRequest.RequestPath
    $outsideObject.allowed_paths = @("..\outside.txt")
    Write-JsonFile -Path $outsideRequest.RequestPath -Value $outsideObject
    Invoke-ExpectedRefusal -Label "outside repo path" -Action {
        & $testRequest -RequestPath $outsideRequest.RequestPath | Out-Null
    }

    $wrongIdentityRequestPath = Join-Path $tempRoot "wrong_identity_request.json"
    $wrongIdentityResultPath = Join-Path $tempRoot "wrong_identity_result.json"
    $wrongIdentityOutputRoot = Join-Path $tempRoot "wrong_identity_logs"
    $wrongIdentity = New-TestRunnerRequest -RequestPath $wrongIdentityRequestPath -ResultPath $wrongIdentityResultPath -OutputRoot $wrongIdentityOutputRoot -Head "0000000000000000000000000000000000000000"
    $wrongIdentityCli = Invoke-PowerShellFile -FilePath $cliPath -Arguments @("-RequestPath", $wrongIdentity.RequestPath, "-OutputPath", $wrongIdentity.ResultPath)
    if ($wrongIdentityCli.ExitCode -eq 0) {
        $failures += "FAIL strict identity: wrong head/tree request exited 0."
    }
    else {
        $wrongIdentityResult = Read-JsonObject -Path $wrongIdentity.ResultPath
        if ($wrongIdentityResult.aggregate_verdict -ne "blocked") {
            $failures += "FAIL strict identity: wrong head/tree result was not blocked."
        }
        else {
            Write-Output "PASS strict identity: wrong head is blocked."
            $invalidRejected += 1
        }
    }

    $canonicalBefore = Get-CanonicalFixtureHashes
    $safeRequestPath = Join-Path $tempRoot "safe_request.json"
    $safeResultPath = Join-Path $tempRoot "safe_result.json"
    $safeOutputRoot = Join-Path $tempRoot "safe_logs"
    $safeRequest = New-TestRunnerRequest -RequestPath $safeRequestPath -ResultPath $safeResultPath -OutputRoot $safeOutputRoot
    $requestValidator = Invoke-PowerShellFile -FilePath $validateRequestPath -Arguments @("-RequestPath", $safeRequest.RequestPath)
    if ($requestValidator.ExitCode -ne 0 -or ([string]::Join("`n", @($requestValidator.Output)) -notmatch "VALID")) {
        $failures += "FAIL validator: generated safe request validator did not print VALID. Output: $([string]::Join(' ', @($requestValidator.Output)))"
    }
    else {
        Write-Output "PASS validator: generated safe request prints VALID."
        $validPassed += 1
    }

    $safeCli = Invoke-PowerShellFile -FilePath $cliPath -Arguments @("-RequestPath", $safeRequest.RequestPath, "-OutputPath", $safeRequest.ResultPath)
    if ($safeCli.ExitCode -ne 0) {
        $failures += "FAIL CLI: safe completed request returned non-zero. Output: $([string]::Join(' ', @($safeCli.Output)))"
    }
    else {
        Write-Output "PASS CLI: safe completed request exited 0."
        $validPassed += 1
    }
    Assert-CanonicalHashesUnchanged -Before $canonicalBefore -Context "safe custom runner execution"

    $generatedResult = Read-JsonObject -Path $safeRequest.ResultPath
    $commandResults = @($generatedResult.command_results)
    $passedCommands = @($commandResults | Where-Object { [string]$_.verdict -eq "passed" })
    $failedCommands = @($commandResults | Where-Object { [string]$_.verdict -eq "failed" })
    if ($commandResults.Count -ne 3 -or $passedCommands.Count -ne 3 -or $failedCommands.Count -ne 0) {
        $failures += "FAIL generated: runner did not capture three passed command results."
    }
    else {
        Write-Output "PASS generated: runner captures three passed command results."
        $validPassed += 1
    }
    foreach ($commandResult in $commandResults) {
        foreach ($ref in @([string]$commandResult.stdout_ref, [string]$commandResult.stderr_ref)) {
            if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $ref))) {
                $failures += "FAIL generated: raw log ref '$ref' was not created."
            }
        }
    }
    if ($generatedResult.aggregate_verdict -ne "passed") {
        $failures += "FAIL generated: runner result aggregate_verdict was not passed."
    }
    else {
        Write-Output "PASS generated: runner result aggregate_verdict is passed."
        $validPassed += 1
    }

    $resultValidator = Invoke-PowerShellFile -FilePath $validateResultPath -Arguments @("-ResultPath", $safeRequest.ResultPath)
    if ($resultValidator.ExitCode -ne 0 -or ([string]::Join("`n", @($resultValidator.Output)) -notmatch "VALID")) {
        $failures += "FAIL validator: generated result validator did not print VALID. Output: $([string]::Join(' ', @($resultValidator.Output)))"
    }
    else {
        Write-Output "PASS validator: generated result prints VALID."
        $validPassed += 1
    }

    $unsafeCli = Invoke-PowerShellFile -FilePath $cliPath -Arguments @("-RequestPath", (Join-Path $invalidRoot "mutation_command_requested.invalid.json"), "-OutputPath", "state\runner\fixtures\invalid_result.json")
    if ($unsafeCli.ExitCode -eq 0) {
        $failures += "FAIL CLI: unsafe request exited 0."
    }
    else {
        Write-Output "PASS CLI: unsafe request exits non-zero."
        $invalidRejected += 1
    }

    $generatedResultText = [string]::Join("`n", @($generatedResult | ConvertTo-Json -Depth 100))
    foreach ($forbiddenClaim in @("external replay completed", "skill invocation completed", "final QA signoff accepted", "R13 hard value gate is delivered", "R14 is now active")) {
        if ($generatedResultText -match [regex]::Escape($forbiddenClaim)) {
            $failures += "FAIL claims: generated result contains forbidden claim '$forbiddenClaim'."
        }
    }
}
catch {
    $failures += ("FAIL R13 custom runner harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        $resolvedTemp = [System.IO.Path]::GetFullPath($tempRoot)
        $allowedPrefix = [System.IO.Path]::GetFullPath((Join-Path $repoRoot "state\runner\_test_runs")).TrimEnd([System.IO.Path]::DirectorySeparatorChar)
        if ($resolvedTemp.StartsWith($allowedPrefix + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R13 custom runner tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R13 custom runner tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
