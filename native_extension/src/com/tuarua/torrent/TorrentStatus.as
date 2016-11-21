package com.tuarua.torrent {
	[RemoteClass(alias="com.tuarua.torrent.TorrentStatus")]
	public class TorrentStatus extends Object {
		/**
		 * <p>The id of the torrent. Assigned by user when calling <code>addTorrent()</code></p> 
		 */	
		public var id:String;
		/**
		 * <p>The info-hash of the torrent.</p> 
		 */	
		public var infoHash:String;
		/**
		 * <p>the number of pieces that has been downloaded. 
		 * This can be used to see if anything has updated
		 * since last time if you want to keep a graph of 
		 * the pieces up to date.</p> 
		 */	
		public var numPieces:uint = 0;
		/**
		 * <p>Is the torrent isFinished downloading</p> 
		 */	
		public var isFinished:Boolean;
		/**
		 * <p><code>true</code> when the torrent is in sequential download mode. In this mode
		 * pieces are downloaded in order rather than rarest first.</p> 
		 */
		public var isSequential:Boolean;
		/**
		 * <p>The current state of the torrent. See TorrentStateCodes for meaning</p> 
		 */
		public var state:int;
		/**
		 * <p>The position this torrent has in the download
		 * queue. If the torrent is a seed or finished, this is -1.</p> 
		 */
		public var queuePosition:int = 0;
		/**
		 * <p>A value in the range [0, 100], that represents the progress of the
		 * torrent's current task. It may be checking files or downloading.</p> 
		 */
		public var progress:Number = 0.0;
		/**
		 * <p>The total transfer rate of payload only, not counting protocol
		 * chatter. This might be slightly smaller than the other rates, but if
		 * projected over a long time (e.g. when calculating ETA:s) the
		 * difference may be noticeable.</p> 
		 */
		public var downloadRate:uint = 0;
		/**
		 * <p>Download rate average</p> 
		 */
		public var downloadRateAverage:uint = 0;
		/**
		 * <p>Number of seconds until the torrent finishes downloading (Estimated)</p> 
		 */
		public var ETA:int = -1;
		/**
		 * <p>The total transfer rate of payload only, not counting protocol
		 * chatter. This might be slightly smaller than the other rates, but if
		 * projected over a long time (e.g. when calculating ETA:s) the
		 * difference may be noticeable.</p> 
		 * 
		 */
		public var uploadRate:uint = 0;
		/**
		 * <p>Upload rate average</p> 
		 */
		public var uploadRateAverage:uint = 0;
		/**
		 * <p>The number of peers this torrent currently is connected to. Peer
		 * connections that are in the half-open state (is attempting to connect)
		 * or are queued for later connection attempt do not count.</p> 
		 */
		public var numPeers:uint = 0;
		/**
		 * <p>The total number of peers
		 * (including seeds). We are not necessarily connected to all the peers
		 * in our peer list. This is the number of peers we know of in total,
		 * including banned peers and peers that we have failed to connect to.</p> 
		 */
		public var numPeersTotal:uint = 0;
		/**
		 * <p>The number of peers that are seeding that this client is
		 * currently connected to.</p> 
		 */
		public var numSeeds:uint = 0;
		/**
		 * <p>The number of seeds in our peer list.</p> 
		 */
		public var numSeedsTotal:uint = 0;
		/**
		 * <p>The number of bytes that has been downloaded and that has failed the
		 * piece hash test. In other words, this is just how much crap that has
		 * been downloaded since the torrent was last started. If a torrent is
		 * paused and then restarted again, this counter will be reset.</p>
		 * <p>+</p>
		 * <p>the number of bytes that has been downloaded even though that data
		 * already was downloaded. The reason for this is that in some situations
		 * the same data can be downloaded by mistake. When libtorrent sends
		 * requests to a peer, and the peer doesn't send a response within a
		 * certain timeout, libtorrent will re-request that block. Another
		 * situation when libtorrent may re-request blocks is when the requests
		 * it sends out are not replied in FIFO-order (it will re-request blocks
		 * that are skipped by an out of order block). This is supposed to be as
		 * low as possible. This only counts bytes since the torrent was last
		 * started. If a torrent is paused and then restarted again, this counter
		 * will be reset.</p>
		 */
		public var wasted:uint = 0;
		/**
		 * <p>These keep track of the number of seconds this torrent has been active
		 * (not paused) and the number of seconds it has been active while being
		 * finished and active while being a seed. It is saved in and restored 
		 * from resume data, to keep totals across sessions.</p> 
		 */
		public var activeTime:uint = 0;
		/**
		 * <p>Download payload byte counters. They are
		 * saved in and restored from resume data to keep totals across sessions.</p> 
		 */
		public var downloaded:uint = 0;
		/**
		 * <p>counts the amount of bytes received this session, but only
		 * the actual payload data (i.e the interesting data), these counters
		 * ignore any protocol overhead. The session is considered to restart
		 * when a torrent is paused and restarted again. When a torrent is
		 * paused, these counters are reset to 0.</p> 
		 */
		public var downloadedSession:uint = 0;
		/**
		 * <p>Upload payload byte counters. They are
		 * saved in and restored from resume data to keep totals across sessions.</p> 
		 */
		public var uploaded:uint = 0;
		/**
		 * <p>counts the amount of bytes sent this session, but only
		 * the actual payload data (i.e the interesting data), these counters
		 * ignore any protocol overhead. The session is considered to restart
		 * when a torrent is paused and restarted again. When a torrent is
		 * paused, these counters are reset to 0.</p> 
		 */
		public var uploadedSession:uint = 0;
		/**
		 * <p>The set limit of upload slots (unchoked peers) for this torrent.</p> 
		 */
		public var uploadMax:int = -1;
		/**
		 * <p>The current limit setting</p> 
		 */
		public var downloadMax:int = -1;
		/**
		 * <p>the number of peer connections this torrent has, including half-open
		 * connections that hasn't completed the bittorrent handshake yet.</p>
		 * 
		 */
		public var numConnections:uint = 0;
		/**
		 * <p>The time in seconds until the torrent will announce itself to the tracker.</p> 
		 */
		public var nextAnnounce:uint = 0;
		/**
		 * <p>The time when we, or one of our peers, last saw a complete copy of
		 * this torrent.</p> 
		 */
		public var lastSeenComplete:int = -1;
		/**
		 * <p>The posix-time when this torrent was finished. If the torrent is not
		 * yet finished, this is 0.</p> 
		 */
		public var completedOn:int = -1;
		/**
		 * <p>the posix-time when this torrent was added.</p> 
		 */
		public var addedOn:int = -1;
		/**
		 * <p>the path to the directory where this torrent's files are stored.
		 * It's typically the path as was given to addTorrent() when this 
		 * torrent was started.</p> 
		 */
		public var savePath:String;
		/**
		 * <p>Share ratio.</p> 
		 */
		public var shareRatio:Number;
		/**
		 * <p>The the number of bytes downloaded of each file in this torrent.
		 * The progress values are ordered the same as the files</p> 
		 */
		public var fileProgress:Array;
		/**
		 * <p>Returns an array with the priorities of all files.</p> 
		 */
		public var filePriority:Array;
		/**
		 * <p>Returns an array with the piece indexes of pieces which are partially downloaded</p> 
		 */
		public var partialPieces:Array;
		
		/** 
		 * This method is omitted from the output. * * @private 
		 */ 
		public function TorrentStatus(){}
		
	}
}