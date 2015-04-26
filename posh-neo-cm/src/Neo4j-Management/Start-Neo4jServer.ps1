Function Start-Neo4jServer
{
  [cmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Low')]
  param (
    [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
    [object]$Neo4jServer = ''

    ,[Parameter(Mandatory=$true,ParameterSetName='Console')]
    [switch]$Console

    ,[Parameter(Mandatory=$false)]
    [switch]$Wait

    ,[Parameter(Mandatory=$false)]
    [switch]$PassThru   
    
    ,[Parameter(Mandatory=$true,ParameterSetName='WindowsService')]
    [switch]$Service
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
    
    if ($PsCmdlet.ParameterSetName -eq 'Console')
    {    
      $JavaCMD = 'java'
  
      $ShellArgs = @( `
        "-DworkingDir=`"$($thisServer.Home)`"" `
        ,"-Djava.util.logging.config.file=`"$($thisServer.Home)\conf\windows-wrapper-logging.properties`"" `
        ,"-DconfigFile=`"conf/neo4j-wrapper.conf`"" `
        ,"-DserverClasspath=`"lib/*.jar;system/lib/*.jar;plugins/**/*.jar;./conf*`"" `
        ,"-DserverMainClass=org.neo4j.server.Bootstrapper" `
        ,"-jar","$($thisServer.Home)\bin\windows-service-wrapper-5.jar"      
      )
      $result = (Start-Process -FilePath $JavaCMD -ArgumentList $ShellArgs -Wait:$Wait -NoNewWindow:$Wait -PassThru -WorkingDirectory $thisServer.Home )
      
      if ($PassThru) { Write-Output $thisServer } else { Write-Output $result }
    }
    
    if ($PsCmdlet.ParameterSetName -eq 'WindowsService')
    {
      # TODO
      Throw 'Not Implemented'
      return $null
    }
  }
  
  End
  {
  }
}
