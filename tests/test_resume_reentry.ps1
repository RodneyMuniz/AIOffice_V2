$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot

$workArtifactValidationModule = Import-Module (Join-Path $repoRoot "tools\WorkArtifactValidation.psm1") -Force -PassThru
$qaGateModule = Import-Module (Join-Path $repoRoot "tools\ExecutionBundleQaGate.psm1") -Force -PassThru
$batonPersistenceModule = Import-Module (Join-Path $repoRoot "tools\BatonPersistence.psm1") -Force -PassThru
$resumeReentryModule = Import-Module (Join-Path $repoRoot "tools\ResumeReentry.psm1") -Force -PassThru
$milestoneBaselineModule = Import-Module (Join-Path $repoRoot "tools\MilestoneBaseline.psm1") -Force -PassThru

$testWorkArtifactContract = $workArtifactValidationModule.ExportedCommands["Test-WorkArtifactContract"]
$testBatonRecordContract = $batonPersistenceModule.ExportedCommands["Test-BatonRecordContract"]
$invokeExecutionBundleQaGate = $qaGateModule.ExportedCommands["Invoke-ExecutionBundleQaGate"]
$newBatonFromQaOutcome = $batonPersistenceModule.ExportedCommands["New-BatonFromQaOutcome"]
$saveBatonRecord = $batonPersistenceModule.ExportedCommands["Save-BatonRecord"]
$invokeResumeReentry = $resumeReentryModule.ExportedCommands["Invoke-ResumeReentry"]
$testResumeReentryResultContract = $resumeReentryModule.ExportedCommands["Test-ResumeReentryResultContract"]
$newMilestoneBaselineRecord = $milestoneBaselineModule.ExportedCommands["New-MilestoneBaselineRecord"]
$saveMilestoneBaselineRecord = $milestoneBaselineModule.ExportedCommands["Save-MilestoneBaselineRecord"]

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

    $json = $Document | ConvertTo-Json -Depth 20
    Set-Content -LiteralPath $Path -Value $json -Encoding UTF8
}

function Resolve-ArtifactReferencePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArtifactPath,
        [Parameter(Mandatory = $true)]
        [string]$Reference
    )

    $baseDirectory = Split-Path -Parent $ArtifactPath
    if ([System.IO.Path]::IsPathRooted($Reference)) {
        return (Resolve-Path -LiteralPath $Reference).Path
    }

    return (Resolve-Path -LiteralPath (Join-Path $baseDirectory ($Reference -replace "[/\\]", [System.IO.Path]::DirectorySeparatorChar))).Path
}

function Get-PathRelativeToRepositoryRoot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $resolvedRepositoryRoot = (Resolve-Path -LiteralPath $repoRoot).Path
    $resolvedPath = if (Test-Path -LiteralPath $Path) {
        (Resolve-Path -LiteralPath $Path).Path
    }
    else {
        [System.IO.Path]::GetFullPath($Path)
    }

    $repositoryUri = [System.Uri]("{0}{1}" -f $resolvedRepositoryRoot.TrimEnd("\/"), [System.IO.Path]::DirectorySeparatorChar)
    $pathUri = [System.Uri]$resolvedPath
    return $repositoryUri.MakeRelativeUri($pathUri).OriginalString
}

function Get-PathRelativeToBaseDirectory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory,
        [Parameter(Mandatory = $true)]
        [string]$TargetPath
    )

    $resolvedBaseDirectory = (Resolve-Path -LiteralPath $BaseDirectory).Path
    $resolvedTargetPath = (Resolve-Path -LiteralPath $TargetPath).Path
    $baseUri = [System.Uri]("{0}{1}" -f $resolvedBaseDirectory.TrimEnd("\/"), [System.IO.Path]::DirectorySeparatorChar)
    $targetUri = [System.Uri]$resolvedTargetPath
    return $baseUri.MakeRelativeUri($targetUri).OriginalString
}

