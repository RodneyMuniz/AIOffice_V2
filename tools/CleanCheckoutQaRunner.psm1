Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot

function Get-RepositoryRoot {
    return $repoRoot
}

function Get-ModuleRepositoryRootPath {
    return (Resolve-Path -LiteralPath (Get-RepositoryRoot)).Path
}

function Resolve-PathValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [string]$AnchorPath = (Get-ModuleRepositoryRootPath)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    $resolvedAnchorPath = if (Test-Path -LiteralPath $AnchorPath) {
        (Resolve-Path -LiteralPath $AnchorPath).Path
    }
    else {
        [System.IO.Path]::GetFullPath($AnchorPath)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $resolvedAnchorPath $PathValue))
}

function Resolve-ExistingPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [string]$AnchorPath = (Get-ModuleRepositoryRootPath)
    )

    $resolvedPath = Resolve-PathValue -PathValue $PathValue -AnchorPath $AnchorPath
    if (-not (Test-Path -LiteralPath $resolvedPath)) {
        throw "$Label '$PathValue' does not exist."
    }

    return (Resolve-Path -LiteralPath $resolvedPath).Path
}

function Write-Utf8File {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [AllowNull()]
        [string]$Value
    )

    $directory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($directory) -and -not (Test-Path -LiteralPath $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    if ($null -eq $Value) {
        $Value = ""
    }

    Set-Content -LiteralPath $Path -Value $Value -Encoding UTF8
}

function Write-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Document
    )

    $json = $Document | ConvertTo-Json -Depth 30
    Write-Utf8File -Path $Path -Value $json
}

function ConvertTo-ProcessArgumentString {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$ArgumentList
    )

    $encodedArguments = foreach ($argument in $ArgumentList) {
        if ($null -eq $argument) {
            '""'
            continue
        }

        if ($argument -notmatch '[\s"]') {
            $argument
            continue
        }

        $builder = New-Object System.Text.StringBuilder
        [void]$builder.Append('"')
        $pendingBackslashes = 0
        foreach ($character in $argument.ToCharArray()) {
            if ($character -eq '\') {
                $pendingBackslashes += 1
                continue
            }

            if ($character -eq '"') {
                if ($pendingBackslashes -gt 0) {
                    [void]$builder.Append([string]::new([char]92, ($pendingBackslashes * 2)))
                    $pendingBackslashes = 0
                }

                [void]$builder.Append('\')
                [void]$builder.Append('"')
                continue
            }

            if ($pendingBackslashes -gt 0) {
                [void]$builder.Append([string]::new([char]92, $pendingBackslashes))
                $pendingBackslashes = 0
            }

            [void]$builder.Append($character)
        }

        if ($pendingBackslashes -gt 0) {
            [void]$builder.Append([string]::new([char]92, ($pendingBackslashes * 2)))
        }

        [void]$builder.Append('"')
        $builder.ToString()
    }

    return [string]::Join(" ", @($encodedArguments))
}

function Get-QaProofFoundationContract {
    return Get-Content -LiteralPath (Join-Path (Get-RepositoryRoot) "contracts\qa_proof\foundation.contract.json") -Raw | ConvertFrom-Json
}

function Assert-NonEmptyString {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -isnot [string] -or [string]::IsNullOrWhiteSpace($Value)) {
        throw "$Context must be a non-empty string."
    }

    return $Value
}

function Assert-StringArray {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($null -eq $Value -or $Value -is [string] -or -not ($Value -is [System.Collections.IEnumerable])) {
        throw "$Context must be an array."
    }

    $items = @($Value)
    if ($items.Count -eq 0) {
        throw "$Context must not be empty."
    }

    foreach ($item in $items) {
        Assert-NonEmptyString -Value $item -Context "$Context item" | Out-Null
    }

    Write-Output -NoEnumerate $items
}

function Assert-MatchesPattern {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Pattern,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -notmatch $Pattern) {
        throw "$Context does not match required pattern '$Pattern'."
    }
}

function Get-UtcTimestamp {
    param(
        [datetime]$DateTime = (Get-Date).ToUniversalTime()
    )

    return $DateTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
}

