# Remove-Neo4jSetting


Remove-Neo4jSetting -ConfigurationFile <string> -Name <string> [-Neo4jServer <Object>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]

Remove-Neo4jSetting -Neo4jHome <string> -ConfigurationFile <string> -Name <string> [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]



## Syntax

```powershell
Remove-Neo4jSetting -ConfigurationFile <$ (@{name=ConfigurationFile; required=true; pipelineInput=false; isDynamic=false; parameterSetName=BySettingObject, ByServerObject; parameterValue=string; type=; position=Named; aliases=File}.parameterValue)> -Name <$ (@{name=Name; required=true; pipelineInput=false; isDynamic=false; parameterSetName=BySettingObject, ByServerObject; parameterValue=string; type=; position=Named; aliases=Setting}.parameterValue)> [-Neo4jServer <$ (@{name=Neo4jServer; required=false; pipelineInput=true (ByValue); isDynamic=false; parameterSetName=ByServerObject; parameterValue=Object; type=; position=Named; aliases=None}.parameterValue)>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

```powershell
Remove-Neo4jSetting -Neo4jHome <$ (@{name=Neo4jHome; required=true; pipelineInput=true (ByPropertyName); isDynamic=false; parameterSetName=BySettingObject; parameterValue=string; type=; position=Named; aliases=Home}.parameterValue)> -ConfigurationFile <$ (@{name=ConfigurationFile; required=true; pipelineInput=true (ByPropertyName); isDynamic=false; parameterSetName=BySettingObject, ByServerObject; parameterValue=string; type=; position=Named; aliases=File}.parameterValue)> -Name <$ (@{name=Name; required=true; pipelineInput=true (ByPropertyName); isDynamic=false; parameterSetName=BySettingObject, ByServerObject; parameterValue=string; type=; position=Named; aliases=Setting}.parameterValue)> [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```


## Parameters

###  -ConfigurationFile \<string\>
|-----------------------------|-----------------------|
| Aliases                     |                       |
| Required?                   | true                  |
| Position?                   | Named                 |
| Default Value               |                       |
| Accept Pipeline Input?      | true (ByPropertyName) |

 
###  -Confirm
|-----------------------------|-------|
| Aliases                     |       |
| Required?                   | false |
| Position?                   | Named |
| Default Value               |       |
| Accept Pipeline Input?      | false |

 
###  -Force
|-----------------------------|-------|
| Aliases                     |       |
| Required?                   | false |
| Position?                   | Named |
| Default Value               |       |
| Accept Pipeline Input?      | false |

 
###  -Name \<string\>
|-----------------------------|-----------------------|
| Aliases                     |                       |
| Required?                   | true                  |
| Position?                   | Named                 |
| Default Value               |                       |
| Accept Pipeline Input?      | true (ByPropertyName) |

 
###  -Neo4jHome \<string\>
|-----------------------------|-----------------------|
| Aliases                     |                       |
| Required?                   | true                  |
| Position?                   | Named                 |
| Default Value               |                       |
| Accept Pipeline Input?      | true (ByPropertyName) |

 
###  -Neo4jServer [\<Object\>]
|-----------------------------|----------------|
| Aliases                     |                |
| Required?                   | false          |
| Position?                   | Named          |
| Default Value               |                |
| Accept Pipeline Input?      | true (ByValue) |

 
###  -WhatIf
|-----------------------------|-------|
| Aliases                     |       |
| Required?                   | false |
| Position?                   | Named |
| Default Value               |       |
| Accept Pipeline Input?      | false |

 ### \<CommonParameters\>
This cmdlet supports the common parameters: -Verbose, -Debug, -ErrorAction, -ErrorVariable, -OutBuffer, and -OutVariable. For more information, see `about_CommonParameters` http://go.microsoft.com/fwlink/p/?LinkID=113216 .

## Aliases

None


## Notes


## Examples


## Links