function Initialize-TemporaryGitRepository {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    & git -C $Path init --initial-branch main 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to initialize temporary Git repository at '$Path'."
    }

    & git -C $Path config user.email "codex@example.com" 2>$null | Out-Null
    & git -C $Path config user.name "Codex Test" 2>$null | Out-Null
    & git -C $Path config core.autocrlf false 2>$null | Out-Null
    & git -C $Path config core.safecrlf false 2>$null | Out-Null
    Set-Content -LiteralPath (Join-Path $Path "README.txt") -Value "resume re-entry test" -Encoding UTF8
    & git -C $Path add README.txt 2>$null | Out-Null
    & git -C $Path commit -m "init" 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to create initial commit in temporary Git repository at '$Path'."
    }

    return $Path
}

function Invoke-GitCommitAll {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root,
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    & git -C $Root add -A 2>$null | Out-Null
    & git -C $Root commit -m $Message 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to create commit '$Message' in temporary Git repository."
    }
}

function New-BaselineFixtureSet {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root
    )

    $validMilestone = Join-Path $repoRoot "state\fixtures\valid\governed_work_object.milestone.valid.json"
    $validProject = Join-Path $repoRoot "state\fixtures\valid\governed_work_object.project.valid.json"
    $validPlanningRecord = Join-Path $repoRoot "state\fixtures\valid\planning_record.task.valid.json"
    $validAcceptedPlanningRecord = Join-Path $repoRoot "state\fixtures\valid\planning_records\accepted\planning_record.task.valid.accepted.json"
    $validWorkingPlanningRecord = Join-Path $repoRoot "state\fixtures\valid\planning_records\working\planning_record.task.valid.working.json"

    $fixtureRoot = Join-Path $Root "state\fixtures\valid"
    New-Item -ItemType Directory -Path (Join-Path $fixtureRoot "planning_records\accepted") -Force | Out-Null
    New-Item -ItemType Directory -Path (Join-Path $fixtureRoot "planning_records\working") -Force | Out-Null

    Copy-Item -LiteralPath $validMilestone -Destination (Join-Path $fixtureRoot "governed_work_object.milestone.valid.json") -Force
    Copy-Item -LiteralPath $validProject -Destination (Join-Path $fixtureRoot "governed_work_object.project.valid.json") -Force
    Copy-Item -LiteralPath $validPlanningRecord -Destination (Join-Path $fixtureRoot "planning_record.task.valid.json") -Force
    Copy-Item -LiteralPath $validAcceptedPlanningRecord -Destination (Join-Path $fixtureRoot "planning_records\accepted\planning_record.task.valid.accepted.json") -Force
    Copy-Item -LiteralPath $validWorkingPlanningRecord -Destination (Join-Path $fixtureRoot "planning_records\working\planning_record.task.valid.working.json") -Force
    Invoke-GitCommitAll -Root $Root -Message "add milestone baseline fixtures"

    return [pscustomobject]@{
        MilestonePath      = Join-Path $fixtureRoot "governed_work_object.milestone.valid.json"
        PlanningRecordPath = Join-Path $fixtureRoot "planning_record.task.valid.json"
    }
}

function New-MilestoneBaselineHarness {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Root,
        [Parameter(Mandatory = $true)]
        [string]$BaselineId
    )

    $fixtureSet = New-BaselineFixtureSet -Root $Root
    $baseline = & $newMilestoneBaselineRecord -BaselineId $BaselineId -MilestonePath $fixtureSet.MilestonePath -PlanningRecordPaths @($fixtureSet.PlanningRecordPath) -OperatorId "operator:rodney" -AuthorityReason "Capture a bounded Git-backed baseline for resume re-entry prerequisite validation." -RepositoryRoot $Root -CapturedAt ([datetime]::Parse("2026-04-21T06:30:00Z").ToUniversalTime())
    $storePath = Join-Path $env:TEMP ("aioffice-r5-005-baseline-store-" + [guid]::NewGuid().ToString("N"))
    $savedBaselinePath = & $saveMilestoneBaselineRecord -Baseline $baseline -StorePath $storePath

    return [pscustomobject]@{
        Baseline        = $baseline
        StorePath       = $storePath
        SavedBaselinePath = $savedBaselinePath
    }
}

