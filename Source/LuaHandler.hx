package;

import android.content.Context;
import haxe.DynamicAccess;
import hxlua.Lua;
import hxlua.LuaL;
import hxlua.Types;
import lime.app.Application;

using StringTools;

class LuaHandler
{
	private static var callbacks:Map<String, Dynamic> = [];

	private var vm:cpp.RawPointer<Lua_State>;

	public function new(path:String):Void
	{
		// create a new lua instance
		vm = LuaL.newstate();

		LuaL.openlibs(vm);

		// make a new file with the instance and check if it can be ran
		var status:Int = LuaL.dofile(vm, Context.getExternalFilesDir(null) + path);
		if (status != Lua.OK)
		{
			var error:String = getErrorMessage(status, 0);
			if (error == null)
				return stop();

			Application.current.window.alert(error, 'Lua Script Error!');
			return stop();
		}
	}

	public function call(name:String, args:Array<Dynamic>):Dynamic
	{
		if (vm == null)
			return 0;

		Lua.getglobal(vm, name);

		var type:Int = Lua.type(vm, -1);

		if (type != Lua.TFUNCTION)
		{
			if (type > Lua.TNIL)
				Application.current.window.alert("attempt to call a " + Lua.typename(vm, type) + " value as a callback", 'Lua Call Error!');

			Lua.pop(vm, 1);
			return 0;
		}

		if (args != null)
			for (arg in args)
				toLua(vm, arg);

		var status:Int = Lua.pcall(vm, args.length, 1, 0);
		if (status != Lua.OK)
		{
			var error:String = getErrorMessage(status);
			if (error == null)
				return 0;

			Application.current.window.alert(error, 'Lua Call Error!');
			return 0;
		}

		var result:Dynamic = fromLua(vm, -1);
		if (result == null)
			result = 0;

		Lua.pop(vm, 1);
		return result;
	}

	public function set(name:String, value:Dynamic):Void
	{
		if (vm == null)
			return;

		toLua(vm, value);
		Lua.setglobal(vm, name);
	}

	public function remove(name:String):Void
	{
		if (vm == null)
			return;

		Lua.pushnil(vm);
		Lua.setglobal(vm, name);
	}

	public function stop():Void
	{
		if (vm == null)
			return;

		callbacks.clear();
		Lua.close(vm);
		vm = null;
	}

	public function setCallback(name:String, callback:Dynamic):Void
	{
		if (vm == null || (callbacks.exists(name) || !Reflect.isFunction(callback)))
			return;

		callbacks.set(name, callback);

		Lua.pushstring(vm, name);
		Lua.pushcclosure(vm, cpp.Callable.fromStaticFunction(callbackHandler), 1);
		Lua.setglobal(vm, name);
	}

	public function removeCallback(name:String):Void
	{
		if (vm == null || !callbacks.exists(name))
			return;

		callbacks.remove(name);

		Lua.pushnil(vm);
		Lua.setglobal(vm, name);
	}

	private function getErrorMessage(status:Int, ?number:Int = 1):String
	{
		var ret:String = Lua.tostring(vm, -1);
		Lua.pop(vm, number);

		if (ret != null)
			ret = ret.trim();

		if (ret == null || (ret != null && ret.length <= 0))
		{
			switch (status)
			{
				case t if (t == Lua.ERRRUN):
					return "Runtime Error";
				case t if (t == Lua.ERRMEM):
					return "Memory Allocation Error";
				case t if (t == Lua.ERRERR):
					return "Critical Error";
				default:
					return "Unknown Error";
			}
		}

		return ret;
	}

	private static function callbackHandler(L:cpp.RawPointer<Lua_State>):Int
	{
		var name:String = Lua.tostring(L, Lua.upvalueindex(1));

		if (!callbacks.exists(name) || callbacks.get(name) == null)
			return 0;

		var args:Array<Dynamic> = [];

		for (i in 0...Lua.gettop(L))
			args[i] = fromLua(L, i + 1);

		var ret:Dynamic = Reflect.callMethod(null, callbacks.get(name), args);

		if (ret != null)
		{
			toLua(L, ret);
			return 1;
		}

		return 0;
	}

