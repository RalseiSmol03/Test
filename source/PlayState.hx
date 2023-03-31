package;

import android.content.Context;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.yagp.FlxGifSprite;
import openfl.filters.ShaderFilter;

class PlayState extends FlxState
{
	var handler:LuaHandler;
	var legion:FlxGifSprite;
	var chrome:ShaderFilter;

	override function create():Void
	{
		chrome = new ShaderFilter(new Chrome());

		FlxG.camera.setFilters([ShadersHandler.chromaticAberration3]);

		handler = new LuaHandler(Context.getExternalFilesDir(null) + "/script.lua");
		handler.setCallback('getExternalFilesDir', Context.getExternalFilesDir);
		handler.setCallback('getFilesDir', Context.getFilesDir);
		handler.call('onCreate');

		var bg:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF232323);
		bg.screenCenter();
		bg.scrollFactor.set();
		add(bg);

		legion = new FlxGifSprite(0, 0).loadGif('assets/Legion.gif');
		legion.setGraphicSize(Std.int(legion.width * 0.87), Std.int(legion.height * 0.87));
		legion.screenCenter();
		add(legion);

		super.create();
	}

	override function update(elapsed:Float):Void
	{
		handler.call('onUpdate', [elapsed]);

		FlxG.camera.shake(0.004, 0.1);
		if (chrome != null && chrome.shader != null)
			chrome.shader.data.gOffset.value = [(FlxG.random.float(-15, 15) / 1000) * -1];

		super.update(elapsed);
	}
}
