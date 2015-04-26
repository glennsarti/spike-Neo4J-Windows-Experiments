Function Start-Neo4jShell
{
  [cmdletBinding(SupportsShouldProcess=$false,ConfirmImpact='Low')]
  param (
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [object]$Neo4jServer = ''
    
    ,[Parameter(Mandatory=$false,ValueFromPipeline=$false)]
    [string]$UseHost = ''

    ,[Parameter(Mandatory=$false,ValueFromPipeline=$false)]
    [Alias('ShellPort')]
    [ValidateRange(0,65535)]
    [int]$UsePort = -1
    
    ,[Parameter(Mandatory=$false)]
    [switch]$Wait

    ,[Parameter(Mandatory=$false)]
    [switch]$PassThru   
    
    ,[Parameter(ValueFromRemainingArguments = $true)]
    [Object[]]$OtherArgs
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

    $ShellRemoteEnabled = $false
    $ShellHost = '127.0.0.1'
    $Port = 1337    
    Get-Neo4jSetting -Neo4jServer $thisServer | ForEach-Object -Process `
    {
      if (($_.ConfigurationFile -eq 'neo4j.properties') -and ($_.Name -eq 'remote_shell_enabled')) { $ShellRemoteEnabled = ($_.Value.ToUpper() -eq 'TRUE') }
      if (($_.ConfigurationFile -eq 'neo4j.properties') -and ($_.Name -eq 'remote_shell_host')) { $ShellHost = ($_.Value) }
      if (($_.ConfigurationFile -eq 'neo4j.properties') -and ($_.Name -eq 'remote_shell_port')) { $Port = [int]($_.Value) }
    }
    if (!$ShellRemoteEnabled) { $ShellHost = 'localhost' }
    if ($UseHost -ne '') { $ShellHost = $UseHost }
    if ($UsePort -ne -1) { $Port = $UsePort }
    
    
    $JavaCMD = 'java'
    $RepoPath = Join-Path  -Path $thisServer.Home -ChildPath 'lib'
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
    
    if ($PassThru) { Write-Output $thisServer } else { Write-Output $result }
  }
  
  End
  {
  }
}
