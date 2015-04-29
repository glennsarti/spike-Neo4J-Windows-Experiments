Function Get-Java
{
  [cmdletBinding(SupportsShouldProcess=$false,ConfirmImpact='Low')]
  param (
    [Parameter(Mandatory=$false,ValueFromPipeline=$false)]
    [string[]]$ExtraClassPath = @()

    ,[Parameter(Mandatory=$true,ValueFromPipeline=$false)]
    [string]$BaseDir
  )
  
  Begin
  {
  }
  
  Process
  {
    $javaPath = ''
    $javaVersion = ''
    
    # Is JAVA specified in an environment variable
    if (($javaPath -eq '') -and ($Env:JAVA_HOME -ne $null))
    {
      $javaPath = $Env:JAVA_HOME
      if (Test-Path -Path "$javaPath\bin\javac.exe") { $javaPath = "$javaPath\jre" }
    }

    # Attempt to find Java in registry
    $regKey = 'Registry::HKLM\SOFTWARE\JavaSoft\Java Runtime Environment'    
    if (($javaPath -eq '') -and (Test-Path -Path $regKey))
    {
      $javaVersion = ''
      try
      {
        $javaVersion = [string](Get-ItemProperty -Path $regKey -ErrorAction 'Stop').CurrentVersion
        if ($javaVersion -ne '')
        {
          $javaPath = [string](Get-ItemProperty -Path "$regKey\$javaVersion" -ErrorAction 'Stop').JavaHome
        }
      }
      catch
      {
        #Ignore any errors
        $javaVersion = ''
        $javaPath = ''
      }
    }

    # Attempt to find Java in registry (32bit Java on 64bit OS)
    $regKey = 'Registry::HKLM\SOFTWARE\Wow6432Node\JavaSoft\Java Runtime Environment'    
    if (($javaPath -eq '') -and (Test-Path -Path $regKey))
    {
      $javaVersion = ''
      try
      {
        $javaVersion = [string](Get-ItemProperty -Path $regKey -ErrorAction 'Stop').CurrentVersion
        if ($javaVersion -ne '')
        {
          $javaPath = [string](Get-ItemProperty -Path "$regKey\$javaVersion" -ErrorAction 'Stop').JavaHome
        }
      }
      catch
      {
        #Ignore any errors
        $javaVersion = ''
        $javaPath = ''
      }
    }
    
    $javaCMD = "$javaPath\bin\java.exe"
    If (-not (Test-Path -Path $javaCMD)) { Throw "Found JAVAHOME but missing bin\java.exe"; return $null }

    # Get the commandline args
    $RepoPath = Join-Path  -Path $BaseDir -ChildPath 'lib'
    #  Get the default classpath jars
    $ClassPath = ''    
    Get-ChildItem -Path $RepoPath | Where-Object { $_.Extension -eq '.jar'} | % {
      $ClassPath += "`"$($_.FullName)`";"
    }
    #  Get the additional classpath jars
    $ExtraClassPath | ForEach-Object -Process { If (Test-Path -Path $_) { Write-Output $_} } | Get-ChildItem | Where-Object { $_.Extension -eq '.jar'} | % {
      $ClassPath += "`"$($_.FullName)`";"
    }
    
    
    if ($ClassPath.Length -gt 0) { $ClassPath = $ClassPath.SubString(0, $ClassPath.Length-1) } # Strip the trailing semicolon if needed    
    
    $ShellArgs = @()
    if ($Env:JAVA_OPTS -ne $null) { $ShellArgs += $Env:JAVA_OPTS }
    if ($Env:EXTRA_JVM_ARGUMENTS -ne $null) { $ShellArgs += $Env:EXTRA_JVM_ARGUMENTS }
    $ShellArgs += @("-classpath $($Env:CLASSPATH_PREFIX);$ClassPath","-Dapp.repo=`"$($RepoPath)`"","-Dbasedir=`"$($BaseDir)`"")

    Write-Output @{'java' = $javaCMD; 'args' = $ShellArgs}
  }
  
  End
  {
  }
}
