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
	$Schedule = new-object -com("Schedule.Service")
    if($ServerHostname -eq '.'){
        $Schedule.connect()
    }else{
        $Schedule.Connect($ServerHostname)
    }
    $Tasks = $Schedule.getfolder("\").gettasks(0)
	
	$TaskResults = @()
	
	if($Tasks){
		$Output = Foreach ($Task IN $Tasks) {
			$XMLobj	= $([xml]$Task.xml)
			
			$TaskAuthor			= $XMLobj.Task.RegistrationInfo.Author
			$TaskDescription	= $XMLobj.Task.RegistrationInfo.Description
			if($($XMLobj.Task.RegistrationInfo.Date)){
				$TaskDateCreated	= "{0:yyyy-MM-dd HH:mm:ss}" -f [datetime]$XMLobj.Task.RegistrationInfo.Date
			}else{
				$TaskDateCreated	= "1955-11-05 00:00:00"
			}
			if($($Task.LastRunTime)){
				$TaskLastRunTime	= "{0:yyyy-MM-dd HH:mm:ss}" -f [datetime]$Task.LastRunTime
			}else{
				$TaskLastRunTime	= "1955-11-05 00:00:00"
			}
			if($($Task.NextRunTime)){
				$TaskNextRunTime	= "{0:yyyy-MM-dd HH:mm:ss}" -f [datetime]$Task.NextRunTime
			}else{
				$TaskNextRunTime	= "1955-11-05 00:00:00"
			}
			$TaskCommand		= $XMLobj.Task.Actions.Exec.Command
			$TaskArguments		= $XMLobj.Task.Actions.Exec.Arguments
			$TaskWorkingDir		= $XMLobj.Task.Actions.Exec.WorkingDirectory
			$TaskRunUser		= $XMLobj.Task.Principals.Principal.UserId
			
			$TaskResult = New-Object System.Object
			$TaskResult | Add-Member -Type NoteProperty -Name Name -Value $Task.Name
			$TaskResult | Add-Member -Type NoteProperty -Name Description -Value $TaskDescription			
			$TaskResult | Add-Member -Type NoteProperty -Name State -Value $Task.State
			$TaskResult | Add-Member -Type NoteProperty -Name LastTaskResult -Value $Task.LastTaskResult
			$TaskResult | Add-Member -Type NoteProperty -Name NumberOfMissedRuns -Value $Task.NumberOfMissedRuns
			$TaskResult | Add-Member -Type NoteProperty -Name Author -Value $TaskAuthor
			$TaskResult | Add-Member -Type NoteProperty -Name DateCreated -Value $TaskDateCreated
			$TaskResult | Add-Member -Type NoteProperty -Name LastRunTime -Value $TaskLastRunTime
			$TaskResult | Add-Member -Type NoteProperty -Name NextRunTime -Value $TaskNextRunTime
			$TaskResult | Add-Member -Type NoteProperty -Name Enabled -Value $Task.Enabled
			$TaskResult | Add-Member -Type NoteProperty -Name Command -Value $TaskCommand
			$TaskResult | Add-Member -Type NoteProperty -Name Arguments -Value $TaskArguments
			$TaskResult | Add-Member -Type NoteProperty -Name WorkingDirectory -Value $TaskWorkingDir
			$TaskResult | Add-Member -Type NoteProperty -Name RunningUser -Value $TaskRunUser
			$TaskResult
		}
	}

	# Filter out 2012 start menu cache
	$Output = $Output | Where-Object {$_.Name -notlike 'Optimize Start Menu Cache Files*'}

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

