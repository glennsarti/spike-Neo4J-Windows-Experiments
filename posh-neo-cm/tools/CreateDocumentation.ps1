# Copyright (c) 2002-2015 "Neo Technology,"
# Network Engine for Objects in Lund AB [http://neotechnology.com]
#
# This file is part of Neo4j.
#
# Neo4j is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Reference
# https://technet.microsoft.com/en-us/library/hh847834.aspx
#
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$PSModuleName = 'Neo4j-Management'
)
$ErrorActionPreference = 'Stop'

function Get-ThisDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  $Global:ThisDirectory = (Split-Path ($Invocation.MyCommand.Path))
  $Global:ThisDirectory = Join-Path -Path $Global:ThisDirectory -ChildPath '..'
  $Global:ThisDirectory
}

function Convert-ExampleItem($objItem) {
	@"
**$($objItem.title.Replace('-','').Trim())**

$($objItem.remarks | ? { $_.Text -ne ''} | % { Write-Output $_.Text})

``````powershell
$($objItem.Introduction.Text) $($objItem.Code)
``````

"@
}
function Convert-SyntaxItem($objItem, $hasCmdletBinding) {
	$cmd = $objItem.Name

	if ($objItem.parameter -ne $null) {
		$objItem.parameter | % {
			$cmd += " "
			if ($_.required -eq $false) { $cmd += '['}
			$cmd += "-$($_.name)"
				

			if ($_.parameterValue -ne $null) { $cmd += " <$($_.parameterValue)>" }
			if ($_.parameterValueGroup -ne $null) { $cmd += " {" + ($_.parameterValueGroup.parameterValue -join ' | ') + "}"}
			if ($_.required -eq $false) { $cmd += ']'}
		}
	}
	if ($hasCmdletBinding) { $cmd += " [<CommonParameters>]"}
	Write-Output "``````powershell`n$($cmd)`n``````"
}
function Convert-Parameter($objItem, $commandName) {
	$parmText = "`n###  -$($objItem.name)"
	if ( ($objItem.parameterValue -ne $null) -and ($objItem.parameterValue -ne 'SwitchParameter') ) {		
		$parmText += ' '
		if ([string]($objItem.required) -eq 'false') { $parmText += "["}
		$parmText += "\<$($objItem.parameterValue)\>"
		if ([string]($objItem.required) -eq 'false') { $parmText += "]"}
	}
	$parmText += "`n"
	if ($objItem.description -ne $null) {
		$parmText += (($objItem.description | % { $_.Text }) -join "`n") + "`n`n"
	}
	if ($objItem.parameterValueGroup -ne $null) {
		$parmText += "`nValid options: " + ($objItem.parameterValueGroup.parameterValue -join ", ") + "`n`n"
	}

  $aliases = [string]((Get-Command -Name $commandName).parameters."$ ($objItem.Name)".Aliases -join ', ')
	$required = [string]($objItem.required)
	$position = [string]($objItem.position)
	$defValue = [string]($objItem.defaultValue)
	$acceptPipeline = [string]($objItem.pipelineInput)

	$padding = ($aliases.Length,$required.Length,$position.Length,$defValue.Length,$acceptPipeline.Length | Measure-Object -Maximum).Maximum

    $parmText += @"

Property               | Value
---------------------- | $([string]('-' * $padding))
Aliases                | $($aliases)
Required?              | $($required)
Position?              | $($position)
Default Value          | $($defValue)
Accept Pipeline Input? | $($acceptPipeline)


"@

	Write-Output $parmText
}

try
{
	Get-ThisDirectory | Out-Null

  	Write-Host "Importing the Module $PSModuleName ..."
	Import-Module "$($Global:ThisDirectory)\src\$($PSModuleName).psd1"

	Write-Host 'Creating per command markdown files...'  
	Get-Command -Module $PSModuleName | ForEach-Object -Process { Get-Help $_ -Full } | ForEach-Object -Process { `
		$commandName = $_.Name
		$fileName = "$($Global:ThisDirectory)\docs\$($_.Name).md"
		$hasCmdletBinding = (Get-Command -Name $commandName).CmdLetBinding

		Write-Host "Generating $fileName ..."
		@"
# $($_.Name)

$($_.Synopsis)
$( if ($_.description -ne $null) { "`n" + $_.description.Text.Replace("`n","`n`n")})

## Syntax

$( ($_.syntax.syntaxItem | % { Convert-SyntaxItem $_ $hasCmdletBinding }) -join "`n`n")


## Parameters
$( if ($_.parameters.parameter.count -gt 0) { $_.parameters.parameter | % { Convert-Parameter $_ $commandName }}) $( if ($hasCmdletBinding) { "`n### \<CommonParameters\>`n`nThis cmdlet supports the common parameters: -Verbose, -Debug, -ErrorAction, -ErrorVariable, -OutBuffer, and -OutVariable. For more information, see ``about_CommonParameters`` http://go.microsoft.com/fwlink/p/?LinkID=113216 ." } )

## Aliases

$( if ($_.aliases -ne $null) { $_.aliases } else { 'None'} )

## Notes
$( if ($_.alertSet -ne $null) { "`n" + $_.alertSet.alert.Text.Replace("`n","`n`n")})

## Examples
$( if ($_.Examples -ne $null) { ($_.Examples.Example | % { Convert-ExampleItem $_ }) -join "`n`n" })

## Links

$( if ($_.relatedLinks -ne $null) { $_.relatedLinks.navigationLink | ? { $_.linkText -ne $null} | % { Write-Output $_.LinkText; Write-Output "`n`n" }})

"@ | Out-File $fileName -Encoding Default
	}

	Exit 0
}
catch
{
	Throw "Failed to generate documenation.  $_"
	Exit 255
}