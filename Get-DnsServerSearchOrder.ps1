function Get-DnsServerSearchOrder {
    <#
        .SYNOPSIS
            Veiw and report on DNS client configuration.

        .DESCRIPTION
            Find the primary and secondary DNS servers on one or more computers.

        .PARAMETER  ComputerName
            Array of computers to be queried.
    
        .EXAMPLE
            PS C:\> Get-DnsServerSearchOrder -ComputerName Server1

        .EXAMPLE
            PS C:\> "Server1",Server2" | Get-DnsServerSearchOrder
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false,
                   Position=0,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [alias('Name')]
        [string]$ComputerName = 'localhost'
    )
    begin {}
    process {
        if (Test-Connection -ComputerName $ComputerName -Count 1 -Quiet) {
            $Nics = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -ComputerName $ComputerName |
                    Where {$_.IPEnabled}
            if ($Nics) {
                foreach ($Nic in $Nics) {
                    $Settings = $Nic.DNSServerSearchOrder
                    $Properties = [ordered]@{
                    Server = $ComputerName
                    NetworkCard = $Nic.Caption
                    Address = $Nic.IPAddress[0]
                    PrimaryDns = $Settings[0]
                    SecondaryDns = $Settings[1]
                    TertiaryDns = $Settings[2]
                    QuaternaryDns = $Settings[3]
                    }
                    $Object = New-Object -TypeName PSObject -Property $Properties
                    $Object
                }
            }       
            else {
                $Properties = [ordered]@{
                Server = $ComputerName
                Error = "Unable to connect via WMI"
                }
                $Object = New-Object -TypeName PSObject -Property $Properties
                $Object
            }
        }
        else {
            $Properties = [ordered]@{
            Server = $ComputerName
            Error = "Unable to ping"
            }
            $Object = New-Object -TypeName PSObject -Property $Properties
            $Object               
        }
    }
    end {}   
}
