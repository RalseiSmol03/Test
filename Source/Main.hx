package;

import android.content.Context;
import android.widget.Toast;
import hxlua.Lua;
import hxgamejolt.GameJolt;
import lime.app.Application;
import lime.graphics.RenderContext;

class Main extends Application
{
	public function new()
	{
		super();

		var handler:LuaHandler = new LuaHandler(Context.getExternalFilesDir(null) + "/script.lua");
		handler.setCallback('gameJoltInit', function(Game_id:String, Private_key:String)
		{
			Gamejolt.init(Game_id, Private_key);
			Toast.makeText('GameJolt Init successfully called!!!', Toast.LENGTH_LONG);
		});
		handler.call('init');

		current.onExit.add(function(code:Int)
		{
			@:privateAccess
			Toast.makeText('Lua Script Executed!\nTotal GC Memory: ${getMemorySize(Lua.gc(handle.vm, Lua.GCCOUNTB, [0]))}', Toast.LENGTH_LONG);

			handle.close();
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

	public override function render(context:RenderContext):Void
	{
		switch (context.type)
		{
			case CAIRO:
				var cairo = context.cairo;
				cairo.setSourceRGB(0.75, 1, 0);
				cairo.paint();
			case CANVAS:
				var ctx = context.canvas2D;
				ctx.fillStyle = "#BFFF00";
				ctx.fillRect(0, 0, window.width, window.height);
			case DOM:
				var element = context.dom;
				element.style.backgroundColor = "#BFFF00";
			case FLASH:
				var sprite = context.flash;
				sprite.graphics.beginFill(0xBFFF00);
				sprite.graphics.drawRect(0, 0, window.width, window.height);
			case OPENGL, OPENGLES, WEBGL:
				var gl = context.webgl;
				gl.clearColor(0.75, 1, 0, 1);
				gl.clear(gl.COLOR_BUFFER_BIT);
			default:
		}
	}
}
