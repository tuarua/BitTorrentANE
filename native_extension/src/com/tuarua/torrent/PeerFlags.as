package com.tuarua.torrent {
	[RemoteClass(alias="com.tuarua.torrent.PeerFlags")]
	public class PeerFlags extends Object{
		public var isInteresting:Boolean;
		public var isChoked:Boolean;
		public var isRemoteInterested:Boolean;
		public var isRemoteChoked:Boolean;
		public var supportsExtensions:Boolean;
		public var isLocalConnection:Boolean;
		public var isSeed:Boolean;
		public var onParole:Boolean;
		public var isOptimisticUnchoke:Boolean;
		public var isSnubbed:Boolean;
		public var isUploadOnly:Boolean;
		public var isEndGameMode:Boolean;
		public var isRC4encrypted:Boolean;
		public var isPlainTextEncrypted:Boolean;
		public var isHolePunched:Boolean;
		public var fromTracker:Boolean;
		public var fromPEX:Boolean;
		public var fromDHT:Boolean;
		public var fromLSD:Boolean;
		public var fromResumeData:Boolean;
		public var fromIncoming:Boolean;
	}
}