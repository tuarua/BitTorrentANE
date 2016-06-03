package views.client {
	import com.tuarua.torrent.PeerInfo;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.QuadBatch;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.utils.HAlign;
	
	import utils.TextUtils;
	import views.SrollableContent;
	
	public class PeersPanel extends Sprite {
		private static var divArr:Array = new Array(0,36,140,220,320,420,600,690,790,880,990,1090,1180);
		private static var headingArr:Array = new Array("", "IP", "Port","Connection","Flags","Client","Progress","Down Speed","Up Speed","Downloaded","Uploaded","Relevance");
		private static var headingAligns:Array = new Array(HAlign.CENTER,HAlign.LEFT,HAlign.LEFT,HAlign.LEFT,HAlign.LEFT,HAlign.LEFT,HAlign.RIGHT,HAlign.RIGHT,HAlign.RIGHT,HAlign.RIGHT,HAlign.RIGHT,HAlign.RIGHT,HAlign.RIGHT);
		private var bg:QuadBatch = new QuadBatch();
		private var headingHolder:Sprite = new Sprite();
		private var holder:Sprite = new Sprite();
		
		private var txtHolder:Sprite = new Sprite();
		private var imgHolder:Sprite = new Sprite();
		private var peersList:SrollableContent;
		
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
			
			peersList = new SrollableContent(1200,255,holder);
			peersList.y = 40;
			
			addChild(bg);
			addChild(headingHolder);
			
			holder.addChild(txtHolder);
			holder.addChild(imgHolder);
			
			peersList.fullHeight = 10;
			peersList.init();
			addChild(peersList);
			
		}
		public function destroy():void {
			peersList.reset();
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
			
			peersList.recalculate();
		}
		
		public function update(_tp:Vector.<PeerInfo>):void {
			
			var srtArr:Array = [];
			while(_tp.length > 0) srtArr.push(_tp.pop());
			srtArr.sortOn("downSpeed", Array.NUMERIC);
			while(srtArr.length > 0) _tp.push(srtArr.pop());
			
			var rowIndex:int;
			var cnt:int = 0;
			for (var i:int=0, l:int=_tp.length; i<l; ++i){
				
				if(i > 19) break; //limit to 19
				cnt = i+1;
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
			
			if(txtHolder.numChildren/(divArr.length-2) > cnt)
				for(var k:int=txtHolder.numChildren-1;k > (cnt*(divArr.length-2)-1);k--){
					txtHolder.removeChildAt(k);
				
				for(var m:int=imgHolder.numChildren-1;m > cnt-1;m--)
					imgHolder.removeChildAt(m);
			}
			
			peersList.fullHeight = (cnt*20)+12;
			peersList.recalculate();
		}
		
	}
}