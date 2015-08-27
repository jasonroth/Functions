function Get-IHGUser
{
    <#
        .SYNOPSIS
            Retrieve AD objects based on login name

        .DESCRIPTION
            Bind to a global catalog server in the root of the current forest and query for objects with specified login name

        .PARAMETER Name
            The samaccountname to query.
        
        .EXAMPLE
            Get-IHGUser -Name doej
        
        .EXAMPLE
            Get-IHGUser doej
            
        .EXAMPLE
            'doej','smithj' | Get-IHGUser | Export-Csv Users.csv


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
            Write-Verbose "Unable to contact AD Forest $Forest"
            $Date = Get-Date -Format yyyy_MM_dd
            $Message = "Unable to contact AD Forest $Forest. $($_.Exception.Message)"
            $Message | Out-File C:\logs\"$Date"_get-ihguser_errorlog.txt -Append
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
            'employeeid',
            'givenname',
            'sn',
            'samaccountname',
            'userprincipalname',
            'proxyaddresses',
            'whencreated'
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
                $Object = $User | Select-Object -ExpandProperty Properties |
		    		              Select-Object @{Name='GivenName';Expression={$_.givenname}},
		    		                            @{Name='Surname';Expression={$_.sn}},
		    		                            @{Name='DisplayName';Expression={$_.displayname}},
		    		                            @{Name='EmployeeID';Expression={$_.employeeid}},
		    		                            @{Name='SamAccountName';Expression={$_.samaccountname}},
		    		                            @{Name='Mail';Expression={$_.mail}},
		    		                            #@{Name='ExtensionAttribute9';Expression={$_.extensionattribute9}},
		    		                            #@{Name='ExtensionAttribute14';Expression={$_.extensionattribute14}},
                                                @{Name='Created';Expression={$_.whencreated}},
                                                @{Name='Disabled';Expression={([ADSI]$User.Path).psbase.invokeget('AccountDisabled')}},  
		    		                            @{Name='UserPrincipalName';Expression={$_.userprincipalname}},
		    		                            @{Name='ProxyAddresses';Expression={$_.proxyaddresses}}
                Write-Output -InputObject $Object
            }
        }        
    }
    end {}
}