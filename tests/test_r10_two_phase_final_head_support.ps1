$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R10TwoPhaseFinalHeadSupport.psm1") -Force -PassThru
$testR10TwoPhaseFinalHeadSupport = $module.ExportedCommands["Test-R10TwoPhaseFinalHeadSupportContract"]

function Get-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Write-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Document
    )

    $json = $Document | ConvertTo-Json -Depth 80
    Set-Content -LiteralPath $Path -Value $json -Encoding UTF8
}

function New-ProcedureCopy {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r10twophase" + [guid]::NewGuid().ToString("N").Substring(0, 8))
    $procedureDirectory = Join-Path $tempRoot $Label
    New-Item -ItemType Directory -Path $procedureDirectory -Force | Out-Null
    $sourceProcedurePath = Join-Path $repoRoot "state\fixtures\valid\post_push_support\r10_two_phase_final_head_closeout_procedure.valid.json"
    $procedurePath = Join-Path $procedureDirectory "r10_two_phase_final_head_closeout_procedure.valid.json"
    Copy-Item -LiteralPath $sourceProcedurePath -Destination $procedurePath -Force
    return [pscustomobject]@{
        Root = $tempRoot
        ProcedurePath = $procedurePath
    }
}

function Remove-ProcedureCopy {
    param(
        [Parameter(Mandatory = $true)]
        $Copy
    )

    if (Test-Path -LiteralPath $Copy.Root) {
        Remove-Item -LiteralPath $Copy.Root -Recurse -Force
    }
}

function Invoke-ProcedureMutation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Mutation
    )

    $copy = New-ProcedureCopy -Label $Label
    try {
        $procedure = Get-JsonDocument -Path $copy.ProcedurePath
        & $Mutation $procedure $copy.Root
        Write-JsonDocument -Path $copy.ProcedurePath -Document $procedure
        return $copy
    }
    catch {
        Remove-ProcedureCopy -Copy $copy
        throw
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

function Invoke-MutatedProcedureRefusal {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [string[]]$RequiredFragments,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Mutation
    )

    Invoke-ExpectedRefusal -Label $Label -RequiredFragments $RequiredFragments -Action {
        $copy = Invoke-ProcedureMutation -Label $Label -Mutation $Mutation
        try {
            & $testR10TwoPhaseFinalHeadSupport -ProcedurePath $copy.ProcedurePath | Out-Null
        }
        finally {
            Remove-ProcedureCopy -Copy $copy
        }
    }
}

function New-MutatedQaSignoff {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TempRoot
    )

    $sourceQaPath = Join-Path $repoRoot "state\external_runs\r10_external_proof_bundle\25040949422\qa\external_runner_consuming_qa_signoff.json"
    $targetQaPath = Join-Path $TempRoot "mutated_qa_signoff.json"
    Copy-Item -LiteralPath $sourceQaPath -Destination $targetQaPath -Force
    $qa = Get-JsonDocument -Path $targetQaPath
    $qa.verdict = "blocked"
    $qa.refusal_reasons = @("synthetic blocked QA signoff for R10-007 validation")
    Write-JsonDocument -Path $targetQaPath -Document $qa
    return $targetQaPath
}

$validPassed = 0
$invalidRejected = 0
$failures = @()
$validProcedure = Join-Path $repoRoot "state\fixtures\valid\post_push_support\r10_two_phase_final_head_closeout_procedure.valid.json"

