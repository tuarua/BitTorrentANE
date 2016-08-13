package com.tuarua.torrent.events {
	import flash.events.Event;
	public class TorrentInfoEvent extends Event {
		public static const TORRENT_CREATED:String = "Torrent.Create.Created";
		public static const TORRENT_CREATION_PROGRESS:String = "Torrent.Create.Progress";
		public static const TORRENT_UNAVAILABLE:String = "Torrent.Unavailable";
		public static const TORRENT_DOWNLOADED:String = "Torrent.Downloaded";
		public static const ON_ERROR:String = "Torrent.Error";
		public static const FILTER_LIST_ADDED:String = "Torrent.Filter.ListAdded";
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