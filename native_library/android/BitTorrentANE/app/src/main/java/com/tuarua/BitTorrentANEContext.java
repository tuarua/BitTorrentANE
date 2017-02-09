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
package com.tuarua;

import android.net.Uri;
import android.os.Environment;
import android.os.Handler;
import android.os.HandlerThread;
import android.util.Log;

import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FREReadOnlyException;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;
import com.frostwire.jlibtorrent.AddTorrentParams;
import com.frostwire.jlibtorrent.Address;
import com.frostwire.jlibtorrent.AlertListener;
import com.frostwire.jlibtorrent.AnnounceEntry;
import com.frostwire.jlibtorrent.Bitfield;
import com.frostwire.jlibtorrent.Dht;
import com.frostwire.jlibtorrent.Entry;
import com.frostwire.jlibtorrent.ErrorCode;
import com.frostwire.jlibtorrent.FileStorage;
import com.frostwire.jlibtorrent.LibTorrent;
import com.frostwire.jlibtorrent.PartialPieceInfo;
import com.frostwire.jlibtorrent.PeerInfo;
import com.frostwire.jlibtorrent.Priority;
import com.frostwire.jlibtorrent.Session;
import com.frostwire.jlibtorrent.SettingsPack;
import com.frostwire.jlibtorrent.Sha1Hash;
import com.frostwire.jlibtorrent.StorageMode;
import com.frostwire.jlibtorrent.TcpEndpoint;
import com.frostwire.jlibtorrent.TorrentHandle;
import com.frostwire.jlibtorrent.TorrentInfo;
import com.frostwire.jlibtorrent.TorrentStatus;
import com.frostwire.jlibtorrent.WebSeedEntry;
import com.frostwire.jlibtorrent.alerts.Alert;
import com.frostwire.jlibtorrent.alerts.AlertType;
import com.frostwire.jlibtorrent.alerts.FileCompletedAlert;
import com.frostwire.jlibtorrent.alerts.ListenFailedAlert;
import com.frostwire.jlibtorrent.alerts.ListenSucceededAlert;
import com.frostwire.jlibtorrent.alerts.MetadataReceivedAlert;
import com.frostwire.jlibtorrent.alerts.PeerAlert;
import com.frostwire.jlibtorrent.alerts.PieceFinishedAlert;
import com.frostwire.jlibtorrent.alerts.SaveResumeDataAlert;
import com.frostwire.jlibtorrent.alerts.StateChangedAlert;
import com.frostwire.jlibtorrent.alerts.StateUpdateAlert;
import com.frostwire.jlibtorrent.alerts.TorrentAddedAlert;
import com.frostwire.jlibtorrent.alerts.TorrentCheckedAlert;
import com.frostwire.jlibtorrent.alerts.TorrentFinishedAlert;
import com.frostwire.jlibtorrent.alerts.TorrentPausedAlert;
import com.frostwire.jlibtorrent.alerts.TorrentResumedAlert;
import com.frostwire.jlibtorrent.alerts.TrackerReplyAlert;
import com.frostwire.jlibtorrent.swig.bitfield;
import com.frostwire.jlibtorrent.swig.dht_settings;
import com.frostwire.jlibtorrent.swig.error_code;
import com.frostwire.jlibtorrent.swig.ip_filter;
import com.frostwire.jlibtorrent.swig.libtorrent;
import com.frostwire.jlibtorrent.swig.peer_info;
import com.frostwire.jlibtorrent.swig.settings_pack;
import com.frostwire.jlibtorrent.swig.add_torrent_params;
import com.frostwire.jlibtorrent.swig.storage_mode_t;
import com.frostwire.jlibtorrent.swig.torrent_handle;
import com.maxmind.db.CHMCache;
import com.maxmind.geoip2.DatabaseReader;
import com.maxmind.geoip2.exception.GeoIp2Exception;
import com.tuarua.jtorrent.TorrentSettings;
import com.tuarua.jtorrent.constants.Encryption;
import com.tuarua.jtorrent.constants.FRETorrentEvent;
import com.tuarua.jtorrent.constants.LogLevel;
import com.tuarua.jtorrent.constants.ProxyType;
import com.tuarua.jtorrent.constants.FRETorrentAlert;
import com.tuarua.jtorrent.constants.QueuePosition;
import com.tuarua.jtorrent.listeners.MetadataReceivedAlertListener;
import com.tuarua.jtorrent.listeners.StateUpdateAlertListener;
import com.tuarua.utils.ANEhelper;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.net.InetAddress;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.ListIterator;
import java.util.Map;
import java.util.Random;
import java.util.concurrent.CountDownLatch;

public class BitTorrentANEContext extends FREContext {
    private int logLevel = LogLevel.QUIET;
    private ANEhelper aneHelper = ANEhelper.getInstance();
    private HandlerThread libTorrentThread;
    private Handler libTorrentHandler;
    private Session ltsession;
    private Dht dht;
    private ArrayList<String> dhtRouters = new ArrayList<String>();
    private Boolean initialising = false, initialised = false;

    private DatabaseReader geoDBreader;

    private CountDownLatch initialisingLatch;
    private static final String LIBTORRENT_THREAD_NAME = "BITTORRENTANE_LIBTORRENT";
    private String clientName;

    private Map<String, Sha1Hash> addedTorrentsIdMap = new HashMap<>();
    private Map<String, String> addedTorrentsHashMap = new HashMap<>();
    private Map<String, Map<String, Integer>> torrentTrackerPeerMap = new HashMap<>();

    private Map<Long, String> addedMagnetsIdMap = new HashMap<>();
    private Map<Long, String> addedMagnetsUriMap = new HashMap<>();
    private Map<Long, Boolean> addedMagnetsSequentialMap = new HashMap<>();
    private final long statusFlags = torrent_handle.status_flags_t.query_accurate_download_counters.swigValue()
            | torrent_handle.status_flags_t.query_distributed_copies.swigValue()
            | torrent_handle.status_flags_t.query_pieces.swigValue()
            | torrent_handle.status_flags_t.query_save_path.swigValue();

    private final InnerListener innerListener;

    private static final int[] INNER_LISTENER_TYPES = new int[]{
            AlertType.PEER.swig(),
            AlertType.TORRENT_CHECKED.swig(),
            AlertType.SAVE_RESUME_DATA.swig(),
            AlertType.SAVE_RESUME_DATA_FAILED.swig(),
            AlertType.FASTRESUME_REJECTED.swig(),
            AlertType.PIECE_FINISHED.swig(),
            AlertType.TRACKER_REPLY.swig(),
            AlertType.LISTEN_SUCCEEDED.swig(),
            AlertType.LISTEN_FAILED.swig(),
            AlertType.STATE_CHANGED.swig(),
            AlertType.FILE_COMPLETED.swig(),
            AlertType.TORRENT_ADDED.swig(),
            AlertType.TORRENT_PAUSED.swig(),
            AlertType.TORRENT_FINISHED.swig(),
            AlertType.PEER_ERROR.swig(),
            AlertType.TORRENT_ERROR.swig(),
            AlertType.PORTMAP_ERROR.swig(),
            AlertType.TORRENT_RESUMED.swig()
    };

    public BitTorrentANEContext() {
        this.innerListener = new InnerListener();
    }


    @Override
    public Map<String, FREFunction> getFunctions() {
        Map<String, FREFunction> functionsToSet = new HashMap<String, FREFunction>();
        functionsToSet.put("isSupported", new isSupported());
        functionsToSet.put("initSession", new initSession());
        functionsToSet.put("endSession", new endSession());
        functionsToSet.put("updateSettings", new updateSettings());
        functionsToSet.put("addDHTRouter", new addDHTRouter());
        functionsToSet.put("addTorrent", new addTorrent());

        functionsToSet.put("pauseTorrent", new pauseTorrent());
        functionsToSet.put("resumeTorrent", new resumeTorrent());
        functionsToSet.put("removeTorrent", new removeTorrent());
        functionsToSet.put("postTorrentUpdates", new postTorrentUpdates());
        functionsToSet.put("getTorrentTrackers", new getTorrentTrackers());
        functionsToSet.put("setSequentialDownload", new setSequentialDownload());
        functionsToSet.put("setPieceDeadline", new setPieceDeadline());
        functionsToSet.put("resetPieceDeadline", new resetPieceDeadline());
        functionsToSet.put("setPiecePriority", new setPiecePriority());
        functionsToSet.put("setFilePriority", new setFilePriority());
        functionsToSet.put("addTracker", new addTracker());
        functionsToSet.put("addUrlSeed", new addUrlSeed());
        functionsToSet.put("removeUrlSeed", new removeUrlSeed());
        functionsToSet.put("setQueuePosition", new setQueuePosition());
        functionsToSet.put("addFilterList", new addFilterList());
        functionsToSet.put("getTorrentInfo", new getTorrentInfo());
        functionsToSet.put("getMagnetURI", new getMagnetURI());
        functionsToSet.put("forceRecheck", new forceRecheck());
        functionsToSet.put("forceAnnounce", new forceAnnounce());
        functionsToSet.put("forceDHTAnnounce", new forceDHTAnnounce());
        functionsToSet.put("getTorrentPeers", new getTorrentPeers());
        functionsToSet.put("saveSessionState", new saveSessionState());

        return functionsToSet;
    }

    @Override
    public void dispose() {

    }

    private final class InnerListener implements AlertListener {

        @Override
        public int[] types() {
            return INNER_LISTENER_TYPES;
        }

