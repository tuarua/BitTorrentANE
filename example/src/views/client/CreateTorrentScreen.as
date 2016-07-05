package views.client {
	import com.tuarua.torrent.TorrentTracker;
	import com.tuarua.torrent.TorrentWebSeed;
	import com.tuarua.torrent.events.TorrentInfoEvent;
	
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.text.TextFieldType;
	
	import events.FormEvent;
	import events.InteractionEvent;
	
	import starling.display.BlendMode;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import starling.textures.Texture;
	import starling.utils.Align;
	
	import utils.TextUtils;
	
	import views.CircularLoader;
	import views.forms.CheckBox;
	import views.forms.DropDown;
	import views.forms.Input;
	
	public class CreateTorrentScreen extends Sprite {
		private var txtHolder:Sprite = new Sprite();
		private var bg:Image;
		private var lbl:TextField;
		private var folderInput:Input;
		private var chooseFile:Image = new Image(Assets.getAtlas().getTexture("choose-bg"));
		private var selectedFile:File = new File();
		private var selectedFolder:File = new File();
		
		private var folderTexture:Texture;
		private var folderBtn:Button;
		private var trackerInput:Input;
		private var webInput:Input;
		private var commentInput:Input;
		private var size:DropDown;
		private var chkAuto:CheckBox;
		
		private var chkPrivate:CheckBox;
		private var chkSeed:CheckBox;
		
		private var okButton:Image = new Image(Assets.getAtlas().getTexture("ok-button"));
		private var cancelButton:Image = new Image(Assets.getAtlas().getTexture("cancel-button"));

		private var sizeDataList:Vector.<Object>;
		private var circularLoader:CircularLoader;
		public function CreateTorrentScreen() {
			super();
			//bgTexture = new Scale9Textures(Assets.getAtlas().getTexture("popmenu-bg"),new Rectangle(4,4,16,16));
			bg = new Image(Assets.getAtlas().getTexture("popmenu-bg"));
			bg.scale9Grid = new Rectangle(4,4,16,16);
			bg.blendMode = BlendMode.NONE;
			bg.touchable = false;
			bg.width = 600;
			bg.height = 500;
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.setTo("Fira Sans Semi-Bold 13",13);
			textFormat.horizontalAlign = Align.LEFT;
			textFormat.verticalAlign = Align.TOP;
			textFormat.color = 0xD8D8D8;
			
			var fileLbl:TextField = new TextField(120,32,"File or folder:");
			var trackerLbl:TextField = new TextField(120,32,"Tracker URLs:");
			var webLbl:TextField = new TextField(120,32,"Web seed URLs:");
			var commentLbl:TextField = new TextField(120,32,"Comment:");
			var sizeLbl:TextField = new TextField(120,32,"Piece size:");
			var autoLbl:TextField = new TextField(120,32,"Auto");
			var privateLbl:TextField = new TextField(120,32,"Private");
			var seedNowLbl:TextField = new TextField(120,32,"Seed now");
			
			
			seedNowLbl.format = privateLbl.format = autoLbl.format = sizeLbl.format = webLbl.format = commentLbl.format = trackerLbl.format = fileLbl.format = textFormat;
			seedNowLbl.touchable = privateLbl.touchable = autoLbl.touchable = sizeLbl.touchable = webLbl.touchable = commentLbl.touchable = trackerLbl.touchable = fileLbl.touchable = false;
			seedNowLbl.batchable = privateLbl.batchable = autoLbl.batchable = sizeLbl.batchable = webLbl.batchable = commentLbl.batchable = trackerLbl.batchable = fileLbl.batchable = true;

			commentLbl.x = fileLbl.x = webLbl.x = trackerLbl.x = 12;
			fileLbl.y = 20;
			trackerLbl.y = 50;
			webLbl.y = 140;
			commentLbl.y = 230;
			
			sizeLbl.x = 12;
			autoLbl.x = 263;
			privateLbl.x = 45;
			seedNowLbl.x = 45;
			
			autoLbl.y = sizeLbl.y = 323;
			privateLbl.y = 353;
			seedNowLbl.y = 383;
			
			folderInput = new Input(360,"");
			folderInput.type = TextFieldType.DYNAMIC;
			folderInput.x = 120;
			chooseFile.y = folderInput.y = 17;
			chooseFile.x = 120 + folderInput.width + 8;
			chooseFile.useHandCursor = false;
			chooseFile.addEventListener(TouchEvent.TOUCH,onChooseTouch);

			folderTexture = Assets.getAtlas().getTexture("folder-button-hover");
			folderBtn = new Button(folderTexture,"",folderTexture,folderTexture,folderTexture);
			folderBtn.x = chooseFile.x + 40;
			folderBtn.y = chooseFile.y + 5;
			folderBtn.useHandCursor = false;
			folderBtn.addEventListener(TouchEvent.TOUCH,onFolderTouch);
			
			selectedFolder.addEventListener(Event.SELECT, onFolderSelect); 
			selectedFile.addEventListener(Event.SELECT, onFileSelect); 
			
			trackerInput = new Input(360,"udp://tracker.openbittorrent.com:80/announce"+String.fromCharCode(13)+"udp://tracker.publicbt.com:80/announce"+String.fromCharCode(13)+"udp://tracker.istole.it:80/announce",80);
			trackerInput.multiline = true;
			trackerInput.addEventListener(FormEvent.CHANGE,onFormChange);
			trackerInput.x = 120;
			trackerInput.y = 50;
			
			webInput = new Input(360,"",80);
			webInput.multiline = true;
			webInput.addEventListener(FormEvent.CHANGE,onFormChange);
			webInput.x = 120;
			webInput.y = 140;
			
			commentInput = new Input(360,"",80);
			commentInput.multiline = true;
			commentInput.addEventListener(FormEvent.CHANGE,onFormChange);
			commentInput.x = 120;
			commentInput.y = 230;
			
			
			sizeDataList = new Vector.<Object>();
			sizeDataList.push({value:32,label:"32 KiB"});
			sizeDataList.push({value:64,label:"64 KiB"});
			sizeDataList.push({value:128,label:"128 KiB"});
			sizeDataList.push({value:256,label:"256 KiB"});
			sizeDataList.push({value:512,label:"512 KiB"});
			sizeDataList.push({value:1024,label:"1 MiB"});
			sizeDataList.push({value:2048,label:"2 MiB"});
			sizeDataList.push({value:4096,label:"4 MiB"});
			
			size = new DropDown(100,sizeDataList);
			size.selected = 4;
			size.addEventListener(FormEvent.CHANGE,onFormChange);
			size.x = 120;
			size.y = 320;
			
			size.enable(false);
			
			chkAuto = new CheckBox(true);
			chkAuto.addEventListener(FormEvent.CHANGE,onFormChange);
			chkAuto.x = 220;
			chkAuto.y = 309;
			
			chkPrivate = new CheckBox(false);
			chkPrivate.addEventListener(FormEvent.CHANGE,onFormChange);
			chkPrivate.x = 3;
			chkPrivate.y = 339;
			
			chkSeed = new CheckBox(true);
			chkSeed.addEventListener(FormEvent.CHANGE,onFormChange);
			chkSeed.x = 3;
			chkSeed.y = 369;
			
			okButton.x = (600 - 180)/2;
			cancelButton.x = okButton.x + 100;
			
			okButton.y = 442;
			cancelButton.y = 442;
			
			okButton.addEventListener(TouchEvent.TOUCH,onOK);
			cancelButton.addEventListener(TouchEvent.TOUCH,onCancel);
			
			circularLoader = new CircularLoader();
			circularLoader.x = 300;
			circularLoader.y = 200;
			circularLoader.visible = false;
			
			
			addChild(bg);
			
			txtHolder.addChild(fileLbl);
			txtHolder.addChild(trackerLbl);
			txtHolder.addChild(webLbl);
			txtHolder.addChild(commentLbl);
			txtHolder.addChild(sizeLbl);
			txtHolder.addChild(autoLbl);
			txtHolder.addChild(privateLbl);
			txtHolder.addChild(seedNowLbl);

		//	txtHolder.flatten();
			
			addChild(txtHolder);
			addChild(folderInput);
			addChild(chooseFile);
			addChild(folderBtn);
			addChild(trackerInput);
			addChild(webInput);
			addChild(commentInput);
			addChild(chkAuto);
			addChild(chkPrivate);
			addChild(chkSeed);
			
			addChild(okButton);
			addChild(cancelButton);
			
			addChild(size);
			
			
			addChild(circularLoader);
			
		}
		private function onFormChange(event:FormEvent):void {
			var test:int;
			switch(event.currentTarget){
				case chkAuto:
					size.enable(!event.params.value);
					break;
			}
		}
		private function onOK(event:TouchEvent):void {
			var touch:Touch = event.getTouch(okButton);
			if(touch != null && touch.phase == TouchPhase.ENDED){
				
				event.stopImmediatePropagation();
				event.stopPropagation();
				
				
				var obj:Object = new Object();
				obj.file = folderInput.text;
				
				var trackers:Vector.<TorrentTracker> = new Vector.<TorrentTracker>();
				var arrTrackers:Array = TextUtils.trim(trackerInput.text).split(String.fromCharCode(13));
				for (var i:int=0, l:int=arrTrackers.length; i<l; ++i)
					trackers.push(new TorrentTracker(arrTrackers[i]));
				obj.trackers = trackers;
				
				var webSeeds:Vector.<TorrentWebSeed> = new Vector.<TorrentWebSeed>();
				var arrWebSeeds:Array = TextUtils.trim(webInput.text).split(String.fromCharCode(13));
				for (var i2:int=0, l2:int=arrTrackers.length; i2<l2; ++i2)
					webSeeds.push(new TorrentWebSeed(arrWebSeeds[i2]));
				
				obj.webSeeds = webSeeds;
				obj.comments = commentInput.text;
				obj.size = (chkAuto.selected) ? 0 : sizeDataList[size.selected].value;
				obj.isPrivate = chkPrivate.selected;
				obj.seedNow = chkSeed.selected;
				
				showFields(false);
				txtHolder.visible = folderInput.visible = chooseFile.visible = folderBtn.visible = trackerInput.visible = webInput.visible = commentInput.visible = chkAuto.visible = chkPrivate.visible = chkSeed.visible = okButton.visible = cancelButton.visible = size.visible = false;
				
				circularLoader.visible = true;
				
				this.dispatchEvent(new InteractionEvent(InteractionEvent.ON_TORRRENT_CREATE,obj,true));
				
				
				
				//var outputFile:File = new File();
				//outputFile.addEventListener(Event.SELECT, onOutputSelected);
				
				//var savePath:String = avANE.saveAs(containerDataList[containerDrop.selected].value);
				
				//outputFile.browseForSave("Save torrent as...");
				
			}
		}
		
		public function onProgress(event:TorrentInfoEvent):void {
			circularLoader.update(event.params.progress/100);
		}
		public function onCreateComplete(event:TorrentInfoEvent):void {
			hide();
			txtHolder.visible = folderInput.visible = chooseFile.visible = folderBtn.visible = trackerInput.visible = webInput.visible = commentInput.visible = chkAuto.visible = chkPrivate.visible = chkSeed.visible = okButton.visible = cancelButton.visible = size.visible = true;
			circularLoader.visible = false;
			circularLoader.reset();
			if(event.params.seedNow)
				this.dispatchEvent(new InteractionEvent(InteractionEvent.ON_TORRRENT_SEED_NOW,{fileName:event.params.fileName},true))
		}
		
		private function onCancel(event:TouchEvent):void {
			var touch:Touch = event.getTouch(cancelButton);
			if(touch != null && touch.phase == TouchPhase.ENDED)
				hide();
		}
		private function onFolderSelect(event:Event):void {
			folderInput.text = selectedFolder.nativePath;
		}
		private function onFileSelect(event:Event):void {
			folderInput.text = selectedFile.nativePath;
		}
		private function onFolderTouch(event:TouchEvent):void {
			event.stopPropagation();
			var touch:Touch = event.getTouch(folderBtn, TouchPhase.ENDED);
			if(touch && touch.phase == TouchPhase.ENDED)
				selectedFolder.browseForDirectory("Select folder...");
		}
		private function onChooseTouch(event:TouchEvent):void {
			event.stopPropagation();
			var touch:Touch = event.getTouch(chooseFile, TouchPhase.ENDED);
			if(touch && touch.phase == TouchPhase.ENDED)            
				selectedFile.browse();
		}
		public function showFields(_b:Boolean):void {
			if(_b){
				folderInput.unfreeze();
				trackerInput.unfreeze();
				webInput.unfreeze();
				commentInput.unfreeze();
			}else{
				folderInput.freeze();
				trackerInput.freeze();
				webInput.freeze();
				commentInput.freeze();
			}	
		}
		public function show():void {
			this.visible = true;
			showFields(true);
			txtHolder.visible = folderInput.visible = chooseFile.visible = folderBtn.visible = trackerInput.visible = webInput.visible = commentInput.visible = chkAuto.visible = chkPrivate.visible = chkSeed.visible = okButton.visible = cancelButton.visible = size.visible = true;
			circularLoader.visible = false;
			circularLoader.reset();
		}
		public function hide():void {
			this.visible = false;
			commentInput.text = "";
			webInput.text = "";
			showFields(false);
		}
	}
}