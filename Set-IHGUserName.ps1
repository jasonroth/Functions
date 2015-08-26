Function Set-IHGUserName {
    <#
        .SYNOPSIS
            ####

        .DESCRIPTION
            ####

        .PARAMETER Name
            ####
        
        .EXAMPLE
            ####
        
		.EXAMPLE
            ####
			
        .EXAMPLE
            ####
  #>

    [CmdletBinding()]
        Param (
            [Parameter(Mandatory=$true,
            Position=0,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
			[ValidateNotNullOrEmpty()]
			[string[]]
            $Identity
        )

    Begin {}
    Process {
        foreach ($User in $Identity) {
            $Domain = ($User.UserPrincipalName).split('@')[1]
            $DisplayName = "$User.Surname"+", "+"$User.GivenName"
            Set-ADUser -Server $Domain -Identity $User.UserPrincipalName -DisplayName $DisplayName
                       
            [psobject]@{
                Name = $User.Name
                UserPrincipalName = $User.UserPrincipalName
                PreviousDisplayName = $User.DisplayName
                NewDisplayName = $DisplayName
            }
        }

	}
    End {}
}
