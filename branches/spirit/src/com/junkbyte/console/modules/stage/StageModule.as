package com.junkbyte.console.modules.stage
{
	import com.junkbyte.console.core.ConsoleModule;
	import com.junkbyte.console.modules.ConsoleModuleNames;
	
	import flash.display.Stage;
	
	// This is a build-in module registed by console when console is added to stage display list.
	public class StageModule extends ConsoleModule
	{
		private var _stage:Stage;
		
		public function StageModule(stage:Stage)
		{
			super();
			if(stage == null)
			{
				throw new Error("StageModule requires that stage is not null.");
			}
			_stage = stage;
		}
		
		public function get stage():Stage
		{
			return _stage;
		}
		
		override public function getModuleName():String
		{
			return ConsoleModuleNames.STAGE;
		}
	}
}