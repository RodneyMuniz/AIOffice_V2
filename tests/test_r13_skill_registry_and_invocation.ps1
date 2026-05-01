$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$registryModule = Import-Module (Join-Path $repoRoot "tools\R13SkillRegistry.psm1") -Force -PassThru
$invocationModule = Import-Module (Join-Path $repoRoot "tools\R13SkillInvocation.psm1") -Force -PassThru
$testRegistry = $registryModule.ExportedCommands["Test-R13SkillRegistry"]
$testRequest = $invocationModule.ExportedCommands["Test-R13SkillInvocationRequest"]
$testResult = $invocationModule.ExportedCommands["Test-R13SkillInvocationResult"]
$writeJson = $registryModule.ExportedCommands["Write-R13SkillJsonFile"]

$validRegistryPath = Join-Path $repoRoot "state\fixtures\valid\skills\r13_skill_registry.valid.json"
$cycleRegistryPath = Join-Path $repoRoot "state\cycles\r13_api_first_qa_pipeline_and_operator_control_room_product_slice\skills\r13_008_skill_registry.json"
$validRoot = Join-Path $repoRoot "state\fixtures\valid\skills"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\skills\r13_skill_invocation"
$canonicalInvalidRoot = Join-Path $repoRoot "state\fixtures\invalid\actionable_qa\r13_detector_inputs"
$invokeCli = Join-Path $repoRoot "tools\invoke_r13_skill.ps1"
$tempRoot = Join-Path $repoRoot ("state\skills\_test_runs\" + [guid]::NewGuid().ToString("N"))

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

function Write-JsonObject {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Value
    )

    & $writeJson -Path $Path -Value $Value
}

