Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$workArtifactValidationModule = Import-Module (Join-Path $PSScriptRoot "WorkArtifactValidation.psm1") -Force -PassThru
$requestBriefFlowModule = Import-Module (Join-Path $PSScriptRoot "RequestBriefTaskPacketPlanningFlow.psm1") -Force -PassThru
$qaGateModule = Import-Module (Join-Path $PSScriptRoot "ExecutionBundleQaGate.psm1") -Force -PassThru
$batonPersistenceModule = Import-Module (Join-Path $PSScriptRoot "BatonPersistence.psm1") -Force -PassThru

$testWorkArtifactContract = $workArtifactValidationModule.ExportedCommands["Test-WorkArtifactContract"]
$invokeRequestBriefToTaskPacketFlow = $requestBriefFlowModule.ExportedCommands["Invoke-RequestBriefToTaskPacketFlow"]
$invokeExecutionBundleQaGate = $qaGateModule.ExportedCommands["Invoke-ExecutionBundleQaGate"]
$newBatonFromQaOutcome = $batonPersistenceModule.ExportedCommands["New-BatonFromQaOutcome"]
$saveBatonRecord = $batonPersistenceModule.ExportedCommands["Save-BatonRecord"]
$getBatonRecord = $batonPersistenceModule.ExportedCommands["Get-BatonRecord"]

function Resolve-PathValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return $PathValue
    }

    return Join-Path (Get-Location) $PathValue
}

function Resolve-ExistingPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $resolvedPath = Resolve-PathValue -PathValue $PathValue
    if (-not (Test-Path -LiteralPath $resolvedPath)) {
        throw "$Label '$PathValue' does not exist."
    }

    return (Resolve-Path -LiteralPath $resolvedPath).Path
}

function Get-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    try {
        return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
    }
    catch {
        throw "$Label at '$Path' is not valid JSON. $($_.Exception.Message)"
    }
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

function Get-UtcTimestamp {
    param(
        [datetime]$DateTime = (Get-Date).ToUniversalTime()
    )

    return $DateTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
}

function Get-RelativeReference {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory,
        [Parameter(Mandatory = $true)]
        [string]$TargetPath
    )

    $resolvedBaseDirectory = Resolve-ExistingPath -PathValue $BaseDirectory -Label "Base directory"
    $resolvedTargetPath = Resolve-ExistingPath -PathValue $TargetPath -Label "Target path"
    $baseUri = [System.Uri]("{0}{1}" -f $resolvedBaseDirectory.TrimEnd("\/"), [System.IO.Path]::DirectorySeparatorChar)
    $targetUri = [System.Uri]$resolvedTargetPath
    return ($baseUri.MakeRelativeUri($targetUri).OriginalString).Replace("\", "/")
}

function Resolve-ArtifactReferencePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ArtifactPath,
        [Parameter(Mandatory = $true)]
        [string]$Reference,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $baseDirectory = Split-Path -Parent $ArtifactPath
    if ([System.IO.Path]::IsPathRooted($Reference)) {
        $candidate = $Reference
    }
    else {
        $candidate = Join-Path $baseDirectory ($Reference -replace "[/\\]", [System.IO.Path]::DirectorySeparatorChar)
    }

    if (-not (Test-Path -LiteralPath $candidate)) {
        throw "$Label reference '$Reference' does not exist."
    }

    return (Resolve-Path -LiteralPath $candidate).Path
}

