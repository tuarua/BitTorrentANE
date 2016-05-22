
REM Get the path to the script and trim to get the directory.
@echo off
SET pathtome=%~dp0
echo cleaning %pathtome%
DEL /F /Q /A %pathtome%BitTorrentANE-debug.ane
DEL /F /Q /A %pathtome%BitTorrentANE.swc
DEL /F /Q /A %pathtome%library.swf
DEL /F /Q /A %pathtome%catalog.xml
rd /S /Q %pathtome%platforms