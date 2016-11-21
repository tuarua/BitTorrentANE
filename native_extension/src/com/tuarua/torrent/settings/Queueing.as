package com.tuarua.torrent.settings {
	public class Queueing extends Object {
		/**
		 * <p>Whether to enable queueing.</p> 
		 */
		public var enabled:Boolean = false;
		/**
		 * <p>For auto managed torrents, these are the limits they are subject
		 * to. If there are too many torrents some of the auto managed ones
		 * will be paused until some slots free up. Controls how many active 
		 * downloading torrents the queuing mechanism allows.</p> 
		 */
		public var maxActiveDownloads:int = 3;
		/**
		 * <p>A hard limit on the number of active (auto
		 * managed) torrents. This limit also applies to slow torrents.</p> 
		 */
		public var maxActiveTorrents:int = 5;
		/**
		 * <p>Upper limits on the number of downloading torrents and seeding 
		 * torrents respectively. Setting the value to -1 means unlimited.</p> 
		 */
		public var maxActiveUploads:int = 3;
		/**
		 * <p>If true, torrents without any
		 * payload transfers are not subject to the maxActiveUploads and
		 * maxActiveDownloads limits. This is intended to make it more
		 * likely to utilize all available bandwidth, and avoid having
		 * torrents that don't transfer anything block the active slots.</p> 
		 */
		public var ignoreSlow:Boolean = false;
		/** 
		 * This method is omitted from the output. * * @private 
		 */ 
		public function Queueing(){}
	}
}