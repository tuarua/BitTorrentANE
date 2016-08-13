# BitTorrentANE

Adobe Air Native Extension written in ActionScript 3 and C++ for working with .torrent files and magnet uris.
Sample client included

![alt tag](https://raw.githubusercontent.com/tuarua/BitTorrentANE/master/screenshots/screen-shot-1.PNG

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
 - Supports RSS feeds
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
 
 - Flash Builder 4.7
 - AIR 22 SDK
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
 - Add ASDocs

### License

The MIT License (MIT)

Copyright (c) [2016] [Tua Rua Ltd.]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
