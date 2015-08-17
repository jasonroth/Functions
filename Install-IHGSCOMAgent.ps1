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
        $ManagemantServer = 'iadd1pwom1ap001.ihg.global'
        $MomAgent = 'MOMAgent.msi'
        $DCHelper = 'OOMADs.msi'

    }
    Process {
        foreach ($Computer in $ComputerName) {
            try {
                New-PSSession -ComputerName $Computer -OutVariable SCOMInstall -ErrorAction Stop | Out-Null
            }
            catch {
                $Message = (Get-Date -Format HH:mm:ss).ToString()+" : Unable to initiate remote session with client $Computer ;$_.Exception.Message"
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
                    $Message = (Get-Date -Format HH:mm:ss).ToString()+" : Unable to download $Using:MomAgent from $Using:url ;$_.Exception.Message ; $Using:url/$Using:MomAgent $Using:LocalPath\$Using:MomAgent"
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
