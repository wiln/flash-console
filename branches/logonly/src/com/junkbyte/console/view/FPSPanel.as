/*
* 
* Copyright (c) 2008-2010 Lu Aye Oo
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
package com.junkbyte.console.view 
{
	import com.junkbyte.console.Console;
	import com.junkbyte.console.vos.GraphGroup;
	import com.junkbyte.console.vos.GraphInterest;

	import flash.events.TextEvent;

	public class FPSPanel extends AbstractPanel {
		//
		public static const NAME:String = "fpsPanel";
		
		public function FPSPanel(m:Console) {
			super(m);
			name = NAME;
			
			txtField = makeTF("menuField");
			txtField.height = m.config.menuFontSize+4;
			txtField.width = 75;
			registerTFRoller(txtField, onMenuRollOver, linkHandler);
			registerDragger(txtField); // so that we can still drag from textfield
			addChild(txtField);
			
			init(75,m.config.menuFontSize,false);
			// 
		}
		protected function linkHandler(e:TextEvent):void{
			if(e.text == "close"){
				master.fpsMonitor = false;
			}
		}
		protected function onMenuRollOver(e:TextEvent):void{
			master.panels.tooltip(e.text?e.text.replace("event:",""):null, this);
		}
		public function update(group:GraphGroup):void{
			var interest:GraphInterest = group.interests[0];
			if(interest && isNaN(interest.v)) {
				txtField.htmlText = "<r><s>no fps input <menu><a href=\"event:close\">X</a></menu></s></r>";
			}else{
				txtField.htmlText = "<r><s>"+interest.v.toFixed(1)+" | "+interest.avg.toFixed(1)+" <menu><a href=\"event:close\">X</a></menu></r></s>";
			}
			txtField.scrollH = txtField.maxScrollH;
		}
	}
}
