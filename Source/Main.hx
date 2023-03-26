package;

import android.content.Context;
import android.widget.Toast;
import hxminiaudio.MiniAudio;
import hxminiaudio.Types;
import openfl.Lib;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new():Void
	{
		super();

		/*var handler:LuaHandler = new LuaHandler(Context.getExternalFilesDir(null) + "/script.lua");
		handler.setCallback('makeToastText', function(text:String)
		{
			Toast.makeText(text, Toast.LENGTH_LONG);
		});
		handler.call('init');
		handler.close();*/

		trace('MiniAudio Version: ${MiniAudio.VERSION_STRING}');

		var engine:MA_Engine = MA_Engine.create();

		var result:MA_Result = MiniAudio.engine_init(null, cpp.RawPointer.addressOf(engine));
		if (result != MA_SUCCESS)
			Toast.makeText('Failed to initialize audio engine: $result', Toast.LENGTH_LONG);
		else
			Toast.makeText('Successfully initialized the audio engine: $result', Toast.LENGTH_LONG);

		var result:MA_Result = MiniAudio.engine_play_sound(cpp.RawPointer.addressOf(engine), Context.getExternalFilesDir(null) + "/The Caretaker - It's just a burning memory (2016).mp3", null);

		if (result != MA_SUCCESS)
			Toast.makeText('Failed to play a sound: $result', Toast.LENGTH_LONG);
		else
			Toast.makeText('Successfully played a sound: $result', Toast.LENGTH_LONG);
	}
}
