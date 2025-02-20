<#
.Synopsis
    Sends Telegram sticker message via Bot API from locally sourced sticker image
.DESCRIPTION
    Uses Telegram Bot API to send sticker message to specified Telegram chat. The sticker will be sourced from the local device and uploaded to telegram.
.EXAMPLE
    $botToken = 'nnnnnnnnn:xxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $chat = '-nnnnnnnnn'
    $sticker = 'C:\stickers\sticker.webp'
    Send-TelegramLocalSticker -BotToken $botToken -ChatID $chat -StickerPath $sticker

    Sends sticker message via Telegram API
.EXAMPLE
    $botToken = 'nnnnnnnnn:xxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxx'
    $chat = '-nnnnnnnnn'
    $sticker = 'C:\stickers\sticker.webp'
    $sendTelegramLocalStickerSplat = @{
        BotToken            = $botToken
        ChatID              = $chat
        StickerPath         = $sticker
        DisableNotification = $true
        ProtectContent      = $true
        Verbose             = $true
    }
    Send-TelegramLocalSticker @sendTelegramLocalStickerSplat

    Sends sticker message via Telegram API
.PARAMETER BotToken
    Use this token to access the HTTP API
.PARAMETER ChatID
    Unique identifier for the target chat
.PARAMETER StickerPath
    File path to the sticker you wish to send
.PARAMETER DisableNotification
    Send the message silently. Users will receive a notification with no sound.
.PARAMETER ProtectContent
    Protects the contents of the sent message from forwarding and saving
.OUTPUTS
    System.Management.Automation.PSCustomObject
.NOTES
    Author: Jake Morrison - @jakemorrison - https://www.techthoughts.info/

    The following sticker types are supported:
    WEBP, TGS

    How do I get my channel ID? Use the getidsbot https://telegram.me/getidsbot  -or-  Use the Telegram web client and copy the channel ID in the address
    How do I set up a bot and get a token? Use the BotFather https://t.me/BotFather
.COMPONENT
    PoshGram - https://github.com/techthoughts2/PoshGram
.FUNCTIONALITY
    Parameters              Type                    Required    Description
    chat_id                 Integer or String       Yes         Unique identifier for the target chat or username of the target channel (in the format @channelusername)
    sticker                 InputFile or String     Yes         Sticker to send.
    disable_notification    Boolean                 Optional    Sends the message silently. Users will receive a notification with no sound.
.LINK
    https://github.com/techthoughts2/PoshGram/blob/main/docs/Send-TelegramLocalSticker.md
.LINK
    https://core.telegram.org/bots/api#sendsticker
.LINK
    https://core.telegram.org/bots/api
#>
function Send-TelegramLocalSticker {
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
            HelpMessage = 'File path to the sticker you wish to send')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$StickerPath,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Send the message silently')]
        [switch]$DisableNotification,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Protects the contents of the sent message from forwarding and saving')]
        [switch]$ProtectContent
    )

    Write-Verbose -Message ('Starting: {0}' -f $MyInvocation.Mycommand)

    Write-Verbose -Message 'Verifying presence of sticker...'
    if (-not(Test-Path -Path $StickerPath)) {
        throw ('The specified sticker path: {0} was not found.' -f $AnimationPath)
    } #if_testPath
    else {
        Write-Verbose -Message 'Path verified.'
    } #else_testPath

    Write-Verbose -Message 'Verifying extension type...'
    $fileTypeEval = Test-FileExtension -FilePath $StickerPath -Type Sticker
    if ($fileTypeEval -eq $false) {
        throw 'File extension is not a supported Sticker type'
    } #if_stickerExtension
    else {
        Write-Verbose -Message 'Extension supported.'
    } #else_stickerExtension

    Write-Verbose -Message 'Verifying file size...'
    $fileSizeEval = Test-FileSize -Path $StickerPath
    if ($fileSizeEval -eq $false) {
        throw 'File size does not meet Telegram requirements'
    } #if_stickerSize
    else {
        Write-Verbose -Message 'File size verified.'
    } #else_stickerSize

    Write-Verbose -Message 'Getting sticker file...'
    try {
        $fileObject = Get-Item $StickerPath -ErrorAction Stop
    } #try_Get-ItemSticker
    catch {
        Write-Warning -Message 'The specified sticker could not be interpreted properly.'
        throw $_
    } #catch_Get-ItemSticker

    $form = @{
        chat_id              = $ChatID
        sticker              = $fileObject
        disable_notification = $DisableNotification.IsPresent
        protect_content      = $ProtectContent.IsPresent
    } #form

    $uri = 'https://api.telegram.org/bot{0}/sendSticker' -f $BotToken
    Write-Debug -Message ('Base URI: {0}' -f $uri)

    Write-Verbose -Message 'Sending sticker...'
    $invokeRestMethodSplat = @{
        Uri         = $uri
        ErrorAction = 'Stop'
        Form        = $form
        Method      = 'Post'
    }
    try {
        $results = Invoke-RestMethod @invokeRestMethodSplat
    } #try_messageSend
    catch {
        Write-Warning -Message 'An error was encountered sending the Telegram sticker message:'
        Write-Error $_
        if ($_.ErrorDetails) {
            $results = $_.ErrorDetails | ConvertFrom-Json -ErrorAction SilentlyContinue
        }
        else {
            throw $_
        }
    } #catch_messageSend

    return $results
} #function_Send-TelegramLocalSticker
