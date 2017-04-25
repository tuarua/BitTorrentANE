/*@copyright The code is licensed under the[MIT
License](http://opensource.org/licenses/MIT):

Copyright © 2015 - 2017 Tua Rua Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files(the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions :

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.*/

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

#include <cstdarg>

#include <utility>
#include <string>
#include <fstream>
#include <map>

#include <boost/lexical_cast.hpp>
#include <boost/numeric/conversion/cast.hpp>
#include <boost/algorithm/string/split.hpp>
#include <boost/algorithm/string.hpp>
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
#include "libtorrent/torrent_info.hpp"
#include "libtorrent/announce_entry.hpp"
#include "libtorrent/bitfield.hpp"
#include "libtorrent/bdecode.hpp"
#include "libtorrent/add_torrent_params.hpp"

#include <ANEhelper.h>

const std::string ANE_NAME = "BitTorrentANE";
ANEHelper aneHelper = ANEHelper();

#include "json.hpp"

#ifdef _WIN32

bool isSupportedInOS = true;
std::string pathSlash = "\\";
#else

#include <Adobe AIR/Adobe AIR.h>

bool isSupportedInOS = true;
std::string pathSlash = "/";
#endif


#include "Constants.hpp"
#include "Settings.hpp"


std::string clientName;

libtorrent::session *ltsession = nullptr;

struct addedTorrentId {
};
struct addedTorrentHash {
};
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

extern int loadFile(std::string const &filename, std::vector<char> &v, boost::system::error_code &ec, int limit = 8000) {
    ec.clear();
    FILE *f = fopen(filename.c_str(), "rb");
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

    v.resize((unsigned long) s);
    if (s == 0) {
        fclose(f);
        return 0;
    }

    r = (int) fread(&v[0], 1, v.size(), f);
    if (r < 0) {
        ec.assign(errno, boost::system::get_generic_category());
        fclose(f);
        return -1;
    }

    fclose(f);

    if (r != s) return -3;

    return 0;
}

