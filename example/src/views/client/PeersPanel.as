package views.client {
	import com.tuarua.torrent.PeerInfo;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.QuadBatch;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.utils.HAlign;
	
	import utils.TextUtils;
	
	public class PeersPanel extends Sprite {
		private static var divArr:Array = new Array(0,36,140,220,320,420,600,690,790,890,990,1090,1180);
		private static var headingArr:Array = new Array("", "IP", "Port","Connection","Flags","Client","Progress","Down Speed","Up Speed","Downloaded","Uploaded","Relevance");
		private static var headingAligns:Array = new Array(HAlign.CENTER,HAlign.LEFT,HAlign.LEFT,HAlign.LEFT,HAlign.LEFT,HAlign.LEFT,HAlign.RIGHT,HAlign.RIGHT,HAlign.RIGHT,HAlign.RIGHT,HAlign.RIGHT,HAlign.RIGHT,HAlign.RIGHT);
		private var bg:QuadBatch = new QuadBatch();
		private var headingHolder:Sprite = new Sprite();
		
		private var itmHolder:Sprite = new Sprite();
		private var holder:Sprite = new Sprite();
		
		private var txtHolder:Sprite = new Sprite();
		private var imgHolder:Sprite = new Sprite();
		private var w:int = 1200;
		private var scrollBar:Quad;
		private var nScrollbarOffset:int = 40;
		private var scrollBeganY:int;
		private var h:int = 255;
		private var fullHeight:uint;
		
		public function PeersPanel() {
			super();
			var divider:Quad = new Quad(1,28,0x202020);
			divider.y = 2;
			var heading:TextField;
			for (var i:int=0, l:int=divArr.length; i<l; ++i){
				divider.x = divArr[i];
				if(i > 0) bg.addQuad(divider);
				heading = new TextField(divArr[i+1] - divArr[i] - 24,32,headingArr[i], "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
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
			
			

			holder.addChild(txtHolder);
			holder.addChild(imgHolder);
			itmHolder.addChild(holder);
			
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
				if(y > (itmHolder.y + 255 - scrollBar.height))
					y = itmHolder.y + 255 - scrollBar.height;
				scrollBar.y = y;	
				var percentage:Number = (y - nScrollbarOffset) / (h-scrollBar.height);
				holder.y = -((fullHeight - h)*percentage);
			}
		}
		public function destroy():void {
			var k:int = txtHolder.numChildren;
			
			while(k--)
				txtHolder.removeChildAt(k);
			txtHolder.dispose();
			k = imgHolder.numChildren;
			while(k--)
				imgHolder.removeChildAt(k);
			imgHolder.dispose();
			
			//dispose anything else ?
			
		}
		
		public function clear():void {
			var k:int = txtHolder.numChildren;
			while(k--)
				txtHolder.removeChildAt(k);
			k = imgHolder.numChildren;
			while(k--)
				imgHolder.removeChildAt(k);
			scrollBar.visible = false;
		}
		
		public function update(_tp:Vector.<PeerInfo>):void {
			
			var srtArr:Array = [];
			while(_tp.length > 0) srtArr.push(_tp.pop());
			srtArr.sortOn("downSpeed", Array.NUMERIC);
			while(srtArr.length > 0) _tp.push(srtArr.pop());
			
			var rowIndex:int;
			for (var i:int=0, l:int=_tp.length; i<l; ++i){
				if(i > 19) break; //limit to 19
				rowIndex = i*(divArr.length-2);
				//10 cols, i is col, j is row
				if(rowIndex > (txtHolder.numChildren-1)) {
					var txt:TextField;
					var img:Image;
					for(var j:int=1,ll:int=divArr.length-1;j<ll;++j){
						txt = new TextField(divArr[j+1] - divArr[j] - 24,32,"", "Fira Sans Semi-Bold 13", 13, /*(j == 4)  ? 0x5CB601 : */0xD8D8D8);
						txt.hAlign = headingAligns[j];
						txt.x = divArr[j] + 12;
						txt.y = i*20;
						txt.batchable = true;
						txt.touchable = false;
						txtHolder.addChild(txt);
					}
					img = new Image(Assets.getAtlas().getTexture("placeholder"));
					img.x = 10;
					img.y = (i*20) + 8;
					imgHolder.addChild(img);
				}
				
				if ((txtHolder.getChildAt(rowIndex+0) as TextField).text != _tp[i].ip)
					(txtHolder.getChildAt(rowIndex+0) as TextField).text = _tp[i].ip;
				if ((txtHolder.getChildAt(rowIndex+1) as TextField).text != _tp[i].port.toString())
					(txtHolder.getChildAt(rowIndex+1) as TextField).text = _tp[i].port.toString();
				if ((txtHolder.getChildAt(rowIndex+2) as TextField).text != _tp[i].connection)
					(txtHolder.getChildAt(rowIndex+2) as TextField).text = _tp[i].connection;
				if ((txtHolder.getChildAt(rowIndex+3) as TextField).text != _tp[i].flagsAsString)
					(txtHolder.getChildAt(rowIndex+3) as TextField).text = _tp[i].flagsAsString;
				if((txtHolder.getChildAt(rowIndex+4) as TextField).text != TextUtils.cleanChars(_tp[i].client))
					(txtHolder.getChildAt(rowIndex+4) as TextField).text = TextUtils.cleanChars(_tp[i].client);
				(txtHolder.getChildAt(rowIndex+5) as TextField).text = (_tp[i].progress > 0) ? (_tp[i].progress*100.0).toFixed(1)+"%" : "";
				(txtHolder.getChildAt(rowIndex+6) as TextField).text = (_tp[i].downSpeed > 0) ? TextUtils.bytesToString(_tp[i].downSpeed) + "/s" : "";
				(txtHolder.getChildAt(rowIndex+7) as TextField).text = (_tp[i].upSpeed > 0) ? TextUtils.bytesToString(_tp[i].upSpeed) + "/s" : "";
				(txtHolder.getChildAt(rowIndex+8) as TextField).text = (_tp[i].downloaded > 0) ? TextUtils.bytesToString(_tp[i].downloaded) : "";
				(txtHolder.getChildAt(rowIndex+9) as TextField).text = (_tp[i].uploaded > 0) ? TextUtils.bytesToString(_tp[i].uploaded) : "";
				(txtHolder.getChildAt(rowIndex+10) as TextField).text = (_tp[i].relevance > 0) ? (_tp[i].relevance*100.0).toFixed(1)+"%" : "";
				
				if(_tp[i].country) {
					try{
						(imgHolder.getChildAt(i) as Image).texture = Assets.getAtlas().getTexture(_tp[i].country.toLowerCase());
						(imgHolder.getChildAt(i) as Image).readjustSize();
					}catch(error:Error){trace("no flag for this country",_tp[i].country);}
				}
				
			}
			
			if(txtHolder.numChildren/(divArr.length-2) > _tp.length)
				for(var k:int=txtHolder.numChildren-1;k > (_tp.length*(divArr.length-2)-1);k--){
					txtHolder.removeChildAt(k);
				
				for(var m:int=imgHolder.numChildren-1;m > _tp.length-1;m--)
					imgHolder.removeChildAt(m);
			}
			
			fullHeight = (_tp.length*20)+12;

			scrollBar.scaleY = h/fullHeight;
			scrollBar.visible = !(fullHeight < h);
			
		}
		
	}
}