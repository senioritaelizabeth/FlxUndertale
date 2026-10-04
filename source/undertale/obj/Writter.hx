package undertale.obj;

import flixel.FlxG;

class Writter extends UnderText
{
	static inline var FRAMES_PER_SECOND:Float = 30;
	static inline var SPACE_CODE:Int = 32;

	public var charsPerSecond:Float = 30;
	public var soundEnabled:Bool = true;
	public var soundEvery:Int = 2;
	public var typeSounds:Array<String> = [];
	public var onComplete:Void->Void;
	public var onBlipSound:Int->Void;
	public var shakeTextRandomly:Bool = false;
	public var isWriting(get, never):Bool;

	var writeTimer:Float = 0;
	var shown:Int = 0;
	var blipCounter:Int = 0;
	var pauseLeft:Float = 0;
	var writing:Bool = false;
	var completeCalled:Bool = false;
	var randomShakeTimer:Float = 0;
	var randomShakeDuration:Float = 0;

	public function new(x:Float = 0, y:Float = 0, text:String = "", font:String = "determination")
	{
		super(x, y, text, font);
		charsVisibles = 0;
		if (text != "")
			start();
	}

	public function write(value:String):Void
	{
		text = value;
		start();
	}

	public function start():Void
	{
		shown = 0;
		blipCounter = 0;
		writeTimer = 0;
		completeCalled = false;
		charsVisibles = 0;
		pauseLeft = pauseFramesAt(0) / FRAMES_PER_SECOND;
		writing = true;
		if (totalCharacters == 0)
			finish();
	}

	public function finish():Void
	{
		charsVisibles = -1;
		shown = totalCharacters;
		writing = false;
		pauseLeft = 0;
		complete();
	}

	public function skip():Void
	{
		if (writing)
			finish();
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		updateRandomShake(elapsed);
		if (!writing)
			return;
		if (charsPerSecond <= 0)
		{
			finish();
			return;
		}
		if (pauseLeft > 0)
		{
			pauseLeft -= elapsed;
			return;
		}

		writeTimer += elapsed * charsPerSecond;
		while (writeTimer >= 1 && writing && pauseLeft <= 0)
		{
			writeTimer -= 1;
			shown++;
			charsVisibles = shown;
			blip(visibleCodeAt(shown - 1));
			pauseLeft = pauseFramesAt(shown) / FRAMES_PER_SECOND;
			if (shown >= totalCharacters)
			{
				writing = false;
				charsVisibles = -1;
				complete();
			}
		}
	}

	function updateRandomShake(elapsed:Float):Void
	{
		if (!shakeTextRandomly)
			return;
		randomShakeTimer += elapsed;
		randomShakeDuration -= elapsed;
		if (randomShakeDuration <= 0 && transientShakeCharacter >= 0)
		{
			transientShakeCharacter = -1;
			rebuild();
		}
		if (randomShakeTimer >= 1 + Math.random() * 0.5)
		{
			randomShakeTimer = 0;
			transientShakeCharacter = Std.random(Std.int(Math.max(1, totalCharacters)));
			randomShakeDuration = 0.15;
			rebuild();
		}
	}

	function blip(code:Int):Void
	{
		if (!soundEnabled || soundEvery <= 0 || code == SPACE_CODE || code < 0)
			return;
		blipCounter++;
		if (blipCounter % soundEvery != 0)
			return;
		if (typeSounds.length > 0)
			FlxG.sound.play(typeSounds[Std.int(blipCounter / soundEvery) % typeSounds.length]);
		if (onBlipSound != null)
			onBlipSound(shown);
	}

	function complete():Void
	{
		if (completeCalled)
			return;
		completeCalled = true;
		if (onComplete != null)
			onComplete();
	}

	inline function get_isWriting():Bool
	{
		return writing;
	}
}
