package undertale.physics;

class PolygonBody extends PhysicsBody
{
	public final localPoints:Array<Float>;
	public final pointCount:Int;

	public function new(x:Float, y:Float, points:Array<Float>)
	{
		var bounds = measure(points);
		super(Polygon, x, y, bounds.maxX - bounds.minX, bounds.maxY - bounds.minY);
		pointCount = Std.int(points.length / 2);
		var middleX = (bounds.minX + bounds.maxX) * 0.5;
		var middleY = (bounds.minY + bounds.maxY) * 0.5;
		localPoints = [];
		for (index in 0...pointCount)
		{
			localPoints.push(points[index * 2] - middleX);
			localPoints.push(points[index * 2 + 1] - middleY);
		}
	}

	override public function worldPoints():Array<Float>
	{
		for (index in 0...pointCount)
			writeRotatedPoint(index, localPoints[index * 2], localPoints[index * 2 + 1]);
		return vertexBuffer;
	}

	static function measure(points:Array<Float>):
		{
			minX:Float,
			minY:Float,
			maxX:Float,
			maxY:Float
		}
	{
		var minX = points[0];
		var maxX = points[0];
		var minY = points[1];
		var maxY = points[1];
		for (index in 1...Std.int(points.length / 2))
		{
			minX = Math.min(minX, points[index * 2]);
			maxX = Math.max(maxX, points[index * 2]);
			minY = Math.min(minY, points[index * 2 + 1]);
			maxY = Math.max(maxY, points[index * 2 + 1]);
		}
		return {
			minX: minX,
			minY: minY,
			maxX: maxX,
			maxY: maxY
		};
	}
}
