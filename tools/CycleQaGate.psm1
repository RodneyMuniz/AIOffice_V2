Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$jsonRootModule = Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force -PassThru
$devAdapterModule = Import-Module (Join-Path $PSScriptRoot "DevExecutionAdapter.psm1") -Force -PassThru -DisableNameChecking -WarningAction SilentlyContinue
$script:ReadSingleJsonObject = $jsonRootModule.ExportedCommands["Read-SingleJsonObject"]
$script:TestDevDispatchPacketContract = $devAdapterModule.ExportedCommands["Test-DevDispatchPacketContract"]
$script:TestDevExecutionResultPacketContract = $devAdapterModule.ExportedCommands["Test-DevExecutionResultPacketContract"]

function Get-RepositoryRoot {
    return $repoRoot
}

function Get-ModuleRepositoryRootPath {
    return (Resolve-Path -LiteralPath (Get-RepositoryRoot)).Path
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

function Resolve-PathValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [string]$AnchorPath = (Get-ModuleRepositoryRootPath)
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    $resolvedAnchorPath = if (Test-Path -LiteralPath $AnchorPath) {
        (Resolve-Path -LiteralPath $AnchorPath).Path
    }
    else {
        [System.IO.Path]::GetFullPath($AnchorPath)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $resolvedAnchorPath $PathValue))
}

function Resolve-ExistingPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [Parameter(Mandatory = $true)]
        [string]$Label,
        [string]$AnchorPath = (Get-ModuleRepositoryRootPath)
    )

    $resolvedPath = Resolve-PathValue -PathValue $PathValue -AnchorPath $AnchorPath
    if (-not (Test-Path -LiteralPath $resolvedPath)) {
        throw "$Label '$PathValue' does not exist."
    }

    return (Resolve-Path -LiteralPath $resolvedPath).Path
}

function Get-JsonDocument {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $document = & $script:ReadSingleJsonObject -Path $Path -Label $Label
    $PSCmdlet.WriteObject($document, $false)
}

function Write-JsonDocument {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Document,
        [switch]$Overwrite
    )

    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        if (-not $Overwrite) {
            throw "Cycle QA gate output '$Path' already exists. Use -Overwrite to replace it explicitly."
        }
    }

    $parentPath = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($parentPath)) {
        New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    }

    $Document | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function ConvertTo-RepositoryPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $fullPath = [System.IO.Path]::GetFullPath($Path)
    $fullRoot = [System.IO.Path]::GetFullPath($RepositoryRoot).TrimEnd([char[]]@([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar))
    if ($fullPath.Equals($fullRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Cycle QA gate refs must not point at the repository root."
    }

    $rootWithSeparator = $fullRoot + [System.IO.Path]::DirectorySeparatorChar
    if (-not $fullPath.StartsWith($rootWithSeparator, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Cycle QA gate path '$Path' escapes repository root."
    }

    return $fullPath.Substring($rootWithSeparator.Length).Replace("\", "/").TrimEnd("/")
}

function Get-CycleControllerFoundationContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "cycle_controller", "foundation.contract.json")) -Label "Cycle controller foundation contract"
}

function Get-CycleQaGateContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "cycle_controller", "cycle_qa_gate.contract.json")) -Label "Cycle QA gate contract"
}

function Get-CycleQaSignoffPacketContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "cycle_controller", "cycle_qa_signoff_packet.contract.json")) -Label "Cycle QA signoff packet contract"
}

function Test-HasProperty {
    param(
        [Parameter(Mandatory = $true)]
        $Object,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    if ($null -eq $Object) {
        return $false
    }

    $propertyNames = @($Object.PSObject.Properties | ForEach-Object { $_.Name })
    return $propertyNames -contains $Name
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

    $property = $Object.PSObject.Properties[$Name]
    $PSCmdlet.WriteObject($property.Value, $false)
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

function Assert-StringArrayValue {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [switch]$AllowEmpty
    )

    if ($null -eq $Value) {
        if ($AllowEmpty) {
            $PSCmdlet.WriteObject(@(), $false)
            return
        }

        throw "$Context must be an array."
    }

    if ($Value -is [string] -or -not ($Value -is [System.Collections.IEnumerable])) {
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

function Assert-ObjectArrayValue {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [int]$MinimumCount = 1
    )

    if ($null -eq $Value -or $Value -is [string] -or -not ($Value -is [System.Collections.IEnumerable])) {
        throw "$Context must be an array."
    }

    $items = @($Value)
    if ($items.Count -lt $MinimumCount) {
        throw "$Context must contain at least $MinimumCount item(s)."
    }

    foreach ($item in $items) {
        Assert-ObjectValue -Value $item -Context "$Context item" | Out-Null
    }

    $PSCmdlet.WriteObject($items, $false)
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

function Assert-MatchesPattern {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Pattern,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -notmatch $Pattern) {
        throw "$Context does not match required pattern '$Pattern'."
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

function Assert-TimestampValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Pattern,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-MatchesPattern -Value $Value -Pattern $Pattern -Context $Context
    try {
        $styles = [System.Globalization.DateTimeStyles]::AssumeUniversal -bor [System.Globalization.DateTimeStyles]::AdjustToUniversal
        [System.DateTimeOffset]::ParseExact($Value, "yyyy-MM-dd'T'HH:mm:ss'Z'", [System.Globalization.CultureInfo]::InvariantCulture, $styles) | Out-Null
    }
    catch {
        throw "$Context must be a valid UTC timestamp."
    }
}

function Assert-RepoRefValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Value -isnot [string] -or [string]::IsNullOrWhiteSpace($Value)) {
        throw "$Context must be a non-empty repo ref."
    }

    Assert-MatchesPattern -Value $Value -Pattern $Foundation.repo_ref_pattern -Context $Context
    return $Value
}

function Assert-RepoRefArrayValue {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [switch]$AllowEmpty
    )

    $items = Assert-StringArrayValue -Value $Value -Context $Context -AllowEmpty:$AllowEmpty
    foreach ($item in $items) {
        Assert-RepoRefValue -Value $item -Foundation $Foundation -Context "$Context item" | Out-Null
    }

    $PSCmdlet.WriteObject($items, $false)
}

