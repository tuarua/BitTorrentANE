package com.tuarua.torrent.settings {
	public class Storage extends Object {
		/**
		 * <p>Path to where downloads should be  saved</p> 
		 */
		public var outputPath:String;
		/**
		 * <p>Path to where .torrents are stored</p> 
		 */
		public var torrentPath:String;
		/**
		 * <p>Path to where resumedata should be stored</p> 
		 */
		public var resumePath:String;
		/**
		 * <p>Path to where session state files should be stored</p> 
		 */
		public var sessionStatePath:String;
		/**
		 * <p>Path to where GeoIP.dat is stored</p> 
		 */
		public var geoipDataPath:String;
		/**
		 * <p>All pieces will be written to the place where they belong and sparse files
		 * will be used. This is the recommended, and default mode.</p> 
		 */
		public var sparse:Boolean = true;
		/**
		 * <p>Set to false for testing and benchmarking. It will throw away 
		 * any data written to it and return garbage for anything read from it.</p> 
		 */
		public var enabled:Boolean = true;
		/** 
		 * This method is omitted from the output. * * @private 
		 */ 
		public function Storage(){}
	}
}