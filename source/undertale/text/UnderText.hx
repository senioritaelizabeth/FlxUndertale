package undertale.text;

import flixel.FlxG;
import flixel.FlxStrip;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxColor;
import openfl.Assets;
import openfl.display.BitmapData;
import undertale.text.TextLayout;

private typedef Glyph =
{
	x:Int,
	y:Int,
	width:Int,
	height:Int,
	offsetX:Int,
	offsetY:Int,
	advance:Int
}

private typedef Face =
{
	graphic:FlxGraphic,
	atlas:BitmapData,
	glyphs:Map<Int, Glyph>,
	lineHeight:Int,
	subsWidth:Int
}

/** Bitmap font text. Supports the markup parsed by `TextLayout`. */
class UnderText extends FlxStrip
{
	static inline var DEFAULT_FIELD_WIDTH:Float = 640;
	static inline var ASTERISK_GAP:Float = 10;
	static final faces:Map<String, Face> = new Map();

	public var text(get, set):String;
	public var font(get, set):String;
	public var charsVisibles(get, set):Int;
	public var subsWidth(get, set):Int;
	public var measuredWidth(get, never):Float;
	public var totalCharacters(get, never):Int;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var outlineSize:Int = 0;
	public var outlineColor:Int = FlxColor.BLACK;
	public var effectTime:Float = 0;
	public var transientShakeCharacter:Int = -1;
	public var lineSpacing:Float = 0;
	public var letterSpacing:Float = 0;
	public var textWidth:Float = -1;
	public var startWithAsterisk:Bool = false;
	public var alignment:String = "LEFT";

	var _text:String = "";
	var _font:String = "";
	var _charsVisibles:Int = -1;
	var _subsWidth:Int = 0;
	var face:Face;
	var parsed:TextLayout = new TextLayout();
	var layoutDirty:Bool = true;
	var outlineRenderer:FlxStrip = new FlxStrip();
	var colorRenderers:Map<Int, FlxStrip> = new Map();
	var lastScaleX:Float = 1;
	var lastScaleY:Float = 1;
	var lastAngle:Float = 0;
	var lastTextWidth:Float = -1;
	var lastAlignment:String = "LEFT";
	var lastLetterSpacing:Float = 0;
	var lastLineSpacing:Float = 0;
	var lastAsterisk:Bool = false;
	var lastOutline:Int = 0;
	var lastOffsetX:Float = 0;
	var lastOffsetY:Float = 0;

	public function new(x:Float = 0, y:Float = 0, text:String = "", font:String = "determination")
	{
		super();
		this.x = x;
		this.y = y;
		_text = text == null ? "" : text;
		parsed.parse(_text);
		loadFont(font);
	}

	public function loadFont(name:String):Void
	{
		_font = name;
		face = getFace(name);
		_subsWidth = face.subsWidth;
		loadGraphic(face.graphic);
		outlineRenderer.loadGraphic(face.graphic);
		for (renderer in colorRenderers)
			renderer.loadGraphic(face.graphic);
		layoutDirty = true;
	}

	public function rebuild():Void
	{
		layoutDirty = true;
	}

	public function centerAt(centerX:Float):Void
	{
		x = centerX - measuredWidth * 0.5;
	}

	public function visibleCodeAt(index:Int):Int
	{
		return parsed.codeAt(index);
	}

	public function pauseFramesAt(count:Int):Float
	{
		return parsed.pauseFramesAt(count);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (parsed.hasEffects)
		{
			effectTime += elapsed;
			layoutDirty = true;
		}
	}

	override public function draw():Void
	{
		if (layoutDirty || layoutChanged())
		{
			rememberLayout();
			build();
			layoutDirty = false;
		}
		drawRenderer(outlineRenderer, outlineColor, outlineSize > 0);
		for (key => renderer in colorRenderers)
			drawRenderer(renderer, FlxColor.multiply(key, color), true);
	}

	override public function destroy():Void
	{
		outlineRenderer.destroy();
		for (renderer in colorRenderers)
			renderer.destroy();
		colorRenderers.clear();
		super.destroy();
	}

	function drawRenderer(renderer:FlxStrip, tint:Int, enabled:Bool):Void
	{
		if (!enabled || !visible || renderer.vertices.length == 0)
			return;
		renderer.x = x;
		renderer.y = y;
		renderer.cameras = cameras;
		renderer.scrollFactor.copyFrom(scrollFactor);
		renderer.antialiasing = antialiasing;
		renderer.alpha = alpha;
		renderer.color = tint;
		renderer.draw();
	}

