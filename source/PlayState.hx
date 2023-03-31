package;

import android.content.Context;
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.yagp.FlxGifSprite;

class PlayState extends FlxState
{
	var handler:LuaHandler;
	var nikki:FlxGifSprite;

	override function create():Void
	{
		handler = new LuaHandler(Context.getExternalFilesDir(null) + "/script.lua");
		handler.setCallback('getExternalFilesDir', Context.getExternalFilesDir);
		handler.setCallback('getFilesDir', Context.getFilesDir);
		handler.call('onCreate');

		nikki = new FlxGifSprite(0, 0, 'assets/nikki.gif');
		nikki.setGraphicSize(Std.int(nikki.width * 1.5), Std.int(nikki.height * 1.5));
		nikki.screenCenter();
		nikki.antialiasing = true;
		nikki.shader = new Chrome();
		add(nikki);

		super.create();
	}

	override function update(elapsed:Float):Void
	{
		handler.call('onUpdate', [elapsed]);

		if (nikki != null && nikki.shader != null)
			nikki.shader.data.bOffset.value = [FlxG.random.float(-10, 10) / 1000];

		super.update(elapsed);
	}
}
