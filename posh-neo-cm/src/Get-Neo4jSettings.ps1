Function Get-Neo4jSettings
{
  [cmdletBinding(SupportsShouldProcess=$false,ConfirmImpact='Low',DefaultParameterSetName='ByDefault')]
  param (
    [Parameter(Mandatory=$true,ValueFromPipeline=$true,ParameterSetName='ByHome')]
    [alias('Home')]
    [string]$Neo4jHome
    
    ,[Parameter(Mandatory=$true,ValueFromPipeline=$true,ParameterSetName='ByServerObject')]
    [PSCustomObject]$Neo4jServer
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
   
     $ConfiguredSettings = ""
   
    'neo4j.properties','neo4j-server.properties','neo4j-wrapper.conf' | ForEach-Object -Process `
    {
      $filename = $_
      $filePath = Join-Path -Path $Neo4jServer.Home -ChildPath "conf\$filename"
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
            'Neo4jHome' = $Neo4jServer.Home;
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
          $processSection = ( $Neo4jServer.ServerVersion -match ([string]$node.versionregex) )
        }
        if ( ($node.editionregex -ne $null) -and ($processSection) )
        {
          $processSection = ( $Neo4jServer.ServerType -match ([string]$node.editionregex) )
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
              'Neo4jHome' = $Neo4jServer.Home;
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
