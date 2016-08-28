#include "BitTorrentANE.h"
#ifdef _WIN32

#else
#define __ASSERT_MACROS_DEFINE_VERSIONS_WITHOUT_UNDERSCORES 0
//#define BOOST_ASIO_SEPARATE_COMPILATION 0
#define TORRENT_USE_I2P 1
#define TORRENT_USE_OPENSSL 1
#endif

#include <stdint.h>
#include <iterator>
#include <sstream>
#include <vector>

#ifdef _WIN32
#include <windows.h>
#include <conio.h>
#else
#include <stdlib.h>
#include <stdio.h>
#endif
#include <cstring>
#include <cstdarg>

#include <iostream>
#include <utility>
#include <string>
#include <complex>
#include <tuple>
#include <fstream>
#include <array>
#include <math.h>
#include <map>
#include "nfd.h"
#include <boost/lexical_cast.hpp>
#include <boost/numeric/conversion/cast.hpp>
#include <boost/algorithm/string/split.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/asio/ip/address.hpp>
#include <boost/thread.hpp>
#include <boost/chrono.hpp>
#include <boost/format.hpp>
#include <boost/optional/optional_io.hpp>
#include <boost/bimap.hpp>
#include <boost/random/mersenne_twister.hpp>
#include <boost/random/uniform_int.hpp>
#include <boost/random/variate_generator.hpp>
#include <boost/random/random_device.hpp>

#include "libtorrent/version.hpp"
#include "libtorrent/entry.hpp"

#include "libtorrent/bencode.hpp"
#include "libtorrent/session.hpp"
#include "libtorrent/alert_types.hpp"
#include "libtorrent/create_torrent.hpp"
#include "libtorrent/file.hpp"
#include "libtorrent/storage.hpp"
#include "libtorrent/hasher.hpp"
#include "libtorrent/file_pool.hpp"
#include "libtorrent/session_settings.hpp"
#include "libtorrent/magnet_uri.hpp"
#include "libtorrent/ip_filter.hpp"
#include "libtorrent/extensions/ut_pex.hpp"
#include "libtorrent/extensions/lt_trackers.hpp"
#include "libtorrent/extensions/smart_ban.hpp"
#include "libtorrent/extensions/ut_metadata.hpp"
#include "libtorrent/peer_info.hpp"
#include "libtorrent/identify_client.hpp"

//new
#include "libtorrent/extensions/ut_pex.hpp"
#include "libtorrent/torrent_info.hpp"
#include "libtorrent/announce_entry.hpp"
#include "libtorrent/bitfield.hpp"
#include "libtorrent/bdecode.hpp"
#include "libtorrent/add_torrent_params.hpp"
#include "libtorrent/time.hpp"
#include "libtorrent/file.hpp"
#include "libtorrent/storage.hpp"


#include "json.hpp"

#ifdef _WIN32
#include "FlashRuntimeExtensions.h"
bool isSupportedInOS = true;
std::string pathSlash = "\\";
#else
#include <Adobe AIR/Adobe AIR.h>
bool isSupportedInOS = true;
std::string pathSlash = "/";
#endif

#include "ANEhelper.h"
#include "Constants.hpp"
#include "Settings.hpp"


std::string clientName;

libtorrent::session* ltsession = nullptr;

struct addedTorrentId{};
struct addedTorrentHash{};
using namespace boost::bimaps;
typedef bimap<
	tagged<std::string, addedTorrentId>,
	tagged<std::string, addedTorrentHash>
> AddedTorrents;
typedef AddedTorrents::value_type hashes;
AddedTorrents addedTorrents;

typedef std::map<uint32_t, std::string> AddedTorrentHandles;
AddedTorrentHandles addedTorrentHandles;

typedef std::map<std::string, std::string> AddedMagnetsUriMap;
AddedMagnetsUriMap addedMagnetsUriMap;

typedef std::map<std::string, int> TrackerPeerMap;
typedef std::map<std::string, TrackerPeerMap> TorrentTrackerPeerMap;
TorrentTrackerPeerMap torrentTrackerPeerMap;

const uint32_t statusFlags = libtorrent::torrent_handle::query_accurate_download_counters
| libtorrent::torrent_handle::query_distributed_copies
| libtorrent::torrent_handle::query_pieces
| libtorrent::torrent_handle::query_save_path;

extern std::string getHashFromId(std::string const id) {
	using namespace std;
	string ret = id;
	auto search = addedTorrents.by<addedTorrentId>().find(id); 
	if (search != addedTorrents.by<addedTorrentId>().end())
		ret = search->get<addedTorrentHash>();
	return ret;
}
extern std::string getIdFromHash(std::string const hash) {
	using namespace std;
	string ret = hash;
auto search = addedTorrents.by<addedTorrentHash>().find(hash);
	if (search != addedTorrents.by<addedTorrentHash>().end())
		ret = search->get<addedTorrentId>();
	return ret;
}

extern int loadFile(std::string const& filename, std::vector<char>& v, libtorrent::error_code& ec, int limit = 8000) {
	ec.clear();
	FILE* f = fopen(filename.c_str(), "rb");
	if (f == NULL) {
		ec.assign(errno, boost::system::get_generic_category());
		return -1;
	}

	int r = fseek(f, 0, SEEK_END);
	if (r != 0) {
		ec.assign(errno, boost::system::get_generic_category());
		fclose(f);
		return -1;
	}
	long s = ftell(f);
	if (s < 0) {
		ec.assign(errno, boost::system::get_generic_category());
		fclose(f);
		return -1;
	}

	if (s > limit) {
		fclose(f);
		return -2;
	}

	r = fseek(f, 0, SEEK_SET);
	if (r != 0) {
		ec.assign(errno, boost::system::get_generic_category());
		fclose(f);
		return -1;
	}

	v.resize(s);
	if (s == 0) {
		fclose(f);
		return 0;
	}

	r = fread(&v[0], 1, v.size(), f);
	if (r < 0) {
		ec.assign(errno, boost::system::get_generic_category());
		fclose(f);
		return -1;
	}

	fclose(f);

	if (r != s) return -3;

	return 0;
}

libtorrent::torrent_info readTorrentInfo(std::string const& filename) {
	using namespace libtorrent;
	int item_limit = 1000000;
	int depth_limit = 1000;
	std::vector<char> buf;
	error_code ec;
	int ret = loadFile(filename, buf, ec, 40 * item_limit);
	bdecode_node e;
	int pos = -1;
	ret = bdecode(&buf[0], &buf[0] + buf.size(), e, ec, &pos, depth_limit, item_limit);
	torrent_info ti(e, ec);
	e.clear();
	std::vector<char>().swap(buf);
	return ti;
}

inline unsigned char from_hex(unsigned char ch) {
	if (ch <= '9' && ch >= '0')
		ch -= '0';
	else if (ch <= 'f' && ch >= 'a')
		ch -= 'a' - 10;
	else if (ch <= 'F' && ch >= 'A')
		ch -= 'A' - 10;
	else
		ch = 0;
	return ch;
}


const std::string urldecode(const std::string& str) {
	using namespace std;
	string result;
	string::size_type i;
	for (i = 0; i < str.size(); ++i) {
		if (str[i] == '+') {
			result += ' ';
		}
		else if (str[i] == '%' && str.size() > i + 2) {
			const unsigned char ch1 = from_hex(str[i + 1]);
			const unsigned char ch2 = from_hex(str[i + 2]);
			const unsigned char ch = (ch1 << 4) | ch2;
			result += ch;
			i += 2;
		}else{
			result += str[i];
		}
	}
	return result;
}


FREObject getFRETorrentInfo(libtorrent::torrent_info ti, std::string filename) {
	using namespace libtorrent;
	FREObject torrentMeta = NULL;
	FRENewObject((const uint8_t*)"com.tuarua.torrent.TorrentInfo", 0, NULL, &torrentMeta, NULL);
	FRESetObjectProperty(torrentMeta, (const uint8_t*)"status", getFREObjectFromString("ok"), NULL);
	FRESetObjectProperty(torrentMeta, (const uint8_t*)"isPrivate", getFREObjectFromBool(ti.priv()), NULL);
	FRESetObjectProperty(torrentMeta, (const uint8_t*)"torrentFile", getFREObjectFromString(filename), NULL);
	FRESetObjectProperty(torrentMeta, (const uint8_t*)"numPieces", getFREObjectFromInt32(ti.num_pieces()), NULL);
	FRESetObjectProperty(torrentMeta, (const uint8_t*)"size", getFREObjectFromUint32((uint32_t)ti.total_size()), NULL);
	FRESetObjectProperty(torrentMeta, (const uint8_t*)"pieceLength", getFREObjectFromInt32(ti.piece_length()), NULL);
	FRESetObjectProperty(torrentMeta, (const uint8_t*)"infoHash", getFREObjectFromString(boost::lexical_cast<std::string>(ti.info_hash())), NULL);
	FRESetObjectProperty(torrentMeta, (const uint8_t*)"name", getFREObjectFromString(ti.name()), NULL);
	FRESetObjectProperty(torrentMeta, (const uint8_t*)"comment", getFREObjectFromString(ti.comment()), NULL);
	FRESetObjectProperty(torrentMeta, (const uint8_t*)"creator", getFREObjectFromString(ti.creator()), NULL);
	FRESetObjectProperty(torrentMeta, (const uint8_t*)"creationDate", getFREObjectFromUint32(boost::numeric_cast<uint32_t>(ti.creation_date().get())), NULL);
	file_storage const& sto = ti.files();
	FREObject vecTorrents = NULL;
	FRENewObject((const uint8_t*)"Vector.<com.tuarua.torrent.TorrentFileMeta>", 0, NULL, &vecTorrents, NULL);
	FRESetArrayLength(vecTorrents, sto.num_files());

	for (int i = 0; i < sto.num_files(); ++i) {
		int first = sto.map_file(i, 0, 0).piece;
		int last = sto.map_file(i, (std::max)(boost::int64_t(sto.file_size(i)) - 1, boost::int64_t(0)), 0).piece;
		FREObject meta;
		FRENewObject((const uint8_t*)"com.tuarua.torrent.TorrentFileMeta", 0, NULL, &meta, NULL);
		FRESetObjectProperty(meta, (const uint8_t*)"path", getFREObjectFromString(sto.file_path(i)), NULL);
		FRESetObjectProperty(meta, (const uint8_t*)"name", getFREObjectFromString(sto.file_name(i)), NULL);
		FRESetObjectProperty(meta, (const uint8_t*)"offset", getFREObjectFromUint32((uint32_t)sto.file_offset(i)), NULL);
		FRESetObjectProperty(meta, (const uint8_t*)"size", getFREObjectFromUint32((uint32_t)sto.file_size(i)), NULL);
		FRESetObjectProperty(meta, (const uint8_t*)"firstPiece", getFREObjectFromInt32(first), NULL);
		FRESetObjectProperty(meta, (const uint8_t*)"lastPiece", getFREObjectFromInt32(last), NULL);
		FRESetArrayElementAt(vecTorrents, i, meta);
	}
	FRESetObjectProperty(torrentMeta, (const uint8_t*)"files", vecTorrents, NULL);
		
	FREObject vecUrlSeeds = NULL;
	FRENewObject((const uint8_t*)"Vector.<String>", 0, NULL, &vecUrlSeeds, NULL);
					
	std::vector<web_seed_entry> webSeeds;
	webSeeds = ti.web_seeds();
	 
	FRESetArrayLength(vecUrlSeeds, uint32_t(webSeeds.size()));
	int cnt = 0;
	for (std::vector<web_seed_entry>::const_iterator i = webSeeds.begin(); i != webSeeds.end(); ++i) {
		FRESetArrayElementAt(vecUrlSeeds, cnt, getFREObjectFromString(i->url));
		cnt++;
	}
	FRESetObjectProperty(torrentMeta, (const uint8_t*)"urlSeeds", vecUrlSeeds, NULL);
		
	return torrentMeta;
}

