Function Initialize-Neo4jHACluster
{
  [cmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High',DefaultParameterSetName='ByDefault')]
  param (
    [Parameter(Mandatory=$true,ValueFromPipeline=$true,ParameterSetName='ByHome')]
    [alias('Home')]
    [string]$Neo4jHome
    
    ,[Parameter(Mandatory=$true,ValueFromPipeline=$true,ParameterSetName='ByServerObject')]
    [PSCustomObject]$Neo4jServer

    ,[Parameter(Mandatory=$false)]
    [switch]$PassThru
    
    ,[Parameter(Mandatory=$true)]
    [ValidateRange(1,65535)]
    [int]$ServerID = 0

    ,[Parameter(Mandatory=$true)]
    [ValidateScript({$_ -match '^[\d\-:.]+$'})]  
    [string]$InitialHosts = ''

    ,[Parameter(Mandatory=$false)]
    [ValidateScript({$_ -match '^[\d]{1,3}\.[\d]{1,3}\.[\d]{1,3}\.[\d]{1,3}:([\d]+|[\d]+-[\d]+)$'})]  
    [string]$ClusterServer = ''

    ,[Parameter(Mandatory=$false)]
    [ValidateScript({$_ -match '^[\d]{1,3}\.[\d]{1,3}\.[\d]{1,3}\.[\d]{1,3}:([\d]+|[\d]+-[\d]+)$'})]  
    [string]$HAServer = ''
    
    ,[Parameter(Mandatory=$false)]
    [switch]$DisallowClusterInit
    
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
    
    if ($Neo4jServer.ServerType -ne 'Enterprise')
    {
      Throw "Neo4j Server type $($Neo4jServer.ServerType) does not support HA"
      return $null
    }

    $settings = @"
"ConfigurationFile","IsDefault","Name","Value","Neo4jHome"
"neo4j-server.properties","False","org.neo4j.server.database.mode","HA",""
"neo4j.properties","False","ha.server_id","$ServerID",""
"neo4j.properties","False","initial_hosts","$InitialHosts",""
"neo4j.properties","False","ha.cluster_server","$ClusterServer",""
"neo4j.properties","False","ha.server","$HAServer",""
"neo4j.properties","False","ha.allow_init_cluster","$(-not $DisallowClusterInit)",""
"@ | ConvertFrom-CSV | ForEach-Object -Process { $_.Neo4jHome = $Neo4jServer.Home; if ($_.Value -ne '') { Write-Output $_} } | Set-Neo4jSetting

    if ($PassThru) { Write-Output $Neo4jServer } else { Write-Output $settings }
  }
  
  End
  {
  }
}
