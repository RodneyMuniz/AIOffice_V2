Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$jsonRootModule = Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force -PassThru
$cycleLedgerModule = Import-Module (Join-Path $PSScriptRoot "CycleLedger.psm1") -Force -PassThru
$script:ReadSingleJsonObject = $jsonRootModule.ExportedCommands["Read-SingleJsonObject"]
$script:TestCycleLedgerContract = $cycleLedgerModule.ExportedCommands["Test-CycleLedgerContract"]
$script:GetCycleLedger = $cycleLedgerModule.ExportedCommands["Get-CycleLedger"]

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

function Test-PathUnderRoot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Root
    )

    $fullPath = [System.IO.Path]::GetFullPath($Path)
    $fullRoot = [System.IO.Path]::GetFullPath($Root).TrimEnd([char[]]@([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar))
    if ($fullPath.Equals($fullRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $true
    }

    $rootWithSeparator = $fullRoot + [System.IO.Path]::DirectorySeparatorChar
    return $fullPath.StartsWith($rootWithSeparator, [System.StringComparison]::OrdinalIgnoreCase)
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
        throw "Dev adapter evidence paths must not point at the repository root."
    }

    $rootWithSeparator = $fullRoot + [System.IO.Path]::DirectorySeparatorChar
    if (-not $fullPath.StartsWith($rootWithSeparator, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Dev adapter path '$Path' escapes repository root."
    }

    return $fullPath.Substring($rootWithSeparator.Length).Replace("\", "/").TrimEnd("/")
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

function Get-CycleControllerFoundationContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "cycle_controller", "foundation.contract.json")) -Label "Cycle controller foundation contract"
}

function Get-DevDispatchPacketContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "cycle_controller", "dev_dispatch_packet.contract.json")) -Label "Dev dispatch packet contract"
}

function Get-DevExecutionResultPacketContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "cycle_controller", "dev_execution_result_packet.contract.json")) -Label "Dev execution result packet contract"
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

