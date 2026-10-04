package undertale.initialize;

typedef NameVerdict =
{
	message:String,
	allow:Bool,
	restart:Bool
}

class NameRules
{
	public static inline var CORRECT:String = "Is this name correct?";
	public static inline var EMPTY:String = "You must choose a name.";
	public static inline var HARD_MODE:String = "WARNING: This name will#make your life hell.#Proceed anyway?";
	public static inline var ALREADY_CHOSEN:String = "A name has already#been chosen.";
	static inline var HARD_MODE_NAME:String = "frisk";

	static final special:Map<String, NameVerdict> = buildSpecial();

	public static function isHardMode(name:String):Bool
	{
		return name != null && name.toLowerCase() == HARD_MODE_NAME;
	}

	public static function evaluate(name:String, existingName:String, trueReset:Bool):NameVerdict
	{
		if (name == null || name == "")
			return verdict(EMPTY, false);
		if (isHardMode(name))
			return verdict(HARD_MODE, true);
		var hasName = existingName != null && existingName != "";
		if (hasName && !trueReset && !isHardMode(existingName))
			return verdict(ALREADY_CHOSEN, true);
		var found = special.get(name.toLowerCase());
		return found != null ? found : verdict(CORRECT, true);
	}

	static function verdict(message:String, allow:Bool, restart:Bool = false):NameVerdict
	{
		return {message: message, allow: allow, restart: restart};
	}

	static function buildSpecial():Map<String, NameVerdict>
	{
		var map = new Map<String, NameVerdict>();
		function add(names:Array<String>, message:String, allow:Bool, restart:Bool = false):Void
		{
			for (name in names)
				map.set(name, verdict(message, allow, restart));
		}
		add(["aaaaaa"], "Not very creative...?", true);
		add(["asgore"], "You cannot.", false);
		add(["toriel"], "I think you should#think of your own#name, my child.", false);
		add(["sans"], "nope.", false);
		add(["undyne"], "Get your OWN name!", false);
		add(["flowey"], "I already CHOSE#that name.", false);
		add(["chara"], "The true name.", true);
		add(["alphys"], "D-don't do that.", false);
		add(["alphy"], "Uh... OK?", true);
		add(["papyru"], "I'LL ALLOW IT!!!!", true);
		add(["napsta", "blooky"], "...........#(They're powerless to#stop you.)", true);
		add(["murder", "mercy"], "That's a little on-#the nose, isn't it...?", true);
		add(["asriel"], "...", false);
		add(["catty"], "Bratty! Bratty!#That's MY name!", true);
		add(["bratty"], "Like, OK I guess.", true);
		add(["mtt", "metta", "mett"], "OOOOH!!! ARE YOU#PROMOTING MY BRAND?", true);
		add(["gerson"], "Wah ha ha! Why not?", true);
		add(["shyren"], "...?", true);
		add(["aaron"], "Is this name correct? ; )", true);
		add(["temmie"], "hOI!", true);
		add(["woshua"], "Clean name.", true);
		add(["jerry"], "Jerry.", true);
		add(["bpants"], "You are really scraping the#bottom of the barrel.", true);
		add(["gaster"], CORRECT, true, true);
		return map;
	}
}
