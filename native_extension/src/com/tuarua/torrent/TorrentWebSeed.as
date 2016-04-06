package com.tuarua.torrent {
	[RemoteClass(alias="com.tuarua.torrent.TorrentWebSeed")]
	public class TorrentWebSeed {
		public var uri:String;
		public function TorrentWebSeed(_uri:String) {
			uri = _uri;
		}
	}
}