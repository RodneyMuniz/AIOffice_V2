Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$jsonRootModule = Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force -PassThru
$script:ReadSingleJsonObject = $jsonRootModule.ExportedCommands["Read-SingleJsonObject"]

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

function Get-CycleControllerFoundationContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "cycle_controller", "foundation.contract.json")) -Label "Cycle controller foundation contract"
}

function Get-LocalResiduePolicyContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "cycle_controller", "local_residue_policy.contract.json")) -Label "Local residue policy contract"
}

function Get-LocalResidueScanResultContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "cycle_controller", "local_residue_scan_result.contract.json")) -Label "Local residue scan result contract"
}

function Get-LocalResidueQuarantineResultContract {
    return Get-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "cycle_controller", "local_residue_quarantine_result.contract.json")) -Label "Local residue quarantine result contract"
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

    if ($Value -is [string]) {
        throw "$Context must be an array."
    }

    if (-not ($Value -is [System.Collections.IEnumerable])) {
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

function Get-UtcTimestamp {
    return [System.DateTimeOffset]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture)
}

function New-GuardId {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Prefix
    )

    return ("{0}-{1}" -f $Prefix, [guid]::NewGuid().ToString("N").Substring(0, 12))
}

function Invoke-GitCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & git -C $RepositoryRoot @Arguments 2>&1
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }
    $lines = @($output | ForEach-Object { [string]$_ })

    return [pscustomobject]@{
        ExitCode = $exitCode
        Lines = $lines
        Command = "git $($Arguments -join ' ')"
    }
}

function Get-CurrentGitRef {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string]$Revision
    )

    $result = Invoke-GitCommand -RepositoryRoot $RepositoryRoot -Arguments @("rev-parse", $Revision)
    if ($result.ExitCode -ne 0 -or $result.Lines.Count -eq 0 -or [string]::IsNullOrWhiteSpace($result.Lines[0])) {
        throw "Unable to resolve Git ref '$Revision' for local residue guard."
    }

    return [string]($result.Lines[0].Trim())
}

function Get-CurrentGitBranch {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $result = Invoke-GitCommand -RepositoryRoot $RepositoryRoot -Arguments @("rev-parse", "--abbrev-ref", "HEAD")
    if ($result.ExitCode -ne 0 -or $result.Lines.Count -eq 0 -or [string]::IsNullOrWhiteSpace($result.Lines[0])) {
        throw "Unable to resolve Git branch for local residue guard."
    }

    return [string]($result.Lines[0].Trim())
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
        return "."
    }

    $rootWithSeparator = $fullRoot + [System.IO.Path]::DirectorySeparatorChar
    if (-not $fullPath.StartsWith($rootWithSeparator, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Path '$Path' escapes repository root."
    }

    return $fullPath.Substring($rootWithSeparator.Length).Replace("\", "/").TrimEnd("/")
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
            throw "Local residue guard output '$Path' already exists. Use -Overwrite to replace it explicitly."
        }
    }

    $parentPath = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($parentPath)) {
        New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    }

    $json = $Document | ConvertTo-Json -Depth 80
    Set-Content -LiteralPath $Path -Value $json -Encoding UTF8
}

function Get-LocalResidueNonClaims {
    param()

    $policy = Get-LocalResiduePolicyContract
    $items = @()
    foreach ($item in @($policy.required_non_claims)) {
        if ($items -notcontains $item) {
            $items += $item
        }
    }

    return $items
}

function New-StatusEntry {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RawStatus
    )

    $policy = Get-LocalResiduePolicyContract
    $xyStatus = ""
    $pathValue = ""
    $originalPath = ""
    $classification = "ignored_or_unknown"
    $tracked = $false
    $eligible = $false
    $refusalReasons = @()

    if ([string]::IsNullOrWhiteSpace($RawStatus) -or $RawStatus.Length -lt 3) {
        $refusalReasons += "ambiguous status entry '$RawStatus' could not be parsed."
    }
    else {
        $xyStatus = $RawStatus.Substring(0, 2)
        $pathText = $RawStatus.Substring(3).Trim()
        if ($RawStatus[2] -ne " ") {
            $refusalReasons += "ambiguous status entry '$RawStatus' does not use expected short-status spacing."
        }

        if ($pathText -match '^(.*?)\s+->\s+(.*)$') {
            $originalPath = $Matches[1]
            $pathValue = $Matches[2]
        }
        else {
            $pathValue = $pathText
        }

        if ([string]::IsNullOrWhiteSpace($pathValue)) {
            $refusalReasons += "ambiguous status entry '$RawStatus' does not include a path."
        }

        if ($xyStatus -eq "??") {
            $classification = "untracked"
            $tracked = $false
            $eligible = $true
        }
        elseif ($xyStatus -eq "!!") {
            $classification = "ignored_or_unknown"
            $tracked = $false
            $refusalReasons += "ignored or unknown status entry '$RawStatus' is not eligible for quarantine."
        }
        elseif ($xyStatus -match "U") {
            $classification = "ignored_or_unknown"
            $tracked = $true
            $refusalReasons += "ambiguous unmerged status entry '$RawStatus' is refused."
        }
        elseif ($xyStatus -notmatch '^[ MADRCUT]{2}$') {
            $classification = "ignored_or_unknown"
            $tracked = $true
            $refusalReasons += "ambiguous status entry '$RawStatus' uses an unknown status code."
        }
        elseif ($xyStatus -match "D") {
            $classification = "tracked_deleted"
            $tracked = $true
        }
        elseif ($xyStatus[0] -match '[ARC]' -or $xyStatus[1] -eq "A") {
            $classification = "tracked_added_or_staged"
            $tracked = $true
        }
        elseif ($xyStatus -match '[MT]') {
            $classification = "tracked_modified"
            $tracked = $true
        }
        elseif (-not [string]::IsNullOrWhiteSpace($xyStatus.Trim())) {
            $classification = "tracked_modified"
            $tracked = $true
        }
        else {
            $classification = "clean"
        }
    }

    Assert-AllowedValue -Value $classification -AllowedValues @($policy.allowed_entry_classifications) -Context "Local residue status entry classification"
    return [pscustomobject][ordered]@{
        raw_status = $RawStatus
        xy_status = $xyStatus
        path = $pathValue
        original_path = $originalPath
        classification = $classification
        tracked = [bool]$tracked
        quarantine_eligible = [bool]($eligible -and $refusalReasons.Count -eq 0)
        evidence_allowed = $false
        evidence_status = "not_evidence"
        refusal_reasons = @($refusalReasons)
    }
}

