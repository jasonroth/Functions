﻿Function ConvertFrom-HTMLTable {
    <#
        .SYNOPSIS
            Convert HTML tables to Powershell objects

        .DESCRIPTION
            Scrapes HTML from web site, and parses elements of table, converting each line into a PSCustomObject

        .PARAMETER Name
            Uri
        
        .EXAMPLE
            ConvertFrom-HTMLTable -Uri 'www.webpage.com'

        .Notes
            Based on code from 'Daniel Srlv'.
            http://poshcode.org/3664
    #>

    [CmdletBinding()]
    [OutputType('System.PSCustomObject')]
        Param (
            [Parameter(Mandatory=$true,
            Position=0,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true)]
            [ValidateNotNullOrEmpty()]
            [uri]$Uri
        )

    Process {
        $WebResponse = Invoke-WebRequest -Uri $Uri
        $HTMl = $WebResponse.ParsedHtml
        $Elements = $HTMl.body.getElementsByTagName('tr')
        $Headers = @()

        foreach ($Element in $Elements) {
            $ColumnID = 0
            $HeaderRow = $false
            $Object = New-Object -TypeName PSCustomObject
        
            foreach ($Child in $Element.children) {
                if ($Child.tagName -eq "th") {
                    $Headers += @($Child.outerText)
                    $HeaderRow = $true
                }
                if ($Child.tagName -eq "td") {
                    $Object | Add-Member -MemberType NoteProperty -Name $Headers[$ColumnID] -Value $Child.outerText
                }
                $ColumnID++
            }
            if (-not $HeaderRow) {
                Write-Output -InputObject $Object
            }
        }
	}
}
