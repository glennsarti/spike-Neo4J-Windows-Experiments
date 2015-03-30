Function Validate-Neo4jServerObject
{
  [cmdletBinding(SupportsShouldProcess=$false,ConfirmImpact='Low')]
  param (
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [PSCustomObject]$Neo4jServer
  )
  
  Begin
  {
  }

  Process
  {
    if ($Neo4jServer -eq $null) { return $false }
    
    if ($Neo4jServer.ServerVersion -eq $null) { return $false }
    if ($Neo4jServer.Home -eq $null) { return $false }
    if ($Neo4jServer.ServerType -eq $null) { return $false }
    
    if ( ($Neo4jServer.ServerType -ne 'Community') -and ($Neo4jServer.ServerType -ne 'Enterprise') ) { return $false }    
    if (-not (Test-Path -Path ($Neo4jServer.Home))) { return $false }
    
    return $true
  }
  
  End
  {
  }
}