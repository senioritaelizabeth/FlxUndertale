package undertale;

import flixel.FlxG;
import flixel.FlxState;
import undertale.overworld.OverworldScene;

class LoaderState extends FlxState
{
    override public function create():Void
    {
        super.create();
        trace("Loader State Created");
        FlxG.switchState(OverworldScene.new);
    }
    
}