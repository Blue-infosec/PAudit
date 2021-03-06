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
Function Get-PAuditLogMessage {
[cmdletbinding()]
param($EventID,[string]$Data=([string]::Empty))

    Write-Verbose "Get-PAuditLogMessage 'Reading messages from $(Join-Path $Global:PAuditRoot 'Helpers\EventMessages.xml')'"
    $Result = ([xml](Get-Content (Join-Path $Global:PAuditRoot 'Helpers\EventMessages.xml'))).SelectSingleNode("/Messages/Message[EventID=$EventID]")

    if($Result.Text -eq '{{DATA}}' -and ($Data -eq [string]::Empty -or $Data -eq ""))
    {
        $Data = "$EventID - NULL Message"
        Write-Verbose "Empty"
    }

    Write-Verbose "Log message $Data"

    $Out            = '' | Select-Object EntryType, Message
    $Out.EntryType  = [System.Diagnostics.EventLogEntryType]$Result.EntryType
    $Out.Message    = $Result.Text -Replace '{{DATA}}',$Data
    $Out.Message    = $Out.Message -Replace '{{BR}}',[System.Environment]::NewLine
    $Out

}
