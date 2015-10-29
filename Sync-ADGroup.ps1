Function Sync-ADGroup {
    <#
        .SYNOPSIS
            Sync two AD Groups

        .DESCRIPTION
            Sync members of AD groups in the same, or different AD forests/domains.
            Syc methods are
                            Mirror : Membership of DifferenceGroup will be set to mirror that of ReferenceGroup.
                            TwoWay : Membership of both groups will be syncronized, adding and removing accounts from each group as needed.
                            Update : Members of ReferenceGroup will be added to DifferenceGroup. No accounts are removed from either group.

        .PARAMETER ReferenceGroup
            AD Group to be used as source for replication
        
        .PARAMETER DifferenceGroup
            AD Group to be used as destination for replication
        
        .PARAMETER ReferenceGroupDomain
            FQDN of AD forest or domain in which the ReferenceGroup resides
        
        .PARAMETER DifferenceGroupDomain
            FQDN of AD forest or domain in which the DifferenceGroup resides
        
        .PARAMETER SyncMethod
            The type of synchronization desired.
            Syc methods are
                            Mirror : Membership of DifferenceGroup will be set to mirror that of ReferenceGroup.
                            TwoWay : Membership of both groups will be syncronized, adding and removing accounts from each group as needed.
                            Update : Members of ReferenceGroup will be added to DifferenceGroup. No accounts are removed from either group.

        .PARAMETER Credential
            AD credential with authority to modify group membership of both groups.
        
        .EXAMPLE
            Sync-ADGroup -ReferenceGroup 'Source' -DifferenceGroup 'Target' -ReferenceGroupDomain 'domain.net' -DifferenceGroupDomain 'domain2.net' -SyncMethod 'Mirror'
#>

    [CmdletBinding()]
        Param (
            [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
	        [ValidateNotNullOrEmpty()]
            [Microsoft.ActiveDirectory.Management.ADGroup]
            $ReferenceGroup,

            [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
	        [ValidateNotNullOrEmpty()]
            [Microsoft.ActiveDirectory.Management.ADGroup]
            $DifferenceGroup,

            [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
	        [ValidateNotNullOrEmpty()]
            [Microsoft.ActiveDirectory.Management.ADDomain]
            $ReferenceGroupDomain,

            [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
	        [ValidateNotNullOrEmpty()]
            [Microsoft.ActiveDirectory.Management.ADDomain]
            $DifferenceGroupDomain,

            [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
	        [ValidateNotNullOrEmpty()]
            [ValidateSet("Mirror", "TwoWay", "Update")]
            [string]$SyncMethod,

            [Parameter(ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
	        [PsCredential]
            [System.Management.Automation.CredentialAttribute()]
            $Credential
        )

    Begin {

# Configure logging
        $LogPath = "$env:SystemDrive\logs\Sync-ADGroup"
        $LogFile = (Get-Date -Format yyyy_MM_dd)+"_Sync-ADGroup.log"
        if (-not (Test-Path $LogPath)) {
            New-Item -ItemType Directory -Path $LogPath -Force |
            Out-Null
        }
    }

    Process {

# Discover domain controller in ReferenceGroupDomain, and set as target DC
        try {
            Get-ADDomainController -Discover -DomainName $ReferenceGroupDomain -Writable -OutVariable 'ReferenceADServer' -ErrorAction Stop |
            Out-Null
        }
        catch {
            $Message = (Get-Date -Format HH:mm:ss).ToString()+" : Unable to connect to domain controller in $ReferenceGroupDomain"
            Write-Verbose $Message
            $Message | Out-File $LogPath\$LogFile -Append
        }
        Write-Verbose "Successfully bound to DC $($ReferenceADServer.HostName)"


# Discover domain controller in DifferenceGroupDomain, and set as target DC
        try {
            Get-ADDomainController -Discover -DomainName $DifferenceGroupDomain -Writable -OutVariable 'DifferenceADServer' -ErrorAction Stop |
            Out-Null
        }
        catch {
            $Message = (Get-Date -Format HH:mm:ss).ToString()+" : Unable to connect to domain controller in $DifferenceGroupDomain"
            Write-Verbose $Message
            $Message | Out-File $LogPath\$LogFile -Append
        }
        Write-Verbose "Successfully bound to DC $($DifferenceADServer.HostName)"


# Build hash to pass parameters to Get-ADGroupMember commandlet,
# and query AD for ReferenceGroup members
        $GroupUserParams = @{
            Identity=$ReferenceGroup
            Server = $ReferenceADServer.HostName
            Recursive = $true
            ErrorAction = 'Stop'
        }
        try {
            $ReferenceGroupUsers = Get-ADGroupMember @GroupUserParams
        }
        catch {
            $Message = (Get-Date -Format HH:mm:ss).ToString()+" : Unable to determine members of $ReferenceGroup due to error: $_"
            Write-Verbose $Message
            $Message | Out-File $LogPath\$LogFile -Append
        }
        Write-Verbose "Found members of $ReferenceGroup"
 
        
# Update hash parameters for DiferenceGroup,
# and query AD for members
        $GroupUserParams.Set_Item('Identity', $DifferenceGroup)
        $GroupUserParams.Set_Item('Server', $DifferenceADServer.HostName)
        try {
            $DifferenceGroupUsers = Get-ADGroupMember @GroupUserParams
        }
        catch {
            $Message = (Get-Date -Format HH:mm:ss).ToString()+" : Unable to determine members of $DifferenceGroup due to error: $_"
            Write-Verbose $Message
            $Message | Out-File $LogPath\$LogFile -Append
        }
        Write-Verbose "Found members of $DifferenceGroup"


# Find user accounts unique to ReferenceGroup 
        $ReferenceOnly = $ReferenceGroupUsers |
        Where-Object {$DifferenceGroupUsers.SamAccountName -notcontains $_.SamAccountName}


# Find user accounts unique to DifferenceGroup
        $DifferenceOnly = $DifferenceGroupUsers |
        Where-Object {$ReferenceGroupUsers.SamAccountName -notcontains $_.SamAccountName}


# Add ReferenceOnly accounts to DifferenceGroup
        if ($ReferenceOnly -ne $null) {
            $GroupUserParams.Remove('Recursive')
            $GroupUserParams.Add('Confirm', $false)
            $GroupUserParams.Add('Members', $ReferenceOnly)
            try {
                Add-ADGroupMember @GroupUserParams
            }
            catch {
                $Message = (Get-Date -Format HH:mm:ss).ToString()+" : Unable to add users to $DifferenceGroup due to error: $_"
                Write-Verbose $Message
                $Message | Out-File $LogPath\$LogFile -Append
            }
            Write-Verbose "Successfully added users to $DifferenceGroup"
        }
        else {
            Write-Verbose "No unique user accounts in $ReferenceGroup"
        }


# If SyncMethod "Mirror" is selected, remove unique users from DifferenceGroup
        if ($SyncMethod -eq 'Mirror' -and $DifferenceOnly -ne $null) {
            $GroupUserParams.Set_Item('Members', $DifferenceOnly)
            try {
                Remove-ADGroupMember @GroupUserParams
            }
            catch {
                $Message = (Get-Date -Format HH:mm:ss).ToString()+" : Unable to remove users from $DifferenceGroup due to error: $_"
                Write-Verbose $Message
                $Message | Out-File $LogPath\$LogFile -Append
            }
            Write-Verbose "Successfully removed users from $DifferenceGroup"
        }
        else {
            Write-Verbose "No unique user accounts in $DifferenceGroup"
        }


# If SyncMethod "TwoWay" is selected, add unique users to ReferenceGroup
        if ($SyncMethod -eq 'TwoWay' -and $DifferenceOnly -ne $null) {
            $GroupUserParams.Set_Item('Identity', $ReferenceGroup)
            $GroupUserParams.Set_Item('Server', $ReferenceADServer.HostName)
            $GroupUserParams.Set_Item('Members', $DifferenceOnly)
            try {
                Add-ADGroupMember @GroupUserParams
            }
            catch {
                $Message = (Get-Date -Format HH:mm:ss).ToString()+" : Unable to add users to $ReferenceGroup due to error: $_"
                Write-Verbose $Message
                $Message | Out-File $LogPath\$LogFile -Append
            }
            Write-Verbose "Successfully added users to $ReferenceGroup"
        }
	}
    End {}
}
