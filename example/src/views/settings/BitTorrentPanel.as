package views.settings {
	import com.tuarua.torrent.constants.Encryption;
	
	import events.FormEvent;
	
	import model.SettingsLocalStore;
	
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	import views.forms.CheckBox;
	import views.forms.DropDown;
	import views.forms.FormGroup;
	import views.forms.Stepper;
	
	public class BitTorrentPanel extends Sprite {
		private var chkDHT:CheckBox;
		private var chkPEX:CheckBox;
		private var chkLSD:CheckBox;
		private var chkAnonymous:CheckBox;
		private var chkQueueing:CheckBox;
		private var chkSlow:CheckBox;
		private var txtHolder:Sprite = new Sprite();
		private var encyptionMode:DropDown;
		private var maxDownStppr:Stepper;
		private var maxUpStppr:Stepper;
		private var maxTorrStppr:Stepper;
		private var maxActiveDownLbl:TextField;
		private var maxActiveUpLbl:TextField;
		private var maxActiveTorrLbl:TextField;
		private var slowTorrLbl:TextField;
		public function BitTorrentPanel() {
			super();
			var privacyGroupLbl:TextField = new TextField(50,32,"Privacy", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			var dhtLbl:TextField = new TextField(500,32,"Enable DHT (decentralised network) to find more peers", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			var pexLbl:TextField = new TextField(500,32,"Enable Peer Exchange (PeX) to find more peers", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			var lsdLbl:TextField = new TextField(500,32,"Enable Local Peer Discovery to find more peers", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			var encryptionModeLbl:TextField = new TextField(100,32,"Encryption:", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			var anonModeLbl:TextField = new TextField(160,32,"Enable anonymous mode", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			var queuingLbl:TextField = new TextField(160,32,"Torrent queueing", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			maxActiveDownLbl = new TextField(200,32,"Maximum active downloads", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			maxActiveUpLbl = new TextField(200,32,"Maximum active uploads", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			maxActiveTorrLbl = new TextField(200,32,"Maximum active torrents", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			slowTorrLbl = new TextField(400,32,"Do not count slow torrents in these limits", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			
			encryptionModeLbl.x = privacyGroupLbl.x = 15;
			privacyGroupLbl.y = -8;
			encryptionModeLbl.y = 115;
			
			
			queuingLbl.x = anonModeLbl.x = lsdLbl.x = pexLbl.x = dhtLbl.x = 45;
			
			dhtLbl.y = 20;
			pexLbl.y = 50;
			lsdLbl.y = 80;
			
			
			slowTorrLbl.vAlign = maxActiveTorrLbl.vAlign = maxActiveUpLbl.vAlign = maxActiveDownLbl.vAlign = queuingLbl.vAlign = anonModeLbl.vAlign = encryptionModeLbl.vAlign = lsdLbl.vAlign = pexLbl.vAlign = dhtLbl.vAlign = privacyGroupLbl.vAlign = VAlign.TOP;
			slowTorrLbl.hAlign = maxActiveTorrLbl.hAlign = maxActiveUpLbl.hAlign = maxActiveDownLbl.hAlign = queuingLbl.hAlign = anonModeLbl.hAlign = encryptionModeLbl.hAlign = lsdLbl.hAlign = pexLbl.hAlign = dhtLbl.hAlign = privacyGroupLbl.hAlign = HAlign.LEFT;
			slowTorrLbl.touchable = maxActiveTorrLbl.touchable = maxActiveUpLbl.touchable = maxActiveDownLbl.touchable = queuingLbl.touchable = anonModeLbl.touchable = encryptionModeLbl.touchable = lsdLbl.touchable = pexLbl.touchable = dhtLbl.touchable = privacyGroupLbl.touchable = false;
			slowTorrLbl.batchable = maxActiveTorrLbl.batchable = maxActiveUpLbl.batchable = maxActiveDownLbl.batchable = queuingLbl.batchable = anonModeLbl.batchable = encryptionModeLbl.batchable = lsdLbl.batchable = pexLbl.batchable = dhtLbl.batchable = privacyGroupLbl.batchable = true;
			
			var privacyGroup:FormGroup = new FormGroup(600,58,200);
			
			chkDHT = new CheckBox(model.SettingsLocalStore.settings.privacy.useDHT);
			chkPEX = new CheckBox(model.SettingsLocalStore.settings.privacy.useLSD);
			chkLSD = new CheckBox(model.SettingsLocalStore.settings.privacy.usePEX);
			chkAnonymous = new CheckBox(model.SettingsLocalStore.settings.privacy.useAnonymousMode);
			
			chkDHT.addEventListener(FormEvent.CHANGE,onFormChange);
			chkPEX.addEventListener(FormEvent.CHANGE,onFormChange);
			chkLSD.addEventListener(FormEvent.CHANGE,onFormChange);
			chkAnonymous.addEventListener(FormEvent.CHANGE,onFormChange);
			slowTorrLbl.addEventListener(FormEvent.CHANGE,onFormChange);
			
			chkAnonymous.x = chkDHT.x = chkPEX.x = chkLSD.x = 3;
			chkDHT.y = 5;
			chkPEX.y = 35;
			chkLSD.y = 65;
			chkAnonymous.y = 132;
			anonModeLbl.y = 147;
			
			var encryptionDataList:Vector.<Object> = new Vector.<Object>();
			encryptionDataList.push({value:Encryption.DISABLED,label:"Disabled"});
			encryptionDataList.push({value:Encryption.ENABLED,label:"Enabled"});
			encryptionDataList.push({value:Encryption.REQUIRED,label:"Required"});
			
			encyptionMode = new DropDown(120,encryptionDataList,model.SettingsLocalStore.settings.privacy.encryption);
			encyptionMode.addEventListener(FormEvent.CHANGE,onFormChange);
			encyptionMode.x = 100;
			encyptionMode.y = 112;
			
			privacyGroup.addChild(chkDHT);
			privacyGroup.addChild(chkPEX);
			privacyGroup.addChild(chkLSD);
			privacyGroup.addChild(chkAnonymous);
			
			txtHolder.addChild(privacyGroupLbl);
			txtHolder.addChild(dhtLbl);
			txtHolder.addChild(pexLbl);
			txtHolder.addChild(lsdLbl);
			txtHolder.addChild(encryptionModeLbl);
			txtHolder.addChild(anonModeLbl);
			
	
			
			
			privacyGroup.addChild(encyptionMode);
			
			var queueGroup:FormGroup = new FormGroup(600,150,180);
			
			queueGroup.y = 250;
			queuingLbl.x = 45;
			queuingLbl.y = 145;
			queuingLbl.y = queueGroup.y - 8;
			chkQueueing = new CheckBox(model.SettingsLocalStore.settings.queueing.enabled);
			
			chkQueueing.addEventListener(FormEvent.CHANGE,onFormChange);
			chkQueueing.y = -23;
			chkQueueing.x = 3;
			queueGroup.addChild(chkQueueing);
			txtHolder.addChild(queuingLbl);
			
			
			
			maxActiveTorrLbl.x = maxActiveUpLbl.x = maxActiveDownLbl.x = 15;
			maxActiveDownLbl.y = queueGroup.y + 20;
			maxActiveUpLbl.y = queueGroup.y + 50;
			maxActiveTorrLbl.y = queueGroup.y + 80;
			
			maxDownStppr = new Stepper(60,String(model.SettingsLocalStore.settings.queueing.maxActiveDownloads));
			maxUpStppr = new Stepper(60,String(model.SettingsLocalStore.settings.queueing.maxActiveUploads));
			maxTorrStppr = new Stepper(60,String(model.SettingsLocalStore.settings.queueing.maxActiveTorrents));
			
			maxDownStppr.addEventListener(FormEvent.CHANGE,onFormChange);
			maxUpStppr.addEventListener(FormEvent.CHANGE,onFormChange);
			maxTorrStppr.addEventListener(FormEvent.CHANGE,onFormChange);
			
			maxDownStppr.y = 17;
			maxUpStppr.y = 47;
			maxTorrStppr.y = 77;
			
			slowTorrLbl.x = 45;
			
			slowTorrLbl.y = queueGroup.y + 115;
			chkSlow = new CheckBox(model.SettingsLocalStore.settings.queueing.ignoreSlow);
			chkSlow.x = 3;
			chkSlow.y = 100;
			
			maxUpStppr.x = maxTorrStppr.x = maxDownStppr.x = 210;
			queueGroup.addChild(maxDownStppr);
			queueGroup.addChild(maxUpStppr);
			queueGroup.addChild(maxTorrStppr);
			queueGroup.addChild(chkSlow);
			
			
			txtHolder.addChild(maxActiveDownLbl);
			txtHolder.addChild(maxActiveUpLbl);
			txtHolder.addChild(maxActiveTorrLbl);
			txtHolder.addChild(slowTorrLbl);
			
			txtHolder.flatten();
			
			enableQueueing(model.SettingsLocalStore.settings.queueing.enabled);
			
			addChild(txtHolder);
			addChild(privacyGroup);
			addChild(queueGroup);
			
			
			
			
		}
		
		
		private function onFormChange(event:FormEvent):void {
			var test:int;
			switch(event.currentTarget){
				case maxDownStppr:
					if(event.params)
						test = (parseInt(maxDownStppr.nti.input.text)+event.params.value)
					else
						test = (parseInt(maxDownStppr.nti.input.text))
					
					if(test > -1){
						maxDownStppr.nti.input.text = test.toString();
						model.SettingsLocalStore.setProp("queueing",test,"maxActiveDownloads");
					}	
					break;
				case maxUpStppr:
					if(event.params)
						test = (parseInt(maxUpStppr.nti.input.text)+event.params.value);
					else
						test = parseInt(maxUpStppr.nti.input.text);
					
					if(test > -1){
						maxUpStppr.nti.input.text = test.toString();
						model.SettingsLocalStore.setProp("queueing",test,"maxActiveUploads");
					}
					break;
				case maxTorrStppr:
					if(event.params)
						test = (parseInt(maxTorrStppr.nti.input.text)+event.params.value);
					else
						test = parseInt(maxTorrStppr.nti.input.text);
					
					if(test > -1){
						maxTorrStppr.nti.input.text = test.toString();
						model.SettingsLocalStore.setProp("queueing",test,"maxActiveTorrents");
					}
					break;
				case chkQueueing:
					enableQueueing(event.params.value);
					model.SettingsLocalStore.setProp("queueing",event.params.value,"enabled");
					break;
				case slowTorrLbl:
					model.SettingsLocalStore.setProp("queueing",event.params.value,"ignoreSlow");
					break;
				
				
				case chkDHT:
					model.SettingsLocalStore.setProp("privacy",event.params.value,"useDHT");
					break;
				case chkPEX:
					model.SettingsLocalStore.setProp("privacy",event.params.value,"usePEX");
					break;
				case chkLSD:
					model.SettingsLocalStore.setProp("privacy",event.params.value,"useLSD");
					break;
				case chkAnonymous:
					model.SettingsLocalStore.setProp("privacy",event.params.value,"useAnonymousMode");
					break;
				case encyptionMode:
					model.SettingsLocalStore.setProp("privacy",event.params.value,"encryption");
					break;
			}	
		}
		private function enableQueueing(_b:Boolean):void {
			maxDownStppr.enable(_b);
			maxUpStppr.enable(_b);
			maxTorrStppr.enable(_b);
			
			chkSlow.enable(_b);
			txtHolder.unflatten();
			slowTorrLbl.alpha = maxActiveUpLbl.alpha = maxActiveTorrLbl.alpha = maxActiveDownLbl.alpha = (_b) ? 1.0 : 0.25;
			txtHolder.flatten();
		}
		public function showFields(_b:Boolean):void {
			maxDownStppr.nti.show(_b);
			maxUpStppr.nti.show(_b);
			maxTorrStppr.nti.show(_b);
		}
		public function positionAllFields():void {
			maxDownStppr.updatePosition();
			maxUpStppr.updatePosition();
			maxTorrStppr.updatePosition();
		}
	}
}