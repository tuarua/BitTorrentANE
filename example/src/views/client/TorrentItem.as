package views.client {
	import com.tuarua.torrent.TorrentInfo;
	import com.tuarua.torrent.TorrentStateCodes;
	import com.tuarua.torrent.TorrentStatus;
	
	import events.InteractionEvent;
	
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.utils.Align;
	
	import utils.TextUtils;
	import utils.TimeUtils;
	
	public class TorrentItem extends Sprite {
		private var txtHolder:Sprite = new Sprite();
		private var _id:String;
		private var highlight:Quad = new Quad(1180,20,0xCC8D1E);
		private var isSelected:Boolean = false;
		private static const divArr:Array = new Array(0,36,320, 410,474,600,665,724,825,925,1015);
		private static const txtAligns:Array = new Array(Align.CENTER,Align.LEFT,Align.RIGHT,Align.RIGHT,Align.LEFT,Align.RIGHT,Align.RIGHT,Align.RIGHT,Align.RIGHT,Align.RIGHT,Align.RIGHT);
		public function TorrentItem() {
			super();
			txtHolder.touchable = false;
			highlight.alpha = 0.0;
			
			var txtArr:Array = new Array("", "", "","","","","","","","","");
			var txt:TextField;
			for (var i:int=0, l:int=divArr.length; i<l; ++i){
				if(i < l) {
					txt = new TextField(divArr[i+1] - divArr[i] - 24,32,txtArr[i]);
					txt.format.setTo("Fira Sans Semi-Bold 13", 13, 0xD8D8D8,txtAligns[i]);
					txt.x = divArr[i] + 12;
					txt.batchable = true;
					txt.touchable = false;
					txtHolder.addChild(txt);
				}
			}
			highlight.y = 5;
			highlight.useHandCursor = false;
			highlight.addEventListener(TouchEvent.TOUCH,onHighlightClick);
			addChild(highlight);
			addChild(txtHolder);	
			
		}
		
		
		private function onHighlightClick(event:TouchEvent):void {
			var touch:Touch = event.getTouch(highlight);
			if(touch && touch.phase == TouchPhase.ENDED){
				//isSelected = !isSelected
				//select(isSelected);
				if(!isSelected)
					this.dispatchEvent(new InteractionEvent(InteractionEvent.ON_TORRENT_ITEM_SELECT,{id:_id},true));
			}
		}
		public function select(_b:Boolean):void {
			isSelected = _b;
			var targetAlpha:Number = (isSelected) ? 0.4 : 0;
			var tween:Tween = new Tween(highlight, 0.1, Transitions.LINEAR);
			tween.animate("alpha",targetAlpha);
			Starling.juggler.add(tween);
		}
		public function update(_tm:TorrentInfo,_ts:TorrentStatus,_isSelected:Boolean=false):void {
			if(_tm && _ts){
				_id = _ts.id;
				(txtHolder.getChildAt(0) as TextField).text = (_ts.queuePosition == -1) ? "*" :(_ts.queuePosition+1).toString();
				(txtHolder.getChildAt(1) as TextField).text = _tm.name;
				(txtHolder.getChildAt(2) as TextField).text = TextUtils.bytesToString(_tm.size);
				(txtHolder.getChildAt(3) as TextField).text = (_ts.progress >= 100) ? "100%" : _ts.progress.toFixed(1) + "%";
				(txtHolder.getChildAt(4) as TextField).text = TorrentStateCodes.getMessageFromCode(_ts.state);
				(txtHolder.getChildAt(5) as TextField).text = _ts.numPeers.toString();
				(txtHolder.getChildAt(6) as TextField).text = _ts.numSeeds.toString();
				(txtHolder.getChildAt(7) as TextField).text = TextUtils.bytesToString(_ts.downloadRate) + "/s";
				(txtHolder.getChildAt(8) as TextField).text = TextUtils.bytesToString(_ts.uploadRate) + "/s";
				(txtHolder.getChildAt(9) as TextField).text = (_ts.ETA > 0 && _ts.ETA < (60*60*24*2)) ? TimeUtils.secsToTimeCode(_ts.ETA) : "∞";
				//select(_isSelected);
			}
		}
		
		public function get id():String {
			return _id;
		}
		

		public function clear():void {
	
		}
	}
}