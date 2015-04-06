$DebugPreference = "SilentlyContinue"

$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$src = Join-Path (Split-Path $here) 'src'

Function Get-MockNeo4jInstall() {
  return "TestDrive:\Neo4j-home"
}

Function New-MockNeo4jInstall($neoVersion = '99.99', [switch]$IsCommunityServer, [switch]$IsEnterpriseServer) {
  $rootDir = "TestDrive:\Neo4j-home"
    
  if (Test-Path -Path $rootDir) { Remove-Item -Path $rootDir -Recurse -Force -Confirm:$false | Out-Null }
  
  # Create the directory structure
  New-Item $rootDir -ItemType Directory | Out-Null
  New-Item "$rootDir\conf" -ItemType Directory | Out-Null
  New-Item "$rootDir\system\lib" -ItemType Directory | Out-Null
  
  # Create the files
  if ($IsCommunityServer -or $IsEnterpriseServer) { "TestFile" | Set-Content -Path "$rootDir\system\lib\neo4j-server-$neoVersion.jar" | Out-Null }
  if ($IsEnterpriseServer) { "TestFile" | Set-Content -Path "$rootDir\system\lib\neo4j-server-enterprise-$neoVersion.jar" | Out-Null }

  # Create a mock neo4j.properties file
  @"
################################################################
# Neo4j
#
# neo4j.properties - database tuning parameters
#
################################################################

setting1=value1
setting2=value2
#setting3=value3
"@ | Out-File -FilePath "$rootDir\conf\neo4j.properties" -Encoding ASCII -Force -Confirm:$false


    
  #Write-Host (dir $rootDir -recurse) -Foreground Cyan
}

Function Clear-Neo4jEnvVar() {
  # TODO Should save the state first
  [Environment]::SetEnvironmentVariable("NEO4J_HOME", "", "Machine")
  [Environment]::SetEnvironmentVariable("NEO4J_HOME", "", "User")
  [Environment]::SetEnvironmentVariable("NEO4J_HOME", "", "Process")
}

Function Restore-Neo4jEnvVar() {
}
