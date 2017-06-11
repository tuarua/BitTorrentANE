@echo off
SET pathtome=%~dp0
SET SZIP="C:\Program Files\7-Zip\7z.exe"
echo Downloading boost...
call cscript scripts\wget.js http://freefr.dl.sourceforge.net/project/boost/boost/1.62.0/boost_1_62_0.7z boost_1_62_0.7z
echo Unzipping boost...
call %SZIP% x %pathtome%boost_1_62_0.7z -o%pathtome%
echo Bootstrapping boost...
cd %pathtome%boost_1_62_0
call bootstrap
call b2 variant=release debug toolset=msvc architecture=x86 address-model=32 link=static runtime-link=static threading=multi stage
call bjam variant=release debug toolset=msvc architecture=x86 address-model=32 link=static threading=multi stage
cd ..\
DEL /F /S /Q /A %pathtome%boost_1_62_0.7z

SETX BOOST_ROOT %pathtome%boost_1_62_0 /m
SETX BOOST_LIBRARYDIR %pathtome%boost_1_62_0\stage\lib /m
SETX BOOST_INCLUDEDIR %pathtome%boost_1_62_0\boost /m