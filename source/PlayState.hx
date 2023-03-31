package;

import android.content.Context;
import flixel.FlxG;
import flixel.FlxSprite;
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

		var bg:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF232323);
		bg.screenCenter();
		bg.scrollFactor.set();
		add(bg);

		legion = new FlxGifSprite(0, 0, 'assets/Legion.gif');
		// legion.setGraphicSize(Std.int(legion.width * 1.1), Std.int(legion.height * 1.1));
		legion.screenCenter();
		legion.shader = new Chrome();
		add(legion);

		super.create();
	}

	override function update(elapsed:Float):Void
	{
		handler.call('onUpdate', [elapsed]);

		if (legion != null && legion.shader != null)
			legion.shader.data.gOffset.value = [(FlxG.random.float(-15, 15) / 1000) * -1];

		super.update(elapsed);
	}
}