function Assert-IntegerValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [int]$Minimum = 1
    )

    if (-not ($Value -is [int] -or $Value -is [long])) {
        throw "$Context must be an integer."
    }

    $integerValue = [int64]$Value
    if ($integerValue -lt $Minimum) {
        throw "$Context must be at least $Minimum."
    }

    return $integerValue
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
        [string]$Context,
        [switch]$AllowEmpty
    )

    if ($Value -isnot [string]) {
        throw "$Context must be a string."
    }

    if ([string]::IsNullOrWhiteSpace($Value)) {
        if ($AllowEmpty) {
            return ""
        }

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

function New-AdapterId {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Prefix
    )

    return ("{0}-{1}" -f $Prefix, [guid]::NewGuid().ToString("N").Substring(0, 12))
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
            throw "Dev adapter output '$Path' already exists. Use -Overwrite to replace it explicitly."
        }
    }

    $parentPath = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($parentPath)) {
        New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    }

    $Document | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Get-UniqueStringValues {
    [CmdletBinding()]
    param(
        [AllowEmptyCollection()]
        [string[]]$Values
    )

    $items = @()
    foreach ($value in @($Values)) {
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

    return ($Line -match '(?i)\b(no|not|without|never|cannot|must not|does not|do not|is not|are not|refuse|reject|non-claim|nonclaims|non-scope|only source evidence|not QA|not evidence|not proof|does not prove|does not claim)\b')
}

function Assert-NoForbiddenDevClaim {
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
        @{ Label = "QA authority"; Pattern = '(?i)\bQA\b.{0,100}\b(authority|verdict|pass|passed|approved|approval|signoff|certif|validated|complete)\b|\b(self-certif(?:y|ies|ication)|executor)\b.{0,100}\bQA\b' },
        @{ Label = "complete controlled cycle"; Pattern = '(?i)\bcomplete controlled cycle\b.{0,120}\b(ran|run|executed|complete|completed|closed|accepted|done|proven)\b|\bcycle\b.{0,80}\b(complete|completed|closed|accepted)\b' },
        @{ Label = "successor milestone"; Pattern = '(?i)\bR12\b.*\b(active|open|opened|complete|closed)\b|\bsuccessor milestone\b.*\b(active|open|opened|complete|closed)\b' },
        @{ Label = "broad autonomous milestone execution"; Pattern = '(?i)\bbroad autonomous milestone execution\b|\bbroad autonomy\b' },
        @{ Label = "UI/control-room productization"; Pattern = '(?i)\bUI/control-room productization\b|\bcontrol-room productization\b|\bproductized control-room\b' },
        @{ Label = "Standard runtime"; Pattern = '(?i)\bStandard runtime\b' },
        @{ Label = "multi-repo orchestration"; Pattern = '(?i)\bmulti-repo orchestration\b' },
        @{ Label = "swarms"; Pattern = '(?i)\bswarms\b|\bfleet execution\b' },
        @{ Label = "unattended automatic resume"; Pattern = '(?i)\bunattended automatic resume\b' },
        @{ Label = "solved Codex context compaction"; Pattern = '(?i)\bsolved Codex context compaction\b|\bCodex context compaction is solved\b' },
        @{ Label = "hours-long unattended execution"; Pattern = '(?i)\bhours-long unattended\b' },
        @{ Label = "production runtime"; Pattern = '(?i)\bproduction runtime\b' },
        @{ Label = "general Codex reliability"; Pattern = '(?i)\bgeneral Codex reliability\b' },
        @{ Label = "real Dev execution"; Pattern = '(?i)\breal Dev execution\b.{0,100}\b(ran|run|executed|complete|completed|proven|proof)\b|\bDev execution\b.{0,100}\b(ran|run|executed)\b' }
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

function Assert-BoundedPathValue {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $pathValue = Assert-NonEmptyString -Value $Value -Context $Context
    if ([System.IO.Path]::IsPathRooted($pathValue)) {
        throw "$Context must be repo-relative and bounded."
    }

    $normalized = $pathValue.Replace("\", "/").Trim()
    $trimmed = $normalized.Trim("/")
    foreach ($pattern in @($Contract.unsafe_path_patterns)) {
        if ($trimmed -match $pattern) {
            throw "$Context '$pathValue' is unbounded or unsafe."
        }
    }

    $segments = @($trimmed -split "/" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    if ($segments.Count -eq 0) {
        throw "$Context '$pathValue' is unbounded or unsafe."
    }

    foreach ($segment in $segments) {
        if ($segment -eq ".." -or $segment -eq ".git") {
            throw "$Context '$pathValue' is unbounded or unsafe."
        }
    }

    if ($segments.Count -eq 1 -and @($Contract.broad_root_path_refusals) -contains $segments[0]) {
        throw "$Context '$pathValue' is a broad root-level path and is refused."
    }

    return $trimmed
}

function Assert-BoundedPathArrayValue {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [switch]$AllowEmpty
    )

    $items = Assert-StringArrayValue -Value $Value -Context $Context -AllowEmpty:$AllowEmpty
    $normalizedItems = @()
    foreach ($item in $items) {
        $normalizedItems += (Assert-BoundedPathValue -Value $item -Contract $Contract -Context "$Context item")
    }

    $PSCmdlet.WriteObject($normalizedItems, $false)
}

function Test-PathWithinAllowedPaths {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [Parameter(Mandatory = $true)]
        [string[]]$AllowedPaths
    )

    $normalized = $PathValue.Replace("\", "/").Trim().Trim("/")
    foreach ($allowedPath in @($AllowedPaths)) {
        $allowed = $allowedPath.Replace("\", "/").Trim().Trim("/")
        if ($normalized.Equals($allowed, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }

        $allowedPrefix = $allowed.TrimEnd("/") + "/"
        if ($normalized.StartsWith($allowedPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }

    return $false
}

function Assert-PathsWithinDispatchScope {
    param(
        [AllowEmptyCollection()]
        [string[]]$Paths,
        [Parameter(Mandatory = $true)]
        [string[]]$AllowedPaths,
        [Parameter(Mandatory = $true)]
        $DispatchContract,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($path in @($Paths)) {
        $normalized = Assert-BoundedPathValue -Value $path -Contract $DispatchContract -Context "$Context item"
        if (-not (Test-PathWithinAllowedPaths -PathValue $normalized -AllowedPaths $AllowedPaths)) {
            throw "$Context item '$path' is outside the dispatch allowed paths."
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

    Assert-NoForbiddenDevClaim -Value $nonClaims -Context $Context
    return $nonClaims
}

function Assert-CommonIdentityFields {
    param(
        [Parameter(Mandatory = $true)]
        $Packet,
        [Parameter(Mandatory = $true)]
        [string]$ExpectedArtifactType,
        [Parameter(Mandatory = $true)]
        $Contract,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        [string]$SourceLabel
    )

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet -Name "contract_version" -Context $SourceLabel) -Context "$SourceLabel.contract_version"
    if ($contractVersion -ne $Foundation.contract_version -or $contractVersion -ne $Contract.contract_version) {
        throw "$SourceLabel.contract_version must be '$($Foundation.contract_version)'."
    }

    $artifactType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet -Name "artifact_type" -Context $SourceLabel) -Context "$SourceLabel.artifact_type"
    if ($artifactType -ne $ExpectedArtifactType) {
        throw "$SourceLabel.artifact_type must be '$ExpectedArtifactType'."
    }

    $repository = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet -Name "repository" -Context $SourceLabel) -Context "$SourceLabel.repository"
    if ($repository -ne $Foundation.repository) {
        throw "$SourceLabel.repository must be '$($Foundation.repository)'."
    }

    $branch = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet -Name "branch" -Context $SourceLabel) -Context "$SourceLabel.branch"
    if ($branch -ne $Foundation.branch) {
        throw "$SourceLabel.branch must be '$($Foundation.branch)'."
    }

    $milestone = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet -Name "milestone" -Context $SourceLabel) -Context "$SourceLabel.milestone"
    if ($milestone -ne $Foundation.milestone) {
        throw "$SourceLabel.milestone must be '$($Foundation.milestone)'."
    }

    $sourceTask = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet -Name "source_task" -Context $SourceLabel) -Context "$SourceLabel.source_task"
    if ($sourceTask -ne $Contract.source_task) {
        throw "$SourceLabel.source_task must be '$($Contract.source_task)'."
    }
}

function Test-DevTaskPacketObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $TaskPacket,
        [Parameter(Mandatory = $true)]
        $DispatchContract,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        [string]$SourceLabel
    )

    Assert-RequiredObjectFields -Object $TaskPacket -FieldNames @($DispatchContract.task_packet_required_fields) -Context $SourceLabel
    $taskId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $TaskPacket -Name "task_id" -Context $SourceLabel) -Context "$SourceLabel.task_id"
    Assert-MatchesPattern -Value $taskId -Pattern $Foundation.identifier_pattern -Context "$SourceLabel.task_id"
    $taskTitle = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $TaskPacket -Name "task_title" -Context $SourceLabel) -Context "$SourceLabel.task_title"
    $taskObjective = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $TaskPacket -Name "task_objective" -Context $SourceLabel) -Context "$SourceLabel.task_objective"
    $boundedScope = Assert-StringArrayValue -Value (Get-RequiredProperty -Object $TaskPacket -Name "bounded_scope" -Context $SourceLabel) -Context "$SourceLabel.bounded_scope"
    $allowedPaths = Assert-BoundedPathArrayValue -Value (Get-RequiredProperty -Object $TaskPacket -Name "allowed_paths" -Context $SourceLabel) -Contract $DispatchContract -Context "$SourceLabel.allowed_paths"
    $forbiddenPaths = Assert-BoundedPathArrayValue -Value (Get-RequiredProperty -Object $TaskPacket -Name "forbidden_paths" -Context $SourceLabel) -Contract $DispatchContract -Context "$SourceLabel.forbidden_paths"
    $expectedOutputs = Assert-StringArrayValue -Value (Get-RequiredProperty -Object $TaskPacket -Name "expected_outputs" -Context $SourceLabel) -Context "$SourceLabel.expected_outputs"
    $acceptanceChecks = Assert-StringArrayValue -Value (Get-RequiredProperty -Object $TaskPacket -Name "acceptance_checks" -Context $SourceLabel) -Context "$SourceLabel.acceptance_checks"
    $evidenceRequired = Assert-StringArrayValue -Value (Get-RequiredProperty -Object $TaskPacket -Name "evidence_required" -Context $SourceLabel) -Context "$SourceLabel.evidence_required"
    $maxAttempts = Assert-IntegerValue -Value (Get-RequiredProperty -Object $TaskPacket -Name "max_attempts" -Context $SourceLabel) -Context "$SourceLabel.max_attempts" -Minimum 1
    $contextBudget = Assert-ObjectValue -Value (Get-RequiredProperty -Object $TaskPacket -Name "context_budget" -Context $SourceLabel) -Context "$SourceLabel.context_budget"
    Assert-RequiredObjectFields -Object $contextBudget -FieldNames @($DispatchContract.context_budget_required_fields) -Context "$SourceLabel.context_budget"
    foreach ($budgetField in @($DispatchContract.context_budget_required_fields)) {
        Assert-IntegerValue -Value (Get-RequiredProperty -Object $contextBudget -Name $budgetField -Context "$SourceLabel.context_budget") -Context "$SourceLabel.context_budget.$budgetField" -Minimum 1 | Out-Null
    }
    $nonClaims = Assert-RequiredNonClaims -Value (Get-RequiredProperty -Object $TaskPacket -Name "non_claims" -Context $SourceLabel) -RequiredNonClaims @($DispatchContract.required_non_claims) -Context "$SourceLabel.non_claims"

    Assert-NoForbiddenDevClaim -Value @($taskTitle, $taskObjective, $boundedScope, $expectedOutputs, $acceptanceChecks, $evidenceRequired) -Context $SourceLabel

    $result = [pscustomobject]@{
        TaskId = $taskId
        AllowedPaths = @($allowedPaths)
        ForbiddenPaths = @($forbiddenPaths)
        ExpectedOutputs = @($expectedOutputs)
        EvidenceRequired = @($evidenceRequired)
        MaxAttempts = $maxAttempts
        NonClaims = @($nonClaims)
    }

    $PSCmdlet.WriteObject($result, $false)
}