function ConvertTo-RepoRef {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $full = [System.IO.Path]::GetFullPath($Path)
    return $full.Substring($repoRoot.Length + 1).Replace("\", "/")
}

function Get-CurrentGitIdentity {
    return [pscustomobject]@{
        Branch = ([string](& git -C $repoRoot branch --show-current)).Trim()
        Head = ([string](& git -C $repoRoot rev-parse HEAD)).Trim()
        Tree = ([string](& git -C $repoRoot rev-parse "HEAD^{tree}")).Trim()
    }
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

function Update-TestRequestOutput {
    param(
        [Parameter(Mandatory = $true)]
        $Request,
        [Parameter(Mandatory = $true)]
        [string]$InvocationId,
        [Parameter(Mandatory = $true)]
        [string]$ResultRef,
        [Parameter(Mandatory = $true)]
        [string]$RawLogRef
    )

    $Request.invocation_id = $InvocationId
    $gitIdentity = Get-CurrentGitIdentity
    $Request.branch = $gitIdentity.Branch
    $Request.head = $gitIdentity.Head
    $Request.tree = $gitIdentity.Tree
    $Request.expected_result_ref = $ResultRef
    $Request.requested_outputs[0].ref = $ResultRef
    $Request.requested_outputs[1].ref = $RawLogRef
    $flatAllowedPaths = @()
    foreach ($inputRef in @($Request.input_refs)) {
        $flatAllowedPaths += [string]$inputRef.ref
    }
    $flatAllowedPaths += "contracts/skills/r13_skill_invocation_result.contract.json"
    $flatAllowedPaths += $ResultRef
    $flatAllowedPaths += $RawLogRef
    $Request.allowed_paths = [string[]]$flatAllowedPaths
    return $Request
}

function New-TestRequest {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourceRequestPath,
        [Parameter(Mandatory = $true)]
        [string]$InvocationId,
        [Parameter(Mandatory = $true)]
        [string]$OutputName
    )

    $request = Read-JsonObject -Path $SourceRequestPath
    $resultRef = ("state/skills/_test_runs/{0}/{1}_result.json" -f (Split-Path -Leaf $tempRoot), $OutputName)
    $rawLogRef = ("state/skills/_test_runs/{0}/{1}_raw_logs" -f (Split-Path -Leaf $tempRoot), $OutputName)
    $request = Update-TestRequestOutput -Request $request -InvocationId $InvocationId -ResultRef $resultRef -RawLogRef $rawLogRef
    $requestPath = Join-Path $tempRoot ("{0}_request.json" -f $OutputName)
    Write-JsonObject -Path $requestPath -Value $request
    return [pscustomobject]@{
        RequestPath = $requestPath
        ResultRef = $resultRef
        ResultPath = Join-Path $repoRoot $resultRef
        RawLogRef = $rawLogRef
    }
}

function Assert-NoHardGateOverclaim {
    $paths = @(
        "README.md",
        "execution\KANBAN.md",
        "governance\ACTIVE_STATE.md",
        "governance\DECISION_LOG.md",
        "governance\R13_API_FIRST_QA_PIPELINE_AND_OPERATOR_CONTROL_ROOM_PRODUCT_SLICE.md"
    )
    $text = [string]::Join("`n", @($paths | ForEach-Object { Get-Content -LiteralPath (Join-Path $repoRoot $_) -Raw }))
    $forbidden = @(
        '(?i)\bR13\b.{0,120}\bhard value gate\b.{0,120}\b(delivered|complete|proved)\b',
        '(?i)\bmeaningful QA loop\b.{0,120}\b(delivered|complete|proved)\b',
        '(?i)\bAPI/custom-runner bypass\b.{0,120}\b(delivered|complete|proved)\b',
        '(?i)\bcurrent operator control-room\b.{0,120}\b(delivered|complete|proved)\b',
        '(?i)\boperator demo\b.{0,120}\b(delivered|complete|proved)\b',
        '(?i)\bR14\b.*\b(active|open|opened)\b',
        '(?i)\bsuccessor milestone\b.*\b(active|open|opened)\b'
    )
    foreach ($line in @($text -split "\r?\n")) {
        foreach ($pattern in $forbidden) {
            if ($line -match $pattern -and $line -notmatch '(?i)\b(no|not|without|planned|partial|partially|not yet|not fully)\b') {
                $script:failures += "FAIL status: R13-008 status docs contain hard-gate or successor overclaim."
                return
            }
        }
    }

    Write-Output "PASS status: no hard R13 value gate is marked delivered by R13-008."
    $script:validPassed += 1
}

try {
    $registryValidation = & $testRegistry -RegistryPath $validRegistryPath
    if ($registryValidation.SkillCount -ne 4) {
        $failures += "FAIL valid: skill registry fixture did not expose four skills."
    }
    else {
        Write-Output "PASS valid registry fixture."
        $validPassed += 1
    }

    foreach ($requestFixture in @(
            "r13_skill_invocation_request.qa_detect.valid.json",
            "r13_skill_invocation_request.qa_fix_plan.valid.json"
        )) {
        $validation = & $testRequest -RegistryPath $validRegistryPath -RequestPath (Join-Path $validRoot $requestFixture)
        if ($validation.CommandCount -ne 1) {
            $failures += "FAIL valid: request fixture '$requestFixture' did not expose one command."
        }
        else {
            Write-Output ("PASS valid request fixture: {0}" -f $requestFixture)
            $validPassed += 1
        }
    }

    foreach ($resultFixture in @(
            "r13_skill_invocation_result.qa_detect.passed.valid.json",
            "r13_skill_invocation_result.qa_fix_plan.passed.valid.json",
            "r13_skill_invocation_result.blocked.valid.json"
        )) {
        $validation = & $testResult -RegistryPath $validRegistryPath -ResultPath (Join-Path $validRoot $resultFixture)
        if ($resultFixture -like "*.blocked.*" -and $validation.AggregateVerdict -ne "blocked") {
            $failures += "FAIL valid: blocked result fixture did not validate as blocked."
        }
        elseif ($resultFixture -notlike "*.blocked.*" -and $validation.AggregateVerdict -ne "passed") {
            $failures += "FAIL valid: passed result fixture '$resultFixture' did not validate as passed."
        }
        else {
            Write-Output ("PASS valid result fixture: {0}" -f $resultFixture)
            $validPassed += 1
        }
    }

    $registryInvalidFixtures = @(
        "missing_required_skill.invalid.json",
        "duplicate_skill_id.invalid.json",
        "missing_output_contract.invalid.json"
    )
    foreach ($fixtureName in $registryInvalidFixtures) {
        $path = Join-Path $invalidRoot $fixtureName
        if (-not (Test-Path -LiteralPath $path)) {
            $failures += "FAIL fixture: missing invalid fixture '$fixtureName'."
            continue
        }
        Invoke-ExpectedRefusal -Label $fixtureName -Action {
            & $testRegistry -RegistryPath $path | Out-Null
        }
    }

    $requestInvalidFixtures = @(
        "unknown_skill_id.invalid.json",
        "mutation_command_requested.invalid.json",
        "git_push_command_requested.invalid.json",
        "outside_repo_path.invalid.json",
        "missing_input_ref.invalid.json",
        "external_replay_executed_too_early.invalid.json",
        "control_room_gate_claimed.invalid.json",
        "final_signoff_claimed.invalid.json",
        "hard_gate_claimed.invalid.json",
        "missing_non_claims.invalid.json",
        "r14_successor_opened.invalid.json"
    )
    foreach ($fixtureName in $requestInvalidFixtures) {
        $path = Join-Path $invalidRoot $fixtureName
        if (-not (Test-Path -LiteralPath $path)) {
            $failures += "FAIL fixture: missing invalid fixture '$fixtureName'."
            continue
        }
        Invoke-ExpectedRefusal -Label $fixtureName -Action {
            & $testRequest -RegistryPath $validRegistryPath -RequestPath $path | Out-Null
        }
    }

    $baseRequestPath = Join-Path $validRoot "r13_skill_invocation_request.qa_detect.valid.json"
    foreach ($unsafeCommand in @(
            @{ Label = "mutation command"; Command = "powershell -NoProfile -ExecutionPolicy Bypass -Command Set-Content README.md bad" },
            @{ Label = "git push"; Command = "git push origin HEAD" },
            @{ Label = "git clean"; Command = "git clean -fdx" },
            @{ Label = "git reset"; Command = "git reset --hard HEAD" },
            @{ Label = "git rm"; Command = "git rm README.md" }
        )) {
        $request = Read-JsonObject -Path $baseRequestPath
        $request.invocation_id = "r13-008-unsafe-" + (($unsafeCommand.Label -replace '\s+', '-') -replace '[^a-zA-Z0-9-]', '')
        $request.allowed_commands = @([pscustomobject][ordered]@{ command_id = "unsafe"; command = $unsafeCommand.Command })
        $unsafePath = Join-Path $tempRoot ($request.invocation_id + ".json")
        Write-JsonObject -Path $unsafePath -Value $request
        Invoke-ExpectedRefusal -Label $unsafeCommand.Label -Action {
            & $testRequest -RegistryPath $validRegistryPath -RequestPath $unsafePath | Out-Null
        }
    }

    foreach ($claimCase in @(
            @{ Label = "control-room gate claim"; Text = "current operator control-room gate delivered by R13-008" },
            @{ Label = "final signoff claim"; Text = "final QA signoff accepted by R13-008" },
            @{ Label = "R14 successor claim"; Text = "R14 successor milestone opened by R13-008" }
        )) {
        $request = Read-JsonObject -Path $baseRequestPath
        $request.refusal_reasons = @($claimCase.Text)
        $claimPath = Join-Path $tempRoot (($claimCase.Label -replace '\s+', '_') + ".json")
        Write-JsonObject -Path $claimPath -Value $request
        Invoke-ExpectedRefusal -Label $claimCase.Label -Action {
            & $testRequest -RegistryPath $validRegistryPath -RequestPath $claimPath | Out-Null
        }
    }

    $registryObject = Read-JsonObject -Path $validRegistryPath
    $runnerSkill = @($registryObject.skills | Where-Object { [string]$_.skill_id -eq "runner.external_replay" })[0]
    $externalReplayRequest = Read-JsonObject -Path $baseRequestPath
    $externalReplayRequest.invocation_id = "r13-008-external-replay-too-early-dynamic"
    $externalReplayRequest.skill_id = "runner.external_replay"
    $externalReplayRequest.invocation_mode = "generate_artifact"
    $externalReplayRequest.input_refs = @([pscustomobject][ordered]@{
            ref_id = "r13-007-custom-runner-result"
            ref = "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/runner/r13_007_custom_runner_result.json"
            evidence_kind = "custom_runner_result"
            authority_kind = "repo_evidence"
            scope = "repo"
        })
    $externalReplayRequest.allowed_commands = @($runnerSkill.allowed_commands)
    $externalReplayRequest.allowed_paths = [string[]]@(
        "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/runner/r13_007_custom_runner_result.json",
        "contracts/skills/r13_skill_invocation_result.contract.json",
        [string]$externalReplayRequest.expected_result_ref,
        [string]$externalReplayRequest.requested_outputs[1].ref
    )
    $externalReplayPath = Join-Path $tempRoot "external_replay_too_early_dynamic.json"
    Write-JsonObject -Path $externalReplayPath -Value $externalReplayRequest
    Invoke-ExpectedRefusal -Label "external replay execution too early" -Action {
        & $testRequest -RegistryPath $validRegistryPath -RequestPath $externalReplayPath | Out-Null
    }

    $canonicalBefore = Get-CanonicalFixtureHashes
    $detectTest = New-TestRequest -SourceRequestPath (Join-Path $validRoot "r13_skill_invocation_request.qa_detect.valid.json") -InvocationId "r13-008-test-qa-detect" -OutputName "qa_detect"
    $detectCli = Invoke-PowerShellFile -FilePath $invokeCli -Arguments @("-RegistryPath", $cycleRegistryPath, "-RequestPath", $detectTest.RequestPath, "-OutputPath", $detectTest.ResultRef)
    if ($detectCli.ExitCode -ne 0) {
        $failures += "FAIL invocation: qa.detect invocation returned non-zero. Output: $([string]::Join(' ', @($detectCli.Output)))"
    }
    else {
        Write-Output "PASS invocation: qa.detect completed through CLI."
        $validPassed += 1
    }

    $fixPlanTest = New-TestRequest -SourceRequestPath (Join-Path $validRoot "r13_skill_invocation_request.qa_fix_plan.valid.json") -InvocationId "r13-008-test-qa-fix-plan" -OutputName "qa_fix_plan"
    $fixCli = Invoke-PowerShellFile -FilePath $invokeCli -Arguments @("-RegistryPath", $cycleRegistryPath, "-RequestPath", $fixPlanTest.RequestPath, "-OutputPath", $fixPlanTest.ResultRef)
    if ($fixCli.ExitCode -ne 0) {
        $failures += "FAIL invocation: qa.fix_plan invocation returned non-zero. Output: $([string]::Join(' ', @($fixCli.Output)))"
    }
    else {
        Write-Output "PASS invocation: qa.fix_plan completed through CLI."
        $validPassed += 1
    }
    Assert-CanonicalHashesUnchanged -Before $canonicalBefore -Context "R13 skill invocation tests"

    foreach ($generated in @($detectTest, $fixPlanTest)) {
        $validation = & $testResult -RegistryPath $cycleRegistryPath -ResultPath $generated.ResultPath
        if ($validation.AggregateVerdict -ne "passed" -or $validation.CommandCount -ne 1 -or $validation.PassedCommandCount -ne 1) {
            $failures += "FAIL generated: invocation result did not preserve one passed command."
        }
        else {
            Write-Output ("PASS generated result validates: {0}" -f $validation.SkillId)
            $validPassed += 1
        }
        $result = Read-JsonObject -Path $generated.ResultPath
        if (@($result.command_results).Count -eq 0 -or @($result.output_artifacts).Count -lt 3) {
            $failures += "FAIL generated: invocation result did not preserve command results and output refs."
        }
        foreach ($commandResult in @($result.command_results)) {
            foreach ($ref in @([string]$commandResult.stdout_ref, [string]$commandResult.stderr_ref)) {
                if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $ref))) {
                    $failures += "FAIL generated: raw log ref '$ref' was not created."
                }
            }
        }
    }

    Assert-NoHardGateOverclaim
}
catch {
    $failures += ("FAIL R13 skill registry/invocation harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        $resolvedTemp = [System.IO.Path]::GetFullPath($tempRoot)
        $allowedPrefix = [System.IO.Path]::GetFullPath((Join-Path $repoRoot "state\skills\_test_runs")).TrimEnd([System.IO.Path]::DirectorySeparatorChar)
        if ($resolvedTemp.StartsWith($allowedPrefix + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R13 skill registry and invocation tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R13 skill registry and invocation tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
