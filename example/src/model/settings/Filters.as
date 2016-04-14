package model.settings {
	import flash.filesystem.File;
	public class Filters extends Object {
		public var fileName:String = File.applicationStorageDirectory.resolvePath("filters").resolvePath("peerGuardian.p2p").nativePath;
		public var enabled:Boolean = false;
		public var applyToTrackers:Boolean = false;
	}
}