function Get-RelativeReference {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory,
        [Parameter(Mandatory = $true)]
        [string]$TargetPath
    )

    $resolvedBaseDirectory = if (Test-Path -LiteralPath $BaseDirectory) {
        (Resolve-Path -LiteralPath $BaseDirectory).Path
    }
    else {
        [System.IO.Path]::GetFullPath($BaseDirectory)
    }

    $resolvedTargetPath = Resolve-ExistingPath -PathValue $TargetPath -Label "Target path"
    $baseUri = [System.Uri]("{0}{1}" -f $resolvedBaseDirectory.TrimEnd("\/"), [System.IO.Path]::DirectorySeparatorChar)
    $targetUri = [System.Uri]$resolvedTargetPath
    return ($baseUri.MakeRelativeUri($targetUri).OriginalString).Replace("\", "/")
}

function Convert-GitStatusTextToState {
    param([string]$StatusText)

    if ([string]::IsNullOrWhiteSpace($StatusText)) {
        return "clean"
    }

    return "dirty"
}

function Invoke-ProcessCapture {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FileName,
        [string]$Arguments,
        [string[]]$ArgumentList,
        [Parameter(Mandatory = $true)]
        [string]$WorkingDirectory
    )

    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = $FileName
    if ($null -ne $ArgumentList -and $ArgumentList.Count -gt 0) {
        $processInfo.Arguments = ConvertTo-ProcessArgumentString -ArgumentList $ArgumentList
    }
    else {
        $processInfo.Arguments = $Arguments
    }
    $processInfo.WorkingDirectory = $WorkingDirectory
    $processInfo.RedirectStandardOutput = $true
    $processInfo.RedirectStandardError = $true
    $processInfo.UseShellExecute = $false
    $processInfo.CreateNoWindow = $true

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $processInfo
    $null = $process.Start()
    $stdout = $process.StandardOutput.ReadToEnd()
    $stderr = $process.StandardError.ReadToEnd()
    $process.WaitForExit()

    return [pscustomobject]@{
        ExitCode = $process.ExitCode
        StdOut = $stdout
        StdErr = $stderr
    }
}

function Get-DisposableGitConfigArguments {
    return @("-c", "core.longpaths=true", "-c", "core.autocrlf=false")
}

function Invoke-GitCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [switch]$UseDisposableGitSettings
    )

    $gitArguments = @()
    if ($UseDisposableGitSettings) {
        $gitArguments += Get-DisposableGitConfigArguments
    }

    $gitArguments += @("-C", $RepositoryRoot)
    $gitArguments += $Arguments

    $processResult = Invoke-ProcessCapture -FileName "git" -ArgumentList $gitArguments -WorkingDirectory $RepositoryRoot
    $outputText = @(
        $processResult.StdOut,
        $processResult.StdErr
    ) -join [Environment]::NewLine
    $outputText = $outputText.Trim()
    if ($processResult.ExitCode -ne 0) {
        if ([string]::IsNullOrWhiteSpace($outputText)) {
            throw "$Context failed."
        }

        throw ("{0} failed. Git output: {1}" -f $Context, $outputText)
    }

    return $outputText
}

function Get-GitTrimmedValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [switch]$UseDisposableGitSettings
    )

    return (Invoke-GitCommand -RepositoryRoot $RepositoryRoot -Arguments $Arguments -Context $Context -UseDisposableGitSettings:$UseDisposableGitSettings).Trim()
}

function Get-GitBranchName {
    param([Parameter(Mandatory = $true)][string]$RepositoryRoot)
    return Get-GitTrimmedValue -RepositoryRoot $RepositoryRoot -Arguments @("branch", "--show-current") -Context "Git branch lookup"
}

function Get-GitRemoteHeadCommit {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string]$RemoteName,
        [Parameter(Mandatory = $true)]
        [string]$Branch
    )

    try {
        $output = @(& git -C $RepositoryRoot ls-remote $RemoteName ("refs/heads/{0}" -f $Branch) 2>&1)
    }
    catch {
        throw "Clean-checkout remote head lookup failed for remote '$RemoteName' branch '$Branch'."
    }

    if ($LASTEXITCODE -ne 0) {
        throw "Clean-checkout remote head lookup failed for remote '$RemoteName' branch '$Branch'."
    }

    $line = ([string]::Join([Environment]::NewLine, @($output))).Trim()
    if ([string]::IsNullOrWhiteSpace($line)) {
        throw "Clean-checkout remote branch head was not found for remote '$RemoteName' branch '$Branch'."
    }

    $parts = $line -split "\s+"
    if ($parts.Count -lt 1 -or [string]::IsNullOrWhiteSpace($parts[0])) {
        throw "Clean-checkout remote head lookup returned malformed output for remote '$RemoteName' branch '$Branch'."
    }

    return $parts[0].Trim()
}

