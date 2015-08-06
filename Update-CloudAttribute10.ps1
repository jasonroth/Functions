$Cred = Get-Credential corp\adminrt_rothja
$Users = Get-ADUser -Server corp.local:3268 -Filter {enabled -eq 'True'} -Properties msDS-cloudExtensionAttribute10, CanonicalName
$Log = C:\_limbo\Attrib10_Update.txt

foreach ($User in $Users) {
    $Properties = [ordered] @{
        #Sam = $User.SamAccountName
        UPN = $User.UserPrincipalName
        Attrib10 = $User.'msDS-cloudExtensionAttribute10'
        NewAttrib10 = 'CN='+$User.SamAccountName+'/O='+$User.CanonicalName.split(".")[0]
        Domain = $User.CanonicalName.split(".")[0]
    }
    
    if ($User.'msDS-cloudExtensionAttribute10' -ne $Object.NewAttrib10) {
        Write-Host "Updating attribute on $($Object.UPN) from $($Object.Attrib10) to $($Object.NewAttrib10)"
        $Object | Out-File $Log
        $Domain = $Object.UPN.Split('@')[1]
        Set-ADUser -Server $Domain -Identity $User -Replace @{'MSDS-CloudExtensionAttribute10'=$Object.NewAttrib10} -Credential $Cred
    }
}
