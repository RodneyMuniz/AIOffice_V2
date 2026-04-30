Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$jsonRootModule = Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force -PassThru
$script:ReadSingleJsonObject = $jsonRootModule.ExportedCommands["Read-SingleJsonObject"]

$script:RequiredNonClaims = @(
    "this does not solve all Codex reliability",
    "this does not prove unattended automatic resume",
    "this does not deliver external/API runner",
    "this does not deliver control-room UI",
    "this does not deliver R12 value gates"
)

$script:ValueGates = @(
    "external_api_runner",
    "actionable_qa",
    "operator_control_room",
    "real_build_change"
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

function Resolve-PathValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathValue
    )

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path (Get-RepositoryRoot) $PathValue))
}

function Read-JsonDocument {
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

    if ((Test-Path -LiteralPath $Path -PathType Leaf) -and -not $Overwrite) {
        throw "Fresh-thread bootstrap output '$Path' already exists. Use -Overwrite to replace it explicitly."
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

function Assert-GitSha {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-NonEmptyString -Value $Value -Context $Context | Out-Null
    if ($Value -notmatch '^[0-9a-f]{40}$') {
        throw "$Context must be a 40-character Git SHA."
    }
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

function Get-UtcTimestamp {
    return [System.DateTimeOffset]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture)
}

function Get-FreshThreadBootstrapContract {
    return Read-JsonDocument -Path (Join-RepositoryPath -Segments @("contracts", "bootstrap", "fresh_thread_bootstrap_packet.contract.json")) -Label "Fresh-thread bootstrap packet contract"
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
            throw "$Context explicit_non_claims must include '$requiredNonClaim'."
        }
    }
}

