#pragma once
#include <stdint.h>
#include <string>

typedef struct {
	//std::string TORRENT_CREATED_FROM_META = "Torrent.Create.CreatedFromMeta";
	std::string TORRENT_CREATED = "Torrent.Create.Created";
	std::string TORRENT_CREATION_PROGRESS = "Torrent.Create.Progress";
	//std::string TORRENT_FROM_RESUME = "Torrent.Resume";
	//std::string TORRENT_ADDED = "Torrent.Added";
	//std::string TORRENT_CHECKED = "Torrent.Checked";
	//std::string TORRENT_PIECE = "Torrent.Piece";
	//std::string TORRENT_FILE_COMPLETE = "Torrent.File.Complete";
	std::string TORRENT_UNAVAILABLE = "Torrent.Unavailable";
	std::string TORRENT_DOWNLOADED = "Torrent.Downloaded";
	//std::string RESUME_SAVED = "Torrent.Resume.Saved";
	std::string DHT_STARTED = "Torrent.DHT.Started";
	std::string ON_ERROR = "Torrent.Error";
	//std::string RSS_STATE_CHANGE = "Torrent.RSS.StateChange";
	//std::string RSS_ITEM = "Torrent.RSS.Item";
	std::string FILTER_LIST_ADDED = "Torrent.Filter.ListAdded";
}TorrentInfoEvent;
TorrentInfoEvent torrentInfoEvent;

typedef struct {
	const std::string STATE_UPDATE= "Torrent.Alert.StateUpdate";
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

}TorrentAlertEvent;
TorrentAlertEvent torrentAlertEvent;

/*
public static const STATE_UPDATE:String = "Torrent.Alert.StateUpdate";
public static const STATE_CHANGED:String = "Torrent.Alert.StateChanged";
public static const TORRENT_FINISHED:String = "Torrent.Alert.TorrentFinished";
public static const TORRENT_ADDED:String = "Torrent.Alert.TorrentAdded";
public static const TORRENT_PAUSED:String = "Torrent.Alert.TorrentPaused";
public static const TORRENT_RESUMED:String = "Torrent.Alert.TorrentResumed";
public static const TORRENT_CHECKED:String = "Torrent.Alert.TorrentChecked";
public static const PIECE_FINISHED:String = "Torrent.Piece.Finished";
public static const METADATA_RECEIVED:String = "Torrent.Alert.MetaDataReceived";
public static const FILE_COMPLETED:String = "Torrent.Alert.FileCompleted";
public static const SAVE_RESUME_DATA:String = "Torrent.Alert.SaveResumeData";



public static const TORRENT_CREATED:String = "Torrent.Create.Created";
public static const TORRENT_CREATION_PROGRESS:String = "Torrent.Create.Progress";
public static const TORRENT_UNAVAILABLE:String = "Torrent.Unavailable";
public static const TORRENT_DOWNLOADED:String = "Torrent.Downloaded";
public static const DHT_STARTED:String = "Torrent.DHT.Started";
public static const ON_ERROR:String = "Torrent.Error";
public static const FILTER_LIST_ADDED:String = "Torrent.Filter.ListAdded";

*/

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