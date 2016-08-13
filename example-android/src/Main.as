package
{
	import com.tuarua.BitTorrentANE;
	import com.tuarua.torrent.PeerInfo;
	import com.tuarua.torrent.TorrentInfo;
	import com.tuarua.torrent.TorrentPeers;
	import com.tuarua.torrent.TorrentSettings;
	import com.tuarua.torrent.TorrentStateCodes;
	import com.tuarua.torrent.TorrentStatus;
	import com.tuarua.torrent.TorrentsLibrary;
	import com.tuarua.torrent.constants.LogLevel;
	import com.tuarua.torrent.events.TorrentAlertEvent;
	import com.tuarua.torrent.events.TorrentInfoEvent;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import events.InstallEvent;
	
	import install.Installer;
	
	import model.SettingsLocalStore;
	
	[SWF(width = "720", height = "1280", frameRate = "60", backgroundColor = "#121314")]
	public class Main extends Sprite {
		private var bitTorrentANE:BitTorrentANE = new BitTorrentANE();
		private var initBtn:Sprite = new Sprite();
		
		private var btnHeight:int = 160;
		private var addBtn:Sprite = new Sprite();
		private var pauseBtn:Sprite = new Sprite();
		private var resumeBtn:Sprite = new Sprite();
		private var filterBtn:Sprite = new Sprite();
		
		private var torrentId:String;
		
		private var statusTimer:Timer;
		private var currentStatus:TorrentStatus;
		
		private var torrentUrl:String = "magnet:?xt=urn:btih:88594aaacbde40ef3e2510c47374ec0aa396c08e&dn=bbb%5Fsunflower%5F1080p%5F30fps%5Fnormal.mp4&tr=udp%3A%2F%2Ftracker.openbittorrent.com%3A80%2Fannounce&tr=udp%3A%2F%2Ftracker.publicbt.com%3A80%2Fannounce&ws=http%3A%2F%2Fdistribution.bbb3d.renderfarming.net%2Fvideo%2Fmp4%2Fbbb%5Fsunflower%5F1080p%5F30fps%5Fnormal.mp4";
		//gimp
		//private var torrentUrl:String = "magnet:?xt=urn:btih:85cd5e9435d68eb255dade6c1ff8fadda0ecbda3&dn=gimp-2.8.16-setup-6.exe&tr=udp%3a%2f%2ftracker.openbittorrent.com%3a80&tr=udp%3a%2f%2fopen.demonii.com%3a1337&tr=udp%3a%2f%2ftracker.coppersurfer.tk%3a6969&tr=udp%3a%2f%2ftracker.leechers-paradise.org%3a6969&ws=http%3a%2f%2fartfiles.org%2fgimp.org%2fv2.8%2fwindows%2f&ws=http%3a%2f%2fde-mirror.gimper.net%2fpub%2fgimp%2fv2.8%2fwindows%2f&ws=http%3a%2f%2fdownload.gimp.org%2fpub%2fgimp%2fv2.8%2fwindows%2f&ws=http%3a%2f%2fftp.cc.uoc.gr%2fmirrors%2fgimp%2fv2.8%2fwindows%2f&ws=http%3a%2f%2fftp.fernuni-hagen.de%2fftp-dir%2fpub%2fmirrors%2fwww.gimp.org%2fv2.8%2fwindows%2f&ws=http%3a%2f%2fftp.gwdg.de%2fpub%2fmisc%2fgrafik%2fgimp%2fv2.8%2fwindows%2f&ws=http%3a%2f%2fftp.heanet.ie%2fmirrors%2fftp.gimp.org%2fpub%2fgimp%2fv2.8%2fwindows%2f&ws=http%3a%2f%2fftp.iut-bm.univ-fcomte.fr%2fgimp%2fv2.8%2fwindows%2f&ws=http%3a%2f%2fftp.nluug.nl%2fgraphics%2fgimp%2fv2.8%2fwindows%2f&ws=http%3a%2f%2fftp.snt.utwente.nl%2fpub%2fsoftware%2fgimp%2fgimp%2fv2.8%2fwindows%2f&ws=http%3a%2f%2fftp.sunet.se%2fpub%2fgnu%2fgimp%2fv2.8%2fwindows%2f&ws=http%3a%2f%2fgimp.afri.cc%2fpub%2fgimp%2fv2.8%2fwindows%2f&ws=http%3a%2f%2fgimp.cp-dev.com%2fv2.8%2fwindows%2f&ws=http%3a%2f%2fgimp.cybermirror.org%2fv2.8%2fwindows%2f&ws=http%3a%2f%2fgimp.mirrors.hoobly.com%2fgimp%2fv2.8%2fwindows%2f&ws=http%3a%2f%2fgimp.parentingamerica.com%2fv2.8%2fwindows%2f&ws=http%3a%2f%2fgimp.raffsoftware.com%2fv2.8%2fwindows%2f&ws=http%3a%2f%2fgimp.skazkaforyou.com%2fv2.8%2fwindows%2f&ws=http%3a%2f%2fgimper.net%2fdownloads%2fpub%2fgimp%2fv2.8%2fwindows%2f&ws=http%3a%2f%2fmirror.hessmo.com%2fgimp%2fv2.8%2fwindows%2f&ws=http%3a%2f%2fmirror.ibcp.fr%2fpub%2fgimp%2fv2.8%2fwindows%2f&ws=http%3a%2f%2fmirror.umd.edu%2fgimp%2fgimp%2fv2.8%2fwindows%2f&ws=http%3a%2f%2fmirrors-br.go-parts.com%2fgimp%2fv2.8%2fwindows%2f&ws=http%3a%2f%2fmirrors.dominios.pt%2fgimpv2.8%2fwindows%2f&ws=http%3a%2f%2fmirrors.fe.up.pt%2fmirrors%2fftp.gimp.org%2fv2.8%2fwindows%2f&ws=http%3a%2f%2fmirrors.serverhost.ro%2fgimp%2fv2.8%2fwindows%2f&ws=http%3a%2f%2fmirrors.xmission.com%2fgimp%2fv2.8%2fwindows%2f&ws=http%3a%2f%2fmirrors.zerg.biz%2fgimp%2fv2.8%2fwindows%2f&ws=http%3a%2f%2fpiotrkosoft.net%2fpub%2fmirrors%2fftp.gimp.org%2fv2.8%2fwindows%2f&ws=http%3a%2f%2fservingzone.com%2fmirrors%2fgimp%2fv2.8%2fwindows%2f&ws=http%3a%2f%2fsunsite.rediris.es%2fmirror%2fgimp%2fv2.8%2fwindows%2f&ws=http%3a%2f%2fwww.mirrorservice.org%2fsites%2fftp.gimp.org%2fpub%2fgimp%2fv2.8%2fwindows%2f&ws=http%3a%2f%2fwww.ring.gr.jp%2fpub%2fgraphics%2fgimp%2fv2.8%2fwindows%2f";
		
		//private var torrentUrl:String = "http://distribution.bbb3d.renderfarming.net/video/mp4/bbb_sunflower_1080p_30fps_normal.mp4.torrent";
		
		public function Main()
		{
			super();
			
			
			model.SettingsLocalStore.load(true);
			
			if(Installer.isAppInstalled()){
				
			}else{
				Installer.dispatcher.addEventListener(InstallEvent.ON_INSTALL_COMPLETE,onInstallComplete);
				Installer.install();
			}
			
			// support autoOrients
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			addBtn = createButton("Add",20);
			addBtn.addEventListener(MouseEvent.CLICK,onAddClick);
			
			pauseBtn = createButton("Pause",220);
			pauseBtn.addEventListener(MouseEvent.CLICK,onPauseClick);
			
			resumeBtn = createButton("Resume",420);
			resumeBtn.addEventListener(MouseEvent.CLICK,onResumeClick);
			
			filterBtn = createButton("Add Filters",620);
			filterBtn.addEventListener(MouseEvent.CLICK,onFilterClick);
			
		
			trace(Capabilities.cpuArchitecture);
		
			//bitTorrentANE.addEventListener(TorrentInfoEvent.TORRENT_CREATED_FROM_META,onMagnetSaved);
			
			bitTorrentANE.addEventListener(TorrentAlertEvent.STATE_UPDATE,onTorrentStateUpdate);
			bitTorrentANE.addEventListener(TorrentAlertEvent.STATE_CHANGED,onTorrentStateChanged);
			bitTorrentANE.addEventListener(TorrentAlertEvent.PEERS_UPDATE,onTorrentPeersUpdate);
			bitTorrentANE.addEventListener(TorrentAlertEvent.TORRENT_ADDED,onTorrentAdded);
			bitTorrentANE.addEventListener(TorrentAlertEvent.TORRENT_PAUSED,onTorrentPaused);
			bitTorrentANE.addEventListener(TorrentAlertEvent.TORRENT_RESUMED,onTorrentResumed);
			bitTorrentANE.addEventListener(TorrentAlertEvent.TORRENT_FINISHED,onTorrentFinished);
			bitTorrentANE.addEventListener(TorrentInfoEvent.FILTER_LIST_ADDED,onFilterListAdded);
			bitTorrentANE.addEventListener(TorrentAlertEvent.LISTEN_SUCCEEDED,onListenSucceded);
			bitTorrentANE.addEventListener(TorrentAlertEvent.LISTEN_FAILED,onListenFailed);
			
		}
		
		protected function onListenSucceded(event:TorrentAlertEvent):void {
			trace("Listening on",event.params.address+":"+event.params.port,event.params.type);
			addChild(addBtn);
			addChild(pauseBtn);
			addChild(resumeBtn);
			addChild(filterBtn);
		}
		protected function onListenFailed(event:TorrentAlertEvent):void {
			trace("Failed on",event.params.address+":"+event.params.port,event.params.type);
			trace(event.params.message);
		}
		protected function onInstallComplete(event:InstallEvent):void {
			init();
		}
		
		protected function onResumeClick(event:MouseEvent):void {
			bitTorrentANE.resumeTorrent(torrentId);
		}
		protected function onFilterClick(event:MouseEvent):void {
			bitTorrentANE.addFilterList(model.SettingsLocalStore.settings.filters.fileName,false);
		}
		
		protected function onPauseClick(event:MouseEvent):void {
			var result:Boolean = bitTorrentANE.pauseTorrent(torrentId);
			trace("result of pauseClick",result);
			
		}
		
		protected function onAddClick(event:MouseEvent):void {
			trace(event);
			bitTorrentANE.addTorrent("thisIsMyID",torrentUrl);
		}
		
		protected function onTorrentStateUpdate(event:TorrentAlertEvent):void {
			trace(event);
			
			currentStatus = TorrentsLibrary.status[torrentId] as TorrentStatus;
			if(currentStatus){
				trace("currentStatus.downloaded",currentStatus.downloaded);
				trace("currentStatus.numPieces",currentStatus.numPieces);
				trace("currentStatus.state",TorrentStateCodes.getMessageFromCode(currentStatus.state)); 
			}
			
			
		}
		
		
		protected function onFilterListAdded(event:TorrentInfoEvent):void {
			trace(event.params.numFilters,"filters added");
		}
		protected function onTorrentFinished(event:TorrentAlertEvent):void {
			trace(event);
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
		protected function onTorrentPeersUpdate(event:TorrentAlertEvent):void {
			trace(event);
			var tpDict:Dictionary = TorrentsLibrary.peers;
			
			var tp:TorrentPeers = TorrentsLibrary.peers[torrentId] as TorrentPeers;
			if(tp){
				trace("tp id",tp.id);
				trace("tp.peersInfo.length",tp.peersInfo.length);
				for each(var pi:PeerInfo in tp.peersInfo){
					trace(pi.ip);
					trace(pi.connection);
					trace(pi.client);
				}
				
			}
		}
		protected function onTorrentAdded(event:TorrentAlertEvent):void {
			trace(event);
			torrentId = event.params.id;
			bitTorrentANE.queryForPeers(true);
			bitTorrentANE.queryForTrackers(false); //torrentId
			
			
			trace("torrentId",torrentId);
			trace();
			//startStatusListener();
		}
	
	
		private function init():void {
			trace("bitTorrentANE.isSupported()",bitTorrentANE.isSupported());
			if(bitTorrentANE.isSupported()){
				
				//move to cliick 3
				TorrentSettings.logLevel = LogLevel.INFO;
				TorrentSettings.prioritizedFileTypes = new Array("mp4"); 
				TorrentSettings.clientName = "BitTorrentANE_Android_Example";
				TorrentSettings.storage.torrentPath = File.applicationStorageDirectory.resolvePath("torrents").nativePath;
				TorrentSettings.storage.resumePath = File.applicationStorageDirectory.resolvePath("torrents").resolvePath("resume").nativePath; //path where we save our "faststart" resume files
				TorrentSettings.storage.geoipDataPath = File.applicationStorageDirectory.resolvePath("geoip").nativePath;
				TorrentSettings.storage.sessionStatePath = File.applicationStorageDirectory.resolvePath("session").nativePath;
				TorrentSettings.storage.sparse = false;
				TorrentSettings.storage.enabled = true; //set to false for testing and benchmarking. No data is saved to disk.
				
				//trace(TorrentSettings.storage.torrentPath);
				
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
		
		private function createButton(lbl:String,y:int):Sprite {
			var spr:Sprite = new Sprite();
			
			spr.graphics.beginFill(0xF73307);
			spr.graphics.drawRect(20,y,400,btnHeight);
			spr.graphics.endFill();
			var tf:TextFormat = new TextFormat();
			tf.size = 40;
			tf.color = 0xFFFFFF;
			
			var txt:TextField = new TextField();
			txt.width = 400;
			txt.defaultTextFormat = tf;
			txt.text = lbl;
			txt.x = 40;
			txt.y = y + 20;
			txt.selectable = false;
			
			spr.addChild(txt);
			spr.cacheAsBitmap = true;
			
			return spr;
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
	}
}