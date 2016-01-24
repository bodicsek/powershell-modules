$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Import-TodoTxtLine" {
    It "parses a default todo.txt line **without any special element** in it" {
        $line = "This is a line without place, project, priority and extra properties."
        $todoObj = Import-TodoTxtLine $line
        $todoObj.Text | Should Be $line
        $todoObj.Priority -Is [Priority] | Should Be $true
        $todoObj.Priority | Should Be Undefined
    }

    It "parses a todo.txt line with **creation date** in it" {
        $line = "2016-01-16 This is a line with creation date."
        $todoObj = Import-TodoTxtLine $line
        $todoObj.Text | Should Be $line
        $todoObj.CreationDate | Should Be ([DateTime]"2016-01-16")
    }

    It "parses a todo.txt line that starts with a **priority** e.g.: (A)" {
        $line = "(A) This is a line that starts with priority."
        $todoObj = Import-TodoTxtLine $line
        $todoObj.Text | Should Be $line
        $todoObj.Priority | Should Be ([Priority]::A)
    }

    It "parses a todo.txt line that starts with a **priority and a creation date** e.g.: (A) 2016-01-06" {
        $line = "(A) 2016-01-06 This is a line that starts with priority and creation date."
        $todoObj = Import-TodoTxtLine $line
        $todoObj.Text | Should Be $line
        $todoObj.Priority | Should Be ([Priority]::A)
        $todoObj.CreationDate | Should Be ([DateTime]"2016-01-06")
    }

    It "parses a todo.txt line that contains **context**" {
        $line = "(A) This is a line with @context in it."
        $todoObj = Import-TodoTxtLine $line
        $todoObj.Text | Should Be $line
        $todoObj.Context | Should Be @("context")
    }

    It "parses a todo.txt line that contains **multiple context** references" {
        $line = "(A) This is a line with @contextone and @contexttwo in it."
        $todoObj = Import-TodoTxtLine $line
        $todoObj.Text | Should Be $line
        $todoObj.Context | Should Be @("contextone", "contexttwo")
    }

    It "parses a todo.txt line that contains **project**" {
        $line = "(A) This is a line with +project in it."
        $todoObj = Import-TodoTxtLine $line
        $todoObj.Text | Should Be $line
        $todoObj.Project | Should Be @("project")
    }

    It "parses a todo.txt line that contains **multiple project** references" {
        $line = "(A) This is a line with +projectA and +projectB in it."
        $todoObj = Import-TodoTxtLine $line
        $todoObj.Text | Should Be $line
        $todoObj.Project | Should Be @("projectA", "projectB")
    }
}

