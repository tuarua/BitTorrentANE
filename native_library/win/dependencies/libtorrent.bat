@echo off
SET pathtome=%~dp0
SET SZIP="C:\Program Files\7-Zip\7z.exe"

SET VERSION="1.1.3"

echo Downloading libtorrent...
call cscript scripts\wget.js https://github.com/arvidn/libtorrent/releases/download/libtorrent-1_1_3/libtorrent-rasterbar-%VERSION%.tar.gz libtorrent-rasterbar-%VERSION%.tar.gz
echo Unzipping libtorrent...
call %SZIP% e %pathtome%libtorrent-rasterbar-%VERSION%.tar.gz -o%pathtome%
DEL /F /S /Q /A %pathtome%libtorrent-rasterbar-%VERSION%.tar.gz
call %SZIP% x %pathtome%libtorrent-rasterbar-%VERSION%.tar -o%pathtome%
DEL /F /S /Q /A %pathtome%libtorrent-rasterbar-%VERSION%.tar

mkdir %pathtome%libtorrent-rasterbar-%VERSION%\include\openssl
copy %pathtome%openssl\include\openssl %pathtome%libtorrent-rasterbar-%VERSION%\include\openssl

cd libtorrent-rasterbar-%VERSION%
call %pathtome%boost_1_62_0\bjam.exe link=static encryption=on crypto=openssl address-model=32 architecture=x86 variant=release variant=debug 
REM
cd ../

SETX LIBTORRENT_ROOT %pathtome%libtorrent-rasterbar-%VERSION% /m
SETX LIBTORRENT_INCLUDEDIR %pathtome%libtorrent-rasterbar-%VERSION%\include /m
SETX LIBTORRENT_LIBRARYDIR %pathtome%libtorrent-rasterbar-%VERSION%\bin\msvc-14.0\release\address-model-32\architecture-x86\crypto-openssl\link-static\threading-multi /m