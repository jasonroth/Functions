function Get-GlobalCatalogUser
{
    <#
        .SYNOPSIS
            Retrieve AD objects based on login name

        .DESCRIPTION
            Bind to a global catalog server in the root of the current forest and query for objects with specified login name

        .PARAMETER Name
            The samaccountname to query.
        
        .EXAMPLE
            Get-GlobalCatalogUser -Name doej
        
        .EXAMPLE
            Get-GlobalCatalogUser doej
            
        .EXAMPLE
            'doej','smithj' | Get-GlobalCatalogUser | Export-Csv Users.csv


  #>

    [CmdletBinding()]
        param
        (
            [Parameter(Mandatory=$true,
                       Position=0,
                       ValueFromPipeline=$True,
                       ValueFromPipelineByPropertyName=$True)]
            [ValidateNotNullOrEmpty()]
            [Alias('samaccountname')]
            [string[]]
            $Name,

            [Parameter(ValueFromPipeline=$True,
                       ValueFromPipelineByPropertyName=$True)]
            [string]
            $Forest = ([System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()).Name,

            [Parameter()]
            [PsCredential]
            $Credential,

            [Parameter()]
            [switch]
            $Enabled
        )

    begin {
        $Params = @{
            'Identity' = $Forest
            'ErrorAction' = 'Stop'
        }
        if ($Credential) {
            $Params.Add('Credential', $Credential)
        }

        try {
            Get-ADDomain @Params | Out-Null
        }
        catch {
            $Message = "Unable to contact AD Forest $Forest. $($_.Exception.Message)"
            throw $_.Exception.Message
        }

        $ADsPath = "GC://$Forest"
        $Searcher =
        New-Object -TypeName System.DirectoryServices.DirectorySearcher
        if ($Credential) {
            $SearcherRoot =
            New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $ADsPath, $($Credential.UserName), $($Credential.GetNetworkCredential().password)
        }
        else {
            $SearcherRoot =
            New-Object -TypeName System.DirectoryServices.DirectoryEntry -ArgumentList $ADsPath
        }
        $Searcher.SearchRoot = $SearcherRoot
        $Searcher.PageSize = 1000
        $Searcher.SizeLimit = 0
        $PropertiesToLoad = @(
            'displayname',
            'mail',
            'givenname',
            'sn',
            'samaccountname',
            'userprincipalname',
            'whencreated',

            #'employeeid',
            'msDS-cloudExtensionAttribute10'
            #'msDS-cloudExtensionAttribute16',
            #'streetaddress',
            #'l',
            #'st',
            #'postalcode',
            #'c'
            #'lastlogontimestamp',
            #'title',
            #'manager',
            #'department',
            #'physicaldeliveryofficename',
            #'pwdlastset'
        )
        foreach ($Property in $PropertiesToLoad) {
	        [Void]$Searcher.PropertiesToLoad.Add($Property)
		}
    }
    process {

        foreach ($Item in $Name) {
            if ($Enabled) {
                $Searcher.Filter =
                "(&(SamAccountType=805306368)(SamAccountName=$Item)(!(UserAccountControl:1.2.840.113556.1.4.803:=2)))"
            }
            else {
                $Searcher.Filter =
                "(&(SamAccountType=805306368)(SamAccountName=$Item))"
            }
            foreach ($User in $Searcher.FindAll()) {
                $Object = $User |
                Select-Object -ExpandProperty Properties |
                Select-Object @{Name='GivenName';Expression={$_.givenname}},
                              @{Name='Surname';Expression={$_.sn}},
                              @{Name='DisplayName';Expression={$_.displayname}},
                              @{Name='SamAccountName';Expression={$_.samaccountname}},
                              @{Name='UserPrincipalName';Expression={$_.userprincipalname}},
                              @{Name='Mail';Expression={$_.mail}},
                              
                              @{Name='msDS-cloudExtensionAttribute10';Expression={$_."msds-cloudextensionattribute10"}},
                              #@{Name='msDS-cloudExtensionAttribute16';Expression={$_."msds-cloudextensionattribute16"}},
                              #@{Name='EmployeeID';Expression={$_.employeeid}},
                              #@{Name='Title';Expression={$_.title}},
                              #@{Name='Department';Expression={$_.department}},
                              #@{Name='Manager';Expression={$_.manager}},
                              #@{Name='Office';Expression={$_.physicaldeliveryofficename}},
                              #@{Name='StreetAddress';Expression={$_.streetaddress}},
                              #@{Name='City';Expression={$_.l}},
                              #@{Name='State';Expression={$_.st}},
                              #@{Name='PostalCode';Expression={$_.postalcode}},
                              #@{Name='Country';Expression={$_.c}},
                              
                              @{Name='Created';Expression={$_.whencreated}},
                              @{Name='Disabled';Expression={([ADSI]$User.Path).psbase.invokeget('AccountDisabled')}}
                              
                              #@{Name='LastLogonTime';Expression={[datetime]::FromFileTime([int64]$_.lastlogontimestamp[0])}},
                              #@{Name='PasswordLastSet';Expression={[datetime]::FromFileTime([int64]$_.pwdlastset[0])}}
                Write-Output -InputObject $Object
            }
        }        
    }
    end {}
}
