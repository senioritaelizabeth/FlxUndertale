package undertale.battle;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import undertale.battle.attacks.AttackParent;
import undertale.core.AssetsPath;
import undertale.core.Global;
import undertale.physics.CircleBody;
import undertale.physics.ContainerBody;
import undertale.physics.GravityMotion;
import undertale.physics.RectangleBody;

enum SoulState
{
	Red;
	Yellow;
	Blue;
}

/** The player soul. Red/Yellow move freely, Blue uses gravity. In debug builds, press 9 to take damage. */
class DodgeHeart extends FlxSprite
{
	public static inline var SPEED:Float = 100;
	static inline var SPRITE_SIZE:Int = 20;
	static inline var HURTBOX_SIZE:Float = 10;
	static inline var GRAVITY:Float = 260;
	static inline var JUMP_SPEED:Float = 150;
	static inline var JUMP_CUT_SPEED:Float = 45;
	static inline var INVULNERABLE_TIME:Float = 0.99;

	public final body:CircleBody;
	public final hurtbox:RectangleBody;
	public var arena:ContainerBody;
	public var gravityAngle(get, set):Float;
	public var state(default, set):SoulState = Red;
	public var grounded(get, never):Bool;

	final gravityMotion:GravityMotion = new GravityMotion(GRAVITY, JUMP_SPEED, JUMP_CUT_SPEED);
	var hurtTimer:Float = 0;

	public function new(x:Float, y:Float)
	{
		super(x, y);
		loadGraphic(AssetsPath.image('battle/spr_dodgeheart'), true, SPRITE_SIZE, SPRITE_SIZE);
		animation.add('idle', [0]);
		animation.add('hurt', [1, 0], 12);
		animation.play('idle');
		moves = false;
		body = new CircleBody(x, y, SPRITE_SIZE * 0.5);
		hurtbox = new RectangleBody(x, y, HURTBOX_SIZE, HURTBOX_SIZE);
		state = Blue;
		syncTransform();
	}

	override function update(elapsed:Float):Void
	{
		if (state == Blue && arena != null)
			updateBlue(elapsed);
		else
			updateFree(elapsed);
		syncTransform();
		super.update(elapsed);
		updateHurtAnimation(elapsed);

	}

	public function setCenter(centerX:Float, centerY:Float):Void
	{
		body.setCenter(centerX, centerY);
		gravityMotion.reset();
		syncTransform();
	}

	public function getHurt(damage:Float):Void
	{
		if (hurtTimer > 0)
			return;
		FlxG.sound.play(AssetsPath.sound('hurt', 'wav'));
		Global.hp -= damage;
		hurtTimer = INVULNERABLE_TIME;
	}

	public function attackCollided(attack:AttackParent):Void
	{
		if (attack != null && attack.isDangerous() && hurtbox.overlaps(attack.body))
			getHurt(attack.damage);
	}

	function updateFree(elapsed:Float):Void
	{
		body.velocityX = horizontalAxis() * SPEED;
		body.velocityY = verticalAxis() * SPEED;
		body.step(elapsed);
		if (arena != null)
			arena.confine(body, body.radius);
		body.grounded = false;
	}

	function updateBlue(elapsed:Float):Void
	{
		var jumpHeld = FlxG.keys.pressed.UP || FlxG.keys.pressed.W;
		var jumpPressed = FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W;
		gravityMotion.step(body, arena, body.radius, horizontalAxis() * SPEED, jumpPressed, jumpHeld, elapsed);
	}

	function syncTransform():Void
	{
		x = body.x;
		y = body.y;
		hurtbox.setCenter(body.centerX, body.centerY);
	}

	function updateHurtAnimation(elapsed:Float):Void
	{
		if (hurtTimer > 0)
		{
			hurtTimer -= elapsed;
			animation.play('hurt');
		}
		else if (animation.name == 'hurt')
			animation.play('idle');
	}

	function horizontalAxis():Float
	{
		if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.A)
			return -1;
		if (FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D)
			return 1;
		return 0;
	}

	function verticalAxis():Float
	{
		if (FlxG.keys.pressed.UP || FlxG.keys.pressed.W)
			return -1;
		if (FlxG.keys.pressed.DOWN || FlxG.keys.pressed.S)
			return 1;
		return 0;
	}

	function set_state(value:SoulState):SoulState
	{
		color = switch value
		{
			case Yellow: FlxColor.YELLOW;
			case Blue: FlxColor.BLUE;
			case Red: FlxColor.RED;
		}
		gravityMotion.reset();
		return state = value;
	}

	inline function get_gravityAngle():Float
	{
		return gravityMotion.angle;
	}

	inline function set_gravityAngle(value:Float):Float
	{
		return gravityMotion.angle = value;
	}

	inline function get_grounded():Bool
	{
		return body.grounded;
	}
}