function Get-ValidatedReplayObservationInput {
    param(
        [Parameter(Mandatory = $true)]
        [string]$QaObservationPath
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $QaObservationPath -Label "QA observation"
    $document = Get-JsonDocument -Path $resolvedPath -Label "QA observation"

    if ($document.record_type -ne "qa_gate_observation") {
        throw "QA observation.record_type must equal 'qa_gate_observation'."
    }
    if (@("fail", "block") -notcontains $document.outcome) {
        throw "R3 replay proof requires QA observation outcome 'fail' or 'block' so the baton foundation is exercised."
    }
    if ([string]::IsNullOrWhiteSpace($document.execution_bundle_id)) {
        throw "QA observation.execution_bundle_id must be a non-empty string."
    }

    return [pscustomobject]@{
        Path     = $resolvedPath
        Document = $document
    }
}

function New-ReplayExecutionBundleArtifact {
    param(
        [Parameter(Mandatory = $true)]
        $TaskPacketFlowResult,
        [Parameter(Mandatory = $true)]
        $ObservationInput,
        [Parameter(Mandatory = $true)]
        [string]$ExecutionBundleId,
        [Parameter(Mandatory = $true)]
        [datetime]$CreatedAt,
        [Parameter(Mandatory = $true)]
        [string]$CreatedById,
        [Parameter(Mandatory = $true)]
        [string]$ExecutionBundleDirectory
    )

    $taskPacket = Get-JsonDocument -Path $TaskPacketFlowResult.TaskPacketPath -Label "Task Packet"
    $createdAtText = Get-UtcTimestamp -DateTime $CreatedAt

    $workObjectRefs = foreach ($workObjectRef in @($taskPacket.work_object_refs)) {
        $resolvedTargetPath = Resolve-ArtifactReferencePath -ArtifactPath $TaskPacketFlowResult.TaskPacketPath -Reference $workObjectRef.ref -Label "Task Packet work object"
        [pscustomobject]@{
            relation    = "implements"
            object_type = $workObjectRef.object_type
            object_id   = $workObjectRef.object_id
            ref         = (Get-RelativeReference -BaseDirectory $ExecutionBundleDirectory -TargetPath $resolvedTargetPath)
            notes       = "The replay execution bundle stays bounded to the work object approved by the Task Packet."
        }
    }

    $planningRecordRefs = foreach ($planningRecordRef in @($taskPacket.planning_record_refs)) {
        $resolvedPlanningPath = Resolve-ArtifactReferencePath -ArtifactPath $TaskPacketFlowResult.TaskPacketPath -Reference $planningRecordRef.ref -Label "Task Packet planning record"
        [pscustomobject]@{
            relation           = "tracks"
            planning_record_id = $planningRecordRef.planning_record_id
            object_type        = $planningRecordRef.object_type
            object_id          = $planningRecordRef.object_id
            view               = "accepted"
            ref                = (Get-RelativeReference -BaseDirectory $ExecutionBundleDirectory -TargetPath $resolvedPlanningPath)
            notes              = "The replay execution bundle tracks the accepted planning baseline approved by the Task Packet."
        }
    }

    $executionBundle = [pscustomobject]@{
        contract_version   = "v1"
        record_type        = "governed_work_artifact"
        artifact_type      = "execution_bundle"
        artifact_id        = $ExecutionBundleId
        title              = "Replay execution bundle for $($taskPacket.title)"
        summary            = "Prepared bounded execution bundle generated inside the replay proof from the approved Task Packet."
        status             = "prepared"
        created_at         = $createdAtText
        created_by         = [pscustomobject]@{
            role = "control_kernel"
            id   = $CreatedById
        }
        lineage            = [pscustomobject]@{
            source_kind = "task_packet"
            source_refs = @(
                (Get-RelativeReference -BaseDirectory $ExecutionBundleDirectory -TargetPath $TaskPacketFlowResult.TaskPacketPath)
            )
            rationale   = "The replay execution bundle is derived directly from the approved Task Packet emitted by the bounded Request Brief flow."
        }
        pipeline           = [pscustomobject]@{
            mode                       = "admin_only_bounded"
            runtime_boundary           = "admin_only"
            standard_runtime_claimed   = $false
            subproject_runtime_claimed = $false
            orchestration_scope        = "bounded_chain_only"
            notes                      = "The replay execution bundle remains inside the admin-only bounded chain and does not imply Standard runtime."
        }
        scope              = [pscustomobject]@{
            summary            = "Replay execution bundle scope is limited to the admin-only control kernel, planning records, governed work objects, task packets, and execution bundle surfaces needed for the bounded replay proof."
            allowed_surfaces   = @("admin_runtime_only", "control_kernel", "governed_work_objects", "planning_records", "task_packets", "execution_bundles")
            protected_surfaces = @("admin_runtime_only", "control_kernel", "planning_records")
            prohibited_surfaces = @("ui_surfaces", "standard_runtime", "subproject_runtime", "automatic_resume", "rollback", "broad_orchestration")
            notes              = "The replay execution bundle exists only to prove the already-bounded internal chain."
        }
        work_object_refs   = @($workObjectRefs)
        planning_record_refs = @($planningRecordRefs)
        evidence           = @(
            [pscustomobject]@{
                kind    = "artifact"
                ref     = (Get-RelativeReference -BaseDirectory $ExecutionBundleDirectory -TargetPath $TaskPacketFlowResult.TaskPacketPath)
                summary = "The approved Task Packet defines the bounded execution intent for the replay proof."
            },
            [pscustomobject]@{
                kind    = "test_output"
                ref     = (Get-RelativeReference -BaseDirectory $ExecutionBundleDirectory -TargetPath $ObservationInput.Path)
                summary = "The committed QA observation drives the bounded QA outcome used by the replay proof."
            }
        )
        audit              = [pscustomobject]@{
            trail_refs       = @("tests/test_r3_planning_replay.ps1")
            last_reviewed_at = $createdAtText
            notes            = "Replay execution bundle generated only for the bounded R3 proof chain."
        }
        execution_summary  = "Replay the bounded R3 planning proof from request through QA and baton foundation only."
        executor_profile   = "bounded-r3-replay"
        bounded_targets    = @(
            "tools/RequestBriefTaskPacketPlanningFlow.psm1",
            "tools/ExecutionBundleQaGate.psm1",
            "tools/BatonPersistence.psm1",
            "tests/test_r3_planning_replay.ps1"
        )
        expected_outputs   = @(
            "Task Packet",
            "QA Report",
            "Remediation record",
            "External Audit Pack",
            "Baton"
        )
        prohibited_operations = @(
            "Automatic resume execution",
            "Recovery or rollback productization",
            "Broad workflow orchestration",
            "Broad UI productization"
        )
        qa_attempt_count   = 1
        qa_retry_ceiling   = 4
        qa_entry_state     = "initial_entry"
        prior_qa_report_ref = $null
        prior_baton_ref    = $null
        replay_command     = "powershell -ExecutionPolicy Bypass -File tests\\test_r3_planning_replay.ps1"
    }

    $executionBundlePath = Join-Path $ExecutionBundleDirectory ("{0}.json" -f $ExecutionBundleId)
    Write-JsonDocument -Path $executionBundlePath -Document $executionBundle
    $validation = & $testWorkArtifactContract -ArtifactPath $executionBundlePath

    return [pscustomobject]@{
        Artifact   = $executionBundle
        Path       = $executionBundlePath
        Validation = $validation
    }
}

function New-ReplaySummaryRecord {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SummaryDirectory,
        [Parameter(Mandatory = $true)]
        [string]$RequestBriefPath,
        [Parameter(Mandatory = $true)]
        [string]$QaObservationPath,
        [Parameter(Mandatory = $true)]
        [string]$TaskPacketPath,
        [Parameter(Mandatory = $true)]
        [string]$ExecutionBundlePath,
        [Parameter(Mandatory = $true)]
        [string]$QaGateResultPath,
        [Parameter(Mandatory = $true)]
        [string]$QaReportPath,
        [Parameter(Mandatory = $true)]
        [string]$RemediationRecordPath,
        [Parameter(Mandatory = $true)]
        [string]$ExternalAuditPackPath,
        [Parameter(Mandatory = $true)]
        [string]$BatonPath,
        [Parameter(Mandatory = $true)]
        [datetime]$CreatedAt
    )

    $createdAtText = Get-UtcTimestamp -DateTime $CreatedAt
    $summary = [pscustomobject]@{
        record_type                = "r3_planning_replay_summary"
        proof_id                   = "r3-bounded-planning-proof"
        created_at                 = $createdAtText
        replay_command             = "powershell -ExecutionPolicy Bypass -File tests\\test_r3_planning_replay.ps1"
        automatic_resume_added     = $false
        broad_orchestration_added  = $false
        recovery_or_rollback_added = $false
        request_brief_path         = (Get-RelativeReference -BaseDirectory $SummaryDirectory -TargetPath $RequestBriefPath)
        qa_observation_path        = (Get-RelativeReference -BaseDirectory $SummaryDirectory -TargetPath $QaObservationPath)
        generated_artifacts        = [pscustomobject]@{
            task_packet        = (Get-RelativeReference -BaseDirectory $SummaryDirectory -TargetPath $TaskPacketPath)
            execution_bundle   = (Get-RelativeReference -BaseDirectory $SummaryDirectory -TargetPath $ExecutionBundlePath)
            qa_gate_result     = (Get-RelativeReference -BaseDirectory $SummaryDirectory -TargetPath $QaGateResultPath)
            qa_report          = (Get-RelativeReference -BaseDirectory $SummaryDirectory -TargetPath $QaReportPath)
            remediation_record = (Get-RelativeReference -BaseDirectory $SummaryDirectory -TargetPath $RemediationRecordPath)
            external_audit_pack = (Get-RelativeReference -BaseDirectory $SummaryDirectory -TargetPath $ExternalAuditPackPath)
            baton              = (Get-RelativeReference -BaseDirectory $SummaryDirectory -TargetPath $BatonPath)
        }
        proof_scope                = @(
            "Request Brief input",
            "Task Packet generation",
            "Prepared Execution Bundle generation",
            "QA gate evaluation",
            "QA Report output",
            "Remediation record",
            "External Audit Pack output",
            "Baton emission, save, and reload"
        )
        guardrails                 = @(
            "No automatic resume execution",
            "No recovery or rollback productization",
            "No broad workflow orchestration",
            "No broad UI or runtime productization"
        )
    }

    $summaryPath = Join-Path $SummaryDirectory "r3-planning-replay-summary.json"
    Write-JsonDocument -Path $summaryPath -Document $summary
    return $summaryPath
}

