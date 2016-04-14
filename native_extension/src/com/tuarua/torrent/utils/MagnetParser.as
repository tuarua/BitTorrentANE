package com.tuarua.torrent.utils {
	public class MagnetParser {
		private static var magnet:Magnet = new Magnet();
		public static function parse(uri:String):Magnet {
			var arr:Array = uri.split("&");
			for(var i:int=0;i < arr.length;i++){
				if(arr[i].substring(0,6) == "magnet")
					magnet.hash = arr[i].split(":btih:")[1];
				else if(arr[i].substring(0,3) == "dn=")
					magnet.name = arr[i].split("=")[1];
			}
			return magnet;
		}
	}
}