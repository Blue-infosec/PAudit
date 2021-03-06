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
if(($DomainMember -eq $true) -AND ($Global:Config.DiscoverDomain -eq $true)){

    Get-ADComputers | foreach
    {
        $Out = '' | Select ComputerName, IP, Username, Password
        $Out.ComputerName = $_.DNSHostName
        $Out
    } 

}

# Now enumerate remote domain comptuers
if(($Global:Config.DomainList -eq $true)){

    $Domains = Get-Content (Join-Path $Global:PAuditRoot 'Lists\Domain.xml')
    foreach($Domain IN ([XML]$Domains).Domains.Domain){
            
            $SecurePassword = ConvertTo-SecureString $Domain.Password
            $BSTR           = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
            $Password       = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

            try {
                $DomainIP = (Resolve-DnsName -Name $Domain.DomainName -Server $Domain.DNSServer -Type A | Select-Object -First 1).IPAddress
                Get-ADComputers -DomainName $DomainIP -Username $Domain.Username -Password $Password | foreach{
                    $Out = '' | Select ComputerName, IP, Username, Password
                    $Out.ComputerName = $_.DNSHostName
                    $Out.IP = (Resolve-DnsName -Name $_.DNSHostName -Server $Domain.DNSServer -Type A | Select-Object -First 1).IPAddress
                    $Out.Username = $Domain.Username
                    $Out.Password = $Password
                    $Out
                } 
            }
            catch [System.Exception] {
                Write-Error $_
            }

    }

}

# Now read the list of computers and process them
if(($Global:Config.UseComputerList -eq $true)){

    $Computers = Get-Content (Join-Path $Global:PAuditRoot 'Lists\Computer.xml')
    $ListComputers = foreach($Computer IN ([XML]$Computers).Computers.Computer){

            Write-Verbose "Reading $($Computer.HostName) from Computer.xml"
            
            if($Computer.Username -ne ""){
                $SecurePassword = ConvertTo-SecureString $Computer.Password
                $BSTR           = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
                $Password       = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
            }else{
                $Password       = $null
            }
            
            $Out = '' | Select ComputerName, IP, Username, Password
            $Out.ComputerName = $Computer.HostName
            $Out.IP = $Computer.IP
            $Out.Username = $Computer.Username
            $Out.Password = $Password
            $Out
    }

    Return $ListComputers

}