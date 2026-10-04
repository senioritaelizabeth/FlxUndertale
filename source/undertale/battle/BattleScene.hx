package undertale.battle;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import undertale.battle.attacks.AttackParent;
import undertale.battle.attacks.BulletParent;
import undertale.battle.attacks.CircleAttack;
import undertale.battle.attacks.PolygonAttack;
import undertale.core.AssetsPath;
import undertale.core.Global;
import undertale.core.UnderState;
import undertale.text.UnderText;
import undertale.text.ValueText;
import undertale.util.ScreenCapture;
#if debug
import undertale.debug.PhysicsDebugger;
#end

/** Dodging battle. When HP reaches 0 it captures the last frame and goes to `GameoverScene`. */
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
		FlxG.sound.playMusic(AssetsPath.music('prebattle'), 1.0, true);
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
			// store the soul screen position (zoom applied) for the game over scene
			var mid = dodgeheart.getGraphicMidpoint();
			var s = ScreenCapture.worldToScreen(mid.x, mid.y, FlxG.camera);
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
				var g = ScreenCapture.captureLastFrame();
				g.persist = true;
				g.destroyOnNoUse = false;
				GameoverScene.lastframe = g;
				trace(g);
				FlxG.switchState(GameoverScene.new);
			});
		}
	}

	public function addAttack(attack:AttackParent):Void
	{
		if (attack == null)
			return;
		attacks.push(attack);
		add(attack);
	}
}
