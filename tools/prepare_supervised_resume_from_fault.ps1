[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ResumeRequestPath,
    [Parameter(Mandatory = $true)]
    [string]$ResumeResultPath
)

$ErrorActionPreference = "Stop"

$modulePath = Join-Path $PSScriptRoot "MilestoneContinuityResume.psm1"
Import-Module $modulePath -Force

try {
    $result = Invoke-MilestoneContinuityResumeFromFault -ResumeRequestPath $ResumeRequestPath -ResumeResultPath $ResumeResultPath
    Write-Output ("PREPARED: supervised resume result '{0}' at '{1}'." -f $result.Validation.ResumeResultId, $result.ResumeResultPath)
    exit 0
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
