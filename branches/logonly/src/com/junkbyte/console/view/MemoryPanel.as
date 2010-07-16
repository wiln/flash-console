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

package com.junkbyte.console.view {
	import com.junkbyte.console.vos.GraphInterest;
	import com.junkbyte.console.Console;
	import com.junkbyte.console.vos.GraphGroup;

	import flash.events.TextEvent;

	public class MemoryPanel extends AbstractPanel {
		//
		public static const NAME:String = "memoryPanel";
		
		public function MemoryPanel(m:Console) {
			super(m);
			name = NAME;
			
			txtField = makeTF("menuField");
			txtField.height = m.config.menuFontSize+4;
			txtField.width = 80;
			registerTFRoller(txtField, onMenuRollOver, linkHandler);
			registerDragger(txtField); // so that we can still drag from textfield
			addChild(txtField);
			
			init(80,m.config.menuFontSize,false);
		}
		public function update(group:GraphGroup):void{
			var interest:GraphInterest = group.interests[0];
			if(interest && isNaN(interest.v)) {
				txtField.htmlText = "<r><s>no mem input <menu><a href=\"event:close\">X</a></menu></s></r>";
			}else{
				txtField.htmlText =  "<r><s>"+interest.v.toFixed(2)+"mb <menu><a href=\"event:gc\">G</a> <a href=\"event:close\">X</a></menu></r></s>";
			}
			txtField.scrollH = txtField.maxScrollH;
		}
		protected function linkHandler(e:TextEvent):void{
			if(e.text == "gc"){
				master.gc();
			}else if(e.text == "close"){
				master.memoryMonitor = false;
			}
		}
		protected function onMenuRollOver(e:TextEvent):void{
			var txt:String = e.text?e.text.replace("event:",""):null;
			if(txt == "gc"){
				txt = "Garbage collect::Requires debugger version of flash player";
			}
			master.panels.tooltip(txt, this);
		}
	}
}
