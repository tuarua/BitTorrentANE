package views.forms {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import starling.core.Starling;
	
	public class NativeTextInput extends Sprite {
		public var input:TextField = new TextField();
		private var firaSansRegularFont:Font = new FiraSansSemiBold();
		private var defaultText:String;
		private var clearOnFocus:Boolean = false;
		private var restrict:String;
		private var originalType:String;
		private var textFormat:TextFormat;
		private var _fontSize:uint = 13;
		private var _type:String = TextFieldType.INPUT;
		private var _password:Boolean = false;
		private var _align:String = TextFormatAlign.LEFT;
		private var _maxChars:uint = 0;
		private var _restrict:String = null;
		public function NativeTextInput(_w:int,_txt:String,_clearOnFocus:Boolean=false,_fontColor:uint=0x111111) {
			super();
			defaultText = _txt;
			clearOnFocus = _clearOnFocus;
			originalType = _type;
			
			textFormat = new TextFormat();
			textFormat.font = firaSansRegularFont.fontName;
			textFormat.size = _fontSize;
			textFormat.align = _align;
			textFormat.color = _fontColor;
			
			input.width = _w;
			input.height = 24;
			input.multiline = false;
			input.selectable = true;
			input.defaultTextFormat = textFormat;
			input.embedFonts = true;
			if(_restrict)
				input.restrict = _restrict;
			
			input.antiAliasType = AntiAliasType.ADVANCED;
			input.sharpness = -100;
			input.type = _type;
			
			input.addEventListener(Event.CHANGE,onTextInput);
			input.addEventListener(FocusEvent.FOCUS_IN,onFocusInput);
			input.text = _txt;
			input.y = 0;
			input.visible = false;
			//Starling.current.nativeOverlay.stage.focus = input;
			input.setSelection(0,1);
			addChild(input);
		}

		public function enable(value:Boolean,withFade:Boolean=true):void {
			if(withFade) input.alpha = (value) ? 1.0 : 0.25;
			input.selectable = value;
			input.type = (value) ? originalType : TextFieldType.DYNAMIC;
		}
		public function show(value:Boolean):void {
			input.visible = value;
		}
		protected function onKeyUp(event:KeyboardEvent):void {
			if(event.charCode == 13)
				this.dispatchEvent(new Event("FOCUS_OUT",true));
		}
		protected function onFocusInput(event:FocusEvent):void {
			if(input.text == defaultText && clearOnFocus)
				input.text = "";
		}
		protected function onInputFocusOut(event:FocusEvent):void {
			this.dispatchEvent(new Event("FOCUS_OUT",true));
		}
		
		protected function onTextInput(event:Event):void {
			this.dispatchEvent(new Event("CHANGE",true));
		}
		public function dispose():void {
			if(Starling.current.nativeOverlay.contains(this))
				Starling.current.nativeOverlay.removeChild(this);
		}

		public function set fontSize(value:uint):void {
			_fontSize = value;
			textFormat.size = _fontSize;
			input.setTextFormat(textFormat);
		}
		public function set align(value:String):void {
			_align = value;
			textFormat.align = _align;
			input.setTextFormat(textFormat);
		}

		public function set type(value:String):void {
			_type = value;
			originalType = _type;
			input.type = _type;
		}
		public function set maxChars(value:uint):void {
			_maxChars = value;
			if(_maxChars > 0)
				input.maxChars = _maxChars;
		}
		
		public function set password(value:Boolean):void {
			_password = value;
			input.displayAsPassword = _password;
		}
		public function set restrict(value:String):void {
			_restrict = value;
			if(_restrict)
				input.restrict = _restrict;
		}

	}
}