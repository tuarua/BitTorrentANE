package com.tuarua.torrent.settings {
	public class Speed extends Object {
		/**
		 * <p>Sets the session-global limits of upload rate limits, in
		 * bytes per second. The local rates refer to peers on the local
		 * network. By default peers on the local network are not rate
		 * limited.</p>
		 * <p>A value of 0 means unlimited.</p> 
		 */
		public var uploadRateLimit:int = 0;
		/**
		 * <p>Sets the session-global limits of download rate limits, in
		 * bytes per second. The local rates refer to peers on the local
		 * network. By default peers on the local network are not rate
		 * limited.</p>
		 * <p>A value of 0 means unlimited.</p> 
		 */
		public var downloadRateLimit:int = 0;
		/**
		 * <p>When set to true, libtorrent will try to make outgoing utp
		 * connections controls whether libtorrent will accept incoming
		 * connections or make outgoing connections of specific type.</p> 
		 */
		public var isuTPEnabled:Boolean = true;
		/**
		 * <p>Set to true if uTP connections should be rate limited</p> 
		 */
		public var isuTPRateLimited:Boolean = true;
		/**
		 * <p>If set to true, the estimated TCP/IP overhead is drained from the
		 * rate limiters, to avoid exceeding the limits with the total traffic</p> 
		 */
		public var rateLimitIpOverhead:Boolean = false;
		/**
		 * <p>If set to true, upload, download and unchoke limits are ignored for
		 * peers on the local network.</p> 
		 */
		public var ignoreLimitsOnLAN:Boolean = false;
		/** 
		 * This method is omitted from the output. * * @private 
		 */ 
		public function Speed(){}
	}
}