function Test-DevDispatchPacketObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $DispatchPacket,
        [string]$SourceLabel = "Dev dispatch packet"
    )

    $foundation = Get-CycleControllerFoundationContract
    $contract = Get-DevDispatchPacketContract
    Assert-RequiredObjectFields -Object $DispatchPacket -FieldNames @($contract.required_fields) -Context $SourceLabel
    Assert-CommonIdentityFields -Packet $DispatchPacket -ExpectedArtifactType $contract.dispatch_artifact_type -Contract $contract -Foundation $foundation -SourceLabel $SourceLabel

    $dispatchId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $DispatchPacket -Name "dispatch_id" -Context $SourceLabel) -Context "$SourceLabel.dispatch_id"
    Assert-MatchesPattern -Value $dispatchId -Pattern $foundation.identifier_pattern -Context "$SourceLabel.dispatch_id"
    $cycleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $DispatchPacket -Name "cycle_id" -Context $SourceLabel) -Context "$SourceLabel.cycle_id"
    Assert-MatchesPattern -Value $cycleId -Pattern $foundation.identifier_pattern -Context "$SourceLabel.cycle_id"
    $cycleLedgerRef = Assert-RepoRefValue -Value (Get-RequiredProperty -Object $DispatchPacket -Name "cycle_ledger_ref" -Context $SourceLabel) -Foundation $foundation -Context "$SourceLabel.cycle_ledger_ref"
    $ledgerState = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $DispatchPacket -Name "ledger_state" -Context $SourceLabel) -Context "$SourceLabel.ledger_state"
    Assert-AllowedValue -Value $ledgerState -AllowedValues @($contract.allowed_ledger_states) -Context "$SourceLabel.ledger_state"
    $baselineRef = Assert-RepoRefValue -Value (Get-RequiredProperty -Object $DispatchPacket -Name "baseline_ref" -Context $SourceLabel) -Foundation $foundation -Context "$SourceLabel.baseline_ref"
    $targetExecutor = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $DispatchPacket -Name "target_executor" -Context $SourceLabel) -Context "$SourceLabel.target_executor"
    Assert-NoForbiddenDevClaim -Value $targetExecutor -Context "$SourceLabel.target_executor"

    $taskPackets = Assert-ObjectArrayValue -Value (Get-RequiredProperty -Object $DispatchPacket -Name "task_packets" -Context $SourceLabel) -Context "$SourceLabel.task_packets" -MinimumCount 2
    $taskIds = @()
    foreach ($index in 0..($taskPackets.Count - 1)) {
        $taskValidation = Test-DevTaskPacketObject -TaskPacket $taskPackets[$index] -DispatchContract $contract -Foundation $foundation -SourceLabel "$SourceLabel.task_packets[$index]"
        if ($taskIds -contains $taskValidation.TaskId) {
            throw "$SourceLabel.task_packets contains duplicate task_id '$($taskValidation.TaskId)'."
        }
        $taskIds += $taskValidation.TaskId
    }

    $allowedPaths = Assert-BoundedPathArrayValue -Value (Get-RequiredProperty -Object $DispatchPacket -Name "allowed_paths" -Context $SourceLabel) -Contract $contract -Context "$SourceLabel.allowed_paths"
    $forbiddenPaths = Assert-BoundedPathArrayValue -Value (Get-RequiredProperty -Object $DispatchPacket -Name "forbidden_paths" -Context $SourceLabel) -Contract $contract -Context "$SourceLabel.forbidden_paths"
    $allowedTools = Assert-StringArrayValue -Value (Get-RequiredProperty -Object $DispatchPacket -Name "allowed_tools" -Context $SourceLabel) -Context "$SourceLabel.allowed_tools"
    $forbiddenTools = Assert-StringArrayValue -Value (Get-RequiredProperty -Object $DispatchPacket -Name "forbidden_tools" -Context $SourceLabel) -Context "$SourceLabel.forbidden_tools"
    $expectedOutputs = Assert-StringArrayValue -Value (Get-RequiredProperty -Object $DispatchPacket -Name "expected_outputs" -Context $SourceLabel) -Context "$SourceLabel.expected_outputs"
    $evidenceRequirements = Assert-StringArrayValue -Value (Get-RequiredProperty -Object $DispatchPacket -Name "evidence_requirements" -Context $SourceLabel) -Context "$SourceLabel.evidence_requirements"
    $headSha = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $DispatchPacket -Name "head_sha" -Context $SourceLabel) -Context "$SourceLabel.head_sha"
    $treeSha = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $DispatchPacket -Name "tree_sha" -Context $SourceLabel) -Context "$SourceLabel.tree_sha"
    Assert-MatchesPattern -Value $headSha -Pattern $foundation.git_sha_pattern -Context "$SourceLabel.head_sha"
    Assert-MatchesPattern -Value $treeSha -Pattern $foundation.git_sha_pattern -Context "$SourceLabel.tree_sha"
    $createdAtUtc = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $DispatchPacket -Name "created_at_utc" -Context $SourceLabel) -Context "$SourceLabel.created_at_utc"
    Assert-TimestampValue -Value $createdAtUtc -Pattern $foundation.timestamp_pattern -Context "$SourceLabel.created_at_utc"
    $operatorApprovalRef = Assert-RepoRefValue -Value (Get-RequiredProperty -Object $DispatchPacket -Name "operator_approval_ref" -Context $SourceLabel) -Foundation $foundation -Context "$SourceLabel.operator_approval_ref"
    $refusalConditions = Assert-StringArrayValue -Value (Get-RequiredProperty -Object $DispatchPacket -Name "refusal_conditions" -Context $SourceLabel) -Context "$SourceLabel.refusal_conditions"
    $nonClaims = Assert-RequiredNonClaims -Value (Get-RequiredProperty -Object $DispatchPacket -Name "non_claims" -Context $SourceLabel) -RequiredNonClaims @($contract.required_non_claims) -Context "$SourceLabel.non_claims"

    Assert-NoForbiddenDevClaim -Value @($expectedOutputs, $evidenceRequirements, $refusalConditions) -Context $SourceLabel

    $null = $baselineRef
    $null = $cycleLedgerRef
    $null = $operatorApprovalRef
    $null = $forbiddenPaths
    $null = $allowedTools
    $null = $forbiddenTools

    $result = [pscustomobject]@{
        IsValid = $true
        DispatchId = $dispatchId
        CycleId = $cycleId
        LedgerState = $ledgerState
        TaskCount = $taskPackets.Count
        AllowedPaths = @($allowedPaths)
        ExpectedOutputs = @($expectedOutputs)
        EvidenceRequirements = @($evidenceRequirements)
        HeadSha = $headSha
        TreeSha = $treeSha
        NonClaims = @($nonClaims)
        SourceLabel = $SourceLabel
    }

    $PSCmdlet.WriteObject($result, $false)
}

