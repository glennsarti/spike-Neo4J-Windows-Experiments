@ECHO OFF
rem Copyright (c) 2002-2015 "Neo Technology,"
rem Network Engine for Objects in Lund AB [http://neotechnology.com]
rem
rem This file is part of Neo4j.
rem
rem Neo4j is free software: you can redistribute it and/or modify
rem it under the terms of the GNU General Public License as published by
rem the Free Software Foundation, either version 3 of the License, or
rem (at your option) any later version.
rem
rem This program is distributed in the hope that it will be useful,
rem but WITHOUT ANY WARRANTY; without even the implied warranty of
rem MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
rem GNU General Public License for more details.
rem
rem You should have received a copy of the GNU General Public License
rem along with this program.  If not, see <http://www.gnu.org/licenses/>.

SETLOCAL ENABLEEXTENSIONS

IF NOT [%2]==[] set serviceName=%2
IF NOT [%3]==[] set serviceDisplayName=%3
IF NOT %serviceName: =% == %serviceName% GOTO :Usage

IF NOT [%serviceName%]==[] set serviceName=-Name '%serviceName%'
IF NOT [%serviceDisplayName%]==[] set serviceDisplayName=-DisplayName '%serviceDisplayName%'

GOTO :Main %1 %2 %3

:Usage
  ECHO Usage: %~0Neo4jInstaller.bat ^<install^|remove^|stop^|start^|status> [service name] [service display name]
  ECHO        - Service Name - Optional, must NOT contain spaces
  ECHO        - Service Display Name - Optional, The name displayed in the services window, surround with quotes to use spaces
  GOTO :eof

:Status
  REM Powershell -NoProfile -ExecutionPolicy Bypass -Command "Import-Module '%~dp0Neo4j-Management.psd1'; Exit (Get-Neo4jServer '%~dp0..' | Stop-Neo4jServer %serviceName%)"
  REM EXIT /B %ERRORLEVEL%
  ECHO Not implemented
  EXIT 255 /B

:Stop
  Powershell -NoProfile -ExecutionPolicy Bypass -Command "Import-Module '%~dp0Neo4j-Management.psd1'; Exit (Get-Neo4jServer '%~dp0..' | Stop-Neo4jServer %serviceName%)"
  EXIT /B %ERRORLEVEL%

:Start
  Powershell -NoProfile -ExecutionPolicy Bypass -Command "Import-Module '%~dp0Neo4j-Management.psd1'; Exit (Get-Neo4jServer '%~dp0..' | Start-Neo4jServer %serviceName%)"
  EXIT /B %ERRORLEVEL%

:Remove
  Powershell -NoProfile -ExecutionPolicy Bypass -Command "Import-Module '%~dp0Neo4j-Management.psd1'; Exit (Get-Neo4jServer '%~dp0..' | Uninstall-Neo4jServer %serviceName%)"
  EXIT /B %ERRORLEVEL%

:Install
  Powershell -NoProfile -ExecutionPolicy Bypass -Command "Import-Module '%~dp0Neo4j-Management.psd1'; Exit (Get-Neo4jServer '%~dp0..' | Install-Neo4jServer %serviceName% %serviceDisplayName%)"
  EXIT /B %ERRORLEVEL%

:Main
  if "%1" == "" goto :Usage
  if "%1" == "remove"  goto :Remove
  if "%1" == "install" goto :Install
  if "%1" == "stop" goto :Stop
  if "%1" == "start" goto :Start
  if "%1" == "status" goto :Status
  CALL :Usage
  GOTO :eof