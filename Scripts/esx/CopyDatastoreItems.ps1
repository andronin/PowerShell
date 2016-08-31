<#
.Synopsis
   Copy files from a VMware Datastore to another location
.AUTHOR
    Kim White (kim.white@taos.za.net)
.VERSION
    1.0
.DESCRIPTION
    .Server             vSphere Server FQDN or IP 
    .DatastoreNames     Comma seperated list of Datastore's
    .DatastorePath      If you want to copy a specific folder in the DataStore
    .DestinationPath    The destination you want to copy to
    .Username           User with the permissions to access the datastore
.EXAMPLE
   CopyDatastoreItems.ps1 -Server vsphere01.fqdn -DatastoreNames DataStore-01 -DatastorePath FolderInDataStore -DestinationPath \\ThePlace\ToStore\YourFiles -Username AdminUser
.EXAMPLE
   CopyDatastoreItems.ps1 -Server vsphere01.fqdn -DatastoreNames DataStore-01,DataStore-02,DataStore-04 -DestinationPath \\ThePlace\ToStore\YourFiles -Username AdminUser
#>

param (
    [Parameter(Mandatory = $true)]
        [string]$Server,
        [string]$Username,
    [Parameter(Mandatory = $true)]
        [string[]]$DatastoreNames,
    [Parameter(Mandatory = $true)]
        [string[]]$DatastorePath="*",
    [Parameter(Mandatory = $true)]
        [string[]]$DestinationPath
)

Import-Module VMware.VimAutomation.Core
if ( $global:DefaultVIServer -eq $null ) { Connect-Viserver -Server $Server -Protocol https -Port 443 -User $Username }

foreach ( $DatastoreName in $DatastoreNames )
{
    Get-Datastore $DatastoreName | New-PSDrive -Name temp -PSProvider VimDatastore -Root "\"
    IF ( Test-Path $DestinationPath$DatastoreName )
    {
        Copy-DatastoreItem -Item temp:\$DatastorePath\* -Destination $DestinationPath\$DatastoreName -Recurse -Verbose -Force
    }
    ELSE
    {
        New-Item $DestinationPath\$DatastoreName -ItemType Directory -Verbose
        Copy-DatastoreItem temp:\$DatastorePath\* -Destination $DestinationPath\$DatastoreName -Recurse -Verbose -Force
    }
    Remove-PSDrive temp
}
Get-PSDrive | where { $_.Provider -eq "*VimDatastore*" }
Disconnect-VIServer -Server $Server -confirm:$false