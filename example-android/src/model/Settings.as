package model {
	import flash.filesystem.File;
	
	import model.settings.Advanced;
	import model.settings.Connections;
	import model.settings.Filters;
	import model.settings.Listening;
	import model.settings.Privacy;
	import model.settings.Proxy;
	import model.settings.Queueing;
	import model.settings.Speed;

	public class Settings extends Object {
		public var outputPath:String = File.applicationDirectory.resolvePath("output").nativePath; //default
		public var speed:Speed = new Speed();
		public var privacy:Privacy = new Privacy();
		public var queueing:Queueing = new Queueing();
		public var connections:Connections = new Connections();
		public var proxy:Proxy = new Proxy();
		public var useUPnP:Boolean = true;
		public var listenPort:int = 6881;
		public var useRandomPort:Boolean = false;
		public var filters:Filters = new Filters();
		public var listening:Listening = new Listening();
		public var advanced:Advanced = new Advanced();
	}
}