# Initialize-Neo4jServer

Initializes a Neo4j installation with common settings such as HTTP port number.


## Syntax

```powershell
Initialize-Neo4jServer [-Neo4jServer <Object>] [-PassThru] [-HTTPPort <Int32>] [-EnableHTTPS] [-HTTPSPort <Int32>] [-EnableRemoteShell] [-RemoteShellPort <Int32>] [-ListenOnIPAddress <String>] [-DisableAuthentication] [-ClearExistingDatabase] [-DisableOnlineBackup] [-OnlineBackupServer <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```


## Parameters

###  -Neo4jServer [\<Object\>]
A directory path or Neo4j server object to the Neo4j instance to initialize


Property               | Value
---------------------- | --------------
Aliases                | 
Required?              | false
Position?              | 1
Default Value          | 
Accept Pipeline Input? | true (ByValue)

 
###  -PassThru
Pass through the Neo4j server object instead of the initialized settings


Property               | Value
---------------------- | -----
Aliases                | 
Required?              | false
Position?              | named
Default Value          | False
Accept Pipeline Input? | false

 
###  -HTTPPort [\<Int32\>]
TCP Port used to communicate via the HTTP protocol. Valid values are 0 to 65535


Property               | Value
---------------------- | -----
Aliases                | 
Required?              | false
Position?              | 2
Default Value          | 7474
Accept Pipeline Input? | false

 
###  -EnableHTTPS
Enabled the HTTPS protocol.  By default this is disable


Property               | Value
---------------------- | -----
Aliases                | 
Required?              | false
Position?              | named
Default Value          | False
Accept Pipeline Input? | false

 
###  -HTTPSPort [\<Int32\>]
TCP Port used to communicate via the HTTPS protocol. Valid values are 0 to 65535


Property               | Value
---------------------- | -----
Aliases                | 
Required?              | false
Position?              | 3
Default Value          | 7473
Accept Pipeline Input? | false

 
###  -EnableRemoteShell
Enable the Remote Shell for the Neo4j Server.  By default this is disabled


Property               | Value
---------------------- | -----
Aliases                | 
Required?              | false
Position?              | named
Default Value          | False
Accept Pipeline Input? | false

 
###  -RemoteShellPort [\<Int32\>]
TCP Port used to communicate with the Neo4j Server. Valid values are 0 to 65535
Requires the EnableRemoteShell switch.


Property               | Value
---------------------- | -----
Aliases                | 
Required?              | false
Position?              | 4
Default Value          | 1337
Accept Pipeline Input? | false

 
###  -ListenOnIPAddress [\<String\>]
The IP Address to listen for incoming connections.  By default his is 127.0.0.1 (localhost). Valid values are IP Addresses in x.x.x.x format
Use 0.0.0.0 to use any network interface


Property               | Value
---------------------- | ---------
Aliases                | 
Required?              | false
Position?              | 5
Default Value          | 127.0.0.1
Accept Pipeline Input? | false

 
###  -DisableAuthentication
Disable the Neo4j authentication.  By default authentication is enabled
This is only applicable to Neo4j 2.2 and above.


Property               | Value
---------------------- | -----
Aliases                | 
Required?              | false
Position?              | named
Default Value          | False
Accept Pipeline Input? | false

 
###  -ClearExistingDatabase
Delete the existing graph data files


Property               | Value
---------------------- | -----
Aliases                | 
Required?              | false
Position?              | named
Default Value          | False
Accept Pipeline Input? | false

 
###  -DisableOnlineBackup
Disable the online backup service
This only applicable to Enterprise Neo4j Servers and will throw an error on Community servers


Property               | Value
---------------------- | -----
Aliases                | 
Required?              | false
Position?              | named
Default Value          | False
Accept Pipeline Input? | false

 
###  -OnlineBackupServer [\<String\>]
Host and port number to listen for online backup service requests.  This can be a single host and port, or a single host and port range
e.g. 127.0.0.1:6000 or 10.1.2.3:6000-6009
If a port range is specified, Neo4j will attempt to listen on the next free port number, starting at the lowest.
This only applicable to Enterprise Neo4j Servers and will throw an error on Community servers


Property               | Value
---------------------- | -----
Aliases                | 
Required?              | false
Position?              | 6
Default Value          | 
Accept Pipeline Input? | false

 
###  -WhatIf

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | false
Position?              | named
Default Value          | 
Accept Pipeline Input? | false

 
###  -Confirm

Property               | Value
---------------------- | -----
Aliases                | 
Required?              | false
Position?              | named
Default Value          | 
Accept Pipeline Input? | false

 
### \<CommonParameters\>

This cmdlet supports the common parameters: -Verbose, -Debug, -ErrorAction, -ErrorVariable, -OutBuffer, and -OutVariable. For more information, see `about_CommonParameters` http://go.microsoft.com/fwlink/p/?LinkID=113216 .

## Aliases

None

## Notes


## Examples
**EXAMPLE 1**

Set the HTTP port to 8000 and use all other defaults for the Neo4j installation at C:\Neo4j\neo4j-community

```powershell
C:\PS> 'C:\Neo4j\neo4j-community' | Initialize-Neo4jServer -HTTPPort 8000
```


**EXAMPLE 2**

Set the HTTP port to 8000, use the Remote Shell on port 40000 and use all other defaults for the Neo4j installation at C:\Neo4j\neo4j-community

```powershell
C:\PS> Get-Neo4jServer 'C:\Neo4j\neo4j-community' | Initialize-Neo4jServer -HTTPPort 8000 -EnableRemoteShell -RemoteShellPort 40000
```


**EXAMPLE 3**

Enable HTTPS on the default port and the backup server on localhost port 5690 for the Neo4j installation at C:\Neo4j\neo4j-enterprise

```powershell
C:\PS> Initialize-Neo4jServer -Neo4jHome 'C:\Neo4j\neo4j-enterprise' -EnableHTTPS -OnlineBackupServer 127.0.0.1:5690
```


## Links

Get-Neo4jServer 



