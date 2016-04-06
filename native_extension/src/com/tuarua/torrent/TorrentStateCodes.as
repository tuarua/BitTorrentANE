package com.tuarua.torrent {
	public final class TorrentStateCodes {
		public static const QUEUED_FOR_CHECKING:int = 0;
		public static const CHECKING_FILES:int = 1;
		public static const DOWNLOADING_METADATA:int = 2;
		public static const DOWNLOADING:int = 3;
		public static const FINISHED:int = 4;
		public static const SEEDING:int = 5;
		public static const ALLOCATING:int = 6;
		public static const CHECKING_RESUME_DATA:int = 7;
		public static const QUEUED:int = 8;
		public static const PAUSED:int = 9;
		private static const codes:Array = ["Queued for checking","Checking files","Downloading metadata","Downloading","Finished","Seeding","Allocating","Checking resume data","Queued","Paused"];
		public static function getMessageFromCode(_n:int):String{
			return codes[_n];
		}
	}
	
}