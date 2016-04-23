package com.tuarua {
	import com.tuarua.torrent.TorrentDownloader;
	import com.tuarua.torrent.TorrentMeta;
	import com.tuarua.torrent.TorrentPeers;
	import com.tuarua.torrent.TorrentPieces;
	import com.tuarua.torrent.TorrentSettings;
	import com.tuarua.torrent.TorrentStatus;
	import com.tuarua.torrent.TorrentTracker;
	import com.tuarua.torrent.TorrentTrackers;
	import com.tuarua.torrent.TorrentWebSeed;
	import com.tuarua.torrent.TorrentsLibrary;
	import com.tuarua.torrent.events.TorrentInfoEvent;
	import com.tuarua.torrent.utils.MagnetParser;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.external.ExtensionContext;
	import flash.filesystem.File;
	import flash.utils.Timer;
	
	public class BitTorrentANE extends EventDispatcher {
		private var extensionContext:ExtensionContext;
		private var alertListenerTimer:Timer;
		private var _inited:Boolean = false;
		private var alertInterval:int = 1000;
		public function BitTorrentANE(target:IEventDispatcher=null) {
			initiate();
		}
		protected function initiate():void {
			trace("[BitTorrentANE] Initalizing ANE...");
			try {
				extensionContext = ExtensionContext.createExtensionContext("com.tuarua.BitTorrentANE", null);
				extensionContext.addEventListener(StatusEvent.STATUS, gotEvent);
			} catch (e:Error) {
				trace("[BitTorrentANE] ANE Not loaded properly.  Future calls will fail.");
			}
		}
		protected function gotEvent(event:StatusEvent):void {
			var tp:TorrentPieces;
			var pObj:Object;
			switch (event.level) {
				case "TRACE":
					trace(event.code);
					break;
				case "INFO":
					trace("INFO:",event.code);
					break;
				case TorrentInfoEvent.ON_ERROR:
					trace(event.code);
					this.dispatchEvent(new TorrentInfoEvent(TorrentInfoEvent.ON_ERROR,{message:event.code}));
					break;
				case TorrentInfoEvent.TORRENT_PIECE:
					pObj = JSON.parse(event.code);
					tp = TorrentsLibrary.pieces[pObj.id] as TorrentPieces;
					if(tp)
						tp.setDownloaded(pObj.index);
					break;
				case TorrentInfoEvent.TORRENT_CREATED_FROM_META:
					this.dispatchEvent(new TorrentInfoEvent(TorrentInfoEvent.TORRENT_CREATED_FROM_META,JSON.parse(event.code)));
					break;
				case TorrentInfoEvent.TORRENT_CREATION_PROGRESS:
					this.dispatchEvent(new TorrentInfoEvent(TorrentInfoEvent.TORRENT_CREATION_PROGRESS,JSON.parse(event.code)));
					break;
				case TorrentInfoEvent.TORRENT_CREATED:
					this.dispatchEvent(new TorrentInfoEvent(TorrentInfoEvent.TORRENT_CREATED,JSON.parse(event.code)));
					break;
				case TorrentInfoEvent.TORRENT_FROM_RESUME:
					break;
				case TorrentInfoEvent.RESUME_SAVED:
					break;
				case TorrentInfoEvent.TORRENT_CHECKED:
					pObj = JSON.parse(event.code);
					tp = new TorrentPieces(pObj.pieces);
					TorrentsLibrary.updatePieces(pObj.id,tp);
					break;
				case TorrentInfoEvent.DHT_STARTED:
					this.dispatchEvent(new TorrentInfoEvent(TorrentInfoEvent.DHT_STARTED));
					break;
				case TorrentInfoEvent.FILTERLIST_ADDED:
					this.dispatchEvent(new TorrentInfoEvent(TorrentInfoEvent.FILTERLIST_ADDED,JSON.parse(event.code)));
					break;
				case TorrentInfoEvent.TORRENT_ADDED:
					this.dispatchEvent(new TorrentInfoEvent(TorrentInfoEvent.TORRENT_ADDED,JSON.parse(event.code)));
					break;
				case TorrentInfoEvent.RSS_STATE_CHANGE:
					this.dispatchEvent(new TorrentInfoEvent(TorrentInfoEvent.RSS_STATE_CHANGE,JSON.parse(event.code)));
					break;
				case TorrentInfoEvent.RSS_ITEM:
					this.dispatchEvent(new TorrentInfoEvent(TorrentInfoEvent.RSS_ITEM,JSON.parse(event.code)));
					break;
			}
		}
		private function startAlertListener():void {
			alertListenerTimer = new Timer(alertInterval);
			alertListenerTimer.addEventListener(TimerEvent.TIMER,onAlertListenerTimer);
			alertListenerTimer.start();
		}
		private function stopAlertListener():void {
			if(alertListenerTimer){
				alertListenerTimer.removeEventListener(TimerEvent.TIMER,onAlertListenerTimer);
				alertListenerTimer.stop();
				alertListenerTimer.reset();
				alertListenerTimer = null;
			}
		}
		public function addDHTRouter(url:String):void {
			extensionContext.call("addDHTRouter",url);
		}
		public function initSession():Boolean {
			_inited = extensionContext.call("initSession");
			startAlertListener();
			return _inited;
		}
		public function saveSessionState():void {
			extensionContext.call("saveSessionState");
		}
		public function endSession():void {
			stopAlertListener();
			extensionContext.call("endSession");
			_inited = false;
		}
		public function getTorrentMeta(filename:String):TorrentMeta {
			var torrentMeta:TorrentMeta = extensionContext.call("getTorrentMeta",filename) as TorrentMeta;
			return torrentMeta;
		}
		public function downloadTorrent(id:String,uri:String,sequential:Boolean,toQueue:Boolean=false,trackers:Vector.<TorrentTracker>=null):void {
			var downloader:TorrentDownloader = new TorrentDownloader(id,uri,sequential,toQueue,trackers);
			downloader.addEventListener(TorrentInfoEvent.TORRENT_DOWNLOADED,onFileDownloaded);
		}
		protected function onFileDownloaded(event:TorrentInfoEvent):void {
			addTorrent(event.params.filename,event.params.id,getTorrentMeta(event.params.filename).infoHash,event.params.sequential,event.params.toQueue,event.params.trackers,false);
			this.dispatchEvent(event);
		}
		public function addTorrent(filename:String,id:String,hash:String,sequential:Boolean,toQueue:Boolean=false,trackers:Vector.<TorrentTracker>=null,seedMode:Boolean=false):void {
			extensionContext.call("addTorrent",filename,id,hash,sequential,toQueue,trackers,seedMode);
		}
		public function setSequentialDownload(id:String,value:Boolean):void {
			extensionContext.call("setSequentialDownload",id,value);
		}
		public function pauseTorrent(id:String=null):void {
			if(extensionContext)
				extensionContext.call("pauseTorrent",(id) ? id : "");
		}
		public function getMagnetURI(id:String):String{
			var ret:String;
			if(extensionContext)
				ret = extensionContext.call("getMagnetURI",id) as String;
			return ret;
		}
		
		public function resumeTorrent(id:String=null):void {
			if(extensionContext)
				extensionContext.call("resumeTorrent",(id) ? id : "");
		}
		public function setQueuePosition(id:String,direction:int):void {
			if(extensionContext)
				extensionContext.call("setQueuePosition",id,direction);
		}
		public function removeTorrent(id:String):void {
			TorrentsLibrary.remove(id);
			if(extensionContext)
				extensionContext.call("removeTorrent",id);
		}
		public function getTorrentStatus():void {
			var vecStatus:Vector.<TorrentStatus> = extensionContext.call("getTorrentStatus") as Vector.<TorrentStatus>;
			for (var i:int=0, l:int=vecStatus.length; i<l; ++i)
				TorrentsLibrary.updateStatus(vecStatus[i].id,vecStatus[i]);
		}
		public function getTorrentPeers(queryFlags:Boolean=true):void {
			var vecPeers:Vector.<TorrentPeers> = extensionContext.call("getTorrentPeers",queryFlags) as Vector.<TorrentPeers>;
			for (var i:int=0, l:int=vecPeers.length; i<l; ++i)
				TorrentsLibrary.updatePeers(vecPeers[i].id,vecPeers[i]);
		}
		public function getTorrentTrackers():void {
			var vecTrackers:Vector.<TorrentTrackers> = extensionContext.call("getTorrentTrackers") as Vector.<TorrentTrackers>;
			for (var i:int=0, l:int=vecTrackers.length; i<l; ++i)
				TorrentsLibrary.updateTrackers(vecTrackers[i].id,vecTrackers[i]);
		}
		public function torrentFromHash(id:String,hash:String,name:String,sequential:Boolean=false,toQueue:Boolean=false,trackers:Vector.<TorrentTracker>=null):void {
			var torrentFile:File = File.applicationDirectory.resolvePath(TorrentSettings.storage.torrentPath).resolvePath(id+".torrent");
			if(torrentFile.exists)
				addTorrent(torrentFile.nativePath,id,hash,sequential,toQueue,trackers);
			else if(!_inited)
				this.dispatchEvent(new TorrentInfoEvent(TorrentInfoEvent.TORRENT_UNAVAILABLE));
			else
				extensionContext.call("torrentFromMagnet","magnet:?xt=urn:btih:"+encodeURIComponent(hash)+"&dn="+encodeURIComponent(name),id,hash,sequential,toQueue,trackers);
		}
		public function torrentFromMagnet(uri:String,id:String,sequential:Boolean=false,toQueue:Boolean=false,trackers:Vector.<TorrentTracker>=null):void {
			var torrentFile:File = File.applicationDirectory.resolvePath(TorrentSettings.storage.torrentPath).resolvePath(id+".torrent");
			if(torrentFile.exists)
				addTorrent(torrentFile.nativePath,id,MagnetParser.parse(uri).hash,sequential,toQueue,trackers);
			else if(!_inited)
				this.dispatchEvent(new TorrentInfoEvent(TorrentInfoEvent.TORRENT_UNAVAILABLE));
			else
				extensionContext.call("torrentFromMagnet",uri,id,MagnetParser.parse(uri).hash,sequential,toQueue,trackers);
		}
		//pieceSize is in KiB
		public function createTorrent(input:String,output:String,pieceSize:int,trackers:Vector.<TorrentTracker>,webSeeds:Vector.<TorrentWebSeed>,isPrivate:Boolean=false,comment:String=null,seedNow:Boolean=false,rootCert:String=null):void {
			if(pieceSize % 16 > 0) throw new Error("pieceSize must be a miltiple of 16");
			extensionContext.call("createTorrent",input,output,trackers,webSeeds,pieceSize,isPrivate,comment,seedNow,rootCert);
		}
		
		protected function onAlertListenerTimer(event:TimerEvent):void {
			if(extensionContext)
				extensionContext.call("listenForAlert");
		}
		
		public function isSupported():Boolean {
			return extensionContext.call("isSupported"); 
		}
		public function updateSettings():void {
			extensionContext.call("updateSettings",TorrentSettings);
		}
		public function addRSS(uri:String,refresh:int=30,autoDownload:Boolean=true):void {
			extensionContext.call("addRSS",uri,refresh,autoDownload);
		}
		public function addFilterList(filename:String,applyToTrackers:Boolean):void {
			var validFile:Boolean;
			var check:String = ".p2p";
			var end:int = filename.lastIndexOf(check);
			validFile = (end == -1);
			validFile = (end == filename.length-check.length);
			validFile = new File(filename).exists;
			if(validFile)
				extensionContext.call("addFilterList",filename,applyToTrackers);
			else
				this.dispatchEvent(new TorrentInfoEvent(TorrentInfoEvent.ON_ERROR,{message:"only .p2p filters are allowed and file must exist"}));
		}
		
		public function dispose():void {
			stopAlertListener();
			if (!extensionContext) {
				trace("[BitTorrentANE] Error. ANE Already in a disposed or failed state...");
				return;
			}
			trace("[BitTorrentANE] Unloading ANE...");
			extensionContext.removeEventListener(StatusEvent.STATUS, gotEvent);
			extensionContext.dispose();
			extensionContext = null;
		}
		
		public function get inited():Boolean {
			return _inited;
		}
	}
}