$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$externalProofFixture = Join-Path $repoRoot "state/fixtures/valid/external_proof_bundle/external_proof_artifact_bundle.valid.json"
$closeoutFixture = Join-Path $repoRoot "state/fixtures/valid/external_runner_artifact/r10_closeout_identity.valid.json"

Write-Output ("PowerShell version: {0}" -f $PSVersionTable.PSVersion)
Write-Output ("ConvertFrom-Json supports -NoEnumerate: {0}" -f (Get-ConvertFromJsonNoEnumerateSupport))
Write-Output ("ConvertFrom-Json supports -DateKind String: {0}" -f (Get-ConvertFromJsonDateKindStringSupport))

$externalProofDocument = Read-SingleJsonObject -Path $externalProofFixture -Label "External proof fixture"
Write-Output ("External proof fixture root type: {0}" -f $externalProofDocument.GetType().FullName)
Write-Output ("External proof fixture contract_version visible: {0}" -f (-not [string]::IsNullOrWhiteSpace($externalProofDocument.contract_version)))
Write-Output ("External proof fixture created_at_utc type: {0}" -f $externalProofDocument.created_at_utc.GetType().FullName)

$closeoutDocument = Read-SingleJsonObject -Path $closeoutFixture -Label "Closeout identity fixture"
Write-Output ("Closeout identity fixture root type: {0}" -f $closeoutDocument.GetType().FullName)
Write-Output ("Closeout identity fixture contract_version visible: {0}" -f (-not [string]::IsNullOrWhiteSpace($closeoutDocument.contract_version)))
Write-Output ("Closeout identity fixture triggered_at_utc type: {0}" -f $closeoutDocument.triggered_at_utc.GetType().FullName)
Write-Output ("Closeout identity fixture completed_at_utc type: {0}" -f $closeoutDocument.completed_at_utc.GetType().FullName)

$arrayRootPath = Join-Path ([System.IO.Path]::GetTempPath()) ("json-root-array-probe-" + [guid]::NewGuid().ToString("N") + ".json")
try {
    Set-Content -LiteralPath $arrayRootPath -Value '[{"contract_version":"v1"}]' -Encoding UTF8
    $arrayRootShape = Test-JsonRootShape -Path $arrayRootPath -Label "Array root probe"
    Write-Output ("Array root rejected before field validation: {0}" -f (-not $arrayRootShape.IsSingleJsonObject))
    Write-Output ("Array root rejection: {0}" -f $arrayRootShape.Error)
}
finally {
    if (Test-Path -LiteralPath $arrayRootPath) {
        Remove-Item -LiteralPath $arrayRootPath -Force
    }
}
