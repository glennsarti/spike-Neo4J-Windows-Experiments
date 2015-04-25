@ECHO OFF
Powershell -NoProfile -ExecutionPolicy Bypass -Command "Import-Module '%~dp0Neo4j-Management.psd1'; Get-Neo4jServer '%~dp0..' | Start-Neo4jShell %* -Wait | Out-Null"