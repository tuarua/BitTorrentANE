package {
	import com.tuarua.BitTorrentANE;
	import com.tuarua.torrent.TorrentFileMeta;
	import com.tuarua.torrent.TorrentMeta;
	import com.tuarua.torrent.TorrentPeers;
	import com.tuarua.torrent.TorrentPieces;
	import com.tuarua.torrent.TorrentSettings;
	import com.tuarua.torrent.TorrentStateCodes;
	import com.tuarua.torrent.TorrentStatus;
	import com.tuarua.torrent.TorrentsLibrary;
	import com.tuarua.torrent.constants.LogLevel;
	import com.tuarua.torrent.constants.QueuePosition;
	import com.tuarua.torrent.events.TorrentInfoEvent;
	import com.tuarua.torrent.utils.MagnetParser;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.utils.Dictionary;
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
	
	import utils.TextUtils;
	import views.client.MainPanel;
	import views.settings.SettingsPanel;

	public class StarlingRoot extends Sprite {
		private var starlingVideo:StarlingVideo = new StarlingVideo();
		private var libTorrentANE:BitTorrentANE = new BitTorrentANE();
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
			
			// ANE error bubble
			selectedFile.addEventListener(Event.SELECT, selectFile); 
			
			model.SettingsLocalStore.load(model.SettingsLocalStore == null);
			//model.SettingsLocalStore.load(true); //force load
			
			settingsPanel = new SettingsPanel();
			torrentClientPanel = new MainPanel();
			torrentClientPanel.addEventListener(InteractionEvent.ON_TORRENT_ADD,onTorrentAdd);
			torrentClientPanel.addEventListener(InteractionEvent.ON_POWER_CLICK,onPowerClick);
			
			starlingVideo.y = 0;
			
			torrentClientPanel.addEventListener(InteractionEvent.ON_MENU_ITEM_RIGHT,onRightClick);
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

			if(libTorrentANE.isSupported()){
				
				TorrentSettings.logLevel = LogLevel.INFO;
				TorrentSettings.prioritizedFileTypes = new Array("mp4"); 
				
				TorrentSettings.storage.torrentPath = File.applicationDirectory.resolvePath("torrents").nativePath;
				TorrentSettings.storage.resumePath = File.applicationDirectory.resolvePath("torrents").resolvePath("resume").nativePath; //path where we save our "faststart" resume files
				TorrentSettings.storage.geoipDataPath = File.applicationDirectory.resolvePath("geoip").nativePath;
				TorrentSettings.storage.sessionStatePath = File.applicationDirectory.resolvePath("session").nativePath;
				
				updateTorrentSettings();
				libTorrentANE.updateSettings();
				
				libTorrentANE.addDHTRouter("router.bittorrent.com");
				libTorrentANE.addDHTRouter("router.utorrent.com");
				libTorrentANE.addDHTRouter("router.bitcomet.com");
				libTorrentANE.addDHTRouter("dht.transmissionbt.com");
				libTorrentANE.addDHTRouter("dht.aelitis.com");
				
				libTorrentANE.addEventListener(TorrentInfoEvent.TORRENT_CREATED_FROM_META,onMagnetSaved);
				libTorrentANE.addEventListener(TorrentInfoEvent.TORRENT_ADDED,onTorrentAdded);
				libTorrentANE.addEventListener(TorrentInfoEvent.ON_ERROR,onTorrentError);
				libTorrentANE.addEventListener(TorrentInfoEvent.TORRENT_UNAVAILABLE,onTorrentUnavailable);
				libTorrentANE.addEventListener(TorrentInfoEvent.FILTERLIST_ADDED,onFilterListAdded);
				libTorrentANE.addEventListener(TorrentInfoEvent.RSS_ITEM,onRSSitem);
				libTorrentANE.initSession();
				
				if(model.SettingsLocalStore.settings.filters.enabled)
					libTorrentANE.addFilterList(model.SettingsLocalStore.settings.filters.fileName,model.SettingsLocalStore.settings.filters.applyToTrackers);
			
			}else{
				trace("This ANE is not supported");
			}
			
		}
		
		private function onTorrentCreate(event:InteractionEvent):void {
			var savePath:String = libTorrentANE.saveAs("torrent",TorrentSettings.storage.torrentPath);
			if(savePath.length == 0){
				torrentClientPanel.createTorrentScreen.hide();
			}else{
				libTorrentANE.addEventListener(TorrentInfoEvent.TORRENT_CREATION_PROGRESS,torrentClientPanel.createTorrentScreen.onProgress);
				libTorrentANE.addEventListener(TorrentInfoEvent.TORRENT_CREATED,torrentClientPanel.createTorrentScreen.onCreateComplete);
				libTorrentANE.createTorrent(event.params.file,savePath,event.params.size,event.params.trackers,event.params.webSeeds,event.params.isPrivate,event.params.comments,event.params.seedNow);
			}
			
		}
		
		private function oTorrentSeedNow(event:InteractionEvent):void {
			var meta:TorrentMeta = libTorrentANE.getTorrentMeta(event.params.fileName);
			if(meta.status == "ok"){
				torrentId = meta.infoHash; //it's a good idea to use the hash as the id
				var dict:Dictionary = TorrentsLibrary.status;
				var rightClickMenuDataList:Array = new Array();
				rightClickMenuDataList.push({value:0,label:"Pause"});//Resume
				rightClickMenuDataList.push({value:1,label:"Delete"});
				rightClickMenuDataList.push({value:(downloadAsSequential) ? 2 : 9,label:(downloadAsSequential) ? "Sequential Off": "Sequential On"});
				rightClickMenuDataList.push({value:7,label:"Copy magnet link"});
				torrentClientPanel.addRightClickMenu(torrentId,rightClickMenuDataList);
				libTorrentANE.addTorrent(meta.torrentFile,torrentId,meta.infoHash,downloadAsSequential,false,null,true);
			}else{
				trace("failed to load torrent");
			}
		}
		
		private function onMagnetListAdd(event:InteractionEvent):void {
			var lst:Array = TextUtils.trim(event.params.value).split(String.fromCharCode(13));
			var itm:String;
			var rightClickMenuDataList:Array = new Array();
			rightClickMenuDataList.push({value:0,label:"Pause"});
			rightClickMenuDataList.push({value:1,label:"Delete"});
			rightClickMenuDataList.push({value:(downloadAsSequential) ? 2 : 9,label:(downloadAsSequential) ? "Sequential Off": "Sequential On"});
			rightClickMenuDataList.push({value:7,label:"Copy magnet link"});
			
			for (var i:int=0, l:int=lst.length; i<l; ++i){
				itm = lst[i];
				if(itm.length > 0){
					if(itm.length > 8 && itm.substr(0,8) == "magnet:?"){
						torrentId = MagnetParser.parse(itm).hash;
						torrentClientPanel.addRightClickMenu(torrentId,rightClickMenuDataList);
						libTorrentANE.torrentFromMagnet(itm,torrentId,downloadAsSequential);
					}else{
						torrentId = itm;
						torrentClientPanel.addRightClickMenu(torrentId,rightClickMenuDataList);
						libTorrentANE.torrentFromHash(torrentId,torrentId,"",downloadAsSequential);
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
					libTorrentANE.updateSettings();
					settingsPanel.hideAllFields();
				}
			}
		}
		private function onRightClick(event:InteractionEvent):void {
			var meta:TorrentMeta = TorrentsLibrary.meta[event.params.id];
			switch(event.params.value){
				case 0:
					torrentClientPanel.updateRightClickMenu(event.params.id,0,"Resume",8);
					libTorrentANE.pauseTorrent(meta.infoHash);
					onStatusTimer();
					break;
				case 8:
					torrentClientPanel.updateRightClickMenu(event.params.id,0,"Pause",0);
					libTorrentANE.resumeTorrent(meta.infoHash);
					onStatusTimer();
					break;
				case 1:
					TorrentsLibrary.remove(meta.infoHash);
					stopStatusListener();
					libTorrentANE.removeTorrent(meta.infoHash);
					torrentClientPanel.clear();
					//clear the item from the client
					
					break;
				case 2:
					torrentClientPanel.updateRightClickMenu(event.params.id,2,"Sequential On",9);
					libTorrentANE.setSequentialDownload(meta.infoHash,false);
					break;
				case 9:
					torrentClientPanel.updateRightClickMenu(event.params.id,2,"Sequential Off",2);
					libTorrentANE.setSequentialDownload(meta.infoHash,true);
					break;
				case 3:
					libTorrentANE.setQueuePosition(meta.infoHash,QueuePosition.TOP);
					onStatusTimer();
					break;
				case 4:
					libTorrentANE.setQueuePosition(meta.infoHash,QueuePosition.UP);
					onStatusTimer();
					break;
				case 5:
					libTorrentANE.setQueuePosition(meta.infoHash,QueuePosition.DOWN);
					onStatusTimer();
					break;
				case 6:
					libTorrentANE.setQueuePosition(meta.infoHash,QueuePosition.BOTTOM);
					onStatusTimer();
					break;
				case 7:
					Clipboard.generalClipboard.clear(); 
					Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, libTorrentANE.getMagnetURI(meta.infoHash), false);
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
			
			TorrentSettings.speed.downloadRateLimit = (model.SettingsLocalStore.settings.speed.downloadRateEnabled) ? model.SettingsLocalStore.settings.speed.downloadRateLimit*1024 : 0;
			TorrentSettings.speed.uploadRateLimit = (model.SettingsLocalStore.settings.speed.uploadRateEnabled) ? model.SettingsLocalStore.settings.speed.uploadRateLimit*1024 : 0;
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
		protected function onRSSitem(event:TorrentInfoEvent):void {
			    
		}
		protected function onTorrentUnavailable(event:TorrentInfoEvent):void {
			
		}
		protected function onTorrentError(event:TorrentInfoEvent):void {
			trace("ERROR:",event.params.message);
		}
		
		protected function selectFile(event:Event):void {
			var meta:TorrentMeta = libTorrentANE.getTorrentMeta(selectedFile.nativePath);
			if(meta.status == "ok"){
				torrentId = meta.infoHash; //it's a good idea to use the hash as the id
				var dict:Dictionary = TorrentsLibrary.status;
				var rightClickMenuDataList:Array = new Array();
				rightClickMenuDataList.push({value:0,label:"Pause"});//Resume
				rightClickMenuDataList.push({value:1,label:"Delete"});
				rightClickMenuDataList.push({value:(downloadAsSequential) ? 2 : 9,label:(downloadAsSequential) ? "Sequential Off": "Sequential On"});
				rightClickMenuDataList.push({value:7,label:"Copy magnet link"});
				torrentClientPanel.addRightClickMenu(torrentId,rightClickMenuDataList);
				libTorrentANE.addTorrent(meta.torrentFile,torrentId,meta.infoHash,downloadAsSequential);
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
				libTorrentANE.initSession();
			}else{
				TorrentsLibrary.remove(torrentId);
				stopStatusListener();
				libTorrentANE.endSession();
			}	
		}
		
		private function onSettingsClick(event:TouchEvent):void {
			var touch:Touch = event.getTouch(settingsButton);
			if(touch != null && touch.phase == TouchPhase.ENDED){
			if(settingsPanel)
				showSettings(!settingsPanel.visible);
			}
		}
		protected function onTorrentAdded(event:TorrentInfoEvent):void {
			var meta:TorrentMeta;
			var torrentFileExists:Boolean = false;
			if(!event.params.toQueue) torrentId = event.params.id.toLowerCase();
			if(event.params.fileName == ""){
				var torrentFile:File = File.applicationDirectory.resolvePath(TorrentSettings.storage.torrentPath).resolvePath(event.params.id+".torrent");
				torrentFileExists = torrentFile.exists;
				if(torrentFileExists)
					meta = libTorrentANE.getTorrentMeta(torrentFile.nativePath);
			}else{
				torrentFileExists = true;
				meta = libTorrentANE.getTorrentMeta(event.params.fileName);
			}
			if(meta)
				TorrentsLibrary.add(event.params.id.toLowerCase(),meta);
			
			torrentClientPanel.addPriorityToRightClick((TorrentsLibrary.length(TorrentsLibrary.meta) > 1));
			
			startStatusListener();
			onStatusTimer();
		}
		
		
		protected function onMagnetSaved(event:TorrentInfoEvent):void {
			var meta:TorrentMeta;
			var torrentFileExists:Boolean = false;
			var torrentFile:File = File.applicationDirectory.resolvePath(TorrentSettings.storage.torrentPath).resolvePath(event.params.id+".torrent");
			torrentFileExists = torrentFile.exists;
			if(torrentFileExists)
				meta = libTorrentANE.getTorrentMeta(torrentFile.nativePath);
				
			if(meta)
				TorrentsLibrary.add(event.params.id,meta);
			startStatusListener();
			
		}
		
		private function startStatusListener():void {
			if(statusTimer == null){
				statusTimer = new Timer(1000);
				statusTimer.addEventListener(TimerEvent.TIMER,onStatusTimer);
				statusTimer.start();
			}	
		}
		private function stopStatusListener():void {
			if(statusTimer){
				statusTimer.removeEventListener(TimerEvent.TIMER,onStatusTimer);
				statusTimer.stop();
				statusTimer.reset();
				statusTimer = null;
			}
		}
		private function onStatusTimer(event:TimerEvent=null):void {
			libTorrentANE.getTorrentStatus();
			libTorrentANE.getTorrentPeers();
			libTorrentANE.getTorrentTrackers();
			
			if(torrentClientPanel.visible){
				torrentClientPanel.updateStatus();
				if(torrentClientPanel.selectedMenu == 0) torrentClientPanel.updatePieces();
				if(torrentClientPanel.selectedMenu == 1) torrentClientPanel.updateTrackers();
				if(torrentClientPanel.selectedMenu == 2) torrentClientPanel.updatePeers();
			}
			
			currentStatus = TorrentsLibrary.status[torrentId] as TorrentStatus; //The dictionary contains all the torrents we've added. Use key to retrieve the status of that torrent. You can of course add multiple torrents, and check their status individually
			currentPieces = TorrentsLibrary.pieces[torrentId] as TorrentPieces;
			if(TorrentsLibrary.meta[torrentId])
				currentVideoFile = TorrentsLibrary.meta[torrentId].getFileByExtension(["mp4"]);
			
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
						starlingVideo.loadVideo(File.applicationDirectory.resolvePath("output").resolvePath(currentVideoFile.path).nativePath);
					}
				}
			}	
		}
		
		
	}
}