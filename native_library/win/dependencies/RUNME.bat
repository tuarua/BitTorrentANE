@echo off
SET pathtome=%~dp0
NET SESSION >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
	IF NOT DEFINED BOOST_ROOT call boost.bat
	IF NOT DEFINED GEOIP_LIBRARYDIR call geoip.bat
	IF NOT DEFINED OPEN_SSL_LIBRARYDIR call openssl.bat
	IF NOT EXIST %pathtome%libtorrent-rasterbar-1.1.0 call libtorrent.bat
) ELSE (
   echo ##########################################################
   echo This script must be run as administrator to work properly!  
   echo If you're seeing this after clicking on a start menu icon, then right click on the shortcut and select "Run As Administrator".
   echo ##########################################################
)