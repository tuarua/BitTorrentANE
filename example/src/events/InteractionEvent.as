package events {
	import starling.events.Event;
	public class InteractionEvent extends Event {
		public static const ON_TORRENT_ITEM_SELECT:String = "onTorrentItemSelect";
		public static const ON_MENU_ITEM_MENU:String = "onMenuItemMenu";
		public static const ON_MENU_ITEM_RIGHT:String = "onMenuItemRight";
		public static const ON_TORRENT_ADD:String = "onTorrentAdd";
		public static const ON_MAGNET_ADD:String = "onMagnetAdd";
		public static const ON_MAGNET_ADD_LIST:String = "onMagnetAddList";
		public static const ON_SETTINGS_CLICK:String = "onSettingsClick";
		public static const ON_POWER_CLICK:String = "onPowerClick";
		public static const ON_TORRRENT_CREATE:String = "onTorrentCreateClick";
		public static const ON_TORRRENT_SEED_NOW:String = "onTorrentSeedNow";
		public var params:Object;
		
		public function InteractionEvent(type:String, _params:Object=null, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.params = _params;
		}
	}
}