package views.forms {
	import flash.events.Event;
	import flash.geom.Point;
	import flash.text.TextFieldType;
	import flash.text.TextFormatAlign;
	
	import events.FormEvent;
	
	import feathers.display.Scale3Image;
	import feathers.textures.Scale3Textures;
	
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Sprite;
	import starling.events.Event;
	
	import views.forms.NativeTextInput;
	
	public class Input extends Sprite {
		private var txtures:Scale3Textures = new Scale3Textures(Assets.getAtlas().getTexture("input-bg"),4,16);
		private var inputBG:Scale3Image = new Scale3Image(txtures);
		private var w:int;
		public var nti:NativeTextInput;
		private var isEnabled:Boolean = true;
		private var _password:Boolean = false;
		private var _type:String = TextFieldType.INPUT;
		public function Input(_w:int,_txt:String) {
			super();
			this.addEventListener(starling.events.Event.ADDED_TO_STAGE,onAddedToStage);
			w = _w;
			inputBG.width = w;
			inputBG.blendMode = BlendMode.NONE;
			inputBG.touchable = false;
			inputBG.flatten();
			
			//trace("creating input with type",_type);
			
			nti = new NativeTextInput(w-10,_txt,false,0xC0C0C0);
			
			
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
			_password = value;
			nti.password = _password;
		}

		public function set type(value:String):void {
			_type = value;
			nti.type = _type;
		}

		
	}
}