$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot

$workArtifactValidationModule = Import-Module (Join-Path $repoRoot "tools\WorkArtifactValidation.psm1") -Force -PassThru
$requestBriefFlowModule = Import-Module (Join-Path $repoRoot "tools\RequestBriefTaskPacketPlanningFlow.psm1") -Force -PassThru
$testWorkArtifactContract = $workArtifactValidationModule.ExportedCommands["Test-WorkArtifactContract"]
$invokeRequestBriefToTaskPacketFlow = $requestBriefFlowModule.ExportedCommands["Invoke-RequestBriefToTaskPacketFlow"]

function Get-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
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

$validRequestBrief = Join-Path $repoRoot "state\fixtures\valid\request_brief_task_packet_flow.request_brief.valid.json"
$expectedTaskPacket = Join-Path $repoRoot "state\fixtures\valid\request_brief_task_packet_flow.task_packet.expected.json"
$invalidCases = @(
    (Join-Path $repoRoot "state\fixtures\invalid\request_brief_task_packet_flow.request_brief.invalid-missing-planning-record.json"),
    (Join-Path $repoRoot "state\fixtures\invalid\request_brief_task_packet_flow.request_brief.invalid-working-planning-view.json")
)

$failures = @()
$validPassed = 0
$invalidRejected = 0

