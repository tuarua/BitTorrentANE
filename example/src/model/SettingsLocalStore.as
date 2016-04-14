package model {
	import com.tuarua.torrent.TorrentSettings;
	
	import flash.events.EventDispatcher;
	import flash.net.SharedObject;
	
	import events.DataProviderEvent;

	public class SettingsLocalStore {
		public static var settings:Object;
		private static var so:SharedObject;
		public static var dispatcher:EventDispatcher = new EventDispatcher();
		public static function load(_reset:Boolean=false):void {
			so = SharedObject.getLocal("BitTorrentSample");
			if(so.data["settings"] == undefined || _reset){
				settings = new Settings();
				so.data["settings"] = settings;
				so.flush();
			}else{
				settings = so.data["settings"];
			}
		}
		public static function setProp(_key:String,_val:*,_key2:String=null):void {
			if(_key2)
				settings[_key][_key2] = _val;
			else
				settings[_key] = _val;
			
			so.data["settings"] = settings;
			so.flush();
			dispatcher.dispatchEvent(new DataProviderEvent(DataProviderEvent.ON_SETTINGS_CHANGE));
		}
	}
}