function Test-DevDispatchPacketContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$DispatchPath
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $DispatchPath -Label "Dev dispatch packet"
    $document = Get-JsonDocument -Path $resolvedPath -Label "Dev dispatch packet"
    $validation = Test-DevDispatchPacketObject -DispatchPacket $document -SourceLabel "Dev dispatch packet"
    $PSCmdlet.WriteObject($validation, $false)
}

function Read-TaskPacketDocument {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TaskPacketPath
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $TaskPacketPath -Label "Dev task packet document"
    $document = Get-JsonDocument -Path $resolvedPath -Label "Dev task packet document"
    if (-not (Test-HasProperty -Object $document -Name "task_packets")) {
        throw "Dev task packet document is missing required field 'task_packets'."
    }

    $taskPackets = Assert-ObjectArrayValue -Value $document.task_packets -Context "Dev task packet document.task_packets" -MinimumCount 1
    $PSCmdlet.WriteObject($taskPackets, $false)
}

function New-DevDispatchPacket {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$LedgerPath,
        [Parameter(Mandatory = $true)]
        [string]$CycleId,
        [Parameter(Mandatory = $true)]
        [string]$BaselineRef,
        [Parameter(Mandatory = $true)]
        [string]$OperatorApprovalRef,
        [Parameter(Mandatory = $true)]
        [object[]]$TaskPackets,
        [string]$OutputPath,
        [string]$TargetExecutor = "codex",
        [string[]]$AllowedTools,
        [string[]]$ForbiddenTools,
        [switch]$Overwrite
    )

    $foundation = Get-CycleControllerFoundationContract
    $contract = Get-DevDispatchPacketContract
    $cycleIdValue = Assert-NonEmptyString -Value $CycleId -Context "Dev dispatch cycle_id"
    Assert-MatchesPattern -Value $cycleIdValue -Pattern $foundation.identifier_pattern -Context "Dev dispatch cycle_id"
    $baselineRefValue = Assert-RepoRefValue -Value $BaselineRef -Foundation $foundation -Context "Dev dispatch baseline_ref"
    $operatorApprovalRefValue = Assert-RepoRefValue -Value $OperatorApprovalRef -Foundation $foundation -Context "Dev dispatch operator_approval_ref"
    $targetExecutorValue = Assert-NonEmptyString -Value $TargetExecutor -Context "Dev dispatch target_executor"
    Assert-NoForbiddenDevClaim -Value $targetExecutorValue -Context "Dev dispatch target_executor"

    $resolvedLedgerPath = Resolve-ExistingPath -PathValue $LedgerPath -Label "Cycle ledger"
    $ledgerValidation = & $script:TestCycleLedgerContract -LedgerPath $resolvedLedgerPath
    $ledger = & $script:GetCycleLedger -LedgerPath $resolvedLedgerPath
    if ($ledgerValidation.CycleId -ne $cycleIdValue) {
        throw "Cycle ledger cycle_id '$($ledgerValidation.CycleId)' does not match Dev dispatch cycle_id '$cycleIdValue'."
    }

    if (@($contract.allowed_ledger_states) -notcontains [string]$ledger.state) {
        throw "Cycle ledger state '$($ledger.state)' is not compatible with Dev dispatch. Allowed states: $($contract.allowed_ledger_states -join ', ')."
    }

    if ([string]$ledger.baseline_ref -ne $baselineRefValue) {
        throw "Dev dispatch baseline_ref must match the cycle ledger baseline_ref."
    }

    if (@($ledger.evidence_refs) -notcontains $operatorApprovalRefValue) {
        throw "Dev dispatch operator_approval_ref must be present in cycle ledger evidence_refs."
    }

    $taskPacketItems = Assert-ObjectArrayValue -Value $TaskPackets -Context "Dev dispatch task_packets" -MinimumCount 2
    foreach ($index in 0..($taskPacketItems.Count - 1)) {
        Test-DevTaskPacketObject -TaskPacket $taskPacketItems[$index] -DispatchContract $contract -Foundation $foundation -SourceLabel "Dev dispatch task_packets[$index]" | Out-Null
    }

    $allowedPathValues = @()
    $forbiddenPathValues = @()
    $expectedOutputValues = @()
    $evidenceRequirementValues = @()
    foreach ($taskPacket in $taskPacketItems) {
        foreach ($value in @($taskPacket.PSObject.Properties["allowed_paths"].Value)) { $allowedPathValues += [string]$value }
        foreach ($value in @($taskPacket.PSObject.Properties["forbidden_paths"].Value)) { $forbiddenPathValues += [string]$value }
        foreach ($value in @($taskPacket.PSObject.Properties["expected_outputs"].Value)) { $expectedOutputValues += [string]$value }
        foreach ($value in @($taskPacket.PSObject.Properties["evidence_required"].Value)) { $evidenceRequirementValues += [string]$value }
    }

    $allowedToolValues = if ($null -eq $AllowedTools -or $AllowedTools.Count -eq 0) { @($contract.default_allowed_tools) } else { @($AllowedTools) }
    $forbiddenToolValues = if ($null -eq $ForbiddenTools -or $ForbiddenTools.Count -eq 0) { @($contract.default_forbidden_tools) } else { @($ForbiddenTools) }
    $cycleLedgerRef = ConvertTo-RepositoryPath -Path $resolvedLedgerPath -RepositoryRoot (Get-ModuleRepositoryRootPath)

    $packet = [pscustomobject][ordered]@{
        contract_version = $foundation.contract_version
        artifact_type = $contract.dispatch_artifact_type
        dispatch_id = New-AdapterId -Prefix "dev-dispatch"
        repository = $foundation.repository
        branch = $foundation.branch
        milestone = $foundation.milestone
        source_task = $contract.source_task
        cycle_id = $cycleIdValue
        cycle_ledger_ref = $cycleLedgerRef
        ledger_state = [string]$ledger.state
        baseline_ref = $baselineRefValue
        target_executor = $targetExecutorValue
        task_packets = @($taskPacketItems)
        allowed_paths = @(Get-UniqueStringValues -Values $allowedPathValues)
        forbidden_paths = @(Get-UniqueStringValues -Values $forbiddenPathValues)
        allowed_tools = @(Get-UniqueStringValues -Values $allowedToolValues)
        forbidden_tools = @(Get-UniqueStringValues -Values $forbiddenToolValues)
        expected_outputs = @(Get-UniqueStringValues -Values $expectedOutputValues)
        evidence_requirements = @(Get-UniqueStringValues -Values $evidenceRequirementValues)
        head_sha = [string]$ledger.head_sha
        tree_sha = [string]$ledger.tree_sha
        created_at_utc = Get-UtcTimestamp
        operator_approval_ref = $operatorApprovalRefValue
        refusal_conditions = @(
            "Refuse missing or malformed cycle ledger truth.",
            "Refuse fewer than two bounded task packets.",
            "Refuse empty scope, empty allowed paths, missing forbidden paths, missing expected outputs, or missing evidence requirements.",
            "Refuse unbounded root, .git, wildcard, broad, or outside-repo paths.",
            "Refuse QA authority, complete-cycle, successor, productization, runtime, orchestration, unattended resume, compaction, production, or broad autonomy claims."
        )
        non_claims = @($contract.required_non_claims)
    }

    Test-DevDispatchPacketObject -DispatchPacket $packet -SourceLabel "Dev dispatch packet draft" | Out-Null

    if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
        $resolvedOutputPath = Resolve-PathValue -PathValue $OutputPath
        Write-JsonDocument -Path $resolvedOutputPath -Document $packet -Overwrite:$Overwrite
        Test-DevDispatchPacketContract -DispatchPath $resolvedOutputPath | Out-Null
    }

    return $packet
}

