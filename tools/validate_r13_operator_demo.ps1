[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$DemoPath
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$requiredSections = @(
    "Executive operator summary",
    "What was proved locally",
    "QA failure-to-fix cycle walkthrough",
    "Before and after evidence",
    "Current control-room posture",
    "Custom runner posture",
    "Skill invocation posture",
    "What is still blocked",
    "Next legal action",
    "Evidence map",
    "Explicit non-claims"
)
$requiredFields = @(
    "contract_version",
    "artifact_type",
    "demo_id",
    "repository",
    "branch",
    "head",
    "tree",
    "source_milestone",
    "source_task",
    "source_control_room_status_ref",
    "source_control_room_view_ref",
    "source_failure_fix_cycle_ref",
    "source_before_after_comparison_ref",
    "source_runner_result_ref",
    "source_skill_registry_ref",
    "source_skill_invocation_refs",
    "demo_sections",
    "evidence_refs",
    "blocker_summary",
    "hard_gate_summary",
    "next_legal_action",
    "generated_at_utc",
    "non_claims"
)
$requiredRefs = @(
    "contracts/control_room/r13_operator_demo.contract.json",
    "tools/render_r13_operator_demo.ps1",
    "tools/validate_r13_operator_demo.ps1",
    "state/cycles/r13_qa_cycle_demo/qa_failure_fix_cycle.json",
    "state/cycles/r13_qa_cycle_demo/before_after_comparison.json",
    "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/runner/r13_007_custom_runner_result.json",
    "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_skill_registry.json",
    "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_qa_detect_invocation_result.json",
    "state/cycles/r13_api_first_qa_pipeline_and_operator_control_room_product_slice/skills/r13_008_qa_fix_plan_invocation_result.json"
)
$requiredNonClaims = @(
    "no external replay has occurred",
    "no final QA signoff has occurred",
    "no hard R13 value gate fully delivered",
    "no productized UI",
    "no production runtime",
    "no R14 or successor opening"
)

function Resolve-RepoPath {
    param([Parameter(Mandatory = $true)][string]$PathValue)
    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $repoRoot $PathValue))
}

function Get-MetadataValue {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][string]$Name
    )
    $match = [regex]::Match($Text, ("(?m)^\-\s+{0}:\s+(.+?)\s*$" -f [regex]::Escape($Name)))
    if (-not $match.Success) {
        throw "R13 operator demo missing required metadata field '$Name'."
    }
    return $match.Groups[1].Value.Trim()
}

function Assert-MetadataBacktickValue {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Expected
    )
    $value = Get-MetadataValue -Text $Text -Name $Name
    if ($value -ne ('`{0}`' -f $Expected)) {
        throw "R13 operator demo metadata '$Name' must be '$Expected'."
    }
}

function ConvertFrom-MetadataCodeValue {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][string]$Name
    )
    $value = Get-MetadataValue -Text $Text -Name $Name
    $match = [regex]::Match($value, '^`([^`]+)`$')
    if (-not $match.Success) {
        throw "R13 operator demo metadata '$Name' must be a single backtick-wrapped value."
    }
    return $match.Groups[1].Value
}

function Test-LineHasNegation {
    param([Parameter(Mandatory = $true)][string]$Line)
    return ($Line -match '(?i)\b(no|not|without|cannot|must not|does not|do not|is not|are not|did not|non-claim|non_claim|blocked|planned|planned only|not yet|not fully|partial|partially|missing|required before|pending|false)\b')
}

function Assert-NoForbiddenClaims {
    param([Parameter(Mandatory = $true)][string]$Text)
    foreach ($line in @($Text -split "`n")) {
        if ($line -match '(?i)\bexternal[_ -]?replay\b' -and $line -match '(?i)\b(executed|complete|completed|passed|delivered|proved|run|ran|replayed|started|occurred)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "R13 operator demo claims external replay. Offending text: $line"
        }
        if ($line -match '(?i)\bfinal\s+QA\s+signoff\b|\bfinal\s+signoff\b|\bsign-off\b' -and $line -match '(?i)\b(accepted|complete|completed|delivered|passed|signed|occurred)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "R13 operator demo claims final QA signoff. Offending text: $line"
        }
        if ($line -match '(?i)\b(hard\s+)?R13\s+hard\s+value\s+gate\b|\bhard\s+value\s+gate\b|\bmeaningful\s+QA\s+loop\b|\bAPI/custom-runner bypass\b|\bcurrent\s+operator\s+control[- ]room\b|\bskill\s+invocation\s+evidence\b|\boperator\s+demo\s+gate\b' -and $line -match '(?i)\b(delivered|complete|completed|passed|proved|fully delivered)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "R13 operator demo claims hard gate delivery. Offending text: $line"
        }
        if ($line -match '(?i)\bproductized UI\b|\bproductized control[- ]room behavior\b|\bfull UI app\b|\bproduction runtime\b|\breal production QA\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "R13 operator demo claims forbidden product or production scope. Offending text: $line"
        }
        if ($line -match '(?i)\bR14\b.*\b(active|open|opened)\b|\bsuccessor\b.*\b(active|open|opened)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "R13 operator demo claims R14 or successor opening. Offending text: $line"
        }
    }
}

