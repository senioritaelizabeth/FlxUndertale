package undertale.util;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import openfl.display.BitmapData;
import openfl.display3D.Context3DTextureFormat;
import openfl.geom.ColorTransform;

/** Helpers to freeze the current frame (used by the game over transition). */
class ScreenCapture
{
	/**
	 * Draws every visible camera into a GPU texture `scale` times the game size.
	 * A texture is used (instead of a regular BitmapData) so sprite colors and tints are kept.
	 * Call it after rendering, e.g. from `FlxG.signals.postDraw`.
	 */
	public static function captureLastFrame(scale:Int = 4):FlxGraphic
	{
		var sx = FlxG.scaleMode.scale.x;
		var sy = FlxG.scaleMode.scale.y;
		var w = FlxG.width * scale;
		var h = FlxG.height * scale;

		var ctx = FlxG.stage.context3D;
		var tex = ctx.createRectangleTexture(w, h, Context3DTextureFormat.BGRA, true);
		var bitmap = BitmapData.fromTexture(tex);

		for (camera in FlxG.cameras.list)
		{
			if (camera == null || !camera.exists || !camera.visible || camera.alpha <= 0)
				continue;

			var sprite = camera.flashSprite;
			var m = sprite.transform.matrix.clone();
			m.scale(scale / sx, scale / sy);

			var ct = new ColorTransform(1, 1, 1, camera.alpha);
			bitmap.draw(sprite, m, ct, null, null, true);
		}

		var g = FlxGraphic.fromBitmapData(bitmap);
		g.persist = true;
		g.destroyOnNoUse = false;
		return g;
	}

	/** Converts a world position to a screen position, taking camera scroll and zoom into account. */
	public static function worldToScreen(px:Float, py:Float, cam:FlxCamera):FlxPoint
	{
		return FlxPoint.get((px - cam.scroll.x) * cam.zoom
			+ cam.width * 0.5 * (1 - cam.zoom)
			+ cam.x,
			(py - cam.scroll.y) * cam.zoom
			+ cam.height * 0.5 * (1 - cam.zoom)
			+ cam.y);
	}
}
