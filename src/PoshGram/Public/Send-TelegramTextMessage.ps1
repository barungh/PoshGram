<#
.Synopsis
    Sends Telegram text message via Bot API
.DESCRIPTION
    Uses Telegram Bot API to send text message to specified Telegram chat. Several options can be specified to adjust message parameters.
.EXAMPLE
    $botToken = 'nnnnnnnnn:xxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $chat = '-nnnnnnnnn'
    Send-TelegramTextMessage -BotToken $botToken -ChatID $chat -Message "Hello"

    Sends text message via Telegram API
.EXAMPLE
    $botToken = 'nnnnnnnnn:xxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $chat = '-nnnnnnnnn'
    $message = 'This is how to use:
    <b>bold</b>,
    <i>italic</i>,
    <u>underline</u>,
    <s>strikethrough</s>,
    <tg-spoiler>spoiler</tg-spoiler>,
    <a href="http://www.example.com/">inline URL</a>,
    <code>inline fixed-width code</code>,
    <pre>pre-formatted fixed-width code block</pre>,
    with default HTML formatting.'
    $sendTelegramTextMessageSplat = @{
        BotToken = $botToken
        ChatID   = $chat
        Message  = $message
    }
    Send-TelegramTextMessage @sendTelegramTextMessageSplat

    Sends text message via Telegram API with properly formatted default HTML syntax.
