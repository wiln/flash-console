/*
* 
* Copyright (c) 2008 Atticmedia
* 
* @author 		Lu Aye Oo
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
* 
*/
package com.atticmedia.console.core {
	import flash.text.TextFormat;	
	import flash.text.StyleSheet;		

	public class Style {

		private var _preset:int;
		
		private var _css:StyleSheet;
		private var _tracecss:StyleSheet;
		
		public var panelBackgroundColor:int;
		public var panelBackgroundAlpha:Number;
		public var panelScalerColor:Number;
		public var panelScalerAlpha:Number;
		public var bottomLineColor:Number;
		public var textFormat:TextFormat;
		public var tooltipBackgroundColor:Number;
				
		public function Style() {
			_css = new StyleSheet();
			_tracecss = new StyleSheet();
			preset = 1;
		}
		public function get css():StyleSheet{
			return _css;
		}
		public function get tracecss():StyleSheet{
			return _tracecss;
		}
		
		public function set preset(num:int):void{
			if(this["preset"+num]){
				this["preset"+num]();
				_preset = num;
			}
		}
		public function get preset():int{
			return _preset;
		}
		public function preset1():void{
			panelBackgroundColor = 0;
			panelBackgroundAlpha = 0.6;
			panelScalerColor = 0;
			panelScalerAlpha = 0.6;
			bottomLineColor = 0xFF0000;
			
			_css.setStyle("r",{textAlign:'right', display:'inline'});
			//_css.setStyle("a",{textDecoration:'underline'});
			_css.setStyle("w",{color:'#FFFFFF', fontFamily:'Arial', fontSize:'12', display:'inline'});
			_css.setStyle("y",{color:'#DD5500', fontFamily:'Arial', fontSize:'11', display:'inline'});
			_css.setStyle("y2",{color:'#EE6611', fontWeight:'bold'});
			_css.setStyle("s",{color:'#CCCCCC', fontFamily:'Arial', fontSize:'10', display:'inline'});
			_css.setStyle("menu",{color:'#FF8800', display:'inline'});
			_css.setStyle("menu2",{color:'#77D077', fontWeight:'bold', display:'inline'});
			_css.setStyle("tooltip",{color:'#DD5500',fontFamily:'Arial', textAlign:'center'});
			textFormat = new TextFormat('Arial', 11, 0xFFFFFF);
			tooltipBackgroundColor = 0;
			
			
			_tracecss.setStyle("p",{fontFamily:'Arial', fontSize:'11'});
			_tracecss.setStyle("l1",{color:'#0099CC'});
			_tracecss.setStyle("l2",{color:'#FF8800'});
			_tracecss.setStyle("p0",{color:'#000000'});
			
			/*
			_priorities[0] = "#000000";
			_priorities[1] = "#33AA33";
			_priorities[2] = "#77D077";
			_priorities[3] = "#AAEEAA";
			_priorities[4] = "#D6FFD6";
			_priorities[5] = "#E6E6E6";
			_priorities[6] = "#FFD6D6";
			_priorities[7] = "#FFAAAA";
			_priorities[8] = "#FF7777";
			_priorities[9] = "#FF3333";
			_priorities[10] = "#FF0000";
			_priorities[-1] = "#0099CC";
			_priorities[-2] = "#FF8800";*/
		}
		
		public function preset2():void{
			panelBackgroundColor = 0xFFFFFF;
			panelBackgroundAlpha = 0.6;
			panelScalerColor = 0xFF0000;
			panelScalerAlpha = 0.6;
			bottomLineColor = 0xFFFFFFF;
			
			_css.setStyle("r",{textAlign:'right', display:'inline'});
			//_css.setStyle("a",{textDecoration:'underline'});
			_css.setStyle("w",{color:'#FFFFFF', fontFamily:'Arial', fontSize:'12', display:'inline'});
			_css.setStyle("y",{color:'#DD5500', fontFamily:'Arial', fontSize:'11', display:'inline'});
			_css.setStyle("y2",{color:'#EE6611', fontWeight:'bold'});
			_css.setStyle("s",{color:'#CCCCCC', fontFamily:'Arial', fontSize:'10', display:'inline'});
			_css.setStyle("menu",{color:'#FF8800', display:'inline'});
			_css.setStyle("menu2",{color:'#77D077', fontWeight:'bold', display:'inline'});
			
			
			
			_tracecss.setStyle("p",{fontFamily:'Arial', fontSize:'11'});
			_tracecss.setStyle("l1",{color:'#0099CC'});
			_tracecss.setStyle("l2",{color:'#FF8800'});
			_tracecss.setStyle("p0",{color:'#000000'});
			/*setbackgroundColour(1,1,1);
			backgroundAlpha = 0.8;
			backgroundBlendMode = "normal";
			var format:TextFormat = new TextFormat();
			format.font = "Arial";
			format.size = 12;
			format.color = 0;
			menuFormat = format;
			_priorities[0] = "#666666";
			_priorities[1] = "#44DD44";
			_priorities[2] = "#33AA33";
			_priorities[3] = "#227722";
			_priorities[4] = "#115511";
			_priorities[5] = "#000000";
			_priorities[6] = "#660000";
			_priorities[7] = "#990000";
			_priorities[8] = "#BB0000";
			_priorities[9] = "#DD0000";
			_priorities[10] = "#FF0000";
			_priorities[-1] = "#0099CC";
			_priorities[-2] = "#FF6600";*/
		}
	}
}