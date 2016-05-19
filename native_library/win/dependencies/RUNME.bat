@echo off
SET pathtome=%~dp0
NET SESSION >nul 2>&1
if %ERRORLEVEL% EQU 0 (
	call boost.bat
	call geoip.bat
	call openssl.bat
	call libtorrent.bat
	REM start "New Window" cmd /c test.cmd
	REM stop
) else (
   echo ##########################################################
   echo This script must be run as administrator to work properly!  
   echo If you're seeing this after clicking on a start menu icon, then right click on the shortcut and select "Run As Administrator".
   echo ##########################################################
)