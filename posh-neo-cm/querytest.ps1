$ErrorActionPreference = 'Stop'
$VerbosePreference = 'SilentlyContinue'

# Start a Server Console
# Get-Module -Name 'Neo4j-Management' | Remove-Module
# Import-Module "$PSScriptRoot\src\Neo4j-Management.psd1" | Out-Null
#"C:\tools\neo4j-community\neo4j-community-2.2.0" | Initialize-Neo4jServer -ListenOnIPAddress 127.0.0.1 -EnableRemoteShell -PassThru | Start-Neo4jServer -Console

$NeoServer = 'http://127.0.0.1:7474'
$NeoUsername = 'neo4j'
$NeoPassword = 'Password1'

#Neo Stuff
function Invoke-Cypher($cypherQuery)
{
  Write-Verbose "Running query $cypherQuery"
  $body = @{
      query = $cypherQuery
  }

  $Headers = @{"Authorization" = "Basic "+[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$($NeoUsername):$($NeoPassword)"))}

  Invoke-WebRequest -URI "$NeoServer/db/data/cypher" -Body $body -Method 'POST' -Timeout 20 -Header $Headers -DisableKeepAlive -Verbose:($VerbosePreference -eq "Continue") 
}

function Invoke-Neo4jGET($childURL)
{
  Write-Verbose "$NeoServer/$childURL"

  $Headers = @{"Authorization" = "Basic "+[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$($NeoUsername):$($NeoPassword)"))}

  Invoke-WebRequest -URI "$NeoServer/$childURL" -Body $body -Method 'GET' -Timeout 20 -Header $Headers -DisableKeepAlive -Verbose:($VerbosePreference -eq "Continue") 
}

Write-Host "`n`n-=-= Running Cypher =-=-" -foreground Yellow
(Invoke-Cypher 'MATCH (n) RETURN Count(n)').Content | ConvertFrom-JSON


Write-Host "`n`n-=-= ID Counts =-=-" -foreground Yellow
((Invoke-Neo4jGET 'db/manage/server/jmx/domain/org.neo4j/instance%3Dkernel%230%2Cname%3DPrimitive%20count').Content | ConvertFrom-JSON).attributes | % {
	Write-Host "$($_.Name) = $($_.value)"
}


Write-Host "`n`n-=-= Server Info =-=-" -foreground Yellow
((Invoke-Neo4jGET 'db/manage/server/jmx/domain/org.neo4j/instance%3Dkernel%230%2Cname%3DConfiguration').Content | ConvertFrom-JSON).attributes | % {
	Write-Host "$($_.Name) = $($_.value)"
}


Write-Host "`n`n-=-= Store Size =-=-" -foreground Yellow
((Invoke-Neo4jGET 'db/manage/server/jmx/domain/org.neo4j/instance%3Dkernel%230%2Cname%3DStore%20file%20sizes').Content | ConvertFrom-JSON).attributes | % {
	Write-Host "$($_.Name) = $($_.value)"
}

<#
Example output

-=-= Running Cypher =-=-

columns                                                     data
-------                                                     ----
{Count(n)}                                                  {169}


-=-= ID Counts =-=-
NumberOfPropertyIdsInUse = 380
NumberOfNodeIdsInUse = 169
NumberOfRelationshipTypeIdsInUse = 6
NumberOfRelationshipIdsInUse = 250


-=-= Server Info =-=-
store_dir = C:\tools\neo4j-community\neo4j-community-2.2.0\data\graph.db
remote_shell_host = 192.168.100.105
remote_shell_read_only = false
remote_shell_enabled = true
online_backup_enabled = False
remote_shell_port = 1337
node_auto_indexing = true
neo4j.ext.udc.enabled = true
remote_shell_name = shell


-=-= Store Size =-=-
TotalStoreSize = 3040945
PropertyStoreSize = 16318
ArrayStoreSize = 24576
NodeStoreSize = 8190
StringStoreSize = 8192
LogicalLogSize = 74883
RelationshipStoreSize = 16320
#>
