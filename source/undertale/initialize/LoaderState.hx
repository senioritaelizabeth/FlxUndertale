package undertale.initialize;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import undertale.core.AssetsPath;
import undertale.text.UnderText;
import undertale.util.QuitHold;

/** First state of the game: shows the splash and moves on to the intro. */
class LoaderState extends FlxState
{
	static var MIN_WAIT = 0.3;

	var spr_splash_text:FlxSprite;

	override public function create():Void
	{
		super.create();

		if (MIN_WAIT > 0)
		{
			spr_splash_text = new FlxSprite();
			spr_splash_text.loadGraphic(AssetsPath.image('spr_splash'));
			add(spr_splash_text);
			FlxG.plugins.drawOnTop = true;
			FlxG.plugins.addIfUniqueType(new QuitHold());
		}
		else
		{
			nextState();
		}
		UnderText.cleanCache();
	}

	public function nextState()
	{
		FlxG.switchState(IntroStoryScene.new);
	}

	override function update(elapsed:Float)
	{
		MIN_WAIT -= elapsed;
		if (MIN_WAIT <= 0)
		{
			nextState();
		}
	}
}
