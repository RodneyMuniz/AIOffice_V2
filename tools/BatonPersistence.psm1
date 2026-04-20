Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$workArtifactValidationModule = Import-Module (Join-Path $PSScriptRoot "WorkArtifactValidation.psm1") -Force -PassThru
$testWorkArtifactContract = $workArtifactValidationModule.ExportedCommands["Test-WorkArtifactContract"]

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

function Get-NormalizedReferenceForSave {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BatonDirectory,
        [Parameter(Mandatory = $true)]
        [string]$Reference
    )

    if ([System.IO.Path]::IsPathRooted($Reference)) {
        return (Get-RelativeReference -BaseDirectory $BatonDirectory -TargetPath $Reference)
    }

    $candidate = Join-Path $BatonDirectory ($Reference -replace "[/\\]", [System.IO.Path]::DirectorySeparatorChar)
    if (Test-Path -LiteralPath $candidate) {
        return $Reference.Replace("\", "/")
    }

    return $Reference.Replace("\", "/")
}

function Test-BatonRecordContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$BatonPath
    )

    $validation = & $testWorkArtifactContract -ArtifactPath $BatonPath
    if ($validation.ArtifactType -ne "baton") {
        throw "Baton persistence requires a baton artifact, but '$BatonPath' resolved to artifact type '$($validation.ArtifactType)'."
    }

    return $validation
}

function Get-ValidatedQaReportInput {
    param(
        [Parameter(Mandatory = $true)]
        [string]$QaReportPath
    )

    $validation = & $testWorkArtifactContract -ArtifactPath $QaReportPath
    if ($validation.ArtifactType -ne "qa_report") {
        throw "Baton emission requires a QA Report artifact, but '$QaReportPath' resolved to artifact type '$($validation.ArtifactType)'."
    }

    $document = Get-JsonDocument -Path $validation.ArtifactPath -Label "QA Report"
    if (@("failed", "blocked", "retry_exhausted") -notcontains $document.status) {
        throw "Baton emission is bounded to QA outcomes that still require follow-up. QA Report '$($document.artifact_id)' must be in status 'failed', 'blocked', or 'retry_exhausted'."
    }

    return [pscustomobject]@{
        Validation = $validation
        Document   = $document
        Directory  = (Split-Path -Parent $validation.ArtifactPath)
    }
}

function Get-ValidatedExternalAuditPackInput {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ExternalAuditPackPath,
        [Parameter(Mandatory = $true)]
        $QaReportInput
    )

    $validation = & $testWorkArtifactContract -ArtifactPath $ExternalAuditPackPath
    if ($validation.ArtifactType -ne "external_audit_pack") {
        throw "Baton emission requires an External Audit Pack artifact, but '$ExternalAuditPackPath' resolved to artifact type '$($validation.ArtifactType)'."
    }

    $document = Get-JsonDocument -Path $validation.ArtifactPath -Label "External Audit Pack"
    $sourceRefs = [string[]](Assert-StringArray -Value (Get-RequiredProperty -Object $document.lineage -Name "source_refs" -Context "External Audit Pack.lineage") -Context "External Audit Pack.lineage.source_refs")
    if ($sourceRefs.Count -eq 0) {
        throw "External Audit Pack '$($document.artifact_id)' must reference its QA Report source."
    }

    $resolvedQaSourcePath = Resolve-ReferenceAgainstBase -BaseDirectory (Split-Path -Parent $validation.ArtifactPath) -Reference $sourceRefs[0] -Label "External Audit Pack lineage"
    if ($resolvedQaSourcePath -ne $QaReportInput.Validation.ArtifactPath) {
        throw "External Audit Pack '$($document.artifact_id)' must derive from the supplied QA Report."
    }

    return [pscustomobject]@{
        Validation = $validation
        Document   = $document
        Directory  = (Split-Path -Parent $validation.ArtifactPath)
    }
}

