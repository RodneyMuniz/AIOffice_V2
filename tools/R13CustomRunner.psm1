Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$script:R13RepositoryName = "AIOffice_V2"
$script:R13Branch = "release/r13-api-first-qa-pipeline-and-operator-control-room-product-slice"
$script:R13Milestone = "R13 API-First QA Pipeline and Operator Control-Room Product Slice"
$script:R13SourceTask = "R13-007"
$script:GitObjectPattern = "^[a-f0-9]{40}$"
$script:TimestampPattern = "^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$"
$script:AllowedRequestedOperations = @(
    "validate_artifacts",
    "run_bounded_validation_commands",
    "summarize_existing_evidence",
    "dry_run_only"
)
$script:AllowedExecutionStatuses = @("completed", "blocked", "failed")
$script:AllowedAggregateVerdicts = @("passed", "failed", "blocked")
$script:AllowedCommandVerdicts = @("passed", "failed", "blocked")
$script:RequiredNonClaims = @(
    "R13-007 adds a local API-shaped/custom-runner foundation only",
    "no production API server delivered by R13-007",
    "no mutation commands are authorized or executed by R13-007 evidence",
    "no external replay has occurred",
    "no skill invocation has occurred",
    "no final QA signoff has occurred",
    "no R13 hard value gate delivered by R13-007",
    "no API/custom-runner bypass gate fully delivered by R13-007",
    "no current operator control-room gate delivered by R13-007",
    "no operator demo gate delivered by R13-007",
    "no R14 or successor opening"
)

function Get-RepositoryRoot {
    return $repoRoot
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

function Convert-ToRepositoryRelativePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue
    )

    $fullPath = [System.IO.Path]::GetFullPath((Resolve-RepositoryPath -PathValue $PathValue))
    $rootPath = [System.IO.Path]::GetFullPath((Get-RepositoryRoot)).TrimEnd([char[]]@([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar))
    if ($fullPath.Equals($rootPath, [System.StringComparison]::OrdinalIgnoreCase)) {
        return "."
    }
    if ($fullPath.StartsWith($rootPath + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $fullPath.Substring($rootPath.Length + 1).Replace("\", "/")
    }

    return $PathValue.Replace("\", "/")
}

function Test-IsInsideRepository {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue
    )

    $fullPath = [System.IO.Path]::GetFullPath($PathValue)
    $rootPath = [System.IO.Path]::GetFullPath((Get-RepositoryRoot)).TrimEnd([char[]]@([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar))
    return $fullPath.Equals($rootPath, [System.StringComparison]::OrdinalIgnoreCase) -or $fullPath.StartsWith($rootPath + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)
}

function Test-RepositoryRelativePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue
    )

    if ([string]::IsNullOrWhiteSpace($PathValue)) {
        return $false
    }
    if ($PathValue -match '^https?://') {
        return $false
    }
    if ([System.IO.Path]::IsPathRooted($PathValue) -or $PathValue -match '(^|[\\/])\.\.([\\/]|$)') {
        return $false
    }

    return Test-IsInsideRepository -PathValue (Resolve-RepositoryPath -PathValue $PathValue)
}

function Assert-RepositoryRelativePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if (-not (Test-RepositoryRelativePath -PathValue $PathValue)) {
        throw "$Context must be a repository-relative path inside the repository."
    }
}

function Assert-ExistingRef {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Ref,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-RepositoryRelativePath -PathValue $Ref -Context $Context
    if (-not (Test-Path -LiteralPath (Resolve-RepositoryPath -PathValue $Ref))) {
        throw "$Context '$Ref' does not exist."
    }
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

function Get-R13CustomRunnerRequestContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\runner\r13_custom_runner_request.contract.json") -Label "R13 custom runner request contract"
}

function Get-R13CustomRunnerResultContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\runner\r13_custom_runner_result.contract.json") -Label "R13 custom runner result contract"
}

function Write-R13CustomRunnerJsonFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        $Value
    )

    $resolvedPath = Resolve-RepositoryPath -PathValue $Path
    $parentPath = Split-Path -Parent $resolvedPath
    if (-not [string]::IsNullOrWhiteSpace($parentPath)) {
        New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    }

    $json = [string]::Join("`n", @($Value | ConvertTo-Json -Depth 100))
    $json = ($json -replace "`r`n", "`n") -replace "`r", "`n"
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($resolvedPath, $json.TrimEnd() + "`n", $utf8NoBom)
}

function Write-TextFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    $resolvedPath = Resolve-RepositoryPath -PathValue $Path
    $parentPath = Split-Path -Parent $resolvedPath
    if (-not [string]::IsNullOrWhiteSpace($parentPath)) {
        New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    }

    $text = ($Value -replace "`r`n", "`n") -replace "`r", "`n"
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($resolvedPath, $text, $utf8NoBom)
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
        [string]$Context
    )

    if ($Value -isnot [int] -and $Value -isnot [long]) {
        throw "$Context must be an integer."
    }

    return [int]$Value
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

