param($fileName)

if ([String]::IsNullOrEmpty($fileName))
{
    throw "Missing file name"
}

if (-not (Test-Path $fileName))
{
    throw "File not found"
}

Remove-Module  DVBChannels -ErrorAction SilentlyContinue
Import-Module ./DVBChannels -ErrorAction Stop

$channels = Import-Channels -Filename $fileName

$channels | Export-ChannelsConf -FileName "output.channels.conf"
$channels | Export-DVBChannelsConf  -FileName "output.DVBChannels.conf"
$channels | Export-VLCM3U  -FileName "output.m3u"
$channels | Export-VLCXSPF -OutputFileName "output.xspf"