Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$workArtifactValidationModule = Import-Module (Join-Path $PSScriptRoot "WorkArtifactValidation.psm1") -Force -PassThru
$planningRecordStorageModule = Import-Module (Join-Path $PSScriptRoot "PlanningRecordStorage.psm1") -Force -PassThru
$testWorkArtifactContract = $workArtifactValidationModule.ExportedCommands["Test-WorkArtifactContract"]
$testPlanningRecordContract = $planningRecordStorageModule.ExportedCommands["Test-PlanningRecordContract"]

function Get-RepositoryRoot {
    return $repoRoot
}

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

function Test-HasProperty {
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    return $null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name
}

function Get-RequiredProperty {
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if (-not (Test-HasProperty -Object $Object -Name $Name)) {
        throw "$Context is missing required field '$Name'."
    }

    Write-Output -NoEnumerate ($Object.$Name)
}

function Assert-NonEmptyString {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -isnot [string] -or [string]::IsNullOrWhiteSpace($Value)) {
        throw "$Context must be a non-empty string."
    }

    return $Value
}

function Assert-NullableString {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($null -eq $Value) {
        return $null
    }

    return (Assert-NonEmptyString -Value $Value -Context $Context)
}

function Assert-BooleanValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -isnot [bool]) {
        throw "$Context must be a boolean."
    }

    return $Value
}

function Assert-IntegerValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -is [int]) {
        return $Value
    }

    if ($Value -is [long] -and $Value -ge [int]::MinValue -and $Value -le [int]::MaxValue) {
        return [int]$Value
    }

    throw "$Context must be an integer."
}

function Assert-ObjectValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($null -eq $Value -or $Value -is [string] -or $Value -is [System.Array]) {
        throw "$Context must be an object."
    }

    return $Value
}

function Assert-ObjectArray {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [switch]$AllowEmpty
    )

    if ($null -eq $Value -or $Value -is [string] -or -not ($Value -is [System.Collections.IEnumerable])) {
        throw "$Context must be an array."
    }

    $items = @($Value)
    if (-not $AllowEmpty -and $items.Count -eq 0) {
        throw "$Context must not be empty."
    }

    foreach ($item in $items) {
        Assert-ObjectValue -Value $item -Context "$Context item" | Out-Null
    }

    Write-Output -NoEnumerate $items
}

function Assert-StringArray {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [switch]$AllowEmpty
    )

    if ($null -eq $Value -or $Value -is [string] -or -not ($Value -is [System.Collections.IEnumerable])) {
        throw "$Context must be an array."
    }

    $items = @($Value)
    if (-not $AllowEmpty -and $items.Count -eq 0) {
        throw "$Context must not be empty."
    }

    foreach ($item in $items) {
        Assert-NonEmptyString -Value $item -Context "$Context item" | Out-Null
    }

    Write-Output -NoEnumerate $items
}

function Assert-AllowedValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string[]]$AllowedValues,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($AllowedValues -notcontains $Value) {
        throw "$Context must be one of: $($AllowedValues -join ', ')."
    }
}

function Get-UtcTimestamp {
    param(
        [datetime]$DateTime = (Get-Date).ToUniversalTime()
    )

    return $DateTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
}

function Resolve-ReferenceAgainstBase {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaseDirectory,
        [Parameter(Mandatory = $true)]
        [string]$Reference,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    if ([System.IO.Path]::IsPathRooted($Reference)) {
        $candidate = $Reference
    }
    else {
        $candidate = Join-Path $BaseDirectory ($Reference -replace "[/\\]", [System.IO.Path]::DirectorySeparatorChar)
    }

    if (-not (Test-Path -LiteralPath $candidate)) {
        throw "$Label reference '$Reference' does not exist."
    }

    return (Resolve-Path -LiteralPath $candidate).Path
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

function Get-ComparisonPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue
    )

    $fullPath = [System.IO.Path]::GetFullPath($PathValue)
    if (Test-Path -LiteralPath $fullPath) {
        $fullPath = (Resolve-Path -LiteralPath $fullPath).Path
    }

    return ($fullPath.Replace("/", "\").TrimEnd("\")).ToLowerInvariant()
}

function New-UniqueStringList {
    Write-Output -NoEnumerate ([System.Collections.Generic.List[string]]::new())
}

function Add-UniqueString {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.Generic.List[string]]$List,
        [AllowNull()]
        [string]$Value
    )

    if (-not [string]::IsNullOrWhiteSpace($Value) -and -not $List.Contains($Value)) {
        $List.Add($Value) | Out-Null
    }
}

function Get-PlanningRecordViewPath {
    param(
        [Parameter(Mandatory = $true)]
        $PlanningRecordDocument,
        [Parameter(Mandatory = $true)]
        [string]$PlanningRecordPath,
        [Parameter(Mandatory = $true)]
        [string]$View
    )

    $planningRecordDirectory = Split-Path -Parent $PlanningRecordPath
    switch ($View) {
        "accepted" {
            $recordRef = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $PlanningRecordDocument.accepted_state -Name "record_ref" -Context "PlanningRecord.accepted_state") -Context "PlanningRecord.accepted_state.record_ref"
            return (Resolve-ReferenceAgainstBase -BaseDirectory $planningRecordDirectory -Reference $recordRef -Label "Accepted planning record")
        }
        "working" {
            $recordRef = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $PlanningRecordDocument.working_state -Name "record_ref" -Context "PlanningRecord.working_state") -Context "PlanningRecord.working_state.record_ref"
            return (Resolve-ReferenceAgainstBase -BaseDirectory $planningRecordDirectory -Reference $recordRef -Label "Working planning record")
        }
        default {
            throw "Unsupported planning record view '$View'."
        }
    }
}

function Get-ValidatedExecutionBundleInput {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ExecutionBundlePath
    )

    $artifactCheck = & $testWorkArtifactContract -ArtifactPath $ExecutionBundlePath
    if ($artifactCheck.ArtifactType -ne "execution_bundle") {
        throw "QA gate requires an Execution Bundle artifact, but '$ExecutionBundlePath' resolved to artifact type '$($artifactCheck.ArtifactType)'."
    }

    $executionBundle = Get-JsonDocument -Path $artifactCheck.ArtifactPath -Label "Execution Bundle"
    if ($executionBundle.status -ne "prepared") {
        throw "Execution Bundle '$($executionBundle.artifact_id)' must be in status 'prepared' before QA gate evaluation."
    }

    return [pscustomobject]@{
        Validation = $artifactCheck
        Document   = $executionBundle
        Directory  = (Split-Path -Parent $artifactCheck.ArtifactPath)
    }
}

