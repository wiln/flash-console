/*
 * 
 * 
 * 
 * 
 * 
 * This class is just to keep important reference tidy
*/
package com.atticmedia.console.core {
	import com.atticmedia.console.panels.PanelsManager;	
	import com.atticmedia.console.Console;	
	import com.atticmedia.console.core.Style;

	public class Central {
	
		public var master:Console;
		public var style:Style;
		public var panels:PanelsManager;
		
		public function Central(m:Console) {
			master = m;
		}
		
	}
}