Function Install-IHGSCOMAgent {
    <#
        .SYNOPSIS
            ####

        .DESCRIPTION
            ####

        .PARAMETER Name
            ####
        
        .EXAMPLE
            ####
        
		.EXAMPLE
            ####
			
        .EXAMPLE
            ####
  #>

    [CmdletBinding()]
    [OutputType()]
        Param (
            [Parameter(Mandatory=$true,
            Position=0,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
			[ValidateNotNullOrEmpty()]
			[string[]]
            $ComputerName
        )

    Begin {
        $url = 'http://scomagent.ihgint.global/Agent'
        $LocalPath = "$env:SystemDrive\Install"
        $LogPath = "$env:SystemDrive\logs\MOMAgent_Install"
        $LogFile = (Get-Date -Format yyyy_MM_dd)+"_MomAgent_Install.log"
        $IHG_ManagemantServer = 'iadd1pwom2ap001.ihg.global'
        $IHGINT_ManagemantServer = 'iadd1pwom1ap001.ihgint.global'
        $IHGEXT_ManagemantServer = 'iadd1pwom2ap002.ihgext.global'
        $CORP_ManagemantServer = 'iadd1pwom2ap003.corp.local'
        $MomAgent = 'MOMAgent.msi'
        $DCHelper = 'OOMADs.msi'

    }
    Process {
        foreach ($Computer in $ComputerName) {
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
            
            if (-not(Test-Connection -ComputerName $Computer -Count 1 -Quiet)) {
                $Message = (Get-Date -Format HH:mm:ss).ToString()+" : Unable to ping $Computer"
                Write-Verbose $Message
                $Message | Out-File $LogPath\$LogFile -Append
                break
            }

            try {
                New-PSSession -ComputerName $Computer -OutVariable SCOMInstall -ErrorAction Stop | Out-Null
            }
            catch {
                $Message = (Get-Date -Format HH:mm:ss).ToString()+" : Unable to initiate remote session with client $Computer ; $_"
                Write-Verbose $Message
                $Message | Out-File $LogPath\$LogFile -Append
                break
            }

            if (Get-Service -ComputerName $Computer -Name HealthService) {
                $Message = (Get-Date -Format HH:mm:ss).ToString()+" : SCOM agent already installed on client $Computer"
                Write-Verbose $Message
                $Message | Out-File $LogPath\$LogFile -Append
                break
            }
            
            Invoke-Command -Session $SCOMInstall -ScriptBlock {
                if (-not (Test-Path $Using:LogPath)) {
                    New-Item -ItemType Directory -Path $Using:LogPath -Force
                }
                if (-not (Test-Path $Using:LocalPath)) {
                    New-Item -ItemType Directory -Path $Using:LocalPath -Force
                }
                try {
                    Invoke-WebRequest -Uri $Using:url/$Using:MomAgent -OutFile $Using:LocalPath\$Using:MomAgent
                }
                catch {
                    $Message = (Get-Date -Format HH:mm:ss).ToString()+" : Unable to download $Using:MomAgent from $Using:url ; $_"
                    Write-Verbose $Message
                    $Message| Out-File $Using:LogPath\$Using:LogFile -Append
                    break
                }
                try {
                    msiexec.exe /i  $Using:LocalPath\$Using:MomAgent USE_SETTINGS_FROM_AD=0 MANAGEMENT_GROUP=IHG-SCOM2012R2-PRD1 MANAGEMENT_SERVER_DNS=$Using:ManagemantServer ACTIONS_USE_COMPUTER_ACCOUNT=1 USE_MANUALLY_SPECIFIED_SETTINGS=1 AcceptEndUserLicenseAgreement=1 /qn /l*v $Using:LogPath\$Using:LogFile
                }
                catch {
                    $Message = (Get-Date -Format HH:mm:ss).ToString()+" : Failed in to install $Using:MomAgent ; $_ "
                    Write-Verbose $Message
                    $Message | Out-File $Using:LogPath\$Using:LogFile -Append
                }
            }
            Remove-PSSession $SCOMInstall
        }
    }
    End {}
}
