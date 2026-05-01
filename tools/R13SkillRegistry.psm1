Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$script:R13RepositoryName = "AIOffice_V2"
$script:R13Branch = "release/r13-api-first-qa-pipeline-and-operator-control-room-product-slice"
$script:R13Milestone = "R13 API-First QA Pipeline and Operator Control-Room Product Slice"
$script:R13SourceTask = "R13-008"
$script:GitObjectPattern = "^[a-f0-9]{40}$"
$script:TimestampPattern = "^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$"
$script:RequiredSkillIds = @(
    "qa.detect",
    "qa.fix_plan",
    "runner.external_replay",
    "control_room.refresh"
)
$script:AllowedInvocationModes = @(
    "validate_existing_evidence",
    "generate_artifact",
    "dry_run_only"
)
$script:RequiredNonClaims = @(
    "R13-008 adds bounded skill registry and invocation evidence only",
    "no external replay executed by R13-008",
    "runner.external_replay is registered but not executed by R13-008",
    "control_room.refresh is registered but current control-room gate is not delivered by R13-008",
    "no current operator control-room gate delivered by R13-008",
    "no operator demo delivered by R13-008",
    "no final QA signoff delivered by R13-008",
    "no R13 hard value gate delivered by R13-008",
    "skill invocation evidence gate is partially evidenced only; not fully delivered by R13-008",
    "no API/custom-runner bypass gate fully delivered by R13-008",
    "no production runtime",
    "no real production QA",
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

function Write-R13SkillJsonFile {
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

function Write-R13SkillTextFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
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

function Get-R13SkillGitIdentity {
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

    return ($Line -match '(?i)\b(no|not|without|cannot|must not|does not|do not|is not|are not|did not|non-claim|non_claim|refuse|refuses|blocked|planned only|not yet delivered|not fully delivered|partial|partially|registered but not executed|not executed|future|pending|rejects|rejected)\b')
}

function Assert-NoForbiddenR13SkillClaims {
    param(
        [Parameter(Mandatory = $true)]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($line in @(Get-StringLeaves -Value $Value)) {
        if ($line -match '(?i)\bexternal[_ -]?replay\b' -and $line -match '(?i)\b(executed|complete|completed|passed|delivered|proved|run|ran|replayed|started)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims external replay execution or delivery. Offending text: $line"
        }
        if ($line -match '(?i)\bcurrent\s+operator\s+control[- ]room\b|\bcurrent\s+control[- ]room\b' -and $line -match '(?i)\b(delivered|complete|completed|passed|proved|current)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims current control-room delivery. Offending text: $line"
        }
        if ($line -match '(?i)\bfinal\s+QA\s+signoff\b|\bfinal\s+signoff\b|\bsign-off\b' -and $line -match '(?i)\b(accepted|complete|completed|delivered|passed|signed)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims final QA signoff. Offending text: $line"
        }
        if ($line -match '(?i)\b(hard\s+)?R13\s+hard\s+value\s+gate\b|\bhard\s+value\s+gate\b|\bmeaningful\s+QA\s+loop\b.*\b(delivered|complete|passed|proved)\b|\bAPI/custom-runner bypass\b.*\b(delivered|complete|passed|proved)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims R13 hard value gate or API/custom-runner bypass delivery. Offending text: $line"
        }
        if ($line -match '(?i)\bskill\s+invocation\s+evidence\s+gate\b.*\b(delivered|complete|completed|proved)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims skill invocation evidence gate delivery. Offending text: $line"
        }
        if ($line -match '(?i)\boperator\s+demo\b.*\b(delivered|complete|completed|proved)\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims operator demo delivery. Offending text: $line"
        }
        if ($line -match '(?i)\bproduction runtime\b|\breal production QA\b|\bproductized control[- ]room behavior\b|\bfull UI app\b|\bbroad autonomous milestone execution\b|\bbroad autonomy\b|\bsolved Codex reliability\b|\bsolved Codex context compaction\b' -and -not (Test-LineHasNegation -Line $line)) {
            throw "$Context claims forbidden product, production, autonomy, or reliability scope. Offending text: $line"
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

function Assert-CommandHasNoForbiddenMutation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $normalized = $Command.Trim()
    $lower = $normalized.ToLowerInvariant()
    $forbiddenPatterns = @(
        '\bgit\s+push\b',
        '\bgit\s+commit\b',
        '\bgit\s+reset\b',
        '\bgit\s+clean\b',
        '\bgit\s+rm\b',
        '\bremove-item\b',
        '(^|[\s;])rm(\s|$)',
        '(^|[\s;])del(\s|$)',
        '(^|[\s;])erase(\s|$)',
        '\bset-content\b',
        '\badd-content\b',
        '\bout-file\b',
        '\bnew-item\b',
        '\bcopy-item\b',
        '\bmove-item\b',
        '\brename-item\b',
        '\binvoke-webrequest\b',
        '\bcurl\b'
    )

    foreach ($pattern in $forbiddenPatterns) {
        if ($lower -match $pattern) {
            throw "$Context contains a forbidden mutation, destructive, network, or git publication command."
        }
    }

    if ($lower -match '(?i)\b(workflow\s+run|invoke_external_runner|watch_external_runner|capture_external_runner|r12-external-replay|external\s+replay\s+execution)\b') {
        throw "$Context attempts external replay execution, which R13-008 forbids."
    }
}

function Assert-AllowedCommandShape {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context,
        [switch]$AllowEmpty
    )

    $commands = Assert-ObjectArray -Value $Value -Context $Context -AllowEmpty:$AllowEmpty
    $commandIds = @{}
    foreach ($commandObject in @($commands)) {
        Assert-RequiredObjectFields -Object $commandObject -FieldNames @("command_id", "command") -Context $Context
        $commandId = Assert-NonEmptyString -Value $commandObject.command_id -Context "$Context command_id"
        if ($commandIds.ContainsKey($commandId)) {
            throw "$Context contains duplicate command_id '$commandId'."
        }
        $commandIds[$commandId] = $true
        $command = Assert-NonEmptyString -Value $commandObject.command -Context "$Context command"
        Assert-CommandHasNoForbiddenMutation -Command $command -Context "$Context command '$commandId'"
    }

    $PSCmdlet.WriteObject($commands, $false)
}

function Test-R13SkillCommandAllowedByRegistry {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,
        [Parameter(Mandatory = $true)]
        $Skill
    )

    $registered = @($Skill.allowed_commands | ForEach-Object { [string]$_.command })
    return $registered -contains $Command
}

function Get-R13SkillRegistryContract {
    return Get-JsonDocument -Path (Join-Path (Get-RepositoryRoot) "contracts\skills\r13_skill_registry.contract.json") -Label "R13 skill registry contract"
}

function Get-R13SkillRequiredNonClaims {
    return @($script:RequiredNonClaims)
}

function Get-R13SkillAllowedInvocationModes {
    return @($script:AllowedInvocationModes)
}

function Get-R13SkillById {
    param(
        [Parameter(Mandatory = $true)]
        $Registry,
        [Parameter(Mandatory = $true)]
        [string]$SkillId
    )

    foreach ($skill in @($Registry.skills)) {
        if ([string]$skill.skill_id -eq $SkillId) {
            return $skill
        }
    }

    return $null
}

function Test-R13SkillRegistryObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Registry,
        [string]$SourceLabel = "R13 skill registry"
    )

    $contract = Get-R13SkillRegistryContract
    Assert-RequiredObjectFields -Object $Registry -FieldNames $contract.required_fields -Context $SourceLabel

    if ($Registry.contract_version -ne "v1") {
        throw "$SourceLabel contract_version must be v1."
    }
    if ($Registry.artifact_type -ne "r13_skill_registry") {
        throw "$SourceLabel artifact_type must be r13_skill_registry."
    }
    $registryId = Assert-NonEmptyString -Value $Registry.registry_id -Context "$SourceLabel registry_id"
    Assert-StandardIdentity -Artifact $Registry -SourceLabel $SourceLabel

    $allowedInvocationModes = Assert-StringArray -Value $Registry.allowed_invocation_modes -Context "$SourceLabel allowed_invocation_modes"
    foreach ($mode in $script:AllowedInvocationModes) {
        if ($allowedInvocationModes -notcontains $mode) {
            throw "$SourceLabel allowed_invocation_modes must include '$mode'."
        }
    }
    foreach ($mode in $allowedInvocationModes) {
        Assert-AllowedValue -Value $mode -AllowedValues $script:AllowedInvocationModes -Context "$SourceLabel allowed_invocation_modes"
    }

    Assert-StringArray -Value $Registry.global_forbidden_operations -Context "$SourceLabel global_forbidden_operations" | Out-Null
    Assert-RefArray -Value $Registry.evidence_refs -Context "$SourceLabel evidence_refs" -RequireExists | Out-Null
    Assert-StringArray -Value $Registry.refusal_reasons -Context "$SourceLabel refusal_reasons" -AllowEmpty | Out-Null
    Assert-TimestampString -Value $Registry.created_at_utc -Context "$SourceLabel created_at_utc"
    $registryNonClaims = Assert-StringArray -Value $Registry.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $registryNonClaims -Context $SourceLabel
    Assert-NoForbiddenR13SkillClaims -Value $Registry -Context $SourceLabel

    $skills = Assert-ObjectArray -Value $Registry.skills -Context "$SourceLabel skills"
    $skillIds = @{}
    foreach ($skill in @($skills)) {
        Assert-RequiredObjectFields -Object $skill -FieldNames $contract.skill_required_fields -Context "$SourceLabel skill"
        $skillId = Assert-NonEmptyString -Value $skill.skill_id -Context "$SourceLabel skill skill_id"
        if ($skillIds.ContainsKey($skillId)) {
            throw "$SourceLabel contains duplicate skill_id '$skillId'."
        }
        $skillIds[$skillId] = $true
        Assert-NonEmptyString -Value $skill.skill_name -Context "$SourceLabel skill '$skillId' skill_name" | Out-Null
        Assert-NonEmptyString -Value $skill.skill_version -Context "$SourceLabel skill '$skillId' skill_version" | Out-Null
        Assert-NonEmptyString -Value $skill.purpose -Context "$SourceLabel skill '$skillId' purpose" | Out-Null
        Assert-StringArray -Value $skill.allowed_inputs -Context "$SourceLabel skill '$skillId' allowed_inputs" | Out-Null
        Assert-StringArray -Value $skill.required_input_refs -Context "$SourceLabel skill '$skillId' required_input_refs" | Out-Null
        $skillCommands = Assert-AllowedCommandShape -Value $skill.allowed_commands -Context "$SourceLabel skill '$skillId' allowed_commands" -AllowEmpty
        Assert-StringArray -Value $skill.allowed_tools -Context "$SourceLabel skill '$skillId' allowed_tools" | Out-Null
        Assert-StringArray -Value $skill.forbidden_operations -Context "$SourceLabel skill '$skillId' forbidden_operations" | Out-Null
        $outputContractRef = Assert-NonEmptyString -Value $skill.output_contract_ref -Context "$SourceLabel skill '$skillId' output_contract_ref"
        Assert-ExistingRef -Ref $outputContractRef -Context "$SourceLabel skill '$skillId' output_contract_ref"
        Assert-NonEmptyString -Value $skill.expected_output_artifact_type -Context "$SourceLabel skill '$skillId' expected_output_artifact_type" | Out-Null
        Assert-NonEmptyString -Value $skill.owner_role -Context "$SourceLabel skill '$skillId' owner_role" | Out-Null
        Assert-NonEmptyString -Value $skill.authority_kind -Context "$SourceLabel skill '$skillId' authority_kind" | Out-Null
        Assert-RefArray -Value $skill.evidence_refs -Context "$SourceLabel skill '$skillId' evidence_refs" -RequireExists | Out-Null
        $skillNonClaims = Assert-StringArray -Value $skill.non_claims -Context "$SourceLabel skill '$skillId' non_claims"
        Assert-RequiredNonClaims -NonClaims $skillNonClaims -Context "$SourceLabel skill '$skillId'"
        Assert-NoForbiddenR13SkillClaims -Value $skill -Context "$SourceLabel skill '$skillId'"

        if ($skillId -eq "runner.external_replay") {
            foreach ($commandObject in @($skillCommands)) {
                $command = [string]$commandObject.command
                if ($command -match '(?i)\b(workflow\s+run|invoke_external_runner|watch_external_runner|capture_external_runner|r12-external-replay)\b') {
                    throw "$SourceLabel skill '$skillId' cannot register external replay execution commands in R13-008."
                }
            }
        }
        if ($skillId -eq "control_room.refresh" -and $skillCommands.Count -gt 0) {
            foreach ($commandObject in @($skillCommands)) {
                if ([string]$commandObject.command -notmatch '(?i)validate_') {
                    throw "$SourceLabel skill '$skillId' can only register safe validation commands in R13-008."
                }
            }
        }
    }

    foreach ($requiredSkillId in $script:RequiredSkillIds) {
        if (-not $skillIds.ContainsKey($requiredSkillId)) {
            throw "$SourceLabel must include required skill_id '$requiredSkillId'."
        }
    }

    $PSCmdlet.WriteObject([pscustomobject][ordered]@{
        RegistryId = $registryId
        SkillCount = $skills.Count
        RequiredSkillCount = $script:RequiredSkillIds.Count
        AllowedInvocationModeCount = $allowedInvocationModes.Count
    }, $false)
}

function Test-R13SkillRegistry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RegistryPath
    )

    $registry = Get-JsonDocument -Path $RegistryPath -Label "R13 skill registry"
    return Test-R13SkillRegistryObject -Registry $registry -SourceLabel "R13 skill registry"
}

Export-ModuleMember -Function Get-RepositoryRoot, Resolve-RepositoryPath, Convert-ToRepositoryRelativePath, Test-RepositoryRelativePath, Assert-RepositoryRelativePath, Assert-ExistingRef, Get-UtcTimestamp, Get-JsonDocument, Write-R13SkillJsonFile, Write-R13SkillTextFile, Test-HasProperty, Get-RequiredProperty, Assert-NonEmptyString, Assert-StringValue, Assert-IntegerValue, Assert-ObjectValue, Assert-StringArray, Assert-ObjectArray, Assert-RequiredObjectFields, Assert-AllowedValue, Assert-GitObjectId, Assert-TimestampString, Get-R13SkillGitIdentity, Get-StableId, Assert-NoForbiddenR13SkillClaims, Assert-RequiredNonClaims, Assert-StandardIdentity, Assert-RefArray, Assert-CommandHasNoForbiddenMutation, Assert-AllowedCommandShape, Test-R13SkillCommandAllowedByRegistry, Get-R13SkillRegistryContract, Get-R13SkillRequiredNonClaims, Get-R13SkillAllowedInvocationModes, Get-R13SkillById, Test-R13SkillRegistryObject, Test-R13SkillRegistry
