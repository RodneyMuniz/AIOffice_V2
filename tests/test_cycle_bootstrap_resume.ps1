$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$controllerModule = Import-Module (Join-Path $repoRoot "tools\CycleController.psm1") -Force -PassThru -DisableNameChecking -WarningAction SilentlyContinue
$bootstrapModule = Import-Module (Join-Path $repoRoot "tools\CycleBootstrap.psm1") -Force -PassThru -DisableNameChecking -WarningAction SilentlyContinue
$jsonRootModule = Import-Module (Join-Path $repoRoot "tools\JsonRoot.psm1") -Force -PassThru

$initialize = $controllerModule.ExportedCommands["Initialize-CycleControllerLedger"]
$prepareBootstrap = $bootstrapModule.ExportedCommands["New-CycleBootstrapResume"]
$testBootstrapPacket = $bootstrapModule.ExportedCommands["Test-CycleBootstrapPacketContract"]
$testNextActionPacket = $bootstrapModule.ExportedCommands["Test-CycleNextActionPacketContract"]
$readSingleJsonObject = $jsonRootModule.ExportedCommands["Read-SingleJsonObject"]

$cliPath = Join-Path $repoRoot "tools\prepare_cycle_bootstrap.ps1"
$tempRoot = Join-Path $repoRoot ("state\cycle_controller\test-r11-004-" + [guid]::NewGuid().ToString("N").Substring(0, 8))
$headSha = (& git -C $repoRoot rev-parse HEAD).Trim()
$treeSha = (& git -C $repoRoot rev-parse "HEAD^{tree}").Trim()
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

    $json = $Document | ConvertTo-Json -Depth 80
    Set-Content -LiteralPath $Path -Value $json -Encoding UTF8
}

function New-LedgerPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
    return (Join-Path $tempRoot ("{0}.ledger.json" -f $Name))
}

function New-OutputRoot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    return (Join-Path $tempRoot ("{0}\packets" -f $Name))
}

