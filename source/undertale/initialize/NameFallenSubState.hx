package undertale.initialize;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import undertale.core.AssetsPath;
import undertale.core.Constants;
import undertale.initialize.NameGrid.*;
import undertale.initialize.NameRules.NameVerdict;
import undertale.text.UnderText;

private enum Phase
{
	Entry;
	Confirm;
	Departing;
}

/** Name entry screen. */
class NameFallenSubState extends FlxSubState
{
	static inline var FONT:String = "determination_sans";
	static inline var FRAMES_PER_SECOND:Float = 30;
	static inline var MAX_LENGTH:Int = 6;
	static inline var GRID_Y:Float = 75;
	static inline var CELL_HEIGHT:Float = 14;
	static inline var BLOCK_GAP:Float = 7;
	static inline var GRID_JITTER:Float = 0.5;
	static inline var MENU_Y:Float = 204;
	static inline var NAME_X:Float = 140;
	static inline var NAME_Y:Float = 52;
	static inline var TITLE_Y:Float = 20;
	static inline var MESSAGE_X:Float = 90;
	static inline var MESSAGE_Y:Float = 30;
	static inline var CHOICE_Y:Float = 200;
	static inline var CHOICE_NO_X:Float = 80;
	static inline var CHOICE_YES_X:Float = 240;
	static inline var SCREEN_CENTER:Float = 160;
	static inline var SHAKE:Float = 0.5;
	static inline var ZOOM_FRAMES:Float = 120;
	static inline var DEPARTURE_FRAMES:Float = 180;
	static inline var CYMBAL_VOLUME:Float = 0.8;
	static inline var CYMBAL_PITCH:Float = 0.95;
	static final MENU_X:Array<Float> = [65, 125, 230];
	static final MENU_LABELS:Array<String> = ["Quit", "Backspace", "Done"];

	final onNamed:String->Void;
	final existingName:String;
	final trueReset:Bool;
	final hasName:Bool;
	final grid:NameGrid = new NameGrid(MENU_X);
	final cells:Array<Array<UnderText>> = [];
	final menuTexts:Array<UnderText> = [];
	final entryTexts:Array<UnderText> = [];
	final confirmTexts:Array<UnderText> = [];

	var phase:Phase = Entry;
	var value:String = "";
	var choice:Int = 0;
	var verdict:NameVerdict;
	var zoomFrames:Float = 0;
	var departureFrames:Float = 0;
	var nameText:UnderText;
	var titleText:UnderText;
	var messageText:UnderText;
	var goBackText:UnderText;
	var noText:UnderText;
	var yesText:UnderText;
	var whiteFade:FlxSprite;

	public function new(onNamed:String->Void, ?existingName:String, trueReset:Bool = false)
	{
		super(FlxColor.BLACK);
		this.onNamed = onNamed;
		this.existingName = existingName;
		this.trueReset = trueReset;
		this.hasName = existingName != null && existingName != "";
	}

	override public function create():Void
	{
		super.create();
		buildEntry();
		buildConfirm();
		whiteFade = new FlxSprite();
		whiteFade.makeGraphic(Constants.GAME_WIDTH, Constants.GAME_HEIGHT, FlxColor.WHITE);
		whiteFade.alpha = 0;
		add(whiteFade);

		if (hasName && !trueReset && !NameRules.isHardMode(existingName))
		{
			value = existingName;
			enterConfirm();
		}
		else
			enterEntry();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (value.toLowerCase() == 'gaster')
			FlxG.switchState(IntroStoryScene.new);
		switch phase
		{
			case Entry:
				updateEntry();
			case Confirm:
				updateConfirm(elapsed);
			case Departing:
				updateDeparting(elapsed);
		}
	}

	function buildEntry():Void
	{
		titleText = label(SCREEN_CENTER, TITLE_Y, "Name the fallen human.", true);
		nameText = label(NAME_X, NAME_Y, "");
		entryTexts.push(titleText);

		for (r in 0...ROWS)
		{
			var line:Array<UnderText> = [];
			for (c in 0...COLS)
			{
				var character = grid.cellAt(r, c);
				if (character == "")
				{
					line.push(null);
					continue;
				}
				var cell = label(cellX(c), cellY(r), character);
				line.push(cell);
				entryTexts.push(cell);
			}
			cells.push(line);
		}
		for (i in 0...MENU_LABELS.length)
		{
			var option = label(MENU_X[i], MENU_Y, MENU_LABELS[i]);
			menuTexts.push(option);
			entryTexts.push(option);
		}
	}

	function buildConfirm():Void
	{
		messageText = label(MESSAGE_X, MESSAGE_Y, "");
		goBackText = label(CHOICE_NO_X, CHOICE_Y, "Go back", true);
		noText = label(CHOICE_NO_X, CHOICE_Y, "No", true);
		yesText = label(CHOICE_YES_X, CHOICE_Y, "Yes", true);
		confirmTexts.push(messageText);
		confirmTexts.push(goBackText);
		confirmTexts.push(noText);
		confirmTexts.push(yesText);
	}

	function label(x:Float, y:Float, text:String, centered:Bool = false):UnderText
	{
		var result = new UnderText(x, y, text, FONT);
		if (centered)
			result.centerAt(x);
		add(result);
		return result;
	}

	function enterEntry():Void
	{
		phase = Entry;
		grid.reset();
		resetNameTransform();
		showTexts(entryTexts, true);
		showTexts(confirmTexts, false);
		nameText.visible = true;
		refreshEntryColors();
		refreshName();
	}

