package {
	import flash.utils.Dictionary;
	
	import starling.text.BitmapFont;
	import starling.textures.Texture;

	public class Fonts {
		[Embed(source="../fonts/fira-regular-13.fnt", mimeType="application/octet-stream")]
		private static const FiraRegular13XML:Class;
		[Embed(source="../fonts/fira-regular-26.fnt", mimeType="application/octet-stream")]
		private static const FiraRegular26XML:Class;
		private static var fonts:Dictionary = new Dictionary();
		public static function getFont(_name:String):BitmapFont {
			if(fonts["fira-regular-13"] == undefined){
				fonts["fira-regular-13"] = XML(new FiraRegular13XML());
			}
			if(fonts["fira-regular-26"] == undefined){
				fonts["fira-regular-26"] = XML(new FiraRegular26XML());
			}
			var fntTexture:Texture = Assets.getAtlas().getTexture(_name);
			return new BitmapFont(fntTexture, fonts[_name] );
		}
		
	}
}