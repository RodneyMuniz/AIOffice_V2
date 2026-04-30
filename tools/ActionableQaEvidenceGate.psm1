Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force
$actionableQaModule = Import-Module (Join-Path $PSScriptRoot "ActionableQa.psm1") -Force -PassThru
$fixQueueModule = Import-Module (Join-Path $PSScriptRoot "ActionableQaFixQueue.psm1") -Force -PassThru
$externalRunnerModule = Import-Module (Join-Path $PSScriptRoot "ExternalRunnerContract.psm1") -Force -PassThru
$externalArtifactModule = Import-Module (Join-Path $PSScriptRoot "ExternalArtifactEvidence.psm1") -Force -PassThru
$residueModule = Import-Module (Join-Path $PSScriptRoot "TransitionResiduePreflight.psm1") -Force -PassThru
$remoteHeadModule = Import-Module (Join-Path $PSScriptRoot "RemoteHeadPhaseDetector.psm1") -Force -PassThru
$operatingLoopModule = Import-Module (Join-Path $PSScriptRoot "OperatingLoop.psm1") -Force -PassThru
$valueScorecardModule = Import-Module (Join-Path $PSScriptRoot "ValueScorecard.psm1") -Force -PassThru

$script:TestActionableQaReport = $actionableQaModule.ExportedCommands["Test-ActionableQaReport"]
$script:TestActionableQaFixQueue = $fixQueueModule.ExportedCommands["Test-ActionableQaFixQueue"]
$script:TestExternalRunnerResult = $externalRunnerModule.ExportedCommands["Test-ExternalRunnerResultContract"]
$script:TestExternalArtifactEvidence = $externalArtifactModule.ExportedCommands["Test-ExternalArtifactEvidencePacket"]
$script:TestResiduePreflight = $residueModule.ExportedCommands["Test-TransitionResiduePreflightContract"]
$script:TestRemoteHeadPhase = $remoteHeadModule.ExportedCommands["Test-RemoteHeadPhaseDetectionContract"]
$script:TestOperatingLoop = $operatingLoopModule.ExportedCommands["Test-OperatingLoopContract"]
$script:TestValueScorecard = $valueScorecardModule.ExportedCommands["Test-ValueScorecardContract"]

$script:R12RepositoryName = "AIOffice_V2"
$script:R12Branch = "release/r12-external-api-runner-actionable-qa-control-room-pilot"
$script:GitObjectPattern = "^[a-f0-9]{40}$"
$script:TimestampPattern = "^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$"
$script:AllowedGateVerdicts = @("passed", "failed", "refused", "blocked")
$script:AllowedComponentVerdicts = @("passed", "warning", "failed", "refused", "blocked", "missing")
$script:RequiredConsumedRefs = @(
    "dev_result_ref",
    "actionable_qa_report_ref",
    "actionable_qa_fix_queue_ref",
    "external_runner_result_ref",
    "external_artifact_evidence_ref",
    "residue_preflight_ref",
    "remote_head_phase_detection_ref",
    "operating_loop_ref",
    "value_scorecard_ref"
)
$script:RequiredNonClaims = @(
    "no real production QA",
    "no final QA pass for R12 closeout",
    "no R12 closeout",
    "no final-state replay",
    "no productized control-room",
    "no broad CI/product coverage",
    "no R12 value-gate completion by gate fixture alone"
)

function Get-RepositoryRoot {
    return $repoRoot
}

function Join-RepositoryPath {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Segments
    )

    $path = Get-RepositoryRoot
    foreach ($segment in $Segments) {
        $path = Join-Path $path $segment
    }

    return $path
}

function Resolve-RepositoryPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path (Get-RepositoryRoot) $PathValue))
}

function Get-UtcTimestamp {
    return [System.DateTimeOffset]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture)
}

function Get-JsonDocument {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    return (Read-SingleJsonObject -Path $Path -Label $Label)
}

