package com.tuarua.torrent {
	[RemoteClass(alias="com.tuarua.torrent.TorrentStatus")]
	public class TorrentStatus extends Object {
		public var id:String;
		public var infoHash:String;
		public var numPieces:uint=0;
		public var isFinished:Boolean;
		public var state:int;
		public var queuePosition:int=0;
		public var progress:Number;
		public var downloadRate:uint=0;
		public var downloadRateAverage:uint=0;
		public var ETA:int = -1;
		public var uploadRate:uint=0;
		public var uploadRateAverage:uint=0;
		public var numPeers:uint=0;
		public var numPeersTotal:uint=0;
		public var numSeeds:uint=0;
		public var numSeedsTotal:uint=0;
		
		public var wasted:uint=0;
		public var activeTime:uint=0;
		public var downloaded:uint=0;
		public var downloadedSession:uint=0;
		public var uploaded:uint=0;
		public var uploadedSession:uint=0;
		public var uploadMax:int=-1;
		public var downloadMax:int=-1;

		public var numConnections:uint=0;
		public var nextAnnounce:uint=0;
		public var lastSeenComplete:int=-1;
		public var completedOn:int=-1;
		public var addedOn:int=-1;
		public var savePath:String;
		public var shareRatio:Number;
	}
}