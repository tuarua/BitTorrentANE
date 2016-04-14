package views.client {
	import com.tuarua.torrent.TrackerInfo;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.display.QuadBatch;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.utils.HAlign;

	public class TrackersPanel extends Sprite {
		private static var divArr:Array = new Array(0,36,400,600,700,1100);
		private static var headingArr:Array = new Array("#", "URL", "Status","Peers","Message","");
		private static var headingAligns:Array = new Array(HAlign.CENTER,HAlign.LEFT,HAlign.LEFT,HAlign.RIGHT,HAlign.LEFT,HAlign.LEFT);
		private var bg:QuadBatch = new QuadBatch();
		private var headingHolder:Sprite = new Sprite();
		private var itmHolder:Sprite = new Sprite();
		private var txtHolder:Sprite = new Sprite();
		private var w:int = 1200;
		private var scrollBar:Quad;
		private var nScrollbarOffset:int = 40;
		private var scrollBeganY:int;
		private var h:int = 255;
		public function TrackersPanel() {
			super();
			var divider:Quad = new Quad(1,28,0x202020);
			divider.y = 2;
			var heading:TextField;
			for (var i:int=0, l:int=divArr.length; i<l; ++i){
				divider.x = divArr[i];
				if(i > 0) bg.addQuad(divider);
				heading = new TextField(divArr[i+1] - divArr[i] - 24,32,headingArr[i], "Fira Sans Regular 13", 13, 0xD8D8D8);
				heading.hAlign = headingAligns[i];
				heading.x = divArr[i] + 12;
				heading.batchable = true;
				heading.touchable = false;
				headingHolder.addChild(heading);
			}
			bg.y = 10;
			headingHolder.y = 10;
			itmHolder.y = 40;
			itmHolder.clipRect = new Rectangle(0,0,w,h);
			//itmHolder.mask = new Quad(w,h);
			addChild(bg);
			addChild(headingHolder);
			itmHolder.addChild(txtHolder);
			addChild(itmHolder);
			
			setupScrollBar();
		}
		private function setupScrollBar():void {
			if(scrollBar && this.contains(scrollBar)) removeChild(scrollBar);
			scrollBar = new Quad(8,h,0xCC8D1E);
			scrollBar.alpha = 1;
			scrollBar.visible = false;
			scrollBar.y = nScrollbarOffset;
			scrollBar.x = 1200 - 12;
			scrollBar.addEventListener(TouchEvent.TOUCH,onScrollBarTouch);
			addChild(scrollBar);
		}
		private function onScrollBarTouch(event:TouchEvent):void {
			var touch:Touch = event.getTouch(scrollBar);
			if(touch && touch.phase == TouchPhase.BEGAN) scrollBeganY = globalToLocal(new Point(0,touch.globalY)).y-scrollBar.y;
			if(touch && touch.phase == TouchPhase.ENDED) scrollBeganY = -1;
			if(touch && touch.phase == TouchPhase.HOVER) Starling.juggler.tween(scrollBar, 0.2, {transition: Transitions.LINEAR,alpha: 1});
			if(touch == null) Starling.juggler.tween(scrollBar, 0.2, {transition: Transitions.LINEAR,alpha: 0});
			
			if(touch && touch.phase == TouchPhase.MOVED){
				var y:int = globalToLocal(new Point(touch.globalX,touch.globalY-(scrollBeganY))).y;
				if(y < itmHolder.y) y = itmHolder.y;
				if(y > (itmHolder.y + itmHolder.height - scrollBar.height)) y = itmHolder.y + itmHolder.height - scrollBar.height;
				scrollBar.y = y;	
				var percentage:Number = (y - nScrollbarOffset) / (h-scrollBar.height);
				txtHolder.y = -((txtHolder.height - h)*percentage)
			}
		}
		
		public function destroy():void {
			var k:int = txtHolder.numChildren;
			while(k--)
				txtHolder.removeChildAt(k);
			txtHolder.dispose();
		}
		
		public function clear():void {
			var k:int = txtHolder.numChildren;
			while(k--)
				txtHolder.removeChildAt(k);
			scrollBar.visible = false;
		}
		
		public function update(_tt:Vector.<TrackerInfo>):void {
			var srtArr:Array = [];

			while(_tt.length > 0) srtArr.push(_tt.pop());
			srtArr.sortOn("url", Array.CASEINSENSITIVE);
			srtArr.reverse();
			while(srtArr.length > 0) _tt.push(srtArr.pop());
			
			var rowIndex:int;
			for (var i:int=0, l:int=_tt.length; i<l; ++i){
				rowIndex = i*(divArr.length-1);
				//10 cols, i is col, j is row
				if(rowIndex > (txtHolder.numChildren-1)) {
					var txt:TextField;
					for(var j:int=0,ll:int=divArr.length-1;j<ll;++j){
						txt = new TextField(divArr[j+1] - divArr[j] - 24,32,"", "Fira Sans Regular 13", 13, 0xD8D8D8);
						txt.hAlign = headingAligns[j];
						txt.x = divArr[j] + 12;
						txt.y = i*20;
						txt.batchable = true;
						txt.touchable = false;
						txtHolder.addChild(txt);
					}
				}
				
				(txtHolder.getChildAt(rowIndex+0) as TextField).text = (_tt[i].tier > 0) ? _tt[i].tier.toString() : "";
				(txtHolder.getChildAt(rowIndex+1) as TextField).text = _tt[i].url;
				(txtHolder.getChildAt(rowIndex+2) as TextField).text = _tt[i].status;
				(txtHolder.getChildAt(rowIndex+3) as TextField).text = _tt[i].numPeers.toString();
				(txtHolder.getChildAt(rowIndex+4) as TextField).text = _tt[i].message;
			}
			
			if(txtHolder.numChildren/(divArr.length-1) > _tt.length){
				for(var k:int=txtHolder.numChildren-1;k > (_tt.length*(divArr.length)-1);k--){
					txtHolder.removeChildAt(k);
				}
			}
			scrollBar.y = nScrollbarOffset;
			scrollBar.scaleY = h/txtHolder.height;
			scrollBar.visible = !(itmHolder.height < h);
		}
			
			
	}
}