function Get-DispatchPacketFromPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$DispatchPath
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $DispatchPath -Label "Dev dispatch packet"
    Test-DevDispatchPacketContract -DispatchPath $resolvedPath | Out-Null
    return (Get-JsonDocument -Path $resolvedPath -Label "Dev dispatch packet")
}

function Read-TaskResultDocument {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TaskResultPath
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $TaskResultPath -Label "Dev task result document"
    $document = Get-JsonDocument -Path $resolvedPath -Label "Dev task result document"
    if (-not (Test-HasProperty -Object $document -Name "task_results")) {
        throw "Dev task result document is missing required field 'task_results'."
    }

    $PSCmdlet.WriteObject($document, $false)
}

function Assert-TaskResultArray {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        $ResultContract,
        [Parameter(Mandatory = $true)]
        $DispatchContract,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [AllowNull()]
        $DispatchPacket,
        [Parameter(Mandatory = $true)]
        [string]$TopLevelStatus,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $minimumCount = if ($null -eq $DispatchPacket) { 1 } else { @($DispatchPacket.task_packets).Count }
    $taskResults = Assert-ObjectArrayValue -Value $Value -Context $Context -MinimumCount $minimumCount
    $expectedTaskIds = @()
    $allowedPaths = @()
    if ($null -ne $DispatchPacket) {
        foreach ($taskPacket in @($DispatchPacket.task_packets)) {
            $expectedTaskIds += [string]$taskPacket.task_id
        }
        $allowedPaths = @($DispatchPacket.allowed_paths)
    }

    $seenTaskIds = @()
    foreach ($index in 0..($taskResults.Count - 1)) {
        $taskResult = $taskResults[$index]
        $taskContext = "$Context[$index]"
        Assert-RequiredObjectFields -Object $taskResult -FieldNames @($ResultContract.task_result_required_fields) -Context $taskContext
        $taskId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $taskResult -Name "task_id" -Context $taskContext) -Context "$taskContext.task_id"
        Assert-MatchesPattern -Value $taskId -Pattern $Foundation.identifier_pattern -Context "$taskContext.task_id"
        if ($seenTaskIds -contains $taskId) {
            throw "$Context contains duplicate task_id '$taskId'."
        }
        $seenTaskIds += $taskId
        if ($expectedTaskIds.Count -gt 0 -and $expectedTaskIds -notcontains $taskId) {
            throw "$taskContext.task_id '$taskId' is not present in the dispatch packet."
        }

        $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $taskResult -Name "status" -Context $taskContext) -Context "$taskContext.status"
        Assert-AllowedValue -Value $status -AllowedValues @($ResultContract.allowed_statuses) -Context "$taskContext.status"
        if ($TopLevelStatus -eq "completed" -and $status -ne "completed") {
            throw "$taskContext.status must be completed when top-level result status is completed."
        }

        $summary = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $taskResult -Name "summary" -Context $taskContext) -Context "$taskContext.summary"
        Assert-NoForbiddenDevClaim -Value $summary -Context "$taskContext.summary"
        $changedFiles = Assert-StringArrayValue -Value (Get-RequiredProperty -Object $taskResult -Name "changed_files" -Context $taskContext) -Context "$taskContext.changed_files" -AllowEmpty
        $producedArtifacts = Assert-RepoRefArrayValue -Value (Get-RequiredProperty -Object $taskResult -Name "produced_artifacts" -Context $taskContext) -Foundation $Foundation -Context "$taskContext.produced_artifacts" -AllowEmpty
        $commandLogs = Assert-RepoRefArrayValue -Value (Get-RequiredProperty -Object $taskResult -Name "command_logs" -Context $taskContext) -Foundation $Foundation -Context "$taskContext.command_logs" -AllowEmpty
        $evidenceRefs = Assert-RepoRefArrayValue -Value (Get-RequiredProperty -Object $taskResult -Name "evidence_refs" -Context $taskContext) -Foundation $Foundation -Context "$taskContext.evidence_refs" -AllowEmpty
        $refusalReasons = Assert-StringArrayValue -Value (Get-RequiredProperty -Object $taskResult -Name "refusal_reasons" -Context $taskContext) -Context "$taskContext.refusal_reasons" -AllowEmpty
        $nonClaims = Assert-RequiredNonClaims -Value (Get-RequiredProperty -Object $taskResult -Name "non_claims" -Context $taskContext) -RequiredNonClaims @($ResultContract.required_non_claims) -Context "$taskContext.non_claims"

        foreach ($changedFile in @($changedFiles)) {
            Assert-BoundedPathValue -Value $changedFile -Contract $DispatchContract -Context "$taskContext.changed_files" | Out-Null
        }
        foreach ($artifact in @($producedArtifacts)) {
            Assert-BoundedPathValue -Value $artifact -Contract $DispatchContract -Context "$taskContext.produced_artifacts" | Out-Null
        }
        if ($allowedPaths.Count -gt 0) {
            Assert-PathsWithinDispatchScope -Paths @($changedFiles) -AllowedPaths $allowedPaths -DispatchContract $DispatchContract -Context "$taskContext.changed_files"
            Assert-PathsWithinDispatchScope -Paths @($producedArtifacts) -AllowedPaths $allowedPaths -DispatchContract $DispatchContract -Context "$taskContext.produced_artifacts"
        }

        if ($status -eq "completed" -and $evidenceRefs.Count -eq 0) {
            throw "$taskContext.evidence_refs are required for completed task results."
        }
        if (@("blocked", "failed") -contains $status -and $refusalReasons.Count -eq 0) {
            throw "$taskContext.refusal_reasons are required for blocked or failed task results."
        }

        Assert-NoForbiddenDevClaim -Value @($refusalReasons, $nonClaims) -Context $taskContext
        $null = $commandLogs
    }

    foreach ($expectedTaskId in $expectedTaskIds) {
        if ($seenTaskIds -notcontains $expectedTaskId) {
            throw "$Context is missing result for dispatch task_id '$expectedTaskId'."
        }
    }

    $PSCmdlet.WriteObject($taskResults, $false)
}

