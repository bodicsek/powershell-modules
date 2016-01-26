$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Show-TodoTxt" {

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
