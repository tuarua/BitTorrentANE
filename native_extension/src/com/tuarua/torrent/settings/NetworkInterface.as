package com.tuarua.torrent.settings {
	[RemoteClass(alias="com.tuarua.torrent.settings.NetworkInterface")]
	public class NetworkInterface extends Object {
		public var name:String;
		public var addresses:Vector.<NetworkAddress> = new Vector.<NetworkAddress>();
		/** 
		 * This method is omitted from the output. * * @private 
		 */ 
		public function NetworkInterface(){}
	}
}