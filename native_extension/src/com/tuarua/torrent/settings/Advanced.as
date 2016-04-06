package com.tuarua.torrent.settings {
	public class Advanced extends Object {
		public var diskCacheSize:int = 0;//0 is auto
		public var diskCacheTTL:int = 60;
		public var outgoingPortsMin:int = 0;//0 is disabled
		public var outgoingPortsMax:int = 0;//0 is disabled
		public var numMaxHalfOpenConnections:int = 20;//0 is disabled
		public var announceIP:String="";
		
		public var enableOsCache:Boolean = true;
		public var recheckTorrentsOnCompletion:Boolean = false;
		public var resolveCountries:Boolean = true;
		public var resolvePeerHostNames:Boolean = false;
		public var isSuperSeedingEnabled:Boolean = false;
		public var announceToAllTrackers:Boolean = false;
		public var enableTrackerExchange:Boolean = true;
		public var listenOnIPv6:Boolean = false;
		public var networkInterface:Object;
	}
}