function Get-TrackedPathsForCandidate {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryPath
    )

    if ($RepositoryPath -eq ".") {
        $gitPath = "."
    }
    else {
        $gitPath = $RepositoryPath
    }

    $result = Invoke-GitCommand -RepositoryRoot $RepositoryRoot -Arguments @("ls-files", "--", $gitPath)
    if ($result.ExitCode -ne 0) {
        throw "Unable to inspect tracked status for candidate '$RepositoryPath'."
    }

    return @($result.Lines | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Test-CandidateCoversUntrackedPath {
    param(
        [Parameter(Mandatory = $true)]
        $Candidate,
        [Parameter(Mandatory = $true)]
        [string]$UntrackedPath
    )

    if ($Candidate.already_absent) {
        return $false
    }

    if ($Candidate.repository_path -eq $UntrackedPath) {
        return $true
    }

    if ($Candidate.path_type -eq "directory") {
        $prefix = $Candidate.repository_path.TrimEnd("/") + "/"
        return $UntrackedPath.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)
    }

    return $false
}

function Get-NormalizedAlreadyAbsentPaths {
    param(
        [AllowEmptyCollection()]
        [string[]]$AlreadyAbsentPaths,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $items = @()
    foreach ($path in @($AlreadyAbsentPaths)) {
        if ([string]::IsNullOrWhiteSpace($path)) {
            continue
        }

        $items += (Resolve-PathValue -PathValue $path -AnchorPath $RepositoryRoot)
    }

    return $items
}

function New-CandidateResult {
    param(
        [Parameter(Mandatory = $true)]
        [string]$CandidatePath,
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [AllowEmptyCollection()]
        [string[]]$AlreadyAbsentFullPaths,
        [AllowEmptyCollection()]
        [string[]]$UntrackedPaths
    )

    $policy = Get-LocalResiduePolicyContract
    $refusalReasons = @()
    $resolvedPath = ""
    $repositoryPath = ""
    $pathExists = $false
    $pathType = "missing"
    $tracked = $false
    $alreadyAbsent = $false
    $coveredUntrackedPaths = @()

    if ([string]::IsNullOrWhiteSpace($CandidatePath)) {
        $refusalReasons += "candidate path is empty."
    }
    else {
        $resolvedPath = Resolve-PathValue -PathValue $CandidatePath -AnchorPath $RepositoryRoot
        $alreadyAbsent = @($AlreadyAbsentFullPaths | Where-Object { $_.Equals($resolvedPath, [System.StringComparison]::OrdinalIgnoreCase) }).Count -gt 0

        if (-not (Test-PathUnderRoot -Path $resolvedPath -Root $RepositoryRoot)) {
            $refusalReasons += "candidate path '$CandidatePath' escapes the repository root."
        }
        else {
            $repositoryPath = ConvertTo-RepositoryPath -Path $resolvedPath -RepositoryRoot $RepositoryRoot
            $normalizedRepositoryPath = $repositoryPath.TrimEnd("/")
            $segments = @($normalizedRepositoryPath -split "/" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
            if ($normalizedRepositoryPath -eq ".") {
                $refusalReasons += "candidate path '$CandidatePath' targets the repository root."
            }
            elseif ($segments.Count -gt 0 -and $segments[0] -eq ".git") {
                $refusalReasons += "candidate path '$CandidatePath' targets .git and is refused."
            }
            elseif ($segments.Count -eq 1 -and @($policy.broad_path_refusals) -contains $segments[0]) {
                $refusalReasons += "candidate path '$CandidatePath' is a broad root-level path and is refused without a narrow child path."
            }

            $pathExists = Test-Path -LiteralPath $resolvedPath
            if ($pathExists) {
                if (Test-Path -LiteralPath $resolvedPath -PathType Container) {
                    $pathType = "directory"
                }
                elseif (Test-Path -LiteralPath $resolvedPath -PathType Leaf) {
                    $pathType = "file"
                }
                else {
                    $pathType = "unknown"
                    $refusalReasons += "candidate path '$CandidatePath' has an unknown filesystem type."
                }
            }
            elseif ($alreadyAbsent) {
                $pathType = "already_absent"
            }
            else {
                $refusalReasons += "candidate path '$CandidatePath' is missing and was not explicitly marked as already absent."
            }

            if (-not [string]::IsNullOrWhiteSpace($repositoryPath)) {
                $trackedPaths = @(Get-TrackedPathsForCandidate -RepositoryRoot $RepositoryRoot -RepositoryPath $repositoryPath)
                if ($trackedPaths.Count -gt 0) {
                    $tracked = $true
                    $refusalReasons += "candidate path '$CandidatePath' is tracked or contains tracked files and cannot be quarantined."
                }
            }

            foreach ($untrackedPath in @($UntrackedPaths)) {
                $candidate = [pscustomobject]@{
                    repository_path = $repositoryPath
                    path_type = $pathType
                    already_absent = $alreadyAbsent
                }
                if (Test-CandidateCoversUntrackedPath -Candidate $candidate -UntrackedPath $untrackedPath) {
                    $coveredUntrackedPaths += $untrackedPath
                }
            }

            if ($pathExists -and -not $tracked -and $coveredUntrackedPaths.Count -eq 0) {
                $refusalReasons += "candidate path '$CandidatePath' is not reported as untracked residue by git status."
            }
        }
    }

    return [pscustomobject][ordered]@{
        input_path = $CandidatePath
        resolved_path = $resolvedPath
        repository_path = $repositoryPath
        exists = [bool]$pathExists
        path_type = $pathType
        already_absent = [bool]$alreadyAbsent
        tracked = [bool]$tracked
        covered_untracked_paths = @($coveredUntrackedPaths)
        quarantine_eligible = [bool]($refusalReasons.Count -eq 0 -and -not $tracked -and ($pathExists -or $alreadyAbsent))
        refusal_reasons = @($refusalReasons)
    }
}

function New-LocalResidueScanDocument {
    [CmdletBinding()]
    param(
        [string]$RepositoryRoot = (Get-ModuleRepositoryRootPath),
        [ValidateSet("scan", "dry-run")]
        [string]$ScanMode = "scan",
        [AllowEmptyCollection()]
        [string[]]$CandidatePaths = @(),
        [AllowEmptyCollection()]
        [string[]]$AlreadyAbsentPaths = @(),
        [AllowEmptyCollection()]
        [string[]]$StatusLinesOverride
    )

    $resolvedRepositoryRoot = Resolve-ExistingPath -PathValue $RepositoryRoot -Label "Repository root"
    $foundation = Get-CycleControllerFoundationContract
    $policy = Get-LocalResiduePolicyContract
    $headSha = Get-CurrentGitRef -RepositoryRoot $resolvedRepositoryRoot -Revision "HEAD"
    $treeSha = Get-CurrentGitRef -RepositoryRoot $resolvedRepositoryRoot -Revision "HEAD^{tree}"
    $branch = Get-CurrentGitBranch -RepositoryRoot $resolvedRepositoryRoot
    $gitStatusCommand = $policy.scan_command
    $gitStatusExitCode = 0
    $rawStatusLines = @()
    $refusalReasons = @()

    if ($PSBoundParameters.ContainsKey("StatusLinesOverride")) {
        $rawStatusLines = @($StatusLinesOverride)
    }
    else {
        $statusResult = Invoke-GitCommand -RepositoryRoot $resolvedRepositoryRoot -Arguments @("status", "--short", "--untracked-files=all")
        $gitStatusExitCode = $statusResult.ExitCode
        $rawStatusLines = @($statusResult.Lines)
        if ($gitStatusExitCode -ne 0) {
            $refusalReasons += "git status command failed and local residue guard refuses to proceed."
        }
    }

    $entries = @()
    foreach ($line in @($rawStatusLines | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })) {
        $entry = New-StatusEntry -RawStatus $line
        $entries += $entry
        foreach ($entryRefusal in @($entry.refusal_reasons)) {
            $refusalReasons += $entryRefusal
        }
    }

    $trackedChangesDetected = @($entries | Where-Object { $_.tracked }).Count -gt 0
    $untrackedResidueDetected = @($entries | Where-Object { $_.classification -eq "untracked" }).Count -gt 0
    $untrackedPaths = @($entries | Where-Object { $_.classification -eq "untracked" } | ForEach-Object { [string]$_.path })
    $worktreeClean = ($gitStatusExitCode -eq 0 -and $entries.Count -eq 0)
    $residueDetected = (-not $worktreeClean)

    if ($trackedChangesDetected) {
        $refusalReasons += "tracked changes detected; local residue guard refuses quarantine while tracked files are dirty."
    }

    $candidateResults = @()
    $unexpectedUntrackedPaths = @()
    if ($ScanMode -eq "dry-run") {
        if ($null -eq $CandidatePaths -or @($CandidatePaths).Count -eq 0) {
            $refusalReasons += "candidate paths are required for dry-run quarantine."
        }

        $alreadyAbsentFullPaths = @(Get-NormalizedAlreadyAbsentPaths -AlreadyAbsentPaths $AlreadyAbsentPaths -RepositoryRoot $resolvedRepositoryRoot)
        foreach ($candidatePath in @($CandidatePaths)) {
            $candidateResult = New-CandidateResult -CandidatePath $candidatePath -RepositoryRoot $resolvedRepositoryRoot -AlreadyAbsentFullPaths $alreadyAbsentFullPaths -UntrackedPaths $untrackedPaths
            $candidateResults += $candidateResult
            foreach ($candidateRefusal in @($candidateResult.refusal_reasons)) {
                $refusalReasons += $candidateRefusal
            }
        }

        foreach ($untrackedPath in @($untrackedPaths)) {
            $covered = $false
            foreach ($candidateResult in @($candidateResults)) {
                if (@($candidateResult.covered_untracked_paths) -contains $untrackedPath) {
                    $covered = $true
                    break
                }
            }

            if (-not $covered) {
                $unexpectedUntrackedPaths += $untrackedPath
                $refusalReasons += "untracked residue path '$untrackedPath' is outside the expected quarantine candidate list."
            }
        }
    }
    elseif ($untrackedResidueDetected) {
        $refusalReasons += "untracked residue detected; explicit dry-run and quarantine authorization are required."
    }

    $dedupedRefusals = @()
    foreach ($reason in @($refusalReasons)) {
        if ([string]::IsNullOrWhiteSpace($reason)) {
            continue
        }
        if ($dedupedRefusals -notcontains $reason) {
            $dedupedRefusals += $reason
        }
    }

    $candidateRepositoryPaths = @()
    if ($ScanMode -eq "dry-run") {
        foreach ($candidateResult in @($candidateResults)) {
            if (-not $candidateResult.already_absent -and -not [string]::IsNullOrWhiteSpace($candidateResult.repository_path)) {
                $candidateRepositoryPaths += $candidateResult.repository_path
            }
        }
    }
    else {
        $candidateRepositoryPaths = @($untrackedPaths)
    }

    $decision = "refused"
    $quarantineEligible = $false
    $residueAllowed = $false
    if ($dedupedRefusals.Count -eq 0 -and -not $residueDetected) {
        $decision = "allowed"
        $residueAllowed = $true
    }
    elseif ($dedupedRefusals.Count -eq 0 -and $ScanMode -eq "dry-run") {
        $decision = "quarantine_eligible"
        $quarantineEligible = $true
    }

    return [pscustomobject][ordered]@{
        contract_version = $foundation.contract_version
        artifact_type = $policy.scan_result_artifact_type
        scan_id = New-GuardId -Prefix "local-residue-scan"
        repository = $foundation.repository
        branch = $branch
        milestone = $foundation.milestone
        source_task = $policy.source_task
        head_sha = $headSha
        tree_sha = $treeSha
        scan_mode = $ScanMode
        git_status_command = $gitStatusCommand
        raw_status_lines = @($rawStatusLines)
        entries = @($entries)
        worktree_clean = [bool]$worktreeClean
        residue_detected = [bool]$residueDetected
        tracked_changes_detected = [bool]$trackedChangesDetected
        untracked_residue_detected = [bool]$untrackedResidueDetected
        quarantine_candidates = @($candidateRepositoryPaths)
        residue_policy_decision = $decision
        residue_allowed = [bool]$residueAllowed
        refused = [bool]($decision -eq "refused")
        quarantine_eligible = [bool]$quarantineEligible
        candidate_paths = @($CandidatePaths)
        candidate_path_results = @($candidateResults)
        unexpected_untracked_paths = @($unexpectedUntrackedPaths)
        local_residue_evidence_policy = "local-only residue is not evidence and is not repo truth"
        refusal_reasons = @($dedupedRefusals)
        created_at_utc = Get-UtcTimestamp
        non_claims = @(Get-LocalResidueNonClaims)
    }
}

function Invoke-LocalResidueScan {
    [CmdletBinding()]
    param(
        [string]$RepositoryRoot = (Get-ModuleRepositoryRootPath),
        [string]$OutputPath,
        [switch]$Overwrite,
        [AllowEmptyCollection()]
        [string[]]$StatusLinesOverride
    )

    $parameters = @{
        RepositoryRoot = $RepositoryRoot
        ScanMode = "scan"
    }
    if ($PSBoundParameters.ContainsKey("StatusLinesOverride")) {
        $parameters["StatusLinesOverride"] = $StatusLinesOverride
    }

    $result = New-LocalResidueScanDocument @parameters
    Test-LocalResidueScanResultObject -ScanResult $result -SourceLabel "Local residue scan result draft" | Out-Null

    if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
        $resolvedOutputPath = Resolve-PathValue -PathValue $OutputPath
        Write-JsonDocument -Path $resolvedOutputPath -Document $result -Overwrite:$Overwrite
        Test-LocalResidueScanResultContract -ScanResultPath $resolvedOutputPath | Out-Null
    }

    return $result
}