function Get-ValidatedRemediationRecordInput {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RemediationRecordPath,
        [Parameter(Mandatory = $true)]
        $QaReportInput
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $RemediationRecordPath -Label "Remediation record"
    $document = Get-JsonDocument -Path $resolvedPath -Label "Remediation record"

    $recordType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $document -Name "record_type" -Context "Remediation record") -Context "Remediation record.record_type"
    if ($recordType -ne "qa_gate_remediation_record") {
        throw "Remediation record.record_type must equal 'qa_gate_remediation_record'."
    }

    $qaReportId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $document -Name "qa_report_id" -Context "Remediation record") -Context "Remediation record.qa_report_id"
    if ($qaReportId -ne $QaReportInput.Document.artifact_id) {
        throw "Remediation record.qa_report_id must match the supplied QA Report."
    }

    $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $document -Name "status" -Context "Remediation record") -Context "Remediation record.status"
    if (@("required", "blocked", "retry_exhausted") -notcontains $status) {
        throw "Remediation record status must be 'required', 'blocked', or 'retry_exhausted' for baton emission."
    }

    $qaAttemptCount = Assert-IntegerValue -Value (Get-RequiredProperty -Object $document -Name "qa_attempt_count" -Context "Remediation record") -Context "Remediation record.qa_attempt_count"
    $qaRetryCeiling = Assert-IntegerValue -Value (Get-RequiredProperty -Object $document -Name "qa_retry_ceiling" -Context "Remediation record") -Context "Remediation record.qa_retry_ceiling"
    $qaLoopState = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $document -Name "qa_loop_state" -Context "Remediation record") -Context "Remediation record.qa_loop_state"
    $nextHandoff = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $document -Name "next_handoff" -Context "Remediation record") -Context "Remediation record.next_handoff"
    $actions = [string[]](Assert-StringArray -Value (Get-RequiredProperty -Object $document -Name "actions" -Context "Remediation record") -Context "Remediation record.actions" -AllowEmpty)
    $blockingReasons = [string[]](Assert-StringArray -Value (Get-RequiredProperty -Object $document -Name "blocking_reasons" -Context "Remediation record") -Context "Remediation record.blocking_reasons" -AllowEmpty)
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $document -Name "notes" -Context "Remediation record") -Context "Remediation record.notes" | Out-Null

    if ($qaRetryCeiling -ne 4) {
        throw "Remediation record.qa_retry_ceiling must equal 4 for the bounded QA loop."
    }
    if ($qaAttemptCount -lt 1 -or $qaAttemptCount -gt $qaRetryCeiling) {
        throw "Remediation record.qa_attempt_count must stay within the bounded QA retry ceiling."
    }
    if ([int]$QaReportInput.Document.qa_attempt_count -ne $qaAttemptCount) {
        throw "Remediation record.qa_attempt_count must match the supplied QA Report."
    }
    if ([int]$QaReportInput.Document.qa_retry_ceiling -ne $qaRetryCeiling) {
        throw "Remediation record.qa_retry_ceiling must match the supplied QA Report."
    }
    if ($QaReportInput.Document.qa_loop_state -ne $qaLoopState) {
        throw "Remediation record.qa_loop_state must match the supplied QA Report."
    }
    if ($QaReportInput.Document.next_handoff -ne $nextHandoff) {
        throw "Remediation record.next_handoff must match the supplied QA Report."
    }

    if ($status -eq "required" -and $actions.Count -eq 0) {
        throw "Remediation record status 'required' must include at least one action."
    }
    if ($status -eq "blocked" -and $blockingReasons.Count -eq 0) {
        throw "Remediation record status 'blocked' must include at least one blocking reason."
    }
    if ($status -eq "retry_exhausted") {
        if ($qaAttemptCount -ne $qaRetryCeiling) {
            throw "Retry-exhausted remediation records must reflect the retry-ceiling attempt."
        }
        if ($qaLoopState -ne "retry_exhausted" -or $nextHandoff -ne "manual_review") {
            throw "Retry-exhausted remediation records must stop the bounded loop and hand off to manual_review."
        }
    }
    elseif ($nextHandoff -ne "baton_follow_up") {
        throw "Open remediation records must hand off to baton_follow_up."
    }

    return [pscustomobject]@{
        Path            = $resolvedPath
        Document        = $document
        AttemptCount    = $qaAttemptCount
        RetryCeiling    = $qaRetryCeiling
        NextHandoff     = $nextHandoff
        Actions         = $actions
        BlockingReasons = $blockingReasons
    }
}

