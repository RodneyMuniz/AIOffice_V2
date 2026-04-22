$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot

$workArtifactValidationModule = Import-Module (Join-Path $repoRoot "tools\WorkArtifactValidation.psm1") -Force -PassThru
$governedWorkObjectValidationModule = Import-Module (Join-Path $repoRoot "tools\GovernedWorkObjectValidation.psm1") -Force -PassThru
$milestoneAutocycleProposalModule = Import-Module (Join-Path $repoRoot "tools\MilestoneAutocycleProposal.psm1") -Force -PassThru
$testWorkArtifactContract = $workArtifactValidationModule.ExportedCommands["Test-WorkArtifactContract"]
$testGovernedWorkObjectContract = $governedWorkObjectValidationModule.ExportedCommands["Test-GovernedWorkObjectContract"]
$testMilestoneAutocycleProposalIntakeContract = $milestoneAutocycleProposalModule.ExportedCommands["Test-MilestoneAutocycleProposalIntakeContract"]
$testMilestoneAutocycleProposalContract = $milestoneAutocycleProposalModule.ExportedCommands["Test-MilestoneAutocycleProposalContract"]
$invokeMilestoneAutocycleProposalFlow = $milestoneAutocycleProposalModule.ExportedCommands["Invoke-MilestoneAutocycleProposalFlow"]

function Get-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Write-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Document
    )

    $json = $Document | ConvertTo-Json -Depth 20
    Set-Content -LiteralPath $Path -Value $json -Encoding UTF8
}

function Resolve-ArtifactReferencePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArtifactPath,
        [Parameter(Mandatory = $true)]
        [string]$Reference
    )

    $baseDirectory = Split-Path -Parent $ArtifactPath
    if ([System.IO.Path]::IsPathRooted($Reference)) {
        return (Resolve-Path -LiteralPath $Reference).Path
    }

    return (Resolve-Path -LiteralPath (Join-Path $baseDirectory ($Reference -replace "[/\\]", [System.IO.Path]::DirectorySeparatorChar))).Path
}

function New-ExpandedTaskDrafts {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$ExistingTaskDrafts,
        [Parameter(Mandatory = $true)]
        [int]$TargetCount
    )

    $expandedTasks = [System.Collections.ArrayList]::new()
    foreach ($taskDraft in @($ExistingTaskDrafts)) {
        [void]$expandedTasks.Add($taskDraft)
    }

    $counter = 1
    while ($expandedTasks.Count -lt $TargetCount) {
        $templateTask = $ExistingTaskDrafts[0]
        [void]$expandedTasks.Add([pscustomobject]@{
                task_id           = "task-r6-pilot-extra-{0}" -f $counter.ToString("00")
                title             = "Extra bounded milestone task {0}" -f $counter
                task_kind         = $templateTask.task_kind
                scope_summary     = "Extra bounded task added only to exceed the proposal task-count ceiling."
                requested_outcome = "This generated draft exists only to push the structured intake above the allowed task-count ceiling."
                acceptance_checks = @(
                    "The milestone proposal refuses task sets above the bounded task-count ceiling."
                )
                non_goals         = @(
                    "Any new runtime behavior"
                )
                depends_on_ids    = @()
                notes             = "Generated only for the out-of-bound task-count refusal path."
            })
        $counter += 1
    }

    return @($expandedTasks)
}

$validMilestone = Join-Path $repoRoot "state\fixtures\valid\milestone_autocycle\governed_work_object.milestone.valid.json"
$validRequestBrief = Join-Path $repoRoot "state\fixtures\valid\milestone_autocycle\request_brief.valid.json"
$validProposalIntake = Join-Path $repoRoot "state\fixtures\valid\milestone_autocycle\proposal_intake.valid.json"
$expectedProposal = Join-Path $repoRoot "state\fixtures\valid\milestone_autocycle\proposal.expected.json"

$failures = @()
$validPassed = 0
$invalidRejected = 0

