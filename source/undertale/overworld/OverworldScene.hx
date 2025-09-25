package undertale.overworld;

import flixel.FlxState;

class OverworldScene extends FlxState
{
    var chara:Chara;
    override public function create():Void
    {
        super.create();
        chara = new Chara(160,120);
        add(chara);
    }    
}