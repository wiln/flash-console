package com.atticmedia.console.view {
	import com.atticmedia.console.view.GraphingPanel;
	import com.atticmedia.console.Console;	
	import com.atticmedia.console.core.MemoryMonitor;	
	
	import flash.system.System;	
	import flash.events.Event;
	import flash.utils.getTimer;
	import flash.events.TextEvent;

	/**
	 * @author LuAye
	 */
	public class MemoryPanel extends GraphingPanel {
		
		public static const NAME:String = "MemoryPanel";
		//
		public function MemoryPanel(m:Console) {
			name = NAME;
			super(m, 80,40);
			updateEvery = 5;
			drawEvery = 5;
			minimumWidth = 32;
			master.mm.addEventListener(MemoryMonitor.GARBAGE_COLLECTED, onGC, false, 0, true);
			master.mm.notifyGC = true;
			add(this, "current", 0x5060FF, "Memory");
		}
		public override function close():void {
			master.mm.notifyGC = false;
			super.close();
		}
		public function get current():Number{
			return Math.round(master.mm.currentMemory/10485.76)/100;
		}
		protected override function onFrame(e:Event):void{
			super.onFrame(e);
			updateKeyText();
		}
		protected override function updateKeyText():void{
			keyTxt.htmlText =  "<r><s>"+getCurrentOf(0).toFixed(2)+"mb <menu><a href=\"event:gc\">G</a> <a href=\"event:reset\">R</a> <a href=\"event:close\">X</a></menu></r></s>";
		}
		protected override function linkHandler(e:TextEvent):void{
			if(e.text == "gc"){
				master.gc();
			}
			super.linkHandler(e);
		}
		//
		
		private function onGC(e:Event):void{
			mark(0xFF000000);
		}
	}
}