	function enterConfirm():Void
	{
		phase = Confirm;
		choice = 0;
		zoomFrames = 0;
		verdict = NameRules.evaluate(value, existingName, trueReset);
		if (verdict.restart)
		{
			FlxG.resetGame();
			return;
		}
		messageText.text = verdict.message;
		showTexts(entryTexts, false);
		showTexts(confirmTexts, false);
		messageText.visible = true;
		nameText.visible = true;
		resetNameTransform();
		showChoices();
		refreshChoiceColors();
	}

	function depart():Void
	{
		phase = Departing;
		departureFrames = 0;
		showTexts(entryTexts, false);
		showTexts(confirmTexts, false);
		silenceAudio();
		var cymbal = FlxG.sound.play(AssetsPath.music("cymbal"), CYMBAL_VOLUME);
		#if FLX_PITCH
		cymbal.pitch = CYMBAL_PITCH;
		#end
	}

	function updateEntry():Void
	{
		jitterGrid();
		grid.navigate(FlxG.keys.justPressed.RIGHT, FlxG.keys.justPressed.LEFT, FlxG.keys.justPressed.DOWN, FlxG.keys.justPressed.UP);
		refreshEntryColors();

		if (confirmPressed())
			chooseCurrent();
		if (cancelPressed())
			backspace();
	}

	function updateConfirm(elapsed:Float):Void
	{
		if (confirmPressed())
		{
			if (verdict.allow && choice == 1 && value.length > 0)
			{
				depart();
				return;
			}
			if (choice == 0)
			{
				if (hasName && !trueReset)
					close();
				else
					enterEntry();
				return;
			}
		}
		animateName(elapsed);
		showChoices();
		if (verdict.allow && (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.LEFT))
		{
			choice = choice == 1 ? 0 : 1;
			refreshChoiceColors();
		}
	}

	function updateDeparting(elapsed:Float):Void
	{
		departureFrames += elapsed * FRAMES_PER_SECOND;
		whiteFade.alpha = Math.min(1, departureFrames / DEPARTURE_FRAMES);
		animateName(elapsed);
		if (departureFrames > DEPARTURE_FRAMES - 1)
		{
			onNamed(value);
			close();
		}
	}

	function chooseCurrent():Void
	{
		if (grid.row == MENU_ROW)
		{
			switch grid.col
			{
				case 0:
					close();
				case 1:
					backspace();
				default:
					if (value.length > 0)
					{
						enterConfirm();
					}
			}
			return;
		}
		if (value.length >= MAX_LENGTH)
			value = value.substr(0, MAX_LENGTH - 1);
		value += grid.selectedCharacter();
		refreshName();
	}

	function backspace():Void
	{
		if (value.length > 0)
			value = value.substr(0, value.length - 1);
		refreshName();
	}

	function jitterGrid():Void
	{
		for (r in 0...ROWS)
			for (c in 0...COLS)
			{
				var cell = cells[r][c];
				if (cell == null)
					continue;
				cell.x = cellX(c) + FlxG.random.float(0, GRID_JITTER);
				cell.y = cellY(r) + FlxG.random.float(0, GRID_JITTER);
			}
	}

	function animateName(elapsed:Float):Void
	{
		zoomFrames = Math.min(ZOOM_FRAMES, zoomFrames + elapsed * FRAMES_PER_SECOND);
		var size = 1 + zoomFrames / 50;
		nameText.scale.set(size, size);
		nameText.angle = FlxG.random.float(-SHAKE * zoomFrames / 60, SHAKE * zoomFrames / 60);
		nameText.x = NAME_X - zoomFrames / 3 + FlxG.random.float(0, SHAKE * 2);
		nameText.y = zoomFrames / 2 + NAME_Y + FlxG.random.float(0, SHAKE * 2);
	}

	function resetNameTransform():Void
	{
		zoomFrames = 0;
		nameText.scale.set(1, 1);
		nameText.angle = 0;
		nameText.x = NAME_X;
		nameText.y = NAME_Y;
	}

	function showChoices():Void
	{
		goBackText.visible = !verdict.allow;
		noText.visible = verdict.allow;
		yesText.visible = verdict.allow;
	}

	function refreshName():Void
	{
		nameText.text = value;
	}

	function refreshEntryColors():Void
	{
		for (r in 0...ROWS)
			for (c in 0...COLS)
			{
				var cell = cells[r][c];
				if (cell != null)
					cell.color = grid.row == r && grid.col == c ? FlxColor.YELLOW : FlxColor.WHITE;
			}
		for (i in 0...menuTexts.length)
			menuTexts[i].color = grid.row == MENU_ROW && grid.col == i ? FlxColor.YELLOW : FlxColor.WHITE;
	}

	function refreshChoiceColors():Void
	{
		goBackText.color = FlxColor.YELLOW;
		noText.color = choice == 0 ? FlxColor.YELLOW : FlxColor.WHITE;
		yesText.color = choice == 1 ? FlxColor.YELLOW : FlxColor.WHITE;
	}

	function showTexts(texts:Array<UnderText>, shown:Bool):Void
	{
		for (text in texts)
			text.visible = shown;
	}

	function silenceAudio():Void
	{
		FlxG.sound.list.forEach(function(sound) sound.stop());
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
	}

	inline function confirmPressed():Bool
	{
		return FlxG.keys.justPressed.Z || FlxG.keys.justPressed.ENTER;
	}

	inline function cancelPressed():Bool
	{
		return FlxG.keys.justPressed.X || FlxG.keys.justPressed.SHIFT;
	}

	static inline function cellY(rowIndex:Int):Float
	{
		return GRID_Y + rowIndex * CELL_HEIGHT + (rowIndex >= BLOCK_ROWS ? BLOCK_GAP : 0);
	}
}
