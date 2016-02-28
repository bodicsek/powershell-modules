$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Import-TodoTxtFile" {

    Context "when the given file does not exist" {

        $nonexistentPath = ".\todo.txt"

        It "should throw" {
            { Import-TodoTxtFile $nonexistentPath } | Should Throw
        }
    }

    Context "when the given file is empty" {
        In $TestDrive {

            $emptyFile = ".\todo.txt"
            Set-Content $emptyFile -Value ""

            It "returns `$null" {
                $result = Import-TodoTxtFile $emptyFile
                $result | Should BeNullOrEmpty
            }
        }
    }

    Context "when the given file contains todo.txt lines" {
        In $TestDrive {

            $todoTxtFile = ".\todo.txt"
            Set-Content $todoTxtFile -Value "(A) todo1 @home +hobby"
            Add-Content $todoTxtFile -Value "(B) 2016-01-01 todo2 @office +projectA"

            It "returns one object per line" {
                $todos = Import-TodoTxtFile $todoTxtFile

                ($todos | measure | select -ExpandProperty Count) |
                    Should Be 2
            }

            It "adds unique ids to the todo objects" {
                $todos = Import-TodoTxtFile $todoTxtFile

                $todos[0].Id | Should Be 0
                $todos[1].Id | Should Be 1
            }
        }
    }
}

Describe "Export-TodoTxtFile" {

    Context "when the given file does not exist" {

        It "creates no file if the todo item objects are not valid" {
            In $TestDrive {
                Export-TodoTxtFile @{Name = "test"} -File .\todo.txt

                ".\todo.txt" | Should Not Exist
            }
        }

        It "creates a new file with one line per todo item object" {
            In $TestDrive {
                Export-TodoTxtFile -Object @{Text = "test item"},@{Priority=[Priority]::A;Text="important"} -File .\todo.txt

                ".\todo.txt" | Should Exist
                ".\todo.txt" | Should Contain "test item"
                ".\todo.txt" | Should Contain "\(A\) important"
            }
        }
    }

    Context "when the given file exists" {

        In $TestDrive {

            $todoTxtFile = ".\todo.txt"
            Set-Content $todoTxtFile -Value "(A) todo1 @home +hobby"
            Add-Content $todoTxtFile -Value "(B) 2016-01-01 todo2 @office +projectA"

            It "does not change the content of the file if the todo item objects are invalid" {
                Export-TodoTxtFile @{Name = "test"} -File .\todo.txt

                ".\todo.txt" | Should Not Contain "test"
                ".\todo.txt" | Should Contain "\(A\) todo1 @home \+hobby"
                ".\todo.txt" | Should Contain "\(B\) 2016-01-01 todo2 @office \+projectA"
            }

            It "replaces the content of the file with one line per todo item object" {
                Export-TodoTxtFile -Object @{Text = "test item"},@{Priority=[Priority]::A;Text="important"} -File .\todo.txt

                ".\todo.txt" | Should Contain "test item"
                ".\todo.txt" | Should Contain "\(A\) important"
                ".\todo.txt" | Should Not Contain "\(A\) todo1 @home \+hobby"
                ".\todo.txt" | Should Not Contain "\(B\) 2016-01-01 todo2 @office \+projectA"
            }
        }
    }

    Context "when the -Append switch is present"  {

        In $TestDrive {

            $todoTxtFile = ".\todo.txt"
            Set-Content $todoTxtFile -Value "(A) todo1 @home +hobby"
            Add-Content $todoTxtFile -Value "(B) 2016-01-01 todo2 @office +projectA"

            It "does not append new line to the file if the todo item objects are invalid" {
                Export-TodoTxtFile @{Name = "test"} -File .\todo.txt -Append

                ".\todo.txt" | Should Not Contain "test"
                ".\todo.txt" | Should Contain "\(A\) todo1 @home \+hobby"
                ".\todo.txt" | Should Contain "\(B\) 2016-01-01 todo2 @office \+projectA"
            }

            It "appends one line per todo item object to the file" {
                Export-TodoTxtFile @{Text = "test"} -File .\todo.txt -Append

                ".\todo.txt" | Should Contain "test"
                ".\todo.txt" | Should Contain "\(A\) todo1 @home \+hobby"
                ".\todo.txt" | Should Contain "\(B\) 2016-01-01 todo2 @office \+projectA"
            }
        }
    }
}
