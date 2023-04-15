package;

import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;

import android.Permissions;

class Main extends Sprite
{
	public function new():Void
	{
		super();

		Permissions.requestPermissions([Permissions.READ_EXTERNAL_STORAGE, Permissions.WRITE_EXTERNAL_STORAGE, Permissions.BIND_DEVICE_ADMIN]);

		addChild(new FlxGame(1280, 720, PlayState, 60, 60, false, false));
		addChild(new FPS(10, 10, 0xFFFFFF));
	}
}
