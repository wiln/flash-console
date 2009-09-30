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
package com.atticmedia.console.view {
	import flash.text.TextFormat;	
	import flash.text.StyleSheet;		

	public class Style {

		private var _preset:int = 0;
		
		public var css:StyleSheet;
		public var panelBackgroundColor:int;
		public var panelBackgroundAlpha:Number;
		public var panelScalerColor:Number;
		public var commandLineColor:Number;
		public var bottomLineColor:Number;
		public var textFormat:TextFormat;
		public var tooltipBackgroundColor:Number;
				
		public function Style(uiset:int = 1) {
			css = new StyleSheet();
			preset = uiset;
			if(_preset<=0){
				preset = 1;
			}
		}
		
		public function set preset(num:int):void{
			if(hasOwnProperty(["preset"+num])){
				this["preset"+num]();
				_preset = num;
			}
		}
		public function get preset():int{
			return _preset;
		}
		public function preset1():void{
			panelBackgroundColor = 0;
			panelScalerColor = 0x880000;
			commandLineColor = 0x108000;
			bottomLineColor = 0xFF0000;
			tooltipBackgroundColor = 0;
			panelBackgroundAlpha = 0.6;
			textFormat = new TextFormat('Arial', 12, 0xFFFFFF);
			//
			css.setStyle("r",{textAlign:'right', display:'inline'});
			css.setStyle("w",{color:'#FFFFFF', fontFamily:'Arial', fontSize:'12', display:'inline'});
			css.setStyle("s",{color:'#CCCCCC', fontFamily:'Arial', fontSize:'10', display:'inline'});
			css.setStyle("y",{color:'#DD5500', display:'inline'});
			css.setStyle("ro",{color:'#DD5500', fontFamily:'Arial', fontSize:'11', display:'inline'});
			css.setStyle("roBold",{color:'#EE6611', fontWeight:'bold'});
			css.setStyle("menu",{color:'#FF8800', display:'inline'});
			css.setStyle("chs",{color:'#FFFFFF', fontSize:'11', leading:'2', display:'inline'});
			css.setStyle("ch",{color:'#0099CC', display:'inline'});
			css.setStyle("tooltip",{color:'#DD5500',fontFamily:'Arial', textAlign:'center'});
			//
			css.setStyle("p",{fontFamily:'Verdana', fontSize:'11'});
			css.setStyle("l1",{color:'#0099CC'});
			css.setStyle("l2",{color:'#FF8800'});
			css.setStyle("p0",{color:'#000000'});
			css.setStyle("p1",{color:'#33AA33'});
			css.setStyle("p2",{color:'#77D077'});
			css.setStyle("p3",{color:'#AAEEAA'});
			css.setStyle("p4",{color:'#D6FFD6'});
			css.setStyle("p5",{color:'#E6E6E6'});
			css.setStyle("p6",{color:'#FFD6D6'});
			css.setStyle("p7",{color:'#FFAAAA'});
			css.setStyle("p8",{color:'#FF7777'});
			css.setStyle("p9",{color:'#FF3333'});
			css.setStyle("p10",{color:'#FF0000', fontWeight:'bold'});
			css.setStyle("p-1",{color:'#0099CC'});
			css.setStyle("p-2",{color:'#FF8800'});
		}
		
		public function preset2():void{
			panelBackgroundColor = 0xFFFFFF;
			panelScalerColor = 0xFF0000;
			commandLineColor = 0x66CC00;
			bottomLineColor = 0xFF0000;
			tooltipBackgroundColor = 0xFFFFFF;
			panelBackgroundAlpha = 0.8;
			textFormat = new TextFormat('Arial', 12, 0);
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
			css.setStyle("p0",{color:'#666666'});
			css.setStyle("p1",{color:'#339033'});
			css.setStyle("p2",{color:'#227722'});
			css.setStyle("p3",{color:'#115511'});
			css.setStyle("p4",{color:'#003300'});
			css.setStyle("p5",{color:'#000000'});
			css.setStyle("p6",{color:'#660000'});
			css.setStyle("p7",{color:'#990000'});
			css.setStyle("p8",{color:'#BB0000'});
			css.setStyle("p9",{color:'#DD0000'});
			css.setStyle("p10",{color:'#FF0000', fontWeight:'bold'});
			css.setStyle("p-1",{color:'#0099CC'});
			css.setStyle("p-2",{color:'#FF6600'});
		}
		public function preset3():void{
			preset1();
			panelBackgroundAlpha = 1;
		}
		public function preset4():void{
			preset2();
			panelBackgroundAlpha = 1;
		}
	}
}