.EXAMPLE
    $botToken = 'nnnnnnnnn:xxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $chat = '-nnnnnnnnn'
    $message = 'This is how to use:
    *bold*,
    _italic_,
    __underline__,
    ~strikethrough~,
    ||spoiler||,
    [inline URL](http://www.example.com/),
    `inline fixed-width code`,
    with MarkdownV2 style formatting'
    $sendTelegramTextMessageSplat = @{
        BotToken  = $botToken
        ChatID    = $chat
        Message   = $message
        ParseMode = 'MarkdownV2'
    }
    Send-TelegramTextMessage @sendTelegramTextMessageSplat

    Sends text message via Telegram API with properly formatted MarkdownV2 syntax.
.EXAMPLE
    $sendTelegramTextMessageSplat = @{
        BotToken  = $botToken
        ChatID    = $chat
        ParseMode = 'MarkdownV2'
        Message   = 'This is how to escape an __underscore__ in a message: \_'
    }
    Send-TelegramTextMessage @sendTelegramTextMessageSplat

    Sends text message via Telegram API using MarkdownV2 with an underlined word and a properly escaped character.
.EXAMPLE
    $sendTelegramTextMessageSplat = @{
        BotToken  = $botToken
        ChatID    = $chat
        ParseMode = 'MarkdownV2'
        Message   = "`u{1F192} Sending emojis is cool\! `u{1F49B}"
    }
    Send-TelegramTextMessage @sendTelegramTextMessageSplat

    Sends text message via Telegram API with two properly escaped special character (!) and emojis.
.EXAMPLE
    $inlineRow1 = @(
    @{
        text = "`u{1F517} Visit"
        url  = 'https://www.techthoughts.info'
    }
    )
    $inlineRow2 = @(
        @{
            text = "`u{1F4CC} Pin"
            url  = 'https://www.techthoughts.info/learn-powershell-series/'
        }
    )
    $inlineKeyboard = @{
        inline_keyboard = @(
            $inlineRow1,
            $inlineRow2
        )
    }
    $sendTelegramTextMessageSplat = @{
        BotToken  = $botToken
        ChatID    = $chat
        Message   = 'Sending an example of inline keyboard'
        Keyboard  = $inlineKeyboard
    }
    Send-TelegramTextMessage @sendTelegramTextMessageSplat

    Sends text message with an inline keyboard right next to the message it belongs to.
    See https://core.telegram.org/bots/api#inlinekeyboardbutton for additional details for forming inline keyboards.
.EXAMPLE
    $row1 = @(
        @{
            text = "`u{1F513} Unlock"
        }
    )
    $row2 = @(
        @{
            text = "`u{1F512} Lock"
        }
    )
    $customKeyboard = @{
        keyboard          = @(
            $row1,
            $row2
        )
        one_time_keyboard = $true
    }
    $sendTelegramTextMessageSplat = @{
        BotToken  = $botToken
        ChatID    = $chat
        Message   = 'Sending an example of a custom keyboard'
        Keyboard  = $customKeyboard
    }
    Send-TelegramTextMessage @sendTelegramTextMessageSplat

    Sends text message with a custom keyboard.
    See https://core.telegram.org/bots/api#replykeyboardmarkup for additional details for forming custom keyboards.
.EXAMPLE
    $sendTelegramTextMessageSplat = @{
        BotToken        = $botToken
        ChatID          = $chat
        Message         = 'Sending a protected content message'
        ProtectContent  = $true
    }
    Send-TelegramTextMessage @sendTelegramTextMessageSplat

    Sends text message via Telegram API with protected content.
.PARAMETER BotToken
    Use this token to access the HTTP API
.PARAMETER ChatID
    Unique identifier for the target chat
.PARAMETER Message
    Text of the message to be sent
.PARAMETER ParseMode
    Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in your bot's message. Default is HTML.
.PARAMETER Keyboard
    Custom or inline keyboard object
.PARAMETER DisablePreview
    Disables link previews for links in this message.
.PARAMETER DisableNotification
    Send the message silently. Users will receive a notification with no sound.
.PARAMETER ProtectContent
    Protects the contents of the sent message from forwarding and saving
.OUTPUTS
    System.Management.Automation.PSCustomObject
.NOTES
    Author: Jake Morrison - @jakemorrison - https://www.techthoughts.info/

    How do I get my channel ID? Use the getidsbot https://telegram.me/getidsbot  -or-  Use the Telegram web client and copy the channel ID in the address
    How do I set up a bot and get a token? Use the BotFather https://t.me/BotFather

    Markdown Style: This is a legacy mode, retained for backward compatibility.
    When using Markdown/Markdownv2 you must properly escape characters.
    Certain characters in Telegram must be escaped with the preceding character '\' - see examples.
.COMPONENT
    PoshGram - https://github.com/techthoughts2/PoshGram
.FUNCTIONALITY
    Parameters                  Type                Required    Description
    chat_id                     Integer or String   Yes         Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    text                        String              Yes         Text of the message to be sent, 1-4096 characters after entities parsing
    parse_mode                  String              Optional    Send Markdown or HTML, if you want Telegram apps to show bold, italic, fixed-width text or inline URLs in your bot's message.
    disable_web_page_preview    Boolean             Optional    Disables link previews for links in this message
    disable_notification        Boolean             Optional    Sends the message silently. Users will receive a notification with no sound.
    reply_to_message_id         Integer             Optional    If the message is a reply, ID of the original message
    reply_markup                KeyboardMarkup      Optional    Additional interface options. A JSON-serialized object for an inline keyboard, custom reply keyboard, instructions to remove reply keyboard or to force a reply from the user.
.LINK
    https://github.com/techthoughts2/PoshGram/blob/main/docs/Send-TelegramTextMessage.md
.LINK
    https://core.telegram.org/bots/api#sendmessage
.LINK
    https://core.telegram.org/bots/api#html-style
.LINK
    https://core.telegram.org/bots/api#markdownv2-style
.LINK
    https://core.telegram.org/bots/api#markdown-style
.LINK
    https://core.telegram.org/bots/api
#>
function Send-TelegramTextMessage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            HelpMessage = '#########:xxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxx')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$BotToken, #you could set a token right here if you wanted

        [Parameter(Mandatory = $true,
            HelpMessage = '-#########')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$ChatID, #you could set a Chat ID right here if you wanted

        [Parameter(Mandatory = $true,
            HelpMessage = 'Text of the message to be sent')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory = $false,
            HelpMessage = 'HTML vs Markdown for message formatting')]
        [ValidateSet('Markdown', 'MarkdownV2', 'HTML')]
        [string]$ParseMode = 'HTML', #set to HTML by default

        [Parameter(Mandatory = $false,
            HelpMessage = 'Custom or inline keyboard object')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [psobject]$Keyboard,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Disables link previews')]
        [switch]$DisablePreview, #set to false by default

        [Parameter(Mandatory = $false,
            HelpMessage = 'Send the message silently')]
        [switch]$DisableNotification,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Protects the contents of the sent message from forwarding and saving')]
        [switch]$ProtectContent
    )

    Write-Verbose -Message ('Starting: {0}' -f $MyInvocation.Mycommand)

    $payload = @{
        chat_id                  = $ChatID
        text                     = $Message
        parse_mode               = $ParseMode
        disable_web_page_preview = $DisablePreview.IsPresent
        disable_notification     = $DisableNotification.IsPresent
        protect_content          = $ProtectContent.IsPresent
    } #payload

    if ($Keyboard) {
        $payload.Add('reply_markup', $Keyboard)
    }

    $uri = 'https://api.telegram.org/bot{0}/sendMessage' -f $BotToken
    Write-Debug -Message ('Base URI: {0}' -f $uri)

    Write-Verbose -Message 'Sending message...'
    $invokeRestMethodSplat = @{
        Uri         = $uri
        Body        = ([System.Text.Encoding]::UTF8.GetBytes((ConvertTo-Json -Compress -InputObject $payload -Depth 50)))
        ErrorAction = 'Stop'
        ContentType = 'application/json'
        Method      = 'Post'
    }
    try {
        $results = Invoke-RestMethod @invokeRestMethodSplat
    } #try_messageSend
    catch {
        Write-Warning -Message 'An error was encountered sending the Telegram message:'
        Write-Error $_
        if ($_.ErrorDetails) {
            $results = $_.ErrorDetails | ConvertFrom-Json -ErrorAction SilentlyContinue
        }
        else {
            throw $_
        }
    } #catch_messageSend

    return $results
} #function_Send-TelegramTextMessage
