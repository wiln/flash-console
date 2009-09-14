/*
 * 
 * 
 * 
 * 
 * 
 * This class is just to keep important references in once place and to be used within all
 * console panels/classes
*/
package com.atticmedia.console.core {
	import com.atticmedia.console.panels.PanelsManager;	
	import com.atticmedia.console.Console;	
	import com.atticmedia.console.core.Style;

	public class Central {
	
		public var master:Console;
		public var style:Style;
		public var panels:PanelsManager;
		public var cl:CommandLine;
		public var mm:MemoryMonitor;
		
		public var report:Function;
		public var tooltip:Function;
		
		public function Central(m:Console) {
			master = m;
		}
	}
}