	function layoutChanged():Bool
	{
		return lastScaleX != scale.x || lastScaleY != scale.y || lastAngle != angle || lastTextWidth != textWidth || lastAlignment != alignment
			|| lastLetterSpacing != letterSpacing || lastLineSpacing != lineSpacing || lastAsterisk != startWithAsterisk || lastOutline != outlineSize
			|| lastOffsetX != offsetX || lastOffsetY != offsetY;
	}

	function rememberLayout():Void
	{
		lastScaleX = scale.x;
		lastScaleY = scale.y;
		lastAngle = angle;
		lastTextWidth = textWidth;
		lastAlignment = alignment;
		lastLetterSpacing = letterSpacing;
		lastLineSpacing = lineSpacing;
		lastAsterisk = startWithAsterisk;
		lastOutline = outlineSize;
		lastOffsetX = offsetX;
		lastOffsetY = offsetY;
	}

	function build():Void
	{
		outlineRenderer.vertices.length = 0;
		outlineRenderer.indices.length = 0;
		outlineRenderer.uvtData.length = 0;
		for (renderer in colorRenderers)
		{
			renderer.vertices.length = 0;
			renderer.indices.length = 0;
			renderer.uvtData.length = 0;
		}

		var wrapWidth = textWidth < 0 ? DEFAULT_FIELD_WIDTH : textWidth;
		var arrangement = parsed.arrange(advanceOfCode, wrapWidth, startWithAsterisk, asteriskAdvance(), alignment);
		var stride = face.lineHeight + lineSpacing;

		for (placed in arrangement.glyphs)
		{
			if (_charsVisibles >= 0 && placed.order >= _charsVisibles)
				continue;
			var glyph = face.glyphs.get(placed.code);
			if (glyph == null || glyph.width <= 0 || glyph.height <= 0)
				continue;
			emitGlyph(glyph, placed, placed.line * stride);
		}
	}

	function emitGlyph(glyph:Glyph, placed:Placed, lineTop:Float):Void
	{
		var left = placed.x + glyph.offsetX + offsetX;
		var top = lineTop + glyph.offsetY + offsetY;
		if (!placed.asterisk)
		{
			if (placed.wave)
				top += Math.sin(effectTime * 8 + placed.order * 0.7) * 2;
			if (placed.shake)
			{
				left += Math.sin(effectTime * 35 + placed.order) * 0.5;
				top += Math.cos(effectTime * 31 + placed.order) * 0.5;
			}
			if (placed.order == transientShakeCharacter)
			{
				left += 1;
				top -= 0.5;
			}
			if (outlineSize > 0)
				for (outlineX in -outlineSize...outlineSize + 1)
					for (outlineY in -outlineSize...outlineSize + 1)
						if (outlineX != 0 || outlineY != 0)
							appendGlyphTo(outlineRenderer, glyph, left + outlineX, top + outlineY);
		}
		appendGlyphTo(getColorRenderer(placed.color), glyph, left, top);
	}

	function getColorRenderer(color:Int):FlxStrip
	{
		var renderer = colorRenderers.get(color);
		if (renderer == null)
		{
			renderer = new FlxStrip();
			renderer.loadGraphic(face.graphic);
			colorRenderers.set(color, renderer);
		}
		return renderer;
	}

	function appendGlyphTo(target:FlxStrip, glyph:Glyph, left:Float, top:Float):Void
	{
		var vertex = Std.int(target.vertices.length / 2);
		var radians = angle * Math.PI / 180;
		var cos = Math.cos(radians);
		var sin = Math.sin(radians);
		var x0 = left * scale.x;
		var y0 = top * scale.y;
		var x1 = (left + glyph.width) * scale.x;
		var y1 = (top + glyph.height) * scale.y;
		var u0 = glyph.x / face.atlas.width;
		var v0 = glyph.y / face.atlas.height;
		var u1 = (glyph.x + glyph.width) / face.atlas.width;
		var v1 = (glyph.y + glyph.height) / face.atlas.height;

		pushCorner(target, x0, y0, cos, sin, u0, v0);
		pushCorner(target, x1, y0, cos, sin, u1, v0);
		pushCorner(target, x1, y1, cos, sin, u1, v1);
		pushCorner(target, x0, y1, cos, sin, u0, v1);
		target.indices.push(vertex);
		target.indices.push(vertex + 1);
		target.indices.push(vertex + 2);
		target.indices.push(vertex);
		target.indices.push(vertex + 2);
		target.indices.push(vertex + 3);
	}

