@ECHO OFF

PUSHD "%~dp0..\packaging\standalone\src\tests\Neo4j-Management"

@PowerShell -NonInteractive -NoProfile -ExecutionPolicy Bypass -Command ^
 "& Import-Module '%~dp0..\pester\Pester.psd1';  & { Invoke-Pester -Strict -EnableExit %*}"

POPD

EXIT /B %ERRORLEVEL%