try {
    $validRequestBriefCheck = & $testWorkArtifactContract -ArtifactPath $validRequestBrief
    Write-Output ("PASS valid input fixture: {0} -> {1} {2}" -f (Resolve-Path -Relative $validRequestBrief), $validRequestBriefCheck.ArtifactType, $validRequestBriefCheck.ArtifactId)

    $expectedTaskPacketCheck = & $testWorkArtifactContract -ArtifactPath $expectedTaskPacket
    Write-Output ("PASS valid output fixture: {0} -> {1} {2}" -f (Resolve-Path -Relative $expectedTaskPacket), $expectedTaskPacketCheck.ArtifactType, $expectedTaskPacketCheck.ArtifactId)

    $tempRoot = Join-Path $env:TEMP ("aioffice-r3-005-{0}" -f ([guid]::NewGuid().ToString("N")))
    New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

    try {
        $createdAt = [datetime]::Parse("2026-04-19T17:30:00Z").ToUniversalTime()
        $flowResult = & $invokeRequestBriefToTaskPacketFlow -RequestBriefPath $validRequestBrief -OutputRoot $tempRoot -TaskPacketId "task-packet-r3-005-flow-001" -CreatedAt $createdAt -CreatedById "control-kernel:planner"
        $generatedCheck = & $testWorkArtifactContract -ArtifactPath $flowResult.TaskPacketPath
        Write-Output ("PASS valid flow: {0} -> {1} {2}" -f $flowResult.RequestBriefValidation.ArtifactId, $generatedCheck.ArtifactType, $generatedCheck.ArtifactId)

        $generated = Get-JsonDocument -Path $flowResult.TaskPacketPath
        $expected = Get-JsonDocument -Path $expectedTaskPacket

        $simpleFields = @(
            "artifact_type",
            "artifact_id",
            "status",
            "packet_summary",
            "execution_profile"
        )
        foreach ($fieldName in $simpleFields) {
            if ($generated.$fieldName -ne $expected.$fieldName) {
                $failures += ("FAIL valid flow: field '{0}' expected '{1}' but found '{2}'." -f $fieldName, $expected.$fieldName, $generated.$fieldName)
            }
        }

        if ($generated.lineage.source_kind -ne $expected.lineage.source_kind) {
            $failures += ("FAIL valid flow: lineage.source_kind expected '{0}' but found '{1}'." -f $expected.lineage.source_kind, $generated.lineage.source_kind)
        }

        if (($generated.requested_actions -join "|") -ne ($expected.requested_actions -join "|")) {
            $failures += "FAIL valid flow: requested_actions did not match the expected bounded planning output."
        }

        if (($generated.acceptance_checks -join "|") -ne ($expected.acceptance_checks -join "|")) {
            $failures += "FAIL valid flow: acceptance_checks did not match the expected bounded planning output."
        }

        if (($generated.bounded_scope -join "|") -ne ($expected.bounded_scope -join "|")) {
            $failures += "FAIL valid flow: bounded_scope did not match the Request Brief constraints."
        }

        if (($generated.non_goals -join "|") -ne ($expected.non_goals -join "|")) {
            $failures += "FAIL valid flow: non_goals did not match the Request Brief non-goals."
        }

        foreach ($fieldName in @("mode", "runtime_boundary", "orchestration_scope")) {
            if ($generated.pipeline.$fieldName -ne $expected.pipeline.$fieldName) {
                $failures += ("FAIL valid flow: pipeline.{0} expected '{1}' but found '{2}'." -f $fieldName, $expected.pipeline.$fieldName, $generated.pipeline.$fieldName)
            }
        }
        if ([bool]$generated.pipeline.standard_runtime_claimed -ne [bool]$expected.pipeline.standard_runtime_claimed) {
            $failures += "FAIL valid flow: pipeline.standard_runtime_claimed did not match the expected bounded planning value."
        }
        if (($generated.scope.allowed_surfaces -join "|") -ne ($expected.scope.allowed_surfaces -join "|")) {
            $failures += "FAIL valid flow: scope.allowed_surfaces did not preserve the bounded planning scope."
        }
        if (($generated.scope.protected_surfaces -join "|") -ne ($expected.scope.protected_surfaces -join "|")) {
            $failures += "FAIL valid flow: scope.protected_surfaces did not preserve the protected planning scope."
        }
        if (($generated.scope.prohibited_surfaces -join "|") -ne ($expected.scope.prohibited_surfaces -join "|")) {
            $failures += "FAIL valid flow: scope.prohibited_surfaces did not preserve the bounded non-claims."
        }

        if (($generated.handoff_notes -join "|") -ne ($expected.handoff_notes -join "|")) {
            $failures += "FAIL valid flow: handoff_notes did not preserve the Request Brief operator questions."
        }

        if (@($generated.work_object_refs).Count -ne @($expected.work_object_refs).Count) {
            $failures += "FAIL valid flow: generated work_object_refs count did not match the expected Task Packet."
        }
        else {
            for ($index = 0; $index -lt @($generated.work_object_refs).Count; $index += 1) {
                $generatedRef = $generated.work_object_refs[$index]
                $expectedRef = $expected.work_object_refs[$index]
                foreach ($fieldName in @("relation", "object_type", "object_id")) {
                    if ($generatedRef.$fieldName -ne $expectedRef.$fieldName) {
                        $failures += ("FAIL valid flow: work_object_refs[{0}].{1} expected '{2}' but found '{3}'." -f $index, $fieldName, $expectedRef.$fieldName, $generatedRef.$fieldName)
                    }
                }

                $generatedResolved = Resolve-ArtifactReferencePath -ArtifactPath $flowResult.TaskPacketPath -Reference $generatedRef.ref
                $expectedResolved = Resolve-ArtifactReferencePath -ArtifactPath $expectedTaskPacket -Reference $expectedRef.ref
                if ($generatedResolved -ne $expectedResolved) {
                    $failures += ("FAIL valid flow: work_object_refs[{0}] did not resolve to the expected durable target." -f $index)
                }
            }
        }

        if (@($generated.planning_record_refs).Count -ne @($expected.planning_record_refs).Count) {
            $failures += "FAIL valid flow: generated planning_record_refs count did not match the expected Task Packet."
        }
        else {
            for ($index = 0; $index -lt @($generated.planning_record_refs).Count; $index += 1) {
                $generatedRef = $generated.planning_record_refs[$index]
                $expectedRef = $expected.planning_record_refs[$index]
                foreach ($fieldName in @("relation", "planning_record_id", "object_type", "object_id", "view")) {
                    if ($generatedRef.$fieldName -ne $expectedRef.$fieldName) {
                        $failures += ("FAIL valid flow: planning_record_refs[{0}].{1} expected '{2}' but found '{3}'." -f $index, $fieldName, $expectedRef.$fieldName, $generatedRef.$fieldName)
                    }
                }

                $generatedResolved = Resolve-ArtifactReferencePath -ArtifactPath $flowResult.TaskPacketPath -Reference $generatedRef.ref
                $expectedResolved = Resolve-ArtifactReferencePath -ArtifactPath $expectedTaskPacket -Reference $expectedRef.ref
                if ($generatedResolved -ne $expectedResolved) {
                    $failures += ("FAIL valid flow: planning_record_refs[{0}] did not resolve to the expected durable planning record." -f $index)
                }
            }
        }

        $generatedLineageResolved = Resolve-ArtifactReferencePath -ArtifactPath $flowResult.TaskPacketPath -Reference $generated.lineage.source_refs[0]
        $expectedLineageResolved = Resolve-ArtifactReferencePath -ArtifactPath $expectedTaskPacket -Reference $expected.lineage.source_refs[0]
        if ($generatedLineageResolved -ne $expectedLineageResolved) {
            $failures += "FAIL valid flow: lineage.source_refs did not resolve back to the expected Request Brief."
        }

        $generatedEvidenceKinds = @($generated.evidence | ForEach-Object { $_.kind })
        $expectedEvidenceKinds = @($expected.evidence | ForEach-Object { $_.kind })
        if (($generatedEvidenceKinds -join "|") -ne ($expectedEvidenceKinds -join "|")) {
            $failures += "FAIL valid flow: evidence kinds did not match the expected Task Packet."
        }

        $validPassed += 1
    }
    finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }

    foreach ($invalidCase in $invalidCases) {
        $invalidFixtureCheck = & $testWorkArtifactContract -ArtifactPath $invalidCase
        Write-Output ("PASS contract-valid malformed input: {0} -> {1} {2}" -f (Resolve-Path -Relative $invalidCase), $invalidFixtureCheck.ArtifactType, $invalidFixtureCheck.ArtifactId)

        $invalidOutputRoot = Join-Path $env:TEMP ("aioffice-r3-005-invalid-{0}" -f ([guid]::NewGuid().ToString("N")))
        New-Item -ItemType Directory -Path $invalidOutputRoot -Force | Out-Null
        try {
            & $invokeRequestBriefToTaskPacketFlow -RequestBriefPath $invalidCase -OutputRoot $invalidOutputRoot -TaskPacketId "task-packet-invalid" -CreatedAt ([datetime]::Parse("2026-04-19T17:30:00Z").ToUniversalTime()) | Out-Null
            $failures += ("FAIL invalid flow: {0} was accepted unexpectedly." -f (Split-Path -Leaf $invalidCase))
        }
        catch {
            Write-Output ("PASS invalid flow: {0} -> {1}" -f (Split-Path -Leaf $invalidCase), $_.Exception.Message)
            $invalidRejected += 1
        }
        finally {
            if (Test-Path -LiteralPath $invalidOutputRoot) {
                Remove-Item -LiteralPath $invalidOutputRoot -Recurse -Force
            }
        }
    }
}
catch {
    $failures += $_.Exception.Message
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output $_ }
    throw ("Request Brief to Task Packet flow tests failed. Valid passed: {0}. Invalid rejected: {1}. Failures: {2}" -f $validPassed, $invalidRejected, $failures.Count)
}

Write-Output ("All Request Brief to Task Packet flow tests passed. Valid passed: {0}. Invalid rejected: {1}." -f $validPassed, $invalidRejected)