function Test-DevExecutionResultPacketObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $ExecutionResult,
        [AllowNull()]
        $DispatchPacket,
        [string]$SourceLabel = "Dev execution result packet"
    )

    $foundation = Get-CycleControllerFoundationContract
    $dispatchContract = Get-DevDispatchPacketContract
    $contract = Get-DevExecutionResultPacketContract
    Assert-RequiredObjectFields -Object $ExecutionResult -FieldNames @($contract.required_fields) -Context $SourceLabel
    Assert-CommonIdentityFields -Packet $ExecutionResult -ExpectedArtifactType $contract.result_artifact_type -Contract $contract -Foundation $foundation -SourceLabel $SourceLabel

    $resultId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ExecutionResult -Name "result_id" -Context $SourceLabel) -Context "$SourceLabel.result_id"
    Assert-MatchesPattern -Value $resultId -Pattern $foundation.identifier_pattern -Context "$SourceLabel.result_id"
    $cycleId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ExecutionResult -Name "cycle_id" -Context $SourceLabel) -Context "$SourceLabel.cycle_id"
    Assert-MatchesPattern -Value $cycleId -Pattern $foundation.identifier_pattern -Context "$SourceLabel.cycle_id"
    $dispatchId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ExecutionResult -Name "dispatch_id" -Context $SourceLabel) -Context "$SourceLabel.dispatch_id"
    Assert-MatchesPattern -Value $dispatchId -Pattern $foundation.identifier_pattern -Context "$SourceLabel.dispatch_id"
    $cycleLedgerRef = Assert-RepoRefValue -Value (Get-RequiredProperty -Object $ExecutionResult -Name "cycle_ledger_ref" -Context $SourceLabel) -Foundation $foundation -Context "$SourceLabel.cycle_ledger_ref"
    $executorIdentity = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ExecutionResult -Name "executor_identity" -Context $SourceLabel) -Context "$SourceLabel.executor_identity"
    $executorKind = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ExecutionResult -Name "executor_kind" -Context $SourceLabel) -Context "$SourceLabel.executor_kind"
    Assert-AllowedValue -Value $executorKind -AllowedValues @($contract.allowed_executor_kinds) -Context "$SourceLabel.executor_kind"
    Assert-NoForbiddenDevClaim -Value @($executorIdentity, $executorKind) -Context "$SourceLabel.executor"
    $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ExecutionResult -Name "status" -Context $SourceLabel) -Context "$SourceLabel.status"
    Assert-AllowedValue -Value $status -AllowedValues @($contract.allowed_statuses) -Context "$SourceLabel.status"

    $taskResults = Assert-TaskResultArray -Value (Get-RequiredProperty -Object $ExecutionResult -Name "task_results" -Context $SourceLabel) -ResultContract $contract -DispatchContract $dispatchContract -Foundation $foundation -DispatchPacket $DispatchPacket -TopLevelStatus $status -Context "$SourceLabel.task_results"
    $changedFiles = Assert-StringArrayValue -Value (Get-RequiredProperty -Object $ExecutionResult -Name "changed_files" -Context $SourceLabel) -Context "$SourceLabel.changed_files" -AllowEmpty
    $producedArtifacts = Assert-RepoRefArrayValue -Value (Get-RequiredProperty -Object $ExecutionResult -Name "produced_artifacts" -Context $SourceLabel) -Foundation $foundation -Context "$SourceLabel.produced_artifacts" -AllowEmpty
    $commandLogs = Assert-RepoRefArrayValue -Value (Get-RequiredProperty -Object $ExecutionResult -Name "command_logs" -Context $SourceLabel) -Foundation $foundation -Context "$SourceLabel.command_logs" -AllowEmpty
    $evidenceRefs = Assert-RepoRefArrayValue -Value (Get-RequiredProperty -Object $ExecutionResult -Name "evidence_refs" -Context $SourceLabel) -Foundation $foundation -Context "$SourceLabel.evidence_refs" -AllowEmpty

    foreach ($changedFile in @($changedFiles)) {
        Assert-BoundedPathValue -Value $changedFile -Contract $dispatchContract -Context "$SourceLabel.changed_files" | Out-Null
    }
    foreach ($artifact in @($producedArtifacts)) {
        Assert-BoundedPathValue -Value $artifact -Contract $dispatchContract -Context "$SourceLabel.produced_artifacts" | Out-Null
    }

    if ($null -ne $DispatchPacket) {
        $dispatchValidation = Test-DevDispatchPacketObject -DispatchPacket $DispatchPacket -SourceLabel "Dev dispatch packet reference"
        if ($dispatchId -ne $dispatchValidation.DispatchId) {
            throw "$SourceLabel.dispatch_id does not match the dispatch packet."
        }
        if ($cycleId -ne $dispatchValidation.CycleId) {
            throw "$SourceLabel.cycle_id does not match the dispatch packet."
        }
        foreach ($fieldName in @("repository", "branch", "milestone", "source_task", "cycle_ledger_ref")) {
            if ([string]$ExecutionResult.PSObject.Properties[$fieldName].Value -ne [string]$DispatchPacket.PSObject.Properties[$fieldName].Value) {
                throw "$SourceLabel.$fieldName does not match the dispatch packet."
            }
        }
        Assert-PathsWithinDispatchScope -Paths @($changedFiles) -AllowedPaths @($DispatchPacket.allowed_paths) -DispatchContract $dispatchContract -Context "$SourceLabel.changed_files"
        Assert-PathsWithinDispatchScope -Paths @($producedArtifacts) -AllowedPaths @($DispatchPacket.allowed_paths) -DispatchContract $dispatchContract -Context "$SourceLabel.produced_artifacts"
    }

    $headBefore = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ExecutionResult -Name "head_before" -Context $SourceLabel) -Context "$SourceLabel.head_before"
    $treeBefore = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ExecutionResult -Name "tree_before" -Context $SourceLabel) -Context "$SourceLabel.tree_before"
    $headAfter = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ExecutionResult -Name "head_after" -Context $SourceLabel) -Context "$SourceLabel.head_after"
    $treeAfter = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ExecutionResult -Name "tree_after" -Context $SourceLabel) -Context "$SourceLabel.tree_after"
    foreach ($entry in @(
            @{ Value = $headBefore; Name = "head_before" },
            @{ Value = $treeBefore; Name = "tree_before" },
            @{ Value = $headAfter; Name = "head_after" },
            @{ Value = $treeAfter; Name = "tree_after" }
        )) {
        Assert-MatchesPattern -Value $entry.Value -Pattern $foundation.git_sha_pattern -Context "$SourceLabel.$($entry.Name)"
    }
    if ($null -ne $DispatchPacket) {
        if ($headBefore -ne [string]$DispatchPacket.head_sha -or $treeBefore -ne [string]$DispatchPacket.tree_sha) {
            throw "$SourceLabel head_before/tree_before must match the dispatch packet head_sha/tree_sha."
        }
    }

    $createdAtUtc = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ExecutionResult -Name "created_at_utc" -Context $SourceLabel) -Context "$SourceLabel.created_at_utc"
    Assert-TimestampValue -Value $createdAtUtc -Pattern $foundation.timestamp_pattern -Context "$SourceLabel.created_at_utc"
    $refusalReasons = Assert-StringArrayValue -Value (Get-RequiredProperty -Object $ExecutionResult -Name "refusal_reasons" -Context $SourceLabel) -Context "$SourceLabel.refusal_reasons" -AllowEmpty
    $nonClaims = Assert-RequiredNonClaims -Value (Get-RequiredProperty -Object $ExecutionResult -Name "non_claims" -Context $SourceLabel) -RequiredNonClaims @($contract.required_non_claims) -Context "$SourceLabel.non_claims"

    if ($status -eq "completed" -and $evidenceRefs.Count -eq 0) {
        throw "$SourceLabel.evidence_refs are required for completed results."
    }
    if (@("blocked", "failed") -contains $status -and $refusalReasons.Count -eq 0) {
        throw "$SourceLabel.refusal_reasons are required for blocked or failed results."
    }

    Assert-NoForbiddenDevClaim -Value @($refusalReasons, $nonClaims) -Context $SourceLabel
    $null = $cycleLedgerRef
    $null = $taskResults
    $null = $commandLogs

    $result = [pscustomobject]@{
        IsValid = $true
        ResultId = $resultId
        DispatchId = $dispatchId
        CycleId = $cycleId
        Status = $status
        TaskResultCount = @($ExecutionResult.task_results).Count
        ChangedFiles = @($changedFiles)
        ProducedArtifacts = @($producedArtifacts)
        EvidenceRefs = @($evidenceRefs)
        HeadBefore = $headBefore
        TreeBefore = $treeBefore
        HeadAfter = $headAfter
        TreeAfter = $treeAfter
        NonClaims = @($nonClaims)
        SourceLabel = $SourceLabel
    }

    $PSCmdlet.WriteObject($result, $false)
}

