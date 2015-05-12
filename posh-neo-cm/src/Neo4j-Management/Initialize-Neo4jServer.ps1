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



Function Initialize-Neo4jServer
{
  [cmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
  param (
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [object]$Neo4jServer = ''

    ,[Parameter(Mandatory=$false)]
    [switch]$PassThru
    
    ,[Parameter(Mandatory=$false)]
    [ValidateRange(0,65535)]
    [int]$HTTPPort = 7474

    ,[Parameter(Mandatory=$false)]
    [switch]$EnableHTTPS

    ,[Parameter(Mandatory=$false)]
    [ValidateRange(0,65535)]
    [int]$HTTPSPort = 7473

    ,[Parameter(Mandatory=$false)]
    [switch]$EnableRemoteShell

    ,[Parameter(Mandatory=$false)]
    [ValidateRange(0,65535)]
    [int]$RemoteShellPort = 1337

    ,[Parameter(Mandatory=$false)]
    [ValidateScript({$_ -match [IPAddress]$_ })]  
    [string]$ListenOnIPAddress = '127.0.0.1'

    ,[Parameter(Mandatory=$false)]
    [switch]$DisableAuthentication
    
    ,[Parameter(Mandatory=$false)]
    [switch]$ClearExistingDatabase
    
    ,[Parameter(Mandatory=$false)]
    [switch]$DisableOnlineBackup

    ,[Parameter(Mandatory=$false)]
    [ValidateScript({$_ -match '^[\d]{1,3}\.[\d]{1,3}\.[\d]{1,3}\.[\d]{1,3}:([\d]+|[\d]+-[\d]+)$'})]  
    [string]$OnlineBackupServer = ''
  )
  
  Begin
  {
  }

  Process
  {
    # Get the Neo4j Server information
    if ($Neo4jServer -eq $null) { $Neo4jServer = '' }
    switch ($Neo4jServer.GetType().ToString())
    {
      'System.Management.Automation.PSCustomObject'
      {
        if (-not (Confirm-Neo4jServerObject -Neo4jServer $Neo4jServer))
        {
          Write-Error "The specified Neo4j Server object is not valid"
          return
        }
        $thisServer = $Neo4jServer
      }      
      default
      {
        $thisServer = Get-Neo4jServer -Neo4jHome $Neo4jServer
      }
    }
    if ($thisServer -eq $null) { return }

    if ( ($thisServer.ServerType -ne 'Enterprise') -and ($DisableOnlineBackup -or ($OnlineBackupServer -ne '') ) )
    {
      Throw "Neo4j Server type $($thisServer.ServerType) does not support online backup settings"
      return
    }
     
    $settings = @"
"ConfigurationFile","IsDefault","Name","Value","Neo4jHome"
"neo4j-server.properties","False","org.neo4j.server.webserver.port","$($HTTPPort)",""
"neo4j-server.properties","False","dbms.security.auth_enabled","$((-not $DisableAuthentication).ToString().ToLower())",""
"neo4j-server.properties","False","org.neo4j.server.webserver.https.enabled","$($EnableHTTPS.ToString().ToLower())",""
"neo4j-server.properties","False","org.neo4j.server.webserver.https.port","$($HTTPSPort)",""
"neo4j.properties","False","remote_shell_enabled","$($EnableRemoteShell.ToString().ToLower())",""
"neo4j.properties","False","remote_shell_port","$($RemoteShellPort)",""
"neo4j-server.properties","False","org.neo4j.server.webserver.address","$($ListenOnIPAddress)",""
"neo4j.properties","False","online_backup_enabled","$(-not $DisableOnlineBackup -and ($OnlineBackupServer -ne ''))",""
"neo4j.properties","False","online_backup_server","$($OnlineBackupServer)",""
"@ | ConvertFrom-CSV | `
      ForEach-Object -Process { $_.Neo4jHome = $thisServer.Home; if ($_.Value -ne '') { Write-Output $_} } | `
      Set-Neo4jSetting

    if ($ClearExistingDatabase)
    {
      $dbSetting = ($thisServer | Get-Neo4jSetting | ? { (($_.ConfigurationFile -eq 'neo4j-server.properties') -and ($_.Name -eq 'org.neo4j.server.database.location')) })
      $dbPath = Join-Path -Path $thisServer.Home -ChildPath $dbSetting.Value
      if (Test-Path -Path $dbPath) { Remove-Item -Path $dbPath -Recurse -Force }
    }

    if ($PassThru) { Write-Output $thisServer } else { Write-Output $settings }
  }
  
  End
  {
  }
}
