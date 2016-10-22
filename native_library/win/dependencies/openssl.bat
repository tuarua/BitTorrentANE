@echo off
echo Downloading openssl...
call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat"
SET pathtome=%~dp0
mkdir %pathtome%SMP\git
git clone https://github.com/ShiftMediaProject/openssl.git SMP\git\openssl
cd SMP\git\openssl\SMP
call MSBuild openssl.sln /t:Rebuild /p:Configuration=Release;Platform=x86
call MSBuild openssl.sln /t:Rebuild /p:Configuration=Debug;Platform=x86
cd ../../../..

SETX OPEN_SSL_INCLUDEDIR %pathtome%SMP\msvc\include /m
SETX OPEN_SSL_LIBRARYDIR %pathtome%SMP\msvc\lib\x86 /m