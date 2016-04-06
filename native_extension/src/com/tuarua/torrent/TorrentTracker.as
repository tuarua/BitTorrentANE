package com.tuarua.torrent {
	[RemoteClass(alias="com.tuarua.torrent.TorrentTracker")]
	public class TorrentTracker {
		public var uri:String;
		public function TorrentTracker(_uri:String) {
			uri = _uri;
		}
	}
}