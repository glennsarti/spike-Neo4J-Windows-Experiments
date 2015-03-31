@ECHO OFF

ECHO Cloning Pester
git clone https://github.com/pester/Pester.git "%~dp0..\pester" --depth 1 --branch 3.3.6


ECHO Removing the Git directory (Stops it being detected as a submodule)
RMDIR "%~dp0..\pester\.git" /s /q
