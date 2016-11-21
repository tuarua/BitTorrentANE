package com.tuarua.torrent.settings {
	import com.tuarua.torrent.constants.Encryption;
	public class Privacy extends Object {
		/**
		 * <p>One of:
		 * <ul>
		 * <li>0 = Disabled</li>
		 * <li>1 = Enabled</li>
		 * <li>2 = Required</li>
		 * </ul>
		 * </p> 
		 * <p>See <code>com.tuarua.torrent.constants.Encryption</code></p>
		 */
		public var encryption:int = Encryption.ENABLED;
		/**
		 * <p>If true, use kademlia DHT</p> 
		 */
		public var useDHT:Boolean = true;
		/**
		 * <p>If true uses Local Service Discovery. This service will
		 * broadcast the infohashes of all the non-private torrents on the
		 * local network to look for peers on the same swarm within multicast
		 * reach.</p> 
		 */
		public var useLSD:Boolean = true;
		/**
		 * <p>Allows peers to gossip about their connections, allowing
		 * the swarm stay well connected and peers aware of more peers in the
		 * swarm.</p> 
		 */
		public var usePEX:Boolean = true;
		/**
		 * <p>When set to true, the client
		 * tries to hide its identity to a certain degree. The peer-ID will no
		 * longer include the client's fingerprint. The user-agent will be
		 * reset to an empty string. Trackers will only be used if they are
		 * using a proxy server. The listen sockets are closed, and incoming
		 * connections will only be accepted through a SOCKS5 or I2P proxy (if
		 * a peer proxy is set up and is run on the same machine as the
		 * tracker proxy). Since no incoming connections are accepted,
		 * NAT-PMP, UPnP, DHT and local peer discovery are all turned off when
		 * this setting is enabled.</p>
		 * <p>
		 * If you're using I2P, it might make sense to enable anonymous mode
		 * as well.</p> 
		 */
		public var useAnonymousMode:Boolean = false;
		/** 
		 * This method is omitted from the output. * * @private 
		 */ 
		public function Privacy(){}
	}
}