package com.tuarua {
import com.tuarua.torrent.PeerInfo;
import com.tuarua.torrent.TorrentInfo;
import com.tuarua.torrent.TorrentPeers;
import com.tuarua.torrent.TorrentPieces;
import com.tuarua.torrent.TorrentSettings;
import com.tuarua.torrent.TorrentStatus;
import com.tuarua.torrent.TorrentTracker;
import com.tuarua.torrent.TorrentTrackers;
import com.tuarua.torrent.TorrentWebSeed;
import com.tuarua.torrent.TorrentsLibrary;
import com.tuarua.torrent.events.TorrentAlertEvent;
import com.tuarua.torrent.events.TorrentInfoEvent;
import com.tuarua.torrent.utils.Magnet;
import com.tuarua.torrent.utils.MagnetBuilder;

import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.StatusEvent;
import flash.events.TimerEvent;
import flash.external.ExtensionContext;
import flash.filesystem.File;
import flash.utils.Timer;
import flash.system.Capabilities;


public class BitTorrentANE extends EventDispatcher {
    private var extensionContext:ExtensionContext;
    private var _inited:Boolean = false;
    private var statusTimer:Timer;
    private var peersTimer:Timer;
    private var trackersTimer:Timer;
    private var _statusUpdateInterval:int = 1000;
    private var _peersUpdateInterval:int = 2000;
    private var _trackersUpdateInterval:int = 5000;

    private var _queryForPeers:Boolean = false;
    private var _queryForPeersFlags:Boolean = false;
    private var _queryPeersForTorrentId:String = "";

    private var _queryForTrackers:Boolean = false;
    private var _queryForTrackersAsync:Boolean = false;
    private var _queryTrackersForTorrentId:String = "";
    /**
     * This method is omitted from the output. * * @private
     */
    public static var TRACKERS_FROM_JSON:String = "Torrent.Trackers.FromJSON";
    /**
     * This method is omitted from the output. * * @private
     */
    public static var PEERS_FROM_JSON:String = "Torrent.Peers.FromJSON";

    public function BitTorrentANE(target:IEventDispatcher = null) {
        initiate();
    }

    private function initiate():void {
        trace("[BitTorrentANE] Initalizing ANE...");
        try {
            extensionContext = ExtensionContext.createExtensionContext("com.tuarua.BitTorrentANE", null);
            extensionContext.addEventListener(StatusEvent.STATUS, gotEvent);
        } catch (e:Error) {
            trace("[BitTorrentANE] ANE Not loaded properly.  Future calls will fail.");
        }
    }

    private function gotEvent(event:StatusEvent):void {
        var tp:TorrentPieces;
        var pObj:Object;
        switch (event.level) {
            case "TRACE":
                trace("[BitTorrentANE]", event.code);
                break;
            case "INFO":
                trace("INFO:", event.code);
                break;

                //android only ?
            case TRACKERS_FROM_JSON:
                pObj = JSON.parse(event.code);

                if (pObj) {
                    TorrentsLibrary.updateTrackersFromJSON(pObj);
                    this.dispatchEvent(new TorrentAlertEvent(TorrentAlertEvent.TRACKERS_UPDATE, {id: _queryTrackersForTorrentId}));
                }
                break;

            case PEERS_FROM_JSON:
                pObj = JSON.parse(event.code);
                if (pObj) {
                    TorrentsLibrary.updatePeersFromJSON(pObj);
                    this.dispatchEvent(new TorrentAlertEvent(TorrentAlertEvent.PEERS_UPDATE, {id: _queryPeersForTorrentId}));
                }
                break;

            case TorrentAlertEvent.LISTEN_SUCCEEDED:
                pObj = JSON.parse(event.code);
                this.dispatchEvent(new TorrentAlertEvent(TorrentAlertEvent.LISTEN_SUCCEEDED, pObj));
                break;

            case TorrentAlertEvent.LISTEN_FAILED:
                pObj = JSON.parse(event.code);
                this.dispatchEvent(new TorrentAlertEvent(TorrentAlertEvent.LISTEN_FAILED, pObj));
                break;

            case TorrentAlertEvent.STATE_UPDATE:
                pObj = JSON.parse(event.code);
                //trace(TorrentAlertEvent.STATE_UPDATE);
                //trace(event.code);
                if (pObj) {
                    TorrentsLibrary.updateStatusFromJSON(pObj);
                    this.dispatchEvent(new TorrentAlertEvent(TorrentAlertEvent.STATE_UPDATE, null));
                }
                break;

            case TorrentAlertEvent.TORRENT_CHECKED:
            case TorrentAlertEvent.SAVE_RESUME_DATA:
                pObj = JSON.parse(event.code);
                this.dispatchEvent(new TorrentAlertEvent(event.level, pObj));
                break;

            case TorrentAlertEvent.FILE_COMPLETED:
                pObj = JSON.parse(event.code);
                this.dispatchEvent(new TorrentAlertEvent(TorrentAlertEvent.FILE_COMPLETED, pObj));
                break;

            case TorrentAlertEvent.TORRENT_FINISHED:
                pObj = JSON.parse(event.code);
                (TorrentsLibrary.status[pObj.id] as TorrentStatus).isFinished = true;
                this.dispatchEvent(new TorrentAlertEvent(TorrentAlertEvent.TORRENT_FINISHED, pObj));
                break;

            case TorrentAlertEvent.TORRENT_ADDED:
                pObj = JSON.parse(event.code);
                startStatusTimer();
                if (_queryForPeers && (peersTimer == null || !peersTimer.running))
                    startPeersTimer();

                if (_queryForTrackers && (trackersTimer == null || !trackersTimer.running))
                    startTrackersTimer();

                this.dispatchEvent(new TorrentAlertEvent(TorrentAlertEvent.TORRENT_ADDED, pObj));
                break;

            case TorrentAlertEvent.TORRENT_PAUSED:
            case TorrentAlertEvent.TORRENT_RESUMED:
            case TorrentAlertEvent.STATE_CHANGED:
                pObj = JSON.parse(event.code);
                var ts:TorrentStatus = (TorrentsLibrary.status[pObj.id] as TorrentStatus);
                if (ts)
                    ts.state = pObj.state;
                this.dispatchEvent(new TorrentAlertEvent(event.level, pObj));
                break;

            case TorrentInfoEvent.FILTER_LIST_ADDED:
                this.dispatchEvent(new TorrentInfoEvent(TorrentInfoEvent.FILTER_LIST_ADDED, JSON.parse(event.code)));
                break;

            case TorrentAlertEvent.PIECE_FINISHED:
                pObj = JSON.parse(event.code);
                tp = TorrentsLibrary.pieces[pObj.id] as TorrentPieces;
                if (tp) {
                    tp.setDownloaded(pObj.index);
                    tp.setTime(pObj.index, pObj.time);
                }
                this.dispatchEvent(new TorrentAlertEvent(TorrentAlertEvent.PIECE_FINISHED, pObj));
                break;

            case TorrentAlertEvent.METADATA_RECEIVED:
                try {
                    pObj = JSON.parse(event.code);
                    if (pObj && pObj.hasOwnProperty("id") && pObj.id) {
                        var torrentFile:File = File.applicationDirectory.resolvePath(TorrentSettings.storage.torrentPath).resolvePath(pObj.id + ".torrent");
                        if (torrentFile.exists)
                            addTorrent(pObj.id, torrentFile.nativePath, "", "", pObj.isSequential);
                    }
                } catch (e:Error) {
                    trace(e.message);
                }
                break;

            case TorrentInfoEvent.ON_ERROR:
                trace(event.code);
                this.dispatchEvent(new TorrentInfoEvent(TorrentInfoEvent.ON_ERROR, {message: event.code}));
                break;

            case TorrentInfoEvent.TORRENT_CREATION_PROGRESS:
                this.dispatchEvent(new TorrentInfoEvent(TorrentInfoEvent.TORRENT_CREATION_PROGRESS, JSON.parse(event.code)));
                break;
            case TorrentInfoEvent.TORRENT_CREATED:
                this.dispatchEvent(new TorrentInfoEvent(TorrentInfoEvent.TORRENT_CREATED, JSON.parse(event.code)));
                break;
        }
    }

    /**
     *
     *
     */
    public function postTrackersUpdate():void {
        var vecTrackers:Vector.<TorrentTrackers> = extensionContext.call("getTorrentTrackers", _queryTrackersForTorrentId) as Vector.<TorrentTrackers>;
        if (vecTrackers) {
            for (var i:int = 0, l:int = vecTrackers.length; i < l; ++i)
                TorrentsLibrary.updateTrackers(vecTrackers[i].id, vecTrackers[i]);
            this.dispatchEvent(new TorrentAlertEvent(TorrentAlertEvent.TRACKERS_UPDATE, {id: _queryTrackersForTorrentId}));
        }

    }

    /**
     *
     *
     */
    public function postPeersUpdate():void {
        var vecPeers:Vector.<TorrentPeers> = extensionContext.call("getTorrentPeers", _queryPeersForTorrentId, _queryForPeersFlags) as Vector.<TorrentPeers>;
        if (vecPeers) {
            for (var i:int = 0, l:int = vecPeers.length; i < l; ++i)
                TorrentsLibrary.updatePeers(vecPeers[i].id, vecPeers[i]);
            this.dispatchEvent(new TorrentAlertEvent(TorrentAlertEvent.PEERS_UPDATE, {id: _queryPeersForTorrentId}));
        }
    }

    /**
     *
     * @param url
     *
     */
    public function addDHTRouter(url:String):void {
        extensionContext.call("addDHTRouter", url);
    }

    /**
     *
     * @return
     *
     */
    public function initSession():Boolean {
        _inited = extensionContext.call("initSession");
        return _inited;
    }

    /**
     *
     *
     */
    public function saveSessionState():void {
        extensionContext.call("saveSessionState");
    }

    /**
     *
     *
     */
    public function endSession():void {
        extensionContext.call("endSession");
        _inited = false;
    }

    /**
     *
     * @param filename
     * @return
     *
     */
    public function getTorrentInfo(filename:String):TorrentInfo {
        var torrentInfo:TorrentInfo;
        if (extensionContext)
            torrentInfo = extensionContext.call("getTorrentInfo", filename) as TorrentInfo;
        return torrentInfo;
    }

    /**
     *
     * @param id
     * @param value
     *
     */
    public function setSequentialDownload(id:String, value:Boolean):void {
        if (extensionContext) {
            var success:Boolean = extensionContext.call("setSequentialDownload", id, value);
            if (success)
                TorrentsLibrary.status[id.toLowerCase()].isSequential = value;
        }
    }

    /**
     *
     * @param id
     * @return
     *
     */
    public function pauseTorrent(id:String):Boolean {
        var ret:Boolean = false;
        if (extensionContext)
            ret = extensionContext.call("pauseTorrent", id.toLowerCase());
        return ret;
    }

    /**
     *
     * @param id
     * @return
     *
     */
    public function resumeTorrent(id:String):Boolean {
        var ret:Boolean = false;
        if (extensionContext)
            ret = extensionContext.call("resumeTorrent", id.toLowerCase());
        return ret;
    }

    /**
     *
     * @param id
     *
     */
    public function forceRecheck(id:String):void {
        if (extensionContext)
            extensionContext.call("forceRecheck", id.toLowerCase());
    }

    /**
     *
     * @param id
     * @param trackerIndex
     *
     */
    public function forceAnnounce(id:String, trackerIndex:int = -1):void {
        if (extensionContext)
            extensionContext.call("forceAnnounce", id.toLowerCase(), trackerIndex);
    }

    /**
     *
     * @param id
     *
     */
    public function forceDHTAnnounce(id:String):void {
        if (extensionContext)
            extensionContext.call("forceDHTAnnounce", id.toLowerCase());
    }

    /**
     *
     * @param id
     * @param index
     * @param priority
     *
     */
    public function setPiecePriority(id:String, index:uint, priority:int):void {
        if (extensionContext)
            extensionContext.call("setPiecePriority", id.toLowerCase(), index, priority);
    }

    /**
     *
     * @param id
     * @param index
     * @param deadline
     *
     */
    public function setPieceDeadline(id:String, index:uint, deadline:int):void {//deadline is in milliseconds
        if (extensionContext)
            extensionContext.call("setPieceDeadline", id.toLowerCase(), index, deadline);
    }

    /**
     *
     * @param id
     * @param index
     *
     */
    public function resetPieceDeadline(id:String, index:uint):void {
        if (extensionContext) {
            extensionContext.call("resetPieceDeadline", id.toLowerCase(), index);
        }

    }

    /**
     *
     * @param id
     * @param url
     *
     */
    public function addTracker(id:String, url:String):void {
        if (extensionContext)
            extensionContext.call("addTracker", id.toLowerCase(), url);
    }

    /**
     *
     * @param id
     * @param url
     *
     */
    public function addUrlSeed(id:String, url:String):void {
        if (extensionContext)
            extensionContext.call("addUrlSeed", id.toLowerCase(), url);
    }

    /**
     *
     * @param id
     * @param url
     *
     */
    public function removeUrlSeed(id:String, url:String):void {
        if (extensionContext)
            extensionContext.call("removeUrlSeed", id.toLowerCase(), url);
    }

    /**
     *
     * @param id
     * @return
     *
     */
    public function getMagnetURI(id:String):String {
        var ret:String;
        if (extensionContext)
            ret = extensionContext.call("getMagnetURI", id.toLowerCase()) as String;
        return ret;
    }

    /**
     *
     * @param id
     * @param direction
     *
     */
    public function setQueuePosition(id:String, direction:int):void {
        if (extensionContext)
            extensionContext.call("setQueuePosition", id.toLowerCase(), direction);
    }

    /**
     *
     * @param id
     *
     */
    public function removeTorrent(id:String):void {
        TorrentsLibrary.remove(id.toLocaleLowerCase());
        if (extensionContext)
            extensionContext.call("removeTorrent", id.toLowerCase());
    }

    /**
     *
     *
     */
    public function postTorrentUpdates():void {
        if (extensionContext)
            extensionContext.call("postTorrentUpdates");
    }

    /**
     *
     *
     */
    public function getTorrentTrackers():void {
        if (extensionContext) {
            var vecTrackers:Vector.<TorrentTrackers> = extensionContext.call("getTorrentTrackers") as Vector.<TorrentTrackers>;
            for (var i:int = 0, l:int = vecTrackers.length; i < l; ++i)
                TorrentsLibrary.updateTrackers(vecTrackers[i].id, vecTrackers[i]);
        }
    }

    /**
     *
     * @param id
     * @param url
     * @param hash
     * @param name
     * @param sequential
     * @param trackers
     * @param webSeeds
     * @param seedMode
     *
     */
    public function addTorrent(id:String, url:String = "", hash:String = "", name:String = "", sequential:Boolean = false,
                               trackers:Vector.<TorrentTracker> = null, webSeeds:Vector.<TorrentWebSeed> = null,
                               seedMode:Boolean = false):void {//trackers and webseeds ignored if url is passed
        var torrentInfo:TorrentInfo;
        var _id:String = id.toLowerCase();
        var _hash:String = hash.toLowerCase();
        if (url == null || url == "") {
            var magnet:Magnet = new Magnet();
            magnet.name = name;
            magnet.hash = hash;
            extensionContext.call("addTorrent", _id, MagnetBuilder.getUri(magnet, trackers, webSeeds), _hash, sequential, seedMode) as TorrentInfo;
        } else if (url.indexOf("http") == 0) {
            var downloader:TorrentDownloader = new TorrentDownloader(_id, url, sequential);
            downloader.addEventListener(TorrentInfoEvent.TORRENT_DOWNLOADED, onFileDownloaded);
        } else {
            //if magnet check if we have the file already
            if (url.indexOf("magnet") == 0) {
                var file:File = new File(File.applicationDirectory.resolvePath(TorrentSettings.storage.torrentPath).resolvePath(_id + ".torrent").nativePath);
                if (file.exists)
                    url = File.applicationDirectory.resolvePath(TorrentSettings.storage.torrentPath).resolvePath(_id + ".torrent").nativePath;
            }
            torrentInfo = extensionContext.call("addTorrent", _id, url, _hash, sequential, seedMode) as TorrentInfo;
            if (torrentInfo) {
                TorrentsLibrary.add(_id, torrentInfo);
                var tp:TorrentPieces = new TorrentPieces(torrentInfo.numPieces);
                TorrentsLibrary.updatePieces(_id, tp);
            }
        }
    }

    private function onFileDownloaded(event:TorrentInfoEvent):void {
        addTorrent(event.params.id, event.params.filename, "", "", event.params.sequential);
    }


    //pieceSize is in KiB

    /**
     *
     * @param input
     * @param output
     * @param pieceSize
     * @param trackers
     * @param webSeeds
     * @param isPrivate
     * @param comment
     * @param seedNow
     * @param rootCert
     *
     */
    public function createTorrent(input:String, output:String, pieceSize:int, trackers:Vector.<TorrentTracker>,
                                  webSeeds:Vector.<TorrentWebSeed>, isPrivate:Boolean = false, comment:String = null,
                                  seedNow:Boolean = false, rootCert:String = null):void {
        if (Capabilities.os.toLowerCase().indexOf("windows") == -1 && Capabilities.os.toLowerCase().indexOf("mac") == -1)
            throw new Error("this method is not yet available for Android");

        if (pieceSize % 16 > 0)
            throw new Error("pieceSize must be a multiple of 16");
        extensionContext.call("createTorrent", input, output, trackers, webSeeds, pieceSize, isPrivate, comment, seedNow, rootCert);
    }

    /**
     *
     * @return
     *
     */
    public function isSupported():Boolean {
        return extensionContext.call("isSupported");
    }

    /**
     *
     *
     */
    public function updateSettings():void {
        extensionContext.call("updateSettings", TorrentSettings);
    }

    /**
     *
     * @param filename
     * @param applyToTrackers
     *
     */
    public function addFilterList(filename:String, applyToTrackers:Boolean):void {
        var validFile:Boolean;
        var check:String = ".p2p";
        var end:int = filename.lastIndexOf(check);
        validFile = (end == -1);
        validFile = (end == filename.length - check.length);
        validFile = new File(filename).exists;
        if (validFile)
            extensionContext.call("addFilterList", filename, applyToTrackers);
        else
            this.dispatchEvent(new TorrentInfoEvent(TorrentInfoEvent.ON_ERROR, {message: "only .p2p filters are allowed and file must exist"}));
    }

    /**
     *
     * @param id
     * @param index
     * @param priority
     *
     */
    public function setFilePriority(id:String, index:int, priority:int):void {
        extensionContext.call("setFilePriority", id.toLowerCase(), index, priority);
    }

    /**
     *
     *
     */
    public function dispose():void {

        //remove listeners
        stopStatusTimer();
        stopPeersTimer();
        stopTrackersTimer();

        if (!extensionContext) {
            trace("[BitTorrentANE] Error. ANE Already in a disposed or failed state...");
            return;
        }
        trace("[BitTorrentANE] Unloading ANE...");
        extensionContext.removeEventListener(StatusEvent.STATUS, gotEvent);
        extensionContext.dispose();
        extensionContext = null;
    }

    /**
     *
     * @return
     *
     */
    public function get inited():Boolean {
        return _inited;
    }

    private function onPeersTimer(event:TimerEvent):void {
        postPeersUpdate();
    }

    private function onTrackersTimer(event:TimerEvent):void {
        postTrackersUpdate();
    }

    private function startStatusTimer():void {
        if (statusTimer == null) {
            statusTimer = new Timer(_statusUpdateInterval);
            statusTimer.addEventListener(TimerEvent.TIMER, onStatusTimer);
            statusTimer.start();
        }
    }

    private function stopStatusTimer():void {
        if (statusTimer) {
            statusTimer.removeEventListener(TimerEvent.TIMER, onStatusTimer);
            statusTimer.stop();
            statusTimer.reset();
            statusTimer = null;
        }
    }

    private function startPeersTimer():void {
        if (peersTimer == null) {
            peersTimer = new Timer(_peersUpdateInterval);
            peersTimer.addEventListener(TimerEvent.TIMER, onPeersTimer);
            peersTimer.start();
        }
    }

    private function stopPeersTimer():void {
        if (peersTimer) {
            peersTimer.removeEventListener(TimerEvent.TIMER, onPeersTimer);
            peersTimer.stop();
            peersTimer.reset();
            peersTimer = null;
        }
    }

    private function onStatusTimer(event:TimerEvent):void {
        postTorrentUpdates();
    }


    private function startTrackersTimer():void {
        if (trackersTimer == null) {
            trackersTimer = new Timer(_trackersUpdateInterval);
            trackersTimer.addEventListener(TimerEvent.TIMER, onTrackersTimer);
            trackersTimer.start();
        }
    }

    private function stopTrackersTimer():void {
        if (trackersTimer) {
            trackersTimer.removeEventListener(TimerEvent.TIMER, onTrackersTimer);
            trackersTimer.stop();
            trackersTimer.reset();
            trackersTimer = null;
        }
    }

    /**
     *
     * @param value
     *
     */
    public function set statusUpdateInterval(value:int):void {
        _statusUpdateInterval = value;
    }

    /**
     *
     * @param value
     *
     */
    public function set peersUpdateInterval(value:int):void {
        _peersUpdateInterval = value;
    }

    /**
     *
     * @param value
     * @param id
     * @param flags
     *
     */
    public function queryForPeers(value:Boolean, id:String = "", flags:Boolean = false):void {
        _queryForPeers = value;
        _queryPeersForTorrentId = id.toLowerCase();
        _queryForPeersFlags = flags;
        if (_queryForPeers) {
            if (peersTimer == null || !peersTimer.running)
                startPeersTimer();
            postPeersUpdate();
        } else {
            if (peersTimer)
                stopPeersTimer();
        }
    }

    /**
     *
     * @param value
     *
     */
    public function set trackersUpdateInterval(value:int):void {
        _trackersUpdateInterval = value;
    }

    /**
     *
     * @param value
     * @param id
     *
     */
    public function queryForTrackers(value:Boolean, id:String = ""):void {
        _queryForTrackers = value;
        _queryTrackersForTorrentId = id.toLowerCase();
        if (_queryForTrackers) {
            if (trackersTimer == null || !trackersTimer.running)
                startTrackersTimer();
            postTrackersUpdate();
        } else {
            if (trackersTimer)
                stopTrackersTimer();
        }
    }


}
}