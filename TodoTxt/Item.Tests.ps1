$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "New-TodoTxtItem" {

    In $TestDrive {

        Context "when File parameter is not present" {
            It "creates the new object and returns it" {

            }
        }

        Context "when explicit File parameter is present" {
            It "creates a new object and appends it to File" {

            }
        }

        Context "when implicit File parameter is present" {
            It "creates a new object and appends it to File" {

            }
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

        }
    }
}