function Invoke-LocalResidueDryRun {
    [CmdletBinding()]
    param(
        [string]$RepositoryRoot = (Get-ModuleRepositoryRootPath),
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [string[]]$CandidatePaths,
        [AllowEmptyCollection()]
        [string[]]$AlreadyAbsentPaths = @(),
        [string]$OutputPath,
        [switch]$Overwrite,
        [AllowEmptyCollection()]
        [string[]]$StatusLinesOverride
    )

    $parameters = @{
        RepositoryRoot = $RepositoryRoot
        ScanMode = "dry-run"
        CandidatePaths = $CandidatePaths
        AlreadyAbsentPaths = $AlreadyAbsentPaths
    }
    if ($PSBoundParameters.ContainsKey("StatusLinesOverride")) {
        $parameters["StatusLinesOverride"] = $StatusLinesOverride
    }

    $result = New-LocalResidueScanDocument @parameters
    Test-LocalResidueScanResultObject -ScanResult $result -SourceLabel "Local residue dry-run result draft" | Out-Null

    if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
        $resolvedOutputPath = Resolve-PathValue -PathValue $OutputPath
        Write-JsonDocument -Path $resolvedOutputPath -Document $result -Overwrite:$Overwrite
        Test-LocalResidueScanResultContract -ScanResultPath $resolvedOutputPath | Out-Null
    }

    return $result
}

