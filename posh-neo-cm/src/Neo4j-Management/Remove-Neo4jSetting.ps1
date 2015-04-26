Function Remove-Neo4jSetting
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

    ,[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName='BySettingObject')]
    [AllowNull()]
    [AllowEmptyString()]
    [string]$Value = ''
  )
  
  Begin
  {
  }

  Process
  {
    Throw "Not Implemented" # NEed to change all this to the single parameterset model
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
        if (-not (Confirm-Neo4jServerObject -Neo4jServer $Neo4jServer))
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
    if (Test-Path -Path $filePath)
    {
      # Find the setting
      $settingFound = $false
      $newContent = (Get-Content -Path $filePath | ForEach-Object -Process `
      {
        $originalLine = $_
        $line = $originalLine
        $misc = $line.IndexOf('#')
        if ($misc -ge 0) { $line = $line.SubString(0,$misc) }
    
        if ($matches -ne $null) { $matches.Clear() }
        if ($line -match "^$($Name)=(.+)`$")
        {
          $settingFound = $true
        }
        else
        {
          Write-Output $originalLine
        }
      })
      # Modify the settings file if needed
      if ($settingFound)
      {
        if ($PSCmdlet.ShouldProcess( ("Item: $($filePath) Setting: $($Name)", 'Write configuration file')))
        {  
          Set-Content -Path "$filePath" -Encoding ASCII -Value $newContent -Force:$Force -Confirm:$false | Out-Null
        }  
      }  
    }  

    $properties = @{
      'Name' = $Name;
      'Value' = $null;
      'ConfigurationFile' = $ConfigurationFile;
      'IsDefault' = $true;
      'Neo4jHome' = $Neo4jServer.Home;
    }
    Write-Output (New-Object -TypeName PSCustomObject -Property $properties)
  }
  
  End
  {
  }
}