function Get-ValidatedExecutionBundleTaskPacket {
    param(
        [Parameter(Mandatory = $true)]
        $ExecutionBundleInput
    )

    $sourceRefs = [string[]](Assert-StringArray -Value (Get-RequiredProperty -Object $ExecutionBundleInput.Document.lineage -Name "source_refs" -Context "Execution Bundle.lineage") -Context "Execution Bundle.lineage.source_refs")
    if ($sourceRefs.Count -ne 1) {
        throw "Execution Bundle '$($ExecutionBundleInput.Document.artifact_id)' must include exactly one lineage source ref for the bounded QA gate."
    }

    $resolvedTaskPacketPath = Resolve-ReferenceAgainstBase -BaseDirectory $ExecutionBundleInput.Directory -Reference $sourceRefs[0] -Label "Execution Bundle lineage"
    $taskPacketValidation = & $testWorkArtifactContract -ArtifactPath $resolvedTaskPacketPath
    if ($taskPacketValidation.ArtifactType -ne "task_packet") {
        throw "Execution Bundle lineage must resolve to a Task Packet artifact."
    }

    $taskPacket = Get-JsonDocument -Path $taskPacketValidation.ArtifactPath -Label "Task Packet"
    if ($taskPacket.status -ne "approved") {
        throw "Execution Bundle '$($ExecutionBundleInput.Document.artifact_id)' must derive from an approved Task Packet."
    }

    $artifactEvidenceMatched = $false
    foreach ($evidenceItem in @($ExecutionBundleInput.Document.evidence)) {
        if ($evidenceItem.kind -ne "artifact") {
            continue
        }

        $artifactEvidencePath = Resolve-ReferenceAgainstBase -BaseDirectory $ExecutionBundleInput.Directory -Reference $evidenceItem.ref -Label "Execution Bundle artifact evidence"
        if ((Get-ComparisonPath -PathValue $artifactEvidencePath) -eq (Get-ComparisonPath -PathValue $taskPacketValidation.ArtifactPath)) {
            $artifactEvidenceMatched = $true
            break
        }
    }

    if (-not $artifactEvidenceMatched) {
        throw "Execution Bundle '$($ExecutionBundleInput.Document.artifact_id)' must include artifact evidence that resolves to its Task Packet lineage source."
    }

    return [pscustomobject]@{
        Validation = $taskPacketValidation
        Document   = $taskPacket
        Path       = $taskPacketValidation.ArtifactPath
    }
}

function Get-ValidatedQaWorkObjectRefs {
    param(
        [Parameter(Mandatory = $true)]
        $ExecutionBundleInput
    )

    $validatedRefs = [System.Collections.ArrayList]::new()

    foreach ($workObjectRef in [object[]](Assert-ObjectArray -Value (Get-RequiredProperty -Object $ExecutionBundleInput.Document -Name "work_object_refs" -Context "Execution Bundle") -Context "Execution Bundle.work_object_refs")) {
        $resolvedPath = Resolve-ReferenceAgainstBase -BaseDirectory $ExecutionBundleInput.Directory -Reference $workObjectRef.ref -Label "Execution Bundle work object"
        [void]$validatedRefs.Add([pscustomobject]@{
            Relation       = $workObjectRef.relation
            ObjectType     = $workObjectRef.object_type
            ObjectId       = $workObjectRef.object_id
            ResolvedPath   = $resolvedPath
            ComparisonPath = Get-ComparisonPath -PathValue $resolvedPath
        })
    }

    if ($validatedRefs.Count -eq 0) {
        throw "Execution Bundle '$($ExecutionBundleInput.Document.artifact_id)' must reference at least one work object for QA evaluation."
    }

    return $validatedRefs
}

function Get-ValidatedQaPlanningRefs {
    param(
        [Parameter(Mandatory = $true)]
        $ExecutionBundleInput,
        [Parameter(Mandatory = $true)]
        $WorkObjectRefs
    )

    $validatedRefs = [System.Collections.ArrayList]::new()

    foreach ($planningRecordRef in [object[]](Assert-ObjectArray -Value (Get-RequiredProperty -Object $ExecutionBundleInput.Document -Name "planning_record_refs" -Context "Execution Bundle") -Context "Execution Bundle.planning_record_refs")) {
        $resolvedPlanningRecordPath = Resolve-ReferenceAgainstBase -BaseDirectory $ExecutionBundleInput.Directory -Reference $planningRecordRef.ref -Label "Execution Bundle planning record"
        $planningRecordValidation = & $testPlanningRecordContract -PlanningRecordPath $resolvedPlanningRecordPath
        $planningRecord = Get-JsonDocument -Path $planningRecordValidation.PlanningRecordPath -Label "Planning record"
        $selectedViewPath = Get-PlanningRecordViewPath -PlanningRecordDocument $planningRecord -PlanningRecordPath $planningRecordValidation.PlanningRecordPath -View $planningRecordRef.view

        if ($planningRecord.accepted_state.status -ne "accepted") {
            throw "Planning record '$($planningRecordValidation.PlanningRecordId)' must expose an accepted surface before QA gate audit-pack assembly."
        }
        if ($planningRecordRef.view -ne "accepted") {
            throw "Execution Bundle '$($ExecutionBundleInput.Document.artifact_id)' must hand off accepted planning_record_refs only before QA gate evaluation."
        }

        $acceptedViewPath = Get-PlanningRecordViewPath -PlanningRecordDocument $planningRecord -PlanningRecordPath $planningRecordValidation.PlanningRecordPath -View "accepted"

        $matchingWorkObject = @($WorkObjectRefs | Where-Object {
                $_.ObjectType -eq $planningRecordValidation.ObjectType -and
                $_.ObjectId -eq $planningRecordValidation.ObjectId -and
                $_.ComparisonPath -eq (Get-ComparisonPath -PathValue $selectedViewPath)
            })

        if ($matchingWorkObject.Count -eq 0) {
            throw "Planning record '$($planningRecordValidation.PlanningRecordId)' must align to the selected work object ref for view '$($planningRecordRef.view)'."
        }

        [void]$validatedRefs.Add([pscustomobject]@{
            Relation             = $planningRecordRef.relation
            PlanningRecordId     = $planningRecordValidation.PlanningRecordId
            ObjectType           = $planningRecordValidation.ObjectType
            ObjectId             = $planningRecordValidation.ObjectId
            View                 = $planningRecordRef.view
            PlanningRecordPath   = $planningRecordValidation.PlanningRecordPath
            SelectedViewPath     = $selectedViewPath
            AcceptedViewPath     = $acceptedViewPath
            MatchingWorkObject   = $matchingWorkObject[0]
        })
    }

    if ($validatedRefs.Count -eq 0) {
        throw "Execution Bundle '$($ExecutionBundleInput.Document.artifact_id)' must include at least one planning record ref for QA evaluation."
    }

    foreach ($workObjectRef in @($WorkObjectRefs)) {
        $matchedPlanningRef = @($validatedRefs | Where-Object { $_.MatchingWorkObject.ComparisonPath -eq $workObjectRef.ComparisonPath })
        if ($matchedPlanningRef.Count -eq 0) {
            throw "Execution Bundle work object '$($workObjectRef.ObjectId)' is not grounded in a planning record ref for the QA gate."
        }
    }

    return $validatedRefs
}

