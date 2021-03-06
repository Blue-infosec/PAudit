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
# NAME:         Get-PhysicalMemory.ps1
# AUTHOR:       Liam Glanfield
# CREATED DATE: 18/11/2015
# CHANGED DATE: 18/11/2015
# VERSION:      1.0.0
# DESCRIPTION:  Collects physical memory information from WMI

# Error handling
$ErrorActionPreference = 'SilentlyContinue'
$Errors = @()
$Error.Clear()

#region Start collecting data

$MemoryType = @(
	'Unknown'
	'Other'
	'DRAM'
	'Synchronous DRAM'
	'Cache DRAM'
	'EDO'
	'EDRAM'
	'VRAM'
	'SRAM'
	'RAM'
	'ROM'
	'Flash'
	'EEPROM'
	'FEPROM'
	'EPROM'
	'CDRAM'
	'3DRAM'
	'SDRAM'
	'SGRAM'
	'RDRAM'
	'DDR'
	'DDR2'
	'DDR2'
	'DDR2 FB-DIMM'
	'DDR3'
	'FBD2'
)

$FormFactor = @(
	'Unknown'
	'Other'
	'SIP'
	'DIP'
	'ZIP'
	'SOJ'
	'Proprietary'
	'SIMM'
	'DIMM'
	'TSOP'
	'PGA'
	'RIMM'
	'SODIMM'
	'SRIMM'
	'SMD'
	'SSMP'
	'QFP'
	'TQFP'
	'SOIC'
	'LCC'
	'PLCC'
	'BGA'
	'FPBGA'
	'LGA'
)

$Output = Get-WmiObject -Class Win32_PhysicalMemory | Select-Object @(
	'BankLabel',
	@{n='CapacityGB';e={$_.Capacity / 1GB}},
	'DeviceLocator',
	@{n='FormFactor';e={$FormFactor[$_.FormFactor]}},
	'HotSwappable',
	'Manufacturer',
	@{n='MemoryType';e={$MemoryType[$_.MemoryType]}},
	'PartNumber',
	'SerialNumber',
	'Speed',
	'TypeDetail'
)

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

