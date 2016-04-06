package com.tuarua.torrent {
	[RemoteClass(alias="com.tuarua.torrent.TorrentFileMeta")]
	public class TorrentFileMeta extends Object {
		public var path:String;
		public var name:String;
		public var offset:uint;
		public var size:uint;
		public var firstPiece:uint;
		public var lastPiece:uint;
		public var numPieces:uint;
		public function getExtension():String {
			return path.substring(path.lastIndexOf(".")+1, path.length);
		}
	}
}