try {
    $milestoneCheck = & $testGovernedWorkObjectContract -WorkObjectPath $validMilestone
    Write-Output ("PASS valid milestone fixture: {0} -> {1} {2}" -f (Resolve-Path -Relative $validMilestone), $milestoneCheck.ObjectType, $milestoneCheck.ObjectId)

    $requestBriefCheck = & $testWorkArtifactContract -ArtifactPath $validRequestBrief
    Write-Output ("PASS valid request fixture: {0} -> {1} {2}" -f (Resolve-Path -Relative $validRequestBrief), $requestBriefCheck.ArtifactType, $requestBriefCheck.ArtifactId)

    $proposalIntakeCheck = & $testMilestoneAutocycleProposalIntakeContract -ProposalIntakePath $validProposalIntake
    Write-Output ("PASS valid proposal intake fixture: {0} -> {1} tasks" -f (Resolve-Path -Relative $validProposalIntake), $proposalIntakeCheck.TaskCount)

    $expectedProposalCheck = & $testMilestoneAutocycleProposalContract -ProposalPath $expectedProposal
    Write-Output ("PASS valid expected proposal fixture: {0} -> {1} tasks" -f (Resolve-Path -Relative $expectedProposal), $expectedProposalCheck.TaskCount)

    $tempRoot = Join-Path $env:TEMP ("aioffice-r6-002-proposal-{0}" -f ([guid]::NewGuid().ToString("N")))
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

    try {
        $createdAt = [datetime]::Parse("2026-04-22T03:30:00Z").ToUniversalTime()
        $flowResult = & $invokeMilestoneAutocycleProposalFlow -ProposalIntakePath $validProposalIntake -OutputRoot $tempRoot -ProposalId "proposal-r6-002-valid-001" -CreatedAt $createdAt
        $generatedCheck = & $testMilestoneAutocycleProposalContract -ProposalPath $flowResult.ProposalPath
        Write-Output ("PASS valid proposal flow: {0} -> {1}" -f $proposalIntakeCheck.IntakeId, $generatedCheck.ProposalId)

        $generated = Get-JsonDocument -Path $flowResult.ProposalPath
        $expected = Get-JsonDocument -Path $expectedProposal

        foreach ($fieldName in @("record_type", "proposal_id", "task_count", "status", "notes")) {
            if ($generated.$fieldName -ne $expected.$fieldName) {
                $failures += ("FAIL valid proposal flow: field '{0}' expected '{1}' but found '{2}'." -f $fieldName, $expected.$fieldName, $generated.$fieldName)
            }
        }

        foreach ($fieldName in @("object_type", "object_id", "title", "status")) {
            if ($generated.milestone_identity.$fieldName -ne $expected.milestone_identity.$fieldName) {
                $failures += ("FAIL valid proposal flow: milestone_identity.{0} expected '{1}' but found '{2}'." -f $fieldName, $expected.milestone_identity.$fieldName, $generated.milestone_identity.$fieldName)
            }
        }

        if (($generated.scope_notes -join "|") -ne ($expected.scope_notes -join "|")) {
            $failures += "FAIL valid proposal flow: scope_notes did not match the expected proposal."
        }
        if (($generated.assumptions -join "|") -ne ($expected.assumptions -join "|")) {
            $failures += "FAIL valid proposal flow: assumptions did not match the expected proposal."
        }
        if (($generated.refusal_reasons -join "|") -ne ($expected.refusal_reasons -join "|")) {
            $failures += "FAIL valid proposal flow: refusal_reasons did not match the expected proposal."
        }

        foreach ($fieldName in @("intake_ref", "request_brief_ref", "milestone_ref")) {
            $generatedResolved = Resolve-ArtifactReferencePath -ArtifactPath $flowResult.ProposalPath -Reference $generated.$fieldName
            $expectedResolved = Resolve-ArtifactReferencePath -ArtifactPath $expectedProposal -Reference $expected.$fieldName
            if ($generatedResolved -ne $expectedResolved) {
                $failures += ("FAIL valid proposal flow: {0} did not resolve to the expected durable path." -f $fieldName)
            }
        }

        if (@($generated.proposed_task_set).Count -ne @($expected.proposed_task_set).Count) {
            $failures += "FAIL valid proposal flow: proposed_task_set count did not match the expected proposal."
        }
        else {
            for ($index = 0; $index -lt @($generated.proposed_task_set).Count; $index += 1) {
                $generatedTask = $generated.proposed_task_set[$index]
                $expectedTask = $expected.proposed_task_set[$index]

                foreach ($fieldName in @("sequence", "task_id", "title", "status", "task_kind", "scope_summary", "requested_outcome", "notes")) {
                    if ($generatedTask.$fieldName -ne $expectedTask.$fieldName) {
                        $failures += ("FAIL valid proposal flow: proposed_task_set[{0}].{1} expected '{2}' but found '{3}'." -f $index, $fieldName, $expectedTask.$fieldName, $generatedTask.$fieldName)
                    }
                }

                foreach ($fieldName in @("object_type", "object_id")) {
                    if ($generatedTask.parent.$fieldName -ne $expectedTask.parent.$fieldName) {
                        $failures += ("FAIL valid proposal flow: proposed_task_set[{0}].parent.{1} expected '{2}' but found '{3}'." -f $index, $fieldName, $expectedTask.parent.$fieldName, $generatedTask.parent.$fieldName)
                    }
                }

                $generatedParentResolved = Resolve-ArtifactReferencePath -ArtifactPath $flowResult.ProposalPath -Reference $generatedTask.parent.ref
                $expectedParentResolved = Resolve-ArtifactReferencePath -ArtifactPath $expectedProposal -Reference $expectedTask.parent.ref
                if ($generatedParentResolved -ne $expectedParentResolved) {
                    $failures += ("FAIL valid proposal flow: proposed_task_set[{0}].parent.ref did not resolve to the expected milestone." -f $index)
                }

                if (($generatedTask.acceptance_checks -join "|") -ne ($expectedTask.acceptance_checks -join "|")) {
                    $failures += ("FAIL valid proposal flow: proposed_task_set[{0}].acceptance_checks did not match the expected proposal." -f $index)
                }
                if (($generatedTask.non_goals -join "|") -ne ($expectedTask.non_goals -join "|")) {
                    $failures += ("FAIL valid proposal flow: proposed_task_set[{0}].non_goals did not match the expected proposal." -f $index)
                }
                if (($generatedTask.depends_on_ids -join "|") -ne ($expectedTask.depends_on_ids -join "|")) {
                    $failures += ("FAIL valid proposal flow: proposed_task_set[{0}].depends_on_ids did not match the expected proposal." -f $index)
                }
            }
        }

        $validPassed += 1
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }

    $validIntakeDocument = Get-JsonDocument -Path $validProposalIntake
    $invalidCases = @(
        @{
            Name = "missing-request-brief-ref"
            Mutate = {
                param($Document)
                $Document.PSObject.Properties.Remove("request_brief_ref")
                return $Document
            }
        },
        @{
            Name = "too-few-tasks"
            Mutate = {
                param($Document)
                $Document.proposed_tasks = @($Document.proposed_tasks[0..3])
                return $Document
            }
        },
        @{
            Name = "too-many-tasks"
            Mutate = {
                param($Document)
                $Document.proposed_tasks = @(New-ExpandedTaskDrafts -ExistingTaskDrafts @($Document.proposed_tasks) -TargetCount 11)
                return $Document
            }
        }
    )

    foreach ($invalidCase in @($invalidCases)) {
        $invalidTempRoot = Join-Path $env:TEMP ("aioffice-r6-002-invalid-{0}-{1}" -f $invalidCase.Name, ([guid]::NewGuid().ToString("N")))
        New-Item -ItemType Directory -Path $invalidTempRoot -Force | Out-Null

        try {
            $invalidInputPath = Join-Path $invalidTempRoot "proposal_intake.invalid.json"
            $invalidInput = ConvertFrom-Json ($validIntakeDocument | ConvertTo-Json -Depth 20)
            $invalidInput.request_brief_ref = $validRequestBrief
            $invalidInput.milestone_ref = $validMilestone
            $invalidInput = & $invalidCase.Mutate $invalidInput
            Write-JsonDocument -Path $invalidInputPath -Document $invalidInput

            try {
                & $invokeMilestoneAutocycleProposalFlow -ProposalIntakePath $invalidInputPath -OutputRoot (Join-Path $invalidTempRoot "output") -ProposalId "proposal-invalid" -CreatedAt ([datetime]::Parse("2026-04-22T03:35:00Z").ToUniversalTime()) | Out-Null
                $failures += ("FAIL invalid proposal flow: {0} was accepted unexpectedly." -f $invalidCase.Name)
            }
            catch {
                Write-Output ("PASS invalid proposal flow: {0} -> {1}" -f $invalidCase.Name, $_.Exception.Message)
                $invalidRejected += 1
            }
        }
        finally {
            if (Test-Path -LiteralPath $invalidTempRoot) {
                Remove-Item -LiteralPath $invalidTempRoot -Recurse -Force
            }
        }
    }
}
catch {
    $failures += ("FAIL milestone proposal harness: {0}" -f $_.Exception.Message)
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Milestone proposal tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All milestone proposal tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
