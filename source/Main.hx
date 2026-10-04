package;

import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;
import openfl.events.Event;
import undertale.core.Constants;
import undertale.initialize.LoaderState;

class Main extends Sprite
{
	public function new()
	{
		super();

		addChild(new FlxGame(Constants.GAME_WIDTH, Constants.GAME_HEIGHT, LoaderState, 30, 30, true));
	
	}


}
