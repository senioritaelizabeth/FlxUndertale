package undertale.obj;

import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import undertale.physics.ContainerBody;

class Box extends FlxBasic
{
	public final body:ContainerBody;
	public var borderSize:Float;

	final border:FlxSprite = createLayer(FlxColor.WHITE);
	final fill:FlxSprite = createLayer(FlxColor.BLACK);

	public function new(body:ContainerBody, borderSize:Float = 3)
	{
		super();
		this.body = body;
		this.borderSize = borderSize;
	}

	override function draw():Void
	{
		if (borderSize > 0)
		{
			place(border, body.width + borderSize * 2, body.height + borderSize * 2);
			border.draw();
		}
		place(fill, body.width, body.height);
		fill.draw();
	}

	override function destroy():Void
	{
		border.destroy();
		fill.destroy();
		super.destroy();
	}

	function place(layer:FlxSprite, width:Float, height:Float):Void
	{
		var halfWidth = width * 0.5;
		var halfHeight = height * 0.5;
		layer.origin.set(0, 0);
		layer.scale.set(width, height);
		layer.angle = body.angle;
		layer.x = body.centerX - halfWidth * body.cosAngle + halfHeight * body.sinAngle;
		layer.y = body.centerY - halfWidth * body.sinAngle - halfHeight * body.cosAngle;
		layer.cameras = cameras;
	}

	static function createLayer(color:FlxColor):FlxSprite
	{
		var layer = new FlxSprite();
		layer.makeGraphic(1, 1, color);
		layer.antialiasing = false;
		layer.moves = false;
		#if debug
		layer.debugBoundingBoxColor = FlxColor.TRANSPARENT;
		#end
		return layer;
	}
}
