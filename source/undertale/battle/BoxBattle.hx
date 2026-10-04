package undertale.battle;

import flixel.FlxG;
import flixel.group.FlxGroup;
import undertale.physics.ContainerBody;
import undertale.ui.Box;

/** The battle box: a `ContainerBody` plus its drawing. Assign `soul` to confine it inside. */
class BoxBattle extends FlxGroup
{
	static inline var BORDER_SIZE:Float = 6;
	static inline var DEFAULT_SIZE:Float = 130;

	public final arena:ContainerBody;
	public final box:Box;
	public var soul(default, set):DodgeHeart;
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var angle(get, set):Float;
	public var width(get, set):Float;
	public var height(get, set):Float;

	public function new(x:Float, y:Float, width:Float = DEFAULT_SIZE, height:Float = DEFAULT_SIZE)
	{
		super();
		arena = new ContainerBody(x, y, width, height);
		box = new Box(arena, BORDER_SIZE);
		add(box);
	}

	function set_soul(value:DodgeHeart):DodgeHeart
	{
		if (value != null)
			value.arena = arena;
		return soul = value;
	}

	inline function get_x():Float
	{
		return arena.x;
	}

	inline function set_x(value:Float):Float
	{
		return arena.x = value;
	}

	inline function get_y():Float
	{
		return arena.y;
	}

	inline function set_y(value:Float):Float
	{
		return arena.y = value;
	}

	inline function get_angle():Float
	{
		return arena.angle;
	}

	inline function set_angle(value:Float):Float
	{
		return arena.angle = value;
	}

	inline function get_width():Float
	{
		return arena.width;
	}

	inline function set_width(value:Float):Float
	{
		arena.setSize(value, arena.height);
		return value;
	}

	inline function get_height():Float
	{
		return arena.height;
	}

	inline function set_height(value:Float):Float
	{
		arena.setSize(arena.width, value);
		return value;
	}
}
