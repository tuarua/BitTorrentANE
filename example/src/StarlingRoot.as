package {
	import com.tuarua.BitTorrentANE;
	import com.tuarua.torrent.TorrentFileMeta;
	import com.tuarua.torrent.TorrentMeta;
	import com.tuarua.torrent.TorrentPeers;
	import com.tuarua.torrent.TorrentPieces;
	import com.tuarua.torrent.TorrentSettings;
	import com.tuarua.torrent.TorrentStatus;
	import com.tuarua.torrent.TorrentsLibrary;
	import com.tuarua.torrent.constants.LogLevel;
	import com.tuarua.torrent.constants.QueuePosition;
	import com.tuarua.torrent.events.TorrentInfoEvent;
	import com.tuarua.torrent.TorrentStateCodes;
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import events.InteractionEvent;
	
	import model.SettingsLocalStore;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.Texture;
	
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
		private var magnetButton:Button = new Button(Texture.fromColor(100,40,0xFF000000),"load magnet",Texture.fromColor(100,40,0xFF000000),Texture.fromColor(100,40,0xFF000000),Texture.fromColor(100,40,0xFF000000));
		private var torrentButton:Button = new Button(Texture.fromColor(100,40,0xFF000000),"load torrent",Texture.fromColor(100,40,0xFF000000),Texture.fromColor(100,40,0xFF000000),Texture.fromColor(100,40,0xFF000000));
		private var endButton:Button = new Button(Texture.fromColor(100,40,0xFF000000),"end session",Texture.fromColor(100,40,0xFF000000),Texture.fromColor(100,40,0xFF000000),Texture.fromColor(100,40,0xFF000000));
		private var torrentId:String;
		
		private var torrentClientPanel:MainPanel;
		private var settingsPanel:SettingsPanel;
		
		private var downloadAsSequential:Boolean = true;
		public function StarlingRoot() {
			super();
			TextField.registerBitmapFont(Fonts.getFont("fira-regular-13"));
		}
		public function start():void {
			
			//TO DO
			// on resize, advanced textfields x not right
			// add magnet button
			// menu screen
			// ok cancel buttons
			// power button
			// settings screen
			// add torrent button
			// ANE error bubble
			
			
			model.SettingsLocalStore.load(model.SettingsLocalStore == null || model.SettingsLocalStore.settings == null);
			model.SettingsLocalStore.load(true);
			
			
			//create dropdown with some magnets and torrents setup
			
			settingsPanel = new SettingsPanel();
			torrentClientPanel = new MainPanel();
			
			endButton.fontColor = magnetButton.fontColor = torrentButton.fontColor = 0xFFFFFF;
			
			magnetButton.addEventListener(TouchEvent.TOUCH,onMagnetClicked);
			endButton.y = torrentButton.y = magnetButton.y = 10;
			magnetButton.x = 10;
			
			torrentButton.x = 150;
			torrentButton.addEventListener(TouchEvent.TOUCH,onTorrentClicked);
			
			endButton.x = 730;
			endButton.addEventListener(TouchEvent.TOUCH,onEndClicked);
			
			starlingVideo.y = 60;
			
			torrentClientPanel.addEventListener(InteractionEvent.ON_MENU_ITEM_RIGHT,onRightClick);
			settingsPanel.x = torrentClientPanel.x = 0;
			torrentClientPanel.y = 60;
			settingsPanel.y = 86;
			
			addChild(magnetButton);
			
			addChild(torrentButton);
			addChild(endButton);

			addChild(starlingVideo);
			addChild(torrentClientPanel);
			
			settingsPanel.visible = false;
			addChild(settingsPanel);

			if(libTorrentANE.isSupported()){
				
				TorrentSettings.logLevel = LogLevel.INFO;
				TorrentSettings.prioritizedFileTypes = new Array("mp4","mkv","avi"); 
				
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
			
			this.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
		}
		private function onKeyDown(event:KeyboardEvent):void {
			if(String.fromCharCode(event.charCode) == "s" && Starling.current.nativeOverlay.stage.focus == null) {
				showSettings();
			}
		}
		private function showSettings(event:InteractionEvent=null):void {
			if(settingsPanel){
				settingsPanel.visible = !settingsPanel.visible;
				settingsPanel.showDefault();
				if(!settingsPanel.visible) settingsPanel.hideAllFields();
				this.setChildIndex(settingsPanel,this.numChildren-1);
				var targetAlphaSettings:Number = (settingsPanel.visible) ? 1 : 0;
				var tweenTCPSettings:Tween = new Tween(settingsPanel, 0.1, Transitions.LINEAR);
				tweenTCPSettings.animate("alpha",targetAlphaSettings);
				Starling.juggler.add(tweenTCPSettings);
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
		
		private function onMagnetClicked(event:TouchEvent):void {
			var touch:Touch = event.getTouch(magnetButton);
			if(touch != null && touch.phase == TouchPhase.ENDED) {
				torrentId = "f3bf22593bd8c5b318c9fa41c7d507215ea67adc";
				var rightClickMenuDataList:Vector.<Object> = new Vector.<Object>();
				rightClickMenuDataList.push({value:0,label:"Pause"});
				rightClickMenuDataList.push({value:1,label:"Delete"});
				rightClickMenuDataList.push({value:(downloadAsSequential) ? 2 : 9,label:(downloadAsSequential) ? "Sequential Off": "Sequential On"});
				rightClickMenuDataList.push({value:7,label:"Copy magnet link"});
				torrentClientPanel.addRightClickMenu("cosmos",rightClickMenuDataList);
				torrentClientPanel.addPriorityToRightClick((TorrentsLibrary.length(TorrentsLibrary.meta) > 0));
				var uri:String = "magnet:?xt=urn:btih:f3bf22593bd8c5b318c9fa41c7d507215ea67adc&dn=Cosmos%20Laundromat%20-%20Blender-short-movie&tr=udp%3a%2f%2fopen.demonii.com%3a1337%2fannounce&tr=udp%3a%2f%2ftracker.publicbt.com%3a80%2fannounce&tr=udp%3a%2f%2ftracker.openbittorrent.com%3a80%2fannounce&tr=udp%3a%2f%2ftracker.istole.it%3a80%2fannounce&tr=udp%3a%2f%2ftorrent.gresille.org%3a80%2fannounce&tr=udp%3a%2f%2ftracker.opentrackr.org%3a1337%2fannounce&tr=http%3a%2f%2ftracker.aletorrenty.pl%3a2710%2fannounce&tr=http%3a%2f%2fopen.acgtracker.com%3a1096%2fannounce&tr=udp%3a%2f%2f9.rarbg.me%3a2710%2fannounce";
				
				libTorrentANE.torrentFromMagnet(uri,"cosmos",downloadAsSequential);
				
			}
		}
		private function onTorrentClicked(event:TouchEvent):void {
			var touch:Touch = event.getTouch(torrentButton);
			if(touch != null && touch.phase == TouchPhase.ENDED){
				var meta:TorrentMeta = libTorrentANE.getTorrentMeta(File.applicationDirectory.resolvePath("torrents").resolvePath("bbb_sunflower_1080p_30fps_normal.mp4.torrent").nativePath);
				if(meta.status == "ok"){
					torrentId = meta.infoHash; //it's a good idea to use the hash as the id
					var dict:Dictionary = TorrentsLibrary.status;
					var rightClickMenuDataList:Vector.<Object> = new Vector.<Object>();
					rightClickMenuDataList.push({value:0,label:"Pause"});//Resume
					rightClickMenuDataList.push({value:1,label:"Delete"});
					rightClickMenuDataList.push({value:(downloadAsSequential) ? 2 : 9,label:(downloadAsSequential) ? "Sequential Off": "Sequential On"});
					rightClickMenuDataList.push({value:7,label:"Copy magnet link"});
					torrentClientPanel.addRightClickMenu(torrentId,rightClickMenuDataList);
					torrentClientPanel.addPriorityToRightClick((TorrentsLibrary.length(TorrentsLibrary.meta) > 0));
					libTorrentANE.addTorrent(File.applicationDirectory.resolvePath("torrents").resolvePath("bbb_sunflower_1080p_30fps_normal.mp4.torrent").nativePath,torrentId,meta.infoHash,downloadAsSequential);
				}else{
					trace("failed to load torrent");
				}
				
			}
		}
		
		private function onEndClicked(event:TouchEvent):void {
			var touch:Touch = event.getTouch(endButton);
			if(touch != null && touch.phase == TouchPhase.ENDED){
				TorrentsLibrary.remove(torrentId);
				stopStatusListener();
				libTorrentANE.endSession();
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
			if(TorrentsLibrary.meta[torrentId]) currentVideoFile = TorrentsLibrary.meta[torrentId].getFileByExtension(["mp4","mkv","avi"]);
			
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