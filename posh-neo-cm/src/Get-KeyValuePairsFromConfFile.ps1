Function Get-KeyValuePairsFromConfFile
{
  [cmdletBinding(SupportsShouldProcess=$false,ConfirmImpact='Low')]
  param (
    [Parameter(Mandatory=$true,ValueFromPipeline=$false)]
    [string]$Filename
    
    #,[Parameter(Mandatory=$false,ValueFromPipeline=$false)]
    #[string]$Filter = ''
  )

 Process
 {
    $properties = @{}
    Get-Content -Path $filename -Filter $Filter | ForEach-Object -Process `
    {
      $line = $_
      $misc = $line.IndexOf('#')
      if ($misc -ge 0) { $line = $line.SubString(0,$misc) }
  
      # Get the server version from the name of the neo4j-server-<version>.jar file
      if ($matches -ne $null) { $matches.Clear() }
      if ($line -match '^([^=]+)=(.+)$')
      {
        $properties."$($matches[1])" = $matches[2]
      }
    }
    Write-Output $properties
  }
}