function New-DefaultQuarantineRoot {
    $timestamp = [System.DateTimeOffset]::UtcNow.ToString("yyyyMMddTHHmmssZ", [System.Globalization.CultureInfo]::InvariantCulture)
    return (Join-Path ([System.IO.Path]::GetTempPath()) ("AIOffice_V2_local_quarantine_{0}_{1}" -f $timestamp, [guid]::NewGuid().ToString("N").Substring(0, 8)))
}

function Get-DryRunRefForPacket {
    param(
        [AllowNull()]
        [string]$DryRunRef
    )

    if ([string]::IsNullOrWhiteSpace($DryRunRef)) {
        return ""
    }

    return $DryRunRef.Replace("\", "/")
}

function New-LocalResidueQuarantinePacket {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,
        [Parameter(Mandatory = $true)]
        [bool]$Authorized,
        [AllowEmptyString()]
        [AllowNull()]
        [string]$DryRunRef,
        [AllowEmptyCollection()]
        [string[]]$SourcePaths,
        [AllowEmptyString()]
        [string]$QuarantineRoot,
        [AllowEmptyCollection()]
        [object[]]$MovedItems,
        [AllowEmptyCollection()]
        [string[]]$RefusalReasons
    )

    $foundation = Get-CycleControllerFoundationContract
    $policy = Get-LocalResiduePolicyContract
    $resolvedRepositoryRoot = Resolve-ExistingPath -PathValue $RepositoryRoot -Label "Repository root"
    $headSha = Get-CurrentGitRef -RepositoryRoot $resolvedRepositoryRoot -Revision "HEAD"
    $treeSha = Get-CurrentGitRef -RepositoryRoot $resolvedRepositoryRoot -Revision "HEAD^{tree}"
    $branch = Get-CurrentGitBranch -RepositoryRoot $resolvedRepositoryRoot

    return [pscustomobject][ordered]@{
        contract_version = $foundation.contract_version
        artifact_type = $policy.quarantine_result_artifact_type
        quarantine_id = New-GuardId -Prefix "local-residue-quarantine"
        repository = $foundation.repository
        branch = $branch
        milestone = $foundation.milestone
        source_task = $policy.source_task
        head_sha = $headSha
        tree_sha = $treeSha
        authorized = [bool]$Authorized
        dry_run_ref = (Get-DryRunRefForPacket -DryRunRef $DryRunRef)
        source_paths = @($SourcePaths)
        quarantine_root = $QuarantineRoot
        moved_items = @($MovedItems)
        refusal_reasons = @($RefusalReasons)
        created_at_utc = Get-UtcTimestamp
        non_claims = @(Get-LocalResidueNonClaims)
    }
}

