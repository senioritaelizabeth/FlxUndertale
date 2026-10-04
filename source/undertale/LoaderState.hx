package undertale;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import undertale.initialize.IntroStoryScene;
import undertale.obj.UnderText;
import undertale.overworld.OverworldScene;

class LoaderState extends FlxState
{
	static var MIN_WAIT = 0.3;

	var spr_splash_text:FlxSprite;

	override public function create():Void
	{
		super.create();
		spr_splash_text = new FlxSprite();
		spr_splash_text.loadGraphic(AssetsPath.image('spr_splash'));
		add(spr_splash_text);
		UnderText.cleanCache();

		trace("Loader State Created");
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