function Get-ValidatedQaLoopContext {
    param(
        [Parameter(Mandatory = $true)]
        $ExecutionBundleInput
    )

    $document = $ExecutionBundleInput.Document
    $qaAttemptCount = Assert-IntegerValue -Value (Get-RequiredProperty -Object $document -Name "qa_attempt_count" -Context "Execution Bundle") -Context "Execution Bundle.qa_attempt_count"
    $qaRetryCeiling = Assert-IntegerValue -Value (Get-RequiredProperty -Object $document -Name "qa_retry_ceiling" -Context "Execution Bundle") -Context "Execution Bundle.qa_retry_ceiling"
    if ($qaRetryCeiling -ne 4) {
        throw "Execution Bundle '$($document.artifact_id)' must use qa_retry_ceiling 4 for the bounded QA loop."
    }
    if ($qaAttemptCount -lt 1 -or $qaAttemptCount -gt $qaRetryCeiling) {
        throw "Execution Bundle '$($document.artifact_id)' must keep qa_attempt_count within the bounded retry ceiling."
    }

    $qaEntryState = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $document -Name "qa_entry_state" -Context "Execution Bundle") -Context "Execution Bundle.qa_entry_state"
    if (@("initial_entry", "retry_entry") -notcontains $qaEntryState) {
        throw "Execution Bundle.qa_entry_state must be 'initial_entry' or 'retry_entry'."
    }

    $priorQaReportRef = if (Test-HasProperty -Object $document -Name "prior_qa_report_ref") { Assert-NullableString -Value $document.prior_qa_report_ref -Context "Execution Bundle.prior_qa_report_ref" } else { $null }
    $priorBatonRef = if (Test-HasProperty -Object $document -Name "prior_baton_ref") { Assert-NullableString -Value $document.prior_baton_ref -Context "Execution Bundle.prior_baton_ref" } else { $null }

    if ($qaEntryState -eq "initial_entry") {
        if ($qaAttemptCount -ne 1) {
            throw "Initial-entry Execution Bundles must start at qa_attempt_count 1."
        }
        if ($null -ne $priorQaReportRef -or $null -ne $priorBatonRef) {
            throw "Initial-entry Execution Bundles must not carry prior QA or Baton refs."
        }
    }

    if ($qaEntryState -eq "retry_entry") {
        if ($qaAttemptCount -le 1) {
            throw "Retry-entry Execution Bundles must use qa_attempt_count greater than 1."
        }
        if ($null -eq $priorQaReportRef -or $null -eq $priorBatonRef) {
            throw "Retry-entry Execution Bundles must carry prior QA and Baton refs."
        }

        $resolvedQaReportPath = Resolve-ReferenceAgainstBase -BaseDirectory $ExecutionBundleInput.Directory -Reference $priorQaReportRef -Label "Execution Bundle prior QA Report"
        $qaValidation = & $testWorkArtifactContract -ArtifactPath $resolvedQaReportPath
        if ($qaValidation.ArtifactType -ne "qa_report") {
            throw "Execution Bundle.prior_qa_report_ref must resolve to a qa_report artifact."
        }

        $priorQaReport = Get-JsonDocument -Path $qaValidation.ArtifactPath -Label "Execution Bundle prior QA Report"
        if (@("failed", "blocked") -notcontains $priorQaReport.status) {
            throw "Retry-entry Execution Bundles must derive from a failed or blocked QA Report."
        }
        if ([int]$priorQaReport.qa_attempt_count -ne ($qaAttemptCount - 1)) {
            throw "Retry-entry Execution Bundles must advance exactly one attempt beyond the prior QA Report."
        }

        $resolvedBatonPath = Resolve-ReferenceAgainstBase -BaseDirectory $ExecutionBundleInput.Directory -Reference $priorBatonRef -Label "Execution Bundle prior Baton"
        $batonValidation = & $testWorkArtifactContract -ArtifactPath $resolvedBatonPath
        if ($batonValidation.ArtifactType -ne "baton") {
            throw "Execution Bundle.prior_baton_ref must resolve to a baton artifact."
        }

        $priorBaton = Get-JsonDocument -Path $batonValidation.ArtifactPath -Label "Execution Bundle prior Baton"
        if ($priorBaton.status -ne "ready_for_handoff") {
            throw "Retry-entry Execution Bundles must derive from a ready_for_handoff baton."
        }
        if ($priorBaton.handoff_state -ne "follow_up") {
            throw "Retry-entry Execution Bundles must derive from a follow_up baton, not a manual-review stop state."
        }
        if ([int]$priorBaton.qa_attempt_count -ne ($qaAttemptCount - 1)) {
            throw "Retry-entry Execution Bundles must advance exactly one attempt beyond the prior Baton handoff."
        }
    }

    return [pscustomobject]@{
        AttemptCount  = $qaAttemptCount
        RetryCeiling  = $qaRetryCeiling
        EntryState    = $qaEntryState
        PriorQaReport = $priorQaReportRef
        PriorBaton    = $priorBatonRef
    }
}

