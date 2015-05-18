$ErrorActionPreference = 'Stop'

# Approved Verb List
# https://msdn.microsoft.com/en-us/library/ms714428%28v=vs.85%29.aspx
# Writing Help
# https://technet.microsoft.com/library/hh847834.aspx

#$VerbosePreference = 'SilentlyContinue'
$VerbosePreference = 'Continue'

Get-Module -Name 'Neo4j-Management' | Remove-Module
#Import-Module "$PSScriptRoot\src\Neo4j-Management.psd1" | Out-Null
Import-Module ".\src\Neo4j-Management.psd1" | Out-Null

#Get-Command -Module 'NeoTechnologies.Neo4jForWindows'

#"C:\tools\neo4j-enterprise\neo4j-enterprise-2.2.0","C:\tools\neo4j-community\neo4j-community-2.2.0" | Get-Neo4jServer
Write-Host "---" -ForegroundColor Yellow


Get-Neo4jServer "C:\tools\neo4j-enterprise\neo4j-enterprise-2.2.0" |
  Install-Neo4jServer -PassThru |
  Start-Neo4jServer -PassThru |
  Remove-Neo4jServer

#Get-Neo4jServer "C:\tools\neo4j-enterprise\neo4j-enterprise-2.2.0" | Start-Neo4jBackup -Wait -to C:\temp\test

# Get-Neo4jServer "C:\tools\neo4j-enterprise\neo4j-enterprise-2.2.0" | `
#   Initialize-Neo4jServer -ListenOnIPAddress 127.0.0.1 -HTTPPort 7474 -OnlineBackupServer '127.0.0.1:6362' -PassThru | `
#   Initialize-Neo4jHACluster -ServerID 1 -InitialHosts '127.0.0.1:5001' -ClusterServer '127.0.0.1:5001' -HAServer '127.0.0.1:6001' -PassThru | `  
#   Install-Neo4jService -Name 'Neo4j-Server1' -PassThru -SucceedIfAlreadyExists | `
#   Start-Neo4jServer
  
# Get-Neo4jServer "C:\tools\neo4j-enterprise\neo4j-enterprise-2.2.0" | `
#   Initialize-Neo4jServer -ListenOnIPAddress 127.0.0.1 -HTTPPort 7474 -OnlineBackupServer '127.0.0.1:6362' -PassThru | `
#   Initialize-Neo4jHACluster -ServerID 1 -InitialHosts '127.0.0.1:5001' -ClusterServer '127.0.0.1:5001' -HAServer '127.0.0.1:6001' -PassThru | `  
#   Start-Neo4jServer -Console
# 
# Start-Sleep -Seconds 10
# 
# Get-Neo4jServer "C:\tools\neo4j-enterprise2\neo4j-enterprise-2.2.0" | `
#   Initialize-Neo4jServer -ListenOnIPAddress 127.0.0.1 -HTTPPort 7475 -ClearExistingDatabase -OnlineBackupServer '127.0.0.1:6363' -PassThru | `
#   Initialize-Neo4jHACluster -ServerID 2 -InitialHosts '127.0.0.1:5001' -ClusterServer '127.0.0.1:5002' -HAServer '127.0.0.1:6002' -DisallowClusterInit -PassThru | `
#   Start-Neo4jServer -Console
# 
# Get-Neo4jServer "C:\tools\neo4j-enterprise3\neo4j-enterprise-2.2.0" | `
#   Initialize-Neo4jServer -ListenOnIPAddress 127.0.0.1 -HTTPPort 7476 -ClearExistingDatabase -OnlineBackupServer '127.0.0.1:6364' -PassThru | `
#   Initialize-Neo4jHACluster -ServerID 3 -InitialHosts '127.0.0.1:5001' -ClusterServer '127.0.0.1:5003' -HAServer '127.0.0.1:6003' -DisallowClusterInit -PassThru | `
#   Start-Neo4jServer -Console

#Get-Neo4jServer "C:\tools\neo4j-community\neo4j-community-2.2.0" | Initialize-Neo4jServer -ListenOnIPAddress 127.0.0.1 -WhatIf

#Get-Neo4jServer "C:\tools\neo4j-community\neo4j-community-2.2.0" | Get-Neo4jSetting | ConvertTo-Csv > c:\temp\tes.csv


#Set-Neo4jSetting -Setting 'invalid-setting' -ConfigurationFile 'invalid-configurationfile' -Neo4jHome 'TestDrive:\some-dir-that-doesnt-exist' -value 'xxx'

# Get-Neo4jServer "C:\tools\neo4j-community\neo4j-community-2.2.0" | Get-Neo4jSettings | `
#    ? { (-not $_.IsDefault) -and ($_.ConfigurationFile -eq 'neo4j-wrapper.conf') -and ($_.Name -eq 'wrapper.java.additional') } | `
#    Set-Neo4jSetting | Sort-Object ConfigurationFile,Name | fl

#set-Neo4jSetting -Neo4jHome "C:\tools\neo4j-community\neo4j-community-2.2.0" -Name "wrapper.java.additional" -ConfigurationFile 'neo4j-wrapper.conf' -Value @('Hello','Hello2','-Dorg.neo4j.server.properties=conf/neo4j-server.properties') -WhatIf


#Get-Neo4jSettings -Home "C:\tools\neo4j-community\neo4j-community-2.2.0"

#Get-Neo4jSettings | ConvertTo-Json

#Get-Neo4jServer | Get-Neo4jSettings | Out-GridView -Wait

#Get-Neo4jServer | Get-Neo4jSettings | ? { $_.Name -eq 'node_auto_indexingxx' } | % { $_.Value = 'true'; Write-Output $_ } | Set-Neo4jSetting

#Set-Neo4jSetting -ConfigurationFile 'neo4j.properties' -Name 'node_auto_indexingxx' -Value 'false' | Remove-Neo4jSetting

#Set-Neo4jSetting -ConfigurationFile 'neo4j.properties' -Name 'node_auto_indexingxx' -Value 'false'
#Get-Neo4jServer | Set-Neo4jSetting -ConfigurationFile 'neo4j.properties' -Name 'node_auto_indexingxx' -Value 'false'
