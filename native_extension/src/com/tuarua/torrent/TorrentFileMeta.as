package com.tuarua.torrent {
	[RemoteClass(alias="com.tuarua.torrent.TorrentFileMeta")]
	public class TorrentFileMeta extends Object {
		/**
		 * <p>Returns the full path to a file.</p> 
		 */
		public var path:String;
		/**
		 * <p>Returns just the name of the file.</p> 
		 */
		public var name:String;
		/**
		 * <p>Returns the byte offset within the torrent file
		 * where this file starts. It can be used to map the file to a piece
		 * index (given the piece size).</p> 
		 */
		public var offset:uint;
		/**
		 * <p>Returns the size of a file in bytes.</p> 
		 */
		public var size:uint;
		/**
		 * <p>The index of the piece in which the range starts.</p> 
		 */
		public var firstPiece:uint;
		/**
		 * <p>The index of the piece in which the range ends.</p> 
		 */
		public var lastPiece:uint;
		/**
		 * <p>The number of pieces.</p> 
		 */
		public var numPieces:uint;
		/** 
		 * This method is omitted from the output. * * @private 
		 */ 
		public function TorrentFileMeta(){}
		/**
		 * 
		 * @return returns the file extenstion of the file, eg mp4
		 * 
		 */		
		public function getExtension():String {
			return path.substring(path.lastIndexOf(".")+1, path.length);
		}
	}
}