        @Override
        public void alert(Alert<?> alert) {
            AlertType type = alert.type();
            TorrentHandle th;
            TorrentInfo ti;
            Sha1Hash infoHash;
            String id;

            if (logLevel == LogLevel.DEBUG) {
                trace(alert.message());
                trace(alert.what());
            }

            JSONObject jsonObject;
            switch (type) {

                case PEER_ERROR:
                    break;
                case FASTRESUME_REJECTED:
                    break;
                case STATE_CHANGED:
                    th = ((StateChangedAlert) alert).handle();
                    if (th.isValid()) {
                        TorrentStatus.State state = ((StateChangedAlert) alert).getState();
                        TorrentStatus status = th.getStatus();
                        infoHash = th.getInfoHash();
                        id = addedTorrentsHashMap.get(infoHash.toString());
                        jsonObject = new JSONObject();
                        try {
                            jsonObject.put("id", id);

                            if (status.isPaused())
                                jsonObject.put("state", status.isAutoManaged() ? 8 : 9);
                            else
                                jsonObject.put("state", state.getSwig());

                        } catch (JSONException e) {
                            trace(e.getMessage());
                            e.printStackTrace();
                        }
                        dispatchStatusEventAsync(jsonObject.toString(), FRETorrentAlert.STATE_CHANGED);
                    }
                    break;
                case TORRENT_ADDED:
                    th = ((TorrentAddedAlert) alert).handle();
                    if (th != null && th.isValid()) {
                        infoHash = th.getInfoHash();
                        id = addedTorrentsHashMap.get(infoHash.toString());
                        ti = th.getTorrentInfo();
                        if (ti != null) {
                            jsonObject = new JSONObject();
                            if (TorrentSettings.priorityFileTypes.size() > 0) prioritizeFileTypes(th, ti);
                            try {
                                jsonObject.put("id", id);
                                jsonObject.put("hash", infoHash.toString());
                            } catch (JSONException e) {
                                trace(e.getMessage());
                                e.printStackTrace();
                            }
                            ltsession.removeListener(stateUpdateAlertListener);
                            ltsession.addListener(stateUpdateAlertListener);
                            dispatchStatusEventAsync(jsonObject.toString(), FRETorrentAlert.TORRENT_ADDED);
                        }
                    }

                    break;
                case SAVE_RESUME_DATA:
                    th = ((SaveResumeDataAlert) alert).handle();
                    if (th.isValid()) {
                        infoHash = th.getInfoHash();
                        id = addedTorrentsHashMap.get(infoHash.toString());
                        ti = th.getTorrentInfo();
                        jsonObject = new JSONObject();
                        try {
                            FileOutputStream fileOutputStream = new FileOutputStream(TorrentSettings.storage.resumePath + "/" + id + ".resume");
                            fileOutputStream.write(ti.bencode());
                            fileOutputStream.close();
                            try {
                                jsonObject.put("id", addedTorrentsHashMap.get(infoHash.toString()));
                                dispatchStatusEventAsync(jsonObject.toString(), FRETorrentAlert.SAVE_RESUME_DATA);
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }

                        } catch (IOException e) {
                            trace(e.getMessage());
                            e.printStackTrace();
                        }
                    }
                    break;
                case TORRENT_FINISHED:
                    th = ((TorrentFinishedAlert) alert).handle();
                    if (th.isValid()) {
                        infoHash = th.getInfoHash();
                        if (TorrentSettings.advanced.recheckTorrentsOnCompletion)
                            th.forceRecheck();
                        th.saveResumeData();
                        jsonObject = new JSONObject();
                        try {
                            jsonObject.put("id", addedTorrentsHashMap.get(infoHash.toString()));
                        } catch (JSONException e) {
                            trace(e.getMessage());
                            e.printStackTrace();
                        }
                        dispatchStatusEventAsync(jsonObject.toString(), FRETorrentAlert.TORRENT_FINISHED);
                    }
                    break;
                case PIECE_FINISHED:
                    jsonObject = new JSONObject();
                    th = ((PieceFinishedAlert) alert).handle();
                    if (th.isValid()) {
                        infoHash = th.getInfoHash();
                        id = addedTorrentsHashMap.get(infoHash.toString());
                        try {
                            jsonObject.put("id", addedTorrentsHashMap.get(id));
                            jsonObject.put("index", ((PieceFinishedAlert) alert).pieceIndex());
                        } catch (JSONException e) {
                            trace(e.getMessage());
                            e.printStackTrace();
                        }
                        dispatchStatusEventAsync(jsonObject.toString(), FRETorrentAlert.PIECE_FINISHED);
                    }
                    break;
                case FILE_COMPLETED:
                    jsonObject = new JSONObject();
                    th = ((FileCompletedAlert) alert).handle();
                    if (th.isValid()) {
                        try {
                            infoHash = th.getInfoHash();
                            id = addedTorrentsHashMap.get(infoHash.toString());
                            jsonObject.put("id", addedTorrentsHashMap.get(id));
                            jsonObject.put("index", ((FileCompletedAlert) alert).getIndex());
                            dispatchStatusEventAsync(jsonObject.toString(), FRETorrentAlert.FILE_COMPLETED);
                        } catch (JSONException e) {
                            trace(e.getMessage());
                            e.printStackTrace();
                        }
                    }
                    break;
                case TORRENT_PAUSED:
                    jsonObject = new JSONObject();
                    th = ((TorrentPausedAlert) alert).handle();
                    if (th.isValid()) {
                        infoHash = th.getInfoHash();
                        id = addedTorrentsHashMap.get(infoHash.toString());
                        TorrentStatus status = th.getStatus();
                        try {
                            jsonObject.put("id", id);
                            jsonObject.put("state", status.isAutoManaged() ? 8 : 9);
                        } catch (JSONException e) {
                            trace(e.getMessage());
                            e.printStackTrace();
                        }
                        dispatchStatusEventAsync(jsonObject.toString(), FRETorrentAlert.TORRENT_PAUSED);
                    }
                    break;
                case TORRENT_RESUMED:
                    jsonObject = new JSONObject();
                    th = ((TorrentResumedAlert) alert).handle();
                    if (th.isValid()) {
                        infoHash = th.getInfoHash();
                        id = addedTorrentsHashMap.get(infoHash.toString());
                        TorrentStatus status = th.getStatus();
                        try {
                            jsonObject.put("id", id);
                            jsonObject.put("state", status.getState().getSwig());
                        } catch (JSONException e) {
                            trace(e.getMessage());
                            e.printStackTrace();
                        }
                        dispatchStatusEventAsync(jsonObject.toString(), FRETorrentAlert.TORRENT_RESUMED);
                    }
                    break;
                case TORRENT_CHECKED:
                    jsonObject = new JSONObject();
                    th = ((TorrentCheckedAlert) alert).handle();
                    if (th.isValid()) {
                        infoHash = th.getInfoHash();
                        id = addedTorrentsHashMap.get(infoHash.toString());

                        ti = th.getTorrentInfo();
                        ArrayList<AnnounceEntry> trackers = ti.trackers();

                        AnnounceEntry an;
                        for (ListIterator<AnnounceEntry> iter = trackers.listIterator(); iter.hasNext(); ) {
                            an = iter.next();
                            Map<String, Integer> torrent = torrentTrackerPeerMap.get(id);
                            Map<String, Integer> trackerMap = new HashMap<>();
                            trackerMap.put(an.url(), 0);
                            if (torrent == null)
                                torrentTrackerPeerMap.put(id, trackerMap);
                            else
                                torrent.putAll(trackerMap);
                        }
                        //this forces the torrent to start
                        if (th.getStatus().isPaused() && !th.getStatus().isAutoManaged())
                            th.resume();

                        try {
                            jsonObject.put("id", id);
                            dispatchStatusEventAsync(jsonObject.toString(), FRETorrentAlert.TORRENT_CHECKED);
                        } catch (JSONException e) {
                            trace(e.getMessage());
                            e.printStackTrace();
                        }
                    }
                    break;
                case TRACKER_REPLY:
                    th = ((TrackerReplyAlert) alert).handle();
                    infoHash = th.getInfoHash();
                    id = addedTorrentsHashMap.get(infoHash.toString());
                    if (th != null && th.isValid()) {
                        ti = th.getTorrentInfo();
                        if (ti.isValid()) {
                            Map<String, Integer> resp = torrentTrackerPeerMap.get(id);
                            resp.put(((TrackerReplyAlert) alert).trackerUrl(), ((TrackerReplyAlert) alert).getNumPeers());
                        }
                    }
                    break;
                case LISTEN_SUCCEEDED:
                    TcpEndpoint endp = ((ListenSucceededAlert) alert).getEndpoint();
                    if (((ListenSucceededAlert) alert).getSocketType() == ListenSucceededAlert.SocketType.TCP) {
                        String address = endp.address().toString();
                        int port = endp.port();
                        jsonObject = new JSONObject();
                        try {
                            jsonObject.put("address", address);
                            jsonObject.put("port", port);
                            jsonObject.put("type", ((ListenSucceededAlert) alert).getSocketType());
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                        ltsession.postDHTStats();
                        dispatchStatusEventAsync(jsonObject.toString(), FRETorrentAlert.LISTEN_SUCCEEDED);
                    }
                    break;
                case LISTEN_FAILED:
                    TcpEndpoint endp2 = ((ListenFailedAlert) alert).endpoint();
                    String address2 = endp2.address().toString();
                    int port2 = endp2.port();
                    String message = ((ListenFailedAlert) alert).getError().message();
                    jsonObject = new JSONObject();
                    try {
                        jsonObject.put("address", address2);
                        jsonObject.put("port", port2);
                        jsonObject.put("type", ((ListenSucceededAlert) alert).getSocketType());
                        jsonObject.put("message", message);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    dispatchStatusEventAsync(jsonObject.toString(), FRETorrentAlert.LISTEN_FAILED);
                    break;
            }

        }
    }

    private SettingsPack getDefaultSessionSettings() {
        SettingsPack settings = new SettingsPack();

        //optimize cpu for android
        int maxQueuedDiskBytes = settings.maxQueuedDiskBytes();
        settings.setMaxQueuedDiskBytes(maxQueuedDiskBytes / 2);
        int sendBufferWatermark = settings.sendBufferWatermark();
        settings.setSendBufferWatermark(sendBufferWatermark / 2);
        settings.setTickInterval(1000);
        settings.setInactivityTimeout(60);
        settings.setSeedingOutgoingConnections(false);
        settings.setGuidedReadCache(true);

        settings.setString(settings_pack.string_types.user_agent.swigValue(), clientName);
        settings.setBoolean(settings_pack.bool_types.apply_ip_filter_to_trackers.swigValue(),
                (!TorrentSettings.filters.filename.isEmpty() && TorrentSettings.filters.applyToTrackers));
        settings.setBoolean(settings_pack.bool_types.upnp_ignore_nonrouters.swigValue(), true);
        settings.setInteger(settings_pack.int_types.ssl_listen.swigValue(), 0);
        settings.setBoolean(settings_pack.bool_types.lazy_bitfields.swigValue(), true);

        settings.setInteger(settings_pack.int_types.stop_tracker_timeout.swigValue(), 1);
        settings.setInteger(settings_pack.int_types.auto_scrape_interval.swigValue(), 1200);
        settings.setInteger(settings_pack.int_types.auto_scrape_min_interval.swigValue(), 900);

        settings.setBoolean(settings_pack.bool_types.announce_to_all_trackers.swigValue(),
                TorrentSettings.advanced.announceToAllTrackers);
        settings.setBoolean(settings_pack.bool_types.announce_to_all_tiers.swigValue(),
                TorrentSettings.advanced.announceToAllTrackers);

        int cacheSize = TorrentSettings.advanced.diskCacheSize;
        if (cacheSize > 0)
            cacheSize = cacheSize * 64;  //0 is off, -1 is 1/8 of machine's RAM
        settings.setInteger(settings_pack.int_types.cache_size.swigValue(), cacheSize);
        settings.setInteger(settings_pack.int_types.cache_expiry.swigValue(), TorrentSettings.advanced.diskCacheTTL);
        settings_pack.io_buffer_mode_t mode = TorrentSettings.advanced.enableOsCache ? settings_pack.io_buffer_mode_t.enable_os_cache : settings_pack.io_buffer_mode_t.disable_os_cache;

        settings.setInteger(settings_pack.int_types.disk_io_read_mode.swigValue(), mode.swigValue());
        settings.setInteger(settings_pack.int_types.disk_io_write_mode.swigValue(), mode.swigValue());

        settings.setAnonymousMode(TorrentSettings.privacy.useAnonymousMode);
        settings.setBoolean(settings_pack.bool_types.lock_files.swigValue(), false);

        if (TorrentSettings.queueing.enabled) {
            settings.setInteger(settings_pack.int_types.active_downloads.swigValue(),
                    TorrentSettings.queueing.maxActiveDownloads);
            settings.setInteger(settings_pack.int_types.active_limit.swigValue(),
                    TorrentSettings.queueing.maxActiveTorrents);
            settings.setInteger(settings_pack.int_types.active_seeds.swigValue(),
                    TorrentSettings.queueing.maxActiveUploads);
            settings.setBoolean(settings_pack.bool_types.dont_count_slow_torrents.swigValue(),
                    TorrentSettings.queueing.ignoreSlow);
        } else {
            settings.setInteger(settings_pack.int_types.active_downloads.swigValue(), -1);
            settings.setInteger(settings_pack.int_types.active_limit.swigValue(), -1);
            settings.setInteger(settings_pack.int_types.active_seeds.swigValue(), -1);
        }


        settings.setInteger(settings_pack.int_types.active_tracker_limit.swigValue(), -1);
        settings.setInteger(settings_pack.int_types.active_dht_limit.swigValue(), -1);
        settings.setInteger(settings_pack.int_types.active_lsd_limit.swigValue(), -1);

        if (TorrentSettings.advanced.outgoingPortsMin > 0 && TorrentSettings.advanced.outgoingPortsMax > 0 && TorrentSettings.advanced.outgoingPortsMin < TorrentSettings.advanced.outgoingPortsMax)
            settings.setInteger(settings_pack.int_types.outgoing_port.swigValue(), randomInteger(TorrentSettings.advanced.outgoingPortsMin, TorrentSettings.advanced.outgoingPortsMax));

        settings.setBoolean(settings_pack.bool_types.rate_limit_ip_overhead.swigValue(), TorrentSettings.speed.rateLimitIpOverhead);

        if (!TorrentSettings.advanced.announceIP.isEmpty())
            settings.setString(settings_pack.string_types.announce_ip.swigValue(), TorrentSettings.advanced.announceIP);

        settings.setBoolean(settings_pack.bool_types.strict_super_seeding.swigValue(), TorrentSettings.advanced.isSuperSeedingEnabled);

        settings.setInteger(settings_pack.int_types.connections_limit.swigValue(), TorrentSettings.connections.maxNum);
        settings.setInteger(settings_pack.int_types.unchoke_slots_limit.swigValue(), TorrentSettings.connections.maxUploads);

        settings.setBoolean(settings_pack.bool_types.enable_incoming_utp.swigValue(), TorrentSettings.speed.isuTPEnabled);
        settings.setBoolean(settings_pack.bool_types.enable_outgoing_utp.swigValue(), TorrentSettings.speed.isuTPEnabled);

        if (TorrentSettings.speed.isuTPRateLimited)
            settings.setInteger(settings_pack.int_types.mixed_mode_algorithm.swigValue(), 0);//settings_pack::prefer_tcp
        else
            settings.setInteger(settings_pack.int_types.mixed_mode_algorithm.swigValue(), 1);//settings_pack::peer_proportional

        settings.setInteger(settings_pack.int_types.connection_speed.swigValue(), 20);
        settings.setBoolean(settings_pack.bool_types.no_connect_privileged_ports.swigValue(), false);

        settings.setInteger(settings_pack.int_types.seed_choking_algorithm.swigValue(), settings_pack.seed_choking_algorithm_t.fastest_upload.swigValue());

        if (TorrentSettings.proxy.type > ProxyType.DISABLED)
            settings.setBoolean(settings_pack.bool_types.force_proxy.swigValue(), TorrentSettings.proxy.force);
        else
            settings.setBoolean(settings_pack.bool_types.force_proxy.swigValue(), false);

        settings.setBoolean(settings_pack.int_types.torrent_connect_boost.swigValue(), true);
        settings.setInteger(settings_pack.int_types.choking_algorithm.swigValue(), settings_pack.choking_algorithm_t.rate_based_choker.swigValue());

        settings.setBoolean(settings_pack.bool_types.volatile_read_cache.swigValue(), false);

        settings.setInteger(settings_pack.int_types.upload_rate_limit.swigValue(), TorrentSettings.speed.uploadRateLimit);
        settings.setInteger(settings_pack.int_types.download_rate_limit.swigValue(), TorrentSettings.speed.downloadRateLimit);
        settings.setInteger(settings_pack.int_types.max_peerlist_size.swigValue(), 25); //set low peerlist size on mobile

        //Local Peer Discovery
        settings.setBoolean(settings_pack.bool_types.enable_lsd.swigValue(), TorrentSettings.privacy.useLSD);
        settings.broadcastLSD(TorrentSettings.privacy.useLSD);

        //Encryption
        settings.setInteger(settings_pack.int_types.allowed_enc_level.swigValue(), settings_pack.enc_level.pe_rc4.swigValue());
        settings.setBoolean(settings_pack.bool_types.prefer_rc4.swigValue(), true);

        if (TorrentSettings.privacy.encryption == Encryption.ENABLED) {
            settings.setInteger(settings_pack.int_types.out_enc_policy.swigValue(), settings_pack.enc_policy.pe_enabled.swigValue());
            settings.setInteger(settings_pack.int_types.in_enc_policy.swigValue(), settings_pack.enc_policy.pe_enabled.swigValue());
        } else if (TorrentSettings.privacy.encryption == Encryption.REQUIRED) {
            settings.setInteger(settings_pack.int_types.out_enc_policy.swigValue(), settings_pack.enc_policy.pe_forced.swigValue());
            settings.setInteger(settings_pack.int_types.in_enc_policy.swigValue(), settings_pack.enc_policy.pe_forced.swigValue());
        } else if (TorrentSettings.privacy.encryption == Encryption.DISABLED) {
            settings.setInteger(settings_pack.int_types.out_enc_policy.swigValue(), settings_pack.enc_policy.pe_disabled.swigValue());
            settings.setInteger(settings_pack.int_types.in_enc_policy.swigValue(), settings_pack.enc_policy.pe_disabled.swigValue());
        }

        //proxy
        if (TorrentSettings.proxy.type > ProxyType.DISABLED) {
            if (TorrentSettings.proxy.type != ProxyType.I2P) {
                settings.setString(settings_pack.string_types.proxy_hostname.swigValue(), TorrentSettings.proxy.host);
                settings.setInteger(settings_pack.int_types.proxy_port.swigValue(), TorrentSettings.proxy.port);
            }
            if (TorrentSettings.proxy.useAuth) {
                settings.setString(settings_pack.string_types.proxy_username.swigValue(), TorrentSettings.proxy.username);
                settings.setString(settings_pack.string_types.proxy_password.swigValue(), TorrentSettings.proxy.password);
            }
            if (TorrentSettings.proxy.type == ProxyType.DISABLED) {
                settings.setInteger(settings_pack.int_types.proxy_type.swigValue(), settings_pack.proxy_type_t.none.swigValue());
            } else if (TorrentSettings.proxy.type == ProxyType.SOCKS4) {
                settings.setInteger(settings_pack.int_types.proxy_type.swigValue(), settings_pack.proxy_type_t.socks4.swigValue());
            } else if (TorrentSettings.proxy.type == ProxyType.SOCKS5) {
                if (TorrentSettings.proxy.useAuth)
                    settings.setInteger(settings_pack.int_types.proxy_type.swigValue(), settings_pack.proxy_type_t.socks5_pw.swigValue());
                else
                    settings.setInteger(settings_pack.int_types.proxy_type.swigValue(), settings_pack.proxy_type_t.socks5.swigValue());
            } else if (TorrentSettings.proxy.type == ProxyType.HTTP) {
                if (TorrentSettings.proxy.useAuth)
                    settings.setInteger(settings_pack.int_types.proxy_type.swigValue(), settings_pack.proxy_type_t.http_pw.swigValue());
                else
                    settings.setInteger(settings_pack.int_types.proxy_type.swigValue(), settings_pack.proxy_type_t.http.swigValue());
            } else if (TorrentSettings.proxy.type == ProxyType.I2P) {
                settings.setString(settings_pack.string_types.i2p_hostname.swigValue(), TorrentSettings.proxy.host);
                settings.setInteger(settings_pack.int_types.i2p_port.swigValue(), 7656);
                settings.setInteger(settings_pack.int_types.proxy_type.i2p_port.swigValue(), settings_pack.proxy_type_t.i2p_proxy.swigValue());
            }
            settings.setBoolean(settings_pack.bool_types.proxy_peer_connections.swigValue(), TorrentSettings.proxy.useForPeerConnections);
        }

        //interfaces + ports
        int port = TorrentSettings.listening.port;


        if (TorrentSettings.advanced.networkInterface != null && TorrentSettings.advanced.networkInterface.size() > 0) {
            Map<String, String> nv = TorrentSettings.advanced.networkInterface;
            for (Map.Entry<String, String> o : nv.entrySet()) {
                Map.Entry pair = (Map.Entry) o;
                if ((!TorrentSettings.advanced.listenOnIPv6 && pair.getValue().equals("IPv6")) || (TorrentSettings.advanced.listenOnIPv6 && pair.getValue().equals("IPv4")))
                    continue;
                settings.setString(settings_pack.string_types.listen_interfaces.swigValue(), String.format("%s:%s", pair.getKey(), pair.getValue()));
                trace("Listening on " + String.format("%s:%s", pair.getKey(), pair.getValue()));
            }
        } else {
            settings.setString(settings_pack.string_types.listen_interfaces.swigValue(), String.format("0.0.0.0:%d", port));
        }

        settings.setString(settings_pack.string_types.listen_interfaces.swigValue(), String.format("0.0.0.0:%d", port));

        //upnp
        settings.setBoolean(settings_pack.bool_types.enable_upnp.swigValue(), TorrentSettings.listening.useUPnP);
        settings.setBoolean(settings_pack.bool_types.enable_natpmp.swigValue(), TorrentSettings.listening.useUPnP);

        //dht
        if (TorrentSettings.privacy.useDHT) {
            settings.enableDht(true);
            dht_settings dhtSettings = new dht_settings();
            dhtSettings.setPrivacy_lookups(true);
            ltsession.swig().set_dht_settings(dhtSettings);
            settings.setBoolean(settings_pack.bool_types.use_dht_as_fallback.swigValue(), false);
        } else if (ltsession.isDHTRunning()) {
            settings.enableDht(false);
        }

        return settings;
    }

    private class initSession implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            if (libTorrentThread != null && ltsession != null) {
                resumeSession();
            } else {
                if ((initialising || initialised) && libTorrentThread != null)
                    libTorrentThread.interrupt();

                initialising = true;
                initialised = false;
                initialisingLatch = new CountDownLatch(1);

                libTorrentThread = new HandlerThread(LIBTORRENT_THREAD_NAME);
                libTorrentThread.start();
                libTorrentHandler = new Handler(libTorrentThread.getLooper());
                libTorrentHandler.post(new Runnable() {
                    @Override
                    public void run() {

                        File geoDB = new File(TorrentSettings.storage.geoipDataPath + "/geolite2-country.mmdb");
                        try {
                            geoDBreader = new DatabaseReader.Builder(geoDB).withCache(new CHMCache()).build();
                        } catch (IOException e) {
                            trace(e.getMessage());
                            e.printStackTrace();
                        }

                        ltsession = new Session();
                        ltsession.addListener(innerListener);
                        ltsession.applySettings(getDefaultSessionSettings());

                        if (TorrentSettings.privacy.useDHT) {
                            dht = new Dht(ltsession);
                            for (int i = 0; i < dhtRouters.size(); i++)
                                dht.put(new Entry(dhtRouters.get(i)));
                            dht.start();
                        }
                        initialising = false;
                        initialised = true;
                        initialisingLatch.countDown();
                    }
                });
            }

            trace("Libtorrent version: " + LibTorrent.version());

            return aneHelper.getFREObject(true);
        }
    }