try {
    $validResult = & $testR10TwoPhaseFinalHeadSupport -ProcedurePath $validProcedure
    Write-Output ("PASS valid R10 two-phase final-head support procedure: {0} -> run {1}, bundle {2}, QA {3}" -f $validResult.ProcedureId, $validResult.ExternalRunId, $validResult.BundleVerdict, $validResult.QaVerdict)
    $validPassed += 1

    Invoke-MutatedProcedureRefusal -Label "missing-required-field" -RequiredFragments @("missing required field", "contract_version") -Mutation {
        param($procedure, $tempRoot)
        $procedure.PSObject.Properties.Remove("contract_version")
    }

    Invoke-MutatedProcedureRefusal -Label "wrong-branch" -RequiredFragments @("branch", "release/r10-real-external-runner-proof-foundation") -Mutation {
        param($procedure, $tempRoot)
        $procedure.branch = "feature/r5-closeout-remaining-foundations"
    }

    Invoke-MutatedProcedureRefusal -Label "wrong-source-task" -RequiredFragments @("source_task", "R10-007") -Mutation {
        param($procedure, $tempRoot)
        $procedure.source_task = "R10-008"
    }

    Invoke-MutatedProcedureRefusal -Label "missing-candidate-closeout-commit-ref" -RequiredFragments @("candidate_closeout_commit_ref", "missing required field") -Mutation {
        param($procedure, $tempRoot)
        $procedure.PSObject.Properties.Remove("candidate_closeout_commit_ref")
    }

    Invoke-MutatedProcedureRefusal -Label "missing-candidate-closeout-tree-ref" -RequiredFragments @("candidate_closeout_tree_ref", "missing required field") -Mutation {
        param($procedure, $tempRoot)
        $procedure.PSObject.Properties.Remove("candidate_closeout_tree_ref")
    }

    Invoke-MutatedProcedureRefusal -Label "missing-external-runner-identity-ref" -RequiredFragments @("external_runner_identity_ref", "missing required field") -Mutation {
        param($procedure, $tempRoot)
        $procedure.PSObject.Properties.Remove("external_runner_identity_ref")
    }

    Invoke-MutatedProcedureRefusal -Label "missing-external-proof-bundle-ref" -RequiredFragments @("external_proof_bundle_ref", "missing required field") -Mutation {
        param($procedure, $tempRoot)
        $procedure.PSObject.Properties.Remove("external_proof_bundle_ref")
    }

    Invoke-MutatedProcedureRefusal -Label "missing-external-runner-consuming-qa-signoff-ref" -RequiredFragments @("external_runner_consuming_qa_signoff_ref", "missing required field") -Mutation {
        param($procedure, $tempRoot)
        $procedure.PSObject.Properties.Remove("external_runner_consuming_qa_signoff_ref")
    }

    Invoke-MutatedProcedureRefusal -Label "external-runner-identity-not-successful-required-run" -RequiredFragments @("external runner identity", "25040949422") -Mutation {
        param($procedure, $tempRoot)
        $procedure.external_runner_identity_ref = "state/external_runs/r10_external_proof_bundle/25033063285/external_runner_closeout_identity.json"
    }

    Invoke-MutatedProcedureRefusal -Label "external-proof-bundle-not-passed" -RequiredFragments @("external proof bundle aggregate verdict", "passed") -Mutation {
        param($procedure, $tempRoot)
        $procedure.external_proof_bundle_ref = "state/external_runs/r10_external_proof_bundle/25034566460/downloaded_artifact/external_proof_artifact_bundle.json"
    }

    Invoke-MutatedProcedureRefusal -Label "qa-signoff-not-passed" -RequiredFragments @("QA signoff verdict", "passed") -Mutation {
        param($procedure, $tempRoot)
        $procedure.external_runner_consuming_qa_signoff_ref = New-MutatedQaSignoff -TempRoot $tempRoot
    }

    Invoke-MutatedProcedureRefusal -Label "post-push-final-head-support-not-required" -RequiredFragments @("post-push final-head support", "required") -Mutation {
        param($procedure, $tempRoot)
        $procedure.post_push_final_head_support_required = $false
    }

    Invoke-MutatedProcedureRefusal -Label "claims-final-head-clean-replay-complete" -RequiredFragments @("final-head clean replay", "already complete") -Mutation {
        param($procedure, $tempRoot)
        $procedure.final_acceptance_conditions += "final-head clean replay is already complete"
    }

    Invoke-MutatedProcedureRefusal -Label "claims-r10-closed" -RequiredFragments @("R10", "already closed") -Mutation {
        param($procedure, $tempRoot)
        $procedure.final_acceptance_conditions += "R10 is already closed"
    }

    Invoke-MutatedProcedureRefusal -Label "allows-same-commit-self-referential-proof" -RequiredFragments @("same-commit", "self-referential") -Mutation {
        param($procedure, $tempRoot)
        $procedure.post_push_support_commit_policy.same_commit_self_referential_proof_allowed = $true
    }

    Invoke-MutatedProcedureRefusal -Label "allows-closeout-without-support" -RequiredFragments @("closeout", "without", "support") -Mutation {
        param($procedure, $tempRoot)
        $procedure.post_push_support_commit_policy.closeout_without_support_allowed = $true
    }

    Invoke-MutatedProcedureRefusal -Label "omits-support-publication-mode" -RequiredFragments @("follow-up support commit", "external artifact identity") -Mutation {
        param($procedure, $tempRoot)
        $procedure.post_push_support_commit_policy.allowed_publication_modes = @()
    }

    Invoke-MutatedProcedureRefusal -Label "final-acceptance-omits-external-proof" -RequiredFragments @("final_acceptance_conditions", "successful external proof run identity exists") -Mutation {
        param($procedure, $tempRoot)
        $procedure.final_acceptance_conditions = @($procedure.final_acceptance_conditions | Where-Object { $_ -ne "successful external proof run identity exists" })
    }

    Invoke-MutatedProcedureRefusal -Label "final-acceptance-omits-qa-signoff" -RequiredFragments @("final_acceptance_conditions", "QA signoff verdict") -Mutation {
        param($procedure, $tempRoot)
        $procedure.final_acceptance_conditions = @($procedure.final_acceptance_conditions | Where-Object { $_ -ne 'external-runner-consuming QA signoff verdict is `passed`' })
    }

    Invoke-MutatedProcedureRefusal -Label "final-acceptance-omits-post-push-support" -RequiredFragments @("final_acceptance_conditions", "post-push final-head support packet verifies the final closeout head") -Mutation {
        param($procedure, $tempRoot)
        $procedure.final_acceptance_conditions = @($procedure.final_acceptance_conditions | Where-Object { $_ -ne "post-push final-head support packet verifies the final closeout head" })
    }

    Invoke-MutatedProcedureRefusal -Label "final-acceptance-omits-status-doc-gate" -RequiredFragments @("final_acceptance_conditions", "status-doc gate passes") -Mutation {
        param($procedure, $tempRoot)
        $procedure.final_acceptance_conditions = @($procedure.final_acceptance_conditions | Where-Object { $_ -ne "status-doc gate passes" })
    }

    Invoke-MutatedProcedureRefusal -Label "final-acceptance-omits-non-claims" -RequiredFragments @("final_acceptance_conditions", "R10 non-claims are preserved") -Mutation {
        param($procedure, $tempRoot)
        $procedure.final_acceptance_conditions = @($procedure.final_acceptance_conditions | Where-Object { $_ -ne "R10 non-claims are preserved" })
    }

    Invoke-MutatedProcedureRefusal -Label "refusal-omits-missing-external-proof" -RequiredFragments @("refusal_conditions", "missing successful external proof identity") -Mutation {
        param($procedure, $tempRoot)
        $procedure.refusal_conditions = @($procedure.refusal_conditions | Where-Object { $_ -ne "missing successful external proof identity" })
    }

    Invoke-MutatedProcedureRefusal -Label "refusal-omits-failed-qa-signoff" -RequiredFragments @("refusal_conditions", "missing or failed external-runner-consuming QA signoff") -Mutation {
        param($procedure, $tempRoot)
        $procedure.refusal_conditions = @($procedure.refusal_conditions | Where-Object { $_ -ne "missing or failed external-runner-consuming QA signoff" })
    }

    Invoke-MutatedProcedureRefusal -Label "refusal-omits-missing-post-push-support" -RequiredFragments @("refusal_conditions", "missing post-push final-head support") -Mutation {
        param($procedure, $tempRoot)
        $procedure.refusal_conditions = @($procedure.refusal_conditions | Where-Object { $_ -ne "missing post-push final-head support" })
    }

    Invoke-MutatedProcedureRefusal -Label "refusal-omits-self-referential-proof" -RequiredFragments @("refusal_conditions", "self-referential final-head proof") -Mutation {
        param($procedure, $tempRoot)
        $procedure.refusal_conditions = @($procedure.refusal_conditions | Where-Object { $_ -ne "self-referential final-head proof" })
    }

    Invoke-MutatedProcedureRefusal -Label "refusal-omits-status-doc-drift" -RequiredFragments @("refusal_conditions", "status-doc drift") -Mutation {
        param($procedure, $tempRoot)
        $procedure.refusal_conditions = @($procedure.refusal_conditions | Where-Object { $_ -ne "status-doc drift" })
    }

    Invoke-MutatedProcedureRefusal -Label "missing-required-non-claim" -RequiredFragments @("non_claims", "no completed final-head clean replay claim") -Mutation {
        param($procedure, $tempRoot)
        $procedure.non_claims = @($procedure.non_claims | Where-Object { $_ -ne "no completed final-head clean replay claim" })
    }
}
catch {
    $failures += ("FAIL R10 two-phase final-head support harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R10 two-phase final-head support tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R10 two-phase final-head support tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
