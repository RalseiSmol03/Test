package;

import android.content.Context;
import openfl.Lib;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new():Void
	{
		super();

		var handler:LuaHandler = new LuaHandler(Context.getExternalFilesDir(null) + "/script.lua");
		handler.setCallback('getExternalFilesDir', Context.getExternalFilesDir);
		handler.setCallback('getFilesDir', Context.getFilesDir);
		handler.call('onInit');
		handler.close();
	}
}
