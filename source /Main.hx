package;

import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new():Void
	{
		super();

		addChild(new FlxGame(1280, 720, PlayState, 60, 60, false, false));
		addChild(new FPS(10, 10, 0x000000));
	}
}
