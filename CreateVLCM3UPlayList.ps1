param($fileName)


if ([String]::IsNullOrEmpty($fileName))
{
    throw "Missing file name"
}

Import-Module DVBChannels

$channels = Import-Channels -Filename $fileName

$channels | Export-VLCM3U