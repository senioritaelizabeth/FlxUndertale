package undertale.physics;

class CircleBody extends PhysicsBody
{
	public var radius(default, set):Float;

	public function new(x:Float, y:Float, radius:Float)
	{
		super(Circle, x, y, radius * 2, radius * 2);
		this.radius = radius;
	}

	override public function containsPoint(pointX:Float, pointY:Float):Bool
	{
		var deltaX = pointX - centerX;
		var deltaY = pointY - centerY;
		return deltaX * deltaX + deltaY * deltaY <= radius * radius;
	}

	function set_radius(value:Float):Float
	{
		width = value * 2;
		height = value * 2;
		return radius = value;
	}
}