function New-BatonFromQaOutcome {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$QaReportPath,
        [Parameter(Mandatory = $true)]
        [string]$ExternalAuditPackPath,
        [Parameter(Mandatory = $true)]
        [string]$RemediationRecordPath,
        [string]$BatonId,
        [datetime]$CreatedAt = (Get-Date).ToUniversalTime(),
        [string]$CreatedById = "control-kernel:baton"
    )

    $qaReportInput = Get-ValidatedQaReportInput -QaReportPath $QaReportPath
    $externalAuditPackInput = Get-ValidatedExternalAuditPackInput -ExternalAuditPackPath $ExternalAuditPackPath -QaReportInput $qaReportInput
    $remediationRecordInput = Get-ValidatedRemediationRecordInput -RemediationRecordPath $RemediationRecordPath -QaReportInput $qaReportInput

    if ([string]::IsNullOrWhiteSpace($BatonId)) {
        $BatonId = "baton-{0}" -f $qaReportInput.Document.artifact_id
    }

    $createdAtText = Get-UtcTimestamp -DateTime $CreatedAt
    $blockedBy = [System.Collections.Generic.List[string]]::new()
    foreach ($reason in @($remediationRecordInput.BlockingReasons)) {
        if (-not [string]::IsNullOrWhiteSpace($reason) -and -not $blockedBy.Contains($reason)) {
            $blockedBy.Add($reason) | Out-Null
        }
    }
    foreach ($finding in @($qaReportInput.Document.findings)) {
        if (-not [string]::IsNullOrWhiteSpace($finding) -and -not $blockedBy.Contains($finding)) {
            $blockedBy.Add($finding) | Out-Null
        }
    }
    if (-not [string]::IsNullOrWhiteSpace($qaReportInput.Document.remediation_notes) -and -not $blockedBy.Contains($qaReportInput.Document.remediation_notes)) {
        $blockedBy.Add($qaReportInput.Document.remediation_notes) | Out-Null
    }
    if ($blockedBy.Count -eq 0) {
        throw "Baton emission requires at least one explicit blocker or remediation reason."
    }

    $handoffNotes = [System.Collections.Generic.List[string]]::new()
    $handoffNotes.Add("Do not auto-resume; this baton is persistence-only foundation state.") | Out-Null
    $handoffNotes.Add($qaReportInput.Document.qa_summary) | Out-Null
    foreach ($action in @($remediationRecordInput.Actions)) {
        if (-not $handoffNotes.Contains($action)) {
            $handoffNotes.Add($action) | Out-Null
        }
    }
    if (-not [string]::IsNullOrWhiteSpace($qaReportInput.Document.remediation_notes) -and -not $handoffNotes.Contains($qaReportInput.Document.remediation_notes)) {
        $handoffNotes.Add($qaReportInput.Document.remediation_notes) | Out-Null
    }
    if ($remediationRecordInput.NextHandoff -eq "manual_review" -and -not $handoffNotes.Contains("Retry ceiling reached; manual review is required before any further bounded work.")) {
        $handoffNotes.Add("Retry ceiling reached; manual review is required before any further bounded work.") | Out-Null
    }

    $nextRequiredArtifacts = @(
        $qaReportInput.Validation.ArtifactPath,
        $externalAuditPackInput.Validation.ArtifactPath,
        $remediationRecordInput.Path
    )

    $baton = [pscustomobject]@{
        contract_version      = "v1"
        record_type           = "governed_work_artifact"
        artifact_type         = "baton"
        artifact_id           = $BatonId
        title                 = "Baton for $($qaReportInput.Document.title)"
        summary               = "Minimal persisted baton emitted from QA outcome '$($qaReportInput.Document.status)' for bounded resume foundations only."
        status                = "ready_for_handoff"
        created_at            = $createdAtText
        created_by            = [pscustomobject]@{
            role = "control_kernel"
            id   = $CreatedById
        }
        lineage               = [pscustomobject]@{
            source_kind = "qa_report"
            source_refs = @($qaReportInput.Validation.ArtifactPath)
            rationale   = "The baton captures the minimal follow-up state produced by a bounded QA outcome."
        }
        pipeline              = [pscustomobject]@{
            mode                       = "admin_only_bounded"
            runtime_boundary           = "admin_only"
            standard_runtime_claimed   = $false
            subproject_runtime_claimed = $false
            orchestration_scope        = "qa_follow_up_only"
            notes                      = "The baton remains inside the admin-only bounded follow-up foundation and does not imply Standard runtime."
        }
        scope                 = [pscustomobject]@{
            summary            = "Baton scope is limited to the admin-only control kernel, planning records, governed work objects, QA reports, external audit packs, and baton surfaces needed for bounded manual follow-up preparation."
            allowed_surfaces   = @("admin_runtime_only", "control_kernel", "governed_work_objects", "planning_records", "qa_reports", "external_audit_packs", "batons")
            protected_surfaces = @("admin_runtime_only", "control_kernel", "planning_records")
            prohibited_surfaces = @("ui_surfaces", "standard_runtime", "subproject_runtime", "automatic_resume", "rollback", "broad_orchestration")
            notes              = "The baton is persistence and load foundation only and does not open automatic resume, rollback, or broader orchestration."
        }
        work_object_refs      = @($qaReportInput.Document.work_object_refs | ForEach-Object {
                [pscustomobject]@{
                    relation    = if ($qaReportInput.Document.status -eq "blocked") { "blocks" } else { "hands_off" }
                    object_type = $_.object_type
                    object_id   = $_.object_id
                    ref         = (Resolve-ReferenceAgainstBase -BaseDirectory $qaReportInput.Directory -Reference $_.ref -Label "QA Report work object")
                    notes       = "The baton persists the bounded work object follow-up scope from the QA outcome."
                }
            })
        planning_record_refs  = @($qaReportInput.Document.planning_record_refs | ForEach-Object {
                [pscustomobject]@{
                    relation           = "hands_off"
                    planning_record_id = $_.planning_record_id
                    object_type        = $_.object_type
                    object_id          = $_.object_id
                    view               = $_.view
                    ref                = (Resolve-ReferenceAgainstBase -BaseDirectory $qaReportInput.Directory -Reference $_.ref -Label "QA Report planning record")
                    notes              = "The baton persists the bounded planning view needed for manual resume preparation."
                }
            })
        evidence              = @(
            [pscustomobject]@{
                kind    = "artifact"
                ref     = $qaReportInput.Validation.ArtifactPath
                summary = "The QA report is the direct baton evidence source."
            },
            [pscustomobject]@{
                kind    = "artifact"
                ref     = $externalAuditPackInput.Validation.ArtifactPath
                summary = "The external audit pack is required input for the next bounded review step."
            },
            [pscustomobject]@{
                kind    = "artifact"
                ref     = $remediationRecordInput.Path
                summary = "The remediation record captures the bounded follow-up or unblock work."
            }
        )
        audit                 = [pscustomobject]@{
            trail_refs       = @("tests/test_baton_persistence.ps1")
            last_reviewed_at = $createdAtText
            notes            = "Minimal baton persistence output reviewed against the focused baton persistence test."
        }
        baton_summary         = "Persist the bounded QA follow-up state for manual resume preparation."
        resume_objective      = "Reload the baton to recover the minimal follow-up context without automatically resuming execution."
        qa_attempt_count      = $remediationRecordInput.AttemptCount
        qa_retry_ceiling      = $remediationRecordInput.RetryCeiling
        handoff_state         = if ($remediationRecordInput.NextHandoff -eq "manual_review") { "manual_review" } else { "follow_up" }
        handoff_notes         = @($handoffNotes)
        blocked_by            = @($blockedBy)
        next_required_artifacts = @($nextRequiredArtifacts)
        expires_at            = $null
    }

    return [pscustomobject]@{
        Baton = $baton
    }
}

