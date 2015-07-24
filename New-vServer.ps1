function New-vServer
{
	[CmdletBinding()]
	param
    (
		[Parameter(Mandatory=$true,
        Position=0,
		ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
		[alias('Name')]
		[array]$ComputerName,

        [Parameter(Mandatory=$false,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
		[string]$Path = 'C:\Hyper-V\Virtual Machines',

		[Parameter(Mandatory=$false,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
        [ValidateSet('1GB','2GB','3','4GB')]
		[long]$Memory= 2GB,

        [Parameter(Mandatory=$false,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
        [ValidateSet('1','2')]
		[long]$ProcessorCount= '1',

        [Parameter(Mandatory=$false,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
		[string]$vSwitch = (Get-VMSwitch -SwitchType Internal).Name,

		[Parameter(Mandatory=$false,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
		[string]$ParentDisk = 'C:\Hyper-V\Base Images\Test.vhdx'
    )

    Begin
    {
        $Split = $Path.Split('\')
        $VHDPath = $Split[0]+'\'+$Split[1]+'\Virtual Hard Disks'
    }
    
    Process
    {
	    foreach ($Computer in $ComputerName)
        {
            Try
            {
                New-VHD -ParentPath $ParentDisk -Differencing -Path "$Path\$Computer\Virtual Hard Disks\$Computer.VHDX" -ErrorAction Stop
            }
            Catch [System.Exception]
            {
                Write-Error $_.Exception.Message
                return
            }
            
            if (-not (Get-VM $Computer -ErrorAction SilentlyContinue))
            {
                New-VM -Generation 2 -Name $Computer -MemoryStartupBytes $Memory -SwitchName $vSwitch -VHDPath "$Path\$Computer\Virtual Hard Disks\$Computer.VHDX" -Path $Path
                Set-VM -VMName $Computer -ProcessorCount $ProcessorCount
		        Set-VMMemory -VMName $Computer -DynamicMemoryEnabled $true -MinimumBytes 256MB -MaximumBytes $Memory -StartupBytes $Memory -Buffer 20
                Get-VMIntegrationService -VMName $Computer | Enable-VMIntegrationService
		        Start-VM $Computer
            }
        }
        
    }

    End {}
}