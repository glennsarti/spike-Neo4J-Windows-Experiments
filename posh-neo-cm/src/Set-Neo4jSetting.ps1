Function Set-Neo4jSetting
{
  [cmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Medium',DefaultParameterSetName='ByDefault')]
  param (
    [Parameter(Mandatory=$true,ValueFromPipeline=$true,ParameterSetName='ByHome')]
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName='BySettingObject')]
    [alias('Home')]
    [string]$Neo4jHome
    
    ,[Parameter(Mandatory=$true,ValueFromPipeline=$true,ParameterSetName='ByServerObject')]
    [PSCustomObject]$Neo4jServer

    ,[Parameter(Mandatory=$true,ParameterSetName='ByDefault')]
    [Parameter(Mandatory=$true,ParameterSetName='ByHome')]
    [Parameter(Mandatory=$true,ParameterSetName='ByServerObject')]
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName='BySettingObject')]
    [alias('File')]
    [string]$ConfigurationFile

    ,[Parameter(Mandatory=$true,ParameterSetName='ByDefault')]
    [Parameter(Mandatory=$true,ParameterSetName='ByHome')]
    [Parameter(Mandatory=$true,ParameterSetName='ByServerObject')]
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName='BySettingObject')]
    [alias('Setting')]
    [string]$Name

    ,[Parameter(Mandatory=$true,ParameterSetName='ByDefault')]
    [Parameter(Mandatory=$true,ParameterSetName='ByHome')]
    [Parameter(Mandatory=$true,ParameterSetName='ByServerObject')]
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName='BySettingObject')]
    [string]$Value
    
    # This parameter is used only for parameterset detection
    ,[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName='BySettingObject')]
    [string]$IsDefault

    ,[Parameter(Mandatory=$false)]
    [switch]$Force = $false
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
      "BySettingObject"
      {
        $Neo4jServer = Get-Neo4jServer -Neo4jHome $Neo4jHome
        if ($Neo4jServer -eq $null) { return }
      }
      default
      {
        Write-Error "Unknown Parameterset $($PsCmdlet.ParameterSetName)"
        return
      }
    }
    
    # Check if the configuration file exists
    $filePath = Join-Path -Path $Neo4jServer.Home -ChildPath "conf\$ConfigurationFile"
    if ( -not (Test-Path -Path $filePath))
    {
      if ($Force)
      {
        New-Item -Path $filePath -ItemType File | Out-Null
      }
      else
      {
        Write-Error "The specified configuration file does not exist"
        return
      }
    }
    
    # See if the setting is already defined
    $settingChanged = $false
    $settingFound = $false
    $newContent = (Get-Content -Path $filePath | ForEach-Object -Process `
    {
      $originalLine = $_
      $line = $originalLine
      $misc = $line.IndexOf('#')
      if ($misc -ge 0) { $line = $line.SubString(0,$misc) }
  
      # Get the server version from the name of the neo4j-server-<version>.jar file
      if ($matches -ne $null) { $matches.Clear() }
      if ($line -match "^$($Name)=(.+)`$")
      {
        $settingFound = $true
        if ($matches[1] -ne $Value)
        {
          $originalLine = "$($Name)=$($Value)"
          $settingChanged = $true
        }
      }
      Write-Output $originalLine
    })
    # Append it to the file if it didn't exist    
    if (-not $settingFound) { $newContent += "$($Name)=$($Value)"; $settingChanged = $true }
    
    # Modify the settings file if needed
    if ($settingChanged)
    {
      if ($PSCmdlet.ShouldProcess( ("Item: $($filePath) Setting: $($Name) Value: $($Value)", 'Write configuration file')))
      {  
        Set-Content -Path "$filePath" -Encoding ASCII -Value $newContent -Force:$Force -Confirm:$false | Out-Null
      }  
    }  

    $properties = @{
      'Name' = $Name;
      'Value' = $Value;
      'ConfigurationFile' = $ConfigurationFile;
      'IsDefault' = $false;
      'Neo4jHome' = $Neo4jServer.Home;
    }
    Write-Output (New-Object -TypeName PSCustomObject -Property $properties)
  }
  
  End
  {
  }
}