function Write-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Document,
        [switch]$Overwrite
    )

    if ((Test-Path -LiteralPath $Path -PathType Leaf) -and -not $Overwrite) {
        throw "Actionable QA evidence gate output '$Path' already exists. Use -Overwrite to replace it explicitly."
    }

    $parentPath = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($parentPath)) {
        New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    }

    $Document | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Test-HasProperty {
    param(
        [AllowNull()]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    return $null -ne $Object -and @($Object.PSObject.Properties.Name) -contains $Name
}

function Get-RequiredProperty {
    [CmdletBinding()]
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

    $PSCmdlet.WriteObject($Object.PSObject.Properties[$Name].Value, $false)
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

function Assert-StringValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($null -eq $Value -or $Value -isnot [string]) {
        throw "$Context must be a string."
    }

    return $Value
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

    return [bool]$Value
}

function Assert-IntegerValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [int]$Minimum = 0
    )

    if ($Value -isnot [int] -and $Value -isnot [long]) {
        throw "$Context must be an integer."
    }
    $integer = [int]$Value
    if ($integer -lt $Minimum) {
        throw "$Context must be at least $Minimum."
    }
    return $integer
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
    [CmdletBinding()]
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

    $PSCmdlet.WriteObject($items, $false)
}

function Assert-ObjectArray {
    [CmdletBinding()]
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

    $PSCmdlet.WriteObject($items, $false)
}

function Assert-GitSha {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-NonEmptyString -Value $Value -Context $Context | Out-Null
    if ($Value -notmatch $script:GitObjectPattern) {
        throw "$Context must be a 40-character Git SHA."
    }
}

function Assert-TimestampString {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $timestamp = Assert-NonEmptyString -Value $Value -Context $Context
    if ($timestamp -notmatch $script:TimestampPattern) {
        throw "$Context must be a UTC timestamp."
    }
    return $timestamp
}

function Assert-RequiredObjectFields {
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        [string[]]$FieldNames,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-ObjectValue -Value $Object -Context $Context | Out-Null
    foreach ($fieldName in $FieldNames) {
        Get-RequiredProperty -Object $Object -Name $fieldName -Context $Context | Out-Null
    }
}

function Assert-AllowedValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [object[]]$AllowedValues,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($AllowedValues -notcontains $Value) {
        throw "$Context must be one of: $($AllowedValues -join ', ')."
    }
}

function Assert-BoundedPathOrUrl {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -match '^https?://') {
        return
    }
    if ([System.IO.Path]::IsPathRooted($Value) -or $Value -match '(^|[\\/])\.\.([\\/]|$)') {
        throw "$Context must be a repository-relative path without traversal."
    }
}

function Test-RefExists {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Ref
    )

    if ([string]::IsNullOrWhiteSpace($Ref)) {
        return $false
    }
    Assert-BoundedPathOrUrl -Value $Ref -Context "consumed ref"
    if ($Ref -match '^https?://') {
        return $true
    }
    return (Test-Path -LiteralPath (Resolve-RepositoryPath -PathValue $Ref))
}

function Assert-ExistingRef {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Ref,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-BoundedPathOrUrl -Value $Ref -Context $Context
    if ($Ref -match '^https?://') {
        return
    }
    if (-not (Test-Path -LiteralPath (Resolve-RepositoryPath -PathValue $Ref))) {
        throw "$Context '$Ref' does not exist."
    }
}

function Assert-RequiredNonClaims {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$NonClaims,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($requiredNonClaim in $script:RequiredNonClaims) {
        if ($NonClaims -notcontains $requiredNonClaim) {
            throw "$Context non_claims must include '$requiredNonClaim'."
        }
    }
}

function Test-LineHasNegation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Line
    )

    return ($Line -match '(?i)\b(no|not|without|cannot|must not|does not|do not|is not|are not|non-claim|non_claim|refuse|refuses|blocked|fixture only)\b')
}

function Assert-NoForbiddenGateClaim {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $strings = @()
    if ($Value -is [string]) {
        $strings += $Value
    }
    elseif ($Value -is [System.Collections.IEnumerable]) {
        foreach ($item in $Value) {
            if ($item -is [string]) {
                $strings += $item
            }
        }
    }

    foreach ($line in $strings) {
        if ($line -match '(?i)\b(real production QA|production QA|R12 closeout|final QA pass for R12 closeout|final-state replay|productized control-room)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context contains a forbidden positive gate claim: $line"
        }
    }
}

function Get-ActionableQaEvidenceGateContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "actionable_qa", "cycle_qa_evidence_gate.contract.json")) -Label "Cycle QA evidence gate contract"
}

function Get-RefValidationEntry {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RefName,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Ref,
        [Parameter(Mandatory = $true)]
        [bool]$Present,
        [Parameter(Mandatory = $true)]
        [bool]$ContractValid,
        [Parameter(Mandatory = $true)]
        [string]$Verdict,
        [Parameter(Mandatory = $true)]
        [string]$Details
    )

    return [pscustomobject][ordered]@{
        ref_name = $RefName
        ref = $Ref
        present = $Present
        contract_valid = $ContractValid
        verdict = $Verdict
        details = $Details
    }
}

