#pragma once
#include <stdint.h>
#include <string>

typedef struct {
	std::string TORRENT_CREATED_FROM_META = "Torrent.Create.CreatedFromMeta";
	std::string TORRENT_CREATED = "Torrent.Create.Created";
	std::string TORRENT_CREATION_PROGRESS = "Torrent.Create.Progress";
	std::string TORRENT_FROM_RESUME = "Torrent.Resume";
	std::string TORRENT_ADDED = "Torrent.Added";
	std::string TORRENT_CHECKED = "Torrent.Checked";
	std::string TORRENT_PIECE = "Torrent.Piece";
	std::string TORRENT_FILE_COMPLETE = "Torrent.File.Complete";
	std::string TORRENT_UNAVAILABLE = "Torrent.Unavailable";
	std::string TORRENT_DOWNLOADED = "Torrent.Downloaded";
	std::string RESUME_SAVED = "Torrent.Resume.Saved";
	std::string DHT_STARTED = "Torrent.DHT.Started";
	std::string ON_ERROR = "Torrent.Error";
	std::string RSS_STATE_CHANGE = "Torrent.RSS.StateChange";
	std::string RSS_ITEM = "Torrent.RSS.Item";
	std::string FILTERLIST_ADDED = "Torrent.Filter.ListAdded";
}TorrentInfoEvent;
TorrentInfoEvent torrentInfoEvent;

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