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

Import-Module (Join-PathSegments -Segments @($repoRoot, "tools", "ExternalProofArtifactBundle.psm1")) -Force
$testExternalProofArtifactBundle = Get-Command -Name "Test-ExternalProofArtifactBundleContract" -ErrorAction Stop

function Assert-SingleJsonRootObject {
    param(
        [AllowNull()]
        $Document,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    if ($null -eq $Document) {
        throw "$Label root did not load as a single JSON object; it was null."
    }

    if ($Document -is [System.Array]) {
        throw "$Label root did not load as a single JSON object; it loaded as an array/property stream."
    }

    if ($Document -isnot [pscustomobject]) {
        throw "$Label root did not load as a single JSON object; it loaded as '$($Document.GetType().FullName)'."
    }
}

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

    $document = [System.IO.File]::ReadAllText($Path) | ConvertFrom-Json
    Assert-SingleJsonRootObject -Document $document -Label $Path
    Write-Output -NoEnumerate $document
}

function Write-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Document
    )

    $json = $Document | ConvertTo-Json -Depth 40
    Set-Content -LiteralPath $Path -Value $json -Encoding UTF8
}

function New-ExternalProofBundleFixtureRoot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r10externalproofbundle" + [guid]::NewGuid().ToString("N").Substring(0, 8))
    $sourceRoot = Join-PathSegments -Segments @($repoRoot, "state", "fixtures", "valid", "external_proof_bundle")
    $fixtureRoot = Join-Path $tempRoot $Label
    New-Item -ItemType Directory -Path $fixtureRoot -Force | Out-Null
    Get-ChildItem -LiteralPath $sourceRoot | Copy-Item -Destination $fixtureRoot -Recurse -Force
    return $fixtureRoot
}

function Invoke-ExternalProofBundleMutation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Mutation
    )

    $fixtureRoot = New-ExternalProofBundleFixtureRoot -Label $Label

    try {
        $bundlePath = Join-Path $fixtureRoot "external_proof_artifact_bundle.valid.json"
        $bundle = Get-JsonDocument -Path $bundlePath
        & $Mutation $bundle $fixtureRoot
        Write-JsonDocument -Path $bundlePath -Document $bundle
        return $bundlePath
    }
    catch {
        if (Test-Path -LiteralPath $fixtureRoot) {
            Remove-Item -LiteralPath $fixtureRoot -Recurse -Force
        }

        throw
    }
}

function Remove-FixtureForBundle {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BundlePath
    )

    $fixtureRoot = Split-Path -Parent $BundlePath
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
        $bundlePath = Invoke-ExternalProofBundleMutation -Label $Label -Mutation $Mutation
        try {
            & $testExternalProofArtifactBundle -BundlePath $bundlePath | Out-Null
        }
        finally {
            Remove-FixtureForBundle -BundlePath $bundlePath
        }
    }
}

$validPassed = 0
$invalidRejected = 0
$failures = @()
$validFixture = Join-PathSegments -Segments @($repoRoot, "state", "fixtures", "valid", "external_proof_bundle", "external_proof_artifact_bundle.valid.json")

