﻿$here = Split-Path -Parent $MyInvocation.MyCommand.Path
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

Describe "Remove-TodoTxtItem" {
    In $TestDrive {

        $TestFile = ".\todo.txt"

        Context "when there is no explicit or implicit File parameter" {
            It "throws an exception" {
                Remove-TodoTxtItem -Id 2 | Should Throw
            }
        }

        Context "when the given Id is not valid" {
            It "the File remains as is" {
                Set-Content $TestFile -Value "(A) item one"
                Add-Content $TestFile -Value "(B) item two"
                Add-Content $TestFile -Value "(C) item three"

                Remove-TodoTxtItem -Id 4 -File $TestFile

                $TestFile | Should Contain "\(A\) item one"
                $TestFile | Should Contain "\(B\) item two"
                $TestFile | Should Contain "\(C\) item three"
            }
        }

        Context "when the given Id is valid" {
            It "removes the appropriate line from the given file" {
                Set-Content $TestFile -Value "(A) item one"

                Remove-TodoTxtItem -Id 1 -File $TestFile

                $TestFile | Should Not Contain "\(A\) item one"
            }
        }

    }
}

Describe "Done-TodoTxtItem" {
    In $TestDrive {
        Context "when there is neither explicit nor implecit File parameter" {
            It "throws an exception" {

            }
        }
        Context "when the given Id is invalid" {
            It "leaves the File as is an nothing is archived" {

            }
        }
        Context "when the given ID is valid" {
            It "removes the item from File and add an archive entry to FilePath\done.txt" {

            }
        }
    }
}
