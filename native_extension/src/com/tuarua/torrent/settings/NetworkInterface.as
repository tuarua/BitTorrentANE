package com.tuarua.torrent.settings {
	[RemoteClass(alias="com.tuarua.torrent.settings.NetworkInterface")]
	public class NetworkInterface extends Object {
		public var name:String;
		public var addresses:Vector.<NetworkAddress> = new Vector.<NetworkAddress>();
	}
}