function Test-DevExecutionResultPacketContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResultPath,
        [string]$DispatchPath
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $ResultPath -Label "Dev execution result packet"
    $document = Get-JsonDocument -Path $resolvedPath -Label "Dev execution result packet"
    $dispatchPacket = $null
    if (-not [string]::IsNullOrWhiteSpace($DispatchPath)) {
        $dispatchPacket = Get-DispatchPacketFromPath -DispatchPath $DispatchPath
    }

    $validation = Test-DevExecutionResultPacketObject -ExecutionResult $document -DispatchPacket $dispatchPacket -SourceLabel "Dev execution result packet"
    $PSCmdlet.WriteObject($validation, $false)
}

function New-DevExecutionResultPacket {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$DispatchPath,
        [Parameter(Mandatory = $true)]
        [string]$ExecutorIdentity,
        [Parameter(Mandatory = $true)]
        [string]$ExecutorKind,
        [Parameter(Mandatory = $true)]
        [string]$Status,
        [Parameter(Mandatory = $true)]
        [object[]]$TaskResults,
        [string[]]$ChangedFiles,
        [string[]]$ProducedArtifacts,
        [string[]]$CommandLogs,
        [string[]]$EvidenceRefs,
        [Parameter(Mandatory = $true)]
        [string]$HeadBefore,
        [Parameter(Mandatory = $true)]
        [string]$TreeBefore,
        [Parameter(Mandatory = $true)]
        [string]$HeadAfter,
        [Parameter(Mandatory = $true)]
        [string]$TreeAfter,
        [string[]]$RefusalReasons,
        [string]$OutputPath,
        [switch]$Overwrite
    )

    $foundation = Get-CycleControllerFoundationContract
    $contract = Get-DevExecutionResultPacketContract
    $dispatchPacket = Get-DispatchPacketFromPath -DispatchPath $DispatchPath
    $executorIdentityValue = Assert-NonEmptyString -Value $ExecutorIdentity -Context "Dev execution result executor_identity"
    $executorKindValue = Assert-NonEmptyString -Value $ExecutorKind -Context "Dev execution result executor_kind"
    Assert-AllowedValue -Value $executorKindValue -AllowedValues @($contract.allowed_executor_kinds) -Context "Dev execution result executor_kind"
    Assert-NoForbiddenDevClaim -Value @($executorIdentityValue, $executorKindValue) -Context "Dev execution result executor"
    $statusValue = Assert-NonEmptyString -Value $Status -Context "Dev execution result status"
    Assert-AllowedValue -Value $statusValue -AllowedValues @($contract.allowed_statuses) -Context "Dev execution result status"

    $taskResultItems = Assert-TaskResultArray -Value $TaskResults -ResultContract $contract -DispatchContract (Get-DevDispatchPacketContract) -Foundation $foundation -DispatchPacket $dispatchPacket -TopLevelStatus $statusValue -Context "Dev execution result task_results"

    $derivedChangedFiles = @()
    $derivedProducedArtifacts = @()
    $derivedCommandLogs = @()
    $derivedEvidenceRefs = @()
    $derivedRefusalReasons = @()
    foreach ($taskResult in @($taskResultItems)) {
        $derivedChangedFiles += @($taskResult.changed_files)
        $derivedProducedArtifacts += @($taskResult.produced_artifacts)
        $derivedCommandLogs += @($taskResult.command_logs)
        $derivedEvidenceRefs += @($taskResult.evidence_refs)
        $derivedRefusalReasons += @($taskResult.refusal_reasons)
    }

    $changedFileValues = if ($null -eq $ChangedFiles) { @(Get-UniqueStringValues -Values $derivedChangedFiles) } else { @(Get-UniqueStringValues -Values (@($ChangedFiles) + $derivedChangedFiles)) }
    $producedArtifactValues = if ($null -eq $ProducedArtifacts) { @(Get-UniqueStringValues -Values $derivedProducedArtifacts) } else { @(Get-UniqueStringValues -Values (@($ProducedArtifacts) + $derivedProducedArtifacts)) }
    $commandLogValues = if ($null -eq $CommandLogs) { @(Get-UniqueStringValues -Values $derivedCommandLogs) } else { @(Get-UniqueStringValues -Values (@($CommandLogs) + $derivedCommandLogs)) }
    $evidenceRefValues = if ($null -eq $EvidenceRefs) { @(Get-UniqueStringValues -Values $derivedEvidenceRefs) } else { @(Get-UniqueStringValues -Values (@($EvidenceRefs) + $derivedEvidenceRefs)) }
    $refusalReasonValues = if ($null -eq $RefusalReasons) { @(Get-UniqueStringValues -Values $derivedRefusalReasons) } else { @(Get-UniqueStringValues -Values (@($RefusalReasons) + $derivedRefusalReasons)) }

    $packet = [pscustomobject][ordered]@{
        contract_version = $foundation.contract_version
        artifact_type = $contract.result_artifact_type
        result_id = New-AdapterId -Prefix "dev-result"
        repository = $dispatchPacket.repository
        branch = $dispatchPacket.branch
        milestone = $dispatchPacket.milestone
        source_task = $contract.source_task
        cycle_id = $dispatchPacket.cycle_id
        dispatch_id = $dispatchPacket.dispatch_id
        cycle_ledger_ref = $dispatchPacket.cycle_ledger_ref
        executor_identity = $executorIdentityValue
        executor_kind = $executorKindValue
        status = $statusValue
        task_results = @($taskResultItems)
        changed_files = @($changedFileValues)
        produced_artifacts = @($producedArtifactValues)
        command_logs = @($commandLogValues)
        evidence_refs = @($evidenceRefValues)
        head_before = $HeadBefore
        tree_before = $TreeBefore
        head_after = $HeadAfter
        tree_after = $TreeAfter
        created_at_utc = Get-UtcTimestamp
        refusal_reasons = @($refusalReasonValues)
        non_claims = @($contract.required_non_claims)
    }

    Test-DevExecutionResultPacketObject -ExecutionResult $packet -DispatchPacket $dispatchPacket -SourceLabel "Dev execution result packet draft" | Out-Null

    if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
        $resolvedOutputPath = Resolve-PathValue -PathValue $OutputPath
        Write-JsonDocument -Path $resolvedOutputPath -Document $packet -Overwrite:$Overwrite
        Test-DevExecutionResultPacketContract -ResultPath $resolvedOutputPath -DispatchPath $DispatchPath | Out-Null
    }

    return $packet
}

