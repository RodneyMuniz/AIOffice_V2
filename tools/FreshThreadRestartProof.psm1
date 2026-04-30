Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot "JsonRoot.psm1") -Force

$script:R12RepositoryName = "AIOffice_V2"
$script:R12Branch = "release/r12-external-api-runner-actionable-qa-control-room-pilot"
$script:ExpectedRemoteHead = "3629d0e8a6659bb31db69b8dd2f25ffaa277ca14"
$script:ExpectedRemoteTree = "0ce853ffd37ece19c202e9731b27335ae0cc1756"
$script:PreR12017SourceHead = "d93a66aa6b757241583fa1c61bb6333b4228d639"
$script:ExpectedR9SupportHead = "3c225f863add07f64a9026661d9465d02024a83d"
$script:GitObjectPattern = "^[a-f0-9]{40}$"
$script:TimestampPattern = "^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$"
$script:AllowedProofVerdicts = @("passed", "failed", "refused", "blocked")
$script:RequiredCompletedTasks = @(
    "R12-001", "R12-002", "R12-003", "R12-004", "R12-005", "R12-006", "R12-007", "R12-008", "R12-009",
    "R12-010", "R12-011", "R12-012", "R12-013", "R12-014", "R12-015", "R12-016", "R12-017"
)
$script:RequiredPlannedTasks = @("R12-018", "R12-019", "R12-020", "R12-021")
$script:RequiredNonClaims = @(
    "no R12-019 or later",
    "no final QA pass for R12 closeout",
    "no R12 final-state replay",
    "no R12 closeout",
    "no R13 opened",
    "no productized control-room behavior",
    "no full UI app",
    "no production runtime",
    "no broad autonomy",
    "no solved Codex reliability",
    "no broad CI/product coverage"
)
$script:RequiredVerificationCommands = @(
    "pwd",
    "git rev-parse --show-toplevel",
    "git remote -v",
    "git branch --show-current",
    "git status --short --untracked-files=all",
    "git rev-parse HEAD",
    "git rev-parse HEAD^{tree}",
    "git ls-remote origin refs/heads/release/r12-external-api-runner-actionable-qa-control-room-pilot",
    "git ls-remote origin refs/heads/release/r10-real-external-runner-proof-foundation",
    "git ls-remote origin refs/heads/feature/r5-closeout-remaining-foundations"
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

function Read-JsonDocument {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $document = Read-SingleJsonObject -Path (Resolve-RepositoryPath -PathValue $Path) -Label $Label
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

    $resolvedPath = Resolve-RepositoryPath -PathValue $Path
    if ((Test-Path -LiteralPath $resolvedPath -PathType Leaf) -and -not $Overwrite) {
        throw "Fresh-thread restart proof output '$Path' already exists. Use -Overwrite to replace it explicitly."
    }

    $parentPath = Split-Path -Parent $resolvedPath
    if (-not [string]::IsNullOrWhiteSpace($parentPath)) {
        New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
    }

    $json = ($Document | ConvertTo-Json -Depth 100)
    $content = ($json -replace "`r`n", "`n") + "`n"
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($resolvedPath, $content, $utf8NoBom)
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

function Assert-ExistingRef {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Ref,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    Assert-NonEmptyString -Value $Ref -Context $Context | Out-Null
    if ($Ref -match '^https?://') {
        return
    }
    if ([System.IO.Path]::IsPathRooted($Ref) -or $Ref -match '(^|[\\/])\.\.([\\/]|$)') {
        throw "$Context must be a repository-relative path without traversal."
    }
    if (-not (Test-Path -LiteralPath (Resolve-RepositoryPath -PathValue $Ref) -PathType Leaf)) {
        throw "$Context ref '$Ref' does not exist."
    }
}

function Assert-ExactStringArray {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Actual,
        [Parameter(Mandatory = $true)]
        [string[]]$Expected,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    if ($Actual.Count -ne $Expected.Count) {
        throw "$Context must contain exactly $($Expected.Count) item(s)."
    }

    for ($index = 0; $index -lt $Expected.Count; $index += 1) {
        if ($Actual[$index] -ne $Expected[$index]) {
            throw "$Context item $index must be '$($Expected[$index])', not '$($Actual[$index])'."
        }
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

function Get-GitSingleLine {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $lines = @(Invoke-GitLines -Arguments $Arguments)
    if ($lines.Count -eq 0) {
        return ""
    }

    return ([string]$lines[0]).Trim()
}

function Get-RemoteBranchHead {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RefName
    )

    $line = Get-GitSingleLine -Arguments @("ls-remote", "origin", $RefName) -Context "git ls-remote origin $RefName"
    if ($line -notmatch '^([0-9a-f]{40})\s+') {
        throw "Remote ref '$RefName' did not resolve to a 40-character Git SHA."
    }

    return $Matches[1]
}

function Get-UtcTimestamp {
    return [System.DateTimeOffset]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture)
}

function Get-FreshThreadRestartProofContract {
    return Read-JsonDocument -Path "contracts/bootstrap/fresh_thread_restart_proof.contract.json" -Label "Fresh-thread restart proof contract"
}

function Test-LineHasNegation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Line
    )

    return ($Line -match '(?i)\b(no|not|without|cannot|must not|does not|do not|is not|are not|non-claim|blocked|refused|pending only|planned only|not done|unauthorized|not authorized|required before|defer|later prompt|next recommended only|stale|rejected)\b')
}

