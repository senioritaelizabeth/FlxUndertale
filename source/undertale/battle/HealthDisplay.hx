package undertale.battle;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import undertale.obj.UnderText;
import undertale.obj.ValueText;

class HealthDisplay extends FlxTypedGroup<FlxObject>
{
	var hp_sprite:FlxSprite;

	var hp_bar:FlxSprite;
	var hp_bar_fill:FlxSprite;
	var hp_text:UnderText;
	var x = 0.0;
	var y = 0.0;

	public function new()
	{
		super();
		x = 40;
		y = -240 / 2;

		var interfaceY = 180;
		var namex = x + 15;

		var nametxt = new UnderText(namex, interfaceY - 6, Global.name, 'hud');
		add(nametxt);
		var lvtxt = new UnderText(namex + nametxt.measuredWidth + 20, interfaceY - 6, 'LV ' + Std.string(Std.int(Global.lv)), 'hud');
		add(lvtxt);
		hp_bar = new FlxSprite(x + 275 - 10, interfaceY);
		hp_bar.makeGraphic(1, 20, 0xFFFF0000);
		hp_bar.origin.x = 0;

		add(hp_bar);
		hp_bar_fill = new FlxSprite(x + 275 - 10, interfaceY);
		hp_bar_fill.makeGraphic(1, 20, 0xFFFFFF00);
		hp_bar_fill.origin.x = 0;
		add(hp_bar_fill);
		hp_sprite = new FlxSprite(x + 220, interfaceY);
		hp_sprite.loadGraphic(AssetsPath.image('battle/spr_hpname'));
		add(hp_sprite);
		hp_text = new UnderText(x + 290, interfaceY - 6, '20 / 20', 'hud');
		add(hp_text);
		update(0);
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		hp_bar_fill.scale.x = (Global.hp * 1.2);
		hp_bar.scale.x = (Global.maxHp * 1.2);
		hp_text.text = formatHpText();
		hp_text.x = x + 290 + (Global.maxHp * 1.2);
	}

	function formatHpText():String
	{
		var hpwrite = Std.string(Std.int(Global.hp));
		if (Global.hp < 10)
		{
			hpwrite = '0' + hpwrite;
		}
		var maxhpwrite = Std.string(Std.int(Global.maxHp));
		if (Global.maxHp < 10)
		{
			maxhpwrite = '0' + maxhpwrite;
		}
		return hpwrite + ' / ' + maxhpwrite;
	}

	function setupText(x:Float, y:Float, fnt = 'hud_small')
	{
		var undertext = new UnderText(x, y, '', fnt);
		add(undertext);
		return undertext;
	}
}