	public static function toLua(L:cpp.RawPointer<Lua_State>, object:Any):Bool
	{
		switch (Type.typeof(object))
		{
			case TNull:
				Lua.pushnil(L);
			case TBool:
				Lua.pushboolean(L, object ? 1 : 0);
			case TInt:
				Lua.pushinteger(L, object);
			case TFloat:
				Lua.pushnumber(L, object);
			case TClass(String):
				Lua.pushstring(L, object);
			case TClass(Array):
				var arr:Array<Any> = object;

				Lua.createtable(L, arr.length, 0);

				for (i in 0...arr.length)
				{
					Lua.pushnumber(L, i + 1);
					toLua(L, arr[i]);
					Lua.settable(L, -3);
				}

			case TClass(haxe.ds.StringMap) | TClass(haxe.ds.ObjectMap):
				var tLen:Int = 0;
				for (n => val in object)
					tLen++;

				Lua.createtable(L, tLen, 0);

				for (n => val in object)
				{
					Lua.pushstring(L, Std.string(n));
					toLua(L, val);
					Lua.settable(L, -3);
				}

			case TObject:
				var tLen:Int = 0;
				for (n in Reflect.fields(object))
					tLen++;

				Lua.createtable(L, tLen, 0);

				for (n in Reflect.fields(object))
				{
					Lua.pushstring(L, n);
					toLua(L, Reflect.field(object, n));
					Lua.settable(L, -3);
				}
			default:
				trace('Cannot convert ${Type.typeof(object)} to Lua');
				return false;
		}

		return true;
	}

	public static function fromLua(L:cpp.RawPointer<Lua_State>, v:Int):Any
	{
		var ret:Any = null;

		switch (Lua.type(L, v))
		{
			case t if (t == Lua.TNIL):
				ret = null;
			case t if (t == Lua.TBOOLEAN):
				ret = Lua.toboolean(L, v) == 1 ? true : false;
			case t if (t == Lua.TNUMBER):
				ret = Lua.tonumber(L, v);
			case t if (t == Lua.TSTRING):
				ret = Lua.tostring(L, v);
			case t if (t == Lua.TTABLE):
				var count:Int = 0;
				var array:Bool = true;

				Lua.pushnil(L);
				while (Lua.next(L, v < 0 ? v - 1 : v) != 0)
				{
					if (array)
					{
						if (Lua.type(L, -2) != Lua.TNUMBER)
							array = false;
						else
						{
							var index = Lua.tonumber(L, -2);
							if (index < 0 || Std.int(index) != index)
								array = false;
						}
					}

					count++;
					Lua.pop(L, 1);
				}

				if (count == 0)
					ret = {};
				else if (array)
				{
					var vArray:Array<Any> = [];

					Lua.pushnil(L);

					while (Lua.next(L, v < 0 ? v - 1 : v) != 0)
					{
						vArray[Std.int(Lua.tonumber(L, -2)) - 1] = fromLua(L, -1);
						Lua.pop(L, 1);
					}

					ret = cast vArray;
				}
				else
				{
					var vAccess:DynamicAccess<Any> = {};

					Lua.pushnil(L);

					while (Lua.next(L, v < 0 ? v - 1 : v) != 0)
					{
						switch (Lua.type(L, -2))
						{
							case t if (t == Lua.TSTRING):
								vAccess.set(Lua.tostring(L, -2), fromLua(L, -1));
							case t if (t == Lua.TNUMBER):
								vAccess.set(Std.string(Lua.tonumber(L, -2)), fromLua(L, -1));
						}

						Lua.pop(L, 1);
					}

					ret = cast vAccess;
				}
			default:
				trace('Cannot return ${Lua.typename(L, v)} in Haxe');
				ret = null;
		}

		return ret;
	}
}
