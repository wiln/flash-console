package com.atticmedia.console.panels {
	import flash.system.System;	
	import flash.events.Event;
	import flash.utils.getTimer;		

	/**
	 * @author LuAye
	 */
	public class MemoryPanel extends GraphingPanel {
		
		//
		public function MemoryPanel() {
			super(80,40);
			updateEvery = 5;
			drawEvery = 5;
			add(this, "current", 0x3333FF, "Memory");
		}
		public function get current():Number{
			return Math.round(System.totalMemory/1048.576)/1000;
		}
		protected override function onFrame(e:Event):void{
			super.onFrame(e);
			keyTxt.text = getCurrentOf(0)+"mb";
		}
	}
}
