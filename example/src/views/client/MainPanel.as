package views.client {
	import com.tuarua.torrent.PeerInfo;
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
	import starling.display.Quad;
	import starling.display.QuadBatch;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.utils.HAlign;
	
	import views.client.RightClickMenu;
	public class MainPanel extends Sprite {
		private var bgMask:Quad = new Quad(1920,1046,0x111414);
		private var bg:QuadBatch = new QuadBatch();
		private var holder:Sprite = new Sprite();
		private var headingHolder:Sprite = new Sprite();
		private var w:int = 1200;
		private var itmHolder:Sprite = new Sprite();
		private var menuItemHolder:Sprite = new Sprite();
		private var menuItemsVec:Vector.<MenuItem> = new Vector.<MenuItem>();
		private var panelsVec:Vector.<Sprite> = new Vector.<Sprite>();
		private var selectedId:String;
		private var _selectedMenu:int = 0;
		
		private var rightClickMenus:Dictionary = new Dictionary();
		private var rightClickMenusData:Dictionary = new Dictionary();
		private var itemSpriteDictionary:Dictionary = new Dictionary();
		
		///private var rightClickMenu:RightClickMenu;

		//private var menuDataList:Vector.<Object>;
		private var hasRightClickPriority:Boolean = false;;
		
		public function MainPanel() {
			super();
			
			
			
			//pause / resume
			//delete
			//sequential
			
			//move to top
			//move up
			//move down
			//move to bottom
			
			//copy magnet
			
			
			
			
			bg.touchable = false;
			bg.addQuad(new Quad(w,1,0x0D1012));
			var lineLeft:Quad = new Quad(1,153,0x0D1012);
			var lineRight:Quad = new Quad(1,153,0x0D1012);
			var lineBot:Quad = new Quad(w,1,0x0D1012);
			var middle:Quad = new Quad(w-2,153,0x0D1012);
			middle.x = middle.y = lineRight.y = lineLeft.y = 1;
			middle.alpha = 0.92;
			
			lineRight.x = w-1;
			lineBot.y = 154;
			bg.touchable = false;
			bg.addQuad(lineLeft);
			bg.addQuad(lineRight);
			bg.addQuad(lineBot);
			bg.addQuad(middle);
			
			//the menu bar
			//#080808
			var mb:Quad = new Quad(w-4,28,0x080808);
			mb.y = mb.x = 2;
			
			bg.addQuad(mb);
			
			var divArr:Array = new Array(0,36,320, 410,474,600,665,724,825,925,1015);
			var headingArr:Array = new Array("#", "Name", "Size","Done","Status","Seeds","Peers","Down Speed","Up Speed","ETA","");
			var headingAligns:Array = new Array(HAlign.CENTER,HAlign.LEFT,HAlign.RIGHT,HAlign.RIGHT,HAlign.LEFT,HAlign.RIGHT,HAlign.RIGHT,HAlign.RIGHT,HAlign.RIGHT,HAlign.RIGHT,HAlign.RIGHT);
			var divider:Quad = new Quad(1,28,0x202020);
			divider.y = 2;
			var heading:TextField;
			for (var i:int=0, l:int=divArr.length; i<l; ++i){
				divider.x = divArr[i];
				if(i > 0) bg.addQuad(divider);
				if(i < l) {
					heading = new TextField(divArr[i+1] - divArr[i] - 24,32,headingArr[i], "Fira Sans Regular 13", 13, 0xD8D8D8);
					heading.hAlign = headingAligns[i];
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
			bg.addQuad(bmiddle);
			bg.addQuad(blineLeft);
			bg.addQuad(blineRight);
			bg.addQuad(blineBot);
			
			itmHolder.y = 25;
			
			
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
			
			holder.addChild(itmHolder);
			holder.addChild(headingHolder);
			holder.addChild(menuItemHolder);
			
			addChild(holder);
			
			Starling.current.nativeStage.addEventListener(flash.events.MouseEvent.RIGHT_CLICK, onRightClick);
		}
		
		public function addPriorityToRightClick(value:Boolean):void {
			if(value && !hasRightClickPriority){
				for (var key:* in rightClickMenusData){
					(rightClickMenusData[key] as Vector.<Object>).push({value:3,label:"Move to top"});
					(rightClickMenusData[key] as Vector.<Object>).push({value:4,label:"Move up"});
					(rightClickMenusData[key] as Vector.<Object>).push({value:5,label:"Move down"});
					(rightClickMenusData[key] as Vector.<Object>).push({value:6,label:"Move to bottom"});
					(rightClickMenus[key] as RightClickMenu).update(rightClickMenusData[key] as Vector.<Object>);
				}
				hasRightClickPriority = true;
			}else if(!value && hasRightClickPriority){
				//remove them
				hasRightClickPriority = false;
			}
				
		}
		
		public function addRightClickMenu(_id:String,_menuDataList:Vector.<Object>):void {
			var rightClickMenu:RightClickMenu;
			rightClickMenu = new RightClickMenu(_id,200,_menuDataList);
			rightClickMenu.visible = false;
			
			rightClickMenus[_id] = rightClickMenu;
			rightClickMenusData[_id] = _menuDataList;
			addChild(rightClickMenu);
		}
		
		public function updateRightClickMenu(_id:String,index:int,label:String,value:int):void {
			var vec:Vector.<Object> = rightClickMenusData[_id] as Vector.<Object>;
			vec[index].value = value;
			vec[index].label = label;
			(rightClickMenus[_id] as RightClickMenu).update(vec);
		}
		
		protected function onRightClick(event:MouseEvent):void {
			var rightCP:Point = holder.globalToLocal(new Point(event.stageX,event.stageY));
			var mousePoint:Point = new Point(rightCP.x,rightCP.y - 30);
			var openMenu:Boolean = false;
			var ti:TorrentItem;
			for (var i:int=0, l:int=itmHolder.numChildren; i<l; ++i){
				ti = itmHolder.getChildAt(i) as TorrentItem;
				if(mousePoint.y > ti.y && mousePoint.y < (ti.y+20)){
					selectedId = ti.id;
					itemSelect();
					rightClickMenus[ti.id].visible = true;
					rightClickMenus[ti.id].x = event.stageX;
					rightClickMenus[ti.id].y = event.stageY-60;
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
			
			updatePieces();
			updateStatus();
			updatePeers();
			updateTrackers();
			updateFiles();
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
			if(selectedId)
				(panelsVec[0] as InfoPanel).updateStatus(TorrentsLibrary.status[selectedId]);
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
				if (tt) (panelsVec[1] as TrackersPanel).update(tt.trackersInfo);
			}
			
		}
	}
}