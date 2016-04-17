package views.settings {
	import com.tuarua.torrent.constants.ProxyType;
	
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.text.TextFieldType;
	
	import events.FormEvent;
	
	import model.SettingsLocalStore;
	
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	import views.forms.CheckBox;
	import views.forms.DropDown;
	import views.forms.FormGroup;
	import views.forms.Input;
	import views.forms.Stepper;
	
	public class ConnectionPanel extends Sprite {
		private var portStppr:Stepper;
		private var chkUPnP:CheckBox;
		private var chkRandom:CheckBox;
		
		private var chkMaxConn:CheckBox;
		private var chkMaxConnTorr:CheckBox;
		private var chkMaxUp:CheckBox;
		private var chkMaxUpTorr:CheckBox;
		private var chkFilter:CheckBox;
		private var chkApplyToTrackers:CheckBox;
		
		private var maxConnStppr:Stepper;
		private var maxConnTorrStppr:Stepper;
		private var maxUpStppr:Stepper;
		private var maxUpTorrStppr:Stepper;
		
		private var proxyPortStppr:Stepper;
		private var proxyType:DropDown;
		private var chkProxyForPeers:CheckBox;
		private var chkProxyDisableConns:CheckBox;
		private var chkAuthentication:CheckBox;
		public var proxyHostInput:Input;
		public var proxyUsernameInput:Input;
		public var proxyPasswordInput:Input;
		
		public var filterPathInput:Input;
		private var chooseFile:Image = new Image(Assets.getAtlas().getTexture("choose-bg"));
		private var selectedFile:File = new File();
		private var txtHolder:Sprite = new Sprite();

		private var proxyForPeersLbl:TextField;
		private var proxyDisableConnsLbl:TextField;
		private var proxyHostLbl:TextField;
		private var proxyPortLbl:TextField;
		private var proxyAuthenticationLbl:TextField;
		private var proxyUsernameLbl:TextField;
		private var proxyPasswordLbl:TextField;

		private var applyToTrackersLbl:TextField;

		private var filterPathLbl:TextField;
		
		public function ConnectionPanel() {
			super();
			
			selectedFile.addEventListener(Event.SELECT, selectFile); 
			
			var privacyGroupLbl:TextField = new TextField(150,32,"Listening Port", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			var portLbl:TextField = new TextField(500,32,"Port used for incoming connections", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			var upnpLbl:TextField = new TextField(500,32,"Use UPnP / NAT-PMP port forwarding from my router", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			var randomLbl:TextField = new TextField(500,32,"Use different port on each startup", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			
			var limitsGroupLbl:TextField = new TextField(150,32,"Connections Limits", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			var proxyGroupLbl:TextField = new TextField(150,32,"Proxy Server", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			var filterGroupLbl:TextField = new TextField(150,32,"IP Filtering", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			
			var proxyTypeLbl:TextField = new TextField(150,32,"Type:", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			proxyHostLbl = new TextField(150,32,"Host:", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			proxyPortLbl = new TextField(150,32,"Port:", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			
			proxyForPeersLbl = new TextField(500,32,"Use proxy for peer connections", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			proxyDisableConnsLbl = new TextField(500,32,"Disable connections not supported by proxies", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			proxyAuthenticationLbl = new TextField(150,32,"Authentication", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			proxyUsernameLbl = new TextField(150,32,"Username:", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			proxyPasswordLbl = new TextField(150,32,"Password:", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			
			var maxConnLbl:TextField = new TextField(500,32,"Global maximum number of connections:", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			var maxConnTorrLbl:TextField = new TextField(500,32,"Maximum number of connections per torrent:", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			var maxUpLbl:TextField = new TextField(500,32,"Global maximum number of upload slots:", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			var maxUpTorrLbl:TextField = new TextField(500,32,"Maximum number of upload slots per torrent:", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			
			filterPathLbl = new TextField(500,32,"Filter path (.p2p):", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			applyToTrackersLbl = new TextField(500,32,"Apply to trackers", "Fira Sans Semi-Bold 13", 13, 0xD8D8D8);
			
			portStppr = new Stepper(75,String(model.SettingsLocalStore.settings.listening.port),5);
			portStppr.addEventListener(FormEvent.CHANGE,onFormChange);
			portStppr.x = 250;
			portStppr.y = 17;
			
			privacyGroupLbl.x = 15;
			privacyGroupLbl.y = -8;
			
			portStppr.enable(!model.SettingsLocalStore.settings.listening.randomPort);
			
			chkMaxConn = new CheckBox(model.SettingsLocalStore.settings.connections.useMaxConnections);
			chkMaxConn.addEventListener(FormEvent.CHANGE,onFormChange);
			chkMaxConnTorr = new CheckBox(model.SettingsLocalStore.settings.connections.useMaxConnectionsPerTorrent);
			chkMaxConnTorr.addEventListener(FormEvent.CHANGE,onFormChange);
			chkMaxUp = new CheckBox(model.SettingsLocalStore.settings.connections.useMaxUploads);
			chkMaxUp.addEventListener(FormEvent.CHANGE,onFormChange);
			chkMaxUpTorr = new CheckBox(model.SettingsLocalStore.settings.connections.useMaxUploadsPerTorrent);
			chkMaxUpTorr.addEventListener(FormEvent.CHANGE,onFormChange);
			
			chkUPnP = new CheckBox(model.SettingsLocalStore.settings.listening.useUPnP);
			chkUPnP.addEventListener(FormEvent.CHANGE,onFormChange);
			chkRandom = new CheckBox(model.SettingsLocalStore.settings.listening.randomPort);
			chkRandom.addEventListener(FormEvent.CHANGE,onFormChange);
			chkProxyForPeers = new CheckBox(model.SettingsLocalStore.settings.proxy.useForPeerConnections);  
			chkProxyForPeers.addEventListener(FormEvent.CHANGE,onFormChange);
			chkProxyDisableConns = new CheckBox(model.SettingsLocalStore.settings.proxy.force);
			chkProxyDisableConns.addEventListener(FormEvent.CHANGE,onFormChange);
			chkAuthentication = new CheckBox(model.SettingsLocalStore.settings.proxy.useAuth);
			chkAuthentication.addEventListener(FormEvent.CHANGE,onFormChange);
			
			chkFilter = new CheckBox(model.SettingsLocalStore.settings.filters.enabled);
			chkFilter.addEventListener(FormEvent.CHANGE,onFormChange);
			chkApplyToTrackers = new CheckBox(model.SettingsLocalStore.settings.filters.applyToTrackers);
			chkApplyToTrackers.addEventListener(FormEvent.CHANGE,onFormChange);
			
			chkApplyToTrackers.x = chkProxyForPeers.x = chkProxyDisableConns.x = chkAuthentication.x = chkRandom.x = chkMaxConn.x = chkMaxConnTorr.x = chkMaxUp.x = chkMaxUpTorr.x = chkUPnP.x = 3;
			
			chkUPnP.y = 35;
			chkRandom.y = 65;
			
			filterGroupLbl.vAlign = filterPathLbl.vAlign = applyToTrackersLbl.vAlign = proxyHostLbl.vAlign = proxyPortLbl.vAlign = proxyForPeersLbl.vAlign = proxyDisableConnsLbl.vAlign = proxyAuthenticationLbl.vAlign = proxyUsernameLbl.vAlign = proxyPasswordLbl.vAlign = proxyTypeLbl.vAlign = proxyGroupLbl.vAlign = maxUpTorrLbl.vAlign = maxUpLbl.vAlign = maxConnTorrLbl.vAlign = maxConnLbl.vAlign = limitsGroupLbl.vAlign = randomLbl.vAlign = upnpLbl.vAlign = portLbl.vAlign = privacyGroupLbl.vAlign = VAlign.TOP;
			filterGroupLbl.hAlign = filterPathLbl.hAlign = applyToTrackersLbl.hAlign = proxyHostLbl.hAlign = proxyPortLbl.hAlign = proxyForPeersLbl.hAlign = proxyDisableConnsLbl.hAlign = proxyAuthenticationLbl.hAlign = proxyUsernameLbl.hAlign = proxyPasswordLbl.hAlign = proxyTypeLbl.hAlign = proxyGroupLbl.hAlign = maxUpTorrLbl.hAlign = maxUpLbl.hAlign = maxConnTorrLbl.hAlign = maxConnLbl.hAlign = limitsGroupLbl.hAlign = randomLbl.hAlign = upnpLbl.hAlign = portLbl.hAlign = privacyGroupLbl.hAlign = HAlign.LEFT;
			filterGroupLbl.touchable = filterPathLbl.touchable = applyToTrackersLbl.touchable = proxyHostLbl.touchable = proxyPortLbl.touchable = proxyForPeersLbl.touchable = proxyDisableConnsLbl.touchable = proxyAuthenticationLbl.touchable = proxyUsernameLbl.touchable = proxyPasswordLbl.touchable = proxyTypeLbl.touchable = proxyGroupLbl.touchable = maxUpTorrLbl.touchable = maxUpLbl.touchable = maxConnTorrLbl.touchable = maxConnLbl.touchable = limitsGroupLbl.touchable = randomLbl.touchable = upnpLbl.touchable = portLbl.touchable = privacyGroupLbl.touchable = false;
			filterGroupLbl.batchable = filterPathLbl.batchable = applyToTrackersLbl.batchable = proxyHostLbl.batchable = proxyPortLbl.batchable = proxyForPeersLbl.batchable = proxyDisableConnsLbl.batchable = proxyAuthenticationLbl.batchable = proxyUsernameLbl.batchable = proxyPasswordLbl.batchable = proxyTypeLbl.batchable = proxyGroupLbl.batchable = maxUpTorrLbl.batchable = maxUpLbl.batchable = maxConnTorrLbl.batchable = maxConnLbl.batchable = limitsGroupLbl.batchable = randomLbl.batchable = upnpLbl.batchable = portLbl.batchable = privacyGroupLbl.batchable = true;
			
			portLbl.x = 15;
			portLbl.y = 20;
			
			upnpLbl.x = 45;
			upnpLbl.y = 50;
			
			randomLbl.x = 45;
			randomLbl.y = 80;
			
			var portGroup:FormGroup = new FormGroup(450,100,170);
			portGroup.addChild(portStppr);
			portGroup.addChild(chkUPnP);
			portGroup.addChild(chkRandom);
			
			txtHolder.addChild(privacyGroupLbl);
			txtHolder.addChild(portLbl);
			txtHolder.addChild(upnpLbl);
			txtHolder.addChild(randomLbl);
			
			addChild(portGroup);
			
			var limitsGroup:FormGroup = new FormGroup(450,117,170);
			limitsGroup.y = 200;
			
			limitsGroupLbl.x = 15;
			limitsGroupLbl.y = limitsGroup.y -8;
			
			txtHolder.addChild(limitsGroupLbl);
			
			maxConnTorrLbl.x = maxUpLbl.x = maxUpTorrLbl.x = maxConnLbl.x = 45;
			maxConnLbl.y = limitsGroup.y + 20;
			maxConnTorrLbl.y = limitsGroup.y + 50;
			maxUpLbl.y = limitsGroup.y + 80;
			maxUpTorrLbl.y = limitsGroup.y + 110;
			
			chkMaxConn.y = 5;
			chkMaxConnTorr.y = 35;
			chkMaxUp.y = 65;
			chkMaxUpTorr.y = 95;
			
			limitsGroup.addChild(chkMaxConn);
			limitsGroup.addChild(chkMaxConnTorr);
			limitsGroup.addChild(chkMaxUp);
			limitsGroup.addChild(chkMaxUpTorr);
			
			txtHolder.addChild(maxConnLbl);
			txtHolder.addChild(maxConnTorrLbl);
			txtHolder.addChild(maxUpLbl);
			txtHolder.addChild(maxUpTorrLbl);
			
			maxConnStppr = new Stepper(60,String(model.SettingsLocalStore.settings.connections.maxNum),3);
			maxConnStppr.addEventListener(FormEvent.CHANGE,onFormChange);
			maxConnStppr.y = chkMaxConn.y + 12;
			maxConnStppr.enable(model.SettingsLocalStore.settings.connections.useMaxConnections);
			
			maxConnTorrStppr = new Stepper(60,String(model.SettingsLocalStore.settings.connections.maxNumPerTorrent),3);
			maxConnTorrStppr.addEventListener(FormEvent.CHANGE,onFormChange);
			maxConnTorrStppr.y = chkMaxConnTorr.y + 12;
			maxConnTorrStppr.enable(model.SettingsLocalStore.settings.connections.useMaxConnectionsPerTorrent);
			
			maxUpStppr = new Stepper(60,String(model.SettingsLocalStore.settings.connections.maxUploads),3);
			maxUpStppr.addEventListener(FormEvent.CHANGE,onFormChange);
			maxUpStppr.y = chkMaxUp.y + 12;
			maxUpStppr.enable(model.SettingsLocalStore.settings.connections.useMaxUploads);
			
			maxUpTorrStppr = new Stepper(60,String(model.SettingsLocalStore.settings.connections.maxUploadsPerTorrent),3);
			maxUpTorrStppr.addEventListener(FormEvent.CHANGE,onFormChange);
			maxUpTorrStppr.y = chkMaxUpTorr.y + 12;
			maxUpTorrStppr.enable(model.SettingsLocalStore.settings.connections.useMaxUploadsPerTorrent);
			
			maxUpTorrStppr.x = maxUpStppr.x = maxConnTorrStppr.x = maxConnStppr.x = 350;
			
			limitsGroup.addChild(maxConnStppr);
			limitsGroup.addChild(maxConnTorrStppr);
			limitsGroup.addChild(maxUpStppr);
			limitsGroup.addChild(maxUpTorrStppr);

			addChild(limitsGroup);
			
			var proxyGroup:FormGroup = new FormGroup(550,90,220);
			proxyGroup.x = 550;
			
			proxyGroupLbl.x = proxyGroup.x + 15;
			proxyGroupLbl.y = -8;
			
			proxyTypeLbl.x = proxyGroup.x + 15;
			proxyHostLbl.y = proxyPortLbl.y = proxyTypeLbl.y = 20;
			
			var proxyDataList:Vector.<Object> = new Vector.<Object>();
			
			proxyDataList.push({value:ProxyType.DISABLED,label:"None"});
			proxyDataList.push({value:ProxyType.SOCKS4,label:"SOCKS4"});
			proxyDataList.push({value:ProxyType.SOCKS5,label:"SOCKS5"});
			proxyDataList.push({value:ProxyType.HTTP,label:"HTTP"});
			proxyDataList.push({value:ProxyType.I2P,label:"I2P"});
			
			proxyType = new DropDown(100,proxyDataList,model.SettingsLocalStore.settings.proxy.type);
			proxyType.addEventListener(FormEvent.CHANGE,onFormChange);
			proxyType.x = 70;
			proxyType.y = 17;
			
			proxyPortStppr = new Stepper(75,String(model.SettingsLocalStore.settings.proxy.port),5);
			proxyPortStppr.addEventListener(FormEvent.CHANGE,onFormChange);
			proxyPortStppr.x = 450;
			proxyPortStppr.y = 17;
			
			proxyHostLbl.x = proxyGroup.x + 200;
			proxyPortLbl.x = proxyGroup.x +  400;
			proxyForPeersLbl.x = proxyGroup.x + 45;
			proxyDisableConnsLbl.x = proxyGroup.x + 45;
			proxyAuthenticationLbl.x = proxyGroup.x + 45;
			proxyUsernameLbl.x = proxyGroup.x + 15;
			proxyPasswordLbl.x = proxyGroup.x + 15;
			
			

			proxyForPeersLbl.y = 50;
			proxyDisableConnsLbl.y = 80;
			proxyAuthenticationLbl.y = 110;
			proxyUsernameLbl.y = 145;
			proxyPasswordLbl.y = 175;
			chkProxyForPeers.y = 35;
			chkProxyDisableConns.y = 65;
			chkAuthentication.y = 95;
			
			
			proxyHostInput = new Input(125,model.SettingsLocalStore.settings.proxy.host);
			proxyHostInput.addEventListener(FormEvent.CHANGE,onFormChange);
			proxyUsernameInput = new Input(200,model.SettingsLocalStore.settings.proxy.username);
			proxyUsernameInput.addEventListener(FormEvent.CHANGE,onFormChange);
			proxyPasswordInput = new Input(200,model.SettingsLocalStore.settings.proxy.password);
			proxyPasswordInput.password = true;
			proxyPasswordInput.addEventListener(FormEvent.CHANGE,onFormChange);
			
			
			proxyHostInput.x = 250;
			proxyHostInput.y = 17;
			
			proxyUsernameInput.x = 100;
			proxyUsernameInput.y = 142;
			
			proxyPasswordInput.x = 100;
			proxyPasswordInput.y = 172;
			
			txtHolder.addChild(proxyGroupLbl);
			txtHolder.addChild(proxyTypeLbl);
			txtHolder.addChild(proxyHostLbl);
			txtHolder.addChild(proxyPortLbl);
				
			txtHolder.addChild(proxyForPeersLbl);
			txtHolder.addChild(proxyDisableConnsLbl);
			txtHolder.addChild(proxyAuthenticationLbl);
			txtHolder.addChild(proxyUsernameLbl);
			txtHolder.addChild(proxyPasswordLbl);
			
			proxyGroup.addChild(proxyPortStppr);
			proxyGroup.addChild(chkProxyForPeers);
			proxyGroup.addChild(chkProxyDisableConns);
			proxyGroup.addChild(chkAuthentication);
			
			proxyGroup.addChild(proxyHostInput);
			proxyGroup.addChild(proxyUsernameInput);
			proxyGroup.addChild(proxyPasswordInput);
			
			proxyGroup.addChild(proxyType);
			
			/*
			proxyForPeersLbl
			proxyDisableConnsLbl
			proxyAuthenticationLbl
			proxyUsernameLbl
			proxyPasswordLbl
			*/
			
			
			var filterGroup:FormGroup = new FormGroup(550,112,120);
			filterGroup.x = 550;
			filterGroup.y = 250;
			
			chkFilter.x = 3;
			chkFilter.y = -23;
			
			filterGroupLbl.x = filterGroup.x + 45;
			filterGroupLbl.y = filterGroup.y - 8;
			
			filterPathLbl.x = filterGroup.x + 12;
			filterPathLbl.y = filterGroup.y + 25;
			
			applyToTrackersLbl.x = filterGroup.x + 45;
			applyToTrackersLbl.y = filterGroup.y + 55;
			
			filterPathInput = new Input(350,model.SettingsLocalStore.settings.filters.fileName);
			filterPathInput.type = TextFieldType.DYNAMIC;
			filterPathInput.x = 140;
			filterPathInput.y = 20;
			
			enableIPfilter(model.SettingsLocalStore.settings.filters.enabled);
			
			txtHolder.addChild(filterGroupLbl);
			txtHolder.addChild(filterPathLbl);
			txtHolder.addChild(applyToTrackersLbl);
			
			chooseFile.x = filterPathInput.x + filterPathInput.width + 8;
			chooseFile.y = filterPathInput.y;
			
			chooseFile.useHandCursor = false;
			chooseFile.blendMode = BlendMode.NONE;
			chooseFile.addEventListener(TouchEvent.TOUCH,onChooseTouch);
			
			filterGroup.addChild(filterPathInput);
			filterGroup.addChild(chkFilter);
			filterGroup.addChild(chooseFile);
			
			chkApplyToTrackers.y = 40;
			
			filterGroup.addChild(chkApplyToTrackers);

			enableProxy(model.SettingsLocalStore.settings.proxy.type);
			
			addChild(txtHolder);
			txtHolder.flatten();
			
			addChild(filterGroup);
			addChild(proxyGroup);
			
		}
		
		private function enableIPfilter(_b:Boolean):void {
			chkApplyToTrackers.enable(_b);
			txtHolder.unflatten();
			chooseFile.alpha = filterPathLbl.alpha = applyToTrackersLbl.alpha = (_b) ? 1.0 : 0.25;
			txtHolder.flatten();
			chooseFile.touchable = _b;
			filterPathInput.enable(_b);
		}
		
		private function enableProxy(_type:int):void {
			proxyPortStppr.enable(_type > ProxyType.DISABLED && _type < ProxyType.I2P);
			
			txtHolder.unflatten();
			proxyPortLbl.alpha = proxyForPeersLbl.alpha = proxyDisableConnsLbl.alpha = (_type > ProxyType.DISABLED && _type < ProxyType.I2P) ? 1.0 : 0.25;
			proxyHostInput.alpha = (_type > ProxyType.DISABLED) ? 1.0 : 0.25;
			proxyHostInput.enable(_type > ProxyType.DISABLED);
			
			proxyAuthenticationLbl.alpha = (_type > ProxyType.SOCKS4 && _type < ProxyType.I2P) ? 1.0 : 0.25;
			proxyUsernameLbl.alpha = (_type > ProxyType.SOCKS4 && _type < ProxyType.I2P && model.SettingsLocalStore.settings.proxy.useAuth) ? 1.0 : 0.25;
			proxyPasswordLbl.alpha = (_type > ProxyType.SOCKS4 && _type < ProxyType.I2P && model.SettingsLocalStore.settings.proxy.useAuth) ? 1.0 : 0.25;
			
			txtHolder.flatten();
			
			chkProxyForPeers.enable(_type > ProxyType.DISABLED && _type < ProxyType.I2P);
			chkProxyDisableConns.enable(_type > ProxyType.DISABLED && _type < ProxyType.I2P);
			chkAuthentication.enable(_type > ProxyType.SOCKS4 && _type < ProxyType.I2P );
			
			proxyUsernameInput.enable(_type > ProxyType.SOCKS4 && _type < ProxyType.I2P  && model.SettingsLocalStore.settings.proxy.useAuth);
			proxyPasswordInput.enable(_type > ProxyType.SOCKS4 && _type < ProxyType.I2P  && model.SettingsLocalStore.settings.proxy.useAuth);
		}
		
		protected function selectFile(event:Event):void {
			filterPathInput.nti.input.text = selectedFile.nativePath;
			model.SettingsLocalStore.setProp("filters",selectedFile.nativePath,"fileName");
		}
		private function onChooseTouch(event:TouchEvent):void {
			event.stopPropagation();
			var touch:Touch = event.getTouch(chooseFile, TouchPhase.ENDED);
			if(touch && touch.phase == TouchPhase.ENDED)
				selectedFile.browseForOpen("Select p2p file...",[new FileFilter("p2p file", "*.p2p;")]);
		}
		
		
		private function onFormChange(event:FormEvent):void {
			var test:int;
			switch(event.currentTarget){
				case proxyType:
					model.SettingsLocalStore.setProp("proxy",event.params.value,"type");
					enableProxy(event.params.value);
					break;
				case proxyPortStppr:
					if(event.params)
						test = (parseInt(proxyPortStppr.nti.input.text)+event.params.value);
					else
						test = parseInt(proxyPortStppr.nti.input.text);
					if(test > -1){
						proxyPortStppr.nti.input.text = test.toString();
						model.SettingsLocalStore.setProp("proxy",test,"port");
					}
					break;
				
				case chkProxyForPeers:
					model.SettingsLocalStore.setProp("proxy",event.params.value,"useForPeerConnections");
					break;
				case chkProxyDisableConns:
					model.SettingsLocalStore.setProp("proxy",event.params.value,"force");
					break;
				case chkAuthentication:
					model.SettingsLocalStore.setProp("proxy",event.params.value,"useAuth");
					proxyAuthenticationLbl.alpha = (event.params.value) ? 1.0 : 0.25;
					proxyUsernameLbl.alpha = (event.params.value) ? 1.0 : 0.25;
					proxyPasswordLbl.alpha = (event.params.value) ? 1.0 : 0.25;
					proxyUsernameInput.enable(event.params.value);
					proxyPasswordInput.enable(event.params.value);
					break;
				case proxyHostInput:
					model.SettingsLocalStore.setProp("proxy",proxyHostInput.nti.input.text,"host");
					break;
				case proxyUsernameInput:
					model.SettingsLocalStore.setProp("proxy",proxyUsernameInput.nti.input.text,"username");
					break;
				case proxyPasswordInput:
					model.SettingsLocalStore.setProp("proxy",proxyPasswordInput.nti.input.text,"password");
					break;
				case chkApplyToTrackers:
					model.SettingsLocalStore.setProp("filters",event.params.value,"applyToTrackers");
					break;
				case chkFilter:
					model.SettingsLocalStore.setProp("filters",event.params.value,"enabled");
					enableIPfilter(event.params.value)
					break;
				case chkUPnP:
					model.SettingsLocalStore.setProp("listening",event.params.value,"useUPnP");
					break;
				case chkRandom:
					model.SettingsLocalStore.setProp("listening",event.params.value,"randomPort");
					portStppr.enable(!event.params.value);
					break;
				case portStppr:
					if(event.params)
						test = (parseInt(portStppr.nti.input.text)+event.params.value);
					else
						test = parseInt(portStppr.nti.input.text);
					if(test > -1){
						portStppr.nti.input.text = test.toString();
						model.SettingsLocalStore.setProp("listening",test,"port");
					}
					break;
				
				
				case chkMaxConn:
					model.SettingsLocalStore.setProp("connections",event.params.value,"useMaxConnections");
					maxConnStppr.enable(event.params.value);
					break;
				case chkMaxConnTorr:
					model.SettingsLocalStore.setProp("connections",event.params.value,"useMaxConnectionsPerTorrent");
					maxConnTorrStppr.enable(event.params.value);
					break;
				case chkMaxUp:
					model.SettingsLocalStore.setProp("connections",event.params.value,"useMaxUploads");
					maxUpStppr.enable(event.params.value);
					break;
				case chkMaxUpTorr:
					model.SettingsLocalStore.setProp("connections",event.params.value,"useMaxUploadsPerTorrent");
					maxUpTorrStppr.enable(event.params.value);
					break;
				case maxConnStppr:
					if(event.params)
						test = (parseInt(maxConnStppr.nti.input.text)+event.params.value);
					else
						test = parseInt(maxConnStppr.nti.input.text);
					if(test > -1){
						maxConnStppr.nti.input.text = test.toString();
						model.SettingsLocalStore.setProp("connections",test,"maxNum");
					}
					break;
				case maxConnTorrStppr:
					if(event.params)
						test = (parseInt(maxConnTorrStppr.nti.input.text)+event.params.value);
					else
						test = parseInt(maxConnTorrStppr.nti.input.text);
					if(test > -1){
						maxConnTorrStppr.nti.input.text = test.toString();
						model.SettingsLocalStore.setProp("connections",test,"maxNumPerTorrent");
					}
					break;
				case maxUpStppr:
					if(event.params)
						test = (parseInt(maxUpStppr.nti.input.text)+event.params.value);
					else
						test = parseInt(maxUpStppr.nti.input.text);
					if(test > -1){
						maxUpStppr.nti.input.text = test.toString();
						model.SettingsLocalStore.setProp("connections",test,"maxUploads");
					}
					break;
				case maxUpTorrStppr:
					if(event.params)
						test = (parseInt(maxUpTorrStppr.nti.input.text)+event.params.value);
					else
						test = parseInt(maxUpTorrStppr.nti.input.text);
					if(test > -1){
						maxUpTorrStppr.nti.input.text = test.toString();
						model.SettingsLocalStore.setProp("connections",test,"maxUploadsPerTorrent");
					}
					break;
			}
		}
		public function showFields(_b:Boolean):void {
			portStppr.nti.show(_b);
			maxConnStppr.nti.show(_b);
			maxConnTorrStppr.nti.show(_b);
			maxUpStppr.nti.show(_b);
			maxUpTorrStppr.nti.show(_b);
			proxyPortStppr.nti.show(_b);
			
			proxyHostInput.nti.show(_b);
			proxyUsernameInput.nti.show(_b);
			proxyPasswordInput.nti.show(_b);
			filterPathInput.nti.show(_b);
		}
		public function positionAllFields():void {
			portStppr.updatePosition();
			maxConnStppr.updatePosition();
			maxConnTorrStppr.updatePosition();
			maxUpStppr.updatePosition();
			maxUpTorrStppr.updatePosition();
			proxyPortStppr.updatePosition();
			
			proxyHostInput.updatePosition();
			proxyUsernameInput.updatePosition();
			proxyPasswordInput.updatePosition();
			filterPathInput.updatePosition();
			
		}
	}
}