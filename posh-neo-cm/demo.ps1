$ErrorActionPreference = 'Stop'

# Approved Verb List
#https://msdn.microsoft.com/en-us/library/ms714428%28v=vs.85%29.aspx

$VerbosePreference = 'SilentlyContinue'

Get-Module -Name 'Neo4j-Management' | Remove-Module
Import-Module "$PSScriptRoot\src\Neo4j-Management.psd1" | Out-Null

# Fails if No NEO4J_HOME
#Get-Neo4jServer

# Single directory
#"C:\tools\neo4j-community\neo4j-community-2.2.0" | Get-Neo4jServer
#Get-Neo4jServer -Home "C:\tools\neo4j-community\neo4j-community-2.2.0"

# Multiple directories
#"C:\tools\neo4j-community\neo4j-community-2.2.0","C:\tools\neo4j-enterprise\neo4j-enterprise-2.2.0","C:\tools\neo4j-enterprise2\neo4j-enterprise-2.2.0" | Get-Neo4jServer

# Different export options in settings
#"C:\tools\neo4j-enterprise\neo4j-enterprise-2.2.0" | Get-Neo4jSetting
#"C:\tools\neo4j-enterprise\neo4j-enterprise-2.2.0" | Get-Neo4jSetting | ConvertTo-Json
#"C:\tools\neo4j-enterprise\neo4j-enterprise-2.2.0" | Get-Neo4jSetting | Out-GridView -Wait

# Set a Setting
# "C:\tools\neo4j-enterprise\neo4j-enterprise-2.2.0" | Set-Neo4jSetting -Name 'org.neo4j.server.webserver.port' -Value 9000 -ConfigurationFile 'neo4j-server.properties'

# What If, PassThru
#"C:\tools\neo4j-community\neo4j-community-2.2.0" | Initialize-Neo4jServer -ListenOnIPAddress 127.0.0.1 -PassThru -WhatIf

# help
# Get-Help Start-Neo4jServer

# Start a Server Console
#"C:\tools\neo4j-community\neo4j-community-2.2.0" | Initialize-Neo4jServer -ListenOnIPAddress 127.0.0.1 -EnableRemoteShell -PassThru | Start-Neo4jServer -Console
# Start a shell - Reads the server config to get the right host and port  -Wait
#"C:\tools\neo4j-community\neo4j-community-2.2.0" | Start-Neo4jShell -Wait

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Three Node Cluster (2 x Database + 1 x Arbiter)
#   Note the -ClearExistingDatabase
# Get-Neo4jServer "C:\tools\neo4j-enterprise\neo4j-enterprise-2.2.0" | `
#   Initialize-Neo4jServer -ListenOnIPAddress 127.0.0.1 -HTTPPort 7474 -ClearExistingDatabase -OnlineBackupServer '127.0.0.1:6362' -PassThru | `
#   Initialize-Neo4jHACluster -ServerID 1 -InitialHosts '127.0.0.1:5001' -ClusterServer '127.0.0.1:5001' -HAServer '127.0.0.1:6001' -PassThru | `  
#   Start-Neo4jServer -Console
# 
# Start-Sleep -Seconds 10
# 
# Get-Neo4jServer "C:\tools\neo4j-enterprise2\neo4j-enterprise-2.2.0" | `
#   Initialize-Neo4jServer -ListenOnIPAddress 127.0.0.1 -HTTPPort 7475 -ClearExistingDatabase -OnlineBackupServer '127.0.0.1:6363' -PassThru | `
#   Initialize-Neo4jHACluster -ServerID 2 -InitialHosts '127.0.0.1:5001' -ClusterServer '127.0.0.1:5002' -HAServer '127.0.0.1:6002' -DisallowClusterInit -PassThru | `
#   Start-Neo4jArbiter -Console
# 
# Get-Neo4jServer "C:\tools\neo4j-enterprise3\neo4j-enterprise-2.2.0" | `
#   Initialize-Neo4jServer -ListenOnIPAddress 127.0.0.1 -HTTPPort 7476 -ClearExistingDatabase -OnlineBackupServer '127.0.0.1:6364' -PassThru | `
#   Initialize-Neo4jHACluster -ServerID 3 -InitialHosts '127.0.0.1:5001' -ClusterServer '127.0.0.1:5003' -HAServer '127.0.0.1:6003' -DisallowClusterInit -PassThru | `
#   Start-Neo4jServer -Console
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Install the server
# Get-Neo4jServer "C:\tools\neo4j-enterprise\neo4j-enterprise-2.2.0" | `
#   Initialize-Neo4jServer -ListenOnIPAddress 127.0.0.1 -HTTPPort 7474 -OnlineBackupServer '127.0.0.1:6362' -PassThru | `
#   Initialize-Neo4jHACluster -ServerID 1 -InitialHosts '127.0.0.1:5001' -ClusterServer '127.0.0.1:5001' -HAServer '127.0.0.1:6001' -PassThru | `  
#   Install-Neo4jService -Name 'Neo4j-Server-Demo' -PassThru -SucceedIfAlreadyExists | `
#   Start-Neo4jServer
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=


#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
# Azure Demo
# Write-Host 'Session options...'
# $sessOption = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
# Write-Host 'Creating session...'
# $azureSession = New-PSSession -Computername 'glenntest2012r2.cloudapp.net' -Port 5986 -Credential 'glenntest2012r2\Glenn' -UseSSL -SessionOption $sessOption
# 
# Write-Host 'Invoking script...'
# Invoke-Command -Session $azureSession -ScriptBlock {
#   Import-Module 'C:\Demo\neo4j-community-2.2.0\bin\Neo4j-Management.psd1'
#   
#   'C:\Demo\neo4j-community-2.2.0' | `
#     Initialize-Neo4jServer -EnableRemoteShell -ListenOnIPAddress '0.0.0.0' -ClearExistingDatabase -PassThru | `
#     Install-Neo4jService -Name 'Neo4j-Server-Azure1' -PassThru -SucceedIfAlreadyExists | `
#     Start-Neo4jServer
# } 
# 
# Write-Host 'Cleanup...'
# Get-PSSession | Remove-PSSession
#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
