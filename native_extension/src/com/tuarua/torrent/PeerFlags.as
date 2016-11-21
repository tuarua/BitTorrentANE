package com.tuarua.torrent {
	[RemoteClass(alias="com.tuarua.torrent.PeerFlags")]
	public class PeerFlags extends Object {
		/**
		 * <p>We are interested in pieces from this peer.</p> 
		 */
		public var isInteresting:Boolean;
		/**
		 * <p>We have choked this peer.</p> 
		 */
		public var isChoked:Boolean;
		/**
		 * <p>The peer is interested in us</p> 
		 */
		public var isRemoteInterested:Boolean;
		/**
		 * <p>The peer has choked us</p> 
		 */
		public var isRemoteChoked:Boolean;
		/**
		 * <p>Means that this peer supports the 'extension protocol'</p> 
		 */
		public var supportsExtensions:Boolean;
		/**
		 * <p>The connection was initiated by us, the peer has a
		 * listen port open, and that port is the same as in the
		 * address of this peer. If this flag is not set, this
		 * peer connection was opened by this peer connecting to
		 * us.</p> 
		 */
		public var isLocalConnection:Boolean;
		/**
		 * <p>This peer is a seed (it has all the pieces).</p> 
		*/
		public var isSeed:Boolean;
		/**
		 * <p>The peer has participated in a piece that failed the
		 * hash check, and is now "on parole", which means we're
		 * only requesting whole pieces from this peer until
		 * it either fails that piece or proves that it doesn't
		 * send bad data.</p> 
		 */
		public var onParole:Boolean;
		/**
		 * <p>This peer is subject to an optimistic unchoke. It has
		 * been unchoked for a while to see if it might unchoke
		 * us in return an earn an upload/unchoke slot. If it
		 * doesn't within some period of time, it will be choked
		 * and another peer will be optimistically unchoked.</p> 
		 */
		public var isOptimisticUnchoke:Boolean;
		/**
		 * <p> This peer has recently failed to send a block within
		 * the request timeout from when the request was sent.
		 * We're currently picking one block at a time from this
		 * peer.</p> 
		 */
		public var isSnubbed:Boolean;
		/**
		 * <p>This peer has either explicitly (with an extension)
		 * or implicitly (by becoming a seed) told us that it
		 * will not downloading anything more, regardless of
		 * which pieces we have.</p> 
		 */
		public var isUploadOnly:Boolean;
		/**
		 * <p>This means the last time this peer picket a piece,
		 * it could not pick as many as it wanted because there
		 * were not enough free ones. i.e. all pieces this peer
		 * has were already requested from other peers.</p> 
		 */
		public var isEndGameMode:Boolean;
		/**
		 * <p>This connection is obfuscated with RC4</p>
		 */
		public var isRC4encrypted:Boolean;
		/**
		 * <p>The handshake of this connection was obfuscated
		 * with a diffie-hellman exchange</p>
		 */
		public var isPlainTextEncrypted:Boolean;
		/**
		 * <p>This flag is set if the peer was in holepunch mode
		 * when the connection succeeded. This typically only
		 * happens if both peers are behind a NAT and the peers
		 * connect via the NAT holepunch mechanism.</p>
		 * 
		 */
		public var isHolePunched:Boolean;
		/**
		 * <p>The peer was received from the tracker.</p> 
		 */
		public var fromTracker:Boolean;
		/**
		 * <p>The peer was received from the peer exchange
		 * extension.</p> 
		 * 
		 */
		public var fromPEX:Boolean;
		/**
		 * <p>The peer was received from the kademlia DHT.</p> 
		 */
		public var fromDHT:Boolean;
		/**
		 * <p>The peer was received from the local service
		 * discovery (The peer is on the local network).</p> 
		 */
		public var fromLSD:Boolean;
		/**
		 * <p>The peer was added from the fast resume data.</p> 
		 */
		public var fromResumeData:Boolean;
		/**
		 * <p>We received an incoming connection from this peer</p> 
		 */
		public var fromIncoming:Boolean;
		/** 
		 * This method is omitted from the output. * * @private 
		 */ 
		public function PeerFlags(){}
	}
}