function Assert-GitObjectId {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $text = Assert-NonEmptyString -Value $Value -Context $Context
    if ($text -notmatch $script:GitObjectPattern) {
        throw "$Context must be a 40-character Git object ID."
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
}

function Invoke-GitLine {
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

    return ([string](@($output)[0])).Trim()
}

function Get-GitIdentity {
    return [pscustomobject][ordered]@{
        Branch = Invoke-GitLine -Arguments @("branch", "--show-current")
        Head = Invoke-GitLine -Arguments @("rev-parse", "HEAD")
        Tree = Invoke-GitLine -Arguments @("rev-parse", "HEAD^{tree}")
    }
}

function Get-StableId {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Prefix,
        [Parameter(Mandatory = $true)]
        [string]$Key
    )

    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Key.ToLowerInvariant())
        $hash = $sha.ComputeHash($bytes)
    }
    finally {
        $sha.Dispose()
    }

    $hex = -join ($hash[0..7] | ForEach-Object { $_.ToString("x2", [System.Globalization.CultureInfo]::InvariantCulture) })
    return "$Prefix-$hex"
}

function Get-StringLeaves {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value
    )

    if ($null -eq $Value) {
        return
    }
    if ($Value -is [string]) {
        $PSCmdlet.WriteObject($Value, $false)
        return
    }
    if ($Value -is [System.Collections.IDictionary]) {
        foreach ($entry in $Value.GetEnumerator()) {
            Get-StringLeaves -Value $entry.Value
        }
        return
    }
    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
        foreach ($item in $Value) {
            Get-StringLeaves -Value $item
        }
        return
    }
    if ($Value -is [pscustomobject]) {
        foreach ($property in @($Value.PSObject.Properties)) {
            Get-StringLeaves -Value $property.Value
        }
    }
}

function Test-LineHasNegation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Line
    )

    return ($Line -match '(?i)\b(no|not|without|cannot|must not|does not|do not|is not|are not|did not|non-claim|non_claim|refuse|refuses|blocked|planned only|not yet delivered|pending|future|not complete|still not|rejects|rejected)\b')
}

