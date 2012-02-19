package com.junkbyte.console.addons.memoryRecorder
{
	import com.junkbyte.console.Console;
	import com.junkbyte.console.KeyBind;

	public class MemoryRecorderConsole
	{

		public static function registerToConsole(console:Console, key:String = "r"):void
		{
			MemoryRecorder.instance.reportCallback = function(... args:Array):void
			{
				args.unshift("R");
				console.infoch.apply(null, args);
			}

			var onMemoryRecorderStart:Function = function():void
			{
				if (MemoryRecorder.instance.running == false)
				{
					MemoryRecorder.instance.start();
				}
			}

			var onMemoryRecorderEnd:Function = function():void
			{
				if (MemoryRecorder.instance.running)
				{
					console.clear("R");
					MemoryRecorder.instance.end();
				}
			}

			console.bindKey(new KeyBind(key), onMemoryRecorderStart);
			console.bindKey(new KeyBind(key, false, false, false, true), onMemoryRecorderEnd);
		}

	}
}
