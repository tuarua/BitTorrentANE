# BitTorrentANE

Adobe Air Native Extension written in ActionScript 3 and C++ for working with .torrent files and magnet uris.


### Version
- 1.0 OSX version only
- 1.1 64bit OSX version only
- 1.2 64bit OSX and Win 32

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

LibTorrentANE uses the following libraries:

* [http://www.libtorrent.org] - C++ bittorrent implementation
* [http://www.boost.org] - C++ portable libraries
* [https://www.openssl.org] - OpenSSL

### Prerequisites

You will need
 
 - Flash Builder 4.7
 - AIR 21 SDK
 - Homebrew if you wish to modify the ANE code on OSX
 - XCode if you wish to modify the ANE code on OSX
 - MS Visual Studio 2015 if you wish to modify the ANE code on Windows

### OSX Preconfiguration
 - to modify the ANE code:
 - Install Homebrew
 - run brew install boost libtorrent-rasterbar --with-geoip

### Win Preconfiguration

### Todos


 - Add ASDocs
 - Android Version