function Invoke-R3PlanningReplayProof {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RequestBriefPath,
        [Parameter(Mandatory = $true)]
        [string]$QaObservationPath,
        [Parameter(Mandatory = $true)]
        [string]$OutputRoot,
        [string]$TaskPacketId,
        [string]$ExecutionBundleId,
        [string]$BatonId,
        [datetime]$CreatedAt = (Get-Date).ToUniversalTime(),
        [string]$CreatedById = "control-kernel:r3-replay"
    )

    $observationInput = Get-ValidatedReplayObservationInput -QaObservationPath $QaObservationPath

    if ([string]::IsNullOrWhiteSpace($ExecutionBundleId)) {
        $ExecutionBundleId = $observationInput.Document.execution_bundle_id
    }

    $resolvedOutputRoot = Resolve-PathValue -PathValue $OutputRoot
    if (-not (Test-Path -LiteralPath $resolvedOutputRoot)) {
        New-Item -ItemType Directory -Path $resolvedOutputRoot -Force | Out-Null
    }

    $planningOutputRoot = Join-Path $resolvedOutputRoot "planning_flow"
    $executionBundleDirectory = Join-Path $resolvedOutputRoot "execution_bundles"
    $qaGateOutputRoot = Join-Path $resolvedOutputRoot "qa_gate"
    $batonStorePath = Join-Path $resolvedOutputRoot "baton_store"
    $proofRecordsDirectory = Join-Path $resolvedOutputRoot "proof_records"

    foreach ($directory in @($planningOutputRoot, $executionBundleDirectory, $qaGateOutputRoot, $proofRecordsDirectory)) {
        if (-not (Test-Path -LiteralPath $directory)) {
            New-Item -ItemType Directory -Path $directory -Force | Out-Null
        }
    }

    $taskPacketFlowResult = & $invokeRequestBriefToTaskPacketFlow -RequestBriefPath $RequestBriefPath -OutputRoot $planningOutputRoot -TaskPacketId $TaskPacketId -CreatedAt $CreatedAt -CreatedById "control-kernel:planner"
    $executionBundleOutput = New-ReplayExecutionBundleArtifact -TaskPacketFlowResult $taskPacketFlowResult -ObservationInput $observationInput -ExecutionBundleId $ExecutionBundleId -CreatedAt $CreatedAt -CreatedById $CreatedById -ExecutionBundleDirectory $executionBundleDirectory
    $qaGateOutput = & $invokeExecutionBundleQaGate -ExecutionBundlePath $executionBundleOutput.Path -OutputRoot $qaGateOutputRoot -CreatedAt $CreatedAt -CreatedById "control-kernel:qa-gate"
    $batonEmission = & $newBatonFromQaOutcome -QaReportPath $qaGateOutput.QaReportPath -ExternalAuditPackPath $qaGateOutput.ExternalAuditPackPath -RemediationRecordPath $qaGateOutput.RemediationRecordPath -BatonId $BatonId -CreatedAt $CreatedAt -CreatedById "control-kernel:baton"
    $savedBatonPath = & $saveBatonRecord -Baton $batonEmission.Baton -StorePath $batonStorePath
    $loadedBaton = & $getBatonRecord -BatonId $batonEmission.Baton.artifact_id -StorePath $batonStorePath
    $replaySummaryPath = New-ReplaySummaryRecord -SummaryDirectory $proofRecordsDirectory -RequestBriefPath $taskPacketFlowResult.RequestBriefPath -QaObservationPath $observationInput.Path -TaskPacketPath $taskPacketFlowResult.TaskPacketPath -ExecutionBundlePath $executionBundleOutput.Path -QaGateResultPath $qaGateOutput.QaGateResultPath -QaReportPath $qaGateOutput.QaReportPath -RemediationRecordPath $qaGateOutput.RemediationRecordPath -ExternalAuditPackPath $qaGateOutput.ExternalAuditPackPath -BatonPath $savedBatonPath -CreatedAt $CreatedAt

    return [pscustomobject]@{
        RequestBriefPath      = $taskPacketFlowResult.RequestBriefPath
        TaskPacketPath        = $taskPacketFlowResult.TaskPacketPath
        ExecutionBundlePath   = $executionBundleOutput.Path
        QaGateResultPath      = $qaGateOutput.QaGateResultPath
        QaReportPath          = $qaGateOutput.QaReportPath
        RemediationRecordPath = $qaGateOutput.RemediationRecordPath
        ExternalAuditPackPath = $qaGateOutput.ExternalAuditPackPath
        BatonPath             = $savedBatonPath
        BatonReloaded         = $loadedBaton.Baton
        ReplaySummaryPath     = $replaySummaryPath
    }
}

Export-ModuleMember -Function Invoke-R3PlanningReplayProof
