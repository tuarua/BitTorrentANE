package com.tuarua.torrent {
	[RemoteClass(alias="com.tuarua.torrent.TorrentPeers")]
	public class TorrentPeers extends Object {
		public var id:String;
		public var peersInfo:Vector.<PeerInfo> = new Vector.<PeerInfo>();	
	}
}