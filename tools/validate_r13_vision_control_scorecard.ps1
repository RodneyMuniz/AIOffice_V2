param(
    [string]$ScorecardPath = "state/vision_control/r13_015_vision_control_scorecard.json"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\R13VisionControlScorecard.psm1") -Force -PassThru
$testScorecard = $module.ExportedCommands["Test-R13VisionControlScorecardContract"]

$resolvedScorecardPath = if ([System.IO.Path]::IsPathRooted($ScorecardPath)) {
    $ScorecardPath
}
else {
    Join-Path $repoRoot $ScorecardPath
}

$result = & $testScorecard -ScorecardPath $resolvedScorecardPath
Write-Output ("VALID: R13 Vision Control scorecard '{0}' has {1} items, {2} evidence refs, R12 reported aggregate {3}, R12 recomputed aggregate {4}, R13 aggregate {5}, uplift from reported R12 {6}, uplift from recomputed R12 {7}, 10-15 percent progress claimed: {8}." -f (Split-Path -Leaf $resolvedScorecardPath), $result.ItemCount, $result.EvidenceRefCount, $result.R12ReportedAggregate, $result.R12RecomputedAggregate, $result.R13Aggregate, $result.UpliftFromReportedR12, $result.UpliftFromRecomputedR12, $result.TenToFifteenPercentProgressClaimed)
