package views.forms {
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import events.FormEvent;
	
	import feathers.display.Scale3Image;
	import feathers.display.Scale9Image;
	import feathers.textures.Scale3Textures;
	import feathers.textures.Scale9Textures;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	import starling.display.BlendMode;
	
	public class DropDown extends Sprite { //5 draw calls - not nice
		private var w:int;
		private var h:int;
		private var selected:int;
		private var items:Vector.<Object>;
		private var bg:Scale3Image;
		private var bgTexture:Scale3Textures = new Scale3Textures(Assets.getAtlas().getTexture("dropdown-bg"),4,23);
		private var listBg:Scale9Image;
		private var listBgTexture:Scale9Textures;
		private var listContainer:Sprite = new Sprite();
		private var hover:Quad;
		private var txt:TextField;
		private var listOuterContainer:Sprite = new Sprite();
		private var tween:Tween;
		public function DropDown(_w:int,_items:Vector.<Object>,_selected:int=0) {
			super();
			w = _w;
			items = _items;
			selected = _selected;
			h = (items.length*20) + 5;
			bg = new Scale3Image(bgTexture);
			bg.width = w;
			bg.blendMode = BlendMode.NONE;
			
			hover = new Quad(w-6,20,0xCC8D1E);
			hover.alpha = 0.4;
			
			txt = new TextField(w,26,items[selected].label, "Fira Sans Regular 13", 13, 0xD8D8D8);
			txt.batchable = true;
			txt.touchable = false;
			txt.hAlign = HAlign.LEFT;
			txt.vAlign = VAlign.CENTER;
			txt.x = 8;
			
			bg.addEventListener(TouchEvent.TOUCH,onTouch);
			
			listBgTexture = new Scale9Textures(Assets.getAtlas().getTexture("dropdown-items-bg"),new Rectangle(4,4,41,17));
			listBg = new Scale9Image(listBgTexture);
			listBg.blendMode = BlendMode.NONE;
			listBg.width = w;
			listBg.height = h;
			
			
			listContainer.y = 25-h;
			listOuterContainer.clipRect = new Rectangle(0,25,w,h);
			
			listContainer.addChild(listBg);
			hover.x = 3;
			hover.y = (selected*20)+2;
			listContainer.addChild(hover);
			
			var itmLbl:TextField;
			for (var i:int=0, l:int=items.length; i<l; ++i){
				itmLbl = new TextField(w,26,items[i].label, "Fira Sans Regular 13", 13, 0xD8D8D8);
				itmLbl.batchable = true;
				itmLbl.touchable = false;
				itmLbl.hAlign = HAlign.LEFT;
				itmLbl.vAlign = VAlign.CENTER;
				itmLbl.x = 8;
				itmLbl.y = (i*20) + 0;
				listContainer.addChild(itmLbl);
			}
			
			listContainer.addEventListener(TouchEvent.TOUCH,onListTouch);
			listOuterContainer.addChild(listContainer);
			listOuterContainer.visible = false;
			addChild(listOuterContainer);
			addChild(bg);
			addChild(txt);
		}
		protected function onTouch(event:TouchEvent):void{
			event.stopPropagation();
			var touch:Touch = event.getTouch(bg, TouchPhase.ENDED);
			if(touch && touch.phase == TouchPhase.ENDED)
				open();
		}
		
		private function open():void {
			tween = new Tween(listContainer, 0.15, Transitions.EASE_OUT);
			tween.animate("y",25);
			listOuterContainer.visible = true;
			Starling.juggler.add(tween);
			this.dispatchEvent(new FormEvent(FormEvent.FOCUS_IN,null));
		}
		private function close():void {
			tween = new Tween(listContainer, 0.15, Transitions.EASE_IN);
			tween.animate("y",25-h);
			Starling.juggler.add(tween);
			tween.onComplete = function():void {
				listOuterContainer.visible = false;
			}
			this.dispatchEvent(new FormEvent(FormEvent.FOCUS_OUT,null));
		}
		
		protected function onListTouch(event:TouchEvent):void {
			var hoverTouch:Touch = event.getTouch(listContainer, TouchPhase.HOVER);
			var clickTouch:Touch = event.getTouch(listContainer, TouchPhase.ENDED);
			if(hoverTouch){
				var p:Point = hoverTouch.getLocation(listContainer,p);
				var proposedHover:int = Math.floor((p.y)/20);
				if(proposedHover > -1 && proposedHover < items.length && tween.isComplete)
					hover.y = (proposedHover*20)+2;
			}else if(clickTouch){
				var pClick:Point = clickTouch.getLocation(listContainer,pClick);
				var proposedSelected:int = Math.floor((pClick.y)/20);
				if(proposedSelected > -1 && proposedSelected < items.length){
					selected = proposedSelected;
					//hover.y = (proposedHover*20)+2;
					txt.text = items[selected].label;
					this.dispatchEvent(new FormEvent(FormEvent.CHANGE,{value:items[selected].value},false));
					//close 
					
					close();
					
				}
			}else{
				
			}

		}
		
	}
}