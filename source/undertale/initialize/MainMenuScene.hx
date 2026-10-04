package undertale.initialize;

import flixel.FlxG;
import flixel.sound.FlxSound;
import flixel.util.FlxColor;
import haxe.ds.Vector;
import undertale.obj.UnderText;
import undertale.overworld.OverworldScene;

enum MenuModal
{
	BeginGame();
	Settings();
	Reset();
}

enum MenuOrder
{
	Center();
	Left();
}

class MainMenuScene extends UnderState
{
	// TODO: multiple lang support
	static inline var SCREEN_CENTER:Float = 160;
	static inline var NAME_X:Float = 70;
	static inline var NAME_Y:Float = 66;
	static inline var MENU_Y:Float = 109;
	static inline var CONTINUE_X:Float = 85;
	static inline var RESET_X:Float = 195;
	static inline var RESET_TRUE_X:Float = 175;
	static inline var SETTINGS_X:Float = 120;

	var music:FlxSound;
	var gray_color:FlxColor = 12632256;
	var gray_color_dark:FlxColor = 8421504;
	var menu_options:Array<Array<MenuModal>> = [[MenuModal.BeginGame], [MenuModal.Settings],];
	var selection:Vector<Int> = new Vector<Int>(2);
	var menu_texts:Array<Array<UnderText>> = [];

	var menu_order:MenuOrder = MenuOrder.Left;

	static inline var SELECTED_COLOR:FlxColor = FlxColor.YELLOW;
	static inline var NORMAL_COLOR:FlxColor = FlxColor.WHITE;

	override function create()
	{
		super.create();
		selection.set(0, 0);
		selection.set(1, 0);
		music = FlxG.sound.play(AssetsPath.music('menu0'), 1, true);

		if (Global.savfileExists)
		{
			menu_options = [[MenuModal.BeginGame, MenuModal.Reset], [MenuModal.Settings],];
			var time_minutes = Math.floor(Global.sav_time / 60);
			var time_seconds = Math.floor(Global.sav_time % 60);
			var name = Global.sav_charaname.substr(0, 6);
			var lvtext = 'LV ${Global.sav_lv}';
			var timetxt = '${time_minutes}:${(time_seconds < 10) ? "0" + time_seconds : Std.string(time_seconds)}';
			var name_obj = new UnderText(NAME_X, NAME_Y, name, 'determination_sans');
			var lv_obj = new UnderText(0, NAME_Y, lvtext, 'determination_sans');
			var time_obj = new UnderText(250, NAME_Y, timetxt, 'determination_sans');
			var x_center = SCREEN_CENTER;
			lv_obj.x = Math.round((x_center + name_obj.measuredWidth * 0.5) - (time_obj.measuredWidth * 0.5) - (lv_obj.measuredWidth * 0.5));
			time_obj.x -= time_obj.measuredWidth;
			add(name_obj);
			add(lv_obj);
			add(time_obj);
			add(new UnderText(NAME_X, NAME_Y + 18, Global.sav_roomname, 'determination_sans'));
			menu_order = MenuOrder.Center;
		}
		else
		{
			var ins_text = new UnderText(85, 20, '--- Instruction ---', 'determination_sans');
			ins_text.color = gray_color;
			var textes = [
				'[Z or ENTER] - Confirm',
				'[X or SHIFT] - Cancel',
				'[C or CTRL] - Menu (In-game)'
			];
			#if desktop
			textes.push('[F4] - Fullscreen');
			textes.push('[Hold ESC] - Quit');
			#end
			for (i in 0...textes.length)
			{
				var text = new UnderText(85, (50 + i * 18), textes[i], 'determination_sans');
				text.color = gray_color;
				add(text);
			}
			var hp_text = new UnderText(85, #if desktop 140 #else 130 #end, 'When HP is 0, you lose.', 'determination_sans');
			hp_text.color = gray_color;
			add(hp_text);
			#if (debug && desktop)
			var debug_text = new UnderText(85, 158, '[F1-F8] - Debug Menus', 'determination_sans');
			debug_text.color = gray_color;
			add(debug_text);
			#end
			add(ins_text);
		}
		var version_text = new UnderText(-320 / 2, 240 - 8, '${Constants.GAME_NAME} v${Constants.GAME_VERSION} (c) ${Constants.GAME_COPYRIGHT}', 'hud_small');
		version_text.alignment = 'CENTER';
		version_text.color = gray_color_dark;
		add(version_text);

		setupOptions();
		updateOptionColors();
	}

	function move(xAdd:Int, yAdd:Int)
	{
		var currentX = selection.get(0);
		var currentY = selection.get(1);
		if (xAdd != 0 && menu_options[currentY].length > 1)
			currentX = currentX == 0 ? 1 : 0;
		if (yAdd > 0 && currentY < menu_options.length - 1)
		{
			currentY++;
			currentX = 0;
		}
		else if (yAdd < 0 && currentY > 0)
		{
			currentY--;
			currentX = 0;
		}
		selection.set(0, currentX);
		selection.set(1, currentY);
		updateOptionColors();
	}

	function updateOptionColors():Void
	{
		var selectedX = selection.get(0);
		var selectedY = selection.get(1);
		for (y in 0...menu_texts.length)
		{
			for (x in 0...menu_texts[y].length)
			{
				menu_texts[y][x].color = (x == selectedX && y == selectedY) ? SELECTED_COLOR : NORMAL_COLOR;
			}
		}
	}

	public function beginGame(newgame:Bool = false, ?name:String):Void
	{
		if (newgame)
		{
			if (name != null && name.length > 0)
				Global.sav_charaname = name.substr(0, 6);
			Global.fun = FlxG.random.int(1, 100);
			Global.hardMode = NameRules.isHardMode(Global.sav_charaname);
			Global.sav_time = 0;
		}
		FlxG.switchState(OverworldScene.new);
	}

	function startNewGame():Void
	{
		if (Constants.NEED_CHARA_GET_NEW_NAME)
			openSubState(new NameFallenSubState(function(name) beginGame(true, name)));
		else
			beginGame(true, Global.sav_charaname);
	}

	function resetGame():Void
	{
		var trueReset = Global.flags['truereset'] == true;
		if (Constants.NEED_CHARA_GET_NEW_NAME)
			openSubState(new NameFallenSubState(function(name) beginGame(true, name), Global.sav_charaname, trueReset));
		else
			beginGame(true, Global.sav_charaname);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.keys.justPressed.Z || FlxG.keys.justPressed.ENTER)
		{
			var currentX = selection.get(0);
			var currentY = selection.get(1);
			var selectedOption = menu_options[currentY][currentX];
			switch (selectedOption)
			{
				case MenuModal.BeginGame:
					if (Global.savfileExists)
						beginGame();
					else
						startNewGame();
				case MenuModal.Settings:
				case MenuModal.Reset:
					resetGame();
			}
		}
		else if (FlxG.keys.justPressed.X || FlxG.keys.justPressed.SHIFT) {}
		else if (FlxG.keys.justPressed.UP)
		{
			move(0, -1);
		}
		else if (FlxG.keys.justPressed.DOWN)
		{
			move(0, 1);
		}
		else if (FlxG.keys.justPressed.LEFT)
		{
			move(-1, 0);
		}
		else if (FlxG.keys.justPressed.RIGHT)
		{
			move(1, 0);
		}
	}

