<#
    .AUTHOR
        Kim White
        www.kimwhite.co.za

    .Changelog
        2016-04-28 v1
            First Stable version
    .DESCRIPTION
        Checks uptime of a set of servers acquired from Active Directory
        Requires that RDS runs on port 3389 to test the connection.
   
    .EXAMPLE
        ServerUptimes.ps1
            Will check uptime of all servers in the domain
        ServerUptimes.ps1 -computers *OPS
            Will check uptime of all servers with the term OPS contained in the Hostname
        ServerUptimes.ps1 -computers OPS
            Will check uptime of all servers with the term OPS at the start of the Hostname

    .Attribution
        Thanks to Serge Nikalaichyk whose post in the comments at https://4sysops.com/archives/calculating-system-uptime-with-powershell/ helped with the core, I just did some prettifying
#>


param ([string]$Computers)
#get-adcomputer -Filter "name -like '$computers*'" | select DNSHostName
$uptime = @()
foreach ( $computer in (get-adcomputer -Filter "name -like '$computers*'" | select DNSHostName | ForEach-Object {$_.DNSHostName } )) 
{ 
    if (Test-NetConnection -ComputerName $computer -Port 3389 ) 
    { 
    $uptime += (Get-WmiObject -Class Win32_PerfFormattedData_PerfOS_System -ComputerName $computer -ErrorAction SilentlyContinue -WarningAction SilentlyContinue) | Select-Object @{ Name="Computer";expression = {$computer}},@{Name = “SystemUpTime”; Expression = {New-TimeSpan -Seconds $_.SystemUpTime}}
    }
}
$uptime | Format-Table -AutoSize
