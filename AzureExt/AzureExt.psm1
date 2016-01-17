
<#
.Synopsis
    Creates a new Azure VM remote session.
.DESCRIPTION
    This Cmdlet makes sure that everything is set for a new Azure VM remote session.
    It connects to the VM and returns an object with all the necessary properties.
    The current Azure subscription is used.
.EXAMPLE
    $azureVmSession = New-AzureExtVMSession -ServiceName "myService" -Name "myVM"
.EXAMPLE
    $azureVmSession = New-AzureExtVMSession "myService" "myVM" -UserName "John Doe"
.INPUTS
    System.String, System.String
.OUTPUTS
    System.Management.Automation.Runspaces.PSSession
.NOTES
    General notes
.COMPONENT
    AzureExt
.ROLE
    The role this cmdlet belongs to
.FUNCTIONALITY
    The functionality that best describes this cmdlet
#>
function New-AzureExtVMSession
{
    [CmdletBinding(DefaultParameterSetName='Parameter Set 1',
                   PositionalBinding=$false,
                   HelpUri = 'http://www.microsoft.com/',
                   ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([System.Management.Automation.Runspaces.PSSession])]
    Param
    (
        # The name of the Azure service that holds the to be connected VM.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromRemainingArguments=$false,
                   Position=0,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNullOrEmpty()]
        [string]
        $ServiceName,

        # The name of the VM attached to the given service.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromRemainingArguments=$false,
                   Position=1,
                   ParameterSetName='Parameter Set 1')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        # The administrator username.
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromRemainingArguments=$false,
                   ParameterSetName='Parameter Set 1')]
        [string]
        $UserName = "Administrator"
    )

    Begin
    {
        $winRmService = Get-Service winrm
        $isUserAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
        if ($winRmService.Status.ToString() -eq "Stopped")
        {
            if ($isUserAdmin)
            {
                Start-Service $winRmService
            }
            else
            {
                throw "Unable to start the WinRM service. Please start it as Administrator."
            }
        }
    }
    Process
    {
        $vm = Get-AzureVM $ServiceName $Name
        $vmCertHash = $vm.VM.DefaultWinRmCertificateThumbprint

        $localCert = Get-ChildItem "Cert:\CurrentUser\Root" | Where-Object -Property Thumbprint -eq $vmCertHash
        if (!$localCert)
        {
            $vm.VM.WinRMCertificate | Out-File "$env:TEMP\winrm.cert"
            Import-Certificate -Filepath "$env:TEMP\winrm.cert" -CertStoreLocation 'Cert:\CurrentUser\Root'
            Remove-Item "$env:TEMP\winrm.cert"
        }

        $uri = Get-AzureWinRMUri -ServiceName $ServiceName -Name $Name
        $cred = Get-Credential -UserName $UserName -Message "Administrator credentials for VM $ServiceName/$Name"

        return New-PSSession $uri -Credential $cred
    }
    End
    {
    }
}
