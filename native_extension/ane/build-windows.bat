REM Get the path to the script and trim to get the directory.
@echo off
SET SZIP="C:\Program Files\7-Zip\7z.exe"
echo Setting path to current directory to:
SET pathtome=%~dp0
echo %pathtome%

REM Setup the directory.
echo Making directories.

mkdir %pathtome%platforms
mkdir %pathtome%platforms\win
mkdir %pathtome%platforms\win\release
mkdir %pathtome%platforms\win\debug

REM Copy SWC into place.
echo Copying SWC into place.
echo %pathtome%..\bin\BitTorrentANE.swc
copy %pathtome%..\bin\BitTorrentANE.swc %pathtome%

REM contents of SWC.
echo Extracting files form SWC.
echo %pathtome%BitTorrentANE.swc
copy %pathtome%BitTorrentANE.swc %pathtome%BitTorrentANEExtract.swc
ren %pathtome%BitTorrentANEExtract.swc BitTorrentANEExtract.zip

call %SZIP% e %pathtome%BitTorrentANEExtract.zip -o%pathtome%

del %pathtome%BitTorrentANEExtract.zip

REM Copy library.swf to folders.
echo Copying library.swf into place.
copy %pathtome%library.swf %pathtome%platforms\win\release
copy %pathtome%library.swf %pathtome%platforms\win\debug


REM Copy native libraries into place.
echo Copying native libraries into place.

copy %pathtome%..\..\native_library\win\BitTorrentANE\Release\BitTorrentANE.dll %pathtome%platforms\win\release
copy %pathtome%..\..\native_library\win\BitTorrentANE\Release\BitTorrentANE.dll %pathtome%platforms\win\debug

REM Run the build command.
echo Building Release.
call adt.bat -package -target ane %pathtome%BitTorrentANE.ane %pathtome%extension_win.xml -swc %pathtome%BitTorrentANE.swc -platform Windows-x86 -C %pathtome%platforms\win\release BitTorrentANE.dll library.swf
echo Building Debug
call adt.bat -package -target ane %pathtome%BitTorrentANE-debug.ane %pathtome%extension_win.xml -swc %pathtome%BitTorrentANE.swc -platform Windows-x86 -C %pathtome%platforms\win\debug BitTorrentANE.dll library.swf

call %SZIP% x %pathtome%BitTorrentANE-debug.ane -o%pathtome%debug\BitTorrentANE.ane\ -aoa

call %pathtome%clean.bat
