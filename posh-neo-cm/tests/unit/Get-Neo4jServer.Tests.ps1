$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
$common = Join-Path (Split-Path -Parent $here) 'Common.ps1'
. $common
. "$src\$sut"

# Fake functions.  You can only mock functions which already exist
function Get-Neo4jHome() { throw "Not Implemented" }
function Validate-Neo4jHome() { throw "Not Implemented" }
function Validate-Neo4jServerObject() { throw "Not Implemented" }

Describe "Get-Neo4jServer" {
  Context "Missing Neo4j installation" {
    # Setup
    Mock Get-Neo4jHome { return $null }

    It "throws an error if no default home" {
       { Get-Neo4jServer -ErrorAction Stop } | Should Throw       
    }
    It "attempts to get the default home" {
      Assert-MockCalled Get-Neo4jHome -Times 1
    }    
  }
  Context "Invalid Neo4j installation" {
    # Setup
    Mock Get-Neo4jHome { return (Get-MockNeo4jInstall) }
    Mock Validate-Neo4jHome { return $false }

    It "throws an error if no default home" {
       { Get-Neo4jServer -ErrorAction Stop } | Should Throw       
    }
    It "attempts to get the default home" {
      Assert-MockCalled Get-Neo4jHome -Times 1
    }
    It "attempts to validate the home" {
      Assert-MockCalled Validate-Neo4jHome -Times 1
    }    
  }
  Context "Invalid Neo4j Server detection" {
    # Setup
    Mock Get-Neo4jHome { return $null }
    Mock Validate-Neo4jHome { return $true }
    Mock Validate-Neo4jServerObject { return $false }
    New-MockNeo4jInstall -NeoVersion '99.99' -IsEnterpriseServer
    
    It "throws an error if no default home" {
       { Get-Neo4jServer -Neo4jHome (Get-MockNeo4jInstall) -ErrorAction Stop } | Should Throw       
    }
    It "does not attempt to get the default home" {
      Assert-MockCalled Get-Neo4jHome -Times 0
    }
    It "attempts to validate the home" {
      Assert-MockCalled Validate-Neo4jHome -Times 1
    }    
    It "attempts to validate the server details" {
      Assert-MockCalled Validate-Neo4jServerObject -Times 1
    }    
  }
  
  Context "Pipes and aliases" {
    # Setup
    
    It "processes piped paths" {
      Mock Get-Neo4jHome { return $null }
      Mock Validate-Neo4jHome { return $true }
      Mock Validate-Neo4jServerObject { return $true }
      New-MockNeo4jInstall -NeoVersion '99.99' -IsEnterpriseServer

      $neoServer = ( Get-MockNeo4jInstall | Get-Neo4jServer )
      
      ($neoServer -ne $null) | Should Be $true
    }

    It "uses the Home alias" {
      Mock Get-Neo4jHome { return $null }
      Mock Validate-Neo4jHome { return $true }
      Mock Validate-Neo4jServerObject { return $true }
      New-MockNeo4jInstall -NeoVersion '99.99' -IsEnterpriseServer

      $neoServer = ( Get-Neo4jServer -Home (Get-MockNeo4jInstall) )
      
      ($neoServer -ne $null) | Should Be $true
    }
  }
  
  Context "Valid Enterprise Neo4j installation" {
    # Setup
    Mock Get-Neo4jHome { return $null }
    Mock Validate-Neo4jHome { return $true }
    Mock Validate-Neo4jServerObject { return $true }
    New-MockNeo4jInstall -NeoVersion '99.99' -IsEnterpriseServer
    
    $neoServer = Get-Neo4jServer -Neo4jHome (Get-MockNeo4jInstall) -ErrorAction Stop

    It "does not attempt to get the default home" {
      Assert-MockCalled Get-Neo4jHome -Times 0
    }
    It "attempts to validate the home" {
      Assert-MockCalled Validate-Neo4jHome -Times 1
    }    
    It "attempts to validate the server details" {
      Assert-MockCalled Validate-Neo4jServerObject -Times 1
    }    
    It "detects an enterprise edition" {
       $neoServer.ServerType | Should Be "Enterprise"      
    }
    It "detects correct version" {
       $neoServer.ServerVersion | Should Be "99.99"      
    }
    It "detects correct home path" {
       $neoServer.Home | Should Be (Get-MockNeo4jInstall)
    }
  }
  Context "Valid Community Neo4j installation" {
    # Setup
    Mock Get-Neo4jHome { return $null }
    Mock Validate-Neo4jHome { return $true }
    Mock Validate-Neo4jServerObject { return $true }
    New-MockNeo4jInstall -NeoVersion '99.99' -IsCommunityServer
    
    $neoServer = Get-Neo4jServer -Neo4jHome (Get-MockNeo4jInstall) -ErrorAction Stop

    It "does not attempt to get the default home" {
      Assert-MockCalled Get-Neo4jHome -Times 0
    }
    It "attempts to validate the home" {
      Assert-MockCalled Validate-Neo4jHome -Times 1
    }    
    It "attempts to validate the server details" {
      Assert-MockCalled Validate-Neo4jServerObject -Times 1
    }    
    It "detects an enterprise edition" {
       $neoServer.ServerType | Should Be "Community"      
    }
    It "detects correct version" {
       $neoServer.ServerVersion | Should Be "99.99"      
    }
    It "detects correct home path" {
       $neoServer.Home | Should Be (Get-MockNeo4jInstall)
    }
  }
}
