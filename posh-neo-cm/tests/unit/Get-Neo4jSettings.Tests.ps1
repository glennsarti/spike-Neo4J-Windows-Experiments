$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
$common = Join-Path (Split-Path -Parent $here) 'Common.ps1'
. $common
. "$src\$sut"

# Fake functions.  You can only mock functions which already exist
function Get-Neo4jServer() { throw "Not Implemented1" }
function Validate-Neo4jServerObject() { throw "Not Implemented2" }
function Get-KeyValuePairsFromConfFile() { Write-Host $args[1]; throw "Not Implemented3" }

Describe "Get-Neo4jSettings" {

  Context "Invalid or missing default neo4j installation" {
    Mock Get-Neo4jServer { return $null }
    $result = Get-Neo4jSettings

    It "return null if missing default" {
      $result | Should BeNullOrEmpty      
    }
    It "calls Get-Neo4Server" {
      Assert-MockCalled Get-Neo4jServer -Times 1
    }
  }

  Context "Invalid or missing specified neo4j installation" {
    Mock Get-Neo4jServer { return $null } -ParameterFilter { $Neo4jHome -eq 'TestDrive:\some-dir-that-doesnt-exist' }
    $result = Get-Neo4jSettings -Neo4jHome 'TestDrive:\some-dir-that-doesnt-exist'

    It "return null if invalid directory" {
      $result | Should BeNullOrEmpty      
    }
    It "calls Get-Neo4Server" {
      Assert-MockCalled Get-Neo4jServer -Times 1
    }
  }

  Context "Invalid or missing server object" {
    Mock Validate-Neo4jServerObject { return $null }
    
    It "throws error for an invalid server object" {
      { Get-Neo4jSettings -Neo4jServer (New-Object -TypeName PSCustomObject) -ErrorAction Stop } | Should Throw
    }

    It "calls Validate-Neo4jServerObject" {
      Assert-MockCalled Validate-Neo4jServerObject -Times 1
    }
  }
  
  Context "Missing configuration file" {
    Mock Get-Neo4jServer { return New-Object -TypeName PSCustomObject -Property (@{'Home' = 'TestDrive:\FakeDir'; 'ServerVersion' = '99.99'; 'ServerType' = 'Community'; }) }  
    Mock Test-Path { return $true } -ParameterFilter { $Path.EndsWith('neo4j.properties') }
    Mock Test-Path { return $true } -ParameterFilter { $Path.EndsWith('neo4j-server.properties') }
    Mock Test-Path { return $false } -ParameterFilter { $Path.EndsWith('neo4j-wrapper.conf') }
    Mock Get-KeyValuePairsFromConfFile { return @{ "setting1"="value1"; } } -ParameterFilter { $Filename.EndsWith('neo4j.properties') }
    Mock Get-KeyValuePairsFromConfFile { return @{ "setting2"="value2"; } } -ParameterFilter { $Filename.EndsWith('neo4j-server.properties') }
    Mock Get-KeyValuePairsFromConfFile { throw 'missing file' }             -ParameterFilter { $Filename.EndsWith('neo4j-wrapper.conf') }
    
    $result = Get-Neo4jSettings
    
    It "ignore the missing file" {
      $result.Count | Should Be 2
    } 
  }

  Context "Simple configuration settings" {
    Mock Get-Neo4jServer { return New-Object -TypeName PSCustomObject -Property (@{'Home' = 'TestDrive:\FakeDir'; 'ServerVersion' = '99.99'; 'ServerType' = 'Community'; }) }  
    Mock Test-Path { return $true }
    Mock Get-KeyValuePairsFromConfFile { return @{ "setting1"="value1"; } } -ParameterFilter { $Filename.EndsWith('neo4j.properties') }
    Mock Get-KeyValuePairsFromConfFile { return @{ "setting2"="value2"; } } -ParameterFilter { $Filename.EndsWith('neo4j-server.properties') }
    Mock Get-KeyValuePairsFromConfFile { return @{ "setting3"="value3"; } } -ParameterFilter { $Filename.EndsWith('neo4j-wrapper.conf') }
    
    $result = Get-Neo4jSettings
    
    It "one setting per file" {
      $result.Count | Should Be 3
    } 

    # Parse the results and make sure the expected results are there
    $unknownSetting = $false
    $neo4jProperties = $false
    $neo4jServerProperties = $false
    $neo4jWrapper = $false
    $result | ForEach-Object -Process {
      $setting = $_
      switch ($setting.Name) {
        'setting1' { $neo4jProperties =       ($setting.ConfigurationFile -eq 'neo4j.properties') -and ($setting.IsDefault -eq $false) -and ($setting.Value -eq 'value1') }
        'setting2' { $neo4jServerProperties = ($setting.ConfigurationFile -eq 'neo4j-server.properties') -and ($setting.IsDefault -eq $false) -and ($setting.Value -eq 'value2') }
        'setting3' { $neo4jWrapper =          ($setting.ConfigurationFile -eq 'neo4j-wrapper.conf') -and ($setting.IsDefault -eq $false) -and ($setting.Value -eq 'value3') }
        default { $unknownSetting = $true}
      }
    }

    It "returns settings for file neo4j.properties" {
      $neo4jProperties | Should Be $true
    } 
    It "returns settings for file neo4j-server.properties" {
      $neo4jServerProperties | Should Be $true
    } 
    It "returns settings for file neo4j-wrapper.conf" {
      $neo4jWrapper | Should Be $true
    } 

    It "returns no unknown settings" {
      $unknownSetting | Should Be $false
    } 
  }
}