try {
    $validFixtureDocument = Get-JsonDocument -Path $validFixture
    Assert-ContractVersionVisible -Document $validFixtureDocument -Label "Valid repository fixture"

    $copiedFixtureRoot = New-ExternalProofBundleFixtureRoot -Label "cross-platform-fixture-copy"
    try {
        $copiedFixturePath = Join-Path $copiedFixtureRoot "external_proof_artifact_bundle.valid.json"
        $copiedFixtureDocument = Get-JsonDocument -Path $copiedFixturePath
        Assert-ContractVersionVisible -Document $copiedFixtureDocument -Label "Copied temp fixture"
    }
    finally {
        Remove-FixtureForBundle -BundlePath (Join-Path $copiedFixtureRoot "external_proof_artifact_bundle.valid.json")
    }

    Invoke-ExpectedRefusal -Label "array-root-json-document" -RequiredFragments @("single JSON object", "array/property stream") -Action {
        $arrayRootPath = Join-Path ([System.IO.Path]::GetTempPath()) ("r10externalproofbundle-array-root-" + [guid]::NewGuid().ToString("N") + ".json")
        try {
            Set-Content -LiteralPath $arrayRootPath -Value '[{"contract_version":"v1"}]' -Encoding UTF8
            & $testExternalProofArtifactBundle -BundlePath $arrayRootPath | Out-Null
        }
        finally {
            if (Test-Path -LiteralPath $arrayRootPath) {
                Remove-Item -LiteralPath $arrayRootPath -Force
            }
        }
    }

    $validResult = & $testExternalProofArtifactBundle -BundlePath $validFixture
    if (-not $validResult.IsPassingBundleShape -or $validResult.CommandCount -ne 1) {
        $failures += "FAIL valid: validator-only external proof bundle shape did not validate as a passing bundle shape."
    }
    else {
        Write-Output ("PASS valid validator-only bundle shape: {0} -> {1} with {2} command(s)" -f $validResult.BundleId, $validResult.AggregateVerdict, $validResult.CommandCount)
        $validPassed += 1
    }

    $failedBundlePath = Invoke-ExternalProofBundleMutation -Label "valid-failed-bundle-shape" -Mutation {
        param($bundle)
        $bundle.bundle_id = "r10-003-external-proof-bundle-validator-failed-shape"
        $bundle.aggregate_verdict = "failed"
        $bundle.refusal_reasons = @("validator-only failed bundle shape")
        $commandResult = @($bundle.command_results)[0]
        $commandResult.verdict = "failed"
        $commandResult.exit_code = 1
    }
    try {
        $failedResult = & $testExternalProofArtifactBundle -BundlePath $failedBundlePath
        if ($failedResult.IsPassingBundleShape) {
            $failures += "FAIL valid: failed bundle shape was incorrectly marked as passing."
        }
        else {
            Write-Output ("PASS valid failed bundle shape: {0} -> {1}" -f $failedResult.BundleId, $failedResult.AggregateVerdict)
            $validPassed += 1
        }
    }
    finally {
        Remove-FixtureForBundle -BundlePath $failedBundlePath
    }

    Invoke-MutatedRefusal -Label "missing-required-field" -RequiredFragments @("missing required field", "bundle_id") -Mutation {
        param($bundle)
        $bundle.PSObject.Properties.Remove("bundle_id")
    }

    Invoke-MutatedRefusal -Label "wrong-repository" -RequiredFragments @("repository", "AIOffice_V2") -Mutation {
        param($bundle)
        $bundle.repository = "OtherRepo"
    }

    Invoke-MutatedRefusal -Label "wrong-branch" -RequiredFragments @("branch", "release/r10-real-external-runner-proof-foundation") -Mutation {
        param($bundle)
        $bundle.branch = "feature/r5-closeout-remaining-foundations"
    }

    Invoke-MutatedRefusal -Label "empty-run-id" -RequiredFragments @("run_id", "non-empty string") -Mutation {
        param($bundle)
        $bundle.run_id = ""
    }

    Invoke-MutatedRefusal -Label "empty-run-url" -RequiredFragments @("run_url", "non-empty string") -Mutation {
        param($bundle)
        $bundle.run_url = ""
    }

    Invoke-MutatedRefusal -Label "github-actions-run-url-not-concrete" -RequiredFragments @("run_url", "required pattern") -Mutation {
        param($bundle)
        $bundle.run_url = "https://example.invalid/not-a-github-actions-run"
    }

    Invoke-MutatedRefusal -Label "missing-workflow-name" -RequiredFragments @("workflow_name", "non-empty string") -Mutation {
        param($bundle)
        $bundle.workflow_name = ""
    }

    Invoke-MutatedRefusal -Label "missing-workflow-ref" -RequiredFragments @("workflow_ref", "non-empty string") -Mutation {
        param($bundle)
        $bundle.workflow_ref = ""
    }

    Invoke-MutatedRefusal -Label "empty-artifact-name" -RequiredFragments @("artifact_name", "non-empty string") -Mutation {
        param($bundle)
        $bundle.artifact_name = ""
    }

    Invoke-MutatedRefusal -Label "empty-retrieval-instruction" -RequiredFragments @("artifact_url_or_retrieval_instruction", "non-empty string") -Mutation {
        param($bundle)
        $bundle.artifact_url_or_retrieval_instruction = ""
    }

    Invoke-MutatedRefusal -Label "malformed-remote-head-sha" -RequiredFragments @("remote_head_sha", "required pattern") -Mutation {
        param($bundle)
        $bundle.remote_head_sha = "not-a-sha"
    }

    Invoke-MutatedRefusal -Label "malformed-tested-head-sha" -RequiredFragments @("tested_head_sha", "required pattern") -Mutation {
        param($bundle)
        $bundle.tested_head_sha = "not-a-sha"
    }

    Invoke-MutatedRefusal -Label "malformed-tested-tree-sha" -RequiredFragments @("tested_tree_sha", "required pattern") -Mutation {
        param($bundle)
        $bundle.tested_tree_sha = "not-a-sha"
    }

    Invoke-MutatedRefusal -Label "passed-head-match-false" -RequiredFragments @("head_match", "passed") -Mutation {
        param($bundle)
        $bundle.head_match = $false
        $bundle.remote_head_sha = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    }

    Invoke-MutatedRefusal -Label "head-match-true-with-sha-mismatch" -RequiredFragments @("head_match true", "remote_head_sha", "tested_head_sha") -Mutation {
        param($bundle)
        $bundle.remote_head_sha = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    }

    Invoke-MutatedRefusal -Label "missing-clean-status-before" -RequiredFragments @("missing required field", "clean_status_before") -Mutation {
        param($bundle)
        $bundle.PSObject.Properties.Remove("clean_status_before")
    }

    Invoke-MutatedRefusal -Label "missing-clean-status-after-evidence" -RequiredFragments @("clean_status_after evidence_ref", "non-empty string") -Mutation {
        param($bundle)
        $bundle.clean_status_after.evidence_ref = ""
    }

    Invoke-MutatedRefusal -Label "missing-command-manifest-ref" -RequiredFragments @("command_manifest_ref", "non-empty string") -Mutation {
        param($bundle)
        $bundle.command_manifest_ref = ""
    }

    Invoke-MutatedRefusal -Label "command-manifest-ref-does-not-resolve" -RequiredFragments @("command_manifest_ref", "does not exist") -Mutation {
        param($bundle)
        $bundle.command_manifest_ref = "artifacts/missing_command_manifest.json"
    }

    Invoke-MutatedRefusal -Label "empty-command-results" -RequiredFragments @("command_results", "must not be empty") -Mutation {
        param($bundle)
        $bundle.command_results = @()
    }

    Invoke-MutatedRefusal -Label "command-result-missing-stdout-ref" -RequiredFragments @("stdout_ref", "non-empty string") -Mutation {
        param($bundle)
        $commandResult = @($bundle.command_results)[0]
        $commandResult.stdout_ref = ""
    }

    Invoke-MutatedRefusal -Label "command-result-missing-stderr-ref" -RequiredFragments @("stderr_ref", "non-empty string") -Mutation {
        param($bundle)
        $commandResult = @($bundle.command_results)[0]
        $commandResult.stderr_ref = ""
    }

    Invoke-MutatedRefusal -Label "command-result-missing-exit-code-ref" -RequiredFragments @("exit_code_ref", "non-empty string") -Mutation {
        param($bundle)
        $commandResult = @($bundle.command_results)[0]
        $commandResult.exit_code_ref = ""
    }

    Invoke-MutatedRefusal -Label "command-result-stdout-ref-does-not-resolve" -RequiredFragments @("stdout_ref", "does not exist") -Mutation {
        param($bundle)
        $commandResult = @($bundle.command_results)[0]
        $commandResult.stdout_ref = "artifacts/missing_stdout.log"
    }

    Invoke-MutatedRefusal -Label "invalid-aggregate-verdict" -RequiredFragments @("aggregate_verdict", "passed, failed, blocked") -Mutation {
        param($bundle)
        $bundle.aggregate_verdict = "successful"
    }

    Invoke-MutatedRefusal -Label "passed-aggregate-with-failed-command" -RequiredFragments @("aggregate_verdict 'passed'", "every command result verdict") -Mutation {
        param($bundle)
        $commandResult = @($bundle.command_results)[0]
        $commandResult.verdict = "failed"
        $commandResult.exit_code = 1
    }

    Invoke-MutatedRefusal -Label "passed-aggregate-with-refusal-reasons" -RequiredFragments @("aggregate_verdict 'passed'", "refusal_reasons", "empty") -Mutation {
        param($bundle)
        $bundle.refusal_reasons = @("validator-only refusal should block a passed aggregate verdict")
    }

    Invoke-MutatedRefusal -Label "failed-aggregate-without-refusal-reasons" -RequiredFragments @("aggregate_verdict 'failed'", "refusal_reasons", "non-empty") -Mutation {
        param($bundle)
        $bundle.aggregate_verdict = "failed"
        $commandResult = @($bundle.command_results)[0]
        $commandResult.verdict = "failed"
        $commandResult.exit_code = 1
        $bundle.refusal_reasons = @()
    }

    Invoke-MutatedRefusal -Label "missing-required-non-claim" -RequiredFragments @("non_claims", "no solved Codex context compaction") -Mutation {
        param($bundle)
        $bundle.non_claims = @($bundle.non_claims | Where-Object { $_ -ne "no solved Codex context compaction" })
    }

    Invoke-MutatedRefusal -Label "broad-ci-product-coverage-claim" -RequiredFragments @("broad CI/product coverage") -Mutation {
        param($bundle)
        $bundle.artifact_url_or_retrieval_instruction = "production-grade CI product coverage is complete in this bundle."
    }

    Invoke-MutatedRefusal -Label "standard-runtime-claim" -RequiredFragments @("Standard runtime", "general Codex reliability") -Mutation {
        param($bundle)
        $bundle.artifact_url_or_retrieval_instruction = "Standard runtime proof is complete in this bundle."
    }
}
catch {
    $failures += ("FAIL external proof artifact bundle harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("External proof artifact bundle tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All external proof artifact bundle tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
