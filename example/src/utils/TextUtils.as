package utils {
	public class TextUtils {
		public static function cleanChars(_s:String):String{
			var pattern1:RegExp = new RegExp(String.fromCharCode(956), "g");
			var ret:String = _s;
			if(ret){
			}
			return ret;
		}
		public static function trim(s:String):String {
			return s ? s.replace(/^\s+|\s+$/gs, '') : "";
		}
		private static const byteSizes:Array = ["B", "KiB", "MiB", "GiB", "TiB", "PiB", "EiB", "ZiB", "YiB"];
		private static const bitsSizes:Array = ["bps", "Kbps", "Mbps", "Gbps", "Tbps", "Pbps", "Ebps", "Zbps", "Ybps"];
		public static function bytesToString(bytes:Number):String {
			var index:uint = Math.floor(Math.log(bytes)/Math.log(1024));
			return (bytes/Math.pow(1024, index)).toFixed(2) + " " +byteSizes[index];
		}
		public static function bitsPerSecToString(bits:Number):String {
			var index:uint = Math.floor(Math.log(bits)/Math.log(1000));
			return (bits/Math.pow(1000, index)).toFixed(2) + " " +bitsSizes[index];
		}
	}
}