package views.settings {
	import events.FormEvent;
	
	import model.SettingsLocalStore;
	
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	import views.forms.CheckBox;
	import views.forms.FormGroup;
	import views.forms.Stepper;
	
	public class SpeedPanel extends Sprite {
		private var upStppr:Stepper;
		private var downStppr:Stepper;
		private var chkUpload:CheckBox;
		private var chkDownload:CheckBox;
		private var chkEnableUTP:CheckBox;
		private var chkRateUTP:CheckBox;
		private var chkRateTransport:CheckBox;
		private var chkRateLAN:CheckBox;
		private var txtHolder:Sprite = new Sprite();
		public function SpeedPanel() {
			super();
			var rateGroup:FormGroup = new FormGroup(600,120,250);
			var rateGroupLbl:TextField = new TextField(150,32,"Global Rate Limits", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			var uploadLbl:TextField = new TextField(150,32,"Upload", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			var downloadLbl:TextField = new TextField(150,32,"Download", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			var utpLbl:TextField = new TextField(500,32,"Enable bandwidth management (uTP)", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			var rateUTPLbl:TextField = new TextField(500,32,"Apply rate limit to uTP connections", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			var rateTransportLbl:TextField = new TextField(500,32,"Apply rate limit to transport overhead", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			var rateLANLbl:TextField = new TextField(500,32,"Apply rate limit to peers on LAN", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			
			chkUpload = new CheckBox(model.SettingsLocalStore.settings.speed.uploadRateEnabled);
			chkUpload.addEventListener(FormEvent.CHANGE,onFormChange);
			chkDownload = new CheckBox(model.SettingsLocalStore.settings.speed.downloadRateEnabled);
			chkDownload.addEventListener(FormEvent.CHANGE,onFormChange);
			chkEnableUTP = new CheckBox(model.SettingsLocalStore.settings.speed.isuTPEnabled);
			chkEnableUTP.addEventListener(FormEvent.CHANGE,onFormChange);
			chkRateUTP = new CheckBox(model.SettingsLocalStore.settings.speed.isuTPRateLimited);
			chkRateUTP.addEventListener(FormEvent.CHANGE,onFormChange);
			chkRateLAN = new CheckBox(model.SettingsLocalStore.settings.speed.ignoreLimitsOnLAN);
			chkRateLAN.addEventListener(FormEvent.CHANGE,onFormChange);
			chkRateTransport = new CheckBox(model.SettingsLocalStore.settings.speed.rateLimitIpOverhead);
			chkRateTransport.addEventListener(FormEvent.CHANGE,onFormChange);
			
			chkUpload.x = chkDownload.x = chkEnableUTP.x = chkRateUTP.x = chkRateLAN.x = chkRateTransport.x = 3;
			
			chkUpload.y = 5;
			chkDownload.y = 35;
			chkEnableUTP.y = 65
			chkRateUTP.y = 95
			chkRateLAN.y = 155
			chkRateTransport.y = 125;
			
			upStppr = new Stepper(80,String(model.SettingsLocalStore.settings.speed.uploadRateLimit),6,100);
			upStppr.addEventListener(FormEvent.CHANGE,onFormChange);
			upStppr.x = 160;
			upStppr.y = chkUpload.y + 12;
			upStppr.enable(model.SettingsLocalStore.settings.speed.uploadRateEnabled);
			
			
			downStppr = new Stepper(80,String(model.SettingsLocalStore.settings.speed.downloadRateLimit),6,100);
			downStppr.addEventListener(FormEvent.CHANGE,onFormChange);
			downStppr.x = 160;
			downStppr.y = chkDownload.y + 12;
			downStppr.enable(model.SettingsLocalStore.settings.speed.downloadRateEnabled);
			
			
			uploadLbl.vAlign = downloadLbl.vAlign = utpLbl.vAlign = rateUTPLbl.vAlign = rateTransportLbl.vAlign = rateLANLbl.vAlign = rateGroupLbl.vAlign = VAlign.TOP;
			uploadLbl.hAlign = downloadLbl.hAlign = utpLbl.hAlign = rateUTPLbl.hAlign = rateTransportLbl.hAlign = rateLANLbl.hAlign = rateGroupLbl.hAlign = HAlign.LEFT;
			uploadLbl.touchable = downloadLbl.touchable = utpLbl.touchable = rateUTPLbl.touchable = rateTransportLbl.touchable = rateLANLbl.touchable = rateGroupLbl.touchable = false;
			uploadLbl.batchable = downloadLbl.batchable = utpLbl.batchable = rateUTPLbl.batchable = rateTransportLbl.batchable = rateLANLbl.batchable = rateGroupLbl.batchable = true;
			
			rateGroupLbl.x = 15;
			rateGroupLbl.y = -8;
			
			uploadLbl.x = downloadLbl.x = utpLbl.x = rateUTPLbl.x = rateTransportLbl.x = rateLANLbl.x = 45;
			
			uploadLbl.y = 20;
			downloadLbl.y = 50;
			utpLbl.y = 80;
			rateUTPLbl.y = 110;
			rateTransportLbl.y = 140;
			rateLANLbl.y = 170;
			
			txtHolder.addChild(rateGroupLbl);
			txtHolder.addChild(uploadLbl);
			txtHolder.addChild(downloadLbl);
			txtHolder.addChild(utpLbl);
			txtHolder.addChild(rateUTPLbl);
			txtHolder.addChild(rateTransportLbl);
			txtHolder.addChild(rateLANLbl);
			
			txtHolder.flatten();
			
			rateGroup.addChild(chkUpload);
			rateGroup.addChild(chkDownload);
			rateGroup.addChild(chkEnableUTP);
			rateGroup.addChild(chkRateUTP);
			rateGroup.addChild(chkRateTransport);
			rateGroup.addChild(chkRateLAN);
			rateGroup.addChild(upStppr);
			rateGroup.addChild(downStppr);
			addChild(txtHolder);
			
			addChild(rateGroup);
		}
		public function showFields(_b:Boolean):void {
			upStppr.nti.show(_b);
			downStppr.nti.show(_b);
		}
		public function positionAllFields():void {
			upStppr.updatePosition();
			downStppr.updatePosition();
		}
		private function onFormChange(event:FormEvent):void {
			var test:int;
			switch(event.currentTarget){
				case upStppr:
					if(event.params.value > -1)
						model.SettingsLocalStore.setProp("speed",event.params.value,"uploadRateLimit");
					break;
				case downStppr:
					if(event.params.value > -1)
						model.SettingsLocalStore.setProp("speed",event.params.value,"downloadRateLimit");
					break;
				case chkUpload:
					upStppr.enable(event.params.value);
					model.SettingsLocalStore.setProp("speed",event.params.value,"uploadRateEnabled");
					break;
				case chkDownload:
					downStppr.enable(event.params.value);
					model.SettingsLocalStore.setProp("speed",event.params.value,"downloadRateEnabled");
					break;
				case chkEnableUTP:
					model.SettingsLocalStore.setProp("speed",event.params.value,"isuTPEnabled");
					break;
				case chkRateUTP:
					model.SettingsLocalStore.setProp("speed",event.params.value,"isuTPRateLimited");
					break;
				case chkRateTransport:
					model.SettingsLocalStore.setProp("speed",event.params.value,"rateLimitIpOverhead");
					break;
				case chkRateLAN:
					model.SettingsLocalStore.setProp("speed",event.params.value,"ignoreLimitsOnLAN");
					break;
			}
			
		}
	}
}