function Get-ValidatedQaObservation {
    param(
        [Parameter(Mandatory = $true)]
        $ExecutionBundleInput
    )

    $testOutputEvidence = @($ExecutionBundleInput.Document.evidence | Where-Object { $_.kind -eq "test_output" })
    if ($testOutputEvidence.Count -eq 0) {
        throw "Execution Bundle '$($ExecutionBundleInput.Document.artifact_id)' must include at least one test_output evidence item before QA gate evaluation."
    }
    if ($testOutputEvidence.Count -ne 1) {
        throw "Execution Bundle '$($ExecutionBundleInput.Document.artifact_id)' must include exactly one bounded test_output evidence item for the QA gate."
    }

    $observationPath = Resolve-ReferenceAgainstBase -BaseDirectory $ExecutionBundleInput.Directory -Reference $testOutputEvidence[0].ref -Label "Execution Bundle test output evidence"
    $observation = Get-JsonDocument -Path $observationPath -Label "QA gate observation"

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $observation -Name "record_type" -Context "QA observation") -Context "QA observation.record_type"
    if ($recordType -ne "qa_gate_observation") {
        throw "QA observation.record_type must equal 'qa_gate_observation'."
    }

    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $observation -Name "observation_id" -Context "QA observation") -Context "QA observation.observation_id" | Out-Null
    $executionBundleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $observation -Name "execution_bundle_id" -Context "QA observation") -Context "QA observation.execution_bundle_id"
    if ($executionBundleId -ne $ExecutionBundleInput.Document.artifact_id) {
        throw "QA observation.execution_bundle_id must match the evaluated Execution Bundle."
    }

    $outcome = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $observation -Name "outcome" -Context "QA observation") -Context "QA observation.outcome"
    Assert-AllowedValue -Value $outcome -AllowedValues @("pass", "fail", "block") -Context "QA observation.outcome"
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $observation -Name "summary" -Context "QA observation") -Context "QA observation.summary" | Out-Null
    $checksRun = [string[]](Assert-StringArray -Value (Get-RequiredProperty -Object $observation -Name "checks_run" -Context "QA observation") -Context "QA observation.checks_run")
    $findings = [string[]](Assert-StringArray -Value (Get-RequiredProperty -Object $observation -Name "findings" -Context "QA observation") -Context "QA observation.findings")
    $remediationRequired = Assert-BooleanValue -Value (Get-RequiredProperty -Object $observation -Name "remediation_required" -Context "QA observation") -Context "QA observation.remediation_required"
    $remediationActions = [string[]](Assert-StringArray -Value (Get-RequiredProperty -Object $observation -Name "remediation_actions" -Context "QA observation") -Context "QA observation.remediation_actions" -AllowEmpty)
    $blockingReasons = [string[]](Assert-StringArray -Value (Get-RequiredProperty -Object $observation -Name "blocking_reasons" -Context "QA observation") -Context "QA observation.blocking_reasons" -AllowEmpty)
    $auditQuestions = [string[]](Assert-StringArray -Value (Get-RequiredProperty -Object $observation -Name "audit_questions" -Context "QA observation") -Context "QA observation.audit_questions")
    $reviewerNotes = if (Test-HasProperty -Object $observation -Name "reviewer_notes") { Assert-NullableString -Value $observation.reviewer_notes -Context "QA observation.reviewer_notes" } else { $null }

    switch ($outcome) {
        "pass" {
            if ($remediationRequired) {
                throw "QA observation outcome 'pass' must set remediation_required to false."
            }
            if ($remediationActions.Count -ne 0) {
                throw "QA observation outcome 'pass' must not include remediation_actions."
            }
            if ($blockingReasons.Count -ne 0) {
                throw "QA observation outcome 'pass' must not include blocking_reasons."
            }
        }
        "fail" {
            if (-not $remediationRequired) {
                throw "QA observation outcome 'fail' must set remediation_required to true."
            }
            if ($remediationActions.Count -eq 0) {
                throw "QA observation outcome 'fail' must include at least one remediation_action."
            }
            if ($blockingReasons.Count -ne 0) {
                throw "QA observation outcome 'fail' must not include blocking_reasons."
            }
        }
        "block" {
            if (-not $remediationRequired) {
                throw "QA observation outcome 'block' must set remediation_required to true."
            }
            if ($remediationActions.Count -eq 0) {
                throw "QA observation outcome 'block' must include at least one remediation_action."
            }
            if ($blockingReasons.Count -eq 0) {
                throw "QA observation outcome 'block' must include at least one blocking_reason."
            }
        }
    }

    return [pscustomobject]@{
        Path                = $observationPath
        Document            = $observation
        Outcome             = $outcome
        ChecksRun           = $checksRun
        Findings            = $findings
        RemediationRequired = $remediationRequired
        RemediationActions  = $remediationActions
        BlockingReasons     = $blockingReasons
        AuditQuestions      = $auditQuestions
        ReviewerNotes       = $reviewerNotes
    }
}

function Get-QaVerdictValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Outcome
    )

    switch ($Outcome) {
        "pass" { return "pass" }
        "fail" { return "fail" }
        "block" { return "blocked" }
        default { throw "Unsupported QA outcome '$Outcome'." }
    }
}

function Get-QaStatusValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Outcome,
        [Parameter(Mandatory = $true)]
        $LoopContext
    )

    if ($Outcome -ne "pass" -and $LoopContext.AttemptCount -ge $LoopContext.RetryCeiling) {
        return "retry_exhausted"
    }

    switch ($Outcome) {
        "pass" { return "passed" }
        "fail" { return "failed" }
        "block" { return "blocked" }
        default { throw "Unsupported QA outcome '$Outcome'." }
    }
}