function Compare-StringArraysExactly {
    param(
        [AllowEmptyCollection()]
        [string[]]$Left,
        [AllowEmptyCollection()]
        [string[]]$Right
    )

    $leftItems = @($Left)
    $rightItems = @($Right)
    if ($leftItems.Count -ne $rightItems.Count) {
        return $false
    }

    for ($index = 0; $index -lt $leftItems.Count; $index += 1) {
        if ($leftItems[$index] -ne $rightItems[$index]) {
            return $false
        }
    }

    return $true
}

function Invoke-LocalResidueQuarantine {
    [CmdletBinding()]
    param(
        [string]$RepositoryRoot = (Get-ModuleRepositoryRootPath),
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [string[]]$CandidatePaths,
        [string]$DryRunRef,
        [string]$OutputPath,
        [switch]$Authorize,
        [string]$QuarantineRoot,
        [string]$Actor = "R11-005-local-residue-guard",
        [string]$Reason = "Quarantine explicit local-only residue candidate after dry-run evidence.",
        [switch]$Overwrite
    )

    $resolvedRepositoryRoot = Resolve-ExistingPath -PathValue $RepositoryRoot -Label "Repository root"
    $refusalReasons = @()
    $movedItems = @()
    $quarantineRootValue = if ([string]::IsNullOrWhiteSpace($QuarantineRoot)) { New-DefaultQuarantineRoot } else { Resolve-PathValue -PathValue $QuarantineRoot }

    if (-not $Authorize) {
        $refusalReasons += "explicit quarantine authorization is required."
    }

    $dryRun = $null
    if ([string]::IsNullOrWhiteSpace($DryRunRef)) {
        $refusalReasons += "dry-run evidence ref is required before quarantine."
    }
    elseif (-not (Test-Path -LiteralPath (Resolve-PathValue -PathValue $DryRunRef) -PathType Leaf)) {
        $refusalReasons += "dry-run evidence ref '$DryRunRef' does not exist."
    }
    else {
        try {
            $resolvedDryRunRef = Resolve-ExistingPath -PathValue $DryRunRef -Label "Dry-run evidence"
            Test-LocalResidueScanResultContract -ScanResultPath $resolvedDryRunRef | Out-Null
            $dryRun = Get-JsonDocument -Path $resolvedDryRunRef -Label "Local residue dry-run evidence"
            if ($dryRun.scan_mode -ne "dry-run") {
                $refusalReasons += "dry-run evidence ref '$DryRunRef' is not a dry-run scan result."
            }
            if (-not [bool]$dryRun.quarantine_eligible -or @($dryRun.refusal_reasons).Count -ne 0) {
                $refusalReasons += "dry-run evidence ref '$DryRunRef' is not quarantine-eligible."
            }
            if (-not (Compare-StringArraysExactly -Left @($dryRun.candidate_paths) -Right @($CandidatePaths))) {
                $refusalReasons += "dry-run evidence candidate paths do not exactly match the requested quarantine candidate paths."
            }
        }
        catch {
            $refusalReasons += "dry-run evidence ref '$DryRunRef' is invalid. $($_.Exception.Message)"
        }
    }

    if (Test-PathUnderRoot -Path $quarantineRootValue -Root $resolvedRepositoryRoot) {
        $refusalReasons += "quarantine root '$quarantineRootValue' must be outside the repository root."
    }

    $currentDryRun = $null
    if ($refusalReasons.Count -eq 0) {
        $currentDryRun = Invoke-LocalResidueDryRun -RepositoryRoot $resolvedRepositoryRoot -CandidatePaths $CandidatePaths
        if (-not $currentDryRun.quarantine_eligible -or @($currentDryRun.refusal_reasons).Count -ne 0) {
            foreach ($reasonItem in @($currentDryRun.refusal_reasons)) {
                $refusalReasons += $reasonItem
            }
            $refusalReasons += "current dry-run recheck is not quarantine-eligible."
        }
    }

    if ($refusalReasons.Count -eq 0) {
        New-Item -ItemType Directory -Path $quarantineRootValue -Force | Out-Null
        foreach ($candidate in @($currentDryRun.candidate_path_results)) {
            if ($candidate.already_absent) {
                continue
            }

            if ($candidate.tracked) {
                $refusalReasons += "candidate path '$($candidate.input_path)' became tracked before quarantine."
                continue
            }

            if (-not $candidate.exists) {
                $refusalReasons += "candidate path '$($candidate.input_path)' is missing before quarantine."
                continue
            }

            $destinationPath = Join-Path $quarantineRootValue ($candidate.repository_path -replace "/", [System.IO.Path]::DirectorySeparatorChar)
            $destinationParent = Split-Path -Parent $destinationPath
            if (-not [string]::IsNullOrWhiteSpace($destinationParent)) {
                New-Item -ItemType Directory -Path $destinationParent -Force | Out-Null
            }

            try {
                Move-Item -LiteralPath $candidate.resolved_path -Destination $destinationPath
                $movedItems += [pscustomobject][ordered]@{
                    original_path = $candidate.repository_path
                    quarantine_path = $destinationPath
                    moved_at_utc = Get-UtcTimestamp
                    actor = $Actor
                    reason = $Reason
                    dry_run_ref = (Get-DryRunRefForPacket -DryRunRef $DryRunRef)
                    command_evidence = @(
                        "git status --short --untracked-files=all",
                        "git ls-files -- $($candidate.repository_path)",
                        "Move-Item -LiteralPath <candidate> -Destination <outside-repo-quarantine>"
                    )
                    evidence_status = "not_evidence"
                    repo_truth_status = "not_repo_truth"
                }
            }
            catch {
                $refusalReasons += "failed to quarantine candidate '$($candidate.input_path)'. $($_.Exception.Message)"
            }
        }
    }

    $dedupedRefusals = @()
    foreach ($reasonItem in @($refusalReasons)) {
        if ([string]::IsNullOrWhiteSpace($reasonItem)) {
            continue
        }
        if ($dedupedRefusals -notcontains $reasonItem) {
            $dedupedRefusals += $reasonItem
        }
    }

    $packet = New-LocalResidueQuarantinePacket -RepositoryRoot $resolvedRepositoryRoot -Authorized:$Authorize.IsPresent -DryRunRef $DryRunRef -SourcePaths $CandidatePaths -QuarantineRoot $quarantineRootValue -MovedItems $movedItems -RefusalReasons $dedupedRefusals
    Test-LocalResidueQuarantineResultObject -QuarantineResult $packet -SourceLabel "Local residue quarantine result draft" | Out-Null

    if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
        $resolvedOutputPath = Resolve-PathValue -PathValue $OutputPath
        Write-JsonDocument -Path $resolvedOutputPath -Document $packet -Overwrite:$Overwrite
        Test-LocalResidueQuarantineResultContract -QuarantineResultPath $resolvedOutputPath | Out-Null
    }

    return $packet
}

