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
Get-ChildItem -Path (Join-Path $Global:PAuditRoot 'Packages') -Directory | Sort-Object -Property Name | Foreach {
	$PackageName 		= $_.Name.Split('.')[1]
	[int]$PackageNumber	= $_.Name.Split('.')[0]

    if(Test-Path (Join-Path $_.FullName "$($PackageName).xml")){
        if($RunPackage -eq 0 -or $RunPackage -eq $PackageNumber){
            Write-PAuditLog -EventID 110 -Data $PackageName
            
            # Any invalid XML files are ignored and in turn the Package is not run
            [xml]$PackageConfig = Get-Content (Join-Path $_.FullName "$($PackageName).xml") -ErrorAction SilentlyContinue

            $LeafNames = @(
                'PackageName'
                'PackageType'
                'Description'
                'DiscoverDomain'
                'DomainList'
                'ComputerList'
                'SupportsLegacy'
                'SupportsSession'
                'FullPath'
                'EnableGlobalFunctions'
                'GlobalFunctions'
                'RunOrder'
            )

            $Out						= '' | Select-Object $LeafNames
            $Out.PackageName            = [string]$PackageConfig.Configuration.PackageName
            $Out.PackageType            = [string]$PackageConfig.Configuration.PackageType
            $Out.Description      		= [string]$PackageConfig.Configuration.Description
            $Out.DiscoverDomain         = [bool][int]$PackageConfig.Configuration.ComputerSource.DiscoverDomain
            $Out.DomainList             = [bool][int]$PackageConfig.Configuration.ComputerSource.DomainList
            $Out.ComputerList           = [bool][int]$PackageConfig.Configuration.ComputerSource.ComputerList
            $Out.SupportsLegacy         = [bool][int]$PackageConfig.Configuration.SupportsLegacy
            $Out.SupportsSession        = [bool][int]$PackageConfig.Configuration.SupportsSession
            $Out.FullPath         		= [string]$_.FullName
            $Out.EnableGlobalFunctions	= [bool][int]$PackageConfig.Configuration.GlobalFunctions.Enabled
            $Out.GlobalFunctions  		= $PackageConfig.Configuration.GlobalFunctions.File
            $Out.RunOrder               = $PackageConfig.Configuration.RunOrder.RunOrder
            $Out
            
            Remove-Variable -Name PackageConfig

        }
    }

}
