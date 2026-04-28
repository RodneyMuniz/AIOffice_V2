[CmdletBinding()]
param(
    [string]$RepositoryRoot = ".",
    [string]$RequestedRef,
    [string]$Branch = "release/r10-real-external-runner-proof-foundation",
    [string]$OutputRoot,
    [string]$ArtifactName,
    [string]$WorkflowName = "R10 External Proof Bundle",
    [string]$WorkflowRef = ".github/workflows/r10-external-proof-bundle.yml"
)

$ErrorActionPreference = "Stop"

function Get-StringOrDefault {
    param(
        [AllowNull()]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$DefaultValue
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $DefaultValue
    }

    return $Value
}

function ConvertTo-RelativeRef {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BasePath,
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $resolvedBasePath = (Resolve-Path -LiteralPath $BasePath).Path
    $resolvedPath = (Resolve-Path -LiteralPath $Path).Path
    $trimChars = @([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
    $basePathWithSeparator = $resolvedBasePath.TrimEnd($trimChars) + [System.IO.Path]::DirectorySeparatorChar
    $baseUri = [System.Uri]$basePathWithSeparator
    $pathUri = [System.Uri]$resolvedPath
    return [System.Uri]::UnescapeDataString($baseUri.MakeRelativeUri($pathUri).ToString())
}

function Write-JsonFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Value
    )

    $Value | ConvertTo-Json -Depth 40 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Get-PowerShellExecutable {
    $pwshCommand = Get-Command -Name "pwsh" -ErrorAction SilentlyContinue
    if ($null -ne $pwshCommand) {
        return $pwshCommand.Source
    }

    $powershellCommand = Get-Command -Name "powershell" -ErrorAction SilentlyContinue
    if ($null -ne $powershellCommand) {
        return $powershellCommand.Source
    }

    throw "Neither pwsh nor powershell is available."
}

function Invoke-CommandForBundle {
    param(
        [Parameter(Mandatory = $true)]
        [string]$CommandId,
        [Parameter(Mandatory = $true)]
        [string]$Command,
        [Parameter(Mandatory = $true)]
        [string]$LogRoot,
        [Parameter(Mandatory = $true)]
        [string]$BundleRoot,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $stdoutPath = Join-Path $LogRoot ("{0}.stdout.log" -f $CommandId)
    $stderrPath = Join-Path $LogRoot ("{0}.stderr.log" -f $CommandId)
    $exitCodePath = Join-Path $LogRoot ("{0}.exit_code.txt" -f $CommandId)

    $process = Start-Process -FilePath (Get-PowerShellExecutable) `
        -ArgumentList @("-NoProfile", "-Command", $Command) `
        -WorkingDirectory $RepositoryRoot `
        -RedirectStandardOutput $stdoutPath `
        -RedirectStandardError $stderrPath `
        -NoNewWindow `
        -PassThru `
        -Wait

    $exitCode = [int]$process.ExitCode
    Set-Content -LiteralPath $exitCodePath -Value $exitCode -Encoding UTF8

    return [pscustomobject]@{
        command_id = $CommandId
        command = $Command
        stdout_ref = ConvertTo-RelativeRef -BasePath $BundleRoot -Path $stdoutPath
        stderr_ref = ConvertTo-RelativeRef -BasePath $BundleRoot -Path $stderrPath
        exit_code_ref = ConvertTo-RelativeRef -BasePath $BundleRoot -Path $exitCodePath
        exit_code = $exitCode
        verdict = if ($exitCode -eq 0) { "passed" } else { "failed" }
    }
}

function Write-CleanStatusEvidence {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $gitStatusOutput = @(& git status --short 2>&1)
    $gitStatusExitCode = $LASTEXITCODE
    $status = if ($gitStatusExitCode -ne 0) {
        "unknown"
    }
    elseif (($gitStatusOutput -join "`n").Trim().Length -eq 0) {
        "clean"
    }
    else {
        "dirty"
    }

    $evidence = [pscustomobject]@{
        label = $Label
        status = $status
        git_status_exit_code = $gitStatusExitCode
        git_status_short = @($gitStatusOutput)
        note = "R10-004 clean-state evidence for the external proof bundle runner path."
    }
    Write-JsonFile -Path $Path -Value $evidence

    return $status
}

$resolvedRepositoryRoot = (Resolve-Path -LiteralPath $RepositoryRoot).Path
Push-Location $resolvedRepositoryRoot
try {
    $requestedRefValue = Get-StringOrDefault -Value $RequestedRef -DefaultValue $Branch
    $outputRootValue = Get-StringOrDefault -Value $OutputRoot -DefaultValue (Join-Path ([System.IO.Path]::GetTempPath()) "r10-external-proof-bundle")
    New-Item -ItemType Directory -Path $outputRootValue -Force | Out-Null
    $resolvedOutputRoot = (Resolve-Path -LiteralPath $outputRootValue).Path
    $artifactsRoot = Join-Path $resolvedOutputRoot "artifacts"
    New-Item -ItemType Directory -Path $artifactsRoot -Force | Out-Null

    $runId = Get-StringOrDefault -Value $env:GITHUB_RUN_ID -DefaultValue "local-r10-external-proof-bundle"
    $runAttempt = Get-StringOrDefault -Value $env:GITHUB_RUN_ATTEMPT -DefaultValue "1"
    $artifactNameValue = Get-StringOrDefault -Value $ArtifactName -DefaultValue ("r10-external-proof-bundle-{0}-{1}" -f $runId, $runAttempt)
    $repository = "AIOffice_V2"
    $runnerKind = if ($env:GITHUB_ACTIONS -eq "true") { "github_actions" } else { "external_runner" }
    $runnerIdentity = if ($env:GITHUB_ACTIONS -eq "true") {
        "GitHub Actions runner {0} {1} {2}" -f $env:RUNNER_NAME, $env:RUNNER_OS, $env:RUNNER_ARCH
    }
    else {
        "local external runner model"
    }
    $runUrl = if ($env:GITHUB_ACTIONS -eq "true") {
        "{0}/{1}/actions/runs/{2}" -f $env:GITHUB_SERVER_URL, $env:GITHUB_REPOSITORY, $env:GITHUB_RUN_ID
    }
    else {
        "https://local.invalid/AIOffice_V2/r10-external-proof-bundle/local"
    }
    $retrievalInstruction = "Download artifact '$artifactNameValue' from GitHub Actions run '$runUrl'."

    $remoteHeadQueryPath = Join-Path $artifactsRoot "remote_head_query.txt"
    $remoteHeadOutput = @(& git ls-remote origin $Branch 2>&1)
    $remoteHeadExitCode = $LASTEXITCODE
    $remoteHeadOutput | Set-Content -LiteralPath $remoteHeadQueryPath -Encoding UTF8
    $remoteHeadSha = ""
    if ($remoteHeadExitCode -eq 0 -and $remoteHeadOutput.Count -gt 0 -and $remoteHeadOutput[0] -match '^([a-f0-9]{40})\s+') {
        $remoteHeadSha = $Matches[1]
    }

    $testedHeadPath = Join-Path $artifactsRoot "tested_head.txt"
    $testedTreePath = Join-Path $artifactsRoot "tested_tree.txt"
    $testedHeadSha = (& git rev-parse HEAD).Trim()
    $testedTreeSha = (& git rev-parse "HEAD^{tree}").Trim()
    Set-Content -LiteralPath $testedHeadPath -Value $testedHeadSha -Encoding UTF8
    Set-Content -LiteralPath $testedTreePath -Value $testedTreeSha -Encoding UTF8
    if ([string]::IsNullOrWhiteSpace($remoteHeadSha)) {
        $remoteHeadSha = $testedHeadSha
    }

    $cleanStatusBeforePath = Join-Path $artifactsRoot "clean_status_before.json"
    $cleanStatusAfterPath = Join-Path $artifactsRoot "clean_status_after.json"
    $cleanStatusBefore = Write-CleanStatusEvidence -Path $cleanStatusBeforePath -Label "before_commands"
    $powershellExecutable = Get-PowerShellExecutable

    $commands = @(
        [pscustomobject]@{
            command_id = "external-proof-artifact-bundle"
            command = "$powershellExecutable -NoProfile -File tests/test_external_proof_artifact_bundle.ps1"
        },
        [pscustomobject]@{
            command_id = "external-runner-closeout-identity"
            command = "$powershellExecutable -NoProfile -File tests/test_external_runner_closeout_identity.ps1"
        },
        [pscustomobject]@{
            command_id = "status-doc-gate-test"
            command = "$powershellExecutable -NoProfile -File tests/test_status_doc_gate.ps1"
        },
        [pscustomobject]@{
            command_id = "status-doc-gate-validator"
            command = "$powershellExecutable -NoProfile -File tools/validate_status_doc_gate.ps1"
        },
        [pscustomobject]@{
            command_id = "git-diff-check"
            command = "git diff --check"
        }
    )

    $commandManifestPath = Join-Path $artifactsRoot "command_manifest.json"
    Write-JsonFile -Path $commandManifestPath -Value ([pscustomobject]@{
            note = "Focused R10-004 external proof bundle command set. This manifest is not broad CI/product coverage."
            commands = $commands
        })

    $commandResults = @()
    foreach ($commandSpec in $commands) {
        $commandResults += Invoke-CommandForBundle -CommandId $commandSpec.command_id -Command $commandSpec.command -LogRoot $artifactsRoot -BundleRoot $resolvedOutputRoot -RepositoryRoot $resolvedRepositoryRoot
    }

    $cleanStatusAfter = Write-CleanStatusEvidence -Path $cleanStatusAfterPath -Label "after_commands"

    $refusalReasons = @()
    if ($remoteHeadExitCode -ne 0) {
        $refusalReasons += "remote head query failed with exit code $remoteHeadExitCode"
    }
    $headMatch = ($remoteHeadSha -eq $testedHeadSha)
    if (-not $headMatch) {
        $refusalReasons += "remote branch head does not match tested head"
    }
    if ($cleanStatusBefore -ne "clean") {
        $refusalReasons += "worktree was not clean before commands"
    }
    if ($cleanStatusAfter -ne "clean") {
        $refusalReasons += "worktree was not clean after commands"
    }
    foreach ($commandResult in $commandResults) {
        if ($commandResult.verdict -ne "passed") {
            $refusalReasons += ("command '{0}' exited with {1}" -f $commandResult.command_id, $commandResult.exit_code)
        }
    }

    $aggregateVerdict = if ($refusalReasons.Count -eq 0) { "passed" } else { "failed" }
    $nonClaims = @(
        "no broad CI/product coverage claim",
        "no UI or control-room productization",
        "no Standard runtime",
        "no multi-repo orchestration",
        "no swarms",
        "no broad autonomous milestone execution",
        "no unattended automatic resume",
        "no solved Codex context compaction",
        "no hours-long unattended milestone execution",
        "no destructive rollback",
        "no general Codex reliability"
    )

    $retrievalReadmePath = Join-Path $resolvedOutputRoot "artifact_retrieval_README.txt"
    @(
        "R10 external proof bundle artifact retrieval",
        "Artifact name: $artifactNameValue",
        "Run URL: $runUrl",
        "Instruction: $retrievalInstruction",
        "Boundary: workflow existence or this generated bundle path is not accepted R10-005 proof until a later committed identity packet cites a real run and artifact retrieval evidence."
    ) | Set-Content -LiteralPath $retrievalReadmePath -Encoding UTF8

    $bundle = [pscustomobject]@{
        contract_version = "v1"
        bundle_type = "external_proof_artifact_bundle"
        bundle_id = "r10-004-external-proof-bundle-$runId-$runAttempt"
        repository = $repository
        branch = $Branch
        triggering_ref = $requestedRefValue
        runner_kind = $runnerKind
        runner_identity = $runnerIdentity
        workflow_name = $WorkflowName
        workflow_ref = $WorkflowRef
        run_id = $runId
        run_url = $runUrl
        artifact_name = $artifactNameValue
        artifact_url_or_retrieval_instruction = $retrievalInstruction
        remote_head_sha = $remoteHeadSha
        tested_head_sha = $testedHeadSha
        tested_tree_sha = $testedTreeSha
        head_match = $headMatch
        clean_status_before = [pscustomobject]@{
            status = $cleanStatusBefore
            evidence_ref = ConvertTo-RelativeRef -BasePath $resolvedOutputRoot -Path $cleanStatusBeforePath
        }
        clean_status_after = [pscustomobject]@{
            status = $cleanStatusAfter
            evidence_ref = ConvertTo-RelativeRef -BasePath $resolvedOutputRoot -Path $cleanStatusAfterPath
        }
        command_manifest_ref = ConvertTo-RelativeRef -BasePath $resolvedOutputRoot -Path $commandManifestPath
        command_results = $commandResults
        aggregate_verdict = $aggregateVerdict
        refusal_reasons = $refusalReasons
        created_at_utc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        non_claims = $nonClaims
        remote_head_query_ref = ConvertTo-RelativeRef -BasePath $resolvedOutputRoot -Path $remoteHeadQueryPath
        tested_head_ref = ConvertTo-RelativeRef -BasePath $resolvedOutputRoot -Path $testedHeadPath
        tested_tree_ref = ConvertTo-RelativeRef -BasePath $resolvedOutputRoot -Path $testedTreePath
        retrieval_readme_ref = ConvertTo-RelativeRef -BasePath $resolvedOutputRoot -Path $retrievalReadmePath
    }

    $bundlePath = Join-Path $resolvedOutputRoot "external_proof_artifact_bundle.json"
    Write-JsonFile -Path $bundlePath -Value $bundle

    $validationStdoutPath = Join-Path $artifactsRoot "bundle_validation.stdout.log"
    $validationStderrPath = Join-Path $artifactsRoot "bundle_validation.stderr.log"
    $validationExitCodePath = Join-Path $artifactsRoot "bundle_validation.exit_code.txt"
    $validationProcess = Start-Process -FilePath $powershellExecutable `
        -ArgumentList @("-NoProfile", "-File", "tools/validate_external_proof_artifact_bundle.ps1", "-BundlePath", $bundlePath) `
        -WorkingDirectory $resolvedRepositoryRoot `
        -RedirectStandardOutput $validationStdoutPath `
        -RedirectStandardError $validationStderrPath `
        -NoNewWindow `
        -PassThru `
        -Wait
    Set-Content -LiteralPath $validationExitCodePath -Value ([int]$validationProcess.ExitCode) -Encoding UTF8

    if ($validationProcess.ExitCode -ne 0) {
        throw "R10 external proof bundle validation failed. See '$validationStderrPath'."
    }

    Write-Output ("R10 external proof artifact bundle written to {0}" -f $bundlePath)
    Write-Output ("Aggregate verdict: {0}" -f $aggregateVerdict)
    if ($aggregateVerdict -ne "passed") {
        Write-Output ("Refusal reasons: {0}" -f ($refusalReasons -join "; "))
        exit 1
    }
}
finally {
    Pop-Location
}
