Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot

function Get-RepositoryRoot {
    return $repoRoot
}

function Ensure-Directory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Resolve-OutputRootPath {
    param(
        [string]$OutputRoot
    )

    if ([string]::IsNullOrWhiteSpace($OutputRoot)) {
        return Join-Path $env:TEMP ("aioffice-bounded-proof-suite-" + [guid]::NewGuid().ToString("N"))
    }

    if ([System.IO.Path]::IsPathRooted($OutputRoot)) {
        return $OutputRoot
    }

    return Join-Path (Get-Location) $OutputRoot
}

function Resolve-PowerShellExecutable {
    foreach ($candidate in @("powershell.exe", "powershell", "pwsh.exe", "pwsh")) {
        $command = Get-Command $candidate -ErrorAction SilentlyContinue
        if ($null -ne $command) {
            return $command.Source
        }
    }

    throw "Unable to resolve a PowerShell executable for the bounded proof suite."
}

function Write-Utf8File {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [AllowNull()]
        [string]$Value
    )

    $directory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($directory)) {
        Ensure-Directory -Path $directory
    }

    if ($null -eq $Value) {
        $Value = ""
    }

    Set-Content -LiteralPath $Path -Value $Value -Encoding UTF8
}

function Get-RepoRelativePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $resolvedRepoRoot = (Resolve-Path -LiteralPath (Get-RepositoryRoot)).Path
    $fullPath = [System.IO.Path]::GetFullPath($Path)

    if (-not $fullPath.StartsWith($resolvedRepoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Path '$Path' is outside the repository root '$resolvedRepoRoot'."
    }

    $baseUri = [System.Uri]("{0}{1}" -f $resolvedRepoRoot.TrimEnd("\/"), [System.IO.Path]::DirectorySeparatorChar)
    $targetUri = [System.Uri]$fullPath
    return ($baseUri.MakeRelativeUri($targetUri).OriginalString).Replace("\", "/")
}

function Get-RepoRelativePathIfInsideRepo {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    try {
        return Get-RepoRelativePath -Path $Path
    }
    catch {
        return $null
    }
}

function Get-GitBranchName {
    $branch = (& git -C (Get-RepositoryRoot) branch --show-current 2>$null).Trim()
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($branch)) {
        throw "Unable to resolve the current Git branch for the bounded proof suite."
    }

    return $branch
}

function Get-GitHeadCommit {
    $head = (& git -C (Get-RepositoryRoot) rev-parse HEAD 2>$null).Trim()
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($head)) {
        throw "Unable to resolve the current Git HEAD commit for the bounded proof suite."
    }

    return $head
}

