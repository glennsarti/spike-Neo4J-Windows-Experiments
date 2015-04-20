Function Get-KeyValuePairsFromConfFile
{
  [cmdletBinding(SupportsShouldProcess=$false,ConfirmImpact='Low')]
  param (
    [Parameter(Mandatory=$true,ValueFromPipeline=$false)]
    [string]$Filename
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
        $keyName = $matches[1].Trim()
        if ($properties.Contains($keyName))
        {
          # There is already a property with this name so it must by a collection of properties.  Turn the value into an array and add it
          if (($properties."$keyName").GetType().ToString() -eq 'System.String') { $properties."$keyName" = [string[]]@($properties."$keyName") }
          $properties."$keyName" = $properties."$keyName" + $matches[2].Trim()
        }
        else
        {
          $properties."$keyName" = $matches[2].Trim()
        }        
      }
    }
    Write-Output $properties
  }
}
