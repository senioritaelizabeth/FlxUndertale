package undertale.battle.attacks;

import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import undertale.physics.PolygonBody;

class PolygonAttack extends AttackParent
{
	static inline var OUTLINE:Int = 2;

	public function new(x:Float, y:Float, points:Array<Float>, damage:Float = 1)
	{
		var polygon = new PolygonBody(x, y, points);
		super(polygon, damage);
		makeGraphic(Std.int(Math.ceil(polygon.width)) + OUTLINE * 2, Std.int(Math.ceil(polygon.height)) + OUTLINE * 2, FlxColor.TRANSPARENT, true);

		var vertices:Array<FlxPoint> = [];
		for (index in 0...polygon.pointCount)
			vertices.push(FlxPoint.get(polygon.localPoints[index * 2]
				+ polygon.width * 0.5
				+ OUTLINE,
				polygon.localPoints[index * 2 + 1]
				+ polygon.height * 0.5
				+ OUTLINE));
		FlxSpriteUtil.drawPolygon(this, vertices, FlxColor.PURPLE, {thickness: OUTLINE, color: FlxColor.WHITE});
		for (vertex in vertices)
			vertex.put();

		offset.set(OUTLINE, OUTLINE);
		this.width = polygon.width;
		this.height = polygon.height;
	}
}
