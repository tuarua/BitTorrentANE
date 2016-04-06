package com.tuarua.torrent{
	[RemoteClass(alias="com.tuarua.torrent.TorrentMeta")]
	public class TorrentMeta extends Object {
		public var status:String;
		public var torrentFile:String;
		public var numPieces:uint;
		public var infoHash:String;
		public var isPrivate:Boolean;
		public var pieceLength:uint;
		public var size:uint;
		public var name:String;
		public var comment:String;
		public var creator:String;
		public var creationDate:uint;
		public var files:Vector.<TorrentFileMeta> = new Vector.<TorrentFileMeta>();
		public var urlSeeds:Vector.<String> = new Vector.<String>();
		public function getFileByExtension(_extension:Array):TorrentFileMeta {
			var ret:TorrentFileMeta;
			for (var i:int=0, l:int=this.files.length; i<l; ++i){
				if(_extension.indexOf(this.files[i].getExtension()) > -1 && this.files[i].path.lastIndexOf("sample") == -1) {
					return files[i];
					break;
				}
			}
			return ret;
		}
	}
}