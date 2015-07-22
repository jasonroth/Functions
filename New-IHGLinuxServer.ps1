Function New-IHGLinuxServer {
    <#
        .SYNOPSIS
            Add linux server to IHG active directory

        .DESCRIPTION
            Pre-provisions linux server in Centrify and AD, adds server to specified security group,
            and registers A and PTR records in DNS

        .EXAMPLE
            New-IHGLinuxServer -ComputerName TestServer2 -Domain IHGINT.global -CentrifyZone 'OU=IHGINT,OU=Zones,OU=_Centrify,OU=IHG,DC=ihgint,DC=global' -Path 'OU=tst,OU=Servers,OU=AMER,OU=IHG,DC=ihgint,DC=global' -DataCenter IADD1 -Group 'CNA_AMER_IHGINT_CR_Dev_Channel_Corp' -IPv4Address 10.210.99.220
        
        .EXAMPLE
            Import-CSV NewServers.csv | New-IHGLinuxServer
  #>

    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Low')]
    [OutputType()]
        Param (
            [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
            [ValidateNotNullOrEmpty()]
            [string]
            $ComputerName,
            
            [Parameter(Mandatory=$true,
            #ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
            [ValidateNotNullOrEmpty()]
            [string]
            $Domain,

            [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
            [ValidateNotNullOrEmpty()]
            [string]
            $CentrifyZone,

            [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
            [ValidateNotNullOrEmpty()]
            [string]
            $Path,

            [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
            [ValidateNotNullOrEmpty()]
            [string]
            $DataCenter,

            [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
            [ValidateNotNullOrEmpty()]
            [string]
            $Group,

            [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
            [ValidateNotNullOrEmpty()]
            [string]
            $IPv4Address,

            [Parameter(Mandatory=$false,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
            [ValidateNotNullOrEmpty()]
            [string]
            $NatAddress
        )

    Begin {}
    Process {
        foreach ($Name in $ComputerName) {

# Discover domain controller in target forest and site, and set as target DC
            try {
                Get-ADDomainController -Discover -DomainName $Domain -SiteName $DataCenter -Writable -OutVariable 'ADServer'
                Set-CdmPreferredServer -Domain $Domain -Server $ADServer.HostName
            }
            catch {
                Write-Verbose "Unable to connect to domain controller in $Domain"
                throw $_.Exception.Message
            }

# Confirm that computer object does not already exist
            try {
                Get-ADComputer -Server $Domain -Filter {Name -eq $Name} -ErrorAction Stop
                Write-Verbose "OU $Path does not exist in $Domain"
            }
            catch {
                throw $_.Exception.Message
            }
# Confirm that target OU does exist
            try {
                Get-ADOrganizationalUnit -Server $Domain -Identity $Path -ErrorAction Stop
                Write-Verbose "OU $Path does not exist in $Domain"
            }
            catch {
                throw $_.Exception.Message
            }
# Confirm that Centrify Zone OU does exist
            try {
                Get-ADOrganizationalUnit -Server $Domain -Identity $CentrifyZone -ErrorAction Stop
                Write-Verbose "Centrify Zone $CentrifyZone does not exist in $Domain"
            }
            catch {
                throw $_.Exception.Message
            }
            
# Add computer object to AD and provision in Centrify
            try {
                New-CdmManagedComputer -Name $Name -Zone $CentrifyZone -Container $Path
            }
            catch {
                throw $_.Exception.Message
            }
    
# Wait for computer object to be discoverable in AD or timeout after 60 seconds
            if (-Not( Get-ADComputer -Server $ADServer.HostName -Filter {Name -eq $Name})) {
                $i = 0
                do {
                    Wait-Event -Timeout 10
                    $i++
                }
                until ((Get-ADComputer -Server $ADServer.HostName -Filter {Name -eq $Name}) -or $i -eq 6)   
            }

# Add computer object to AD security group
            try {
                Add-ADGroupMember -Identity $Group -Members ($Name+'$') -Server $ADServer.HostName
            }
            catch {
                throw $_.Exception.Message
            }
    
# Add DNS Records
            try {
                 Add-DnsServerResourceRecordA -ComputerName $ADServer.HostName -CreatePtr -IPv4Address $IPv4Address -Name $Name -ZoneName $Domain
                 if ($NatAddress) {
                     Add-DnsServerResourceRecordA -ComputerName $ADServer.HostName -CreatePtr -IPv4Address $NatAddress -Name $Name+'-nat' -ZoneName $Domain
                 }
            }
            catch {
                throw $_.Exception.Message
            }
        }
    }
    End {}
}
