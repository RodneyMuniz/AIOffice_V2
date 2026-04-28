$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\ExternalRunnerConsumingQaSignoff.psm1") -Force -PassThru
$jsonRootModule = Import-Module (Join-Path $repoRoot "tools\JsonRoot.psm1") -Force -PassThru
$testExternalRunnerConsumingQaSignoff = $module.ExportedCommands["Test-ExternalRunnerConsumingQaSignoffContract"]
$readSingleJsonObject = $jsonRootModule.ExportedCommands["Read-SingleJsonObject"]

function Get-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return (& $readSingleJsonObject -Path $Path -Label "Test JSON document")
}

function Write-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Document
    )

    $json = $Document | ConvertTo-Json -Depth 60
    Set-Content -LiteralPath $Path -Value $json -Encoding UTF8
}

function New-TestPacketCopy {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r10qa" + [guid]::NewGuid().ToString("N").Substring(0, 8))
    $packetDirectory = Join-Path $tempRoot $Label
    New-Item -ItemType Directory -Path $packetDirectory -Force | Out-Null
    $sourcePacketPath = Join-Path $repoRoot "state\external_runs\r10_external_proof_bundle\25040949422\qa\external_runner_consuming_qa_signoff.json"
    $packetPath = Join-Path $packetDirectory "external_runner_consuming_qa_signoff.json"
    Copy-Item -LiteralPath $sourcePacketPath -Destination $packetPath -Force
    return [pscustomobject]@{
        Root = $tempRoot
        PacketPath = $packetPath
    }
}

function Invoke-QaSignoffMutation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Mutation
    )

    $copy = New-TestPacketCopy -Label $Label
    try {
        $packet = Get-JsonDocument -Path $copy.PacketPath
        & $Mutation $packet $copy.Root
        Write-JsonDocument -Path $copy.PacketPath -Document $packet
        return $copy
    }
    catch {
        if (Test-Path -LiteralPath $copy.Root) {
            Remove-Item -LiteralPath $copy.Root -Recurse -Force
        }

        throw
    }
}

function Remove-TestPacketCopy {
    param(
        [Parameter(Mandatory = $true)]
        $Copy
    )

    if (Test-Path -LiteralPath $Copy.Root) {
        Remove-Item -LiteralPath $Copy.Root -Recurse -Force
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

function Invoke-MutatedPacketRefusal {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [string[]]$RequiredFragments,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Mutation
    )

    Invoke-ExpectedRefusal -Label $Label -RequiredFragments $RequiredFragments -Action {
        $copy = Invoke-QaSignoffMutation -Label $Label -Mutation $Mutation
        try {
            & $testExternalRunnerConsumingQaSignoff -PacketPath $copy.PacketPath | Out-Null
        }
        finally {
            Remove-TestPacketCopy -Copy $copy
        }
    }
}

function New-MutatedBundleCopy {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TempRoot,
        [Parameter(Mandatory = $true)]
        [scriptblock]$BundleMutation
    )

    $sourceBundleRoot = Join-Path $repoRoot "state\external_runs\r10_external_proof_bundle\25040949422\downloaded_artifact"
    $targetBundleRoot = Join-Path $TempRoot "downloaded_artifact_copy"
    Copy-Item -LiteralPath $sourceBundleRoot -Destination $targetBundleRoot -Recurse -Force
    $bundlePath = Join-Path $targetBundleRoot "external_proof_artifact_bundle.json"
    $bundle = Get-JsonDocument -Path $bundlePath
    & $BundleMutation $bundle
    Write-JsonDocument -Path $bundlePath -Document $bundle
    return $bundlePath
}

function New-MutatedIdentityCopy {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TempRoot,
        [Parameter(Mandatory = $true)]
        [scriptblock]$IdentityMutation
    )

    $sourceRunRoot = Join-Path $repoRoot "state\external_runs\r10_external_proof_bundle\25040949422"
    $targetRunRoot = Join-Path $TempRoot "run_copy"
    New-Item -ItemType Directory -Path $targetRunRoot -Force | Out-Null
    Copy-Item -Path (Join-Path $sourceRunRoot "*") -Destination $targetRunRoot -Recurse -Force
    $identityPath = Join-Path $targetRunRoot "external_runner_closeout_identity.json"
    $identity = Get-JsonDocument -Path $identityPath
    & $IdentityMutation $identity
    Write-JsonDocument -Path $identityPath -Document $identity
    return $identityPath
}

