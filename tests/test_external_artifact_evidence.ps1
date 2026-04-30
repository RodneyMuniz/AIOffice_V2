$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\ExternalArtifactEvidence.psm1") -Force -PassThru
$testPacket = $module.ExportedCommands["Test-ExternalArtifactEvidencePacket"]

$validRoot = Join-Path $repoRoot "state\fixtures\valid\external_artifact_evidence"
$invalidRoot = Join-Path $repoRoot "state\fixtures\invalid\external_artifact_evidence"
$validPassed = 0
$invalidRejected = 0
$failures = @()

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

try {
    $external = & $testPacket -PacketPath (Join-Path $validRoot "external_artifact_evidence.github.valid.json")
    if (-not $external.ExternalEvidenceClaim -or $external.AggregateVerdict -ne "passed") {
        $failures += "FAIL valid: external artifact evidence fixture did not validate as external passed evidence shape."
    }
    else {
        Write-Output ("PASS valid imported external evidence fixture: {0}" -f $external.EvidencePacketId)
        $validPassed += 1
    }

    $local = & $testPacket -PacketPath (Join-Path $validRoot "external_artifact_evidence.local-only.valid.json")
    if ($local.ExternalEvidenceClaim -or $local.ArtifactSourceKind -ne "local_artifact_zip") {
        $failures += "FAIL valid: local-only normalization fixture was mislabeled as external evidence."
    }
    else {
        Write-Output ("PASS valid local-only normalization fixture: {0}" -f $local.EvidencePacketId)
        $validPassed += 1
    }

    Invoke-ExpectedRefusal -Label "invalid-head-mismatch" -RequiredFragments @("head/tree", "match for pass") -Action {
        & $testPacket -PacketPath (Join-Path $invalidRoot "external_artifact_evidence.head-mismatch.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-failed-replay-as-pass" -RequiredFragments @("failed replay bundle", "passed evidence") -Action {
        & $testPacket -PacketPath (Join-Path $invalidRoot "external_artifact_evidence.failed-replay-as-pass.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-path-traversal" -RequiredFragments @("path traversal", "rejected") -Action {
        & $testPacket -PacketPath (Join-Path $invalidRoot "external_artifact_evidence.path-traversal.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-run-artifact-identity" -RequiredFragments @("run_id", "non-empty string") -Action {
        & $testPacket -PacketPath (Join-Path $invalidRoot "external_artifact_evidence.missing-run-artifact-identity.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-missing-non-claims" -RequiredFragments @("non_claims", "no R12 value-gate delivery yet") -Action {
        & $testPacket -PacketPath (Join-Path $invalidRoot "external_artifact_evidence.missing-non-claims.invalid.json") | Out-Null
    }
}
catch {
    $failures += ("FAIL external artifact evidence harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("External artifact evidence tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All external artifact evidence tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
