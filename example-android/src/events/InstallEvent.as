package events {
	import flash.events.Event;
	
	public class InstallEvent extends Event {
		public static const ON_INSTALL_COMPLETE:String = "onInstallComplete";
		public var params:Object;
		public function InstallEvent(type:String, _params:Object=null, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			this.params = _params;
		}
	}
}