package undertale.battle;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import undertale.physics.ContainerBody;
import undertale.physics.PhysicsBody;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

private typedef Tracked =
{
	body:PhysicsBody,
	color:FlxColor,
	trigger:PhysicsBody
}

class PhysicsDebugger extends FlxBasic
{
	static inline var TRACE_FRAMES:Int = 30;
	static inline var AXIS_LENGTH:Float = 24;
	static inline var VELOCITY_LOOKAHEAD:Float = 0.25;
	static inline var CENTER_MARK:Float = 3;
	static inline var CANVAS_MARGIN:Int = 64;
	static inline var GRAVITY_COLOR:FlxColor = 0xFFFF40FF;
	static inline var HIT_COLOR:FlxColor = 0xFFFF2020;
	static inline var CONTAINER_COLOR:FlxColor = 0xFFFFE000;

	public var toggleKey:FlxKey = F4;
	public var traceKey:FlxKey = F8;

	final canvas:FlxSprite = new FlxSprite();
	final tracked:Array<Tracked> = [];
	final containers:Array<ContainerBody> = [];
	var gravityBody:PhysicsBody;
	var gravityAngle:() -> Float;
	var traceTarget:PhysicsBody;
	var traceSpace:ContainerBody;
	var traceRemaining:Int = 0;
	var traceRows:Array<String> = [];
	var lineThickness:Float = 1;

	public function new()
	{
		super();
		visible = false;
		canvas.moves = false;
		canvas.antialiasing = false;
		#if debug
		canvas.debugBoundingBoxColor = FlxColor.TRANSPARENT;
		#end
	}

	public function watch(body:PhysicsBody, color:FlxColor = FlxColor.CYAN, ?trigger:PhysicsBody):Void
	{
		tracked.push({body: body, color: color, trigger: trigger});
	}

	public function watchContainer(container:ContainerBody):Void
	{
		containers.push(container);
	}

	public function watchGravity(body:PhysicsBody, angle:() -> Float):Void
	{
		gravityBody = body;
		gravityAngle = angle;
	}

	public function traceBody(target:PhysicsBody, ?space:ContainerBody):Void
	{
		traceTarget = target;
		traceSpace = space;
	}

	override function update(elapsed:Float):Void
	{
		if (FlxG.keys.anyJustPressed([toggleKey]))
			visible = !visible;
		if (FlxG.keys.anyJustPressed([traceKey]))
			startTrace();
		recordTrace(elapsed);
	}

	override function draw():Void
	{
		if (!visible)
			return;
		var camera = FlxG.camera;
		var viewWidth = camera.width / camera.zoom;
		var viewHeight = camera.height / camera.zoom;
		var canvasWidth = Std.int(Math.ceil(viewWidth)) + CANVAS_MARGIN * 2;
		var canvasHeight = Std.int(Math.ceil(viewHeight)) + CANVAS_MARGIN * 2;
		if (canvas.frameWidth != canvasWidth || canvas.frameHeight != canvasHeight)
			canvas.makeGraphic(canvasWidth, canvasHeight, FlxColor.TRANSPARENT, true);
		else
			FlxSpriteUtil.fill(canvas, FlxColor.TRANSPARENT);

		canvas.x = Math.floor(camera.scroll.x + (camera.width - viewWidth) * 0.5) - CANVAS_MARGIN;
		canvas.y = Math.floor(camera.scroll.y + (camera.height - viewHeight) * 0.5) - CANVAS_MARGIN;
		lineThickness = Math.max(1, 1 / camera.zoom);

		for (container in containers)
			drawContainer(container);
		for (entry in tracked)
			drawTracked(entry);
		drawGravity();

		canvas.draw();
	}

	override function destroy():Void
	{
		canvas.destroy();
		tracked.resize(0);
		containers.resize(0);
		super.destroy();
	}

	function drawContainer(container:ContainerBody):Void
	{
		drawPolygonOutline(container.worldPoints(), CONTAINER_COLOR);
	}

	function drawGravity():Void
	{
		if (gravityBody == null)
			return;
		var radians = gravityAngle() * Math.PI / 180;
		var centerX = gravityBody.centerX;
		var centerY = gravityBody.centerY;
		drawArrow(centerX, centerY, centerX - Math.sin(radians) * AXIS_LENGTH, centerY + Math.cos(radians) * AXIS_LENGTH, GRAVITY_COLOR);
	}

