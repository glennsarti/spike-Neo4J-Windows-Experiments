@ECHO OFF

PUSHD "%~dp0..\tests"

@PowerShell -Version 3.0 -NonInteractive -NoProfile -ExecutionPolicy Bypass -Command ". {& Import-Module '..\pester\Pester.psm1';  & { Invoke-Pester -Strict -EnableExit %*}}"

POPD

EXIT /B %ERRORLEVEL%
