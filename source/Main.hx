package;

import flixel.FlxGame;
import openfl.display.Sprite;
import undertale.Constants;
import undertale.LoaderState;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(Constants.GAME_WIDTH, Constants.GAME_HEIGHT, LoaderState, 30, 30, true));
	}
}
