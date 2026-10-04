package undertale.initialize;

/** Cursor movement over the name entry character grid. */
class NameGrid
{
	public static inline var ROWS:Int = 8;
	public static inline var COLS:Int = 7;
	public static inline var BLOCK_ROWS:Int = 4;
	public static inline var MENU_ROW:Int = -1;
	public static inline var MENU_COLS:Int = 3;
	public static inline var GRID_X:Float = 60;
	public static inline var CELL_WIDTH:Float = 32;
	static inline var MENU_SNAP:Float = 10;
	static inline var GUARD_LIMIT:Int = 64;

	public final menuX:Array<Float>;
	public final charmap:Array<Array<String>> = buildCharmap();
	public var row:Int = 0;
	public var col:Int = 0;

	public function new(menuX:Array<Float>)
	{
		this.menuX = menuX;
	}

	public function cellAt(rowIndex:Int, colIndex:Int):String
	{
		return charmap[rowIndex][colIndex];
	}

	public function selectedCharacter():String
	{
		return row < 0 ? "" : charmap[row][col];
	}

	public function reset():Void
	{
		row = 0;
		col = 0;
	}

	public function navigate(pressedRight:Bool, pressedLeft:Bool, pressedDown:Bool, pressedUp:Bool):Void
	{
		if (!pressedRight && !pressedLeft && !pressedDown && !pressedUp)
			return;

		var oldCol = col;
		var guard = 0;
		do
		{
			if (pressedRight)
			{
				col++;
				if (row == MENU_ROW)
				{
					if (col >= MENU_COLS)
						col = 0;
				}
				else if (col >= COLS)
				{
					if (row == ROWS - 1)
					{
						col = oldCol;
						break;
					}
					col = 0;
					row++;
				}
			}
			if (pressedLeft)
			{
				col--;
				if (col < 0)
				{
					if (row == 0)
						col = 0;
					else if (row > 0)
					{
						col = COLS - 1;
						row--;
					}
					else
						col = MENU_COLS - 1;
				}
			}
			if (pressedDown)
				moveDown();
			if (pressedUp)
				moveUp();
		}
		while (!(col < 0 || row < 0 || charmap[row][col] != "") && ++guard < GUARD_LIMIT);
	}

	function moveDown():Void
	{
		if (row == MENU_ROW)
		{
			row = 0;
			col = nearestColumn(menuX[col]);
			return;
		}
		row++;
		if (row >= ROWS)
		{
			row = MENU_ROW;
			col = menuIndexAt(cellX(col));
		}
	}

	function moveUp():Void
	{
		if (row == MENU_ROW)
		{
			row = ROWS - 1;
			if (col > 0)
				col = nearestColumn(menuX[col]);
			return;
		}
		row--;
		if (row == MENU_ROW)
			col = menuIndexAt(cellX(col));
	}

	function nearestColumn(x:Float):Int
	{
		var best = 0;
		var bestDifference = Math.abs(cellX(0) - x);
		for (i in 1...COLS)
		{
			var difference = Math.abs(cellX(i) - x);
			if (difference < bestDifference)
			{
				best = i;
				bestDifference = difference;
			}
		}
		return best;
	}

	function menuIndexAt(x:Float):Int
	{
		if (x >= menuX[2] - MENU_SNAP)
			return 2;
		if (x >= menuX[1] - MENU_SNAP)
			return 1;
		return 0;
	}

	public static inline function cellX(column:Int):Float
	{
		return GRID_X + column * CELL_WIDTH;
	}

	static function buildCharmap():Array<Array<String>>
	{
		var map:Array<Array<String>> = [];
		for (alphabet in ["ABCDEFGHIJKLMNOPQRSTUVWXYZ", "abcdefghijklmnopqrstuvwxyz"])
			for (r in 0...BLOCK_ROWS)
				map.push([
					for (c in 0...COLS)
						r * COLS + c < alphabet.length ? alphabet.charAt(r * COLS + c) : ""
				]);
		return map;
	}
}
