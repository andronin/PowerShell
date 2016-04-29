<#
    .SYNOPSIS
        Create report with Pivot table of Provisioned , UsedSpace and TotalSpace


    .AUTHOR
        Kim White
        www.kimwhite.co.za

    .Changelog
        2016-04-29
            v 1.0.0
                First commit
            
    .DESCRIPTION
        Create report for each cluster with Pivot table of Provisioned , UsedSpace and TotalSpace    

    . STATUS
        Working

    .CREDITS
        http://vniklas.djungeln.se/2012/05/08/powercli-report-on-datastores-overprovision-and-number-of-powered-on-vm%C2%B4s/ for the powercli base.

    .Requirements
        https://github.com/dfinke/ImportExcel

    .TODO
        
   
    .EXAMPLE
        
        
    #>

if ( Get-Module -ListAvailable -Name ImportExcel )
{
    foreach ( $cluster in Get-Cluster )
    {
        $ExcelFile = "C:\temp\VMWare_Datastores_$cluster.xlsx"
        rm $ExcelFile -ErrorAction Ignore
        Write-Host "Creating report for $cluster"
        Get-Cluster $cluster | Get-Datastore * | where { ( $_.name -notlike "*local*" ) -and ( $_.name -notlike "*Swap*" ) -and ( $_.name -notlike "*EVA*" ) } | Select Name,@{N="TotalSpaceGB";E={[Math]::Round(($_.ExtensionData.Summary.Capacity)/1GB,0)}},@{N="UsedSpaceGB";E={[Math]::Round(($_.ExtensionData.Summary.Capacity - $_.ExtensionData.Summary.FreeSpace)/1GB,0)}}, @{N="ProvisionedSpaceGB";E={[Math]::Round(($_.ExtensionData.Summary.Capacity -$_.ExtensionData.Summary.FreeSpace + $_.ExtensionData.Summary.Uncommitted)/1GB,0)}},@{N="NumVM";E={@($_ | Get-VM | where {$_.PowerState -eq "PoweredOn"}).Count}} | Sort Name | Export-Excel $ExcelFile -show -AutoSize -IncludePivotTable -IncludePivotChart -ChartType ColumnClustered -PivotRows Name  -PivotData @{TotalSpaceGB='sum';UsedSpaceGB='sum';ProvisionedSpaceGB='sum'} -PivotDataToColumn
    }
}
else
{ 
    Write-Host ""
    Write-Host "Please install the Import-Excel Module from https://github.com/dfinke/ImportExcel" -ForegroundColor Red
    Write-Host "You can do this by running" -ForegroundColor Red
    Write-Host "   Install-Module -Name ImportExcel" -ForegroundColor Yellow
    Write-Host "or" -ForegroundColor Red
    Write-Host "   iex (new-object System.Net.WebClient).DownloadString('https://raw.github.com/dfinke/ImportExcel/master/Install.ps1') " -ForegroundColor Yellow
    Write-Host ""
}