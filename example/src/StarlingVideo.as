package
{
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.VideoTexture;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.VideoTextureEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.ConcreteTexture;
	
	public class StarlingVideo extends Sprite{
		private var ns:NetStream;
		private var nc:NetConnection;
		private var vidClient:Object;
		
		private var vTexture:VideoTexture;
		
		private var stage3D:Stage3D;
		private var cTexture:ConcreteTexture;
		private var image:Image;
		private var context3D:Context3D;
		public function StarlingVideo() {
			super();
		}
		public function loadVideo(_uri:String):void {
			context3D = Starling.context;
			vidClient = new Object();
			vidClient.onMetaData = onMetaData;
			nc = new NetConnection();
			
			nc.connect(null);
			ns = new NetStream(nc);
			ns.addEventListener( NetStatusEvent.NET_STATUS, onNetStatus );
			ns.client = vidClient;
			ns.play(_uri);
			
			vTexture = context3D.createVideoTexture();
			vTexture.attachNetStream(ns);
			vTexture.addEventListener( VideoTextureEvent.RENDER_STATE, renderFrame);
		}
		protected function renderFrame(event:VideoTextureEvent):void {
			if(event.status == "accelerated"){
				cTexture = new ConcreteTexture(vTexture, Context3DTextureFormat.BGRA, 1280, 730, false, true, true);
				image = new Image(cTexture);
				addChild(image);
			}else{
				trace("no hardward acceleration. Video will not play. Close any other video apps and web browsers. Adobe are aware of the issue.");
			}
		}
		private function onMetaData(metadata:Object):void {
		}
		protected function onNetStatus(event:NetStatusEvent):void {
			trace(event.info.code);
		}
	}
}


