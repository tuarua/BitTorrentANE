package com.tuarua.torrent{
	[RemoteClass(alias="com.tuarua.torrent.TorrentInfo")]
	public class TorrentInfo extends Object {
		/**
		 * <p>ok</p> 
		 */
		public var status:String;
		/**
		 * <p>The filename of the torrent</p> 
		 */
		public var torrentFile:String;
		/**
		 * <p>The total number of pieces</p> 
		 */
		public var numPieces:uint;
		/**
		 * <p>The info-hash of the torrent</p> 
		 */
		public var infoHash:String;
		/**
		 * <p>Returns true if this torrent is private. i.e., it should not be
		 * distributed on the trackerless network (the kademlia DHT).</p> 
		 */
		public var isPrivate:Boolean;
		/**
		 * <p>The number of bytes for each piece</p> 
		 */
		public var pieceLength:uint;
		/**
		 * <p>The total number of bytes the torrent-file represents 
		 * (all the files in it)</p> 
		 */
		public var size:uint;
		/**
		 * <p>The name of the torrent.</p> 
		 */
		public var name:String;
		/**
		 * <p>The comment associated with the torrent. If
		 * there's no comment, it will return an empty string.</p> 
		 */
		public var comment:String;
		/**
		 * <p>The creator string in the torrent. If there is
		 * no creator string it will return an empty string.</p> 
		 */
		public var creator:String;
		/**
		 * <p>The creation date of the torrent</p> 
		 */
		public var creationDate:uint;
		/**
		 * <p>Vector of files contained in this torrent</p> 
		 */
		public var files:Vector.<TorrentFileMeta> = new Vector.<TorrentFileMeta>();
		/**
		 * <p>Vector of url seeds contained in this torrent</p> 
		 */
		public var urlSeeds:Vector.<String> = new Vector.<String>();
		/** 
		 * This method is omitted from the output. * * @private 
		 */ 
		public function TorrentInfo(){}
		/**
		 * 
		 * @param _extension
		 * @return 
		 * 
		 */		
		public function getFileByExtension(_extension:Array):TorrentFileMeta {
			var ret:TorrentFileMeta;
			for (var i:int=0, l:int=this.files.length; i<l; ++i){
				if(_extension.indexOf(this.files[i].getExtension()) > -1 && this.files[i].path.lastIndexOf("sample") == -1) {
					return files[i];
					break;
				}
			}
			return ret;
		}
	}
}