function Get-GitHeadCommit {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [switch]$UseDisposableGitSettings
    )

    return Get-GitTrimmedValue -RepositoryRoot $RepositoryRoot -Arguments @("rev-parse", "HEAD") -Context "Git HEAD lookup" -UseDisposableGitSettings:$UseDisposableGitSettings
}

function Get-GitTreeId {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [switch]$UseDisposableGitSettings
    )

    return Get-GitTrimmedValue -RepositoryRoot $RepositoryRoot -Arguments @("rev-parse", "HEAD^{tree}") -Context "Git tree lookup" -UseDisposableGitSettings:$UseDisposableGitSettings
}

function Get-GitStatusPorcelainText {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [switch]$UseDisposableGitSettings
    )

    return Invoke-GitCommand -RepositoryRoot $RepositoryRoot -Arguments @("status", "--porcelain") -Context "Git status --porcelain" -UseDisposableGitSettings:$UseDisposableGitSettings
}

function Get-GitDiffCheckText {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [switch]$UseDisposableGitSettings
    )

    $gitArguments = @()
    if ($UseDisposableGitSettings) {
        $gitArguments += Get-DisposableGitConfigArguments
    }

    $gitArguments += @("-C", $RepositoryRoot, "diff", "--check")
    $processResult = Invoke-ProcessCapture -FileName "git" -ArgumentList $gitArguments -WorkingDirectory $RepositoryRoot
    $outputText = @(
        $processResult.StdOut,
        $processResult.StdErr
    ) -join [Environment]::NewLine

    return [pscustomobject]@{
        ExitCode = $processResult.ExitCode
        Output = $outputText.Trim()
    }
}

function Get-DisposableCheckoutBaseRoot {
    $preferredRoot = "C:\t"
    try {
        if (-not (Test-Path -LiteralPath $preferredRoot)) {
            New-Item -ItemType Directory -Path $preferredRoot -Force | Out-Null
        }
    }
    catch {
    }

    if (Test-Path -LiteralPath $preferredRoot) {
        return (Resolve-Path -LiteralPath $preferredRoot).Path
    }

    return [System.IO.Path]::GetTempPath().TrimEnd("\/")
}

function Initialize-DisposableWorktree {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string]$CheckoutRoot,
        [Parameter(Mandatory = $true)]
        [string]$RemoteSha
    )

    $checkoutParent = Split-Path -Parent $CheckoutRoot
    if (-not [string]::IsNullOrWhiteSpace($checkoutParent) -and -not (Test-Path -LiteralPath $checkoutParent)) {
        New-Item -ItemType Directory -Path $checkoutParent -Force | Out-Null
    }

    Invoke-GitCommand -RepositoryRoot $RepositoryRoot -Arguments @("worktree", "add", "--detach", $CheckoutRoot, $RemoteSha) -Context "Disposable worktree add" -UseDisposableGitSettings | Out-Null
    Invoke-GitCommand -RepositoryRoot $CheckoutRoot -Arguments @("config", "core.longpaths", "true") -Context "Disposable worktree long-path config" | Out-Null
    Invoke-GitCommand -RepositoryRoot $CheckoutRoot -Arguments @("config", "core.autocrlf", "false") -Context "Disposable worktree autocrlf config" | Out-Null
}

function Remove-DisposableWorktree {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string]$CheckoutRoot
    )

    if (-not (Test-Path -LiteralPath $CheckoutRoot)) {
        return
    }

    Invoke-GitCommand -RepositoryRoot $RepositoryRoot -Arguments @("worktree", "remove", "--force", $CheckoutRoot) -Context "Disposable worktree cleanup" -UseDisposableGitSettings | Out-Null
    if (Test-Path -LiteralPath $CheckoutRoot) {
        Remove-Item -LiteralPath $CheckoutRoot -Recurse -Force -ErrorAction Stop
    }

    if (Test-Path -LiteralPath $CheckoutRoot) {
        throw "Disposable worktree cleanup left checkout path '$CheckoutRoot' behind."
    }
}

