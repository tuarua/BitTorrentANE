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
	
	import feathers.display.Scale9Image;
	import feathers.textures.Scale9Textures;
	
	import starling.display.BlendMode;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	import utils.TextUtils;
	
	import views.forms.CheckBox;
	import views.forms.DropDown;
	import views.forms.Input;
	
	public class CreateTorrentScreen extends Sprite {
		private var txtHolder:Sprite = new Sprite();
		private var bgTexture:Scale9Textures;
		private var bg:Scale9Image;
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

		private var progressLbl:TextField;
		public function CreateTorrentScreen() {
			super();
			bgTexture = new Scale9Textures(Assets.getAtlas().getTexture("popmenu-bg"),new Rectangle(4,4,16,16));
			bg = new Scale9Image(bgTexture);
			bg.blendMode = BlendMode.NONE;
			bg.touchable = false;
			bg.width = 600;
			bg.height = 500;
			
			var fileLbl:TextField = new TextField(120,32,"File or folder:", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			var trackerLbl:TextField = new TextField(120,32,"Tracker URLs:", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			var webLbl:TextField = new TextField(120,32,"Web seed URLs:", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			var commentLbl:TextField = new TextField(120,32,"Comment:", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			var sizeLbl:TextField = new TextField(120,32,"Piece size:", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			var autoLbl:TextField = new TextField(120,32,"Auto", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			var privateLbl:TextField = new TextField(120,32,"Private", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			var seedNowLbl:TextField = new TextField(120,32,"Seed now", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			progressLbl = new TextField(600,32,"", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			
			
			
			progressLbl.vAlign = seedNowLbl.vAlign = privateLbl.vAlign = autoLbl.vAlign = sizeLbl.vAlign = webLbl.vAlign = commentLbl.vAlign = trackerLbl.vAlign = fileLbl.vAlign = VAlign.TOP;
			seedNowLbl.hAlign = privateLbl.hAlign = autoLbl.hAlign = sizeLbl.hAlign = webLbl.hAlign = commentLbl.hAlign = trackerLbl.hAlign = fileLbl.hAlign = HAlign.LEFT;
			progressLbl.touchable = seedNowLbl.touchable = privateLbl.touchable = autoLbl.touchable = sizeLbl.touchable = webLbl.touchable = commentLbl.touchable = trackerLbl.touchable = fileLbl.touchable = false;
			progressLbl.batchable = seedNowLbl.batchable = privateLbl.batchable = autoLbl.batchable = sizeLbl.batchable = webLbl.batchable = commentLbl.batchable = trackerLbl.batchable = fileLbl.batchable = true;
			
			progressLbl.hAlign = HAlign.CENTER;

			commentLbl.x = fileLbl.x = webLbl.x = trackerLbl.x = 12;
			fileLbl.y = 20;
			trackerLbl.y = 50;
			webLbl.y = 140;
			commentLbl.y = 230;
			
			progressLbl.x = 0;
			progressLbl.y = 200;
			progressLbl.visible = false;
			
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
			
			addChild(bg);
			
			txtHolder.addChild(fileLbl);
			txtHolder.addChild(trackerLbl);
			txtHolder.addChild(webLbl);
			txtHolder.addChild(commentLbl);
			txtHolder.addChild(sizeLbl);
			txtHolder.addChild(autoLbl);
			txtHolder.addChild(privateLbl);
			txtHolder.addChild(seedNowLbl);

			txtHolder.flatten();
			
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
			
			addChild(progressLbl);
			
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
				var outputFile:File = new File();
				outputFile.addEventListener(Event.SELECT, onOutputSelected); 
				outputFile.browseForSave("Save torrent as...");
			}
		}
		
		
		private function onOutputSelected(event:Event):void {
			
			var obj:Object = new Object();
			obj.file = folderInput.nti.input.text;
			
			var trackers:Vector.<TorrentTracker> = new Vector.<TorrentTracker>();
			var arrTrackers:Array = TextUtils.trim(trackerInput.nti.input.text).split(String.fromCharCode(13));
			for (var i:int=0, l:int=arrTrackers.length; i<l; ++i)
				trackers.push(new TorrentTracker(arrTrackers[i]));
			obj.trackers = trackers;
			
			var webSeeds:Vector.<TorrentWebSeed> = new Vector.<TorrentWebSeed>();
			var arrWebSeeds:Array = TextUtils.trim(webInput.nti.input.text).split(String.fromCharCode(13));
			for (var i2:int=0, l2:int=arrTrackers.length; i2<l2; ++i2)
				webSeeds.push(new TorrentWebSeed(arrWebSeeds[i2]));
			
			obj.webSeeds = webSeeds;
			obj.comments = commentInput.nti.input.text;
			obj.size = (chkAuto.selected) ? 0 : sizeDataList[size.selected].value;
			obj.isPrivate = chkPrivate.selected;
			obj.seedNow = chkSeed.selected;
			obj.output = (event.target as File).nativePath;
			
			showFields(false);
			txtHolder.visible = folderInput.visible = chooseFile.visible = folderBtn.visible = trackerInput.visible = webInput.visible = commentInput.visible = chkAuto.visible = chkPrivate.visible = chkSeed.visible = okButton.visible = cancelButton.visible = size.visible = false;
			
			progressLbl.visible = true;
			
			this.dispatchEvent(new InteractionEvent(InteractionEvent.ON_TORRRENT_CREATE,obj,true));
			
		}
		
		public function onProgress(event:TorrentInfoEvent):void {
			progressLbl.text = event.params.progress.toString()+"%";
		}
		public function onCreateComplete(event:TorrentInfoEvent):void {
			hide();
			txtHolder.visible = folderInput.visible = chooseFile.visible = folderBtn.visible = trackerInput.visible = webInput.visible = commentInput.visible = chkAuto.visible = chkPrivate.visible = chkSeed.visible = okButton.visible = cancelButton.visible = size.visible = true;
			progressLbl.text = "";
			progressLbl.visible = true;
			
			if(event.params.seedNow)
				this.dispatchEvent(new InteractionEvent(InteractionEvent.ON_TORRRENT_SEED_NOW,{fileName:event.params.fileName},true))
		}
		
		private function onCancel(event:TouchEvent):void {
			var touch:Touch = event.getTouch(cancelButton);
			if(touch != null && touch.phase == TouchPhase.ENDED)
				hide();
		}
		private function onFolderSelect(event:Event):void {
			folderInput.nti.input.text = selectedFolder.nativePath;
		}
		private function onFileSelect(event:Event):void {
			folderInput.nti.input.text = selectedFile.nativePath;
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
			folderInput.nti.show(_b);
			trackerInput.nti.show(_b);
			webInput.nti.show(_b);
			commentInput.nti.show(_b);
		}
		public function show():void {
			this.visible = true;
			showFields(true);
		}
		public function hide():void {
			this.visible = false;
			commentInput.nti.input.text = "";
			webInput.nti.input.text = "";
			showFields(false);
		}
	}
}