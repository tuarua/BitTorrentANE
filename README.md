# BitTorrentANE

Adobe Air Native Extension written in ActionScript 3 and C++ for working with .torrent files and magnet uris.
Sample client included

![alt tag](https://raw.githubusercontent.com/tuarua/BitTorrentANE/master/screenshots/screen-shot-1.PNG)

### Features
 - Supports Magnet uris
 - Supports .torrent files
 - Supports "fast resume"
 - Supports DHT, PeX and LSD
 - Supports I2P
 - Sequential downloading
 - Supports PeerGuardian .p2p filter lists
 - Filetype prioritization
 - Supports torrent queue ordering
 - Allow port forwarding UPnP
 - Ability to create .torrent files

### Tech

BitTorrentANE uses the following libraries:  
C++  
* [http://www.libtorrent.org] - C++ bittorrent implementation  
* [http://www.boost.org] - C++ portable libraries
* [https://www.openssl.org] - OpenSSL
* [https://github.com/maxmind/geoip-api-c] - GeoIp
* [http://www.frogtoss.com/labs] - Native File Dialog
* [https://github.com/nlohmann/json/] - JSON for Modern C++

Android 
* [https://github.com/maxmind/GeoIP2-java] - GeoIP2 for Java
* [https://github.com/frostwire/frostwire-jlibtorrent] - Java interface for libtorrent from Frostwire

### Prerequisites

You will need
 
 - Flash Builder 4.7 / Intelli J
 - AIR 25 SDK
 - Homebrew if you wish to modify the ANE code on OSX
 - XCode if you wish to modify the ANE code on OSX
 - MS Visual Studio 2015 if you wish to modify the ANE code on Windows
 - Android Studio if you wish to modify the ANE code for Android


### OSX Preconfiguration to modify the ANE code:
 - Install Homebrew
 - from the Terminal run:  
    brew update  
    brew install boost  
    brew install openssl  
    brew install libtorrent-rasterbar --with-geoip  

### Win Preconfiguration to modify the ANE code:
 - Install Visual Studio 2015
 - Install YASM for Visual Studio [http://yasm.tortall.net/Download.html]
 - Install 7Zip [http://7-zip.org]
 - Run native_library/win/dependencies/RUNME.bat from cmd as Administrator.
This will download and build the remaining dependencies needed (boost, geoip, libtorrent, openssl)

### Android Preconfiguration to modify the ANE code:
to follow...

### Known Issues
 - The Visual Studio project only builds in Release mode. The Debug build throws errors.
 
### Todos
 - improve error reporting
