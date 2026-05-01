[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$QueuePath
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "R13QaFixQueue.psm1") -Force -PassThru
$testQueue = $module.ExportedCommands["Test-R13QaFixQueue"]

$validation = & $testQueue -QueuePath $QueuePath
Write-Output ("VALID: R13 QA fix queue '{0}' has aggregate verdict '{1}' with {2} source issue(s), {3} blocking issue(s), {4} fix item(s), and {5} unmapped blocking issue(s)." -f $validation.QueueId, $validation.AggregateVerdict, $validation.SourceIssueCount, $validation.BlockingIssueCount, $validation.FixItemCount, $validation.UnmappedBlockingIssueCount)