libtorrent::settings_pack getDefaultSessionSettings(std::vector<std::string> dhtRouters) {
	using namespace libtorrent;
	settings_pack settings;
	
	settings.set_str(settings_pack::user_agent, clientName);
	settings.set_bool(settings_pack::apply_ip_filter_to_trackers, (!settingsContext.filters.filename.empty() && settingsContext.filters.applyToTrackers));
	settings.set_bool(settings_pack::upnp_ignore_nonrouters,true);
	settings.set_int(settings_pack::ssl_listen,0);
	settings.set_bool(settings_pack::lazy_bitfields, true);
	
	settings.set_int(settings_pack::stop_tracker_timeout,1);
	settings.set_int(settings_pack::auto_scrape_interval, 1200);
	settings.set_int(settings_pack::auto_scrape_min_interval, 900);
	settings.set_bool(settings_pack::announce_to_all_trackers, settingsContext.advanced.announceToAllTrackers);
	settings.set_bool(settings_pack::announce_to_all_tiers, settingsContext.advanced.announceToAllTrackers);

	int cache_size = settingsContext.advanced.diskCacheSize;
	if(cache_size > 0)
		cache_size = cache_size * 64;  //0 is off, -1 is 1/8 of machine's RAM

	settings.set_int(settings_pack::cache_size, cache_size);
	settings.set_int(settings_pack::cache_expiry, settingsContext.advanced.diskCacheTTL);
	settings_pack::io_buffer_mode_t mode = settingsContext.advanced.enableOsCache ? settings_pack::enable_os_cache : settings_pack::disable_os_cache;

	settings.set_int(settings_pack::disk_io_read_mode, mode);
	settings.set_int(settings_pack::disk_io_write_mode, mode);
	settings.set_bool(settings_pack::anonymous_mode, settingsContext.privacy.useAnonymousMode);
	settings.set_bool(settings_pack::lock_files, false);

	// Queueing System
	if (settingsContext.queueing.enabled) {
		settings.set_int(settings_pack::active_downloads, settingsContext.queueing.maxActiveDownloads);
		settings.set_int(settings_pack::active_limit, settingsContext.queueing.maxActiveTorrents);
		settings.set_int(settings_pack::active_seeds, settingsContext.queueing.maxActiveUploads);
		settings.set_bool(settings_pack::dont_count_slow_torrents, settingsContext.queueing.ignoreSlow);
	} else {
		settings.set_int(settings_pack::active_downloads, -1);
		settings.set_int(settings_pack::active_limit, -1);
		settings.set_int(settings_pack::active_seeds, -1);
	}

	settings.set_int(settings_pack::active_tracker_limit, -1);
	settings.set_int(settings_pack::active_dht_limit, -1);
	settings.set_int(settings_pack::active_lsd_limit, -1);

	if (settingsContext.advanced.outgoingPortsMin > 0 && settingsContext.advanced.outgoingPortsMax > 0 && settingsContext.advanced.outgoingPortsMin < settingsContext.advanced.outgoingPortsMax) {
		int port;
		port = 0;
		boost::mt19937 gen;
		boost::uniform_int<> dist(settingsContext.advanced.outgoingPortsMin, settingsContext.advanced.outgoingPortsMax);
		boost::variate_generator<boost::mt19937&, boost::uniform_int<> > randRange(gen, dist);
		settings.set_int(settings_pack::outgoing_port, randRange());
	}

	settings.set_bool(settings_pack::ignore_limits_on_local_network, settingsContext.speed.ignoreLimitsOnLAN);
	settings.set_bool(settings_pack::rate_limit_ip_overhead, settingsContext.speed.rateLimitIpOverhead);

	if (!settingsContext.advanced.announceIP.empty())
		settings.set_str(settings_pack::announce_ip, settingsContext.advanced.announceIP);

	settings.set_bool(settings_pack::strict_super_seeding, settingsContext.advanced.isSuperSeedingEnabled);

	settings.set_int(settings_pack::half_open_limit, settingsContext.advanced.numMaxHalfOpenConnections);
	settings.set_int(settings_pack::connections_limit, settingsContext.connections.maxNum);
	settings.set_int(settings_pack::unchoke_slots_limit, settingsContext.connections.maxUploads);

	settings.set_bool(settings_pack::enable_incoming_utp, settingsContext.speed.isuTPEnabled);
	settings.set_bool(settings_pack::enable_outgoing_utp, settingsContext.speed.isuTPEnabled);

	settings.set_bool(settings_pack::rate_limit_utp, settingsContext.speed.isuTPRateLimited);

	if (settingsContext.speed.isuTPRateLimited)
		settings.set_int(settings_pack::mixed_mode_algorithm, settings_pack::prefer_tcp);
	else
		settings.set_int(settings_pack::mixed_mode_algorithm, settings_pack::peer_proportional);

	settings.set_int(settings_pack::connection_speed, 20);
	settings.set_bool(settings_pack::no_connect_privileged_ports, false);
	
	settings.set_int(settings_pack::seed_choking_algorithm, settings_pack::fastest_upload);

	if (settingsContext.proxy.type > ProxyTypeConstants::DISABLED)
		settings.set_bool(settings_pack::force_proxy, settingsContext.proxy.force);
	else
		settings.set_bool(settings_pack::force_proxy, false);

	settings.set_bool(settings_pack::torrent_connect_boost, true);
	settings.set_int(settings_pack::choking_algorithm, settings_pack::rate_based_choker);
	settings.set_bool(settings_pack::volatile_read_cache,false);
	
	settings.set_int(settings_pack::upload_rate_limit, settingsContext.speed.uploadRateLimit);
	settings.set_int(settings_pack::download_rate_limit, settingsContext.speed.downloadRateLimit);
	settings.set_int(settings_pack::max_peerlist_size, 100);

	//Local Peer Discovery
	settings.set_bool(settings_pack::enable_lsd, settingsContext.privacy.useLSD);


	//Encryption
	settings.set_int(settings_pack::allowed_enc_level, settings_pack::pe_rc4);
	settings.set_bool(settings_pack::prefer_rc4, true);

	switch (settingsContext.privacy.encryption) {
	case EncyptionConstants::ENABLED:
		settings.set_int(settings_pack::out_enc_policy, settings_pack::pe_enabled);
		settings.set_int(settings_pack::in_enc_policy, settings_pack::pe_enabled);
		break;
	case EncyptionConstants::REQUIRED:
		settings.set_int(settings_pack::out_enc_policy, settings_pack::pe_forced);
		settings.set_int(settings_pack::in_enc_policy, settings_pack::pe_forced);
		break;
	case EncyptionConstants::DISABLED:
		settings.set_int(settings_pack::out_enc_policy, settings_pack::pe_disabled);
		settings.set_int(settings_pack::in_enc_policy, settings_pack::pe_disabled);
		break;
	default:
		break;
	}

	//proxy
	if (settingsContext.proxy.type > ProxyTypeConstants::DISABLED) {
		if (settingsContext.proxy.type != ProxyTypeConstants::I2P) {
			settings.set_str(settings_pack::proxy_hostname, settingsContext.proxy.host);
			settings.set_int(settings_pack::proxy_port,settingsContext.proxy.port);
		}
		if (settingsContext.proxy.useAuth) {
			settings.set_str(settings_pack::proxy_username, settingsContext.proxy.username);
			settings.set_str(settings_pack::proxy_password, settingsContext.proxy.password);
		}
		switch (settingsContext.proxy.type) {
			case ProxyTypeConstants::DISABLED:
				settings.set_int(settings_pack::proxy_type, settings_pack::none);
				break;
			case ProxyTypeConstants::SOCKS4:
				settings.set_int(settings_pack::proxy_type, settings_pack::socks4);
				break;
			case ProxyTypeConstants::SOCKS5:
				if (settingsContext.proxy.useAuth)
					settings.set_int(settings_pack::proxy_type, settings_pack::socks5_pw);
				else
					settings.set_int(settings_pack::proxy_type, settings_pack::socks5);
				break;
			case ProxyTypeConstants::HTTP:
				if (settingsContext.proxy.useAuth)
					settings.set_int(settings_pack::proxy_type, settings_pack::http_pw);
				else
					settings.set_int(settings_pack::proxy_type, settings_pack::http);
				break;
	#if TORRENT_USE_I2P
			case ProxyTypeConstants::I2P:
				settings.set_str(settings_pack::i2p_hostname, settingsContext.proxy.host);
				settings.set_int(settings_pack::i2p_port, 7656);
				settings.set_int(settings_pack::proxy_type, settings_pack::i2p_proxy);
				break;
	#endif
		}
		settings.set_bool(settings_pack::proxy_peer_connections, settingsContext.proxy.useForPeerConnections);
	}

	//upnp
	settings.set_bool(settings_pack::enable_upnp, settingsContext.listening.useUPnP);
	settings.set_bool(settings_pack::enable_natpmp, settingsContext.listening.useUPnP);


	if (settingsContext.privacy.useDHT) {
		dht_settings dht;
		dht.privacy_lookups = true;
		ltsession->set_dht_settings(dht);
		settings.set_bool(settings_pack::use_dht_as_fallback, false);
		settings.set_bool(settings_pack::enable_dht, true);
		for (unsigned int i = 0; i < dhtRouters.size(); ++i)
			ltsession->add_dht_router(std::make_pair(dhtRouters.at(i), settingsContext.listening.port));
	}
	else if (ltsession->is_dht_running()) {
		settings.set_bool(settings_pack::enable_dht, false);
	}

	return settings;
}

unsigned int numAvailableThreads = boost::thread::hardware_concurrency();

boost::thread threads[1];
boost::thread createThread(void(*otherFunction)(int p), int p) {
	boost::thread t(*otherFunction, p);
	return boost::move(t);
}

bool yes(libtorrent::torrent_status const&) {
	return true;
}

libtorrent::torrent_handle findHandle(std::string h) {
	using namespace libtorrent;
	using namespace std;
	torrent_handle fh;

	vector<torrent_status> temp;
	ltsession->get_torrent_status(&temp, &yes, 0);
	vector<torrent_handle> tv;
	tv = ltsession->get_torrents();

	for (unsigned int i = 0; i < tv.size(); ++i) {
		if (boost::lexical_cast<std::string>(tv.at(i).info_hash()) == h) {
			fh = tv.at(i);
			break;
		}
	}
	return fh;
}