	function drawTracked(entry:Tracked):Void
	{
		var body = entry.body;
		var hit = entry.trigger != null && body.overlaps(entry.trigger);
		var color = hit ? HIT_COLOR : entry.color;
		switch body.shape
		{
			case Circle:
				var circle:undertale.physics.CircleBody = cast body;
				var style = {thickness: lineThickness, color: color};
				FlxSpriteUtil.drawCircle(canvas, localX(circle.centerX), localY(circle.centerY), circle.radius,
					hit ? withAlpha(color, 0x60) : FlxColor.TRANSPARENT, style);
			default:
				drawPolygonOutline(body.worldPoints(), color);
		}
		drawCross(body.centerX, body.centerY, color);
		if (body.velocityX != 0 || body.velocityY != 0)
			drawArrow(body.centerX, body.centerY, body.centerX + body.velocityX * VELOCITY_LOOKAHEAD, body.centerY + body.velocityY * VELOCITY_LOOKAHEAD,
				color);
	}

	function drawPolygonOutline(vertices:Array<Float>, color:FlxColor):Void
	{
		var count = Std.int(vertices.length / 2);
		for (index in 0...count)
		{
			var next = (index + 1) % count;
			drawSegment(vertices[index * 2], vertices[index * 2 + 1], vertices[next * 2], vertices[next * 2 + 1], color);
		}
	}

	function drawCross(worldX:Float, worldY:Float, color:FlxColor):Void
	{
		drawSegment(worldX - CENTER_MARK, worldY, worldX + CENTER_MARK, worldY, color);
		drawSegment(worldX, worldY - CENTER_MARK, worldX, worldY + CENTER_MARK, color);
	}

	function drawArrow(fromX:Float, fromY:Float, toX:Float, toY:Float, color:FlxColor):Void
	{
		drawSegment(fromX, fromY, toX, toY, color);
		var angle = Math.atan2(toY - fromY, toX - fromX);
		var head = 4 * lineThickness;
		drawSegment(toX, toY, toX - Math.cos(angle - 0.5) * head, toY - Math.sin(angle - 0.5) * head, color);
		drawSegment(toX, toY, toX - Math.cos(angle + 0.5) * head, toY - Math.sin(angle + 0.5) * head, color);
	}

	function drawSegment(fromX:Float, fromY:Float, toX:Float, toY:Float, color:FlxColor):Void
	{
		FlxSpriteUtil.drawLine(canvas, localX(fromX), localY(fromY), localX(toX), localY(toY), {thickness: lineThickness, color: color});
	}

	inline function localX(worldX:Float):Float
	{
		return worldX - canvas.x;
	}

	inline function localY(worldY:Float):Float
	{
		return worldY - canvas.y;
	}

	inline function withAlpha(color:FlxColor, alpha:Int):FlxColor
	{
		return FlxColor.fromRGB(color.red, color.green, color.blue, alpha);
	}

	function startTrace():Void
	{
		if (traceTarget == null)
			return;
		traceRemaining = TRACE_FRAMES;
		traceRows = ["frame,dt,angle,centerX,centerY,localX,localY,velocityX,velocityY,grounded"];
	}

	function recordTrace(elapsed:Float):Void
	{
		if (traceRemaining <= 0 || traceTarget == null)
			return;
		var centerX = traceTarget.centerX;
		var centerY = traceTarget.centerY;
		var localPointX = traceSpace != null ? traceSpace.toLocalX(centerX, centerY) : centerX;
		var localPointY = traceSpace != null ? traceSpace.toLocalY(centerX, centerY) : centerY;
		var angle = traceSpace != null ? traceSpace.angle : 0;
		var row:Array<Dynamic> = [
			TRACE_FRAMES - traceRemaining,
			elapsed,
			angle,
			centerX,
			centerY,
			localPointX,
			localPointY,
			traceTarget.velocityX,
			traceTarget.velocityY,
			traceTarget.grounded
		];
		traceRows.push(row.join(","));
		if (--traceRemaining == 0)
			saveTrace();
	}

	function saveTrace():Void
	{
		#if sys
		if (!FileSystem.exists("debug"))
			FileSystem.createDirectory("debug");
		File.saveContent("debug/physics_trace.csv", traceRows.join("\n") + "\n");
		#end
	}
}
