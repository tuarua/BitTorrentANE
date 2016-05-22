package events {
	import flash.events.Event;
	public class DataProviderEvent extends Event {
		public static const ON_SETTINGS_CHANGE:String = "onSettingsChange";
		public var params:Object;
		public function DataProviderEvent(type:String, _params:Object=null, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.params = _params;
		}
	}
}