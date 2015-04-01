#Neo4j Powershell Config Cmdlets

# WIP DOCUMENTATION

## Example stuff you can do

**Show all settings**
```
Get-Neo4jSetting
```

**Export all settings to CSV**
```
Get-Neo4jServer 'C:\tools\neo4j-community\neo4j-community-2.2.0' | Get-Neo4jSetting | ExportTo-CSV C:\NeoProperties.CSV
```

**Show all settings to JSON**
```
Get-Neo4jServer 'C:\tools\neo4j-community\neo4j-community-2.2.0' | Get-Neo4jSetting | ConvertTo-JSON
```

**Set HTTP port to 4015**
```
Set-Neo4jSetting -ConfigurationFile 'neo4j-server.properties' -Name 'org.neo4j.server.webserver.port' -Value 4015
```


**See what would happen if I set HTTP port to 4015**

All Cmdlets (where appropriate) support the -WhatIf and -Confirm parameters
```
Set-Neo4jSetting -ConfigurationFile 'neo4j-server.properties' -Name 'org.neo4j.server.webserver.port' -Value 4015 -WhatIf
```

**Set all 'true' values to 'false'**
```
Get-Neo4jSetting | Where-Object { $_.Value -eq 'true' } | ForEach-Object { $_.Value = 'false'; Write-Output $_ } | Set-Neo4jSetting
```
* Get all settings
* If the value is 'true' pass it through the pipeline
* For each setting in the pipeline chagne the Value property to 'false' and pass it down the pipeline
* Set the setting

**Remove all settings (DO NOT DO THIS.  Bad stuff will happen)**
```
Get-Neo4jSetting | Remove-Neo4jSetting -Confirm:$false
```

## Stuff to do

* Add in pre-canned cmdlet to do a basic Neo4j Server setup e.g. Set Http and https port, enable/disable https, set memory, enable GC logging

* Add in pre-canned query to enable and disable clustering (I need to setup clustering first to try this)

* Start the Neo4j-Shell (easy enough)

* Start a console version of the Neo4j Server e.g. Start-Neo4jServer -Console

* Start/Stop/Restart Neo4j Server Service?



## Cmdlet Documentation

** Get-Neo4jServer **

Retrieves information about a Neo4j instance via the filesystem

```Powershell
Get-Neo4jServer

Get-Neo4jServer -Home <Path to Neo4j installation>
```
Without a -Home it just uses the `NEO4J_HOME` environment variable.

Returns and object with;
* Home - Full path to HOME
* ServerVersion - Server Version e.g. 2.2.0
* ServerType - Server Type e.g. Community or Enterprise



** Get-Neo4jSetting **

Retrieves settings from the Neo4j instance

```Powershell
Get-Neo4jSetting

Get-Neo4jSetting -Neo4jHome <Path to Neo4j installation>

Get-Neo4jSetting -Neo4jServer <Neo4j Server Object>
```

Returns objects in the pipeline with;
* Name - Name of the setting e.g. 'node_auto_indexing'
* Value - The value of the setting e.g. 'true'.  Always a string
* Configuration File - The name of the configuration file it was retrieved from e.g. neo4j.properties
* Neo4jHome - The full path to the Neo4j Installation
* IsDefault - Whether this setting is derived via default values or explicitly set in the configuration file

** Set-Neo4jSetting **

Sets a setting for the Neo4j instance

```Powershell
Set-Neo4jSetting -ConfigurationFile <File Name> -Name <Setting Name> -Value <Setting Value>

Set-Neo4jSetting -Neo4jHome <Path to Neo4j installation> -ConfigurationFile <File Name> -Name <Setting Name> -Value <Setting Value>

Set-Neo4jSetting -Neo4jServer <Neo4j Server Object> -ConfigurationFile <File Name> -Name <Setting Name> -Value <Setting Value>

Set-Neo4jSetting <Input Pipeline Setting Object>
```
Returns a modified Setting Object (See Get-Neo4jSetting for schema)

** Remove-Neo4jSetting **

Removes a setting from the Neo4j instance

```Powershell
Remove-Neo4jSetting -ConfigurationFile <File Name> -Name <Setting Name>

Set-Neo4jSetting -Neo4jHome <Path to Neo4j installation> -ConfigurationFile <File Name> -Name <Setting Name>

Set-Neo4jSetting -Neo4jServer <Neo4j Server Object> -ConfigurationFile <File Name> -Name <Setting Name>

Set-Neo4jSetting <Input Pipeline Setting Object>
```

Returns a modified Setting Object (See Get-Neo4jSetting for schema) with the following modifications;
* Value is set to NULL
* IsDefault is set to TRUE
