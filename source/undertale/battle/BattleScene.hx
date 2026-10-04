package undertale.battle;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.display.BitmapData;
import openfl.display3D.Context3DTextureFormat;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Matrix;
import undertale.obj.UnderText;
import undertale.obj.ValueText;

class BattleScene extends UnderState
{
	var dodgeheart:DodgeHeart;
	var battle_box:BoxBattle;
	final attacks:Array<AttackParent> = [];
	#if debug
	var debugger:PhysicsDebugger;
	#end

	public var uiGroup:FlxGroup;

	var hudCamera:FlxCamera;
	var pendingGameOver:Bool = false;

	override function create():Void
	{
		super.create();
		var text = new UnderText(-100, -100, 'Battle Scene', 'hud');
		add(text);
		battle_box = new BoxBattle(100, 100);
		add(battle_box);

		dodgeheart = new DodgeHeart(160, 120);
		add(dodgeheart);
		battle_box.soul = dodgeheart;

		addAttack(new BulletParent(108, 108, 20, 20));
		addAttack(new CircleAttack(176, 116, 14));
		addAttack(new PolygonAttack(132, 170, [18, 0, 30, 5, 36, 16, 32, 28, 22, 36, 9, 32, 0, 22, 2, 10, 10, 3]));

		#if debug
		debugger = new PhysicsDebugger();
		debugger.watchContainer(battle_box.arena);
		debugger.watch(dodgeheart.body, 0xFF40FF40);
		debugger.watch(dodgeheart.hurtbox, 0xFFFF8080);
		for (attack in attacks)
			debugger.watch(attack.body, 0xFF00FFFF, dodgeheart.hurtbox);
		debugger.watchGravity(dodgeheart.body, () -> dodgeheart.gravityAngle);
		debugger.traceBody(dodgeheart.body, battle_box.arena);
		add(debugger);
		#end
		uiGroup = new FlxGroup();
		add(uiGroup);
		hudCamera = new FlxCamera(-320 / 2, 0, 640, 480);
		hudCamera.bgColor = FlxColor.TRANSPARENT;
		hudCamera.zoom = 0.5;
		FlxG.cameras.add(hudCamera, false);

		uiGroup.cameras = [hudCamera];

		uiGroup.add(new HealthDisplay());
		camera.zoom = 0.5;
	}

	function setupText(x:Float, y:Float, format:String, value:String)
	{
		var valued = new ValueText(x, y, Global, value, format);
		return valued;
	}

	override function update(elapsed:Float):Void
	{
		if (pendingGameOver)
			return;
		if (Global.hp <= 0)
		{
			function worldToScreen(px:Float, py:Float, cam:FlxCamera):FlxPoint
			{
				return FlxPoint.get((px - cam.scroll.x) * cam.zoom
					+ cam.width * 0.5 * (1 - cam.zoom)
					+ cam.x,
					(py - cam.scroll.y) * cam.zoom
					+ cam.height * 0.5 * (1 - cam.zoom)
					+ cam.y);
			}

		
			var mid = dodgeheart.getGraphicMidpoint(); 
			var s = worldToScreen(mid.x, mid.y, FlxG.camera);
			Global.soulx = Math.round(s.x);
			Global.souly = Math.round(s.y);
			mid.put();
			s.put();
			pendingGameOver = true;
			return;
		}
		super.update(elapsed);
		for (attack in attacks)
			dodgeheart.attackCollided(attack);
	}

	override function draw():Void
	{
		super.draw();
		if (pendingGameOver)
		{
			pendingGameOver = false;
			FlxG.signals.postDraw.addOnce(() ->
			{
				var g = captureLastFrame();
				g.persist = true;
				g.destroyOnNoUse = false;
				GameoverScene.lastframe = g;
				trace(g);
				FlxG.switchState(GameoverScene.new);
			});
		}
	}

	function captureLastFrame(scale:Int = 4):FlxGraphic
	{
		var sx = FlxG.scaleMode.scale.x;
		var sy = FlxG.scaleMode.scale.y;
		var w = FlxG.width * scale;
		var h = FlxG.height * scale;

		var ctx = FlxG.stage.context3D;
		var tex = ctx.createRectangleTexture(w, h, Context3DTextureFormat.BGRA, true);
		var bitmap = BitmapData.fromTexture(tex);

		for (camera in FlxG.cameras.list)
		{
			if (camera == null || !camera.exists || !camera.visible || camera.alpha <= 0)
				continue;

			var sprite = camera.flashSprite;
			var m = sprite.transform.matrix.clone();
			m.scale(scale / sx, scale / sy);

			var ct = new ColorTransform(1, 1, 1, camera.alpha);
			bitmap.draw(sprite, m, ct, null, null, true);
		}

		var g = FlxGraphic.fromBitmapData(bitmap);
		g.persist = true;
		g.destroyOnNoUse = false;
		return g;
	}

	public function addAttack(attack:AttackParent):Void
	{
		if (attack == null)
			return;
		attacks.push(attack);
		add(attack);
	}
}
