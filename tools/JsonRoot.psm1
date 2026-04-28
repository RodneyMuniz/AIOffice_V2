Set-StrictMode -Version Latest

function Get-ConvertFromJsonNoEnumerateSupport {
    $command = Get-Command -Name ConvertFrom-Json -ErrorAction Stop
    return $command.Parameters.ContainsKey("NoEnumerate")
}

function Get-ConvertFromJsonDateKindStringSupport {
    $command = Get-Command -Name ConvertFrom-Json -ErrorAction Stop
    return $command.Parameters.ContainsKey("DateKind")
}

function Convert-DateValueToJsonString {
    param(
        [Parameter(Mandatory = $true)]
        $Value
    )

    if ($Value -is [datetime]) {
        return $Value.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture)
    }

    if ($Value -is [datetimeoffset]) {
        return $Value.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ", [System.Globalization.CultureInfo]::InvariantCulture)
    }

    return $Value
}

function Convert-JsonDatesToStrings {
    [CmdletBinding()]
    param(
        [AllowNull()]
        $Value
    )

    if ($null -eq $Value) {
        $PSCmdlet.WriteObject($null, $false)
        return
    }

    if ($Value -is [datetime] -or $Value -is [datetimeoffset]) {
        $PSCmdlet.WriteObject((Convert-DateValueToJsonString -Value $Value), $false)
        return
    }

    if ($Value -is [System.Array]) {
        for ($index = 0; $index -lt $Value.Count; $index += 1) {
            $Value[$index] = Convert-JsonDatesToStrings -Value $Value[$index]
        }

        $PSCmdlet.WriteObject($Value, $false)
        return
    }

    if ($Value -is [pscustomobject]) {
        foreach ($property in @($Value.PSObject.Properties)) {
            $property.Value = Convert-JsonDatesToStrings -Value $property.Value
        }

        $PSCmdlet.WriteObject($Value, $false)
        return
    }

    $PSCmdlet.WriteObject($Value, $false)
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
        $convertParameters = @{
            InputObject = $json
        }

        if (Get-ConvertFromJsonNoEnumerateSupport) {
            $convertParameters["NoEnumerate"] = $true
        }

        if (Get-ConvertFromJsonDateKindStringSupport) {
            $convertParameters["DateKind"] = "String"
        }

        $document = ConvertFrom-Json @convertParameters
    }
    catch {
        throw "$Label at '$Path' is not valid JSON. $($_.Exception.Message)"
    }

    Assert-SingleJsonRootObject -Document $document -Label $Label
    $document = Convert-JsonDatesToStrings -Value $document
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

Export-ModuleMember -Function Read-SingleJsonObject, Assert-SingleJsonRootObject, Test-JsonRootShape, Get-ConvertFromJsonNoEnumerateSupport, Get-ConvertFromJsonDateKindStringSupport
