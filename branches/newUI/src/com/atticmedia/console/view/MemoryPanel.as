package com.atticmedia.console.view {
	import com.atticmedia.console.Console;
	import com.atticmedia.console.events.TextFieldRollOver;
	import com.atticmedia.console.view.GraphingPanel;
	
	import flash.events.Event;
	import flash.events.TextEvent;	

	/**
	 * @author LuAye
	 */
	public class MemoryPanel extends GraphingPanel {
		
		//
		public function MemoryPanel(m:Console) {
			super(m, 80,40);
			name = Console.PANEL_MEMORY;
			updateEvery = 5;
			drawEvery = 5;
			minimumWidth = 32;
			//master.mm.addEventListener(MemoryMonitor.GARBAGE_COLLECTED, onGC, false, 0, true);
			//master.mm.notifyGC = !m.isRemote;
			add(this, "current", 0x5060FF, "Memory");
		}
		public override function close():void {
			//master.mm.notifyGC = false;
			super.close();
		}
		public function get current():Number{
			// in MB, up to 2 decimal
			return Math.round(master.currentMemory/10485.76)/100;
		}
		protected override function onFrame(e:Event):void{
			super.onFrame(e);
			updateKeyText();
		}
		public override function updateKeyText():void{
			keyTxt.htmlText =  "<r><s>"+getCurrentOf(0).toFixed(2)+"mb <menu><a href=\"event:gc\">G</a> <a href=\"event:reset\">R</a> <a href=\"event:close\">X</a></menu></r></s>";
		}
		protected override function linkHandler(e:TextEvent):void{
			if(e.text == "gc"){
				master.gc();
			}
			super.linkHandler(e);
		}
		//
		
		protected override function onMenuRollOver(e:TextFieldRollOver):void{
			var txt:String = e.url?e.url.replace("event:",""):null;
			if(txt == "gc"){
				txt = "Garbage collect::Requires debugger version of flash player";
			}
			master.panels.tooltip(txt, this);
		}
		/*private function onGC(e:Event):void{
			mark(0xFF000000);
		}*/
	}
}
