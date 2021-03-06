#requires -Version 2
Function Test-NetworkDrive {
    <#
            .SYNOPSIS
            Mounts network drive and attempts to write a test file.

            .DESCRIPTION
            Mounts a drive to the specified path(s) and writes a text file with the current date and time as the title

            .PARAMETER Share
            The path(s) to be mounted
        
            .EXAMPLE
            Test-NetworkDrive -Share '\\Server\Share\Monitor'
        
            .EXAMPLE
            '\\Server\Share\Monitor','\\Server\Share2\Monitor' | Test-NetworkDrive
			
            .EXAMPLE
            Import-CSV Shares.csv | Test-NetworkDrive


    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
        Position = 0,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Share
    )

    begin {
        $Date = (Get-Date -Format MM_dd_yyyy_HH_mm)
    }
    process
    {
        foreach ($Object in $Share) {
            try {
                $Path = New-PSDrive -Name 'Monitor' -PSProvider FileSystem -Root "$Object" -ErrorAction Stop
                New-Item -ItemType file -Path $Path.Root -Name "$Date.txt" -ErrorAction Stop
            }
            catch {
                Write-Error -Message $_.Exception.Message
            }
            finally {
                if($Path.Name) {
                    Remove-PSDrive -Name $Path.Name -Force
                }
            }
        }
    }
    end {}
}
