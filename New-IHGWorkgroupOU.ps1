Function New-IHGWorkgroupOU {
    <#
        .SYNOPSIS
            Create AD OU for new IHG workgroup

        .DESCRIPTION
            Binds to domain controller in specified AD domain and AD site, queries for existance of OU.
            If no matching OU is present, a new one is generated.

        .PARAMETER Workgroup
            IHG workgroup for which the OU should be created.
        
        .PARAMETER Description
            Text to be entered in description field. 
            This should be the full name of the application represented by the workgroup.
        
        .PARAMETER Domain
            The AD domain in which the OU should be created.
        
        .PARAMETER DataCenter
            The datacenter/AD Site in which for which to find an active DC.
        
        .PARAMETER PassThru
            Optional switch to pass an object to the pipeline.

        .PARAMETER Credential
            Alternate credentials for running AD commands.
        
        .EXAMPLE
            New-IHGWorkgroupOU -Workgroup 'tst' -Description 'test' -Domain 'ihgint.global' -DataCenter 'iadd1' -Verbose -PassThru
        
        .EXAMPLE
            New-IHGWorkgroupOU -Workgroup 'tst' -Description 'test' -Domain 'ihgext.global' -DataCenter 'sjcd1'
			
        .EXAMPLE
            Import-Csv NewWorkgroups.csv | New-IHGWorkgroupOU -Credential ihgint\admin_test
  #>

    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Low')]
    [OutputType('Microsoft.ActiveDirectory.Management.ADOrganizationalUnit')]
        Param (
            [Parameter(Mandatory=$true,
            Position=0,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
            [ValidateLength(3,3)]
            [ValidateNotNullOrEmpty()]
            [string]
            $Workgroup,

            [Parameter(Mandatory=$true,
            Position=0,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
            [ValidateNotNullOrEmpty()]
            [string]
            $Description,

            [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
            [ValidateNotNullOrEmpty()]
            [string]
            $Domain,

            [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
            [ValidateNotNullOrEmpty()]
            [string]
            $DataCenter,

            [Parameter()]
            [PsCredential]
            [System.Management.Automation.CredentialAttribute()]
            $Credential,
            
            [Parameter()]
            [switch]
            $PassThru
        )

    Begin {
        
# Configure required variables
        $LogPath = "$env:SystemDrive\logs\New-IHGWorkgroupOU"
        $LogFile = (Get-Date -Format yyyy_MM_dd)+"_New-IHGWorkgroupOU.log"

# Create logging directory
        if (-not (Test-Path $LogPath)) {
            New-Item -ItemType Directory -Path $LogPath -Force |
            Out-Null
        }
    }

    Process {    

# Discover domain controller in target forest and site, and set as target DC
        $DomainShortName = $Domain.ToString().Split('.')[0]
        try {
            Get-ADDomainController -Discover -DomainName $Domain -SiteName $DataCenter -Writable -OutVariable 'ADServer' -ErrorAction Stop |
            Out-Null
        }
        catch {
            $Message = (Get-Date -Format HH:mm:ss).ToString()+" : Unable to connect to domain controller in $Domain"
            Write-Verbose $Message
            $Message | Out-File $LogPath\$LogFile -Append
        }

# Build hash to pass parameters to New-ADOrganizationalUnit commandlet
        $OUPath = "OU=Servers,OU=AMER,OU=IHG,DC=$DomainShortName,DC=global"
        $OUCreateParams = @{
            Server = $ADServer.HostName
            Name = $WorkGroup
            DisplayName = $WorkGroup.ToLower()
            Description = $Description.ToLower()
            Path = $OUPath
            PassThru = $true
            OutVariable = 'NewOU'
            ErrorAction = 'Stop'
        }

# Add optional credentials parameters to hash
        if ($Credential) {
            $OUCreateParams.Add('Credential', $Credential)
        }

# Create OU in active directory
         try {
            New-ADOrganizationalUnit @OUCreateParams |
            Out-Null
            $Message = (Get-Date -Format HH:mm:ss).ToString()+" : Successfully created workgroup OU $($NewOU.DistinguishedName)"
            Write-Verbose $Message
            $Message | Out-File $LogPath\$LogFile -Append
        }
        catch {
            $Message = (Get-Date -Format HH:mm:ss).ToString()+" : Unable to create OU $WorkGroup in $Domain with the error: $_"
            Write-Verbose $Message
            $Message | Out-File $LogPath\$LogFile -Append
        }

# Write object to pipeline if PassThru was selected
        if ($PassThru) {
            Write-Output $NewOU
        }
    }

    End {}