libtorrent::torrent_info readTorrentInfo(std::string const &filename) {
    using namespace libtorrent;
    auto item_limit = 1000000;
    auto depth_limit = 1000;
    std::vector<char> buf;
    boost::system::error_code ec;
    loadFile(filename, buf, ec, 40 * item_limit);
    bdecode_node e;
    auto pos = -1;
    bdecode(&buf[0], &buf[0] + buf.size(), e, ec, &pos, depth_limit, item_limit);
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


std::string urldecode(const std::string &str) {
    using namespace std;
    string result;
    string::size_type i;
    for (i = 0; i < str.size(); ++i) {
        if (str[i] == '+') {
            result += ' ';
        } else if (str[i] == '%' && str.size() > i + 2) {
            const unsigned char ch1 = from_hex((unsigned char) str[i + 1]);
            const unsigned char ch2 = from_hex((unsigned char) str[i + 2]);
            const unsigned char ch = (ch1 << 4) | ch2;
            result += ch;
            i += 2;
        } else {
            result += str[i];
        }
    }
    return result;
}


FREObject getFRETorrentInfo(libtorrent::torrent_info ti, std::string filename) {
    using namespace libtorrent;
    auto torrentMeta = aneHelper.createFREObject("com.tuarua.torrent.TorrentInfo");
    aneHelper.setProperty(torrentMeta, "status", "ok");

    aneHelper.setProperty(torrentMeta, "isPrivate", ti.priv());
    aneHelper.setProperty(torrentMeta, "torrentFile", filename);
    aneHelper.setProperty(torrentMeta, "numPieces", ti.num_pieces());

    aneHelper.setProperty(torrentMeta, "size", ti.total_size());
    aneHelper.setProperty(torrentMeta, "pieceLength", ti.piece_length());
    aneHelper.setProperty(torrentMeta, "infoHash", boost::lexical_cast<std::string>(ti.info_hash()));

    aneHelper.setProperty(torrentMeta, "name", ti.name());
    aneHelper.setProperty(torrentMeta, "comment", ti.comment());
    aneHelper.setProperty(torrentMeta, "creator", ti.creator());
    aneHelper.setProperty(torrentMeta, "creationDate", boost::numeric_cast<uint32_t>(ti.creation_date().get()));


    auto const &sto = ti.files();

    auto vecTorrents = aneHelper.createFREObject("Vector.<com.tuarua.torrent.TorrentFileMeta>");
    FRESetArrayLength(vecTorrents, (uint32_t) sto.num_files());

    for (int i = 0; i < sto.num_files(); ++i) {
        auto first = sto.map_file(i, 0, 0).piece;
        auto last = sto.map_file(i, (std::max)(int64_t(sto.file_size(i)) - 1, int64_t(0)), 0).piece;

        auto meta = aneHelper.createFREObject("com.tuarua.torrent.TorrentFileMeta");
        aneHelper.setProperty(meta, "path", sto.file_path(i));
        aneHelper.setProperty(meta, "name", sto.file_name(i));
        aneHelper.setProperty(meta, "offset", sto.file_offset(i));
        aneHelper.setProperty(meta, "size", sto.file_size(i));
        aneHelper.setProperty(meta, "firstPiece", first);
        aneHelper.setProperty(meta, "lastPiece", last);

        FRESetArrayElementAt(vecTorrents, (uint32_t) i, meta);
    }

    aneHelper.setProperty(torrentMeta, "files", vecTorrents);

    auto vecUrlSeeds = aneHelper.createFREObject("Vector.<String>");

    std::vector<web_seed_entry> webSeeds;
    webSeeds = ti.web_seeds();

    FRESetArrayLength(vecUrlSeeds, uint32_t(webSeeds.size()));
    uint32_t cnt = 0;
    for (std::vector<web_seed_entry>::const_iterator i = webSeeds.begin(); i != webSeeds.end(); ++i) {
        FRESetArrayElementAt(vecUrlSeeds, cnt, aneHelper.getFREObject(i->url));
        cnt++;
    }
    aneHelper.setProperty(torrentMeta, "urlSeeds", vecUrlSeeds);

    return torrentMeta;
}

libtorrent::settings_pack getDefaultSessionSettings(std::vector<std::string> dhtRouters) {
    using namespace libtorrent;
    settings_pack settings;

    settings.set_str(settings_pack::user_agent, clientName);
    settings.set_bool(settings_pack::apply_ip_filter_to_trackers, (!settingsContext.filters.filename.empty()
            && settingsContext.filters.applyToTrackers));
    settings.set_bool(settings_pack::upnp_ignore_nonrouters, true);
    settings.set_int(settings_pack::ssl_listen, 0);
    settings.set_bool(settings_pack::lazy_bitfields, true);

    settings.set_int(settings_pack::stop_tracker_timeout, 1);
    settings.set_int(settings_pack::auto_scrape_interval, 1200);
    settings.set_int(settings_pack::auto_scrape_min_interval, 900);
    settings.set_bool(settings_pack::announce_to_all_trackers, settingsContext.advanced.announceToAllTrackers);
    settings.set_bool(settings_pack::announce_to_all_tiers, settingsContext.advanced.announceToAllTrackers);

    int cache_size = settingsContext.advanced.diskCacheSize;
    if (cache_size > 0)
        cache_size = cache_size * 64;  //0 is off, -1 is 1/8 of machine's RAM

    settings.set_int(settings_pack::cache_size, cache_size);
    settings.set_int(settings_pack::cache_expiry, settingsContext.advanced.diskCacheTTL);
    settings_pack::io_buffer_mode_t mode =
            settingsContext.advanced.enableOsCache ? settings_pack::enable_os_cache : settings_pack::disable_os_cache;

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

    if (settingsContext.advanced.outgoingPortsMin > 0 && settingsContext.advanced.outgoingPortsMax > 0
            && settingsContext.advanced.outgoingPortsMin < settingsContext.advanced.outgoingPortsMax) {
        boost::mt19937 gen;
        boost::uniform_int<> dist(settingsContext.advanced.outgoingPortsMin, settingsContext.advanced.outgoingPortsMax);
        boost::variate_generator<boost::mt19937 &, boost::uniform_int<> > randRange(gen, dist);
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
    settings.set_bool(settings_pack::volatile_read_cache, false);

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
            settings.set_int(settings_pack::proxy_port, settingsContext.proxy.port);
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
            default:;
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
            ltsession->add_dht_router(make_pair(dhtRouters.at(i), settingsContext.listening.port));
    } else if (ltsession->is_dht_running()) {
        settings.set_bool(settings_pack::enable_dht, false);
    }

    return settings;
}

unsigned int numAvailableThreads = boost::thread::hardware_concurrency();

boost::thread threads[1];

boost::thread createThread(void(*otherFunction)(int p), int p) {
    boost::thread t(*otherFunction, p);
    return move(t);
}

bool yes(libtorrent::torrent_status const &) {
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
#define FRE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])
FREContext dllContext;
unsigned int logLevel = 0;

std::vector<std::string> dhtRouters = {};

extern void trace(std::string msg) {
    auto value = "[" + ANE_NAME + "] " + msg;
    if (logLevel > 0)
        aneHelper.dispatchEvent(dllContext, "TRACE", msg);
}
extern void logError(std::string msg) {
    aneHelper.dispatchEvent(dllContext, torrentInfoEvent.ON_ERROR, msg);
}
extern void logInfo(std::string msg) {
    if (logLevel > 0)
        aneHelper.dispatchEvent(dllContext, "INFO", msg);
}
void printFREResult(FREResult errorCode, char *errMessage) {
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
        case FREResult_ENUMPADDING:
            break;
        default:;
    }
}

int saveFile(std::string const &filename, std::vector<char> &v) {
    auto f = fopen(filename.c_str(), "wb");
    if (NULL == f)
        return -1;

    int w = (int) fwrite(&v[0], 1, v.size(), f);
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
    file_storage const &st = ti->files();
    int first = 0;
    int last = 0;
    bool found = false;
    for (int i = 0; i < st.num_files(); ++i) {
        for (unsigned int j = 0; j < settingsContext.priorityFileTypes.size(); ++j) {
            if (boost::algorithm::ends_with(st.file_path(i), "." + settingsContext.priorityFileTypes[j])) {
                first = st.map_file(i, 0, 0).piece;
                last = st.map_file(i, (std::max)(int64_t(st.file_size(i)) - 1, int64_t(0)), 0).piece;
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

void handleAlert(libtorrent::alert *a) {
    using namespace libtorrent;
    using namespace std;
    using std::ios;
    using json = nlohmann::json;

    if (logLevel == LogLevelConstants::DBG) {
        logInfo(a->what());
        logInfo("alert message: " + a->message());
    }

    if (auto *alert = alert_cast<listen_failed_alert>(a)) {
        using json = nlohmann::json;
        json j;
        auto ep = alert->endpoint;
        j["port"] = ep.port();
        j["message"] = alert->message();
        j["address"] = ep.address().to_string();
        switch (alert->sock_type) {
            case listen_failed_alert::socket_type_t::tcp:
                j["type"] = "tcp";
                break;
            case listen_failed_alert::socket_type_t::tcp_ssl:
                j["type"] = "tcp_ssl";
                break;
            case listen_failed_alert::socket_type_t::udp:
                j["type"] = "udp";
                break;
            case listen_failed_alert::socket_type_t::i2p:
                j["type"] = "i2p";
                break;
            case listen_failed_alert::socket_type_t::socks5:
                j["type"] = "socks5";
                break;
            case listen_failed_alert::socket_type_t::utp_ssl:
                j["type"] = "utp_ssl";
                break;
            default:
                j["type"] = "tcp";
                break;
        }
        aneHelper.dispatchEvent(dllContext, torrentAlertEvent.LISTEN_FAILED, j.dump());
    } else if (auto *alert2 = alert_cast<listen_succeeded_alert>(a)) {

    } else if (auto *alert3 = alert_cast<state_update_alert>(a)) {
        vector<torrent_status> torrentList = alert3->status;
        std::string hash;
        std::string id;
        json j;
        for (vector<torrent_status>::const_iterator i = torrentList.begin(); i != torrentList.end(); ++i) {
            json jitm;
            hash = boost::lexical_cast<std::string>(i->info_hash);
            id = getIdFromHash(hash);
            jitm["id"] = id;
            jitm["numPieces"] = i->num_pieces;
            jitm["isSequential"] = i->sequential_download;
            jitm["queuePosition"] = i->queue_position;
            jitm["progress"] = i->progress * 100;
            jitm["downloadRate"] = i->download_payload_rate;
            jitm["downloadRateAverage"] = static_cast<uint32_t>(i->all_time_download / (1 + i->active_time - i->finished_time));
            jitm["allTimeDownload"] = i->all_time_download;
            jitm["downloadPayloadRate"] = i->download_payload_rate;
            jitm["uploadRate"] = i->upload_payload_rate;
            jitm["uploadRateAverage"] = static_cast<uint32_t>(i->all_time_upload / (1 + i->active_time));
            jitm["numPeers"] = i->num_peers;
            jitm["numPeersTotal"] = i->list_peers;
            jitm["numSeeds"] = i->num_seeds;
            jitm["numSeedsTotal"] = i->list_seeds;
            jitm["wasted"] = static_cast<uint32_t>(i->total_failed_bytes + i->total_redundant_bytes);
            jitm["activeTime"] = (i->state == torrent_status::seeding) ? i->seeding_time : i->active_time;
            jitm["downloaded"] = i->all_time_download;
            jitm["downloadedSession"] = i->total_payload_download;
            jitm["uploaded"] = i->all_time_upload;
            jitm["uploadedSession"] = i->total_payload_upload;
            jitm["uploadMax"] = (i->uploads_limit > 0) ? i->uploads_limit : -1;
            jitm["numConnections"] = i->num_connections;

            auto int_announce = duration_cast<seconds>(i->next_announce);
            jitm["nextAnnounce"] = (int_announce.count() > 0 && int_announce.count() < 3600) ? int_announce.count() : 0;

            jitm["lastSeenComplete"] = i->last_seen_complete;
            jitm["completedOn"] = i->completed_time;
            jitm["savePath"] = i->save_path;
            jitm["addedOn"] = i->added_time;

            auto uploadR = static_cast<double>(i->all_time_upload);
            auto downloadR = i->all_time_download < i->total_done * 0.01 ? static_cast<double>(i->total_done) : static_cast<double>(i->all_time_download);

            if (downloadR == 0) {
                jitm["shareRatio"] = (uploadR == 0) ? 0.00 : 9999.0;
            } else {
                auto ratio = static_cast<double>(uploadR / downloadR);
                jitm["shareRatio"] = (ratio > 9999.0) ? 9999.0 : ratio;
            }
            jitm["addedOn"] = i->added_time;
            auto th = i->handle;
            jitm["downloadMax"] = th.download_limit();


            //partial pieces
            vector<partial_piece_info> queue;
            th.get_download_queue(queue);
            json jpieces;
            for (vector<partial_piece_info>::const_iterator it = queue.begin(); it != queue.end(); ++it)
                jpieces.push_back(it->piece_index);
            jitm["partialPieces"] = jpieces;

            if (settingsContext.queryFileProgress && i->state != torrent_status::seeding) {
                vector<int64_t> fp;
                i->handle.file_progress(fp);
                json jprogress;
                for (unsigned int k = 0; k < fp.size(); ++k)
                    jprogress.push_back(static_cast<double>(fp.at(k)));
                jitm["fileProgress"] = jprogress;

                vector<int> fpri;
                fpri = i->handle.file_priorities();

                json jpriorities;
                for (unsigned int k = 0; k < fpri.size(); ++k)
                    jpriorities.push_back(fpri.at(k));
                jitm["filePriority"] = jpriorities;
            }

            j.push_back(jitm);
        }
        aneHelper.dispatchEvent(dllContext, torrentAlertEvent.STATE_UPDATE, j.dump());
    } else if (auto *alert4 = alert_cast<state_changed_alert>(a)) {
        auto th = alert4->handle;
        if (th.is_valid()) {
            boost::shared_ptr<const torrent_info> ti = th.torrent_file();
            auto status = th.status();
            auto hash = boost::lexical_cast<std::string>(status.info_hash);
            auto id = getIdFromHash(hash);
            json j;
            j["id"] = getIdFromHash(id);
            if (status.paused) {
                j["state"] = (status.auto_managed) ? 8 : 9;
            } else {
                j["state"] = alert4->state;
            }
            aneHelper.dispatchEvent(dllContext, torrentAlertEvent.STATE_CHANGED, j.dump());
        }
    } else if (auto *alert5 = alert_cast<torrent_paused_alert>(a)) {
        auto th = alert5->handle;
        if (th.is_valid()) {
            auto status = th.status();
            auto hash = boost::lexical_cast<std::string>(status.info_hash);
            auto id = getIdFromHash(hash);
            json j;
            j["id"] = getIdFromHash(id);
            j["state"] = (status.auto_managed) ? 8 : 9;
            aneHelper.dispatchEvent(dllContext, torrentAlertEvent.TORRENT_PAUSED, j.dump());
        }
    } else if (auto *alert6 = alert_cast<torrent_resumed_alert>(a)) {
        auto th = alert6->handle;
        if (th.is_valid()) {
            auto status = th.status();
            auto hash = boost::lexical_cast<std::string>(status.info_hash);
            auto id = getIdFromHash(hash);
            json j;
            j["id"] = getIdFromHash(id);
            j["state"] = status.state;
            aneHelper.dispatchEvent(dllContext, torrentAlertEvent.TORRENT_RESUMED, j.dump());
        }
    } else if (auto *alert7 = alert_cast<torrent_finished_alert>(a)) {
        auto th = alert7->handle;
        if (th.is_valid()) {
            boost::shared_ptr<const torrent_info> ti = th.torrent_file();
            th.save_resume_data();
            if (settingsContext.advanced.recheckTorrentsOnCompletion)
                th.force_recheck();

            auto hash = boost::lexical_cast<std::string>(ti->info_hash());
            auto id = getIdFromHash(hash);
            json j;
            j["id"] = getIdFromHash(id);
            aneHelper.dispatchEvent(dllContext, torrentAlertEvent.TORRENT_FINISHED, j.dump());
        }
    } else if (auto *alert8 = alert_cast<piece_finished_alert>(a)) {
        auto th = alert8->handle;
        if (th.is_valid()) {
            boost::shared_ptr<const torrent_info> ti = th.torrent_file();
            if (ti) {
                std::string hash = boost::lexical_cast<std::string>(ti->info_hash());
                std::string id = getIdFromHash(hash);
                json j;
                j["id"] = getIdFromHash(boost::lexical_cast<std::string>(ti->info_hash()));
                j["index"] = alert8->piece_index;
                aneHelper.dispatchEvent(dllContext, torrentAlertEvent.PIECE_FINISHED, j.dump());
            }
        }
    } else if (auto *alert9 = alert_cast<tracker_reply_alert>(a)) {
        auto th = alert9->handle;
        if (th.is_valid()) {
            boost::shared_ptr<const torrent_info> ti = th.torrent_file();
            if (ti) {
                std::string hash = boost::lexical_cast<std::string>(ti->info_hash());
                std::string id = getIdFromHash(hash);
                auto search = torrentTrackerPeerMap[id].find(alert9->url);
                if (search != torrentTrackerPeerMap[id].end())
                    search->second = alert9->num_peers;
            }
        }
    } else if (auto *alert10 = alert_cast<metadata_received_alert>(a)) {
        auto th = alert10->handle;
        if (th.is_valid()) {
            torrent_info ti = th.get_torrent_info();

            auto idFromHandleSearch = addedTorrentHandles.find(th.id());
            auto idFromHandle = idFromHandleSearch->second;
            std::string id;
            if (!idFromHandle.empty()) {
                id = idFromHandle;
                auto existingHash = getHashFromId(id);
            } else {
                id = getIdFromHash(boost::lexical_cast<std::string>(ti.info_hash()));
                if (id.empty())
                    id = boost::lexical_cast<std::string>(ti.info_hash());
            }

            addedTorrents.left.erase(id);
            addedTorrents.insert(hashes(id, boost::lexical_cast<std::string>(ti.info_hash())));

            auto search = addedMagnetsUriMap.find(id);
            auto sUri = search->second;

            vector<std::string> aUris;
            split(aUris, sUri, boost::is_any_of("&"));
            std::string s;
            for (unsigned int i = 1; i < aUris.size(); i++) {
                s = urldecode(aUris.at(i));
                if (boost::algorithm::starts_with(s, "ws=")) {
                    s = s.substr(3);
                    ti.add_url_seed(s);
                }
            }
            create_torrent ct(ti);
            auto te = ct.generate();
            vector<char> data;
            auto filename = settingsContext.storage.torrentPath + pathSlash + id + ".torrent";
            bencode(back_inserter(data), te);
            saveFile(filename, data);
            ltsession->remove_torrent(th);

            addedMagnetsUriMap.erase(id);
            json j;
            j["id"] = id;
            j["isSequential"] = th.status().sequential_download;
            aneHelper.dispatchEvent(dllContext, torrentAlertEvent.METADATA_RECEIVED, j.dump());
        }

    } else if (auto *alert11 = alert_cast<save_resume_data_alert>(a)) {
        auto th = alert11->handle;
        if (th.is_valid()) {
            vector<char> out;
            bencode(back_inserter(out), *alert11->resume_data);
            auto status = th.status(torrent_handle::query_save_path); //don't need this ?
            auto hash = boost::lexical_cast<std::string>(th.info_hash());
            auto id = getIdFromHash(hash);
            saveFile((settingsContext.storage.resumePath + pathSlash + id + ".resume"), out);
            json j;
            j["id"] = id;
            aneHelper.dispatchEvent(dllContext, torrentAlertEvent.SAVE_RESUME_DATA, j.dump());
        }
    } else if (auto *alert12 = alert_cast<add_torrent_alert>(a)) {
        auto th = alert12->handle;
        if (alert12->error || th.is_valid()) {
            if (alert12->params.userdata) {
                vector<std::string> aUserData;
                std::string sUserData = static_cast<char *>(alert12->params.userdata);
                split(aUserData, sUserData, boost::is_any_of("|"));
                auto id = aUserData[0];
                auto hash = aUserData[1];
                auto uri = aUserData[2];

                addedTorrentHandles.insert(make_pair(th.id(), id));
                addedMagnetsUriMap.insert(make_pair(id, uri));
            } else {
                auto ti = th.torrent_file();
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
                aneHelper.dispatchEvent(dllContext, torrentAlertEvent.TORRENT_ADDED, j.dump());
            }
        } else {
            logError(alert12->message());
        }

    } else if (auto *alert13 = alert_cast<torrent_checked_alert>(a)) {
        auto th = alert13->handle;
        if (th.is_valid()) {
            boost::shared_ptr<const torrent_info> ti = th.torrent_file();
            auto hash = boost::lexical_cast<std::string>(ti->info_hash());
            auto id = getIdFromHash(hash);
            json j;
            j["id"] = id;
            for (vector<announce_entry>::const_iterator i = ti->trackers().begin(); i != ti->trackers().end(); ++i) {
                torrentTrackerPeerMap.insert(make_pair(id, TrackerPeerMap()));
                torrentTrackerPeerMap[id].insert(make_pair(i->url, 0));
            }
            if (th.status().paused && !th.status().auto_managed)
                th.resume();
            aneHelper.dispatchEvent(dllContext, torrentAlertEvent.TORRENT_CHECKED, j.dump());
        }
    } else if (auto *alert14 = alert_cast<file_completed_alert>(a)) {
        auto th = alert14->handle;
        if (th.is_valid()) {
            boost::shared_ptr<const torrent_info> ti = th.torrent_file();
            json j;
            j["id"] = getIdFromHash(boost::lexical_cast<std::string>(ti->info_hash()));
            j["index"] = alert14->index;
            //j["fileName"] = ti->file_at(alert->index).path;
            aneHelper.dispatchEvent(dllContext, torrentAlertEvent.FILE_COMPLETED, j.dump());
        }
    } else if (auto *alert15 = alert_cast<fastresume_rejected_alert>(a)) {
        auto th = alert15->handle;
        boost::shared_ptr<const torrent_info> ti = th.torrent_file();
        ti.reset();
        th.resume();
    }
}

FRE_FUNCTION(addTorrent) {
    using namespace boost;
    using namespace libtorrent;
    using json = nlohmann::json;
    system::error_code ec;
    using namespace std;
    bool isMagnet;

    auto id = aneHelper.getString(argv[0]);
    auto uri = aneHelper.getString(argv[1]);
    auto hash = aneHelper.getString(argv[2]);
    uint32_t isSeq;
    FREGetObjectAsBool(argv[3], &isSeq);
    uint32_t seedMode;
    FREGetObjectAsBool(argv[4], &seedMode);

    algorithm::to_lower(hash);
    algorithm::to_lower(id);
    isMagnet = starts_with(uri, "magnet");

    add_torrent_params p;

    p.max_connections = settingsContext.connections.maxNumPerTorrent;
    p.max_uploads = settingsContext.connections.maxUploadsPerTorrent;

    loadFile((settingsContext.storage.resumePath + pathSlash + id + ".resume").c_str(), p.resume_data, ec);

    if (ec)
        logError("Failed to load the resume: " + lexical_cast<std::string>(ec.message()));
    else
        logInfo("torrent started from the resume file");

    p.save_path = settingsContext.storage.outputPath;
    FREObject FREtorrentInfo = nullptr;
    if (isMagnet) {
        p.storage = disabled_storage_constructor;
        auto sUserData = id + "|" + hash + "|" + uri;
        p.userdata = static_cast<void *>(strdup(sUserData.c_str()));

        p.url = uri;
        parse_magnet_uri(uri, p, ec);

        if (ec) {
            logError("MAGNET_PARSE_FAIL");
        } else {
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
            addedTorrents.insert(hashes(id, lexical_cast<std::string>(th.info_hash())));
            th.resume();
        }
    } else {

        auto ti = readTorrentInfo(uri);
        FREtorrentInfo = getFRETorrentInfo(ti, uri);

        if (!settingsContext.storage.enabled)
            p.storage = zero_storage_constructor;

        p.ti = boost::make_shared<torrent_info>(std::string(uri), boost::ref(ec), 0);

        if (settingsContext.storage.sparse)
            p.storage_mode = storage_mode_sparse;
        else
            p.storage_mode = storage_mode_allocate;

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

        addedTorrents.insert(hashes(id, lexical_cast<std::string>(ti.info_hash())));

        ltsession->async_add_torrent(p);


    }
    return FREtorrentInfo;
}

void requestAlerts() {
    using namespace libtorrent;
    std::vector<alert *> alerts;
    ltsession->pop_alerts(&alerts);
    for (std::vector<alert *>::iterator i = alerts.begin(), end(alerts.end()); i != end; ++i)
        handleAlert(*i);
    alerts.clear();
}

FRE_FUNCTION(initSession) {
    using namespace libtorrent;

    FREObject result;
    FRENewObjectFromBool(true, &result);

    //deprecated init in a different way
    //ltsession = new session(fingerprint("LT", LIBTORRENT_VERSION_MAJOR, LIBTORRENT_VERSION_MINOR, LIBTORRENT_VERSION_TINY, 0), 0);
    //ltsession->set_alert_notify(requestAlerts);

    std::string peerId = generate_fingerprint("LT", LIBTORRENT_VERSION_MAJOR, LIBTORRENT_VERSION_MINOR, LIBTORRENT_VERSION_TINY, 0);

    auto settings = getDefaultSessionSettings(dhtRouters);

    settings.set_int(settings_pack::alert_mask, alert::error_notification
            | alert::peer_notification /*| alert::port_mapping_notification */
            | alert::storage_notification
            | alert::tracker_notification
            | alert::status_notification
            | alert::ip_block_notification
            | alert::progress_notification/* | alert::rss_notification | alert::stats_notification*/);

    int port = settingsContext.listening.port;
    if (settingsContext.advanced.networkInterface.size() > 0) {
        std::vector<std::pair<std::string, std::string>> nv;
        nv = settingsContext.advanced.networkInterface;
        for (std::vector<std::pair<std::string, std::string>>::const_iterator i = nv.begin(); i != nv.end(); ++i) {
            if ((!settingsContext.advanced.listenOnIPv6 && (i->second == "IPv6"))
                    || (settingsContext.advanced.listenOnIPv6 && (i->second == "IPv4")))
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


    ltsession = new session(settings, 0);
    ltsession->set_alert_notify(requestAlerts);
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
    if (settingsContext.advanced.enableTrackerExchange)
        ltsession->add_extension(&create_lt_trackers_plugin);
    if (settingsContext.privacy.usePEX)
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

FRE_FUNCTION(getTorrentInfo) {
    std::string uri = aneHelper.getString(argv[0]);
    return getFRETorrentInfo(readTorrentInfo(uri), uri);
}

FRE_FUNCTION(getTorrentTrackers) {
    using namespace libtorrent;

    std::vector<torrent_status> temp;
    ltsession->get_torrent_status(&temp, &yes, 0);
    std::vector<torrent_handle> tv;
    tv = ltsession->get_torrents();

    auto vecTorrentTrackers = aneHelper.createFREObject("Vector.<com.tuarua.torrent.TorrentTrackers>");

    int cnt = 0;
    for (std::vector<torrent_handle>::const_iterator i = tv.begin(); i != tv.end(); ++i) {
        if (!i->torrent_file())
            continue;

        auto torrentTrackers = aneHelper.createFREObject("com.tuarua.torrent.TorrentTrackers");

        auto hash = boost::lexical_cast<std::string>(i->info_hash());
        auto id = getIdFromHash(hash);

        auto vecTrackers = aneHelper.createFREObject("Vector.<com.tuarua.torrent.TrackerInfo>");

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

        auto freTracker = aneHelper.createFREObject("com.tuarua.torrent.TrackerInfo");

        aneHelper.setProperty(freTracker, "url", "**[DHT]**");
        if (settingsContext.privacy.useDHT && !i->torrent_file()->priv())
            aneHelper.setProperty(freTracker, "status", "Working");
        else
            aneHelper.setProperty(freTracker, "status", "Disabled");
        if (i->torrent_file()->priv())
            aneHelper.setProperty(freTracker, "message", "This torrent is private");

        aneHelper.setProperty(freTracker, "numPeers", numDHT);
        FRESetArrayElementAt(vecTrackers, 0, freTracker);


        freTracker = aneHelper.createFREObject("com.tuarua.torrent.TrackerInfo");

        aneHelper.setProperty(freTracker, "url", "**[PeX]**");
        if (settingsContext.privacy.usePEX && !i->torrent_file()->priv())
            aneHelper.setProperty(freTracker, "status", "Working");
        else
            aneHelper.setProperty(freTracker, "status", "Disabled");
        if (i->torrent_file()->priv())
            aneHelper.setProperty(freTracker, "message", "This torrent is private");
        aneHelper.setProperty(freTracker, "numPeers", numPEX);
        FRESetArrayElementAt(vecTrackers, 1, freTracker);

        freTracker = aneHelper.createFREObject("com.tuarua.torrent.TrackerInfo");
        aneHelper.setProperty(freTracker, "url", "**[LSD]**");
        if (settingsContext.privacy.useLSD && !i->torrent_file()->priv())
            aneHelper.setProperty(freTracker, "status", "Working");
        else
            aneHelper.setProperty(freTracker, "status", "Disabled");
        if (i->torrent_file()->priv())
            aneHelper.setProperty(freTracker, "message", "This torrent is private");

        aneHelper.setProperty(freTracker, "numPeers", numLSD);
        FRESetArrayElementAt(vecTrackers, 2, freTracker);

        auto tr = i->trackers();

        uint32_t trackercnt = 3;

        //to prevent duplicates
        std::vector<std::string> existingTrackers;
        for (auto t = tr.begin(), end(tr.end()); t != end; ++t) {

            if (find(existingTrackers.begin(), existingTrackers.end(), t->url) != existingTrackers.end())
                continue;

            existingTrackers.push_back(t->url);

            auto freTracker2 = aneHelper.createFREObject("com.tuarua.torrent.TrackerInfo");

            aneHelper.setProperty(freTracker2, "tier", t->tier);
            aneHelper.setProperty(freTracker2, "url", t->url);


            if (t->verified) {
                aneHelper.setProperty(freTracker2, "status", "Working");
            } else if (t->updating && t->fails == 0) {
                aneHelper.setProperty(freTracker2, "status", "Updating");
            } else if (t->fails > 0) {
                aneHelper.setProperty(freTracker2, "status", "Not Working");
                aneHelper.setProperty(freTracker2, "message", t->last_error.message());
            } else {
                aneHelper.setProperty(freTracker2, "status", "Not contacted yet");
            }

            auto search = torrentTrackerPeerMap[id].find(t->url);
            if (search != torrentTrackerPeerMap[id].end())
                aneHelper.setProperty(freTracker2, "numPeers", search->second);

            FRESetArrayElementAt(vecTrackers, trackercnt, freTracker2);
            trackercnt++;
        }

        FRESetArrayLength(vecTrackers, trackercnt);

        aneHelper.setProperty(torrentTrackers, "id", id);
        aneHelper.setProperty(torrentTrackers, "trackersInfo", vecTrackers);
        FRESetArrayElementAt(vecTorrentTrackers, cnt, torrentTrackers);
        cnt++;
    }
    FRESetArrayLength(vecTorrentTrackers, cnt);
    return vecTorrentTrackers;
}

FRE_FUNCTION(getTorrentPeers) {
    using namespace libtorrent;

    //check we have a session
    std::vector<torrent_status> temp;

    auto queryid = aneHelper.getString(argv[0]);
    auto queryhash = getHashFromId(queryid);

    auto queryFlags = aneHelper.getBool(argv[1]);

    //ltsession->get_torrent_status(&temp, &yes, 0);
    std::vector<torrent_handle> tv;
    tv = ltsession->get_torrents();

    auto vecTorrentPeers = aneHelper.createFREObject("Vector.<com.tuarua.torrent.TorrentPeers>");

    auto cnt = 0;
    for (std::vector<torrent_handle>::const_iterator i = tv.begin(); i != tv.end(); ++i) {
        auto hash = boost::lexical_cast<std::string>(i->info_hash());
        auto id = getIdFromHash(hash);

        if (!queryhash.empty() && hash != queryhash)
            continue;

        if (!i->torrent_file())
            continue;

        auto torrentPeers = aneHelper.createFREObject("com.tuarua.torrent.TorrentPeers");

        aneHelper.setProperty(torrentPeers, "id", id);
        auto vecPeers = aneHelper.createFREObject("Vector.<com.tuarua.torrent.PeerInfo>");

        if (i->status().state != torrent_status::seeding) {
            std::vector<peer_info> peers;
            i->get_peer_info(peers);
            if (!peers.empty()) {
                FRESetArrayLength(vecPeers, static_cast<uint32_t>(peers.size()));
                uint32_t peercnt = 0;
                for (std::vector<peer_info>::const_iterator p = peers.begin(); p != peers.end(); ++p) {
                    if (p->flags & (peer_info::handshake | peer_info::connecting | peer_info::queued))
                        continue;

                    auto const &addr = p->ip.address();
                    boost::system::error_code ec;

                    auto frePeer = aneHelper.createFREObject("com.tuarua.torrent.PeerInfo");
                    aneHelper.setProperty(frePeer, "ip", addr.to_string(ec));
#ifndef TORRENT_DISABLE_RESOLVE_COUNTRIES
                    if (settingsContext.advanced.resolveCountries && p->country[0] != 0) {
                        std::stringstream ss;
                        ss << boost::format("%c%c") % p->country[0] % p->country[1];
                        aneHelper.setProperty(frePeer, "country", ss.str());
                    }
#endif
#ifndef TORRENT_DISABLE_GEO_IP
                    //if(settingsContext.advanced.resolveCountries)
                    //FRESetObjectProperty(frePeer, (const uint8_t*)"asName", getFREObjectFromString(p->inet_as_name), NULL); //NEED


#endif
                    aneHelper.setProperty(frePeer, "client", p->client);
                    aneHelper.setProperty(frePeer, "port", p->ip.port());
                    aneHelper.setProperty(frePeer, "localPort", p->local_endpoint.port());


                    if (p->flags & peer_info::utp_socket)
                        aneHelper.setProperty(frePeer, "connection", "uTP");
                    else if (p->flags & peer_info::i2p_socket)
                        aneHelper.setProperty(frePeer, "connection", "i2P");
                    else if (p->connection_type == peer_info::standard_bittorrent)
                        aneHelper.setProperty(frePeer, "connection", "BT");
                    else if (p->connection_type == peer_info::web_seed)
                        aneHelper.setProperty(frePeer, "connection", "Web");

                    aneHelper.setProperty(frePeer, "downSpeed", p->down_speed);
                    aneHelper.setProperty(frePeer, "downloaded", p->total_download);

                    aneHelper.setProperty(frePeer, "upSpeed", p->up_speed);
                    aneHelper.setProperty(frePeer, "uploaded", p->total_upload);

                    if (queryFlags) {
                        std::stringstream flgsAsString;
                        flgsAsString << "";

                        int isChoked = (p->flags & peer_info::choked);
                        int isRemoteChoked = (p->flags & peer_info::remote_choked);
                        int isRemoteInterested = (p->flags & peer_info::remote_interested);
                        int isInteresting = (p->flags & peer_info::interesting);

                        if (isInteresting && isRemoteChoked)
                            flgsAsString << "d ";
                        else flgsAsString << "D ";

                        if (isRemoteInterested && isChoked)
                            flgsAsString << "u ";
                        else flgsAsString << "U ";

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

                        auto freFlags = aneHelper.createFREObject("com.tuarua.torrent.PeerFlags");

                        if (isInteresting)
                            aneHelper.setProperty(freFlags, "isInteresting", true);
                        if (isChoked)
                            aneHelper.setProperty(freFlags, "isChoked", true);
                        if (isRemoteInterested)
                            aneHelper.setProperty(freFlags, "isRemoteInterested", true);
                        if (isRemoteChoked)
                            aneHelper.setProperty(freFlags, "isRemoteChoked", true);
                        if (p->flags & peer_info::supports_extensions)
                            aneHelper.setProperty(freFlags, "supportsExtensions", true);
                        if (p->flags & peer_info::local_connection)
                            aneHelper.setProperty(freFlags, "isLocalConnection", true);
                        if (p->flags & peer_info::seed)
                            aneHelper.setProperty(freFlags, "isSeed", true);
                        if (p->flags & peer_info::on_parole)
                            aneHelper.setProperty(freFlags, "onParole", true);
                        if (p->flags & peer_info::optimistic_unchoke)
                            aneHelper.setProperty(freFlags, "isOptimisticUnchoke", true);
                        if (p->flags & peer_info::snubbed)
                            aneHelper.setProperty(freFlags, "isSnubbed", true);
                        if (p->flags & peer_info::upload_only)
                            aneHelper.setProperty(freFlags, "isUploadOnly", true);
                        if (p->flags & peer_info::endgame_mode)
                            aneHelper.setProperty(freFlags, "isEndGameMode", true);
#ifndef TORRENT_DISABLE_ENCRYPTION
                        if (p->flags & peer_info::rc4_encrypted)
                            aneHelper.setProperty(freFlags, "isRC4encrypted", true);
                        if (p->flags & peer_info::plaintext_encrypted)
                            aneHelper.setProperty(freFlags, "isPlainTextEncrypted", true);
#endif
                        if (p->flags & peer_info::holepunched)
                            aneHelper.setProperty(freFlags, "isHolePunched", true);
                        if (p->source & peer_info::tracker)
                            aneHelper.setProperty(freFlags, "fromTracker", true);
                        if (p->source & peer_info::pex)
                            aneHelper.setProperty(freFlags, "fromPEX", true);
                        if (p->source & peer_info::dht)
                            aneHelper.setProperty(freFlags, "fromDHT", true);
                        if (p->source & peer_info::lsd)
                            aneHelper.setProperty(freFlags, "fromLSD", true);
                        if (p->source & peer_info::resume_data)
                            aneHelper.setProperty(freFlags, "fromResumeData", true);
                        if (p->source & peer_info::incoming)
                            aneHelper.setProperty(freFlags, "fromIncoming", true);

                        aneHelper.setProperty(frePeer, "flags", freFlags);
                        aneHelper.setProperty(frePeer, "flagsAsString", flgsAsString.str());
                    }

                    //relevance
                    auto localMissing = 0;
                    auto remoteHaves = 0;
                    auto local = static_cast<bitfield &&>(i->status().pieces);
                    auto remote = p->pieces;
                    for (auto j = 0; j < local.size(); ++j) {
                        if (!local[j]) {
                            ++localMissing;
                            if (remote[j]) ++remoteHaves;
                        }
                    }

                    aneHelper.setProperty(frePeer, "relevance", localMissing == 0 ? 0.0 : static_cast<double>(remoteHaves / localMissing));
                    aneHelper.setProperty(frePeer, "progress", p->progress);

                    FRESetArrayElementAt(vecPeers, peercnt, frePeer);

                    peercnt++;
                }
                FRESetArrayLength(vecPeers, peercnt);
            }
        }

        aneHelper.setProperty(torrentPeers, "peersInfo", vecPeers);

        FRESetArrayElementAt(vecTorrentPeers, cnt, torrentPeers);
        cnt++;
    }

    return vecTorrentPeers;
}

FRE_FUNCTION(postTorrentUpdates) {
    using namespace libtorrent;
    ltsession->post_torrent_updates(statusFlags);
    return aneHelper.getFREObject(true);
}

FRE_FUNCTION(getMagnetURI) {
    using namespace libtorrent;
    using namespace std;
    auto id = aneHelper.getString(argv[0]);
    auto hash = getHashFromId(id);
    std::string ret = "";
    auto fh = findHandle(hash);
    if (fh.is_valid()) {
        if (fh.is_valid())
            ret = make_magnet_uri(fh);
    }
    return aneHelper.getFREObject(ret);
}

FRE_FUNCTION(setPieceDeadline) {
    using namespace libtorrent;
    using namespace std;
    auto id = aneHelper.getString(argv[0]);
    auto index = aneHelper.getUInt32(argv[1]);
    auto deadline = aneHelper.getUInt32(argv[2]);
    auto hash = getHashFromId(id);
    auto fh = findHandle(hash);
    if (fh.is_valid()) {
        if (fh.is_valid() && fh.status().has_metadata)
            fh.set_piece_deadline(index, deadline);
        return aneHelper.getFREObject(true);
    } else {
        return aneHelper.getFREObject(false);
    }
}

FRE_FUNCTION(resetPieceDeadline) {
    using namespace libtorrent;
    using namespace std;
    auto id = aneHelper.getString(argv[0]);
    auto index = aneHelper.getUInt32(argv[1]);
    auto hash = getHashFromId(id);
    auto fh = findHandle(hash);
    if (fh.is_valid()) {
        if (fh.is_valid() && fh.status().has_metadata)
            fh.reset_piece_deadline(index);
        return aneHelper.getFREObject(true);
    } else {
        return aneHelper.getFREObject(false);
    }
}

FRE_FUNCTION(setPiecePriority) {
    using namespace libtorrent;
    using namespace std;
    auto id = aneHelper.getString(argv[0]);
    auto index = aneHelper.getUInt32(argv[1]);
    auto priority = aneHelper.getUInt32(argv[2]);
    auto hash = getHashFromId(id);
    auto fh = findHandle(hash);
    if (fh.is_valid()) {
        if (fh.is_valid() && fh.status().has_metadata)
            fh.piece_priority(index, priority);
        return aneHelper.getFREObject(true);
    } else {
        return aneHelper.getFREObject(false);
    }
}

FRE_FUNCTION(setFilePriority) {
    using namespace libtorrent;
    using namespace std;
    auto id = aneHelper.getString(argv[0]);
    auto index = aneHelper.getUInt32(argv[1]);
    auto priority = aneHelper.getUInt32(argv[2]);
    auto hash = getHashFromId(id);
    auto fh = findHandle(hash);
    if (fh.is_valid()) {
        if (fh.is_valid() && fh.status().has_metadata)
            fh.file_priority(index, priority);
        return aneHelper.getFREObject(true);
    } else {
        return aneHelper.getFREObject(false);
    }
}

FRE_FUNCTION(forceDHTAnnounce) {
    using namespace libtorrent;
    using namespace std;
    auto id = aneHelper.getString(argv[0]);
    auto hash = getHashFromId(id);
    auto fh = findHandle(hash);
    if (fh.is_valid()) {
        fh.force_dht_announce();
        return aneHelper.getFREObject(true);
    } else {
        return aneHelper.getFREObject(false);
    }
}

FRE_FUNCTION(forceAnnounce) {
    using namespace libtorrent;
    using namespace std;
    auto id = aneHelper.getString(argv[0]);
    auto trackerIndex = aneHelper.getInt32(argv[1]);
    auto hash = getHashFromId(id);
    auto fh = findHandle(hash);
    if (fh.is_valid()) {
        fh.force_reannounce(0, trackerIndex);
        return aneHelper.getFREObject(true);
    } else {
        return aneHelper.getFREObject(false);
    }
}

FRE_FUNCTION(forceRecheck) {
    using namespace libtorrent;
    using namespace std;
    auto id = aneHelper.getString(argv[0]);
    auto hash = getHashFromId(id);
    auto fh = findHandle(hash);
    if (fh.is_valid()) {
        fh.save_resume_data();
        fh.force_recheck();
        return aneHelper.getFREObject(true);
    } else {
        return aneHelper.getFREObject(false);
    }
}

FRE_FUNCTION(pauseTorrent) {
    using namespace libtorrent;
    using namespace std;
    auto id = aneHelper.getString(argv[0]);
    auto hash = getHashFromId(id);
    auto fh = findHandle(hash);
    if (fh.is_valid()) {
        fh.auto_managed(false);
        fh.pause();
        if (fh.status().has_metadata && fh.status().need_save_resume)
            fh.save_resume_data();
        return aneHelper.getFREObject(true);
    } else {
        return aneHelper.getFREObject(false);
    }
}

FRE_FUNCTION(resumeTorrent) {
    using namespace libtorrent;
    using namespace std;
    auto id = aneHelper.getString(argv[0]);
    auto hash = getHashFromId(id);
    auto fh = findHandle(hash);
    if (fh.is_valid()) {
        fh.resume();
        fh.auto_managed(true);
        return aneHelper.getFREObject(true);
    } else {
        return aneHelper.getFREObject(false);
    }
}

FRE_FUNCTION(removeTorrent) {
    using namespace libtorrent;
    using namespace std;
    auto id = aneHelper.getString(argv[0]);
    addedTorrents.by<addedTorrentId>().erase(id);
    auto hash = getHashFromId(id);
    auto fh = findHandle(hash);
    if (fh.is_valid()) {
        ltsession->remove_torrent(fh);
        return aneHelper.getFREObject(true);
    } else {
        return aneHelper.getFREObject(false);
    }
}

FRE_FUNCTION(addTracker) {
    using namespace libtorrent;
    using namespace std;
    auto id = aneHelper.getString(argv[0]);
    auto hash = getHashFromId(id);
    auto url = aneHelper.getString(argv[1]);
    auto th = findHandle(hash);
    return aneHelper.getFREObject(th.is_valid());
}

FRE_FUNCTION(addUrlSeed) {
    using namespace libtorrent;
    using namespace std;
    auto id = aneHelper.getString(argv[0]);
    auto hash = getHashFromId(id);
    auto url = aneHelper.getString(argv[1]);
    auto th = findHandle(hash);
    if (th.is_valid()) {
        th.add_url_seed(url);
        return aneHelper.getFREObject(true);
    }
    return aneHelper.getFREObject(false);
}

FRE_FUNCTION(removeUrlSeed) {
    using namespace libtorrent;
    using namespace std;
    auto id = aneHelper.getString(argv[0]);
    auto hash = getHashFromId(id);
    auto url = aneHelper.getString(argv[1]);
    auto th = findHandle(hash);
    if (th.is_valid()) {
        th.remove_url_seed(url);
        return aneHelper.getFREObject(true);
    }
    return aneHelper.getFREObject(false);
}

FRE_FUNCTION(setQueuePosition) {
    using namespace libtorrent;
    using namespace std;
    auto id = aneHelper.getString(argv[0]);
    auto hash = getHashFromId(id);
    auto dir = aneHelper.getUInt32(argv[1]); //0 is up,1 is down, 2 is top, 3 is bottom
    auto th = findHandle(hash);

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
        return aneHelper.getFREObject(true);
    } else {
        return aneHelper.getFREObject(false);
    }
}

FRE_FUNCTION(setSequentialDownload) {
    using namespace libtorrent;
    using namespace std;
    uint32_t ASseq;
    auto isSeq = false;
    auto id = aneHelper.getString(argv[0]);
    auto hash = getHashFromId(id);
    FREGetObjectAsBool(argv[1], &ASseq);
    if (ASseq) isSeq = true;

    auto fh = findHandle(hash);
    if (fh.is_valid()) {
        fh.set_sequential_download(isSeq);
        if (!isSeq)
            fh.clear_piece_deadlines();
        return aneHelper.getFREObject(true);
    } else {
        return aneHelper.getFREObject(false);
    }
}

FRE_FUNCTION(addDHTRouter) {
#ifndef TORRENT_DISABLE_DHT
    dhtRouters.push_back(aneHelper.getString(argv[0]));
#endif
    return aneHelper.getFREObject(true);
}

FRE_FUNCTION(endSession) {
    using namespace libtorrent;
    using namespace std;
    vector<torrent_status> temp;

    ltsession->get_torrent_status(&temp, &yes, 0);
    vector<torrent_handle> oTorrentVector;
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

    return aneHelper.getFREObject(true);
}

FRE_FUNCTION(updateSettings) {
    FREObject settingsProps = argv[0];

    logLevel = aneHelper.getUInt32(aneHelper.getProperty(settingsProps, "logLevel"));

    std::stringstream ss;
    ss << aneHelper.getString(aneHelper.getProperty(settingsProps, "clientName")) << "/" << LIBTORRENT_VERSION
       << std::endl;
    clientName = ss.str();

    settingsContext.priorityFileTypes = aneHelper.getStringVector(aneHelper.getProperty(settingsProps, "prioritizedFileTypes"), "");
    settingsContext.queryFileProgress = aneHelper.getBool(aneHelper.getProperty(settingsProps, "queryFileProgress"));

    auto storageProps = aneHelper.getProperty(settingsProps, "storage");
    settingsContext.storage.outputPath = aneHelper.getString(aneHelper.getProperty(storageProps, "outputPath"));
    settingsContext.storage.torrentPath = aneHelper.getString(aneHelper.getProperty(storageProps, "torrentPath"));
    settingsContext.storage.resumePath = aneHelper.getString(aneHelper.getProperty(storageProps, "resumePath"));
    settingsContext.storage.geoipDataPath = aneHelper.getString(aneHelper.getProperty(storageProps, "geoipDataPath"));
    settingsContext.storage.sessionStatePath = aneHelper.getString(aneHelper.getProperty(storageProps, "sessionStatePath"));
    settingsContext.storage.sparse = aneHelper.getBool(aneHelper.getProperty(storageProps, "sparse"));
    settingsContext.storage.enabled = aneHelper.getBool(aneHelper.getProperty(storageProps, "enabled"));

    auto privacyProps = aneHelper.getProperty(settingsProps, "privacy");
    settingsContext.privacy.usePEX = aneHelper.getBool(aneHelper.getProperty(privacyProps, "usePEX"));
    settingsContext.privacy.useLSD = aneHelper.getBool(aneHelper.getProperty(privacyProps, "useLSD"));
    settingsContext.privacy.encryption = aneHelper.getUInt32(aneHelper.getProperty(privacyProps, "encryption"));
    settingsContext.privacy.useAnonymousMode = aneHelper.getBool(aneHelper.getProperty(privacyProps, "useAnonymousMode"));
#ifndef TORRENT_DISABLE_DHT
    settingsContext.privacy.useDHT = aneHelper.getBool(aneHelper.getProperty(privacyProps, "useDHT"));
#else
    settingsContext.useDHT = false;
#endif
    auto queueingProps = aneHelper.getProperty(settingsProps, "queueing");
    settingsContext.queueing.enabled = aneHelper.getBool(aneHelper.getProperty(queueingProps, "enabled"));
    settingsContext.queueing.ignoreSlow = aneHelper.getBool(aneHelper.getProperty(queueingProps, "ignoreSlow"));
    settingsContext.queueing.maxActiveDownloads = aneHelper.getUInt32(aneHelper.getProperty(queueingProps, "maxActiveDownloads"));
    settingsContext.queueing.maxActiveTorrents = aneHelper.getUInt32(aneHelper.getProperty(queueingProps, "maxActiveTorrents"));
    settingsContext.queueing.maxActiveUploads = aneHelper.getUInt32(aneHelper.getProperty(queueingProps, "maxActiveUploads"));
    auto speedProps = aneHelper.getProperty(settingsProps, "speed");
    settingsContext.speed.uploadRateLimit = aneHelper.getUInt32(aneHelper.getProperty(speedProps, "uploadRateLimit"));
    settingsContext.speed.downloadRateLimit = aneHelper.getUInt32(aneHelper.getProperty(speedProps, "downloadRateLimit"));
    settingsContext.speed.isuTPEnabled = aneHelper.getBool(aneHelper.getProperty(speedProps, "isuTPEnabled"));
    settingsContext.speed.isuTPRateLimited = aneHelper.getBool(aneHelper.getProperty(speedProps, "isuTPRateLimited"));
    settingsContext.speed.ignoreLimitsOnLAN = aneHelper.getBool(aneHelper.getProperty(speedProps, "ignoreLimitsOnLAN"));
    settingsContext.speed.rateLimitIpOverhead = aneHelper.getBool(aneHelper.getProperty(speedProps, "rateLimitIpOverhead"));

    //listening port
    auto listeningProps = aneHelper.getProperty(settingsProps, "listening");
    settingsContext.listening.useUPnP = aneHelper.getBool(aneHelper.getProperty(listeningProps, "useUPnP"));
    settingsContext.listening.randomPort = aneHelper.getBool(aneHelper.getProperty(listeningProps, "randomPort"));
    if (settingsContext.listening.randomPort) {
        boost::mt19937 gen;
        boost::uniform_int<> dist(6881, 6999);
        boost::variate_generator<boost::mt19937 &, boost::uniform_int<> > randRange(gen, dist);
        settingsContext.listening.port = (uint32_t) randRange();
    } else {
        settingsContext.listening.port = aneHelper.getUInt32(aneHelper.getProperty(listeningProps, "port"));
    }
    auto connectionsProps = aneHelper.getProperty(settingsProps, "connections");
    settingsContext.connections.maxNum = aneHelper.getUInt32(aneHelper.getProperty(connectionsProps, "maxNum"));
    settingsContext.connections.maxNumPerTorrent = aneHelper.getUInt32(aneHelper.getProperty(connectionsProps, "maxNumPerTorrent"));
    settingsContext.connections.maxUploads = aneHelper.getUInt32(aneHelper.getProperty(connectionsProps, "maxUploads"));
    settingsContext.connections.maxUploadsPerTorrent = aneHelper.getUInt32(aneHelper.getProperty(connectionsProps, "maxUploadsPerTorrent"));

    auto proxyProps = aneHelper.getProperty(settingsProps, "proxy");
    settingsContext.proxy.type = aneHelper.getUInt32(aneHelper.getProperty(proxyProps, "type"));
    settingsContext.proxy.port = aneHelper.getUInt32(aneHelper.getProperty(proxyProps, "port"));
    settingsContext.proxy.host = aneHelper.getString(aneHelper.getProperty(proxyProps, "host"));
    settingsContext.proxy.useForPeerConnections = aneHelper.getBool(aneHelper.getProperty(proxyProps, "useForPeerConnections"));
    settingsContext.proxy.force = aneHelper.getBool(aneHelper.getProperty(proxyProps, "force"));
    settingsContext.proxy.useAuth = aneHelper.getBool(aneHelper.getProperty(proxyProps, "useAuth"));
    settingsContext.proxy.username = aneHelper.getString(aneHelper.getProperty(proxyProps, "username"));
    settingsContext.proxy.password = aneHelper.getString(aneHelper.getProperty(proxyProps, "password"));

    auto advancedProps = aneHelper.getProperty(settingsProps, "advanced");
    settingsContext.advanced.diskCacheSize = aneHelper.getInt32(aneHelper.getProperty(advancedProps, "diskCacheSize"));
    settingsContext.advanced.diskCacheTTL = aneHelper.getUInt32(aneHelper.getProperty(advancedProps, "diskCacheTTL"));
    settingsContext.advanced.enableOsCache = aneHelper.getBool(aneHelper.getProperty(advancedProps, "enableOsCache"));
    settingsContext.advanced.outgoingPortsMin = aneHelper.getInt32(aneHelper.getProperty(advancedProps, "outgoingPortsMin"));
    settingsContext.advanced.outgoingPortsMax = aneHelper.getInt32(aneHelper.getProperty(advancedProps, "outgoingPortsMax"));
    settingsContext.advanced.recheckTorrentsOnCompletion = aneHelper.getBool(aneHelper.getProperty(advancedProps, "recheckTorrentsOnCompletion"));
    settingsContext.advanced.resolveCountries = aneHelper.getBool(aneHelper.getProperty(advancedProps, "resolveCountries"));
    settingsContext.advanced.isSuperSeedingEnabled = aneHelper.getBool(aneHelper.getProperty(advancedProps, "isSuperSeedingEnabled"));
    settingsContext.advanced.numMaxHalfOpenConnections = aneHelper.getUInt32(aneHelper.getProperty(advancedProps, "numMaxHalfOpenConnections"));
    settingsContext.advanced.announceToAllTrackers = aneHelper.getBool(aneHelper.getProperty(advancedProps, "announceToAllTrackers"));
    settingsContext.advanced.enableTrackerExchange = aneHelper.getBool(aneHelper.getProperty(advancedProps, "enableTrackerExchange"));
    settingsContext.advanced.resolvePeerHostNames = aneHelper.getBool(aneHelper.getProperty(advancedProps, "resolvePeerHostNames"));
    settingsContext.advanced.listenOnIPv6 = aneHelper.getBool(aneHelper.getProperty(advancedProps, "listenOnIPv6"));
    settingsContext.advanced.announceIP = aneHelper.getString(aneHelper.getProperty(advancedProps, "announceIP"));
    auto networkInterface = aneHelper.getProperty(advancedProps, "networkInterface");
    auto networkAddresses = aneHelper.getProperty(networkInterface, "addresses");
    auto numAddresses = aneHelper.getArrayLength(networkAddresses);

    for (unsigned int j = 0; j < numAddresses; ++j) {
        FREObject elemAS = nullptr;
        FREGetArrayElementAt(networkAddresses, j, &elemAS);
        settingsContext.advanced.networkInterface.push_back(make_pair(aneHelper.getString(aneHelper.getProperty(elemAS, "address")), aneHelper.getString(aneHelper.getProperty(elemAS, "ipVersion"))));
    }

    if (ltsession && ltsession->is_listening())
        ltsession->apply_settings(getDefaultSessionSettings(dhtRouters));

    return aneHelper.getFREObject(true);
}
bool fileFilter(std::string const &f) {
    using namespace libtorrent;
    return filename(f)[0] != '.';
}
void printCreationProgress(int i, int num) {
    using json = nlohmann::json;
    json j;
    j["progress"] = static_cast<int>(i * 100. / static_cast<float>(num));
    aneHelper.dispatchEvent(dllContext, torrentInfoEvent.TORRENT_CREATION_PROGRESS, j.dump());
}
void threadCreateTorrent(int p) {
    using namespace libtorrent;
    boost::mutex mutex;
    using boost::this_thread::get_id;
    mutex.lock();

    auto padFileLimit = -1;
    uint32_t flags = 0;

    file_storage fs;
    auto fullPath = complete(createTorrentContext.inputFile);
    add_files(fs, fullPath, fileFilter, flags);

    create_torrent t(fs, createTorrentContext.pieceSize, padFileLimit, flags);
    auto tier = 0;
    for (auto i = createTorrentContext.trackers.begin(), end(createTorrentContext.trackers.end()); i != end; ++i, ++tier)
        t.add_tracker(*i, tier);
    for (auto i = createTorrentContext.webSeeds.begin(), end(createTorrentContext.webSeeds.end()); i != end; ++i)
        t.add_url_seed(*i);

    boost::system::error_code ec;
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
    bencode(back_inserter(torrent), t.generate());
    saveFile(createTorrentContext.outputFile, torrent);

    using json = nlohmann::json;
    json j;
    j["fileName"] = createTorrentContext.outputFile;
    j["seedNow"] = createTorrentContext.seedNow;
    aneHelper.dispatchEvent(dllContext, torrentInfoEvent.TORRENT_CREATED, j.dump());
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
        while (getline(file, line)) {
            if (starts_with(line, "#") || starts_with(line, "//") || line.empty()) continue;
            vector<std::string> partsList;
            vector<std::string> IPList;

            split(partsList, line, is_any_of(":"));
            if (partsList.size() < 2) continue;

            split(IPList, partsList.at(partsList.size() - 1), is_any_of("-"));
            if (IPList.size() != 2) continue;

            ipRangeFromStr = IPList.at(0);
            trim(ipRangeFromStr);

            if (ipRangeFromStr.empty()) continue;

            boost::system::error_code ec;

            address ipRangeFrom = ipRangeFrom.from_string(ipRangeFromStr, ec);
            if (ec) continue;

            ipRangeToStr = IPList.at(1);
            trim(ipRangeToStr);

            if (ipRangeToStr.empty()) continue;

            address ipRangeTo = ipRangeTo.from_string(ipRangeToStr, ec);
            if (ec) continue;
            try {
                ipFilterList.add_rule(ipRangeFrom, ipRangeTo, ip_filter::blocked);
                numFilters++;
            }
            catch (exception &) {
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
    aneHelper.dispatchEvent(dllContext, torrentInfoEvent.FILTER_LIST_ADDED, j.dump());
    mutex.unlock();
}

FRE_FUNCTION(createTorrent) {
    createTorrentContext.inputFile = aneHelper.getString(argv[0]);
    createTorrentContext.outputFile = aneHelper.getString(argv[1]);
    createTorrentContext.trackers = aneHelper.getStringVector(argv[2], "uri");
    createTorrentContext.webSeeds = aneHelper.getStringVector(argv[3], "uri");
    createTorrentContext.pieceSize = aneHelper.getUInt32(argv[4]) * 1024;
    createTorrentContext.isPrivate = aneHelper.getBool(argv[5]);
    createTorrentContext.comment = aneHelper.getString(argv[6]);
    createTorrentContext.creator = clientName;
    createTorrentContext.seedNow = aneHelper.getBool(argv[7]);
    createTorrentContext.rootCert = aneHelper.getString(argv[8]);
    threads[0] = move(createThread(&threadCreateTorrent, 1));
    return aneHelper.getFREObject(true);
}

FRE_FUNCTION(saveSessionState) {
    using namespace std;
    using namespace libtorrent;
    entry session_state;
    ltsession->save_state(session_state);
    vector<char> out;
    bencode(back_inserter(out), session_state);
    saveFile(settingsContext.storage.sessionStatePath + pathSlash + ".ses_state", out);
    return aneHelper.getFREObject(true);
}

FRE_FUNCTION(addFilterList) {
    settingsContext.filters.filename = aneHelper.getString(argv[0]);
    settingsContext.filters.applyToTrackers = aneHelper.getBool(argv[1]);
    threads[0] = move(createThread(&threadAddFilterList, 1));
    return aneHelper.getFREObject(true);
}

FRE_FUNCTION(isSupported) {
    return aneHelper.getFREObject(isSupportedInOS);
}

void contextInitializer(void *extData, const uint8_t *ctxType, FREContext ctx, uint32_t *numFunctionsToSet, const FRENamedFunction **functionsToSet) {
    static FRENamedFunction extensionFunctions[] = {
            {reinterpret_cast<const uint8_t *>("isSupported"), nullptr, &isSupported}, {reinterpret_cast<const uint8_t *>("removeTorrent"), nullptr, &removeTorrent}, {reinterpret_cast<const uint8_t *>("addTorrent"), nullptr, &addTorrent}, {reinterpret_cast<const uint8_t *>("initSession"), nullptr, &initSession}, {reinterpret_cast<const uint8_t *>("endSession"), nullptr, &endSession}, {reinterpret_cast<const uint8_t *>("getTorrentInfo"), nullptr, &getTorrentInfo}, {reinterpret_cast<const uint8_t *>("postTorrentUpdates"), nullptr, &postTorrentUpdates}, {reinterpret_cast<const uint8_t *>("getTorrentPeers"), nullptr, &getTorrentPeers}, {reinterpret_cast<const uint8_t *>("getTorrentTrackers"), nullptr, &getTorrentTrackers}, {reinterpret_cast<const uint8_t *>("pauseTorrent"), nullptr, &pauseTorrent}, {reinterpret_cast<const uint8_t *>("resumeTorrent"), nullptr, &resumeTorrent}, {reinterpret_cast<const uint8_t *>("updateSettings"), nullptr, &updateSettings}, {reinterpret_cast<const uint8_t *>("setSequentialDownload"), nullptr, &setSequentialDownload}, {reinterpret_cast<const uint8_t *>("addDHTRouter"), nullptr, &addDHTRouter}, {reinterpret_cast<const uint8_t *>("setQueuePosition"), nullptr, &setQueuePosition}, {reinterpret_cast<const uint8_t *>("addFilterList"), nullptr, &addFilterList}, {reinterpret_cast<const uint8_t *>("createTorrent"), nullptr, &createTorrent}, {reinterpret_cast<const uint8_t *>("saveSessionState"), nullptr, &saveSessionState}, {reinterpret_cast<const uint8_t *>("getMagnetURI"), nullptr, &getMagnetURI}, {reinterpret_cast<const uint8_t *>("setFilePriority"), nullptr, &setFilePriority}, {reinterpret_cast<const uint8_t *>("forceRecheck"), nullptr, &forceRecheck}, {reinterpret_cast<const uint8_t *>("forceAnnounce"), nullptr, &forceAnnounce}, {reinterpret_cast<const uint8_t *>("forceDHTAnnounce"), nullptr, &forceDHTAnnounce}, {reinterpret_cast<const uint8_t *>("setPiecePriority"), nullptr, &setPiecePriority}, {reinterpret_cast<const uint8_t *>("setPieceDeadline"), nullptr, &setPieceDeadline}, {reinterpret_cast<const uint8_t *>("resetPieceDeadline"), nullptr, &resetPieceDeadline}, {reinterpret_cast<const uint8_t *>("addTracker"), nullptr, &addTracker}, {reinterpret_cast<const uint8_t *>("addUrlSeed"), nullptr, &addUrlSeed}, {reinterpret_cast<const uint8_t *>("removeUrlSeed"), nullptr, &removeUrlSeed}
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
}

void TRLTAExtInizer(void **extData, FREContextInitializer *ctxInitializer, FREContextFinalizer *ctxFinalizer) {
    *ctxInitializer = &contextInitializer;
    *ctxFinalizer = &contextFinalizer;
}

void TRLTAExtFinizer(void *extData) {
    FREContext nullCTX;
    nullCTX = nullptr;
    contextFinalizer(nullCTX);
}

}
