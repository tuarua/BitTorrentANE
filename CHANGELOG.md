### 1.3.3
- Win/OSX: updated Libtorrent to 1.1.3
- OSX: updated Boost to 1.64

### 1.3.2
- Win/OSX: updated Libtorrent to 1.1.1, Boost to 1.62, OpenSSL to latest
- Android: fixed bug with output savePath
- changed compile version to AIR 19 for better compatability
- Android: Updated example. Removed HLS code as there are vidoe bugs in AIR.
- All: Updated Starling to 2.1

### 1.3.1
- Android: Updated example
- Android: Updated jlibtorrent to 1.1.1.37
- Win/OSX/Android: Added resetPieceDeadline method
- Win/OSX: Fix BUG with url seeds when creating torrent
- Win/OSX: Added setPieceDeadline method
- Win/OSX: Minor fixes

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
