package com.tuarua.torrent.settings {
	import com.tuarua.torrent.constants.Encryption;
	public class Privacy extends Object {
		public var encryption:int = Encryption.ENABLED;
		public var useDHT:Boolean = true;
		public var useLSD:Boolean = true;//Local Peer Discovery
		public var usePEX:Boolean = true;//Peer Exchange
		public var useAnonymousMode:Boolean = false;
	}
}