$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$jsonRootModule = Import-Module (Join-Path $repoRoot "tools\JsonRoot.psm1") -Force -PassThru
$ledgerModule = Import-Module (Join-Path $repoRoot "tools\CycleLedger.psm1") -Force -PassThru -DisableNameChecking -WarningAction SilentlyContinue
$devModule = Import-Module (Join-Path $repoRoot "tools\DevExecutionAdapter.psm1") -Force -PassThru -DisableNameChecking -WarningAction SilentlyContinue
$qaModule = Import-Module (Join-Path $repoRoot "tools\CycleQaGate.psm1") -Force -PassThru -DisableNameChecking -WarningAction SilentlyContinue

$readSingleJsonObject = $jsonRootModule.ExportedCommands["Read-SingleJsonObject"]
$testLedger = $ledgerModule.ExportedCommands["Test-CycleLedgerContract"]
$testDispatch = $devModule.ExportedCommands["Test-DevDispatchPacketContract"]
$testResult = $devModule.ExportedCommands["Test-DevExecutionResultPacketContract"]
$testQaSignoff = $qaModule.ExportedCommands["Test-CycleQaSignoffPacketContract"]

$pilotRootRelative = "state/cycles/r11_008_controlled_cycle_pilot"
$pilotRoot = Join-Path $repoRoot ($pilotRootRelative -replace "/", "\")
$cycleId = "cycle-r11-008-controlled-cycle-pilot"
$validPassed = 0
$invalidRejected = 0
$failures = @()

function Get-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return (& $readSingleJsonObject -Path $Path -Label "R11-008 pilot JSON")
}