function Get-FileSha256 {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLower()
}

function Invoke-LoggedPowerShellCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorkingDirectory,
        [Parameter(Mandatory = $true)]
        [string]$Command,
        [Parameter(Mandatory = $true)]
        [string]$StdOutPath,
        [Parameter(Mandatory = $true)]
        [string]$StdErrPath,
        [Parameter(Mandatory = $true)]
        [string]$CommandId
    )

    $scriptText = @(
        ("Set-Location -LiteralPath '{0}'" -f $WorkingDirectory.Replace("'", "''")),
        $Command
    ) -join [Environment]::NewLine
    $encodedCommand = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($scriptText))
    $processResult = Invoke-ProcessCapture -FileName "powershell.exe" -Arguments ("-NoProfile -ExecutionPolicy Bypass -EncodedCommand {0}" -f $encodedCommand) -WorkingDirectory $WorkingDirectory

    Write-Utf8File -Path $StdOutPath -Value $processResult.StdOut
    Write-Utf8File -Path $StdErrPath -Value $processResult.StdErr

    return [pscustomobject]@{
        command_id = $CommandId
        command = $Command
        stdout_path = $StdOutPath
        stderr_path = $StdErrPath
        exit_code = $processResult.ExitCode
        status = if ($processResult.ExitCode -eq 0) { "passed" } else { "failed" }
    }
}

