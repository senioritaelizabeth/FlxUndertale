package undertale.initialize;

import flixel.FlxG;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import undertale.UnderState;
import undertale.overworld.OverworldScene;

class IntroStoryScene extends UnderState
{
	public var mus:FlxSound;

	override function create()
	{
		mus = FlxG.sound.load(AssetsPath.music('story'), 1.0, true);
		mus.play();
		mus.pitch = 0.91;

		var text = new FlxText();
		text.text = 'Unimplemented.';
		add(text);
	}

	private function nextState()
	{
		FlxG.switchState(LogoScene.new);
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ENTER)
		{
			mus.fadeOut(0.05 * 30);
			camera.fade(FlxColor.BLACK, 0.05 * 30, () -> nextState(), true);
		}
	}
}
