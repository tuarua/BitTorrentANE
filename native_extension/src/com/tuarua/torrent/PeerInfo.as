package com.tuarua.torrent {
	[RemoteClass(alias="com.tuarua.torrent.PeerInfo")]
	public class PeerInfo extends Object {
		/**
		 * <p>Get the IP address associated with the endpoint.</p> 
		 */
		public var ip:String;
		/**
		 * <p>the two letter `ISO 3166 country code`__ for the country 
		 * the peer is connected from.</p> 
		 */
		public var country:String;
		/** 
		 * This method is omitted from the output. * * @private 
		 */
		public var asName:String;
		/**
		 * <p>Get the port associated with the endpoint. 
		 * The port number is always in the host's byte order.</p> 
		 */
		public var port:int;
		/**
		 * <p>Get the port associated with the endpoint. 
		 * The port number is always in the host's byte order.</p> 
		 */		
		public var localPort:int;
		/**
		 * <p>The connection type. One of:
		 * <ul>
		 * <li>uTP</li>
		 * <li>i2P</li>
		 * <li>BT
		 * Regular Bittorrent connection</li>
		 * <li>Web
		 * HTTP connection using the `BEP 19`_ protocol. </li>
		 * </ul>
		 * </p> 
		 */	
		public var connection:String;
		
		public var flagsAsString:String;
		public var flags:PeerFlags;
		/**
		 * <p>a string describing the software at the other end of the connection.
		 * In some cases this information is not available, then it will contain
		 * a string that may give away something about which software is running
		 * in the other end. In the case of a web seed, the server type and
		 * version will be a part of this string. </p> 
		 */		
		public var client:String;
		/**
		 * <p>the progress of the peer in the range [0, 1].</p> 
		 */	
		public var progress:Number=-1.0;
		/**
		 * <p>The current download speed we have to and from this peer 
		 * (including any protocol messages). bytes per second</p> 
		 */	
		public var downSpeed:int;
		/**
		 * <p>the total number of bytes downloaded from downloaded this peer.
			These numbers do not include the protocol chatter, but only the
			payload data.</p> 
		 */	
		public var downloaded:int;
		/**
		 * <p>The current upload speed we have to and from this peer 
		 * (including any protocol messages). bytes per second</p> 
		 */	
		public var upSpeed:int;
		/**
		 * <p>the total number of bytes uploaded to this peer.
		 These numbers do not include the protocol chatter, but only the
		 payload data.</p> 
		 */	
		public var uploaded:int;
		
		public var relevance:Number=-1.0;
		/** 
		 * This method is omitted from the output. * * @private 
		 */ 
		public function PeerInfo(){}
	}
}