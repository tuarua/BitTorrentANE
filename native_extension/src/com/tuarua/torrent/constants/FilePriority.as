package com.tuarua.torrent.constants {
	public class FilePriority  {
		public static const DO_NOT_DOWNLOAD:int = 0;
		public static const NORMAL:int = 1;
		public static const HIGH:int = 2;
		public static const MAXIMUM:int = 7;
		private static var types:Array = new Array();
		types[0] = "Do not Download";
		types[1] = "Normal";
		types[2] = "High";
		types[3] = "High";
		types[4] = "High";
		types[5] = "High";
		types[6] = "High";
		types[7] = "Maximum";
		public static function getValue(type:int):String{
			return types[type];
		}
	}
}