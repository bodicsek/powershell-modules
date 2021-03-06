Param (
    [parameter(Mandatory=$false,
               Position=0)]
    [string]
    $File
)

if (Get-Module TodoTxt) {
    return
}

Push-Location $psScriptRoot
. .\Item.ps1
. .\Render.ps1
Pop-Location

Export-ModuleMember -Function @(
    'New-TodoTxtItem',
    'Remove-TodoTxtItem',
    'Complete-TodoTxtItem',
    'Show-TodoTxt'
)
Export-ModuleMember -Alias @(
    'nt',
    'rt',
    'ct',
    't'
)
Export-ModuleMember -Variable @(
    'File'
)
