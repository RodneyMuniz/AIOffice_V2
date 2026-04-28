$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
function Join-PathSegments {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Segments
    )

    $path = $Segments[0]
    foreach ($segment in @($Segments | Select-Object -Skip 1)) {
        $path = Join-Path $path $segment
    }

    return $path
}

Import-Module (Join-PathSegments -Segments @($repoRoot, "tools", "ExternalRunnerArtifactIdentity.psm1")) -Force
Import-Module (Join-PathSegments -Segments @($repoRoot, "tools", "JsonRoot.psm1")) -Force
$testExternalRunnerCloseoutIdentity = Get-Command -Name "Test-ExternalRunnerCloseoutIdentityContract" -ErrorAction Stop

function Assert-ContractVersionVisible {
    param(
        [Parameter(Mandatory = $true)]
        $Document,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    Assert-SingleJsonRootObject -Document $Document -Label $Label
    if ($Document.contract_version -isnot [string] -or [string]::IsNullOrWhiteSpace($Document.contract_version)) {
        throw "$Label contract_version did not load as a non-empty string."
    }
}

function Get-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return (Read-SingleJsonObject -Path $Path -Label $Path)
}

function Write-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Document
    )

    $json = $Document | ConvertTo-Json -Depth 30
    Set-Content -LiteralPath $Path -Value $json -Encoding UTF8
}

function New-R10CloseoutFixtureRoot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r10closeoutidentity" + [guid]::NewGuid().ToString("N").Substring(0, 8))
    $sourceRoot = Join-PathSegments -Segments @($repoRoot, "state", "fixtures", "valid", "external_runner_artifact")
    $fixtureRoot = Join-Path $tempRoot $Label
    New-Item -ItemType Directory -Path $fixtureRoot -Force | Out-Null
    Get-ChildItem -LiteralPath $sourceRoot | Copy-Item -Destination $fixtureRoot -Recurse -Force
    return $fixtureRoot
}

function Invoke-R10CloseoutFixtureMutation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Mutation
    )

    $fixtureRoot = New-R10CloseoutFixtureRoot -Label $Label

    try {
        $packetPath = Join-Path $fixtureRoot "r10_closeout_identity.valid.json"
        $packet = Get-JsonDocument -Path $packetPath
        & $Mutation $packet $fixtureRoot
        Write-JsonDocument -Path $packetPath -Document $packet
        return $packetPath
    }
    catch {
        if (Test-Path -LiteralPath $fixtureRoot) {
            Remove-Item -LiteralPath $fixtureRoot -Recurse -Force
        }

        throw
    }
}

function Remove-FixtureForPacket {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PacketPath
    )

    $fixtureRoot = Split-Path -Parent $PacketPath
    $tempRoot = Split-Path -Parent $fixtureRoot
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

function Invoke-ExpectedRefusal {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [string[]]$RequiredFragments,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Action
    )

    try {
        & $Action
        $script:failures += ("FAIL invalid: {0} was accepted unexpectedly." -f $Label)
    }
    catch {
        $message = $_.Exception.Message
        $missingFragments = @($RequiredFragments | Where-Object { $message -notlike ("*{0}*" -f $_) })
        if ($missingFragments.Count -gt 0) {
            $script:failures += ("FAIL invalid: {0} refusal message missed fragments {1}. Actual: {2}" -f $Label, ($missingFragments -join ", "), $message)
            return
        }

        Write-Output ("PASS invalid: {0} -> {1}" -f $Label, $message)
        $script:invalidRejected += 1
    }
}

function Invoke-MutatedRefusal {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [string[]]$RequiredFragments,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Mutation
    )

    Invoke-ExpectedRefusal -Label $Label -RequiredFragments $RequiredFragments -Action {
        $packetPath = Invoke-R10CloseoutFixtureMutation -Label $Label -Mutation $Mutation
        try {
            & $testExternalRunnerCloseoutIdentity -PacketPath $packetPath | Out-Null
        }
        finally {
            Remove-FixtureForPacket -PacketPath $packetPath
        }
    }
}

$validPassed = 0
$invalidRejected = 0
$failures = @()
$validFixture = Join-PathSegments -Segments @($repoRoot, "state", "fixtures", "valid", "external_runner_artifact", "r10_closeout_identity.valid.json")
$r9LimitationFixture = Join-PathSegments -Segments @($repoRoot, "state", "fixtures", "valid", "external_runner_artifact", "external_runner_limitation.valid.json")

