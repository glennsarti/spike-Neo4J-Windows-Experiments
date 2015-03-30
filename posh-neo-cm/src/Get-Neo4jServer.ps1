Function Get-Neo4jServer
{
  [cmdletBinding(SupportsShouldProcess=$false,ConfirmImpact='Low')]
  param (
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [alias('Home')]
    [AllowEmptyString()]
    [string]$Neo4jHome = ''
  )
  
  Begin
  {
  }
  
  Process
  {
    # Get and check the Neo4j Home directory
    if ($Neo4jHome -eq '') { $Neo4jHome = Get-Neo4jHome }
    if ( ($Neo4jHome -eq '') -or ($Neo4jHome -eq $null) )
    {
      Write-Error "Could not detect the Neo4j Home directory"
      return
    }
    if (-not (Validate-Neo4jHome -Neo4jHome $Neo4jHome))
    {
      Write-Error "$Neo4jHome is not a Neo4j Home directory"
      return
    }
    
    # Get the information about the server
    $serverProperties = @{
      'Home' = $Neo4jHome;
      'ServerVersion' = '';
      'ServerType' = 'Community';
    }
    Get-ChildItem (Join-Path -Path $Neo4jHome -ChildPath 'system\lib') | Where-Object { $_.Name -like 'neo4j-server-*.jar' } | ForEach-Object -Process `
    {
      # if neo4j-server-enterprise-<version>.jar exists then this is the enterprise version
      if ($_.Name -like 'neo4j-server-enterprise-*.jar') { $serverProperties.ServerType = 'Enterprise' }
      
      # Get the server version from the name of the neo4j-server-<version>.jar file
      if ($matches -ne $null) { $matches.Clear() }
      if ($_.Name -match '^neo4j-server-([\d.\-MRC]+)\.jar$') { $serverProperties.ServerVersion = $matches[1] }
    }
    
    $serverObject = New-Object -TypeName PSCustomObject -Property $serverProperties
    if (-not (Validate-Neo4jServerObject -Neo4jServer $serverObject))
    {
      Write-Error "$Neo4jHome does not contain a valid Neo4j installation"
      return
    }

    Write-Output $serverObject
  }
  
  End
  {
  }
}