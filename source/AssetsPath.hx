class AssetsPath {
    public static inline var IMAGES:String = "assets/images/";
    public static inline var SOUNDS:String = "assets/sounds/";
    public static inline var FONTS:String = "assets/fonts/";

    public static function image(name:String):String {
        return IMAGES + name + ".png";
    }
    public static function sound(name:String):String {
        return SOUNDS + name + ".ogg";
    }
    public static function font(name:String):String {
        return FONTS + name + ".ttf";
    }

}