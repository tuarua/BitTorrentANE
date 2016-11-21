package com.tuarua.torrent.utils {
	public class Magnet extends Object {
		private var _name:String;
		private var _hash:String;

		public function get name():String {
			return _name;
		}

		public function set name(value:String):void {
			_name = value;
		}

		public function get hash():String {
			return _hash;
		}

		public function set hash(value:String):void {
			_hash = value;
		}
		/** 
		 * This method is omitted from the output. * * @private 
		 */ 
		public function Magnet(){}
	}
}