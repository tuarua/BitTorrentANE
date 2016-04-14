package views.client {
	import com.tuarua.torrent.TorrentFileMeta;
	import com.tuarua.torrent.TorrentSettings;
	
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.QuadBatch;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.utils.HAlign;
	
	import utils.TextUtils;
	
	public class FilesPanel extends Sprite {
		private static var divArr:Array = new Array(0,800,900,1000,1200);
		private static var headingArr:Array = new Array("Name", "Size", "Progress","Priority","");
		private static var headingAligns:Array = new Array(HAlign.LEFT,HAlign.LEFT,HAlign.CENTER,HAlign.LEFT,HAlign.LEFT);
		private var bg:QuadBatch = new QuadBatch();
		private var headingHolder:Sprite = new Sprite();
		private var itmHolder:Sprite = new Sprite();
		private var txtHolder:Sprite = new Sprite();
		private var imgHolder:Sprite = new Sprite();
		private var w:int = 1200;
		private var h:int = 255;
		public function FilesPanel() {
			super();
			
			var divider:Quad = new Quad(1,28,0x202020);
			divider.y = 2;
			var heading:TextField;
			for (var i:int=0, l:int=divArr.length; i<l; ++i){
				divider.x = divArr[i];
				if(i > 0) bg.addQuad(divider);
				heading = new TextField(divArr[i+1] - divArr[i] - 24,32,headingArr[i], "Fira Sans Regular 13", 13, 0xD8D8D8);
				heading.hAlign = headingAligns[i];
				heading.x = divArr[i] + 12;
				heading.batchable = true;
				heading.touchable = false;
				headingHolder.addChild(heading);
			}
			bg.y = 10;
			headingHolder.y = 10;
			itmHolder.y = 40;
			itmHolder.clipRect = new Rectangle(0,0,w,h);
			//itmHolder.mask = new Quad(w,h);
			addChild(bg);
			addChild(headingHolder);
			itmHolder.addChild(txtHolder);
			addChild(itmHolder);
		}
		public function populate(_files:Vector.<TorrentFileMeta>):void {
			var k:int = txtHolder.numChildren;
			while(k--)
				txtHolder.removeChildAt(k);
			
			k = itmHolder.numChildren;
			while(k--)
				itmHolder.removeChildAt(k);
			
			k = imgHolder.numChildren;
			while(k--)
				imgHolder.removeChildAt(k);
			
			var rowIndex:int;
			var indent:int = 0;
			var cnt:int = 0;
			var folder:String="";
			var folders:Array = new Array();
			for (var i:int=0, l:int=_files.length; i<l; ++i){
				rowIndex = cnt*(divArr.length-1);

				var txt:TextField;
				var img:Image;
				var arrFolder:Array = _files[i].path.split("\\");
				indent = arrFolder.length - 1;
				
				if(arrFolder.length > 1){
					folder = arrFolder[arrFolder.length-2];
					if(folders.indexOf(folder) == -1){
						folders.push(folder);
						for(var z:int=0,l3:int=divArr.length-1;z<l3;++z){
							txt = new TextField(divArr[z+1] - divArr[z] - 24,32,"", "Fira Sans Regular 13", 13, 0xD8D8D8);
							txt.hAlign = headingAligns[z];
							txt.x = divArr[z] + 12;
							
							txt.y = cnt*22;
							txt.batchable = true;
							txt.touchable = false;
							if(z == 0) {
								txt.x += ((indent*50) - 20);
								img = new Image(Assets.getAtlas().getTexture("folder-button-hover"));
								img.x = txt.x - 28;
								img.y = txt.y + 6;
								imgHolder.addChild(img);
							}
							txtHolder.addChild(txt);
							
							
						}
						
						(txtHolder.getChildAt(rowIndex+0) as TextField).text = folder;
						(txtHolder.getChildAt(rowIndex+1) as TextField).text = "";
						(txtHolder.getChildAt(rowIndex+2) as TextField).text = "";
						(txtHolder.getChildAt(rowIndex+3) as TextField).text = "";
						
						cnt++;
						rowIndex = cnt*(divArr.length-1);
					}
				}
				

				for(var j:int=0,ll:int=divArr.length-1;j<ll;++j){
					txt = new TextField(divArr[j+1] - divArr[j] - 24,32,"", "Fira Sans Regular 13", 13, 0xD8D8D8);
					txt.hAlign = headingAligns[j];
					txt.x = divArr[j] + 12;
					if(j == 0) txt.x += ( ((indent+1)*50) - 20 );
					txt.y = cnt*22;
					if(j == 0) {
						img = new Image(Assets.getAtlas().getTexture("file"));
						img.x = txt.x - 20;
						img.y = txt.y + 6;
						imgHolder.addChild(img);
					}
						
					txt.batchable = true;
					txt.touchable = false;
					txtHolder.addChild(txt);
				}
				
				(txtHolder.getChildAt(rowIndex+0) as TextField).text = _files[i].name;
				(txtHolder.getChildAt(rowIndex+1) as TextField).text = TextUtils.bytesToString(_files[i].size);
				cnt++;
				
			}

			itmHolder.addChild(txtHolder);
			itmHolder.addChild(imgHolder);
			
			addChild(itmHolder);
			
		}
		
		public function clear():void {
			var k:int = txtHolder.numChildren;
			while(k--)
				txtHolder.removeChildAt(k);
			k = itmHolder.numChildren;
			while(k--)
				itmHolder.removeChildAt(k);
			k = imgHolder.numChildren;
			while(k--)
				imgHolder.removeChildAt(k);
		}
		
	}
}