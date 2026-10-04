package undertale.util;


import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import undertale.core.AssetsPath;

/** "QUITTING..." overlay: hold ESC to close the game. Works in every state. */
class QuitHold extends FlxBasic
{
	static inline var HOLD_TIME:Float = 1.0; // seconds holding ESC before quitting
	static inline var FRAMES:Int = 3; // frames in the sprite sheet (horizontal strip)

	var timer:Float = 0;
	var sprite:FlxSprite;
	var overlay:FlxCamera;

	public function new()
	{
		super();
		var graphic = FlxG.bitmap.add(AssetsPath.image('spr_quittingmessage'));
		sprite = new FlxSprite(4, 4);
		sprite.loadGraphic(graphic, true, Std.int(graphic.width / FRAMES), graphic.height);
        sprite.animation.add('idle', [0, 1, 2], 12);
		sprite.antialiasing = false;
		sprite.scrollFactor.set(0, 0);
		sprite.visible = true;
		sprite.alpha = 0;
	}

	override function update(elapsed:Float):Void
	{
		// switchState removes every camera, so recreate ours when needed
		if (overlay == null || FlxG.cameras.list.indexOf(overlay) < 0)
		{
			overlay = new FlxCamera(0, 0, FlxG.width, FlxG.height);
			overlay.bgColor = FlxColor.TRANSPARENT;
			FlxG.cameras.add(overlay, false);
			sprite.cameras = [overlay];
		}

		if (FlxG.keys.pressed.ESCAPE)
			timer += elapsed;
		else
			timer = 0;

		if (timer >= HOLD_TIME)
		{
			#if sys
			Sys.exit(0);
			#end
			return;
		}
        if (FlxG.keys.justPressed.F4) 
            FlxG.fullscreen = !FlxG.fullscreen;

        sprite.alpha = Math.min(timer / HOLD_TIME, 1);
		sprite.animation.frameIndex = Std.int(Math.min(timer / HOLD_TIME * FRAMES, FRAMES - 1));
	}

	override function draw():Void
	{
		if (sprite.visible)
			sprite.draw();
	}

	override function destroy():Void
	{
		sprite.destroy();
		super.destroy();
	}
}