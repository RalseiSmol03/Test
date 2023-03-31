package;

import android.content.Context;
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.yagp.FlxGifSprite;

class PlayState extends FlxState
{
	var handler:LuaHandler;
	var legion:FlxGifSprite;

	override function create():Void
	{
		handler = new LuaHandler(Context.getExternalFilesDir(null) + "/script.lua");
		handler.setCallback('getExternalFilesDir', Context.getExternalFilesDir);
		handler.setCallback('getFilesDir', Context.getFilesDir);
		handler.call('onCreate');

		legion = new FlxGifSprite(0, 0, 'assets/Legion.gif');
		legion.setGraphicSize(Std.int(legion.width * 1.5), Std.int(legion.height * 1.5));
		legion.screenCenter();
		legion.antialiasing = true;
		legion.shader = new Chrome();
		add(legion);

		super.create();
	}

	override function update(elapsed:Float):Void
	{
		handler.call('onUpdate', [elapsed]);

		if (legion != null && legion.shader != null)
			legion.shader.data.bOffset.value = [FlxG.random.float(-10, 10) / 1000];

		super.update(elapsed);
	}
}
