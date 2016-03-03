$WorkdnsSuffix = "work.dns.suffix"
$HomednsSuffix = "home.dns.suffix"

#Change git working folder depending on dnsSuffix defined above
if ( (Get-DnsClient).ConnectionSpecificSuffix -contains $dnsSuffix )
{
    Set-Location C:\Data\gitwork
    $gitwork = Get-Location
}
elseif ( (Get-DnsClient).ConnectionSpecificSuffix -contains $dnsSuffix )
{
    Set-Location D:\Data\Gitwork
    $gitwork = Get-Location
}
else
{
    set-Location C:\Data\GitWork
    $gitwork = Get-Location
}

$scompath = "C:\Program Files\Microsoft System Center 2012 R2\Operations Manager\Powershell"
$UCSPSpath = "C:\Program Files (x86)\Cisco\Cisco UCS PowerTool\Modules\CiscoUcsPS"
$env:PSModulePath = $env:PSModulePath + ";$scompath" <#+ ";$powerclipath"#>
$ProfilePath = $env:USERPROFILE

function Get-ExternalIP {
(Invoke-WebRequest ifconfig.me/ip).Content
}

function Get-ExternalIP {
(Invoke-WebRequest ifconfig.me/ip).Content
}

function Get-IP { Get-NetAdapter | Get-NetIPAddress | Where-Object { $_.addressfamily -eq "IPv4" } | select InterfaceAlias,IPAddress | sort InterfaceAlias }

### Import Modules I use
Import-Module C:\Data\gitwork\sysadmin-general\windows\powershell\Modules\Pushbullet.psm1
Import-Module "C:\Program Files (x86)\Cisco\Cisco UCS PowerTool\Modules\CiscoUcsPS\CiscoUcsPS.psd1"
#Import-Module "C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts"
#. "C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
# Load posh-git example profile
. $ProfilePath'\OneDrive\Documents\WindowsPowerShell\Modules\posh-git\profile.example.ps1'

###All My Alias are belong to me
Set-Alias -Name gh -Value Get-Help -Option AllScope
Set-Alias -Name ipcalc -Value $gitwork\windows-scripts\ipcalc.ps1
Set-Alias -Name elevateme -Value $gitwork\windows-scripts\elevateme.ps1

### Show some useful information
Get-Module | select Name,Path | Format-Table -AutoSize
Get-IP
