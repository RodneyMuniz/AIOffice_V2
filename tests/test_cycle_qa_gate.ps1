$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\CycleQaGate.psm1") -Force -PassThru -DisableNameChecking -WarningAction SilentlyContinue
$jsonRootModule = Import-Module (Join-Path $repoRoot "tools\JsonRoot.psm1") -Force -PassThru

$newSignoff = $module.ExportedCommands["New-CycleQaSignoffPacket"]
$testSignoff = $module.ExportedCommands["Test-CycleQaSignoffPacketContract"]
$testSignoffObject = $module.ExportedCommands["Test-CycleQaSignoffPacketObject"]
$inspectSignoff = $module.ExportedCommands["Inspect-CycleQaSignoffPacket"]
$readSingleJsonObject = $jsonRootModule.ExportedCommands["Read-SingleJsonObject"]

$cliPath = Join-Path $repoRoot "tools\invoke_cycle_qa_gate.ps1"
$validDispatchPath = Join-Path $repoRoot "state\fixtures\valid\cycle_controller\dev_dispatch_packet.valid.json"
$validDevResultPath = Join-Path $repoRoot "state\fixtures\valid\cycle_controller\dev_execution_result_packet.valid.json"
$validFixtureSignoffPath = Join-Path $repoRoot "state\fixtures\valid\cycle_controller\cycle_qa_signoff_packet.valid.json"
$testRunId = "test-cycle-qa-" + [guid]::NewGuid().ToString("N").Substring(0, 8)
$stateRootRelative = "state/cycle_controller/$testRunId"
$stateRoot = Join-Path $repoRoot ($stateRootRelative -replace "/", "\")
$validPassed = 0
$invalidRejected = 0
$failures = @()

function Get-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return (& $readSingleJsonObject -Path $Path -Label "Test JSON document")
}

function Write-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Document
    )

    $parentPath = Split-Path -Parent $Path
    New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    $Document | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Copy-JsonObject {
    param(
        [Parameter(Mandatory = $true)]
        $Object
    )

    $copyPath = Join-Path $stateRoot ("copy-" + [guid]::NewGuid().ToString("N") + ".json")
    Write-JsonDocument -Path $copyPath -Document $Object
    return Get-JsonDocument -Path $copyPath
}

function New-StatePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    return (Join-Path $stateRoot $Name)
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

function Invoke-ExpectedRefusal {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [string[]]$RequiredFragments = @(),
        [Parameter(Mandatory = $true)]
        [scriptblock]$Action
    )

    try {
        & $Action
        $script:failures += ("FAIL invalid: {0} was accepted unexpectedly." -f $Label)
    }
    catch {
        $message = $_.Exception.Message
        $missingFragments = @($RequiredFragments | Where-Object { $message -notlike ("*{0}*" -f $_) })
        if ($missingFragments.Count -gt 0) {
            $script:failures += ("FAIL invalid: {0} refusal message missed fragments {1}. Actual: {2}" -f $Label, ($missingFragments -join ", "), $message)
            return
        }

        Write-Output ("PASS invalid: {0} -> {1}" -f $Label, $message)
        $script:invalidRejected += 1
    }
}

function Invoke-CliJson {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Parameters
    )

    $output = & $cliPath @Parameters
    return (($output -join "`n") | ConvertFrom-Json)
}

function New-MutatedDevResultPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Mutate
    )

    $doc = Copy-JsonObject -Object (Get-JsonDocument -Path $validDevResultPath)
    & $Mutate $doc
    $path = New-StatePath -Name $Name
    Write-JsonDocument -Path $path -Document $doc
    return $path
}