function Get-RemediationStatusValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Outcome,
        [Parameter(Mandatory = $true)]
        $LoopContext
    )

    if ($Outcome -ne "pass" -and $LoopContext.AttemptCount -ge $LoopContext.RetryCeiling) {
        return "retry_exhausted"
    }

    switch ($Outcome) {
        "pass" { return "none" }
        "fail" { return "required" }
        "block" { return "blocked" }
        default { throw "Unsupported QA outcome '$Outcome'." }
    }
}

function Get-QaLoopStateValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Outcome,
        [Parameter(Mandatory = $true)]
        $LoopContext
    )

    if ($Outcome -eq "pass") {
        return "closed"
    }

    if ($LoopContext.AttemptCount -ge $LoopContext.RetryCeiling) {
        return "retry_exhausted"
    }

    switch ($Outcome) {
        "fail" { return "retry_required" }
        "block" { return "blocked" }
        default { throw "Unsupported QA outcome '$Outcome'." }
    }
}

function Get-NextHandoffValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Outcome,
        [Parameter(Mandatory = $true)]
        $LoopContext
    )

    if ($Outcome -eq "pass") {
        return "none"
    }

    if ($LoopContext.AttemptCount -ge $LoopContext.RetryCeiling) {
        return "manual_review"
    }

    return "baton_follow_up"
}

function Initialize-QaGateResultRecord {
    param(
        [Parameter(Mandatory = $true)]
        $ExecutionBundleInput,
        [Parameter(Mandatory = $true)]
        $TaskPacketInput,
        [Parameter(Mandatory = $true)]
        $WorkObjectRefs,
        [Parameter(Mandatory = $true)]
        $PlanningRefs,
        [Parameter(Mandatory = $true)]
        $Observation,
        [Parameter(Mandatory = $true)]
        $LoopContext,
        [Parameter(Mandatory = $true)]
        [datetime]$CreatedAt
    )

    return [pscustomobject]@{
        record_type            = "qa_gate_result"
        gate_id                = "qa-gate-{0}" -f $ExecutionBundleInput.Document.artifact_id
        execution_bundle_id    = $ExecutionBundleInput.Document.artifact_id
        task_packet_id         = $TaskPacketInput.Document.artifact_id
        outcome                = $Observation.Outcome
        summary                = $Observation.Document.summary
        observed_at            = Get-UtcTimestamp -DateTime $CreatedAt
        observation_ref        = $null
        qa_attempt_count       = $LoopContext.AttemptCount
        qa_retry_ceiling       = $LoopContext.RetryCeiling
        qa_loop_state          = Get-QaLoopStateValue -Outcome $Observation.Outcome -LoopContext $LoopContext
        next_handoff           = Get-NextHandoffValue -Outcome $Observation.Outcome -LoopContext $LoopContext
        validated_work_objects = @($WorkObjectRefs | ForEach-Object { "{0}:{1}" -f $_.ObjectType, $_.ObjectId })
        validated_planning_records = @($PlanningRefs | ForEach-Object { $_.PlanningRecordId })
        remediation_required   = $Observation.RemediationRequired
        remediation_status     = Get-RemediationStatusValue -Outcome $Observation.Outcome -LoopContext $LoopContext
        generated_artifacts    = [pscustomobject]@{
            qa_report           = $null
            remediation_record  = $null
            external_audit_pack = $null
        }
    }
}

function New-RemediationRecord {
    param(
        [Parameter(Mandatory = $true)]
        $ExecutionBundleInput,
        [Parameter(Mandatory = $true)]
        $Observation,
        [Parameter(Mandatory = $true)]
        $LoopContext,
        [Parameter(Mandatory = $true)]
        [string]$QaReportId,
        [Parameter(Mandatory = $true)]
        [string]$ExecutionBundlePath,
        [Parameter(Mandatory = $true)]
        [string]$RemediationDirectory,
        [Parameter(Mandatory = $true)]
        [datetime]$CreatedAt
    )

    $record = [pscustomobject]@{
        record_type          = "qa_gate_remediation_record"
        remediation_id       = "remediation-{0}" -f $ExecutionBundleInput.Document.artifact_id
        execution_bundle_id  = $ExecutionBundleInput.Document.artifact_id
        qa_report_id         = $QaReportId
        status               = Get-RemediationStatusValue -Outcome $Observation.Outcome -LoopContext $LoopContext
        qa_attempt_count     = $LoopContext.AttemptCount
        qa_retry_ceiling     = $LoopContext.RetryCeiling
        qa_loop_state        = Get-QaLoopStateValue -Outcome $Observation.Outcome -LoopContext $LoopContext
        next_handoff         = Get-NextHandoffValue -Outcome $Observation.Outcome -LoopContext $LoopContext
        remediation_required = $Observation.RemediationRequired
        actions              = @($Observation.RemediationActions)
        blocking_reasons     = @($Observation.BlockingReasons)
        notes                = switch ($Observation.Outcome) {
            "pass" { "No remediation is required for this QA outcome." }
            "fail" {
                if ($LoopContext.AttemptCount -ge $LoopContext.RetryCeiling) {
                    "The bounded QA retry ceiling has been reached; further retries must stop and return for manual review."
                }
                else {
                    "Remediation is required before the bounded QA slice can be reconsidered."
                }
            }
            "block" {
                if ($LoopContext.AttemptCount -ge $LoopContext.RetryCeiling) {
                    "The bounded QA retry ceiling has been reached while blocked; further retries must stop and return for manual review."
                }
                else {
                    "The QA slice is blocked until the listed blockers are resolved."
                }
            }
        }
        created_at           = Get-UtcTimestamp -DateTime $CreatedAt
        updated_at           = Get-UtcTimestamp -DateTime $CreatedAt
        source_artifacts     = @(
            (Get-RelativeReference -BaseDirectory $RemediationDirectory -TargetPath $ExecutionBundlePath)
        )
    }

    $path = Join-Path $RemediationDirectory ("{0}.json" -f $record.remediation_id)
    Write-JsonDocument -Path $path -Document $record
    return [pscustomobject]@{
        Record = $record
        Path   = $path
    }
}

