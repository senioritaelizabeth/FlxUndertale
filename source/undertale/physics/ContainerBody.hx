package undertale.physics;

class ContainerBody extends RectangleBody
{
	public var correctionX(default, null):Float = 0;
	public var correctionY(default, null):Float = 0;

	public function setSize(newWidth:Float, newHeight:Float):Void
	{
		var middleX = centerX;
		var middleY = centerY;
		width = newWidth;
		height = newHeight;
		setCenter(middleX, middleY);
	}

	public function toLocalX(worldX:Float, worldY:Float):Float
	{
		return (worldX - centerX) * cosAngle + (worldY - centerY) * sinAngle + width * 0.5;
	}

	public function toLocalY(worldX:Float, worldY:Float):Float
	{
		return -(worldX - centerX) * sinAngle + (worldY - centerY) * cosAngle + height * 0.5;
	}

	public function toWorldX(localX:Float, localY:Float):Float
	{
		return centerX + (localX - width * 0.5) * cosAngle - (localY - height * 0.5) * sinAngle;
	}

	public function toWorldY(localX:Float, localY:Float):Float
	{
		return centerY + (localX - width * 0.5) * sinAngle + (localY - height * 0.5) * cosAngle;
	}

	public function confine(body:PhysicsBody, margin:Float):Bool
	{
		var localX = toLocalX(body.centerX, body.centerY);
		var localY = toLocalY(body.centerX, body.centerY);
		var solvedX = clamp(localX, Math.min(margin, width * 0.5), Math.max(width - margin, width * 0.5));
		var solvedY = clamp(localY, Math.min(margin, height * 0.5), Math.max(height - margin, height * 0.5));

		correctionX = 0;
		correctionY = 0;
		if (solvedX == localX && solvedY == localY)
			return false;

		var solvedWorldX = toWorldX(solvedX, solvedY);
		var solvedWorldY = toWorldY(solvedX, solvedY);
		correctionX = solvedWorldX - body.centerX;
		correctionY = solvedWorldY - body.centerY;
		body.setCenter(solvedWorldX, solvedWorldY);
		return true;
	}

	static inline function clamp(value:Float, min:Float, max:Float):Float
	{
		return value < min ? min : (value > max ? max : value);
	}
}
