@echo off
SET pathtome=%~dp0
SET SZIP="C:\Program Files\7-Zip\7z.exe"

SET projectName=BitTorrentANE

REM copy ..\..\..\..\flash\BitTorrentANE-android\native_extension\bin\%projectName%.swc %projectName%.swc

copy %pathtome%..\bin\%projectName%.swc %pathtome%

REM contents of SWC.
copy /Y %pathtome%%projectName%.swc %pathtome%%projectName%Extract.swc
ren %pathtome%%projectName%Extract.swc %projectName%Extract.zip
call %SZIP% e %pathtome%%projectName%Extract.zip -o%pathtome%
del %pathtome%%projectName%Extract.zip

REM Copy library.swf to folders.
echo Copying library.swf into place.
copy %pathtome%library.swf %pathtome%platforms\android

echo copy the aar into place
copy /Y %pathtome%..\..\native_library\android\%projectName%\app\build\outputs\aar\app-debug.aar %pathtome%platforms\android\app-debug.aar

echo "GETTING ANDROID JAR"
call %SZIP% x %pathtome%platforms\android\app-debug.aar -o%pathtome%platforms\android\ classes.jar
call %SZIP% x %pathtome%platforms\android\app-debug.aar -o%pathtome%platforms\android\ libs\jlibtorrent-1.1.1.37.jar
call %SZIP% x %pathtome%platforms\android\app-debug.aar -o%pathtome%platforms\android\ libs\geoip2-2.7.0.jar
call %SZIP% x %pathtome%platforms\android\app-debug.aar -o%pathtome%platforms\android\ libs\maxmind-db-1.2.1.jar
call %SZIP% x %pathtome%platforms\android\app-debug.aar -o%pathtome%platforms\android\ libs\jackson-annotations-2.7.0.jar
call %SZIP% x %pathtome%platforms\android\app-debug.aar -o%pathtome%platforms\android\ libs\jackson-core-2.7.3.jar
call %SZIP% x %pathtome%platforms\android\app-debug.aar -o%pathtome%platforms\android\ libs\jackson-databind-2.7.3.jar

move %pathtome%platforms\android\libs\jlibtorrent-1.1.1.37.jar %pathtome%platforms\android
move %pathtome%platforms\android\libs\geoip2-2.7.0.jar %pathtome%platforms\android
move %pathtome%platforms\android\libs\maxmind-db-1.2.1.jar %pathtome%platforms\android
move %pathtome%platforms\android\libs\jackson-annotations-2.7.0.jar %pathtome%platforms\android
move %pathtome%platforms\android\libs\jackson-core-2.7.3.jar %pathtome%platforms\android
move %pathtome%platforms\android\libs\jackson-databind-2.7.3.jar %pathtome%platforms\android

echo "GENERATING ANE"
call adt.bat -package -target ane %projectName%-android.ane extension_android.xml ^
-swc %projectName%.swc ^
-platform Android-ARM ^
-C platforms/android library.swf classes.jar libs/armeabi/libjlibtorrent.so ^
libs/armeabi-v7a/libjlibtorrent.so ^
-platformoptions platforms/android/platform.xml res/values/strings.xml ^
jlibtorrent-1.1.1.37.jar ^
geoip2-2.7.0.jar ^
maxmind-db-1.2.1.jar ^
jackson-annotations-2.7.0.jar ^
jackson-core-2.7.3.jar ^
jackson-databind-2.7.3.jar ^
-platform Android-x86 ^
-C platforms/android library.swf classes.jar ^
libs/x86/libjlibtorrent.so ^
-platformoptions platforms/android/platform.xml res/values/strings.xml ^
jlibtorrent-1.1.1.37.jar ^
geoip2-2.7.0.jar ^
maxmind-db-1.2.1.jar ^
jackson-annotations-2.7.0.jar ^
jackson-core-2.7.3.jar ^
jackson-databind-2.7.3.jar

del platforms\\android\\library.swf
del platforms\\android\\classes.jar
del platforms\\android\\jlibtorrent-1.1.1.37.jar
del platforms\\android\\geoip2-2.7.0.jar
del platforms\\android\\maxmind-db-1.2.1.jar
del platforms\\android\\jackson-annotations-2.7.0.jar
del platforms\\android\\jackson-core-2.7.3.jar
del platforms\\android\\jackson-databind-2.7.3.jar
call DEL /F /Q /A %pathtome%library.swf
call DEL /F /Q /A %pathtome%catalog.xml
call DEL /F /Q /A %pathtome%%projectName%.swc

echo "DONE!"