Set-StrictMode -Version Latest

function Get-ConvertFromJsonNoEnumerateSupport {
    $command = Get-Command -Name ConvertFrom-Json -ErrorAction Stop
    return $command.Parameters.ContainsKey("NoEnumerate")
}

function Assert-SingleJsonRootObject {
    param(
        [AllowNull()]
        $Document,
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    if ($null -eq $Document) {
        throw "$Label root must be a single JSON object, but it was null."
    }

    if ($Document -is [System.Array]) {
        throw "$Label root must be a single JSON object, but it loaded as an array/property stream."
    }

    if ($Document -isnot [pscustomobject]) {
        throw "$Label root must be a single JSON object, but it loaded as '$($Document.GetType().FullName)'."
    }
}

function Read-SingleJsonObject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$Label = "JSON document"
    )

    $resolvedPath = if (Test-Path -LiteralPath $Path) {
        (Resolve-Path -LiteralPath $Path).Path
    }
    else {
        [System.IO.Path]::GetFullPath($Path)
    }

    try {
        $json = [System.IO.File]::ReadAllText($resolvedPath)
    }
    catch {
        throw "$Label at '$Path' could not be read. $($_.Exception.Message)"
    }

    $trimmedJson = $json.TrimStart([char]0xFEFF, [char]0x20, [char]0x09, [char]0x0A, [char]0x0D)
    if ([string]::IsNullOrWhiteSpace($trimmedJson)) {
        throw "$Label root must be a single JSON object, but the file is empty."
    }

    $firstCharacter = $trimmedJson[0]
    if ($firstCharacter -eq "[") {
        throw "$Label root must be a single JSON object; array root documents are not accepted."
    }

    if ($firstCharacter -ne "{") {
        throw "$Label root must be a single JSON object, but the root does not start with '{'."
    }

    try {
        if (Get-ConvertFromJsonNoEnumerateSupport) {
            $document = ConvertFrom-Json -InputObject $json -NoEnumerate
        }
        else {
            $document = ConvertFrom-Json -InputObject $json
        }
    }
    catch {
        throw "$Label at '$Path' is not valid JSON. $($_.Exception.Message)"
    }

    Assert-SingleJsonRootObject -Document $document -Label $Label
    return $document
}

function Test-JsonRootShape {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$Label = "JSON document"
    )

    try {
        $document = Read-SingleJsonObject -Path $Path -Label $Label
        return [pscustomobject]@{
            IsSingleJsonObject = $true
            RootType = $document.GetType().FullName
            Error = $null
        }
    }
    catch {
        return [pscustomobject]@{
            IsSingleJsonObject = $false
            RootType = $null
            Error = $_.Exception.Message
        }
    }
}

Export-ModuleMember -Function Read-SingleJsonObject, Assert-SingleJsonRootObject, Test-JsonRootShape, Get-ConvertFromJsonNoEnumerateSupport
