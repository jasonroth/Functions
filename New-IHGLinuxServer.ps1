Function New-IHGLinuxServer {
    <#
        .SYNOPSIS
            Add linux server to IHG active directory

        .DESCRIPTION
            Pre-provisions linux server in Centrify and AD, adds server to specified security group, and registers A and PTR records in DNS

        .EXAMPLE
            New-IHGLinuxServer -ComputerName TestServer2 -Domain IHGINT.global -CentrifyZone 'OU=IHGINT,OU=Zones,OU=_Centrify,OU=IHG,DC=ihgint,DC=global' -Path 'OU=tst,OU=Servers,OU=AMER,OU=IHG,DC=ihgint,DC=global' -DataCenter IADD1 -Group 'CNA_AMER_IHGINT_CR_Dev_Channel_Corp' -IPv4Address 10.210.99.220
        
		.EXAMPLE
            Import-CSV NewServers.csv | New-IHGLinuxServer
  #>

    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Low')]
    [OutputType()]
        Param (
            [Parameter(Mandatory=$true,
            Position=0,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
			[ValidateNotNullOrEmpty()]
			[Alias('Name')]
            [string]
            $ComputerName,
            
            [Parameter(Mandatory=$true,
            Position=1,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
			[ValidateNotNullOrEmpty()]
			[Alias('Forest')]
            [string]
            $Domain,

            [Parameter(Mandatory=$true,
            Position=2,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
			[ValidateNotNullOrEmpty()]
			[Alias('Zone')]
            [string]
            $CentrifyZone,

            [Parameter(Mandatory=$true,
            Position=3,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
			[ValidateNotNullOrEmpty()]
			[Alias('OU')]
            [string]
            $Path,

            [Parameter(Mandatory=$true,
            Position=4,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
			[ValidateNotNullOrEmpty()]
			[string]
            $DataCenter,

            [Parameter(Mandatory=$true,
            Position=5,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
			[ValidateNotNullOrEmpty()]
			[Alias('SecGroup')]
            [string]
            $Group,

            [Parameter(Mandatory=$true,
            Position=6,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
			[ValidateNotNullOrEmpty()]
			[Alias('IP')]
            [string]
            $IPv4Address
        )

    Begin {

#Discover domain controller in target forest and site
        try {
            Get-ADDomainController -Discover -DomainName $Domain -SiteName $DataCenter -Writable -OutVariable 'ADServer' -ErrorAction Stop
            Set-CdmPreferredServer -Domain $Domain -Server $ADServer.HostName -ErrorAction Stop
        }
        catch {
            throw $_.Exception.Message
        }
    }
    Process {

#Add computer object to AD and provision in Centrify
        try {
            New-CdmManagedComputer -Name $ComputerName -Zone $CentrifyZone -Container $Path
        }
        catch {
            throw $_.Exception.Message
        }
    
#Wait for computer object to be discoverable in AD or timeout after 60 seconds
        if (-Not( Get-ADComputer -Server $ADServer.HostName -Filter {Name -eq $ComputerName})) {
            $i = 0
            do {
                Wait-Event -Timeout 10
                $i++
            }
            until ((Get-ADComputer -Server $ADServer.HostName -Filter {Name -eq $ComputerName}) -or $i -eq 6)   
        }

#Add computer object to AD security group
        try {
            Add-ADGroupMember -Identity $Group -Members ($ComputerName+'$') -Server $ADServer.HostName -ErrorAction Stop
        }
        catch {
            throw $_.Exception.Message
        }
    
#Add DNS Record
        try {
             Add-DnsServerResourceRecordA -ComputerName $ADServer.HostName -CreatePtr -IPv4Address $IPv4Address -Name $ComputerName -ZoneName $Domain
        }
        catch {
        
        }
	}
    End {}
}
