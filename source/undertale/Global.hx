package undertale;

class Global
{
	public static var hp:Float = 20;
	public static var maxHp:Float = 20;

	public static var lv:Float = 1;
	public static var exp:Float = 0;
	public static var name:String = "CHARA";
	public static var gold:Float = 0;

	public static var soulx:Float = 0;
	public static var souly:Float = 0;

	public static var savfileExists:Bool = false;
	public static var sav_lv:Float = 1;
	public static var sav_time:Float = 0;
	public static var sav_roomname:String = "Unknown Room";
	public static var sav_charaname:String = "CHARA";
	public static var fun:Int = 0;
	public static var hardMode:Bool = false;
	public static var flags:Map<String, Bool> = new Map<String, Bool>();
}
