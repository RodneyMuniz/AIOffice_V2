$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17OrchestratorIdentityAuthority.psm1"
$module = Import-Module $modulePath -Force -PassThru
$newArtifacts = $module.ExportedCommands["New-R17OrchestratorIdentityAuthorityArtifacts"]
$testArtifacts = $module.ExportedCommands["Test-R17OrchestratorIdentityAuthorityArtifacts"]
$testFixtures = $module.ExportedCommands["Test-R17OrchestratorIdentityAuthorityFixtures"]

$failures = @()

try {
    $generation = & $newArtifacts -RepositoryRoot $repoRoot
    if ($generation.aggregate_verdict -ne "generated_r17_orchestrator_identity_authority_candidate") {
        $failures += "generation aggregate verdict was '$($generation.aggregate_verdict)'."
    }
}
catch {
    $failures += "generation failed: $($_.Exception.Message)"
}

try {
    $validation = & $testArtifacts -RepositoryRoot $repoRoot
    if ($validation.aggregate_verdict -ne "generated_r17_orchestrator_identity_authority_candidate") {
        $failures += "validation aggregate verdict was '$($validation.aggregate_verdict)'."
    }
    if ($validation.recommended_next_action -ne "request_user_review_or_closure_decision") {
        $failures += "route seed recommended next action was '$($validation.recommended_next_action)'."
    }
    foreach ($falseField in @(
            "board_mutation_performed",
            "agent_invocation_performed",
            "a2a_message_sent",
            "api_call_performed",
            "dev_output_claimed",
            "qa_result_claimed",
            "audit_verdict_claimed"
        )) {
        if ($validation.$falseField -ne $false) {
            $failures += "route seed field '$falseField' must be false."
        }
    }
}
catch {
    $failures += "live artifact validation failed: $($_.Exception.Message)"
}

try {
    $fixtureValidation = & $testFixtures -RepositoryRoot $repoRoot
    if ($fixtureValidation.invalid_fixtures_rejected -lt 37) {
        $failures += "expected at least 37 invalid fixtures to be rejected, got $($fixtureValidation.invalid_fixtures_rejected)."
    }
}
catch {
    $failures += "fixture validation failed: $($_.Exception.Message)"
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output ("FAIL: {0}" -f $_) }
    throw ("R17 Orchestrator identity/authority tests failed with {0} failure(s)." -f $failures.Count)
}

Write-Output "All R17 Orchestrator identity/authority tests passed."
