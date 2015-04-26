Function Initialize-Neo4jHACluster
{
  [cmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
  param (
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [object]$Neo4jServer = ''

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
    
    if ($thisServer.ServerType -ne 'Enterprise')
    {
      Throw "Neo4j Server type $($thisServer.ServerType) does not support HA"
      return $null
    }

    $settings = @"
"ConfigurationFile","IsDefault","Name","Value","Neo4jHome"
"neo4j-server.properties","False","org.neo4j.server.database.mode","HA",""
"neo4j.properties","False","ha.server_id","$ServerID",""
"neo4j.properties","False","ha.initial_hosts","$InitialHosts",""
"neo4j.properties","False","ha.cluster_server","$ClusterServer",""
"neo4j.properties","False","ha.server","$HAServer",""
"neo4j.properties","False","ha.allow_init_cluster","$(-not $DisallowClusterInit)",""
"@ | ConvertFrom-CSV | ForEach-Object -Process { $_.Neo4jHome = $thisServer.Home; if ($_.Value -ne '') { Write-Output $_} } | Set-Neo4jSetting

    if ($PassThru) { Write-Output $thisServer } else { Write-Output $settings }
  }
  
  End
  {
  }
}
