package undertale.battle;

import flixel.FlxG;
import flixel.FlxSprite;
import undertale.core.AssetsPath;

/** Piece of the broken soul. Mimics GameMaker physics: speed and gravity are per step, 30 steps per second. */
class HeartShard extends FlxSprite
{
	static inline var STEP:Float = 1 / 30;

	var hspeed:Float;
	var vspeed:Float;
	var gravity:Float = 0.2;
	var gravityDir:Float = 270;
	var acc:Float = 0;

	public function new(x:Float, y:Float)
	{
		super(x, y);
		loadGraphic(AssetsPath.image('battle/spr_heartshard'), true, 10, 10);
		animation.add('idle', [0, 1, 2, 3], 7.5);
		animation.play('idle');
		antialiasing = false;

		var direction = FlxG.random.float(0, 360);
		var speed = 7;
		hspeed = speed * Math.cos(direction * Math.PI / 180);
		vspeed = -speed * Math.sin(direction * Math.PI / 180);
		scale.set(0.5, 0.5);
	}

	override function update(elapsed:Float)
	{
		acc += elapsed;
		while (acc >= STEP)
		{
			acc -= STEP;
			hspeed += gravity * Math.cos(gravityDir * Math.PI / 180);
			vspeed += -gravity * Math.sin(gravityDir * Math.PI / 180);
			x += hspeed;
			y += vspeed;
		}
		super.update(elapsed);
	}
}