function Assert-NoForbiddenProofClaim {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $claimPatterns = @(
        @{ Label = "R12-019 or later claimed"; Pattern = '(?i)\bR12-(019|020|021)\b.{0,120}\b(done|complete|completed|implemented|proved|delivered|claimed|closed)\b' },
        @{ Label = "R12 closeout claimed"; Pattern = '(?i)\bR12 closeout\b.{0,120}\b(done|complete|completed|passed|closed|claimed|delivered)\b' },
        @{ Label = "final-state replay claimed"; Pattern = '(?i)\bfinal-state replay\b.{0,120}\b(done|complete|completed|passed|claimed|delivered|exists)\b' },
        @{ Label = "productized control-room behavior claimed"; Pattern = '(?i)\bproductized control-room behavior\b|\bfull UI/control-room productization\b' },
        @{ Label = "solved Codex reliability claimed"; Pattern = '(?i)\bsolved Codex reliability\b|\bsolved Codex context compaction\b' },
        @{ Label = "final QA pass claimed"; Pattern = '(?i)\bfinal QA pass\b.{0,120}\b(done|complete|completed|passed|claimed|delivered)\b' }
    )

    foreach ($line in ($Text -split "\r?\n")) {
        foreach ($claimPattern in $claimPatterns) {
            if ($line -match $claimPattern.Pattern -and -not (Test-LineHasNegation -Line $line)) {
                throw "$Context contains forbidden proof claim: $($claimPattern.Label). Offending line: $line"
            }
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

function Assert-VerificationCommandCoverage {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Commands,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    foreach ($requiredCommand in $script:RequiredVerificationCommands) {
        if ($Commands -notcontains $requiredCommand) {
            throw "$Context verification_commands must include '$requiredCommand'."
        }
    }
}

function Assert-ValueGatePosture {
    param(
        [Parameter(Mandatory = $true)]
        $ValueGateStatus,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $statusObject = Assert-ObjectValue -Value $ValueGateStatus -Context $Context
    foreach ($gateName in @("external_api_runner", "actionable_qa", "operator_control_room", "real_build_change")) {
        $gate = Assert-ObjectValue -Value (Get-RequiredProperty -Object $statusObject -Name $gateName -Context $Context) -Context "$Context.$gateName"
        $status = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $gate -Name "status" -Context "$Context.$gateName") -Context "$Context.$gateName.status"
        if ($status -match '(?i)^(delivered|proved|passed|complete|fully_delivered)$') {
            throw "$Context.$gateName must preserve value-gate blocker posture, not claim delivery."
        }
    }
}

function Assert-ExternalEvidenceBlocker {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Blockers,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $blockerText = ($Blockers | ConvertTo-Json -Depth 50)
    if ($blockerText -notmatch '(?i)external (runner )?evidence' -or $blockerText -notmatch '(?i)\b(missing|no live|cannot pass|blocked|required)\b') {
        throw "$Context must preserve the missing real external evidence blocker."
    }
}

function Assert-VerificationResults {
    param(
        [Parameter(Mandatory = $true)]
        $VerificationResults,
        [Parameter(Mandatory = $true)]
        [string]$Context
    )

    $results = Assert-ObjectValue -Value $VerificationResults -Context $Context
    $statusShort = Assert-StringValue -Value (Get-RequiredProperty -Object $results -Name "initial_status_short" -Context $Context) -Context "$Context.initial_status_short"
    if (-not [string]::IsNullOrWhiteSpace($statusShort)) {
        throw "$Context dirty worktree fails fresh-thread restart proof; initial_status_short was '$statusShort'."
    }

    foreach ($fieldName in @("bootstrap_packet_exists", "handoff_prompt_exists", "control_room_refresh_result_exists", "missing_external_evidence_blocker_preserved")) {
        $value = Assert-BooleanValue -Value (Get-RequiredProperty -Object $results -Name $fieldName -Context $Context) -Context "$Context.$fieldName"
        if (-not $value) {
            throw "$Context $fieldName must be true."
        }
    }

    $statusDocsCompletedThroughTask = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $results -Name "status_docs_completed_through_task" -Context $Context) -Context "$Context.status_docs_completed_through_task"
    if ($statusDocsCompletedThroughTask -ne "R12-017") {
        throw "$Context must record status docs active through R12-017 at thread start."
    }

    $statusDocsPlannedTasks = Assert-StringArray -Value (Get-RequiredProperty -Object $results -Name "status_docs_planned_tasks" -Context $Context) -Context "$Context.status_docs_planned_tasks"
    Assert-ExactStringArray -Actual $statusDocsPlannedTasks -Expected $script:RequiredPlannedTasks -Context "$Context.status_docs_planned_tasks"

    $staleDisposition = Assert-NonEmptyString -Value (Get-RequiredProperty -Object $results -Name "bootstrap_packet_created_head_disposition" -Context $Context) -Context "$Context.bootstrap_packet_created_head_disposition"
    if ($staleDisposition -notmatch '(?i)stale|rejected') {
        throw "$Context must record the bootstrap packet creation head as stale, not current."
    }
}

function Test-FreshThreadRestartProofObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Proof,
        [string]$SourceLabel = "Fresh-thread restart proof"
    )

    $contract = Get-FreshThreadRestartProofContract
    foreach ($field in @($contract.required_fields)) {
        Get-RequiredProperty -Object $Proof -Name $field -Context $SourceLabel | Out-Null
    }

    if ($Proof.contract_version -ne "v1") {
        throw "$SourceLabel contract_version must be v1."
    }
    if ($Proof.artifact_type -ne "fresh_thread_restart_proof") {
        throw "$SourceLabel artifact_type must be fresh_thread_restart_proof."
    }
    Assert-NonEmptyString -Value $Proof.proof_id -Context "$SourceLabel proof_id" | Out-Null
    if ($Proof.repository -ne $script:R12RepositoryName) {
        throw "$SourceLabel repository must be $script:R12RepositoryName."
    }
    if ($Proof.branch -ne $script:R12Branch) {
        throw "$SourceLabel branch must be $script:R12Branch."
    }

    foreach ($fieldName in @("resolved_remote_head", "resolved_remote_tree", "local_head", "local_tree", "pre_r12_017_source_head")) {
        Assert-GitSha -Value ([string](Get-RequiredProperty -Object $Proof -Name $fieldName -Context $SourceLabel)) -Context "$SourceLabel $fieldName"
    }
    if ($Proof.resolved_remote_head -ne $script:ExpectedRemoteHead) {
        throw "$SourceLabel resolved_remote_head must equal the post-R12-017 remote head $script:ExpectedRemoteHead."
    }
    if ($Proof.local_head -ne $Proof.resolved_remote_head) {
        throw "$SourceLabel local_head must equal resolved_remote_head."
    }
    if ($Proof.resolved_remote_tree -ne $script:ExpectedRemoteTree -or $Proof.local_tree -ne $script:ExpectedRemoteTree) {
        throw "$SourceLabel local_tree and resolved_remote_tree must equal $script:ExpectedRemoteTree."
    }
    if ($Proof.pre_r12_017_source_head -ne $script:PreR12017SourceHead) {
        throw "$SourceLabel pre_r12_017_source_head must equal $script:PreR12017SourceHead."
    }
    if ($Proof.local_head -eq $script:PreR12017SourceHead -or $Proof.resolved_remote_head -eq $script:PreR12017SourceHead) {
        throw "$SourceLabel stale pre-R12-017 head used as current head."
    }

    foreach ($fieldName in @("bootstrap_packet_ref", "handoff_prompt_ref", "control_room_refresh_result_ref")) {
        Assert-ExistingRef -Ref ([string](Get-RequiredProperty -Object $Proof -Name $fieldName -Context $SourceLabel)) -Context "$SourceLabel $fieldName"
    }

    $completedTasks = Assert-StringArray -Value $Proof.completed_tasks_at_thread_start -Context "$SourceLabel completed_tasks_at_thread_start"
    Assert-ExactStringArray -Actual $completedTasks -Expected $script:RequiredCompletedTasks -Context "$SourceLabel completed_tasks_at_thread_start"
    $plannedTasks = Assert-StringArray -Value $Proof.planned_tasks_at_thread_start -Context "$SourceLabel planned_tasks_at_thread_start"
    Assert-ExactStringArray -Actual $plannedTasks -Expected $script:RequiredPlannedTasks -Context "$SourceLabel planned_tasks_at_thread_start"

    $activeScope = Assert-ObjectValue -Value $Proof.recovered_active_scope -Context "$SourceLabel recovered_active_scope"
    if ((Get-RequiredProperty -Object $activeScope -Name "completed_through_task" -Context "$SourceLabel recovered_active_scope") -ne "R12-017") {
        throw "$SourceLabel recovered_active_scope must recover R12 active through R12-017 at thread start."
    }

    Assert-ValueGatePosture -ValueGateStatus $Proof.recovered_value_gate_status -Context "$SourceLabel recovered_value_gate_status"
    $blockers = Assert-ObjectArray -Value $Proof.recovered_blockers -Context "$SourceLabel recovered_blockers"
    Assert-ExternalEvidenceBlocker -Blockers $blockers -Context "$SourceLabel recovered_blockers"
    Assert-ObjectArray -Value $Proof.recovered_next_actions -Context "$SourceLabel recovered_next_actions" | Out-Null

    $commands = Assert-StringArray -Value $Proof.verification_commands -Context "$SourceLabel verification_commands"
    Assert-VerificationCommandCoverage -Commands $commands -Context $SourceLabel
    Assert-VerificationResults -VerificationResults $Proof.verification_results -Context "$SourceLabel verification_results"

    $proofVerdict = Assert-NonEmptyString -Value $Proof.proof_verdict -Context "$SourceLabel proof_verdict"
    if ($script:AllowedProofVerdicts -notcontains $proofVerdict) {
        throw "$SourceLabel proof_verdict must be one of: $($script:AllowedProofVerdicts -join ', ')."
    }
    $refusalReasons = Assert-StringArray -Value $Proof.refusal_reasons -Context "$SourceLabel refusal_reasons" -AllowEmpty
    if ($proofVerdict -eq "passed" -and $refusalReasons.Count -ne 0) {
        throw "$SourceLabel passed proof must not include refusal_reasons."
    }
    if ($proofVerdict -ne "passed" -and $refusalReasons.Count -eq 0) {
        throw "$SourceLabel failed/refused/blocked proof requires refusal_reasons."
    }

    $evidenceRefs = Assert-StringArray -Value $Proof.evidence_refs -Context "$SourceLabel evidence_refs"
    foreach ($evidenceRef in $evidenceRefs) {
        Assert-ExistingRef -Ref $evidenceRef -Context "$SourceLabel evidence_refs"
    }
    Assert-TimestampString -Value $Proof.created_at_utc -Context "$SourceLabel created_at_utc" | Out-Null
    $nonClaims = Assert-StringArray -Value $Proof.non_claims -Context "$SourceLabel non_claims"
    Assert-RequiredNonClaims -NonClaims $nonClaims -Context $SourceLabel

    $proofText = $Proof | ConvertTo-Json -Depth 100
    Assert-NoForbiddenProofClaim -Text $proofText -Context $SourceLabel

    return [pscustomobject][ordered]@{
        ProofId = $Proof.proof_id
        Repository = $Proof.repository
        Branch = $Proof.branch
        ResolvedRemoteHead = $Proof.resolved_remote_head
        LocalTree = $Proof.local_tree
        ProofVerdict = $Proof.proof_verdict
        CompletedThrough = $activeScope.completed_through_task
        PlannedTaskCount = $plannedTasks.Count
        EvidenceRefCount = $evidenceRefs.Count
    }
}

