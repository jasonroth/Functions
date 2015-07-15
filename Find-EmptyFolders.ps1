function Find-EmptyFolders
{
[cmdletbinding()]
Param
(
	[parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [string[]]$Path
)

	$EmptyFolders = @() 
	$Folders = (Get-ChildItem -Path $Path -Recurse -Directory)
		foreach ($Folder in $Folders)
		{
		    $l = 0 
    		$Files = Get-ChildItem $Folder.FullName -Recurse -Directory:$false
    		foreach ($File in $Files)
			{
				$l += $File.length
			}
			if ($l -eq 0)
			{
				$EmptyFolders += $Folder.FullName
			}
		}
$EmptyFolders
}
#Remove-Item -Recurse -ErrorAction SilentlyContinue -Force