package com.tuarua.torrent {
	[RemoteClass(alias="com.tuarua.torrent.TorrentTrackers")]
	public class TorrentTrackers extends Object {
		public var id:String;
		public var trackersInfo:Vector.<TrackerInfo> = new Vector.<TrackerInfo>();
	}
}