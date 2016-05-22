package model.settings {
	import com.tuarua.torrent.settings.Speed;
	
	public class Speed extends com.tuarua.torrent.settings.Speed {
		public var uploadRateEnabled:Boolean = true;
		public var downloadRateEnabled:Boolean = false;
	}
}