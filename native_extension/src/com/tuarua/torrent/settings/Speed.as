package com.tuarua.torrent.settings {
	public class Speed extends Object {
		public var uploadRateLimit:int = 0;
		public var downloadRateLimit:int = 0;
		public var isuTPEnabled:Boolean = true;
		public var isuTPRateLimited:Boolean = true;
		public var rateLimitIpOverhead:Boolean = false;
		public var ignoreLimitsOnLAN:Boolean = false;
	}
}