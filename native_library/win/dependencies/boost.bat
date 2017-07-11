@echo off
SET pathtome=%~dp0
SET SZIP="C:\Program Files\7-Zip\7z.exe"
SET BOOST_VERSION="1_64_0"
echo Downloading boost...
call cscript scripts\wget.js http://freefr.dl.sourceforge.net/project/boost/boost/1.64.0/boost_1_64_0.7z boost_1_64_0.7z
echo Unzipping boost...
call %SZIP% x %pathtome%boost_1_64_0.7z -o%pathtome%
echo Bootstrapping boost...
cd %pathtome%boost_%BOOST_VERSION%
call bootstrap
call b2 variant=release toolset=msvc-14.1 --with-thread --with-date_time --with-system --with-random --with-atomic address-model=32 architecture=x86 link=static runtime-link=static threading=multi --stagedir=stage_x86 stage
call bjam variant=release toolset=msvc-14.1 --with-thread --with-date_time --with-system --with-random --with-atomic address-model=32 architecture=x86 link=static threading=multi --stagedir=stage_x86 stage

call b2 variant=release toolset=msvc-14.1 --with-thread --with-date_time --with-system --with-random --with-atomic address-model=64 architecture=x86 link=static runtime-link=static threading=multi --stagedir=stage_x64 stage
call bjam variant=release toolset=msvc-14.1 --with-thread --with-date_time --with-system --with-random --with-atomic address-model=64 architecture=x86 link=static threading=multi --stagedir=stage_x64 stage

cd ..\
DEL /F /S /Q /A %pathtome%boost_1_64_0.7z

SETX BOOST_ROOT %pathtome%boost_1_64_0 /m
SETX BOOST_INCLUDEDIR %pathtome%boost_1_64_0\boost /m