function Inspect-DevDispatchPacket {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$DispatchPath
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $DispatchPath -Label "Dev dispatch packet"
    $validation = Test-DevDispatchPacketContract -DispatchPath $resolvedPath
    $dispatchPacket = Get-JsonDocument -Path $resolvedPath -Label "Dev dispatch packet"
    return [pscustomobject][ordered]@{
        ArtifactType = "dev_dispatch_summary"
        DispatchPath = $resolvedPath
        DispatchId = $validation.DispatchId
        CycleId = $validation.CycleId
        LedgerState = $validation.LedgerState
        TaskCount = $validation.TaskCount
        TargetExecutor = $dispatchPacket.target_executor
        AllowedPathCount = @($dispatchPacket.allowed_paths).Count
        EvidenceRequirementCount = @($dispatchPacket.evidence_requirements).Count
        HeadSha = $validation.HeadSha
        TreeSha = $validation.TreeSha
        NonClaims = @($validation.NonClaims)
    }
}

function Inspect-DevExecutionResultPacket {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResultPath,
        [string]$DispatchPath
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $ResultPath -Label "Dev execution result packet"
    $validation = if ([string]::IsNullOrWhiteSpace($DispatchPath)) {
        Test-DevExecutionResultPacketContract -ResultPath $resolvedPath
    }
    else {
        Test-DevExecutionResultPacketContract -ResultPath $resolvedPath -DispatchPath $DispatchPath
    }
    $resultPacket = Get-JsonDocument -Path $resolvedPath -Label "Dev execution result packet"
    return [pscustomobject][ordered]@{
        ArtifactType = "dev_execution_result_summary"
        ResultPath = $resolvedPath
        ResultId = $validation.ResultId
        DispatchId = $validation.DispatchId
        CycleId = $validation.CycleId
        Status = $validation.Status
        ExecutorIdentity = $resultPacket.executor_identity
        ExecutorKind = $resultPacket.executor_kind
        TaskResultCount = $validation.TaskResultCount
        EvidenceRefCount = @($validation.EvidenceRefs).Count
        HeadBefore = $validation.HeadBefore
        HeadAfter = $validation.HeadAfter
        NonClaims = @($validation.NonClaims)
    }
}

Export-ModuleMember -Function New-DevDispatchPacket, Test-DevDispatchPacketContract, Test-DevDispatchPacketObject, Inspect-DevDispatchPacket, Read-TaskPacketDocument, New-DevExecutionResultPacket, Test-DevExecutionResultPacketContract, Test-DevExecutionResultPacketObject, Inspect-DevExecutionResultPacket, Read-TaskResultDocument