function Get-UtcTimestamp {
    return [System.DateTimeOffset]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture)
}

function New-QaSignoffId {
    return ("qa-signoff-{0}" -f [guid]::NewGuid().ToString("N").Substring(0, 12))
}

function ConvertTo-FlatStringArray {
    [CmdletBinding()]
    param(
        [AllowEmptyCollection()]
        [object[]]$Values
    )

    foreach ($value in @($Values)) {
        if ($null -eq $value) {
            continue
        }

        if ($value -is [string]) {
            $PSCmdlet.WriteObject($value)
            continue
        }

        if ($value -is [System.Collections.IEnumerable]) {
            foreach ($nestedValue in @($value)) {
                if ($null -ne $nestedValue) {
                    $PSCmdlet.WriteObject([string]$nestedValue)
                }
            }
            continue
        }

        $PSCmdlet.WriteObject([string]$value)
    }
}

function Get-UniqueStringValues {
    [CmdletBinding()]
    param(
        [AllowEmptyCollection()]
        [object[]]$Values
    )

    $items = @()
    foreach ($value in @(ConvertTo-FlatStringArray -Values $Values)) {
        if ([string]::IsNullOrWhiteSpace($value)) {
            continue
        }

        if ($items -notcontains $value) {
            $items += $value
        }
    }

    foreach ($item in $items) {
        $PSCmdlet.WriteObject($item)
    }
}

function Test-LineHasNegation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Line
    )

    return ($Line -match '(?i)\b(no|not|without|never|cannot|must not|does not|do not|is not|are not|did not|reject|rejects|refuse|refuses|non-claim|nonclaims|non-scope|source evidence only|not accepted|not evidence|not proof|does not prove|does not claim|must not claim)\b')
}

function Assert-NoForbiddenPositiveClaim {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($null -eq $Value) {
        return
    }

    $items = if ($Value -is [System.Array]) { @($Value) } else { @($Value) }
    $claimPatterns = @(
        @{ Label = "executor self-certification as QA"; Pattern = '(?i)\bexecutor self-certification\b.{0,100}\b(QA|accepted|proof|authority)\b|\bself-certif(?:y|ies|ication)\b.{0,100}\bQA\b' },
        @{ Label = "Dev result accepted as QA authority"; Pattern = '(?i)\bDev result\b.{0,100}\b(QA authority|QA verdict|accepted as QA|proof)\b' },
        @{ Label = "executor narration accepted as proof"; Pattern = '(?i)\bexecutor narration\b.{0,100}\b(accepted|proof|authority)\b|\bnarration\b.{0,100}\b(accepted as proof|QA authority)\b' },
        @{ Label = "complete controlled cycle"; Pattern = '(?i)\bcomplete controlled cycle\b.{0,120}\b(ran|run|executed|complete|completed|closed|accepted|done|proven)\b|\bcycle\b.{0,80}\b(complete|completed|closed|accepted)\b' },
        @{ Label = "R11 closeout"; Pattern = '(?i)\bR11\b.{0,80}\b(closeout|closed|accepted)\b' },
        @{ Label = "real production QA"; Pattern = '(?i)\breal production QA\b|\bproduction QA\b' },
        @{ Label = "UI/control-room productization"; Pattern = '(?i)\bUI/control-room productization\b|\bcontrol-room productization\b|\bproductized control-room\b|\bproduct UI\b' },
        @{ Label = "Standard runtime"; Pattern = '(?i)\bStandard runtime\b' },
        @{ Label = "multi-repo orchestration"; Pattern = '(?i)\bmulti-repo orchestration\b' },
        @{ Label = "swarms"; Pattern = '(?i)\bswarms\b|\bfleet execution\b' },
        @{ Label = "broad autonomous milestone execution"; Pattern = '(?i)\bbroad autonomous milestone execution\b|\bbroad autonomy\b' },
        @{ Label = "unattended automatic resume"; Pattern = '(?i)\bunattended automatic resume\b' },
        @{ Label = "solved Codex context compaction"; Pattern = '(?i)\bsolved Codex context compaction\b|\bCodex context compaction is solved\b' },
        @{ Label = "hours-long unattended execution"; Pattern = '(?i)\bhours-long unattended\b' },
        @{ Label = "destructive rollback"; Pattern = '(?i)\bdestructive rollback\b' },
        @{ Label = "broad CI/product coverage"; Pattern = '(?i)\bbroad CI/product coverage\b|\bproduction-grade CI\b' },
        @{ Label = "production runtime"; Pattern = '(?i)\bproduction runtime\b' },
        @{ Label = "general Codex reliability"; Pattern = '(?i)\bgeneral Codex reliability\b' },
        @{ Label = "successor milestone"; Pattern = '(?i)\bR12\b.*\b(active|open|opened|complete|closed)\b|\bsuccessor milestone\b.*\b(active|open|opened|complete|closed)\b' }
    )

    foreach ($item in $items) {
        if ($item -isnot [string]) {
            continue
        }

        foreach ($claimPattern in $claimPatterns) {
            if ($item -match $claimPattern.Pattern -and -not (Test-LineHasNegation -Line $item)) {
                throw "$Context must not claim $($claimPattern.Label). Offending text: $item"
            }
        }
    }
}

