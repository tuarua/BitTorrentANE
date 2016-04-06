package com.tuarua.torrent {
	public class TorrentPieces {
		public var pieces:Vector.<int> = new Vector.<int>();
		public var hasLast:Boolean = false;
		public var numDownloaded:int = 0;
		public var numSequential:int = 0;
		public function TorrentPieces(_initialPieces:String) {
			var arr:Array = _initialPieces.split("");
			for (var i:int=0, l:int=_initialPieces.length; i<l; ++i) {
				pieces.push(parseInt(arr[i]));
			}
			hasLast = (pieces[pieces.length-1] == 1);
			calcTotals();
		}
		public function setDownloaded(_index:int):void {
			pieces[_index] = 1;
			if(!hasLast) hasLast = (pieces[pieces.length-1] == 1);
			calcTotals();
		}
		private function calcTotals():void {
			numDownloaded = 0;
			for (var i:int=0, l:int=pieces.length; i<l; ++i) {
				if(pieces[i] == 1) numDownloaded++;
			}
			numSequential = pieces.indexOf(0);
		}
	}
}