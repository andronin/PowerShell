[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory=$true)]
    [string[]]$vCenters,
    [Parameter(Mandatory=$true)]
    [string[]]$ReportPath,
    [Parameter(Mandatory=$true)]
    [ValidateSet("RoundRobin","MostRecentlyUsed")]
    [string]$MultiPathPolicy
)
$vCenterCount = 0
$vCenters | ForEach-Object {
    $vcenter = $_
    $vCenterCount ++
    Write-Progress -Id 1 -Activity "Working on $($global:DefaultVIServer)" -Status "$vCenterCount of $($vcenters.Count)" 
    if ( $global:DefaultVIServer ) {
        Disconnect-VIServer  $global:DefaultVIServer -Confirm:$false
    }
    $vcenter = Connect-VIServer -Server $vcenter -Credential $credentials
    Write-Progress -Id 2 -ParentId 1 -Activity "Collecting LUNs that are not set to $MultiPathPolicy"
    $NotRR = Get-VMHost | where { $_.ConnectionState -eq "Connected" } | Get-ScsiLun -LunType disk | Where {$_.MultipathPolicy -notlike "$MultiPathPolicy"}
    $RR = @()
    $NOTRRCount = 0
    $NOTRR | ForEach-Object {
        $LUN = $_
        $NOTRRCount ++
        Write-Progress -Id 2 -ParentId 1 -Activity "Setting $($LUN.CanonicalName) to a multipath policy of $MultiPathPolicy" -Status "$NOTRRCount of $($NOTRR.count)" -PercentComplete (( $NOTRRCount / $NOTRR.count)*100)
        $RR += $LUN | Set-Scsilun -MultiPathPolicy $MultiPathPolicy
    }
    if ($ReportPath) {
        $RR | select CanonicalName,HostId,CapacityGB,MultipathPolicy | Export-Excel "$($ReportPath)_$(Get-date -Format yyyy-MM-dd).xlsx" -WorkSheetname $global:DefaultVIServer
    }
    Disconnect-VIServer  $global:DefaultVIServer -Confirm:$false
}
