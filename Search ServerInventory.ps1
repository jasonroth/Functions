Function Get-ServerInventory {
    
    #Requires -modules PoshRSJob, ActiveDirectory
    <#
        .SYNOPSIS
            
        .DESCRIPTION 

        .PARAMETER Name
        
        .EXAMPLE
        
		.EXAMPLE
    #>

    [CmdletBinding()]
    [OutputType('pscustomobject')]
        Param (
            [Parameter(
            Position=0,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
            [string[]]
            $ComputerName = $env:COMPUTERNAME,

            [Parameter()]
            [PsCredential]
            [System.Management.Automation.CredentialAttribute()]
            $Credential
        )

    Begin {

#Define ScriptBlock for data collection

        $ScriptBlock = {

# Get OS info

            $Operating_System = Get-CimInstance -ClassName Win32_OperatingSystem

# Get system info

            $Computer_System = Get-CimInstance -ClassName Win32_ComputerSystem

# Get installed software

            $Apps64 = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' 
            $Apps32 = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
            $Apps = $Apps64+$Apps32

# Check Chef install

            if ($Apps | Where-Object DisplayName -like 'Chef Client*') {
                $Chef = 'Installed'
            }

# Check OMS install

            if ($Apps |
                Where-Object {
                ($_.DisplayName -like 'Microsoft Monitoring Agent*') -and 
                ($_.DisplayVersion -ge '7.2')}) {
                $OMS = 'Installed'
            }

# Check SCCM install

            if ($Apps | Where-Object DisplayName -like 'Configuration Manager Client*') {
                $SCCM = 'Installed'
            }

# Check SCOM install

            if ($Apps |
                Where-Object {
                ($_.DisplayName -like 'Microsoft Monitoring Agent*') -and 
                ($_.DisplayVersion -lt '7.2')}){
                $SCOM = 'Installed'
            }

# Check LANDesk install

            if ($Apps | Where-Object DisplayName -like '*LANDesk*') {
                $LANDesk = 'Installed'
            }

# Check Kaspersky install

            if ($Apps | Where-Object DisplayName -like '*Kaspersky*') {
                $Kaspersky = 'Installed'
            }

# Check SCEP install

            if ($Apps | Where-Object DisplayName -like 'System Center Endpoint Protection*') {
                $SCEP = 'Installed'
            }

# Check Trend install

            if ($Apps | Where-Object DisplayName -like 'Trend Micro Deep Security Agent*') {
                $Trend = 'Installed'
            }

# Check FireEye install

            if ($Apps | Where-Object DisplayName -like 'FireEye Endpoint Agent*') {
                $FireEye = 'Installed'
            }

# Output custom object

            [pscustomobject]@{
                Name   = $Computer_System.Name
                OS     = $Operating_System.Caption
                Domain = $Computer_System.Domain
                Model  = $Computer_System.Model
                Shell_Info = "{0}.{1}" -f $PSVersionTable.PSVersion.Major,$PSVersionTable.PSVersion.Minor
                Chef = $Chef
                OMS = $OMS
                SCCM = $SCCM
                SCOM = $SCOM
                LANDesk = $LANDesk
                Kaspersky = $Kaspersky
                SCEP = $SCEP
                Trend = $Trend
                FireEye = $FireEye
            }
        }
    }

    Process {

        foreach ($Computer in $ComputerName) {

# Test netconnection and WinRM
            
            try {
                $Connection = Test-Connection -ComputerName $Computer -Count 1 -ErrorAction Stop
                $Ping = 'Success'
            }
            catch {
                $Ping = 'Fail'    
            }

# Build Hash to be used for passing parameters to Invoke-Command commandlet

            $CommandParams = @{
                ScriptBlock = $ScriptBlock
                ErrorAction = 'Stop'
            }
        
# Add optional parameters to hash

            if (($Computer -notlike "$env:COMPUTERNAME*") -and ($Computer -notlike 'localhost')) {
                $CommandParams.Add('ComputerName', $Computer)
            }              

            if ($Credential) {
                $CommandParams.Add('Credential', $Credential)
            }
               
# Run ScriptBlock

            try {
                $ReturnedValues = Invoke-Command @CommandParams

                if (($Computer -notlike "$env:COMPUTERNAME*") -and ($Computer -notlike 'localhost')) {
                    $WinRM = 'Success'
                }
                else {
                    $WinRM = 'LocalHost'                   
                }
            }
            catch {
                $WinRM = 'Fail'
            }

# Create object for output

            [pscustomobject]@{
                Name = $Computer
                # Name_query = $ReturnedValues.Name
                OS = $ReturnedValues.OS
                PowerShell = $ReturnedValues.Shell_Info
                IPV4Address = $Connection.IPV4Address
                Domain = $ReturnedValues.Domain
                Model = $ReturnedValues.Model
                Ping = $Ping
                WinRM = $WinRM
                # RDP = $RDP
                Chef = $ReturnedValues.Chef
                OMS = $ReturnedValues.OMS
                SCCM = $ReturnedValues.SCCM
                SCOM = $ReturnedValues.SCOM
                LANDesk = $ReturnedValues.LANDesk
                Kaspersky = $ReturnedValues.Kaspersky
                SCEP = $ReturnedValues.SCEP
                Trend = $ReturnedValues.Trend
                FireEye = $ReturnedValues.FireEye
            }

# Cleanup variables

            if ($ReturnedValues) {
                Remove-Variable 'ReturnedValues'
            }
            if ($Ping) {
                Remove-Variable 'Ping'
            }
            if ($WinRM) {
                Remove-Variable 'WinRM'
            }
            if ($IPV4Address) {
                Remove-Variable 'IPV4Address'
            }
            if ($Connection) {
                Remove-Variable 'Connection'
            }
            if ($CommandParams) {
                Remove-Variable 'CommandParams'
            }
        }
    }

    End {}
}



#
### Controller script
#

$Date = (get-date).AddDays(-30)

$Domains = @(
    'domain1.global',
    'domain2.global',
    'domain3.global'
)

$Servers = foreach ($Domain in $Domains) {
    Get-ADComputer -Server $Domain -Properties OperatingSystem, LastLogonDate, PasswordLastSet -Filter {
        (enabled -eq $true) -and
        (OperatingSystem -like 'Windows Server*') -and
        ((LastLogonDate -ge $Date) -or
        (PasswordLastSet -ge $Date))
    }
}

$Servers |
Where-Object {($_.DNSHostName -ne $null) -and ($_.DNSHostName -ne '')} |

Start-RSJob -FunctionsToLoad Get-ServerInventory -ScriptBlock {
    Get-ServerInventory -ComputerName $_.DNSHostName
}

Get-RSJob  |
Wait-RSJob -ShowProgress |
Receive-RSJob |

Out-GridView -PassThru | ForEach-Object {do-thathnig -verbose}

# Export-Csv -NoTypeInformation C:\Scripts\output\ServerInventory.csv

Get-RSJob |
Remove-RSJob -Force
