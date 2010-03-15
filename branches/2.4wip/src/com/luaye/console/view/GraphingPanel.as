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
	import com.luaye.console.Console;
	import com.luaye.console.vos.GraphGroup;
	import com.luaye.console.vos.GraphInterest;

	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.events.TextEvent;
	import flash.text.TextField;

	public class GraphingPanel extends AbstractPanel {
		
		//
		protected var _group:GraphGroup;
		protected var _interest:GraphInterest;
		protected var _infoMap:Object = new Object();
		//
		private var _needRedraw:Boolean;
		//
		protected var underlay:Shape;
		protected var graph:Shape;
		protected var lowTxt:TextField;
		protected var highTxt:TextField;
		protected var keyTxt:TextField;
		//
		public var updatedFrame:uint = 0;
		public var startOffset:int = 5;
		//
		public function GraphingPanel(m:Console, W:int = 0, H:int = 0, resizable:Boolean = true) {
			super(m);
			registerDragger(bg);
			minimumHeight = 26;
			//
			lowTxt = new TextField();
			lowTxt.name = "lowestField";
			lowTxt.mouseEnabled = false;
			lowTxt.styleSheet = m.css;
			lowTxt.height = master.style.menuFontSize+2;
			addChild(lowTxt);
			highTxt = new TextField();
			highTxt.name = "highestField";
			highTxt.mouseEnabled = false;
			highTxt.styleSheet = m.css;
			highTxt.height = master.style.menuFontSize+2;
			highTxt.y = master.style.menuFontSize-4;
			addChild(highTxt);
			//
			keyTxt = new TextField();
			keyTxt.name = "menuField";
			keyTxt.styleSheet = m.css;
			keyTxt.height = m.style.menuFontSize+4;
			keyTxt.y = -3;
			keyTxt.addEventListener(TextEvent.LINK, linkHandler, false, 0, true);
			registerRollOverTextField(keyTxt);
			keyTxt.addEventListener(AbstractPanel.TEXT_LINK, onMenuRollOver, false, 0, true);
			registerDragger(keyTxt); // so that we can still drag from textfield
			addChild(keyTxt);
			//
			underlay = new Shape();
			addChild(underlay);
			//
			graph = new Shape();
			graph.name = "graph";
			graph.y = m.style.menuFontSize;
			addChild(graph);
			//
			init(W?W:100,H?H:80,resizable);
		}
		private function stop():void {
			if(_group) master.graphing.remove(_group.name);
			close();
		}
		public function reset():void{
			_infoMap = {};
			graph.graphics.clear();
		}
		/*public function set showKeyText(b:Boolean):void{
			keyTxt.visible = b;
		}
		public function get showKeyText():Boolean{
			return keyTxt.visible;
		}
		public function set showBoundsText(b:Boolean):void{
			lowTxt.visible = b;
			highTxt.visible = b;
		}
		public function get showBoundsText():Boolean{
			return lowTxt.visible;
		}*/
		override public function set height(n:Number):void{
			super.height = n;
			lowTxt.y = n-master.style.menuFontSize;
			_needRedraw = true;
			
			var g:Graphics = underlay.graphics;
			g.clear();
			g.lineStyle(1,master.style.controlColor, 0.6);
			g.moveTo(0, graph.y);
			g.lineTo(width-startOffset, graph.y);
			g.lineTo(width-startOffset, n);
		}
		override public function set width(n:Number):void{
			super.width = n;
			lowTxt.width = n;
			highTxt.width = n;
			keyTxt.width = n;
			keyTxt.scrollH = keyTxt.maxScrollH;
			_needRedraw = true;
		}
		//
		//
		//
		public function update(group:GraphGroup):void{
			_group = group;
			var doPush:Boolean = true;
			if(group.freq>1){
				updatedFrame++;
				if(updatedFrame < group.freq){
					doPush = false;
					if(!_needRedraw) return;
				}else{
					updatedFrame=0;
				}
			}
			_needRedraw = false;
			var interests:Array = group.interests;
			var W:int = width-startOffset;
			var H:int = height-graph.y;
			graph.graphics.clear();
			var lowest:Number = group.lowest;
			var highest:Number = group.highest;
			var diffGraph:Number = highest-lowest;
			var keys:Object = {};
			var listchanged:Boolean = false;
			for each(_interest in interests){
				var n:String = _interest.key;
				keys[n] = true;
				var info:InterestInfo = _infoMap[n];
				if(info == null){
					listchanged = true;
					info = new InterestInfo(_interest.col);
					_infoMap[n] = info;
				}
				var history:Array = info.history;
				if(doPush) history.push(_interest.values[_interest.values.length-1]);
				var len:int = history.length;
				var maxLen:int = Math.floor(W)+10;
				if(len > maxLen){
					history.splice(0, (len-maxLen));
					len = history.length;
				}
				graph.graphics.lineStyle(1, _interest.col);
				var maxi:int = W>len?len:W;
				for(var i:int = 1; i<maxi; i++){
					var Y:Number = (diffGraph?((history[len-i]-lowest)/diffGraph):0.5)*H;
					if(!group.inverse) Y = H-Y;
					if(Y<0)Y=0;
					if(Y>H)Y=H;
					if(i==1){
						graph.graphics.moveTo(width, Y);
					}
					graph.graphics.lineTo((W-i), Y);
				}
				if(group.averaging>0 && diffGraph){
					Y = ((_interest.avg-lowest)/diffGraph)*H;
					if(!group.inverse) Y = H-Y;
					if(Y<0)Y=0;
					if(Y>H)Y=H;
					graph.graphics.lineStyle(1,_interest.col, 0.3);
					graph.graphics.moveTo(0, Y);
					graph.graphics.lineTo(W, Y);
				}
			}
			for(var X:String in _infoMap){
				if(keys[X] == undefined){
					listchanged = true;
					delete _infoMap[X];
				}
			}
			(group.inverse?highTxt:lowTxt).text = isNaN(group.lowest)?"":"<s>"+group.lowest+"</s>";
			(group.inverse?lowTxt:highTxt).text = isNaN(group.highest)?"":"<s>"+group.highest+"</s>";
			if(listchanged) updateKeyText();
		}
		public function updateKeyText():void{
			var str:String = "<r><s>";
			for(var X:String in _infoMap){
				str += " <font color='#"+InterestInfo(_infoMap[X]).col.toString(16)+"'>"+X+"</font>";
			}
			str +=  " | <menu><a href=\"event:reset\">R</a> <a href=\"event:close\">X</a></menu></s></r>";
			keyTxt.htmlText = str;
			keyTxt.scrollH = keyTxt.maxScrollH;
		}
		protected function linkHandler(e:TextEvent):void{
			TextField(e.currentTarget).setSelection(0, 0);
			if(e.text == "reset"){
				reset();
			}else if(e.text == "close"){
				stop();
			}
			e.stopPropagation();
		}
		protected function onMenuRollOver(e:TextEvent):void{
			master.panels.tooltip(e.text?e.text.replace("event:",""):null, this);
		}
	}
}
class InterestInfo{
	public var col:Number;
	public var history:Array = [];
	public function InterestInfo(c:Number){
		col = c;
	}
}