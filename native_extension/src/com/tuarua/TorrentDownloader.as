package com.tuarua {
	import com.tuarua.torrent.events.TorrentInfoEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	import com.tuarua.torrent.TorrentSettings;
	
	internal class TorrentDownloader extends EventDispatcher {
		private var _uri:String;
		private var _id:String;
		private var _fileName:String;
		private var _isSequential:Boolean;
		public function TorrentDownloader(id:String,uri:String,sequential:Boolean=true) {
			_id = id;
			_uri = uri;
			_isSequential = sequential;
			var fNameArr:Array = _uri.split("/"); //fix this to use resolve path
			_fileName = fNameArr[fNameArr.length-1];
			var urlStream:URLStream = new URLStream();
			urlStream.addEventListener(Event.COMPLETE, onTorrentFileLoaded);
			urlStream.addEventListener(IOErrorEvent.IO_ERROR, onError);
			urlStream.load(new URLRequest(_uri)); 
		}
		
		protected function onError(event:IOErrorEvent):void {
			trace(".torrent download failed");
		}
		protected function onTorrentFileLoaded(event:Event):void {
			var fileData:ByteArray = new ByteArray();
			event.target.readBytes(fileData, 0, event.target.bytesAvailable);
			var file:File = File.applicationStorageDirectory.resolvePath(TorrentSettings.storage.torrentPath).resolvePath(_fileName);
			var fileStream:FileStream = new FileStream(); 
			fileStream.open(file, FileMode.WRITE); 
			fileStream.writeBytes(fileData, 0, fileData.length); 
			fileStream.close();
			var obj:Object = new Object();
			obj.filename = file.url;
			obj.id = _id;
			obj.sequential = _isSequential;
			this.dispatchEvent(new TorrentInfoEvent(TorrentInfoEvent.TORRENT_DOWNLOADED,obj));
		}
	}
}