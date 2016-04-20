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
        SendTelegram -Message "This is a Test"
