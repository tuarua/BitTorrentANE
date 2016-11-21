package com.tuarua.torrent.settings {
	public class Listening extends Object {
		/**
		 * <p>Use the UPnP service. When started, the listen port
		 * and the DHT port are attempted to be forwarded on local UPnP router
		 * devices.</p> 
		 */
		public var useUPnP:Boolean = true;
		/**
		 * <p>This is the listen port that will be opened for accepting incoming uTP
		 * and TCP connections.</p> 
		 */
		public var port:uint = 6881;
		/**
		 * <p>When set to true, a random port between 6881 and 6999 is used.</p> 
		 */
		public var randomPort:Boolean = false;
		/** 
		 * This method is omitted from the output. * * @private 
		 */ 
		public function Listening(){}
	}
}