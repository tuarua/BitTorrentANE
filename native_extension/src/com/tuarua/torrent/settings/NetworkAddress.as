package com.tuarua.torrent.settings {
	[RemoteClass(alias="com.tuarua.torrent.settings.NetworkAddress")]
	public class NetworkAddress extends Object {
		public var address:String;
		/**
		 * <p>IPv4 or IPv6</p> 
		 */
		public var ipVersion:String;
		/**
		 * 
		 * @param _address
		 * @param _ipVersion IPv4 or IPv6
		 * 
		 */		
		public function NetworkAddress(_address:String,_ipVersion:String){
			address = _address;
			ipVersion = _ipVersion;
		}
	}
}