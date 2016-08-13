package com.tuarua.torrent.events {
	import flash.events.Event;

	public class TorrentAlertEvent extends Event {
		public static var TRACKERS_UPDATE:String = "Torrent.Alert.TrackersUpdate";
		public static const PEERS_UPDATE:String = "Torrent.Alert.PeersUpdate";
		public static const STATE_UPDATE:String = "Torrent.Alert.StateUpdate";
		public static const STATE_CHANGED:String = "Torrent.Alert.StateChanged";
		public static const TORRENT_FINISHED:String = "Torrent.Alert.TorrentFinished";
		public static const TORRENT_ADDED:String = "Torrent.Alert.TorrentAdded";
		public static const TORRENT_PAUSED:String = "Torrent.Alert.TorrentPaused";
		public static const TORRENT_RESUMED:String = "Torrent.Alert.TorrentResumed";
		public static const TORRENT_CHECKED:String = "Torrent.Alert.TorrentChecked";
		public static const PIECE_FINISHED:String = "Torrent.Piece.Finished";
		public static const METADATA_RECEIVED:String = "Torrent.Alert.MetaDataReceived";
		public static const FILE_COMPLETED:String = "Torrent.Alert.FileCompleted";
		public static const SAVE_RESUME_DATA:String = "Torrent.Alert.SaveResumeData";
		public static const LISTEN_FAILED:String = "Torrent.Alert.ListenFailed";
		public static const LISTEN_SUCCEEDED:String = "Torrent.Alert.ListenSucceeded";
		public var params:Object;
		
		public function TorrentAlertEvent(type:String, _params:Object=null, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.params = _params;
		}
		public override function clone():Event {
			return new TorrentInfoEvent(type, this.params, bubbles, cancelable);
		}
		public override function toString():String {
			return formatToString("TorrentAlertEvent", "params", "type", "bubbles", "cancelable");
		}
	}
}