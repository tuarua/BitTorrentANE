package views.client.files {
	import com.tuarua.torrent.TorrentFileMeta;
	import com.tuarua.torrent.TorrentStatus;
	import com.tuarua.torrent.constants.FilePriority;
	
	import flash.events.MouseEvent;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MeshBatch;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.utils.Align;
	
	import utils.TextUtils;
	
	import views.SrollableContent;
	import flash.geom.Point;
	import views.client.RightClickMenu;
	
	public class FilesPanel extends Sprite {
		private static var divArr:Array = new Array(0,800,900,1000,1200);
		private static var headingArr:Array = new Array("Name", "Size", "Progress","Priority","");
		private static var headingAligns:Array = new Array(Align.LEFT,Align.LEFT,Align.CENTER,Align.LEFT,Align.LEFT);
		private var bg:MeshBatch = new MeshBatch();
		private var headingHolder:Sprite = new Sprite();
		private var txtHolder:Sprite = new Sprite();
		private var imgHolder:Sprite = new Sprite();
		private var holder:Sprite = new Sprite();
		
		private var fileList:SrollableContent;
		private var _files:Vector.<TorrentFileMeta>;
		private var fileRowIndexes:Array = new Array();
		private var _isFinished:Boolean = false;
		
		private var highlight:Quad = new Quad(1180,20,0xCC8D1E);
		private var rightClickMenu:RightClickMenu;
		
		public function FilesPanel() {
			super();
			
			var divider:Quad = new Quad(1,28,0x202020);
			divider.y = 2;
			var heading:TextField;
			for (var i:int=0, l:int=divArr.length; i<l; ++i){
				divider.x = divArr[i];
				if(i > 0) bg.addMesh(divider);
				heading = new TextField(divArr[i+1] - divArr[i] - 24,32,headingArr[i]);
				heading.format.setTo("Fira Sans Semi-Bold 13",13,0xD8D8D8,headingAligns[i]);
				heading.x = divArr[i] + 12;
				heading.batchable = true;
				heading.touchable = false;
				headingHolder.addChild(heading);
			}
			bg.y = 10;
			headingHolder.y = 10;
			
			fileList = new SrollableContent(1200,255,holder);
			fileList.y = 40;
			addChild(bg);
			addChild(headingHolder);
			
			addChild(fileList);
			
			//Starling.current.nativeStage.addEventListener(flash.events.MouseEvent.RIGHT_CLICK, onRightClick);
		}
		
		/*
		protected function onRightClick(event:MouseEvent):void {
			var mousePointCheck:Point = this.globalToLocal(new Point(Starling.current.nativeStage.mouseX,Starling.current.nativeStage.mouseY));
			
			//trace(mousePointCheck);
			if(this.visible && mousePointCheck.x > 0 && mousePointCheck.y > 0){
				event.stopImmediatePropagation();
				event.stopPropagation();
				
				
				var rightCP:Point = holder.globalToLocal(new Point(event.stageX,event.stageY));
				var mousePoint:Point = new Point(rightCP.x,rightCP.y - 30);
				
				//trace(rightCP);
				//trace(mousePoint);
				
				if(rightClickMenu){
					if(!this.contains(rightClickMenu))
						addChild(rightClickMenu);
					rightClickMenu.dispose();
					rightClickMenu = null;
				}
				
				for (var i:int=0, l:int=holder.numChildren; i<l; ++i){
					
				}
				
			}
		}
		*/
		public function populate(files:Vector.<TorrentFileMeta>):void {
			fileRowIndexes = new Array()
			_files = files;
			clear();
			
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
							txt = new TextField(divArr[z+1] - divArr[z] - 24,32,"");
							txt.format.setTo("Fira Sans Semi-Bold 13",13,0xD8D8D8, headingAligns[z]);
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
					txt = new TextField(divArr[j+1] - divArr[j] - 24,32,"");
					txt.format.setTo("Fira Sans Semi-Bold 13",13,0xD8D8D8, headingAligns[j]);
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
				fileRowIndexes.push(cnt);
				cnt++;
				
			}

			holder.addChild(txtHolder);
			holder.addChild(imgHolder);

			fileList.fullHeight = (cnt*22)+12;
			fileList.init();
		}
		
		public function finishStatus():void {
			_isFinished = true;
			var cnt:int=0;
			var rowCnt:int=0
			var rowIndex:int;
			for (var i:int=0, l:int=_files.length; i<l; ++i){
				rowIndex = fileRowIndexes[rowCnt]*(divArr.length-1);
				(txtHolder.getChildAt(rowIndex+2) as TextField).text = "100%";
				rowCnt++;
			}
		}
		public function updateStatus(_ts:TorrentStatus):void {
			_isFinished = false;
			if(_files && _ts && _ts.fileProgress && _ts.fileProgress.length == _files.length){
				var cnt:int=0;
				var rowCnt:int=0
				var rowIndex:int;
				for (var i:int=0, l:int=_files.length; i<l; ++i){
					rowIndex = fileRowIndexes[rowCnt]*(divArr.length-1);
					(txtHolder.getChildAt(rowIndex+2) as TextField).text = ((_ts.fileProgress[i]/_files[i].size)*100).toFixed(1)+"%";
					(txtHolder.getChildAt(rowIndex+3) as TextField).text = FilePriority.getValue(_ts.filePriority[i]);
					rowCnt++;
				}
			}
		}
		
		
		public function clear():void {
			fileList.reset();
			var k:int = txtHolder.numChildren;
			while(k--)
				txtHolder.removeChildAt(k);
			k = imgHolder.numChildren;
			while(k--)
				imgHolder.removeChildAt(k);
		}

		public function destroy():void {
			fileList.reset();
			var k:int = txtHolder.numChildren;
			while(k--)
				txtHolder.removeChildAt(k);
			txtHolder.dispose();
			k = imgHolder.numChildren;
			while(k--)
				imgHolder.removeChildAt(k);
			imgHolder.dispose();
		}
		
		public function get isFinished():Boolean {
			return _isFinished;
		}
	}
}