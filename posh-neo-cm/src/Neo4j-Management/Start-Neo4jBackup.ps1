Function Start-Neo4jBackup
{
  [cmdletBinding(SupportsShouldProcess=$false,ConfirmImpact='Low')]
  param (
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [object]$Neo4jServer = ''
    
    ,[Parameter(Mandatory=$false,ValueFromPipeline=$false)]
    [Alias('Host')]
    [string]$UseHost = ''

    ,[Parameter(Mandatory=$false,ValueFromPipeline=$false)]
    [Alias('Port')]
    [ValidateRange(0,65535)]
    [int]$UsePort = -1

    ,[Parameter(Mandatory=$true,ValueFromPipeline=$false)]
    [string]$To = ''

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

    if ($thisServer.ServerType -ne 'Enterprise')
    {
      Throw "Neo4j Server type $($thisServer.ServerType) does not support online backup"
      return
    }

    # Get the online backup settings
    $BackupEnabled = $false
    $BackupHost = '127.0.0.1:6362'
    Get-Neo4jSetting -Neo4jServer $thisServer | ForEach-Object -Process `
    {
      if (($_.ConfigurationFile -eq 'neo4j.properties') -and ($_.Name -eq 'online_backup_enabled')) { $BackupEnabled = ($_.Value.ToUpper() -eq 'TRUE') }
      if (($_.ConfigurationFile -eq 'neo4j.properties') -and ($_.Name -eq 'online_backup_server')) { $BackupHost = ($_.Value) }
    }
    if (($UseHost -ne '') -and ($UserPort -ne -1))
    {
      $BackupHost = "$($UseHost):$(UsePort)"
      $BackupEnabled = $true
    }
    if (!$BackupEnabled)
    {
      throw "Online Backup Server is not enabled"
      return
    }
    
    if ($matches -ne $null) { $matches.Clear() }
    if ($BackupHost -match '^([\d]{1,3}\.[\d]{1,3}\.[\d]{1,3}\.[\d]{1,3}):([\d]+|[\d]+-[\d]+)$')
    {
      $serverHost = $matches[1]
      $serverport = $matches[2]
    }
    else
    {
      Throw "$BackupHost is an invalid Backup Server address"
      return
    }

    # Get Java
    $JavaCMD = Get-Java -BaseDir $thisServer.Home -ExtraClassPath (Join-Path -Path $thisServer.Home -ChildPath 'system\coordinator\lib')  -ErrorAction Stop
    if ($JavaCMD -eq $null)
    {
      Throw "Unable to locate Java"
      return
    }
    
    $ShellArgs = $JavaCMD.args
    $ShellArgs += @('-Dapp.name=neo4j-backup')
    $ShellArgs += @('org.neo4j.backup.BackupTool')
    $ShellArgs += @('-host',"$serverHost")
    $ShellArgs += @('-port',"$serverport")
    $ShellArgs += @('-to',"$To")    
    # Add unbounded command line arguments
    if ($OtherArgs -ne $null) { $ShellArgs += $OtherArgs }

    $result = (Start-Process -FilePath $JavaCMD.java -ArgumentList $ShellArgs -Wait:$Wait -NoNewWindow:$Wait -PassThru)
    
    if ($PassThru) { Write-Output $thisServer } else { Write-Output $result.ExitCode }
  }
  
  End
  {
  }
}
