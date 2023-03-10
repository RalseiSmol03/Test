package;

import haxe.DynamicAccess;
import haxe.macro.Expr;

import hxlua.Lua;
import hxlua.LuaL;
import hxlua.Types;

// Mostly a fork of https://github.com/superpowers04/linc_luajit/blob/master/llua/Convert.hx
class Convert
{
	public static function toLua(L:cpp.RawPointer<Lua_State>, object:Any):Bool
	{
		switch (Type.typeof(val))
		{
			case TNull:
				Lua.pushnil(L);
			case TBool:
				Lua.pushboolean(L, object ? 1 : 0);
			case TInt:
				Lua.pushinteger(L, object);
			// case TFunction:
			// 	Lua.pushcfunction(L, object);
			case TFloat:
				Lua.pushnumber(L, object);
			case TClass(String):
				Lua.pushstring(L, object);
			case TClass(Array):
				Lua.createtable(L, object.length, 0);

				for (i in 0...object.length)
				{
					Lua.pushnumber(L, i + 1);
					toLua(L, object[i]);
					Lua.settable(L, -3);
				}
			case TClass(haxe.ds.StringMap) | TClass(haxe.ds.ObjectMap):
				var tLen:Int = 0;
				for (n in object.keys())
					tLen++;

				Lua.createtable(L, tLen, 0);

				for (index => val in object)
				{
					Lua.pushstring(L, Std.string(index));
					toLua(L, object);
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
				trace('Cannot convert ${Type.typeof(val)} to Lua');
				return false;
		}

		return true;
	}

	public static function fromLua(L:cpp.RawPointer<Lua_State>, v:Int):Any
	{
		var ret:Any = null;

		switch (Lua.type(L, v))
		{
			case Lua.TNIL:
				ret = null;
			case Lua.TBOOLEAN:
				ret = Lua.toboolean(L, v) == 1 ? true : false;
			case Lua.TNUMBER:
				ret = Lua.tonumber(L, v);
			case Lua.TSTRING:
				ret = Lua.tostring(L, v);
			case Lua.TTABLE:
				ret = toHaxeObj(L, v);
			default:
				trace('Cannot return ${Lua.typename(L, v)} in Haxe');
				ret = null;
		}

		return ret;
	}

	public static function toHaxeObj(L:cpp.RawPointer<Lua_State>, v:Int):Any
	{
		var count:Int = 0;
		var array:Bool = true;

		loopTable(L, i, {
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
		});

		return if (count == 0)
		{
			{};
		}
		else if (array)
		{
			var v:Array<Any> = [];

			loopTable(L, i, {
				v[Std.int(Lua.tonumber(L, -2)) - 1] = fromLua(L, -1);
			});

			cast v;
		}
		else
		{
			var v:DynamicAccess<Any> = {};

			loopTable(L, i, {
				switch (Lua.type(L, -2))
				{
					case Lua.TSTRING:
						v.set(Lua.tostring(L, -2), fromLua(L, -1));
					case Lua.TNUMBER:
						v.set(Std.string(Lua.tonumber(L, -2)), fromLua(L, -1));
				}
			});

			cast v;
		}
	}

	public macro function loopTable(L:Expr, v:Expr, body:Expr) {
		return macro {
			Lua.pushnil($l);
			while(Lua.next($l, $v < 0 ? $v - 1 : $v) != 0) {
				$body;
				Lua.pop($l, 1);
			}
		}
	}
}