function Assert-CommonPacketFields {
    param(
        [Parameter(Mandatory = $true)]
        $Packet,
        [Parameter(Mandatory = $true)]
        [string]$ArtifactType,
        [Parameter(Mandatory = $true)]
        [string]$SourceLabel,
        [Parameter(Mandatory = $true)]
        $Foundation,
        [Parameter(Mandatory = $true)]
        $Policy
    )

    $contractVersion = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet -Name "contract_version" -Context $SourceLabel) -Context "$SourceLabel.contract_version"
    if ($contractVersion -ne $Foundation.contract_version) {
        throw "$SourceLabel.contract_version must be '$($Foundation.contract_version)'."
    }

    $packetArtifactType = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet -Name "artifact_type" -Context $SourceLabel) -Context "$SourceLabel.artifact_type"
    if ($packetArtifactType -ne $ArtifactType) {
        throw "$SourceLabel.artifact_type must be '$ArtifactType'."
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
    if ($sourceTask -ne $Policy.source_task) {
        throw "$SourceLabel.source_task must be '$($Policy.source_task)'."
    }

    $headSha = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet -Name "head_sha" -Context $SourceLabel) -Context "$SourceLabel.head_sha"
    $treeSha = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet -Name "tree_sha" -Context $SourceLabel) -Context "$SourceLabel.tree_sha"
    Assert-MatchesPattern -Value $headSha -Pattern $Foundation.git_sha_pattern -Context "$SourceLabel.head_sha"
    Assert-MatchesPattern -Value $treeSha -Pattern $Foundation.git_sha_pattern -Context "$SourceLabel.tree_sha"

    $createdAtUtc = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet -Name "created_at_utc" -Context $SourceLabel) -Context "$SourceLabel.created_at_utc"
    Assert-TimestampValue -Value $createdAtUtc -Pattern $Foundation.timestamp_pattern -Context "$SourceLabel.created_at_utc"

    $nonClaims = Assert-StringArrayValue -Value (Get-RequiredProperty -Object $Packet -Name "non_claims" -Context $SourceLabel) -Context "$SourceLabel.non_claims"
    foreach ($requiredNonClaim in @($Policy.required_non_claims)) {
        if ($nonClaims -notcontains $requiredNonClaim) {
            throw "$SourceLabel.non_claims must include '$requiredNonClaim'."
        }
    }
}

