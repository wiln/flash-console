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
		//
		public var backgroundColor:int; // panel backround color
		public var backgroundAlpha:Number = 0.8; // panel background alpha
		public var controlColor:Number = 0x990000; // Scroll bar, scaler, etc. some gets alpha applied
		public var commandLineColor:Number = 0x10AA00; // command line background and text color, background gets alpha so it is less visible.
		//
		public var menuFont:String = "Arial"; // font for menus and almost all others
		public var menuFontSize:int = 12; // Font size for menus and almost all others
		public var traceFont:String = "Verdana"; // Font for trace field
		public var traceFontSize:int = 11; // Font size for trace field
		//
		public var highColor:uint = 0xFFFFFF; // Font color for high priority text, such as user input.
		public var lowColor:uint = 0xC0C0C0; // Font color for less important / smaller text
		public var menuColor:uint = 0xFF8800; // Font color for menu
		public var menuHighlightColor:uint = 0xDD5500; // Font color for highlighted menu
		public var channelsColor:uint = 0xFFFFFF; // Font color for channel names
		public var channelColor:uint = 0x0099CC; // Font color for current channel name
		public var tooltipColor:uint = 0xDD5500; // Font color for tool tips
		//
		// To find out which level assigns to which type of log, e.g. C.log, C.info, etc...
		// see Console.LOG_LEVEL, Console.INFO_LEVEL, Console.DEBUG_LEVEL, Console.WARN_LEVEL, etc
		public var priority0:uint = 0x336633; // color of priority level 0
		public var priority1:uint = 0x33AA33; // level 1
		public var priority2:uint = 0x77D077; // 2
		public var priority3:uint = 0xAAEEAA;
		public var priority4:uint = 0xD6FFD6;
		public var priority5:uint = 0xE6E6E6;
		public var priority6:uint = 0xFFD6D6;
		public var priority7:uint = 0xFFAAAA;
		public var priority8:uint = 0xFF7777;
		public var priority9:uint = 0xFF2222;
		public var priority10:uint = 0xFF2222; // priority 10, also gets a bold
		public var priorityC1:uint = 0x0099CC; // priority -1, designed to use by Console only, but you can also pass in that pirority
		public var priorityC2:uint = 0xFF8800; // priority -2, designed to use by Console only, but you can also pass in that pirority
		//
		//
		public function ConsoleStyle() {
			
		}
		public function whiteBase():void{
			backgroundColor = 0xFFFFFF;
			controlColor = 0xFF3333;
			commandLineColor = 0x66CC00;
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
			traceFontSize = 12;
			menuFontSize = 14;
		}
		public function opaque():void{
			backgroundAlpha = 1;
		}
		public function blackAndWhiteTrace():void{
			priority0 = 0x808080;
			priority1 = 0x888888;
			priority2 = 0x999999;
			priority3 = 0x9F9F9F;
			priority4 = 0xAAAAAA;
			priority5 = 0xAAAAAA;
			priority6 = 0xCCCCCC;
			priority7 = 0xCCCCCC;
			priority8 = 0xDDDDDD;
			priority9 = 0xFFFFFF;
			priority10 = 0xFFFFFF;
			priorityC1 = 0xBBC0CC;
			priorityC2 = 0xFFEEDD;
		}
		
		//
		// Used by console at init.
		//
		public function generateCSS():StyleSheet{
			var css:StyleSheet = new StyleSheet();
			css.setStyle("r",{textAlign:'right', display:'inline'});
			css.setStyle("w",{color:hesh(highColor), fontFamily:menuFont, fontSize:menuFontSize, display:'inline'});
			css.setStyle("s",{color:hesh(lowColor), fontFamily:menuFont, fontSize:menuFontSize-2, display:'inline'});
			css.setStyle("hi",{color:hesh(menuHighlightColor), display:'inline'});
			css.setStyle("menu",{color:hesh(menuColor), display:'inline'});
			css.setStyle("chs",{color:hesh(channelsColor), fontSize:menuFontSize, leading:'2', display:'inline'});
			css.setStyle("ch",{color:hesh(channelColor), display:'inline'});
			css.setStyle("tooltip",{color:hesh(tooltipColor),fontFamily:menuFont,fontSize:menuFontSize, textAlign:'center'});
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
	}
}