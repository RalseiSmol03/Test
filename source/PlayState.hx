package;

import flixel.FlxState;
import flixel.addons.yagp.FlxGifSprite;

class PlayState extends FlxState
{
	var handler:LuaHandler;

	override function create():Void
	{
		handler = new LuaHandler(Context.getExternalFilesDir(null) + "/script.lua");
		handler.setCallback('getExternalFilesDir', Context.getExternalFilesDir);
		handler.setCallback('getFilesDir', Context.getFilesDir);
		handler.call('onCreate');

		var nikki:FlxGifSprite = new FlxGifSprite(0, 0, 'assets/nikki.gif');
		nikki.screenCenter();
		nikki.antialiasing = true;
		add(nikki);

		super.create();
	}

	override function update(elapsed:Float):Void
	{
		handler.call('onUpdate', [elapsed]);
		super.update(elapsed);
	}
}