    private void resumeSession() {
        if (libTorrentThread != null && ltsession != null) {
            libTorrentHandler.removeCallbacksAndMessages(null);

            //resume torrent session if needed
            if (ltsession.isPaused()) {
                libTorrentHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        ltsession.resume();
                    }
                });
            }

            //start DHT if needed
            if (dht != null && !dht.running()) {
                libTorrentHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        dht.start();
                    }
                });
            }
        }
    }

    private class endSession implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            trace("endSession called");
            try {
                if (ltsession == null) {
                    return null;
                }
                libTorrentHandler.removeCallbacksAndMessages(null);
                ltsession.removeListener(stateUpdateAlertListener);
                ltsession.removeListener(innerListener);

                //saveSettings();

                ltsession.abort();
                ltsession = null;
                dht.stop();
            } catch (Exception e) {
                trace(e.getMessage());
            }
            return null;
        }
    }


    private class updateSettings implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            FREObject settingsProps = freObjects[0];

            logLevel = aneHelper.getInt(aneHelper.getProperty(settingsProps, "logLevel"));
            clientName = aneHelper.getString(aneHelper.getProperty(settingsProps, "clientName")) + "/" + LibTorrent.version();


            TorrentSettings.queryFileProgress = aneHelper.getBool(aneHelper.getProperty(settingsProps, "queryFileProgress"));

            FREArray frePriority = (FREArray) aneHelper.getProperty(settingsProps, "prioritizedFileTypes");
            long numPriority = aneHelper.getArrayLength(frePriority);
            for (int j = 0; j < numPriority; ++j) {
                try {
                    TorrentSettings.priorityFileTypes.add(aneHelper.getString(frePriority.getObjectAt(j)));
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            FREObject storageProps = aneHelper.getProperty(settingsProps, "storage");
            TorrentSettings.storage.outputPath = aneHelper.getString(aneHelper.getProperty(storageProps, "outputPath"));
            TorrentSettings.storage.torrentPath = aneHelper.getString(aneHelper.getProperty(storageProps, "torrentPath"));
            TorrentSettings.storage.resumePath = aneHelper.getString(aneHelper.getProperty(storageProps, "resumePath"));
            TorrentSettings.storage.geoipDataPath = aneHelper.getString(aneHelper.getProperty(storageProps, "geoipDataPath"));
            TorrentSettings.storage.sessionStatePath = aneHelper.getString(aneHelper.getProperty(storageProps, "sessionStatePath"));
            TorrentSettings.storage.sparse = aneHelper.getBool(aneHelper.getProperty(storageProps, "sparse"));
            TorrentSettings.storage.enabled = aneHelper.getBool(aneHelper.getProperty(storageProps, "enabled"));

            FREObject privacyProps = aneHelper.getProperty(settingsProps, "privacy");
            TorrentSettings.privacy.usePEX = aneHelper.getBool(aneHelper.getProperty(privacyProps, "usePEX"));
            TorrentSettings.privacy.useLSD = aneHelper.getBool(aneHelper.getProperty(privacyProps, "useLSD"));
            TorrentSettings.privacy.encryption = aneHelper.getInt(aneHelper.getProperty(privacyProps, "encryption"));
            TorrentSettings.privacy.useAnonymousMode = aneHelper.getBool(aneHelper.getProperty(privacyProps, "useAnonymousMode"));
            TorrentSettings.privacy.useDHT = aneHelper.getBool(aneHelper.getProperty(privacyProps, "useDHT"));

            FREObject queueingProps = aneHelper.getProperty(settingsProps, "queueing");
            TorrentSettings.queueing.enabled = aneHelper.getBool(aneHelper.getProperty(queueingProps, "enabled"));
            TorrentSettings.queueing.ignoreSlow = aneHelper.getBool(aneHelper.getProperty(queueingProps, "ignoreSlow"));
            TorrentSettings.queueing.maxActiveDownloads = aneHelper.getInt(aneHelper.getProperty(queueingProps, "maxActiveDownloads"));
            TorrentSettings.queueing.maxActiveTorrents = aneHelper.getInt(aneHelper.getProperty(queueingProps, "maxActiveTorrents"));
            TorrentSettings.queueing.maxActiveUploads = aneHelper.getInt(aneHelper.getProperty(queueingProps, "maxActiveUploads"));

            FREObject speedProps = aneHelper.getProperty(settingsProps, "speed");
            TorrentSettings.speed.uploadRateLimit = aneHelper.getInt(aneHelper.getProperty(speedProps, "uploadRateLimit"));
            TorrentSettings.speed.downloadRateLimit = aneHelper.getInt(aneHelper.getProperty(speedProps, "downloadRateLimit"));
            TorrentSettings.speed.isuTPEnabled = aneHelper.getBool(aneHelper.getProperty(speedProps, "isuTPEnabled"));
            TorrentSettings.speed.isuTPRateLimited = aneHelper.getBool(aneHelper.getProperty(speedProps, "isuTPRateLimited"));
            TorrentSettings.speed.ignoreLimitsOnLAN = aneHelper.getBool(aneHelper.getProperty(speedProps, "ignoreLimitsOnLAN"));
            TorrentSettings.speed.rateLimitIpOverhead = aneHelper.getBool(aneHelper.getProperty(speedProps, "rateLimitIpOverhead"));

            //listening port
            FREObject listeningProps = aneHelper.getProperty(settingsProps, "listening");
            TorrentSettings.listening.useUPnP = aneHelper.getBool(aneHelper.getProperty(listeningProps, "useUPnP"));
            TorrentSettings.listening.randomPort = aneHelper.getBool(aneHelper.getProperty(listeningProps, "randomPort"));
            if (TorrentSettings.listening.randomPort)
                TorrentSettings.listening.port = randomInteger(6881, 6999);
            else
                TorrentSettings.listening.port = aneHelper.getInt(aneHelper.getProperty(listeningProps, "port"));

            FREObject connectionsProps = aneHelper.getProperty(settingsProps, "connections");
            TorrentSettings.connections.maxNum = aneHelper.getInt(aneHelper.getProperty(connectionsProps, "maxNum"));
            TorrentSettings.connections.maxNumPerTorrent = aneHelper.getInt(aneHelper.getProperty(connectionsProps, "maxNumPerTorrent"));
            TorrentSettings.connections.maxUploads = aneHelper.getInt(aneHelper.getProperty(connectionsProps, "maxUploads"));
            TorrentSettings.connections.maxUploadsPerTorrent = aneHelper.getInt(aneHelper.getProperty(connectionsProps, "maxUploadsPerTorrent"));

            FREObject proxyProps = aneHelper.getProperty(settingsProps, "proxy");
            TorrentSettings.proxy.type = aneHelper.getInt(aneHelper.getProperty(proxyProps, "type"));
            TorrentSettings.proxy.port = aneHelper.getInt(aneHelper.getProperty(proxyProps, "port"));
            TorrentSettings.proxy.host = aneHelper.getString(aneHelper.getProperty(proxyProps, "host"));
            TorrentSettings.proxy.useForPeerConnections = aneHelper.getBool(aneHelper.getProperty(proxyProps, "useForPeerConnections"));
            TorrentSettings.proxy.force = aneHelper.getBool(aneHelper.getProperty(proxyProps, "force"));
            TorrentSettings.proxy.useAuth = aneHelper.getBool(aneHelper.getProperty(proxyProps, "useAuth"));
            TorrentSettings.proxy.username = aneHelper.getString(aneHelper.getProperty(proxyProps, "username"));
            TorrentSettings.proxy.password = aneHelper.getString(aneHelper.getProperty(proxyProps, "password"));

            FREObject advancedProps = aneHelper.getProperty(settingsProps, "advanced");
            TorrentSettings.advanced.diskCacheSize = aneHelper.getInt(aneHelper.getProperty(advancedProps, "diskCacheSize"));
            TorrentSettings.advanced.diskCacheTTL = aneHelper.getInt(aneHelper.getProperty(advancedProps, "diskCacheTTL"));
            TorrentSettings.advanced.enableOsCache = aneHelper.getBool(aneHelper.getProperty(advancedProps, "enableOsCache"));
            TorrentSettings.advanced.outgoingPortsMin = aneHelper.getInt(aneHelper.getProperty(advancedProps, "outgoingPortsMin"));
            TorrentSettings.advanced.outgoingPortsMax = aneHelper.getInt(aneHelper.getProperty(advancedProps, "outgoingPortsMax"));
            TorrentSettings.advanced.recheckTorrentsOnCompletion = aneHelper.getBool(aneHelper.getProperty(advancedProps, "recheckTorrentsOnCompletion"));
            TorrentSettings.advanced.resolveCountries = aneHelper.getBool(aneHelper.getProperty(advancedProps, "resolveCountries"));
            TorrentSettings.advanced.isSuperSeedingEnabled = aneHelper.getBool(aneHelper.getProperty(advancedProps, "isSuperSeedingEnabled"));
            TorrentSettings.advanced.numMaxHalfOpenConnections = aneHelper.getInt(aneHelper.getProperty(advancedProps, "numMaxHalfOpenConnections"));
            TorrentSettings.advanced.announceToAllTrackers = aneHelper.getBool(aneHelper.getProperty(advancedProps, "announceToAllTrackers"));
            TorrentSettings.advanced.enableTrackerExchange = aneHelper.getBool(aneHelper.getProperty(advancedProps, "enableTrackerExchange"));
            TorrentSettings.advanced.resolvePeerHostNames = aneHelper.getBool(aneHelper.getProperty(advancedProps, "resolvePeerHostNames"));
            TorrentSettings.advanced.listenOnIPv6 = aneHelper.getBool(aneHelper.getProperty(advancedProps, "listenOnIPv6"));
            TorrentSettings.advanced.announceIP = aneHelper.getString(aneHelper.getProperty(advancedProps, "announceIP"));

            FREObject networkInterface = aneHelper.getProperty(advancedProps, "networkInterface");
            if (networkInterface != null) {
                FREArray networkAddresses = (FREArray) aneHelper.getProperty(networkInterface, "addresses");
                long numAddresses = aneHelper.getArrayLength(networkAddresses);
                for (int j = 0; j < numAddresses; ++j) {
                    try {
                        FREObject address = networkAddresses.getObjectAt(j);
                        Map<String, String> addressMap = new HashMap<>();
                        addressMap.put(aneHelper.getString(aneHelper.getProperty(address, "address")),
                                aneHelper.getString(aneHelper.getProperty(address, "ipVersion")));
                        TorrentSettings.advanced.networkInterface.putAll(addressMap);
                    } catch (FREInvalidObjectException | FREWrongThreadException e) {
                        trace(e.getMessage());
                        e.printStackTrace();
                    }
                }
            }
            return null;
        }
    }

    private final StateUpdateAlertListener stateUpdateAlertListener = new StateUpdateAlertListener() {
        @Override
        public void stateUpdate(StateUpdateAlert alert) {
            List<TorrentStatus> torrentList = alert.getStatus();
            JSONObject jitm;
            JSONArray jsonArray = new JSONArray();

            TorrentStatus status;
            TorrentStatus.State state;
            for (ListIterator<TorrentStatus> iter = torrentList.listIterator(); iter.hasNext(); ) {
                status = iter.next();
                state = status.getState();
                try {
                    jitm = new JSONObject();
                    jitm.put("id", addedTorrentsHashMap.get(status.getInfoHash().toString()));
                    jitm.put("numPieces", status.getNumPieces());
                    jitm.put("isSequential", status.isSequentialDownload()); //need this ?


                    jitm.put("queuePosition", status.getQueuePosition());
                    jitm.put("progress", status.getProgress() * 100);
                    jitm.put("downloadRate", status.getDownloadPayloadRate());
                    jitm.put("downloadRateAverage", status.getAllTimeDownload() / (1 + status.getActiveTime() - status.getFinishedTime()));
                    jitm.put("allTimeDownload", status.getAllTimeDownload());
                    jitm.put("downloadPayloadRate", status.getDownloadPayloadRate());
                    jitm.put("uploadRate", status.getUploadPayloadRate());
                    jitm.put("uploadRateAverage", status.getAllTimeUpload() / (1 + status.getActiveTime()));
                    jitm.put("numPeers", status.getNumPeers());
                    jitm.put("numPeersTotal", status.getListPeers());
                    jitm.put("numSeeds", status.getNumSeeds());
                    jitm.put("numSeedsTotal", status.getListSeeds());
                    jitm.put("wasted", status.totalFailedBytes() + status.totalRedundantBytes());
                    jitm.put("activeTime", (state == TorrentStatus.State.SEEDING) ? status.getSeedingTime() : status.getActiveTime());
                    jitm.put("downloaded", status.getAllTimeDownload());
                    jitm.put("downloadedSession", status.getAllTimeDownload());
                    jitm.put("uploaded", status.getAllTimeUpload());
                    jitm.put("uploadedSession", status.totalPayloadUpload());
                    jitm.put("uploadMax", (status.getUploadsLimit() > 0) ? status.getUploadsLimit() : -1);
                    jitm.put("numConnections", status.getNumConnections());
                    jitm.put("nextAnnounce", (status.nextAnnounce() > 0) ? status.nextAnnounce() * 1000L : 0);
                    jitm.put("lastSeenComplete", (status.lastSeenComplete() != 0) ? status.lastSeenComplete() : -1);
                    jitm.put("completedOn", (status.getCompletedTime() != 0) ? status.getCompletedTime() : -1);
                    jitm.put("savePath", status.handle().getSavePath());
                    jitm.put("addedOn", status.getAddedTime());
                    Long uploadR = status.getAllTimeUpload();
                    Long downloadR = (status.getAllTimeDownload() < status.getTotalDone() * 0.01) ? status.getTotalDone() : status.getAllTimeDownload();
                    if (downloadR == 0) {
                        jitm.put("shareRatio", (uploadR == 0) ? 0.00 : 9999.0);
                    } else {
                        Double ratio = (double) (uploadR / downloadR);
                        jitm.put("shareRatio", (ratio == 9999.0) ? 9999.0 : ratio);
                    }
                    jitm.put("downloadMax", status.handle().getDownloadLimit());

                    //partial pieces
                    ArrayList<PartialPieceInfo> queue = status.handle().getDownloadQueue();
                    JSONArray partialpArray = new JSONArray();
                    for (PartialPieceInfo aQueue : queue) {
                        partialpArray.put(aQueue.pieceIndex());
                    }
                    jitm.put("partialPieces", partialpArray);

                    //file progress
                    if (TorrentSettings.queryFileProgress && state != TorrentStatus.State.SEEDING) {
                        long[] fp = status.handle().getFileProgress();
                        JSONArray progressArray = new JSONArray();
                        for (int k = 0; k < fp.length; ++k)
                            progressArray.put(fp[k]);
                        jitm.put("fileProgress", progressArray);

                        Priority[] fpri = status.handle().getFilePriorities();
                        JSONArray priorityArray = new JSONArray();
                        for (int k = 0; k < fpri.length; ++k)
                            priorityArray.put(fpri[k].swig());
                        jitm.put("filePriority", priorityArray);
                    }

                    jsonArray.put(jitm);

                } catch (JSONException e) {
                    trace(e.getMessage());
                    e.printStackTrace();
                }
            }
            dispatchStatusEventAsync(jsonArray.toString(), FRETorrentAlert.STATE_UPDATE);
        }
    };

    final MetadataReceivedAlertListener metadataReceivedAlertListener = new MetadataReceivedAlertListener() {
        @Override
        public void metaDataReceived(MetadataReceivedAlert alert) {
            torrent_handle th = alert.handle().swig();
            TorrentInfo ti = new TorrentInfo(th.get_torrent_copy());
            String savedId = addedMagnetsIdMap.get(th.id());
            String savedUri = addedMagnetsUriMap.get(th.id());
            Boolean isSeq = addedMagnetsSequentialMap.get(th.id());

            String[] uriParams = savedUri.split("&");
            String s;
            for (int i = 1; i < uriParams.length; i++) {
                s = Uri.decode(uriParams[i]);
                if (s.startsWith("ws=")) {
                    s = s.substring(3);
                    ti.addUrlSeed(s);
                }
            }
            byte[] data = ti.bencode();

            FileOutputStream stream = null;
            try {
                trace(TorrentSettings.storage.torrentPath);
                stream = new FileOutputStream(TorrentSettings.storage.torrentPath + "/" + savedId + ".torrent");
                stream.write(data);
                stream.close();
            } catch (IOException e) {
                trace(e.getMessage());
                e.printStackTrace();
            }

            addedMagnetsIdMap.remove(th.id());
            addedMagnetsUriMap.remove(th.id());
            addedMagnetsSequentialMap.remove(th.id());

            if (th.is_valid())
                ltsession.swig().remove_torrent(th);

            JSONObject jsonObject = new JSONObject();
            try {
                jsonObject.put("id", savedId);
                jsonObject.put("isSequential", isSeq);
            } catch (JSONException e) {
                e.printStackTrace();
            }

            dispatchStatusEventAsync(jsonObject.toString(), FRETorrentAlert.METADATA_RECEIVED);
        }
    };

    void prioritizeFileTypes(TorrentHandle th, TorrentInfo ti) {
        FileStorage sto = ti.files();
        int first = 0;
        int last = 0;
        Boolean found = false;
        for (int i = 0; i < sto.numFiles(); ++i) {
            for (int j = 0; j < TorrentSettings.priorityFileTypes.size(); ++j) {
                first = sto.mapFile(i, 0, 0).getPiece();
                last = sto.mapFile(i, sto.fileSize(i) - 1, 0).getPiece();
                th.setFilePriority(i, Priority.SEVEN);
                found = true;
                break;
            }
        }
        if (found) {
            Priority[] pri = new Priority[ti.numPieces()];
            for (int i = 0; i < pri.length; ++i) {
                if (i >= first && i <= last) {
                    if (i < first + 10)
                        pri[i] = Priority.SEVEN;
                    else
                        pri[i] = Priority.TWO;
                } else {
                    pri[i] = Priority.NORMAL;
                }
            }

            for (int j = first; j < last; ++j) {
                th.setPieceDeadline(j, j + 1);
            }
            th.setPieceDeadline(last, 0);
        }
    }


    private class getTorrentPeers implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            final String queryId = aneHelper.getString(freObjects[0]);
            final Boolean queryFlags = aneHelper.getBool(freObjects[1]);

            libTorrentHandler.post(new Runnable() {
                @Override
                public void run() {
                    String queryHash = "";
                    if (queryId != null && !queryId.isEmpty()) {
                        Sha1Hash tmpHash = addedTorrentsIdMap.get(queryId);
                        if (tmpHash != null)
                            queryHash = addedTorrentsIdMap.get(queryId).toString();
                    }

                    JSONArray jsonTorrentArr = new JSONArray();
                    JSONObject jsonTorrent;
                    JSONArray jsonPeersArr;
                    JSONObject jsonTracker;

                    ArrayList<TorrentHandle> tv = ltsession.getTorrents();
                    TorrentHandle th;
                    String id;
                    String hash;
                    TorrentInfo ti;
                    TorrentStatus status;

                    for (int i = 0; i < tv.size(); i++) {
                        jsonPeersArr = new JSONArray();
                        th = tv.get(i);
                        hash = th.getInfoHash().toString();
                        id = addedTorrentsHashMap.get(th.getInfoHash().toString());
                        if (!queryHash.isEmpty() && hash.compareTo(queryHash) != 0)
                            continue;

                        if (!th.isValid())
                            continue;

                        status = th.getStatus();

                        if (!status.isSeeding()) {
                            ArrayList<PeerInfo> arrayList = th.peerInfo();
                            PeerInfo pi;
                            long flags;
                            long source;
                            long connection;

                            for (int j = 0; j < arrayList.size(); j++) {
                                pi = arrayList.get(j);

                                flags = pi.getSwig().getFlags();
                                source = pi.getSwig().getSource();
                                connection = pi.getSwig().getConnection_type();

                                if (hasBit(flags, (long) peer_info.peer_flags_t.handshake.swigValue()) || hasBit(flags, (long) peer_info.peer_flags_t.connecting.swigValue()))
                                    continue;


                                jsonTracker = new JSONObject();
                                try {
                                    jsonTracker.put("ip", pi.getSwig().getIp().address().to_string());
                                    jsonTracker.put("client", pi.getSwig().getClient());
                                    jsonTracker.put("port", pi.getSwig().getIp().port());
                                    jsonTracker.put("localPort", pi.getSwig().getLocal_endpoint().port());

                                    if (geoDBreader == null) {
                                        jsonTracker.put("country", "");
                                    } else {
                                        try {
                                            jsonTracker.put("country", geoDBreader.country(InetAddress.getByName(pi.getSwig().getIp().address().to_string())).getCountry().getIsoCode());
                                        } catch (IOException | GeoIp2Exception e) {
                                            trace(e.getMessage());
                                            e.printStackTrace();
                                        }
                                    }

                                    String conn = "";
                                    if (hasBit(flags, (long) peer_info.peer_flags_t.utp_socket.swigValue()))
                                        conn = "uTP";
                                    else if (hasBit(flags, (long) peer_info.peer_flags_t.i2p_socket.swigValue()))
                                        conn = "i2P";
                                    else if (connection == peer_info.connection_type_t.standard_bittorrent.swigValue())
                                        conn = "BT";
                                    else if (connection == peer_info.connection_type_t.web_seed.swigValue())
                                        conn = "Web";

                                    jsonTracker.put("connection", conn);

                                    jsonTracker.put("downSpeed", pi.getSwig().getDown_speed());
                                    jsonTracker.put("downloaded", pi.getSwig().getTotal_download());
                                    jsonTracker.put("upSpeed", pi.getSwig().getUp_speed());
                                    jsonTracker.put("uploaded", pi.getSwig().getTotal_upload());
                                    jsonTracker.put("progress", pi.getSwig().getProgress());

                                    if (queryFlags) {
                                        boolean isChoked = hasBit(flags, (long) peer_info.peer_flags_t.choked.swigValue());
                                        boolean isRemoteChoked = hasBit(flags, (long) peer_info.peer_flags_t.remote_choked.swigValue());
                                        boolean isRemoteInterested = hasBit(flags, (long) peer_info.peer_flags_t.remote_interested.swigValue());
                                        boolean isInteresting = hasBit(flags, (long) peer_info.peer_flags_t.interesting.swigValue());

                                        String flgsAsString = "";
                                        JSONObject jsonFlags = new JSONObject();

                                        if (isInteresting) {
                                            if (isRemoteChoked)
                                                flgsAsString += "d ";
                                            else
                                                flgsAsString += "D ";
                                        }

                                        if (isRemoteInterested) {
                                            if (isChoked)
                                                flgsAsString += "u ";
                                            else
                                                flgsAsString += "U ";
                                        }

                                        if (hasBit(flags, (long) peer_info.peer_flags_t.optimistic_unchoke.swigValue())) {
                                            jsonFlags.put("isOptimisticUnchoke", true);
                                            flgsAsString += "O ";
                                        } else {
                                            jsonFlags.put("isOptimisticUnchoke", false);
                                        }

                                        if (hasBit(flags, (long) peer_info.peer_flags_t.snubbed.swigValue())) {
                                            jsonFlags.put("isSnubbed", isInteresting);
                                            flgsAsString += "S ";
                                        } else {
                                            jsonFlags.put("isSnubbed", isInteresting);
                                        }

                                        if (hasBit(flags, (long) peer_info.peer_flags_t.local_connection.swigValue())) {
                                            flgsAsString += "I ";
                                            jsonFlags.put("isLocalConnection", true);
                                        } else {
                                            jsonFlags.put("isLocalConnection", false);
                                        }

                                        if (!isRemoteChoked && !isInteresting)
                                            flgsAsString += "K ";

                                        if (!isChoked && !isRemoteInterested)
                                            flgsAsString += "? ";


                                        if (hasBit(source, (long) peer_info.peer_source_flags.pex.swigValue())) {
                                            flgsAsString += "X ";
                                            jsonFlags.put("fromPEX", true);
                                        } else {
                                            jsonFlags.put("fromPEX", false);
                                        }

                                        if (hasBit(source, (long) peer_info.peer_source_flags.dht.swigValue())) {
                                            flgsAsString += "H ";
                                            jsonFlags.put("fromDHT", true);
                                        } else {
                                            jsonFlags.put("fromDHT", false);
                                        }

                                        if (hasBit(source, (long) peer_info.peer_source_flags.lsd.swigValue())) {
                                            flgsAsString += "L ";
                                            jsonFlags.put("fromLSD", true);
                                        } else {
                                            jsonFlags.put("fromLSD", false);
                                        }

                                        if (hasBit(flags, (long) peer_info.peer_flags_t.rc4_encrypted.swigValue())) {
                                            jsonFlags.put("isRC4encrypted", true);
                                            flgsAsString += "E ";
                                        } else {
                                            jsonFlags.put("isRC4encrypted", false);
                                        }

                                        if (hasBit(flags, (long) peer_info.peer_flags_t.plaintext_encrypted.swigValue())) {
                                            jsonFlags.put("isPlainTextEncrypted", true);
                                            flgsAsString += "e ";
                                        } else {
                                            jsonFlags.put("isPlainTextEncrypted", false);
                                        }

                                        if (hasBit(flags, (long) peer_info.peer_flags_t.utp_socket.swigValue()))
                                            flgsAsString += "P ";


                                        jsonFlags.put("supportsExtensions", (hasBit(flags, (long) peer_info.peer_flags_t.supports_extensions.swigValue())));
                                        jsonFlags.put("isSeed", (hasBit(flags, (long) peer_info.peer_flags_t.seed.swigValue())));
                                        jsonFlags.put("onParole", (hasBit(flags, (long) peer_info.peer_flags_t.on_parole.swigValue())));
                                        jsonFlags.put("isUploadOnly", (hasBit(flags, (long) peer_info.peer_flags_t.upload_only.swigValue())));
                                        jsonFlags.put("isEndGameMode", (hasBit(flags, (long) peer_info.peer_flags_t.endgame_mode.swigValue())));
                                        jsonFlags.put("isHolePunched", (hasBit(flags, (long) peer_info.peer_flags_t.holepunched.swigValue())));
                                        jsonFlags.put("fromTracker", (hasBit(source, (long) peer_info.peer_source_flags.tracker.swigValue())));
                                        jsonFlags.put("fromResumeData", (hasBit(source, (long) peer_info.peer_source_flags.tracker.swigValue())));
                                        jsonFlags.put("fromIncoming", (hasBit(source, (long) peer_info.peer_source_flags.incoming.swigValue())));

                                        jsonFlags.put("isInteresting", isInteresting);
                                        jsonFlags.put("isRemoteInterested", isRemoteInterested);
                                        jsonFlags.put("isChoked", isChoked);

                                        jsonTracker.put("flagsAsString", flgsAsString);
                                        jsonTracker.put("flags", jsonFlags);
                                    }

                                    int localMissing = 0;
                                    int remoteHaves = 0;
                                    Bitfield local = status.pieces();
                                    bitfield remote = pi.getSwig().getPieces();

                                    for (int k = 0; k < local.swig().count(); ++k) {
                                        if (!local.swig().get_bit(k)) {
                                            ++localMissing;
                                            if (remote.get_bit(k))
                                                ++remoteHaves;
                                        }
                                    }
                                    jsonTracker.put("relevance", (localMissing == 0) ? 0.0 : remoteHaves / localMissing);
                                    jsonPeersArr.put(jsonTracker);

                                } catch (JSONException e) {
                                    e.printStackTrace();
                                }
                            }
                        }

                        jsonTorrent = new JSONObject();
                        try {
                            jsonTorrent.put("id", id);
                            jsonTorrent.put("peersInfo", jsonPeersArr);
                        } catch (JSONException e) {
                            trace(e.getMessage());
                            e.printStackTrace();
                        }
                        jsonTorrentArr.put(jsonTorrent);
                    }

                    dispatchStatusEventAsync(jsonTorrentArr.toString(), FRETorrentEvent.PEERS_FROM_JSON);

                }
            });

            return null;
        }
    }

    //temporary until can compare 2 flags properly
    private Boolean hasBit(Long num1, Long num2) {
        String s1 = Long.toBinaryString(num1); //flags
        String s2 = Long.toBinaryString(num2); //test
        Boolean ret = false;
        if (s1.length() >= s2.length())
            ret = (s1.charAt(s1.length() - s2.length()) == '1');
        return ret;
    }

    private class getTorrentInfo implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            final String uri = aneHelper.getString(freObjects[0]);
            FREObject ti = null;
            try {
                ti = getFRETorrentInfo(readTorrentInfo(uri), Uri.parse(uri).getPath());
            } catch (FREWrongThreadException e) {
                e.printStackTrace();
            }
            return ti;
        }
    }

    private TorrentInfo readTorrentInfo(String uri) {
        TorrentInfo ti = null;
        File file;
        if (uri.startsWith("file:")) {
            Uri path = Uri.parse(uri);
            file = new File(path.getPath());
        } else {
            file = new File(uri);
        }
        FileInputStream fileInputStream = null;
        byte[] responseByteArray = null;
        try {
            fileInputStream = new FileInputStream(file);
            responseByteArray = getBytesFromInputStream(fileInputStream);
            fileInputStream.close();
        } catch (IOException e) {
            trace(e.getMessage());
            e.printStackTrace();
        }
        if (fileInputStream != null && responseByteArray.length > 0)
            ti = TorrentInfo.bdecode(responseByteArray);
        return ti;
    }

    private FREObject getFRETorrentInfo(TorrentInfo ti, String path) throws FREWrongThreadException {
        FREObject torrentMeta;

        torrentMeta = aneHelper.createFREObject("com.tuarua.torrent.TorrentInfo", null);
        aneHelper.setProperty(torrentMeta, "status", "ok");
        aneHelper.setProperty(torrentMeta, "isPrivate", ti.isPrivate());
        aneHelper.setProperty(torrentMeta, "torrentFile", path);
        aneHelper.setProperty(torrentMeta, "numPieces", ti.numPieces());
        aneHelper.setProperty(torrentMeta, "size", ti.totalSize());
        aneHelper.setProperty(torrentMeta, "pieceLength", ti.pieceLength());
        aneHelper.setProperty(torrentMeta, "infoHash", ti.infoHash().toString());
        aneHelper.setProperty(torrentMeta, "name", ti.name());
        aneHelper.setProperty(torrentMeta, "comment", ti.comment());
        aneHelper.setProperty(torrentMeta, "creator", ti.creator());
        aneHelper.setProperty(torrentMeta, "creationDate", ti.creationDate());

        FileStorage sto = ti.files();

        FREArray vecTorrents;
        vecTorrents = (FREArray) aneHelper.createFREObject("Vector.<com.tuarua.torrent.TorrentFileMeta>", null);
        try {
            vecTorrents.setLength(sto.numFiles());
        } catch (FREInvalidObjectException | FREReadOnlyException e) {
            trace(e.getMessage());
            e.printStackTrace();
        }
        for (int i = 0; i < sto.numFiles(); ++i) {
            int first = sto.mapFile(i, 0, 0).getPiece();
            int last = sto.mapFile(i, sto.fileSize(i) - 1, 0).getPiece();
            FREObject meta = null;
            meta = aneHelper.createFREObject("com.tuarua.torrent.TorrentFileMeta", null);
            aneHelper.setProperty(meta, "path", sto.filePath(i));
            aneHelper.setProperty(meta, "name", sto.fileName(i));
            aneHelper.setProperty(meta, "offset", sto.fileOffset(i));
            aneHelper.setProperty(meta, "size", sto.fileSize(i));
            aneHelper.setProperty(meta, "firstPiece", first);
            aneHelper.setProperty(meta, "lastPiece", last);
            try {
                vecTorrents.setObjectAt(i, meta);
            } catch (FRETypeMismatchException | FREInvalidObjectException e) {
                e.printStackTrace();
            }
        }
        aneHelper.setProperty(torrentMeta, "files", vecTorrents);
        ArrayList<WebSeedEntry> webSeeds = ti.webSeeds();
        FREArray vecUrlSeeds;
        vecUrlSeeds = (FREArray) aneHelper.createFREObject("Vector.<String>", null);
        try {
            vecUrlSeeds.setLength(webSeeds.size());
        } catch (FREInvalidObjectException | FREReadOnlyException e) {
            e.printStackTrace();
        }
        //trace("number of webseeds: "+String.valueOf(webSeeds.size()));
        for (int i = 0; i < webSeeds.size(); ++i) {
            try {
                vecUrlSeeds.setObjectAt(i, aneHelper.getFREObject(webSeeds.get(i).url()));
            } catch (FRETypeMismatchException e) {
                trace(e.getMessage());
                e.printStackTrace();
            } catch (FREInvalidObjectException e) {
                e.printStackTrace();
            }
        }
        aneHelper.setProperty(torrentMeta, "urlSeeds", vecUrlSeeds);

        return torrentMeta;
    }

    private class addTorrent implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            final String id = aneHelper.getString(freObjects[0]);
            final String uri = aneHelper.getString(freObjects[1]);
            final String hash = aneHelper.getString(freObjects[2]);
            final Boolean isSeq = aneHelper.getBool(freObjects[3]);
            final Boolean seedMode = aneHelper.getBool(freObjects[4]);
            FREObject FREtorrentInfo = null;

            if (uri.startsWith("magnet")) {
                libTorrentHandler.post(new Runnable() {
                    //@Override
                    public void run() {
                        //change to metadata received alert
                        ltsession.removeListener(metadataReceivedAlertListener);
                        ltsession.addListener(metadataReceivedAlertListener);

                        add_torrent_params p = add_torrent_params.create_instance_disabled_storage();
                        error_code ec = new error_code();
                        libtorrent.parse_magnet_uri(uri, p, ec);

                        p.setUrl(uri);

                        if (ec.value() != 0) {
                            trace(ec.message());
                            throw new IllegalArgumentException(ec.message());
                        }

                        torrent_handle th;

                        p.setName("fetch_magnet:" + uri);
                        p.setSave_path("fetch_magnet/" + uri);

                        long flags = p.get_flags();
                        flags &= ~add_torrent_params.flags_t.flag_auto_managed.swigValue();

                        if (isSeq)
                            flags |= add_torrent_params.flags_t.flag_sequential_download.swigValue();
                        else
                            flags &= ~add_torrent_params.flags_t.flag_sequential_download.swigValue();


                        p.set_flags(flags);

                        ec.clear();
                        th = ltsession.swig().add_torrent(p, ec);
                        addedMagnetsIdMap.put(th.id(), id);
                        addedMagnetsUriMap.put(th.id(), uri);
                        addedMagnetsSequentialMap.put(th.id(), isSeq);
                        th.resume();
                    }
                });
            } else {
                TorrentInfo ti = readTorrentInfo(uri);
                if (ti != null) {
                    try {
                        if (uri.startsWith("file:"))
                            FREtorrentInfo = getFRETorrentInfo(ti, Uri.parse(uri).getPath());
                        else
                            FREtorrentInfo = getFRETorrentInfo(ti, uri);

                    } catch (FREWrongThreadException e) {
                        trace(e.getMessage());
                        e.printStackTrace();
                    }


                    addedTorrentsIdMap.put(id, ti.infoHash());
                    addedTorrentsHashMap.put(ti.infoHash().toString(), id);

                    AddTorrentParams p;
                    if (TorrentSettings.storage.enabled)
                        p = new AddTorrentParams();
                    else
                        p = new AddTorrentParams().createInstanceZeroStorage();

                    // p.savePath(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).getPath());
                    p.savePath(TorrentSettings.storage.outputPath);

                    p.torrentInfo(ti);
                    p.swig().setMax_connections(TorrentSettings.connections.maxNumPerTorrent);
                    p.swig().setMax_uploads(TorrentSettings.connections.maxUploadsPerTorrent);

                    long flags = p.flags();
                    flags &= ~add_torrent_params.flags_t.flag_paused.swigValue();
                    flags |= add_torrent_params.flags_t.flag_auto_managed.swigValue();

                    File resumeFile = new File(TorrentSettings.storage.resumePath + "/" + id + ".resume");
                    if (resumeFile.exists()) {
                        FileInputStream fileInputStream;
                        byte[] responseByteArray;
                        try {
                            fileInputStream = new FileInputStream(resumeFile);
                            responseByteArray = getBytesFromInputStream(fileInputStream);
                            fileInputStream.close();
                            p.resumeData(responseByteArray);
                            flags |= add_torrent_params.flags_t.flag_use_resume_save_path.swigValue();
                        } catch (IOException e) {
                            trace(e.getMessage());
                            e.printStackTrace();
                        }
                    }

                    if (isSeq)
                        flags |= add_torrent_params.flags_t.flag_sequential_download.swigValue();
                    else
                        flags &= ~add_torrent_params.flags_t.flag_sequential_download.swigValue();


                    if (seedMode)
                        flags |= add_torrent_params.flags_t.flag_seed_mode.swigValue();
                    else
                        flags &= ~add_torrent_params.flags_t.flag_seed_mode.swigValue();

                    p.flags(flags);

                    StorageMode storageMode;
                    if (TorrentSettings.storage.sparse)
                        storageMode = StorageMode.fromSwig(storage_mode_t.storage_mode_sparse.swigValue());
                    else
                        storageMode = StorageMode.fromSwig(storage_mode_t.storage_mode_allocate.swigValue());
                    p.storageMode(storageMode);


                    ltsession.asyncAddTorrent(p);
                }

                return FREtorrentInfo;
            }

            return FREtorrentInfo;
        }
    }

    private class isSupported implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            return aneHelper.getFREObject(true);
        }
    }

    private class addDHTRouter implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            dhtRouters.add(aneHelper.getString(freObjects[0]));
            return null;
        }
    }

    private class addFilterList implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            TorrentSettings.filters.filename = aneHelper.getString(freObjects[0]);
            libTorrentHandler.post(new Runnable() {
                @Override
                public void run() {
                    ip_filter ipFilterList = new ip_filter();
                    File file = new File(TorrentSettings.filters.filename);
                    int numFilters = 0;

                    BufferedReader br = null;
                    try {
                        br = new BufferedReader(new FileReader(file));
                        String line;

                        while ((line = br.readLine()) != null) {
                            if (line.startsWith("#") || line.startsWith("//") || line.isEmpty())
                                continue;

                            String[] partsList = line.split(":");
                            if (partsList.length < 2)
                                continue;
                            String[] IPList = partsList[partsList.length - 1].split("-");
                            if (IPList.length != 2)
                                continue;

                            String ipRangeFromStr = IPList[0].trim();
                            String ipRangeToStr = IPList[1].trim();

                            Address ipRangeFrom = new Address(ipRangeFromStr);
                            Address ipRangeTo = new Address(ipRangeToStr);

                            ipFilterList.add_rule(ipRangeFrom.swig(), ipRangeTo.swig(), 1);
                            trace(line);
                            numFilters++;
                        }
                        br.close();

                    } catch (IOException e) {
                        trace(e.getMessage());
                        e.printStackTrace();
                    }
                    if (numFilters > 0)
                        ltsession.swig().set_ip_filter(ipFilterList);

                    JSONObject jsonObject = new JSONObject();
                    try {
                        jsonObject.put("numFilters", numFilters);
                    } catch (JSONException e) {
                        trace(e.getMessage());
                        e.printStackTrace();
                    }
                    dispatchStatusEventAsync(jsonObject.toString(), FRETorrentEvent.FILTER_LIST_ADDED);

                }
            });

            return null;
        }
    }

    private class setQueuePosition implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            final String id = aneHelper.getString(freObjects[0]);
            int dir = aneHelper.getInt(freObjects[1]);
            Boolean ret = false;
            TorrentHandle th = ltsession.findTorrent(addedTorrentsIdMap.get(id));
            if (th != null) {
                if (th.isValid()) {
                    ret = true;
                    if (dir == QueuePosition.UP) {
                        th.queuePositionUp();
                    } else if (dir == QueuePosition.DOWN) {
                        th.queuePositionDown();
                    } else if (dir == QueuePosition.TOP) {
                        th.queuePositionTop();
                    } else if (dir == QueuePosition.BOTTOM) {
                        th.queuePositionBottom();
                    }
                }
            }
            return aneHelper.getFREObject(ret);
        }
    }

    private class setFilePriority implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            final String id = aneHelper.getString(freObjects[0]);
            final int index = aneHelper.getInt(freObjects[1]);
            final int priority = aneHelper.getInt(freObjects[2]);
            Boolean ret = false;
            TorrentHandle th = ltsession.findTorrent(addedTorrentsIdMap.get(id));
            if (id != null) {
                if (th.isValid()) {
                    ret = true;
                    Priority p = Priority.fromSwig(priority);
                    th.setFilePriority(index, p);
                }
            }
            return aneHelper.getFREObject(ret);
        }
    }

    private class setPiecePriority implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            final String id = aneHelper.getString(freObjects[0]);
            final int index = aneHelper.getInt(freObjects[1]);
            final int priority = aneHelper.getInt(freObjects[2]);
            Boolean ret = false;
            TorrentHandle th = ltsession.findTorrent(addedTorrentsIdMap.get(id));
            if (th != null) {
                if (th.isValid()) {
                    ret = true;
                    Priority p = Priority.fromSwig(priority);
                    th.piecePriority(index, p);
                }
            }
            return aneHelper.getFREObject(ret);
        }
    }

    private class resetPieceDeadline implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            final String id = aneHelper.getString(freObjects[0]);
            final int index = aneHelper.getInt(freObjects[1]);
            Boolean ret = false;
            TorrentHandle th = ltsession.findTorrent(addedTorrentsIdMap.get(id));
            if (th != null) {
                if (th.isValid() && th.getStatus().hasMetadata()) {
                    ret = true;
                    th.resetPieceDeadline(index);
                }
            }
            return aneHelper.getFREObject(ret);
        }
    }

    private class setPieceDeadline implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            final String id = aneHelper.getString(freObjects[0]);
            final int index = aneHelper.getInt(freObjects[1]);
            final int deadline = aneHelper.getInt(freObjects[2]);
            Boolean ret = false;
            TorrentHandle th = ltsession.findTorrent(addedTorrentsIdMap.get(id));
            if (th != null) {
                if (th.isValid() && th.getStatus().hasMetadata()) {
                    ret = true;
                    th.setPieceDeadline(index, deadline);
                }
            }
            return aneHelper.getFREObject(ret);
        }
    }

    private class setSequentialDownload implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            final String id = aneHelper.getString(freObjects[0]);
            final Boolean isSequential = aneHelper.getBool(freObjects[1]);
            Boolean ret = false;
            TorrentHandle th = ltsession.findTorrent(addedTorrentsIdMap.get(id));
            if (th != null) {
                th.setSequentialDownload(isSequential);
                if (!isSequential) {
                    ret = true;
                    th.clearPieceDeadlines();
                }
            }
            return aneHelper.getFREObject(ret);
        }
    }

    private class pauseTorrent implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            final String id = aneHelper.getString(freObjects[0]);
            Boolean ret = false;
            TorrentHandle th = ltsession.findTorrent(addedTorrentsIdMap.get(id));
            if (id != null) {
                ret = true;
                th.setAutoManaged(false);
                th.pause();
                if (th.getStatus().hasMetadata() && th.getStatus().needSaveResume())
                    th.saveResumeData();
            }
            return aneHelper.getFREObject(ret);
        }
    }

    private class resumeTorrent implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            final String id = aneHelper.getString(freObjects[0]);
            Boolean ret = false;
            TorrentHandle th = ltsession.findTorrent(addedTorrentsIdMap.get(id));
            if (th != null) {
                ret = true;
                th.resume();
                th.setAutoManaged(true);
            }
            return aneHelper.getFREObject(ret);
        }
    }

    private class getMagnetURI implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            final String id = aneHelper.getString(freObjects[0]);
            String ret = null;
            if (id != null) {
                TorrentHandle th = ltsession.findTorrent(addedTorrentsIdMap.get(id));
                ret = th.makeMagnetUri();
            }
            return aneHelper.getFREObject(ret);
        }
    }

    private class removeTorrent implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            final String id = aneHelper.getString(freObjects[0]);
            Boolean ret = false;
            TorrentHandle th = ltsession.findTorrent(addedTorrentsIdMap.get(id));
            if (th != null) {
                ret = true;
                ltsession.removeTorrent(th);
                String hash = addedTorrentsIdMap.get(id).toString();
                addedTorrentsIdMap.remove(id);
                addedTorrentsHashMap.remove(hash);
            }
            return aneHelper.getFREObject(ret);
        }
    }

    private class postTorrentUpdates implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            libTorrentHandler.post(new Runnable() {
                @Override
                public void run() {
                    ltsession.swig().post_torrent_updates(statusFlags);
                }
            });
            return null;
        }
    }

    private class forceRecheck implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            final String id = aneHelper.getString(freObjects[0]);
            Boolean ret = false;
            TorrentHandle th = ltsession.findTorrent(addedTorrentsIdMap.get(id));
            if (th != null) {
                ret = true;
                th.forceRecheck();
                th.saveResumeData();
            }
            return aneHelper.getFREObject(ret);
        }
    }

    private class forceAnnounce implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            final String id = aneHelper.getString(freObjects[0]);
            final int trackerIndex = aneHelper.getInt(freObjects[1]);
            Boolean ret = false;
            TorrentHandle th = ltsession.findTorrent(addedTorrentsIdMap.get(id));
            if (th != null) {
                ret = true;
                th.forceReannounce(0, trackerIndex);
            }
            return aneHelper.getFREObject(ret);
        }
    }

    private class forceDHTAnnounce implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            final String id = aneHelper.getString(freObjects[0]);
            Boolean ret = false;
            TorrentHandle th = ltsession.findTorrent(addedTorrentsIdMap.get(id));
            if (th != null) {
                ret = true;
                th.forceDHTAnnounce();
            }
            return aneHelper.getFREObject(ret);
        }
    }

    private byte[] getBytesFromInputStream(InputStream inputStream) throws IOException {
        ByteArrayOutputStream byteBuffer = new ByteArrayOutputStream();

        int bufferSize = 1024;
        byte[] buffer = new byte[bufferSize];

        int len;
        while ((len = inputStream.read(buffer)) != -1) {
            byteBuffer.write(buffer, 0, len);
        }

        return byteBuffer.toByteArray();
    }

    private int randomInteger(int min, int max) {
        Random rand = new Random();
        return rand.nextInt((max - min) + 1) + min;
    }

    private void trace(String msg) {
        if (logLevel > LogLevel.QUIET) {
            Log.i("com.tuarua.BT", String.valueOf(msg));
            dispatchStatusEventAsync(msg, "TRACE");
        }

    }

    private void trace(int msg) {
        if (logLevel > LogLevel.QUIET) {
            Log.i("com.tuarua.BT", String.valueOf(msg));
            dispatchStatusEventAsync(String.valueOf(msg), "TRACE");
        }
    }

    private void trace(boolean msg) {
        if (logLevel > LogLevel.QUIET) {
            Log.i("com.tuarua.BT", String.valueOf(msg));
            dispatchStatusEventAsync(String.valueOf(msg), "TRACE");
        }
    }

    private class saveSessionState implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            byte[] data = ltsession.saveState();
            try {
                FileOutputStream fileOutputStream = new FileOutputStream(TorrentSettings.storage.sessionStatePath + "/.ses_state");
                fileOutputStream.write(data);
                fileOutputStream.close();
            } catch (IOException e) {
                trace(e.getMessage());
                e.printStackTrace();
            }
            return null;
        }
    }


    private class getTorrentTrackers implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            final String queryId = aneHelper.getString(freObjects[0]);
            libTorrentHandler.post(new Runnable() {
                @Override
                public void run() {
                    String queryHash = "";
                    if (queryId != null && !queryId.isEmpty()) {
                        Sha1Hash tmpHash = addedTorrentsIdMap.get(queryId);
                        if (tmpHash != null)
                            queryHash = addedTorrentsIdMap.get(queryId).toString();
                    }

                    JSONArray jsonTorrentArr = new JSONArray();
                    JSONObject jsonTorrent;
                    JSONArray jsonTrackersArr;
                    JSONObject jsonTracker;

                    ArrayList<TorrentHandle> tv = ltsession.getTorrents();
                    TorrentHandle th;
                    String id;
                    String hash;
                    TorrentInfo ti;


                    for (int i = 0; i < tv.size(); i++) {
                        jsonTrackersArr = new JSONArray();
                        th = tv.get(i);
                        ti = th.getTorrentInfo();
                        id = addedTorrentsHashMap.get(th.getInfoHash().toString()).toLowerCase();
                        hash = th.getInfoHash().toString();
                        if (queryHash != null && !queryHash.isEmpty() && hash.compareTo(queryHash) != 0)
                            continue;

                        int numDHT = 0;
                        int numPEX = 0;
                        int numLSD = 0;
                        ArrayList<PeerInfo> arrayList = th.peerInfo();
                        PeerInfo pi;
                        long flags;
                        long source;
                        for (int j = 0; j < arrayList.size(); j++) {
                            pi = arrayList.get(j);
                            flags = pi.getSwig().getFlags();
                            source = pi.getSwig().getSource();
                            if (hasBit(flags, (long) peer_info.peer_flags_t.handshake.swigValue()) || hasBit(flags, (long) peer_info.peer_flags_t.connecting.swigValue()))
                                continue;
                            if (hasBit(source, (long) peer_info.peer_source_flags.pex.swigValue()))
                                ++numPEX;
                            if (hasBit(source, (long) peer_info.peer_source_flags.dht.swigValue()))
                                ++numDHT;
                            if (hasBit(source, (long) peer_info.peer_source_flags.lsd.swigValue()))
                                ++numLSD;
                        }

                        try {
                            jsonTracker = new JSONObject();
                            jsonTracker.put("url", "**[DHT]**");
                            jsonTracker.put("status", (TorrentSettings.privacy.useDHT && !ti.isPrivate()) ? "Working" : "Disabled");
                            jsonTracker.put("message", (ti.isPrivate()) ? "This torrent is private" : "");
                            jsonTracker.put("numPeers", numDHT);
                            jsonTracker.put("tier", 0);
                            jsonTrackersArr.put(jsonTracker);

                            jsonTracker = new JSONObject();
                            jsonTracker.put("url", "**[PeX]**");
                            jsonTracker.put("status", (TorrentSettings.privacy.usePEX && !ti.isPrivate()) ? "Working" : "Disabled");
                            jsonTracker.put("message", (ti.isPrivate()) ? "This torrent is private" : "");
                            jsonTracker.put("numPeers", numPEX);
                            jsonTracker.put("tier", 0);
                            jsonTrackersArr.put(jsonTracker);

                            jsonTracker = new JSONObject();
                            jsonTracker.put("url", "**[LSD]**");
                            jsonTracker.put("status", (TorrentSettings.privacy.useLSD && !ti.isPrivate()) ? "Working" : "Disabled");
                            jsonTracker.put("message", (ti.isPrivate()) ? "This torrent is private" : "");
                            jsonTracker.put("numPeers", numLSD);
                            jsonTracker.put("tier", 0);
                            jsonTrackersArr.put(jsonTracker);


                            ArrayList<AnnounceEntry> trackers = ti.trackers();
                            AnnounceEntry an;

                            //to prevent duplicates
                            ArrayList<String> existingTrackers = new ArrayList<>();
                            for (int j = 0; j < trackers.size(); j++) {
                                an = trackers.get(j);
                                if (existingTrackers.indexOf(an.url()) > -1)
                                    continue;

                                existingTrackers.add(an.url());

                                jsonTracker = new JSONObject();
                                jsonTracker.put("url", an.url());

                                if (an.swig().getVerified()) {
                                    jsonTracker.put("status", "Working");
                                    jsonTracker.put("message", "");
                                } else if (an.swig().getUpdating() && an.swig().getFails() == 0) {
                                    jsonTracker.put("status", "Updating");
                                    jsonTracker.put("message", "");
                                } else if (an.swig().getFails() > 0) {
                                    jsonTracker.put("status", "Not Working");
                                    jsonTracker.put("message", an.message());
                                } else {
                                    jsonTracker.put("status", "Not contacted yet");
                                    jsonTracker.put("message", "");
                                }

                                Map<String, Integer> t = torrentTrackerPeerMap.get(id);
                                if (t != null) {
                                    Integer np = t.get(an.url());
                                    if (np != null)
                                        jsonTracker.put("numPeers", np);
                                    else
                                        jsonTracker.put("numPeers", 0);
                                } else {
                                    jsonTracker.put("numPeers", 0);
                                }

                                jsonTracker.put("tier", an.tier());
                                jsonTrackersArr.put(jsonTracker);

                            }
                        } catch (JSONException e) {
                            trace(e.getMessage());
                            e.printStackTrace();
                        }

                        jsonTorrent = new JSONObject();
                        try {
                            jsonTorrent.put("id", id);
                            jsonTorrent.put("trackersInfo", jsonTrackersArr);
                        } catch (JSONException e) {
                            trace(e.getMessage());
                            e.printStackTrace();
                        }
                        jsonTorrentArr.put(jsonTorrent);
                    }
                    dispatchStatusEventAsync(jsonTorrentArr.toString(), FRETorrentEvent.TRACKERS_FROM_JSON);
                }
            });

            return null;
        }
    }

    private class addTracker implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            final String id = aneHelper.getString(freObjects[0]);
            final String url = aneHelper.getString(freObjects[1]);
            Boolean ret = false;
            TorrentHandle th = ltsession.findTorrent(addedTorrentsIdMap.get(id));
            if (th != null && th.isValid()) {
                th.addTracker(new AnnounceEntry(url));
                ret = true;
            }
            return aneHelper.getFREObject(ret);
        }
    }

    private class addUrlSeed implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            final String id = aneHelper.getString(freObjects[0]);
            final String url = aneHelper.getString(freObjects[1]);
            Boolean ret = false;
            TorrentHandle th = ltsession.findTorrent(addedTorrentsIdMap.get(id));
            if (th != null && th.isValid()) {
                th.addUrlSeed(url);
                ret = true;
            }
            return aneHelper.getFREObject(ret);
        }
    }

    private class removeUrlSeed implements FREFunction {
        @Override
        public FREObject call(FREContext freContext, FREObject[] freObjects) {
            final String id = aneHelper.getString(freObjects[0]);
            final String url = aneHelper.getString(freObjects[1]);
            Boolean ret = false;
            TorrentHandle th = ltsession.findTorrent(addedTorrentsIdMap.get(id));
            if (th != null && th.isValid()) {
                th.removeUrlSeed(url);
                ret = true;
            }
            return aneHelper.getFREObject(ret);
        }
    }


}