$resolvedDemoPath = Resolve-RepoPath -PathValue $DemoPath
if (-not (Test-Path -LiteralPath $resolvedDemoPath)) {
    throw "R13 operator demo '$DemoPath' does not exist."
}

$text = Get-Content -LiteralPath $resolvedDemoPath -Raw
if ($text -notmatch '^# R13 Operator Demo') {
    throw "R13 operator demo must include the title."
}

foreach ($field in $requiredFields) {
    Get-MetadataValue -Text $text -Name $field | Out-Null
}
Assert-MetadataBacktickValue -Text $text -Name "contract_version" -Expected "v1"
Assert-MetadataBacktickValue -Text $text -Name "artifact_type" -Expected "r13_operator_demo"
Assert-MetadataBacktickValue -Text $text -Name "repository" -Expected "AIOffice_V2"
Assert-MetadataBacktickValue -Text $text -Name "branch" -Expected "release/r13-api-first-qa-pipeline-and-operator-control-room-product-slice"
Assert-MetadataBacktickValue -Text $text -Name "source_task" -Expected "R13-010"
$sourceStatusRef = ConvertFrom-MetadataCodeValue -Text $text -Name "source_control_room_status_ref"
$sourceViewRef = ConvertFrom-MetadataCodeValue -Text $text -Name "source_control_room_view_ref"

$headValue = Get-MetadataValue -Text $text -Name "head"
$treeValue = Get-MetadataValue -Text $text -Name "tree"
foreach ($identity in @($headValue, $treeValue)) {
    if ($identity -notmatch '^`[a-f0-9]{40}`$') {
        throw "R13 operator demo branch/head/tree metadata must include 40-character Git object IDs."
    }
}

foreach ($section in $requiredSections) {
    if ($text -notmatch [regex]::Escape("## $section")) {
        throw "R13 operator demo missing required section '$section'."
    }
}

foreach ($ref in @($requiredRefs + $sourceStatusRef + $sourceViewRef)) {
    if ($text -notmatch [regex]::Escape($ref)) {
        throw "R13 operator demo missing required evidence ref '$ref'."
    }
    if (-not (Test-Path -LiteralPath (Resolve-RepoPath -PathValue $ref))) {
        throw "R13 operator demo evidence ref '$ref' does not exist."
    }
}

foreach ($nonClaim in $requiredNonClaims) {
    if ($text -notmatch [regex]::Escape($nonClaim)) {
        throw "R13 operator demo missing required non-claim '$nonClaim'."
    }
}

foreach ($section in $requiredSections) {
    if ((Get-MetadataValue -Text $text -Name "demo_sections") -notmatch [regex]::Escape($section)) {
        throw "R13 operator demo demo_sections metadata missing '$section'."
    }
}

if ($text -notmatch 'R13\s+active\s+through\s+R13-010\s+only') {
    throw "R13 operator demo must say R13 active through R13-010 only."
}
if ($text -notmatch 'R13-011\s+through\s+R13-018\s+remain\s+planned\s+only') {
    throw "R13 operator demo must say R13-011 through R13-018 remain planned only."
}
foreach ($requiredText in @(
        'selected issue type `malformed_json`',
        'Before issue count: `1`',
        'After issue count: `0`',
        'Comparison verdict: `target_issue_resolved`',
        'Cycle aggregate verdict: `fixed_pending_external_replay`',
        'Commands: `3` total, `3` passed, `0` failed',
        '`qa.detect`: `1` command, `1` passed',
        '`qa.fix_plan`: `1` command, `1` passed',
        "External replay missing",
        "Final QA signoff missing",
        "Hard gates not fully delivered",
        '`R13-011`: external replay after demo'
    )) {
    if ($text -notmatch [regex]::Escape($requiredText)) {
        throw "R13 operator demo missing required summary text '$requiredText'."
    }
}

Assert-NoForbiddenClaims -Text $text

Write-Output ("VALID: R13 operator demo '{0}', sections {1}, evidence refs {2}, next legal action R13-011." -f (Split-Path -Leaf $resolvedDemoPath), $requiredSections.Count, $requiredRefs.Count)
