package views.client {
	import com.tuarua.torrent.TorrentMeta;
	import com.tuarua.torrent.TorrentPeers;
	import com.tuarua.torrent.TorrentPieces;
	import com.tuarua.torrent.TorrentStatus;
	import com.tuarua.torrent.TorrentTrackers;
	import com.tuarua.torrent.TorrentsLibrary;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import events.InteractionEvent;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.utils.Align;
	
	import views.SrollableContent;
	import views.client.RightClickMenu;
	import starling.display.MeshBatch;

	public class MainPanel extends Sprite {
		private var bgMask:Quad = new Quad(1920,1046,0x111414);
		private var bg:MeshBatch = new MeshBatch();
		private var holder:Sprite = new Sprite();
		private var headingHolder:Sprite = new Sprite();
		private var w:int = 1200;
		private var itmHolder:Sprite = new Sprite();
		private var menuItemHolder:Sprite = new Sprite();
		private var menuItemsVec:Vector.<MenuItem> = new Vector.<MenuItem>();
		private var panelsVec:Vector.<Sprite> = new Vector.<Sprite>();
		private var magnetButtonTexture:Texture = Assets.getAtlas().getTexture("add-magnet");
		private var addButtonTexture:Texture = Assets.getAtlas().getTexture("add-torrent");
		private var powerOnButtonTexture:Texture = Assets.getAtlas().getTexture("power-on");
		private var powerOffButtonTexture:Texture = Assets.getAtlas().getTexture("power-off");
		private var createButtonTexture:Texture = Assets.getAtlas().getTexture("create-torrent");
		private var magnetButton:Image = new Image(magnetButtonTexture);
		private var addButton:Image = new Image(addButtonTexture);
		private var powerButton:Image = new Image(powerOnButtonTexture);
		private var createButton:Image = new Image(createButtonTexture);
		private var sampleMagnet:String = "magnet:?xt=urn:btih:f3bf22593bd8c5b318c9fa41c7d507215ea67adc&dn=Cosmos%20Laundromat%20-%20Blender-short-movie&tr=udp%3a%2f%2fopen.demonii.com%3a1337%2fannounce&tr=udp%3a%2f%2ftracker.publicbt.com%3a80%2fannounce&tr=udp%3a%2f%2ftracker.openbittorrent.com%3a80%2fannounce&tr=udp%3a%2f%2ftracker.istole.it%3a80%2fannounce&tr=udp%3a%2f%2ftorrent.gresille.org%3a80%2fannounce&tr=udp%3a%2f%2ftracker.opentrackr.org%3a1337%2fannounce&tr=http%3a%2f%2ftracker.aletorrenty.pl%3a2710%2fannounce&tr=http%3a%2f%2fopen.acgtracker.com%3a1096%2fannounce&tr=udp%3a%2f%2f9.rarbg.me%3a2710%2fannounce";
		private var magnetScreen:MagnetScreen = new MagnetScreen(sampleMagnet);
		public var createTorrentScreen:CreateTorrentScreen = new CreateTorrentScreen();
		private var selectedId:String;
		private var _selectedMenu:int = 0;
		private var rightClickMenus:Dictionary = new Dictionary();
		private var rightClickMenusData:Dictionary = new Dictionary(true);
		private var itemSpriteDictionary:Dictionary = new Dictionary();
		private var hasRightClickPriority:Boolean = false;
		private var isPowerOn:Boolean = true;
		
		private var itemsList:SrollableContent;
		
		public function MainPanel() {
			super();
			
			bg.touchable = false;
			bg.addMesh(new Quad(w,1,0x0D1012));
			var lineLeft:Quad = new Quad(1,153,0x0D1012);
			var lineRight:Quad = new Quad(1,153,0x0D1012);
			var lineBot:Quad = new Quad(w,1,0x0D1012);
			var middle:Quad = new Quad(w-2,153,0x0D1012);
			middle.x = middle.y = lineRight.y = lineLeft.y = 1;
			bg.alpha = 0.92;
			
			lineRight.x = w-1;
			lineBot.y = 154;
			
			bg.addMesh(lineLeft);
			bg.addMesh(lineRight);
			bg.addMesh(lineBot);
			bg.addMesh(middle);
			
			//the menu bar
			//#080808
			var mb:Quad = new Quad(w-4,28,0x080808);
			mb.y = mb.x = 2;
			
			bg.addMesh(mb);
			
			var divArr:Array = new Array(0,36,320, 410,474,600,665,724,825,925,1015);
			var headingArr:Array = new Array("#", "Name", "Size","Done","Status","Seeds","Peers","Down Speed","Up Speed","ETA","");
			var headingAligns:Array = new Array(Align.CENTER,Align.LEFT,Align.RIGHT,Align.RIGHT,Align.LEFT,Align.RIGHT,Align.RIGHT,Align.RIGHT,Align.RIGHT,Align.RIGHT,Align.RIGHT);
			var divider:Quad = new Quad(1,28,0x202020);
			divider.y = 2;
			var heading:TextField;
			for (var i:int=0, l:int=divArr.length; i<l; ++i){
				divider.x = divArr[i];
				if(i > 0) bg.addMesh(divider);
				if(i < l) {
					heading = new TextField(divArr[i+1] - divArr[i] - 24,32,headingArr[i]);
					heading.format.setTo("Fira Sans Semi-Bold 13",13,0xD8D8D8,headingAligns[i]);
					heading.x = divArr[i] + 12;
					heading.batchable = true;
					heading.touchable = false;
					headingHolder.addChild(heading);
					
				}
			}
			
			var bmiddle:Quad = new Quad(w-2,308,0x0D1012);
			var blineLeft:Quad = new Quad(1,308,0x0D1012);
			var blineRight:Quad = new Quad(1,308,0x0D1012);
			var blineBot:Quad = new Quad(w,1,0x0D1012);
			bmiddle.alpha = 0.92;
			bmiddle.x = 1;
			blineRight.x = w-1;
			
			blineRight.y = bmiddle.y = 200;
			blineLeft.y = 200;
			blineBot.y = 508;
			bg.addMesh(bmiddle);
			bg.addMesh(blineLeft);
			bg.addMesh(blineRight);
			bg.addMesh(blineBot);
			
			itemsList = new SrollableContent(1200,115,itmHolder);
			//itemsList.y = 40;
			//itmHolder.y = 25;
			
			
			itemsList.y = 30;
			
			
			menuItemsVec.push(new MenuItem("Info",0,true));
			menuItemsVec.push(new MenuItem("Trackers",1));
			menuItemsVec.push(new MenuItem("Peers",2));
			menuItemsVec.push(new MenuItem("HTTP Sources",3));
			menuItemsVec.push(new MenuItem("Files",4));
			
			for (var ii:int=0, ll:int=menuItemsVec.length; ii<ll; ++ii){
				menuItemsVec[ii].x = (ii * 122);
				menuItemsVec[ii].addEventListener(InteractionEvent.ON_MENU_ITEM_MENU,onMenuSelect);
				menuItemHolder.addChild(menuItemsVec[ii]);
			}
			
			menuItemHolder.y = 173;
			
			
			holder.x = 40;
			holder.y = 110-34;
			
			panelsVec.push(new InfoPanel());
			panelsVec.push(new TrackersPanel());
			panelsVec.push(new PeersPanel());
			panelsVec.push(new HttpPanel());
			panelsVec.push(new FilesPanel());
			
			addChild(bgMask);
			holder.addChild(bg);
			
			for (var j:int=0, l3:int=panelsVec.length; j<l3; ++j){
				panelsVec[j].y = 200;
				panelsVec[j].visible = (j==0);
				holder.addChild(panelsVec[j]);
			}
			
			addButton.x = 0;
			
			magnetButton.x = 62;
			createButton.x = 124;
			powerButton.x = 1200 - 122;
			createButton.y = powerButton.y = addButton.y = magnetButton.y = -38;
			
			magnetButton.addEventListener(TouchEvent.TOUCH,onMagnetAdd);
			addButton.addEventListener(TouchEvent.TOUCH,onTorrentAdd);
			powerButton.addEventListener(TouchEvent.TOUCH,onPowerClick);
			createButton.addEventListener(TouchEvent.TOUCH,onCreateClick);
			
			itemsList.fullHeight = 10;
			itemsList.init();
			
			holder.addChild(itemsList);
			holder.addChild(headingHolder);
			holder.addChild(menuItemHolder);
			holder.addChild(addButton);
			holder.addChild(magnetButton);
			holder.addChild(createButton);
			holder.addChild(powerButton);
			
			magnetScreen.x = 300;
			magnetScreen.y = 90;
			magnetScreen.showFields(false);
			magnetScreen.visible = false;
			
			createTorrentScreen.x = 300;
			createTorrentScreen.y = 40;
			createTorrentScreen.showFields(false);
			createTorrentScreen.visible = false;
			
			holder.addChild(magnetScreen);
			holder.addChild(createTorrentScreen);
			
			addChild(holder);
			
			Starling.current.nativeStage.addEventListener(flash.events.MouseEvent.RIGHT_CLICK, onRightClick);
		}
		
		private function onMagnetAdd(event:TouchEvent):void {
			var touch:Touch = event.getTouch(magnetButton);
			if(touch != null && touch.phase == TouchPhase.ENDED)
				magnetScreen.show();
		}
		
		private function onCreateClick(event:TouchEvent):void {
			var touch:Touch = event.getTouch(createButton);
			if(touch != null && touch.phase == TouchPhase.ENDED)
				createTorrentScreen.show();
		}
		
		private function onTorrentAdd(event:TouchEvent):void {
			var touch:Touch = event.getTouch(addButton);
			if(touch != null && touch.phase == TouchPhase.ENDED)
				this.dispatchEvent(new InteractionEvent(InteractionEvent.ON_TORRENT_ADD));
		}
		
		private function onPowerClick(event:TouchEvent):void {
			var touch:Touch = event.getTouch(powerButton);
			//trace(touch);
			if(touch != null && touch.phase == TouchPhase.ENDED){
				isPowerOn = !isPowerOn;
				powerButton.texture = (isPowerOn) ? powerOnButtonTexture : powerOffButtonTexture;
				this.dispatchEvent(new InteractionEvent(InteractionEvent.ON_POWER_CLICK,{on:isPowerOn}));
			}
		}
		public function addPriorityToRightClick(value:Boolean):void {
			var tmpArr:Array;
			if(value && !hasRightClickPriority){
				for (var key:String in rightClickMenusData){
					tmpArr = new Array();
					var obj:Object;
					for each(var thing:Object in rightClickMenusData[key]){
						obj = new Object();
						obj.value = thing.value;
						obj.label = thing.label;
						tmpArr.push(obj);
					}
					tmpArr.push({value:3,label:"Move to top"});
					tmpArr.push({value:4,label:"Move up"});
					tmpArr.push({value:5,label:"Move down"});
					tmpArr.push({value:6,label:"Move to bottom"});
					rightClickMenusData[key] = tmpArr;
					(rightClickMenus[key] as RightClickMenu).update(rightClickMenusData[key]);
				}
				hasRightClickPriority = true;
			}else if(!value && hasRightClickPriority){
				hasRightClickPriority = false;
			}
				
		}
		
		public function addRightClickMenu(_id:String,_menuDataList:Array):void {
			var rightClickMenu:RightClickMenu;
			rightClickMenu = new RightClickMenu(_id,200,_menuDataList);
			rightClickMenu.visible = false;
			
			rightClickMenus[_id] = rightClickMenu;
			rightClickMenusData[_id] = _menuDataList;
			addChild(rightClickMenu);
		}
		
		public function updateRightClickMenu(_id:String,index:int,label:String,value:int):void {
			var vec:Array = rightClickMenusData[_id];
			vec[index].value = value;
			vec[index].label = label;
			(rightClickMenus[_id] as RightClickMenu).update(vec);
		}
		
		protected function onRightClick(event:MouseEvent):void {
			event.stopImmediatePropagation();
			event.stopPropagation();
			
			var rightCP:Point = holder.globalToLocal(new Point(event.stageX,event.stageY));
			var mousePoint:Point = new Point(rightCP.x,rightCP.y - 30);
			var openMenu:Boolean = false;
			var ti:TorrentItem;
			for (var i:int=0, l:int=itmHolder.numChildren; i<l; ++i){
				ti = itmHolder.getChildAt(i) as TorrentItem;
				
				if(mousePoint.y > (ti.y+itmHolder.y) && mousePoint.y < (ti.y+20+itmHolder.y)){//allow for the scrolling content
					if(selectedId != ti.id){
						selectedId = ti.id;
						itemSelect();
					}
					rightClickMenus[ti.id].visible = true;
					rightClickMenus[ti.id].x = event.stageX;
					rightClickMenus[ti.id].y = event.stageY-30;
					rightClickMenus[ti.id].open();
				}else{
					rightClickMenus[ti.id].close();
				}
				
			}	
			
			
		}
		public function resize(_screenW:int,_screenH:int):void {
			holder.x = (_screenW - w)/2;
			holder.y = 110-34;
		}
		
		public function get selectedMenu():int {
			return _selectedMenu;
		}

		public function showMask(_b:Boolean):void {
			bgMask.visible = _b;
		}
		protected function onMenuSelect(event:InteractionEvent):void {
			_selectedMenu = event.params.type;
			if(_selectedMenu == 2)
				(panelsVec[2] as PeersPanel).destroy();
			
			var mi:MenuItem;
			for (var ii:int=0, ll:int=menuItemsVec.length; ii<ll; ++ii){
				mi = menuItemsVec[ii];
				mi.setSelected((event.params.type == ii));
				panelsVec[ii].visible = (event.params.type == ii);
			}
		}
		protected function onItemSelect(event:InteractionEvent):void {
			selectedId = event.params.id;
			itemSelect();
		}
		
		private function itemSelect():void {
			var ti:TorrentItem;
			for (var i:int=0, l:int=itmHolder.numChildren; i<l; ++i){
				ti = itmHolder.getChildAt(i) as TorrentItem;
				ti.select(selectedId == ti.id);
			}
			
			(panelsVec[0] as InfoPanel).init(TorrentsLibrary.meta[selectedId]);
			(panelsVec[1] as TrackersPanel).destroy();
			(panelsVec[2] as PeersPanel).destroy();
			(panelsVec[4] as FilesPanel).destroy();
			
			updateFiles();
			updatePieces();
			updateStatus();
			updatePeers();
			updateTrackers();
			
			updateHTTPsources();
		}
		
		public function clear():void {
			(panelsVec[0] as InfoPanel).clear();
			(panelsVec[1] as TrackersPanel).clear();
			(panelsVec[2] as PeersPanel).clear();
			(panelsVec[3] as HttpPanel).clear();
			(panelsVec[4] as FilesPanel).clear();
			
			var ti:TorrentItem;
			for (var i:int=0, l:int=itmHolder.numChildren; i<l; ++i){
				ti = itmHolder.getChildAt(i) as TorrentItem;
				if(selectedId == ti.id){
					ti.dispose();
					itmHolder.removeChildAt(i);
					selectedId = "";
				}
			}
			itemsList.recalculate();
		}
		
		private function updateFiles():void {
			if(selectedId)
				(panelsVec[4] as FilesPanel).populate((TorrentsLibrary.meta[selectedId] as TorrentMeta).files);
		}
		
		private function updateHTTPsources():void {
			if(selectedId)
				(panelsVec[3] as HttpPanel).populate((TorrentsLibrary.meta[selectedId] as TorrentMeta).urlSeeds);
		}
		
		public function updatePieces():void {
			if(selectedId){
				if((TorrentsLibrary.status[selectedId] as TorrentStatus).isFinished)
					(panelsVec[0] as InfoPanel).finishPieces(TorrentsLibrary.pieces[selectedId] as TorrentPieces);
				else
					(panelsVec[0] as InfoPanel).updatePieces(TorrentsLibrary.pieces[selectedId] as TorrentPieces);
			}			
		}
		
		public function updateStatus():void {
			var itm:TorrentItem;
			var tm:TorrentMeta;
			var ts:TorrentStatus;
			var numNonSeeding:int=0;
			var arrSeeding:Array = new Array();
			for (var key:String in TorrentsLibrary.meta) {
				tm = TorrentsLibrary.meta[key] as TorrentMeta;
				ts = TorrentsLibrary.status[key];
				if(tm && ts){
					if(itemSpriteDictionary[key] == undefined){
						itm = new TorrentItem();
						itm.addEventListener(InteractionEvent.ON_TORRENT_ITEM_SELECT,onItemSelect);
						itmHolder.addChild(itm);
						itemSpriteDictionary[key] = itm;
					}else{
						itm = itemSpriteDictionary[key] as TorrentItem;
					}
					
					if(ts.queuePosition > -1) {
						numNonSeeding++;
						itm.y = ts.queuePosition*20;
					}else{
						arrSeeding.push(key);
					}
					itm.update(tm,ts,(selectedId == key));
				}
			}
			for (var i:int;i<arrSeeding.length;i++){
				itm = itemSpriteDictionary[arrSeeding[i]] as TorrentItem;
				itm.y = (i*20)+(numNonSeeding*20);
			}
			if(selectedId){
				if(!(TorrentsLibrary.status[selectedId] as TorrentStatus).isFinished)
					(panelsVec[0] as InfoPanel).updatePartialPieces((TorrentsLibrary.status[selectedId] as TorrentStatus).partialPieces);
				(panelsVec[0] as InfoPanel).updateStatus(TorrentsLibrary.status[selectedId]);
				if(selectedMenu == 4){
					if((TorrentsLibrary.status[selectedId] as TorrentStatus).isFinished){
						if((panelsVec[4] as FilesPanel) && !(panelsVec[4] as FilesPanel).isFinished)
							(panelsVec[4] as FilesPanel).finishStatus();
						
					}else{
						(panelsVec[4] as FilesPanel).updateStatus(TorrentsLibrary.status[selectedId]);
					}
				}
			}
			itemsList.fullHeight = (itmHolder.numChildren*20)+12;
			itemsList.recalculate();
		}
		
		private function sortChildrenByY(container:Sprite):void {
			var i:int;
			var childList:Array = new Array();
			i = container.numChildren;
			while(i--)
				childList[i] = container.getChildAt(i);
			childList.sortOn("y", Array.NUMERIC);
			i = container.numChildren;
			while(i--)
				if (childList[i] != container.getChildAt(i)){
					container.setChildIndex(childList[i], i);
			}
		}
		
		public function updatePeers():void {
			var d:Dictionary = TorrentsLibrary.peers;
			if(selectedId){
				var tp:TorrentPeers = TorrentsLibrary.peers[selectedId] as TorrentPeers;
				if(tp)
					(panelsVec[2] as PeersPanel).update(tp.peersInfo);
			}
		}
		
		public function updateTrackers():void {
			if(selectedId){
				var tt:TorrentTrackers = TorrentsLibrary.trackers[selectedId] as TorrentTrackers;
				var p:TrackersPanel;
				if (tt)
					(panelsVec[1] as TrackersPanel).update(tt.trackersInfo);
			}
			
		}
	}
}