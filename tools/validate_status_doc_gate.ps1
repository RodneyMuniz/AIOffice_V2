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

if ($validation.R12Closed) {
    Write-Output ("VALID: status-doc gate records R8 closed with tasks through R8-{0} complete, most recently closed milestone '{1}', no active successor milestone, R10 through R10-{2} closed, R11 through R11-{3} closed, and R12 through R12-{4} closed." -f $validation.DoneThrough.ToString("000"), $validation.MostRecentlyClosedMilestone, $validation.R10DoneThrough.ToString("000"), $validation.R11DoneThrough.ToString("000"), $validation.R12DoneThrough.ToString("000"))
}
elseif ($validation.R12Opened) {
    Write-Output ("VALID: status-doc gate records R8 closed with tasks through R8-{0} complete, most recently closed milestone '{1}', R10 through R10-{2} closed, R11 through R11-{3} closed, and active milestone '{4}' through R12-{5} with R12-{6} through R12-{7} planned." -f $validation.DoneThrough.ToString("000"), $validation.MostRecentlyClosedMilestone, $validation.R10DoneThrough.ToString("000"), $validation.R11DoneThrough.ToString("000"), $validation.ActiveMilestone, $validation.R12DoneThrough.ToString("000"), $validation.R12PlannedStart.ToString("000"), $validation.R12PlannedThrough.ToString("000"))
}
elseif ($validation.R11Closed) {
    Write-Output ("VALID: status-doc gate records R8 closed with tasks through R8-{0} complete, most recently closed milestone '{1}', no active successor milestone, R10 through R10-{2} closed, and R11 through R11-{3} closed." -f $validation.DoneThrough.ToString("000"), $validation.MostRecentlyClosedMilestone, $validation.R10DoneThrough.ToString("000"), $validation.R11DoneThrough.ToString("000"))
}
elseif ($validation.R11Opened) {
    Write-Output ("VALID: status-doc gate records R8 closed with tasks through R8-{0} complete, most recently closed milestone '{1}', R10 through R10-{2} closed, and active milestone '{3}' through R11-{4} with R11-{5} through R11-{6} planned." -f $validation.DoneThrough.ToString("000"), $validation.MostRecentlyClosedMilestone, $validation.R10DoneThrough.ToString("000"), $validation.ActiveMilestone, $validation.R11DoneThrough.ToString("000"), $validation.R11PlannedStart.ToString("000"), $validation.R11PlannedThrough.ToString("000"))
}
elseif ($validation.R10Closed) {
    Write-Output ("VALID: status-doc gate records R8 closed with tasks through R8-{0} complete, most recently closed milestone '{1}', no active successor milestone, and R10 through R10-{2} closed." -f $validation.DoneThrough.ToString("000"), $validation.MostRecentlyClosedMilestone, $validation.R10DoneThrough.ToString("000"))
}
elseif ($validation.R10Opened) {
    Write-Output ("VALID: status-doc gate records R8 closed with tasks through R8-{0} complete, most recently closed milestone '{1}', and active milestone '{2}' through R10-{3} with R10-{4} through R10-{5} planned." -f $validation.DoneThrough.ToString("000"), $validation.MostRecentlyClosedMilestone, $validation.ActiveMilestone, $validation.R10DoneThrough.ToString("000"), $validation.R10PlannedStart.ToString("000"), $validation.R10PlannedThrough.ToString("000"))
}
elseif ($validation.R9Closed) {
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
