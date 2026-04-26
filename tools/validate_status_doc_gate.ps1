[CmdletBinding()]
param(
    [string]$RepositoryRoot
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
    $RepositoryRoot = Split-Path -Parent $RepositoryRoot
}

$module = Import-Module (Join-Path $PSScriptRoot "StatusDocGate.psm1") -Force -PassThru
$testStatusDocGate = $module.ExportedCommands["Test-StatusDocGate"]

$validation = & $testStatusDocGate -RepositoryRoot $RepositoryRoot
$plannedSummary = if ($null -eq $validation.PlannedStart) {
    "no remaining planned R8 tasks"
}
elseif ($validation.PlannedStart -eq $validation.PlannedThrough) {
    ("{0} planned" -f ("R8-{0}" -f $validation.PlannedStart.ToString("000")))
}
else {
    ("R8-{0} through R8-{1} planned" -f $validation.PlannedStart.ToString("000"), $validation.PlannedThrough.ToString("000"))
}

if ($validation.R9Closed) {
    Write-Output ("VALID: status-doc gate records R8 closed with tasks through R8-{0} complete, most recently closed milestone '{1}', no active successor milestone, and R9 through R9-{2} closed." -f $validation.DoneThrough.ToString("000"), $validation.MostRecentlyClosedMilestone, $validation.R9DoneThrough.ToString("000"))
}
elseif ($validation.R9Opened) {
    Write-Output ("VALID: status-doc gate records R8 closed with tasks through R8-{0} complete, most recently closed milestone '{1}', and active milestone '{2}' through R9-{3} with R9-{4} through R9-{5} planned." -f $validation.DoneThrough.ToString("000"), $validation.MostRecentlyClosedMilestone, $validation.ActiveMilestone, $validation.R9DoneThrough.ToString("000"), $validation.R9PlannedStart.ToString("000"), $validation.R9PlannedThrough.ToString("000"))
}
elseif ($validation.R8Closed) {
    Write-Output ("VALID: status-doc gate records R8 closed with tasks through R8-{0} complete, most recently closed milestone '{1}', and {2}." -f $validation.DoneThrough.ToString("000"), $validation.MostRecentlyClosedMilestone, $plannedSummary)
}
else {
    Write-Output ("VALID: status-doc gate keeps '{0}' active with tasks through R8-{1} complete and {2}." -f $validation.ActiveMilestone, $validation.DoneThrough.ToString("000"), $plannedSummary)
}
