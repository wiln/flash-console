/*
* 
* Copyright (c) 2008-2009 Lu Aye Oo
* 
* @author 		Lu Aye Oo
* 
* http://code.google.com/p/flash-console/
* 
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
* 
*/
package com.luaye.console.view {
	import com.luaye.console.utils.Utils;
	import com.luaye.console.vos.GraphGroup;
	import com.luaye.console.Console;
	import com.luaye.console.view.GraphingPanel;
	
	import flash.events.Event;

	public class FPSPanel extends GraphingPanel {
		//
		private var _avg:Number;
		//
		public function FPSPanel(m:Console) {
			super(m, 80,40);
			name = Console.PANEL_FPS;
			lowest = 0;
			minimumWidth = 32;
			// 
		}
		public override function close():void {
			master.fpsMonitor = false;
			super.close();
		}
		public override function update(group:GraphGroup):void{
			super.update(group);
			if(isNaN(_avg)) _avg = _v;
			_avg = Utils.averageOut(_avg, _v, 10);
			updateKeyText();
		}
		public override function updateKeyText():void{
			if(isNaN(_v)){
				keyTxt.htmlText = "<r><s>no fps input <menu><a href=\"event:close\">X</a></menu></s></r>";
			}else{
				keyTxt.htmlText = "<r><s>"+_v.toFixed(1)+" | "+_avg.toFixed(1)+" <menu><a href=\"event:reset\">R</a> <a href=\"event:close\">X</a></menu></r></s>";
			}
			keyTxt.scrollH = keyTxt.maxScrollH;
		}
	}
}
