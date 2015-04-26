Function Get-Neo4jSetting
{
  [cmdletBinding(SupportsShouldProcess=$false,ConfirmImpact='Low')]
  param (
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [object]$Neo4jServer = ''
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
   
    $ConfiguredSettings = ""
   
    'neo4j.properties','neo4j-server.properties','neo4j-wrapper.conf' | ForEach-Object -Process `
    {
      $filename = $_
      $filePath = Join-Path -Path $thisServer.Home -ChildPath "conf\$filename"
      if (Test-Path -Path $filePath)
      {
        $keyPairsFromFile = Get-KeyValuePairsFromConfFile -filename $filePath        
      }
      else
      {
        $keyPairsFromFile = $null
      }
      
      if ($keyPairsFromFile -ne $null)
      {
        $keyPairsFromFile.GetEnumerator() | ForEach-Object -Process `
        {
          $properties = @{
            'Name' = $_.Name;
            'Value' = $_.Value;
            'ConfigurationFile' = $filename;
            'IsDefault' = $false;
            'Neo4jHome' = $thisServer.Home;
          }
          Write-Output (New-Object -TypeName PSCustomObject -Property $properties)
          $ConfiguredSettings = $ConfiguredSettings + "|$($filename);$($_.Name)"
        }
      }
    }
    
    $defaultsXML = Join-Path -Path $PSScriptRoot -ChildPath 'neo4j-default-settings.xml'
    if (Test-Path -Path $defaultsXML)
    {
      $defaultsXML = [xml](Get-Content -Path $defaultsXML)
      
      $defaultsXML.selectNodes('/defaults/section') | ForEach-Object -Process `
      {
        $node = $_
        $processSection = $true
        if ( ($node.versionregex -ne $null) -and ($processSection) )
        {
          $processSection = ( $thisServer.ServerVersion -match ([string]$node.versionregex) )
        }
        if ( ($node.editionregex -ne $null) -and ($processSection) )
        {
          $processSection = ( $thisServer.ServerType -match ([string]$node.editionregex) )
        }
        
        if ( $processSection )
        {
          $node.selectNodes("setting") | ForEach-Object -Process `
          {
            $properties = @{
              'Name' = $_.name;
              'Value' = $_."#text";
              'ConfigurationFile' = $_.file;
              'IsDefault' = $true;
              'Neo4jHome' = $thisServer.Home;
            }
            # Only emit the default value if it was not configured
            $hash = "|$($_.file);$($_.name)"
            if ($ConfiguredSettings.IndexOf($hash) -eq -1) { Write-Output (New-Object -TypeName PSCustomObject -Property $properties) }
          }
        }
      }
      
    }
  }
  
  End
  {
  }
}
