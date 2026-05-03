[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TaxonomyPath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R15ArtifactClassificationTaxonomy.psm1") -Force -PassThru
$testTaxonomy = $module.ExportedCommands["Test-R15ArtifactClassificationTaxonomy"]

try {
    $result = & $testTaxonomy -TaxonomyPath $TaxonomyPath
    Write-Output ("VALID: R15 artifact classification taxonomy '{0}' passed with {1} classes, {2} evidence kinds, {3} authority kinds, {4} lifecycle states, and {5} proof statuses." -f $result.TaxonomyId, $result.ClassificationClassCount, $result.EvidenceKindCount, $result.AuthorityKindCount, $result.LifecycleStateCount, $result.ProofStatusCount)
    exit 0
}
catch {
    Write-Output ("INVALID: R15 artifact classification taxonomy failed validation. {0}" -f $_.Exception.Message)
    exit 1
}
