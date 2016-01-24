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
    Import-TodoTxtLine "(A) Feed the cat @home +Cat"

    It returns an object:
    Priority     : A
    Context      : home
    Project      : Cat
    Text         : (A) Feed the cat @home +Cat
    CreationDate : 1/1/0001 12:00:00 AM
#>
function Import-TodoTxtLine
{
    [CmdletBinding()]
    Param
    (
        # A valid Todo.txt line (https://github.com/ginatrapani/todo.txt-cli/wiki/The-Todo.txt-Format)
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]
        $Line
    )

    Begin
    {}
    Process
    {
        New-Object psobject -Property @{
            Text = $Line;
            Priority = ParseTodoTxtLinePriority $Line;
            CreationDate = ParseTodoTxtLineCreationDate $Line;
            Context = ParseTodoTxtLineContext $Line;
            Project = ParseTodoTxtLineProject $Line;
        }
    }
    End
    {}
}

Add-Type -TypeDefinition @"
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

function ParseTodoTxtLinePriority ($line)
{
    $stringValue = GetAllRegexCaptureOccurances '^\(([A-Z])\)' $line | select -First 1
    if ($stringValue)
    {
        [System.Enum]::Parse([type]"Priority", $stringValue)
    }
    else
    {
        [Priority]::Undefined
    }
}

function ParseTodoTxtLineCreationDate ($line)
{
    $creationDateAtStart = GetAllRegexCaptureOccurances '^([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])' $line | select -First 1
    if ($creationDateAtStart)
    {
        [DateTime]$creationDateAtStart
    }
    else
    {
        $creationDateAfterPrio = GetAllRegexCaptureOccurances '^\([A-Z]\) ([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9])' $line | select -First 1
        if ($creationDateAfterPrio)
        {
            [DateTime]$creationDateAfterPrio
        }
        else
        {
            $null
        }
    }
}

function ParseTodoTxtLineContext ($line)
{
    GetAllRegexCaptureOccurances '@([A-Za-z]+)' $line
}

function ParseTodoTxtLineProject ($line)
{
    GetAllRegexCaptureOccurances '\+([A-Za-z]+)' $line
}

function GetAllRegexCaptureOccurances($regexWithCapture, $line)
{
    $matches = Select-String $regexWithCapture -InputObject $line -AllMatches |
               select -ExpandProperty Matches
    foreach ($match in $matches)
    {
        $match.Groups[1].Value
    }
}