function New-QaReportArtifact {
    param(
        [Parameter(Mandatory = $true)]
        $ExecutionBundleInput,
        [Parameter(Mandatory = $true)]
        $WorkObjectRefs,
        [Parameter(Mandatory = $true)]
        $PlanningRefs,
        [Parameter(Mandatory = $true)]
        $Observation,
        [Parameter(Mandatory = $true)]
        $LoopContext,
        [Parameter(Mandatory = $true)]
        [string]$QaGateResultPath,
        [Parameter(Mandatory = $true)]
        [string]$RemediationRecordPath,
        [Parameter(Mandatory = $true)]
        [string]$QaReportDirectory,
        [Parameter(Mandatory = $true)]
        [datetime]$CreatedAt,
        [Parameter(Mandatory = $true)]
        [string]$CreatedById
    )

    $artifactId = "qa-report-{0}" -f $ExecutionBundleInput.Document.artifact_id
    $createdAtText = Get-UtcTimestamp -DateTime $CreatedAt
    $qaStatus = Get-QaStatusValue -Outcome $Observation.Outcome -LoopContext $LoopContext
    $qaVerdict = Get-QaVerdictValue -Outcome $Observation.Outcome
    $qaLoopState = Get-QaLoopStateValue -Outcome $Observation.Outcome -LoopContext $LoopContext
    $nextHandoff = Get-NextHandoffValue -Outcome $Observation.Outcome -LoopContext $LoopContext

    $workObjectRefs = foreach ($workObjectRef in @($WorkObjectRefs)) {
        [pscustomobject]@{
            relation    = "verifies"
            object_type = $workObjectRef.ObjectType
            object_id   = $workObjectRef.ObjectId
            ref         = (Get-RelativeReference -BaseDirectory $QaReportDirectory -TargetPath $workObjectRef.ResolvedPath)
            notes       = "The QA gate verifies the bounded work object referenced by the prepared Execution Bundle."
        }
    }

    $planningRecordRefs = foreach ($planningRef in @($PlanningRefs)) {
        [pscustomobject]@{
            relation           = "tracks"
            planning_record_id = $planningRef.PlanningRecordId
            object_type        = $planningRef.ObjectType
            object_id          = $planningRef.ObjectId
            view               = $planningRef.View
            ref                = (Get-RelativeReference -BaseDirectory $QaReportDirectory -TargetPath $planningRef.PlanningRecordPath)
            notes              = "The QA report tracks the planning record view used by the bounded Execution Bundle."
        }
    }

    $qaReport = [pscustomobject]@{
        contract_version   = "v1"
        record_type        = "governed_work_artifact"
        artifact_type      = "qa_report"
        artifact_id        = $artifactId
        title              = "QA report for $($ExecutionBundleInput.Document.title)"
        summary            = "Bounded QA gate outcome for Execution Bundle '$($ExecutionBundleInput.Document.artifact_id)'."
        status             = $qaStatus
        created_at         = $createdAtText
        created_by         = [pscustomobject]@{
            role = "control_kernel"
            id   = $CreatedById
        }
        lineage            = [pscustomobject]@{
            source_kind = "execution_bundle"
            source_refs = @(
                (Get-RelativeReference -BaseDirectory $QaReportDirectory -TargetPath $ExecutionBundleInput.Validation.ArtifactPath)
            )
            rationale   = "The QA report is produced directly from the bounded QA gate evaluation of the prepared Execution Bundle."
        }
        pipeline           = [pscustomobject]@{
            mode                       = "admin_only_bounded"
            runtime_boundary           = "admin_only"
            standard_runtime_claimed   = $false
            subproject_runtime_claimed = $false
            orchestration_scope        = "bounded_chain_only"
            notes                      = "The QA report remains inside the admin-only bounded QA chain and does not imply Standard runtime."
        }
        scope              = [pscustomobject]@{
            summary            = "QA report scope is limited to the admin-only control kernel, planning records, governed work objects, execution bundles, and QA report surfaces in the bounded chain."
            allowed_surfaces   = @("admin_runtime_only", "control_kernel", "governed_work_objects", "planning_records", "execution_bundles", "qa_reports")
            protected_surfaces = @("admin_runtime_only", "control_kernel", "planning_records")
            prohibited_surfaces = @("ui_surfaces", "standard_runtime", "subproject_runtime", "automatic_resume", "rollback", "broad_orchestration")
            notes              = "The QA report stays bounded to the already-proved internal QA chain only."
        }
        work_object_refs   = @($workObjectRefs)
        planning_record_refs = @($planningRecordRefs)
        evidence           = @(
            [pscustomobject]@{
                kind    = "test_output"
                ref     = (Get-RelativeReference -BaseDirectory $QaReportDirectory -TargetPath $QaGateResultPath)
                summary = "The QA gate result captures the direct bounded QA outcome."
            },
            [pscustomobject]@{
                kind    = "artifact"
                ref     = (Get-RelativeReference -BaseDirectory $QaReportDirectory -TargetPath $RemediationRecordPath)
                summary = "The remediation record captures the durable remediation state for this QA outcome."
            }
        )
        audit              = [pscustomobject]@{
            trail_refs       = @("tests/test_execution_bundle_qa_gate.ps1")
            last_reviewed_at = $createdAtText
            notes            = "Bounded QA gate output reviewed against the focused QA gate test."
        }
        qa_summary         = $Observation.Document.summary
        verdict            = $qaVerdict
        checks_run         = @($Observation.ChecksRun)
        findings           = @($Observation.Findings)
        remediation_required = $Observation.RemediationRequired
        qa_attempt_count   = $LoopContext.AttemptCount
        qa_retry_ceiling   = $LoopContext.RetryCeiling
        qa_loop_state      = $qaLoopState
        next_handoff       = $nextHandoff
        remediation_notes  = switch ($Observation.Outcome) {
            "pass" { $null }
            "fail" {
                if ($qaStatus -eq "retry_exhausted") {
                    "The bounded QA retry ceiling has been reached; the loop is stopped and must return for manual review."
                }
                else {
                    "Remediation is required before the bundle can be reconsidered."
                }
            }
            "block" {
                if ($qaStatus -eq "retry_exhausted") {
                    "The bounded QA retry ceiling has been reached while blocked; the loop is stopped and must return for manual review."
                }
                else {
                    "The QA gate is blocked until the listed blockers are cleared."
                }
            }
        }
    }

    $qaReportPath = Join-Path $QaReportDirectory ("{0}.json" -f $artifactId)
    Write-JsonDocument -Path $qaReportPath -Document $qaReport
    $validation = & $testWorkArtifactContract -ArtifactPath $qaReportPath

    return [pscustomobject]@{
        Artifact   = $qaReport
        Path       = $qaReportPath
        Validation = $validation
    }
}

