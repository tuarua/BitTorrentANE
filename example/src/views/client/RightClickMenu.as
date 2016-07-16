package views.client {
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import events.InteractionEvent;
	
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.utils.Align;
	import starling.display.Image;
	public class RightClickMenu extends Sprite {
		private var w:int;
		private var h:int;
		private var items:Array;
		private var listBg:Image;
		private var listContainer:Sprite = new Sprite();
		private var hover:Quad;
		private var listOuterContainer:Sprite = new Sprite();
		private var tween:Tween;
		private var id:String;
		public function RightClickMenu(_id:String,_w:int,_items:Array) {
			super();
			id = _id;
			w = _w;
			items = _items;
			h = (items.length*20) + 5;
			
			hover = new Quad(w-6,20,0xCC8D1E);
			hover.alpha = 0.4;
			hover.visible = false;
			
			listBg = new Image(Assets.getAtlas().getTexture("right-click-bg"));
			listBg.scale9Grid = new Rectangle(4,4,41,17);
			listBg.blendMode = BlendMode.NONE;
			listBg.width = w;
			listBg.height = h;
			
			listContainer.addChild(listBg);
			hover.x = 3;
			hover.y = 2;
			listContainer.addChild(hover);
			
			var itmLbl:TextField;
			for (var i:int=0, l:int=items.length; i<l; ++i){
				itmLbl = new TextField(w,26,items[i].label);
				itmLbl.format.setTo("Fira Sans Semi-Bold 13", 13, 0xD8D8D8,Align.LEFT,Align.CENTER);
				itmLbl.batchable = true;
				itmLbl.touchable = false;
				itmLbl.x = 8;
				itmLbl.y = (i*20) + 0;
				listContainer.addChild(itmLbl);
			}
			
			listContainer.addEventListener(TouchEvent.TOUCH,onListTouch);
			listOuterContainer.addChild(listContainer);
			listOuterContainer.visible = true;
			addChild(listOuterContainer);
		}
		public function open():void {
			listOuterContainer.visible = true;
			Starling.current.nativeStage.addEventListener(MouseEvent.CLICK,onClick);
		}
		private function onClick(event:MouseEvent):void {
			Starling.current.nativeStage.removeEventListener(MouseEvent.CLICK,onClick);
			close();
		}
		public function close():void {
			hover.visible = false;
			this.visible = false;
		}
		protected function onListTouch(event:TouchEvent):void {
			var hoverTouch:Touch = event.getTouch(listContainer, TouchPhase.HOVER);
			var clickTouch:Touch = event.getTouch(listContainer, TouchPhase.ENDED);
			if(hoverTouch){
				hover.visible = true;
				var p:Point = hoverTouch.getLocation(listContainer,p);
				var proposedHover:int = Math.floor((p.y)/20);
				if(proposedHover > -1 && proposedHover < items.length)
					hover.y = (proposedHover*20)+2;
			}else if(clickTouch){
				var pClick:Point = clickTouch.getLocation(listContainer,pClick);
				var proposedSelected:int = Math.floor((pClick.y)/20);
				if(proposedSelected > -1 && proposedSelected < items.length)
					this.dispatchEvent(new InteractionEvent(InteractionEvent.ON_MENU_ITEM_RIGHT,{value:items[proposedSelected].value,id:id},true));
			}else{
				
			}
			
		}
	}
}