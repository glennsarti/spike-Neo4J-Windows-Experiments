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
  
      if ($matches -ne $null) { $matches.Clear() }
      if ($line -match '^([^=]+)=(.+)$')
      {
        $properties."$($matches[1].Trim())" = $matches[2].Trim()
      }
    }
    Write-Output $properties
  }
}
