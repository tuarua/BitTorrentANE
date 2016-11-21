package com.tuarua.torrent {
	[RemoteClass(alias="com.tuarua.torrent.TorrentPeers")]
	public class TorrentPeers extends Object {
		public var id:String;
		public var peersInfo:Vector.<PeerInfo> = new Vector.<PeerInfo>();
		/** 
		 * This method is omitted from the output. * * @private 
		 */ 
		public function TorrentPeers(){}
	}
}