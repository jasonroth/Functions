Function Install-IHGSCOMAgent {
    <#
        .SYNOPSIS
            Install SCOM agent on remote servers.

        .DESCRIPTION
            Initiates remote PSSession on specified servers, downloads SCOM agent and installs agent,
            and configures correct Management group and Management server. 

        .PARAMETER Name
            $ComputerName
        
        .EXAMPLE
            Install-SCOMAgent -ComputerName server1.ihg.global
        
		.EXAMPLE
            Get-ADComputer -Server ihg.global -Filter {OperatingSystem -like 'Windows Server*'}.DNSHostName | Install-SCOMAgent -Verbose
  #>

    [CmdletBinding()]
    [OutputType()]
        Param (
            [Parameter(Mandatory=$true,
            Position=0,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
			[ValidateNotNullOrEmpty()]
			[alias('DNSHostName')]
            [string[]]
            $ComputerName
        )

    Begin {
        # Configure required variables

        $url = 'http://scomagent.ihgint.global/Agent'
        $LocalPath = "$env:SystemDrive\Install"
        $LogPath = "$env:SystemDrive\logs\MOMAgent_Install"
        $LogFile = (Get-Date -Format yyyy_MM_dd)+"_MomAgent_Install.log"
        $ManagementGroup = 'IHG-SCOM2012R2-PRD1'
        $IHG_ManagemantServer = 'iadd1pwom2ap001.ihg.global'
        $IHGINT_ManagemantServer = 'iadd1pwom1ap001.ihgint.global'
        $IHGEXT_ManagemantServer = 'iadd1pwom2ap002.ihgext.global'
        $CORP_ManagemantServer = 'iadd1pwom2ap003.corp.local'
        $MomAgent = 'MOMAgent.msi'
        $DCHelper = 'OOMADs.msi'

        # Create logging directory

        if (-not (Test-Path $LogPath)) {
            New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
        }
    }
    Process {
        foreach ($Computer in $ComputerName) {
            
            # Determine Management server based on AD forest

            $Domain = $Computer.split('.')[1..($Computer.split('.').Length)] -join('.')
            if ($Domain -eq 'ihg.global') {
                $ManagemantServer = $IHG_ManagemantServer
            }
            elseif ($Domain -eq 'ihgint.global') {
                $ManagemantServer = $IHGINT_ManagemantServer
            }
            elseif ($Domain -eq 'ihgext.global') {
                $ManagemantServer = $IHGEXT_ManagemantServer
            }
            elseif ($Domain -like '*corp.local') {
                $ManagemantServer = $CORP_ManagemantServer
            }            
            
            # Ping test targeted server

            if (-not(Test-Connection -ComputerName $Computer -Count 1 -Quiet)) {
                $Message = (Get-Date -Format HH:mm:ss).ToString()+" : Unable to ping $Computer"
                Write-Verbose $Message
                $Message | Out-File $LogPath\$LogFile -Append
                break
            }

            # Create remote powershell session

            try {
                New-PSSession -ComputerName $Computer -OutVariable SCOMInstall -ErrorAction Stop | Out-Null
            }
            catch {
                $Message = (Get-Date -Format HH:mm:ss).ToString()+" : Unable to initiate remote session with client $Computer ; $_"
                Write-Verbose $Message
                $Message | Out-File $LogPath\$LogFile -Append
                break
            }

            # Determine if agent is already installed

            $Installed = Get-Service -ComputerName $Computer -Name HealthService -ErrorAction SilentlyContinue
            if ($Installed) {
                $Message = (Get-Date -Format HH:mm:ss).ToString()+" : SCOM agent already installed on client $Computer"
                Write-Verbose $Message
                $Message | Out-File $LogPath\$LogFile -Append
                break
            }
            
            #Determine if target server is Domain Controller
            
            $DC = Get-ADDomainController -DomainName $Domain -Filter {DNSHostName -eq $Computer}
            
            # Log successful remote connection

            $Message = "Initiating remote install on client $Computer, check client logs for details"
            Write-Verbose $Message
            $Message | Out-File $LogPath\$LogFile -Append

            # Run code on target server

            Invoke-Command -Session $SCOMInstall -ScriptBlock {
                
                # Enable verbose output in remote session

                $VerbosePreference=$Using:VerbosePreference
                
                # Create logging and install directories
                
                if (-not (Test-Path $Using:LogPath)) {
                    New-Item -ItemType Directory -Path $Using:LogPath -Force | Out-Null
                }
                if (-not (Test-Path $Using:LocalPath)) {
                    New-Item -ItemType Directory -Path $Using:LocalPath -Force | Out-Null
                }
                
                # Download agent from internal repository

                Write-Verbose "Downloading SCOM agent from $url to client $Using:Computer"
                try {                    
                    Invoke-WebRequest -Uri $Using:url/$Using:MomAgent -OutFile $Using:LocalPath\$Using:MomAgent
                }
                catch {
                    $Message = (Get-Date -Format HH:mm:ss).ToString()+" : Unable to download $Using:MomAgent from $Using:url ; $_"
                    Write-Verbose $Message
                    $Message| Out-File $Using:LogPath\$Using:LogFile -Append
                    Remove-PSSession $SCOMInstall
                    break
                }

                #If server is domain controller, download OOMADs helper service

                if ($Using:DC) {
                    Write-Verbose "Downloading OOMADs agent from $url to client $Using:Computer"
                    try {                    
                        Invoke-WebRequest -Uri $Using:url/$Using:DCHelper -OutFile $Using:LocalPath\$Using:DCHelper
                    }
                    catch {
                        $Message = (Get-Date -Format HH:mm:ss).ToString()+" : Unable to download $Using:DCHelper from $Using:url ; $_"
                        Write-Verbose $Message
                        $Message| Out-File $Using:LogPath\$Using:LogFile -Append
                        Remove-PSSession $SCOMInstall
                        break
                }

                # Run msiexec to install agent msi

                Write-Verbose "Installing SCOM agent on client $Using:Computer"
                Write-Verbose "Management Group: $Using:ManagementGroup"
                Write-Verbose "Management Server: $Using:ManagemantServer"
                Write-Verbose "LogFile : $Using:LogPath\$Using:LogFile"
                try {
                    Start-Process -FilePath `
                    "$env:SystemRoot\system32\msiexec.exe" `
                    -ErrorAction Stop `
                    -Wait `
                    -ArgumentList "/i $Using:LocalPath\$Using:MomAgent USE_SETTINGS_FROM_AD=0 MANAGEMENT_GROUP=$Using:ManagementGroup MANAGEMENT_SERVER_DNS=$Using:ManagemantServer ACTIONS_USE_COMPUTER_ACCOUNT=1 USE_MANUALLY_SPECIFIED_SETTINGS=1 AcceptEndUserLicenseAgreement=1 /qn /l*v $Using:LogPath\$Using:LogFile"
                }
                catch {
                    $Message = (Get-Date -Format HH:mm:ss).ToString()+" : Failed in to install $Using:MomAgent ; $_ "
                    Write-Verbose $Message
                    $Message | Out-File $Using:LogPath\$Using:LogFile -Append
                }

                #If server is domain controller, install OOMADs helper service

                if ($Using:DC) {
                    try {
                        Start-Process -FilePath `
                        "$env:SystemRoot\system32\msiexec.exe" `
                        -ErrorAction Stop `
                        -Wait `
                        -ArgumentList "/i $Using:LocalPath\$Using:DCHelper /qn /l*v $Using:LogPath\$Using:LogFile"
                    }
                    catch {
                        $Message = (Get-Date -Format HH:mm:ss).ToString()+" : Failed in to install $Using:MomAgent ; $_ "
                        Write-Verbose $Message
                        $Message | Out-File $Using:LogPath\$Using:LogFile -Append
                    }
                }
            }

            # Clean up remote session

            Remove-PSSession $SCOMInstall
        }
    }
}
