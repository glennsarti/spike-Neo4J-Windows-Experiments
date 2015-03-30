Function Get-Neo4jProperties
{
  [cmdletBinding(SupportsShouldProcess=$false,ConfirmImpact='Low')]
  param (
    [Parameter(Mandatory=$true,ValueFromPipeline=$true,ParameterSetName='ByHome')]
    [alias('Home')]
    [string]$Neo4jHome
    
    ,[Parameter(Mandatory=$true,ValueFromPipeline=$true,ParameterSetName='ByServerObject')]
    [PSCustomObject]$Neo4jServer

    #,[Parameter(Mandatory=$false,ValueFromPipeline=$false)]
    #[string]$Filter = ''
  )
  
  Begin
  {
  }

  Process
  {
    switch ($PsCmdlet.ParameterSetName)
    {
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
    } 
   
   
    'neo4j.properties','neo4j-server.properties','neo4j-wrapper.conf' | ForEach-Object -Process `
    {
      $filename = $_
      $filePath = Join-Path -Path $Neo4jServer.Home -ChildPath "conf\$filename"
      $keyPairsFromFile = Get-KeyValuePairsFromConfFile -filename $filePath
      
      if ($keyPairsFromFile -ne $null)
      {
        $keyPairsFromFile.GetEnumerator() | ForEach-Object -Process `
        {
          $properties = @{
            'Name' = $_.Name;
            'Value' = $_.Value;
            'ConfigurationFile' = $filename;
            'IsDefault' = $false
          }
          Write-Output (New-Object -TypeName PSCustomObject -Property $properties)
        }
      }
    }
  }
  
  End
  {
  }
}
