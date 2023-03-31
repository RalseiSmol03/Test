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
		nikki.shader = new Chrome();
		nikki.antialiasing = true;
		nikki.screenCenter();
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
