package {
	import com.tuarua.BitTorrentANE;
	import com.tuarua.torrent.PeerInfo;
	import com.tuarua.torrent.TorrentInfo;
	import com.tuarua.torrent.TorrentPeers;
	import com.tuarua.torrent.TorrentSettings;
	import com.tuarua.torrent.TorrentStateCodes;
	import com.tuarua.torrent.TorrentStatus;
	import com.tuarua.torrent.TorrentsLibrary;
	import com.tuarua.torrent.constants.LogLevel;
	import com.tuarua.torrent.constants.PiecePriority;
	import com.tuarua.torrent.events.TorrentAlertEvent;
	
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.media.SoundTransform;
	import flash.utils.ByteArray;
	
	import events.InstallEvent;
	
	import install.Installer;
	
	import model.HLSMap;
	import model.SettingsLocalStore;
	
	import org.mangui.hls.HLS;
	import org.mangui.hls.HLSSettings;
	import org.mangui.hls.event.HLSEvent;
	import org.mangui.hls.model.Fragment;
	
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	import starling.utils.Align;
	
	import utils.TextUtils;
	
	public class StarlingRoot extends Sprite {
		private var bitTorrentANE:BitTorrentANE = new BitTorrentANE();
		private var hls:HLS = null;
		
		private var videoImage:Image;
		private var videoTexture:Texture;
		private var soundTransform:SoundTransform = new SoundTransform();
		
		private var baVec:Vector.<ByteArray> = new Vector.<ByteArray>;
		private var currentTorrentInfo:TorrentInfo;
		private var currentStatus:TorrentStatus;
		
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
		private var torrentId:String = "c8436d8b114319a55e8fa75fe12177f6c13f09d9";
		
		private var hlsMaps:Vector.<HLSMap> = new Vector.<HLSMap>();
		private var pieceBG:Quad = new Quad(1720,16,0x090909);
		private var numFragments:int = 0;
		
		
		public function StarlingRoot() {
			super();
			
			bitTorrentANE.addEventListener(TorrentAlertEvent.STATE_UPDATE,onTorrentStateUpdate);
			bitTorrentANE.addEventListener(TorrentAlertEvent.STATE_CHANGED,onTorrentStateChanged);
			bitTorrentANE.addEventListener(TorrentAlertEvent.PIECE_FINISHED,onPieceFinished);
			bitTorrentANE.addEventListener(TorrentAlertEvent.TORRENT_ADDED,onTorrentAdded);
			bitTorrentANE.addEventListener(TorrentAlertEvent.LISTEN_SUCCEEDED,onListenSucceded);
			bitTorrentANE.addEventListener(TorrentAlertEvent.LISTEN_FAILED,onListenFailed);
			
		}
		
		protected function onTorrentAdded(event:TorrentAlertEvent):void {
			currentTorrentInfo = bitTorrentANE.getTorrentInfo(TorrentSettings.storage.torrentPath + "/" + torrentId + ".torrent");
			sizeTxt.text = TextUtils.bytesToString(currentTorrentInfo.size);
			hls.streamBuffer.fragmentLoader.localFilePath = TorrentSettings.storage.outputPath + "/" + currentTorrentInfo.files[0].path;
			hls.load("https://tuarua-website.firebaseapp.com/hls/tears_of_steel/tears_of_steel.m3u8");
		}
		
		protected function onPieceFinished(event:TorrentAlertEvent):void {
			trace("piece finished",event.params.index);
			var numMatches:int = 0;
			var hasAll:Boolean = false;
			var h:HLSMap;
			var q:Quad;
			for (var i:int=0, l:int=hlsMaps.length; i<l; ++i){
				h = hlsMaps[i];
				if(event.params.index <= h.endPiece && event.params.index >= h.startPiece){
					h.setPiece(event.params.index,1);
					if(h.hasAllPieces()){
						hls.streamBuffer.fragmentLoader.setIsLocal(i);
						q = new Quad((1720/numFragments),16,0x0186B3);
						q.x = (i*(1720/numFragments)) + 100;
						q.y = 850;
						progressHolder.addChild(q);
					}
					numMatches++;
					if(numMatches > 1)
						break;
				}
			}
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
			if(currentStatus){
				peersTxt.text = currentStatus.numPeers.toString();
				seedsTxt.text = currentStatus.numSeeds.toString();
				downTxt.text = TextUtils.bytesToString(currentStatus.downloadRate) + "/s";
				doneTxt.text = (currentStatus.progress >= 100) ? "100%" : currentStatus.progress.toFixed(1) + "%";
				statusTxt.text = TorrentStateCodes.getMessageFromCode(currentStatus.state);
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
			addBtn = createButton("Play");
			addBtn.addEventListener(TouchEvent.TOUCH,onPlayTouch);
			model.SettingsLocalStore.load(true);
			if(Installer.isAppInstalled()){
				onInstallComplete();
			}else{
				Installer.dispatcher.addEventListener(InstallEvent.ON_INSTALL_COMPLETE,onInstallComplete);
				Installer.install();
			}
			
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
			
			pieceBG.x = 100;
			pieceBG.y = 850;
			progressHolder.addChild(pieceBG);
			
			progressHolder.scaleY = progressHolder.scaleX = Starling.current.viewPort.width/1920; 
			
			addChild(progressHolder);
			
			hls = new HLS();
			hls.stage = Starling.current.nativeStage;
			
			HLSSettings.logDebug = false;
			HLSSettings.maxBufferLength = 20;
			hls.addEventListener(HLSEvent.MANIFEST_PARSED, manifestHandler);
			hls.addEventListener(HLSEvent.FRAGMENT_LOADED,onFragmentLoaded);
			hls.addEventListener(HLSEvent.FRAGMENT_LOADING,onFragmentLoading);
			hls.addEventListener(HLSEvent.ERROR,onHlsError);
			videoTexture = Texture.fromNetStream(hls.stream, Starling.current.contentScaleFactor, onTextureComplete);
			addBtn.x = (Starling.current.viewPort.width-320)/2;
			addBtn.y = 200;
			addChild(addBtn);
			
		}
		
		protected function onHlsError(event:HLSEvent):void {
			// TODO Auto-generated method stub
			trace(event);
		}
		protected function onInstallComplete(event:InstallEvent=null):void {
			if(bitTorrentANE.isSupported()){
				TorrentSettings.logLevel = LogLevel.DEBUG;
				TorrentSettings.clientName = "BitTorrentANE_Android_Example";
				TorrentSettings.storage.torrentPath = File.applicationStorageDirectory.resolvePath("torrents").nativePath;
				TorrentSettings.storage.resumePath = File.applicationStorageDirectory.resolvePath("torrents").resolvePath("resume").nativePath; //path where we save our "faststart" resume files
				TorrentSettings.storage.geoipDataPath = File.applicationStorageDirectory.resolvePath("geoip").nativePath;
				TorrentSettings.storage.sessionStatePath = File.applicationStorageDirectory.resolvePath("session").nativePath;
				TorrentSettings.storage.sparse = true;
				TorrentSettings.storage.enabled = true; //set to false for testing and benchmarking. No data is saved to disk.
				
				torrentUrl = TorrentSettings.storage.torrentPath + "/" + torrentId + ".torrent";

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

		protected function onTextureComplete():void {
			videoImage = new Image(videoTexture);
			videoImage.blendMode = BlendMode.NONE;
			videoImage.touchable = false;
			setSize();
			if(!this.contains(videoImage))
				this.addChildAt(videoImage,0);
		}
		public function setSize():void {
			var scaleFactor:Number = Starling.current.viewPort.width/videoTexture.nativeWidth;
			videoImage.scaleY = videoImage.scaleX = scaleFactor;
			
			if(videoTexture.nativeWidth == Starling.current.viewPort.width)
				videoImage.textureSmoothing = TextureSmoothing.NONE;
			else
				videoImage.textureSmoothing = TextureSmoothing.BILINEAR;
			
		}
		
		
		protected function onFragmentLoading(event:HLSEvent):void {
			//if from http get the pieces of this fragment and set to do now download
			
			trace("loading",event.url);
			
			if(event.url.indexOf("http") == 0){ //reset deadline
				var h:HLSMap;
				if(event.seqNum > -1){
					h = hlsMaps[event.seqNum];
					for(var k:int = h.startPiece;k < h.endPiece+1;k++){
					//for(var k:int = h.startPiece+1;k < h.endPiece;k++){
						bitTorrentANE.setPiecePriority(torrentId,k,PiecePriority.DO_NOT_DOWNLOAD);
						bitTorrentANE.resetPieceDeadline(torrentId,k);
					}
					var q:Quad;
					q = new Quad((1720/numFragments),16,0x0FFFFFF);
					q.x = (event.seqNum*(1720/numFragments))+100;
					q.y = 850;
					progressHolder.addChild(q);
					
				}
			}
			var hNext:HLSMap;
			if(event.seqNum < hlsMaps.length){
				hNext = hlsMaps[event.seqNum+1];
				for(var j:int = hNext.startPiece;j < hNext.endPiece+1;j++){
					bitTorrentANE.setPiecePriority(torrentId,j,PiecePriority.MAXIMUM);
					bitTorrentANE.setPieceDeadline(torrentId,j,10000); //10 seconds
				}
			}
			
			if(event.seqNum == 2){
				hls.stream.seek(60);
			}
			
		}
		
		protected function onFragmentLoaded(event:HLSEvent):void {
		}
		
		public function manifestHandler(event:HLSEvent) : void {
			var fragments:Vector.<Fragment> = event.levels[0].fragments;
			var hlsMap:HLSMap;
			var startPiece:int = 0;
			var endPiece:int = 0;
			numFragments = fragments.length;
			for each(var f:Fragment in fragments){
				hlsMap = new HLSMap();
				hlsMap.fragment = f;
				endPiece = Math.floor(f.byterange_end_offset/currentTorrentInfo.pieceLength);
				hlsMap.startPiece = startPiece;
				hlsMap.endPiece = endPiece;
				hlsMap.initPieces()
				hlsMaps.push(hlsMap);
				startPiece = endPiece;
			}
			hls.stream.play(null, -1);
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
			
			//trace(TorrentSettings.storage.outputPath);
			
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