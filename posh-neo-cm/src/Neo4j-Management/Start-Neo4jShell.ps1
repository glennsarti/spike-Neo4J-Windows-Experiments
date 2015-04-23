Function Start-Neo4jShell
{
  [cmdletBinding(SupportsShouldProcess=$false,ConfirmImpact='Low',DefaultParameterSetName='ByDefault')]
  param (
    [Parameter(Mandatory=$true,ValueFromPipeline=$true,ParameterSetName='ByHome')]
    [alias('Home')]
    [string]$Neo4jHome
    
    ,[Parameter(Mandatory=$true,ValueFromPipeline=$true,ParameterSetName='ByServerObject')]
    [PSCustomObject]$Neo4jServer

    ,[Parameter(Mandatory=$false,ValueFromPipeline=$false)]
    [string]$UseHost = ''

    ,[Parameter(Mandatory=$false,ValueFromPipeline=$false)]
    [Alias('ShellPort')]
    [ValidateRange(0,65535)]
    [int]$UsePort = -1
    
    ,[Parameter(Mandatory=$false)]
    [switch]$Wait
    
    ,[Parameter(ValueFromRemainingArguments = $true)]
    [Object[]]$OtherArgs
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

    $ShellRemoteEnabled = $false
    $ShellHost = '127.0.0.1'
    $Port = 1337    
    Get-Neo4jSetting -Neo4jServer $Neo4jServer | ForEach-Object -Process `
    {
      if (($_.ConfigurationFile -eq 'neo4j.properties') -and ($_.Name -eq 'remote_shell_enabled')) { $ShellRemoteEnabled = ($_.Value.ToUpper() -eq 'TRUE') }
      if (($_.ConfigurationFile -eq 'neo4j.properties') -and ($_.Name -eq 'remote_shell_host')) { $ShellHost = ($_.Value) }
      if (($_.ConfigurationFile -eq 'neo4j.properties') -and ($_.Name -eq 'remote_shell_port')) { $Port = [int]($_.Value) }
    }
    if (!$ShellRemoteEnabled) { $ShellHost = 'localhost' }
    if ($UseHost -ne '') { $ShellHost = $UseHost }
    if ($UsePort -ne -1) { $Port = $UsePort }
    
    
    $JavaCMD = 'java'
    $RepoPath = Join-Path  -Path $Neo4jServer.Home -ChildPath 'lib'
    $ClassPath = ''    
    Get-ChildItem -Path $RepoPath | ? { $_.Extension -eq '.jar'} | % {
      $ClassPath += "`"$($_.FullName)`";"
    }
    if ($ClassPath.Length -gt 0) { $ClassPath = $ClassPath.SubString(0, $ClassPath.Length-1) } # Strip the trailing semicolon if needed    
    $ShellArgs = @()
    if ($Env:JAVA_OPTS -ne $null) { $ShellArgs += $Env:JAVA_OPTS }
    if ($Env:EXTRA_JVM_ARGUMENTS -ne $null) { $ShellArgs += $Env:EXTRA_JVM_ARGUMENTS }
    $ShellArgs += @("-classpath $($Env:CLASSPATH_PREFIX);$ClassPath","-Dapp.name=`"neo4j-shell`"","-Dapp.repo=`"$($RepoPath)`"","-Dbasedir=`"$($Neo4jServer.Home)`"","org.neo4j.shell.StartClient")
    $ShellArgs += @('-host',"$ShellHost")
    $ShellArgs += @('-port',"$Port")
    # Add unbounded command line arguments
    if ($OtherArgs -ne $null) { $ShellArgs += $OtherArgs }

    $result = (Start-Process -FilePath $JavaCMD -ArgumentList $ShellArgs -Wait:$Wait -NoNewWindow:$Wait -PassThru)
    
    Write-Output $Neo4jServer
  }
  
  End
  {
  }
}
