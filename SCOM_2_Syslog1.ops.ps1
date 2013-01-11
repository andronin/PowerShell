<#
.SYNOPSIS  
    send2syslog

.DESCRIPTION  
	Basic SyslogSendUDP code from http://wannemacher.us/wp-content/uploads/2009/01/syslogsender.ps1 
	
	Added command line parameter passing.
	The -SysTimeStamp is optional, will be replaced with the current time in format of YYYY-MM-DD HH-MM-SS.ff
.NOTES  
    File Name      : send2syslog.ps1  
    Author         : andronin@github
    Prerequisite   : PowerShell V2 over Vista and upper.
.LINK  
    

.EXAMPLE	$logger = SyslogSenderUdp syslogserver.local
          	$logger.Send("Apr  1 14:14:41", "myhost", "Logger test message"
		OR FROM COMMAND LINE
			.\send2syslog_server.ps1 -SysLogServer 196.22.64.245 -SysHostName "196.22.64.245" -SysData "This is a test to syslog" -SysFacility "local5" -SysSeverity "5"
		or from CMD
		powershell -NoProfile -File "C:\AdminTools\Scripts\send2syslog.ps1" -SysLogServer "196.22.64.245" -SysHostName "41.181.99.166" -SysData "This is a test to syslog" -SysFacility "local5" -SysSeverity "5"
			
 Send has the following parameters
          $timestamp, $hostname, $data, $facility = "user", $severity = "info"
#>

param(
    $SysLogServer,
	$SysHostName,
	$SysData,
	$SysFacility,
	$SysSeverity
	)

Function SyslogSenderUdp
{
    param
    (
        [String]$dest_host = $(throw "Error SyslogSenderUdp: A destination host must be given.")
    )
    
    $SSU = New-Object PSObject
    $SSU | Add-Member -MemberType NoteProperty -Name _UdpClient -Value $null
    $SSU | Add-Member -MemberType ScriptMethod -Name init -Value {
        param
        (
            [String]$dest_host = $(throw "Error SyslogSenderUdp:init; A destination host must be given."),
            [Int32]$dest_port = 514
        )
        $this._UdpClient = New-Object System.Net.Sockets.UdpClient
        $this._UdpClient.Connect($dest_host, $dest_port)
    }
    
    $SSU | Add-Member -MemberType ScriptMethod -Name Send -Value {
        param
        (
            [String]$timestamp = $(throw "Error SyslogSenderUdp:init; Timestamp must be given."),
            [String]$hostname = $(throw "Error SyslogSenderUdp:init; Hostname must be given."),
            [String]$data = $(throw "Error SyslogSenderUdp:init; Log data must be given."),
            [String]$facility = "user",
            [String]$severity = "info"
        )
        $facility_map = @{  "kern" = 0;
                            "user" = 1;
                            "mail" = 2;
                            "daemon" = 3;
                            "security" = 4;
                            "auth" = 4;
                            "syslog" = 5;
                            "lpr" = 6;
                            "news" = 7;
                            "uucp" = 8;
                            "cron" = 9;
                            "authpriv" = 10;
                            "ftp" = 11;
                            "ntp" = 12;
                            #"logaudit" = 13;
                            #"logalert" = 14;
                            "clock" = 15;
                            "local0" = 16;
                            "local1" = 17;
                            "local2" = 18;
                            "local3" = 19;
                            "local4" = 20;
                            "local5" = 21;
                            "local6" = 21;
                            "local7" = 23;
                        }
    
        $severity_map = @{  "emerg" = 0;
                            "panic" = 0;
                            "alert" = 1;
                            "crit" = 2;
                            "error" = 3;
                            "err" = 3;
                            "warning" = 4;
                            "warn" = 4;
                            "notice" = 5;
                            "info" = 6;
                            "debug" = 7;
                            }

        # Map the text to the decimal value
        if ($facility_map.ContainsKey($facility))
        {
            $facility_num = $facility_map[$facility]
        }
        else
        {
            $facility_num = $facility_map["user"]
        }
        
        if ($severity_map.ContainsKey($severity))
        {
            $severity_num = $severity_map[$severity]
        }
        else
        {
            $severity_num = $severity_map["user"]
        }
        
        # Calculate the PRI code
        $pri = ($facility_num * 8) + $severity_num
        
        # Get a properly formatted, encoded, and length limited data string
        $message = "<{0}>{1} {2} {3}" -f $pri, $timestamp, $hostname, $data
        Write-Host $message
        $enc     = [System.Text.Encoding]::ASCII
        $message = $Enc.GetBytes($message)
            
        if ($message.Length -gt 1024)
        {
            $message = $message.SubString(0, 1024)
        }
        
        # Fire away
        $this._UdpClient.Send($message, $message.Length)
    }
    
    $SSU.init($dest_host)
    
    # Emit the newly built object
    $SSU
}

#validate input parameters
if ($SysTimeStamp -eq $null)
	{$sysTimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.ff"}
if (	$SysHostName -eq $null)
	{}
#if ($SysHostName -eq "Microsoft.SystemCenter.AgentWatchersGroup")
#    {$SysHostName = "cpt-scom01"}
if (	$SysData -eq $null)
	{}
if (	$SysFacility -eq $null)
	{}
if (	$SysSeverity -eq $null)
	{}
    
#Map Severity to *nix format
if (	$SysSeverity -eq 0)
	{$SysSeverity = "info"}
if (	$SysSeverity -eq 1)
	{$SysSeverity = "warning"}
if (	$SysSeverity -eq 2)
	{$SysSeverity = "emergency"}

$SysTimeStamp = Get-Date -Format "MMMM dd HH:mm:ss"

#$date = ( get-date ).ToString('yyyyMMdd')
#$file = New-Item -type file "$date-syslog1.txt"
# echo "$systimestamp	:	$SysHostName	:	$SysData	:	$SysFacility	:	$SysSeverity" >> $file


#Setup SysLog Server address
$logger = SyslogSenderUdp $SysLogServer
$logger.send("$SysTimeStamp", "$SysHostName", "$SysData", "local5", "$SysSeverity")