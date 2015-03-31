@ECHO OFF

PUSHD "%~dp0..\src"

REM Clear any old test reports
IF EXIST Test.xml ( DEL /Q Test.XML )
IF EXIST "..\tests\Test.XML" ( DEL /Q "..\tests\Test.XML" )

CALL "..\pester\bin\pester.bat"

REM Copy the test report
IF EXIST Test.xml ( MOVE /Y Test.XML "..\tests\Test.XML" )

POPD

EXIT /B %ERRORLEVEL%
