package undertale.physics;

class RectangleBody extends PhysicsBody
{
	public function new(x:Float, y:Float, width:Float, height:Float)
	{
		super(Rectangle, x, y, width, height);
	}

	override public function worldPoints():Array<Float>
	{
		var halfWidth = width * 0.5;
		var halfHeight = height * 0.5;
		writeRotatedPoint(0, -halfWidth, -halfHeight);
		writeRotatedPoint(1, halfWidth, -halfHeight);
		writeRotatedPoint(2, halfWidth, halfHeight);
		writeRotatedPoint(3, -halfWidth, halfHeight);
		return vertexBuffer;
	}

	override public function containsPoint(pointX:Float, pointY:Float):Bool
	{
		var deltaX = pointX - centerX;
		var deltaY = pointY - centerY;
		var localX = deltaX * cosAngle + deltaY * sinAngle;
		var localY = -deltaX * sinAngle + deltaY * cosAngle;
		return Math.abs(localX) <= width * 0.5 && Math.abs(localY) <= height * 0.5;
	}
}
