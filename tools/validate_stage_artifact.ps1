[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ArtifactPath
)

$ErrorActionPreference = "Stop"

$modulePath = Join-Path $PSScriptRoot "StageArtifactValidation.psm1"
Import-Module $modulePath -Force

try {
    $result = Test-StageArtifactContract -ArtifactPath $ArtifactPath
    Write-Output ("VALID: stage '{0}' artifact at '{1}'." -f $result.Stage, $result.ArtifactPath)
    exit 0
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
