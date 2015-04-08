$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
$common = Join-Path (Split-Path -Parent $here) 'Common.ps1'
. $common
. "$src\$sut"

# Fake functions.  You can only mock functions which already exist
function Get-Neo4jServer() { throw "Not Implemented" }
function Validate-Neo4jServerObject() { throw "Not Implemented" }

Describe "Set-Neo4jSetting" {

  Context "Invalid or missing default neo4j installation" {
    Mock Get-Neo4jServer { return $null }
    $result = Set-Neo4jSetting -Name 'invalid-setting' -ConfigurationFile 'invalid-configurationfile' -Value 'invalid-value'
    
    It "return null if missing default" {
      $result | Should BeNullOrEmpty      
    }
    It "calls Get-Neo4Server" {
      Assert-MockCalled Get-Neo4jServer -Times 1
    }
  }

  Context "Invalid or missing specified neo4j installation" {
    Mock Get-Neo4jServer { return $null } -ParameterFilter { $Neo4jHome -eq 'TestDrive:\some-dir-that-doesnt-exist' }
    $result = Set-Neo4jSetting -Name 'invalid-setting' -ConfigurationFile 'invalid-configurationfile' -Neo4jHome 'TestDrive:\some-dir-that-doesnt-exist' -Value 'invalid-value'

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
      { Set-Neo4jSetting -Name 'invalid-setting' -ConfigurationFile 'invalid-configurationfile' -Neo4jServer (New-Object -TypeName PSCustomObject) -Value 'invalid-value' -ErrorAction Stop } | Should Throw
    }

    It "calls Validate-Neo4jServerObject" {
      Assert-MockCalled Validate-Neo4jServerObject -Times 1
    }
  }

  Context "Invalid specified neo4j installation in setting object" {
    Mock Get-Neo4jServer { return $null } -ParameterFilter { $Neo4jHome -eq 'TestDrive:\some-dir-that-doesnt-exist' }
    
    $setting = New-Object -TypeName PSCustomObject -Property @{ 'Neo4jHome' = 'TestDrive:\some-dir-that-doesnt-exist'; 'ConfigurationFile' = 'invalid-configurationfile'; 'Name' = 'invalid-setting'; 'Value' = 'invalid-value'; 'IsDefault' = $false }
    $result = ($setting | Set-Neo4jSetting)

    It "return null if invalid directory" {
      $result | Should BeNullOrEmpty      
    }
    It "calls Get-Neo4Server" {
      Assert-MockCalled Get-Neo4jServer -Times 1
    }
  }

  Context "Invalid configuration file without force" {
    Mock Get-Neo4jServer { return $serverObject = New-Object -TypeName PSCustomObject -Property @{ 'Home' = Get-MockNeo4jInstall; 'ServerVersion' = '99.99'; 'ServerType' = 'Community';} }    
    
    $setting = New-Object -TypeName PSCustomObject -Property @{ 'Neo4jHome' = Get-MockNeo4jInstall; 'ConfigurationFile' = 'invalid-configurationfile'; 'Name' = 'invalid-setting'; 'Value' = 'invalid-value'; 'IsDefault' = $false }
    
    It "should throw" {
      { $setting | Set-Neo4jSetting -ErrorAction Stop } | Should Throw
    }
  }

  Context "Invalid configuration file with force" {
    Mock Get-Neo4jServer { return $serverObject = New-Object -TypeName PSCustomObject -Property @{ 'Home' = Get-MockNeo4jInstall; 'ServerVersion' = '99.99'; 'ServerType' = 'Community';} }    
    New-MockNeo4jInstall
    
    $setting = New-Object -TypeName PSCustomObject -Property @{ 'Neo4jHome' = Get-MockNeo4jInstall; 'ConfigurationFile' = 'newconfig.properties'; 'Name' = 'newsetting'; 'Value' = 'newvalue'; 'IsDefault' = $false }
    $settingsFile = Join-Path -Path ($setting.Neo4jHome) -ChildPath "conf\$($setting.ConfigurationFile)"
    $result = ($setting | Set-Neo4jSetting -Confirm:$false -Force)
    
    It "creates the configuration file" {
      (Test-Path -Path $settingsFile) | Should Be $true
    }
    It "returns the name" {
      ($result.Name -eq $setting.Name) | Should Be $true
    }
    It "returns the configuration file" {
      ($result.ConfigurationFile -eq $setting.ConfigurationFile) | Should Be $true
    }
    It "returns the Neo4jHome" {
      ($result.Neo4jHome -eq $setting.Neo4jHome) | Should Be $true
    }
    It "returns the new value" {
      ($result.Value -eq $setting.Value) | Should Be $true
    }
    It "returns non-default value" {
      $result.IsDefault | Should Be $false
    }
    It "added the value to the file" {
      { Get-Content $settingsFile | % { if ($_ -match 'newsetting=newvalue') { throw "Setting was added" } } } | Should Throw
    }
  }
  
  Context "Valid configuration but empty value" {
    Mock Get-Neo4jServer { return $serverObject = New-Object -TypeName PSCustomObject -Property @{ 'Home' = Get-MockNeo4jInstall; 'ServerVersion' = '99.99'; 'ServerType' = 'Community';} }    
    New-MockNeo4jInstall
    
    $setting = New-Object -TypeName PSCustomObject -Property @{ 'Neo4jHome' = Get-MockNeo4jInstall; 'ConfigurationFile' = 'neo4j.properties'; 'Name' = 'newsetting'; 'Value' = ''; 'IsDefault' = $false }
    $settingsFile = Join-Path -Path ($setting.Neo4jHome) -ChildPath "conf\$($setting.ConfigurationFile)"
    It "should throw" {
      { $setting | Set-Neo4jSetting -Confirm:$false -ErrorAction Stop } | Should Throw
    }
  }

  Context "Valid configuration file - new setting" {
    Mock Get-Neo4jServer { return $serverObject = New-Object -TypeName PSCustomObject -Property @{ 'Home' = Get-MockNeo4jInstall; 'ServerVersion' = '99.99'; 'ServerType' = 'Community';} }    
    New-MockNeo4jInstall
    
    $setting = New-Object -TypeName PSCustomObject -Property @{ 'Neo4jHome' = Get-MockNeo4jInstall; 'ConfigurationFile' = 'neo4j.properties'; 'Name' = 'newsetting'; 'Value' = 'newvalue'; 'IsDefault' = $false }
    $settingsFile = Join-Path -Path ($setting.Neo4jHome) -ChildPath "conf\$($setting.ConfigurationFile)"
    $result = ($setting | Set-Neo4jSetting -Confirm:$false)
    
    It "returns the name" {
      ($result.Name -eq $setting.Name) | Should Be $true
    }
    It "returns the configuration file" {
      ($result.ConfigurationFile -eq $setting.ConfigurationFile) | Should Be $true
    }
    It "returns the Neo4jHome" {
      ($result.Neo4jHome -eq $setting.Neo4jHome) | Should Be $true
    }
    It "returns the new value" {
      ($result.Value -eq $setting.Value) | Should Be $true
    }
    It "returns non-default value" {
      $result.IsDefault | Should Be $false
    }
    It "added the value to the file" {
      { Get-Content $settingsFile | % { if ($_ -match 'newsetting=newvalue') { throw "Setting was added" } } } | Should Throw
    }
  }

  Context "Valid configuration file - modify existing setting" {
    Mock Get-Neo4jServer { return $serverObject = New-Object -TypeName PSCustomObject -Property @{ 'Home' = Get-MockNeo4jInstall; 'ServerVersion' = '99.99'; 'ServerType' = 'Community';} }    
    New-MockNeo4jInstall
    
    $setting = New-Object -TypeName PSCustomObject -Property @{ 'Neo4jHome' = Get-MockNeo4jInstall; 'ConfigurationFile' = 'neo4j.properties'; 'Name' = 'setting1'; 'Value' = 'newvalue'; 'IsDefault' = $false }
    $settingsFile = Join-Path -Path ($setting.Neo4jHome) -ChildPath "conf\$($setting.ConfigurationFile)"
    $result = ($setting | Set-Neo4jSetting -Confirm:$false)
    
    It "returns the name" {
      ($result.Name -eq $setting.Name) | Should Be $true
    }
    It "returns the configuration file" {
      ($result.ConfigurationFile -eq $setting.ConfigurationFile) | Should Be $true
    }
    It "returns the Neo4jHome" {
      ($result.Neo4jHome -eq $setting.Neo4jHome) | Should Be $true
    }
    It "returns the new value" {
      ($result.Value -eq $setting.Value) | Should Be $true
    }
    It "returns non-default value" {
      $result.IsDefault | Should Be $false
    }
    It "modified the value in the file" {
      { Get-Content $settingsFile | % { if ($_ -match 'setting1=newvalue') { throw "Setting was added" } } } | Should Throw
    }
  }

  Context "Valid configuration file with -WhatIf" {
    Mock Get-Neo4jServer { return $serverObject = New-Object -TypeName PSCustomObject -Property @{ 'Home' = Get-MockNeo4jInstall; 'ServerVersion' = '99.99'; 'ServerType' = 'Community';} }    
    New-MockNeo4jInstall
    
    $setting = New-Object -TypeName PSCustomObject -Property @{ 'Neo4jHome' = Get-MockNeo4jInstall; 'ConfigurationFile' = 'neo4j.properties'; 'Name' = 'newsetting'; 'Value' = 'newvalue'; 'IsDefault' = $false }
    $settingsFile = Join-Path -Path ($setting.Neo4jHome) -ChildPath "conf\$($setting.ConfigurationFile)"
    $result = ($setting | Set-Neo4jSetting -WhatIf)
    
    It "returns the name" {
      ($result.Name -eq $setting.Name) | Should Be $true
    }
    It "returns the configuration file" {
      ($result.ConfigurationFile -eq $setting.ConfigurationFile) | Should Be $true
    }
    It "returns the Neo4jHome" {
      ($result.Neo4jHome -eq $setting.Neo4jHome) | Should Be $true
    }
    It "returns the new value" {
      ($result.Value -eq $setting.Value) | Should Be $true
    }
    It "returns non-default value" {
      $result.IsDefault | Should Be $false
    }
    It "Did not add the value to the file" {
      ( Get-Content $settingsFile | % { if ($_ -match 'newsetting=newvalue') { throw "Setting was added" } } ) | Should BeNullOrEmpty
    }
  }

  Context "Valid configuration file using the Home alias" {
    Mock Get-Neo4jServer { return $serverObject = New-Object -TypeName PSCustomObject -Property @{ 'Home' = Get-MockNeo4jInstall; 'ServerVersion' = '99.99'; 'ServerType' = 'Community';} }    
    New-MockNeo4jInstall
    
    $setting = New-Object -TypeName PSCustomObject -Property @{ 'Neo4jHome' = Get-MockNeo4jInstall; 'ConfigurationFile' = 'neo4j.properties'; 'Name' = 'newsetting'; 'Value' = 'newvalue'; 'IsDefault' = $false }
    $settingsFile = Join-Path -Path ($setting.Neo4jHome) -ChildPath "conf\$($setting.ConfigurationFile)"
    $result = (Set-Neo4jSetting -Home ($setting.Neo4jHome) -ConfigurationFile ($setting.ConfigurationFile) -Name ($setting.Name) -Value ($setting.Value) -Confirm:$false)
    
    It "returns the name" {
      ($result.Name -eq $setting.Name) | Should Be $true
    }
    It "returns the configuration file" {
      ($result.ConfigurationFile -eq $setting.ConfigurationFile) | Should Be $true
    }
    It "returns the Neo4jHome" {
      ($result.Neo4jHome -eq $setting.Neo4jHome) | Should Be $true
    }
    It "returns the new value" {
      ($result.Value -eq $setting.Value) | Should Be $true
    }
    It "returns non-default value" {
      $result.IsDefault | Should Be $false
    }
    It "added the value to the file" {
      { Get-Content $settingsFile | % { if ($_ -match 'newsetting=newvalue') { throw "Setting was added" } } } | Should Throw
    }
  }

  Context "Valid configuration file using the File alias" {
    Mock Get-Neo4jServer { return $serverObject = New-Object -TypeName PSCustomObject -Property @{ 'Home' = Get-MockNeo4jInstall; 'ServerVersion' = '99.99'; 'ServerType' = 'Community';} }    
    New-MockNeo4jInstall
    
    $setting = New-Object -TypeName PSCustomObject -Property @{ 'Neo4jHome' = Get-MockNeo4jInstall; 'ConfigurationFile' = 'neo4j.properties'; 'Name' = 'newsetting'; 'Value' = 'newvalue'; 'IsDefault' = $false }
    $settingsFile = Join-Path -Path ($setting.Neo4jHome) -ChildPath "conf\$($setting.ConfigurationFile)"
    $result = (Set-Neo4jSetting -Neo4jHome ($setting.Neo4jHome) -File ($setting.ConfigurationFile) -Name ($setting.Name) -Value ($setting.Value) -Confirm:$false)
    
    It "returns the name" {
      ($result.Name -eq $setting.Name) | Should Be $true
    }
    It "returns the configuration file" {
      ($result.ConfigurationFile -eq $setting.ConfigurationFile) | Should Be $true
    }
    It "returns the Neo4jHome" {
      ($result.Neo4jHome -eq $setting.Neo4jHome) | Should Be $true
    }
    It "returns the new value" {
      ($result.Value -eq $setting.Value) | Should Be $true
    }
    It "returns non-default value" {
      $result.IsDefault | Should Be $false
    }
    It "added the value to the file" {
      { Get-Content $settingsFile | % { if ($_ -match 'newsetting=newvalue') { throw "Setting was added" } } } | Should Throw
    }
  }
  
  Context "Valid configuration file using the Setting alias" {
    Mock Get-Neo4jServer { return $serverObject = New-Object -TypeName PSCustomObject -Property @{ 'Home' = Get-MockNeo4jInstall; 'ServerVersion' = '99.99'; 'ServerType' = 'Community';} }    
    New-MockNeo4jInstall
    
    $setting = New-Object -TypeName PSCustomObject -Property @{ 'Neo4jHome' = Get-MockNeo4jInstall; 'ConfigurationFile' = 'neo4j.properties'; 'Name' = 'newsetting'; 'Value' = 'newvalue'; 'IsDefault' = $false }
    $settingsFile = Join-Path -Path ($setting.Neo4jHome) -ChildPath "conf\$($setting.ConfigurationFile)"
    $result = (Set-Neo4jSetting -Neo4jHome ($setting.Neo4jHome) -ConfigurationFile ($setting.ConfigurationFile) -Setting ($setting.Name) -Value ($setting.Value) -Confirm:$false)
    
    It "returns the name" {
      ($result.Name -eq $setting.Name) | Should Be $true
    }
    It "returns the configuration file" {
      ($result.ConfigurationFile -eq $setting.ConfigurationFile) | Should Be $true
    }
    It "returns the Neo4jHome" {
      ($result.Neo4jHome -eq $setting.Neo4jHome) | Should Be $true
    }
    It "returns the new value" {
      ($result.Value -eq $setting.Value) | Should Be $true
    }
    It "returns non-default value" {
      $result.IsDefault | Should Be $false
    }
    It "added the value to the file" {
      { Get-Content $settingsFile | % { if ($_ -match 'newsetting=newvalue') { throw "Setting was added" } } } | Should Throw
    }
  }
}