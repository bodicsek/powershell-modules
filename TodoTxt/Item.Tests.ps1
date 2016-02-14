$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "New-TodoTxtItem" {

    In $TestDrive {

        BeforeEach {
            Get-ChildItem "." | Remove-Item
        }

        Context "when File parameter is not present" {
            It "creates the new object and returns it" {
                $line = "My new item"
                $todoItem = New-TodoTxtItem $line

                Get-ChildItem "." | Should Be $null
                $todoItem.Text | Should Be $line
            }
        }

        Context "when explicit File parameter is present" {
            It "creates a new object and appends it to File" {
                $file = ".\todo.txt"
                Set-Content $file -Value ""
                $line = "This item must be written to file"

                $todoItem = New-TodoTxtItem $line -File $file

                $file | Should Contain $line
            }
        }

        Context "when implicit File parameter is present" {
            It "creates a new object and appends it to File" {
                $script:File = ".\todo.txt"
                Set-Content $File -Value ""
                $line = "This item must be written to File"

                $todoItem = New-TodoTxtItem $line

                $file | Should Contain $line
            }
        }

        Context "when the given File does not exist" {
            It "creates the File and appends the new todo.txt item to it" {
                $file = ".\todo.txt"
                $line = "This item must be written to file"

                $todoItem = New-TodoTxtItem $line -File $file

                $file | Should Contain $line
            }
        }

        Context "when only the Text parameter is present" {

            It "returns a todo.txt item ps object" {
                $text = "(A) My new item @home +ProjectA"

                $newItem = New-TodoTxtItem $text

                $newItem.Text | Should Be $text
                $newItem.Priority | Should Be ([Priority]::A)
                $newItem.Context | Should Be @("home")
                $newItem.Project | Should Be @("ProjectA")
            }
        }

        Context "when modifier parameters are present" {

            It "returns a todo.txt item ps object with properties according to the parameters" {
                $text = "My new item"
                $priority = [Priority]::B
                $context = "office"
                $project = "ProjectB"

                $newItem = New-TodoTxtItem $text -Priority $priority -Context $context -Project $project

                $newItem.Text | Should Be $text
                $newItem.Priority | Should Be $priority
                $newItem.Context | Should Be $context
                $newItem.Project | Should Be $project
            }
        }
    }
}
