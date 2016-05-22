REM Get the path to the script and trim to get the directory.
@echo off
SET pathtome=%~dp0
SET ADL_PATH="C:\Program Files\Adobe\Adobe Flash Builder 4.7 (64 Bit)\sdks\4.6.0\bin\adl"
echo Running
call %ADL_PATH% -profile extendedDesktop -extdir %pathtome%/../native_extension/ane/debug/ -nodebug %pathtome%/bin-debug/BitTorrentANESample-app.xml