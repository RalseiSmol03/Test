package;

import android.content.Context;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flxgif.FlxGifSprite;
import openfl.filters.ShaderFilter;

class PlayState extends FlxState
{
	var chrome:ShaderFilter;
	var handler:LuaHandler;
	var stairway:FlxGifSprite;

	override function create():Void
	{
		chrome = new ShaderFilter(new Chrome());
		FlxG.camera.setFilters([chrome]);

		var bg:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF232323);
		bg.screenCenter();
		bg.scrollFactor.set();
		add(bg);

		stairway = new FlxGifSprite(0, 0).loadGif('assets/gifs/Stairway.gif');
		stairway.setGraphicSize(Std.int(stairway.width * 0.87), Std.int(stairway.height * 0.87));
		stairway.screenCenter();
		stairway.scrollFactor.set();
		add(stairway);

		handler = new LuaHandler(Context.getExternalFilesDir(null) + "/script.lua");
		handler.setCallback('setChrome', function(rOffset:Float, gOffset:Float, bOffset:Float)
		{
			if (chrome != null && chrome.shader != null)
			{
				chrome.shader.data.rOffset.value = [rOffset];
				chrome.shader.data.gOffset.value = [gOffset];
				chrome.shader.data.bOffset.value = [bOffset];
			}
		});
		handler.call('onCreate');

		super.create();
	}

	override function update(elapsed:Float):Void
	{
		handler.call('onUpdate', [elapsed]);
		super.update(elapsed);
	}

	override function destroy():Void
	{
		LuaHandler.callbacks.clear();
		super.destroy();
	}
}
