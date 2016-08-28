package model {
	import org.mangui.hls.model.Fragment;

	public class HLSMap {
		private var _fragment:Fragment;
		private var _startPiece:int;
		private var _endPiece:int;
		private var _pieces:Vector.<int> = new Vector.<int>();
		public function HLSMap() {
			
		}

		public function get fragment():Fragment {
			return _fragment;
		}

		public function set fragment(value:Fragment):void {
			_fragment = value;
		}

		public function get startPiece():int {
			return _startPiece;
		}

		public function set startPiece(value:int):void {
			_startPiece = value;
		}

		public function get endPiece():int {
			return _endPiece;
		}

		public function set endPiece(value:int):void {
			_endPiece = value;
		}

		public function initPieces():void {
			for(var i:int = 0;i < _endPiece-_startPiece+1;i++)
				pieces.push(0);
		}
		public function setPiece(index:int,value:int):void {
			pieces[index-_startPiece] = value;
		}
		public function hasAllPieces():Boolean {
			for (var k:int=0, ll:int=_pieces.length; k<ll; ++k){
				if(_pieces[k] == 0)
					return false;
			}
			return true;
		}

		public function get pieces():Vector.<int> {
			return _pieces;
		}

		public function set pieces(value:Vector.<int>):void {
			_pieces = value;
		}
		


	}
}