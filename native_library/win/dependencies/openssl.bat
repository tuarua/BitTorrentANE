@echo off
echo Downloading openssl...
call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat"
SET pathtome=%~dp0
SET SZIP="C:\Program Files\7-Zip\7z.exe"

REM https://github.com/ShiftMediaProject/openssl/releases/download/OpenSSL_1_0_2h/openssl_OpenSSL_1_0_2h_msvc14.zip

echo Downloading openssl...
call cscript scripts\wget.js https://github.com/ShiftMediaProject/openssl/releases/download/OpenSSL_1_0_2h/openssl_OpenSSL_1_0_2h_msvc14.zip openssl.zip
echo Unzipping openssl...
call %SZIP% x %pathtome%openssl.zip -o%pathtome%openssl
DEL /F /S /Q /A %pathtome%openssl.zip

SETX OPEN_SSL_INCLUDEDIR %pathtome%openssl\include /m
SETX OPEN_SSL_LIBRARYDIR %pathtome%openssl\lib\x86 /m