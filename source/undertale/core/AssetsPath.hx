package undertale.core;

/**
 * Builds asset paths so the rest of the code never hardcodes folders.
 * Example: `AssetsPath.image("battle/spr_dodgeheart")` -> `assets/images/battle/spr_dodgeheart.png`
 */
class AssetsPath
{
	public static inline var IMAGES:String = "assets/images/";
	public static inline var SOUNDS:String = "assets/sounds/";
	public static inline var MUSIC:String = "assets/music/";
	public static inline var FONTS:String = "assets/fonts/";

	public static function image(name:String):String
	{
		return IMAGES + name + ".png";
	}

	public static function sound(name:String, extension:String = 'ogg'):String
	{
		return SOUNDS + name + "." + extension;
	}

	public static function music(name:String):String
	{
		return MUSIC + name + ".ogg";
	}

	public static function font(name:String):String
	{
		return FONTS + name + ".ttf";
	}
}
