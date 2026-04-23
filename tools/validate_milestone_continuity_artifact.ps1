[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ArtifactPath
)

$ErrorActionPreference = "Stop"

$modulePath = Join-Path $PSScriptRoot "MilestoneContinuity.psm1"
Import-Module $modulePath -Force

try {
    $result = Test-MilestoneContinuityArtifactContract -ArtifactPath $ArtifactPath
    Write-Output ("VALID: continuity artifact '{0}' ({1}) at '{2}'." -f $result.ArtifactId, $result.RecordType, $result.ArtifactPath)
    exit 0
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
