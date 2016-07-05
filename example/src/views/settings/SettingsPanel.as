package views.settings {
	import events.InteractionEvent;
	
	import starling.display.Quad;
	import starling.display.Sprite;
	import views.client.MenuItem;
	import starling.display.MeshBatch;

	public class SettingsPanel extends Sprite {
		private var bgMask:Quad = new Quad(1920,1046,0x111414);
		private var bg:MeshBatch = new MeshBatch();
		private var holder:Sprite = new Sprite();
		private var w:int = 1200;
		private var menuItemHolder:Sprite = new Sprite();
		private var menuItemsVec:Vector.<MenuItem> = new Vector.<MenuItem>();
		private var panelsVec:Vector.<Sprite> = new Vector.<Sprite>();
		private var selectedId:String;
		private var _selectedMenu:int = 0;
		
		public function SettingsPanel() {
			super();
			bg.touchable = false;
			
			var bmiddle:Quad = new Quad(w-2,508,0x0D1012);
			var blineLeft:Quad = new Quad(1,508,0x0D1012);
			var blineRight:Quad = new Quad(1,508,0x0D1012);
			var blineBot:Quad = new Quad(w,1,0x0D1012);
			bmiddle.alpha = 0.92;
			bmiddle.x = 1;
			blineRight.x = w-1;
			
			blineRight.y = bmiddle.y = 0;
			blineLeft.y = 0;
			blineBot.y = 508;
			bg.addMesh(bmiddle);
			bg.addMesh(blineLeft);
			bg.addMesh(blineRight);
			bg.addMesh(blineBot);
			
			addChild(bgMask);
			
			
			menuItemsVec.push(new MenuItem("Downloads",0,true));
			menuItemsVec.push(new MenuItem("Connection",1));
			menuItemsVec.push(new MenuItem("Speed",2));
			menuItemsVec.push(new MenuItem("Bittorrent",3));
			menuItemsVec.push(new MenuItem("Advanced",4));
			
			for (var ii:int=0, ll:int=menuItemsVec.length; ii<ll; ++ii){
				menuItemsVec[ii].x = (ii * 122);
				menuItemsVec[ii].addEventListener(InteractionEvent.ON_MENU_ITEM_MENU,onMenuSelect);
				menuItemHolder.addChild(menuItemsVec[ii]);
			}
			
			menuItemHolder.y = -27;
			holder.x = 40;
			holder.y = 110-34;
			
			panelsVec.push(new DownloadsPanel());
			panelsVec.push(new ConnectionPanel());
			panelsVec.push(new SpeedPanel());
			panelsVec.push(new BitTorrentPanel());
			panelsVec.push(new AdvancedPanel());
			
			holder.addChild(bg);
			for (var j:int=0, l3:int=panelsVec.length; j<l3; ++j){
				panelsVec[j].x = 50;
				panelsVec[j].y = 50;
				panelsVec[j].visible = (j==0);
				holder.addChild(panelsVec[j]);
			}
			
			holder.addChild(menuItemHolder);
			addChild(holder);
		}
		public function resize(_screenW:int,_screenH:int):void {
			holder.x = (_screenW - w)/2;
			holder.y = 110-34;
			positionAllFields();
		}
		protected function onMenuSelect(event:InteractionEvent):void {
			_selectedMenu = event.params.type;
			var mi:MenuItem;
			for (var ii:int=0, ll:int=menuItemsVec.length; ii<ll; ++ii){
				mi = menuItemsVec[ii];
				mi.setSelected((event.params.type == ii));
				panelsVec[ii].visible = (event.params.type == ii);
				panelsVec[ii].showFields(event.params.type == ii);
			}
		}
		public function showMask(_b:Boolean):void {
			bgMask.visible = _b;
		}
		public function hideAllFields():void {
			for (var ii:int=0, ll:int=menuItemsVec.length; ii<ll; ++ii)
				panelsVec[ii].showFields(false);
		}
		public function clear():void {
			hideAllFields();
		}
		public function positionAllFields():void {
			for (var ii:int=0, ll:int=menuItemsVec.length; ii<ll; ++ii)
				panelsVec[ii].positionAllFields();
		}
		public function showDefault():void {
			panelsVec[_selectedMenu].showFields(true);
		}
	}
}