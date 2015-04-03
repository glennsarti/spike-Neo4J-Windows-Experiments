$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
$common = Join-Path (Split-Path -Parent $here) 'Common.ps1'
. $common
. "$src\$sut"

Describe "Validate-Neo4jServerObject" {
  Context "Invalid Server Object" {
    It "throw if missing object" {
      { Validate-Neo4jServerObject } | Should Throw
    }
    It "return false if missing all properties" {
      (Validate-Neo4jServerObject -Neo4jServer (New-Object -TypeName PSCustomObject)) | Should be $false
    }
    It "return false if Home is null" {
      $serverObject = New-Object -TypeName PSCustomObject -Property @{
        'Home' = $null;
        'ServerVersion' = '99.99';
        'ServerType' = 'Community';
      }
      (Validate-Neo4jServerObject -Neo4jServer $serverObject) | Should be $false
    }
    It "return false if ServerVersion is null" {
      $serverObject = New-Object -TypeName PSCustomObject -Property @{
        'Home' = Get-MockNeo4jInstall;
        'ServerVersion' = $null;
        'ServerType' = 'Community';
      }
      (Validate-Neo4jServerObject -Neo4jServer $serverObject) | Should be $false
    }
    It "return false if ServerType is null" {
      $serverObject = New-Object -TypeName PSCustomObject -Property @{
        'Home' = Get-MockNeo4jInstall;
        'ServerVersion' = '99.99';
        'ServerType' = $null;
      }
      (Validate-Neo4jServerObject -Neo4jServer $serverObject) | Should be $false
    }
    It "return false if ServerType is not Community or Enterprise" {
      $serverObject = New-Object -TypeName PSCustomObject -Property @{
        'Home' = Get-MockNeo4jInstall;
        'ServerVersion' = '99.99';
        'ServerType' = 'SomethingSilly';
      }
      (Validate-Neo4jServerObject -Neo4jServer $serverObject) | Should be $false
    }
    It "return false if Home does not exist" {
      $serverObject = New-Object -TypeName PSCustomObject -Property @{
        'Home' = 'TestDrive:\Some-directory-that-doesnt-exist';
        'ServerVersion' = '99.99';
        'ServerType' = 'Community';
      }
      (Validate-Neo4jServerObject -Neo4jServer $serverObject) | Should be $false
    }
  }

  Context "Valid Server Object" {
    # Setup
    Mock Test-Path { return $true }
    $serverObject = New-Object -TypeName PSCustomObject -Property @{
      'Home' = Get-MockNeo4jInstall;
      'ServerVersion' = '99.99';
      'ServerType' = 'Community';
    }
    $result = Validate-Neo4jServerObject -Neo4jServer $serverObject

    It "returns true" {
      $result | Should be $true
    }
    It "attemtps to validate the path" {
      Assert-MockCalled Test-Path -Times 1
    }
  }
}