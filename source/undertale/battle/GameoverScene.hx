package undertale.battle;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;

enum GOState
{
	ShowingLastFrame;
	ShowingSoul;
	Break1;
	FallingShatt;
	ShowingGameOverText;
}

class GameoverScene extends UnderState
{
	var phase:GOState = GOState.ShowingLastFrame;

	public static var lastframe:FlxGraphic;

	var _last_frame_sprite:FlxSprite;
	var _soul_sprite:FlxSprite;

	override function create()
	{
		super.create();

		_last_frame_sprite = new FlxSprite(0, 0);
		_last_frame_sprite.loadGraphic(lastframe);
		_last_frame_sprite.setGraphicSize(FlxG.width, FlxG.height);
		_last_frame_sprite.updateHitbox();
		add(_last_frame_sprite);

		_soul_sprite = new FlxSprite();
		_soul_sprite.loadGraphic(AssetsPath.image('battle/spr_dodgeheart'), true, 20, 20);
		_soul_sprite.animation.add('idle', [0]);
		_soul_sprite.animation.play('idle');
		_soul_sprite.scale.set(0.5, 0.5);
		_soul_sprite.antialiasing = false;
		_soul_sprite.setPosition(Global.soulx - _soul_sprite.width * 0.5, Global.souly - _soul_sprite.height * 0.5);
		_soul_sprite.visible = false;
		add(_soul_sprite);
	}

	var _timer = 0.0;

	static final SHARD_OFFSETS:Array<Array<Float>> = [[-2, 0], [0, 3], [2, 6], [8, 0], [10, 3], [12, 6]];

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		switch (phase)
		{
			case ShowingLastFrame:
				_timer += elapsed;
				if (_timer > 0.25)
				{
					_timer = 0;
					phase = GOState.ShowingSoul;
					_soul_sprite.visible = true;
					destroylastframescene();
				}
			case ShowingSoul:
				_timer += elapsed;
				if (_timer > 1.0)
				{
					_timer = 0;
					phase = GOState.Break1;
					FlxG.sound.play(AssetsPath.sound('break', 'wav'), 1.0, false);
					_soul_sprite.loadGraphic(AssetsPath.image('battle/spr_dodgeheart_broken'));
					_soul_sprite.updateHitbox();
					_soul_sprite.x = Global.soulx - _soul_sprite.width * 0.5;
					_soul_sprite.y = Global.souly - _soul_sprite.height * 0.5;
				}
			case Break1:
				_timer += elapsed;
				if (_timer > 1.5)
				{
					_timer = 0;
					phase = GOState.FallingShatt;
					// al morir:
					_soul_sprite.visible = false;

					var size = _soul_sprite.frameWidth * _soul_sprite.scale.x;
					var left = Global.soulx - size * 0.5;
					var top = Global.souly - size * 0.5;
					var k = size / 8;

					for (o in SHARD_OFFSETS)
					{
						var shard = new HeartShard(left + o[0] * k, top + o[1] * k);
						add(shard);
					}
					FlxG.sound.play(AssetsPath.sound('break2', 'wav'), 1.0, false);
				}
			case FallingShatt:
				_timer += elapsed;
				if (_timer > 1.0)
				{
					_timer = 0;
					phase = GOState.ShowingGameOverText;
				}
			case ShowingGameOverText:
		}
	}

	public function destroylastframescene()
	{
		if (lastframe != null)
		{
			lastframe.destroy();
			lastframe = null;
		}
		if (_last_frame_sprite != null)
		{
			_last_frame_sprite.destroy();
			_last_frame_sprite = null;
		}
	}
}

class HeartShard extends FlxSprite
{
	static inline var STEP:Float = 1 / 30;

	var hspeed:Float;
	var vspeed:Float;
	var gravity:Float = 0.2;
	var gravityDir:Float = 270;
	var acc:Float = 0;

	public function new(x:Float, y:Float)
	{
		super(x, y);
		loadGraphic(AssetsPath.image('battle/spr_heartshard'), true, 10, 10);
		animation.add('idle', [0, 1, 2, 3], 7.5);
		animation.play('idle');
		antialiasing = false;

		var direction = FlxG.random.float(0, 360);
		var speed = 7;
		hspeed = speed * Math.cos(direction * Math.PI / 180);
		vspeed = -speed * Math.sin(direction * Math.PI / 180);
		scale.set(0.5, 0.5);
	}

	override function update(elapsed:Float)
	{
		acc += elapsed;
		while (acc >= STEP)
		{
			acc -= STEP;
			hspeed += gravity * Math.cos(gravityDir * Math.PI / 180);
			vspeed += -gravity * Math.sin(gravityDir * Math.PI / 180);
			x += hspeed;
			y += vspeed;
		}
		super.update(elapsed);
	}
}
