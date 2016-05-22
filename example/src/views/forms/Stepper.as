package views.forms {
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextFormatAlign;
	
	import events.FormEvent;
	
	import feathers.display.Scale3Image;
	import feathers.textures.Scale3Textures;
	
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class Stepper extends Sprite {
		private var txtures:Scale3Textures = new Scale3Textures(Assets.getAtlas().getTexture("stepper-bg"),4,18);
		private var inputBG:Scale3Image = new Scale3Image(txtures);
		private var upArrow:Image = new Image(Assets.getAtlas().getTexture("stepper-arrow"));
		private var downArrow:Image = new Image(Assets.getAtlas().getTexture("stepper-arrow"));
		private var w:int;
		public var nti:NativeTextInput;
		private var isEnabled:Boolean = true;
		private var increment:int;
		public function Stepper(_w:int,_txt:String,_maxChars:int=3,_increment:int=1) {
			super();
			this.addEventListener(starling.events.Event.ADDED_TO_STAGE,onAddedToStage);
			w = _w;
			increment = _increment;
			inputBG.width = w;
			inputBG.blendMode = BlendMode.NONE;
			inputBG.touchable = false;
			inputBG.flatten();
			nti = new NativeTextInput(w-29,_txt,false,0xC0C0C0);
			nti.align = TextFormatAlign.RIGHT;
			nti.maxChars = _maxChars;
			nti.restrict = "0-9";
			upArrow.x = w - 24;
			upArrow.y = 1;
			upArrow.addEventListener(TouchEvent.TOUCH,onUp);
			
			downArrow.scaleY = -1;
			downArrow.x = w - 24;
			downArrow.y = 24;
			downArrow.addEventListener(TouchEvent.TOUCH,onDown);
			
			addChild(inputBG);
			addChild(upArrow);
			addChild(downArrow);
		}
		
		private function onUp(event:TouchEvent):void {
			var touch:Touch = event.getTouch(upArrow);
			if(touch && touch.phase == TouchPhase.ENDED && isEnabled)
				this.dispatchEvent(new FormEvent(FormEvent.CHANGE,{value:increment}));
		}
		private function onDown(event:TouchEvent):void {
			var touch:Touch = event.getTouch(downArrow);
			if(touch && touch.phase == TouchPhase.ENDED && isEnabled)
				this.dispatchEvent(new FormEvent(FormEvent.CHANGE,{value:-increment}));
		}
		public function enable(value:Boolean):void {
			isEnabled = value;
			downArrow.alpha = upArrow.alpha = inputBG.alpha = inputBG.alpha = (value) ? 1 : 0.25;
			nti.enable(value);
			nti.enable(value);
			nti.enable(value);
		}
		
		private function onAddedToStage(event:starling.events.Event):void {
			updatePosition();
			nti.addEventListener("CHANGE",changeHandler);
			Starling.current.nativeOverlay.addChild(nti);
		}
		public function updatePosition():void {
			var pos:Point = this.parent.localToGlobal(new Point(this.x,this.y));
			var offsetY:int = 1;
			nti.x = pos.x + 3;
			nti.y = pos.y + offsetY;
		}
		protected function changeHandler(event:flash.events.Event):void {
			this.dispatchEvent(new FormEvent(FormEvent.CHANGE));
		}
	}
}