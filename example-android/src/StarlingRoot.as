package {
	import com.tuarua.BitTorrentANE;
	import com.tuarua.torrent.PeerInfo;
	import com.tuarua.torrent.TorrentFileMeta;
	import com.tuarua.torrent.TorrentInfo;
	import com.tuarua.torrent.TorrentPeers;
	import com.tuarua.torrent.TorrentPieces;
	import com.tuarua.torrent.TorrentSettings;
	import com.tuarua.torrent.TorrentStateCodes;
	import com.tuarua.torrent.TorrentStatus;
	import com.tuarua.torrent.TorrentsLibrary;
	import com.tuarua.torrent.constants.LogLevel;
	import com.tuarua.torrent.constants.PiecePriority;
	import com.tuarua.torrent.events.TorrentAlertEvent;
	
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	import events.InstallEvent;
	
	import install.Installer;
	
	import model.SettingsLocalStore;
	
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import starling.utils.Align;
	
	import utils.TextUtils;
	
	public class StarlingRoot extends Sprite {
		private var bitTorrentANE:BitTorrentANE = new BitTorrentANE();
		
		private var starlingVideo:StarlingVideo = new StarlingVideo();
		
		private var baVec:Vector.<ByteArray> = new Vector.<ByteArray>;
		private var currentTorrentInfo:TorrentInfo;
		private var currentStatus:TorrentStatus;
		private var currentPieces:TorrentPieces;
		private var currentVideoFile:TorrentFileMeta;
		private var isVideoPlaying:Boolean = false;
		private var numRequiredPieces:int = 10;
		private var textHolder:Sprite = new Sprite();
		private var progressHolder:Sprite = new Sprite();
		private var peersTxt:TextField;
		private var seedsTxt:TextField;
		private var downTxt:TextField;
		private var doneTxt:TextField;
		private var sizeTxt:TextField;
		private var statusTxt:TextField;
		
		
		private var addBtn:Sprite;
		private var fontSize:int = 36;
		private var torrentUrl:String;
		private var torrentId:String = "88594aaacbde40ef3e2510c47374ec0aa396c08e";
		private var pieceBG:Quad;
		
		public function StarlingRoot() {
			super();
			
			bitTorrentANE.addEventListener(TorrentAlertEvent.STATE_UPDATE,onTorrentStateUpdate);
			bitTorrentANE.addEventListener(TorrentAlertEvent.STATE_CHANGED,onTorrentStateChanged);
			bitTorrentANE.addEventListener(TorrentAlertEvent.PIECE_FINISHED,onPieceFinished);
			bitTorrentANE.addEventListener(TorrentAlertEvent.TORRENT_ADDED,onTorrentAdded);
			bitTorrentANE.addEventListener(TorrentAlertEvent.TORRENT_FINISHED,onTorrentFinished);
			bitTorrentANE.addEventListener(TorrentAlertEvent.LISTEN_SUCCEEDED,onListenSucceded);
			bitTorrentANE.addEventListener(TorrentAlertEvent.LISTEN_FAILED,onListenFailed);
			
		}
		
		protected function onTorrentFinished(event:TorrentAlertEvent):void {
			trace(event);
		}
		
		protected function onTorrentAdded(event:TorrentAlertEvent):void {
			currentTorrentInfo = bitTorrentANE.getTorrentInfo(TorrentSettings.storage.torrentPath + "/bbb_sunflower_1080p_30fps_normal.mp4.torrent");
			sizeTxt.text = TextUtils.bytesToString(currentTorrentInfo.size);
			
			pieceBG = new Quad(currentTorrentInfo.numPieces*16,16,0x090909); //16 * number of pieces
			progressHolder.addChild(pieceBG);
			progressHolder.scaleX = (Starling.current.viewPort.width/1920 * 1720) / (currentTorrentInfo.numPieces*16);
		}
		
		protected function onPieceFinished(event:TorrentAlertEvent):void {
			trace("piece finished",event.params.index);
			var numMatches:int = 0;
			var hasAll:Boolean = false;
			var q:Quad;
			
			q = new Quad(16,16,0x0186B3);
			q.x = (event.params.index*16);
			
			progressHolder.addChild(q);
			
		}
		protected function onListenSucceded(event:TorrentAlertEvent):void {
			trace("Listening on",event.params.address+":"+event.params.port,event.params.type);
		}
		protected function onListenFailed(event:TorrentAlertEvent):void {
			trace("Failed on",event.params.address+":"+event.params.port,event.params.type);
			trace(event.params.message);
		}
		protected function onTorrentStateChanged(event:TorrentAlertEvent):void {
			trace(TorrentStateCodes.getMessageFromCode(event.params.state));
		}
		protected function onTorrentStateUpdate(event:TorrentAlertEvent):void {
			currentStatus = TorrentsLibrary.status[torrentId] as TorrentStatus;
			currentPieces = TorrentsLibrary.pieces[torrentId] as TorrentPieces;
			
			if(currentStatus){

				peersTxt.text = currentStatus.numPeers.toString();
				seedsTxt.text = currentStatus.numSeeds.toString();
				downTxt.text = TextUtils.bytesToString(currentStatus.downloadRate) + "/s";
				doneTxt.text = (currentStatus.progress >= 100) ? "100%" : currentStatus.progress.toFixed(1) + "%";
				statusTxt.text = TorrentStateCodes.getMessageFromCode(currentStatus.state);
				
				
				if(TorrentsLibrary.info[torrentId])
					currentVideoFile = TorrentsLibrary.info[torrentId].getFileByExtension(["mp4"]);
					
				if(currentVideoFile && currentStatus && currentPieces){
					if(!isVideoPlaying){
						numRequiredPieces = Math.ceil((currentVideoFile.lastPiece - currentVideoFile.firstPiece)/1000)*10;
						var initialPieces:Number = 0;
						if(currentPieces && currentPieces.pieces.length > 0){
							initialPieces = currentPieces.numSequential - currentVideoFile.firstPiece;
							if (currentPieces.pieces[currentVideoFile.lastPiece] == 1) initialPieces++;
						}
						if((initialPieces >= numRequiredPieces) || currentStatus.state == TorrentStateCodes.SEEDING || currentStatus.isFinished) {
							isVideoPlaying = true;
							Starling.current.skipUnchangedFrames = false;
							starlingVideo.loadVideo(File.applicationStorageDirectory.resolvePath("output").resolvePath(currentVideoFile.path).url);
						}
					}
				}
				
			}
			
			
			
		}
		
		private function onPlayTouch(event:TouchEvent):void {
			event.stopPropagation();
			var touch:Touch = event.getTouch(addBtn, TouchPhase.ENDED);
			if(touch && touch.phase == TouchPhase.ENDED)  {
				addBtn.visible = false;
				bitTorrentANE.queryForPeers(true,torrentId);
				bitTorrentANE.addTorrent(torrentId,torrentUrl,"","",true);
			}
		}
		
		public function start():void {
			addBtn = createButton("Start");
			addBtn.addEventListener(TouchEvent.TOUCH,onPlayTouch);
			model.SettingsLocalStore.load(true);
			if(Installer.isAppInstalled()){
				onInstallComplete();
			}else{
				Installer.dispatcher.addEventListener(InstallEvent.ON_INSTALL_COMPLETE,onInstallComplete);
				Installer.install();
			}
			
			starlingVideo.y = 0;
			
			var tfl:TextFormat = new TextFormat("Roboto-Medium", fontSize, 0xFFFFFF);
			tfl.horizontalAlign = Align.LEFT;
			tfl.verticalAlign = Align.TOP;
			
			var tfr:TextFormat = new TextFormat("Roboto-Medium", fontSize, 0xFFFFFF);
			tfr.horizontalAlign = Align.RIGHT;
			tfr.verticalAlign = Align.TOP;
			
			var statusLbl:TextField = new TextField(210, 50, "Status");
			statusTxt = new TextField(500, 50, "");
			
			statusTxt.format = statusLbl.format = tfl;
			statusTxt.x = statusLbl.x = 100;
			
			
			var sizeLbl:TextField = new TextField(210, 50, "Size");
			sizeTxt = new TextField(210, 50, "");
			sizeTxt.format = sizeLbl.format = tfr;
			sizeTxt.x = sizeLbl.x = 620;
			
			var doneLbl:TextField = new TextField(200, 50, "Done");
			doneTxt = new TextField(200, 50, "");
			doneTxt.format = doneLbl.format = tfr;
			doneTxt.x = doneLbl.x = 850;
			
			var downLbl:TextField = new TextField(230, 50, "Down Speed");
			downTxt = new TextField(230, 50, "");
			downTxt.format = downLbl.format = tfr;
			downTxt.x = downLbl.x = 1140;
			
			var seedsLbl:TextField = new TextField(140, 50, "Seeds");
			seedsTxt = new TextField(140, 50, "");
			seedsTxt.format = seedsLbl.format = tfr;
			seedsTxt.x = seedsLbl.x = 1470;
			
			
			var peersLbl:TextField = new TextField(140, 50, "Peers");
			peersTxt = new TextField(140, 50, "");
			peersTxt.format = peersLbl.format = tfr;
			peersTxt.x = peersLbl.x = 1680;
			
			seedsLbl.y = peersLbl.y = downLbl.y = sizeLbl.y = statusLbl.y = sizeLbl.y = doneLbl.y = 900;
			seedsTxt.y = peersTxt.y = downTxt.y = sizeTxt.y = statusTxt.y = sizeTxt.y = doneTxt.y = 960;
			
			textHolder.addChild(statusLbl);
			textHolder.addChild(sizeLbl);
			textHolder.addChild(doneLbl);
			textHolder.addChild(downLbl);
			textHolder.addChild(peersLbl);
			textHolder.addChild(seedsLbl);
			
			textHolder.addChild(statusTxt);
			textHolder.addChild(sizeTxt);
			textHolder.addChild(doneTxt);
			textHolder.addChild(downTxt);
			textHolder.addChild(peersTxt);
			textHolder.addChild(seedsTxt);
			
			textHolder.scaleY = textHolder.scaleX = Starling.current.viewPort.width/1920; 
			addChild(textHolder);
			
			progressHolder.x = 100;
			progressHolder.y = 850;
			
			addChild(progressHolder);
			
			
			addBtn.x = (Starling.current.viewPort.width-320)/2;
			addBtn.y = 200;
			addChild(addBtn);
			
			addChild(starlingVideo);
			
		}
		
		protected function onInstallComplete(event:InstallEvent=null):void {
			if(bitTorrentANE.isSupported()){
				TorrentSettings.logLevel = LogLevel.DEBUG;
				TorrentSettings.clientName = "BitTorrentANE_Android_Example";
				TorrentSettings.storage.torrentPath = File.applicationStorageDirectory.resolvePath("torrents").nativePath;
				
				TorrentSettings.storage.resumePath = File.applicationStorageDirectory.resolvePath("torrents").resolvePath("resume").nativePath; //path where we save our "faststart" resume files
				TorrentSettings.storage.geoipDataPath = File.applicationStorageDirectory.resolvePath("geoip").nativePath;
				TorrentSettings.storage.sessionStatePath = File.applicationStorageDirectory.resolvePath("session").nativePath;
				TorrentSettings.storage.sparse = false;
				TorrentSettings.storage.enabled = true; //set to false for testing and benchmarking. No data is saved to disk.
				
				torrentUrl = TorrentSettings.storage.torrentPath + "/bbb_sunflower_1080p_30fps_normal.mp4.torrent";

				updateTorrentSettings();
				
				bitTorrentANE.updateSettings();
				
				bitTorrentANE.addDHTRouter("router.bittorrent.com");
				bitTorrentANE.addDHTRouter("router.utorrent.com");
				bitTorrentANE.addDHTRouter("router.bitcomet.com");
				bitTorrentANE.addDHTRouter("dht.transmissionbt.com");
				bitTorrentANE.addDHTRouter("dht.aelitis.com");
				
				bitTorrentANE.initSession();
			}
		}

		private function createButton(lbl:String):Sprite {
			var spr:Sprite = new Sprite();
			var bg:Quad = new Quad(320,100,0xFFFFFF);
			
			var tf:TextFormat = new TextFormat("Roboto-Medium", fontSize, 0x000000);
			tf.horizontalAlign = Align.CENTER;
			tf.verticalAlign = Align.TOP;
			
			var lblTxt:TextField = new TextField(320, 80, lbl);
			lblTxt.format = tf;
			lblTxt.y = 32;
			
			spr.addChild(bg);
			spr.addChild(lblTxt);
			return spr;
		}
		
		private function updateTorrentSettings():void {
			TorrentSettings.storage.outputPath = model.SettingsLocalStore.settings.outputPath;
			
			trace(TorrentSettings.storage.outputPath);
			
			TorrentSettings.privacy.useDHT = model.SettingsLocalStore.settings.privacy.useDHT;
			TorrentSettings.privacy.useLSD = model.SettingsLocalStore.settings.privacy.useLSD;
			TorrentSettings.privacy.usePEX = model.SettingsLocalStore.settings.privacy.usePEX;
			TorrentSettings.privacy.encryption = model.SettingsLocalStore.settings.privacy.encryption;
			TorrentSettings.privacy.useAnonymousMode = model.SettingsLocalStore.settings.privacy.useAnonymousMode;
			
			TorrentSettings.speed.downloadRateLimit = (model.SettingsLocalStore.settings.speed.downloadRateEnabled) ? model.SettingsLocalStore.settings.speed.downloadRateLimit*1000 : 0;
			//TorrentSettings.speed.downloadRateLimit = 500*1000;
			
			
			TorrentSettings.speed.uploadRateLimit = (model.SettingsLocalStore.settings.speed.uploadRateEnabled) ? model.SettingsLocalStore.settings.speed.uploadRateLimit*1000 : 0;
			TorrentSettings.speed.ignoreLimitsOnLAN = model.SettingsLocalStore.settings.speed.ignoreLimitsOnLAN;
			TorrentSettings.speed.isuTPEnabled = model.SettingsLocalStore.settings.speed.isuTPEnabled;
			TorrentSettings.speed.isuTPRateLimited = model.SettingsLocalStore.settings.speed.isuTPRateLimited;
			TorrentSettings.speed.rateLimitIpOverhead = model.SettingsLocalStore.settings.speed.rateLimitIpOverhead;
			
			TorrentSettings.connections.maxNum = (model.SettingsLocalStore.settings.connections.useMaxConnections) ? model.SettingsLocalStore.settings.connections.maxNum : -1;
			TorrentSettings.connections.maxUploads = (model.SettingsLocalStore.settings.connections.useMaxUploads) ? model.SettingsLocalStore.settings.connections.maxUploads : -1;
			TorrentSettings.connections.maxNumPerTorrent= (model.SettingsLocalStore.settings.connections.useMaxConnectionsPerTorrent) ? model.SettingsLocalStore.settings.connections.maxNumPerTorrent : -1;
			TorrentSettings.connections.maxUploadsPerTorrent = (model.SettingsLocalStore.settings.connections.useMaxUploadsPerTorrent) ? model.SettingsLocalStore.settings.connections.maxUploadsPerTorrent : -1;
			
			TorrentSettings.queueing.enabled = model.SettingsLocalStore.settings.queueing.enabled;
			TorrentSettings.queueing.maxActiveDownloads = model.SettingsLocalStore.settings.queueing.maxActiveDownloads;
			TorrentSettings.queueing.maxActiveTorrents = model.SettingsLocalStore.settings.queueing.maxActiveTorrents;
			TorrentSettings.queueing.maxActiveUploads = model.SettingsLocalStore.settings.queueing.maxActiveUploads;
			TorrentSettings.queueing.ignoreSlow = model.SettingsLocalStore.settings.queueing.ignoreSlow;
			
			TorrentSettings.proxy.type = model.SettingsLocalStore.settings.proxy.type;
			TorrentSettings.proxy.host = model.SettingsLocalStore.settings.proxy.host;
			TorrentSettings.proxy.port = model.SettingsLocalStore.settings.proxy.port;
			TorrentSettings.proxy.useForPeerConnections = model.SettingsLocalStore.settings.proxy.useForPeerConnections;
			TorrentSettings.proxy.force = model.SettingsLocalStore.settings.proxy.force;
			TorrentSettings.proxy.useAuth = model.SettingsLocalStore.settings.proxy.useAuth;
			TorrentSettings.proxy.username = model.SettingsLocalStore.settings.proxy.username;
			TorrentSettings.proxy.password = model.SettingsLocalStore.settings.proxy.password;
			
			TorrentSettings.listening.port = model.SettingsLocalStore.settings.listening.port;
			TorrentSettings.listening.randomPort = model.SettingsLocalStore.settings.listening.randomPort;
			TorrentSettings.listening.useUPnP = model.SettingsLocalStore.settings.listening.useUPnP;
			
			TorrentSettings.advanced.announceIP = model.SettingsLocalStore.settings.advanced.announceIP;
			TorrentSettings.advanced.diskCacheSize = model.SettingsLocalStore.settings.advanced.diskCacheSize;
			TorrentSettings.advanced.diskCacheTTL = model.SettingsLocalStore.settings.advanced.diskCacheTTL;
			TorrentSettings.advanced.outgoingPortsMin = model.SettingsLocalStore.settings.advanced.outgoingPortsMin;
			TorrentSettings.advanced.outgoingPortsMax = model.SettingsLocalStore.settings.advanced.outgoingPortsMax;
			TorrentSettings.advanced.numMaxHalfOpenConnections = model.SettingsLocalStore.settings.advanced.numMaxHalfOpenConnections;
			TorrentSettings.advanced.enableOsCache = model.SettingsLocalStore.settings.advanced.enableOsCache;
			TorrentSettings.advanced.recheckTorrentsOnCompletion = model.SettingsLocalStore.settings.advanced.recheckTorrentsOnCompletion;
			TorrentSettings.advanced.resolveCountries = model.SettingsLocalStore.settings.advanced.resolveCountries;
			TorrentSettings.advanced.resolvePeerHostNames = model.SettingsLocalStore.settings.advanced.resolvePeerHostNames;
			TorrentSettings.advanced.isSuperSeedingEnabled = model.SettingsLocalStore.settings.advanced.isSuperSeedingEnabled;
			TorrentSettings.advanced.announceToAllTrackers = model.SettingsLocalStore.settings.advanced.announceToAllTrackers;
			TorrentSettings.advanced.enableTrackerExchange = model.SettingsLocalStore.settings.advanced.enableTrackerExchange;
			TorrentSettings.advanced.listenOnIPv6 = model.SettingsLocalStore.settings.advanced.listenOnIPv6;
			TorrentSettings.advanced.networkInterface = model.SettingsLocalStore.settings.advanced.networkInterface;
		}
		
	}
}