Function Test-ChannelStructure
{
    Param
    (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $FileName
    )
    Process
    {       
      $lines = Get-Content -Path $FileName
      
      $firstLine = $lines[0]
      if ( ($firstLine.StartsWith("[")) -and  ($firstLine.EndsWith("]")))
      {
        return "DVBChannels.conf"
      } else
      {
        return "Channels.conf"
      }      
    }
}

Function New-Channel
{
    Param
    (
        $Name
    )
    Process
    {       
        $channel = new-object PSObject
        $channel | Add-member -membertype NoteProperty -name "Name" -value $Name

        $channel | Add-member -membertype NoteProperty -name "ServiceID" -Value $null
        $channel | Add-member -membertype NoteProperty -name "VideoPID" -Value $null
        $channel | Add-member -membertype NoteProperty -name "AudioPID" -Value $null
        $channel | Add-member -membertype NoteProperty -name "PID06" -Value $null
        $channel | Add-member -membertype NoteProperty -name "PID05" -Value $null
        $channel | Add-member -membertype NoteProperty -name "Frequency" -Value $null
        $channel | Add-member -membertype NoteProperty -name "Modulation" -Value $null
        $channel | Add-member -membertype NoteProperty -name "Bandwidth" -Value $null

        $channel | Add-member -membertype NoteProperty -name "Inversion" -Value $null
        $channel | Add-member -membertype NoteProperty -name "CodeRateHP" -Value $null
        $channel | Add-member -membertype NoteProperty -name "CodeRateLP" -Value $null
        $channel | Add-member -membertype NoteProperty -name "GuardInterval" -Value $null

        $channel | Add-member -membertype NoteProperty -name "TransmissionMode" -Value $null
        $channel | Add-member -membertype NoteProperty -name "Hierarchy" -Value $null
        $channel | Add-member -membertype NoteProperty -name "DeliverySystem" -Value $null

        $channel
    }
}

Function Export-ChannelsConf
{
    Param
    (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $Channel,

        [parameter(Mandatory = $false, ValueFromPipeline = $false)]
        $FileName
    )
    Begin
    {
        $allChannelLines = @()
    }
    Process
    {
        #Write-Host ("Exporting " + $Channel.Name)                

        $line = [String]::Empty
        $line += $Channel.Name.Replace(":","") + ":"
        $line += $Channel.Frequency + ":"
        $line += "INVERSION_AUTO:"

        $bandWidthMHZ = [System.Convert]::ToInt32($Channel.BandWidth) / 1000000

        $line += "BANDWIDTH_" + $bandWidthMHZ + "_MHZ:"

        $FEC = "FEC_" + $Channel.CodeRateHP.Replace("/","_")

        $line += $FEC + ":"

        $line += "FEC_NONE:"

        $modulation = $Channel.Modulation.Replace("/","_")
        
        $line += $modulation + ":"

        $line += "TRANSMISSION_MODE_" + $Channel.TransmissionMode + ":"
                
        $guardInterval = $Channel.GuardInterval.Replace("/","_")

        $line += "GUARD_INTERVAL_" + $guardInterval + ":"

        $line += "HIERARCHY_" + $Channel.Hierarchy + ":"

        $line += $Channel.VideoPID + ":"

        $audioPID = ""
        if (![String]::IsNullOrEmpty($Channel.AudioPID))
        {
            $audioPIDs = $Channel.AudioPID.Split(" ")
            $audioPID = $audioPIDs[0]
        }

        $line += $audioPID + ":"

        $line += $Channel.ServiceID

        $allChannelLines += $line
    }
    End
    {
        if ([String]::IsNullOrEmpty($FileName))
        {
            $allChannelLines 
        } else
        {
            $allChannelLines | Out-File -FilePath $FileName -Encoding utf8
        }
    }
}

Function Export-DVBChannelsConf
{
    Param
    (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $Channel,

        [parameter(Mandatory = $false, ValueFromPipeline = $false)]
        $FileName
    )
    Begin
    {
        $allChannelLines = @()
    }
    Process
    {
        #Write-Host ("Exporting " + $Channel.Name)                
        $allChannelLines += "[" + $Channel.Name + "]"

        $allChannelLines += "`t" + "SERVICE_ID = " + $Channel.ServiceId

        if ((![String]::IsNullOrEmpty($Channel.VideoPID)) -and ($Channel.VideoPID -ne "0"))
        {
            $allChannelLines += "`t" + "VIDEO_PID = " + $Channel.VideoPID
        }
        if ((![String]::IsNullOrEmpty($Channel.AudioPID)) -and ($Channel.AudioPID -ne "0"))
        {
            $allChannelLines += "`t" + "AUDIO_PID = " + $Channel.AudioPID
        }

        $allChannelLines += "`t" + "FREQUENCY = " + $Channel.Frequency
        $allChannelLines += "`t" + "MODULATION = " + $Channel.Modulation
        $allChannelLines += "`t" + "BANDWIDTH_HZ = " + $Channel.Bandwidth
        $allChannelLines += "`t" + "INVERSION = AUTO"
        $allChannelLines += "`t" + "CODE_RATE_HP = " + $channel.CodeRateHP
        #$allChannelLines += "`t" + "CODE_RATE_LP = "
        $allChannelLines += "`t" + "GUARD_INTERVAL = " + $channel.GuardInterval
        $allChannelLines += "`t" + "TRANSMISSION_MODE = " + $channel.TransmissionMode
        $allChannelLines += "`t" + "HIERARCHY = " + $channel.Hierarchy
        $allChannelLines += "`t" + "DELIVERY_SYSTEM = DVBT"
        


        $allChannelLines += [String]::Empty
    }
    End
    {
        if ([String]::IsNullOrEmpty($FileName))
        {
            $allChannelLines 
        } else
        {
            $allChannelLines | Out-File -FilePath $FileName -Encoding utf8
        }
    }
}