function Assert-RequiredNonClaims {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [object[]]$RequiredNonClaims,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $nonClaims = Assert-StringArrayValue -Value $Value -Context $Context
    foreach ($requiredNonClaim in @($RequiredNonClaims)) {
        if ($nonClaims -notcontains $requiredNonClaim) {
            throw "$Context must include '$requiredNonClaim'."
        }
    }

    Assert-NoForbiddenPositiveClaim -Value $nonClaims -Context $Context
    return $nonClaims
}

function Get-DevEvidenceRefs {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $DevResult
    )

    $evidenceRefs = @()
    if (Test-HasProperty -Object $DevResult -Name "evidence_refs") {
        $evidenceRefs += @($DevResult.evidence_refs)
    }

    if (Test-HasProperty -Object $DevResult -Name "task_results") {
        foreach ($taskResult in @($DevResult.task_results)) {
            if (Test-HasProperty -Object $taskResult -Name "evidence_refs") {
                $evidenceRefs += @($taskResult.evidence_refs)
            }
        }
    }

    foreach ($uniqueEvidenceRef in @(Get-UniqueStringValues -Values $evidenceRefs)) {
        $PSCmdlet.WriteObject($uniqueEvidenceRef)
    }
}

function Assert-DevResultHasNoQaFields {
    param(
        [Parameter(Mandatory = $true)]
        $DevResult,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $forbiddenQaFields = @(
        "qa_verdict",
        "qa_authority",
        "qa_authority_type",
        "qa_signoff_id",
        "qa_checks",
        "qa_findings",
        "qa_actor_identity",
        "qa_actor_kind"
    )

    foreach ($fieldName in $forbiddenQaFields) {
        if (Test-HasProperty -Object $DevResult -Name $fieldName) {
            throw "$Context must not claim QA authority or QA verdict through field '$fieldName'."
        }
    }
}

function Assert-DevResultTextHasNoQaClaims {
    param(
        [Parameter(Mandatory = $true)]
        $DevResult
    )

    $textValues = @()
    foreach ($fieldName in @("executor_identity", "executor_kind", "status", "refusal_reasons", "non_claims")) {
        if (Test-HasProperty -Object $DevResult -Name $fieldName) {
            $textValues += @($DevResult.PSObject.Properties[$fieldName].Value)
        }
    }

    if (Test-HasProperty -Object $DevResult -Name "task_results") {
        foreach ($taskResult in @($DevResult.task_results)) {
            foreach ($fieldName in @("summary", "refusal_reasons", "non_claims")) {
                if (Test-HasProperty -Object $taskResult -Name $fieldName) {
                    $textValues += @($taskResult.PSObject.Properties[$fieldName].Value)
                }
            }
        }
    }

    Assert-NoForbiddenPositiveClaim -Value $textValues -Context "Dev result packet"
}

function Assert-DevStatusCompatibleWithQa {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Status,
        [Parameter(Mandatory = $true)]
        $GateContract
    )

    if (@($GateContract.allowed_dev_result_statuses_for_qa) -notcontains $Status) {
        throw "Dev result status '$Status' is not compatible with QA. Allowed statuses: $($GateContract.allowed_dev_result_statuses_for_qa -join ', ')."
    }
}

function Assert-IndependenceBoundary {
    param(
        [Parameter(Mandatory = $true)]
        [string]$QaActorIdentity,
        [Parameter(Mandatory = $true)]
        [string]$ExecutorIdentity,
        [Parameter(Mandatory = $true)]
        [string]$QaIndependenceBoundary
    )

    Assert-NoForbiddenPositiveClaim -Value $QaIndependenceBoundary -Context "QA independence boundary"

    if ($QaActorIdentity -ne $ExecutorIdentity) {
        return
    }

    $explicitBoundaryPattern = '(?i)(executor self-certification.{0,120}(not accepted|not being accepted|rejected|refused)|not accepting.{0,120}executor self-certification|separate QA gate.{0,120}source evidence only|Dev result.{0,120}source evidence only.{0,120}not accepted as QA authority)'
    if ($QaIndependenceBoundary -notmatch $explicitBoundaryPattern) {
        throw "QA actor identity matches executor identity; qa_independence_boundary must explicitly state why executor self-certification is not being accepted."
    }
}

function New-QaCheck {
    param(
        [Parameter(Mandatory = $true)]
        [string]$CheckId,
        [Parameter(Mandatory = $true)]
        [string]$Summary,
        [Parameter(Mandatory = $true)]
        [string[]]$EvidenceRefs
    )

    $flatEvidenceRefs = @(ConvertTo-FlatStringArray -Values $EvidenceRefs)
    return [pscustomobject][ordered]@{
        check_id = $CheckId
        status = "passed"
        summary = $Summary
        evidence_refs = @($flatEvidenceRefs)
        refusal_reasons = @()
    }
}

