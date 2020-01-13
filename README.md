# DVBChannels
Powershell module for linux DVB channels file formats conversion

Example 1
- converting dvb_channel.conf to chanels.conf

```powershell
Import-Module DVBChannels

Import-DVBChannelsConf -Filename "./dvb_channel.conf" | Export-ChannelsConf
```

Example 2:
- converting chanels.conf to dvb_channel.conf

```powershell
Import-Module DVBChannels

Import-ChannelsConf -Filename "./channels.conf" | Export-DVBChannelsConf 
```

Example 3:
- exporting chanels.conf or dvb_channel.conf to vlc playlist:

```powershell
Import-Module DVBChannels

Import-Channels -Filename "./dvb_channel.conf" | Export-VLCM3U
Import-Channels -Filename "./chanels.conf" | Export-VLCM3U
```