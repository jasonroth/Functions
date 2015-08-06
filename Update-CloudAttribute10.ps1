$Users = Get-ADUser -Server apac.corp.local -Filter {Name -like 'admin_*'} -Properties msDS-cloudExtensionAttribute10, CanonicalName #| Select UserPrincipalName, msDS-cloudExtensionAttribute10, CanonicalName
$Cred = Get-Credential corp\adminrt_rothja

foreach ($User in $Users) {
    $Properties = [ordered] @{
        #Sam = $User.SamAccountName
        UPN = $User.UserPrincipalName
        Attrib10 = $User.'msDS-cloudExtensionAttribute10'
        NewAttrib10 = 'CN='+$User.SamAccountName+'/O='+$User.CanonicalName.split(".")[0]
        Domain = $User.CanonicalName.split(".")[0]
    }
    #$NewAttrib10 = 'CN='+$Properties.Sam+'/O='+$Properties.Domain
    #$Properties.Add('NewAttrib10', $NewAttrib10)
    $Object = New-Object -TypeName psObject -Property $Properties
    Write-Output $Object
    if ($User.'msDS-cloudExtensionAttribute10' -ne $Object.NewAttrib10) {
        Write-Host "Updating attribute on $($Object.UPN) from $($Object.Attrib10) to $($Object.NewAttrib10)"
        $Domain = $Object.UPN.Split('@')[1]
        Set-ADUser -Server $Domain -Identity $User -Replace @{'MSDS-CloudExtensionAttribute10'=$Object.NewAttrib10} -Credential $Cred
    }
    
}
