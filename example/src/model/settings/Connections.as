package model.settings {
	import com.tuarua.torrent.settings.Connections;
	public class Connections extends com.tuarua.torrent.settings.Connections {
		public var useMaxConnectionsPerTorrent:Boolean = true;
		public var useMaxConnections:Boolean = true;
		public var useMaxUploadsPerTorrent:Boolean = false;
		public var useMaxUploads:Boolean = false;
	}
}