function Write-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Document
    )

    $parent = Split-Path -Parent $Path
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
    $Document | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Assert-Condition {
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

function Assert-HasProperty {
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if (@($Object.PSObject.Properties.Name) -notcontains $Name) {
        throw "$Context is missing required field '$Name'."
    }
}

function Assert-RequiredFields {
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        [string[]]$Fields,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($field in $Fields) {
        Assert-HasProperty -Object $Object -Name $field -Context $Context
    }
}

function Assert-StringArrayContains {
    param(
        [AllowNull()]
        $Values,
        [Parameter(Mandatory = $true)]
        [string]$Expected,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if (@($Values) -notcontains $Expected) {
        throw "$Context must include '$Expected'."
    }
}

function Resolve-PilotRef {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RootPath,
        [Parameter(Mandatory = $true)]
        [string]$Ref
    )

    $normalizedRef = $Ref.Replace("\", "/")
    if ($normalizedRef.StartsWith($pilotRootRelative + "/", [System.StringComparison]::OrdinalIgnoreCase)) {
        $suffix = $normalizedRef.Substring($pilotRootRelative.Length + 1)
        return Join-Path $RootPath ($suffix -replace "/", "\")
    }

    return Join-Path $repoRoot ($normalizedRef -replace "/", "\")
}

function Assert-RefExists {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RootPath,
        [Parameter(Mandatory = $true)]
        [string]$Ref,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $path = Resolve-PilotRef -RootPath $RootPath -Ref $Ref
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "$Context ref '$Ref' does not resolve to an artifact."
    }
}

function Test-LineHasNegation {
    param([Parameter(Mandatory = $true)][string]$Line)
    return ($Line -match '(?i)\b(no|not|without|never|does not|do not|is not|are not|reject|rejects|rejected|planned only|limited to|non-claim|nonclaims|non-scope)\b')
}

function Assert-NoForbiddenPositiveClaims {
    param(
        [Parameter(Mandatory = $true)]
        $Value,
        [string]$Path = "artifact"
    )

    if ($null -eq $Value) {
        return
    }

    if ($Path -match '\.(non_claims|rejected_claims|refusal_reasons|refusal_conditions)(\.|\[|$)') {
        return
    }

    if ($Value -is [string]) {
        $line = $Value
        $patterns = @(
            @{ Label = "R11 closeout"; Pattern = '(?i)\bR11 closeout\b.{0,80}\b(complete|closed|accepted|done)\b|\bR11\b.{0,80}\b(closed|closeout complete)\b' },
            @{ Label = "successor milestone opening"; Pattern = '(?i)\b(R12|successor milestone)\b.{0,80}\b(active|open|opened|accepted|complete)\b|\b(open|opened|active)\b.{0,80}\b(R12|successor milestone)\b' },
            @{ Label = "production runtime"; Pattern = '(?i)\bproduction runtime\b' },
            @{ Label = "real production QA"; Pattern = '(?i)\breal production QA\b|\bproduction QA\b' },
            @{ Label = "UI/control-room productization"; Pattern = '(?i)\bUI/control-room productization\b|\bcontrol-room productization\b' },
            @{ Label = "Standard runtime"; Pattern = '(?i)\bStandard runtime\b' },
            @{ Label = "multi-repo orchestration"; Pattern = '(?i)\bmulti-repo orchestration\b' },
            @{ Label = "swarms"; Pattern = '(?i)\bswarms\b' },
            @{ Label = "broad autonomous milestone execution"; Pattern = '(?i)\bbroad autonomous milestone execution\b|\bbroad autonomy\b' },
            @{ Label = "unattended automatic resume"; Pattern = '(?i)\bunattended automatic resume\b' },
            @{ Label = "solved Codex context compaction"; Pattern = '(?i)\bsolved Codex context compaction\b|\bCodex context compaction is solved\b' },
            @{ Label = "hours-long unattended execution"; Pattern = '(?i)\bhours-long unattended execution\b|\bhours-long unattended milestone execution\b' },
            @{ Label = "destructive rollback"; Pattern = '(?i)\bdestructive rollback\b' },
            @{ Label = "broad CI/product coverage"; Pattern = '(?i)\bbroad CI/product coverage\b' },
            @{ Label = "general Codex reliability"; Pattern = '(?i)\bgeneral Codex reliability\b' }
        )

        foreach ($pattern in $patterns) {
            if ($line -match $pattern.Pattern -and -not (Test-LineHasNegation -Line $line)) {
                throw "$Path claims $($pattern.Label): $line"
            }
        }
        return
    }

    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
        $index = 0
        foreach ($item in @($Value)) {
            Assert-NoForbiddenPositiveClaims -Value $item -Path "${Path}[$index]"
            $index += 1
        }
        return
    }

    if ($Value.PSObject -and $Value.PSObject.Properties.Count -gt 0) {
        foreach ($property in $Value.PSObject.Properties) {
            Assert-NoForbiddenPositiveClaims -Value $property.Value -Path "$Path.$($property.Name)"
        }
    }
}

function Assert-RefsInsideAllowedPaths {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Refs,
        [Parameter(Mandatory = $true)]
        [string[]]$AllowedPaths,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($ref in @($Refs)) {
        $normalized = $ref.Replace("\", "/").Trim("/")
        $matched = $false
        foreach ($allowed in @($AllowedPaths)) {
            $allowedNormalized = $allowed.Replace("\", "/").Trim("/")
            if ($normalized.Equals($allowedNormalized, [System.StringComparison]::OrdinalIgnoreCase) -or $normalized.StartsWith($allowedNormalized.TrimEnd("/") + "/", [System.StringComparison]::OrdinalIgnoreCase)) {
                $matched = $true
                break
            }
        }

        if (-not $matched) {
            throw "$Context ref '$ref' is outside dispatch allowed paths."
        }
    }
}

function Get-PilotFiles {
    param([Parameter(Mandatory = $true)][string]$RootPath)

    return [ordered]@{
        operator_request = Join-Path $RootPath "operator_request.json"
        cycle_plan = Join-Path $RootPath "cycle_plan.json"
        operator_approval = Join-Path $RootPath "operator_approval.json"
        baseline = Join-Path $RootPath "baseline.json"
        cycle_ledger = Join-Path $RootPath "cycle_ledger.json"
        bootstrap_packet = Join-Path $RootPath "bootstrap\bootstrap_packet.json"
        next_action_packet = Join-Path $RootPath "bootstrap\next_action_packet.json"
        residue_scan = Join-Path $RootPath "residue_guard\preflight_scan.json"
        dev_dispatch = Join-Path $RootPath "dev\dev_dispatch.json"
        dev_result = Join-Path $RootPath "dev\dev_execution_result.json"
        qa_signoff = Join-Path $RootPath "qa\cycle_qa_signoff.json"
        audit_packet = Join-Path $RootPath "audit\cycle_audit_packet.json"
        decision_packet = Join-Path $RootPath "decision\operator_decision_packet.json"
        summary = Join-Path $RootPath "summary.md"
    }
}

function Test-R11PilotRoot {
    param([Parameter(Mandatory = $true)][string]$RootPath)

    $files = Get-PilotFiles -RootPath $RootPath
    foreach ($entry in $files.GetEnumerator()) {
        if (-not (Test-Path -LiteralPath $entry.Value -PathType Leaf)) {
            throw "required artifact missing: $($entry.Key)"
        }
    }

    $auditContract = Get-JsonDocument -Path (Join-Path $repoRoot "contracts\cycle_controller\cycle_audit_packet.contract.json")
    $decisionContract = Get-JsonDocument -Path (Join-Path $repoRoot "contracts\cycle_controller\operator_decision_packet.contract.json")

    $operatorRequest = Get-JsonDocument -Path $files.operator_request
    $cyclePlan = Get-JsonDocument -Path $files.cycle_plan
    $operatorApproval = Get-JsonDocument -Path $files.operator_approval
    $baseline = Get-JsonDocument -Path $files.baseline
    $ledger = Get-JsonDocument -Path $files.cycle_ledger
    $bootstrap = Get-JsonDocument -Path $files.bootstrap_packet
    $nextAction = Get-JsonDocument -Path $files.next_action_packet
    $residue = Get-JsonDocument -Path $files.residue_scan
    $dispatch = Get-JsonDocument -Path $files.dev_dispatch
    $devResult = Get-JsonDocument -Path $files.dev_result
    $qaSignoff = Get-JsonDocument -Path $files.qa_signoff
    $audit = Get-JsonDocument -Path $files.audit_packet
    $decision = Get-JsonDocument -Path $files.decision_packet
    $summaryText = Get-Content -LiteralPath $files.summary -Raw

    foreach ($artifact in @($operatorRequest, $cyclePlan, $operatorApproval, $baseline, $ledger, $bootstrap, $nextAction, $dispatch, $devResult, $qaSignoff, $audit, $decision)) {
        Assert-Condition -Condition ([string]$artifact.cycle_id -eq $cycleId) -Message "artifact '$($artifact.artifact_type)' does not preserve shared cycle_id."
    }
    Write-Output "PASS valid: pilot artifacts preserve shared cycle_id."
    $script:validPassed += 1

    & $testLedger -LedgerPath $files.cycle_ledger | Out-Null
    Assert-Condition -Condition ($ledger.state -eq "accepted" -and $ledger.transition_history.Count -ge 12) -Message "cycle ledger did not reach accepted with expected transition history."
    foreach ($state in @("request_recorded", "plan_prepared", "plan_approved", "dev_dispatch_ready", "dev_in_progress", "dev_evidence_recorded", "qa_pending", "qa_passed", "audit_packet_ready", "operator_decision_pending", "accepted")) {
        Assert-Condition -Condition (@($ledger.transition_history.to_state) -contains $state) -Message "cycle ledger transition history is missing '$state'."
    }
    Write-Output "PASS valid: cycle ledger state and transition history validate."
    $script:validPassed += 1

    Assert-Condition -Condition ($bootstrap.next_action_packet_ref -eq "$pilotRootRelative/bootstrap/next_action_packet.json" -and $nextAction.cycle_ledger_ref -eq "$pilotRootRelative/cycle_ledger.json" -and $nextAction.recommended_action -eq "advance_to_dev_dispatch_ready") -Message "bootstrap or next-action refs are inconsistent."
    Write-Output "PASS valid: bootstrap and next-action refs validate."
    $script:validPassed += 1

    Assert-Condition -Condition ([bool]$residue.worktree_clean -and $residue.residue_policy_decision -eq "allowed" -and -not [bool]$residue.residue_detected) -Message "residue guard preflight was not clean and accepted."
    Write-Output "PASS valid: residue guard preflight validates clean posture."
    $script:validPassed += 1

    & $testDispatch -DispatchPath $files.dev_dispatch | Out-Null
    Assert-Condition -Condition (@($dispatch.task_packets).Count -ge 2 -and @($dispatch.task_packets).Count -le 3) -Message "Dev dispatch does not have 2 to 3 bounded tasks."
    Assert-Condition -Condition ($dispatch.cycle_id -eq $cycleId -and $dispatch.cycle_ledger_ref -eq "$pilotRootRelative/cycle_ledger.json") -Message "Dev dispatch does not preserve cycle or ledger identity."
    Write-Output "PASS valid: Dev dispatch has 2 to 3 bounded tasks and preserves identity."
    $script:validPassed += 1

    & $testResult -ResultPath $files.dev_result -DispatchPath $files.dev_dispatch | Out-Null
    Assert-Condition -Condition ($devResult.status -eq "completed" -and $devResult.dispatch_id -eq $dispatch.dispatch_id -and $devResult.cycle_id -eq $dispatch.cycle_id -and @($devResult.evidence_refs).Count -gt 0) -Message "Dev result lacks evidence refs or identity preservation."
    Assert-RefsInsideAllowedPaths -Refs @($devResult.changed_files) -AllowedPaths @($dispatch.allowed_paths) -Context "Dev result changed_files"
    Assert-RefsInsideAllowedPaths -Refs @($devResult.produced_artifacts) -AllowedPaths @($dispatch.allowed_paths) -Context "Dev result produced_artifacts"
    Write-Output "PASS valid: Dev result evidence refs and dispatch/cycle identity validate."
    $script:validPassed += 1

    & $testQaSignoff -SignoffPath $files.qa_signoff -DispatchPath $files.dev_dispatch -DevResultPath $files.dev_result | Out-Null
    foreach ($evidenceRef in @($devResult.evidence_refs)) {
        Assert-StringArrayContains -Values $qaSignoff.source_evidence_refs -Expected $evidenceRef -Context "QA source_evidence_refs"
    }
    Assert-Condition -Condition ($qaSignoff.qa_actor_identity -ne $devResult.executor_identity -and $qaSignoff.qa_verdict -eq "passed") -Message "QA signoff did not remain separate or did not pass."
    Write-Output "PASS valid: QA signoff consumes Dev evidence refs separately."
    $script:validPassed += 1

    Assert-RequiredFields -Object $audit -Fields @($auditContract.required_fields) -Context "Audit packet"
    Assert-Condition -Condition ($audit.artifact_type -eq $auditContract.audit_packet_artifact_type -and $audit.qa_verdict -eq "passed") -Message "Audit packet artifact type or QA verdict is invalid."
    foreach ($field in @($auditContract.required_evidence_ref_fields)) {
        $ref = [string]$audit.PSObject.Properties[$field].Value
        Assert-RefExists -RootPath $RootPath -Ref $ref -Context "Audit packet $field"
        Assert-StringArrayContains -Values $audit.evidence_refs -Expected $ref -Context "Audit evidence_refs"
    }
    Write-Output "PASS valid: audit packet refs validate."
    $script:validPassed += 1

    Assert-RequiredFields -Object $decision -Fields @($decisionContract.required_fields) -Context "Decision packet"
    Assert-Condition -Condition ($decision.artifact_type -eq $decisionContract.decision_packet_artifact_type -and @($decisionContract.allowed_decisions) -contains $decision.decision) -Message "Decision packet value is invalid."
    Assert-Condition -Condition ($decision.decision -eq "accepted_for_r11_008_pilot" -and [int]$decision.operator_intervention_count -le 2 -and [int]$decision.manual_bootstrap_count -eq 0) -Message "Decision packet counts or accepted pilot decision are invalid."
    foreach ($claim in @($decisionContract.required_rejected_claims)) {
        Assert-StringArrayContains -Values $decision.rejected_claims -Expected $claim -Context "Decision rejected_claims"
    }
    Write-Output "PASS valid: decision packet values validate."
    $script:validPassed += 1

    foreach ($artifact in @($operatorRequest, $cyclePlan, $operatorApproval, $baseline, $ledger, $bootstrap, $nextAction, $dispatch, $devResult, $qaSignoff, $audit, $decision)) {
        if (@($artifact.PSObject.Properties.Name) -contains "non_claims") {
            foreach ($nonClaim in @($decisionContract.required_non_claims)) {
                Assert-StringArrayContains -Values $artifact.non_claims -Expected $nonClaim -Context "$($artifact.artifact_type).non_claims"
            }
        }
        Assert-NoForbiddenPositiveClaims -Value $artifact -Path $artifact.artifact_type
    }
    Assert-NoForbiddenPositiveClaims -Value $summaryText -Path "summary"
    Write-Output "PASS valid: non-claims and no successor/closeout overclaims validate."
    $script:validPassed += 1

    return [pscustomobject]@{
        CycleId = $cycleId
        OperatorInterventionCount = [int]$decision.operator_intervention_count
        ManualBootstrapCount = [int]$decision.manual_bootstrap_count
        LedgerState = [string]$ledger.state
    }
}

function New-TempPilotCopy {
    $tempParent = Join-Path ([System.IO.Path]::GetTempPath()) ("r11pilot" + [guid]::NewGuid().ToString("N").Substring(0, 8))
    New-Item -ItemType Directory -Path $tempParent -Force | Out-Null
    Copy-Item -LiteralPath $pilotRoot -Destination $tempParent -Recurse -Force
    return (Join-Path $tempParent "r11_008_controlled_cycle_pilot")
}

function Invoke-ExpectedRefusal {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [string[]]$RequiredFragments,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Action
    )

    try {
        & $Action
        $script:failures += "FAIL invalid: $Label was accepted unexpectedly."
    }
    catch {
        $message = $_.Exception.Message
        $missing = @($RequiredFragments | Where-Object { $message -notlike "*$_*" })
        if ($missing.Count -gt 0) {
            $script:failures += "FAIL invalid: $Label refusal missed fragments $($missing -join ', '). Actual: $message"
            return
        }

        Write-Output "PASS invalid: $Label -> $message"
        $script:invalidRejected += 1
    }
}

try {
    Test-R11PilotRoot -RootPath $pilotRoot | Out-Null

    Invoke-ExpectedRefusal -Label "missing-qa-signoff" -RequiredFragments @("required artifact missing", "qa_signoff") -Action {
        $temp = New-TempPilotCopy
        try {
            Remove-Item -LiteralPath (Join-Path $temp "qa\cycle_qa_signoff.json") -Force
            Test-R11PilotRoot -RootPath $temp | Out-Null
        }
        finally {
            if (Test-Path -LiteralPath (Split-Path -Parent $temp)) { Remove-Item -LiteralPath (Split-Path -Parent $temp) -Recurse -Force }
        }
    }

    Invoke-ExpectedRefusal -Label "missing-audit-packet" -RequiredFragments @("required artifact missing", "audit_packet") -Action {
        $temp = New-TempPilotCopy
        try {
            Remove-Item -LiteralPath (Join-Path $temp "audit\cycle_audit_packet.json") -Force
            Test-R11PilotRoot -RootPath $temp | Out-Null
        }
        finally {
            if (Test-Path -LiteralPath (Split-Path -Parent $temp)) { Remove-Item -LiteralPath (Split-Path -Parent $temp) -Recurse -Force }
        }
    }

    Invoke-ExpectedRefusal -Label "missing-decision-packet" -RequiredFragments @("required artifact missing", "decision_packet") -Action {
        $temp = New-TempPilotCopy
        try {
            Remove-Item -LiteralPath (Join-Path $temp "decision\operator_decision_packet.json") -Force
            Test-R11PilotRoot -RootPath $temp | Out-Null
        }
        finally {
            if (Test-Path -LiteralPath (Split-Path -Parent $temp)) { Remove-Item -LiteralPath (Split-Path -Parent $temp) -Recurse -Force }
        }
    }

    Invoke-ExpectedRefusal -Label "successor-claim" -RequiredFragments @("successor milestone") -Action {
        $temp = New-TempPilotCopy
        try {
            $decisionPath = Join-Path $temp "decision\operator_decision_packet.json"
            $decision = Get-JsonDocument -Path $decisionPath
            $decision.accepted_claims = @($decision.accepted_claims) + @("R12 successor milestone opened.")
            Write-JsonDocument -Path $decisionPath -Document $decision
            Test-R11PilotRoot -RootPath $temp | Out-Null
        }
        finally {
            if (Test-Path -LiteralPath (Split-Path -Parent $temp)) { Remove-Item -LiteralPath (Split-Path -Parent $temp) -Recurse -Force }
        }
    }

    Invoke-ExpectedRefusal -Label "r11-closeout-claim" -RequiredFragments @("R11 closeout") -Action {
        $temp = New-TempPilotCopy
        try {
            $decisionPath = Join-Path $temp "decision\operator_decision_packet.json"
            $decision = Get-JsonDocument -Path $decisionPath
            $decision.accepted_claims = @($decision.accepted_claims) + @("R11 closeout complete.")
            Write-JsonDocument -Path $decisionPath -Document $decision
            Test-R11PilotRoot -RootPath $temp | Out-Null
        }
        finally {
            if (Test-Path -LiteralPath (Split-Path -Parent $temp)) { Remove-Item -LiteralPath (Split-Path -Parent $temp) -Recurse -Force }
        }
    }
}
catch {
    $failures += "FAIL R11 controlled-cycle pilot harness: $($_.Exception.Message)"
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R11 controlled-cycle pilot tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All R11 controlled-cycle pilot tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
