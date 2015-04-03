$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
$common = Join-Path (Split-Path -Parent $here) 'Common.ps1'
. $common
. "$src\$sut"

Describe "Validate-Neo4jHome" {
  Context "Invalid Neo4jHome path" {
    It "return false for missing parameter" {
      Validate-Neo4jHome | Should Be $false
    }
    It "return false for a missing directory" {
      Validate-Neo4jHome -Neo4jHome 'TestDrive:\Some-dir-that-doesnt-exist' | Should Be $false
    }
  }

  Context "Valid Neo4jHome path" {
    New-MockNeo4jInstall -NeoVersion '99.99' -IsEnterpriseServer

    It "return true" {
      Validate-Neo4jHome -Neo4jHome (Get-MockNeo4jInstall) | Should Be $true
    }
    It "return true for alias Home" {
      Validate-Neo4jHome -Home (Get-MockNeo4jInstall) | Should Be $true
    }
    It "return true for piped input" {
      { (Get-MockNeo4jInstall) | Validate-Neo4jHome } | Should Be $true
    }
  }
}