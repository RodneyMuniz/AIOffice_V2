[CmdletBinding()]
param(
    [ValidateSet("diagnostic_non_strict", "strict", "fixture")]
    [string]$QaMode = "diagnostic_non_strict",
    [string[]]$PowerShellPath = @("tools", "tests"),
    [string[]]$JsonPath = @("contracts", "state/fixtures"),
    [string[]]$MarkdownPath = @(
        "README.md",
        "governance/ACTIVE_STATE.md",
        "execution/KANBAN.md",
        "governance/DECISION_LOG.md",
        "governance/R12_EXTERNAL_API_RUNNER_ACTIONABLE_QA_AND_CONTROL_ROOM_WORKFLOW_PILOT.md"
    ),
    [string[]]$EvidenceRef = @(
        "contracts/actionable_qa/actionable_qa_report.contract.json",
        "contracts/actionable_qa/actionable_qa_issue.contract.json",
        "tools/ActionableQa.psm1"
    ),
    [string[]]$TestCommand = @(),
    [string]$OutputPath = "",
    [string]$MarkdownOutputPath = "",
    [switch]$Overwrite
)

$ErrorActionPreference = "Stop"

$module = Import-Module (Join-Path $PSScriptRoot "ActionableQa.psm1") -Force -PassThru
$invokeActionableQa = $module.ExportedCommands["Invoke-ActionableQa"]

& $invokeActionableQa `
    -QaMode $QaMode `
    -PowerShellPaths $PowerShellPath `
    -JsonPaths $JsonPath `
    -MarkdownPaths $MarkdownPath `
    -EvidenceRefs $EvidenceRef `
    -TestCommands $TestCommand `
    -OutputPath $OutputPath `
    -MarkdownOutputPath $MarkdownOutputPath `
    -Overwrite:$Overwrite