function Get-GitStatusLines {
    $statusOutput = & git -C (Get-RepositoryRoot) status --short --untracked-files=all 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Unable to resolve Git status for the bounded proof suite."
    }

    return @($statusOutput | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Get-BoundedProofSuiteDefinition {
    $definitions = @(
        [pscustomobject]@{
            Id           = "r2-stage-artifact-contracts"
            Name         = "R2 stage artifact contracts"
            RelativePath = "tests/test_stage_artifact_contracts.ps1"
            Purpose      = "Validate stage artifact contracts through architect."
            Command      = "powershell -ExecutionPolicy Bypass -File tests\test_stage_artifact_contracts.ps1"
        }
        [pscustomobject]@{
            Id           = "r2-packet-record-storage"
            Name         = "R2 packet record storage"
            RelativePath = "tests/test_packet_record_storage.ps1"
            Purpose      = "Validate packet record storage, lifecycle, and chronology enforcement."
            Command      = "powershell -ExecutionPolicy Bypass -File tests\test_packet_record_storage.ps1"
        }
        [pscustomobject]@{
            Id           = "r2-apply-promotion-gate"
            Name         = "R2 apply or promotion gate"
            RelativePath = "tests/test_apply_promotion_gate.ps1"
            Purpose      = "Validate bounded apply or promotion gate preconditions and blocked-state recording."
            Command      = "powershell -ExecutionPolicy Bypass -File tests\test_apply_promotion_gate.ps1"
        }
        [pscustomobject]@{
            Id           = "r2-apply-promotion-action"
            Name         = "R2 apply or promotion action"
            RelativePath = "tests/test_apply_promotion_action.ps1"
            Purpose      = "Validate bounded allow-path action execution and refusal after blocked gate results."
            Command      = "powershell -ExecutionPolicy Bypass -File tests\test_apply_promotion_action.ps1"
        }
        [pscustomobject]@{
            Id           = "r2-supervised-admin-flow"
            Name         = "R2 supervised admin flow"
            RelativePath = "tests/test_supervised_admin_flow.ps1"
            Purpose      = "Validate the supervised harness allow path and block path without broad UI."
            Command      = "powershell -ExecutionPolicy Bypass -File tests\test_supervised_admin_flow.ps1"
        }
        [pscustomobject]@{
            Id           = "r3-governed-work-object-contracts"
            Name         = "R3 governed work object contracts"
            RelativePath = "tests/test_governed_work_object_contracts.ps1"
            Purpose      = "Validate Project, Milestone, Task, and Bug governed work object contracts."
            Command      = "powershell -ExecutionPolicy Bypass -File tests\test_governed_work_object_contracts.ps1"
        }
        [pscustomobject]@{
            Id           = "r3-planning-record-storage"
            Name         = "R3 planning record storage"
            RelativePath = "tests/test_planning_record_storage.ps1"
            Purpose      = "Validate planning record storage, pipeline metadata, and fail-closed scope rules."
            Command      = "powershell -ExecutionPolicy Bypass -File tests\test_planning_record_storage.ps1"
        }
        [pscustomobject]@{
            Id           = "r3-work-artifact-contracts"
            Name         = "R3 governed work artifact contracts"
            RelativePath = "tests/test_work_artifact_contracts.ps1"
            Purpose      = "Validate governed work artifact contracts, lineage, scope, and retry metadata."
            Command      = "powershell -ExecutionPolicy Bypass -File tests\test_work_artifact_contracts.ps1"
        }
        [pscustomobject]@{
            Id           = "r3-request-brief-task-packet-flow"
            Name         = "R3 request brief to task packet flow"
            RelativePath = "tests/test_request_brief_task_packet_flow.ps1"
            Purpose      = "Validate the bounded Request Brief to Task Packet planning flow."
            Command      = "powershell -ExecutionPolicy Bypass -File tests\test_request_brief_task_packet_flow.ps1"
        }
        [pscustomobject]@{
            Id           = "r3-execution-bundle-qa-gate"
            Name         = "R3 execution bundle QA gate"
            RelativePath = "tests/test_execution_bundle_qa_gate.ps1"
            Purpose      = "Validate bounded QA gate outcomes, retry ceilings, and stop behavior."
            Command      = "powershell -ExecutionPolicy Bypass -File tests\test_execution_bundle_qa_gate.ps1"
        }
        [pscustomobject]@{
            Id           = "r3-baton-persistence"
            Name         = "R3 baton persistence"
            RelativePath = "tests/test_baton_persistence.ps1"
            Purpose      = "Validate bounded Baton persistence, reload, and invalid handoff rejection."
            Command      = "powershell -ExecutionPolicy Bypass -File tests\test_baton_persistence.ps1"
        }
        [pscustomobject]@{
            Id           = "r3-planning-replay"
            Name         = "R3 planning replay proof"
            RelativePath = "tests/test_r3_planning_replay.ps1"
            Purpose      = "Validate the replayable bounded R3 planning proof path."
            Command      = "powershell -ExecutionPolicy Bypass -File tests\test_r3_planning_replay.ps1"
        }
        [pscustomobject]@{
            Id           = "r4-ci-foundation"
            Name         = "R4 CI foundation"
            RelativePath = "tests/test_bounded_proof_ci_foundation.ps1"
            Purpose      = "Validate that the source-controlled CI workflow is wired to the bounded proof runner."
            Command      = "powershell -ExecutionPolicy Bypass -File tests\test_bounded_proof_ci_foundation.ps1"
        }
        [pscustomobject]@{
            Id           = "r5-milestone-baseline"
            Name         = "R5 milestone baseline"
            RelativePath = "tests/test_milestone_baseline.ps1"
            Purpose      = "Validate Git-backed milestone baseline capture, storage, and clean-worktree refusal behavior."
            Command      = "powershell -ExecutionPolicy Bypass -File tests\test_milestone_baseline.ps1"
        }
        [pscustomobject]@{
            Id           = "r5-restore-gate"
            Name         = "R5 restore gate"
            RelativePath = "tests/test_restore_gate.ps1"
            Purpose      = "Validate bounded restore-gate allow and refusal behavior without executing restore actions."
            Command      = "powershell -ExecutionPolicy Bypass -File tests\test_restore_gate.ps1"
        }
        [pscustomobject]@{
            Id           = "r5-resume-reentry"
            Name         = "R5 resume re-entry"
            RelativePath = "tests/test_resume_reentry.ps1"
            Purpose      = "Validate operator-controlled retry-entry resume preparation and invalid-state refusal behavior."
            Command      = "powershell -ExecutionPolicy Bypass -File tests\test_resume_reentry.ps1"
        }
        [pscustomobject]@{
            Id           = "r5-repo-enforcement"
            Name         = "R5 repo enforcement"
            RelativePath = "tests/test_repo_enforcement.ps1"
            Purpose      = "Validate bounded repo-enforcement allow and blocked decisions around proof coverage and worktree discipline."
            Command      = "powershell -ExecutionPolicy Bypass -File tests\test_repo_enforcement.ps1"
        }
        [pscustomobject]@{
            Id           = "r5-proof-review"
            Name         = "R5 proof review"
            RelativePath = "tests/test_r5_recovery_resume_proof_review.ps1"
            Purpose      = "Validate the R5 proof-review entrypoint and bounded replay package assembly."
            Command      = "powershell -ExecutionPolicy Bypass -File tests\test_r5_recovery_resume_proof_review.ps1"
        }
    )

    return $definitions
}

function Get-StatusPathFromLine {
    param(
        [Parameter(Mandatory = $true)]
        [string]$StatusLine
    )

    if ($StatusLine.Length -lt 4) {
        return $null
    }

    $pathPart = $StatusLine.Substring(3).Trim()
    if ($pathPart -match " -> ") {
        $pathPart = ($pathPart -split " -> ")[-1]
    }

    if ($pathPart.StartsWith('"') -and $pathPart.EndsWith('"')) {
        $pathPart = $pathPart.Trim('"')
    }

    return $pathPart.Replace("\", "/")
}

function Test-StatusPathAllowed {
    param(
        [AllowNull()]
        [string]$StatusPath,
        [AllowNull()]
        [string]$AllowedPrefix
    )

    if ([string]::IsNullOrWhiteSpace($StatusPath) -or [string]::IsNullOrWhiteSpace($AllowedPrefix)) {
        return $false
    }

    if ($StatusPath.Equals($AllowedPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $true
    }

    return $StatusPath.StartsWith(($AllowedPrefix.TrimEnd("/") + "/"), [System.StringComparison]::OrdinalIgnoreCase)
}

function Get-UnexpectedStatusLines {
    param(
        [AllowEmptyCollection()]
        [Parameter(Mandatory = $true)]
        [string[]]$BeforeStatusLines,
        [AllowEmptyCollection()]
        [Parameter(Mandatory = $true)]
        [string[]]$AfterStatusLines,
        [AllowNull()]
        [string]$AllowedPrefix
    )

    $beforeSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
    foreach ($line in $BeforeStatusLines) {
        [void]$beforeSet.Add($line)
    }

    $unexpected = [System.Collections.Generic.List[string]]::new()
    foreach ($line in $AfterStatusLines) {
        if ($beforeSet.Contains($line)) {
            continue
        }

        $statusPath = Get-StatusPathFromLine -StatusLine $line
        if (Test-StatusPathAllowed -StatusPath $statusPath -AllowedPrefix $AllowedPrefix) {
            continue
        }

        $unexpected.Add($line)
    }

    return @($unexpected)
}

function Get-CurrentUtcTimestamp {
    return (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
}

function Invoke-BoundedProofSuite {
    [CmdletBinding()]
    param(
        [string]$OutputRoot,
        [string[]]$TestIds,
        [switch]$SkipWorkspaceMutationCheck
    )

    $resolvedOutputRoot = Resolve-OutputRootPath -OutputRoot $OutputRoot
    Ensure-Directory -Path $resolvedOutputRoot

    $metaRoot = Join-Path $resolvedOutputRoot "meta"
    $testLogRoot = Join-Path $resolvedOutputRoot "tests"
    Ensure-Directory -Path $metaRoot
    Ensure-Directory -Path $testLogRoot

    $selectedDefinitions = @()
    $suiteDefinitions = @(Get-BoundedProofSuiteDefinition)
    if ($null -ne $TestIds -and $TestIds.Count -gt 0) {
        $knownIds = @($suiteDefinitions | ForEach-Object { $_.Id })
        $unknownIds = @($TestIds | Where-Object { $knownIds -notcontains $_ })
        if ($unknownIds.Count -gt 0) {
            throw "Unknown bounded proof suite test id(s): $($unknownIds -join ', ')."
        }

        foreach ($testId in $TestIds) {
            $selectedDefinitions += $suiteDefinitions | Where-Object { $_.Id -eq $testId }
        }
    }
    else {
        $selectedDefinitions = $suiteDefinitions
    }

    if ($selectedDefinitions.Count -eq 0) {
        throw "The bounded proof suite selection is empty."
    }

    $powershellExecutable = Resolve-PowerShellExecutable
    $branch = Get-GitBranchName
    $headCommit = Get-GitHeadCommit
    $statusBefore = @(Get-GitStatusLines)
    $repoRelativeOutputRoot = Get-RepoRelativePathIfInsideRepo -Path $resolvedOutputRoot

    Write-Utf8File -Path (Join-Path $metaRoot "git_branch.txt") -Value $branch
    Write-Utf8File -Path (Join-Path $metaRoot "git_head.txt") -Value $headCommit
    Write-Utf8File -Path (Join-Path $metaRoot "git_status_before.txt") -Value ($statusBefore -join [Environment]::NewLine)
    Write-Utf8File -Path (Join-Path $metaRoot "repo_root.txt") -Value (Get-RepositoryRoot)
    Write-Utf8File -Path (Join-Path $metaRoot "pwd.txt") -Value (Get-Location).Path
    Write-Utf8File -Path (Join-Path $metaRoot "powershell_executable.txt") -Value $powershellExecutable

    $results = @()
    foreach ($definition in $selectedDefinitions) {
        $relativePath = $definition.RelativePath
        $absolutePath = Join-Path (Get-RepositoryRoot) ($relativePath -replace "/", "\")
        if (-not (Test-Path -LiteralPath $absolutePath)) {
            throw "Bounded proof case '$($definition.Id)' references missing script '$relativePath'."
        }

        $logPath = Join-Path $testLogRoot ("{0}.txt" -f $definition.Id)
        $startedAt = Get-Date
        $commandOutput = @(& $powershellExecutable -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $absolutePath 2>&1 | ForEach-Object { $_.ToString() })
        $exitCode = $LASTEXITCODE
        $endedAt = Get-Date
        $durationSeconds = [math]::Round(($endedAt - $startedAt).TotalSeconds, 3)
        $outputText = $commandOutput -join [Environment]::NewLine
        if ($commandOutput.Count -gt 0) {
            $outputText += [Environment]::NewLine
        }

        Write-Utf8File -Path $logPath -Value $outputText

        $results += [pscustomobject]@{
            id               = $definition.Id
            name             = $definition.Name
            relative_path    = $definition.RelativePath
            purpose          = $definition.Purpose
            command          = $definition.Command
            started_at       = $startedAt.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
            ended_at         = $endedAt.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
            duration_seconds = $durationSeconds
            status           = if ($exitCode -eq 0) { "passed" } else { "failed" }
            exit_code        = $exitCode
            log_path         = $logPath
            log_path_repo_relative = Get-RepoRelativePathIfInsideRepo -Path $logPath
        }
    }

    $statusAfter = @(Get-GitStatusLines)
    Write-Utf8File -Path (Join-Path $metaRoot "git_status_after.txt") -Value ($statusAfter -join [Environment]::NewLine)

    $unexpectedStatusLines = @()
    if (-not $SkipWorkspaceMutationCheck) {
        $unexpectedStatusLines = @(Get-UnexpectedStatusLines -BeforeStatusLines $statusBefore -AfterStatusLines $statusAfter -AllowedPrefix $repoRelativeOutputRoot)
    }

    $passedCount = @($results | Where-Object { $_.status -eq "passed" }).Count
    $failedCount = @($results | Where-Object { $_.status -eq "failed" }).Count

    $summary = [pscustomobject]@{
        suite_id                  = "aioffice-bounded-proof-suite"
        created_at                = Get-CurrentUtcTimestamp
        repo_branch               = $branch
        repo_head                 = $headCommit
        output_root               = $resolvedOutputRoot
        output_root_repo_relative = $repoRelativeOutputRoot
        powershell_executable     = $powershellExecutable
        selection_ids             = @($selectedDefinitions | ForEach-Object { $_.Id })
        results                   = $results
        passed_count              = $passedCount
        failed_count              = $failedCount
        workspace_mutation_check  = [pscustomobject]@{
            enabled               = (-not $SkipWorkspaceMutationCheck.IsPresent)
            allowed_output_prefix = $repoRelativeOutputRoot
            passed                = ($unexpectedStatusLines.Count -eq 0)
            unexpected_status     = $unexpectedStatusLines
        }
        proof_scope               = @(
            "R2 supervised workflow through architect plus bounded apply or promotion control",
            "R3 governed work object, planning record, work artifact, QA, Baton, and replay foundations",
            "R4 lifecycle, scope, retry-ceiling, and CI foundation hardening",
            "R5 Git-backed baseline, restore gate, bounded resume re-entry, repo enforcement, and proof-review foundations"
        )
        non_claims_preserved      = @(
            "No UI or control-room productization is proved here.",
            "No Standard or subproject runtime productization is proved here.",
            "No rollback execution or automatic resume behavior is proved here.",
            "No broader orchestration beyond the bounded chain is proved here."
        )
    }

    $summaryJsonPath = Join-Path $resolvedOutputRoot "bounded-proof-suite-summary.json"
    $summaryMarkdownPath = Join-Path $resolvedOutputRoot "bounded-proof-suite-summary.md"
    Write-Utf8File -Path $summaryJsonPath -Value ($summary | ConvertTo-Json -Depth 10)

    $markdown = @(
        "# Bounded Proof Suite Summary",
        "",
        "- Created at: $($summary.created_at)",
        "- Repo branch: $branch",
        "- Repo HEAD: $headCommit",
        "- Output root: $resolvedOutputRoot",
        "- PowerShell executable: $powershellExecutable",
        "- Passed: $passedCount",
        "- Failed: $failedCount",
        "- Workspace mutation check passed: $($summary.workspace_mutation_check.passed)",
        "",
        "## Commands Replayed"
    )
    foreach ($result in $results) {
        $markdown += "- $($result.command)"
    }
    $markdown += ""
    $markdown += "## Results"
    foreach ($result in $results) {
        $logReference = if ([string]::IsNullOrWhiteSpace($result.log_path_repo_relative)) { $result.log_path } else { $result.log_path_repo_relative }
        $markdown += "- $($result.id): $($result.status) ($($result.duration_seconds)s) -> $logReference"
    }
    if ($unexpectedStatusLines.Count -gt 0) {
        $markdown += ""
        $markdown += "## Unexpected Workspace Status"
        foreach ($line in $unexpectedStatusLines) {
            $markdown += "- $line"
        }
    }

    Write-Utf8File -Path $summaryMarkdownPath -Value ($markdown -join [Environment]::NewLine)

    if ($failedCount -gt 0 -or $unexpectedStatusLines.Count -gt 0) {
        throw "The bounded proof suite failed. See '$summaryJsonPath' for details."
    }

    return [pscustomobject]@{
        OutputRoot               = $resolvedOutputRoot
        SummaryPath              = $summaryJsonPath
        SummaryMarkdownPath      = $summaryMarkdownPath
        PassedCount              = $passedCount
        FailedCount              = $failedCount
        WorkspaceMutationPassed  = ($unexpectedStatusLines.Count -eq 0)
        Results                  = $results
    }
}

Export-ModuleMember -Function Get-BoundedProofSuiteDefinition, Invoke-BoundedProofSuite
