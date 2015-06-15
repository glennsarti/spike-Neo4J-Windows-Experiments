# WARNING this should be copied directly into real repo
$DebugPreference = "SilentlyContinue"

$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$src = Join-Path -Path (Join-Path -Path (Split-Path $here) -ChildPath 'src') -ChildPath 'Neo4j-Management'