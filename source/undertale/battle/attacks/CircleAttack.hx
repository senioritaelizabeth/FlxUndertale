package undertale.battle.attacks;

import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import undertale.physics.CircleBody;

class CircleAttack extends AttackParent
{
	static inline var OUTLINE:Int = 2;

	public function new(x:Float, y:Float, radius:Float, damage:Float = 10)
	{
		super(new CircleBody(x, y, radius), damage);
		var size = Std.int(Math.ceil(radius * 2)) + OUTLINE * 2;
		makeGraphic(size, size, FlxColor.TRANSPARENT, true);
		FlxSpriteUtil.drawCircle(this, size * 0.5, size * 0.5, radius, FlxColor.YELLOW, {thickness: OUTLINE, color: FlxColor.WHITE});
		offset.set(OUTLINE, OUTLINE);
		this.width = radius * 2;
		this.height = radius * 2;
	}
}