$validPassed = 0
$invalidRejected = 0
$failures = @()
$validPacket = Join-Path $repoRoot "state\external_runs\r10_external_proof_bundle\25040949422\qa\external_runner_consuming_qa_signoff.json"

try {
    $validResult = & $testExternalRunnerConsumingQaSignoff -PacketPath $validPacket
    Write-Output ("PASS valid external-runner-consuming QA signoff: {0} -> {1} run {2}" -f $validResult.PacketId, $validResult.Verdict, $validResult.ExternalRunId)
    $validPassed += 1

    Invoke-MutatedPacketRefusal -Label "missing-required-field" -RequiredFragments @("missing required field", "contract_version") -Mutation {
        param($packet, $tempRoot)
        $packet.PSObject.Properties.Remove("contract_version")
    }

    Invoke-MutatedPacketRefusal -Label "missing-qa-role-identity" -RequiredFragments @("qa_role_identity", "missing required field") -Mutation {
        param($packet, $tempRoot)
        $packet.PSObject.Properties.Remove("qa_role_identity")
    }

    Invoke-MutatedPacketRefusal -Label "missing-qa-runner-kind" -RequiredFragments @("qa_runner_kind", "missing required field") -Mutation {
        param($packet, $tempRoot)
        $packet.PSObject.Properties.Remove("qa_runner_kind")
    }

    Invoke-MutatedPacketRefusal -Label "missing-qa-authority-type" -RequiredFragments @("qa_authority_type", "missing required field") -Mutation {
        param($packet, $tempRoot)
        $packet.PSObject.Properties.Remove("qa_authority_type")
    }

    Invoke-MutatedPacketRefusal -Label "executor-self-certification-authority" -RequiredFragments @("qa_authority_type", "executor self-certification") -Mutation {
        param($packet, $tempRoot)
        $packet.qa_authority_type = "executor_self_certification"
    }

    Invoke-MutatedPacketRefusal -Label "missing-external-runner-identity-ref" -RequiredFragments @("external_runner_identity_ref", "missing required field") -Mutation {
        param($packet, $tempRoot)
        $packet.PSObject.Properties.Remove("external_runner_identity_ref")
    }

    Invoke-MutatedPacketRefusal -Label "missing-external-proof-bundle-ref" -RequiredFragments @("external_proof_bundle_ref", "missing required field") -Mutation {
        param($packet, $tempRoot)
        $packet.PSObject.Properties.Remove("external_proof_bundle_ref")
    }

    Invoke-MutatedPacketRefusal -Label "missing-artifact-retrieval-ref" -RequiredFragments @("artifact_retrieval_ref", "missing required field") -Mutation {
        param($packet, $tempRoot)
        $packet.PSObject.Properties.Remove("artifact_retrieval_ref")
    }

    Invoke-MutatedPacketRefusal -Label "missing-final-remote-head-support-ref" -RequiredFragments @("final_remote_head_support_ref", "missing required field") -Mutation {
        param($packet, $tempRoot)
        $packet.PSObject.Properties.Remove("final_remote_head_support_ref")
    }

    Invoke-MutatedPacketRefusal -Label "external-runner-identity-run-id-mismatch" -RequiredFragments @("external_runner_identity_ref", "25040949422") -Mutation {
        param($packet, $tempRoot)
        $identityPath = New-MutatedIdentityCopy -TempRoot $tempRoot -IdentityMutation {
            param($identity)
            $identity.run_id = "25040949423"
            $identity.run_url = "https://github.com/RodneyMuniz/AIOffice_V2/actions/runs/25040949423"
        }
        $packet.external_runner_identity_ref = $identityPath
    }

    Invoke-MutatedPacketRefusal -Label "external-runner-identity-conclusion-not-success" -RequiredFragments @("conclusion", "success") -Mutation {
        param($packet, $tempRoot)
        $identityPath = New-MutatedIdentityCopy -TempRoot $tempRoot -IdentityMutation {
            param($identity)
            $identity.conclusion = "failure"
        }
        $packet.external_runner_identity_ref = $identityPath
    }

    Invoke-MutatedPacketRefusal -Label "failed-run-25033063285-as-qa-proof" -RequiredFragments @("failed run evidence", "25033063285", "QA proof") -Mutation {
        param($packet, $tempRoot)
        $packet.external_runner_identity_ref = "state/external_runs/r10_external_proof_bundle/25033063285/external_runner_closeout_identity.json"
    }

    Invoke-MutatedPacketRefusal -Label "failed-run-25034566460-as-qa-proof" -RequiredFragments @("failed run evidence", "25034566460", "QA proof") -Mutation {
        param($packet, $tempRoot)
        $packet.external_runner_identity_ref = "state/external_runs/r10_external_proof_bundle/25034566460/external_runner_closeout_identity.json"
    }

    Invoke-MutatedPacketRefusal -Label "r9-004-limitation-as-qa-proof" -RequiredFragments @("R9-004 limitation", "QA proof") -Mutation {
        param($packet, $tempRoot)
        $packet.external_runner_identity_ref = "state/fixtures/valid/external_runner_artifact/external_runner_limitation.valid.json"
    }

    Invoke-MutatedPacketRefusal -Label "failed-external-proof-bundle-as-qa-proof" -RequiredFragments @("failed run evidence", "25034566460", "QA proof") -Mutation {
        param($packet, $tempRoot)
        $packet.external_proof_bundle_ref = "state/external_runs/r10_external_proof_bundle/25034566460/downloaded_artifact/external_proof_artifact_bundle.json"
    }

    Invoke-MutatedPacketRefusal -Label "external-proof-bundle-run-id-mismatch" -RequiredFragments @("run ID", "match identity") -Mutation {
        param($packet, $tempRoot)
        $bundlePath = New-MutatedBundleCopy -TempRoot $tempRoot -BundleMutation {
            param($bundle)
            $bundle.run_id = "25040949423"
            $bundle.run_url = "https://github.com/RodneyMuniz/AIOffice_V2/actions/runs/25040949423"
        }
        $packet.external_proof_bundle_ref = $bundlePath
    }

    Invoke-MutatedPacketRefusal -Label "external-proof-bundle-head-match-false" -RequiredFragments @("head_match", "passed") -Mutation {
        param($packet, $tempRoot)
        $bundlePath = New-MutatedBundleCopy -TempRoot $tempRoot -BundleMutation {
            param($bundle)
            $bundle.remote_head_sha = "0000000000000000000000000000000000000000"
            $bundle.head_match = $false
        }
        $packet.external_proof_bundle_ref = $bundlePath
    }

    Invoke-MutatedPacketRefusal -Label "external-proof-bundle-aggregate-not-passed" -RequiredFragments @("aggregate verdict", "passed") -Mutation {
        param($packet, $tempRoot)
        $bundlePath = New-MutatedBundleCopy -TempRoot $tempRoot -BundleMutation {
            param($bundle)
            $bundle.aggregate_verdict = "failed"
            $bundle.refusal_reasons = @("synthetic failed aggregate verdict for signoff validation")
        }
        $packet.external_proof_bundle_ref = $bundlePath
    }

    Invoke-MutatedPacketRefusal -Label "local-only-qa-source-artifact" -RequiredFragments @("local-only QA evidence", "R10 closeout QA") -Mutation {
        param($packet, $tempRoot)
        $packet.source_artifacts = @(
            [pscustomobject]@{
                artifact_ref = "state/external_runs/r10_external_proof_bundle/25040949422/artifact_retrieval_instructions.md"
                artifact_kind = "local_qa_evidence"
                authority_role = "consumed_external_runner_evidence"
                produced_by = "local-runner"
                notes = "Local-only QA evidence must not be R10 closeout QA."
            }
        )
    }

    Invoke-MutatedPacketRefusal -Label "executor-only-source-artifact" -RequiredFragments @("executor-only evidence", "QA authority") -Mutation {
        param($packet, $tempRoot)
        $packet.source_artifacts = @(
            [pscustomobject]@{
                artifact_ref = "state/external_runs/r10_external_proof_bundle/25040949422/artifact_retrieval_instructions.md"
                artifact_kind = "executor_evidence"
                authority_role = "consumed_external_runner_evidence"
                produced_by = "executor"
                notes = "Executor-only evidence must not be QA authority."
            }
        )
    }

    Invoke-MutatedPacketRefusal -Label "failed-run-source-artifact-disguised-as-allowed-kind" -RequiredFragments @("failed run evidence", "25033063285", "QA proof") -Mutation {
        param($packet, $tempRoot)
        $packet.source_artifacts = @(
            [pscustomobject]@{
                artifact_ref = "state/external_runs/r10_external_proof_bundle/25033063285/external_runner_closeout_identity.json"
                artifact_kind = "external_runner_identity"
                authority_role = "consumed_external_runner_evidence"
                produced_by = "github_actions:R10 External Proof Bundle"
                notes = "Failed run evidence must not be disguised as allowed source evidence."
            }
        )
    }

    Invoke-MutatedPacketRefusal -Label "r9-limitation-source-artifact-disguised-as-allowed-kind" -RequiredFragments @("R9-004 limitation", "QA proof") -Mutation {
        param($packet, $tempRoot)
        $packet.source_artifacts = @(
            [pscustomobject]@{
                artifact_ref = "state/fixtures/valid/external_runner_artifact/external_runner_limitation.valid.json"
                artifact_kind = "external_runner_identity"
                authority_role = "consumed_external_runner_evidence"
                produced_by = "github_actions:R10 External Proof Bundle"
                notes = "R9 limitation evidence must not be disguised as allowed source evidence."
            }
        )
    }

    Invoke-MutatedPacketRefusal -Label "executor-produced-source-artifact-as-qa-authority" -RequiredFragments @("executor-only evidence", "QA authority") -Mutation {
        param($packet, $tempRoot)
        $packet.source_artifacts = @(
            [pscustomobject]@{
                artifact_ref = "state/external_runs/r10_external_proof_bundle/25040949422/external_runner_closeout_identity.json"
                artifact_kind = "external_runner_identity"
                authority_role = "consumed_external_runner_evidence"
                produced_by = "executor"
                notes = "Executor-produced evidence must not become QA authority."
            }
        )
    }

    Invoke-MutatedPacketRefusal -Label "passed-verdict-with-refusal-reasons" -RequiredFragments @("refusal_reasons", "passed") -Mutation {
        param($packet, $tempRoot)
        $packet.refusal_reasons = @("unexpected refusal")
    }

    Invoke-MutatedPacketRefusal -Label "failed-verdict-without-refusal-reasons" -RequiredFragments @("refusal_reasons", "failed") -Mutation {
        param($packet, $tempRoot)
        $packet.verdict = "failed"
        $packet.refusal_reasons = @()
    }

    Invoke-MutatedPacketRefusal -Label "blocked-verdict-without-refusal-reasons" -RequiredFragments @("refusal_reasons", "blocked") -Mutation {
        param($packet, $tempRoot)
        $packet.verdict = "blocked"
        $packet.refusal_reasons = @()
    }

    Invoke-MutatedPacketRefusal -Label "missing-required-non-claim" -RequiredFragments @("non_claims", "no final-head clean replay claim") -Mutation {
        param($packet, $tempRoot)
        $packet.non_claims = @($packet.non_claims | Where-Object { $_ -ne "no final-head clean replay claim" })
    }

    Invoke-MutatedPacketRefusal -Label "same-executor-approves-signoff" -RequiredFragments @("same executor", "approved") -Mutation {
        param($packet, $tempRoot)
        $packet.independence_boundary.qa_identity = $packet.independence_boundary.executor_identity
        $packet.qa_role_identity = $packet.independence_boundary.executor_identity
        $packet.independence_boundary.statement = "The same executor produced and approved the signoff."
    }

    Invoke-MutatedPacketRefusal -Label "artifact-retrieval-missing-run-artifact" -RequiredFragments @("artifact retrieval", "run URL", "artifact name") -Mutation {
        param($packet, $tempRoot)
        $retrievalPath = Join-Path $tempRoot "bad_retrieval.md"
        Set-Content -LiteralPath $retrievalPath -Value "retrieval omitted" -Encoding UTF8
        $packet.artifact_retrieval_ref = $retrievalPath
    }
}
catch {
    $failures += ("FAIL external-runner-consuming QA signoff harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("External-runner-consuming QA signoff tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All external-runner-consuming QA signoff tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
