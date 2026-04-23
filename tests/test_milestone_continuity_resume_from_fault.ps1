$ErrorActionPreference = "Stop"

$modulePath = Join-Path (Split-Path -Parent $PSScriptRoot) "tools\MilestoneContinuityResume.psm1"
Import-Module $modulePath -Force

$repoRoot = Split-Path -Parent $PSScriptRoot
$validRequestFixture = Join-Path $repoRoot "state\fixtures\valid\milestone_continuity\resume_from_fault_request.valid.json"
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("aioffice-r7-004-" + [System.Guid]::NewGuid().ToString("N"))

$validPassed = 0
$invalidRejected = 0
$failures = @()

function Get-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Copy-JsonObject {
    param(
        [Parameter(Mandatory = $true)]
        $Object
    )

    return (ConvertFrom-Json ($Object | ConvertTo-Json -Depth 20))
}

try {
    $requestValidation = Test-MilestoneContinuityResumeRequestContract -ResumeRequestPath $validRequestFixture
    Write-Output ("PASS valid resume request: {0} -> {1}" -f (Resolve-Path -Relative $validRequestFixture), $requestValidation.ResumeRequestId)
    $validPassed += 1

    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
    $resultPath = Join-Path $tempRoot "resume_from_fault.result.json"
    $resumeFlow = Invoke-MilestoneContinuityResumeFromFault -ResumeRequestPath $validRequestFixture -ResumeResultPath $resultPath
    $resultValidation = Test-MilestoneContinuityResumeResultContract -ResumeResultPath $resumeFlow.ResumeResultPath
    $resumeResult = Get-JsonDocument -Path $resumeFlow.ResumeResultPath

    Write-Output ("PASS valid supervised resume-from-fault: {0} -> {1}" -f $resumeResult.resume_request_id, $resultValidation.ResumeResultId)
    if ($resumeResult.prepared_reentry.prepared_action -ne "resume_supervised_segment") {
        $failures += "FAIL valid supervised resume-from-fault: prepared_action did not stay bounded to 'resume_supervised_segment'."
    }
    if ($resumeResult.resume_execution_claim -ne "not_implied") {
        $failures += "FAIL valid supervised resume-from-fault: resume_execution_claim did not preserve the non-claim."
    }
    $validPassed += 1

    $validRequest = Get-JsonDocument -Path $validRequestFixture
    $invalidCases = @(
        @{
            Name = "missing-checkpoint-ref"
            UseInvoke = $false
            Mutate = {
                param($Document)
                $Document.PSObject.Properties.Remove("checkpoint_ref")
                return $Document
            }
        },
        @{
            Name = "missing-handoff-packet-ref"
            UseInvoke = $false
            Mutate = {
                param($Document)
                $Document.PSObject.Properties.Remove("handoff_packet_ref")
                return $Document
            }
        },
        @{
            Name = "missing-fault-event-ref"
            UseInvoke = $false
            Mutate = {
                param($Document)
                $Document.PSObject.Properties.Remove("fault_event_ref")
                return $Document
            }
        },
        @{
            Name = "checkpoint-ref-id-mismatch"
            UseInvoke = $false
            Mutate = {
                param($Document)
                $Document.checkpoint_ref.checkpoint_id = "checkpoint-r7-003-other-001"
                return $Document
            }
        },
        @{
            Name = "invalid-operator-authority"
            UseInvoke = $true
            Mutate = {
                param($Document)
                $Document.supervision.operator_authority = "operator:other"
                return $Document
            }
        },
        @{
            Name = "git-context-mismatch"
            UseInvoke = $true
            Mutate = {
                param($Document)
                $Document.git_context.head_commit = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
                return $Document
            }
        },
        @{
            Name = "identity-mismatch"
            UseInvoke = $true
            Mutate = {
                param($Document)
                $Document.scope_context.task_id = "task-r7-004-other-task-001"
                return $Document
            }
        }
    )

    foreach ($invalidCase in @($invalidCases)) {
        $invalidRequest = Copy-JsonObject -Object $validRequest
        $invalidRequest = & $invalidCase.Mutate $invalidRequest

        try {
            if ($invalidCase.UseInvoke) {
                $invalidPath = Join-Path $tempRoot ("{0}.request.json" -f $invalidCase.Name)
                $invalidResultPath = Join-Path $tempRoot ("{0}.result.json" -f $invalidCase.Name)
                $invalidRequest | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $invalidPath -Encoding ascii
                Invoke-MilestoneContinuityResumeFromFault -ResumeRequestPath $invalidPath -ResumeResultPath $invalidResultPath | Out-Null
            }
            else {
                Test-MilestoneContinuityResumeRequestObject -ResumeRequest $invalidRequest -SourceLabel $invalidCase.Name | Out-Null
            }

            $failures += ("FAIL invalid: {0} was accepted unexpectedly." -f $invalidCase.Name)
        }
        catch {
            Write-Output ("PASS invalid: {0} -> {1}" -f $invalidCase.Name, $_.Exception.Message)
            $invalidRejected += 1
        }
    }
}
catch {
    $failures += ("FAIL milestone continuity resume-from-fault harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Force -Recurse
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Milestone continuity resume-from-fault tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All milestone continuity resume-from-fault tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
