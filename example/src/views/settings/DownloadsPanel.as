package views.settings {
	import com.tuarua.torrent.TorrentSettings;
	
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.text.TextFieldType;
	
	import events.FormEvent;
	
	import model.SettingsLocalStore;
	
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
	
	import views.forms.FormGroup;
	import views.forms.Input;

	public class DownloadsPanel extends Sprite {
		public var appRootInput:Input;
		private var chooseFolder:Image = new Image(Assets.getAtlas().getTexture("choose-bg"));
		private var txtHolder:Sprite = new Sprite();
		private var folderBtn:Button;
		private var selectedFolder:File = new File();
		private var folderTexture:Texture;
		public function DownloadsPanel() {
			super();
			
			selectedFolder.addEventListener(Event.SELECT, openFolder); 
			
			appRootInput = new Input(500,model.SettingsLocalStore.settings.outputPath);
			appRootInput.type = TextFieldType.DYNAMIC;
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.setTo("Fira Sans Semi-Bold 13",13);
			textFormat.horizontalAlign = Align.LEFT;
			textFormat.verticalAlign = Align.TOP;
			textFormat.color = 0xD8D8D8;
			
			var storageGroupLbl:TextField = new TextField(50,32,"Storage");
			storageGroupLbl.format = textFormat;
			storageGroupLbl.x = 15;
			storageGroupLbl.y = -8;
			storageGroupLbl.touchable = false;
			storageGroupLbl.batchable = true;
			
			
			var storageGroup:FormGroup = new FormGroup(600,62,70);

		
			
			folderTexture = Assets.getAtlas().getTexture("folder-button-hover");
			folderBtn = new Button(folderTexture,"",folderTexture,folderTexture,folderTexture);
			

			
			txtHolder.addChild(storageGroupLbl);
			
			appRootInput.x = 12;
			chooseFolder.y = appRootInput.y = 20;
			folderBtn.y = chooseFolder.y + 5;
			chooseFolder.x = 20 + appRootInput.width + 8;
			chooseFolder.useHandCursor = false;
			chooseFolder.addEventListener(TouchEvent.TOUCH,onChooseTouch);
			
			folderBtn.x = chooseFolder.x + 40;
			folderBtn.useHandCursor = false;
			folderBtn.addEventListener(TouchEvent.TOUCH,onFolderTouch);
			
			storageGroup.addChild(appRootInput);
			storageGroup.addChild(chooseFolder);
			storageGroup.addChild(folderBtn);

			addChild(storageGroup);
			addChild(txtHolder);
			
		}
		
		private function onChooseTouch(event:TouchEvent):void {
			event.stopPropagation();
			var touch:Touch = event.getTouch(chooseFolder, TouchPhase.ENDED);
			if(touch && touch.phase == TouchPhase.ENDED)            
				selectedFolder.browseForDirectory("Select folder...");
		}
		
		private function openFolder(event:Event):void{
			appRootInput.text = selectedFolder.nativePath;
			model.SettingsLocalStore.setProp("outputPath",selectedFolder.nativePath);
			TorrentSettings.storage.outputPath = selectedFolder.nativePath;
		}
		
		private function onFolderTouch(event:TouchEvent):void {
			event.stopPropagation();
			var touch:Touch = event.getTouch(folderBtn, TouchPhase.ENDED);
			if(touch && touch.phase == TouchPhase.ENDED){
				var folder:File = File.applicationStorageDirectory.resolvePath(model.SettingsLocalStore.settings.outputPath);
				folder.openWithDefaultApplication();
			}
		}
		
		public function showFields(_b:Boolean):void {
			appRootInput.freeze(!_b);
		}
		public function positionAllFields():void {
			appRootInput.updatePosition();
		}
		
		
	}
}