extern "C" {
	FREContext dllContext;
	unsigned int logLevel = 0;
	
	std::vector<std::string> dhtRouters = {};


	extern void trace(std::string msg) {
		if (logLevel > 0)
			FREDispatchStatusEventAsync(dllContext, (uint8_t*)msg.c_str(), (const uint8_t*) "TRACE");
	}
	extern void logError(std::string msg) {
		FREDispatchStatusEventAsync(dllContext, (uint8_t*)msg.c_str(), (const uint8_t*)torrentInfoEvent.ON_ERROR.c_str());
	}
	extern void logInfo(std::string msg) {
		if (logLevel > 0)
			FREDispatchStatusEventAsync(dllContext, (uint8_t*)msg.c_str(), (const uint8_t*) "INFO");
	}
	void printFREResult(FREResult errorCode, char * errMessage) {
		//sort this print based on the enum
		trace(std::string(errMessage));
		switch (errorCode) {
		case FRE_OK:
			trace("FRE_OK");
			break;
		case FRE_NO_SUCH_NAME:
			trace("FRE_NO_SUCH_NAME");
			break;
		case FRE_INVALID_OBJECT:
			trace("FRE_INVALID_OBJECT");
			break;
		case FRE_TYPE_MISMATCH:
			trace("FRE_TYPE_MISMATCH");
			break;
		case FRE_ACTIONSCRIPT_ERROR:
			trace("FRE_ACTIONSCRIPT_ERROR");
			break;
		case FRE_INVALID_ARGUMENT:
			trace("FRE_INVALID_ARGUMENT");
			break;
		case FRE_READ_ONLY:
			trace("FRE_READ_ONLY");
			break;
		case FRE_WRONG_THREAD:
			trace("FRE_WRONG_THREAD");
			break;
		case FRE_ILLEGAL_STATE:
			trace("FRE_ILLEGAL_STATE");
			break;
		case FRE_INSUFFICIENT_MEMORY:
			trace("FRE_INSUFFICIENT_MEMORY");
			break;
		}
	}
	
	int saveFile(std::string const& filename, std::vector<char>& v) {
		FILE* f = fopen(filename.c_str(), "wb");
		if (f == NULL)
			return -1;

		int w = fwrite(&v[0], 1, v.size(), f);
		if (w < 0) {
			fclose(f);
			return -1;
		}

		if (w != int(v.size()))
			return -3;
		fclose(f);
		return 0;
	}
	
	void prioritizeFileTypes(libtorrent::torrent_handle th, boost::shared_ptr<const libtorrent::torrent_info> ti) {
		using namespace libtorrent;
		file_storage const& st = ti->files();
		int first = 0;
		int last = 0;
		bool found = false;
		for (int i = 0; i < st.num_files(); ++i) {
			for (unsigned int j = 0; j < settingsContext.priorityFileTypes.size(); ++j) {
				if (boost::algorithm::ends_with(st.file_path(i), "." + settingsContext.priorityFileTypes[j])) {
					first = st.map_file(i, 0, 0).piece;
					last = st.map_file(i, (std::max)(boost::int64_t(st.file_size(i)) - 1, boost::int64_t(0)), 0).piece;
					th.file_priority(i, 7);
					found = true;
					break;
				}
			}
		}
		std::vector<std::pair<int, int>> pri;
		if (found) {
			for (int i = first; i < (first + 10); ++i)
				pri.push_back(std::make_pair(i, 7));
			pri.push_back(std::make_pair(last, 7));
			th.prioritize_pieces(pri);
			for (int j = first; j < last; ++j)
				th.set_piece_deadline(j, j + 1);
			th.set_piece_deadline(last, 0);
		}
	}

	void handleAlert(libtorrent::alert* a) {
		using namespace libtorrent;
		using namespace std;
		using std::ios;
		using json = nlohmann::json;

		if (logLevel == LogLevelConstants::DBG) {
			logInfo(a->what());
			logInfo("alert message: " + a->message());
		}

		if (listen_failed_alert* alert = alert_cast<listen_failed_alert>(a)) {
			using json = nlohmann::json;
			json j;
			tcp::endpoint ep = alert->endpoint;
			j["port"] = ep.port();
			j["message"] = alert->message();
			j["address"] = ep.address().to_string();
			switch (alert->sock_type) {
			case 0:
				j["type"] = "tcp";
				break;
			case 1:
				j["type"] = "tcp_ssl";
				break;
			case 2:
				j["type"] = "udp";
				break;
			case 3:
				j["type"] = "i2p";
				break;
			case 4:
				j["type"] = "socks5";
				break;
			case 5:
				j["type"] = "utp_ssl";
				break;
			default:
				j["type"] = "tcp";
				break;
			}
			FREDispatchStatusEventAsync(dllContext, (uint8_t*)j.dump().c_str(), (const uint8_t*)torrentAlertEvent.LISTEN_FAILED.c_str());
		}
		else if (listen_succeeded_alert* alert = alert_cast<listen_succeeded_alert>(a)) {
			
		}
		else if (state_update_alert* alert = alert_cast<state_update_alert>(a)) {
			std::vector<torrent_status> torrentList = alert->status;
			std::string hash;
			std::string id;
			json j;
			for (std::vector<torrent_status>::const_iterator i = torrentList.begin(); i != torrentList.end(); ++i) {
				json jitm;
				hash = boost::lexical_cast<std::string>(i->info_hash);
				id = getIdFromHash(hash);
				jitm["id"] = id;
				jitm["numPieces"] = i->num_pieces;
				jitm["isSequential"] = i->sequential_download;
				jitm["queuePosition"] = i->queue_position;
				jitm["progress"] = i->progress * 100;
				jitm["downloadRate"] = i->download_payload_rate;
				jitm["downloadRateAverage"] = (uint32_t)(i->all_time_download / (1 + i->active_time - i->finished_time));
				jitm["allTimeDownload"] = i->all_time_download;
				jitm["downloadPayloadRate"] = i->download_payload_rate;
				jitm["uploadRate"] = i->upload_payload_rate;
				jitm["uploadRateAverage"] = (uint32_t)(i->all_time_upload / (1 + i->active_time));
				jitm["numPeers"] = i->num_peers;
				jitm["numPeersTotal"] = i->list_peers;
				jitm["numSeeds"] = i->num_seeds;
				jitm["numSeedsTotal"] = i->list_seeds;
				jitm["wasted"] = (uint32_t)(i->total_failed_bytes + i->total_redundant_bytes);
				jitm["activeTime"] = (i->state == torrent_status::seeding) ? i->seeding_time : i->active_time;
				jitm["downloaded"] = i->all_time_download;
				jitm["downloadedSession"] = i->total_payload_download;
				jitm["uploaded"] = i->all_time_upload;
				jitm["uploadedSession"] = i->total_payload_upload;
				jitm["uploadMax"] = (i->uploads_limit > 0) ? i->uploads_limit : -1;
				jitm["numConnections"] = i->num_connections;

				auto int_announce = std::chrono::duration_cast<std::chrono::seconds>(i->next_announce);
				jitm["nextAnnounce"] = (int_announce.count() > 0 && int_announce.count() < 3600) ?  int_announce.count() : 0;

				jitm["lastSeenComplete"] = i->last_seen_complete;
				jitm["completedOn"] = i->completed_time;
				jitm["savePath"] = i->save_path;
				jitm["addedOn"] = i->added_time;

				double uploadR = (double)i->all_time_upload;
				double downloadR = (i->all_time_download < i->total_done * 0.01) ? (double)i->total_done : (double)i->all_time_download;

				if (downloadR == 0) {
					jitm["shareRatio"] = (uploadR == 0) ? 0.00 : 9999.0;
				} else {
					double ratio = (double)(uploadR / downloadR);
					jitm["shareRatio"] = (ratio > 9999.0) ? 9999.0 : ratio;
				}
				jitm["addedOn"] = i->added_time;
				torrent_handle th = i->handle;
				jitm["downloadMax"] = th.download_limit();


				//partial pieces
				std::vector<partial_piece_info> queue;
				th.get_download_queue(queue);
				json jpieces;
				for (std::vector<partial_piece_info>::const_iterator it = queue.begin(); it != queue.end(); ++it)
					jpieces.push_back(it->piece_index);
				jitm["partialPieces"] = jpieces;
				
				if (settingsContext.queryFileProgress && i->state != torrent_status::seeding) {
					std::vector<boost::int64_t> fp;
					i->handle.file_progress(fp);
					json jprogress;
					for (unsigned int k = 0; k < fp.size(); ++k)
						jprogress.push_back((double)fp.at(k));
					jitm["fileProgress"] = jprogress;

					std::vector<int> fpri;
					fpri = i->handle.file_priorities();

					json jpriorities;
					for (unsigned int k = 0; k < fpri.size(); ++k)
						jpriorities.push_back(fpri.at(k));
					jitm["filePriority"] = jpriorities;
				}

				j.push_back(jitm);
			}

			FREDispatchStatusEventAsync(dllContext, (uint8_t*)j.dump().c_str(), (const uint8_t*)torrentAlertEvent.STATE_UPDATE.c_str());
		}
		else if (state_changed_alert* alert = alert_cast<state_changed_alert>(a)) {
			torrent_handle th = alert->handle;
			if (th.is_valid()) {
				boost::shared_ptr<const torrent_info> ti = th.torrent_file();
				torrent_status status = th.status();
				std::string hash = boost::lexical_cast<std::string>(status.info_hash);
				std::string id = getIdFromHash(hash);
				json j;
				j["id"] = getIdFromHash(id);
				if (status.paused) {
					j["state"] = (status.auto_managed) ? 8 : 9;
				}else{
					j["state"] = alert->state;
				}
				FREDispatchStatusEventAsync(dllContext, (uint8_t*)j.dump().c_str(), (const uint8_t*)torrentAlertEvent.STATE_CHANGED.c_str());
			}
		}
		else if (torrent_paused_alert* alert = alert_cast<torrent_paused_alert>(a)) {
			torrent_handle th = alert->handle;
			if (th.is_valid()) {
				torrent_status status = th.status();
				std::string hash = boost::lexical_cast<std::string>(status.info_hash);
				std::string id = getIdFromHash(hash);
				json j;
				j["id"] = getIdFromHash(id);
				j["state"] = (status.auto_managed) ? 8 : 9;
				FREDispatchStatusEventAsync(dllContext, (uint8_t*)j.dump().c_str(), (const uint8_t*)torrentAlertEvent.TORRENT_PAUSED.c_str());
			}
		}
		else if (torrent_resumed_alert* alert = alert_cast<torrent_resumed_alert>(a)) {
			torrent_handle th = alert->handle;
			if (th.is_valid()) {
				torrent_status status = th.status();
				std::string hash = boost::lexical_cast<std::string>(status.info_hash);
				std::string id = getIdFromHash(hash);
				json j;
				j["id"] = getIdFromHash(id);
				j["state"] = status.state;
				FREDispatchStatusEventAsync(dllContext, (uint8_t*)j.dump().c_str(), (const uint8_t*)torrentAlertEvent.TORRENT_RESUMED.c_str());
			}
		}
		else if (torrent_finished_alert* alert = alert_cast<torrent_finished_alert>(a)) {
			torrent_handle th = alert->handle;
			if (th.is_valid()) {
				boost::shared_ptr<const torrent_info> ti = th.torrent_file();
				th.save_resume_data();
				if (settingsContext.advanced.recheckTorrentsOnCompletion)
					th.force_recheck();

				std::string hash = boost::lexical_cast<std::string>(ti->info_hash());
				std::string id = getIdFromHash(hash);
				json j;
				j["id"] = getIdFromHash(id);
				FREDispatchStatusEventAsync(dllContext, (uint8_t*)j.dump().c_str(), (const uint8_t*)torrentAlertEvent.TORRENT_FINISHED.c_str());
			}
		}
		else if (piece_finished_alert* alert = alert_cast<piece_finished_alert>(a)) {
			torrent_handle th = alert->handle;
			if (th.is_valid()) {
				boost::shared_ptr<const torrent_info> ti = th.torrent_file();
				if (ti) {
					std::string hash = boost::lexical_cast<std::string>(ti->info_hash());
					std::string id = getIdFromHash(hash);
					json j;
					j["id"] = getIdFromHash(boost::lexical_cast<std::string>(ti->info_hash()));
					j["index"] = alert->piece_index;
					FREDispatchStatusEventAsync(dllContext, (uint8_t*)j.dump().c_str(), (const uint8_t*)torrentAlertEvent.PIECE_FINISHED.c_str());
				}
			}
		}
		else if (tracker_reply_alert* alert = alert_cast<tracker_reply_alert>(a)) {
			torrent_handle th = alert->handle;
			if (th.is_valid()) {
				boost::shared_ptr<const torrent_info> ti = th.torrent_file();
				if (ti) {
					std::string hash = boost::lexical_cast<std::string>(ti->info_hash());
					std::string id = getIdFromHash(hash);
					auto search = torrentTrackerPeerMap[id].find(alert->url);
					if (search != torrentTrackerPeerMap[id].end())
						search->second = alert->num_peers;
				}
			}
		}
		else if (metadata_received_alert* alert = alert_cast<metadata_received_alert>(a)) {
			torrent_handle th = alert->handle;
			if (th.is_valid()) {
				torrent_info ti = th.get_torrent_info();

				auto idFromHandleSearch = addedTorrentHandles.find(th.id());
				std::string idFromHandle = idFromHandleSearch->second;
				std::string id;
				if (!idFromHandle.empty()) {
					id = idFromHandle;
					std::string existingHash = getHashFromId(id);
				}
				else {
					id = getIdFromHash(boost::lexical_cast<std::string>(ti.info_hash()));
					if (id.empty())
						id = boost::lexical_cast<std::string>(ti.info_hash());
				}
				
				addedTorrents.left.erase(id);
				addedTorrents.insert(hashes(id, boost::lexical_cast<std::string>(ti.info_hash())));

				auto search = addedMagnetsUriMap.find(id);
				std::string sUri = search->second;

				vector<std::string> aUris;
				boost::split(aUris, sUri, boost::is_any_of("&"));
				std::string s;
				for (unsigned int i = 1; i < aUris.size(); i++) {
					s = urldecode(aUris.at(i));
					if (boost::algorithm::starts_with(s, "ws=")) {
						s = s.substr(3);
						ti.add_url_seed(s);
					}
				}
				create_torrent ct(ti);
				entry te = ct.generate();
				vector<char> data;
				std::string filename = settingsContext.storage.torrentPath + pathSlash + id + ".torrent";
				libtorrent::bencode(std::back_inserter(data), te);
				saveFile(filename, data);
				ltsession->remove_torrent(th);
				
				addedMagnetsUriMap.erase(id);
				json j;
				j["id"] = id;
				j["isSequential"] = th.status().sequential_download;
				FREDispatchStatusEventAsync(dllContext, (uint8_t*)j.dump().c_str(), (const uint8_t*)torrentAlertEvent.METADATA_RECEIVED.c_str());
			}
			
		}
		else if (save_resume_data_alert* alert = alert_cast<save_resume_data_alert>(a)) {
			torrent_handle th = alert->handle;
			if (th.is_valid()) {
				vector<char> out;
				libtorrent::bencode(back_inserter(out), *alert->resume_data);
				torrent_status status = th.status(torrent_handle::query_save_path); //don't need this ?
				std::string hash = boost::lexical_cast<std::string>(th.info_hash());
				std::string id = getIdFromHash(hash);
				saveFile((settingsContext.storage.resumePath + pathSlash + id + ".resume"), out);
				json j;
				j["id"] = id;
				FREDispatchStatusEventAsync(dllContext, (uint8_t*)j.dump().c_str(), (const uint8_t*)torrentAlertEvent.SAVE_RESUME_DATA.c_str());
			}
		}


		else if (add_torrent_alert* alert = alert_cast<add_torrent_alert>(a)) {
			torrent_handle th = alert->handle;
			if (alert->error || th.is_valid()) {
				if (alert->params.userdata) {
					vector<std::string> aUserData;
					std::string sUserData = (char*)alert->params.userdata;
					boost::split(aUserData, sUserData, boost::is_any_of("|"));
					std::string id = aUserData[0];
					std::string hash = aUserData[1];
					std::string uri = aUserData[2];

					addedTorrentHandles.insert(make_pair(th.id(), id));
					addedMagnetsUriMap.insert(make_pair(id, uri));
				} else {
					boost::shared_ptr<const torrent_info> ti = th.torrent_file();
					std::string id;
					std::string hash;
					hash = boost::lexical_cast<std::string>(ti->info_hash());
					id = getIdFromHash(hash);

					if (th.status().sequential_download)
						prioritizeFileTypes(th, ti);

#ifndef TORRENT_DISABLE_RESOLVE_COUNTRIES
					th.resolve_countries(settingsContext.advanced.resolveCountries);
#endif

					json j;
					j["id"] = id;
					FREDispatchStatusEventAsync(dllContext, (uint8_t*)j.dump().c_str(), (const uint8_t*)torrentAlertEvent.TORRENT_ADDED.c_str());
				}
			} else {
				logError(alert->message());
			}
			
		}
		else if (torrent_checked_alert* alert = alert_cast<torrent_checked_alert>(a)) {
			torrent_handle th = alert->handle;
			if (th.is_valid()) {
				boost::shared_ptr<const torrent_info> ti = th.torrent_file();
				std::string hash = boost::lexical_cast<std::string>(ti->info_hash());
				std::string id = getIdFromHash(hash);
				json j;
				j["id"] = id;
				for (std::vector<announce_entry>::const_iterator i = ti->trackers().begin(); i != ti->trackers().end(); ++i) {
					torrentTrackerPeerMap.insert(make_pair(id, TrackerPeerMap()));
					torrentTrackerPeerMap[id].insert(make_pair(i->url, 0));
				}
				if (th.status().paused && !th.status().auto_managed)
					th.resume();
				FREDispatchStatusEventAsync(dllContext, (uint8_t*)j.dump().c_str(), (const uint8_t*)torrentAlertEvent.TORRENT_CHECKED.c_str());
			}
		}
		else if (file_completed_alert* alert = alert_cast<file_completed_alert>(a)) {
			torrent_handle th = alert->handle;
			if (th.is_valid()) {
				boost::shared_ptr<const torrent_info> ti = th.torrent_file();
				json j;
				j["id"] = getIdFromHash(boost::lexical_cast<std::string>(ti->info_hash()));
				j["index"] = alert->index;
				//j["fileName"] = ti->file_at(alert->index).path;
				FREDispatchStatusEventAsync(dllContext, (uint8_t*)j.dump().c_str(), (const uint8_t*)torrentAlertEvent.FILE_COMPLETED.c_str());
			}
		}
		else if (fastresume_rejected_alert* alert = alert_cast<fastresume_rejected_alert>(a)) {
			torrent_handle th = alert->handle;
			boost::shared_ptr<const torrent_info> ti = th.torrent_file();
			ti.reset();
			th.resume();
		}
	}

	
	FREObject addTorrent(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		using namespace boost;
		using namespace libtorrent;
		using json = nlohmann::json;
		error_code ec;
		using namespace std;
		bool isMagnet = false;

		std::string id = getStringFromFREObject(argv[0]);
		std::string uri = getStringFromFREObject(argv[1]);
		std::string hash = getStringFromFREObject(argv[2]);
		uint32_t isSeq;
		FREGetObjectAsBool(argv[3], &isSeq);
		uint32_t seedMode;
		FREGetObjectAsBool(argv[4], &seedMode);

		algorithm::to_lower(hash);
		algorithm::to_lower(id);
		isMagnet = algorithm::starts_with(uri, "magnet");
		
		add_torrent_params p;

		p.max_connections = settingsContext.connections.maxNumPerTorrent;
		p.max_uploads = settingsContext.connections.maxUploadsPerTorrent;

		loadFile((settingsContext.storage.resumePath + pathSlash + id + ".resume").c_str(), p.resume_data, ec);
		
		if (ec)
			logError("Failed to load the resume: " + lexical_cast<std::string>(ec.message()));
		else
			logInfo("torrent started from the resume file");
		
		p.save_path = settingsContext.storage.outputPath;
		FREObject FREtorrentInfo = NULL;
		if (isMagnet) {
			p.storage = disabled_storage_constructor;
			std::string sUserData = id + "|" + hash + "|" + uri;
			p.userdata = (void*)strdup(sUserData.c_str());

			p.url = uri;
			parse_magnet_uri(uri, p, ec);
			
			if (ec) {
				logError("MAGNET_PARSE_FAIL");
			}
			else {
				logInfo("MAGNET_PARSE_SUCCESS");
				p.name = "fetch_magnet:" + uri;
				p.save_path = settingsContext.storage.outputPath;
				p.flags &= ~add_torrent_params::flag_auto_managed;

				if (isSeq)
					p.flags |= add_torrent_params::flag_sequential_download;
				else
					p.flags &= ~add_torrent_params::flag_sequential_download;

				ec.clear();
				torrent_handle th;
				th = ltsession->add_torrent(p, ec);
				addedTorrents.insert(hashes(id, boost::lexical_cast<std::string>(th.info_hash())));
				th.resume();
			}
		}
		else {

			torrent_info ti = readTorrentInfo(uri);
			FREtorrentInfo = getFRETorrentInfo(ti, uri);
			
			if (!settingsContext.storage.enabled)
				p.storage = zero_storage_constructor;

			p.ti = boost::make_shared<torrent_info>(std::string(uri), boost::ref(ec), 0);

			if (settingsContext.storage.sparse)
				p.storage_mode = libtorrent::storage_mode_sparse;
			else
				p.storage_mode = libtorrent::storage_mode_allocate;

			p.flags &= ~add_torrent_params::flag_paused;
			p.flags |= add_torrent_params::flag_auto_managed;
			if (isSeq)
				p.flags |= add_torrent_params::flag_sequential_download;
			else
				p.flags &= ~add_torrent_params::flag_sequential_download;

			if (seedMode)
				p.flags |= add_torrent_params::flag_seed_mode;
			else
				p.flags &= ~add_torrent_params::flag_seed_mode;

			addedTorrents.insert(hashes(id, boost::lexical_cast<std::string>(ti.info_hash())));

			ltsession->async_add_torrent(p);
			

		}
		return FREtorrentInfo;
	}

	void requestAlerts(){
		using namespace libtorrent;
		std::vector<alert*> alerts;
		ltsession->pop_alerts(&alerts);
		for (std::vector<alert*>::iterator i = alerts.begin(), end(alerts.end()); i != end; ++i)
			handleAlert(*i);
		alerts.clear();
	}


	FREObject initSession(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		using namespace libtorrent;
		FREObject result;
		FRENewObjectFromBool(true, &result);

		//deprecated init in a different way
		ltsession = new libtorrent::session(fingerprint("LT", LIBTORRENT_VERSION_MAJOR, LIBTORRENT_VERSION_MINOR, LIBTORRENT_VERSION_TINY,0), 0);
		ltsession->set_alert_notify(requestAlerts);
		error_code ec;

		settings_pack settings = getDefaultSessionSettings(dhtRouters);
		//allow to ovveride ?
		//settings.set_int(settings_pack::alert_mask, alert::error_notification | alert::peer_notification /*| alert::port_mapping_notification */ | alert::storage_notification | alert::tracker_notification | alert::status_notification | alert::ip_block_notification | alert::progress_notification | alert::rss_notification | alert::stats_notification);
		
		settings.set_int(settings_pack::alert_mask, alert::error_notification | alert::peer_notification /*| alert::port_mapping_notification */ | alert::storage_notification | alert::tracker_notification | alert::status_notification | alert::ip_block_notification | alert::progress_notification/* | alert::rss_notification | alert::stats_notification*/);

		int port = settingsContext.listening.port;
		if (settingsContext.advanced.networkInterface.size() > 0) {
			std::vector<std::pair<std::string, std::string>> nv;
			nv = settingsContext.advanced.networkInterface;
			for (std::vector<std::pair<std::string, std::string>>::const_iterator i = nv.begin(); i != nv.end(); ++i) {
				if ((!settingsContext.advanced.listenOnIPv6 && (i->second == "IPv6")) || (settingsContext.advanced.listenOnIPv6 && (i->second == "IPv4")))
					continue;
				char iface_str[100];
				snprintf(iface_str, sizeof(iface_str), "%s:%d", i->first.c_str(), port);
				settings.set_str(settings_pack::listen_interfaces, iface_str);
				//ltsession->listen_on(std::make_pair(port, port), ec, i->first.c_str());
			}
		} else {
			char iface_str[100];
			snprintf(iface_str, sizeof(iface_str), "%s:%d", "0.0.0.0", port);
			settings.set_str(settings_pack::listen_interfaces, iface_str);
		}
		
		ltsession->apply_settings(settings);
		
		FRENewObjectFromBool(true, &result);


		//reinstate
		/*
		std::vector<char> in;
		if (loadFile(settingsContext.storage.sessionStatePath + pathSlash + ".ses_state", in, ec) == 0) {
			bdecode_node e;
			if (bdecode(&in[0], &in[0] + in.size(), e, ec) == 0) {
				trace("load session state");
				ltsession->load_state(e, session::save_dht_state);
			}							
		}
		*/
		ltsession->add_extension(&create_ut_metadata_plugin);
		if(settingsContext.advanced.enableTrackerExchange)
			ltsession->add_extension(&create_lt_trackers_plugin);
		if(settingsContext.privacy.usePEX)
			ltsession->add_extension(&create_ut_pex_plugin);
		ltsession->add_extension(&create_smart_ban_plugin);
		
		//geoip
#ifndef TORRENT_DISABLE_GEO_IP
		if (settingsContext.advanced.resolveCountries) {
			if (settingsContext.advanced.resolvePeerHostNames) {
				std::string asNumDat = settingsContext.storage.geoipDataPath + pathSlash + "GeoIPASNum.dat";
				ltsession->load_asnum_db(asNumDat.c_str());
			}
			std::string geoIPDat = settingsContext.storage.geoipDataPath + pathSlash + "GeoIP.dat";
			ltsession->load_country_db(geoIPDat.c_str());
		}
#else
		sendInfo("Geoip is disabled");
#endif

		return result;
	}
	
	FREObject getTorrentInfo(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		std::string uri = getStringFromFREObject(argv[0]);
		return getFRETorrentInfo(readTorrentInfo(uri), uri);
	}
	FREObject getTorrentTrackers(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		using namespace libtorrent;
		
		FREObject vecTorrentTrackers = NULL;
		std::vector<torrent_status> temp;
		ltsession->get_torrent_status(&temp, &yes, 0);
		std::vector<torrent_handle> tv;
		tv = ltsession->get_torrents();

		FRENewObject((const uint8_t*)"Vector.<com.tuarua.torrent.TorrentTrackers>", 0, NULL, &vecTorrentTrackers, NULL);

		int cnt = 0;
		for (std::vector<torrent_handle>::const_iterator i = tv.begin(); i != tv.end(); ++i) {
			if (!i->torrent_file())
				continue;
			FREObject torrentTrackers;
			FRENewObject((const uint8_t*)"com.tuarua.torrent.TorrentTrackers", 0, NULL, &torrentTrackers, NULL);
			std::string hash = boost::lexical_cast<std::string>(i->info_hash());
			std::string id = getIdFromHash(hash);

			FREObject vecTrackers = NULL;
			FRENewObject((const uint8_t*)"Vector.<com.tuarua.torrent.TrackerInfo>", 0, NULL, &vecTrackers, NULL);

			//trackers via DHT, PeX and LSD
			int numDHT = 0;
			int numPEX = 0;
			int numLSD = 0;
			std::vector<peer_info> peers;
			i->get_peer_info(peers);
			if (!peers.empty()) {
				for (std::vector<peer_info>::const_iterator p = peers.begin(); p != peers.end(); ++p) {
					if (p->flags & (peer_info::handshake | peer_info::connecting | peer_info::queued))
						continue;
					if (p->source & peer_info::pex) ++numPEX;
					if (p->source & peer_info::dht) ++numDHT;
					if (p->source & peer_info::lsd) ++numLSD;
				}
			}

			FREObject freTracker;
			FRENewObject((const uint8_t*)"com.tuarua.torrent.TrackerInfo", 0, NULL, &freTracker, NULL);
			FRESetObjectProperty(freTracker, (const uint8_t*)"url", getFREObjectFromString("**[DHT]**"), NULL);
			if (settingsContext.privacy.useDHT && !i->torrent_file()->priv())
				FRESetObjectProperty(freTracker, (const uint8_t*)"status", getFREObjectFromString("Working"), NULL);
			else
				FRESetObjectProperty(freTracker, (const uint8_t*)"status", getFREObjectFromString("Disabled"), NULL);
			if(i->torrent_file()->priv())
				FRESetObjectProperty(freTracker, (const uint8_t*)"message", getFREObjectFromString("This torrent is private"), NULL);
			FRESetObjectProperty(freTracker, (const uint8_t*)"numPeers", getFREObjectFromUint32(numDHT), NULL);
			FRESetArrayElementAt(vecTrackers, 0, freTracker);

			FRENewObject((const uint8_t*)"com.tuarua.torrent.TrackerInfo", 0, NULL, &freTracker, NULL);
			FRESetObjectProperty(freTracker, (const uint8_t*)"url", getFREObjectFromString("**[PeX]**"), NULL);
			if (settingsContext.privacy.usePEX && !i->torrent_file()->priv())
				FRESetObjectProperty(freTracker, (const uint8_t*)"status", getFREObjectFromString("Working"), NULL);
			else
				FRESetObjectProperty(freTracker, (const uint8_t*)"status", getFREObjectFromString("Disabled"), NULL);
			if (i->torrent_file()->priv())
				FRESetObjectProperty(freTracker, (const uint8_t*)"message", getFREObjectFromString("This torrent is private"), NULL);
			FRESetObjectProperty(freTracker, (const uint8_t*)"numPeers", getFREObjectFromUint32(numPEX), NULL);
			FRESetArrayElementAt(vecTrackers, 1, freTracker);

			FRENewObject((const uint8_t*)"com.tuarua.torrent.TrackerInfo", 0, NULL, &freTracker, NULL);
			FRESetObjectProperty(freTracker, (const uint8_t*)"url", getFREObjectFromString("**[LSD]**"), NULL);
			if (settingsContext.privacy.useLSD && !i->torrent_file()->priv())
				FRESetObjectProperty(freTracker, (const uint8_t*)"status", getFREObjectFromString("Working"), NULL);
			else
				FRESetObjectProperty(freTracker, (const uint8_t*)"status", getFREObjectFromString("Disabled"), NULL);
			if (i->torrent_file()->priv())
				FRESetObjectProperty(freTracker, (const uint8_t*)"message", getFREObjectFromString("This torrent is private"), NULL);
			FRESetObjectProperty(freTracker, (const uint8_t*)"numPeers", getFREObjectFromUint32(numLSD), NULL);
			FRESetArrayElementAt(vecTrackers, 2, freTracker);

			std::vector<announce_entry> tr = i->trackers();
			
			int trackercnt = 3;

			//to prevent duplicates
			std::vector<std::string> existingTrackers;
			for (std::vector<announce_entry>::iterator t = tr.begin(), end(tr.end()); t != end; ++t) {

				if (std::find(existingTrackers.begin(), existingTrackers.end(), t->url) != existingTrackers.end())
					continue;

				existingTrackers.push_back(t->url);

				FREObject freTracker;
				FRENewObject((const uint8_t*)"com.tuarua.torrent.TrackerInfo", 0, NULL, &freTracker, NULL);

				FRESetObjectProperty(freTracker, (const uint8_t*)"tier", getFREObjectFromUint32(t->tier), NULL);
				FRESetObjectProperty(freTracker, (const uint8_t*)"url", getFREObjectFromString(t->url), NULL);
				if (t->verified) {
					FRESetObjectProperty(freTracker, (const uint8_t*)"status", getFREObjectFromString("Working"), NULL);
				}else if (t->updating && t->fails == 0) {
					FRESetObjectProperty(freTracker, (const uint8_t*)"status", getFREObjectFromString("Updating"), NULL);
				}else if (t->fails > 0) {
					FRESetObjectProperty(freTracker, (const uint8_t*)"status", getFREObjectFromString("Not Working"), NULL);
					FRESetObjectProperty(freTracker, (const uint8_t*)"message", getFREObjectFromString(t->last_error.message()), NULL);
				}else {
					FRESetObjectProperty(freTracker, (const uint8_t*)"status", getFREObjectFromString("Not contacted yet"), NULL);
				}

				auto search = torrentTrackerPeerMap[id].find(t->url);
				if (search != torrentTrackerPeerMap[id].end())
					FRESetObjectProperty(freTracker, (const uint8_t*)"numPeers", getFREObjectFromUint32(search->second), NULL);

				FRESetArrayElementAt(vecTrackers, trackercnt, freTracker);
				trackercnt++;
			}

			FRESetArrayLength(vecTrackers, trackercnt);
			FRESetObjectProperty(torrentTrackers, (const uint8_t*)"id", getFREObjectFromString(id), NULL);
			FRESetObjectProperty(torrentTrackers, (const uint8_t*)"trackersInfo", vecTrackers, NULL);
			FRESetArrayElementAt(vecTorrentTrackers, cnt, torrentTrackers);
			cnt++;
		}
		FRESetArrayLength(vecTorrentTrackers, cnt);
		return vecTorrentTrackers;
	}
	FREObject getTorrentPeers(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		using namespace libtorrent;
		FREObject vecTorrentPeers = NULL;

		//check we have a session

		std::vector<torrent_status> temp;

		std::string queryid = getStringFromFREObject(argv[0]);
		std::string queryhash = getHashFromId(queryid);

		bool queryFlags = getBoolFromFREObject(argv[1]);

		//ltsession->get_torrent_status(&temp, &yes, 0);
		std::vector<torrent_handle> tv;
		tv = ltsession->get_torrents();
		FRENewObject((const uint8_t*)"Vector.<com.tuarua.torrent.TorrentPeers>", 0, NULL, &vecTorrentPeers, NULL);
		
		int cnt = 0;
		for (std::vector<torrent_handle>::const_iterator i = tv.begin(); i != tv.end(); ++i) {
			//check if id

			std::string hash = boost::lexical_cast<std::string>(i->info_hash());
			std::string id = getIdFromHash(hash);

			if (!queryhash.empty() && hash != queryhash)
				continue;

			if (!i->torrent_file())
				continue;

			FREObject torrentPeers;
			FRENewObject((const uint8_t*)"com.tuarua.torrent.TorrentPeers", 0, NULL, &torrentPeers, NULL);
			FRESetObjectProperty(torrentPeers, (const uint8_t*)"id", getFREObjectFromString(id), NULL);
			FREObject vecPeers = NULL;
			FRENewObject((const uint8_t*)"Vector.<com.tuarua.torrent.PeerInfo>", 0, NULL, &vecPeers, NULL);

			if (i->status().state != torrent_status::seeding) {
				std::vector<peer_info> peers;
				i->get_peer_info(peers);
				if (!peers.empty()) {
					FRESetArrayLength(vecPeers, (uint32_t)peers.size());
					int peercnt = 0;
					for (std::vector<peer_info>::const_iterator p = peers.begin(); p != peers.end(); ++p) {
						if (p->flags & (peer_info::handshake | peer_info::connecting | peer_info::queued))
							continue;

						address const& addr = p->ip.address();
						error_code ec;
						FREObject frePeer;
						FRENewObject((const uint8_t*)"com.tuarua.torrent.PeerInfo", 0, NULL, &frePeer, NULL);
						FRESetObjectProperty(frePeer, (const uint8_t*)"ip", getFREObjectFromString(addr.to_string(ec)), NULL);
#ifndef TORRENT_DISABLE_RESOLVE_COUNTRIES
						if (settingsContext.advanced.resolveCountries && p->country[0] != 0) {
							std::stringstream ss;
							ss << boost::format("%c%c") % p->country[0] % p->country[1];
							FRESetObjectProperty(frePeer, (const uint8_t*)"country", getFREObjectFromString(ss.str()), NULL);
						}
#endif
#ifndef TORRENT_DISABLE_GEO_IP
						//if(settingsContext.advanced.resolveCountries)
							//FRESetObjectProperty(frePeer, (const uint8_t*)"asName", getFREObjectFromString(p->inet_as_name), NULL); //NEED


#endif
						FRESetObjectProperty(frePeer, (const uint8_t*)"client", getFREObjectFromString(p->client), NULL);
						FRESetObjectProperty(frePeer, (const uint8_t*)"port", getFREObjectFromUint32(p->ip.port()), NULL);
						FRESetObjectProperty(frePeer, (const uint8_t*)"localPort", getFREObjectFromUint32(p->local_endpoint.port()), NULL);

						if (p->flags & peer_info::utp_socket)
							FRESetObjectProperty(frePeer, (const uint8_t*)"connection", getFREObjectFromString("uTP"), NULL);
						else if (p->flags & peer_info::i2p_socket)
							FRESetObjectProperty(frePeer, (const uint8_t*)"connection", getFREObjectFromString("i2P"), NULL);
						else if (p->connection_type == peer_info::standard_bittorrent)
							FRESetObjectProperty(frePeer, (const uint8_t*)"connection", getFREObjectFromString("BT"), NULL);
						else if (p->connection_type == peer_info::web_seed)
							FRESetObjectProperty(frePeer, (const uint8_t*)"connection", getFREObjectFromString("Web"), NULL);

						FRESetObjectProperty(frePeer, (const uint8_t*)"downSpeed", getFREObjectFromUint32(p->down_speed), NULL);
						FRESetObjectProperty(frePeer, (const uint8_t*)"downloaded", getFREObjectFromUint32((uint32_t)p->total_download), NULL);

						FRESetObjectProperty(frePeer, (const uint8_t*)"upSpeed", getFREObjectFromUint32(p->up_speed), NULL);
						FRESetObjectProperty(frePeer, (const uint8_t*)"uploaded", getFREObjectFromUint32((uint32_t)p->total_upload), NULL);

						if (queryFlags) {
							std::stringstream flgsAsString;
							flgsAsString << "";

							int isChoked = (p->flags & peer_info::choked);
							int isRemoteChoked = (p->flags & peer_info::remote_choked);
							int isRemoteInterested = (p->flags & peer_info::remote_interested);
							int isInteresting = (p->flags & peer_info::interesting);

							if (isInteresting && isRemoteChoked)
								flgsAsString << "d "; else flgsAsString << "D ";
							
							if (isRemoteInterested && isChoked)
								flgsAsString << "u "; else flgsAsString << "U ";
							
							if (p->flags & peer_info::optimistic_unchoke) flgsAsString << "O ";
							if (p->flags & peer_info::snubbed) flgsAsString << "S ";
							if ((p->flags & peer_info::local_connection) == 0) flgsAsString << "I ";
							
							
							if (!isRemoteChoked && !isInteresting)
								flgsAsString << "K ";

							if (!isChoked && !isRemoteInterested)
								flgsAsString << "? ";
							
							if (p->source & peer_info::pex) flgsAsString << "X ";
							if (p->source & peer_info::dht) flgsAsString << "H ";
							if (p->source & peer_info::lsd) flgsAsString << "L ";
							if (p->flags & peer_info::rc4_encrypted) flgsAsString << "E ";
							if (p->flags & peer_info::plaintext_encrypted) flgsAsString << "e ";
							if (p->flags & peer_info::utp_socket) flgsAsString << "P ";
						
							FREObject freFlags;
							FRENewObject((const uint8_t*)"com.tuarua.torrent.PeerFlags", 0, NULL, &freFlags, NULL);
						
							if (isInteresting) FRESetObjectProperty(freFlags, (const uint8_t*)"isInteresting", getFREObjectFromBool(true), NULL);
							if (isChoked) FRESetObjectProperty(freFlags, (const uint8_t*)"isChoked", getFREObjectFromBool(true), NULL);
							if (isRemoteInterested) FRESetObjectProperty(freFlags, (const uint8_t*)"isRemoteInterested", getFREObjectFromBool(true), NULL);
							if (isRemoteChoked) FRESetObjectProperty(freFlags, (const uint8_t*)"isRemoteChoked", getFREObjectFromBool(true), NULL);
							if (p->flags & peer_info::supports_extensions) FRESetObjectProperty(freFlags, (const uint8_t*)"supportsExtensions", getFREObjectFromBool(true), NULL);
							if (p->flags & peer_info::local_connection) FRESetObjectProperty(freFlags, (const uint8_t*)"isLocalConnection", getFREObjectFromBool(true), NULL);
							if (p->flags & peer_info::seed) FRESetObjectProperty(freFlags, (const uint8_t*)"isSeed", getFREObjectFromBool(true), NULL);
							if (p->flags & peer_info::on_parole) FRESetObjectProperty(freFlags, (const uint8_t*)"onParole", getFREObjectFromBool(true), NULL);
							if (p->flags & peer_info::optimistic_unchoke) FRESetObjectProperty(freFlags, (const uint8_t*)"isOptimisticUnchoke", getFREObjectFromBool(true), NULL);
							if (p->flags & peer_info::snubbed) FRESetObjectProperty(freFlags, (const uint8_t*)"isSnubbed", getFREObjectFromBool(true), NULL);
							if (p->flags & peer_info::upload_only) FRESetObjectProperty(freFlags, (const uint8_t*)"isUploadOnly", getFREObjectFromBool(true), NULL);
							if (p->flags & peer_info::endgame_mode) FRESetObjectProperty(freFlags, (const uint8_t*)"isEndGameMode", getFREObjectFromBool(true), NULL);
	#ifndef TORRENT_DISABLE_ENCRYPTION
							if (p->flags & peer_info::rc4_encrypted) FRESetObjectProperty(freFlags, (const uint8_t*)"isRC4encrypted", getFREObjectFromBool(true), NULL);
							if (p->flags & peer_info::plaintext_encrypted) FRESetObjectProperty(freFlags, (const uint8_t*)"isPlainTextEncrypted", getFREObjectFromBool(true), NULL);
	#endif
							if (p->flags & peer_info::holepunched) FRESetObjectProperty(freFlags, (const uint8_t*)"isHolePunched", getFREObjectFromBool(true), NULL);
							if (p->source & peer_info::tracker) FRESetObjectProperty(freFlags, (const uint8_t*)"fromTracker", getFREObjectFromBool(true), NULL);
							if (p->source & peer_info::pex) FRESetObjectProperty(freFlags, (const uint8_t*)"fromPEX", getFREObjectFromBool(true), NULL);
							if (p->source & peer_info::dht) FRESetObjectProperty(freFlags, (const uint8_t*)"fromDHT", getFREObjectFromBool(true), NULL);
							if (p->source & peer_info::lsd) FRESetObjectProperty(freFlags, (const uint8_t*)"fromLSD", getFREObjectFromBool(true), NULL);
							if (p->source & peer_info::resume_data) FRESetObjectProperty(freFlags, (const uint8_t*)"fromResumeData", getFREObjectFromBool(true), NULL);
							if (p->source & peer_info::incoming) FRESetObjectProperty(freFlags, (const uint8_t*)"fromIncoming", getFREObjectFromBool(true), NULL);

							FRESetObjectProperty(frePeer, (const uint8_t*)"flags", freFlags, NULL);
							FRESetObjectProperty(frePeer, (const uint8_t*)"flagsAsString", getFREObjectFromString(flgsAsString.str()), NULL);
						
						}

						//relevance
						int localMissing = 0;
						int remoteHaves = 0;
						libtorrent::bitfield local = i->status().pieces;
						libtorrent::bitfield remote = p->pieces;
						for (int j = 0; j<local.size(); ++j) {
							if (!local[j]) {
								++localMissing;
								if (remote[j]) ++remoteHaves;
							}
						}
						FRESetObjectProperty(frePeer, (const uint8_t*)"relevance", getFREObjectFromDouble((localMissing == 0) ? 0.0 : (double)(remoteHaves/localMissing)), NULL);
						FRESetObjectProperty(frePeer, (const uint8_t*)"progress", getFREObjectFromDouble(p->progress), NULL);
						

						FRESetArrayElementAt(vecPeers, peercnt, frePeer);

						peercnt++;
					}
					FRESetArrayLength(vecPeers, peercnt);
				}
			}
			
			FRESetObjectProperty(torrentPeers, (const uint8_t*)"peersInfo", vecPeers, NULL);

			FRESetArrayElementAt(vecTorrentPeers, cnt, torrentPeers);
			cnt++;
		}

		return vecTorrentPeers;
	}

	FREObject postTorrentUpdates(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		using namespace libtorrent;
		ltsession->post_torrent_updates(statusFlags);
		return getReturnTrue();
	}
	

	FREObject getMagnetURI(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		using namespace libtorrent;
		using namespace std;
		std::string id = getStringFromFREObject(argv[0]);
		std::string hash = getHashFromId(id);
		std::string ret = "";
		torrent_handle fh = findHandle(hash);
		if (fh.is_valid()) {
			if(fh.is_valid())
				ret = make_magnet_uri(fh);
		}	
		return getFREObjectFromString(ret);
	}

	FREObject setPieceDeadline(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		using namespace libtorrent;
		using namespace std;
		std::string id = getStringFromFREObject(argv[0]);
		unsigned int index = getUInt32FromFREObject(argv[1]);
		unsigned int deadline = getUInt32FromFREObject(argv[2]);
		std::string hash = getHashFromId(id);
		torrent_handle fh = findHandle(hash);
		if (fh.is_valid()) {
			if (fh.is_valid() && fh.status().has_metadata)
				fh.set_piece_deadline(index, deadline);
			return getFREObjectFromBool(true);
		} else {
			return getFREObjectFromBool(false);
		}
		return getFREObjectFromBool(false);
	}

	FREObject resetPieceDeadline(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		using namespace libtorrent;
		using namespace std;
		std::string id = getStringFromFREObject(argv[0]);
		unsigned int index = getUInt32FromFREObject(argv[1]);
		std::string hash = getHashFromId(id);
		torrent_handle fh = findHandle(hash);
		if (fh.is_valid()) {
			if (fh.is_valid() && fh.status().has_metadata)
				fh.reset_piece_deadline(index);
			return getFREObjectFromBool(true);
		}
		else {
			return getFREObjectFromBool(false);
		}
		return getFREObjectFromBool(false);
	}
	

	FREObject setPiecePriority(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		using namespace libtorrent;
		using namespace std;
		std::string id = getStringFromFREObject(argv[0]);
		unsigned int index = getUInt32FromFREObject(argv[1]);
		unsigned int priority = getUInt32FromFREObject(argv[2]);
		std::string hash = getHashFromId(id);
		torrent_handle fh = findHandle(hash);
		if (fh.is_valid()) {
			if (fh.is_valid() && fh.status().has_metadata)
				fh.piece_priority(index, priority);
			return getFREObjectFromBool(true);
		} else {
			return getFREObjectFromBool(false);
		}
		return getFREObjectFromBool(false);
	}

	FREObject setFilePriority(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		using namespace libtorrent;
		using namespace std;
		std::string id = getStringFromFREObject(argv[0]);
		unsigned int index = getUInt32FromFREObject(argv[1]);
		unsigned int priority = getUInt32FromFREObject(argv[2]);
		std::string hash = getHashFromId(id);
		torrent_handle fh = findHandle(hash);
		if (fh.is_valid()) {
			if (fh.is_valid() && fh.status().has_metadata)
				fh.file_priority(index, priority);
			return getFREObjectFromBool(true);
		} else {
			return getFREObjectFromBool(false);
		}
		return getFREObjectFromBool(false);
	}

	FREObject forceDHTAnnounce(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		using namespace libtorrent;
		using namespace std;
		std::string id = getStringFromFREObject(argv[0]);
		std::string hash = getHashFromId(id);
		torrent_handle fh = findHandle(hash);
		if (fh.is_valid()) {
			fh.force_dht_announce();
			return getFREObjectFromBool(true);
		} else {
			return getFREObjectFromBool(false);
		}
		return getFREObjectFromBool(false);
	}

	FREObject forceAnnounce(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		using namespace libtorrent;
		using namespace std;
		std::string id = getStringFromFREObject(argv[0]);
		int trackerIndex = getInt32FromFREObject(argv[1]);
		std::string hash = getHashFromId(id);
		torrent_handle fh = findHandle(hash);
		if (fh.is_valid()) {
			fh.force_reannounce(0, trackerIndex);
			return getFREObjectFromBool(true);
		} else {
			return getFREObjectFromBool(false);
		}
		return getFREObjectFromBool(false);
	}
	
	FREObject forceRecheck(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		using namespace libtorrent;
		using namespace std;
		std::string id = getStringFromFREObject(argv[0]);
		std::string hash = getHashFromId(id);
		torrent_handle fh = findHandle(hash);
		if (fh.is_valid()) {
			fh.save_resume_data();
			fh.force_recheck();
			return getFREObjectFromBool(true);
		}else {
			return getFREObjectFromBool(false);
		}
		return getFREObjectFromBool(false);
	}


	FREObject pauseTorrent(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		using namespace libtorrent;
		using namespace std;
		std::string id = getStringFromFREObject(argv[0]);
		std::string hash = getHashFromId(id);
		torrent_handle fh = findHandle(hash);
		if(fh.is_valid()){
			fh.auto_managed(false);
			fh.pause();
			if (fh.status().has_metadata && fh.status().need_save_resume) 
				fh.save_resume_data();
			return getFREObjectFromBool(true);
		} else {
			return getFREObjectFromBool(false);
		}
		return getFREObjectFromBool(false);
	}
	
	FREObject resumeTorrent(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		using namespace libtorrent;
		using namespace std;
		std::string id = getStringFromFREObject(argv[0]);
		std::string hash = getHashFromId(id);
		torrent_handle fh = findHandle(hash);
		if (fh.is_valid()) {
			fh.resume();
			fh.auto_managed(true);
			return getFREObjectFromBool(true);
		} else {
			return getFREObjectFromBool(false);
		}
		return getFREObjectFromBool(false);
	}
	FREObject removeTorrent(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		using namespace libtorrent;
		using namespace std;
		std::string id = getStringFromFREObject(argv[0]);
		addedTorrents.by<addedTorrentId>().erase(id);
		std::string hash = getHashFromId(id);
		torrent_handle fh = findHandle(hash);
		if (fh.is_valid()) {
			ltsession->remove_torrent(fh);
			return getFREObjectFromBool(true);
		} else {
			return getFREObjectFromBool(false);
		}
		return getFREObjectFromBool(false);
	}

	FREObject addTracker(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		using namespace libtorrent;
		using namespace std;
		std::string id = getStringFromFREObject(argv[0]);
		std::string hash = getHashFromId(id);
		std::string url = getStringFromFREObject(argv[1]);
		torrent_handle th = findHandle(hash);
		if (th.is_valid()) {
			return getFREObjectFromBool(true);
		}
		return getFREObjectFromBool(false);
	}

	FREObject addUrlSeed(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		using namespace libtorrent;
		using namespace std;
		std::string id = getStringFromFREObject(argv[0]);
		std::string hash = getHashFromId(id);
		std::string url = getStringFromFREObject(argv[1]);
		torrent_handle th = findHandle(hash);
		if (th.is_valid()) {
			th.add_url_seed(url);
			return getFREObjectFromBool(true);
		}
		return getFREObjectFromBool(false);
	}

	FREObject removeUrlSeed(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		using namespace libtorrent;
		using namespace std;
		std::string id = getStringFromFREObject(argv[0]);
		std::string hash = getHashFromId(id);
		std::string url = getStringFromFREObject(argv[1]);
		torrent_handle th = findHandle(hash);
		if (th.is_valid()) {
			th.remove_url_seed(url);
			return getFREObjectFromBool(true);
		}
		return getFREObjectFromBool(false);
	}

	FREObject setQueuePosition(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		using namespace libtorrent;
		using namespace std;
		std::string id = getStringFromFREObject(argv[0]);
		std::string hash = getHashFromId(id);
		uint32_t dir = getUInt32FromFREObject(argv[1]); //0 is up,1 is down, 2 is top, 3 is bottom

		torrent_handle th = findHandle(hash);
		if (th.is_valid()) {
			switch (dir) {
				case QueuePositionConstants::UP:
					th.queue_position_up();
					break;
				case QueuePositionConstants::DOWN:
					th.queue_position_down();
					break;
				case QueuePositionConstants::TOP:
					th.queue_position_top();
					break;
				case QueuePositionConstants::BOTTOM:
					th.queue_position_bottom();
					break;
				default:
					break;
			}
			return getFREObjectFromBool(true);
		} else {
			return getFREObjectFromBool(false);
		}
		return getFREObjectFromBool(false);
	}
	FREObject setSequentialDownload(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		using namespace libtorrent;
		using namespace std;
		uint32_t ASseq;
		bool isSeq = false;
		std::string id = getStringFromFREObject(argv[0]);
		std::string hash = getHashFromId(id);
		FREGetObjectAsBool(argv[1], &ASseq);
		if (ASseq) isSeq = true;

		torrent_handle fh = findHandle(hash);
		if (fh.is_valid()) {
			fh.set_sequential_download(isSeq);
			if (!isSeq)
				fh.clear_piece_deadlines();
			return getFREObjectFromBool(true);
		} else {
			return getFREObjectFromBool(false);
		}
		return getFREObjectFromBool(false);

	}


	FREObject addDHTRouter(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
#ifndef TORRENT_DISABLE_DHT
		dhtRouters.push_back(getStringFromFREObject(argv[0]));
#endif
		return getReturnTrue();
	}

	FREObject endSession(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		using namespace libtorrent;
		using namespace std;
		std::vector<torrent_status> temp;
		
		ltsession->get_torrent_status(&temp, &yes, 0);
		std::vector<torrent_handle> oTorrentVector;
		oTorrentVector = ltsession->get_torrents();
		for (unsigned int i = 0; i < oTorrentVector.size(); ++i)
			ltsession->remove_torrent(oTorrentVector[i]);

		settings_pack endSettings;
#ifndef TORRENT_DISABLE_DHT
		if (ltsession->is_dht_running())
			endSettings.set_bool(settings_pack::enable_dht, false);
#endif
		endSettings.set_bool(settings_pack::enable_lsd, false);
		endSettings.set_bool(settings_pack::enable_upnp, false);
		endSettings.set_bool(settings_pack::enable_natpmp, false);

		ltsession->apply_settings(endSettings);

		logInfo("session ended");
	
		return getReturnTrue();
	}
	
	FREObject updateSettings(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		FREObject settingsProps = argv[0];
		
		logLevel = getUInt32FromFREObject(getFREObjectProperty(settingsProps, (const uint8_t*) "logLevel"));
		
		std::stringstream ss;
		ss << getStringFromFREObject(getFREObjectProperty(settingsProps, (const uint8_t*) "clientName")) << "/" << LIBTORRENT_VERSION << std::endl;
		clientName = ss.str();

		settingsContext.priorityFileTypes = getStringVectorFromFREObject(getFREObjectProperty(settingsProps, (const uint8_t*) "prioritizedFileTypes"), NULL);
		settingsContext.queryFileProgress = getBoolFromFREObject(getFREObjectProperty(settingsProps, (const uint8_t*) "queryFileProgress"));

		FREObject storageProps = getFREObjectProperty(settingsProps, (const uint8_t*) "storage");
		settingsContext.storage.outputPath = getStringFromFREObject(getFREObjectProperty(storageProps, (const uint8_t*) "outputPath"));
		settingsContext.storage.torrentPath = getStringFromFREObject(getFREObjectProperty(storageProps, (const uint8_t*) "torrentPath"));
		settingsContext.storage.resumePath = getStringFromFREObject(getFREObjectProperty(storageProps, (const uint8_t*) "resumePath"));
		settingsContext.storage.geoipDataPath = getStringFromFREObject(getFREObjectProperty(storageProps, (const uint8_t*) "geoipDataPath"));
		settingsContext.storage.sessionStatePath = getStringFromFREObject(getFREObjectProperty(storageProps, (const uint8_t*) "sessionStatePath"));
		settingsContext.storage.sparse = getBoolFromFREObject(getFREObjectProperty(storageProps, (const uint8_t*) "sparse"));
		settingsContext.storage.enabled = getBoolFromFREObject(getFREObjectProperty(storageProps, (const uint8_t*) "enabled"));

		FREObject privacyProps = getFREObjectProperty(settingsProps, (const uint8_t*) "privacy");
		settingsContext.privacy.usePEX = getBoolFromFREObject(getFREObjectProperty(privacyProps, (const uint8_t*) "usePEX"));
		settingsContext.privacy.useLSD = getBoolFromFREObject(getFREObjectProperty(privacyProps, (const uint8_t*) "useLSD"));
		settingsContext.privacy.encryption = getUInt32FromFREObject(getFREObjectProperty(privacyProps, (const uint8_t*) "encryption"));
		settingsContext.privacy.useAnonymousMode = getBoolFromFREObject(getFREObjectProperty(privacyProps, (const uint8_t*) "useAnonymousMode"));
#ifndef TORRENT_DISABLE_DHT
		settingsContext.privacy.useDHT = getBoolFromFREObject(getFREObjectProperty(privacyProps, (const uint8_t*) "useDHT"));
#else
		settingsContext.useDHT = false;
#endif
		FREObject queueingProps = getFREObjectProperty(settingsProps, (const uint8_t*) "queueing");
		settingsContext.queueing.enabled = getBoolFromFREObject(getFREObjectProperty(queueingProps, (const uint8_t*) "enabled"));
		settingsContext.queueing.ignoreSlow = getBoolFromFREObject(getFREObjectProperty(queueingProps, (const uint8_t*) "ignoreSlow"));
		settingsContext.queueing.maxActiveDownloads = getUInt32FromFREObject(getFREObjectProperty(queueingProps, (const uint8_t*) "maxActiveDownloads"));
		settingsContext.queueing.maxActiveTorrents = getUInt32FromFREObject(getFREObjectProperty(queueingProps, (const uint8_t*) "maxActiveTorrents"));
		settingsContext.queueing.maxActiveUploads = getUInt32FromFREObject(getFREObjectProperty(queueingProps, (const uint8_t*) "maxActiveUploads"));
		FREObject speedProps = getFREObjectProperty(settingsProps, (const uint8_t*) "speed");
		settingsContext.speed.uploadRateLimit = getUInt32FromFREObject(getFREObjectProperty(speedProps, (const uint8_t*) "uploadRateLimit"));
		settingsContext.speed.downloadRateLimit = getUInt32FromFREObject(getFREObjectProperty(speedProps, (const uint8_t*) "downloadRateLimit"));
		settingsContext.speed.isuTPEnabled = getBoolFromFREObject(getFREObjectProperty(speedProps, (const uint8_t*) "isuTPEnabled"));
		settingsContext.speed.isuTPRateLimited = getBoolFromFREObject(getFREObjectProperty(speedProps, (const uint8_t*) "isuTPRateLimited"));
		settingsContext.speed.ignoreLimitsOnLAN = getBoolFromFREObject(getFREObjectProperty(speedProps, (const uint8_t*) "ignoreLimitsOnLAN"));
		settingsContext.speed.rateLimitIpOverhead = getBoolFromFREObject(getFREObjectProperty(speedProps, (const uint8_t*) "rateLimitIpOverhead"));

		//listening port
		FREObject listeningProps = getFREObjectProperty(settingsProps, (const uint8_t*) "listening");
		settingsContext.listening.useUPnP = getBoolFromFREObject(getFREObjectProperty(listeningProps, (const uint8_t*) "useUPnP"));
		settingsContext.listening.randomPort = getBoolFromFREObject(getFREObjectProperty(listeningProps, (const uint8_t*) "randomPort"));
		if (settingsContext.listening.randomPort) {
			int port;
			port = 0;
			boost::mt19937 gen;
			boost::uniform_int<> dist(6881, 6999);
			boost::variate_generator<boost::mt19937&, boost::uniform_int<> > randRange(gen, dist);
			settingsContext.listening.port = randRange();
		} else {
			settingsContext.listening.port = getUInt32FromFREObject(getFREObjectProperty(listeningProps, (const uint8_t*) "port"));
		}
		FREObject connectionsProps = getFREObjectProperty(settingsProps, (const uint8_t*) "connections");
		settingsContext.connections.maxNum = getUInt32FromFREObject(getFREObjectProperty(connectionsProps, (const uint8_t*) "maxNum"));
		settingsContext.connections.maxNumPerTorrent = getUInt32FromFREObject(getFREObjectProperty(connectionsProps, (const uint8_t*) "maxNumPerTorrent"));
		settingsContext.connections.maxUploads = getUInt32FromFREObject(getFREObjectProperty(connectionsProps, (const uint8_t*) "maxUploads"));
		settingsContext.connections.maxUploadsPerTorrent = getUInt32FromFREObject(getFREObjectProperty(connectionsProps, (const uint8_t*) "maxUploadsPerTorrent"));

		FREObject proxyProps = getFREObjectProperty(settingsProps, (const uint8_t*) "proxy");
		settingsContext.proxy.type = getUInt32FromFREObject(getFREObjectProperty(proxyProps, (const uint8_t*) "type"));
		settingsContext.proxy.port = getUInt32FromFREObject(getFREObjectProperty(proxyProps, (const uint8_t*) "port"));
		settingsContext.proxy.host = getStringFromFREObject(getFREObjectProperty(proxyProps, (const uint8_t*) "host"));
		settingsContext.proxy.useForPeerConnections = getBoolFromFREObject(getFREObjectProperty(proxyProps, (const uint8_t*) "useForPeerConnections"));
		settingsContext.proxy.force = getBoolFromFREObject(getFREObjectProperty(proxyProps, (const uint8_t*) "force"));
		settingsContext.proxy.useAuth = getBoolFromFREObject(getFREObjectProperty(proxyProps, (const uint8_t*) "useAuth"));
		settingsContext.proxy.username = getStringFromFREObject(getFREObjectProperty(proxyProps, (const uint8_t*) "username"));
		settingsContext.proxy.password = getStringFromFREObject(getFREObjectProperty(proxyProps, (const uint8_t*) "password"));

		FREObject advancedProps = getFREObjectProperty(settingsProps, (const uint8_t*) "advanced");
		settingsContext.advanced.diskCacheSize = getInt32FromFREObject(getFREObjectProperty(advancedProps, (const uint8_t*) "diskCacheSize"));
		settingsContext.advanced.diskCacheTTL = getUInt32FromFREObject(getFREObjectProperty(advancedProps, (const uint8_t*) "diskCacheTTL"));
		settingsContext.advanced.enableOsCache = getBoolFromFREObject(getFREObjectProperty(advancedProps, (const uint8_t*) "enableOsCache"));
		settingsContext.advanced.outgoingPortsMin = getUInt32FromFREObject(getFREObjectProperty(advancedProps, (const uint8_t*) "outgoingPortsMin"));
		settingsContext.advanced.outgoingPortsMax = getUInt32FromFREObject(getFREObjectProperty(advancedProps, (const uint8_t*) "outgoingPortsMax"));
		settingsContext.advanced.recheckTorrentsOnCompletion = getBoolFromFREObject(getFREObjectProperty(advancedProps, (const uint8_t*) "recheckTorrentsOnCompletion"));
		settingsContext.advanced.resolveCountries = getBoolFromFREObject(getFREObjectProperty(advancedProps, (const uint8_t*) "resolveCountries"));
		settingsContext.advanced.isSuperSeedingEnabled = getBoolFromFREObject(getFREObjectProperty(advancedProps, (const uint8_t*) "isSuperSeedingEnabled"));
		settingsContext.advanced.numMaxHalfOpenConnections = getUInt32FromFREObject(getFREObjectProperty(advancedProps, (const uint8_t*) "numMaxHalfOpenConnections"));
		settingsContext.advanced.announceToAllTrackers = getBoolFromFREObject(getFREObjectProperty(advancedProps, (const uint8_t*) "announceToAllTrackers"));
		settingsContext.advanced.enableTrackerExchange = getBoolFromFREObject(getFREObjectProperty(advancedProps, (const uint8_t*) "enableTrackerExchange"));
		settingsContext.advanced.resolvePeerHostNames = getBoolFromFREObject(getFREObjectProperty(advancedProps, (const uint8_t*) "resolvePeerHostNames"));
		settingsContext.advanced.listenOnIPv6 = getBoolFromFREObject(getFREObjectProperty(advancedProps, (const uint8_t*) "listenOnIPv6"));
		settingsContext.advanced.announceIP = getStringFromFREObject(getFREObjectProperty(advancedProps, (const uint8_t*) "announceIP"));
		FREObject networkInterface = getFREObjectProperty(advancedProps, (const uint8_t*) "networkInterface");
		FREObject networkAddresses = getFREObjectProperty(networkInterface, (const uint8_t*) "addresses");
		uint32_t numAddresses = getFREObjectArrayLength(networkAddresses);
		for (unsigned int j = 0; j < numAddresses; ++j) {
			FREObject elemAS = NULL;
			FREGetArrayElementAt(networkAddresses, j, &elemAS);
			settingsContext.advanced.networkInterface.push_back(std::make_pair(getStringFromFREObject(getFREObjectProperty(elemAS, (const uint8_t*) "address")), getStringFromFREObject(getFREObjectProperty(elemAS, (const uint8_t*) "ipVersion"))));
		}

		if (ltsession && ltsession->is_listening())
			ltsession->apply_settings(getDefaultSessionSettings(dhtRouters));

		return getReturnTrue();
	}
	bool fileFilter(std::string const& f) {
		using namespace libtorrent;
		if (filename(f)[0] == '.') return false;
		return true;
	}
	void printCreationProgress(int i, int num) {
		using json = nlohmann::json;
		json j;
		j["progress"] = (int)(i*100. / (float)num);
		FREDispatchStatusEventAsync(dllContext, (uint8_t*)j.dump().c_str(), (const uint8_t*)torrentInfoEvent.TORRENT_CREATION_PROGRESS.c_str());
	}
	void threadCreateTorrent(int p) {
		using namespace libtorrent;
		boost::mutex mutex;
		using boost::this_thread::get_id;
		mutex.lock();

		int padFileLimit = -1;
		int flags = 0;

		file_storage fs;
		std::string fullPath = libtorrent::complete(createTorrentContext.inputFile);
		add_files(fs, fullPath, fileFilter, flags);

		create_torrent t(fs, createTorrentContext.pieceSize, padFileLimit, flags);
		int tier = 0;
		for (std::vector<std::string>::iterator i = createTorrentContext.trackers.begin(), end(createTorrentContext.trackers.end()); i != end; ++i, ++tier)
			t.add_tracker(*i, tier);
		for (std::vector<std::string>::iterator i = createTorrentContext.webSeeds.begin(), end(createTorrentContext.webSeeds.end()); i != end; ++i)
			t.add_url_seed(*i);

		error_code ec;
		set_piece_hashes(t, parent_path(createTorrentContext.inputFile), boost::bind(&printCreationProgress, _1, t.num_pieces()), ec);
		t.set_priv(createTorrentContext.isPrivate);

		if (ec) {
			logError(ec.message().c_str());
			mutex.unlock();
			return;
		}

		t.set_creator(createTorrentContext.creator.c_str());
		if (!createTorrentContext.comment.empty())
			t.set_comment(createTorrentContext.comment.c_str());

		if (!createTorrentContext.rootCert.empty()) {
			std::vector<char> pem;
			loadFile(createTorrentContext.rootCert, pem, ec, 10000);
			if (ec)
				logError(ec.message().c_str());
			else
				t.set_root_cert(std::string(&pem[0], pem.size()));
		}

		std::vector<char> torrent;
		libtorrent::bencode(back_inserter(torrent), t.generate());
		saveFile(createTorrentContext.outputFile, torrent);

		using json = nlohmann::json;
		json j;
		j["fileName"] = createTorrentContext.outputFile;
		j["seedNow"] = createTorrentContext.seedNow;

		FREDispatchStatusEventAsync(dllContext, (uint8_t*)j.dump().c_str(), (const uint8_t*)torrentInfoEvent.TORRENT_CREATED.c_str());
		mutex.unlock();
	}
	void threadAddFilterList(int p) {
		using namespace std;
		using namespace boost::algorithm;
		using namespace libtorrent;

		boost::mutex mutex;
		using boost::this_thread::get_id;
		mutex.lock();

		ifstream file(settingsContext.filters.filename);
		std::string line;
		std::string ipRangeFromStr;
		std::string ipRangeToStr;

		ip_filter ipFilterList;
		unsigned int numFilters = 0;

		if (file.is_open()) {
			address ipRangeTo;
			while (getline(file, line)) {
				if (starts_with(line, "#") || starts_with(line, "//") || line.empty()) continue;
				vector<std::string> partsList;
				vector<std::string> IPList;

				boost::split(partsList, line, boost::is_any_of(":"));
				if (partsList.size() < 2) continue;

				boost::split(IPList, partsList.at(partsList.size() - 1), boost::is_any_of("-"));
				if (IPList.size() != 2) continue;

				ipRangeFromStr = IPList.at(0);
				boost::trim(ipRangeFromStr);

				if (ipRangeFromStr.empty()) continue;

				boost::system::error_code ec;

				address ipRangeFrom = ipRangeFrom.from_string(ipRangeFromStr, ec);
				if (ec) continue;

				ipRangeToStr = IPList.at(1);
				boost::trim(ipRangeToStr);

				if (ipRangeToStr.empty()) continue;

				address ipRangeTo = ipRangeTo.from_string(ipRangeToStr, ec);
				if (ec) continue;
				try {
					ipFilterList.add_rule(ipRangeFrom, ipRangeTo, libtorrent::ip_filter::blocked);
					numFilters++;
				}
				catch (std::exception &) {
					//sendError(msg.what());
					continue;
				}
			}
			if (numFilters > 0) ltsession->set_ip_filter(ipFilterList);
		}
		file.close();
		using json = nlohmann::json;
		json j;
		j["numFilters"] = numFilters;

		FREDispatchStatusEventAsync(dllContext, (uint8_t*)j.dump().c_str(), (const uint8_t*)torrentInfoEvent.FILTER_LIST_ADDED.c_str());
		mutex.unlock();
	}

	FREObject createTorrent(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		createTorrentContext.inputFile = getStringFromFREObject(argv[0]);
		createTorrentContext.outputFile = getStringFromFREObject(argv[1]);
		createTorrentContext.trackers = getStringVectorFromFREObject(argv[2], (const uint8_t*)"uri");
		createTorrentContext.webSeeds = getStringVectorFromFREObject(argv[3], (const uint8_t*)"uri");
		createTorrentContext.pieceSize = getUInt32FromFREObject(argv[4]) * 1024;
		createTorrentContext.isPrivate = getBoolFromFREObject(argv[5]);
		createTorrentContext.comment = getStringFromFREObject(argv[6]);
		createTorrentContext.creator = clientName;
		createTorrentContext.seedNow = getBoolFromFREObject(argv[7]);
		createTorrentContext.rootCert = getStringFromFREObject(argv[8]);
		threads[0] = boost::move(createThread(&threadCreateTorrent, 1));
		return getReturnTrue();
	}


	
	FREObject saveSessionState(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		using namespace std;
		using namespace libtorrent;
		entry session_state;
		ltsession->save_state(session_state);
		std::vector<char> out;
		libtorrent::bencode(std::back_inserter(out), session_state);
		saveFile(settingsContext.storage.sessionStatePath + pathSlash + ".ses_state", out);
		return getReturnTrue();
	}

	FREObject addFilterList(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		settingsContext.filters.filename = getStringFromFREObject(argv[0]);
		settingsContext.filters.applyToTrackers = getBoolFromFREObject(argv[1]);
		threads[0] = boost::move(createThread(&threadAddFilterList, 1));
		return getReturnTrue();
	}
	
	FREObject isSupported(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		return getFREObjectFromBool(isSupportedInOS);
	}

	FREObject saveAs(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
		nfdchar_t *outPath = NULL;
		nfdresult_t result = NFD_SaveDialog(getStringFromFREObject(argv[0]).c_str(), getStringFromFREObject(argv[1]).c_str(), &outPath);
		if (result == NFD_OKAY) {
		}
		else if (result == NFD_CANCEL) {
			outPath = "";
		}
		else {
			outPath = "";
			trace(NFD_GetError());
		}
		return getFREObjectFromString(outPath);
	}
	void contextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet, const FRENamedFunction** functionsToSet) {
		static FRENamedFunction extensionFunctions[] = {
			{ (const uint8_t*) "isSupported",NULL, &isSupported }
			,{ (const uint8_t*) "removeTorrent",NULL, &removeTorrent }
			,{ (const uint8_t*) "addTorrent",NULL, &addTorrent }
			,{ (const uint8_t*) "initSession",NULL, &initSession }
			,{ (const uint8_t*) "endSession",NULL, &endSession }
			,{ (const uint8_t*) "getTorrentInfo",NULL, &getTorrentInfo }
			,{ (const uint8_t*) "postTorrentUpdates",NULL, &postTorrentUpdates }
			,{ (const uint8_t*) "getTorrentPeers",NULL, &getTorrentPeers }
			,{ (const uint8_t*) "getTorrentTrackers",NULL, &getTorrentTrackers }
			,{ (const uint8_t*) "pauseTorrent",NULL, &pauseTorrent }
			,{ (const uint8_t*) "resumeTorrent",NULL, &resumeTorrent }
			,{ (const uint8_t*) "updateSettings",NULL, &updateSettings }
			,{ (const uint8_t*) "setSequentialDownload",NULL, &setSequentialDownload }
			,{ (const uint8_t*) "addDHTRouter",NULL, &addDHTRouter }
			,{ (const uint8_t*) "setQueuePosition",NULL, &setQueuePosition }
			,{ (const uint8_t*) "addFilterList",NULL, &addFilterList }
			,{ (const uint8_t*) "createTorrent",NULL, &createTorrent }
			,{ (const uint8_t*) "saveSessionState",NULL, &saveSessionState }
			,{ (const uint8_t*) "getMagnetURI",NULL, &getMagnetURI }
			,{ (const uint8_t*) "setFilePriority",NULL, &setFilePriority }
			,{ (const uint8_t*) "forceRecheck",NULL, &forceRecheck }
			,{ (const uint8_t*) "forceAnnounce",NULL, &forceAnnounce }
			,{ (const uint8_t*) "forceDHTAnnounce",NULL, &forceDHTAnnounce }
			,{ (const uint8_t*) "setPiecePriority",NULL, &setPiecePriority }
			,{ (const uint8_t*) "setPieceDeadline",NULL, &setPieceDeadline }
			,{ (const uint8_t*) "resetPieceDeadline",NULL, &resetPieceDeadline }
			,{ (const uint8_t*) "addTracker",NULL, &addTracker }
			,{ (const uint8_t*) "addUrlSeed",NULL, &addUrlSeed }
			,{ (const uint8_t*) "removeUrlSeed",NULL, &removeUrlSeed }
			,{ (const uint8_t*) "saveAs",NULL, &saveAs }
		};

		*numFunctionsToSet = sizeof(extensionFunctions) / sizeof(FRENamedFunction);
		*functionsToSet = extensionFunctions;
		dllContext = ctx;
	}


	void contextFinalizer(FREContext ctx) {
		using namespace libtorrent;
		if (ltsession->is_listening()) {
			settings_pack endSettings;
#ifndef TORRENT_DISABLE_DHT
			if (ltsession->is_dht_running())
				endSettings.set_bool(settings_pack::enable_dht, false);
#endif
			endSettings.set_bool(settings_pack::enable_lsd, false);
			endSettings.set_bool(settings_pack::enable_upnp, false);
			endSettings.set_bool(settings_pack::enable_natpmp, false);
			ltsession->apply_settings(endSettings);
			ltsession->pause();
		}
		return;
	}

	void TRLTAExtInizer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer) {
		*ctxInitializer = &contextInitializer;
		*ctxFinalizer = &contextFinalizer;
	}

	void TRLTAExtFinizer(void* extData) {
		FREContext nullCTX;
		nullCTX = 0;
		contextFinalizer(nullCTX);
		return;
	}

}