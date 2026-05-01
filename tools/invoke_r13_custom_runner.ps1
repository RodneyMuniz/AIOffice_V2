[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RequestPath,
    [Parameter(Mandatory = $true)]
    [string]$OutputPath,
    [switch]$StrictRepoIdentity
)

$ErrorActionPreference = "Stop"

$strictRepoIdentityValue = $true
if ($PSBoundParameters.ContainsKey("StrictRepoIdentity")) {
    $strictRepoIdentityValue = [bool]$StrictRepoIdentity
}

$module = Import-Module (Join-Path $PSScriptRoot "R13CustomRunner.psm1") -Force -PassThru
$invokeRunner = $module.ExportedCommands["Invoke-R13CustomRunner"]
$writeJson = $module.ExportedCommands["Write-R13CustomRunnerJsonFile"]

try {
    $request = Get-Content -LiteralPath $RequestPath -Raw | ConvertFrom-Json
    $expectedResultRef = [string]$request.expected_result_ref
    $repoRoot = Split-Path -Parent $PSScriptRoot
    if ([System.IO.Path]::IsPathRooted($OutputPath)) {
        $outputPathForResolution = $OutputPath
    }
    else {
        $outputPathForResolution = Join-Path $repoRoot $OutputPath
    }
    $resolvedOutputPath = [System.IO.Path]::GetFullPath($outputPathForResolution)
    $resolvedExpectedPath = [System.IO.Path]::GetFullPath((Join-Path $repoRoot $expectedResultRef))
    if (-not $resolvedOutputPath.Equals($resolvedExpectedPath, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "OutputPath must match request expected_result_ref '$expectedResultRef'."
    }

    $result = & $invokeRunner -RequestPath $RequestPath -StrictRepoIdentity:$strictRepoIdentityValue
    & $writeJson -Path $OutputPath -Value $result

    $commandResults = @($result.command_results)
    $passedCommandCount = @($commandResults | Where-Object { [string]$_.verdict -eq "passed" }).Count
    $failedCommandCount = @($commandResults | Where-Object { [string]$_.verdict -eq "failed" }).Count

    Write-Output ("request_id: {0}" -f $result.request_id)
    Write-Output ("operation: {0}" -f $result.requested_operation)
    Write-Output ("command count: {0}" -f $commandResults.Count)
    Write-Output ("passed command count: {0}" -f $passedCommandCount)
    Write-Output ("failed command count: {0}" -f $failedCommandCount)
    Write-Output ("aggregate_verdict: {0}" -f $result.aggregate_verdict)

    if ($result.aggregate_verdict -eq "passed" -or $result.aggregate_verdict -eq "failed") {
        exit 0
    }

    exit 1
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