Function Import-DVBChannelsConf
{
    Param
    (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $Filename
    )
    Process
    {
        #Write-Host "Importing $Filename"

        $fileLines = Get-Content -Path $Filename

        foreach ($line in $fileLines)
        {
            if ( ($line.StartsWith("[")) -and ($line.EndsWith("]")))
            {
                $channel = New-Channel -Name $line.SubString(1,$line.Length-2)
            } elseif ([String]::IsNullOrEmpty($line))
            {
                $channel
            } else
            {
                $paramAndValue = $line.Trim().Split("=")
                $param = $paramAndValue[0].Trim()
                $value = $paramAndValue[1].Trim()

                switch ($param)
                {
                    "SERVICE_ID" { $channel.ServiceID = $value }
                    "VIDEO_PID" { $channel.VideoPID = $value }
                    "AUDIO_PID" { $channel.AudioPID = $value }
                    "PID_06" { $channel.PID06 = $value }
                    "PID_05" { $channel.PID05 = $value }
                    "FREQUENCY" { $channel.Frequency = $value }
                    "MODULATION" { $channel.Modulation = $value }
                    "BANDWIDTH_HZ" { $channel.Bandwidth = $value }
                    "INVERSION" { $channel.Inversion = $value }
                    "CODE_RATE_HP" { $channel.CodeRateHP = $value }
                    "CODE_RATE_LP" { $channel.CodeRateLP = $value }
                    "GUARD_INTERVAL" { $channel.GuardInterval = $value }
                    "TRANSMISSION_MODE" { $channel.TransmissionMode = $value }
                    "HIERARCHY" { $channel.Hierarchy = $value }
                    "DELIVERY_SYSTEM" { $channel.DeliverySystem = $value }
                }
            }
        }
    }
}

Function Import-ChannelsConf
{
    Param
    (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $Filename
    )
    Process
    {
        #Write-Host "Importing $Filename"

        $fileLines = Get-Content -Path $Filename

        foreach ($line in $fileLines)
        {
            if ([string]::IsNullOrEmpty($line))
            {
                continue
            }

            $values = $line.Split(":")

            $channel = New-Channel -Name $values[0]
            $channel.ServiceID = $values[12]
            $channel.VideoPID = $values[10]
            $channel.AudioPID = $values[11]

            $channel.PID06 = $null # ??
            $channel.PID05 = $null # ??
            $channel.Frequency = $values[1]
            $channel.Modulation = $values[6].Replace("_","/")
            
            $bandWidth = $values[3].SubString(10).Replace("_MHZ","")
            $bandWidth = [System.Convert]::ToInt32($bandWidth)*1000000
            $channel.BandWidth = $bandWidth

            $channel.Inversion = "AUTO"

            $channel.CodeRateHP = $values[4].SubString(4).Replace("_","/")

            $channel.CodeRateLP = $null

            $channel.GuardInterval = $values[8].SubString(15).Replace("_","/")

            $channel.TransmissionMode = $values[7].SubString(18)

            $channel.Hierarchy = $values[9].SubString(10)

            $channel.DeliverySystem = "DVBT"
            
            $channel
        }
    }
}

Function Import-Channels
{
    Param
    (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $Filename
    )
    Process
    {
        $structure = Test-ChannelStructure -FileName $fileName
        if ($structure -eq "DVBChannels.conf")
        {
            return Import-DVBChannelsConf -Filename $fileName
        } else
        {
            return Import-ChannelsConf -Filename $fileName
        }  
    }
}

Function Export-VLCM3U
{
    Param
    (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        $Channel,

        [parameter(Mandatory = $false, ValueFromPipeline = $false)]
        $FileName
    )
    Begin
    {
        $allChannelLines = @()
        $allChannelLines += "#EXTM3U"
    }
    Process
    {
        #Write-Host ("Exporting " + $Channel.Name)                

        $allChannelLines += "#EXTINF:0, " + $Channel.Name
        $allChannelLines += "#EXTVLCOPT:dvb-frequency=" + $Channel.Frequency
        $allChannelLines += "#EXTVLCOPT:program=" + $Channel.ServiceId
        $allChannelLines += "#EXTVLCOPT:dvb-bandwidth=" + ($Channel.Bandwidth / 1000000)
        if ($channel.DeliverySystem -eq "DVBT2")
        {
            $allChannelLines += "dvb-t2://"
        } else
        {
            $allChannelLines += "dvb-t://"
        }        
    }
    End
    {
        if ([String]::IsNullOrEmpty($FileName))
        {
            $allChannelLines 
        } else
        {
            $allChannelLines | Out-File -FilePath $FileName -Encoding utf8
        }
    }
}

Export-ModuleMember `
    Test-ChannelStructure, `
    New-Channel, `
    Export-ChannelsConf, Export-DVBChannelsConf, Export-VLCM3U, `
    Import-Channels, Import-DVBChannelsConf, Import-ChannelsConf 