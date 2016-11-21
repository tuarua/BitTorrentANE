package {
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	
	public class StarlingVideo extends Sprite{
		private var ns:NetStream;
		private var nc:NetConnection;
		private var vidClient:Object;
		
		private var videoTexture:Texture;
		private var videoImage:Image;

		public function StarlingVideo() {
			super();
		}
		public function loadVideo(_uri:String):void {
			vidClient = new Object();
			vidClient.onMetaData = onMetaData;
			nc = new NetConnection();
			
			nc.connect(null);
			ns = new NetStream(nc);
			ns.addEventListener( NetStatusEvent.NET_STATUS, onNetStatus );
			ns.client = vidClient;
			
			videoTexture = Texture.fromNetStream(this.ns, Starling.current.contentScaleFactor, onTextureComplete);
			

			ns.play(_uri);
			
		}
		protected function onTextureComplete():void {videoImage = new Image(videoTexture);
			videoImage.blendMode = BlendMode.NONE;
			videoImage.touchable = false;
			videoImage.width = 1280;
			videoImage.height = 720;
			
			videoImage.x = (Starling.current.viewPort.width - 1280)/2;
			
			if(videoTexture.nativeWidth == 1280)
				videoImage.textureSmoothing = TextureSmoothing.NONE;
			else
				videoImage.textureSmoothing = TextureSmoothing.BILINEAR;
			
			if(!this.contains(videoImage))
				this.addChildAt(videoImage,0);
			
		}
		
		private function onMetaData(metadata:Object):void {
		}
		protected function onNetStatus(event:NetStatusEvent):void {
			trace(event.info.code);
			if(event.info.code == "NetStream.Play.Stop")
				Starling.current.skipUnchangedFrames = true;
		}
	}
}


