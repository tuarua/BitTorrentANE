package views.forms {
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFieldType;
	import flash.text.TextFormatAlign;
	
	import events.FormEvent;
	
	import feathers.display.Scale9Image;
	import feathers.textures.Scale9Textures;
	
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Sprite;
	import starling.events.Event;
	
	import views.forms.NativeTextInput;
	
	public class Input extends Sprite {
		private var txtures:Scale9Textures;
		private var inputBG:Scale9Image;
		//private var w:int;
		public var nti:NativeTextInput;
		private var isEnabled:Boolean = true;
		private var _password:Boolean = false;
		private var _type:String = TextFieldType.INPUT;
		private var _multiline:Boolean = false;
		public function Input(_w:int,_txt:String,_h:int=25) {
			super();
			this.addEventListener(starling.events.Event.ADDED_TO_STAGE,onAddedToStage);
			//w = _w;
			
			txtures = new Scale9Textures(Assets.getAtlas().getTexture("input-bg"),new Rectangle(4,4,16,16));
			inputBG = new Scale9Image(txtures);
			inputBG.width = _w;
			inputBG.height = _h;
			
			inputBG.blendMode = BlendMode.NONE;
			inputBG.touchable = false;
			inputBG.flatten();

			nti = new NativeTextInput(_w-10,_txt,false,0xC0C0C0);
			nti.setHeight(_h);
			
			addChild(inputBG);
		}
		
		private function onAddedToStage(event:starling.events.Event):void {
			updatePosition();
			nti.addEventListener("CHANGE",changeHandler);
			Starling.current.nativeOverlay.addChild(nti);
		}
		protected function changeHandler(event:flash.events.Event):void {
			this.dispatchEvent(new FormEvent(FormEvent.CHANGE));
		}
		public function updatePosition():void {
			var pos:Point = this.parent.localToGlobal(new Point(this.x,this.y));
			var offsetY:int = 1;
			nti.x = pos.x + 5;
			nti.y = pos.y + offsetY;
		}
		public function enable(_b:Boolean):void {
			isEnabled = _b;
			inputBG.alpha = (_b) ? 1 : 0.25;
			nti.enable(_b);
		}

		public function set password(value:Boolean):void {
			nti.password = _password = value;
		}

		public function set type(value:String):void {
			nti.type = _type = value;
		}

		public function set multiline(value:Boolean):void {
			nti.multiline = _multiline = value;
		}
		/*
		public function setHeight(value:int):void {
			_height = value;
			nti.setHeight(value);
		}
		*/
	}
}