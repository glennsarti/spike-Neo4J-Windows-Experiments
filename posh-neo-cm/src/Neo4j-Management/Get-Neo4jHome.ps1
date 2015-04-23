Function Get-Neo4jHome
{
  [cmdletBinding(SupportsShouldProcess=$false,ConfirmImpact='Low')]
  param ()
  
  Begin
  {
  }
  
  Process
  {
    $path = $Env:NEO4J_HOME
    if ($path -ne $null)
    {
      if (Test-Path -Path $path) { Write-Output $path }
    }
  }
  
  End
  {
  }
}