function Read-ConsumedJsonIfPresent {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Ref,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    if ([string]::IsNullOrWhiteSpace($Ref)) {
        return $null
    }
    if ($Ref -match '^https?://') {
        return $null
    }
    return Get-JsonDocument -Path (Resolve-RepositoryPath -PathValue $Ref) -Label $Label
}

function Assert-HeadTreeMatch {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ExpectedHead,
        [Parameter(Mandatory = $true)]
        [string]$ExpectedTree,
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        $Artifact,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [string]$HeadField = "head",
        [string]$TreeField = "tree"
    )

    if ($null -eq $Artifact) {
        return
    }
    if (-not (Test-HasProperty -Object $Artifact -Name $HeadField) -or -not (Test-HasProperty -Object $Artifact -Name $TreeField)) {
        return
    }
    if ([string]$Artifact.$HeadField -ne $ExpectedHead -or [string]$Artifact.$TreeField -ne $ExpectedTree) {
        throw "$Context head/tree mismatch is rejected."
    }
}

function Test-ActionableQaEvidenceGateObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Gate,
        [string]$SourceLabel = "Cycle QA evidence gate"
    )

    $contract = Get-ActionableQaEvidenceGateContract
    Assert-RequiredObjectFields -Object $Gate -FieldNames $contract.required_fields -Context $SourceLabel

    if ($Gate.contract_version -ne $contract.contract_version) {
        throw "$SourceLabel contract_version must be '$($contract.contract_version)'."
    }
    if ($Gate.artifact_type -ne "cycle_qa_evidence_gate") {
        throw "$SourceLabel artifact_type must be 'cycle_qa_evidence_gate'."
    }
    Assert-NonEmptyString -Value $Gate.gate_id -Context "$SourceLabel gate_id" | Out-Null
    if ($Gate.repository -ne $script:R12RepositoryName) {
        throw "$SourceLabel repository must be '$script:R12RepositoryName'."
    }
    if ($Gate.branch -ne $script:R12Branch) {
        throw "$SourceLabel branch must be '$script:R12Branch'."
    }
    Assert-GitSha -Value ([string]$Gate.head) -Context "$SourceLabel head"
    Assert-GitSha -Value ([string]$Gate.tree) -Context "$SourceLabel tree"
    Assert-NonEmptyString -Value $Gate.gate_scope -Context "$SourceLabel gate_scope" | Out-Null

    $consumedRefs = Assert-ObjectValue -Value $Gate.consumed_refs -Context "$SourceLabel consumed_refs"
    foreach ($refName in $script:RequiredConsumedRefs) {
        Get-RequiredProperty -Object $consumedRefs -Name $refName -Context "$SourceLabel consumed_refs" | Out-Null
        Assert-StringValue -Value $consumedRefs.$refName -Context "$SourceLabel consumed_refs.$refName" | Out-Null
    }

    $validationEntries = Assert-ObjectArray -Value $Gate.consumed_ref_validation -Context "$SourceLabel consumed_ref_validation" -AllowEmpty
    foreach ($entry in $validationEntries) {
        Assert-RequiredObjectFields -Object $entry -FieldNames $contract.consumed_ref_validation_required_fields -Context "$SourceLabel consumed_ref_validation"
        Assert-NonEmptyString -Value $entry.ref_name -Context "$SourceLabel consumed_ref_validation.ref_name" | Out-Null
        Assert-StringValue -Value $entry.ref -Context "$SourceLabel consumed_ref_validation.ref" | Out-Null
        Assert-BooleanValue -Value $entry.present -Context "$SourceLabel consumed_ref_validation.present" | Out-Null
        Assert-BooleanValue -Value $entry.contract_valid -Context "$SourceLabel consumed_ref_validation.contract_valid" | Out-Null
        Assert-NonEmptyString -Value $entry.verdict -Context "$SourceLabel consumed_ref_validation.verdict" | Out-Null
        Assert-StringValue -Value $entry.details -Context "$SourceLabel consumed_ref_validation.details" | Out-Null
    }

    foreach ($componentVerdictField in @("actionable_qa_verdict", "external_evidence_verdict", "residue_preflight_verdict", "remote_head_verdict")) {
        $componentVerdict = Assert-NonEmptyString -Value $Gate.$componentVerdictField -Context "$SourceLabel $componentVerdictField"
        Assert-AllowedValue -Value $componentVerdict -AllowedValues $script:AllowedComponentVerdicts -Context "$SourceLabel $componentVerdictField"
    }

    $gateVerdict = Assert-NonEmptyString -Value $Gate.gate_verdict -Context "$SourceLabel gate_verdict"
    Assert-AllowedValue -Value $gateVerdict -AllowedValues $script:AllowedGateVerdicts -Context "$SourceLabel gate_verdict"
    $blockingIssueCount = Assert-IntegerValue -Value $Gate.blocking_issue_count -Context "$SourceLabel blocking_issue_count" -Minimum 0
    $unresolvedBlockingIssues = Assert-ObjectArray -Value $Gate.unresolved_blocking_issues -Context "$SourceLabel unresolved_blocking_issues" -AllowEmpty
    if ($blockingIssueCount -ne $unresolvedBlockingIssues.Count) {
        throw "$SourceLabel blocking_issue_count must match unresolved_blocking_issues."
    }

    $refusalReasons = Assert-StringArray -Value $Gate.refusal_reasons -Context "$SourceLabel refusal_reasons" -AllowEmpty
    $evidenceRefs = Assert-StringArray -Value $Gate.evidence_refs -Context "$SourceLabel evidence_refs"
    foreach ($evidenceRef in $evidenceRefs) {
        Assert-ExistingRef -Ref $evidenceRef -Context "$SourceLabel evidence_refs"
    }
    Assert-TimestampString -Value $Gate.created_at_utc -Context "$SourceLabel created_at_utc" | Out-Null
    $nonClaims = Assert-StringArray -Value $Gate.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel
    Assert-NoForbiddenGateClaim -Value @($Gate.non_claims + $refusalReasons) -Context $SourceLabel

    if (-not [string]::IsNullOrWhiteSpace([string]$consumedRefs.actionable_qa_report_ref)) {
        if ($consumedRefs.actionable_qa_report_ref -notmatch '\.json$' -or $consumedRefs.actionable_qa_report_ref -match '(?i)narration|transcript|executor') {
            throw "$SourceLabel cannot consume executor narration as QA evidence."
        }
    }

    $report = $null
    $fixQueue = $null
    $externalResult = $null
    $externalEvidence = $null
    $residuePreflight = $null
    $remoteHead = $null

    if (Test-RefExists -Ref $consumedRefs.actionable_qa_report_ref) {
        & $script:TestActionableQaReport -ReportPath $consumedRefs.actionable_qa_report_ref | Out-Null
        $report = Read-ConsumedJsonIfPresent -Ref $consumedRefs.actionable_qa_report_ref -Label "Actionable QA report"
    }
    if (Test-RefExists -Ref $consumedRefs.actionable_qa_fix_queue_ref) {
        & $script:TestActionableQaFixQueue -QueuePath $consumedRefs.actionable_qa_fix_queue_ref | Out-Null
        $fixQueue = Read-ConsumedJsonIfPresent -Ref $consumedRefs.actionable_qa_fix_queue_ref -Label "Actionable QA fix queue"
    }
    if (Test-RefExists -Ref $consumedRefs.external_runner_result_ref) {
        & $script:TestExternalRunnerResult -ResultPath $consumedRefs.external_runner_result_ref | Out-Null
        $externalResult = Read-ConsumedJsonIfPresent -Ref $consumedRefs.external_runner_result_ref -Label "External runner result"
    }
    if (Test-RefExists -Ref $consumedRefs.external_artifact_evidence_ref) {
        & $script:TestExternalArtifactEvidence -PacketPath $consumedRefs.external_artifact_evidence_ref | Out-Null
        $externalEvidence = Read-ConsumedJsonIfPresent -Ref $consumedRefs.external_artifact_evidence_ref -Label "External artifact evidence"
    }
    if (Test-RefExists -Ref $consumedRefs.residue_preflight_ref) {
        & $script:TestResiduePreflight -PreflightPath $consumedRefs.residue_preflight_ref | Out-Null
        $residuePreflight = Read-ConsumedJsonIfPresent -Ref $consumedRefs.residue_preflight_ref -Label "Residue preflight"
    }
    if (Test-RefExists -Ref $consumedRefs.remote_head_phase_detection_ref) {
        & $script:TestRemoteHeadPhase -DetectionPath $consumedRefs.remote_head_phase_detection_ref | Out-Null
        $remoteHead = Read-ConsumedJsonIfPresent -Ref $consumedRefs.remote_head_phase_detection_ref -Label "Remote-head phase detection"
    }
    if (Test-RefExists -Ref $consumedRefs.operating_loop_ref) {
        & $script:TestOperatingLoop -LoopPath $consumedRefs.operating_loop_ref | Out-Null
    }
    if (Test-RefExists -Ref $consumedRefs.value_scorecard_ref) {
        & $script:TestValueScorecard -ScorecardPath $consumedRefs.value_scorecard_ref | Out-Null
    }
    if (Test-RefExists -Ref $consumedRefs.dev_result_ref) {
        Assert-ExistingRef -Ref $consumedRefs.dev_result_ref -Context "$SourceLabel consumed_refs.dev_result_ref"
    }

    if ($null -ne $report) {
        Assert-HeadTreeMatch -ExpectedHead $Gate.head -ExpectedTree $Gate.tree -Artifact $report -Context "$SourceLabel actionable QA report"
    }
    if ($null -ne $fixQueue) {
        Assert-HeadTreeMatch -ExpectedHead $Gate.head -ExpectedTree $Gate.tree -Artifact $fixQueue -Context "$SourceLabel actionable QA fix queue"
    }

    if ($gateVerdict -eq "passed") {
        foreach ($refName in $script:RequiredConsumedRefs) {
            if (-not (Test-RefExists -Ref $consumedRefs.$refName)) {
                throw "$SourceLabel gate cannot pass without $refName."
            }
        }
        if ($null -eq $report) {
            throw "$SourceLabel gate cannot pass without actionable QA report."
        }
        if ($null -eq $fixQueue) {
            throw "$SourceLabel gate cannot pass without actionable QA fix queue."
        }
        if ($blockingIssueCount -gt 0 -or [int]$report.summary.blocking_issue_count -gt 0 -or [int]$fixQueue.blocking_issue_count -gt 0) {
            throw "$SourceLabel gate cannot pass with unresolved blocking QA issues."
        }
        if ($report.aggregate_verdict -in @("failed", "blocked")) {
            throw "$SourceLabel gate cannot pass with actionable QA verdict '$($report.aggregate_verdict)'."
        }
        if ($null -eq $externalResult) {
            throw "$SourceLabel gate cannot pass without external runner result evidence."
        }
        if ($null -eq $externalEvidence) {
            throw "$SourceLabel gate cannot pass without external artifact evidence."
        }
        if ($externalResult.status -ne "completed" -or $externalResult.conclusion -ne "success") {
            throw "$SourceLabel gate cannot pass unless external runner result completed successfully."
        }
        if ($externalEvidence.artifact_source_kind -notin @("github_actions_artifact", "github_artifact_metadata")) {
            throw "$SourceLabel local-only evidence cannot be used as external proof."
        }
        if ($externalEvidence.aggregate_verdict -ne "passed") {
            throw "$SourceLabel gate cannot pass unless external artifact evidence passed."
        }
        if ($externalResult.requested_head -ne $Gate.head -or $externalResult.requested_tree -ne $Gate.tree -or $externalResult.observed_head -ne $Gate.head -or $externalResult.observed_tree -ne $Gate.tree) {
            throw "$SourceLabel external head/tree mismatch is rejected."
        }
        if ($externalEvidence.requested_head -ne $Gate.head -or $externalEvidence.requested_tree -ne $Gate.tree -or $externalEvidence.observed_head -ne $Gate.head -or $externalEvidence.observed_tree -ne $Gate.tree) {
            throw "$SourceLabel external artifact evidence head/tree mismatch is rejected."
        }
        if ($externalEvidence.run_id -ne $externalResult.run_id) {
            throw "$SourceLabel external evidence run_id must match external runner result."
        }
        if ($null -eq $residuePreflight -or $residuePreflight.preflight_verdict -ne "pass") {
            throw "$SourceLabel gate cannot pass without residue preflight pass."
        }
        Assert-HeadTreeMatch -ExpectedHead $Gate.head -ExpectedTree $Gate.tree -Artifact $residuePreflight -Context "$SourceLabel residue preflight"
        if ($null -eq $remoteHead -or [bool]$remoteHead.fail_closed) {
            throw "$SourceLabel gate cannot pass without non-fail-closed remote-head phase detection."
        }
        if ($remoteHead.local_head -ne $Gate.head -or $remoteHead.local_tree -ne $Gate.tree -or $remoteHead.remote_head -ne $Gate.head) {
            throw "$SourceLabel remote-head phase detection head/tree mismatch is rejected."
        }
        if ($Gate.actionable_qa_verdict -notin @("passed", "warning")) {
            throw "$SourceLabel passed gate requires passed or warning actionable_qa_verdict."
        }
        if ($Gate.external_evidence_verdict -ne "passed" -or $Gate.residue_preflight_verdict -ne "passed" -or $Gate.remote_head_verdict -ne "passed") {
            throw "$SourceLabel passed gate requires passed external, residue, and remote-head verdicts."
        }
        if ($refusalReasons.Count -ne 0) {
            throw "$SourceLabel passed gate requires empty refusal_reasons."
        }
    }
    else {
        if ($refusalReasons.Count -eq 0) {
            throw "$SourceLabel non-passed gate verdict requires refusal_reasons."
        }
    }

    $PSCmdlet.WriteObject([pscustomobject][ordered]@{
            GateId = $Gate.gate_id
            Repository = $Gate.repository
            Branch = $Gate.branch
            Head = $Gate.head
            Tree = $Gate.tree
            GateVerdict = $gateVerdict
            BlockingIssueCount = $blockingIssueCount
            RefusalReasonCount = $refusalReasons.Count
            EvidenceRefCount = $evidenceRefs.Count
        }, $false)
}

