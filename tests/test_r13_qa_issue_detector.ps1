$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R13QaIssueDetector.psm1") -Force -PassThru
$testReport = $module.ExportedCommands["Test-R13QaIssueDetectionReport"]
$invokeDetector = $module.ExportedCommands["Invoke-R13QaIssueDetector"]

$validRoot = Join-Path $repoRoot "state\fixtures\valid\actionable_qa"
$invalidReportRoot = Join-Path $repoRoot "state\fixtures\invalid\actionable_qa\r13_qa_issue_detector"
$inputRoot = Join-Path $repoRoot "state\fixtures\invalid\actionable_qa\r13_detector_inputs"
$validatorPath = Join-Path $repoRoot "tools\validate_r13_qa_issue_detection_report.ps1"
$cliPath = Join-Path $repoRoot "tools\invoke_r13_qa_issue_detector.ps1"
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

function Get-GitLine {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $value = & git -C $repoRoot @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Arguments -join ' ') failed."
    }
    return ([string]$value).Trim()
}

try {
    $cleanReport = & $testReport -ReportPath (Join-Path $validRoot "r13_qa_issue_detection_report.clean.valid.json")
    if ($cleanReport.AggregateVerdict -ne "passed" -or $cleanReport.IssueCount -ne 0) {
        $failures += "FAIL valid: clean valid report did not validate as passed with zero issues."
    }
    else {
        Write-Output ("PASS valid clean report: {0}" -f $cleanReport.ReportId)
        $validPassed += 1
    }

    $withIssuesReport = & $testReport -ReportPath (Join-Path $validRoot "r13_qa_issue_detection_report.with_issues.valid.json")
    if ($withIssuesReport.AggregateVerdict -ne "failed" -or $withIssuesReport.IssueCount -lt 1 -or $withIssuesReport.BlockingIssueCount -lt 1) {
        $failures += "FAIL valid: with-issues report did not validate as failed with blocking issues."
    }
    else {
        Write-Output ("PASS valid with-issues report: {0}" -f $withIssuesReport.ReportId)
        $validPassed += 1
    }

    $expectedInvalidFragments = @{
        "missing_issue_required_field.invalid.json" = @("expected_behavior")
        "passed_with_unresolved_blocking_issue.invalid.json" = @("unresolved blocking")
        "missing_reproduction_command.invalid.json" = @("reproduction_command")
        "missing_recommended_fix.invalid.json" = @("recommended_fix")
        "narrative_only_qa_as_pass.invalid.json" = @("narrative-only QA")
        "executor_self_certification_as_qa.invalid.json" = @("executor self-certification")
        "local_only_as_external_proof.invalid.json" = @("local-only", "external proof")
        "missing_non_claims.invalid.json" = @("non_claims")
        "wrong_branch.invalid.json" = @("branch")
        "r14_successor_opened.invalid.json" = @("R14")
    }

    $invalidFiles = @(Get-ChildItem -LiteralPath $invalidReportRoot -Filter "*.invalid.json" -File | Sort-Object Name)
    foreach ($expectedName in $expectedInvalidFragments.Keys) {
        if (@($invalidFiles | Where-Object { $_.Name -eq $expectedName }).Count -ne 1) {
            $failures += "FAIL fixture: missing invalid fixture '$expectedName'."
        }
    }

    foreach ($invalidFile in $invalidFiles) {
        if (-not $expectedInvalidFragments.ContainsKey($invalidFile.Name)) {
            $failures += "FAIL fixture: unexpected invalid fixture '$($invalidFile.Name)' lacks expected refusal fragments."
            continue
        }
        Invoke-ExpectedRefusal -Label $invalidFile.Name -RequiredFragments $expectedInvalidFragments[$invalidFile.Name] -Action {
            & $testReport -ReportPath $invalidFile.FullName | Out-Null
        }
    }

    $branch = Get-GitLine -Arguments @("branch", "--show-current")
    $head = Get-GitLine -Arguments @("rev-parse", "HEAD")
    $tree = Get-GitLine -Arguments @("rev-parse", "HEAD^{tree}")

    $detectorReport = & $invokeDetector -ScopePath @($inputRoot) -FixtureMode -ExpectedBranch $branch -ExpectedHead $head -ExpectedTree $tree
    if ($detectorReport.aggregate_verdict -ne "failed" -or [int]$detectorReport.summary.total_issue_count -lt 9) {
        $failures += "FAIL detector: seeded invalid inputs did not produce a failed report with practical issues."
    }
    else {
        Write-Output ("PASS detector seeded inputs produced {0} issue(s)." -f $detectorReport.summary.total_issue_count)
        $validPassed += 1
    }

    $requiredIssueTypes = @(
        "malformed_json",
        "missing_required_evidence_ref",
        "missing_reproduction_command",
        "narrative_only_qa_evidence",
        "executor_self_certification_qa_authority",
        "local_only_evidence_as_external_proof",
        "missing_recommended_fix",
        "aggregate_passed_with_unresolved_blocking_issue",
        "stale_or_wrong_branch_head_tree_identity"
    )
    $missingIssueTypes = @()
    foreach ($issueType in $requiredIssueTypes) {
        if (@($detectorReport.issues | Where-Object { $_.issue_type -eq $issueType }).Count -lt 1) {
            $failures += "FAIL detector: required issue type '$issueType' was not detected."
            $missingIssueTypes += $issueType
        }
    }
    if ($missingIssueTypes.Count -eq 0) {
        Write-Output "PASS detector found all required issue types."
        $validPassed += 1
    }

    $blockedReport = & $invokeDetector -ScopePath @(".")
    if ($blockedReport.aggregate_verdict -ne "blocked" -or ([string]::Join("`n", @($blockedReport.refusal_reasons)) -notmatch "repo-root")) {
        $failures += "FAIL detector: repo-root scan was not refused without AllowRepoRootScan."
    }
    else {
        Write-Output "PASS detector refused unsafe repo-root scan."
        $validPassed += 1
    }

    $psaModule = Get-Module -ListAvailable -Name PSScriptAnalyzer | Select-Object -First 1
    if ($null -eq $psaModule) {
        if ([bool]$detectorReport.dependency_status.psscriptanalyzer.available -or [string]$detectorReport.dependency_status.psscriptanalyzer.status -ne "unavailable" -or [string]$detectorReport.dependency_status.psscriptanalyzer.details -notmatch "full lint") {
            $failures += "FAIL detector: PSScriptAnalyzer unavailable state was not explicit."
        }
        else {
            Write-Output "PASS detector recorded PSScriptAnalyzer unavailable without claiming full lint."
            $validPassed += 1
        }
    }
    else {
        if (-not [bool]$detectorReport.dependency_status.psscriptanalyzer.available) {
            $failures += "FAIL detector: PSScriptAnalyzer is installed but report did not mark it available."
        }
        else {
            Write-Output "PASS detector recorded PSScriptAnalyzer available in this environment."
            $validPassed += 1
        }
    }

    Invoke-ExpectedRefusal -Label "dynamic-passed-with-blocking" -RequiredFragments @("unresolved blocking") -Action {
        & $testReport -ReportPath (Join-Path $invalidReportRoot "passed_with_unresolved_blocking_issue.invalid.json") | Out-Null
    }

    $tempIssueReport = Join-Path ([System.IO.Path]::GetTempPath()) ("r13-detector-cli-issues-" + [guid]::NewGuid().ToString("N") + ".json")
    $cliIssues = Invoke-PowerShellFile -FilePath $cliPath -Arguments @("-ScopePath", $inputRoot, "-OutputPath", $tempIssueReport, "-FixtureMode", "-ExpectedBranch", $branch, "-ExpectedHead", $head, "-ExpectedTree", $tree)
    if ($cliIssues.ExitCode -ne 0) {
        $failures += "FAIL cli issues: detector CLI returned non-zero for successful detection with issues. Output: $([string]::Join(' ', @($cliIssues.Output)))"
    }
    else {
        $cliIssueReport = Get-Content -LiteralPath $tempIssueReport -Raw | ConvertFrom-Json
        if ($cliIssueReport.aggregate_verdict -ne "failed" -or [int]$cliIssueReport.summary.total_issue_count -lt 1) {
            $failures += "FAIL cli issues: detector CLI output did not record failed issue detection."
        }
        else {
            Write-Output "PASS CLI exits 0 when detection succeeds but issues are found."
            $validPassed += 1
        }
    }

    $tempBlockedReport = Join-Path ([System.IO.Path]::GetTempPath()) ("r13-detector-cli-blocked-" + [guid]::NewGuid().ToString("N") + ".json")
    $cliBlocked = Invoke-PowerShellFile -FilePath $cliPath -Arguments @("-ScopePath", ".", "-OutputPath", $tempBlockedReport)
    if ($cliBlocked.ExitCode -eq 0) {
        $failures += "FAIL cli blocked: detector CLI returned zero for blocked unsafe scan."
    }
    else {
        Write-Output "PASS CLI exits non-zero when detector is blocked/refused."
        $invalidRejected += 1
    }

    $validatorValid = Invoke-PowerShellFile -FilePath $validatorPath -Arguments @("-ReportPath", (Join-Path $validRoot "r13_qa_issue_detection_report.clean.valid.json"))
    if ($validatorValid.ExitCode -ne 0 -or ([string]::Join("`n", @($validatorValid.Output)) -notmatch "VALID")) {
        $failures += "FAIL validator valid: validator CLI did not print VALID for clean fixture. Output: $([string]::Join(' ', @($validatorValid.Output)))"
    }
    else {
        Write-Output "PASS validator CLI prints VALID for valid fixture."
        $validPassed += 1
    }

    $validatorInvalid = Invoke-PowerShellFile -FilePath $validatorPath -Arguments @("-ReportPath", (Join-Path $invalidReportRoot "missing_reproduction_command.invalid.json"))
    if ($validatorInvalid.ExitCode -eq 0) {
        $failures += "FAIL validator invalid: validator CLI accepted invalid fixture."
    }
    else {
        Write-Output "PASS validator CLI rejects invalid fixture."
        $invalidRejected += 1
    }
}
catch {
    $failures += ("FAIL R13 QA issue detector harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R13 QA issue detector tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R13 QA issue detector tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
