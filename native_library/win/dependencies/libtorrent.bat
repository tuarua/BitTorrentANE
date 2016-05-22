@echo off
SET pathtome=%~dp0
SET SZIP="C:\Program Files\7-Zip\7z.exe"
echo Downloading libtorrent...
call cscript scripts\wget.js https://github.com/arvidn/libtorrent/releases/download/libtorrent-1_0_9/libtorrent-rasterbar-1.0.9.tar.gz libtorrent-rasterbar-1.0.9.tar.gz
echo Unzipping libtorrent...
call %SZIP% e %pathtome%libtorrent-rasterbar-1.0.9.tar.gz -o%pathtome%
DEL /F /S /Q /A %pathtome%libtorrent-rasterbar-1.0.9.tar.gz
call %SZIP% x %pathtome%libtorrent-rasterbar-1.0.9.tar -o%pathtome%
DEL /F /S /Q /A %pathtome%libtorrent-rasterbar-1.0.9.tar

mkdir %pathtome%libtorrent-rasterbar-1.0.9\include\openssl
copy %pathtome%SMP\msvc\include\openssl %pathtome%libtorrent-rasterbar-1.0.9\include\openssl

cd libtorrent-rasterbar-1.0.9
call %pathtome%boost_1_60_0\bjam.exe boost=source link=static geoip=static encryption=openssl address-model=32 architecture=x86 variant=debug variant=release
cd ../

SETX LIBTORRENT_ROOT %pathtome%libtorrent-rasterbar-1.0.9 /m
SETX LIBTORRENT_INCLUDEDIR %pathtome%libtorrent-rasterbar-1.0.9\include /m
SETX LIBTORRENT_LIBRARYDIR %pathtome%libtorrent-rasterbar-1.0.9\bin\msvc-14.0\release\address-model-32\architecture-x86\boost-source\encryption-openssl\geoip-static\link-static\threading-multi /m