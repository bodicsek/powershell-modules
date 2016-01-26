$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Import-TodoTxtFile" {

    Context "when the given file does not exist" {

        $nonexistentPath = ".\todo.txt"

        It "should throw" {
            Import-TodoTxtFile $nonexistentPath | Should Throw
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
