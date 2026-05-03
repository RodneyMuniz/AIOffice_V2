[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$IndexPath,
    [string]$TaxonomyPath = "state\knowledge\r15_artifact_classification_taxonomy.json"
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R15RepoKnowledgeIndex.psm1") -Force -PassThru
$testIndex = $module.ExportedCommands["Test-R15RepoKnowledgeIndex"]

try {
    $result = & $testIndex -IndexPath $IndexPath -TaxonomyPath $TaxonomyPath
    Write-Output ("VALID: R15 repo knowledge index '{0}' passed with {1} entries, bounded_seed_only={2}, full_repo_index={3}, taxonomy={4}." -f $result.IndexId, $result.EntryCount, $result.BoundedSeedOnly, $result.FullRepoIndex, $result.TaxonomyId)
    exit 0
}
catch {
    Write-Output ("INVALID: R15 repo knowledge index failed validation. {0}" -f $_.Exception.Message)
    exit 1
}
