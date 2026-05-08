$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$modulePath = Join-Path $repoRoot "tools\R17OperatorIntakeSurface.psm1"
Import-Module $modulePath -Force

$failures = @()
$validPassed = 0
$invalidRejected = 0
$paths = Get-R17OperatorIntakePaths -RepositoryRoot $repoRoot
$fixtureRoot = $paths.FixtureRoot

function Read-JsonFixture {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Invoke-ExpectedRefusal {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [Parameter(Mandatory = $true)]
        [scriptblock]$Action
    )

    try {
        & $Action | Out-Null
        $script:failures += ("FAIL invalid: {0} was accepted unexpectedly." -f $Label)
    }
    catch {
        Write-Output ("PASS invalid: {0} -> {1}" -f $Label, $_.Exception.Message)
        $script:invalidRejected += 1
    }
}

try {
    $liveResult = Test-R17OperatorIntakeSurface -RepositoryRoot $repoRoot
    if ($liveResult.AggregateVerdict -ne "generated_r17_operator_interaction_surface_candidate" -or
        $liveResult.RuntimeOrchestratorInvoked -ne $false -or
        $liveResult.BoardMutationPerformed -ne $false -or
        $liveResult.CardCreated -ne $false -or
        $liveResult.AgentInvocationPerformed -ne $false -or
        $liveResult.A2aMessageSent -ne $false -or
        $liveResult.ApiCallPerformed -ne $false -or
        $liveResult.DevOutputClaimed -ne $false -or
        $liveResult.QaResultClaimed -ne $false -or
        $liveResult.AuditVerdictClaimed -ne $false) {
        $failures += "FAIL valid: live R17-011 operator intake surface returned an unexpected validation result."
    }
    else {
        Write-Output "PASS valid: live R17-011 operator intake surface validated."
        $validPassed += 1
    }

    $contract = Read-JsonFixture -Path $paths.Contract
    $validPacket = Read-JsonFixture -Path (Join-Path $fixtureRoot "valid_operator_intake_seed_packet.json")
    $validProposal = Read-JsonFixture -Path (Join-Path $fixtureRoot "valid_orchestrator_intake_proposal.json")
    $validReport = Read-JsonFixture -Path (Join-Path $fixtureRoot "valid_operator_intake_check_report.json")
    $validSnapshot = Read-JsonFixture -Path (Join-Path $fixtureRoot "valid_operator_intake_snapshot.json")
    $authorityState = Read-JsonFixture -Path (Join-Path $repoRoot "state\agents\r17_orchestrator_identity_authority.json")
    $loopStateMachine = Read-JsonFixture -Path (Join-Path $repoRoot "state\orchestration\r17_orchestrator_loop_state_machine.json")

    $fixtureResult = Test-R17OperatorIntakeSurfaceSet `
        -Contract $contract `
        -Packet $validPacket `
        -Proposal $validProposal `
        -Report $validReport `
        -Snapshot $validSnapshot `
        -AuthorityState $authorityState `
        -LoopStateMachine $loopStateMachine

    if ($fixtureResult.RecommendedCardId -ne "R17-011") {
        $failures += "FAIL valid: valid fixture set did not recommend R17-011."
    }
    else {
        Write-Output "PASS valid: fixture set validated."
        $validPassed += 1
    }

    $invalidFixturePaths = Get-ChildItem -LiteralPath $fixtureRoot -Filter "invalid_*.json" | Sort-Object Name
    foreach ($fixturePath in $invalidFixturePaths) {
        $mutation = Read-JsonFixture -Path $fixturePath.FullName

        Invoke-ExpectedRefusal -Label $fixturePath.Name -Action {
            if ($mutation.target -eq "ui_external_dependency") {
                $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("r17intakeui" + [guid]::NewGuid().ToString("N").Substring(0, 8))
                New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
                try {
                    foreach ($sourcePath in $paths.UiFiles) {
                        Copy-Item -LiteralPath $sourcePath -Destination (Join-Path $tempRoot (Split-Path -Leaf $sourcePath)) -Force
                    }

                    Add-Content -LiteralPath (Join-Path $tempRoot $mutation.ui_file) -Value $mutation.append_text -Encoding UTF8

                    Test-R17OperatorIntakeSurfaceSet `
                        -Contract $contract `
                        -Packet $validPacket `
                        -Proposal $validProposal `
                        -Report $validReport `
                        -Snapshot $validSnapshot `
                        -AuthorityState $authorityState `
                        -LoopStateMachine $loopStateMachine `
                        -UiFilePaths @(
                            (Join-Path $tempRoot "index.html"),
                            (Join-Path $tempRoot "styles.css"),
                            (Join-Path $tempRoot "kanban.js"),
                            (Join-Path $tempRoot "README.md")
                        ) | Out-Null
                }
                finally {
                    if (Test-Path -LiteralPath $tempRoot) {
                        Remove-Item -LiteralPath $tempRoot -Recurse -Force
                    }
                }

                return
            }

            $mutatedContract = Copy-R17Object -Value $contract
            $mutatedPacket = Copy-R17Object -Value $validPacket
            $mutatedProposal = Copy-R17Object -Value $validProposal
            $mutatedReport = Copy-R17Object -Value $validReport
            $mutatedSnapshot = Copy-R17Object -Value $validSnapshot

            if ($mutation.target -eq "contract") {
                Invoke-R17OperatorIntakeMutation -TargetObject $mutatedContract -Mutation $mutation | Out-Null
            }
            elseif ($mutation.target -eq "operator_intake_packet") {
                Invoke-R17OperatorIntakeMutation -TargetObject $mutatedPacket -Mutation $mutation | Out-Null
            }
            elseif ($mutation.target -eq "orchestrator_intake_proposal") {
                Invoke-R17OperatorIntakeMutation -TargetObject $mutatedProposal -Mutation $mutation | Out-Null
            }
            elseif ($mutation.target -eq "operator_intake_check_report") {
                Invoke-R17OperatorIntakeMutation -TargetObject $mutatedReport -Mutation $mutation | Out-Null
            }
            elseif ($mutation.target -eq "operator_intake_snapshot") {
                Invoke-R17OperatorIntakeMutation -TargetObject $mutatedSnapshot -Mutation $mutation | Out-Null
            }
            elseif ($mutation.target -eq "artifact_set" -and $mutation.remove_artifact -eq "proposal") {
                $mutatedProposal = $null
            }
            else {
                throw "Unknown invalid fixture target '$($mutation.target)'."
            }

            Test-R17OperatorIntakeSurfaceSet `
                -Contract $mutatedContract `
                -Packet $mutatedPacket `
                -Proposal $mutatedProposal `
                -Report $mutatedReport `
                -Snapshot $mutatedSnapshot `
                -AuthorityState $authorityState `
                -LoopStateMachine $loopStateMachine | Out-Null
        }
    }
}
catch {
    $failures += ("FAIL r17 operator intake surface test harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("R17 operator intake surface tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

if ($invalidRejected -lt 35) {
    throw ("R17 operator intake surface tests rejected too few invalid fixtures. Rejected: {0}" -f $invalidRejected)
}

Write-Output ("All R17 operator intake surface tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
