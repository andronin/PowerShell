<#
    .SYNOPSIS
        Telegram bot poster

    .AUTHOR
        Kim White
        www.kimwhite.co.za

    .Changelog
        2016-04-20
            v 1.0.0
            
            
    .DESCRIPTION
        Sends Telegram messages using the bot api
            Requires a csv file called TelegramBots.txt in the format
                BOTNAME,BOTID,APIKEY,ChatID
            The module will iterate though all bots listed and send a message using each
        Modify the $TG_BotsPath to where you put the TelegramBots.txt file

    . STATUS
        Working

    .CREDITS
        

    .TODO
        Allow cmd line options for Bots variables as well
   
    .EXAMPLE
        
    #>

function SendTelegram
{
    param ([string]$TelegramMessage=$(throw "TelegramMessage is Mandatory"))
    foreach ( $TG_Bot in $TG_Bots )
    {
        $TG_BotID = $TG_Bot.BOTID
        $TG_APIKey = $TG_Bot.APIKEY
        $TG_ChatID = $TG_Bot.ChatID
        $TelegramURL = "https://api.telegram.org/bot${TG_BotID}:${TG_APIKey}/SendMessage"
        $Body = @{
            chat_id = "$TG_ChatID"
            text = "$TelegramMessage"
        }
    }          
    $JSONtoSend = ConvertTo-Json -InputObject $body
    Invoke-RestMethod -Method Post -TimeoutSec 3 -Uri $TelegramURL -Body (($JSONtoSend)) -ContentType "application/json; charset=utf-8" -Proxy $proxyserver
}
$TG_BotsPath = "Path\To\Bots\File"
$TG_BotsFile = "$TG_BotsPath\TelegramBots.txt"
$TG_Bots = Import-Csv $TG_BotsFile