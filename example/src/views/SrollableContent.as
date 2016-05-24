package views {
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class SrollableContent extends Sprite {
		private var _w:int = 1200;
		private var scrollBar:Quad;
		private var nScrollbarOffset:int = 0;
		private var scrollBeganY:int;
		private var _h:int = 255;
		private var _fullHeight:uint;
		private var _spr:Sprite;
		public function SrollableContent(w:int,h:int,spr:Sprite) {
			super();
			_w = w;
			_h = h;
			_spr = spr;
			this.clipRect = new Rectangle(0,0,w,h);
			addChild(spr);//holder
		}
		
		public function set fullHeight(value:uint):void {
			_fullHeight = value;
		}
		
		public function init():void {
			setupScrollBar();
			recalculate();
		}
		
		private function setupScrollBar():void {
			if(scrollBar && this.contains(scrollBar)) removeChild(scrollBar);
			scrollBar = new Quad(8,_h,0xCC8D1E);
			scrollBar.alpha = 1;
			scrollBar.visible = false;
			scrollBar.y = nScrollbarOffset;
			scrollBar.x = _w - 12;
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
				
				if(y < 0) y = 0;
				if(y > (_h - scrollBar.height))
					y = _h - scrollBar.height;
				
				scrollBar.y = y;	
				var percentage:Number = (y - nScrollbarOffset) / (_h-scrollBar.height);
				_spr.y = Math.round(-((_fullHeight - _h)*percentage));
			}
		}
		
		public function recalculate():void {
			scrollBar.scaleY = _h/_fullHeight;
			scrollBar.visible = !(_fullHeight < _h);
		}

	}
}