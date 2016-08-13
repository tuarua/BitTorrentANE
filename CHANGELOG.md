### 1.3.0
- Android: Added support.
- Win/OSX: reworked addTorrent to remove complexity from the client. Magnets, downloads and local files are all now handled by the one method
- Win/OSX: reworked events to more closely resemble those emmitted by libtorrent via new TorrentAlertEvent
- Win/OSX: improved torrent status calls.
- Win/OSX: renamed TorrentMeta class to TorrentInfo
- Win/OSX: changed means of whether to query trackers and peers thus improving performance
- Win/OSX: removed timePieces flags and experimental metods
- Win/OSX: improved progress bar in example
- Win/OSX: bug fixes

### 1.2.3

- Added new methods:  forceRecheck, forceAnnounce, forceDHTAnnounce, setPiecePriority, setPieceDeadline 
- Added file download finished event
- Added ability to specify sparse file storage
- Added ability to disable file storage
- Added scrollbar container to HTTP sources panel
- FIX: peer panel slow to update
- FIX: improve right click logic

### 1.2.2 
- Updated to libtorrent 1.1.0 (Please see preconfiguration sections below for how to update)
- Updated to AIR 22
- Minor changes and build script tidy up

### 1.2  
- 64bit OSX and Win 32