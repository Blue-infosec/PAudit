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
# NAME:         Get-NetworkAdapters.ps1
# AUTHOR:       Liam Glanfield
# CREATED DATE: 18/11/2015
# CHANGED DATE: 18/11/2015
# VERSION:      1.0.0
# DESCRIPTION:  Collects network adapters information from WMI

# Error handling
$ErrorActionPreference = 'SilentlyContinue'
$Errors = @()
$Error.Clear()

#region Start collecting data

function ConvertFrom-WMIDate {
	Param($WMIDate)
	([WMI]'').ConvertToDateTime($WMIDate)
}

$Output = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True' | Select-Object @(
	'Description',
	'macaddress',
	'WINSPrimaryServer',
	'WINSSecondaryServer',
	@{ n = 'DNSServers'; e = { $_.dnsserversearchorder -join ';' } },
	@{ n = 'IPAddress'; e = { $_.IPAddress -join ';' } },
	@{ n = 'DefaultIPGateway'; e = { $_.DefaultIPGateway -join ';' } },
	@{ n = 'IPSubnet'; e = { $_.IPSubnet -join ';' } },
	'DHCPEnabled',
	'DHCPLeaseExpires',
	'DHCPLeaseObtained',
	'DHCPServer',
	@{ n = 'GUID'; e = { $_.SettingID.Trim('{}') } }
) | ForEach-Object {
				
	if ($_.DHCPEnabled)
	{
		$DHCPLeaseExpires = (ConvertFrom-WMIDate $_.DHCPLeaseExpires)
		$DHCPLeaseObtained = (ConvertFrom-WMIDate $_.DHCPLeaseObtained)
	}
	else
	{
		$DHCPLeaseExpires = $Null
		$DHCPLeaseObtained = $Null
	}
				
	$NetworkAdapter = Get-WmiObject -Class win32_networkadapter -Filter "Description = '$($_.Description)'"
				
	if ($NetworkAdapter)
	{
					
		$NetworkDriver = Get-WmiObject -Class Win32_pnpsigneddriver -filter "deviceclass = 'net' AND devicename = '$($_.Description)'"
					
		$NetConnectionID = $NetworkAdapter.NetConnectionID
		$PhysicalAdapter = $NetworkAdapter.PhysicalAdapter
		$AdapterTypeId = $NetworkAdapter.AdapterTypeId
		$Availability = $NetworkAdapter.Availability
		$TimeOfLastReset = (ConvertFrom-WMIDate $NetworkAdapter.TimeOfLastReset)
					
		if ($NetworkDriver)
		{
			$DriverDate = ConvertFrom-WMIDate ($NetworkDriver.DriverDate)
			$IsSigned = $NetworkDriver.IsSigned
			$DriverVersion = $NetworkDriver.DriverVersion
			$DriverProviderName = $NetworkDriver.DriverProviderName
		}
		else
		{
			$IsSigned = $null
			$DriverVersion = $null
			$DriverProviderName = $null
		}
					
	}
	else
	{
		$NetConnectionID = $null
		$PhysicalAdapter = $null
		$AdapterTypeId = $null
		$Availability = $null
		$TimeOfLastReset = $null
		$IsSigned = $null
		$DriverVersion = $null
		$DriverProviderName = $null
	}
				
	$Result = @{
		'Name' = $NetConnectionID
		'Description' = $_.Description.Trim()
		'MACAddress' = $_.MacAddress
		'WINSPrimaryServer' = $_.WINSPrimaryServer
		'WINSSecondaryServer' = $_.WINSSecondaryServer
		'DNSServers' = $_.DNSServers
		'IPAddress' = $_.IPAddress
		'DefaultIPGateway' = $_.DefaultIPGateway
		'IPSubnet' = $_.IPSubnet
		'DHCPEnabled' = $_.DHCPEnabled
		'DHCPLeaseExpires' = $DHCPLeaseExpires
		'DHCPLeaseObtained' = $DHCPLeaseObtained
		'DHCPServer' = $_.DHCPServer
		'GUID' = $_.GUID
		'IsPhysicalAdapter' = $PhysicalAdapter
		'AdapterType' = $AdapterTypeId
		'Availability' = $Availability
		'TimeOfLastReset' = $TimeOfLastReset
		'DriverSigned' = $IsSigned
		'DriverVersion' = $DriverVersion
		'DriverProviderName' = $DriverProviderName
		'DriverDate' = $DriverDate
	}

	#Output the result
	New-Object -TypeName PSObject -Property $Result
}


#endregion

# Collect errors and return result
$System        = Get-WmiObject Win32_ComputerSystem
$LocalComputer = $System.DNSHostName + '.' + $System.Domain
if($Output) {
	$Output = $Output | Select-Object @{n='ComputerName';e={$LocalComputer}},*
}else{
	$Output = $null
}
$Result = @{
	Errors = $Error
	Result = $Output
}

# Return result as an object
New-Object PSObject -Property $Result
