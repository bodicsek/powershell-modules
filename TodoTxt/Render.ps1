$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\File.ps1"

<#
.Synopsis
    Shows the content of a todo.txt file.
.DESCRIPTION
    Long description
.EXAMPLE
    Example of how to use this cmdlet
.EXAMPLE
    Another example of how to use this cmdlet
#>
function Show-TodoTxt {
    [Alias("t")]
    [CmdletBinding()]
    Param (
        # The full path of the todo.txt file.
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]
        $File = $script:File,

        # The priority -> foreground color map
        [Parameter(Mandatory=$false)]
        [System.Collections.Hashtable]
        $ColorMap = @{
            [Priority]::A = 'Yellow';
            [Priority]::B = 'Green';
            [Priority]::C = 'Cyan';
            [Priority]::Undefined = 'Gray';
        }
    )

    Begin {
    }
    Process {
        Import-TodoTxtFile $File |
        group -Property Priority |
        sort -Property Name |
        select -ExpandProperty Group |
        % { Write-Host ("{0,2:G} {1}" -f $_.Id, $_.Text) -ForegroundColor $ColorMap.($_.Priority) } |
        Out-Null
    }
    End {
    }
}

