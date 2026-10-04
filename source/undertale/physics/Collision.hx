package undertale.physics;

class Collision
{
	public static function overlaps(first:PhysicsBody, second:PhysicsBody):Bool
	{
		return switch [first.shape, second.shape]
		{
			case [Circle, Circle]:
				circleCircle(cast first, cast second);
			case [Circle, _]:
				circlePolygon(first.centerX, first.centerY, cast(first, CircleBody).radius, second.worldPoints());
			case [_, Circle]:
				circlePolygon(second.centerX, second.centerY, cast(second, CircleBody).radius, first.worldPoints());
			default:
				polygonPolygon(first.worldPoints(), second.worldPoints());
		}
	}

	public static function circleCircle(first:CircleBody, second:CircleBody):Bool
	{
		var deltaX = first.centerX - second.centerX;
		var deltaY = first.centerY - second.centerY;
		var radiusSum = first.radius + second.radius;
		return deltaX * deltaX + deltaY * deltaY <= radiusSum * radiusSum;
	}

	public static function circlePolygon(circleX:Float, circleY:Float, radius:Float, vertices:Array<Float>):Bool
	{
		if (pointInPolygon(circleX, circleY, vertices))
			return true;
		var count = Std.int(vertices.length / 2);
		var radiusSquared = radius * radius;
		for (index in 0...count)
		{
			var next = (index + 1) % count;
			if (distanceToSegmentSquared(circleX, circleY, vertices[index * 2], vertices[index * 2 + 1], vertices[next * 2],
				vertices[next * 2 + 1]) <= radiusSquared)
				return true;
		}
		return false;
	}

	public static function polygonPolygon(first:Array<Float>, second:Array<Float>):Bool
	{
		var firstCount = Std.int(first.length / 2);
		var secondCount = Std.int(second.length / 2);
		for (firstIndex in 0...firstCount)
		{
			var firstNext = (firstIndex + 1) % firstCount;
			for (secondIndex in 0...secondCount)
			{
				var secondNext = (secondIndex + 1) % secondCount;
				if (segmentsIntersect(first[firstIndex * 2], first[firstIndex * 2 + 1], first[firstNext * 2], first[firstNext * 2 + 1],
					second[secondIndex * 2], second[secondIndex * 2 + 1], second[secondNext * 2], second[secondNext * 2 + 1]))
					return true;
			}
		}
		return pointInPolygon(first[0], first[1], second) || pointInPolygon(second[0], second[1], first);
	}

	public static function pointInPolygon(pointX:Float, pointY:Float, vertices:Array<Float>):Bool
	{
		var count = Std.int(vertices.length / 2);
		var inside = false;
		var previous = count - 1;
		for (current in 0...count)
		{
			var currentX = vertices[current * 2];
			var currentY = vertices[current * 2 + 1];
			var previousX = vertices[previous * 2];
			var previousY = vertices[previous * 2 + 1];
			if ((currentY > pointY) != (previousY > pointY)
				&& pointX < (previousX - currentX) * (pointY - currentY) / (previousY - currentY) + currentX)
				inside = !inside;
			previous = current;
		}
		return inside;
	}

	public static function distanceToSegmentSquared(pointX:Float, pointY:Float, startX:Float, startY:Float, endX:Float, endY:Float):Float
	{
		var segmentX = endX - startX;
		var segmentY = endY - startY;
		var lengthSquared = segmentX * segmentX + segmentY * segmentY;
		var progress = lengthSquared == 0 ? 0 : ((pointX - startX) * segmentX + (pointY - startY) * segmentY) / lengthSquared;
		progress = progress < 0 ? 0 : (progress > 1 ? 1 : progress);
		var deltaX = pointX - (startX + segmentX * progress);
		var deltaY = pointY - (startY + segmentY * progress);
		return deltaX * deltaX + deltaY * deltaY;
	}

	public static function segmentsIntersect(ax:Float, ay:Float, bx:Float, by:Float, cx:Float, cy:Float, dx:Float, dy:Float):Bool
	{
		var first = orientation(cx, cy, dx, dy, ax, ay);
		var second = orientation(cx, cy, dx, dy, bx, by);
		var third = orientation(ax, ay, bx, by, cx, cy);
		var fourth = orientation(ax, ay, bx, by, dx, dy);
		if (first * second < 0 && third * fourth < 0)
			return true;
		return (first == 0 && withinSegment(cx, cy, dx, dy, ax, ay))
			|| (second == 0 && withinSegment(cx, cy, dx, dy, bx, by))
			|| (third == 0 && withinSegment(ax, ay, bx, by, cx, cy))
			|| (fourth == 0 && withinSegment(ax, ay, bx, by, dx, dy));
	}

	static inline function orientation(ax:Float, ay:Float, bx:Float, by:Float, px:Float, py:Float):Float
	{
		return (bx - ax) * (py - ay) - (by - ay) * (px - ax);
	}

	static inline function withinSegment(ax:Float, ay:Float, bx:Float, by:Float, px:Float, py:Float):Bool
	{
		return px >= Math.min(ax, bx) && px <= Math.max(ax, bx) && py >= Math.min(ay, by) && py <= Math.max(ay, by);
	}
}
