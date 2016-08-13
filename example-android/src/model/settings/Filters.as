package model.settings {
	import flash.filesystem.File;
	public class Filters extends Object {
		public var fileName:String = File.applicationStorageDirectory.resolvePath("filters").resolvePath("peerGuardianSample.p2p").nativePath;
		public var enabled:Boolean = false;
		public var applyToTrackers:Boolean = false;
	}
}