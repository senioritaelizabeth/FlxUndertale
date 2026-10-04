package undertale.physics;

/** Gravity and jump movement (blue soul). `angle` rotates the gravity direction, 0 is down. */
class GravityMotion
{
	static inline var GROUND_NORMAL_MIN:Float = 0.5;
	static inline var CONTACT_MIN:Float = 0.000001;

	public var gravity:Float;
	public var jumpSpeed:Float;
	public var jumpCutSpeed:Float;
	public var angle(default, set):Float = 0;
	public var velocityX(default, null):Float = 0;
	public var velocityY(default, null):Float = 0;
	public var grounded(default, null):Bool = false;

	var downX:Float = 0;
	var downY:Float = 1;
	var groundNormalX:Float = 0;
	var groundNormalY:Float = -1;

	public function new(gravity:Float, jumpSpeed:Float, jumpCutSpeed:Float)
	{
		this.gravity = gravity;
		this.jumpSpeed = jumpSpeed;
		this.jumpCutSpeed = jumpCutSpeed;
	}

	public function step(body:PhysicsBody, arena:ContainerBody, margin:Float, lateral:Float, jumpPressed:Bool, jumpHeld:Bool, elapsed:Float):Void
	{
		if (jumpPressed && grounded)
			addAlongGravity(-jumpSpeed - alongGravity());
		else if (grounded)
		{
			velocityX = -groundNormalX * gravity * elapsed;
			velocityY = -groundNormalY * gravity * elapsed;
		}
		else
		{
			velocityX += downX * gravity * elapsed;
			velocityY += downY * gravity * elapsed;
		}
		if (!jumpHeld && alongGravity() < -jumpCutSpeed)
			addAlongGravity(-jumpCutSpeed - alongGravity());

		var moveX = downY;
		var moveY = -downX;
		if (grounded)
		{
			var along = moveX * groundNormalX + moveY * groundNormalY;
			moveX -= groundNormalX * along;
			moveY -= groundNormalY * along;
			var length = Math.sqrt(moveX * moveX + moveY * moveY);
			if (length > CONTACT_MIN)
			{
				moveX /= length;
				moveY /= length;
			}
		}
		body.velocityX = velocityX + moveX * lateral;
		body.velocityY = velocityY + moveY * lateral;
		body.step(elapsed);

		grounded = false;
		if (arena.confine(body, margin))
			resolveContact(arena.correctionX, arena.correctionY);
		body.grounded = grounded;
	}

	public function reset():Void
	{
		velocityX = 0;
		velocityY = 0;
		grounded = false;
	}

	function resolveContact(correctionX:Float, correctionY:Float):Void
	{
		var length = Math.sqrt(correctionX * correctionX + correctionY * correctionY);
		if (length < CONTACT_MIN)
			return;
		var normalX = correctionX / length;
		var normalY = correctionY / length;
		var intoWall = velocityX * normalX + velocityY * normalY;
		if (intoWall < 0)
		{
			velocityX -= normalX * intoWall;
			velocityY -= normalY * intoWall;
		}
		grounded = -(normalX * downX + normalY * downY) > GROUND_NORMAL_MIN;
		if (grounded)
		{
			groundNormalX = normalX;
			groundNormalY = normalY;
			velocityX = 0;
			velocityY = 0;
		}
	}

	inline function alongGravity():Float
	{
		return velocityX * downX + velocityY * downY;
	}

	inline function addAlongGravity(amount:Float):Void
	{
		velocityX += downX * amount;
		velocityY += downY * amount;
	}

	function set_angle(value:Float):Float
	{
		var radians = value * Math.PI / 180;
		downX = -Math.sin(radians);
		downY = Math.cos(radians);
		return angle = value;
	}
}
