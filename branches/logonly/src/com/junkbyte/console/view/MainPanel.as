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
	import com.junkbyte.console.ConsoleChannel;
	import com.junkbyte.console.vos.Log;
	import com.junkbyte.console.vos.Logs;

	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TextEvent;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;

	public class MainPanel extends AbstractPanel {
		
		private static const MAX_MENU_CHANNELS:int = 7;
		
		public static const TOOLTIPS:Object = {
				fps:"Frames Per Second",
				mm:"Memory Monitor",
				copy:"Copy to clipboard",
				clear:"Clear log",
				trace:"Use trace(...)",
				pause:"Pause updates",
				resume:"Resume updates",
				priority:"Toggle priority filter",
				channels:"Expand channels",
				close:"Close",
				closemain:"Close::Type password to show again",
				viewall:"View all channels",
				defaultch:"Default channel::Logs with no channel",
				consolech:"Console's channel::Logs generated from Console",
				filterch:"Filtering channel",
				channel:"Change channel::Hold shift to select multiple channels",
				scrollUp:"Scroll up",
				scrollDown:"Scroll down"
		};
		
		public static const NAME:String = "mainPanel";
		
		// these are used for adding extended functionality such as from RemoteAIR
		private var _extraMenuKeys:Array = [];
		public var topMenuClick:Function;
		public var topMenuRollOver:Function;
		
		private var _traceField:TextField;
		private var _bottomLine:Shape;
		private var _isMinimised:Boolean;
		private var _shift:Boolean;
		private var _canUseTrace:Boolean;
		private var _txtscroll:TextScroller;
		
		private var _channels:Array;
		private var _viewingChannels:Array;
		private var _lines:Logs;
		private var _priority:int;
		private var _filterText:String;
		private var _filterRegExp:RegExp;
		
		private var _needUpdateMenu:Boolean;
		private var _needUpdateTrace:Boolean;
		private var _lockScrollUpdate:Boolean;
		private var _atBottom:Boolean = true;
		
		public function MainPanel(m:Console, lines:Logs, channels:Array) {
			super(m);
			_canUseTrace = (Capabilities.playerType=="External"||Capabilities.isDebugger);
			var fsize:int = m.config.menuFontSize;
			_channels = channels;
			_viewingChannels = new Array();
			_lines = lines;
			
			name = NAME;
			minWidth = 50;
			minHeight = 18;
			
			_traceField = makeTF("traceField");
			_traceField.wordWrap = true;
			_traceField.multiline = true;
			_traceField.y = fsize;
			_traceField.addEventListener(Event.SCROLL, onTraceScroll, false, 0, true);
			addChild(_traceField);
			//
			txtField = makeTF("menuField");
			txtField.height = fsize+6;
			txtField.y = -2;
			registerTFRoller(txtField, onMenuRollOver);
			addChild(txtField);
			//
			//
			var tf:TextFormat = new TextFormat(config.menuFont, config.menuFontSize, config.highColor);
			
			tf.color = config.commandLineColor;
			//
			_bottomLine = new Shape();
			_bottomLine.name = "blinkLine";
			_bottomLine.alpha = 0.2;
			addChild(_bottomLine);
			//
			_txtscroll = new TextScroller(null, config.controlColor);
			_txtscroll.y = fsize+4;
			_txtscroll.addEventListener(Event.INIT, startedScrollingHandle, false, 0, true);
			_txtscroll.addEventListener(Event.COMPLETE, stoppedScrollingHandle,  false, 0, true);
			_txtscroll.addEventListener(Event.SCROLL, onScrolledHandle,  false, 0, true);
			_txtscroll.addEventListener(Event.CHANGE, onScrollIncHandle,  false, 0, true);
			addChild(_txtscroll);
			//
			init(640,100,true);
			registerDragger(txtField);
			//
			addEventListener(TextEvent.LINK, linkHandler, false, 0, true);
			addEventListener(Event.ADDED_TO_STAGE, stageAddedHandle, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, stageRemovedHandle, false, 0, true);
		}
		public function addMenuKey(key:String):void{
			_extraMenuKeys.push(key);
			_needUpdateMenu = true;
		}

		private function stageAddedHandle(e:Event=null):void{
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler, false, 0, true);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, false, 0, true);
		}
		private function stageRemovedHandle(e:Event=null):void{
			stage.removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		}
		private function keyDownHandler(e:KeyboardEvent):void{
			if(e.keyCode == Keyboard.SHIFT){
				_shift = true;
			}
		}
		private function keyUpHandler(e:KeyboardEvent):void{
			if(e.keyCode == Keyboard.SHIFT){
				_shift = false;
			}
		}
		public function update(changed:Boolean):void{
			if(_bottomLine.alpha>0){
				_bottomLine.alpha -= 0.25;
			}
			if(changed){
				_bottomLine.alpha = 1;
				_needUpdateMenu = true;
				_needUpdateTrace = true;
			}
			if(_needUpdateTrace){
				_needUpdateTrace = false;
				_updateTraces(true);
			}
			if(_needUpdateMenu){
				_needUpdateMenu = false;
				_updateMenu();
			}
		}
		public function updateToBottom():void{
			_atBottom = true;
			_needUpdateTrace = true;
		}
		public function updateTraces(instant:Boolean = false):void{
			if(instant){
				_updateTraces();
			}else{
				_needUpdateTrace = true;
			}
		}
		private function _updateTraces(onlyBottom:Boolean = false):void{
			if(_atBottom) {
				updateBottom(); 
			}else if(!onlyBottom){
				updateFull();
			}
		}
		private function updateFull():void{
			var str:String = "";
			var line:Log = _lines.first;
			while(line){
				if(lineShouldShow(line)){
					str += makeLine(line);
				}
				line = line.next;
			}
			_lockScrollUpdate = true;
			_traceField.htmlText = str;
			_lockScrollUpdate = false;
			updateScroller();
		}
		public function setPaused(b:Boolean):void{
			if(b && _atBottom){
				_atBottom = false;
				updateTraces(true);
				_traceField.scrollV = _traceField.maxScrollV;
			}else if(!b){
				_atBottom = true;
				updateBottom();
			}
			updateMenu();
		}
		private function updateBottom():void{
			var lines:Array = new Array();
			var linesLeft:int = Math.round(_traceField.height/master.config.traceFontSize);
			var maxchars:int = Math.round(_traceField.width*5/master.config.traceFontSize);
			
			var line:Log = _lines.last;
			while(line){
				if(lineShouldShow(line)){
					var numlines:int = Math.ceil(line.text.length/ maxchars);
					if(linesLeft >= numlines ){
						lines.push(makeLine(line));
					}else{
						line = line.clone();
						line.text = line.text.substring(Math.max(0,line.text.length-(maxchars*linesLeft)));
						lines.push(makeLine(line));
						break;
					}
					linesLeft-=numlines;
					if(linesLeft<=0){
						break;
					}
				}
				line = line.prev;
			}
			_lockScrollUpdate = true;
			_traceField.htmlText = lines.reverse().join("");
			_traceField.scrollV = _traceField.maxScrollV;
			_lockScrollUpdate = false;
			updateScroller();
		}
		private function lineShouldShow(line:Log):Boolean{
			return (
				(
					_viewingChannels.length == 0
			 		|| _viewingChannels.indexOf(line.c)>=0 
			 		|| (_filterText && _viewingChannels.indexOf(config.filteredChannel) >= 0 && line.text.toLowerCase().indexOf(_filterText.toLowerCase())>=0 )
			 		|| (_filterRegExp && _viewingChannels.indexOf(config.filteredChannel)>=0 && line.text.search(_filterRegExp)>=0 )
			 	) 
			 	&& ( _priority <= 0 || line.p >= _priority)
			);
		}
		public function set priority (i:int):void{
			_priority = i;
			updateToBottom();
			updateMenu();
		}
		public function get priority ():int{
			return _priority;
		}
		public function get viewingChannels():Array{
			return _viewingChannels;
		}
		public function set viewingChannels(a:Array):void{
			_viewingChannels.splice(0);
			if(a && a.length) {
				if(a.indexOf(config.globalChannel) >= 0) a = [];
				for each(var item:Object in a) _viewingChannels.push(item is ConsoleChannel?(ConsoleChannel(item).name):String(item));
			}
			updateToBottom();
			master.panels.updateMenu();
		}
		//
		public function set filterText(str:String):void{
			_filterText = str;
			if(str){
				_filterRegExp = null;
				master.clear(config.filteredChannel);
				_channels.splice(1,0,config.filteredChannel);
				master.ch(config.filteredChannel, "Filtering ["+str+"]", 10);
				viewingChannels = [config.filteredChannel];
			}else if(_viewingChannels.length == 1 && _viewingChannels[0] == config.filteredChannel){
				viewingChannels = [config.globalChannel];
			}
		}
		public function get filterText():String{
			return _filterText?_filterText:(_filterRegExp?String(_filterRegExp):null);
		}
		//
		public function set filterRegExp(exp:RegExp):void{
			_filterRegExp = exp;
			if(exp){
				_filterText = null;
				master.clear(config.filteredChannel);
				_channels.splice(1,0,config.filteredChannel);
				master.ch(config.filteredChannel, "Filtering RegExp ["+exp+"]", 10);
				viewingChannels = [config.filteredChannel];
			}else if(_viewingChannels.length == 1 && _viewingChannels[0] == config.filteredChannel){
				viewingChannels = [config.globalChannel];
			}
		}
		private function makeLine(line:Log):String{
			var str:String = "";
			var txt:String = line.text;
			if(line.c != config.defaultChannel && (_viewingChannels.length == 0 || _viewingChannels.length>1)){
				txt = "[<a href=\"event:channel_"+line.c+"\">"+line.c+"</a>] "+txt;
			}
			var ptag:String = "p"+line.p;
			str += "<p><"+ptag+">" + txt + "</"+ptag+"></p>";
			return str;
		}
		private function onTraceScroll(e:Event = null):void{
			if(_lockScrollUpdate) return;
			var atbottom:Boolean = _traceField.scrollV >= _traceField.maxScrollV-1;
			if(!master.paused && _atBottom !=atbottom){
				var diff:int = _traceField.maxScrollV-_traceField.scrollV;
				_atBottom = atbottom;
				_updateTraces();
				_traceField.scrollV = _traceField.maxScrollV-diff;
			}
			updateScroller();
		}
		private function updateScroller():void{
			if(_traceField.maxScrollV <= 1){
				_txtscroll.visible = false;
			}else{
				_txtscroll.visible = true;
				if(_atBottom) {
					_txtscroll.scrollPercent = 1;
				}else{
					_txtscroll.scrollPercent = (_traceField.scrollV-1)/(_traceField.maxScrollV-1);
				}
			}
		}
		private function startedScrollingHandle(e:Event):void{
			if(!master.paused){
				_atBottom = false;
				var p:Number = _txtscroll.scrollPercent;
				_updateTraces();
				_txtscroll.scrollPercent = p;
			}
		}
		private function onScrolledHandle(e:Event):void{
			_lockScrollUpdate = true;
			_traceField.scrollV = Math.round((_txtscroll.scrollPercent*(_traceField.maxScrollV-1))+1);
			_lockScrollUpdate = false;
		}
		private function onScrollIncHandle(e:Event):void{
			_traceField.scrollV += _txtscroll.targetIncrement;
		}
		private function stoppedScrollingHandle(e:Event):void{
			onTraceScroll();
		}
		override public function set width(n:Number):void{
			_lockScrollUpdate = true;
			super.width = n;
			_traceField.width = n-4;
			txtField.width = n;
			
			_bottomLine.graphics.clear();
			_bottomLine.graphics.lineStyle(1, config.controlColor);
			_bottomLine.graphics.moveTo(10, -1);
			_bottomLine.graphics.lineTo(n-10, -1);
			_txtscroll.x = n;
			_atBottom = true;
			_needUpdateMenu = true;
			_needUpdateTrace = true;
			_lockScrollUpdate = false;
		}
		override public function set height(n:Number):void{
			_lockScrollUpdate = true;
			super.height = n;
			var minimize:Boolean = false;
			if(n<24){
				minimize = true;
			}
			if(_isMinimised != minimize){
				registerDragger(txtField, minimize);
				registerDragger(_traceField, !minimize);
				_isMinimised = minimize;
			}
			var fsize:int = master.config.menuFontSize;
			txtField.visible = !minimize;
			_traceField.y = minimize?0:fsize;
			_traceField.height = n-(minimize?0:fsize);
			_bottomLine.y = n;
			//
			_txtscroll.height = (_bottomLine.y-10)-_txtscroll.y;
			//
			_atBottom = true;
			_needUpdateTrace = true;
			_lockScrollUpdate = false;
		}
		//
		//
		//
		public function updateMenu(instant:Boolean = false):void{
			if(instant){
				_updateMenu();
			}else{
				_needUpdateMenu = true;
			}
		}
		private function _updateMenu():void{
			var str:String = "<r><w>";
			if(!master.panels.channelsPanel){
				str += getChannelsLink(true);
			}
			str += "<menu>[ <b>";
			str += doActive("<a href=\"event:fps\">F</a>", master.fpsMonitor>0);
			str += doActive(" <a href=\"event:mm\">M</a>", master.memoryMonitor>0);
			str += " ¦</b>";
			for each(var link:String in _extraMenuKeys){
				str += " <a href=\"event:"+link+"\">"+link+"</a>";
			}
			if(config.traceCall != null && (_canUseTrace || config.traceCall != trace)){
				str += doActive(" <a href=\"event:trace\">T</a>", master.tracing);
			}
			str += " <a href=\"event:copy\">Cc</a>";
			str += " <a href=\"event:priority\">P"+_priority+"</a>";
			str += doActive(" <a href=\"event:pause\">P</a>", master.paused);
			str += " <a href=\"event:clear\">C</a> <a href=\"event:close\">X</a>";
			
			str += " ]</menu> </w></r>";
			txtField.htmlText = str;
			txtField.scrollH = txtField.maxScrollH;
		}
		public function getChannelsLink(limited:Boolean = false):String{
			var str:String = "<chs>";
			var len:int = _channels.length;
			if(limited && len>MAX_MENU_CHANNELS) len = MAX_MENU_CHANNELS;
			for(var ci:int = 0; ci<len;  ci++){
				var channel:String = _channels[ci];
				var channelTxt:String = ((ci == 0 && _viewingChannels.length == 0) || _viewingChannels.indexOf(channel)>=0) ? "<ch><b>"+channel+"</b></ch>" : channel;
				str += "<a href=\"event:channel_"+channel+"\">["+channelTxt+"]</a> ";
			}
			if(limited){
				str += "<ch><a href=\"event:channels\"><b>"+(_channels.length>len?"...":"")+"</b>^^ </a></ch>";
			}
			str += "</chs> ";
			return str;
		}
		private function doActive(str:String, b:Boolean):String{
			if(b) return "<hi>"+str+"</hi>";
			return str;
		}
		public function onMenuRollOver(e:TextEvent, src:AbstractPanel = null):void{
			if(src==null) src = this;
			var txt:String = e.text?e.text.replace("event:",""):"";
			if(topMenuRollOver!=null) {
				var t:String = topMenuRollOver(txt);
				if(t) {
					master.panels.tooltip(t, src);
					return;
				}
			}
			if(txt == "channel_"+config.globalChannel){
				txt = TOOLTIPS["viewall"];
			}else if(txt == "channel_"+config.defaultChannel) {
				txt = TOOLTIPS["defaultch"];
			}else if(txt == "channel_"+ config.consoleChannel) {
				txt = TOOLTIPS["consolech"];
			}else if(txt == "channel_"+ config.filteredChannel) {
				txt = TOOLTIPS["filterch"]+"::*"+master.filterText+"*";
			}else if(txt.indexOf("channel_")==0) {
				txt = TOOLTIPS["channel"];
			}else if(txt == "pause"){
				if(master.paused)
					txt = TOOLTIPS["resume"];
				else
					txt = TOOLTIPS["pause"];
			}else if(txt == "copy"){
				txt = TOOLTIPS["copy"];
			}else if(txt == "close" && src == this){
				txt = TOOLTIPS["closemain"];
			}else{
				txt = TOOLTIPS[txt];
			}
			master.panels.tooltip(txt, src);
		}
		private function linkHandler(e:TextEvent):void{
			txtField.setSelection(0, 0);
			stopDrag();
			if(topMenuClick!=null && topMenuClick(e.text)) return;
			if(e.text == "pause"){
				if(master.paused){
					master.paused = false;
					master.panels.tooltip(TOOLTIPS["pause"], this);
				}else{
					master.paused = true;
					master.panels.tooltip(TOOLTIPS["resume"], this);
				}
			}else if(e.text == "trace"){
				master.tracing = !master.tracing;
				if(master.tracing){
					master.report("Tracing turned [<b>On</b>]",-1);
				}else{
					master.report("Tracing turned [<b>Off</b>]",-1);
				}
			}else if(e.text == "close"){
				master.panels.tooltip();
				visible = false;
				//dispatchEvent(new Event(AbstractPanel.CLOSED));
			}else if(e.text == "channels"){
				master.panels.channelsPanel = !master.panels.channelsPanel;
			}else if(e.text == "fps"){
				master.fpsMonitor = !master.fpsMonitor;
			}else if(e.text == "priority"){
				if(_priority<10){
					priority++;
				}else{
					priority = 0;
				}
			}else if(e.text == "mm"){
				master.memoryMonitor = !master.memoryMonitor;
			}else if(e.text == "copy") {
				System.setClipboard(master.getAllLog());
				master.report("Copied log to clipboard.", -1);
			}else if(e.text == "clear"){
				master.clear();
			}else if(e.text.substring(0,8) == "channel_"){
				onChannelPressed(e.text.substring(8));
			}
			txtField.setSelection(0, 0);
			e.stopPropagation();
		}
		public function onChannelPressed(chn:String):void{
			var current:Array = _viewingChannels.concat();
			if(_shift && _viewingChannels.length > 0 && chn != config.globalChannel){
				var ind:int = current.indexOf(chn);
				if(ind>=0){
					current.splice(ind,1);
					if(current.length == 0){
						current.push(config.globalChannel);
					}
				}else{
					current.push(chn);
				}
				viewingChannels = current;
			}else{
				viewingChannels = [chn];
			}
		}
	}
}