	function setupOptions()
	{
		var xPos = CONTINUE_X;
		var yPos = 160.0;
		#if desktop
		yPos += 12.0;
		#end
		if (menu_order == MenuOrder.Center)
		{
			yPos = MENU_Y;
		}
		for (x in menu_options)
		{
			var rowTexts:Array<UnderText> = [];
			for (i in 0...x.length)
			{
				var option = x[i];
				var text = '';
				switch (option)
				{
					case MenuModal.BeginGame:
						text = Global.savfileExists ? 'Continue' : 'Begin Game';
					case MenuModal.Settings:
						text = 'Settings';
					case MenuModal.Reset:
						text = 'Reset';
						if (Global.flags['truereset'] == true)
							text = 'True Reset';
				}
				rowTexts.push(new UnderText(xPos, yPos, text, 'determination_sans'));
			}
			var rowWidth = 0.0;
			for (rowText in rowTexts)
				rowWidth += rowText.measuredWidth;
			var sep = 60;
			if (menu_order == MenuOrder.Center && rowTexts.length > 1)
				rowWidth += sep * (rowTexts.length - 1);

			for (i in 0...rowTexts.length)
			{
				var option_text = rowTexts[i];
				if (menu_order == MenuOrder.Center)
				{
					if (rowTexts.length > 1)
					{
						switch (x[i])
						{
							case MenuModal.BeginGame:
								option_text.x = CONTINUE_X;
							case MenuModal.Reset:
								option_text.x = Global.flags['truereset'] == true ? RESET_TRUE_X : RESET_X;
							default:
						}
					}
					if (rowTexts.length <= 1)
						option_text.x = SCREEN_CENTER - option_text.measuredWidth * 0.5;
				}
				else
				{
					yPos += 20;
				}
				add(option_text);
			}
			menu_texts.push(rowTexts);
			if (menu_order == MenuOrder.Center)
			{
				yPos += 20;
			}
		}
	}
}
