@echo off
call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat"
SET pathtome=%~dp0
SET SZIP="C:\Program Files\7-Zip\7z.exe"
echo Downloading geoip...
git clone https://github.com/maxmind/geoip-api-c.git
mkdir geoip-api-c\data
call cscript scripts\wget.js http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz GeoIP.dat.gz
call cscript scripts\wget.js http://download.maxmind.com/download/geoip/database/asnum/GeoIPASNum.dat.gz GeoIPASNum.dat.gz

call %SZIP% e %pathtome%GeoIP.dat.gz -o%pathtome%geoip-api-c\data

mkdir %pathtome%geoip
mkdir %pathtome%geoip\build
mkdir %pathtome%geoip\build\data
mkdir %pathtome%geoip\build\bin
mkdir %pathtome%geoip\build\include
mkdir %pathtome%geoip\build\lib
cd geoip-api-c
cscript ..\scripts\geoip.js Makefile.vc C:\\\\Windows\\\\SYSTEM32 %pathtome%geoip\build\data 1
cscript ..\scripts\geoip.js Makefile.vc C:\\GeoIP %pathtome%geoip\build 0
nmake /f Makefile.vc
nmake /f Makefile.vc test
nmake /f Makefile.vc install
cd ..\

call %SZIP% e %pathtome%GeoIPASNum.dat.gz -o%pathtome%geoip\build\data

DEL /F /S /Q /A %pathtome%GeoIP.dat.gz
DEL /F /S /Q /A %pathtome%GeoIPASNum.dat.gz
rd /S /Q %pathtome%geoip-api-c

copy %pathtome%geoip\build\data\GeoIP.dat %pathtome%..\..\..\example\src\geoip\GeoIP.dat
copy %pathtome%geoip\build\data\GeoIPASNum.dat %pathtome%..\..\..\example\src\geoip\GeoIPASNum.dat

SETX GEOIP_INCLUDEDIR %pathtome%geoip\build\include /m
SETX GEOIP_LIBRARYDIR %pathtome%geoip\build\lib /m