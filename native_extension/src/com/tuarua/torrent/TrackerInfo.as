package com.tuarua.torrent {
	[RemoteClass(alias="com.tuarua.torrent.TrackerInfo")]
	public class TrackerInfo extends Object {
		/**
		 * <p>The tier this tracker belongs to.</p> 
		 */
		public var tier:int;
		/**
		 * <p>Tracker URL as it appeared in the torrent file.</p> 
		 */
		public var url:String;
		/**
		 * <p>The status. One of:
		 * <ul>
		 * <li>Working</li>
		 * <li>Updating</li>
		 * <li>Not Working</li>
		 * <li>Not contacted yet</li>
		 * </ul>
		 * </p> 
		 */	
		public var status:String;
		/**
		 * <p>Number of peers on this tracker</p> 
		 */
		public var numPeers:int;
		/**
		 * <p>If this tracker failed the last time it was contacted
		 * this error code specifies what error occurred.</p> 
		 */
		public var message:String;	
		/** 
		 * This method is omitted from the output. * * @private 
		 */ 
		public function TrackerInfo(){}
	}
}