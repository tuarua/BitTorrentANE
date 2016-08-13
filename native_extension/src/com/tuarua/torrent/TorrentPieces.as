package com.tuarua.torrent {
	public class TorrentPieces {
		public var pieces:Vector.<int> = new Vector.<int>();
		public var piecesTime:Vector.<int> = new Vector.<int>(); //milliseconds
		public var hasLast:Boolean = false;
		public var numDownloaded:int = 0;
		public var numSequential:int = 0;
		public function TorrentPieces(len:int) {
			for (var i:int=0, l:int=len; i<l; ++i){
				pieces.push(0);
				piecesTime.push(0);
			}
		}
		
		public function setDownloaded(index:int):void {
			pieces[index] = 1;
			if(!hasLast)
				hasLast = (pieces[pieces.length-1] == 1);
			calcTotals();
		}
		public function setTime(index:int,time:int):void { //milliseconds
			piecesTime[index] = time;
		}
		private function calcTotals():void {
			numDownloaded = 0;
			for (var i:int=0, l:int=pieces.length; i<l; ++i)
				if(pieces[i] == 1) numDownloaded++;
			numSequential = pieces.indexOf(0);
		}
	}
}