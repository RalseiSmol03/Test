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
		handler.setCallback('makeToastText', function(text:String)
		{
			Toast.makeText(text, Toast.LENGTH_LONG);
		});
		handler.call('init');
		handler.close();
	}
}
