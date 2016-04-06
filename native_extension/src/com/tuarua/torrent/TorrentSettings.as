package com.tuarua.torrent {
	import com.tuarua.torrent.constants.LogLevel;
	import com.tuarua.torrent.settings.Advanced;
	import com.tuarua.torrent.settings.Connections;
	import com.tuarua.torrent.settings.Listening;
	import com.tuarua.torrent.settings.Privacy;
	import com.tuarua.torrent.settings.Proxy;
	import com.tuarua.torrent.settings.Queueing;
	import com.tuarua.torrent.settings.Speed;
	import com.tuarua.torrent.settings.Storage;

	[RemoteClass(alias="com.tuarua.torrent.TorrentSettings")]
	public class TorrentSettings extends Object {
		public static var logLevel:int = LogLevel.INFO;
		public static var prioritizedFileTypes:Array = new Array();
		public static var storage:Storage = new Storage();
		public static var queueing:Queueing = new Queueing();
		public static var privacy:Privacy = new Privacy();
		public static var listening:Listening = new Listening();
		public static var proxy:Proxy = new Proxy();
		public static var speed:Speed = new Speed();
		public static var connections:Connections = new Connections();
		public static var advanced:Advanced = new Advanced();
		
	}
}