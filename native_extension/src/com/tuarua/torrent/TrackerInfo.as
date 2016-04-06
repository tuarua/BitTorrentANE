package com.tuarua.torrent {
	[RemoteClass(alias="com.tuarua.torrent.TrackerInfo")]
	public class TrackerInfo extends Object{
		public var tier:int;
		public var url:String;
		public var status:String;
		public var numPeers:int;
		public var message:String;	
	}
}