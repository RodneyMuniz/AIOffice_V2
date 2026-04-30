$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$module = Import-Module (Join-Path $repoRoot "tools\OperatingLoop.psm1") -Force -PassThru
$jsonRootModule = Import-Module (Join-Path $repoRoot "tools\JsonRoot.psm1") -Force -PassThru
$testOperatingLoop = $module.ExportedCommands["Test-OperatingLoopContract"]
$readSingleJsonObject = $jsonRootModule.ExportedCommands["Read-SingleJsonObject"]

$validFixture = Join-Path $repoRoot "state\fixtures\valid\operating_loop\r12_operating_loop.valid.json"
$invalidFixtureRoot = Join-Path $repoRoot "state\fixtures\invalid\operating_loop"
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r12operatingloop" + [guid]::NewGuid().ToString("N").Substring(0, 8))

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

function New-MutatedLoopPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Mutation
    )

    $loop = Get-JsonDocument -Path $validFixture
    & $Mutation $loop
    $path = Join-Path $tempRoot ("$Label.json")
    Write-JsonDocument -Path $path -Document $loop
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

try {
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

    $validResult = & $testOperatingLoop -LoopPath $validFixture
    Write-Output ("PASS valid operating loop fixture: {0} -> {1} with {2} transition(s)" -f $validResult.LoopId, $validResult.State, $validResult.TransitionCount)
    $validPassed += 1

    Invoke-ExpectedRefusal -Label "invalid-missing-external-runner-evidence" -RequiredFragments @("external_runner_result_ref") -Action {
        & $testOperatingLoop -LoopPath (Join-Path $invalidFixtureRoot "r12_operating_loop.missing-external-runner-evidence.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-qa-without-actionable-report" -RequiredFragments @("actionable_qa_report_ref") -Action {
        & $testOperatingLoop -LoopPath (Join-Path $invalidFixtureRoot "r12_operating_loop.qa-without-actionable-report.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-operator-decision-without-control-room" -RequiredFragments @("control_room_status_ref") -Action {
        & $testOperatingLoop -LoopPath (Join-Path $invalidFixtureRoot "r12_operating_loop.operator-decision-without-control-room.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-successor-milestone" -RequiredFragments @("successor milestone", "rejected") -Action {
        & $testOperatingLoop -LoopPath (Join-Path $invalidFixtureRoot "r12_operating_loop.successor-milestone.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-chat-memory-authority" -RequiredFragments @("chat transcript", "authority") -Action {
        & $testOperatingLoop -LoopPath (Join-Path $invalidFixtureRoot "r12_operating_loop.chat-memory-authority.invalid.json") | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-illegal-state-transition" -RequiredFragments @("illegal state transition", "control_room_status_ready") -Action {
        $path = New-MutatedLoopPath -Label "illegal-transition" -Mutation {
            param($loop)
            $loop.transition_history[10].to_state = "control_room_status_ready"
        }
        & $testOperatingLoop -LoopPath $path | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-final-support-before-candidate" -RequiredFragments @("final support", "candidate closeout") -Action {
        $path = New-MutatedLoopPath -Label "final-support-before-candidate" -Mutation {
            param($loop)
            $loop.evidence_refs.candidate_closeout_ref = ""
        }
        & $testOperatingLoop -LoopPath $path | Out-Null
    }

    Invoke-ExpectedRefusal -Label "invalid-broad-runtime-claim" -RequiredFragments @("broad autonomy/product/runtime claim", "production runtime") -Action {
        $path = New-MutatedLoopPath -Label "broad-runtime-claim" -Mutation {
            param($loop)
            $loop.claims = @("production runtime")
        }
        & $testOperatingLoop -LoopPath $path | Out-Null
    }
}
catch {
    $failures += ("FAIL operating-loop harness: {0}" -f $_.Exception.Message)
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Operating-loop tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All operating-loop tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
