[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$RegistryPath,
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

$module = Import-Module (Join-Path $PSScriptRoot "R13SkillInvocation.psm1") -Force -PassThru
$registryModule = Import-Module (Join-Path $PSScriptRoot "R13SkillRegistry.psm1") -Force -PassThru
$invokeSkill = $module.ExportedCommands["Invoke-R13Skill"]
$testResult = $module.ExportedCommands["Test-R13SkillInvocationResult"]
$writeJson = $registryModule.ExportedCommands["Write-R13SkillJsonFile"]

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

    $result = & $invokeSkill -RegistryPath $RegistryPath -RequestPath $RequestPath -StrictRepoIdentity:$strictRepoIdentityValue
    & $writeJson -Path $OutputPath -Value $result
    $validation = & $testResult -ResultPath $OutputPath -RegistryPath $RegistryPath

    Write-Output ("skill_id: {0}" -f $result.skill_id)
    Write-Output ("command count: {0}" -f $validation.CommandCount)
    Write-Output ("passed command count: {0}" -f $validation.PassedCommandCount)
    Write-Output ("failed command count: {0}" -f $validation.FailedCommandCount)
    Write-Output ("aggregate_verdict: {0}" -f $result.aggregate_verdict)

    if ($result.execution_status -eq "completed" -and ($result.aggregate_verdict -eq "passed" -or $result.aggregate_verdict -eq "failed")) {
        exit 0
    }

    exit 1
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