function Test-ActionableQaEvidenceGate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$GatePath
    )

    $gate = Get-JsonDocument -Path $GatePath -Label "Cycle QA evidence gate"
    return Test-ActionableQaEvidenceGateObject -Gate $gate -SourceLabel "Cycle QA evidence gate"
}

function Invoke-GitLines {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & git -C (Get-RepositoryRoot) @Arguments 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }

    if ($exitCode -ne 0) {
        throw "Git command failed: git $($Arguments -join ' ')"
    }

    return @($output | ForEach-Object { [string]$_ })
}

function Invoke-ValidationForRef {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RefName,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Ref
    )

    if ([string]::IsNullOrWhiteSpace($Ref)) {
        return Get-RefValidationEntry -RefName $RefName -Ref $Ref -Present:$false -ContractValid:$false -Verdict "missing" -Details "Reference was not supplied."
    }
    if (-not (Test-RefExists -Ref $Ref)) {
        return Get-RefValidationEntry -RefName $RefName -Ref $Ref -Present:$false -ContractValid:$false -Verdict "missing" -Details "Reference path does not exist."
    }

    try {
        switch ($RefName) {
            "actionable_qa_report_ref" { & $script:TestActionableQaReport -ReportPath $Ref | Out-Null }
            "actionable_qa_fix_queue_ref" { & $script:TestActionableQaFixQueue -QueuePath $Ref | Out-Null }
            "external_runner_result_ref" { & $script:TestExternalRunnerResult -ResultPath $Ref | Out-Null }
            "external_artifact_evidence_ref" { & $script:TestExternalArtifactEvidence -PacketPath $Ref | Out-Null }
            "residue_preflight_ref" { & $script:TestResiduePreflight -PreflightPath $Ref | Out-Null }
            "remote_head_phase_detection_ref" { & $script:TestRemoteHeadPhase -DetectionPath $Ref | Out-Null }
            "operating_loop_ref" { & $script:TestOperatingLoop -LoopPath $Ref | Out-Null }
            "value_scorecard_ref" { & $script:TestValueScorecard -ScorecardPath $Ref | Out-Null }
            default { Assert-ExistingRef -Ref $Ref -Context $RefName }
        }
        return Get-RefValidationEntry -RefName $RefName -Ref $Ref -Present:$true -ContractValid:$true -Verdict "passed" -Details "Reference exists and validation passed."
    }
    catch {
        return Get-RefValidationEntry -RefName $RefName -Ref $Ref -Present:$true -ContractValid:$false -Verdict "failed" -Details $_.Exception.Message
    }
}

