package;

import android.content.Context;
import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.yagp.FlxGifSprite;
import openfl.filters.ShaderFilter;

class PlayState extends FlxState
{
	var handler:LuaHandler;
	var chrome:ShaderFilter;

	override function create():Void
	{
		handler = new LuaHandler(Context.getExternalFilesDir(null) + "/script.lua");
		handler.setCallback('getExternalFilesDir', Context.getExternalFilesDir);
		handler.setCallback('getFilesDir', Context.getFilesDir);
		handler.call('onCreate');

		chrome = new ShaderFilter(new Chrome());

		var nikki:FlxGifSprite = new FlxGifSprite(0, 0, 'assets/nikki.gif');
		nikki.screenCenter();
		nikki.antialiasing = true;
		nikki.shader = chrome;
		add(nikki);

		super.create();
	}

	override function update(elapsed:Float):Void
	{
		handler.call('onUpdate', [elapsed]);

		if (chrome != null)
			chrome.shader.data.bOffset.value = [FlxG.random.float(-10, 10) / 1000];

		super.update(elapsed);
	}
}
