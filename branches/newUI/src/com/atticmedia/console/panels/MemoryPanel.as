package com.atticmedia.console.panels {
	import flash.system.System;	
	import flash.events.Event;
	import flash.utils.getTimer;
	import flash.events.TextEvent;	

	/**
	 * @author LuAye
	 */
	public class MemoryPanel extends GraphingPanel {
		
		//
		public function MemoryPanel() {
			name = "MemoryPanel";
			super(80,40);
			updateEvery = 5;
			drawEvery = 5;
			minimumWidth = 32;
			keyTxt.selectable = false;
			keyTxt.mouseEnabled = true;
			keyTxt.addEventListener(TextEvent.LINK, linkHandler, false, 0, true);
			registerDragger(keyTxt);
			add(this, "current", 0x3333FF, "Memory");
		}
		public function get current():Number{
			return Math.round(System.totalMemory/1048.576)/1000;
		}
		protected override function onFrame(e:Event):void{
			super.onFrame(e);
			keyTxt.htmlText = getCurrentOf(0)+"mb <font color='#C04444'><a href=\"event:reset\">R</a> <a href=\"event:gc\">GC</a></font>";
		}
		private function linkHandler(e:TextEvent):void{
			if(e.text == "reset"){
				reset();
			}else if(e.text == "gc"){
				// TODO: Should notify main Console if Garbage Collection is possible or not.
				if(System["gc"] != null){
					System["gc"]();
				}
			}
			e.stopPropagation();
		}
	}
}