$validExecutionBundle = Join-Path $repoRoot "state\fixtures\valid\qa_gate.execution_bundle.fail.json"
$failures = @()
$validPassed = 0
$invalidRejected = 0

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-005-valid-{0}" -f ([guid]::NewGuid().ToString("N")))
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

    try {
        $resumeRepo = Initialize-TemporaryGitRepository -Path (Join-Path $tempRoot "resume-repo")
        $qaOutputRoot = Join-Path $tempRoot "qa-output"
        $gateResult = & $invokeExecutionBundleQaGate -ExecutionBundlePath $validExecutionBundle -OutputRoot $qaOutputRoot -CreatedAt ([datetime]::Parse("2026-04-21T05:00:00Z").ToUniversalTime())
        $batonEmission = & $newBatonFromQaOutcome -QaReportPath $gateResult.QaReportPath -ExternalAuditPackPath $gateResult.ExternalAuditPackPath -RemediationRecordPath $gateResult.RemediationRecordPath -CreatedAt ([datetime]::Parse("2026-04-21T05:05:00Z").ToUniversalTime())
        $savedBatonPath = & $saveBatonRecord -Baton $batonEmission.Baton -StorePath (Join-Path $tempRoot "baton-store")

        $resumeRequestPath = Join-Path $tempRoot "resume-request.valid.json"
        Write-JsonDocument -Path $resumeRequestPath -Document ([pscustomobject]@{
                contract_version   = "v1"
                record_type        = "resume_reentry_request"
                resume_request_id  = "resume-reentry-valid-001"
                baton_ref          = $savedBatonPath
                operator_id        = "operator:rodney"
                requested_at       = "2026-04-21T05:10:00Z"
                reentry_kind       = "retry_entry"
                baseline_ref       = $null
                restore_result_ref = $null
                notes              = "Prepare one bounded retry-entry execution bundle from the persisted baton state."
            })

        $resumeResult = & $invokeResumeReentry -ResumeRequestPath $resumeRequestPath -OutputRoot (Join-Path $tempRoot "resume-output") -RepositoryRoot $resumeRepo -CreatedAt ([datetime]::Parse("2026-04-21T05:12:00Z").ToUniversalTime())
        $resumeResultCheck = & $testResumeReentryResultContract -ResumeResultPath $resumeResult.ResumeResultPath
        $resumeResultDocument = Get-JsonDocument -Path $resumeResult.ResumeResultPath
        $generatedExecutionBundlePath = Resolve-ArtifactReferencePath -ArtifactPath $resumeResult.ResumeResultPath -Reference $resumeResultDocument.generated_execution_bundle_ref
        $generatedExecutionBundle = Get-JsonDocument -Path $generatedExecutionBundlePath
        $generatedExecutionBundleCheck = & $testWorkArtifactContract -ArtifactPath $generatedExecutionBundlePath

        Write-Output ("PASS valid resume re-entry: {0} -> {1}" -f $resumeResultDocument.resume_request_id, $generatedExecutionBundle.artifact_id)

        if ($resumeResultCheck.IsValid -ne $true) {
            $failures += "FAIL valid resume re-entry: saved result did not validate."
        }
        if ($resumeResultDocument.decision -ne "allow") {
            $failures += ("FAIL valid resume re-entry: expected decision 'allow' but found '{0}'." -f $resumeResultDocument.decision)
        }
        if ($generatedExecutionBundleCheck.ArtifactType -ne "execution_bundle") {
            $failures += "FAIL valid resume re-entry: generated artifact did not validate as an execution_bundle."
        }
        if ([int]$generatedExecutionBundle.qa_attempt_count -ne 2) {
            $failures += ("FAIL valid resume re-entry: expected qa_attempt_count 2 but found '{0}'." -f $generatedExecutionBundle.qa_attempt_count)
        }
        if ($generatedExecutionBundle.qa_entry_state -ne "retry_entry") {
            $failures += ("FAIL valid resume re-entry: expected qa_entry_state 'retry_entry' but found '{0}'." -f $generatedExecutionBundle.qa_entry_state)
        }
        if ($generatedExecutionBundle.prior_qa_report_ref -eq $null -or $generatedExecutionBundle.prior_baton_ref -eq $null) {
            $failures += "FAIL valid resume re-entry: generated execution bundle did not persist prior QA and baton refs."
        }
        $resolvedGeneratedPriorQaReportPath = Resolve-ArtifactReferencePath -ArtifactPath $generatedExecutionBundlePath -Reference $generatedExecutionBundle.prior_qa_report_ref
        if ($resolvedGeneratedPriorQaReportPath -ne $gateResult.QaReportPath) {
            $failures += "FAIL valid resume re-entry: generated execution bundle prior_qa_report_ref did not preserve the source QA report."
        }
        $resolvedGeneratedPriorBatonPath = Resolve-ArtifactReferencePath -ArtifactPath $generatedExecutionBundlePath -Reference $generatedExecutionBundle.prior_baton_ref
        if ($resolvedGeneratedPriorBatonPath -ne $savedBatonPath) {
            $failures += "FAIL valid resume re-entry: generated execution bundle prior_baton_ref did not preserve the saved baton path."
        }
        if (-not $resumeResultDocument.checkpoints.clean_worktree) {
            $failures += "FAIL valid resume re-entry: clean_worktree checkpoint did not pass for the clean temporary Git repository."
        }
        if ($resumeResultDocument.checkpoints.restore_gate -ne $true) {
            $failures += "FAIL valid resume re-entry: restore_gate checkpoint should remain true when no restore gate is required."
        }

        $validPassed += 1
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL valid resume re-entry harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-005-manual-review-{0}" -f ([guid]::NewGuid().ToString("N")))
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

    try {
        $resumeRepo = Initialize-TemporaryGitRepository -Path (Join-Path $tempRoot "resume-repo")
        $retryGateResult = & $invokeExecutionBundleQaGate -ExecutionBundlePath $validExecutionBundle -OutputRoot (Join-Path $tempRoot "qa-output") -CreatedAt ([datetime]::Parse("2026-04-21T05:30:00Z").ToUniversalTime())
        $retryQaReport = Get-JsonDocument -Path $retryGateResult.QaReportPath
        $retryRemediation = Get-JsonDocument -Path $retryGateResult.RemediationRecordPath

        $retryQaReport.status = "retry_exhausted"
        $retryQaReport.qa_attempt_count = 4
        $retryQaReport.qa_retry_ceiling = 4
        $retryQaReport.qa_loop_state = "retry_exhausted"
        $retryQaReport.next_handoff = "manual_review"
        $retryQaReport.remediation_notes = "The bounded QA retry ceiling has been reached; the loop is stopped and must return for manual review."
        Write-JsonDocument -Path $retryGateResult.QaReportPath -Document $retryQaReport

        $retryRemediation.status = "retry_exhausted"
        $retryRemediation.qa_attempt_count = 4
        $retryRemediation.qa_retry_ceiling = 4
        $retryRemediation.qa_loop_state = "retry_exhausted"
        $retryRemediation.next_handoff = "manual_review"
        $retryRemediation.notes = "The bounded QA retry ceiling has been reached; further retries must stop and return for manual review."
        Write-JsonDocument -Path $retryGateResult.RemediationRecordPath -Document $retryRemediation

        $retryBatonEmission = & $newBatonFromQaOutcome -QaReportPath $retryGateResult.QaReportPath -ExternalAuditPackPath $retryGateResult.ExternalAuditPackPath -RemediationRecordPath $retryGateResult.RemediationRecordPath -CreatedAt ([datetime]::Parse("2026-04-21T05:35:00Z").ToUniversalTime())
        $savedRetryBatonPath = & $saveBatonRecord -Baton $retryBatonEmission.Baton -StorePath (Join-Path $tempRoot "baton-store")

        $resumeRequestPath = Join-Path $tempRoot "resume-request.manual-review.json"
        Write-JsonDocument -Path $resumeRequestPath -Document ([pscustomobject]@{
                contract_version   = "v1"
                record_type        = "resume_reentry_request"
                resume_request_id  = "resume-reentry-manual-review-001"
                baton_ref          = $savedRetryBatonPath
                operator_id        = "operator:rodney"
                requested_at       = "2026-04-21T05:40:00Z"
                reentry_kind       = "retry_entry"
                baseline_ref       = $null
                restore_result_ref = $null
                notes              = "Attempt to resume from a manual-review baton; this should block."
            })

        $resumeResult = & $invokeResumeReentry -ResumeRequestPath $resumeRequestPath -OutputRoot (Join-Path $tempRoot "resume-output") -RepositoryRoot $resumeRepo -CreatedAt ([datetime]::Parse("2026-04-21T05:42:00Z").ToUniversalTime())
        $resumeResultDocument = Get-JsonDocument -Path $resumeResult.ResumeResultPath
        Write-Output ("PASS blocked manual-review resume re-entry: {0} -> {1}" -f $resumeResultDocument.resume_request_id, $resumeResultDocument.decision)

        if ($resumeResultDocument.decision -ne "blocked") {
            $failures += ("FAIL blocked manual-review resume re-entry: expected decision 'blocked' but found '{0}'." -f $resumeResultDocument.decision)
        }
        if ($null -ne $resumeResultDocument.generated_execution_bundle_ref) {
            $failures += "FAIL blocked manual-review resume re-entry: generated_execution_bundle_ref should remain null."
        }
        if (@($resumeResultDocument.block_reasons | Where-Object { $_.code -eq "resume_not_allowed" }).Count -eq 0) {
            $failures += "FAIL blocked manual-review resume re-entry: missing resume_not_allowed block reason."
        }

        $invalidRejected += 1
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL blocked manual-review resume re-entry harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-005-dirty-repo-{0}" -f ([guid]::NewGuid().ToString("N")))
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

    try {
        $dirtyResumeRepo = Initialize-TemporaryGitRepository -Path (Join-Path $tempRoot "resume-repo")
        Set-Content -LiteralPath (Join-Path $dirtyResumeRepo "DIRTY.txt") -Value "dirty" -Encoding UTF8

        $qaOutputRoot = Join-Path $tempRoot "qa-output"
        $gateResult = & $invokeExecutionBundleQaGate -ExecutionBundlePath $validExecutionBundle -OutputRoot $qaOutputRoot -CreatedAt ([datetime]::Parse("2026-04-21T06:00:00Z").ToUniversalTime())
        $batonEmission = & $newBatonFromQaOutcome -QaReportPath $gateResult.QaReportPath -ExternalAuditPackPath $gateResult.ExternalAuditPackPath -RemediationRecordPath $gateResult.RemediationRecordPath -CreatedAt ([datetime]::Parse("2026-04-21T06:05:00Z").ToUniversalTime())
        $savedBatonPath = & $saveBatonRecord -Baton $batonEmission.Baton -StorePath (Join-Path $tempRoot "baton-store")

        $resumeRequestPath = Join-Path $tempRoot "resume-request.dirty-repo.json"
        Write-JsonDocument -Path $resumeRequestPath -Document ([pscustomobject]@{
                contract_version   = "v1"
                record_type        = "resume_reentry_request"
                resume_request_id  = "resume-reentry-dirty-repo-001"
                baton_ref          = $savedBatonPath
                operator_id        = "operator:rodney"
                requested_at       = "2026-04-21T06:10:00Z"
                reentry_kind       = "retry_entry"
                baseline_ref       = $null
                restore_result_ref = $null
                notes              = "Attempt to resume with a dirty Git worktree; this should block."
            })

        $resumeResult = & $invokeResumeReentry -ResumeRequestPath $resumeRequestPath -OutputRoot (Join-Path $tempRoot "resume-output") -RepositoryRoot $dirtyResumeRepo -CreatedAt ([datetime]::Parse("2026-04-21T06:12:00Z").ToUniversalTime())
        $resumeResultDocument = Get-JsonDocument -Path $resumeResult.ResumeResultPath
        Write-Output ("PASS blocked dirty-worktree resume re-entry: {0} -> {1}" -f $resumeResultDocument.resume_request_id, $resumeResultDocument.decision)

        if ($resumeResultDocument.decision -ne "blocked") {
            $failures += ("FAIL blocked dirty-worktree resume re-entry: expected decision 'blocked' but found '{0}'." -f $resumeResultDocument.decision)
        }
        if (@($resumeResultDocument.block_reasons | Where-Object { $_.code -eq "worktree_dirty" }).Count -eq 0) {
            $failures += "FAIL blocked dirty-worktree resume re-entry: missing worktree_dirty block reason."
        }
        if ($null -ne $resumeResultDocument.generated_execution_bundle_ref) {
            $failures += "FAIL blocked dirty-worktree resume re-entry: generated_execution_bundle_ref should remain null."
        }

        $invalidRejected += 1
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL blocked dirty-worktree resume re-entry harness: {0}" -f $_.Exception.Message)
}

try {
    $pathInvariantRoot = Join-Path $repoRoot ("state\temp\aioffice-r6-p2-resume-{0}" -f ([guid]::NewGuid().ToString("N")))
    New-Item -ItemType Directory -Path (Join-Path $pathInvariantRoot "requests") -Force | Out-Null

    try {
        $resumeRepoRoot = Join-Path $env:TEMP ("aioffice-r6-p2-resume-repo-{0}" -f ([guid]::NewGuid().ToString("N")))
        $resumeRepo = Initialize-TemporaryGitRepository -Path $resumeRepoRoot
        $qaOutputRoot = Join-Path $pathInvariantRoot "qa-output"
        $gateResult = & $invokeExecutionBundleQaGate -ExecutionBundlePath $validExecutionBundle -OutputRoot $qaOutputRoot -CreatedAt ([datetime]::Parse("2026-04-22T02:00:00Z").ToUniversalTime())
        $batonEmission = & $newBatonFromQaOutcome -QaReportPath $gateResult.QaReportPath -ExternalAuditPackPath $gateResult.ExternalAuditPackPath -RemediationRecordPath $gateResult.RemediationRecordPath -CreatedAt ([datetime]::Parse("2026-04-22T02:05:00Z").ToUniversalTime())
        $savedBatonPath = & $saveBatonRecord -Baton $batonEmission.Baton -StorePath (Join-Path $pathInvariantRoot "baton-store")
        $requestDirectory = Join-Path $pathInvariantRoot "requests"
        $resumeRequestPath = Join-Path $requestDirectory "resume-request.relative.json"
        $relativeBatonRefFromRequest = Get-PathRelativeToBaseDirectory -BaseDirectory $requestDirectory -TargetPath $savedBatonPath
        $relativeRequestPath = Get-PathRelativeToRepositoryRoot -Path $resumeRequestPath
        $relativeOutputRoot = Get-PathRelativeToRepositoryRoot -Path (Join-Path $pathInvariantRoot "resume-output")
        $outsideRoot = Join-Path $env:TEMP ("aioffice-r6-p2-resume-cwd-{0}" -f ([guid]::NewGuid().ToString("N")))
        New-Item -ItemType Directory -Path $outsideRoot -Force | Out-Null

        Write-JsonDocument -Path $resumeRequestPath -Document ([pscustomobject]@{
                contract_version   = "v1"
                record_type        = "resume_reentry_request"
                resume_request_id  = "resume-reentry-relative-baton-001"
                baton_ref          = $relativeBatonRefFromRequest
                operator_id        = "operator:rodney"
                requested_at       = "2026-04-22T02:10:00Z"
                reentry_kind       = "retry_entry"
                baseline_ref       = $null
                restore_result_ref = $null
                notes              = "Prepare one bounded retry-entry execution bundle from a request whose baton_ref is relative to the request artifact."
            })

        try {
            Push-Location $outsideRoot
            $relativeResumeResult = & $invokeResumeReentry -ResumeRequestPath $relativeRequestPath -OutputRoot $relativeOutputRoot -RepositoryRoot $resumeRepo -CreatedAt ([datetime]::Parse("2026-04-22T02:12:00Z").ToUniversalTime())
            $relativeResumeResultDocument = Get-JsonDocument -Path $relativeResumeResult.ResumeResultPath

            $invalidResumeRequestPath = Join-Path $requestDirectory "resume-request.missing-baton.json"
            Write-JsonDocument -Path $invalidResumeRequestPath -Document ([pscustomobject]@{
                    contract_version   = "v1"
                    record_type        = "resume_reentry_request"
                    resume_request_id  = "resume-reentry-relative-baton-missing-001"
                    baton_ref          = "../baton-store/batons/missing.json"
                    operator_id        = "operator:rodney"
                    requested_at       = "2026-04-22T02:14:00Z"
                    reentry_kind       = "retry_entry"
                    baseline_ref       = $null
                    restore_result_ref = $null
                    notes              = "Attempt to resume from a missing request-relative baton path; this should fail closed."
                })

            try {
                & $invokeResumeReentry -ResumeRequestPath (Get-PathRelativeToRepositoryRoot -Path $invalidResumeRequestPath) -OutputRoot $relativeOutputRoot -RepositoryRoot $resumeRepo -CreatedAt ([datetime]::Parse("2026-04-22T02:15:00Z").ToUniversalTime()) | Out-Null
                $failures += "FAIL caller-location-invariant resume re-entry: missing request-relative baton path was accepted unexpectedly."
            }
            catch {
                Write-Output ("PASS invalid request-relative baton path: {0}" -f $_.Exception.Message)
                $invalidRejected += 1
            }
        }
        finally {
            Pop-Location
            if (Test-Path -LiteralPath $outsideRoot) {
                Remove-Item -LiteralPath $outsideRoot -Recurse -Force
            }
        }

        $expectedResumeOutputRoot = Join-Path $pathInvariantRoot "resume-output"
        Write-Output ("PASS caller-location-invariant resume re-entry: {0} -> {1}" -f $relativeResumeResultDocument.resume_request_id, $relativeResumeResultDocument.decision)

        if ($relativeResumeResultDocument.decision -ne "allow") {
            $failures += ("FAIL caller-location-invariant resume re-entry: expected decision 'allow' but found '{0}'." -f $relativeResumeResultDocument.decision)
        }
        if ((Split-Path -Parent $relativeResumeResult.ResumeResultPath) -notlike "$expectedResumeOutputRoot*") {
            $failures += "FAIL caller-location-invariant resume re-entry: output root did not stay anchored to the repository root."
        }

        $validPassed += 1
    }
    finally {
        if (Test-Path -LiteralPath $resumeRepoRoot) {
            Remove-Item -LiteralPath $resumeRepoRoot -Recurse -Force
        }
        if (Test-Path -LiteralPath $pathInvariantRoot) {
            Remove-Item -LiteralPath $pathInvariantRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL caller-location-invariant resume re-entry harness: {0}" -f $_.Exception.Message)
}

try {
    $tempRoot = Join-Path $env:TEMP ("aioffice-r5-005-missing-restore-gate-{0}" -f ([guid]::NewGuid().ToString("N")))
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

    try {
        $resumeRepo = Initialize-TemporaryGitRepository -Path (Join-Path $tempRoot "resume-repo")
        $baselineHarness = New-MilestoneBaselineHarness -Root $resumeRepo -BaselineId "baseline-r5-005-restore-required-001"

        $qaOutputRoot = Join-Path $tempRoot "qa-output"
        $gateResult = & $invokeExecutionBundleQaGate -ExecutionBundlePath $validExecutionBundle -OutputRoot $qaOutputRoot -CreatedAt ([datetime]::Parse("2026-04-21T06:40:00Z").ToUniversalTime())
        $batonEmission = & $newBatonFromQaOutcome -QaReportPath $gateResult.QaReportPath -ExternalAuditPackPath $gateResult.ExternalAuditPackPath -RemediationRecordPath $gateResult.RemediationRecordPath -CreatedAt ([datetime]::Parse("2026-04-21T06:45:00Z").ToUniversalTime())
        $savedBatonPath = & $saveBatonRecord -Baton $batonEmission.Baton -StorePath (Join-Path $tempRoot "baton-store")

        $tamperedBaton = Get-JsonDocument -Path $savedBatonPath
        $tamperedBaton.resume_authority.restore_gate_required = $true
        $tamperedBaton.resume_context.baseline_ref = $baselineHarness.SavedBaselinePath
        Write-JsonDocument -Path $savedBatonPath -Document $tamperedBaton
        & $testBatonRecordContract -BatonPath $savedBatonPath | Out-Null

        $resumeRequestPath = Join-Path $tempRoot "resume-request.missing-restore-gate.json"
        Write-JsonDocument -Path $resumeRequestPath -Document ([pscustomobject]@{
                contract_version   = "v1"
                record_type        = "resume_reentry_request"
                resume_request_id  = "resume-reentry-missing-restore-gate-001"
                baton_ref          = $savedBatonPath
                operator_id        = "operator:rodney"
                requested_at       = "2026-04-21T06:50:00Z"
                reentry_kind       = "retry_entry"
                baseline_ref       = $null
                restore_result_ref = $null
                notes              = "Attempt to resume when the baton explicitly requires an allow restore gate result."
            })

        $resumeResult = & $invokeResumeReentry -ResumeRequestPath $resumeRequestPath -OutputRoot (Join-Path $tempRoot "resume-output") -RepositoryRoot $resumeRepo -CreatedAt ([datetime]::Parse("2026-04-21T06:52:00Z").ToUniversalTime())
        $resumeResultDocument = Get-JsonDocument -Path $resumeResult.ResumeResultPath
        Write-Output ("PASS blocked missing restore gate resume re-entry: {0} -> {1}" -f $resumeResultDocument.resume_request_id, $resumeResultDocument.decision)

        if ($resumeResultDocument.decision -ne "blocked") {
            $failures += ("FAIL blocked missing restore gate resume re-entry: expected decision 'blocked' but found '{0}'." -f $resumeResultDocument.decision)
        }
        if (@($resumeResultDocument.block_reasons | Where-Object { $_.code -eq "restore_gate_missing" }).Count -eq 0) {
            $failures += "FAIL blocked missing restore gate resume re-entry: missing restore_gate_missing block reason."
        }
        if ($null -ne $resumeResultDocument.generated_execution_bundle_ref) {
            $failures += "FAIL blocked missing restore gate resume re-entry: generated_execution_bundle_ref should remain null."
        }

        $invalidRejected += 1
    }
    finally {
        if ($null -ne $baselineHarness -and (Test-Path -LiteralPath $baselineHarness.StorePath)) {
            Remove-Item -LiteralPath $baselineHarness.StorePath -Recurse -Force
        }
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }
}
catch {
    $failures += ("FAIL blocked missing restore gate resume re-entry harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Resume re-entry tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All resume re-entry tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
