package undertale.physics;

/** Base of all collision shapes (rectangle, circle, polygon). Rotates around its center. */
class PhysicsBody
{
	public final shape:BodyShape;
	public var x:Float;
	public var y:Float;
	public var width:Float;
	public var height:Float;
	public var velocityX:Float = 0;
	public var velocityY:Float = 0;
	public var grounded:Bool = false;
	public var active:Bool = true;
	public var angle(default, set):Float = 0;
	public var cosAngle(default, null):Float = 1;
	public var sinAngle(default, null):Float = 0;
	public var centerX(get, never):Float;
	public var centerY(get, never):Float;

	var vertexBuffer:Array<Float> = [];

	public function new(shape:BodyShape, x:Float, y:Float, width:Float, height:Float)
	{
		this.shape = shape;
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}

	public function step(elapsed:Float):Void
	{
		if (!active)
			return;
		x += velocityX * elapsed;
		y += velocityY * elapsed;
	}

	public function setCenter(centerX:Float, centerY:Float):Void
	{
		x = centerX - width * 0.5;
		y = centerY - height * 0.5;
	}

	public function worldPoints():Array<Float>
	{
		return vertexBuffer;
	}

	public function overlaps(other:PhysicsBody):Bool
	{
		return Collision.overlaps(this, other);
	}

	public function containsPoint(pointX:Float, pointY:Float):Bool
	{
		return Collision.pointInPolygon(pointX, pointY, worldPoints());
	}

	function set_angle(value:Float):Float
	{
		var radians = value * Math.PI / 180;
		cosAngle = Math.cos(radians);
		sinAngle = Math.sin(radians);
		return angle = value;
	}

	inline function get_centerX():Float
	{
		return x + width * 0.5;
	}

	inline function get_centerY():Float
	{
		return y + height * 0.5;
	}

	function writeRotatedPoint(index:Int, localX:Float, localY:Float):Void
	{
		vertexBuffer[index * 2] = centerX + localX * cosAngle - localY * sinAngle;
		vertexBuffer[index * 2 + 1] = centerY + localX * sinAngle + localY * cosAngle;
	}
}
