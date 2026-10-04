package undertale.text;

typedef Pause =
{
	at:Int,
	frames:Float
}

typedef Placed =
{
	code:Int,
	color:Int,
	wave:Bool,
	shake:Bool,
	x:Float,
	line:Int,
	order:Int,
	asterisk:Bool
}

typedef Arrangement =
{
	glyphs:Array<Placed>,
	lineCount:Int
}

private typedef Line =
{
	first:Int,
	last:Int,
	width:Float,
	asterisk:Bool
}

private class Token
{
	public final code:Int;
	public final color:Int;
	public final wave:Bool;
	public final shake:Bool;

	public function new(code:Int, color:Int, wave:Bool, shake:Bool)
	{
		this.code = code;
		this.color = color;
		this.wave = wave;
		this.shake = shake;
	}

	public inline function isNewline():Bool
	{
		return code == TextLayout.NEWLINE;
	}

	public inline function isSpace():Bool
	{
		return code == TextLayout.SPACE;
	}
}

/**
 * Parses the text markup and lays out the characters.
 * Markup: `[color=#RRGGBB]..[/color]`, `[wave]..[/wave]`, `[shake]..[/shake]`, `[pause=frames]`,
 * `#` = new line. Escape `#`, `[` and `\` with a backslash.
 */
class TextLayout
{
	public static inline var NEWLINE:Int = 10;
	public static inline var SPACE:Int = 32;
	public static inline var ASTERISK:Int = 42;
	static inline var HASH:Int = 35;
	static inline var BACKSLASH:Int = 92;
	static inline var OPEN_BRACKET:Int = 91;
	static final namedColors:Map<String, Int> = [
		"white" => 0xFFFFFFFF,
		"black" => 0xFF000000,
		"red" => 0xFFFF0000,
		"green" => 0xFF00FF00,
		"blue" => 0xFF0000FF,
		"yellow" => 0xFFFFFF00,
		"orange" => 0xFFFFA040,
		"purple" => 0xFFD535D8,
		"gray" => 0xFF808080,
		"grey" => 0xFF808080,
		"cyan" => 0xFF00FFFF,
		"magenta" => 0xFFFF00FF
	];

	public var pauses(default, null):Array<Pause> = [];
	public var printableCount(default, null):Int = 0;
	public var hasEffects(default, null):Bool = false;

	var tokens:Array<Token> = [];

	public function new(text:String = "")
	{
		parse(text);
	}

	public function parse(text:String):Void
	{
		tokens = [];
		pauses = [];
		printableCount = 0;
		hasEffects = false;
		var color = 0xFFFFFFFF;
		var wave = false;
		var shake = false;
		var index = 0;
		var length = text.length;

		while (index < length)
		{
			var code = text.charCodeAt(index);
			if (code == BACKSLASH && index + 1 < length)
			{
				var escaped = text.charCodeAt(index + 1);
				if (escaped == HASH || escaped == BACKSLASH || escaped == OPEN_BRACKET)
				{
					tokens.push(new Token(escaped, color, wave, shake));
					printableCount++;
					index += 2;
					continue;
				}
			}
			if (code == OPEN_BRACKET)
			{
				var close = text.indexOf("]", index);
				if (close > index)
				{
					var tag = text.substring(index + 1, close);
					var handled = true;
					if (tag == "wave")
					{
						wave = true;
						hasEffects = true;
					}
					else if (tag == "/wave")
						wave = false;
					else if (tag == "shake")
					{
						shake = true;
						hasEffects = true;
					}
					else if (tag == "/shake")
						shake = false;
					else if (tag == "/color")
						color = 0xFFFFFFFF;
					else if (StringTools.startsWith(tag, "color="))
						color = parseColor(tag.substr(6));
					else if (StringTools.startsWith(tag, "pause="))
					{
						var frames = Std.parseFloat(tag.substr(6));
						pauses.push({at: printableCount, frames: Math.isNaN(frames) ? 0 : frames});
					}
					else
						handled = false;
					if (handled)
					{
						index = close + 1;
						continue;
					}
				}
			}
			if (code == HASH)
				code = NEWLINE;
			tokens.push(new Token(code, color, wave, shake));
			if (code != NEWLINE)
				printableCount++;
			index++;
		}
	}

	public function codeAt(printableIndex:Int):Int
	{
		var count = 0;
		for (token in tokens)
		{
			if (token.isNewline())
				continue;
			if (count == printableIndex)
				return token.code;
			count++;
		}
		return -1;
	}

	public function pauseFramesAt(count:Int):Float
	{
		var total = 0.0;
		for (pause in pauses)
			if (pause.at == count)
				total += pause.frames;
		return total;
	}

