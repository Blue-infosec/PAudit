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



# Enumerate local domain computers
# First check we are on a domain, the package wants domain enumeration and globally its enabled to!
$DomainMember = (Get-WmiObject -Class Win32_ComputerSystem).DomainRole -ge 3
if(($DomainMember -eq $true) -AND ($Package.DiscoverDomain -eq $true) -AND ($Global:Config.DiscoverDomain -eq $true)){

    $LocalDomainComputers = Get-ADComputers

}

# Now enumerate remote domain comptuers
if(($Package.DiscoverDomain -eq $true) -AND ($Global:Config.DomainList -eq $true)){

    $Domains = Get-Content (Join-Path $Global:PAuditRoot 'Lists\Domain.xml')
    $RemoteDomainComputers = foreach($Domain IN ([XML]$Domains).Domains.Domain){
            
            $SecurePassword = $Domain.Password
            $BSTR           = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
            $Password       = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
            
            Get-ADComputers -DomainName $Domain.DomainName -Username $Domain.Username -Password $Password

    }

}

# Now read the list of computers and process them
if(($Package.ComputerList -eq $true) -AND ($Global:Config.UseComputerList -eq $true)){

    $Computers = Get-Content (Join-Path $Global:PAuditRoot 'Lists\Computer.xml')
    $ListComputers = foreach($Computer IN ([XML]$Computers).Computers.Computer){
            
            $SecurePassword = $Computer.Password
            $BSTR           = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
            $Password       = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
            
            Get-ADComputers -DomainName $Computer.HostName -Username $Computer.Username -Password $Password

    }

}


$LocalDomainComputers
$RemoteDomainComputers
$ListComputers