function Test-LocalResidueScanResultObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $ScanResult,
        [string]$SourceLabel = "Local residue scan result"
    )

    $foundation = Get-CycleControllerFoundationContract
    $policy = Get-LocalResiduePolicyContract
    $contract = Get-LocalResidueScanResultContract
    Assert-RequiredObjectFields -Object $ScanResult -FieldNames @($contract.required_fields) -Context $SourceLabel
    Assert-CommonPacketFields -Packet $ScanResult -ArtifactType $policy.scan_result_artifact_type -SourceLabel $SourceLabel -Foundation $foundation -Policy $policy

    $scanId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ScanResult -Name "scan_id" -Context $SourceLabel) -Context "$SourceLabel.scan_id"
    Assert-MatchesPattern -Value $scanId -Pattern $foundation.identifier_pattern -Context "$SourceLabel.scan_id"

    $scanMode = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ScanResult -Name "scan_mode" -Context $SourceLabel) -Context "$SourceLabel.scan_mode"
    Assert-AllowedValue -Value $scanMode -AllowedValues @($policy.allowed_scan_modes) -Context "$SourceLabel.scan_mode"

    $gitStatusCommand = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ScanResult -Name "git_status_command" -Context $SourceLabel) -Context "$SourceLabel.git_status_command"
    if ($gitStatusCommand -ne $policy.scan_command) {
        throw "$SourceLabel.git_status_command must be '$($policy.scan_command)'."
    }

    Assert-StringArrayValue -Value (Get-RequiredProperty -Object $ScanResult -Name "raw_status_lines" -Context $SourceLabel) -Context "$SourceLabel.raw_status_lines" -AllowEmpty | Out-Null
    $entries = Assert-ObjectArrayValue -Value (Get-RequiredProperty -Object $ScanResult -Name "entries" -Context $SourceLabel) -Context "$SourceLabel.entries" -AllowEmpty
    Assert-BooleanValue -Value (Get-RequiredProperty -Object $ScanResult -Name "worktree_clean" -Context $SourceLabel) -Context "$SourceLabel.worktree_clean" | Out-Null
    Assert-BooleanValue -Value (Get-RequiredProperty -Object $ScanResult -Name "residue_detected" -Context $SourceLabel) -Context "$SourceLabel.residue_detected" | Out-Null
    Assert-BooleanValue -Value (Get-RequiredProperty -Object $ScanResult -Name "tracked_changes_detected" -Context $SourceLabel) -Context "$SourceLabel.tracked_changes_detected" | Out-Null
    Assert-BooleanValue -Value (Get-RequiredProperty -Object $ScanResult -Name "untracked_residue_detected" -Context $SourceLabel) -Context "$SourceLabel.untracked_residue_detected" | Out-Null
    Assert-StringArrayValue -Value (Get-RequiredProperty -Object $ScanResult -Name "quarantine_candidates" -Context $SourceLabel) -Context "$SourceLabel.quarantine_candidates" -AllowEmpty | Out-Null
    Assert-StringArrayValue -Value (Get-RequiredProperty -Object $ScanResult -Name "candidate_paths" -Context $SourceLabel) -Context "$SourceLabel.candidate_paths" -AllowEmpty | Out-Null
    Assert-ObjectArrayValue -Value (Get-RequiredProperty -Object $ScanResult -Name "candidate_path_results" -Context $SourceLabel) -Context "$SourceLabel.candidate_path_results" -AllowEmpty | Out-Null
    Assert-StringArrayValue -Value (Get-RequiredProperty -Object $ScanResult -Name "unexpected_untracked_paths" -Context $SourceLabel) -Context "$SourceLabel.unexpected_untracked_paths" -AllowEmpty | Out-Null
    Assert-StringArrayValue -Value (Get-RequiredProperty -Object $ScanResult -Name "refusal_reasons" -Context $SourceLabel) -Context "$SourceLabel.refusal_reasons" -AllowEmpty | Out-Null

    $decision = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ScanResult -Name "residue_policy_decision" -Context $SourceLabel) -Context "$SourceLabel.residue_policy_decision"
    Assert-AllowedValue -Value $decision -AllowedValues @($policy.allowed_residue_policy_decisions) -Context "$SourceLabel.residue_policy_decision"
    Assert-BooleanValue -Value (Get-RequiredProperty -Object $ScanResult -Name "residue_allowed" -Context $SourceLabel) -Context "$SourceLabel.residue_allowed" | Out-Null
    Assert-BooleanValue -Value (Get-RequiredProperty -Object $ScanResult -Name "refused" -Context $SourceLabel) -Context "$SourceLabel.refused" | Out-Null
    Assert-BooleanValue -Value (Get-RequiredProperty -Object $ScanResult -Name "quarantine_eligible" -Context $SourceLabel) -Context "$SourceLabel.quarantine_eligible" | Out-Null

    $evidencePolicy = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $ScanResult -Name "local_residue_evidence_policy" -Context $SourceLabel) -Context "$SourceLabel.local_residue_evidence_policy"
    if ($evidencePolicy -ne $contract.evidence_policy) {
        throw "$SourceLabel.local_residue_evidence_policy must be '$($contract.evidence_policy)'."
    }

    foreach ($entry in @($entries)) {
        Assert-RequiredObjectFields -Object $entry -FieldNames @($contract.entry_required_fields) -Context "$SourceLabel.entries item"
        $classification = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $entry -Name "classification" -Context "$SourceLabel.entries item") -Context "$SourceLabel.entries item.classification"
        Assert-AllowedValue -Value $classification -AllowedValues @($policy.allowed_entry_classifications) -Context "$SourceLabel.entries item.classification"
        $evidenceAllowed = Assert-BooleanValue -Value (Get-RequiredProperty -Object $entry -Name "evidence_allowed" -Context "$SourceLabel.entries item") -Context "$SourceLabel.entries item.evidence_allowed"
        if ($evidenceAllowed) {
            throw "$SourceLabel entries must never mark local-only residue as evidence."
        }
        $evidenceStatus = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $entry -Name "evidence_status" -Context "$SourceLabel.entries item") -Context "$SourceLabel.entries item.evidence_status"
        if ($evidenceStatus -ne "not_evidence") {
            throw "$SourceLabel entries must preserve evidence_status 'not_evidence'."
        }
        Assert-StringArrayValue -Value (Get-RequiredProperty -Object $entry -Name "refusal_reasons" -Context "$SourceLabel.entries item") -Context "$SourceLabel.entries item.refusal_reasons" -AllowEmpty | Out-Null
    }

    foreach ($candidate in @($ScanResult.candidate_path_results)) {
        Assert-RequiredObjectFields -Object $candidate -FieldNames @($contract.candidate_result_required_fields) -Context "$SourceLabel.candidate_path_results item"
        Assert-BooleanValue -Value (Get-RequiredProperty -Object $candidate -Name "exists" -Context "$SourceLabel.candidate_path_results item") -Context "$SourceLabel.candidate_path_results item.exists" | Out-Null
        Assert-BooleanValue -Value (Get-RequiredProperty -Object $candidate -Name "already_absent" -Context "$SourceLabel.candidate_path_results item") -Context "$SourceLabel.candidate_path_results item.already_absent" | Out-Null
        Assert-BooleanValue -Value (Get-RequiredProperty -Object $candidate -Name "tracked" -Context "$SourceLabel.candidate_path_results item") -Context "$SourceLabel.candidate_path_results item.tracked" | Out-Null
        Assert-BooleanValue -Value (Get-RequiredProperty -Object $candidate -Name "quarantine_eligible" -Context "$SourceLabel.candidate_path_results item") -Context "$SourceLabel.candidate_path_results item.quarantine_eligible" | Out-Null
        Assert-StringArrayValue -Value (Get-RequiredProperty -Object $candidate -Name "covered_untracked_paths" -Context "$SourceLabel.candidate_path_results item") -Context "$SourceLabel.candidate_path_results item.covered_untracked_paths" -AllowEmpty | Out-Null
        Assert-StringArrayValue -Value (Get-RequiredProperty -Object $candidate -Name "refusal_reasons" -Context "$SourceLabel.candidate_path_results item") -Context "$SourceLabel.candidate_path_results item.refusal_reasons" -AllowEmpty | Out-Null
    }

    if ($decision -eq "quarantine_eligible" -and ($scanMode -ne "dry-run" -or @($ScanResult.refusal_reasons).Count -ne 0)) {
        throw "$SourceLabel can be quarantine_eligible only for a clean dry-run result."
    }

    $PSCmdlet.WriteObject([pscustomobject]@{
        IsValid = $true
        ScanId = $scanId
        ScanMode = $scanMode
        Decision = $decision
        WorktreeClean = [bool]$ScanResult.worktree_clean
        RefusalCount = @($ScanResult.refusal_reasons).Count
        SourceLabel = $SourceLabel
    }, $false)
}

