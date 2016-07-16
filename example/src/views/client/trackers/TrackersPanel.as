package views.client.trackers {
	import com.tuarua.torrent.TrackerInfo;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.utils.Align;
	import views.SrollableContent;
	import starling.display.MeshBatch;

	public class TrackersPanel extends Sprite {
		private static var divArr:Array = new Array(0,36,400,600,700,1100);
		private static var headingArr:Array = new Array("#", "URL", "Status","Peers","Message","");
		private static var headingAligns:Array = new Array(Align.CENTER,Align.LEFT,Align.LEFT,Align.RIGHT,Align.LEFT,Align.LEFT);
		private var bg:MeshBatch = new MeshBatch();
		private var headingHolder:Sprite = new Sprite();
		private var holder:Sprite = new Sprite();
		private var txtHolder:Sprite = new Sprite();
		private var trackersList:SrollableContent;
		
		public function TrackersPanel() {
			super();
			var divider:Quad = new Quad(1,28,0x202020);
			divider.y = 2;
			var heading:TextField;
			for (var i:int=0, l:int=divArr.length; i<l; ++i){
				divider.x = divArr[i];
				if(i > 0) bg.addMesh(divider);
				heading = new TextField(divArr[i+1] - divArr[i] - 24,32,headingArr[i]);
				heading.format.setTo("Fira Sans Semi-Bold 13", 13, 0xD8D8D8,headingAligns[i]);
				heading.x = divArr[i] + 12;
				heading.batchable = true;
				heading.touchable = false;
				headingHolder.addChild(heading);
			}
			bg.y = 10;
			headingHolder.y = 10;
			trackersList = new SrollableContent(1200,255,holder);
			trackersList.y = 40;
			addChild(bg);
			addChild(headingHolder);
			
			holder.addChild(txtHolder);
			
			trackersList.fullHeight = 10;
			trackersList.init();
			addChild(trackersList);
		}
		
		public function destroy():void {
			trackersList.reset();
			var k:int = txtHolder.numChildren;
			while(k--)
				txtHolder.removeChildAt(k);
			txtHolder.dispose();
		}
		
		public function clear():void {
			var k:int = txtHolder.numChildren;
			while(k--)
				txtHolder.removeChildAt(k);
			trackersList.recalculate();
		}
		
		public function update(_tt:Vector.<TrackerInfo>):void {
			var srtArr:Array = [];

			while(_tt.length > 0) srtArr.push(_tt.pop());
			srtArr.sortOn("url", Array.CASEINSENSITIVE);
			srtArr.reverse();
			while(srtArr.length > 0) _tt.push(srtArr.pop());
			
			var rowIndex:int;
			for (var i:int=0, l:int=_tt.length; i<l; ++i){
				rowIndex = i*(divArr.length-1);
				//10 cols, i is col, j is row
				if(rowIndex > (txtHolder.numChildren-1)) {
					var txt:TextField;
					for(var j:int=0,ll:int=divArr.length-1;j<ll;++j){
						txt = new TextField(divArr[j+1] - divArr[j] - 24,32,"");
						txt.format.setTo("Fira Sans Semi-Bold 13", 13, 0xD8D8D8,headingAligns[j]);
						txt.x = divArr[j] + 12;
						txt.y = i*20;
						txt.batchable = true;
						txt.touchable = false;
						txtHolder.addChild(txt);
					}
				}
				
				(txtHolder.getChildAt(rowIndex+0) as TextField).text = (_tt[i].tier > 0) ? _tt[i].tier.toString() : "";
				(txtHolder.getChildAt(rowIndex+1) as TextField).text = _tt[i].url;
				(txtHolder.getChildAt(rowIndex+2) as TextField).text = _tt[i].status;
				(txtHolder.getChildAt(rowIndex+3) as TextField).text = _tt[i].numPeers.toString();
				(txtHolder.getChildAt(rowIndex+4) as TextField).text = _tt[i].message;
			}
			
			if(txtHolder.numChildren/(divArr.length-1) > _tt.length){
				for(var k:int=txtHolder.numChildren-1;k > (_tt.length*(divArr.length)-1);k--)
					txtHolder.removeChildAt(k);
			}
			trackersList.fullHeight = (_tt.length*20)+12;
			trackersList.recalculate();
		}
			
			
	}
}