function New-DefaultQaChecks {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$DispatchRef,
        [Parameter(Mandatory = $true)]
        [string]$DevResultRef,
        [Parameter(Mandatory = $true)]
        [string[]]$DevEvidenceRefs,
        [Parameter(Mandatory = $true)]
        [string]$DevStatus,
        [Parameter(Mandatory = $true)]
        [bool]$ActorDistinct
    )

    $checks = @(
        (New-QaCheck -CheckId "dev_dispatch_packet_validates" -Summary "Dev dispatch packet validates against the R11-006 dispatch contract." -EvidenceRefs @($DispatchRef)),
        (New-QaCheck -CheckId "dev_result_packet_validates" -Summary "Dev result packet validates against the R11-006 result contract." -EvidenceRefs @($DevResultRef)),
        (New-QaCheck -CheckId "dispatch_result_cycle_identity_matches" -Summary "Dispatch and Dev result cycle identity match." -EvidenceRefs @($DispatchRef, $DevResultRef)),
        (New-QaCheck -CheckId "dev_result_status_compatible_with_qa" -Summary ("{0} Dev result status is compatible with a separate QA signoff." -f ($DevStatus.Substring(0, 1).ToUpperInvariant() + $DevStatus.Substring(1))) -EvidenceRefs @($DevResultRef)),
        (New-QaCheck -CheckId "completed_dev_result_has_evidence_refs" -Summary "Completed Dev result carries source evidence refs." -EvidenceRefs @($DevEvidenceRefs)),
        (New-QaCheck -CheckId "changed_files_inside_dispatch_allowed_paths" -Summary "Changed files remain inside dispatch allowed paths." -EvidenceRefs @($DevResultRef)),
        (New-QaCheck -CheckId "produced_artifacts_inside_dispatch_allowed_paths" -Summary "Produced artifacts remain inside dispatch allowed paths." -EvidenceRefs @($DevResultRef)),
        (New-QaCheck -CheckId "dev_result_no_qa_authority" -Summary "Dev result does not claim QA authority." -EvidenceRefs @($DevResultRef)),
        (New-QaCheck -CheckId "dev_result_no_qa_verdict" -Summary "Dev result does not claim a QA verdict." -EvidenceRefs @($DevResultRef)),
        (New-QaCheck -CheckId "dev_result_no_complete_controlled_cycle_claim" -Summary "Dev result does not claim complete controlled cycle execution." -EvidenceRefs @($DevResultRef)),
        (New-QaCheck -CheckId "dev_result_no_successor_milestone_claim" -Summary "Dev result does not claim a successor milestone." -EvidenceRefs @($DevResultRef)),
        (New-QaCheck -CheckId "qa_actor_independent_or_boundary_explicit" -Summary $(if ($ActorDistinct) { "QA actor is distinct from executor identity." } else { "Same technical runner boundary explicitly rejects executor self-certification." }) -EvidenceRefs @($DevResultRef)),
        (New-QaCheck -CheckId "qa_consumes_dev_evidence_refs" -Summary "QA signoff consumes Dev evidence refs as source evidence." -EvidenceRefs @($DevEvidenceRefs))
    )

    foreach ($check in $checks) {
        $PSCmdlet.WriteObject($check)
    }
}

function Assert-QaChecks {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        $GateContract,
        [Parameter(Mandatory = $true)]
        $SignoffContract,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $checks = Assert-ObjectArrayValue -Value $Value -Context $Context
    $seenCheckIds = @()
    foreach ($check in $checks) {
        Assert-RequiredObjectFields -Object $check -FieldNames @($SignoffContract.qa_check_required_fields) -Context "$Context item"
        $checkId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $check -Name "check_id" -Context "$Context item") -Context "$Context.check_id"
        if ($seenCheckIds -contains $checkId) {
            throw "$Context contains duplicate check_id '$checkId'."
        }

        $seenCheckIds += $checkId
        $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $check -Name "status" -Context "$Context item") -Context "$Context.status"
        Assert-AllowedValue -Value $status -AllowedValues @($SignoffContract.qa_check_allowed_statuses) -Context "$Context.status"
        $summary = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $check -Name "summary" -Context "$Context item") -Context "$Context.summary"
        $evidenceRefs = Assert-RepoRefArrayValue -Value (Get-RequiredProperty -Object $check -Name "evidence_refs" -Context "$Context item") -Foundation $Foundation -Context "$Context.evidence_refs"
        $refusalReasons = Assert-StringArrayValue -Value (Get-RequiredProperty -Object $check -Name "refusal_reasons" -Context "$Context item") -Context "$Context.refusal_reasons" -AllowEmpty
        Assert-NoForbiddenPositiveClaim -Value @($summary, $refusalReasons) -Context "$Context item"
        $null = $evidenceRefs
    }

    foreach ($requiredCheckId in @($GateContract.required_checks)) {
        if ($seenCheckIds -notcontains $requiredCheckId) {
            throw "$Context must include required check '$requiredCheckId'."
        }
    }

    $PSCmdlet.WriteObject($checks, $false)
}

function Assert-SourceEvidenceRefsConsumeDevEvidence {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$SourceEvidenceRefs,
        [Parameter(Mandatory = $true)]
        [object[]]$DevEvidenceRefs
    )

    $sourceEvidenceRefValues = @(ConvertTo-FlatStringArray -Values $SourceEvidenceRefs)
    $devEvidenceRefValues = @(ConvertTo-FlatStringArray -Values $DevEvidenceRefs)

    if ($sourceEvidenceRefValues.Count -eq 0) {
        throw "QA signoff source_evidence_refs must not be empty."
    }

    if ($devEvidenceRefValues.Count -eq 0) {
        throw "Dev result evidence refs must not be empty for QA signoff."
    }

    foreach ($devEvidenceRef in @($devEvidenceRefValues)) {
        if ($sourceEvidenceRefValues -notcontains $devEvidenceRef) {
            throw "QA signoff source_evidence_refs must consume Dev evidence ref '$devEvidenceRef'."
        }
    }

    foreach ($sourceRef in @($sourceEvidenceRefValues)) {
        if ($sourceRef -match '(?i)(executor[_ -]?narration|self[_ -]?certification|narration[_ -]?only)') {
            throw "QA signoff must not accept executor narration as proof."
        }
    }
}

