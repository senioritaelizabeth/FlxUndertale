package undertale.overworld;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import undertale.core.AssetsPath;

/** Player character in the overworld. Moves with arrow keys or WASD. */
class Chara extends FlxSprite
{
	public final SPEED = 100;

	var move_direction:String = "down";
	var directional_speed:FlxPoint = new FlxPoint(0, 0);

	public function new(X:Float, Y:Float)
	{
		super(X, Y);
		loadGraphic(AssetsPath.image('spr_mainchara'), true, 20, 30);
		pushAnimation('u idle', [1], 0, false);
		pushAnimation('u walk', [1, 0, 1, 2], 3, true);
		pushAnimation('d idle', [3], 0, false);
		pushAnimation('d walk', [3, 4, 3, 5], 3, true);
		pushAnimation('l idle', [6], 0, false);
		pushAnimation('l walk', [6, 7], 3, true);
		pushAnimation('r idle', [8], 0, false);
		pushAnimation('r walk', [8, 9], 3, true);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		move();
	}

	// for now its hardcoded to arrow keys and WASD
	public function move()
	{
		directional_speed.set(0, 0);
		if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.A)
		{
			directional_speed.x = -SPEED;
			move_direction = "left";
		}
		else if (FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D)
		{
			directional_speed.x = SPEED;
			move_direction = "right";
		}
		if (FlxG.keys.pressed.UP || FlxG.keys.pressed.W)
		{
			directional_speed.y = -SPEED;
			move_direction = "up";
		}
		else if (FlxG.keys.pressed.DOWN || FlxG.keys.pressed.S)
		{
			directional_speed.y = SPEED;
			move_direction = "down";
		}
		velocity.set(directional_speed.x, directional_speed.y);
		if (velocity.x == 0 && velocity.y == 0)
		{
			play(move_direction.charAt(0) + " idle");
		}
		else
		{
			play(move_direction.charAt(0) + " walk", 1);
		}
	}

	function play(name:String, frame_index:Int = 0):Void
	{
		if (animation.curAnim == null || animation.curAnim.name != name)
		{
			animation.play(name, true, false, frame_index);
		}
	}

	function pushAnimation(name:String, frames:Array<Int>, frameRate:Int = 3, looped:Bool = false):Void
	{
		animation.add(name, frames, frameRate, looped);
	}
}
