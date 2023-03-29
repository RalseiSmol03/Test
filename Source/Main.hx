package;

import android.content.Context;
import android.widget.Toast;
import openfl.Lib;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new():Void
	{
		super();

		var handler:LuaHandler = new LuaHandler(Context.getExternalFilesDir(null) + "/script.lua");
		handler.call('onInit');
		handler.close();
	}
}
