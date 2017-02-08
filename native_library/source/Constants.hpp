#pragma once
typedef struct {
    std::string TORRENT_CREATED = "Torrent.Create.Created";
    std::string TORRENT_CREATION_PROGRESS = "Torrent.Create.Progress";
    std::string TORRENT_UNAVAILABLE = "Torrent.Unavailable";
    std::string TORRENT_DOWNLOADED = "Torrent.Downloaded";
    std::string DHT_STARTED = "Torrent.DHT.Started";
    std::string ON_ERROR = "Torrent.Error";
    std::string FILTER_LIST_ADDED = "Torrent.Filter.ListAdded";
} TorrentInfoEvent;
TorrentInfoEvent torrentInfoEvent;

typedef struct {
    const std::string STATE_UPDATE = "Torrent.Alert.StateUpdate";
    const std::string STATE_CHANGED = "Torrent.Alert.StateChanged";
    const std::string TORRENT_FINISHED = "Torrent.Alert.TorrentFinished";
    const std::string TORRENT_ADDED = "Torrent.Alert.TorrentAdded";
    const std::string TORRENT_PAUSED = "Torrent.Alert.TorrentPaused";
    const std::string TORRENT_RESUMED = "Torrent.Alert.TorrentResumed";
    const std::string TORRENT_CHECKED = "Torrent.Alert.TorrentChecked";
    const std::string PIECE_FINISHED = "Torrent.Piece.Finished";
    const std::string METADATA_RECEIVED = "Torrent.Alert.MetaDataReceived";
    const std::string FILE_COMPLETED = "Torrent.Alert.FileCompleted";
    const std::string SAVE_RESUME_DATA = "Torrent.Alert.SaveResumeData";
    const std::string LISTEN_FAILED = "Torrent.Alert.ListenFailed";
    const std::string LISTEN_SUCCEEDED = "Torrent.Alert.ListenSucceeded";

} TorrentAlertEvent;
TorrentAlertEvent torrentAlertEvent;


class EncyptionConstants {
public:
    enum Constants {
        DISABLED = 0,
        ENABLED = 1,
        REQUIRED = 2
    };
};

class LogLevelConstants {
public:
    enum Constants {
        QUIET = 0,
        INFO = 1,
        DBG = 2
    };
};

class ProxyTypeConstants {
public:
    enum Constants {
        DISABLED = 0,
        SOCKS4 = 1,
        SOCKS5 = 2,
        HTTP = 3,
        I2P = 4
    };
};

class QueuePositionConstants {
public:
    enum Constants {
        UP = 0,
        DOWN = 1,
        TOP = 2,
        BOTTOM = 3
    };
};