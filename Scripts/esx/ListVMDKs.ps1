<#
    .SYNOPSIS
        List all VMDK's in a Datastore with size


    .AUTHOR
        Kim White
        www.kimwhite.co.za

    .Changelog
        2016-05-04
            v 1.0.0
                First commit
            
    .DESCRIPTION
        List all VMDK's in a Datastore with size

    . STATUS
        Working

    .CREDITS
        

    .Requirements
        None

    .TODO        
   
    .EXAMPLE
        Connect to Server ESXHost.fqdn.or.IP with username OptionalUsername and list files using the Filefilter of * in the list of Datastores Comma,Seperated,List,of,DataStores. Size metric will display in MB
            .\ListVMDKs.ps1 -Server ESXHost.fqdn.or.IP -User OptionalUsername -Datastores Comma,Seperated,List,of,DataStores -FileFilter * -Unit MB
        Connect to Server ESXHost.fqdn.or.IP with username OptionalUsername and list files using the Filefilter of * in A list generated from a wildcard. Size metric will display in MB
            .\ListVMDKs.ps1 -Server ESXHost.fqdn.or.IP -User OptionalUsername -Datastores *STORENAME* -FileFilter * -Unit MB
        
    #>

param (
    [Parameter(Mandatory = $true)]
        [string]$Server,
    [Parameter(Mandatory = $false)]
        [string]$Username,
    [Parameter(Mandatory = $true)]
        [string[]]$DataStores,
    [Parameter(Mandatory = $true)]
        [string]$FileFilter,
    [Parameter(Mandatory = $true)]
    [ValidateSet('KB','MB','GB','TB')]
        [string]$Unit = 'KB'
    )
Import-Module VMware.VimAutomation.Core
$ESXConnected = $global:DefaultVIServer # | ForEach-Object {$_.Name}
if ( $ESXConnected -eq $null ) { Connect-Viserver -Server $Server -Protocol https -Port 443 -User $Username }
Write-Host "Connected to $global:DefaultVIServer" -ForegroundColor Cyan
$Disks = @()
Write-Host '------------------'
foreach ( $DataStore in (Get-Datastore $DataStores | ForEach-Object { $_.Name }) )
{

    Write-Host "Working on " $DataStore
    $datastore = Get-Datastore $datastore | New-PSDrive -Name $DataStore -PSProvider VimDatastore -Root "\"
    $Disks += Get-ChildItem -recurse ${DataStore}:\* | where {$_.name -like $FileFilter }
    Remove-PSDrive $DataStore
}
Write-Host '------------------'
$Disks | select Datastore,Name,LastWriteTime,@{Name="${Unit}ytes";Expression={[math]::Round((($_.Length / "1$Unit")))}} | sort Datastore,Length | ft -AutoSize
foreach ( $disk in $Disks )
{
    if ($disk.Datastore -ne $null) { $total += $disk.Length }
}
Write-Host "Total Size of files's with filter " $FileFilter " = " ([math]::Round(($total / "1$Unit") , 2,"AwayFromZero")) " $Unit"
($total / "1$Unit")
[math]::Round(($total / "1$Unit"), 2,"AwayFromZero")
if ( $ESXConnected -eq $null ) { Disconnect-VIServer -Server $Server -Confirm:$false }
Write-Host '------------------'
