﻿Add-Type -TypeDefinition @"
   public enum Priority
   {
      Undefined,
      A,
      B,
      C,
      D,
      E,
      F,
      G,
      H,
      I,
      J,
      K,
      L,
      M,
      N,
      O,
      P,
      Q,
      R,
      S,
      T,
      U,
      V,
      W,
      X,
      Y,
      Z
   }
"@

<#
.Synopsis
    Parses a Todo.txt line.
.DESCRIPTION
    Parses a Todo.txt line into a PS custom object.

    Properties:
    ===========
    Context       string[]  Every @context reference
    CreationDate  datetime  Date of creation
    Priority      Priority  Priority
    Project       string[]  Every +project reference
    Text          string    The full todo.txt line
.EXAMPLE
    Import-TodoTxtItem "(A) Feed the cat @home +Cat"

    It returns an object:
    Priority     : A
    Context      : home
    Project      : Cat
    Text         : (A) Feed the cat @home +Cat
    CreationDate : 1/1/0001 12:00:00 AM
#>
function Import-TodoTxtItem
{
    [CmdletBinding()]
    [OutputType([psobject])]
    Param (
        # A valid Todo.txt line (https://github.com/ginatrapani/todo.txt-cli/wiki/The-Todo.txt-Format).
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]
        $Line
    )

    Begin {
        function ParseTodoTxtItemPriority ($line) {
            $stringValue = GetAllRegexCaptureOccurances '^\(([A-Z])\)' $line | select -First 1
            if ($stringValue) {
                [System.Enum]::Parse([type]"Priority", $stringValue)
            } else {
                [Priority]::Undefined
            }
        }

        function ParseTodoTxtItemCreationDate ($line) {
            $creationDateAtStart = GetAllRegexCaptureOccurances '^(\d{4}-\d{2}-\d{2})' $line | select -First 1
            if ($creationDateAtStart) {
                [DateTime]$creationDateAtStart
            } else {
                $creationDateAfterPrio = GetAllRegexCaptureOccurances '^\([A-Z]\) (\d{4}-\d{2}-\d{2})' $line | select -First 1
                if ($creationDateAfterPrio) {
                    [DateTime]$creationDateAfterPrio
                } else {
                    $null
                }
            }
        }

        function ParseTodoTxtItemContext ($line) {
            GetAllRegexCaptureOccurances '@(\S+)' $line
        }

        function ParseTodoTxtItemProject ($line) {
            GetAllRegexCaptureOccurances '\+(\S+)' $line
        }

        function GetAllRegexCaptureOccurances($regexWithCapture, $line) {
            $matches = Select-String $regexWithCapture -InputObject $line -AllMatches |
                    select -ExpandProperty Matches
            foreach ($match in $matches) {
                $match.Groups[1].Value
            }
        }
    }
    Process {
        New-Object psobject -Property @{
            Text = $Line;
            Priority = ParseTodoTxtItemPriority $Line;
            CreationDate = ParseTodoTxtItemCreationDate $Line;
            Context = ParseTodoTxtItemContext $Line;
            Project = ParseTodoTxtItemProject $Line;
        }
    }
    End {
    }
}

<#
.Synopsis
    Exports a todo item.
.DESCRIPTION
    A todo item is exported to a valid todo.txt line (https://github.com/ginatrapani/todo.txt-cli/wiki/The-Todo.txt-Format).

    Recognized todo item properties:
    ===========
    Context       string[]  Every @context reference
    CreationDate  datetime  Date of creation
    Priority      Priority  Priority
    Project       string[]  Every +project reference
    Text          string    The full todo.txt line

    It is possible to export a todo item as an archive todo.txt line:
    'x 2016-01-01 (A) my todo item'
.EXAMPLE
    Export-TodoTxtItem -Object @{Text = "my todo"}
#>
function Export-TodoTxtItem
{
    [CmdletBinding()]
    [OutputType([string])]
    Param (
        # A todo item object.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [psobject]
        $Object,

        # If this switch is defined the format is the archive format.
        [Parameter(Mandatory=$false)]
        [switch]
        $Archive
    )

    Begin {
        function RemoveExistingProperties ($text) {
            $newText = $($text -replace '^\([A-Z]\)', '').Trim()
            $newText = $($newText -replace '^\d\d\d\d-\d\d-\d\d', '').Trim()
            $newText = $($newText -replace ' @\S+')
            $($newText -replace ' \+\S+')
        }
    }
    Process
    {
        $todoTxtLine = ""
        if ($Object.Priority -ne $null -and $Object.Priority -ne [Priority]::Undefined) {
            $todoTxtLine += "(" + $Object.Priority + ") "
        }
        if ($Object.CreationDate -ne $null) {
            $todoTxtLine += "{0:yyyy-MM-dd} " -f $Object.CreationDate
        }
        if ($Object.Text -ne $null) {
            $todoTxtLine += RemoveExistingProperties $Object.Text
        }
        if ($Object.Context -ne $null) {
            foreach ($ctx in $Object.Context) {
                $todoTxtLine += " @" + $ctx
            }
        }
        if ($Object.Project -ne $null) {
            foreach ($proj in $Object.Project) {
                $todoTxtLine += " +" + $proj
            }
        }

        if ($todoTxtLine -ne "") {
            if ($Archive.IsPresent) {
                $todoTxtLine = "x " + ("{0:yyyy-MM-dd} " -f [DateTime]::Now) + $todoTxtLine
            }
            return $todoTxtLine
        }
        $null
    }
    End {
    }
}

