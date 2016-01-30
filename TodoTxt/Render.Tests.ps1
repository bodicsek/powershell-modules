$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Show-TodoTxt" {

    Context "when the todo items are unordered" {

        In $TestDrive {

            $todoTxtFile = ".\todo.txt"
            Set-Content $todoTxtFile -Value "(C) todo1 @home +hobby"
            Add-Content $todoTxtFile -Value "simple"
            Add-Content $todoTxtFile -Value "(B) 2016-01-01 todo2 @office +projectA"
            Add-Content $todoTxtFile -Value "(A) todo3 @phone"

            It "the ouput is ordered by priority" {
                $output = New-Object -TypeName System.Collections.ArrayList
                Mock Write-Host {
                    $a = [ref]$output
                    $a.Value.Add($object)
                }.GetNewClosure()

                Show-TodoTxt -File $todoTxtFile

                $output[0] | Should Match "(A)"
                $output[1] | Should Match "(B)"
                $output[2] | Should Match "(C)"
                $output[3] | Should Match "simple"
            }
        }
    }

    Context "when the default color map is used" {

        Mock Write-Host {}

        In $TestDrive {

            $todoTxtFile = ".\todo.txt"
            Set-Content $todoTxtFile -Value "(A) todo1 @home +hobby"
            Add-Content $todoTxtFile -Value "(B) 2016-01-01 todo2 @office +projectA"
            Add-Content $todoTxtFile -Value "(C) todo3 @phone"
            Add-Content $todoTxtFile -Value "simple"

            It "calls Write-Host with foregroundcolor Yellow for priority A items" {
                Show-TodoTxt -File $todoTxtFile
                Assert-MockCalled Write-Host -Exactly 1 -ParameterFilter {$foregroundcolor -eq 'Yellow'} -Scope It
            }
            It "calls Write-Host with foregroundcolor Green for priority B items" {
                Show-TodoTxt -File $todoTxtFile
                Assert-MockCalled Write-Host -Exactly 1 -ParameterFilter {$foregroundcolor -eq 'Green'} -Scope It
            }
            It "calls Write-Host with foregroundcolor Cyan for priority C items" {
                Show-TodoTxt -File $todoTxtFile
                Assert-MockCalled Write-Host -Exactly 1 -ParameterFilter {$foregroundcolor -eq 'Cyan'} -Scope It
            }
            It "calls Write-Host with foregroundcolor Gray for priority Undefined items" {
                Show-TodoTxt -File $todoTxtFile
                Assert-MockCalled Write-Host -Exactly 1 -ParameterFilter {$foregroundcolor -eq 'Gray'} -Scope It
            }
        }
    }
}
