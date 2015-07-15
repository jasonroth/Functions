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
            [Parameter(Mandatory=$True,
            Position=0,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True)]
			[ValidateNotNullOrEmpty()]
			[Alias('samaccountname')]
            [string[]]$Name
        )

    begin
    {
        $Output = @()
		$ForestName = ([System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()).Name
        $ADsPath = [ADSI]"GC://$ForestName"
        $Search = New-Object -TypeName ADSISearcher -ArgumentList $ADsPath
    }
    process
    {
	    $Search.Filter = "(&(objectCategory=User)(SamAccountName=$Name))"

		if ((($Results = $Search.FindAll()).count)-gt '1')
			{
				$Dupes = ($Results | ForEach-Object{$_.Properties.userprincipalname})
				Write-Error -Message "Duplicate SamAccountNames found in AD! ---- $Dupes"
			}
		else
			{
				$Object = $Results | Select-Object -ExpandProperty Properties |
				Select-Object @{Name='givenname';Expression={$_.givenname}},
				@{Name='sn';Expression={$_.sn}},
				@{Name='displayname';Expression={$_.displayname}},
				@{Name='employeeID';Expression={$_.employeeid}},
				@{Name='samaccountname';Expression={$_.samaccountname}},
				@{Name='mail';Expression={$_.mail}},
				@{Name='extensionattribute9';Expression={$_.extensionattribute9}},
				@{Name='extensionattribute14';Expression={$_.extensionattribute14}},
				@{Name='userprincipalname';Expression={$_.userprincipalname}},
				@{Name='proxyaddresses';Expression={$_.proxyaddresses}}
				$Output +=$Object
			}
    }
    end {Write-Output -InputObject $Output}
}