function New-InitializedLedger {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $path = New-LedgerPath -Name $Name
    & $initialize -CycleId ("cycle-r11-004-{0}" -f $Name) -OutputPath $path -HeadSha $headSha -TreeSha $treeSha | Out-Null
    return $path
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

try {
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

    $fixtureBootstrapValidation = & $testBootstrapPacket -PacketPath (Join-Path $repoRoot "state\fixtures\valid\cycle_controller\cycle_bootstrap_packet.valid.json")
    $fixtureNextActionValidation = & $testNextActionPacket -PacketPath (Join-Path $repoRoot "state\fixtures\valid\cycle_controller\cycle_next_action_packet.valid.json")
    if (-not $fixtureBootstrapValidation.IsValid -or -not $fixtureNextActionValidation.IsValid) {
        $failures += "FAIL valid: checked-in bootstrap and next-action fixtures did not validate."
    }
    else {
        Write-Output "PASS valid: checked-in bootstrap and next-action fixtures validate."
        $validPassed += 1
    }

    $initializedPath = New-InitializedLedger -Name "initialized"
    $result = & $prepareBootstrap -LedgerPath $initializedPath -OutputRoot (New-OutputRoot -Name "initialized") -BootstrapId "bootstrap-r11-004-initialized" -NextActionId "next-action-r11-004-initialized"
    if ($result.Status -ne "succeeded" -or $result.LedgerState -ne "initialized" -or $result.RecommendedAction -ne "advance_to_request_recorded") {
        $failures += "FAIL valid: bootstrap from initialized ledger did not report initialized state and request-recorded next action."
    }
    elseif (-not (Test-Path -LiteralPath $result.BootstrapPacketPath) -or -not (Test-Path -LiteralPath $result.NextActionPacketPath)) {
        $failures += "FAIL valid: bootstrap from initialized ledger did not write both packet artifacts."
    }
    else {
        Write-Output ("PASS valid: bootstrap from initialized ledger succeeds -> {0}" -f $result.RecommendedAction)
        $validPassed += 1
    }

    $bootstrapPacket = Get-JsonDocument -Path $result.BootstrapPacketPath
    $nextActionPacket = Get-JsonDocument -Path $result.NextActionPacketPath
    if ($nextActionPacket.allowed_target_states.Count -ne $bootstrapPacket.allowed_next_states.Count -or $nextActionPacket.allowed_target_states[0] -ne "request_recorded" -or $nextActionPacket.allowed_target_states[1] -ne "stopped") {
        $failures += "FAIL valid: next-action packet did not preserve allowed target states from the ledger."
    }
    else {
        Write-Output ("PASS valid: next-action packet uses ledger allowed states -> {0}" -f ($nextActionPacket.allowed_target_states -join ", "))
        $validPassed += 1
    }

    $generatedBootstrapValidation = & $testBootstrapPacket -PacketPath $result.BootstrapPacketPath
    $generatedNextActionValidation = & $testNextActionPacket -PacketPath $result.NextActionPacketPath
    if (-not $generatedBootstrapValidation.IsValid -or -not $generatedNextActionValidation.IsValid) {
        $failures += "FAIL valid: generated bootstrap or next-action packet did not validate against its contract."
    }
    else {
        Write-Output "PASS valid: generated bootstrap and next-action packets validate against contracts."
        $validPassed += 1
    }

    $authorityText = @(
        $bootstrapPacket.bootstrap_source,
        $bootstrapPacket.state_authority,
        [string]$bootstrapPacket.chat_memory_authority_allowed
    ) -join " "
    if ($authorityText -match '(?i)chat transcript|chat memory|narration|manual assertion' -or $bootstrapPacket.state_authority -ne "cycle_ledger_artifact" -or $bootstrapPacket.chat_memory_authority_allowed) {
        $failures += "FAIL valid: generated bootstrap packet used chat transcript or memory as authority."
    }
    else {
        Write-Output "PASS valid: generated bootstrap packet uses repo-truth ledger authority, not chat transcript memory."
        $validPassed += 1
    }

    $cliLedgerPath = New-InitializedLedger -Name "cli"
    $cliResult = Invoke-CliJson -Parameters @{
        LedgerPath = $cliLedgerPath
        OutputRoot = (New-OutputRoot -Name "cli")
        BootstrapId = "bootstrap-r11-004-cli"
        NextActionId = "next-action-r11-004-cli"
    }
    if ($cliResult.Status -ne "succeeded" -or $cliResult.RecommendedAction -ne "advance_to_request_recorded") {
        $failures += "FAIL valid: prepare_cycle_bootstrap.ps1 did not return a successful JSON result."
    }
    else {
        Write-Output ("PASS valid: CLI prepares bootstrap JSON -> {0}" -f $cliResult.RecommendedAction)
        $validPassed += 1
    }

    Invoke-ExpectedRefusal -Label "missing-ledger" -RequiredFragments @("Cycle ledger", "does not exist") -Action {
        & $prepareBootstrap -LedgerPath (Join-Path $tempRoot "missing.ledger.json") -OutputRoot (New-OutputRoot -Name "missing") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "malformed-ledger" -RequiredFragments @("Cycle ledger", "not valid JSON") -Action {
        $path = New-LedgerPath -Name "malformed"
        Set-Content -LiteralPath $path -Value "{ not-json" -Encoding UTF8
        & $prepareBootstrap -LedgerPath $path -OutputRoot (New-OutputRoot -Name "malformed") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "chat-memory-authority" -RequiredFragments @("state_authority", "chat") -Action {
        $path = New-InitializedLedger -Name "authority-refusal"
        $ledger = Get-JsonDocument -Path $path
        $ledger.controller_authority.state_authority = "chat memory"
        Write-JsonDocument -Path $path -Document $ledger
        & $prepareBootstrap -LedgerPath $path -OutputRoot (New-OutputRoot -Name "authority-refusal") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "branch-mismatch" -RequiredFragments @("branch", "contradicts") -Action {
        $path = New-InitializedLedger -Name "branch-mismatch"
        & $prepareBootstrap -LedgerPath $path -OutputRoot (New-OutputRoot -Name "branch-mismatch") -ExpectedBranch "feature/not-r11-branch" | Out-Null
    }

    Invoke-ExpectedRefusal -Label "head-mismatch" -RequiredFragments @("head", "contradicts") -Action {
        $path = New-InitializedLedger -Name "head-mismatch"
        & $prepareBootstrap -LedgerPath $path -OutputRoot (New-OutputRoot -Name "head-mismatch") -ExpectedHeadSha "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" | Out-Null
    }

    Invoke-ExpectedRefusal -Label "tree-mismatch" -RequiredFragments @("tree", "contradicts") -Action {
        $path = New-InitializedLedger -Name "tree-mismatch"
        & $prepareBootstrap -LedgerPath $path -OutputRoot (New-OutputRoot -Name "tree-mismatch") -ExpectedTreeSha "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb" | Out-Null
    }

    Invoke-ExpectedRefusal -Label "next-action-outside-allowed-states" -RequiredFragments @("outside allowed_next_states") -Action {
        $path = New-InitializedLedger -Name "outside-allowed"
        & $prepareBootstrap -LedgerPath $path -OutputRoot (New-OutputRoot -Name "outside-allowed") -PreferredTargetState "plan_prepared" | Out-Null
    }

    Invoke-ExpectedRefusal -Label "missing-non-claim" -RequiredFragments @("non_claims", "must include") -Action {
        $path = New-InitializedLedger -Name "missing-non-claim"
        $ledger = Get-JsonDocument -Path $path
        $ledger.non_claims = @($ledger.non_claims | Where-Object { $_ -ne "no solved Codex context compaction" })
        Write-JsonDocument -Path $path -Document $ledger
        & $prepareBootstrap -LedgerPath $path -OutputRoot (New-OutputRoot -Name "missing-non-claim") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-fixture-chat-authority" -RequiredFragments @("bootstrap_source") -Action {
        & $testBootstrapPacket -PacketPath (Join-Path $repoRoot "state\fixtures\invalid\cycle_controller\cycle_bootstrap_packet.chat_authority.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-fixture-next-action-outside-allowed" -RequiredFragments @("allowed_target_states", "ledger.allowed_next_states") -Action {
        & $testNextActionPacket -PacketPath (Join-Path $repoRoot "state\fixtures\invalid\cycle_controller\cycle_next_action_packet.outside_allowed.invalid.json") | Out-Null
    }
}
catch {
    $failures += ("FAIL cycle bootstrap resume harness: {0}" -f $_.Exception.Message)
}
finally {
    $expectedPrefix = Join-Path $repoRoot "state\cycle_controller\test-r11-004-"
    if ($tempRoot.StartsWith($expectedPrefix, [System.StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $tempRoot)) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Cycle bootstrap resume tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All cycle bootstrap resume tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
