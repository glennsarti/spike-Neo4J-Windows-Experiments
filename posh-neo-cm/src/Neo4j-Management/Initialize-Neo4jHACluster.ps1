Function Initialize-Neo4jServer
{
  [cmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High',DefaultParameterSetName='ByDefault')]
  param (
    [Parameter(Mandatory=$true,ValueFromPipeline=$true,ParameterSetName='ByHome')]
    [alias('Home')]
    [string]$Neo4jHome
    
    ,[Parameter(Mandatory=$true,ValueFromPipeline=$true,ParameterSetName='ByServerObject')]
    [PSCustomObject]$Neo4jServer
  )
  
  Begin
  {
  }

  Process
  {
    switch ($PsCmdlet.ParameterSetName)
    {
      "ByDefault"
      {
        $Neo4jServer = Get-Neo4jServer
        if ($Neo4jServer -eq $null) { return }
      }
      "ByHome"
      {
        $Neo4jServer = Get-Neo4jServer -Neo4jHome $Neo4jHome
        if ($Neo4jServer -eq $null) { return }
      }
      "ByServerObject"
      {
        if (-not (Validate-Neo4jServerObject -Neo4jServer $Neo4jServer))
        {
          Write-Error "The specified Neo4j Server object is not valid"
          return
        }
      }
      default
      {
        Write-Error "Unknown Parameterset $($PsCmdlet.ParameterSetName)"
        return
      }
    }
    Throw "Not implemented yet"
# 
#     $defaultSettings = @"
# "ConfigurationFile","IsDefault","Name","Value","Neo4jHome"
# "neo4j-server.properties","False","org.neo4j.server.webserver.port","$($HTTPPort)",""
# "neo4j-server.properties","False","dbms.security.auth_enabled","$((-not $DisableAuthentication).ToString().ToLower())",""
# "neo4j-server.properties","False","org.neo4j.server.webserver.https.enabled","$($EnableHTTPS.ToString().ToLower())",""
# "neo4j-server.properties","False","org.neo4j.server.webserver.https.port","$($HTTPSPort)",""
# "neo4j.properties","False","remote_shell_enabled","$($EnableRemoteShell.ToString().ToLower())",""
# "neo4j.properties","False","remote_shell_port","$($RemoteShellPort)",""
# "neo4j-server.properties","False","org.neo4j.server.webserver.address","$($ListenOnIPAddress)",""
# "@ | ConvertFrom-CSV | ForEach-Object -Process { $_.Neo4jHome = $Neo4jServer.Home; Write-Output $_ } | Set-Neo4jSetting
  }
  
  End
  {
  }
}