	public function measureWidest(advance:Int->Float):Float
	{
		var widest = 0.0;
		var current = 0.0;
		for (token in tokens)
		{
			if (token.isNewline())
			{
				widest = Math.max(widest, current);
				current = 0;
			}
			else
				current += advance(token.code);
		}
		return Math.max(widest, current);
	}

	public function arrange(advance:Int->Float, wrapWidth:Float, startWithAsterisk:Bool, asteriskAdvance:Float, alignment:String):Arrangement
	{
		var lines = breakLines(advance, wrapWidth, startWithAsterisk, asteriskAdvance);
		var glyphs:Array<Placed> = [];
		var order = 0;

		for (lineIndex in 0...lines.length)
		{
			var line = lines[lineIndex];
			var pen = alignmentOffset(alignment, line.width, wrapWidth);
			if (line.asterisk)
				glyphs.push({
					code: ASTERISK,
					color: 0xFFFFFFFF,
					wave: false,
					shake: false,
					x: pen,
					line: lineIndex,
					order: order,
					asterisk: true
				});
			if (startWithAsterisk)
				pen += asteriskAdvance;
			for (tokenIndex in line.first...line.last)
			{
				var token = tokens[tokenIndex];
				if (token.isNewline())
					continue;
				glyphs.push({
					code: token.code,
					color: token.color,
					wave: token.wave,
					shake: token.shake,
					x: pen,
					line: lineIndex,
					order: order,
					asterisk: false
				});
				pen += advance(token.code);
				order++;
			}
		}
		return {glyphs: glyphs, lineCount: lines.length};
	}

	function breakLines(advance:Int->Float, wrapWidth:Float, startWithAsterisk:Bool, asteriskAdvance:Float):Array<Line>
	{
		var lines:Array<Line> = [];
		var indent = startWithAsterisk ? asteriskAdvance : 0.0;
		var first = 0;
		var width = indent;
		var asterisk = startWithAsterisk;
		var index = 0;
		var count = tokens.length;

		while (index < count)
		{
			var token = tokens[index];
			if (token.isNewline())
			{
				lines.push({
					first: first,
					last: index,
					width: trimmedWidth(first, index, width, advance),
					asterisk: asterisk
				});
				first = index + 1;
				width = indent;
				asterisk = startWithAsterisk;
				index++;
				continue;
			}
			if (token.isSpace())
			{
				width += advance(token.code);
				index++;
				continue;
			}

			var wordEnd = index;
			var wordWidth = 0.0;
			while (wordEnd < count && !tokens[wordEnd].isNewline() && !tokens[wordEnd].isSpace())
			{
				wordWidth += advance(tokens[wordEnd].code);
				wordEnd++;
			}
			if (width + wordWidth > wrapWidth && width > indent)
			{
				lines.push({
					first: first,
					last: index,
					width: trimmedWidth(first, index, width, advance),
					asterisk: asterisk
				});
				first = index;
				width = indent;
				asterisk = false;
			}
			for (cursor in index...wordEnd)
			{
				var step = advance(tokens[cursor].code);
				if (width + step > wrapWidth && width > indent)
				{
					lines.push({
						first: first,
						last: cursor,
						width: width,
						asterisk: asterisk
					});
					first = cursor;
					width = indent;
					asterisk = false;
				}
				width += step;
			}
			index = wordEnd;
		}
		lines.push({
			first: first,
			last: count,
			width: trimmedWidth(first, count, width, advance),
			asterisk: asterisk
		});
		return lines;
	}

	function trimmedWidth(first:Int, last:Int, width:Float, advance:Int->Float):Float
	{
		var cursor = last - 1;
		while (cursor >= first && tokens[cursor].isSpace())
		{
			width -= advance(tokens[cursor].code);
			cursor--;
		}
		return width;
	}

	static function alignmentOffset(alignment:String, lineWidth:Float, wrapWidth:Float):Float
	{
		return switch alignment
		{
			case "CENTER": Math.max(0, (wrapWidth - lineWidth) * 0.5);
			case "RIGHT": Math.max(0, wrapWidth - lineWidth);
			default: 0;
		}
	}

	static function parseColor(value:String):Int
	{
		if (StringTools.startsWith(value, "#"))
		{
			var digits = value.substr(1);
			if (digits.length == 3)
				digits = digits.charAt(0) + digits.charAt(0) + digits.charAt(1) + digits.charAt(1) + digits.charAt(2) + digits.charAt(2);
			var parsed = Std.parseInt("0x" + digits);
			return parsed == null ? 0xFFFFFFFF : (0xFF000000 | parsed);
		}
		var named = namedColors.get(value.toLowerCase());
		return named == null ? 0xFFFFFFFF : named;
	}
}
