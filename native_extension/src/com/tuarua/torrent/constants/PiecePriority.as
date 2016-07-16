package com.tuarua.torrent.constants {
	public class PiecePriority {
		public static const DO_NOT_DOWNLOAD:int = 0;
		public static const NORMAL:int = 1;
		public static const MEDIUM:int = 2;
		public static const LIKELY:int = 3;
		public static const PREFERRED:int = 4;
		public static const HIGH:int = 6;
		public static const MAXIMUM:int = 7;
		private static var types:Array = new Array();
		types[0] = "piece is not downloaded at all";
		types[1] = "normal priority. Download order is dependent on availability";
		types[2] = "higher than normal priority. Pieces are preferred over pieces with the same availability, but not over pieces with lower availability";
		types[3] = "pieces are as likely to be picked as partial pieces";
		types[4] = "pieces are preferred over partial pieces, but not over pieces with lower availability";
		types[5] = "pieces are preferred over partial pieces, but not over pieces with lower availability";
		types[6] = "piece is as likely to be picked as any piece with availability 1";
		types[7] = "maximum priority, availability is disregarded, the piece is preferred over any other piece with lower priority";
		public function PiecePriority() {
		}
		public static function getValue(type:int):String{
			return types[type];
		}
	}
}
