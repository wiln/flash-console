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
		
		
		public var backgroundColor:int;
		public var backgroundAlpha:Number = 0.8;
		public var scalerColor:Number = 0x990000;
		public var commandLineColor:Number = 0x10AA00;
		public var bottomLineColor:Number = 0xFF0000;
		//
		public var traceFont:String = "Verdana";
		public var traceFontSize:int = 11;
		public var menuFont:String = "Arial";
		public var fontSizeMedium:int = 12;
		public var fontSizeSmall:int = 10;
		//
		public var highColor:int = 0xFFFFFF;
		public var lowColor:int = 0xC0C0C0;
		public var menuColor:int = 0xFF8800;
		public var menuHighlightColor:int = 0xDD5500;
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
		//
		//
		//
		public function ConsoleStyle() {
			big();
		}
		
		public function generateCSS():StyleSheet{
			var css:StyleSheet = new StyleSheet();
			css.setStyle("r",{textAlign:'right', display:'inline'});
			css.setStyle("w",{color:hesh(highColor), fontFamily:menuFont, fontSize:fontSizeMedium, display:'inline'});
			css.setStyle("s",{color:hesh(lowColor), fontFamily:menuFont, fontSize:fontSizeSmall, display:'inline'});
			css.setStyle("hi",{color:hesh(menuHighlightColor), display:'inline'});
			css.setStyle("menu",{color:hesh(menuColor), display:'inline'});
			css.setStyle("chs",{color:hesh(channelsColor), fontSize:fontSizeMedium, leading:'2', display:'inline'});
			css.setStyle("ch",{color:hesh(channelColor), display:'inline'});
			css.setStyle("tooltip",{color:hesh(tooltipColor),fontFamily:menuFont, textAlign:'center'});
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
			return css;
		}
		private function hesh(n:Number):String{return "#"+n.toString(16);}
		
		public function preset2():void{
			backgroundColor = 0xFFFFFF;
			scalerColor = 0xFF3333;
			commandLineColor = 0x66CC00;
			bottomLineColor = 0xFF0000;
			//
			highColor = 0x000000;
			lowColor = 0x333333;
			menuColor = 0xCC1100;
			menuHighlightColor = 0x881100;
			channelsColor = 0x000000;
			channelColor = 0x0066AA;
			tooltipColor = 0xAA3300;
			//
			priority0 = 0x44A044;
			priority1 = 0x339033;
			priority2 = 0x227722;
			priority3 = 0x115511;
			priority4 = 0x003300;
			priority5 = 0x000000;
			priority6 = 0x660000;
			priority7 = 0x990000;
			priority8 = 0xBB0000;
			priority9 = 0xDD0000;
			priority10 = 0xDD0000;
			priorityC1 = 0x0099CC;
			priorityC2 = 0xFF6600;
		}
		public function big():void{
			backgroundAlpha = 1;
			traceFontSize = 16;
			fontSizeMedium = 18;
			fontSizeSmall = 14;
		}
		public function preset4():void{
			preset2();
			backgroundAlpha = 1;
		}
		public function preset951():void{
			// USED BY AIR Remote
			//preset1();
			backgroundAlpha = 0.55;
		}
	}
}