function Invoke-CleanCheckoutQaRun {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryName,
        [Parameter(Mandatory = $true)]
        [string]$Branch,
        [Parameter(Mandatory = $true)]
        [string]$RemoteSha,
        [Parameter(Mandatory = $true)]
        [string[]]$Commands,
        [Parameter(Mandatory = $true)]
        [string]$OutputRoot,
        [string]$RemoteName = "origin"
    )

    $foundation = Get-QaProofFoundationContract
    $qaProofModule = Import-Module (Join-Path $PSScriptRoot "QaProofPacket.psm1") -Force -PassThru
    $testQaProofPacket = $qaProofModule.ExportedCommands["Test-QaProofPacketContract"]

    $resolvedRepositoryRoot = Resolve-ExistingPath -PathValue $RepositoryRoot -Label "Repository root"
    $repositoryNameValue = Assert-NonEmptyString -Value $RepositoryName -Context "RepositoryName"
    Assert-MatchesPattern -Value $repositoryNameValue -Pattern $foundation.repository_name_pattern -Context "RepositoryName"
    if ($repositoryNameValue -ne $foundation.repository_name) {
        throw "RepositoryName must be '$($foundation.repository_name)'."
    }

    $branchValue = Assert-NonEmptyString -Value $Branch -Context "Branch"
    Assert-MatchesPattern -Value $branchValue -Pattern $foundation.branch_pattern -Context "Branch"

    $remoteShaValue = Assert-NonEmptyString -Value $RemoteSha -Context "RemoteSha"
    Assert-MatchesPattern -Value $remoteShaValue -Pattern $foundation.git_object_pattern -Context "RemoteSha"

    $declaredCommands = Assert-StringArray -Value $Commands -Context "Commands"

    $currentBranch = Get-GitBranchName -RepositoryRoot $resolvedRepositoryRoot
    if ($currentBranch -ne $branchValue) {
        throw "Repository current branch '$currentBranch' does not match requested branch '$branchValue'."
    }

    $actualRemoteHead = Get-GitRemoteHeadCommit -RepositoryRoot $resolvedRepositoryRoot -RemoteName $RemoteName -Branch $branchValue
    if ($actualRemoteHead -ne $remoteShaValue) {
        throw "Requested RemoteSha '$remoteShaValue' does not match actual remote head '$actualRemoteHead' for branch '$branchValue'."
    }

    $resolvedOutputRoot = Resolve-PathValue -PathValue $OutputRoot -AnchorPath $resolvedRepositoryRoot
    $logsRoot = Join-Path $resolvedOutputRoot "logs"
    $artifactsRoot = Join-Path $resolvedOutputRoot "artifacts"
    New-Item -ItemType Directory -Path $logsRoot -Force | Out-Null
    New-Item -ItemType Directory -Path $artifactsRoot -Force | Out-Null

    $checkoutRoot = Join-Path (Get-DisposableCheckoutBaseRoot) ("r8wt" + [guid]::NewGuid().ToString("N").Substring(0, 10))
    $packetPath = Join-Path $resolvedOutputRoot "qa_proof_packet.json"
    $result = $null
    $runError = $null
    $cleanupError = $null

    try {
        Initialize-DisposableWorktree -RepositoryRoot $resolvedRepositoryRoot -CheckoutRoot $checkoutRoot -RemoteSha $remoteShaValue

        $checkedOutHead = Get-GitHeadCommit -RepositoryRoot $checkoutRoot -UseDisposableGitSettings
        if ($checkedOutHead -ne $remoteShaValue) {
            throw "Checked-out HEAD '$checkedOutHead' does not match requested remote SHA '$remoteShaValue'."
        }

        $treeHash = Get-GitTreeId -RepositoryRoot $checkoutRoot -UseDisposableGitSettings

        $statusBeforeText = Get-GitStatusPorcelainText -RepositoryRoot $checkoutRoot -UseDisposableGitSettings
        $statusBeforeLogPath = Join-Path $logsRoot "git_status_porcelain_before.log"
        Write-Utf8File -Path $statusBeforeLogPath -Value $statusBeforeText

        $commandResults = @()
        $hasFailedCommand = $false
        for ($i = 0; $i -lt $declaredCommands.Count; $i++) {
            $commandId = "command-{0}" -f ($i + 1).ToString("000")
            $stdoutPath = Join-Path $logsRoot ("{0}.stdout.log" -f $commandId)
            $stderrPath = Join-Path $logsRoot ("{0}.stderr.log" -f $commandId)
            $commandResult = Invoke-LoggedPowerShellCommand -WorkingDirectory $checkoutRoot -Command $declaredCommands[$i] -StdOutPath $stdoutPath -StdErrPath $stderrPath -CommandId $commandId
            if ($commandResult.status -eq "failed") {
                $hasFailedCommand = $true
            }
            $commandResults += [pscustomobject]@{
                command_id = $commandResult.command_id
                command = $commandResult.command
                stdout_log_ref = Get-RelativeReference -BaseDirectory $resolvedOutputRoot -TargetPath $commandResult.stdout_path
                stderr_log_ref = Get-RelativeReference -BaseDirectory $resolvedOutputRoot -TargetPath $commandResult.stderr_path
                exit_code = $commandResult.exit_code
                status = $commandResult.status
            }
        }

        $statusAfterText = Get-GitStatusPorcelainText -RepositoryRoot $checkoutRoot -UseDisposableGitSettings
        $statusAfterLogPath = Join-Path $logsRoot "git_status_porcelain_after.log"
        Write-Utf8File -Path $statusAfterLogPath -Value $statusAfterText

        $diffCheckLogPath = Join-Path $logsRoot "git_diff_check.log"
        $diffCheckResult = Get-GitDiffCheckText -RepositoryRoot $checkoutRoot -UseDisposableGitSettings
        Write-Utf8File -Path $diffCheckLogPath -Value $diffCheckResult.Output.Trim()

        $statusBeforeState = Convert-GitStatusTextToState -StatusText $statusBeforeText
        $statusAfterState = Convert-GitStatusTextToState -StatusText $statusAfterText

        $refusalReasons = @()
        if ($hasFailedCommand) {
            $refusalReasons += "One or more declared QA commands failed."
        }
        if ($statusBeforeState -eq "dirty") {
            $refusalReasons += "Disposable checkout was dirty before QA commands."
        }
        if ($statusAfterState -eq "dirty") {
            $refusalReasons += "Disposable checkout was dirty after QA commands."
        }
        if ($diffCheckResult.ExitCode -ne 0) {
            $refusalReasons += "Disposable checkout failed git diff --check after QA commands."
        }

        $qaVerdict = if ($refusalReasons.Count -eq 0) { "passed" } else { "failed" }

        $commandManifestPath = Join-Path $artifactsRoot "command_manifest.json"
        Write-JsonDocument -Path $commandManifestPath -Document ([pscustomobject]@{
                branch = $branchValue
                remote_sha = $remoteShaValue
                command_count = $declaredCommands.Count
                commands = @($commandResults)
            })

        $qaRunSummaryPath = Join-Path $artifactsRoot "qa_run_summary.json"
        Write-JsonDocument -Path $qaRunSummaryPath -Document ([pscustomobject]@{
                repository_name = $repositoryNameValue
                branch = $branchValue
                remote_sha = $remoteShaValue
                checked_out_head = $checkedOutHead
                tree_hash = $treeHash
                qa_verdict = $qaVerdict
                refusal_reasons = @($refusalReasons)
                git_diff_check_exit_code = $diffCheckResult.ExitCode
                captured_at_utc = Get-UtcTimestamp
            })

        $packet = [pscustomobject]@{
            contract_version = $foundation.contract_version
            packet_type = $foundation.qa_proof_packet_type
            packet_id = ("qa-proof-{0}" -f ([guid]::NewGuid().ToString("N").Substring(0, 12)))
            repository = [pscustomobject]@{
                repository_name = $repositoryNameValue
                repository_root_relative = "."
            }
            branch = $branchValue
            local_head = $checkedOutHead
            remote_head = $remoteShaValue
            checked_out_head = $checkedOutHead
            tree_hash = $treeHash
            captured_at_utc = Get-UtcTimestamp
            command_list = @($declaredCommands)
            command_results = @($commandResults)
            environment = [pscustomobject]@{
                runner_kind = "clean_checkout_runner"
                runner_identity = "clean-checkout-qa-runner"
                platform = "windows"
                shell = "powershell"
                checkout_mode = "exact_remote_sha_pinned"
            }
            workspace_state = [pscustomobject]@{
                status_before = $statusBeforeState
                status_after = $statusAfterState
                git_status_porcelain_before_ref = Get-RelativeReference -BaseDirectory $resolvedOutputRoot -TargetPath $statusBeforeLogPath
                git_status_porcelain_after_ref = Get-RelativeReference -BaseDirectory $resolvedOutputRoot -TargetPath $statusAfterLogPath
                git_diff_check_ref = Get-RelativeReference -BaseDirectory $resolvedOutputRoot -TargetPath $diffCheckLogPath
            }
            artifact_hashes = @(
                [pscustomobject]@{
                    artifact_label = "command-manifest"
                    artifact_ref = Get-RelativeReference -BaseDirectory $resolvedOutputRoot -TargetPath $commandManifestPath
                    hash_sha256 = Get-FileSha256 -Path $commandManifestPath
                },
                [pscustomobject]@{
                    artifact_label = "qa-run-summary"
                    artifact_ref = Get-RelativeReference -BaseDirectory $resolvedOutputRoot -TargetPath $qaRunSummaryPath
                    hash_sha256 = Get-FileSha256 -Path $qaRunSummaryPath
                }
            )
            qa_verdict = $qaVerdict
            refusal_reasons = @($refusalReasons)
            executor_self_certification_state = "rejected_replaced_by_qa_packet"
            notes = "Disposable clean-checkout QA run for the exact remote SHA only via a short-path git worktree."
        }
        Write-JsonDocument -Path $packetPath -Document $packet
        $validation = & $testQaProofPacket -PacketPath $packetPath

        $result = [pscustomobject]@{
            OutputRoot = $resolvedOutputRoot
            PacketPath = $packetPath
            PacketId = $validation.PacketId
            Verdict = $validation.Verdict
            RemoteHead = $validation.RemoteHead
            CheckedOutHead = $validation.CheckedOutHead
            CheckoutRoot = $checkoutRoot
            CheckoutStrategy = "git_worktree"
        }
    }
    catch {
        $runError = $_
    }
    finally {
        try {
            Remove-DisposableWorktree -RepositoryRoot $resolvedRepositoryRoot -CheckoutRoot $checkoutRoot
        }
        catch {
            $cleanupError = $_
        }
    }

    if ($null -ne $cleanupError) {
        if ($null -ne $runError) {
            throw ("{0} Cleanup also failed: {1}" -f $runError.Exception.Message, $cleanupError.Exception.Message)
        }

        throw $cleanupError
    }

    if ($null -ne $runError) {
        throw $runError
    }

    return $result
}

Export-ModuleMember -Function Invoke-CleanCheckoutQaRun
