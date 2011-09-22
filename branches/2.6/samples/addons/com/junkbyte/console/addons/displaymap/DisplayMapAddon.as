package com.junkbyte.console.addons.displaymap
{
	import com.junkbyte.console.Cc;
	import com.junkbyte.console.Console;
	import com.junkbyte.console.view.ConsolePanel;
	
	import flash.display.DisplayObject;
	
	public class DisplayMapAddon
	{
		
		public static function start(targetDisplay:DisplayObject, console:Console = null):void
		{
			if(console == null)
			{
				console = Cc.instance;
			}
			if(console == null)
			{
				return;
			}
			var mapPanel:DisplayMapPanel = new DisplayMapPanel(console);
			mapPanel.start(targetDisplay);
			console.panels.addPanel(mapPanel);
		}
	}
}