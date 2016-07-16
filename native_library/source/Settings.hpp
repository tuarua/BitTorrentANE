#pragma once
#include <stdint.h>
#include <string>
#include <vector>
typedef struct {
	bool timePieces = true;
	std::vector<std::string> priorityFileTypes = {};
	typedef struct {
		std::string outputPath;
		std::string torrentPath;
		std::string resumePath;
		std::string sessionStatePath;
		std::string geoipDataPath;
		bool sparse = true;
		bool enabled = true;
	}StorageContext;
	StorageContext storage;

	typedef struct {
		std::string filename;
		bool applyToTrackers = false;
	}FilterContext;
	FilterContext filters;

	typedef struct {
		uint32_t maxActiveDownloads;
		uint32_t maxActiveUploads;
		uint32_t maxActiveTorrents;
		bool ignoreSlow = false;
		bool enabled = false;
	}QueueingContext;
	QueueingContext queueing;

	typedef struct {
		bool useAnonymousMode = false;
		bool useDHT = false;
		bool usePEX = false;
		bool useLSD = false;
		int encryption;
	}PrivacyContext;
	PrivacyContext privacy;

	typedef struct {
		uint32_t maxNum;
		uint32_t maxNumPerTorrent;
		uint32_t maxUploads;
		uint32_t maxUploadsPerTorrent;
	}ConnectionContext;
	ConnectionContext connections;

	typedef struct {
		bool randomPort = false;
		bool useUPnP = false;
		uint32_t port;
	}ListeningContext;
	ListeningContext listening;

	typedef struct {
		uint32_t type;
		uint32_t port;
		std::string host;
		bool useForPeerConnections = false;
		bool force = false;
		bool useAuth = false;
		std::string username;
		std::string password;
	}ProxyContext;
	ProxyContext proxy;

	typedef struct {
		uint32_t uploadRateLimit;
		uint32_t downloadRateLimit;
		bool isuTPEnabled = false;
		bool isuTPRateLimited = false;
		bool rateLimitIpOverhead = false;
		bool ignoreLimitsOnLAN = false;
	}SpeedContext;
	SpeedContext speed;

	typedef struct {
		bool announceToAllTrackers = false;
		bool enableTrackerExchange = false;
		int32_t diskCacheSize;
		uint32_t diskCacheTTL;
		bool enableOsCache = false;
		int outgoingPortsMin;
		int outgoingPortsMax;
		bool isSuperSeedingEnabled = false;
		bool recheckTorrentsOnCompletion = false;
		bool resolveCountries = false;
		bool resolvePeerHostNames = false;
		bool strictSuperSeeding = false;
		uint32_t numMaxHalfOpenConnections;
		std::vector<std::pair<std::string, std::string>> networkInterface;
		bool listenOnIPv6 = false;
		std::string announceIP;
	}AdvancedContext;
	AdvancedContext advanced;

}SettingsContext;
SettingsContext settingsContext;

typedef struct {
	std::string inputFile;
	std::string outputFile;
	std::vector<std::string> webSeeds;
	std::vector<std::string> trackers;
	uint32_t pieceSize;
	bool isPrivate = false;
	bool seedNow = false;
	std::string comment;
	std::string creator;
	std::string rootCert;
}CreateTorrentContext;
CreateTorrentContext createTorrentContext;