﻿# Set earliest date for user creation

$Date = [datetime]'06/01/2013'

# Search for enabled accounts created since $Date
$Users = Get-IHGUser * -Enabled | where Created -GT $Date

# Configure Logging

$LogPath = "$env:SystemDrive\logs\Change_DisplayName"
$LogFile = (Get-Date -Format yyyy_MM_dd)+"_Change_DisplayName.csv"
$ErrorLog = (Get-Date -Format yyyy_MM_dd)+"_Change_DisplayName_Errors.log"

# Create logging directory

if (-not (Test-Path $LogPath)) {
    New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
}
        
# Iterate through user accounts

foreach ($User in $Users | Where UserPrincipalName -NotLike '*@global.corp.local') {
    
    # Create variables to use with Set-ADUser commandlet

    $Domain = ($User.UserPrincipalName).split('@')[1]
    try {
        $NewDisplayName = (Get-Culture).TextInfo.ToTitleCase($User.Surname.Trim()+", "+$User.GivenName.Trim())
    }
    catch {
        # Write Failures to error log

        $Message = (Get-Date -Format HH:mm:ss).ToString()+" : Unable to determine new DisplayName for $User"
        Write-Verbose $Message
        $Message | Out-File -Append -FilePath $LogPath\$ErrorLog
    }
    
    # Change the DisplayName if it does not currently start with "LastName, FirstName"

    if ($User.DisplayName -notlike $NewDisplayName+'*') {
        try {
            Set-ADUser -Server $Domain -Identity $User.SamAccountname -DisplayName $NewDisplayName -Verbose
        }
        catch {
           
           # Write Failures to error log

           $Message = (Get-Date -Format HH:mm:ss).ToString()+" : Failed to set DisplayName for $($User.UserPrincipalName)"
           Write-Verbose $Message
           $Message | Out-File -Append -FilePath $LogPath\$ErrorLog 
        }
        
        #Create custom object to export to log

        $Object = [PSCustomObject] @{
            UserPrincipalName = $User.UserPrincipalName
            Surname = $User.Surname
            GivenName = $User.GivenName
            PreviousDisplayName = $User.DisplayName
            NewDisplayName = $NewDisplayName
            Created = $User.Created
        }
        
        # Export custom object to log, then clear object variable

        $Object | Export-Csv -NoTypeInformation -Append -Path $LogPath\$LogFile
        Remove-Variable Object
        Remove-Variable User
        Remove-Variable Domain
        Remove-Variable NewDisplayName
        Remove-Variable Message
    }
}
