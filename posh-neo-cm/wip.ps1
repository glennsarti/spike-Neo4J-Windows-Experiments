$ErrorActionPreference = 'Stop'

Get-Module -Name 'NeoTechnologies.Neo4jForWindows' | Remove-Module
Import-Module "$PSScriptRoot\src\NeoTechnologies.Neo4jForWindows.psd1" | Out-Null

#Get-Command -Module 'NeoTechnologies.Neo4jForWindows'

#"C:\tools\neo4j-enterprise\neo4j-enterprise-2.2.0","C:\tools\neo4j-community\neo4j-community-2.2.0" | Get-Neo4jServer
Write-Host "---" -ForegroundColor Yellow

#Set-Neo4jSetting -Setting 'invalid-setting' -ConfigurationFile 'invalid-configurationfile' -Neo4jHome 'TestDrive:\some-dir-that-doesnt-exist' -value 'xxx'

Get-Neo4jServer "C:\tools\neo4j-community\neo4j-community-2.2.0" | Get-Neo4jSettings | Sort-Object ConfigurationFile,Name | ft

#Get-Neo4jSettings -Home "C:\tools\neo4j-community\neo4j-community-2.2.0"

#Get-Neo4jSettings | ConvertTo-Json

#Get-Neo4jServer | Get-Neo4jSettings | Out-GridView -Wait

#Get-Neo4jServer | Get-Neo4jSettings | ? { $_.Name -eq 'node_auto_indexingxx' } | % { $_.Value = 'true'; Write-Output $_ } | Set-Neo4jSetting

#Set-Neo4jSetting -ConfigurationFile 'neo4j.properties' -Name 'node_auto_indexingxx' -Value 'false' | Remove-Neo4jSetting

#Set-Neo4jSetting -ConfigurationFile 'neo4j.properties' -Name 'node_auto_indexingxx' -Value 'false'
#Get-Neo4jServer | Set-Neo4jSetting -ConfigurationFile 'neo4j.properties' -Name 'node_auto_indexingxx' -Value 'false'