try {
    New-Item -ItemType Directory -Path $stateRoot -Force | Out-Null
    $dispatch = Get-JsonDocument -Path $validDispatchPath
    $devResult = Get-JsonDocument -Path $validDevResultPath

    $signoffPath = New-StatePath -Name "cycle_qa_signoff.json"
    $signoff = Invoke-CliJson -Parameters @{
        Command = "signoff"
        DispatchPath = $validDispatchPath
        DevResultPath = $validDevResultPath
        OutputPath = $signoffPath
        QaActorIdentity = "codex-cycle-qa-test"
        QaActorKind = "codex"
        QaAuthorityType = "separate_qa_gate"
        Overwrite = $true
    }
    Assert-Condition -Condition ($signoff.qa_verdict -eq "passed" -and $signoff.cycle_id -eq $dispatch.cycle_id) -Message "valid QA signoff did not pass over valid Dev dispatch/result evidence."
    Write-Output "PASS valid: QA signoff over valid Dev dispatch/result passes."
    $validPassed += 1

    $validation = & $testSignoff -SignoffPath $signoffPath -DispatchPath $validDispatchPath -DevResultPath $validDevResultPath
    Assert-Condition -Condition ($validation.IsValid -and $validation.QaVerdict -eq "passed" -and $validation.QaCheckCount -ge 13) -Message "QA signoff did not validate against the contract."
    Write-Output "PASS valid: QA signoff validates against contract."
    $validPassed += 1

    Assert-Condition -Condition ($signoff.cycle_id -eq $dispatch.cycle_id -and $signoff.dispatch_ref -eq "state/fixtures/valid/cycle_controller/dev_dispatch_packet.valid.json" -and $signoff.dev_result_ref -eq "state/fixtures/valid/cycle_controller/dev_execution_result_packet.valid.json") -Message "QA signoff did not preserve cycle, dispatch, and Dev result refs."
    Write-Output "PASS valid: QA signoff preserves cycle/dispatch/dev-result refs."
    $validPassed += 1

    foreach ($evidenceRef in @($devResult.evidence_refs)) {
        Assert-Condition -Condition (@($signoff.source_evidence_refs) -contains $evidenceRef) -Message "QA signoff did not consume Dev evidence ref '$evidenceRef'."
    }
    Write-Output "PASS valid: QA signoff consumes Dev evidence refs."
    $validPassed += 1

    $fixtureValidation = & $testSignoff -SignoffPath $validFixtureSignoffPath -DispatchPath $validDispatchPath -DevResultPath $validDevResultPath
    Assert-Condition -Condition ($fixtureValidation.IsValid -and $fixtureValidation.QaSignoffId -eq "qa-signoff-r11-007-fixture") -Message "valid QA signoff fixture did not validate."
    Write-Output "PASS valid: valid QA signoff fixture validates."
    $validPassed += 1

    $inspect = Invoke-CliJson -Parameters @{
        Command = "inspect-signoff"
        SignoffPath = $signoffPath
        DispatchPath = $validDispatchPath
        DevResultPath = $validDevResultPath
    }
    Assert-Condition -Condition ($inspect.QaVerdict -eq "passed" -and $inspect.QaCheckCount -ge 13) -Message "inspect-signoff did not validate and summarize the signoff."
    Write-Output "PASS valid: inspect-signoff validates and summarizes the packet."
    $validPassed += 1

    Invoke-ExpectedRefusal -Label "missing-dispatch" -RequiredFragments @("Dev dispatch packet", "does not exist") -Action {
        & $newSignoff -DispatchPath (New-StatePath -Name "missing-dispatch.json") -DevResultPath $validDevResultPath -QaActorIdentity "codex-cycle-qa-test" -QaActorKind "codex" -QaAuthorityType "separate_qa_gate" | Out-Null
    }

    $malformedDispatchPath = New-StatePath -Name "malformed-dispatch.json"
    Set-Content -LiteralPath $malformedDispatchPath -Value "{ not-json" -Encoding UTF8
    Invoke-ExpectedRefusal -Label "malformed-dispatch" -RequiredFragments @("not valid JSON") -Action {
        & $newSignoff -DispatchPath $malformedDispatchPath -DevResultPath $validDevResultPath -QaActorIdentity "codex-cycle-qa-test" -QaActorKind "codex" -QaAuthorityType "separate_qa_gate" | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-dev-result" -RequiredFragments @("Dev result packet", "does not exist") -Action {
        & $newSignoff -DispatchPath $validDispatchPath -DevResultPath (New-StatePath -Name "missing-result.json") -QaActorIdentity "codex-cycle-qa-test" -QaActorKind "codex" -QaAuthorityType "separate_qa_gate" | Out-Null
    }

    $malformedResultPath = New-StatePath -Name "malformed-result.json"
    Set-Content -LiteralPath $malformedResultPath -Value "{ not-json" -Encoding UTF8
    Invoke-ExpectedRefusal -Label "malformed-dev-result" -RequiredFragments @("not valid JSON") -Action {
        & $newSignoff -DispatchPath $validDispatchPath -DevResultPath $malformedResultPath -QaActorIdentity "codex-cycle-qa-test" -QaActorKind "codex" -QaAuthorityType "separate_qa_gate" | Out-Null
    }

    $cycleMismatchPath = New-MutatedDevResultPath -Name "cycle-mismatch-result.json" -Mutate {
        param($doc)
        $doc.cycle_id = "cycle-r11-007-mismatch"
    }
    Invoke-ExpectedRefusal -Label "dispatch-result-cycle-mismatch" -RequiredFragments @("cycle_id", "does not match") -Action {
        & $newSignoff -DispatchPath $validDispatchPath -DevResultPath $cycleMismatchPath -QaActorIdentity "codex-cycle-qa-test" -QaActorKind "codex" -QaAuthorityType "separate_qa_gate" | Out-Null
    }

    $noEvidencePath = New-MutatedDevResultPath -Name "completed-no-evidence-result.json" -Mutate {
        param($doc)
        $doc.evidence_refs = @()
        foreach ($taskResult in @($doc.task_results)) {
            $taskResult.evidence_refs = @()
        }
    }
    Invoke-ExpectedRefusal -Label "completed-dev-result-without-evidence" -RequiredFragments @("evidence_refs", "completed") -Action {
        & $newSignoff -DispatchPath $validDispatchPath -DevResultPath $noEvidencePath -QaActorIdentity "codex-cycle-qa-test" -QaActorKind "codex" -QaAuthorityType "separate_qa_gate" | Out-Null
    }

    $outsideChangedPath = New-MutatedDevResultPath -Name "outside-changed-result.json" -Mutate {
        param($doc)
        $doc.changed_files = @("README.md")
        $doc.task_results[0].changed_files = @("README.md")
    }
    Invoke-ExpectedRefusal -Label "changed-file-outside-dispatch-scope" -RequiredFragments @("changed_files", "outside") -Action {
        & $newSignoff -DispatchPath $validDispatchPath -DevResultPath $outsideChangedPath -QaActorIdentity "codex-cycle-qa-test" -QaActorKind "codex" -QaAuthorityType "separate_qa_gate" | Out-Null
    }

    $outsideArtifactPath = New-MutatedDevResultPath -Name "outside-artifact-result.json" -Mutate {
        param($doc)
        $doc.produced_artifacts = @("README.md")
        $doc.task_results[0].produced_artifacts = @("README.md")
    }
    Invoke-ExpectedRefusal -Label "produced-artifact-outside-dispatch-scope" -RequiredFragments @("produced_artifacts", "outside") -Action {
        & $newSignoff -DispatchPath $validDispatchPath -DevResultPath $outsideArtifactPath -QaActorIdentity "codex-cycle-qa-test" -QaActorKind "codex" -QaAuthorityType "separate_qa_gate" | Out-Null
    }

    Invoke-ExpectedRefusal -Label "dev-result-claiming-qa-authority" -RequiredFragments @("QA authority") -Action {
        & $newSignoff -DispatchPath $validDispatchPath -DevResultPath (Join-Path $repoRoot "state\fixtures\invalid\cycle_controller\dev_execution_result_packet.qa_claim.invalid.json") -QaActorIdentity "codex-cycle-qa-test" -QaActorKind "codex" -QaAuthorityType "separate_qa_gate" | Out-Null
    }

    $qaVerdictClaimPath = New-MutatedDevResultPath -Name "qa-verdict-claim-result.json" -Mutate {
        param($doc)
        Add-Member -InputObject $doc -MemberType NoteProperty -Name "qa_verdict" -Value "passed"
    }
    Invoke-ExpectedRefusal -Label "dev-result-claiming-qa-verdict" -RequiredFragments @("QA", "verdict") -Action {
        & $newSignoff -DispatchPath $validDispatchPath -DevResultPath $qaVerdictClaimPath -QaActorIdentity "codex-cycle-qa-test" -QaActorKind "codex" -QaAuthorityType "separate_qa_gate" | Out-Null
    }

    $completeCycleClaimPath = New-MutatedDevResultPath -Name "complete-cycle-claim-result.json" -Mutate {
        param($doc)
        $doc.task_results[0].summary = "The complete controlled cycle ran and is accepted."
    }
    Invoke-ExpectedRefusal -Label "dev-result-claiming-complete-controlled-cycle" -RequiredFragments @("complete controlled cycle") -Action {
        & $newSignoff -DispatchPath $validDispatchPath -DevResultPath $completeCycleClaimPath -QaActorIdentity "codex-cycle-qa-test" -QaActorKind "codex" -QaAuthorityType "separate_qa_gate" | Out-Null
    }

    Invoke-ExpectedRefusal -Label "qa-actor-missing" -RequiredFragments @("QaActorIdentity", "empty string") -Action {
        & $newSignoff -DispatchPath $validDispatchPath -DevResultPath $validDevResultPath -QaActorIdentity "" -QaActorKind "codex" -QaAuthorityType "separate_qa_gate" | Out-Null
    }

    Invoke-ExpectedRefusal -Label "same-qa-actor-as-executor-without-boundary" -RequiredFragments @("matches executor identity", "self-certification") -Action {
        & $newSignoff -DispatchPath $validDispatchPath -DevResultPath $validDevResultPath -QaActorIdentity $devResult.executor_identity -QaActorKind "codex" -QaAuthorityType "separate_qa_gate" | Out-Null
    }

    $signoffNoEvidence = Copy-JsonObject -Object (Get-JsonDocument -Path $signoffPath)
    $signoffNoEvidence.source_evidence_refs = @()
    Invoke-ExpectedRefusal -Label "qa-signoff-without-source-evidence-refs" -RequiredFragments @("source_evidence_refs", "must not be empty") -Action {
        & $testSignoffObject -SignoffPacket $signoffNoEvidence -DispatchPacket $dispatch -DevResultPacket $devResult | Out-Null
    }

    $signoffMissingNonClaim = Copy-JsonObject -Object (Get-JsonDocument -Path $signoffPath)
    $signoffMissingNonClaim.non_claims = @($signoffMissingNonClaim.non_claims | Where-Object { $_ -ne "no solved Codex context compaction" })
    Invoke-ExpectedRefusal -Label "qa-signoff-missing-non-claim" -RequiredFragments @("non_claims", "no solved Codex context compaction") -Action {
        & $testSignoffObject -SignoffPacket $signoffMissingNonClaim -DispatchPacket $dispatch -DevResultPacket $devResult | Out-Null
    }

    $invalidFixturePaths = @(Get-ChildItem -Path (Join-Path $repoRoot "state\fixtures\invalid\cycle_controller") -Filter "cycle_qa_signoff_packet.*.invalid.json" -File | Select-Object -ExpandProperty FullName)
    Assert-Condition -Condition ($invalidFixturePaths.Count -gt 0) -Message "No invalid QA signoff fixtures were found."
    foreach ($invalidFixturePath in $invalidFixturePaths) {
        Invoke-ExpectedRefusal -Label ("invalid-fixture-" + (Split-Path $invalidFixturePath -Leaf)) -Action {
            & $testSignoff -SignoffPath $invalidFixturePath -DispatchPath $validDispatchPath -DevResultPath $validDevResultPath | Out-Null
        }
    }
}
catch {
    $failures += ("FAIL cycle QA gate harness: {0}" -f $_.Exception.Message)
}
finally {
    $resolvedStateRoot = [System.IO.Path]::GetFullPath($stateRoot)
    $allowedStateRoot = [System.IO.Path]::GetFullPath((Join-Path $repoRoot "state\cycle_controller"))
    if (-not $allowedStateRoot.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $allowedStateRoot = $allowedStateRoot + [System.IO.Path]::DirectorySeparatorChar
    }
    if ($resolvedStateRoot.StartsWith($allowedStateRoot, [System.StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $resolvedStateRoot)) {
        Remove-Item -LiteralPath $resolvedStateRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Cycle QA gate tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All cycle QA gate tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
