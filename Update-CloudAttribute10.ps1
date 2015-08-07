#$Cred = Get-Credential corp\adminrt_rothja
#$Users = Get-ADUser -Server corp.local:3268 -Filter {enabled -eq 'True'} -Properties msDS-cloudExtensionAttribute10, CanonicalName
$Log = 'C:\_limbo\Attrib10_Update.csv'

foreach ($User in $Users) {
    $Properties = [ordered] @{
        UPN = $User.UserPrincipalName
        Attrib10 = $User.'msDS-cloudExtensionAttribute10'
        NewAttrib10 = 'CN='+$User.SamAccountName+'/O='+$User.CanonicalName.split(".")[0]
        Domain = $User.CanonicalName.split(".")[0]
    }
    
    $Object = New-Object -TypeName psObject -Property $Properties
    if ($Object.UPN -ne $null) {
        if ($User.'msDS-cloudExtensionAttribute10' -ne $Object.NewAttrib10) {
            Write-Host "Updating attribute on $($Object.UPN) from $($Object.Attrib10) to $($Object.NewAttrib10)"
            $Object | export-csv -NoTypeInformation $Log -Append
            $Domain = $Object.Domain
            Set-ADUser -Server $Domain -Identity $User -Replace @{'MSDS-CloudExtensionAttribute10'=$Object.NewAttrib10} -Credential $Cred
        }
    }
    Remove-Variable Object
    Remove-Variable Properties
}
