package undertale.battle;

import flixel.FlxSprite;
import undertale.physics.PhysicsBody;

class AttackParent extends FlxSprite
{
	public final body:PhysicsBody;
	public var damage:Float;

	public function new(body:PhysicsBody, damage:Float = 20)
	{
		super(body.x, body.y);
		this.body = body;
		this.damage = damage;
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		syncBody();
	}

	public function syncBody():Void
	{
		body.x = x;
		body.y = y;
		body.angle = angle;
	}

	public function isDangerous():Bool
	{
		return exists && active && damage > 0;
	}
}