function New-ExternalAuditPackArtifact {
    param(
        [Parameter(Mandatory = $true)]
        $ExecutionBundleInput,
        [Parameter(Mandatory = $true)]
        $QaReportOutput,
        [Parameter(Mandatory = $true)]
        $RemediationRecord,
        [Parameter(Mandatory = $true)]
        $TaskPacketInput,
        [Parameter(Mandatory = $true)]
        $WorkObjectRefs,
        [Parameter(Mandatory = $true)]
        $PlanningRefs,
        [Parameter(Mandatory = $true)]
        $Observation,
        [Parameter(Mandatory = $true)]
        [string]$QaGateResultPath,
        [Parameter(Mandatory = $true)]
        [string]$ExternalAuditPackDirectory,
        [Parameter(Mandatory = $true)]
        [datetime]$CreatedAt,
        [Parameter(Mandatory = $true)]
        [string]$CreatedById
    )

    $artifactId = "external-audit-pack-{0}" -f $ExecutionBundleInput.Document.artifact_id
    $createdAtText = Get-UtcTimestamp -DateTime $CreatedAt

    $workObjectRefs = foreach ($workObjectRef in @($WorkObjectRefs)) {
        [pscustomobject]@{
            relation    = "audits"
            object_type = $workObjectRef.ObjectType
            object_id   = $workObjectRef.ObjectId
            ref         = (Get-RelativeReference -BaseDirectory $ExternalAuditPackDirectory -TargetPath $workObjectRef.ResolvedPath)
            notes       = "The audit pack remains bounded to the work object referenced by the evaluated Execution Bundle."
        }
    }

    $planningRecordRefs = foreach ($planningRef in @($PlanningRefs)) {
        [pscustomobject]@{
            relation           = "audits"
            planning_record_id = $planningRef.PlanningRecordId
            object_type        = $planningRef.ObjectType
            object_id          = $planningRef.ObjectId
            view               = "accepted"
            ref                = (Get-RelativeReference -BaseDirectory $ExternalAuditPackDirectory -TargetPath $planningRef.PlanningRecordPath)
            notes              = "The audit pack references the accepted planning baseline for external review."
        }
    }

    $includedArtifacts = New-UniqueStringList
    Add-UniqueString -List $includedArtifacts -Value (Get-RelativeReference -BaseDirectory $ExternalAuditPackDirectory -TargetPath $TaskPacketInput.Path)
    Add-UniqueString -List $includedArtifacts -Value (Get-RelativeReference -BaseDirectory $ExternalAuditPackDirectory -TargetPath $ExecutionBundleInput.Validation.ArtifactPath)
    Add-UniqueString -List $includedArtifacts -Value (Get-RelativeReference -BaseDirectory $ExternalAuditPackDirectory -TargetPath $QaReportOutput.Path)
    Add-UniqueString -List $includedArtifacts -Value (Get-RelativeReference -BaseDirectory $ExternalAuditPackDirectory -TargetPath $RemediationRecord.Path)
    Add-UniqueString -List $includedArtifacts -Value (Get-RelativeReference -BaseDirectory $ExternalAuditPackDirectory -TargetPath $QaGateResultPath)

    $externalAuditPack = [pscustomobject]@{
        contract_version    = "v1"
        record_type         = "governed_work_artifact"
        artifact_type       = "external_audit_pack"
        artifact_id         = $artifactId
        title               = "External audit pack for $($ExecutionBundleInput.Document.title)"
        summary             = "Bounded external audit pack assembled from the QA gate output for Execution Bundle '$($ExecutionBundleInput.Document.artifact_id)'."
        status              = "ready_for_audit"
        created_at          = $createdAtText
        created_by          = [pscustomobject]@{
            role = "control_kernel"
            id   = $CreatedById
        }
        lineage             = [pscustomobject]@{
            source_kind = "qa_report"
            source_refs = @(
                (Get-RelativeReference -BaseDirectory $ExternalAuditPackDirectory -TargetPath $QaReportOutput.Path)
            )
            rationale   = "The audit pack is assembled directly from the bounded QA report outcome."
        }
        pipeline            = [pscustomobject]@{
            mode                       = "admin_only_bounded"
            runtime_boundary           = "admin_only"
            standard_runtime_claimed   = $false
            subproject_runtime_claimed = $false
            orchestration_scope        = "bounded_chain_only"
            notes                      = "The external audit pack remains inside the admin-only bounded QA chain and does not imply Standard runtime."
        }
        scope               = [pscustomobject]@{
            summary            = "External audit pack scope is limited to the admin-only control kernel, planning records, governed work objects, execution bundles, QA reports, and external audit pack surfaces in the bounded chain."
            allowed_surfaces   = @("admin_runtime_only", "control_kernel", "governed_work_objects", "planning_records", "execution_bundles", "qa_reports", "external_audit_packs")
            protected_surfaces = @("admin_runtime_only", "control_kernel", "planning_records")
            prohibited_surfaces = @("ui_surfaces", "standard_runtime", "subproject_runtime", "automatic_resume", "rollback", "broad_orchestration")
            notes              = "The audit pack preserves bounded audit-ready packaging only and does not imply broader packaging orchestration."
        }
        work_object_refs    = @($workObjectRefs)
        planning_record_refs = @($planningRecordRefs)
        evidence            = @(
            [pscustomobject]@{
                kind    = "qa_report"
                ref     = (Get-RelativeReference -BaseDirectory $ExternalAuditPackDirectory -TargetPath $QaReportOutput.Path)
                summary = "The QA report is the direct evidence input for the external audit pack."
            }
        )
        audit               = [pscustomobject]@{
            trail_refs       = @("tests/test_execution_bundle_qa_gate.ps1")
            last_reviewed_at = $createdAtText
            notes            = "External audit pack output reviewed against the focused QA gate test."
        }
        pack_summary        = "Assemble the bounded QA evidence, remediation state, and source artifacts for external audit review."
        included_artifacts  = @($includedArtifacts)
        audit_questions     = @($Observation.AuditQuestions)
        exclusions          = @(
            "Baton persistence and resume behavior",
            "Replay-proof end-to-end packaging beyond the bounded QA slice",
            "Broad workflow orchestration or UI productization"
        )
        reviewer_notes      = $Observation.ReviewerNotes
    }

    $path = Join-Path $ExternalAuditPackDirectory ("{0}.json" -f $artifactId)
    Write-JsonDocument -Path $path -Document $externalAuditPack
    $validation = & $testWorkArtifactContract -ArtifactPath $path

    return [pscustomobject]@{
        Artifact   = $externalAuditPack
        Path       = $path
        Validation = $validation
    }
}

