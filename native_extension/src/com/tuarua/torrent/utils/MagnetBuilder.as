package com.tuarua.torrent.utils {
	import com.tuarua.torrent.TorrentTracker;
	import com.tuarua.torrent.TorrentWebSeed;

	public class MagnetBuilder {
		public static function getUri(magnet:Magnet,trackers:Vector.<TorrentTracker>=null,webSeeds:Vector.<TorrentWebSeed>=null):String {
			var ret:String = "magnet:?xt=urn:btih:";
			ret += magnet.hash+"&dn="+encodeURIComponent(magnet.name);
			if(trackers){
				for each(var t:TorrentTracker in trackers)
				ret += "&tr="+encodeURIComponent(t.uri);
			}
			if(webSeeds){
				for each(var ws:TorrentTracker in webSeeds)
				ret += "&ws="+encodeURIComponent(ws.uri);
			}
			return ret;
		}
	}
}