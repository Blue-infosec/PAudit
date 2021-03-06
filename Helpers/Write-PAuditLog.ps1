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
Function Write-PAuditLog {
Param([int]$EventID,[string]$Data=([string]::Empty))
 
    # Create the event log in case it does not exist
    New-PAuditLog

	# Get event message
	$EventDetails	= Get-PAuditLogMessage -EventID $EventID -Data $Data
	$Message		= $EventDetails.Message
	$EntryType		= $EventDetails.EntryType

    # Write event to log
    Write-EventLog -LogName PAudit -Source 'PAudit' -EntryType $EntryType -EventId $EventID -Message $Message

    # Output to host
    $DateFormat = 'yyyy-MM-dd HH:mm:ss'
    $LogMessage = "$(Get-Date -Format $DateFormat) - $EntryType - $EventID - $Message"

	$Colours = switch ($EntryType) 
    { 
        'Error' { $Host.PrivateData.ErrorForegroundColor,$Host.PrivateData.ErrorBackgroundColor } 
        'Warning' { $Host.PrivateData.WarningForegroundColor,$Host.PrivateData.WarningBackgroundColor } 
        'Information' { 'White', 'DarkMagenta'} 
        default { 'White', 'DarkMagenta' }
    }
	if($LogMessage.Length -gt 0)
	{
		# Replace any new lines
		$LogMessage = $LogMessage.replace([System.Environment]::NewLine,' ')

		# Build log path
		$LogPathDir = Join-Path $Global:PAuditRoot Logs
		$LogPathFil = Join-Path $LogPathDir $Global:Config.LogFileName

		# Check if outputing to file and do so
		if($Global:Config.UseLogFile)
		{
			if(-not (Test-Path $LogPathDir))
			{
                New-Item $LogPathDir -ItemType Directory -Force
				Write-PAuditLog -EventID 1 -Data "PAudit log directory created at '$LogPathDir'"
			}
			$LogMessage | Out-File -FilePath $LogPathFil -Append -Encoding ascii
		}

		# Trim to fit on console window
		if($LogMessage.Length -gt $host.ui.rawui.WindowSize.Width)
		{
			$LogMessage = "$($LogMessage.Substring(0,$host.ui.rawui.WindowSize.Width - 3))..."
		}

	}

    # Output result
    Write-Host $LogMessage -ForegroundColor $Colours[0] -BackgroundColor $Colours[1]
    
}
