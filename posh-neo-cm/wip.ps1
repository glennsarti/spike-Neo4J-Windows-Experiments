$ErrorActionPreference = 'Stop'

Get-Module -Name 'NeoTechnologies.Neo4jForWindows' | Remove-Module
Import-Module "$PSScriptRoot\src\NeoTechnologies.Neo4jForWindows.psd1" | Out-Null

#Get-Command -Module 'NeoTechnologies.Neo4jForWindows'

#"C:\tools\neo4j-enterprise\neo4j-enterprise-2.2.0","C:\tools\neo4j-community\neo4j-community-2.2.0" | Get-Neo4jServer
Write-Host "---" -ForegroundColor Yellow
Get-Neo4jServer | Get-Neo4jProperties
