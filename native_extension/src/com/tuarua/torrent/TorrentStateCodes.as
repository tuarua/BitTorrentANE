package com.tuarua.torrent {
	public final class TorrentStateCodes {
		/**
		 * <p>The torrent is in the queue for being checked. But there
		 * currently is another torrent that are being checked.
		 * This torrent will wait for its turn.</p> 
		 */	
		public static const QUEUED_FOR_CHECKING:int = 0;
		/**
		 * <p>The torrent has not started its download yet, and is
		 * currently checking existing files.</p> 
		 */	
		public static const CHECKING_FILES:int = 1;
		/**
		 * <p>The torrent is trying to download metadata from peers.
		 * This assumes the metadata_transfer extension is in use.</p> 
		 */	
		public static const DOWNLOADING_METADATA:int = 2;
		/**
		 * <p>The torrent is being downloaded. This is the state
		 * most torrents will be in most of the time. The progress
		 * meter will tell how much of the files that has been
		 * downloaded.</p> 
		 */	
		public static const DOWNLOADING:int = 3;
		/**
		 * <p>In this state the torrent has finished downloading but
		 * still doesn't have the entire torrent. i.e. some pieces
		 * are filtered and won't get downloaded.</p> 
		 */	
		public static const FINISHED:int = 4;
		/**
		 * <p>In this state the torrent has finished downloading and
		 * is a pure seeder.</p> 
		 */	
		public static const SEEDING:int = 5;
		/**
		 * <p>If the torrent was started in full allocation mode, this
		 * indicates that the (disk) storage for the torrent is
		 * allocated.</p> 
		 */	
		public static const ALLOCATING:int = 6;
		/**
		 * <p>The torrent is currently checking the fastresume data and
		 * comparing it to the files on disk. This is typically
		 * completed in a fraction of a second, but if you add a
		 * large number of torrents at once, they will queue up.</p> 
		 */	
		public static const CHECKING_RESUME_DATA:int = 7;
		/**
		 * <p>The torrent is queued</p> 
		 */
		public static const QUEUED:int = 8;
		/**
		 * <p>The torrent is paused</p> 
		 */	
		public static const PAUSED:int = 9;
		private static const codes:Array = ["Queued for checking","Checking files","Downloading metadata","Downloading","Finished","Seeding","Allocating","Checking resume data","Queued","Paused"];
		/**
		 * 
		 * @param state As per <code>TorrentStatus.state</code>
		 * @return Friendly message for the state
		 * 
		 */		
		public static function getMessageFromCode(state:int):String {
			return codes[state];
		}
	}
	
}