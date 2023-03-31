package;

import android.content.Context;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.yagp.FlxGifSprite;
#if (flixel >= "5.3.0")
import flixel.sound.FlxSound;
#else
import flixel.system.FlxSound;
#end
import openfl.filters.ShaderFilter;

class PlayState extends FlxState
{
	var chrome:ShaderFilter;
	var handler:LuaHandler;

	var legion:FlxGifSprite;
	var inst:FlxSound;
	var voices:FlxSound;

	override function create():Void
	{
		chrome = new ShaderFilter(new Chrome());

		FlxG.camera.setFilters([chrome]);

		handler = new LuaHandler(Context.getExternalFilesDir(null) + "/script.lua");
		handler.setCallback('getExternalFilesDir', Context.getExternalFilesDir);
		handler.setCallback('getFilesDir', Context.getFilesDir);
		handler.call('onCreate');

		var bg:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF232323);
		bg.screenCenter();
		bg.scrollFactor.set();
		add(bg);

		stairway = new FlxGifSprite(0, 0).loadGif('assets/gifs/Stairway.gif');
		stairway.setGraphicSize(Std.int(stairway.width * 0.87), Std.int(stairway.height * 0.87));
		stairway.screenCenter();
		stairway.scrollFactor.set();
		add(stairway);

		inst = new FlxSound().loadEmbedded('assets/audio/Pteromerhanophobia_Inst.ogg');
		vocals = new FlxSound().loadEmbedded('assets/audio/Pteromerhanophobia_Voices.ogg');

		for (music in [inst, vocals])
			FlxG.sound.list.add(music);

		super.create();

		for (music in [inst, vocals])
			music.play();
	}

	override function update(elapsed:Float):Void
	{
		handler.call('onUpdate', [elapsed]);

		if (chrome != null && chrome.shader != null)
			chrome.shader.data.bOffset.value = [(FlxG.random.float(-10, 10) / 1000) * -1];

		super.update(elapsed);

		if (Math.abs(inst.time - vocals.time) > 20)
			vocals.time = inst.time;
	}
}
