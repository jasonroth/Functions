# Set earliest date for user creation

    $Date = (Get-Date).AddDays(-7)

# Search for enabled accounts created since $Date

    $Users = Get-IHGUser * -Enabled | where Created -GT $Date

# Configure Logging

    $LogPath = "$env:SystemDrive\logs\Set-CloudAttribute10"
    $LogFile = (Get-Date -Format yyyy_MM_dd)+"_Set-CloudAttribute10.csv"
    $ErrorLog = (Get-Date -Format yyyy_MM_dd)+"_Set-CloudAttribute10_Errors.log"

# Create logging directory

    if (-not (Test-Path $LogPath)) {
        New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
    }
        
# Iterate through user accounts

    foreach ($User in $Users) {
        
# Create variables to use with Set-ADUser commandlet
    
        $Domain = ($User.UserPrincipalName).split('@')[1]
        try {
            $NewAttrib10 = 'CN='+$User.SamAccountName+'/O='+($User.UserPrincipalName.Split('@')[1]).split('.')[0]
        }
        catch {

# Write Failures to error log
    
            $Message = (Get-Date -Format HH:mm:ss).ToString()+" : Unable to determine new msDS-cloudExtensionAttribute10 for $User"
            Write-Verbose $Message
            $Message | Out-File -Append -FilePath $LogPath\$ErrorLog
        }
        
# Change the msDS-cloudExtensionAttribute10 if it is not correctly set
    
        if ($User.'msDS-cloudExtensionAttribute10' -notlike $NewAttrib10) {
            try {
                Set-ADUser -Server $Domain -Identity $User.SamAccountname -Replace @{'MSDS-CloudExtensionAttribute10'=$NewAttrib10} -Verbose
            }
            catch {
               
# Write Failures to error log
    
               $Message = (Get-Date -Format HH:mm:ss).ToString()+" : Failed to set MSDS-CloudExtensionAttribute10 for $($User.UserPrincipalName)"
               Write-Verbose $Message
               $Message | Out-File -Append -FilePath $LogPath\$ErrorLog 
            }
            
#Create custom object to export to log
    
            $Object = [PSCustomObject] @{
                UserPrincipalName = $User.UserPrincipalName
                'PreviousMSDS-CloudExtensionAttribute10' = $User.'msDS-cloudExtensionAttribute10'
                'NewMSDS-CloudExtensionAttribute10' = $NewAttrib10
                Created = $User.Created
            }
            
# Export custom object to log, then clear object variable
    
            $Object | Export-Csv -NoTypeInformation -Append -Path $LogPath\$LogFile
        }
        if ($User) {Remove-Variable User}
        if ($Domain) {Remove-Variable Domain}
        if ($NewAttrib10) {Remove-Variable NewAttrib10}
        if ($Message) {Remove-Variable Message}
        if ($Object) {Remove-Variable Object}
    }
