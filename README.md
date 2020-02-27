# DVBChannels
Powershell module for linux DVB channels file formats conversion

Example 1
- converting dvb_channel.conf to channels.conf

```powershell
Import-Module DVBChannels

Import-DVBChannelsConf -Filename "./dvb_channel.conf" | Export-ChannelsConf
```

Input (dvb_channel.conf format):
```
[Prima COOL]
	SERVICE_ID = 770
	NETWORK_ID = 8395
	TRANSPORT_ID = 518
	VIDEO_PID = 501
	AUDIO_PID = 511
	PID_0c = 8000
	PID_05 = 531
	FREQUENCY = 634000000
	MODULATION = QAM/64
	BANDWIDTH_HZ = 8000000
	INVERSION = AUTO
	CODE_RATE_HP = 2/3
	CODE_RATE_LP = 1/2
	GUARD_INTERVAL = 1/4
	TRANSMISSION_MODE = 8K
	HIERARCHY = NONE
	DELIVERY_SYSTEM = DVBT

[ABC TV]
	SERVICE_ID = 6922
	NETWORK_ID = 8395
	TRANSPORT_ID = 3841
	VIDEO_PID = 2701
	AUDIO_PID = 2702
	FREQUENCY = 730000000
	MODULATION = QAM/64
	BANDWIDTH_HZ = 8000000
	INVERSION = AUTO
	CODE_RATE_HP = 5/6
	CODE_RATE_LP = 1/2
	GUARD_INTERVAL = 1/16
	TRANSMISSION_MODE = 8K
	HIERARCHY = NONE
	DELIVERY_SYSTEM = DVBT


```

Output (channels.conf format):
```
Prima COOL:634000000:INVERSION_AUTO:BANDWIDTH_8_MHZ:FEC_2_3:FEC_NONE:QAM_64:TRANSMISSION_MODE_8K:GUARD_INTERVAL_1_4:HIERARCHY_NONE:501:511:770
ABC TV:730000000:INVERSION_AUTO:BANDWIDTH_8_MHZ:FEC_5_6:FEC_NONE:QAM_64:TRANSMISSION_MODE_8K:GUARD_INTERVAL_1_16:HIERARCHY_NONE:2701:2702:6922
```

Example 2:
- converting channels.conf to dvb_channel.conf

```powershell
Import-Module DVBChannels

Import-ChannelsConf -Filename "./channels.conf" | Export-DVBChannelsConf 
```

Example 3:
- exporting channels.conf or dvb_channel.conf to vlc playlist:

```powershell
Import-Module DVBChannels

Import-Channels -Filename "./dvb_channel.conf" | Export-VLCM3U
Import-Channels -Filename "./chanels.conf" | Export-VLCM3U
```

Output (m3u for VLC format):
```
#EXTM3U
#EXTINF:0, Prima COOL
#EXTVLCOPT:dvb-frequency=634000000
#EXTVLCOPT:program=770
#EXTVLCOPT:dvb-bandwidth=8
dvb-t://
#EXTINF:0, ABC TV
#EXTVLCOPT:dvb-frequency=730000000
#EXTVLCOPT:program=6922
#EXTVLCOPT:dvb-bandwidth=8
dvb-t://
```
