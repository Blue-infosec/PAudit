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
#
# Create_OutputFolder.ps1
#


Function New-RecursivePath {
Param([string]$RootPath,[switch]$Compress,[switch]$ReturnPaths)

    #Get each path until the root drive
    $NewPath = $RootPath.TrimEnd('\')
    [int]$LeafCount = $NewPath.split('\').count
    $Array = 1..$LeafCount | foreach{
        if($NewPath)
        {
            $NewPath = Split-Path $NewPath -ErrorAction SilentlyContinue
            $NewPath
        }
    }
    $Paths = $Array | Where-Object { $_ -ne '' }
    $Paths = $Paths[$($LeafCount-1)..0]
    $Paths += $RootPath

    #Just return paths if switch is used
    if($ReturnPaths){
        Return $Paths
    }
    
    #Check each leaf and make sure it exists if not then create it
    try
    {
        Foreach($Path IN $Paths){
            if(-not (Test-Path $Path)){
                New-Item -Path $Path -ItemType Directory -ErrorAction Stop | Out-Null
            }
        }

		if($Compress)
		{
			Get-CimInstance -Class Win32_Directory -Filter "Name='$($RootPath.Replace('\','\\'))'" | Invoke-CimMethod -MethodName Compress | Out-Null
		}
    }
    catch
    {
        Write-Warning "Could not create '$Path' - $_"
    }

}



