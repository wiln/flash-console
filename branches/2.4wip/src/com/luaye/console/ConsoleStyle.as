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
package com.luaye.console {
	import flash.text.StyleSheet;

	public class ConsoleStyle {
		
		
		public var traceFont:String = "Verdana";
		public var traceFontSize:int = 11;
		public var menuFont:String = "Arial";
		public var fontSizeMedium:int = 12;
		public var fontSizeSmall:int = 10;
		//
		public var menuColor:int = 0xFF8800;
		public var menuHighlightColor:int = 0xDD5500;
		public var inputColor:int = 0xFFFFFF;
		public var lowColor:int = 0xCCCCCC;
		public var channelsColor:int = 0xFFFFFF;
		public var channelColor:int = 0x0099CC;
		public var tooltipColor:int = 0xDD5500;
		//
		public var priority0:int = 0x336633;
		public var priority1:int = 0x33AA33;
		public var priority2:int = 0x77D077;
		public var priority3:int = 0xAAEEAA;
		public var priority4:int = 0xD6FFD6;
		public var priority5:int = 0xE6E6E6;
		public var priority6:int = 0xFFD6D6;
		public var priority7:int = 0xFFAAAA;
		public var priority8:int = 0xFF7777;
		public var priority9:int = 0xFF2222;
		public var priority10:int = 0xFF2222;
		public var priorityC1:int = 0x0099CC;
		public var priorityC2:int = 0xFF8800;
		
		
		public var panelBackgroundColor:int;
		public var panelBackgroundAlpha:Number = 0.8;
		public var panelScalerColor:Number = 0x880000;
		public var commandLineColor:Number = 0x10AA00;
		public var bottomLineColor:Number = 0xFF0000;
		private var _css:StyleSheet = new StyleSheet();
				
		public function ConsoleStyle(uiset:int = 1) {
			preset1();
		}
		public function get css():StyleSheet{
			return _css;
		}
		public function preset1():void{
			//
			css.setStyle("r",{textAlign:'right', display:'inline'});
			css.setStyle("w",{color:'#FFFFFF', fontFamily:menuFont, fontSize:fontSizeMedium, display:'inline'});
			css.setStyle("s",{color:'#CCCCCC', fontFamily:menuFont, fontSize:'10', display:'inline'});
			css.setStyle("hi",{color:'#DD5500', display:'inline'});
			css.setStyle("ro",{color:'#DD5500', fontFamily:menuFont, fontSize:'11', display:'inline'});
			css.setStyle("roBold",{color:'#EE6611', fontWeight:'bold'});
			css.setStyle("menu",{color:'#FF8800', display:'inline'});
			css.setStyle("chs",{color:'#FFFFFF', fontSize:fontSizeMedium, leading:'2', display:'inline'});
			css.setStyle("ch",{color:'#0099CC', display:'inline'});
			css.setStyle("tooltip",{color:'#DD5500',fontFamily:menuFont, textAlign:'center'});
			//
			css.setStyle("p",{fontFamily:traceFont, fontSize:traceFontSize});
			css.setStyle("p0",{color:hesh(priority0), display:'inline'});
			css.setStyle("p1",{color:hesh(priority1), display:'inline'});
			css.setStyle("p2",{color:hesh(priority2), display:'inline'});
			css.setStyle("p3",{color:hesh(priority3), display:'inline'});
			css.setStyle("p4",{color:hesh(priority4), display:'inline'});
			css.setStyle("p5",{color:hesh(priority5), display:'inline'});
			css.setStyle("p6",{color:hesh(priority6), display:'inline'});
			css.setStyle("p7",{color:hesh(priority7), display:'inline'});
			css.setStyle("p8",{color:hesh(priority8), display:'inline'});
			css.setStyle("p9",{color:hesh(priority9), display:'inline'});
			css.setStyle("p10",{color:hesh(priority10), fontWeight:'bold', display:'inline'});
			css.setStyle("p-1",{color:hesh(priorityC1), display:'inline'});
			css.setStyle("p-2",{color:hesh(priorityC2), display:'inline'});
		}
		private function hesh(n:Number):String{
			return "#"+n.toString(16);
		}
		
		public function preset2():void{
			panelBackgroundColor = 0xFFFFFF;
			panelScalerColor = 0xFF0000;
			commandLineColor = 0x66CC00;
			bottomLineColor = 0xFF0000;
			panelBackgroundAlpha = 0.8;
			//
			css.setStyle("r",{textAlign:'right', display:'inline'});
			css.setStyle("w",{color:'#000000', fontFamily:'Arial', fontSize:'12', display:'inline'});
			css.setStyle("s",{color:'#333333', fontFamily:'Arial', fontSize:'10', display:'inline'});
			css.setStyle("y",{color:'#881100', display:'inline'});
			css.setStyle("ro",{color:'#661100', fontFamily:'Arial', fontSize:'11', display:'inline'});
			css.setStyle("roBold",{color:'#AA4400', fontWeight:'bold'});
			css.setStyle("menu",{color:'#CC1100', display:'inline'});
			css.setStyle("chs",{color:'#000000', fontSize:'11', leading:'2', display:'inline'});
			css.setStyle("ch",{color:'#0066AA', display:'inline'});
			css.setStyle("tooltip",{color:'#AA3300',fontFamily:'Arial', textAlign:'center'});
			//
			css.setStyle("p",{fontFamily:'Verdana', fontSize:'11'});
			css.setStyle("l1",{color:'#0099CC'});
			css.setStyle("l2",{color:'#FF8800'});
			//css.setStyle("p0",{color:'#666666', display:'inline'});
			css.setStyle("p0",{color:'#339033', display:'inline'});
			css.setStyle("p1",{color:'#227722', display:'inline'});
			css.setStyle("p2",{color:'#115511', display:'inline'});
			css.setStyle("p3",{color:'#003300', display:'inline'});
			css.setStyle("p4",{color:'#000000', display:'inline'});
			css.setStyle("p5",{color:'#660000', display:'inline'});
			css.setStyle("p6",{color:'#990000', display:'inline'});
			css.setStyle("p7",{color:'#BB0000', display:'inline'});
			css.setStyle("p8",{color:'#DD0000', display:'inline'});
			css.setStyle("p9",{color:'#FF0000', display:'inline'});
			css.setStyle("p10",{color:'#FF0000', fontWeight:'bold', display:'inline'});
			css.setStyle("p-1",{color:'#0099CC', display:'inline'});
			css.setStyle("p-2",{color:'#FF6600', display:'inline'});
		}
		public function preset3():void{
			preset1();
			panelBackgroundAlpha = 1;
		}
		public function preset4():void{
			preset2();
			panelBackgroundAlpha = 1;
		}
		public function preset951():void{
			// USED BY AIR Remote
			preset1();
			panelBackgroundAlpha = 0.55;
		}
	}
}