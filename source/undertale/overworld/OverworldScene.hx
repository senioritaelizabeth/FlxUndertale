package undertale.overworld;

import flixel.FlxG;
import flixel.FlxState;
import undertale.core.AssetsPath;
import undertale.core.UnderState;
import undertale.text.Writter;

/** Overworld test room (player + test dialogue). */
class OverworldScene extends UnderState
{
	var chara:Chara;

	override public function create():Void
	{
		FlxG.sound.list.forEach(function(s)
		{
			s.destroy();
		});
		super.create();
		chara = new Chara(160, 120);
		add(chara);
		var writer = new Writter(20, 20);
		writer.typeSounds = [AssetsPath.sound("test_blip", "ogg"),];
		writer.soundEvery = 2;
		writer.onComplete = function() {};
		writer.onBlipSound = function(character) {};
		writer.shakeTextRandomly = true;
		writer.textWidth = 280;
		writer.startWithAsterisk = true;
		writer.write("[color=#FFFF00]Hola[/color] [shake]Test![/shake] [wave]Wave![/wave] [[Spamton]] asda [color=#FF0000]G E N O C I D E S\\#dasdasd asdj asd jaksdjkldj[/color] askjld asj\ndasjdasjkd asdlasdas dasldajsdljs\nYoure [color=#0000FF]BLUE[/color] now! Thats my special attack.");
		add(writer);
	}
}
