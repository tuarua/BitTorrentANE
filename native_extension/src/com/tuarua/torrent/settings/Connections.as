package com.tuarua.torrent.settings {
	public class Connections extends Object {
		/**
		 * <p>Maximum number of connections. -1 means unlimited on these settings just like their counterpart</p> 
		 */
		public var maxNum:int = 500;
		/**
		 * <p>Maximum number of connections per torrent. -1 means unlimited on these settings just like their counterpart</p> 
		 */
		public var maxNumPerTorrent:int = 100;
		/**
		 * <p>Maximum number of uploads. -1 means unlimited on these settings just like their counterpart</p> 
		 */
		public var maxUploads:int = -1;
		/**
		 * <p>Maximum number of uploads per torrent. -1 means unlimited on these settings just like their counterpart</p> 
		 */
		public var maxUploadsPerTorrent:int = -1;
		/** 
		 * This method is omitted from the output. * * @private 
		 */ 
		public function Connections(){}
	}
}