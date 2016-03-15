$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\Line.ps1"
. "$here\File.ps1"

<#
.SYNOPSIS
    Creates a new todo.txt item.
.DESCRIPTION
    Creates a new todo.txt item from a given string.
    When $File is provided it appends the new line to it.
    Returns the todo.txt item object.
.EXAMPLE
    New-TodoTxtItem "My new todo"
.EXAMPLE
    New-TodoTxtItem "My new todo" -File todo.txt
.EXAMPLE
    New-TodoTxtItem -Text "My new todo" -Priority A -Context home,office -Project ProjectA
.EXAMPLE
    New-TodoTxtItem "(A) My new todo @home @office +ProjectA"
#>
function New-TodoTxtItem {
    [Alias("nt")]
    [CmdletBinding()]
    Param (
        # The todo description. It can be a valid todo.txt line.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]
        $Text,

        # The todo.txt file.
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $File = $script:File,

        # The priority of the new item [A-Z].
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [Priority]
        $Priority,

        # The context of the new item.
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [string[]]
        $Context,

        # The project of the new item.
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [string[]]
        $Project
    )

    Begin {
    }

    Process {
        $newItem = Import-TodoTxtItem $Text
        if ($Priority) {
            $newItem.Priority = $Priority
        }
        if ($Context) {
            $newItem.Context = $Context
        }
        if ($Project) {
            $newItem.Project = $Project
        }
        if ($File) {
            Export-TodoTxtFile $newItem -File $File -Append | Out-Null
        }
        $newItem
    }

    End {
    }
}

<#
.SYNOPSIS
    Removes a todo.txt item.
.DESCRIPTION
    Removes the todo.txt item from the given File that has the given Id.
    Ids are assigned based on the order of the items in File.
.EXAMPLE
    Remove-TodoTxtItem 1
.EXAMPLE
    Remove-TodoTxtItem -Id 1
#>
function Remove-TodoTxtItem {
    [Alias("rt")]
    [CmdletBinding()]
    Param (
        # The Id of the todo.txt item.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [int]
        $Id,

        # The todo.txt file.
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $File = $script:File
    )

    Begin {
    }

    Process {
        Try {
            $oldItems = Import-TodoTxtFile -File $File -ErrorAction Stop
            $itemToBeDeleted = $oldItems | where {$_.Id -eq $Id}
            $newItems = $oldItems | where {$_.Id -ne $Id}
            Export-TodoTxtFile -Objects $newItems -File $File -ErrorAction Stop
            $itemToBeDeleted
        }
        Catch {

        }
    }

    End {
    }
}

<#
.SYNOPSIS
    Marks a todo.txt item as done.
.DESCRIPTION
    Removes the todo.txt item from the given File that has the given Id.
    Ids are assigned based on the order of the items in File.
    Adds the item to the done.txt file with a mark X and the date of the archival.
.EXAMPLE
    Complete-TodoTxtItem 1
.EXAMPLE
    Complete-TodoTxtItem -Id 1
#>
function Complete-TodoTxtItem {
    [Alias("ct")]
    [CmdletBinding()]
    Param (
        # The Id of the todo.txt item.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [int]
        $Id,

        # The todo.txt file.
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $File = $script:File
    )

    Begin {
        $itemToBeArchived = Remove-TodoTxtItem -Id $Id -File $File
        $archiveFile = $(Split-Path $File) + "\\done.txt"
        Export-TodoTxtFile -Objects @($itemToBeArchived) -File $archiveFile -Archive
    }

    Process {
    }

    End {
    }
}