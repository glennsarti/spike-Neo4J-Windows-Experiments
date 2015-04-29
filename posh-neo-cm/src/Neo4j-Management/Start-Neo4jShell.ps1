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

    $JavaCMD = Get-Java -BaseDir $thisServer.Home -ErrorAction Stop
    if ($JavaCMD -eq $null)
    {
      Throw "Unable to locate Java"
      return
    }
    
    $ShellArgs = $JavaCMD.args
    $ShellArgs += @('-Dapp.name=neo4j-shell')
    $ShellArgs += @('org.neo4j.shell.StartClient')
    $ShellArgs += @('-host',"$ShellHost")
    $ShellArgs += @('-port',"$Port")
    # Add unbounded command line arguments
    if ($OtherArgs -ne $null) { $ShellArgs += $OtherArgs }

    $result = (Start-Process -FilePath $JavaCMD.java -ArgumentList $ShellArgs -Wait:$Wait -NoNewWindow:$Wait -PassThru)
    
    if ($PassThru) { Write-Output $thisServer } else { Write-Output $result.ExitCode }
  }
  
  End
  {
  }
}