function Invoke-ActionableQaEvidenceGate {
    [CmdletBinding()]
    param(
        [string]$GateScope = "r12_actionable_qa_evidence_gate_diagnostic",
        [string]$DevResultRef = "",
        [string]$ActionableQaReportRef = "",
        [string]$ActionableQaFixQueueRef = "",
        [string]$ExternalRunnerResultRef = "",
        [string]$ExternalArtifactEvidenceRef = "",
        [string]$ResiduePreflightRef = "",
        [string]$RemoteHeadPhaseDetectionRef = "",
        [string]$OperatingLoopRef = "",
        [string]$ValueScorecardRef = "",
        [string]$OutputPath = "",
        [switch]$Overwrite
    )

    $branch = (Invoke-GitLines -Arguments @("branch", "--show-current"))[0].Trim()
    $head = (Invoke-GitLines -Arguments @("rev-parse", "HEAD"))[0].Trim()
    $tree = (Invoke-GitLines -Arguments @("rev-parse", "HEAD^{tree}"))[0].Trim()

    $consumedRefs = [pscustomobject][ordered]@{
        dev_result_ref = $DevResultRef
        actionable_qa_report_ref = $ActionableQaReportRef
        actionable_qa_fix_queue_ref = $ActionableQaFixQueueRef
        external_runner_result_ref = $ExternalRunnerResultRef
        external_artifact_evidence_ref = $ExternalArtifactEvidenceRef
        residue_preflight_ref = $ResiduePreflightRef
        remote_head_phase_detection_ref = $RemoteHeadPhaseDetectionRef
        operating_loop_ref = $OperatingLoopRef
        value_scorecard_ref = $ValueScorecardRef
    }

    $validationEntries = New-Object System.Collections.Generic.List[object]
    foreach ($refName in $script:RequiredConsumedRefs) {
        $validationEntries.Add((Invoke-ValidationForRef -RefName $refName -Ref ([string]$consumedRefs.$refName))) | Out-Null
    }

    $refusalReasons = New-Object System.Collections.Generic.List[string]
    foreach ($entry in @($validationEntries)) {
        if (-not [bool]$entry.present) {
            $refusalReasons.Add("missing required evidence ref '$($entry.ref_name)'.") | Out-Null
        }
        elseif (-not [bool]$entry.contract_valid) {
            $refusalReasons.Add("invalid consumed evidence ref '$($entry.ref_name)': $($entry.details)") | Out-Null
        }
    }

    $report = if (Test-RefExists -Ref $ActionableQaReportRef) { Read-ConsumedJsonIfPresent -Ref $ActionableQaReportRef -Label "Actionable QA report" } else { $null }
    $fixQueue = if (Test-RefExists -Ref $ActionableQaFixQueueRef) { Read-ConsumedJsonIfPresent -Ref $ActionableQaFixQueueRef -Label "Actionable QA fix queue" } else { $null }
    $externalResult = if (Test-RefExists -Ref $ExternalRunnerResultRef) { Read-ConsumedJsonIfPresent -Ref $ExternalRunnerResultRef -Label "External runner result" } else { $null }
    $externalEvidence = if (Test-RefExists -Ref $ExternalArtifactEvidenceRef) { Read-ConsumedJsonIfPresent -Ref $ExternalArtifactEvidenceRef -Label "External artifact evidence" } else { $null }
    $residuePreflight = if (Test-RefExists -Ref $ResiduePreflightRef) { Read-ConsumedJsonIfPresent -Ref $ResiduePreflightRef -Label "Residue preflight" } else { $null }
    $remoteHead = if (Test-RefExists -Ref $RemoteHeadPhaseDetectionRef) { Read-ConsumedJsonIfPresent -Ref $RemoteHeadPhaseDetectionRef -Label "Remote-head phase detection" } else { $null }

    $blockingIssues = @()
    if ($null -ne $report) {
        $blockingIssues = @($report.issues | Where-Object { $_.blocking_status -eq "blocking" })
    }
    if ($blockingIssues.Count -gt 0) {
        $refusalReasons.Add("unresolved blocking actionable QA issues remain.") | Out-Null
    }

    $externalEvidenceVerdict = "missing"
    if ($null -ne $externalResult -and $null -ne $externalEvidence) {
        if ($externalEvidence.artifact_source_kind -notin @("github_actions_artifact", "github_artifact_metadata")) {
            $externalEvidenceVerdict = "refused"
            $refusalReasons.Add("external artifact evidence is local-only and cannot be used as external proof.") | Out-Null
        }
        elseif ($externalResult.requested_head -ne $head -or $externalResult.requested_tree -ne $tree -or $externalEvidence.requested_head -ne $head -or $externalEvidence.requested_tree -ne $tree) {
            $externalEvidenceVerdict = "refused"
            $refusalReasons.Add("external evidence head/tree does not match current branch head/tree.") | Out-Null
        }
        elseif ($externalResult.status -eq "completed" -and $externalResult.conclusion -eq "success" -and $externalEvidence.aggregate_verdict -eq "passed") {
            $externalEvidenceVerdict = "passed"
        }
        else {
            $externalEvidenceVerdict = "failed"
            $refusalReasons.Add("external evidence did not pass.") | Out-Null
        }
    }
    elseif ($null -eq $externalResult -or $null -eq $externalEvidence) {
        $externalEvidenceVerdict = "blocked"
    }

    $actionableQaVerdict = if ($null -eq $report) { "missing" } elseif ($report.aggregate_verdict -eq "passed") { "passed" } elseif ($report.aggregate_verdict -eq "warning") { "warning" } else { "failed" }
    $residueVerdict = if ($null -eq $residuePreflight) { "missing" } elseif ($residuePreflight.preflight_verdict -eq "pass") { "passed" } else { "failed" }
    $remoteVerdict = if ($null -eq $remoteHead) { "missing" } elseif ([bool]$remoteHead.fail_closed) { "failed" } else { "passed" }

    $gateVerdict = "passed"
    if ($refusalReasons.Count -gt 0) {
        if ($externalEvidenceVerdict -eq "blocked" -or $actionableQaVerdict -eq "missing" -or $residueVerdict -eq "missing" -or $remoteVerdict -eq "missing") {
            $gateVerdict = "blocked"
        }
        elseif ($actionableQaVerdict -eq "failed" -or $residueVerdict -eq "failed" -or $remoteVerdict -eq "failed") {
            $gateVerdict = "failed"
        }
        else {
            $gateVerdict = "refused"
        }
    }

    $unresolvedBlockingIssues = @($blockingIssues | ForEach-Object {
            [pscustomobject][ordered]@{
                id = $_.id
                severity = $_.severity
                component = $_.component
                file_path = $_.file_path
                line = $_.line
                failed_rule = $_.failed_rule
                recommended_fix = $_.recommended_fix
                reproduction_command = $_.reproduction_command
            }
        })

    $evidenceRefs = @(
        "contracts/actionable_qa/cycle_qa_evidence_gate.contract.json",
        "tools/ActionableQaEvidenceGate.psm1"
    )
    foreach ($refName in $script:RequiredConsumedRefs) {
        $refValue = [string]$consumedRefs.$refName
        if (Test-RefExists -Ref $refValue) {
            $evidenceRefs += $refValue
        }
    }
    $evidenceRefs = @($evidenceRefs | Sort-Object -Unique)

    $gate = [pscustomobject][ordered]@{
        contract_version = "v1"
        artifact_type = "cycle_qa_evidence_gate"
        gate_id = "r12-cycle-qa-evidence-gate-" + [guid]::NewGuid().ToString("N")
        repository = $script:R12RepositoryName
        branch = $branch
        head = $head
        tree = $tree
        gate_scope = $GateScope
        consumed_refs = $consumedRefs
        consumed_ref_validation = @($validationEntries | ForEach-Object { $_ })
        actionable_qa_verdict = $actionableQaVerdict
        external_evidence_verdict = $externalEvidenceVerdict
        residue_preflight_verdict = $residueVerdict
        remote_head_verdict = $remoteVerdict
        blocking_issue_count = $unresolvedBlockingIssues.Count
        unresolved_blocking_issues = @($unresolvedBlockingIssues)
        gate_verdict = $gateVerdict
        refusal_reasons = @($refusalReasons)
        evidence_refs = @($evidenceRefs)
        created_at_utc = Get-UtcTimestamp
        non_claims = @($script:RequiredNonClaims)
    }

    Test-ActionableQaEvidenceGateObject -Gate $gate -SourceLabel "Cycle QA evidence gate draft" | Out-Null

    if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
        Write-JsonDocument -Path (Resolve-RepositoryPath -PathValue $OutputPath) -Document $gate -Overwrite:$Overwrite
    }

    $PSCmdlet.WriteObject($gate, $false)
}

Export-ModuleMember -Function Get-ActionableQaEvidenceGateContract, Test-ActionableQaEvidenceGateObject, Test-ActionableQaEvidenceGate, Invoke-ActionableQaEvidenceGate
