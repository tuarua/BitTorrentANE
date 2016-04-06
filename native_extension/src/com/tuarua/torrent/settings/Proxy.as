package com.tuarua.torrent.settings {
	import com.tuarua.torrent.constants.ProxyType;
	public class Proxy extends Object {
		public var type:int = ProxyType.DISABLED;
		public var port:int = 8080;
		public var host:String = "0.0.0.0";
		public var useForPeerConnections:Boolean = false;
		public var force:Boolean = false;
		public var useAuth:Boolean = false;
		public var username:String = "";
		public var password:String = ""; 
	}
}