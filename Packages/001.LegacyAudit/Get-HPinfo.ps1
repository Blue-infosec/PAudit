<#
    This file is part of PAudit available from https://github.com/OneLogicalMyth/PAudit
    Created by Liam Glanfield @OneLogicalMyth

    PAudit is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    PAudit is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with PAudit.  If not, see <http://www.gnu.org/licenses/>.
#>
[cmdletbinding()]
Param($ServerHostname='.')


Begin{

    Function Get-HPBatteryStatus {
    Param([int]$Status)
        switch($Status){
            1 { 'OK'}
            2 { 'Failed'}
            3 { 'Not Fully Charged'}
            4 { 'Not Present'}   
        }
    }

    Function Get-HPiLOBladeInfo {
    Param($ILOIPAddress)

	    try{
		    $chassisaddress = "http://" + $ILOIPAddress + "/xmldata?item=All"
		    $enclosure = New-Object System.Xml.XmlDocument
		    $enclosure.Load($chassisaddress)

		    $Result = @{}
		    $Result.Add("EnclosureName",$enclosure.RIMP.BLADESYSTEM.MANAGER.ENCL)
		    $Result.Add("EnclosureIP",$enclosure.RIMP.BLADESYSTEM.MANAGER.MGMTIPADDR)
		    $Result.Add("BladeBay",$enclosure.RIMP.BLADESYSTEM.BAY)
		    Return $Result
	    }

	    catch {
	    }

    }

}

Process{

	$ComputerSystem = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $ServerHostname
	if($ComputerSystem.Manufacturer -eq 'HP') {
		$ArrayController = Get-WmiObject -Class HPSA_ArrayController -computername $ServerHostname -namespace root\HPQ | Select-Object CacheHasBattery,BatteryStatus
		$iLO             = Get-WmiObject -class hp_managementprocessor -computername $ServerHostname -namespace root\HPQ | Select-Object caption,ipaddress,ipv4subnetmask
		$Processor       = @(Get-WmiObject -class hp_processor -computername $ServerHostname -namespace root\HPQ | Select-Object NumberOfEnabledCores,Description)
		$BladeInfo       = Get-HPiLOBladeInfo -ILOIPAddress $iLO.ipaddress

		$HPinfo = '' | Select-Object ILOCaption,ILOIPAddress,ILOSubnetMask,EnclosureName,EnclosureIPAddress,BladeBayLocation,ProcDescription,ProcessorCount,ProcessorCores,CacheHasBattery,BatteryStatus
		$HPinfo.ILOCaption         = $iLO.caption
		$HPinfo.ILOIPAddress       = $iLO.ipaddress
		$HPinfo.ILOSubnetMask      = $iLO.ipv4subnetmask
		$HPinfo.EnclosureName      = $BladeInfo.EnclosureName
		$HPinfo.EnclosureIPAddress = $BladeInfo.EnclosureIP
		$HPinfo.BladeBayLocation   = $BladeInfo.BladeBay
		$HPinfo.ProcDescription    = $Processor[0].Description
		$HPinfo.ProcessorCount     = $Processor.Count
		$HPinfo.ProcessorCores     = $Processor[0].NumberOfEnabledCores
		$HPinfo.CacheHasBattery    = [bool][int]$ArrayController.CacheHasBattery
		$HPinfo.BatteryStatus      = $(Get-HPBatteryStatus -Status $ArrayController.BatteryStatus)
	}else{
		$HPinfo = $false
	}

	# Collect errors and return result
    $OperatingSystem = Get-WmiObject -ComputerName $ServerHostname -Class Win32_OperatingSystem
    $ComputerName    = $OperatingSystem.__Server.ToString().ToUpper()
	if($HPinfo) {
		$HPinfo = $HPinfo | Select-Object @{n='Hostname';e={$ComputerName}},*
	}else{
		$HPinfo = $null
	}
	$Result = @{
		Errors = $Error
		Result = $HPinfo
	}

	# Return result as an object
	New-Object PSObject -Property $Result

}
