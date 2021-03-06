function Set-DnsServerSearchOrder
{
	<#
		.SYNOPSIS
			Modify DNS client configuration.

		.DESCRIPTION
			Set the primary and secondary DNS servers on one or more computers.

		.PARAMETER  ComputerName
			Array of computers to be modified.

		.PARAMETER  PrimaryDNS
			DNS server to be set as Primary.

		.PARAMETER  SecondaryDNS
			DNS server to be set as Secondary.
			
		.EXAMPLE
			PS C:\> Set-DnsServerSearchOrder -ComputerName Server1 -PrimaryDns DNSServer1 -SecondaryDns DNSServer2

		.EXAMPLE
			PS C:\> "Server1",Server2" | Set-DnsServerSearchOrder -PrimaryDns DNSServer1 -SecondaryDns DNSServer2


		.NOTES
			If no secondary DNS server is specified, the existing secondary will be retained.

            Name: Set-DnsServerSearchOrder.ps1   
            Author: Jason Roth   
            DateCreated: 3.26.2014
			
	#>
	[CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Low')]
	param(
		[Parameter(Mandatory=$false,
		ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
		[alias('Name')]
		[array]$ComputerName = 'localhost',
		
		[Parameter(Mandatory=$true,
		ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
		[ValidateNotNullOrEmpty()]
		[string]$PrimaryDns,

		[Parameter(Mandatory=$false,
		ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
		[string]$SecondaryDns,
		
		[Parameter(Mandatory=$false,
		ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
		[string]$TertiaryDns,

		[Parameter(Mandatory=$false,
		ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
		[string]$QuaternaryDns
		)
	
	begin
	{
		$Output = @()
	}
	
	process
	{
		foreach ($Computer in $ComputerName)
		{
			if (Test-Connection -ComputerName $Computer -Count 1 -Quiet)
			{
				$Nics = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -ComputerName $Computer  | Where {$_.IPEnabled}
				if ($Nics)
				{
					foreach ($Nic in $Nics)
					{
						$Previous = $Nic.DNSServerSearchOrder
						
						if (($QuaternaryDns) -and ($TertiaryDns) -and $($SecondaryDns))
						{$Set = $NIC.SetDNSServerSearchOrder($($PrimaryDns,$SecondaryDns,$TertiaryDns,$QuaternaryDns))}
						
						elseif (($TertiaryDns) -and $($SecondaryDns))
						{$Set = $NIC.SetDNSServerSearchOrder($($PrimaryDns,$SecondaryDns,$TertiaryDns))}
						
						elseif ($SecondaryDns)
						{$Set = $NIC.SetDNSServerSearchOrder($($PrimaryDns,$SecondaryDns))}
						
						else
						{
							if ($Previous[3] -and $Previous[2] -and $Previous[1])
							{
								$QuaternaryDns = $Previous[3]
								$TertiaryDns = $Previous[2]
								$SecondaryDns = $Previous[1]
								$Set = $Nic.SetDNSServerSearchOrder($($PrimaryDns,$SecondaryDns,$TertiaryDns,$QuaternaryDns))
							}
							
							elseif ($Previous[2] -and $Previous[1])
							{
								$TertiaryDns = $Previous[2]
								$SecondaryDns = $Previous[1]
								$Set = $Nic.SetDNSServerSearchOrder($($PrimaryDns,$SecondaryDns,$TertiaryDns))
							}
							
							elseif ($Previous[1])
							{
								$SecondaryDns = $Previous[1]
								$Set = $Nic.SetDNSServerSearchOrder($($PrimaryDns,$SecondaryDns))
							}
							
							else
							{$Set = $Nic.SetDNSServerSearchOrder($PrimaryDns)}
						}
						
						if ($Set.ReturnValue -eq 0)
						{	
							
							$Properties = [ordered] @{
							Server = $Computer
							NetworkCard = $Nic.Caption
							Address = $Nic.IPAddress[0]
							PreviousPrimaryDns = $Previous[0]
							PreviousSecondaryDns = $Previous[1]
							PreviousTertiaryDns = $Previous[2]
							PreviousQuaternaryDns = $Previous[3]
							NewPrimaryDns = $PrimaryDns
							NewSecondaryDns = $SecondaryDns
							NewTertiaryDns = $TertiaryDns
							NewQuaternaryDns = $QuaternaryDns}
							$Object = New-Object -TypeName PSObject -Property $Properties
							$Output +=$Object
						}		
						else 
						{
							$Properties = [ordered] @{
							Server = $Computer
							Error = "Failed to Set DNS Settings"}
							$Object = New-Object -TypeName PSObject -Property $Properties
							$Output +=$Object						
						}
					}
				}		
				else
				{
					$Properties = [ordered] @{
					Server = $Computer
					Error = "Unable to connect to Server via WMI"}
					$Object = New-Object -TypeName PSObject -Property $Properties
					$Output +=$Object
				}
			}
			else
			{
				$Properties = [ordered] @{
				Server = $Computer
				Error = "Unable to ping Server"}
				$Object = New-Object -TypeName PSObject -Property $Properties
				$Output +=$Object				
			}
		}
	}
	end
	{
		$Output
	}	
}