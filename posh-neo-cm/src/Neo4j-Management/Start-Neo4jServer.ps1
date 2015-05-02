Function Start-Neo4jServer
{
  [cmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low',DefaultParameterSetName='WindowsService')]
  param (
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [object]$Neo4jServer = ''

    ,[Parameter(Mandatory=$true,ParameterSetName='Console')]
    [switch]$Console

    ,[Parameter(Mandatory=$false)]
    [switch]$Wait

    ,[Parameter(Mandatory=$false)]
    [switch]$PassThru   
    
    ,[Parameter(Mandatory=$false,ParameterSetName='WindowsService')]
    [string]$ServiceName = ''
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
    
    $JavaCMD = Get-Java -BaseDir $thisServer.Home
    if ($JavaCMD -eq $null)
    {
      Throw "Unable to locate Java"
      return
    }

    if ($PsCmdlet.ParameterSetName -eq 'Console')
    {    
  
      $ShellArgs = @( `
        "-DworkingDir=`"$($thisServer.Home)`"" `
        ,"-Djava.util.logging.config.file=`"$($thisServer.Home)\conf\windows-wrapper-logging.properties`"" `
        ,"-DconfigFile=`"conf/neo4j-wrapper.conf`"" `
        ,"-DserverClasspath=`"lib/*.jar;system/lib/*.jar;plugins/**/*.jar;./conf*`"" `
        ,"-DserverMainClass=org.neo4j.server.Bootstrapper" `
        ,"-jar","$($thisServer.Home)\bin\windows-service-wrapper-5.jar"      
      )
      $result = (Start-Process -FilePath $JavaCMD.java -ArgumentList $ShellArgs -Wait:$Wait -NoNewWindow:$Wait -PassThru -WorkingDirectory $thisServer.Home )
      
      if ($PassThru) { Write-Output $thisServer } else { Write-Output $result.ExitCode }
    }
    
    if ($PsCmdlet.ParameterSetName -eq 'WindowsService')
    {
      if ($ServiceName -eq '')
      {
        $setting = ($thisServer | Get-Neo4jSetting -ConfigurationFile 'neo4j-wrapper.conf' -Name 'wrapper.name')
        if ($setting -ne $null) { $ServiceName = $setting.Value }
      }

      if ($ServiceName -eq '')
      {
        Throw "Could not find the Windows Service Name for Neo4j"
        return
      }

      $result = Start-Service -Name $ServiceName
      if ($PassThru) { Write-Output $thisServer } else { Write-Output $result }
    }
  }
  
  End
  {
  }
}
