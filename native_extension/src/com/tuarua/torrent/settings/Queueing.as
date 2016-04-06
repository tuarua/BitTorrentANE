package com.tuarua.torrent.settings {
	public class Queueing extends Object {
		public var enabled:Boolean = false;
		public var maxActiveDownloads:int = 3;
		public var maxActiveTorrents:int = 5;
		public var maxActiveUploads:int = 3;
		public var ignoreSlow:Boolean = false;
	}
}