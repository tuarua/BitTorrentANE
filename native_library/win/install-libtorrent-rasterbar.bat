REM https://github.com/arvidn/libtorrent/releases/download/libtorrent-1_0_9/libtorrent-rasterbar-1.0.9.tar.gz
@echo off
cd %LIBTORRENT_ROOT%
echo changing to %LIBTORRENT_ROOT%
bjam boost=source link=static geoip=static encryption=openssl address-model=32 architecture=x86 variant=debug variant=release