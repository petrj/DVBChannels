param($fileName)


if ([String]::IsNullOrEmpty($fileName))
{
    throw "Missing file name"
}

Import-Module DVBChannels

$structure = Test-ChannelStructure -FileName $fileName
if ($structure -eq "DVBChannels.conf")
{
    Import-DVBChannelsConf -Filename $fileName | Export-ChannelsConf  
} else
{
    Import-ChannelsConf -Filename $fileName | Export-DVBChannelsConf 
}