	inline function pushCorner(target:FlxStrip, cornerX:Float, cornerY:Float, cos:Float, sin:Float, u:Float, v:Float):Void
	{
		target.vertices.push(cornerX * cos - cornerY * sin);
		target.vertices.push(cornerX * sin + cornerY * cos);
		target.uvtData.push(u);
		target.uvtData.push(v);
	}

	function advanceOfCode(code:Int):Float
	{
		var glyph = face.glyphs.get(code);
		return glyph == null ? 0 : glyph.advance - _subsWidth + letterSpacing;
	}

	function asteriskAdvance():Float
	{
		var glyph = face.glyphs.get(TextLayout.ASTERISK);
		return glyph == null ? 0 : advanceOfCode(TextLayout.ASTERISK) + ASTERISK_GAP;
	}

	function get_text():String
	{
		return _text;
	}

	function set_text(value:String):String
	{
		value = value == null ? "" : value;
		if (value == _text)
			return value;
		_text = value;
		parsed.parse(value);
		layoutDirty = true;
		return value;
	}

	function get_font():String
	{
		return _font;
	}

	function set_font(value:String):String
	{
		if (value != _font)
			loadFont(value);
		return value;
	}

	function get_charsVisibles():Int
	{
		return _charsVisibles;
	}

	function set_charsVisibles(value:Int):Int
	{
		if (value != _charsVisibles)
			layoutDirty = true;
		return _charsVisibles = value;
	}

	function get_subsWidth():Int
	{
		return _subsWidth;
	}

	function set_subsWidth(value:Int):Int
	{
		layoutDirty = true;
		return _subsWidth = value;
	}

	function get_totalCharacters():Int
	{
		return parsed.printableCount;
	}

	function get_measuredWidth():Float
	{
		return parsed.measureWidest(advanceOfCode) * scale.x;
	}

	public static function cleanCache():Void
	{
		for (face in faces)
			face.graphic.destroy();
		faces.clear();
	}

	static function getFace(name:String):Face
	{
		var cached = faces.get(name);
		if (cached != null && cached.graphic.bitmap != null)
			return cached;

		var base = "assets/fonts/" + name + "/" + name;
		var atlas = Assets.getBitmapData(base + ".png");
		var graphic = FlxG.bitmap.add(atlas, false, "undertext:" + name);
		graphic.persist = true;
		graphic.destroyOnNoUse = false;

		var created:Face = {
			graphic: graphic,
			atlas: atlas,
			glyphs: new Map(),
			lineHeight: 16,
			subsWidth: 0
		};
		parseDescriptor(created, Assets.getText(base + ".fnt"));
		if (Assets.exists(base + ".ini"))
		{
			var subtraction = ~/subsWidth=([-0-9]+)/;
			if (subtraction.match(Assets.getText(base + ".ini")))
				created.subsWidth = Std.parseInt(subtraction.matched(1));
		}
		faces.set(name, created);
		return created;
	}

	static function parseDescriptor(target:Face, data:String):Void
	{
		for (line in data.split("\n"))
		{
			var fields = readFields(line);
			if (StringTools.startsWith(line, "common ") && fields.exists("lineHeight"))
			{
				var parsedLineHeight = Std.parseInt(fields.get("lineHeight"));
				if (parsedLineHeight != null && parsedLineHeight > 1)
					target.lineHeight = parsedLineHeight;
			}
			else if (StringTools.startsWith(line, "char "))
				target.glyphs.set(fieldInt(fields, "id"), {
					x: fieldInt(fields, "x"),
					y: fieldInt(fields, "y"),
					width: fieldInt(fields, "width"),
					height: fieldInt(fields, "height"),
					offsetX: fieldInt(fields, "xoffset"),
					offsetY: fieldInt(fields, "yoffset"),
					advance: fieldInt(fields, "xadvance")
				});
		}
	}

	static function readFields(line:String):Map<String, String>
	{
		var fields = new Map<String, String>();
		for (part in line.split(" "))
		{
			var separator = part.indexOf("=");
			if (separator > 0)
				fields.set(part.substr(0, separator), StringTools.trim(part.substr(separator + 1)));
		}
		return fields;
	}

	static inline function fieldInt(fields:Map<String, String>, key:String):Int
	{
		var value = fields.get(key);
		var parsedValue = value == null ? null : Std.parseInt(value);
		return parsedValue == null ? 0 : parsedValue;
	}
}
