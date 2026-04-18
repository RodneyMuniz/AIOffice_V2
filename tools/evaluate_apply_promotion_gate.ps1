[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$GateRequestPath,
    [string]$ResultStorePath
)

$ErrorActionPreference = "Stop"

$modulePath = Join-Path $PSScriptRoot "ApplyPromotionGate.psm1"
Import-Module $modulePath -Force

try {
    $gateResult = Invoke-ApplyPromotionGate -GateRequestPath $GateRequestPath
    $savedResult = Save-ApplyPromotionGateResult -GateResult $gateResult -StorePath $ResultStorePath

    if ($savedResult.GateResult.decision -eq "allow") {
        Write-Output ("ALLOW: gate result '{0}' saved to '{1}'." -f $savedResult.GateResult.gate_result_id, $savedResult.GateResultPath)
    }
    else {
        $reasonCodes = @($savedResult.GateResult.block_reasons | Select-Object -ExpandProperty code) -join ", "
        Write-Output ("BLOCKED: gate result '{0}' saved to '{1}'. Reasons: {2}" -f $savedResult.GateResult.gate_result_id, $savedResult.GateResultPath, $reasonCodes)
    }

    exit 0
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
