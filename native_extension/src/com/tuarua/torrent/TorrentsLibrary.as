package com.tuarua.torrent {
	import flash.utils.Dictionary;
	
	public class TorrentsLibrary{
		public static var info:Dictionary = new Dictionary();
		public static var status:Dictionary = new Dictionary();
		public static var pieces:Dictionary = new Dictionary();
		public static var peers:Dictionary = new Dictionary();
		public static var trackers:Dictionary = new Dictionary();
		public static function add(name:String,ti:TorrentInfo):void {
			if(info[name] == undefined){
				info[name] = ti;
				initStatus(name,ti);
				pieces[name] = null;
				peers[name] = null;
			}
		}
		private static function initStatus(name:String,ti:TorrentInfo):void {
			status[name] = new TorrentStatus();
			status[name].id = name;
			status[name].infoHash = ti.infoHash;
		}
		public static function remove(name:String):void {
			delete info[name];
			delete status[name];
			delete pieces[name];
			delete peers[name];
		}
		public static function updateStatus(name:String,ts:TorrentStatus):void {
			status[name] = ts;
		}
		
		public static function updateStatusFromJSON(json:Object):void {
			var statusInternal:TorrentStatus;
			var statusJSON:Object;
			for (var i:int=0, l:int=json.length; i<l; ++i){
				
				statusJSON = json[i];
				statusInternal = status[statusJSON.id];
				
				if(statusInternal == null)
					break;
				
				statusInternal.activeTime = statusJSON.activeTime;
				statusInternal.addedOn = statusJSON.addedOn;
				
				if(statusInternal.state == TorrentStateCodes.DOWNLOADING && (info[statusJSON.id] as TorrentInfo).size > 0 
					&& statusJSON.allTimeDownload > 0 && statusJSON.downloadPayloadRate > 1024){
					statusInternal.ETA = Math.round(((info[statusJSON.id] as TorrentInfo).size - statusJSON.allTimeDownload)/statusJSON.downloadPayloadRate);
				}
				
				statusInternal.downloaded = statusJSON.downloaded;
				statusInternal.downloadedSession = statusJSON.downloadedSession;
				statusInternal.downloadRate = statusJSON.downloadRate;
				statusInternal.downloadRateAverage = statusJSON.downloadRateAverage;
				statusInternal.isSequential = statusJSON.isSequential;
				statusInternal.lastSeenComplete = statusJSON.lastSeenComplete;
				statusInternal.nextAnnounce = statusJSON.nextAnnounce;
				statusInternal.numConnections = statusJSON.numConnections;
				statusInternal.numPeers = statusJSON.numPeers;
				statusInternal.numPeersTotal = statusJSON.numPeersTotal;
				statusInternal.numPieces = statusJSON.numPieces;
				statusInternal.numSeeds = statusJSON.numSeeds;
				statusInternal.numSeedsTotal = statusJSON.numSeedsTotal;
				statusInternal.progress = statusJSON.progress;
				statusInternal.queuePosition = statusJSON.queuePosition;
				statusInternal.shareRatio = statusJSON.shareRatio;
				statusInternal.uploaded = statusJSON.uploaded;
				statusInternal.uploadedSession = statusJSON.uploadedSession;
				statusInternal.uploadRate = statusJSON.uploadRate;
				statusInternal.uploadRateAverage = statusJSON.uploadRateAverage;
				statusInternal.wasted = statusJSON.wasted;
				statusInternal.downloadMax = statusJSON.downloadMax;
				statusInternal.savePath = statusJSON.savePath;
				statusInternal.partialPieces = statusJSON.partialPieces;
				
				statusInternal.fileProgress = statusJSON.fileProgress;
				statusInternal.filePriority = statusJSON.filePriority;
				
			}
		}
		
		public static function updatePieces(name:String,tp:TorrentPieces):void {
			pieces[name] = tp;
		}
		public static function updatePeers(name:String,tp:TorrentPeers):void {
			peers[name] = tp;
		}
		public static function updateTrackers(name:String,tp:TorrentTrackers):void{
			trackers[name] = tp;
		}
		
		public static function updatePeersFromJSON(json:Object):void {
			var peersJSON:Object;
			for (var i:int=0, l:int=json.length; i<l; ++i){
				peersJSON = json[i];
				var torrentPeers:TorrentPeers = new TorrentPeers();
				torrentPeers.id = peersJSON.id;
				var peersInfo:Vector.<PeerInfo> = new Vector.<PeerInfo>()
				var peerInfo:PeerInfo;
				for (var j:int=0, l2:int=peersJSON.peersInfo.length; j<l2; ++j){
					peerInfo = new PeerInfo();
					peerInfo.client = peersJSON.peersInfo[j].client;
					peerInfo.country = peersJSON.peersInfo[j].country;
					peerInfo.connection = peersJSON.peersInfo[j].connection;
					peerInfo.downloaded = peersJSON.peersInfo[j].downloaded;
					peerInfo.downSpeed = peersJSON.peersInfo[j].downSpeed;
					if(peersJSON.peersInfo[j].flags){
						var pf:PeerFlags = new PeerFlags();
						pf.fromDHT = peersJSON.peersInfo[j].flags.fromDHT;
						pf.fromIncoming = peersJSON.peersInfo[j].flags.fromIncoming;
						pf.fromLSD = peersJSON.peersInfo[j].flags.fromLSD;
						pf.fromPEX = peersJSON.peersInfo[j].flags.fromPEX;
						pf.fromResumeData = peersJSON.peersInfo[j].flags.fromResumeData;
						pf.fromTracker = peersJSON.peersInfo[j].flags.fromTracker;
						pf.isChoked = peersJSON.peersInfo[j].flags.isChoked;
						pf.isEndGameMode = peersJSON.peersInfo[j].flags.isEndGameMode;
						pf.isHolePunched = peersJSON.peersInfo[j].flags.isHolePunched;
						pf.isInteresting = peersJSON.peersInfo[j].flags.isInteresting;
						pf.isLocalConnection = peersJSON.peersInfo[j].flags.isLocalConnection;
						pf.isOptimisticUnchoke = peersJSON.peersInfo[j].flags.isOptimisticUnchoke;
						pf.isPlainTextEncrypted = peersJSON.peersInfo[j].flags.isPlainTextEncrypted;
						pf.isRC4encrypted = peersJSON.peersInfo[j].flags.isRC4encrypted;
						pf.isRemoteChoked = peersJSON.peersInfo[j].flags.isRemoteChoked;
						pf.isSeed = peersJSON.peersInfo[j].flags.isSeed;
						pf.isSnubbed = peersJSON.peersInfo[j].flags.isSnubbed;
						pf.isUploadOnly = peersJSON.peersInfo[j].flags.isUploadOnly;
						pf.onParole = peersJSON.peersInfo[j].flags.onParole;
						pf.supportsExtensions = peersJSON.peersInfo[j].flags.supportsExtensions;
						peerInfo.flags = pf;
					}
					
					peerInfo.flagsAsString = peersJSON.peersInfo[j].flagsAsString;
					peerInfo.ip = peersJSON.peersInfo[j].ip;
					peerInfo.localPort = peersJSON.peersInfo[j].localPort;
					peerInfo.port = peersJSON.peersInfo[j].port;
					peerInfo.progress = peersJSON.peersInfo[j].progress;
					peerInfo.relevance = peersJSON.peersInfo[j].relevance;
					peerInfo.uploaded = peersJSON.peersInfo[j].uploaded;
					peerInfo.upSpeed = peersJSON.peersInfo[j].upSpeed;
					peersInfo.push(peerInfo);
				}
				torrentPeers.peersInfo = peersInfo;
				peers[peersJSON.id] = torrentPeers;
			}
		}
		
		public static function updateTrackersFromJSON(json:Object):void {
			var trackersJSON:Object;
			for (var i:int=0, l:int=json.length; i<l; ++i){
				trackersJSON = json[i];
				var torrentTrackers:TorrentTrackers = new TorrentTrackers();
				torrentTrackers.id = trackersJSON.id;
				var trackersInfo:Vector.<TrackerInfo> = new Vector.<TrackerInfo>()
				var trackerInfo:TrackerInfo;
				for (var j:int=0, l2:int=trackersJSON.trackersInfo.length; j<l2; ++j){
					trackerInfo = new TrackerInfo();
					trackerInfo.message = trackersJSON.trackersInfo[j].message;
					trackerInfo.numPeers = trackersJSON.trackersInfo[j].numPeers;
					trackerInfo.status = trackersJSON.trackersInfo[j].status;
					trackerInfo.url = trackersJSON.trackersInfo[j].url;
					trackersInfo.push(trackerInfo);
				}
				torrentTrackers.trackersInfo = trackersInfo;
				trackers[trackersJSON.id] = torrentTrackers;
			}
		}
		public static function length(dictionary:Dictionary):int {
			var n:int = 0;
			for (var key:* in dictionary)
				n++;
			return n;
		}
		
		
	}
}