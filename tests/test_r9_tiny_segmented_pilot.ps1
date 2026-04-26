$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$pilotRoot = Join-Path $repoRoot "state\pilots\r9_tiny_segmented_milestone_pilot"
$segmentModule = Import-Module (Join-Path $repoRoot "tools\ExecutionSegmentContinuity.psm1") -Force -PassThru
$qaModule = Import-Module (Join-Path $repoRoot "tools\IsolatedQaSignoff.psm1") -Force -PassThru
$testExecutionSegmentArtifact = $segmentModule.ExportedCommands["Test-ExecutionSegmentArtifactContract"]
$testIsolatedQaSignoff = $qaModule.ExportedCommands["Test-IsolatedQaSignoffContract"]

function Get-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Resolve-PilotPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$AnchorPath = $pilotRoot
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return [System.IO.Path]::GetFullPath($Path)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $AnchorPath $Path))
}

function Assert-True {
    param(
        [Parameter(Mandatory = $true)]
        [bool]$Condition,
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Assert-Equal {
    param(
        [AllowNull()]
        $Actual,
        [AllowNull()]
        $Expected,
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    if ($Actual -ne $Expected) {
        throw ("{0} Expected '{1}', got '{2}'." -f $Message, $Expected, $Actual)
    }
}

function Assert-PathExists {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$AnchorPath = $pilotRoot,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $resolvedPath = Resolve-PilotPath -Path $Path -AnchorPath $AnchorPath
    if (-not (Test-Path -LiteralPath $resolvedPath)) {
        throw "$Context '$Path' does not exist."
    }

    return (Resolve-Path -LiteralPath $resolvedPath).Path
}

function Assert-ArrayCountBetween {
    param(
        [AllowNull()]
        $Value,
        [int]$Minimum,
        [int]$Maximum,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($null -eq $Value -or $Value -is [string] -or -not ($Value -is [System.Collections.IEnumerable])) {
        throw "$Context must be an array."
    }

    $items = @($Value)
    if ($items.Count -lt $Minimum -or $items.Count -gt $Maximum) {
        throw "$Context must have between $Minimum and $Maximum items."
    }

    Write-Output $items
}

function Assert-ContainsValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Expected,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if (@($Value) -notcontains $Expected) {
        throw "$Context must include '$Expected'."
    }
}

function Assert-RequiredNonClaims {
    param(
        [Parameter(Mandatory = $true)]
        $Document,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $requiredNonClaims = @(
        "no unattended automatic resume",
        "no solved Codex context compaction",
        "no hours-long unattended milestone execution",
        "no broad autonomous milestone execution",
        "no UI or control-room productization",
        "no Standard runtime",
        "no multi-repo orchestration",
        "no swarms"
    )

    if (-not ($Document.PSObject.Properties.Name -contains "non_claims")) {
        throw "$Context must include non_claims."
    }

    foreach ($requiredNonClaim in $requiredNonClaims) {
        Assert-ContainsValue -Value $Document.non_claims -Expected $requiredNonClaim -Context "$Context non_claims"
    }
}

function Get-StringValues {
    param(
        [AllowNull()]
        $Value
    )

    if ($null -eq $Value) {
        return @()
    }

    if ($Value -is [string]) {
        return @($Value)
    }

    if ($Value -is [System.Collections.IEnumerable]) {
        $items = @()
        foreach ($item in $Value) {
            $items += @(Get-StringValues -Value $item)
        }

        return $items
    }

    if ($null -ne $Value.PSObject -and @($Value.PSObject.Properties).Count -gt 0) {
        $items = @()
        foreach ($property in $Value.PSObject.Properties) {
            $items += @(Get-StringValues -Value $property.Value)
        }

        return $items
    }

    return @()
}

function Assert-NoForbiddenPositiveClaims {
    param(
        [Parameter(Mandatory = $true)]
        $Document,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $forbiddenPhrases = @(
        "unattended automatic resume",
        "solved Codex context compaction",
        "hours-long unattended milestone execution",
        "broad autonomous milestone execution",
        "real external or CI runner artifact identity is claimed",
        "external QA proof is claimed",
        "CI proof is claimed"
    )

    foreach ($value in @(Get-StringValues -Value $Document)) {
        foreach ($phrase in $forbiddenPhrases) {
            if ($value -match [regex]::Escape($phrase) -and $value -notmatch '(?i)\b(no|not|without|do not|does not|never)\b') {
                throw "$Context must not positively claim '$phrase'."
            }
        }
    }
}

function Assert-DurableReference {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Reference,
        [Parameter(Mandatory = $true)]
        [string]$AnchorPath,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Reference -match '(?i)(chat|transcript|conversation)') {
        throw "$Context must use durable repo refs, not chat memory."
    }

    Assert-PathExists -Path $Reference -AnchorPath $AnchorPath -Context $Context | Out-Null
}

function Assert-ReferenceArray {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$AnchorPath,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($reference in @(Assert-ArrayCountBetween -Value $Value -Minimum 1 -Maximum 100 -Context $Context)) {
        Assert-DurableReference -Reference $reference -AnchorPath $AnchorPath -Context "$Context item"
    }
}

$failures = @()
$validations = 0

try {
    $requestPath = Assert-PathExists -Path "pilot_request.json" -Context "pilot request"
    $planPath = Assert-PathExists -Path "pilot_plan.json" -Context "pilot plan"
    $freezePath = Assert-PathExists -Path "operator_freeze.json" -Context "operator freeze"
    $auditPath = Assert-PathExists -Path "audit\pilot_audit_summary.json" -Context "pilot audit summary"
    $decisionPath = Assert-PathExists -Path "operator_decision_packet.json" -Context "operator decision packet"
    $qaPath = Assert-PathExists -Path "qa\isolated_qa_signoff.json" -Context "isolated QA signoff"

    $request = Get-JsonDocument -Path $requestPath
    Assert-True -Condition ([bool]$request.bounded) -Message "pilot request must be bounded."
    Assert-Equal -Actual $request.product_behavior_change -Expected $false -Message "pilot request must avoid product behavior changes."
    Assert-True -Condition ($request.max_segments -le 2) -Message "pilot request must allow at most two segments."
    Assert-True -Condition ($request.purpose -match "segmented control flow") -Message "pilot request must state the segmented control-flow purpose."
    Assert-RequiredNonClaims -Document $request -Context "pilot request"
    Assert-NoForbiddenPositiveClaims -Document $request -Context "pilot request"
    $validations += 1

    $plan = Get-JsonDocument -Path $planPath
    $segments = @(Assert-ArrayCountBetween -Value $plan.segments -Minimum 1 -Maximum 2 -Context "pilot plan segments")
    Assert-Equal -Actual $plan.segment_count -Expected $segments.Count -Message "pilot plan segment_count must match segment entries."
    Assert-True -Condition ($plan.segment_count -le 2) -Message "pilot plan must use one or two segments only."
    Assert-RequiredNonClaims -Document $plan -Context "pilot plan"
    Assert-NoForbiddenPositiveClaims -Document $plan -Context "pilot plan"
    $validations += 1

    $freeze = Get-JsonDocument -Path $freezePath
    Assert-True -Condition ([bool]$freeze.scope_frozen) -Message "operator freeze must freeze scope."
    Assert-Equal -Actual $freeze.segment_count_frozen -Expected $plan.segment_count -Message "operator freeze must freeze exact segment count."
    Assert-ContainsValue -Value $freeze.forbidden_scope -Expected "R9-007 closeout" -Context "operator freeze forbidden_scope"
    Assert-ContainsValue -Value $freeze.forbidden_scope -Expected "no real external or CI proof claim" -Context "operator freeze forbidden_scope"
    Assert-NoForbiddenPositiveClaims -Document $freeze -Context "operator freeze"
    $validations += 1

    $segmentArtifactPaths = @(
        (Join-Path $pilotRoot "segments\segment_001_dispatch.json"),
        (Join-Path $pilotRoot "segments\segment_001_checkpoint.json"),
        (Join-Path $pilotRoot "segments\segment_001_result.json")
    )

    $priorSequence = 0
    foreach ($segmentArtifactPath in $segmentArtifactPaths) {
        $validation = & $testExecutionSegmentArtifact -ArtifactPath $segmentArtifactPath
        if ($validation.SegmentSequence -lt $priorSequence) {
            throw "segment sequence must be forward-only."
        }

        $priorSequence = $validation.SegmentSequence
        $artifact = Get-JsonDocument -Path $segmentArtifactPath
        $anchorPath = Split-Path -Parent $segmentArtifactPath
        Assert-RequiredNonClaims -Document $artifact -Context $artifact.artifact_id
        Assert-NoForbiddenPositiveClaims -Document $artifact -Context $artifact.artifact_id

        if ($artifact.artifact_type -eq "execution_segment_dispatch") {
            Assert-DurableReference -Reference $artifact.source_request_ref -AnchorPath $anchorPath -Context "dispatch source_request_ref"
            Assert-DurableReference -Reference $artifact.operator_authority_ref -AnchorPath $anchorPath -Context "dispatch operator_authority_ref"
            Assert-True -Condition ($null -ne $artifact.context_budget) -Message "dispatch must declare a context budget."
            Assert-True -Condition ($null -ne $artifact.allowed_scope) -Message "dispatch must declare allowed scope."
        }

        if ($artifact.artifact_type -eq "execution_segment_checkpoint") {
            Assert-DurableReference -Reference $artifact.dispatch_ref -AnchorPath $anchorPath -Context "checkpoint dispatch_ref"
            Assert-ReferenceArray -Value $artifact.produced_artifact_refs -AnchorPath $anchorPath -Context "checkpoint produced_artifact_refs"
            Assert-ReferenceArray -Value $artifact.evidence_refs -AnchorPath $anchorPath -Context "checkpoint evidence_refs"
            Assert-True -Condition ([bool]$artifact.workspace_state.durable_state_written) -Message "checkpoint must record durable state before exit."
        }

        if ($artifact.artifact_type -eq "execution_segment_result") {
            Assert-DurableReference -Reference $artifact.dispatch_ref -AnchorPath $anchorPath -Context "result dispatch_ref"
            Assert-DurableReference -Reference $artifact.checkpoint_ref -AnchorPath $anchorPath -Context "result checkpoint_ref"
            Assert-ReferenceArray -Value $artifact.produced_artifact_refs -AnchorPath $anchorPath -Context "result produced_artifact_refs"
            Assert-ReferenceArray -Value $artifact.evidence_refs -AnchorPath $anchorPath -Context "result evidence_refs"
            Assert-True -Condition (-not [bool]$artifact.next_segment_required) -Message "tiny pilot result must not require a second segment."
        }

        $validations += 1
    }

    $qaValidation = & $testIsolatedQaSignoff -PacketPath $qaPath
    Assert-Equal -Actual $qaValidation.SourceTask -Expected "R9-006" -Message "pilot QA signoff must target R9-006."
    Assert-Equal -Actual $qaValidation.QaRunnerKind -Expected "local_isolated_qa_runner" -Message "pilot QA signoff must use local isolated QA runner identity."
    $qaPacket = Get-JsonDocument -Path $qaPath
    foreach ($sourceArtifact in @($qaPacket.source_artifacts)) {
        if ($sourceArtifact.artifact_kind -eq "executor_evidence") {
            Assert-Equal -Actual $sourceArtifact.authority_role -Expected "source_evidence" -Message "executor evidence must remain source evidence only."
        }
    }
    Assert-NoForbiddenPositiveClaims -Document $qaPacket -Context "isolated QA signoff"
    $validations += 1

    $localQa = Get-JsonDocument -Path (Assert-PathExists -Path "qa\local_qa_evidence.json" -Context "local QA evidence")
    Assert-ContainsValue -Value $localQa.limitations -Expected "no external QA proof is claimed" -Context "local QA evidence limitations"
    Assert-ContainsValue -Value $localQa.limitations -Expected "no CI proof is claimed" -Context "local QA evidence limitations"
    Assert-NoForbiddenPositiveClaims -Document $localQa -Context "local QA evidence"
    $validations += 1

    $audit = Get-JsonDocument -Path $auditPath
    Assert-True -Condition ([bool]$audit.advisory_only) -Message "pilot audit summary must be advisory only."
    Assert-RequiredNonClaims -Document $audit -Context "pilot audit summary"
    Assert-NoForbiddenPositiveClaims -Document $audit -Context "pilot audit summary"
    $validations += 1

    $decision = Get-JsonDocument -Path $decisionPath
    Assert-True -Condition ([bool]$decision.advisory_only) -Message "operator decision packet must be advisory only."
    Assert-Equal -Actual $decision.decision_executed -Expected $false -Message "operator decision packet must not claim executed operator decision."
    foreach ($option in @("accept_pilot", "request_rework", "stop")) {
        Assert-ContainsValue -Value $decision.allowed_options -Expected $option -Context "operator decision allowed_options"
    }
    Assert-RequiredNonClaims -Document $decision -Context "operator decision packet"
    Assert-NoForbiddenPositiveClaims -Document $decision -Context "operator decision packet"
    $validations += 1
}
catch {
    $failures += $_.Exception.Message
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output ("FAIL r9 tiny segmented pilot: {0}" -f $_) }
    throw ("R9 tiny segmented pilot tests failed. Validations completed before failure: {0}." -f $validations)
}

Write-Output ("All R9 tiny segmented pilot tests passed. Validations completed: {0}." -f $validations)