function Get-ValidatedSourcePackets {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$DispatchPath,
        [Parameter(Mandatory = $true)]
        [string]$DevResultPath
    )

    $resolvedDispatchPath = Resolve-ExistingPath -PathValue $DispatchPath -Label "Dev dispatch packet"
    $resolvedDevResultPath = Resolve-ExistingPath -PathValue $DevResultPath -Label "Dev result packet"
    & $script:TestDevDispatchPacketContract -DispatchPath $resolvedDispatchPath | Out-Null
    & $script:TestDevExecutionResultPacketContract -ResultPath $resolvedDevResultPath -DispatchPath $resolvedDispatchPath | Out-Null
    $dispatchPacket = Get-JsonDocument -Path $resolvedDispatchPath -Label "Dev dispatch packet"
    $devResultPacket = Get-JsonDocument -Path $resolvedDevResultPath -Label "Dev result packet"

    $PSCmdlet.WriteObject([pscustomobject]@{
        DispatchPath = $resolvedDispatchPath
        DevResultPath = $resolvedDevResultPath
        DispatchPacket = $dispatchPacket
        DevResultPacket = $devResultPacket
    }, $false)
}

function Get-DefaultQaVerdict {
    param(
        [Parameter(Mandatory = $true)]
        [string]$DevStatus
    )

    switch ($DevStatus) {
        "completed" { return "passed" }
        "failed" { return "failed" }
        "blocked" { return "blocked" }
        default { throw "Dev result status '$DevStatus' is not compatible with QA." }
    }
}

function Test-CycleQaSignoffPacketObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $SignoffPacket,
        [AllowNull()]
        $DispatchPacket,
        [AllowNull()]
        $DevResultPacket,
        [string]$SourceLabel = "Cycle QA signoff packet"
    )

    $foundation = Get-CycleControllerFoundationContract
    $gateContract = Get-CycleQaGateContract
    $contract = Get-CycleQaSignoffPacketContract
    Assert-RequiredObjectFields -Object $SignoffPacket -FieldNames @($contract.required_fields) -Context $SourceLabel

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $SignoffPacket -Name "contract_version" -Context $SourceLabel) -Context "$SourceLabel.contract_version"
    if ($contractVersion -ne $foundation.contract_version -or $contractVersion -ne $contract.contract_version) {
        throw "$SourceLabel.contract_version must match the cycle controller contract version."
    }

    $artifactType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $SignoffPacket -Name "artifact_type" -Context $SourceLabel) -Context "$SourceLabel.artifact_type"
    if ($artifactType -ne $contract.signoff_artifact_type) {
        throw "$SourceLabel.artifact_type must be '$($contract.signoff_artifact_type)'."
    }

    $qaSignoffId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $SignoffPacket -Name "qa_signoff_id" -Context $SourceLabel) -Context "$SourceLabel.qa_signoff_id"
    Assert-MatchesPattern -Value $qaSignoffId -Pattern $foundation.identifier_pattern -Context "$SourceLabel.qa_signoff_id"
    $repository = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $SignoffPacket -Name "repository" -Context $SourceLabel) -Context "$SourceLabel.repository"
    $branch = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $SignoffPacket -Name "branch" -Context $SourceLabel) -Context "$SourceLabel.branch"
    $milestone = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $SignoffPacket -Name "milestone" -Context $SourceLabel) -Context "$SourceLabel.milestone"
    if ($repository -ne $foundation.repository -or $branch -ne $foundation.branch -or $milestone -ne $foundation.milestone) {
        throw "$SourceLabel repository, branch, and milestone must match cycle controller foundation truth."
    }

    $sourceTask = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $SignoffPacket -Name "source_task" -Context $SourceLabel) -Context "$SourceLabel.source_task"
    if ($sourceTask -ne $contract.source_task) {
        throw "$SourceLabel.source_task must be '$($contract.source_task)'."
    }

    $cycleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $SignoffPacket -Name "cycle_id" -Context $SourceLabel) -Context "$SourceLabel.cycle_id"
    Assert-MatchesPattern -Value $cycleId -Pattern $foundation.identifier_pattern -Context "$SourceLabel.cycle_id"
    $cycleLedgerRef = Assert-RepoRefValue -Value (Get-RequiredProperty -Object $SignoffPacket -Name "cycle_ledger_ref" -Context $SourceLabel) -Foundation $foundation -Context "$SourceLabel.cycle_ledger_ref"
    $dispatchRef = Assert-RepoRefValue -Value (Get-RequiredProperty -Object $SignoffPacket -Name "dispatch_ref" -Context $SourceLabel) -Foundation $foundation -Context "$SourceLabel.dispatch_ref"
    $devResultRef = Assert-RepoRefValue -Value (Get-RequiredProperty -Object $SignoffPacket -Name "dev_result_ref" -Context $SourceLabel) -Foundation $foundation -Context "$SourceLabel.dev_result_ref"

    $qaActorIdentity = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $SignoffPacket -Name "qa_actor_identity" -Context $SourceLabel) -Context "$SourceLabel.qa_actor_identity"
    $qaActorKind = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $SignoffPacket -Name "qa_actor_kind" -Context $SourceLabel) -Context "$SourceLabel.qa_actor_kind"
    Assert-AllowedValue -Value $qaActorKind -AllowedValues @($contract.allowed_qa_actor_kinds) -Context "$SourceLabel.qa_actor_kind"
    $qaAuthorityType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $SignoffPacket -Name "qa_authority_type" -Context $SourceLabel) -Context "$SourceLabel.qa_authority_type"
    Assert-AllowedValue -Value $qaAuthorityType -AllowedValues @($contract.allowed_qa_authority_types) -Context "$SourceLabel.qa_authority_type"
    $qaIndependenceBoundary = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $SignoffPacket -Name "qa_independence_boundary" -Context $SourceLabel) -Context "$SourceLabel.qa_independence_boundary"

    $sourceEvidenceRefs = Assert-RepoRefArrayValue -Value (Get-RequiredProperty -Object $SignoffPacket -Name "source_evidence_refs" -Context $SourceLabel) -Foundation $foundation -Context "$SourceLabel.source_evidence_refs"
    $qaChecks = Assert-QaChecks -Value (Get-RequiredProperty -Object $SignoffPacket -Name "qa_checks" -Context $SourceLabel) -GateContract $gateContract -SignoffContract $contract -Foundation $foundation -Context "$SourceLabel.qa_checks"
    $qaVerdict = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $SignoffPacket -Name "qa_verdict" -Context $SourceLabel) -Context "$SourceLabel.qa_verdict"
    Assert-AllowedValue -Value $qaVerdict -AllowedValues @($contract.allowed_verdicts) -Context "$SourceLabel.qa_verdict"
    $qaFindings = Assert-StringArrayValue -Value (Get-RequiredProperty -Object $SignoffPacket -Name "qa_findings" -Context $SourceLabel) -Context "$SourceLabel.qa_findings" -AllowEmpty
    $requiredFollowups = Assert-StringArrayValue -Value (Get-RequiredProperty -Object $SignoffPacket -Name "required_followups" -Context $SourceLabel) -Context "$SourceLabel.required_followups" -AllowEmpty

    $headSha = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $SignoffPacket -Name "head_sha" -Context $SourceLabel) -Context "$SourceLabel.head_sha"
    $treeSha = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $SignoffPacket -Name "tree_sha" -Context $SourceLabel) -Context "$SourceLabel.tree_sha"
    Assert-MatchesPattern -Value $headSha -Pattern $foundation.git_sha_pattern -Context "$SourceLabel.head_sha"
    Assert-MatchesPattern -Value $treeSha -Pattern $foundation.git_sha_pattern -Context "$SourceLabel.tree_sha"
    $createdAtUtc = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $SignoffPacket -Name "created_at_utc" -Context $SourceLabel) -Context "$SourceLabel.created_at_utc"
    Assert-TimestampValue -Value $createdAtUtc -Pattern $foundation.timestamp_pattern -Context "$SourceLabel.created_at_utc"
    $refusalReasons = Assert-StringArrayValue -Value (Get-RequiredProperty -Object $SignoffPacket -Name "refusal_reasons" -Context $SourceLabel) -Context "$SourceLabel.refusal_reasons" -AllowEmpty
    $nonClaims = Assert-RequiredNonClaims -Value (Get-RequiredProperty -Object $SignoffPacket -Name "non_claims" -Context $SourceLabel) -RequiredNonClaims @($contract.required_non_claims) -Context "$SourceLabel.non_claims"

    Assert-NoForbiddenPositiveClaim -Value @($qaActorIdentity, $qaActorKind, $qaAuthorityType, $qaIndependenceBoundary, $qaFindings, $requiredFollowups, $refusalReasons) -Context $SourceLabel
    foreach ($check in @($qaChecks)) {
        Assert-NoForbiddenPositiveClaim -Value @($check.summary, $check.refusal_reasons) -Context "$SourceLabel.qa_checks"
    }

    if ($null -ne $DispatchPacket) {
        foreach ($entry in @(
                @{ Name = "repository"; Expected = $repository },
                @{ Name = "branch"; Expected = $branch },
                @{ Name = "milestone"; Expected = $milestone },
                @{ Name = "cycle_id"; Expected = $cycleId },
                @{ Name = "cycle_ledger_ref"; Expected = $cycleLedgerRef }
            )) {
            if ([string]$DispatchPacket.PSObject.Properties[$entry.Name].Value -ne [string]$entry.Expected) {
                throw "$SourceLabel.$($entry.Name) does not match the dispatch packet."
            }
        }
    }

    if ($null -ne $DevResultPacket) {
        foreach ($entry in @(
                @{ Name = "repository"; Expected = $repository },
                @{ Name = "branch"; Expected = $branch },
                @{ Name = "milestone"; Expected = $milestone },
                @{ Name = "cycle_id"; Expected = $cycleId },
                @{ Name = "cycle_ledger_ref"; Expected = $cycleLedgerRef }
            )) {
            if ([string]$DevResultPacket.PSObject.Properties[$entry.Name].Value -ne [string]$entry.Expected) {
                throw "$SourceLabel.$($entry.Name) does not match the Dev result packet."
            }
        }

        if ($headSha -ne [string]$DevResultPacket.head_after -or $treeSha -ne [string]$DevResultPacket.tree_after) {
            throw "$SourceLabel head_sha/tree_sha must match the Dev result head_after/tree_after."
        }

        Assert-IndependenceBoundary -QaActorIdentity $qaActorIdentity -ExecutorIdentity ([string]$DevResultPacket.executor_identity) -QaIndependenceBoundary $qaIndependenceBoundary
        $devEvidenceRefs = @(Get-DevEvidenceRefs -DevResult $DevResultPacket)
        Assert-SourceEvidenceRefsConsumeDevEvidence -SourceEvidenceRefs @($sourceEvidenceRefs) -DevEvidenceRefs @($devEvidenceRefs)
    }

    $result = [pscustomobject][ordered]@{
        IsValid = $true
        QaSignoffId = $qaSignoffId
        CycleId = $cycleId
        DispatchRef = $dispatchRef
        DevResultRef = $devResultRef
        QaVerdict = $qaVerdict
        QaActorIdentity = $qaActorIdentity
        QaActorKind = $qaActorKind
        QaAuthorityType = $qaAuthorityType
        SourceEvidenceRefs = @($sourceEvidenceRefs)
        QaCheckCount = @($qaChecks).Count
        HeadSha = $headSha
        TreeSha = $treeSha
        NonClaims = @($nonClaims)
        SourceLabel = $SourceLabel
    }

    $PSCmdlet.WriteObject($result, $false)
}

function Test-CycleQaSignoffPacketContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SignoffPath,
        [string]$DispatchPath,
        [string]$DevResultPath
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $SignoffPath -Label "Cycle QA signoff packet"
    $signoffPacket = Get-JsonDocument -Path $resolvedPath -Label "Cycle QA signoff packet"
    $dispatchPacket = $null
    $devResultPacket = $null
    if (-not [string]::IsNullOrWhiteSpace($DispatchPath) -or -not [string]::IsNullOrWhiteSpace($DevResultPath)) {
        if ([string]::IsNullOrWhiteSpace($DispatchPath) -or [string]::IsNullOrWhiteSpace($DevResultPath)) {
            throw "Both DispatchPath and DevResultPath are required when source packet validation is requested."
        }

        $sourcePackets = Get-ValidatedSourcePackets -DispatchPath $DispatchPath -DevResultPath $DevResultPath
        $dispatchPacket = $sourcePackets.DispatchPacket
        $devResultPacket = $sourcePackets.DevResultPacket
    }

    $validation = Test-CycleQaSignoffPacketObject -SignoffPacket $signoffPacket -DispatchPacket $dispatchPacket -DevResultPacket $devResultPacket -SourceLabel "Cycle QA signoff packet"
    $PSCmdlet.WriteObject($validation, $false)
}

