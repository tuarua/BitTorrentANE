package com.tuarua.torrent.settings {
	import com.tuarua.torrent.constants.ProxyType;
	public class Proxy extends Object {
		/**
		 * <p>Type of Proxy. One of:
		 * <ul>
		 * <li>0 = Disabled</li>
		 * <li>1 = Socks 4</li>
		 * <li>2 = Socks 5</li>
		 * <li>3 = HTTP</li>
		 * <li>4 = I2P</li>
		 * </ul>
		 * </p> 
		 * <p>See <code>com.tuarua.torrent.constants.ProxyType</code></p>
		 */
		public var type:int = ProxyType.DISABLED;
		/**
		 * <p>The port of the proxy server.</p> 
		 */
		public var port:int = 8080;
		/**
		 * <p>This is the hostname where the proxy is running.</p> 
		 */
		public var host:String = "0.0.0.0";
		/**
		 * <p>if true, peer connections are made (and accepted) over the
		 * configured proxy, if any. Web seeds as well as regular bittorrent
		 * peer connections are considered "peer connections". Anything
		 * transporting actual torrent payload (trackers and DHT traffic are
		 * not considered peer connections).</p> 
		 */
		public var useForPeerConnections:Boolean = false;
		/**
		 * <p>If true, disables any communication that's not going over a proxy.
		 * Enabling this requires a proxy to be configured as well, see
		 * proxy_type and proxy_hostname settings. The listen sockets are
		 * closed, and incoming connections will only be accepted through a
		 * SOCKS5 or I2P proxy (if a peer proxy is set up and is run on the
		 * same machine as the tracker proxy). This setting also disabled peer
		 * country lookups, since those are done via DNS lookups that aren't
		 * supported by proxies.</p> 
		 */
		public var force:Boolean = false;
		/**
		 * <p>Set to true use authorisation</p> 
		 */
		public var useAuth:Boolean = false;
		/**
		 * <p>When <code>useAuth</code> is set to true, this is the username  to use when
		 * connecting to the proxy.</p> 
		 */
		public var username:String = "";
		/**
		 * <p>When <code>useAuth</code> is set to true, this is the password  to use when
		 * connecting to the proxy.</p> 
		 */
		public var password:String = "";
		/** 
		 * This method is omitted from the output. * * @private 
		 */ 
		public function Proxy(){}
	}
}