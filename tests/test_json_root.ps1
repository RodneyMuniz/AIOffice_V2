$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $repoRoot "tools/JsonRoot.psm1") -Force

function New-JsonRootTestPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    return Join-Path $script:testRoot $Name
}

function Write-TestJson {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Content
    )

    $path = New-JsonRootTestPath -Name $Name
    Set-Content -LiteralPath $path -Value $Content -Encoding UTF8
    return $path
}

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
            $script:failures += ("FAIL invalid: {0} refusal missed fragments {1}. Actual: {2}" -f $Label, ($missingFragments -join ", "), $message)
            return
        }

        Write-Output ("PASS invalid: {0} -> {1}" -f $Label, $message)
        $script:invalidRejected += 1
    }
}

$script:testRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("jsonroot" + [guid]::NewGuid().ToString("N").Substring(0, 8))
$validPassed = 0
$invalidRejected = 0
$failures = @()

New-Item -ItemType Directory -Path $script:testRoot -Force | Out-Null

try {
    $objectPath = Write-TestJson -Name "object.json" -Content '{"contract_version":"v1","name":"validator-only"}'
    $objectDocument = Read-SingleJsonObject -Path $objectPath -Label "Valid object root"
    if ($objectDocument -isnot [pscustomobject]) {
        $failures += "FAIL valid: object root did not load as PSCustomObject."
    }
    elseif ($objectDocument.contract_version -ne "v1") {
        $failures += "FAIL valid: contract_version was not visible on loaded root object."
    }
    else {
        Write-Output "PASS valid: object root loads as one PSCustomObject with visible contract_version."
        $validPassed += 1
    }

    $timestampPath = Write-TestJson -Name "timestamps.json" -Content '{"contract_version":"v1","created_at_utc":"2026-04-28T00:00:00Z","triggered_at_utc":"2026-04-28T00:01:00Z","completed_at_utc":"2026-04-28T00:02:00Z"}'
    $timestampDocument = Read-SingleJsonObject -Path $timestampPath -Label "Timestamp object root"
    if ($timestampDocument.created_at_utc -isnot [string] -or $timestampDocument.triggered_at_utc -isnot [string] -or $timestampDocument.completed_at_utc -isnot [string]) {
        $failures += "FAIL valid: root timestamp fields did not remain strings."
    }
    else {
        Write-Output "PASS valid: root timestamp fields remain strings."
        $validPassed += 1
    }

    $nestedTimestampPath = Write-TestJson -Name "nested-timestamps.json" -Content '{"contract_version":"v1","meta":{"created_at_utc":"2026-04-28T00:03:00Z"},"items":[{"completed_at_utc":"2026-04-28T00:04:00Z"},{"observed_at_utc":"2026-04-28T00:05:00Z"}]}'
    $nestedTimestampDocument = Read-SingleJsonObject -Path $nestedTimestampPath -Label "Nested timestamp object root"
    if ($nestedTimestampDocument.meta.created_at_utc -isnot [string] -or @($nestedTimestampDocument.items)[0].completed_at_utc -isnot [string] -or @($nestedTimestampDocument.items)[1].observed_at_utc -isnot [string]) {
        $failures += "FAIL valid: nested or array timestamp fields did not remain strings."
    }
    else {
        Write-Output "PASS valid: nested object and array timestamp fields remain strings."
        $validPassed += 1
    }

    $nestedArrayPath = Write-TestJson -Name "nested-array.json" -Content '{"contract_version":"v1","items":[{"id":"one"},{"id":"two"}]}'
    $nestedArrayDocument = Read-SingleJsonObject -Path $nestedArrayPath -Label "Nested array object root"
    if ($nestedArrayDocument.items.Count -ne 2 -or $nestedArrayDocument.contract_version -ne "v1") {
        $failures += "FAIL valid: object root with nested arrays did not load correctly."
    }
    else {
        Write-Output "PASS valid: object root with nested arrays is accepted."
        $validPassed += 1
    }

    $captured = @(Read-SingleJsonObject -Path $objectPath -Label "Enumeration probe")
    if ($captured.Count -ne 1 -or $captured[0] -isnot [pscustomobject] -or $captured[0].contract_version -ne "v1") {
        $failures += "FAIL valid: Read-SingleJsonObject output enumerated the root object into property streams."
    }
    else {
        Write-Output "PASS valid: function output preserves one root object."
        $validPassed += 1
    }

    Invoke-ExpectedRefusal -Label "array-root" -RequiredFragments @("single JSON object", "array root") -Action {
        $path = Write-TestJson -Name "array-root.json" -Content '[{"contract_version":"v1"}]'
        Read-SingleJsonObject -Path $path -Label "Array root input" | Out-Null
    }

    Invoke-ExpectedRefusal -Label "scalar-root" -RequiredFragments @("single JSON object", "root does not start") -Action {
        $path = Write-TestJson -Name "scalar-root.json" -Content '"v1"'
        Read-SingleJsonObject -Path $path -Label "Scalar root input" | Out-Null
    }

    Invoke-ExpectedRefusal -Label "empty-file" -RequiredFragments @("single JSON object", "empty") -Action {
        $path = Write-TestJson -Name "empty.json" -Content ""
        Read-SingleJsonObject -Path $path -Label "Empty input" | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-json" -RequiredFragments @("not valid JSON") -Action {
        $path = Write-TestJson -Name "invalid.json" -Content '{"contract_version":'
        Read-SingleJsonObject -Path $path -Label "Invalid JSON input" | Out-Null
    }
}
finally {
    if (Test-Path -LiteralPath $script:testRoot) {
        Remove-Item -LiteralPath $script:testRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("JSON root tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All JSON root tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
