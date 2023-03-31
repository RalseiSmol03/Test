package;

import flixel.system.FlxAssets.FlxShader;

class Chrome extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform float rOffset;
		uniform float gOffset;
		uniform float bOffset;

		void main()
		{
		  vec4 toUse = texture2D(bitmap, openfl_TextureCoordv);
		  toUse.r = texture2D(bitmap, openfl_TextureCoordv.st - vec2(rOffset, 0.0)).r;
		  toUse.g = texture2D(bitmap, openfl_TextureCoordv.st - vec2(gOffset, 0.0)).g;
		  toUse.b = texture2D(bitmap, openfl_TextureCoordv.st - vec2(bOffset, 0.0)).b;
		  gl_FragColor = toUse;
		}
	')
	public function new():Void
	{
		super();

		data.rOffset.value = [0.0];
		data.gOffset.value = [0.0];
		data.bOffset.value = [0.0];
	}
}
