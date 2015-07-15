function New-ImmutableID
{
    <#
        .SYNOPSIS
            Generates new ImmutableID for AD Users.

        .DESCRIPTION
            Looks up AD user objects based on UserPrincipalName, and generates
			an ImmutableID by converting the ObjectGUID to a Base64 string.
			
        .PARAMETER Name
            $UserPrincipalName
        
        .EXAMPLE
            New-ImmutableID smithj@domain.com
        
		.EXAMPLE
            New-ImmutableID -UserPrincipalName smithj@domain.com
			
        .EXAMPLE
            Import-CSV Users.csv | New-ImmutableID
  #>
    [CmdletBinding()]
        param
        (
            [Parameter(Mandatory=$True,
            Position=0,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$True)]
			[ValidateNotNullOrEmpty()]
			[Alias('UPN')]
            [string[]]$UserPrincipalName
        )

    begin
    {
        $Output = New-Object -TypeName System.Collections.ArrayList
		$ForestName = ([System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()).Name
        $ADsPath = [ADSI]"GC://$ForestName"
        $Search = New-Object -TypeName ADSISearcher -ArgumentList $ADsPath
    }
    process
    {
        $Search.Filter = "(&(objectCategory=User)(UserPrincipalName=$UserPrincipalName))"
		$Results = $Search.FindAll()
		foreach ($Result in $Results)
		{
			$ADUser = $Result | Select-Object -ExpandProperty Properties |
			Select-Object	@{Name='ObjectGUID';Expression={$_.objectguid}},
					 	@{Name='UserPrincipalName';Expression={$_.userprincipalname}},
						@{Name='ImmutableID';Expression={$_.extensionattribute15}}
			if ($ADUser.ImmutableID -ne $null)
            {
                $ID = $ADUser.ImmutableID
                $UPN = $ADUser.UserPrincipalName
                Write-Error "ImmutableID $ID already exists for $UPN"
            }
            else
            {
                $ByteArray = ([GUID]$ADUser.ObjectGUID).ToByteArray()
       			$ImmutableID = [system.convert]::ToBase64String($ByteArray)
        		$Properties = @{
        		ImmutableID = $ImmutableID
        		Userprincipalname = $ADUser.userPrincipalName}
        		$Object = New-Object -TypeName PSObject -Property $Properties
        		[Void]$Output.Add($Object)
		    }
		}
    }
    end {Write-Output -InputObject $Output}
}