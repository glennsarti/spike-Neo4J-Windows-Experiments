$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
$common = Join-Path (Split-Path -Parent $here) 'Common.ps1'
. $common
. "$src\$sut"

# Fake functions.  You can only mock functions which already exist
function Get-Neo4jServer() { throw "Not Implemented" }
function Validate-Neo4jServerObject() { throw "Not Implemented" }
function Set-Neo4jSetting() { throw "Not Implemented" }

Describe "Initialize-Neo4jServer" {

  Context "Invalid or missing default neo4j installation" {
    Mock Get-Neo4jServer { return $null }
    $result = Initialize-Neo4jServer 

    It "return null if missing default" {
      $result | Should BeNullOrEmpty      
    }
    It "calls Get-Neo4Server" {
      Assert-MockCalled Get-Neo4jServer -Times 1
    }
  }

  Context "Invalid or missing specified neo4j installation" {
    Mock Get-Neo4jServer { return $null } -ParameterFilter { $Neo4jHome -eq 'TestDrive:\some-dir-that-doesnt-exist' }
    $result = Initialize-Neo4jServer -Neo4jHome 'TestDrive:\some-dir-that-doesnt-exist'

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
      { Initialize-Neo4jServer -Neo4jServer (New-Object -TypeName PSCustomObject) -ErrorAction Stop } | Should Throw
    }

    It "calls Validate-Neo4jServerObject" {
      Assert-MockCalled Validate-Neo4jServerObject -Times 1
    }
  }

  Context "All default settings" {
    Mock Get-Neo4jServer { return New-Object -TypeName PSCustomObject -Property (@{'Home' = 'TestDrive:\FakeDir'; 'ServerVersion' = '99.99'; 'ServerType' = 'Community'; }) }
    Mock Set-Neo4jSetting { Write-Output (New-Object -TypeName PSCustomObject -Property (@{'Value' = 'Something'; })) }
    
    $result = Initialize-Neo4jServer
    It "returns at least one configuration setting" {
      ($result.Count -gt 0) | Should Be $true
    }
    It "attempts to write settings" {
      Assert-MockCalled Set-Neo4jSetting
    }
  }

  Context "ListenOnIPAddress Parameter" {
    Mock Get-Neo4jServer { return New-Object -TypeName PSCustomObject -Property (@{'Home' = 'TestDrive:\FakeDir'; 'ServerVersion' = '99.99'; 'ServerType' = 'Community'; }) }
    Mock Set-Neo4jSetting { Write-Output (New-Object -TypeName PSCustomObject -Property (@{'Value' = 'Something'; })) }
    
    It "should throw for bad IP (Alpha chars)" {
      { Initialize-Neo4jServer -ListenOnIPAddress 'a.b.c.d' } | Should Throw
    }
    It "should throw for bad IP (Too big int)" {
      { Initialize-Neo4jServer -ListenOnIPAddress '260.1.1.1' } | Should Throw
    }
    It "should not throw for good IP" {
      { Initialize-Neo4jServer -ListenOnIPAddress '10.1.2.3' } | Should Not Throw
    }
  }

  Context "HTTPPort Parameter" {
    Mock Get-Neo4jServer { return New-Object -TypeName PSCustomObject -Property (@{'Home' = 'TestDrive:\FakeDir'; 'ServerVersion' = '99.99'; 'ServerType' = 'Community'; }) }
    Mock Set-Neo4jSetting { Write-Output (New-Object -TypeName PSCustomObject -Property (@{'Value' = 'Something'; })) }
    
    It "should throw for bad cast (Alpha chars)" {
      { Initialize-Neo4jServer -HTTPPort 'abcd' } | Should Throw
    }
    It "should throw for bad number (Negative)" {
      { Initialize-Neo4jServer -HTTPPort -1234 } | Should Throw
    }
    It "should throw for bad number (70000)" {
      { Initialize-Neo4jServer -HTTPPort 70000 } | Should Throw
    }
    It "should not throw for good number (Min)" {
      { Initialize-Neo4jServer -HTTPPort 0 } | Should Not Throw
    }
    It "should not throw for good number (Max)" {
      { Initialize-Neo4jServer -HTTPPort '65535' } | Should Not Throw
    }
  }

  Context "HTTPSPort Parameter" {
    Mock Get-Neo4jServer { return New-Object -TypeName PSCustomObject -Property (@{'Home' = 'TestDrive:\FakeDir'; 'ServerVersion' = '99.99'; 'ServerType' = 'Community'; }) }
    Mock Set-Neo4jSetting { Write-Output (New-Object -TypeName PSCustomObject -Property (@{'Value' = 'Something'; })) }
    
    It "should throw for bad cast (Alpha chars)" {
      { Initialize-Neo4jServer -HTTPSPort 'abcd' } | Should Throw
    }
    It "should throw for bad nu-mber (Negative)" {
      { Initialize-Neo4jServer HTTPSPort -1234 } | Should Throw
    }
    It "should throw for bad number (70000)" {
      { Initialize-Neo4jServer -HTTPSPort 70000 } | Should Throw
    }
    It "should not throw for good number (Min)" {
      { Initialize-Neo4jServer -HTTPSPort 0 } | Should Not Throw
    }
    It "should not throw for good number (Max)" {
      { Initialize-Neo4jServer -HTTPSPort '65535' } | Should Not Throw
    }
  }

  Context "RemoteShellPort Parameter" {
    Mock Get-Neo4jServer { return New-Object -TypeName PSCustomObject -Property (@{'Home' = 'TestDrive:\FakeDir'; 'ServerVersion' = '99.99'; 'ServerType' = 'Community'; }) }
    Mock Set-Neo4jSetting { Write-Output (New-Object -TypeName PSCustomObject -Property (@{'Value' = 'Something'; })) }
    
    It "should throw for bad cast (Alpha chars)" {
      { Initialize-Neo4jServer -RemoteShellPort 'abcd' } | Should Throw
    }
    It "should throw for bad number (Negative)" {
      { Initialize-Neo4jServer -RemoteShellPort -1234 } | Should Throw
    }
    It "should throw for bad number (70000)" {
      { Initialize-Neo4jServer -RemoteShellPort 70000 } | Should Throw
    }
    It "should not throw for good number (Min)" {
      { Initialize-Neo4jServer -RemoteShellPort 0 } | Should Not Throw
    }
    It "should not throw for good number (Max)" {
      { Initialize-Neo4jServer -RemoteShellPort '65535' } | Should Not Throw
    }
  }
}
