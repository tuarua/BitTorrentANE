package views.client {
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.utils.HAlign;
	
	public class HttpPanel extends Sprite {
		
		public function HttpPanel() {
			super();
		}
		public function populate(_itms:Vector.<String>):void {
			var k:int = this.numChildren;
			while(k--)
				this.removeChildAt(k);
			var txt:TextField;
			for(var j:int=0,ll:int=_itms.length;j<ll;++j){
				txt = new TextField(800,32,_itms[j], "Fira Sans Regular 13", 13, 0xD8D8D8);
				txt.hAlign = HAlign.LEFT;
				txt.x = 24;
				txt.y = j*20 + 10;
				txt.batchable = true;
				txt.touchable = false;
				addChild(txt);
			}
		}
		public function destroy():void {
			var k:int = this.numChildren;
			while(k--)
				this.removeChildAt(k);
		}
		public function clear():void {
			var k:int = this.numChildren;
			while(k--)
				this.removeChildAt(k);
		}
	}
}