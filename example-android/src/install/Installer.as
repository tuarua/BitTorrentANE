package install {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	
	import events.InstallEvent;
	
	public class Installer{
		public static var dispatcher:EventDispatcher = new EventDispatcher();
		
		private static var dbSourceDir:File;
		private static var numFilesCopied:int = 0;
		private static var numFilesRequired:int = 3;
		public static function isAppInstalled():Boolean {
			var torrentFolder:File = File.applicationStorageDirectory.resolvePath("torrents");
			trace("is there an install already",torrentFolder.exists);
			return torrentFolder.exists;
		}
		
		public static function install():void {
			File.applicationStorageDirectory.resolvePath("output").createDirectory();
			File.applicationStorageDirectory.resolvePath("torrents").createDirectory();
			File.applicationStorageDirectory.resolvePath("torrents").resolvePath("resume").createDirectory();
			File.applicationStorageDirectory.resolvePath("geoip").createDirectory();
			File.applicationStorageDirectory.resolvePath("filters").createDirectory();
			File.applicationStorageDirectory.resolvePath("session").createDirectory();
			
			var filterSource:File = File.applicationDirectory.resolvePath("filters").resolvePath("peerGuardianSample.p2p");
			var filterDest:File = File.applicationStorageDirectory.resolvePath("filters").resolvePath("peerGuardianSample.p2p");
			filterSource.addEventListener(Event.COMPLETE, fileCopyCompleteHandler);
			filterSource.copyToAsync(filterDest, true);
			
			var geoipSource:File = File.applicationDirectory.resolvePath("geoip").resolvePath("geolite2-country.mmdb");
			var geoipDest:File = File.applicationStorageDirectory.resolvePath("geoip").resolvePath("geolite2-country.mmdb");
			geoipSource.addEventListener(Event.COMPLETE, fileCopyCompleteHandler);
			geoipSource.copyToAsync(geoipDest, true);
			
			var torrentSource:File = File.applicationDirectory.resolvePath("torrents").resolvePath("bbb_sunflower_1080p_30fps_normal.mp4.torrent");
			var torrentpDest:File = File.applicationStorageDirectory.resolvePath("torrents").resolvePath("bbb_sunflower_1080p_30fps_normal.mp4.torrent");
			torrentSource.addEventListener(Event.COMPLETE, fileCopyCompleteHandler);
			torrentSource.copyToAsync(torrentpDest, true);
		}
		
		protected static function fileCopyCompleteHandler(event:Event):void{
			numFilesCopied++;
			if(numFilesCopied == numFilesRequired)
				dispatcher.dispatchEvent(new InstallEvent(InstallEvent.ON_INSTALL_COMPLETE));
		}
	}
}