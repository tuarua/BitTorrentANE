REM Get the path to the script and trim to get the directory.
@echo off
echo Setting path to current directory to:
SET pathtome=%~dp0
echo %pathtome%


REM Setup the directory.
echo Making directories.

mkdir %pathtome%platforms
mkdir %pathtome%platforms\win
mkdir %pathtome%platforms\win\release
mkdir %pathtome%platforms\win\debug
REM mkdir %pathtome%platforms\mac
REM mkdir %pathtome%platforms\mac\release
REM mkdir %pathtome%platforms\mac\debug

REM Copy SWC into place.
echo Copying SWC into place.
echo %pathtome%..\bin\BitTorrentANE.swc
copy %pathtome%..\bin\BitTorrentANE.swc %pathtome%

REM contents of SWC.
echo Extracting files form SWC.
echo %pathtome%BitTorrentANE.swc
copy %pathtome%BitTorrentANE.swc %pathtome%BitTorrentANEExtract.swc
ren %pathtome%BitTorrentANEExtract.swc BitTorrentANEExtract.zip

"C:\Program Files\7-Zip\7z.exe" e %pathtome%BitTorrentANEExtract.zip -o%pathtome%

del %pathtome%BitTorrentANEExtract.zip

REM Copy library.swf to folders.
echo Copying library.swf into place.
copy %pathtome%library.swf %pathtome%platforms\win\release
copy %pathtome%library.swf %pathtome%platforms\win\debug
REM copy %pathtome%library.swf %pathtome%platforms\mac\release
REM copy %pathtome%library.swf %pathtome%platforms\mac\debug


REM Copy native libraries into place.
echo Copying native libraries into place.

copy %pathtome%..\..\native_library\win\BitTorrentANE\Release\BitTorrentANE.dll %pathtome%platforms\win\release
REM When I've fixed debug build in MSVC
REM cp -R -L "%pathtome%..\..\native_library\win\BitTorrentANE\Debug\BitTorrentANE.dll" "%pathtome%platforms\win\debug"

REM copy %pathtome%..\..\native_library\mac\BitTorrentANE\Build\Products\Release\BitTorrentANE.framework %pathtome%platforms\mac\release
REM copy %pathtome%..\..\native_library\mac\BitTorrentANE\Build\Products\Debug\BitTorrentANE.framework %pathtome%platforms\mac\debug


REM Run the build command.
echo Building Release.
REM how do you package win and osx ?
call adt.bat -package -target ane %pathtome%BitTorrentANE.ane %pathtome%extension_win.xml -swc %pathtome%BitTorrentANE.swc -platform Windows-x86 -C %pathtome%platforms\win\release BitTorrentANE.dll library.swf
call %pathtome%clean.bat
