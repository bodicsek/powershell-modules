$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Import-TodoTxtItem" {
    It "parses a default todo.txt line **without any special element** in it" {
        $line = "This is a line without place, project, priority and extra properties."
        $todoObj = Import-TodoTxtItem $line
        $todoObj.Text | Should Be $line
        $todoObj.Priority -Is [Priority] | Should Be $true
        $todoObj.Priority | Should Be Undefined
    }

    It "parses a todo.txt line with **creation date** in it" {
        $line = "2016-01-16 This is a line with creation date."
        $todoObj = Import-TodoTxtItem $line
        $todoObj.Text | Should Be $line
        $todoObj.CreationDate | Should Be ([DateTime]"2016-01-16")
    }

    It "parses a todo.txt line that starts with a **priority** e.g.: (A)" {
        $line = "(A) This is a line that starts with priority."
        $todoObj = Import-TodoTxtItem $line
        $todoObj.Text | Should Be $line
        $todoObj.Priority | Should Be ([Priority]::A)
    }

    It "parses a todo.txt line that starts with a **priority and a creation date** e.g.: (A) 2016-01-06" {
        $line = "(A) 2016-01-06 This is a line that starts with priority and creation date."
        $todoObj = Import-TodoTxtItem $line
        $todoObj.Text | Should Be $line
        $todoObj.Priority | Should Be ([Priority]::A)
        $todoObj.CreationDate | Should Be ([DateTime]"2016-01-06")
    }

    It "parses a todo.txt line that contains **context**" {
        $line = "(A) This is a line with @context in it."
        $todoObj = Import-TodoTxtItem $line
        $todoObj.Text | Should Be $line
        $todoObj.Context | Should Be @("context")
    }

    It "parses a todo.txt line that contains **multiple context** references" {
        $line = "(A) This is a line with @contextone and @contexttwo in it."
        $todoObj = Import-TodoTxtItem $line
        $todoObj.Text | Should Be $line
        $todoObj.Context | Should Be @("contextone", "contexttwo")
    }

    It "parses a todo.txt line that contains **project**" {
        $line = "(A) This is a line with +project in it."
        $todoObj = Import-TodoTxtItem $line
        $todoObj.Text | Should Be $line
        $todoObj.Project | Should Be @("project")
    }

    It "parses a todo.txt line that contains **multiple project** references" {
        $line = "(A) This is a line with +projectA and +projectB in it."
        $todoObj = Import-TodoTxtItem $line
        $todoObj.Text | Should Be $line
        $todoObj.Project | Should Be @("projectA", "projectB")
    }
}

Describe "Export-TodoTxtItem" {

    Context "when there is no recognized todo object property" {

        It "returns `$null" {
            $todoItem = New-Object psobject

            $lineToWrite = Export-TodoTxtItem $todoItem

            $lineToWrite | Should Be $null
        }
    }

    Context "when Priority is undefined and CreationDate is not present" {

        It "returns the Text property only" {
            $todoItem = New-Object psobject -Property @{
                Text = "test item";
                Priority = [Priority]::Undefined;
            }

            $lineToWrite = Export-TodoTxtItem $todoItem

            $lineToWrite | Should Be "test item"
        }

    }

    Context "when Priority is defined but there is no CreationDate" {

        It "returns '(Priority) Text'" {
            $todoItem = New-Object psobject -Property @{
                Text = "test item";
                Priority = [Priority]::A;
            }

            $lineToWrite = Export-TodoTxtItem $todoItem

            $lineToWrite | Should BeExactly "(A) test item"
        }

        It "returns '(Priority) Text' even if the original Text has '(Priority)'" {
            $todoItem = New-Object psobject -Property @{
                Text = "(A) test item";
                Priority = [Priority]::A;
            }

            $lineToWrite = Export-TodoTxtItem $todoItem

            $lineToWrite | Should BeExactly "(A) test item"
        }
    }

    Context "when Priority and CreationDate are present" {

        It "returns '(Priority) CreationDate Text'" {
            $todoItem = New-Object psobject -Property @{
                Text = "test item";
                Priority = [Priority]::A;
                CreationDate = [datetime]"2016-01-01";
            }

            $lineToWrite = Export-TodoTxtItem $todoItem

            $lineToWrite | Should Be "(A) 2016-01-01 test item"
        }

        It "returns '(Priority) CreationDate Text' even if the original Text contains '(Priority) CreationDate'" {
            $todoItem = New-Object psobject -Property @{
                Text = "(A) 2016-01-01 test item";
                Priority = [Priority]::B;
                CreationDate = [datetime]"2016-01-02";
            }

            $lineToWrite = Export-TodoTxtItem $todoItem

            $lineToWrite | Should Be "(B) 2016-01-02 test item"
        }
    }

    Context "when the -Archive parameter is present" {

        It "returns 'x DateTime.Now (Priority) CreationDate Text'" {
            $today = "{0:yyyy-MM-dd}" -f [datetime]::Now
            $todoItem = New-Object psobject -Property @{
                Text = "test item";
                Priority = [Priority]::A;
                CreationDate = [datetime]"2016-01-01";
            }

            $lineToWrite = Export-TodoTxtItem $todoItem -Archive

            $lineToWrite | Should Be "x $today (A) 2016-01-01 test item"
        }

        It "returns 'x DateTime.Now (Priority) CreationDate Text' even if the original Text contains '(Priority) CreationDate'" {
            $today = "{0:yyyy-MM-dd}" -f [datetime]::Now
            $todoItem = New-Object psobject -Property @{
                Text = "(A) 2016-01-01 test item";
                Priority = [Priority]::B;
                CreationDate = [datetime]"2016-01-02";
            }

            $lineToWrite = Export-TodoTxtItem $todoItem -Archive

            $lineToWrite | Should Be "x $today (B) 2016-01-02 test item"
        }

    }

    Context "when all parameters are present" {

        It "returns a todo.txt line with all the parameters" {
            $todoItem = New-Object psobject -Property @{
                Text = "test item";
                Priority = "C";
                CreationDate = "2016-01-01";
                Project = @("+ProjectA");
                Context = @("@home");
            }

            $todoLine = Export-TodoTxtItem $todoItem

            $todoLine | Should BeExactly "(C) 2016-01-01 test item @home +ProjectA"
        }

        It "returns a todo.txt line with all parameters even if the parameters were in Text property" {
            $todoItem = New-Object psobject -Property @{
                Text = "(C) 2016-01-01 test item @home +ProjectA";
                Priority = "C";
                CreationDate = "2016-01-01";
                Project = @("+ProjectA");
                Context = @("@home");
            }

            $todoLine = Export-TodoTxtItem $todoItem

            $todoLine | Should BeExactly "(C) 2016-01-01 test item @home +ProjectA"
        }
    }
}