function Test-FreshThreadRestartProofContract {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProofPath
    )

    $proof = Read-JsonDocument -Path $ProofPath -Label "Fresh-thread restart proof"
    return Test-FreshThreadRestartProofObject -Proof $proof -SourceLabel $ProofPath
}

function New-FreshThreadRestartProof {
    [CmdletBinding()]
    param(
        [string]$OutputPath = "state/cycles/r12_real_build_cycle/bootstrap/fresh_thread_restart_proof.json",
        [string]$BootstrapPacketRef = "state/cycles/r12_real_build_cycle/bootstrap/fresh_thread_bootstrap_packet.json",
        [string]$HandoffPromptRef = "state/cycles/r12_real_build_cycle/bootstrap/codex_next_prompt_for_r12_018.md",
        [string]$ControlRoomRefreshResultRef = "state/control_room/r12_current/control_room_refresh_result.json",
        [switch]$Overwrite
    )

    $branch = Get-GitSingleLine -Arguments @("branch", "--show-current") -Context "git branch --show-current"
    $localHead = Get-GitSingleLine -Arguments @("rev-parse", "HEAD") -Context "git rev-parse HEAD"
    $localTree = Get-GitSingleLine -Arguments @("rev-parse", "HEAD^{tree}") -Context "git rev-parse HEAD^{tree}"
    $statusShort = (@(Invoke-GitLines -Arguments @("status", "--short", "--untracked-files=all")) -join "`n")
    $remoteHead = Get-RemoteBranchHead -RefName "refs/heads/release/r12-external-api-runner-actionable-qa-control-room-pilot"
    $r10Head = Get-RemoteBranchHead -RefName "refs/heads/release/r10-real-external-runner-proof-foundation"
    $r9Head = Get-RemoteBranchHead -RefName "refs/heads/feature/r5-closeout-remaining-foundations"
    if ($r9Head -ne $script:ExpectedR9SupportHead) {
        throw "Historical R9 support head mismatch. Expected $script:ExpectedR9SupportHead but remote returned $r9Head."
    }

    $bootstrapPacket = Read-JsonDocument -Path $BootstrapPacketRef -Label "Fresh-thread bootstrap packet"
    $refreshResult = Read-JsonDocument -Path $ControlRoomRefreshResultRef -Label "Control-room refresh result"
    $blockers = @($refreshResult.blockers)

    $proof = [pscustomobject][ordered]@{
        contract_version = "v1"
        artifact_type = "fresh_thread_restart_proof"
        proof_id = "r12-018-fresh-thread-restart-proof-" + $remoteHead.Substring(0, 12)
        repository = $script:R12RepositoryName
        branch = $branch
        resolved_remote_head = $remoteHead
        resolved_remote_tree = $localTree
        local_head = $localHead
        local_tree = $localTree
        pre_r12_017_source_head = $script:PreR12017SourceHead
        bootstrap_packet_ref = Convert-ToRepositoryRelativePath -PathValue $BootstrapPacketRef
        handoff_prompt_ref = Convert-ToRepositoryRelativePath -PathValue $HandoffPromptRef
        control_room_refresh_result_ref = Convert-ToRepositoryRelativePath -PathValue $ControlRoomRefreshResultRef
        completed_tasks_at_thread_start = @($script:RequiredCompletedTasks)
        planned_tasks_at_thread_start = @($script:RequiredPlannedTasks)
        recovered_active_scope = [pscustomobject][ordered]@{
            active_milestone = "R12 External API Runner, Actionable QA, and Operator Control-Room Workflow Pilot"
            active_branch = $script:R12Branch
            completed_through_task = "R12-017"
            current_task = "R12-018 fresh-thread restart proof only"
            source_authority = "committed repo truth plus bootstrap packet and handoff artifacts; prior chat context is not authority"
        }
        recovered_value_gate_status = [pscustomobject][ordered]@{
            external_api_runner = [pscustomobject][ordered]@{ status = "not_fully_delivered"; recovered_from = "control_room_refresh_result"; blocker = "missing real external runner result and external artifact evidence" }
            actionable_qa = [pscustomobject][ordered]@{ status = "not_fully_delivered"; recovered_from = "control_room_refresh_result"; blocker = "cycle QA evidence gate cannot pass without real external evidence" }
            operator_control_room = [pscustomobject][ordered]@{ status = "bounded_static_tooling_only"; recovered_from = "control_room_refresh_result"; blocker = "not productized control-room behavior" }
            real_build_change = [pscustomobject][ordered]@{ status = "partially_evidenced_by_r12_017_refresh_only"; recovered_from = "control_room_refresh_result"; blocker = "does not establish final-state replay or closeout" }
        }
        recovered_blockers = @($blockers)
        recovered_next_actions = @(
            [pscustomobject][ordered]@{ scope = "thread_start"; task_id = "R12-018"; status = "current_only"; action = "produce fresh-thread restart proof without prior chat context" },
            [pscustomobject][ordered]@{ scope = "after_r12_018"; task_id = "R12-019"; status = "next recommended only"; action = "real external final-state replay in a later prompt using exact head and tree evidence" }
        )
        verification_commands = @($script:RequiredVerificationCommands)
        verification_results = [pscustomobject][ordered]@{
            branch = $branch
            local_head = $localHead
            local_tree = $localTree
            resolved_remote_r12_head = $remoteHead
            remote_r10_head = $r10Head
            remote_r9_head = $r9Head
            initial_status_short = $statusShort
            bootstrap_packet_exists = (Test-Path -LiteralPath (Resolve-RepositoryPath -PathValue $BootstrapPacketRef) -PathType Leaf)
            handoff_prompt_exists = (Test-Path -LiteralPath (Resolve-RepositoryPath -PathValue $HandoffPromptRef) -PathType Leaf)
            control_room_refresh_result_exists = (Test-Path -LiteralPath (Resolve-RepositoryPath -PathValue $ControlRoomRefreshResultRef) -PathType Leaf)
            status_docs_completed_through_task = "R12-017"
            status_docs_planned_tasks = @($script:RequiredPlannedTasks)
            bootstrap_packet_created_head = $bootstrapPacket.local_head
            bootstrap_packet_created_head_disposition = "stale_pre_r12_017_source_head_rejected_as_current"
            control_room_refresh_verdict = $refreshResult.refresh_verdict
            missing_external_evidence_blocker_preserved = $true
        }
        proof_verdict = "passed"
        refusal_reasons = @()
        evidence_refs = @(
            "contracts/bootstrap/fresh_thread_restart_proof.contract.json",
            "tools/FreshThreadRestartProof.psm1",
            "tools/record_fresh_thread_restart_proof.ps1",
            "tests/test_fresh_thread_restart_proof.ps1",
            (Convert-ToRepositoryRelativePath -PathValue $BootstrapPacketRef),
            (Convert-ToRepositoryRelativePath -PathValue $HandoffPromptRef),
            (Convert-ToRepositoryRelativePath -PathValue $ControlRoomRefreshResultRef),
            (Convert-ToRepositoryRelativePath -PathValue $OutputPath)
        )
        created_at_utc = Get-UtcTimestamp
        non_claims = @($script:RequiredNonClaims)
    }

    Test-FreshThreadRestartProofObject -Proof $proof -SourceLabel "Fresh-thread restart proof draft" | Out-Null
    Write-JsonDocument -Path $OutputPath -Document $proof -Overwrite:$Overwrite
    return $proof
}

Export-ModuleMember -Function Get-FreshThreadRestartProofContract, Test-FreshThreadRestartProofObject, Test-FreshThreadRestartProofContract, New-FreshThreadRestartProof