try {
    $validFixtureDocument = Get-JsonDocument -Path $validFixture
    Assert-ContractVersionVisible -Document $validFixtureDocument -Label "Valid closeout identity repository fixture"

    $copiedFixtureRoot = New-R10CloseoutFixtureRoot -Label "cross-platform-fixture-copy"
    try {
        $copiedFixturePath = Join-Path $copiedFixtureRoot "r10_closeout_identity.valid.json"
        $copiedFixtureDocument = Get-JsonDocument -Path $copiedFixturePath
        Assert-ContractVersionVisible -Document $copiedFixtureDocument -Label "Copied closeout identity temp fixture"
    }
    finally {
        Remove-FixtureForPacket -PacketPath (Join-Path $copiedFixtureRoot "r10_closeout_identity.valid.json")
    }

    Invoke-ExpectedRefusal -Label "array-root-json-document" -RequiredFragments @("single JSON object", "array root") -Action {
        $arrayRootPath = Join-Path ([System.IO.Path]::GetTempPath()) ("r10closeoutidentity-array-root-" + [guid]::NewGuid().ToString("N") + ".json")
        try {
            Set-Content -LiteralPath $arrayRootPath -Value '[{"contract_version":"v1"}]' -Encoding UTF8
            & $testExternalRunnerCloseoutIdentity -PacketPath $arrayRootPath | Out-Null
        }
        finally {
            if (Test-Path -LiteralPath $arrayRootPath) {
                Remove-Item -LiteralPath $arrayRootPath -Force
            }
        }
    }

    $validResult = & $testExternalRunnerCloseoutIdentity -PacketPath $validFixture
    if (-not $validResult.IsSuccessfulProofIdentity) {
        $failures += "FAIL valid: validator-only R10 closeout identity shape was not marked as a successful identity shape."
    }
    else {
        Write-Output ("PASS valid validator-only shape: {0} -> {1} {2}" -f $validResult.ArtifactId, $validResult.Status, $validResult.Conclusion)
        $validPassed += 1
    }

    $failurePacketPath = Invoke-R10CloseoutFixtureMutation -Label "valid-completed-failure" -Mutation {
        param($packet)
        $packet.artifact_id = "r10-002-closeout-identity-validator-failure-shape"
        $packet.conclusion = "failure"
    }
    try {
        $failureResult = & $testExternalRunnerCloseoutIdentity -PacketPath $failurePacketPath
        if ($failureResult.IsSuccessfulProofIdentity) {
            $failures += "FAIL valid: completed failure identity was incorrectly marked as successful proof identity."
        }
        else {
            Write-Output ("PASS valid completed failure shape: {0} -> {1} {2}" -f $failureResult.ArtifactId, $failureResult.Status, $failureResult.Conclusion)
            $validPassed += 1
        }
    }
    finally {
        Remove-FixtureForPacket -PacketPath $failurePacketPath
    }

    Invoke-ExpectedRefusal -Label "r9-limitation-fixture-as-r10-closeout-proof" -RequiredFragments @("missing required field", "command_manifest_ref") -Action {
        & $testExternalRunnerCloseoutIdentity -PacketPath $r9LimitationFixture | Out-Null
    }

    Invoke-MutatedRefusal -Label "unavailable-status" -RequiredFragments @("status", "completed") -Mutation {
        param($packet)
        $packet.status = "unavailable"
    }

    Invoke-MutatedRefusal -Label "unavailable-conclusion" -RequiredFragments @("conclusion", "success, failure, cancelled, timed_out, skipped") -Mutation {
        param($packet)
        $packet.conclusion = "unavailable"
    }

    Invoke-MutatedRefusal -Label "empty-run-id" -RequiredFragments @("run_id", "non-empty string") -Mutation {
        param($packet)
        $packet.run_id = ""
    }

    foreach ($syntheticRunId in @("synthetic", "dummy", "test", "placeholder")) {
        Invoke-MutatedRefusal -Label ("synthetic-run-id-" + $syntheticRunId) -RequiredFragments @("run_id", "synthetic") -Mutation {
            param($packet)
            $packet.run_id = $syntheticRunId
        }
    }

    Invoke-MutatedRefusal -Label "empty-run-url" -RequiredFragments @("run_url", "non-empty string") -Mutation {
        param($packet)
        $packet.run_url = ""
    }

    Invoke-MutatedRefusal -Label "invalid-github-actions-run-url" -RequiredFragments @("run_url", "required pattern") -Mutation {
        param($packet)
        $packet.run_url = "https://example.invalid/not-a-github-actions-run"
    }

    Invoke-MutatedRefusal -Label "missing-runner-identity" -RequiredFragments @("runner_identity", "non-empty string") -Mutation {
        param($packet)
        $packet.runner_identity = ""
    }

    Invoke-MutatedRefusal -Label "missing-workflow-name" -RequiredFragments @("workflow_name", "non-empty string") -Mutation {
        param($packet)
        $packet.workflow_name = ""
    }

    Invoke-MutatedRefusal -Label "missing-workflow-ref" -RequiredFragments @("workflow_ref", "non-empty string") -Mutation {
        param($packet)
        $packet.workflow_ref = ""
    }

    Invoke-MutatedRefusal -Label "empty-artifact-name" -RequiredFragments @("artifact_name", "non-empty string") -Mutation {
        param($packet)
        $packet.artifact_name = ""
    }

    Invoke-MutatedRefusal -Label "empty-retrieval-instruction" -RequiredFragments @("artifact_url_or_retrieval_instruction", "non-empty string") -Mutation {
        param($packet)
        $packet.artifact_url_or_retrieval_instruction = ""
    }

    Invoke-MutatedRefusal -Label "missing-command-manifest-ref" -RequiredFragments @("command_manifest_ref", "non-empty string") -Mutation {
        param($packet)
        $packet.command_manifest_ref = ""
    }

    Invoke-MutatedRefusal -Label "missing-head-sha" -RequiredFragments @("head_sha", "non-empty string") -Mutation {
        param($packet)
        $packet.head_sha = ""
    }

    Invoke-MutatedRefusal -Label "missing-tree-sha" -RequiredFragments @("tree_sha", "non-empty string") -Mutation {
        param($packet)
        $packet.tree_sha = ""
    }

    Invoke-MutatedRefusal -Label "missing-stdout-refs" -RequiredFragments @("stdout_log_refs", "must not be empty") -Mutation {
        param($packet)
        $packet.stdout_log_refs = @()
    }

    Invoke-MutatedRefusal -Label "missing-stderr-refs" -RequiredFragments @("stderr_log_refs", "must not be empty") -Mutation {
        param($packet)
        $packet.stderr_log_refs = @()
    }

    Invoke-MutatedRefusal -Label "missing-exit-code-refs" -RequiredFragments @("exit_code_refs", "must not be empty") -Mutation {
        param($packet)
        $packet.exit_code_refs = @()
    }

    Invoke-MutatedRefusal -Label "missing-qa-packet-ref" -RequiredFragments @("qa_packet_ref", "non-empty string") -Mutation {
        param($packet)
        $packet.qa_packet_ref = ""
    }

    Invoke-MutatedRefusal -Label "missing-remote-head-evidence-ref" -RequiredFragments @("remote_head_evidence_ref", "non-empty string") -Mutation {
        param($packet)
        $packet.remote_head_evidence_ref = ""
    }

    Invoke-MutatedRefusal -Label "missing-final-head-support-ref" -RequiredFragments @("final_remote_head_support_ref", "non-empty string") -Mutation {
        param($packet)
        $packet.final_remote_head_support_ref = ""
    }

    Invoke-MutatedRefusal -Label "wrong-branch-old-r9-support-line" -RequiredFragments @("branch", "release/r10-real-external-runner-proof-foundation") -Mutation {
        param($packet)
        $packet.branch = "feature/r5-closeout-remaining-foundations"
    }

    Invoke-MutatedRefusal -Label "missing-required-non-claim" -RequiredFragments @("non_claims", "no solved Codex context compaction") -Mutation {
        param($packet)
        $packet.non_claims = @($packet.non_claims | Where-Object { $_ -ne "no solved Codex context compaction" })
    }

    Invoke-MutatedRefusal -Label "broad-ci-product-coverage-claim" -RequiredFragments @("broad CI/product coverage") -Mutation {
        param($packet)
        $packet.non_claims += "production-grade CI product coverage is complete"
    }

    Invoke-MutatedRefusal -Label "unavailable-limitation-described-as-proof" -RequiredFragments @("limitation-only external-runner evidence", "proof") -Mutation {
        param($packet)
        $packet.artifact_url_or_retrieval_instruction = "unavailable limitation external-runner proof satisfies R10 closeout."
    }

    Invoke-MutatedRefusal -Label "r9-004-limitation-satisfies-r10-proof" -RequiredFragments @("R9-004 limitation evidence", "R10 external proof") -Mutation {
        param($packet)
        $packet.artifact_url_or_retrieval_instruction = "R9-004 limitation evidence satisfies R10 external proof."
    }
}
catch {
    $failures += ("FAIL external runner closeout identity harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("External runner closeout identity tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All external runner closeout identity tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