function Invoke-ExecutionBundleQaGate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ExecutionBundlePath,
        [Parameter(Mandatory = $true)]
        [string]$OutputRoot,
        [datetime]$CreatedAt = (Get-Date).ToUniversalTime(),
        [string]$CreatedById = "control-kernel:qa-gate"
    )

    $executionBundleInput = Get-ValidatedExecutionBundleInput -ExecutionBundlePath $ExecutionBundlePath
    $taskPacketInput = Get-ValidatedExecutionBundleTaskPacket -ExecutionBundleInput $executionBundleInput
    $workObjectRefs = Get-ValidatedQaWorkObjectRefs -ExecutionBundleInput $executionBundleInput
    $planningRefs = Get-ValidatedQaPlanningRefs -ExecutionBundleInput $executionBundleInput -WorkObjectRefs $workObjectRefs
    $observation = Get-ValidatedQaObservation -ExecutionBundleInput $executionBundleInput
    $loopContext = Get-ValidatedQaLoopContext -ExecutionBundleInput $executionBundleInput

    $resolvedOutputRoot = Resolve-PathValue -PathValue $OutputRoot
    if (-not (Test-Path -LiteralPath $resolvedOutputRoot)) {
        New-Item -ItemType Directory -Path $resolvedOutputRoot -Force | Out-Null
    }

    $qaGateDirectory = Join-Path $resolvedOutputRoot "qa_gate_records"
    $qaReportsDirectory = Join-Path $resolvedOutputRoot "qa_reports"
    $remediationDirectory = Join-Path $resolvedOutputRoot "remediation_records"
    $externalAuditPackDirectory = Join-Path $resolvedOutputRoot "external_audit_packs"

    foreach ($directory in @($qaGateDirectory, $qaReportsDirectory, $remediationDirectory, $externalAuditPackDirectory)) {
        if (-not (Test-Path -LiteralPath $directory)) {
            New-Item -ItemType Directory -Path $directory -Force | Out-Null
        }
    }

    $qaGateResult = Initialize-QaGateResultRecord -ExecutionBundleInput $executionBundleInput -TaskPacketInput $taskPacketInput -WorkObjectRefs $workObjectRefs -PlanningRefs $planningRefs -Observation $observation -LoopContext $loopContext -CreatedAt $CreatedAt
    $qaGateResultPath = Join-Path $qaGateDirectory ("{0}.json" -f $qaGateResult.gate_id)
    $qaGateResult.observation_ref = Get-RelativeReference -BaseDirectory $qaGateDirectory -TargetPath $observation.Path
    Write-JsonDocument -Path $qaGateResultPath -Document $qaGateResult

    $qaReportId = "qa-report-{0}" -f $executionBundleInput.Document.artifact_id
    $remediationRecord = New-RemediationRecord -ExecutionBundleInput $executionBundleInput -Observation $observation -LoopContext $loopContext -QaReportId $qaReportId -ExecutionBundlePath $executionBundleInput.Validation.ArtifactPath -RemediationDirectory $remediationDirectory -CreatedAt $CreatedAt

    $qaReportOutput = New-QaReportArtifact -ExecutionBundleInput $executionBundleInput -WorkObjectRefs $workObjectRefs -PlanningRefs $planningRefs -Observation $observation -LoopContext $loopContext -QaGateResultPath $qaGateResultPath -RemediationRecordPath $remediationRecord.Path -QaReportDirectory $qaReportsDirectory -CreatedAt $CreatedAt -CreatedById $CreatedById
    $externalAuditPackOutput = New-ExternalAuditPackArtifact -ExecutionBundleInput $executionBundleInput -QaReportOutput $qaReportOutput -RemediationRecord $remediationRecord -TaskPacketInput $taskPacketInput -WorkObjectRefs $workObjectRefs -PlanningRefs $planningRefs -Observation $observation -QaGateResultPath $qaGateResultPath -ExternalAuditPackDirectory $externalAuditPackDirectory -CreatedAt $CreatedAt -CreatedById $CreatedById

    $qaGateResult.generated_artifacts.qa_report = Get-RelativeReference -BaseDirectory $qaGateDirectory -TargetPath $qaReportOutput.Path
    $qaGateResult.generated_artifacts.remediation_record = Get-RelativeReference -BaseDirectory $qaGateDirectory -TargetPath $remediationRecord.Path
    $qaGateResult.generated_artifacts.external_audit_pack = Get-RelativeReference -BaseDirectory $qaGateDirectory -TargetPath $externalAuditPackOutput.Path
    Write-JsonDocument -Path $qaGateResultPath -Document $qaGateResult

    return [pscustomobject]@{
        Outcome                  = $observation.Outcome
        ExecutionBundleValidation = $executionBundleInput.Validation
        TaskPacketValidation     = $taskPacketInput.Validation
        QaReportValidation       = $qaReportOutput.Validation
        ExternalAuditPackValidation = $externalAuditPackOutput.Validation
        QaGateResultPath         = $qaGateResultPath
        QaReportPath             = $qaReportOutput.Path
        RemediationRecordPath    = $remediationRecord.Path
        ExternalAuditPackPath    = $externalAuditPackOutput.Path
    }
}

Export-ModuleMember -Function Invoke-ExecutionBundleQaGate
