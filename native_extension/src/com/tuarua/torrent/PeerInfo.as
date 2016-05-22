package com.tuarua.torrent {
	[RemoteClass(alias="com.tuarua.torrent.PeerInfo")]
	public class PeerInfo extends Object {
		public var ip:String;
		public var country:String;
		public var asName:String;
		public var port:int;
		public var localPort:int;
		public var connection:String; //convert to constant
		public var flagsAsString:String;
		public var flags:PeerFlags;
		public var client:String;
		public var progress:Number=-1.0; //TO DO
		
		public var downSpeed:int; //bytes per sec
		public var downloaded:int; //bytes
		public var upSpeed:int; //bytes per sec
		public var uploaded:int; //bytes
		
		public var relevance:Number=-1.0; 
	}
}