# FlxUndertale

ALL of this code is based on Undertale v1.0.8 (steam) - Please be patient, some of the code need some docs and better code but still.

## Run

```
lime test hl -debug   # debug build (physics debugger, debug menu in the logo screen)
lime test hl          # release build
```

## Debug builds only

| Key | Action |
| --- | --- |
| F4 | Show / hide the physics debugger |
| F8 | Record a short physics trace to `debug/physics_trace.csv` |

## Structure

```
source/
  Main.hx                 entry point
  undertale/
    core/                 AssetsPath, Constants, Global, UnderState (base state)
    initialize/           LoaderState, intro, logo, main menu and name entry
    overworld/            overworld scene and the player character
    battle/               battle scene, soul, battle box, HUD, game over
      attacks/            things that hurt the soul (bullet, circle, polygon)
    physics/              collision shapes, overlap tests and gravity movement
    text/                 bitmap font text, markup parser and typewriter
    debug/                PhysicsDebugger
    util/                 ScreenCapture (freeze the last frame)
    ui/                   UI related stuff
```

## Assets

Always go through `AssetsPath` instead of writing paths by hand:

```haxe
AssetsPath.image("battle/spr_dodgeheart"); // assets/images/battle/spr_dodgeheart.png
AssetsPath.sound("hurt", "wav");           // assets/sounds/hurt.wav
AssetsPath.music("menu0");                 // assets/music/menu0.ogg
```

