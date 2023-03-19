package;

import android.content.Context;
import android.widget.Toast;
import hxlua.Lua;
import hxgamejolt.GameJolt;
import openfl.Lib;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new():Void
	{
		super();

		var handler:LuaHandler = new LuaHandler(Context.getExternalFilesDir(null) + "/script.lua");
		handler.setCallback('gameJoltInit', function(Game_id:String, Private_key:String)
		{
			GameJolt.init(Game_id, Private_key);
			Toast.makeText('GameJolt Init successfully called!!!', Toast.LENGTH_LONG);
		});
		handler.call('init');

		Lib.application.onExit.add(function(code:Int)
		{
			@:privateAccess
			Toast.makeText('Lua Script Executed!\nTotal GC Memory: ${getMemorySize(Lua.gc(handler.vm, Lua.GCCOUNTB, [0]))}', Toast.LENGTH_LONG);

			handler.close();
		});
	}

	public function getMemorySize(size:Float):String
	{
		final labels:Array<String> = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

		var label:Int = 0;

		while (size >= 1000 && (label < labels.length - 1))
		{
			size /= 1000;
			label++;
		}

		return '${Std.int(size) + "." + addZeros(Std.string(Std.int((size % 1) * 100)), 2)}${labels[label]}';
	}

	public inline function addZeros(str:String, num:Int)
	{
		while (str.length < num)
			str = '0${str}';

		return str;
	}
}
