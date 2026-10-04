package undertale.battle.attacks;

import flixel.util.FlxColor;
import undertale.physics.RectangleBody;

class BulletParent extends AttackParent
{
	public function new(x:Float, y:Float, width:Float, height:Float, damage:Float = 1)
	{
		super(new RectangleBody(x, y, width, height), damage);
		makeGraphic(Std.int(width), Std.int(height), FlxColor.ORANGE, true);
		this.width = width;
		this.height = height;
	}
}
