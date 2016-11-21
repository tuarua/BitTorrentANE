package com.tuarua.torrent.settings {
	public class Advanced extends Object {
		/**
		 * <p>Disk cache size is the disk write and read  cache. It is specified
		 * in units of 16 KiB blocks. Buffers that are part of a peer's send
		 * or receive buffer also count against this limit. Send and receive
		 * buffers will never be denied to be allocated, but they will cause
		 * the actual cached blocks to be flushed or evicted. If this is set
		 * to -1, the cache size is automatically set to the amount of
		 * physical RAM available in the machine divided by 8. If the amount
		 * of physical RAM cannot be determined, it's set to 1024 (= 16 MiB).</p> 
		 */
		public var diskCacheSize:int = 0;
		/**
		 * <p>Disk cache TTL is the number of seconds from the last 
		 * cached write to a piece in the write cache, to when
		 * it's forcefully flushed to disk. Default is 60 seconds.</p> 
		 */
		public var diskCacheTTL:int = 60;
		
		
		public var outgoingPortsMin:int = 0;//0 is disabled
		public var outgoingPortsMax:int = 0;//0 is disabled
		/**
		 * <p>Sets the maximum number of half-open
		 * connections libtorrent will have when connecting to peers. A
		 * half-open connection is one where connect() has been called, but
		 * the connection still hasn't been established (nor failed). Set to 0 to disable</p> 
		 */
		public var numMaxHalfOpenConnections:int = 20;
		/**
		 * <p>The ip address passed along to trackers as the
		 * &amp;ip= parameter. If left as the default, that parameter is
		 * omitted.</p> 
		 */
		public var announceIP:String="";
		/**
		 * <p></p> 
		 */
		public var enableOsCache:Boolean = true;
		public var recheckTorrentsOnCompletion:Boolean = false;
		/**
		 * <p>Determines if countries should be resolved
		 * for the peers of this torrent.</p> 
		 */
		public var resolveCountries:Boolean = true;
		public var resolvePeerHostNames:Boolean = false;
		public var isSuperSeedingEnabled:Boolean = false;
		public var announceToAllTrackers:Boolean = false;
		public var enableTrackerExchange:Boolean = true;
		public var listenOnIPv6:Boolean = false;
		public var networkInterface:Object;
		/** 
		 * This method is omitted from the output. * * @private 
		 */ 
		public function Advanced(){}
	}
}