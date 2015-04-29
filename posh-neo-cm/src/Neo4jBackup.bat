@ECHO OFF
Powershell -NoProfile -ExecutionPolicy Bypass -Command "Import-Module '%~dp0Neo4j-Management.psd1'; Exit (Get-Neo4jServer '%~dp0..' | Start-Neo4jBackup %* -Wait)"
EXIT /B %ERRORLEVEL%