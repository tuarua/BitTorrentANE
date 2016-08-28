package {
	import com.tuarua.BitTorrentANE;
	import com.tuarua.torrent.TorrentFileMeta;
	import com.tuarua.torrent.TorrentInfo;
	import com.tuarua.torrent.TorrentPeers;
	import com.tuarua.torrent.TorrentPieces;
	import com.tuarua.torrent.TorrentSettings;
	import com.tuarua.torrent.TorrentStateCodes;
	import com.tuarua.torrent.TorrentStatus;
	import com.tuarua.torrent.TorrentsLibrary;
	import com.tuarua.torrent.constants.LogLevel;
	import com.tuarua.torrent.constants.QueuePosition;
	import com.tuarua.torrent.events.TorrentAlertEvent;
	import com.tuarua.torrent.events.TorrentInfoEvent;
	import com.tuarua.torrent.utils.MagnetParser;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.utils.Timer;
	import events.InteractionEvent;
	import model.SettingsLocalStore;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.core.Starling
	
	import utils.TextUtils;
	
	import views.client.MainPanel;
	import views.settings.SettingsPanel;

	public class StarlingRoot extends Sprite {
		private var starlingVideo:StarlingVideo = new StarlingVideo();
		private var bitTorrentANE:BitTorrentANE = new BitTorrentANE();
		private var statusTimer:Timer;
		private var currentStatus:TorrentStatus;
		private var currentPieces:TorrentPieces;
		private var currentPeers:TorrentPeers;
		private var currentVideoFile:TorrentFileMeta;
		private var isVideoPlaying:Boolean = false;
		private var numRequiredPieces:int = 5;
		private var buttonBG:Quad = new Quad(100,40,0xF3F3F3);
		private var torrentId:String;
		
		private var torrentClientPanel:MainPanel;
		private var settingsPanel:SettingsPanel;
		private var settingsButtonTexture:Texture = Assets.getAtlas().getTexture("settings-cog");
		private var settingsButton:Image = new Image(settingsButtonTexture);
		private var downloadAsSequential:Boolean = true;
		private var selectedFile:File = new File();

		public function StarlingRoot() {
			super();
			TextField.registerBitmapFont(Fonts.getFont("fira-sans-semi-bold-13"));
		}

		
		public function start():void {
			
			selectedFile.addEventListener(Event.SELECT, selectFile); 
			
			model.SettingsLocalStore.load(model.SettingsLocalStore == null);
			//model.SettingsLocalStore.load(true); //force load
			
			settingsPanel = new SettingsPanel();
			torrentClientPanel = new MainPanel();
			torrentClientPanel.addEventListener(InteractionEvent.ON_TORRENT_ADD,onTorrentAdd);
			torrentClientPanel.addEventListener(InteractionEvent.ON_POWER_CLICK,onPowerClick);
			
			starlingVideo.y = 0;
			
			torrentClientPanel.addEventListener(InteractionEvent.ON_MENU_ITEM_RIGHT,onRightMenuClick);
			torrentClientPanel.addEventListener(InteractionEvent.ON_MENU_ITEM_MENU,onMenuClick);
			settingsPanel.x = torrentClientPanel.x = 0;
			torrentClientPanel.y = 30;
			torrentClientPanel.addEventListener(InteractionEvent.ON_MAGNET_ADD_LIST,onMagnetListAdd);
			torrentClientPanel.addEventListener(InteractionEvent.ON_TORRRENT_CREATE,onTorrentCreate);
			torrentClientPanel.addEventListener(InteractionEvent.ON_TORRRENT_SEED_NOW,oTorrentSeedNow);
			settingsPanel.y = 30;
			

			addChild(starlingVideo);
			addChild(torrentClientPanel);
			
			settingsPanel.visible = false;
			addChild(settingsPanel);
			
			settingsButton.x = 1180;
			settingsButton.y = settingsPanel.y + 38;
			
			settingsButton.addEventListener(TouchEvent.TOUCH,onSettingsClick);
			addChild(settingsButton);

			
			if(bitTorrentANE.isSupported()){
				
				TorrentSettings.logLevel = LogLevel.DEBUG;
				TorrentSettings.prioritizedFileTypes = new Array("mp4"); 
				TorrentSettings.clientName = "BitTorrentANE_Example";
				TorrentSettings.storage.torrentPath = File.applicationDirectory.resolvePath("torrents").nativePath;
				TorrentSettings.storage.resumePath = File.applicationDirectory.resolvePath("torrents").resolvePath("resume").nativePath; //path where we save our "faststart" resume files
				TorrentSettings.storage.geoipDataPath = File.applicationDirectory.resolvePath("geoip").nativePath;
				TorrentSettings.storage.sessionStatePath = File.applicationDirectory.resolvePath("session").nativePath;
				TorrentSettings.storage.sparse = true;
				TorrentSettings.storage.enabled = true; //set to false for testing and benchmarking. No data is saved to disk.
				
				updateTorrentSettings();
				bitTorrentANE.updateSettings();
				
				
				bitTorrentANE.addDHTRouter("router.bittorrent.com");
				bitTorrentANE.addDHTRouter("router.utorrent.com");
				bitTorrentANE.addDHTRouter("router.bitcomet.com");
				bitTorrentANE.addDHTRouter("dht.transmissionbt.com");
				bitTorrentANE.addDHTRouter("dht.aelitis.com");
				
				bitTorrentANE.addEventListener(TorrentAlertEvent.TORRENT_ADDED,onTorrentAdded);
				bitTorrentANE.addEventListener(TorrentInfoEvent.ON_ERROR,onTorrentError);
				bitTorrentANE.addEventListener(TorrentInfoEvent.TORRENT_UNAVAILABLE,onTorrentUnavailable);
				bitTorrentANE.addEventListener(TorrentInfoEvent.FILTER_LIST_ADDED,onFilterListAdded);	
				bitTorrentANE.addEventListener(TorrentAlertEvent.FILE_COMPLETED,onFileComplete);
				bitTorrentANE.addEventListener(TorrentAlertEvent.LISTEN_FAILED,onListenFailed);
				
				bitTorrentANE.addEventListener(TorrentAlertEvent.STATE_UPDATE,onTorrentStateUpdate);
				bitTorrentANE.addEventListener(TorrentAlertEvent.STATE_CHANGED,onTorrentStateChanged);
				bitTorrentANE.addEventListener(TorrentAlertEvent.PEERS_UPDATE,onTorrentPeersUpdate);
				bitTorrentANE.addEventListener(TorrentAlertEvent.TRACKERS_UPDATE,onTorrentTrackersUpdate);
				bitTorrentANE.addEventListener(TorrentAlertEvent.TORRENT_PAUSED,onTorrentPaused);
				bitTorrentANE.addEventListener(TorrentAlertEvent.TORRENT_RESUMED,onTorrentResumed);
				bitTorrentANE.addEventListener(TorrentAlertEvent.TORRENT_FINISHED,onTorrentFinished);
				bitTorrentANE.addEventListener(TorrentAlertEvent.PIECE_FINISHED,onPieceFinished);
				
				bitTorrentANE.initSession();
				
				if(model.SettingsLocalStore.settings.filters.enabled)
					bitTorrentANE.addFilterList(model.SettingsLocalStore.settings.filters.fileName,model.SettingsLocalStore.settings.filters.applyToTrackers);
			
			}else{
				trace("This ANE is not supported");
			}
			
		}
		
		protected function onListenFailed(event:TorrentAlertEvent):void {
			trace("Failed on",event.params.address+":"+event.params.port,event.params.type);
			trace(event.params.message);
		}

		private function onTorrentCreate(event:InteractionEvent):void {
			var savePath:String = bitTorrentANE.saveAs("torrent",TorrentSettings.storage.torrentPath);
			if(savePath.length == 0){
				torrentClientPanel.createTorrentScreen.hide();
			}else{
				bitTorrentANE.addEventListener(TorrentInfoEvent.TORRENT_CREATION_PROGRESS,torrentClientPanel.createTorrentScreen.onProgress);
				bitTorrentANE.addEventListener(TorrentInfoEvent.TORRENT_CREATED,torrentClientPanel.createTorrentScreen.onCreateComplete);
				bitTorrentANE.createTorrent(event.params.file,savePath,event.params.size,event.params.trackers,event.params.webSeeds,event.params.isPrivate,event.params.comments,event.params.seedNow);
			}
			
		}
		
		
		private function oTorrentSeedNow(event:InteractionEvent):void {
			var torrentInfo:TorrentInfo = bitTorrentANE.getTorrentInfo(event.params.fileName);
			if(torrentInfo.status == "ok"){
				torrentId = torrentInfo.infoHash; //it's a good idea to use the hash as the id
				bitTorrentANE.addTorrent(torrentId,torrentInfo.torrentFile,torrentInfo.infoHash,"",downloadAsSequential,null,null,true);
				
			}else{
				trace("failed to load torrent");
			}
		}
		
		private function onMagnetListAdd(event:InteractionEvent):void {
			var lst:Array = TextUtils.trim(event.params.value).split(String.fromCharCode(13));
			var itm:String;
			var file:File;
			for (var i:int=0, l:int=lst.length; i<l; ++i){
				itm = lst[i];
				if(itm.length > 0){
					if(itm.length > 8 && itm.substr(0,8) == "magnet:?"){
						torrentId = MagnetParser.parse(itm).hash;
						bitTorrentANE.addTorrent(torrentId,itm,torrentId,"",downloadAsSequential);
					}else{
						torrentId = itm;
						bitTorrentANE.addTorrent(torrentId,"",torrentId,"",downloadAsSequential);
					}
				}
			}
		}
		private function showSettings(b:Boolean):void {
			if(settingsPanel){
				settingsPanel.visible = !settingsPanel.visible;
				torrentClientPanel.visible = !settingsPanel.visible;
				if(b){
					settingsPanel.showDefault();
					this.setChildIndex(settingsPanel,this.numChildren-2);
				}else{
					updateTorrentSettings();
					bitTorrentANE.updateSettings();
					settingsPanel.hideAllFields();
				}
			}
		}

		private function onMenuClick(event:InteractionEvent):void {
			bitTorrentANE.queryForPeers((event.params.value == 2),torrentId,(event.params.value == 2));
			if(event.params.value == 2){
				bitTorrentANE.postPeersUpdate();
			}else if(event.params.value == 1){
				bitTorrentANE.postTrackersUpdate();
			}
		}
		
		private function onRightMenuClick(event:InteractionEvent):void {
			switch(event.params.value){
				case 0:
					bitTorrentANE.pauseTorrent(event.params.id);
					bitTorrentANE.postTorrentUpdates();
					break;
				case 8:
					bitTorrentANE.resumeTorrent(event.params.id);
					bitTorrentANE.postTorrentUpdates();
					break;
				case 1:
					bitTorrentANE.removeTorrent(event.params.id);
					bitTorrentANE.postTorrentUpdates();
					torrentClientPanel.removeTorrent(event.params.id);
					break;
				case 2:
					bitTorrentANE.setSequentialDownload(event.params.id,false);
					break;
				case 9:
					bitTorrentANE.setSequentialDownload(event.params.id,true);
					break;
				case 3:
					bitTorrentANE.setQueuePosition(event.params.id,QueuePosition.TOP);
					bitTorrentANE.postTorrentUpdates();
					break;
				case 4:
					bitTorrentANE.setQueuePosition(event.params.id,QueuePosition.UP);
					bitTorrentANE.postTorrentUpdates();
					break;
				case 5:
					bitTorrentANE.setQueuePosition(event.params.id,QueuePosition.DOWN);
					bitTorrentANE.postTorrentUpdates();
					break;
				case 6:
					bitTorrentANE.setQueuePosition(event.params.id,QueuePosition.BOTTOM);
					bitTorrentANE.postTorrentUpdates();
					break;
				case 7:
					Clipboard.generalClipboard.clear(); 
					Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, bitTorrentANE.getMagnetURI(event.params.id), false);
					break;
			}	
			
		}
		private function updateTorrentSettings():void {
			TorrentSettings.storage.outputPath = model.SettingsLocalStore.settings.outputPath;
			TorrentSettings.privacy.useDHT = model.SettingsLocalStore.settings.privacy.useDHT;
			TorrentSettings.privacy.useLSD = model.SettingsLocalStore.settings.privacy.useLSD;
			TorrentSettings.privacy.usePEX = model.SettingsLocalStore.settings.privacy.usePEX;
			TorrentSettings.privacy.encryption = model.SettingsLocalStore.settings.privacy.encryption;
			TorrentSettings.privacy.useAnonymousMode = model.SettingsLocalStore.settings.privacy.useAnonymousMode;
			
			TorrentSettings.speed.downloadRateLimit = (model.SettingsLocalStore.settings.speed.downloadRateEnabled) ? model.SettingsLocalStore.settings.speed.downloadRateLimit*1000 : 0;
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
		
		protected function onFilterListAdded(event:TorrentInfoEvent):void {
			trace("number of filters added",event.params.numFilters);
		}
		
		protected function onTorrentUnavailable(event:TorrentInfoEvent):void {
			
		}
		protected function onTorrentError(event:TorrentInfoEvent):void {
			trace("ERROR:",event.params.message);
		}
		
		protected function selectFile(event:Event):void {
			var torrentInfo:TorrentInfo = bitTorrentANE.getTorrentInfo(selectedFile.nativePath);	
			if(torrentInfo && torrentInfo.status == "ok"){
				torrentId = torrentInfo.infoHash; //it's a good idea to use the hash as the id
				bitTorrentANE.addTorrent(torrentId,torrentInfo.torrentFile,torrentInfo.infoHash,"",downloadAsSequential);
			}else{
				trace("failed to load torrent");
			}
		}
		private function onTorrentAdd(event:InteractionEvent):void {
			event.stopPropagation();
			selectedFile.browseForOpen("Select torrent file...",[new FileFilter("torrent file", "*.torrent;")]);
		}
		
		private function onPowerClick(event:InteractionEvent):void {
			if(event.params.on){
				bitTorrentANE.initSession();
			}else{
				TorrentsLibrary.remove(torrentId);
				//stopStatusListener();
				bitTorrentANE.endSession();
			}	
		}
		
		private function onSettingsClick(event:TouchEvent):void {
			var touch:Touch = event.getTouch(settingsButton);
			if(touch != null && touch.phase == TouchPhase.ENDED){
			if(settingsPanel)
				showSettings(!settingsPanel.visible);
			}
		}
		
		
		protected function onPieceFinished(event:TorrentAlertEvent):void {
			//trace(event);
			if(torrentClientPanel.visible && torrentClientPanel.selectedMenu == 0)
				torrentClientPanel.updatePieces();
		}
		protected function onFileComplete(event:TorrentAlertEvent):void {
			trace(event);
		}
		protected function onTorrentFinished(event:TorrentAlertEvent):void {
			//trace(event);
		}
		protected function onTorrentResumed(event:TorrentAlertEvent):void {
			trace(TorrentStateCodes.getMessageFromCode(event.params.state));
		}
		protected function onTorrentPaused(event:TorrentAlertEvent):void {
			trace(TorrentStateCodes.getMessageFromCode(event.params.state));
		}
		protected function onTorrentStateChanged(event:TorrentAlertEvent):void {
			trace(TorrentStateCodes.getMessageFromCode(event.params.state));
		}
		protected function onTorrentTrackersUpdate(event:TorrentAlertEvent):void {
			trace(event);
			if(torrentClientPanel.visible)
				if(torrentClientPanel.selectedMenu == 1)torrentClientPanel.updateTrackers();
		}
		protected function onTorrentPeersUpdate(event:TorrentAlertEvent):void {
			trace(event);
			if(torrentClientPanel.visible)
				if(torrentClientPanel.selectedMenu == 2) torrentClientPanel.updatePeers();
		}
		protected function onTorrentAdded(event:TorrentAlertEvent):void {
			torrentId = event.params.id;
			bitTorrentANE.queryForPeers((torrentClientPanel.selectedMenu == 2),torrentId,(torrentClientPanel.selectedMenu == 2));
		}
		protected function onTorrentStateUpdate(event:TorrentAlertEvent):void {
			trace(event);
			if(torrentClientPanel.visible){
				torrentClientPanel.updateStatus();
				if(torrentClientPanel.selectedMenu == 0) torrentClientPanel.updatePieces();
			}
			
			currentStatus = TorrentsLibrary.status[torrentId] as TorrentStatus;
			currentPieces = TorrentsLibrary.pieces[torrentId] as TorrentPieces;
			if(currentStatus){
				if(TorrentsLibrary.info[torrentId])
					currentVideoFile = TorrentsLibrary.info[torrentId].getFileByExtension(["mp4"]);
				
				if(currentVideoFile && currentStatus && currentPieces){
					if(isVideoPlaying){
						
					}else{
						numRequiredPieces = Math.ceil((currentVideoFile.lastPiece - currentVideoFile.firstPiece)/1000)*5;
						var initialPieces:Number = 0;
						if(currentPieces && currentPieces.pieces.length > 0){
							initialPieces = currentPieces.numSequential - currentVideoFile.firstPiece;
							if (currentPieces.pieces[currentVideoFile.lastPiece] == 1) initialPieces++;
						}
						if((initialPieces >= numRequiredPieces) || currentStatus.state == TorrentStateCodes.SEEDING || currentStatus.isFinished) {
							isVideoPlaying = true;
							torrentClientPanel.showMask(false);
							settingsPanel.showMask(false);
							Starling.current.skipUnchangedFrames = false;
							starlingVideo.loadVideo(File.applicationDirectory.resolvePath("output").resolvePath(currentVideoFile.path).nativePath);
						}
					}
				}	
			}
			
			
		}
		
		
		
		
	}
}