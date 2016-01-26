$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\ParseLine.ps1"

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
function Import-TodoTxtFile
{
    [CmdletBinding()]
    Param
    (
        # Full path of a todo.txt file.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $File
    )

    Begin
    {
    }
    Process
    {
        $lines = Get-Content $File | where Length -gt 0
        for ($i = 0; $i -lt $lines.Length; $i++)
        {
            Import-TodoTxtLine $lines[$i] | Add-Member -NotePropertyName Id -NotePropertyValue $i -PassThru
        }
    }
    End
    {
    }
}
