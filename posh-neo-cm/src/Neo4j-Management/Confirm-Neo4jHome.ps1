Function Confirm-Neo4jHome 
{
  [cmdletBinding(SupportsShouldProcess=$false,ConfirmImpact='Low')]
  param (
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [alias('Home')]
    [string]$Neo4jHome = ''
  )
  
  Begin
  {
  }

  Process
  {
    if ( ($Neo4jHome -eq '') -or ($Neo4jHome -eq $null) ) { return $false }
    if (-not (Test-Path -Path $Neo4jHome)) { return $false }
    
    # TODO Add test to see if this really is a Neo install
    
    return $true
  }
  
  End
  {
  }
}
