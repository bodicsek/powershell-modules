﻿$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\Line.ps1"

<#
.Synopsis
    Imports a todo.txt file
.DESCRIPTION
    The given file is parsed as a todo.txt file using the Import-TodoTxtLine cmdlet.
    The return value is $null if there is no content in the file.
    The return value is an array of parsed custom objects (see: Get-Hel Import-TodoTxtLine) if there were valid todo.txt lines in the file.
    A 'File not found' exception is thrown if the file is nonexistent.
.EXAMPLE
    Import-TodoTxtFile todo.txt
.EXAMPLE
    Import-TodoTxtFile -File todo.txt
#>
function Import-TodoTxtFile {
    [CmdletBinding()]
    Param
    (
        # Full path of a todo.txt file.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $File
    )

    Begin {
    }
    Process {
        $lines = @(Get-Content $File -ErrorAction Stop | where Length -gt 0)
        for ($i = 0; $i -lt $lines.Length; $i++) {
            Import-TodoTxtItem $lines[$i] |
            Add-Member -NotePropertyName Id -NotePropertyValue $i -PassThru
        }
    }
    End {
    }
}

<#
.Synopsis
    Exports todo items into a todo.txt file.
.DESCRIPTION
    Generates valid todo.txt lines from the todo item objects and writes them to a file.
    It is possible to append the generated lines to the file using the -Append switch.
.EXAMPLE
    Export-TodoTxtFile -Object @{Text="my todo item";} -File .\todo.txt
    The content of the todo.txt file becomes a single todo.txt line.
.EXAMPLE
    Export-TodoTxtFile -Object @{Text="my todo item";}, @{Text="my next todo item";} -File .\todo.txt
    The content of the todo.txt file becomes two todo.txt lines.
.EXAMPLE
    Export-TodoTxtFile -Object @{Text="my todo item";} -File .\todo.txt -Append
    The todo.txt line that represents the item is appended to todo.txt file.
#>
function Export-TodoTxtFile {
    [CmdletBinding()]
    Param
    (
        # The todo items that should be written to a file.
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [psobject[]]
        $Objects,

        # The destination file of the export.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $File,

        # A switch that signs if the items should be appended to the file.
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$false)]
        [switch]
        $Append,

        # A switch that signs if the items should be exported in archive format and appended to the file.
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$false)]
        [switch]
        $Archive
    )

    Begin {
        $isAppendPresent = $Append.IsPresent
        $exportAction = { Param($Object) Export-TodoTxtItem $Object }
        if ($Archive.IsPresent) {
            $isAppendPresent = $true
            $exportAction = { Param($Object) Export-TodoTxtItem $Object -Archive }
        }
    }
    Process {
        if ($Objects.Length -gt 0) {
            $lines = $Objects | foreach { Invoke-Command $exportAction -ArgumentList $_ } | where { $_ -ne $null }
            if ($lines.Length -gt 0) {
                if ($isAppendPresent) {
                    $lines | Out-File $File utf8 -Append
                } else {
                    $lines | Out-File $File utf8
                }
            }
        }
        elseif ($(Test-Path $File) -and !$isAppendPresent) {
            Set-Content $File ""
        }
    }
    End {
    }
}