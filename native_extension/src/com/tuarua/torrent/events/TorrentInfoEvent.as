package com.tuarua.torrent.events {
	import flash.events.Event;
	public class TorrentInfoEvent extends Event {
		public static const TORRENT_CREATED_FROM_META:String = "Torrent.Create.CreatedFromMeta";
		public static const TORRENT_CREATED:String = "Torrent.Create.Created";
		public static const TORRENT_CREATION_PROGRESS:String = "Torrent.Create.Progress";
		public static const TORRENT_FROM_RESUME:String = "Torrent.Resume";
		public static const TORRENT_ADDED:String = "Torrent.Added";
		public static const TORRENT_CHECKED:String = "Torrent.Checked";
		public static const TORRENT_PIECE:String = "Torrent.Piece";
		public static const TORRENT_UNAVAILABLE:String = "Torrent.Unavailable";
		public static const TORRENT_DOWNLOADED:String = "Torrent.Downloaded";
		public static const RESUME_SAVED:String = "Torrent.Resume.Saved";
		public static const DHT_STARTED:String = "Torrent.DHT.Started";
		public static const ON_ERROR:String = "Torrent.Error";
		public static const RSS_STATE_CHANGE:String = "Torrent.RSS.StateChange";
		public static const RSS_ITEM:String = "Torrent.RSS.Item";
		public static const FILTERLIST_ADDED:String = "Torrent.Filter.ListAdded";
		public var params:Object;
		
		public function TorrentInfoEvent(type:String, _params:Object=null, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.params = _params;
		}
		public override function clone():Event {
			return new TorrentInfoEvent(type, this.params, bubbles, cancelable);
		}	
		public override function toString():String {
			return formatToString("TorrentInfoEvent", "params", "type", "bubbles", "cancelable");
		}
		
	}
}