function Save-BatonRecord {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Baton,
        [Parameter(Mandatory = $true)]
        [string]$StorePath
    )

    $resolvedStorePath = Resolve-PathValue -PathValue $StorePath
    if (-not (Test-Path -LiteralPath $resolvedStorePath)) {
        New-Item -ItemType Directory -Path $resolvedStorePath -Force | Out-Null
    }

    $batonDirectory = Join-Path $resolvedStorePath "batons"
    if (-not (Test-Path -LiteralPath $batonDirectory)) {
        New-Item -ItemType Directory -Path $batonDirectory -Force | Out-Null
    }

    $persistedBaton = [pscustomobject]@{
        contract_version      = $Baton.contract_version
        record_type           = $Baton.record_type
        artifact_type         = $Baton.artifact_type
        artifact_id           = $Baton.artifact_id
        title                 = $Baton.title
        summary               = $Baton.summary
        status                = $Baton.status
        created_at            = $Baton.created_at
        created_by            = $Baton.created_by
        lineage               = [pscustomobject]@{
            source_kind = $Baton.lineage.source_kind
            source_refs = @($Baton.lineage.source_refs | ForEach-Object { Get-NormalizedReferenceForSave -BatonDirectory $batonDirectory -Reference $_ })
            rationale   = $Baton.lineage.rationale
        }
        pipeline              = $Baton.pipeline
        scope                 = $Baton.scope
        work_object_refs      = @($Baton.work_object_refs | ForEach-Object {
                [pscustomobject]@{
                    relation    = $_.relation
                    object_type = $_.object_type
                    object_id   = $_.object_id
                    ref         = (Get-NormalizedReferenceForSave -BatonDirectory $batonDirectory -Reference $_.ref)
                    notes       = $_.notes
                }
            })
        planning_record_refs  = @($Baton.planning_record_refs | ForEach-Object {
                [pscustomobject]@{
                    relation           = $_.relation
                    planning_record_id = $_.planning_record_id
                    object_type        = $_.object_type
                    object_id          = $_.object_id
                    view               = $_.view
                    ref                = (Get-NormalizedReferenceForSave -BatonDirectory $batonDirectory -Reference $_.ref)
                    notes              = $_.notes
                }
            })
        evidence              = @($Baton.evidence | ForEach-Object {
                [pscustomobject]@{
                    kind    = $_.kind
                    ref     = (Get-NormalizedReferenceForSave -BatonDirectory $batonDirectory -Reference $_.ref)
                    summary = $_.summary
                }
            })
        audit                 = $Baton.audit
        baton_summary         = $Baton.baton_summary
        resume_objective      = $Baton.resume_objective
        qa_attempt_count      = $Baton.qa_attempt_count
        qa_retry_ceiling      = $Baton.qa_retry_ceiling
        handoff_state         = $Baton.handoff_state
        handoff_notes         = @($Baton.handoff_notes)
        blocked_by            = @($Baton.blocked_by)
        next_required_artifacts = @($Baton.next_required_artifacts | ForEach-Object { Get-NormalizedReferenceForSave -BatonDirectory $batonDirectory -Reference $_ })
        expires_at            = $Baton.expires_at
    }

    $batonPath = Join-Path $batonDirectory ("{0}.json" -f $persistedBaton.artifact_id)
    Write-JsonDocument -Path $batonPath -Document $persistedBaton
    Test-BatonRecordContract -BatonPath $batonPath | Out-Null

    return $batonPath
}

function Get-BatonRecord {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$BatonId,
        [Parameter(Mandatory = $true)]
        [string]$StorePath
    )

    $resolvedStorePath = Resolve-PathValue -PathValue $StorePath
    $batonPath = Join-Path (Join-Path $resolvedStorePath "batons") ("{0}.json" -f $BatonId)
    $validation = Test-BatonRecordContract -BatonPath $batonPath
    $baton = Get-JsonDocument -Path $validation.ArtifactPath -Label "Baton"

    return [pscustomobject]@{
        Validation = $validation
        Baton      = $baton
    }
}

Export-ModuleMember -Function Test-BatonRecordContract, New-BatonFromQaOutcome, Save-BatonRecord, Get-BatonRecord
