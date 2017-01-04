<#
    .SYNOPSIS
        Set of functions to Telegram messaging functions


    .AUTHOR
        Kim White
        www.kimwhite.co.za

    .Changelog
        2016-04-01
            v 1.0.0
                Sends Telegram messages using the bot api
                Requires a csv file called TelegramBots.txt in the format
                    BOTNAME,BOTID,APIKEY,ChatID

            v 1.0.1
                Bot options in cli
                    -BotID
                    -APIKey
                    -ChatID
                Parsemode option to select https://core.telegram.org/bots/api#markdown-style
                    markdown
                    html
            
    .DESCRIPTION
        Sends Telegram messages using the bot api
            Requires a csv file called TelegramBots.txt in the format
                BOTNAME,BOTID,APIKEY,ChatID
            The module will iterate though all bots listed and send a message using each
        Modify the $TG_BotsPath to where you put the TelegramBots.txt file
        There are command line options to specify bot information instead of using the botfile. If you do not using a BotID it will attempt to use the defined botfile.
    

    . STATUS
        Working

    .CREDITS
        

    .TODO
        
   
    .EXAMPLE
        Send-Telegram -Message " Sent <b>without options</b> " -parse_mode html
        Send-Telegram -Message " Sent *with bot* options " -botid 12345678 -APIKEY "ThisIsMyBotAPIKey" -ChatID ReplaceWithChatID -parse_mode markdown
        
    #>

function Send-Telegram
{
    param
    (
        [Parameter(
            Mandatory=$true
        )]
        [string]$Message=$(throw "TelegramMessage is Mandatory"),
        [Parameter(
            Mandatory=$false
        )]
        [ValidateSet("markdown","html")]
        [string]$parse_mode="markdown",
        [Parameter(
            Mandatory=$false
        )]
        [string]$BotID="",
        [Parameter(
            Mandatory=$false
        )]
        [string]$APIKEY,
        [Parameter(
            Mandatory=$false
        )]
        [string]$ChatID,
        [Parameter(
            Mandatory=$false
        )]
        [string]$ProxyServer
    )
    Write-Host " Using CLI Options" -ForegroundColor Red
    $TelegramURL = "https://api.telegram.org/bot${BotID}:${APIKey}/SendMessage"
    $Body = @{
        chat_id = "$ChatID"
        parse_mode = "$parse_mode"
        text = "$Message"
        }
    $JSONtoSend = ConvertTo-Json -InputObject $body

    Try
    {
        if ( $ProxyServer ) { Invoke-RestMethod -Method Post -TimeoutSec 3 -Uri $TelegramURL -Body (ConvertTo-Json -InputObject $body) -ContentType "application/json; charset=utf-8" -Proxy $proxyserver }
        else { Invoke-RestMethod -Method Post -TimeoutSec 3 -Uri $TelegramURL -Body (ConvertTo-Json -InputObject $body) -ContentType "application/json; charset=utf-8" }
    }
    Catch # [System.Management.Automation.ActionPreferenceStopException]
    {
        Write-Host -ForegroundColor Red "Unable to send message"
        Write-Host -ForegroundColor Cyan -NoNewline "Chat ID : "
        Write-Host -ForegroundColor Yellow $ChatID
        Write-Host -ForegroundColor Cyan -NoNewline "BOT ID  : "
        Write-Host -ForegroundColor Yellow $BotID
        Write-Host -ForegroundColor Cyan -NoNewline "API Key : "
        Write-Host -ForegroundColor Yellow $APIKEY
        Write-Host -ForegroundColor Cyan -NoNewline "Message : "
        Write-Host -ForegroundColor Yellow $Message
        break
    }

}