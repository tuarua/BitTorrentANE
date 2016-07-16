package views.client.http {
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.utils.Align;
	
	import views.SrollableContent;
	
	public class HttpPanel extends Sprite {
		
		private var holder:Sprite = new Sprite();
		private var fileList:SrollableContent;
		
		public function HttpPanel() {
			super();
			fileList = new SrollableContent(1200,275,holder);
			fileList.y = 20;
			addChild(fileList);
		}
		public function populate(_itms:Vector.<String>):void {
			clear();
			
			var txt:TextField;
			for(var j:int=0,ll:int=_itms.length;j<ll;++j){
				txt = new TextField(800,32,_itms[j]);
				txt.format.setTo("Fira Sans Semi-Bold 13",13,0xD8D8D8,Align.LEFT);
				txt.x = 24;
				txt.y = j*22;
				txt.batchable = true;
				txt.touchable = false;
				holder.addChild(txt);
			}
			
			fileList.fullHeight = (j*22)+12;
			fileList.init();
			
		}
		
		public function destroy():void {
			fileList.reset();
			var k:int = holder.numChildren;
			while(k--)
				holder.removeChildAt(k);
			holder.dispose();
		}
		public function clear():void {
			fileList.reset();
			var k:int = holder.numChildren;
			while(k--)
				holder.removeChildAt(k);
			
		}
	}
}