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

process{

	$NetworkInfo	= Get-WMIObject -ComputerName $ServerHostname -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled='true'" | `
					Select macaddress, WINSPrimaryServer, WINSSecondaryServer, `
					@{n='DNSServers';e={[string]$_.dnsserversearchorder}}, @{n='IPAddress';e={[string]$_.IPAddress}}, `
					@{n='DefaultIPGateway';e={[string]$_.DefaultIPGateway}}, @{n='IPSubnet';e={[string]$_.IPSubnet}}, DHCP

	#Cycle through network cards (only IP enabled cards)
	$Output = foreach ($objNetwork in $NetworkInfo){
        $NetworkInfo = New-Object Object
        $NetworkInfo | Add-Member -MemberType NoteProperty -Name AdapterName -Value $objNetwork.description
        $NetworkInfo | Add-Member -MemberType NoteProperty -Name IP -Value $objNetwork.IPAddress
        $NetworkInfo | Add-Member -MemberType NoteProperty -Name MAC -Value $objNetwork.macaddress
        $NetworkInfo | Add-Member -MemberType NoteProperty -Name DNS -Value $objNetwork.DNSServers
        $NetworkInfo | Add-Member -MemberType NoteProperty -Name Gateway -Value $objNetwork.DefaultIPGateway
        $NetworkInfo | Add-Member -MemberType NoteProperty -Name Subnet -Value $objNetwork.ipsubnet
        $NetworkInfo | Add-Member -MemberType NoteProperty -Name DHCP -Value $objNetwork.dhcpenabled
        $NetworkInfo | Add-Member -MemberType NoteProperty -Name DHCPServer -Value $objNetwork.dhcpserver
        $NetworkInfo
	}

	# Collect errors and return result
    $OperatingSystem = Get-WmiObject -ComputerName $ServerHostname -Class Win32_OperatingSystem
    $ComputerName    = $OperatingSystem.__Server.ToString().ToUpper()
	if($Output) {
		$Output = $Output | Select-Object @{n='Hostname';e={$ComputerName}},*
	}else{
		$Output = $null
	}
	$Result = @{
		Errors = $Error
		Result = $Output
	}

	# Return result as an object
	New-Object PSObject -Property $Result

}
