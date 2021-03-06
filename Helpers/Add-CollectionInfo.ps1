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
Function Add-CollectionInfo {
	<#
	.SYNOPSIS
		Appends the collection details to the end of the object.

	.DESCRIPTION
		Appends the collection details to the end of the object.

	.PARAMETER InputObject
		The object you wish to have the collection details appended to.

	.EXAMPLE
		Get-Process | Add-CollectionInfo

	.NOTES
		Liam Glanfield - 01/06/2016 - v1.0 - First function build

	#>
	[CmdletBinding()]
	param(
		# Parameter help description
		[Parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[psobject]
		$InputObject
	)
	
	process{
		$Sys = Get-WmiObject -Class Win32_ComputerSystem
		$LocalComputer = 'SampleComputer.WORKGROUP' # $Sys.DNSHostName + '.' + $Sys.Domain
		$Username = 'SampleUser' #Join-Path $env:USERDOMAIN $env:USERNAME
		$InputObject | Select-Object *, @{n='CollectedByUser';e={$Username}}, @{n='CollectedByComputer';e={$LocalComputer}},@{n='CollectedOn';e={Get-Date}}	
	}
	
}