function Assert-NoForbiddenR13RunnerClaims {
    param(
        [Parameter(Mandatory = $true)]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($line in @(Get-StringLeaves -Value $Value)) {
        if ($line -match '(?i)\bexternal[_ -]?replay\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims external replay. Offending text: $line"
        }
        if ($line -match '(?i)\bskill[_ -]?invocation\b|\binvoked skill\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims skill invocation. Offending text: $line"
        }
        if ($line -match '(?i)\bsignoff\b|\bsign-off\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims final signoff. Offending text: $line"
        }
        if ($line -match '(?i)\b(hard\s+)?R13\s+hard\s+value\s+gate\b|\bhard\s+value\s+gate\b|\bmeaningful\s+QA\s+loop\b.*\b(delivered|complete|passed)\b|\bAPI/custom-runner bypass\b.*\b(delivered|complete|passed)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims R13 hard value gate or API/custom-runner bypass delivery. Offending text: $line"
        }
        if ($line -match '(?i)\bproduction API server\b|\bproduction runtime\b|\breal production QA\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims production runtime or production QA. Offending text: $line"
        }
        if ($line -match '(?i)\bR14\b.*\b(active|open|opened)\b|\bsuccessor milestone\b.*\b(active|open|opened)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims R14 or successor milestone opening. Offending text: $line"
        }
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

function Assert-StandardIdentity {
    param(
        [Parameter(Mandatory = $true)]
        $Artifact,
        [Parameter(Mandatory = $true)]
        [string]$SourceLabel
    )

    if ($Artifact.repository -ne $script:R13RepositoryName) {
        throw "$SourceLabel repository must be '$script:R13RepositoryName'."
    }
    if ($Artifact.branch -ne $script:R13Branch) {
        throw "$SourceLabel branch must be '$script:R13Branch'."
    }
    Assert-GitObjectId -Value $Artifact.head -Context "$SourceLabel head"
    Assert-GitObjectId -Value $Artifact.tree -Context "$SourceLabel tree"
    if ($Artifact.source_milestone -ne $script:R13Milestone) {
        throw "$SourceLabel source_milestone must be '$script:R13Milestone'."
    }
    if ($Artifact.source_task -ne $script:R13SourceTask) {
        throw "$SourceLabel source_task must be '$script:R13SourceTask'."
    }
}

function Assert-RefArray {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [switch]$AllowEmpty,
        [switch]$RequireExists
    )

    $refs = Assert-ObjectArray -Value $Value -Context $Context -AllowEmpty:$AllowEmpty
    $refIds = @{}
    foreach ($refObject in @($refs)) {
        Assert-RequiredObjectFields -Object $refObject -FieldNames @("ref_id", "ref", "evidence_kind", "authority_kind", "scope") -Context $Context
        $refId = Assert-NonEmptyString -Value $refObject.ref_id -Context "$Context ref_id"
        if ($refIds.ContainsKey($refId)) {
            throw "$Context contains duplicate ref_id '$refId'."
        }
        $refIds[$refId] = $true
        $ref = Assert-NonEmptyString -Value $refObject.ref -Context "$Context ref"
        Assert-RepositoryRelativePath -PathValue $ref -Context "$Context ref"
        if ($RequireExists -and -not (Test-Path -LiteralPath (Resolve-RepositoryPath -PathValue $ref))) {
            throw "$Context ref '$ref' does not exist."
        }
        Assert-NonEmptyString -Value $refObject.evidence_kind -Context "$Context evidence_kind" | Out-Null
        Assert-NonEmptyString -Value $refObject.authority_kind -Context "$Context authority_kind" | Out-Null
        Assert-NonEmptyString -Value $refObject.scope -Context "$Context scope" | Out-Null
    }

    $PSCmdlet.WriteObject($refs, $false)
}

function Assert-AllowedPaths {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $paths = Assert-StringArray -Value $Value -Context $Context
    foreach ($path in @($paths)) {
        $normalized = $path.Replace("\", "/")
        if ($normalized -eq "." -or $normalized -eq "state" -or $normalized -eq "state/cycles" -or $normalized -eq "state/runner" -or $normalized -eq "tools" -or $normalized -eq "tests") {
            throw "$Context contains overly broad path '$path'."
        }
        Assert-RepositoryRelativePath -PathValue $path -Context "$Context item"
    }

    $PSCmdlet.WriteObject($paths, $false)
}

function Test-RefWithinAllowedPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Ref,
        [Parameter(Mandatory = $true)]
        [string[]]$AllowedPaths
    )

    $normalizedRef = $Ref.Replace("\", "/").TrimEnd("/")
    foreach ($allowedPath in @($AllowedPaths)) {
        $normalizedAllowed = $allowedPath.Replace("\", "/").TrimEnd("/")
        if ($normalizedRef.Equals($normalizedAllowed, [System.StringComparison]::OrdinalIgnoreCase) -or $normalizedRef.StartsWith($normalizedAllowed + "/", [System.StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }

    return $false
}

function Assert-OutputRoot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$OutputRoot,
        [Parameter(Mandatory = $true)]
        [string[]]$AllowedPaths
    )

    $normalized = $OutputRoot.Replace("\", "/").TrimEnd("/")
    Assert-RepositoryRelativePath -PathValue $normalized -Context "output_root"
    if ($normalized -notmatch '^state/(cycles|runner)/.+') {
        throw "output_root must be inside state/cycles or state/runner."
    }
    if (-not (Test-RefWithinAllowedPath -Ref $normalized -AllowedPaths $AllowedPaths)) {
        throw "output_root must be covered by allowed_paths."
    }
}

function Assert-CommandHasNoForbiddenMutation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Command -match '(?i)\bgit\s+(commit|push|reset|clean|rm|checkout|switch|merge|rebase)\b') {
        throw "$Context contains a forbidden git mutation command."
    }
    if ($Command -match '(?i)\b(Remove-Item|Set-Content|Add-Content|Out-File|New-Item|Copy-Item|Move-Item|Rename-Item|del|erase|rmdir|mkdir)\b') {
        throw "$Context contains a forbidden file mutation command."
    }
    if ($Command -match '(^|\s)(\.{2}[\\/]|[A-Za-z]:\\|/)') {
        throw "$Context contains an outside-repo or absolute path token."
    }
}

function Assert-AllowedCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-CommandHasNoForbiddenMutation -Command $Command -Context $Context

    $normalized = ($Command.Trim() -replace '/', '\')
    if ($normalized -match '^powershell\s+-NoProfile\s+-ExecutionPolicy\s+Bypass\s+-File\s+tests\\[^ ]+\.ps1(?:\s+.*)?$') {
        return $true
    }
    if ($normalized -match '^powershell\s+-NoProfile\s+-ExecutionPolicy\s+Bypass\s+-File\s+tools\\validate_[^ ]+\.ps1(?:\s+.*)?$') {
        return $true
    }

    $allowedGitCommands = @(
        "git status --short --untracked-files=all",
        "git rev-parse HEAD",
        "git rev-parse HEAD^{tree}",
        "git rev-parse `"HEAD^{tree}`"",
        "git branch --show-current",
        "git diff --check"
    )
    if ($allowedGitCommands -contains $Command.Trim()) {
        return $true
    }

    throw "$Context is not an approved R13-007 non-destructive command."
}

function Assert-AllowedCommands {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $commands = Assert-ObjectArray -Value $Value -Context $Context
    $commandIds = @{}
    foreach ($commandObject in @($commands)) {
        Assert-RequiredObjectFields -Object $commandObject -FieldNames @("command_id", "command") -Context $Context
        $commandId = Assert-NonEmptyString -Value $commandObject.command_id -Context "$Context command_id"
        if ($commandIds.ContainsKey($commandId)) {
            throw "$Context contains duplicate command_id '$commandId'."
        }
        $commandIds[$commandId] = $true
        $command = Assert-NonEmptyString -Value $commandObject.command -Context "$Context command"
        Assert-AllowedCommand -Command $command -Context "$Context command '$commandId'" | Out-Null
    }

    $PSCmdlet.WriteObject($commands, $false)
}

function Assert-ExecutionProfile {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $profile = Assert-ObjectValue -Value $Value -Context $Context
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $profile -Name "profile_id" -Context $Context) -Context "$Context profile_id" | Out-Null
    Assert-NonEmptyString -Value (Get-RequiredProperty -Object $profile -Name "runner_kind" -Context $Context) -Context "$Context runner_kind" | Out-Null
    $mutationAllowed = Assert-BooleanValue -Value (Get-RequiredProperty -Object $profile -Name "mutation_allowed" -Context $Context) -Context "$Context mutation_allowed"
    $destructiveCommandsAllowed = Assert-BooleanValue -Value (Get-RequiredProperty -Object $profile -Name "destructive_commands_allowed" -Context $Context) -Context "$Context destructive_commands_allowed"
    if ($mutationAllowed) {
        throw "$Context mutation_allowed must be false for R13-007."
    }
    if ($destructiveCommandsAllowed) {
        throw "$Context destructive_commands_allowed must be false for R13-007."
    }
}

function Assert-OperatorApproval {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $approval = Assert-ObjectValue -Value $Value -Context $Context
    Assert-RequiredObjectFields -Object $approval -FieldNames @("approval_status", "approved_by", "approved_at_utc", "approval_scope") -Context $Context
    $status = Assert-NonEmptyString -Value $approval.approval_status -Context "$Context approval_status"
    if ($status -ne "approved_for_local_non_mutating_validation") {
        throw "$Context approval_status must be approved_for_local_non_mutating_validation."
    }
    Assert-NonEmptyString -Value $approval.approved_by -Context "$Context approved_by" | Out-Null
    Assert-TimestampString -Value $approval.approved_at_utc -Context "$Context approved_at_utc"
    $scope = Assert-NonEmptyString -Value $approval.approval_scope -Context "$Context approval_scope"
    if ($scope -notmatch '(?i)non[- ]?mutating|validation') {
        throw "$Context approval_scope must explicitly scope local non-mutating validation."
    }
}

function Split-SimpleCommandLine {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command
    )

    $matches = [regex]::Matches($Command, '(?:"([^"]*)"|(\S+))')
    foreach ($match in $matches) {
        if ($match.Groups[1].Success) {
            $PSCmdlet.WriteObject($match.Groups[1].Value, $false)
        }
        else {
            $PSCmdlet.WriteObject($match.Groups[2].Value, $false)
        }
    }
}

function New-EvidenceRef {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RefId,
        [Parameter(Mandatory = $true)]
        [string]$Ref,
        [Parameter(Mandatory = $true)]
        [string]$EvidenceKind,
        [string]$AuthorityKind = "repo_tooling",
        [string]$Scope = "repo"
    )

    return [pscustomobject][ordered]@{
        ref_id = $RefId
        ref = $Ref.Replace("\", "/")
        evidence_kind = $EvidenceKind
        authority_kind = $AuthorityKind
        scope = $Scope
    }
}

function Invoke-RunnerCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $CommandObject,
        [Parameter(Mandatory = $true)]
        [int]$Index,
        [Parameter(Mandatory = $true)]
        [string]$OutputRoot
    )

    $commandId = [string]$CommandObject.command_id
    $command = [string]$CommandObject.command
    $number = $Index.ToString("000", [System.Globalization.CultureInfo]::InvariantCulture)
    $stdoutRef = (Join-Path $OutputRoot ("command_{0}_{1}_stdout.log" -f $number, $commandId)).Replace("\", "/")
    $stderrRef = (Join-Path $OutputRoot ("command_{0}_{1}_stderr.log" -f $number, $commandId)).Replace("\", "/")
    $stdoutPath = Resolve-RepositoryPath -PathValue $stdoutRef
    $stderrPath = Resolve-RepositoryPath -PathValue $stderrRef
    New-Item -ItemType Directory -Path (Split-Path -Parent $stdoutPath) -Force | Out-Null

    $startedAt = Get-UtcTimestamp
    $tokens = @(Split-SimpleCommandLine -Command $command)
    if ($tokens.Count -eq 0) {
        Write-TextFile -Path $stdoutRef -Value ""
        Write-TextFile -Path $stderrRef -Value "Command could not be tokenized."
        return [pscustomobject][ordered]@{
            CommandResult = [pscustomobject][ordered]@{
                command_id = $commandId
                command = $command
                exit_code = -1
                verdict = "blocked"
                stdout_ref = $stdoutRef
                stderr_ref = $stderrRef
                started_at_utc = $startedAt
                completed_at_utc = Get-UtcTimestamp
            }
            RefusalReason = "Command '$commandId' could not be tokenized."
        }
    }

    $filePath = $tokens[0]
    $arguments = @()
    if ($tokens.Count -gt 1) {
        $arguments = @($tokens[1..($tokens.Count - 1)])
    }

    try {
        $process = Start-Process -FilePath $filePath -ArgumentList $arguments -WorkingDirectory (Get-RepositoryRoot) -NoNewWindow -Wait -PassThru -RedirectStandardOutput $stdoutPath -RedirectStandardError $stderrPath
        $exitCode = [int]$process.ExitCode
        $verdict = if ($exitCode -eq 0) { "passed" } else { "failed" }
        $refusalReason = $null
    }
    catch {
        Write-TextFile -Path $stdoutRef -Value ""
        Write-TextFile -Path $stderrRef -Value $_.Exception.Message
        $exitCode = -1
        $verdict = "blocked"
        $refusalReason = "Dependency failure while running command '$commandId': $($_.Exception.Message)"
    }

    return [pscustomobject][ordered]@{
        CommandResult = [pscustomobject][ordered]@{
            command_id = $commandId
            command = $command
            exit_code = $exitCode
            verdict = $verdict
            stdout_ref = $stdoutRef
            stderr_ref = $stderrRef
            started_at_utc = $startedAt
            completed_at_utc = Get-UtcTimestamp
        }
        RefusalReason = $refusalReason
    }
}

function New-BlockedRunnerResult {
    param(
        [Parameter(Mandatory = $true)]
        $Request,
        [Parameter(Mandatory = $true)]
        [string[]]$RefusalReasons,
        [Parameter(Mandatory = $true)]
        [string]$StartedAtUtc
    )

    return [pscustomobject][ordered]@{
        contract_version = "v1"
        artifact_type = "r13_custom_runner_result"
        result_id = Get-StableId -Prefix "r13crr" -Key "$($Request.request_id)|blocked|$([string]::Join('|', $RefusalReasons))"
        request_id = [string]$Request.request_id
        repository = $script:R13RepositoryName
        branch = [string]$Request.branch
        head = [string]$Request.head
        tree = [string]$Request.tree
        source_milestone = $script:R13Milestone
        source_task = $script:R13SourceTask
        requested_operation = [string]$Request.requested_operation
        execution_profile = $Request.execution_profile
        execution_status = "blocked"
        command_results = @()
        artifact_results = @()
        output_refs = @()
        aggregate_verdict = "blocked"
        evidence_refs = @(
            (New-EvidenceRef -RefId "r13-custom-runner-result-contract" -Ref "contracts/runner/r13_custom_runner_result.contract.json" -EvidenceKind "contract" -AuthorityKind "repo_contract"),
            (New-EvidenceRef -RefId "r13-custom-runner-module" -Ref "tools/R13CustomRunner.psm1" -EvidenceKind "module")
        )
        refusal_reasons = @($RefusalReasons)
        started_at_utc = $StartedAtUtc
        completed_at_utc = Get-UtcTimestamp
        non_claims = @($script:RequiredNonClaims)
    }
}

function Test-R13CustomRunnerRequestObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Request,
        [string]$SourceLabel = "R13 custom runner request"
    )

    $requiredFields = @(
        "contract_version",
        "artifact_type",
        "request_id",
        "repository",
        "branch",
        "head",
        "tree",
        "source_milestone",
        "source_task",
        "requested_operation",
        "execution_profile",
        "input_refs",
        "allowed_paths",
        "allowed_commands",
        "output_root",
        "expected_result_ref",
        "operator_approval",
        "evidence_refs",
        "refusal_reasons",
        "created_at_utc",
        "non_claims"
    )
    Assert-RequiredObjectFields -Object $Request -FieldNames $requiredFields -Context $SourceLabel

    if ($Request.contract_version -ne "v1") {
        throw "$SourceLabel contract_version must be v1."
    }
    if ($Request.artifact_type -ne "r13_custom_runner_request") {
        throw "$SourceLabel artifact_type must be r13_custom_runner_request."
    }
    $requestId = Assert-NonEmptyString -Value $Request.request_id -Context "$SourceLabel request_id"
    Assert-StandardIdentity -Artifact $Request -SourceLabel $SourceLabel
    $requestedOperation = Assert-NonEmptyString -Value $Request.requested_operation -Context "$SourceLabel requested_operation"
    Assert-AllowedValue -Value $requestedOperation -AllowedValues $script:AllowedRequestedOperations -Context "$SourceLabel requested_operation"
    Assert-ExecutionProfile -Value $Request.execution_profile -Context "$SourceLabel execution_profile"
    $inputRefs = Assert-RefArray -Value $Request.input_refs -Context "$SourceLabel input_refs" -RequireExists
    $allowedPaths = Assert-AllowedPaths -Value $Request.allowed_paths -Context "$SourceLabel allowed_paths"
    $allowedCommands = Assert-AllowedCommands -Value $Request.allowed_commands -Context "$SourceLabel allowed_commands"
    $outputRoot = Assert-NonEmptyString -Value $Request.output_root -Context "$SourceLabel output_root"
    Assert-OutputRoot -OutputRoot $outputRoot -AllowedPaths $allowedPaths
    $expectedResultRef = Assert-NonEmptyString -Value $Request.expected_result_ref -Context "$SourceLabel expected_result_ref"
    Assert-RepositoryRelativePath -PathValue $expectedResultRef -Context "$SourceLabel expected_result_ref"
    if (-not (Test-RefWithinAllowedPath -Ref $expectedResultRef -AllowedPaths $allowedPaths)) {
        throw "$SourceLabel expected_result_ref must be covered by allowed_paths."
    }
    foreach ($inputRef in @($inputRefs)) {
        if (-not (Test-RefWithinAllowedPath -Ref ([string]$inputRef.ref) -AllowedPaths $allowedPaths)) {
            throw "$SourceLabel input ref '$($inputRef.ref)' must be covered by allowed_paths."
        }
    }
    Assert-OperatorApproval -Value $Request.operator_approval -Context "$SourceLabel operator_approval"
    Assert-RefArray -Value $Request.evidence_refs -Context "$SourceLabel evidence_refs" -RequireExists | Out-Null
    Assert-StringArray -Value $Request.refusal_reasons -Context "$SourceLabel refusal_reasons" -AllowEmpty | Out-Null
    Assert-TimestampString -Value $Request.created_at_utc -Context "$SourceLabel created_at_utc"
    $nonClaims = Assert-StringArray -Value $Request.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel
    Assert-NoForbiddenR13RunnerClaims -Value $Request -Context $SourceLabel

    return [pscustomobject][ordered]@{
        RequestId = $requestId
        RequestedOperation = $requestedOperation
        CommandCount = @($allowedCommands).Count
        InputRefCount = @($inputRefs).Count
        OutputRoot = $outputRoot
        ExpectedResultRef = $expectedResultRef
    }
}

function Test-R13CustomRunnerRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RequestPath
    )

    $request = Get-JsonDocument -Path $RequestPath -Label "R13 custom runner request"
    return Test-R13CustomRunnerRequestObject -Request $request -SourceLabel "R13 custom runner request"
}

function Test-R13CustomRunnerResultObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Result,
        [string]$SourceLabel = "R13 custom runner result"
    )

    $requiredFields = @(
        "contract_version",
        "artifact_type",
        "result_id",
        "request_id",
        "repository",
        "branch",
        "head",
        "tree",
        "source_milestone",
        "source_task",
        "requested_operation",
        "execution_profile",
        "execution_status",
        "command_results",
        "artifact_results",
        "output_refs",
        "aggregate_verdict",
        "evidence_refs",
        "refusal_reasons",
        "started_at_utc",
        "completed_at_utc",
        "non_claims"
    )
    Assert-RequiredObjectFields -Object $Result -FieldNames $requiredFields -Context $SourceLabel

    if ($Result.contract_version -ne "v1") {
        throw "$SourceLabel contract_version must be v1."
    }
    if ($Result.artifact_type -ne "r13_custom_runner_result") {
        throw "$SourceLabel artifact_type must be r13_custom_runner_result."
    }
    $resultId = Assert-NonEmptyString -Value $Result.result_id -Context "$SourceLabel result_id"
    $requestId = Assert-NonEmptyString -Value $Result.request_id -Context "$SourceLabel request_id"
    Assert-StandardIdentity -Artifact $Result -SourceLabel $SourceLabel
    $requestedOperation = Assert-NonEmptyString -Value $Result.requested_operation -Context "$SourceLabel requested_operation"
    Assert-AllowedValue -Value $requestedOperation -AllowedValues $script:AllowedRequestedOperations -Context "$SourceLabel requested_operation"
    Assert-ExecutionProfile -Value $Result.execution_profile -Context "$SourceLabel execution_profile"
    $executionStatus = Assert-NonEmptyString -Value $Result.execution_status -Context "$SourceLabel execution_status"
    Assert-AllowedValue -Value $executionStatus -AllowedValues $script:AllowedExecutionStatuses -Context "$SourceLabel execution_status"
    $aggregateVerdict = Assert-NonEmptyString -Value $Result.aggregate_verdict -Context "$SourceLabel aggregate_verdict"
    Assert-AllowedValue -Value $aggregateVerdict -AllowedValues $script:AllowedAggregateVerdicts -Context "$SourceLabel aggregate_verdict"

    $commandResults = Assert-ObjectArray -Value $Result.command_results -Context "$SourceLabel command_results" -AllowEmpty
    $passedCount = 0
    $failedCount = 0
    $blockedCount = 0
    foreach ($commandResult in @($commandResults)) {
        Assert-RequiredObjectFields -Object $commandResult -FieldNames @("command_id", "command", "exit_code", "verdict", "stdout_ref", "stderr_ref", "started_at_utc", "completed_at_utc") -Context "$SourceLabel command_results"
        Assert-NonEmptyString -Value $commandResult.command_id -Context "$SourceLabel command_results command_id" | Out-Null
        $command = Assert-NonEmptyString -Value $commandResult.command -Context "$SourceLabel command_results command"
        Assert-AllowedCommand -Command $command -Context "$SourceLabel command_results command" | Out-Null
        Assert-IntegerValue -Value $commandResult.exit_code -Context "$SourceLabel command_results exit_code" | Out-Null
        $verdict = Assert-NonEmptyString -Value $commandResult.verdict -Context "$SourceLabel command_results verdict"
        Assert-AllowedValue -Value $verdict -AllowedValues $script:AllowedCommandVerdicts -Context "$SourceLabel command_results verdict"
        if ($verdict -eq "passed") { $passedCount += 1 }
        if ($verdict -eq "failed") { $failedCount += 1 }
        if ($verdict -eq "blocked") { $blockedCount += 1 }
        Assert-ExistingRef -Ref (Assert-NonEmptyString -Value $commandResult.stdout_ref -Context "$SourceLabel command_results stdout_ref") -Context "$SourceLabel command_results stdout_ref"
        Assert-ExistingRef -Ref (Assert-NonEmptyString -Value $commandResult.stderr_ref -Context "$SourceLabel command_results stderr_ref") -Context "$SourceLabel command_results stderr_ref"
        Assert-TimestampString -Value $commandResult.started_at_utc -Context "$SourceLabel command_results started_at_utc"
        Assert-TimestampString -Value $commandResult.completed_at_utc -Context "$SourceLabel command_results completed_at_utc"
    }

    $artifactResults = Assert-ObjectArray -Value $Result.artifact_results -Context "$SourceLabel artifact_results" -AllowEmpty
    foreach ($artifactResult in @($artifactResults)) {
        Assert-RequiredObjectFields -Object $artifactResult -FieldNames @("artifact_id", "ref", "evidence_kind", "validation_status") -Context "$SourceLabel artifact_results"
        Assert-NonEmptyString -Value $artifactResult.artifact_id -Context "$SourceLabel artifact_results artifact_id" | Out-Null
        Assert-ExistingRef -Ref (Assert-NonEmptyString -Value $artifactResult.ref -Context "$SourceLabel artifact_results ref") -Context "$SourceLabel artifact_results ref"
        Assert-NonEmptyString -Value $artifactResult.evidence_kind -Context "$SourceLabel artifact_results evidence_kind" | Out-Null
        Assert-NonEmptyString -Value $artifactResult.validation_status -Context "$SourceLabel artifact_results validation_status" | Out-Null
    }

    Assert-RefArray -Value $Result.output_refs -Context "$SourceLabel output_refs" -AllowEmpty -RequireExists | Out-Null
    Assert-RefArray -Value $Result.evidence_refs -Context "$SourceLabel evidence_refs" -RequireExists | Out-Null
    $refusalReasons = Assert-StringArray -Value $Result.refusal_reasons -Context "$SourceLabel refusal_reasons" -AllowEmpty
    Assert-TimestampString -Value $Result.started_at_utc -Context "$SourceLabel started_at_utc"
    Assert-TimestampString -Value $Result.completed_at_utc -Context "$SourceLabel completed_at_utc"
    $nonClaims = Assert-StringArray -Value $Result.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel
    Assert-NoForbiddenR13RunnerClaims -Value $Result -Context $SourceLabel

    if ($aggregateVerdict -eq "passed" -and ($commandResults.Count -eq 0 -or $failedCount -ne 0 -or $blockedCount -ne 0)) {
        throw "$SourceLabel aggregate_verdict passed requires at least one command and all commands passing."
    }
    if ($aggregateVerdict -eq "failed" -and $failedCount -eq 0) {
        throw "$SourceLabel aggregate_verdict failed requires at least one failed command."
    }
    if ($aggregateVerdict -eq "blocked" -and @($refusalReasons).Count -eq 0) {
        throw "$SourceLabel aggregate_verdict blocked requires refusal_reasons."
    }
    if ($executionStatus -eq "completed" -and $aggregateVerdict -eq "blocked") {
        throw "$SourceLabel completed execution cannot have aggregate_verdict blocked."
    }
    if ($executionStatus -eq "blocked" -and $aggregateVerdict -ne "blocked") {
        throw "$SourceLabel blocked execution_status must have aggregate_verdict blocked."
    }

    return [pscustomobject][ordered]@{
        ResultId = $resultId
        RequestId = $requestId
        RequestedOperation = $requestedOperation
        ExecutionStatus = $executionStatus
        CommandCount = @($commandResults).Count
        PassedCommandCount = $passedCount
        FailedCommandCount = $failedCount
        BlockedCommandCount = $blockedCount
        AggregateVerdict = $aggregateVerdict
    }
}

function Test-R13CustomRunnerResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ResultPath
    )

    $result = Get-JsonDocument -Path $ResultPath -Label "R13 custom runner result"
    return Test-R13CustomRunnerResultObject -Result $result -SourceLabel "R13 custom runner result"
}

function Invoke-R13CustomRunner {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RequestPath,
        [bool]$StrictRepoIdentity = $true
    )

    $startedAt = Get-UtcTimestamp
    $request = Get-JsonDocument -Path $RequestPath -Label "R13 custom runner request"
    $requestValidation = Test-R13CustomRunnerRequestObject -Request $request -SourceLabel "R13 custom runner request"

    $refusalReasons = @()
    if ($StrictRepoIdentity) {
        try {
            $gitIdentity = Get-GitIdentity
            if ($gitIdentity.Branch -ne $request.branch) {
                $refusalReasons += "Strict repo identity mismatch: current branch '$($gitIdentity.Branch)' does not match request branch '$($request.branch)'."
            }
            if ($gitIdentity.Head -ne $request.head) {
                $refusalReasons += "Strict repo identity mismatch: current head '$($gitIdentity.Head)' does not match request head '$($request.head)'."
            }
            if ($gitIdentity.Tree -ne $request.tree) {
                $refusalReasons += "Strict repo identity mismatch: current tree '$($gitIdentity.Tree)' does not match request tree '$($request.tree)'."
            }
        }
        catch {
            $refusalReasons += "Strict repo identity check failed: $($_.Exception.Message)"
        }
    }

    if ($refusalReasons.Count -gt 0) {
        return New-BlockedRunnerResult -Request $request -RefusalReasons $refusalReasons -StartedAtUtc $startedAt
    }

    $outputRoot = ([string]$request.output_root).Replace("\", "/").TrimEnd("/")
    New-Item -ItemType Directory -Path (Resolve-RepositoryPath -PathValue $outputRoot) -Force | Out-Null

    $artifactResults = @()
    foreach ($inputRef in @($request.input_refs)) {
        $artifactResults += [pscustomobject][ordered]@{
            artifact_id = [string]$inputRef.ref_id
            ref = ([string]$inputRef.ref).Replace("\", "/")
            evidence_kind = [string]$inputRef.evidence_kind
            validation_status = "available"
        }
    }

    $commandResults = @()
    $outputRefs = @()
    $commandRefusals = @()
    $index = 1
    if ([string]$request.requested_operation -ne "dry_run_only" -and [string]$request.requested_operation -ne "summarize_existing_evidence") {
        foreach ($commandObject in @($request.allowed_commands)) {
            $execution = Invoke-RunnerCommand -CommandObject $commandObject -Index $index -OutputRoot $outputRoot
            $commandResults += $execution.CommandResult
            $outputRefs += (New-EvidenceRef -RefId ("stdout-{0}" -f $execution.CommandResult.command_id) -Ref $execution.CommandResult.stdout_ref -EvidenceKind "stdout_log")
            $outputRefs += (New-EvidenceRef -RefId ("stderr-{0}" -f $execution.CommandResult.command_id) -Ref $execution.CommandResult.stderr_ref -EvidenceKind "stderr_log")
            if (-not [string]::IsNullOrWhiteSpace($execution.RefusalReason)) {
                $commandRefusals += [string]$execution.RefusalReason
            }
            $index += 1
        }
    }

    $failedCommands = @($commandResults | Where-Object { [string]$_.verdict -eq "failed" })
    $blockedCommands = @($commandResults | Where-Object { [string]$_.verdict -eq "blocked" })
    if ($commandRefusals.Count -gt 0 -or $blockedCommands.Count -gt 0) {
        $executionStatus = "blocked"
        $aggregateVerdict = "blocked"
        $refusalReasons = @($commandRefusals)
        if ($refusalReasons.Count -eq 0) {
            $refusalReasons = @("One or more runner commands were blocked before completion.")
        }
    }
    elseif ($failedCommands.Count -gt 0) {
        $executionStatus = "completed"
        $aggregateVerdict = "failed"
        $refusalReasons = @()
    }
    else {
        $executionStatus = "completed"
        $aggregateVerdict = "passed"
        $refusalReasons = @()
    }

    if ([string]$request.requested_operation -eq "dry_run_only") {
        $executionStatus = "completed"
        $aggregateVerdict = "passed"
        $refusalReasons = @()
    }

    $evidenceRefs = @(
        (New-EvidenceRef -RefId "r13-custom-runner-request-contract" -Ref "contracts/runner/r13_custom_runner_request.contract.json" -EvidenceKind "contract" -AuthorityKind "repo_contract"),
        (New-EvidenceRef -RefId "r13-custom-runner-result-contract" -Ref "contracts/runner/r13_custom_runner_result.contract.json" -EvidenceKind "contract" -AuthorityKind "repo_contract"),
        (New-EvidenceRef -RefId "r13-custom-runner-module" -Ref "tools/R13CustomRunner.psm1" -EvidenceKind "module"),
        (New-EvidenceRef -RefId "r13-custom-runner-cli" -Ref "tools/invoke_r13_custom_runner.ps1" -EvidenceKind "cli"),
        (New-EvidenceRef -RefId "r13-custom-runner-request" -Ref (Convert-ToRepositoryRelativePath -PathValue $RequestPath) -EvidenceKind "runner_request")
    )
    foreach ($inputRef in @($request.input_refs)) {
        $evidenceRefs += (New-EvidenceRef -RefId ("input-{0}" -f $inputRef.ref_id) -Ref ([string]$inputRef.ref) -EvidenceKind ([string]$inputRef.evidence_kind) -AuthorityKind ([string]$inputRef.authority_kind))
    }

    $result = [pscustomobject][ordered]@{
        contract_version = "v1"
        artifact_type = "r13_custom_runner_result"
        result_id = Get-StableId -Prefix "r13crr" -Key "$($request.request_id)|$($request.requested_operation)|$outputRoot"
        request_id = [string]$request.request_id
        repository = $script:R13RepositoryName
        branch = [string]$request.branch
        head = [string]$request.head
        tree = [string]$request.tree
        source_milestone = $script:R13Milestone
        source_task = $script:R13SourceTask
        requested_operation = [string]$request.requested_operation
        execution_profile = $request.execution_profile
        execution_status = $executionStatus
        command_results = @($commandResults)
        artifact_results = @($artifactResults)
        output_refs = @($outputRefs)
        aggregate_verdict = $aggregateVerdict
        evidence_refs = @($evidenceRefs)
        refusal_reasons = @($refusalReasons)
        started_at_utc = $startedAt
        completed_at_utc = Get-UtcTimestamp
        non_claims = @($script:RequiredNonClaims)
    }

    Test-R13CustomRunnerResultObject -Result $result -SourceLabel "generated R13 custom runner result" | Out-Null
    return $result
}

Export-ModuleMember -Function Get-R13CustomRunnerRequestContract, Get-R13CustomRunnerResultContract, Test-R13CustomRunnerRequestObject, Test-R13CustomRunnerRequest, Test-R13CustomRunnerResultObject, Test-R13CustomRunnerResult, Invoke-R13CustomRunner, Write-R13CustomRunnerJsonFile