function Test-LocalResidueScanResultContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScanResultPath
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $ScanResultPath -Label "Local residue scan result"
    $document = Get-JsonDocument -Path $resolvedPath -Label "Local residue scan result"
    $validation = Test-LocalResidueScanResultObject -ScanResult $document -SourceLabel "Local residue scan result"
    $PSCmdlet.WriteObject($validation, $false)
}

function Test-LocalResidueQuarantineResultObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $QuarantineResult,
        [string]$SourceLabel = "Local residue quarantine result"
    )

    $foundation = Get-CycleControllerFoundationContract
    $policy = Get-LocalResiduePolicyContract
    $contract = Get-LocalResidueQuarantineResultContract
    Assert-RequiredObjectFields -Object $QuarantineResult -FieldNames @($contract.required_fields) -Context $SourceLabel
    Assert-CommonPacketFields -Packet $QuarantineResult -ArtifactType $policy.quarantine_result_artifact_type -SourceLabel $SourceLabel -Foundation $foundation -Policy $policy

    $quarantineId = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $QuarantineResult -Name "quarantine_id" -Context $SourceLabel) -Context "$SourceLabel.quarantine_id"
    Assert-MatchesPattern -Value $quarantineId -Pattern $foundation.identifier_pattern -Context "$SourceLabel.quarantine_id"
    $authorized = Assert-BooleanValue -Value (Get-RequiredProperty -Object $QuarantineResult -Name "authorized" -Context $SourceLabel) -Context "$SourceLabel.authorized"
    $dryRunRef = Get-RequiredProperty -Object $QuarantineResult -Name "dry_run_ref" -Context $SourceLabel
    if ($dryRunRef -isnot [string]) {
        throw "$SourceLabel.dry_run_ref must be a string."
    }
    if ($authorized -and [string]::IsNullOrWhiteSpace($dryRunRef)) {
        throw "$SourceLabel.dry_run_ref is required when quarantine is authorized."
    }

    Assert-StringArrayValue -Value (Get-RequiredProperty -Object $QuarantineResult -Name "source_paths" -Context $SourceLabel) -Context "$SourceLabel.source_paths" -AllowEmpty | Out-Null
    $quarantineRoot = Get-RequiredProperty -Object $QuarantineResult -Name "quarantine_root" -Context $SourceLabel
    if ($quarantineRoot -isnot [string]) {
        throw "$SourceLabel.quarantine_root must be a string."
    }
    $movedItems = Assert-ObjectArrayValue -Value (Get-RequiredProperty -Object $QuarantineResult -Name "moved_items" -Context $SourceLabel) -Context "$SourceLabel.moved_items" -AllowEmpty
    $refusalReasons = Assert-StringArrayValue -Value (Get-RequiredProperty -Object $QuarantineResult -Name "refusal_reasons" -Context $SourceLabel) -Context "$SourceLabel.refusal_reasons" -AllowEmpty

    if ($authorized -and $refusalReasons.Count -eq 0 -and $movedItems.Count -eq 0) {
        throw "$SourceLabel authorized successful quarantine must record moved_items."
    }

    foreach ($item in @($movedItems)) {
        Assert-RequiredObjectFields -Object $item -FieldNames @($contract.moved_item_required_fields) -Context "$SourceLabel.moved_items item"
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "original_path" -Context "$SourceLabel.moved_items item") -Context "$SourceLabel.moved_items item.original_path" | Out-Null
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "quarantine_path" -Context "$SourceLabel.moved_items item") -Context "$SourceLabel.moved_items item.quarantine_path" | Out-Null
        $movedAtUtc = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "moved_at_utc" -Context "$SourceLabel.moved_items item") -Context "$SourceLabel.moved_items item.moved_at_utc"
        Assert-TimestampValue -Value $movedAtUtc -Pattern $foundation.timestamp_pattern -Context "$SourceLabel.moved_items item.moved_at_utc"
        Assert-StringArrayValue -Value (Get-RequiredProperty -Object $item -Name "command_evidence" -Context "$SourceLabel.moved_items item") -Context "$SourceLabel.moved_items item.command_evidence" | Out-Null
        $evidenceStatus = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "evidence_status" -Context "$SourceLabel.moved_items item") -Context "$SourceLabel.moved_items item.evidence_status"
        if ($evidenceStatus -ne "not_evidence") {
            throw "$SourceLabel moved_items must preserve evidence_status 'not_evidence'."
        }
        $repoTruthStatus = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $item -Name "repo_truth_status" -Context "$SourceLabel.moved_items item") -Context "$SourceLabel.moved_items item.repo_truth_status"
        if ($repoTruthStatus -ne "not_repo_truth") {
            throw "$SourceLabel moved_items must preserve repo_truth_status 'not_repo_truth'."
        }
    }

    $PSCmdlet.WriteObject([pscustomobject]@{
        IsValid = $true
        QuarantineId = $quarantineId
        Authorized = $authorized
        MovedCount = $movedItems.Count
        RefusalCount = $refusalReasons.Count
        SourceLabel = $SourceLabel
    }, $false)
}

function Test-LocalResidueQuarantineResultContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$QuarantineResultPath
    )

    $resolvedPath = Resolve-ExistingPath -PathValue $QuarantineResultPath -Label "Local residue quarantine result"
    $document = Get-JsonDocument -Path $resolvedPath -Label "Local residue quarantine result"
    $validation = Test-LocalResidueQuarantineResultObject -QuarantineResult $document -SourceLabel "Local residue quarantine result"
    $PSCmdlet.WriteObject($validation, $false)
}

Export-ModuleMember -Function Invoke-LocalResidueScan, Invoke-LocalResidueDryRun, Invoke-LocalResidueQuarantine, Test-LocalResidueScanResultContract, Test-LocalResidueScanResultObject, Test-LocalResidueQuarantineResultContract, Test-LocalResidueQuarantineResultObject
