package undertale.initialize;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import undertale.battle.BattleScene;
import undertale.obj.UnderText;
import undertale.overworld.OverworldScene;

using StringTools;

#if debug
enum DebugModal
{
	DisplayText(text:String);
	MoveState(text:String, nextState:Class<UnderState>);
	ArraySelection(texts:Array<String>, format:String, onDo:String->Void, currentIndex:Int);
	ContinueNormalGame();
}
#end

class LogoScene extends UnderState
{
	#if debug
	var debug_modal:Array<DebugModal> = [];
	var _textes:Array<UnderText> = [];
	#end
	var pressenter:UnderText;

	override function create()
	{
		onFocus();

		var logo = new FlxSprite();
		logo.loadGraphic(AssetsPath.image('spr_splash'));
		add(logo);
		FlxG.sound.play(AssetsPath.sound('intronoise'));
		#if debug
		debug_modal = [
			DisplayText('BounderEngine BETA - DEBUG MENU'),
			DisplayText(''),
			// MoveState('Quick Test Room', null),
			MoveState('Test Overworld', OverworldScene),
			ArraySelection(['hurt:wav', 'menu_move:wav'], 'Sound <%s> quick test', (selected:String) ->
			{
				FlxG.sound.play(AssetsPath.sound(selected.split(':')[0], selected.split(':')[1]));
			},
				0),
			ArraySelection(getRooms(), 'room <  %s  >', _teleport_to_selected_room, 0),

			MoveState('Boot Menu', MainMenuScene),

			MoveState('Test Battle', BattleScene),
			ArraySelection(getBattles(), 'battle <  %s  >', open_battle, 0),
			ContinueNormalGame
		];
		setupModals();
		#end
		pressenter = new UnderText(-320 / 2, 200, '[Press Z or ENTER to Continue]', 'hud_small');
		pressenter.alignment = 'CENTER';
		pressenter.alpha = 0.65;
		add(pressenter);
	}

	#if debug
	function getRooms()
	{
		return ['rm_test'];
	}

	function _teleport_to_selected_room(room:String)
	{
		trace('Teleporting to room: $room');
		// Implement the logic to switch to the selected room here
	}

	function getBattles()
	{
		return ['battle_test'];
	}

	function open_battle(battle:String)
	{
		trace('Opening battle: $battle');
		// Implement the logic to switch to the selected battle here
	}

	function setupModals()
	{
		var currentY = 50;

		for (modal in debug_modal)
		{
			var text_modal_button = new UnderText(0, currentY += 9, 'Unknown Text');
			// text_modal_button
			text_modal_button.outlineSize = 1;
			text_modal_button.outlineColor = FlxColor.BLACK;
			text_modal_button.scale.set(0.5, 0.5);
			text_modal_button.alignment = "CENTER";
			_textes.push(text_modal_button);
			switch (modal)
			{
				case DisplayText(text), MoveState(text, _):
					text_modal_button.text = text;
				case ArraySelection(texts, format, onDo, currentIndex):
					text_modal_button.text = format.replace("%s", texts[currentIndex]);
				case ContinueNormalGame:
					text_modal_button.text = 'Continue';

				default:
			}
			add(text_modal_button);
		}
		debugMove(1);
	}

	var _debug_selection:Int = 1;

	function debugMove(add:Int)
	{
		do
		{
			_debug_selection += add;
			if (_debug_selection >= debug_modal.length)
				_debug_selection = 0;
			else if (_debug_selection < 0)
				_debug_selection = debug_modal.length - 1;
		}
		while (!_modal_is_selectable());
		for (i in _textes)
		{
			i.color = _textes.indexOf(i) == _debug_selection ? FlxColor.YELLOW : FlxColor.WHITE;
		}

		FlxG.sound.play(AssetsPath.sound('menu_move', 'wav'));
	}

	function _modal_is_selectable()
	{
		switch (debug_modal[_debug_selection])
		{
			case DisplayText(text):
				return false;
			default:
		}
		return true;
	}
	#end

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		#if debug
		if (FlxG.keys.justPressed.UP)
			debugMove(-1);
		if (FlxG.keys.justPressed.DOWN)
			debugMove(1);

		switch (debug_modal[_debug_selection])
		{
			case DisplayText(_):
				// Do nothing
			case ArraySelection(texts, format, onDo, currentIndex):
				if (FlxG.keys.justPressed.LEFT)
				{
					currentIndex--;
					if (currentIndex < 0)
						currentIndex = texts.length - 1;
					FlxG.sound.play(AssetsPath.sound('menu_move', 'wav')).pitch = 1.2;
				}

				if (FlxG.keys.justPressed.RIGHT)
				{
					currentIndex++;
					if (currentIndex >= texts.length)
						currentIndex = 0;
					FlxG.sound.play(AssetsPath.sound('menu_move', 'wav')).pitch = 1.2;
				}
				var selectedText = texts[currentIndex];
				_textes[_debug_selection].text = format.replace("%s", selectedText);
				if (FlxG.keys.justPressed.ENTER)
				{
					onDo(selectedText);
				}
				debug_modal[_debug_selection] = ArraySelection(texts, format, onDo, currentIndex);
			case MoveState(text, nextState):
				if (FlxG.keys.justPressed.ENTER)
					FlxG.switchState(() -> Type.createInstance(nextState, []));
			default:
		}
		#end
	}
}

class ButtonWithoutBG extends FlxButton
{
	override public function draw():Void
	{
		// super.draw();

		if (_spriteLabel != null && _spriteLabel.visible)
		{
			_spriteLabel.cameras = _cameras;
			_spriteLabel.draw();
		}
	}
}
