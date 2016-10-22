@echo off
SET pathtome=%~dp0
SET SZIP="C:\Program Files\7-Zip\7z.exe"
echo Downloading libtorrent...
call cscript scripts\wget.js https://github.com/arvidn/libtorrent/releases/download/libtorrent-1_1_1/libtorrent-rasterbar-1.1.1.tar.gz libtorrent-rasterbar-1.1.1.tar.gz
echo Unzipping libtorrent...
call %SZIP% e %pathtome%libtorrent-rasterbar-1.1.1.tar.gz -o%pathtome%
DEL /F /S /Q /A %pathtome%libtorrent-rasterbar-1.1.1.tar.gz
call %SZIP% x %pathtome%libtorrent-rasterbar-1.1.1.tar -o%pathtome%
DEL /F /S /Q /A %pathtome%libtorrent-rasterbar-1.1.1.tar

mkdir %pathtome%libtorrent-rasterbar-1.1.1\include\openssl
copy %pathtome%SMP\msvc\include\openssl %pathtome%libtorrent-rasterbar-1.1.1\include\openssl

cd libtorrent-rasterbar-1.1.1
call %pathtome%boost_1_62_0\bjam.exe link=static encryption=on crypto=openssl address-model=32 architecture=x86 variant=release variant=debug 
cd ../

SETX LIBTORRENT_ROOT %pathtome%libtorrent-rasterbar-1.1.1 /m
SETX LIBTORRENT_INCLUDEDIR %pathtome%libtorrent-rasterbar-1.1.1\include /m
SETX LIBTORRENT_LIBRARYDIR %pathtome%libtorrent-rasterbar-1.1.1\bin\msvc-14.0\release\address-model-32\architecture-x86\crypto-openssl\link-static\threading-multi /m