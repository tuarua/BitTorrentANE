package com.tuarua.torrent {
	import flash.utils.Dictionary;
	
	public class TorrentsLibrary{
		public static var meta:Dictionary = new Dictionary();
		public static var status:Dictionary = new Dictionary();
		public static var pieces:Dictionary = new Dictionary();
		public static var peers:Dictionary = new Dictionary();
		public static var trackers:Dictionary = new Dictionary();
		public static function add(_name:String,_tm:TorrentMeta):void {
			if(meta[_name] == undefined){
				meta[_name] = _tm;
				status[_name] = null;
				pieces[_name] = null;
				peers[_name] = null;
			}
		}
		public static function remove(_name:String):void {
			delete meta[_name];
			delete status[_name];
			delete pieces[_name];
			delete peers[_name];
		}
		public static function updateStatus(_name:String,_ts:TorrentStatus):void {
			status[_name] = _ts;
		}
		public static function updatePieces(_name:String,_tp:TorrentPieces):void {
			pieces[_name] = _tp;
		}
		public static function updatePeers(_name:String,_tp:TorrentPeers):void {
			peers[_name] = _tp;
		}
		
		public static function updateTrackers(_name:String,_tp:TorrentTrackers):void{
			trackers[_name] = _tp;
		}
	}
}