function Assert-NoForbiddenPositiveClaim {
    param(
        [AllowNull()]
        $Value,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $items = if ($Value -is [System.Array]) { @($Value) } else { @($Value) }
    foreach ($item in $items) {
        if ($item -isnot [string]) {
            continue
        }

        if ($item -match '(?i)\b(solved Codex reliability|solved Codex context compaction|value gates delivered|delivered R12 value gates|unattended automatic resume)\b' -and $item -notmatch '(?i)\b(no|not|does not|without|non-claim|fail-closed|planned only|must not|this does not)\b') {
            throw "$Context contains a forbidden positive claim: $item"
        }

        if ($item -match '(?i)\b(chat transcript|chat memory|prior chat)\b' -and $item -notmatch '(?i)\b(no|not|without|do not|does not|not authority|no reliance|must not)\b') {
            throw "$Context treats chat transcript as authority."
        }
    }
}

function Get-DefaultValueGateStatus {
    $status = [ordered]@{}
    foreach ($gate in $script:ValueGates) {
        $status[$gate] = [pscustomobject][ordered]@{
            status = "not_delivered"
            proof_refs = @()
        }
    }
    return [pscustomobject]$status
}

function New-NextPromptBody {
    param(
        [Parameter(Mandatory = $true)]
        $Packet
    )

    $evidenceText = (@($Packet.required_evidence_refs) -join ", ")
    $nonClaimsText = (@($Packet.explicit_non_claims) -join "; ")
    $failClosedText = (@($Packet.fail_closed_rules) -join "; ")

    return @"
You are Codex continuing R12 in RodneyMuniz/AIOffice_V2.

Do not rely on prior chat context. Treat repo truth and this packet as authority.

Branch/head/tree truth:
- Branch: $($Packet.active_branch)
- Local head: $($Packet.local_head)
- Local tree: $($Packet.local_tree)
- Remote head: $($Packet.remote_head)

Current task: $($Packet.current_task)
Exact next action: advance only after required evidence is present and fail closed on ambiguity.
Operating loop state: $($Packet.operating_loop_state)
Allowed next states: $(@($Packet.allowed_next_states) -join ", ")

Fail-closed rules: $failClosedText
Relevant evidence refs: $evidenceText
Remote-head phase detection ref: $($Packet.remote_head_phase_detection_ref)
Non-claims: $nonClaimsText
"@
}

function Test-FreshThreadBootstrapPacketObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Packet,
        [string]$SourceLabel = "Fresh-thread bootstrap packet"
    )

    $contract = Get-FreshThreadBootstrapContract
    foreach ($field in @($contract.required_fields)) {
        Get-RequiredProperty -Object $Packet -Name $field -Context $SourceLabel | Out-Null
    }

    if ($Packet.contract_version -ne "v1") {
        throw "$SourceLabel contract_version must be v1."
    }
    if ($Packet.artifact_type -ne "fresh_thread_bootstrap_packet") {
        throw "$SourceLabel artifact_type must be fresh_thread_bootstrap_packet."
    }
    if ($Packet.repository -ne "AIOffice_V2") {
        throw "$SourceLabel repository must be AIOffice_V2."
    }
    if ($Packet.active_branch -ne "release/r12-external-api-runner-actionable-qa-control-room-pilot") {
        throw "$SourceLabel active_branch must be release/r12-external-api-runner-actionable-qa-control-room-pilot."
    }
    foreach ($field in @("local_head", "local_tree", "remote_head")) {
        Assert-GitSha -Value ([string](Get-RequiredProperty -Object $Packet -Name $field -Context $SourceLabel)) -Context "$SourceLabel $field"
    }
    foreach ($field in @("active_milestone", "current_task", "operating_loop_state", "remote_head_phase_detection_ref")) {
        Assert-NonEmptyString -Value (Get-RequiredProperty -Object $Packet -Name $field -Context $SourceLabel) -Context "$SourceLabel $field" | Out-Null
    }

    $completedTasks = Assert-StringArray -Value $Packet.completed_tasks -Context "$SourceLabel completed_tasks" -AllowEmpty
    $plannedNextTasks = Assert-StringArray -Value $Packet.planned_next_tasks -Context "$SourceLabel planned_next_tasks" -AllowEmpty
    $allowedNextStates = Assert-StringArray -Value $Packet.allowed_next_states -Context "$SourceLabel allowed_next_states" -AllowEmpty
    $requiredEvidenceRefs = Assert-StringArray -Value $Packet.required_evidence_refs -Context "$SourceLabel required_evidence_refs"
    $failClosedRules = Assert-StringArray -Value $Packet.fail_closed_rules -Context "$SourceLabel fail_closed_rules"
    $nonClaims = Assert-StringArray -Value $Packet.explicit_non_claims -Context "$SourceLabel explicit_non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel
    Assert-BooleanValue -Value $Packet.residue_preflight_required -Context "$SourceLabel residue_preflight_required" | Out-Null

    if (Test-HasProperty -Object $Packet -Name "source_authority") {
        Assert-NoForbiddenPositiveClaim -Value $Packet.source_authority -Context "$SourceLabel source_authority"
    }
    Assert-NoForbiddenPositiveClaim -Value @($Packet.current_task, $completedTasks, $plannedNextTasks, $allowedNextStates, $requiredEvidenceRefs, $failClosedRules, $nonClaims) -Context $SourceLabel

    $nextPromptRef = if (Test-HasProperty -Object $Packet -Name "next_prompt_ref") { [string]$Packet.next_prompt_ref } else { "" }
    $nextPromptBody = if (Test-HasProperty -Object $Packet -Name "next_prompt_body") { [string]$Packet.next_prompt_body } else { "" }
    if ([string]::IsNullOrWhiteSpace($nextPromptRef) -and [string]::IsNullOrWhiteSpace($nextPromptBody)) {
        throw "$SourceLabel must include next_prompt_ref or next_prompt_body."
    }
    if (-not [string]::IsNullOrWhiteSpace($nextPromptBody)) {
        foreach ($requiredText in @($Packet.active_branch, $Packet.local_head, $Packet.local_tree, $Packet.current_task, "Do not rely on prior chat context", "Fail-closed rules", "Relevant evidence refs", "Non-claims")) {
            if ($nextPromptBody -notmatch [regex]::Escape([string]$requiredText)) {
                throw "$SourceLabel next_prompt_body is missing required prompt text '$requiredText'."
            }
        }
        Assert-NoForbiddenPositiveClaim -Value $nextPromptBody -Context "$SourceLabel next_prompt_body"
    }

    $valueGateStatus = Assert-ObjectValue -Value $Packet.value_gate_status -Context "$SourceLabel value_gate_status"
    foreach ($gate in $script:ValueGates) {
        $gateStatus = Assert-ObjectValue -Value (Get-RequiredProperty -Object $valueGateStatus -Name $gate -Context "$SourceLabel value_gate_status") -Context "$SourceLabel value_gate_status.$gate"
        $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $gateStatus -Name "status" -Context "$SourceLabel value_gate_status.$gate") -Context "$SourceLabel value_gate_status.$gate.status"
        if (@("not_delivered", "proved") -notcontains $status) {
            throw "$SourceLabel value_gate_status.$gate.status must be not_delivered or proved."
        }
        $proofRefs = Assert-StringArray -Value (Get-RequiredProperty -Object $gateStatus -Name "proof_refs" -Context "$SourceLabel value_gate_status.$gate") -Context "$SourceLabel value_gate_status.$gate.proof_refs" -AllowEmpty
        if ($status -eq "proved" -and $proofRefs.Count -eq 0) {
            throw "$SourceLabel claims value gates delivered without proof refs for $gate."
        }
    }

    $PSCmdlet.WriteObject([pscustomobject][ordered]@{
        IsValid = $true
        CurrentTask = $Packet.current_task
        OperatingLoopState = $Packet.operating_loop_state
        EvidenceRefCount = $requiredEvidenceRefs.Count
        HasInlineNextPrompt = (-not [string]::IsNullOrWhiteSpace($nextPromptBody))
    }, $false)
}

function Test-FreshThreadBootstrapPacketContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PacketPath
    )

    $packet = Read-JsonDocument -Path (Resolve-PathValue -PathValue $PacketPath) -Label "Fresh-thread bootstrap packet"
    return Test-FreshThreadBootstrapPacketObject -Packet $packet -SourceLabel $PacketPath
}

function New-FreshThreadBootstrapPacket {
    [CmdletBinding()]
    param(
        [string]$ActiveBranch = "",
        [string]$LocalHead = "",
        [string]$LocalTree = "",
        [string]$RemoteHead = "",
        [string]$CurrentTask = "R12-005 make fresh-thread bootstrap the default execution protocol",
        [string[]]$CompletedTasks = @("R12-001", "R12-002", "R12-003", "R12-004"),
        [string[]]$PlannedNextTasks = @("R12-006"),
        [string]$OperatingLoopState = "fresh_thread_bootstrap_ready",
        [string[]]$AllowedNextStates = @("residue_preflight_passed"),
        [string[]]$RequiredEvidenceRefs = @("contracts/bootstrap/fresh_thread_bootstrap_packet.contract.json", "tools/FreshThreadBootstrap.psm1", "tests/test_fresh_thread_bootstrap.ps1"),
        [string]$RemoteHeadPhaseDetectionRef = "state/fixtures/valid/remote_head_phase/phase_match.valid.json",
        [string[]]$FailClosedRules = @("missing branch/head/tree refuses bootstrap", "chat transcript is not authority", "missing non-claims refuses bootstrap", "value gates cannot be claimed without proof refs"),
        [string[]]$ExplicitNonClaims = $script:RequiredNonClaims,
        [string]$NextPromptRef = "",
        [string]$OutputPath = "",
        [switch]$Overwrite
    )

    $branchValue = if ([string]::IsNullOrWhiteSpace($ActiveBranch)) { (@(Invoke-GitLines -Arguments @("branch", "--show-current")))[0].Trim() } else { $ActiveBranch }
    $headValue = if ([string]::IsNullOrWhiteSpace($LocalHead)) { (@(Invoke-GitLines -Arguments @("rev-parse", "HEAD")))[0].Trim() } else { $LocalHead }
    $treeValue = if ([string]::IsNullOrWhiteSpace($LocalTree)) { (@(Invoke-GitLines -Arguments @("rev-parse", "HEAD^{tree}")))[0].Trim() } else { $LocalTree }
    $remoteHeadValue = $RemoteHead
    if ([string]::IsNullOrWhiteSpace($remoteHeadValue)) {
        $remoteLine = @(Invoke-GitLines -Arguments @("ls-remote", "origin", "refs/heads/release/r12-external-api-runner-actionable-qa-control-room-pilot"))
        if ($remoteLine.Count -gt 0 -and $remoteLine[0] -match '^([0-9a-f]{40})\s+') {
            $remoteHeadValue = $Matches[1]
        }
    }

    $packet = [pscustomobject][ordered]@{
        contract_version = "v1"
        artifact_type = "fresh_thread_bootstrap_packet"
        repository = "AIOffice_V2"
        active_branch = $branchValue
        local_head = $headValue
        local_tree = $treeValue
        remote_head = $remoteHeadValue
        active_milestone = "R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot"
        current_task = $CurrentTask
        completed_tasks = @($CompletedTasks)
        planned_next_tasks = @($PlannedNextTasks)
        operating_loop_state = $OperatingLoopState
        allowed_next_states = @($AllowedNextStates)
        required_evidence_refs = @($RequiredEvidenceRefs)
        value_gate_status = Get-DefaultValueGateStatus
        residue_preflight_required = $true
        remote_head_phase_detection_ref = $RemoteHeadPhaseDetectionRef
        next_prompt_ref = $NextPromptRef
        next_prompt_body = ""
        fail_closed_rules = @($FailClosedRules)
        explicit_non_claims = @($ExplicitNonClaims)
        source_authority = "committed repo/status artifacts plus explicit input parameters; chat transcript is not authority"
        created_at_utc = Get-UtcTimestamp
    }
    $packet.next_prompt_body = New-NextPromptBody -Packet $packet

    Test-FreshThreadBootstrapPacketObject -Packet $packet -SourceLabel "Fresh-thread bootstrap packet draft" | Out-Null

    if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
        Write-JsonDocument -Path (Resolve-PathValue -PathValue $OutputPath) -Document $packet -Overwrite:$Overwrite
    }

    $PSCmdlet.WriteObject($packet, $false)
}

Export-ModuleMember -Function Get-FreshThreadBootstrapContract, Test-FreshThreadBootstrapPacketObject, Test-FreshThreadBootstrapPacketContract, New-FreshThreadBootstrapPacket