function New-CycleQaSignoffPacket {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$DispatchPath,
        [Parameter(Mandatory = $true)]
        [string]$DevResultPath,
        [Parameter(Mandatory = $true)]
        [string]$QaActorIdentity,
        [Parameter(Mandatory = $true)]
        [string]$QaActorKind,
        [Parameter(Mandatory = $true)]
        [string]$QaAuthorityType,
        [string]$QaIndependenceBoundary,
        [string]$QaVerdict,
        [string[]]$QaFindings,
        [string[]]$RequiredFollowups,
        [string[]]$SourceEvidenceRefs,
        [string[]]$RefusalReasons,
        [string]$OutputPath,
        [switch]$Overwrite
    )

    $foundation = Get-CycleControllerFoundationContract
    $gateContract = Get-CycleQaGateContract
    $contract = Get-CycleQaSignoffPacketContract
    $sourcePackets = Get-ValidatedSourcePackets -DispatchPath $DispatchPath -DevResultPath $DevResultPath
    $dispatchPacket = $sourcePackets.DispatchPacket
    $devResultPacket = $sourcePackets.DevResultPacket
    $dispatchRef = ConvertTo-RepositoryPath -Path $sourcePackets.DispatchPath -RepositoryRoot (Get-ModuleRepositoryRootPath)
    $devResultRef = ConvertTo-RepositoryPath -Path $sourcePackets.DevResultPath -RepositoryRoot (Get-ModuleRepositoryRootPath)

    Assert-DevResultHasNoQaFields -DevResult $devResultPacket -Context "Dev result packet"
    Assert-DevResultTextHasNoQaClaims -DevResult $devResultPacket
    $devStatus = Assert-NonEmptyString -Value $devResultPacket.status -Context "Dev result status"
    Assert-DevStatusCompatibleWithQa -Status $devStatus -GateContract $gateContract
    $devEvidenceRefs = @(Get-DevEvidenceRefs -DevResult $devResultPacket)
    if ($devStatus -eq "completed" -and $devEvidenceRefs.Count -eq 0) {
        throw "Dev result evidence refs must not be empty for completed results."
    }

    $qaActorIdentityValue = Assert-NonEmptyString -Value $QaActorIdentity -Context "QA actor identity"
    $qaActorKindValue = Assert-NonEmptyString -Value $QaActorKind -Context "QA actor kind"
    Assert-AllowedValue -Value $qaActorKindValue -AllowedValues @($contract.allowed_qa_actor_kinds) -Context "QA actor kind"
    $qaAuthorityTypeValue = Assert-NonEmptyString -Value $QaAuthorityType -Context "QA authority type"
    Assert-AllowedValue -Value $qaAuthorityTypeValue -AllowedValues @($contract.allowed_qa_authority_types) -Context "QA authority type"
    $boundaryValue = if ([string]::IsNullOrWhiteSpace($QaIndependenceBoundary)) {
        if ($qaActorIdentityValue -eq [string]$devResultPacket.executor_identity) {
            throw "QA actor identity matches executor identity; qa_independence_boundary must explicitly state why executor self-certification is not being accepted."
        }

        "QA actor identity is distinct from Dev executor identity; Dev result is source evidence only and is not accepted as QA authority."
    }
    else {
        $QaIndependenceBoundary
    }
    Assert-IndependenceBoundary -QaActorIdentity $qaActorIdentityValue -ExecutorIdentity ([string]$devResultPacket.executor_identity) -QaIndependenceBoundary $boundaryValue

    $sourceEvidenceRefValues = if ($PSBoundParameters.ContainsKey("SourceEvidenceRefs")) {
        @(Get-UniqueStringValues -Values @($SourceEvidenceRefs))
    }
    else {
        @(Get-UniqueStringValues -Values @($devEvidenceRefs))
    }
    foreach ($sourceEvidenceRef in @($sourceEvidenceRefValues)) {
        Assert-RepoRefValue -Value $sourceEvidenceRef -Foundation $foundation -Context "QA source_evidence_refs" | Out-Null
    }
    Assert-SourceEvidenceRefsConsumeDevEvidence -SourceEvidenceRefs @($sourceEvidenceRefValues) -DevEvidenceRefs @($devEvidenceRefs)

    $qaVerdictValue = if ([string]::IsNullOrWhiteSpace($QaVerdict)) { Get-DefaultQaVerdict -DevStatus $devStatus } else { $QaVerdict }
    Assert-AllowedValue -Value $qaVerdictValue -AllowedValues @($contract.allowed_verdicts) -Context "QA verdict"
    $qaFindingValues = if ($null -eq $QaFindings) { @() } else { @(Assert-StringArrayValue -Value $QaFindings -Context "QA findings" -AllowEmpty) }
    $requiredFollowupValues = if ($null -eq $RequiredFollowups) { @() } else { @(Assert-StringArrayValue -Value $RequiredFollowups -Context "Required followups" -AllowEmpty) }
    $refusalReasonValues = if ($null -eq $RefusalReasons) { @() } else { @(Assert-StringArrayValue -Value $RefusalReasons -Context "QA refusal reasons" -AllowEmpty) }
    Assert-NoForbiddenPositiveClaim -Value @($qaFindingValues, $requiredFollowupValues, $refusalReasonValues) -Context "QA signoff input"

    $actorDistinct = ($qaActorIdentityValue -ne [string]$devResultPacket.executor_identity)
    $qaChecks = New-DefaultQaChecks -DispatchRef $dispatchRef -DevResultRef $devResultRef -DevEvidenceRefs @($devEvidenceRefs) -DevStatus $devStatus -ActorDistinct:$actorDistinct

    $packet = [pscustomobject][ordered]@{
        contract_version = $foundation.contract_version
        artifact_type = $contract.signoff_artifact_type
        qa_signoff_id = New-QaSignoffId
        repository = $dispatchPacket.repository
        branch = $dispatchPacket.branch
        milestone = $dispatchPacket.milestone
        source_task = $contract.source_task
        cycle_id = $dispatchPacket.cycle_id
        cycle_ledger_ref = $dispatchPacket.cycle_ledger_ref
        dispatch_ref = $dispatchRef
        dev_result_ref = $devResultRef
        qa_actor_identity = $qaActorIdentityValue
        qa_actor_kind = $qaActorKindValue
        qa_authority_type = $qaAuthorityTypeValue
        qa_independence_boundary = $boundaryValue
        source_evidence_refs = @($sourceEvidenceRefValues)
        qa_checks = @($qaChecks)
        qa_verdict = $qaVerdictValue
        qa_findings = @($qaFindingValues)
        required_followups = @($requiredFollowupValues)
        head_sha = $devResultPacket.head_after
        tree_sha = $devResultPacket.tree_after
        created_at_utc = Get-UtcTimestamp
        refusal_reasons = @($refusalReasonValues)
        non_claims = @($contract.required_non_claims)
    }

    Test-CycleQaSignoffPacketObject -SignoffPacket $packet -DispatchPacket $dispatchPacket -DevResultPacket $devResultPacket -SourceLabel "Cycle QA signoff packet draft" | Out-Null

    if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
        $resolvedOutputPath = Resolve-PathValue -PathValue $OutputPath
        Write-JsonDocument -Path $resolvedOutputPath -Document $packet -Overwrite:$Overwrite
        Test-CycleQaSignoffPacketContract -SignoffPath $resolvedOutputPath -DispatchPath $sourcePackets.DispatchPath -DevResultPath $sourcePackets.DevResultPath | Out-Null
    }

    $PSCmdlet.WriteObject($packet, $false)
}

function Inspect-CycleQaSignoffPacket {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SignoffPath,
        [string]$DispatchPath,
        [string]$DevResultPath
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $SignoffPath -Label "Cycle QA signoff packet"
    $validation = if ([string]::IsNullOrWhiteSpace($DispatchPath) -and [string]::IsNullOrWhiteSpace($DevResultPath)) {
        Test-CycleQaSignoffPacketContract -SignoffPath $resolvedPath
    }
    else {
        Test-CycleQaSignoffPacketContract -SignoffPath $resolvedPath -DispatchPath $DispatchPath -DevResultPath $DevResultPath
    }

    return [pscustomobject][ordered]@{
        ArtifactType = "cycle_qa_signoff_summary"
        SignoffPath = $resolvedPath
        QaSignoffId = $validation.QaSignoffId
        CycleId = $validation.CycleId
        DispatchRef = $validation.DispatchRef
        DevResultRef = $validation.DevResultRef
        QaVerdict = $validation.QaVerdict
        QaActorIdentity = $validation.QaActorIdentity
        QaActorKind = $validation.QaActorKind
        QaAuthorityType = $validation.QaAuthorityType
        SourceEvidenceRefCount = @($validation.SourceEvidenceRefs).Count
        QaCheckCount = $validation.QaCheckCount
        HeadSha = $validation.HeadSha
        TreeSha = $validation.TreeSha
        NonClaims = @($validation.NonClaims)
    }
}

Export-ModuleMember -Function New-CycleQaSignoffPacket, Test-CycleQaSignoffPacketContract, Test-CycleQaSignoffPacketObject, Inspect-CycleQaSignoffPacket
