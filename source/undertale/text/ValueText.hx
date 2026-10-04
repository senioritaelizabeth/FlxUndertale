package undertale.text;

using StringTools;

/** Text that shows a property of an object and refreshes it every frame (e.g. `Global.hp`). */
class ValueText extends UnderText
{
	public var object:Dynamic;
	public var property:String;
	public var format:String = "%s";

	public function new(x:Float, y:Float, object:Dynamic, property:String, format:String = "%s", font:String = "determination")
	{
		super(x, y, "", font);
		this.object = object;
		this.property = property;
		this.format = format;
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (object == null)
			return;
		var value = Reflect.getProperty(object, property);
		if (value != null)
			text = format.replace("%s", Std.string(value));
	}
}
